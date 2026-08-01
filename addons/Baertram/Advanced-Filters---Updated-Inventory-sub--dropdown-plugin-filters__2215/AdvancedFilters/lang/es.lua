local util = AdvancedFilters.util
local enStrings = AdvancedFilters.ENstrings

local afPrefixNormal    = enStrings.AFPREFIXNORMAL
local afPrefixError     = string.format(enStrings.AFPREFIX, " ERROR")

--Provided 2020-03-20 by Inval1d @www.esoui.com. ¡Gracias!
local strings = {
    --SHARED
    All                                       = "Todo",

    --WEAPON
    OneHand                                   = "A una mano",
    TwoHand                                   = "A dos manos",
    DestructionStaff                          = "Vara de destrucción",

    TwoHandAxe                                = "Hacha de batalla",
    TwoHandSword                              = "Mandoble",
    TwoHandHammer                             = "Mazo",

    --Clothing = ,
    Shield                                    = "Escudo",
    Jewelry                                   = "Joyería",
    Vanity                                    = "Varios",

    Head                                      = "Cabeza",
    Chest                                     = "Pecho",
    Shoulders                                 = "Hombros",
    Hand                                      = "Manos",
    Waist                                     = "Cintura",
    Legs                                      = "Piernas",
    Feet                                      = "Pies",
    Ring                                      = "Anillos",
    Neck                                      = "Collar",

    Repair                                    = "Reparación",

    --MATERIALS
    Blacksmithing                             = "Herrería",
    Clothier                                  = "Sastrería",
    Woodworking                               = "Carpintería",
    Alchemy                                   = "Alquimia",
    Enchanting                                = "Encantamiento",
    Provisioning                              = "Cocina",

    --MISCELLANEOUS
    Glyphs                                    = "Glifos",
    Bait                                      = "Cebo",

    --DROPDOWN CONTEXT MENU
    ResetToAll                                = "Mostrar todo",
    InvertDropdownFilter                      = "Invertir filtro: %s",

    --LAM settings menu
    lamDescription                            = "Muestra filtros adicionales en el inventario para separar objetos por su tipo.",
    lamHideItemCount                          = "Ocultar cantidad de objetos",
    lamHideItemCountTT                        = "Oculta la cantidad de objetos, mostrada entre una \'(...)\', al fondo de las ventanas de inventario.",
    lamHideItemCountColor                     = "Color de cantidad de objetos",
    lamHideItemCountColorTT                   = "Selecciona el color del indicador de cantidad al fondo del inventario.",
    lamHideSubFilterLabel                     = "Ocultar título en subfiltros",
    lamHideSubFilterLabelTT                   = "Oculta el título de los subfiltros en la parte superior de las ventanas de inventario (a la izquierda de los botones de selección subfiltro).",
    lamGrayOutSubFiltersWithNoItems           = "Desactivar los subfiltros sin objetos",
    lamGrayOutSubFiltersWithNoItemsTT         = "Desactiva los botones de subfiltros que no contengan ningún objeto.",
    lamShowIconsInFilterDropdowns             = "Mostrar íconos en la lista deplegable",
    lamShowIconsInFilterDropdownsTT           = "Muestra u oculta los íconos para los filtros en las listas desplegables.",
    lamRememberFilterDropdownsLastSelection   = "Recordar el último filtro seleccionado",
    lamRememberFilterDropdownsLastSelectionTT = "Recuerda el último filtro seleccionado de la lista desplegable en cada subfiltro y panel de filtro (inventario, correo, talleres, etc...) y volverá a aplicar este filtro en la lista desplegable si vuelves a este panel de filtros o subfiltro.\n¡Siempre OLVIDARÁ la selección al salir del juego o al recargar la interfaz!",
    lamShowDropdownSelectedReminderAnimation  = "Resaltar el último filtro seleccionado",
    lamShowDropdownSelectedReminderAnimationTT= "Aplicará un brillo en las cajas de las listas desplegables si su valor no es \'".. util.Localize(SI_ITEMFILTERTYPE0) .. "\' en un subfiltro.",
    lamShowDropdownLastSelectedEntries		  = "Mostrar historial de filtros en menú contextual",
    lamShowDropdownLastSelectedEntriesTT	  = "Mostrará una lista de los últimos 10 filtros seleccionados de las listas desplegables debajo de las opciones comunes del menú contextual. ¡Haz clic en una opción del historial para seleccionarlo una vez más (siempre que la lista desplegable del subfiltro actual tenga dicha opción disponible, ya que el historial incluye todos los subfiltros)!",
	lamDebugOutput                            = "Modo depuración",
    lamDebugSpamOutput                        = "Spam de depuración",

    --Error messages
    errorCheckChatPlease                      = afPrefixError .. "¡Por favor lee el mensaje de error en el chat!",
    errorLibraryMissing     = afPrefixError .. "La biblioteca \'%s\' no se ha cargado. ¡Es requerida para la correcta función de este addon!",
    errorWhatToDo1          = "!> Por favor responde las preguntas y envía las respuestas (y si existe: las variantes en las líneas comenzando a partir del -> al final de las preguntas) a la sección de comentarios del addon AdvancedFilters en @www.esoui.com:\nhttps://bit.ly/2lSbb2A",
    errorWhatToDo2          = "1) ¿Qué hiciste?\n2)¿Dónde lo hiciste?\n3)¿Probaste si este error ocurría con sólo AdvancedFilters y sus bibliotecas activadas (¡Por favor, inténtalo!)?\n4)Si el error ocurre con otros addons activos: ¿Qué otros addons estabas usando cuando ocurrió el error? ¿Sabes con exactitud qué addon es el que causa el error?",

    --Errors because of other addons
    errorOtherAddonsMulticraft = afPrefixError .. "Hay otro addon que altera \'" .. afPrefixNormal .. "\' -> ¡POR FAVOR, DESACTIVA EL ADDON: \'MultiCraft\'!",
    errorOtherAddonsMulticraftLong = "¡POR FAVOR, DESACTIVA EL ADDON \'MultiCraft\'! " .. afPrefixNormal .. " no funcionará mientras el addon esté activado.  ¡\'Multicraft\' ha sido reemplazado por la función de fabricación en masa de ZOS, por lo que ya no es necesario ese addon!"
}
setmetatable(strings, {__index = enStrings})

