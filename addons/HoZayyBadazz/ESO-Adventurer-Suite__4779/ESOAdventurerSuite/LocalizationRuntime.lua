-- ESO Adventurer Suite
-- v0.29.552 - runtime i18n integration.
-- Localizes Suite-owned controls after creation and wires the Modern UI,
-- bank grid, and character gear refresh paths into the central localization layer.

local EPC = ESOProgressionCoach
if not EPC or not EPC.I18N then return end
local I = EPC.I18N

local function localizeTree(control)
    if control and I.LocalizeControlTree then I:LocalizeControlTree(control, 0) end
end

local function isSuiteName(name)
    name = tostring(name or "")
    return name:find("^EAS") ~= nil or name:find("^EPC") ~= nil or name:find("^ESOProgressionCoach") ~= nil
end

function I:LocalizeTopLevelSuiteControls()
    local root = rawget(_G, "GuiRoot")
    if not root or type(root.GetNumChildren) ~= "function" or type(root.GetChild) ~= "function" then return end
    local ok, count = pcall(root.GetNumChildren, root)
    count = ok and tonumber(count) or 0
    for index = 1, count do
        local okChild, child = pcall(root.GetChild, root, index)
        if okChild and child then
            local name = ""
            if type(child.GetName) == "function" then
                local okName, value = pcall(child.GetName, child)
                if okName then name = tostring(value or "") end
            end
            if isSuiteName(name) then localizeTree(child) end
        end
    end
end

local function scheduleSweep(delay)
    if not EVENT_MANAGER then
        I:LocalizeTopLevelSuiteControls()
        return
    end
    local key = (EPC.name or "ESOAdventurerSuite") .. "_I18NSweep029552"
    EVENT_MANAGER:UnregisterForUpdate(key)
    EVENT_MANAGER:RegisterForUpdate(key, math.max(1, tonumber(delay) or 50), function()
        EVENT_MANAGER:UnregisterForUpdate(key)
        I:LocalizeTopLevelSuiteControls()
    end)
end

local function wrapMethod(object, methodName, marker, rootResolver)
    if type(object) ~= "table" or type(object[methodName]) ~= "function" or object[marker] then return end
    local base = object[methodName]
    object[methodName] = function(self, ...)
        local result = base(self, ...)
        local root = rootResolver and rootResolver(self) or nil
        if root then localizeTree(root) else scheduleSweep(1) end
        return result
    end
    object[marker] = true
end

-- Modern application: localize every newly created/lazily refreshed page.
local M = EPC.ModernAppUI
if type(M) == "table" then
    local function modernRoot(self) return self and self.window end
    wrapMethod(M, "Show", "_i18nShow029552", modernRoot)
    wrapMethod(M, "SetTab", "_i18nSetTab029552", modernRoot)
    wrapMethod(M, "RefreshCurrent", "_i18nRefresh029552", modernRoot)
    wrapMethod(M, "CreateShell", "_i18nCreateShell029552", modernRoot)
    if M.window then localizeTree(M.window) end
end

-- Bank grid: category/count labels are rebuilt as filters and modes change.
local B = EPC.BankGridUnifiedV2
if type(B) == "table" then
    local function bankRoot(self) return self and (self.root or self.frame) end
    wrapMethod(B, "Render", "_i18nRender029552", bankRoot)
    wrapMethod(B, "Refresh", "_i18nRefresh029552", bankRoot)
    if B.root then localizeTree(B.root) end
end

-- Character / companion equipment screen.
local G = EPC.CharacterGearScreen
if type(G) == "table" then
    local function gearRoot(self)
        if not self then return nil end
        return self.root or self.playerRoot or self.companionRoot or self.window
    end
    wrapMethod(G, "Refresh", "_i18nRefresh029552", gearRoot)
    wrapMethod(G, "RequestRefresh", "_i18nRequestRefresh029552", gearRoot)
end

-- Main Suite UI/HUD-owned top-level controls are localized once after activation.
if EVENT_MANAGER and EVENT_PLAYER_ACTIVATED then
    local eventName = (EPC.name or "ESOAdventurerSuite") .. "_I18NPlayerActivated029552"
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_PLAYER_ACTIVATED, function()
        scheduleSweep(250)
    end)
end

-- Scene changes can create lazy Suite controls. Do a single deferred sweep only
-- when a scene transition occurs; there is no permanent polling/update loop.
if SCENE_MANAGER and type(SCENE_MANAGER.RegisterCallback) == "function" then
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(_, _, newState)
        if newState == SCENE_SHOWN or newState == SCENE_SHOWING then scheduleSweep(80) end
    end)
end

scheduleSweep(1)
