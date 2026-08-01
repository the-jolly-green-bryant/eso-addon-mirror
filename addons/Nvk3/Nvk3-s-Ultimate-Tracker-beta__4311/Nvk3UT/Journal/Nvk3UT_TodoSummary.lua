Nvk3UT = Nvk3UT or {}

local Summary = {}
Nvk3UT.TodoSummary = Summary

local Diagnostics = Nvk3UT and Nvk3UT.Diagnostics

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
        Diagnostics.Debug("TodoSummary SHIM -> %s", tostring(action))
    end
end

local state = {
    parent = nil,
}

---Initialize the to-do summary placeholder.
---@param parentOrContainer any
---@return any
function Summary:Init(parentOrContainer)
    state.parent = parentOrContainer
    return parentOrContainer
end

---Refresh the to-do summary placeholder.
---@return any
function Summary:Refresh()
    return state.parent
end

---Set the visibility of the to-do summary placeholder.
---@param _isVisible boolean
function Summary:SetVisible(_isVisible)
    -- Intentionally left blank. The summary does not render any controls today.
end

---Get the measured height of the to-do summary placeholder.
---@return number
function Summary:GetHeight()
    return 0
end

function Nvk3UT.EnableTodoSummary(...)
    logShim("Init")
    if type(Summary.Init) ~= "function" then
        return nil
    end
    return safeCall(Summary.Init, Summary, ...)
end

function Nvk3UT.RefreshTodoSummary(...)
    logShim("Refresh")
    if type(Summary.Refresh) ~= "function" then
        return nil
    end
    return safeCall(Summary.Refresh, Summary, ...)
end

function Nvk3UT.SetTodoSummaryVisible(...)
    logShim("SetVisible")
    if type(Summary.SetVisible) ~= "function" then
        return nil
    end
    return safeCall(Summary.SetVisible, Summary, ...)
end

function Nvk3UT.GetTodoSummaryHeight(...)
    if type(Summary.GetHeight) ~= "function" then
        return 0
    end
    local height = safeCall(Summary.GetHeight, Summary, ...)
    return tonumber(height) or 0
end

return Summary
