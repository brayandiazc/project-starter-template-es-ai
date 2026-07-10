---
name: actualizar-plantilla
description: Trae a este proyecto las mejoras que la plantilla de origen recibió después de la instanciación — lee .template-origin, calcula el diff del tooling (skills, hooks, scripts, workflows) contra la plantilla actual y propone aplicarlo. Úsalo cuando la persona quiera actualizar/sincronizar el proyecto con la plantilla (p. ej. "actualiza la plantilla", "trae las mejoras nuevas del template").
---

<!-- Skill de ejemplo de la plantilla — adáptalo o elimínalo según tu proyecto. -->

Sincroniza el **tooling** de este proyecto con la versión actual de su plantilla de
origen. Solo toca la capa reutilizable — nunca la documentación ya rellenada ni el código.

## Paso 1 — Leer el origen

Lee `.template-origin` en la raíz (lo escribe `/instanciar`):

```
repo=https://github.com/brayandiazc/project-starter-template-es-ai
commit=<sha-de-la-plantilla-al-instanciar>
fecha=YYYY-MM-DD
```

Si no existe, pregunta de qué plantilla/variante vino el proyecto y desde qué fecha
aproximada, y usa el tag/commit de esa época como base.

## Paso 2 — Calcular el diff del tooling

Clona la plantilla a un directorio temporal y calcula qué cambió desde el commit de
origen, **limitado a las rutas de tooling**:

```bash
git clone --quiet <repo> /tmp/tpl-update && cd /tmp/tpl-update
git diff --stat <commit-origen>..HEAD -- \
  .claude/ .github/scripts/ .github/workflows/ specs/_template/ \
  docs/conventions/_template.md
```

Excluye siempre: `README.md`, `docs/` rellenados, `CHANGELOG.md`, `LICENSE` y cualquier
archivo que el proyecto haya adaptado (compara antes de pisar; si el archivo local
difiere de la versión vieja de la plantilla, es una adaptación local — muéstrala y
pregunta).

## Paso 3 — Proponer y aplicar

Presenta un resumen por archivo (nuevo / actualizado / eliminado en la plantilla) y deja
elegir qué aplicar. Trabaja en una rama `chore/update-template`. Aplica lo aceptado,
ejecuta la suite `bash .github/scripts/tests/run-tests.sh` si existe, y actualiza
`.template-origin` con el nuevo commit y la fecha de hoy.

## Paso 4 — Cierre

Muestra el diff final y recuerda abrir un PR. NO hagas commit ni push sin confirmación.

Ejemplo: `/actualizar-plantilla` → "la plantilla tiene 3 mejoras de tooling desde tu
instanciación (hook nuevo, script de enlaces, workflow de calidad); ¿aplico las 3?"

NO pises adaptaciones locales sin preguntar, NO toques documentación ya rellenada ni
código de producción, y NO apliques cambios de la plantilla que el proyecto decidió
eliminar (p. ej. convenciones borradas a propósito).
