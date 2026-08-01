local GS = GetString
local cspsPost = CSPS.post
local cspsD = CSPS.cspsD
local checkedT = "esoui/art/buttons/checkbox_checked.dds"
local uncheckedT = "esoui/art/buttons/checkbox_unchecked.dds"
local helpSections = {}
local helpOversections = {}
local impExpChoices = {}
local initOpen = false
local sm = SCENE_MANAGER
local wm = WINDOW_MANAGER
local cp = CSPS.cp
local cspsWindowFragment = false

local function initCSPSHelp()
	local helpOversectionsCtr = CSPSWindowHelpSection:GetNamedChild("Oversections")
	local ovBefore = 0
	for i=1, 42 do
		local myTitle = GS("CSPS_Help_Head", i)
		if myTitle == "" then break end
		local myText = GS("CSPS_Help_Sect", i)
		local myOversection = GS("CSPS_Help_Oversection", i)
		helpSections[i] = wm:CreateControlFromVirtual("CSPSWindowHelpSectionSection"..i, CSPSWindowHelpSection, "CSPSHelpSectionPres")
		local ctrBefore = helpOversectionsCtr
		if myOversection ~= "" then
			helpOversections[i] = wm:CreateControlFromVirtual("CSPSWindowHelpSectionOversection"..i, CSPSWindowHelpSectionOversections, "CSPSHelpOversectionPres")
			if i == 1 then
				helpOversections[i]:SetAnchor(TOPLEFT, helpOversectionsCtr, TOPLEFT, 0, 0)
				helpOversectionsCtr:SetWidth(100)
			else
				helpOversections[i]:SetAnchor(LEFT, helpOversections[ovBefore], RIGHT, 5, 0)
				helpOversectionsCtr:SetWidth(helpOversectionsCtr:GetWidth()+105)
			end
			helpOversections[i]:SetText(myOversection)
			helpOversections[i].myIndex = i
			ovBefore = i
		end
		if i > 1 and i ~= ovBefore then ctrBefore = helpSections[i-1] end
		helpSections[i]:SetAnchor(TOP, ctrBefore, BOTTOM, 0, 5)
		helpSections[i]:GetNamedChild("Btn"):SetText(myTitle)
		helpSections[i]:GetNamedChild("Btn").myIndex = i
		helpSections[i]:GetNamedChild("Btn"):SetHeight(0)
		helpSections[i]:GetNamedChild("Btn"):SetHidden(true)
		helpSections[i]:GetNamedChild("Lbl").auxText = myText
	end
end

function CSPS.showHelp()
	if #helpSections == 0 then initCSPSHelp() end
	CSPSWindowHelpSection:SetHidden(not CSPSWindowHelpSection:IsHidden())
end

function CSPS:InitLocalText()
	-- Loading localized text data
		
	ESO_Dialogs[CSPS.name.."_OkDiag"] = {
		canQueue = true,
		uniqueIdentifier = CSPS.name.."_OkDiag",
		title = {text = "<<1>>"},
		mainText = {text = "<<1>>"},
		buttons = {
			[1] = {
				text = SI_DIALOG_CONFIRM,
				callback =  function(dialog) if dialog.data.returnFunc then dialog.data.returnFunc() end CSPS.toggleMouse(true) end,
			},
		},
		setup = function() end,
	}
	ESO_Dialogs[CSPS.name.."_OkCancelDiag"] = {
		canQueue = true,
		uniqueIdentifier = CSPS.name.."_OkCancelDiag",
		title = {text = "<<1>>"},
		mainText = {text = "<<1>>"},
		buttons = {
			[1] = {
				text = SI_DIALOG_CONFIRM,
				callback =  function(dialog) dialog.data.returnFunc() CSPS.toggleMouse(true) end,
			},
			[2] = {
				text = SI_DIALOG_CANCEL,
				callback =  function(dialog) if dialog.data.cancelFunc then dialog.data.cancelFunc() end CSPS.toggleMouse(true) end,
			},
		},
		setup = function() end,
	}	
	ESO_Dialogs[CSPS.name.."_YesNoDiag"] = {
		canQueue = true,
		uniqueIdentifier = CSPS.name.."_YesNoDiag",
		title = {text = GS(CSPS_MyWindowTitle)},
		mainText = {text = "<<1>>"},
		buttons = {
			[1] = {
				text = SI_DIALOG_YES,
				callback = function(dialog) dialog.data.yesFunc() CSPS.toggleMouse(true) end,
			},
			[2] = {
				text = SI_DIALOG_NO,
				callback = function(dialog) dialog.data.noFunc() CSPS.toggleMouse(true) end,
			},
			},
		setup = function() end,
	}
	
	ESO_Dialogs[CSPS.name.."_TextInputDiag"] = {
		canQueue = true,
		uniqueIdentifier = CSPS.name.."_TextInputDiag",
		title = {text = GS(CSPS_MyWindowTitle)},
		mainText = {text = "<<C:1>>"}, --GS(CSPS_MSG_RenameProfile)
		editBox = {},
		buttons = {
			[1] = {
				text = SI_DIALOG_CONFIRM,
				callback = function(dialog)
					dialog.data.confirmFunc(ZO_Dialogs_GetEditBoxText(dialog))
					CSPS.toggleMouse(true)
				end,
			},
			[2] = {
				text = SI_DIALOG_CANCEL,
				callback = function() CSPS.toggleMouse(true) end,
			},
			},
		setup = function() end,
	}
	
	local cpButtons = {"CPProfileBlue", "CPProfileRed", "CPProfileGreen"}
	for i,v in pairs(cpButtons) do
		GetControl(CSPSWindowBuild, v):SetHandler("OnMouseEnter", 
			function(self) 
				ZO_Tooltips_ShowTextTooltip(self, RIGHT, 
					zo_strformat("<<C:1>> (<<C:2>>)\n|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t: <<3>>\n|t26:26:esoui/art/miscellaneous/icon_rmb.dds|t: <<4>>", 
					GS(CSPS_Tooltiptext_CPProfile), GetChampionDisciplineName(i), GS(CSPS_SubProfiles_Edit), GS(SI_GIFT_INVENTORY_VIEW_KEYBIND)))
			end)
	end
	
	CSPS.fillSrcCombo()
	CSPS.fillProfileCombo()
