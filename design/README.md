# Identidad visual por defecto

> **La estructura se hereda; los valores se reemplazan.** Cada producto es su propia
> marca —su nombre, su sitio y su paleta— así que lo reutilizable aquí son los tokens
> semánticos, los dos temas, el contraste AA y los cuatro estados de datos.
> La paleta que trae `tokens.css` es un **punto de partida deliberadamente neutro**, no
> un mandato: existe para que ningún producto arranque con los colores sin definir, que
> es lo que produce el aspecto de plantilla genérica. Re-brandear es lo normal, no una
> desviación: la decide `/identidad`, se tocan los valores de `tokens.css` y nada más.
> Los assets por producto (logo, imagen social) se registran en
> [`../docs/conventions/ui.md`](../docs/conventions/ui.md).

Los tokens viven en un solo lugar:

- [`tokens.css`](tokens.css) — **la única fuente de verdad.** Paleta en `:root` como
  custom properties de CSS estándar, oscuro por `prefers-color-scheme` y por
  `[data-theme="dark"]`, y al final un bloque **adaptador** que las expone al framework
  de UI que uses (o ninguno). (Hubo un `tokens.json`
  "espejo para JS/Expo": era una copia a mano que nadie consumía y ya había divergido —
  si un stack llega a necesitar los valores en JSON, se **genera** desde este CSS y se
  suma al check de `design-md.sh`, no se copia.)
- [`preview.html`](preview.html) — **ábrelo en el navegador para decidir la paleta.**
  Enlaza `tokens.css` directamente y solo usa `var(--token)`: no copia un solo valor, así
  que no puede desincronizarse. Muestra el inventario de componentes aplicado —paleta con
  su contraste AA calculado en vivo, tipografía, botones con sus cinco estados,
  formulario, los cuatro estados de datos, superficies y un registro «herramienta»
  (toolbar, panel, timeline) para productos que no son un SaaS de documentos.

> **`preview.html` valida tokens, no layouts.** Responde «¿este color funciona?», no
> «¿cómo se ve mi producto?». Las vistas del producto se generan con `/prototipo` cuando
> hacen falta y no se versionan: una landing de muestra envejece y acaba contradiciendo
> a los tokens. El preview no, porque solo muestra primitivas.

> Criterio de selección de todo lo que sigue: **solo open source** (MIT/OFL/ISC/BSD) —
> nada con licencia restrictiva o de pago en el camino crítico del stack.

## Framework de UI (web)

**Esta tabla la rellenas tú.** El sistema **no depende de ninguna tecnología**: el
diseño se puede montar como quieras —un framework de utilidades, uno de componentes,
un preprocesador, CSS a pelo, un sistema propio de la empresa— porque lo que manda son
los tokens de `tokens.css` y no las utilidades de nadie. Lo que sigue son las
**preguntas** que hay que contestar y el criterio para contestarlas.

| Pieza          | Elección          | Criterio para elegir                                                               |
| -------------- | ----------------- | ---------------------------------------------------------------------------------- |
| CSS            | [HERRAMIENTA]     | Que pueda leer tus tokens como variables, sin duplicar los valores                 |
| Componentes    | [HERRAMIENTA]     | Que no traiga estética propia: el aspecto es del producto (ver abajo)              |
| Primitivas     | HTML nativo       | `<dialog>`, `<details>`, `popover`: foco, teclado y Escape ya resueltos            |
| Interactividad | [FRAMEWORK_FRONT] | Lo que ya use tu stack; ver [`../docs/marco-tecnico.md`](../docs/marco-tecnico.md) |

**Regla de oro, y esta no se rellena**: tokens semánticos (`primary`, `base-100`,
`base-content`), **nunca** colores crudos —ni un hex inline, ni una utilidad de paleta
del framework (`bg-blue-500`, `--bs-blue`, `$gray-700`)—. Es lo que permite re-brandear
el producto tocando un solo bloque de `tokens.css`, y lo verifica el CI.

