zFederGamepadCameraBoost = {
    name = "zFederGamepadCameraBoost",
    displayName = "zFeder Gamepad Camera Boost",
    version = "1.0.2",
    supportUrl = "https://www.buymeacoffee.com/zFeder",
}

local zFGCB = zFederGamepadCameraBoost

local defaults = {
    enabled = true,
    profileVersion = 2,
    horizontalSensitivity = 2.15,
    verticalSensitivity = 2.15,
    oneToOneSensitivity = true,
    reapplyEnabled = true,
    reapplySeconds = 2,
    disableCameraSmoothing = false,
    applyLegacyFallback = true,
    applyMouseCameraFallback = false,
    debug = false,
}

local sv
local lastApplied = {
    horizontal = nil,
    vertical = nil,
}

local function Color(text, color)
    return "|c" .. color .. tostring(text) .. "|r"
end

local function Round(value, decimals)
    local factor = 10 ^ (decimals or 2)
    return math.floor((tonumber(value) or 0) * factor + 0.5) / factor
end

local function Clamp(value, fallback, minValue, maxValue)
    local numberValue = tonumber(value)
    if not numberValue then
        numberValue = fallback
    end
    if numberValue < minValue then
        return minValue
    end
    if numberValue > maxValue then
        return maxValue
    end
    return numberValue
end

