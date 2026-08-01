-- Transmute Set Crafter — Materials/cost panel
--
-- Aggregates everything the queue will spend: transmute crystals, glyph runes
-- (via LLC), and improvement materials (via GetSmithingImprovementItemLink).
-- Renders rows into the cost window's scroll list; updates the cost summary
-- label on the main window's footer.

local TSC = TransmuteSetCrafter

local COST_ENTRY       = 4   -- ScrollList data type id; must match SetupUI registration
local COST_ROW_HEIGHT  = 22

-- Quality-tier improvement counts assuming max improvement skill (typical end
-- game). Index 1=white→green, 2=green→blue, 3=blue→purple, 4=purple→gold.
local IMPROVEMENT_COUNTS = { 2, 3, 4, 8 }

-- Build a minimal valid item link for an itemId. The default subtype/level
-- (30/1) is sufficient for name/quality/stack-count lookups on materials.
local function ItemLinkFor(itemId)
    return string.format("|H1:item:%d:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
end

local function GetItemNameById(itemId)
    if not itemId then return nil end
    local name = GetItemLinkName(ItemLinkFor(itemId))
    if not name or name == "" then return nil end
    return zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
end

local function GetItemQualityById(itemId)
    if not itemId then return nil end
    return GetItemLinkFunctionalQuality(ItemLinkFor(itemId))
end

-- Sum the player's stock of an item across backpack, bank, subscriber bank, and craft bag.
local function CountItemAvailable(itemId)
    if not itemId or itemId == 0 then return 0 end
    local bag, bank, craft = GetItemLinkStacks(ItemLinkFor(itemId))
    return (bag or 0) + (bank or 0) + (craft or 0)
end

local function GetImprovementMaterialId(craftType, tier)
    local link = GetSmithingImprovementItemLink(craftType, tier, LINK_STYLE_DEFAULT)
    if not link or link == "" then return nil end
    local id = GetItemLinkItemId(link)
    if id == 0 then return nil end
    return id
end

-- Public: returns { {name, needed, have, quality, sortKey}, ... } describing
-- every material the queue will consume.
function TSC.GetCostBreakdown()
    local rows = {}

    -- Transmute crystals (the reconstruction currency itself)
    local crystalCost  = TSC.GetTotalCrystalCost()
    local currencyType = TSC.GetReconCurrencyType()
    local location     = GetCurrencyPlayerStoredLocation(currencyType)
    local crystalAvail = GetCurrencyAmount(currencyType, location)
    table.insert(rows, {
        name    = GetString(SI_TSC_NAME_TRANSMUTE_CRYSTALS),
        needed  = crystalCost,
        have    = crystalAvail,
        sortKey = "0_crystals",
    })

    -- Glyph runes (only if LLC is available)
    if TSC.GetGlyphRuneCounts then
        local runeCounts = TSC.GetGlyphRuneCounts()
        for itemId, needed in pairs(runeCounts) do
            local name = GetItemNameById(itemId) or ("Rune " .. itemId)
            table.insert(rows, {
                name    = name,
                needed  = needed,
                have    = CountItemAvailable(itemId),
                quality = GetItemQualityById(itemId),
                sortKey = "1_" .. name,
            })
        end
    end

    -- Improvement (upgrade) materials per item using ESO's canonical itemIds.
    -- The floor is the piece's intrinsic minimum functional quality (most
    -- dropped sets start at Fine/green = 2), NOT always Normal/white.
    -- Matches ZO_ItemSetCollectionReconstructionPieceData:GetCostInfo.
    local matCounts = {}
    for _, entry in ipairs(TSC.queue) do
        local target = entry.quality
        if target and target > ITEM_FUNCTIONAL_QUALITY_NORMAL then
            local pieceData = TSC.GetPieceData(entry.pieceId)
            if pieceData then
                local craftType = GetItemLinkCraftingSkillType(pieceData:GetItemLink())
                local minQ      = pieceData:GetFunctionalQuality() or ITEM_FUNCTIONAL_QUALITY_NORMAL
                for tier = minQ, target - 1 do
                    local matId = GetImprovementMaterialId(craftType, tier)
                    if matId then
                        matCounts[matId] = (matCounts[matId] or 0) + IMPROVEMENT_COUNTS[tier]
                    end
                end
            end
        end
    end
    for itemId, needed in pairs(matCounts) do
        local name = GetItemNameById(itemId) or ("Material " .. itemId)
        table.insert(rows, {
            name    = name,
            needed  = needed,
            have    = CountItemAvailable(itemId),
            quality = GetItemQualityById(itemId),
            sortKey = "2_" .. name,
        })
    end

    table.sort(rows, function(a, b) return a.sortKey < b.sortKey end)
    return rows
