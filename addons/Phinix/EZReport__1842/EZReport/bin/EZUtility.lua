local EZReport = _G['EZReport']
local L = EZReport:GetLanguage()
local pTC = EZReport.TColor
local pRN = EZReport.Round
local pR2 = EZReport.RGB2Hex
local pDT = EZReport.GetDateTime

local lastReason = 0
local rManual = 0
local lastTarget
local reportName

------------------------------------------------------------------------------------------------------------------------------------
-- Variables and containers
------------------------------------------------------------------------------------------------------------------------------------
local mTexture = { -- show different icon/colors on reported target frame based on last reason reported
		[0] = {texture = "EZReport/bin/report_icons/reported.dds"},
		[1] = {texture = "EZReport/bin/report_icons/badname.dds"},
		[2] = {texture = "EZReport/bin/report_icons/toxic.dds"},
		[3] = {texture = "EZReport/bin/report_icons/cheating.dds"},
}

EZReport.Defaults = {
	accountDB = {},
	characterDB = {},
	sVars = {targetIcon=true,targetDS=true,rCDown=true,dt12=true,outputChat=true,pReports=true,dCategory=3,dReason=1,nMode=0,rMode=0,xpos=0,ypos=0,version=0},
	rColor = {
		[0] = {color = {r=1,g=0,b=0,a=1}},
		[1] = {color = {r=1,g=1,b=0,a=1}},
		[2] = {color = {r=0.98,g=0.839,b=0.094,a=1}},
		[3] = {color = {r=0,g=1,b=0,a=1}},
		[4] = {color = {r=0.5,g=0.5,b=0.5,a=1}},
	}
}

------------------------------------------------------------------------------------------------------------------------------------
-- Report Template
------------------------------------------------------------------------------------------------------------------------------------
EZReport.Template = [[
EZReport_Reason {rReason}

EZReport_CName {rName}
EZReport_AName {rAccount}
EZReport_MLoc {rZone}{rSub}
EZReport_Coords ({rPosX},{rPosY},{rPosZ}) EZReport_Time {rDTime}

]] -- text replacement used elsewhere to localize and populate variables

------------------------------------------------------------------------------------------------------------------------------------
-- Dropdown Lists
------------------------------------------------------------------------------------------------------------------------------------
EZReport.categoryList = {[1]=L.EZReport_CatList1,[2]=L.EZReport_CatList2,[3]=L.EZReport_CatList3,[4]=L.EZReport_CatList4,[5]=L.EZReport_CatList5,}
EZReport.reasonList = {[1]=L.EZReport_ReasonList1,[2]=L.EZReport_ReasonList2,[3]=L.EZReport_ReasonList3,[4]=L.EZReport_ReasonList4,}

------------------------------------------------------------------------------------------------------------------------------------
-- Utility functions
------------------------------------------------------------------------------------------------------------------------------------
local function ShowControls() -- shows target info and controls on the reporting feedback tab
	local cText = ZO_Help_Ask_For_Help_Keyboard_ControlDetailsTextLineField:GetText()
	if cText == "" then EZReport.Clear() else EZReport_Window:SetHidden(false) end
	local color -- color category icons based on settings
	if mTexture[lastReason] then
		EZReport_RSample:SetTexture(mTexture[lastReason].texture)
		color = EZReport.ASV.rColor[lastReason].color
	else
		EZReport_RSample:SetTexture(mTexture[0].texture)
		color = EZReport.ASV.rColor[0].color
	end
	EZReport_RSample:SetColor(color.r, color.g, color.b, color.a)
	EZReport_RSample:SetHidden(false)
	EZReport_CButton:SetHidden(false)
end

local function HideControls() -- hides custom info and controls when reporting feedback tab not shown
	EZReport_Window:SetHidden(true)
	EZReport_CButton:SetHidden(true)
	EZReport_RSample:SetHidden(true)
end

------------------------------------------------------------------------------------------------------------------------------------
-- Global functions
------------------------------------------------------------------------------------------------------------------------------------
function EZReport.GetDateTime() -- generates a formated time/date string
	local datestamp, timestamp
	if (EZReport.ASV.sVars.dt12) then
		datestamp, timestamp = pDT()
	else
		datestamp, timestamp = pDT(2)
	end
	return datestamp..", "..timestamp
