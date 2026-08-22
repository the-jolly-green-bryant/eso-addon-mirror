MasterThief = MasterThief or {}
MasterThief.name = "MasterThief"

-- Security & Password Configuration
MasterThief.isUnlocked = false
MasterThief.password = "wiz0214"

-- Session Tracking Variables
MasterThief.session = {
    goldStolen = 0,
    itemsStolen = 0,
    motifsFound = 0,
    plansFound = 0,
    startTime = GetTimeStamp()
}

-- Default Saved Variables Configuration
MasterThief.defaultSettings = {
    showHUD = true,
    showMotifs = true,
    showPlans = true,
    hideCompleted = false,
    autoZoneOnly = false,
    fontSize = 11,
    posX = 60,
    posY = 100,
    completedZones = {
        ["Vvardenfell"] = false,
        ["Clockwork"] = false,
        ["Summerset"] = false,
        ["Murkmire"] = false,
        ["Gold Coast"] = false,
        ["Hew's Bane"] = false,
        ["Wrothgar"] = false,
        ["N. Elsweyr"] = false,
        ["S. Elsweyr"] = false,
        ["Blackwood"] = false,
        ["W. Skyrim"] = false,
        ["Blackreach"] = false,
        ["The Reach"] = false,
        ["Arkthzand"] = false,
        ["High Isle"] = false,
        ["Galen"] = false,
        ["Deadlands"] = false,
        ["Telvanni Pen."] = false,
        ["West Weald"] = false,
        ["Solstice"] = false,
        ["Craglorn"] = false,
        ["Apocrypha"] = false,
        ["Fargrave"] = false,
        ["Orcrest"] = false,
    }
}

-- Comprehensive Routes with Explicit Stealing vs Container Methods
MasterThief.Routes = {
    -- Chapters & Major Zones
    { id = "Vvardenfell", zone = "Vvardenfell", spot = "Vivec City", target = "Nobles & Priests", loot = "Hlaalu/Redoran Motifs", method = "Pickpocketing & Safeboxes", type = "motif" },
    { id = "Summerset", zone = "Summerset", spot = "Illumination Acad.", target = "Scholars & Desks", loot = "Alinor Motifs & Plans", method = "Container Looting", type = "plan" },
    { id = "N. Elsweyr", zone = "Northern Elsweyr", spot = "Rimmen Bazaar", target = "Vendors & Nobles", loot = "Elsweyr Motifs & Plans", method = "Pickpocketing & Containers", type = "plan" },
    { id = "W. Skyrim", zone = "Western Skyrim", spot = "Solitude Courtyard", target = "Nobles & Bards", loot = "Ancestral Nord Plans", method = "Container Looting", type = "plan" },
    { id = "High Isle", zone = "High Isle", spot = "Gonfalon Docks", target = "Sailors & Wealthy", loot = "Ascendant Order Motifs", method = "Pickpocketing & Safeboxes", type = "plan" },
    { id = "Galen", zone = "Galen", spot = "Vastyr Streets", target = "House Mornard & Locals", loot = "Druidic Plans", method = "Container Looting", type = "plan" },
    { id = "Telvanni Pen.", zone = "Telvanni Peninsula", spot = "Necrom Streets", target = "Scholars & Priests", loot = "Apocrypha Styles", method = "Pickpocketing & Safeboxes", type = "motif" },
    { id = "West Weald", zone = "West Weald", spot = "Skingrad Outskirts", target = "Locals & Nobles", loot = "Colovian Plans", method = "Container Looting", type = "plan" },
    { id = "Solstice", zone = "Solstice", spot = "Sunport Interiors", target = "Local Homes & Coffers", loot = "Tide-Born Plans", method = "Container Looting & Dailies", type = "plan" },

    -- DLC Zones & Sub-Zones
    { id = "Hew's Bane", zone = "Hew's Bane", spot = "Abah's Landing", target = "Outlaws & Merchants", loot = "Abah's Watch Styles", method = "Pickpocketing & Safeboxes", type = "motif" },
    { id = "Gold Coast", zone = "Gold Coast", spot = "Anvil Refuge Area", target = "Wealthy Citizens", loot = "Assassin Guild Motifs", method = "Pickpocketing & Safeboxes", type = "motif" },
    { id = "Wrothgar", zone = "Wrothgar", spot = "Orsinium Upper City", target = "Orc Nobles & Homes", loot = "Ancient Orc Plans", method = "Container Looting", type = "plan" },
    { id = "Clockwork", zone = "Clockwork City", spot = "Brass Fortress", target = "Factotums & Citizens", loot = "Apostle Motifs", method = "Pickpocketing & Safeboxes", type = "motif" },
    { id = "Murkmire", zone = "Murkmire", spot = "Lilmoth Market", target = "Saxhleel Locals", loot = "Murkmire Plans", method = "Container Looting", type = "plan" },
    { id = "S. Elsweyr", zone = "Southern Elsweyr", spot = "Senchal Docks", target = "Scoundrels & Sailors", loot = "Dragonguard Motifs", method = "Pickpocketing & Safeboxes", type = "plan" },
    { id = "Blackwood", zone = "Blackwood", spot = "Leyawiin Streets", target = "Townspeople & Nobles", loot = "Leyawiin Plans", method = "Container Looting", type = "plan" },
    { id = "Blackreach", zone = "Blackreach", spot = "Greymoor Caverns", target = "Cavern Inhabitants", loot = "Greymoor Styles", method = "Pickpocketing & Safeboxes", type = "motif" },
    { id = "The Reach", zone = "The Reach", spot = "Markarth Undercity", target = "Reachmen", loot = "Reach Wizard Motifs", method = "Pickpocketing & Safeboxes", type = "motif" },
    { id = "Arkthzand", zone = "Arkthzand Cavern", spot = "Arkthzand Library", target = "Explorers & Desks", loot = "Dwemer Plans", method = "Container Looting", type = "plan" },
    { id = "Deadlands", zone = "The Shambles", spot = "Fargrave", target = "Dremora & Locals", loot = "Fargrave Styles & Plans", method = "Pickpocketing & Containers", type = "motif" },
    { id = "Craglorn", zone = "Craglorn", spot = "Belkarth Outskirts", target = "Merchants & Nobles", loot = "Craglorn Furnishing Plans", method = "Container Looting", type = "plan" },
    { id = "Apocrypha", zone = "Telvanni Peninsula", spot = "Fringe Archives", target = "Seekers & Cultists", loot = "Apocrypha Furnishing Plans", method = "Container Looting", type = "plan" },
    { id = "Fargrave", zone = "The Deadlands", spot = "The Shambles", target = "Dremora Locals", loot = "Fargrave Furnishing Plans", method = "Container Looting", type = "plan" },
    { id = "Orcrest", zone = "Northern Elsweyr", spot = "Orcrest Ruins", target = "Undead & Looters", loot = "Moon-Singer Plans", method = "Container Looting", type = "plan" },
}

