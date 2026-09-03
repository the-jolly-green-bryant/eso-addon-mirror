-- Discord.lua

ArcTech = ArcTech or {}
ArcTech.Discord = ArcTech.Discord or {}

local Discord = ArcTech.Discord

Discord.url = "https://discord.gg/naF4EXVREm"
Discord.initialised = false
Discord.window = nil
Discord.qrControl = nil
Discord.closeKeybindState = nil
Discord.guildKeybindAdded = false

local closeKeybind

-----------------------------------------------------------
-- Hide QR window
-----------------------------------------------------------

function Discord.Hide()
    if Discord.window then
        Discord.window:SetHidden(true)
    end

    if Discord.closeKeybindState then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(
            closeKeybind,
            Discord.closeKeybindState
        )

        KEYBIND_STRIP:PopKeybindGroupState()

        Discord.closeKeybindState = nil
    end

    PlaySound(SOUNDS.GAMEPAD_CLOSE_WINDOW)
end

-----------------------------------------------------------
-- Close QR keybind
-----------------------------------------------------------

closeKeybind = {
    alignment = KEYBIND_STRIP_ALIGN_LEFT,

    {
        keybind = "UI_SHORTCUT_NEGATIVE",
        name = GetString(SI_GAMEPAD_BACK_OPTION),

        callback = function()
            Discord.Hide()
        end,
    },
}

-----------------------------------------------------------
-- Create QR window
-----------------------------------------------------------

function Discord.CreateWindow()
    if Discord.window then
        return
    end

    if not LibQRCode then
        d("ArcTech: LibQRCode is not installed or enabled")
        return
    end

    local window = WINDOW_MANAGER:CreateTopLevelWindow(
        "ArcTechDiscordQRCodeWindow"
    )

    window:SetDimensions(520, 580)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetDrawTier(DT_HIGH)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetClampedToScreen(true)
    window:SetHidden(true)

    Discord.window = window

    -------------------------------------------------------
    -- Background
    -------------------------------------------------------

    local background = WINDOW_MANAGER:CreateControl(
        "ArcTechDiscordQRCodeBackground",
        window,
        CT_BACKDROP
    )

    background:SetAnchorFill()
    background:SetCenterColor(0.02, 0.02, 0.02, 0.98)
    background:SetEdgeColor(0.8, 0.7, 0.2, 1)

    background:SetEdgeTexture(
        "EsoUI/Art/Tooltips/UI-SliderBackdrop.dds",
        32,
        4
    )

    -------------------------------------------------------
    -- Title
    -------------------------------------------------------

    local title = WINDOW_MANAGER:CreateControl(
        "ArcTechDiscordQRCodeTitle",
        window,
        CT_LABEL
    )

    title:SetFont("ZoFontGamepadBold34")
    title:SetText("Join Arcanists Discord")
    title:SetColor(1, 0.85, 0.2, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    title:SetAnchor(
        TOPLEFT,
        window,
        TOPLEFT,
        20,
        20
    )

    title:SetAnchor(
        TOPRIGHT,
        window,
        TOPRIGHT,
        -20,
        20
    )

    -------------------------------------------------------
    -- QR code
    -------------------------------------------------------

    local qrControl = LibQRCode.CreateQRControl(
        400,
        Discord.url
    )

    qrControl:SetParent(window)
    qrControl:ClearAnchors()

    qrControl:SetAnchor(
        TOP,
        title,
        BOTTOM,
        0,
        20
    )

    Discord.qrControl = qrControl

    -------------------------------------------------------
    -- Description
    -------------------------------------------------------

    local description = WINDOW_MANAGER:CreateControl(
        "ArcTechDiscordQRCodeDescription",
        window,
        CT_LABEL
    )

    description:SetFont("ZoFontGamepad27")
    description:SetText("Open your camera app and scan this QR code with your phone to be invited into Arcanists Discord Server")
    description:SetColor(1, 1, 1, 1)
    description:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    description:SetAnchor(
        TOPLEFT,
        qrControl,
        BOTTOMLEFT,
        0,
        15
    )

    description:SetAnchor(
        TOPRIGHT,
        qrControl,
        BOTTOMRIGHT,
        0,
        15
    )
end

-----------------------------------------------------------
-- Show QR window
-----------------------------------------------------------

function Discord.Show()
    if not LibQRCode then
        d("ArcTech: LibQRCode is not installed or enabled")
        return
    end

    if not Discord.window then
        Discord.CreateWindow()
    end

    if not Discord.window then
        return
    end

    if not Discord.window:IsHidden() then
        return
    end

    Discord.window:SetHidden(false)

    Discord.closeKeybindState =
        KEYBIND_STRIP:PushKeybindGroupState()

    KEYBIND_STRIP:AddKeybindButtonGroup(
        closeKeybind,
        Discord.closeKeybindState
    )

    PlaySound(SOUNDS.GAMEPAD_OPEN_WINDOW)
end

-----------------------------------------------------------
-- Guild Discord keybind
-----------------------------------------------------------

local guildDiscordKeybind = {
    alignment = KEYBIND_STRIP_ALIGN_CENTER,

    {
        keybind = "UI_SHORTCUT_RIGHT_STICK",
        name = "Discord",

        callback = function()
            Discord.Show()
        end,
    },
}

local function RemoveGuildKeybind()
    if not Discord.guildKeybindAdded then
        return
    end

    KEYBIND_STRIP:RemoveKeybindButtonGroup(
        guildDiscordKeybind
    )

    Discord.guildKeybindAdded = false
end

local function AddGuildKeybind()
    RemoveGuildKeybind()

    KEYBIND_STRIP:AddKeybindButtonGroup(
        guildDiscordKeybind
    )

    KEYBIND_STRIP:UpdateKeybindButtonGroup(
        guildDiscordKeybind
    )

    Discord.guildKeybindAdded = true
end

-----------------------------------------------------------
-- Guild scene
-----------------------------------------------------------

local function InitializeGuildScene()
    local guildScene =
        SCENE_MANAGER:GetScene("gamepad_guild_hub")

    if not guildScene then
        d("ArcTech Discord: guild scene not found")
        return
    end

    guildScene:RegisterCallback(
        "StateChange",
        function(_, newState)
            if newState == SCENE_SHOWN then
                zo_callLater(function()
                    if guildScene:IsShowing() then
                        AddGuildKeybind()
                    end
                end, 500)

            elseif newState == SCENE_HIDING then
                Discord.Hide()
                RemoveGuildKeybind()

            elseif newState == SCENE_HIDDEN then
                RemoveGuildKeybind()
            end
        end
    )

    if guildScene:IsShowing() then
        zo_callLater(function()
            if guildScene:IsShowing() then
                AddGuildKeybind()
            end
        end, 500)
    end
end

-----------------------------------------------------------
-- Discord initialization
-----------------------------------------------------------

function Discord.Initialize()
    if Discord.initialised then
        return
    end

    Discord.initialised = true

    InitializeGuildScene()

    SLASH_COMMANDS["/discord"] = function()
        Discord.Show()
    end
end