Nvk3UT = Nvk3UT or {}

local Category = {}
Nvk3UT.TodoCategory = Category

local Diagnostics = Nvk3UT and Nvk3UT.Diagnostics
local List = Nvk3UT and Nvk3UT.AchievementList
local TodoData = Nvk3UT and Nvk3UT.TodoData

local state = {
    parent = nil,
    host = nil,
    container = nil,
    lastSection = nil,
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
        Diagnostics.Debug("Todo SHIM -> %s", tostring(action))
    end
end

local function ensureTodoData()
    if TodoData and TodoData.InitSavedVars then
        safeCall(TodoData.InitSavedVars)
    end
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

local function fetchTodoSection()
    local listModule = List or (Nvk3UT and Nvk3UT.AchievementList)
    if not listModule then
        return nil
    end

    if type(listModule.GetSection) ~= "function" then
        return nil
    end

    local section = safeCall(listModule.GetSection, listModule, "todo")
    if section then
        state.lastSection = section
    end
    return section
end

local function hasTodoEntries(section)
    section = section or state.lastSection or fetchTodoSection()
    if not section then
        return false
    end

    if type(section.total) == "number" then
        return section.total > 0
    end

    local ids = section.ids
    return type(ids) == "table" and #ids > 0
end

---Initialize the to-do category container.
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

---Refresh the to-do category view.
---@return any
function Category:Refresh()
    local container = state.container or resolveContainer()
    if not container then
        return nil
    end

    ensureTodoData()
    local section = fetchTodoSection()

    local hasEntries
    if section then
        hasEntries = hasTodoEntries(section)
    else
        local count = 0
        if TodoData and TodoData.CountOpen then
            count = safeCall(TodoData.CountOpen) or 0
        elseif TodoData and TodoData.ListAllOpen then
            local list = safeCall(TodoData.ListAllOpen, 0, false)
            if type(list) == "table" then
                count = #list
            end
        end
        hasEntries = (tonumber(count) or 0) > 0
    end

    toggleContainerHidden(not hasEntries)
    return container
end

---Set the visibility of the to-do category container.
---@param isVisible boolean
function Category:SetVisible(isVisible)
    toggleContainerHidden(not isVisible)
end

---Get the measured height of the to-do container.
---@return number
function Category:GetHeight()
    local container = state.container or state.host
    if container and container.GetHeight then
        return container:GetHeight()
    end
    return 0
end

local Shim = {}
Nvk3UT.Todo = Shim

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
