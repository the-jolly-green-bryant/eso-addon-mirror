J2EUpdate = {
    displayName = "|c3CB371" .. "J2E Update" .. "|r",
    shortName = "J2u",
    name = "J2EUpdate",
    author = "@Marify (Original:@Naaa)",
    version = "1.7.0",
    originFormats = {},
    txtColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_TOOLTIP, ITEM_TOOLTIP_COLOR_GENERAL)):ToHex(),
    updateTotal = 0,
    typeDataCounts = {},
    defaultDisplayTypes = {
        ITEMTYPE_ADDITIVE,
        ITEMTYPE_ARMOR,
        ITEMTYPE_ARMOR_TRAIT,
        ITEMTYPE_BLACKSMITHING_BOOSTER,
        ITEMTYPE_BLACKSMITHING_MATERIAL,
        ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
        ITEMTYPE_CLOTHIER_BOOSTER,
        ITEMTYPE_CLOTHIER_MATERIAL,
        ITEMTYPE_CLOTHIER_RAW_MATERIAL,
        ITEMTYPE_DEPRECATED,
        ITEMTYPE_ENCHANTING_RUNE_ASPECT,
        ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
        ITEMTYPE_ENCHANTING_RUNE_POTENCY,
        ITEMTYPE_FLAVORING,
        ITEMTYPE_FURNISHING_MATERIAL,
        ITEMTYPE_INGREDIENT,
        ITEMTYPE_JEWELRYCRAFTING_BOOSTER,
        ITEMTYPE_JEWELRYCRAFTING_MATERIAL,
        ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER,
        ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL,
        ITEMTYPE_JEWELRY_RAW_TRAIT,
        ITEMTYPE_JEWELRY_TRAIT,
        ITEMTYPE_LOCKPICK,
        ITEMTYPE_LURE,
        ITEMTYPE_MASTER_WRIT,
        ITEMTYPE_PLUG,
        ITEMTYPE_POISON,
        ITEMTYPE_POISON_BASE,
        ITEMTYPE_POTION,
        ITEMTYPE_POTION_BASE,
        ITEMTYPE_RACIAL_STYLE_MOTIF,
        ITEMTYPE_RAW_MATERIAL,
        ITEMTYPE_REAGENT,
        ITEMTYPE_SPICE,
        ITEMTYPE_STYLE_MATERIAL,
        ITEMTYPE_WEAPON,
        ITEMTYPE_WEAPON_TRAIT,
        ITEMTYPE_WOODWORKING_BOOSTER,
        ITEMTYPE_WOODWORKING_MATERIAL,
        ITEMTYPE_WOODWORKING_RAW_MATERIAL,
    },
}




function J2EUpdate:CopySavedVariables(old, new)

    self.savedVariables = ZO_SavedVars:NewAccountWide("J2EUpdateVariables", old, nil, {})
    local inheritedValues = {
        displayTypes         = self.savedVariables.displayTypes,
        isNotification       = self.savedVariables.isNotification,
        labelPositions       = self.savedVariables.labelPositions,
        showEnchant          = self.savedVariables.showEnchant,
        showItemName         = self.savedVariables.showItemName,
        showItemNameBottom   = self.savedVariables.showItemNameBottom,
        showSetName          = self.savedVariables.showSetName,
        showSetNameBottom    = self.savedVariables.showSetNameBottom,
        showSkillName        = self.savedVariables.showSkillName,
        showSkillNameBottom  = self.savedVariables.showSkillNameBottom,
        showStarName         = self.savedVariables.showStarName,
        showTrait            = self.savedVariables.showTrait,
    }
    self.savedVariables = ZO_SavedVars:NewAccountWide("J2EUpdateVariables", new, nil, inheritedValues)
    J2EUpdateVariables.variableVersion = new
end



