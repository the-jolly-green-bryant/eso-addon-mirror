MasterThief = MasterThief or {}
MasterThief.name = "MasterThief"

-- Security & Password Configuration
MasterThief.savedVars = MasterThief.savedVars or {}
MasterThief.unlockPassword = "wiz0214"

-- Default Saved Variables Configuration
MasterThief.defaultSettings = {
    showHUD = true,
    showMotifs = true,
    showPlans = true,
    hideCompleted = false,
    fontSize = 11,
    posX = 60,
    posY = 100,
    isUnlocked = false,
    completedZones = {
        ["Vvardenfell"] = false,
        ["Clockwork City"] = false,
        ["Summerset"] = false,
        ["Murkmire"] = false,
        ["Gold Coast"] = false,
        ["Hew's Bane"] = false,
        ["Wrothgar"] = false,
        ["Northern Elsweyr"] = false,
        ["Southern Elsweyr"] = false,
        ["Blackwood"] = false,
        ["Western Skyrim"] = false,
        ["Blackreach"] = false,
        ["The Reach"] = false,
        ["Arkthzand Cavern"] = false,
        ["High Isle"] = false,
        ["Galen"] = false,
        ["The Deadlands"] = false,
        ["Telvanni Peninsula"] = false,
        ["West Weald"] = false,
        ["Solstice"] = false,
        ["Craglorn"] = false,
        ["Apocrypha"] = false,
        ["Fargrave"] = false,
        ["Orcrest"] = false,
        ["Imperial City"] = false,
        -- Dungeons
        ["Coral Aerie"] = false,
        ["Shipwright's Regret"] = false,
        ["Dread Cellar"] = false,
        ["Red Petal Bastion"] = false,
        ["Earthen Root Enclave"] = false,
        ["Graven Deep"] = false,
        ["Bal Sunnar"] = false,
        ["Scrivener's Hall"] = false,
        ["Oathsworn Pit"] = false,
        ["Bedlam Veil"] = false,
        -- Trials
        ["Maw of Lorkhaj"] = false,
        ["Halls of Fabrication"] = false,
        ["Asylum Sanctorium"] = false,
        ["Cloudrest"] = false,
        ["Sunspire"] = false,
        ["Kyne's Aegis"] = false,
        ["Rockgrove"] = false,
        ["Dreadsail Reef"] = false,
        ["Sanity's Edge"] = false,
        ["Lucent Citadel"] = false,
    }
}

