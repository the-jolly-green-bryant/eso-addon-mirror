if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop


------------------------------------------------------------------------------------------------------------
-- Addon info
------------------------------------------------------------------------------------------------------------
FCOSS.addonVars =  {}
FCOSS.addonVars.addonRealVersion		= 0.97
FCOSS.addonVars.addonSavedVarsVersion	= 0.4
FCOSS.addonVars.addonName				= "FCOStarveStop"
FCOSS.addonVars.addonSavedVars			= "FCOStarveStop_Settings"
FCOSS.addonVars.settingsName   			= "FCO StarveStop"
FCOSS.addonVars.settingsDisplayName   	= "|c00FF00FCO |cFFFF00 StarveStop|r"
FCOSS.addonVars.addonAuthor				= "Baertram"
FCOSS.addonVars.addonWebsite			= "http://www.esoui.com/downloads/info1291-FCOStarveStop.html#info"


--For deferred init.
FCOSS.wasInitialized = {}

------------------------------------------------------------------------------------------------------------
-- Constants & variables
------------------------------------------------------------------------------------------------------------
--Alerts
FCOSS.alertTextDrink		= ""
FCOSS.alertTextFood			= ""
FCOSS.alertTextGeneral		= ""
FCOSS.alertTextGeneralPotion= ""
FCOSS.alertIconIsBlinking	= false
--The event name for the update event in function "FCOSS.setupWarningBeforeExpirationRepeat" in file "FCOCSS_Functions.lua"
FCOSS.updateEventName = "FCOStarveStopBuffFoodWarningBeforeExpirationCheck"

--Combat
FCOSS.inCombat				= false

--Different
FCOSS.activeDropdown		= nil

--LAM addon menu
FCOSS.addonMenu = {}
FCOSS.addonMenu.isShown = false

--Quickslots
FCOSS.quickslotSelectIconSize = 24
FCOSS.quickSlots			= {}
FCOSS.quickSlotsMapping		= {}


--Are we at the new quickslots introduced wit API101034 High Isle (Multi quickslot wheels)
local quickslotsNew                         = (QUICKSLOT_KEYBOARD ~= nil and true) or false
FCOSS.quickslotsNew                         = quickslotsNew
FCOSS.quickSlotsActionButtonIndex           = 1
local quickslotKeyboard                     = QUICKSLOT_KEYBOARD
FCOSS.quickslotVar = quickslotKeyboard
local quickSlotWheel                        = UTILITY_WHEEL_KEYBOARD
FCOSS.quickslotWheelVar = quickSlotWheel

local EMPTY_QUICKSLOT_TEXTURE               = "/esoui/art/quickslots/quickslot_emptyslot.dds"
FCOSS.EMPTY_QUICKSLOT_TEXTURE               = EMPTY_QUICKSLOT_TEXTURE
local EMPTY_QUICKSLOT_STRING                = GetString(SI_QUICKSLOTS_EMPTY)
FCOSS.quickSlotEmptyText                    = EMPTY_QUICKSLOT_STRING
FCOSS.quickSlotEmptyText                    = zo_iconTextFormat(EMPTY_QUICKSLOT_TEXTURE, FCOSS.quickslotSelectIconSize, FCOSS.quickslotSelectIconSize, EMPTY_QUICKSLOT_STRING)


--Preventing other stuff
FCOSS.preventerVars						= {}
FCOSS.preventerVars.KeyBindingTexts				= false
FCOSS.preventerVars.gLocalizationDone			= false
FCOSS.preventerVars.alreadyBuffFoodChecked		= false
FCOSS.preventerVars.buffFoodFaded				= false
FCOSS.preventerVars.buffFoodRenewed				= false
FCOSS.preventerVars.iconManuallyHidden			= false
FCOSS.preventerVars.iconManuallyHiddenPotion 	= false
FCOSS.preventerVars.weaponSwitched 				= false
FCOSS.preventerVars.ultimateAbility				= {}
FCOSS.preventerVars.ultimateAbility["NoChatOutput"] = false
FCOSS.preventerVars.ultimateAbility["AbilityId"]	= nil
FCOSS.preventerVars.changedBySettingsMenu 		= false
FCOSS.preventerVars.changedBySettingsMenuPotion	= false
FCOSS.preventerVars.iconShownBeforeMenuOpened 	= false
FCOSS.preventerVars.iconShownBeforeMenuOpenedPotion	= false
FCOSS.preventerVars.addonMenuBuild				= false
FCOSS.preventerVars.setupWarningBeforeExpirationRepeat = false
FCOSS.preventerVars.changeBackToQuickslotAfterFoodBuffUsage = false
FCOSS.preventerVars.lockpickInProgress = false
FCOSS.preventerVars.lockpickWasDone = false
FCOSS.preventerVars.activePotionBuff = false
FCOSS.preventerVars.hidePotionAlertIcon = false