end


function CSPS.OnWindowMoveStop()
	CSPS.savedVariables.settings.left = CSPSWindow:GetLeft()
	CSPS.savedVariables.settings.top = CSPSWindow:GetTop()
	CSPS.toggleMouse(true)
end

function CSPS.OnWindowResizeStop()
	local theWidth = CSPSWindow:GetWidth()
	CSPS.savedVariables.settings.width = theWidth
	CSPS.savedVariables.settings.height = CSPSWindow:GetHeight()
	CSPS.savedVariables.settings.left = CSPSWindow:GetLeft()
	CSPS.savedVariables.settings.top = CSPSWindow:GetTop()
	if theWidth < 1000 then
		CSPSWindowMundusLabel:SetDimensionConstraints(0,0,theWidth-520,0)
	else
		CSPSWindowMundusLabel:SetDimensionConstraints(0,0,0,0)
	end
end

function CSPS:RestorePosition()
  local left = CSPS.savedVariables.settings.left
  local top = CSPS.savedVariables.settings.top
  CSPSWindow:ClearAnchors()
  CSPSWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  CSPSWindow:SetWidth(CSPS.savedVariables.settings.width or 605)
  CSPSWindow:SetHeight(CSPS.savedVariables.settings.height or 780)
  if CSPS.savedVariables.settings.hbleft == nil then return end
  local hbleft = CSPS.savedVariables.settings.hbleft
  local hbtop = CSPS.savedVariables.settings.hbtop
  CSPSCpHotbar:ClearAnchors()
  CSPSCpHotbar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, hbleft, hbtop)
end

local function changeButtonTextures(btnCtr, differentTextures, sameTextures)
	btnCtr:SetNormalTexture(sameTextures or differentTextures.."_up.dds")
	btnCtr:SetMouseOverTexture(sameTextures or differentTextures.."_over.dds")
	btnCtr:SetPressedTexture(sameTextures or differentTextures.."_down.dds")
end

local function setSubProfilesAnchor(showMe)
	if showMe then 
		CSPSWindowSubProfiles:SetAnchor(BOTTOMRIGHT, CSPSWindowSPPlaceholder, RIGHT, -7, 150)
	else 
		CSPSWindowSubProfiles:SetAnchor(BOTTOMRIGHT, CSPSWindowBuild, BOTTOMRIGHT, 0, 5)
	end
end

