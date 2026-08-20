-- Satuve Rotation Trainer - LibAddonMenu / Gamepad settings bridge
-- Standard LAM controls are intentionally used so LibGamepad can expose the
-- same settings in ESO's gamepad settings UI without a mouse-only custom panel.

SatuveRotationTrainer = SatuveRotationTrainer or {}
local SRT = SatuveRotationTrainer

local HOTBAR_PRIMARY = HOTBAR_CATEGORY_PRIMARY
local HOTBAR_BACKUP  = HOTBAR_CATEGORY_BACKUP
local ULTIMATE_SLOT  = 8
local HEAVY_ATTACK_ID = -900001
local HEAVY_ATTACK_CHANNEL_MS = 2200



-- Dedicated QR overlay. LibGamepad does not reliably render LAM texture controls
-- inside submenus, so the QR is displayed in its own controller-friendly window.
local QR_KEYBINDS = nil

function SRT:CreateQRWindow()
    if self.qrWindow then return end

    local wm = WINDOW_MANAGER
    local win = wm:CreateTopLevelWindow("SatuveRotationTrainerQRWindow")
    win:SetDimensions(420, 500)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawTier(DT_HIGH)
    win:SetDrawLevel(100)
    win:SetMouseEnabled(false)
    win:SetHidden(true)

    local bg = wm:CreateControl("SatuveRotationTrainerQRWindowBG", win, CT_BACKDROP)
    bg:SetAnchorFill(win)
    bg:SetCenterColor(0.02, 0.02, 0.02, 0.97)
    bg:SetEdgeColor(0.75, 0.72, 0.45, 1)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 16)
    bg:SetInsets(8, 8, -8, -8)

    local title = wm:CreateControl("SatuveRotationTrainerQRWindowTitle", win, CT_LABEL)
    title:SetFont("ZoFontWinH1")
    title:SetText("SATUVE MODS DISCORD")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetAnchor(TOP, win, TOP, 0, 28)
    title:SetDimensions(380, 46)

    local qr = wm:CreateControl("SatuveRotationTrainerQRWindowTexture", win, CT_TEXTURE)
    qr:SetTexture("SatuveRotationTrainer/Textures/DiscordQR.dds")
    qr:SetDimensions(300, 300)
    qr:SetAnchor(TOP, title, BOTTOM, 0, 18)

    local link = wm:CreateControl("SatuveRotationTrainerQRWindowLink", win, CT_LABEL)
    link:SetFont("ZoFontGamepad34")
    link:SetText("discord.gg/UgPn6VK3us")
    link:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    link:SetAnchor(TOP, qr, BOTTOM, 0, 18)
    link:SetDimensions(380, 44)

    local hint = wm:CreateControl("SatuveRotationTrainerQRWindowHint", win, CT_LABEL)
    hint:SetFont("ZoFontGamepad27")
    hint:SetText("Scan with your phone")
    hint:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    hint:SetColor(0.75, 0.75, 0.75, 1)
    hint:SetAnchor(TOP, link, BOTTOM, 0, 2)
    hint:SetDimensions(380, 36)

    QR_KEYBINDS = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = GetString(SI_GAMEPAD_BACK_OPTION),
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function() SRT:CloseQRWindow() end,
        },
    }

    self.qrWindow = win
end

function SRT:OpenQRWindow()
    self:CreateQRWindow()
    if not self.qrWindow then return end
    self.qrWindow:SetHidden(false)
    if KEYBIND_STRIP and QR_KEYBINDS then
        KEYBIND_STRIP:AddKeybindButtonGroup(QR_KEYBINDS)
    end
end

function SRT:CloseQRWindow()
    if self.qrWindow then self.qrWindow:SetHidden(true) end
    if KEYBIND_STRIP and QR_KEYBINDS then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(QR_KEYBINDS)
    end
end

local function getLAM()
    if LibAddonMenu2 then return LibAddonMenu2 end
    if LibStub then
        local ok, lib = pcall(function() return LibStub("LibAddonMenu-2.0") end)
        if ok then return lib end
    end
    return nil
