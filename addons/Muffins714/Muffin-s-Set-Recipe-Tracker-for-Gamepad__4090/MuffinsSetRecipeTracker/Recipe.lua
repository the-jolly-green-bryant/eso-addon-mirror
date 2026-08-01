-- Create a local shortcut for global
local MSRT = MuffinsSetRecipeTracker

-- Dependencies
local LCK = LibCharacterKnowledge

-- Custom Tooltip Object
local MSRT_custom_tooltip2 = ZO_InitializingObject:Subclass()

function MSRT_custom_tooltip2:Initialize(parent)
    self.anchors = {}
    self.parent = parent
    self.root = parent:GetNamedChild('Tip')

    table.insert(self.anchors, ZO_Anchor:New(select(2, self.root:GetAnchor(0))))
    table.insert(self.anchors, ZO_Anchor:New(select(2, self.root:GetAnchor(1))))

    -- Create a tooltip below the base Gamepad tooltip
    self.control = CreateControlFromVirtual("$(parent)MSRTTooltip2", parent, "MSRT_GamepadTooltip2")
    self.control:SetWidth(parent:GetWidth())
    table.insert(self.anchors, ZO_Anchor:New(BOTTOMRIGHT, self.control, TOPRIGHT, 0, 0))

    parent.knowledgeTooltip = self
    self.tooltip = self.control:GetNamedChild("Tip")
    ZO_Tooltip:Initialize(self.tooltip, ZO_TOOLTIP_STYLES)

    ZO_PostHookHandler(self.parent, "OnEffectivelyHidden", function()
        self:Reset()
    end)

    if self.parent.tip and self.parent.tip.ClearLines then
        local original_ClearLines = self.parent.tip.ClearLines
        self.parent.tip.ClearLines = function(tip, ...)
            original_ClearLines(tip, ...)
            self:Reset()
        end
    end
end

