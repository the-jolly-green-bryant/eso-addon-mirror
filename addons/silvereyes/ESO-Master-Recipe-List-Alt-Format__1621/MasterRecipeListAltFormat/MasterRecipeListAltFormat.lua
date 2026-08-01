local addonName = "MasterRecipeListAltFormat"
local addon = {
    name = addonName,
    title = "ESO Master Recipe List Alt Format",
    author = "silvereyes",
    version = "1.1.17",
}

-- Color configuration
local COLOR_UNKNOWN               = ZO_ERROR_COLOR
local COLOR_KNOWN                 = ZO_ColorDef:New("66CCFF")
local COLOR_INDETERMINATE         = ZO_DEFAULT_DISABLED_COLOR

local charNames                   = {} -- all character names, indexed by order
local knownCharsByName            = {} -- scanned character name lookup index
local originalAddLines            = {} -- original tooltip AddLine() methods, indexed by control
local originalAddVerticalPaddings = {} -- original tooltip AddVerticalPadding() methods, indexed by control

local reformatting       -- flag indicating we are in the middle of a reformat
local verticalPadding    -- stores padding to be added before reformatted list
local tooltipLineBuilder -- stores multiline alt lists in between AddLine() calls
local knownByHeader      -- ESO Master Recipe List "Known By" header text
local craftableByHeader  -- ESO Master Recipe List "Craftable By" header text

--[[ Removes any ESO color code markers from the start and end of the given text. ]]
local function StripColorAndWhitespace(text)
    text = zo_strtrim(text)
    if string.sub(text, 1, 2) == "|c" then
        text = string.sub(text, 9)
    end
    if string.sub(text, -2) == "|r" then
        text = string.sub(text, 1, -3)
    end
    return text
end

--[[ Reformats a colorized list of characters into an ordered list, and appends any remaining 
     characters in either red or grey, depending on whether they have been scanned by 
     ESO Master Recipe List yet.]]
local function ReformatKnownBy(text)

    -- Parse out the character names in the passed in list
    local names = {}
    for part in string.gmatch(text, '([^,]+)') do
        local characterName = StripColorAndWhitespace(part)
        names[characterName] = true
    end
    
    -- Create an ordered, colorized list of the names
    local formattedNames = {}
    for _, characterName in ipairs(charNames) do
        if names[characterName] then
            table.insert(formattedNames, COLOR_KNOWN:Colorize(characterName))
        end
    end
    
    -- Append an ordered list of any remaining names that have been scanned, colored in red
    for _, characterName in ipairs(charNames) do
        if not names[characterName] and knownCharsByName[characterName] then
            table.insert(formattedNames, COLOR_UNKNOWN:Colorize(characterName))
        end
    end
    
    -- Append a list of any remaining names that have not been scanned, colored in grey
    for _, characterName in ipairs(charNames) do
        if not names[characterName] and not knownCharsByName[characterName] then
            table.insert(formattedNames, COLOR_INDETERMINATE:Colorize(characterName))
        end
    end
    
    -- Create the final comma separated list of names
    local output = table.concat(formattedNames, ", ")
    return output
end

--[[ Hooks ItemTooltip:AddVerticalPadding() and PopupTooltip:AddVerticalPadding(). 
     When in the middle of a multi-line alt list reformat, it ignores any vertical padding calls in
     the middle of the list, since we are going to format the whole list as a single line. 
     The padding amount is saved in the verticalPadding local variable so that we can add it before 
     writing the final line.]]
local function TooltipAddVerticalPadding(control, paddingY)
    if reformatting then
        verticalPadding = paddingY
        return
    end
    originalAddVerticalPaddings[control](control, paddingY)
end

--[[ Hooks ItemTooltip:AddLine() and PopupTooltip:AddLine(). 
     Detects the "known by" and "craftable by" tooltip lines, and then reformats the following list
     of alts that are added. ]]
local function TooltipAddLine(control, text, font, r, g, b, lineAnchor, modifyTextType, textAlignment, setToFullSize)
    
    -- We are in the middle of a reformat
    if reformatting then
    
        -- Lines ending in commas indicate more lines to come, so append the text to the running
        -- tooltipLineBuilder, and then return.
        if string.sub(text, -2) == ", " then
            if tooltipLineBuilder then
                tooltipLineBuilder = tooltipLineBuilder .. text
            else
                tooltipLineBuilder = text
            end
            return
        end
        
        -- No comma means this is the last line
        reformatting = nil
        if tooltipLineBuilder then
            text = tooltipLineBuilder .. text
            tooltipLineBuilder = nil
        end
        
        -- Perform the reformat
        text = ReformatKnownBy(text)
        font = ""
        lineAnchor = CENTER
        textAlignment = TEXT_ALIGN_CENTER
        setToFullSize = true
        
        -- Add the most recently-seen vertical padding, if there was one (there should be)
        if verticalPadding then
            originalAddVerticalPaddings[control](control, verticalPadding)
        end
    
    -- Known By or Craftable By header detected. Start reformat the next time AddLine() is called.
    elseif text == knownByHeader or text == craftableByHeader then
        reformatting = true
    
    -- Not in a reformat. So, no special processing. Just pass through.
    --else
    end
    
    -- Fix issue with default text color getting set to black. I have no clue why this is necessary.
    if r == nil then r = 1 end
    if g == nil then g = 1 end
    if b == nil then b = 1 end
    
    -- Add the line to the tooltip
    originalAddLines[control](control, text, font, r, g, b, lineAnchor, modifyTextType, textAlignment, setToFullSize)
end

local function OnAddonLoaded(event, name)
    if name ~= addonName then return end
    
    -- Populate ordered list of character names for this account
    for i = 1, GetNumCharacters() do
        local characterName = zo_strformat("<<1>>", GetCharacterInfo(i))
        charNames[i] = characterName
    end
    
    -- Populate list of characters that have been scanned by ESO Master Recipe List
    local accountName = GetDisplayName()
    local savedVars = MasterRecipeList[GetWorldName()] or MasterRecipeList["Default"]
    for characterId, characterDetails in pairs(savedVars[accountName]) do
        local characterName
        if characterDetails["$LastCharacterName"] then
            characterName = characterDetails["$LastCharacterName"]
        else
            characterName = characterId
        end
        if characterName ~= "$AccountWide" then
            knownCharsByName[characterName] = true
        end
    end
    knownCharsByName[GetUnitName("player")] = true
    
    -- Store the tooltip headers used to signal that the following line(s) represents a list of alts
    local mrlStrings = ESOMRL:GetLanguage()
    knownByHeader = mrlStrings.ESOMRL_KNOWN
    craftableByHeader = mrlStrings.ESOMRL_CRAFTABLE
    
    -- Hook tooltip AddLine and AddVerticalPadding functions
    for _, tooltip in ipairs({ItemTooltip, ESOMRL_MainFrameRecipeTooltip or PopupTooltip}) do
        originalAddLines[tooltip] = tooltip.AddLine
        originalAddVerticalPaddings[tooltip] = tooltip.AddVerticalPadding
        tooltip.AddLine = TooltipAddLine
        tooltip.AddVerticalPadding = TooltipAddVerticalPadding
    end
end
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnAddonLoaded)
MasterRecipeListAltFormat = addon