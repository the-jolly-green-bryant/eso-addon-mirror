AreWeMounted = {}
AreWeMounted.name = "AreWeMounted"
AreWeMounted.version = "1.0.0"
AreWeMounted.savedVarsVer = 1
AreWeMounted.savedVars = {}

local LAM = LibAddonMenu2

local debug = false

local isInit = false
local nMounted = 0

local ARM_MOUNT_STATE_UNKNOWN = 0
local ARM_MOUNT_STATE_MOUNTED = 1
local ARM_MOUNT_STATE_CAN_MOUNT = 2
local ARM_MOUNT_STATE_IN_COMBAT = 3

local LABEL_WIDTH = 200
local LABEL_HEIGHT = 15
local LABEL_PAD_Y = 5
local GROUP_HEIGHT = GROUP_SIZE_MAX * (LABEL_HEIGHT + LABEL_PAD_Y)

local preferUserId

local function dd(msg)
    d("[" .. AreWeMounted.name .. "]  " .. msg)
end


-- -------------------------------------
-- --Default Settings--
-- -------------------------------------
local defaults = {
    pvpOnly = false,
    positionLocked = false,
    printToChat = true,
    colors = {
        ARM_MOUNT_STATE_UNKNOWN = {
            r = 1,
            g = 1,
            b = 1,
        },
        ARM_MOUNT_STATE_MOUNTED = {
            r = 0,
            g = 1,
            b = 0,
        },
        ARM_MOUNT_STATE_CAN_MOUNT = {
            r = 1,
            g = 1,
            b = 0,
        },
        ARM_MOUNT_STATE_IN_COMBAT = {
            r = 1,
            g = 0,
            b = 0,
        },
    },
}

local tlw = nil
local wm = GetWindowManager()
local mountControlGroup = nil
local UnitControl, UnitControlGroup
local groupControl


--------------------------
-- Unit Control
--------------------------
UnitControl = ZO_Object:Subclass()
function UnitControl:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function UnitControl:Initialize(index, parent)
    self.index = index
    self.parent = parent

    self.control = CreateControl(nil, parent, CT_CONTROL)
    self.control:SetDimensions(LABEL_WIDTH, LABEL_HEIGHT)
    local x = 0
    local y = (self.index - 1) * (LABEL_HEIGHT + LABEL_PAD_Y)
    self.control:ClearAnchors()
    self.control:SetAnchor(TOPLEFT, self.parent, TOPLEFT, x, y)

    self.nameControl = wm:CreateControl(nil, self.control, CT_LABEL)
    self.nameControl:SetAnchor(TOPLEFT, self.control, TOPLEFT, 0, 0)
    self.nameControl:SetDimensions(LABEL_WIDTH, LABEL_HEIGHT)
    self.nameControl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.nameControl:SetFont("$(GAMEPAD_MEDIUM_FONT)|" .. 20 .. "|soft-shadow-thick")
    self.nameControl:SetColor(1, 1, 1)
    self.nameControl:SetText("")
end

function UnitControl:SetHidden(hidden)
    self.control:SetHidden(hidden)
end

function UnitControl:SetText(name)
    if name then
        self.nameControl:SetText(name)
    else
        self.nameControl:SetText("")
    end
end

function UnitControl:UpdateStatus(status)
    if status == ARM_MOUNT_STATE_MOUNTED then
        self.nameControl:SetColor(AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_MOUNTED.r,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_MOUNTED.g,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_MOUNTED.b)
    elseif status == ARM_MOUNT_STATE_CAN_MOUNT then
        self.nameControl:SetColor(AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_CAN_MOUNT.r,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_CAN_MOUNT.g,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_CAN_MOUNT.b)
    elseif status == ARM_MOUNT_STATE_IN_COMBAT then
        self.nameControl:SetColor(AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_IN_COMBAT.r,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_IN_COMBAT.g,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_IN_COMBAT.b)
    else
        self.nameControl:SetColor(AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_UNKNOWN.r,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_UNKNOWN.g,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_UNKNOWN.b)
    end
end

