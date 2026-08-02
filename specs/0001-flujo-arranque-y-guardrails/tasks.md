# Tareas — Flujo de arranque unificado y guardrails obligatorios

Lista de tareas de implementación. Manténla ordenada; marca los elementos a medida que avanzas.

## Implementación

- [x] Reescribir `/arrancar-proyecto` como comando único (con Paso 0 de ramas) y
      degradar `/instanciar` a paso interno.
- [x] Extender `git-guardrails.sh`: merges locales en protegidas + creación de ramas
      desde `main` (excepciones: `develop`, `hotfix/*`).
- [x] Crear `spec-guardrails.sh` (specs obligatorias en `feat/*`/`fix/*`).
- [x] Activar los tres hooks por defecto en `.claude/settings.json`.
- [x] Crear `.github/workflows/template-update-check.yml`.
- [x] Documentar Impeccable / UI/UX Pro Max en `design/README.md` y conectarlos a
      `designer`, `/prototipo` y `/arrancar-proyecto`.
- [x] Documentar MCPs de infraestructura en `docs/conventions/ai-agents.md`.

## Pruebas

- [x] Casos nuevos en `.github/scripts/tests/run-tests.sh` (creación de ramas, merge,
      spec-guardrails) — 42/42 en verde.

## Documentación

- [x] Actualizar `workflow.md`, `ai-agents.md`, `CONTRIBUTING.md`, `specs/README.md`,
      `AGENTS.md`, `TEMPLATE-USAGE.md`, `README.md` y `CHANGELOG.md`.
- [x] Registrar la decisión como ADR (`docs/decisions/`).

## Revisión y despliegue

- [ ] Autorrevisión / `code-reviewer`
- [ ] Abrir PR usando la plantilla de PR
