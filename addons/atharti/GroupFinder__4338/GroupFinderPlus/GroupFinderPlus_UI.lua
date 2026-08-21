local GF = GroupFinderPlus

local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER

GF.ColorPickers = {
	title = {
		savedColor = "AA55EE",
		fieldName = "ZO_GroupFinder_Keyboard_TopLevelCreateGroupListingPanelContentGroupTitleBackdropEdit",
		texture	  = "GroupFinderPlus\\Textures\\color2.dds"
	},
	desc  = {
		savedColor = "55AAEE",
		fieldName = "ZO_GroupFinder_Keyboard_TopLevelCreateGroupListingPanelContentDescriptionEdit",
		texture	  = "GroupFinderPlus\\Textures\\color2.dds"
	}
}

-- =========================================================
-- Fix hex to avoid 3+ repeated letters (GF limitation)
-- =========================================================
function GF.FixHexForText(hex)
	local result = {}
	local count = 1
	local prev = nil

	for i = 1, #hex do
		local c = hex:sub(i,i)
		if c == prev then
			count = count + 1
			if count > 2 then
				local n = tonumber(c,16)
				if n then
					n = (n + 1) % 16
					c = string.format("%X", n)
				end
				count = 1
			end
		else
			count = 1
		end
		result[#result + 1] = c
		prev = c
	end

	return table.concat(result)
end

-- =========================================================
-- Wrap text with color code
-- =========================================================
function GF.ColorizeText(text, hex)
	if not hex then hex = "FFFFFF" end
	hex = GF.FixHexForText(hex)
	return string.format("|c%s%s|r", hex, text)
end

-- =========================================================
-- Apply color to the field
-- =========================================================
function GF.ApplyColorToField(fieldName, hex)
	local field = WM:GetControlByName(fieldName)
	if not field then return end

	local text = field:GetText()
	if not text or text == "" then return end

	field:SetText(GF.ColorizeText(text, hex))
end

-- =========================================================
-- Callback when color is picked
-- =========================================================
function GF.OnColorPicked(fieldKey, r, g, b)
	local hex = ZO_ColorDef:New(r, g, b):ToHex()
	hex = GF.FixHexForText(hex)

	GF.ColorPickers[fieldKey].savedColor = hex
	GF.ApplyColorToField(GF.ColorPickers[fieldKey].fieldName, hex)
end

-- =========================================================
-- Create an icon button for a field
-- =========================================================
function GF.CreateIconButton(fieldKey)
	local cfg = GF.ColorPickers[fieldKey]
	local field = WM:GetControlByName(cfg.fieldName)
	if not field then return end

	local button = WM:CreateControl("GFP_" .. fieldKey .. "_ColorButton", field:GetParent(), CT_TEXTURE)

	button:SetTexture(cfg.texture)
	button:SetDimensions(24, 24)
	button:SetMouseEnabled(true)

	if fieldKey == "title" then
		button:SetAnchor(LEFT, field, LEFT, -40, 0)
	else
		button:SetAnchor(LEFT, field, LEFT, -39, -33)
	end

	button:SetHandler("OnMouseUp", function()
		COLOR_PICKER:Show(function(r, g, b) GF.OnColorPicked(fieldKey, r, g, b) end, ZO_ColorDef:New(cfg.savedColor):UnpackRGB())
	end)

	return button
end

-- =========================================================
-- Init color pickers
-- =========================================================
function GF.InitializeColorPickers()
	GF.CreateIconButton("title")
	GF.CreateIconButton("desc")
end

-- =========================================================
-- Recreate Button
-- =========================================================
function GF.CreateRecreateButton(parentName)
	local parent = WM:GetControlByName(parentName)
	if not parent then return end

	local createButton = parent:GetNamedChild("CreateGroupButton")
	if not createButton then return end

	local button = WM:CreateControl(parentName .. "RecreateButton", parent, CT_TEXTURE)
	button:SetTexture("esoui/art/lfg/lfg_groupfinder_refreshsearch_up.dds")
	button:SetDimensions(40, 40)
	button:SetMouseEnabled(true)
	button:SetAnchor(RIGHT, createButton, LEFT, -10, 0)

	button:SetHandler("OnMouseEnter", function(self)
		InitializeTooltip(InformationTooltip, self, RIGHT, 5, 0)
		SetTooltipText(InformationTooltip, "Recreate last listing")

		button:SetTexture("esoui/art/lfg/lfg_groupfinder_refreshsearch_over.dds")
	end)

	button:SetHandler("OnMouseExit", function()
		ClearTooltip(InformationTooltip)
		button:SetTexture("esoui/art/lfg/lfg_groupfinder_refreshsearch_up.dds")
	end)

	button:SetHandler("OnMouseDown", function()
		button:SetTexture("esoui/art/lfg/lfg_groupfinder_refreshsearch_down.dds")
	end)

	button:SetHandler("OnMouseUp", function()
		button:SetTexture("esoui/art/lfg/lfg_groupfinder_refreshsearch_up.dds")
		GF.RestoreSavedListing()
	end)

	return button
end

function GF.InitializeRecreateButtons()
	GF.CreateRecreateButton("ZO_GroupFinder_Keyboard_TopLevelOverview")
	GF.CreateRecreateButton("ZO_GroupFinder_Keyboard_TopLevelSearchPanel")
end

-- =========================================================
-- Saved Listing Data
-- =========================================================
local savedListingData = nil
local userType = 0

function GF.GetSelectedSecondaryIndex(userType)
	local count = GetGroupFinderUserTypeGroupListingNumSecondaryOptions(userType)
	for i = 1, count do
		local _, setState = GetGroupFinderUserTypeGroupListingSecondaryOptionByIndex(userType, i)
		if setState then
			return i
		end
	end
end

function GF.GetSelectedPrimaryIndex(userType)
	local count = GetGroupFinderUserTypeGroupListingNumPrimaryOptions(userType)
	for i = 1, count do
		local _, setState = GetGroupFinderUserTypeGroupListingPrimaryOptionByIndex(userType, i)
		if setState then
			return i
		end
	end
end

function GF.SaveCurrentListing()
	local selectedSecondaryIndex = GF.GetSelectedSecondaryIndex(userType)

	local selectedPrimaryIndex = GF.GetSelectedPrimaryIndex(userType)

	savedListingData = {
		title = GetGroupFinderUserTypeGroupListingTitle(userType),
		description = GetGroupFinderUserTypeGroupListingDescription(userType),
		category = GetGroupFinderUserTypeGroupListingCategory(userType),
		mode = selectedPrimaryIndex,
		targetInstance = selectedSecondaryIndex,
		groupSize = GetGroupFinderUserTypeGroupListingGroupSize(userType),
		playstyle = GetGroupFinderUserTypeGroupListingPlaystyle(userType),
		requiresChampion = DoesGroupFinderUserTypeGroupListingRequireChampion(userType),
		championPoints = GetGroupFinderCreateGroupListingChampionPoints(userType),
		requiresVOIP = DoesGroupFinderUserTypeGroupListingRequireVOIP(userType),
		requiresInviteCode = DoesGroupFinderUserTypeGroupListingRequireInviteCode(userType),
		inviteCode = GetGroupFinderUserTypeGroupListingInviteCode(userType),
		autoAccept = DoesGroupFinderUserTypeGroupListingAutoAcceptRequests(userType),
		enforceRoles = DoesGroupFinderUserTypeGroupListingEnforceRoles(userType),
		tankCount = GetGroupFinderUserTypeGroupListingDesiredRoleCount(userType, LFG_ROLE_TANK),
		healerCount = GetGroupFinderUserTypeGroupListingDesiredRoleCount(userType, LFG_ROLE_HEAL),
		dpsCount = GetGroupFinderUserTypeGroupListingDesiredRoleCount(userType, LFG_ROLE_DPS),
	}

end

function GF.RestoreSavedListing()
	if not savedListingData then
		GF.Popup("No saved Data!", nil, "FFA500")
		return
	end

	if GetActivityFinderStatus() == 1 then
		GF.Popup("Can't recreate while queued for activity!", nil, "FFA500")
		return
	end

	if HasGroupListingForUserType(GROUP_FINDER_GROUP_LISTING_USER_TYPE_CREATED_GROUP_LISTING) then
		GF.Popup("Listing already active!", nil, "FFA500")
		return
	end

	local ut = userType
	local data = savedListingData

	SetGroupFinderUserTypeGroupListingCategory(ut, data.category)
	SetGroupFinderUserTypeGroupListingPrimaryOption(ut, data.mode)
	SetGroupFinderUserTypeGroupListingSecondaryOption(ut, data.targetInstance)
	SetGroupFinderUserTypeGroupListingGroupSize(ut, data.groupSize)
	SetGroupFinderUserTypeGroupListingPlaystyle(ut, data.playstyle)
	SetGroupFinderUserTypeGroupListingRequiresChampion(ut, data.requiresChampion)
	SetGroupFinderUserTypeGroupListingChampionPoints(ut, data.championPoints)
	SetGroupFinderUserTypeGroupListingRequiresVOIP(ut, data.requiresVOIP)
	SetGroupFinderUserTypeGroupListingRequiresInviteCode(ut, data.requiresInviteCode)
	SetGroupFinderUserTypeGroupListingInviteCode(ut, data.inviteCode)
	SetGroupFinderUserTypeGroupListingAutoAcceptRequests(ut, data.autoAccept)
	SetGroupFinderUserTypeGroupListingEnforceRoles(ut, data.enforceRoles)
	SetGroupFinderUserTypeGroupListingRoleCount(ut, LFG_ROLE_TANK, data.tankCount)
	SetGroupFinderUserTypeGroupListingRoleCount(ut, LFG_ROLE_HEAL, data.healerCount)
	SetGroupFinderUserTypeGroupListingRoleCount(ut, LFG_ROLE_DPS, data.dpsCount)
	SetGroupFinderUserTypeGroupListingTitle(ut, data.title)
	SetGroupFinderUserTypeGroupListingDescription(ut, data.description)

	RequestCreateGroupListing()

	zo_callLater(function()
		SCENE_MANAGER:ShowBaseScene()
	end, 50)

	zo_callLater(function()
		local userTypeResult = GetCurrentGroupFinderUserType()
		if userTypeResult == 1 then
			GF.Popup("Listing restored!", nil, "00FF00")
		elseif userTypeResult == 0 then
			GF.Popup("BUGGED! Change zone to be able to recreate!", nil, "FF0000")
		end
	end, 500)
end

function GF.OnListingCreated(_, result)
	if result == GROUP_FINDER_ACTION_RESULT_SUCCESS then
		zo_callLater(function()
			  GF.SaveCurrentListing()
		end, 500)
	end
end

function GF.OnListingEdited()
	zo_callLater(function()
		  GF.SaveCurrentListing()
	end, 500)
end

function GroupFinderPlus_RecreateListing()
	GF.RestoreSavedListing()
end

function GF.Popup(msgText, sound, color)
	sound = sound or SOUNDS.ENDLESS_DUNGEON_BUFF_ACQUIRE_VERSE
	color = color or "FFFFFF"

	local msg = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
	msg:SetSound(sound)
	msg:SetText("|c" .. color .. msgText .. "|r")
	msg:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
	msg:MarkSuppressIconFrame()
	CENTER_SCREEN_ANNOUNCE:DisplayMessage(msg)
end

-- =========================================================
-- Events
-- =========================================================
EM:RegisterForEvent(GF.name .. "_UI", EVENT_ADD_ON_LOADED, function(_, addonName)
	if addonName ~= GF.name then return end
	EM:UnregisterForEvent(GF.name .. "_UI", EVENT_ADD_ON_LOADED)

	GF.InitializeColorPickers()
	GF.InitializeRecreateButtons()

	EM:RegisterForEvent(GF.name .. "_SaveListing", EVENT_GROUP_FINDER_CREATE_GROUP_LISTING_RESULT, GF.OnListingCreated)
	EM:RegisterForEvent(GF.name .. "_UpdateListing", EVENT_GROUP_FINDER_UPDATE_GROUP_LISTING_RESULT, GF.OnListingEdited)
end)
