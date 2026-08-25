-- FurnitureFinder.lua
--
-- Hooks the shared item tooltip and appends source/ID/quality/collection
-- info when the item being shown is a furnishing.
--
-- VERIFICATION NOTE: The API functions and events referenced here
-- (IsItemLinkPlaceableFurniture, GetItemLinkItemId,
-- GetItemLinkDisplayQuality, ItemTooltip:SetBagItem/SetLink,
-- EVENT_ADD_ON_LOADED) are documented ESO Lua API. Furnishing detection
-- uses IsItemLinkPlaceableFurniture rather than comparing itemType to
-- ITEMTYPE_FURNISHING directly -- confirmed in-game (2026-08-24) that
-- placeable furnishings can report different itemType values (e.g.
-- trophy-style wall decor reported itemType 29, not 61/FURNISHING),
-- so a strict itemType match silently skipped valid furnishings.
-- What is NOT verified against a live client is (a) the exact current
-- APIVersion number, and
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
    local ok, isPlaceable = pcall(IsItemLinkPlaceableFurniture, itemLink)
    if not ok then return false end
    return isPlaceable == true
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
        if data.materials then
            table.insert(lines, zo_strformat("Materials: <<1>>", data.materials))
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

    -- Ownership info (FurnitureFinder_Ownership.lua). Guarded with pcall
    -- since the ownership module is a separate file/SavedVariables and
    -- shouldn't be able to break the core tooltip if it errors.
    if ok and FFOwnership and FFOwnership.FormatOwnershipLine then
        local ok3, ownLine = pcall(FFOwnership.FormatOwnershipLine, itemLink, itemId)
        if ok3 and ownLine then
            table.insert(lines, zo_strformat("<<1>>", ownLine))
        end
    end

    return lines
end

local FF_lastDiagnosedLink = nil

local function AppendFurnitureTooltip(tooltipControl, itemLink)
    if not itemLink or itemLink == "" then return end

    local isDuplicate = (itemLink == FF_lastDiagnosedLink)
    FF_lastDiagnosedLink = itemLink

    local ok, isPlaceable = pcall(IsItemLinkPlaceableFurniture, itemLink)
    if not isDuplicate then
        d("[FurnitureFinder] IsItemLinkPlaceableFurniture=" .. tostring(isPlaceable))
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
    -- REVERTED to the previously confirmed working pattern: hooking the
    -- shared ZO_Tooltip.LayoutItem class method and calling raw AddLine
    -- was untested (flagged as such in this file's own prior comments)
    -- and is the likely cause of state corruption that crashes
    -- ZO_GamepadInventory:Select downstream. The confirmed console
    -- pattern is: GAMEPAD_TOOLTIPS:GetTooltip() instances, hooked via
    -- ZO_PostHook on AddItemTitle, using AcquireSection/AddSection.

    if not GAMEPAD_TOOLTIPS or not GAMEPAD_TOOLTIPS.GetTooltip then
        d("[FurnitureFinder] GAMEPAD_TOOLTIPS not found -- hook NOT installed")
        return
    end

    local tooltipTypes = { GAMEPAD_LEFT_TOOLTIP, GAMEPAD_RIGHT_TOOLTIP }
    local hookedCount = 0

    for _, tooltipType in pairs(tooltipTypes) do
        local ok, tooltip = pcall(function() return GAMEPAD_TOOLTIPS:GetTooltip(tooltipType) end)
        if ok and tooltip and tooltip.AddItemTitle then
            ZO_PostHook(tooltip, "AddItemTitle", function(self, ...)
                -- DIAGNOSTIC: dump every argument's type and value, whatever
                -- shape they turn out to be. Previous attempt wrongly assumed
                -- arg 1 was a table (itemData) -- it's actually a string
                -- (almost certainly the title text itself), which crashed
                -- pairs(). Not guessing again: just dump raw types/values
                -- for every arg so we can see the real signature.
                local argCount = select("#", ...)
                local parts = { "argCount=" .. argCount }
                for i = 1, argCount do
                    local v = select(i, ...)
                    table.insert(parts, string.format("arg%d(%s)=%s", i, type(v), tostring(v)))
                end
                d("[FurnitureFinder] AddItemTitle args: " .. table.concat(parts, ", "))
            end)
            hookedCount = hookedCount + 1
        end
    end

    d("[FurnitureFinder] AddItemTitle hook installed on " .. hookedCount .. " gamepad tooltip(s)")
end

local function HookHousingEditorTooltip()
    -- TODO / needs in-game verification: if the Housing Editor's furniture
    -- browser and placed-item selection tooltip turn out NOT to route
    -- through the same GAMEPAD_TOOLTIPS instances, hook the specific
    -- control here using the same pattern as HookItemTooltip above.
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
