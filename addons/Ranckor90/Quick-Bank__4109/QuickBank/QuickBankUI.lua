QuickBankUI = {}

function QuickBankUI.CreatePanel()
    if QuickBankUI.panel then return end

    local wm = WINDOW_MANAGER
    local panel = wm:CreateTopLevelWindow("QuickBankUIPanel")
    panel:SetDimensions(180, 200)
    panel:SetMovable(true)
    panel:SetMouseEnabled(true)
    panel:SetClampedToScreen(true)
    panel:SetHidden(true)

    panel.bg = wm:CreateControl(nil, panel, CT_BACKDROP)
    panel.bg:SetAnchorFill()
    panel.bg:SetCenterColor(0, 0, 0, 0.6)

    local pos = QuickBank.savedVars.panelPos
    panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.left, pos.top)
    panel:SetHandler("OnMoveStop", function()
        local l, t = panel:GetLeft(), panel:GetTop()
        QuickBank.savedVars.panelPos = { left = l, top = t }
    end)

    -- Title Text
    panel.title = wm:CreateControl(nil, panel, CT_LABEL)
    panel.title:SetFont("ZoFontGameLargeBold")
    panel.title:SetText("Quick Bank")
    panel.title:SetAnchor(TOPLEFT, panel, TOPLEFT, 10, 8)
    panel.title:SetDimensions(140, 25)
    panel.title:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    panel.title:SetMouseEnabled(true)
    panel.title:SetHandler("OnMouseUp", function()
        RequestOpenUnsafeURL("https://illyriat.com/")
    end)

    -- Version Text
    panel.version = wm:CreateControl(nil, panel, CT_LABEL)
    panel.version:SetFont("ZoFontGameSmall")
    panel.version:SetText("v1.0.1")
    panel.version:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -10, 12)
    panel.version:SetDimensions(30, 15)

    local currencies = {
        {
            label = "Deposit Gold",
            type = CURT_MONEY,
            setting = "depositGold",
            func = function(amt) DepositMoneyIntoBank(amt) end,
        },
        {
            label = "Deposit AP",
            type = CURT_ALLIANCE_POINTS,
            setting = "depositAP",
            func = function(amt) DepositCurrencyIntoBank(CURT_ALLIANCE_POINTS, amt) end,
        },
        {
            label = "Deposit Tel Var",
            type = CURT_TELVAR_STONES,
            setting = "depositTelVar",
            func = function(amt) DepositCurrencyIntoBank(CURT_TELVAR_STONES, amt) end,
        },
        {
            label = "Deposit Writs",
            type = CURT_WRIT_VOUCHERS,
            setting = "depositWrits",
            func = function(amt) DepositCurrencyIntoBank(CURT_WRIT_VOUCHERS, amt) end,
        },
    }

    for i, entry in ipairs(currencies) do
        local btn = wm:CreateControlFromVirtual("QuickBankButton"..i, panel, "ZO_DefaultButton")
        btn:SetDimensions(160, 30)
        btn:SetAnchor(TOPLEFT, panel, TOPLEFT, 10, 40 + (i - 1) * 35)
        btn:SetText(entry.label)
        btn:SetHandler("OnClicked", function()
            if IsBankOpen() then
                local amt = GetCarriedCurrencyAmount(entry.type)
                if amt > 0 then
                    if QuickBank.savedVars[entry.setting] then
                        entry.func(amt)
                        d("QuickBank: Deposited "..amt.." "..entry.label)
                    else
                        d("QuickBank: "..entry.label.." deposit is disabled in settings")
                    end
                else
                    d("QuickBank: No "..entry.label.." to deposit")
                end
            else
                d("QuickBank: Bank must be open to deposit")
            end
        end)
    end

    QuickBankUI.panel = panel
end

function QuickBankUI.OnBankOpen()
    QuickBankUI.CreatePanel()
    if QuickBankUI.panel then
        QuickBankUI.panel:SetHidden(false)
    end
end
