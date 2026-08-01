local wtb = WTBConduits

function wtb.ToggleMovable()
     local tankName = wtb.sv.tankName
     local tankName2 = wtb.sv.tankName2
     local tankName3 = wtb.sv.tankName3
     wtb.isMovable = not wtb.isMovable
     if wtb.isMovable then
          WTBConduitsFrame:SetHidden(false)
          WTBConduitsFrame:SetMovable(true)
          WTBConduitsFrameLabel:SetText("|cccccff" .. tankName .. "|r needs a |cff0000Synergy!|r")
          if wtb.sv.enableTank2 then
               WTBConduitsFrame2:SetHidden(false)
               WTBConduitsFrame2:SetMovable(true)
               WTBConduitsFrame2Label:SetText("|cccccff" .. tankName2 .. "|r needs a |cff0000Synergy!|r")
          end
          if wtb.sv.enableTank3 then
               WTBConduitsFrame3:SetHidden(false)
               WTBConduitsFrame3:SetMovable(true)
               WTBConduitsFrame3Label:SetText("|cccccff" .. tankName3 .. "|r needs a |cff0000Synergy!|r")
          end
          wtb:ShowArrow("player")
     else
          WTBConduitsFrame:SetHidden(true)
          WTBConduitsFrame:SetMovable(false)
          WTBConduitsFrame2:SetHidden(true)
          WTBConduitsFrame2:SetMovable(false)
          WTBConduitsFrame3:SetHidden(true)
          WTBConduitsFrame3:SetMovable(false)
          wtb:HideArrow()
     end
end

function wtb.SavePosition()
     wtb.sv.offsetX = WTBConduitsFrame:GetLeft()
     wtb.sv.offsetY = WTBConduitsFrame:GetTop()
     wtb.sv.offsetX2 = WTBConduitsFrame2:GetLeft()
     wtb.sv.offsetY2 = WTBConduitsFrame2:GetTop()
     wtb.sv.offsetX3 = WTBConduitsFrame3:GetLeft()
     wtb.sv.offsetY3 = WTBConduitsFrame3:GetTop()
end

function wtb.ResetAnchors()
     WTBConduitsFrame:ClearAnchors()
     WTBConduitsFrame2:ClearAnchors()
     WTBConduitsFrame3:ClearAnchors()
     WTBConduitsFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, wtb.sv.offsetX, wtb.sv.offsetY)
     WTBConduitsFrame2:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, wtb.sv.offsetX2, wtb.sv.offsetY2)
     WTBConduitsFrame3:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, wtb.sv.offsetX3, wtb.sv.offsetY3)
end

function wtb.SetFontSize(label, size)
     local label = label
     local size = size
     local path = "EsoUI/Common/Fonts/univers67.otf"
     local outline = "soft-shadow-thick"
     label:SetFont(path .. "|" .. size .. "|" .. outline)
end
