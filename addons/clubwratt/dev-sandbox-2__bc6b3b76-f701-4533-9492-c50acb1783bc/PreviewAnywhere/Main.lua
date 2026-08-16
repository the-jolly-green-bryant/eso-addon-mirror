local PreviewAnywhere = PreviewAnywhere

-- Registered at file scope (not inside Initialize) so "/pva debug" works even
-- when EVENT_ADD_ON_LOADED never fires with our name or Initialize crashes.
SLASH_COMMANDS["/pva"] = function(args)
    PreviewAnywhere.SlashCommandActions.HandleCommand(args)
end
SLASH_COMMANDS["/previewanywhere"] = SLASH_COMMANDS["/pva"]

---Run one module Initialize, capturing rather than propagating errors so a
---single failure can't silently disable the remaining modules.
---@param moduleName string
---@param initialize fun()
local function SafeInitialize(moduleName, initialize)
    local ok, err = pcall(initialize)
    if not ok then
        table.insert(PreviewAnywhere.diagnostics.initErrors, string.format("%s: %s", moduleName, tostring(err)))
    end
end

local function Initialize()
    local diagnostics = PreviewAnywhere.diagnostics
    if diagnostics.initialized then
        return
    end
    diagnostics.initialized = true

    local State = PreviewAnywhere.State

    PreviewAnywhere.state = State.Create()
    PreviewAnywhere.state.savedVars = ZO_SavedVars:NewAccountWide(
        PreviewAnywhere.savedVarsName,
        PreviewAnywhere.savedVarsVersion,
        nil,
        PreviewAnywhere.state.savedVars
    )

    -- All integrations target the gamepad UI, which is the only UI on console.
    if not (ITEM_PREVIEW_GAMEPAD and ITEM_PREVIEW_LIST_HELPER_GAMEPAD) then
        table.insert(diagnostics.initErrors, "gamepad item preview system not available")
        PreviewAnywhere.Log("ERROR: gamepad item preview system not available; addon inactive")
        return
    end

    SafeInitialize("PreviewActions", PreviewAnywhere.PreviewActions.Initialize)
    SafeInitialize("BankActions", PreviewAnywhere.BankActions.Initialize)
    SafeInitialize("LinkActions", PreviewAnywhere.LinkActions.Initialize)

    PreviewAnywhere.Log(string.format("Loaded v%s", PreviewAnywhere.version))
end

EVENT_MANAGER:RegisterForEvent(PreviewAnywhere.name, EVENT_ADD_ON_LOADED, function(_eventId, addonName)
    -- Record every name so "/pva debug" can reveal what the console actually
    -- reports for dev-slot content (it may not match our manifest name).
    table.insert(PreviewAnywhere.diagnostics.addonNames, addonName)
    if addonName == PreviewAnywhere.name then
        Initialize()
        EVENT_MANAGER:UnregisterForEvent(PreviewAnywhere.name, EVENT_ADD_ON_LOADED)
    end
end)

-- Fallback: if EVENT_ADD_ON_LOADED never matched our name (suspected console
-- dev-slot behavior), initialize once the player activates. Saved variables
-- are guaranteed loaded by then.
EVENT_MANAGER:RegisterForEvent(PreviewAnywhere.name .. "Activated", EVENT_PLAYER_ACTIVATED, function()
    EVENT_MANAGER:UnregisterForEvent(PreviewAnywhere.name .. "Activated", EVENT_PLAYER_ACTIVATED)
    if not PreviewAnywhere.diagnostics.initialized then
        PreviewAnywhere.diagnostics.lateInit = true
        Initialize()
    end
end)
