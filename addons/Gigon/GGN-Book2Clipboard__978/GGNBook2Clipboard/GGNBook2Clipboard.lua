GGNBook2Clipboard={}

local ClipBoardControl = nil
local Window = nil
local CurStartBookPos=0
local buffer=nil
local AddText="--Press Ctrl+c--\n"
local AddTextToEnd="          "
local CurTextBlock=""
local bUpdateText=false
local CharsInEditbox=1010



------------------------------------------------------------------
--GetPages
------------------------------------------------------------------
function GGNBook2Clipboard:GetNextPage()
	AddTextLen=string.len(AddText)
	BufferBlockLen=CharsInEditbox-AddTextLen-string.len(AddTextToEnd)

	BufLen=string.len(buffer)
	
	if CurStartBookPos==0 then
		NextStartBookPos=1
	else
		local count = string.len(CurTextBlock)-AddTextLen-string.len(AddTextToEnd)
		NextStartBookPos=CurStartBookPos+count
		if NextStartBookPos>BufLen then			
			return
		end
	end
		
	EndPos=math.min(NextStartBookPos+BufferBlockLen-1,BufLen)
	if EndPos<BufLen then 
		DotPos=0
		for i=EndPos,NextStartBookPos,-1 do
			CurChar=string.sub(buffer,i,i)
			if CurChar=="." then 
				DotPos=i
				break
			end				
		end
		if DotPos>0 then
			EndPos=DotPos
		end			
	end	
	CurTextBlock=AddText..string.sub(buffer, NextStartBookPos, EndPos)..AddTextToEnd	
	CurStartBookPos=NextStartBookPos	

end

------------------------------------------------------------------
function GGNBook2Clipboard:GetPrevPage()
	AddTextLen=string.len(AddText)
	BufferBlockLen=CharsInEditbox-AddTextLen-string.len(AddTextToEnd)

	BufLen=string.len(buffer)
	
	--local count = string.len(CurTextBlock)-AddTextLen-string.len(AddTextToEnd)
	EndPos=CurStartBookPos-1	
	
	if EndPos<=0 then		
		return
	else	
		NextStartBookPos=math.max(CurStartBookPos-BufferBlockLen,0)
		if NextStartBookPos>1 then 
			DotPos=0
			for i=NextStartBookPos,EndPos,1 do
				CurChar=string.sub(buffer,i,i)
				if CurChar=="." then 
					DotPos=i
					break
				end				
			end
			if DotPos>0 then
				NextStartBookPos=DotPos+1
			end			
		end
		CurTextBlock=AddText..string.sub(buffer, NextStartBookPos, EndPos)..AddTextToEnd
	end

	CurStartBookPos=NextStartBookPos	
end

------------------------------------------------------------------
function GGNBook2Clipboard:GetFirstPage()
	CurStartBookPos=0
	GGNBook2Clipboard:GetNextPage()
end


------------------------------------------------------------------
--Control pages and window
------------------------------------------------------------------
function GGNBook2Clipboard:ShowPage()
	bUpdateText=true	
end
	
------------------------------------------------------------------
function GGNBook2Clipboard:HideWindow()
	Window:SetHidden(true)
end

------------------------------------------------------------------
function GGNBook2Clipboard:ShowWindow()
	Window:SetHidden(false)
end

------------------------------------------------------------------
--Manage data
------------------------------------------------------------------
function GGNBook2Clipboard:PrepareText(title, body)	
	--if body==nil then return self.loreReaderShow(arg1, title, body, ...) end
	CurStartBookPos=0
	CurTextBlock=""
	bUpdateText=false	
	buffer=title.."\n"..body		
end

------------------------------------------------------------------
function GGNBook2Clipboard:SetupBook(arg1, title, body,...)	
	
	GGNBook2Clipboard:PrepareText(title, body)		
	return self.loreSetupBook(arg1, title, body, ...)
end

------------------------------------------------------------------
function GGNBook2Clipboard:LoreOnHide(...)
	GGNBook2Clipboard:HideWindow()
	return self.loreReaderOnHide(...)
end	

------------------------------------------------------------------
function GGNBook2Clipboard:LibrarianReadBook(...)
	retval= self.librarianReadBook(...)
	GGNBook2Clipboard:GetFirstPage()		
	GGNBook2Clipboard:ShowWindow()
	GGNBook2Clipboard:ShowPage()
	return retval	
end
------------------------------------------------------------------
function GGNBook2Clipboard:SelectAllText()
	local text = ClipBoardControl:GetText()
	local count = string.len(text)
	ClipBoardControl:SetSelection(0, count-string.len(AddTextToEnd))	
	
end


------------------------------------------------------------------
--Events
------------------------------------------------------------------
local function GGNBook2Clipboard_ShowBook(eventType,bookTitle, body, medium, showTitle)	
	GGNBook2Clipboard:GetFirstPage()		
	GGNBook2Clipboard:ShowWindow()
	GGNBook2Clipboard:ShowPage()
	