local function SplitArgs(args)
    local values = {}
    for value in string.gmatch(args or "", "%S+") do
        values[#values + 1] = value
    end
    return values
end

function zFGCB:Print(message)
    d(Color("[zFeder] ", "66CCFF") .. tostring(message))
end

function zFGCB:Debug(message)
    if sv and sv.debug then
        self:Print(Color("Debug: ", "AAAAAA") .. tostring(message))
    end
end

function zFGCB:FormatValue(value)
    if value == nil then
        return "n/a"
    end
    local numberValue = tonumber(value)
    if numberValue then
        return string.format("%.2f", numberValue)
    end
    return tostring(value)
end

function zFGCB:ResolveGlobal(name)
    return _G and _G[name] or nil
end

function zFGCB:TryGetSetting(settingTypeName, settingName)
    local settingType = self:ResolveGlobal(settingTypeName)
    local settingId = self:ResolveGlobal(settingName)
    if settingType == nil or settingId == nil or not GetSetting then
        return nil, "missing " .. settingTypeName .. "/" .. settingName
    end

    local ok, value = pcall(GetSetting, settingType, settingId)
    if ok then
        return value
    end
    return nil, value
end

function zFGCB:TrySetSetting(settingTypeName, settingName, value)
    local settingType = self:ResolveGlobal(settingTypeName)
    local settingId = self:ResolveGlobal(settingName)
    if settingType == nil or settingId == nil or not SetSetting then
        self:Debug("Setting fehlt: " .. settingTypeName .. "/" .. settingName)
        return false, nil
    end

    local stringValue = tostring(value)
    local saveOption = self:ResolveGlobal("SETTINGS_SET_OPTION_SAVE_TO_PERSISTED_DATA")
    local ok, err
    if saveOption ~= nil then
        ok, err = pcall(SetSetting, settingType, settingId, stringValue, saveOption)
    else
        ok, err = pcall(SetSetting, settingType, settingId, stringValue)
    end

    if not ok then
        self:Debug("SetSetting fehlgeschlagen: " .. settingTypeName .. "/" .. settingName .. " -> " .. tostring(err))
        return false, nil
    end

    local actual = self:TryGetSetting(settingTypeName, settingName)
    return true, actual
end

function zFGCB:TrySetCVar(name, value)
    if not SetCVar then
        self:Debug("SetCVar fehlt fuer " .. tostring(name))
        return false
    end

    local ok, err = pcall(SetCVar, name, tostring(value))
    if not ok then
        self:Debug("SetCVar fehlgeschlagen: " .. tostring(name) .. " -> " .. tostring(err))
        return false
    end
    return true
end

function zFGCB:CheckClamp(label, requested, actual)
    local actualNumber = tonumber(actual)
    if actualNumber and math.abs(actualNumber - requested) > 0.01 then
        self:Print(Color("Warnung: ", "FFAA33") .. label .. " wollte " .. self:FormatValue(requested) .. ", ESO meldet " .. self:FormatValue(actual) .. ". Moeglicher Engine-Clamp.")
    end
end

function zFGCB:GetEffectiveValues()
    local horizontal = Clamp(sv.horizontalSensitivity, defaults.horizontalSensitivity, 0.05, 100)
    local vertical = sv.oneToOneSensitivity and horizontal or Clamp(sv.verticalSensitivity, defaults.verticalSensitivity, 0.05, 100)
    return Round(horizontal, 2), Round(vertical, 2)
end

function zFGCB:ApplyCameraSmoothing()
    if not sv.disableCameraSmoothing then
        return false
    end
    local changed = self:TrySetSetting("SETTING_TYPE_CAMERA", "CAMERA_SETTING_SMOOTHING", 0)
    return changed
end

function zFGCB:ApplySensitivity(silent)
    if not sv.enabled then
        if not silent then
            self:Print("deaktiviert. Nutze /zfgamepad on zum Aktivieren.")
        end
        return false
    end

    local horizontal, vertical = self:GetEffectiveValues()
    local changed = false

    local okX, actualX = self:TrySetSetting("SETTING_TYPE_GAMEPAD", "GAMEPAD_SETTING_CAMERA_SENSITIVITY_X", horizontal)
    local okY, actualY = self:TrySetSetting("SETTING_TYPE_GAMEPAD", "GAMEPAD_SETTING_CAMERA_SENSITIVITY_Y", vertical)
    changed = okX or okY or changed

    if okX then
        self:CheckClamp("Gamepad X", horizontal, actualX)
    end
    if okY then
        self:CheckClamp("Gamepad Y", vertical, actualY)
    end

    if sv.applyLegacyFallback then
        local legacyValue = math.max(horizontal, vertical)
        changed = self:TrySetSetting("SETTING_TYPE_GAMEPAD", "GAMEPAD_SETTING_CAMERA_SENSITIVITY", legacyValue) or changed
    end

    self:TrySetCVar("GamepadSensitivityFirstPersonX", horizontal)
    self:TrySetCVar("GamepadSensitivityThirdPersonX", horizontal)
    self:TrySetCVar("GamepadSensitivityFirstPerson.2", horizontal)
    self:TrySetCVar("GamepadSensitivityThirdPerson.2", horizontal)
    self:TrySetCVar("GamepadSensitivityFirstPersonY", vertical)
    self:TrySetCVar("GamepadSensitivityThirdPersonY", vertical)

    if sv.applyMouseCameraFallback then
        self:TrySetSetting("SETTING_TYPE_CAMERA", "CAMERA_SETTING_SENSITIVITY_FIRST_PERSON_X", horizontal)
        self:TrySetSetting("SETTING_TYPE_CAMERA", "CAMERA_SETTING_SENSITIVITY_THIRD_PERSON_X", horizontal)
        self:TrySetSetting("SETTING_TYPE_CAMERA", "CAMERA_SETTING_SENSITIVITY_FIRST_PERSON_Y", vertical)
        self:TrySetSetting("SETTING_TYPE_CAMERA", "CAMERA_SETTING_SENSITIVITY_THIRD_PERSON_Y", vertical)
        self:TrySetSetting("SETTING_TYPE_CAMERA", "CAMERA_SETTING_SENSITIVITY_FIRST_PERSON", math.max(horizontal, vertical))
        self:TrySetSetting("SETTING_TYPE_CAMERA", "CAMERA_SETTING_SENSITIVITY_THIRD_PERSON", math.max(horizontal, vertical))
    end

    self:ApplyCameraSmoothing()

    lastApplied.horizontal = horizontal
    lastApplied.vertical = vertical

    if not silent then
        self:Print("angewendet: horizontal " .. self:FormatValue(horizontal) .. " / vertikal " .. self:FormatValue(vertical) .. ".")
    end

    return changed
end

function zFGCB:StartReapplyLoop()
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "Reapply")
    if not sv.enabled or not sv.reapplyEnabled then
        return
    end

    local interval = Clamp(sv.reapplySeconds, defaults.reapplySeconds, 1, 30) * 1000
    EVENT_MANAGER:RegisterForUpdate(self.name .. "Reapply", interval, function()
        zFGCB:ApplySensitivity(true)
    end)
