function buildControlPanel()

	sc.menuId = LAM:CreateControlPanel('scConfig', 'SimpleClock ')

	-- -----------------------------------------------------------------------------
	-- Visibility
	-- -----------------------------------------------------------------------------
	LAM:AddHeader(sc.menuId, 'scHeaderVisibility', 'Visibility')

	-- Hide with overlay
	LAM:AddCheckbox(
		sc.menuId,
		'scConfigChkbox_HideWithOverlay',
		'Hide when viewing menus',
		'Hides the clock when viewing inventory or similar screens.',
		function() return sc.sv.hideWithOverlay end,
		function() sc.ui.toggleSetting('hideWithOverlay') end
	)

	-- -----------------------------------------------------------------------------
	-- Time Format
	-- -----------------------------------------------------------------------------
	LAM:AddHeader(sc.menuId, 'scHeaderTimeFormat', 'Time Format')

	-- Time Format dropdown (24hr vs. 12hr)
	LAM:AddCheckbox(
		sc.menuId,
		'scConfigChkbox_24HourTime',
		'24 Hour (Military) Time',
		'Choose whether to use 24hr time (00:30) or 12hr time (12:30AM).',
		function() return sc.sv.use24Hour end,
		function() sc.ui.toggleSetting('use24Hour') end
	)

	-- Show/Hide meridiem
	LAM:AddCheckbox(
		sc.menuId,
		'scConfigChkbox_VisibleMeridiem',
		'Hide Meridiem Indicator',
		'Disable the A.M./P.M. text.',
		function() return sc.sv.hideMeridiem end,
		function() sc.ui.toggleSetting('hideMeridiem') end
	)

	-- Use lowercase AM/PM
	LAM:AddCheckbox(
		sc.menuId,
		'scConfigChkbox_LowercaseMeridiem',
		'Lowercase Meridiem Indicator',
		'Have the A.M./P.M. text display in lowercase.',
		function() return sc.sv.lowercaseMeridiem end,
		function() sc.ui.toggleSetting('lowercaseMeridiem') end
	)

	-- Hide dots in AM/PM
	LAM:AddCheckbox(
		sc.menuId,
		'scConfigChkbox_NoDotsMeridiem',
		'Hide Dots in Meridiem Indicator',
		'Hide the dots in A.M./P.M.',
		function() return sc.sv.noDotsMeridiem end,
		function() sc.ui.toggleSetting('noDotsMeridiem') end
	)

	-- -----------------------------------------------------------------------------
	-- Positioning
	-- -----------------------------------------------------------------------------
	LAM:AddHeader(sc.menuId, 'scHeaderPositioning', 'Positioning')

	-- Text alignment
	LAM:AddDropdown(
		sc.menuId,
		'scConfigDrpdwn_TextAlign',
		'Text Alignment',
		'Which way the numbers on the clock should expand from.',
		{'Left', 'Right', 'Center'},
		function() return sc.sv.align end,
		function(val) sc.ui:setAlignment(val) end
	)

	-- -----------------------------------------------------------------------------
	-- Font
	-- -----------------------------------------------------------------------------
	LAM:AddHeader(sc.menuId, 'scHeaderFont', 'Font')

	-- Font family
	LAM:AddDropdown(
		sc.menuId,
		'scConfigDrpdwn_FontFamily',
		'Family',
		'The font family used to display the clock.',
		LMP:List('font'),
		function() return sc.sv.fontFamily end,
		function(val) sc.ui.updateSetting('fontFamily', val) end
	)

	-- Font size
	LAM:AddSlider(
		sc.menuId,
		'scConfigDrpdwn_FontSize',
		'Size',
		'The size of the font use for the clock.',
		12,
		48,
		1,
		function() return sc.sv.fontSize end,
		function(val) sc.ui.updateSetting('fontSize', val) end
	)

	-- Font style
	LAM:AddDropdown(
		sc.menuId,
		'scConfigDrpdwn_FontStyle',
		'Style',
		'Additional borders and shadows for the text.',
		sc.ui.styles,
		function() return sc.sv.fontStyle end,
		function(val) sc.ui.updateSetting('fontStyle', val) end
	)

	-- Font color
	LAM:AddColorPicker(
		sc.menuId,
		'scConfigDrpdwn_FontColor',
		'Color',
		'Set the colour of the text.',
		function() return sc.sv.fontColor.r, sc.sv.fontColor.g, sc.sv.fontColor.b, sc.sv.fontColor.a end,
		function(r, g, b, a) sc.ui.updateSetting('fontColor', {r = r, g = g, b = b, a = a}) end
	)

end