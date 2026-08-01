if NBUI == nil then NBUI = {} end

local buttonCount = 1
---------------------------------------------------------------------------------------------------
function Create_NB3_IndexButton(NB3_IndexPool)
	local button = WINDOW_MANAGER:CreateControlFromVirtual("NB3_Index" .. NB3_IndexPool:GetNextControlId(), NBUI.NB3LeftPage_ScrollContainer.scrollChild, "ZO_DefaultTextButton")
	local anchorBtn = buttonCount == 1 and NBUI.NB3LeftPage_ScrollContainer.scrollChild or NB3_IndexPool:AcquireObject(buttonCount-1)
		button:SetAnchor(TOPLEFT, anchorBtn, buttonCount == 1 and TOPLEFT or BOTTOMLEFT)
		button:SetClickSound(SOUNDS.BOOK_PAGE_TURN)			
		button:SetFont("ZoFontBookPaper")		
		button:SetHandler("OnClicked", function(self)
			
			currentlyViewing = self.id
		
			NBUI.NB3RightPage_Title:SetText(UnprotectText(self.data.title))
			NBUI.NB3RightPage_Title:SetCursorPosition(TOPLEFT)
			
			NBUI.NB3RightPage_Contents:SetText(UnprotectText(self.data.text))
			NBUI.NB3RightPage_Contents:SetCursorPosition(TOPLEFT)
			
			NBUI.NB3SelectedPage_Button:ClearAnchors()
			NBUI.NB3SelectedPage_Button:SetAnchorFill(self)			
			-- shows these buttons
			NBUI.NB3SavePage_Button:SetHidden(true)
			NBUI.NB3UndoPage_Button:SetHidden(true)
			-- hides these buttons
			NBUI.NB3RunScript_Button:SetHidden(false)
			NBUI.NB3DeletePage_Button:SetHidden(false)
			NBUI.NB3SelectedPage_Button:SetHidden(false)
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
function Populate_NB3_ScrollList()
	local numPages = #NBUIDB.NB3Pages
	for i = 1, numPages do
		local button = NB3_IndexPool:AcquireObject(i)
		button.data = NBUIDB.NB3Pages[i]
		button.id = i
		button:SetText(UnprotectText(button.data.title))
		button:SetHidden(false)
	end
	local activePages = NB3_IndexPool:GetActiveObjectCount()
	if activePages > numPages then
		for i = numPages+1, activePages do
			NB3_IndexPool:ReleaseObject(i)
		end
	end
end
---------------------------------------------------------------------------------------------------
function Remove_NB3_IndexButton(button)
	button:SetHidden(true)
end
---------------------------------------------------------------------------------------------------
--  Interface  --
---------------------------------------------------------------------------------------------------
function CreateNB3()
---------------------------------------------------------------------------------------------------
	NBUI.NB3MainWindow = WINDOW_MANAGER:CreateTopLevelWindow("NBUI_NB3MainWindow")	
		NBUI.NB3MainWindow:AllowBringToTop(true)
		NBUI.NB3MainWindow:SetAnchor(NBUIDB.NB3_Anchor.a, GuiRoot, NBUIDB.NB3_Anchor.b, NBUIDB.NB3_Anchor.x, NBUIDB.NB3_Anchor.y)
		NBUI.NB3MainWindow:SetClampedToScreen(true)		
		NBUI.NB3MainWindow:SetDimensions(1004, 752)
		NBUI.NB3MainWindow:SetDrawLayer(0)		
		NBUI.NB3MainWindow:SetDrawLevel(0) 
		NBUI.NB3MainWindow:SetDrawTier(0) 
		NBUI.NB3MainWindow:SetHandler("OnMoveStop", function(self)
			local _,a,_,b,x,y = self:GetAnchor()
			NBUIDB.anchor = {["a"]=a, ["b"]=b, ["x"]=x, ["y"]=y}
		end)		
		NBUI.NB3MainWindow:SetHandler("OnReceiveDrag", function(self)
			self:StartMoving()
		end)		
		NBUI.NB3MainWindow:SetHidden(true)		
		NBUI.NB3MainWindow:SetMouseEnabled(true)	
 		NBUI.NB3MainWindow:SetMovable(not NBUIDB.NB3_Locked)
---------------------------------------------------------------------------------------------------	
	NBUI.NB3MainWindow_Cover = WINDOW_MANAGER:CreateControl("NBUI_NB3MainWindow_Cover", NBUI.NB3MainWindow, CT_TEXTURE)
		NBUI.NB3MainWindow_Cover:SetAnchor(TOPLEFT, NBUI.NB3MainWindow, TOPLEFT, -10, -126)
		NBUI.NB3MainWindow_Cover:SetAnchor(BOTTOMRIGHT, NBUI.NB3MainWindow, BOTTOMRIGHT, 10, 146)		
		NBUI.NB3MainWindow_Cover:SetDimensions(1024, 1024)
		NBUI.NB3MainWindow_Cover:SetTexture("/esoui/art/lorelibrary/lorelibrary_paperbook.dds")
		NBUI.NB3MainWindow_Cover:SetColor(unpack(NBUIDB.NB3_BookColor))
		NBUI.NB3MainWindow_Cover:SetAlpha(1)
--***********************************************************************************************--		
--  LEFT PAGE  ------------------------------------------------------------------------------------
	NBUI.NB3LeftPage_TitleBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB3LeftPage_TitleBackdrop", NBUI.NB3MainWindow, "ZO_EditBackdrop")
		NBUI.NB3LeftPage_TitleBackdrop:SetAnchor(TOPLEFT, NBUI.NB3MainWindow_Cover, TOPLEFT, 85, 160)		
		NBUI.NB3LeftPage_TitleBackdrop:SetCenterColor(0, 0, 0, 0)		
		NBUI.NB3LeftPage_TitleBackdrop:SetDimensions(420, 45)
		NBUI.NB3LeftPage_TitleBackdrop:SetDrawLayer(0)		
		NBUI.NB3LeftPage_TitleBackdrop:SetDrawLevel(1)
		NBUI.NB3LeftPage_TitleBackdrop:SetDrawTier(0)		
		NBUI.NB3LeftPage_TitleBackdrop:SetEdgeColor(0, 0, 0, 0)
		NBUI.NB3LeftPage_TitleBackdrop:SetHidden(not NBUIDB.NB3_ShowTitle)	
---------------------------------------------------------------------------------------------------	
	NBUI.NB3LeftPage_Title = WINDOW_MANAGER:CreateControl("NBUI_NB3LeftPage_Title", NBUI.NB3MainWindow, CT_LABEL)
		NBUI.NB3LeftPage_Title:SetAnchor(CENTER, NBUI.NB3LeftPage_TitleBackdrop, CENTER, 0, 0)
		NBUI.NB3LeftPage_Title:SetColor(0, 0, 0, 0.7)	
		NBUI.NB3LeftPage_Title:SetDrawLayer(0)		
		NBUI.NB3LeftPage_Title:SetDrawLevel(2)
		NBUI.NB3LeftPage_Title:SetDrawTier(0) 			
		NBUI.NB3LeftPage_Title:SetFont("ZoFontBookPaperTitle")
		NBUI.NB3LeftPage_Title:SetHidden(not NBUIDB.NB3_ShowTitle)		
		NBUI.NB3LeftPage_Title:SetText(NBUIDB.NB3_Title)
---------------------------------------------------------------------------------------------------
	NBUI.NB3Information_Button = WINDOW_MANAGER:CreateControl("NBUI_NB3Information_Button", NBUI.NB3MainWindow, CT_BUTTON)
		NBUI.NB3Information_Button:SetAnchor(CENTER, NBUI.NB3LeftPage_TitleBackdrop, RIGHT, -30, 0)		
		NBUI.NB3Information_Button:SetDimensions(32, 32)
		NBUI.NB3Information_Button:SetDrawLayer(1)		
		NBUI.NB3Information_Button:SetDrawLevel(1)
		NBUI.NB3Information_Button:SetDrawTier(0)		
		NBUI.NB3Information_Button:SetHandler("OnClicked", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, GetString(SI_NBUI_NB3INFORMATION_TOOLTIP))
		end)
		NBUI.NB3Information_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)
		NBUI.NB3Information_Button:SetHidden(not NBUIDB.NB3_ShowTitle)		
		NBUI.NB3Information_Button:SetMouseOverTexture("/esoui/art/buttons/info_over.dds")
		NBUI.NB3Information_Button:SetNormalTexture("/esoui/art/buttons/info_up.dds")
		NBUI.NB3Information_Button:SetPressedTexture("/esoui/art/buttons/info_down.dds")
