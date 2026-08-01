--                v 1.8.3               --
--[[
   à : \195\160    è : \195\168    ì : \195\172    ò : \195\178    ù : \195\185
   á : \195\161    é : \195\169    í : \195\173    ó : \195\179    ú : \195\186
   â : \195\162    ê : \195\170    î : \195\174    ô : \195\180    û : \195\187
   ã : \195\163    ë : \195\171    ï : \195\175    õ : \195\181    ü : \195\188
   ä : \195\164                    ñ : \195\177    ö : \195\182
   æ : \195\166                                    ø : \195\184
   ç : \195\167                                    œ : \197\147
   Ä : \195\132   Ö : \195\150   Ü : \195\156    ß : \195\159
]]

TimEmote = TimEmote or {}
local TE = TimEmote
TE.Lang = TE.Lang or {}

TE.Lang["es"] = {
		LOCALE = "ES",

		Settings_control = "Ajustes",
		Settings_title1 = "Ventana móvil",
		Settings_description1 = "Permite mover la ventana de TimEmote.",
		Settings_displaySize = "Tamaño de interfaz",
		Settings_displaySizeTip = "Cambia la fuente, la altura y el ancho de las listas de emotes.",
		DisplaySize_compact = "Compacto (14)",
		DisplaySize_normal = "Normal (15)",
		DisplaySize_large = "Grande (16)",
		Settings_contrast = "Contraste de fondo",
		Settings_contrastTip = "Controla la intensidad del fondo de los encabezados y las listas de emotes.",
		Settings_title3 = "Opacidad",
		Settings_description3 = "Cambia la opacidad de la ventana de TimEmote.",
		Settings_warning = "Recarga la interfaz para aplicar este cambio.",
		Settings_group = "Nombres de grupos",
		Settings_groupItem = "Grupo",
		Settings_groupItemTip = "Nombre de este grupo",
		Settings_groupNoname = "Sin nombre",
		Settings_groupDefault = "Favoritos",
		Settings_groupNewBtn = "Nuevo",
		Settings_groupNewBtnTip = "Añadir un grupo nuevo",
		Settings_groupDeleteBtn = "Eliminar",
		Settings_groupDeleteBtnTip = "Eliminar este grupo",
		Settings_groupDeleteWarning = "Este grupo y todos sus favoritos serán eliminados.",
		UI_list = "Lista",
		Message_notSelGroup = "Selecciona primero un grupo con un clic izquierdo en su encabezado.",
		Message_noEmote = "No hay ningún emote disponible en este grupo.",
		Message_lastGroup = "Debe conservarse al menos un grupo.",
		Tooltip_playRandom = "Reproducir un emote aleatorio",
		Tooltip_moveDown = "Mover hacia abajo",
		Tooltip_moveUp = "Mover hacia arriba",
		Tooltip_listHeader = "Emote:\nClic izquierdo: reproducir\nMayús + clic izquierdo: añadir/quitar del grupo activo\nDoble clic: color siguiente",
		Tooltip_groupHeader = "Encabezado:\nClic izquierdo: activar grupo\n--------------------\nEmote:\nClic izquierdo: reproducir\nMayús + clic izquierdo: quitar\nDoble clic: color siguiente",
	}
