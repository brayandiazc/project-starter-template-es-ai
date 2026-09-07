#!/usr/bin/env bash
# spec-guardrails.sh — hook PreToolUse (Write|Edit|NotebookEdit) que hace OBLIGATORIAS las
# especificaciones: en ramas feat/* y fix/* no se puede tocar código si no existe
# la spec correspondiente en specs/ **y está escrita**. La rama y la spec comparten
# slug:
#   feat/login-google  →  specs/NNNN-login-google/
# "Escrita" = su proposal.md ya no conserva líneas de specs/_template/proposal.md
# sin rellenar (incluidas las CONTINUACIONES de un placeholder multilínea), y
# design.md/tasks.md no conservan líneas con placeholders [así] de sus plantillas.
# Una carpeta con la plantilla intacta no es un contrato.
# Documentación (docs/), specs, tooling (.claude/, .github/, .githooks/) y el
# Markdown de la raíz quedan exentos: se pueden editar siempre.
# Activo por defecto en settings.json (ver docs/conventions/ai-agents.md).
#
# Contrato del hook: lee el JSON del evento por stdin y devuelve exit 2 para
# BLOQUEAR — el motivo (stderr) se le muestra al agente. Exit 0 permite.
# Ante cualquier duda, falla ABIERTO (permite) para no trabar el flujo.
set -euo pipefail

payload="$(cat)"

file_path="$(printf '%s' "$payload" \
  | python3 -c 'import sys,json; ti=json.load(sys.stdin).get("tool_input",{}); print(ti.get("file_path") or ti.get("notebook_path") or "")' \
  2>/dev/null || true)"

[ -z "$file_path" ] && exit 0

dir="$(dirname "$file_path")"
# La carpeta puede no existir todavía — es el caso NORMAL al crear un archivo en una
# carpeta nueva: una spec, un componente. Subimos al ancestro más cercano que sí
# exista, en vez de caer a $PWD, que puede ser OTRO repositorio: si eso pasa, el hook
# lee la rama equivocada y su veredicto depende de dónde estés parado, no del archivo.
while [ ! -d "$dir" ] && [ "$dir" != "/" ] && [ "$dir" != "." ] && [ -n "$dir" ]; do
  dir="$(dirname "$dir")"
done
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
  specs/*|docs/*|.claude/*|.github/*|.githooks/*) exit 0 ;;
  # Cualquier otra ruta anidada sigue la regla, incluido su Markdown: en muchos
  # proyectos el contenido .md ES el producto (design/, legal/, content/).
  */*) : ;;
  # Markdown de la raíz (README, CHANGELOG, AGENTS…): siempre editable.
  *.md) exit 0 ;;
esac

# Slug esperado: lo que sigue al prefijo de tipo, con / interiores como -.
slug="${branch#*/}"
slug="${slug//\//-}"

# ¿Existe specs/NNNN-<slug>/ (o en specs/archive/)? El prefijo numérico es libre.
spec_dir=""
for d in "$root/specs/"*"-$slug" "$root/specs/archive/"*"-$slug"; do
  if [ -d "$d" ]; then
    spec_dir="$d"
    break
  fi
done

if [ -z "$spec_dir" ]; then
  echo "⛔ spec-guardrails: la rama '$branch' no tiene especificación en specs/. \
Sin spec no hay cambio (docs/conventions/workflow.md): crea primero la spec con \
/new-spec '$slug' (debe llamarse specs/NNNN-$slug/), complétala, y recién entonces \
edita código. Si esto es documentación pura, usa una rama docs/*." >&2
  exit 2
fi

# ── La spec existe: ¿está escrita? ───────────────────────────────────────────
# Sin la plantilla de referencia no hay nada con qué comparar: falla ABIERTO.
tmpl="$root/specs/_template/proposal.md"
[ -f "$tmpl" ] || exit 0

proposal="$spec_dir/proposal.md"
spec_rel="${spec_dir#"$root"/}"

if [ ! -f "$proposal" ]; then
  echo "⛔ spec-guardrails: '$spec_rel' no tiene proposal.md. Es el contrato del \
cambio (problema, objetivo, alcance, ítem de roadmap): cópialo de \
specs/_template/proposal.md y complétalo antes de tocar código." >&2
  exit 2
fi

# Líneas de la plantilla que son marcadores por rellenar. Si alguna sobrevive
# literal en el archivo de la spec, la spec sigue siendo la plantilla.
#
# Dos reglas (python3: el filtro necesita distinguir estructura de contenido):
#   1. Líneas con un placeholder [así] que no son enlaces markdown. El checkbox
#      "- [ ]" no cuenta como placeholder por sí solo — hay casillas legítimas
#      que sobreviven rellenas (tasks.md §Documentación).
#   2. Solo con "prosa": las CONTINUACIONES de un placeholder multilínea —
#      líneas de prosa que no son encabezado, cita, tabla ni etiqueta **así**.
#      Sin esto, rellenar la primera línea del "Ítem de roadmap" y dejar las
#      otras dos intactas pasaba el check (regresión real de proposal.md:6-8).
#      Se aplica a proposal.md y design.md — toda su prosa suelta de plantilla
#      es continuación de un placeholder. En tasks.md NO: su línea 3 es prosa
#      instructiva que sobrevive rellena.
tmpl_markers() { # $1 = plantilla, $2 = "prosa" para incluir continuaciones
  python3 - "$1" "${2:-}" <<'PY' 2>/dev/null || true
import re, sys
prosa = len(sys.argv) > 2 and sys.argv[2] == "prosa"
for line in open(sys.argv[1], encoding="utf-8"):
    line = line.rstrip("\n")
    s = line.strip()
    if not s:
        continue
    core = re.sub(r"^-\s*\[[ xX]\]\s*", "", s)
    if "[" in core and "](" not in core:
        print(line)
    elif prosa and not (s.startswith(("#", ">", "|")) or re.fullmatch(r"\*\*[^*]+\*\*:?", s)):
        print(line)
PY
}

# check_pendiente <archivo-de-la-spec> <plantilla> [prosa]: bloquea si el
# archivo conserva marcadores. Archivo o plantilla ausentes: falla ABIERTO.
check_pendiente() {
  local target="$1" template="$2" modo="${3:-}" markers pending count
  [ -f "$target" ] && [ -f "$template" ] || return 0
  markers="$(tmpl_markers "$template" "$modo")"
  [ -n "$markers" ] || return 0
  pending="$(grep -Fxf <(printf '%s\n' "$markers") "$target" 2>/dev/null || true)"
  [ -z "$pending" ] && return 0
  count="$(printf '%s\n' "$pending" | wc -l | tr -d ' ')"
  echo "⛔ spec-guardrails: '$spec_rel/$(basename "$target")' conserva $count línea(s) de la \
plantilla sin rellenar — la spec no está escrita todavía. Complétalas (o borra las \
secciones que no apliquen) antes de editar código:" >&2
  # Las 5 primeras bastan para orientar. sed -n en vez de `head` para no cerrar
  # la tubería antes de tiempo teniendo pipefail activo.
  printf '%s\n' "$pending" | sed -n '1,5s|^|   · |p' >&2
  exit 2
}

check_pendiente "$proposal" "$tmpl" prosa
check_pendiente "$spec_dir/design.md" "$root/specs/_template/design.md" prosa
check_pendiente "$spec_dir/tasks.md" "$root/specs/_template/tasks.md"

exit 0
