NeatExperienceInfo = {}
NeatExperienceInfo.name = "NeatExperienceInfo"

local LAM = LibAddonMenu2
local ADDON_VERSION = "1.15.1"
 
function NeatExperienceInfo:Initialize()
	controlPool = ZO_ControlPool:New("TopLevelControl")
	LastCFT = GetFrameTimeMilliseconds()
	savedVariables = ZO_SavedVars:New("NeatExperienceInfoSavedVariables", 1, nil, {})
	if savedVariables.ShowInChat == nil then savedVariables.ShowInChat = true end
	if savedVariables.ShowAsAnimation == nil then savedVariables.ShowAsAnimation = true end
	if savedVariables.AnimationOffset == nil then savedVariables.AnimationOffset = 70 end
	if savedVariables.PrimaryFontColor  == nil then savedVariables.PrimaryFontColor = {0.7725490332, 0.7607843280, 0.6196078431, 1} end
	if savedVariables.SecondaryFontColor  == nil then savedVariables.SecondaryFontColor = {0, 0.6000000238, 0, 1} end
	
	if savedVariables.AnimationPosition ~= GetString(NEI_OPTION_POSITION_LEFT) and
	   savedVariables.AnimationPosition ~= GetString(NEI_OPTION_POSITION_CENTER) and
	   savedVariables.AnimationPosition ~= GetString(NEI_OPTION_POSITION_RIGHT) then
		savedVariables.AnimationPosition = GetString(NEI_OPTION_POSITION_LEFT)
	end
	if savedVariables.FontSize ~= GetString(NEI_OPTION_FONTSIZE_HUGE) and
	   savedVariables.FontSize ~= GetString(NEI_OPTION_FONTSIZE_LARGE) and
	   savedVariables.FontSize ~= GetString(NEI_OPTION_FONTSIZE_MEDIUM) and 
	   savedVariables.FontSize ~= GetString(NEI_OPTION_FONTSIZE_SMALL) and 
	   savedVariables.FontSize ~= GetString(NEI_OPTION_FONTSIZE_TINY) then
		savedVariables.FontSize = GetString(NEI_OPTION_FONTSIZE_MEDIUM)
	end

	NeatExperienceInfo:CreateSettingsMenu()

	--EVENT_MANAGER:RegisterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED, self.OnPlayerStealthState)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SKILL_XP_UPDATE, self.OnGainCraftingXP)
end