function CSPS.showElement(myElement, arg)
	local showFunctions = {
		modules = function()
			local hideCPCtr = CSPS.unlockedCP == false or CSPS.moduleExclude.cp or false
			
			CSPSWindowIncludeCPCheck1:SetHidden(hideCPCtr)
			CSPSWindowIncludeCPCheck2:SetHidden(hideCPCtr)
			CSPSWindowIncludeCPCheck3:SetHidden(hideCPCtr)
			CSPSWindowIncludeCPLabel:SetHidden(hideCPCtr)
			CSPSWindowBuildCPProfileGreen:SetHidden(hideCPCtr)
			CSPSWindowBuildCPProfileRed:SetHidden(hideCPCtr)
			CSPSWindowBuildCPProfileBlue:SetHidden(hideCPCtr)
			CSPSWindowIncludeBtnApplyCP:SetHidden(hideCPCtr)
			if hideCPCtr then 
				CSPSWindowBuildCPProfileGreen:SetWidth(0)
				CSPSWindowBuildCPProfileRed:SetWidth(0)
				CSPSWindowBuildCPProfileBlue:SetWidth(0)
				CSPSWindowIncludeBtnApplyCP:SetWidth(0)
			end
			
			CSPSWindowBuildOutfitProfiles:SetHidden(CSPS.moduleExclude.outfit)
			CSPSWindowBuildOutfitProfiles:SetWidth(CSPS.moduleExclude.outfit and 0 or 27)
			CSPSWindowManageBarsDiscsSpecialInclude9:SetHidden(CSPS.moduleExclude.outfit)
			
			CSPSWindowBuildQuickslotProfiles:SetHidden(CSPS.moduleExclude.qs)
			CSPSWindowBuildQuickslotProfiles:SetWidth(CSPS.moduleExclude.qs and 0 or 27)
			CSPSWindowManageBarsDiscsSpecialInclude8:SetHidden(CSPS.moduleExclude.qs)
			
			CSPSWindowBuildGearProfiles:SetHidden(CSPS.moduleExclude.gear)
			CSPSWindowBuildGearProfiles:SetWidth(CSPS.moduleExclude.gear and 0 or 27)
			CSPSWindowManageBarsDiscsSpecialInclude7:SetHidden(CSPS.moduleExclude.gear)
			
			CSPSWindowBuildSkillProfiles:SetHidden(CSPS.moduleExclude.skills)
			CSPSWindowBuildSkillProfiles:SetWidth(CSPS.moduleExclude.skills and 0 or 27)
			CSPSWindowManageBarsDiscsSpecialInclude1:SetHidden(CSPS.moduleExclude.skills)
			CSPSWindowManageBarsDiscsSpecialInclude6:SetHidden(CSPS.moduleExclude.skills)
			
			CSPSWindowManageBarsDiscsSpecialInclude2:SetHidden(CSPS.moduleExclude.attr)
			CSPSWindowManageBarsDiscsSpecialInclude10:SetHidden(CSPS.moduleExclude.role)
			
			if CSPS.moduleExclude.mundus then CSPSWindowMundus:SetWidth(0) CSPSWindowMundus:SetHidden(true) end
			if CSPS.moduleExclude.role then CSPSWindowRoleIcon:SetWidth(0) CSPSWindowRoleIcon:SetHidden(true) end
			
		end,
		cpsidebarlabels = function()
			if arg ~= nil then CSPS.savedVariables.settings.cpSideBarLabels = arg else CSPS.savedVariables.settings.cpSideBarLabels = not CSPS.savedVariables.settings.cpSideBarLabels end
			local cpBL = CSPS.savedVariables.settings.cpSideBarLabels
			local myCtrl = CSPSWindowCPSideBar
			local toggleButton = myCtrl:GetNamedChild("ToggleLabels")
			
			changeButtonTextures(toggleButton, cpBL == true and "esoui/art/buttons/large_rightarrow" or "esoui/art/buttons/large_leftarrow")
			myCtrl:SetWidth(cpBL == true and 242 or 38)
			toggleButton.tt = cpBL and GS(SI_SCREEN_ADJUST_SHRINK) or GS(SI_SCREEN_ADJUST_GROW)
			if arg == nil then ZO_Tooltips_ShowTextTooltip(toggleButton, RIGHT, toggleButton.tt) end
			for i=1, 3 do
				for j=1,4 do 
					myCtrl.slots[i][j].label:SetHidden(not cpBL)
				end
			end
		end,
		load = function()
			if arg ~= nil then CSPSWindowBuildLoad:SetHidden(not arg) return end
			if not CSPS.currentCharData or not CSPS.currentCharData.werte or not CSPS.currentCharData.werte.prog then
				CSPSWindowBuildLoad:SetHidden(true)
			else
				CSPSWindowBuildLoad:SetHidden(false)
			end
		end,
		save = function()
			if arg ~= nil then CSPSWindowBuildSave:SetHidden(not arg) end
		end,
		hotbar = function()
			CSPSWindowFooter:SetHidden(arg == false)
			CSPSWindowFooter:SetHeight(arg == false and 3 or 46)
		end,
		craftList = function()
			local showMe = arg == nil and CSPSWindowCraftList:IsHidden() or arg ~= nil and arg
			if showMe then CSPS.showCraftList() end
			CSPSWindowSubProfiles:SetHidden(true)
			CSPSWindowCPImport:SetHidden(true)
			CSPSWindowCraftList:SetHidden(not showMe)
			setSubProfilesAnchor(showMe)
		end,
		cpProfiles = function()
			local showMe = arg == nil and CSPSWindowCraftList:IsHidden() or arg ~= nil and arg
			CSPSWindowSubProfiles:SetHidden(not showMe)
			if (not CSPSWindowCPImport:IsHidden() and showMe == true) or not CSPSWindowSubProfiles:IsHidden() then
				CSPS.showElement("save", true)
				CSPS.unsavedChanges = true
			end
			CSPSWindowCPImport:SetHidden(true)
			CSPSWindowCraftList:SetHidden(true)
			setSubProfilesAnchor(showMe)
		end,
		cpImport = function()
			local showMe = arg == nil and CSPSWindowCraftList:IsHidden() or arg ~= nil and arg
			if not showMe then
				CSPS.showElement("save", true)
				CSPS.unsavedChanges = true
				CSPS.inCpRemapMode = false
				cpDisciToMap = nil
				cpSkillToMap = nil
			end
			CSPSWindowSubProfiles:SetHidden(true)
			CSPSWindowCraftList:SetHidden(true)
			CSPSWindowCPImport:SetHidden(not showMe)
			setSubProfilesAnchor(showMe)
		end
	}
	showFunctions[myElement]()
end

function CSPS.toggleOptional()
	--[[ClearMenu()
	
	AddCustomMenuItem(GS(CSPS_Manage_Connections), function() CSPS.toggleManageBars(true) end)
	local chkBoxIndex = AddCustomMenuItem(GS(CSPS_ShowHb), function() CSPS.toggleHotbar() end, MENU_ADD_OPTION_CHECKBOX)
	ZO_Menu.items[chkBoxIndex].checked = function()  return CSPS.showHotbar  end
	AddCustomMenuItem(GS(CSPS_Tooltiptext_Optional), function() CSPS.openLAM() end)
	
	ShowMenu()
	if true then return end]]--
	CSPSWindowOptions:SetHidden(not CSPSWindowOptions:IsHidden())
	if not CSPSWindowOptions:IsHidden() then EVENT_MANAGER:RegisterForEvent(CSPS.name, EVENT_GLOBAL_MOUSE_DOWN, CSPS.hideOptions) end
end

function CSPS.hideOptions()
	local control = wm:GetMouseOverControl()
	if control == CSPSWindowOptions or control:GetParent() == CSPSWindowOptions or control == CSPSWindowOptionalButton then return end
	CSPSWindowOptions:SetHidden(true)
	EVENT_MANAGER:UnregisterForEvent(CSPS.name, EVENT_GLOBAL_MOUSE_DOWN)
end

function CSPS.toggleCPCustomIcons()
	cp.useCustomIcons = CSPS.savedVariables.settings.useCustomIcons and not CSPS.moduleExclude.cp
	cp.updateSidebarIcons()
	
	if CSPS.savedVariables.settings.cpCustomBar and not CSPS.moduleExclude.cp then cp.refreshCustomBar() end
end 



