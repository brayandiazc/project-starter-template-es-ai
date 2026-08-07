#!/usr/bin/env bash
# git-guardrails.sh — hook PreToolUse que bloquea acciones de git que violan el
# branching de CONTRIBUTING.md: commits/merges/push en main|master|develop,
# force-push, y creación de ramas de trabajo desde main (deben nacer de develop;
# excepciones: develop misma y hotfix/*). Activo por defecto en settings.json;
# se puede desactivar quitando el hook (ver docs/conventions/ai-agents.md).
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
# "subcomando<US>force<US>ruta-de--C<US>rama-nueva<US>base" (US = \x1f; los dos últimos
# campos solo aplican a la creación de ramas; van vacíos en commit/push/merge).
verdicts="$(printf '%s' "$cmd" | python3 -c '
import sys, shlex

try:
    toks = shlex.split(sys.stdin.read())
except ValueError:
    sys.exit(0)  # comando no parseable: falla abierto

SEP = {"&&", "||", ";", "|"}
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
    non_create_branch = False
    j = i + 1
    while j < len(toks) and toks[j] not in SEP:
        t = toks[j]
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
            if t in ("--force", "--force-with-lease") or t.startswith("--force-with-lease="):
                force = "1"
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
            if not t.startswith("-"):
                positional.append(t)
        j += 1
    if sub == "branch" and not non_create_branch and positional:
        creates = True
    if creates and positional:
        newbranch = positional[0]
        base = positional[1] if len(positional) > 1 else ""
    if sub in ("commit", "push", "merge"):
        print(sub + SEPCH + force + SEPCH + cdir + SEPCH + SEPCH)
    elif creates and newbranch:
        print("crear-rama" + SEPCH + "0" + SEPCH + cdir + SEPCH + newbranch + SEPCH + base)
    i = j
' 2>/dev/null || true)"

[ -z "$verdicts" ] && exit 0

protected_re='^(main|master|develop)$'
block() { echo "⛔ git-guardrails: $1" >&2; exit 2; }

while IFS=$'\x1f' read -r sub force cdir newbranch base; do
  [ -z "$sub" ] && continue

  # Rama del repo objetivo; symbolic-ref la resuelve incluso sin commits. Si no
  # es un repo git (o está en detached HEAD), no hay rama protegida que cuidar.
  if [ -n "$cdir" ]; then
    branch="$(git -C "$cdir" symbolic-ref --short -q HEAD 2>/dev/null || true)"
  else
    branch="$(git symbolic-ref --short -q HEAD 2>/dev/null || true)"
  fi

  # 1. Nada de commits (ni merges locales) directos en ramas protegidas.
  if { [ "$sub" = "commit" ] || [ "$sub" = "merge" ]; } && [ -n "$branch" ] && [[ "$branch" =~ $protected_re ]]; then
    block "No hagas $sub directo en '$branch'. Los cambios llegan a '$branch' vía PR (CONTRIBUTING.md)."
  fi

  # 2. Nada de push directo desde ramas protegidas, ni force-push a nada compartido.
  if [ "$sub" = "push" ]; then
    if [ -n "$branch" ] && [[ "$branch" =~ $protected_re ]]; then
      block "No hagas push directo desde '$branch'. Abre un PR desde tu rama (CONTRIBUTING.md)."
    fi
    if [ "$force" = "1" ]; then
      block "Force-push bloqueado: reescribir historial compartido rompe a otros (CONTRIBUTING.md)."
    fi
  fi

  # 3. Las ramas de trabajo nacen de develop, no de main. Únicas excepciones:
  # crear la propia develop (clon de main) y los hotfix/* (CONTRIBUTING.md).
  if [ "$sub" = "crear-rama" ] && [ -n "$newbranch" ]; then
    eff_base="$base"
    [ -z "$eff_base" ] && eff_base="$branch"
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
