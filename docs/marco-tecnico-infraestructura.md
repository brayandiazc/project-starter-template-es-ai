# Marco técnico — la infraestructura, de punta a punta

> **Fecha de verificación**: [FECHA] — de los precios; las vías de acceso no caducan.
> Todo en USD, sin IVA. Cada precio sale de la página del proveedor o de una factura
> real; la factura gana siempre al precio de lista.

Los servicios de [`marco-tecnico.md`](marco-tecnico.md) §2 se eligen **una vez** y son
los mismos en todos los stacks. Aquí está todo lo demás sobre ellos: **cuánto cuestan**,
**cómo se tocan** desde una conversación con el agente, y **quién hace qué**.

Responde cuatro preguntas que aparecen siempre y que sin esto se contestan a ojo:
¿cuánto cuesta arrancar? ¿cuánto cuando funcione? ¿por dónde opero cada cosa? ¿qué puedo
hacer yo y qué tiene que hacer la persona?

> **Las tablas vienen vacías y el criterio no.** Los precios de otra persona, otro país
> y otro año son el peor dato posible: son plausibles y son falsos. Lo que sí se hereda
> —el reparto de §3, las reglas de §6 y la disciplina de §5— sigue valiendo tal cual.

> **Los precios caducan, el criterio y las vías de acceso no.** Las cifras se revisan
> cada trimestre y `check-costs.sh` falla cuando la fecha de arriba se queda vieja.

## 1. Los servicios: qué cuesta cada uno

Una fila por servicio de `marco-tecnico.md` §2, más lo que este producto añada. La
columna «Qué incluye» es la que evita la sorpresa: **el límite del plan gratuito importa
más que su precio.**

| Categoría           | Servicio              | Qué incluye | Costo/mes    |
| ------------------- | --------------------- | ----------- | ------------ |
| Servidor            | [PROVEEDOR_HOSTING]   | [RECURSO]   | [COSTO_MES]  |
| Base de datos       | [BASE_DE_DATOS]       | [RECURSO]   | [COSTO_MES]  |
| DNS, CDN y TLS      | [PROVEEDOR_DNS]       | [RECURSO]   | [COSTO_MES]  |
| Archivos            | [PROVEEDOR_ARCHIVOS]  | [RECURSO]   | [COSTO_MES]  |
| Respaldos · datos   | [ESTRATEGIA_BACKUP]   | [RECURSO]   | [COSTO_MES]  |
| Respaldos · máquina | [ESTRATEGIA_BACKUP]   | [RECURSO]   | [COSTO_MES]  |
| Email transaccional | [PROVEEDOR_EMAIL]     | [RECURSO]   | [COSTO_MES]  |
| CI/CD               | [CI_CD]               | [RECURSO]   | [COSTO_MES]  |
| Errores             | [MONITOREO]           | [RECURSO]   | [COSTO_MES]  |
| Uptime y logs       | [PROVEEDOR_UPTIME]    | [RECURSO]   | [COSTO_MES]  |
| Analytics           | [PROVEEDOR_ANALYTICS] | [RECURSO]   | [COSTO_MES]  |
| Pagos               | [PROVEEDOR_PAGOS]     | [RECURSO]   | [PORCENTAJE] |
| Dominio             | [PROVEEDOR_DOMINIOS]  | [RECURSO]   | [COSTO_MES]  |
| Desarrollo          | [HERRAMIENTA_IA]      | [RECURSO]   | [COSTO_MES]  |

**Todo precio lleva su fuente.** Si no la tiene, va marcado **⚠️ sin verificar** — un
número sin origen no se distingue de uno inventado.

## 2. Cómo se opera cada uno

No basta con saber qué se usa: hace falta saber **por dónde se toca**, porque de eso
depende si el agente puede hacerlo o tiene que pedírtelo.

| Servicio         | Para qué                           | Cómo lo opera el agente            | Credencial   | Dueño                                  |
| ---------------- | ---------------------------------- | ---------------------------------- | ------------ | -------------------------------------- |
| **Búsqueda web** | Evidencia de fuera del repositorio | `WebSearch` / `WebFetch`           | Ninguna      | `product-researcher`                   |
| [SERVICIO/API]   | [PARA_QUE]                         | [COMO]                             | [CREDENCIAL] | [RESPONSABLE]                          |
| **Credenciales** | Secretos del proyecto              | CLI — **la persona, no el agente** | La suya      | [`secrets.md`](conventions/secrets.md) |

