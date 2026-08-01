if NBUI == nil then NBUI = {} end

local buttonCount = 1
---------------------------------------------------------------------------------------------------
function Create_NB2_IndexButton(NB2_IndexPool)
	local button = WINDOW_MANAGER:CreateControlFromVirtual("NB2_Index" .. NB2_IndexPool:GetNextControlId(), NBUI.NB2LeftPage_ScrollContainer.scrollChild, "ZO_DefaultTextButton")
	local anchorBtn = buttonCount == 1 and NBUI.NB2LeftPage_ScrollContainer.scrollChild or NB2_IndexPool:AcquireObject(buttonCount-1)
		button:SetAnchor(TOPLEFT, anchorBtn, buttonCount == 1 and TOPLEFT or BOTTOMLEFT)
		button:SetClickSound(SOUNDS.BOOK_PAGE_TURN)			
		button:SetFont("ZoFontBookPaper")		
		button:SetHandler("OnClicked", function(self)
			
			currentlyViewing = self.id
		
			NBUI.NB2RightPage_Title:SetText(UnprotectText(self.data.title))
			NBUI.NB2RightPage_Title:SetCursorPosition(TOPLEFT)
			
			NBUI.NB2RightPage_Contents:SetText(UnprotectText(self.data.text))
			NBUI.NB2RightPage_Contents:SetCursorPosition(TOPLEFT)
			
			NBUI.NB2SelectedPage_Button:ClearAnchors()
			NBUI.NB2SelectedPage_Button:SetAnchorFill(self)			
			-- shows these buttons
			NBUI.NB2SavePage_Button:SetHidden(true)
			NBUI.NB2UndoPage_Button:SetHidden(true)
			-- hides these buttons
			NBUI.NB2RunScript_Button:SetHidden(false)
			NBUI.NB2DeletePage_Button:SetHidden(false)
			NBUI.NB2SelectedPage_Button:SetHidden(false)
		end)		
		button:SetHorizontalAlignment(TEXT_ALIGN_LEFT)		
		button:SetMouseOverFontColor(0, 0, 0, 0.4)
		button:SetNormalFontColor(0, 0, 0, 0.7)
		button:SetPressedFontColor(0, 0, 0, 0.9)		
		button:SetWidth(400)

	buttonCount = buttonCount + 1
	return button
end
---------------------------------------------------------------------------------------------------
function Populate_NB2_ScrollList()
	local numPages = #NBUIDB.NB2Pages
	for i = 1, numPages do
		local button = NB2_IndexPool:AcquireObject(i)
		button.data = NBUIDB.NB2Pages[i]
		button.id = i
		button:SetText(UnprotectText(button.data.title))
		button:SetHidden(false)
	end
	local activePages = NB2_IndexPool:GetActiveObjectCount()
	if activePages > numPages then
		for i = numPages+1, activePages do
			NB2_IndexPool:ReleaseObject(i)
		end
	end
end
---------------------------------------------------------------------------------------------------
function Remove_NB2_IndexButton(button)
	button:SetHidden(true)
end
---------------------------------------------------------------------------------------------------
--  Interface  --
---------------------------------------------------------------------------------------------------
function CreateNB2()
---------------------------------------------------------------------------------------------------
	NBUI.NB2MainWindow = WINDOW_MANAGER:CreateTopLevelWindow("NBUI_NB2MainWindow")	
		NBUI.NB2MainWindow:AllowBringToTop(true)
		NBUI.NB2MainWindow:SetAnchor(NBUIDB.NB2_Anchor.a, GuiRoot, NBUIDB.NB2_Anchor.b, NBUIDB.NB2_Anchor.x, NBUIDB.NB2_Anchor.y)
		NBUI.NB2MainWindow:SetClampedToScreen(true)		
		NBUI.NB2MainWindow:SetDimensions(1004, 752)
		NBUI.NB2MainWindow:SetDrawLayer(0)		
		NBUI.NB2MainWindow:SetDrawLevel(0) 
		NBUI.NB2MainWindow:SetDrawTier(0) 
		NBUI.NB2MainWindow:SetHandler("OnMoveStop", function(self)
			local _,a,_,b,x,y = self:GetAnchor()
			NBUIDB.anchor = {["a"]=a, ["b"]=b, ["x"]=x, ["y"]=y}
		end)		
		NBUI.NB2MainWindow:SetHandler("OnReceiveDrag", function(self)
			self:StartMoving()
		end)		
		NBUI.NB2MainWindow:SetHidden(true)		
		NBUI.NB2MainWindow:SetMouseEnabled(true)	
 		NBUI.NB2MainWindow:SetMovable(not NBUIDB.NB2_Locked)
---------------------------------------------------------------------------------------------------	
	NBUI.NB2MainWindow_Cover = WINDOW_MANAGER:CreateControl("NBUI_NB2MainWindow_Cover", NBUI.NB2MainWindow, CT_TEXTURE)
		NBUI.NB2MainWindow_Cover:SetAnchor(TOPLEFT, NBUI.NB2MainWindow, TOPLEFT, -10, -126)
		NBUI.NB2MainWindow_Cover:SetAnchor(BOTTOMRIGHT, NBUI.NB2MainWindow, BOTTOMRIGHT, 10, 146)		
		NBUI.NB2MainWindow_Cover:SetDimensions(1024, 1024)
		NBUI.NB2MainWindow_Cover:SetTexture("/esoui/art/lorelibrary/lorelibrary_paperbook.dds")
		NBUI.NB2MainWindow_Cover:SetColor(unpack(NBUIDB.NB2_BookColor))
		NBUI.NB2MainWindow_Cover:SetAlpha(1)