function J2EUpdate:CreateMenu()

    local panelData = {
        type = "panel",
        reference = "J2ESettingControl",
        name = self.displayName,
        displayName = self.displayName,
        author = self.author,
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local panel = LibAddonMenu2:RegisterAddonPanel(self.displayName, panelData)



    local format = GetString(J2E_DATA_COUNT_FMT)
    local format2 = GetString(J2E_DATA_COUNT_FMT2)
    local count
    local itemtypeSubmenu = {}
    for itemType = ITEMTYPE_ITERATION_BEGIN + 1, ITEMTYPE_MAX_VALUE do
        count = self.savedVariables.displayTypesCount[itemType]
        if count then
            count = ZO_LocalizeDecimalNumber(count)
        end

        if self:ContainsNumber(itemType, ITEMTYPE_BLACKSMITHING_MATERIAL,
                                         ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
                                         ITEMTYPE_BLACKSMITHING_BOOSTER) then
            --itemTypeName = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_BLACKSMITHING) .. ":" .. itemTypeName
            itemTypeName = zo_strformat(format2, GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_BLACKSMITHING),
                                                 GetString("SI_ITEMTYPE", itemType),
                                                 count)

        elseif self:ContainsNumber(itemType, ITEMTYPE_CLOTHIER_MATERIAL,
                                             ITEMTYPE_CLOTHIER_RAW_MATERIAL,
                                             ITEMTYPE_CLOTHIER_BOOSTER) then
            itemTypeName = zo_strformat(format2, GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_CLOTHING),
                                                 GetString("SI_ITEMTYPE", itemType),
                                                 count)

        elseif self:ContainsNumber(itemType, ITEMTYPE_WOODWORKING_MATERIAL,
                                             ITEMTYPE_WOODWORKING_RAW_MATERIAL,
                                             ITEMTYPE_WOODWORKING_BOOSTER) then
            itemTypeName = zo_strformat(format2, GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WOODWORKING),
                                                 GetString("SI_ITEMTYPE", itemType),
                                                 count)

        elseif self:ContainsNumber(itemType, ITEMTYPE_JEWELRYCRAFTING_MATERIAL,
                                             ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL,
                                             ITEMTYPE_JEWELRYCRAFTING_BOOSTER,
                                             ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER,
                                             ITEMTYPE_JEWELRY_TRAIT,
                                             ITEMTYPE_JEWELRY_RAW_TRAIT) then
            itemTypeName = zo_strformat(format2, GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRYCRAFTING),
                                                 GetString("SI_ITEMTYPE", itemType),
                                                 count)

        elseif self:ContainsNumber(itemType, ITEMTYPE_ENCHANTING_RUNE_ASPECT,
                                             ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
                                             ITEMTYPE_ENCHANTING_RUNE_POTENCY) then
            itemTypeName = zo_strformat(format2, GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ENCHANTING),
                                                 GetString("SI_ITEMTYPE", itemType),
                                                 count)

        elseif self:ContainsNumber(itemType, ITEMTYPE_REAGENT,
                                             ITEMTYPE_POISON_BASE,
                                             ITEMTYPE_POTION_BASE) then
            itemTypeName = zo_strformat(format2, GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALCHEMY),
                                                 GetString("SI_ITEMTYPE", itemType),
                                                 count)

        elseif self:ContainsNumber(itemType, ITEMTYPE_INGREDIENT) then
            itemTypeName = zo_strformat(format2, GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_PROVISIONING),
                                                 GetString("SI_ITEMTYPE", itemType),
                                                 count)

        else
            itemTypeName = zo_strformat(format, GetString("SI_ITEMTYPE", itemType), count)
        end

        if (not self:ContainsNumber(itemType, ITEMTYPE_DEPRECATED,
                                              ITEMTYPE_LOCKPICK,
                                              ITEMTYPE_WEAPON_BOOSTER,
                                              ITEMTYPE_ARMOR_BOOSTER,
                                              ITEMTYPE_PLUG,
                                              ITEMTYPE_ENCHANTMENT_BOOSTER,
                                              ITEMTYPE_ADDITIVE,
                                              ITEMTYPE_SPICE,
                                              ITEMTYPE_FLAVORING,
                                              ITEMTYPE_SPELLCRAFTING_TABLET,
                                              --
                                              ITEMTYPE_MOUNT,
                                              ITEMTYPE_COSTUME)) then
            itemtypeSubmenu[#itemtypeSubmenu + 1] = {
                type = "checkbox",
                name = itemTypeName,
                getFunc = function()
                    return self.savedVariables.displayTypes[itemType]
                end,
                setFunc = function(value)
                    self.savedVariables.displayTypes[itemType] = value
                end,
                width = "full",
                reference = "J2E_DisplayTypes" .. tostring(itemType),
            }
        end
    end
    table.sort(itemtypeSubmenu, function(a, b)
        return a.name < b.name
        end
    )


    local optionsTable = {
        {
            type = "header",
            name = "表示設定",
            width = "full",
        },
        {
            type = "checkbox",
            name = "アイテム名(英語) を表示",
            getFunc = function()
                return self.savedVariables.showItemName
            end,
            setFunc = function(value)
                self.savedVariables.showItemName = value
                self:ResetCachedItemFormat(true)
                if value then
                    self.savedVariables.showItemNameBottom = false
                end
            end,
            width = "full",
            reference = "J2E_ShowItemName",
        },
        {
            type = "checkbox",
            name = "装備品の セット名(英語) を表示",
            getFunc = function()
                return self.savedVariables.showSetName
            end,
            setFunc = function(value)
                self.savedVariables.showSetName = value
                self:ResetCachedItemFormat(true)
                if value then
                    self.savedVariables.showSetNameBottom = false
                end
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "装備品の 付呪名(英語) を表示",
            getFunc = function()
                return self.savedVariables.showEnchant
            end,
            setFunc = function(value)
                self.savedVariables.showEnchant = value
                self:ResetCachedItemFormat(true)
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "装備品の 特性名(英語) を表示",
            getFunc = function()
                return self.savedVariables.showTrait
            end,
            setFunc = function(value)
                self.savedVariables.showTrait = value
                self:ResetCachedItemFormat(true)
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "スキル名(英語) を表示",
            getFunc = function()
                return self.savedVariables.showSkillName
            end,
            setFunc = function(value)
                self.savedVariables.showSkillName = value
                self:ResetCachedSkillFormat()
                if SKILLS_WINDOW and SKILLS_WINDOW.skillLinesTree then
                    SKILLS_WINDOW:RebuildSkillLineList()
                end
                if GAMEPAD_SKILLS and GAMEPAD_SKILLS.categoryList then
                    GAMEPAD_SKILLS:RefreshCategoryList()
                end
                if value then
                    self.savedVariables.showSkillNameBottom = false
                end
            end,
            width = "full",
        },
        {
            type = "divider",
            width = "half",
            alpha = 0.6,
        },
        {
            type = "checkbox",
            name = "アイテム名(英語) を下部に表示",
            getFunc = function()
                return self.savedVariables.showItemNameBottom
            end,
            setFunc = function(value)
                self.savedVariables.showItemNameBottom = value
                self:ResetCachedItemFormat(true)
                if value then
                    self.savedVariables.showItemName = false
                end
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "装備品の セット名(英語) を下部に表示",
            getFunc = function()
                return self.savedVariables.showSetNameBottom
            end,
            setFunc = function(value)
                self.savedVariables.showSetNameBottom = value
                self:ResetCachedItemFormat(true)
                if value then
                    self.savedVariables.showSetName = false
                end
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "スキル名(英語) を下部に表示",
            getFunc = function()
                return self.savedVariables.showSkillNameBottom
            end,
            setFunc = function(value)
                self.savedVariables.showSkillNameBottom = value
                self:ResetCachedSkillFormat()
                if SKILLS_WINDOW and SKILLS_WINDOW.skillLinesTree then
                    SKILLS_WINDOW:RebuildSkillLineList()
                end
                if GAMEPAD_SKILLS and GAMEPAD_SKILLS.categoryList then
                    GAMEPAD_SKILLS:RefreshCategoryList()
                end
                if value then
                    self.savedVariables.showSkillName = false
                end
            end,
            width = "full",
        },
        {
            type = "divider",
            width = "half",
            alpha = 0.6,
        },
        {
            type = "checkbox",
            name = "CPの星座上に名前を表示(※マウスモード限定)",
            tooltip = "名前/名前(英語名)を表示します。\n位置はマウスで移動可能です。",
            disabled = function()
                return IsInGamepadPreferredMode()
            end,
            getFunc = function()
                return self.savedVariables.showStarName
            end,
            setFunc = function(value)
                self.savedVariables.showStarName = value
                self:ResetCachedSkillFormat()
            end,
            width = "full",
        },
        {
            type = "submenu",
            name = "表示するアイテムの種類",
            controls = itemtypeSubmenu,
            disabled = function()
                return not (self.savedVariables.showItemName or self.savedVariables.showItemNameBottom)
            end,
        },
        {
            type = "header",
            name = "その他",
            width = "full",
        },
        {
            type = "checkbox",
            name = "未登録アイテムがあれば通知する",
            getFunc = function()
                return self.savedVariables.isNotification
            end,
            setFunc = function(value)
                self.savedVariables.isNotification = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "デバッグログを表示",
            getFunc = function()
                return self.savedVariables.isDebug
            end,
            setFunc = function(value)
                self.savedVariables.isDebug = value
                if value then
                    self.savedVariables.debugLog = nil
                end
            end,
            width = "full",
        },
    }

    --if GetDisplayName() == "@Marify" then
    --    optionsTable[#optionsTable + 1] = {
    --        type = "checkbox",
    --        name = "データ収集中",
    --        getFunc = function()
    --            return self.savedVariables.isCollectingData
    --        end,
    --        setFunc = function(value)
    --            self.savedVariables.isCollectingData = value
    --        end,
    --        width = "full",
    --    }
    --end
    
    LibAddonMenu2:RegisterOptionControls(self.displayName, optionsTable)

