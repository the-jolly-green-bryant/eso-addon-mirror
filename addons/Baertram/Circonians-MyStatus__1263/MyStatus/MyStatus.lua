local ADDON_NAME    = "myStatus"
local DEBUG_MODE 	= false
local CODE_VERSION	= 1.70

local myStatus = ZO_Object:Subclass()
local MY_STATUS

local EM = EVENT_MANAGER
local tins = table.insert

local chatIsMinimized = false

--=====================================================--
--======= DEBUG =========--
--=====================================================--
local function debugMsg(msg, tableItem)
	if not DEBUG_MODE then return end
	if not MYSTATUS_DEBUG_TABLE then MYSTATUS_DEBUG_TABLE = {} end

	if msg and msg ~= "" then
		d(tostring(msg))
		tins(MYSTATUS_DEBUG_TABLE, msg)
	end

	-- Used to save object references for later examination:
	if tableItem then
		tins(MYSTATUS_DEBUG_TABLE, tableItem)
	end
end
--=====================================================--
--=====================================================--


--=====================================================--
--======= NEW/INIT =========--
--=====================================================--
function myStatus:New(control)
    local manager = ZO_Object.New(self)
    manager.control = control -->XML defined My_Status_TLC

    local comboBoxControl = GetControl(control, "Status")
    manager.statusComboBoxControl = comboBoxControl
    local statusBG = GetControl(comboBoxControl, "BG")
    manager.stausComboBoxBGControl = statusBG
    statusBG:SetHidden(true)

    manager.comboBox = ZO_ComboBox_ObjectFromContainer(comboBoxControl)
    manager.comboBox:SetSortsItems(false)
    manager.comboBox:SetDropdownFont("ZoFontHeader")
    manager.comboBox:SetSpacing(8)
    manager.selectedItem = GetControl(comboBoxControl, "SelectedItem")

    manager.OnStatusChanged =   function(_, entryText, entry)
--d("[myStatus]MANAGER_OnStatusChanged, status: " ..tostring(entry.status))
                                    --manager:SetSelectedStatus(entry.status) --Double call! Will be called from SelectPlayerStatus(entry.status) blow through EVENT_PLAYER_STATUS_CHANGED callback function
                                    SelectPlayerStatus(entry.status)
                                end

    manager:Initialize()

    control:RegisterForEvent(EVENT_PLAYER_STATUS_CHANGED, function(_, oldStatus, newStatus) manager:OnPlayerStatusChanged(oldStatus, newStatus) end)

    return manager
end


function myStatus:Initialize()
    for i = 1, GetNumPlayerStatuses() do
        local statusTexture = GetPlayerStatusIcon(i)
        local statusName = GetString("SI_PLAYERSTATUS", i)
        local entryText = zo_iconTextFormat(statusTexture, 32, 32, statusName) --This will show ... now as the text is too long for the dropdown
        local entry = self.comboBox:CreateItemEntry(entryText, self.OnStatusChanged)
        entry.status = i
		self.comboBox:AddItem(entry)
    end

    local status = GetPlayerStatus()
    self:SetSelectedStatus(status)

    --Register the slash commands
    SLASH_COMMANDS["/dnd"] = function() MyStatus_Set_Status('dnd') end
    SLASH_COMMANDS["/afk"] = function() MyStatus_Set_Status('away') end
    SLASH_COMMANDS["/on"]  = function() MyStatus_Set_Status('online') end
    SLASH_COMMANDS["/off"] = function() MyStatus_Set_Status('offline') end
end


--=====================================================--
--======= OTHER =========--
--=====================================================--
function myStatus:SetSelectedStatus(status)
--d("[myStatus]SetSelectedStatus, status: " ..tostring(status))
    local statusTexture = GetPlayerStatusIcon(status)
    self.status 		= status

    self.selectedItem:SetNormalTexture(statusTexture)
    self.selectedItem:SetPressedTexture(statusTexture)
    self.comboBox:SetSelectedItemText("") --Empty the text or it will always show ... because the text output is not wide enough for the icon :-(
    self.stausComboBoxBGControl:SetHidden(true)
end

function myStatus:OnPlayerStatusChanged(oldStatus, newStatus)
--d("[myStatus]OnPlayerStatusChanged, oldStatus: " ..tostring(oldStatus) .. ", newStatus: " ..tostring(newStatus))
    self:SetSelectedStatus(newStatus)
end

function myStatus:Status_OnMouseEnter(control)
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -25)
    SetTooltipText(InformationTooltip, zo_strformat(SI_PLAYER_STATUS_TOOLTIP, GetString("SI_PLAYERSTATUS", self.status)))
end

function myStatus:Status_OnMouseExit()
    ClearTooltip(InformationTooltip)
end


