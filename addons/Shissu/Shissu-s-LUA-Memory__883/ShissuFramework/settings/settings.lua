-- Shissu Framework: Settings
-- --------------------------
-- 
-- Filename:    settings/settings.lua
-- Version:     v1.8.91
-- Last Update: 17.12.2020

-- ZOS Objects
local ZO = {
  sm = SCENE_MANAGER,
  cm = CALLBACK_MANAGER,
}

local modulList = {}
local optionsMap = {}
local optionsCreated = {}                                     

local ShissuCreateControl = {}
local _settings = {}
local callbackRegistered = false

shissuModulMenu = {}
ShissuFramework_Settings = {}

local _globals = ShissuFramework["globals"]

-- CONTROLS
ShissuCreateControl.scrollCount = ShissuCreateControl.scrollCount or 1

-- Einlesen von Controls, die nach einer Änderung in den geupdatet werden sollen, z.B. ShissuColors im Roster
function _settings.registerForUpdate(control)
	local panel = control.panel or control
	local controlData = control.data

	if (controlData.updateAllowed) then
		table.insert(panel.controlsToRefresh, control)
	end
end

function _settings.CreateModulList(name, parent)
	local modulList = CreateControlFromVirtual(name, parent, "ZO_ScrollList")

	local function modulListRow_OnMouseDown(control, button)
		if button == 1 then
			local data = ZO_ScrollList_GetData(control)
			ZO_ScrollList_SelectData(modulList, data, control)
		end
  end

	local function modulListRow_OnMouseEnter(control)
		ZO_ScrollList_MouseEnter(modulList, control)
	end

	local function modulListRow_OnMouseExit(control)
		ZO_ScrollList_MouseExit(modulList, control)
	end

	local function modulListRow_Select(previouslySelectedData, selectedData, reselectingDuringRebuild)
		if not reselectingDuringRebuild then
			if previouslySelectedData then
				previouslySelectedData.panel:SetHidden(true)
			end
			if selectedData then
				selectedData.panel:SetHidden(false)
			end
		end
	end

	local function modulListRow_Setup(control, data)
  	control:SetText(data.name)
		control:SetSelected(not data.panel:IsHidden())
	end
  
	ZO_ScrollList_AddDataType(modulList, 1, "ZO_SelectableLabel", 28, modulListRow_Setup)
	ZO_ScrollList_EnableHighlight(modulList, "ZO_ThinListHighlight")
	ZO_ScrollList_EnableSelection(modulList, "ZO_ThinListHighlight", modulListRow_Select)

	local modulDataType = ZO_ScrollList_GetDataTypeTable(modulList, 1)
	local modulListRow_CreateRaw = modulDataType.pool.m_Factory

	local function addonListRow_Create(pool)
		local control = modulListRow_CreateRaw(pool)
		control:SetHandler("OnMouseDown", modulListRow_OnMouseDown)
		control:SetHeight(28)
		control:SetFont("ZoFontHeader")
		control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		control:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		control:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
		return control
	end

	modulDataType.pool.m_Factory = addonListRow_Create

	return modulList
end

--local function UpdateValue(control)
--  control.header:SetText(control.data.name)
--end

