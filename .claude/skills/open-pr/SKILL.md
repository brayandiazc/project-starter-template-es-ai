---
name: open-pr
description: Redacta un pull request para la rama actual rellenando la plantilla de PR del repositorio en función de los cambios de la rama. Úsalo cuando la persona pida abrir/crear un PR, preparar un pull request o escribir la descripción de un PR (p. ej. "abre un PR", "redacta el pull request de esta rama"). No hace merge.
---

<!-- Skill de ejemplo de la plantilla — adáptalo o elimínalo según tu proyecto. -->

Prepara un pull request para la rama actual.

1. Lee `.github/PULL_REQUEST_TEMPLATE.md` para conocer las secciones requeridas y la lista de verificación.
2. Reúne contexto sobre los cambios de la rama:
   - `git log <base>..HEAD --oneline` para la lista de commits (la base suele ser `main`).
   - `git diff <base>...HEAD --stat` y revisa los diffs relevantes.
3. Rellena cada sección de la plantilla usando ese contexto:
   - Resumen de qué cambió y por qué.
   - Issues vinculados / ADRs o especificaciones relacionados si se mencionan.
   - Notas de pruebas (qué ejecutaste o qué debería revisar quien haga la revisión).
   - Marca los ítems de la lista de verificación que realmente apliquen; deja el resto para la persona autora.
4. Crea el PR con la CLI `gh` (p. ej. `gh pr create --title ... --body ...`) si la rama está pusheada; de lo contrario, muestra la plantilla rellenada para que la persona la pegue.
5. Informa la URL del PR o el cuerpo redactado.

NO hagas merge, NO apruebes, y NO marques ítems de la lista de verificación que no estén realmente hechos. Escribe un PR en borrador si el trabajo está incompleto.
