-- RareFishTracker Integration with DovahMova
-- Інтеграція RareFishTracker з DovahMova
-- Автор: DovahMova Team

if GetCVar("language.2") ~= "ua" then
    return
end

local RareFishTrackerIntegration = {}
RareFishTrackerIntegration.name = "RareFishTrackerUA"
RareFishTrackerIntegration.isInitialized = false

-- Функція ініціалізації
function RareFishTrackerIntegration:Initialize()
    -- Перевіряємо чи RareFishTracker вже завантажений
    if not RFT then
        -- Якщо RareFishTracker ще не завантажений, чекаємо його завантаження
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
            if addonName == "RareFishTracker" then
                EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
                -- Застосовуємо переклади після завантаження аддона
                zo_callLater(function()
                    self:ApplyTranslations()
                end, 100)
            end
        end)
        return
    end
    
    -- Якщо RareFishTracker вже завантажений, застосовуємо переклади
    self:ApplyTranslations()
end

-- Застосовуємо переклади
function RareFishTrackerIntegration:ApplyTranslations()
    -- Переклади вже застосовані через ua.lua
    
    -- FIX: Overwrite RFT functions to ensure consistent naming and "UA (EN)" format
    if RFT then
        -- Check if RFT is fully initialized (CatchTracker loaded)
        if not RFT.GetAchievementCriterion then
            if d then d("DovahMova: RFT not fully initialized, retrying in 500ms...") end
            zo_callLater(function() self:ApplyTranslations() end, 500)
            return
        end

        local originalScan = RFT.ScanAchievementsById
        local originalRecord = RFT.RecordProgress
        
        -- Helper to get fish name with optional English postfix
        local function GetFishName(itemLink)
            local name = GetItemLinkName(itemLink)
            
            -- Check if we need to add English postfix
            if DovahMova and DovahMova.Settings and (DovahMova.Settings.ShowLocations == "uaen" or DovahMova.Settings.ShowItemsDisplay == "uaen") then
                -- If name doesn't already have parentheses (simple check)
                if not string.find(name, "%(") then
                    local itemId = GetItemLinkItemId(itemLink)
                    if itemId then
                        -- Try to find English name in DovahMova database
                        local rsv = DovahMova.Settings.Data
                        if rsv and rsv.Items and rsv.Items[itemId] then
                            local enName = rsv.Items[itemId]
                            -- DovahMova stores "Name" or "Name (EN)"? 
                            -- Usually Items[id] stores English name if enDump ran.
                            -- But let's verify format. Usually it's just the name.
                            if enName and enName ~= "" and enName ~= name then
                                return name .. " (" .. enName .. ")"
                            end
                        end
                    end
                end
            end
            
            return name
        end
        
        -- Overwrite ScanAchievementsById
        RFT.ScanAchievementsById = function(id)
            RFT.progress[id] = {}
            RFT.fishnames[id] = {}
            RFT.fishIcons[id] = {}
            RFT.achnames[id] = GetAchievementInfo(id)
            local numCrit = GetAchievementNumCriteria(id)
            -- Use our custom name getter
            local giln = GetFishName
            local GetItemLinkInfo = GetItemLinkInfo
            local strformat = string.format
            local progress, fishnames, itemLinks, fishIcons = RFT.progress[id], RFT.fishnames[id], RFT.achievementToItem[id], RFT.fishIcons[id]
        
            local desc, done, itemLink, icon
            for j = 1, numCrit, 1 do
                desc, done = RFT:GetAchievementCriterion(id, j)
                if itemLinks then
                    itemLink = itemLinks[j]
                    if itemLink then
                        itemLink = strformat("|H1:item:%i:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h", itemLink)
                        desc = giln(itemLink)
                        icon = GetItemLinkInfo(itemLink)
                    end
                end
                progress[desc] = done
                fishnames[#fishnames + 1] = desc
                fishIcons[#fishIcons + 1] = icon
            end
        end
        
        -- Overwrite RecordProgress
        RFT.RecordProgress = function(achieveId)
            local _, _, _, icon = GetAchievementInfo(achieveId)
            local numCrit = GetAchievementNumCriteria(achieveId)
        
            -- Use our custom name getter
            local itemLinks, giln, GetItemLinkInfo = RFT.achievementToItem[achieveId], GetFishName, GetItemLinkInfo
            local format = string.format
            for i = 1, numCrit, 1 do
                local desc, done = RFT:GetAchievementCriterion(achieveId, i)
                if itemLinks then
                    local itemLink = itemLinks[i]
                    if itemLink then
                        itemLink = format("|H1:item:%i:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h", itemLink)
                        desc = giln(itemLink)
                        icon = GetItemLinkInfo(itemLink)
                    end
                end
                
                -- Ensure the entry exists before checking/updating
                if RFT.progress[achieveId] then
                    if RFT.progress[achieveId][desc] ~= done then
                        RFT.progress[achieveId][desc] = done
                        -- Update: You can catch more than one fish (due to CPs?), even two for achievement.
                        -- Use zo_strformat to handle potential formatting issues
                        local safeDesc = zo_strformat("<<1>>", desc)
                        local message = zo_strformat("<<1>> <<2>>", zo_iconFormat(icon, 30, 30), safeDesc)
                        
                        -- Call ShowAnnouncement (local in RFT, but we can't access it easily)
                        -- So we reimplement it or use CenterScreenAnnounce directly
                        local CSA = CENTER_SCREEN_ANNOUNCE
                        local params = CSA:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.QUEST_OBJECTIVE_INCREMENT)
                        params:SetSound(SOUNDS.QUEST_OBJECTIVE_INCREMENT)
                        params:SetText(message)
                        params:MarkSuppressIconFrame()
                        params:MarkShowImmediately()
                        CSA:QueueMessage(params)
                    end
                end
            end
        end
        
        -- Force rescan to apply new names
        RFT:RescanAchievements()
        RFT.RefreshWindow()
    end
    
    self.isInitialized = true
end

-- Функція отримання інформації про інтеграцію
function RareFishTrackerIntegration:GetInfo()
    return {
        name = self.name,
        initialized = self.isInitialized,
        compatible = true,
        message = "Українська локалізація RareFishTracker"
    }
end

-- Реєструємо інтеграцію в DovahMova
if DovahMova and DovahMova.integrations then
    DovahMova.integrations[RareFishTrackerIntegration.name] = RareFishTrackerIntegration
end

-- Ініціалізуємо
RareFishTrackerIntegration:Initialize()

-- Експортуємо глобально для доступу ззовні
_G["DovahMova_RareFishTrackerIntegration"] = RareFishTrackerIntegration
