--------------------------------------------------------------------------------------------------
-- UI functions

-- moving the indicator on screen saves the position
function DA.OnMoveStop()
	DA.savedVariables.barleft = DA_COUNTER:GetLeft()
	DA.savedVariables.bartop = DA_COUNTER:GetTop()
end

function DA.RestorePosition()
	if not DA.savedVariables.barleft then
		DA.savedVariables.barleft = 300
		DA.savedVariables.bartop = 300
	end
	local barleft = DA.savedVariables.barleft
	local bartop = DA.savedVariables.bartop
	DA_COUNTER:ClearAnchors()
	DA_COUNTER:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, barleft, bartop)
end

function DA.CreateSceneCOUNTER()
	local fragment1 = ZO_HUDFadeSceneFragment:New(DA_COUNTER)
	HUD_SCENE:AddFragment(fragment1)
    HUD_UI_SCENE:AddFragment(fragment1)
end

function DA.initCOUNTER()
	DA.RestorePosition()
	DA.CreateSceneCOUNTER()
	--DA_COUNTERCount1:SetText(GetUnitName("player"))
end