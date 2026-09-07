# Banco de preguntas — definición de producto

> Las preguntas **literales** que se hacen para definir un producto antes de escribir
> código. Es el guion de la fase DEFINIR de
> [`../conventions/workflow.md`](../conventions/workflow.md), y la única agenda válida:
> `/definir-producto` e `/instanciar` se remiten a este archivo. Las conduce una skill,
> no un subagente: un subagente corre sin acceso a la persona y no puede preguntar nada.
> **Última actualización**: 2026-08-10

## Por qué existe este archivo

Sin un guion fijo, cada entrevista sale distinta: el modelo improvisa la redacción, el
orden y hasta los temas, y dos proyectos del mismo dueño terminan definidos con criterios
diferentes. Esa variación no es creatividad, es ruido — impide comparar proyectos,
volver sobre una definición meses después y saber si algo quedó sin preguntar.

Aquí las preguntas son **literales y estables**. Cambian por PR, como cualquier otra
decisión del repositorio, no por improvisación en medio de una conversación.

El marco base es el **Lean Canvas** (los bloques 1–5 y 7 lo recorren), extendido con lo
que un canvas no responde y sí hace falta para construir: el **corte de la v1**
(bloque 4) y la **superficie del producto** — recorrido, vistas, entidades e
integraciones (bloque 6). Las respuestas no aterrizan en un canvas aparte: van a
`product-definition.md`, que solo conserva del canvas lo que cambia una decisión.

## Reglas de uso (para el agente)

1. **Se hacen todas, en orden, con esta redacción.** No se reformulan ni se resumen. Sí
   se pueden añadir repreguntas de seguimiento cuando una respuesta quede vaga.
2. **En lotes de 2 a 4**, con `AskUserQuestion`, ofreciendo opciones concretas cuando el
   abanico sea acotado. Nunca un interrogatorio de 30 preguntas seguidas.
3. **Solo se salta una pregunta si ya está respondida por escrito** en la conversación o
   en `docs/product/`. En ese caso no se asume: se muestra la respuesta inferida y se
   pide confirmación ("entendí X, ¿es correcto?").
4. **Una pregunta cuya capacidad no existe no se hace.** Si el producto ya declaró que
   no tiene interfaz, ni base de datos, ni idiomas, preguntarlo es ruido: se marca como
   **no aplica** en el mapa de cobertura y se sigue. La regla 3 cubre lo ya respondido;
   esta cubre lo **inaplicable**, que no es lo mismo. Varias preguntas traen abajo su
   variante para productos sin interfaz — se usa esa, no se salta el bloque entero.
5. **Nada se inventa.** Si la persona no sabe o no quiere responder, la respuesta es
   "pendiente" y así queda marcada en el documento destino. Un pendiente explícito vale
   más que un dato plausible.
6. **La respuesta literal se registra; el documento es la interpretación.** Si una
   respuesta contradice otra anterior, se señala en el momento.
7. **El banco evoluciona por PR.** Si una pregunta nueva resulta útil dos veces, se
   incorpora aquí; si una nunca aporta, se elimina. Ambas cosas con su entrada en el
   `CHANGELOG.md`.

---

## Bloque 0 — Identidad y punto de partida

1. ¿Cómo se llama el proyecto? Si todavía no tiene nombre, ¿le ponemos un nombre-clave
   y decidimos el definitivo al cerrar la definición?
2. Completa esta frase: "**\_\_\_** es un/una **\_\_\_** que ayuda a **\_\_\_** a
   **\_\_\_**".
3. ¿Qué tipo de proyecto es? (producto con usuarios y CRUD · sitio de contenido sin
   backend · procesamiento de datos o IA · realtime, CLI o extensión) — determina qué
   stack de [`../marco-tecnico.md`](../marco-tecnico.md) §3 aplica.
   Y si hay móvil: ¿basta una PWA o hace falta app nativa? Lo decide §4.2 —offline real,
   cámara, push nativo o presencia en store—, no la preferencia.
4. ¿Este producto es para ti, para un cliente, o para el público? ¿Va a ser open source?

## Bloque 1 — Problema y cliente (Lean Canvas 1 y 2)

5. Cuéntame la última vez que viste a alguien sufrir este problema: ¿qué estaba
   haciendo, qué pasó, cómo terminó?
   _Si la respuesta es abstracta, insistir por un episodio concreto: el problema que no
   se puede narrar suele no existir._
