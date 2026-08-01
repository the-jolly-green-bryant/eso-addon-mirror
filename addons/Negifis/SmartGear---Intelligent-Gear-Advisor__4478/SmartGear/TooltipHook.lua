----------------------------------------------------------------------
-- SmartGear — Tooltip Hook
-- Injects gear recommendations into item tooltips
----------------------------------------------------------------------
SmartGear = SmartGear or {}

-- Color constants
local COLOR_GREEN   = "|c00FF00"
local COLOR_YELLOW  = "|cFFFF00"
local COLOR_ORANGE  = "|cFF8800"
local COLOR_RED     = "|cFF3333"
local COLOR_CYAN    = "|c00DDFF"
local COLOR_GRAY    = "|c888888"
local COLOR_WHITE   = "|cFFFFFF"
local COLOR_GOLD    = "|cFFD700"
local COLOR_PURPLE  = "|cAA55FF"
local COLOR_RESET   = "|r"

----------------------------------------------------------------------
-- Rating display configuration
----------------------------------------------------------------------
local RatingDisplay = {
    [SmartGear.RATING_RECOMMENDED] = {
        color = COLOR_GREEN,
        label_en = "RECOMMENDED",
        label_ru = "РЕКОМЕНДОВАНО",
        stars = "[***]",
    },
    [SmartGear.RATING_GOOD] = {
        color = COLOR_GREEN,
        label_en = "GOOD",
        label_ru = "ХОРОШО",
        stars = "[** ]",
    },
    [SmartGear.RATING_DECENT] = {
        color = COLOR_YELLOW,
        label_en = "DECENT",
        label_ru = "НЕПЛОХО",
        stars = "[*  ]",
    },
    [SmartGear.RATING_MAYBE] = {
        color = COLOR_ORANGE,
        label_en = "MAYBE",
        label_ru = "ВОЗМОЖНО",
        stars = "[?  ]",
    },
    [SmartGear.RATING_BAD] = {
        color = COLOR_RED,
        label_en = "NOT FOR YOU",
        label_ru = "НЕ ПОДХОДИТ",
        stars = "[x  ]",
    },
    [SmartGear.RATING_STICKERBOOK] = {
        color = COLOR_PURPLE,
        label_en = "COLLECT (Stickerbook)",
        label_ru = "СОБЕРИ (Стикербук)",
        stars = "[!  ]",
    },
}

