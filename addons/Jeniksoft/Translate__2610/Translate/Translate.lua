Translate={}
Translate.name = "Translate"
Translate.conversationText = {}
Translate.countTexts = 0
Translate.actualText = 0
Translate.language = GetCVar("language.2")
Translate.activated = false

local chunkLength = 5000
  
-- Show Control
local function showControl(control)
	control:SetHidden(false)
end

-- Hide Control
local function hideControl(control)
	control:SetHidden(true)
end

local function getBreakIndex(chunkReversed, pattern)
	local startIndex = string.find(chunkReversed, "[%.%?!]")
	local maxIndex = 0
	if startIndex then maxIndex = startIndex end
	return maxIndex
end

local function showData()
	local count = Translate.countTexts - Translate.actualText
	MessagesQueue:SetText(GetString(SI_TRANSLATE_JENIKSOFT_MESSAGE_QUEUE)..count)
	TextBuffer:SetText(Translate.conversationText[Translate.actualText + 1])
end

local function PostMessage(text)
	if not text then return end
	
	local stringLength = string.len(text)
	text = string.gsub(text, "%s", " ")
	text = string.gsub(text, '%"', "'")
	if (chunkLength < stringLength + 1) then
		local startChunk = 1
		local endChunk = chunkLength 
		while startChunk < stringLength + 1 do 
			Translate.countTexts = Translate.countTexts +  1
			local chunkMessage = string.sub(text, startChunk, endChunk)
			local chunkReversed = string.reverse(chunkMessage)
			local breakIndex =getBreakIndex(chunkReversed,"[%.%?!]")
			if breakIndex > 0 then
				endChunk = endChunk - breakIndex + 1
			else 
				breakIndex =getBreakIndex(chunkReversed,",")
				if breakIndex > 0 then
					endChunk = endChunk - breakIndex + 1 
				else
					breakIndex =getBreakIndex(chunkReversed," ")
					if breakIndex > 0 then
						endChunk = endChunk - breakIndex + 1
					end
				end
			end	
			Translate.conversationText[Translate.countTexts] = string.sub(text, startChunk, endChunk)
			startChunk = endChunk + 1
			endChunk = math.min(endChunk + chunkLength, stringLength + 1)
		end
	else
		Translate.countTexts = Translate.countTexts +  1
		Translate.conversationText[Translate.countTexts] = text
	end
	showData()
	Translate.ShowDialog()
end

-- Open Language Code Page
function Translate.OpenLanguageCodePage()
	RequestOpenUnsafeURL('https://sites.google.com/site/opti365/translate_codes')
end

-- Translate Request
function Translate.Translate()
	if Translate.countTexts > 0 then
		local url = string.format('https://translate.google.com/?sl=auto&tl=%s&text=%s', EditLanguage:GetText(), Translate.conversationText[Translate.actualText + 1])
		RequestOpenUnsafeURL(url)
		Translate.actualText = Translate.actualText + 1
		if Translate.actualText >= Translate.countTexts then
			Translate.HideDialog()
		else
			showData()
		end
	end
end

-- Skip Message
function Translate.Skip()
	if Translate.countTexts > 0 then
		Translate.actualText = Translate.actualText + 1
		if Translate.actualText >= Translate.countTexts then
			Translate.HideDialog()
		else
			showData()
		end
	end
end

-- Dialog Move Stop
function Translate.OnIndicatorMoveStopTranslate()
	Translate.savedVariables.chatterLeft = TranslateDlg:GetLeft()
	Translate.savedVariables.chatterTop = TranslateDlg:GetTop()
end

-- Dialog Move Stop
function Translate.OnIndicatorMoveStopMinimalized()
	Translate.savedVariables.chatterLeft = MinimalizedDlg:GetLeft()
	Translate.savedVariables.chatterTop = MinimalizedDlg:GetTop()
end

-- Restore Position
function Translate.RestorePosition()
	local left  = Translate.savedVariables.chatterLeft
	local top = Translate.savedVariables.chatterTop
	local code = Translate.savedVariables.languageCode
	local activated = Translate.savedVariables.activated
 
	Translate.activated = activated
	TranslateDlg:ClearAnchors()
	TranslateDlg:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	MinimalizedDlg:ClearAnchors()
	MinimalizedDlg:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	EditLanguage:SetText(code)
end

-- Dialog Save Language Code
function Translate.SaveLanguageCode()
  Translate.savedVariables.languageCode = EditLanguage:GetText()
