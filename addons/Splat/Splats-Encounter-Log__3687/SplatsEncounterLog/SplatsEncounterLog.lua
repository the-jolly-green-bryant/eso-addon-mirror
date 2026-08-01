SplatsEncounterLog = SplatsEncounterLog or {}
local SELAddon = SplatsEncounterLog
SELAddon.name = "SplatsEncounterLog"
SELAddon.variableVersion = 1
SELAddon.author    = "Splat"

SELAddon.svChar    = {}
SELAddon.svCharDef = {
        enclogtrial = false,
        enclogdungeon = false,
        enclogarena = false,
        enclogcyro = false,
        enclogic = false,
	xui = 350,
	yui = 350
}

fchecker = false

--- SETTIGNS MENU ---

function SELAddon.initMenu()
  local LAM2 = LibAddonMenu2
  local panelData = {
    type        = "panel",
    name        = "Splats Encounter Log",
    author      = "Splat",
    version	    = "1.20",
    registerForRefresh = true,	-- will refresh all options controls when a setting is changed and when the panel is shown
    registerForDefaults = true	-- will set all options controls back to default values
  }
  LAM2:RegisterAddonPanel("SplatsEncounterLog", panelData)
    local optionsData = {
    {  type = "description",
       Title = "Settings options for Splats Encounter Log",
       text = "Please use 'Controls > Addon Keybinds > Splats Encounter Log' to assign a keybind to enable/disable Encounter Logging.",
       width = "full",
    }, 
    {  type = "divider",
       alpha = 0.4,
    },
    {  type = "description",
       title = "Encounter Log Status",
       text = "Show Encounter Log Status in Trials, Dungeons, Arenas, Cyrodiil or Imperial City",
       width = "full",
    },
    {  type    = "checkbox",
       name    = "Display Encounter Log Status in Trials",
       getFunc = function() return SELAddon.svChar.enclogtrial end,
       setFunc = function(value) SELAddon.svChar.enclogtrial=value end,
       default = SELAddon.svCharDef.enclogtrial,
       width   = "full",
       requiresReload = true,
    },
    {  type    = "checkbox",
       name    = "Display Encounter Log Status in Dungeons",
       getFunc = function() return SELAddon.svChar.enclogdungeon end,
       setFunc = function(value) SELAddon.svChar.enclogdungeon=value end,
       default = SELAddon.svCharDef.enclogdungeon,
       width   = "full",
       requiresReload = true,
    },
    {  type    = "checkbox",
       name    = "Display Encounter Log Status in Arenas",
       getFunc = function() return SELAddon.svChar.enclogarena end,
       setFunc = function(value) SELAddon.svChar.enclogarena=value end,
       default = SELAddon.svCharDef.enclogarena,
       width   = "full",
       requiresReload = true,
    },
    {  type    = "checkbox",
       name    = "Display Encounter Log Status in Cyrodiil",
       getFunc = function() return SELAddon.svChar.enclogcyro end,
       setFunc = function(value) SELAddon.svChar.enclogcyro=value end,
       default = SELAddon.svCharDef.enclogcyro,
       width   = "full",
       requiresReload = true,
    },
    {  type    = "checkbox",
       name    = "Display Encounter Log Status in Imperial City",
       getFunc = function() return SELAddon.svChar.enclogic end,
       setFunc = function(value) SELAddon.svChar.enclogic=value end,
       default = SELAddon.svCharDef.enclogic,
       width   = "full",
       requiresReload = true,
    },
  }
  LAM2:RegisterOptionControls("SplatsEncounterLog", optionsData)
end

function showMarkers()
local zoneId = GetZoneId(GetUnitZoneIndex("player")) -- GET CURRENT PLAYER ZONE ID
fchecker = false

-- ENCOUNTER LOG TRIAL SECTION
 if (SELAddon.svChar.enclogtrial == true) then
  if ((zoneId == 636) or (zoneId == 638) or (zoneId == 639) or (zoneId == 725) or (zoneId == 975) or (zoneId == 1000) or (zoneId == 1051) or (zoneId == 1021) or (zoneId == 1196) or (zoneId == 1344) or (zoneId == 1427) or (zoneId == 1263)) then
   fchecker = true
   encounterlogcheck()
   SELAddon.svChar.hiddenUI = false
   SELAddonENCUI:SetHidden(false) -- MAKE LOGGER VISIBLE
 end
end

-- ENCOUNTER LOG DUNGEON SECTION
if (SELAddon.svChar.enclogdungeon == true) then
 if ((zoneId == 11) or (zoneId == 22) or (zoneId == 31) or (zoneId == 38) or (zoneId == 63) or (zoneId == 64) or (zoneId == 126) or (zoneId == 130) or (zoneId == 131) or (zoneId == 144) or (zoneId == 146) or (zoneId == 148) or (zoneId == 176) or (zoneId == 283) or (zoneId == 380) or (zoneId == 449) or (zoneId == 678) or (zoneId == 681) or (zoneId == 688) or (zoneId == 843) or (zoneId == 848) or (zoneId == 930) or (zoneId == 931) or (zoneId == 932) or (zoneId == 933) or (zoneId == 934) or (zoneId == 935) or (zoneId == 936) or (zoneId == 973) or (zoneId == 974) or (zoneId == 1009) or (zoneId == 1010) or (zoneId == 1052) or (zoneId == 1055) or (zoneId == 1080) or (zoneId == 1081) or (zoneId == 1122) or (zoneId == 1123) or (zoneId == 1152) or (zoneId == 1153) or (zoneId == 1197) or (zoneId == 1201) or (zoneId == 1228) or (zoneId == 1229) or (zoneId == 1267) or (zoneId == 1268) or (zoneId == 1301) or (zoneId == 1302) or (zoneId == 1360) or (zoneId == 1361) or (zoneId == 1389) or (zoneId == 1390)) then
   fchecker = true
   encounterlogcheck()
   SELAddon.svChar.hiddenUI = false
   SELAddonENCUI:SetHidden(false) -- MAKE LOGGER VISIBLE
 end
