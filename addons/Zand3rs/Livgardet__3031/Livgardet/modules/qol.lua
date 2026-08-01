-- CHAT ROLL FUNCTION FOR ROLLING ON ITEMS-
function lgRoll(upper) 
    if upper == "" then 
        upper = 20 
    else 
        upper = tonumber(upper) 
        if (upper == nil) then 
            upper = 20 
        end 
    end 
    local random = zo_random(1, upper) 
    local output = 'Random roll: ' .. random .. ' out of ' .. upper 
    CHAT_SYSTEM:StartTextEntry("/party " .. output .. " by: " .. GetUnitName("player")) 
    local x = random / 10000 
    local y = upper / 10000 
    PingMap(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, x, y) 
end 
function HandlePingData(eventCode, pingEventType, pingType, pingTag, offsetX, offsetY, isOwner) 
    local result = math.floor(offsetX * 10000) 
    local outOf = math.floor(offsetY * 10000) 
    if outOf > 0 and outOf < 100 and result < 100 and isOwner ~= true then 
        local output = 'Random roll:  ' .. result .. ' out of ' .. outOf 
        CHAT_SYSTEM:StartTextEntry("/party " .. output .. " by: " .. GetUnitName("player")) 
    end 
end 
SLASH_COMMANDS["/roll"] = function (roll)  
    lgRoll(roll) 
end
EVENT_MANAGER:RegisterForEvent("lgRollPing", EVENT_MAP_PING, HandlePingData)

--WORKS !! BUG EATER.
function NoBugs() 
    local bugTemp=0 
    function NoBugs(event, addonName) 
        if Livgardet.db.BugEater then 
            if (bugTemp==0) then ZO_UIErrors_ToggleSupressDialog() 
                bugTemp=1 
            end 
        end 
    end
end

-- WORKS !! AUTO TRADER AND AUTOREPAIR. 
function AutoTrader()
ZO_PostHook(INTERACTION, "PopulateChatterOption", function (control, optionIndex, _, _, optionType) 
    if Livgardet.db.AutoTrader then 
        if optionIndex == 1 and optionType == CHATTER_START_TRADINGHOUSE then 
            control:SelectChatterOptionByIndex(1) 
        end 
    end 
end) 
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OPEN_STORE, function() 
    local repairCost = GetRepairAllCost() 
    if repairCost > 0 and CanStoreRepair() then 
        if Livgardet.db.AutoRepair then 
            RepairAll() 
            d("Everything repaired for: " .. repairCost .. " hard earned Gold") 
        end 
    end
end)
end



-- NOT WORKING YET! AUTO KEEP CLAIM. 
--function AutoClaim() 
--    ZO_PostHook(INTERACTION, "PopulateChatterOption", function (control, optionIndex, _, _, optionType) 
--        if optionIndex == 5 and optionType == CHATTER_START_TRADINGHOUSE then 
--            control:SelectChatterOptionByIndex(1) 
--        end 
--    end)
--end



--WORKS !!  Removes the Mail delete confirmation if mail is empty. Does not remove attachments. | /esoui/ingame/mail/keyboard/mailinbox_keyboard.lua
ZO_PreHook(MAIL_INBOX, "Delete", function(self)
	if Livgardet.db.skipMailDeletionPrompt and self.mailId and self:IsMailDeletable() then
		local numAttachments, attachedMoney = GetMailAttachmentInfo(self.mailId)
		if numAttachments == 0 and attachedMoney == 0 then
			self:ConfirmDelete(self.mailId)
			return true
		end
	end
end)

-- WORKS !! ADDS CONFIRM TO THE DIALOG BOXES 
--local original = ZO_Dialogs_ShowDialog 
local function qconfirm(...)
    zo_callLater(function() 
        if Livgardet.db.ConfirmDialog then
        if ZO_Dialog1 and ZO_Dialog1.textParams and ZO_Dialog1.textParams.mainTextParams then
            local itemName= ZO_Dialog1.textParams.mainTextParams[1]
            if  true then
                for k, v in pairs(ZO_Dialog1.textParams.mainTextParams) do
                    if v == string.upper(v) then
                        ZO_Dialog1EditBox:SetText(v)
                    end
                end
                ZO_Dialog1EditBox:LoseFocus()
            end
        end 
    end
    end, 10)
end
ZO_PreHook("ZO_Dialogs_ShowDialog", qconfirm)

-- WORKS !! FAST TRAVEL CONFIRMATION.
local function NoConfirmTravel(name, data) 
    if Livgardet.db.NoConfirmTravel then 
        if name == "FAST_TRAVEL_CONFIRM" or name == "RECALL_CONFIRM" then 
            FastTravelToNode(data.nodeIndex) 
            ZO_Dialogs_ReleaseDialog("FAST_TRAVEL_CONFIRM") 
            return true 
        end 
    end 
end 
ZO_PreHook("ZO_Dialogs_ShowDialog", NoConfirmTravel) 

-- WORKS !! Guild Invite from Chat window.
local function AddPlayerToGuild(name, guildid, guildname) 
    d(zo_strformat(LIVGARDET_GUILDINVITED, name, guildname)) 
    GuildInvite(guildid, name) 
end 
local CreateChatMenuItem = CHAT_SYSTEM.ShowPlayerContextMenu 
CHAT_SYSTEM.ShowPlayerContextMenu = function(self, name, rawName, ...) 
    CreateChatMenuItem(self, name, rawName, ...) 
    for i = 1, GetNumGuilds() do 
        local gid = GetGuildId(i) 
        if DoesPlayerHaveGuildPermission(gid, GUILD_PERMISSION_INVITE) then 
            local guildName = GetGuildName(gid) 
            AddMenuItem(zo_strformat(LIVGARDET_GUILDINVITE, guildName), function() AddPlayerToGuild(name, gid, guildName) end) 
        end 
    end 
    if ZO_Menu_GetNumMenuItems() > 0 then 
        ShowMenu() 
    end 
end

-- Works !! Do not open books when reading.
function DontReadBooks()
	local function OnShowBook(eventCode, title, body, medium, showTitle)
		local willShow = LORE_READER:Show(title, body, medium, showTitle)
		if willShow then
			PlaySound(LORE_READER.OpenSound)
		else
			EndInteraction(INTERACTION_BOOK)
		end
	end
	local function OnDontShowBook()
		EndInteraction(INTERACTION_BOOK)
	end
	if Livgardet.db.dontReadBooks then
		LORE_READER.control:UnregisterForEvent(EVENT_SHOW_BOOK)
		LORE_READER.control:RegisterForEvent(EVENT_SHOW_BOOK, OnDontShowBook)
	else
		LORE_READER.control:UnregisterForEvent(EVENT_SHOW_BOOK)
		LORE_READER.control:RegisterForEvent(EVENT_SHOW_BOOK, OnShowBook)
	end
end