---
--- Created by YeOldeDragon.
--- DateTime: 2026-03-09
---
--- YeOldePromoEvents - Barre de suivi des Promotional Events actifs.
---

------------------------------
-- Local constant variables
local DEFAULT_TEXT = "n/a"
local BAR_ICON = "/esoui/art/lfg/gamepad/lfg_menuicon_promotionalevents.dds"
local SV_VERSION = 1

local TEXT_CAPSTONE = "<<1>>/<<2>>"

------------------------------
-- Helpers locaux

local function GetActivityColor(progress, threshold)
	if threshold == 0 then
		return YeOldeInfos.Colors.DISABLED
	end
	if progress >= threshold then
		return YeOldeInfos.Colors.GREEN
	end
	if progress > 0 then
		return YeOldeInfos.Colors.GOLD
	end
	return YeOldeInfos.Colors.WHITE
end

------------------------------
-- Class definition
YeOldePromoEvents = YeOldeInfoBar_Base:Subclass()

function YeOldePromoEvents:InitializeControls()
	self.bloc = self.uiBar:AddContentBloc(1, BAR_ICON, DEFAULT_TEXT)
	self.bloc:SetIconSize(30, 30)
	self.bloc:SetMouseEnabled(true)

	self.bloc:SetHandler("OnMouseEnter", function(control)
		self:ShowTooltip(control)
	end)

	self.bloc:SetHandler("OnMouseExit", function()
		ClearTooltipImmediately(InformationTooltip)
		InformationTooltip:SetDimensionConstraints(
			YeOldeInfos.ToolTip.MIN_WIDTH,
			YeOldeInfos.ToolTip.AUTO_SIZE,
			YeOldeInfos.ToolTip.MAX_WIDTH,
			YeOldeInfos.ToolTip.AUTO_SIZE
		)
	end)

	local function OnUpdate()
		self:RefreshBar()
	end

	PROMOTIONAL_EVENT_MANAGER:RegisterCallback("CampaignsUpdated", OnUpdate)
	PROMOTIONAL_EVENT_MANAGER:RegisterCallback("RewardsClaimed", OnUpdate)
	PROMOTIONAL_EVENT_MANAGER:RegisterCallback("ActivityProgressUpdated", OnUpdate)

	EVENT_MANAGER:RegisterForEvent(self.eventNamespace, EVENT_PROMOTIONAL_EVENTS_ACTIVITY_TRACKING_UPDATED, OnUpdate)
end

function YeOldePromoEvents:OnActivate(enabled)
	if enabled then
		self:RefreshBar()
	end
end

--- Retourne la première campagne active, ou nil si aucune.
function YeOldePromoEvents:GetActiveCampaign()
	if not PROMOTIONAL_EVENT_MANAGER then
		return nil
	end
	local numActive = PROMOTIONAL_EVENT_MANAGER:GetNumActiveCampaigns()
	if numActive > 0 then
		return PROMOTIONAL_EVENT_MANAGER:GetCampaignDataByIndex(1)
	end
	return nil
end

function YeOldePromoEvents:RefreshBar()
	local campaignData = self:GetActiveCampaign()

	if not campaignData then
		self.bloc:SetText(DEFAULT_TEXT)
		self.bloc:SetTextColor(YeOldeInfos.Colors.DISABLED:UnpackRGB())
		if self.SV.HideWhenNoEvent then
			self.uiBar:SetHidden(true)
		end
		return
	end

	self.uiBar:SetHidden(false)

	local completed = campaignData:GetNumActivitiesCompleted()
	local threshold = campaignData:GetCapstoneRewardThreshold()

	self.bloc:SetText(zo_strformat(TEXT_CAPSTONE, completed, threshold))
	self.bloc:SetTextColor(YeOldeInfos.Colors.YELLOW:UnpackRGB())
end

