PearlsTracker = PearlsTracker or {}
PearlsTracker.icon = PearlsTracker.icon or {}

local PT = PearlsTracker
PT.icon.Fragment = ZO_HUDFadeSceneFragment:New(PearlsTrackerPanel, nil, 0)


function PT.icon.Restore()
    PearlsTrackerPanel:SetClampedToScreen(true)
    PT.icon.SetIcon()
    PT.icon.SetBackgroundTexture()
    PT.icon.SetPosition(PT.SV.panel.posX, PT.SV.panel.posY)
    PT.icon.SetResourceFontSize(PT.SV.resource.fontSize)
    PT.icon.SetUltiGainFontSize(PT.SV.ultiGain.fontSize)
    PT.icon.SetResourceColor(unpack(PT.SV.colors.aboveThreshold))
    PT.icon.SetUltiGainColor(unpack(PT.SV.colors.ultiGain))
    PT.icon.SetIconSize(PT.SV.icon.size)
    PT.icon.SetIconBackgroundOpacity(PT.SV.background.opacity)
    PT.icon.SetBackgroundOutlineWidth(PT.SV.background.outlineWidth)
    PT.icon.SetBackgroundOutlineColor(0, 0 , 0 ,1)
    PT.icon.HideIcon(PT.SV.icon.hide)
    PT.icon.HideResource(PT.SV.resource.hide)
    PT.icon.HideBackground(PT.SV.background.hide)
    PT.icon.HideUltiGain(PT.SV.ultiGain.hide)
    PT.icon.Hide(not PT.IsPearlsEquiped())
end


function PT.icon.SetIcon()
    local itemIconTexture = GetItemLinkIcon(PT.PEARLS_ITEM_LINK)
    PearlsTrackerPanel_Icon:SetTexture(itemIconTexture)
end

function PT.icon.Hide(value)
    if value then
        HUD_SCENE:RemoveFragment(PT.icon.Fragment)
        HUD_UI_SCENE:RemoveFragment(PT.icon.Fragment)
        PT.isHidden = true
        return
    end

    if PT.isHidden then
        HUD_SCENE:AddFragment(PT.icon.Fragment)
        HUD_UI_SCENE:AddFragment(PT.icon.Fragment)
        PT.isHidden = false
        return
    end
end

function PT.icon.HideIcon(value)
    PearlsTrackerPanel_Icon:SetHidden(value)
end
function PT.icon.HideResource(value)
    PearlsTrackerPanel_Resource:SetHidden(value)
end
function PT.icon.HideBackground(value)
    PearlsTrackerPanel_Icon_Background:SetHidden(value)
end
function PT.icon.HideUltiGain(value)
    PearlsTrackerPanel_UltiGain:SetHidden(value)
end
-- Load Icon location
function PT.icon.SetPosition(x, y)
    PearlsTrackerPanel:ClearAnchors()
    PearlsTrackerPanel:SetAnchor(CENTER, GuiRoot, TOPLEFT, x, y)
end

-- Set fonts
function PT.icon.SetResourceFontSize(fontSize)
    local font = string.format('%s|%d|%s', '$(CHAT_FONT)', fontSize, 'soft-shadow-thick')
    PearlsTrackerPanel_Resource:SetFont(font)
end
function PT.icon.SetUltiGainFontSize(fontSize)
    local font = string.format('%s|%d|%s', '$(CHAT_FONT)', fontSize, 'soft-shadow-thick')
    PearlsTrackerPanel_UltiGain:SetFont(font)
end

function PT.icon.SetIconSize(iconSize)
    PearlsTrackerPanel_Icon:SetDimensions(iconSize, iconSize)
    PearlsTrackerPanel_Icon_Background:SetDimensions(iconSize, iconSize)
end

function PT.icon.SetResourceColor(r, g, b, a)
    PearlsTrackerPanel_Resource:SetColor(r, g, b, a)
end
function PT.icon.SetResourceValue(value)
    PearlsTrackerPanel_Resource:SetText(string.format("%d", value))
end
function PT.icon.SetUltiGainValue(value)
    PearlsTrackerPanel_UltiGain:SetText(string.format("%d", value))
end

function PT.icon.SetIconBackgroundOpacity(opacity)
    PearlsTrackerPanel_Icon_Background:SetAlpha(opacity / 100)
end


function PT.icon.SetBackgroundTexture()
    PearlsTrackerPanel_Icon_Background:SetCenterTexture(nil, 4, TEX_MODE_WRAP)
end

function PT.icon.SetBackgroundOutlineWidth(width)
    -- wee need a power of 2 here
    local lineWidth = zo_pow(2, zo_ceil(math.log(width)/math.log(2)))
    if lineWidth <= 1 then lineWidth = 2 end

    PearlsTrackerPanel_Icon_Background:SetEdgeTexture(nil, lineWidth, lineWidth, lineWidth, 0)
end

function PT.icon.SetBackgroundOutlineColor(r, g, b, a)
    PearlsTrackerPanel_Icon_Background:SetEdgeColor(r, g, b, a)
end

function PT.icon.SetUltiGainColor(r, g, b ,a)
    PearlsTrackerPanel_UltiGain:SetColor(r, g, b, a)
end


-- Move Icon
function PT.icon.OnMove()
    PT.SV.panel.posX, PT.SV.panel.posY = PearlsTrackerPanel:GetCenter()

    PearlsTrackerPanel:ClearAnchors()
    PearlsTrackerPanel:SetAnchor(CENTER, GuiRoot, TOPLEFT, PT.SV.panel.posX, PT.SV.panel.posY)
end