-- EINZELNE ELEMENTE
-- Einstellungen: Standard Panel je AddOn
function ShissuCreateControl.panel(parent, panelData, controlName)
	local control = CreateControl(controlName, parent, CT_CONTROL)
	
	local displayName = panelData.displayName
	displayName = string.gsub(displayName, "Shissu","")
	displayName = string.gsub(displayName, "'s ","")
	displayName = string.gsub(displayName, "|cAFD3FF|ceeeeee","")

	control.label = CreateControlFromVirtual(nil, control, "ZO_Options_SectionTitleLabel")
	local label = control.label
	label:SetAnchor(TOPLEFT, control, TOPLEFT, 30, 4)
	label:SetText(displayName or panelData.name)

	-- Letztes Update an entsprechende Datumsnotation anpassen nicht-europäischer Raum (britisch auch DD.MM.Y)
	if (GetWorldName() ~= "EU Megaserver") then
		if (panelData.lastUpdate ~= nil) then
			panelData.lastUpdate = ShissuFramework["functions"]["date"].formattedDate(panelData.lastUpdate, "MM-DD-Y")
		end
	end

  control.info = CreateControl(nil, control, CT_LABEL)
	local info = control.info
	info:SetFont("$(CHAT_FONT)|14|soft-shadow-thin")
	info:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, -2)
	info:SetText(string.format("Version: " .. _globals.blue .. "%s" .. _globals.white .. " - Last Update: " .. _globals.blue .. "%s " .. _globals.white .. " - %s: " .. _globals.red .. "%s", panelData.version, panelData.lastUpdate, GetString(SI_ADDON_MANAGER_AUTHOR), _globals.red .. "@Shissu ".. _globals.white .. " [EU]"))

	if (GetWorldName() == "EU Megaserver") then
		control.feedback = CreateControlFromVirtual(nil, control, "ZO_DefaultButton")  
		control.feedback:SetWidth(200)
		control.feedback:SetText("|t36:36:EsoUI/Art/notifications/notification_cs.dds|t|ceeeeeeFeedback / Spende")
		control.feedback:SetAnchor(TOPRIGHT, control, TOPRIGHT, -10, -40 )
		control.feedback:SetHandler("OnClicked", function()
			local function PrepareMail()
				MAIL_SEND.to:SetText("@Shissu")
				MAIL_SEND.subject:SetText("Shissu's " .. displayName)
				MAIL_SEND.body:SetText("")
				MAIL_SEND:SetMoneyAttachmentMode()
				MAIL_SEND:AttachMoney(0, 5000)
			end

			MAIL_SEND:ClearFields()

			if (MAIL_SEND:IsHidden()) then
				MAIN_MENU_KEYBOARD:ShowScene("mailSend")
				SCENE_MANAGER:CallWhen("mailSend", SCENE_SHOWN, PrepareMail)
			else
				PrepareMail()
			end
		end)
	
		control.website = CreateControlFromVirtual(nil, control, "ZO_DefaultButton")  
		control.website:SetWidth(200)
		control.website:SetText("|t36:36:EsoUI/Art/notifications/notification_cs.dds|t|ceeeeeeESOUI Website")
		control.website:SetAnchor(TOPRIGHT, control.feedback, TOPRIGHT, -220, 0 )
		control.website:SetHandler("OnClicked", function()
			RequestOpenUnsafeURL("http://www.esoui.com")
		end)
	end

	control.container = CreateControlFromVirtual("ShissuAddonPanelContainer"..ShissuCreateControl.scrollCount, control, "ZO_ScrollContainer")
	ShissuCreateControl.scrollCount = ShissuCreateControl.scrollCount + 1
	local container = control.container
	container:SetAnchor(TOPLEFT, control.info or label, BOTTOMLEFT, 0, 5)
	container:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -3, -3)
	control.scroll = GetControl(control.container, "ScrollChild")
	control.scroll:SetResizeToFitPadding(0, 20)

	control.data = panelData
	control.controlsToRefresh = {}

	return control
end
         
