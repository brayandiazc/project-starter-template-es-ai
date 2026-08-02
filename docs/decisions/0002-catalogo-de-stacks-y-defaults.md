# 0002. Catálogo de stacks predefinidos y defaults de producto/diseño

- **Estado**: Aceptada
- **Fecha**: 2026-07-30
- **Decisores**: Brayan Diaz C

## Contexto y problema

La plantilla ofrecía formularios en blanco (`stack.md`, Lean Canvas, design-system)
que se rellenaban desde cero en cada proyecto. Cada arranque repetía las mismas
decisiones (framework, base de datos, pagos, emails, hosting, paleta, tipografías),
gastando tiempo que debería ir al producto. El objetivo del autor es lanzar productos
rápido, con IA como parte del desarrollo y con proveedores de IA intercambiables.

## Opciones consideradas

- **Seguir con formularios en blanco** — máxima flexibilidad, pero re-decidir todo en
  cada proyecto es lento y produce inconsistencia.
- **Convertir la plantilla en un boilerplate de código por stack** — arranque aún más
  rápido, pero rompe la naturaleza multiplataforma de la plantilla y multiplica el
  mantenimiento (un repo por stack).
- **Catálogo de presets + defaults transversales (elegida)** — decisiones pre-tomadas
  y documentadas que la instanciación aplica en minutos, manteniendo la plantilla
  agnóstica: los formularios siguen existiendo y el catálogo trae las respuestas.

## Decisión

Se añade un catálogo de decisiones pre-tomadas, sin convertir la plantilla en boilerplate:

- **`docs/stacks/`** — un preset por tipo de proyecto (web-fullstack, spa-api,
  api-service, mobile, web-estatica, pwa, extension-navegador, microservicios), con
  Rails como columna vertebral y servicios transversales fijos: PostgreSQL, Paddle,
  Resend, Cloudflare (DNS/R2/Pages), Sentry, PostHog, Better Stack, GitHub Actions,
  y hosting en escalera PaaS → Hetzner. La IA en los productos pasa por una capa
  adaptadora (RubyLLM / LiteLLM / Vercel AI SDK) para poder cambiar de proveedor.
- **`design/`** — identidad visual por defecto derivada del design system de Phareto
  (Tailwind v4 + DaisyUI v5, paleta slate con acento cobre, Inter, iconos Lucide,
  guías de motion) como tokens en CSS y JSON.
- **`docs/product/product-definition.md`** + skill `/definir-producto` — documento que
  acota la v1 (dentro/fuera, MoSCoW, puertas de crecimiento).
- `/instanciar` ofrece los presets en su entrevista (Lote C).

## Consecuencias

**Positivas:**

- Arrancar un proyecto pasa de re-decidir todo a elegir un preset y anotar desviaciones.
- Consistencia entre proyectos (misma identidad visual, mismos proveedores, misma
  forma de acotar producto).

**Negativas / costos:**

- El catálogo hay que mantenerlo vivo: cambios de proveedor o de preferencia requieren
  actualizar presets y registrar ADRs.
- Los defaults reflejan las preferencias del autor; otros usuarios de la plantilla
  deberán adaptarlos.

**Neutras / a vigilar:**

- Si un preset se desvía repetidamente en proyectos reales, es señal de que el default
  debe cambiar.
- El cambio debe portarse a las variantes hermanas de la plantilla (es/en × IA/sin-IA).

## Referencias

- [`docs/stacks/README.md`](../stacks/README.md)
- [`design/README.md`](../../design/README.md)
- [`docs/product/product-definition.md`](../product/product-definition.md)