end

-- Initialize
function Translate.Initialize()
	EVENT_MANAGER:RegisterForEvent(Translate.name, EVENT_SHOW_BOOK, Translate.OnShowBook)
	EVENT_MANAGER:RegisterForEvent(Translate.name, EVENT_HIDE_BOOK , Translate.OnHideBook)
	
	EVENT_MANAGER:RegisterForEvent(Translate.name, EVENT_CHATTER_BEGIN, Translate.OnConversationBegin)
	EVENT_MANAGER:RegisterForEvent(Translate.name, EVENT_CHATTER_END, Translate.OnConversationEnd)
	EVENT_MANAGER:RegisterForEvent(Translate.name, EVENT_SHOW_SUBTITLE , Translate.OnShowSubtitle)
	EVENT_MANAGER:RegisterForEvent(Translate.name, EVENT_CONVERSATION_UPDATED, Translate.OnConversationUpdated)
	EVENT_MANAGER:RegisterForEvent(Translate.name, EVENT_NO_INTERACT_TARGET, Translate.OnNoInteract)
	EVENT_MANAGER:RegisterForEvent(Translate.name, EVENT_CONFIRM_INTERACT, Translate.OnConfirmInteract)
	EVENT_MANAGER:RegisterForEvent(Translate.name, EVENT_QUEST_COMPLETE_DIALOG, Translate.OnQuestCompleteDialog) 
	EVENT_MANAGER:RegisterForEvent(Translate.name, EVENT_QUEST_SHOW_JOURNAL_ENTRY, Translate.OnQuestJournalEntry)
	EVENT_MANAGER:RegisterForEvent(Translate.name, EVENT_QUEST_OFFERED, Translate.OnQuestOffered)	
	EVENT_MANAGER:RegisterForEvent(Translate.name, EVENT_QUEST_SHARED, Translate.OnQuestShared)	 
	
	TranslateDlg_WindowTitle:SetText(GetString(SI_TRANSLATE_JENIKSOFT_TRANSLATION))
	ActualMessage:SetText(GetString(SI_TRANSLATE_JENIKSOFT_ACTUAL_MESSAGE))
	OpenTextLanguageCode:SetText(GetString(SI_TRANSLATE_JENIKSOFT_OPEN_LANGUAGE_CODE_PAGE))
	TextLanguageCode:SetText(GetString(SI_TRANSLATE_JENIKSOFT_LANGUAGE_CODE))
	
	MinimalizedDlg_WindowTitle:SetText(GetString(SI_TRANSLATE_JENIKSOFT_TRANSLATION))
	MaximalizedText:SetText(GetString(SI_TRANSLATE_JENIKSOFT_MAXIMALIZE))
	
	Translate.savedVariables = ZO_SavedVars:New("TranslateAddonSavedVariables", 1, nil, { chatterLeft = 50, chatterTop = 100, languageCode = "cs", activated = false })
	Translate.RestorePosition()
end

function Translate.OnQuestOffered(eventCode)
	local dialogue, response = GetOfferedQuestInfo()
	PostMessage(dialogue.." "..GetString(SI_TRANSLATE_JENIKSOFT_ANSWER)..": "..response)
end

function Translate.OnQuestShared(eventCode, questId)
	local questName, characterName, millisecondsSinceRequest, displayName = GetOfferedQuestShareInfo(questId)
	PostMessage(GetString(SI_TRANSLATE_JENIKSOFT_QUEST).." "..questName.." "..displayName)
end

-- Show Quest Complete Dialog
function Translate.OnQuestCompleteDialog(eventCode, journalIndex)
	local goal, dialog, confirmComplete, declineComplete, backgroundText, journalStepText = GetJournalQuestEnding(journalIndex)
		
	PostMessage(GetString(SI_TRANSLATE_JENIKSOFT_QUEST).." "..dialog)
end

-- Show Journal Entry
function Translate.OnQuestJournalEntry(eventCode, journalIndex)
	d("Show Journal Entry")
	local questName, backgroundText, activeStepText, _, activeStepTrackerOverrideText, completed, _, _, _, _, _ = GetJournalQuestInfo(journalIndex)
	if not questName and not backgroundText and not activeStepText and not activeStepTrackerOverrideText then return end
	
	PostMessage(GetString(SI_TRANSLATE_JENIKSOFT_QUEST).." "..questName.."... "..GetString(SI_TRANSLATE_JENIKSOFT_BACKGROUND_TEXT).." "..backgroundText.."... "..GetString(SI_TRANSLATE_JENIKSOFT_ACTIVE_STEP_TEXT).." "..			activeStepText.."... "..GetString(SI_TRANSLATE_JENIKSOFT_ACTIVE_STEP_TRACKER_OVERRIDE_TEXT).." "..activeStepTrackerOverrideText)
	d("Show Journal Entry")
