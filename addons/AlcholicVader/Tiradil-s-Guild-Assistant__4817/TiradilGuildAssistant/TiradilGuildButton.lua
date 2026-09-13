
local function TryAddGuildHomeButton()
    local candidateNames = {
        "ZO_GuildHomeGuildInfo",
        "ZO_GuildHome",
        "ZO_GuildHomeKeyboard",
        "GuildHomeGuildInfo",
    }

    local targetControl = nil
    for _, name in ipairs(candidateNames) do
        local ctrl = _G[name]
        if ctrl and ctrl.GetNamedChild then
            targetControl = ctrl
            break
        end
    end

    if not targetControl then
        return
    end

    if _G["TiradilGuildHomeButton"] then
        return
    end

    local btn = WINDOW_MANAGER:CreateControl("TiradilGuildHomeButton", targetControl, CT_BUTTON)
    btn:SetDimensions(150, 44)
    btn:SetAnchor(BOTTOMRIGHT, targetControl, BOTTOMRIGHT, -10, -10)

    local bg = WINDOW_MANAGER:CreateControl(nil, btn, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.11, 0.11, 0.11, 0.95)
    bg:SetEdgeColor(0.165, 0.165, 0.2, 1)
    bg:SetEdgeTexture("", 1, 1, 0)

    local icon = WINDOW_MANAGER:CreateControl(nil, btn, CT_TEXTURE)
    icon:SetDimensions(24, 24)
    icon:SetAnchor(LEFT, btn, LEFT, 10, 0)
    icon:SetTexture("EsoUI/Art/LFG/LFG_tabIcon_groupTools_up.dds")

    local label = WINDOW_MANAGER:CreateControl(nil, btn, CT_LABEL)
    label:SetAnchor(LEFT, icon, RIGHT, 8, 0)
    label:SetAnchor(RIGHT, btn, RIGHT, -8, 0)
    label:SetFont("ZoFontGameSmall")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    label:SetColor(0.72, 0.72, 0.75, 1)
    label:SetText((TiradilL10n and TiradilL10n.Get("SUITE_TITLE")) or "Tiradil Suite")

    btn:SetHandler("OnMouseEnter", function(self)
        label:SetColor(0.788, 0.631, 0.353, 1)
        icon:SetTexture("EsoUI/Art/LFG/LFG_tabIcon_groupTools_over.dds")
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -5, TOPRIGHT)
        SetTooltipText(InformationTooltip, (TiradilL10n and TiradilL10n.Get("GUILD_BUTTON_TOOLTIP")) or "Click to open Tiradil's Guild Assistant. You can also type /tga at any time.")
    end)
    btn:SetHandler("OnMouseExit", function()
        label:SetColor(0.72, 0.72, 0.75, 1)
        icon:SetTexture("EsoUI/Art/LFG/LFG_tabIcon_groupTools_up.dds")
        ClearTooltip(InformationTooltip)
    end)
    btn:SetHandler("OnClicked", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            icon:SetTexture("EsoUI/Art/LFG/LFG_tabIcon_groupTools_down.dds")
            zo_callLater(function() icon:SetTexture("EsoUI/Art/LFG/LFG_tabIcon_groupTools_over.dds") end, 120)
            if TiradilSuite and TiradilSuite.ToggleWindow then
                TiradilSuite.ToggleWindow()
            end
        end
    end)
end

function TiradilGuildButton_TryInitialize()
    pcall(TryAddGuildHomeButton)
end
