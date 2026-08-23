local U = Ultivite
if not U then return end

U.Ownership = U.Ownership or {}
local O = U.Ownership

O.controlStates = O.controlStates or setmetatable({}, { __mode = "k" })
O.ownerControls = O.ownerControls or {}
O.resources = O.resources or {}
O.ownerResources = O.ownerResources or {}

local function safeHidden(control)
    if not control or type(control.IsHidden) ~= "function" then return nil end
    local ok, hidden = pcall(control.IsHidden, control)
    if not ok then return nil end
    return hidden == true
end

local function safeSetHidden(control, hidden)
    if not control or type(control.SetHidden) ~= "function" then return false end
    return pcall(control.SetHidden, control, hidden == true)
end

local function addOwnerIndex(index, owner, value)
    index[owner] = index[owner] or {}
    index[owner][value] = true
end

local function removeOwnerIndex(index, owner, value)
    local values = index[owner]
    if not values then return end
    values[value] = nil
    if next(values) == nil then index[owner] = nil end
end

function O.AcquireControl(owner, control)
    owner = tostring(owner or "")
    if owner == "" or not control or type(control.SetHidden) ~= "function" then return false end

    local state = O.controlStates[control]
    if not state then
        state = { baselineHidden = safeHidden(control), owners = {} }
        O.controlStates[control] = state
    end
    state.owners[owner] = true
    addOwnerIndex(O.ownerControls, owner, control)
    safeSetHidden(control, true)
    return true
end

function O.ReleaseControl(owner, control)
    owner = tostring(owner or "")
    local state = control and O.controlStates[control] or nil
    if not state or state.owners[owner] ~= true then return false end

    state.owners[owner] = nil
    removeOwnerIndex(O.ownerControls, owner, control)
    if next(state.owners) ~= nil then
        safeSetHidden(control, true)
        return true
    end

    if state.baselineHidden ~= nil then safeSetHidden(control, state.baselineHidden) end
    O.controlStates[control] = nil
    return true
end

function O.IsControlOwned(control, owner)
    local state = control and O.controlStates[control] or nil
    if not state then return false end
    if owner ~= nil then return state.owners[tostring(owner)] == true end
    return next(state.owners) ~= nil
end

function O.EnforceControl(control)
    if not O.IsControlOwned(control) then return false end
    safeSetHidden(control, true)
    return true
end

function O.AcquireResource(owner, key, captureFunc, applyFunc, restoreFunc)
    owner = tostring(owner or "")
    key = tostring(key or "")
    if owner == "" or key == "" or type(applyFunc) ~= "function" then return false end

    local state = O.resources[key]
    if not state then
        local baseline = nil
        if type(captureFunc) == "function" then
            local ok, value = pcall(captureFunc)
            if ok then baseline = value end
        end
        state = {
            baseline = baseline,
            owners = {},
            applyFunc = applyFunc,
            restoreFunc = restoreFunc,
        }
        O.resources[key] = state
    end
    state.owners[owner] = true
    addOwnerIndex(O.ownerResources, owner, key)
    pcall(state.applyFunc, state.baseline)
    return true
end

function O.ReleaseResource(owner, key)
    owner = tostring(owner or "")
    key = tostring(key or "")
    local state = O.resources[key]
    if not state or state.owners[owner] ~= true then return false end

    state.owners[owner] = nil
    removeOwnerIndex(O.ownerResources, owner, key)
    if next(state.owners) ~= nil then
        pcall(state.applyFunc, state.baseline)
        return true
    end

    if type(state.restoreFunc) == "function" then pcall(state.restoreFunc, state.baseline) end
    O.resources[key] = nil
    return true
end

function O.ReleaseOwner(owner)
    owner = tostring(owner or "")
    local controls = O.ownerControls[owner]
    if controls then
        local pending = {}
        for control in pairs(controls) do pending[#pending + 1] = control end
        for _, control in ipairs(pending) do O.ReleaseControl(owner, control) end
    end

    local resources = O.ownerResources[owner]
    if resources then
        local pending = {}
        for key in pairs(resources) do pending[#pending + 1] = key end
        for _, key in ipairs(pending) do O.ReleaseResource(owner, key) end
    end
end

function O.ReleaseAll()
    local owners = {}
    for owner in pairs(O.ownerControls) do owners[owner] = true end
    for owner in pairs(O.ownerResources) do owners[owner] = true end
    for owner in pairs(owners) do O.ReleaseOwner(owner) end
end

function O.IsOwnerActive(owner)
    owner = tostring(owner or "")
    return O.ownerControls[owner] ~= nil or O.ownerResources[owner] ~= nil
end

function O.IsAnyActive()
    return next(O.ownerControls) ~= nil or next(O.ownerResources) ~= nil
end

function O.GetStatusText()
    local owners = {}
    for owner in pairs(O.ownerControls) do owners[owner] = true end
    for owner in pairs(O.ownerResources) do owners[owner] = true end
    local names = {}
    for owner in pairs(owners) do names[#names + 1] = owner end
    table.sort(names)
    if #names == 0 then return "No temporary Ultivite overrides are active." end
    return "Active Ultivite override owners: " .. table.concat(names, ", ")
end