---------------------------------------------------------------------------------------------------		
	NBUI.NB3LeftPage_Separator = WINDOW_MANAGER:CreateControl("NBUI_NB3LeftPage_Separator", NBUI.NB3MainWindow, CT_TEXTURE)		
		NBUI.NB3LeftPage_Separator:SetAnchor(CENTER, NBUI.NB3LeftPage_TitleBackdrop, BOTTOM, 0, 0)		
		NBUI.NB3LeftPage_Separator:SetColor(0, 0, 0, 0.7)		
		NBUI.NB3LeftPage_Separator:SetDimensions(420, 2)
		NBUI.NB3LeftPage_Separator:SetDrawLayer(1)		
		NBUI.NB3LeftPage_Separator:SetDrawLevel(1)
		NBUI.NB3LeftPage_Separator:SetDrawTier(0)		
		NBUI.NB3LeftPage_Separator:SetHidden(not NBUIDB.NB3_ShowTitle)
		NBUI.NB3LeftPage_Separator:SetTexture("/esoui/art/interaction/conversation_divider.dds")	
---------------------------------------------------------------------------------------------------
	NBUI.NB3LeftPage_Backdrop = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB3LeftPage_Backdrop", NBUI.NB3MainWindow, "ZO_EditBackdrop")
		NBUI.NB3LeftPage_Backdrop:SetAnchor(BOTTOMLEFT, NBUI.NB3MainWindow_Cover, BOTTOMLEFT, 85, -174)		
		NBUI.NB3LeftPage_Backdrop:SetCenterColor(0, 0, 0, 0)
			if (NBUIDB.NB3_ShowTitle) then
				NBUI.NB3LeftPage_Backdrop:SetDimensions(420, 645)
			else
				NBUI.NB3LeftPage_Backdrop:SetDimensions(420, 690)
			end	
		NBUI.NB3LeftPage_Backdrop:SetDrawLayer(0)		
		NBUI.NB3LeftPage_Backdrop:SetDrawLevel(1)
		NBUI.NB3LeftPage_Backdrop:SetDrawTier(0)		
		NBUI.NB3LeftPage_Backdrop:SetEdgeColor(0, 0, 0, 0)		