--***********************************************************************************************--		
--  LEFT PAGE  ------------------------------------------------------------------------------------
	NBUI.NB2LeftPage_TitleBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB2LeftPage_TitleBackdrop", NBUI.NB2MainWindow, "ZO_EditBackdrop")
		NBUI.NB2LeftPage_TitleBackdrop:SetAnchor(TOPLEFT, NBUI.NB2MainWindow_Cover, TOPLEFT, 85, 160)		
		NBUI.NB2LeftPage_TitleBackdrop:SetCenterColor(0, 0, 0, 0)		
		NBUI.NB2LeftPage_TitleBackdrop:SetDimensions(420, 45)
		NBUI.NB2LeftPage_TitleBackdrop:SetDrawLayer(0)		
		NBUI.NB2LeftPage_TitleBackdrop:SetDrawLevel(1)
		NBUI.NB2LeftPage_TitleBackdrop:SetDrawTier(0)		
		NBUI.NB2LeftPage_TitleBackdrop:SetEdgeColor(0, 0, 0, 0)
		NBUI.NB2LeftPage_TitleBackdrop:SetHidden(not NBUIDB.NB2_ShowTitle)	
---------------------------------------------------------------------------------------------------	
	NBUI.NB2LeftPage_Title = WINDOW_MANAGER:CreateControl("NBUI_NB2LeftPage_Title", NBUI.NB2MainWindow, CT_LABEL)
		NBUI.NB2LeftPage_Title:SetAnchor(CENTER, NBUI.NB2LeftPage_TitleBackdrop, CENTER, 0, 0)
		NBUI.NB2LeftPage_Title:SetColor(0, 0, 0, 0.7)	
		NBUI.NB2LeftPage_Title:SetDrawLayer(0)		
		NBUI.NB2LeftPage_Title:SetDrawLevel(2)
		NBUI.NB2LeftPage_Title:SetDrawTier(0) 			
		NBUI.NB2LeftPage_Title:SetFont("ZoFontBookPaperTitle")
		NBUI.NB2LeftPage_Title:SetHidden(not NBUIDB.NB2_ShowTitle)		
		NBUI.NB2LeftPage_Title:SetText(NBUIDB.NB2_Title)
---------------------------------------------------------------------------------------------------
	NBUI.NB2Information_Button = WINDOW_MANAGER:CreateControl("NBUI_NB2Information_Button", NBUI.NB2MainWindow, CT_BUTTON)
		NBUI.NB2Information_Button:SetAnchor(CENTER, NBUI.NB2LeftPage_TitleBackdrop, RIGHT, -30, 0)		
		NBUI.NB2Information_Button:SetDimensions(32, 32)
		NBUI.NB2Information_Button:SetDrawLayer(1)		
		NBUI.NB2Information_Button:SetDrawLevel(1)
		NBUI.NB2Information_Button:SetDrawTier(0)		
		NBUI.NB2Information_Button:SetHandler("OnClicked", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, GetString(SI_NBUI_NB2INFORMATION_TOOLTIP))
		end)
		NBUI.NB2Information_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)
		NBUI.NB2Information_Button:SetHidden(not NBUIDB.NB2_ShowTitle)		
		NBUI.NB2Information_Button:SetMouseOverTexture("/esoui/art/buttons/info_over.dds")
		NBUI.NB2Information_Button:SetNormalTexture("/esoui/art/buttons/info_up.dds")
		NBUI.NB2Information_Button:SetPressedTexture("/esoui/art/buttons/info_down.dds")
---------------------------------------------------------------------------------------------------		
	NBUI.NB2LeftPage_Separator = WINDOW_MANAGER:CreateControl("NBUI_NB2LeftPage_Separator", NBUI.NB2MainWindow, CT_TEXTURE)		
		NBUI.NB2LeftPage_Separator:SetAnchor(CENTER, NBUI.NB2LeftPage_TitleBackdrop, BOTTOM, 0, 0)		
		NBUI.NB2LeftPage_Separator:SetColor(0, 0, 0, 0.7)		
		NBUI.NB2LeftPage_Separator:SetDimensions(420, 2)
		NBUI.NB2LeftPage_Separator:SetDrawLayer(1)		
		NBUI.NB2LeftPage_Separator:SetDrawLevel(1)
		NBUI.NB2LeftPage_Separator:SetDrawTier(0)		
		NBUI.NB2LeftPage_Separator:SetHidden(not NBUIDB.NB2_ShowTitle)
		NBUI.NB2LeftPage_Separator:SetTexture("/esoui/art/interaction/conversation_divider.dds")	
---------------------------------------------------------------------------------------------------
	NBUI.NB2LeftPage_Backdrop = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB2LeftPage_Backdrop", NBUI.NB2MainWindow, "ZO_EditBackdrop")
		NBUI.NB2LeftPage_Backdrop:SetAnchor(BOTTOMLEFT, NBUI.NB2MainWindow_Cover, BOTTOMLEFT, 85, -174)		
		NBUI.NB2LeftPage_Backdrop:SetCenterColor(0, 0, 0, 0)
			if (NBUIDB.NB2_ShowTitle) then
				NBUI.NB2LeftPage_Backdrop:SetDimensions(420, 645)
			else
				NBUI.NB2LeftPage_Backdrop:SetDimensions(420, 690)
			end	
		NBUI.NB2LeftPage_Backdrop:SetDrawLayer(0)		
		NBUI.NB2LeftPage_Backdrop:SetDrawLevel(1)
		NBUI.NB2LeftPage_Backdrop:SetDrawTier(0)		
		NBUI.NB2LeftPage_Backdrop:SetEdgeColor(0, 0, 0, 0)		
