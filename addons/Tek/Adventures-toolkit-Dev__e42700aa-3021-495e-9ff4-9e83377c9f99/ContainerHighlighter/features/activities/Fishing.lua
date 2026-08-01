-- ============================================
-- FISHING TRACKER MODULE - MASTER ANGLER
-- ============================================

NWT.FishingDashboard = { 
    isOpen = false, 
    sceneInitialized = false,
    selectedZoneIndex = 1,
    zoneScrollOffset = 0,
    achievementCache = {},
}

-- Master Angler meta-achievement ID (Master Fisher)
local MASTER_ANGLER_ID = 706

-- Zone fishing achievements required for Master Angler (base game only, no DLC)
-- Total: 207 fish across 18 zone achievements
local ZONE_ACHIEVEMENTS = {
    -- Daggerfall Covenant (60 fish)
    { id = 471, zone = "Glenumbra" },
    { id = 472, zone = "Stormhaven" },
    { id = 473, zone = "Rivenspire" },
    { id = 474, zone = "Alik'r Desert" },
    { id = 475, zone = "Bangkorai" },
    -- Ebonheart Pact (60 fish)
    { id = 477, zone = "Stonefalls" },
    { id = 478, zone = "Deshaan" },
    { id = 479, zone = "Shadowfen" },
    { id = 480, zone = "Eastmarch" },
    { id = 481, zone = "The Rift" },
    -- Aldmeri Dominion (60 fish)
    { id = 483, zone = "Auridon" },
    { id = 484, zone = "Grahtwood" },
    { id = 485, zone = "Greenshade" },
    { id = 486, zone = "Malabal Tor" },
    { id = 487, zone = "Reaper's March" },
    -- Starter zones (3 fish total - 1 each)
    { id = 491, zone = "Stros M'Kai" },
    { id = 492, zone = "Khenarthi's Roost" },
    { id = 493, zone = "Bleakrock Isle" },
    -- Other base game (24 fish)
    { id = 489, zone = "Cyrodiil" },
    { id = 490, zone = "Coldharbour" },
}

local MAX_VISIBLE_ZONES = 16
local MAX_VISIBLE_FISH = 12

local function FormatDuration(seconds)
    if not seconds or seconds <= 0 then return "0:00" end
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return hours > 0 and string.format("%d:%02d:%02d", hours, mins, secs) or string.format("%d:%02d", mins, secs)
end

-- Get achievement info with caching
local function GetZoneAchievementData(achievementId)
    if NWT.FishingDashboard.achievementCache[achievementId] then
        return NWT.FishingDashboard.achievementCache[achievementId]
    end
    
    local name, desc, points, icon, completed, date, time = GetAchievementInfo(achievementId)
    local numCriteria = GetAchievementNumCriteria(achievementId)
    local criteria = {}
    local completedCount = 0
    
    for i = 1, numCriteria do
        local critName, numCompleted, numRequired = GetAchievementCriterion(achievementId, i)
        local isCritCompleted = numCompleted >= numRequired
        if isCritCompleted then completedCount = completedCount + 1 end
        table.insert(criteria, {
            name = critName,
            completed = isCritCompleted,
            numCompleted = numCompleted,
            numRequired = numRequired,
        })
    end
    
    local data = {
        id = achievementId,
        name = name or "Unknown",
        completed = completed,
        criteria = criteria,
        numCriteria = numCriteria,
        completedCriteria = completedCount,
    }
    
    NWT.FishingDashboard.achievementCache[achievementId] = data
    return data
end

-- Refresh achievement cache (call on achievement update events)
local function RefreshAchievementCache()
    NWT.FishingDashboard.achievementCache = {}
end

