local TARGET_UNIT_TAG = "reticleover"
local PLAYER_UNIT_TAG = "player"
local TEXT_MODE_HIDDEN, TEXT_MODE_PERCENT, TEXT_MODE_ABSOLUTE, TEXT_MODE_BOTH = 0, 1, 2, 3
local TEXT_FORMAT_RAW, TEXT_FORMAT_COMMA, TEXT_FORMAT_SHORTENED = 0, 1, 2
local STYLE_NORMAL, STYLE_REVERSE, STYLE_STRAIGHT_NORMAL, STYLE_STRAIGHT_REVERSE = 1, 2, 3, 4

local DIVIDER_BAR_TEMPLATE = {
	attributeBarLeft = {
		width = 9,
		height = 19,
		style = STYLE_REVERSE,
	},
	attributeBarRight = {
		width = 9,
		height = 19,
		style = STYLE_NORMAL,
	},
	targetBarLeft = {
		width = 16,
		height = 19,
		style = STYLE_STRAIGHT_REVERSE,
	},
	targetBarRight = {
		width = 16,
		height = 19,
		style = STYLE_STRAIGHT_NORMAL,
	}
}

sidWarTools.DEFAULT_SETTINGS.attributeBars = {
	enabled = true,
	targetHealthBar = {
		dividerEnabled = false,
		dividerColor = "090903",--ADAF9A
		dividerValue = 4000,
		dividerLimit = 10,
        textEnabled = true,
		dividerTextMode = TEXT_MODE_PERCENT,
		dividerTextFormat = TEXT_FORMAT_RAW,
		generalTextMode = TEXT_MODE_BOTH,
		generalTextFormat = TEXT_FORMAT_RAW
	},
	playerHealthBar = {
		dividerEnabled = false,
		dividerColor = "090903",
		dividerValue = 4000,
		dividerLimit = 10,
        textEnabled = true,
        dividerTextMode = TEXT_MODE_PERCENT,
        dividerTextFormat = TEXT_FORMAT_RAW,
        generalTextMode = TEXT_MODE_BOTH,
        generalTextFormat = TEXT_FORMAT_RAW
	},
	playerMagickaBar = {
		dividerEnabled = false,
		dividerColor = "090903",
		dividerValue = 4000,
		dividerLimit = 10,
        textEnabled = true,
        dividerTextMode = TEXT_MODE_PERCENT,
        dividerTextFormat = TEXT_FORMAT_RAW,
        generalTextMode = TEXT_MODE_BOTH,
        generalTextFormat = TEXT_FORMAT_RAW
	},
	playerStaminaBar = {
		dividerEnabled = false,
		dividerColor = "090903",
		dividerValue = 4000,
		dividerLimit = 10,
		textEnabled = true,
        dividerTextMode = TEXT_MODE_PERCENT,
        dividerTextFormat = TEXT_FORMAT_RAW,
        generalTextMode = TEXT_MODE_BOTH,
        generalTextFormat = TEXT_FORMAT_RAW
	},
	mutationColors = true,
	werewolfGradientStart = {ZO_ColorDef:New("6d4026"):UnpackRGBA()},
	werewolfGradientEnd = {ZO_ColorDef:New("d87f31"):UnpackRGBA()},
	vampireGradientStart = {ZO_ColorDef:New("702255"):UnpackRGBA()},
	vampireGradientEnd = {ZO_ColorDef:New("d8318d"):UnpackRGBA()},
	classIcons = true,
	classLeaderBoardRank = true,
	allianceLeaderBoardRank = true,
}

local WrapFunction = sidWarTools.WrapFunction
local RegisterForEvent = sidWarTools.RegisterForEvent