---------------------------------------------------------------------------------------------------
	NBUI.NB3LeftPage_ScrollContainer = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB3LeftPage_ScrollContainer", NBUI.NB3MainWindow, "ZO_ScrollContainer")
		NBUI.NB3LeftPage_ScrollContainer.scrollChild = NBUI.NB3LeftPage_ScrollContainer:GetNamedChild("ScrollChild")		
		NBUI.NB3LeftPage_ScrollContainer:SetAnchorFill(NBUI.NB3LeftPage_Backdrop)
		NBUI.NB3LeftPage_ScrollContainer:SetDrawLayer(0)	
		NBUI.NB3LeftPage_ScrollContainer:SetDrawLevel(2)
		NBUI.NB3LeftPage_ScrollContainer:SetDrawTier(0)
---------------------------------------------------------------------------------------------------	  
	NBUI.NB3SelectedPage_Button = WINDOW_MANAGER:CreateControl(nil, NBUI.NB3LeftPage_ScrollContainer.scrollChild, CT_TEXTURE)
		NBUI.NB3SelectedPage_Button:SetAlpha(.45)		
		NBUI.NB3SelectedPage_Button:SetDrawLayer(0)		
		NBUI.NB3SelectedPage_Button:SetDrawLevel(3) 
		NBUI.NB3SelectedPage_Button:SetDrawTier(0) 	
		NBUI.NB3SelectedPage_Button:SetHidden(true)
		NBUI.NB3SelectedPage_Button:SetTexture("esoui/art/buttons/generic_highlight.dds")
		NBUI.NB3SelectedPage_Button:SetWidth(420)
---------------------------------------------------------------------------------------------------		
	NBUI.NB3SavePage_Button = WINDOW_MANAGER:CreateControl("NBUI_NB3SavePage_Button", NBUI.NB3LeftPage_ScrollContainer.scrollChild, CT_BUTTON)
		NBUI.NB3SavePage_Button:SetAnchor(RIGHT, NBUI.NB3SelectedPage_Button, RIGHT, -95, -2) 		
		NBUI.NB3SavePage_Button:SetClickSound(SOUNDS.BOOK_PAGE_TURN)
		NBUI.NB3SavePage_Button:SetDimensions(30, 30)
		NBUI.NB3SavePage_Button:SetDrawLayer(1)		
		NBUI.NB3SavePage_Button:SetDrawLevel(1)
		NBUI.NB3SavePage_Button:SetDrawTier(0)	
		NBUI.NB3SavePage_Button:SetHandler("OnClicked", function(self)
			if (NBUIDB.showdialog) then
				ZO_Dialogs_ShowDialog("NBUI_NB3CONFIRM_SAVE")
			else
				NBUI.NB3SavePage(self)
			end			
		end)
		NBUI.NB3SavePage_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, GetString(SI_NBUI_SAVEBUTTON_TOOLTIP))
		end)
		NBUI.NB3SavePage_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)
		NBUI.NB3SavePage_Button:SetHidden(true)		
		NBUI.NB3SavePage_Button:SetMouseOverTexture("/esoui/art/buttons/edit_save_over.dds")
		NBUI.NB3SavePage_Button:SetNormalTexture("/esoui/art/buttons/edit_save_up.dds")
		NBUI.NB3SavePage_Button:SetPressedTexture("/esoui/art/buttons/edit_save_down.dds")	
---------------------------------------------------------------------------------------------------		
	NBUI.NB3UndoPage_Button = WINDOW_MANAGER:CreateControl("NBUI_NB3UndoPage_Button", NBUI.NB3LeftPage_ScrollContainer.scrollChild, CT_BUTTON)
		NBUI.NB3UndoPage_Button:SetAnchor(RIGHT, NBUI.NB3SelectedPage_Button, RIGHT, -60, 0)
		NBUI.NB3UndoPage_Button:SetClickSound(SOUNDS.BOOK_PAGE_TURN)
		NBUI.NB3UndoPage_Button:SetDimensions(32, 35)
		NBUI.NB3UndoPage_Button:SetDrawLayer(1)		
		NBUI.NB3UndoPage_Button:SetDrawLevel(1)
		NBUI.NB3UndoPage_Button:SetDrawTier(0)
		NBUI.NB3UndoPage_Button:SetHandler("OnClicked", function(self)
			if (NBUIDB.showdialog) then
				ZO_Dialogs_ShowDialog("NBUI_NB3CONFIRM_UNDO")
			else
				NBUI.NB3UndoPage()
			end			
		end)
		NBUI.NB3UndoPage_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, GetString(SI_NBUI_UNDOBUTTON_TOOLTIP))
		end)
		NBUI.NB3UndoPage_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)
		NBUI.NB3UndoPage_Button:SetHidden(true)		
		NBUI.NB3UndoPage_Button:SetMouseOverTexture("/esoui/art/contacts/social_note_over.dds") 
		NBUI.NB3UndoPage_Button:SetNormalTexture("/esoui/art/contacts/social_note_up.dds")
		NBUI.NB3UndoPage_Button:SetPressedTexture("/esoui/art/contacts/social_note_down.dds")		
