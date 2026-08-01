local GS = GetString
local cp = CSPS.cp
local hf = CSPS.helperFunctions

local applyAllCats = {
		{SI_CHARACTER_MENU_SKILLS, "skills"},
		{SI_COLLECTIBLECATEGORYTYPE30, "skillStyles"},
		{SI_CHARACTER_MENU_STATS, "attr"},
		{SI_STAT_GAMEPAD_CHAMPION_POINTS_LABEL, "cp"},
		{SI_INTERFACE_OPTIONS_ACTION_BAR, "hb"},
		{SI_GAMEPAD_DYEING_EQUIPMENT_HEADER, "gear"},
		{SI_HOTBARCATEGORY10, "qs"},
		{GetCollectibleCategoryNameByCategoryId(13), "outfit"},
		{SI_GROUP_LIST_PANEL_PREFERRED_ROLES_LABEL, "role"},
	}

function CSPS.getApplyAllCats()  return applyAllCats end

function CSPS.selectProfile(profileId, refreshName)
	CSPS.currentProfile = profileId
	CSPSWindowBuildProfileRename:SetHidden(profileId == 0)
	CSPSWindowBuildProfileMinus:SetHidden(profileId == 0)
	if not refreshName then return end
	CSPSWindowBuildProfiles.comboBox:SetSelectedItem(profileId == 0 and GS(CSPS_Txt_StandardProfile) or CSPS.profiles[profileId].name)
end

function CSPS.profilePlus()
	local newProfileId = 1
	while CSPS.profiles[newProfileId] ~= nil do
		newProfileId = newProfileId + 1
	end
	local profilEx = true
	local newProfileName = ""
	local j = newProfileId - 1
	while profilEx == true do
		j = j + 1
		newProfileName = GS(CSPS_Txt_NewProfile)..j
		profilEx = false
		for i,v in pairs(CSPS.profiles) do
			if v.name == newProfileName then profilEx = true end
		end
	end
	CSPS.profiles[newProfileId] = {name = newProfileName}
	CSPS.selectProfile(newProfileId)
	if CSPS.currentProfile ~= 0 then CSPS.saveBuildGo() end
	CSPS.UpdateProfileCombo()	
	return CSPS.profiles[newProfileId], CSPS.profiles, newProfileId
end

local function renameProfileGo(txt)
	for i, v in pairs(CSPS.profiles) do
		if v.name == txt then return end
	end
	CSPS.profiles[CSPS.currentProfile].name = txt
	CSPS.UpdateProfileCombo()
end

function CSPS.profileRename()
	if CSPS.currentProfile ~= 0 then
		local myWarning = not CSPS.savedVariables.settings.suppressSaveOther and (not CSPSWindowSubProfiles:IsHidden()) and GS(CSPS_MSG_NoCPProfiles) or ""
		
		local myName = CSPS.profiles[CSPS.currentProfile].name
		
		ZO_Dialogs_ShowDialog(CSPS.name.."_TextInputDiag", 
			{confirmFunc = function(txt) if not txt or txt == "" then return end renameProfileGo(txt) end},
			{mainTextParams = {zo_strformat(GS(CSPS_MSG_RenameProfile), myName, myWarning)}, initialEditText = myName})
	end
end


function CSPS.profileMinus()
	if CSPS.currentProfile ~= 0 then
		
		local myWarning = not CSPS.savedVariables.settings.suppressSaveOther and (not CSPSWindowSubProfiles:IsHidden()) and GS(CSPS_MSG_NoCPProfiles) or ""
		ZO_Dialogs_ShowDialog(CSPS.name.."_OkCancelDiag", 
			{returnFunc = function() CSPS.deleteProfileGo() end},  
			{mainTextParams = {zo_strformat(GS(CSPS_MSG_DeleteProfile), CSPS.profiles[CSPS.currentProfile].name, GS(CSPS_MSG_DeleteProfileStan), myWarning)}, titleParams = {GS(CSPS_MyWindowTitle)}})
	end
end

function CSPS.deleteProfileGo()
	CSPS.profiles[CSPS.currentProfile] = nil
	CSPS.selectProfile(0)
	CSPS.loadBuild()
	CSPS.UpdateProfileCombo()	
end


local function applyAll(excludeSkills, excludeAttributes, excludeGreenCP, excludeBlueCP, excludeRedCP, excludeHotbar, excludeGear, excludeQuickslots, excludeOutfit, excludeSkillStyles, excludeRole)
	
	local function afterSkills(skSuccess)
		local function afterAttributes()	
			if not (excludeGreenCP and excludeBlueCP and excludeRedCP) then
				CSPS.toggleCP(1, not excludeGreenCP)
				CSPS.toggleCP(2, not excludeBlueCP)
				CSPS.toggleCP(3, not excludeRedCP)
				
				cp.applyGo(true)
			end
			
			if not excludeGear and  not CSPS.moduleExclude.gear  then CSPS.equipAllFittingGear() end
			if not CSPS.savedVariables.settings.moduleExclude.outfit and not excludeOutfit then CSPS.outfits.apply() end
			
			if not excludeQuickslots then 
				CSPS.loadConnectedQuickSlots() 
				CSPS.applyQS()
			end
			
			if not excludeRole then CSPS.applyRole() end
		end
		if skSuccess and not excludeHotbar then 
			CSPS.hbApply()
		end
		
		if excludeAttributes then
			afterAttributes()
			return
		end
		
		SCENE_MANAGER:Show("hud")
		zo_callLater(function() CSPS.applyAttr(true, function() 
			SCENE_MANAGER:Show("hud") 
			zo_callLater(function() afterAttributes() end, 240)
		end) end, 420)
	end
	
	if excludeSkills then 
		afterSkills(true)
		return
	end
	
	CSPS.applySkills(true, function() afterSkills(true) end, function() afterSkills(false) end, excludeSkillStyles) -- skipDiag, callOnSuccess, callOnFail