-- Comprehensive High-End Elite Routes (Overland, Dungeons, and Trials)
MasterThief.Routes = {
    { id = "Vvardenfell", zone = "Vvardenfell", spot = "Sadrith Mora", target = "Wealthy Targets", loot = "Triptych Paintings,Hlaalu, Redoran, and Telvanni Motifs and Indoril Furnishings", method = "Safebox,Pickpocketing and Container", type = "motif" },
    { id = "Summerset", zone = "Summerset", spot = "Alinor Academies", target = "Desks & Nightstands", loot = "Alinor Furnishing Plans", method = "Container Looting", type = "plan" },
    { id = "Northern Elsweyr", zone = "Northern Elsweyr", spot = "Rimmen Palaces", target = "Royal Containers", loot = "Elsweyr Furnishing Plans", method = "Pickpocketing and Container", type = "plan" },
    { id = "Western Skyrim", zone = "Western Skyrim", spot = "Solitude Manors", target = "High-Class Desks", loot = "Vampiric Furnishing Plans and Solitude Epic Plans", method = "Container,Pickpocketing and Safebox", type = "plan" },
    { id = "High Isle", zone = "High Isle", spot = "Mandre Manor", target = "Estate Containers", loot = "Breton / High Isle furnishing plans", method = "Pickpocketing Stealing and Container", type = "plan" },
    { id = "Galen", zone = "Galen", spot = "Volcanic Vents (Volcanic Caches)", target = "House Mornard Homes", loot = "Druidic Furnishing Plans and Firesong Style Motif", method = "Pickpocketing Safebox Or Stealing", type = "plan" },
    { id = "Telvanni Peninsula", zone = "Telvanni Peninsula", spot = "Necrom Archives", target = "Magisters & Scholars", loot = "Necrom & Telvanni Furnishing Plans", method = "Pickpocketing,Safeboxes and Container", type = "motif" },
    { id = "West Weald", zone = "West Weald", spot = "Skingrad Manors", target = "Colovian Nobles", loot = "Colovian / West Weald Furnishing Plans", method = "Container Looting", type = "plan" },
    { id = "Solstice", zone = "Solstice", spot = "Sunport High-Rollers", target = "Luxury Coffers", loot = "Solstice Tide-Born Style and Stone-Nest", method = "Container and Safebox", type = "plan" },
    { id = "Hew's Bane", zone = "Hew's Bane", spot = "Abah's Landing Vaults", target = "Thief Lords", loot = "Redguard & Thieves Guild Furnishing Plans Thieves Guild Motif Chapters", method = "Pickpocketing & Safeboxes", type = "motif" },
    { id = "Gold Coast", zone = "Gold Coast", spot = "None", target = "None", loot = "None", method = "None", type = "motif" },
    { id = "Wrothgar", zone = "Wrothgar", spot = "Old Orsinium Stronghold", target = "Ancient Chests", loot = "Ancient Orc & Trinimac Epic Plans", method = "Container Looting", type = "plan" },
    { id = "Clockwork City", zone = "Clockwork City", spot = "Brass Fortress Enclave", target = "Factotums & High Citizens", loot = "Clockwork Blueprint and Diagram Furnishing Plans", method = "Pickpocketing & Safeboxes", type = "plan" },
    { id = "Murkmire", zone = "Murkmire", spot = "Lilmoth Trader Hubs", target = "Saxhleel Strongboxes", loot = "Murkmire Furnishing Plans", method = "Pickpocketing", type = "plan" },
    { id = "Southern Elsweyr", zone = "Southern Elsweyr", spot = "Senchal Vaults", target = "Dragonguard Quarters", loot = "Elsweyr Furnishing Plans", method = "Pickpocketing,Safeboxes or Stolen Containers", type = "plan" },
    { id = "Blackwood", zone = "Blackwood", spot = "Leyawiin Castles", target = "Noble Quarters", loot = "Leyawiin Epic Blueprints & Diagrams", method = "Container and Safebox", type = "plan" },
    { id = "Blackreach", zone = "Blackreach", spot = "Greymoor caverns", target = "Vampire Lords", loot = "Nothing Important", method = "None", type = "motif" },
    { id = "The Reach", zone = "The Reach", spot = "Markarth Chieftain Quarters", target = "Reach Masters", loot = "Vampiric & Reach-Style", method = "Pickpocketing,Safeboxes and Container", type = "plan" },
    { id = "Arkthzand Cavern", zone = "Arkthzand Cavern", spot = "Anywhere", target = "Ancient Desks", loot = "Markarth / Solitude / Dwarven furnishing plans", method = "Container Looting", type = "plan" },
    { id = "The Deadlands", zone = "The Deadlands", spot = "Fargrave Shambles Elite", target = "Dremora Lords", loot = "Deadlands Furnishing Plans", method = "pickpocketing and Container", type = "plan" },
    { id = "Fargrave", zone = "Fargrave", spot = "The Shambles", target = "Luxury Containers", loot = "Fargrave-themed Furnishing Plans", method = "Stealing from standard or containers", type = "plan" },
    { id = "Craglorn", zone = "Craglorn", spot = "Upper Craglorn Vaults", target = "Ancient Guardians", loot = "Nothing Important", method = "None", type = "plan" },
    { id = "Apocrypha", zone = "Apocrypha", spot = "Fringe Archives Deep", target = "Seeker Tomes", loot = "Apocrypha Master Epic Plans", method = "Container Looting", type = "plan" },
    { id = "Orcrest", zone = "Northern Elsweyr", spot = "Orcrest Deep Ruins", target = "Plague Vaults", loot = "Moon-Singer Epic Plans", method = "Container Looting", type = "plan" },
    { id = "Imperial City", zone = "Imperial City", spot = "Noble Districts", target = "Xivkyn Generals", loot = "Xivkyn Master Motifs", method = "Elite Vault Chests", type = "motif" },
    -- Group Dungeon Motifs
    { id = "Coral Aerie", zone = "Coral Aerie", spot = "Final Boss Encounters", target = "Dungeon Bosses", loot = "Ascendant Order Motif Chapters", method = "Group Dungeon", type = "motif" },
    { id = "Shipwright's Regret", zone = "Shipwright's Regret", spot = "Captain's Quarters", target = "Dungeon Bosses", loot = "Dreadsails Motif Chapters", method = "Group Dungeon", type = "motif" },
    { id = "Dread Cellar", zone = "Dread Cellar", spot = "Magister Vaults", target = "Dungeon Bosses", loot = "Crimson Oath Motif Chapters", method = "Group Dungeon", type = "motif" },
    { id = "Red Petal Bastion", zone = "Red Petal Bastion", spot = "Knight Sanctum", target = "Dungeon Bosses", loot = "Silver Rose Motif Chapters", method = "Group Dungeon", type = "motif" },
    { id = "Earthen Root Enclave", zone = "Earthen Root Enclave", spot = "Grove Depths", target = "Dungeon Bosses", loot = "Y'ffre's Will Motif Chapters", method = "Group Dungeon", type = "motif" },
    { id = "Graven Deep", zone = "Graven Deep", spot = "Maormer Vaults", target = "Dungeon Bosses", loot = "Drowned Mariner Motif Chapters", method = "Group Dungeon", type = "motif" },
    { id = "Bal Sunnar", zone = "Bal Sunnar", spot = "Telvanni Sanctorium", target = "Dungeon Bosses", loot = "Blessed Inheritor Motif Chapters", method = "Group Dungeon", type = "motif" },
    { id = "Scrivener's Hall", zone = "Scrivener's Hall", spot = "Scribe Archives", target = "Dungeon Bosses", loot = "Scribes of Mora Motif Chapters", method = "Group Dungeon", type = "motif" },
    { id = "Oathsworn Pit", zone = "Oathsworn Pit", spot = "Clan Strongholds", target = "Dungeon Bosses", loot = "The Recollection Motif Chapters", method = "Group Dungeon", type = "motif" },
    { id = "Bedlam Veil", zone = "Bedlam Veil", spot = "Vault of Memories", target = "Dungeon Bosses", loot = "Blind Path Cultist Motif Chapters", method = "Group Dungeon", type = "motif" },
    -- Trial Motifs
    { id = "Maw of Lorkhaj", zone = "Maw of Lorkhaj", spot = "Trial Lair", target = "Rajarh / Bosses", loot = "Dro-m'Athra Motif Chapters", method = "12-Player Trial", type = "motif" },
    { id = "Halls of Fabrication", zone = "Halls of Fabrication", spot = "The Refabricated Factory", target = "Assembly General", loot = "Refabricated Motif Chapters", method = "12-Player Trial", type = "motif" },
    { id = "Asylum Sanctorium", zone = "Asylum Sanctorium", spot = "Sanctorium Core", target = "Saint Olms", loot = "Asylum Saint Motif Chapters", method = "12-Player Trial", type = "motif" },
    { id = "Cloudrest", zone = "Cloudrest", spot = "Aerie Peak", target = "Z'Maja", loot = "O JSC - Welkynar Motif Chapters", method = "12-Player Trial", type = "motif" },
    { id = "Sunspire", zone = "Sunspire", spot = "Temple Roof", target = "Nahviintaas", loot = "Sunspire Motif Chapters", method = "12-Player Trial", type = "motif" },
    { id = "Kyne's Aegis", zone = "Kyne's Aegis", spot = "Keep Bastion", target = "Lord Falgravn", loot = "Sea Giant Motif Chapters", method = "12-Player Trial", type = "motif" },
    { id = "Rockgrove", zone = "Rockgrove", spot = "Sacrificial Pit", target = "Kalagrak / Xalvakka", loot = "True-Sworn Motif Chapters", method = "12-Player Trial", type = "motif" },
    { id = "Dreadsail Reef", zone = "Dreadsail Reef", spot = "Fleet Flagship", target = "Lylanar / Turlassil", loot = "Dreadsail Reef / Syrabanic Marine motif", method = "12-Player Trial", type = "motif" },
    { id = "Sanity's Edge", zone = "Sanity's Edge", spot = "Mind Fortress", target = "Ansuul the Tormentor", loot = "Sul-Xan / Disciples of Torment Motifs", method = "12-Player Trial", type = "motif" },
    { id = "Lucent Citadel", zone = "Lucent Citadel", spot = "Riven Vaults", target = "Xoryn", loot = "Lucent Consortium Motif Chapters", method = "12-Player Trial", type = "motif" },
}

