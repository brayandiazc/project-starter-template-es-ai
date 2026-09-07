#!/usr/bin/env bash
# design-md.sh — genera y verifica DESIGN.md a partir de design/tokens.css.
#
# DESIGN.md es el borrador de especificación que Google Labs liberó en abril de 2026
# (google-labs-code/design.md, Apache 2.0): un archivo en la raíz que le da a cualquier
# agente de IA el sistema de diseño en un formato que entiende, igual que AGENTS.md hace
# con las instrucciones del repositorio.
#
# POR QUÉ SE GENERA Y NO SE ESCRIBE:
#   El spec pide los tokens en el frontmatter YAML. Pero los tokens ya viven en
#   design/tokens.css, que es lo que el navegador lee en runtime y lo que consume el
#   framework de UI que uses. Escribir DESIGN.md a mano sería una SEGUNDA COPIA de los
#   mismos valores — exactamente la deriva que este repositorio evita en todas partes
#   (por eso design/preview.html enlaza tokens.css en vez de copiarlo).
#   Así que tokens.css manda y DESIGN.md se deriva. Si divergen, gana el CSS.
#
# Uso:
#   bash .github/scripts/design-md.sh --write   # regenera DESIGN.md
#   bash .github/scripts/design-md.sh           # verifica que esté sincronizado (CI)
#
# Requiere: python3. Sale con 1 si DESIGN.md no coincide con tokens.css.
set -euo pipefail

ROOT="${2:-.}"
[ "${1:-}" = "--write" ] || ROOT="${1:-.}"
cd "$ROOT"

TOKENS="design/tokens.css"
OUT="DESIGN.md"

# Sin design/ no hay sistema de diseño que documentar: es un producto sin interfaz y
# DESIGN.md no aplica. Que exista uno huérfano sería peor que no tenerlo.
if [ ! -f "$TOKENS" ]; then
  if [ -f "$OUT" ]; then
    echo "❌ Hay $OUT pero no $TOKENS: o falta la fuente, o sobra el archivo generado."
    echo "→ Si el producto no tiene interfaz, borra $OUT."
    exit 1
  fi
  echo "ℹ️  Sin $TOKENS: el producto no tiene sistema de diseño. Nada que generar."
  exit 0
fi

generado="$(python3 - "$TOKENS" <<'PY'
import re, sys

css = open(sys.argv[1], encoding="utf-8").read()
css = re.sub(r"/\*.*?\*/", "", css, flags=re.S)  # fuera comentarios


def bloques(patron):
    """Fusiona TODOS los bloques que casen: tokens.css tiene más de un `:root`
    —color en uno, geometría y tipografía en otro— y quedarse con el primero
    silenciaba la mitad de la tipografía."""
    vals = {}
    for m in re.finditer(patron + r"\s*\{(.*?)\n\}", css, re.S):
        vals.update(re.findall(r"--([a-z0-9-]+)\s*:\s*([^;]+);", m.group(1)))
    return vals


claro = bloques(r":root(?!\[)(?!:)")
oscuro = bloques(r":root\[data-theme=\"dark\"\]")

def yaml(v):
    """Escalar YAML entre comillas simples: los valores de tipografía llevan comillas
    dobles dentro ("Inter", "Space Grotesk") y entrecomillarlos con dobles producía
    YAML inválido que ningún agente podría parsear."""
    return "'" + " ".join(v.split()).replace("'", "''") + "'"


# El orden importa: es el que se lee, no el alfabético.
orden = [
    "base-100", "base-200", "base-300", "base-content",
    "primary", "primary-content", "secondary", "secondary-content",
    "accent", "accent-content", "neutral", "neutral-content",
    "info", "info-content", "success", "success-content",
    "warning", "warning-content", "error", "error-content",
]

out = ["---", "# GENERADO por .github/scripts/design-md.sh — no lo edites a mano.",
       "# La fuente de verdad es design/tokens.css.", "colors:"]
for tema, vals in (("light", claro), ("dark", oscuro)):
    if not vals:
        continue
    out.append(f"  {tema}:")
    for k in orden:
        if k in vals:
            out.append(f"    {k}: {yaml(vals[k])}")

tipo = {k: v for k, v in claro.items() if k in ("sans", "display", "mono")}
if tipo:
    out.append("typography:")
    for k, v in tipo.items():
        out.append(f"  {k}: {yaml(v)}")

radios = {k: v for k, v in claro.items() if k in ("field", "box")}
if radios:
    out.append("radius:")
    for k, v in radios.items():
        out.append(f"  {k}: {yaml(v)}")

out += [
    "---",
    "",
    "# Sistema de diseño",
    "",
    "Los tokens de arriba son la paleta completa del producto, en OKLCH y en sus dos temas.",
    "**Úsalos siempre por su nombre** (`var(--primary)`, o la utilidad equivalente de tu",
    "framework): nunca escribas un hex ni una utilidad de paleta cruda en un componente.",
    "",
    "Este archivo lo genera `.github/scripts/design-md.sh` desde `design/tokens.css`, que es",
    "la fuente de verdad — el navegador lo lee en runtime y tu framework de UI lo consume",
    "por el adaptador del final. Editarlo a mano no sirve de nada: el CI compara los dos y",
    "falla.",
    "",
    "## Dónde está el resto",
    "",
    "- **Las reglas** —primitivas nativas antes que componentes propios, los cuatro estados",
    "  de cada vista, accesibilidad AA en ambos temas— en [`docs/conventions/ui.md`](docs/conventions/ui.md).",
    "- **Verlo aplicado**: abre [`design/preview.html`](design/preview.html) en el navegador.",
    "  Enlaza `tokens.css` directamente y calcula el contraste en vivo, así que muestra los",
    "  colores reales y no una descripción de ellos.",
    "- **Elegir la paleta de un producto nuevo**: la skill `/identidad`.",
    "",
]
print("\n".join(out))
PY
)"

if [ "${1:-}" = "--write" ]; then
  printf '%s\n' "$generado" >"$OUT"
  echo "✅ $OUT regenerado desde $TOKENS."
  exit 0
fi

if [ ! -f "$OUT" ]; then
  echo "❌ Falta $OUT. Genéralo con: bash .github/scripts/design-md.sh --write"
  exit 1
fi

if ! printf '%s\n' "$generado" | diff -q - "$OUT" >/dev/null; then
  echo "❌ $OUT no coincide con $TOKENS."
  echo "→ Los tokens mandan. Regenera con: bash .github/scripts/design-md.sh --write"
  exit 1
fi
echo "✅ DESIGN.md sincronizado con design/tokens.css."