**Por qué no hay MCP para todo.** Un MCP se justifica cuando la herramienta tiene un
modelo de datos que consultar (errores, eventos, documentación). Para lo que ya tiene
una CLI buena, el MCP añade una capa sin añadir capacidad. **Los MCP de SSH solo tienen
sentido en clientes sin shell**; aquí hay shell.

## 3. El reparto: quién hace qué

La tabla anterior dice **por dónde** se toca cada servicio. Esto dice **quién**, que es
lo que necesita saber cualquiera que llegue —persona o modelo— antes de tocar nada.

| Lo hace…                             | Qué                                                                                                                                                             |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **El agente, solo**                  | Leer errores y analytics, consultar documentación, abrir issues y PRs, correr los checks, desplegar y ver logs, tomar un snapshot antes de un cambio arriesgado |
| **El agente, con permiso explícito** | Provisionar o destruir infraestructura, restaurar un respaldo, borrar snapshots, publicar un release, cualquier cosa que se le cobre a alguien                  |
| **La persona, siempre**              | Abrir la bóveda de credenciales y poner valores en el `.env` real, aprobar y fusionar PRs, decidir público/privado del repositorio, aceptar un gasto nuevo      |

**La regla que resuelve las dudas**: si la acción es difícil de revertir o se ve desde
fuera —un cobro, un borrado, algo publicado— se confirma antes, aunque el agente pueda
hacerla técnicamente. Que pueda no es que deba.

Y el corolario que hace útil todo esto: **lo que el agente opera, lo deja escrito**. Un
deploy hecho a mano por el panel de un proveedor no existe para quien llegue después. Un
comando en la conversación, sí.

## 4. Los dos escenarios

Un total por servicio no dice nada; lo que se decide con esta sección es **si el
producto puede permitirse existir**. Por eso son dos escenarios y no uno.

### Escenario 1 — un solo ambiente que en realidad es producción

Donde pruebas tú y donde viven las primeras versiones con clientes reales. Cobra, envía
correos y guarda datos de verdad.

| Concepto            | $/mes         |
| ------------------- | ------------- |
| [SERVICIO/API]      | [COSTO_MES]   |
| **Plataforma sola** | [COSTO_TOTAL] |
| [HERRAMIENTA_IA]    | [COSTO_MES]   |
| **Total**           | [COSTO_TOTAL] |

### Escenario 2 — producción con tracción

Los free tiers se agotan y el servidor sube de escalón.

| Concepto            | $/mes         |
| ------------------- | ------------- |
| [SERVICIO/API]      | [COSTO_MES]   |
| **Plataforma sola** | [COSTO_TOTAL] |
| [HERRAMIENTA_IA]    | [COSTO_MES]   |
| **Total**           | [COSTO_TOTAL] |

**Al pasar al escenario 2, el ambiente de test deja de poder ser producción.** Con
clientes pagando no se prueba en el servidor que les da servicio: hacen falta los dos a
la vez. Súmalo aquí antes de que llegue el día, no después.

> **Busca los costos que no bajan con el uso.** Casi siempre hay dos o tres fijos que se
> comen la mayor parte de la factura mientras el producto es pequeño, y el resto cabe en
> el ruido. Cualquier ahorro que no los toque es cosmético.

## 5. Las trampas

**Esto es lo que no caduca.** Los precios de arriba envejecen; una trampa no, porque es
cómo funciona el proveedor y no cuánto cobra hoy.

Aquí se anota lo que descubriste pagando y no quieres volver a descubrir:

- Una comisión cuyo porcentaje real no es el anunciado, una vez sumadas conversión de
  moneda, contracargos y reembolsos.
- Un límite que se aplica por día y no por mes, o por cuenta y no por recurso.
- Una restricción que no es de precio sino **de arquitectura** —una API que no se puede
  llamar desde el navegador, un formato que no está disponible en todos los planes—.
  Estas son las caras: cambian el diseño, no el presupuesto.
- Un escalón donde lo caro sale más barato que lo barato. Suele ser contraintuitivo, y
  por eso hay que escribirlo.

