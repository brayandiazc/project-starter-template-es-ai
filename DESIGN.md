---
# GENERADO por .github/scripts/design-md.sh — no lo edites a mano.
# La fuente de verdad es design/tokens.css.
colors:
  light:
    base-100: 'oklch(100% 0 0)'
    base-200: 'oklch(98.4% 0.003 247.858)'
    base-300: 'oklch(96.8% 0.007 247.896)'
    base-content: 'oklch(20.8% 0.042 265.755)'
    primary: 'oklch(54.1% 0.102 258)'
    primary-content: 'oklch(100% 0 0)'
    secondary: 'oklch(44.6% 0.043 257.281)'
    secondary-content: 'oklch(100% 0 0)'
    accent: 'oklch(67.9% 0.213 70)'
    accent-content: 'oklch(20.8% 0.042 265.755)'
    neutral: 'oklch(37.2% 0.044 257.287)'
    neutral-content: 'oklch(100% 0 0)'
    info: 'oklch(62.3% 0.214 259.815)'
    info-content: 'oklch(100% 0 0)'
    success: 'oklch(69.6% 0.17 162.48)'
    success-content: 'oklch(100% 0 0)'
    warning: 'oklch(76.9% 0.188 70.08)'
    warning-content: 'oklch(20.8% 0.042 265.755)'
    error: 'oklch(64.5% 0.246 16.439)'
    error-content: 'oklch(100% 0 0)'
  dark:
    base-100: 'oklch(20.8% 0.042 265.755)'
    base-200: 'oklch(27.9% 0.041 260.031)'
    base-300: 'oklch(37.2% 0.044 257.287)'
    base-content: 'oklch(98.4% 0.003 247.858)'
    primary: 'oklch(72% 0.114 258)'
    primary-content: 'oklch(20.8% 0.042 265.755)'
    secondary: 'oklch(71.1% 0.035 256.788)'
    secondary-content: 'oklch(20.8% 0.042 265.755)'
    accent: 'oklch(72.7% 0.173 70)'
    accent-content: 'oklch(20.8% 0.042 265.755)'
    neutral: 'oklch(44.6% 0.043 257.281)'
    neutral-content: 'oklch(98.4% 0.003 247.858)'
    info: 'oklch(71.4% 0.143 254.624)'
    info-content: 'oklch(20.8% 0.042 265.755)'
    success: 'oklch(76.5% 0.177 163.223)'
    success-content: 'oklch(20.8% 0.042 265.755)'
    warning: 'oklch(82.8% 0.189 84.429)'
    warning-content: 'oklch(20.8% 0.042 265.755)'
    error: 'oklch(71.2% 0.194 13.428)'
    error-content: 'oklch(20.8% 0.042 265.755)'
typography:
  sans: '"Inter", ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif'
  display: '"Space Grotesk", "Inter", ui-sans-serif, system-ui, sans-serif'
  mono: '"JetBrains Mono", ui-monospace, monospace'
radius:
  field: '0.5rem'
  box: '0.75rem'
---

# Sistema de diseño

Los tokens de arriba son la paleta completa del producto, en OKLCH y en sus dos temas.
**Úsalos siempre por su nombre** (`var(--primary)`, o la utilidad equivalente de tu
framework): nunca escribas un hex ni una utilidad de paleta cruda en un componente.

Este archivo lo genera `.github/scripts/design-md.sh` desde `design/tokens.css`, que es
la fuente de verdad — el navegador lo lee en runtime y tu framework de UI lo consume
por el adaptador del final. Editarlo a mano no sirve de nada: el CI compara los dos y
falla.

## Dónde está el resto

- **Las reglas** —primitivas nativas antes que componentes propios, los cuatro estados
  de cada vista, accesibilidad AA en ambos temas— en [`docs/conventions/ui.md`](docs/conventions/ui.md).
- **Verlo aplicado**: abre [`design/preview.html`](design/preview.html) en el navegador.
  Enlaza `tokens.css` directamente y calcula el contraste en vivo, así que muestra los
  colores reales y no una descripción de ellos.
- **Elegir la paleta de un producto nuevo**: la skill `/identidad`.
