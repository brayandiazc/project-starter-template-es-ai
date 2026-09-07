---
name: actualizar-costos
description: Revisa cada precio de docs/marco-tecnico-infraestructura.md contra su fuente en la web, actualiza lo que cambió y renueva la fecha de verificación. Úsalo cuando el check de costos se ponga rojo, cuando toque la revisión trimestral, o cuando la persona pregunte cuánto cuesta operar el proyecto hoy (p. ej. "actualiza los costos", "revisa los precios", "¿esto sigue costando lo mismo?").
---

Revisa los precios de `docs/marco-tecnico-infraestructura.md` contra la realidad.
**Verificar, no recordar**: todo precio sale de una búsqueda hecha ahora, nunca de tu
memoria. Las vías de acceso, el reparto y las trampas de ese documento **no se tocan
aquí** — no caducan con los precios.

Los precios de modelos viven en `docs/marco-tecnico-ia.md`, al lado de la decisión de
proveedor: se revisan en la misma pasada.

## Paso 0 — ¿Hay algo que revisar?

```bash
bash .github/scripts/check-costs.sh
```

Si sale en verde y la persona no pidió una revisión explícita, dilo y para: los
precios están dentro del trimestre. Si sale en rojo, sigue.

Rama: `docs/actualizar-costos-<AAAA-MM>` desde `develop`.

## Paso 1 — Verifica, proveedor por proveedor

**Una búsqueda por proveedor, y la fuente es su propia página de precios.** No te
fíes de comparativas ni de blogs: los precios cambian y esos no.

Prioriza por lo que más pesa en la factura, no por el orden de la tabla. El orden es
por **tipo de línea**, no por proveedor, porque los proveedores los eliges tú:

1. **Los costos fijos que no bajan con el uso.** Suelen ser dos o tres y suelen ser la
   mayor parte del escenario 1; si uno cambia, cambia todo el documento.
2. **El servidor.** Es la línea que más se mueve, y a veces mucho: hay proveedores que
   han subido líneas enteras más del 100% en cuatro meses. Verifica todos los escalones
   y **vuelve a comparar los tipos de instancia entre sí**: si alguna trampa de §5 dice
   que un tipo sale más barato que otro, eso puede haber dejado de ser cierto.
3. **Los que tienen plan gratuito.** Lo que cambia no suele ser el precio sino **el
   límite del plan gratuito**. Verifica el límite, no solo el número.
4. **Los modelos de IA**, si el producto los usa: precio de entrada, de salida y
   contexto, por modelo. Si un modelo se retiró o salió uno nuevo, dilo — el documento
   nombra modelos concretos.
5. **Las comisiones**: la anunciada Y la letra pequeña (conversión de moneda,
   contracargos, reembolsos). Las trampas de §5 suelen depender de ellas.

## Paso 2 — Escribe lo que encontraste

- **Cada precio que cambie**: actualízalo y **anota el anterior** en la línea de
  cambios del Paso 4. Un salto grande es la información, no el ruido.
- **Lo que no pudiste verificar** va marcado `⚠️ sin verificar` con la fecha del
  último dato bueno. **No lo dejes con su valor viejo como si estuviera vigente**:
  ese es exactamente el fallo que este documento existe para evitar.
- **Recalcula los dos escenarios y el total con staging.** Es aritmética, y es lo
  que la gente lee.
- **Revisa las trampas.** Si un precio nuevo tumba una —el tipo de instancia caro deja
  de ser el más barato, un proveedor cambia su comisión, una restricción técnica
  desaparece— la trampa se reescribe o se retira. Una trampa falsa es peor que
  ninguna.
- **Actualiza la `Fecha de verificación`** de la cabecera. Es lo que lee el check.

## Paso 3 — Lo que NO se toca

- **Precios de un producto concreto** que vivan fuera de este repo: aquí solo se
  mantiene el documento del marco.
- **La regla del §5** (todo proveedor tras un adaptador propio). No depende de
  ningún precio; de hecho, cada subida la confirma.
- **Los criterios de elección de casa** en §3.1. Se revisan cuando cambia lo que
  cada casa hace bien, no cuando cambia su tarifa.

## Paso 4 — Cierra

Resume en tres bloques, sin adornos:

1. **Qué subió, qué bajó y cuánto** — con el valor anterior al lado.
2. **Cómo quedaron los dos escenarios**, comparados con los de antes.
3. **Qué no pudiste verificar**, y por qué.

Entrada en el `CHANGELOG.md` bajo `Unreleased`, y PR con `/open-pr`. Si algún cambio
mueve una decisión del marco —un proveedor que deja de tener sentido— eso no es una
actualización de precios: **es un ADR**, y va aparte.

NO inventes un precio que no encontraste. NO copies cifras de tu memoria. NO dejes un
valor viejo sin marcar. Un presupuesto plausible y falso es peor que uno incompleto.
