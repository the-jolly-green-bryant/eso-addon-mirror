-- CharacterMarkdown - Equipment Table Generator
-- Generates equipment and active set tables

local CM = CharacterMarkdown
CM.generators = CM.generators or {}
CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.equipment = CM.generators.sections.equipment or {}

local helpers = CM.generators.sections.equipment
local gear = {}

-- =====================================================
-- EQUIPMENT
-- =====================================================

local function GenerateEquipmentInternal(equipmentData, noWrapper)
    helpers.InitializeUtilities()
    local cache = helpers.cache
    local markdown_utils = cache.markdown

    if not equipmentData or type(equipmentData) ~= "table" or (not equipmentData.sets and not equipmentData.items) then
        return ""
    end

    local bodyParts = {}

    -- SET DISPLAY
    if equipmentData.sets and type(equipmentData.sets) == "table" and #equipmentData.sets > 0 then
        local CreateStyledTable = markdown_utils and markdown_utils.CreateStyledTable
        if CreateStyledTable then
            local headers = { "Set", "Progress" }
            local rows = {}

            for _, set in ipairs(equipmentData.sets) do
                local maxPieces = 5
                local indicator = "•"
                if markdown_utils and markdown_utils.GetProgressIndicator then
                    local success_ind, ind =
                        pcall(markdown_utils.GetProgressIndicator, math.min(set.count or 0, maxPieces), maxPieces)
                    if success_ind and ind then
                        indicator = tostring(ind)
                    end
                end

                local setLink = cache.CreateSetLink(set.name or "")
                local setTypeBadge = helpers.GetSetTypeBadge(set.setTypeName)
                if setTypeBadge ~= "" then
                    setTypeBadge = " " .. setTypeBadge
                end

                local progressText = ""
                if markdown_utils and markdown_utils.CreateProgressBar then
                    local success_pb, progressBar =
                        pcall(markdown_utils.CreateProgressBar, math.min(set.count or 0, maxPieces), maxPieces, 10)
                    if success_pb and progressBar then
                        local pieceCount = set.count or 0
                        if pieceCount > maxPieces then
                            progressText = string.format(
                                "`%d/%d` %s *(+%d extra)*",
                                maxPieces,
                                maxPieces,
                                progressBar,
                                pieceCount - maxPieces
                            )
                        else
                            progressText = string.format("`%d/%d` %s", pieceCount, maxPieces, progressBar)
                        end
                    else
                        progressText = string.format("`%d/%d`", set.count or 0, maxPieces)
                    end
                else
                    local pieceCount = set.count or 0
                    if pieceCount > maxPieces then
                        progressText =
                            string.format("`%d/%d` *(+%d extra)*", maxPieces, maxPieces, pieceCount - maxPieces)
                    else
                        progressText = string.format("`%d/%d`", pieceCount, maxPieces)
                    end
                end

                table.insert(rows, { indicator .. " **" .. setLink .. "**" .. setTypeBadge, progressText })
            end

            local options = { alignment = { "left", "left" }, coloredHeaders = true }
            table.insert(bodyParts, CreateStyledTable(headers, rows, options))
        else
            -- Fallback table
            local setTableParts = { "| Set | Progress |\n|---|---|\n" }
            for _, set in ipairs(equipmentData.sets) do
                local setLink = cache.CreateSetLink(set.name or "")
                table.insert(setTableParts, string.format("| **%s** | %d/5 |\n", setLink, set.count or 0))
            end
            table.insert(setTableParts, "\n")
            table.insert(bodyParts, table.concat(setTableParts))
        end
    end

    -- EQUIPMENT DETAILS
    if equipmentData.items and type(equipmentData.items) == "table" and #equipmentData.items > 0 then
        local detailsParts = { "### 📋 Equipment Details\n\n" }

        local setInfoLookup = {}
        if equipmentData.sets and type(equipmentData.sets) == "table" then
            for _, set in ipairs(equipmentData.sets) do
                if set.name then
                    setInfoLookup[set.name] = set
                end
            end
        end

        local headers = { "Slot", "Item", "Set", "Quality", "Trait", "Type", "Enchantment" }
        local rows = {}

        for _, item in ipairs(equipmentData.items) do
            local setLink = cache.CreateSetLink(item.setName or "")
            local setInfo = setInfoLookup[item.setName]
            if setInfo and setInfo.setTypeName then
                local setTypeBadge = helpers.GetSetTypeBadge(setInfo.setTypeName)
                setLink = setLink .. " " .. setTypeBadge
            end

            local itemType = ""
            if item.armorType then
                local success_armor, armorTypeName = pcall(GetString, "SI_ARMORTYPE", item.armorType)
                if success_armor and armorTypeName ~= "" then
                    itemType = armorTypeName
                end
            elseif item.weaponType then
                local success_weapon, weaponTypeName = pcall(GetString, "SI_WEAPONTYPE", item.weaponType)
                if success_weapon and weaponTypeName ~= "" then
                    itemType = weaponTypeName
                end
            end

            local itemIndicators = {}
            if item.isCrafted then
                table.insert(itemIndicators, "⚒️ Crafted")
            end
            if item.isStolen then
                table.insert(itemIndicators, "👤 Stolen")
            end
            if #itemIndicators > 0 then
                itemType = itemType .. (#itemType > 0 and " • " or "") .. table.concat(itemIndicators, " • ")
            end

            local enchantText = "-"
            local hasEnchantment = (item.enchantment and item.enchantment ~= false)
                or (item.enchantCharge ~= nil and item.enchantCharge ~= 0)
            if hasEnchantment then
                local enchantName = (type(item.enchantment) == "string") and item.enchantment or ""
                local charge = tonumber(item.enchantCharge) or 0
                local maxCharge = tonumber(item.enchantMaxCharge) or 0

                if enchantName ~= "" then
                    if maxCharge > 0 then
                        enchantText = string.format("%s (%d/%d)", enchantName, charge, maxCharge)
                    else
                        enchantText = enchantName
                    end
                elseif maxCharge > 0 then
                    enchantText = string.format("Unknown (%d/%d)", charge, maxCharge)
                end
            end

            table.insert(rows, {
                (item.emoji or "📦") .. " **" .. (item.slotName or "Unknown") .. "**",
                item.name or "-",
                setLink or "-",
                (item.qualityEmoji or "⚪") .. " " .. (item.quality or "Normal"),
                item.trait or "None",
                (itemType ~= "" and itemType) or "-",
                enchantText,
            })
        end

        local CreateStyledTable = markdown_utils and markdown_utils.CreateStyledTable
        if CreateStyledTable then
            local options = {
                alignment = { "left", "left", "left", "left", "left", "left", "left" },
                coloredHeaders = true,
                width = "100%",
            }
            table.insert(detailsParts, CreateStyledTable(headers, rows, options))
        else
            -- Simple fallback table
            table.insert(detailsParts, "| Slot | Item | Set |\n|---|---|---|\n")
            for _, row in ipairs(rows) do
                table.insert(detailsParts, "| " .. row[1] .. " | " .. row[2] .. " | " .. row[3] .. " |\n")
            end
            table.insert(detailsParts, "\n")
        end
        table.insert(bodyParts, table.concat(detailsParts))
    end

    if #bodyParts == 0 then
        return ""
    end

    local header
    if markdown_utils and markdown_utils.CreateHeader then
        header = markdown_utils.CreateHeader("Equipment & Active Sets", "⚔️", nil, 2)
            or '<a id="equipment--active-sets"></a>\n\n## ⚔️ Equipment & Active Sets\n\n'
    else
        header = '<a id="equipment--active-sets"></a>\n\n## ⚔️ Equipment & Active Sets\n\n'
    end

    local result = header .. table.concat(bodyParts)

    if not noWrapper then
        local CreateSeparator = markdown_utils and markdown_utils.CreateSeparator
        if CreateSeparator then
            result = result .. CreateSeparator("hr")
        else
            result = result .. "---\n\n"
        end
    end

    return result
end

function gear.GenerateEquipment(equipmentData, noWrapper)
    local success, result = pcall(GenerateEquipmentInternal, equipmentData, noWrapper)
    if success then
        if not result or result == "" then
            return ""
        end
        return result
    else
        CM.Error("GenerateEquipment: Internal function failed with error: " .. tostring(result))
        return '<a id="equipment--active-sets"></a>\n\n## ⚔️ Equipment & Active Sets\n\n*Error generating equipment data*\n\n---\n\n'
    end
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections.GenerateEquipment = gear.GenerateEquipment
CM.generators.sections.equipment.GearTable = gear

CM.DebugPrint("GENERATOR", "Gear table module loaded")
