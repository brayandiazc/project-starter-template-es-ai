#!/usr/bin/env bash
# check-skills.sh — valida la estructura de las skills y subagentes de Claude.
#
# Reglas (ver .claude/skills/README.md):
#   - Cada `.claude/skills/<dir>/SKILL.md` tiene frontmatter YAML con `name` (en
#     kebab-case e igual al nombre de su carpeta) y `description` no vacía y con
#     longitud útil (≥ 40 caracteres: debe decir cuándo invocarla, no solo qué es).
#   - Cada `.claude/agents/<nombre>.md` tiene frontmatter con `name` (igual al
#     nombre del archivo sin extensión) y `description` no vacía.
#
# Uso:
#   bash .github/scripts/check-skills.sh [raíz-del-repo]
#
# Sale con 1 si encuentra problemas. Si el repo no tiene capa de IA, no hay nada
# que validar y sale con 0.
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

fail=0
err() { echo "❌ $1"; fail=1; }

# Extrae un campo del frontmatter (entre la primera pareja de `---`).
front() { # $1 = archivo, $2 = campo
  awk -v f="$2" '
    NR==1 && $0!="---" { exit }
    NR>1 && $0=="---" { exit }
    NR>1 && index($0, f":")==1 {
      sub("^" f ":[[:space:]]*", ""); print; exit
    }
  ' "$1"
}

# ── Skills ────────────────────────────────────────────────────────────────────
if [ -d .claude/skills ]; then
  for dir in .claude/skills/*/; do
    [ -d "$dir" ] || continue
    slug="$(basename "$dir")"
    file="$dir/SKILL.md"
    if [ ! -f "$file" ]; then
      err "skills/$slug: falta SKILL.md"
      continue
    fi
    name="$(front "$file" name)"
    desc="$(front "$file" description)"
    [ "$name" = "$slug" ] || err "skills/$slug: name '$name' no coincide con la carpeta"
    printf '%s' "$slug" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$' \
      || err "skills/$slug: el nombre no está en kebab-case"
    [ -n "$desc" ] || err "skills/$slug: description vacía o ausente"
    [ "${#desc}" -ge 40 ] || err "skills/$slug: description demasiado corta — debe decir cuándo invocarla"
    # Longitud: una skill debe caber en ~150 líneas (.claude/skills/README.md) —
    # el cuerpo se carga entero en el contexto cada vez que la skill se activa.
    # Sin excepciones: hasta `instanciar` cupo, moviendo lo enciclopédico a un
    # reference.md que se lee en el paso que lo cita.
    lineas="$(wc -l <"$file" | tr -d ' ')"
    [ "$lineas" -le 160 ] || err "skills/$slug: SKILL.md tiene $lineas líneas (límite ~150 — parte lo enciclopédico a un reference.md, ver .claude/skills/README.md)"
  done
fi

# ── Subagentes ────────────────────────────────────────────────────────────────
if [ -d .claude/agents ]; then
  for file in .claude/agents/*.md; do
    [ -f "$file" ] || continue
    base="$(basename "$file" .md)"
    [ "$base" = "README" ] && continue
    name="$(front "$file" name)"
    desc="$(front "$file" description)"
    modelo="$(front "$file" model)"
    [ "$name" = "$base" ] || err "agents/$base: name '$name' no coincide con el archivo"
    [ -n "$desc" ] || err "agents/$base: description vacía o ausente"
    esfuerzo="$(front "$file" effort)"
    # El modelo se DECLARA, siempre. Sin el campo, el subagente hereda el de la
    # sesión — que es una elección legítima, pero tiene que ser una elección: la
    # mitad del roster lo omitía y nadie lo veía, así que todos corrían con el
    # modelo caro sin que nadie lo hubiera decidido. `inherit` sigue valiendo;
    # lo que deja de valer es el silencio.
    #
    # Se aceptan los alias cortos, `inherit` y los IDs completos `claude-*`. Ojo
    # con la diferencia, que importa: **los alias se mueven**. `opus` apunta a la
    # versión recomendada del momento y cambia cuando Anthropic la actualiza; un
    # ID completo la fija. Para un subagente casi siempre quieres el alias.
    case "$modelo" in
      opus | sonnet | haiku | fable | inherit) : ;;
      claude-*) : ;;
      "") err "agents/$base: falta 'model' en el frontmatter — decláralo (opus, sonnet, haiku, fable, inherit o un ID claude-*)" ;;
      *) err "agents/$base: model '$modelo' no es válido (opus, sonnet, haiku, fable, inherit o un ID claude-*)" ;;
    esac
    # `effort` es opcional: omitirlo equivale a `high`. Solo se declara cuando se
    # desvía de ese default, para que declararlo signifique algo.
    case "$esfuerzo" in
      "" | low | medium | high | xhigh | max) : ;;
      *) err "agents/$base: effort '$esfuerzo' no es válido (low, medium, high, xhigh o max)" ;;
    esac
  done
fi

if [ "$fail" -ne 0 ]; then
  echo "→ Corrige el frontmatter (ver .claude/skills/README.md)."
  exit 1
fi
echo "✅ Skills y agentes: frontmatter válido."