---------------------------------------------------------------------------------------------------
	NBUI.NB2LeftPage_ScrollContainer = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB2LeftPage_ScrollContainer", NBUI.NB2MainWindow, "ZO_ScrollContainer")
		NBUI.NB2LeftPage_ScrollContainer.scrollChild = NBUI.NB2LeftPage_ScrollContainer:GetNamedChild("ScrollChild")		
		NBUI.NB2LeftPage_ScrollContainer:SetAnchorFill(NBUI.NB2LeftPage_Backdrop)
		NBUI.NB2LeftPage_ScrollContainer:SetDrawLayer(0)	
		NBUI.NB2LeftPage_ScrollContainer:SetDrawLevel(2)
		NBUI.NB2LeftPage_ScrollContainer:SetDrawTier(0)
---------------------------------------------------------------------------------------------------	  
	NBUI.NB2SelectedPage_Button = WINDOW_MANAGER:CreateControl(nil, NBUI.NB2LeftPage_ScrollContainer.scrollChild, CT_TEXTURE)
		NBUI.NB2SelectedPage_Button:SetAlpha(.45)		
		NBUI.NB2SelectedPage_Button:SetDrawLayer(0)		
		NBUI.NB2SelectedPage_Button:SetDrawLevel(3) 
		NBUI.NB2SelectedPage_Button:SetDrawTier(0) 	
		NBUI.NB2SelectedPage_Button:SetHidden(true)
		NBUI.NB2SelectedPage_Button:SetTexture("esoui/art/buttons/generic_highlight.dds")
		NBUI.NB2SelectedPage_Button:SetWidth(420)
---------------------------------------------------------------------------------------------------		
	NBUI.NB2SavePage_Button = WINDOW_MANAGER:CreateControl("NBUI_NB2SavePage_Button", NBUI.NB2LeftPage_ScrollContainer.scrollChild, CT_BUTTON)
		NBUI.NB2SavePage_Button:SetAnchor(RIGHT, NBUI.NB2SelectedPage_Button, RIGHT, -95, -2) 		
		NBUI.NB2SavePage_Button:SetClickSound(SOUNDS.BOOK_PAGE_TURN)
		NBUI.NB2SavePage_Button:SetDimensions(30, 30)
		NBUI.NB2SavePage_Button:SetDrawLayer(1)		
		NBUI.NB2SavePage_Button:SetDrawLevel(1)
		NBUI.NB2SavePage_Button:SetDrawTier(0)	
		NBUI.NB2SavePage_Button:SetHandler("OnClicked", function(self)
			if (NBUIDB.showdialog) then
				ZO_Dialogs_ShowDialog("NBUI_NB2CONFIRM_SAVE")
			else
				NBUI.NB2SavePage(self)
			end			
		end)
		NBUI.NB2SavePage_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, GetString(SI_NBUI_SAVEBUTTON_TOOLTIP))
		end)
		NBUI.NB2SavePage_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)
		NBUI.NB2SavePage_Button:SetHidden(true)		
		NBUI.NB2SavePage_Button:SetMouseOverTexture("/esoui/art/buttons/edit_save_over.dds")
		NBUI.NB2SavePage_Button:SetNormalTexture("/esoui/art/buttons/edit_save_up.dds")
		NBUI.NB2SavePage_Button:SetPressedTexture("/esoui/art/buttons/edit_save_down.dds")	
---------------------------------------------------------------------------------------------------		
	NBUI.NB2UndoPage_Button = WINDOW_MANAGER:CreateControl("NBUI_NB2UndoPage_Button", NBUI.NB2LeftPage_ScrollContainer.scrollChild, CT_BUTTON)
		NBUI.NB2UndoPage_Button:SetAnchor(RIGHT, NBUI.NB2SelectedPage_Button, RIGHT, -60, 0)
		NBUI.NB2UndoPage_Button:SetClickSound(SOUNDS.BOOK_PAGE_TURN)
		NBUI.NB2UndoPage_Button:SetDimensions(32, 35)
		NBUI.NB2UndoPage_Button:SetDrawLayer(1)		
		NBUI.NB2UndoPage_Button:SetDrawLevel(1)
		NBUI.NB2UndoPage_Button:SetDrawTier(0)
		NBUI.NB2UndoPage_Button:SetHandler("OnClicked", function(self)
			if (NBUIDB.showdialog) then
				ZO_Dialogs_ShowDialog("NBUI_NB2CONFIRM_UNDO")
			else
				NBUI.NB2UndoPage()
			end			
		end)
		NBUI.NB2UndoPage_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, GetString(SI_NBUI_UNDOBUTTON_TOOLTIP))
		end)
		NBUI.NB2UndoPage_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)
		NBUI.NB2UndoPage_Button:SetHidden(true)		
		NBUI.NB2UndoPage_Button:SetMouseOverTexture("/esoui/art/contacts/social_note_over.dds") 
		NBUI.NB2UndoPage_Button:SetNormalTexture("/esoui/art/contacts/social_note_up.dds")
		NBUI.NB2UndoPage_Button:SetPressedTexture("/esoui/art/contacts/social_note_down.dds")		
