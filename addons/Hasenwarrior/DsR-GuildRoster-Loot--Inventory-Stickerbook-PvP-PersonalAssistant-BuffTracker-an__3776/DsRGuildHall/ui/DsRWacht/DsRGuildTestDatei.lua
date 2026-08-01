-- Create namespace
DsRGuildTestDatei = {}
local DsRGuildTestDatei = DsRGuildTestDatei or {}

DsRGuildTestDatei.name = "DsRGuildTestDatei"

local LCM = LibCustomMenu
local LMM = LibMainMenu2
local LAM = LibAddonMenu2
local LMP = LibMapPins
local GPS = LibGPS3

-- ------------------------------------------------------


-- ------------------------------------------------------
-- LEER
-- ------------------------------------------------------
function DsRGuildTestDatei.TESTFUNCTION()
end


-- TRIBUTE_SUMMARY_BEGIN_VICTORY

-- ------------------------------------------------------
-- Guildmember in my zone
-- ------------------------------------------------------
-- function DsRGuildTestDatei.TESTFUNCTION()

--     for i = 1, 5 do
--         local guildId   = GetGuildId(i)
--         local guildName = GetGuildName(guildId)
--         if guildName == "Die sieben Raben" then
    
--             local guildId = GetGuildId(guildIndex)
--             local numMembers, numOnline = GetGuildInfo(guildId)
 
--             local myPlayerMemberIndex = GetPlayerGuildMemberIndex(guildId)
  
--             local _, My_x, My_y, My_z = GetUnitRawWorldPosition( "player" )
--             d("|cFAA0A0Meine Position:|r " .. My_x .. " , " .. My_y .. " , " .. My_z)
 
--             for memberIndex = 1, numMembers, 1 do
--                 if memberIndex ~= myPlayerMemberIndex then
--                     local memberName, _, _, memberStatus = GetGuildMemberInfo(guildId, memberIndex)
--                     local _, _, memberZone = GetGuildMemberCharacterInfo(guildId, memberIndex)
--                     if memberName ~= GetUnitDisplayName("player") then
--                         if memberZone == GetUnitZone("player") and memberStatus ~= PLAYER_STATUS_OFFLINE then
--                             d("|c6666FFGildenmember |r" .. memberName .. " |c6666FFin deiner Zone|r")
 
--                             local _, GM_x, GM_y, GM_z = GetUnitRawWorldPosition( memberName )
--                             d("|cFAA0A0Positon|r " .. memberName .. ": " .. GM_x .. " , " .. GM_y .. " , " .. GM_z)
--                         end
--                     end
--                 end
--             end
--             return
--         end
--     end
-- end

-- ------------------------------------------------------
-- Meine Live Position
-- ------------------------------------------------------
-- local function WorldPositionChanged()
--     local _, My_x, My_y, My_z          = GetUnitRawWorldPosition( "player" )
--     local player_x, player_y, player_z = GetMapPlayerPosition("player")
--     d("|cFAA0A0Meine Position (World):|r " .. My_x .. " , " .. My_y .. " , " .. My_z)
--     d("|cFAA0A0Meine Position (Map):|r " .. player_x .. " , " .. player_y .. " , " .. player_z)
-- end

-- function DsRGuildTestDatei.TESTFUNCTION()
--     EVENT_MANAGER:RegisterForUpdate(DsRGuildTestDatei.name, 5000, function() WorldPositionChanged() end)
-- end
-- ------------------------------------------------------  
-- ------------------------------------------------------  

-- ------------------------------------------------------
-- Keep ID auslesen
-- ------------------------------------------------------
-- function DsRGuildTestDatei.TESTFUNCTION() 
--     for i = 1, GetNumKeeps() do
--         local keepId, _ = GetKeepKeysByIndex(i)
--         local keepType  = GetKeepType(keepId)
--         local keepName  = GetKeepName(keepId)
--         d(keepId)
--         d(keepType)
--         d(keepName)
--         d('-------------------------------------------------------')
--     end
-- end
-- ------------------------------------------------------  
-- ------------------------------------------------------  

-- ------------------------------------------------------
-- Bewerbungen
-- ------------------------------------------------------
-- function DsRGuildTestDatei.TESTFUNCTION() 
--     for i = 1, 5 do
--         local guildId   = GetGuildId(i)
--         local guildName = GetGuildName(guildId)
--         if guildName == "Die sieben Raben" then
--             local guildId         = GetGuildId(GuildNum)
--             local numApplications = GetGuildFinderNumGuildApplications(guildId)

