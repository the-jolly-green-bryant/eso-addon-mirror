-- Slash commands and /uiedit diag. Session open/close stays in editor.lua.
-- Methods hang off the same ValknarrUIEEditor table so Initialize can
-- register SLASH_COMMANDS["/uiedit"] = Editor:HandleSlash.

ValknarrUIEEditor = ValknarrUIEEditor or {}

local Editor = ValknarrUIEEditor
local ADDON_VERSION = Editor.ADDON_VERSION or ValknarrUIEVersion or "0.0.0"
local Log = ValknarrUIELog
local Budget = ValknarrUIEBudget
local Adapter = ValknarrUIEPlayerAttributes
local Chat = ValknarrUIEGamepadChat
local Store = ValknarrUIELayoutStore
local Movement = ValknarrUIEMovement
local Scene = ValknarrUIEEditorScene
local SettingsMenu = ValknarrUIESettingsMenu
local ElementIds = Editor.ElementIds
local CountFound = Editor.CountFound

function Editor:Diagnose()
    if Log then
        Log:SetHudVisible(true)
        Log:ClearHud()
        Log:Always("Running /uiedit diag")
        -- Session / stick / scene always print so a console paste works with
        -- Show debug logs off. Verbose dumps still need /uiedit log on.
        Log:Always("Session " .. Log:FormatPairs(self:DescribeSession()))
        if Movement and Movement.Describe then
            Log:Always("Sticks " .. Log:FormatPairs(Movement:Describe()))
        end
        if Scene and Scene.Describe then
            Log:Always("Scene " .. Log:FormatPairs(Scene:Describe()))
        end
        Log:Dump("Environment", Adapter:DescribeEnvironment())
        Log:Dump("Session", self:DescribeSession())
        if Movement and Movement.Describe then
            Log:Dump("Sticks", Movement:Describe())
        end
        if Scene and Scene.Describe then
            Log:Dump("Scene", Scene:Describe())
        end
    end
    local controls, sources = self:LocateAll()
    if Log then
        local found, total = CountFound(controls)
        Log:Info("Controls found: " .. found .. "/" .. total)
        Log:Dump("Sources", sources)
        Log:Dump("Settings", Store:DescribeSettings())
        if Chat and Chat.Describe then
            Log:Dump("Gamepad chat", Chat:Describe())
        end
        if LibValknarrUIE and LibValknarrUIE.Count then
            Log:Info("LibValknarrUIE registered elements: " .. tostring(LibValknarrUIE:Count()))
        end
        Log:Dump("SavedVars", {
            initialized = Store.saved ~= nil,
            hasUserLayout = Store:HasUserLayout(),
        })
        if Store:HasUserLayout() then
            Log:Dump("Saved elements", Store:Load())
        end
        for _, name in ipairs(ElementIds()) do
            local live
            if Adapter.GetNormalizedRect then
                live = Adapter:GetNormalizedRect(controls[name])
            else
                live = Adapter:GetNormalizedCenter(controls[name])
            end
            if live then
                Log:Debug(string.format(
                    "Live %s center = %.3f, %.3f w=%.3f h=%.3f",
                    name,
                    live.x,
                    live.y,
                    live.w or 0,
                    live.h or 0
                ))
            else
                Log:Warn("Live center unavailable for " .. name)
            end
            if controls[name] then
                Log:Info(name .. " anchors: " .. Adapter:DescribeAnchors(controls[name]))
            end
        end
        if _G.ACTION_BAR then
            Log:Info("ACTION_BAR present")
            Log:Debug("ACTION_BAR anchors: " .. Adapter:DescribeAnchors(_G.ACTION_BAR))
        else
            Log:Debug("ACTION_BAR global not present")
        end
        Log:Dump("Budget", Budget and Budget.Describe and Budget:Describe())
        Log:Always("Diag complete. Paste the [UIE] Session / Sticks / Scene lines from chat.")
        Log:Always("Those lines are also in SavedVariables/ValknarrUIElementsEditor_SavedVariables.lua debugLog after /reloadui. The engine Logs folder is not addon output.")
    end
    self:ShowBudget()
end

function Editor:ShowBudget()
    if not Log then
        return
    end
    if not Budget or not Budget.Report then
        Log:Always("Budget instrumentation unavailable")
        return
    end
    Budget:Report(Log)