end




function J2EUpdate:InitializeCommand()

    if GetCVar("language.2") == "en" then
        local defaultLang = self.savedVariables.defaultLanguage
        if defaultLang then
            SLASH_COMMANDS["/lang" .. defaultLang] = function()
                SetCVar("language.2", defaultLang)
            end
        end
    else
        self.savedVariables.defaultLanguage = GetCVar("language.2")
        SLASH_COMMANDS["/langen"] = function()
            SetCVar("language.2", "en")
        end
        SLASH_COMMANDS["/j2e_update"] = function()
            SetCVar("language.2", "en")
        end
    end
    SLASH_COMMANDS["/j2e_reset"] = function()
        self:ResetTable()
    end
end





function J2EUpdate:InitializeTable()

    if J2EUpdateVariables == nil or J2EUpdateVariables.variableVersion == 6 then
        -- version6
        self.savedVariables = ZO_SavedVars:NewAccountWide("J2EUpdateVariables", 6, nil, {})
        J2EUpdateVariables.variableVersion = 6

    elseif J2EUpdateVariables.variableVersion == nil then
        self:CopySavedVariables(4, 6) -- version4 -> 6

    elseif J2EUpdateVariables.variableVersion == 5 then
        self:CopySavedVariables(5, 6) -- version5 -> 6
    end


    if J2EUpdateVariables and J2EUpdateVariables.variableVersion == nil then
        self:CopySavedVariables(4, 5) -- version4 -> 5
    end
    if J2EUpdateVariables and J2EUpdateVariables.variableVersion == 5 then
        self:CopySavedVariables(5, 6) -- version5 -> 6
    end
    if J2EUpdateVariables and J2EUpdateVariables.variableVersion == 5 then
        -- version6
        self.savedVariables = ZO_SavedVars:NewAccountWide("J2EUpdateVariables", 6, nil, {})
        J2EUpdateVariables.variableVersion = 6
    end

    if self.savedVariables.labelPositions == nil then
        self.savedVariables.labelPositions = {}
    end
    if self.savedVariables.newSkillTable == nil then
        self.savedVariables.newSkillTable = {}
    end
    if self.savedVariables.showItemName == nil then
        self.savedVariables.showItemName = true
    end
    if self.savedVariables.showItemNameBottom == nil then
        self.savedVariables.showItemNameBottom = false
    end
    if self.savedVariables.showSetName == nil then
        self.savedVariables.showSetName = true
    end
    if self.savedVariables.showSetNameBottom == nil then
        self.savedVariables.showSetNameBottom = false
    end
    if self.savedVariables.showEnchant == nil then
        self.savedVariables.showEnchant = true
    end
    if self.savedVariables.showTrait == nil then
        self.savedVariables.showTrait = true
    end
    if self.savedVariables.showSkillName == nil then
        self.savedVariables.showSkillName = true
    end
    if self.savedVariables.showSkillNameBottom == nil then
        self.savedVariables.showSkillNameBottom = false
    end
    if self.savedVariables.isNotification == nil then
        self.savedVariables.isNotification = true
    end
    if self.savedVariables.showStarName == nil then
        self.savedVariables.showStarName = true
    end
    if self.savedVariables.isDebug == nil then
        self.savedVariables.isDebug = false
    end
    self.savedVariables.debugLog = nil

    if self.savedVariables.skillLineTable == nil then
        self.savedVariables.skillLineTable = {}
    end
    if self.savedVariables.skillTable == nil then
        self.savedVariables.skillTable = {}
    end
    if self.savedVariables.itemLinkTable == nil then
        self.savedVariables.itemLinkTable = {}
    end
    if self.savedVariables.itemTable == nil then
        self.savedVariables.itemTable = {}
    end
    if self.savedVariables.normalItemSuffixTable == nil then
        self.savedVariables.normalItemSuffixTable = {}
    end
    if self.savedVariables.itemPrefixTable == nil then
        self.savedVariables.itemPrefixTable = {}
    end
    if self.savedVariables.itemPrefixTable[CRAFTING_TYPE_BLACKSMITHING] == nil then
        self.savedVariables.itemPrefixTable[CRAFTING_TYPE_BLACKSMITHING] = {}
    end
    if self.savedVariables.itemPrefixTable[CRAFTING_TYPE_CLOTHIER] == nil then
        self.savedVariables.itemPrefixTable[CRAFTING_TYPE_CLOTHIER] = {}
    end
    if self.savedVariables.itemPrefixTable[CRAFTING_TYPE_WOODWORKING] == nil then
        self.savedVariables.itemPrefixTable[CRAFTING_TYPE_WOODWORKING] = {}
    end
    if self.savedVariables.itemPrefixTable[CRAFTING_TYPE_JEWELRYCRAFTING] == nil then
        self.savedVariables.itemPrefixTable[CRAFTING_TYPE_JEWELRYCRAFTING] = {}
    end

    if self.savedVariables.itemSetTable == nil then
        self.savedVariables.itemSetTable = {}
    end
    if self.savedVariables.newItemLinkTable == nil then
        self.savedVariables.newItemLinkTable = {}
    end
    if self.savedVariables.newItemTable == nil then
        self.savedVariables.newItemTable = {}
    end
    if self.savedVariables.displayTypesCount == nil then
        self.savedVariables.displayTypesCount = {}
    end
    if self.savedVariables.displayTypes == nil then
        self.savedVariables.displayTypes = {}
    end

    for itemType = ITEMTYPE_ITERATION_BEGIN + 1, ITEMTYPE_MAX_VALUE do
        if self.savedVariables.displayTypes[itemType] == nil then
            self.savedVariables.displayTypes[itemType] = self:ContainsNumber(itemType, self.defaultDisplayTypes)
        end
    end


    self.savedVariables.displayTypesCount = {}
    local list
    local count
    for itemType = ITEMTYPE_ITERATION_BEGIN + 1, ITEMTYPE_MAX_VALUE do
        list = {}
        if itemType == ITEMTYPE_ARMOR and self.defaultArmorTable then
            table.insert(list, self.defaultArmorTable[itemType])

        elseif itemType == ITEMTYPE_WEAPON and self.defaultWeaponTable then
            table.insert(list, self.defaultWeaponTable[itemType])

        elseif itemType == ITEMTYPE_FURNISHING then
            table.insert(list, self.defaultFurnishingTable[itemType])

        elseif itemType == ITEMTYPE_RECIPE then
            table.insert(list, self.defaultRecipeTable[itemType])

        elseif self:ContainsNumber(itemType, ITEMTYPE_POISON,
                                             ITEMTYPE_POTION,
                                             ITEMTYPE_GLYPH_WEAPON,
                                             ITEMTYPE_GLYPH_ARMOR,
                                             ITEMTYPE_GLYPH_JEWELRY) then
            table.insert(list, self.defaultItemLinkTable[itemType])

        else
            table.insert(list, self.defaultItemTable[itemType])
        end
        table.insert(list, self.savedVariables.itemTable[itemType])

        count = 0
        for _, itemSubTable in pairs(list) do
            for key, value in pairs(itemSubTable) do
                count = count + 1
            end
        end
        self.savedVariables.displayTypesCount[itemType] = count
        self:Debug("　　<<1>>:<<2>> (<<3>> アイテム)", itemType, GetString("SI_ITEMTYPE", itemType), count)
    end


    local langCurrent = GetCVar("language.2")
    if langCurrent == "jp" then
        self.savedVariables.returnMessage = GetString(J2E_MSG_TORETURN)

        count = 0
        for key, value in pairs(self.savedVariables.newItemTable) do
            count = count + 1
        end
        for key, value in pairs(self.savedVariables.newItemLinkTable) do
            count = count + 1
        end
        if count > 100 then
            zo_callLater(function()
                self:Message(GetString(J2E_MSG_TOEN))
            end, 5000)
        end

    elseif langCurrent == "en" then

        self.updateTotal = 0
        local callTask = LibAsync:Create("Update Table")
        callTask:Delay(2000, function(task)
            self:UpdateSkillTable(task)

        end):Then(function(task)
            self:UpdateItemLinkTable(task)

        end):Then(function(task)
            self:UpdateItemTable(task)

        end):Delay(3000, function()
            if self.updateTotal == 0 then
                return
            end
            local defaultLang = self.savedVariables.defaultLanguage
            local returnMessage = self.savedVariables.returnMessage
            if defaultLang and returnMessage then
                local editControl = CHAT_SYSTEM:GetEditControl()
                if (not editControl:HasFocus()) then
                    StartChatInput()
                end
                editControl:SetText("/lang" .. defaultLang)
                self:Message(returnMessage)
            end

        end):Then(function(task)
            if GetDisplayName() == "@Marify" then
                self:UpdateCompare(task)
            end

        end)
    end
