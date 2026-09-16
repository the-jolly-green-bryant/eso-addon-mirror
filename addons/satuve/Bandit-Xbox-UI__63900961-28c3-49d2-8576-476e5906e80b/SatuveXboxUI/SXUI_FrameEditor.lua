-- Controller layout editor. All coordinates are session-local until Preview confirms Save.
BUI.FrameEditor = BUI.FrameEditor or {}
local Editor = BUI.FrameEditor
Editor.registry = Editor.registry or {}
Editor.order = Editor.order or {}
Editor.pendingPositions = Editor.pendingPositions or {}
local UPDATE_NAME = "SXUI_FrameEditorMove"
local SAFE_INSET = 32
local DEADZONE = 0.18
local FINE_SPEED = 65
local FAST_SPEED = 520

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = Copy(item) end
    return result
end

local function KeyIs(key, name)
    local expected = rawget(_G, name)
    return expected ~= nil and key == expected
end

local function ControlFor(entry)
    local control = entry.control
    if type(control) == "function" then control = control() end
    if control and control.GetCenter and control.GetDimensions then return control end
end

function Editor:RegisterFrame(spec)
    if not spec or not spec.id or not spec.control or not spec.savedKey then return false end
    if not self.registry[spec.id] then self.order[#self.order + 1] = spec.id end
    self.registry[spec.id] = spec
    return true
end

local function RegisterStandardFrames()
    local specs = {
        {"BUI_PlayerFrame", "Player Frame", "PlayerFrame", "100% Health\n80% Magicka\n65% Stamina"},
        {"BUI_TargetFrame", "Target Frame", "TargetFrame", "Training Target\n87% Health"},
        {"BUI_RaidFrame", "Group Frames", "RaidFrames", "Player One\nPlayer Two\nPlayer Three\nPlayer Four"},
        {"BUI_BossFrame", "Boss Frames", "BossFrame", "Test Boss\n72% Health"},
        {"BUI_BuffsP", "Player Buffs", "PlayerBuffs", "Player Buffs"},
        {"BUI_BuffsC", "Custom Buffs", "EnableCustomBuffs", "Custom Buffs"},
        {"BUI_BuffsS", "Synergy Buffs", "EnableSynergyCd", "Synergy Timers"},
        {"BUI_BuffsT", "Target Buffs", "TargetBuffs", "Target Buffs"},
        {"BUI_BuffsPas", "Passive Buffs", "BuffsPassives", "Passive Buffs"},
        {"BUI_BuffsUp", "Buff Uptimes", "PlayerBuffs", "Buff Uptimes"},
        {"BUI_OnScreen", "Notifications", "NotificationsTrial", "Notifications"},
        {"BUI_OnScreenS", "Secondary Notifications", "NotificationsWorld", "Secondary Notifications"},
        {"BUI_Glyphs", "Glyph Timers", "Glyphs", "Glyph Timers"},
        {"BUI_MiniMeter", "Mini Meter", "StatsMiniMeter", "Mini Meter"},
        {"BUI_GroupDPS", "Group DPS", "StatsGroupDPSframe", "Group DPS"},
        {"BUI_Attackers", "Attackers", "Attackers", "Attackers"},
        {"BUI_Targets", "Combat Targets", "Targets", "Combat Targets"},
        {"BUI_Minimap", "Minimap", "MiniMap", "Minimap"},
    }
    for _, item in ipairs(specs) do
        local id, label, preference, preview = unpack(item)
        Editor:RegisterFrame({
            id = id, name = label, savedKey = (id == "BUI_PlayerFrame" and function() return BUI.Vars.FrameHorisontal and "BUI_HPlayerFrame" or id end or id), preview = preview,
            control = function() return rawget(_G, id) end,
        })
    end
    if BUI.Meters and BUI.Meters.List then
        for _, meterName in ipairs(BUI.Meters.List) do
            local meter = meterName
            local id = "BUI_Meter_" .. meter
            Editor:RegisterFrame({
                id = id, name = meter .. " Meter", savedKey = id,
                control = function() return rawget(_G, id) end,
                enabled = function() return BUI.Vars["Meter_" .. meter] == true end,
                preview = meter .. " Meter",
            })
        end
    end
    for widgetName, enabled in pairs(BUI.Vars.Widgets or {}) do
        if enabled then
            local widget = widgetName
            local id = "BUI_Widget_" .. string.gsub(widget, " ", "_")
            Editor:RegisterFrame({
                id = id, name = widget .. " Timer", savedKey = id,
                control = function() return rawget(_G, id) end,
                enabled = function() return BUI.Vars.Widgets[widget] == true end,
                preview = widget .. " Timer",
            })
        end
    end
end

local function RootCenter()
    local x, y = GuiRoot:GetCenter()
    return x or 0, y or 0
end

local function SessionPosition(control)
    local x, y = control:GetCenter()
    local rx, ry = RootCenter()
    if not x or not y then return nil end
    return {x = x - rx, y = y - ry}
end

local function SetSessionPosition(control, position)
    if not control or not position then return end
    control:ClearAnchors()
    control:SetAnchor(CENTER, GuiRoot, CENTER, position.x, position.y)
end

local function SnapshotAnchors(control)
    local result = {}
    local count = control.GetNumAnchors and control:GetNumAnchors() or 0
    for index = 0, count - 1 do
        local anchor = {control:GetAnchor(index)}
        if type(anchor[1]) == "boolean" then table.remove(anchor, 1) end
        if anchor[1] then result[#result + 1] = anchor end
    end
    if #result == 0 then
        local anchor = {control:GetAnchor()}
        if type(anchor[1]) == "boolean" then table.remove(anchor, 1) end
        if anchor[1] then result[1] = anchor end
    end
    return result
end

local function RestoreControl(entry)
    local state = entry.original
    local control = entry.control
    control:ClearAnchors()
    for _, anchor in ipairs(state.anchors) do
        if anchor[1] ~= nil and anchor[1] ~= false then control:SetAnchor(unpack(anchor)) end
    end
    control:SetHidden(state.hidden)
    control:SetAlpha(state.alpha)
end

local function Clamp(control, x, y)
    local rootW, rootH = GuiRoot:GetDimensions()
    local width, height = control:GetDimensions()
    local scale = control.GetScale and control:GetScale() or 1
    width, height = (width or 0) * scale, (height or 0) * scale
    local maxX = math.max(0, rootW / 2 - SAFE_INSET - width / 2)
    local maxY = math.max(0, rootH / 2 - SAFE_INSET - height / 2)
    return math.max(-maxX, math.min(maxX, x)), math.max(-maxY, math.min(maxY, y))
end
Editor.Clamp = Clamp

local function CreateLabel(name, parent, width, height, anchor, size)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetDimensions(width, height)
    label:SetAnchor(unpack(anchor))
    label:SetFont("$(BOLD_FONT)|" .. size .. "|soft-shadow-thick")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

function Editor:CreateWindow()
    if self.window then return end
    local win = WINDOW_MANAGER:CreateTopLevelWindow("SXUI_FrameEditor")
    win:SetAnchorFill(GuiRoot)
    win:SetDrawTier(DT_HIGH)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetMouseEnabled(false)
    if win.SetKeyboardEnabled then win:SetKeyboardEnabled(true) end
    win:SetHidden(true)
    self.window = win
    local help = WINDOW_MANAGER:CreateControl("SXUI_FrameEditorHelp", win, CT_BACKDROP)
    help:SetDimensions(1060, 100)
    help:SetAnchor(TOP, GuiRoot, TOP, 0, 30)
    help:SetCenterColor(0, 0, 0, 0.88)
    help:SetEdgeColor(0.78, 0.72, 0.38, 1)
    self.title = CreateLabel("SXUI_FrameEditorTitle", help, 1020, 40, {TOP, help, TOP, 0, 3}, 24)
    self.helpText = CreateLabel("SXUI_FrameEditorKeys", help, 1020, 48, {TOP, help, TOP, 0, 46}, 18)
    local highlight = WINDOW_MANAGER:CreateControl("SXUI_FrameEditorHighlight", win, CT_BACKDROP)
    highlight:SetCenterColor(0.8, 0.7, 0.1, 0.1)
    highlight:SetEdgeColor(1, 0.85, 0.2, 1)
    highlight:SetHidden(true)
    self.highlight = highlight
    win:SetHandler("OnKeyDown", function(_, key) return Editor:OnKeyDown(key) end)
end

function Editor:RefreshHighlight()
    if not self.active or not self.selection then return end
    local entry = self.visible[self.selection]
    if not entry then return end
    local control = entry.control
    self.highlight:ClearAnchors()
    self.highlight:SetAnchor(TOPLEFT, control, TOPLEFT, -5, -5)
    self.highlight:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 5, 5)
    self.highlight:SetEdgeColor(self.mode == "move" and 1 or 0.78, self.mode == "move" and 0.25 or 0.72, 0.2, 1)
    self.highlight:SetHidden(self.mode == "preview")
    local prefix = self.mode == "move" and "MOVE: " or self.mode == "preview" and "TEST LAYOUT" or "SELECT: "
    self.title:SetText(prefix .. (self.mode == "preview" and "" or entry.spec.name))
    if self.mode == "move" then
        self.helpText:SetText("Left Stick: fine move   •   Right Stick: fast move   •   B: place   •   View: cancel")
    elseif self.mode == "preview" then
        self.helpText:SetText("A: Save Layout   •   B: Reposition   •   View: cancel")
    else
        self.helpText:SetText("D-Pad: select frame   •   A: move   •   Menu: test layout   •   View: cancel")
    end
end

function Editor:SelectDirection(dx, dy)
    if self.mode ~= "select" or not self.selection then return end
    local current = self.visible[self.selection]
    local cx, cy = current.control:GetCenter()
    local best, bestScore
    for index, entry in ipairs(self.visible) do
        if index ~= self.selection then
            local x, y = entry.control:GetCenter()
            if x and y and cx and cy then
                local horizontal, vertical = x - cx, y - cy
                local along = horizontal * dx + vertical * dy
                local cross = math.abs(horizontal * dy - vertical * dx)
                if along > 1 then
                    local score = along + cross * 2
                    if not bestScore or score < bestScore then best, bestScore = index, score end
                end
            end
        end
    end
    if not best then
        best = ((self.selection - 1 + (dx + dy > 0 and 1 or -1)) % #self.visible) + 1
    end
    self.selection = best
    self:RefreshHighlight()
end

local function Axis(name)
    local func = rawget(_G, name)
    if type(func) ~= "function" then return 0 end
    local value = tonumber(func(false)) or 0
    if math.abs(value) < DEADZONE then return 0 end
    return (value > 0 and 1 or -1) * (math.abs(value) - DEADZONE) / (1 - DEADZONE)
end

function Editor:MoveTick()
    if not self.active or self.mode ~= "move" then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
        return
    end
    local lx, ly = Axis("GetGamepadLeftStickX"), Axis("GetGamepadLeftStickY")
    local rx, ry = Axis("GetGamepadRightStickX"), Axis("GetGamepadRightStickY")
    if lx == 0 and ly == 0 and rx == 0 and ry == 0 then return end
    local entry = self.visible[self.selection]
    local position = self.pendingPositions[entry.spec.id]
    local dt = type(GetFrameDeltaTimeSeconds) == "function" and GetFrameDeltaTimeSeconds() or 0.016
    dt = math.max(0, math.min(0.05, tonumber(dt) or 0.016))
    local x = position.x + (lx * FINE_SPEED + rx * FAST_SPEED) * dt
    local y = position.y - (ly * FINE_SPEED + ry * FAST_SPEED) * dt
    position.x, position.y = Clamp(entry.control, x, y)
    SetSessionPosition(entry.control, position)
    self:RefreshHighlight()
end

function Editor:EnterMove()
    if self.mode ~= "select" then return end
    self.mode = "move"
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 16, function() Editor:MoveTick() end)
    self:RefreshHighlight()
end

function Editor:Place()
    if self.mode ~= "move" then return end
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    self.mode = "select"
    self:RefreshHighlight()
end

function Editor:Preview()
    if not self.active then return end
    self:Place()
    self.mode = "preview"
    for _, entry in ipairs(self.visible) do
        if not entry.previewControl then
            entry.previewControl = CreateLabel(
                "SXUI_FramePreview_" .. entry.spec.id, entry.control,
                math.max(260, entry.control:GetWidth()), 90,
                {CENTER, entry.control, CENTER, 0, 0}, 16)
            entry.previewControl:SetColor(1, 0.9, 0.45, 1)
        end
        entry.previewControl:SetText(entry.spec.preview or entry.spec.name)
        entry.previewControl:SetHidden(false)
    end
    self:RefreshHighlight()
end

function Editor:Reposition()
    if self.mode ~= "preview" then return end
    for _, entry in ipairs(self.visible) do
        if entry.previewControl then entry.previewControl:SetHidden(true) end
    end
    self.mode = "select"
    self:RefreshHighlight()
end

local function SavedKey(spec)
    return type(spec.savedKey) == "function" and spec.savedKey() or spec.savedKey
end

local function Changed(self, entry)
    local now = self.pendingPositions[entry.spec.id]
    local old = self.originalPositions[entry.spec.id]
    return now and old and (math.abs(now.x - old.x) > 0.05 or math.abs(now.y - old.y) > 0.05)
end

local function SavePosition(entry, position)
    local control = entry.control
    local existing = BUI.Vars[SavedKey(entry.spec)]
    local anchor = type(existing) == "table" and Copy(existing) or {}
    local point = anchor[1] or CENTER
    local rootW, rootH = GuiRoot:GetDimensions()
    local width, height = control:GetDimensions()
    local x, y = position.x, position.y
    if point == LEFT or point == TOPLEFT or point == BOTTOMLEFT then x = x - width / 2 end
    if point == RIGHT or point == TOPRIGHT or point == BOTTOMRIGHT then x = x + width / 2 end
    if point == TOP or point == TOPLEFT or point == TOPRIGHT then y = y - height / 2 end
    if point == BOTTOM or point == BOTTOMLEFT or point == BOTTOMRIGHT then y = y + height / 2 end
    anchor[1], anchor[2], anchor[3], anchor[4] = point, CENTER, x, y
    anchor[5] = nil
    BUI.Vars[SavedKey(entry.spec)] = anchor
end

function Editor:Close(saved)
    if not self.active then return end
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    for _, entry in ipairs(self.visible) do
        if entry.previewControl then entry.previewControl:SetHidden(true) end
        RestoreControl(entry)
        if saved and Changed(self, entry) then
            local anchor = BUI.Vars[SavedKey(entry.spec)]
            if anchor then
                entry.control:ClearAnchors()
                entry.control:SetAnchor(anchor[1], GuiRoot, anchor[2], anchor[3], anchor[4])
            end
        end
    end
    self.highlight:SetHidden(true)
    self.window:SetHidden(true)
    if self.settingsWasShown and rawget(_G, "BUI_SettingsWindow") then BUI_SettingsWindow:SetHidden(false) end
    if self.uiModeWasOff and SCENE_MANAGER and not WINDOW_MANAGER:IsSecureRenderModeEnabled() then
        SCENE_MANAGER:SetInUIMode(false)
    end
    self.active, self.mode, self.visible, self.selection = false, nil, nil, nil
    self.pendingPositions = {}
    self.originalPositions = {}
    if BUI.Frames and BUI.Frames.SetupPlayer then BUI.Frames:SetupPlayer() end
    if BUI.Frames and BUI.Frames.SetupGroup then BUI.Frames:SetupGroup() end
    if BUI.MiniMap and BUI.MiniMap.EnsureMinimapState then BUI.MiniMap.EnsureMinimapState("FRAME_EDITOR_CLOSED") end
end

function Editor:Save()
    if self.mode ~= "preview" then return end
    for _, entry in ipairs(self.visible) do
        local position = self.pendingPositions[entry.spec.id]
        if Changed(self, entry) then SavePosition(entry, position) end
    end
    self:Close(true)
end

function Editor:Cancel()
    self:Close(false)
end

function Editor:OnKeyDown(key)
    if not self.active then return false end
    if KeyIs(key, "KEY_GAMEPAD_BACK") or KeyIs(key, "KEY_GAMEPAD_BACK_HOLD") or KeyIs(key, "KEY_ESCAPE") then
        self:Cancel()
    elseif self.mode == "preview" then
        if KeyIs(key, "KEY_GAMEPAD_BUTTON_1") or KeyIs(key, "KEY_ENTER") then self:Save()
        elseif KeyIs(key, "KEY_GAMEPAD_BUTTON_2") then self:Reposition() end
    elseif self.mode == "move" then
        if KeyIs(key, "KEY_GAMEPAD_BUTTON_2") then self:Place() end
    else
        if KeyIs(key, "KEY_GAMEPAD_BUTTON_1") or KeyIs(key, "KEY_ENTER") then self:EnterMove()
        elseif KeyIs(key, "KEY_GAMEPAD_START") then self:Preview()
        elseif KeyIs(key, "KEY_GAMEPAD_DPAD_UP") or KeyIs(key, "KEY_UPARROW") then self:SelectDirection(0, -1)
        elseif KeyIs(key, "KEY_GAMEPAD_DPAD_DOWN") or KeyIs(key, "KEY_DOWNARROW") then self:SelectDirection(0, 1)
        elseif KeyIs(key, "KEY_GAMEPAD_DPAD_LEFT") or KeyIs(key, "KEY_LEFTARROW") then self:SelectDirection(-1, 0)
        elseif KeyIs(key, "KEY_GAMEPAD_DPAD_RIGHT") or KeyIs(key, "KEY_RIGHTARROW") then self:SelectDirection(1, 0) end
    end
    return true
end

function Editor:Open()
    if self.active or not BUI.Vars or (BUI.inCombat) then return false end
    RegisterStandardFrames()
    self.visible, self.pendingPositions, self.originalPositions = {}, {}, {}
    for _, id in ipairs(self.order) do
        local spec = self.registry[id]
        local control = ControlFor(spec)
        local allowed = not spec.enabled or spec.enabled()
        local position = allowed and control and SessionPosition(control)
        if position and control:GetWidth() > 0 and control:GetHeight() > 0 then
            local entry = {
                spec = spec, control = control,
                original = {
                    anchors = SnapshotAnchors(control),
                    hidden = control:IsHidden(), alpha = control:GetAlpha(),
                },
            }
            self.visible[#self.visible + 1] = entry
            self.pendingPositions[id] = Copy(position)
            self.originalPositions[id] = Copy(position)
            control:SetHidden(false)
            control:SetAlpha(1)
        end
    end
    if #self.visible == 0 then return false end
    self:CreateWindow()
    self.active, self.mode, self.selection = true, "select", 1
    self.uiModeWasOff = SCENE_MANAGER and not SCENE_MANAGER:IsInUIMode()
    self.settingsWasShown = rawget(_G, "BUI_SettingsWindow") and not BUI_SettingsWindow:IsHidden()
    if self.settingsWasShown then BUI_SettingsWindow:SetHidden(true) end
    if self.uiModeWasOff and not WINDOW_MANAGER:IsSecureRenderModeEnabled() then SCENE_MANAGER:SetInUIMode(true) end
    self.window:SetHidden(false)
    if self.window.TakeFocus then self.window:TakeFocus() end
    self:RefreshHighlight()
    return true
end