--             for a = 1, numApplications do
--                 local level, championPoints, alliance, classId, accountName, characterName, achievementPoints, applicationMessage = GetGuildFinderGuildApplicationInfoAt(guildId, a)
--                 local CheckLen = zo_strlen(applicationMessage)

--                 if CheckLen <= 60 then
--                     -- d("|c7393B3accountName:|r " .. accountName)
--                     -- d("|c7393B3CheckLen:|r " .. CheckLen)
--                     -- d("|c7393B3applicationMessage:|r " .. applicationMessage)
--                     -- d("|cFAA0A0--------------------------------------|r")

--                     d("|cFAA0A0Bewerbung von|r " .. accountName .. "|cFAA0A0automatisch abgelehnt|r ")

--                     local declineMessage = "Hey, leider können wir keine Bewerbungen ohne Text berücksichtigen. Bitte schreib uns doch ein paar Zeilen über dich, wenn du dich nochmal bewerben möchtest."
--                     -- local declineMessage = GUILD_RECRUITMENT_MANAGER:GetSavedApplicationsDefaultMessage(guildId)
                    
--                     DeclineGuildApplication(guildId, a, declineMessage, false, "")
--                 end
--             end
--             return
--         end
--     end
-- end
-- ------------------------------------------------------  
-- ------------------------------------------------------  


-- ------------------------------------------------------
-- GildenNews
-- ------------------------------------------------------
-- function DsRGuildTestDatei.TESTFUNCTION() 
--     local GuildCount                  = GetNumGuilds()

--     for i = 1, GuildCount do
--         local guildID   = GetGuildId(i)
--         local GuildName = GetGuildName(guildID)

        -- if GuildName == "Die sieben Raben" then
            -- local guildDescription  = GetGuildMotD(guildID)
            -- local NewsDate          = zo_strmatch(guildDescription, "Date: %d%d.%d%d.%d%d%d%d")
            -- local NewsDateSUB       = zo_strsub(NewsDate , 7 , 16)

            -- local Manage = GUILD_BROWSER_MANAGER:GetGuildData(guildID)

-- sieben Raben
-- /script d(GUILD_BROWSER_MANAGER:GetGuildData(155508))
-- /script d(GUILD_BROWSER_MANAGER:RequestGuildData(155508))
-- Hasenbande
-- /script d(GUILD_BROWSER_MANAGER:GetGuildData(508568)) 
-- /script d(GUILD_BROWSER_MANAGER:RequestGuildData(508568))


            -- d(guildDescription)
            -- d("#################################")
            -- d(guildID)
            -- d(Manage)
            -- d(NewsDate)
            -- d(NewsDateSUB)
        -- end
    -- end
-- end
-- ------------------------------------------------------  
-- ------------------------------------------------------  


-- ------------------------------------------------------
-- Rabenwacht joint
-- ------------------------------------------------------
-- local isOnlineManager = {}

-- local function OnGuildMemberPlayerStatusChanged(_, guildId, account, prevStatus, currStatus)
--     local RabenBlue = "|c9fb6cd"

-- 	if account ~= GetDisplayName() then
-- 		local guildName = GetGuildName(guildId)

--         if guildName == "Die sieben Raben" then
--             if account == "@Hasenwarrior" or account == "@PettiPuuh" or account == "@flo1980" or account == "@Siraa" or account == "@Sisiktil" or account == "@Magnolyon" or account == "@Prof_Flausch" or account == "@Ravnic93" then
--                 local wasOnline = prevStatus ~= PLAYER_STATUS_OFFLINE
-- 			    local isOnline  = currStatus ~= PLAYER_STATUS_OFFLINE

--                 if account == "@Hasenwarrior" or account == "@flo1980" or account == "@Sisiktil" or account == "@Magnolyon" or account == "@Ravnic93" then
--                     Wacht = "Rabenwächter |r"
--                 elseif account == "@PettiPuuh" then
--                     Wacht = "Rabenmama |r"
--                 else
--                     Wacht = "Rabenwächterin |r"
--                 end