| Trampa   | Qué significa en la práctica |
| -------- | ---------------------------- |
| [TRAMPA] | [CONSECUENCIA]               |

## 6. Lo que el agente NO puede hacer

Esto no es una lista de limitaciones técnicas: son **decisiones**, y por eso están
escritas. Tres de ellas las bloquea un hook, no la buena voluntad.

| No puede                                       | Por qué                                                                           | Quién lo impide               |
| ---------------------------------------------- | --------------------------------------------------------------------------------- | ----------------------------- |
| Leer o escribir el `.env` real                 | Los valores reales de secretos no pasan por el agente                             | `secret-guardrails.sh` (hook) |
| Commitear en `main` o `develop`, ni force-push | Todo entra por PR                                                                 | `git-guardrails.sh` (hook)    |
| Tocar código en `feat/*` o `fix/*` sin su spec | Sin contrato no hay cambio                                                        | `spec-guardrails.sh` (hook)   |
| **Aprobar su propio PR**                       | GitHub no permite aprobar un PR propio, y el PR sale con la autoría de la persona | GitHub                        |
| Sacar una credencial de la bóveda              | La bóveda la abre la persona; el agente recibe nombres de variable, no valores    | `secrets.md`                  |

**Y una que no bloquea nadie**: si el repositorio no tiene protección de ramas —GitHub
no la ofrece en repos privados de plan gratuito— las tres primeras reglas solo las
sostienen los hooks locales, que se saltan con `--no-verify`. Compruébalo con
`check-hooks-enabled.sh` y consulta `/configurar-repo` §Paso 4.

## 7. Lo que falta por automatizar

Se declara aquí en vez de descubrirse a mitad de una urgencia. Un hueco callado se lee
como resuelto:

- [QUE_FALTA] — [CONSECUENCIA]
- **La restauración de un respaldo** rara vez está automatizada. Documéntala en
  [`deploy.md`](conventions/deploy.md) y **pruébala a mano cada mes**: un respaldo que
  nunca se restauró es una suposición, no un respaldo.

## 8. Cómo se activan los MCP y las CLI

Los MCP vienen en [`.mcp.json.example`](../.mcp.json.example), desactivados:

```bash
cp .mcp.json.example .mcp.json
```

Claude Code pide aprobación antes de usar cualquier servidor MCP del proyecto, y hay
que reiniciarlo tras copiar el archivo.

**Los servidores que trae el ejemplo son eso: ejemplos.** Uno de documentación de
librerías (el único que vale para cualquier stack, porque es la defensa contra la deriva
de sintaxis), uno de errores y uno de analytics — los dos últimos, sustitúyelos por los
de tus proveedores o bórralos. Añadir un MCP solo se justifica cuando la herramienta
tiene un modelo de datos que consultar; si ya tiene una CLI buena, el MCP añade una capa
sin añadir capacidad.

Las CLI se instalan aparte y autentican con la sesión de la persona. **Ninguna guarda su
token en el repositorio.**

## 9. La regla

> **Toda API de terceros va detrás de un adaptador propio.**

Los proveedores suben precios, renuevan líneas de producto y apagan APIs con preaviso
corto. El día que pase, hay que replantear **la integración, no el producto**.

Es la misma regla que [`marco-tecnico-ia.md`](marco-tecnico-ia.md) declara para la capa
de IA y que [`marco-tecnico.md`](marco-tecnico.md) §3.0 exige a un proyecto que aplaza
la elección de stack. Aparece tres veces porque se paga tres veces.

## Cómo se mantiene

- **Todo precio lleva su fuente.** Si no la tiene, va marcado **⚠️ sin verificar**.
- **Una factura real gana al precio de lista**, siempre.
- Se revisa **cada trimestre**, o cuando un proveedor anuncia un cambio. Al hacerlo, se
  actualiza la `Fecha de verificación` de la cabecera — es la que lee
  `.github/scripts/check-costs.sh` para fallar cuando el documento se queda viejo. La
  skill `/actualizar-costos` hace la revisión contra la fuente.
- **Este documento es opcional.** Si el producto no tiene costos propios que
  presupuestar, la poda de `/instanciar` lo borra. Lo que nunca se queda es una foto de
  precios vieja presentada como actual.