**El criterio que sí es del sistema: cero opinión visual en la capa de componentes.**
Una librería que trae su propio aspecto —cualquier kit de UI con estética de fábrica,
comprado o gratis— produce el look que comparten miles de sitios, que es justo la deriva a
"plantilla de SaaS genérica" que este documento existe para evitar. Y, siendo CSS, **no**
resuelve el comportamiento (focus trap, Escape, ARIA, teclado), que es donde de verdad
falla el código generado por un agente. Se paga la ventaja equivocada.

Lo que sí vale es una capa **headless**: accesibilidad y comportamiento resueltos, cero
estilos. Las primitivas nativas del navegador son la versión gratis de eso, y casi todo
ecosistema tiene su equivalente headless — búscalo por esa palabra. Los pocos
componentes propios que queden se revisan a mano (ver
[`../docs/conventions/ai-agents.md`](../docs/conventions/ai-agents.md)).

> **Única excepción a los colores: los logos de terceros.** La "G" de Google, el logo de
> GitHub o el de Stripe llevan sus colores de marca exactos — retiñirlos con nuestros
> tokens infringe sus brand guidelines. Se marca el `<svg>` con `data-brand="<marca>"` y
> el check del CI lo respeta; el contenedor (botón, card) sí usa nuestros tokens, para
> que funcione en ambos temas. Caso típico: el botón de "entrar con Google". Fuera de
> ese `<svg>`, un hex sigue fallando.

## Paleta (tema `base`)

**Los valores no se listan aquí** — otra copia a mano divergiría sin que nada lo
detectara. La tabla completa de los 20 tokens en ambos temas vive en
[`../DESIGN.md`](../DESIGN.md), que se **genera** desde `tokens.css` con
`design-md.sh --write` y cuya sincronía verifica el CI. El rol de cada token está
comentado dentro del propio [`tokens.css`](tokens.css).

- **Modo claro y oscuro desde el día 1**: `tokens.css` trae ambas paletas; el oscuro
  responde a `prefers-color-scheme` **y** a `data-theme="dark"`, de modo que el toggle
  de la UI gana en los dos sentidos. Toda vista se revisa en los dos modos antes de
  darse por hecha.
- **Multiidioma por defecto (es + en neutro)**: nada de cadenas hardcodeadas en
  vistas — todo texto visible pasa por i18n (`docs/conventions/i18n.md`); la skill
  `/i18n-parity` verifica la paridad.
- Texto secundario: `base-content` con opacidad (`text-base-content/70`), no un gris nuevo.
- Contraste mínimo WCAG AA (4.5:1 texto normal, 3:1 texto grande) — en ambos temas.
- **Derivación de marca**: los colores de marca (teal `#0C93BC`, naranja `#FF5722`)
  son fijos; los tokens `primary`/`accent` los ajustan por luminancia en cada tema
  solo para mantener AA (en oscuro: teal claro `#3FB4D8`, naranja claro `#FF7A4D`).

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
- Escala: una escala tipográfica fija y corta (la de tu framework, o defínela en
  `tokens.css`). Pesos 400/500/600/700 — no más de cuatro.