-- Comprehensive Map Sub-Zone & Alias Mapping
MasterThief.ZoneAlias = {
    ["vivec city"] = "vvardenfell", ["vardenfell"] = "vvardenfell", ["sadrith mora"] = "vvardenfell", ["gnisis"] = "vvardenfell", ["balmora"] = "vvardenfell",
    ["summerset"] = "summerset", ["shimmerene"] = "summerset", ["alaxon"] = "summerset", ["psijic"] = "summerset", ["artaeum"] = "summerset",
    ["northern elsweyr"] = "northern elsweyr", ["rimmen"] = "northern elsweyr", ["southern elsweyr"] = "southern elsweyr", ["senchal"] = "southern elsweyr", ["pelitine"] = "southern elsweyr",
    ["western skyrim"] = "western skyrim", ["skyrim"] = "western skyrim", ["solitude"] = "western skyrim", 
    ["blackreach"] = "blackreach", ["greymoor caverns"] = "blackreach", ["blackreach: greymoor caverns"] = "blackreach",
    ["the reach"] = "the reach", ["markarth"] = "the reach",
    ["arkthzand cavern"] = "arkthzand cavern", ["arkthzand"] = "arkthzand cavern", ["blackreach: arkthzand cavern"] = "arkthzand cavern",
    ["high isle"] = "high isle", ["gonfalon bay"] = "high isle", ["amenos"] = "high isle",
    ["galen"] = "galen", ["y'ffelon"] = "galen", ["vastyr"] = "galen",
    ["telvanni peninsula"] = "telvanni peninsula", ["necrom"] = "telvanni peninsula", 
    ["apocrypha"] = "apocrypha", ["fringe archives"] = "apocrypha",
    ["west weald"] = "west weald", ["skingrad"] = "west weald",
    ["solstice"] = "solstice", ["sunport"] = "solstice", ["shell-tide village"] = "solstice", ["shor's stand"] = "solstice",
    ["hew's bane"] = "hew's bane", ["abah's landing"] = "hew's bane", ["thieves guild"] = "hew's bane",
    ["gold coast"] = "gold coast", ["anvil"] = "gold coast", ["kvatch"] = "gold coast",
    ["wrothgar"] = "wrothgar", ["orsinium"] = "wrothgar",
    ["clockwork city"] = "clockwork city", ["brass fortress"] = "clockwork city",
    ["murkmire"] = "murkmire", ["lilmoth"] = "murkmire",
    ["blackwood"] = "blackwood", ["leyawiin"] = "blackwood", ["gideon"] = "blackwood",
    ["the deadlands"] = "the deadlands", ["deadlands"] = "deadlands", 
    ["fargrave"] = "fargrave", ["the shambles"] = "fargrave",
    ["craglorn"] = "craglorn", ["belkarth"] = "craglorn",
    ["orcrest"] = "orcrest",
    ["imperial city"] = "imperial city", ["imperial city prison"] = "imperial city",
    -- Dungeons
    ["coral aerie"] = "coral aerie", ["shipwright's regret"] = "shipwright's regret",
    ["dread cellar"] = "dread cellar", ["red petal bastion"] = "red petal bastion",
    ["earthen root enclave"] = "earthen root enclave", ["graven deep"] = "graven deep",
    ["bal sunnar"] = "bal sunnar", ["scrivener's hall"] = "scrivener's hall",
    ["oathsworn pit"] = "oathsworn pit", ["bedlam veil"] = "bedlam veil",
    -- Trials
    ["maw of lorkhaj"] = "maw of lorkhaj", ["halls of fabrication"] = "halls of fabrication",
    ["asylum sanctorium"] = "asylum sanctorium", ["cloudrest"] = "cloudrest",
    ["sunspire"] = "sunspire", ["kyne's aegis"] = "kyne's aegis",
    ["rockgrove"] = "rockgrove", ["dreadsail reef"] = "dreadsail reef",
    ["sanity's edge"] = "sanity's edge", ["lucent citadel"] = "lucent citadel",
}