end

function zFGCB:PrintStatus()
    local horizontal, vertical = self:GetEffectiveValues()
    self:Print("Status: " .. (sv.enabled and Color("aktiv", "55FF55") or Color("aus", "FF5555")) .. ", Ziel X " .. self:FormatValue(horizontal) .. ", Ziel Y " .. self:FormatValue(vertical) .. ".")

    local gamepadX = self:TryGetSetting("SETTING_TYPE_GAMEPAD", "GAMEPAD_SETTING_CAMERA_SENSITIVITY_X")
    local gamepadY = self:TryGetSetting("SETTING_TYPE_GAMEPAD", "GAMEPAD_SETTING_CAMERA_SENSITIVITY_Y")
    local oldGamepad = self:TryGetSetting("SETTING_TYPE_GAMEPAD", "GAMEPAD_SETTING_CAMERA_SENSITIVITY")
    self:Print("ESO meldet: Gamepad X " .. self:FormatValue(gamepadX) .. ", Gamepad Y " .. self:FormatValue(gamepadY) .. ", Legacy " .. self:FormatValue(oldGamepad) .. ".")
    self:Print("Befehle: /zfgamepad set 5 oder /zfgamepad set 5 4, /zfgamepad apply, /zfgamepad on, /zfgamepad off.")
end

function zFGCB:SetValues(horizontal, vertical)
    sv.horizontalSensitivity = Clamp(horizontal, sv.horizontalSensitivity or defaults.horizontalSensitivity, 0.05, 100)
    if vertical ~= nil then
        sv.verticalSensitivity = Clamp(vertical, sv.verticalSensitivity or defaults.verticalSensitivity, 0.05, 100)
        sv.oneToOneSensitivity = false
    end
    self:ApplySensitivity(false)
    self:StartReapplyLoop()
end

function zFGCB:HandleSlash(args)
    local values = SplitArgs(args)
    local command = values[1] and string.lower(values[1]) or "status"

    if command == "on" then
        sv.enabled = true
        self:ApplySensitivity(false)
        self:StartReapplyLoop()
        return
    end

    if command == "off" then
        sv.enabled = false
        EVENT_MANAGER:UnregisterForUpdate(self.name .. "Reapply")
        self:Print("deaktiviert.")
        return
    end

    if command == "apply" then
        self:ApplySensitivity(false)
        self:StartReapplyLoop()
        return
    end

    if command == "set" then
        local horizontal = tonumber(values[2])
        if not horizontal then
            self:Print("Syntax: /zfgamepad set 5 oder /zfgamepad set 5 4")
            return
        end
        self:SetValues(horizontal, tonumber(values[3]))
        return
    end

    if command == "debug" then
        sv.debug = not sv.debug
        self:Print("Debug ist jetzt " .. (sv.debug and "an" or "aus") .. ".")
        return
    end

    self:PrintStatus()
end