function CSPS.registerFragment()
	cspsWindowFragment = cspsWindowFragment or ZO_SimpleSceneFragment:New(CSPSWindow)
	local settings = CSPS.savedVariables.settings
	for sceneName, doShow in pairs(settings.autoShowScenes) do
		if doShow then
			sm:GetScene(sceneName):AddFragment(cspsWindowFragment)
		else
			sm:GetScene(sceneName):RemoveFragment(cspsWindowFragment)
		end
	end
	
	local function openOnCombatEnd()
		if not IsUnitInCombat("player") then
			CSPSWindow:SetHidden(false)
		else
			EVENT_MANAGER:RegisterForEvent(CSPS.name.."_OnCombatEnd", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
				if not inCombat then
					CSPSWindow:SetHidden(false)
					EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_OnCombatEnd", EVENT_PLAYER_COMBAT_STATE)
				end
			end)
		end
	end
	
	if settings.openOnCPGain then
		EVENT_MANAGER:RegisterForEvent(CSPS.name.."_CP_Gain", EVENT_CHAMPION_POINT_GAINED, openOnCombatEnd)
	else
		EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_CP_Gain", EVENT_CHAMPION_POINT_GAINED)
	end
	if settings.openOnLevelUp then
		EVENT_MANAGER:RegisterForEvent(CSPS.name.."_LevelUp", EVENT_LEVEL_UPDATE, openOnCombatEnd)
		EVENT_MANAGER:AddFilterForEvent(CSPS.name.."_LevelUp", EVENT_LEVEL_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
	else
		EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_LevelUp", EVENT_LEVEL_UPDATE)
	end
end

function CSPS.toggleCPCustomBar()
	if CSPS.savedVariables.settings.cpCustomBar and not CSPS.moduleExclude.cp then 
		cp.rearrangeCustomBar()
		if CSPS.cpFragment == nil then CSPS.cpFragment = ZO_SimpleSceneFragment:New( CSPSCpHotbar ) end
		sm:GetScene('hud'):AddFragment( CSPS.cpFragment  )
		sm:GetScene('hudui'):AddFragment( CSPS.cpFragment  )
	elseif CSPS.cpFragment ~= nil then
		sm:GetScene('hud'):RemoveFragment( CSPS.cpFragment )
		sm:GetScene('hudui'):RemoveFragment( CSPS.cpFragment )	
	end
end 

function CSPS.toggleManageBars(arg)
	if CSPSWindowManageBars:IsHidden() or arg == nil or arg == true then
		CSPS.barManagerRefreshGroup()
		CSPSWindowImportExport:SetHidden(true)
		CSPSWindowOptions:SetHidden(true)
		CSPSWindowMain:SetHidden(true)
		CSPSWindowCpHbHkNumberList:SetHidden(true) 
		CSPSWindowManageBars:SetHidden(false)
		for i=1, 4 do
			CSPS.updatePrCombo(i)
		end
	else
		CSPSWindowImportExport:SetHidden(true)
		CSPSWindowOptions:SetHidden(true)
		CSPSWindowManageBars:SetHidden(true)
		CSPSWindowMain:SetHidden(false)
	end
end

function CSPS.toggleImportExport(arg)
	if CSPSWindowImportExport:IsHidden() or arg == nil or arg == true then
		CSPSWindowImportExport:SetHidden(false)
		CSPSWindowOptions:SetHidden(true)
		CSPSWindowManageBars:SetHidden(true)
		CSPSWindowMain:SetHidden(true)
	else
		CSPSWindowImportExport:SetHidden(true)
		CSPSWindowOptions:SetHidden(true)
		CSPSWindowManageBars:SetHidden(true)
		CSPSWindowMain:SetHidden(false)
	end
end

local function toggleCheckbox(ctrButton, arg)
	if type(ctrButton) == "string" then ctrButton = GetControl(CSPSWindow, ctrButton) end
	changeButtonTextures(ctrButton, nil, arg == true and checkedT or uncheckedT)
end

local function ieCtr(childName)
	return CSPSWindowImportExport:GetNamedChild(childName)
end

function CSPS.impExpAddInfo(myRace, myClass)
	local colors = CSPS.colors
		
	ieCtr("RaceValue"):SetText(myRace and zo_strformat("<<C:1>>", GetRaceName(GetUnitGender('player'), myRace)) or "-")
	ieCtr("RaceValue"):SetColor((myRace and (myRace == GetUnitRaceId('player') and colors.green or colors.orange) or colors.white):UnpackRGB())
	
	ieCtr("ClassValue"):SetText(myClass and zo_strformat("<<C:1>>", GetClassName(GetUnitGender('player'), myClass)) or "-")
	ieCtr("ClassValue"):SetColor((myClass and (myClass == GetUnitClassId('player') and colors.green or colors.orange) or colors.white):UnpackRGB())
end

function CSPS.helpSectionBtn(control)
	for i, v in pairs(helpSections) do
		local myButton = v:GetNamedChild("Btn")	
		local myLabel = v:GetNamedChild("Lbl")		
		if i == control.myIndex then
			local r,g,b = CSPS.colors.green:UnpackRGB()
			myButton:GetNamedChild("BG"):SetCenterColor(r,g,b, 0.4)
			myLabel:SetText(myLabel.auxText)
		else
			myButton:GetNamedChild("BG"):SetCenterColor(0.0314, 0.0314, 0.0314)
			myLabel:SetText("")
		end
	end
end

function CSPS.helpOversectionBtn(control)
	
	for i, v in pairs(helpOversections) do
		if i == control.myIndex then
			local r,g,b = CSPS.colors.green:UnpackRGB()
			v:GetNamedChild("BG"):SetCenterColor(r, g, b, 0.4)
		else
			v:GetNamedChild("BG"):SetCenterColor(0.0314, 0.0314, 0.0314)
		end
	end
	local isInSection = false
	for i, v in pairs(helpSections) do
		local myButton = v:GetNamedChild("Btn")	
		local myLabel = v:GetNamedChild("Lbl")
		if i == control.myIndex then
			isInSection = true
		elseif isInSection and helpOversections[i] ~= nil then
			isInSection = false
		end
		if isInSection then
			myButton:SetHeight(28)
			myButton:SetHidden(false)
		else
			myButton:SetHeight(0)
			myButton:SetHidden(true)
			myButton:GetNamedChild("BG"):SetCenterColor(0.0314, 0.0314, 0.0314)
			myLabel:SetText("")
		end
	end
	
end



function CSPS.fillProfileCombo()
	-- tooltip 
	CSPSWindowBuildProfiles.data = {tooltipText = GS(CSPS_Tooltiptext_ProfileCombo)}
	CSPSWindowBuildProfiles:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	CSPSWindowBuildProfiles:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

	CSPS.UpdateProfileCombo()
end

function CSPS.UpdateProfileCombo()
	CSPSWindowBuildProfiles.comboBox = CSPSWindowBuildProfiles.comboBox or ZO_ComboBox_ObjectFromContainer(CSPSWindowBuildProfiles)
	local myComboBox = CSPSWindowBuildProfiles.comboBox	
	myComboBox:SetHeight(610)
	myComboBox:ClearItems()
	myComboBox:SetSortsItems(false)
	
	-- d(os.date("%x", os.time()))
	local function OnItemSelect(choiceIndex)
		if CSPS.unsavedChanges == false then
			CSPS.selectProfile(choiceIndex)
			CSPS.loadBuild()
		else 
			local name1 = CSPS.profiles[CSPS.currentProfile] and CSPS.profiles[CSPS.currentProfile].name or GS(CSPS_Txt_StandardProfile)
			local name2 = choiceIndex > 0 and CSPS.profiles[choiceIndex].name or GS(CSPS_Txt_StandardProfile)
			local myWarning = not CSPS.savedVariables.settings.suppressSaveOther and  (not CSPSWindowSubProfiles:IsHidden()) and GS(CSPS_MSG_NoCPProfiles) or ""		
			ZO_Dialogs_ShowDialog(CSPS.name.."_OkCancelDiag", 
				{
					returnFunc = function() CSPS.selectProfile(choiceIndex) CSPS.loadBuild() end,
					cancelFunc = function() 
						local currentProfile = CSPS.currentProfile or 0
						if currentProfile == 0 then
							CSPSWindowBuildProfiles.comboBox:SetSelectedItem(GS(CSPS_Txt_StandardProfile))
						else
							CSPSWindowBuildProfiles.comboBox:SetSelectedItem(CSPS.profiles[currentProfile].name)
						end 
					end,
				},
				{
					mainTextParams = {zo_strformat(GS(CSPS_MSG__ChangeProfile), name1, name2, myWarning)}, 
					titleParams = {GS(CSPS_MyWindowTitle)}
				}
			)
		end
		PlaySound(SOUNDS.POSITIVE_CLICK)
	end
	
	local profileText = GS(CSPS_Txt_StandardProfile)
	profileText = CSPS.currentCharData.lastSaved and not CSPS.savedVariables.settings.suppressLastModified and string.format("%s (%s)", profileText, os.date("%x", CSPS.currentCharData.lastSaved)) or profileText
	
	local orderedProfiles = {}
	if CSPS.savedVariables.settings.standardOnTop then
		myComboBox:AddItem(myComboBox:CreateItemEntry(profileText, function() OnItemSelect(0) end))
	else
		table.insert(orderedProfiles, {lastModified = CSPS.currentCharData.lastSaved or 0, text = profileText, index=0})
	end
	
	for i, v in pairs(CSPS.profiles) do
		local profileText = v.name
		profileText = v.lastSaved and not CSPS.savedVariables.settings.suppressLastModified and string.format("%s (%s)", profileText, os.date("%x", v.lastSaved)) or profileText
		table.insert(orderedProfiles, {lastModified = v.lastSaved or 0, text = profileText, index=i})
	end
	
	local orderFunctions = {
		function(a,b) return a.text < b.text end,
		function(a,b) return a.text > b.text end,
		function(a,b) return a.lastModified > b.lastModified end,
		function(a,b) return a.lastModified < b.lastModified end,
	}
	
	table.sort(orderedProfiles, orderFunctions[CSPS.savedVariables.settings.profileOrder or 1])
	
	for i, v in pairs(orderedProfiles) do
		myComboBox:AddItem(myComboBox:CreateItemEntry(v.text, function() OnItemSelect(v.index) end))
	end
	
	myComboBox:SetSelectedItem(CSPS.currentProfile == 0 and GS(CSPS_Txt_StandardProfile) or CSPS.profiles[CSPS.currentProfile].name)
	
end


local function getLanguageName()
    local language = GetCVar("Language.2")
	local langNames = {
		--["en"] = SI_GUILDLANGUAGEATTRIBUTEVALUE1,
		["de"] = SI_GUILDLANGUAGEATTRIBUTEVALUE3,
		["fr"] = SI_GUILDLANGUAGEATTRIBUTEVALUE2,
		["sp"] = SI_GUILDLANGUAGEATTRIBUTEVALUE6,
		-- ["jp"] = SI_GUILDLANGUAGEATTRIBUTEVALUE4
		-- ["ru"] = SI_GUILDLANGUAGEATTRIBUTEVALUE5
  }
  return langNames[language] and GS(langNames[language])
end

function CSPS.toggleImpExpSource(myChoice, fromList)
	local oldTxtExports = {txtSk1 = true, txtSk2 = true, txtSk3 = true, txtOd = true}
	myChoice = oldTxtExports[myChoice] and "txtExport" or myChoice
	CSPS.savedVariables.settings.formatImpExp = myChoice
	if not fromList then 
		for i,v in pairs(impExpChoices) do
			if v == myChoice then ieCtr("SrcList").comboBox:SetSelectedItem(i) end
		end
	end
	
	local function hideShowImpExpControls(tableToShow)
		ieCtr("BtnImp1"):SetHidden(not tableToShow.btnImp)
		ieCtr("BtnExp1"):SetHidden(not tableToShow.btnExp)
		ieCtr("Text"):SetHidden(not tableToShow.txt)
		ieCtr("TxtScrollBar"):SetHidden(not tableToShow.txt)
		ieCtr("AddInfo"):SetHidden(not tableToShow.add)
		ieCtr("HandleCP"):SetHidden(not tableToShow.handleCP)
		ieCtr("SelectParts"):SetHidden(not tableToShow.selectParts)
		ieCtr("Transfer"):SetHidden(not tableToShow.transfer)
		ieCtr("CleanUpText"):SetHidden(not tableToShow.cleanUp)
		ieCtr("ChkLanguage"):SetHidden(not tableToShow.cpLang)
		ieCtr("LblLang"):SetHidden(not tableToShow.cpLang)
		ieCtr("BtnTextCPOrder1"):SetHidden(not tableToShow.cpOrd)
		ieCtr("BtnTextCPOrder2"):SetHidden(not tableToShow.cpOrd)
		ieCtr("BtnTextCPOrder3"):SetHidden(not tableToShow.cpOrd)
		ieCtr("OpenLink"):SetHidden(not tableToShow.link)
		ieCtr("LblReset"):SetHidden(not tableToShow.reset)
		ieCtr("SelectPartsChkReset"):SetHidden(not tableToShow.reset) 
		ieCtr("TextEdit"):SetText(tableToShow.txt or "")
		ieCtr("BtnImp1"):SetText(tableToShow.btnImp or "")
		ieCtr("BtnImp1").tooltip = tableToShow.btnImpTT or ""
		ieCtr("BtnExp1"):SetText(tableToShow.btnExp or "")
				
	end
	local choiceFunctions = {}
	if myChoice == "sf" then 
		hideShowImpExpControls({btnImp = GS(CSPS_ImpEx_BtnImpLink), btnImpTT = GS(CSPS_ImpEx_BtnImpTT), 
			txt = GS(CSPS_ImpEx_Standard), add = true})	
	elseif myChoice == "hub" then 
		hideShowImpExpControls({btnImp = GS(CSPS_ImpEx_BtnImpLink), btnImpTT = GS(CSPS_ImpEx_BtnImpTT), 
			txt = GS(CSPS_ImpEx_Standard), btnExp = GS(CSPS_ImpEx_BtnExpLink), add = true, reset = true, link = true})
	elseif myChoice == "csvCP" then
		hideShowImpExpControls({btnImp = GS(CSPS_ImpEx_BtnImpText), btnImpTT = GS(CSPS_ImpEx_BtnImpTT), handleCP = true, txt = ""})
	elseif myChoice == "csps" then
		hideShowImpExpControls({btnImp = GS(CSPS_ImpEx_BtnImpText), btnImpTT = GS(CSPS_ImpEx_BtnImpTT), btnExp = GS(CSPS_ImpEx_BtnExpText), selectParts = true, txt = ""})
	elseif string.sub(myChoice, 1, 6) == "txtCP2" then
		local cpLang = getLanguageName()
		hideShowImpExpControls({btnImp = GS(CSPS_ImpEx_BtnImpText), btnImpTT = GS(CSPS_ImpEx_BtnImpTTCP), 
			handleCP = true, txt = GS(CSPS_ImpEx_CpAsText), btnExp = GS(CSPS_ImpEx_BtnExpText),
			cpOrd = true, cpLang = cpLang, cleanUp = true})
		if cpLang then
			ieCtr("LblLang"):SetText(cpLang)
			ieCtr("ChkLanguage"):SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, RIGHT, string.format(GS(CSPS_ImpEx_LangTT), cpLang)) end)
		end
		CSPS.toggleCPReverseImport()
	elseif myChoice == "transfer" then
		hideShowImpExpControls({transfer = true})
		CSPS.updateTransferCombo(1)
	elseif myChoice == "ww" then
		hideShowImpExpControls({transfer = true})
		CSPS.updateTransferCombo(1, true)
	else
		hideShowImpExpControls({btnExp = GS(CSPS_ImpEx_BtnExpText), txt = ""})
	end