end

local function refreshLAMPanel()
    local lam = SRT.lam
    local panel = SRT.lamPanel
    if not lam or not panel then return end

    -- LAM versions / gamepad bridges do not all expose RefreshPanel.
    -- Only call it when it is actually available.
    if type(lam.RefreshPanel) == "function" then
        lam:RefreshPanel(panel)
    elseif CALLBACK_MANAGER and type(CALLBACK_MANAGER.FireCallbacks) == "function" then
        -- LAM controls registered for refresh update themselves when the panel
        -- is shown again; this callback is safe for compatible bridges.
        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", panel)
    end
end

local function abilityName(id)
    if not id or id == 0 then return "Empty" end
    local name = GetAbilityName(id)
    return (name and name ~= "") and name or ("Ability " .. tostring(id))
end

local function heavyAttackLabel()
    return (IsInGamepadPreferredMode and IsInGamepadPreferredMode()) and "HOLD RT" or "HOLD LMB"
end

local function encodeSlot(hotbar, slot)
    if not hotbar or not slot then return "none" end
    local prefix = hotbar == HOTBAR_BACKUP and "B" or "F"
    return prefix .. tostring(slot)
end

local function decodeSlot(value)
    if not value or value == "none" then return nil, nil end
    local prefix = string.sub(value, 1, 1)
    local slot = tonumber(string.sub(value, 2))
    if not slot then return nil, nil end
    return prefix == "B" and HOTBAR_BACKUP or HOTBAR_PRIMARY, slot
end

local NORMAL_CHOICES = {
    "None",
    "Heavy Attack (Hold RT - 2.2s)",
    "Front Bar - Skill 1", "Front Bar - Skill 2", "Front Bar - Skill 3", "Front Bar - Skill 4", "Front Bar - Skill 5",
    "Back Bar - Skill 1",  "Back Bar - Skill 2",  "Back Bar - Skill 3",  "Back Bar - Skill 4",  "Back Bar - Skill 5",
}

local NORMAL_VALUES = {
    "none",
    "HEAVY",
    "F3", "F4", "F5", "F6", "F7",
    "B3", "B4", "B5", "B6", "B7",
}

local ULT_CHOICES = {"None", "Front Bar - Ultimate", "Back Bar - Ultimate"}
local ULT_VALUES  = {"none", "F8", "B8"}

local function currentValue(skill)
    if skill and (skill.isHeavyAttack == true or tonumber(skill.abilityId) == HEAVY_ATTACK_ID) then return "HEAVY" end
    if not skill or not skill.slotIndex or not skill.hotbar then return "none" end
    return encodeSlot(skill.hotbar, skill.slotIndex)
end

function SRT:AssignRoleFromLAM(kind, index, encoded)
    if encoded == "none" then
        self:ClearRole(kind, index)
        refreshLAMPanel()
        return
    end

    if encoded == "HEAVY" then
        local skill = {
            abilityId = HEAVY_ATTACK_ID,
            isHeavyAttack = true,
            channelMs = HEAVY_ATTACK_CHANNEL_MS,
        }
        if kind == "spammable" then
            self.sv.spammable = skill
        elseif kind == "execute" then
            self.sv.execute = skill
        elseif kind == "priority" and index then
            local old = self.sv.priorities[index]
            skill.earlyMs = 0
            skill.manualDurationMs = HEAVY_ATTACK_CHANNEL_MS
            if old and old.manualDurationMs and old.manualDurationMs > 0 then skill.manualDurationMs = old.manualDurationMs end
            self.sv.priorities[index] = skill
        end
        self:ResetDynamicLockQueue()
        self:ClearHeldRecommendation()
        self:RefreshConfig()
        refreshLAMPanel()
        return
    end

    local hotbar, slot = decodeSlot(encoded)
    if not hotbar or not slot then return end
    local id = GetSlotBoundId(slot, hotbar)
    if not id or id == 0 then
        if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
            CHAT_SYSTEM:AddMessage("|c66ccff[SRT]|r That hotbar slot is empty.")
        end
        return
    end

    local skill = {abilityId=id, slotIndex=slot, hotbar=hotbar}
    if kind == "spammable" then
        self.sv.spammable = skill
    elseif kind == "execute" then
        self.sv.execute = skill
    elseif kind == "ultimate" then
        self.sv.ultimate = skill
    elseif kind == "priority" and index then
        local old = self.sv.priorities[index]
        skill.earlyMs = old and (tonumber(old.earlyMs) or 0) or 0
        skill.manualDurationMs = old and (tonumber(old.manualDurationMs) or 0) or 0
        self.sv.priorities[index] = skill
    end

    self:RefreshBarMap()
    self:RefreshConfig()
    refreshLAMPanel()
