# 0004. Guardrails obligatorios (opt-out) y arranque con un solo comando

- **Estado**: Aceptada
- **Fecha**: 2026-08-02
- **Decisores**: Brayan Diaz C

## Contexto y problema

La primera instanciación real de la plantilla (proyecto de prueba) mostró que las
reglas escritas no bastan: el agente creó ramas de trabajo desde `main` (sin crear
`develop`), implementó funcionalidades sin ninguna spec, y la existencia de dos
comandos de arranque (`/instanciar` y `/arrancar-proyecto`) generó confusión sobre
cuál usar. Los hooks de guardrails existían pero eran opt-in y nadie los activó.
Además, los proyectos instanciados no tenían forma de enterarse de que la plantilla
publicó mejoras.

## Opciones consideradas

- **Reforzar la prosa** (AGENTS.md más enfático) — ya estaba escrito y se saltó igual.
- **Guardrails opt-in mejor documentados** — la prueba demostró que lo opcional no se
  activa en la práctica.
- **Guardrails activos por defecto (opt-out) + un único comando de arranque** — la
  regla se cumple sin depender de disciplina; quien no la quiera la desactiva a
  conciencia y deja rastro.

## Decisión

1. Los tres hooks (`git-guardrails`, `secret-guardrails`, `spec-guardrails`) vienen
   **activos en `.claude/settings.json`**. Desactivarlos es una decisión explícita
   que se registra en el ADR de instanciación.
2. `git-guardrails` también bloquea **crear ramas de trabajo desde `main`** (solo
   `develop` y `hotfix/*` pueden nacer ahí) y los merges locales en ramas protegidas.
3. Las specs son **obligatorias** para `feat/*`/`fix/*`, con slug compartido rama ↔
   spec (`feat/x` ↔ `specs/NNNN-x/`), garantizado por `spec-guardrails`.
4. `/arrancar-proyecto` es el **único punto de entrada** del arranque, con el orden:
   `main → develop → docs/arranque → (PR a develop) → feat/<primera-spec>`.
   `/instanciar` queda como paso interno.
5. `template-update-check.yml` avisa semanalmente (issue) a los proyectos
   instanciados cuando la plantilla publica mejoras de tooling; `/actualizar-plantilla`
   las aplica.

## Consecuencias

- **Positivas**: el flujo pactado se cumple aunque el agente (o la persona) lo olvide;
  el arranque tiene una sola puerta; las instancias dejan de quedar huérfanas.
- **Negativas / costes**: los hooks requieren `python3`; un falso positivo puede
  frenar un caso legítimo (mitigado: fallan abiertos ante la duda y `docs/*`/`chore/*`
  quedan exentos de spec); mantener los hooks exige tests (cubiertos en
  `.github/scripts/tests/run-tests.sh`).

## Enlaces

- Spec del cambio: [`specs/0001-flujo-arranque-y-guardrails/`](../../specs/0001-flujo-arranque-y-guardrails/proposal.md)
- [`docs/conventions/workflow.md`](../conventions/workflow.md) · [`docs/conventions/ai-agents.md`](../conventions/ai-agents.md)
- Relacionada: [0003 — flujo de trabajo guiado](0003-flujo-de-trabajo-guiado.md)
