--------------------------------------------------------------------------------
--                   Zolan's Chat Notification (Visual Alert)                 --
--------------------------------------------------------------------------------
local ZCN         = Zolan_CN
local VisualAlert = ZCN.VisualAlert

-- ZO
local PlaySound = PlaySound

function VisualAlert.initializeWindow()

    local screenWidth  = GuiRoot:GetWidth()
    local screenHeight = GuiRoot:GetHeight()
    d(screenWidth)
    d(screenHeight)


    VisualAlert.UI.window = WINDOW_MANAGER:CreateTopLevelWindow("ZCN_VisualAlert")
    --
    VisualAlert.UI.window:SetDimensions(100, 100)
    VisualAlert.UI.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    VisualAlert.UI.window:SetClampedToScreen(true)
    VisualAlert.UI.window:SetMouseEnabled(true)
    VisualAlert.UI.window:SetMovable(true)
    VisualAlert.UI.window:SetHidden(false)
    VisualAlert.UI.window:SetAlpha(75)
    VisualAlert.UI.window:SetScale(1)

    VisualAlert.UI.backdrop = WINDOW_MANAGER:CreateControl("ZCN_VisualAlert_BD", VisualAlert.UI.window, CT_BACKDROP)
    --
    VisualAlert.UI.backdrop:SetDimensions(100 * 1.5, 100 * 1.7)
    VisualAlert.UI.backdrop:SetAnchor(CENTER, VisualAlert.UI.window, CENTER, 22, 7)
    -- VisualAlert.UI.backdrop:SetTexture([[/esoui/art/actionbar/magechamber_lightningspelloverlay_up.dds]])
    VisualAlert.UI.backdrop:SetCenterColor(255,0,0)
end

function VisualAlert.alertForConfKey(confKey)
    ZCN.debug("VisualAlert -> alertForConfKey -> " .. confKey)
--
--    if ZCN.savedVars.audio.enabled and ZCN.savedVars.audio[confKey].enabled  then
--        ZCN.debug("+_ VisualAlert: Playing Sound.")
--        PlaySound(ZCN.savedVars.audio[confKey].sound)
--    end
end
