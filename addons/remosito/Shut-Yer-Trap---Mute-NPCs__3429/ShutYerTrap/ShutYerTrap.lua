

local function pDebug(dmsg)

	if SYT.Debug then d("SYT: "..dmsg) end
end


local function UnMute()

	EVENT_MANAGER:UnregisterForUpdate("SYT_UnMute")
	SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, SYT.Volume)
    pDebug(string.format("End Shut Yer Trap %s", SYT.Volume))
end


local function shutIt(who, what)

	if SYT.SV.Muted[who] and ( SYT.SV.Muted[who]["#@ALL@#"] or SYT.SV.Muted[who][what] ) then 
		return true
	else
		return false
	end
end


local function OnChatMsg(self, eventName, msgType, fromName, text)

	if not eventName or (eventName and eventName ~= EVENT_CHAT_MESSAGE_CHANNEL) then return false end
	pDebug(string.format("OCM %d : %s said %s", msgType, fromName, text))
	if not SCENE_MANAGER:IsShowing("gameMenuInGame") then
		if 	msgType == CHAT_CHANNEL_MONSTER_SAY or msgType == CHAT_CHANNEL_MONSTER_YELL then
			if shutIt(fromName, text) then
				pDebug("Shut Yer Trap")
				if tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME)) > 0 then --if next shutup happens before previous one is done. current volume is 0. we dont want to store that one...or VO volume will be set to 0 constantly....
					SYT.Volume = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME)
				end
				pDebug(SYT.Volume)
				SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, 0)
				local timeout = 1000 + ( #text * 0.1 ) * 1000
				pDebug(timeout)
				EVENT_MANAGER:RegisterForUpdate("SYT_UnMute", timeout, UnMute)
				return true
			else	
				local alreadythere = false
				for i,l in ipairs(SYT.Chatter) do
					if l[1] == fromName and l[2] == text then 
						alreadythere = true
						break
					end			
				end
				if not alreadythere then
					table.insert(SYT.Chatter, 1, { fromName, text })
					table.insert(SYT.DropDown.choices, 1, zo_strformat("<<1>> : <<2>>", fromName, text))
					if table.getn(SYT.Chatter) > 20 then 
						table.remove(SYT.Chatter, #SYT.Chatter) 
						table.remove(SYT.DropDown.choices, #SYT.DropDown.choices)
					else
						table.insert(SYT.DropDown.choicesValues, #SYT.DropDown.choices)
					end
				end
			end
		end
	end
end


local function HookSubtitles()

	local origCallback = ZO_SubtitleManager.OnShowSubtitle
	ZO_SubtitleManager.OnShowSubtitle = function(control, messageType, speaker, message)
		pDebug(string.format("%s : %s %s", messageType,speaker, message))
		if shutIt(speaker, message) then 
			return 
		else 
			origCallback(control, messageType, speaker, message) 
		end
	end
end
 
local function OnZoneChanged()

	if math.floor(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME)) == 0 and SYT.SV.backupLevel ~= 0 then 
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, SYT.SV.backupLevel)
	end
end


local function OnPlayerActivated(_, initial)

	ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", OnChatMsg)
	EVENT_MANAGER:UnregisterForEvent(SYT.name, EVENT_PLAYER_ACTIVATED)
	OnZoneChanged()
	EVENT_MANAGER:RegisterForEvent(SYT.name, EVENT_PLAYER_ACTIVATED, OnZoneChanged)
end


local function OnAddOnLoaded(event, addonName)

    if addonName ~= SYT.name then return end
	SYT.SV = ZO_SavedVars:NewAccountWide("SYTVars", 1, nil, nil, GetWorldName(), nil)
	if not SYT.SV.Muted then SYT.SV.Muted = {} end
	if not SYT.SV.backupLevel then SYT.SV.backupLevel = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME) end
	SYT.CreateSettings()
--	EVENT_MANAGER:RegisterForEvent("ShutYerTrap", EVENT_CHAT_MESSAGE_CHANNEL, OnChatMsg)
	HookSubtitles()
	EVENT_MANAGER:RegisterForEvent(SYT.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

--Events
EVENT_MANAGER:RegisterForEvent(SYT.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