local function CreateDividerPool()
	local parent, prefix = GuiRoot, "sidAttributeBarDivider"

	local function SetDividerStyle(divider, style)
		local upper, lower = divider.upper, divider.lower
		if style == STYLE_NORMAL then -- >
			upper:ClearAnchors()
			upper:SetAnchor(TOPLEFT, divider, TOPLEFT, 0, 0)
			upper:SetAnchor(BOTTOMRIGHT, divider, RIGHT, 0, 0)
			lower:ClearAnchors()
			lower:SetAnchor(BOTTOMRIGHT, divider, RIGHT, 0, 0)
			lower:SetAnchor(TOPLEFT, divider, BOTTOMLEFT, 0, 0)
			lower:SetHidden(false)
		elseif style == STYLE_REVERSE then -- <
			upper:ClearAnchors()
			upper:SetAnchor(TOPLEFT, divider, TOPRIGHT, 0, 0)
			upper:SetAnchor(BOTTOMRIGHT, divider, LEFT, 0, 0)
			lower:ClearAnchors()
			lower:SetAnchor(BOTTOMRIGHT, divider, LEFT, 0, 0)
			lower:SetAnchor(TOPLEFT, divider, BOTTOMRIGHT, 0, 0)
			lower:SetHidden(false)
		elseif style == STYLE_STRAIGHT_NORMAL then -- /
			upper:ClearAnchors()
			upper:SetAnchor(TOPLEFT, divider, TOPRIGHT, 0, 0)
			upper:SetAnchor(BOTTOMRIGHT, divider, BOTTOMLEFT, 0, 0)
			lower:SetHidden(true)
		elseif style == STYLE_STRAIGHT_REVERSE then -- \
			upper:ClearAnchors()
			upper:SetAnchor(TOPLEFT, divider, TOPLEFT, 0, 0)
			upper:SetAnchor(BOTTOMRIGHT, divider, BOTTOMRIGHT, 0, 0)
			lower:SetHidden(true)
		end
	end

	local function SetDividerColor(divider, color)
		local upper, lower = divider.upper, divider.lower
		local r, g, b, a = color:UnpackRGBA()
		upper:SetColor(r, g, b, a)
		lower:SetColor(r, g, b, a)
	end

	local function CreateLine(divider, name)
		local line = divider:CreateControl(name, CT_LINE)
		line:SetTexture("EsoUI/Art/AvA/AvA_transitLine.dds")
		line:SetDrawLayer(1)
		line:SetDrawLevel(551)
		return line
	end

	local function DividerFactory(pool)
		local name = prefix .. pool:GetNextControlId()
		local divider = parent:CreateControl(name, CT_CONTROL)
		divider.upper = CreateLine(divider, name .. "Upper")
		divider.lower = CreateLine(divider, name .. "Lower")
		divider.SetStyle = SetDividerStyle
		divider.SetColor = SetDividerColor
		return divider
	end

	local function ResetFunction(divider)
		divider:ClearAnchors()
		divider:SetParent(parent)
	end

	return ZO_ObjectPool:New(DividerFactory, ResetFunction)
end

local function GetPercentText(current, max)
	return string.format("%d%%", math.ceil(100 * current / max))
end

local SHORT_TEXT_SUFFIXES = { "", "k", "M" }
local function FormatNumberAsShortenedText(value)
    local index = 1
    while value > 1000 and index < #SHORT_TEXT_SUFFIXES do
        value = value / 1000
        index = index + 1
    end
    return string.format("%.1f%s", value, SHORT_TEXT_SUFFIXES[index])
end

local function GetFormattedText(value, textFormat)
    if(textFormat == TEXT_FORMAT_COMMA) then
        return ZO_CommaDelimitNumber(value)
    elseif(textFormat == TEXT_FORMAT_SHORTENED) then
        return FormatNumberAsShortenedText(value)
    else
        return tostring(value)
    end
end

local function GetBarText(current, shieldValue, max, textMode, textFormat)
    local absoluteText, percentText = "", ""
    local showAbsolute = (textMode == TEXT_MODE_ABSOLUTE or textMode == TEXT_MODE_BOTH)
    local showPercentage = (textMode == TEXT_MODE_PERCENT or textMode == TEXT_MODE_BOTH)

    if(shieldValue and shieldValue > 0) then
        if(showAbsolute) then
            absoluteText = zo_strformat("<<1>> + <<2>> / <<3>>", GetFormattedText(current, textFormat), GetFormattedText(shieldValue, textFormat), GetFormattedText(max, textFormat))
        end
        if(showPercentage) then
            percentText = zo_strformat("<<1>> + <<2>>", GetPercentText(current, max), GetPercentText(shieldValue, max))
        end
    else
        if(showAbsolute) then
            absoluteText = zo_strformat("<<1>> / <<2>>", GetFormattedText(current, textFormat), GetFormattedText(max, textFormat))
        end
        if(showPercentage) then
            percentText = GetPercentText(current, max)
        end
    end

	if(showAbsolute and showPercentage) then
        return zo_strformat("<<1>> (<<2>>)", absoluteText, percentText)
	elseif(showAbsolute) then
		return absoluteText
	elseif(showPercentage) then
		return percentText
	end
