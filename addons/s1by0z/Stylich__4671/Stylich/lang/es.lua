local STLLang = Stylich.Lang
STLLang.msg = STLLang.msg or {}
local m = STLLang.msg

-- Categorías de apariencia
m.CATEGORY_TYPE_COSTUME = 'Traje'
m.CATEGORY_TYPE_POLYMORPH = 'Polimorfia'
m.CATEGORY_TYPE_SKIN = 'Piel'
m.CATEGORY_TYPE_PERSONALITY = 'Personalidad'
m.CATEGORY_TYPE_HAT = 'Sombrero'
m.CATEGORY_TYPE_HAIR = 'Peinado'
m.CATEGORY_TYPE_FACIAL_HAIR_HORNS = 'Vello facial'
m.CATEGORY_TYPE_FACIAL_ACCESSORY = 'Adornos mayores'
m.CATEGORY_TYPE_PIERCING_JEWELRY = 'Adornos menores'
m.CATEGORY_TYPE_HEAD_MARKING = 'Marca facial'
m.CATEGORY_TYPE_BODY_MARKING = 'Marca corporal'
m.CATEGORY_TYPE_VANITY_PET = 'Mascota'
m.CATEGORY_TYPE_MOUNT = 'Montura'
m.GEAR_APPEARANCE = 'Apariencia (arma)'

-- Etiquetas
m.STYLE = 'Estilo'
m.OUTFIT = 'Atuendo'
m.TITLE = 'Título'
m.HOTKEY = 'Atajo'
m.MEMENTO = 'Recuerdo'
m.REVEAL = 'Retraso'
m.COMPANION = 'Compañero'
m.COMPANION_NONE = '- Ninguno -'
m.COMPANION_KEEP = '- No tocar -'
m.WEAPONS = 'Armas'
m.APPLY_SECTION = 'AL APLICAR'
m.OPTIONS = 'Opciones'

-- Listas desplegables
m.SLOT = 'Ranura'
m.HOTKEY_NONE = '- Ninguno -'
m.MEMENTO_NONE = '- Ninguno -'
m.NO_OUTFIT = '- Sin atuendo -'
m.NO_TITLE = '- Sin título -'
m.WEAPON_UNEQUIP = 'Ranura vacía (se desequipará)'
m.WEAPON_NONE = 'Mantener el arma actual (esta ranura no se modifica)'

-- Opciones
m.OPT_SHOW_BUTTON = 'Mostrar el botón flotante'
m.OPT_SHOW_DROPDOWN = 'Mostrar la lista de cambio rápido'
m.OPT_LOCK_BUTTON = 'Bloquear la posición del botón flotante'
m.OPT_PLAY_MEMENTOS = 'Reproducir el recuerdo de entrada al aplicar un estilo'
m.OPT_HIDE_ON_MENUS = 'Ocultar Stylich cuando hay un menú abierto'
m.OPT_CLOSE_COMBAT = 'Cerrar la ventana al entrar en combate'
m.OPT_HELP =
	"|cFFAA33Crear un estilo|r\n"..
	"- Compón tu aspecto en el juego, luego pulsa Actualizar para guardarlo.\n"..
	"- O arrastra un arma desde tu inventario a una ranura de arma.\n"..
	"- Clic derecho en una ranura de arma para alternar: vacía (desequipar) o mantener (deja tu arma).\n"..
	"- Elige un Atuendo, un Título y un Recuerdo de entrada en las listas.\n\n"..
	"|cFFAA33Recuerdo de entrada|r\n"..
	"Al aplicar un estilo, su recuerdo se reproduce para ocultar el cambio: tu nuevo aspecto se revela al terminar la animación. Si el recuerdo aún está en reutilización, el estilo no cambia (para que la revelación siempre ocurra)."

-- Diálogos de confirmación
m.CONFIRM_UPDATE_TITLE = 'Actualizar estilo'
m.CONFIRM_UPDATE_TEXT = "¿Sobrescribir «<<1>>» con tu apariencia actual?"
m.CONFIRM_DELETE_TITLE = 'Eliminar estilo'
m.CONFIRM_DELETE_TEXT = "¿Eliminar el estilo «<<1>>»?"

-- Descripciones emergentes
m.TT_NEW = 'Nuevo estilo'
m.TT_RENAME = 'Renombrar / propiedades'
m.TT_UPDATE = 'Actualizar desde la apariencia actual'
m.TT_APPLY = 'Aplicar estilo'
m.TT_DELETE = 'Eliminar estilo'
m.TT_OPTIONS = 'Opciones'
m.TT_REVEAL = 'Retraso antes de que tu nuevo aspecto aparezca bajo el recuerdo de entrada. Más corto = revelación más rápida; más largo oculta el cambio más tiempo. Ajústalo a la duración de tu recuerdo.'

-- Atajos de teclado
m.BIND_SHOW = 'Abrir/cerrar la ventana'
m.BIND_SLOT = 'Aplicar el estilo de la ranura'

-- Mensajes de chat
m.MSG_NO_STYLE_SLOT = "Stylich: no hay ningún estilo asignado a la ranura <<1>>."
m.MSG_CREATED = "Stylich: «<<1>>» creado."
m.MSG_MEMENTO_COOLDOWN = "Stylich: el recuerdo de entrada no está listo (<<1>>s) - estilo no aplicado."
m.MSG_WEAPON_NOT_FOUND = "Stylich: arma no encontrada: <<1>>."
m.MSG_WEAPON_DUP = "Stylich: esa arma ya está asignada a otra ranura."
m.MSG_WEAPON_ONLY = "Stylich: solo se pueden soltar armas aquí."
m.MSG_NO_SPACE = "Stylich: no hay espacio suficiente en la mochila para desequipar <<1>>."
m.MSG_COMBAT_WEAPONS = "Stylich: no se pueden cambiar armas en combate."
