-- ESO Adventurer Suite
-- v0.29.648 - Character Gear Polymorph collectible slot.
-- Display-only bridge into ESO's native Collections UI. The Suite never calls
-- UseCollectible or protected collectible actions, preserving Outfit/Collections
-- secure preview paths.

local EPC = ESOProgressionCoach
if not EPC or not WINDOW_MANAGER then return end
local G = EPC.CharacterGearScreen
if not G then return end

local NAME = (EPC.name or "ESOAdventurerSuite") .. "_CharacterGearPolymorphSlot029546"
local wm = WINDOW_MANAGER
local PLAYER = rawget(_G, "GAMEPLAY_ACTOR_CATEGORY_PLAYER")
local POLYMORPH_TYPE = rawget(_G, "COLLECTIBLE_CATEGORY_TYPE_POLYMORPH")

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
    if type(control.SetDrawLevel) == "function" then pcall(control.SetDrawLevel, control, level or 660) end
end

local function activePolymorphId()
    if POLYMORPH_TYPE == nil or PLAYER == nil or type(GetActiveCollectibleByType) ~= "function" then return 0 end
    return tonumber(first(GetActiveCollectibleByType, 0, POLYMORPH_TYPE, PLAYER)) or 0
end

local function collectibleIcon(id)
    if id and id > 0 and type(GetCollectibleIcon) == "function" then
        local icon = first(GetCollectibleIcon, "", id)
        if icon and icon ~= "" then return icon end
    end
    return "EsoUI/Art/Collections/collections_tabIcon_appearance_up.dds"
end

local function collectibleName(id)
    if id and id > 0 and type(GetCollectibleName) == "function" then
        local name = first(GetCollectibleName, "", id)
        if name and name ~= "" then return name end
    end
    return "Polymorph"
end

local function openCollections()
    if not SCENE_MANAGER then return end
    local scene = SCENE_MANAGER:GetScene("collectionsBook")
    if scene then pcall(SCENE_MANAGER.Show, SCENE_MANAGER, "collectionsBook") end
end

local function ensureCell()
    if G.polymorphUtilityCell029546 then return G.polymorphUtilityCell029546 end

    local cell = wm:CreateTopLevelWindow(NAME .. "Cell")
    cell:SetDimensions(68, 68)
    cell:SetMouseEnabled(true)
    cell:SetClampedToScreen(true)
    high(cell, 660)

    local bg = wm:CreateControl(nil, cell, CT_BACKDROP)
    bg:SetAnchorFill(cell)
    bg:SetCenterColor(0.025, 0.03, 0.04, 0.92)
    bg:SetEdgeColor(0.60, 0.48, 0.25, 0.92)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-TooltipBorder.dds", 16, 4, 4)
    bg:SetMouseEnabled(false)
    high(bg, 661)

    local icon = wm:CreateControl(nil, cell, CT_TEXTURE)
    icon:SetAnchor(CENTER, cell, CENTER, 0, -4)
    icon:SetDimensions(42, 42)
    icon:SetTextureCoords(0.04, 0.96, 0.04, 0.96)
    icon:SetMouseEnabled(false)
    high(icon, 662)

    local label = wm:CreateControl(nil, cell, CT_LABEL)
    label:SetAnchor(TOP, cell, BOTTOM, 0, 2)
    label:SetDimensions(140, 20)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetFont("ZoFontGameSmall")
    label:SetColor(1, 0.82, 0.26, 1)
    label:SetText("Polymorph")
    label:SetMouseEnabled(false)
    high(label, 663)

    cell.bg = bg
    cell.icon = icon
    cell.label = label

    cell:SetHandler("OnMouseEnter", function(ctrl)
        local id = activePolymorphId()
        if not InformationTooltip or type(InitializeTooltip) ~= "function" then return end
        InitializeTooltip(InformationTooltip, ctrl, LEFT, -8, 0, RIGHT)
        local text = id > 0 and (collectibleName(id) .. "\nClick to open ESO Collections") or "Polymorph\nNo polymorph equipped\nClick to open ESO Collections"
        if type(SetTooltipText) == "function" then SetTooltipText(InformationTooltip, text) end
    end)

    cell:SetHandler("OnMouseExit", function()
        if InformationTooltip and type(ClearTooltip) == "function" then pcall(ClearTooltip, InformationTooltip) end
    end)

    cell:SetHandler("OnMouseUp", function(_, button, upInside)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or upInside == false then return end
        openCollections()
    end)

    G.polymorphUtilityCell029546 = cell
    return cell
end

local function refresh()
    if POLYMORPH_TYPE == nil then
        if G.polymorphUtilityCell029546 then G.polymorphUtilityCell029546:SetHidden(true) end
        return
    end

    local skin = G.skinUtilityCell029544
    local appearance = G.weaponUtilityCells and G.weaponUtilityCells.Appearance
    local anchor = skin or appearance
    if not anchor or (type(anchor.IsHidden) == "function" and anchor:IsHidden()) then
        if G.polymorphUtilityCell029546 then G.polymorphUtilityCell029546:SetHidden(true) end
        return
    end

    local cell = ensureCell()
    local size = tonumber(first(anchor.GetWidth, 68, anchor)) or 68
    if size < 48 then size = 48 elseif size > 128 then size = 128 end
    cell:SetDimensions(size, size)
    cell.icon:SetDimensions(size * 0.62, size * 0.62)
    cell:ClearAnchors()
    cell:SetAnchor(LEFT, anchor, RIGHT, 12, 0)

    local id = activePolymorphId()
    cell.activePolymorphId029546 = id
    cell.icon:SetTexture(collectibleIcon(id))
    if id > 0 then
        cell.bg:SetEdgeColor(0.92, 0.72, 0.26, 1)
        cell.icon:SetColor(1, 1, 1, 1)
    else
        cell.bg:SetEdgeColor(0.42, 0.42, 0.46, 0.84)
        cell.icon:SetColor(0.65, 0.65, 0.68, 0.82)
    end
    cell:SetHidden(false)
    high(cell, 660); high(cell.bg, 661); high(cell.icon, 662); high(cell.label, 663)
end

local function delayedRefresh()
    refresh()
    if type(zo_callLater) == "function" then
        zo_callLater(refresh, 80)
        zo_callLater(refresh, 250)
    end
end

if EVENT_MANAGER then
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