--                 if account == "@PettiPuuh" then
--                     Rabe = "|c505050P|r|c646464e|r|c787878t|r|c8c8c8ct|r|ca0a0a0i|r|c8c8c8cP|r|c787878u|r|c646464u|r|c505050h|r"
--                 elseif account == "@flo1980" then
--                     Rabe = zo_iconFormat("/DsRGuildHall/misc/flo1980.dds", 20, 20) .. "|cff0000F|r|cffffffL|r|cff0000O|r"           
--                 elseif account == "@Siraa" then
--                     Rabe = zo_iconFormat("/DsRGuildHall/misc/siraa.dds", 20, 20) .. "|c007f78S|r|c007051i|r|c00602ar|r|c005003a|r"
--                 elseif account == "@Sisiktil" then
--                     Rabe = zo_iconFormat("/DsRGuildHall/misc/sisiktil.dds", 20, 20) .. "|cffff8fD|r|ce1d816r|r|cbfb81du|r|c9c9723z|r|c605c00i|r|c3c3a05l|r"
--                 elseif account == "@Prof_Flausch" then
--                     Rabe = zo_iconFormat("/DsRGuildHall/misc/prof_flausch.dds", 20, 20) .. "|ccca6e0Prof Flausch|r"
--                 elseif account == "@Ravnic93" then
--                     Rabe = zo_iconFormat("/DsRGuildHall/misc/ravnic93.dds", 20, 20) .. "|c89693eRavnic|r"
--                 elseif account == "@Magnolyon" then
--                     Rabe = zo_iconFormat("/DsRGuildHall/misc/Magnolyon.dds", 20, 20) .. "|cffbe00B|r|cffac00o|r|cff9900o|r|cff8700p|r|cff7500s|r"
--                 elseif account == "@Hasenwarrior" then
--                     Rabe = zo_iconFormat("/DsRGuildHall/misc/Hasenwarrior.dds", 20, 20) .. "|cD8F781S|r|cF3F781i|r|cF5DA81r|r |cF7BE81H|r|cF5DA81o|r|cF3F781p|r|cD8F781p|r|cBEF781e|r|c9FF781l|r"
--                 end

-- 			    if(not wasOnline and isOnline and (isOnlineManager[account] == nil or isOnlineManager[account] == false)) then
--                     d(RabenBlue .. Wacht .. Rabe .. "|c35fc38 hat sich eingeloggt|r")
--                 elseif(wasOnline and not isOnline and (isOnlineManager[account] == nil or isOnlineManager[account])) then
--                     d(RabenBlue .. Wacht .. Rabe .. " |cFAA0A0hat sich ausgeloggt|r")
-- 			    end
--                 isOnlineManager[account] = isOnline
--             end
-- 		end
-- 	end
-- end

-- function DsRGuildTestDatei.TESTFUNCTION() 
--     EVENT_MANAGER:RegisterForEvent(DsRGuildTestDatei.name, EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, OnGuildMemberPlayerStatusChanged)
-- end
-- ------------------------------------------------------  
-- ------------------------------------------------------  




-- ------------------------------------------------------
-- ID ArchivementTrack
-- ------------------------------------------------------
-- function DsRGuildTestDatei.TESTFUNCTION() 

--     for id in pairs(DsRGuildAchievTracker.tracked) do
--         local name, desc, _, icon, done = GetAchievementInfo(id)
--         local cName = zo_strformat(SI_TOOLTIP_ITEM_NAME, name)

--         d(id .. " - " .. cName)
--     end
-- end
-- ------------------------------------------------------  
-- ------------------------------------------------------  



-- ------------------------------------------------------
-- Cyrodiil / kaiserstadt PORT
-- ------------------------------------------------------
-- function DsRGuildTestDatei.TESTFUNCTION() 
--     for campaignIndex = 1, GetNumSelectionCampaigns() do 
--         local campID   = GetSelectionCampaignId(campaignIndex)
--         local waitTime = GetSelectionCampaignQueueWaitTime(campaignIndex)
--         local Campaign = GetCampaignName(campID)

--         d("|c5C6BFF" .. Campaign .. "|r (ID:" .. tostring(campID) .. ") - Wartezeit: |c35fc38" .. tostring(waitTime) .. "|r")
--     end

--     if IsInImperialCity() then
--         QueueForCampaign(103, false) -- false = Soloport // true = Gruppenport
--         return
--     end

--     if IsInCyrodiil() then
--         QueueForCampaign(95, false) -- false = Soloport // true = Gruppenport
--         return
--     end
-- end
-- ------------------------------------------------------  
-- ------------------------------------------------------  


-- ------------------------------------------------------
-- Gilde "Die sieben Raben" seid wann Mitglied
-- ------------------------------------------------------
-- local LGH = LibHistoire

-- DsRGuildTestDatei.LibHistoireListener = {}

-- function DsRGuildTestDatei.TESTFUNCTION() 
--     local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
--     local guildName = GetGuildName(guildId)

--     local NewMember = ""
    
--     if guildName == "Die sieben Raben" then
--         DsRGuildTestDatei.LibHistoireListener[guildId] = {}
--         DsRGuildTestDatei.LibHistoireListener[guildId] = LGH:CreateGuildHistoryListener(guildId, GUILD_HISTORY_GENERAL)