end

-- Show Book
function Translate.OnShowBook(eventCode, bookTitle, body, medium, showTitle, bookId)
	PostMessage(bookTitle.."\n\n"..body)
end

-- Hide Book
function Translate.OnHideBook(eventCode)
	Translate.HideDialog()
end

-- Get Importent String
local function GetIsImportant(isImportant)
	if isImportant then
		return GetString(SI_TRANSLATE_JENIKSOFT_IS_IMPORTANT)
	else
		return ""
	end
end

-- Get Answers
local function GetAnswers(optionCount)
	if not optionCount then return end
	
	local answersText = ""
	for i = 1, optionCount, 1 do
		local optionString, optionType, optionalArgument, isImportant, chosenBefore = GetChatterOption(i)
		answersText = answersText.." "..GetString(SI_TRANSLATE_JENIKSOFT_ANSWER).." "..i..": "..GetIsImportant(isImportant)..optionString.."\n"
	end
	return answersText
end

-- Minimalize to MinimalizedDialog
function Translate.Minimalize()
	Translate.activated = false
	hideControl(TranslateDlg)
	showControl(MinimalizedDlg)
	
	Translate.savedVariables.activated = Translate.activated
	MinimalizedDlg:ClearAnchors()
	MinimalizedDlg:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TranslateDlg:GetLeft(), TranslateDlg:GetTop())
end

-- Maximalize to TranslateDialog
function Translate.Maximalize()
	Translate.activated = true
	hideControl(MinimalizedDlg)
	showControl(TranslateDlg)
	
	Translate.savedVariables.activated = Translate.activated
	TranslateDlg:ClearAnchors()
	TranslateDlg:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MinimalizedDlg:GetLeft(), MinimalizedDlg:GetTop())
end

-- Show Dialog
function Translate.ShowDialog()
	if Translate.activated then
		Translate.RestorePosition()
		showControl(TranslateDlg)
	else
		showControl(MinimalizedDlg)
	end
end

-- Hide Dialog
function Translate.HideDialog()
	if Translate.activated then Translate.OnIndicatorMoveStopTranslate() else Translate.OnIndicatorMoveStopMinimalized() end
	hideControl(TranslateDlg)
	hideControl(MinimalizedDlg) 
	Translate.actualText = 0
	Translate.countTexts = 0
	Translate.conversationText = {}
end

-- Conversation Begin
function Translate.OnConversationBegin(eventCode, optionCount)
	Translate.Maximalize()
	local answer = GetAnswers(optionCount)
	if answer then
		PostMessage(GetChatterGreeting().."\n\n"..answer)
	else
		PostMessage(GetChatterGreeting())
	end
end

-- Conversation End
function Translate.OnConversationEnd(eventCode)
	Translate.HideDialog()
end

-- Conversation Updated
function Translate.OnConversationUpdated(eventCode, conversationBodyText, optionCount)
	local answer = GetAnswers(optionCount)
	if answer then
		PostMessage(conversationBodyText.."\n\n"..answer)
	else
		PostMessage(conversationBodyText)
	end
end

-- Confirm Interact
function Translate.OnConfirmInteract(eventCode, dialogTitle, dialogBody, acceptText, cancelText)
	PostMessage(dialogTitle.."\n"..dialogBody)
end

-- Show Subtitle
function Translate.OnShowSubtitle(eventCode, channelType, speakerName, text)
	Translate.Minimalize()
	speakerName = string.sub(speakerName, 1, string.len(speakerName) - 2)
	PostMessage(speakerName..": "..text)
end

-- No Interact
function Translate.OnNoInteract(eventCode)
	hideControl(TranslateDlg)
	d("No Interact")
end

-----------------------------------------------------------------------------------------------------------
-- Addon Loaded
function Translate.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads - but we only care about when our own addon loads.
	if addonName ~= Translate.name then return end
		
	Translate.Initialize()
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(Translate.name, EVENT_ADD_ON_LOADED, Translate.OnAddOnLoaded)