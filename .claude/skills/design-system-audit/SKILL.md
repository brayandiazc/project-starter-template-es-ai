---
name: design-system-audit
description: Audita el código de UI frente al sistema de diseño del proyecto — tokens semánticos, componentes permitidos, estados de interacción requeridos y la línea base de accesibilidad. Úsalo cuando la persona pida auditar/revisar el cumplimiento del sistema de diseño, verificar que se usen tokens en lugar de valores crudos, o confirmar que un componente sigue las guías de diseño (p. ej. "¿este componente sigue nuestro sistema de diseño?", "audita la nueva tarjeta").
---

<!-- Skill de ejemplo de la plantilla — adáptalo o elimínalo según tu proyecto. -->

Audita la UI indicada (componente/página) frente al sistema de diseño.

1. Lee `docs/conventions/design-system.md` para conocer el sistema de tokens, la lista de componentes aprobados/oficiales, los estados requeridos y la línea base de accesibilidad.
2. Localiza los archivos fuente de la UI dentro del alcance.
3. Verifica frente a las convenciones:
   - Tokens — los colores, el espaciado, la tipografía y los radios usan tokens de diseño semánticos, NO valores crudos hex/px/mágicos.
   - Componentes — construidos a partir del conjunto de componentes aprobados en lugar de reimplementaciones puntuales.
   - Estados — se manejan los estados interactivos requeridos (default, hover, focus, active, disabled, loading, empty, error) según especifique el documento.
   - Línea base de accesibilidad — cumple el mínimo que exige el documento (contraste, visibilidad del foco, marcado semántico).
4. Informa una lista de verificación: cada ítem como Pasa / Falla, con archivo:línea y una corrección concreta que referencie el token o componente correcto.

Ejemplo de hallazgo: `Color crudo #2563eb en Button.tsx:14 — usa el token \`color-primary\` según design-system.md.`

NO rediseñes ni reestilices por iniciativa propia — informa los hallazgos y sugiere correcciones. Para revisiones de a11y más profundas, recurre al skill accessibility-audit. Da siempre prioridad a `docs/conventions/design-system.md`.