----------------------------------------------------------------------
-- Build tooltip text lines from evaluation result
----------------------------------------------------------------------
local function BuildTooltipLines(eval)
    if not eval then return nil end

    local settings = SmartGear.savedVars
    local lang = SmartGear.currentLang or "en"
    local lines = {}

    -- Header separator
    table.insert(lines, {
        text = COLOR_CYAN .. "=== SmartGear ===" .. COLOR_RESET,
        color = {0, 0.87, 1, 1},
    })

    -- Rating line
    local display = RatingDisplay[eval.rating]
    if display and settings.showStars then
        local label = lang == "ru" and display.label_ru or display.label_en
        local ratingText = display.color .. display.stars .. " " .. label .. COLOR_RESET
        -- Append numeric score
        if eval.score then
            ratingText = ratingText .. COLOR_GRAY .. "  [" .. eval.score .. "]" .. COLOR_RESET
        end
        table.insert(lines, { text = ratingText })
    end

    -- Details section
    if settings.showDetails then
        -- Role + Context
        local roleName = SmartGear.GetRoleDisplayName(eval.role)
        local context = SmartGear.lastContext or SmartGear.GetContentContext()
        local ctxInfo = SmartGear.ContentContexts and SmartGear.ContentContexts[context]
        local ctxName = ctxInfo and (lang == "ru" and ctxInfo.nameRu or ctxInfo.name) or ""
        table.insert(lines, {
            text = COLOR_GRAY .. (lang == "ru" and "Роль: " or "Role: ")
                .. COLOR_YELLOW .. roleName .. COLOR_RESET
                .. COLOR_GRAY .. " | " .. COLOR_CYAN .. ctxName .. COLOR_RESET,
        })

        -- Meta set info
        if eval.isMetaSet then
            local tierColor = COLOR_WHITE
            if eval.metaTier == "S" then tierColor = COLOR_GOLD
            elseif eval.metaTier == "A" then tierColor = COLOR_GREEN
            elseif eval.metaTier == "B" then tierColor = COLOR_YELLOW
            elseif eval.metaTier == "C" then tierColor = COLOR_ORANGE end

            local setLine = COLOR_GRAY .. (lang == "ru" and "Мета-сет: " or "Meta set: ")
            setLine = setLine .. tierColor .. eval.setName .. " (" .. eval.metaTier .. "-tier)" .. COLOR_RESET

            if eval.isForCurrentRole then
                setLine = setLine .. COLOR_GREEN .. " (+)" .. COLOR_RESET
            else
                setLine = setLine .. COLOR_RED .. " (x) " .. (lang == "ru" and "(не ваша роль)" or "(wrong role)") .. COLOR_RESET
            end
            table.insert(lines, { text = setLine })

            -- Notes
            if eval.metaNotes then
                table.insert(lines, {
                    text = COLOR_GRAY .. "  " .. eval.metaNotes .. COLOR_RESET,
                })
            end

            -- Mythic / Monster set marker
            if eval.isMythic then
                table.insert(lines, {
                    text = COLOR_GOLD .. (lang == "ru" and "  >>Мифический предмет" or "  >>Mythic Item") .. COLOR_RESET,
                })
            elseif eval.isMonsterSet then
                table.insert(lines, {
                    text = COLOR_PURPLE .. (lang == "ru" and "  >>Монстр-сет" or "  >>Monster Set") .. COLOR_RESET,
                })
            end
        elseif eval.setName then
            -- Non-meta set
            table.insert(lines, {
                text = COLOR_GRAY .. (lang == "ru" and "Сет: " or "Set: ") .. COLOR_WHITE .. eval.setName .. COLOR_RESET,
            })
        end

        -- Set synergy
        if eval.setName then
            local synergyLine = COLOR_GRAY
            if eval.completesSet then
                synergyLine = synergyLine .. (lang == "ru" and "Бонус: " or "Bonus: ")
                synergyLine = synergyLine .. COLOR_GREEN .. (lang == "ru" and "Замыкает сет!" or "Completes set!") .. COLOR_RESET
            elseif eval.isEquippedSet then
                synergyLine = synergyLine .. (lang == "ru" and "Бонус: " or "Bonus: ")
                synergyLine = synergyLine .. COLOR_YELLOW .. eval.setEquipped .. "/" .. eval.setMax
                synergyLine = synergyLine .. (lang == "ru" and " (уже надето)" or " (already worn)") .. COLOR_RESET
            end
            if eval.isEquippedSet or eval.completesSet then
                table.insert(lines, { text = synergyLine })
            end
        end

        -- Trait
        if eval.traitName then
            local traitLine = COLOR_GRAY .. (lang == "ru" and "Трейт: " or "Trait: ")
            if eval.isOptimalTrait then
                traitLine = traitLine .. COLOR_GREEN .. eval.traitName .. " (+) "
                traitLine = traitLine .. (lang == "ru" and "(идеально)" or "(optimal)") .. COLOR_RESET
            elseif eval.traitQuality == "good" then
                traitLine = traitLine .. COLOR_YELLOW .. eval.traitName .. " ~ "
                traitLine = traitLine .. (lang == "ru" and "(приемлемо)" or "(acceptable)") .. COLOR_RESET
            elseif eval.traitQuality == "suboptimal" then
                traitLine = traitLine .. COLOR_ORANGE .. eval.traitName .. " (x) "
                traitLine = traitLine .. (lang == "ru" and "(не оптимально)" or "(suboptimal)") .. COLOR_RESET
            else
                traitLine = traitLine .. COLOR_RED .. eval.traitName .. " (x) "
                traitLine = traitLine .. (lang == "ru" and "(плохо)" or "(bad)") .. COLOR_RESET
            end
            table.insert(lines, { text = traitLine })

            -- Transmute recommendation
            if eval.recommendTransmute then
                local roleConfig = SmartGear.RoleConfig[eval.role]
                local optimalName = ""
                if roleConfig then
                    local pvp = SmartGear.savedVars and SmartGear.savedVars.pvpMode
                    local traits = pvp and roleConfig.pvpTraits or roleConfig.optimalTraits
                    if traits then
                        for traitId, _ in pairs(traits) do
                            optimalName = SmartGear.TraitNames[traitId] or ""
                            break
                        end
                    end
                end
                table.insert(lines, {
                    text = COLOR_CYAN .. "  → " .. (lang == "ru" and "Трансмутируй в " or "Transmute to ")
                        .. optimalName .. COLOR_RESET,
                })
            end
        end

        -- Armor weight
        if eval.armorWeight and eval.armorWeight ~= ARMORTYPE_NONE then
            local weightNames = {
                [ARMORTYPE_LIGHT] = lang == "ru" and "Лёгкая" or "Light",
                [ARMORTYPE_MEDIUM] = lang == "ru" and "Средняя" or "Medium",
                [ARMORTYPE_HEAVY] = lang == "ru" and "Тяжёлая" or "Heavy",
            }
            local weightName = weightNames[eval.armorWeight] or "?"
            local weightLine = COLOR_GRAY .. (lang == "ru" and "Вес: " or "Weight: ")
            if eval.isOptimalWeight then
                weightLine = weightLine .. COLOR_GREEN .. weightName .. " (+)" .. COLOR_RESET
            else
                weightLine = weightLine .. COLOR_RED .. weightName .. " (x)" .. COLOR_RESET
            end
            table.insert(lines, { text = weightLine })
        end

        -- Item level display
        if eval.itemLevel and eval.itemLevel > 0 then
            local maxLevel = 210
            local levelColor = COLOR_GREEN
            if eval.itemLevel < maxLevel * 0.5 then
                levelColor = COLOR_RED
            elseif eval.itemLevel < maxLevel * 0.8 then
                levelColor = COLOR_ORANGE
            elseif eval.itemLevel < maxLevel then
                levelColor = COLOR_YELLOW
            end

            local levelLabel = ""
            if eval.requiredCP and eval.requiredCP > 0 then
                levelLabel = "CP " .. eval.requiredCP
            else
                levelLabel = (lang == "ru" and "Ур. " or "Lv. ") .. eval.requiredLevel
            end

            table.insert(lines, {
                text = COLOR_GRAY .. (lang == "ru" and "Уровень: " or "Level: ")
                    .. levelColor .. levelLabel .. COLOR_RESET,
            })
        end
    end

    -- Adaptive scoring info
    if settings.showDetails then
        local hasAdaptive = false
        local adaptLine = COLOR_GRAY .. "  "
            .. (lang == "ru" and "Адаптивно: " or "Adaptive: ")

        if eval.traitGapAdjust and eval.traitGapAdjust ~= 0 then
            local c = eval.traitGapAdjust > 0 and COLOR_GREEN or COLOR_RED
            local s = eval.traitGapAdjust > 0 and "+" or ""
            adaptLine = adaptLine .. c .. s .. eval.traitGapAdjust
                .. (lang == "ru" and " трейт" or " trait") .. COLOR_RESET
            hasAdaptive = true
        end

        if eval.setGapAdjust and eval.setGapAdjust ~= 0 then
            local c = eval.setGapAdjust > 0 and COLOR_GREEN or COLOR_RED
            local s = eval.setGapAdjust > 0 and "+" or ""
            if hasAdaptive then adaptLine = adaptLine .. ", " end
            adaptLine = adaptLine .. c .. s .. eval.setGapAdjust
                .. (lang == "ru" and " сет" or " set") .. COLOR_RESET
            hasAdaptive = true
        end

        if hasAdaptive then
            adaptLine = adaptLine .. COLOR_GRAY
                .. (lang == "ru" and " (ваш билд)" or " (your build)") .. COLOR_RESET
            table.insert(lines, { text = adaptLine })
        end

        -- Mundus info if relevant to trait
        if eval.traitGapAdjust and eval.traitGapAdjust ~= 0 then
            local p = SmartGear.PlayerProfile
            if p and p.mundusName and p.mundusName ~= "" then
                local mName = lang == "ru" and (p.mundusNameRu or p.mundusName) or p.mundusName
                table.insert(lines, {
                    text = COLOR_GRAY .. "  "
                        .. (lang == "ru" and "Мундус: " or "Mundus: ")
                        .. COLOR_CYAN .. mName .. COLOR_RESET,
                })
            end
        end
    end

    -- Stickerbook note
    if eval.rating == SmartGear.RATING_STICKERBOOK and settings.showStickerbook then
        table.insert(lines, {
            text = COLOR_PURPLE .. (lang == "ru"
                and "  Мета-сет для других ролей — добавь в стикербук!"
                or  "  Meta set for other roles — add to stickerbook!") .. COLOR_RESET,
        })
    end

    return lines
