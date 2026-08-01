DeadMansTally = {
    name = "DeadMansTally",
    version = "1.0.0"
}
local DMT = DeadMansTally


---------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------
local function FillDefaults(tab)
    local defaults = {"ungroupedplayer", "group", "playerpet", "boss", "companion", "groupcompanion"}
    for _, name in ipairs(defaults) do
        if (not tab[name]) then
            tab[name] = ""
        end
    end
end

local function FillAllDefaults(tab, defaults)
    for k, v in pairs(defaults) do
        if (tab[k] == null) then
            if (type(v) == "table") then
                tab[k] = ZO_DeepTableCopy(v)
            else
                tab[k] = v
            end
        end
    end
end

local function Initialize()
    DeadMansTallySavedVariables = DeadMansTallySavedVariables or {}
    DMT.packedSVs = DeadMansTallySavedVariables

    local world = GetWorldName()
    if (not DMT.packedSVs[world]) then
        DMT.packedSVs[world] = {}
    end

    local accName = GetUnitDisplayName("player")
    if (not DMT.packedSVs[world][accName]) then
        DMT.packedSVs[world][accName] = {}
    end

    FillAllDefaults(DMT.packedSVs[world][accName], {
        includeInAll = true,
        show = true,
        locked = false,
        scale = 1,
        x = GuiRoot:GetWidth() * 2 / 3,
        y = GuiRoot:GetHeight() / 2,
        foreverDeaths = {},
        currentDeaths = {},
    })

    FillDefaults(DMT.packedSVs[world][accName].foreverDeaths)
    FillDefaults(DMT.packedSVs[world][accName].currentDeaths)

    ZO_CreateStringId("SI_BINDING_NAME_DMT_TOGGLE_UI", "Toggle showing tally")

    DMT.InitializeDataStore()
    DMT.InitializeCore()
    DMT.InitializeUI()
    DMT.CreateSettingsMenu()
end


---------------------------------------------------------------------
-- On load
local function OnAddOnLoaded(_, addonName)
    if (addonName == DMT.name) then
        EVENT_MANAGER:UnregisterForEvent(DMT.name, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end
 
EVENT_MANAGER:RegisterForEvent(DMT.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
