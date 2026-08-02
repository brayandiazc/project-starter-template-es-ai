# [NOMBRE_DEL_PROYECTO] — Definición del producto

> Este documento **acota**: define qué es la v1, qué queda fuera y qué señal habilita
> crecer. Complementa al [Lean Canvas](business-model.md) (el porqué del negocio) y al
> [roadmap](roadmap.md) (el cuándo). La skill `/definir-producto` lo rellena por entrevista.
> **Última actualización**: [FECHA]

## Visión en una frase

[Para quién, qué hace y qué cambia para esa persona. Una sola frase.]

## El problema que ataca la v1

- [El problema concreto, en palabras del usuario — no de la solución.]
- **Cómo lo resuelven hoy**: [alternativa actual y por qué es insuficiente.]

## Definición de v1 (el corte)

La v1 es lo mínimo que **entrega el valor central de punta a punta** a un usuario real.
Regla: si al quitar algo el producto sigue resolviendo el problema, no va en la v1.

### Dentro de v1 (Must)

| Capacidad              | Qué permite hacer al usuario       |
| ---------------------- | ---------------------------------- |
| [Capacidad esencial 1] | [Acción/resultado para el usuario] |
| [Capacidad esencial 2] | [Acción/resultado para el usuario] |

### Fuera de v1 (explícitamente)

| Se queda fuera             | Por qué                                 | ¿Cuándo se reconsidera?     |
| -------------------------- | --------------------------------------- | --------------------------- |
| [Funcionalidad descartada] | [No es necesaria para el valor central] | [Señal que la haría entrar] |

> Esta tabla es la más importante del documento. Todo lo que no esté en "Dentro de v1"
> está fuera por defecto.

## Priorización (MoSCoW)

- **Must** — sin esto la v1 no existe: [lista].
- **Should** — importante, entra si sobra tiempo sin retrasar el corte: [lista].
- **Could** — deseable, va al backlog: [lista].
- **Won't (por ahora)** — decidido que no: [lista, espejo de "Fuera de v1"].

## Recorrido crítico del usuario

[El camino único que la v1 debe hacer impecable, de punta a punta:]

1. [Llega / se entera de que existe.]
2. [Se registra / entra.]
3. [Hace la acción de valor.]
4. [Obtiene el resultado.]
5. [Vuelve / paga.]

## Criterio de "v1 lista"

- [ ] El recorrido crítico funciona sin intervención manual.
- [ ] [Métrica o hecho verificable, p. ej. "3 usuarios reales lo completaron solos".]
- [ ] Cumple la [definición de terminado](../conventions/definition-of-done.md) técnica.

## Puertas de crecimiento

Qué señal habilita cada siguiente paso — para no construirlo antes de tiempo:

| Versión | Se construye cuando…                       | Añade                 |
| ------- | ------------------------------------------ | --------------------- |
| v1.1    | [Señal medible, p. ej. retención > X%]     | [Siguiente capacidad] |
| v2      | [Señal medible, p. ej. N clientes pagando] | [Apuesta mayor]       |

## Experimentos de validación

Pruebas baratas que validan los supuestos **antes** de construir — cada supuesto
frágil tiene su experimento:

| Supuesto                       | Experimento (barato)                          | Señal de validado              | Estado |
| ------------------------------ | --------------------------------------------- | ------------------------------ | ------ |
| [La gente tiene este problema] | [5 conversaciones con usuarios objetivo]      | [N de 5 lo confirman]          | ⬜     |
| [Pagarían por resolverlo]      | [Landing + lista de espera con precio]        | [X registros en Y semanas]     | ⬜     |
| [La solución les sirve]        | [Prototipo estático recorrido con 3 personas] | [Completan el flujo sin ayuda] | ⬜     |

## Riesgos y supuestos

- **Supuesto más frágil**: [lo que, si es falso, invalida el producto] → su experimento
  está en la tabla anterior.
- [Otros riesgos relevantes.]
