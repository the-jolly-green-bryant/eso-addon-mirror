LibAkaUtils = LibAkaUtils or {}
LibAkaUtils.chatSuggestions = {}
LibAkaUtils.chatSuggestionsBG = {}
LibAkaUtils.chatSuggestionsData = {}

LibAkaUtils.listeningAF = false
LibAkaUtils.lastMessage = ""
LibAkaUtils.lastCtrl = 0
LibAkaUtils.ctrldwn = false

local NUM_SUGGESTION = 5
local DELTA_TIME_CTRL_S = 1

function LibAkaUtils.HandleAF(message)
	if message == "" then 
		if LibAkaUtils.lastMessage == "" then return end
		local slash = string.substring(LibAkaUtils.lastMessage, 1, 1)
		if slash == "/" then return end
		local charOnly = string.replace(LibAkaUtils.lastMessage, "([^a-zA-ZäöüÄÖÜß']+)", " ")
		local words = string.split(charOnly)
		LibAkaUtils.FillDictionary(words)
		LibAkaUtils.lastMessage = ""
		LibAkaUtils.HideSuggestion()
		return
	end
	LibAkaUtils.lastMessage = message
	LibAkaUtils.TriggerAF()
end

function LibAkaUtils.TriggerAF()
	local word = LibAkaUtils.GetCursorWord(LibAkaUtils.getChat())
	local results = LibAkaUtils.SearchDictionary(word)
	local endIndex = #results
	if endIndex > 5 then endIndex = NUM_SUGGESTION end
	LibAkaUtils.HideSuggestion()
	EVENT_MANAGER:RegisterForUpdate(LibAkaUtils.name.."AutoCompleteListener", 50, LibAkaUtils.AutoCompleteListener)
	LibAkaUtils.forLoop(1, endIndex, 1, function(index)
		LibAkaUtils.SetSuggestion(index, results[index].word)
	end)
end

function LibAkaUtils.AutoCompleteListener()
	if IsControlKeyDown() == true then
		if LibAkaUtils.ctrldwn == true then return end
		if LibAkaUtils.lastCtrl + DELTA_TIME_CTRL_S > os.time() then
			LibAkaUtils.ApplySuggestion(1)
		end
		LibAkaUtils.lastCtrl = os.time()
	end
	LibAkaUtils.ctrldwn = IsControlKeyDown()
end

function LibAkaUtils.FillDictionary(words)
	table.foreachi(words, function(_, word) 
		local first = string.toLowercase(string.substring(word, 1, 1))
		local second = string.toLowercase(string.substring(word, 2, 2))
		if LibAkaUtils.savedVars.dictionary[first] == nil then
			LibAkaUtils.savedVars.dictionary[first] = {}
		end
		if LibAkaUtils.savedVars.dictionary[first][second] == nil then
			LibAkaUtils.savedVars.dictionary[first][second] = {}
		end
		local before = tonumber(LibAkaUtils.savedVars.dictionary[first][second][word])
		if before == nil then before = 0 end
		LibAkaUtils.savedVars.dictionary[first][second][word] = before + 1
	end)
end