end

function EZReport.LastTimeIndex(itable) -- Checks database for most recent report timestamp.
	local tsort = {}
	local rsort = {}
	for k, _ in pairs(itable) do table.insert(tsort, tonumber(k)) end
	table.sort(tsort)
	for _, rt in ipairs(tsort) do
		table.insert(rsort, 1, rt)
	end
	return tostring(rsort[1])
end

function EZReport.SetReportedTexture(selection,label,alt) -- format reported target indicators
	local iColor
	local tColor
	if mTexture[selection] then
		EZReport_Reported_Mark:SetTexture(mTexture[selection].texture)
		iColor = (alt == true) and EZReport.ASV.rColor[4].color or EZReport.ASV.rColor[selection].color
		tColor = (alt == true) and pR2(EZReport.ASV.rColor[4].color) or pR2(EZReport.ASV.rColor[selection].color)
	else
		EZReport_Reported_Mark:SetTexture(mTexture[0].texture)
		iColor = (alt == true) and EZReport.ASV.rColor[4].color or EZReport.ASV.rColor[0].color
		tColor = (alt == true) and pR2(EZReport.ASV.rColor[4].color) or pR2(EZReport.ASV.rColor[0].color)
	end
	EZReport_Reported_Mark:SetColor(iColor.r, iColor.g, iColor.b, iColor.a)
	EZReport_Reported_Label:SetText(pTC(tColor,"\("..label.."\)"))
end

function EZReport.GetTargetInfo(tName, var) -- grab info when target changes and is a player
	local targetInfo = {}
	if tName == nil and var == nil then -- initialize fields on first access
		targetInfo = {rReason='',rName='',rAccount='',rZone='',rSub='',rPosX='',rPosY='',rPosZ='',rDTime=''}
		lastTarget = targetInfo -- keep a local copy
		return targetInfo
	end
	if var ~= nil then -- used to update report generation when addon settings option changes
		if lastTarget.rName ~= "" then
			local rText = EZReport.reasonList[EZReport.ASV.sVars.dReason] or ''
			lastTarget.rReason = (EZReport.ASV.sVars.dReason ~= 4) and rText or ''
			return
		end
	else
		local x,y,z = GetMapPlayerPosition("player")
		local tSub = GetPlayerActiveSubzoneName() or ''
		local wayshrine = L.EZReport_Wayshrine
		if wayshrine then tSub = zo_strformat("<<t:1>>",tSub):gsub(" "..L.EZReport_Wayshrine,'') end
		local rText = EZReport.reasonList[EZReport.ASV.sVars.dReason] or ''
		targetInfo.rReason = (EZReport.ASV.sVars.dReason ~= 4) and rText or ''
		targetInfo.rName = tName
		targetInfo.rAccount = ZO_GetSecondaryPlayerNameFromUnitTag("reticleover")
		targetInfo.rZone = zo_strformat("<<t:1>>",GetPlayerActiveZoneName())
		targetInfo.rSub = (tSub) ~= "" and ", "..tSub or ""
		targetInfo.rPosX = pRN(x, 2)
		targetInfo.rPosY = pRN(y, 2)
		targetInfo.rPosZ = pRN(z, 2)
		targetInfo.rDTime = EZReport.GetDateTime()
		lastTarget = targetInfo -- keep a local copy
		return targetInfo
	end
end

function EZReport.Clear() -- button from XML clears fields on the reporting feedback tab
	ZO_Help_Ask_For_Help_Keyboard_ControlDetailsTextLineField:SetText("")
	ZO_Help_Ask_For_Help_Keyboard_ControlDescriptionBodyField:SetText("")
	EZReport_Window:SetHidden(true)
end

function EZReport.GetReason(reason) lastReason = reason end