-- Get Master Angler overall progress
local function GetMasterAnglerProgress()
    local totalZones = #ZONE_ACHIEVEMENTS
    local completedZones = 0
    local totalFish = 0
    local caughtFish = 0
    
    for _, zone in ipairs(ZONE_ACHIEVEMENTS) do
        local data = GetZoneAchievementData(zone.id)
        if data.completed then
            completedZones = completedZones + 1
        end
        totalFish = totalFish + data.numCriteria
        caughtFish = caughtFish + data.completedCriteria
    end
    
    local _, _, _, _, masterCompleted = GetAchievementInfo(MASTER_ANGLER_ID)
    
    return {
        zonesComplete = completedZones,
        totalZones = totalZones,
        fishCaught = caughtFish,
        totalFish = totalFish,
        masterComplete = masterCompleted,
        percent = totalFish > 0 and math.floor((caughtFish / totalFish) * 100) or 0,
    }
end

function NWT.UpdateFishingUI()
    -- This function now only updates stats, does not control visibility
    -- UI visibility is controlled by scene manager (menu navigation only)
end

local function UpdateFishingDashboardStats()
    local ui = ATK_Fishing_UI
    if not ui then return end
    local sv = NWT.savedVars
    local fd = NWT.FishingDashboard
    
    -- Session stats
    local duration = sv.fishingSessionStart > 0 and GetTimeStamp() - sv.fishingSessionStart or 0
    local rate = duration > 0 and math.floor((sv.fishingSessionFish / duration) * 3600) or 0
    
    local leftCol = ui:GetNamedChild("LeftCol")
    if leftCol then
        local session = leftCol:GetNamedChild("SessionCard")
        if session then
            local c = session:GetNamedChild("Caught") if c then c:SetText("Fish: |cFFFFFF" .. (sv.fishingSessionFish or 0) .. "|r") end
            local d = session:GetNamedChild("Duration") if d then d:SetText("Time: |cFFFFFF" .. FormatDuration(duration) .. "|r") end
            local r = session:GetNamedChild("Rate") if r then r:SetText("Rate: |cFFFFFF" .. rate .. "/hr|r") end
            local ra = session:GetNamedChild("Rare") if ra then ra:SetText("Rare: |cFFFFFF" .. (sv.fishingSessionRare or 0) .. "|r") end
            local p = session:GetNamedChild("Perfect") if p then p:SetText("Perfect: |cFFFFFF" .. (sv.fishingSessionPerfect or 0) .. "|r") end
        end
        
        -- Master Angler progress
        local master = leftCol:GetNamedChild("MasterCard")
        if master then
            local progress = GetMasterAnglerProgress()
            local status = master:GetNamedChild("Status")
            if status then
                if progress.masterComplete then
                    status:SetText("|c00FF00COMPLETE!|r")
                else
                    status:SetText("|cFFFF00In Progress|r")
                end
            end
            local zc = master:GetNamedChild("ZonesComplete") if zc then zc:SetText("Zones: |cFFFFFF" .. progress.zonesComplete .. "/" .. progress.totalZones .. "|r") end
            local tf = master:GetNamedChild("TotalFish") if tf then tf:SetText("Total: |cFFFFFF" .. (sv.fishingTotalFish or 0) .. "|r") end
            local rc = master:GetNamedChild("RareCaught") if rc then rc:SetText("Rare Caught: |c00FF00" .. progress.fishCaught .. "|r") end
            local rn = master:GetNamedChild("RareNeeded") if rn then rn:SetText("Rare Needed: |cFF6600" .. (progress.totalFish - progress.fishCaught) .. "|r") end
            local pct = master:GetNamedChild("Percent") 
            if pct then 
                local color = progress.percent >= 100 and "00FF00" or (progress.percent >= 50 and "FFFF00" or "FF6600")
                pct:SetText("|c" .. color .. progress.percent .. "% Complete|r")
            end
        end
    end
    
    -- Zone achievements list (center column)
    local centerCol = ui:GetNamedChild("CenterCol")
    if centerCol then
        local header = centerCol:GetNamedChild("Header")
        if header then header:SetText("|cFFD700RARE FISH BY ZONE|r") end
        
        local subtitle = ui:GetNamedChild("HeaderSubtitle")
        if subtitle then
            local progress = GetMasterAnglerProgress()
            subtitle:SetText("|c888888Master Angler: " .. progress.zonesComplete .. "/" .. progress.totalZones .. " zones complete|r")
        end
        
        local zoneList = centerCol:GetNamedChild("ZoneList")
        if zoneList then
            for i = 1, MAX_VISIBLE_ZONES do
                local zoneLabel = zoneList:GetNamedChild("Zone" .. i)
                if zoneLabel then
                    local zoneIdx = fd.zoneScrollOffset + i
                    if zoneIdx <= #ZONE_ACHIEVEMENTS then
                        local zone = ZONE_ACHIEVEMENTS[zoneIdx]
                        local data = GetZoneAchievementData(zone.id)
                        local isSelected = (zoneIdx == fd.selectedZoneIndex)
                        
                        local statusIcon = data.completed and "|c00FF00[+]|r" or ("|cFFAA00[" .. data.completedCriteria .. "/" .. data.numCriteria .. "]|r")
                        local selectMarker = isSelected and "|cFFFFFF> |r" or "  "
                        local zoneColor = isSelected and "00FFFF" or (data.completed and "00FF00" or "FFFFFF")
                        
                        zoneLabel:SetText(selectMarker .. statusIcon .. " |c" .. zoneColor .. zone.zone .. "|r")
                        zoneLabel:SetHidden(false)
                    else
                        zoneLabel:SetHidden(true)
                    end
                end
            end
        end
    end
    
    -- Selected zone fish details (right column)
    local rightCol = ui:GetNamedChild("RightCol")
    if rightCol then
        local fishCard = rightCol:GetNamedChild("FishCard")
        if fishCard then
            local selectedZone = ZONE_ACHIEVEMENTS[fd.selectedZoneIndex]
            if selectedZone then
                local data = GetZoneAchievementData(selectedZone.id)
                
                local zoneName = fishCard:GetNamedChild("ZoneName")
                if zoneName then zoneName:SetText("|cFFD700" .. selectedZone.zone .. "|r") end
                
                local progress = fishCard:GetNamedChild("Progress")
                if progress then 
                    local color = data.completed and "00FF00" or "FFAA00"
                    progress:SetText("|c" .. color .. data.completedCriteria .. "/" .. data.numCriteria .. " Rare Fish|r")
                end
                
                -- Show fish for this zone
                for i = 1, MAX_VISIBLE_FISH do
                    local fishLabel = fishCard:GetNamedChild("Fish" .. i)
                    if fishLabel then
                        if data.criteria[i] then
                            local crit = data.criteria[i]
                            local icon = crit.completed and "|c00FF00[+]|r" or "|cFF0000[-]|r"
                            local nameColor = crit.completed and "888888" or "FFFFFF"
                            fishLabel:SetText(icon .. " |c" .. nameColor .. crit.name .. "|r")
                            fishLabel:SetHidden(false)
                        else
                            fishLabel:SetHidden(true)
                        end
                    end
                end
            end
        end
    end