end

function TSC.SetupCostRow(ctrl, data)
    ctrl.data = data

    -- Track the list width so the row's right-anchored Have/Needed columns
    -- end up at the right edge of the visible area and Name stretches to fill.
    local list = TransmuteSetCrafterCostWindowList
    if list then
        local rowWidth = list:GetWidth() - 18  -- scrollbar
        if rowWidth > 200 then
            ctrl:SetWidth(rowWidth)
        end
    end

    local nameLbl   = ctrl:GetNamedChild("Name")
    local neededLbl = ctrl:GetNamedChild("Needed")
    local haveLbl   = ctrl:GetNamedChild("Have")
    nameLbl:SetText(data.name)
    neededLbl:SetText(tostring(data.needed))
    haveLbl:SetText(tostring(data.have))

    local statusColor = (data.have >= data.needed) and TSC.Color.ENOUGH or TSC.Color.SHORT
    neededLbl:SetColor(statusColor:UnpackRGBA())
    haveLbl:SetColor(statusColor:UnpackRGBA())

    if data.quality then
        local qr, qg, qb = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.quality)
        if qr then
            nameLbl:SetColor(qr, qg, qb, 1)
        else
            nameLbl:SetColor(statusColor:UnpackRGBA())
        end
    else
        nameLbl:SetColor(statusColor:UnpackRGBA())
    end
end

function TSC.RefreshCostPanel()
    local list = TransmuteSetCrafterCostWindowList
    if not list then return end
    ZO_ScrollList_Clear(list)
    local dataList = ZO_ScrollList_GetDataList(list)
    for _, row in ipairs(TSC.GetCostBreakdown()) do
        table.insert(dataList, ZO_ScrollList_CreateDataEntry(COST_ENTRY, row))
    end
    ZO_ScrollList_Commit(list)
end

function TSC.UpdateCostDisplay()
    local cost         = TSC.GetTotalCrystalCost()
    local currencyType = TSC.GetReconCurrencyType()
    local location     = GetCurrencyPlayerStoredLocation(currencyType)
    local available    = GetCurrencyAmount(currencyType, location)
    TransmuteSetCrafterWindowCostLabel:SetText(zo_strformat(SI_TSC_CRYSTALS_COST, cost, available))
    TSC.RefreshCostPanel()
end

-- Called from UI.lua SetupUI: register the data type and seed the headers.
function TSC.SetupCostPanel()
    local costList = TransmuteSetCrafterCostWindowList
    if costList then
        ZO_ScrollList_AddDataType(costList, COST_ENTRY, "TSC_CostRow", COST_ROW_HEIGHT,
                                  function(ctrl, data) TSC.SetupCostRow(ctrl, data) end)
    end
    TransmuteSetCrafterCostWindowTitle:SetText(GetString(SI_TSC_LABEL_MATERIALS))
    TransmuteSetCrafterCostWindowColName:SetText(GetString(SI_TSC_COL_ITEM))
    TransmuteSetCrafterCostWindowColNeeded:SetText(GetString(SI_TSC_COL_NEED))
    TransmuteSetCrafterCostWindowColHave:SetText(GetString(SI_TSC_COL_HAVE))
end