local light = " (ligera)"
local medium = " (media)"
strings.Head_Light = strings.Head .. light
strings.Chest_Light = strings.Chest .. light
strings.Shoulders_Light = strings.Shoulders .. light
strings.Hand_Light = strings.Hand .. light
strings.Waist_Light = strings.Waist .. light
strings.Legs_Light = strings.Legs .. light
strings.Feet_Light = strings.Feet .. light
strings.Head_Light = strings.Head .. medium
strings.Chest_Medium = strings.Chest .. medium
strings.Shoulders_Medium = strings.Shoulders .. medium
strings.Hand_Medium = strings.Hand .. medium
strings.Waist_Medium = strings.Waist .. medium
strings.Legs_Medium = strings.Legs .. medium
strings.Feet_Medium = strings.Feet .. medium
local ringStr = " (" .. strings.Ring .. ")"
strings.Arcane_Ring = strings.Arcane .. ringStr
strings.Bloodthirsty_Ring = strings.Bloodthirsty .. ringStr
strings.Harmony_Ring = strings.Harmony .. ringStr
strings.Healthy_Ring = strings.Healthy .. ringStr
strings.Infused_Ring = strings.Infused .. ringStr
strings.Intricate_Ring = strings.Intricate .. ringStr
strings.Ornate_Ring = strings.Ornate .. ringStr
strings.Robust_Ring = strings.Robust .. ringStr
strings.Swift_Ring = strings.Swift .. ringStr
strings.Triune_Ring = strings.Triune .. ringStr
local neckStr = " (" .. strings.Neck .. ")"
strings.Arcane_Neck = strings.Arcane .. neckStr
strings.Bloodthirsty_Neck = strings.Bloodthirsty .. neckStr
strings.Harmony_Neck = strings.Harmony .. neckStr
strings.Healthy_Neck = strings.Healthy .. neckStr
strings.Infused_Neck = strings.Infused .. neckStr
strings.Intricate_Neck = strings.Intricate .. neckStr
strings.Ornate_Neck = strings.Ornate .. neckStr
strings.Robust_Neck = strings.Robust .. neckStr
strings.Swift_Neck = strings.Swift .. neckStr
strings.Triune_Neck = strings.Triune .. neckStr

setmetatable(strings, {__index = enStrings})
AdvancedFilters.strings = strings