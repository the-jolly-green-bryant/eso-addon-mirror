-- FurnitureFinder.lua
--
-- Hooks the shared item tooltip and appends source/ID/quality/collection
-- info when the item being shown is a furnishing.
--
-- VERIFICATION NOTE: The API functions and events referenced here
-- (GetItemLinkItemType, ITEMTYPE_FURNISHING, GetItemLinkItemId,
-- GetItemLinkDisplayQuality, ItemTooltip:SetBagItem/SetLink,
-- EVENT_ADD_ON_LOADED) are documented ESO Lua API. What is NOT verified
-- against a live client is (a) the exact current APIVersion number, and
-- (b) whether the Housing Editor's placed-furniture selection UI (as
-- opposed to the inventory/bank/browser list) routes through this same
-- ItemTooltip control or a separate one -- that needs an in-game check
-- with /reloadui and a test house. If it turns out to be separate, the
-- fix is adding one more hook in HookHousingEditorTooltip() below, same
-- pattern as the inventory hook.

-- DIAGNOSTIC: print the real display name unconditionally, before the gate,
-- so we can see exactly what the game reports vs. what's hardcoded below.
d("[FurnitureFinder] real display name is: " .. tostring(GetDisplayName()))

-- TESTING GATE: while this addon is being tested before wider release, it
-- only activates for the account below. Replace "@YourAccountName" with
-- your actual Bethesda/Xbox display name (the @Handle shown in-game), or
-- delete this whole if-block once you're ready to publish for everyone.
if GetDisplayName() ~= "@Atomic Khaos" then return end

FurnitureFinder = FurnitureFinder or {}
local FF = FurnitureFinder
FF.name = "FurnitureFinder"

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function IsFurnishingLink(itemLink)
    if not itemLink or itemLink == "" then return false end
    local ok, itemType = pcall(GetItemLinkItemType, itemLink)
    if not ok then return false end
    return itemType == ITEMTYPE_FURNISHING
end

local function GetQualityLine(itemLink)
    local ok, quality = pcall(GetItemLinkDisplayQuality, itemLink)
    if not ok or not quality then return nil end

    local ok2, colorDef = pcall(GetItemQualityColor, quality)
    local qualityName = ok2 and GetString("SI_ITEMQUALITY", quality) or tostring(quality)

    if ok2 and colorDef then
        return zo_strformat("Quality: |c<<1>><<2>>|r", colorDef:ToHex(), qualityName)
    end
    return zo_strformat("Quality: <<1>>", qualityName)
end

local function BuildFurnitureLines(itemLink)
    local lines = {}

    local ok, itemId = pcall(GetItemLinkItemId, itemLink)
    if ok and itemId then
        table.insert(lines, zo_strformat("Item ID: <<1>>", itemId))
    end

    local qualityLine = GetQualityLine(itemLink)
    if qualityLine then
        table.insert(lines, qualityLine)
    end

    local data = ok and FF.GetFurnitureData(itemId) or nil
    if data then
        if data.source then
            table.insert(lines, zo_strformat("Source: <<1>>", data.source))
        end
        if data.collection then
            table.insert(lines, zo_strformat("Collection: <<1>>", data.collection))
        end
        if data.notes then
            table.insert(lines, zo_strformat("|c888888<<1>>|r", data.notes))
        end
    else
        table.insert(lines, "|c888888Source: not in local database yet|r")
    end

    return lines
end

local FF_lastDiagnosedLink = nil

local function AppendFurnitureTooltip(tooltipControl, itemLink)
    if not itemLink or itemLink == "" then return end

    local isDuplicate = (itemLink == FF_lastDiagnosedLink)
    FF_lastDiagnosedLink = itemLink

    local ok, itemType = pcall(GetItemLinkItemType, itemLink)
    if not isDuplicate then
        d("[FurnitureFinder] itemType=" .. tostring(itemType) .. " (ITEMTYPE_FURNISHING=" .. tostring(ITEMTYPE_FURNISHING) .. ")")
    end

    if not IsFurnishingLink(itemLink) then return end
    if not tooltipControl or not tooltipControl.AddLine then
        if not isDuplicate then
            d("[FurnitureFinder] tooltipControl missing AddLine method")
        end
        return
    end

    local lines = BuildFurnitureLines(itemLink)
    if not isDuplicate then
        d("[FurnitureFinder] furnishing recognized, adding " .. #lines .. " lines")
    end
    if #lines == 0 then return end

    if tooltipControl.AddVerticalPadding then
        tooltipControl:AddVerticalPadding(8)
    end
    for _, line in ipairs(lines) do
        local ok2, err2 = pcall(function()
            tooltipControl:AddLine(line, "ZoFontGame", ZO_NORMAL_TEXT:UnpackRGB())
        end)
        if not ok2 then
            d("[FurnitureFinder] AddLine error: " .. tostring(err2))
        end
    end
end

-- ---------------------------------------------------------------------------
-- Hooks
-- ---------------------------------------------------------------------------

local function HookItemTooltip()
    -- IMPORTANT: hooking ItemTooltip:SetBagItem/SetLink only affects the
    -- KEYBOARD/MOUSE UI's tooltip instance. Console always runs the gamepad
    -- UI, which builds its own separate tooltip object internally (not the
    -- global ItemTooltip). Both keyboard and gamepad tooltip instances are
    -- built from the shared ZO_Tooltip class, though, and ESO addon-dev
    -- discussion identifies ZO_Tooltip:LayoutItem as the method both paths
    -- funnel through to actually populate item data. Hooking at that level
    -- (the shared class method) instead of a specific instance should cover
    -- both UI modes with one hook.

    if not ZO_Tooltip or not ZO_Tooltip.LayoutItem then
        d("[FurnitureFinder] ZO_Tooltip.LayoutItem not found -- hook NOT installed")
    else
        local orig_LayoutItem = ZO_Tooltip.LayoutItem
        ZO_Tooltip.LayoutItem = function(self, itemLink, ...)
            orig_LayoutItem(self, itemLink, ...)
            pcall(AppendFurnitureTooltip, self, itemLink)
        end
        d("[FurnitureFinder] ZO_Tooltip.LayoutItem hook installed")
    end
end

local function HookHousingEditorTooltip()
    -- TODO / needs in-game verification: if the Housing Editor's furniture
    -- browser and placed-item selection tooltip turn out NOT to route
    -- through ItemTooltip:SetLink, hook the specific control here using the
    -- same orig-then-append pattern as HookItemTooltip above. Likely
    -- candidates to check first: ZO_HousingFurnitureBrowser tooltip calls,
    -- and whatever control backs the furniture placement info panel.
end

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------

local function OnAddOnLoaded(_, addonName)
    if addonName ~= FF.name then return end
    EVENT_MANAGER:UnregisterForEvent(FF.name, EVENT_ADD_ON_LOADED)

    d("[FurnitureFinder] loaded OK")

    HookItemTooltip()
    HookHousingEditorTooltip()
end

EVENT_MANAGER:RegisterForEvent(FF.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
