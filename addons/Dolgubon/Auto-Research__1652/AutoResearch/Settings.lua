local addon = AutoResearch

local COLOR_DISABLED = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED))
local NONE = COLOR_DISABLED:Colorize(zo_strformat(GetString(SI_QUEST_TYPE_FORMAT), GetString(SI_ITEMTYPE0)))
local INDENT = not IsConsoleUI() and "|t420%:100%:art/icons/placeholder/icon_blank.dds|t" or ""
local LSV = LibSavedVars or (not IsConsoleUI() and LibStub("LibSavedVars"))
local savedVarsUpdateVersion2, savedVarsUpdateVersion4, refreshPrefix
local LAM2 = LibAddonMenu2 or (not IsConsoleUI() and LibStub("LibSavedVars")) or {}
addon.consoleVarsVersion = 1


----------------- Settings -----------------------
local lastChosenish = 1
local function consoleValues(settings, optionIndex, value, valueSources)
    local unAvailableValues = {}
    local finalOptions = {}
    local currentOptions = {}
    local currentValue = settings[optionIndex]
    ZO_ShallowTableCopy(valueSources, finalOptions)
    for i = 1, optionIndex-1 do
        -- availableOptions[i - optionIndex] = {i, settings[i]}
        if settings[i] ~= 0 then
            unAvailableValues[settings[i]] = {i, settings[i]}
        end
    end
    for i = 1, #valueSources do
        if unAvailableValues[valueSources[i]] then
            finalOptions[i]= nil
        end
    end
    local optionsInOrder = {}
    for i = 1, #valueSources do
        if finalOptions[i] then
            optionsInOrder[#optionsInOrder + 1] = finalOptions[i]
        end
    end
    return optionsInOrder
end
local function getNextValue(settings, optionIndex, value, valueSources, optionsInOrder)
    local nextOptionOrder 
    for i = 1, #optionsInOrder do
        if optionsInOrder[i] == settings[optionIndex] then
            nextOptionOrder = ((i + 1) % #optionsInOrder) 
            if nextOptionOrder == 0 then
                nextOptionOrder = #optionsInOrder
            end
            return optionsInOrder[nextOptionOrder]
        end
    end
    return optionsInOrder[2] or optionsInOrder[1]
end
-- /script AutoResearch.settings:ResetToDefaults()
local function SwapDropdownValues(settings, optionIndex, value,valueSources)
    if value == 0 and not IsConsoleUI() then
        settings[optionIndex] = value
        return
    end
    local oldValue = settings[optionIndex]
    if IsConsoleUI() then
        local availableValues = consoleValues(settings, optionIndex, value, valueSources)
        value = getNextValue(settings, optionIndex, value, valueSources, availableValues)
    end
    for swapOptionIndex=1,#settings do
        local swapValue = settings[swapOptionIndex]

        if swapValue == value and value ~= 0 then --and (not IsConsoleUI() or swapOptionIndex > optionIndex) then
            settings[swapOptionIndex] = oldValue
            settings[optionIndex] = value
            if IsConsoleUI() then LAM2.LHASConversion.settingTables[addon.name .. "Options"]:UpdateControls() end
            return
        elseif swapValue == value and IsConsoleUI() and swapOptionIndex < optionIndex then
            value, swapOptionIndex = findFirstAvailableOption(settings, optionIndex, value,valueSources)
            if swapOptionIndex then
                settings[swapOptionIndex] = 0
            end
            settings[optionIndex] = value
            if IsConsoleUI() then LAM2.LHASConversion.settingTables[addon.name .. "Options"]:UpdateControls() end
            return 
        end
    end
    settings[optionIndex] = value
    if IsConsoleUI() then LAM2.LHASConversion.settingTables[addon.name .. "Options"]:UpdateControls() end
end
local function CreateTraitOption(optionsTable, optionIndex, researchCategory)
    local self = addon
    local traitOption = {
        type = "dropdown",
        width = "half",
        choices = addon.traitChoices[researchCategory],
        choicesValues = self.traitChoicesValues[researchCategory],
        name = INDENT .. tostring(optionIndex),
        getFunc = function() return self.settings.traitResearchOrder[researchCategory][optionIndex] end,
        setFunc = function(value)
            SwapDropdownValues(self.settings.traitResearchOrder[researchCategory], optionIndex, value, self.traitChoicesValues[researchCategory])
        end,
        default = self.defaults.traitResearchOrder[researchCategory][optionIndex]
    }
    
    table.insert(optionsTable, traitOption)
end
local function CreateResearchLineOption(optionsTable, optionIndex, craftSkill)
    local self = addon
    local researchLineOption = {
        type = "dropdown",
        width = "half",
        choices = self.researchLineChoices[craftSkill],
        choicesValues = self.researchLineChoicesValues[craftSkill],
        name = INDENT .. tostring(optionIndex),
        getFunc = function() return self.settings.researchLineOrder[craftSkill][optionIndex] end,
        setFunc = function(value)
            SwapDropdownValues(self.settings.researchLineOrder[craftSkill], optionIndex, value, self.researchLineChoicesValues[craftSkill])
        end,
        default = self.defaults.researchLineOrder[craftSkill][optionIndex],
        disabled = function() return not self.settings.enabled[craftSkill] end
    }
    
    table.insert(optionsTable, researchLineOption)
end
local function GetItemTraitTypeName(traitIndex)
    return GetString("SI_ITEMTRAITTYPE", traitIndex)
end

function addon:SetupOptions()

    -- Populate the dropdown choices
    self.traitChoices = { }
    self.traitChoicesValues = { }
    for researchCategory, config in pairs(self.traitConfig) do
        if config.name then
            self.traitChoicesValues[researchCategory] = { 0 }
            self.traitChoices[researchCategory] = { NONE }
            for _, types in ipairs(config.types) do
                for traitIndex=types.min,types.max do
                    table.insert(self.traitChoicesValues[researchCategory], traitIndex)
                    table.insert(self.traitChoices[researchCategory], GetItemTraitTypeName(traitIndex))
                end
            end
        end
    end
    self.researchLineChoices = { }
    self.researchLineChoicesValues = { }
    self.defaults.researchLineOrder = { }
    self.defaults.enabled = { }
    for craftSkill, _ in pairs(self.craftSkills) do
        local researchLineCount = GetNumSmithingResearchLines(craftSkill)
        self.researchLineChoicesValues[craftSkill] = { 0 }
        self.researchLineChoices[craftSkill] = { NONE }
        self.defaults.researchLineOrder[craftSkill] = { }
        for researchLineIndex = 1, researchLineCount do
        local researchLineName = GetSmithingResearchLineInfo(craftSkill, researchLineIndex)
            table.insert(self.researchLineChoicesValues[craftSkill], researchLineIndex)
            table.insert(self.researchLineChoices[craftSkill], researchLineName)
            table.insert(self.defaults.researchLineOrder[craftSkill], researchLineIndex)
        end
        self.defaults.enabled[craftSkill] = true
    end    
    
    -- Setup saved vars
    if LSV then
        self.settings = LSV:NewCharacterSettings(self.name .. "_Character", self.defaults)
                           :AddAccountWideToggle(self.name .. "_Account")
                           :Version(2, savedVarsUpdateVersion2)
                           :RemoveSettings(3, "dataVersion")
                           :Version(4, savedVarsUpdateVersion4)
    else
        self.settings = ZO_SavedVars:NewAccountWide(
        "AutoResearch_Account", addon.consoleVarsVersion, nil,  self.defaults)
    end
    
    if LSV and LSV_Data.EnableDefaultsTrimming then
        self.settings:EnableDefaultsTrimming()
    end
    
    self.chatColor = ZO_ColorDef:New(unpack(self.settings.chatColor))
    refreshPrefix()

    --Setup options panel

    local panelData = {
        type = "panel",
        name = self.title,
        displayName = self.title,
        author = self.author,
        version = self.version,
        slashCommand = "/autoresearch",
        registerForRefresh = true,
        registerForDefaults = not IsConsoleUI(),
    }
    LAM2:RegisterAddonPanel(self.name .. "Options", panelData)
    
    local qualityChoices = {}
    local qualityChoicesValues = {}
    for quality = ITEM_FUNCTIONAL_QUALITY_MIN_VALUE, ITEM_FUNCTIONAL_QUALITY_MAX_VALUE do
        local qualityColor = GetItemQualityColor(quality)
        local qualityString = qualityColor:Colorize(GetString("SI_ITEMQUALITY", quality))
        table.insert(qualityChoicesValues, quality)
        table.insert(qualityChoices, qualityString)
    end

        
    --[[ General Options ]]--
    local optionsTable = { 
        
        -- Account-wide settings
        
        
        -- Bags to search for equipment to research
        {
            type = "dropdown",
            width = "full",
            choices = { 
                GetString(SI_GAMEPAD_INVENTORY_CATEGORY_HEADER),
                GetString(SI_GAMEPAD_BANK_CATEGORY_HEADER),
                zo_strformat("<<1>><<2>><<3>>", 
                             GetString(SI_GAMEPAD_INVENTORY_CATEGORY_HEADER),
                             GetString(SI_LIST_AND_SEPARATOR),
                             GetString(SI_GAMEPAD_BANK_CATEGORY_HEADER)),
            },
            choicesValues = { 
                AUTORESEARCH_BAG_BACKPACK,
                AUTORESEARCH_BAG_BANK,
                AUTORESEARCH_BAG_BOTH,
            },
            name = GetString(SI_AUTORESEARCH_BAGS),
            getFunc = function() return self.settings.bags end,
            setFunc = function(value) self.settings.bags = value end,
            default = self.defaults.bags,
        },
    }
    
    if LSV then table.insert(optionsTable, 1, self.settings:GetLibAddonMenuAccountCheckbox()) end
    --[[ Skill Lines to Research ]]--
    local traitLinesTitle = zo_strformat("<<m:1>>", GetString(SI_SMITHING_RESEARCH_LINE_HEADER), 2)
    local pairFormat = GetString(SI_INVENTORY_TRAIT_STATUS_TOOLTIP)
    for _, craftSkill in ipairs({ CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, 
                                  CRAFTING_TYPE_WOODWORKING, CRAFTING_TYPE_JEWELRYCRAFTING })
    do
        local controls = { 
            {
                type = "divider",
                width = "full",
            },
            {
                type = "checkbox",
                name = INDENT .. GetString(SI_ADDON_MANAGER_ENABLED),
                getFunc = function() return self.settings.enabled[craftSkill] end,
                setFunc = function(value) self.settings.enabled[craftSkill] = value end,
                width = "full",
                default = self.defaults.enabled[craftSkill],
            },
            -- Max Quality
            {
                type = "dropdown",
                width = "full",
                choices = qualityChoices,
                choicesValues = qualityChoicesValues,
                name = INDENT .. GetString(SI_AUTORESEARCH_MAX_QUALITY),
                getFunc = function() return self.settings.maxQuality[craftSkill] end,
                setFunc = function(value) self.settings.maxQuality[craftSkill] = value end,
                default = self.defaults.maxQuality[craftSkill],
                disabled = function() return not self.settings.enabled[craftSkill] end
            },
            {
                type = "divider",
                width = "full",
            },
        }
        
        -- Number of research lines
        local researchLineCount = GetNumSmithingResearchLines(craftSkill)
        local minColumn2Index = math.ceil( researchLineCount / 2 ) + 1
        if IsConsoleUI() then
            for i = 1, researchLineCount do
                CreateResearchLineOption(controls, i, craftSkill)
            end
        else
            for researchLineIndex = 1, minColumn2Index - 1 do
                CreateResearchLineOption(controls, researchLineIndex, craftSkill)
                local researchLineIndex2 = researchLineIndex + minColumn2Index - 1
                if researchLineIndex2 <= researchLineCount then
                    CreateResearchLineOption(controls, researchLineIndex2, craftSkill)
                end
            end
        end
        table.insert(optionsTable,
            -- Submenu
            {
                type = "submenu",
                name = zo_strformat(pairFormat, traitLinesTitle, GetCraftingSkillName(craftSkill)),
                controls = controls,
            })
    end

    --[[ Traits ]]--
    for _, researchCategory in ipairs({ "armor", "weapons", "jewelry" }) do
        local categoryNameStringId = self.traitConfig[researchCategory].name
        if not categoryNameStringId then break end
        local controls = { }
        local maxOrderIndex = #self.defaults.traitResearchOrder[researchCategory]
        local minColumn2Index = math.ceil( maxOrderIndex / 2 ) + 1
        if IsConsoleUI() then
            for i = 1, maxOrderIndex do
                CreateTraitOption(controls, i, researchCategory)
            end
        else
            for column1Index=1, minColumn2Index - 1 do
                CreateTraitOption(controls, column1Index, researchCategory)
                local column2Index = column1Index + minColumn2Index - 1
                if column2Index <= maxOrderIndex then
                    CreateTraitOption(controls, column2Index, researchCategory)
                end
            end
        end
        table.insert(optionsTable,
            -- Submenu
            {
                type = "submenu",
                name = zo_strformat("<<m:1>>", GetString(categoryNameStringId), 2),
                controls = controls,
            })
    end
    
    --[[ Styles to Research ]]--
    if not IsConsoleUI() then
        local controls = {
            {
                type = "dropdown",
                name = GetString(SI_ADDONLOADSTATE2),
                choices = self.allSelectChoices,
                choicesValues = self.allSelectChoicesValues,
                getFunc = function() return self.settings.stylesEnabled end,
                setFunc = function(value) self.settings.stylesEnabled = value end,
                width = "full",
                default = self.defaults.stylesEnabled,
            }
        }
        
        self.styleOptions = {}
        self.styleOptionValues = {}
        local itemStyleIdsByName = {}

        for i = 1, GetNumValidItemStyles() do
          local itemStyleId = GetValidItemStyleId(i)
          local itemStyleName = zo_strformat("<<C:1>>", GetItemStyleName(itemStyleId))
          if not self.invalidStyles[itemStyleId] then
              table.insert(self.styleOptions, itemStyleName)
              itemStyleIdsByName[itemStyleName] = itemStyleId
          end
        end
        table.sort(self.styleOptions)
        for _, itemStyleName in ipairs(self.styleOptions) do
            local itemStyleId = itemStyleIdsByName[itemStyleName]
            table.insert(self.styleOptionValues, itemStyleId)
            table.insert(controls, 
                {
                    type = "checkbox",
                    name = itemStyleName,
                    getFunc = function() return self.settings.styles[itemStyleId] end,
                    setFunc = function(value) self.settings.styles[itemStyleId] = value end,
                    width = "full",
                    default = self.defaults.styles[itemStyleId],
                    disabled = function() return self.settings.stylesEnabled ~= AUTORESEARCH_ENABLE_SELECTED end,
                })
        end
        
        table.insert(optionsTable,
            -- Submenu
            {
                type = "submenu",
                name = GetString(SI_AUTORESEARCH_STYLES),
                controls = controls,
            })
    end
    
    --[[ Sets to Research ]]--
    if not IsConsoleUI() then
        local controls = {}
        local setIds
        if LibSets and LibSets.GetAllSetIds then
            setIds = LibSets.GetAllSetIds()
        end
        
        if setIds and next(setIds) then
              
            -- LibSets >= 0.06
            self.setTypeMap = {
                [LIBSETS_SETTYPE_ARENA] = "isDungeon",
                [LIBSETS_SETTYPE_BATTLEGROUND] = "isOverland",
                [LIBSETS_SETTYPE_CRAFTED] = "isCrafted",
                [LIBSETS_SETTYPE_CYRODIIL] = "isOverland",
                [LIBSETS_SETTYPE_DAILYRANDOMDUNGEONANDICREWARD] = "isOverland",
                [LIBSETS_SETTYPE_DUNGEON] = "isDungeon",
                [LIBSETS_SETTYPE_IMPERIALCITY] = "isOverland",
                [LIBSETS_SETTYPE_MONSTER] = "isMonster",
                [LIBSETS_SETTYPE_OVERLAND] = "isOverland",
                [LIBSETS_SETTYPE_SPECIAL] = "isDungeon",
                [LIBSETS_SETTYPE_TRIAL] = "isDungeon",
            }
            local invertedSetIds = {}
            for setId, _ in pairs(setIds) do
                table.insert(invertedSetIds, setId)
            end
            setIds = invertedSetIds
            invertedSetIds = nil
            self.setIds = setIds
              
            local setNames = { isOverland = {}, isDungeon = {}, isMonster = {}, isCrafted = {} }
            local setNameIds = { isOverland = {}, isDungeon = {}, isMonster = {}, isCrafted = {} }
            
            for _, setId in ipairs(setIds) do
                local setName = LibSets.GetSetName(setId) or LibSets.GetSetName(setId, "en")
                local setInfo = LibSets.GetSetInfo(setId)
                if setInfo and setName then
                    if setInfo.setTypes then
                        for setType, isSetType in pairs(setInfo.setTypes) do
                            if isSetType and setName then
                                setNameIds[setType][setName] = setId
                                table.insert(setNames[setType], setName)
                                break
                            end
                        end
                    elseif setInfo.setType then
                        if self.setTypeMap[setInfo.setType] then
                            local setType = self.setTypeMap[setInfo.setType]
                            setNameIds[setType][setName] = setId
                            table.insert(setNames[setType], setName)
                        end
                    else
                        --d("setInfo.setType is empty")
                    end
                else
                    --d("setInfo is empty")
                end
            end
            for _, setTypeNames in pairs(setNames) do
                table.sort(setTypeNames)
            end
            self.setNames = setNames
            self.setNameIds = setNameIds
            local setTypeCategories = { "boe", "bop" }
            local setTypeCategoryTitles = { ["boe"] = GetString(SI_BINDTYPE2), ["bop"] = GetString(SI_BINDTYPE1) }
            local setTypes = { ["boe"] = { "isOverland", "isCrafted" }, ["bop"] = { "isDungeon", "isMonster" } }
            local setTypeTitles = {
                ["isOverland"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES503),
                ["isCrafted"] = GetString(SI_ITEM_FORMAT_STR_CRAFTED),
                ["isDungeon"] = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKCATEGORIES10),
                ["isMonster"] = GetString(SI_SPECIALIZEDITEMTYPE406),
            }
            for _, setTypeCategory in ipairs(setTypeCategories) do
                local categoryControls = {}
                for _, setType in ipairs(setTypes[setTypeCategory]) do
                    local setTypeControls = {
                        {
                            type = "dropdown",
                            name = GetString(SI_ADDONLOADSTATE2),
                            choices = self.noneAllSelectChoices,
                            choicesValues = self.noneAllSelectChoicesValues,
                            getFunc = function() return self.settings.setsEnabled[setType] end,
                            setFunc = function(value) self.settings.setsEnabled[setType] = value end,
                            width = "full",
                            default = self.defaults.setsEnabled[setType],
                        }
                    }
                    for _, setName in ipairs(setNames[setType]) do
                        local setId = setNameIds[setType][setName]
                        table.insert(setTypeControls, 
                            {
                                type = "checkbox",
                                name = setName,
                                getFunc = function() return self.settings.sets[setId] end,
                                setFunc = function(value) self.settings.sets[setId] = value end,
                                width = "full",
                                default = false,
                                disabled = function() return self.settings.setsEnabled[setType] ~= AUTORESEARCH_ENABLE_SELECTED end,
                            })
                    end
                    table.insert(categoryControls,
                        -- Set Type Submenu
                        {
                            type = "submenu",
                            name = setTypeTitles[setType],
                            controls = setTypeControls,
                        })
                end
                table.insert(controls,
                -- Set Category Submenu
                {
                    type = "submenu",
                    name = setTypeCategoryTitles[setTypeCategory],
                    controls = categoryControls,
                })
            end
            
        else
            table.insert(controls, 
                {
                    type = "description",
                    text = ZO_ERROR_COLOR:Colorize(GetString(SI_ADDON_MANAGER_DEPENDENCIES) .. GetString(SI_AUTORESEARCH_WORD_DELIMITER) .. "LibSets≥0.0.6"),
                    width = "full",
                })
        end
        table.insert(optionsTable,
            -- Submenu
            {
                type = "submenu",
                name = GetString(SI_AUTORESEARCH_SETS),
                controls = controls,
            })
    end
    local chatMessagesSubmenu =
    -- Chat Messages
    {
        type     = "submenu",
        name     = GetString(SI_AUTORESEARCH_CHAT_MESSAGES),
        controls = {
            -- Short prefix
            {
                type = "checkbox",
                name = GetString(SI_AUTORESEARCH_SHORT_PREFIX),
                tooltip = GetString(SI_AUTORESEARCH_SHORT_PREFIX_TOOLTIP),
                getFunc = function() return self.settings.shortPrefix end,
                setFunc = function(value)
                              self.settings.shortPrefix = value
                              refreshPrefix()
                          end,
                default = self.defaults.shortPrefix,
            },
            -- Use default system color
            {
                type = "checkbox",
                name = GetString(SI_AUTORESEARCH_CHAT_USE_SYSTEM_COLOR),
                getFunc = function() return self.settings.chatUseSystemColor end,
                setFunc = function(value)
                              self.settings.chatUseSystemColor = value
                              refreshPrefix()
                          end,
                default = self.defaults.chatUseSystemColor,
            },
            -- Message color
            {
                type = "colorpicker",
                name = GetString(SI_AUTORESEARCH_CHAT_COLOR),
                getFunc = function() return unpack(self.settings.chatColor) end,
                setFunc = function(r, g, b, a)
                              self.settings.chatColor = { r, g, b, a }
                              self.chatColor = ZO_ColorDef:New(r, g, b, a)
                              refreshPrefix()
                          end,
                default = function()
                              local r, g, b, a = unpack(self.defaults.chatColor)
                              return {r=r, g=g, b=b, a=a}
                          end,
                disabled = function() return self.settings.chatUseSystemColor end,
            },
            -- Old Prefix Colors
            {
                type = "checkbox",
                name = GetString(SI_AUTORESEARCH_COLORED_PREFIX),
                tooltip = GetString(SI_AUTORESEARCH_COLORED_PREFIX_TOOLTIP),
                getFunc = function() return self.settings.coloredPrefix end,
                setFunc = function(value)
                              self.settings.coloredPrefix = value
                              refreshPrefix()
                          end,
                default = self.defaults.coloredPrefix,
            },
        },
    }
    if IsConsoleUI() then
        -- table.remove(chatMessagesSubmenu.controls, 2)
        -- table.remove(chatMessagesSubmenu.controls, 2)
    end
    table.insert(optionsTable,chatMessagesSubmenu)
    LAM2:RegisterOptionControls(self.name .. "Options", optionsTable)
end

function refreshPrefix()
    local self = addon
    local stringId
    local startColor = self.settings.chatUseSystemColor and "" or "|c" .. self.chatColor:ToHex()
    if self.settings.coloredPrefix then
        self.prefix = GetString(self.settings.shortPrefix and SI_AUTORESEARCH_PREFIX_SHORT_COLOR or SI_AUTORESEARCH_PREFIX_COLOR)
            .. "|r" .. startColor .. " "
    else
        self.prefix = startColor
            .. GetString(self.settings.shortPrefix and SI_AUTORESEARCH_PREFIX_SHORT or SI_AUTORESEARCH_PREFIX)
            .. " "
    end
    self.suffix = self.settings.chatUseSystemColor and "" or "|r"
    self.startColor = startColor
end

function savedVarsUpdateVersion2(sv)
    local self = addon
    local currentMaxQuality = sv.maxQuality
    if type(currentMaxQuality) == "number" then
        local maxQuality = { }
        for craftSkill, _ in pairs(self.craftSkills) do
            maxQuality[craftSkill] = currentMaxQuality
        end
        sv.maxQuality = maxQuality
    elseif type(currentMaxQuality) ~= "table" then
        sv.maxQuality = ZO_ShallowTableCopy(self.defaults.maxQuality)
    end
    if sv.researchLineOrder then
        sv.researchLineOrder[-1] = nil
    end
end

function savedVarsUpdateVersion4(sv)
    local self = addon
    local defaultValue
    if sv.setsAllowed == false then
        defaultValue = AUTORESEARCH_ENABLE_NONE
    else
        defaultValue = AUTORESEARCH_ENABLE_SELECTED
    end
    sv.setsEnabled = {
      isMonster = defaultValue,
      isDungeon = defaultValue,
      isCrafted = defaultValue,
      isOverland = defaultValue
    }
    sv.setsAllowed = nil
end

------------------------------------------
-- Temporary LAM to LHAS console converter
------------------------------------------
if LibAddonMenu2 then return end
local lam = LAM2
function lam:RegisterAddonPanel(addonID, panelData)
    if IsConsoleUI() then
        lam:registerConsoleAddonPanel(addonID, panelData)
        return
    end
end
function lam:RegisterOptionControls(addonID, optionsTable) --optionsTable = {sliderData, buttonData, etc}
    if IsConsoleUI() then
        lam:registerConsoleOptionControls(addonID, optionsTable)
    end
end
local function addToControlTable(newOption, t)
    t.indexed[#t.indexed + 1 ] = newOption
    if newOption.label then
        t.nameMap[newOption.label] = newOption
    end
    newOption.conversionIndex = #t.indexed
end
local function LAMtoHASDropdownConverter(option, controlTable)
    local newOption = {
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = option.name,
        default = option.default,
        -- setFunction = option.setFunc,
        getFunction = option.getFunc,
        tooltip = option.tooltip,
        disable = option.disabled,
    }

    newOption.setFunction = function(combobox, name, item) option.setFunc(item.data) end
    
    local items = {}
    local labelMap = {}
    if not option.choicesValues then
        option.choicesValues = option.choices
    end
    for i = 1, # option.choices do
        items[i] = {name = option.choices[i], data = option.choicesValues[i]}
        if option.choicesValues[i] then
            labelMap[items[i].data] = items[i].name
        end
    end
    newOption.items = items
    newOption.getFunction = function() return labelMap[option.getFunc()]  end
    addToControlTable(newOption, controlTable)
end

local function LamtoHASSubmenuConverter(optionsTable, controlTable)
    local newOption = {
        type = LibHarvensAddonSettings.ST_SECTION,
        label = optionsTable.name,
    }
    addToControlTable(newOption, controlTable)
    return lam:convertLamOptionsToHasTable(optionsTable.controls, controlTable)
end

local function LamToHASDescriptionConverter(entry, controlTable)
    
    local newOption = {
        type = LibHarvensAddonSettings.ST_LABEL,
        label = entry.title,
        default = entry.default,
        tooltip = entry.tooltip,
    }
    addToControlTable(newOption, controlTable)
    newOption = {
        type = LibHarvensAddonSettings.ST_LABEL,
        label = entry.text,
        default = entry.default,
        tooltip = entry.tooltip,
    }
    addToControlTable(newOption, controlTable)
end

local function LamToHASDividerConverter(entry, controlTable)
    newOption = {
        type = LibHarvensAddonSettings.ST_SECTION,
        label = nil,
    }
    addToControlTable(newOption, controlTable)
end

function lam:convertLamOptionsToHasTable(optionsTable, controlTable)
    local LAMtoHAS = {
        slider = LibHarvensAddonSettings.ST_SLIDER,
        header = LibHarvensAddonSettings.ST_SECTION,
        checkbox = LibHarvensAddonSettings.ST_CHECKBOX,
        colorpicker = LibHarvensAddonSettings.ST_COLOR,
        button = LibHarvensAddonSettings.ST_BUTTON,
        editbox = LibHarvensAddonSettings.ST_EDIT,
    }
    local LAMtoHASSpecial = {
        dropdown = LAMtoHASDropdownConverter,
        submenu = LamtoHASSubmenuConverter,
        description = LamToHASDescriptionConverter,
        divider = LamToHASDividerConverter,
    }
    local controlTable = controlTable or {
        indexed = {},
        nameMap = {},
    }
    
    -- LAMHASMissing = {}
    
    for i, entry in ipairs(optionsTable) do
        local newType = LAMtoHAS[entry.type]
        if newType and not entry.isPCOnly then
            local newOption = {
                type = newType,
                label = entry.name,
                default = entry.default,
                setFunction = entry.setFunc,
                getFunction = entry.getFunc,
                tooltip = entry.tooltip,
                min = entry.min,
                max = entry.max,
                step = entry.step,
                disable = entry.disabled,
                clickHandler = entry.func,
                buttonText = entry.name,
            }
            addToControlTable(newOption, controlTable)
            -- settings:AddSetting(newOption)
        elseif LAMtoHASSpecial[entry.type] then
            LAMtoHASSpecial[entry.type](entry, controlTable)
        else
           -- LHAS does not have an equivalent for:
           -- iconPicker
           -- texture
        end
    end
    return controlTable
end

lam.LHASConversion = {}
lam.LHASConversion.settingTables = {}
lam.LHASConversion.optionControls = {}

function lam:registerConsoleAddonPanel(addonID, panelData)
    if IsConsoleUI() then
        local LHA = LibHarvensAddonSettings
        local options = {
            allowDefaults = panelData.registerForDefaults, --will allow users to reset the settings to default values
            allowRefresh = panelData.registerForRefresh, --if this is true, when one of settings is changed, all other settings will be checked for state change (disable/enable)
            defaultsFunction = panelData.resetFunc,
        }

        local settings = LHA:AddAddon(panelData.name, options)
        lam.LHASConversion.settingTables[addonID] = settings
    end
end

function lam:registerConsoleOptionControls(addonID, optionsTable)
    if not IsConsoleUI() then
        return
    end
    if lam.LHASConversion.settingTables[addonID] then
        local settings = lam.LHASConversion.settingTables[addonID]
        local LHA = LibHarvensAddonSettings
        lam.LHASConversion.optionControls [addonID]= lam:convertLamOptionsToHasTable(optionsTable)
        local controlTable = lam.LHASConversion.optionControls[addonID]

        for i = 1, #controlTable.indexed do
            settings:AddSetting(controlTable.indexed[i])
        end
    end
end