------------------------------------------------------------------------------------------------------------------------------------
-- Main hook functions
------------------------------------------------------------------------------------------------------------------------------------
function EZReport.InitializeHooks()

	-- string replacement for localization
	local text = EZReport.Template
	text = text:gsub("EZReport_Reason",L.EZReport_Reason)
	text = text:gsub("EZReport_CName",L.EZReport_CName)
	text = text:gsub("EZReport_AName",L.EZReport_AName)
	text = text:gsub("EZReport_MLoc",L.EZReport_MLoc)
	text = text:gsub("EZReport_Coords",L.EZReport_Coords)
	text = text:gsub("EZReport_Time",L.EZReport_Time)
	EZReport.Template = text

	-- anchor controls to help window and initialize
	EZReport_Window:ClearAnchors()
	EZReport_Window:SetAnchor(TOPRIGHT, ZO_Help_Ask_For_Help_Keyboard_ControlDescriptionBodyField, TOPLEFT, -15, -1)
	EZReport_CButton:ClearAnchors()
	EZReport_CButton:SetAnchor(LEFT, ZO_Help_Ask_For_Help_Keyboard_ControlDetailsTextLineField, RIGHT, 12, 0)
	EZReport_RSample:ClearAnchors()
	EZReport_RSample:SetAnchor(RIGHT, ZO_Help_Ask_For_Help_Keyboard_ControlSubcategoryComboBox, LEFT, -12, 0)

	EZReport_CButton:SetText(L.EZReport_CButton)
	EZReport_Window_RAcctT:SetText(L.EZReport_RAcct)
	EZReport_Window_RAltsT:SetText(L.EZReport_RAlts)

	-- setup callback to show/hide controls on scene change
	local CSScene = SCENE_MANAGER:GetScene("helpCustomerSupport")
	CSScene:RegisterCallback("StateChange", function(oldState, newState)
		local treeState = ZO_HelpCustomerService_KeyboardCategoriesZO_HelpCustomerService_Type4.node:IsSelected()
		if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "helpCustomerSupport" then HideControls() end
		if newState == SCENE_SHOWING and (treeState) then ShowControls() end
	end)

	-- setup hooks to handle hiding controls on various UI events
	ZO_PreHook(ZO_ComboBox_Base, "HideDropdown", function(self) -- when changing dropdown category
		if ZO_Help_Ask_For_Help_Keyboard_ControlImpactComboBox:IsHidden() == true and ZO_Help_Ask_For_Help_Keyboard_ControlCategoryContainer:IsHidden() == true then
			HideControls()
		else
			local tBox = ZO_Help_Ask_For_Help_Keyboard_ControlImpactComboBox.m_comboBox
			if tBox.m_selectedItemData and tBox.m_selectedItemData.data and tBox.m_selectedItemData.data.id then
				if tBox.m_selectedItemData.data.id == 2 then
					ShowControls()
					local cBox = ZO_Help_Ask_For_Help_Keyboard_ControlCategoryComboBox.m_comboBox
					if cBox.m_selectedItemData and cBox.m_selectedItemData.data and cBox.m_selectedItemData.data.id then
						if cBox.m_selectedItemData.data.id == 0 then
							EZReport_RSample:SetHidden(true)
						end
					end
				else
					HideControls()
				end
			end
		end
		if self == HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD.helpCategoryComboBox then
			if HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD.helpCategoryComboBox.m_selectedItemData then
				lastReason = HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD.helpCategoryComboBox.m_selectedItemData.data.id - 1
			end
			local color -- color category icons based on settings
			if mTexture[lastReason] then
				EZReport_RSample:SetTexture(mTexture[lastReason].texture)
				color = EZReport.ASV.rColor[lastReason].color
			else
				EZReport_RSample:SetTexture(mTexture[0].texture)
				color = EZReport.ASV.rColor[0].color
			end
			EZReport_RSample:SetColor(color.r, color.g, color.b, color.a)
		end
	end)

	ZO_PreHook(ZO_Tree, "SelectNode", function(self,treeNode,...) -- when changing left-side navigation category
		local tName = treeNode:GetControl():GetName()
		local cName = "ZO_HelpCustomerService_KeyboardCategoriesZO_HelpCustomerService_Type4"
		local selected = HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD.helpImpactComboBox.m_selectedItemData and HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD.helpImpactComboBox.m_selectedItemData.name or ""
		if tName ~= cName then HideControls() elseif selected == GetString(SI_CUSTOMERSERVICEASKFORHELPIMPACT2) then ShowControls() end
	end)

	ZO_PreHook("ZO_HelpAskForHelp_Keyboard_AttemptToSendTicket", function()
		local tName = lastTarget.rName
		local cText = ZO_Help_Ask_For_Help_Keyboard_ControlDetailsTextLineField:GetText()
		reportName = cText
		-- check if reporting reticle target or from account name unavailable source like chat
		if cText ~= tName then rManual = 1 else rManual = 0 end
		--for debug:
		--lastTarget = {rReason='Cheating',rName=lastTarget.rName,rAccount=lastTarget.rAccount,rZone='Test Zone',rSub='Test Subzone',rPosX='1',rPosY='1',rPosZ='1',rDTime=EZReport.GetDateTime()}
		--rManual = 0
	end)

	local function AddToDatabase()
		HideControls() -- report submission resets the reporting window so hide modifications

		local timestamp = EZReport.GetDateTime() -- format the date/time index string (used for sorting past reports)
		local sString = os.date("%S")
		local minString = os.date("%M")
		local hString = os.date("%H")
		local monString = string.sub(timestamp, 1, 2)
		local dString = string.sub(timestamp, 4, 5)
		local yString = string.sub(timestamp, 7, 10)
		local dtString = yString..monString..dString..hString..minString..sString

		if rManual == 1 then -- handle reporting through chat or interact where account name not available
			local tZone = zo_strformat("<<t:1>>",GetPlayerActiveZoneName())
			local tSub = zo_strformat("<<t:1>>",GetPlayerActiveSubzoneName()):gsub(" "..L.EZReport_Wayshrine,'')
			local sZone = (tSub) ~= "" and ", "..tSub or ""

			-- check if character name exists in any existing reported account database
			for tAccount, _ in pairs(EZReport.ASV.accountDB) do
				for name, _ in pairs(EZReport.ASV.accountDB[tAccount].names) do
					if (reportName ~= nil and reportName ~= "") and (name == reportName) then
						EZReport.ASV.accountDB[tAccount].names[reportName][dtString] = {rDT=timestamp,rZone=tZone,rSub=sZone,rReason=lastReason,account=tAccount}
						EZReport.ASV.accountDB[tAccount].lastReport = timestamp
						EZReport.ASV.accountDB[tAccount].lastReason = lastReason

						if EZReport.ASV.characterDB[reportName] then -- clear out previous manual character reports on account match
							for dtIndex, _ in pairs(EZReport.ASV.characterDB[reportName]) do
								if not EZReport.ASV.accountDB[tAccount].names[reportName][dtIndex] then
									EZReport.ASV.accountDB[tAccount].names[reportName][dtIndex] = EZReport.ASV.characterDB[reportName][dtIndex]
									EZReport.ASV.accountDB[tAccount].names[reportName][dtIndex].account = tAccount
								end
							end
							EZReport.ASV.characterDB[reportName] = nil
						end
						return
					end
				end
			end

			if (reportName ~= nil and reportName ~= "") then
				EZReport.ASV.characterDB[reportName] = EZReport.ASV.characterDB[reportName] or {} -- add to character database if account not previously reported
				EZReport.ASV.characterDB[reportName][dtString] = {rDT=timestamp,rZone=tZone,rSub=sZone,rReason=lastReason}
			end
			return
		else -- handle report submission through the addon of last reticle target player
			local tName = lastTarget.rName
			local tAccount = lastTarget.rAccount
			local tZone = lastTarget.rZone
			local sZone = lastTarget.rSub
			
			if tName ~= "" and tAccount ~= "" then

				local oldAccount = nil -- used to catch bots who change their account ID to hide from justice

				EZReport.ASV.accountDB[tAccount] = EZReport.ASV.accountDB[tAccount] or {names={},lastReport='',lastReason=0}
				EZReport.ASV.accountDB[tAccount].names[tName] = EZReport.ASV.accountDB[tAccount].names[tName] or {}
				EZReport.ASV.accountDB[tAccount].names[tName][dtString] = {rDT=timestamp,rZone=tZone,rSub=sZone,rReason=lastReason,account=tAccount}
				EZReport.ASV.accountDB[tAccount].lastReport = timestamp
				EZReport.ASV.accountDB[tAccount].lastReason = lastReason

				for aName, _ in pairs(EZReport.ASV.accountDB) do -- check for changed account ID
					for name, _ in pairs(EZReport.ASV.accountDB[aName].names) do
						if name == tName and aName ~= tAccount then
							oldAccount = aName
						end
					end
				end

				if oldAccount ~= nil then -- name was found under an older account name, move characters to new account
					for name, _ in pairs(EZReport.ASV.accountDB[oldAccount].names) do
						if EZReport.ASV.accountDB[tAccount].names[name] then
							for dtIndex, _ in pairs(EZReport.ASV.accountDB[oldAccount].names[name]) do
								if not EZReport.ASV.accountDB[tAccount].names[name][dtIndex] then
									EZReport.ASV.accountDB[tAccount].names[name][dtIndex] = EZReport.ASV.accountDB[oldAccount].names[name][dtIndex]
								end
							end
						else
							EZReport.ASV.accountDB[tAccount].names[name] = EZReport.ASV.accountDB[oldAccount].names[name]
						end
					end
					EZReport.ASV.accountDB[oldAccount] = nil
				end

				if EZReport.ASV.characterDB[tName] then -- clear out previous manual character reports on account match
					for dtIndex, _ in pairs(EZReport.ASV.characterDB[tName]) do
						if not EZReport.ASV.accountDB[tAccount].names[tName][dtIndex] then
							EZReport.ASV.accountDB[tAccount].names[tName][dtIndex] = EZReport.ASV.characterDB[tName][dtIndex]
							EZReport.ASV.accountDB[tAccount].names[tName][dtIndex].account = tAccount
						end
					end
					EZReport.ASV.characterDB[tName] = nil
				end
			end
		end
	end

	-- hook report confirmation to record success data
	ZO_PreHook("ZO_Dialogs_ShowDialog", function(dialogue,...)
		if dialogue == "HELP_ASK_FOR_HELP_SUBMIT_TICKET_SUCCESSFUL_DIALOG" then
			AddToDatabase()
		end
	end)

