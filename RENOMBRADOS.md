# Renombrados y fusiones

Qué documentos de esta plantilla cambiaron de nombre o se fusionaron, y qué hacer con el
contenido si tu proyecto tiene la versión antigua.

**Por qué existe.** Al adoptar una versión nueva sobre un proyecto que ya tenía otra, los
documentos renombrados **no se sustituyen: se duplican**. Quedan los dos —el tuyo con
contenido y el nuevo vacío—, ningún check lo detecta (los dos existen, los dos son
markdown válido, los enlaces resuelven) y el proyecto acaba con dos documentos que dicen
cosas distintas sobre lo mismo. Probado contra un proyecto real: cinco pares duplicados.

**Cómo se mantiene.** Una fila **en el mismo PR que renombra o fusiona**. Si se deja para
después, la información se pierde en el CHANGELOG y esta tabla se vuelve mentira.

| Antes                                   | Ahora                                  | Qué hacer con tu contenido                                                                                                                                                                           |
| --------------------------------------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `docs/architecture/design.md`           | `docs/architecture/pantallas.md`       | Migrar el mapa de pantallas y borrar el viejo. El nombre `design.md` queda reservado para el diseño **técnico** de cada spec (`specs/*/design.md`), que es la convención de las herramientas de IA   |
| `docs/conventions/design-system.md`     | `docs/conventions/ui.md`               | Fusionar en `ui.md`, que reúne design system, marca y layouts                                                                                                                                        |
| `docs/conventions/branding.md`          | `docs/conventions/ui.md`               | Ídem                                                                                                                                                                                                 |
| `docs/conventions/views-and-layouts.md` | `docs/conventions/ui.md`               | Ídem                                                                                                                                                                                                 |
| `docs/conventions/authentication.md`    | `docs/architecture/auth.md`            | Fusionado: mover las reglas transversales a la sección «Reglas» de `auth.md` y borrar el viejo. El par siempre se rellenaba y se podaba junto — eran la misma tabla en dos archivos                  |
| `docs/README.md`                        | `AGENTS.md`                            | Era una segunda copia del mapa de documentación. El índice canónico es `AGENTS.md`, que es el archivo que de verdad se lee en cada sesión                                                            |
| `docs/glossary.md`                      | —                                      | Eliminado (huérfano: nada lo referenciaba). Si el tuyo tiene contenido, muévelo a una sección de vocabulario en `docs/product/business-model.md`                                                     |
| `.claude/skills/refactor/`              | —                                      | Eliminada: duplicaba el builtin `/simplify` de Claude Code sin aportar nada del proyecto. Si tu copia tiene reglas propias, muévelas a `docs/conventions/` y borra la skill                          |
| `.claude/agents/explorer.md`            | —                                      | Eliminado: duplicaba el agente `Explore` de fábrica, en versión más pobre                                                                                                                            |
| `.claude/agents/code-reviewer.md`       | —                                      | Eliminado: duplicaba la skill `/code-review` de fábrica, que además admite niveles de esfuerzo, `--fix`, `--comment` y sabe revisar un PR                                                            |
| `.github/labeler.yml`                   | —                                      | Eliminado: configuración huérfana de 82 líneas para un workflow de auto-etiquetado que nunca existió en el repositorio. Ningún workflow la leía                                                      |
| `.github/scripts/check-herencia.sh`     | `.github/scripts/check-inheritance.sh` | Renombrado, junto con `check-hooks-activos`→`check-hooks-enabled` y `check-instrucciones`→`check-instructions`. El código va en inglés, también sus archivos                                         |
| `RENOMBRADOS.md` (en instancias)        | —                                      | Este archivo es del repo-plantilla: `/instanciar` lo borra al podar y `check-inheritance.sh` lo marca como sobrante. `/actualizar-plantilla` lo lee por URL del origen, así que tu copia local sobra |

## Lo que no está aquí

Los documentos que solo cambiaron de contenido no se listan: para eso está el
`CHANGELOG.md`. Esta tabla es únicamente para **cambios de ruta**, que son los que dejan
duplicados silenciosos.