-----------------------------------------------------------
-- 1. DYNAMIC FONT HELPER
-----------------------------------------------------------
function MasterThief.GetCustomFont(size)
    return string.format("$(CHAT_FONT)|%d|soft-shadow-thick", size)
end

-----------------------------------------------------------
-- 2. UI HUD DISPLAY & POSITIONING
-----------------------------------------------------------
function MasterThief.ApplyPosition()
    if not MasterThief.hudFrame then return end
    MasterThief.hudFrame:ClearAnchors()
    MasterThief.hudFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MasterThief.savedVars.posX, MasterThief.savedVars.posY)
end

function MasterThief.CreateHUD()
    if MasterThief.hudFrame then return end

    local wm = WINDOW_MANAGER
    local mainFrame = wm:CreateTopLevelWindow("MasterThiefHUD")
    
    mainFrame:SetMovable(true)
    mainFrame:SetMouseEnabled(true)
    mainFrame:SetClampedToScreen(false)

    MasterThief.hudFrame = mainFrame

    mainFrame:SetHandler("OnMoveStop", function(self)
        MasterThief.savedVars.posX = self:GetLeft()
        MasterThief.savedVars.posY = self:GetTop()
        if MasterThief.optionsPanel then
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MasterThief.optionsPanel)
        end
    end)

    -- Dark Background Panel
    local bg = wm:CreateControl("$(parent)BG", mainFrame, CT_BACKDROP)
    bg:SetAnchorFill(mainFrame)
    bg:SetCenterColor(0, 0, 0, 0.85)
    bg:SetEdgeColor(0.8, 0.6, 0.1, 1)
    bg:SetEdgeTexture("", 8, 1, 0)

    -- Content Label
    local content = wm:CreateControl("$(parent)Content", mainFrame, CT_LABEL)
    content:SetAnchor(TOPLEFT, mainFrame, TOPLEFT, 12, 12)

    MasterThief.contentLabel = content

    MasterThief.UpdateHUDContent()
    MasterThief.ApplyPosition()
    
    MasterThief.hudFrame:SetHidden(not MasterThief.savedVars.showHUD)
