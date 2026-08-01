local namespace = "StudsGroupFinderTweaks"

local overviewPageRelistButton, searchPageRelistButton, savedListing, hasTrialFilterDefaultBeenSet, savedVariables, accountWideSavedVariables, characterSavedVariables
local roleMismatchWarnings = {}
local listing = GROUP_FINDER_KEYBOARD.createGroupListingContent

local function getCurrentRoleCounts()
	local currentRoleCounts = { [LFG_ROLE_TANK] = 0, [LFG_ROLE_HEAL] = 0, [LFG_ROLE_DPS] = 0, [LFG_ROLE_INVALID] = 0 }
	for i = 1, 12 do
		local unitTag = GetGroupUnitTagByIndex(i)
		if unitTag then 
			local role = GetGroupMemberSelectedRole(unitTag)
			currentRoleCounts[role] = currentRoleCounts[role] + 1
		end
	end
	return currentRoleCounts
end

local function updateRoleMismatchWarning(currentRoleCounts)
	local isInGroup = GetGroupSize() > 0
	for roleType, warning in pairs(roleMismatchWarnings) do
		local serverRoleCount = listing.userTypeData:GetAttainedRoleCountAtEdit(roleType)
		if isInGroup and serverRoleCount > currentRoleCounts[roleType] then
			warning:SetHidden(false)
		else
			warning:SetHidden(true)
		end
    end
end

-- if more of a role joined since last listing, spinner max can go too high
local function fixRoleCounts(currentRoleCounts)
	-- it's usually supports that matter, so attempt to take away dps or just reset if too many
	local overCount = 0
	if savedListing.tankCount < currentRoleCounts[LFG_ROLE_TANK] then 
		overCount = overCount + (currentRoleCounts[LFG_ROLE_TANK] - savedListing.tankCount)
		savedListing.tankCount = currentRoleCounts[LFG_ROLE_TANK]
	end
	if savedListing.healerCount < currentRoleCounts[LFG_ROLE_HEAL] then 
		overCount = overCount + (currentRoleCounts[LFG_ROLE_HEAL] - savedListing.healerCount)
		savedListing.healerCount = currentRoleCounts[LFG_ROLE_HEAL]
	end

	if overCount > 0 then
		if savedListing.dpsCount - currentRoleCounts[LFG_ROLE_DPS] >= overCount then
			savedListing.dpsCount = savedListing.dpsCount - overCount
		else
			savedListing.tankCount, savedListing.healerCount, savedListing.dpsCount = 0, 0, 0 -- let the server min/max limits handle it since they can bug and conflict anyways
		end
	end
end
	
local function onRecreateClicked()
	GROUP_FINDER_KEYBOARD:SetMode(ZO_GROUP_FINDER_MODES.CREATE_EDIT)
	listing.categoryDropdown:SetSelected(savedListing.categoryIndex)
	listing.groupTitleEditControl:SetText(savedListing.title)
	listing.descriptionEditControl:SetText(savedListing.description)
	if savedListing.categoryIndex < 4 then -- dungeon/arena/trial
		listing.difficultyRadioButtonGroup:SetClickedButton(savedListing.selectedDifficultyControl)
	else
		listing.primaryOptionDropdown:SetSelected(savedListing.primaryDropdownIndex)
	end
	listing.secondaryOptionDropdown:SetSelected(savedListing.secondaryDropdownIndex)
	listing.sizeDropdown:SetSelected(savedListing.sizeDropdownIndex)
	listing.playstyleDropdown:SetSelected(savedListing.playstyleDropdownIndex)
	listing.userTypeData:SetGroupRequiresChampion(savedListing.requiresChampionPoints)
	listing.userTypeData:SetChampionPoints(savedListing.championPoints)
	listing.userTypeData:SetGroupRequiresVOIP(savedListing.requiresVoice)
	listing.userTypeData:SetGroupRequiresInviteCode(savedListing.requiresInviteCode)
	listing.userTypeData:SetInviteCode(savedListing.inviteCode)
	listing.userTypeData:SetGroupAutoAcceptRequests(savedListing.autoAccept)
	listing.userTypeData:SetGroupEnforceRoles(savedListing.enforceRoles)
	
	local currentRoleCounts = getCurrentRoleCounts()
	if savedVariables.roleMismatchWarnings then updateRoleMismatchWarning(currentRoleCounts) end
	fixRoleCounts(currentRoleCounts)
	listing.userTypeData:SetDesiredRoleCount(LFG_ROLE_TANK, savedListing.tankCount)
	listing.userTypeData:SetDesiredRoleCount(LFG_ROLE_HEAL, savedListing.healerCount)
	listing.userTypeData:SetDesiredRoleCount(LFG_ROLE_DPS, savedListing.dpsCount)
	
	listing:UpdateUserType()
	listing:Refresh()
