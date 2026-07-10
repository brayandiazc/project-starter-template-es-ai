#!/usr/bin/env bash
# git-guardrails.sh — hook PreToolUse (OPT-IN) que bloquea acciones de git que
# violan el branching de CONTRIBUTING.md. No está activo por defecto; se habilita
# desde settings.json / settings.local.json (ver docs/conventions/ai-agents.md).
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
# "subcomando<TAB>force<TAB>ruta-de--C" (solo para commit/push).
verdicts="$(printf '%s' "$cmd" | python3 -c '
import sys, shlex

try:
    toks = shlex.split(sys.stdin.read())
except ValueError:
    sys.exit(0)  # comando no parseable: falla abierto

SEP = {"&&", "||", ";", "|"}
OPT_WITH_ARG = {"-C", "-c", "--git-dir", "--work-tree", "--namespace"}

i = 0
while i < len(toks):
    if toks[i] != "git":
        i += 1
        continue
    cdir, sub, force = "", "", "0"
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
            elif t.startswith("-") and not t.startswith("--") and "f" in t:
                force = "1"
        j += 1
    if sub in ("commit", "push"):
        print(sub + "\t" + force + "\t" + cdir)
    i = j
' 2>/dev/null || true)"

[ -z "$verdicts" ] && exit 0

protected_re='^(main|master|develop)$'
block() { echo "⛔ git-guardrails: $1" >&2; exit 2; }

while IFS=$'\t' read -r sub force cdir; do
  [ -z "$sub" ] && continue

  # Rama del repo objetivo; symbolic-ref la resuelve incluso sin commits. Si no
  # es un repo git (o está en detached HEAD), no hay rama protegida que cuidar.
  if [ -n "$cdir" ]; then
    branch="$(git -C "$cdir" symbolic-ref --short -q HEAD 2>/dev/null || true)"
  else
    branch="$(git symbolic-ref --short -q HEAD 2>/dev/null || true)"
  fi

  # 1. Nada de commits directos en ramas protegidas.
  if [ "$sub" = "commit" ] && [ -n "$branch" ] && [[ "$branch" =~ $protected_re ]]; then
    block "No hagas commit directo en '$branch'. Crea una rama feat/…|fix/…|docs/…|chore/… (CONTRIBUTING.md)."
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
done <<<"$verdicts"

exit 0