function LibAkaUtils.GetCursorWord(message)
	local slash = string.substring(message, 1, 1)
	if slash == "/" then return "" end
	local charOnly = string.replace(message, "([^a-zA-ZäöüÄÖÜß]+)", " ")
	local words = string.split(charOnly)
	local cursor = LibAkaUtils.GetCursorPos()
	local out = words[#words]
	local fullword = words[#words]
	local wsindex, weindex = string.indexOf(message, out)
	if cursor == nil then
		return out, wsindex, weindex, fullword
	end
	table.foreachi(words, function(_, word)
		local starti, endi = string.indexOf(message, word)
		if starti == nil then return end
		if endi == nil then return end
		if starti <= cursor and endi >= cursor then
			out = string.substring(message, starti, cursor)
			wsindex = starti
			weindex = endi
			fullword = word
		end
	end)
	return out, wsindex, weindex, fullword
end

function LibAkaUtils.SearchDictionary(pattern)
	if pattern == nil then return {} end
	if string.length(pattern) < 2 then return {} end
	local first = string.toLowercase(string.substring(pattern, 1, 1))
	local second = string.toLowercase(string.substring(pattern, 2, 2))
	if LibAkaUtils.savedVars.dictionary[first] == nil then return {} end
	if LibAkaUtils.savedVars.dictionary[first][second] == nil then return {} end
	local searchList = LibAkaUtils.savedVars.dictionary[first][second]
	local results = {}
	table.foreach(searchList, function(word, times)
		if string.containsIgnoreCase(word, pattern) == true and word ~= pattern then 
			table.insert(results, {
				word = word,
				times = times
			})
		end
	end)
	table.sort(results, function(a, b) return a.times > b.times end)
	return results
end

function LibAkaUtils.SetupAutofillDataCollector()
	if LibAkaUtils.savedVars.autofillEnabled ~= true then return end
	if LibAkaUtils.listeningAF == true then return end
	if LibAkaUtils.savedVars.dictionary == nil then
		LibAkaUtils.savedVars.dictionary = {}
	end
	LibAkaUtils.listeningAF = true
	LibAkaUtils.AddChatListener("LibAkaUtils_AutoFill", LibAkaUtils.HandleAF)
	EVENT_MANAGER:RegisterForEvent("LibAkaUtils_AutoFill2", EVENT_CHAT_MESSAGE_CHANNEL, function(_, _, _, message)
		LibAkaUtils.HandleAF(message)
	end)
	LibAkaUtils.RunWhenCHAT_SYSTEMIsActive(LibAkaUtils.SetupChatSuggestionsWindow)
end

function LibAkaUtils.TriggerAutofill()
	LibAkaUtils.savedVars.autofillEnabled = LibAkaUtils.invertBool(LibAkaUtils.getOrInit(LibAkaUtils.savedVars.autofillEnabled, false))
	if LibAkaUtils.savedVars.autofillEnabled == true then
		LibAkaUtils.SetupAutofillDataCollector()
		d("AutoFill enabled.")
	else
		LibAkaUtils.listeningAF = false
		LibAkaUtils.HideSuggestion()
		LibAkaUtils.RemoveListener("EVENT_ENTER_TEXT_IN_CHAT", "LibAkaUtils_AutoFill")
		EVENT_MANAGER:UnregisterForEvent("LibAkaUtils_AutoFill2")
		d("AutoFill disabled.")
	end
end

function LibAkaUtils.RunWhenCHAT_SYSTEMIsActive(func)
	if CHAT_SYSTEM == nil then 
		zo_callLater(function () 
			LibAkaUtils.RunWhenCHAT_SYSTEMIsActive(func)
		end, 500)
		return
	end
	if LibAkaUtils.GetEditControl() == nil then 
		zo_callLater(function () 
			LibAkaUtils.RunWhenCHAT_SYSTEMIsActive(func)
		end, 500)
		return
	end
	func()
end

function LibAkaUtils.SetupChatSuggestionsWindow()
	LibAkaUtils.forLoop(1, NUM_SUGGESTION, 1, function(index)
		LibAkaUtils.SetupChatSuggestion(index)
	end)
end

function LibAkaUtils.SetSuggestion(index, word)
	LibAkaUtils.chatSuggestionsData[index] = word
	LibAkaUtils.chatSuggestions[index]:SetText(word)
	LibAkaUtils.chatSuggestions[index]:SetHidden(false)
	LibAkaUtils.chatSuggestionsBG[index]:SetHidden(false)
end

function LibAkaUtils.ApplySuggestion(index)
	LibAkaUtils.chatSuggestions[index]:SetHidden(true)
	LibAkaUtils.chatSuggestionsBG[index]:SetHidden(true)
	if LibAkaUtils.chatSuggestionsData[index] == nil then return end
	local _, wordsi, wordei = LibAkaUtils.GetCursorWord(LibAkaUtils.getChat())
	local suggestion = LibAkaUtils.chatSuggestionsData[index]
	local first = string.substring(LibAkaUtils.getChat(), 0, wordsi - 1)
	local last = string.substring(LibAkaUtils.getChat(), wordei + 1, #LibAkaUtils.getChat())
	local message = first..suggestion..last
	LibAkaUtils.setChat(message)
	LibAkaUtils.chatSuggestionsData[index] = nil
	LibAkaUtils.HideSuggestion()
end

function LibAkaUtils.HideSuggestion()
	EVENT_MANAGER:UnregisterForUpdate(LibAkaUtils.name.."AutoCompleteListener")
	LibAkaUtils.forLoop(1, NUM_SUGGESTION, 1, function(index)
		LibAkaUtils.chatSuggestions[index]:SetHidden(true)
		LibAkaUtils.chatSuggestionsData[index] = nil
		LibAkaUtils.chatSuggestionsBG[index]:SetHidden(true)
	end)
end

function LibAkaUtils.SetupChatSuggestion(index)
	local width, height = LibAkaUtils.GetEditControl():GetDimensions()
	height = height + 8
	LibAkaUtils.chatSuggestionsBG[index] = WINDOW_MANAGER:CreateControl(LibAkaUtils.name.."-ChatSuggestionBG"..index, ZO_ChatWindow, CT_BACKDROP)
	LibAkaUtils.chatSuggestionsBG[index]:SetAnchor(BOTTOMRIGHT, LibAkaUtils.GetEditControl(), TOPRIGHT, 0, (index - 1) * -height)
	LibAkaUtils.chatSuggestionsBG[index]:SetAnchor(BOTTOMLEFT, LibAkaUtils.GetEditControl(), TOPLEFT, 0, (index - 1) * -height)
	LibAkaUtils.chatSuggestionsBG[index]:SetCenterColor(0, 0, 0, .85)
	LibAkaUtils.chatSuggestionsBG[index]:SetEdgeColor(0, 0, 0, .85)
	LibAkaUtils.chatSuggestionsBG[index]:SetEdgeTexture(nil, 1, 1, 0, 0)
	LibAkaUtils.chatSuggestionsBG[index]:SetHidden(true)
	LibAkaUtils.chatSuggestionsBG[index]:SetDrawLayer(2)
	LibAkaUtils.chatSuggestionsBG[index]:SetDimensions(width, height)
	
	LibAkaUtils.chatSuggestions[index] = WINDOW_MANAGER:CreateControl(LibAkaUtils.name.."-ChatSuggestion"..index, LibAkaUtils.chatSuggestionsBG[index], CT_LABEL)
	LibAkaUtils.chatSuggestions[index]:SetAnchor(LEFT, LibAkaUtils.chatSuggestionsBG[index], LEFT, 0, 0)
	LibAkaUtils.chatSuggestions[index]:SetAnchor(RIGHT, LibAkaUtils.chatSuggestionsBG[index], RIGHT, 0, 0)
	LibAkaUtils.chatSuggestions[index]:SetFont("ZoFontGameMedium")
	LibAkaUtils.chatSuggestions[index]:SetText("")
	LibAkaUtils.chatSuggestions[index]:SetWrapMode(TEX_MODE_CLAMP)
	LibAkaUtils.chatSuggestions[index]:SetColor(.8, .8, .8, 1)
	LibAkaUtils.chatSuggestions[index]:SetHidden(true)
	LibAkaUtils.chatSuggestions[index]:SetDrawLayer(3)
	LibAkaUtils.chatSuggestions[index]:SetMouseEnabled(true)
	LibAkaUtils.chatSuggestions[index]:SetMovable(false)
	LibAkaUtils.chatSuggestions[index]:SetHandler("OnMouseUp", function()
		LibAkaUtils.ApplySuggestion(index)
	end)
	LibAkaUtils.chatSuggestions[index]:SetHandler("OnMouseEnter", function()
		LibAkaUtils.chatSuggestions[index]:SetColor(1, 1, 1, 1)
	end)
	LibAkaUtils.chatSuggestions[index]:SetHandler("OnMouseExit", function()
		LibAkaUtils.chatSuggestions[index]:SetColor(.8, .8, .8, 1)
	end)
end