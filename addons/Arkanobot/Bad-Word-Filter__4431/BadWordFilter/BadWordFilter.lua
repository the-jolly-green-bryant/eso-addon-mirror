BadWordFilter = BadWordFilter or {}
BadWordFilter.name = "BadWordFilter"

--------------------------------------------------
-- CACHE SYSTEM
--------------------------------------------------

local patternCache = {}
local normalizedCache = {}

-- Clear cache when words change (to avoid stale patterns)
local function ClearCache()
    patternCache = {}
    normalizedCache = {}
end

--------------------------------------------------
-- LEETSPEAK NORMALIZATION
--------------------------------------------------

local function NormalizeText(text)
    if not text then return "" end
    
    -- Check cache first
    if normalizedCache[text] then
        return normalizedCache[text]
    end
    
    local normalized = string.lower(text)
    
    -- Single pass replacement using gsub with table
    normalized = string.gsub(normalized, "[@41!3$05]", function(match)
        return BadWordFilter.LEET_MAP[match] or match
    end)
    
    -- Cache the result
    normalizedCache[text] = normalized
    return normalized
end

--------------------------------------------------
-- BUILD FLEXIBLE WORD PATTERN
--------------------------------------------------

local function BuildWordPattern(word)
    if not word then return "" end
    
    word = string.lower(word)
    
    -- Check cache first
    if patternCache[word] then
        return patternCache[word]
    end
    
    local pattern = {}
    
    for i = 1, #word do
        local char = word:sub(i, i)
        local charPattern = BadWordFilter.CHAR_CLASSES[char] or char
        
        if i < #word then
            pattern[#pattern + 1] = charPattern .. "[%W_]*"
        else
            pattern[#pattern + 1] = charPattern
        end
    end
    
    local fullPattern = table.concat(pattern)
    patternCache[word] = fullPattern
    
    return fullPattern
end

--------------------------------------------------
-- DETECT BAD WORD
--------------------------------------------------

local function ContainsBadWord(text)
    if not text or text == "" then return false end
    
    text = NormalizeText(text)
    
    for _, word in ipairs(BadWordFilter.saved.words) do
        local pattern = BuildWordPattern(word)
        
        if string.find(text, pattern, 1, false) then
            return true
        end
    end
    
    return false
end

--------------------------------------------------
-- MASTER FILTER FUNCTION
--------------------------------------------------

local function FilterText(text, mode)
    if not text or text == "" then return text end
    
    local normalized = NormalizeText(text)
    local result = text
    local replacement = BadWordFilter.saved.replacementWord or "beep"
    
    for _, word in ipairs(BadWordFilter.saved.words) do
        local pattern = BuildWordPattern(word)
        
        if string.find(normalized, pattern, 1, false) then
            
            if mode == "block" then
                return ""  -- Early return for block mode
                
            elseif mode == "censor" then
                local stars = string.rep("*", #word)
                -- Use a function to preserve case of surrounding text
                result = string.gsub(result, pattern, function(match)
                    return stars
                end)
                
            elseif mode == "partial" then
                local first = string.sub(word, 1, 1)
                local last = string.sub(word, -1)
                local stars = string.rep("*", math.max(#word - 2, 1))
                local replacementText = first .. stars .. last
                
                result = string.gsub(result, pattern, function(match)
                    -- Check if the matched word was uppercase
                    if match == string.upper(match) then
                        return string.upper(replacementText)
                    -- Check if first letter was capitalized
                    elseif match:sub(1,1) == string.upper(match:sub(1,1)) then
                        return string.upper(first) .. stars .. last
                    else
                        return replacementText
                    end
                end)
                
            elseif mode == "replace" then
                result = string.gsub(result, pattern, function(match)
                    -- Check if the matched word was uppercase
                    if match == string.upper(match) then
                        return string.upper(replacement)
                    -- Check if first letter was capitalized
                    elseif match:sub(1,1) == string.upper(match:sub(1,1)) then
                        return string.upper(replacement:sub(1,1)) .. replacement:sub(2)
                    else
                        return replacement
                    end
                end)
            end
        end
    end
    
    return result
end

--------------------------------------------------
-- CHAT HOOK 
--------------------------------------------------

local function HookChat()
    if not CHAT_SYSTEM then return end
    
    ZO_PreHook(CHAT_SYSTEM, "SubmitTextEntry", function(self)
        local editBox = self.textEntry.editControl
        local text = editBox:GetText()
        
        if text == "" or not ContainsBadWord(text) then
            return false
        end
        
        local mode = BadWordFilter.saved.mode
        
        if mode == "block" then
            editBox:SetText("")
            d("[BadWordFilter] Message blocked")
            return true
        end
        
        local filtered = FilterText(text, mode)
        if filtered ~= text then
            editBox:SetText(filtered)
        end
        
        return false
    end)
end

--------------------------------------------------
-- WORD MANAGEMENT FUNCTIONS
--------------------------------------------------

local function AddWord(word)
    word = string.lower(word)
    if word == "" then return end
    
    for _, w in ipairs(BadWordFilter.saved.words) do
        if w == word then return end
    end
    
    table.insert(BadWordFilter.saved.words, word)
    ClearCache()  -- Clear cache when words change
end

local function RemoveWord(word)
    word = string.lower(word)
    if word == "" then return end
    
    for i, w in ipairs(BadWordFilter.saved.words) do
        if w == word then
            table.remove(BadWordFilter.saved.words, i)
            ClearCache()  -- Clear cache when words change
            return
        end
    end
end

local function ResetDefaults()
    BadWordFilter.saved.mode = BadWordFilter.DEFAULTS.mode
    BadWordFilter.saved.words = {}
    BadWordFilter.saved.replacementWord = BadWordFilter.DEFAULTS.replacementWord
    
    for _, w in ipairs(BadWordFilter.DEFAULTS.words) do
        table.insert(BadWordFilter.saved.words, w)
    end
    
    ClearCache()  -- Clear cache after reset
end

--------------------------------------------------
-- SETTINGS PANEL
--------------------------------------------------

local function CreateSettings()
    local LAM = LibAddonMenu2
    
    local panelData = {
        type = "panel",
        name = "Bad Word Filter",
        displayName = "Bad Word Filter",
        author = "ARKANOBOT",
        version = "1.0",
        registerForRefresh = true,
        registerForDefaults = true,
        resetFunc = ResetDefaults
    }
    
    LAM:RegisterAddonPanel("BadWordFilterPanel", panelData)
    
    -- Cache the word list for description updates
    local function GetWordListText()
        return "Current words:\n" .. table.concat(BadWordFilter.saved.words, ", ")
    end
    
    local options = {
        {
            type = "dropdown",
            name = "Filter Mode",
            choices = {"block", "censor", "partial", "replace"},
            default = BadWordFilter.DEFAULTS.mode,
            getFunc = function() return BadWordFilter.saved.mode end,
            setFunc = function(value)
                BadWordFilter.saved.mode = value
            end
        },
        {
            type = "editbox",
            name = "Add Bad Word",
            getFunc = function() return "" end,
            setFunc = function(value)
                value = value and value:match("^%s*(.-)%s*$") or ""
                if value ~= "" then AddWord(value) end
            end
        },
        {
            type = "editbox",
            name = "Remove Bad Word",
            getFunc = function() return "" end,
            setFunc = function(value)
                value = value and value:match("^%s*(.-)%s*$") or ""
                if value ~= "" then RemoveWord(value) end
            end
        },
        {
            type = "editbox",
            name = "Replacement Word",
            tooltip = "Word used when filter mode is 'replace'",
            default = BadWordFilter.DEFAULTS.replacementWord,
            getFunc = function() return BadWordFilter.saved.replacementWord end,
            setFunc = function(value)
                value = value and value:match("^%s*(.-)%s*$") or ""
                if value ~= "" then
                    BadWordFilter.saved.replacementWord = value
                end
            end
        },
        {
            type = "description",
            text = GetWordListText
        }
    }
    
    LAM:RegisterOptionControls("BadWordFilterPanel", options)
end

--------------------------------------------------
-- PLAYER LOADED
--------------------------------------------------

local function OnPlayerActivated()
    zo_callLater(HookChat, 1000)
end

--------------------------------------------------
-- ADDON LOADED
--------------------------------------------------

local function OnAddonLoaded(event, addonName)
    if addonName ~= BadWordFilter.name then return end
    
    EVENT_MANAGER:UnregisterForEvent(BadWordFilter.name, EVENT_ADD_ON_LOADED)
    
    BadWordFilter.saved = ZO_SavedVars:NewAccountWide(
        "BadWordFilterSaved",
        1,
        nil,
        BadWordFilter.DEFAULTS  -- Use DEFAULTS from constants
    )
    
    -- Ensure saved vars are properly initialized
    if not BadWordFilter.saved.words then
        ResetDefaults()
    end
    
    CreateSettings()
    
    EVENT_MANAGER:RegisterForEvent(
        BadWordFilter.name.."Player",
        EVENT_PLAYER_ACTIVATED,
        OnPlayerActivated
    )
end

EVENT_MANAGER:RegisterForEvent(
    BadWordFilter.name,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)