local ee = ESOEmoji


ee.SCAutoComplete = ZO_AutoComplete:Subclass()
local sca = ee.SCAutoComplete
local shortcodes = {}
local shortcodeBytes = {}

-- This file utilizes alot of code from the esoui. Below are some of the major files used:
-- https://github.com/esoui/esoui/blob/master/esoui/libraries/utility/zo_autocomplete.lua
-- https://github.com/esoui/esoui/blob/master/esoui/ingame/slashcommands/slashcommandautocomplete.lua

function ee.SCAutoComplete_Init()
    local vars = ee:GetVars()
	for i,v in pairs(ee.emojiSCs) do
		if v.unicode and ee.emojiMap[v.unicode] then -- skip various unicode icons such as copyright which dont have a texture
            local emojiFile = ee.emojiMap[v.unicode].texture
			
			local size = tostring(math.floor(vars.emojiSettings.Size*ee.PathScale[vars.emojiSettings.Path]+0.5))
			textureLink = "|t" .. size .. ":" .. size .. ":" .. vars.emojiSettings.Path .. emojiFile .. "|t"
            local text = textureLink.." - :"..i..":"
            shortcodes[i] = text
            
			local result = ""
			for uCode in string.gmatch(v.unicode, "([%u%1%d]+)") do
				--Encode
				result = result .. ee.Unicode2Bytes(uCode)
			end
			shortcodeBytes[text] = result
			
		end
	end
    ee.asc = ee.SCAutoComplete:New(CHAT_SYSTEM.textEntry.editControl, nil, nil, nil, 8, AUTO_COMPLETION_AUTOMATIC_MODE, AUTO_COMPLETION_DONT_USE_ARROWS)
end


function sca:New(...)
    return ZO_AutoComplete.New(self, ...)
end

function sca:Initialize(editControl, ...)
    ZO_AutoComplete.Initialize(self, editControl, ...)


    self.matchedTextStart = nil

    self.possibleMatches = {}

    self:SetUseCallbacks(true)
    self:SetAnchorStyle(AUTO_COMPLETION_ANCHOR_BOTTOM)
    self:SetOwner(ee.emojiSCs)
    self:SetKeepFocusOnCommit(true)

    local function OnAutoCompleteEntrySelected(selected, selectionMethod) -- EDIT THIS
        local replacementByte = shortcodeBytes[selected]
        self:autoFillEditbox(replacementByte)
    end

    self:RegisterCallback(ZO_AutoComplete.ON_ENTRY_SELECTED, OnAutoCompleteEntrySelected)


    ZO_PreHook("ZO_ChatTextEntry_PreviousCommand", function(...)
        if not IsShiftKeyDown() and self:IsOpen() then
            local index = self:GetAutoCompleteIndex()
            if not index or index > 1 then
                self:ChangeAutoCompleteIndex(-1)
                return true
            end
        end
    end)

    ZO_PreHook("ZO_ChatTextEntry_NextCommand", function(...)
        if not IsShiftKeyDown() and self:IsOpen() then
            local index = self:GetAutoCompleteIndex()
            if not index or index < self:GetNumAutoCompleteEntries() then
                self:ChangeAutoCompleteIndex(1)
                return true --Handled
            end
        end
    end)
end

function sca:InvalidateSlashCommandCache()
    self.possibleMatches = {}
end



function sca:autoFillEditbox(replacementByte)
    if self.matchedTextStart and self.matchedTextEnd then
		-- Insert Emoji into text message
        self.editControl:SetText(self.editControl:GetText():sub(1,self.matchedTextStart-1) .. replacementByte .. self.editControl:GetText():sub(self.matchedTextEnd+1))
    end
end



function sca:ApplyAutoCompletionResults(...)
    if ... and ... ~= "" then
        ClearMenu()
        SetMenuMinimumWidth(self.editControl:GetWidth() - GetMenuPadding() * 2)

        local numResults = select("#", ...)
        for i=1, numResults do
            local name = select(i, ...)
            AddMenuItem(shortcodes[name], function()
                local replacementByte = shortcodeBytes[shortcodes[name]]
                self:autoFillEditbox(replacementByte)
            end)
        end
        
        ShowMenu(self.owner, nil, MENU_TYPE_TEXT_ENTRY_DROP_DOWN)

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
    end
    
    return false
end



function sca:SetEditControl(editControl)
    if editControl then
        if self.automaticMode then
            ZO_PreHookHandler(editControl, "OnTextChanged", function() self:OnTextChanged() end)
        end

        ZO_PreHookHandler(editControl, "OnTab", function()
            if self:IsOpen() then
                if not ZO_Menu_GetSelectedIndex() then
                    self:ChangeAutoCompleteIndex(1)
                end
                return self:OnCommit(COMMIT_BEHAVIOR_KEEP_FOCUS, AUTO_COMPLETION_SELECTED_BY_TAB)
            end
        end)

        if self.useArrows then
            ZO_PreHookHandler(editControl, "OnDownArrow", function() self:ChangeAutoCompleteIndex(1) end)
            ZO_PreHookHandler(editControl, "OnUpArrow", function() self:ChangeAutoCompleteIndex(-1) end)
        end
    
        ZO_PreHookHandler(editControl, "OnFocusLost", function() self:Hide() end)
        ZO_PreHookHandler(editControl, "OnHide", function() self:Hide() end)
    end
    
    self.editControl = editControl
end


function sca:GetAutoCompletionResults(text)
    if #text < 3 then
        return
    end
    
    local parseText = string.sub(text, 1, KEYBOARD_CHAT_SYSTEM.textEntry:GetCursorPosition())
    local escapedParseText = parseText:gsub("([^%w])", "%%%1");

    if (string.match(escapedParseText, "%%|[hH]%d%%:.-%%|[hH].-%%|[hH]")) then --> Match out any guild or achieve links
        for link in string.gmatch(escapedParseText, "%%|[hH]%d%%:.-%%|[hH].-%%|[hH]") do
            replacementString = string.format("%-"..#link.."s","")
            escapedParseText,_ = escapedParseText:gsub(link, replacementString)
        end
    end

    parseText = escapedParseText:gsub("%%([^%w])", "%1")

    local matchedTextEnd = 1
    
    self.matchedTextStart, self.matchedTextEnd = string.find(parseText, ":[^:]*$") --> Match the last : in the message

    if not self.matchedTextStart then
        return
    end

    local matchedText = string.sub(parseText, self.matchedTextStart+1, self.matchedTextEnd)
    if #matchedText < 3 or matchedText:find(" ") then
        return
    end

    if next(self.possibleMatches) == nil then
        for i,v in pairs(shortcodes) do
            self.possibleMatches[i] = i
        end
    end

    local results = GetTopMatchesByLevenshteinSubStringScore(self.possibleMatches, matchedText, 2, self.maxResults)
    if results then
        return unpack(results)
    end
    return nil
end