end

local function roleDescription(skill)
    if skill and (skill.isHeavyAttack == true or tonumber(skill.abilityId) == HEAVY_ATTACK_ID) then
        return "Current: Heavy Attack [" .. heavyAttackLabel() .. " / 2.2s channel]"
    end
    if not skill or not skill.abilityId then return "Current: Empty" end
    local bar = skill.hotbar == HOTBAR_BACKUP and "Back" or "Front"
    local slot = tonumber(skill.slotIndex)
    local label = slot == ULTIMATE_SLOT and "Ultimate" or (slot and tostring(slot - 2) or "?")
    return string.format("Current: %s [%s / %s]", abilityName(skill.abilityId), bar, label)
end

local function priorityControls(index)
    return {
        {
            type = "description",
            text = function()
                local skill = SRT.sv and SRT.sv.priorities and SRT.sv.priorities[index]
                return roleDescription(skill)
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Skill",
            tooltip = "Assign a hotbar skill, or choose Heavy Attack (HOLD RT, 2.2 second channel).",
            choices = NORMAL_CHOICES,
            choicesValues = NORMAL_VALUES,
            getFunc = function()
                return currentValue(SRT.sv.priorities[index])
            end,
            setFunc = function(value)
                SRT:AssignRoleFromLAM("priority", index, value)
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Manual Recast",
            tooltip = "0 = AUTO. Otherwise force a recast time in seconds.",
            min = 0,
            max = 120,
            step = 1,
            getFunc = function()
                local s = SRT.sv.priorities[index]
                return s and math.floor((tonumber(s.manualDurationMs) or 0) / 1000 + 0.5) or 0
            end,
            setFunc = function(value)
                local s = SRT.sv.priorities[index]
                if s then s.manualDurationMs = zo_clamp((tonumber(value) or 0) * 1000, 0, 120000) end
                SRT:RefreshConfig()
            end,
            width = "full",
            default = 0,
        },
        {
            type = "slider",
            name = "Refresh Early",
            tooltip = "How many seconds before this buff/DoT expires it may be recommended again. 0.0 = wait until expiry.",
            min = 0,
            max = 5,
            step = 0.1,
            decimals = 1,
            getFunc = function()
                local s = SRT.sv.priorities[index]
                return s and ((tonumber(s.earlyMs) or 0) / 1000) or 0
            end,
            setFunc = function(value)
                local s = SRT.sv.priorities[index]
                if s then s.earlyMs = zo_clamp((tonumber(value) or 0) * 1000, 0, 5000) end
                SRT:ResetDynamicLockQueue()
                SRT:ClearHeldRecommendation()
                SRT:RefreshConfig()
            end,
            width = "full",
            default = 0,
        },
        {
            type = "button",
            name = "Clear Priority " .. tostring(index),
            func = function() SRT:ClearRole("priority", index) end,
            width = "full",
        },
    }
end

