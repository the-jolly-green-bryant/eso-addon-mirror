local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

CrownCustomizer = {} 

CrownCustomizer.name = "CrownCustomizer"
CrownCustomizer.version = "-"
CrownCustomizer.author = "@triase"
CrownCustomizer.Default = {
    IconSize = 64,
    IconName = "Default"
}

CrownCustomizer.SelectIcons = {
    { name = "Default", path = "esoui/art/compass/groupleader.dds" },
    { name = "Ourosboros", path = "esoui/art/gammaadjust/gamma_referenceimage1.dds" },
    { name = "Champion Point", path = "esoui/art/menubar/gamepad/gp_playermenu_icon_champion.dds" },
    { name = "Skill", path = "esoui/art/menubar/gamepad/gp_playermenu_icon_skills.dds" },
    { name = "Crown Store", path = "esoui/art/menubar/gamepad/gp_playermenu_icon_store.dds" },
    { name = "Crown Store2", path = "esoui/art/menubar/gamepad/gp_playermenu_icon_crowncrates.dds" },
    { name = "Emperor", path = "esoui/art/campaign/gamepad/gp_overview_menuicon_emperor.dds" },
    { name = "Cross Swards", path = "esoui/art/campaign/campaignbrowser_indexicon_normal_down.dds" },
    { name = "Shield & Cross Swards", path = "esoui/art/lfg/lfg_tabicon_mygroup_down.dds" },
    { name = "Quest", path = "esoui/art/floatingmarkers/quest_icon.dds" },
    { name = "Quest Assisted", path = "esoui/art/floatingmarkers/quest_icon_assisted.dds" },
    { name = "Achivemet", path = "esoui/art/journal/journal_tabicon_achievements_down.dds" },
    { name = "Eye", path = "esoui/art/icons/poi/poi_areaofinterest_complete.dds" },
    { name = "Group Boss", path = "esoui/art/icons/poi/poi_groupboss_complete.dds" },
    { name = "Fighters Guild", path = "esoui/art/icons/servicemappins/servicepin_fightersguild.dds" },
    { name = "Mages Guild", path = "esoui/art/icons/servicemappins/servicepin_magesguild.dds" },
    { name = "Aldmeri Dominion", path = "esoui/art/stats/alliancebadge_aldmeri.dds" },
    { name = "Daggerfall Covenant", path = "esoui/art/stats/alliancebadge_daggerfall.dds" },
    { name = "Ebonheart Pact", path = "esoui/art/stats/alliancebadge_ebonheart.dds" },
    { name = "Bethesda", path = "esoui/art/login/credits_bethesda_logo.dds" },
    { name = "Zenimax Online", path = "esoui/art/login/credits_zos_logo.dds" },
    { name = "My CustomIcon", path = "CrownCustomizer/Icons/myCustomIcon.dds" },
    { name = "triase's Cats Pad", path = "CrownCustomizer/Icons/catspad.dds" },
    { name = "Scootworks's Wabbajack", path = "CrownCustomizer/Icons/wabbajack.dds" },
}

function CrownCustomizer.OnAddOnLoaded(event, addonName)
    if addonName ~= CrownCustomizer.name then return end
    
    CrownCustomizer:Initialize()
end

function CrownCustomizer:Initialize()
    CrownCustomizer.savedVariables = ZO_SavedVars:New("CrownCustomizerVars", CrownCustomizer.version, nil, CrownCustomizer.Default)
    CrownCustomizer.CreateSettingsWindow() 
    EVENT_MANAGER:UnregisterForEvent(CrownCustomizer.name, EVENT_ADD_ON_LOADED)
end

function CrownCustomizer.CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = "CrownCustomizer",
        displayName = "CrownCustomizer",
        author = "@triase",
        version = "1.0.5",
        slashCommand = "/crcu",
        registerForRefresh = true,
        registerForDefaults = false,
    }
    local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Crown_Customizer", panelData)
    local optionsData = {
        [1] = {
            type = "header",
            name = "Crown Customizer Settings"
        },
        [2] = {
            type = "description",
            text = "Here you can choice icon."
        },
        [3] = {
            type = "dropdown",
            name = "Icon Name",
            choices = CrownCustomizer.GetIconNameList(),
            getFunc = function() return CrownCustomizer.savedVariables.IconName end,
            setFunc = function(newValue)
                CrownCustomizer.savedVariables.IconName = newValue
            end,
            requiresReload = true,
        },
        [4] = {
            type = "slider",
            name = "Icon Size",
            min = 32,
            max = 256,
            getFunc = function() return CrownCustomizer.savedVariables.IconSize end,
            setFunc = function(newValue)
                CrownCustomizer.savedVariables.IconSize = newValue
            end,
            requiresReload = true,
        },
        [5] = {
            type = "texture",
            image = CrownCustomizer.GetIconPath(),
            imageWidth = CrownCustomizer.savedVariables.IconSize,
            imageHeight = CrownCustomizer.savedVariables.IconSize,
        },
    }
    LAM2:RegisterOptionControls("Crown_Customizer", optionsData)
end

function CrownCustomizer.GetIconPath()
    name = CrownCustomizer.savedVariables.IconName
    path = CrownCustomizer.SelectIcons["Default"]
    for key, val in pairs(CrownCustomizer.SelectIcons) do
        if val.name == name then
            path = val.path
        end
    end
    return path
end

function CrownCustomizer.GetIconNameList()
    t = {}
    for key, val in pairs(CrownCustomizer.SelectIcons) do
        table.insert(t, val.name)
    end
    return t
end


function CrownCustomizer.OnPlayerActivated()
   SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER, CrownCustomizer.savedVariables.IconSize, CrownCustomizer.GetIconPath(), CrownCustomizer.GetIconPath())
end

EVENT_MANAGER:RegisterForEvent(CrownCustomizer.name, EVENT_ADD_ON_LOADED, CrownCustomizer.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent("CrownCustomizerOnPlayer", EVENT_PLAYER_ACTIVATED, CrownCustomizer.OnPlayerActivated)