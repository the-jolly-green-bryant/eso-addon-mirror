local clipBoardControl = nil
local window = nil
local buffer=""

--------------------------------------------------------------------------------
local function CreateClipBoardControl()
	window = GGNDialog2ClipboardControl -- api v100010 made the CopyAllTextToClipboard method private so we can only show a textbox, select everything and let the user press ctrl+c manually now
	clipBoardControl = GGNDialog2ClipboardControlOutputBox
	clipBoardControl:SetMaxInputChars(10000)	
	clipBoardControl:SetHandler("OnFocusLost", function()
		window:SetHidden(true)
	end)
end

--------------------------------------------------------------------------------
local function openTextBox()
	clipBoardControl:SetText(buffer)
	
	local text = clipBoardControl:GetText()
	local count = #text
	clipBoardControl:SetSelection(0, count-10)

	window:SetHidden(false)
	clipBoardControl:TakeFocus()	
end
--------------------------------------------------------------------------------
local function kl_GGNDialog2Clipboard_copy(text)
	buffer="--Press Ctrl+c--\n"..text.."          "
	openTextBox()
end

--------------------------------------------------------------------------------
local function GGNDialog2Clipboard_onBegin(something, optionCount)		
	local ChatterGreeting=GetChatterGreeting()
	local text = ChatterGreeting .. "\n\n"	
	for i=1,optionCount do
		text = text .. " ["..i.." - " ..GetChatterOption(i) .. "]\n"
	end
	kl_GGNDialog2Clipboard_copy(text)	
	--for lip animations
	INTERACTION:InitializeInteractWindow(ChatterGreeting)
	INTERACTION:UpdateChatterOptions(optionCount, HIDE_BACK_TO_TOC_OPTION)
	--for lip animations
end

--------------------------------------------------------------------------------
local function GGNDialog2Clipboard_onEnd()
	window:SetHidden(true)
end

--------------------------------------------------------------------------------
local function empty(something, cnt)		
	local text = GetChatterData()	
end
--------------------------------------------------------------------------------
local function GGNDialog2Clipboard_onUpdate(something, text, cnt)	
	local text = text .. "\n\n"	
	for i=1,cnt do
		text = text .. " ["..i.." - " ..GetChatterOption(i) .. "]\n"
	end

	kl_GGNDialog2Clipboard_copy(text)
end

--------------------------------------------------------------------------------
local function GGNDialog2Clipboard_onQuestOffered(something)	
	local textNPC,textMe = GetOfferedQuestInfo()
	local text=textNPC .. "\n\n"  ..textMe

	kl_GGNDialog2Clipboard_copy(text)
end

--------------------------------------------------------------------------------
local function GGNDialog2Clipboard_onQuestComplete(something, journalIndex)	
	local goal,dialog = GetJournalQuestEnding(journalIndex)		
	local text=dialog
	kl_GGNDialog2Clipboard_copy(text)
end


--------------------------------------------------------------------------------
local function GGNDialog2Clipboard_init()
	CreateClipBoardControl()
end

--------------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent("kl_GGNDialog2ClipboardAddOnLoaded", EVENT_ADD_ON_LOADED, GGNDialog2Clipboard_init)
EVENT_MANAGER:RegisterForEvent("kl_GGNDialog2ClipboardChatterBegin", EVENT_CHATTER_BEGIN, GGNDialog2Clipboard_onBegin)
EVENT_MANAGER:RegisterForEvent("kl_GGNDialog2ClipboardChatterEnd", EVENT_CHATTER_END, GGNDialog2Clipboard_onEnd)
EVENT_MANAGER:RegisterForEvent("kl_GGNDialog2ClipboardConvUpdate",	EVENT_CONVERSATION_UPDATED, GGNDialog2Clipboard_onUpdate)

EVENT_MANAGER:RegisterForEvent("kl_GGNDialog2ClipboardQuestOffered", EVENT_QUEST_OFFERED, GGNDialog2Clipboard_onQuestOffered)
EVENT_MANAGER:RegisterForEvent("kl_GGNDialog2ClipboardQuestComplete", EVENT_QUEST_COMPLETE_DIALOG, GGNDialog2Clipboard_onQuestComplete)

ZO_InteractWindow:UnregisterForEvent(EVENT_CHATTER_BEGIN) --for lip animations
--------------------------------------------------------------------------------
