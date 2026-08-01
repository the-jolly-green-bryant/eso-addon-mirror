-- ZAM_Stats © ZAM Network LLC
-- All Rights Reserved

local isVeteran, GetLevel, GetCurXP, GetMaxXP, veteranIcon
local GetUnitVeteranPoints = GetUnitVeteranPoints
local GetUnitVeteranPointsMax = GetUnitVeteranPointsMax
local GetUnitXP = GetUnitXP
local GetUnitXPMax = GetUnitXPMax
local strformat = string.format

local function UpdateVeteranStatus()
	if isVeteran ~= IsUnitVeteran("player") then
		isVeteran = IsUnitVeteran("player")
	end
	GetLevel = isVeteran and GetUnitVeteranRank or GetUnitLevel
	GetCurXP = isVeteran and GetUnitVeteranPoints or GetUnitXP
	GetMaxXP = isVeteran and GetUnitVeteranPointsMax or GetUnitXPMax
	veteranIcon = isVeteran and "|t28:28:EsoUI\\Art\\UnitFrames\\target_veteranrank_icon.dds|t" or ""
end

local module, text = ZAM_Stats:CreateModule("Exp")


CALLBACK_MANAGER:RegisterCallback("ZAM_Stats_Modules_Ready", function()
	local em = EVENT_MANAGER
	local function UpdateTextOnEvent(event)
			ZAM_Stats:SetModuleText(text, strformat("%d%%", GetCurXP("player")/GetMaxXP("player")*100), " Lvl "..GetLevel("player")..veteranIcon)
		end

	em:RegisterForEvent(module:GetName(), EVENT_EXPERIENCE_UPDATE, UpdateTextOnEvent)
	em:RegisterForEvent(module:GetName(), EVENT_VETERAN_POINTS_UPDATE, UpdateTextOnEvent)
	em:RegisterForEvent(module:GetName(), EVENT_LEVEL_UPDATE, function() UpdateVeteranStatus() UpdateTextOnEvent() end)
	em:RegisterForEvent(module:GetName(), EVENT_VETERAN_RANK_UPDATE, function() UpdateVeteranStatus() UpdateTextOnEvent() end)
	
	UpdateVeteranStatus()
	UpdateTextOnEvent()
	
	CALLBACK_MANAGER:RegisterCallback("ZAM_Stats_Force_Refresh", UpdateTextOnEvent)
end)