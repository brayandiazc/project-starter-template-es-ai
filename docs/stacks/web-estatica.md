# Preset: Web estática / contenido

> Landings, blogs, documentación, portafolios, sitios de marketing. Sin backend
> propio: contenido en el repo, hosting gratis, performance perfecta.

## Stack

| Capa           | Elección                                                                              | Por qué                                                |
| -------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| Framework      | Astro                                                                                 | HTML primero, cero JS por defecto, islas si hace falta |
| Contenido      | Content Collections + MDX                                                             | Contenido tipado y versionado en el repo               |
| CSS            | Tailwind CSS                                                                          | Con los tokens de `design/`                            |
| Interactividad | Islas (Astro/React) solo puntual                                                      | Un buscador, un pricing toggle — nada más              |
| Hosting        | Cloudflare Pages                                                                      | Gratis, CDN global, previews por PR                    |
| Formularios    | Endpoint propio + Resend, o Formspark                                                 | Contacto/newsletter sin backend                        |
| Analytics      | Plausible (o PostHog si hay producto detrás)                                          | Ligero, sin banner de cookies si config bien           |
| SEO            | `@astrojs/sitemap` + convenciones de [`../conventions/seo.md`](../conventions/seo.md) | El SEO es la razón de ser de estos sitios              |

## Recetas rápidas (sin backend)

Para necesidades pequeñas no montes un servidor — usa la pieza mínima:

| Necesidad                                                   | Solución                                                                                                                                     |
| ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Lista de espera / contacto                                  | **FormSubmit** o Formspark apuntando a tu email; si quieres los emails en una lista, un Worker de Cloudflare que escriba en Resend Audiences |
| Newsletter                                                  | Resend Audiences (o Buttondown si es contenido regular)                                                                                      |
| Preferencias del visitante (tema, banner cerrado, progreso) | `localStorage` — nada de cookies propias ni base de datos                                                                                    |
| Contador simple / feature flag                              | Cloudflare Workers KV (gratis en este volumen)                                                                                               |
| Comentarios (blog/docs)                                     | Giscus (sobre GitHub Discussions)                                                                                                            |
| Buscador en docs/blog                                       | Pagefind (indexa en build, sin servidor)                                                                                                     |

Regla: el día que una receta se queda corta (necesitas cuentas, panel, datos de
verdad), no la parches — es la señal de pasar a [`web-fullstack.md`](web-fullstack.md).

## Cuándo elegirlo

- La web de marketing de un producto (aunque el producto sea Rails o móvil) — se
  despliega aparte y siempre gratis.
- Blogs, documentación, portafolios, sitios de eventos.

## Cuándo NO

- Hay usuarios con sesión o datos → [`web-fullstack.md`](web-fullstack.md).
- El contenido lo edita alguien no técnico a diario → considera un CMS headless
  (p. ej. Decap CMS sobre el mismo repo) antes de cambiar de stack.

## Costo estimado

- 0 USD/mes + dominio (~10 USD/año).

## Arranque

```bash
npm create astro@latest mi-web -- --template minimal
npx astro add tailwind mdx sitemap
```