end

function CSPS.fillSrcCombo()
	local scrList = ieCtr("SrcList")
	scrList.comboBox = scrList.comboBox or ZO_ComboBox_ObjectFromContainer(scrList)
	local myComboBox = scrList.comboBox
	
	-- tooltip 
	scrList.data = {tooltipText = GS(CSPS_Tooltiptext_SrcCombo)}
	scrList:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	scrList:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	local choices = {
		["eso-hub.com"] = "hub",
		["eso-skillfactory.com"] = "sf",
		[GS(CSPS_ImpExp_TextSk)] = "txtExport",
		--[string.format("%s 2/3", GS(CSPS_ImpExp_TextSk))] = "txtSk2",
		--[string.format("%s 3/3", GS(CSPS_ImpExp_TextSk))] = "txtSk3",
		--[GS(CSPS_ImpExp_TextOd)] = "txtOd",
		[GS(CSPS_ImpExp_Transfer)] = not CSPS.moduleExclude.cp and "transfer" or nil,
		["Wizards Wardrobe Import"] = WizardsWardrobe and "ww" or nil,
		[GS(CSPS_ImpEx_CsvCP)] = "csvCP",
		[GS(CSPS_ImpEx_TxtCP2_1)] = not CSPS.moduleExclude.cp and "txtCP2_1" or nil,
		[GS(CSPS_ImpEx_TxtCP2_2)] = not CSPS.moduleExclude.cp and "txtCP2_2" or nil,
		[GS(CSPS_ImpEx_TxtCP2_3)] = not CSPS.moduleExclude.cp and "txtCP2_3" or nil,
		["CSPS"] = "csps",
	}
	
	impExpChoices = choices

	local function OnItemSelect(_, choiceText, choice)
		CSPS.toggleImpExpSource(choices[choiceText], true)
		PlaySound(SOUNDS.POSITIVE_CLICK)
	end

	myComboBox:SetSortsItems(true)
	
	for i,v in pairs(choices) do
		myComboBox:AddItem(myComboBox:CreateItemEntry(i, OnItemSelect))
		if CSPS.savedVariables.settings.formatImpExp == v then
			myComboBox:SetSelectedItem(i)
		end
	end
