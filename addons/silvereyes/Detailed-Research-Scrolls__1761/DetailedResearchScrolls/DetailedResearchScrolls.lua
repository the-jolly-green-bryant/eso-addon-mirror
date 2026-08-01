DetailedResearchScrolls = {
    name = "DetailedResearchScrolls",
    title = "Detailed Research Scrolls",
    version = "1.4.13",
    author = "silvereyes",
}
local addon                 = DetailedResearchScrolls
local CRAFT_SKILLS_ALL     = { CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING, CRAFTING_TYPE_JEWELRYCRAFTING }
local CRAFT_SKILLS_SMITH   = { CRAFTING_TYPE_BLACKSMITHING }
local CRAFT_SKILLS_CLOTH   = { CRAFTING_TYPE_CLOTHIER }
local CRAFT_SKILLS_WOOD    = { CRAFTING_TYPE_WOODWORKING }
local CRAFT_SKILLS_JEWELRY = { CRAFTING_TYPE_JEWELRYCRAFTING or -1 }
local COLOR_ERROR          = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_FAILED))
local COLOR_WARNING        = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_CAST_BAR_START, CAST_BAR_DEFAULT))
local COLOR_TOOLTIP        = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
local COLOR_TITLE          = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HIGHLIGHT))
local COLOR_VALID          = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SUCCEEDED))
local ONE_DAY              = 86400
local TWO_DAYS             = 2 * ONE_DAY
local SEVEN_DAYS           = 7 * ONE_DAY
local FIFTEEN_DAYS         = 15 * ONE_DAY
local CRAFTSKILL_SLOT_COUNTS = {
    [CRAFTING_TYPE_BLACKSMITHING]   = 3, 
    [CRAFTING_TYPE_CLOTHIER]        = 3,
    [CRAFTING_TYPE_WOODWORKING]     = 3,
    [CRAFTING_TYPE_JEWELRYCRAFTING or -1] = 1,
}
local researchScrolls      = {
    -- Crown Research Scroll, Blacksmithing, 1 Day
    [125450] = {
        ["craftSkills"] = CRAFT_SKILLS_SMITH,
        ["duration"] = ONE_DAY,
    },
    -- Crown Research Scroll, Blacksmithing, 2 Day
    [125462] = {
        ["craftSkills"] = CRAFT_SKILLS_SMITH,
        ["duration"] = FIFTEEN_DAYS,
    },
    -- Crown Research Scroll, Blacksmithing, 7 Day
    [125463] = {
        ["craftSkills"] = CRAFT_SKILLS_SMITH,
        ["duration"] = SEVEN_DAYS,
    },
    -- Crown Research Scroll, Clothing, 1 Day
    [125464] = {
        ["craftSkills"] = CRAFT_SKILLS_CLOTH,
        ["duration"] = ONE_DAY,
    },
    -- Crown Research Scroll, Clothing, 2 Day
    [125465] = {
        ["craftSkills"] = CRAFT_SKILLS_CLOTH,
        ["duration"] = FIFTEEN_DAYS,
    },
    -- Crown Research Scroll, Clothing, 7 Day
    [125466] = {
        ["craftSkills"] = CRAFT_SKILLS_CLOTH,
        ["duration"] = SEVEN_DAYS,
    },
    -- Crown Research Scroll, Woodworking, 1 Day
    [125467] = {
        ["craftSkills"] = CRAFT_SKILLS_WOOD,
        ["duration"] = ONE_DAY,
    },
    -- Crown Research Scroll, Woodworking, 2 Day
    [125468] = {
        ["craftSkills"] = CRAFT_SKILLS_WOOD,
        ["duration"] = FIFTEEN_DAYS,
    },
    -- Crown Research Scroll, Woodworking, 7 Day
    [125469] = {
        ["craftSkills"] = CRAFT_SKILLS_WOOD,
        ["duration"] = SEVEN_DAYS,
    },
    -- Crown Research Scroll, All, 1 Day
    [125470] = {
        ["craftSkills"] = CRAFT_SKILLS_ALL,
        ["duration"] = ONE_DAY,
    },
    -- Crown Research Scroll, All, 2 Day
    [125471] = {
        ["craftSkills"] = CRAFT_SKILLS_ALL,
        ["duration"] = FIFTEEN_DAYS,
    },
    -- Crown Research Scroll, All, 7 Day
    [125472] = {
        ["craftSkills"] = CRAFT_SKILLS_ALL,
        ["duration"] = SEVEN_DAYS,
    },
    -- Research Scroll, Blacksmithing, 1 Day
    [125473] = {
        ["craftSkills"] = CRAFT_SKILLS_SMITH,
        ["duration"] = ONE_DAY,
    },
    -- Research Scroll, Clothing, 1 Day
    [125474] = {
        ["craftSkills"] = CRAFT_SKILLS_CLOTH,
        ["duration"] = ONE_DAY,
    },
    -- Research Scroll, Woodworking, 1 Day
    [125475] = {
        ["craftSkills"] = CRAFT_SKILLS_WOOD,
        ["duration"] = ONE_DAY,
    },
    -- Character BOP Crown Research Scroll, All, 1 Day
    [135124] = {
        ["craftSkills"] = CRAFT_SKILLS_ALL,
        ["duration"] = ONE_DAY,
    },
    -- Research Scroll, Jewelry Crafting, 1 Day
    [138814] = {
        ["craftSkills"] = CRAFT_SKILLS_JEWELRY,
        ["duration"] = ONE_DAY,
    },
    -- Crown Research Scroll, Jewelry Crafting, 1 Day
    [139056] = {
        ["craftSkills"] = CRAFT_SKILLS_JEWELRY,
        ["duration"] = ONE_DAY,
    },
    -- Crown Research Scroll, Jewelry Crafting, 7 Day
    [139057] = {
        ["craftSkills"] = CRAFT_SKILLS_JEWELRY,
        ["duration"] = SEVEN_DAYS,
    },
    -- Crown Research Scroll, Jewelry Crafting, 15 Day
    [139058] = {
        ["craftSkills"] = CRAFT_SKILLS_JEWELRY,
        ["duration"] = FIFTEEN_DAYS,
    },
}
addon.researchScrolls = researchScrolls
local activeResearchLines = { }
local knownTraits = { }
addon.knownTraits = knownTraits

