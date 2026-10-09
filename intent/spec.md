# Spec: claude-orquestador (desde intent.md 2026-10-08)
Estado: aceptado

## Requisitos
- REQ-1 MUST: Un usuario instala la skill `orquestar` y los 5 agentes con los comandos de plugin
  de Claude Code (agregar el marketplace del repo e instalar), sin copiar archivos a mano.
  Origen: Resultado esperado; Cambios 2026-10-08.
- REQ-2 MUST: En una sesión nueva tras instalar, están disponibles `explorador`, `verificador` y
  `mecanico` en la familia `haiku`, y `ejecutor` y `navegador` en `sonnet` con esfuerzo medio,
  con las herramientas y el tope de turnos del archivo corregido. Origen: Restricciones.
- REQ-3 MUST: La skill y los agentes conservan el comportamiento del archivo corregido. Solo
  cambian las versiones de modelo (REQ-4) y los nombres de los workers, para que la skill los
  encuentre instalada como plugin o copiada a mano. Origen: Restricciones; Fuera de alcance,
  "cambiar el comportamiento de los workers".
- REQ-4 MUST: Ningún texto del repo nombra una versión de modelo (por ejemplo "Haiku 4.5"). Los
  modelos se nombran por familia, los costos se comparan de forma relativa y el README enlaza a
  los precios oficiales. Origen: Resultado esperado, "ningún texto depende de un número de
  versión".
- REQ-5 MUST: El README, en español, explica en este orden: qué resuelve, instalación como plugin,
  cómo comprobar que quedó instalado, uso, qué hace cada worker, cuándo conviene delegar,
  actualizar y desinstalar, e instalación manual. Origen: Resultado esperado, "un README en
  español que explique de forma fácil".
- REQ-6 SHOULD: Copiar la skill y los agentes al perfil da la misma funcionalidad que el plugin.
  Origen: Cambios 2026-10-08.
- REQ-7 MUST: `Ranteck/claude-orquestador` es público, con licencia MIT, revisado sin secretos ni
  datos personales, y se crea y se hace push solo con confirmación explícita. Origen:
  Restricciones.
- REQ-8 MUST: El plugin queda instalado desde el repo en `~/.claude` y `~/.claude-personal`.
  Origen: Resultado esperado, "queda instalado en mis dos perfiles".

## Capacidades y escenarios
### Instalar como plugin (REQ-1, REQ-2, REQ-8)
- GIVEN un perfil de Claude Code sin el plugin
- WHEN el usuario corre los comandos del README y abre una sesión nueva
- THEN aparecen la skill y los 5 agentes, cada uno con su familia de modelo, y la validación
  oficial de plugins no informa errores

### Orquestar una tarea (REQ-3)
- GIVEN el plugin instalado y una tarea con 3 o más piezas independientes
- WHEN el usuario invoca la skill o pide "orquestá esto"
- THEN la sesión reparte las piezas entre los workers por su nombre instalado, sin usar
  `general-purpose` ni `Explore`
- GIVEN una tarea que es una sola cadena de pasos dependientes
- WHEN el usuario invoca la skill
- THEN la sesión dice en una línea que la hace directo y no delega

### Instalación manual (REQ-6)
- GIVEN la skill y los agentes copiados al perfil sin plugin
- WHEN el usuario invoca la skill
- THEN la skill encuentra a los workers por su nombre sin prefijo

### Sin versiones de modelo (REQ-4)
- GIVEN el contenido final del repo
- WHEN se buscan nombres de familia seguidos de un número de versión
- THEN no hay coincidencias

### Publicar (REQ-7)
- GIVEN el repo listo localmente
- WHEN no hay confirmación explícita
- THEN no se crea el repo en GitHub ni se hace push

## Concerns
- **Nombres con prefijo:** como plugin, la skill es `/orquestar:orquestar` y los agentes
  `orquestar:explorador`, etc.; copiados a mano, van sin prefijo. La skill debe aceptar ambos.
- **`navegador` depende de Claude in Chrome:** sin la extensión arranca sin herramientas de
  navegador. Falta verificar que un agente de plugin acceda a herramientas MCP configuradas.
- **Solo lectura por instrucción:** que `explorador` y `verificador` usen Bash solo para leer lo
  pide el prompt, no lo garantiza Claude Code. Endurecerlo queda fuera de alcance.
- **graph-engineer:** mención propia de mi setup; queda como nota condicional.
- **Ahorro sin medir:** el README lo aclara y sugiere `/usage`.
