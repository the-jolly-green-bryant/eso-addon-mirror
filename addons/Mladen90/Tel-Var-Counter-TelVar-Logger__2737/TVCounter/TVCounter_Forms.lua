TVC_FORMS.MainWindow = nil
TVC_FORMS.MainWindowBackGround = nil
TVC_FORMS.MainWindowText = nil


TVC_FORMS.FragmentText1 = nil
TVC_FORMS.FragmentText2 = nil


TVC_FORMS.Functions = {}


TVC_FORMS.Functions.Init = function(left, bottom)
	TVC_FORMS.MainWindow = WINDOW_MANAGER:CreateTopLevelWindow()

	TVC_FORMS.MainWindow:SetClampedToScreen(true)
	TVC_FORMS.MainWindow:SetAlpha(1)

	--if (TVC.SavedVariables.DisplayScreenMessageResourceName) then TVC_FORMS.MainWindow:SetDimensions(500 * TVC.SavedVariables.ScreenMessageScaling, 80 * TVC.SavedVariables.ScreenMessageScaling)
	--else TVC_FORMS.MainWindow:SetDimensions(350 * TVC.SavedVariables.ScreenMessageScaling, 80 * TVC.SavedVariables.ScreenMessageScaling) end
	TVC_FORMS.MainWindow:SetDimensions(350 * TVC.SavedVariables.ScreenMessageScaling, 80 * TVC.SavedVariables.ScreenMessageScaling)

	if left and bottom then
		TVC_FORMS.MainWindow:SetAnchor(BOTTOMLEFT, GuiRoot, TOPLEFT, left, bottom)
	else
		TVC_FORMS.MainWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
		TVC.SavedVariables.MainWindowLeft = TVC_FORMS.MainWindow:GetLeft()
		TVC.SavedVariables.MainWindowBottom = TVC_FORMS.MainWindow:GetBottom()
	end

	TVC_FORMS.MainWindowBackGround = WINDOW_MANAGER:CreateControl(nil, TVC_FORMS.MainWindow, CT_BACKDROP)
	TVC_FORMS.MainWindowBackGround:SetEdgeColor(1, 1, 1, 0.5)
	TVC_FORMS.MainWindowBackGround:SetCenterColor(0, 0, 0, 0.8)
	TVC_FORMS.MainWindowBackGround:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 0)
	TVC_FORMS.MainWindowBackGround:SetDimensions(TVC_FORMS.MainWindow:GetWidth(), TVC_FORMS.MainWindow:GetHeight())
	TVC_FORMS.MainWindowBackGround:SetDrawLayer(0)
	TVC_FORMS.MainWindowBackGround:SetAlpha(0)

	TVC_FORMS.MainWindowText = WINDOW_MANAGER:CreateControl(nil, TVC_FORMS.MainWindow, CT_LABEL)
	TVC_FORMS.MainWindowText:SetText("TVC SCREEN MESSAGE")
	TVC_FORMS.MainWindowText:SetColor(1, 1, 1)
	TVC_FORMS.MainWindowText:SetFont("ZoFontCallout3")
	TVC_FORMS.MainWindowText:SetDrawLayer(0)
	TVC_FORMS.MainWindowText:SetAnchor(CENTER, nil, CENTER, 0, 0)
	TVC_FORMS.MainWindowText:SetAlpha(0)
	TVC_FORMS.MainWindowText:SetScale(0.5 * TVC.SavedVariables.ScreenMessageScaling)
end


TVC_FORMS.Functions.DisplayScreenMessage = function(text1, text2)
	if TVC_FORMS.FragmentText1 then TVC_FORMS.FragmentText1:Hide(0) end
	if TVC_FORMS.FragmentText2 then TVC_FORMS.FragmentText2:Hide(0) end

	local moveY = 0

	if not TVC_IsStringEmpty(text1) then
		local lblText1 = WINDOW_MANAGER:CreateControl(nil, TVC_FORMS.MainWindow, CT_LABEL)
		lblText1:SetText(text1)
		lblText1:SetColor(TVC.SavedVariables.ScreenMessageColor.Red, TVC.SavedVariables.ScreenMessageColor.Green, TVC.SavedVariables.ScreenMessageColor.Blue, 1)
		lblText1:SetFont("ZoFontCallout3")
		lblText1:SetScale(0.5 * TVC.SavedVariables.ScreenMessageScaling)
		lblText1:SetDrawLayer(1)
		lblText1:SetAnchor(CENTER, nil, CENTER, 0, -(25.0 * TVC.SavedVariables.ScreenMessageScaling))
		moveY = 15.0 * TVC.SavedVariables.ScreenMessageScaling

		TVC_FORMS.FragmentText1 = ZO_HUDFadeSceneFragment:New(lblText1)
		SCENE_MANAGER:AddFragment(TVC_FORMS.FragmentText1)

		TVC_FORMS.FragmentText1:Hide(TVC.SavedVariables.ScreenMessageFadeTime * 1000)
	end

	if not TVC_IsStringEmpty(text2) then
		local lblText2 = WINDOW_MANAGER:CreateControl(nil, TVC_FORMS.MainWindow, CT_LABEL)
		lblText2:SetText(text2)
		lblText2:SetColor(TVC.SavedVariables.ScreenMessageColor.Red, TVC.SavedVariables.ScreenMessageColor.Green, TVC.SavedVariables.ScreenMessageColor.Blue, 1)
		lblText2:SetFont("ZoFontCallout3")
		lblText2:SetScale(1.0 * TVC.SavedVariables.ScreenMessageScaling)
		lblText2:SetDrawLayer(1)
		lblText2:SetAnchor(CENTER, nil, CENTER, 0, moveY)

		TVC_FORMS.FragmentText2 = ZO_HUDFadeSceneFragment:New(lblText2)
		SCENE_MANAGER:AddFragment(TVC_FORMS.FragmentText2)

		TVC_FORMS.FragmentText2:Hide(TVC.SavedVariables.ScreenMessageFadeTime * 1000)
	end
end