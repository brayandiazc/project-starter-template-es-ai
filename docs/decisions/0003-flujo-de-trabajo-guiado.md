# 0003. Flujo de trabajo guiado: SDD + agentes + acompañamiento de producto

- **Estado**: Aceptada
- **Fecha**: 2026-08-01
- **Decisores**: Brayan Diaz C

## Contexto y problema

El autor desarrolla solo, con IA como par de trabajo. El catálogo de stacks (ADR 0002)
resuelve el "con qué", pero faltaba el "cómo": quién pregunta y aterriza el producto
desde el minuto uno, cómo se conectan definición → especificación → implementación →
revisión, y qué regla decide prioridades cuando todo parece importante. También
faltaban piezas operativas: qué stack usar para herramientas no-web (CLIs, generadores
de archivos) y cómo manejar credenciales de forma uniforme.

## Opciones consideradas

- **Solo prosa en AGENTS.md** — barata, pero sin agente dedicado el acompañamiento de
  producto se diluye en la sesión principal.
- **Un framework SDD externo completo** (OpenSpec u otro) — más estructura, pero más
  fricción que la que un equipo de una persona amortiza hoy; `specs/` ligero ya existe.
- **Capa propia: convención de flujo + agente de producto (elegida)** — formaliza el
  ciclo con las piezas que ya existen (specs, reviewers, hooks) y añade la que faltaba.

## Decisión

- **`docs/conventions/workflow.md`** define el ciclo: definir (product-coach) → elegir
  stack (catálogo) → especificar (specs/architect) → implementar → revisar
  (code-reviewer + security-reviewer) → documentar (doc-keeper) → medir. Incluye las
  reglas críticas: la definición de producto manda sobre el backlog, preguntar antes
  de asumir, sin spec no hay cambio grande, sin revisión no hay merge.
- **Sprint de definición (Design Sprint exprés)**: la fase DEFINIR se corre como
  sprint comprimido (entender → mapear vistas → decidir modelo/integraciones →
  prototipar en estático → validar), con catálogo estándar de vistas y regla
  "estático antes que funcional".
- **Subagentes nuevos**: `product-coach` (guía de producto que entrevista, acota y
  filtra el alcance), `designer` (prototipa y revisa consistencia con el design
  system) y `metrics-analyst` (eventos del recorrido crítico y revisión de datos por
  versión).
- **Skills nuevas**: `/arrancar-proyecto` (encadena el arranque completo),
  `/definir-producto`, `/prototipo` y `/configurar-repo` (la IA administra el
  repositorio: descripción, labels, ramas, protección).
- **Reglas estrictas**: "nada sin documentar" (CHANGELOG + docs + legal en el mismo
  PR) y "la definición de producto manda sobre el backlog".
- **Marco legal base** en `legal/` (términos/privacidad/cookies, es/en, derivado de
  Phareto) con versionado y re-aceptación; las specs que tocan datos/pagos/terceros
  lo actualizan.
- **Preset `docs/stacks/cli-herramientas.md`** (Python + Typer + uv) para herramientas
  internas y generadores de archivos, con su versión ligera de operación.
- **Credenciales con Bitwarden** como lugar canónico (local: `bw`/`.env` generado;
  CI: GitHub Secrets/`bws`; producción: Kamal secrets ← `bws`), y dominios con
  Namecheap (compra) + Cloudflare (DNS).
- **Identidad visual** anclada al design system real de Phareto (Tailwind v4 +
  DaisyUI v5) en vez de una paleta inventada.

## Consecuencias

**Positivas:**

- Hay acompañamiento explícito de producto: alguien pregunta, acota y prioriza.
- El ciclo con puertas (spec, revisión) da robustez sin burocracia pesada.
- CLIs y herramientas internas dejan de ser un hueco del catálogo.

**Negativas / costos:**

- Más piezas que mantener sincronizadas (workflow ↔ agentes ↔ skills).
- El flujo añade fricción mínima a cambios triviales; la válvula es el criterio de
  "no trivial" de la spec.

**Neutras / a vigilar:**

- Si el flujo se salta sistemáticamente en la práctica, simplificarlo antes que
  ignorarlo.
- Evaluar más adelante patrones avanzados de orquestación de agentes (harnesses,
  loops con verificación multi-agente) cuando los proyectos reales los ameriten.

## Referencias

- [ADR 0002](0002-catalogo-de-stacks-y-defaults.md)
- [`docs/conventions/workflow.md`](../conventions/workflow.md)
- [`.claude/agents/product-coach.md`](../../.claude/agents/product-coach.md)
