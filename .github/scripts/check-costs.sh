#!/usr/bin/env bash
# check-costs.sh — un precio viejo no es información neutra: es plausible y falso.
#
# docs/marco-tecnico-infraestructura.md lleva en su cabecera la fecha en que sus precios se
# verificaron contra la fuente. Este check falla cuando esa fecha se queda vieja.
#
# Por qué existe: "se revisa cada trimestre" es una regla que solo se cumple
# leyendo, y esas no se cumplen. Y aquí el costo de olvidarla es alto —  en cuatro
# meses un proveedor de VPS subió sus líneas más del 100%, así que un presupuesto de
# hace dos trimestres no está algo desviado: está mal, y con pinta de estar bien.
#
# Uso:
#   bash .github/scripts/check-costs.sh [raíz-del-repo]
#
# Sin el documento (un proyecto que lo podó al instanciar) no impone nada.
# Sale con 1 si los precios pasaron del trimestre.
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

DOC="docs/marco-tecnico-infraestructura.md"
# Un trimestre, con margen: 100 días en vez de 92. La revisión no tiene por qué
# caer el día exacto, y un check que se pone rojo por dos días de retraso enseña
# a ignorarlo.
LIMITE_DIAS=100

[ -f "$DOC" ] || {
  echo "ℹ️  No hay $DOC en este repo; nada que verificar."
  exit 0
}

# Modo plantilla: el documento aún es el esqueleto y la fecha es el placeholder
# `[FECHA]`. No hay precios que caduquen, así que exigir una fecha real sería pedir
# un dato inventado — justo lo contrario de para qué existe este check. Se dice en
# voz alta, para que no se confunda con un ✅.
if grep -q '\*\*Fecha de verificación\*\*:[[:space:]]*\[FECHA\]' "$DOC"; then
  echo "ℹ️  Modo plantilla: $DOC todavía es el esqueleto (sin precios reales)."
  echo "   Al rellenarlo, pon la fecha en que verificaste cada precio contra su fuente."
  exit 0
fi

fecha="$(grep -m1 -oE '\*\*Fecha de verificación\*\*:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$DOC" \
  | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || true)"

if [ -z "$fecha" ]; then
  echo "❌ $DOC no declara una 'Fecha de verificación' con formato YYYY-MM-DD."
  echo "→ Añádela en la cabecera. Sin ella, nadie sabe si estos precios valen hoy:"
  echo
  echo "   > **Fecha de verificación**: $(date +%F)"
  exit 1
fi

# El cálculo va en python3 y no en `date`: BSD (macOS) y GNU (Ubuntu) no comparten
# la sintaxis de aritmética de fechas, y el mismo check daría resultados distintos
# en local y en el CI. Ese patrón ya nos costó un CI rojo con verde en macOS.
dias="$(python3 - "$fecha" <<'PY'
import datetime as dt, sys
try:
    d = dt.date.fromisoformat(sys.argv[1])
except ValueError:
    sys.exit(1)
print((dt.date.today() - d).days)
PY
)" || {
  echo "❌ $DOC declara una fecha ilegible: '$fecha'."
  exit 1
}

if [ "$dias" -lt 0 ]; then
  echo "❌ $DOC dice haberse verificado el $fecha, que está en el futuro."
  echo "→ Corrige la fecha: una verificación que no ha pasado no verifica nada."
  exit 1
fi

meses=$((dias / 30))

if [ "$dias" -gt "$LIMITE_DIAS" ]; then
  echo "❌ $DOC se verificó el $fecha: hace $dias días (~$meses meses)."
  echo "→ Los precios caducan rápido — hay proveedores que han subido líneas enteras"
  echo "  CCX/CPX más del 100%. Un presupuesto de hace dos trimestres no está algo"
  echo "  desviado: está mal, y con pinta de estar bien."
  echo
  echo "  Corre '/actualizar-costos' (revisa cada precio contra su fuente y actualiza"
  echo "  la fecha), o borra el documento si este proyecto no lo necesita."
  exit 1
fi

echo "✅ Costos: verificados el $fecha (hace $dias días)."