end




function J2EUpdate:OnMoveLabel(label)
    self:Debug("[OnMoveLabel]")

    local abilityId = label:GetName():gsub("J2EWindow", ""):gsub("Name", "")
    abilityId = tonumber(abilityId)
    self:Debug("　　abilityId=" .. tostring(abilityId))
    local abilityName = self:GetSkillName(abilityId)
    self:Debug("　　abilityName=" .. tostring(abilityName))
    local x = math.ceil(label:GetLeft())
    local y = math.ceil(label:GetTop())
    self:Debug("　　x=" .. tostring(x))
    self:Debug("　　y=" .. tostring(y))

    self.savedVariables.labelPositions[abilityId] = x .. "," .. y

end




function J2EUpdate:OnAddOnLoaded(event, addonName)

    if addonName ~= self.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    setmetatable(J2EUpdate, {__index = LibMarify})


    self:InitializeTable()
    self:InitializeCommand()
    self:CreateMenu()
    self:ResetCachedSkillFormat()
    self:ResetCachedItemFormat(true)


    if GetCVar("language.2") == "jp" then
        -- Pass
    --elseif GetCVar("language.2") == "en" and self.savedVariables.isCollectingData then
    --    -- Pass
    else
        return
    end


    EVENT_MANAGER:RegisterForEvent(self.name,  EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId, slotIndex) self:AddItemName(GetItemLink(bagId, slotIndex)) end)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)


    self.hookObjectNames = {
        ["SKILLS_WINDOW"]   = SKILLS_WINDOW,
        ["GAMEPAD_SKILLS"]  = GAMEPAD_SKILLS,
        ["ACTIVE"]          = ZO_ActiveSkillProgressionData,
        ["PASSIVE"]         = ZO_PassiveSkillProgressionData,
        ["LEFT"]            = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP),
        ["RIGHT"]           = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP),
        ["MOVABLE"]         = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP),
        ["ALCHEMY"]         = ALCHEMY.tooltip,
        ["ENCHANT"]         = ENCHANTING.resultTooltip,
        ["SMITHING"]        = ZO_SmithingCreation,
        ["ItemTooltip"]     = ItemTooltip,
        ["PopupTooltip"]    = PopupTooltip,

        ["DISCIPLINE_DATA"] = ZO_ChampionDisciplineData,            -- "C:/esoui/ingame/champion/championdatamanager.lua"
        ["CLUSTER_DATA"]    = ZO_ChampionClusterData,               -- "C:/esoui/ingame/champion/championdatamanager.lua"
        ["CP_SKILL_DATA"]   = ZO_ChampionSkillData,                 -- "C:/esoui/ingame/champion/championdatamanager.lua"
        ["CONSTELLATION"]   = ZO_ChampionConstellation,             -- "C:/esoui/ingame/champion/championconstellation.lua"
        ["CP_SLOT"]         = ZO_ChampionAssignableActionBarSlot,   -- "C:/esoui/ingame/champion/championassignableactionbar.lua"
        ["STAR"]            = ZO_ChampionSkillStar,                 -- "C:/esoui/ingame/champion/championstar.lua"
        ["PORTAL_STAR"]     = ZO_ChampionClusterPortalStar,         -- "C:/esoui/ingame/champion/championstar.lua"
        ["PERKS"]           = CHAMPION_PERKS,                       -- "C:/esoui/ingame/champion/champion.lua"
    }


    -- [ChampionPoint]
    self:PreHook("DISCIPLINE_DATA", "GetFormattedName",                      function(disciplineData)  self:SetDisciplineFormat(disciplineData)    end)
    self:PreHook("CLUSTER_DATA",    "GetFormattedName",                      function(clusterData)     self:SetClusterFormat(clusterData)          end)
    self:PreHook("CP_SKILL_DATA",   "GetFormattedName",                      function(skillData)       self:SetStarFormat(skillData)               end)
    self:PreHook("CP_SLOT",         "ShowTooltip",                           function(slot)            self:SetCpSkillFormat(slot)                 end)
    self:PreHook("STAR",            "ShowKeyboardTooltip",                   function(skillStar)       self:SetCpSkillFormat(skillStar)            end)

    self:PostHook("CP_SKILL_DATA",  "GetFormattedName",                      function()                self:ResetCachedSkillFormat()               end, self.disabledColor)
    self:PostHook("CP_SLOT",        "ShowTooltip",                           function(slot)            self:AddCpSkillName(slot)                   end)
    self:PostHook("STAR",           "ShowKeyboardTooltip",                   function(skillStar)       self:AddCpSkillName(skillStar)              end)
    self:PostHook("STAR",           "RefreshTexture",                        function(star)            self:ShowStarName(star)                     end)
    self:PostHook("PORTAL_STAR",    "RefreshTexture",                        function(star)            self:ShowClusterStarName(star)              end)
    self:PostHook("CONSTELLATION",  "SetActive",                             function()                J2EWindow:SetHidden(true)                   end, self.disabledColor)
    self:PostHook("PERKS",          "ResetToInactive",                       function()                J2EWindow:SetHidden(true)                   end, self.disabledColor)


    -- [Skill]
    self:PreHook("ACTIVE",          "SetKeyboardTooltip",                    function(skillData)       self:SetSkillFormat(skillData,  true)   end)
    self:PreHook("PASSIVE",         "SetKeyboardTooltip",                    function(skillData)       self:SetSkillFormat(skillData,  true)   end)
    self:PreHook("LEFT",            "LayoutAbilityWithSkillProgressionData", function(_, ...)          self:SetSkillFormat(({...})[2], true)   end)
    self:PreHook("LEFT",            "LayoutSkillProgression",                function(_, ...)          self:SetSkillFormat(({...})[1], true)   end)
    self:PreHook("ACTIVE",          "GetFormattedNameWithRank",              function(skillData)       self:SetSkillFormat(skillData,  false)  end)
    self:PreHook("ACTIVE",          "GetFormattedName",                      function(skillData)       self:SetSkillFormat(skillData,  false)  end)
    self:PreHook("PASSIVE",         "GetFormattedNameWithUpgradeLevels",     function(skillData)       self:SetSkillFormat(skillData,  false)  end)
    self:PreHook("PASSIVE",         "GetFormattedName",                      function(skillData)       self:SetSkillFormat(skillData,  false)  end)
    self:PreHook("SKILLS_WINDOW",   "RebuildSkillLineList",                  function()                self:SetSkillLineName()                 end)
    self:PreHook("GAMEPAD_SKILLS",  "RefreshCategoryList",                   function()                self:SetSkillLineName()                 end)

    self:PostHook("ACTIVE",         "SetKeyboardTooltip",                    function(skillData, ...)  self:AddSkillName(skillData, ...)       end)
    self:PostHook("PASSIVE",        "SetKeyboardTooltip",                    function(skillData, ...)  self:AddSkillName(skillData, ...)       end)
    self:PostHook("ACTIVE",         "GetFormattedNameWithRank",              function()                self:ResetCachedSkillFormat()           end, self.disabledColor)
    self:PostHook("ACTIVE",         "GetFormattedName",                      function()                self:ResetCachedSkillFormat()           end, self.disabledColor)
    self:PostHook("PASSIVE",        "GetFormattedNameWithUpgradeLevels",     function()                self:ResetCachedSkillFormat()           end, self.disabledColor)
    self:PostHook("PASSIVE",        "GetFormattedName",                      function()                self:ResetCachedSkillFormat()           end, self.disabledColor)
    self:PostHook("LEFT",           "LayoutSkillProgression",                function()                self:ResetCachedSkillFormat()           end, self.disabledColor)
    self:PostHook("LEFT",           "GetFormattedNameWithRank",              function()                self:ResetCachedSkillFormat()           end, self.disabledColor)


    -- [Item]
    self:PreHook("SMITHING",        "SetupResultTooltip",       function(_, ...)        self:SetItemFormat(GetSmithingPatternResultLink(...))               end)
    self:PreHook("ALCHEMY",         "SetPendingAlchemyItem",    function(_, ...)        self:SetItemFormat(GetAlchemyResultingItemLink(...))                end)
    self:PreHook("ENCHANT",         "SetPendingEnchantingItem", function(_, ...)        self:SetItemFormat(GetEnchantingResultingItemLink(...))             end)
    self:PreHook("ItemTooltip",     "SetBagItem",               function(_, ...)        self:SetItemFormat(GetItemLink(...))                                end)
    self:PreHook("ItemTooltip",     "SetWornItem",              function(_, ...)        self:SetItemFormat(GetItemLink(BAG_WORN, ...))                      end)
    self:PreHook("ItemTooltip",     "SetTradingHouseListing",   function(_, ...)        self:SetItemFormat(GetTradingHouseListingItemLink(...))             end)
    self:PreHook("ItemTooltip",     "SetTradingHouseItem",      function(_, ...)        self:SetItemFormat(GetTradingHouseSearchResultItemLink(...))        end)
    self:PreHook("ItemTooltip",     "SetAction",                function(_, ...)        self:SetItemFormat(GetSlotItemLink(...))                            end)
    self:PreHook("PopupTooltip",    "SetLink",                  function(_, ...)        self:SetItemFormat(...)                                             end)
    self:PreHook("LEFT",            "LayoutItem",               function(_, ...)        self:SetItemFormat(({...})[1])                                      end)
    self:PreHook("RIGHT",           "LayoutItem",               function(_, ...)        self:SetItemFormat(({...})[1])                                      end)
    self:PreHook("MOVABLE",         "LayoutItem",               function(_, ...)        self:SetItemFormat(({...})[1])                                      end)

    self:PostHook("SMITHING",       "SetupResultTooltip",       function(tooltip, ...)  self:AddItemName(tooltip, GetSmithingPatternResultLink(...))        end)
    self:PostHook("ALCHEMY",        "SetPendingAlchemyItem",    function(tooltip, ...)  self:AddItemName(tooltip, GetAlchemyResultingItemLink(...))         end)
    self:PostHook("ENCHANT",        "SetPendingEnchantingItem", function(tooltip, ...)  self:AddItemName(tooltip, GetEnchantingResultingItemLink(...))      end)
    self:PostHook("ItemTooltip",    "SetBagItem",               function(tooltip, ...)  self:AddItemName(tooltip, GetItemLink(...))                         end)
    self:PostHook("ItemTooltip",    "SetWornItem",              function(tooltip, ...)  self:AddItemName(tooltip, GetItemLink(BAG_WORN, ...))               end)
    self:PostHook("ItemTooltip",    "SetTradingHouseListing",   function(tooltip, ...)  self:AddItemName(tooltip, GetTradingHouseListingItemLink(...))      end)
    self:PostHook("ItemTooltip",    "SetTradingHouseItem",      function(tooltip, ...)  self:AddItemName(tooltip, GetTradingHouseSearchResultItemLink(...)) end)
    self:PostHook("ItemTooltip",    "SetAction",                function(tooltip, ...)  self:AddItemName(tooltip, GetSlotItemLink(...))                     end)
    self:PostHook("PopupTooltip",   "SetLink",                  function(tooltip, ...)  self:AddItemName(tooltip, ...)                                      end)
    self:PostHook("LEFT",           "LayoutItem",               function(tooltip, ...)  self:AddItemNameGamePad(tooltip, ...)                               end)
    self:PostHook("RIGHT",          "LayoutItem",               function(tooltip, ...)  self:AddItemNameGamePad(tooltip, ...)                               end)
    self:PostHook("MOVABLE",        "LayoutItem",               function(tooltip, ...)  self:AddItemNameGamePad(tooltip, ...)                               end)
    LibCustomMenu:RegisterContextMenu(function(...) self:ShowContextMenu(...) end, LibCustomMenu.CATEGORY_LATE)
    self:RegisterChatContextMenu(function(...) self:ShowChatContextMenu(...) end)


    if GetDisplayName() == "@Marify" then
        EVENT_MANAGER:RegisterForEvent(self.name,  EVENT_GUILD_BANK_ITEMS_READY, function(...) J2EUpdate:CheckItems() end)
    end