---------------------------------------------------------------------------------------------------		
	NBUI.NB3RunScript_Button = WINDOW_MANAGER:CreateControl("NBUI_NB3RunScript_Button", NBUI.NB3LeftPage_ScrollContainer.scrollChild, CT_BUTTON)
		NBUI.NB3RunScript_Button:SetAnchor(RIGHT, NBUI.NB3SelectedPage_Button, RIGHT, -30, -2)		
		NBUI.NB3RunScript_Button:SetClickSound(SOUNDS.BOOK_PAGE_TURN)
		NBUI.NB3RunScript_Button:SetDimensions(28, 28)
		NBUI.NB3RunScript_Button:SetDrawLayer(1)		
		NBUI.NB3RunScript_Button:SetDrawLevel(1)
		NBUI.NB3RunScript_Button:SetDrawTier(0) 
		NBUI.NB3RunScript_Button:SetHandler("OnClicked", function(self)
			local NBUIScript = zo_loadstring(NBUI.NB3RightPage_Contents:GetText())
			if NBUIScript then
				NBUIScript()
			end
		end)
		NBUI.NB3RunScript_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, GetString(SI_NBUI_RUNBUTTON_TOOLTIP))
		end)
		NBUI.NB3RunScript_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)
		NBUI.NB3RunScript_Button:SetHidden(true)		
		NBUI.NB3RunScript_Button:SetMouseOverTexture("/esoui/art/buttons/edit_over.dds")
		NBUI.NB3RunScript_Button:SetNormalTexture("/esoui/art/buttons/edit_up.dds")
		NBUI.NB3RunScript_Button:SetPressedTexture("/esoui/art/buttons/edit_down.dds")
---------------------------------------------------------------------------------------------------
	NBUI.NB3DeletePage_Button = WINDOW_MANAGER:CreateControl("NBUI_NB3DeletePage_Button", NBUI.NB3LeftPage_ScrollContainer.scrollChild, CT_BUTTON)
		NBUI.NB3DeletePage_Button:SetAnchor(RIGHT, NBUI.NB3SelectedPage_Button, RIGHT, 0, 0) 		
		NBUI.NB3DeletePage_Button:SetClickSound(SOUNDS.BOOK_PAGE_TURN)
		NBUI.NB3DeletePage_Button:SetDimensions(26, 26)
		NBUI.NB3DeletePage_Button:SetDrawLayer(1)
		NBUI.NB3DeletePage_Button:SetDrawLevel(1)
		NBUI.NB3DeletePage_Button:SetDrawTier(0)
		NBUI.NB3DeletePage_Button:SetHandler("OnClicked", function(self)
			if (NBUIDB.NB3_ShowDialog) then
				ZO_Dialogs_ShowDialog("NBUI_NB3CONFIRM_DELETE")
			else
				NBUI.NB3DeletePage()
			end			
		end)
		NBUI.NB3DeletePage_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, GetString(SI_NBUI_DELETEBUTTON_TOOLTIP))
		end)
		NBUI.NB3DeletePage_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)		
		NBUI.NB3DeletePage_Button:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
		NBUI.NB3DeletePage_Button:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
		NBUI.NB3DeletePage_Button:SetPressedTexture("/esoui/art/buttons/decline_down.dds")		
--***********************************************************************************************--		
--  RIGHT PAGE  -----------------------------------------------------------------------------------		
	NBUI.NB3RightPage_TitleBackdrop  = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB3RightPage_TitleBackdrop", NBUI.NB3MainWindow, "ZO_EditBackdrop")
		NBUI.NB3RightPage_TitleBackdrop:SetAnchor(TOPRIGHT, NBUI.NB3MainWindow_Cover, TOPRIGHT, -70, 160)		
		NBUI.NB3RightPage_TitleBackdrop:SetCenterColor(0, 0, 0, 0)		
		NBUI.NB3RightPage_TitleBackdrop:SetDimensions(420, 45)
		NBUI.NB3RightPage_TitleBackdrop:SetDrawLayer(0)
		NBUI.NB3RightPage_TitleBackdrop:SetDrawLevel(1)
		NBUI.NB3RightPage_TitleBackdrop:SetDrawTier(0)		
		NBUI.NB3RightPage_TitleBackdrop:SetEdgeColor(0, 0, 0, 0)		
---------------------------------------------------------------------------------------------------	
	NBUI.NB3RightPage_Backdrop = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB3RightPage_Backdrop", NBUI.NB3MainWindow, "ZO_EditBackdrop")
		NBUI.NB3RightPage_Backdrop:SetAnchor(BOTTOMRIGHT, NBUI.NB3MainWindow_Cover, BOTTOMRIGHT, -70, -174)		
		NBUI.NB3RightPage_Backdrop:SetCenterColor(0, 0, 0, 0)		
		NBUI.NB3RightPage_Backdrop:SetDimensions(420, 645)
		NBUI.NB3RightPage_Backdrop:SetDrawLayer(0)
		NBUI.NB3RightPage_Backdrop:SetDrawLevel(1)
		NBUI.NB3RightPage_Backdrop:SetDrawTier(0)		
		NBUI.NB3RightPage_Backdrop:SetEdgeColor(0, 0, 0, 0)
