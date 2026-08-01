BorrowerAndLender = {}
LibStub("AceTimer-3.0"):Embed(BorrowerAndLender)
local LAM = LibStub:GetLibrary("LibAddonMenu-1.0")

local originalLevel
local inBank 
local currentWait = nil
local settings
local chatOptions = {ZO_ChatterOption1, ZO_ChatterOption2, ZO_ChatterOption3} -- Just covering our bases

local function EndsWith(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

local function Hush()	
	SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, 0)		
end

local function SpeakUpLad()
	if currentWait then BorrowerAndLender:CancelTimer(currentWait) end
	currentWait = nil	
	SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, settings.defaultSoundLevel)
end



local function WhoAmI(eventCode, options)
	for i,v in ipairs(chatOptions) do
		if v and not v:IsHidden() and EndsWith(v:GetText(), GetString(SI_INTERACT_OPTION_BANK)) then			
			if currentWait then BorrowerAndLender:CancelTimer(currentWait) end
			currentWait = BorrowerAndLender:ScheduleTimer(SpeakUpLad, (#ZO_InteractWindowTargetAreaBodyText:GetText()/15) + 5)
			return Hush()		
		end
	end
end

local function tFindChat(t, entry)
	for i,v in ipairs(t) do
		if v.chat == entry then return i end
	end
	return nil
end

local function FilterNPC(eventCode, channel, npc, chat)
	if channel ~= CHAT_CHANNEL_MONSTER_SAY and channel ~= CHAT_CHANNEL_MONSTER_YELL then return end
	
	if not settings.muteAmbientWhileChatting and not ZO_ChatterOption1:IsHidden() then return end

	if settings.whitelist[npc] then return end
	
	if not settings.chats[npc] then
		settings.chats[npc] = {}
	end

	local chatIndex = tFindChat(settings.chats[npc], chat)
	if not chatIndex then
		table.insert(settings.chats[npc], {chat = chat, count = 1})
		return
	else
		settings.chats[npc][chatIndex].count = settings.chats[npc][chatIndex].count  + 1
	end

	if currentWait then BorrowerAndLender:CancelTimer(currentWait) end

	currentWait = BorrowerAndLender:ScheduleTimer(SpeakUpLad, (#chat/15) + 2)
	Hush()	
end

local function AddToBlackList()
	local name = GetRawUnitName("reticleover")
	if name  == "" then return end
	settings.whitelist[name] = true
	d("Adding " .. name:gsub("%^[%a]+","") .. " to the list of npcs to bypass")
	EVENT_MANAGER:UnregisterForEvent("BALAdd", EVENT_RETICLE_TARGET_CHANGED)
end

local function RemoveFromBlackList()
	local name = GetRawUnitName("reticleover")
	settings.whitelist[name] = nil
	d(name:gsub("%^[%a]+", "") .. " will now be processed by the addon")
	EVENT_MANAGER:UnregisterForEvent("BALRemove", EVENT_RETICLE_TARGET_CHANGED)
end

local function BorrowerAndLenderLoaded(eventCode, addOnName)
	
	if(addOnName ~= "BorrowerAndLender") then
        return
    end
	
	local defaults = {
		chats = {},
		whitelist = {},
		defaultSoundLevel = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME)) or 75,
		muteBank = true,
		muteAmbient = true,
		muteAmbientWhileChatting = false
	}
	
	settings = ZO_SavedVars:New("BorrowerAndLender_Settings", 6, nil, defaults)
	
	local panel = LAM:CreateControlPanel("BAL", "Borrower And Lender")
  
	LAM:AddHeader(panel, "BAL_General", "Settings")
  
  	LAM:AddSlider(panel, "defaultSound", "Set the standard voice over volume ", 
						"Set this value to your standard voice over volume", 
						0, 100, 1, function() return settings.defaultSoundLevel end, 
						function(value) settings.defaultSoundLevel = value end)
	LAM:AddCheckbox(panel, "muteBank", "Mute bank npcs", "Set this on to mute all bank NPCs from speaking",
					function() return settings.muteBank end, 
					function(value)
						if value == false then
							EVENT_MANAGER:UnregisterForEvent("BALWho", EVENT_CHATTER_BEGIN)
							EVENT_MANAGER:UnregisterForEvent("BALTalk", EVENT_CHATTER_END)							
						else
							EVENT_MANAGER:RegisterForEvent("BALWho", EVENT_CHATTER_BEGIN, WhoAmI)
							EVENT_MANAGER:RegisterForEvent("BALTalk", EVENT_CHATTER_END, SpeakUpLad)													
						end
						settings.muteBank = value
					end)
	LAM:AddCheckbox(panel, "muteAmbient", "Mute ambient NPCs", "Mute passing npcs from repeated chats",
					function() return settings.muteAmbient end, 
					function(value)
						if value == false then
							EVENT_MANAGER:UnregisterForEvent("BALChat", EVENT_CHAT_MESSAGE_CHANNEL)
						else
							EVENT_MANAGER:RegisterForEvent("BALChat", EVENT_CHAT_MESSAGE_CHANNEL, FilterNPC)
						end
						settings.muteAmbient = value
					end)
	LAM:AddCheckbox(panel, "muteAmbientChatting", "Mute ambient NPCs while in a chat dialog", "Mute passing npcs when inside a chat dialog (eg quest)",
					function() return settings.muteAmbientWhileChatting end, 
					function(value) settings.muteAmbientWhileChatting = value end)

	if settings.muteBank then
		EVENT_MANAGER:RegisterForEvent("BALWho", EVENT_CHATTER_BEGIN, WhoAmI)
		EVENT_MANAGER:RegisterForEvent("BALTalk", EVENT_CHATTER_END, SpeakUpLad)
	end
	if settings.muteAmbient then
		EVENT_MANAGER:RegisterForEvent("BALChat", EVENT_CHAT_MESSAGE_CHANNEL, FilterNPC)
	end

	SLASH_COMMANDS["/baladd"] = 
	function() 
		EVENT_MANAGER:RegisterForEvent("BALAdd", EVENT_RETICLE_TARGET_CHANGED, AddToBlackList)
		d("Mouse over the NPC you wish to hear all the time")
	end
	SLASH_COMMANDS["/balremove"] = 
	function() 
		EVENT_MANAGER:RegisterForEvent("BALRemove", EVENT_RETICLE_TARGET_CHANGED, RemoveFromBlackList)
		d("Mouse over the NPC you wish to remove from the 'always hear' list.")
	end


end

function BorrowerAndLender:CommandHandler()
	settings.muteAmbient = not settings.muteAmbient
	if settings.muteAmbient == false then
		EVENT_MANAGER:UnregisterForEvent("BALChat", EVENT_CHAT_MESSAGE_CHANNEL)
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, 1, "Unmuting Ambient NPCs")
	else
		EVENT_MANAGER:RegisterForEvent("BALChat", EVENT_CHAT_MESSAGE_CHANNEL, FilterNPC)
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, 1, "Muting Ambient NPCs")
	end

end

ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_BAL", "Toggle Ambient NPC Ignoring")

EVENT_MANAGER:RegisterForEvent("BorrowerAndLenderLoaded", EVENT_ADD_ON_LOADED, BorrowerAndLenderLoaded)