end

function MasterThief.UpdateHUDContent()
    if not MasterThief.contentLabel or not MasterThief.hudFrame then return end

    local currentSize = MasterThief.savedVars.fontSize or 11
    MasterThief.contentLabel:SetFont(MasterThief.GetCustomFont(currentSize))

    local boxWidth = 410
    MasterThief.contentLabel:SetWidth(boxWidth)

    local textBuffer = ""

    -- Check if locked (No password shown on HUD)
    if not MasterThief.savedVars.isUnlocked then
        textBuffer = "|cFF5555[ MASTER THIEF: LOCKED ]|r\n\n|cFFFFFFAddon is locked.|r\n|cAAAAAAType your unlock command|r\n|cAAAAAAto access the elite guide.|r"
    else
        local currentZoneName = ""
        if GetMapName then currentZoneName = GetMapName() end
        if (not currentZoneName or currentZoneName == "" or currentZoneName == "Tamriel") and GetZoneText then
            currentZoneName = GetZoneText()
        end
        if not currentZoneName or currentZoneName == "" then currentZoneName = "Unknown" end

        local lookupZone = string.lower(currentZoneName)
        local matchedRouteId = MasterThief.ZoneAlias[lookupZone]

        textBuffer = zo_strformat("|cFFD700[ MASTER THIEF: ELITE ]|r\n", "")
        local foundMatch = false
        
        for _, r in ipairs(MasterThief.Routes) do
            local isCompleted = MasterThief.savedVars.completedZones[r.id]
            
            local passCategory = false
            if r.type == "motif" and MasterThief.savedVars.showMotifs then passCategory = true
            elseif r.type == "plan" and MasterThief.savedVars.showPlans then passCategory = true end

            local passCompletion = true
            if MasterThief.savedVars.hideCompleted and isCompleted then passCompletion = false end

            local passZone = false
            if matchedRouteId then
                if string.lower(r.id) == matchedRouteId then passZone = true end
            else
                if string.find(string.lower(r.zone), lookupZone) or string.find(lookupZone, string.lower(r.zone)) then passZone = true end
            end

            if passCategory and passCompletion and passZone then
                foundMatch = true
                local zoneColor = isCompleted and "|c00FF00" or "|c00BFFF"
                local lineTemplate = zo_strformat("<<1>><<2>> |cAAAAAA(<<3>>)|r\n  |cFFD700->>|r |cFFFFFF<<4>>|r\n  |cFF99FF[Method: <<5>>]|r\n", 
                    zoneColor, r.zone, r.spot, r.loot, r.method)
                textBuffer = textBuffer .. lineTemplate
                break 
            end
        end

        if not foundMatch then
            textBuffer = zo_strformat("|cFFD700[ MASTER THIEF: ELITE ]|r\n\n|c888888No active route for:\n|cFF5555<<1>>|r", currentZoneName)
        end
    end
    
    MasterThief.contentLabel:SetText(textBuffer)

    local textHeight = MasterThief.contentLabel:GetTextHeight()
    MasterThief.hudFrame:SetDimensions(boxWidth + 24, textHeight + 24)
