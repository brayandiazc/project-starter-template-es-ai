---
name: configurar-repo
description: Configura el repositorio de GitHub de punta a punta con gh — descripción, topics, labels, rama develop, protección de ramas, merge settings y metadatos — a partir de la definición del producto. Úsalo al crear el repo de un proyecto nuevo o cuando haya que poner en orden uno existente (p. ej. "configura el repo", "prepara el repositorio en GitHub", "pon los labels y la protección de ramas").
---

<!-- Skill de ejemplo de la plantilla — adáptalo o elimínalo según tu proyecto. -->

Deja el repositorio de GitHub operativo y coherente con la plantilla. Requiere `gh`
autenticado; verifica con `gh auth status` antes de empezar.

## Paso 1 — Contexto

Lee `README.md` y `docs/product/product-definition.md` para derivar descripción y
topics. Detecta el repo actual (`gh repo view`). Si no existe remoto, pregunta si
crearlo (`gh repo create` — público/privado lo decide la persona).

## Paso 2 — Metadatos

- **Descripción**: una frase desde la visión del producto (`gh repo edit
--description`). **Homepage**: la URL del producto si existe.
- **Topics**: 3–6 derivados del stack y el dominio (`gh repo edit --add-topic`).

## Paso 3 — Labels

Ejecuta `.github/scripts/setup-labels.sh` (usa `.github/LABELS.md` como catálogo).

## Paso 4 — Ramas y flujo

- Crea `develop` desde `main` si no existe, publícala y **establécela como rama por
  defecto del repo** (`gh api -X PATCH repos/{owner}/{repo} -f default_branch=develop`)
  — no es opcional: la rama por defecto es a donde apuntan los PRs nuevos y los de
  Dependabot; si queda `main`, el Git Flow se rompe (`CONTRIBUTING.md`).
- Verifica que `.github/dependabot.yml` tenga `target-branch: "develop"` en cada
  ecosistema.
- Protección de `main` (y `develop` si la persona quiere): PR obligatorio, checks de
  CI requeridos (`quality`, `secret-scan`), sin force-push, conversaciones resueltas.
  Aplica vía `gh api repos/{owner}/{repo}/branches/{branch}/protection` y muestra el
  JSON antes de aplicar.

## Paso 5 — Ajustes de merge e higiene

- Squash merge habilitado, borrar ramas al mergear, issues habilitados; template de
  PR/issues ya vienen del repo.
- Verifica que Actions esté habilitado y que los workflows activos (`quality.yml`,
  `secret-scan.yml`) corran.

## Paso 6 — Cierre

Resume qué quedó configurado (con los comandos ejecutados), qué requirió permisos que
no tienes (p. ej. protección de ramas en repos personales free) y regístralo en el
CHANGELOG bajo Unreleased.

Reglas: muestra cada comando destructivo o de configuración antes de ejecutarlo la
primera vez; NO borres labels/ramas existentes sin confirmar; NO toques repos que no
sean el del proyecto actual.