function SRT:RegisterLAMPanel()
    if self.lamRegistered then return true end
    local LAM = getLAM()
    if not LAM then return false end
    self.lam = LAM

    local panelData = {
        type = "panel",
        name = "Satuve Rotation Trainer",
        displayName = "Satuve Rotation Trainer",
        author = "Satuve",
        version = self.version or "0.6.37",
        registerForRefresh = true,
        registerForDefaults = false,
    }

    local options = {
        -- Keep a selectable control at the very top. Gamepad option bridges move
        -- focus between selectable controls; a description-only header can make
        -- the top of the panel impossible to reach with the controller.
        {
            type = "checkbox",
            name = "Trainer Enabled",
            getFunc = function() return SRT.sv.enabled == true end,
            setFunc = function(v) SRT.sv.enabled = v == true end,
            default = true,
            width = "full",
        },
        {
            type = "description",
            title = "Satuve Mods Support",
            text = "Need help, found a bug, or have a suggestion?\n\nJoin the official Satuve Mods Discord for bug reports, screenshots, help and feature suggestions.\n\nDiscord: discord.gg/UgPn6VK3us",
            width = "full",
        },
        {
            type = "button",
            name = "Scan QR Code",
            tooltip = "Open a large controller-friendly QR code for the Satuve Mods Discord.",
            func = function() SRT:OpenQRWindow() end,
            width = "full",
        },
        {
            type = "description",
            text = "Controller-ready settings. With LibGamepad installed, these controls are available directly in ESO's Gamepad Add-Ons menu.",
            width = "full",
        },
        {
            type = "header",
            name = "General",
        },
        {
            type = "dropdown",
            name = "Rotation Mode",
            choices = {"Dynamic", "Static"},
            choicesValues = {"dynamic", "static"},
            getFunc = function() return SRT.sv.rotationMode or "dynamic" end,
            setFunc = function(v)
                SRT.sv.rotationMode = v == "static" and "static" or "dynamic"
                SRT.staticStepIndex = 1
                SRT:ResetDynamicLockQueue()
                SRT:ClearHeldRecommendation()
                SRT:RefreshConfig()
            end,
            default = "dynamic",
            width = "full",
        },
        {
            type = "slider",
            name = "GCD / Coach Rhythm",
            tooltip = "Training rhythm in milliseconds. Minimum is 1000 ms.",
            min = 1000, max = 1500, step = 50,
            getFunc = function() return SRT:GetAdaptiveRhythmMs() end,
            setFunc = function(v)
                v = zo_clamp(tonumber(v) or 1000, 1000, 1500)
                SRT.sv.gcdMs = v
                SRT.sv.adaptiveRhythmMs = v
                SRT.sv.rhythmCalibrated = true
                SRT:RefreshConfig()
            end,
            default = 1000,
            width = "full",
        },
        {
            type = "slider",
            name = "Execute HP",
            min = 1, max = 100, step = 1,
            getFunc = function() return tonumber(SRT.sv.executeHp) or 25 end,
            setFunc = function(v) SRT.sv.executeHp = zo_clamp(tonumber(v) or 25, 1, 100); SRT:RefreshConfig() end,
            default = 25,
            width = "full",
        },
        {
            type = "submenu",
            name = "Flow & Timing",
            controls = {
                {
                    type = "slider", name = "Swap Before", min = 200, max = 1000, step = 50,
                    getFunc = function() return tonumber(SRT.sv.swapLeadMs) or 250 end,
                    setFunc = function(v) SRT.sv.swapLeadMs = zo_clamp(tonumber(v) or 250, 200, 1000); SRT:RefreshConfig() end,
                    default = 250, width = "full",
                },
                {
                    type = "slider", name = "Swap After", min = 200, max = 1000, step = 50,
                    getFunc = function() return tonumber(SRT.sv.swapTrailMs) or 200 end,
                    setFunc = function(v) SRT.sv.swapTrailMs = zo_clamp(tonumber(v) or 200, 200, 1000); SRT:RefreshConfig() end,
                    default = 200, width = "full",
                },
                {
                    type = "checkbox", name = "PRESS Hold (200 ms)",
                    getFunc = function() return SRT.sv.pressVisualHoldEnabled == true end,
                    setFunc = function(v)
                        SRT.sv.pressVisualHoldEnabled = v == true
                        SRT.visualPressHoldStartMs = nil
                        SRT.visualPressHoldDoneKey = nil
                        SRT:RefreshConfig()
                    end,
                    default = true, width = "full",
                },
                {
                    type = "checkbox", name = "Fixed Flow Speed",
                    tooltip = "ON = constant movement speed. OFF = adaptive easing/slowdown.",
                    getFunc = function() return SRT.sv.fixedFlowSpeed == true end,
                    setFunc = function(v) SRT.sv.fixedFlowSpeed = v == true; SRT:RefreshConfig() end,
                    default = false, width = "full",
                },
                {
                    type = "checkbox", name = "AHK Color Markers",
                    getFunc = function() return SRT.sv.ahkColorMarkersEnabled == true end,
                    setFunc = function(v) SRT.sv.ahkColorMarkersEnabled = v == true; SRT:RefreshConfig() end,
                    default = false, width = "full",
                },
            },
        },
        {
            type = "header",
            name = "Core Skills",
        },
        {
            type = "description",
            text = function() return roleDescription(SRT.sv.spammable) end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Spammable",
            choices = NORMAL_CHOICES, choicesValues = NORMAL_VALUES,
            getFunc = function() return currentValue(SRT.sv.spammable) end,
            setFunc = function(v) SRT:AssignRoleFromLAM("spammable", nil, v) end,
            width = "full",
        },
        {
            type = "description",
            text = function() return roleDescription(SRT.sv.execute) end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Execute",
            choices = NORMAL_CHOICES, choicesValues = NORMAL_VALUES,
            getFunc = function() return currentValue(SRT.sv.execute) end,
            setFunc = function(v) SRT:AssignRoleFromLAM("execute", nil, v) end,
            width = "full",
        },
        {
            type = "description",
            text = function() return roleDescription(SRT.sv.ultimate) end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Ultimate",
            choices = ULT_CHOICES, choicesValues = ULT_VALUES,
            getFunc = function() return currentValue(SRT.sv.ultimate) end,
            setFunc = function(v) SRT:AssignRoleFromLAM("ultimate", nil, v) end,
            width = "full",
        },
        {
            type = "header",
            name = "Priority Rotation",
        },
        {
            type = "description",
            text = "Maintained buffs and DoTs are skipped while active. Each Priority has its own Refresh Early value; the trainer only recommends it again when the remaining duration reaches that window.",
            width = "full",
        },
    }

    for i = 1, self.maxPriorities do
        options[#options + 1] = {
            type = "submenu",
            name = "Priority " .. tostring(i),
            controls = priorityControls(i),
        }
    end

    options[#options + 1] = {type="header", name="Tools"}
    options[#options + 1] = {
        type="button", name="20-Skill Route Preview",
        func=function() SRT:OpenRoutePreview() end,
        width="full",
    }
    options[#options + 1] = {
        type="button", name="Move Trainer",
        tooltip="Enter move mode. Use the existing D-Pad/arrow controls to position the trainer.",
        func=function() if SRT.moveMode then SRT:ExitMoveMode() else SRT:EnterMoveMode() end end,
        width="full",
    }
    options[#options + 1] = {
        type="button", name="Rhythm Test",
        func=function() if SRT.testMode then SRT:StopRhythmTest(false) else SRT:StartRhythmTest() end end,
        width="full",
    }
    options[#options + 1] = {
        type="button", name="Legacy Visual Setup",
        tooltip="Opens the original large mouse-oriented setup window as a fallback.",
        func=function() SRT:OpenConfig() end,
        width="full",
    }

    self.lamPanel = LAM:RegisterAddonPanel("SatuveRotationTrainerOptions", panelData)
    LAM:RegisterOptionControls("SatuveRotationTrainerOptions", options)
    self.lamRegistered = true
    return true
end

function SRT:OpenLAMSettings()
    if not self:RegisterLAMPanel() then
        self:OpenConfig()
        return false
    end
    if self.lam and self.lamPanel and self.lam.OpenToPanel then
        self.lam:OpenToPanel(self.lamPanel)
        return true
    end
    return false
end
