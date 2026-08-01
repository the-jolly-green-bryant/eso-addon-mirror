local HarvensBookCopy = {}

function HarvensBookCopy:CopyToClipboard()
	if self.bookBody then
		if self.copyIteration > 0 then
			HarvensBookCopyClipboard:SetText(string.sub(self.bookBody, 1023*self.copyIteration, (self.copyIteration + 1)*1023))
		else
			HarvensBookCopyClipboard:SetText(string.sub(self.bookBody, 1, 1022))
		end
		HarvensBookCopyClipboard:CopyAllTextToClipboard()
		if self.numIterations > 1 then
			self.copyIteration = self.copyIteration + 1
			CHAT_SYSTEM:AddMessage("Part "..self.copyIteration.."/"..self.numIterations.." of the book copied to clipboard, press 'X' again to copy next part")
			if self.copyIteration >= self.numIterations then
				self.copyIteration = 0
			end
		else
			CHAT_SYSTEM:AddMessage("Book content copied to system clipboard.")
		end
	end
end

local function HarvensBookCopy_CopyToClipboard()
	HarvensBookCopy:CopyToClipboard()
end

function HarvensBookCopy:InjectKeystrip()
	if LORE_READER.PCKeybindStripDescriptor then
		table.insert(LORE_READER.PCKeybindStripDescriptor, { name = "Copy to Clipboard", keybind = "UI_SHORTCUT_NEGATIVE", callback = HarvensBookCopy_CopyToClipboard, alignment = KEYBIND_STRIP_ALIGN_CENTER})
	end
end

function HarvensBookCopy:ShowBook(bookTitle, body, medium, ...)
	if self.bookTitle and self.bookTitle == bookTitle then return end
	
	self.bookTitle = bookTitle
	self.bookBody = body
	self.copyIteration = 0
	self.numIterations = math.ceil(#self.bookBody/1023)
end

function HarvensBookCopy:SetupBook(loreReader, title, body, ...)
	if self.bookTitle and self.bookTitle == title then return self.loreReaderSetupBook(loreReader, title, body, ...) end
	self.bookTitle = title
	self.bookBody = body
	self.copyIteration = 0
	self.numIterations = math.ceil(#self.bookBody/1023)
	return self.loreReaderSetupBook(loreReader, title, body, ...)
end

local function HarvensBookCopy_SetupBook(...)
	return HarvensBookCopy:SetupBook(...)
end

function HarvensBookCopy:Initialize()
	self.loreReaderSetupBook = LORE_READER.SetupBook
	LORE_READER.SetupBook = HarvensBookCopy_SetupBook
	
	self:InjectKeystrip()
	HarvensBookCopyClipboard:SetCopyEnabled(true)
	HarvensBookCopyClipboard:SetMaxInputChars(10000)
end

local function HarvensBookCopy_ShowBook(eventType, ...)
	HarvensBookCopy:ShowBook(...)
end

local function HarvensBookCopy_AddOnLoaded(code, name)
	if name ~= "HarvensBookCopy" then return end
	
	HarvensBookCopy:Initialize()
end

EVENT_MANAGER:RegisterForEvent("HarvensBookCopyAddOnLoaded", EVENT_ADD_ON_LOADED, HarvensBookCopy_AddOnLoaded)
EVENT_MANAGER:RegisterForEvent("HarvensBookCopyShowBook", EVENT_SHOW_BOOK, HarvensBookCopy_ShowBook)