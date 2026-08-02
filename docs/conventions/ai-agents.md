# Convención de agentes de IA

> Cómo trabajamos con agentes de codificación con IA en [NOMBRE_DEL_PROYECTO].
> **Última actualización**: [FECHA]

## Fuente de verdad

- [`AGENTS.md`](../../AGENTS.md) es el archivo de instrucciones canónico para cualquier agente.
- [`CLAUDE.md`](../../CLAUDE.md) es un puente de una línea que importa `AGENTS.md`
  (Claude Code lee `CLAUDE.md`; otras herramientas leen `AGENTS.md`).
- Los [subagentes](../../.claude/agents) y las [skills](../../.claude/skills) reutilizables
  están versionados y se comparten con el equipo.

## Qué delegamos a la IA

- ✅ Redactar código, pruebas y documentación; explorar el código; revisar diffs;
  proponer diseños y ADRs; refactorizaciones rutinarias.
- ⚠️ Cualquier cosa que toque autenticación, criptografía, pagos o migraciones de datos →
  requiere escrutinio humano adicional.
- ❌ Aprobación final. **Una persona es responsable de cada merge.**

## Reglas

- **La revisión humana es obligatoria.** El código generado por IA pasa por el mismo proceso de PR y
  revisión que cualquier otro cambio ([`../../CONTRIBUTING.md`](../../CONTRIBUTING.md)).
- **Nunca le des secretos a un agente** (claves, tokens, `.env` real, datos de clientes).
  Consulta [`secrets.md`](secrets.md) y [`../../SECURITY.md`](../../SECURITY.md).
- **Los agentes se remiten a la documentación.** Las convenciones en `docs/` prevalecen sobre los valores
  por defecto del modelo.
- **Verifica antes de confiar.** Las dependencias, APIs y rutas de archivo que cite un agente
  deben comprobarse — los agentes pueden alucinar.
- **Mantén los cambios acotados.** Un cambio lógico por PR; sin reformateos no relacionados.

## Atribución

Marca los commits asistidos por IA con un trailer para que la autoría sea transparente:

```
Co-Authored-By: [HERRAMIENTA_IA] <[EMAIL_HERRAMIENTA_IA]>
```

## Memoria del agente vs. documentación

Algunas herramientas mantienen una **memoria persistente** por proyecto (p. ej. la
auto-memoria de Claude Code). Úsala solo para lo personal y efímero (preferencias,
correcciones recurrentes) y pódala con frecuencia. Todo conocimiento **duradero o de
equipo** — decisiones, convenciones, contexto del dominio — pertenece al repositorio:
`docs/`, los ADRs de [`../decisions/`](../decisions/README.md) y el `CHANGELOG.md`.
Si un agente "recuerda" algo que el equipo necesita saber, ese recuerdo está en el
lugar equivocado: conviértelo en documentación versionada.

## Cambios guiados por especificaciones (obligatorio)

**Toda funcionalidad o corrección (`feat/*`, `fix/*`) nace de una especificación** en
[`../../specs/`](../../specs/README.md): una propuesta breve, una lista de tareas y
una nota de diseño. Esto les da a los agentes (y a las personas) un objetivo claro y
un punto de revisión. La regla la garantiza de forma determinista el hook
`spec-guardrails.sh` (ver abajo): en una rama `feat/*` o `fix/*` no se puede editar
código si no existe `specs/NNNN-<slug-de-la-rama>/`. Los cambios de documentación
pura van en ramas `docs/*` y no requieren spec.

## Servidores MCP (opcional)

Esta plantilla incluye un [`.mcp.json.example`](../../.mcp.json.example) con un
servidor recomendado y agnóstico al stack:

- **Context7** (Upstash) — obtiene documentación de librerías **actualizada y por
  versión**, para que los agentes no dependan de conocimiento de API obsoleto. No
  requiere API key.

Para activarlo, copia el archivo y reinicia Claude Code:

```bash
cp .mcp.json.example .mcp.json
```

Claude Code pide aprobación antes de usar cualquier servidor MCP del proyecto.

- **No** agregues servidores MCP para archivos, búsqueda o web — las herramientas
  integradas de Claude Code ya lo cubren.