end

local function ReleaseActiveDividers(dividerPool, activeDividers)
	for i = 1, #activeDividers do
		dividerPool:ReleaseObject(activeDividers[i])
	end
	activeDividers = {}
end

local function GetDivisionCount(max, saveData)
	local divisions = max / saveData.dividerValue
	return divisions, divisions > saveData.dividerLimit
end

local function SetupDividerControl(dividerPool, activeDividers, parent, templateName, color, anchorTarget, anchorPoint, offset)
	if(not anchorTarget) then return end
	local template = DIVIDER_BAR_TEMPLATE[templateName]
	local divider, key = dividerPool:AcquireObject()
	activeDividers[#activeDividers + 1] = key
	divider:SetParent(parent)
	divider:SetDimensions(template.width, template.height)
	divider:SetStyle(template.style)
	divider:SetColor(color)
	divider:SetAnchor(anchorPoint, anchorTarget, anchorPoint, offset, -1)
end

local function UpdateDividers(dividerPool, activeDividers, parent, template, color, barLeft, barRight, divisions)
	local width = barLeft and barLeft:GetWidth() or barRight:GetWidth()
	local blockSize = width / divisions

	for i = 1, math.ceil(divisions) - 1 do
		local offsetX = blockSize * (i - 0.5)
		SetupDividerControl(dividerPool, activeDividers, parent, template .. "Right", color, barRight, TOPLEFT, offsetX)
		SetupDividerControl(dividerPool, activeDividers, parent, template .. "Left", color, barLeft, TOPRIGHT, -offsetX)
	end
end

local function InitializeTargetFrameHealthBar(saveData, dividerPool)
	local activeDividers = {}

	local HIDE_BAR_TEXT, SHOW_BAR_TEXT = 0, 2 -- keep synced with constants in unitframes.lua
	local targetFrame = ZO_UnitFrames_GetUnitFrame(TARGET_UNIT_TAG)
	local targetHealthBar = targetFrame.healthBar
	local parent = targetFrame.frame
	local barLeft = targetHealthBar.barControls[1]
	local barRight = targetHealthBar.barControls[2]

	local targetBarText = CreateControlFromVirtual(parent:GetName().."HpText1", parent, "ZO_UnitFrameBarText")
	targetBarText:SetAnchor(TOP, nil, BOTTOM, 0, -22)
	targetBarText:SetFont("ZoFontWinT2")
	targetHealthBar.leftText = targetBarText

	targetHealthBar.UpdateText = function(self)
		if(saveData.textEnabled and self.showBarText == SHOW_BAR_TEXT) then
			local shieldValue = GetUnitAttributeVisualizerEffectInfo(TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH)
			local text = GetBarText(self.currentValue, shieldValue, self.maxValue, self.useDividerTextMode and saveData.dividerTextMode or saveData.generalTextMode, self.useDividerTextMode and saveData.dividerTextFormat or saveData.generalTextFormat)
			self.leftText:SetText(text)
			self.leftText:SetHidden(false)
		else
			self.leftText:SetHidden(true)
		end
	end

	local dividerColor = ZO_ColorDef:New(saveData.dividerColor)
	local function OnDividerColorChanged() -- TODO: call on color setting changes
		dividerColor = ZO_ColorDef:New(saveData.dividerColor)
	end

	WrapFunction(targetHealthBar, "Update", function(originalUpdate, self, ...)
		originalUpdate(self, ...)

		local divisions, hasTooManyDivisions = GetDivisionCount(self.maxValue, saveData)

		self.useDividerTextMode = saveData.dividerEnabled and not hasTooManyDivisions
		if((self.useDividerTextMode and saveData.dividerTextMode ~= TEXT_MODE_HIDDEN) or (not self.useDividerTextMode and saveData.generalTextMode ~= TEXT_MODE_HIDDEN)) then
			if(targetHealthBar.showBarText ~= SHOW_BAR_TEXT) then
				targetHealthBar:SetBarTextMode(SHOW_BAR_TEXT)
			end
		else
			if(targetHealthBar.showBarText ~= HIDE_BAR_TEXT) then
				targetHealthBar:SetBarTextMode(HIDE_BAR_TEXT)
			end
		end

		ReleaseActiveDividers(dividerPool, activeDividers)
		if(saveData.dividerEnabled and not hasTooManyDivisions) then
			UpdateDividers(dividerPool, activeDividers, parent, "targetBar", dividerColor, barLeft, barRight, divisions)
		end
	end)

	local function UpdateText(_, unitTag, unitAttributeVisual, statType, attributeType, powerType)
		if(unitAttributeVisual ~= ATTRIBUTE_VISUAL_POWER_SHIELDING or statType ~= STAT_MITIGATION or attributeType ~= ATTRIBUTE_HEALTH or powerType ~= POWERTYPE_HEALTH) then return end
		targetHealthBar:UpdateText()
	end
	local namespace = RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, UpdateText)
	EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, TARGET_UNIT_TAG)
	namespace = RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, UpdateText)
	EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, TARGET_UNIT_TAG)
	namespace = RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, UpdateText)
	EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, TARGET_UNIT_TAG)

	--	SLASH_COMMANDS["/sethp"] = function(value)
	--		local current, max = zo_strsplit(",", value)
	--		--		healthBar:UpdateStatusBar(tonumber(current), tonumber(max), tonumber(max))
	--		targetFrame:SetHasTarget(true)
	--		targetHealthBar:Update(targetHealthBar.barType, tonumber(current), tonumber(max))
	--	end
