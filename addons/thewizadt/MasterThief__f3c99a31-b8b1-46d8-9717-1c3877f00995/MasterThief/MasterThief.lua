MasterThief = MasterThief or {}
MasterThief.name = "MasterThief"

MasterThief.defaultSettings = {
    showHUD = true,
    showMotifs = true,
    showPlans = true,
    hideCompleted = false,
    fontSize = 11,
    posX = 60,
    posY = 100,
    debugMode = true,
    unlocked = false,
    completedZones = {},
    cooldowns = {},
    charStats = {},
}

MasterThief.RoutesByID = {
    ["vvardenfell"] = { zone = "Vvardenfell", spot = "Sadrith Mora", target = "Wealthy Targets", loot = "Triptych Paintings, Hlaalu/Redoran/Telvanni Motifs", method = "Safebox, Pickpocketing & Container", type = "motif" },
    ["summerset"] = { zone = "Summerset", spot = "Alinor Academies", target = "Desks & Nightstands", loot = "Alinor Furnishing Plans", method = "Container Looting", type = "plan" },
    ["northern elsweyr"] = { zone = "Northern Elsweyr", spot = "Rimmen Palaces", target = "Royal Containers", loot = "Elsweyr Furnishing Plans", method = "Pickpocketing and Container", type = "plan" },
    ["western skyrim"] = { zone = "Western Skyrim", spot = "Solitude Manors", target = "High-Class Desks", loot = "Vampiric Furnishing Plans and Solitude Epic Plans", method = "Container, Pickpocketing & Safebox", type = "plan" },
    ["high isle"] = { zone = "High Isle", spot = "Mandre Manor", target = "Estate Containers", loot = "Breton / High Isle Furnishing Plans", method = "Pickpocketing, Stealing & Container", type = "plan" },
    ["galen"] = { zone = "Galen", spot = "Volcanic Vents", target = "House Mornard Homes", loot = "Druidic Furnishing Plans and Firesong Style Motif", method = "Pickpocketing, Safebox or Stealing", type = "plan" },
    ["telvanni peninsula"] = { zone = "Telvanni Peninsula", spot = "Necrom Archives", target = "Magisters & Scholars", loot = "Necrom & Telvanni Furnishing Plans", method = "Pickpocketing, Safeboxes & Container", type = "motif" },
    ["west weald"] = { zone = "West Weald", spot = "Skingrad Manors", target = "Colovian Nobles", loot = "Colovian / West Weald Furnishing Plans", method = "Container Looting", type = "plan" },
    ["solstice"] = { zone = "Solstice", spot = "Sunport High-Rollers", target = "Luxury Coffers", loot = "Solstice Tide-Born Style and Stone-Nest", method = "Container and Safebox", type = "plan" },
    ["hew's bane"] = { zone = "Hew's Bane", spot = "Abah's Landing Vaults", target = "Thief Lords", loot = "Redguard & Thieves Guild Furnishing Plans", method = "Pickpocketing & Safeboxes", type = "motif" },
    ["gold coast"] = { zone = "Gold Coast", spot = "Kvatch / Anvil", target = "Gold Coast Citizens", loot = "Order of the Hour / Dark Brotherhood Motifs", method = "Pickpocketing & Safeboxes", type = "motif" },
    ["wrothgar"] = { zone = "Wrothgar", spot = "Old Orsinium Stronghold", target = "Ancient Chests", loot = "Ancient Orc & Trinimac Epic Plans", method = "Container Looting", type = "plan" },
    ["clockwork city"] = { zone = "Clockwork City", spot = "Brass Fortress Enclave", target = "Factotums & High Citizens", loot = "Clockwork Blueprint and Diagram Furnishing Plans", method = "Pickpocketing & Safeboxes", type = "plan" },
    ["murkmire"] = { zone = "Murkmire", spot = "Lilmoth Trader Hubs", target = "Saxhleel Strongboxes", loot = "Murkmire Furnishing Plans", method = "Pickpocketing", type = "plan" },
    ["southern elsweyr"] = { zone = "Southern Elsweyr", spot = "Senchal Vaults", target = "Dragonguard Quarters", loot = "Elsweyr Furnishing Plans", method = "Pickpocketing & Safeboxes", type = "plan" },
    ["blackwood"] = { zone = "Blackwood", spot = "Leyawiin Castles", target = "Noble Quarters", loot = "Leyawiin Epic Blueprints & Diagrams", method = "Container and Safebox", type = "plan" },
    ["the reach"] = { zone = "The Reach", spot = "Markarth Chieftain Quarters", target = "Reach Masters", loot = "Vampiric & Reach-Style Plans", method = "Pickpocketing & Safeboxes", type = "plan" },
    ["arkthzand cavern"] = { zone = "Arkthzand Cavern", spot = "Dwarven Ruins", target = "Ancient Desks", loot = "Markarth / Dwarven Furnishing Plans", method = "Container Looting", type = "plan" },
    ["the deadlands"] = { zone = "The Deadlands", spot = "Fargrave Faction Elite", target = "Dremora Lords", loot = "Deadlands Furnishing Plans", method = "Pickpocketing & Container", type = "plan" },
    ["fargrave"] = { zone = "Fargrave", spot = "The Shambles", target = "Luxury Containers", loot = "Fargrave-themed Furnishing Plans", method = "Stealing from Containers", type = "plan" },
    ["apocrypha"] = { zone = "Apocrypha", spot = "Fringe Archives Deep", target = "Seeker Tomes", loot = "Apocrypha Master Epic Plans", method = "Container Looting", type = "plan" },
    ["imperial city"] = { zone = "Imperial City", spot = "Noble Districts", target = "Xivkyn Generals", loot = "Xivkyn Master Motifs", method = "Elite Vault Chests", type = "motif" },
}

