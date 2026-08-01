QRH = QRH or {}
local QRH = QRH

-- TODO: Move to util.
-- [!] adjust label scale and draw order
local function AdjustLabelForIcon(icon)
    local order = icon.ctrl:GetDrawLevel() + 1
    icon.myLabel:SetDrawLevel( order )
end

function QRH.SetOaxiltsoPoolsIcons()
  if not QRH.status.poolLabelsEnabled and QRH.hasOSI() then
    QRH.status.poolLabelsEnabled = true
    --d("[QRH] Enabling pool labels on all 4 pools")
    local texture = "QcellRockgroveHelper/icons/square_green.dds"
    for i=1, 4 do
      local icon = OSI.CreatePositionIcon(
        QRH.data.oaxiltso_pools[i][1],
        --QRH.data.oaxiltso_pools[i][2],
        QRH.data.oaxiltso_pools_render_y,
        QRH.data.oaxiltso_pools[i][3],
        texture,
        OSI.GetIconSize() * 2)
      if icon then
        if not icon.myLabel then
          icon.myLabel = icon.ctrl:CreateControl( icon.ctrl:GetName() .. "Label", CT_LABEL )
          icon.myLabel:SetAnchor( CENTER, icon.ctrl, CENTER, 0, 0 )
          icon.myLabel:SetFont( "$(BOLD_FONT)|$(KB_54)|outline" )
          icon.myLabel:SetScale(3)
          icon.myLabel:SetDrawLayer( DL_BACKGROUND )
          icon.myLabel:SetDrawTier( DT_LOW )
          icon.myLabel:SetColor(0.9,0.9,0.9,0.85)
          AdjustLabelForIcon(icon)
          
          icon.myLabel:SetText( tostring(i))
          icon.myTimer = GetGameTimeSeconds() -- + 35 for debugging
          icon.myLabel:SetHidden( false )
        end
      end
      QRH.status.oaxiltso_pool_icons[i] = icon
    end
  end
end

function QRH.HideOaxiltsoPoolsIcons()
  if QRH.hasOSI() and QRH.status.poolLabelsEnabled then
    for i=1, 4 do
      if QRH.status.oaxiltso_pool_icons[i] ~= nil then
        OSI.DiscardPositionIcon(QRH.status.oaxiltso_pool_icons[i])
        QRH.status.oaxiltso_pool_icons[i] = nil
      end
    end
    QRH.status.poolLabelsEnabled = false
  else
    --d("QRH.HideOaxiltsoPoolsIcons() with poolLabelsEnabled = false")
  end
end

function QRH.SetXalvakkaSplitIcons()
  if not QRH.status.xalvakkaSplitLabelsEnabled and QRH.hasOSI() then
    QRH.status.xalvakkaSplitLabelsEnabled = true
    --d("[QRH] Enabling Xalvakka split labels on all 3 shells 2nd FLOOR")
    local texture = "QcellRockgroveHelper/icons/green_sq.dds"
    for i=1, 3 do
      local icon = OSI.CreatePositionIcon(
        QRH.data.xalvakka_split[i][1],
        QRH.data.xalvakka_split[i][2],
        QRH.data.xalvakka_split[i][3],
        texture,
        OSI.GetIconSize() * 2)
      if icon then
        if not icon.myLabel then
          icon.myLabel = icon.ctrl:CreateControl( icon.ctrl:GetName() .. "Label", CT_LABEL )
          icon.myLabel:SetAnchor( CENTER, icon.ctrl, CENTER, 0, 0 )
          icon.myLabel:SetFont( "$(BOLD_FONT)|$(KB_54)|outline" )
          icon.myLabel:SetScale(3)
          icon.myLabel:SetDrawLayer( DL_BACKGROUND )
          icon.myLabel:SetDrawTier( DT_LOW )
          icon.myLabel:SetColor(0.9,0.9,0.9,0.85)
          AdjustLabelForIcon(icon)

          --icon.myLabel:SetText("INIT")
          --icon.myTimer = GetGameTimeSeconds() + 35
          icon.myLabel:SetHidden( false )
        end
      end
      QRH.status.xalvakka_split_icons[i] = icon
    end
  end
end

function QRH.SetXalvakkaSplitIconsLastFloor()
  if not QRH.status.xalvakkaSplitLabelsLastFloorEnabled and QRH.hasOSI() then
    QRH.status.xalvakkaSplitLabelsLastFloorEnabled = true
    --d("[QRH] Enabling Xalvakka split labels on all 3 shells LAST FLOOR")
    local texture = "QcellRockgroveHelper/icons/green_sq.dds"
    for i=1, 3 do
      local icon = OSI.CreatePositionIcon(
        QRH.data.xalvakka_split_3[i][1],
        QRH.data.xalvakka_split_3[i][2],
        QRH.data.xalvakka_split_3[i][3],
        texture,
        OSI.GetIconSize() * 2)
      if icon then
        if not icon.myLabel then
          icon.myLabel = icon.ctrl:CreateControl( icon.ctrl:GetName() .. "Label", CT_LABEL )
          icon.myLabel:SetAnchor( CENTER, icon.ctrl, CENTER, 0, 0 )
          icon.myLabel:SetFont( "$(BOLD_FONT)|$(KB_30)|outline" )
          icon.myLabel:SetScale(3)
          icon.myLabel:SetDrawLayer( DL_BACKGROUND )
          icon.myLabel:SetDrawTier( DT_LOW )
          icon.myLabel:SetColor(0.9,0.9,0.9,0.85)
          AdjustLabelForIcon(icon)

          icon.myLabel:SetHidden( false )
        end
      end
      QRH.status.xalvakka_split_icons_3[i] = icon
    end
  end
end

function QRH.HideXalvakkaSplitIcons()
  if QRH.hasOSI() and QRH.status.xalvakkaSplitLabelsEnabled then
    --d("[QRH] HideXalvakkaSplitIcons()")
    for i=1, 3 do
      if QRH.status.xalvakka_split_icons[i] ~= nil then
        OSI.DiscardPositionIcon(QRH.status.xalvakka_split_icons[i])
        QRH.status.xalvakka_split_icons[i] = nil
      end
    end
    QRH.status.xalvakkaSplitLabelsEnabled = false
  end
end

function QRH.HideXalvakkaSplitIconsLastFloor()
  if QRH.hasOSI() and QRH.status.xalvakkaSplitLabelsLastFloorEnabled then
    --d("[QRH] HideXalvakkaSplitIconsLastFloor()")
    for i=1, 3 do
      if QRH.status.xalvakka_split_icons_3[i] ~= nil then
        OSI.DiscardPositionIcon(QRH.status.xalvakka_split_icons_3[i])
        QRH.status.xalvakka_split_icons_3[i] = nil
      end
    end
    QRH.status.xalvakkaSplitLabelsLastFloorEnabled = false
  end
end