end

local function InitializeAttributeBar(attributeBar, saveData, dividerPool, reversed, hasShield)
	local activeDividers = {}

	attributeBar:SetTextEnabled(true) -- enable it so the label control gets created
	attributeBar.label:SetFont("ZoFontWinT2")

	WrapFunction(attributeBar.label, "SetText", function(originalSetText, self)
		local shieldValue
		if(hasShield) then
			shieldValue = GetUnitAttributeVisualizerEffectInfo(PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH)
		end
		local text = GetBarText(attributeBar.current, shieldValue, attributeBar.max, attributeBar.useDividerTextMode and saveData.dividerTextMode or saveData.generalTextMode, self.useDividerTextMode and saveData.dividerTextFormat or saveData.generalTextFormat)
		originalSetText(self, text)
	end)

	local parent = attributeBar.control
	local barLeft = attributeBar.barControls[1]
	local barRight = attributeBar.barControls[2]
	if(reversed) then
		barRight = barLeft
		barLeft = nil
	end

	local dividerColor = ZO_ColorDef:New(saveData.dividerColor)
	local function OnDividerColorChanged() -- TODO: call on color setting changes
		dividerColor = ZO_ColorDef:New(saveData.dividerColor)
	end

	WrapFunction(attributeBar, "UpdateStatusBar", function(originalUpdate, self, ...)
		local result = originalUpdate(self, ...)

		local divisions, hasTooManyDivisions = GetDivisionCount(self.max, saveData)

		self.useDividerTextMode = saveData.dividerEnabled and not hasTooManyDivisions
		self:SetTextEnabled(saveData.textEnabled and ((self.useDividerTextMode and saveData.dividerTextMode ~= TEXT_MODE_HIDDEN) or (not self.useDividerTextMode and saveData.generalTextMode ~= TEXT_MODE_HIDDEN)))

		ReleaseActiveDividers(dividerPool, activeDividers)
		if(saveData.dividerEnabled and not hasTooManyDivisions) then
			UpdateDividers(dividerPool, activeDividers, parent, "attributeBar", dividerColor, barLeft, barRight, divisions)
		end

		return result
	end)

    -- trick the function into updating even when the actual values didn't change
    attributeBar:UpdateStatusBar(attributeBar.current, attributeBar.max, attributeBar.effectiveMax + 0.0001)

	if(hasShield) then
		local function UpdateText(_, unitTag, unitAttributeVisual, statType, attributeType, powerType)
			if(unitAttributeVisual ~= ATTRIBUTE_VISUAL_POWER_SHIELDING or statType ~= STAT_MITIGATION or attributeType ~= ATTRIBUTE_HEALTH or powerType ~= POWERTYPE_HEALTH) then return end
			attributeBar.label:SetText("")
		end
		local namespace = RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, UpdateText)
		EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, PLAYER_UNIT_TAG)
		namespace = RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, UpdateText)
		EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, PLAYER_UNIT_TAG)
		namespace = RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, UpdateText)
		EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, PLAYER_UNIT_TAG)
	end
