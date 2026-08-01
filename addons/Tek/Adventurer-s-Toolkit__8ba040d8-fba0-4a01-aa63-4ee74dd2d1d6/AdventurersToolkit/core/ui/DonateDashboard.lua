-- ============================================
-- DONATE DASHBOARD
-- ============================================
NWT.DonateDashboard = { isOpen = false }

function NWT.InitDonateDashboardScene()
    if DONATE_DASHBOARD_SCENE then return end
    local ui = ATK_Donate_UI or ATK_Donate_UI
    if not ui then return end
    DONATE_DASHBOARD_SCENE = ZO_Scene:New("donateDashboardScene", SCENE_MANAGER)
    DONATE_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    DONATE_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    DONATE_DASHBOARD_SCENE:AddFragment(ZO_SimpleSceneFragment:New(ui))
    
    NWT.DonateKeybinds = { alignment = KEYBIND_STRIP_ALIGN_LEFT }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(NWT.DonateKeybinds, GAME_NAVIGATION_TYPE_BUTTON, function() NWT.CloseDonateDashboard() end)
    DONATE_DASHBOARD_SCENE:RegisterCallback("StateChange", function(os, ns)
        if ns == SCENE_SHOWING then if KEYBIND_STRIP then KEYBIND_STRIP:AddKeybindButtonGroup(NWT.DonateKeybinds) end NWT.DonateDashboard.isOpen = true
        elseif ns == SCENE_HIDDEN then if KEYBIND_STRIP then KEYBIND_STRIP:RemoveKeybindButtonGroup(NWT.DonateKeybinds) end NWT.DonateDashboard.isOpen = false end
    end)
end

function NWT.OpenDonateDashboard()
    if NWT.DonateDashboard.isOpen then return end
    if not DONATE_DASHBOARD_SCENE then NWT.InitDonateDashboardScene() end
    NWT.GenerateDonateQRCode()
    SCENE_MANAGER:Push("donateDashboardScene")
end

function NWT.GenerateDonateQRCode()
    local ui = ATK_Donate_UI or ATK_Donate_UI
    if not ui then return end
    local rightPanel = ui:GetNamedChild("RightPanel")
    if not rightPanel then return end
    local qr = rightPanel:GetNamedChild("QRContainer")
    if not qr then return end
    if NWT.donateQRControl then NWT.donateQRControl:SetHidden(true) NWT.donateQRControl:ClearAnchors() end
    if LibQRCode then
        NWT.donateQRControl = LibQRCode.CreateQRControl(300, "https://paypal.me/tekatsu23")
        if NWT.donateQRControl then NWT.donateQRControl:SetParent(qr) NWT.donateQRControl:ClearAnchors() NWT.donateQRControl:SetAnchor(CENTER, qr, CENTER, 0, 0) NWT.donateQRControl:SetHidden(false) end
    else
        if not NWT.donateNoQRLabel then
            NWT.donateNoQRLabel = WINDOW_MANAGER:CreateControl("NWT_DonateNoQR", qr, CT_LABEL)
            NWT.donateNoQRLabel:SetFont("ZoFontGamepad27") NWT.donateNoQRLabel:SetColor(1, 1, 0, 1) NWT.donateNoQRLabel:SetText("Install LibQRCode addon\nto see QR code here")
            NWT.donateNoQRLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER) NWT.donateNoQRLabel:SetAnchor(CENTER, qr, CENTER, 0, 0)
        end
        NWT.donateNoQRLabel:SetHidden(false)
    end
end

function NWT.CloseDonateDashboard() if DONATE_DASHBOARD_SCENE then SCENE_MANAGER:Hide("donateDashboardScene") end end