--Other addons
FCOSS.otherAddons						= {}
FCOSS.otherAddons.autoSlotSwitch		= {
    ["isLoaded"]	            =	false,
    ["lastNonCombatQuickslot"]  = -1,
}

--Count/Numbers off...
FCOSS.numVars = {}

--Available languages
FCOSS.numVars.languageCount = 7 --English, German, French, Spanish, Italian, Japanese, Russian
FCOSS.langVars = {}
FCOSS.langVars.languages = {}
--Build the languages array
for i=1, FCOSS.numVars.languageCount do
    FCOSS.langVars.languages[i] = true
end

--Settings
FCOSS.settingsVars					 	= {}
FCOSS.settingsVars.defaults						 	= {}
FCOSS.settingsVars.settings						 	= {}
FCOSS.settingsVars.defaultSettings				 	= {}

--Localization
FCOSS.localizationVars				 	= {}
FCOSS.localizationVars.localizationAll  = {}
FCOSS.locVars							= {}
--Uncolored "FCOIS" pre chat text for the chat output
FCOSS.locVars.preChatText = "[FCO StarveStop]"
--Green colored "FCOSS" pre text for the chat output
FCOSS.locVars.preChatTextGreen = "|c22DD22"..FCOSS.locVars.preChatText.."|r "
--Red colored "FCOSS" pre text for the chat output
FCOSS.locVars.preChatTextRed = "|cDD2222"..FCOSS.locVars.preChatText.."|r "
--Blue colored "FCOSS" pre text for the chat output
FCOSS.locVars.preChatTextBlue = "|c2222DD"..FCOSS.locVars.preChatText.."|r "

--Icons
FCOSS.iconTextures 						= {
    [1] = [[/esoui/art/crafting/alchemy_tabicon_solvent_up.dds]],
    [2] = [[/esoui/art/charactercreate/charactercreate_bodyicon_up.dds]],
    [3] = [[/esoui/art/chatwindow/chat_notification_up.dds]],
    [4] = [[/esoui/art/crafting/alchemy_tabicon_reagent_up.dds]],
    [5] = [[/esoui/art/inventory/inventory_tabicon_consumables_up.dds]],
    [6] = [[/esoui/art/icons/justice_stolen_food_001.dds]],
    [7] = [[/esoui/art/icons/quest_food_001.dds]],
    [8] = [[/esoui/art/icons/quest_food_002.dds]],
    [9] = [[/esoui/art/icons/quest_food_003.dds]],
    [10] = [[/esoui/art/icons/quest_food_004.dds]],
    [11] = [[/esoui/art/icons/justice_stolen_flask_001.dds]],
    [12] = [[/esoui/art/icons/crafting_water_skin_003.dds]],
    [13] = [[/esoui/art/icons/justice_stolen_waterskin_001.dds]],
    [14] = [[/esoui/art/icons/crafting_potion_base_water_1_r1.dds]],
    [15] = [[/esoui/art/icons/crafting_potion_base_water_1_r2.dds]],
    [16] = [[/esoui/art/icons/crafting_potion_base_water_1_r3.dds]],
    [17] = [[/esoui/art/icons/crafting_potion_base_water_2_r2.dds]],
    [18] = [[/esoui/art/icons/crafting_potion_base_water_2_r3.dds]],
    [19] = [[/esoui/art/icons/crafting_potion_base_water_3_r1.dds]],
    [20] = [[/esoui/art/icons/crafting_potion_base_water_3_r2.dds]],
    [21] = [[/esoui/art/icons/crafting_potion_base_water_3_r3.dds]],
    [22] = [[/esoui/art/icons/crafting_potion_base_water_4_r1.dds]],
    [23] = [[/esoui/art/icons/crafting_potion_base_water_4_r2.dds]],
    [24] = [[/esoui/art/icons/crafting_potion_base_water_4_r3.dds]],
    [25] = [[/esoui/art/icons/crafting_potion_base_water_5_r1.dds]],
    [26] = [[/esoui/art/icons/crafting_potion_base_water_5_r2.dds]],
    [27] = [[/esoui/art/icons/crafting_potion_base_water_5_r3.dds]],
    --User created icons: Scootworks
    [28] = [[FCOStarveStop/DDS/elixier.dds]],
    [29] = [[FCOStarveStop/DDS/food.dds]],
    [30] = [[FCOStarveStop/DDS/steak.dds]],
    [31] = [[FCOStarveStop/DDS/wasser.dds]],
    --User created icons: manavortex
    [32] = [[FCOStarveStop/DDS/fork_knife.dds]],
}

