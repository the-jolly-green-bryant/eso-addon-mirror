-- This libray is currently only for internal use and its API might change a lot between versions
local lib = LibStub:NewLibrary("LibAbilityTooltip", 1.1)

if not lib then
	return	-- already loaded and no upgrade necessary
end

local LIB_IDENTIFIER = "LibAbilityTooltip"
local ICON_MISSING = "EsoUI/Art/Icons/icon_missing.dds"
local ABILITY_LINK = "LATAbility"
local CURRENT_VERSION = 1
local ABILITY_LINK_MATCH1 = "(|H.-:.-:.-|h.-|h)"
local ABILITY_LINK_MATCH2 = ("|H(.-):.-%s:(.-):(.-)|h.-|h"):format(ABILITY_LINK)
local ABILITY_LINK_TEMPLATE = ("|cFF7B52|H%%d:%s:%%d:%%d|h%%s|h|r"):format(ABILITY_LINK)
local ABILITY_LINK_WRAPPED_TEMPLATE = ("|H%%d:book:851:%s:%%d:%%d|h|h"):format(ABILITY_LINK)

local function CreateControls()
	local container = CreateTopLevelWindow("LibAbilityTooltipWindow")
	container:SetDrawTier(DT_HIGH)
	container:SetDrawLevel(ZO_HIGH_TIER_TOOLTIPS)

	local tooltip = CreateControlFromVirtual("LibAbilityTooltipControl", container, "ZO_BaseTooltip")
	tooltip:SetResizeToFitPadding(32, 40)
	tooltip:SetDimensionConstraints(384, nil, 384, nil)
	tooltip:SetHidden(true)
	tooltip:SetAnchor(CENTER)

	local fadeLeft = tooltip:CreateControl("$(parent)FadeLeft", CT_TEXTURE)
	fadeLeft:SetTexture("EsoUI/Art/ItemToolTip/iconStrip.dds")
	fadeLeft:SetExcludeFromResizeToFitExtents(true)
	fadeLeft:SetDimensions(100, 4)
	fadeLeft:SetTextureCoords(1, 0)
	fadeLeft:SetAnchor(TOPRIGHT, nil, TOP)

	local fadeRight = tooltip:CreateControl("$(parent)FadeRight", CT_TEXTURE)
	fadeRight:SetTexture("EsoUI/Art/ItemToolTip/iconStrip.dds")
	fadeRight:SetExcludeFromResizeToFitExtents(true)
	fadeRight:SetDimensions(100, 4)
	fadeRight:SetAnchor(TOPLEFT, nil, TOP)

	local missingIcon = tooltip:CreateControl("$(parent)MissingIcon", CT_TEXTURE)
	missingIcon:SetTexture("EsoUI/Art/Icons/icon_missing.dds")
	missingIcon:SetExcludeFromResizeToFitExtents(true)
	missingIcon:SetDimensions(64, 64)
	missingIcon:SetAnchor(CENTER, nil, TOP)

	local icon = tooltip:CreateControl("$(parent)Icon", CT_TEXTURE)
	icon:SetExcludeFromResizeToFitExtents(true)
	icon:SetDimensions(64, 64)
	icon:SetAnchor(CENTER, nil, TOP)
	icon:SetHandler("OnTextureLoaded", function()
		missingIcon:SetHidden(true)
	end)
	local originalSetTexture = icon.SetTexture
	icon.SetTexture = function(...)
		originalSetTexture(...)
		if(not icon:IsTextureLoaded()) then
			missingIcon:SetHidden(false)
		end
	end

	local closeButton = CreateControlFromVirtual("$(parent)Close", tooltip, "ZO_CloseButton")
	closeButton:SetExcludeFromResizeToFitExtents(true)
	closeButton:SetAnchor(TOPRIGHT, nil, nil, -6, 6)
	closeButton:SetHandler("OnClicked", function() lib:HideTooltip() end)
	closeButton:SetHidden(true)

	lib.container = container
	lib.tooltip = tooltip
	lib.icon = icon
	lib.closeButton = closeButton
end

local function AquireTooltip()
	if(not lib.tooltip) then
		CreateControls()
	end
	return lib.tooltip
end

local function AquireContainer()
	if(not lib.container) then
		CreateControls()
	end
	return lib.container
end

local function AquireIcon()
	if(not lib.icon) then
		CreateControls()
	end
	return lib.icon
end

local function AddHeadline(tooltip, text)
	tooltip:AddVerticalPadding(32)
	tooltip:AddLine(text, "ZoFontTooltipTitle", 1, 1, 1, nil, MODIFY_TEXT_TYPE_UPPERCASE)
end