local function GetItemIdFromLink(itemLink)
    local itemId = select(4, ZO_LinkHandler_ParseLink(itemLink))
    if itemId and itemId ~= "" then
        return tonumber(itemId)
    end
end
local function LookupResearchScroll(itemLink)
    if not itemLink then return end
    local itemId
    if type(itemLink) == "number" then
        itemId = itemLink
    else
        itemId = GetItemIdFromLink(itemLink)
        if not itemId then return end
    end
    local researchScroll = researchScrolls[itemId]
    return researchScroll
end
local function MarkResearchActive(craftSkill, researchLineIndex, traitIndex)
    table.insert(activeResearchLines[craftSkill], { researchLineIndex = researchLineIndex, traitIndex = traitIndex })
end
local function MarkResearchComplete(craftSkill, researchLineIndex, traitIndex)
    for i=1,#activeResearchLines[craftSkill] do
        local activeResearch = activeResearchLines[craftSkill][i]
        if activeResearch.researchLineIndex == researchLineIndex and activeResearch.traitIndex == traitIndex then
            table.remove(activeResearchLines[craftSkill], i)
            break
        end
    end
    if not knownTraits[craftSkill] then
        knownTraits[craftSkill] = { }
    end
    if not knownTraits[craftSkill][researchLineIndex] then
        knownTraits[craftSkill][researchLineIndex] = { }
    end
    for _, knownTrait in ipairs(knownTraits[craftSkill][researchLineIndex]) do
        if knownTrait == traitIndex then 
            return
        end
    end
    table.insert(knownTraits[craftSkill][researchLineIndex], traitIndex )
end
function addon:GetIsResearchScroll(itemLink)
    local researchScroll = LookupResearchScroll(itemLink)
    if researchScroll then
        return true
    end
end
function addon:GetRemainingResearchSeconds(craftSkill, researchLineIndex, traitIndex)
    return select(2, GetSmithingResearchLineTraitTimes(craftSkill, researchLineIndex, traitIndex))
end
function addon:GetKnownResearchLineCount(craftSkill)
    local knownCount = 0
    if not knownTraits[craftSkill] then
        return knownCount
    end
    for researchLineIndex, researchLineKnownTraits in pairs(knownTraits[craftSkill]) do
        local researchLineTraitCount = select(3, GetSmithingResearchLineInfo(craftSkill, researchLineIndex))
        if #researchLineKnownTraits == researchLineTraitCount then
            knownCount = knownCount + 1
        end
    end
    return knownCount
