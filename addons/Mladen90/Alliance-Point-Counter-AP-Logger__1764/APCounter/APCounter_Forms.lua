APC_FORMS.MainWindow = nil
APC_FORMS.MainWindowBackGround = nil
APC_FORMS.MainWindowText = nil


APC_FORMS.FragmentResource = nil
APC_FORMS.FragmentTick = nil


APC_FORMS.Functions = {}


APC_FORMS.Functions.Init = function(left, bottom)
	APC_FORMS.MainWindow = WINDOW_MANAGER:CreateTopLevelWindow()

	APC_FORMS.MainWindow:SetClampedToScreen(true)
	APC_FORMS.MainWindow:SetAlpha(1)

	if (APC.SavedVariables.DisplayTickResourceName) then APC_FORMS.MainWindow:SetDimensions(500 * APC.SavedVariables.ScreenMessageScaling, 80 * APC.SavedVariables.ScreenMessageScaling)
	else APC_FORMS.MainWindow:SetDimensions(350 * APC.SavedVariables.ScreenMessageScaling, 80 * APC.SavedVariables.ScreenMessageScaling) end

	if left and bottom then
		APC_FORMS.MainWindow:SetAnchor(BOTTOMLEFT, GuiRoot, TOPLEFT, left, bottom)
	else
		APC_FORMS.MainWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
		APC.SavedVariables.MainWindowLeft = APC_FORMS.MainWindow:GetLeft()
		APC.SavedVariables.MainWindowBottom = APC_FORMS.MainWindow:GetBottom()
	end

	APC_FORMS.MainWindowBackGround = WINDOW_MANAGER:CreateControl(nil, APC_FORMS.MainWindow, CT_BACKDROP)
	APC_FORMS.MainWindowBackGround:SetEdgeColor(1, 1, 1, 0.5)
	APC_FORMS.MainWindowBackGround:SetCenterColor(0, 0, 0, 0.8)
	APC_FORMS.MainWindowBackGround:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 0)
	APC_FORMS.MainWindowBackGround:SetDimensions(APC_FORMS.MainWindow:GetWidth(), APC_FORMS.MainWindow:GetHeight())
	APC_FORMS.MainWindowBackGround:SetDrawLayer(0)
	APC_FORMS.MainWindowBackGround:SetAlpha(0)

	APC_FORMS.MainWindowText = WINDOW_MANAGER:CreateControl(nil, APC_FORMS.MainWindow, CT_LABEL)
	APC_FORMS.MainWindowText:SetText("APC TICK MESSAGE")
	APC_FORMS.MainWindowText:SetColor(1, 1, 1)
	APC_FORMS.MainWindowText:SetFont("ZoFontCallout3")
	APC_FORMS.MainWindowText:SetDrawLayer(0)
	APC_FORMS.MainWindowText:SetAnchor(CENTER, nil, CENTER, 0, 0)
	APC_FORMS.MainWindowText:SetAlpha(0)
	APC_FORMS.MainWindowText:SetScale(0.5 * APC.SavedVariables.ScreenMessageScaling)
end


APC_FORMS.Functions.DisplayTick = function(resourceText, tickText)
	if APC_FORMS.FragmentResource then APC_FORMS.FragmentResource:Hide(0) end
	if APC_FORMS.FragmentTick then APC_FORMS.FragmentTick:Hide(0) end

	local moveY = 0

	if not APC_IsStringEmpty(resourceText) then
		local lblResource = WINDOW_MANAGER:CreateControl(nil, APC_FORMS.MainWindow, CT_LABEL)
		lblResource:SetText(resourceText)
		lblResource:SetColor(APC.SavedVariables.TickColor.Red, APC.SavedVariables.TickColor.Green, APC.SavedVariables.TickColor.Blue, 1)
		lblResource:SetFont("ZoFontCallout3")
		lblResource:SetScale(0.5 * APC.SavedVariables.ScreenMessageScaling)
		lblResource:SetDrawLayer(1)
		lblResource:SetAnchor(CENTER, nil, CENTER, 0, -(25.0 * APC.SavedVariables.ScreenMessageScaling))
		moveY = 15.0 * APC.SavedVariables.ScreenMessageScaling

		APC_FORMS.FragmentResource = ZO_HUDFadeSceneFragment:New(lblResource)
		SCENE_MANAGER:AddFragment(APC_FORMS.FragmentResource)

		APC_FORMS.FragmentResource:Hide(APC.SavedVariables.TickFadeTime * 1000)
	end

	local lblTick = WINDOW_MANAGER:CreateControl(nil, APC_FORMS.MainWindow, CT_LABEL)
	lblTick:SetText(tickText)
	lblTick:SetColor(APC.SavedVariables.TickColor.Red, APC.SavedVariables.TickColor.Green, APC.SavedVariables.TickColor.Blue, 1)
	lblTick:SetFont("ZoFontCallout3")
	lblTick:SetScale(1.0 * APC.SavedVariables.ScreenMessageScaling)
	lblTick:SetDrawLayer(1)
	lblTick:SetAnchor(CENTER, nil, CENTER, 0, moveY)

	APC_FORMS.FragmentTick = ZO_HUDFadeSceneFragment:New(lblTick)
	SCENE_MANAGER:AddFragment(APC_FORMS.FragmentTick)

	APC_FORMS.FragmentTick:Hide(APC.SavedVariables.TickFadeTime * 1000)
end