if Binder then return end
Binder = {}
local Binder = Binder

-- Localize builtin functions we use 
local ipairs = ipairs
local next = next
local pairs = pairs
local tinsert = table.insert

-- Localize ESO API functions we use
local d = d
local strjoin = zo_strjoin
local strsplit = zo_strsplit
local GetNumActionLayers = GetNumActionLayers
local GetActionLayerInfo = GetActionLayerInfo
local GetActionLayerCategoryInfo = GetActionLayerCategoryInfo
local GetActionInfo = GetActionInfo
local GetActionIndicesFromName = GetActionIndicesFromName

local function print(...)
    d(strjoin("", ...))
end

Binder.defaults = {
    ["bindings"] = {},
    ["auto"] = false,
    ["autoSets"] = {},
}

Binder.debug = {}

function Binder.BuildActionTables()
    local actionHierarchy = {}
    local actionNames = {}
    local layers = GetNumActionLayers()
    for layerIndex=1, layers do
        local layerName, categories = GetActionLayerInfo(layerIndex)
        local layer = {}
        for categoryIndex=1, categories do
            local category = {}
            local categoryName, actions = GetActionLayerCategoryInfo(layerIndex, categoryIndex)
            for actionIndex=1, actions do
                local actionName, isRebindable, isHidden = GetActionInfo(layerIndex, categoryIndex, actionIndex)
                if isRebindable then
                    local action = {
                        ["name"] = actionName,
                        ["rebind"] = isRebindable,
                        ["hidden"] = isHidden,
                    }
                    category[actionIndex] = action
                    tinsert(actionNames, actionName)
                end
            end
            if next(category) ~= nil then
                category["name"] = categoryName
                layer[categoryIndex] = category
            end
        end
        if next(layer) ~= nil then
            layer["name"] = layerName
            actionHierarchy[layerIndex] = layer
        end
    end
    Binder.actionHierarchy = actionHierarchy
    Binder.actionNames = actionNames
end

function Binder.BuildBindingsTable()
    if not Binder.actionNames then Binder.BuildActionTables() end
    local bindings = {}
    local bindCount = 0
    local maxBindings = GetMaxBindingsPerAction()
    for index, actionName in ipairs(Binder.actionNames) do
        local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName(actionName)
        local actionBindings = {}
        for bindIndex=1, maxBindings do
            local keyCode, mod1, mod2, mod3, mod4 = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, bindIndex)
            if keyCode ~= 0 then
                local bind = {
                    ["keyCode"] = keyCode,
                    ["mod1"] = mod1,
                    ["mod2"] = mod2,
                    ["mod3"] = mod3,
                    ["mod4"] = mod4,
                }
                tinsert(actionBindings, bind)
                bindCount = bindCount + 1
            end
        end
        bindings[actionName] = actionBindings
    end
    Binder.bindings = bindings
    Binder.bindCount = bindCount
end

function Binder.RestoreBindingsFromTable()
    local bindCount = 0
    local attemptedBindCount = 0
    local skippedBindCount = 0
    local maxBindings = GetMaxBindingsPerAction()
    for actionName, actionBindings in pairs(Binder.bindings) do
        local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName(actionName)
        if layerIndex and categoryIndex and actionIndex then
            CallSecureProtected("UnbindAllKeysFromAction", layerIndex, categoryIndex, actionIndex)
            for bindingIndex, bind in ipairs(actionBindings) do
                if bindingIndex <= maxBindings then
                    attemptedBindCount = attemptedBindCount + 1
                    CallSecureProtected("BindKeyToAction", layerIndex, categoryIndex, actionIndex, bindingIndex, bind["keyCode"], bind["mod1"], bind["mod2"], bind["mod3"], bind["mod4"])
                    bindCount = bindCount + 1
                else
                    skippedBindCount = skippedBindCount + 1
                end
            end
        else
            skippedBindCount = skippedBindCount + 1
        end
    end
    Binder.debug.bindCount = bindCount
    Binder.debug.attemptedBindCount = attemptedBindCount
    Binder.debug.skippedBindCount = skippedBindCount
    Binder.debug.maxBindingsPerAction = maxBindings
end

function Binder.SaveBindings(bindSetName, isSilent)
    if bindSetName == nil or bindSetName == "" then
        print("Usage: /binder save <set name>")
        return
    end
    Binder.debug.savingSet = bindSetName
    Binder.BuildBindingsTable()
    
    -- Update any existing bind set as a set union, or create new
    local bindSet = Binder.savedVariables.bindings[bindSetName] or {}
    for bindName, binding in pairs(Binder.bindings) do
        bindSet[bindName] = binding
    end
    Binder.savedVariables.bindings[bindSetName] = bindSet
    
    if not isSilent then
        print("Saved ", Binder.bindCount, " bindings to bind set '", bindSetName, "'.")
    end
    local character = GetUnitName("player")
    Binder.savedVariables.autoSets[character] = bindSetName
    Binder.debug.savedSet = bindSetName
end

function Binder.LoadBindings(bindSetName, isSilent)
    if bindSetName == nil or bindSetName == "" then
        print("Usage: /binder load <set name>")
        return
    end
    if Binder.savedVariables.bindings[bindSetName] == nil then
        print("Bind set '", bindSetName, "' does not exist.")
        return
    end
    if IsUnitInCombat("player") then
        print("Cannot load bind set - in combat. Please try again out of combat.")
        return
    end
    Binder.debug.loadingSet = bindSetName
    Binder.bindings = Binder.savedVariables.bindings[bindSetName]
    Binder.RestoreBindingsFromTable()
    if not isSilent then
        print("Loaded ", Binder.bindCount, " bindings from bind set '", bindSetName, "'.")
    end
    local character = GetUnitName("player")
    Binder.savedVariables.autoSets[character] = bindSetName
    Binder.debug.loadedSet = bindSetName
