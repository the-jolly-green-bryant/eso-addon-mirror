EPT = EPT or {}
local EPT = EPT


function EPT.InitializeMythic(self, setId)

end

function EPT.TerminateMythic(self, setId)
	self.guiList[setId].primaryInd.label:SetText(0)
	self.guiList[setId].secondaryInd.label:SetText(0)
end

function EPT:UpdateStackNumber(setId, stacks)
	local self = EPT
	local gui = self.guiList[setId].secondaryInd

	gui.label:SetText(stacks)
	if stacks == self.procSets[setId].maxstack then
		gui.label:SetColor(0,1,0,0.8)
    else
		gui.label:SetColor(0,1,1,0.8)
    end
end

function EPT:SecondaryIndicatorMythic(setId, win)
	local self = EPT
    local data = self:GetGuiData(setId)

    local ctrl = self.window:CreateControl(data.name.."MythicControl"..tostring(setId), win, CT_CONTROL )
    local offSet = data.nameOffSet

    ctrl:SetAnchor(LEFT, win, TOPRIGHT, offSet-5, offSet+5 )
    ctrl:SetHidden(false)

    local back = self.window:CreateControl(data.name.."MythicBackground"..tostring(setId), ctrl, CT_BACKDROP )
    back:SetAnchor( CENTER, ctrl, CENTER, 0, 0 )
    back:SetEdgeColor( 0, 0, 0, 1)
    back:SetCenterColor(0, 0, 0, 1)
    back:SetEdgeTexture( nil , data.edgeLine, data.edgeLine, data.edgeLine)
    back:SetHidden(true)

    local label = self.window:CreateControl(data.name.."MythicLabel"..tostring(setId), ctrl, CT_LABEL )
    label:SetAnchor(CENTER, ctrl, CENTER, 4, 0 )
    label:SetColor(0,1,1,0.8)
    label:SetFont(self:GetFont(data.design.indicator.font).."|"..math.floor(data.iconSize * 0.7 ).."|soft-shadow-thick")
    label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
    label:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
    label:SetText("00.0")

    local width = label:GetTextWidth()
    local height = label:GetTextHeight()

    ctrl:SetDimensions( width+20, height+12 )
    back:SetDimensions( width+15, height+7 )
    label:SetDimensions( width+15, height+7)

    return {
      ["ctrl"] = ctrl,
      ["back"] = back,
      ["label"] = label,
    }
end
