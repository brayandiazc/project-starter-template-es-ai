# Identidad visual por defecto

> Sistema de diseño que **todo proyecto nuevo hereda el día cero**, derivado del tema
> de Phareto (el proyecto de referencia). Un proyecto puede desviarse, pero la
> desviación se decide a propósito y se documenta en
> `docs/conventions/design-system.md`, no por accidente.

Los tokens viven en dos formatos equivalentes, más una muestra visual:

- [`tokens.css`](tokens.css) — tema DaisyUI/variables CSS listos para importar.
- [`tokens.json`](tokens.json) — para consumir desde JS o Flutter (ThemeData).
- [`preview.html`](preview.html) — muestra navegable de los componentes más usados con
  el tema aplicado; ábrelo en el navegador para ver/validar cualquier cambio de tokens.

> Criterio de selección de todo lo que sigue: **solo open source** (MIT/OFL/ISC/BSD) —
> nada con licencia restrictiva o de pago en el camino crítico del stack.

## Framework de UI (web)

| Pieza          | Elección                           | Por qué                                                            |
| -------------- | ---------------------------------- | ------------------------------------------------------------------ |
| CSS            | Tailwind CSS v4 (config CSS-first) | Sin `tailwind.config.js`; el tema vive en un bloque CSS            |
| Componentes    | DaisyUI v5, tema propio único      | Componentes semánticos (`btn-primary`, `card`) atados a los tokens |
| Interactividad | Stimulus (Rails) / React (SPA)     | Según preset de stack                                              |

**Regla de oro**: tokens semánticos de DaisyUI (`primary`, `base-100`, `base-content`),
**nunca** colores crudos de Tailwind (`bg-blue-500`) ni hex inline. No mezclar DaisyUI
con otra librería de UI; si en un contexto React necesitas un primitive complejo que
DaisyUI no trae (combobox, date-picker), usa el equivalente de shadcn/ui tematizado con
estos mismos tokens y documéntalo como excepción.

## Paleta (tema `base`, derivado de Phareto)

Valores en OKLCH (los que entienden Tailwind v4 y DaisyUI); hex aproximado como referencia.

| Token semántico | Light                        | ≈ Hex     | Uso                                    |
| --------------- | ---------------------------- | --------- | -------------------------------------- |
| `base-100`      | `oklch(100% 0 0)`            | `#FFFFFF` | Fondo principal / superficie           |
| `base-200`      | `oklch(98.4% 0.003 247.858)` | `#F8FAFC` | Fondo alternativo (slate-50)           |
| `base-300`      | `oklch(96.8% 0.007 247.896)` | `#F1F5F9` | Bordes, fondos sutiles (slate-100)     |
| `base-content`  | `oklch(20.8% 0.042 265.755)` | `#0F172A` | Texto principal (slate-900)            |
| `primary`       | `oklch(20.8% 0.042 265.755)` | `#0F172A` | CTA principal, branding (slate oscuro) |
| `secondary`     | `oklch(44.6% 0.043 257.281)` | `#475569` | Acciones secundarias (slate-600)       |
| `accent`        | `oklch(70% 0.18 50)`         | `#E27614` | Destacados, badges, premium (cobre)    |
| `neutral`       | `oklch(37.2% 0.044 257.287)` | `#334155` | Neutrales fuertes (slate-700)          |
| `info`          | `oklch(62.3% 0.214 259.815)` | `#3B82F6` | Mensajes informativos                  |
| `success`       | `oklch(69.6% 0.17 162.48)`   | `#10B981` | Confirmaciones                         |
| `warning`       | `oklch(76.9% 0.188 70.08)`   | `#FBBF24` | Advertencias                           |
| `error`         | `oklch(64.5% 0.246 16.439)`  | `#F43F5E` | Errores, destructivo                   |

- **Modo claro y oscuro desde el día 1**: `tokens.css` trae ambos temas (`base` +
  `base-dark`); el oscuro responde a `prefers-color-scheme` y a un toggle con
  `data-theme`. Toda vista se revisa en los dos modos antes de darse por hecha.
- **Multiidioma por defecto (es + en neutro)**: nada de cadenas hardcodeadas en
  vistas — todo texto visible pasa por i18n (`docs/conventions/i18n.md`); la skill
  `/i18n-parity` verifica la paridad.
- Texto secundario: `base-content` con opacidad (`text-base-content/70`), no un gris nuevo.
- Contraste mínimo WCAG AA (4.5:1 texto normal, 3:1 texto grande) — en ambos temas.

## Tipografía