end

local function toggleChkTexture(ctrButton, value)
	ctrButton:SetTexture(value and checkedT or uncheckedT)
end

CSPS.toggleChkTexture = toggleChkTexture

function CSPS.toggleCP(disciplineIndex, arg)
	if type(disciplineIndex) == "table" then
		CSPS.applyCPc = disciplineIndex
	elseif disciplineIndex == 0 or disciplineIndex == nil then
		if arg ~= nil then CSPS.applyCP = arg else CSPS.applyCP = not CSPS.applyCP end
		CSPS.applyCPc = {CSPS.applyCP, CSPS.applyCP, CSPS.applyCP}
	else
		CSPS.applyCP = false
		if arg ~= nil then CSPS.applyCPc[disciplineIndex] = arg else CSPS.applyCPc[disciplineIndex] = not CSPS.applyCPc[disciplineIndex] end
	end
	if CSPS.applyCPc[1] or CSPS.applyCPc[2] or CSPS.applyCPc[3] then CSPS.applyCP = true end
	for i=1,3 do 
		toggleChkTexture(CSPSWindowInclude:GetNamedChild("CPCheck"..i), CSPS.applyCPc[i])
	end
	CSPS.savedVariables.settings.applyCP = CSPS.applyCP
	CSPS.savedVariables.settings.applyCPc = CSPS.applyCPc
	 CSPS.refreshTree()