end
function addon:GetScrollResearchData(itemLink)
    local researchScroll = LookupResearchScroll(itemLink)
    if not researchScroll then return end
    
    local requiredResearchCount
    local craftSkillCount = #researchScroll.craftSkills
    if craftSkillCount == 4 then
        requiredResearchCount = 10
    elseif craftSkillCount == 3 then
        requiredResearchCount = 9
    elseif researchScroll.craftSkills == CRAFT_SKILLS_JEWELRY then
        requiredResearchCount = 1
    else
        requiredResearchCount = 3
    end
    
    local scrollData = {
        ["craftSkills"]           = researchScroll.craftSkills,
        ["duration"]              = researchScroll.duration,
        ["requiredResearchCount"] = requiredResearchCount,
        ["activeResearchCount"]   = 0,
        ["warningResearchCount"]  = 0,
        ["activeResearch"]        = { },
    }
    for _, craftSkill in ipairs(researchScroll.craftSkills) do
        local skillResearch = activeResearchLines[craftSkill]
        if not skillResearch then return end
        local invalidResearchCount = 0
        for i = #skillResearch,1,-1 do
            local researchLineIndex = skillResearch[i].researchLineIndex
            local traitIndex        = skillResearch[i].traitIndex
            local secondsRemaining = addon:GetRemainingResearchSeconds(craftSkill, researchLineIndex, traitIndex)
            local known = select(3, GetSmithingResearchLineTraitInfo(craftSkill, researchLineIndex, traitIndex))
            if known then
                MarkResearchComplete(craftSkill, researchLineIndex, traitIndex)
            elseif secondsRemaining then
                local activeResearchTrait = {
                    ["researchLineIndex"]        = researchLineIndex,
                    ["traitIndex"]               = traitIndex,
                    ["secondsRemaining"]         = secondsRemaining,
                    ["longerThanScrollDuration"] = secondsRemaining > researchScroll.duration
                }
                scrollData.activeResearchCount = scrollData.activeResearchCount + 1
                if not activeResearchTrait.longerThanScrollDuration then
                    scrollData.warningResearchCount = scrollData.warningResearchCount + 1
                end
                if not scrollData.activeResearch[craftSkill] then
                    scrollData.activeResearch[craftSkill] = { }
                end
                table.insert(scrollData.activeResearch[craftSkill], activeResearchTrait)
            end
        end
    end
    return scrollData
end
function addon:GetWarningLine(itemLink)
    local scrollData
    if type(itemLink) == "table" then
        scrollData = itemLink
    else
        scrollData = self:GetScrollResearchData(itemLink)
        if not scrollData then
            return 
        end
    end
    local color
    if scrollData.activeResearchCount < scrollData.requiredResearchCount then
        color = COLOR_ERROR
    elseif scrollData.warningResearchCount > 0 then
        color = COLOR_WARNING
    else
        return
    end
    local durationDays = scrollData.duration / ONE_DAY
    local warningLine = GetString(SI_DETAILEDRESEARCHSCROLLS_WARNING)
    warningLine = zo_strformat(warningLine, scrollData.requiredResearchCount, durationDays)
    warningLine = color:Colorize(warningLine)
    return warningLine
end
local function AppendResearchStatusLine(line, text, color)
    return line .. "\n              "  .. color:Colorize(text)