| Rol                 | Familia              | Licencia | Fallback                 | Nota                                        |
| ------------------- | -------------------- | -------- | ------------------------ | ------------------------------------------- |
| Titulares / display | **Space Grotesk**    | OFL      | ui-sans-serif, system-ui | Da identidad sin ser exótica; pesos 500–700 |
| UI y cuerpo         | **Inter** (variable) | OFL      | ui-sans-serif, system-ui | Máxima legibilidad en tamaños pequeños      |
| Código              | **JetBrains Mono**   | OFL      | ui-monospace, monospace  | Snippets, `kbd`, datos                      |

- Por qué dos familias: Inter sola es segura pero genérica (es el default de medio
  internet); Space Grotesk en titulares aporta carácter manteniendo la misma base
  geométrica. Si un producto quiere máxima sobriedad, puede quedarse solo con Inter —
  el token `--font-display` cae a `--font-sans`.
- Escala: la de Tailwind (`text-xs/sm/base/lg/xl/2xl/3xl/4xl`); pesos 400/500/600/700.
- Carga self-hosted vía [Fontsource](https://fontsource.org) (variable fonts) — sin
  Google Fonts en runtime de producción.

## Iconografía

- **Set único: [Lucide](https://lucide.dev)** (licencia ISC) — trazo 2px, tamaño base
  20/24px. Elegido por cobertura multiplataforma con paquetes oficiales/mantenidos:
  `lucide-react`, `lucide-static` (Rails/Astro), `lucide-react-native`,
  `lucide_icons` (Flutter) — el mismo icono se ve igual en web y móvil.
- **Alternativa documentada: [Phosphor](https://phosphoricons.com)** (MIT) — úsalo solo
  si el producto necesita variantes de peso (thin/regular/bold/fill/duotone) como parte
  del lenguaje visual; también cubre web, RN y Flutter.
- No mezclar sets en un producto. Emojis solo en contenido, nunca como iconos de UI.

## Geometría

- Radios (convención DaisyUI): `0.5rem` en campos y botones, `0.75rem` en cards/modales.
- Bordes de 1px con `base-300`; profundidad plana (sin sombras fuertes) — la elevación
  se comunica con borde + fondo, como en Phareto.
- Espaciado: escala de Tailwind (`gap-2`, `p-4`, …).

## Motion (animación y efectos)

Stack cerrado, todo open source. Regla general: **un solo motor por vista** (dos motores
duplican bundle y pelean por el `requestAnimationFrame`).

| Necesidad                                | Elección                                                                         | Licencia | Nota                                                       |
| ---------------------------------------- | -------------------------------------------------------------------------------- | -------- | ---------------------------------------------------------- |
| Hover, focus, estados                    | CSS `transition` (tokens `--motion-*`)                                           | —        | El 80% de la UI no necesita JS                             |
| UI de app (modales, listas, layout)      | **[Motion](https://motion.dev)**                                                 | MIT      | React, JS vanilla y Vue; springs, gestos, layout           |
| Transiciones entre páginas               | **View Transitions API** (nativa)                                                | —        | Astro la trae integrada; evalúala antes que una librería   |
| Scroll en landings (reveals, secuencias) | Utilidades de scroll de Motion + **[Lenis](https://lenis.darkroom.engineering)** | MIT      | Lenis solo en marketing, nunca en apps                     |
| Animación que viene de diseño            | **Lottie** (lottie-web/dotLottie) o **Rive** (runtimes)                          | MIT      | Rive cuando debe reaccionar a input (state machines)       |
| 3D (visores, heroes)                     | **Three.js + React Three Fiber**                                                 | MIT      | Import dinámico (`ssr: false`); solo si el 3D se justifica |
| Componentes animados listos (landings)   | **Magic UI** / **Motion Primitives**                                             | MIT      | Sobre Motion; para no reinventar micro-interacciones       |

- **GSAP queda fuera del default**: hoy es gratuito y excelente, pero es propiedad de
  Webflow y su licencia (no open source) prohíbe usarlo en productos que compitan con
  Webflow. Solo con ADR y revisando esa cláusula.
- Duraciones: 150ms micro-interacciones, 200–300ms entradas/salidas; `ease-out` al
  entrar, `ease-in` al salir. Entradas: fade + translate-y de 8px. Sin rebotes ni
  parallax por defecto.
- Loading: `skeleton` (preferido) o `loading-spinner` de DaisyUI — nunca texto "Cargando…".
- **Siempre** respeta `prefers-reduced-motion: reduce` (Motion lo trae con
  `useReducedMotion`; el CSS de `tokens.css` ya desactiva lo decorativo).

### Motion en móvil

| Plataforma   | Stack                                                                                                      |
| ------------ | ---------------------------------------------------------------------------------------------------------- |
| Flutter      | Animaciones del framework + **flutter_animate**; Lottie y Rive tienen runtime oficial                      |
| React Native | **Reanimated 3+** + **Gesture Handler** (corren en el hilo de UI) y **Moti** encima para menos boilerplate |

## Librerías JS de apoyo (elige de aquí, no improvises)

| Necesidad             | Default                                        | Nota                                          |
| --------------------- | ---------------------------------------------- | --------------------------------------------- |
| Gráficas              | Chart.js                                       | Apache ECharts si el dashboard es denso       |
| Tablas de datos       | TanStack Table (React) / tabla + Turbo (Rails) | Ordenar/filtrar/paginar                       |
| Fechas                | `Intl` nativo; day.js si se complica           | Nada de moment.js                             |
| Formularios (React)   | React Hook Form + Zod                          | Ya en los presets SPA/PWA                     |
| Animación JS          | Motion                                         | Solo cuando CSS no alcanza                    |
| Manipulación de datos | JS nativo (map/filter/groupBy)                 | Lodash solo funciones puntuales (`lodash-es`) |

## Imágenes, ilustraciones y vectores (fuentes aprobadas)

De aquí se descargan los assets para prototipos y producto — todo gratuito y con
licencia que permite uso comercial (verifica siempre la licencia del asset concreto):

| Necesidad                   | Fuente                                                                        | Licencia / nota                                   |
| --------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------------- |
| Ilustraciones (SVG)         | [unDraw](https://undraw.co)                                                   | Licencia abierta; el color se ajusta al `primary` |
| Fotos                       | [Unsplash](https://unsplash.com) / [Pexels](https://pexels.com)               | Licencias libres; sin atribución obligatoria      |
| Logos de marcas de terceros | [Simple Icons](https://simpleicons.org)                                       | CC0; respeta las brand guidelines de cada marca   |
| Avatares de ejemplo         | [DiceBear](https://dicebear.com)                                              | API/librería open source; para datos de muestra   |
| Patrones de fondo (SVG)     | [Hero Patterns](https://heropatterns.com)                                     | CC BY 4.0                                         |
| Placeholders de imagen      | [picsum.photos](https://picsum.photos) / [placehold.co](https://placehold.co) | Solo en prototipos, nunca a producción            |
| Iconos                      | Lucide (ver Iconografía)                                                      | ISC                                               |

Reglas de uso:

- **Optimiza antes de commitear**: SVG por [SVGO](https://svgo.dev); fotos a WebP/AVIF
  con el ancho real de render. Assets pesados van a R2, no al repo.
- **`alt` siempre** (descriptivo, o `alt=""` si es decorativa) — es parte del baseline
  de accesibilidad.
- Ilustraciones de un solo estilo por producto (igual que los iconos: no mezclar).
- Nada de stock con marca de agua ni assets de licencia dudosa "mientras tanto".

## Estados obligatorios por vista

Toda vista que cargue datos maneja explícitamente: **loading** (skeleton), **empty**
(icono + texto + CTA que oriente), **error** (`alert-error` + retry) y **éxito**. La
skill `design-system-audit` lo verifica.

## Assets de marca por proyecto

Lo que sí cambia por proyecto (logo, nombre, OG image, y la paleta si el producto exige
identidad propia) se define al instanciar en
[`../docs/conventions/branding.md`](../docs/conventions/branding.md). Para cambiar el
branding se modifica **solo el bloque de tokens** — la estructura no se toca.

## Herramientas de diseño con IA (recomendadas)

Complementan este design system durante el desarrollo y la revisión — ambas open
source (criterio de la plantilla) y se **instalan como plugin**, no se copian al repo
(así reciben actualizaciones):

- **[Impeccable](https://impeccable.style)** (Apache 2.0) — la recomendación
  principal. Vocabulario de diseño operable (`/impeccable audit`, `critique`,
  `polish`, `typeset`…) + 59 detectores deterministas de anti-patrones de "diseño IA
  genérico". Clave para nosotros: **hereda los tokens y componentes existentes** (los
  de `design/`) en vez de imponer los suyos. Instalación en Claude Code:
  `/plugin marketplace add pbakaus/impeccable` → `/plugin install impeccable`, y corre
  `/impeccable init` una vez en el proyecto. Su CLI `npx impeccable detect` puede
  añadirse al CI como chequeo de UI.
- **[UI/UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)** (MIT) —
  opcional, solo para la **fase de definición**: base de datos consultable de estilos,
  paletas e industrias, útil para explorar dirección estética ANTES de fijar los
  tokens de `design/`. Una vez decidido el design system, no se usa (recomendaría
  desviaciones). Instalación: `/plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill`.

Reglas de convivencia: los tokens de `design/` y `docs/conventions/design-system.md`
**siempre mandan** sobre lo que sugiera cualquier herramienta; `design-system-audit` y
`accessibility-audit` siguen siendo los auditores de cumplimiento del sistema —
Impeccable añade la capa estética (jerarquía, tipografía, anti-slop) que ellas no cubren.
