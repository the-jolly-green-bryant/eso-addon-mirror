
-- ZO_PreHookHandler(ZO_ChatWindowTextEntryEditBox, "OnBackspace",function(self) if IsControlKeyDown() then
-- 	local text = self:GetText()
-- 	local position = self:GetCursorPosition()
-- 		local beforeCursor = string.sub(text, 1, position)
-- 		local space= #beforeCursor - (string.find(string.reverse(beforeCursor), "[% %(\"%']") or #beforeCursor)
-- 		local newText = string.sub(text, 0, space+1)..string.sub(text, #beforeCursor+1)
-- 		if space == 0 then
-- 			newText = ""..string.sub(text, #beforeCursor+1)
-- 		end
-- 		self:SetText(newText)
-- 		self:SetCursorPosition(space+1)
-- end end)
-- qwe ret yt ui op asd sgfd 
SlashCompletion = SlashCompletion or {}


SlashCompletion.initializeFunctions = SlashCompletion.initializeFunctions or {}
--77 81 91

SlashCompletion.default = 
{
	--["accountWideProfile"] = SlashCompletion.defaultCharacter,
	["slashHistory"] = {},
}
SlashCompletion.default.savedVarsVersion = 1
local originald = d
local function d(...)
	originald(...)
end
--
-- ZO_ChatWindowTextEntryEditBox
-- SetSelection(number selectionStartIndex, number selectionEndIndex)
-- [[function ZO_AutoComplete:ApplyAutoCompletionResults(...)
--ZO_ChatTextEntry_PreviousCommand( ZO_ChatWindow )


local a = 1
ZO_PreHook(ZO_AutoComplete, "IsOpen", function(self) 

	local text = self.editControl:GetText()
	if string.find(text, "/") then
		return true
	else
		return false
	end
end)

local function filterDuplicates(results)
	local uniques = {}
	for i = 1, #results do
		uniques[results[i]] = 1
	end
	local uniqueResults = {}
	for i = 1, #results do
		if uniques[results[i]] then
			uniqueResults[#uniqueResults + 1] = results[i]
			uniques[results[i]] = nil
		end
	end
	return uniqueResults
end

function ZO_AutoComplete:ApplyAutoCompletionResults(...)
	ClearMenu()
    if ... and ... ~= "" then
        --SetMenuMinimumWidth(self.editControl:GetWidth() - GetMenuPadding() * 2)
        local results = filterDuplicates({...})
        local numResults = #results

        local text = self.editControl:GetText()
        if text == "" or (#text < 3 and string.find(text, "/") and not string.find(text, " ")) then return end
        control = self.editControl

        if not control.lastText then control.lastText = "" end
        --d("New function")
        if control.addonChangedText then
			-- do not change text here!
			control.addonChangedText = false
		else
			
			--d("__")
			--d("LAst "..control.lastText)
			--d("Text "..text)
			--d("Last Replace: "..(control.lastReplaceText or ""))
			if control.lastReplaceText == text then
				-- the current text is what we made it so let's ignore
				--d("Do not pass go!")
			elseif (#control.lastText > #text and control.lastText:sub(1, #text) == text ) or (control.lastText == text) then -- backspacing or no change
				control.lastText = text
			else
				--d("pass")
				--d("Text "..text)
				control.lastText = text
				local prefix = ""
				local offset = 0
				if string.lower(text:sub(1, 3)) == "/w " then 
					prefix = "/w "
					offset = 4
				elseif string.lower(text:sub(1, 9)) == "/whisper" then 
					prefix = "/whisper "
					offset = 10
				elseif string.find(text, " ") then return
				end
				local highestFrequency = -1
				local mostCommon = ""
				local history = SlashCompletion.savedvars['slashHistory']
				local completion = results
				if not completion then return end
				--d(completion)
				for i = 1, #completion do
					--d(completion[i])
					--d(history[completion[i]])
					--d(highestFrequency)
					if (history[completion[i]] or 0) > highestFrequency then
						--d(prefix..string.lower(completion[i]:sub(1 , #text - offset)))
						----d(string.lower(text))
						if prefix..string.lower(completion[i]:sub(1 , #text - offset)) == string.lower(text) then
							--d("A")
							highestFrequency = history[completion[i]] or 0
							mostCommon = completion[i]
							--break
						end
					end
				end

				--	d(mostCommon)
				if mostCommon ~= "" then

					-- They're entering a slash command and we have a completion we can give!
					-- Only change text here!
					if offset == 0 then
						control.addonChangedText = true
					end
					local replaceText = text .. mostCommon:sub(#text + 1 - offset)

					control.lastText = self.editControl:GetText()
					control.lastReplaceText = replaceText

					control:SetText(replaceText)
					

					control:SetSelection(#text, #mostCommon + offset, "D")
				else
					control.lastText = self.editControl:GetText()
					control.lastReplaceText = ""
				end
			end
		end
		ClearMenu()
        for i=1, math.min(numResults, 6) do
            local name = results[i]
            AddMenuItem(name, function()
                if self.useCallbacks then
                    self:FireCallbacks(self.ON_ENTRY_SELECTED, name, AUTO_COMPLETION_SELECTED_BY_CLICK)
                else
                    self.editControl:SetText(name) 
                end
            end)
        end
        --d("Hey")
        ShowMenu(self.owner, nil, MENU_TYPE_TEXT_ENTRY_DROP_DOWN)
        if not string.find(text, "/") then
        	self.ignoreArrows = true
	        if self.anchorStyle == AUTO_COMPLETION_ANCHOR_BOTTOM then
	            ZO_Menu:ClearAnchors()
	            ZO_Menu:SetAnchor(BOTTOMLEFT, self.editControl, TOPLEFT, -8, -2)
	            ZO_Menu:SetAnchor(BOTTOMRIGHT, self.editControl, TOPRIGHT, 8, -2)
	        else
	            ZO_Menu:ClearAnchors()
	            ZO_Menu:SetAnchor(TOPLEFT, self.editControl, BOTTOMLEFT, -8, 2)
	            ZO_Menu:SetAnchor(TOPRIGHT, self.editControl, BOTTOMRIGHT, 8, 2)
	        end
	        return true
	        --]]
	    else
	    	--if true then return false end
	    	--ZO_PreHookHandler(editControl, "OnDownArrow", function() self:ChangeAutoCompleteIndex(1) end)
            --ZO_PreHookHandler(editControl, "OnUpArrow", function() self:ChangeAutoCompleteIndex(-1) end)
	    	self.ignoreArrows = false
	    	--self.anchorStyle = AUTO_COMPLETION_ANCHOR_TOP
    		ZO_Menu:ClearAnchors()
    		local width = self.editControl:GetDimensions()
            ZO_Menu:SetAnchor(TOPLEFT, self.editControl, TOPRIGHT, 8, 0)
            --ZO_Menu:SetAnchor(TOPRIGHT, self.editControl, BOTTOMRIGHT, 8 + width, 2)
            
	    end
	    return true
    end
    return false

end



--[[
function GetAutoCompletion(input, maxResults, onlineOnly, includeFlags, excludeFlags, noMinScore)
    maxResults = maxResults or 10
    input = input:lower()
    d(input)
    return GenerateAutoCompletionResults(input, maxResults, onlineOnly, includeFlags, excludeFlags, noMinScore)
end]]

SlashCompletion.savedVarsVersion = 1
SlashCompletion.name = "SlashCompletion"

local function whisperSlash(value)

	CHAT_SYSTEM:SetChannel( CHAT_CHANNEL_WHISPER , value)
	StartChatInput("")
end
SLASH_COMMANDS["/w"] = whisperSlash
SLASH_COMMANDS["/whisper"] = whisperSlash
SLASH_COMMANDS["/t"] = whisperSlash
SLASH_COMMANDS["/tell"] = whisperSlash

function SlashCompletion:Initialize()
	--[[LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("DolgubonsWritCrafter", SlashCompletion.settings["panel"])
	SlashCompletion.settings["options"] = SlashCompletion.langOptions()
	LAM:RegisterOptionControls("DolgubonsWritCrafter", SlashCompletion.settings["options"])]]
	
	SlashCompletion.savedvars = ZO_SavedVars:NewAccountWide("autocompletesavedvars", 
		SlashCompletion.savedVarsVersion, nil, SlashCompletion.default)
	-- Allow the preference to decay if it hasn't been used in some time
	for k, v in pairs(SlashCompletion.savedvars['slashHistory']) do
		if v*0.94 < 0.2 then
			v = 0
		end
		SlashCompletion.savedvars['slashHistory'][k] = v*0.94
	end

	for k, v in pairs(SLASH_COMMANDS) do

		ZO_PreHook(SLASH_COMMANDS,k, function()
			--d(SlashCompletion.savedvars['slashHistory'][k])
			--d("No 2 calls "..k)
		SlashCompletion.savedvars['slashHistory'][k] = math.max((SlashCompletion.savedvars['slashHistory'][k] or 0) + 1 ,5)   end)
	end

	EVENT_MANAGER:UnregisterForEvent(SlashCompletion.name, EVENT_PLAYER_ACTIVATED)
	setmetatable(SLASH_COMMANDS, {['__newindex'] = function(t, index, newvalue)

	rawset (t, index ,newvalue)
	ZO_PreHook(t, index, function() SlashCompletion.savedvars['slashHistory'][index] = (SlashCompletion.savedvars['slashHistory'][index] or 0) + 1    end) end
	})

-- No idea if this code had a reason for being here??
-- comment it out for now I guess
-- local a = true
-- local function addTooltip(s, ability, data, displayView, b, c)

-- 	local bar = ability.xpBar:GetControl()
-- 	bar:SetHandler("OnMouseEnter",function()
-- 		if not data.progressionIndex then return end
-- 		local lastXP, nextXP, currentXP, atMorph = GetAbilityProgressionXPInfo(data.progressionIndex)
-- 		local current, total = currentXP - lastXP, nextXP - lastXP
-- 		if current == 0 and total == 0 then return end
-- 		InitializeTooltip(InformationTooltip, bar, BOTTOM, 0, -5)
-- 		SetTooltipText(InformationTooltip, current.."/"..total)
-- 	end)
-- 	bar:SetHandler("OnMouseExit",function()ClearTooltip(InformationTooltip) end)
-- end

-- local function hook(ability, data, displayView)
	
-- 	zo_callLater( function() addTooltip(ability, data, displayView) end, 100)

-- end
-- ZO_PreHook( ZO_SkillsManager,"SetupAbilityEntry", hook)


--[[
	

	SlashCompletion.charSavedVars = ZO_SavedVars:NewCharacterIdSettings("dolgubonslazysetcrafter",
		SlashCompletion.savedVarsVersion, nil, SlashCompletion.savedvars.accountWideProfile) 

	if SlashCompletion.savedvars.debug then
		SlashCompletionWindow:SetHidden(false)
	end--]]

	--if pcall(SlashCompletion.initializeFunctions.initializeSettingsMenu) then else d("Dolgubon's Lazy Set Crafter: USettings not loaded") end
	--SlashCompletion.initializeFunctions.initializeSettingsMenu()
	--if pcall(SlashCompletion.initializeFunctions.initializeCrafting) then else d("Dolgubon's Lazy Set Crafter: UCrafting not loaded") end
	--SlashCompletion.initializeFunctions.initializeCrafting()
	--if pcall(SlashCompletion.initializeFunctions.setupUI) then else d("Dolgubon's Lazy Set Crafter: UI not loaded") end
	--SlashCompletion.initializeFunctions.setupUI()
	
	--SlashCompletion.initializeFeedbackWindow()
end

EVENT_MANAGER:RegisterForEvent(SlashCompletion.name, EVENT_PLAYER_ACTIVATED, SlashCompletion.Initialize)
--EVENT_MANAGER:RegisterForEvent(SlashCompletion.name, EVENT_CRAFT_COMPLETED , d)

-- Also anyone know if there's an addon that automatically opens up to what you were last looking at when you press escape?
--e.g. if I'm looking at the settings of some UI heavy addon, I might want to exit the settings menu a lot and go back in, but I don't want to click on the addon settings button all the time