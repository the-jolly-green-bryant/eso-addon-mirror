local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

CrownOfCyrodiil = {} 

CrownOfCyrodiil.name = "CrownOfCyrodiil"
CrownOfCyrodiil.version = "1.2.1"
CrownOfCyrodiil.author = "@Tillalarrien"


CrownOfCyrodiil.IconTexture = {
    [1] = "CrownOfCyrodiil/Icons/ClassicCrown.dds",
    [2] = "CrownOfCyrodiil/Icons/EbonheartWhite.dds",
    [3] = "CrownOfCyrodiil/Icons/EbonheartColour.dds",
    [4] = "CrownOfCyrodiil/Icons/DaggerfallWhite.dds",
    [5] = "CrownOfCyrodiil/Icons/DaggerfallColour.dds",
    [6] = "CrownOfCyrodiil/Icons/AldmeriWhite.dds",
    [7] = "CrownOfCyrodiil/Icons/AldmeriColour.dds",
    [8] = "CrownOfCyrodiil/Icons/DaedricRuneWhite.dds",
    [9] = "CrownOfCyrodiil/Icons/DaedricRuneColour.dds",
    [10] = "CrownOfCyrodiil/Icons/Hand.dds",
    [11] = "CrownOfCyrodiil/Icons/RedArrow.dds",
}

CrownOfCyrodiil.IconTooltips = {
    [1] = "Crown",
    [2] = "Ebonheart Pact: White",
    [3] = "Ebonheart Pact: Red",
    [4] = "Daggerfall Covenant: White",
    [5] = "Daggerfall Covenant: Blue",
    [6] = "Aldmeri Dominion: White",
    [7] = "Aldmeri Dominion: Red",
    [8] = "Daedric Rune: White",
    [9] = "Daedric Rune: Purple",
    [10] = "Hand",
    [11] = "Red Arrow",
}

function CrownOfCyrodiil.OnAddOnLoaded(event, addonName)
    if addonName ~= CrownOfCyrodiil.name then return end
    
    CrownOfCyrodiil:Initialize()
end

function CrownOfCyrodiil:Initialize()
    CrownOfCyrodiil.savedVariables = ZO_SavedVars:New("CrownOfCyrodiilVars", CrownOfCyrodiil.version, nil, CrownOfCyrodiil.Default)
    CrownOfCyrodiil.CreateSettingsWindow() 
    EVENT_MANAGER:UnregisterForEvent(CrownOfCyrodiil.name, EVENT_ADD_ON_LOADED)
end

function CrownOfCyrodiil.CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = GetString(CROWN_TITLE),
        displayName = "|cdd5a00" .. GetString(CROWN_TITLE) .. "|r",
        author = "@Tillalarrien",
        version = "1.1.0",
        slashCommand = "/crown",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Crowns_1", panelData)
    local optionsData = {
        [1] = {
            type = "divider",
        },
        [2] = {
            type = "iconpicker",
            name = GetString(CROWN_SYMBOL),
            choices = CrownOfCyrodiil.IconTexture,
            choicesTooltips = CrownOfCyrodiil.IconTooltips,
            getFunc = function() return CrownOfCyrodiil.savedVariables.Icon end,
            setFunc = function(newValue)
                CrownOfCyrodiil.savedVariables.Icon = newValue
            end,
            iconSize = 100,
            visibleRows = 1,
            maxColumns = 1,
            default = CrownOfCyrodiil.IconTexture[1],
            requiresReload = true,
        },
        [3] = {
            type = "slider",
            name = GetString(CROWN_SIZE),
            min = 25,
            max = 300,
            getFunc = function() return CrownOfCyrodiil.savedVariables.IconSize end,
            setFunc = function(newValue)
                CrownOfCyrodiil.savedVariables.IconSize = newValue
            end,
            default = 156,
            requiresReload = true,
        },
        [4] = {
	    type = "checkbox",
	    name = GetString(CYRODIIL_ONLY),
	    getFunc = function() return CrownOfCyrodiil.savedVariables.CyroOnly end,
	    setFunc = function(newValue)
                CrownOfCyrodiil.savedVariables.CyroOnly = newValue
            end,
            default = true,
            requiresReload = true,
	},
    }
    LAM2:RegisterOptionControls("Crowns_1", optionsData)
end

function CrownOfCyrodiil.OnPlayerActivated()
  if (not CrownOfCyrodiil.savedVariables.CyroOnly) or (CrownOfCyrodiil.savedVariables.CyroOnly and IsPlayerInAvAWorld()) then
       SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER, CrownOfCyrodiil.savedVariables.IconSize, CrownOfCyrodiil.savedVariables.Icon)
  end
end

EVENT_MANAGER:RegisterForEvent(CrownOfCyrodiil.name, EVENT_ADD_ON_LOADED, CrownOfCyrodiil.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent("CrownsOnPlayer", EVENT_PLAYER_ACTIVATED, CrownOfCyrodiil.OnPlayerActivated)