---------------------------------------------------------------------------------------------------		
	NBUI.NB2RunScript_Button = WINDOW_MANAGER:CreateControl("NBUI_NB2RunScript_Button", NBUI.NB2LeftPage_ScrollContainer.scrollChild, CT_BUTTON)
		NBUI.NB2RunScript_Button:SetAnchor(RIGHT, NBUI.NB2SelectedPage_Button, RIGHT, -30, -2)		
		NBUI.NB2RunScript_Button:SetClickSound(SOUNDS.BOOK_PAGE_TURN)
		NBUI.NB2RunScript_Button:SetDimensions(28, 28)
		NBUI.NB2RunScript_Button:SetDrawLayer(1)		
		NBUI.NB2RunScript_Button:SetDrawLevel(1)
		NBUI.NB2RunScript_Button:SetDrawTier(0) 
		NBUI.NB2RunScript_Button:SetHandler("OnClicked", function(self)
			local NBUIScript = zo_loadstring(NBUI.NB2RightPage_Contents:GetText())
			if NBUIScript then
				NBUIScript()
			end
		end)
		NBUI.NB2RunScript_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, GetString(SI_NBUI_RUNBUTTON_TOOLTIP))
		end)
		NBUI.NB2RunScript_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)
		NBUI.NB2RunScript_Button:SetHidden(true)		
		NBUI.NB2RunScript_Button:SetMouseOverTexture("/esoui/art/buttons/edit_over.dds")
		NBUI.NB2RunScript_Button:SetNormalTexture("/esoui/art/buttons/edit_up.dds")
		NBUI.NB2RunScript_Button:SetPressedTexture("/esoui/art/buttons/edit_down.dds")
---------------------------------------------------------------------------------------------------
	NBUI.NB2DeletePage_Button = WINDOW_MANAGER:CreateControl("NBUI_NB2DeletePage_Button", NBUI.NB2LeftPage_ScrollContainer.scrollChild, CT_BUTTON)
		NBUI.NB2DeletePage_Button:SetAnchor(RIGHT, NBUI.NB2SelectedPage_Button, RIGHT, 0, 0) 		
		NBUI.NB2DeletePage_Button:SetClickSound(SOUNDS.BOOK_PAGE_TURN)
		NBUI.NB2DeletePage_Button:SetDimensions(26, 26)
		NBUI.NB2DeletePage_Button:SetDrawLayer(1)
		NBUI.NB2DeletePage_Button:SetDrawLevel(1)
		NBUI.NB2DeletePage_Button:SetDrawTier(0)
		NBUI.NB2DeletePage_Button:SetHandler("OnClicked", function(self)
			if (NBUIDB.NB2_ShowDialog) then
				ZO_Dialogs_ShowDialog("NBUI_NB2CONFIRM_DELETE")
			else
				NBUI.NB2DeletePage()
			end			
		end)
		NBUI.NB2DeletePage_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, GetString(SI_NBUI_DELETEBUTTON_TOOLTIP))
		end)
		NBUI.NB2DeletePage_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)		
		NBUI.NB2DeletePage_Button:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
		NBUI.NB2DeletePage_Button:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
		NBUI.NB2DeletePage_Button:SetPressedTexture("/esoui/art/buttons/decline_down.dds")		
--***********************************************************************************************--		
--  RIGHT PAGE  -----------------------------------------------------------------------------------		
	NBUI.NB2RightPage_TitleBackdrop  = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB2RightPage_TitleBackdrop", NBUI.NB2MainWindow, "ZO_EditBackdrop")
		NBUI.NB2RightPage_TitleBackdrop:SetAnchor(TOPRIGHT, NBUI.NB2MainWindow_Cover, TOPRIGHT, -70, 160)		
		NBUI.NB2RightPage_TitleBackdrop:SetCenterColor(0, 0, 0, 0)		
		NBUI.NB2RightPage_TitleBackdrop:SetDimensions(420, 45)
		NBUI.NB2RightPage_TitleBackdrop:SetDrawLayer(0)
		NBUI.NB2RightPage_TitleBackdrop:SetDrawLevel(1)
		NBUI.NB2RightPage_TitleBackdrop:SetDrawTier(0)		
		NBUI.NB2RightPage_TitleBackdrop:SetEdgeColor(0, 0, 0, 0)		
---------------------------------------------------------------------------------------------------	
	NBUI.NB2RightPage_Backdrop = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB2RightPage_Backdrop", NBUI.NB2MainWindow, "ZO_EditBackdrop")
		NBUI.NB2RightPage_Backdrop:SetAnchor(BOTTOMRIGHT, NBUI.NB2MainWindow_Cover, BOTTOMRIGHT, -70, -174)		
		NBUI.NB2RightPage_Backdrop:SetCenterColor(0, 0, 0, 0)		
		NBUI.NB2RightPage_Backdrop:SetDimensions(420, 645)
		NBUI.NB2RightPage_Backdrop:SetDrawLayer(0)
		NBUI.NB2RightPage_Backdrop:SetDrawLevel(1)
		NBUI.NB2RightPage_Backdrop:SetDrawTier(0)		
		NBUI.NB2RightPage_Backdrop:SetEdgeColor(0, 0, 0, 0)
