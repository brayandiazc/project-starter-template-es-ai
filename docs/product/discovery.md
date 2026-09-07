# Discovery — lo que sabemos del mercado y de quién paga

> Lo que hemos averiguado **fuera** del producto: quién paga, quién más lo resuelve, y
> qué decidimos no construir. Lo alimenta el subagente
> [`product-researcher`](../../.claude/agents/product-researcher.md); lo consulta
> [`product-coach`](../../.claude/agents/product-coach.md) antes de aprobar nada.

`product-definition.md` dice **qué decidimos**. Este documento dice **con qué evidencia**.

Tres reglas, y la tercera es la que lo mantiene vivo:

1. **Toda entrada lleva fecha y fuente.** Sin fuente va marcada `⚠️ sin verificar`.
2. **«No encontré» no es «no existe».** Una investigación vacía hace la decisión más
   arriesgada, no más segura — escríbelo así.
3. **Una entrada con más de seis meses se re-verifica antes de usarse como argumento.**
   «Hace año y medio nadie cobraba por esto» no dice nada sobre hoy.

## 1. Quién pagaría, y con qué evidencia

Ordenado por fuerza de la señal, no por orden de llegada.

| Señal                             | Qué la respalda            | Fuente | Fecha   |
| --------------------------------- | -------------------------- | ------ | ------- |
| [Ya pagan por algo peor · fuerte] | [qué producto, qué precio] | [URL]  | [FECHA] |
| [Montan un apaño manual · media]  | [dónde lo vi]              | [URL]  | [FECHA] |
| [Dicen que les gustaría · débil]  | [dónde]                    | [URL]  | [FECHA] |

**«Lo quieren» y «lo pagarían» son cosas distintas.** La primera es barata de conseguir y
no sostiene un producto.

## 2. Quién más lo resuelve

| Producto | Cómo lo resuelve | Qué le falta | Precio | Fecha |
| -------- | ---------------- | ------------ | ------ | ----- |

**Que alguien cobre por esto es una buena noticia**: demuestra que hay presupuesto. Lo
preocupante es una tabla vacía — si nadie cobra, la pregunta incómoda es si alguien
pagaría.

## 3. Lo que decidimos NO construir

**Esta es la sección más valiosa del documento.** Una idea descartada vuelve —de tu
cabeza o de la de un modelo— y sin el registro se re-investiga entera.

| Qué                | Por qué no                   | Qué lo cambiaría         | Fecha   |
| ------------------ | ---------------------------- | ------------------------ | ------- |
| [La funcionalidad] | [La razón, con su evidencia] | [La señal que lo reabre] | [FECHA] |

La tercera columna es la que evita que esto sea un cementerio: un «no» sin condición de
reapertura es un «no» que nadie se atreve a revisar. Y el ítem correspondiente vive en
`roadmap.md` → «Fuera de alcance».

## Cómo se actualiza

- **Al terminar una investigación**: `product-researcher` devuelve su informe en la
  conversación; lo reutilizable —señales de pago, competidores— baja aquí. Lo que solo
  valía para esa decisión se queda en el `proposal.md` de su spec.
- **Los experimentos NO viven aquí.** Su tabla está en
  [`product-definition.md`](product-definition.md) → «Experimentos de validación», que
  ya ata cada supuesto frágil con la prueba que lo valida. Ahí se anota también **qué
  dijo**: un experimento y su resultado no se buscan en dos sitios. Lo que sí baja aquí
  es la **decisión** que salió de él, si fue no construir.
- **Al descartar algo**: entra en §3 con su condición de reapertura, **el mismo día**. Es
  cuando se recuerda por qué.
- **Al cerrar una versión**: se repasa §3. Si alguna condición de reapertura se cumplió,
  eso es una entrada de roadmap, no una idea nueva.