---------------------------------------------------------------------------------------------------	
	NBUI.NB3RightPage_Title = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB3RightPage_Title", NBUI.NB3RightPage_TitleBackdrop, "ZO_DefaultEditForBackdrop")
		NBUI.NB3RightPage_Title:SetColor(0, 0, 0, 0.7)			
		NBUI.NB3RightPage_Title:SetDrawLayer(0)
		NBUI.NB3RightPage_Title:SetDrawLevel(2)
		NBUI.NB3RightPage_Title:SetDrawTier(0)		
		NBUI.NB3RightPage_Title:SetFont("ZoFontBookPaperTitle")
		NBUI.NB3RightPage_Title:SetHandler("OnEscape", NBUI.NB3RightPage_Title.LoseFocus)		
		NBUI.NB3RightPage_Title:SetHandler("OnTab", function() 
			NBUI.NB3RightPage_Contents:TakeFocus() 
		end)
		NBUI.NB3RightPage_Title:SetHandler("OnMouseDoubleClick", function(self) 
			zo_callLater(function() self:SelectAll() end, 0.5)
		end) 
		NBUI.NB3RightPage_Title:SetHandler("OnTextChanged", function(self)
				local NB3Pages = NBUIDB.NB3Pages[currentlyViewing]
				if not NB3Pages or self:GetText() ~= NB3Pages.title or self:GetText() then
					NBUI.NB3SavePage_Button:SetHidden(false)
					NBUI.NB3UndoPage_Button:SetHidden(false)				
				else
					NBUI.NB3SavePage_Button:SetHidden(true)
					NBUI.NB3UndoPage_Button:SetHidden(true)				
				end
			end)
		NBUI.NB3RightPage_Title:SetMaxInputChars(30)
---------------------------------------------------------------------------------------------------		
	NBUI.NB3RightPage_ScrollContainer = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB3RightPage_ScrollContainer", NBUI.NB3MainWindow, "ZO_ScrollContainer")
		NBUI.NB3RightPage_ScrollContainer.scrollChild = NBUI.NB3RightPage_ScrollContainer:GetNamedChild("ScrollChild")		
		NBUI.NB3RightPage_ScrollContainer:SetAnchorFill(NBUI.NB3RightPage_Backdrop)
		NBUI.NB3RightPage_ScrollContainer:SetDrawLayer(0)	
		NBUI.NB3RightPage_ScrollContainer:SetDrawLevel(2)
		NBUI.NB3RightPage_ScrollContainer:SetDrawTier(0)
---------------------------------------------------------------------------------------------------	
	NBUI.NB3RightPage_Contents = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB3RightPage_Contents", NBUI.NB3RightPage_ScrollContainer, "ZO_DefaultEditMultiLineForBackdrop")
		NBUI.NB3RightPage_Contents:SetColor(0, 0, 0, 0.7)		
		NBUI.NB3RightPage_Contents:SetDrawLayer(0)
		NBUI.NB3RightPage_Contents:SetDrawLevel(3)
		NBUI.NB3RightPage_Contents:SetDrawTier(1)	
		NBUI.NB3RightPage_Contents:SetFont("ZoFontBookPaper")
		NBUI.NB3RightPage_Contents:SetHandler("OnEscape", NBUI.NB3RightPage_Contents.LoseFocus)
		NBUI.NB3RightPage_Contents:SetHandler("OnTab", function() 
			NBUI.NB3RightPage_Title:TakeFocus() 
		end)
		NBUI.NB3RightPage_Contents:SetHandler("OnMouseDoubleClick", function(self) 
			zo_callLater(function() self:SelectAll() end, 0.5)
		end)		
		NBUI.NB3RightPage_Contents:SetHandler("OnTextChanged", function(self)
			local page = NBUIDB.NB3Pages[currentlyViewing]
			if not page or self:GetText() ~= page.text or self:GetText() then
				NBUI.NB3SavePage_Button:SetHidden(false)
				NBUI.NB3UndoPage_Button:SetHidden(false)				
			else
				NBUI.NB3SavePage_Button:SetHidden(true)
				NBUI.NB3UndoPage_Button:SetHidden(true)				
			end
		end)
		NBUI.NB3RightPage_Contents:SetMaxInputChars(3000) --625 to only fill a page full
		NBUI.NB3RightPage_Contents:SetMultiLine(true)
---------------------------------------------------------------------------------------------------	
	NBUI.NB3NewPage_Button = WINDOW_MANAGER:CreateControl("NBUI_NB3NewPage_Button", NBUI.NB3MainWindow, CT_BUTTON)
		NBUI.NB3NewPage_Button:SetAnchor(TOPRIGHT, NBUI.NB3RightPage_TitleBackdrop, TOPRIGHT, 34, -25)		
		NBUI.NB3NewPage_Button:SetClickSound(SOUNDS.BOOK_PAGE_TURN)	
		NBUI.NB3NewPage_Button:SetDimensions(32, 32)
		NBUI.NB3NewPage_Button:SetDrawLayer(1)
		NBUI.NB3NewPage_Button:SetDrawLevel(2)
		NBUI.NB3NewPage_Button:SetDrawTier(0)		
		NBUI.NB3NewPage_Button:SetHandler("OnClicked", function(self)
			if (NBUIDB.NB3_ShowDialog) then
				ZO_Dialogs_ShowDialog("NBUI_NB3CONFIRM_NEWPAGE")
			else
				NBUI.NB3NewPage(self)
			end	
		end)
		NBUI.NB3NewPage_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, GetString(SI_NBUI_NEWBUTTON_TOOLTIP))
		end)
		NBUI.NB3NewPage_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)		
		NBUI.NB3NewPage_Button:SetMouseOverTexture("/esoui/art/chatwindow/chat_addtab_over.dds")
		NBUI.NB3NewPage_Button:SetNormalTexture("/esoui/art/chatwindow/chat_addtab_up.dds")
		NBUI.NB3NewPage_Button:SetPressedTexture("/esoui/art/chatwindow/chat_addtab_down.dds")
			
	NBUI.NB3NewPage_Button.highlight = WINDOW_MANAGER:CreateControl("NBUI_NB3NewPage_Button_highlight", NBUI.NB3NewPage_Button, CT_TEXTURE)		
		NBUI.NB3NewPage_Button.highlight:SetAnchor(TOPLEFT, NBUI.NB3NewPage_Button, TOPLEFT, -15, -6)
		NBUI.NB3NewPage_Button.highlight:SetAnchor(BOTTOMRIGHT, NBUI.NB3NewPage_Button, BOTTOMRIGHT, 6, 15)
		NBUI.NB3NewPage_Button.highlight:SetColor(0, 0.8, 0, 0)		
		NBUI.NB3NewPage_Button.highlight:SetDrawLayer(1)
		NBUI.NB3NewPage_Button.highlight:SetDrawLevel(1)
		NBUI.NB3NewPage_Button.highlight:SetDrawTier(0)		
		NBUI.NB3NewPage_Button.highlight:SetTexture("/esoui/art/chatwindow/maximize_up.dds")
		NBUI.NB3NewPage_Button.highlight:SetAlpha(1)