end

function Editor:ShowHelp()
    if not Log then
        return
    end
    Log:Always("Valknarr UI v" .. ADDON_VERSION)
    Log:Always("/uiedit              toggle editor")
    Log:Always("/uiedit diag         session, stick owner, scene (always); writes SavedVariables debugLog")
    Log:Always("/uiedit budget       memory, control count, and editor timing")
    Log:Always("/uiedit log on|off   verbose chat logging")
    Log:Always("/uiedit log hud      show on-canvas log HUD")
    Log:Always("/uiedit log hud off  hide on-canvas log HUD")
    Log:Always("/uiedit settings     open the config panel (invert stick, etc.)")
    Log:Always("/uiedit invert       toggle invert stick up/down")
    Log:Always("/uiedit preview      toggle clean preview (if editor is open)")
    Log:Always("/uiedit reset        default layout (editor must be open)")
    Log:Always("/uiedit help         this help")
    Log:Always("In editor: LS moves, RS resizes Chat, L3 lock axis, Y hides buttons, A saves, B exits")
end

local function TrimArgs(args)
    local text = tostring(args or "")
    if type(zo_strtrim) == "function" then
        return zo_strtrim(text)
    end
    return text:match("^%s*(.-)%s*$") or text
end

function Editor:HandleSlash(args)
    local text = TrimArgs(args)
    local command = string.lower(text)
    if command == "" then
        self:Begin()
        return
    end
    if command == "help" or command == "?" then
        self:ShowHelp()
        return
    end
    if command == "diag" or command == "debug" or command == "status" then
        self:Diagnose()
        return
    end
    if command == "budget" or command == "memory" or command == "perf" then
        self:ShowBudget()
        return
    end
    if command == "log on" or command == "logon" then
        Store:SetSetting("showDebugLog", true)
        if Log.ApplyFromStore then
            Log:ApplyFromStore(false)
        else
            Log:SetEnabled(true)
        end
        return
    end
    if command == "log off" or command == "logoff" then
        Store:SetSetting("showDebugLog", false)
        if Log.ApplyFromStore then
            Log:ApplyFromStore(false)
        else
            Log:SetEnabled(false)
        end
        return
    end
    if command == "log hud" or command == "loghud" then
        Store:SetSetting("showDebugLog", true)
        if Log.ApplyFromStore then
            Log:ApplyFromStore(false)
        else
            Log:SetEnabled(true)
            Log:SetHudVisible(true)
        end
        Log:Always("On-canvas log HUD shown")
        return
    end
    if command == "log hud off" or command == "loghudoff" then
        Log:SetHudVisible(false)
        Log:Always("On-canvas log HUD hidden")
        return
    end
    if command == "preview" or command == "clean" then
        if self.active then
            self:ToggleCleanPreview()
        elseif Log then
            Log:Warn("Open /uiedit first, then toggle clean preview")
        end
        return
    end
    if command == "reset" or command == "defaults" then
        if self.active then
            self:ResetToDefaults()
        elseif Log then
            Log:Warn("Open /uiedit first, then /uiedit reset")
        end
        return
    end
    if command == "settings" or command == "config" or command == "options" then
        if SettingsMenu and SettingsMenu.Show then
            SettingsMenu:Show()
        end
        return
    end
    if command == "invert" or command == "invert y" or command == "inverty" then
        local on = Store:ToggleSetting("invertStickY")
        if Log then
            Log:Always("Invert stick up/down = " .. (on and "ON" or "OFF") .. " (saved)")
        end
        if SettingsMenu and SettingsMenu.active and SettingsMenu.Refresh then
            SettingsMenu:Refresh()
        end
        return
    end
    if command == "invert x" or command == "invertx" then
        local on = Store:ToggleSetting("invertStickX")
        if Log then
            Log:Always("Invert stick left/right = " .. (on and "ON" or "OFF") .. " (saved)")
        end
        if SettingsMenu and SettingsMenu.active and SettingsMenu.Refresh then
            SettingsMenu:Refresh()
        end
        return
    end
    if Log then
        Log:Warn("Unknown /uiedit args: " .. text)
    end
    self:ShowHelp()
end

return Editor