local function AddDivider(tooltip)
	ZO_Tooltip_AddDivider(tooltip)
end

local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
local function AddStatValuePair(tooltip, label, value)
	tooltip:AddVerticalPadding(-5)
	tooltip:AddLine(label, "ZoFontGameBold", r, g, b, nil, nil, TEXT_ALIGN_LEFT, true)
	tooltip:AddVerticalPadding(-35)
	tooltip:AddLine(value, "ZoFontGameBold", 1, 1, 1, nil, nil, TEXT_ALIGN_RIGHT, true)
end

local function AddBodyHeader(tooltip, text)
	tooltip:AddLine(text, "ZoFontWinH5", 1, 1, 1, nil, nil, TEXT_ALIGN_CENTER, true)
end

local function AddBodyText(tooltip, text)
	tooltip:AddLine(text, "ZoFontGameMedium", r, g, b, nil, nil, TEXT_ALIGN_CENTER, true)
end

function lib:SetAbility(abilityId)
	if(self.abilityId == abilityId) then return end
	local tooltip = AquireTooltip()
	tooltip:ClearLines()
	if(DoesAbilityExist(abilityId)) then
		local icon = AquireIcon()
		icon:SetTexture(GetAbilityIcon(abilityId))

		AddHeadline(tooltip, GetAbilityName(abilityId))
		AddDivider(tooltip)

		if(not IsAbilityPassive(abilityId)) then
			local label, value

			local channeled, castTime, channelTime = GetAbilityCastInfo(abilityId)
			if(channeled) then
				label = GetString(SI_ABILITY_TOOLTIP_CHANNEL_TIME_LABEL)
				value = ZO_FormatTimeMilliseconds(channelTime, TIME_FORMAT_STYLE_CHANNEL_TIME, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE)
			else
				label = GetString(SI_ABILITY_TOOLTIP_CAST_TIME_LABEL)
				value = ZO_FormatTimeMilliseconds(castTime, TIME_FORMAT_STYLE_CAST_TIME, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE)
			end
			AddStatValuePair(tooltip, label, value)

			local targetDescription = GetAbilityTargetDescription(abilityId)
			if(targetDescription) then
				label = GetString(SI_ABILITY_TOOLTIP_TARGET_TYPE_LABEL)
				value = targetDescription
				AddStatValuePair(tooltip, label, value)
			end

			local minRangeCM, maxRangeCM = GetAbilityRange(abilityId)
			if(maxRangeCM > 0) then
				label = GetString(SI_ABILITY_TOOLTIP_RANGE_LABEL)
				value = targetDescription
				if(minRangeCM == 0) then
					value = zo_strformat(SI_ABILITY_TOOLTIP_RANGE, FormatFloatRelevantFraction(maxRangeCM / 100))
				else
					value = zo_strformat(SI_ABILITY_TOOLTIP_MIN_TO_MAX_RANGE, FormatFloatRelevantFraction(minRangeCM / 100), FormatFloatRelevantFraction(maxRangeCM / 100))
				end
				AddStatValuePair(tooltip, label, value)
			end

			local radiusCM = GetAbilityRadius(abilityId)
			local angleDistanceCM = GetAbilityAngleDistance(abilityId)
			if(radiusCM > 0) then
				if(angleDistanceCM > 0) then
					label = GetString(SI_ABILITY_TOOLTIP_AREA_LABEL)
					value = zo_strformat(SI_ABILITY_TOOLTIP_AOE_DIMENSIONS, FormatFloatRelevantFraction(radiusCM / 100), FormatFloatRelevantFraction(angleDistanceCM * 2 / 100))
				else
					label = GetString(SI_ABILITY_TOOLTIP_RADIUS_LABEL)
					value = zo_strformat(SI_ABILITY_TOOLTIP_RADIUS, FormatFloatRelevantFraction(radiusCM / 100))
				end
				AddStatValuePair(tooltip, label, value)
			end

			local durationMS = GetAbilityDuration(abilityId)
			if(durationMS > 0) then
				label = GetString(SI_ABILITY_TOOLTIP_DURATION_LABEL)
				value = ZO_FormatTimeMilliseconds(durationMS, TIME_FORMAT_STYLE_DURATION, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE)
				AddStatValuePair(tooltip, label, value)
			end

			local cost, mechanic = GetAbilityCost(abilityId)
			if(cost > 0) then
				label = GetString(SI_ABILITY_TOOLTIP_RESOURCE_COST_LABEL)
				value = zo_strformat(SI_ABILITY_TOOLTIP_RESOURCE_COST, cost, GetString("SI_COMBATMECHANICTYPE", mechanic))
				AddStatValuePair(tooltip, label, value)
			end
		end

		local descriptionHeader = GetAbilityDescriptionHeader(abilityId)
		local description = GetAbilityDescription(abilityId)
		if(descriptionHeader ~= "" or description ~= "") then
			if(not IsAbilityPassive(abilityId)) then
				AddDivider(tooltip)
			end

			if(descriptionHeader ~= "") then
				AddBodyHeader(tooltip, zo_strformat(SI_ABILITY_TOOLTIP_DESCRIPTION_HEADER, descriptionHeader))
			end

			if(description ~= "") then
				AddBodyText(tooltip, zo_strformat(SI_ABILITY_TOOLTIP_DESCRIPTION, description))
			end

			AddBodyText(tooltip, "")
			AddBodyText(tooltip, "")
		end
	else
		AddBodyText(tooltip, "Invalid Ability")
	end
	self.abilityId = abilityId