-- Tooltip Layout Logic
function MSRT_custom_tooltip2:Layout(itemLink)
    self.tooltip:ClearLines()

    ---------------------------------------------------------------------------------------------
    -- Character
    ---------------------------------------------------------------------------------------------

    -- Figure out which character to use
    local settings      = MSRT.GetSettings()
    local characterList = LCK.GetCharacterList()

    -- Select character
    local selectedCharId
    for _, char in ipairs(characterList) do
        if zo_strformat("<<1>>", char.name) == settings.selectedCharName then
            selectedCharId = char.id
            break
        end
    end
    if not selectedCharId then
        selectedCharId = characterList[1].id
        settings.selectedCharName = zo_strformat("<<1>>", characterList[1].name)
    end

    -- figure out which character ID were going to use
    local currentCharId = GetCurrentCharacterId()
    local selChar = MSRT.GetSettings().useSelectedMotif and selectedCharId or currentCharId

    -- Show the name not ID
    local displayName = ""
    for _, entry in ipairs(characterList) do
        if entry.id == tostring(selChar) then
            displayName = zo_strformat("<<1>>", entry.name)
            break
        end
    end
    if displayName == "" then
        displayName = zo_strformat("<<1>>", GetUnitName("player"))
    end

    ---------------------------------------------------------------------------------------------
    -- Motifs
    ---------------------------------------------------------------------------------------------

    -- Motif and KNOWN BY section
    local motifSection, chapterSection

    local knowledgeList = LCK.GetItemKnowledgeList(itemLink)
    if not knowledgeList or #knowledgeList == 0 then
        return
    end

    -- Is this a motif
    local category = LCK.GetItemCategory(itemLink)
    if category == LCK.ITEM_CATEGORY_MOTIF then
        local styleId, _ = LCK.GetStyleAndChapterFromMotif(itemLink)
        if styleId and styleId > 0 then
            local motifData         = LCK.GetMotifItemsFromStyle(styleId)
            local chapterInfoList   = LCK.GetMotifChapterNames()
            local chapterPage       = {}
            local total, knownCount = 0, 0

            for _, ch in ipairs(chapterInfoList) do
                local itemId = motifData.chapters[ch.id]
                if itemId then
                    total = total + 1
                    local know = LCK.GetMotifKnowledgeForCharacter(styleId, ch.id, nil, selChar)
                    if know == LCK.KNOWLEDGE_KNOWN then
                        chapterPage[#chapterPage + 1] = ZO_ColorDef:New(0.2, 1, 0.2):Colorize(ch.name)
                        -- Green for known (light green)
                        knownCount = knownCount + 1
                    else
                        chapterPage[#chapterPage + 1] = ZO_ColorDef:New(1, 0.2, 0.2):Colorize(ch.name)
                        -- Red for unknown (light red)
                    end
                end
            end

            -- Tooltip section
            if total > 0 then
                motifSection = self.tooltip:AcquireSection(self.tooltip:GetStyle("msrtGamepadSection2"))
                local nicknames = (MSRT.GetSettings().charNicknames or {})
                local displayNickname = (settings.useNicknames and nicknames[displayName]) or displayName
                motifSection:AddLine(string.format("%s (%d/%d)", displayNickname, knownCount, total),
                    self.tooltip:GetStyle("bodyHeader"))
                self.tooltip:AddSection(motifSection)

                chapterSection = self.tooltip:AcquireSection(self.tooltip:GetStyle("msrtGamepadSection2"))
                chapterSection:AddLine(table.concat(chapterPage, ", "), {
                    fontSize = "$(GP_20)",
                    fontColor = ZO_ColorDef:New(1, 1, 1),
                    wrapText = true,
                    horizontalAlignment = TEXT_ALIGN_CENTER
                })
                self.tooltip:AddSection(chapterSection)
            end
        end
    end

    ---------------------------------------------------------------------------------------------
    -- KNOWN BY section
    ---------------------------------------------------------------------------------------------

    local known = 0
    local names = {}
    for _, char in ipairs(knowledgeList) do
        local settings        = MSRT.GetSettings()
        local nicknames       = settings.charNicknames or {}
        local cleanName       = zo_strformat("<<1>>", char.name)
        local displayCharName = (settings.useNicknames and nicknames[cleanName]) or cleanName
        local name            = (char.id == currentCharId) and ("* " .. displayCharName .. " *") or displayCharName
        -- Blue for known (light blue)
        if char.knowledge == LCK.KNOWLEDGE_KNOWN then
            table.insert(names, ZO_ColorDef:New(0.25, 0.75, 1):Colorize(name))
            known = known + 1
        elseif char.knowledge == LCK.KNOWLEDGE_UNKNOWN then
            table.insert(names, ZO_ColorDef:New(0.5, 0.5, 0.5):Colorize(name))
            -- Grey for unknown
        end
    end

    local section = self.tooltip:AcquireSection(self.tooltip:GetStyle("msrtGamepadSection2"))
    section:AddLine(string.format("KNOWN BY (%d/%d)", known, #knowledgeList), self.tooltip:GetStyle("bodyHeader"))
    self.tooltip:AddSection(section)

    local namesSection = self.tooltip:AcquireSection(self.tooltip:GetStyle("msrtGamepadSection2"))
    namesSection:AddLine(table.concat(names, ", "), {
        fontSize = "$(GP_20)",
        fontColor = ZO_ColorDef:New(1, 1, 1),
        wrapText = true,
        horizontalAlignment = TEXT_ALIGN_CENTER,
    })
    self.tooltip:AddSection(namesSection)
    namesSection:AddLine('', self.tooltip:GetStyle("verticalPadding"))

    ---------------------------------------------------------------------------------------------
    -- Tooltip and Styles
    ---------------------------------------------------------------------------------------------

    self:SetAnchors()
    self.control:SetHidden(false)

    -- Adjust height based on content
    local height = 0
    if motifSection then height = height + motifSection:GetPrimaryDimension() end
    if chapterSection then height = height + chapterSection:GetPrimaryDimension() end

    height = height
        + section:GetPrimaryDimension()
        + namesSection:GetPrimaryDimension()

    self.control:SetHeight(height)
end

function MSRT_custom_tooltip2:Reset()
    self.control:SetHidden(true)
    self.root:ClearAnchors()
    self.anchors[1]:AddToControl(self.root)
    self.anchors[2]:AddToControl(self.root)
end

function MSRT_custom_tooltip2:SetAnchors()
    self.root:ClearAnchors()
    self.anchors[1]:AddToControl(self.root)
    self.anchors[3]:AddToControl(self.root)
end

ZO_TOOLTIP_STYLES.msrtGamepadSection2 = {
    paddingTop = 0,
    customSpacing = 5,
    fontSize = "$(GP_20)",
    fontFace = "$(GAMEPAD_MEDIUM_FONT)",
    fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1,
    uppercase = false,
    widthPercent = 100,
    horizontalAlignment = TEXT_ALIGN_CENTER,
}

ZO_TOOLTIP_STYLES.verticalPadding = {
    customSpacing = 10,
    widthPercent = 100,
}

local function getTooltip(container)
    if not container.knowledgeTooltip then
        container.knowledgeTooltip = MSRT_custom_tooltip2:New(container)
    end
    return container.knowledgeTooltip
end

local function HookTooltip(functionName, getLinkFunc)
    local orig = GAMEPAD_TOOLTIPS[functionName]
    GAMEPAD_TOOLTIPS[functionName] = function(self, tooltipType, ...)
        GAMEPAD_TOOLTIPS.currentLayoutFunctionName = functionName
        local result = orig(self, tooltipType, ...)
        local container = self:GetTooltipContainer(tooltipType)
        if container then
            local tip = getTooltip(container)
            tip:Layout(getLinkFunc(...))
        end
        return result
    end
end

function MSRT_Initialize2()
    if not LCK then return end
    HookTooltip("LayoutItem", function(link) return link end)
    HookTooltip("LayoutBagItem", function(bag, slot) return GetItemLink(bag, slot) end)
    HookTooltip("LayoutGuildStoreSearchResult", function(link) return link end)
    HookTooltip("LayoutLink", function(link, ...) return link end)
    HookTooltip("LayoutStoreWindowItem", function(buyData) return buyData and buyData.itemLink end)
end
