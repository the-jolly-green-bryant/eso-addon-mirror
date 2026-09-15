-- ESO Adventurer Suite
-- v0.29.648 - Character Gear Skin / Costume collectible slot.
-- Display-only bridge into ESO's native Collections UI. The Suite never calls
-- UseCollectible or protected collectible actions, preserving Outfit/Collections
-- secure preview paths.

local EPC = ESOProgressionCoach
if not EPC or not WINDOW_MANAGER then return end
local G = EPC.CharacterGearScreen
if not G then return end

local NAME = (EPC.name or "ESOAdventurerSuite") .. "_CharacterGearSkinSlot029627"
local wm = WINDOW_MANAGER
local PLAYER = rawget(_G, "GAMEPLAY_ACTOR_CATEGORY_PLAYER")
local SKIN_TYPE = rawget(_G, "COLLECTIBLE_CATEGORY_TYPE_SKIN")
local COSTUME_TYPE = rawget(_G, "COLLECTIBLE_CATEGORY_TYPE_COSTUME")
local DEFAULT_APPEARANCE_ICON = "EsoUI/Art/Collections/collections_tabIcon_appearance_up.dds"
local DEFAULT_COSTUME_ICON = "EsoUI/Art/Dye/dyes_tabicon_costumedye_down.dds"

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
end

local function high(control, level)
    if not control then return end
    if type(control.SetDrawTier) == "function" and rawget(_G, "DT_HIGH") ~= nil then
        pcall(control.SetDrawTier, control, DT_HIGH)
    end
    if type(control.SetDrawLayer) == "function" and rawget(_G, "DL_OVERLAY") ~= nil then
        pcall(control.SetDrawLayer, control, DL_OVERLAY)
    end
    if type(control.SetDrawLevel) == "function" then pcall(control.SetDrawLevel, control, level or 650) end
end

local function activeCollectibleId(categoryType)
    if categoryType == nil or PLAYER == nil or type(GetActiveCollectibleByType) ~= "function" then return 0 end
    return tonumber(first(GetActiveCollectibleByType, 0, categoryType, PLAYER)) or 0
end

local function activeAppearance()
    local costumeId = activeCollectibleId(COSTUME_TYPE)
    if costumeId > 0 then return costumeId, "COSTUME", "Costume" end
    local skinId = activeCollectibleId(SKIN_TYPE)
    if skinId > 0 then return skinId, "SKIN", "Skin" end
    return 0, "NONE", "Skin"
end

local function collectibleIcon(id, kind)
    if id and id > 0 and type(GetCollectibleIcon) == "function" then
        local icon = first(GetCollectibleIcon, "", id)
        if icon and icon ~= "" then return icon end
    end
    if kind == "COSTUME" then return DEFAULT_COSTUME_ICON end
    return DEFAULT_APPEARANCE_ICON
end

local function collectibleName(id, fallback)
    if id and id > 0 and type(GetCollectibleName) == "function" then
        local name = first(GetCollectibleName, "", id)
        if name and name ~= "" then return name end
    end
    return fallback or "Appearance"
end

local function openCollections()
    if not SCENE_MANAGER then return end
    local scene = SCENE_MANAGER:GetScene("collectionsBook")
    if scene then pcall(SCENE_MANAGER.Show, SCENE_MANAGER, "collectionsBook") end
end

