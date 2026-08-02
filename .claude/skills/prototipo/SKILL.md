---
name: prototipo
description: Genera las vistas estáticas navegables del producto (landing, auth, app, legales, errores y las propias del mapa de pantallas) usando el design system de design/, sin lógica de backend. Úsalo en el paso "prototipar" del sprint de definición o cuando haya que maquetar vistas nuevas (p. ej. "haz el prototipo", "maqueta las vistas", "crea la landing estática").
---

<!-- Skill de ejemplo de la plantilla — adáptalo o elimínalo según tu proyecto. -->

Construye vistas estáticas clicables — validan flujo y diseño antes de escribir
lógica, y luego se conectan (no se tiran).

## Paso 1 — Contexto

Lee `design/README.md` + `design/tokens.css` (sistema y tokens), el mapa de vistas en
`docs/architecture/design.md` y la definición en `docs/product/product-definition.md`.
Si no hay mapa de vistas, constrúyelo primero con la persona (o delega en
`product-coach`).

## Paso 2 — Inventario de vistas

Parte del **catálogo estándar** y márcalo contra el mapa:

- **Públicas**: landing/home, precios (si hay pago), sobre/about, contacto,
  404 y 500.
- **Legales**: términos, privacidad, cookies (contenido desde `legal/`).
- **Auth** (si hay cuentas): login, registro, recuperar contraseña.
- **App**: las vistas propias del recorrido crítico (dashboard, la acción de valor,
  ajustes/cuenta).

Confirma con la persona cuáles entran en el prototipo (default: todas las del
recorrido crítico + landing + legales).

## Paso 3 — Construir

- Formato según preset: ERB/partials si es Rails, páginas Astro si es estática,
  JSX si es SPA. Si el proyecto aún no está instanciado, HTML plano estilo
  `design/preview.html`.
- Solo tokens semánticos del design system; componentes de `design/preview.html`
  como base; estados loading/empty/error visibles donde aplique (con datos de
  ejemplo realistas, no "lorem ipsum").
- Imágenes/ilustraciones desde las fuentes aprobadas de `design/README.md`
  (unDraw, Unsplash, DiceBear…) — optimizadas y con `alt`.
- Navegación real entre vistas (links funcionando) — el prototipo se recorre completo.
- Modo claro y oscuro (temas `base`/`base-dark`) y textos pensados para es/en
  (sin hardcodear cadenas si el preset ya tiene i18n).

## Paso 4 — Validar

Recorre el prototipo contra el recorrido crítico de la definición y lista lo que
chirría (pasos de más, información faltante). Cierra con: vistas creadas, decisiones
de diseño tomadas, y qué vista conectar primero cuando empiece la implementación.

Si el plugin **Impeccable** está disponible, pasa `/impeccable audit` sobre las
vistas generadas antes de darlas por listas (ver `design/README.md` → Herramientas
de diseño con IA).

NO añadas lógica de negocio, ni JS más allá de navegación/toggles triviales, ni
inventes vistas fuera del mapa sin proponerlas antes.