--------------------------
-- Unit Control Group
--------------------------
UnitControlGroup = ZO_Object:Subclass()
function UnitControlGroup:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function UnitControlGroup:Initialize(tlc, tlw)
    self.control = tlc
    self.tlw = tlw
    self.unitControls = {}

    self.backdrop = wm:CreateControl(AreWeMounted.name .. "_backdrop", self.control, CT_BACKDROP)
    self.backdrop:SetDimensions(LABEL_WIDTH, GROUP_HEIGHT)
    self.backdrop:SetAnchor(TOPLEFT, self.control, TOPLEFT, 0, 0)
    self.backdropLabel = wm:CreateControl(AreWeMounted.name .. "_backdropLabel", self.backdrop, CT_LABEL)
    self.backdropLabel:SetDimensions(LABEL_WIDTH, LABEL_HEIGHT)
    self.backdropLabel:SetText("Are We Mounted")
    self.backdropLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.backdropLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.backdropLabel:SetAnchor(CENTER, self.backdrop, CENTER, 0, 0)
    self.backdropLabel:SetFont("$(GAMEPAD_MEDIUM_FONT)|" .. 40 .. "|soft-shadow-thick")
    self.backdropLabel:SetColor(1, 1, 1, .25)
    self:SetBackdropColors()

    self.control:SetDimensions(LABEL_WIDTH, GROUP_HEIGHT)
    self.control:ClearAnchors()
    self.control:SetAnchor(TOPLEFT, self.tlw, TOPLEFT, 0, 0)

    self:InitUnits()
end

function UnitControlGroup:InitUnits()
    for i = 1, GROUP_SIZE_MAX, 1 do
        local unit = self:GetUnit(i)
        unit:SetHidden(true)
    end
end

function UnitControlGroup:GetUnit(index)
    local unitControl = self.unitControls[index]
    if unitControl == nil then
        unitControl = UnitControl:New(index, self.control)
        self.unitControls[index] = unitControl
    end
    return unitControl
end

function UnitControlGroup:SetBackdropColors()
    if AreWeMounted.savedVars.positionLocked then
        self.backdrop:SetCenterColor(0, 0, 0, 0)
        self.backdrop:SetEdgeColor(0, 0, 0, 0)
        self.backdrop:SetHidden(true)
        self.backdropLabel:SetHidden(true)
    else
        self.backdrop:SetCenterColor(1, 0, 0, 0.5)
        self.backdrop:SetEdgeColor(1, 0, 0, 0.5)
        self.backdrop:SetHidden(false)
        self.backdropLabel:SetHidden(false)
    end
end

--------------------------
-- Settings Window
--------------------------
local function SaveLocation()
    AreWeMounted.savedVars.location = {}
    AreWeMounted.savedVars.location.x = tlw:GetLeft()
    AreWeMounted.savedVars.location.y = tlw:GetTop()
end

local function SetMovable(movable)
    tlw:SetMovable(movable)
    tlw:SetMouseEnabled(movable)
    groupControl:SetBackdropColors()
end


local function SetPositionLocked(isLocked)
    AreWeMounted.savedVars.positionLocked = isLocked
    SetMovable(not isLocked)
end

local function SetPvpOnly(pvpOnly)
    AreWeMounted.savedVars.pvpOnly = pvpOnly
    if pvpOnly and not IsPlayerInAvAWorld() then
        tlw:SetHidden(true)
        groupControl.control:SetHidden(true)
        groupControl.backdrop:SetHidden(true)
        groupControl.backdropLabel:SetHidden(true)
    else
        tlw:SetHidden(false)
        groupControl.control:SetHidden(false)
        if not AreWeMounted.savedVars.positionLocked then
            groupControl.backdrop:SetHidden(false)
            groupControl.backdropLabel:SetHidden(false)
        end
    end
end

local function GetColorForState(state)
    if state == ARM_MOUNT_STATE_MOUNTED then
        return AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_MOUNTED.r,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_MOUNTED.g,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_MOUNTED.b
    elseif state == ARM_MOUNT_STATE_CAN_MOUNT then
        return AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_CAN_MOUNT.r,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_CAN_MOUNT.g,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_CAN_MOUNT.b
    elseif state == ARM_MOUNT_STATE_IN_COMBAT then
        return AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_IN_COMBAT.r,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_IN_COMBAT.g,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_IN_COMBAT.b
    else
        return AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_UNKNOWN.r,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_UNKNOWN.g,
            AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_UNKNOWN.b
    end
end