function zFGCB:RegisterSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then
        self:Print("LibAddonMenu-2.0 fehlt. Einstellungen gehen trotzdem per /zfgamepad.")
        return
    end

    local panelName = self.name .. "Options"
    local panelData = {
        type = "panel",
        name = self.displayName,
        displayName = self.displayName,
        author = "zFeder",
        version = self.version,
        slashCommand = "/zfgamepad",
        registerForRefresh = true,
        registerForDefaults = true,
        website = self.supportUrl,
        donation = self.supportUrl,
    }

    local optionsData = {
        {
            type = "checkbox",
            name = "Aktiv",
            tooltip = "Wendet die Gamepad-Kameraempfindlichkeit automatisch an.",
            getFunc = function() return sv.enabled end,
            setFunc = function(value)
                sv.enabled = value
                zFGCB:ApplySensitivity(false)
                zFGCB:StartReapplyLoop()
            end,
            default = defaults.enabled,
        },
        {
            type = "slider",
            name = function() return "Horizontal (" .. zFGCB:FormatValue(sv.horizontalSensitivity) .. ")" end,
            tooltip = "Rechter Stick links/rechts. Werte ueber 3 sind sehr schnell; bis 30 ist fuer extreme Tests erlaubt.",
            min = 0.10,
            max = 30.00,
            step = 0.05,
            decimals = 2,
            getFunc = function() return sv.horizontalSensitivity end,
            setFunc = function(value)
                sv.horizontalSensitivity = value
                if sv.oneToOneSensitivity then
                    sv.verticalSensitivity = value
                end
                zFGCB:ApplySensitivity(false)
            end,
            default = defaults.horizontalSensitivity,
        },
        {
            type = "checkbox",
            name = "1:1 X/Y",
            tooltip = "Wenn aktiv, nutzt vertikale Kamera denselben Wert wie horizontal.",
            getFunc = function() return sv.oneToOneSensitivity end,
            setFunc = function(value)
                sv.oneToOneSensitivity = value
                if value then
                    sv.verticalSensitivity = sv.horizontalSensitivity
                end
                zFGCB:ApplySensitivity(false)
            end,
            default = defaults.oneToOneSensitivity,
        },
        {
            type = "slider",
            name = function() return "Vertikal (" .. zFGCB:FormatValue(sv.verticalSensitivity) .. ")" end,
            tooltip = "Rechter Stick hoch/runter. Nur aktiv, wenn 1:1 X/Y aus ist.",
            min = 0.10,
            max = 30.00,
            step = 0.05,
            decimals = 2,
            getFunc = function() return sv.verticalSensitivity end,
            setFunc = function(value)
                sv.verticalSensitivity = value
                zFGCB:ApplySensitivity(false)
            end,
            disabled = function() return sv.oneToOneSensitivity end,
            default = defaults.verticalSensitivity,
        },
        {
            type = "checkbox",
            name = "Regelmaessig erneut anwenden",
            tooltip = "Hilft, falls ESO oder ein anderes Addon die Werte nach Zone-/UI-Wechsel zuruecksetzt.",
            getFunc = function() return sv.reapplyEnabled end,
            setFunc = function(value)
                sv.reapplyEnabled = value
                zFGCB:StartReapplyLoop()
            end,
            default = defaults.reapplyEnabled,
        },
        {
            type = "slider",
            name = "Reapply Sekunden",
            tooltip = "Wie oft die Werte erneut gesetzt werden.",
            min = 1,
            max = 30,
            step = 1,
            getFunc = function() return sv.reapplySeconds end,
            setFunc = function(value)
                sv.reapplySeconds = value
                zFGCB:StartReapplyLoop()
            end,
            default = defaults.reapplySeconds,
            disabled = function() return not sv.reapplyEnabled end,
        },
        {
            type = "checkbox",
            name = "Kamera-Smoothing aus",
            tooltip = "Optional: setzt Camera Smoothing auf 0. Kann sich direkter anfuehlen.",
            getFunc = function() return sv.disableCameraSmoothing end,
            setFunc = function(value)
                sv.disableCameraSmoothing = value
                zFGCB:ApplySensitivity(false)
            end,
            default = defaults.disableCameraSmoothing,
        },
        {
            type = "checkbox",
            name = "Legacy-Fallback setzen",
            tooltip = "Setzt zusaetzlich den alten GAMEPAD_SETTING_CAMERA_SENSITIVITY, falls er im Client noch existiert.",
            getFunc = function() return sv.applyLegacyFallback end,
            setFunc = function(value)
                sv.applyLegacyFallback = value
                zFGCB:ApplySensitivity(false)
            end,
            default = defaults.applyLegacyFallback,
        },
        {
            type = "checkbox",
            name = "Mouse/Keyboard-Camera-Fallback",
            tooltip = "Nur fuer Tests: setzt zusaetzlich normale Kamera-Sensitivitaet. Kann Mausgefuehl veraendern.",
            getFunc = function() return sv.applyMouseCameraFallback end,
            setFunc = function(value)
                sv.applyMouseCameraFallback = value
                zFGCB:ApplySensitivity(false)
            end,
            default = defaults.applyMouseCameraFallback,
        },
        {
            type = "button",
            name = "Jetzt anwenden",
            tooltip = "Setzt die Werte sofort und schreibt den Status in den Chat.",
            func = function()
                zFGCB:ApplySensitivity(false)
                zFGCB:PrintStatus()
            end,
        },
        {
            type = "checkbox",
            name = "Debug",
            tooltip = "Zeigt fehlende Konstanten oder SetSetting-Fehler im Chat.",
            getFunc = function() return sv.debug end,
            setFunc = function(value) sv.debug = value end,
            default = defaults.debug,
        },
        {
            type = "description",
            title = "Chat-Befehle",
            text = "/zfgamepad status\n/zfgamepad set 5\n/zfgamepad set 5 4\n/zfgamepad apply\n/zfgamepad on\n/zfgamepad off",
        },
        {
            type = "description",
            title = "Support",
            text = "Optional: Buy me a coffee\n" .. self.supportUrl,
        },
    }

    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsData)