end

----------------------------------------------------------------------
-- Build comparison tooltip lines
----------------------------------------------------------------------
local function BuildComparisonLines(comp)
    if not comp then return nil end

    local lang = SmartGear.currentLang or "en"
    local lines = {}

    -- Comparison header
    table.insert(lines, {
        text = COLOR_CYAN .. (lang == "ru" and "--- vs ---" or "--- vs Equipped ---") .. COLOR_RESET,
    })

    -- Verdict line with arrow
    local verdictText = ""
    if comp.verdict == "upgrade" then
        verdictText = COLOR_GREEN .. "^"
            .. (lang == "ru" and "УЛУЧШЕНИЕ" or "UPGRADE")
            .. " (+" .. comp.scoreDiff .. ")" .. COLOR_RESET
    elseif comp.verdict == "slight_upgrade" then
        verdictText = COLOR_GREEN .. "^"
            .. (lang == "ru" and "НЕБОЛЬШОЕ УЛУЧШЕНИЕ" or "SLIGHT UPGRADE")
            .. " (+" .. comp.scoreDiff .. ")" .. COLOR_RESET
    elseif comp.verdict == "sidegrade" then
        verdictText = COLOR_YELLOW .. "~"
            .. (lang == "ru" and "РАВНОЗНАЧНО" or "SIDEGRADE")
            .. " (" .. (comp.scoreDiff >= 0 and "+" or "") .. comp.scoreDiff .. ")" .. COLOR_RESET
    elseif comp.verdict == "slight_downgrade" then
        verdictText = COLOR_ORANGE .. "v"
            .. (lang == "ru" and "НЕБОЛЬШОЕ УХУДШЕНИЕ" or "SLIGHT DOWNGRADE")
            .. " (" .. comp.scoreDiff .. ")" .. COLOR_RESET
    elseif comp.verdict == "downgrade" then
        verdictText = COLOR_RED .. "v"
            .. (lang == "ru" and "УХУДШЕНИЕ" or "DOWNGRADE")
            .. " (" .. comp.scoreDiff .. ")" .. COLOR_RESET
    end
    table.insert(lines, { text = verdictText })

    -- Numeric score comparison line: [new] vs [equipped]
    if comp.newScore and comp.equippedScore then
        local scoreCompLine = COLOR_GRAY .. "  "
            .. (lang == "ru" and "Рейтинг: " or "Score: ")
            .. COLOR_WHITE .. comp.newScore
            .. COLOR_GRAY .. " vs "
            .. COLOR_WHITE .. comp.equippedScore
            .. COLOR_RESET
        table.insert(lines, { text = scoreCompLine })
    end

    -- Slot label (Ring 1, Main Bar, etc.)
    local slotLabel = comp.slotLabel or ""
    local slotLabelRu = {
        ["Ring 1"] = "Кольцо 1", ["Ring 2"] = "Кольцо 2",
        ["Main Bar"] = "Основная панель", ["Backup Bar"] = "Запасная панель",
        ["Main Hand"] = "Основная рука", ["Off Hand"] = "Вторая рука",
        ["Backup Main"] = "Запасная основная", ["Backup Off"] = "Запасная вторая",
        ["Main Bar Off-hand"] = "Основная панель (оффхенд)",
        ["Backup Bar Off-hand"] = "Запасная панель (оффхенд)",
        ["Head"] = "Голова", ["Chest"] = "Грудь", ["Shoulders"] = "Плечи",
        ["Waist"] = "Пояс", ["Legs"] = "Ноги", ["Feet"] = "Ступни",
        ["Hands"] = "Руки", ["Neck"] = "Шея",
    }
    local displaySlotLabel = lang == "ru" and (slotLabelRu[slotLabel] or slotLabel) or slotLabel

    -- What it replaces
    if comp.slotEmpty then
        local emptyText = COLOR_GRAY
        if displaySlotLabel ~= "" then
            emptyText = emptyText .. COLOR_CYAN .. "[" .. displaySlotLabel .. "] " .. COLOR_RESET .. COLOR_GRAY
        end
        emptyText = emptyText .. (lang == "ru" and "Слот пуст — надевай!" or "Empty slot — equip it!") .. COLOR_RESET
        table.insert(lines, { text = "  " .. emptyText })
    else
        -- Show slot label for paired slots
        if displaySlotLabel ~= "" then
            table.insert(lines, {
                text = COLOR_GRAY .. "  " .. (lang == "ru" and "Слот: " or "Slot: ")
                    .. COLOR_CYAN .. displaySlotLabel .. COLOR_RESET,
            })
        end

        -- Show equipped item name
        local replaceLine = COLOR_GRAY
            .. (lang == "ru" and "  Заменяет: " or "  Replaces: ")
            .. COLOR_WHITE .. comp.equippedName .. COLOR_RESET
        table.insert(lines, { text = replaceLine })

        -- Show equipped set if different
        if comp.equippedSetName then
            local eqSetLine = COLOR_GRAY .. "  "
                .. (lang == "ru" and "Текущий сет: " or "Current set: ")
                .. COLOR_WHITE .. comp.equippedSetName .. COLOR_RESET
            table.insert(lines, { text = eqSetLine })
        end
    end

    -- Detailed changes
    if #comp.changes > 0 then
        for _, change in ipairs(comp.changes) do
            local changeText = "  "
            local arrow = change.direction == "up" and (COLOR_GREEN .. "  ^") or (COLOR_RED .. "  v")

            if change.detail == "empty_slot" then
                changeText = arrow .. (lang == "ru" and "Пустой слот" or "Empty slot") .. COLOR_RESET
            elseif change.detail == "meta_vs_nonmeta" then
                changeText = arrow .. (lang == "ru" and "Мета-сет вместо обычного" or "Meta set replaces non-meta") .. COLOR_RESET
            elseif change.detail == "nonmeta_vs_meta" then
                changeText = arrow .. (lang == "ru" and "Обычный сет вместо мета" or "Non-meta replaces meta set") .. COLOR_RESET
            elseif change.detail == "higher_tier" then
                changeText = arrow .. (lang == "ru" and "Сет выше тиром" or "Higher tier set") .. COLOR_RESET
            elseif change.detail == "lower_tier" then
                changeText = arrow .. (lang == "ru" and "Сет ниже тиром" or "Lower tier set") .. COLOR_RESET
            elseif change.detail == "completes_set" then
                changeText = arrow .. (lang == "ru" and "Замыкает сетовый бонус!" or "Completes set bonus!") .. COLOR_RESET
            elseif change.detail == "better_trait" then
                changeText = arrow .. (lang == "ru" and "Лучший трейт" or "Better trait") .. COLOR_RESET
            elseif change.detail == "worse_trait" then
                changeText = arrow .. (lang == "ru" and "Худший трейт" or "Worse trait") .. COLOR_RESET
            elseif change.detail == "better_weight" then
                changeText = arrow .. (lang == "ru" and "Правильный вес брони" or "Correct armor weight") .. COLOR_RESET
            elseif change.detail == "worse_weight" then
                changeText = arrow .. (lang == "ru" and "Неправильный вес брони" or "Wrong armor weight") .. COLOR_RESET
            elseif change.detail == "higher_quality" then
                changeText = arrow .. (lang == "ru" and "Выше качество" or "Higher quality") .. COLOR_RESET
            elseif change.detail == "lower_quality" then
                changeText = arrow .. (lang == "ru" and "Ниже качество" or "Lower quality") .. COLOR_RESET
            elseif change.detail == "higher_level" then
                changeText = arrow .. (lang == "ru" and "Выше уровень" or "Higher level")
                    .. " (" .. (change.value or "") .. ")" .. COLOR_RESET
            elseif change.detail == "lower_level" then
                changeText = arrow .. (lang == "ru" and "Ниже уровень" or "Lower level")
                    .. " (" .. (change.value or "") .. ")" .. COLOR_RESET
            elseif change.detail == "trait_wrong_hand" then
                changeText = COLOR_RED .. "  ! " .. (lang == "ru"
                    and "Nirnhoned в оффхенде (18% скейлинг!)"
                    or "Nirnhoned in off-hand (18% scaling!)") .. COLOR_RESET
            elseif change.detail == "trait_correct_hand" then
                changeText = COLOR_GREEN .. "  (+) " .. (lang == "ru"
                    and "Nirnhoned в основной руке (100%)"
                    or "Nirnhoned in main hand (100%)") .. COLOR_RESET
            elseif change.detail == "dw_expert_bad_offhand" then
                changeText = COLOR_RED .. "  ! " .. (lang == "ru"
                    and "Кинжал в оффхенде: низкий урон для Эксперта ПО"
                    or "Dagger in off-hand: low dmg for DW Expert") .. COLOR_RESET
            elseif change.detail == "dw_expert_good_offhand" then
                changeText = COLOR_GREEN .. "  (+) " .. (lang == "ru"
                    and "Высокий урон в оффхенде (Эксперт ПО +3%)"
                    or "High dmg in off-hand (DW Expert +3%)") .. COLOR_RESET
            elseif change.detail == "dagger_main_optimal" then
                changeText = COLOR_GREEN .. "  (+) " .. (lang == "ru"
                    and "Кинжал в основной руке (оптимально)"
                    or "Dagger in main hand (optimal)") .. COLOR_RESET
            elseif change.detail == "high_dmg_main_waste" then
                changeText = COLOR_ORANGE .. "  ? " .. (lang == "ru"
                    and "Лучше в оффхенд (Эксперт ПО)"
                    or "Better in off-hand (DW Expert)") .. COLOR_RESET
            elseif change.detail == "displaces_offhand" then
                local offName = change.value or "?"
                local pen = change.penalty or 0
                changeText = COLOR_RED .. "  ! " .. (lang == "ru"
                    and "Уберет оффхенд: " .. offName .. " (-" .. pen .. ")"
                    or  "Removes off-hand: " .. offName .. " (-" .. pen .. ")") .. COLOR_RESET
            elseif change.detail == "dw_bonus" then
                -- Info line, not up/down
                local bonusName = change.value or ""
                changeText = COLOR_CYAN .. "  >> DW: " .. bonusName .. COLOR_RESET
            end

            table.insert(lines, { text = changeText })
        end
    end

    return lines
