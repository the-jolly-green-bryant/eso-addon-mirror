FrankGrinder_Gamepad = {}

local BUTTON_WIDTH  = 260
local BUTTON_HEIGHT = 40
local BUTTON_GAP    = 16

function FrankGrinder_Gamepad:Initialize()
    -- Root control
    local root = WINDOW_MANAGER:CreateControl("FrankGrinder_GamepadRoot", GuiRoot, CT_CONTROL)
    self.control = root
    root:SetDimensions(1280, 720)
    root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
    root:SetHidden(true)

    -- Simple title label
    local title = WINDOW_MANAGER:CreateControl(nil, root, CT_LABEL)
    title:SetFont("ZoFontGamepad42")
    title:SetText("FrankGrinder Mailer")
    title:SetAnchor(TOPLEFT, root, TOPLEFT, 60, 60)

    self.buttons = {}
    self:CreateButtons()
    self:SetupKeybinds()
end

function FrankGrinder_Gamepad:CreateButtons()
    local root = self.control
    local labels = { "Items", "Directed", "Mats" }

    local function makeButton(index, label, clickFn)
        local btn = CreateControlFromVirtual(
            "FrankGrinder_GamepadButton" .. index,
            root,
            "ZO_GamepadButtonTemplate"
        )

        btn:SetDimensions(BUTTON_WIDTH, BUTTON_HEIGHT)

        if index == 1 then
            btn:SetAnchor(TOPLEFT, root, TOPLEFT, 60, 120)
        else
            btn:SetAnchor(TOPLEFT, self.buttons[index - 1], BOTTOMLEFT, 0, BUTTON_GAP)
        end

        btn:SetText(label)
        btn:SetHandler("OnClicked", clickFn)

        self.buttons[index] = btn
    end

    makeButton(1, "Items", function()
        FrankGrinder:StartMailing(function()
            FrankGrinder:BuildQueue_LooseItems()
        end)
    end)

    makeButton(2, "Directed", function()
        FrankGrinder:StartMailing(function()
            FrankGrinder:BuildQueue_Directed()
        end)
    end)

    makeButton(3, "Mats", function()
        FrankGrinder:StartMailing(function()
            FrankGrinder:BuildQueue_Mats()
        end)
    end)
end

function FrankGrinder_Gamepad:SetupKeybinds()
    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,

        {
            name = "Send All",
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function()
                -- Your pipeline already sends as soon as queue is built,
                -- so this is optional. You can hook something here later if needed.
            end,
        },

        {
            name = "Cancel",
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function()
                FrankGrinder:ResetMailer()
            end,
        },
    }
end

function FrankGrinder_Gamepad:Activate()
    if not IsInGamepadPreferredMode() then
        self.control:SetHidden(true)
        return
    end

    self.control:SetHidden(false)
    KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
end

function FrankGrinder_Gamepad:Deactivate()
    self.control:SetHidden(true)
    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
end