--         DsRGuildTestDatei.LibHistoireListener[guildId]:SetEventCallback(function(eventType, eventId, eventTime, p1, p2, p3, p4, p5, p6)
--             local timeStamp  = GetTimeStamp()
--             local timeString = DsRglobals:secondsToString(timeStamp - eventTime)
--             local days       = zo_floor((timeStamp - eventTime)/86400)

--             if eventType == GUILD_EVENT_GUILD_JOIN and days < 1 then
--                 local param1     = p1 or ""
--                 local param2     = p2 or ""
--                 local param3     = p3 or ""
--                 local param4     = p4 or ""
--                 local param5     = p5 or ""
--                 local param6     = p6 or ""
--                 local theString  = param1 .. param2 .. param3 .. param4 .. param5 .. param6

--                 d(theString ..  " - " .. timeString)
                
--             end
--         end)
       
--         DsRGuildTestDatei.LibHistoireListener[guildId]:Start()
--     end
-- end
-- ------------------------------------------------------  
-- ------------------------------------------------------  


-- ------------------------------------------------------
-- Charakter auslesen
-- ------------------------------------------------------
-- function DsRGuildTestDatei.TESTFUNCTION() 

--     local SortTable = {}

--     for charNum=1, GetNumCharacters ( ), 1 do
--         local name, gender, level, classId, raceId, alliance, charId, locationId = GetCharacterInfo ( charNum )
--         local name = zo_strformat(SI_UNIT_NAME, name)
--         table.insert(SortTable, {name = name, charId = charId})
--         -- d("|c7393B3name:|r " .. name)
--         -- d("|c7393B3gender:|r " .. gender)
--         -- d("|c7393B3level:|r " .. level)
--         -- d("|c7393B3classId:|r " .. classId)
--         -- d("|c7393B3raceId:|r " .. raceId)
--         -- d("|c7393B3alliance:|r " .. alliance)
--         -- d("|c7393B3charId:|r " .. charId)
--         -- d("|c7393B3locationId:|r " .. locationId)
--         -- d("|cFAA0A0--------------------------------------|r")
--     end
    
--     table.sort(SortTable, function(a, b) return a.name < b.name end)

--     for a, b in pairs(SortTable) do
--         d(b.name)
--     end
-- end
-- ------------------------------------------------------  
-- ------------------------------------------------------  


-- ------------------------------------------------------
-- Manuelle Trödelliste auslesen
-- ------------------------------------------------------
-- function DsRGuildTestDatei.TESTFUNCTION() 

    -- for id, Junk in pairs( DsRGuildPersonal.ACCconfig.JunkMarkManu ) do
    --     local Link = Junk.itemLink
    --     local Mark = Junk.MarkJunk
    --     local ID = id
    --     d("|c7393B3ID:|r " .. ID)
    --     d("|c7393B3Link:|r " .. Link)
    --     d("|c7393B3Mark:|r " .. tostring(Mark))
    --     d("|cFAA0A0--------------------------------------|r")
    -- end
    -- SCENE_MANAGER:Show("inventory")
-- end 
-- ------------------------------------------------------  
-- ------------------------------------------------------  
    

-- ------------------------------------------------------
-- Aktuelle Zone auslesen
-- ------------------------------------------------------  
-- function DsRGuildTestDatei.TESTFUNCTION() 
--     local LMP          = LibMapPins
--     local Mainzone, Subzone = LMP:GetZoneAndSubzone()
--         d(Mainzone)
--         d(Subzone)
--     local zonenameCHECK = string.match(GetMapTileTexture(), "%w+/%w+/%w+/(%w+)")
--         d(zonenameCHECK)

--     local ZoneId        = GetZoneId(GetUnitZoneIndex("player"))
--     local subZoneName   = GetZoneNameById(ZoneId)
--     local ZoneIndex     = GetZoneIndex(ZoneId)
--     local ZoneName      = GetZoneNameByIndex(ZoneIndex):gsub("%^.+", "")
--     local ZoneDesc      = GetZoneDescription(ZoneIndex)

--         d("|c7393B3ZoneId:|r " .. ZoneId)
--         d("|c7393B3ZoneIndex:|r " .. ZoneIndex)
--         d("|c7393B3ZoneName:|r " .. ZoneName)
--         d("|c7393B3subZoneName:|r " .. subZoneName)
-- end 
-- ------------------------------------------------------  
-- ------------------------------------------------------  

-- ------------------------------------------------------  
-- Assistenten & Companions auslesen
-- ------------------------------------------------------  
-- function DsRGuildTestDatei.TESTFUNCTION() 
--     for Ass = 1, GetTotalCollectiblesByCategoryType( COLLECTIBLE_CATEGORY_TYPE_ASSISTANT ) do

