-- FurnitureFinder.lua
--
-- Hooks the gamepad item tooltip and appends source/ID/quality/collection
-- info when the item being shown is a furnishing.
--
-- VERIFIED against GamePadHelper's real, currently-maintained source
-- (github.com/olegbl/eso-mods, GamePadHelper/modules/TooltipPrice.lua):
-- console runs the gamepad UI exclusively, which uses SEPARATE tooltip
-- INSTANCES (obtained via GAMEPAD_TOOLTIPS:GetTooltip(<constant>)), not
-- the keyboard-mode global ItemTooltip. Those instances override
-- AddItemTitle(itemLink, name) themselves, so that's the correct hook
-- point -- installed with ZO_PostHook (confirmed real base-game utility)
-- on each of the six gamepad tooltip instances.

-- TESTING GATE: while this addon is being tested before wider release, it
-- only activates for the account below. Delete this whole if-block once
-- ready to publish for everyone.
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

    if not IsFurnishingLink(itemLink) then return end
    if not tooltipControl or not tooltipControl.AcquireSection or not tooltipControl.AddSection then
        if not isDuplicate then d("[FurnitureFinder] tooltip has no AcquireSection/AddSection") end
        return
    end

    local lines = BuildFurnitureLines(itemLink)
    if #lines == 0 then return end

    local ok, section = pcall(function()
        return tooltipControl:AcquireSection({
            paddingTop = 3,
            paddingBottom = 3,
            customSpacing = 5,
            childSpacing = 5,
            widthPercent = 100,
            fontSize = 24,
            fontFace = "$(GAMEPAD_LIGHT_FONT)",
            fontColorType = INTERFACE_COLOR_TYPE_TEXT_COLORS,
            fontColorField = INTERFACE_TEXT_COLOR_NORMAL,
            fontStyle = "soft-shadow-thick",
            uppercase = false,
        })
    end)

    if not ok or not section then
        if not isDuplicate then d("[FurnitureFinder] AcquireSection failed: " .. tostring(section)) end
        return
    end

    for _, line in ipairs(lines) do
        pcall(function() section:AddLine(line) end)
    end

    local ok2, err2 = pcall(function() tooltipControl:AddSection(section) end)
    if not isDuplicate then
        if ok2 then
            d("[FurnitureFinder] section added (" .. #lines .. " lines)")
        else
            d("[FurnitureFinder] AddSection failed: " .. tostring(err2))
        end
    end
end

-- ---------------------------------------------------------------------------
-- Hooks
-- ---------------------------------------------------------------------------

local function HookGamepadTooltips()
    if not GAMEPAD_TOOLTIPS or not GAMEPAD_TOOLTIPS.GetTooltip then
        d("[FurnitureFinder] GAMEPAD_TOOLTIPS not found -- hook NOT installed")
        return
    end

    local tooltipConstants = {
        GAMEPAD_LEFT_DIALOG_TOOLTIP,
        GAMEPAD_LEFT_TOOLTIP,
        GAMEPAD_MOVABLE_TOOLTIP,
        GAMEPAD_QUAD1_TOOLTIP,
        GAMEPAD_QUAD3_TOOLTIP,
        GAMEPAD_RIGHT_TOOLTIP,
    }

    local hookedCount = 0
    for _, tooltipConst in ipairs(tooltipConstants) do
        if tooltipConst then
            local ok, gamepadTooltip = pcall(function()
                return GAMEPAD_TOOLTIPS:GetTooltip(tooltipConst)
            end)
            if ok and gamepadTooltip and gamepadTooltip.AddItemTitle then
                ZO_PostHook(gamepadTooltip, "AddItemTitle", function(self, itemLink, name)
                    pcall(AppendFurnitureTooltip, self, itemLink)
                end)
                hookedCount = hookedCount + 1
            end
        end
    end

    d("[FurnitureFinder] hooked " .. hookedCount .. " gamepad tooltip instances")
end

local function HookKeyboardTooltip()
    -- Kept as a fallback in case any screen still routes through the
    -- keyboard-mode tooltip control even on console.
    if not (ItemTooltip and ItemTooltip.SetBagItem) then return end

    local orig_SetBagItem = ItemTooltip.SetBagItem
    ItemTooltip.SetBagItem = function(self, bagId, slotIndex, ...)
        orig_SetBagItem(self, bagId, slotIndex, ...)
        local ok, itemLink = pcall(GetItemLink, bagId, slotIndex)
        if ok then pcall(AppendFurnitureTooltip, self, itemLink) end
    end
end

local function HookHousingEditorTooltip()
    -- TODO / needs in-game verification: the Housing Editor's furniture
    -- browser may or may not route through the same GAMEPAD_TOOLTIPS
    -- instances hooked above. Test in-game; if it doesn't show the extra
    -- lines there, this is the next thing to dig into specifically.
end

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------

local function OnAddOnLoaded(_, addonName)
    if addonName ~= FF.name then return end
    EVENT_MANAGER:UnregisterForEvent(FF.name, EVENT_ADD_ON_LOADED)

    d("[FurnitureFinder] loaded OK")

    HookGamepadTooltips()
    HookKeyboardTooltip()
    HookHousingEditorTooltip()
end

EVENT_MANAGER:RegisterForEvent(FF.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
