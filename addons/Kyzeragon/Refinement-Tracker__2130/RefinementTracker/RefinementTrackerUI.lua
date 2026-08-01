-----------------------------------------------------------
-- RefinementTracker
-- Displays boosters obtained from refining raw materials
-- @author Kyzeragon
-----------------------------------------------------------

local materialItemIDs =
{
    [CRAFTING_TYPE_BLACKSMITHING] =
    {
        808, --    = "Iron Ore",
        5820, --   = "High Iron Ore",
        23103, --  = "Orichalcum Ore",
        23104, --  = "Dwarven Ore",
        23105, --  = "Ebony Ore",
        4482, --   = "Calcinium Ore",
        23133, --  = "Galatite Ore",
        23134, --  = "Quicksilver Ore",
        23135, --  = "Voidstone Ore",
        71198 --  = "Rubedite Ore"
    },
    [CRAFTING_TYPE_CLOTHIER] =
    {
        812, --    = "Raw Jute",
        4464, --   = "Raw Flax",
        23129, --  = "Raw Cotton",
        23130, --  = "Raw Spidersilk",
        23131, --  = "Raw Ebonthread",
        33217, --  = "Raw Kreshweed",
        33218, --  = "Raw Ironweed",
        33219, --  = "Raw Silverweed",
        33220, --  = "Raw Void Bloom",
        71200 --  = "Raw Ancestor Silk"
    },
    [3] = -- Leather mats
    {
        793, --    = "Rawhide Scraps",
        4448, --   = "Hide Scraps",
        23095, --  = "Leather Scraps",
        6020, --   = "Thick Leather Scraps",
        23097, --  = "Fell Hide Scraps",
        23142, --  = "Topgrain Scraps",
        23143, --  = "Iron Hide Scraps",
        800, --    = "Superb Hide Scraps",
        4478, --   = "Shadowhide Scraps",
        71239 --  = "Rubedo Hide Scraps"
    },
    [CRAFTING_TYPE_WOODWORKING] =
    {
        802, --    = "Rough Maple",
        521, --    = "Rough Oak",
        23117, --  = "Rough Beech",
        23118, --  = "Rough Hickory",
        23119, --  = "Rough Yew",
        818, --    = "Rough Birch",
        4439, --   = "Rough Ash",
        23137, --  = "Rough Mahogany",
        23138, --  = "Rough Nightwood",
        71199 --  = "Rough Ruby Ash"
    },
    [CRAFTING_TYPE_JEWELRYCRAFTING] =
    {
        135137, --  = "Pewter Dust",
        135139, --  = "Copper Dust",
        135141, --  = "Silver Dust",
        135143, --  = "Electrum Dust",
        135145 --  = "Platinum Dust"
    }
}

local boosterItemIDs =
{
    [CRAFTING_TYPE_BLACKSMITHING] =
    {
        54170, --  = "Honing Stone",
        54171, --  = "Dwarven Oil",
        54172, --  = "Grain Solvent",
        54173 --  = "Tempering Alloy"
    },
    [CRAFTING_TYPE_CLOTHIER] =
    {
        54174, --  = "Hemming",
        54175, --  = "Embroidery",
        54176, --  = "Elegant Lining",
        54177 --  = "Dreugh Wax"
    },
    [3] =
    {
        54174, --  = "Hemming",
        54175, --  = "Embroidery",
        54176, --  = "Elegant Lining",
        54177 --  = "Dreugh Wax"
    },
    [CRAFTING_TYPE_WOODWORKING] =
    {
        54178, --  = "Pitch",
        54179, --  = "Turpen",
        54180, --  = "Mastic",
        54181 --  = "Rosin"
    },
    [CRAFTING_TYPE_JEWELRYCRAFTING] =
    {
        135151, --  = "Terne Grains",
        135152, --  = "Iridium Grains",
        135153, --  = "Zircon Grains",
        135154 --  = "Chromium Grains"
    }
}

local craftOffsets =
{
    [CRAFTING_TYPE_BLACKSMITHING] =
    {
        x = 0,
        y = 22
    },
    [CRAFTING_TYPE_CLOTHIER] =
    {
        x = 250,
        y = 22
    },
    [3] =
    {
        x = 500,
        y = 22
    },
    [CRAFTING_TYPE_WOODWORKING] =
    {
        x = 0,
        y = 252
    },
    [CRAFTING_TYPE_JEWELRYCRAFTING] =
    {
        x = 250,
        y = 252
    }
}

---------------------------------------------------------------------
-- UI

