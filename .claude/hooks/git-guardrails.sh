#!/usr/bin/env bash
# git-guardrails.sh — hook PreToolUse que bloquea acciones de git que violan el
# branching de CONTRIBUTING.md: commits/merges/pulls-de-otra-rama/push en
# main|master|develop, force-push, y creación de ramas de trabajo desde main
# (deben nacer de develop; excepciones: develop misma y hotfix/*). Un merge o
# pull con `--ff-only` pasa: no crea historial, solo mueve la rama a un estado
# ya publicado — es el back-merge post-release de CONTRIBUTING.md. Activo por
# defecto en settings.json; se puede desactivar quitando el hook (ver
# docs/conventions/ai-agents.md).
#
# Contrato del hook: lee el JSON del evento por stdin y devuelve exit 2 para
# BLOQUEAR la herramienta — el motivo (stderr) se le muestra al agente. Exit 0
# permite. Ante cualquier duda, falla ABIERTO (permite) para no trabar el flujo.
#
# Cobertura: cada invocación `git …` del comando (incluso encadenadas con && o ;),
# respetando `git -C <ruta>`. Limitación conocida (fail-open): `cd <otra-ruta> &&
# git …` evalúa la rama del cwd de la sesión, no la del destino del `cd`.
set -euo pipefail

payload="$(cat)"

# Extraer el comando de Bash del JSON del evento (python3: parseo robusto).
cmd="$(printf '%s' "$payload" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' \
  2>/dev/null || true)"

# Solo nos interesan los comandos que mencionan git; el resto pasa sin tocar.
case "$cmd" in
  *git*) : ;;
  *) exit 0 ;;
esac

# Analiza el comando con shlex: por cada invocación de git emite una línea
# "subcomando<US>force<US>ruta-de--C<US>rama-nueva<US>base<US>refs" (US = \x1f).
# `rama-nueva`/`base` solo aplican a la creación de ramas; `refs` solo a push, y
# lleva los refspecs (lo que se empuja) para poder distinguir un tag de una rama.
verdicts="$(printf '%s' "$cmd" | python3 -c '
import re, sys, shlex

raw = sys.stdin.read()

# El SALTO DE LÍNEA separa comandos igual que `&&` o `;`, pero shlex.split() lo
# trata como espacio y lo borra. Sin esto, los argumentos de un comando se
# atribuían al ANTERIOR: un script de dos líneas
#
#     git checkout -q develop && git pull -q origin develop
#     git checkout -b feat/x
#
# se leía como un `git pull` de la rama feat/x —que ni siquiera existía todavía—
# y quedaba bloqueado como "merge encubierto". Es la secuencia más común que
# existe (sincronizar develop y ramificar desde ella), y la prescribe la propia
# skill /instanciar. Un guardrail que acusa en falso enseña a saltárselo, y
# entonces deja de proteger cuando acierta.
#
# Se tokeniza línea a línea y se intercala un separador explícito. Si alguna
# línea no se puede leer sola —una cadena entrecomillada que abarca varias— se
# vuelve al parseo del comando entero, que es el comportamiento anterior.
#
# De paso se salta el CUERPO de los heredocs: es contenido, no comandos. Un mensaje
# de commit o un documento que mencione `git push --force` no está haciendo un
# force-push, y hasta ahora el hook lo bloqueaba (su hermano secret-guardrails ya
# contemplaba el caso). Se salta solo hasta el delimitador, no el resto del script:
# un comando de verdad escrito DESPUÉS del heredoc se sigue analizando.
def tokenizar(texto):
    piezas, hasta = [], None
    for n, linea in enumerate(texto.split("\n")):
        if hasta is not None:
            if linea.strip() == hasta:
                hasta = None
            continue
        try:
            trozos = shlex.split(linea)
        except ValueError:
            return None
        if n:
            piezas.append("\n")
        piezas.extend(trozos)
        # \x22 y \x27 son " y : una comilla literal aquí cerraría el python3 -c.
        m = re.search(r"<<-?\s*[\x22\x27]?([A-Za-z_][A-Za-z0-9_]*)", linea)
        if m:
            hasta = m.group(1)
    return piezas

