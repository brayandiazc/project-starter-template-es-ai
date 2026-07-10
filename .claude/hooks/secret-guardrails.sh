#!/usr/bin/env bash
# secret-guardrails.sh — hook PreToolUse (OPT-IN) para Write|Edit que bloquea
# escrituras del agente sobre archivos de secretos: el `.env` real y llaves
# privadas. Convierte la regla "nunca le des secretos a un agente" de
# docs/conventions/ai-agents.md en una garantía dura. No está activo por
# defecto; se habilita desde settings.json / settings.local.json.
#
# Contrato del hook: lee el JSON del evento por stdin y devuelve exit 2 para
# BLOQUEAR la herramienta — el motivo (stderr) se le muestra al agente. Exit 0
# permite. Ante cualquier duda, falla ABIERTO (permite) para no trabar el flujo.
set -euo pipefail

payload="$(cat)"

path="$(printf '%s' "$payload" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' \
  2>/dev/null || true)"
[ -z "$path" ] && exit 0

base="$(basename "$path")"
block() { echo "⛔ secret-guardrails: $1" >&2; exit 2; }

case "$base" in
  # Las plantillas de configuración sí se editan: son el contrato, sin valores reales.
  .env.example|.env.sample|.env.template) exit 0 ;;
  # El .env real (y variantes como .env.local, .env.production) no se toca.
  .env|.env.*)
    block "No escribas en '$base': los valores reales de entorno no se tocan ni se leen. Edita .env.example en su lugar (docs/conventions/secrets.md)." ;;
  # Llaves privadas y certificados.
  *.pem|*.key|id_rsa|id_rsa.*|id_ed25519|id_ed25519.*|id_ecdsa|id_ecdsa.*)
    block "No escribas en '$base': parece una llave privada o certificado (SECURITY.md)." ;;
esac

exit 0