---------------------------------------------------------------------------------------------------	
	NBUI.NB2RightPage_Title = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB2RightPage_Title", NBUI.NB2RightPage_TitleBackdrop, "ZO_DefaultEditForBackdrop")
		NBUI.NB2RightPage_Title:SetColor(0, 0, 0, 0.7)			
		NBUI.NB2RightPage_Title:SetDrawLayer(0)
		NBUI.NB2RightPage_Title:SetDrawLevel(2)
		NBUI.NB2RightPage_Title:SetDrawTier(0)		
		NBUI.NB2RightPage_Title:SetFont("ZoFontBookPaperTitle")
		NBUI.NB2RightPage_Title:SetHandler("OnEscape", NBUI.NB2RightPage_Title.LoseFocus)		
		NBUI.NB2RightPage_Title:SetHandler("OnTab", function() 
			NBUI.NB2RightPage_Contents:TakeFocus() 
		end)
		NBUI.NB2RightPage_Title:SetHandler("OnMouseDoubleClick", function(self) 
			zo_callLater(function() self:SelectAll() end, 0.5)
		end) 
		NBUI.NB2RightPage_Title:SetHandler("OnTextChanged", function(self)
				local NB2Pages = NBUIDB.NB2Pages[currentlyViewing]
				if not NB2Pages or self:GetText() ~= NB2Pages.title or self:GetText() then
					NBUI.NB2SavePage_Button:SetHidden(false)
					NBUI.NB2UndoPage_Button:SetHidden(false)				
				else
					NBUI.NB2SavePage_Button:SetHidden(true)
					NBUI.NB2UndoPage_Button:SetHidden(true)				
				end
			end)
		NBUI.NB2RightPage_Title:SetMaxInputChars(30)
---------------------------------------------------------------------------------------------------		
	NBUI.NB2RightPage_ScrollContainer = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB2RightPage_ScrollContainer", NBUI.NB2MainWindow, "ZO_ScrollContainer")
		NBUI.NB2RightPage_ScrollContainer.scrollChild = NBUI.NB2RightPage_ScrollContainer:GetNamedChild("ScrollChild")		
		NBUI.NB2RightPage_ScrollContainer:SetAnchorFill(NBUI.NB2RightPage_Backdrop)
		NBUI.NB2RightPage_ScrollContainer:SetDrawLayer(0)	
		NBUI.NB2RightPage_ScrollContainer:SetDrawLevel(2)
		NBUI.NB2RightPage_ScrollContainer:SetDrawTier(0)
---------------------------------------------------------------------------------------------------	
	NBUI.NB2RightPage_Contents = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB2RightPage_Contents", NBUI.NB2RightPage_ScrollContainer, "ZO_DefaultEditMultiLineForBackdrop")
		NBUI.NB2RightPage_Contents:SetColor(0, 0, 0, 0.7)		
		NBUI.NB2RightPage_Contents:SetDrawLayer(0)
		NBUI.NB2RightPage_Contents:SetDrawLevel(3)
		NBUI.NB2RightPage_Contents:SetDrawTier(1)	
		NBUI.NB2RightPage_Contents:SetFont("ZoFontBookPaper")
		NBUI.NB2RightPage_Contents:SetHandler("OnEscape", NBUI.NB2RightPage_Contents.LoseFocus)
		NBUI.NB2RightPage_Contents:SetHandler("OnTab", function() 
			NBUI.NB2RightPage_Title:TakeFocus() 
		end)
		NBUI.NB2RightPage_Contents:SetHandler("OnMouseDoubleClick", function(self) 
			zo_callLater(function() self:SelectAll() end, 0.5)
		end)		
		NBUI.NB2RightPage_Contents:SetHandler("OnTextChanged", function(self)
			local page = NBUIDB.NB2Pages[currentlyViewing]
			if not page or self:GetText() ~= page.text or self:GetText() then
				NBUI.NB2SavePage_Button:SetHidden(false)
				NBUI.NB2UndoPage_Button:SetHidden(false)				
			else
				NBUI.NB2SavePage_Button:SetHidden(true)
				NBUI.NB2UndoPage_Button:SetHidden(true)				
			end
		end)
		NBUI.NB2RightPage_Contents:SetMaxInputChars(3000) --625 to only fill a page full
		NBUI.NB2RightPage_Contents:SetMultiLine(true)
---------------------------------------------------------------------------------------------------	
	NBUI.NB2NewPage_Button = WINDOW_MANAGER:CreateControl("NBUI_NB2NewPage_Button", NBUI.NB2MainWindow, CT_BUTTON)
		NBUI.NB2NewPage_Button:SetAnchor(TOPRIGHT, NBUI.NB2RightPage_TitleBackdrop, TOPRIGHT, 34, -25)		
		NBUI.NB2NewPage_Button:SetClickSound(SOUNDS.BOOK_PAGE_TURN)	
		NBUI.NB2NewPage_Button:SetDimensions(32, 32)
		NBUI.NB2NewPage_Button:SetDrawLayer(1)
		NBUI.NB2NewPage_Button:SetDrawLevel(2)
		NBUI.NB2NewPage_Button:SetDrawTier(0)		
		NBUI.NB2NewPage_Button:SetHandler("OnClicked", function(self)
			if (NBUIDB.NB2_ShowDialog) then
				ZO_Dialogs_ShowDialog("NBUI_NB2CONFIRM_NEWPAGE")
			else
				NBUI.NB2NewPage(self)
			end	
		end)
		NBUI.NB2NewPage_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, GetString(SI_NBUI_NEWBUTTON_TOOLTIP))
		end)
		NBUI.NB2NewPage_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)		
		NBUI.NB2NewPage_Button:SetMouseOverTexture("/esoui/art/chatwindow/chat_addtab_over.dds")
		NBUI.NB2NewPage_Button:SetNormalTexture("/esoui/art/chatwindow/chat_addtab_up.dds")
		NBUI.NB2NewPage_Button:SetPressedTexture("/esoui/art/chatwindow/chat_addtab_down.dds")
			
	NBUI.NB2NewPage_Button.highlight = WINDOW_MANAGER:CreateControl("NBUI_NB2NewPage_Button_highlight", NBUI.NB2NewPage_Button, CT_TEXTURE)		
		NBUI.NB2NewPage_Button.highlight:SetAnchor(TOPLEFT, NBUI.NB2NewPage_Button, TOPLEFT, -15, -6)
		NBUI.NB2NewPage_Button.highlight:SetAnchor(BOTTOMRIGHT, NBUI.NB2NewPage_Button, BOTTOMRIGHT, 6, 15)
		NBUI.NB2NewPage_Button.highlight:SetColor(0, 0.8, 0, 0)		
		NBUI.NB2NewPage_Button.highlight:SetDrawLayer(1)
		NBUI.NB2NewPage_Button.highlight:SetDrawLevel(1)
		NBUI.NB2NewPage_Button.highlight:SetDrawTier(0)		
		NBUI.NB2NewPage_Button.highlight:SetTexture("/esoui/art/chatwindow/maximize_up.dds")
		NBUI.NB2NewPage_Button.highlight:SetAlpha(1)