function RefinementTracker.initializeWindow()
    local header = RefinementTrackerWindow:GetNamedChild("H1")

    local prevItem = header

    for craftId, craftType in pairs(materialItemIDs) do

        -- Control for the entire craft type
        local craftControl = CreateControlFromVirtual(
            "$(parent)Craft" .. tostring(craftId),  -- name
            RefinementTrackerWindow,        -- parent
            "RT_Craft_Template",            -- template
            "")                             -- suffix
        craftControl:SetAnchor(TOPLEFT, header, BOTTOMLEFT,
            craftOffsets[craftId].x, craftOffsets[craftId].y)
        prevItem = craftControl

        -- Add header
        local boosterControl = CreateControlFromVirtual(
            "$(parent)Boost" .. tostring(craftId),  -- name
            craftControl,           -- parent
            "RT_Heading_Template",  -- template
            "")                     -- suffix
        boosterControl:SetAnchor(TOPLEFT, prevItem, BOTTOMLEFT, 0, 0)

        -- Add texture and mouseover tooltip
        local qualities = {"Fine", "Superior", "Epic", "Legendary"}
        local i = 0
        for index, id in pairs(boosterItemIDs[craftId]) do
            local link = getLinkFromID(id)
            local name = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(link))
            i = i + 1
            boosterControl:GetNamedChild(qualities[i]):SetTexture(GetItemLinkIcon(link))
            boosterControl:GetNamedChild(qualities[i]):SetHandler("OnMouseEnter", function(s)
                ZO_Tooltips_ShowTextTooltip(s, RIGHT, name) end)
        end
        prevItem = boosterControl

        -- Add rows
        for index, id in pairs(craftType) do
            local link = getLinkFromID(id)
            local icon = GetItemLinkIcon(link)
            local name = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(link))
            local itemControl = CreateControlFromVirtual(
                "$(parent)" .. id,          -- name
                craftControl,               -- parent
                "RT_Icon_Template",         -- template
                "")                         -- suffix
            if (prevItem == boosterControl) then
                itemControl:SetAnchor(TOPLEFT, prevItem, BOTTOMLEFT, 0, 5)
            else
                itemControl:SetAnchor(TOPLEFT, prevItem, BOTTOMLEFT, 0, 0)
            end
            itemControl:GetNamedChild("Material"):SetTexture(icon)
            itemControl:GetNamedChild("Material"):SetHandler("OnMouseEnter", function(s)
                ZO_Tooltips_ShowTextTooltip(s, RIGHT, name) end)

            prevItem = itemControl
        end
    end

    -- And finally, populate the GUI from the saved values
    RefinementTracker.populateGui()
end

function RefinementTracker.showWindow()
    SCENE_MANAGER:ShowTopLevel(RefinementTrackerWindow)
    RefinementTracker.isVisible = true
    -- RefinementTrackerWindow:SetHidden(false)
end

function RefinementTracker.hideWindow()
    SCENE_MANAGER:HideTopLevel(RefinementTrackerWindow)
    RefinementTracker.isVisible = false
    -- RefinementTrackerWindow:SetHidden(true)
end

function RefinementTracker.toggleWindow()
    if (RefinementTracker.isVisible) then
        RefinementTracker.hideWindow()
    else
        RefinementTracker.showWindow()
    end
end

---------------------------------------------------------------------
-- Data Structure

local qualityConversion =
{
    [ITEM_QUALITY_MAGIC] = "Fine",
    [ITEM_QUALITY_ARCANE] = "Superior",
    [ITEM_QUALITY_ARTIFACT] = "Epic",
    [ITEM_QUALITY_LEGENDARY] = "Legendary"
}

-- Updates GUI according to passed in rawId and quality.
function RefinementTracker.mergeToGui(rawId, craftSkill, quality, quantity)
    -- This is needed because both light and medium are in Clothing
    local currentCraftSkill = craftSkill
    if (craftSkill == CRAFTING_TYPE_CLOTHIER) then
        -- Why is Lua so annoying
        if (rawId == 793 or
            rawId == 4448 or
            rawId == 23095 or
            rawId == 6020 or
            rawId == 23097 or
            rawId == 23142 or
            rawId == 23143 or
            rawId == 800 or
            rawId == 4478 or
            rawId == 71239) then
            currentCraftSkill = 3
        end
    end

    local craftSection = RefinementTrackerWindow:GetNamedChild("Craft" .. tostring(currentCraftSkill))
    local row = craftSection:GetNamedChild(tostring(rawId))

    if (quality == -1) then
        -- -1 means just update value for raw material
        local rawText = row:GetNamedChild("Raw")
        rawText:SetText(tostring(tonumber(rawText:GetText()) + quantity))
    else
        -- Update value for whatever quality it was
        local qualityText = row:GetNamedChild(qualityConversion[quality])
        qualityText:SetText(tostring(tonumber(qualityText:GetText()) + quantity))
    end
end

-- Populate the GUI with the values from RefinementTracker.SavedValues.Table
function RefinementTracker.populateGui()
    for craftId, craftType in pairs(RefinementTracker.SavedValues.Table) do
        local craftSection = RefinementTrackerWindow:GetNamedChild("Craft" .. tostring(craftId))

        for rawId, boosters in pairs(craftType) do
            local row = craftSection:GetNamedChild(tostring(rawId))

            for boosterId, total in pairs(boosters) do
                if (boosterId == "used") then
                    local rawText = row:GetNamedChild("Raw")
                    rawText:SetText(tostring(total))
                else
                    local link = getLinkFromID(boosterId)
                    local qualityText = row:GetNamedChild(qualityConversion[GetItemLinkQuality(link)])
                    qualityText:SetText(tostring(total))
                end
            end
        end
    end
end

---------------------------------------------------------------------
-- Util

function getLinkFromID(id)
    return "|H0:item:" .. id .. ":30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
end

---------------------------------------------------------------------
-- Commands
SLASH_COMMANDS["/refined"] = RefinementTracker.showWindow
