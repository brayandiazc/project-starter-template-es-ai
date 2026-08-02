# Propuesta — Flujo de arranque unificado y guardrails obligatorios

- **Estado**: Implementada
- **Fecha**: 2026-08-02
- **Autor**: Brayan Diaz C (con Claude Code)

## Problema

La primera prueba real de la plantilla reveló cuatro fallos de proceso:

1. **Dos comandos de arranque** (`/instanciar` y `/arrancar-proyecto`) con
   descripciones solapadas — confuso cuál usar.
2. **La regla de ramas se saltaba**: el agente creaba ramas de trabajo desde `main`
   (el hook de git era opt-in y no vigilaba la creación de ramas), y `develop` ni
   siquiera se creaba.
3. **Las specs se saltaban**: figuraban como "opcional" en la documentación y nada
   las exigía — el proyecto de prueba se implementó sin ninguna spec.
4. **Los proyectos instanciados no se enteran** cuando la plantilla publica mejoras.

## Objetivo

Que el arranque sea UN comando con el orden correcto de ramas, y que las reglas de
ramas y specs sean imposibles de saltar (bloqueadas por hooks, no prometidas).

## Alcance

**Dentro del alcance:**

- `/arrancar-proyecto` como único punto de entrada; `/instanciar` como paso interno.
- Flujo de ramas del arranque: `main → develop → docs/arranque → (PR) → feat/<spec>`.
- `git-guardrails.sh`: bloquear también merges locales en ramas protegidas y la
  creación de ramas de trabajo desde `main` (excepciones: `develop`, `hotfix/*`).
- Nuevo `spec-guardrails.sh`: sin `specs/NNNN-<slug>/` no se edita código en
  `feat/*`/`fix/*`.
- Hooks activos por defecto en `.claude/settings.json`.
- Workflow `template-update-check.yml`: aviso semanal (issue) de mejoras de la plantilla.
- Recomendaciones documentadas: plugin Impeccable (+ UI/UX Pro Max opcional) y MCPs
  de infraestructura (Cloudflare plugin, Hetzner comunitario, SSH/Kamal vía Bash).

**Fuera del alcance:**

- Vendorizar las skills de diseño externas en la plantilla (se instalan como plugin).
- Un MCP propio para Hetzner.
- Migrar automáticamente proyectos ya instanciados (usan `/actualizar-plantilla`).

## Impacto

- **Usuarios**: arranque más simple (un comando) y reglas que ya no dependen de la
  disciplina del agente.
- **Sistema**: `.claude/hooks/`, `.claude/settings.json`, skills de arranque,
  `.github/workflows/`, convenciones (`workflow.md`, `ai-agents.md`,
  `CONTRIBUTING.md`, `specs/README.md`, `AGENTS.md`), `design/README.md`.
- **Riesgos**: falsos positivos de los hooks → los tres fallan abiertos ante la duda
  y sus casos están cubiertos en `.github/scripts/tests/run-tests.sh`.