end

-- ENCOUNTER LOG ARENA SECTION
if (SELAddon.svChar.enclogarena == true) then
 if ((zoneId == 677) or (zoneId == 635) or (zoneId == 1082) or (zoneId == 1227)) then
   fchecker = true
   encounterlogcheck()
   SELAddon.svChar.hiddenUI = false
   SELAddonENCUI:SetHidden(false) -- MAKE LOGGER VISIBLE
 end
end

-- ENCOUNTER LOG CYRO SECTION
 if (SELAddon.svChar.enclogcyro == true) then
  if (zoneId == 181) then
   fchecker = true
   encounterlogcheck()
   SELAddon.svChar.hiddenUI = false
   SELAddonENCUI:SetHidden(false) -- MAKE LOGGER VISIBLE
 end
end

-- ENCOUNTER LOG IC SECTION
 if (SELAddon.svChar.enclogic == true) then
  if (zoneId == 643) then
   fchecker = true
   encounterlogcheck()
   SELAddon.svChar.hiddenUI = false
   SELAddonENCUI:SetHidden(false) -- MAKE LOGGER VISIBLE
 end
end

if (fchecker == false) then
  SELAddonENCUI:SetHidden(true) -- MAKE LOGGER INVISIBLE
  SELAddon.svChar.hiddenUI = true
end


end -- CLOSE OF SHOWMARKERS FUNCTION


--- ENCOUNTER LOG SECTION

function ToggleLogging()
 if IsEncounterLogEnabled() then
    SetEncounterLogEnabled(false)
 encounterlogprint()
 else
    SetEncounterLogEnabled(true)
 encounterlogprint()
 end
end

function encounterlogprint()
 if IsEncounterLogEnabled() then
   CHAT_ROUTER:AddSystemMessage("Encounter logging enabled.")
    local colour = {0.39, 0.82, 0.24, 0.8}
    SELAddonENCUI_Backdrop:SetCenterColor(unpack(colour)) -- TURN BACKGROUND GREEN
    SELAddonENCUILabel:SetText("Logging On")
 else
   CHAT_ROUTER:AddSystemMessage("Encounter logging disabled.")
    local colour = {0.69, 0, 0, 0.8}
    SELAddonENCUI_Backdrop:SetCenterColor(unpack(colour)) -- TURN BACKGROUND RED
    SELAddonENCUILabel:SetText("Logging Off")
 end
end

function encounterlogcheck()
 if IsEncounterLogEnabled() then
    local colour = {0.39, 0.82, 0.24, 0.8}
    SELAddonENCUI_Backdrop:SetCenterColor(unpack(colour)) -- TURN BACKGROUND GREEN
    SELAddonENCUILabel:SetText("Logging On")
 else
    local colour = {0.69, 0, 0, 0.8}
    SELAddonENCUI_Backdrop:SetCenterColor(unpack(colour)) -- TURN BACKGROUND RED
    SELAddonENCUILabel:SetText("Logging Off")
 end
end

function EncounterLogUIOnMoveStop()
 SELAddon.svChar.xui = SELAddonENCUI:GetLeft()
 SELAddon.svChar.yui = SELAddonENCUI:GetTop()
end

function SELAddon:RestorePosition()
    SELAddonENCUI:ClearAnchors()
    SELAddonENCUI:SetHidden(SELAddon.svChar.hiddenUI)
    SELAddonENCUI:SetTopmost(true)
    SELAddonENCUI:BringWindowToTop(true)
    SELAddonENCUI:SetAnchor(
        TOPLEFT,
        GuiRoot,
        TOPLEFT,
        SELAddon.svChar.xui,
        SELAddon.svChar.yui
    )
end

--- Hide the window if visible and screen state changed to some dialogue/menu interface.
local function HideIfVisible()
    if SELAddon.svChar.hiddenUI == false then
        SELAddonENCUI:SetHidden(true)
    end
end
 
--- Show the window if visible and screen state returned to normal.
local function ShowIfVisible()
    if SELAddon.svChar.hiddenUI == false then
        SELAddonENCUI:SetHidden(false)
    end
end

---------------------

--- INITIALIZE ADDON ---

function SELAddon:Initialize()
  SELAddon.svChar = ZO_SavedVars:NewAccountWide("SplatsEncounterLogging", SELAddon.variableVersion, nil, SELAddon.svCharDef, GetWorldName())
  EVENT_MANAGER:RegisterForEvent( SELAddon.name, EVENT_PLAYER_ACTIVATED, showMarkers)
  SELAddon.initMenu()
 -- Hotkeys
  ZO_CreateStringId("SI_BINDING_NAME_SPLATS_ENCOUNTER_LOG_TOGGLE_ENCOUNTER_LOG", "Toggle Encounter Log")
  SELAddon:RestorePosition()
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnHide", function()
        ShowIfVisible()
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnHide", function()
        ShowIfVisible()
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function()
        ShowIfVisible()
    end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function()
        HideIfVisible()
    end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function()
        ShowIfVisible()
    end)
  EVENT_MANAGER:UnregisterForEvent( SELAddon.name, EVENT_ADD_ON_LOADED )
end -- close Main Initilze function


function SELAddon.OnAddOnLoaded(event, addonName)
  if addonName == SELAddon.name then
    SELAddon:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(SELAddon.name, EVENT_ADD_ON_LOADED, SELAddon.OnAddOnLoaded)