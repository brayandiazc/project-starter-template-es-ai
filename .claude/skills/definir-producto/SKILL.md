---
name: definir-producto
description: Define el producto mediante una entrevista guiada — rellena el Lean Canvas, acota la v1 (alcance, MoSCoW, fuera de alcance) y alinea el roadmap. Úsalo al arrancar un producto o cuando haya que redefinir su alcance (p. ej. "definamos el producto", "acotemos la v1", "qué entra en la primera versión").
---

<!-- Skill de ejemplo de la plantilla — adáptalo o elimínalo según tu proyecto. -->

Convierte una idea de producto en tres documentos coherentes:
`docs/product/business-model.md` (por qué), `docs/product/product-definition.md`
(qué y cuánto) y `docs/product/roadmap.md` (cuándo).

## Paso 1 — Contexto

Lee los tres documentos de `docs/product/`. Si ya están rellenados, pregunta si esto
es una redefinición (y qué cambió) o un repaso. Lee también
`docs/architecture/stack.md` si existe — el stack condiciona qué es barato construir.

## Paso 2 — Entrevista (usa AskUserQuestion, por lotes)

Pregunta SOLO lo que no puedas inferir de la conversación o del repo:

- **Lote A · Problema y cliente:** ¿qué problema, de quién, cómo lo resuelven hoy?
  ¿Quién es el early adopter concreto (persona con nombre y contexto, no "las pymes")?
- **Lote B · Valor:** propuesta de valor en una frase; concepto de alto nivel
  ("X para Y"); ¿por qué tú / por qué ahora?
- **Lote C · Alcance v1:** ¿cuál es LA acción de valor que la v1 hace de punta a punta?
  Reta cada funcionalidad propuesta con: "si esto no está, ¿el producto deja de resolver
  el problema?" — si la respuesta es no, va a Fuera de v1.
- **Lote D · Negocio:** ¿gratis, de pago, freemium? precio tentativo; canal de llegada
  a los primeros 10 usuarios.
- **Lote E · Medida de éxito:** ¿qué hecho verificable declara la v1 exitosa?
  ¿qué señal habilitaría la v1.1 y la v2?
- **Lote F · Sprint (mapa e integraciones):** recorrido del usuario paso a paso →
  lista de vistas de la v1; entidades principales del modelo de datos; integraciones
  necesarias desde el día 1 (¿login con Google?, ¿storage de archivos?, ¿pagos?,
  ¿emails?) — cada una con su default del catálogo de stacks.

## Paso 3 — Redactar

1. Rellena `business-model.md` (Lean Canvas) con A, B y D.
2. Rellena `product-definition.md` con C y E: visión, tabla Dentro/Fuera de v1,
   MoSCoW, recorrido crítico, criterio de "v1 lista" y puertas de crecimiento.
   Sé agresivo acotando: la tabla "Fuera de v1" debe quedar más larga que la de "Dentro".
3. Alinea `roadmap.md`: v0.x = hitos hacia la v1; backlog = los Could/Won't; sección
   "Fuera de alcance" espejo de la definición.
4. Con el Lote F, esboza el mapa de vistas en `docs/architecture/design.md`, las
   entidades en `docs/architecture/database.md` y las integraciones en
   `docs/architecture/auth.md` (como borradores marcados).
5. Actualiza la línea "Última actualización" de los documentos tocados.
6. Sugiere el siguiente paso del sprint: construir las **vistas estáticas navegables**
   con `design/` como referencia (ver `docs/conventions/workflow.md` → Sprint).

## Paso 4 — Cierre

Muestra un resumen: la frase de visión, qué entra en v1 (lista corta), qué quedó fuera
(lista larga) y el criterio de éxito. Señala contradicciones detectadas (p. ej. precio
premium con canal masivo). Si la definición cambió el rumbo de forma relevante, sugiere
registrarlo con `/new-adr`.

NO inventes datos de negocio (precios, tamaños de mercado): si la persona no los da,
deja el placeholder y márcalo como pendiente. NO toques código ni `docs/architecture/`.