MasterThief.ZoneAlias = {
    ["vivec city"] = "vvardenfell", ["vardenfell"] = "vvardenfell", ["sadrith mora"] = "vvardenfell", ["gnisis"] = "vvardenfell", ["balmora"] = "vvardenfell",
    ["summerset"] = "summerset", ["shimmerene"] = "summerset", ["artaeum"] = "summerset",
    ["northern elsweyr"] = "northern elsweyr", ["rimmen"] = "northern elsweyr", ["southern elsweyr"] = "southern elsweyr", ["senchal"] = "southern elsweyr",
    ["western skyrim"] = "western skyrim", ["solitude"] = "western skyrim", 
    ["the reach"] = "the reach", ["markarth"] = "the reach",
    ["arkthzand cavern"] = "arkthzand cavern", ["arkthzand"] = "arkthzand cavern",
    ["high isle"] = "high isle", ["gonfalon bay"] = "high isle", ["amenos"] = "high isle",
    ["galen"] = "galen", ["vastyr"] = "galen",
    ["telvanni peninsula"] = "telvanni peninsula", ["necrom"] = "telvanni peninsula", 
    ["apocrypha"] = "apocrypha", ["fringe archives"] = "apocrypha",
    ["west weald"] = "west weald", ["skingrad"] = "west weald",
    ["solstice"] = "solstice", ["sunport"] = "solstice",
    ["hew's bane"] = "hew's bane", ["abah's landing"] = "hew's bane",
    ["gold coast"] = "gold coast", ["anvil"] = "gold coast", ["kvatch"] = "gold coast",
    ["wrothgar"] = "wrothgar", ["orsinium"] = "wrothgar",
    ["clockwork city"] = "clockwork city", ["brass fortress"] = "clockwork city",
    ["murkmire"] = "murkmire", ["lilmoth"] = "murkmire",
    ["blackwood"] = "blackwood", ["leyawiin"] = "blackwood",
    ["the deadlands"] = "the deadlands", ["deadlands"] = "the deadlands", 
    ["fargrave"] = "fargrave", ["the shambles"] = "fargrave",
    ["imperial city"] = "imperial city",
}

-----------------------------------------------------------
-- 1. HELPERS & DEBUG LOGGER
-----------------------------------------------------------
function MasterThief.DebugLog(msg)
    if MasterThief.savedVars and MasterThief.savedVars.debugMode then
        CHAT_ROUTER:AddSystemMessage(string.format("|cFFD700[MasterThief Debug]|r %s", tostring(msg)))
    end
end

function MasterThief.GetCustomFont(size)
    return string.format("$(CHAT_FONT)|%d|soft-shadow-thick", size or 11)
end

function MasterThief.GetCurrentZoneID()
    local name = GetMapName()
    if not name or name == "" or name == "Tamriel" then
        name = GetZoneText()
    end
    if not name or name == "" then return "unknown", "Unknown" end
    
    local cleanName = string.lower(name)
    return MasterThief.ZoneAlias[cleanName] or cleanName, name
end

