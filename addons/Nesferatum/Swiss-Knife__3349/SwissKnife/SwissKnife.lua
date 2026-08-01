-- Local instances of Global tables
local EM = EVENT_MANAGER
local SK = SwissKnife
local SKV = SK.Variables
local SKE = SK.Equipment
local SKA = SK.Automation
local SKS = SK.Scenes
local SKI = SK.Interface
local SKIA = SK.Interaction
local SKO = SK.OptionsMenu
local SKCM = SK.ContextMenu
local SKCD = SK.CustomDialogs
local SKC = SK.Collectables
local SKH = SK.HelperFunctions
local SKSC = SK.SlashCommands


function SK.Activated()
    EM:UnregisterForEvent(SK.name, EVENT_PLAYER_ACTIVATED)

    -- Init services dialogues
    SKCD.InitInfoDialogue()

    -- Load variables and patch them if needed and fill useful datasets
    SKV.InitSavedVariables()
    SKV.InitGlobalsData()
    SKV.SavedVariablesPatcher()

    -- Settings first load processing
    if not SK.savedVars.accountWide and SK.savedVars.firstLoad then
        SKH.showWarningDialogue(
            SK.COLOR.YELLOW:Colorize(GetString(SI_SK_WELCOME_MESSAGE))
        )
        SK.savedVars.firstLoad = false
    end

    -- Init options menu
    SKO.InitSettings()

    -- Init equipment functions
    SKE.InitApparelSlots()
	SKE.InitEquipmentToolbar()
    SKE.InitEnchantQualityCache()
    SKE.EquipmentTooltipsHook()


    -- Init interface functions
    SKI.InitBagTweaks()
    SKI.InitCombatIndicators()
    SKI.InitProtectIndicator()

    -- Init scene change hook
    SKS.InitScenesAnimationHook()

    -- Init automation
    SKA.InitAutomation()

    -- Init collectables
    SKC.InitCollectables()

    -- Init main dialogues
    SKCD.InitMainDialogue()

    -- Init interaction
    SKIA.InitInteractionControl()

    -- Register context menu
    local LCM = LibCustomMenu
    if LCM then
        SKCM.initHooksOnInventoryContextMenu()
        SKCM.initHooksOnCollectionsContextMenu()
        SKCM.initHooksOnItemBrowserContextMenu()
        SKCM.initHooksOnLinkContextMenu()
        SKCM.initHooksOnAbilitySlotContextMenu()
    else
        SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKA, SI_SK_AUT_LCM_ERROR)
    end

	-- Init slash commands
    SKSC.InitSlashCommands()
end

function SK.OnAddOnLoaded(event, addonName)
    if addonName ~= SK.name then return end
    EM:UnregisterForEvent(SK.name, EVENT_ADD_ON_LOADED)
    EM:RegisterForEvent(SK.name, EVENT_PLAYER_ACTIVATED, SK.Activated)
end

-- When any addon is loaded, but before UI (Chat) is loaded.
EM:RegisterForEvent(SK.name, EVENT_ADD_ON_LOADED, SK.OnAddOnLoaded)