6. ¿Quién tiene ese problema? Descríbeme **una persona concreta**: rol, contexto,
   herramientas que usa hoy.
   _Si responde con una categoría ("las pymes", "los freelancers"), repreguntar por una
   persona con nombre y situación._
7. ¿Cómo lo resuelven hoy sin ti? (incluye "con Excel", "a mano", "pagando a alguien",
   "no lo resuelven")
8. ¿Qué les cuesta hoy ese problema, en tiempo, dinero o riesgo?
   _Si no se puede estimar ni de forma gruesa, es señal de que quizá no duele lo
   suficiente para pagar por resolverlo._
9. Enumera los **tres problemas principales**, en orden de dolor.
10. ¿Por qué ahora? ¿Qué cambió (tecnología, regulación, hábito, tu situación) que hace
    que esto tenga sentido hoy y no hace tres años?

## Bloque 2 — Valor y solución (Lean Canvas 3, 4 y 9)

11. Propuesta de valor única en una frase: ¿qué obtiene la persona, y por qué contigo?
    _Formato útil: "el único \_\_\_ que \_\_\_"._
12. Concepto de alto nivel: "es el **\_\_\_** de **\_\_\_**" (analogía con algo que la
    persona ya conoce).
13. ¿Qué 2 a 4 capacidades componen el producto? Para cada una, ¿cuál de los tres
    problemas de la pregunta 9 ataca?
14. ¿Qué tienes tú que un competidor con dinero no pueda copiar en seis meses?
    _"Trabajar duro" y "mejor UX" no son ventajas defendibles; sí lo son el acceso a un
    canal, un dato propio, una comunidad o una experiencia específica._

## Bloque 3 — Alternativas

15. ¿Qué usan hoy tus usuarios que sea lo más parecido a esto? Nombra productos
    concretos.
16. ¿Por qué alguien dejaría lo que usa hoy para pasarse a lo tuyo? ¿Cuál es el costo de
    ese cambio para esa persona?

## Bloque 4 — El corte de la v1

17. ¿Cuál es **LA acción de valor** que la v1 hace de punta a punta? Una sola frase con
    un verbo.
18. Para cada funcionalidad que quieras meter: **si esto no está, ¿el producto deja de
    resolver el problema?**
    _Si la respuesta es no, va a "Fuera de v1". Se pregunta una por una, sin excepción._
19. ¿Qué queda **explícitamente fuera** de la v1, aunque duela?
    _Esta lista debe terminar más larga que la de "dentro". Si no lo está, el corte no
    fue un corte._
20. ¿Hay algo que este producto **no hará nunca**, por principio?
21. ¿Para cuándo quieres que la v1 esté en manos de alguien real?
    _La fecha no es un compromiso: es una herramienta para retar el alcance._

## Bloque 5 — Negocio (Lean Canvas 5, 6 y 7)

22. ¿Gratis, de pago o freemium? Si es de pago, ¿cuánto y por qué unidad (usuario, uso,
    plan, proyecto)?
23. ¿Cómo llegan tus **primeros diez** usuarios? Nómbralos si puedes.
    _"Redes sociales" y "SEO" no son respuestas: son categorías. Se busca un canal
    concreto y accionable esta semana._
24. ¿Qué costos fijos tendrá el producto al mes con 10 usuarios? ¿Y con 1000?
    _Repregunta obligatoria: **¿qué crece sin límite?** (storage, cómputo, llamadas a un
    modelo). Eso es el costo recurrente y tiene que estar en el precio desde el día uno._
25. ¿Cuál es el precio mínimo al que esto tiene sentido para ti, considerando tu tiempo?

## Bloque 6 — Recorrido y superficie

26. Cuéntame el recorrido completo de la persona, paso a paso, desde que llega por
    primera vez hasta que obtiene el valor.
27. Sobre ese recorrido: ¿qué pantallas hacen falta?
    _Contrastar contra el catálogo estándar de vistas de
    [`../conventions/workflow.md`](../conventions/workflow.md) — públicas, legales, auth,
    app — para que ninguna se descubra a mitad del desarrollo._
    **Sin interfaz**: ¿qué comandos (o funciones públicas) tiene, y qué entra y sale de
    cada uno? Es la misma pregunta —cuál es la superficie del producto— para lo que este
    producto es. La respuesta va a `architecture.md`, no a `pantallas.md`.
28. ¿Cuáles son las entidades principales del sistema y cómo se relacionan?
29. ¿Qué integraciones necesitas **desde el día 1**? (login con Google, storage de
    archivos, pagos, emails transaccionales, IA, analítica)
    _Cada una tiene su default en [`../marco-tecnico.md`](../marco-tecnico.md) §2; lo que
    no sea del día 1 se decide después._
