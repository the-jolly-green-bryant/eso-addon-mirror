tim99sFTSIO = tim99sFTSIO or {}
local ftsio = tim99sFTSIO
ftsio.name         = "tim99sFTSIO"
ftsio.author       = "tim99"
ftsio.campIdCyr    = 101
ftsio.campIdIC     = 95
ftsio.campIdNoCPIC = 96
ftsio.quAsGroup    = false
ftsio.col_grn      = ZO_ColorDef:New("66ff66") --grn
ftsio.col_red      = ZO_ColorDef:New("ff6666") --red
ftsio.col_pur      = ZO_ColorDef:New("9b30ff") --milka
ftsio.myAlly       = GetUnitAlliance("player")
ftsio.myAllyCol    = GetAllianceColor(ftsio.myAlly)
ftsio.myAllyIco    = ftsio.myAllyCol:Colorize(zo_iconFormatInheritColor(GetAllianceSymbolIcon(ftsio.myAlly),24,24))
ftsio.svChar = {}
ftsio.svCharDef = {
	autoAcceptPvpQ = true,
	autoAcceptChat = false,
	autoAcceptIniQ = false,
	useICnoCP      = false,
}
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function ftsio.queueIC()
	--/script d(GetCurrentCampaignId())
	local cIdIcCp=ftsio.svChar.useICnoCP and GetSelectionCampaignId(2) or GetSelectionCampaignId(1)
	if cIdIcCp==0 or cIdIcCp==nil then cIdIcCp=ftsio.svChar.useICnoCP and ftsio.campIdNoCPIC or ftsio.campIdIC end --IC   ----QueryCampaignSelectionData() ???
	if not IsQueuedForCampaign(cIdIcCp, ftsio.quAsGroup) then
		CHAT_SYSTEM:AddMessage(zo_strformat("|c666666[FTSIO] [<<1>>]|r Joining <<2>><<3>>  |c333333(<<4>>)|r", GetTimeString(), ftsio.myAllyIco, ftsio.col_pur:Colorize(GetCampaignName(cIdIcCp)),tostring(cIdIcCp)))
		QueueForCampaign(cIdIcCp, ftsio.quAsGroup)
	else
		CHAT_SYSTEM:AddMessage(string.format("|c666666[FTSIO] [%s]|r already in queue", GetTimeString()))
	end
end
------------------------------------------------------------------------------------------
function ftsio.queueCyro()
	local cIdCyro=GetAssignedCampaignId()
	if cIdCyro==0 or cIdCyro==nil then cIdCyro=ftsio.campIdCyr end --Blackreach
	if not IsQueuedForCampaign(cIdCyro, ftsio.quAsGroup) then
		CHAT_SYSTEM:AddMessage(zo_strformat("|c666666[FTSIO] [<<1>>]|r Joining <<2>><<3>>  |c333333(<<4>>)|r", GetTimeString(), ftsio.myAllyIco, ftsio.myAllyCol:Colorize(GetCampaignName(cIdCyro)),tostring(cIdCyro)))
		QueueForCampaign(cIdCyro, ftsio.quAsGroup)
	else
		CHAT_SYSTEM:AddMessage(string.format("|c666666[FTSIO] [%s]|r already in queue", GetTimeString()))
	end
end
------------------------------------------------------------------------------------------
function Tim99_FTSIO_Q4PvP()
	if IsPlayerInAvAWorld() and not IsInImperialCity() and not IsActiveWorldBattleground() then --cyrodill + cyro-delves
		ftsio.queueIC()
	elseif IsInImperialCity() then --ic
		ftsio.queueCyro()
	else --pve
		if IsShiftKeyDown() then ftsio.queueIC() else ftsio.queueCyro() end
	end
end
------------------------------------------------------------------------------------------
local function OnQueueStateChange(eventCode, id, isGroup, state)
	if state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then 
		if ftsio.svChar.autoAcceptChat then
			CHAT_SYSTEM:AddMessage(string.format("|c666666[FTSIO] [%s]|r |c33ff33%s accepted|r", GetTimeString(), GetCampaignName(id)))
		end
		ConfirmCampaignEntry(id, isGroup, true)
	end
end
------------------------------------------------------------------------------------------
function ftsio.addonLoaded(event, addonName)
	if addonName ~= ftsio.name then return end
	EVENT_MANAGER:UnregisterForEvent(ftsio.name, EVENT_ADD_ON_LOADED)
	
	ftsio.svChar = ZO_SavedVars:NewAccountWide("Tim99sFTSIO", 1, nil, ftsio.svCharDef, GetWorldName())
	ftsio.initMenu()
	
	--auto accept campaign
	if ftsio.svChar.autoAcceptPvpQ then
		EVENT_MANAGER:RegisterForEvent(ftsio.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, OnQueueStateChange)
	end
	
	--hotkey
	ZO_CreateStringId("SI_BINDING_NAME_TIMFTSIO1","|cEECA2AToggle Cyro-IC|r")
	
end
------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(ftsio.name, EVENT_ADD_ON_LOADED, ftsio.addonLoaded)