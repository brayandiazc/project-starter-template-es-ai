---
name: release
description: Corta una nueva versión — mueve la sección Unreleased del CHANGELOG a una versión SemVer con fecha, crea el commit y el tag, y opcionalmente el release de GitHub. Úsalo cuando la persona pida publicar/cortar una versión o preparar un release (p. ej. "corta la versión 1.2.0", "prepara el release", "publica una nueva versión"). No hace push sin confirmación.
---

<!-- Skill de ejemplo de la plantilla — adáptalo o elimínalo según tu proyecto. -->

Corta una versión siguiendo Keep a Changelog y Semantic Versioning (ver `CHANGELOG.md`
y `CONTRIBUTING.md`).

## Pasos

1. **Precondiciones.** Verifica que el árbol esté limpio (`git status`) y que estés en la
   rama correcta según `CONTRIBUTING.md` (con Git Flow, el release sale de `develop` hacia
   `main`; sin `develop`, desde `main`). Si hay cambios sin commit, detente y avisa.
2. **Leer lo pendiente.** Toma las entradas de la sección `## [Unreleased]` de
   `CHANGELOG.md`. Si está vacía, no hay nada que publicar: dilo y detente.
3. **Proponer la versión.** Lee la última versión publicada (tag `v*` o CHANGELOG) y
   propone el bump SemVer según el contenido: cambios incompatibles → **major**; solo
   `Added`/`Changed` → **minor**; solo `Fixed`/`Security` → **patch**. Deja que la
   persona confirme o corrija con AskUserQuestion.
4. **Actualizar el CHANGELOG.** Mueve las entradas de `Unreleased` a una nueva sección
   `## [X.Y.Z] - YYYY-MM-DD` (fecha de hoy), deja `Unreleased` con sus categorías vacías
   y actualiza los enlaces de comparación del pie del archivo.
5. **Commit y tag.** Crea el commit `chore(release): vX.Y.Z` (con la coautoría de IA de
   `docs/conventions/ai-agents.md`) y el tag anotado `vX.Y.Z` apuntándole.
6. **Release de GitHub (opcional).** Ofrece publicar con
   `gh release create vX.Y.Z --title "vX.Y.Z" --notes "<sección del CHANGELOG>"`.

Ejemplo: "corta la versión" → propone `v1.3.0` → CHANGELOG actualizado + commit + tag.

NO hagas push del commit, del tag ni publiques el release sin confirmación explícita, NO
inventes entradas de changelog que no estén en `Unreleased`, y NO saltes una versión SemVer.
