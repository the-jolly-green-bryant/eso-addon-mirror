local FSC = FlamechasersSpellcheck

local DEFAULTS = FSC.DEFAULT_SETTINGS

local APPEARANCE_KEYS = {
    "underlineOpacity",
    "underlineColor",
    "suggestionStyle",
    "suggestionHeight",
    "suggestionFont",
    "suggestionTextScale",
    "suggestionTextColor",
    "suggestionSelectedColor",
    "suggestionBackgroundOpacity",
    "suggestionDividerOpacityPercent",
}

local FONT_CHOICES = {
    "ESO Game (default)",
    "Consolas",
    "Futura Condensed",
    "Futura Condensed Bold",
    "Futura Condensed Light",
    "Prose Antique",
    "Skyrim Handwritten",
    "Trajan Pro",
    "Univers 55",
    "Univers 57",
    "Univers 67",
    "ESO Game Small",
    "ESO Chat",
    "ESO Edit",
}

local FONT_VALUES = {
    "ZoFontGame",
    "$(CONSOLAS_FONT)|18|soft-shadow-thin",
    "$(FTN57_FONT)|18|soft-shadow-thin",
    "$(FTN87_FONT)|18|soft-shadow-thin",
    "$(FTN47_FONT)|18|soft-shadow-thin",
    "$(PROSE_ANTIQUE_FONT)|18|soft-shadow-thin",
    "$(HANDWRITTEN_BOLD_FONT)|18|soft-shadow-thin",
    "$(TRAJAN_PRO_R_FONT)|18|soft-shadow-thin",
    "$(UNIVERS55_FONT)|18|soft-shadow-thin",
    "$(UNIVERS57_FONT)|18|soft-shadow-thin",
    "$(UNIVERS67_FONT)|18|soft-shadow-thin",
    "ZoFontGameSmall",
    "ZoFontEditChat",
    "ZoFontEdit",
}

local STYLE_CHOICES = {
    "Prediction bar",
    "Rounded boxes",
}

local STYLE_VALUES = {
    "bar",
    "boxes",
}