end

function CSPS.toggleCPImportLanguage(arg)
	if arg ~= nil then CSPS.cpImportLang = arg else CSPS.cpImportLang = not CSPS.cpImportLang end
	if not getLanguageName() then CSPS.cpImportLang = false end
	toggleCheckbox("ImportExportChkLanguage", CSPS.cpImportLang)
	CSPS.savedVariables.settings.cpImportLang = CSPS.cpImportLang
end

function CSPS.toggleCPImpExpParts(arg)
	local partTable = CSPS.savedVariables.settings.importExportParts
	if arg then partTable[arg] = not partTable[arg] end
	local partControls = {
		skills = "ChkSkills",
		hotbar = "ChkSkillBar",
		attributes = "ChkAttributes",
		mundus = "ChkMundus",
		cp = "ChkCp",
		gear = "ChkGear",
		quickslots = "ChkQuickSlots",
		outfit = "ChkOutfit",
		reset = "ChkReset",
	}
	for i, v in pairs(partTable) do
		toggleCheckbox(string.format("ImportExportSelectParts%s", partControls[i]), v)
	end
end

function CSPS.toggleCPCapImport(arg)
	if arg ~= nil then CSPS.cpImportCap = arg else CSPS.cpImportCap = not CSPS.cpImportCap end
	toggleCheckbox("ImportExportChkCap", CSPS.cpImportCap)
	CSPS.savedVariables.settings.cpImportCap = CSPS.cpImportCap
end

function CSPS.toggleStrictOrder(arg)
	if arg ~= nil then CSPS.savedVariables.settings.strictOrder = arg else CSPS.savedVariables.settings.strictOrder = not CSPS.savedVariables.settings.strictOrder end
	toggleCheckbox("SubProfilesChkStrictOrder", CSPS.savedVariables.settings.strictOrder)
end

function CSPS.toggleMouse(arg)
	local myScene = sm.currentScene and sm.currentScene:GetName()
	if myScene ~= "hud" and myScene ~= "hudui" then return end
	if arg then
		if not sm:IsInUIMode() then
			sm:SetInUIMode(true)
		end
	else
		if sm:IsInUIMode() then
			sm:SetInUIMode(false)
		end
	end
end

function CSPS.toggleCPReverseImport(arg)
	if arg ~= nil then 
		if arg == false then arg = 1 elseif arg == true then arg = 2 end
		CSPS.cpImportReverse = arg
	end
	local thisDisci = 1
	if string.sub(CSPS.savedVariables.settings.formatImpExp, 1,6) == "txtCP2" then 
		thisDisci = tonumber(string.sub(CSPS.savedVariables.settings.formatImpExp, 8))
	end
	local myColor = CSPS.cpColors[thisDisci]
	for i=1, 3 do
		local myControl = CSPSWindow:GetNamedChild(string.format("ImportExportBtnTextCPOrder%s", i))
		local myBG = myControl:GetNamedChild("BG")
		if i == CSPS.cpImportReverse then
			local r,g,b = CSPS.colors.green:UnpackRGB()
			myBG:SetCenterColor(r,g,b, 0.4)
		else
			myBG:SetCenterColor(1, 1, 1, 0.4)
		end
	end
	CSPS.savedVariables.settings.cpImportReverse = CSPS.cpImportReverse
end

function CSPS.openKeybindSettings()
  local function openKeybindSettings()
    local kbMenu = ZO_GameMenu_InGame.gameMenu and ZO_GameMenu_InGame.gameMenu.headerControls[GetString(SI_GAME_MENU_CONTROLS)]
    if not kbMenu then return end
    for _, nodeControl in ipairs(kbMenu:GetChildren()) do
      local data = nodeControl:GetData()
      if data and data.name == GetString(SI_GAME_MENU_KEYBINDINGS) then
		nodeControl:GetTree():SelectNode(nodeControl)
		local ctrKbList = KEYBINDING_MANAGER.list.list
		for _, entry in pairs(ZO_ScrollList_GetDataList(ctrKbList)) do
		  if type(entry) == "table" and type(entry.data) == "table" and entry.data.categoryName == "|c9e0911Caro's|r Skill Point Saver" then
			ZO_ScrollList_ScrollRelative(ctrKbList, entry.data.dataEntry.top - ctrKbList.scrollbar:GetValue(), nil, true)
			return
		  end
		end
		return	
      end
    end
  end
  if sm:GetScene("gameMenuInGame"):GetState() == SCENE_SHOWN then
    openKeybindSettings()
  else
    sm:CallWhen("gameMenuInGame", SCENE_SHOWN, openKeybindSettings)  -- CallWhen: callback once then delete callback entry
    sm:Show("gameMenuInGame")
  end
end