function MasterThief.GetActiveCharacterStats()
    if not MasterThief.savedVars then return nil end
    MasterThief.savedVars.charStats = MasterThief.savedVars.charStats or {}
    
    local charName = GetUnitName("player")
    if not charName or charName == "" then charName = "Default" end
    
    if not MasterThief.savedVars.charStats[charName] then
        MasterThief.savedVars.charStats[charName] = {
            totalPickpockets = 0,
            greenLoot = 0,
            blueLoot = 0,
            purpleLoot = 0,
        }
    end
    return MasterThief.savedVars.charStats[charName]
end

-----------------------------------------------------------
-- 2. EVENT TRACKERS & HOOKS
-----------------------------------------------------------
function MasterThief.OnInventorySlotUpdate(eventCode, bagId, slotIndex, isNew, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    if not MasterThief.savedVars or not MasterThief.savedVars.unlocked then return end
    if type(bagId) ~= "number" or bagId ~= BAG_BACKPACK then return end

    if isNew and IsItemStolen(bagId, slotIndex) then
        local link = GetItemLink(bagId, slotIndex)
        local quality = GetItemLinkDisplayQuality(link) or 1
        if quality <= 1 and link then
            if string.find(link, "a335ee") then quality = 4
            elseif string.find(link, "3a92ff") then quality = 3
            elseif string.find(link, "2dc800") then quality = 2 end
        end
        quality = tonumber(quality) or 1

        local delta = (type(stackCountChange) == "number" and stackCountChange > 0) and stackCountChange or 1
        local stats = MasterThief.GetActiveCharacterStats()
        stats.totalPickpockets = (tonumber(stats.totalPickpockets) or 0) + 1

        if quality == 2 then
            stats.greenLoot = (tonumber(stats.greenLoot) or 0) + delta
        elseif quality == 3 then
            stats.blueLoot = (tonumber(stats.blueLoot) or 0) + delta
        elseif quality >= 4 then
            stats.purpleLoot = (tonumber(stats.purpleLoot) or 0) + delta
            MasterThief.savedVars.cooldowns = MasterThief.savedVars.cooldowns or {}
            local routeID = MasterThief.GetCurrentZoneID()
            -- Set 20 hours cooldown (20 * 3600 seconds = 72000 seconds)
            MasterThief.savedVars.cooldowns[routeID] = GetTimeStamp() + 72000
        end

        MasterThief.UpdateHUDContent()
    end
end

-----------------------------------------------------------
-- 3. HUD & DISPLAY LOGIC
-----------------------------------------------------------
function MasterThief.ApplyPosition()
    if not MasterThief.hudFrame then return end
    MasterThief.hudFrame:ClearAnchors()
    MasterThief.hudFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MasterThief.savedVars.posX or 60, MasterThief.savedVars.posY or 100)
end

function MasterThief.CreateHUD()
    if MasterThief.hudFrame then return end

    local wm = WINDOW_MANAGER
    local mainFrame = wm:CreateTopLevelWindow("MasterThiefHUD")
    mainFrame:SetMovable(true)
    mainFrame:SetMouseEnabled(true)
    mainFrame:SetClampedToScreen(true)

    MasterThief.hudFrame = mainFrame

    mainFrame:SetHandler("OnMoveStop", function(self)
        MasterThief.savedVars.posX = self:GetLeft()
        MasterThief.savedVars.posY = self:GetTop()
        if LibAddonMenu2 and MasterThief.optionsPanel then
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MasterThief.optionsPanel)
        end
    end)

    local content = wm:CreateControl("$(parent)Content", mainFrame, CT_LABEL)
    content:SetAnchor(TOPLEFT, mainFrame, TOPLEFT, 12, 12)
    MasterThief.contentLabel = content

    MasterThief.UpdateHUDContent()
    MasterThief.ApplyPosition()
    
    local showHUD = MasterThief.savedVars.showHUD and MasterThief.savedVars.unlocked
    MasterThief.hudFrame:SetHidden(not showHUD)
end