- Carga self-hosted vía [Fontsource](https://fontsource.org) (variable fonts) — sin
  Google Fonts en runtime de producción.

## Iconografía

- **Set único: [Lucide](https://lucide.dev)** (licencia ISC) — trazo 2px, tamaño base
  20/24px. Elegido por cobertura multiplataforma con paquetes oficiales/mantenidos:
  con un paquete por ecosistema (web, framework de componentes, móvil) — el
  mismo icono se ve igual en web y en móvil.
- **Alternativa documentada: [Phosphor](https://phosphoricons.com)** (MIT) — úsalo solo
  si el producto necesita variantes de peso (thin/regular/bold/fill/duotone) como parte
  del lenguaje visual; también cubre web y React Native.
- No mezclar sets en un producto. Emojis solo en contenido, nunca como iconos de UI.
- **Única excepción, el selector de idioma**: la bandera acompaña al nombre del idioma,
  nunca lo sustituye (`🇪🇸 Español`, no `🇪🇸` sola). Conviene recordar que las banderas
  son países y no idiomas — el español no es solo de España —; se usan porque se
  reconocen de un vistazo, y por eso el texto manda.

## Geometría

- Radios: `rounded-field` (`0.5rem`) en campos y botones, `rounded-box` (`0.75rem`) en
  cards y modales. Ambos salen de `tokens.css`.
- Bordes de 1px con `base-300`; profundidad plana (sin sombras fuertes) — la elevación
  se comunica con borde + fondo, no con sombra.
- Espaciado: una escala fija basada en múltiplos de 4px, la de tu framework o la
  tuya. Lo importante no es cuál, es que **no haya valores sueltos** fuera de ella.

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
- Loading: **skeleton** con la forma del contenido que va a llegar (preferido) o un
  spinner — nunca el texto "Cargando…".
- **Siempre** respeta `prefers-reduced-motion: reduce` (Motion lo trae con
  `useReducedMotion`; el CSS de `tokens.css` ya desactiva lo decorativo).

### Motion en móvil

En Expo (la única vía a móvil, y solo cuando la PWA no basta): **Reanimated 3+** +
**Gesture Handler**, que corren en el hilo de UI, y **Moti** encima para menos
boilerplate. Lottie y Rive tienen runtime oficial.

## Librerías JS de apoyo (elige de aquí, no improvises)

| Necesidad             | Default                              | Nota                                          |
| --------------------- | ------------------------------------ | --------------------------------------------- |
| Gráficas              | Chart.js                             | Apache ECharts si el dashboard es denso       |
| Tablas de datos       | [HERRAMIENTA]                        | Ordenar/filtrar/paginar                       |
| Fechas                | `Intl` nativo; day.js si se complica | Nada de moment.js                             |
| Formularios (React)   | React Hook Form + Zod                | Ya en los presets SPA/PWA                     |
| Animación JS          | Motion                               | Solo cuando CSS no alcanza                    |
| Manipulación de datos | JS nativo (map/filter/groupBy)       | Lodash solo funciones puntuales (`lodash-es`) |

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
skill `design-system-audit` los verifica; el job `Design system` del CI solo puede
verificar los colores.

Los cuatro se revisan **en ambos temas** antes de dar una vista por hecha. El estado
vacío es el que más se olvida y el que más define el producto: un icono, una frase que
explique por qué está vacío y un CTA que oriente — nunca una tabla en blanco.

## Assets de marca por proyecto

Lo que sí cambia por proyecto (logo, nombre, imagen social, y la paleta si el producto
exige identidad propia) se registra en
[`../docs/conventions/ui.md`](../docs/conventions/ui.md) → Assets de marca. Para
cambiar el branding se tocan **solo los valores de `tokens.css`** — la estructura no.

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

> **Quién decide qué.** La dirección de diseño —paleta, tipografías, el elemento que
> hace memorable el producto— la propone la skill `frontend-design`, que ya viene con
> Claude Code y trae la calibración contra los tres _looks_ por defecto de la IA. Quien
> la ata a este sistema es [`/identidad`](../.claude/skills/identidad/SKILL.md):
> traduce esa dirección a los veinte tokens en dos temas, verifica el contraste y te la
> deja aplicada en `preview.html` para que decidas viéndola. Impeccable entra después,
> como detector determinista de lo que se coló.

Reglas de convivencia: los tokens de `design/` **siempre mandan** sobre lo que sugiera cualquier herramienta; `design-system-audit` y
`accessibility-audit` siguen siendo los auditores de cumplimiento del sistema —
Impeccable añade la capa estética (jerarquía, tipografía, anti-slop) que ellas no cubren.