--***********************************************************************************************--		
--  MAIN WINDOW CLOSE BUTTON  ---------------------------------------------------------------------		
--[[
		NBUI.NB2Close_Button = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB2Close_Button", NBUI.NB2MainWindow, "ZO_CloseButton")
			NBUI.NB2Close_Button:SetDimensions(16, 16)
			NBUI.NB2Close_Button:SetAnchor(TOPRIGHT, NBUI.NB2RightPage_TitleBackdrop, TOPRIGHT, 40, -25)
			NBUI.NB2Close_Button:SetHandler("OnClicked", function(self) 
				NBUI.NB2MainWindow:SetHidden(true) 
				NBUI.NB2MainWindow:SetTopmost(false)
			end) 
			NBUI.NB2Close_Button:SetHandler("OnMouseEnter", function(self)
				InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
				SetTooltipText(InformationTooltip, GetString(SI_NBUI_CLOSEBUTTON_TOOLTIP))
			end)
			NBUI.NB2Close_Button:SetHandler("OnMouseExit", function(self)
				ClearTooltip(InformationTooltip)
			end)
]]--

	NBUI.NB2Close_Button = WINDOW_MANAGER:CreateControl("NBUI_NB2Close_Button", NBUI.NB2MainWindow, CT_BUTTON)
		NBUI.NB2Close_Button:SetAnchor(BOTTOMRIGHT, NBUI.NB2RightPage_Backdrop, BOTTOMRIGHT, 46, 16)		
		NBUI.NB2Close_Button:SetClickSound(SOUNDS.BOOK_CLOSE)		
		NBUI.NB2Close_Button:SetDimensions(25, 25)
		NBUI.NB2Close_Button:SetDrawLayer(1)
		NBUI.NB2Close_Button:SetDrawLevel(2)
		NBUI.NB2Close_Button:SetDrawTier(0)	
		NBUI.NB2Close_Button:SetHandler("OnClicked", function(self) 
			NBUI.NB2MainWindow:SetHidden(true) 
			if SCENE_MANAGER:IsInUIMode() then
				SCENE_MANAGER:SetInUIMode(false)
			end
			DoCommand("/idle")
		end)
		NBUI.NB2Close_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, GetString(SI_NBUI_CLOSEBUTTON_TOOLTIP))
		end)
		NBUI.NB2Close_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)
		NBUI.NB2Close_Button:SetMouseOverTexture("/esoui/art/buttons/closebutton_mouseover.dds")
		NBUI.NB2Close_Button:SetNormalTexture("/esoui/art/buttons/closebutton_up.dds")
		NBUI.NB2Close_Button:SetPressedTexture("/esoui/art/buttons/closebutton_down.dds")
		
	NBUI.NB2Close_ButtonTexture = WINDOW_MANAGER:CreateControl("NBUI_NB2Close_ButtonTexture", NBUI.NB2Close_Button, CT_TEXTURE)		
		NBUI.NB2Close_ButtonTexture:SetAnchor(TOPLEFT, NBUI.NB2Close_Button, TOPLEFT, -20, -11)
		NBUI.NB2Close_ButtonTexture:SetAnchor(BOTTOMRIGHT, NBUI.NB2Close_Button, BOTTOMRIGHT, 10, 20)
		NBUI.NB2Close_ButtonTexture:SetColor(0.8, 0, 0, 0)		
		NBUI.NB2Close_ButtonTexture:SetDrawLayer(1)
		NBUI.NB2Close_ButtonTexture:SetDrawLevel(1)
		NBUI.NB2Close_ButtonTexture:SetDrawTier(0)	
		NBUI.NB2Close_ButtonTexture:SetTexture("/esoui/art/chatwindow/maximize_up.dds")--("/esoui/art/buttons/cancel_up.dds")
		NBUI.NB2Close_ButtonTexture:SetTextureRotation(4.7, .61, .32)
		NBUI.NB2Close_ButtonTexture:SetAlpha(1)
		