function MasterThief.UpdateHUDContent()
    if not MasterThief.contentLabel or not MasterThief.hudFrame then return end

    if not MasterThief.savedVars.unlocked then
        MasterThief.contentLabel:SetFont(MasterThief.GetCustomFont(11))
        MasterThief.contentLabel:SetWidth(410)
        MasterThief.hudFrame:SetDimensions(434, 48)
        return
    end

    local fontSize = MasterThief.savedVars.fontSize or 11
    MasterThief.contentLabel:SetFont(MasterThief.GetCustomFont(fontSize))
    MasterThief.contentLabel:SetWidth(410)

    local routeID, rawZoneName = MasterThief.GetCurrentZoneID()
    local route = MasterThief.RoutesByID[routeID]

    local buffer = { "|cFFD700[ MASTER THIEF: ELITE ]|r" }

    if route then
        local isCompleted = MasterThief.savedVars.completedZones[routeID] or false
        local showCategory = (route.type == "motif" and MasterThief.savedVars.showMotifs) or 
                             (route.type == "plan" and MasterThief.savedVars.showPlans)
        
        if showCategory and not (MasterThief.savedVars.hideCompleted and isCompleted) then
            local color = isCompleted and "|c00FF00" or "|c00BFFF"
            table.insert(buffer, string.format("%s%s|r |cAAAAAA(%s)|r", color, route.zone, route.spot))
            table.insert(buffer, string.format("  |cFFD700->|r |cFFFFFF%s|r", route.loot))
            table.insert(buffer, string.format("  |cFF99FF[Method: %s]|r", route.method))
            
            MasterThief.savedVars.cooldowns = MasterThief.savedVars.cooldowns or {}
            local expiryTime = MasterThief.savedVars.cooldowns[routeID]
            local currentTime = GetTimeStamp()
            
            if expiryTime and currentTime < expiryTime then
                local remainingHours = math.ceil((expiryTime - currentTime) / 3600)
                table.insert(buffer, string.format("  |cFF5555[CD ACTIVE: ~%d hrs remaining (Switch Alt!)]|r", remainingHours))
            else
                table.insert(buffer, "  |c55FF55[Status: Ready to Farm / No CD]|r")
            end
        else
            table.insert(buffer, "\n|c888888Route hidden by active filter options.|r")
        end
    else
        table.insert(buffer, string.format("\n|c888888No active route configured for:\n|cFF5555%s|r", rawZoneName))
    end

    local stats = MasterThief.GetActiveCharacterStats()

    table.insert(buffer, "\n|cFFD700--- SESSION DROPS ---|r")
    table.insert(buffer, string.format("Drops: |c2DC800%d Green|r | |c3A92FF%d Blue|r | |cA335EE%d Purple|r", stats.greenLoot or 0, stats.blueLoot or 0, stats.purpleLoot or 0))

    local textOutput = table.concat(buffer, "\n")
    MasterThief.contentLabel:SetText(textOutput)

    local height = MasterThief.contentLabel:GetTextHeight()
    MasterThief.hudFrame:SetDimensions(434, height + 24)
end