end

local function setupButtons(parentName)
	local parent = WINDOW_MANAGER:GetControlByName(parentName)
	if (not parent) then return end
	
	local createButton = parent:GetNamedChild("CreateGroupButton")
	if (not createButton) then return end
	
	if savedVariables.roleMismatchWarnings then
		createButton:SetHandler("OnMouseDown", function()
			GROUP_FINDER_KEYBOARD:SetMode(ZO_GROUP_FINDER_MODES.CREATE_EDIT)
			updateRoleMismatchWarning(getCurrentRoleCounts()) 
		end)
	end
	
	createButton:ClearAnchors()
	createButton:SetAnchor(BOTTOMRIGHT, parent, BOTTOM)
	
	local recreateButton = CreateControlFromVirtual(parentName .. "RecreateListingButton", parent, "ZO_DefaultButton")
	recreateButton:SetEnabled(false)
	recreateButton:SetText("Recreate Listing")
	recreateButton:SetWidth(200)
	recreateButton:SetParent(parent)
	recreateButton:SetAnchor(LEFT, createButton, RIGHT)
	recreateButton:SetHandler("OnMouseDown", onRecreateClicked)
	return recreateButton
end


local function setupRoleMismatchWarnings()
	local parent = "ZO_GroupFinder_CreateGroupListingContent_KeyboardContentRoleContainer"
	local warningText = "This group is bugged, server thinks there are extra members of this role in group. Try editing roles after creating, ask people to fake roles and change back after creating, or ask someone else to create the listing"
	for roleType, roleText in pairs({[LFG_ROLE_TANK] = "Tank", [LFG_ROLE_HEAL] = "Heal", [LFG_ROLE_DPS] = "DPS"}) do
		local warning = CreateControl("RoleMismatchWarning" .. roleText, listing.roleContainerControl, CT_TEXTURE)
		warning:SetTexture("/esoui/art/miscellaneous/eso_icon_warning.dds")
		warning:SetResizeToFitFile(true)
		warning:SetAnchor(LEFT, listing.roleSpinnerTable[roleType] , RIGHT)
		warning:SetMouseEnabled(true)
		warning:SetHandler("OnMouseEnter", function()
			InitializeTooltip(InformationTooltip, warning, BOTTOMLEFT, 0, 0, TOPLEFT)
            SetTooltipText(InformationTooltip, ZO_ERROR_COLOR:Colorize(warningText))
		end)
		warning:SetHandler("OnMouseExit", function()
			ClearTooltip(InformationTooltip)
		end)
		warning:SetHidden(true)
		roleMismatchWarnings[roleType] = warning
	end
end

local function setupAddonMenu()
	local LAM = LibAddonMenu2
	
	characterSavedVariables = ZO_SavedVars:NewCharacterIdSettings(namespace .. "Vars", 1, nil, {
		accountWide = true,
		roleFilterDisable = true,
		roleMismatchWarnings = true
	})
	accountWideSavedVariables = ZO_SavedVars:NewAccountWide(namespace .. "Vars", 1, nil, {
		accountWide = true,
		roleFilterDisable = true,
		roleMismatchWarnings = true
	})
	if characterSavedVariables.accountWide then savedVariables = accountWideSavedVariables
	else savedVariables = characterSavedVariables end
	
	local function syncToAccountWide()
		characterSavedVariables.accountWide = true
		accountWideSavedVariables.roleFilterDisable = savedVariables.roleFilterDisable
		accountWideSavedVariables.roleMismatchWarnings = savedVariables.roleMismatchWarnings
		savedVariables = accountWideSavedVariables
	end
	local function syncToCharacter()
		characterSavedVariables.accountWide = false
		characterSavedVariables.roleFilterDisable = savedVariables.roleFilterDisable
		characterSavedVariables.roleMismatchWarnings = savedVariables.roleMismatchWarnings
		savedVariables = characterSavedVariables
	end
	
	local panelConfig = {
		type = "panel",
		name = "Stud's Group Finder Tweaks",
		author = "@STUDLETON",
		version = "1.0.0"
	}
	
	local optionsConfig = {
		{
			type = "description",
			text = "Changes made while Accountwide is enabled will affect the saved accountwide settings. Enabling will sync this character's settings to the accountwide settings.",
		},
		{
			type = "checkbox",
			name = "Accountwide",
			tooltip = "Turn off if you want this character to have it's own settings.",
			getFunc = function () return characterSavedVariables.accountWide end,
			setFunc = function (value) if value then syncToAccountWide() else syncToCharacter() end end,
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = "Auto role filter disable",
			tooltip = "On means filter will be disabled on first trial search. Off means game default, filter stays enabled.",
			getFunc = function () return savedVariables.roleFilterDisable end,
			setFunc = function (value) savedVariables.roleFilterDisable = value end,
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = "Show group role bug warning",
			tooltip = "Shows warnings next to role spinners if a server bug is detected",
			getFunc = function () return savedVariables.roleMismatchWarnings end,
			setFunc = function (value) savedVariables.roleMismatchWarnings = value end,
			requiresReload = true,
		},
	}
	
	local panel = LAM:RegisterAddonPanel(namespace, panelConfig)
	LAM:RegisterOptionControls(namespace, optionsConfig)
