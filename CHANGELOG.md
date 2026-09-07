# Changelog

Todos los cambios notables de este proyecto se documentan en este archivo.

El formato se basa en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/)
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [Unreleased]

### Added

- **Sprint de definición de producto.** `docs/product/` pasa de un lienzo de negocio a
  tres documentos que se usan en orden: `interview.md` (las preguntas),
  `product-definition.md` (el corte de la v1, MoSCoW, fuera de alcance y negocio) y
  `discovery.md` (con qué evidencia se decidió y qué se descartó). Con ellos llegan los
  subagentes `product-coach`, `product-researcher`, `metrics-analyst` y `designer`, y
  las skills `/definir-producto`, `/identidad`, `/prototipo` y `/configurar-repo`.
- **`design/` — identidad visual con tokens semánticos**, más `DESIGN.md` en la raíz
  (generado desde `design/tokens.css`, nunca a mano) para que cualquier agente de IA lea
  el sistema de diseño. **Es agnóstico del framework a propósito**: los tokens son
  custom properties de CSS estándar y el enganche a una librería concreta vive en un
  solo bloque marcado como adaptador, que se reemplaza. El diseño se puede montar como
  quieras.
- **`docs/marco-tecnico.md` y sus tres extensiones** (infraestructura, IA, móvil): el
  sitio donde se escriben **una sola vez** las decisiones de tecnología que no se
  vuelven a discutir por proyecto. Vienen **vacías, con la estructura y el criterio**:
  una plantilla no puede elegirte el stack ni los proveedores.
- **`spec-guardrails.sh`**: sin spec en `specs/` —o con un `proposal.md` a medio
  rellenar— no se puede editar código en `feat/*` ni `fix/*`. Con él, `specs/` deja de
  ser una recomendación.
- **Ocho checks nuevos**, porque una regla que solo se cumple leyendo no se cumple:
  `check-changelog`, `check-costs`, `check-design-tokens`, `check-inheritance`,
  `check-hooks-enabled`, `check-instructions`, `check-project-tests`, `check-release`,
  más `design-md.sh`. El banco de pruebas pasa de cero a 290 casos.
- **`.githooks/pre-commit` y `pre-push`**: los mismos checks del CI, antes de subir.
  En local son gratis; en Actions, minutos.
- **`docs/conventions/workflow.md`** — el ciclo completo, de la idea al release — y
  **`docs/architecture/pantallas.md`**, el mapa de pantallas del producto.
- **`RENOMBRADOS.md`**: qué documento cambió de nombre y qué hacer con tu contenido. Al
  adoptar una versión nueva sobre un proyecto que ya tenía otra, los renombrados no se
  sustituyen: **se duplican**, y ningún check lo detecta.

### Changed

- **`architecture/` responde qué construye el proyecto; `conventions/`, cómo se
  trabaja.** Los pares que se rellenaban y podaban siempre juntos se fusionaron:
  `design-system.md` + `branding.md` + `views-and-layouts.md` → `conventions/ui.md`, y
  `conventions/authentication.md` → `architecture/auth.md`. El mapa completo está en
  `RENOMBRADOS.md`.
- **`AGENTS.md` es el índice único de la documentación.** `docs/README.md` era una
  segunda copia del mismo mapa, y las dos divergían.
- **Los scripts se nombran en inglés, como el resto del código**: `check-costos` →
  `check-costs`, `check-herencia` → `check-inheritance`, `check-hooks-activos` →
  `check-hooks-enabled`, `check-instrucciones` → `check-instructions`.
- **Cada subagente declara su modelo**, y la plantilla los deja todos en `inherit`: el
  reparto depende de tu plan, no de esta plantilla. El criterio para subir o bajar
  —«¿el error se detecta solo?»— está en `conventions/ai-agents.md`.
- **Las variables de servicios de `.env.example` van por categoría, no por proveedor**
  (`PAYMENTS_API_KEY`, `STORAGE_*`, `ERROR_TRACKING_DSN`…), y `scripts/backup-db.sh`
  habla S3 genérico en vez de un proveedor concreto.

### Removed

- Los subagentes `explorer` y `code-reviewer` y la skill `/refactor`: **duplicaban
  funcionalidad que Claude Code trae de fábrica** (`Explore`, `/code-review`,
  `/simplify`), en versiones más pobres.
- `docs/glossary.md` (huérfano: nada lo referenciaba) y `.github/labeler.yml`
  (82 líneas de configuración para un workflow de auto-etiquetado que nunca existió —
  ningún workflow la leía).
- `.github/FUNDING.yml`, `.github/CODEOWNERS.example` y las plantillas de issue
  `support_question` y `documentation_request`. Quedan bug, funcionalidad y tarea.

### Fixed

- **Dos pasos de `quality.yml` no llevaban `!cancelled()`** y ocultaban a los
  siguientes cuando fallaban: el propósito del job de un solo trabajo es ver todos los
  problemas de una vez.
- **`check-design-tokens.sh` solo sabía leer un framework.** Ahora detecta la
  **notación** —utilidad con guiones, variable de preprocesador, custom property— en vez
  de una librería, así que un proyecto que no usa la de la plantilla deja de pasar en
  verde sin que se mire una sola de sus infracciones. Y no se traga los tokens del
  propio sistema: `--neutral` es un rol, no un color.
- **`check-costs.sh` exigía una fecha de verificación en la plantilla**, donde el
  documento aún es el esqueleto y no hay precio alguno que caduque.

## [0.1.0] - [FECHA]

### Added

- Versión inicial.

<!--
Enlaces de comparación entre versiones (ajusta a tu repositorio):
[Unreleased]: [URL_REPOSITORIO]/compare/v0.1.0...HEAD
[0.1.0]: [URL_REPOSITORIO]/releases/tag/v0.1.0
-->