end




function J2EUpdate:PostHook(objectOrName, existingFunctionName, hookFunction, color)

    local objectTable = self.hookObjectNames[objectOrName]
    if objectTable == nil then
        self:Debug(zo_strformat("[PostHook] hookObjectNames[\"<<1>>\"] is NotFoud!", objectOrName), self.failedColor)
        return
    end

    if color == nil then
        color = self.hookColor
    end


    LibMarify:PostHook(objectTable,
                  existingFunctionName,
                  function(...)
                      J2EUpdate:Debug(zo_strformat("[Post]<<1>>:<<2>>", objectOrName, existingFunctionName), color)
                      hookFunction(...)
                  end)

end




function J2EUpdate:PreHook(objectOrName, existingFunctionName, hookFunction, color)

    local objectTable = self.hookObjectNames[objectOrName]
    if objectTable == nil then
        self:Debug(zo_strformat("[PostHook] hookObjectNames[\"<<1>>\"] is NotFoud!", objectOrName), self.failedColor)
        return
    end

    if color == nil then
        color = self.hookColor
    end


    ZO_PreHook(objectTable,
               existingFunctionName,
               function(...)
                   J2EUpdate:Debug(zo_strformat("[Pre]<<1>>:<<2>>", objectOrName, existingFunctionName), color)
                   hookFunction(...)
               end)

