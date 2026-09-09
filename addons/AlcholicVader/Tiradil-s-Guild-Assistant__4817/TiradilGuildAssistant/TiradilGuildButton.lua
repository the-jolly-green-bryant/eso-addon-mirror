
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
    btn:SetDimensions(120, 28)
    btn:SetAnchor(BOTTOMRIGHT, targetControl, BOTTOMRIGHT, -10, -10)
    btn:SetFont("ZoFontGameSmall")

    local bg = WINDOW_MANAGER:CreateControl(nil, btn, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.11, 0.11, 0.11, 0.95)
    bg:SetEdgeColor(0.165, 0.165, 0.2, 1)
    bg:SetEdgeTexture("", 1, 1, 0)

    local label = WINDOW_MANAGER:CreateControl(nil, btn, CT_LABEL)
    label:SetAnchorFill()
    label:SetFont("ZoFontGameSmall")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(0.72, 0.72, 0.75, 1)
    label:SetText((TiradilL10n and TiradilL10n.Get("SUITE_TITLE")) or "Tiradil Suite")

    btn:SetHandler("OnMouseEnter", function() label:SetColor(0.788, 0.631, 0.353, 1) end)
    btn:SetHandler("OnMouseExit", function() label:SetColor(0.72, 0.72, 0.75, 1) end)
    btn:SetHandler("OnClicked", function()
        if TiradilSuite and TiradilSuite.ToggleWindow then
            TiradilSuite.ToggleWindow()
        end
    end)
end

function TiradilGuildButton_TryInitialize()
    pcall(TryAddGuildHomeButton)
end