--Food buffs
FCOSS.buffFoodNotActive		= false
FCOSS.buffNames                      	= {}
FCOSS.buffNames.food = {}
--Disabled with updated version 0.747, and replaced by read food buffs from the ability IDs
FCOSS.buffNames.foodStatic = {
    --food
    --health
    ["increase max health"]                    = true,
    ["santé maximale augmentée"]               = true,
    ["gestärktes leben"]                       = true,
    ["erhöht euer maximales leben"]            = true,
    --magicka
    ["increase max magicka"]                   = true,
    ["magie maximale augmentée"]               = true,
    ["gestärkte magicka"]                      = true, -- active version with API 100015 Dark Brotherhood
    ["erhöht maximale magicka"]                = true, -- fallback version
    ["erhöht eure maximale magicka"]           = true, -- Assumed to be correct version with Dark brotherhood, but it isn't active!
    --stamina
    ["increase max stamina"]                   = true,
    ["vigueur maximale augmentée"]             = true,
    ["erhöht eure maximale ausdauer"]          = true,
    --health & magicka
    ["increase max health & max magicka"]      = true,
    ["increase max health & magicka"]          = true,
    ["santé et magie maximales augmentées"]    = true,
    ["erhöht euer maximales leben und magicka"]     = true,
    --health & stamina
    ["increase max health & stamina"]          = true,
    ["augmentation santé et la vigueur max"]   = true,
    ["gestärktes leben und ausdauer"]          = true,
    --magicka & stamina
    ["increase max magicka & stamina"]         = true,
    ["magie et vigueur maximales augmentées"]  = true,
    ["erhöht eure maximale magicka und ausdauer"] = true,
    --all primary stats
    ["increase all primary stats"]             = true,
    ["augmentation caracs primaires"]          = true,
    ["komplettstärkung"]                       = true, -- active version with API 100015 Dark Brotherhood
    ["erhöht alle attribute"]				   = true, -- fallback version

    --Max health & regen health
    ["increase max health & health r"]			= true,
    --Max health & regen magicka
    ["erhöht euer maximales leben und magicka"] = true,
    --Max health & regen stamina
    ["gestärktes leben und ausdauer"] 			= true,
    --Max health & regen all
    ["erhöhtes leben und regeneration"] 		= true,
    ["increases max health, health regen, stamina regen and magicka regen"] = true,
}
FCOSS.buffNames.drink = {}
FCOSS.buffNames.drinkStatic = {
    --drink
    --health
    ["health recovery"]                        = true,
    ["récupération de santé"]                  = true,
    ["lebensregeneration"]                     = true,
    --magicka
    ["magicka recovery"]                       = true,
    ["récupération de magie"]                  = true,
    ["magickaregeneration"]                    = true,
    --stamina
    ["stamina recovery"]                       = true,
    ["récupération de vigueur"]                = true,
    ["ausdauerregeneration"]                   = true,
    --health & magicka
    ["health & magicka recovery"]              = true,
    ["récupération santé et magie"]            = true,
    ["lebens- und magickaregeneration"]        = true,
    --health & stamina
    ["health & stamina recovery"]              = true,
    ["récupération santé et vigueur"]          = true,
    ["lebens- und ausdauerregeneration"]       = true,
    --magicka & stamina
    ["magicka & stamina recovery"]             = true,
    ["récupération de magie et de vigueur"]    = true,
    ["magicka- und ausdauerregeneration"]      = true,
    --all primary stats
    ["all primary stat recovery"]              = true,
    ["regeneration aller Primärattribute"]     = true,
    ["rétablissement de toutes les stats principales"]     = true,
    ["komplettregeneration"]                   = true, -- active version with API 100015 Dark Brotherhood
}