toks = tokenizar(raw)
if toks is None:
    try:
        toks = shlex.split(raw)
    except ValueError:
        sys.exit(0)  # comando no parseable: falla abierto

REDIR = __import__("re").compile(r"^(?:\d*[<>]|&>|>>|<<)")
SEP = {"&&", "||", ";", "|", "\n"}
SEPCH = "\x1f"  # separador de campos: no colapsa como el tab en IFS
OPT_WITH_ARG = {"-C", "-c", "--git-dir", "--work-tree", "--namespace"}
# Flags de checkout/switch/branch que toman argumento propio (no posicional).
SUB_OPT_WITH_ARG = {"-t", "--track", "-u", "--set-upstream-to"}
# Usos de `git branch` que NO crean rama.
BRANCH_NON_CREATE = {"-d", "-D", "--delete", "-m", "-M", "--move", "-c", "--copy",
                     "-l", "--list", "-a", "--all", "-r", "--remotes",
                     "--show-current", "--set-upstream-to", "-u", "--unset-upstream",
                     "--edit-description", "--contains", "--merged", "--no-merged"}

i = 0
while i < len(toks):
    if toks[i] != "git":
        i += 1
        continue
    cdir, sub, force = "", "", "0"
    creates, newbranch, base, positional = False, "", "", []
    solo_tags_flag = False
    delete_flag = False
    ffonly = False
    non_create_branch = False
    j = i + 1
    while j < len(toks) and toks[j] not in SEP:
        t = toks[j]
        # Un `git` suelto empieza OTRA invocación: nunca es argumento de esta.
        # Cinturón y tirantes por si aparece un separador que no contemplamos.
        if t == "git":
            break
        if not sub:
            if t in OPT_WITH_ARG:
                if t == "-C" and j + 1 < len(toks):
                    cdir = toks[j + 1]
                j += 2
                continue
            if t.startswith("-"):
                j += 1
                continue
            sub = t
        else:
            if t in ("--tags", "--follow-tags") and sub == "push":
                solo_tags_flag = True
            if t in ("--delete", "-d") and sub == "push":
                delete_flag = True
            if t in ("--force", "--force-with-lease") or t.startswith("--force-with-lease="):
                force = "1"
            if t == "--ff-only" and sub in ("merge", "pull"):
                ffonly = True
            elif t.startswith("-") and not t.startswith("--") and "f" in t and sub == "push":
                force = "1"
            if sub in ("checkout", "switch") and t in ("-b", "-B", "-c", "-C", "--create", "--force-create"):
                creates = True
            elif sub == "branch":
                if t in BRANCH_NON_CREATE:
                    non_create_branch = True
                if t in SUB_OPT_WITH_ARG:
                    j += 2
                    continue
            # Una REDIRECCIÓN no es un refspec. Sin esto, `git push origin v1.0 2>&1`
            # dejaba refs="v1.0,2>&1", solo_tags() no encontraba un tag llamado "2>&1"
            # y el push del tag se bloqueaba como si moviera una rama protegida. Pasa
            # siempre que se redirige la salida, que es lo normal al automatizar.
            if REDIR.match(t):
                break
            if not t.startswith("-"):
                positional.append(t)
        j += 1
    if sub == "branch" and not non_create_branch and positional:
        creates = True
    if creates and positional:
        newbranch = positional[0]
        base = positional[1] if len(positional) > 1 else ""
    if sub == "push":
        # positional[0] es el remoto; el resto, los refspecs.
        refs = ",".join(positional[1:])
        if solo_tags_flag and not refs:
            refs = "--tags"
        # El campo `rama-nueva` transporta el flag --delete en los push: un push de
        # borrado no empuja el estado de la rama actual y sigue otra regla.
        print(sub + SEPCH + force + SEPCH + cdir + SEPCH + ("1" if delete_flag else "0") + SEPCH + SEPCH + refs)
    elif sub in ("commit", "merge", "pull"):
        # `newbranch` transporta el flag --ff-only; `refs` los refspecs del pull
        # (positional[0] es el remoto), para distinguir sincronizar la propia
        # rama de traerse OTRA rama (un merge encubierto).
        pull_refs = ",".join(positional[1:]) if sub == "pull" else ""
        print(sub + SEPCH + force + SEPCH + cdir + SEPCH + ("1" if ffonly else "0") + SEPCH + SEPCH + pull_refs)
    elif creates and newbranch:
        print("crear-rama" + SEPCH + "0" + SEPCH + cdir + SEPCH + newbranch + SEPCH + base + SEPCH)
    i = j
