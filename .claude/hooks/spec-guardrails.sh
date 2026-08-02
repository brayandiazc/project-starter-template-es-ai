#!/usr/bin/env bash
# spec-guardrails.sh — hook PreToolUse (Write|Edit) que hace OBLIGATORIAS las
# especificaciones: en ramas feat/* y fix/* no se puede tocar código si no existe
# la spec correspondiente en specs/. La rama y la spec comparten slug:
#   feat/login-google  →  specs/NNNN-login-google/
# Documentación, specs y tooling quedan exentos (se pueden editar siempre).
# Activo por defecto en settings.json (ver docs/conventions/ai-agents.md).
#
# Contrato del hook: lee el JSON del evento por stdin y devuelve exit 2 para
# BLOQUEAR — el motivo (stderr) se le muestra al agente. Exit 0 permite.
# Ante cualquier duda, falla ABIERTO (permite) para no trabar el flujo.
set -euo pipefail

payload="$(cat)"

file_path="$(printf '%s' "$payload" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' \
  2>/dev/null || true)"

[ -z "$file_path" ] && exit 0

dir="$(dirname "$file_path")"
[ -d "$dir" ] || dir="$PWD"

# Raíz y rama del repo objetivo; si no es un repo git, no hay regla que aplicar.
root="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true)"
[ -z "$root" ] && exit 0
branch="$(git -C "$root" symbolic-ref --short -q HEAD 2>/dev/null || true)"

# La regla solo aplica a ramas de funcionalidad/corrección.
case "$branch" in
  feat/*|fix/*) : ;;
  *) exit 0 ;;
esac

# Si el proyecto no usa specs (borró la carpeta), no imponemos nada.
[ -d "$root/specs" ] || exit 0

# Rutas exentas: la spec misma, documentación y tooling — relativas a la raíz.
# realpath: sin canonicalizar, los symlinks (p. ej. /var → /private/var en macOS)
# impiden recortar el prefijo de la raíz.
file_path_real="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$file_path" 2>/dev/null || printf '%s' "$file_path")"
rel="${file_path_real#"$root"/}"
case "$rel" in
  specs/*|docs/*|.claude/*|.github/*|*.md) exit 0 ;;
esac

# Slug esperado: lo que sigue al prefijo de tipo, con / interiores como -.
slug="${branch#*/}"
slug="${slug//\//-}"

# ¿Existe specs/NNNN-<slug>/ (o en specs/archive/)? El prefijo numérico es libre.
for d in "$root/specs/"*"-$slug" "$root/specs/archive/"*"-$slug"; do
  [ -d "$d" ] && exit 0
done

echo "⛔ spec-guardrails: la rama '$branch' no tiene especificación en specs/. \
Sin spec no hay cambio (docs/conventions/workflow.md): crea primero la spec con \
/new-spec '$slug' (debe llamarse specs/NNNN-$slug/), complétala, y recién entonces \
edita código. Si esto es documentación pura, usa una rama docs/*." >&2
exit 2