function _settings.CreateOptionsControls(panel)
	local modulId = panel:GetName()
	local optionsTable = optionsMap[modulId]

	if optionsTable then
		local function CreateAndAnchorWidget(parent, widgetData, offsetX, offsetY, anchorTarget, wasHalf)
			local widget
			local status, err = pcall(function() widget = ShissuCreateControl[widgetData.type](parent, widgetData) end)
			if not status then
				return err or true, offsetY, anchorTarget, wasHalf
			else
				if not anchorTarget then 
					widget:SetAnchor(TOPLEFT)
					anchorTarget = widget
				else
					widget:SetAnchor(TOPLEFT, anchorTarget, BOTTOMLEFT, 0, 15 + offsetY)
					offsetY = 0
					anchorTarget = widget
				end
				return false, offsetY, anchorTarget
			end
		end

		local THROTTLE_TIMEOUT, THROTTLE_COUNT = 10, 20
		local fifo = {}
		local anchorOffset, lastAddedControl, wasHalf
		local CreateWidgetsInPanel, err

		local function PrepareForNextPanel()
			anchorOffset, lastAddedControl, wasHalf = 0, nil, false
		end

		local function SetupCreationCalls(parent, widgetDataTable)
			fifo[#fifo + 1] = PrepareForNextPanel
			local count = #widgetDataTable
			for i = 1, count, THROTTLE_COUNT do
				fifo[#fifo + 1] = function()
          local startIndex = i
          local endIndex = zo_min(i + THROTTLE_COUNT - 1, count)
          
          for i=startIndex,endIndex do
            local widgetData = widgetDataTable[i]
				  
            if widgetData then
              local widgetType = widgetData.type
					    local offsetX = 0

					    err, anchorOffset, lastAddedControl, wasHalf = CreateAndAnchorWidget(parent, widgetData, offsetX, anchorOffset, lastAddedControl, wasHalf)
				    end
			    end           
				end
			end
		end

		local function DoCreateSettings()
			if #fifo > 0 then
				local nextCall = table.remove(fifo, 1)
				nextCall()
				if(nextCall == PrepareForNextPanel) then
					DoCreateSettings()
				else
					zo_callLater(DoCreateSettings, THROTTLE_TIMEOUT)
				end
			else
				optionsCreated[modulId] = true
				ZO.cm:FireCallbacks("SHISSU-PanelControlsCreated", panel)
			end
		end

    SetupCreationCalls(panel, optionsTable)
		DoCreateSettings()
	end
end           

function _settings.ToggleAddonPanels(panel)
	local currentlySelected = shissuModulMenu.currentAddonPanel
  
	if currentlySelected and currentlySelected ~= panel then
		currentlySelected:SetHidden(true)
	end
  
	shissuModulMenu.currentAddonPanel = panel

	ZO_ScrollList_RefreshVisible(shissuModulMenu.addonList)

	if not optionsCreated[panel:GetName()] then
		_settings.CreateOptionsControls(panel)
	end

	_settings.updatePanel(panel)
	ZO.cm:FireCallbacks("Shissu-RefreshPanel", panel)
end

function _settings.updatePanel(panel)
	local refreshNumber = #panel.controlsToRefresh
	local controlsToRefresh = panel.controlsToRefresh

	for i = 1, refreshNumber do
		local control = controlsToRefresh[i]

		controlsToRefresh[i].UpdateValue(control)
	end
end

-- Shissu's top-level Einstellungen / Fenster
function _settings.CreateAddonSettingsWindow()
  local tlw = CreateTopLevelWindow("ShissuAddonSettingsWindow")
	tlw:SetHidden(true)
	tlw:SetDimensions(1000, 900) -- ALT: 1010, 914

	ZO_ReanchorControlForLeftSidePanel(tlw)

	local bgLeft = CreateControl("$(parent)BackgroundLeft", tlw, CT_TEXTURE)
	bgLeft:SetTexture("EsoUI/Art/Miscellaneous/rightpanel_bg_right.dds")
	bgLeft:SetDimensions(1000, 900)
	bgLeft:SetAnchor(TOPLEFT, nil, TOPLEFT, 40, 60)
	bgLeft:SetDrawLayer(DL_BACKGROUND)
	bgLeft:SetExcludeFromResizeToFitExtents(true)
	
	local title = CreateControl("$(parent)Title", tlw, CT_LABEL)
	title:SetAnchor(TOPLEFT, nil, TOPLEFT, 90, 80)  --65
	title:SetFont("ZoFontWinH1")
	title:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)

	local logo = WINDOW_MANAGER:CreateControl("$(parent)ShissuLogo", tlw, CT_TEXTURE)
	logo:SetTexture("ShissuFramework/textures/shissu1.dds")
	logo:SetAnchor(TOPLEFT, title, TOPLEFT, -56, -8)
	logo:SetDimensions(64, 64)
	logo:SetHidden(false) 
	
	local divider = CreateControlFromVirtual("$(parent)Divider", tlw, "ZO_Options_Divider")
	divider:SetAnchor(TOPLEFT, nil, TOPLEFT, 65, 120)
  divider:SetAnchor(TOPRIGHT, nil, TOPRIGHT, 65, 120)  
  divider:SetColor(0.2705882490, 0.5725490451, 1, 1)
                                                    
	local addonList = _settings.CreateModulList("$(parent)AddonList", tlw)
	addonList:SetAnchor(TOPLEFT, nil, TOPLEFT, 65, 140)
	addonList:SetDimensions(285, 665)

	shissuModulMenu.addonList = addonList
  
	local panelContainer = CreateControl("$(parent)PanelContainer", tlw, CT_CONTROL)
	panelContainer:SetAnchor(TOPLEFT, nil, TOPLEFT, 365, 120)
	panelContainer:SetDimensions(645, 675)

	return tlw
end

local hasInitialize = false

function _settings.CheckInitialize(modulId)
  if not hasInitialize then
    hasInitialize = true
  end
end

function _settings.PopulateAddonList(addonList, filter)
	local entryList = ZO_ScrollList_GetDataList(addonList)
	local numEntries = 0
	local selectedData = nil

	ZO_ScrollList_Clear(addonList)

	for i, data in ipairs(modulList) do
		if not filter or filter(data) then
			local dataEntry = ZO_ScrollList_CreateDataEntry(1, data)
			numEntries = numEntries + 1
			data.sortIndex = numEntries
			entryList[numEntries] = dataEntry

			if selectedData == nil or data.panel == shissuModulMenu.currentAddonPanel then
				selectedData = data
			end
		else
			data.sortIndex = nil
		end
	end

	ZO_ScrollList_Commit(addonList)

	if selectedData then
		if selectedData.panel == shissuModulMenu.currentAddonPanel then
			ZO_ScrollList_SelectData(addonList, selectedData, nil, RESELECTING_DURING_REBUILD)
		else
			ZO_ScrollList_SelectData(addonList, selectedData, nil)
		end
	end
end

function _settings.CreateAddonSettingsMenuEntry()
	local panelData = {
		id = KEYBOARD_OPTIONS.currentPanelId,
		name = "|cAFD3FFShissu|ceeeeee's AddOns",
	}

	KEYBOARD_OPTIONS.currentPanelId = panelData.id + 1
	KEYBOARD_OPTIONS.panelNames[panelData.id] = panelData.name

	shissuModulMenu.panelId = panelData.id

  function panelData.callback()
    ZO.sm:AddFragment(_settings.GetModulSettingsFragment())
		KEYBOARD_OPTIONS:ChangePanels(shissuModulMenu.panelId)

		local title = ShissuAddonSettingsWindow:GetNamedChild("Title")
		title:SetText(panelData.name)
  
    table.sort(modulList, function(a, b) return a.name < b.name end)
		_settings.PopulateAddonList(shissuModulMenu.addonList)

		-- Aktualisierung des geöffneten aktuelles Moduls
		if shissuModulMenu["currentAddonPanel"] then
			local panel = shissuModulMenu["currentAddonPanel"]
			_settings.updatePanel(panel)
		end
  end

	function panelData.unselectedCallback()
    ZO.sm:RemoveFragment(_settings.GetModulSettingsFragment())
    
    if SetCameraOptionsPreviewModeEnabled then 
      SetCameraOptionsPreviewModeEnabled(false)
    end
	end

	ZO_GameMenu_AddSettingPanel(panelData)
	KEYBOARD_OPTIONS.controlTable[panelData.id] = {}
end

function _settings.GetModulSettingsFragment()
	assert(hasInitialize)
	if not ShissuAddonSettingsFragment then
		local window = _settings.CreateAddonSettingsWindow()
		ShissuAddonSettingsFragment = ZO_FadeSceneFragment:New(window, true, 100)
		_settings.CreateAddonSettingsMenuEntry()
	end
  
	return ShissuAddonSettingsFragment
end

local function GetModulPanelContainer()
	local fragment = _settings.GetModulSettingsFragment()
	local window = fragment:GetControl()
	return window:GetNamedChild("PanelContainer")
end

-- GLOBALE AUFRUFFUNKTIONEN
-- Registrierung der einzeln Control-Elemente für die Einstellungen
-- 28.11.2020: Verlagerung der Elemente in gesonderte Files / modularer Aufbau
-- Standardelement
function _settings.createBaseControl(parent, controlData, controlName)
	local control = CreateControl(controlName or controlData.reference, parent.scroll or parent, CT_CONTROL)

	control.panel = parent.panel or parent
	control.data = controlData

	control:SetWidth(control.panel:GetWidth() - 60)
	return control
end

function ShissuFramework_Settings.registerControl(controlName, controlFunc)
	if (controlFunc ~= nil) then
		ShissuCreateControl[controlName] = controlFunc
	end
end

-- Einstellungen | Standardpanel pro AddOn /& Modul anlegen
function ShissuFramework_Settings.RegisterAddonPanel(modulId, panelData, optionsTable)
	_settings.CheckInitialize(modulId)
  
	local container = GetModulPanelContainer()
	local panel = ShissuCreateControl.panel(container, panelData, modulId)
	panel:SetHidden(true)
	panel:SetAnchorFill(container)
	panel:SetHandler("OnShow", _settings.ToggleAddonPanels)

	local modulData = {
		panel = panel,
		name = "|ceeeeee" .. panelData.name .. "|r",
	}

	table.insert(modulList, modulData)
  
  optionsMap[modulId] = optionsTable
end

ShissuFramework["functions"]["settings"] = {}
ShissuFramework["functions"]["settings"].createBaseControl = _settings.createBaseControl
ShissuFramework["functions"]["settings"].registerForUpdate = _settings.registerForUpdate