local function ensureCell()
    if G.skinUtilityCell029544 then return G.skinUtilityCell029544 end

    local cell = wm:CreateTopLevelWindow(NAME .. "Cell")
    cell:SetDimensions(68, 68)
    cell:SetMouseEnabled(true)
    cell:SetClampedToScreen(true)
    high(cell, 650)

    local bg = wm:CreateControl(nil, cell, CT_BACKDROP)
    bg:SetAnchorFill(cell)
    bg:SetCenterColor(0.025, 0.03, 0.04, 0.92)
    bg:SetEdgeColor(0.60, 0.48, 0.25, 0.92)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-TooltipBorder.dds", 16, 4, 4)
    bg:SetMouseEnabled(false)
    high(bg, 651)

    local icon = wm:CreateControl(nil, cell, CT_TEXTURE)
    icon:SetAnchor(CENTER, cell, CENTER, 0, -4)
    icon:SetDimensions(42, 42)
    icon:SetTextureCoords(0.04, 0.96, 0.04, 0.96)
    icon:SetMouseEnabled(false)
    high(icon, 652)

    local label = wm:CreateControl(nil, cell, CT_LABEL)
    label:SetAnchor(TOP, cell, BOTTOM, 0, 2)
    label:SetDimensions(140, 20)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetFont("ZoFontGameSmall")
    label:SetColor(1, 0.82, 0.26, 1)
    label:SetText("Skin")
    label:SetMouseEnabled(false)
    high(label, 653)

    cell.bg = bg
    cell.icon = icon
    cell.label = label

    cell:SetHandler("OnMouseEnter", function(ctrl)
        local id, kind, labelText = activeAppearance()
        if not InformationTooltip or type(InitializeTooltip) ~= "function" then return end
        InitializeTooltip(InformationTooltip, ctrl, LEFT, -8, 0, RIGHT)
        local text
        if id > 0 then
            text = collectibleName(id, labelText) .. "\nClick to open ESO Collections"
        else
            text = "Skin / Costume\nNo skin or costume equipped\nClick to open ESO Collections"
        end
        if type(SetTooltipText) == "function" then SetTooltipText(InformationTooltip, text) end
    end)

    cell:SetHandler("OnMouseExit", function()
        if InformationTooltip and type(ClearTooltip) == "function" then pcall(ClearTooltip, InformationTooltip) end
    end)

    cell:SetHandler("OnMouseUp", function(_, button, upInside)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or upInside == false then return end
        openCollections()
    end)

    G.skinUtilityCell029544 = cell
    return cell
end

local function refresh()
    if SKIN_TYPE == nil and COSTUME_TYPE == nil then
        if G.skinUtilityCell029544 then G.skinUtilityCell029544:SetHidden(true) end
        return
    end

    local appearance = G.weaponUtilityCells and G.weaponUtilityCells.Appearance
    if not appearance or (type(appearance.IsHidden) == "function" and appearance:IsHidden()) then
        if G.skinUtilityCell029544 then G.skinUtilityCell029544:SetHidden(true) end
        return
    end

    local cell = ensureCell()
    local size = tonumber(first(appearance.GetWidth, 68, appearance)) or 68
    if size < 48 then size = 48 elseif size > 128 then size = 128 end
    cell:SetDimensions(size, size)
    cell.icon:SetDimensions(size * 0.62, size * 0.62)
    cell:ClearAnchors()
    cell:SetAnchor(LEFT, appearance, RIGHT, 12, 0)

    local id, kind, labelText = activeAppearance()
    cell.activeSkinId029544 = kind == "SKIN" and id or 0
    cell.activeCostumeId029627 = kind == "COSTUME" and id or 0
    cell.activeAppearanceId029627 = id
    cell.activeAppearanceKind029627 = kind
    cell.icon:SetTexture(collectibleIcon(id, kind))
    cell.label:SetText(labelText)

    if id > 0 then
        cell.bg:SetEdgeColor(0.92, 0.72, 0.26, 1)
        cell.icon:SetColor(1, 1, 1, 1)
    else
        cell.bg:SetEdgeColor(0.42, 0.42, 0.46, 0.84)
        cell.icon:SetColor(0.65, 0.65, 0.68, 0.82)
    end

    cell:SetHidden(false)
    high(cell, 650); high(cell.bg, 651); high(cell.icon, 652); high(cell.label, 653)
end

local function delayedRefresh()
    refresh()
    if type(zo_callLater) == "function" then
        zo_callLater(refresh, 80)
        zo_callLater(refresh, 250)
    end
end

if EVENT_MANAGER then
    -- Remove the old 200 ms polling loop. Appearance state changes are event-driven.
    EVENT_MANAGER:UnregisterForUpdate(NAME)

    local collectibleEvent = rawget(_G, "EVENT_COLLECTIBLE_UPDATED")
    if collectibleEvent then
        EVENT_MANAGER:RegisterForEvent(NAME .. "Collectible", collectibleEvent, delayedRefresh)
    end

    local activeCollectibleEvent = rawget(_G, "EVENT_ACTIVE_COLLECTIBLE_UPDATED")
    if activeCollectibleEvent then
        EVENT_MANAGER:RegisterForEvent(NAME .. "ActiveCollectible", activeCollectibleEvent, delayedRefresh)
    end

    local activatedEvent = rawget(_G, "EVENT_PLAYER_ACTIVATED")
    if activatedEvent then
        EVENT_MANAGER:RegisterForEvent(NAME .. "PlayerActivated", activatedEvent, delayedRefresh)
    end
end

delayedRefresh()
