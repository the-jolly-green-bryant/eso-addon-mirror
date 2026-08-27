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

-- Public release 2026-08-25: removed the always-on display-name and
-- APIVersion diagnostic prints that used to be here (were spamming chat
-- on every login for every user, not just during testing) -- APIVersion
-- 101050 has been confirmed against a live client already.

-- TESTING GATE: while this addon is being tested before wider release, it
-- only activates for the account below. Replace "@YourAccountName" with
-- your actual Bethesda/Xbox display name (the @Handle shown in-game), or
-- delete this whole if-block once you're ready to publish for everyone.
-- Testing gate removed 2026-08-25 -- addon now open to everyone.

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
        -- Only show the "missing" fallback for items that are actually
        -- placeable furnishings -- i.e. the kind of item this database is
        -- keyed by. A recipe/diagram item will ALWAYS miss here, since the
        -- database is keyed by the crafted furnishing's item ID, not the
        -- recipe's own ID -- showing "not in local database" on a recipe
        -- is misleading, not a real gap, so stay silent for those.
        local okFurn, isFurnishing = pcall(IsItemLinkPlaceableFurniture, itemLink)
        if okFurn and isFurnishing then
            table.insert(lines, "|c888888Source: not in local database yet|r")
        end
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

    -- Recipe/furnishing-plan known status, via LibCharacterKnowledge if
    -- present (bundled alongside this addon, OptionalDependsOn in the
    -- manifest -- confirmed console-compatible, has its own console/
    -- settings). Confirmed real API: LibCharacterKnowledge.GetItemKnowledgeForCharacter
    -- returns KNOWLEDGE_INVALID for ordinary furnishings (not a plan
    -- item), so this correctly stays silent except on actual "Recipe:"/
    -- "Diagram:" plan items.
    if ok and LibCharacterKnowledge then
        -- Same validity check as before: try the item itself first, fall
        -- back to LibCharacterKnowledge's reverse lookup (crafted
        -- furnishing -> its recipe/diagram) if the item isn't itself a
        -- recipe. This just determines whether we have a valid target to
        -- check at all -- the actual per-character breakdown comes from
        -- GetItemKnowledgeList below.
        local targetItem = itemLink
        local ok4, knowledge = pcall(LibCharacterKnowledge.GetItemKnowledgeForCharacter, targetItem)

        if ok4 and knowledge == LibCharacterKnowledge.KNOWLEDGE_INVALID then
            local ok5, recipeItemId = pcall(LibCharacterKnowledge.GetSourceItemIdFromResultItem, itemId)
            if ok5 and recipeItemId and recipeItemId ~= 0 then
                targetItem = recipeItemId
                ok4, knowledge = pcall(LibCharacterKnowledge.GetItemKnowledgeForCharacter, targetItem)
            end
        end

        -- Only worth building the character list if we ended up with a
        -- genuinely valid recipe/plan target (known OR unknown for the
        -- current character -- i.e. IsKnowledgeUsable). NODATA/INVALID at
        -- this point means there's nothing meaningful to show.
        if ok4 and LibCharacterKnowledge.IsKnowledgeUsable(knowledge) then
            local ok6, charList = pcall(LibCharacterKnowledge.GetItemKnowledgeList, targetItem)
            if ok6 and charList then
                local namesWhoKnow = {}
                local namesWhoDontKnow = {}
                for _, entry in ipairs(charList) do
                    if entry.knowledge == LibCharacterKnowledge.KNOWLEDGE_KNOWN then
                        table.insert(namesWhoKnow, entry.name)
                    elseif entry.knowledge == LibCharacterKnowledge.KNOWLEDGE_UNKNOWN then
                        table.insert(namesWhoDontKnow, entry.name)
                    end
                end
                if #namesWhoKnow > 0 then
                    table.insert(lines, zo_strformat("|c00c000Known by: <<1>>|r", table.concat(namesWhoKnow, ", ")))
                end
                if #namesWhoDontKnow > 0 then
                    table.insert(lines, zo_strformat("|cc00000Not known by: <<1>>|r", table.concat(namesWhoDontKnow, ", ")))
                end
                -- If both lists are empty, no tracked characters have data
                -- for this item yet -- stay silent, nothing meaningful to show.
            end
        end
    end

    return lines
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
            ZO_PostHook(tooltip, "AddItemTitle", function(self, itemLink, name)
                -- CONFIRMED against real ESOUI source and in-game testing
                -- (2026-08-25): AddItemTitle(itemLink, name) -- arg1 is the
                -- real itemLink. itemId/isFurnishing resolve correctly.
                local ok, err = pcall(function()
                    local itemId = GetItemLinkItemId(itemLink)

                    -- Gate widened 2026-08-25: a "Recipe:"/"Diagram:" item is
                    -- NOT itself placeable furniture (it's the separate,
                    -- consumable item that teaches you one) -- the original
                    -- IsItemLinkPlaceableFurniture-only gate silently skipped
                    -- every recipe item, including the LibCharacterKnowledge
                    -- lookup, before BuildFurnitureLines ever ran. Now also
                    -- let actual recipe items through so the known/unknown
                    -- line can show.
                    local okType, itemType = pcall(GetItemLinkItemType, itemLink)
                    local isRecipeItem = okType and itemType == ITEMTYPE_RECIPE
                    local isFurnishing = IsItemLinkPlaceableFurniture(itemLink)

                    if not isFurnishing and not isRecipeItem then
                        return
                    end

                    local lines = BuildFurnitureLines(itemLink)
                    if not lines or #lines == 0 then
                        return
                    end

                    -- CONFIRMED pattern from real ESOUI source
                    -- (esoui/esoui/publicallingames/tooltip/itemtooltips.lua):
                    -- real game code always adds body content via
                    -- AcquireSection -> section:AddLine -> AddSection,
                    -- never a raw AddLine call directly on the tooltip
                    -- object itself. The earlier crash-causing build did
                    -- exactly that (raw tooltipControl:AddLine), which is
                    -- the most likely root cause of the corruption that
                    -- crashed ZO_GamepadInventory:Select downstream.
                    local section = self:AcquireSection(self:GetStyle("bodySection"))
                    for _, line in ipairs(lines) do
                        section:AddLine(line, self:GetStyle("bodyDescription"))
                    end
                    self:AddSection(section)
                end)

                if not ok then
                    d("[FurnitureFinder] tooltip section error (safely caught): " .. tostring(err))
                end
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