function CSPS.setupImportExportTextEdit()
	local ctrText = CSPSWindowImportExportText
	local ctrEdit = GetControl(ctrText, "Edit")
	local ctrScroll = CSPSWindowImportExportTxtScrollBar
	ctrEdit:SetMaxInputChars(3000)
	
	local scrollExtents = 0
	local topLineIndex = 0
	
	local function updateLine()
		topLineIndex = ctrEdit:GetTopLineIndex()
		ctrScroll:SetValue(topLineIndex)
	end
	local function updateExtents()
		scrollExtents = ctrEdit:GetScrollExtents()
		if scrollExtents == 0 then ctrScroll:SetValue(1) ctrScroll:SetEnabled(false) return end
		ctrScroll:SetEnabled(true)
		ctrScroll:SetValueStep(1)
		ctrScroll:SetMinMax(1, scrollExtents)
		ctrScroll:SetThumbTextureHeight(ctrScroll:GetHeight()/scrollExtents)
		updateLine()
	end

	updateExtents()
	
	local function refreshTxtScroll()
		if scrollExtents ~= ctrEdit:GetScrollExtents() then updateExtents() return end 
		if topLineIndex ~= ctrEdit:GetTopLineIndex() then updateLine() end
	end
	
	ctrEdit:SetHandler("OnEffectivelyShown",  function() EVENT_MANAGER:RegisterForUpdate("CSPS_RefreshTextEditScroll", 100, refreshTxtScroll) end)
	ctrEdit:SetHandler("OnEffectivelyHidden", function() EVENT_MANAGER:UnregisterForUpdate("CSPS_RefreshTextEditScroll") end)
	
	ctrScroll:SetHandler("OnMouseWheel", function(_, delta) ctrEdit:SetTopLineIndex(topLineIndex - delta) end)
	ctrScroll:SetHandler("OnValueChanged", function(_, value, eventReason)	if eventReason == EVENT_REASON_SOFTWARE then return end	ctrEdit:SetTopLineIndex(value) end)
	
	local btnUp = GetControl(ctrScroll, "Up")
	local btnDown = GetControl(ctrScroll, "Down")
	
	local function moveUp() if topLineIndex > 1 then ctrEdit:SetTopLineIndex(topLineIndex - 1) end end
	local function moveDown() if topLineIndex < scrollExtents + 1 then ctrEdit:SetTopLineIndex(topLineIndex + 1) end end
	btnUp:SetHandler("OnMouseDown", function() moveUp() EVENT_MANAGER:RegisterForUpdate("CSPS_MoveTextUp", 500, moveUp) end)
	btnUp:SetHandler("OnMouseUp", function() EVENT_MANAGER:UnregisterForUpdate("CSPS_MoveTextUp") end)
	
	btnDown:SetHandler("OnMouseDown", function() moveDown() EVENT_MANAGER:RegisterForUpdate("CSPS_MoveTextDown", 500, moveDown) end)
	btnDown:SetHandler("OnMouseUp", function() EVENT_MANAGER:UnregisterForUpdate("CSPS_MoveTextDown") end)
	
end

function CSPS.OnWindowShow()
	CSPS.showElement("load") -- Show, if theres data to load
	
	if not initOpen then
		CSPS.initCPSideBar()
		CSPS.showBuild(true) -- boolean to prevent from setting unsaved-changes to true
		initOpen = true
		CSPS.setTransparencyBG()
		CSPS.setTransparencyWin()
		if CSPS.savedVariables.settings.keepLastBuild and CSPS.currentCharData.auxProfile then
			CSPS.loadBuild(true)
			local profileIndex =  CSPS.currentCharData.auxProfile.profileIndex
			if profileIndex and (profileIndex == 0 or CSPS.profiles[profileIndex]) then 
				CSPS.selectProfile(profileIndex) 
				CSPSWindowBuildProfiles.comboBox = CSPSWindowBuildProfiles.comboBox or ZO_ComboBox_ObjectFromContainer(CSPSWindowBuildProfiles)
				local myComboBox = CSPSWindowBuildProfiles.comboBox	
				if profileIndex ~= 0 then 
					myComboBox:SetSelectedItem(CSPS.profiles[profileIndex].name)
				else
					myComboBox:SetSelectedItem(GS(CSPS_Txt_StandardProfile))
				end
			end
		end
	end

	CSPS.toggleMouse(true)
	
	CSPS.refreshTree()
	if not CSPS.moduleExclude.gear or not CSPS.moduleExclude.qs then	
		local waitingForGearChange = false
		EVENT_MANAGER:RegisterForEvent(CSPS.name.."GearChange", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 
			function(_, bagId) 
				if waitingForGearChange then return end
				waitingForGearChange = true
				zo_callLater(function() waitingForGearChange = false CSPS.refreshTree() end, 420)
			end)
		EVENT_MANAGER:RegisterForEvent(CSPS.name.."OpenBank", EVENT_OPEN_BANK, function(_, bagId) if bagId == BAG_BANK then CSPS.refreshTree() end end)
	end
end

function CSPS.OnWindowHide()
	CSPS.checkCpOnClose()
	CSPS.toggleMouse(true)
	if CSPS.savedVariables.settings.keepLastBuild then CSPS.saveBuildGo(true) end
	EVENT_MANAGER:UnregisterForEvent(CSPS.name.."GearChange", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	EVENT_MANAGER:UnregisterForEvent(CSPS.name.."OpenBank", EVENT_OPEN_BANK)
end

function CSPS.setTransparencyBG(value)
	CSPS.savedVariables.settings.bgalpha = value or CSPS.savedVariables.settings.bgalpha or 1
	value = CSPS.savedVariables.settings.bgalpha
	CSPSWindowBG:SetAlpha(value)
	CSPSWindowCPSideBarBG:SetAlpha(value)
	CSPSWindowSubProfilesBG:SetCenterColor(0,0,0,0)
end

function CSPS.setTransparencyWin(value)
	CSPS.savedVariables.settings.winalpha = value or CSPS.savedVariables.settings.winalpha or 1
	CSPSWindow:SetAlpha(CSPS.savedVariables.settings.winalpha)
end
