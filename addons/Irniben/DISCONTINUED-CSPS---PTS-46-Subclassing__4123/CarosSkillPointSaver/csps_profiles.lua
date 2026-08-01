local GS = GetString
local cp = CSPS.cp

function CSPS.selectProfile(profileId)
	CSPS.currentProfile = profileId
	CSPSWindowBuildProfileRename:SetHidden(profileId == 0)
	CSPSWindowBuildProfileMinus:SetHidden(profileId == 0)
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


local function applyAll(excludeSkills, excludeAttributes, excludeGreenCP, excludeBlueCP, excludeRedCP, excludeHotbar, excludeGear, excludeQuickslots, excludeOutfit, excludeSkillStyles)
	
	if not excludeSkills then 
		if not excludeHotbar then 
			CSPS.applySkills(true, CSPS.hbApply, excludeSkillStyles)
		else
			CSPS.applySkills(true, nil, excludeSkillStyles) 
		end
	elseif not excludeHotbar then 
		CSPS.hbApply()
	end
	
	if not excludeAttributes then CSPS.applyAttr(true) end
	
	if not (excludeGreenCP and excludeBlueCP and excludeRedCP) then
		CSPS.toggleCP(1, not excludeGreenCP)
		CSPS.toggleCP(2, not excludeBlueCP)
		CSPS.toggleCP(3, not excludeRedCP)
		
		cp.applyGo(true)
	end
	
	if not excludeGear and CSPS.doGear then CSPS.equipAllFittingGear() end
	if CSPS.savedVariables.settings.showOutfits and not excludeOutfit then CSPS.outfits.apply() end
	
	if not excludeQuickslots then 
		CSPS.loadConnectedQuickSlots() 
		CSPS.applyQS()
	end
end

CSPS.applyAll = applyAll

function CSPS.btnApplyAll(mouseButton)
	if mouseButton == 2 then
		CSPS.openLAM()
		return
	end
	local toExclude = CSPS.savedVariables.settings.applyAllExclude
	applyAll(toExclude.skills, toExclude.attr, toExclude.cp, toExclude.cp, toExclude.cp, toExclude.hb, toExclude.gear, toExclude.qs, toExclude.outfit, toExclude.skillStyles)
end

function CSPS.showApplyAllTooltip(control)
	InitializeTooltip(InformationTooltip, control, LEFT)
	InformationTooltip:AddLine(GS(CSPS_BtnApplyAll) , "ZoFontWinH2")
	ZO_Tooltip_AddDivider(InformationTooltip)
	local toExclude = CSPS.savedVariables.settings.applyAllExclude
	local toExcludeTexts = {
		skills = GS(SI_CHARACTER_MENU_SKILLS), attr = GS(SI_CHARACTER_MENU_STATS), cp = GS(SI_STAT_GAMEPAD_CHAMPION_POINTS_LABEL), hb = GS(SI_INTERFACE_OPTIONS_ACTION_BAR), gear = GS(SI_GAMEPAD_DYEING_EQUIPMENT_HEADER), qs = GS(SI_HOTBARCATEGORY10), outfit = GetCollectibleCategoryNameByCategoryId(13),
	}
	local excludeOrder = {"skills", "attr", "cp", "hb"} -- last three entries inserted manually
	if CSPS.doGear then table.insert(excludeOrder, "gear") end
	table.insert(excludeOrder, "qs")
	if CSPS.savedVariables.settings.showOutfits then table.insert(excludeOrder, "outfit") end
	for i, v in pairs(excludeOrder) do
		local r,g,b = CSPS.colors.orange:UnpackRGB()
		if not toExclude[v] then			
			r,g,b = CSPS.colors.green:UnpackRGB()
		end
		InformationTooltip:AddLine(toExcludeTexts[v], "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
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