#!/bin/sh
# Comprobación de paridad de i18n — STUB.
#
# Esto es un marcador de posición. DEBES adaptarlo al formato de i18n de tu proyecto
# (p. ej. JSON, YAML, .po, .arb, .properties) y a la estructura de tu directorio de idiomas
# antes de confiar en él. Tal como se entrega no hace nada y termina con éxito.
#
# Comportamiento sugerido a implementar:
#   1. Elige un idioma de referencia (la fuente de verdad para el conjunto de claves).
#   2. Para cada otro idioma, compara su conjunto de claves con el de referencia.
#   3. Imprime las claves faltantes y huérfanas, luego termina con código distinto de cero si se encuentra alguna.
#
# Ejemplo (idiomas en JSON, requiere `jq`):
#   ref=locales/en.json
#   for f in locales/*.json; do
#     [ "$f" = "$ref" ] && continue
#     missing=$(comm -23 \
#       <(jq -r 'keys[]' "$ref" | sort) \
#       <(jq -r 'keys[]' "$f" | sort))
#     [ -n "$missing" ] && printf '%s missing:\n%s\n' "$f" "$missing"
#   done

echo "i18n-parity check.sh is a stub — adapt it to your i18n format."
exit 0