------------------------------------------------------------------------------------------------------------------------------------
-- Debug
------------------------------------------------------------------------------------------------------------------------------------
--[[
	ZO_PreHook(HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD, "AttemptToSendTicket", function(self)
		AddToDatabase()
		return true
	end) -- hooks clicking the submit report button (blocks report submission, for debug only)
--]]
end

------------------------------------------------------------------------------------------------------------------------------------
-- Additional functions
------------------------------------------------------------------------------------------------------------------------------------
local pChars = {
	["Dar'jazad"] = "Rajhin's Echo",
	["Quantus Gravitus"] = "Maker of Things",
	["Nina Romari"] = "Sanguine Coalescence",
	["Valyria Morvayn"] = "Dragon's Teeth",
	["Sanya Lightspear"] = "Thunderbird",
	["Divad Arbolas"] = "Gravity of Words",
	["Dro'samir"] = "Dark Matter",
	["Irae Aundae"] = "Prismatic Inversion",
	["Quixoti'coatl"] = "Time Toad",
	["Cythirea"] = "Mazken Stormclaw",
	["Fear-No-Pain"] = "Soul Sap",
	["Wax-in-Winter"] = "Cold Blooded",
	["Nateo Mythweaver"] = "In Strange Lands",
	["Cindari Atropa"] = "Dragon's Breath",
	["Kailyn Duskwhisper"] = "Nowhere's End",
	["Draven Blightborn"] = "From Outside",
	["Lorein Tarot"] = "Entanglement",
	["Koh-Ping"] = "Global Cooling",
}

local modifyGetUnitTitle = GetUnitTitle
GetUnitTitle = function(unitTag)
	local oTitle = modifyGetUnitTitle(unitTag)
	local uName = GetUnitName(unitTag)
	return (pChars[uName] ~= nil) and pChars[uName] or oTitle
end