- **Nunca** pongas secretos en `.mcp.json`. Referencia variables de entorno (p. ej.
  `${GITHUB_TOKEN}`) y documéntalas en `.env.example` (ver [`secrets.md`](secrets.md)).
- Agrega servidores específicos de tu proyecto (GitHub, Playwright, un MCP de base
  de datos, etc.) según lo necesite tu stack.

### MCP de infraestructura (DNS, CDN, VPS)

Recomendaciones probadas para la capa de despliegue (ver `docs/conventions/deploy.md`):

- **Cloudflare** (DNS, Workers, R2, observabilidad) — usa el **plugin oficial de
  Cloudflare para Claude Code** (`cloudflare-api`, `cloudflare-bindings`,
  `cloudflare-observability`…). Es la pieza más útil del stack: cubre DNS y edge
  aunque el hosting esté en otro proveedor.
- **Hetzner (VPS)** — no existe MCP oficial. Para **provisionar** (evento raro:
  crear el servidor, firewall, redes) las opciones agente-friendly son la CLI oficial
  `hcloud` vía Bash, o el MCP comunitario más completo,
  [`@lazyants/hetzner-mcp-server`](https://github.com/lazyants/hetzner-mcp-server)
  (185 tools, incluye DNS y Storage Boxes): se añade con
  `claude mcp add hetzner --env HETZNER_API_TOKEN=xxx -- npx -y @lazyants/hetzner-mcp-server`.
  Usa un token **read-only** salvo durante el aprovisionamiento.
- **Administración del VPS día a día** (deploy, logs, docker, systemd) — **sin MCP**:
  `ssh` directo por Bash (con claves y `~/.ssh/config`) y la herramienta de deploy del
  **preset elegido en `docs/stacks/`** (p. ej. Kamal en Rails, Wrangler en Workers,
  `flyctl` o Docker Compose en otros) — la regla es del producto, no del stack.
  Los MCP de SSH solo tienen sentido en clientes sin shell (Claude Desktop/web).
- **Si se prefiere MCP oficial de primera clase con VPS**: DigitalOcean es el único
  proveedor con Droplets + MCP oficial maduro y hospedado (~2× el precio de Hetzner).

## Guardrails deterministas (activos por defecto)

Las reglas de [`AGENTS.md`](../../AGENTS.md) le dicen al agente qué **debería** hacer, pero
no lo obligan. Para una garantía dura, esta plantilla trae tres hooks que
**bloquean de forma determinista** — el agente no puede saltárselos — y vienen
**activados en `.claude/settings.json`**:

- [`.claude/hooks/git-guardrails.sh`](../../.claude/hooks/git-guardrails.sh) — bloquea
  las acciones que rompen el branching de [`../../CONTRIBUTING.md`](../../CONTRIBUTING.md):
  commits, merges locales o push directos a `main`/`develop`, force-push a ramas
  compartidas, y **crear ramas de trabajo desde `main`** (deben nacer de `develop`;
  únicas excepciones: crear la propia `develop` y las `hotfix/*`). Cubre también
  `git -C <ruta>` y comandos encadenados con `&&`.
- [`.claude/hooks/secret-guardrails.sh`](../../.claude/hooks/secret-guardrails.sh) —
  bloquea escrituras del agente sobre archivos de secretos: el `.env` real (y variantes
  como `.env.local`) y llaves privadas (`*.pem`, `id_rsa`…). `.env.example` sí se puede
  editar: es el contrato, sin valores reales.
- [`.claude/hooks/spec-guardrails.sh`](../../.claude/hooks/spec-guardrails.sh) — hace
  cumplir "sin spec no hay cambio": en ramas `feat/*`/`fix/*` bloquea la edición de
  código mientras no exista `specs/NNNN-<slug-de-la-rama>/`. Documentación
  (`docs/`, `*.md`), las specs mismas y el tooling (`.claude/`, `.github/`) quedan exentos.

Para desactivar alguno (no recomendado), elimina su bloque de `hooks.PreToolUse` en
`.claude/settings.json`. Requieren `python3` (para leer el evento). Los tres scripts
fallan _abiertos_: ante la duda permiten, para no trabar el flujo. Sus casos cubiertos
están probados en `.github/scripts/tests/run-tests.sh` (corre en CI).
