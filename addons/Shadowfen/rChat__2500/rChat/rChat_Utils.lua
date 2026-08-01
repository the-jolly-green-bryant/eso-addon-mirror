rChat = rChat or {}

local SF = LibSFUtils

-- Used for rChat LinkHandling
local RCHAT_LINK = "p"
local RCHAT_URL_CHAN = 97
local RCHAT_CHANNEL_NONE = 99

-- ------------------------------------------------------
function rChat.getPlayerNames()
	local names={}
	for i = 1, GetNumCharacters() do
		local name, _, _, _, _, _, characterId = GetCharacterInfo(i)
		table.insert(names, zo_strformat("<<1>>", name))
	end
	return names
end

function rChat.getPlayerIds()
	local ids={}
	for i = 1, GetNumCharacters() do
		local name, _, _, _, _, _, characterId = GetCharacterInfo(i)
		table.insert(ids, characterId)
	end
	return ids
end

-- ------------------------------------------------------
-- Timestamp functions
--

-- Create a timestamp string in the specified format
-- with the time string (HH:mm:ss) provided. If no time
-- is provided then get the current time.
function rChat.CreateTimestamp(formatStr, timeStr)
    if not timeStr then timeStr = GetTimeString() end

    -- split up default timestamp
    local hours, minutes, seconds = timeStr:match("([^%:]+):([^%:]+):([^%:]+)")
    local hoursNoLead = tonumber(hours) -- hours without leading zero
    local hours12NoLead = (hoursNoLead - 1)%12 + 1
    local hours12 = hours12NoLead
    if (hours12NoLead < 10) then
        hours12 = "0" .. hours12NoLead
    end
    local pUp = "AM"
    local pLow = "am"
    if (hoursNoLead >= 12) then
        pUp = "PM"
        pLow = "pm"
    end

    -- create new one
    local timestamp = formatStr
    timestamp = timestamp:gsub("HH", hours)
    timestamp = timestamp:gsub("H", hoursNoLead)
    timestamp = timestamp:gsub("hh", hours12)
    timestamp = timestamp:gsub("h", hours12NoLead)
    timestamp = timestamp:gsub("m", minutes)
    timestamp = timestamp:gsub("s", seconds)
    timestamp = timestamp:gsub("A", pUp)
    timestamp = timestamp:gsub("a", pLow)

    return timestamp

end


-- ------------------------------------------------------
-- UTF-8 Helper Function (Robust Implementation)
-- ------------------------------------------------------
-- Returns the number of bytes used by the UTF-8 character starting at index i
-- Returns 0 if invalid or out of bounds
function rChat.getUtf8CharLength(s, i)
    if not s or i > #s then return 0 end
    
    local c = s:byte(i)
    
    -- UTF8-1 (0xxxxxxx)
    if c <= 127 then
        return 1
    -- UTF8-2 (110xxxxx)
    elseif c >= 194 and c <= 223 then
        if i + 1 > #s then return 0 end -- Invalid truncation
        local c2 = s:byte(i + 1)
        if c2 < 128 or c2 > 191 then return 0 end
        return 2
    -- UTF8-3 (1110xxxx)
    elseif c >= 224 and c <= 239 then
        if i + 2 > #s then return 0 end
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)
        
        -- Validation for overlong encodings
        if c == 224 and (c2 < 160 or c2 > 191) then return 0 end
        if c == 237 and (c2 < 128 or c2 > 159) then return 0 end
        if c2 < 128 or c2 > 191 then return 0 end
        if c3 < 128 or c3 > 191 then return 0 end
        
        return 3
    -- UTF8-4 (11110xxx)
    elseif c >= 240 and c <= 244 then
        if i + 3 > #s then return 0 end
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)
        local c4 = s:byte(i + 3)
        
        if c == 240 and (c2 < 144 or c2 > 191) then return 0 end
        if c == 244 and (c2 < 128 or c2 > 143) then return 0 end
        if c2 < 128 or c2 > 191 then return 0 end
        if c3 < 128 or c3 > 191 then return 0 end
        if c4 < 128 or c4 > 191 then return 0 end
        
        return 4
    else
        -- Invalid byte
        return 0
    end
end

-- ------------------------------------------------------
-- Split String by Byte Length (Safe UTF-8)
-- ------------------------------------------------------
function rChat.strSplitMB(text, maxChars)
    if not text then return {} end
    
    local retval = {}
    local textLen = #text
    
    if textLen <= maxChars then
        table.insert(retval, text)
        return retval
    end

    local splitStart = 1
    while splitStart <= textLen do
        local currentPos = splitStart
        local charCount = 0
        
        -- Iterate byte by byte until we hit maxChars or end of string
        while currentPos <= textLen and charCount < maxChars do
            local charLen = rChat.getUtf8CharLength(text, currentPos)
            
            if charLen == 0 then
                -- Invalid UTF-8 sequence, treat as 1 byte to avoid infinite loop
                charLen = 1
            end
            
            -- Check if adding this character exceeds the limit
            if charCount + 1 > maxChars then
                break
            end
            
            currentPos = currentPos + charLen
            charCount = charCount + 1
        end
        
        -- Extract the segment
        local segment = text:sub(splitStart, currentPos - 1)
        table.insert(retval, segment)
        
        splitStart = currentPos
    end

    return retval
end


-- Create an RCHAT link of the passed in text with chanCode, numline data.
-- withoutbrackets (boolean) is optional - defaults to false.
function rChat.LinkHandler_CreateLink(numLine, chanCode, text, withoutbrackets)
    if not withoutbrackets then
        return ZO_LinkHandler_CreateLink(text, nil, RCHAT_LINK, numLine, chanCode)
    else
        return ZO_LinkHandler_CreateLinkWithoutBrackets(text, nil, RCHAT_LINK, numLine, chanCode)
    end
end

-- ------------------------------------------------------
-- Split Text for LinkHandler (Safe UTF-8)
-- ------------------------------------------------------
-- Split text into blocs of 100 chars (106 is max for LinkHandle) and add LinkHandle to them
function rChat.SplitTextForLinkHandler(text, numLine, chanCode)
    if not text then return nil end
    
    local textLen = #text
    local MAX_LEN = 100 -- Max length per link segment
    
    -- Handle empty or whitespace-only strings
    if textLen == 0 or text:match("^%s*$") then
        return text
    end

    if textLen <= MAX_LEN then
        return rChat.LinkHandler_CreateLink(numLine, chanCode, text, true)
    end

    local segments = rChat.strSplitMB(text, MAX_LEN)
    local result = ""
    
    for i, segment in ipairs(segments) do
        if segment and #segment > 0 then
            result = result .. rChat.LinkHandler_CreateLink(numLine, chanCode, segment, true)
        end
    end
    
    return result
end