end

----------------------------------------------------------------------
-- Add lines to a tooltip control
----------------------------------------------------------------------
local function AddLinesToTooltip(tooltip, lines)
    if not lines or #lines == 0 then return end

    -- Add a small separator
    tooltip:AddVerticalPadding(8)

    for _, lineData in ipairs(lines) do
        tooltip:AddLine(lineData.text, "ZoFontGameSmall", 1, 1, 1, 1, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
    end

    tooltip:AddVerticalPadding(4)
end

----------------------------------------------------------------------
-- Tooltip hook handlers
----------------------------------------------------------------------
local function OnSetItemTooltip(tooltip, bagId, slotIndex)
    if not SmartGear.savedVars or not SmartGear.savedVars.showTooltips then return end

    -- Evaluation + rating
    local eval = SmartGear.EvaluateItem(bagId, slotIndex)
    local lines = BuildTooltipLines(eval)
    AddLinesToTooltip(tooltip, lines)

    -- Comparison with equipped (only for bag items, not already equipped)
    if bagId ~= BAG_WORN and SmartGear.savedVars.showComparison then
        local comp = SmartGear.CompareWithEquipped(bagId, slotIndex)
        local compLines = BuildComparisonLines(comp)
        AddLinesToTooltip(tooltip, compLines)
    end
end

local function OnSetItemLinkTooltip(tooltip, itemLink)
    if not SmartGear.savedVars or not SmartGear.savedVars.showTooltips then return end

    -- Evaluation + rating
    local eval = SmartGear.EvaluateItemLink(itemLink)
    local lines = BuildTooltipLines(eval)
    AddLinesToTooltip(tooltip, lines)

    -- Comparison with equipped
    if SmartGear.savedVars.showComparison then
        local comp = SmartGear.CompareWithEquippedByLink(itemLink)
        local compLines = BuildComparisonLines(comp)
        AddLinesToTooltip(tooltip, compLines)
    end
end

----------------------------------------------------------------------
-- Initialize tooltip hooks
----------------------------------------------------------------------
function SmartGear.InitTooltipHooks()
    -- Hook inventory item tooltips (bag items)
    ZO_PreHookHandler(ItemTooltip, "OnUpdate", function() end) -- ensure tooltip exists

    -- Hook the main tooltip set functions
    local origSetBagItem = ItemTooltip.SetBagItem
    if origSetBagItem then
        ItemTooltip.SetBagItem = function(self, bagId, slotIndex, ...)
            origSetBagItem(self, bagId, slotIndex, ...)
            OnSetItemTooltip(self, bagId, slotIndex)
        end
    end

    local origSetLootItem = ItemTooltip.SetLootItem
    if origSetLootItem then
        ItemTooltip.SetLootItem = function(self, lootId, ...)
            origSetLootItem(self, lootId, ...)
            -- Loot items don't have bag/slot, try link-based eval
            local itemLink = GetLootItemLink(lootId)
            if itemLink then
                OnSetItemLinkTooltip(self, itemLink)
            end
        end
    end

    -- Hook link-based tooltips (chat links, store, etc.)
    local origSetLink = ItemTooltip.SetLink
    if origSetLink then
        ItemTooltip.SetLink = function(self, itemLink, ...)
            origSetLink(self, itemLink, ...)
            OnSetItemLinkTooltip(self, itemLink)
        end
    end

    -- Hook PopupTooltip as well
    if PopupTooltip then
        local origPopupSetLink = PopupTooltip.SetLink
        if origPopupSetLink then
            PopupTooltip.SetLink = function(self, itemLink, ...)
                origPopupSetLink(self, itemLink, ...)
                OnSetItemLinkTooltip(self, itemLink)
            end
        end
    end

    -- Hook trading house / guild store tooltips
    local origSetTrading = ItemTooltip.SetTradingHouseItem
    if origSetTrading then
        ItemTooltip.SetTradingHouseItem = function(self, tradingHouseIndex, ...)
            origSetTrading(self, tradingHouseIndex, ...)
            local itemLink = GetTradingHouseSearchResultItemLink(tradingHouseIndex)
            if itemLink then
                OnSetItemLinkTooltip(self, itemLink)
            end
        end
    end

    -- Hook equipped item tooltips
    local origSetWornItem = ItemTooltip.SetWornItem
    if origSetWornItem then
        ItemTooltip.SetWornItem = function(self, slotIndex, ...)
            origSetWornItem(self, slotIndex, ...)
            OnSetItemTooltip(self, BAG_WORN, slotIndex)
        end
    end
end
