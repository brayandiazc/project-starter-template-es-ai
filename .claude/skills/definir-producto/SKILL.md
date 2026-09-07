---
name: definir-producto
description: Define el producto mediante una entrevista guiada — acota la v1 (alcance, MoSCoW, fuera de alcance), aterriza el negocio (precio, canal, costos) y alinea el roadmap. Úsalo al arrancar un producto o cuando haya que redefinir su alcance (p. ej. "definamos el producto", "acotemos la v1", "qué entra en la primera versión").
---

Convierte una idea de producto en dos documentos coherentes:
`docs/product/product-definition.md` (qué, para quién, cuánto y cómo se sostiene) y
`docs/product/roadmap.md` (cuándo).

**Esta skill es la única que conduce la entrevista.** El subagente `product-coach` no
puede: corre en su propio contexto, sin acceso a la persona. Él vigila el alcance
_después_; aquí se define.

## Paso 1 — Contexto

Lee los dos documentos de `docs/product/`. Si ya están rellenados, pregunta si esto
es una redefinición (y qué cambió) o un repaso. Lee también
`docs/architecture/stack.md` si existe — el stack condiciona qué es barato construir.

## Paso 2 — Entrevista

**Usa el banco de preguntas literal de
[`docs/product/interview.md`](../../../docs/product/interview.md)** — es la única
agenda válida. Léelo y sigue sus reglas de uso: preguntas textuales, en orden, en lotes
de 2 a 4 con AskUserQuestion; se salta solo lo ya respondido por escrito, y en ese caso
se confirma la inferencia en vez de asumirla.

No improvises la lista ni reformules las preguntas: si crees que falta una, hazla como
seguimiento y propón añadirla al banco por PR al terminar.

**Infiere antes de preguntar.** La regla 3 del banco permite saltar lo ya respondido por
escrito; extiéndelo a lo que el contexto ya dice. El nombre suele estar en la carpeta y
el remoto; si es open source, en la visibilidad del repositorio; el tipo de proyecto,
muchas veces en la primera frase de la idea. Cuando puedas inferir, **no preguntes:
confirma** («entendí que es X, ¿correcto?»). Convierte una pregunta en un asentimiento y
no cuesta precisión, porque la confirmación es explícita.

**Puedes cerrar por bloques.** Los bloques 0–4 y 6 producen la tabla Dentro/Fuera y el
mapa de pantallas: sin ellos no se avanza. Los bloques 5, 7 y 8 (negocio, éxito, riesgos)
no bloquean el prototipo. Si la sesión se alarga, cierra los primeros, deja constancia de
por dónde ibas y retoma los otros **después de ver el prototipo** — que es cuando esas
respuestas salen mejor. Lo que no vale es darlos por respondidos sin preguntarlos.

## Paso 3 — Redactar

Usa el **mapa de cobertura** del banco de preguntas: dice qué respuesta llena qué
sección. Si una sección queda vacía, falta preguntar — no "no aplicaba".

1. Rellena `product-definition.md`: visión, tabla Dentro/Fuera de v1, MoSCoW, recorrido
   crítico, **Negocio** (persona concreta, propuesta de valor, ventaja, canal de los
   primeros diez, precio y costos, métrica diaria), criterio de "v1 lista" y puertas de
   crecimiento.
   Sé agresivo acotando: la tabla "Fuera de v1" debe quedar más larga que la de "Dentro".
2. **Siembra `discovery.md`** con lo que la entrevista destapó y sea evidencia, no
   decisión: qué usan hoy las personas usuarias, por qué producto pagan ya, qué se
   descartó en el corte y qué lo reabriría. La entrevista es la primera fuente de esas
   señales, y si no bajan ahí se pierden en cuanto se cierra la conversación.
3. Alinea `roadmap.md`: v0.x = hitos hacia la v1; backlog = los Could/Won't; sección
   "Fuera de alcance" espejo de la definición.
4. Esboza en `docs/architecture/` los **cuatro borradores** que salen de la entrevista,
   marcados como tales:
   - `pantallas.md` — el mapa de pantallas y el recorrido (preguntas 26–27).
   - `database.md` — las entidades y sus relaciones (28).
   - `auth.md` — las integraciones del día 1 (29).
   - **`stack.md` — el stack elegido y sus desviaciones** (3, 29, 30). Sin esto el
     proyecto arranca sin constancia de con qué se construye, y la regla «desviarse
     cuesta un ADR» se queda sin línea base contra la que comparar.
5. Actualiza la línea "Última actualización" de los documentos tocados.
6. Sugiere el siguiente paso del sprint: construir las **vistas estáticas navegables**
   con `design/` como referencia (ver `docs/conventions/workflow.md` → Sprint).

## Paso 4 — Cierre

Muestra un resumen: la frase de visión, qué entra en v1 (lista corta), qué quedó fuera
(lista larga) y el criterio de éxito. Señala contradicciones detectadas (p. ej. precio
premium con canal masivo). Si la definición cambió el rumbo de forma relevante, sugiere
registrarlo con `/new-adr`.

NO inventes datos de negocio (precios, tamaños de mercado): si la persona no los da,
deja el placeholder y márcalo como pendiente en su misma línea
(`<!-- pendiente: … -->`). Cuando la sección es **prosa y no tiene placeholder** —«cómo
llegan los primeros diez», «la métrica diaria»—, escribe una frase corta y la misma
marca; **no inventes un placeholder nuevo**, uno fuera del catálogo de `TEMPLATE-USAGE.md`
hace fallar el check. NO toques código.

Es normal que buena parte de «Negocio» quede pendiente al arrancar: sale de los bloques
5, 7 y 8, que se cierran después de ver el prototipo.

En `docs/architecture/` escribe **solo los cuatro borradores del paso 3** —pantallas,
entidades, integraciones y stack—: son insumos que salen de la entrevista, no diseño
técnico. El resto de esos documentos se rellena al especificar cada cambio.
