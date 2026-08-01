Nvk3UT = Nvk3UT or {}

local Category = {}
Nvk3UT.RecentCategory = Category

local Diagnostics = Nvk3UT and Nvk3UT.Diagnostics
local Utils = Nvk3UT and Nvk3UT.Utils
local Ach = Nvk3UT and Nvk3UT.Achievements
local Data = Nvk3UT and Nvk3UT.RecentData

local state = {
    parent = nil,
    host = nil,
    container = nil,
}

local function safeCall(func, ...)
    local SafeCall = Nvk3UT and Nvk3UT.SafeCall
    if type(SafeCall) == "function" then
        return SafeCall(func, ...)
    end

    if type(func) ~= "function" then
        return nil
    end

    local results = { pcall(func, ...) }
    if not results[1] then
        return nil
    end

    table.remove(results, 1)
    return unpack(results)
end

local function logShim(action)
    if Diagnostics and Diagnostics.Debug then
        Diagnostics.Debug("Recent SHIM -> %s", tostring(action))
    end
end

local function isDebugEnabled()
    local utils = Utils or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        return utils.IsDebugEnabled()
    end
    return false
end

local function ensureData()
    if Data and Data.InitSavedVars then
        safeCall(Data.InitSavedVars)
    end
end

local function iterateProgress()
    ensureData()
    if not (Data and Data.IterateProgress) then
        return {}
    end

    local iterator, stateValue, key = safeCall(Data.IterateProgress)
    if type(iterator) ~= "function" then
        return {}
    end

    local entries = {}
    for rawId, _ in iterator, stateValue, key do
        entries[#entries + 1] = tonumber(rawId) or rawId
    end

    return entries
end

local function resolveContainer()
    if state.container then
        return state.container
    end

    local host = state.host
    if not host or type(host) ~= "userdata" then
        return nil
    end

    local wm = WINDOW_MANAGER
    if not wm then
        return nil
    end

    local control = wm:CreateControl(nil, host, CT_CONTROL)
    control:SetHidden(true)
    control:SetResizeToFitDescendents(true)
    control:SetAnchor(TOPLEFT, host, TOPLEFT, 0, 0)
    control:SetAnchor(TOPRIGHT, host, TOPRIGHT, 0, 0)

    state.container = control
    return control
end

local function toggleContainerHidden(isVisible)
    local container = state.container or state.host
    if container and container.SetHidden then
        container:SetHidden(isVisible == false)
    end
end

local function hasRecentEntries()
    ensureData()

    if not Data then
        return false
    end

    if Data.ListConfigured then
        local list = safeCall(Data.ListConfigured)
        if type(list) == "table" and #list > 0 then
            return true
        end
    end

    if Data.List then
        local list = safeCall(Data.List)
        if type(list) == "table" and #list > 0 then
            return true
        end
    end

    local entries = iterateProgress()
    return #entries > 0
end

---Initialize the recent category container.
---@param parentOrContainer Control|any
---@return any
function Category:Init(parentOrContainer)
    state.parent = parentOrContainer
    state.host = nil
    state.container = nil

    if type(parentOrContainer) == "userdata" then
        state.host = parentOrContainer
        state.container = parentOrContainer
    elseif parentOrContainer and type(parentOrContainer.GetControl) == "function" then
        local ok, control = pcall(parentOrContainer.GetControl, parentOrContainer)
        if ok and type(control) == "userdata" then
            state.host = control
            state.container = control
        end
    end

    if not state.host and parentOrContainer and type(parentOrContainer.GetNamedChild) == "function" then
        state.host = parentOrContainer
    end

    if not state.container then
        state.container = resolveContainer()
    end

    return state.container or state.host or parentOrContainer
end

---Refresh the recent category view.
---@return any
function Category:Refresh()
    local container = state.container or resolveContainer()
    if not container then
        return nil
    end

    local visible = hasRecentEntries()
    toggleContainerHidden(not visible)

    return container
end

---Set the visibility of the recent category container.
---@param isVisible boolean
function Category:SetVisible(isVisible)
    toggleContainerHidden(not isVisible)
end

---Get the measured height of the recent container.
---@return number
function Category:GetHeight()
    local container = state.container or state.host
    if container and container.GetHeight then
        return container:GetHeight()
    end
    return 0
end

---Remove all completed achievements from the recent list.
---@return boolean removedAny
function Category:CleanupCompleted()
    if not (Ach and Ach.IsComplete) then
        return false
    end

    ensureData()
    if not (Data and Data.Clear) then
        return false
    end

    local entries = iterateProgress()
    if #entries == 0 then
        return false
    end

    local removedIds = {}
    for _, id in ipairs(entries) do
        if type(id) == "number" and Ach.IsComplete(id) then
            Data.Clear(id)
            removedIds[#removedIds + 1] = id
            if isDebugEnabled() then
                Utils.d(string.format("[Recent] Cleaned completed achievement %d", id))
            end
        end
    end

    if #removedIds > 0 then
        local ui = Nvk3UT and Nvk3UT.UI
        if ui and ui.RefreshAchievements then
            safeCall(ui.RefreshAchievements)
        end
        if ui and ui.UpdateStatus then
            safeCall(ui.UpdateStatus)
        end
        return true
    end

    return false
end

local Shim = {}
Nvk3UT.Recent = Shim

function Shim.Init(...)
    logShim("Init")
    if type(Category.Init) ~= "function" then
        return nil
    end
    return safeCall(Category.Init, Category, ...)
end

function Shim.Refresh(...)
    logShim("Refresh")
    if type(Category.Refresh) ~= "function" then
        return nil
    end
    return safeCall(Category.Refresh, Category, ...)
end

function Shim.SetVisible(...)
    logShim("SetVisible")
    if type(Category.SetVisible) ~= "function" then
        return nil
    end
    return safeCall(Category.SetVisible, Category, ...)
end

function Shim.GetHeight(...)
    if type(Category.GetHeight) ~= "function" then
        return 0
    end
    local height = safeCall(Category.GetHeight, Category, ...)
    return tonumber(height) or 0
end

function Shim.CleanupCompleted(...)
    logShim("CleanupCompleted")
    if type(Category.CleanupCompleted) ~= "function" then
        return false
    end
    local result = safeCall(Category.CleanupCompleted, Category, ...)
    return result and true or false
end

return Category