--=====================================================--
--======= HOOKS  =========--
--=====================================================--
local OrigShowMiniBar = CHAT_SYSTEM.ShowMinBar
function CHAT_SYSTEM:ShowMinBar()
	OrigShowMiniBar(self)

    if MY_STATUS ~= nil then
        MY_STATUS:AnchorToMiniBar()
    end
end

local OrigHideMiniBar = CHAT_SYSTEM.HideMinBar
function CHAT_SYSTEM:HideMinBar()
	OrigHideMiniBar(self)

    if MY_STATUS ~= nil then
        MY_STATUS:AnchorToChatWindow()
    end
end

--=====================================================--
--======= HOOK FUNCTIONS =========--
--=====================================================--
function myStatus:AnchorToMiniBar()
    chatIsMinimized = true
    self.stausComboBoxBGControl:SetHidden(true)
	local control = self.control

	--control:SetParent(CHAT_SYSTEM.minBar) -- API101034 TLCs cannot be parented to anything else than GuiRoot
	control:ClearAnchors()
	control:SetAnchor(TOPLEFT, ZO_ChatWindowNumNotifications, BOTTOMLEFT, 0, 0)
    control:BringWindowToTop()
end
function myStatus:AnchorToChatWindow()
    chatIsMinimized = false
    self.stausComboBoxBGControl:SetHidden(true)
	local control = self.control

	--control:SetParent(CHAT_SYSTEM.control) -- API101034 TLCs cannot be parented to anything else than GuiRoot
	control:ClearAnchors()
	control:SetAnchor(LEFT, ZO_ChatWindowNumNotifications, RIGHT, 2, 0)
    control:BringWindowToTop()
end


--=====================================================--
--======= XML FUNCTIONS =========--
--=====================================================--
function MyStatus__OnMouseEnter(control)
    MY_STATUS:Status_OnMouseEnter(control)
end

function MyStatus__OnMouseExit(control)
    MY_STATUS:Status_OnMouseExit()
end

function MyStatus__OnStatusDropdownClicked(control)
    ZO_ComboBox_DropdownClicked(control)
    --Reanchor the dropdown control if the chat is minimized
    if chatIsMinimized == true then
        if My_Status_TLCStatusDropdown ~= nil then
            My_Status_TLCStatusDropdown:ClearAnchors()
            My_Status_TLCStatusDropdown:SetAnchor(BOTTOMLEFT, My_Status_TLCStatusOpenDropdown, BOTTOMRIGHT, 2, 0)
        end
    else
        if My_Status_TLCStatusDropdown ~= nil then
            My_Status_TLCStatusDropdown:ClearAnchors()
            My_Status_TLCStatusDropdown:SetAnchor(TOPLEFT, My_Status_TLCStatus, BOTTOMLEFT, 0, 5)
        end
    end
end

function MyStatus_OnInitialized(MyStatusControlFromXML) -->XML defined My_Status_TLC
    MY_STATUS = myStatus:New(MyStatusControlFromXML)
    --Global variable MyStatus
    MyStatus = MY_STATUS

	ZO_CreateStringId("SI_BINDING_NAME_MYSTATUS_TOGGLE_STATUS", "Toggle Status")
	ZO_CreateStringId("SI_BINDING_NAME_MYSTATUS_ONLINE_STATUS", "Status Online")
	ZO_CreateStringId("SI_BINDING_NAME_MYSTATUS_AWAY_STATUS", "Status Away")
	ZO_CreateStringId("SI_BINDING_NAME_MYSTATUS_DND_STATUS", "Status Do not disturb")
	ZO_CreateStringId("SI_BINDING_NAME_MYSTATUS_OFFLINE_STATUS", "Status Offline")
end

function MyStatus_Set_Status(chosenStatus)
	chosenStatus = chosenStatus or "online"
	local statusTable = {
    	["online"]	= 1,
    	["away"]	= 2,
    	["dnd"]		= 3,
    	["offline"]	= 4,
    }
	local newStatus = statusTable[chosenStatus]
	SelectPlayerStatus(newStatus)
end

function MyStatus_Toggle_Status()
	local numStatuses = GetNumPlayerStatuses()
    local status = GetPlayerStatus()
	local newStatus = (status % numStatuses) + 1

	SelectPlayerStatus(newStatus)
end


local function OnPlayerActivated()
--d("[myStatus]OnPlayerActivated")

    --Update the current status to the myStatus dropdownbox
    local curStatus = GetPlayerStatus()
    MY_STATUS:SetSelectedStatus(curStatus)
end

-------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------
local function OnAddOnLoaded(event, addonName)
	if addonName ~= ADDON_NAME then return end

    --Events
	EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    EM:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

---------------------------------------------------------------------
--  Register Events --
---------------------------------------------------------------------
EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)