end

CSPS.applyAll = applyAll

function CSPS.btnApplyAll(mouseButton)
	local toExclude = CSPS.savedVariables.settings.applyAllExclude
	if mouseButton == 2 then
		ClearMenu()
		for i, v in pairs(applyAllCats) do
			if not CSPS.moduleExclude[v[2]] then
				local index = AddCustomMenuItem(type(v[1]) == "string" and v[1] or GS(v[1]), function() 
					CSPS.savedVariables.settings.applyAllExclude[v[2]] = not CSPS.savedVariables.settings.applyAllExclude[v[2]]
				end, MENU_ADD_OPTION_CHECKBOX)
				if not CSPS.savedVariables.settings.applyAllExclude[v[2]] then
					ZO_CheckButton_SetChecked(ZO_Menu.items[index].checkbox)
				end
			end
		end
		AddCustomMenuItem("-", function() end)
		AddCustomMenuItem(GS(SI_APPLY), function() applyAll(toExclude.skills, toExclude.attr, toExclude.cp, toExclude.cp, toExclude.cp, toExclude.hb, toExclude.gear, toExclude.qs, toExclude.outfit, toExclude.skillStyles, toExclude.role) end)
		ShowMenu()
		return
	end
	applyAll(toExclude.skills, toExclude.attr, toExclude.cp, toExclude.cp, toExclude.cp, toExclude.hb, toExclude.gear, toExclude.qs, toExclude.outfit, toExclude.skillStyles, toExclude.role)
end

function CSPS.showApplyAllTooltip(control)
	InitializeTooltip(InformationTooltip, control, LEFT)
	InformationTooltip:AddLine(GS(CSPS_BtnApplyAll) , "ZoFontWinH2")
	ZO_Tooltip_AddDivider(InformationTooltip)
	local toExclude = CSPS.savedVariables.settings.applyAllExclude
	for i, v in pairs(applyAllCats) do
		if not CSPS.moduleExclude[v[2]] then
			hf.ttAddLine(type(v[1]) == "string" and v[1] or GS(v[1]), nil, toExclude[v[2]] and CSPS.colors.orange or CSPS.colors.green)
		end
	end
	ZO_Tooltip_AddDivider(InformationTooltip)
	InformationTooltip:AddLine(string.format("|t26:26:esoui/art/miscellaneous/icon_rmb.dds|t: %s", GS(SI_GAMEPAD_OPTIONS_MENU)))
end

function CSPS.loadAndApplyByName(profileName, excludeSkills, excludeAttributes, excludeGreenCP, excludeBlueCP, excludeRedCP, excludeHotbar, excludeGear, excludeQuickslots, excludeSkillStyles)
	local indexToLoad = false
	if profileName == GS(CSPS_Txt_StandardProfile) then
		indexToLoad = 0
	else
		for i,v in pairs(CSPS.profiles) do
			if v.name == profileName then indexToLoad = i break end
		end
	end
	if not indexToLoad then d("[CSPS] Profile not found.") return end
	CSPS.loadAndApplyByIndex(indexToLoad, excludeSkills, excludeAttributes, excludeGreenCP, excludeBlueCP, excludeRedCP, excludeHotbar, excludeGear, excludeQuickslots)
end


function CSPS.loadAndApplyByIndex(indexToLoad, excludeSkills, excludeAttributes, excludeGreenCP, excludeBlueCP, excludeRedCP, excludeHotbar, excludeGear, excludeQuickslots, excludeOutfit, excludeSkillStyles)
	if indexToLoad == 0 then
		CSPSWindowBuildProfiles.comboBox:SetSelectedItem(GS(CSPS_Txt_StandardProfile))
	else
		CSPSWindowBuildProfiles.comboBox:SetSelectedItem(CSPS.profiles[indexToLoad].name)
	end 
	CSPS.selectProfile(indexToLoad)
	CSPS.loadBuild()
	applyAll(excludeSkills, excludeAttributes, excludeGreenCP, excludeBlueCP, excludeRedCP, excludeHotbar, excludeGear, excludeQuickslots, excludeOutfit, excludeSkillStyles)
end


function CSPS.showProfileVersionHistory()
	if not CSPS.savedVariables.settings.versionHistory then return end
	local myProfile = CSPS.currentProfile == 0 and CSPS.currentCharData or CSPS.profiles[CSPS.currentProfile]
	if not myProfile.history or #myProfile.history == 0 then return end
	ClearMenu()
	for i, v in ipairs(myProfile.history)  do
		AddCustomMenuItem(string.format("%s) %s", i, os.date("%c", v.lastSaved)), function() 
			CSPS.loadBuild(false, v)
		end) 
	end
	ShowMenu() 
end