local function SetColorForState(state, r, g, b)
    if state == ARM_MOUNT_STATE_MOUNTED then
        AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_MOUNTED.r = r
        AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_MOUNTED.g = g
        AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_MOUNTED.b = b
    elseif state == ARM_MOUNT_STATE_CAN_MOUNT then
        AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_CAN_MOUNT.r = r
        AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_CAN_MOUNT.g = g
        AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_CAN_MOUNT.b = b
    elseif state == ARM_MOUNT_STATE_IN_COMBAT then
        AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_IN_COMBAT.r = r
        AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_IN_COMBAT.g = g
        AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_IN_COMBAT.b = b
    else
        AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_UNKNOWN.r = r
        AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_UNKNOWN.g = g
        AreWeMounted.savedVars.colors.ARM_MOUNT_STATE_UNKNOWN.b = b
    end
end

local function CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = "Are We Mounted",
        displayName = "Are We Mounted",
        author = "@DaWeedle [PC NA]",
        version = AreWeMounted.version,
        slashCommand = "/arewemounted",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsPanel = LAM:RegisterAddonPanel("ARM_Settings", panelData)

    local optionsData = {
        [1] = {
            type = "checkbox",
            name = "Position Locked",
            tooltip = "Lock UI Position",
            getFunc = function() return AreWeMounted.savedVars.positionLocked end,
            setFunc = SetPositionLocked
        },

        [2] = {
            type = "checkbox",
            name = "PvP Only",
            tooltip = "Only Show in PvP Zones",
            getFunc = function() return AreWeMounted.savedVars.pvpOnly end,
            setFunc = SetPvpOnly
        },

        [3] = {
            type = "checkbox",
            name = "Print to Chat",
            tooltip = "Print message to chat when everyone is mounted",
            getFunc = function() return AreWeMounted.savedVars.printToChat end,
            setFunc = function(mode) AreWeMounted.savedVars.printToChat = mode end
        },

        [4] = {
            type = "colorpicker",
            name = "Mount State Mounted",
            getFunc = function() return GetColorForState(ARM_MOUNT_STATE_MOUNTED) end,
            setFunc = function(r, g, b) SetColorForState(ARM_MOUNT_STATE_MOUNTED, r, g, b) end,
            width = "full",
        },

        [5] = {
            type = "colorpicker",
            name = "Mount State Can Mount",
            getFunc = function() return GetColorForState(ARM_MOUNT_STATE_CAN_MOUNT) end,
            setFunc = function(r, g, b) SetColorForState(ARM_MOUNT_STATE_CAN_MOUNT, r, g, b) end,
            width = "full",
        },

        [6] = {
            type = "colorpicker",
            name = "Mount State In Combat",
            getFunc = function() return GetColorForState(ARM_MOUNT_STATE_IN_COMBAT) end,
            setFunc = function(r, g, b) SetColorForState(ARM_MOUNT_STATE_IN_COMBAT, r, g, b) end,
            width = "full",
        },

        [7] = {
            type = "colorpicker",
            name = "Mount State Unknown",
            getFunc = function() return GetColorForState(ARM_MOUNT_STATE_UNKNOWN) end,
            setFunc = function(r, g, b) SetColorForState(ARM_MOUNT_STATE_UNKNOWN, r, g, b) end,
            width = "full",
        },
    }

    LAM:RegisterOptionControls("ARM_Settings", optionsData)
end


--------------------------
-- Init UI
--------------------------
local function ARM_unitControls_Initialize()
    AreWeMounted.savedVars = ZO_SavedVars:NewAccountWide("AreWeMountedVars", AreWeMounted.savedVarsVer, nil, defaults)

    if IsConsoleUI() then
        preferUserId = tonumber(GetSetting(SETTING_TYPE_UI, UI_SETTING_PRIMARY_PLAYER_NAME_GAMEPAD)) ==
            PRIMARY_PLAYER_NAME_SETTING_PREFER_USERID
    else
        preferUserId = tonumber(GetSetting(SETTING_TYPE_UI, UI_SETTING_PRIMARY_PLAYER_NAME_KEYBOARD)) ==
            PRIMARY_PLAYER_NAME_SETTING_PREFER_USERID
    end

    tlw = wm:CreateTopLevelWindow("ARM_TLW")
    tlw:SetDimensions(LABEL_WIDTH, GROUP_HEIGHT)
    tlw:SetResizeToFitDescendents(true)
    tlw:ClearAnchors()
    if AreWeMounted.savedVars.location == nil then
        tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    else
        tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, AreWeMounted.savedVars.location.x, AreWeMounted.savedVars.location.y)
    end
    tlw:SetHandler('OnMoveStop', SaveLocation)
    tlw:SetDrawLayer(0)
    tlw:SetDrawLevel(0)
    tlw:SetHidden(false)

    tlc = wm:CreateControl("mountControlGroup", tlw, CT_CONTROL)
    groupControl = UnitControlGroup:New(tlc, tlw)

    CreateSettingsWindow()