' 2>/dev/null || true)"

[ -z "$verdicts" ] && exit 0

protected_re='^(main|master|develop)$'
block() { echo "⛔ git-guardrails: $1" >&2; exit 2; }

# ¿Este push mueve solo tags? Un tag no actualiza ninguna rama, así que empujarlo
# desde `develop` no se salta ningún PR — y es justo lo que pide el paso 8 de la
# skill /release cuando release.yml no está activo.
solo_tags() { # $1 = refspecs separados por coma
  local refs="$1" r
  [ -z "$refs" ] && return 1                 # push a secas: mueve la rama actual
  [ "$refs" = "--tags" ] && return 0
  local IFS=,
  for r in $refs; do
    r="${r#+}"; r="${r%%:*}"                 # quita el '+' de force y el destino
    r="${r#refs/tags/}"
    git ${cdir:+-C "$cdir"} show-ref --verify -q "refs/tags/$r" 2>/dev/null && continue
    # PreToolUse evalúa la línea ENTERA antes de que se ejecute nada: en
    # `git tag v0.1.0 … && git push origin v0.1.0` el tag todavía no existe al
    # clasificar el push, y el refspec caía como rama — bloqueando justo el paso 8
    # de /release que solo_tags existe para permitir. Lo que tiene forma de versión
    # (v?X.Y.Z, sufijo opcional) se trata como tag aunque aún no exista. Una rama
    # llamada 'v1.2.3' colaría, pero ese nombre no existe en este flujo (feat/*,
    # fix/*, docs/*, chore/*, hotfix/*).
    [[ "$r" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]] || return 1
  done
  return 0
}

# ¿Este push solo BORRA refs del remoto? `--delete` convierte todos los refspecs
# en borrados; la forma antigua es el refspec con origen vacío (':rama'). Borrar
# la rama ya fusionada es justo lo que Git Flow manda al terminar, y el estado del
# que se hace push no es el destino del push: no empuja nada de la rama actual,
# así que no se salta ningún PR aunque se haga parado en develop.
solo_borrados() { # $1 = flag --delete, $2 = refspecs separados por coma
  local del="$1" refs="$2" r
  [ -z "$refs" ] && return 1
  local IFS=,
  for r in $refs; do
    if [ "$del" != "1" ]; then
      # ':rama' borra; ':' a secas es "matching branches" y NO es un borrado.
      case "$r" in :?*) ;; *) return 1 ;; esac
    fi
  done
  return 0
}

# Si entre lo borrado hay una rama protegida, la imprime (para bloquear con nombre).
borrado_protegido() { # $1 = flag --delete, $2 = refspecs
  local refs="$2" r
  local IFS=,
  for r in $refs; do
    r="${r#:}"; r="${r#refs/heads/}"
    if [[ "$r" =~ $protected_re ]]; then printf '%s' "$r"; return 0; fi
  done
  return 1
}