function NeatExperienceInfo.OnGainCraftingXP(eventCode, skillType, skillIndex, reason, rank, previousXP, currentXP)
	local name, rank, _, skillLineId = GetSkillLineInfo(skillType, skillIndex)
	local totalExperience = currentXP - previousXP
	
	if totalExperience > 0 then
		if skillType == 8 or (skillType == 4 and skillLineId == 111) then
			if skillType == 4 then ExperienceLabel = GetString(NEI_XPLABEL_EXPERIENCE) else ExperienceLabel = GetString(NEI_XPLABEL_INSPIRATION) end
			
			local timelineTranslate = ANIMATION_MANAGER:CreateTimelineFromVirtual("TranslateAnimation")
			local timelineAlpha = ANIMATION_MANAGER:CreateTimelineFromVirtual("AlphaAnimation")
			local animationTranslate = timelineTranslate:GetFirstAnimation()
			local animationAlpha = timelineAlpha:GetFirstAnimation()
			
			name = string.match(name, "^[%a%säÄöÖüÜ]+[^\^.*]")
						
			local AnimationOffset = 750
			local Difference = GetFrameTimeMilliseconds() - LastCFT
			if Difference < 0 then
				Difference = 0 - Difference
				animationDelay = Difference + AnimationOffset
				timelineTranslate:SetAnimationOffset(animationTranslate, animationDelay)
				LastCFT = LastCFT + AnimationOffset
			elseif Difference < AnimationOffset then
				animationDelay = AnimationOffset - Difference
				timelineTranslate:SetAnimationOffset(animationTranslate, animationDelay)
				LastCFT = LastCFT + animationDelay
			else
				LastCFT = GetFrameTimeMilliseconds()
				animationDelay = 0
				timelineTranslate:SetAnimationOffset(animationTranslate, animationDelay)
			end
			
			local FontColor1 = ZO_ColorDef:New({r=savedVariables.PrimaryFontColor[1], g=savedVariables.PrimaryFontColor[2], b=savedVariables.PrimaryFontColor[3], a=savedVariables.PrimaryFontColor[4]})
			local FontColor2 = ZO_ColorDef:New({r=savedVariables.SecondaryFontColor[1], g=savedVariables.SecondaryFontColor[2], b=savedVariables.SecondaryFontColor[3], a=savedVariables.SecondaryFontColor[4]})
						
			local control, ckey = controlPool:AcquireObject()
			control.hPoolKey = ckey
			control:GetNamedChild("Label"):SetText("|c" .. FontColor1:ToHex() .. GetString(NEI_INFOMSG_1) .. "|c" .. FontColor2:ToHex() .. totalExperience .. "|c" .. FontColor1:ToHex() .. ExperienceLabel .. GetString(NEI_INFOMSG_2) .. "|c" .. FontColor2:ToHex() .. name .. " (" .. GetString(NEI_INFOMSG_RANK) .. rank .. ")|c" .. FontColor1:ToHex() .. GetString(NEI_INFOMSG_3) .. "|r")
			
			if savedVariables.FontSize == GetString(NEI_OPTION_FONTSIZE_HUGE) then
				control:GetNamedChild("Label"):SetFont("ZoFontWinH1")
			elseif savedVariables.FontSize == GetString(NEI_OPTION_FONTSIZE_LARGE) then
				control:GetNamedChild("Label"):SetFont("ZoFontWinH2")
			elseif savedVariables.FontSize == GetString(NEI_OPTION_FONTSIZE_SMALL) then
				control:GetNamedChild("Label"):SetFont("ZoFontWinH4")
			elseif savedVariables.FontSize == GetString(NEI_OPTION_FONTSIZE_TINY) then
				control:GetNamedChild("Label"):SetFont("ZoFontWinH5")
			else 
				control:GetNamedChild("Label"):SetFont("ZoFontWinH3")
			end
			
			if savedVariables.AnimationPosition == GetString(NEI_OPTION_POSITION_CENTER) then
				control:SetAnchor(TOP)
				control:GetNamedChild("Label"):SetAnchor(nil, nil, nil, 0, savedVariables.AnimationOffset)
				control:GetNamedChild("Label"):SetHorizontalAlignment(128)
			elseif savedVariables.AnimationPosition == GetString(NEI_OPTION_POSITION_RIGHT) then
				control:SetAnchor(TOPRIGHT)
				control:GetNamedChild("Label"):SetAnchor(nil, nil, nil, -20, savedVariables.AnimationOffset)
				control:GetNamedChild("Label"):SetHorizontalAlignment(8)
			else
				control:SetAnchor(TOPLEFT)
				control:GetNamedChild("Label"):SetAnchor(nil, nil, nil, 20, savedVariables.AnimationOffset)
				control:GetNamedChild("Label"):SetHorizontalAlignment(2)
			end

			animationTranslate:SetTranslateOffsets(0, 0, 0, 0 + 200)
			animationTranslate:SetDuration(4000)

			animationAlpha:SetAlphaValues(1, 0)
			animationAlpha:SetDuration(1000)
			
			timelineTranslate:ApplyAllAnimationsToControl(control)

			timelineTranslate:InsertCallback(function()
				control:SetAlpha(1)
			end, animationDelay)
			
			timelineTranslate:InsertCallback(function()
				timelineAlpha:ApplyAllAnimationsToControl(control)
				timelineAlpha:PlayFromStart()
			end, 3000 + animationDelay)

			timelineTranslate:SetHandler("OnStop", function(timelineTranslate)
				controlPool:ReleaseObject(timelineTranslate:GetFirstAnimation():GetAnimatedControl().hPoolKey)
			end)

			if savedVariables.ShowAsAnimation then
				timelineTranslate:PlayFromStart()
			end
			if savedVariables.ShowInChat then
				d("|c" .. FontColor1:ToHex() .. GetString(NEI_INFOMSG_1) .. "|c" .. FontColor2:ToHex() .. totalExperience .. "|c" .. FontColor1:ToHex() .. ExperienceLabel .. GetString(NEI_INFOMSG_2) .. "|c" .. FontColor2:ToHex() .. name .. " (" .. GetString(NEI_INFOMSG_RANK) .. rank .. ")|c" .. FontColor1:ToHex() .. GetString(NEI_INFOMSG_3) .. "|r")
			end
		end
	end
end