end
function addon:GetResearchStatusLines(itemLink)
    local scrollData
    if type(itemLink) == "table" then
        scrollData = itemLink
    else
        scrollData = self:GetScrollResearchData(itemLink)
    end
    if not scrollData then
        return 
    end
    local lines = { }
    for _, craftSkill in ipairs(scrollData.craftSkills) do
        local craftSkillName = zo_strformat("<<1>>", GetCraftingSkillName(craftSkill))
        local knownCount = self:GetKnownResearchLineCount(craftSkill)
        local researchLineCount = GetNumSmithingResearchLines(craftSkill)
        local line = "      " .. COLOR_TITLE:Colorize(craftSkillName .. ":")
        
        if knownCount == researchLineCount then
            line = AppendResearchStatusLine(line, GetString(SI_SMITHING_RESEARCH_ALL_RESEARCHED), COLOR_ERROR)
        elseif researchLineCount - knownCount < CRAFTSKILL_SLOT_COUNTS[craftSkill] then
            line = AppendResearchStatusLine(line, 
                                            zo_strformat(GetString(SI_DETAILEDRESEARCHSCROLLS_ALL_TRAITS),
                                                         knownCount,
                                                         researchLineCount), 
                                            COLOR_WARNING)
        end
        local traits = scrollData.activeResearch[craftSkill]
        if traits and #traits > 0 then
            for i, trait in ipairs(traits) do
                local researchLineName = zo_strformat("<<1>>", GetSmithingResearchLineInfo(craftSkill, trait.researchLineIndex))
                local formattedTimeRemaining = ZO_FormatTime(trait.secondsRemaining, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
                local color
                if trait.secondsRemaining < scrollData.duration then
                    color = COLOR_WARNING
                else
                    color = COLOR_VALID
                end
                line = AppendResearchStatusLine(line, researchLineName .. ": ", COLOR_TOOLTIP) .. color:Colorize(formattedTimeRemaining)
            end
            for researchSlot=#traits + 1, CRAFTSKILL_SLOT_COUNTS[craftSkill] do
                line = AppendResearchStatusLine(line, zo_strformat(GetString(SI_DETAILEDRESEARCHSCROLLS_RESEARCH_SLOT_UNUSED), researchSlot), COLOR_ERROR)
            end
        elseif researchLineCount - knownCount >= CRAFTSKILL_SLOT_COUNTS[craftSkill] then
            line = AppendResearchStatusLine(line, GetString(SI_DETAILEDRESEARCHSCROLLS_NO_RESEARCH), COLOR_ERROR)
            
        end
        table.insert(lines, line)
    end
    return lines
end
function addon.PrintAllScrolls(parameters)
    local itemIds={}
    for itemId, _ in pairs(researchScrolls) do
      table.insert(itemIds, itemId)
    end
    table.sort(itemIds)
    for _, itemId in ipairs(itemIds) do
        d( "|H1:item:" .. tostring(itemId) .. ":124:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h" )
    end
end
local function TooltipAddLineLeftAligned(tooltipControl, line)
    local r, g, b = COLOR_TOOLTIP:UnpackRGB()
    tooltipControl:AddLine(line, "", r, g, b, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
end
local function TooltipHook(tooltipControl, method, linkFunc)
	local origMethod = tooltipControl[method]

	tooltipControl[method] = function(control, ...)
		origMethod(control, ...)
        local itemLink = linkFunc(...)
        local scrollData = addon:GetScrollResearchData(itemLink)
        local warningLine = addon:GetWarningLine(scrollData)
        if warningLine then
            control:AddVerticalPadding(8)
            ZO_Tooltip_AddDivider(control)
            control:AddLine(warningLine)
        end
        local statusLines = addon:GetResearchStatusLines(scrollData)
        if statusLines then
            control:AddVerticalPadding(8)
            if not warningLine then
                ZO_Tooltip_AddDivider(control)
            end
            for _, statusLine in ipairs(statusLines) do
                TooltipAddLineLeftAligned(control, statusLine)
            end
        end
	end
end

local function ReturnItemLink(itemLink)
	return itemLink
end
local function HookToolTips()
    TooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
    TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
    TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
    TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
    TooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
    TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
    TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
    TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
    TooltipHook(ItemTooltip, "SetLink", ReturnItemLink)
    TooltipHook(PopupTooltip, "SetLink", ReturnItemLink)
    --TODO: uncomment the following if ZOS every makes GetMarketProductItemLink() public instead of private
    --TooltipHook(ItemTooltip, "SetMarketProduct", GetMarketProductItemLink)
end
local function UpdateActiveResearchLines()
    for _, craftSkill in ipairs(CRAFT_SKILLS_ALL) do
        activeResearchLines[craftSkill] = { }
        -- Total number of research lines for this craft skill
        local researchLineCount = GetNumSmithingResearchLines(craftSkill)
        
        -- Loop through each research line (e.g. axe, mace, etc.)
        for researchLineIndex = 1, researchLineCount do
            
            -- Get the total number of traits in the research line
            local numTraits = select(3, GetSmithingResearchLineInfo(craftSkill, researchLineIndex))
            
            for traitIndex = 1, numTraits do
                local secondsRemaining = addon:GetRemainingResearchSeconds(craftSkill, researchLineIndex, traitIndex)
                local known = select(3, GetSmithingResearchLineTraitInfo(craftSkill, researchLineIndex, traitIndex))
                if known then
                    MarkResearchComplete(craftSkill, researchLineIndex, traitIndex)
                elseif secondsRemaining then
                    MarkResearchActive(craftSkill, researchLineIndex, traitIndex)
                    break
                end
            end
        end
    end
end
local function OnResearchStarted(eventCode, craftSkill, researchLineIndex, traitIndex)
    MarkResearchActive(craftSkill, researchLineIndex, traitIndex)
end
local function OnResearchCompleted(eventCode, craftSkill, researchLineIndex, traitIndex)
    MarkResearchComplete(craftSkill, researchLineIndex, traitIndex)
end
local function HookResearchEvents()
    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, OnResearchCompleted)
    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_SMITHING_TRAIT_RESEARCH_STARTED, OnResearchStarted)
    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_SMITHING_TRAIT_RESEARCH_TIMES_UPDATED, UpdateActiveResearchLines)
    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_SKILLS_FULL_UPDATE, UpdateActiveResearchLines)
    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, UpdateActiveResearchLines)
end
local function OnAddonLoaded(event, name)
    if name ~= addon.name then return end
    EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
    HookResearchEvents()
    HookToolTips()
    SLASH_COMMANDS["/printresearchscrolls"] = addon.PrintAllScrolls
end
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)