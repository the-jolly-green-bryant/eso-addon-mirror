-- Translated by: Cisneros

local PAC = PersonalAssistant.Constants
local PACOStrings = {
    -- =================================================================================================================
    -- Textos específicos del idioma que necesitan ser traducidos --

    -- =================================================================================================================
    -- == TEXTOS DE MENÚ/PANEL == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- Menú de PAConsume --
    SI_PA_MENU_CONSUME_DESCRIPTION = "PAConsume puede aplicar veneno, o consumir comida/bebida y pergaminos de EXP",

    -- veneno automático --
    SI_PA_MENU_CONSUME_POISON_HEADER = "Aplicar veneno automáticamente",
    SI_PA_MENU_CONSUME_POISON_ENABLE = "Habilitar auto aplicado de veneno ",
    SI_PA_MENU_CONSUME_POISON_ENABLE_T = "Aplica automáticamente tu veneno más acumulado después del combate si no queda más en el arma",
    SI_PA_MENU_CONSUME_POISON_SMALL_STACKS_FIRST = "Use small stacks first",
    SI_PA_MENU_CONSUME_POISON_SMALL_STACKS_FIRST_T = "Use small stacks of poison first in order to free inventory slots",
    
    -- auto potion --
    SI_PA_MENU_CONSUME_POTION_HEADER = "Auto Slot Potion",
    SI_PA_MENU_CONSUME_POTION_ENABLE = "Enable Auto Slot Potion",
    SI_PA_MENU_CONSUME_POTION_ENABLE_T = "Auto slot your most stacked potion after combat if there is no more on the selected quickslot",
    SI_PA_MENU_CONSUME_POTION_SMALL_STACKS_FIRST = "Use small stacks first",
    SI_PA_MENU_CONSUME_POTION_SMALL_STACKS_FIRST_T = "Use small stacks of potion first in order to free inventory slots",

    -- consumo automático de comida y EXP --
    SI_PA_MENU_CONSUME_FOOD_HEADER = "Consumir comida/bebida automáticamente",
    SI_PA_MENU_CONSUME_EXP_HEADER = "Consumir pergaminos de EXP automáticamente",
    SI_PA_MENU_CONSUME_CURRENT_FOOD_BUFF = "Buff de comida actual para este personaje: ",
    SI_PA_MENU_CONSUME_CURRENT_EXP_BUFF = "Buff de EXP actual para este personaje: ",
    SI_PA_MENU_CONSUME_LABEL_ON = "Consumir automáticamente",
    SI_PA_MENU_CONSUME_LABEL_OFF = "Dejar de consumir automáticamente",
    SI_PA_MENU_CONSUME_USE_NUMBER_FOOD = "Tiempo de anticipación (segundos antes)",
    SI_PA_MENU_CONSUME_USE_NUMBER_FOOD_T = "Segundos para consumir el buff de comida antes de que expire el buff actual. Usa un número entre 0 y 600 segundos para cambiar el tiempo de anticipación.",
    SI_PA_MENU_CONSUME_USE_NUMBER_EXP = "Tiempo de anticipación (segundos después)",
    SI_PA_MENU_CONSUME_USE_NUMBER_EXP_T = "Segundos para consumir el buff de EXP después de que expire el buff actual. Usa un número entre 0 y 600 segundos para cambiar el tiempo de anticipación.",
    SI_PA_MENU_CONSUME_TURN_OFF_FOOD = "Suspender",
    SI_PA_MENU_CONSUME_TURN_OFF_FOOD_T = "Deja de consumir esa comida/bebida por ahora",
    SI_PA_MENU_CONSUME_TURN_OFF_EXP = "Suspender",
    SI_PA_MENU_CONSUME_TURN_OFF_EXP_T = "Deja de consumir ese buff de EXP por ahora",

    -- =================================================================================================================
    -- == SALIDAS DE CHAT == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAConsume veneno --
    SI_PA_CHAT_CONSUME_POISON_MAIN = "El arma principal ha sido impregnada con ",
    SI_PA_CHAT_CONSUME_POISON_BACKUP = "El arma secundaria ha sido impregnada con ",
    
    -- PAConsume potion--
    SI_PA_CHAT_CONSUME_POTION = "Current Quickslot has been equiped with ",

    -- PAConsume comida y EXP --
    SI_PA_CHAT_CONSUME_NO_FOOD = "No se ha seleccionado ninguna comida todavía. Abre el inventario, haz clic derecho en la pila de comida o bebida que desees y elige la opción consumir automáticamente.",
    SI_PA_CHAT_CONSUME_AUTO_EATING_OFF_BUT = "El consumo automático de comida está desactivado. Pero has seleccionado <<1>> como tu comida preferida.",
    SI_PA_CHAT_CONSUME_TO_ENABLE_EATING = "Para habilitar el consumo automático de comida para este personaje, abre el inventario, haz clic derecho en la comida o bebida que desees y elige la opción consumir automáticamente.",
    SI_PA_CHAT_CONSUME_LOOKS_LIKE = "Parece que <<1>> está en el menú.",
    SI_PA_CHAT_CONSUME_THIS_FOOD_WILL_BE_MINUTES = "Esto se consumirá <<1[cuando/$d minuto antes/$d minutos antes]>> de que expire tu comida actual.",
    SI_PA_CHAT_CONSUME_THIS_FOOD_WILL_BE_SECONDS = "Esto se consumirá <<1[cuando/$d segundo antes/$d segundos antes]>> de que expire tu comida actual.",
    SI_PA_CHAT_CONSUME_YOU_HAVE_ONLY = "Solo te quedan <<1>> en tu bolsa.", -- "Te quedan <<1[$d/solo $d/solo $d]>> en tu bolsa."
    SI_PA_CHAT_CONSUME_YOU_HAVE = "Te quedan <<1>> en tu bolsa.",
    SI_PA_CHAT_CONSUME_WISH_STOP_EATING = "Si deseas detener el consumo automático de comida para este personaje, usa el menú de PAconsume.",

    SI_PA_CHAT_CONSUME_NO_EXP = "No se ha seleccionado ningún buff de EXP todavía. Abre el inventario, haz clic derecho en la pila de pergaminos de EXP que desees y elige la opción consumir automáticamente.",
    SI_PA_CHAT_CONSUME_AUTO_EXPING_OFF_BUT = "El consumo automático de buffs de EXP está desactivado. Pero has seleccionado <<1>> como tu buff de EXP preferido.",
    SI_PA_CHAT_CONSUME_TO_ENABLE_EXPING = "Para habilitar el consumo automático de buffs de EXP para este personaje, abre el inventario, haz clic derecho en el pergamino de EXP que desees y elige la opción consumir automáticamente.",
    SI_PA_CHAT_CONSUME_THIS_EXP_WILL_BE_MINUTES = "Esto se consumirá <<1[cuando/$d minuto después/$d minutos después]>> de que expire tu buff de EXP actual.",
    SI_PA_CHAT_CONSUME_THIS_EXP_WILL_BE_SECONDS = "Esto se consumirá <<1[cuando/$d segundo después/$d segundos después]>> de que expire tu buff de EXP actual.",
    SI_PA_CHAT_CONSUME_WISH_STOP_EXPING = "Si deseas detener el consumo automático de buffs de EXP para este personaje, usa el menú de PAconsume.",

    SI_PA_CHAT_CONSUME_FOOD_WILL_BE_CONSUMED = "La comida se consumirá <<1>> segundos antes de que expire la comida actual.",
    SI_PA_CHAT_CONSUME_EXP_WILL_BE_CONSUMED = "El buff de EXP se consumirá <<1>> segundos después de que expire el buff de EXP actual.",

    SI_PA_CHAT_CONSUME_HAS_BEEN_AUTOMATICALLY_CONSUMED = " ha sido consumido automáticamente.",
    SI_PA_CHAT_CONSUME_BUT_HAVE_ZERO = "Has configurado <<1>> para consumir automáticamente pero tienes 0 en tu bolsa.",

    SI_PA_CHAT_CONSUME_FOOD_EXPIRE_SECONDS = "Tu comida actual expirará en <<1[$d segundos./$d segundo./$d segundos.]>>",
    SI_PA_CHAT_CONSUME_FOOD_EXPIRE_MINUTES = "Tu comida actual expirará en <<1[$d minutos./$d minuto./$d minutos.]>>",
    SI_PA_CHAT_CONSUME_EXP_EXPIRE_SECONDS = "Tu buff de EXP actual expirará en <<1[$d segundos./$d segundo./$d segundos.]>>",
    SI_PA_CHAT_CONSUME_EXP_EXPIRE_MINUTES = "Tu buff de EXP actual expirará en <<1[$d minutos./$d minuto./$d minutos.]>>",
}

for key, value in pairs(PACOStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end

local PACOGenericStrings = {
    -- =================================================================================================================
    -- Textos independientes del idioma (no necesitan ser traducidos/copiados a otros idiomas) --

    -- =================================================================================================================
    -- == SALIDAS DE CHAT == --
    -- -----------------------------------------------------------------------------------------------------------------
    --SI_PA_CHAT_Consume_CHARGE_WEAPON = "%s (%d%% --> %d%%) - %s",
}

for key, value in pairs(PACOGenericStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end
