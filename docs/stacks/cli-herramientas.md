# Preset: CLI / herramienta interna

> Herramientas de uso propio o interno que no son web: generadores de archivos
> (presentaciones, PDFs, reportes), scripts de automatización, procesadores de datos,
> utilidades de terminal. Aquí el "hosting" es tu máquina — la infraestructura pesada
> del catálogo no aplica.

## Stack (default: Python)

Python es el default porque su ecosistema de manipulación de archivos y datos no tiene
rival (pptx, docx, xlsx, PDF, imágenes, pandas).

| Capa               | Elección                                  | Por qué                                              |
| ------------------ | ----------------------------------------- | ---------------------------------------------------- |
| Lenguaje / gestor  | Python 3.12+ con **uv**                   | uv gestiona todo: venv, deps, lockfile, publicación  |
| CLI framework      | **Typer**                                 | Comandos y flags tipados con casi cero código        |
| Salida en terminal | **Rich**                                  | Tablas, progreso, colores — UX de CLI decente gratis |
| Presentaciones     | python-pptx                               | Genera .pptx programáticamente                       |
| Documentos         | python-docx / WeasyPrint (PDF desde HTML) | Word y PDF con plantillas                            |
| Hojas de cálculo   | openpyxl / pandas                         | Leer, transformar y escribir datos                   |
| Config del usuario | archivo TOML en `~/.config/<tool>/`       | Estándar XDG, legible y editable                     |
| IA                 | LiteLLM / Pydantic AI                     | Capa agnóstica (ver catálogo)                        |
| Tests              | pytest                                    | Estándar                                             |
| Lint / formato     | Ruff                                      | Lint + formato en una herramienta                    |

**Alternativas** (elige por afinidad con el proyecto, no por moda):

- **Ruby + Thor**: si la herramienta orbita un proyecto Rails y quieres un solo lenguaje.
- **Bun/TS**: si la herramienta manipula APIs web o quieres compilar un binario único
  (`bun build --compile`).

## Operación (la versión ligera de los transversales)

| Tema          | Cómo se resuelve en una CLI                                                                                                    |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Distribución  | `uv tool install` desde el repo Git; GitHub Releases con tag SemVer para versiones                                             |
| Actualización | `uv tool upgrade <tool>`; el CHANGELOG dice qué cambió                                                                         |
| Credenciales  | **Bitwarden CLI** (`bw get` / `bws`) o variables en `~/.config/<tool>/.env` — nunca hardcodeadas (ver catálogo → Credenciales) |
| Logs          | Archivo local (`~/.local/state/<tool>/log`) con `--verbose` para depurar                                                       |
| Errores       | Mensajes claros con Rich + exit codes correctos; Sentry solo si la usan terceros                                               |
| Métricas      | Normalmente ninguna. Si la comparte un equipo, un contador simple basta                                                        |
| Backups       | La herramienta no guarda estado valioso; los archivos generados van a carpetas del usuario                                     |
| CI            | GitHub Actions: Ruff + pytest en cada PR; release al taguear                                                                   |

## Reglas del preset

- **Entrada/salida por archivos y stdout** — componible con pipes y otras herramientas.
- Un comando = una acción; `--help` útil es parte del producto.
- Idempotente cuando sea posible: correrla dos veces no rompe nada.
- Si la herramienta crece hacia "esto lo debería usar más gente vía web", eso es una
  señal de migrar a [`web-fullstack.md`](web-fullstack.md) reutilizando el core como gema/paquete.

## Costo estimado

- 0 USD/mes. Es el preset más barato del catálogo.

## Arranque

```bash
uv init mi-tool --package && cd mi-tool
uv add typer rich python-pptx
uv run mi-tool --help
```