--***********************************************************************************************--		
--  MAIN WINDOW CLOSE BUTTON  ---------------------------------------------------------------------		
--[[
		NBUI.NB3Close_Button = WINDOW_MANAGER:CreateControlFromVirtual("NBUI_NB3Close_Button", NBUI.NB3MainWindow, "ZO_CloseButton")
			NBUI.NB3Close_Button:SetDimensions(16, 16)
			NBUI.NB3Close_Button:SetAnchor(TOPRIGHT, NBUI.NB3RightPage_TitleBackdrop, TOPRIGHT, 40, -25)
			NBUI.NB3Close_Button:SetHandler("OnClicked", function(self) 
				NBUI.NB3MainWindow:SetHidden(true) 
				NBUI.NB3MainWindow:SetTopmost(false)
			end) 
			NBUI.NB3Close_Button:SetHandler("OnMouseEnter", function(self)
				InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
				SetTooltipText(InformationTooltip, GetString(SI_NBUI_CLOSEBUTTON_TOOLTIP))
			end)
			NBUI.NB3Close_Button:SetHandler("OnMouseExit", function(self)
				ClearTooltip(InformationTooltip)
			end)
]]--

	NBUI.NB3Close_Button = WINDOW_MANAGER:CreateControl("NBUI_NB3Close_Button", NBUI.NB3MainWindow, CT_BUTTON)
		NBUI.NB3Close_Button:SetAnchor(BOTTOMRIGHT, NBUI.NB3RightPage_Backdrop, BOTTOMRIGHT, 46, 16)		
		NBUI.NB3Close_Button:SetClickSound(SOUNDS.BOOK_CLOSE)		
		NBUI.NB3Close_Button:SetDimensions(25, 25)
		NBUI.NB3Close_Button:SetDrawLayer(1)
		NBUI.NB3Close_Button:SetDrawLevel(2)
		NBUI.NB3Close_Button:SetDrawTier(0)	
		NBUI.NB3Close_Button:SetHandler("OnClicked", function(self) 
			NBUI.NB3MainWindow:SetHidden(true) 
			if SCENE_MANAGER:IsInUIMode() then
				SCENE_MANAGER:SetInUIMode(false)
			end
			DoCommand("/idle")
		end)
		NBUI.NB3Close_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, GetString(SI_NBUI_CLOSEBUTTON_TOOLTIP))
		end)
		NBUI.NB3Close_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)
		NBUI.NB3Close_Button:SetMouseOverTexture("/esoui/art/buttons/closebutton_mouseover.dds")
		NBUI.NB3Close_Button:SetNormalTexture("/esoui/art/buttons/closebutton_up.dds")
		NBUI.NB3Close_Button:SetPressedTexture("/esoui/art/buttons/closebutton_down.dds")
		
	NBUI.NB3Close_ButtonTexture = WINDOW_MANAGER:CreateControl("NBUI_NB3Close_ButtonTexture", NBUI.NB3Close_Button, CT_TEXTURE)		
		NBUI.NB3Close_ButtonTexture:SetAnchor(TOPLEFT, NBUI.NB3Close_Button, TOPLEFT, -20, -11)
		NBUI.NB3Close_ButtonTexture:SetAnchor(BOTTOMRIGHT, NBUI.NB3Close_Button, BOTTOMRIGHT, 10, 20)
		NBUI.NB3Close_ButtonTexture:SetColor(0.8, 0, 0, 0)		
		NBUI.NB3Close_ButtonTexture:SetDrawLayer(1)
		NBUI.NB3Close_ButtonTexture:SetDrawLevel(1)
		NBUI.NB3Close_ButtonTexture:SetDrawTier(0)	
		NBUI.NB3Close_ButtonTexture:SetTexture("/esoui/art/chatwindow/maximize_up.dds")--("/esoui/art/buttons/cancel_up.dds")
		NBUI.NB3Close_ButtonTexture:SetTextureRotation(4.7, .61, .32)
		NBUI.NB3Close_ButtonTexture:SetAlpha(1)
		
