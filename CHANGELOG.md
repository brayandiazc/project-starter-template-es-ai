# Changelog

Todos los cambios notables de este proyecto se documentan en este archivo.

El formato se basa en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/)
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [Unreleased]

### Added

- Catálogo de stacks predefinidos por tipo de proyecto en `docs/stacks/` (web
  fullstack, SPA+API, API, móvil, web estática, PWA, extensión de navegador,
  microservicios, CLI) con servicios transversales y capa de IA agnóstica (ADR 0002).
- Design system base en `design/`: paleta, tipografías, iconografía, stack de motion,
  tokens en CSS/JSON y `preview.html` navegable.
- Marco legal base bilingüe en `legal/` (términos, privacidad y cookies en es/en) con
  reglas de versionado/re-aceptación y placeholders de jurisdicción.
- Flujo de trabajo SDD guiado en `docs/conventions/workflow.md` con sprint de
  definición y ciclo por agentes (ADR 0003).
- Comando único de arranque `/arrancar-proyecto` (sprint → preset → instanciar →
  prototipo → primera spec), junto con las skills `/definir-producto`, `/prototipo` y
  `/configurar-repo`.
- Subagentes `product-coach`, `designer` y `metrics-analyst`.
- Guardrails activos por defecto en `.claude/settings.json`: `git-guardrails.sh`,
  `secret-guardrails.sh` y `spec-guardrails.sh` (specs obligatorias en ramas
  `feat/*`/`fix/*`, ADR 0004).
- Workflows `release.yml` y `template-update-check.yml` (aviso semanal de mejoras de
  la plantilla a los proyectos instanciados).
- `docs/product/product-definition.md` para acotar la v1, spec
  `specs/0001-flujo-arranque-y-guardrails/` y ADRs 0002–0004.
- Estructura inicial del proyecto.

### Changed

- `develop` pasa a ser la rama por defecto del repositorio; los PRs (incluido
  Dependabot) apuntan ahí y `main` solo recibe merges de release o `hotfix/*`.
- Documentación y plantilla sincronizadas con la fuente v0.2.0: `AGENTS.md`,
  `README.md`, `TEMPLATE-USAGE.md`, `CONTRIBUTING.md`, convenciones y specs
  actualizados al flujo con specs obligatorias y arranque único.

### Deprecated

### Removed

### Fixed

### Security

## [0.1.0] - [FECHA]

### Added

- Versión inicial.

<!--
Enlaces de comparación entre versiones (ajusta a tu repositorio):
[Unreleased]: [URL_REPOSITORIO]/compare/v0.1.0...HEAD
[0.1.0]: [URL_REPOSITORIO]/releases/tag/v0.1.0
-->