end




function J2EUpdate:RegisterChatContextMenu(func)

    local base = ZO_LinkHandler_OnLinkMouseUp
    ZO_LinkHandler_OnLinkMouseUp = function(itemLink, button, control)
        base(itemLink, button, control)

        if button ~= MOUSE_BUTTON_INDEX_RIGHT then
            return
        end
        

        zo_callLater(function()
            local itemNameJp = GetItemLinkName(itemLink)
            local editControl = CHAT_SYSTEM:GetEditControl()
            func(itemLink, button, control)
            ShowMenu(inventorySlot)
        end, 50)
    end
end




function J2EUpdate:ResetString(si)
    --self:Debug("　　[ResetString] <<1>>", si, self.checkColor)

    local origin = self.originFormats[si]
    if origin then
        self:UpdateString(si, origin)
    else
        self.originFormats[si]  = GetString(si)
    end
end




function J2EUpdate:ResetTable()
    self.savedVariables.skillLineTable = {}
    self.savedVariables.skillTable = {}
    self.savedVariables.itemLinkTable = {}
    self.savedVariables.itemTable = {}
    self.savedVariables.itemSetTable = {}
    self.savedVariables.newItemLinkTable = {}
    self.savedVariables.newItemTable = {}
    self:Message(GetString(J2E_RESET_TABLE))