end

function zFGCB:OnPlayerActivated()
    zo_callLater(function()
        zFGCB:ApplySensitivity(true)
        zFGCB:StartReapplyLoop()
    end, 1500)
end

function zFGCB:OnLoaded()
    sv = ZO_SavedVars:NewAccountWide("zFederGamepadCameraBoostSavedVariables", 1, nil, defaults, GetWorldName())

    if not sv.profileVersion or sv.profileVersion < defaults.profileVersion then
        sv.horizontalSensitivity = defaults.horizontalSensitivity
        sv.verticalSensitivity = defaults.verticalSensitivity
        sv.profileVersion = defaults.profileVersion
    end

    sv.horizontalSensitivity = Clamp(sv.horizontalSensitivity, defaults.horizontalSensitivity, 0.05, 100)
    sv.verticalSensitivity = Clamp(sv.verticalSensitivity, defaults.verticalSensitivity, 0.05, 100)
    sv.reapplySeconds = Clamp(sv.reapplySeconds, defaults.reapplySeconds, 1, 30)

    local slashHandler = function(args) zFGCB:HandleSlash(args) end
    SLASH_COMMANDS["/zfgamepad"] = slashHandler
    SLASH_COMMANDS["/zfpadboost"] = slashHandler
    SLASH_COMMANDS["/padboost"] = slashHandler
    SLASH_COMMANDS["/gamepadboost"] = slashHandler

    self:RegisterSettingsMenu()

    EVENT_MANAGER:RegisterForEvent(self.name .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        zFGCB:OnPlayerActivated()
    end)

    if EVENT_GAME_CAMERA_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(self.name .. "CameraActivated", EVENT_GAME_CAMERA_ACTIVATED, function()
            zo_callLater(function() zFGCB:ApplySensitivity(true) end, 300)
        end)
    end

    zo_callLater(function()
        zFGCB:ApplySensitivity(true)
        zFGCB:StartReapplyLoop()
        zFGCB:Print("geladen. /zfgamepad status zeigt die aktuellen Werte.")
    end, 1200)
end

EVENT_MANAGER:RegisterForEvent(zFGCB.name, EVENT_ADD_ON_LOADED, function(_, addOnName)
    if addOnName == zFGCB.name then
        EVENT_MANAGER:UnregisterForEvent(zFGCB.name, EVENT_ADD_ON_LOADED)
        zFGCB:OnLoaded()
    end
end)
