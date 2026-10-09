# Intención: claude-orquestador
Autor: Denis · Estado: aceptado · Fecha: 2026-10-08

## Problema
En Claude Code, los subagentes `Explore` y `general-purpose` corren con el mismo modelo que la
sesión (Opus), así que delegar no ahorra tokens. La skill `orquestar` y sus 5 workers con modelo
asignado (Haiku y Sonnet) resuelven eso, pero hoy solo existen como un archivo en `Downloads`
(`orquestar-equipo.corregido.md`): no están instalados ni publicados. Además, el texto nombra
versiones de modelo concretas (Haiku 4.5, Sonnet 5.5, Opus 5.5) que ya quedaron viejas o van a
quedar viejas.

## Resultado esperado
- Un repo público en mi GitHub (`Ranteck/claude-orquestador`) con la skill `orquestar` y los
  agentes `explorador`, `verificador`, `mecanico`, `ejecutor` y `navegador`.
- Un README en español que explique de forma fácil cómo instalarla y usarla.
- Ningún texto depende de un número de versión de modelo: solo alias por familia (`haiku`,
  `sonnet`, `opus`), que siguen valiendo cuando salgan modelos nuevos.
- Queda instalado en mis dos perfiles (`~/.claude` y `~/.claude-personal`) desde el repo.

## Usuarios y sistemas afectados
Yo y cualquiera que use Claude Code y quiera gastar menos en tareas con muchas piezas
independientes. Se instala en `skills/` y `agents/` del perfil de Claude Code que elija cada uno.

## Restricciones
- El contenido de la skill y de los agentes es el del archivo corregido (ya pasó una revisión
  adversarial con Codex); el único cambio de contenido es quitar los números de versión de modelo.
- Repo público con licencia MIT, sin secretos ni datos personales.
- Crear el repo y hacer push solo con mi confirmación explícita.

## Fuera de alcance
- Cambiar el comportamiento de los workers o agregar workers nuevos.
- Medir el ahorro real con un benchmark.
- Modificar graph-engineer.

## Preguntas abiertas

## Cambios
- 2026-10-08: se resolvió la forma de instalación. Se distribuye como plugin de Claude Code
  (repo `claude-orquestador`, plugin `orquestar`), y el README documenta la copia manual de
  `skills/` y `agents/` como alternativa. Motivo: una skill sola no puede traer los agentes, que
  son los que llevan el modelo barato. Aprobado por Denis.