end

function lib:SetAnchor(...)
	local tooltip = AquireTooltip()
	tooltip:ClearAnchors()
	tooltip:SetAnchor(...)
end

function lib:ShowTooltip(abilityId, isPopupTooltip)
	self:SetAbility(abilityId)
	local tooltip = AquireTooltip()
	tooltip:SetHidden(false)

	lib.closeButton:SetHidden(not isPopupTooltip)
	if(isPopupTooltip and not lib.wasPopupTooltip) then
		lib.wasPopupTooltip = true
		tooltip:ClearAnchors()
		tooltip:SetAnchor(CENTER, GuiRoot, CENTER)
		tooltip:SetMovable(true)
		tooltip:SetMouseEnabled(true)
	elseif(not isPopupTooltip and lib.wasPopupTooltip) then
		lib.wasPopupTooltip = false
		tooltip:SetMovable(false)
		tooltip:SetMouseEnabled(false)
	end
end

function lib:HideTooltip()
	local tooltip = AquireTooltip()
	tooltip:SetHidden(true)
end

local function ParseAbilityLink(link)
	local linkStyle, version, abilityId = link:match(ABILITY_LINK_MATCH2)
	return tonumber(linkStyle), tonumber(version), tonumber(abilityId)
end

local function ReplaceLink(link)
	local linkStyle, version, abilityId = ParseAbilityLink(link)
	if(linkStyle == nil) then return end
	if(version == CURRENT_VERSION and linkStyle ~= nil and DoesAbilityExist(abilityId)) then
		local name = GetAbilityName(abilityId)
		if(linkStyle == LINK_STYLE_BRACKETS) then name = "[" .. name .. "]" end
		return ABILITY_LINK_TEMPLATE:format(linkStyle, version, abilityId, name)
	end
end

function lib:ReplaceAbilityLinks(message)
	message = message:gsub(ABILITY_LINK_MATCH1, ReplaceLink)
	return message
end

function lib:CreateAbilityLink(abilityId, linkStyle)
	if(not linkStyle or (linkStyle ~= LINK_STYLE_DEFAULT and linkStyle ~= LINK_STYLE_BRACKETS)) then linkStyle = LINK_STYLE_DEFAULT end
	return ABILITY_LINK_WRAPPED_TEMPLATE:format(linkStyle, CURRENT_VERSION, abilityId)
end

if(not lib.HasHookedChat) then
	lib.HasHookedChat = true

	lib.AddWindow_Orig = SharedChatContainer.AddWindow
	lib.AddMessage_Orig = {}
	SharedChatContainer.AddWindow = function(...)
		local window = lib.AddWindow_Orig(...)
		local buffer = window.buffer

		local AddMessage_Orig = buffer.AddMessage
		lib.AddMessage_Orig[buffer] = AddMessage_Orig
		buffer.AddMessage = function(self, message, ...)
			if(message and #message > 0) then
				message = lib:ReplaceAbilityLinks(message)
			end
			AddMessage_Orig(self, message, ...)
		end

		return window
	end
end

EVENT_MANAGER:UnregisterForEvent(LIB_IDENTIFIER, EVENT_PLAYER_ACTIVATED)
EVENT_MANAGER:RegisterForEvent(LIB_IDENTIFIER, EVENT_PLAYER_ACTIVATED, function()
	EVENT_MANAGER:UnregisterForEvent(LIB_IDENTIFIER, EVENT_PLAYER_ACTIVATED)

	local function HandleAbilityLink(link, button, control, color, linkType, copyBufferIndex, messageIndex)
		if(linkType == ABILITY_LINK) then
			local _, version, abilityId = ParseAbilityLink(link)
			if(version == CURRENT_VERSION) then
				lib:ShowTooltip(abilityId, true)
			end
			return true
		end
	end

	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, HandleAbilityLink)
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, HandleAbilityLink)
end)