-----------------------------------------------------------
-- 4. SETTINGS PANEL (LibAddonMenu2)
-----------------------------------------------------------
function MasterThief.CreateSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelName = "MasterThief_OptionsPanel"
    local panelData = {
        type = "panel",
        name = "Master Thief Elite",
        displayName = "|cFFD700Master Thief Elite Settings|r",
        author = "Thief",
        version = "1.0",
        slashCommand = "/thiefsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    MasterThief.optionsPanel = LAM:RegisterAddonPanel(panelName, panelData)

    local optionsData = {
        { type = "header", name = "Display & Behavior" },
        {
            type = "checkbox",
            name = "Enable Debug Logging",
            getFunc = function() return MasterThief.savedVars.debugMode end,
            setFunc = function(value) MasterThief.savedVars.debugMode = value end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Show Route Guide HUD",
            getFunc = function() return MasterThief.savedVars.showHUD end,
            setFunc = function(value)
                MasterThief.savedVars.showHUD = value
                if MasterThief.hudFrame and MasterThief.savedVars.unlocked then 
                    MasterThief.hudFrame:SetHidden(not value) 
                end
            end,
            default = MasterThief.defaultSettings.showHUD,
        },
        {
            type = "button", 
            name = "Reset Session Pickpocket Stats (Current Character)", 
            func = function()
                local stats = MasterThief.GetActiveCharacterStats()
                stats.totalPickpockets = 0
                stats.greenLoot = 0
                stats.blueLoot = 0
                stats.purpleLoot = 0
                MasterThief.UpdateHUDContent()
                MasterThief.DebugLog("Character Session Statistics Reset.")
            end 
        },
        {
            type = "button", 
            name = "Clear All Zone Cooldowns", 
            func = function()
                MasterThief.savedVars.cooldowns = {}
                MasterThief.UpdateHUDContent()
                MasterThief.DebugLog("Zone cooldowns cleared.")
            end 
        },
        { type = "header", name = "Layout Controls" },
        {
            type = "slider",
            name = "Text Size",
            min = 9, max = 24, step = 1,
            getFunc = function() return MasterThief.savedVars.fontSize end,
            setFunc = function(value) MasterThief.savedVars.fontSize = value; MasterThief.UpdateHUDContent() end,
            default = MasterThief.defaultSettings.fontSize,
        },
        {
            type = "slider",
            name = "X Position",
            min = 0, max = 2000, step = 5,
            getFunc = function() return MasterThief.savedVars.posX end,
            setFunc = function(value) MasterThief.savedVars.posX = value; MasterThief.ApplyPosition() end,
            default = MasterThief.defaultSettings.posX,
        },
        {
            type = "slider",
            name = "Y Position",
            min = 0, max = 1200, step = 5,
            getFunc = function() return MasterThief.savedVars.posY end,
            setFunc = function(value) MasterThief.savedVars.posY = value; MasterThief.ApplyPosition() end,
            default = MasterThief.defaultSettings.posY,
        },
        { type = "header", name = "Zone Completion Trackers" }
    }

    for key, r in pairs(MasterThief.RoutesByID) do
        table.insert(optionsData, {
            type = "checkbox",
            name = string.format("Completed: %s (%s)", r.zone, r.spot),
            getFunc = function() return MasterThief.savedVars.completedZones[key] or false end,
            setFunc = function(value)
                MasterThief.savedVars.completedZones[key] = value
                MasterThief.UpdateHUDContent()
            end,
            default = false,
        })
    end

    LAM:RegisterOptionControls(panelName, optionsData)
end

-----------------------------------------------------------
-- 5. INITIALIZATION & EVENT REGISTRATION
-----------------------------------------------------------
function MasterThief.Initialize()
    MasterThief.savedVars = ZO_SavedVars:NewAccountWide("MasterThief_SavedVars", 1, nil, MasterThief.defaultSettings)
    
    MasterThief.CreateHUD()
    MasterThief.CreateSettingsPanel()

    local function DelayedUpdate()
        zo_callLater(MasterThief.UpdateHUDContent, 500)
    end

    EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_PLAYER_ACTIVATED, DelayedUpdate)
    EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_ZONE_CHANGED, DelayedUpdate)
    EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, MasterThief.OnInventorySlotUpdate)
    EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_MONEY_UPDATE, DelayedUpdate)

    SLASH_COMMANDS["/thief"] = function()
        if MasterThief.hudFrame and MasterThief.savedVars.unlocked then
            local newState = not MasterThief.savedVars.showHUD
            MasterThief.savedVars.showHUD = newState
            MasterThief.hudFrame:SetHidden(not newState)
        else
            CHAT_ROUTER:AddSystemMessage("|cFF5555[MasterThief]|r Addon is locked. Type /thiefunlock unlock wiz0214 first.")
        end
    end

    SLASH_COMMANDS["/thiefdebug"] = function()
        if MasterThief.savedVars.unlocked then
            MasterThief.savedVars.debugMode = not MasterThief.savedVars.debugMode
            CHAT_ROUTER:AddSystemMessage(string.format("|c00FF00[MasterThief]|r Debug Mode toggled: %s", tostring(MasterThief.savedVars.debugMode)))
        end
    end

    SLASH_COMMANDS["/resetthiefstats"] = function()
        if MasterThief.savedVars.unlocked then
            local stats = MasterThief.GetActiveCharacterStats()
            stats.totalPickpockets = 0
            stats.greenLoot = 0
            stats.blueLoot = 0
            stats.purpleLoot = 0
            MasterThief.UpdateHUDContent()
            CHAT_ROUTER:AddSystemMessage("|c00FF00[MasterThief]|r Character session statistics resetted.")
        end
    end

    SLASH_COMMANDS["/hi"] = function(text)
        if text == "wiz0214" then
            MasterThief.savedVars.unlocked = true
            CHAT_ROUTER:AddSystemMessage("|c00FF00[MasterThief]|r Access granted! Master Thief features unlocked.")
            if MasterThief.hudFrame then
                MasterThief.hudFrame:SetHidden(not MasterThief.savedVars.showHUD)
            end
            MasterThief.UpdateHUDContent()
        else
            CHAT_ROUTER:AddSystemMessage("|cFF5555[MasterThief]|r Incorrect password.")
        end
    end

    if not MasterThief.savedVars.unlocked then
        CHAT_ROUTER:AddSystemMessage("|cFF5555[MasterThief] Addon Locked.|r Type |cFFFFFF/thiefunlock unlock wiz0214|r to activate.")
    end
end

EVENT_MANAGER:RegisterForEvent(MasterThief.name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= MasterThief.name then return end
    MasterThief.Initialize()
    EVENT_MANAGER:UnregisterForEvent(MasterThief.name, EVENT_ADD_ON_LOADED)
end)