30. ¿El producto es multiidioma desde la v1? ¿Cuáles?
    No aplica si no hay interfaz ni contenido de cara al público.

## Bloque 7 — Éxito y medida (Lean Canvas 8)

31. ¿Qué **hecho verificable** te permite decir "la v1 está lista"?
    _Debe ser observable por alguien más que tú: "tres personas ajenas completaron el
    recorrido sin ayuda", no "quedó bien"._
32. Si solo pudieras mirar **una métrica** a diario, ¿cuál sería?
33. ¿Qué señal concreta te haría construir la v1.1? ¿Y qué señal te haría abandonar el
    proyecto?

## Bloque 8 — Riesgos, supuestos y restricciones

34. ¿Cuál es el supuesto que, si resulta falso, tira abajo todo el proyecto?
35. ¿Cómo puedes probar ese supuesto **antes** de construir, gastando poco?
36. ¿El producto guarda datos personales o sensibles? ¿De menores? ¿En qué países están
    tus usuarios?
    **¿De quién son esos datos: de tus usuarios, o de terceros que nunca aceptaron nada?**
    Si el producto recolecta datos de alguien que no tiene cuenta —quien rellena un
    formulario, quien abre un enlace compartido, quien escanea un QR—, ese consentimiento
    hay que pedirlo **donde se recolecta**, y condiciona el diseño de esa pantalla. Es de
    las pocas cosas que salen caras si se descubren tarde.
    _Determina qué textos legales hace falta redactar y si aplica GDPR u otra
    normativa. La plantilla no los trae: se escriben por producto, con asesoría._
37. ¿Cuántas horas por semana le vas a dedicar de verdad?
38. ¿Qué tienes que respetar sí o sí? (presupuesto máximo, proveedor obligatorio, plazo
    externo, normativa, decisión ya tomada que no se discute)

---

## Mapa de cobertura

Cada sección de los documentos de producto se llena con respuestas concretas. Si una
sección queda vacía, es que faltó preguntar — no que "no aplicaba".

| Documento y sección                                         | Se llena con          |
| ----------------------------------------------------------- | --------------------- |
| `product-definition.md` · Visión en una frase               | 2                     |
| `product-definition.md` · El problema de la v1              | 5, 7, 8, 9, 10        |
| `product-definition.md` · Dentro de v1                      | 13, 17, 18            |
| `product-definition.md` · Fuera de v1                       | 18, 19, 20            |
| `product-definition.md` · Priorización (MoSCoW)             | 18                    |
| `product-definition.md` · Recorrido crítico                 | 26                    |
| `product-definition.md` · Negocio › Para quién y por qué tú | 6, 11, 12, 14, 15, 16 |
| `product-definition.md` · Negocio › Primeros diez           | 23                    |
| `product-definition.md` · Negocio › Precio y costos         | 22, 24, 25            |
| `product-definition.md` · Negocio › Métrica diaria          | 32                    |
| `product-definition.md` · Criterio de "v1 lista"            | 31                    |
| `product-definition.md` · Puertas de crecimiento            | 33                    |
| `product-definition.md` · Experimentos de validación        | 34, 35                |
| `product-definition.md` · Riesgos y supuestos               | 34, 36, 37, 38        |
| `roadmap.md` · Visión y versiones                           | 17, 19, 21            |
| `architecture/pantallas.md` · Mapa y recorrido              | 26, 27                |
| `architecture/database.md` · Entidades                      | 28                    |
| `architecture/auth.md` e integraciones                      | 29                    |
| `architecture/stack.md` · Stack elegido                     | 3, 29, 30             |
| `legal/`                                                    | 4, 36                 |

## Preguntas que no se hacen

- **Tamaño de mercado, TAM/SAM/SOM.** Para un producto de una persona no cambia ninguna
  decisión, y la respuesta siempre es inventada.
- **"¿Qué tecnología quieres usar?" al inicio.** El stack se decide **después** del
  producto, desde [`../marco-tecnico.md`](../marco-tecnico.md) y el tipo de
  proyecto (pregunta 3). Preguntarlo antes contamina el alcance con lo que es cómodo de
  construir.
- **Preguntas de diseño visual** (colores, tipografías). El sistema ya está resuelto en
  [`../../design/README.md`](../../design/README.md).
- **Cualquier pregunta cuya respuesta no cambie un documento.** Si no aterriza en el mapa
  de cobertura, sobra.
