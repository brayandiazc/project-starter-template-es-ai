# Preset: Extensión de navegador

> Extensiones para Chrome/Edge/Firefox (Manifest V3). Buen formato para productos
> "acompañantes" de un SaaS o utilidades de nicho con distribución en la Web Store.

## Stack

| Capa           | Elección                                      | Por qué                                                                |
| -------------- | --------------------------------------------- | ---------------------------------------------------------------------- |
| Framework      | WXT                                           | Convenciones tipo Next para extensiones; multi-navegador; HMR          |
| UI             | React + Tailwind                              | Popup/options/side panel con los tokens de `design/`                   |
| Estado/storage | `wxt/storage` (chrome.storage.sync)           | Config sincronizada entre dispositivos del usuario                     |
| Mensajería     | La de WXT (runtime messaging tipada)          | content script ↔ background sin strings mágicos                        |
| Backend        | Ninguno, o [`api-service.md`](api-service.md) | Muchas extensiones no lo necesitan; añádelo solo para cuentas/pagos/IA |
| IA             | Vía tu API, nunca desde la extensión          | La API key jamás va en el cliente                                      |
| Publicación    | Chrome Web Store + Firefox AMO                | 5 USD una vez (Chrome); revisión en días                               |

## Reglas del preset

- **Manifest V3 desde el día 1** (service worker, no background pages).
- **Permisos mínimos**: cada permiso extra (`tabs`, `<all_urls>`…) reduce conversiones
  en la Web Store y alarga la revisión. Pide solo lo que uses, usa `optional_permissions`
  para lo demás.
- Si hay cuentas o pagos: el login vive en tu web (preset fullstack) y la extensión
  consume tokens — no reimplementes auth dentro de la extensión.
- Versiona con SemVer y mantén un changelog visible: las stores muestran las notas.

## Monetización típica

- Free + Pro con licencia validada contra tu API (Paddle para el cobro, en tu web).

## Costo estimado

- 5 USD (registro Chrome) + backend solo si aplica.

## Arranque

```bash
npx wxt@latest init mi-extension --template react
```