end

------------------------------------------------------------------
local function GGNBook2Clipboard_OnKeyboardKeyShow()
	GGNBook2Clipboard:GetFirstPage()		
	GGNBook2Clipboard:ShowWindow()
	GGNBook2Clipboard:ShowPage()
end

--------------------------------------------------------------------------------
local function GGNBook2Clipboard_SetupBook(...)	
	GGNBook2Clipboard:SetupBook(...)
end

--------------------------------------------------------------------------------	
local function GGNBook2Clipboard_OnHide(...)
	return GGNBook2Clipboard:LoreOnHide(...)
end
	
--------------------------------------------------------------------------------
local function GGNBook2Clipboard_LibrarianReadBook(...)
	return GGNBook2Clipboard:LibrarianReadBook(...)
end
	
--------------------------------------------------------------------------------
local function GGNBook2Clipboard_HideBook(eventType)
	GGNBook2Clipboard:HideWindow()
	
end

------------------------------------------------------------------
local function GGNBook2Clipboard_OnUpdate()
	if bUpdateText then
		ClipBoardControl:SetText(CurTextBlock)
		bUpdateText=false
		GGNBook2Clipboard:SelectAllText()		
		ClipBoardControl:TakeFocus()
	end		
end

------------------------------------------------------------------
local function GGNBook2Clipboard_OnMouseWheel(control,delta)
	if delta==1 then
		GGNBook2Clipboard:GetPrevPage()
		GGNBook2Clipboard:ShowPage()
	else
		GGNBook2Clipboard:GetNextPage()
		GGNBook2Clipboard:ShowPage()		
	end
end
		
------------------------------------------------------------------
local function GGNBook2Clipboard_OnFocusGained()
	GGNBook2Clipboard:SelectAllText()
end
	
------------------------------------------------------------------
--init
------------------------------------------------------------------
function GGNBook2Clipboard:CreateClipBoardControl()
	Window = GGNBook2ClipboardControl -- api v100010 made the CopyAllTextToClipboard method private so we can only show a textbox, select everything and let the user press ctrl+c manually now
	ClipBoardControl = GGNBook2ClipboardControlOutputBox
	ClipBoardControl:SetMaxInputChars(CharsInEditbox*3)	
	ClipBoardControl:SetFont("GGNBook2Clipboard\\fonts\\univers55.otf|20")
	

	
	--ClipBoardControl.SetHeight(20);
	
	ClipBoardControl:SetHandler("OnFocusGained", GGNBook2Clipboard_OnFocusGained)
	
	Window:SetHandler("OnUpdate",  GGNBook2Clipboard_OnUpdate)
	ClipBoardControl:SetHandler("OnMouseWheel",  GGNBook2Clipboard_OnMouseWheel)
	
end

------------------------------------------------------------------
function GGNBook2Clipboard:InjectKeystrip()
	--if LORE_READER.PCKeybindStripDescriptor then
	--	table.insert(LORE_READER.PCKeybindStripDescriptor, { name = "Show text", keybind = "UI_SHORTCUT_NEGATIVE", callback = GGNBook2Clipboard_OnKeyboardKeyShow, alignment = KEYBIND_STRIP_ALIGN_CENTER})
	--end
end

------------------------------------------------------------------
function GGNBook2Clipboard:Initialize()
	self.loreSetupBook = LORE_READER.SetupBook
	LORE_READER.SetupBook = GGNBook2Clipboard_SetupBook
	
	self.loreReaderOnHide = LORE_READER.OnHide
	LORE_READER.OnHide = GGNBook2Clipboard_OnHide	
	
	if Librarian~=nil then
		self.librarianReadBook = Librarian.ReadBook
		Librarian.ReadBook = GGNBook2Clipboard_LibrarianReadBook	
	end
	
	GGNBook2Clipboard:CreateClipBoardControl()
	
	self:InjectKeystrip()
	--self.Font="GGNBook2Clipboard\\fonts\\univers55.otf|20"
	
end

------------------------------------------------------------------
local function GGNBook2Clipboard_init(code, name)
	if name ~= "GGNBook2Clipboard" then return end
	GGNBook2Clipboard:Initialize()
end

--------------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent("GGNBook2ClipboardAddOnLoaded", EVENT_ADD_ON_LOADED, GGNBook2Clipboard_init)
EVENT_MANAGER:RegisterForEvent("GGNBook2ClipboardShowBook", EVENT_SHOW_BOOK, GGNBook2Clipboard_ShowBook)
--EVENT_MANAGER:RegisterForEvent("GGNBook2ClipboardHideBook", EVENT_HIDE_BOOK, GGNBook2Clipboard_HideBook)

--------------------------------------------------------------------------------
