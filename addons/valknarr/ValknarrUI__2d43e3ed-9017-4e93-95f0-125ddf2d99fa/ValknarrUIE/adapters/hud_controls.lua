-- Native HUD controls beyond Health/Magicka/Stamina/chat.
-- Locate by well-known ESO globals (same idea as FAB+ moving ACTION_BAR).
-- Missing or hidden pieces fall back to catalog silhouettes.

ValknarrUIEHudControls = ValknarrUIEHudControls or {}

local Hud = ValknarrUIEHudControls
local Log = ValknarrUIELog
local Adapter = ValknarrUIEPlayerAttributes

Hud.savedHidden = Hud.savedHidden or {}

-- Approximate default centers on a 16:9 HUD. First /uiedit prefers live
-- positions; these are only used when the control cannot be measured.
local SPECS = {
    {
        id = "actionbar",
        name = "Action Bar",
        candidates = { "ZO_ActionBar1", "ACTION_BAR", "ZO_ActionBar" },
        default = { x = 0.50, y = 0.94 },
    },
    {
        id = "compass",
        name = "Compass",
        candidates = { "ZO_CompassFrame", "ZO_Compass" },
        managers = { "COMPASS_FRAME" },
        default = { x = 0.50, y = 0.05 },
    },
    {
        id = "exp",
        name = "Experience",
        candidates = { "ZO_PlayerProgressBar" },
        managers = { "PLAYER_PROGRESS_BAR" },
        default = { x = 0.50, y = 0.02 },
    },
    {
        id = "target",
        name = "Target",
        candidates = { "ZO_TargetUnitFramereticleover", "ZO_TargetUnitFrame" },
        default = { x = 0.50, y = 0.20 },
    },
    {
        id = "quest",
        name = "Quest Tracker",
        candidates = { "ZO_FocusedQuestTrackerPanel", "ZO_FocusedQuestTracker" },
        managers = { "FOCUSED_QUEST_TRACKER" },
        default = { x = 0.88, y = 0.22 },
    },
    {
        id = "synergy",
        name = "Synergy",
        candidates = { "ZO_SynergyTopLevelContainer", "ZO_SynergyTopLevel", "ZO_Synergy" },
        managers = { "SYNERGY" },
        default = { x = 0.50, y = 0.58 },
    },
    {
        id = "buffs",
        name = "Buffs",
        candidates = {
            "ZO_BuffDebuffTopLevelSelfContainer",
            "ZO_BuffDebuffTopLevel",
            "ZO_BuffDebuff",
            "ZO_PlayerBuffDebuff",
        },
        managers = { "BUFF_DEBUFF", "BUFF_DEBUFF_FRAGMENT" },
        preferChild = "SelfContainer",
        default = { x = 0.50, y = 0.78 },
    },
    {
        id = "equipment",
        name = "Equipment",
        candidates = { "ZO_HUDEquipmentStatus" },
        managers = { "HUD_EQUIPMENT_STATUS" },
        default = { x = 0.42, y = 0.90 },
    },
    {
        id = "mountstamina",
        name = "Mount Stamina",
        candidates = { "ZO_PlayerAttributeMountStamina" },
        default = { x = 0.50, y = 0.74 },
    },
    {
        id = "werewolf",
        name = "Werewolf",
        candidates = { "ZO_PlayerAttributeWerewolf" },
        default = { x = 0.50, y = 0.70 },
    },
}

local function IsMovableControl(object)
    return object ~= nil and type(object.SetAnchor) == "function"
end

local function NamedChild(control, childName)
    if not control or not childName or type(control.GetNamedChild) ~= "function" then
        return nil
    end
    local ok, child = pcall(control.GetNamedChild, control, childName)
    if ok and IsMovableControl(child) then
        return child
    end
    return nil
end

local function FromManager(manager, label)
    if not manager then
        return nil, nil
    end
    if IsMovableControl(manager) then
        return manager, label
    end
    if IsMovableControl(manager.control) then
        return manager.control, label .. ".control"
    end
    if type(manager.GetControl) == "function" then
        local ok, control = pcall(manager.GetControl, manager)
        if ok and IsMovableControl(control) then
            return control, label .. ":GetControl"
        end
    end
    return nil, nil
end

local function PreferChild(control, source, childName)
    if not childName then
        return control, source
    end
    local child = NamedChild(control, childName)
    if child then
        return child, (source or "parent") .. "/" .. childName
    end
    return control, source
end

function Hud:Find(id)
    for index = 1, #SPECS do
        local spec = SPECS[index]
        if spec.id == id then
            for _, name in ipairs(spec.candidates or {}) do
                local control = _G[name]
                if IsMovableControl(control) then
                    control, name = PreferChild(control, name, spec.preferChild)
                    if Log then
                        Log:Debug("Locate " .. id .. " via " .. name)
                    end
                    return control, name
                end
            end
            for _, name in ipairs(spec.managers or {}) do
                local control, source = FromManager(_G[name], name)
                if control then
                    control, source = PreferChild(control, source, spec.preferChild)
                    if Log then
                        Log:Debug("Locate " .. id .. " via " .. source)
                    end
                    return control, source
                end
            end
            if Log then
                Log:Debug("Locate missed " .. id)
            end
            return nil, "missing"
        end
    end
    return nil, "unknown"
end

function Hud:Prepare(id)
    local control = self:Find(id)
    if not control then
        return false
    end
    local hidden = nil
    if type(control.IsHidden) == "function" then
        local ok, value = pcall(control.IsHidden, control)
        if ok and type(value) == "boolean" then
            hidden = value
        end
    end
    self.savedHidden[id] = hidden
    if type(control.SetHidden) == "function" then
        pcall(control.SetHidden, control, false)
    end
    return true
end

function Hud:EndPreview(id)
    local control = self:Find(id)
    local hidden = self.savedHidden[id]
    self.savedHidden[id] = nil
    if control and hidden ~= nil and type(control.SetHidden) == "function" then
        pcall(control.SetHidden, control, hidden)
    end
end

function Hud:Apply(control, position)
    if type(position) ~= "table" then
        return false
    end
    local target = control
    if not target then
        return false
    end
    return Adapter:Apply(target, position.x, position.y, position.w, position.h)
end

function Hud:Register(lib, addonName)
    if not lib or type(lib.RegisterElement) ~= "function" then
        return
    end
    for index = 1, #SPECS do
        local spec = SPECS[index]
        local id = spec.id
        lib:RegisterElement(addonName, id, {
            name = spec.name,
            locate = function()
                return Hud:Find(id)
            end,
            resizable = true,
            apply = function(control, position)
                return Hud:Apply(control, position)
            end,
            preparePreview = function()
                Hud:Prepare(id)
            end,
            endPreview = function()
                Hud:EndPreview(id)
            end,
            default = {
                x = spec.default.x,
                y = spec.default.y,
            },
        })
    end
end

return Hud