end

EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ADD_ON_LOADED, function(_, addonName)
	if addonName ~= namespace then return end
	EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_ADD_ON_LOADED)
	setupAddonMenu()
	
	overviewPageRelistButton = setupButtons("ZO_GroupFinder_Keyboard_TopLevelOverview")
	searchPageRelistButton = setupButtons("ZO_GroupFinder_Keyboard_TopLevelSearchPanel")
	
	if savedVariables.roleMismatchWarnings then setupRoleMismatchWarnings() end
	
	if savedVariables.roleFilterDisable then
		EVENT_MANAGER:RegisterForEvent(namespace, EVENT_GROUP_FINDER_SEARCH_COMPLETE, function()
			if (GetGroupFinderFilterCategory() ~= GROUP_FINDER_CATEGORY_TRIAL) then return end
			if (DoesGroupFinderFilterRequireEnforceRoles()) then 
				SetGroupFinderFilterEnforceRoles(false)
				GROUP_FINDER_KEYBOARD:RefreshCurrentRoleLabel()
				GROUP_FINDER_KEYBOARD:ExecuteSearchForCategory(GROUP_FINDER_CATEGORY_TRIAL)
			end
			EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_GROUP_FINDER_SEARCH_COMPLETE)
		end)
	end
	
	EVENT_MANAGER:RegisterForEvent(namespace, EVENT_GROUP_FINDER_CREATE_GROUP_LISTING_RESULT, function() -- does this fire if not group lead...?
		if not savedListing then
			if overviewPageRelistButton then overviewPageRelistButton:SetEnabled(true) end
			if searchPageRelistButton then searchPageRelistButton:SetEnabled(true) end
		end
		savedListing = {
			title = listing.groupTitleEditControl:GetText(),
			description = listing.descriptionEditControl:GetText(),
			categoryIndex = listing.categoryDropdown:GetSelectedItemData().value+1, -- values start at 0 here
			selectedDifficultyControl = listing.difficultyRadioButtonGroup:GetClickedButton(),
			primaryDropdownIndex = listing.primaryOptionDropdown:GetSelectedItemData().value,
			secondaryDropdownIndex = listing.secondaryOptionDropdown:GetSelectedItemData().value,
			sizeDropdownIndex = listing.sizeDropdown:GetSelectedItemData().value, 
			playstyleDropdownIndex = listing.playstyleDropdown:GetSelectedItemData().value,
			requiresChampionPoints = listing.userTypeData:DoesGroupRequireChampion(),
			championPoints = listing.userTypeData:GetChampionPoints(),
			requiresVoice = listing.userTypeData:DoesGroupRequireVOIP(),
			requiresInviteCode = listing.userTypeData:DoesGroupRequireInviteCode(),
			inviteCode = listing.userTypeData:GetInviteCode(),
			autoAccept = listing.userTypeData:DoesGroupAutoAcceptRequests(),
			enforceRoles = listing.userTypeData:DoesGroupEnforceRoles(),
			tankCount = listing.userTypeData:GetDesiredRoleCount(LFG_ROLE_TANK),
			healerCount = listing.userTypeData:GetDesiredRoleCount(LFG_ROLE_HEAL),
			dpsCount = listing.userTypeData:GetDesiredRoleCount(LFG_ROLE_DPS)
		}
	end)
	
	GROUP_FINDER_KEYBOARD_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWING then
			local canRelist = (savedListing ~= nil) and ZO_GroupFinder_CanDoCreateEdit()
			overviewPageRelistButton:SetEnabled(canRelist)
			searchPageRelistButton:SetEnabled(canRelist)
		end
	end)
end)