--***********************************************************************************************--		
--  CHAT WINDOW BUTTONS  --------------------------------------------------------------------------
	NBUI.NB3MaxChatWin_Button = WINDOW_MANAGER:CreateControl("NBUI_NB3MaxChatWin_Button", ZO_ChatWindow, CT_BUTTON)	
		NBUI.NB3MaxChatWin_Button:SetDimensions(32, 32)
		NBUI.NB3MaxChatWin_Button:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, NBUIDB.NB3_MaxOffsetChatButton, 7)
		NBUI.NB3MaxChatWin_Button:SetMouseOverTexture("/esoui/art/mainmenu/menubar_journal_down.dds")
		NBUI.NB3MaxChatWin_Button:SetHidden(not NBUIDB.NB3_ChatButton)				
		NBUI.NB3MaxChatWin_Button:SetHandler("OnClicked", function(self)
			--if button == 1 then
				NBUI.NB3KeyBindToggle()
			--elseif button == 2 then
				--DoCommand("/nb1s") 
			--end
		end)		
		NBUI.NB3MaxChatWin_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, NBUIDB.NB3_Title)
		end)
		NBUI.NB3MaxChatWin_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)
		
	NBUI.NB3MaxChatWin_ButtonTexture = WINDOW_MANAGER:CreateControl("NBUI_NB3MaxTexureChatButton", ZO_ChatWindow, CT_TEXTURE)		
		NBUI.NB3MaxChatWin_ButtonTexture:SetAnchorFill(NBUI.NB3MaxChatWin_Button)
		NBUI.NB3MaxChatWin_ButtonTexture:SetColor(unpack(NBUIDB.NB3_BookColor))
		NBUI.NB3MaxChatWin_ButtonTexture:SetDrawTier(DT_HIGH)
		NBUI.NB3MaxChatWin_ButtonTexture:SetHidden(not NBUIDB.NB3_ChatButton)
		NBUI.NB3MaxChatWin_ButtonTexture:SetTexture("/esoui/art/mainmenu/menubar_journal_up.dds")
---------------------------------------------------------------------------------------------------
	NBUI.NB3MinChatWin_Button = WINDOW_MANAGER:CreateControl("NBUI_NB3MinChatWin_Button", ZO_ChatWindowMinBar, CT_BUTTON)
		NBUI.NB3MinChatWin_Button:SetDimensions(32, 32)
		NBUI.NB3MinChatWin_Button:SetAnchor(BOTTOMLEFT, ZO_ChatWindowMinBar, BOTTOMLEFT, -3, NBUIDB.NB3_MinOffsetChatButton)
		NBUI.NB3MinChatWin_Button:SetMouseOverTexture("/esoui/art/mainmenu/menubar_journal_down.dds")
		NBUI.NB3MinChatWin_Button:SetHidden(not NBUIDB.NB3_ChatButton)
		NBUI.NB3MinChatWin_Button:SetHandler("OnClicked", function(self)
			NBUI.NB3KeyBindToggle()
		end)		
		NBUI.NB3MinChatWin_Button:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, NBUIDB.NB3_Title)
		end)
		NBUI.NB3MinChatWin_Button:SetHandler("OnMouseExit", function(self)
			ClearTooltip(InformationTooltip)
		end)

	NBUI.NB3MinChatWin_ButtonTexture = WINDOW_MANAGER:CreateControl("NBUI_NB3MinTexureChatButton", ZO_ChatWindowMinBar, CT_TEXTURE)		
		NBUI.NB3MinChatWin_ButtonTexture:SetAnchorFill(NBUI.NB3MinChatWin_Button)
		NBUI.NB3MinChatWin_ButtonTexture:SetColor(unpack(NBUIDB.NB3_BookColor))
		NBUI.NB3MinChatWin_ButtonTexture:SetDrawTier(DT_HIGH)
		NBUI.NB3MinChatWin_ButtonTexture:SetHidden(not NBUIDB.NB3_ChatButton)
		NBUI.NB3MinChatWin_ButtonTexture:SetTexture("/esoui/art/mainmenu/menubar_journal_up.dds")		
