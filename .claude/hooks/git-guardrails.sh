#!/usr/bin/env bash
# git-guardrails.sh — hook PreToolUse (OPT-IN) que bloquea acciones de git que
# violan el branching de CONTRIBUTING.md. No está activo por defecto; se habilita
# desde settings.json / settings.local.json (ver docs/conventions/ai-agents.md).
#
# Contrato del hook: lee el JSON del evento por stdin y devuelve exit 2 para
# BLOQUEAR la herramienta — el motivo (stderr) se le muestra al agente. Exit 0
# permite. Ante cualquier duda, falla ABIERTO (permite) para no trabar el flujo.
set -euo pipefail

payload="$(cat)"

# Extraer el comando de Bash del JSON del evento (python3: parseo robusto).
cmd="$(printf '%s' "$payload" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' \
  2>/dev/null || true)"

# Solo nos interesan los comandos git; el resto pasa sin tocar.
case "$cmd" in
  *git\ *) : ;;
  *) exit 0 ;;
esac

# Rama actual; symbolic-ref la resuelve incluso en un repo sin commits. Si no es
# un repo git (o está en detached HEAD), no hay rama protegida que cuidar.
branch="$(git symbolic-ref --short -q HEAD 2>/dev/null || true)"
[ -z "$branch" ] && exit 0

protected_re='^(main|master|develop)$'
block() { echo "⛔ git-guardrails: $1" >&2; exit 2; }

# 1. Nada de commits directos en ramas protegidas.
if printf '%s' "$cmd" | grep -Eq 'git( +-[^ ]+)* +commit' \
   && [[ "$branch" =~ $protected_re ]]; then
  block "No hagas commit directo en '$branch'. Crea una rama feat/…|fix/…|docs/…|chore/… (CONTRIBUTING.md)."
fi

# 2. Nada de push directo desde ramas protegidas, ni force-push a nada compartido.
if printf '%s' "$cmd" | grep -Eq 'git( +-[^ ]+)* +push'; then
  if [[ "$branch" =~ $protected_re ]]; then
    block "No hagas push directo desde '$branch'. Abre un PR desde tu rama (CONTRIBUTING.md)."
  fi
  if printf '%s' "$cmd" | grep -Eq -- '--force([^-]|$)|--force-with-lease|(^| )-[a-zA-Z]*f'; then
    block "Force-push bloqueado: reescribir historial compartido rompe a otros (CONTRIBUTING.md)."
  fi
fi

exit 0