end




function J2EUpdate:ShowChatContextMenu(itemLink, button, ...)

    if button ~= MOUSE_BUTTON_INDEX_RIGHT then
        return true
    end
    if itemLink == nil or itemLink == "" then
        return true
    end
    local _, _, type = ZO_LinkHandler_ParseLink(itemLink)
    if type ~= "item" then
        return true
    end


    local itemNameJp = GetItemLinkName(itemLink)
    local itemNameEn = self:GetItemName(itemLink)

    local editControl = CHAT_SYSTEM:GetEditControl()
    AddCustomMenuItem(GetString(J2E_COPY_ITEM_NAME_JP), function()
        if (not editControl:HasFocus()) then
            StartChatInput()
        end
        itemNameJp = string.gsub(itemNameJp, "(\^)%a*", "")
        editControl:SetText(itemNameJp)
    end)

    if itemNameEn then
        AddCustomMenuItem(GetString(J2E_COPY_ITEM_NAME_EN), function()
            if (not editControl:HasFocus()) then
                StartChatInput()
            end
            itemNameEn = string.gsub(itemNameEn, "(\^)%a*", "")
            editControl:SetText(itemNameEn)
        end)
    end
    return true
end




function J2EUpdate:ShowContextMenu(inventorySlot, slotActions)

    local slotType = ZO_InventorySlot_GetType(inventorySlot)
    local itemLink = nil

    -- @see http://wiki.esoui.com/Constant_Values
    if slotType == nil then
        return true

    elseif slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
        local slotIndex = ZO_Inventory_GetSlotIndex(inventorySlot)
        itemLink = GetTradingHouseSearchResultItemLink(slotIndex)

    elseif slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING then
        local slotIndex = ZO_Inventory_GetSlotIndex(inventorySlot)
        itemLink = GetTradingHouseListingItemLink(slotIndex)

    elseif slotType == SLOT_TYPE_ITEM
        or slotType == SLOT_TYPE_EQUIPMENT
        or slotType == SLOT_TYPE_BANK_ITEM
        or slotType == SLOT_TYPE_GUILD_BANK_ITEM then
        local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
        itemLink = GetItemLink(bagId, slotIndex)

    end
    if itemLink == nil or itemLink == "" then
        return true
    end


    local itemNameJp = GetItemLinkName(itemLink)
    local itemNameEn = self:GetItemName(itemLink)
    local hasSet, setNameEn = self:GetItemSetName(itemLink)


    local editControl = CHAT_SYSTEM:GetEditControl()
    AddCustomMenuItem(GetString(J2E_COPY_ITEM_NAME_JP), function()
        if (not editControl:HasFocus()) then
            StartChatInput()
        end
        itemNameJp = string.gsub(itemNameJp, "(\^)%a*", "")
        editControl:SetText(itemNameJp)
    end)

    if itemNameEn then
        AddCustomMenuItem(GetString(J2E_COPY_ITEM_NAME_EN), function()
            if (not editControl:HasFocus()) then
                StartChatInput()
            end
            itemNameEn = string.gsub(itemNameEn, "(\^)%a*", "")
            editControl:SetText(itemNameEn)
        end)
    end

    if setNameEn then
        AddCustomMenuItem(GetString(J2E_COPY_SET_NAME), function()
            if (not editControl:HasFocus()) then
                StartChatInput()
            end
            setNameEn = string.gsub(setNameEn, "(\^)%a*", "")
            editControl:SetText(setNameEn)
        end)
    end

    if GetDisplayName() == "@Marify" then
        AddCustomMenuItem("チャットに情報をコピー", function ()
            if (not editControl:HasFocus()) then
                StartChatInput()
            end
            local itemId = GetItemLinkItemId(itemLink)
            local itemType, specializedItemType = GetItemLinkItemType(itemLink)
            local traitInfo = GetItemTraitInformationFromItemLink(itemLink)
            local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
            local txt = tostring(itemNameJp)
                        .. ", itemId=" .. tostring(itemId)
                        .. ", itemType=" .. tostring(itemType)
                        .. ":" .. GetString("SI_ITEMTYPE", itemType)
                        .. ", specializedItemType=" .. tostring(specializedItemType)
                        .. ":" .. GetString("SI_SPECIALIZEDITEMTYPE", specializedItemType)
                        .. ", traitInfo=" .. tostring(traitInfo)
                        .. ", setId=" .. tostring(setId)
            editControl:SetText(txt)
        end, MENU_ADD_OPTION_LABEL)
    end
    return true
end




function J2EUpdate:UpdateString(id, value)
    --self:Debug("　　[UpdateString] <<1>>:<<2>>", id, value)
    local version = EsoStringVersions[id]
    SafeAddString(id, value, version)
end

EVENT_MANAGER:RegisterForEvent(J2EUpdate.name, EVENT_ADD_ON_LOADED, function(...) J2EUpdate:OnAddOnLoaded(...) end)