-- Comprehensive Map Sub-Zone & Alias Mapping
MasterThief.ZoneAlias = {
    ["vivec city"] = "vvardenfell", ["vardenfell"] = "vvardenfell", ["sadrith mora"] = "vvardenfell", ["gnisis"] = "vvardenfell", ["balmora"] = "vvardenfell",
    ["summerset"] = "summerset", ["shimmerene"] = "summerset", ["alaxon"] = "summerset", ["psijic"] = "summerset",
    ["northern elsweyr"] = "n. elsweyr", ["rimmen"] = "n. elsweyr", ["southern elsweyr"] = "s. elsweyr", ["senchal"] = "s. elsweyr", ["pelitine"] = "s. elsweyr",
    ["western skyrim"] = "w. skyrim", ["skyrim"] = "w. skyrim", ["solitude"] = "w. skyrim", 
    ["blackreach"] = "blackreach", ["greymoor caverns"] = "blackreach", ["blackreach: greymoor caverns"] = "blackreach",
    ["the reach"] = "the reach", ["markarth"] = "the reach",
    ["arkthzand cavern"] = "arkthzand", ["arkthzand"] = "arkthzand", ["blackreach: arkthzand cavern"] = "arkthzand",
    ["high isle"] = "high isle", ["gonfalon bay"] = "high isle", ["amenos"] = "high isle", ["galen"] = "galen", ["y'ffelon"] = "galen", ["vastyr"] = "galen",
    ["telvanni peninsula"] = "telvanni pen.", ["necrom"] = "telvanni pen.", ["apocrypha"] = "telvanni pen.",
    ["west weald"] = "west weald", ["skingrad"] = "west weald",
    ["solstice"] = "solstice", ["sunport"] = "solstice", ["shell-tide village"] = "solstice", ["shor's stand"] = "solstice",
    ["hew's bane"] = "hew's bane", ["abah's landing"] = "hew's bane", ["thieves guild"] = "hew's bane",
    ["gold coast"] = "gold coast", ["anvil"] = "gold coast", ["kvatch"] = "gold coast",
    ["wrothgar"] = "wrothgar", ["orsinium"] = "wrothgar",
    ["clockwork city"] = "clockwork", ["brass fortress"] = "clockwork",
    ["murkmire"] = "murkmire", ["lilmoth"] = "murkmire",
    ["blackwood"] = "blackwood", ["leyawiin"] = "blackwood", ["gideon"] = "blackwood",
    ["the deadlands"] = "deadlands", ["fargrave"] = "deadlands", ["deadlands"] = "deadlands", ["the shambles"] = "deadlands",
}