--         local id = GetCollectibleIdFromType( COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, Ass )
--         local name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType, hint = GetCollectibleInfo(id)
        
--         d("|c7393B3name:|r " .. name:gsub("%^.+", ""))
--         d("|c7393B3description:|r " .. description)
--         d("|c7393B3id:|r " .. id)
--         d("|c7393B3icon:|r " .. icon)
--         d("|c7393B3:deprecatedLockedIcon|r " .. deprecatedLockedIcon)
--         d("|c7393B3:unlocked|r " .. tostring(unlocked))
--         d("|c7393B3:purchasable|r " .. tostring(purchasable))
--         d("|c7393B3:isActive|r " .. tostring(isActive))
--         d("|c7393B3:categoryType|r " .. categoryType)
--         d("|c7393B3:hint|r " .. hint)
--         d("|cFAA0A0--------------------------------------|r")
--     end

--     d("|cFF0000--------------------------------------|r")
--     d("|cFF0000--------------------------------------|r")
--     d("|cFF0000--------------------------------------|r")
--     for Com = 1, GetTotalCollectiblesByCategoryType( COLLECTIBLE_CATEGORY_TYPE_COMPANION ) do

--         local id = GetCollectibleIdFromType( COLLECTIBLE_CATEGORY_TYPE_COMPANION, Com )
--         local name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType, hint = GetCollectibleInfo(id)
        
--         d("|c7393B3name:|r " .. name:gsub("%^.+", ""))
--         -- d("|c7393B3description:|r " .. description)
--         d("|c7393B3id:|r " .. id)
--         d("|c7393B3icon:|r " .. icon)
--         -- d("|c7393B3:deprecatedLockedIcon|r " .. deprecatedLockedIcon)
--         d("|c7393B3:unlocked|r " .. tostring(unlocked))
--         -- d("|c7393B3:purchasable|r " .. tostring(purchasable))
--         -- d("|c7393B3:isActive|r " .. tostring(isActive))
--         -- d("|c7393B3:categoryType|r " .. categoryType)
--         -- d("|c7393B3:hint|r " .. hint)
        
--         d("|cFAA0A0--------------------------------------|r")
--     end
-- end
-- ------------------------------------------------------  
-- ------------------------------------------------------  

-- ------------------------------------------------------  
-- Inventar auslesen
-- ------------------------------------------------------  
-- function DsRGuildTestDatei.TESTFUNCTION() 
--     local bagpackCache = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)
--     for bagSlot, data in pairs(bagpackCache) do
--             local itemId    = GetItemId(BAG_BACKPACK, data.slotIndex)
--             local itemLink 	= GetItemLink(BAG_BACKPACK, data.slotIndex)
--             local itemIcon  = GetItemLinkIcon(itemLink)
--             local itemType, specializedItemType = GetItemType(BAG_BACKPACK, data.slotIndex)
--             local _, _, _, _, locked, _, itemStyleId, itemQuality, displayQuality = GetItemInfo(BAG_BACKPACK, data.slotIndex)

--             local stritemType       	  = GetString ( "SI_ITEMTYPE", itemType )
--             local strspecializedItemType  = GetString ( "SI_SPECIALIZEDITEMTYPE", specializedItemType )
                
--             local CheckKnown = DsRGuildUnknown:IsItemLinkKnownUnknown(itemLink)

--             if itemId == 212238 then

--                 if IsProtectedFunction("UseItem") then 
--                     CallSecureProtected("UseItem", BAG_BACKPACK, data.slotIndex)
--                   else
--                     UseItem(BAG_BACKPACK, data.slotIndex) 
--                 end
              

--                 d("|c7393B3itemLink:|r "            .. itemLink)
--                 d("|c7393B3CheckKnown:|r "          .. tostring(CheckKnown))
--                 d("|c7393B3itemIcon:|r "            .. itemIcon)
--                 d("|c7393B3itemId:|r "              .. itemId)
--                 d("|c7393B3itemQuality:|r "         .. itemQuality)
--                 d("|c7393B3displayQuality:|r "      .. displayQuality)
--                 d("|c7393B3itemType:|r "            .. stritemType .. " (|c35fc38" .. itemType .. "|r)")
--                 d("|c7393B3specializedItemType:|r " .. strspecializedItemType .. " (|c35fc38" .. specializedItemType .. "|r)")
--                 d("|cFAA0A0--------------------------------------|r")
--             end
--     end
-- end
-- ------------------------------------------------------  
-- ------------------------------------------------------  