end


--------------------------
-- Main
--------------------------
local function getNumMounted()
    local n = 0
    local activeMembers = 0
    local myZone = GetUnitZoneIndex("player")
    local isInAvAWorld = IsPlayerInAvAWorld()
    local index = 1

    for unitIdx = 1, GROUP_SIZE_MAX do
        local unitTag = "group" .. unitIdx
        if DoesUnitExist(unitTag) then
            local status = ARM_MOUNT_STATE_UNKNOWN
            local unitZone = GetUnitZoneIndex(unitTag)
            local unitControl = groupControl.unitControls[index]
            if IsUnitOnline(unitTag) and unitZone == myZone then
                local mounted
                mounted, _, _ = GetTargetMountedStateInfo(GetUnitName(unitTag))

                if mounted ~= MOUNTED_STATE_NOT_MOUNTED then
                    n = n + 1
                    status = ARM_MOUNT_STATE_MOUNTED
                elseif IsUnitInCombat(unitTag) then
                    status = ARM_MOUNT_STATE_IN_COMBAT
                else
                    status = ARM_MOUNT_STATE_CAN_MOUNT
                end
                activeMembers = activeMembers + 1
            else
                status = ARM_MOUNT_STATE_UNKNOWN
            end
            unitControl:UpdateStatus(status)
            if preferUserId then
                local displayName = GetUnitDisplayName(unitTag)
                unitControl:SetText(displayName)
            else
                local characterName = GetUnitName(unitTag)
                unitControl:SetText(characterName)
            end
            if AreWeMounted.savedVars.pvpOnly and not isInAvAWorld then
                unitControl:SetHidden(true)
            else
                unitControl:SetHidden(false)
            end
            index = index + 1
        end
    end

    -- Clear remaining controls
    for i = index, GROUP_SIZE_MAX do
        local unitControl = groupControl.unitControls[i]
        unitControl:SetHidden(true)
        unitControl:SetText("")
    end

    if n ~= nMounted then
        nMounted = n

        if AreWeMounted.savedVars.pvpOnly and not isInAvAWorld then
            return
        end

        if nMounted == activeMembers then
            if AreWeMounted.savedVars.printToChat then
                dd("Everyone is mounted! Giddy Up!")
            end
        end
    end
end

local function onSettingChanged(_, settingSystemType, settingId)
    local setting
    if IsConsoleUI() then
        setting = tonumber(GetSetting(SETTING_TYPE_UI, UI_SETTING_PRIMARY_PLAYER_NAME_GAMEPAD))
    else
        setting = tonumber(GetSetting(SETTING_TYPE_UI, UI_SETTING_PRIMARY_PLAYER_NAME_KEYBOARD))
    end
    preferUserId = (setting == PRIMARY_PLAYER_NAME_SETTING_PREFER_USERID)
end

local function onPlayerActivated(_, initial)
    if not isInit then
        isInit = true
    else
        EVENT_MANAGER:UnregisterForEvent(AreWeMounted.name, EVENT_PLAYER_ACTIVATED)
    end
    EVENT_MANAGER:RegisterForUpdate(AreWeMounted.name, 500, getNumMounted)
end


local function Initialize()
    EVENT_MANAGER:UnregisterForEvent(AreWeMounted.name, EVENT_ADD_ON_LOADED)

    ARM_unitControls_Initialize()
    EVENT_MANAGER:RegisterForEvent(AreWeMounted.name, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(AreWeMounted.name, EVENT_INTERFACE_SETTING_CHANGED, onSettingChanged)
    EVENT_MANAGER:AddFilterForEvent(AreWeMounted.name, EVENT_INTERFACE_SETTING_CHANGED,
        REGISTER_FILTER_SETTING_SYSTEM_TYPE, SETTING_TYPE_UI)


    SLASH_COMMANDS["/arewemounted"] = getNumMounted
end


local function OnAddOnLoaded(event, addonName)
    if addonName == AreWeMounted.name then
        Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(AreWeMounted.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