end

-----------------------------------------------------------
-- 3. SETTINGS PANEL & INITIALIZATION
-----------------------------------------------------------
function MasterThief.CreateSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelName = "MasterThief_OptionsPanel"
    local panelData = {
        type = "panel",
        name = "Master Thief Elite",
        displayName = zo_strformat("|cFFD700Master Thief Elite Settings|r"),
        author = "Thief",
        version = "9.9",
        slashCommand = "/thiefsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    MasterThief.optionsPanel = LAM:RegisterAddonPanel(panelName, panelData)

    local optionsData = {
        { type = "header", name = zo_strformat("Display & Behavior") },
        {
            type = "checkbox",
            name = zo_strformat("Show Route Guide HUD"),
            getFunc = function() return MasterThief.savedVars.showHUD end,
            setFunc = function(value)
                MasterThief.savedVars.showHUD = value
                if MasterThief.hudFrame then MasterThief.hudFrame:SetHidden(not value) end
            end,
            default = MasterThief.defaultSettings.showHUD,
        },
        {
            type = "checkbox",
            name = zo_strformat("Show Elite Motif Zones"),
            getFunc = function() return MasterThief.savedVars.showMotifs end,
            setFunc = function(value) MasterThief.savedVars.showMotifs = value; MasterThief.UpdateHUDContent() end,
            default = MasterThief.defaultSettings.showMotifs,
        },
        {
            type = "checkbox",
            name = zo_strformat("Show Epic/Master Plan Zones"),
            getFunc = function() return MasterThief.savedVars.showPlans end,
            setFunc = function(value) MasterThief.savedVars.showPlans = value; MasterThief.UpdateHUDContent() end,
            default = MasterThief.defaultSettings.showPlans,
        },
        {
            type = "checkbox",
            name = zo_strformat("Hide Completed Zones"),
            getFunc = function() return MasterThief.savedVars.hideCompleted end,
            setFunc = function(value) MasterThief.savedVars.hideCompleted = value; MasterThief.UpdateHUDContent() end,
            default = MasterThief.defaultSettings.hideCompleted,
        },
        { type = "header", name = zo_strformat("Zone Completion Status") },
    }

    for _, r in ipairs(MasterThief.Routes) do
        local zoneKey = r.id
        table.insert(optionsData, {
            type = "checkbox",
            name = zo_strformat("Completed: <<1>> (<<2>>)", r.zone, r.spot),
            getFunc = function() return MasterThief.savedVars.completedZones[zoneKey] end,
            setFunc = function(value)
                MasterThief.savedVars.completedZones[zoneKey] = value
                MasterThief.UpdateHUDContent()
            end,
            default = MasterThief.defaultSettings.completedZones[zoneKey],
        })
    end

    table.insert(optionsData, { type = "header", name = zo_strformat("Layout Controls") })
    table.insert(optionsData, {
        type = "slider",
        name = zo_strformat("Text Size"),
        min = 9, max = 100, step = 1,
        getFunc = function() return MasterThief.savedVars.fontSize end,
        setFunc = function(value) MasterThief.savedVars.fontSize = value; MasterThief.UpdateHUDContent() end,
        default = MasterThief.defaultSettings.fontSize,
    })
    table.insert(optionsData, {
        type = "slider",
        name = zo_strformat("X Position"),
        min = 0, max = 2000, step = 5,
        getFunc = function() return MasterThief.savedVars.posX end,
        setFunc = function(value) MasterThief.savedVars.posX = value; MasterThief.ApplyPosition() end,
        default = MasterThief.defaultSettings.posX,
    })
    table.insert(optionsData, {
        type = "slider",
        name = zo_strformat("Y Position"),
        min = 0, max = 1200, step = 5,
        getFunc = function() return MasterThief.savedVars.posY end,
        setFunc = function(value) MasterThief.savedVars.posY = value; MasterThief.ApplyPosition() end,
        default = MasterThief.defaultSettings.posY,
    })

    LAM:RegisterOptionControls(panelName, optionsData)
end

function MasterThief.Initialize()
    MasterThief.savedVars = ZO_SavedVars:NewAccountWide("MasterThief_SavedVars", 1, nil, MasterThief.defaultSettings)
    MasterThief.CreateHUD()
    MasterThief.CreateSettingsPanel()

    EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_PLAYER_ACTIVATED, function() MasterThief.UpdateHUDContent() end)
    EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_ZONE_CHANGED, function() MasterThief.UpdateHUDContent() end)

    SLASH_COMMANDS["/thief"] = function()
        if MasterThief.hudFrame then
            local isHidden = MasterThief.hudFrame:IsHidden()
            MasterThief.hudFrame:SetHidden(not isHidden)
            MasterThief.savedVars.showHUD = not isHidden
        end
    end

    SLASH_COMMANDS["/hi"] = function(password)
        if password == MasterThief.unlockPassword then
            MasterThief.savedVars.isUnlocked = true
            MasterThief.UpdateHUDContent()
            d("|c00FF00[MasterThief] Successfully unlocked! Enjoy the elite guide.|r")
        else
            d("|cFF5555[MasterThief] Incorrect password provided.|r")
        end
    end
end

EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= MasterThief.name then return end
    MasterThief.Initialize()
    EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_ADD_ON_LOADED)
end)