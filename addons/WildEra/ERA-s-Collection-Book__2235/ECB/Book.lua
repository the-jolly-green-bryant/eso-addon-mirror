
function ECB_InitializeBook()
	ECB.database.book = {
		{
			id = ECB.constants.pages.settings,
			menu = ECB_GUI_BOOK_SUMMARY_SETTINGS,
			title = SI_ECB_MENU_SETTINGS,
			content = ECB_GUI_BOOK_CONTENT_SETTINGS_,
			scroll = ECB_GUI_BOOK_CONTENT_SETTINGS_ScrollChild,
			left = {
				width = 300,
				height = 20,
				elements = {
					{ elementType = 1, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_LEFT_UI_TITLE", ui = nil, value = SI_ECB_BOOK_SETTINGS_UI_TITLE },
					{ elementType = 2, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_LEFT_UI_WIDTH", ui = nil, value = SI_ECB_BOOK_SETTINGS_UI_WIDTH },
					{ elementType = 2, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_LEFT_UI_HEIGHT", ui = nil, value = SI_ECB_BOOK_SETTINGS_UI_HEIGHT },
					{ elementType = 2, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_LEFT_UI_BG", ui = nil, value = SI_ECB_BOOK_SETTINGS_UI_BG },
					{ elementType = 3, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_LEFT_UI_SAVE", ui = nil, value = SI_ECB_BOOK_SETTINGS_UI_SAVE, fct = ECB_SaveTracker },
					{ elementType = 3, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_LEFT_UI_RESET", ui = nil, value = SI_ECB_BOOK_SETTINGS_UI_RESET, fct = ECB_ResetTracker },
					--{ elementType = 1, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_LEFT_DATA_TITLE", ui = nil, value = SI_ECB_BOOK_SETTINGS_DATA_TITLE },
					--{ elementType = 3, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_LEFT_DATA_RESET", ui = nil, value = SI_ECB_BOOK_SETTINGS_DATA_RESET, fct = ECB_ResetDatabase }
				}
			},
			right = {
				width = 40,
				height = 20,
				elements = {
					{ elementType = 0, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_UI_TITLE", ui = nil, value = nil },
					{ elementType = 1, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_UI_WIDTH", ui = nil, value = ECB.dimensions.tracker.width },
					{ elementType = 1, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_UI_HEIGHT", ui = nil, value = ECB.dimensions.tracker.height },
					{ elementType = 1, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_UI_BG", ui = nil, value = ECB.dimensions.tracker.opacity },
					{ elementType = 0, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_UI_SAVE", ui = nil, value = nil },
					{ elementType = 0, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_UI_RESET", ui = nil, value = nil },
					--{ elementType = 0, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_DATA_TITLE", ui = nil, value = nil },
					--{ elementType = 0, uiName = "ECB_GUI_BOOK_CONTENT_SETTINGS_RIGHT_DATA_RESET", ui = nil, value = nil }
				}
			}
		},
		{
			id = ECB.constants.pages.about,
			menu = ECB_GUI_BOOK_SUMMARY_ABOUT,
			title = SI_ECB_MENU_ABOUT,
			content = ECB_GUI_BOOK_CONTENT_ABOUT_,
			scroll = ECB_GUI_BOOK_CONTENT_ABOUT_ScrollChild,
			left = {
				width = 400,
				height = 20,
				elements = {
					{ elementType = 1, uiName = "ECB_GUI_BOOK_CONTENT_ABOUT_NEWS_TITLE", ui = nil, value = SI_ECB_BOOK_ABOUT_NEWS_TITLE },
					{ elementType = 2, uiName = "ECB_GUI_BOOK_CONTENT_ABOUT_NEWS_LINE_1", ui = nil, value = SI_ECB_BOOK_ABOUT_NEWS_LINE_1 },
					{ elementType = 1, uiName = "ECB_GUI_BOOK_CONTENT_ABOUT_NEXT_TITLE", ui = nil, value = SI_ECB_BOOK_ABOUT_NEXT_TITLE },
					{ elementType = 2, uiName = "ECB_GUI_BOOK_CONTENT_ABOUT_NEXT_LINE_1", ui = nil, value = SI_ECB_BOOK_ABOUT_NEXT_LINE_1 },
					{ elementType = 2, uiName = "ECB_GUI_BOOK_CONTENT_ABOUT_NEXT_LINE_2", ui = nil, value = SI_ECB_BOOK_ABOUT_NEXT_LINE_2 },
					{ elementType = 1, uiName = "ECB_GUI_BOOK_CONTENT_ABOUT_SUPPORT_TITLE", ui = nil, value = SI_ECB_BOOK_ABOUT_SUPPORT_TITLE },
					{ elementType = 2, uiName = "ECB_GUI_BOOK_CONTENT_ABOUT_SUPPORT_LINE_1", ui = nil, value = SI_ECB_BOOK_ABOUT_SUPPORT_LINE_1 },
					{ elementType = 2, uiName = "ECB_GUI_BOOK_CONTENT_ABOUT_SUPPORT_LINE_2", ui = nil, value = SI_ECB_BOOK_ABOUT_SUPPORT_LINE_2 },
					{ elementType = 2, uiName = "ECB_GUI_BOOK_CONTENT_ABOUT_SUPPORT_LINE_3", ui = nil, value = SI_ECB_BOOK_ABOUT_SUPPORT_LINE_3 },
					{ elementType = 2, uiName = "ECB_GUI_BOOK_CONTENT_ABOUT_SUPPORT_LINE_4", ui = nil, value = SI_ECB_BOOK_ABOUT_SUPPORT_LINE_4 },
					{ elementType = 2, uiName = "ECB_GUI_BOOK_CONTENT_ABOUT_SUPPORT_LINE_5", ui = nil, value = SI_ECB_BOOK_ABOUT_SUPPORT_LINE_5 },
					{ elementType = 2, uiName = "ECB_GUI_BOOK_CONTENT_ABOUT_SUPPORT_LINE_6", ui = nil, value = SI_ECB_BOOK_ABOUT_SUPPORT_LINE_6 },
					{ elementType = 2, uiName = "ECB_GUI_BOOK_CONTENT_ABOUT_SUPPORT_LINE_7", ui = nil, value = SI_ECB_BOOK_ABOUT_SUPPORT_LINE_7 },
					{ elementType = 2, uiName = "ECB_GUI_BOOK_CONTENT_ABOUT_SUPPORT_LINE_8", ui = nil, value = SI_ECB_BOOK_ABOUT_SUPPORT_LINE_8 },
					{ elementType = 2, uiName = "ECB_GUI_BOOK_CONTENT_ABOUT_SUPPORT_LINE_9", ui = nil, value = SI_ECB_BOOK_ABOUT_SUPPORT_LINE_9 }
				}
			},
			right = { width = 0, height = 0, elements = {} }
		}
	}
end

function ECB_LoadBook()
	local WM = GetWindowManager()
	local text = ""
	local offsetY = 0
	local relativePoint = BOTTOMLEFT
	for i, page in ipairs(ECB.database.book) do
		-- menu
		local titleText = GetString(page.title)
		page.menu:SetText(titleText)
		
		-- content left
		local previous = page.scroll
		for j, element in ipairs(page.left.elements) do
			element.ui = WM:CreateControl(element.uiName, page.scroll, CT_LABEL)
			element.ui:SetDimensions(page.left.width, page.left.height)
			element.ui:SetFont(ECB.parameters.default.font)
			element.ui:SetWrapMode(ELLIPSIS)
			element.ui:SetHorizontalAlignment(RIGHT)
			element.ui:SetVerticalAlignment(CENTER)
			
			text = GetString(element.value)
			element.ui:SetText(text)
			
			element.ui:SetColor(1.0, 1.0, 1.0)
			if element.elementType == 1 or element.elementType == 3 then
				element.ui:SetColor(0.77, 0.76, 0.62)
			end
			
			offsetY = 0
			relativePoint = BOTTOMLEFT
			if j == 1 then
				relativePoint = TOPLEFT
			else
				if element.elementType == 1 or element.elementType == 3 then
					offsetY = 10
				end
			end
			element.ui:SetAnchor(TOPLEFT, previous, relativePoint, 0, offsetY)
			
			if element.elementType == 3 then
				element.ui:SetHandler("OnMouseUp", element.fct)
				element.ui:SetMouseEnabled(true)
			end
			
			previous = element.ui
		end
		
		-- content right
		local previous = page.scroll
		for j, element in ipairs(page.right.elements) do
			-- label
			if element.elementType == 0 then
				element.ui = WM:CreateControl(element.uiName, page.scroll, CT_LABEL)
				element.ui:SetDimensions(page.right.width, page.right.height)
				element.ui:SetFont(ECB.parameters.default.font)
				element.ui:SetWrapMode(ELLIPSIS)
				element.ui:SetHorizontalAlignment(LEFT)
				element.ui:SetColor(0.77, 0.76, 0.62)
				
				offsetY = 0
				relativePoint = BOTTOMRIGHT
				if j == 1 then
					relativePoint = TOPRIGHT
				else
					if element.elementType == 0 then
						offsetY = 10
					end
				end
				element.ui:SetAnchor(TOPRIGHT, previous, relativePoint, 0, offsetY)
			end
			-- editbox
			if element.elementType == 1 then
				local editboxbg = WM:CreateControlFromVirtual(string.format("%s_BG", element.uiName), page.scroll, "ZO_EditBackdrop")
				element.ui = WM:CreateControlFromVirtual(element.uiName, editboxbg, "ZO_DefaultEditForBackdrop")
				element.ui:ClearAnchors()
				if previous.elementType == 1 then
					editboxbg:SetDimensions(page.right.width, page.right.height - 1)
					editboxbg:SetAnchor(TOPRIGHT, previous, BOTTOMRIGHT, 0, 1)
					element.ui:SetDimensions(page.right.width, page.right.height - 1)
					element.ui:SetAnchor(TOPRIGHT, previous, BOTTOMRIGHT, 0, 1)
				else
					editboxbg:SetDimensions(page.right.width, page.right.height - 2)
					editboxbg:SetAnchor(TOPRIGHT, previous, BOTTOMRIGHT, 0, 2)
					element.ui:SetDimensions(page.right.width, page.right.height - 2)
					element.ui:SetAnchor(TOPRIGHT, previous, BOTTOMRIGHT, 0, 2)
				end
				element.ui:SetFont(ECB.parameters.default.font)
				element.ui:SetText(element.value)
				element.ui:SetMaxInputChars(3)
			end
			
			previous = element.ui
		end
	end
	
	local initTitleText = GetString(ECB.database.book[1].title)
	ECB_GUI_BOOK_CONTENT_TITLE:SetText(string.format("%s%s", ECB.parameters.default.prefix, string.upper(initTitleText)))
end