--***********************************************************************************************--		
--  CHAT WINDOW BUTTONS  --------------------------------------------------------------------------
	NBUI.NB2MaxChatWin_Button = WINDOW_MANAGER:CreateControl("NBUI_NB2MaxChatWin_Button", ZO_ChatWindow, CT_BUTTON)	
		NBUI.NB2MaxChatWin_Button:SetDimensions(32, 32)
		NBUI.NB2MaxChatWin_Button:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, NBUIDB.NB2_MaxOffsetChatButton, 7)
		NBUI.NB2MaxChatWin_Button:SetMouseOverTexture("/esoui/art/mainmenu/menubar_journal_down.dds")
		NBUI.NB2MaxChatWin_Button:SetHidden(not NBUIDB.NB2_ChatButton)				
		NBUI.NB2MaxChatWin_Button:SetHandler("OnClicked", function(self)
			--if button == 1 then
				NBUI.NB2KeyBindToggle()
			--elseif button == 2 then
				--DoCommand("/nb1s") 
			--end
		end)		
		NBUI.NB2MaxChatWin_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, NBUIDB.NB2_Title)
		end)
		NBUI.NB2MaxChatWin_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)
		
	NBUI.NB2MaxChatWin_ButtonTexture = WINDOW_MANAGER:CreateControl("NBUI_NB2MaxTexureChatButton", ZO_ChatWindow, CT_TEXTURE)		
		NBUI.NB2MaxChatWin_ButtonTexture:SetAnchorFill(NBUI.NB2MaxChatWin_Button)
		NBUI.NB2MaxChatWin_ButtonTexture:SetColor(unpack(NBUIDB.NB2_BookColor))
		NBUI.NB2MaxChatWin_ButtonTexture:SetDrawTier(DT_HIGH)
		NBUI.NB2MaxChatWin_ButtonTexture:SetHidden(not NBUIDB.NB2_ChatButton)
		NBUI.NB2MaxChatWin_ButtonTexture:SetTexture("/esoui/art/mainmenu/menubar_journal_up.dds")
---------------------------------------------------------------------------------------------------
	NBUI.NB2MinChatWin_Button = WINDOW_MANAGER:CreateControl("NBUI_NB2MinChatWin_Button", ZO_ChatWindowMinBar, CT_BUTTON)
		NBUI.NB2MinChatWin_Button:SetDimensions(32, 32)
		NBUI.NB2MinChatWin_Button:SetAnchor(BOTTOMLEFT, ZO_ChatWindowMinBar, BOTTOMLEFT, -3, NBUIDB.NB2_MinOffsetChatButton)
		NBUI.NB2MinChatWin_Button:SetMouseOverTexture("/esoui/art/mainmenu/menubar_journal_down.dds")
		NBUI.NB2MinChatWin_Button:SetHidden(not NBUIDB.NB2_ChatButton)
		NBUI.NB2MinChatWin_Button:SetHandler("OnClicked", function(self)
			NBUI.NB2KeyBindToggle()
		end)		
		NBUI.NB2MinChatWin_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, NBUIDB.NB2_Title)
		end)
		NBUI.NB2MinChatWin_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)

	NBUI.NB2MinChatWin_ButtonTexture = WINDOW_MANAGER:CreateControl("NBUI_NB2MinTexureChatButton", ZO_ChatWindowMinBar, CT_TEXTURE)		
		NBUI.NB2MinChatWin_ButtonTexture:SetAnchorFill(NBUI.NB2MinChatWin_Button)
		NBUI.NB2MinChatWin_ButtonTexture:SetColor(unpack(NBUIDB.NB2_BookColor))
		NBUI.NB2MinChatWin_ButtonTexture:SetDrawTier(DT_HIGH)
		NBUI.NB2MinChatWin_ButtonTexture:SetHidden(not NBUIDB.NB2_ChatButton)
		NBUI.NB2MinChatWin_ButtonTexture:SetTexture("/esoui/art/mainmenu/menubar_journal_up.dds")		
