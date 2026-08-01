Nvk3UT = Nvk3UT or {}

local Category = {}
Nvk3UT.CompletedCategory = Category

local Diagnostics = Nvk3UT and Nvk3UT.Diagnostics
local CompletedData = Nvk3UT and Nvk3UT.CompletedData

local state = {
    parent = nil,
    host = nil,
    container = nil,
    createdContainer = false,
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
        Diagnostics.Debug("Completed SHIM -> %s", tostring(action))
    end
end

local function resolveCompletedData()
    if not CompletedData then
        CompletedData = Nvk3UT and Nvk3UT.CompletedData
    end
    return CompletedData
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
    control:SetResizeToFitDescendents(true)
    control:SetAnchor(TOPLEFT, host, TOPLEFT, 0, 0)
    control:SetAnchor(TOPRIGHT, host, TOPRIGHT, 0, 0)

    state.container = control
    state.createdContainer = true
    return control
end

local function toggleContainerHidden(isVisible)
    local container = state.container or state.host
    if container and container.SetHidden then
        container:SetHidden(isVisible == false)
    end
end

local function computeCompletedCount()
    local data = resolveCompletedData()
    if not data then
        return 0
    end

    if type(data.GetSubcategoryList) ~= "function" then
        return 0
    end

    local _, keys = safeCall(data.GetSubcategoryList, data)
    if type(keys) ~= "table" then
        keys = {}
    end

    local total = 0
    if type(data.ListForKey) == "function" then
        for index = 1, #keys do
            local list = safeCall(data.ListForKey, data, keys[index])
            if type(list) == "table" then
                total = total + #list
            end
        end
    end

    return total
end

---Initialize the completed category container.
---@param parentOrContainer Control|any
---@return any
function Category:Init(parentOrContainer)
    state.parent = parentOrContainer
    state.host = nil
    state.container = nil
    state.createdContainer = false

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
        local ok, child = pcall(parentOrContainer.GetNamedChild, parentOrContainer, "Completed")
        if ok and type(child) == "userdata" then
            state.host = child
            state.container = child
        else
            state.host = parentOrContainer
        end
    end

    if not state.container then
        state.container = resolveContainer()
    end

    return state.container or state.host or parentOrContainer
end

---Refresh the completed category view.
---@return any
function Category:Refresh()
    local container = state.container or resolveContainer()
    if not container then
        return nil
    end

    local count = computeCompletedCount()
    toggleContainerHidden(count > 0)

    return container
end

---Set the visibility of the completed category container.
---@param isVisible boolean
function Category:SetVisible(isVisible)
    toggleContainerHidden(isVisible)
end

---Get the measured height of the completed container.
---@return number
function Category:GetHeight()
    local container = state.container or state.host
    if container and container.GetHeight then
        return container:GetHeight()
    end
    return 0
end

local Shim = {}
Nvk3UT.Completed = Shim

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

return Category