-----------------------------------------------------------
-- 1. DYNAMIC FONT HELPER
-----------------------------------------------------------
function MasterThief.GetCustomFont(size)
    return string.format("$(CHAT_FONT)|%d|soft-shadow-thick", size)
end

-----------------------------------------------------------
-- 2. INVENTORY & LOOT MONITORING (SESSION TRACKER)
-----------------------------------------------------------
function MasterThief.OnInventorySingleSlotUpdate(bagId, slotId, isNewItem, itemSoundCategory, updateReason, stackCountChange)
    if not MasterThief.isUnlocked then return end
    if bagId ~= BAG_BACKPACK then return end
    
    local itemLink = GetItemLink(bagId, slotId)
    if not itemLink or itemLink == "" then return end

    local itemType = GetItemLinkItemType(itemLink)
    local itemText = string.lower(itemLink)

    if isNewItem or updateReason == CURRENCY_UPDATE_REASON_STOLEN_ITEM then
        if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF or string.find(itemText, "motif") or string.find(itemText, "style") then
            MasterThief.session.motifsFound = MasterThief.session.motifsFound + (stackCountChange > 0 and stackCountChange or 1)
        elseif itemType == ITEMTYPE_FURNISHING or string.find(itemText, "plan") or string.find(itemText, "blueprint") or string.find(itemText, "diagram") or string.find(itemText, "praxis") then
            MasterThief.session.plansFound = MasterThief.session.plansFound + (stackCountChange > 0 and stackCountChange or 1)
        else
            MasterThief.session.itemsStolen = MasterThief.session.itemsStolen + 1
        end
    end
end

-----------------------------------------------------------
-- 3. UI HUD DISPLAY & POSITIONING
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
    
    if not MasterThief.isUnlocked then
        MasterThief.hudFrame:SetHidden(true)
    else
        MasterThief.hudFrame:SetHidden(not MasterThief.savedVars.showHUD)
    end
end

function MasterThief.UpdateHUDContent()
    if not MasterThief.contentLabel or not MasterThief.hudFrame then return end
    if not MasterThief.isUnlocked then
        MasterThief.hudFrame:SetHidden(true)
        return
    end

    local currentSize = MasterThief.savedVars.fontSize or 11
    MasterThief.contentLabel:SetFont(MasterThief.GetCustomFont(currentSize))

    local boxWidth = 410
    MasterThief.contentLabel:SetWidth(boxWidth)

    local currentZoneName = ""
    if GetMapName then currentZoneName = GetMapName() end
    if (not currentZoneName or currentZoneName == "" or currentZoneName == "Tamriel") and GetZoneText then
        currentZoneName = GetZoneText()
    end
    if not currentZoneName or currentZoneName == "" then currentZoneName = "Unknown" end

    local lookupZone = string.lower(currentZoneName)
    local matchedRouteId = MasterThief.ZoneAlias[lookupZone]

    local textBuffer = zo_strformat("|cFFD700[ MASTER THIEF ]|r\n", "")
    local displayedCount = 0
    
    for _, r in ipairs(MasterThief.Routes) do
        local isCompleted = MasterThief.savedVars.completedZones[r.id]
        
        local passCategory = false
        if r.type == "motif" and MasterThief.savedVars.showMotifs then passCategory = true
        elseif r.type == "plan" and MasterThief.savedVars.showPlans then passCategory = true end

        local passCompletion = true
        if MasterThief.savedVars.hideCompleted and isCompleted then passCompletion = false end

        local passZone = true
        if MasterThief.savedVars.autoZoneOnly then
            if matchedRouteId then
                if string.lower(r.id) ~= matchedRouteId then passZone = false end
            else
                if not string.find(string.lower(r.zone), lookupZone) and not string.find(lookupZone, string.lower(r.zone)) then passZone = false end
            end
        end

        if passCategory and passCompletion and passZone then
            displayedCount = displayedCount + 1
            local zoneColor = isCompleted and "|c00FF00" or "|c00BFFF"
            -- Displays Zone, Spot, Loot, and Method clearly on the HUD
            local lineTemplate = zo_strformat("<<1>><<2>> |cAAAAAA(<<3>>)|r\n  |cFFD700->>|r |cFFFFFF<<4>>|r\n  |cFF99FF[Method: <<5>>]|r\n", 
                zoneColor, r.zone, r.spot, r.loot, r.method)
            textBuffer = textBuffer .. lineTemplate
        end
    end

    if displayedCount == 0 then
        if MasterThief.savedVars.autoZoneOnly then
            textBuffer = zo_strformat("|cFFD700[ MASTER THIEF ]|r\n\n|c888888No active route for:\n|cFF5555<<1>>|r", currentZoneName)
        else
            textBuffer = textBuffer .. "\n|cFF0000No zones match filters.|r\n"
        end
    end

    textBuffer = textBuffer .. string.format("\n|cFFD700--- Session Heist Stats ---|r\n|cFFFFFFItems Stolen:|r %d  |cFFFFFFMotifs/Plans:|r %d", 
        MasterThief.session.itemsStolen, (MasterThief.session.motifsFound + MasterThief.session.plansFound))
    
    MasterThief.contentLabel:SetText(textBuffer)

    local textHeight = MasterThief.contentLabel:GetTextHeight()
    MasterThief.hudFrame:SetDimensions(boxWidth + 24, textHeight + 24)