--Ability IDs for the buffs
FCOSS.buffAbilityIds = {}
--Ultimate abilities where the activation would renew the buffs and thus throw the event with the food buff check again!
FCOSS.buffAbilityIds.ultimatesExcluded = {
    --Overload (Überladung, Energieüberladung, kraftüberladung)
    [30348] = true, --"Überladung^f"
    [30349] = true, --"Overload End"
    [30350] = true, --"Überladung^f"
    [30351] = true, --"Überladung^f"
    [30352] = true, --"Overload End"
    [30353] = true, --"Überladung^f"
    [30354] = true, --"Überladung^f"
    [30355] = true, --"Overload End"
    [30356] = true, --"Überladung^f"
    [30357] = true, --"Überladung^f"
    [30358] = true, --"Kraftüberladung^f"
    [30359] = true, --"Overload End"
    [30360] = true, --"Kraftüberladung^f"
    [30361] = true, --"Überladung^f"
    [30362] = true, --"Kraftüberladung^f"
    [30363] = true, --"Overload End"
    [30364] = true, --"Kraftüberladung^f"
    [30365] = true, --"Überladung^f"
    [30366] = true, --"Kraftüberladung^f"
    [30367] = true, --"Overload End"
    [30368] = true, --"Kraftüberladung^f"
    [30369] = true, --"Überladung^f"
    [30370] = true, --"Überladung^f"
    [30371] = true, --"Energieüberladung^f"
    [30372] = true, --"Energieüberladung^f"
    [30373] = true, --"Overload End"
    [30374] = true, --"Energieüberladung^f"
    [30375] = true, --"Überladung^f"
    [30376] = true, --"Energieüberladung^f"
    [30377] = true, --"Overload End"
    [30378] = true, --"Energieüberladung^f"
    [30379] = true, --"Überladung^f"
    [30380] = true, --"Energieüberladung^f"
    [30381] = true, --"Energieüberladung^f"
    [30382] = true, --"Overload End",
    [30383] = true, --"Energieüberladung^f"
    [30384] = true, --"Überladung^f"
    [30385] = true, --"Energieüberladung^f"
}

--[[ MOVED TO libPotionBuff
--Potions
--Ability IDs for the potions
FCOSS.buffAbilityIds.potions = {}
--Crafted potion buffs
FCOSS.buffAbilityIds.potions.crafted = {
    [45222] = true, --"Major Fortitude",
    [45224] = true, --"Major Intellect",
    [45226] = true, --"Major Endurance",
    [45236] = true, --"Increase Detection",
    [45237] = true, --"Vanish",
    [45239] = true, --"Unstoppable",

    [46113] = true, --"Health Potion Poison",
    [46193] = true, --"Ravage Magicka",
    [46199] = true, --"Ravage Stamina",
    [46202] = true, --"Minor Cowardice",
    [46204] = true, --"Minor Maim",
    [46206] = true, --"Minor Breach",
    [46208] = true, --"Minor Fracture",
    [46210] = true, --"Hindrance",

    [47203] = true, --"Minor Enervation",

    [64555] = true, --"Major Brutality",
    [64558] = true, --"Major Sorcery",
    [64562] = true, --"Major Ward",
    [64566] = true, --"Major Expedition",
    [64568] = true, --"Major Savagery",
    [64570] = true, --"Major Prophecy",

    [79705] = true, --"Lingering Restore Health",
    [79709] = true, --"Creeping Ravage Health",
    [79712] = true, --"Minor Protection",
    [79848] = true, --"Major Vitality",
    [79860] = true, --"Minor Defile",
}
--Non-crafted potion buffs (bought at a vendor or found)
FCOSS.buffAbilityIds.potions.nonCrafted = {
    [63672] = true, --"Major Fortitude",
    [63678] = true, --"Major Intellect",
    [63683] = true, --"Major Endurance",

    [72928] = true, --"Major Fortitude",
    [72930] = true, --"Unstoppable",
    [72932] = true, --"Major Intellect",
    [72933] = true, --"Major Sorcery",
    [72935] = true, --"Major Endurance",
    [72936] = true, --"Major Brutality",

    [78054] = true, --"Major Endurance",
    [78058] = true, --"Vanish",
    [78080] = true, --"Major Endurance",
    [78081] = true, --"Major Expedition",
}
--Crown-Store potion buffs
FCOSS.buffAbilityIds.potions.crownStore = {
    [68405] = true, --"Major Fortitude",
    [68406] = true, --"Major Intellect",
    [68408] = true, --"Major Endurance",

    [86683] = true, --"Major Intellect",
    [86684] = true, --"Major Prophecy",
    [86685] = true, --"Major Sorcery",
    [86693] = true, --"Major Endurance",
    [86694] = true, --"Major Savagery",
    [86695] = true, --"Major Brutality",
    [86697] = true, --"Major Fortitude",
    [86698] = true, --"Unstoppable",
    [86699] = true, --"Invisibility",
    [86780] = true, --"Invisibility",
}
]]