function YeOldePromoEvents:ShowTooltip(control)
	local handler = InformationTooltip
	InitializeTooltip(handler)
	ZO_Tooltips_SetupDynamicTooltipAnchors(handler, control)
	handler:SetDimensionConstraints(DEFAULT_TOOLTIP_WIDTH, 0, 0, 0)

	local campaignData = self:GetActiveCampaign()
	-- Temps restant
	local timeLeft = ""
	if campaignData then
		timeLeft = ZO_FormatTime(
			campaignData:GetSecondsRemaining(),
			TIME_FORMAT_STYLE_SHOW_LARGEST_TWO_UNITS,
			TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR
		)
	end

	-- En-tête
	local headerText = campaignData and campaignData:GetDisplayName()
		or YeOldeInfos.lang[SI_YEOLDEINFOS_PROMO_EVENTS_HEADER]
	handler:AddHeaderLine(
		zo_strformat("<<1>>", headerText),
		"ZoFontTooltipTitle",
		1,
		TOOLTIP_HEADER_SIDE_LEFT,
		YeOldeInfos.Colors.GOLD:UnpackRGB()
	)

	if not campaignData then
		ZO_Tooltip_AddDivider(handler)
		handler:AddLine(
			YeOldeInfos.lang[SI_YEOLDEINFOS_PROMO_EVENTS_NONE],
			"ZoFontGame",
			YeOldeInfos.Colors.DISABLED:UnpackRGB()
		)
		return
	end

	-- progression capstone
	local completed = campaignData:GetNumActivitiesCompleted()
	local capThreshold = campaignData:GetCapstoneRewardThreshold()

	handler:AddLine(
		zo_strformat("|c888888<<1>>|r", zo_strformat(SI_EVENT_ANNOUNCEMENT_TIME, timeLeft)),
		"ZoFontGame",
		GetActivityColor(completed, capThreshold):UnpackRGB()
	)

	-- Liste des activités
	local activities = campaignData:GetActivities()
	if activities and #activities > 0 then
		ZO_Tooltip_AddDivider(handler)
		for _, activityData in ipairs(activities) do
			local actName = activityData:GetDisplayName() or "?"
			local progress = activityData:GetProgress()
			local threshold = activityData:GetCompletionThreshold()
			local color = GetActivityColor(progress, threshold)

			-- Icône de la récompense réelle si l'activité en a une
			local rewardSuffix = ""
			if activityData.GetRewardData then
				local rewardData = activityData:GetRewardData()
				if rewardData then
					local icon = rewardData:GetPlatformLootIcon()
					if icon and icon ~= "" then
						rewardSuffix = "  |t24:24:" .. icon .. "|t"
					end
				end
			end

			handler:AddLine(
				zo_strformat(
					"<<1>>  <<2>>/<<3>> <<4>>",
					actName,
					ZO_CommaDelimitNumber(progress),
					ZO_CommaDelimitNumber(threshold),
					rewardSuffix
				),
				"ZoFontGame",
				color:UnpackRGB()
			)
		end
	end
end

------------------------------
-- SavedVariables

function YeOldePromoEvents:InitializeSavedVars()
	if self.SV.Version == 0 then
		self.SV.HideWhenNoEvent = true
	end
	self.SV.Version = SV_VERSION
end

------------------------------
-- Settings menu

function YeOldePromoEvents:InitializeSettingsMenu(controls)
	controls[#controls + 1] = {
		type = "checkbox",
		name = YeOldeInfos.lang[SI_YEOLDEINFOS_PROMO_EVENTS_HIDE_WHEN_NO_EVENT],
		tooltip = YeOldeInfos.lang[SI_YEOLDEINFOS_TT_PROMO_HIDE],
		getFunc = function()
			return self.SV.HideWhenNoEvent
		end,
		setFunc = function(value)
			self.SV.HideWhenNoEvent = value
			self:RefreshBar()
		end,
	}

	return {
		type = "submenu",
		name = GetString(SI_PROMOTIONAL_EVENT_TRACKER_HEADER),
		controls = controls,
	}
end