end

local WEREWOLF_ABILITY = GetAbilityName(35658)
local VAMPIRE_ABILITYS = {
	[GetAbilityName(35792)] = true, -- Stage 4 Vampirism
	[GetAbilityName(35783)] = true, -- Stage 3 Vampirism
	[GetAbilityName(35773)] = true, -- Stage 2 Vampirism
	[GetAbilityName(35771)] = true, -- Stage 1 Vampirism
	[GetAbilityName(39472)] = true, -- Vampirism
}

local MUTATION_NONE = 0
local MUTATION_WEREWOLF = 1
local MUTATION_VAMPIRE = 2

local MUTATION_COLOR = {}
local function RefreshMutationColors(saveData)
	MUTATION_COLOR[MUTATION_NONE] = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH]
	MUTATION_COLOR[MUTATION_WEREWOLF] = { ZO_ColorDef:New(unpack(saveData.werewolfGradientStart)), ZO_ColorDef:New(unpack(saveData.werewolfGradientEnd)) }
	MUTATION_COLOR[MUTATION_VAMPIRE] = { ZO_ColorDef:New(unpack(saveData.vampireGradientStart)), ZO_ColorDef:New(unpack(saveData.vampireGradientEnd)) }
end
sidWarTools.RefreshMutationColors = RefreshMutationColors

local function GetUnitMutation(unitTag)
	for i = 1, GetNumBuffs(unitTag) do
		local buffName = GetUnitBuffInfo(unitTag, i)
		if(WEREWOLF_ABILITY == buffName) then
			return MUTATION_WEREWOLF
		elseif(VAMPIRE_ABILITYS[buffName]) then
			return MUTATION_VAMPIRE
		end
	end
	return MUTATION_NONE
end