end
---------------------------------------------------------------------------------------------------
-- new page function
function NBUI.NB2NewPage(self)		
	currentlyViewing = nil
	NBUI.NB2RightPage_Title:SetText("New Page "..#NBUIDB.NB2Pages+1)
	--NBUI.NB2RightPage_Title:SelectAll()
	--NBUI.NB2RightPage_Title:TakeFocus()
	NBUI.NB2RightPage_Contents:Clear()
	NBUI.NB2SavePage(self)
	
	NBUI.NB2UndoPage_Button:SetHidden(true)
end	
NB2ConfirmNewDialog = {
	title={ text = GetString(SI_NBUI_NEWBUTTON_TITLE)},
	mainText={ text = GetString(SI_NBUI_NEWBUTTON_MAINTEXT)},
	buttons = {
		[1]={ 
			text = GetString(SI_NBUI_YES_LABEL), callback = function(self)
				NBUI.NB2NewPage(self)
				zo_callLater(function() SetGameCameraUIMode(true) end, 10)
			end
			},
		[2]={ text = GetString(SI_NBUI_NO_LABEL)}
	}
}
ZO_Dialogs_RegisterCustomDialog("NBUI_NB2CONFIRM_NEWPAGE", NB2ConfirmNewDialog)
---------------------------------------------------------------------------------------------------
-- save page function
function NBUI.NB2SavePage(self) 		
	local titleText = NBUI.NB2RightPage_Title:GetText()
		if titleText == "" then
			NBUI.NB2RightPage_Title:SetText("New Page "..#NBUIDB.NB2Pages+1)
			titleText = NBUI.NB2RightPage_Title:GetText()
		end
	local pageText = NBUI.NB2RightPage_Contents:GetText()
	local safe_titleText = ProtectText(titleText)	
	local safe_pageText = ProtectText(pageText)
		if currentlyViewing == nil then	--if this was a new page
			table.insert(NBUIDB.NB2Pages, {["title"] = safe_titleText, ["text"]=safe_pageText})
			currentlyViewing = #NBUIDB.NB2Pages
			NBUI.NB2SelectedPage_Button:SetHidden(false)
			NBUI.NB2SelectedPage_Button:ClearAnchors()
			self.new = true
		else
			NBUIDB.NB2Pages[currentlyViewing].title = safe_titleText
			NBUIDB.NB2Pages[currentlyViewing].text = safe_pageText
			self.new = false
		end
		
	Populate_NB2_ScrollList()
		if self.new then
			NBUI.NB2SelectedPage_Button:SetAnchorFill(_G["NBUI_Index"..currentlyViewing])
		end
	
	NBUI.NB2SavePage_Button:SetHidden(true)
	NBUI.NB2UndoPage_Button:SetHidden(true)
end
NB2ConfirmSaveDialog = {
	title = { text = GetString(SI_NBUI_SAVEBUTTON_TITLE)},
	mainText = { text = GetString(SI_NBUI_SAVEBUTTON_MAINTEXT)},
	buttons = {
		[1]={ 
			text = GetString(SI_NBUI_YES_LABEL), callback = function(self)
				NBUI.NB2SavePage(self)
				zo_callLater(function() SetGameCameraUIMode(true) end, 10)
			end
			},
		[2]={ text = GetString(SI_NBUI_NO_LABEL)}
	}
}
ZO_Dialogs_RegisterCustomDialog("NBUI_NB2CONFIRM_SAVE", NB2ConfirmSaveDialog)
---------------------------------------------------------------------------------------------------
-- undo page function
function NBUI.NB2UndoPage() 		
	if currentlyViewing then
		NBUI.NB2RightPage_Title:SetText(NBUIDB.NB2Pages[currentlyViewing].title)
		NBUI.NB2RightPage_Contents:SetText(NBUIDB.NB2Pages[currentlyViewing].text)
	end
	
	NBUI.NB2SavePage_Button:SetHidden(true)
	NBUI.NB2UndoPage_Button:SetHidden(true)
end
NB2ConfirmUndoDialog = {
	title = { text = GetString(SI_NBUI_UNDOPAGE_TITLE)},
	mainText = { text = GetString(SI_NBUI_UNDOPAGE_MAINTEXT)},
	buttons = {
		[1]={ 
			text = GetString(SI_NBUI_YES_LABEL), callback = function()
				NBUI.NB2UndoPage()
				zo_callLater(function() SetGameCameraUIMode(true) end, 10)
			end
			},
		[2]={ text = GetString(SI_NBUI_NO_LABEL)}
	}
}
ZO_Dialogs_RegisterCustomDialog("NBUI_NB2CONFIRM_UNDO", NB2ConfirmUndoDialog)
---------------------------------------------------------------------------------------------------
-- delete page function
function NBUI.NB2DeletePage()
	if currentlyViewing then
		table.remove(NBUIDB.NB2Pages, currentlyViewing)
		currentlyViewing = nil
		Populate_NB2_ScrollList()
		NBUI.NB2SelectedPage_Button:SetHidden(true)
	end

	NBUI.NB2RightPage_Title:Clear()
	NBUI.NB2RightPage_Contents:Clear()
		
	NBUI.NB2DeletePage_Button:SetHidden(true)
	NBUI.NB2SavePage_Button:SetHidden(true)				
	NBUI.NB2UndoPage_Button:SetHidden(true)
	NBUI.NB2RunScript_Button:SetHidden(true)
end
NB2ConfirmDeleteDialog = {
	title = {text = GetString(SI_NBUI_DELETEBUTTON_TITLE)},
	mainText = {text = GetString(SI_NBUI_DELETEBUTTON_MAINTEXT)},
	buttons = {
		[1]={
			text = GetString(SI_NBUI_YES_LABEL), callback = function()
				NBUI.NB2DeletePage()
				zo_callLater(function() SetGameCameraUIMode(true) end, 10)
			end
			},
		[2]={text = GetString(SI_NBUI_NO_LABEL)}
	}
}
ZO_Dialogs_RegisterCustomDialog("NBUI_NB2CONFIRM_DELETE", NB2ConfirmDeleteDialog)
---------------------------------------------------------------------------------------------------
function NBUI.NB2KeyBindToggle()
	if NBUI.NB2MainWindow:IsHidden() then
		NBUI.NB2MainWindow:SetHidden(false)
		NBUI.NB2MainWindow:BringWindowToTop(true)
		if not SCENE_MANAGER:IsInUIMode() then
			SCENE_MANAGER:SetInUIMode(true)
		end
		DoCommand("/read")
		PlaySound(SOUNDS.BOOK_OPEN)
	else
		NBUI.NB2MainWindow:SetHidden(true)
		if SCENE_MANAGER:IsInUIMode() then
			SCENE_MANAGER:SetInUIMode(false)
		end
		DoCommand("/idle")
		PlaySound(SOUNDS.BOOK_CLOSE)
	end
end

---------------------------------------------------------------------------------------------------
--  Chat Commands  --
---------------------------------------------------------------------------------------------------
SLASH_COMMANDS["/nb2"] = NBUI.NB2KeyBindToggle