while IFS=$'\x1f' read -r sub force cdir newbranch base refs; do
  [ -z "$sub" ] && continue

  # Rama del repo objetivo; symbolic-ref la resuelve incluso sin commits. Si no
  # es un repo git (o está en detached HEAD), no hay rama protegida que cuidar.
  if [ -n "$cdir" ]; then
    branch="$(git -C "$cdir" symbolic-ref --short -q HEAD 2>/dev/null || true)"
  else
    branch="$(git symbolic-ref --short -q HEAD 2>/dev/null || true)"
  fi

  # 1. Nada de commits ni merges (explícitos o vía pull) directos en ramas
  # protegidas. Excepción: `--ff-only` no crea historial — solo mueve la rama a
  # un estado ya publicado, que es justo el back-merge post-release. Sin la
  # excepción, el hook bloqueaba la forma segura y dejaba pasar la peligrosa:
  # `git pull origin main` en develop era un merge encubierto que pasaba limpio.
  if { [ "$sub" = "commit" ] || [ "$sub" = "merge" ] || [ "$sub" = "pull" ]; } && [ -n "$branch" ] && [[ "$branch" =~ $protected_re ]]; then
    ffonly="$newbranch"
    case "$sub" in
      commit)
        block "No hagas commit directo en '$branch'. Los cambios llegan a '$branch' vía PR (CONTRIBUTING.md)." ;;
      merge)
        [ "$ffonly" = "1" ] || block "No hagas merge directo en '$branch': un merge con commit se salta el PR. El back-merge post-release es 'git merge --ff-only origin/main' (no crea historial); si las ramas divergieron, abre el PR main → develop (CONTRIBUTING.md)." ;;
      pull)
        # `git pull` a secas — o de la propia rama — sincroniza con upstream y
        # pasa. Traerse OTRA rama es un merge y sigue sus reglas.
        if [ "$ffonly" != "1" ] && [ -n "$refs" ]; then
          otra=""
          IFS=, read -ra _prefs <<<"$refs"
          for r in "${_prefs[@]}"; do
            [ "$r" = "$branch" ] || otra="$r"
          done
          [ -z "$otra" ] || block "No hagas 'git pull' de '$otra' estando en '$branch': es un merge encubierto que se salta el PR. Usa 'git pull --ff-only' para el back-merge post-release, o abre el PR main → develop (CONTRIBUTING.md)."
        fi ;;
    esac
  fi

  # 2. Nada de push directo desde ramas protegidas, ni force-push a nada compartido.
  # Excepciones: mover solo tags (solo_tags) y borrar ramas ya fusionadas
  # (solo_borrados) — salvo que lo borrado sea una protegida, que es lo que la
  # regla quiere impedir de verdad.
  if [ "$sub" = "push" ]; then
    del="$newbranch"  # en los push, el campo transporta el flag --delete
    if solo_borrados "$del" "$refs"; then
      if prot="$(borrado_protegido "$del" "$refs")"; then
        block "No borres la rama protegida '$prot' del remoto (CONTRIBUTING.md)."
      fi
    elif [ -n "$branch" ] && [[ "$branch" =~ $protected_re ]] && ! solo_tags "$refs"; then
      block "No hagas push directo desde '$branch'. Abre un PR desde tu rama (CONTRIBUTING.md)."
    fi
    if [ "$force" = "1" ]; then
      block "Force-push bloqueado: reescribir historial compartido rompe a otros (CONTRIBUTING.md)."
    fi
  fi

  # 3. Las ramas de trabajo nacen de develop, no de main. Únicas excepciones:
  # crear la propia develop (clon de main) y los hotfix/* (CONTRIBUTING.md).
  # La base se NORMALIZA antes de comparar: `origin/main`, `remotes/origin/main`
  # y `refs/(heads|remotes/origin)/main` son main igualmente — la forma más
  # idiomática tras un fetch (`git checkout -b feat/x origin/main`) se colaba.
  # Limitación conocida (fail-open): `git worktree add -b rama ruta main` no se
  # analiza; el worktree nuevo cae bajo estas mismas reglas en cuanto se use.
  if [ "$sub" = "crear-rama" ] && [ -n "$newbranch" ]; then
    eff_base="$base"
    [ -z "$eff_base" ] && eff_base="$branch"
    eff_base="${eff_base#refs/}"
    eff_base="${eff_base#remotes/}"
    eff_base="${eff_base#heads/}"
    eff_base="${eff_base#origin/}"
    eff_base="${eff_base#upstream/}"
    if [[ "$eff_base" =~ ^(main|master)$ ]] \
      && [ "$newbranch" != "develop" ] \
      && [[ "$newbranch" != hotfix/* ]]; then
      if git ${cdir:+-C "$cdir"} show-ref --verify -q refs/heads/develop 2>/dev/null; then
        block "La rama '$newbranch' debe nacer de 'develop', no de '$eff_base'. Usa: git checkout -b $newbranch develop (CONTRIBUTING.md)."
      else
        block "No crees '$newbranch' desde '$eff_base': primero crea 'develop' (git checkout -b develop $eff_base && git push -u origin develop) y saca tu rama de ahí (CONTRIBUTING.md)."
      fi
    fi
  fi
done <<<"$verdicts"

exit 0