function NeatExperienceInfo:CreateSettingsMenu()
	local panelData = {
		type = "panel",
		name = "Neat Experience Info",
		displayName = "|cC5C29ENeat Experience Info|r",
		author = "qhil",
		version = ADDON_VERSION,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	LAM:RegisterAddonPanel("NeatExperienceInfo", panelData)

	local optionsTable = {
		{
			type = "header",
			name = GetString(NEI_OPTION_HEADER_VISIBILITY),
		},
		{
			type = "checkbox",
			name = GetString(NEI_OPTION_NAME_ANIMATION),
			tooltip = GetString(NEI_OPTION_TOOLTIP_ANIMATION),
			getFunc = function() return savedVariables.ShowAsAnimation end,
			setFunc = function(value)
				savedVariables.ShowAsAnimation = value
				end,
			default = true,
		},
		{
			type = "checkbox",
			name = GetString(NEI_OPTION_NAME_CHAT),
			tooltip = GetString(NEI_OPTION_TOOLTIP_CHAT),
			getFunc = function() return savedVariables.ShowInChat end,
			setFunc = function(value)
				savedVariables.ShowInChat = value
				end,
			default = true,
		},
		{
			type = "header",
			name = GetString(NEI_OPTION_HEADER_POSITIONING),
		},
		{
			type = "dropdown",
			name = GetString(NEI_OPTION_NAME_POSITION),
			tooltip = GetString(NEI_OPTION_TOOLTIP_POSITION),
			choices = {GetString(NEI_OPTION_POSITION_LEFT), GetString(NEI_OPTION_POSITION_CENTER), GetString(NEI_OPTION_POSITION_RIGHT)},
			default = GetString(NEI_OPTION_POSITION_LEFT),
			getFunc = function() return savedVariables.AnimationPosition end,
			setFunc = function(value) 
				savedVariables.AnimationPosition = value
				end,
		},
		{
			type = "slider",
			name = GetString(NEI_OPTION_NAME_OFFSET),
			tooltip = GetString(NEI_OPTION_TOOLTIP_OFFSET),
			min = 10,
			max = 200,
			step = 1,
			default = 70,
			getFunc = function() return savedVariables.AnimationOffset end,
			setFunc = function(value) 
				savedVariables.AnimationOffset = value
				end,
		},
		{
			type = "header",
			name = GetString(NEI_OPTION_HEADER_APPEARANCE),
		},
		{
			type = "dropdown",
			name = GetString(NEI_OPTION_NAME_FONTSIZE),
			tooltip = GetString(NEI_OPTION_TOOLTIP_FONTSIZE),
			choices = {GetString(NEI_OPTION_FONTSIZE_HUGE), GetString(NEI_OPTION_FONTSIZE_LARGE), GetString(NEI_OPTION_FONTSIZE_MEDIUM), GetString(NEI_OPTION_FONTSIZE_SMALL), GetString(NEI_OPTION_FONTSIZE_TINY)},
			default = GetString(NEI_OPTION_FONTSIZE_MEDIUM),
			getFunc = function() return savedVariables.FontSize end,
			setFunc = function(value) 
				savedVariables.FontSize = value
				end,
		},
		{
			type = "colorpicker",
			name = GetString(NEI_OPTION_NAME_PRIMARYCOLOR),
			tooltip = GetString(NEI_OPTION_TOOLTIP_PRIMARYCOLOR),
			default = {r = 0.7725490332, g = 0.7607843280, b = 0.6196078431, a = 1},		
			getFunc = function() return unpack(savedVariables.PrimaryFontColor) end,
			setFunc = function(r,g,b,a)
				savedVariables.PrimaryFontColor = {r, g, b, a}
			end,
		},
		{
			type = "colorpicker",
			name = GetString(NEI_OPTION_NAME_SECONDARYCOLOR),
			tooltip = GetString(NEI_OPTION_TOOLTIP_SECONDARYCOLOR),
			default = {r = 0, g = 0.6000000238, b = 0, a = 1},
			getFunc = function() return unpack(savedVariables.SecondaryFontColor) end,
			setFunc = function(r,g,b,a)
				savedVariables.SecondaryFontColor = {r, g, b, a}
			end,
		},
	}
	LAM:RegisterOptionControls("NeatExperienceInfo", optionsTable)
end

function NeatExperienceInfo.OnAddOnLoaded(event, addonName)
  if addonName == NeatExperienceInfo.name then
    NeatExperienceInfo:Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(NeatExperienceInfo.name, EVENT_ADD_ON_LOADED, NeatExperienceInfo.OnAddOnLoaded)

--######################################################################################################################################
--######################################################################################################################################