end
---------------------------------------------------------------------------------------------------
-- new page function
function NBUI.NB3NewPage(self)		
	currentlyViewing = nil
	NBUI.NB3RightPage_Title:SetText("New Page "..#NBUIDB.NB3Pages+1)
	--NBUI.NB3RightPage_Title:SelectAll()
	--NBUI.NB3RightPage_Title:TakeFocus()
	NBUI.NB3RightPage_Contents:Clear()
	NBUI.NB3SavePage(self)
	
	NBUI.NB3UndoPage_Button:SetHidden(true)
end	
NB3ConfirmNewDialog = {
	title={ text = GetString(SI_NBUI_NEWBUTTON_TITLE)},
	mainText={ text = GetString(SI_NBUI_NEWBUTTON_MAINTEXT)},
	buttons = {
		[1]={ 
			text = GetString(SI_NBUI_YES_LABEL), callback = function(self)
				NBUI.NB3NewPage(self)
				zo_callLater(function() SetGameCameraUIMode(true) end, 10)
			end
			},
		[2]={ text = GetString(SI_NBUI_NO_LABEL)}
	}
}
ZO_Dialogs_RegisterCustomDialog("NBUI_NB3CONFIRM_NEWPAGE", NB3ConfirmNewDialog)
---------------------------------------------------------------------------------------------------
-- save page function
function NBUI.NB3SavePage(self) 		
	local titleText = NBUI.NB3RightPage_Title:GetText()
		if titleText == "" then
			NBUI.NB3RightPage_Title:SetText("New Page "..#NBUIDB.NB3Pages+1)
			titleText = NBUI.NB3RightPage_Title:GetText()
		end
	local pageText = NBUI.NB3RightPage_Contents:GetText()
	local safe_titleText = ProtectText(titleText)	
	local safe_pageText = ProtectText(pageText)
		if currentlyViewing == nil then	--if this was a new page
			table.insert(NBUIDB.NB3Pages, {["title"] = safe_titleText, ["text"]=safe_pageText})
			currentlyViewing = #NBUIDB.NB3Pages
			NBUI.NB3SelectedPage_Button:SetHidden(false)
			NBUI.NB3SelectedPage_Button:ClearAnchors()
			self.new = true
		else
			NBUIDB.NB3Pages[currentlyViewing].title = safe_titleText
			NBUIDB.NB3Pages[currentlyViewing].text = safe_pageText
			self.new = false
		end
		
	Populate_NB3_ScrollList()
		if self.new then
			NBUI.NB3SelectedPage_Button:SetAnchorFill(_G["NBUI_Index"..currentlyViewing])
		end
	
	NBUI.NB3SavePage_Button:SetHidden(true)
	NBUI.NB3UndoPage_Button:SetHidden(true)
end
NB3ConfirmSaveDialog = {
	title = { text = GetString(SI_NBUI_SAVEBUTTON_TITLE)},
	mainText = { text = GetString(SI_NBUI_SAVEBUTTON_MAINTEXT)},
	buttons = {
		[1]={ 
			text = GetString(SI_NBUI_YES_LABEL), callback = function(self)
				NBUI.NB3SavePage(self)
				zo_callLater(function() SetGameCameraUIMode(true) end, 10)
			end
			},
		[2]={ text = GetString(SI_NBUI_NO_LABEL)}
	}
}
ZO_Dialogs_RegisterCustomDialog("NBUI_NB3CONFIRM_SAVE", NB3ConfirmSaveDialog)
---------------------------------------------------------------------------------------------------
-- undo page function
function NBUI.NB3UndoPage() 		
	if currentlyViewing then
		NBUI.NB3RightPage_Title:SetText(NBUIDB.NB3Pages[currentlyViewing].title)
		NBUI.NB3RightPage_Contents:SetText(NBUIDB.NB3Pages[currentlyViewing].text)
	end
	
	NBUI.NB3SavePage_Button:SetHidden(true)
	NBUI.NB3UndoPage_Button:SetHidden(true)
end
NB3ConfirmUndoDialog = {
	title = { text = GetString(SI_NBUI_UNDOPAGE_TITLE)},
	mainText = { text = GetString(SI_NBUI_UNDOPAGE_MAINTEXT)},
	buttons = {
		[1]={ 
			text = GetString(SI_NBUI_YES_LABEL), callback = function()
				NBUI.NB3UndoPage()
				zo_callLater(function() SetGameCameraUIMode(true) end, 10)
			end
			},
		[2]={ text = GetString(SI_NBUI_NO_LABEL)}
	}
}
ZO_Dialogs_RegisterCustomDialog("NBUI_NB3CONFIRM_UNDO", NB3ConfirmUndoDialog)
---------------------------------------------------------------------------------------------------
-- delete page function
function NBUI.NB3DeletePage()
	if currentlyViewing then
		table.remove(NBUIDB.NB3Pages, currentlyViewing)
		currentlyViewing = nil
		Populate_NB3_ScrollList()
		NBUI.NB3SelectedPage_Button:SetHidden(true)
	end

	NBUI.NB3RightPage_Title:Clear()
	NBUI.NB3RightPage_Contents:Clear()
		
	NBUI.NB3DeletePage_Button:SetHidden(true)
	NBUI.NB3SavePage_Button:SetHidden(true)				
	NBUI.NB3UndoPage_Button:SetHidden(true)
	NBUI.NB3RunScript_Button:SetHidden(true)
end
NB3ConfirmDeleteDialog = {
	title = {text = GetString(SI_NBUI_DELETEBUTTON_TITLE)},
	mainText = {text = GetString(SI_NBUI_DELETEBUTTON_MAINTEXT)},
	buttons = {
		[1]={
			text = GetString(SI_NBUI_YES_LABEL), callback = function()
				NBUI.NB3DeletePage()
				zo_callLater(function() SetGameCameraUIMode(true) end, 10)
			end
			},
		[2]={text = GetString(SI_NBUI_NO_LABEL)}
	}
}
ZO_Dialogs_RegisterCustomDialog("NBUI_NB3CONFIRM_DELETE", NB3ConfirmDeleteDialog)
---------------------------------------------------------------------------------------------------
function NBUI.NB3KeyBindToggle()
	if NBUI.NB3MainWindow:IsHidden() then
		NBUI.NB3MainWindow:SetHidden(false)
		NBUI.NB3MainWindow:BringWindowToTop(true)
		if not SCENE_MANAGER:IsInUIMode() then
			SCENE_MANAGER:SetInUIMode(true)
		end
		DoCommand("/read")
		PlaySound(SOUNDS.BOOK_OPEN)
	else
		NBUI.NB3MainWindow:SetHidden(true)
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
SLASH_COMMANDS["/nb3"] = NBUI.NB3KeyBindToggle