local function InitializeTargetFrameEnhancements(saveData)
	local targetUnitFrame = ZO_UnitFrames_GetUnitFrame(TARGET_UNIT_TAG)

	if(saveData.classIcons) then
		local classIcon = targetUnitFrame.frame:CreateControl("$(parent)ClassIcon", CT_TEXTURE)
		table.insert(targetUnitFrame.fadeComponents, classIcon)
		classIcon:SetHidden(true)
		classIcon:SetDimensions(32, 32)
		classIcon:SetAnchor(LEFT, targetUnitFrame.nameLabel, RIGHT, 1, 0)
		targetUnitFrame.rankIcon:ClearAnchors()
		targetUnitFrame.rankIcon:SetAnchor(LEFT, classIcon, RIGHT, 1, 0)
		targetUnitFrame.classIcon = classIcon

		ZO_PreHook(targetUnitFrame.nameLabel, 'SetText', function()
			if(DoesUnitExist(TARGET_UNIT_TAG) and IsUnitPlayer(TARGET_UNIT_TAG)) then
				classIcon:SetTexture(GetClassIcon(GetUnitClassId(TARGET_UNIT_TAG)))
				classIcon:SetHidden(false)
			else
				classIcon:SetHidden(true)
			end
		end)
	end

	if(saveData.mutationColors) then
		local function GetPowerShieldModule(targetUnitFrame)
			for module in pairs(targetUnitFrame.attributeVisualizer.visualModules) do
				if(module.__index == ZO_UnitVisualizer_PowerShieldModule) then
					return module
				end
			end
		end

		RefreshMutationColors(saveData)
		local healthBar = targetUnitFrame.healthBar
		local controls = {
			healthBar.barControls[1], -- left half of healthbar
			healthBar.barControls[2], -- right half of healthbar
		}

		local function SetGradientColor(color)
			for i = 1, #controls do
				ZO_StatusBar_SetGradientColor(controls[i], color)
			end
		end

		local mutation
		ZO_PreHook(targetUnitFrame.nameLabel, 'SetText', function()
			if(DoesUnitExist(TARGET_UNIT_TAG) and IsUnitPlayer(TARGET_UNIT_TAG)) then
				mutation = GetUnitMutation(TARGET_UNIT_TAG)
				SetGradientColor(MUTATION_COLOR[mutation])
			else
				SetGradientColor(MUTATION_COLOR[MUTATION_NONE])
			end
		end)

		local powerShieldModule = GetPowerShieldModule(targetUnitFrame)
		WrapFunction(powerShieldModule, "PlayAnimation", function(originalPlayAnimation, self, bar, info)
			local firstRun = false
			if(not info.shieldLeftOverlay) then
				firstRun = true
			end

			local colorBackup = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH]
			ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH] = MUTATION_COLOR[mutation]
			originalPlayAnimation(self, bar, info)
			ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH] = colorBackup

			if(firstRun) then
				controls[#controls + 1] = targetUnitFrame.frame:GetNamedChild("PowerShieldLeftOverlay").chunk -- left half of shield overlay
				controls[#controls + 1] = targetUnitFrame.frame:GetNamedChild("PowerShieldRightOverlay").chunk -- right half of shield overlay
			end
		end)
	end
end

local function InitializeLeaderBoardRankLabels(saveData)
	if(not (saveData.classLeaderBoardRank or saveData.allianceLeaderBoardRank)) then return end

	local targetUnitFrame = ZO_UnitFrames_GetUnitFrame(TARGET_UNIT_TAG)
	local classLeaderBoardRank, allianceLeaderBoardRank
	if(targetUnitFrame.classIcon and saveData.classLeaderBoardRank) then
		classLeaderBoardRank = targetUnitFrame.frame:CreateControl("$(parent)ClassLeaderBoardRank", CT_LABEL)
		table.insert(targetUnitFrame.fadeComponents, classLeaderBoardRank)
		classLeaderBoardRank:SetAnchor(TOP, targetUnitFrame.classIcon, BOTTOM, 0, -10)
		classLeaderBoardRank:SetFont("ZoFontGameSmall")
		classLeaderBoardRank:SetColor(1, 1, 1, 1)
	end

	if(saveData.allianceLeaderBoardRank) then
		allianceLeaderBoardRank = targetUnitFrame.frame:CreateControl("$(parent)AllianceLeaderBoardRank", CT_LABEL)
		table.insert(targetUnitFrame.fadeComponents, allianceLeaderBoardRank)
		allianceLeaderBoardRank:SetAnchor(TOP, targetUnitFrame.rankIcon, BOTTOM, 0, -10)
		allianceLeaderBoardRank:SetFont("ZoFontGameSmall")
		allianceLeaderBoardRank:SetColor(1, 1, 1, 1)
	end

	if(not classLeaderBoardRank and not allianceLeaderBoardRank) then return end

	local function ResetTimeout(callback, duration, timeoutId)
		if(timeoutId ~= nil) then
			EVENT_MANAGER:UnregisterForUpdate("CallLaterFunction" .. timeoutId)
		end
		return zo_callLater(callback, duration)
	end

	local function GenerateAllianceLookupTable(campaignId, allianceId)
		local leaderBoardRankLookup = {}
		for i = 1, GetNumCampaignAllianceLeaderboardEntries(campaignId, allianceId) do
			local isPlayer, ranking, charName, alliancePoints, classId, displayName = GetCampaignAllianceLeaderboardEntryInfo(campaignId, allianceId, i)
			leaderBoardRankLookup[charName] = ranking
		end
		return leaderBoardRankLookup
	end

	local function SortByRank(a, b)
		return a.rank < b.rank
	end

	local CLASS_DRAGONKNIGHT = 1
	local CLASS_SORCERER = 2
	local CLASS_NIGHTBLADE = 3
	local CLASS_WARDEN = 4
	local CLASS_NECROMANCER = 5
	local CLASS_TEMPLAR = 6
	local function GenerateClassLookupTables(campaignId)
		local rankTable = {
			[CLASS_DRAGONKNIGHT] = {},
			[CLASS_SORCERER] = {},
			[CLASS_NIGHTBLADE] = {},
			[CLASS_WARDEN] = {},
			[CLASS_NECROMANCER] = {},
			[CLASS_TEMPLAR] = {},
		}
		local classRanking
		for i = 1, GetNumCampaignLeaderboardEntries(campaignId) do
			local isPlayer, ranking, charName, alliancePoints, classId, allianceId, displayName = GetCampaignLeaderboardEntryInfo(campaignId, i)
			classRanking = rankTable[classId]
			classRanking[#classRanking + 1] = { name = charName, rank = ranking }
		end

		for classId, classRanking in pairs(rankTable) do
			table.sort(classRanking, SortByRank)
			local lookUp = {}
			for i = 1, #classRanking do
				lookUp[classRanking[i].name] = i
			end
			rankTable[classId] = lookUp
		end
		return rankTable
	end

	local UPDATE_TIMEOUT = 5*60*1000
	local timeoutId
	local allianceLeaderBoardRankLookup = {
		[ALLIANCE_ALDMERI_DOMINION] = {},
		[ALLIANCE_EBONHEART_PACT] = {},
		[ALLIANCE_DAGGERFALL_COVENANT] = {},
	}
	local classLeaderBoardRankLookup = GenerateClassLookupTables(0)

	local function DoUpdateData()
		if(IsInCampaign()) then
			QueryCampaignLeaderboardData()
		end
	end

	RegisterForEvent(EVENT_CAMPAIGN_LEADERBOARD_DATA_CHANGED, function()
		local campaignId = GetCurrentCampaignId()

		for allianceId in ipairs(allianceLeaderBoardRankLookup) do
			allianceLeaderBoardRankLookup[allianceId] = GenerateAllianceLookupTable(campaignId, allianceId)
		end
		classLeaderBoardRankLookup = GenerateClassLookupTables(campaignId)

		timeoutId = ResetTimeout(DoUpdateData, UPDATE_TIMEOUT, timeoutId)
	end)

	RegisterForEvent(EVENT_PLAYER_ACTIVATED, DoUpdateData)

	ZO_PreHook(targetUnitFrame.nameLabel, 'SetText', function()
		local classRank, allianceRank, name, class, alliance
		if(IsInCampaign() and DoesUnitExist(TARGET_UNIT_TAG) and IsUnitPlayer(TARGET_UNIT_TAG)) then
			name = GetUnitName(TARGET_UNIT_TAG)
			class = GetUnitClassId(TARGET_UNIT_TAG)
			alliance = GetUnitAlliance(TARGET_UNIT_TAG)
			classRank = classLeaderBoardRankLookup[class][name]
			allianceRank = allianceLeaderBoardRankLookup[alliance][name]
		end

		if(classLeaderBoardRank) then
			if(classRank) then
				classLeaderBoardRank:SetText(("#%d"):format(classRank))
			end
			classLeaderBoardRank:SetHidden(not classRank)
		end

		if(allianceLeaderBoardRank) then
			if(allianceRank) then
				allianceLeaderBoardRank:SetText(("#%d"):format(allianceRank))
			end
			allianceLeaderBoardRank:SetHidden(not allianceRank)
		end
	end)
end

local function Initialize(saveData)
	if(saveData.enabled) then
		local dividerPool = CreateDividerPool()
		InitializeTargetFrameHealthBar(saveData.targetHealthBar, dividerPool)
		InitializeAttributeBar(PLAYER_ATTRIBUTE_BARS.bars[1], saveData.playerHealthBar, dividerPool, false, true)
		InitializeAttributeBar(PLAYER_ATTRIBUTE_BARS.bars[3], saveData.playerMagickaBar, dividerPool)
		InitializeAttributeBar(PLAYER_ATTRIBUTE_BARS.bars[5], saveData.playerStaminaBar, dividerPool, true)
	end
	InitializeTargetFrameEnhancements(saveData)
	InitializeLeaderBoardRankLabels(saveData)
end

sidWarTools.InitializeAttributeBars = Initialize
sidWarTools.AttributeBarTextMode = {
	TEXT_MODE_HIDDEN = TEXT_MODE_HIDDEN,
	TEXT_MODE_PERCENT = TEXT_MODE_PERCENT,
	TEXT_MODE_ABSOLUTE = TEXT_MODE_ABSOLUTE,
	TEXT_MODE_BOTH = TEXT_MODE_BOTH
}