end

-- Navigate zones
local function NavigateZones(direction)
    local fd = NWT.FishingDashboard
    local newIndex = fd.selectedZoneIndex + direction
    
    if newIndex < 1 then newIndex = #ZONE_ACHIEVEMENTS
    elseif newIndex > #ZONE_ACHIEVEMENTS then newIndex = 1 end
    
    fd.selectedZoneIndex = newIndex
    
    -- Adjust scroll offset to keep selection visible
    if newIndex <= fd.zoneScrollOffset then
        fd.zoneScrollOffset = newIndex - 1
    elseif newIndex > fd.zoneScrollOffset + MAX_VISIBLE_ZONES then
        fd.zoneScrollOffset = newIndex - MAX_VISIBLE_ZONES
    end
    
    fd.zoneScrollOffset = math.max(0, math.min(fd.zoneScrollOffset, #ZONE_ACHIEVEMENTS - MAX_VISIBLE_ZONES))
    
    UpdateFishingDashboardStats()
    PlaySound(SOUNDS.DEFAULT_CLICK)
end

-- Find a wayshrine in the selected zone for fast travel
local function TravelToSelectedZone()
    local selectedZone = ZONE_ACHIEVEMENTS[NWT.FishingDashboard.selectedZoneIndex]
    if not selectedZone then return end
    
    local numNodes = GetNumFastTravelNodes()
    for i = 1, numNodes do
        local known, name, _, _, _, _, poiType, isShown = GetFastTravelNodeInfo(i)
        if known and poiType == POI_TYPE_WAYSHRINE then
            local zoneIndex, poiIndex = GetFastTravelNodePOIIndicies(i)
            local zoneName = GetZoneNameById(GetZoneId(zoneIndex))
            if zoneName and zo_plainstrfind(zoneName:lower(), selectedZone.zone:lower()) then
                FastTravelToNode(i)
                NWT.CloseFishingDashboard()
                return
            end
        end
    end
end

NWT.FishingKeybindGroup = {
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    {
        name = "Travel to Zone", keybind = "UI_SHORTCUT_PRIMARY",
        callback = TravelToSelectedZone,
    },
    {
        name = function()
            local sessionStart = NWT.savedVars.fishingSessionStart or 0
            return sessionStart > 0 and "Reset Session" or "Start Session"
        end,
        keybind = "UI_SHORTCUT_SECONDARY",
        callback = function()
            local sessionStart = NWT.savedVars.fishingSessionStart or 0
            if sessionStart > 0 then
                -- Reset existing session
                NWT.savedVars.fishingSessionFish = 0
                NWT.savedVars.fishingSessionStart = 0
                NWT.savedVars.fishingSessionRare = 0
                NWT.savedVars.fishingSessionPerfect = 0
            else
                -- Start new session
                NWT.savedVars.fishingSessionStart = GetTimeStamp()
                NWT.savedVars.fishingSessionFish = 0
                NWT.savedVars.fishingSessionRare = 0
                NWT.savedVars.fishingSessionPerfect = 0
            end
            UpdateFishingDashboardStats()
            KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.FishingKeybindGroup)
            PlaySound(SOUNDS.POSITIVE_CLICK)
        end,
    },
    {
        name = "Clear All", keybind = "UI_SHORTCUT_TERTIARY",
        callback = function()
            NWT.savedVars.fishingSessionFish = 0
            NWT.savedVars.fishingSessionStart = 0
            NWT.savedVars.fishingSessionRare = 0
            NWT.savedVars.fishingSessionPerfect = 0
            NWT.savedVars.fishingTotalFish = 0
            UpdateFishingDashboardStats()
            NWT.UpdateFishingUI()
            PlaySound(SOUNDS.POSITIVE_CLICK)
        end,
    },
    {
        name = "Prev Zone", keybind = "UI_SHORTCUT_LEFT_SHOULDER",
        callback = function() NavigateZones(-1) end,
    },
    {
        name = "Next Zone", keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
        callback = function() NavigateZones(1) end,
    },
}
ZO_Gamepad_AddBackNavigationKeybindDescriptors(NWT.FishingKeybindGroup, GAME_NAVIGATION_TYPE_BUTTON, function() NWT.CloseFishingDashboard() end)

function NWT.InitFishingDashboardScene()
    if NWT.FishingDashboard.sceneInitialized then return end
    local ui = ATK_Fishing_UI
    if not ui then return end
    FISHING_DASHBOARD_SCENE = ZO_Scene:New("fishingDashboardScene", SCENE_MANAGER)
    FISHING_DASHBOARD_SCENE:AddFragment(ZO_HUDFadeSceneFragment:New(ui))
    FISHING_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    FISHING_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    FISHING_DASHBOARD_SCENE:RegisterCallback("StateChange", function(os, ns)
        if ns == SCENE_SHOWING then
            NWT.FishingDashboard.isOpen = true
            RefreshAchievementCache()
            UpdateFishingDashboardStats()
            if KEYBIND_STRIP then KEYBIND_STRIP:AddKeybindButtonGroup(NWT.FishingKeybindGroup) end
            EVENT_MANAGER:RegisterForUpdate("FishingDashboardUpdate", 1000, UpdateFishingDashboardStats)
        elseif ns == SCENE_HIDDEN then
            NWT.FishingDashboard.isOpen = false
            if KEYBIND_STRIP then KEYBIND_STRIP:RemoveKeybindButtonGroup(NWT.FishingKeybindGroup) end
            EVENT_MANAGER:UnregisterForUpdate("FishingDashboardUpdate")
        end
    end)
    NWT.FishingDashboard.sceneInitialized = true
end

function NWT.OpenFishingDashboard()
    if NWT.FishingDashboard.isOpen then return end
    if not FISHING_DASHBOARD_SCENE then NWT.InitFishingDashboardScene() end
    SCENE_MANAGER:Push("fishingDashboardScene")
end

function NWT.CloseFishingDashboard()
    if FISHING_DASHBOARD_SCENE then SCENE_MANAGER:Hide("fishingDashboardScene") end
end

function NWT.OnActionLayerChanged(eventCode, layerIndex, activeLayerIndex)
    -- No longer auto-shows UI - controlled by scene manager only
end

function NWT.OnFishingLureSet(eventCode, fishingLure)
    if not NWT.savedVars.fishingEnabled then return end
    if NWT.savedVars.fishingSessionStart == 0 then
        NWT.savedVars.fishingSessionStart = GetTimeStamp()
    end
end

function NWT.OnFishingLootReceived(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, isSelf, isPickpocket, questItemIcon, itemId, isStolen)
    if not isSelf or not itemId or itemId == 0 or not NWT.savedVars or not NWT.savedVars.fishingEnabled then return end
    local link = string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
    local it, st = GetItemLinkItemType(link)
    if it == ITEMTYPE_FISH or st == SPECIALIZED_ITEMTYPE_FISH then
        if NWT.savedVars.fishingSessionStart == 0 then NWT.savedVars.fishingSessionStart = GetTimeStamp() end
        local amt = quantity or 1
        NWT.savedVars.fishingSessionFish = (NWT.savedVars.fishingSessionFish or 0) + amt
        NWT.savedVars.fishingTotalFish = (NWT.savedVars.fishingTotalFish or 0) + amt
        
        -- Check if rare fish (quality >= ITEM_QUALITY_ARCANE)
        local quality = GetItemLinkQuality(link)
        if quality and quality >= ITEM_QUALITY_ARCANE then
            NWT.savedVars.fishingSessionRare = (NWT.savedVars.fishingSessionRare or 0) + amt
        end
        
        -- Refresh cache if dashboard open
        if NWT.FishingDashboard.isOpen then
            RefreshAchievementCache()
            UpdateFishingDashboardStats()
        end
    end
end

function NWT.OnFishingInventoryUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, itemId)
    if stackCountChange <= 0 or bagId ~= BAG_BACKPACK or not NWT.savedVars or not NWT.savedVars.fishingEnabled then return end
    if NWT.lastFishTime and (GetGameTimeMilliseconds() - NWT.lastFishTime) < 500 then return end
    local link = GetItemLink(bagId, slotIndex)
    if not link or link == "" then return end
    local it, st = GetItemLinkItemType(link)
    if it == ITEMTYPE_FISH or st == SPECIALIZED_ITEMTYPE_FISH then
        NWT.lastFishTime = GetGameTimeMilliseconds()
        if NWT.savedVars.fishingSessionStart == 0 then NWT.savedVars.fishingSessionStart = GetTimeStamp() end
        NWT.savedVars.fishingSessionFish = (NWT.savedVars.fishingSessionFish or 0) + stackCountChange
        NWT.savedVars.fishingTotalFish = (NWT.savedVars.fishingTotalFish or 0) + stackCountChange
    end
end

-- Achievement update handler
function NWT.OnFishingAchievementUpdated(eventCode, achievementId)
    -- Check if it's a fishing achievement
    for _, zone in ipairs(ZONE_ACHIEVEMENTS) do
        if zone.id == achievementId then
            RefreshAchievementCache()
            if NWT.FishingDashboard.isOpen then
                UpdateFishingDashboardStats()
            end
            break
        end
    end
end

function NWT.StartFishingUIUpdates()
    -- Register for achievement updates only - no auto-show UI updates
    EVENT_MANAGER:RegisterForEvent("FishingAchievementUpdate", EVENT_ACHIEVEMENT_UPDATED, NWT.OnFishingAchievementUpdated)
end
