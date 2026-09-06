local GoldenPursuitsTracker = {}

local GPT = GoldenPursuitsTracker
local EM = EVENT_MANAGER

GPT.name = "GoldenPursuitsTracker"

function GPT.ProgressUpdate(_, campaignKey, activityIndex, _, Progress)
	local _, ActivityName, _, Goal = GetPromotionalEventCampaignActivityInfo(campaignKey, activityIndex)

	local IconGP = "|t20:20:EsoUI/Art/LFG/Gamepad/LFG_menuIcon_PromotionalEvents.dds|t "

	if Progress >= Goal then
		local CompletedMsg = "|cFFFFFF" .. IconGP .. ActivityName .. "|r |t20:20:GoldenPursuitsTracker/Textures/success.dds|t"
		d(CompletedMsg)
	else
		local ProgressionMsg = "|cFFFFFF" .. IconGP .. ActivityName .. " (|r|cFFFF00" .. Progress .. "|r |cFFFFFF/ " .. Goal .. ")|r"
		d(ProgressionMsg)
	end
end

function GPT.OnAddOnLoaded(_, addonName)
	if addonName ~= GPT.name then return end
	EM:UnregisterForEvent(GPT.name, EVENT_ADD_ON_LOADED)

	EM:RegisterForEvent(GPT.name, EVENT_PROMOTIONAL_EVENTS_ACTIVITY_PROGRESS_UPDATED, GPT.ProgressUpdate)
end

EM:RegisterForEvent(GPT.name, EVENT_ADD_ON_LOADED, GPT.OnAddOnLoaded)