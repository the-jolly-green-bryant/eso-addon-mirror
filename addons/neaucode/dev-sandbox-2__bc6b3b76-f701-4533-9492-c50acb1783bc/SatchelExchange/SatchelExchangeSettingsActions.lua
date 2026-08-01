-- SatchelExchangeSettingsActions.lua: Gamepad-friendly settings page via
-- LibHarvensAddonSettings (register with AddAddon + AddSetting; never call
-- CreateAddonSettingsPanel from an addon).

---@type LibConsoleLogger
local CL = LibConsoleLogger

local SatchelExchangeSettingsActions = {}

---@return SatchelExchangeSavedVars
local function GetSettings()
    return SatchelExchange.state.savedVars
end

function SatchelExchangeSettingsActions.Initialize()
    local LAS = _G["LibHarvensAddonSettings"]
    if not LAS or not LAS.AddAddon then
        CL:Log("[SatchelExchange] LibHarvensAddonSettings not available; settings page disabled")
        return
    end

    local panel = LAS:AddAddon("Satchel Exchange")
    panel.author = "neaucode"
    panel.version = "v" .. tostring(SatchelExchange.version)

    panel:AddSetting({
        type = LAS.ST_CHECKBOX,
        label = "Enable Satchel Exchange",
        tooltip = "Master switch. Turning this off also disarms any pending auto-exchange.",
        getFunction = function()
            return GetSettings().enabled
        end,
        setFunction = function(value)
            GetSettings().enabled = value
            if not value then
                SatchelExchange.StoreActions.Stop("disabled in settings")
            end
        end,
    })

    panel:AddSetting({
        type = LAS.ST_BUTTON,
        label = "Disarm Auto-Exchange",
        tooltip = "Cancel the pending Talk-to-buy loop without turning the addon off. It also disarms on zone change, talking to a different NPC, the in-store keybind, or after the resume window expires.",
        buttonText = "Disarm",
        clickHandler = function()
            SatchelExchange.StoreActions.Disarm()
        end,
    })

    panel:AddSetting({
        type = LAS.ST_CHECKBOX,
        label = "Auto-exit vendor after buying",
        tooltip = "Close the store and end the interaction as soon as the satchel is bought.",
        getFunction = function()
            return GetSettings().autoCloseStore
        end,
        setFunction = function(value)
            GetSettings().autoCloseStore = value
        end,
    })

    panel:AddSetting({
        type = LAS.ST_SLIDER,
        label = "Auto-resume window (minutes)",
        tooltip = "How long the armed auto-exchange survives between vendor visits.",
        min = 1,
        max = 15,
        step = 1,
        format = "%.0f",
        getFunction = function()
            return math.floor(GetSettings().resumeWindowMs / 60000)
        end,
        setFunction = function(value)
            local minutes = tonumber(value)
            if minutes then
                GetSettings().resumeWindowMs = minutes * 60000
            end
        end,
    })

    panel:AddSetting({
        type = LAS.ST_SECTION,
        label = "Unboxing (experimental)",
    })

    panel:AddSetting({
        type = LAS.ST_CHECKBOX,
        label = "Unbox satchels",
        tooltip = "Open the satchel right after leaving the vendor, polling until the game allows item use. Disable your external unboxer/autoloot addon for the satchel to compare.",
        getFunction = function()
            return GetSettings().autoUnbox
        end,
        setFunction = function(value)
            GetSettings().autoUnbox = value
        end,
    })

    panel:AddSetting({
        type = LAS.ST_SLIDER,
        label = "Unbox start delay (ms)",
        tooltip = "Wait this long after the interaction ends before the first attempt. Lower is snappier; raise it if attempts fail.",
        min = 0,
        max = 1500,
        step = 50,
        format = "%.0f",
        getFunction = function()
            return GetSettings().unboxDelayMs
        end,
        setFunction = function(value)
            GetSettings().unboxDelayMs = tonumber(value) or GetSettings().unboxDelayMs
        end,
    })

    panel:AddSetting({
        type = LAS.ST_SLIDER,
        label = "Unbox max attempts",
        tooltip = "Readiness checks/use attempts (one every 300ms) before giving up.",
        min = 1,
        max = 30,
        step = 1,
        format = "%.0f",
        getFunction = function()
            return GetSettings().unboxMaxAttempts
        end,
        setFunction = function(value)
            GetSettings().unboxMaxAttempts = tonumber(value) or GetSettings().unboxMaxAttempts
        end,
    })
end

SatchelExchange.SettingsActions = SatchelExchangeSettingsActions
