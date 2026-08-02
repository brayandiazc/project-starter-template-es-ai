# Preset: PWA

> App instalable desde el navegador, sin pasar por las stores. El punto medio entre
> web y app nativa: un solo despliegue web, icono en el home, capacidad offline.

## ¿PWA o app nativa?

| Elige PWA si…                                           | Elige [`mobile.md`](mobile.md) si…                                     |
| ------------------------------------------------------- | ---------------------------------------------------------------------- |
| La distribución es por URL (B2B, herramientas internas) | Necesitas presencia en las stores para adquisición                     |
| Te basta push web y offline básico                      | Necesitas APIs nativas profundas (Bluetooth, widgets, background real) |
| Quieres un solo deploy para todo                        | iOS es tu mercado principal (las PWA en iOS siguen limitadas)          |

## Stack

| Capa            | Elección                                  | Por qué                                                           |
| --------------- | ----------------------------------------- | ----------------------------------------------------------------- |
| Base            | Vite + React + TypeScript                 | SPA ligera y rápida de iterar                                     |
| PWA             | vite-plugin-pwa (Workbox)                 | Manifest + service worker sin escribirlos a mano                  |
| CSS / UI        | Tailwind v4 + DaisyUI v5                  | El sistema de `design/`; shadcn/ui solo para primitives complejos |
| Estado servidor | TanStack Query (con `persistQueryClient`) | Cache que sobrevive offline                                       |
| Datos offline   | IndexedDB vía Dexie                       | Si la app debe funcionar sin red de verdad                        |
| Push            | Web Push (VAPID)                          | Sin Firebase; soporte iOS 16.4+                                   |
| Backend         | Supabase o Rails API                      | Misma decisión que en [`mobile.md`](mobile.md)                    |
| Hosting         | Cloudflare Pages                          | Gratis, HTTPS obligatorio ya resuelto                             |

Servicios transversales (Sentry, PostHog, IA…): ver [`README.md`](README.md).

## Reglas del preset

- **Define qué funciona offline y qué no** en la spec antes de programar — el service
  worker mal pensado es la principal fuente de bugs "fantasma" (usuarios viendo
  versiones viejas).
- Estrategia de actualización explícita: `autoUpdate` + aviso "nueva versión
  disponible" en la UI.
- Prueba la instalación real en Android e iOS (Safari) como parte del checklist de
  release.

## Costo estimado

- Cloudflare Pages free + backend según elección ≈ 0–15 USD/mes.

## Arranque

```bash
npm create vite@latest mi-pwa -- --template react-ts
npm i -D vite-plugin-pwa && npm i @tanstack/react-query dexie
```
