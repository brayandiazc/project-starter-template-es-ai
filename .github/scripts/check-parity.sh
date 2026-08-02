#!/usr/bin/env bash
# check-parity.sh — compara la estructura de archivos de esta plantilla con la
# de su variante hermana (es ↔ en) para detectar divergencias entre variantes.
#
# EXCLUSIVO DEL REPO-PLANTILLA: este script (y el workflow template-parity.yml
# que lo ejecuta) no tienen sentido en un proyecto instanciado — la skill
# /instanciar los elimina.
#
# Uso:
#   bash .github/scripts/check-parity.sh <ruta-al-repo-hermano>
#
# Compara solo archivos versionados (git ls-files), aplicando el mapa de
# renombres conocidos entre idiomas.
set -euo pipefail

SIBLING="${1:?uso: check-parity.sh <ruta-al-repo-hermano>}"

# Mapa de renombres conocidos entre variantes (es ↔ en). Se normalizan ambos
# lados hacia el nombre en inglés, así el script sirve en las dos direcciones.
normalize() {
  sed -e 's|skills/instanciar/|skills/instantiate/|' \
      -e 's|skills/portar-cambio/|skills/port-change/|' \
      -e 's|skills/actualizar-plantilla/|skills/update-template/|' \
      -e 's|skills/arrancar-proyecto/|skills/start-project/|' \
      -e 's|skills/definir-producto/|skills/define-product/|' \
      -e 's|skills/prototipo/|skills/prototype/|' \
      -e 's|skills/configurar-repo/|skills/setup-repo/|'
}

mine="$(git ls-files | normalize | sort)"
theirs="$(git -C "$SIBLING" ls-files | normalize | sort)"

if diff <(printf '%s\n' "$mine") <(printf '%s\n' "$theirs") >/tmp/parity-diff.$$ 2>&1; then
  echo "✅ Paridad estructural OK con la variante hermana."
  rm -f "/tmp/parity-diff.$$"
else
  echo "❌ Divergencia estructural con la variante hermana:"
  echo "   («<» solo existe aquí · «>» solo existe en la hermana)"
  cat "/tmp/parity-diff.$$"
  rm -f "/tmp/parity-diff.$$"
  echo "→ Porta el cambio pendiente (skill /portar-cambio) o actualiza el mapa de renombres de este script."
  exit 1
fi