end

function Binder.ListBindings()
    local sets = {}
    for setName in pairs(Binder.savedVariables.bindings) do
        table.insert(sets, setName)
    end
    table.sort(sets)
    print("Bind sets saved:")
    for i,setName in ipairs(sets) do
        print("- ", setName)
    end
end

function Binder.DeleteBindings(bindSetName)
    if bindSetName == nil or bindSetName == "" then
        print("Usage: /binder delete <set name>")
        return
    end
    if Binder.savedVariables.bindings[bindSetName] == nil then
        print("Bind set '", bindSetName, "' does not exist.")
        return
    end
    Binder.savedVariables.bindings[bindSetName] = nil
    print("Deleted bind set '", bindSetName, "'.")
end

function Binder.SetAuto(newValue)
    if newValue == "on" then
        Binder.savedVariables.auto = true
        print("Enabled automatic bind set updates.")
        Binder.LoadAutomaticBindings()
    elseif newValue == "off" then
        Binder.savedVariables.auto = false
        print("Disabled automatic bind set updates.")
    else
        if Binder.savedVariables.auto then
            print("Automatic bind set updates are on (disable with /binder auto off).")
        else
            print("Automatic bind set updates are off (enable with /binder auto on).")
        end
        
        local character = GetUnitName("player")
        local setName = Binder.savedVariables.autoSets[character]
        if setName ~= nil then
            print("Currently active set: ", setName)
        end
    end
end

function Binder.SaveAutomaticBindings(isSilent)
    -- No-op if automatic mode is disabled.
    if not Binder.savedVariables.auto then return end
    
    local character = GetUnitName("player")
    local setName = Binder.savedVariables.autoSets[character]
    
    if setName == nil then
        setName = character:gsub(" ", "-") .. "-auto"
        Binder.savedVariables.autoSets[character] = setName
    end
    
    Binder.debug.autoSavingSet = setName
    Binder.SaveBindings(setName, isSilent)
    Binder.debug.autoSavedSet = setName
end

function Binder.LoadAutomaticBindings(isSilent)
    -- No-op if automatic mode is disabled.
    if not Binder.savedVariables.auto then return end
    
    local character = GetUnitName("player")
    local setName = Binder.savedVariables.autoSets[character]
    
    if setName ~= nil then
        Binder.debug.autoLoadingSet = setName
        Binder.LoadBindings(setName, isSilent)
        Binder.debug.autoLoadedSet = setName
    else
        -- If there isn't a set to load, but automatic mode is on,
        -- create a new set.
        Binder.SaveAutomaticBindings(isSilent)
    end
end

function Binder.OnKeybindingSetOrCleared()
    -- Silently update active bind set
    Binder.SaveAutomaticBindings(true)
end

function Binder.OnKeybindingsLoaded()
    -- Silently load active bind set
    Binder.LoadAutomaticBindings(true)
end

function Binder.RegisterEvents()
    EVENT_MANAGER:RegisterForEvent("Binder", EVENT_KEYBINDINGS_LOADED, Binder.OnKeybindingsLoaded)
    EVENT_MANAGER:RegisterForEvent("Binder", EVENT_KEYBINDING_SET, Binder.OnKeybindingSetOrCleared)
    EVENT_MANAGER:RegisterForEvent("Binder", EVENT_KEYBINDING_CLEARED, Binder.OnKeybindingSetOrCleared)
end

Binder.commands = {
    ["build"] = Binder.BuildBindingsTable,
    ["save"] = Binder.SaveBindings,
    ["load"] = Binder.LoadBindings,
    ["list"] = Binder.ListBindings,
    ["delete"] = Binder.DeleteBindings,
    ["auto"] = Binder.SetAuto,
}

function Binder.SlashCommandHelp()
    print("Binder usage:")
    print("- /binder save <set name> (saves current keybindings)")
    print("- /binder load <set name> (loads specified keybindings)")
    print("- /binder list (lists all saved bind sets)")
    print("- /binder delete <set name> (deletes specified keybindings)")
    print("- /binder auto [on||off] (lists or sets automatic mode)")
end

function Binder.SlashCommand(argtext)
    local args = {strsplit(" ", argtext)}
    if next(args) == nil then
        Binder.SlashCommandHelp()
        return
    end
    
    local command = Binder.commands[args[1]]
    if not command then
        print("Binder: unknown command '", args[1], "'.")
        Binder.SlashCommandHelp()
        return
    end
    
    -- Call the selected function with everything except the original command
    command(unpack(args, 2))
end

function Binder.OnAddOnLoaded(event, addonName)
    if addonName ~= "Binder" then return end
    
    Binder.savedVariables = ZO_SavedVars:NewAccountWide("Binder_SavedVariables", 1, "default", Binder.defaults)
    
    -- Silently load the active bind set, if automatic mode is on.
    Binder.LoadAutomaticBindings(true)
    
    Binder.RegisterEvents()
end

EVENT_MANAGER:RegisterForEvent("Binder", EVENT_ADD_ON_LOADED, Binder.OnAddOnLoaded)

if WF_SlashCommand ~= nil then
    -- Register via Wykkyd's framework for those who use it, to allow macroing
    WF_SlashCommand("binder", Binder.SlashCommand)
else
    -- But don't require the framework.
    SLASH_COMMANDS["/binder"] = Binder.SlashCommand
end