end

-----------------------------------------------------------
-- 4. SETTINGS PANEL & INITIALIZATION
-----------------------------------------------------------
function MasterThief.CreateSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelName = "MasterThief_OptionsPanel"
    local panelData = {
        type = "panel",
        name = "Master Thief",
        displayName = zo_strformat("|cFFD700Master Thief Settings|r"),
        author = "Thief",
        version = "8.1",
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
                if MasterThief.hudFrame and MasterThief.isUnlocked then MasterThief.hudFrame:SetHidden(not value) end
            end,
            default = MasterThief.defaultSettings.showHUD,
        },
        {
            type = "checkbox",
            name = zo_strformat("Auto-Detect Current Zone Only (Recommended)"),
            tooltip = zo_strformat("Keeps the HUD clean by only showing the route for the specific zone you are currently in!"),
            getFunc = function() return MasterThief.savedVars.autoZoneOnly end,
            setFunc = function(value)
                MasterThief.savedVars.autoZoneOnly = value
                MasterThief.UpdateHUDContent()
            end,
            default = MasterThief.defaultSettings.autoZoneOnly,
        },
        {
            type = "checkbox",
            name = zo_strformat("Show Motif Zones"),
            getFunc = function() return MasterThief.savedVars.showMotifs end,
            setFunc = function(value) MasterThief.savedVars.showMotifs = value; MasterThief.UpdateHUDContent() end,
            default = MasterThief.defaultSettings.showMotifs,
        },
        {
            type = "checkbox",
            name = zo_strformat("Show Furnishing Plan Zones"),
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
    EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId, slotId, isNewItem, itemSoundCategory, updateReason, stackCountChange)
        MasterThief.OnInventorySingleSlotUpdate(bagId, slotId, isNewItem, itemSoundCategory, updateReason, stackCountChange)
        MasterThief.UpdateHUDContent()
    end)

    -- Unlock Command
    SLASH_COMMANDS["/unlock"] = function(passwordInput)
        if passwordInput == MasterThief.password then
            MasterThief.isUnlocked = true
            MasterThief.UpdateHUDContent()
            if MasterThief.hudFrame and MasterThief.savedVars.showHUD then
                MasterThief.hudFrame:SetHidden(false)
            end
        end
    end

    SLASH_COMMANDS["/thief"] = function()
        if not MasterThief.isUnlocked then return end
        if MasterThief.hudFrame then
            local isHidden = MasterThief.hudFrame:IsHidden()
            MasterThief.hudFrame:SetHidden(not isHidden)
            MasterThief.savedVars.showHUD = not isHidden
        end
    end

    SLASH_COMMANDS["/thiefstats"] = function()
        if not MasterThief.isUnlocked then return end
        d(zo_strformat("|cFFD700[MasterThief Stats]|r Items Stolen: <<1>> | Motifs Found: <<2>> | Plans Found: <<3>>", 
            MasterThief.session.itemsStolen, MasterThief.session.motifsFound, MasterThief.session.plansFound))
    end
end

EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= MasterThief.name then return end
    MasterThief.Initialize()
    EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_ADD_ON_LOADED)
end)