local function CopyValue(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[key] = CopyValue(child) end
    return result
end

local function SettingsTable(self)
    if not self.saved then return DEFAULTS end
    self.saved.settings = self.saved.settings or {}
    local settings = self.saved.settings
    for key, value in pairs(DEFAULTS) do
        if settings[key] == nil then settings[key] = CopyValue(value) end
    end
    return settings
end

function FSC:GetSetting(key)
    local settings = SettingsTable(self)
    local value = settings[key]
    if value == nil then return DEFAULTS[key] end
    return value
end

function FSC:SetSetting(key, value)
    SettingsTable(self)[key] = value
end

function FSC:IsSpellcheckEnabled()
    return self:GetSetting("spellcheckEnabled") ~= false
end

function FSC:IsAutocompleteEnabled()
    return self:GetSetting("suggestionsEnabled") ~= false
end

function FSC:GetSuggestionIntelligence()
    local value=tostring(self:GetSetting("suggestionIntelligence") or DEFAULTS.suggestionIntelligence)
    return value=="super" and "super" or "standard"
end

function FSC:IsSuperSuggestionsEnabled()
    return self:GetSuggestionIntelligence()=="super"
end

function FSC:IsSuperConversationContextEnabled()
    return self:GetSetting("superConversationContext") ~= false
end

function FSC:IsPersonalizationEnabled()
    return self:GetSetting("personalizationEnabled") ~= false
end

function FSC:IsCorrectionLearningEnabled()
    return self:GetSetting("correctionLearningEnabled") ~= false
end

function FSC:GetUnderlineAlpha()
    return math.max(0, math.min(1, (tonumber(self:GetSetting("underlineOpacity")) or 78) / 100))
end

local function GetColor(self, key, fallback)
    local value = self:GetSetting(key)
    if type(value) ~= "table" then value = fallback end
    local r = tonumber(value.r or value[1]) or fallback.r
    local g = tonumber(value.g or value[2]) or fallback.g
    local b = tonumber(value.b or value[3]) or fallback.b
    local a = tonumber(value.a or value[4]) or fallback.a or 1
    return math.max(0, math.min(1, r)), math.max(0, math.min(1, g)), math.max(0, math.min(1, b)), math.max(0, math.min(1, a))
end

function FSC:SetColorSetting(key, r, g, b, a)
    self:SetSetting(key, {
        r = math.max(0, math.min(1, tonumber(r) or 1)),
        g = math.max(0, math.min(1, tonumber(g) or 1)),
        b = math.max(0, math.min(1, tonumber(b) or 1)),
        a = math.max(0, math.min(1, tonumber(a) or 1)),
    })
end

function FSC:GetUnderlineColor()
    return GetColor(self, "underlineColor", DEFAULTS.underlineColor)
end

function FSC:GetSuggestionTextColor()
    return GetColor(self, "suggestionTextColor", DEFAULTS.suggestionTextColor)
end

function FSC:GetSuggestionSelectedColor()
    return GetColor(self, "suggestionSelectedColor", DEFAULTS.suggestionSelectedColor)
end

function FSC:GetSuggestionStyle()
    local value = tostring(self:GetSetting("suggestionStyle") or DEFAULTS.suggestionStyle)
    return value == "boxes" and "boxes" or "bar"
end

function FSC:GetSuggestionHeight()
    return math.max(20, math.min(30, math.floor((tonumber(self:GetSetting("suggestionHeight")) or DEFAULTS.suggestionHeight) + 0.5)))
end

function FSC:GetSuggestionFont()
    local value = tostring(self:GetSetting("suggestionFont") or DEFAULTS.suggestionFont)
    for _, valid in ipairs(FONT_VALUES) do
        if value == valid then return value end
    end
    return DEFAULTS.suggestionFont
end

function FSC:GetSuggestionTextScale()
    return math.max(0.75, math.min(1.10, (tonumber(self:GetSetting("suggestionTextScale")) or 90) / 100))
end

function FSC:GetSuggestionBackgroundOpacity()
    return math.max(0, math.min(1, (tonumber(self:GetSetting("suggestionBackgroundOpacity")) or 100) / 100))
end

function FSC:GetSuggestionDividerAlpha()
    return math.max(0, math.min(1, (tonumber(self:GetSetting("suggestionDividerOpacityPercent")) or DEFAULTS.suggestionDividerOpacityPercent) / 100))
end

function FSC:ResetAppearanceSettings()
    local settings = SettingsTable(self)
    for _, key in ipairs(APPEARANCE_KEYS) do
        settings[key] = CopyValue(DEFAULTS[key])
    end
    self:ApplySettingsNow()
end

function FSC:ApplySettingsNow()
    self:ApplyAppearanceSettings()
    self:ApplyChatUtilityBarLayout()
    self.suggestionCache = {}
    self.suggestionCacheCount = 0
    self.superPredictionCacheKey = nil
    self.superPredictionCacheResults = nil
    -- Enabling/disabling the two primary features should take effect immediately.
    -- With both disabled, UI.lua restores ESO's untouched EditBox and unregisters
    -- its active-input poll/mouse callbacks instead of idling in the background.
    if self.UpdateChatInputActivity then self:UpdateChatInputActivity() end
    self:ScheduleRefresh(0)
end

local function CountMap(map)
    local count = 0
    for _ in pairs(map or {}) do count = count + 1 end
    return count
end

function FSC:GetPersonalDictionaryCount()
    return CountMap(self.saved and self.saved.userWords)
end

function FSC:GetPersonalDictionaryWords()
    local words = {}
    for word in pairs(self.saved and self.saved.userWords or {}) do
        words[#words + 1] = word
    end
    table.sort(words, function(a, b) return string.lower(a) < string.lower(b) end)
    return words
end

function FSC:GetLearnedSuggestionCount()
    local store = self.saved and self.saved.autocomplete
    return store and CountMap(store.unigrams) or 0
end

function FSC:GetLearnedCorrectionCount()
    local store = self.saved and self.saved.correctionLearning
    return store and CountMap(store.pairs) or 0
end

function FSC:ResetLearnedLanguageData()
    if not self.saved then return end
    self.saved.autocomplete = {
        unigrams = {},
        bigrams = {},
        trigrams = {},
        fourgrams = {},
        learnedMessages = 0,
    }
    self.saved.correctionLearning = {
        pairs = {},
        acceptances = 0,
    }
    self.personalAutocompletePrefixIndex = nil
    self.superAutocompleteSession = nil
    self.superPredictionCacheKey = nil
    self.superPredictionCacheResults = nil
    self.suggestionCache = {}
    self.suggestionCacheCount = 0
    self:ScheduleRefresh(0)
end

function FSC:ClearPersonalDictionary()
    if not self.saved then return end
    self.saved.userWords = {}
    self.settingsDictionarySelections = {}
    self:InvalidateAutocompleteCaches()
    self:InvalidateInputLayoutCaches()
    self:ScheduleRefresh(0)
end

local function RefreshSettingsPanel()
    if FSC.settingsPanel then
        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", FSC.settingsPanel)
    end
end

local function Message(text)
    d(string.format("|cD6A7FF%s|r: %s", FSC.shortDisplayName or "Spellcheck", tostring(text)))
end

local function GetLAM()
    return LibAddonMenu2
end

local function IsDictionaryWordSelected(word)
    for _, selected in ipairs(FSC.settingsDictionarySelections or {}) do
        if selected == word then return true end
    end
    return false
end

local function ToggleDictionaryWordSelection(word)
    local selections = FSC.settingsDictionarySelections or {}
    for index, selected in ipairs(selections) do
        if selected == word then
            table.remove(selections, index)
            FSC.settingsDictionarySelections = selections
            return
        end
    end
    selections[#selections + 1] = word
    FSC.settingsDictionarySelections = selections
end

local function RefreshDictionaryControl(clearSelection)
    if clearSelection then FSC.settingsDictionarySelections = {} end
    local control = FSC.settingsDictionaryListBox
    if control and control.RefreshWords then control:RefreshWords() end
end

local function CreateDictionaryListBox(customControl)
    local ROW_HEIGHT = 26
    local LIST_HEIGHT = 184
    local wm = WINDOW_MANAGER

    FSC.settingsDictionaryListBox = customControl
    customControl.dictionaryRows = customControl.dictionaryRows or {}

    local title = wm:CreateControl(nil, customControl, CT_LABEL)
    title:SetAnchor(TOPLEFT, customControl, TOPLEFT, 0, 0)
    title:SetFont("ZoFontWinH4")
    title:SetText("Saved words")
    title:SetColor(0.82, 0.82, 0.82, 1)
    customControl.dictionaryTitle = title

    local frame = wm:CreateControl(nil, customControl, CT_BACKDROP)
    frame:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 6)
    frame:SetAnchor(TOPRIGHT, customControl, TOPRIGHT, 0, 26)
    frame:SetHeight(LIST_HEIGHT)
    frame:SetCenterTexture("EsoUI/Art/Tooltips/UI-Tooltip-Center.dds")
    frame:SetCenterColor(0.02, 0.02, 0.02, 0.72)
    customControl.dictionaryFrame = frame

    local scroll = wm:CreateControlFromVirtual(nil, frame, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, frame, TOPLEFT, 5, 5)
    scroll:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -5, -5)
    ZO_Scroll_SetUseFadeGradient(scroll, false)
    customControl.dictionaryScroll = scroll

    local child = scroll:GetNamedChild("ScrollChild")
    customControl.dictionaryScrollChild = child

    local emptyLabel = wm:CreateControl(nil, child, CT_LABEL)
    emptyLabel:SetAnchor(TOPLEFT, child, TOPLEFT, 8, 6)
    emptyLabel:SetFont("ZoFontGame")
    emptyLabel:SetColor(0.55, 0.55, 0.55, 1)
    emptyLabel:SetText("No saved words")
    emptyLabel:SetHidden(true)
    customControl.dictionaryEmptyLabel = emptyLabel

    function customControl:RefreshWords()
        local words = FSC:GetPersonalDictionaryWords()
        local childControl = self.dictionaryScrollChild
        if not childControl then return end

        -- ZO_ScrollContainer does not guarantee a useful ScrollChild width for
        -- custom LAM controls. Without an explicit width the row starts at x=0
        -- (so the selection marker is visible) but the word label is squeezed to
        -- essentially zero pixels. Resolve the width from the finished LAM control
        -- every refresh so this also survives UI-scale changes and panel resizing.
        local frameWidth = self.dictionaryFrame and self.dictionaryFrame:GetWidth() or 0
        local controlWidth = self:GetWidth() or 0
        local contentWidth = math.max(120, (frameWidth > 30 and frameWidth or controlWidth) - 22)
        childControl:SetWidth(contentWidth)

        self.dictionaryEmptyLabel:SetHidden(#words > 0)
        childControl:SetHeight(math.max(LIST_HEIGHT - 10, #words * ROW_HEIGHT + 4))

        for index, word in ipairs(words) do
            local row = self.dictionaryRows[index]
            if not row then
                row = wm:CreateControl(nil, childControl, CT_BUTTON)
                row:SetHeight(ROW_HEIGHT)
                row:SetMouseEnabled(true)

                local highlight = wm:CreateControl(nil, row, CT_TEXTURE)
                highlight:SetAnchorFill(row)
                highlight:SetTexture("EsoUI/Art/Buttons/Generic_Highlight.dds")
                highlight:SetColor(0.55, 0.72, 1.00, 1)
                highlight:SetAlpha(0)
                highlight:SetMouseEnabled(false)
                row.highlight = highlight

                local marker = wm:CreateControl(nil, row, CT_LABEL)
                marker:SetAnchor(LEFT, row, LEFT, 5, 0)
                marker:SetDimensions(28, ROW_HEIGHT)
                marker:SetFont("ZoFontGameSmall")
                marker:SetVerticalAlignment(TEXT_ALIGN_CENTER)
                marker:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                marker:SetMouseEnabled(false)
                row.marker = marker

                local label = wm:CreateControl(nil, row, CT_LABEL)
                label:SetAnchor(LEFT, marker, RIGHT, 3, 0)
                label:SetAnchor(RIGHT, row, RIGHT, -6, 0)
                label:SetHeight(ROW_HEIGHT)
                label:SetFont("ZoFontGame")
                label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
                label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
                label:SetMouseEnabled(false)
                row.label = label

                row:SetHandler("OnMouseEnter", function(self)
                    self.mouseOver = true
                    self:RefreshVisual()
                end)
                row:SetHandler("OnMouseExit", function(self)
                    self.mouseOver = false
                    self:RefreshVisual()
                end)
                row:SetHandler("OnClicked", function(self)
                    if not self.word then return end
                    ToggleDictionaryWordSelection(self.word)
                    RefreshSettingsPanel()
                end)

                function row:RefreshVisual()
                    local selected = self.word and IsDictionaryWordSelected(self.word)
                    self.marker:SetText(selected and "[x]" or "[ ]")
                    self.marker:SetColor(selected and 1.00 or 0.62, selected and 0.84 or 0.62, selected and 0.40 or 0.62, 1)
                    self.label:SetColor(selected and 1.00 or 0.84, selected and 0.92 or 0.84, selected and 0.62 or 0.84, 1)
                    self.highlight:SetAlpha(selected and 0.24 or (self.mouseOver and 0.10 or 0))
                end

                self.dictionaryRows[index] = row
            end

            row.word = word
            row.label:SetText(word)
            row:ClearAnchors()
            row:SetAnchor(TOPLEFT, childControl, TOPLEFT, 0, (index - 1) * ROW_HEIGHT)
            row:SetDimensions(math.max(100, contentWidth - 4), ROW_HEIGHT)
            row:SetHidden(false)
            row:RefreshVisual()
        end

        for index = #words + 1, #self.dictionaryRows do
            self.dictionaryRows[index]:SetHidden(true)
        end
    end

    customControl:RefreshWords()
    zo_callLater(function()
        if customControl.RefreshWords then customControl:RefreshWords() end
    end, 0)
end

local function NormalizeMenuText(text)
    text = tostring(text or "")
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    return string.lower(text)
end

function FSC:OpenKeybindSettings()
    local function SelectKeybindingsEntry()
        local gameMenu = ZO_GameMenu_InGame and ZO_GameMenu_InGame.gameMenu
        local controlsName = GetString(SI_GAME_MENU_CONTROLS)
        local standardKeybindingsName = GetString(SI_GAME_MENU_KEYBINDINGS)
        local controlsNode = gameMenu and gameMenu.headerControls and controlsName and gameMenu.headerControls[controlsName] or nil

        local fallbackNode = nil
        if controlsNode and controlsNode.GetChildren then
            local children = controlsNode:GetChildren()
            for index = 1, (children and #children or 0) do
                local childNode = children[index]
                local data = childNode and childNode.GetData and childNode:GetData() or nil
                local name = data and data.name or nil
                local normalized = NormalizeMenuText(name)

                -- libAddonKeybinds inserts two children under Controls:
                -- "Standard Keybinds" and "Addon Keybinds". Select the latter
                -- explicitly instead of using SI_GAME_MENU_KEYBINDINGS, which is the
                -- standard entry and caused v0.5.3 to land on the wrong page.
                if normalized:find("addon", 1, true) and normalized:find("keybind", 1, true) then
                    childNode:GetTree():SelectNode(childNode)
                    return
                end

                if standardKeybindingsName and name == standardKeybindingsName then
                    fallbackNode = childNode
                end
            end
        end

        -- If libAddonKeybinds is not installed, there is no separate Addon Keybinds
        -- entry. Fall back to ESO's normal keybindings page so the button remains useful.
        if fallbackNode then
            fallbackNode:GetTree():SelectNode(fallbackNode)
        elseif KEYBINDINGS_FRAGMENT then
            SCENE_MANAGER:AddFragment(KEYBINDINGS_FRAGMENT)
        end
    end

    local scene = SCENE_MANAGER:GetScene("gameMenuInGame")
    if scene and scene:GetState() == SCENE_SHOWN then
        SelectKeybindingsEntry()
    elseif SCENE_MANAGER.CallWhen then
        SCENE_MANAGER:CallWhen("gameMenuInGame", SCENE_SHOWN, SelectKeybindingsEntry)
        SCENE_MANAGER:Show("gameMenuInGame")
    else
        SCENE_MANAGER:Show("gameMenuInGame")
        zo_callLater(SelectKeybindingsEntry, 0)
    end
end

function FSC:OpenSettingsPanel()
    local LAM = GetLAM()
    if not self.settingsPanel then self:RegisterSettings() end
    if self.settingsPanel then LAM:OpenToPanel(self.settingsPanel) end
end

function FSC:RegisterChatCogSettingsEntry()
    if self.chatCogSettingsHooked then return end

    ZO_PostHook("ZO_ChatSystem_ShowOptions", function(control)
        local owner = GetMenuOwner()
        AddCustomMenuItem("Spellcheck Settings", function()
            FSC:OpenSettingsPanel()
        end)
        ShowMenu(owner or control)
    end)

    self.chatCogSettingsHooked = true
end

function FSC:RegisterSettings()
    if self.settingsRegistered then return end

    local LAM = GetLAM()

    local panelData = {
        type = "panel",
        name = self.displayName,
        displayName = self.displayName,
        author = "Flamechasers",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    self.settingsPanel = LAM:RegisterAddonPanel("FlamechasersSpellcheckSettings", panelData)

    local function SetAndApply(key, value)
        FSC:SetSetting(key, value)
        FSC:ApplySettingsNow()
    end

    local function SetColorAndApply(key, r, g, b, a)
        FSC:SetColorSetting(key, r, g, b, a)
        FSC:ApplySettingsNow()
    end

    local options = {
        {
            type = "description",
            text = "Spellcheck and predictive text built directly into ESO chat. Changes on this page apply immediately.",
            width = "full",
        },
        {
            type = "header",
            name = "General",
        },
        {
            type = "checkbox",
            name = "Enable spell checking",
            tooltip = "Show wave underlines and enable the right-click correction menu for misspelled words.",
            getFunc = function() return FSC:IsSpellcheckEnabled() end,
            setFunc = function(value) SetAndApply("spellcheckEnabled", value) end,
            default = DEFAULTS.spellcheckEnabled,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable typing suggestions",
            tooltip = "Show three predictive word suggestions above the chat input.",
            getFunc = function() return FSC:IsAutocompleteEnabled() end,
            setFunc = function(value) SetAndApply("suggestionsEnabled", value) end,
            default = DEFAULTS.suggestionsEnabled,
            width = "full",
        },

        {
            type = "header",
            name = "Suggestion Intelligence",
        },
        {
            type = "dropdown",
            name = "Prediction mode",
            tooltip = "Normal is the more lightweight predictor. SUPER is the default and adds heavier context-aware ranking, a four-word personal language model, recency memory, and live conversation context. Switch to Normal at any time if you prefer the lower-cost mode.",
            choices = { "Normal", "SUPER" },
            -- Keep the saved value "standard" for compatibility; the user-facing name is Normal.
            choicesValues = { "standard", "super" },
            getFunc = function() return FSC:GetSuggestionIntelligence() end,
            setFunc = function(value)
                SetAndApply("suggestionIntelligence", value)
                FSC.superPredictionCacheKey = nil
                FSC.superPredictionCacheResults = nil
                RefreshSettingsPanel()
            end,
            default = DEFAULTS.suggestionIntelligence,
            disabled = function() return not FSC:IsAutocompleteEnabled() end,
            width = "full",
        },
        {
            type = "description",
            text = "SUPER is the default prediction mode. It uses up to the previous three words, learns four-word phrase patterns from messages you actually send, remembers recent vocabulary during the current play session, and blends those signals with the currently enabled dictionaries, typo tolerance and your personal history. It becomes more personalized as you use it, while your existing Normal-mode learning still contributes. Normal is the more lightweight fallback if you prefer lower processing cost.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Use recent chat as temporary context",
            tooltip = "In SUPER mode, recent player chat can temporarily boost words and phrase patterns related to the current conversation. Other players' messages are kept only in memory for this play session and are never written to SavedVariables. Your own sent messages can still be learned permanently when Personalized suggestions is enabled.",
            getFunc = function() return FSC:IsSuperConversationContextEnabled() end,
            setFunc = function(value)
                SetAndApply("superConversationContext", value)
                if not value then FSC.superAutocompleteSession = nil end
            end,
            default = DEFAULTS.superConversationContext,
            disabled = function() return not FSC:IsAutocompleteEnabled() or not FSC:IsSuperSuggestionsEnabled() end,
            width = "full",
        },

        {
            type = "header",
            name = "Suggestion Controls",
        },
        {
            type = "description",
            text = "Default chat controls: TAB accepts the selected suggestion and CTRL navigates through the suggestions. These defaults always keep working while the chat input is open, even after you assign additional addon keybinds below.",
            width = "full",
        },
        {
            type = "button",
            name = "Set accept keybind",
            tooltip = "Opens Controls directly on Addon Keybinds. Under Flamechasers, bind 'Accept suggested word'. TAB will still work while chat is open.",
            func = function() FSC:OpenKeybindSettings() end,
            width = "half",
        },
        {
            type = "button",
            name = "Set navigation keybind",
            tooltip = "Opens Controls directly on Addon Keybinds. Under Flamechasers, bind 'Navigate suggestions'. CTRL will still work while chat is open.",
            func = function() FSC:OpenKeybindSettings() end,
            width = "half",
        },

        {
            type = "header",
            name = "Appearance",
        },
        {
            type = "dropdown",
            name = "Suggestion style",
            tooltip = "Prediction bar uses the current integrated strip. Rounded boxes shows three separate compact suggestion boxes.",
            choices = STYLE_CHOICES,
            choicesValues = STYLE_VALUES,
            getFunc = function() return FSC:GetSuggestionStyle() end,
            setFunc = function(value)
                SetAndApply("suggestionStyle", value)
                RefreshSettingsPanel()
            end,
            default = DEFAULTS.suggestionStyle,
            disabled = function() return not FSC:IsAutocompleteEnabled() end,
            width = "full",
        },
        {
            type = "slider",
            name = "Suggestion height",
            tooltip = "Adjusts the height of the prediction bar or rounded boxes. The range is intentionally limited to keep the chat UI safe.",
            min = 20,
            max = 30,
            step = 1,
            getFunc = function() return FSC:GetSuggestionHeight() end,
            setFunc = function(value) SetAndApply("suggestionHeight", value) end,
            default = DEFAULTS.suggestionHeight,
            disabled = function() return not FSC:IsAutocompleteEnabled() end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Suggestion font",
            tooltip = "Choose from a wider set of built-in ESO fonts, including several clearly different typefaces.",
            choices = FONT_CHOICES,
            choicesValues = FONT_VALUES,
            scrollable = 12,
            getFunc = function() return FSC:GetSuggestionFont() end,
            setFunc = function(value) SetAndApply("suggestionFont", value) end,
            default = DEFAULTS.suggestionFont,
            disabled = function() return not FSC:IsAutocompleteEnabled() end,
            width = "full",
        },
        {
            type = "slider",
            name = "Suggestion text size",
            tooltip = "Adjusts suggested-word size independently of the chosen font.",
            min = 75,
            max = 110,
            step = 1,
            getFunc = function() return FSC:GetSetting("suggestionTextScale") end,
            setFunc = function(value) SetAndApply("suggestionTextScale", value) end,
            default = DEFAULTS.suggestionTextScale,
            disabled = function() return not FSC:IsAutocompleteEnabled() end,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Suggested word color",
            tooltip = "Color used for suggestions that are not currently selected.",
            getFunc = function() return FSC:GetSuggestionTextColor() end,
            setFunc = function(r, g, b, a) SetColorAndApply("suggestionTextColor", r, g, b, a) end,
            default = DEFAULTS.suggestionTextColor,
            disabled = function() return not FSC:IsAutocompleteEnabled() end,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "Selected word color",
            tooltip = "Color used for the suggestion selected by keyboard navigation. Its selection underline follows the same color.",
            getFunc = function() return FSC:GetSuggestionSelectedColor() end,
            setFunc = function(r, g, b, a) SetColorAndApply("suggestionSelectedColor", r, g, b, a) end,
            default = DEFAULTS.suggestionSelectedColor,
            disabled = function() return not FSC:IsAutocompleteEnabled() end,
            width = "half",
        },
        {
            type = "slider",
            name = "Suggestion background opacity",
            tooltip = "Controls the dark prediction-bar background or the rounded-box backgrounds.",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return FSC:GetSetting("suggestionBackgroundOpacity") end,
            setFunc = function(value) SetAndApply("suggestionBackgroundOpacity", value) end,
            default = DEFAULTS.suggestionBackgroundOpacity,
            disabled = function() return not FSC:IsAutocompleteEnabled() end,
            width = "full",
        },
        {
            type = "slider",
            name = "Divider opacity",
            tooltip = "Actual opacity of the two separators in Prediction bar mode: 0 is invisible and 100 is fully opaque.",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return FSC:GetSetting("suggestionDividerOpacityPercent") end,
            setFunc = function(value) SetAndApply("suggestionDividerOpacityPercent", value) end,
            default = DEFAULTS.suggestionDividerOpacityPercent,
            disabled = function() return not FSC:IsAutocompleteEnabled() or FSC:GetSuggestionStyle() ~= "bar" end,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Misspelling underline color",
            tooltip = "Choose the color of the wave underline shown below misspelled words.",
            getFunc = function() return FSC:GetUnderlineColor() end,
            setFunc = function(r, g, b, a) SetColorAndApply("underlineColor", r, g, b, a) end,
            default = DEFAULTS.underlineColor,
            disabled = function() return not FSC:IsSpellcheckEnabled() end,
            width = "half",
        },
        {
            type = "slider",
            name = "Underline visibility",
            tooltip = "Controls how strongly misspelled words are underlined.",
            min = 30,
            max = 100,
            step = 1,
            getFunc = function() return FSC:GetSetting("underlineOpacity") end,
            setFunc = function(value) SetAndApply("underlineOpacity", value) end,
            default = DEFAULTS.underlineOpacity,
            disabled = function() return not FSC:IsSpellcheckEnabled() end,
            width = "half",
        },
        {
            type = "button",
            name = "Reset appearance",
            tooltip = "Restores suggestion style, height, font, colors, opacity, dividers, and underline appearance to Flamechasers defaults. Learning and dictionary data are not changed.",
            func = function()
                FSC:ResetAppearanceSettings()
                Message("Appearance reset to default.")
                RefreshSettingsPanel()
            end,
            width = "full",
        },

        {
            type = "header",
            name = "Personalization",
        },
        {
            type = "checkbox",
            name = "Personalized suggestions",
            tooltip = "Learn from messages you send and from suggestions you accept. All learning stays in ESO SavedVariables on your computer.",
            getFunc = function() return FSC:IsPersonalizationEnabled() end,
            setFunc = function(value)
                SetAndApply("personalizationEnabled", value)
                FSC.personalAutocompletePrefixIndex = nil
            end,
            default = DEFAULTS.personalizationEnabled,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Learn correction choices",
            tooltip = "Prefer corrections you have selected before when the same typo appears again.",
            getFunc = function() return FSC:IsCorrectionLearningEnabled() end,
            setFunc = function(value) SetAndApply("correctionLearningEnabled", value) end,
            default = DEFAULTS.correctionLearningEnabled,
            width = "full",
        },
        {
            type = "description",
            title = "Learned data",
            text = function()
                return string.format(
                    "%d personalized words • %d learned typo patterns",
                    FSC:GetLearnedSuggestionCount(),
                    FSC:GetLearnedCorrectionCount()
                )
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Reset learned data",
            tooltip = "Deletes learned word frequencies, phrase patterns, and correction choices. Your manually added dictionary words are kept.",
            warning = "This cannot be undone.",
            func = function()
                FSC:ResetLearnedLanguageData()
                Message("Learned suggestion and correction data reset.")
                RefreshSettingsPanel()
            end,
            width = "full",
        },

        {
            type = "header",
            name = "Personal Dictionary",
        },
        {
            type = "description",
            text = function()
                local count = FSC:GetPersonalDictionaryCount()
                return string.format("%d custom word%s currently saved. Use the list below to select one or more words for removal.", count, count == 1 and "" or "s")
            end,
            width = "full",
        },
        {
            type = "editbox",
            name = "Add word",
            tooltip = "Enter a word you never want Spellcheck to mark as misspelled.",
            getFunc = function() return FSC.settingsWordToAdd or "" end,
            setFunc = function(value) FSC.settingsWordToAdd = value or "" end,
            isMultiline = false,
            width = "half",
        },
        {
            type = "button",
            name = "Add to dictionary",
            func = function()
                local raw = FSC.settingsWordToAdd or ""
                local word = FSC:NormalizeWord(raw)
                if word == "" then
                    Message("Enter a word first.")
                    return
                end
                FSC:AddUserWord(raw)
                Message("Added \"" .. raw .. "\" to your dictionary.")
                FSC.settingsWordToAdd = ""
                RefreshDictionaryControl(true)
                RefreshSettingsPanel()
            end,
            width = "half",
        },
        {
            type = "custom",
            createFunc = CreateDictionaryListBox,
            refreshFunc = function(control)
                if control.RefreshWords then control:RefreshWords() end
            end,
            minHeight = 220,
            maxHeight = 220,
            reference = "FlamechasersSpellcheckDictionaryListBox",
            width = "full",
        },
        {
            type = "button",
            name = "Remove selected",
            tooltip = "Remove the selected words from your personal dictionary.",
            disabled = function() return #(FSC.settingsDictionarySelections or {}) == 0 end,
            func = function()
                local selections = FSC.settingsDictionarySelections or {}
                if #selections == 0 then
                    Message("Select at least one saved word first.")
                    return
                end
                local removed = 0
                if FSC.saved and FSC.saved.userWords then
                    for _, word in ipairs(selections) do
                        if FSC.saved.userWords[word] then
                            FSC.saved.userWords[word] = nil
                            removed = removed + 1
                        end
                    end
                end
                FSC.settingsDictionarySelections = {}
                if removed > 0 then FSC:InvalidateInputLayoutCaches() end
                FSC:InvalidateAutocompleteCaches()
                FSC:ScheduleRefresh(0)
                RefreshDictionaryControl(true)
                RefreshSettingsPanel()
                Message(string.format("Removed %d word%s from your dictionary.", removed, removed == 1 and "" or "s"))
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Clear dictionary",
            tooltip = "Deletes every word you manually added to the dictionary.",
            warning = "This cannot be undone.",
            func = function()
                FSC:ClearPersonalDictionary()
                RefreshDictionaryControl(true)
                RefreshSettingsPanel()
                Message("Personal dictionary cleared.")
            end,
            width = "half",
        },
    }

    -- Dictionary controls are generated from the registry rather than hard-coded.
    -- New language/domain packs can register themselves and automatically receive
    -- an enable/disable switch here.
    local dictionaryOptions = {
        {
            type = "header",
            name = "Dictionaries",
        },
        {
            type = "description",
            text = "Choose which built-in dictionaries contribute to spell checking, corrections and predictions. Your Personal Dictionary and learned personal suggestions remain available independently. This list is generated from registered dictionary packs so more languages can be added later without redesigning this page.",
            width = "full",
        },
    }

    for _, pack in ipairs(FSC:GetDictionaryPacks()) do
        local dictionary = pack
        dictionaryOptions[#dictionaryOptions + 1] = {
            type = "checkbox",
            name = dictionary.name,
            tooltip = dictionary.description,
            getFunc = function() return FSC:IsDictionaryEnabled(dictionary.id) end,
            setFunc = function(value)
                FSC:SetDictionaryEnabled(dictionary.id, value)
                RefreshSettingsPanel()
            end,
            default = dictionary.defaultEnabled ~= false,
            width = "full",
        }

        local subcategories = dictionary.subcategories or {}
        if #subcategories > 0 then
            dictionaryOptions[#dictionaryOptions + 1] = {
                type = "description",
                title = dictionary.name .. " categories",
                text = dictionary.subcategoryDescription or "Fine-tune which parts of this dictionary are allowed to contribute built-in spelling, correction, and prediction candidates. Disabled categories stay disabled even after reloads. Your Personal Dictionary and words learned from your own messages remain independent, so a word you personally trained can still appear as a personalized suggestion.",
                width = "full",
            }

            for _, subcategory in ipairs(subcategories) do
                local category = subcategory
                dictionaryOptions[#dictionaryOptions + 1] = {
                    type = "checkbox",
                    name = category.name,
                    tooltip = category.description,
                    getFunc = function() return FSC:IsDictionarySubcategoryEnabled(dictionary.id, category.id) end,
                    setFunc = function(value)
                        FSC:SetDictionarySubcategoryEnabled(dictionary.id, category.id, value)
                        RefreshSettingsPanel()
                    end,
                    default = category.defaultEnabled ~= false,
                    disabled = function() return not FSC:IsDictionaryEnabled(dictionary.id) end,
                    width = "full",
                }
            end

            dictionaryOptions[#dictionaryOptions + 1] = {
                type = "button",
                name = "Enable all categories",
                tooltip = "Turns on every subcategory in " .. dictionary.name .. ".",
                func = function()
                    FSC:SetAllDictionarySubcategories(dictionary.id, true)
                    RefreshSettingsPanel()
                end,
                disabled = function() return not FSC:IsDictionaryEnabled(dictionary.id) end,
                width = "half",
            }
            dictionaryOptions[#dictionaryOptions + 1] = {
                type = "button",
                name = "Disable all categories",
                tooltip = "Turns off every subcategory in " .. dictionary.name .. " while leaving the master dictionary switch enabled.",
                func = function()
                    FSC:SetAllDictionarySubcategories(dictionary.id, false)
                    RefreshSettingsPanel()
                end,
                disabled = function() return not FSC:IsDictionaryEnabled(dictionary.id) end,
                width = "half",
            }
        end
    end

    -- Insert after General, before Suggestion Intelligence.
    for index = #dictionaryOptions, 1, -1 do
        table.insert(options, 5, dictionaryOptions[index])
    end

    LAM:RegisterOptionControls("FlamechasersSpellcheckSettings", options)
    self.settingsRegistered = true
end

return FSC
