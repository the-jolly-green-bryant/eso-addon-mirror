-- ESO Adventurer Suite
-- v0.29.649 - inventory-family tooltip placement.
-- Dock item/information tooltips immediately outside the visible inventory,
-- bank, storage, or crafting panel instead of sending them to a screen edge.
-- Placement only: ESO remains authoritative for tooltip content and actions.

local EPC = ESOProgressionCoach
if not EPC or not GuiRoot then return end

local GAP = 12
local TOP_INSET = 12

local function controlName(control)
    if not control or type(control.GetName) ~= "function" then return "" end
    local ok, name = pcall(control.GetName, control)
    return ok and tostring(name or "") or ""
end

local function rect(control)
    if not control then return nil end
    if type(control.GetLeft) ~= "function" or type(control.GetRight) ~= "function"
        or type(control.GetTop) ~= "function" or type(control.GetBottom) ~= "function" then
        return nil
    end
    local okL, left = pcall(control.GetLeft, control)
    local okR, right = pcall(control.GetRight, control)
    local okT, top = pcall(control.GetTop, control)
    local okB, bottom = pcall(control.GetBottom, control)
    left, right, top, bottom = tonumber(left), tonumber(right), tonumber(top), tonumber(bottom)
    if not okL or not okR or not okT or not okB or not left or not right or not top or not bottom then return nil end
    if right <= left or bottom <= top then return nil end
    return left, top, right, bottom, right - left, bottom - top
end

local function isInventoryFamilyName(name)
    name = string.lower(tostring(name or ""))
    return name ~= "" and (
        name:find("easinventorygrid", 1, true)
        or name:find("easbankunified", 1, true)
        or name:find("playerinventory", 1, true)
        or name:find("playerbank", 1, true)
        or name:find("guildbank", 1, true)
        or name:find("housebank", 1, true)
        or name:find("housestorage", 1, true)
        or name:find("furnishing", 1, true)
        or name:find("furniture", 1, true)
        or name:find("smithing", 1, true)
        or name:find("alchemy", 1, true)
        or name:find("enchant", 1, true)
        or name:find("retrait", 1, true)
        or name:find("craft", 1, true)
    )
end

local function isInventoryFamilyOwner(owner)
    if not owner then return false end
    if owner.bagId ~= nil or (type(owner.item) == "table" and owner.item.bag ~= nil) then return true end

    local current = owner
    for _ = 1, 12 do
        if not current then break end
        if isInventoryFamilyName(controlName(current)) then return true end
        if type(current.GetParent) ~= "function" then break end
        local ok, parent = pcall(current.GetParent, current)
        current = ok and parent or nil
    end
    return false
end

-- Find the visible panel/container that owns the hovered item. We prefer the
-- largest sensible inventory-family ancestor instead of the tiny item button.
local function findPanel(owner)
    local current = owner
    local best, bestArea = nil, 0

    for _ = 1, 14 do
        if not current then break end
        local left, top, right, bottom, width, height = rect(current)
        if left and width >= 240 and height >= 180 then
            local name = controlName(current)
            if isInventoryFamilyName(name) or current == owner or best == nil then
                local area = width * height
                -- Do not let GuiRoot/full-screen scene roots become the panel.
                local rootW = type(GuiRoot.GetWidth) == "function" and tonumber(GuiRoot:GetWidth()) or 1920
                local rootH = type(GuiRoot.GetHeight) == "function" and tonumber(GuiRoot:GetHeight()) or 1080
                if width < rootW * 0.94 and height < rootH * 0.94 and area > bestArea then
                    best, bestArea = current, area
                end
            end
        end
        if type(current.GetParent) ~= "function" then break end
        local ok, parent = pcall(current.GetParent, current)
        current = ok and parent or nil
    end

    -- Suite cells sometimes sit inside anonymous controls. Walk again and take
    -- the largest non-fullscreen ancestor if a named panel was not found.
    if not best then
        current = owner
        for _ = 1, 14 do
            if not current then break end
            local left, top, right, bottom, width, height = rect(current)
            if left and width >= 240 and height >= 180 then
                local rootW = type(GuiRoot.GetWidth) == "function" and tonumber(GuiRoot:GetWidth()) or 1920
                local rootH = type(GuiRoot.GetHeight) == "function" and tonumber(GuiRoot:GetHeight()) or 1080
                local area = width * height
                if width < rootW * 0.94 and height < rootH * 0.94 and area > bestArea then
                    best, bestArea = current, area
                end
            end
            if type(current.GetParent) ~= "function" then break end
            local ok, parent = pcall(current.GetParent, current)
            current = ok and parent or nil
        end
    end

    return best
end

local repositioning = false
local function dockTooltip(tooltip, owner)
    if repositioning or not tooltip or not owner or not isInventoryFamilyOwner(owner) then return end
    if type(tooltip.ClearAnchors) ~= "function" or type(tooltip.SetAnchor) ~= "function" then return end

    local panel = findPanel(owner)
    if not panel then return end

    local left, top, right, bottom = rect(panel)
    if not left then return end

    local rootW = type(GuiRoot.GetWidth) == "function" and tonumber(GuiRoot:GetWidth()) or 1920
    local tooltipW = type(tooltip.GetWidth) == "function" and tonumber(tooltip:GetWidth()) or 420
    if not tooltipW or tooltipW < 260 then tooltipW = 420 end

    local roomRight = rootW - right
    local roomLeft = left
    local useRight
    if roomRight >= tooltipW + GAP then
        useRight = true
    elseif roomLeft >= tooltipW + GAP then
        useRight = false
    else
        useRight = roomRight >= roomLeft
    end

    repositioning = true
    tooltip:ClearAnchors()

    if useRight then
        -- Tooltip begins directly outside the inventory's right border.
        tooltip:SetAnchor(TOPLEFT, panel, TOPRIGHT, GAP, TOP_INSET)
        tooltip._easDockSide029649 = "RIGHT"
    else
        -- Tooltip ends directly outside the inventory's left border.
        tooltip:SetAnchor(TOPRIGHT, panel, TOPLEFT, -GAP, TOP_INSET)
        tooltip._easDockSide029649 = "LEFT"
    end

    repositioning = false
end

-- All normal ESO/Suite item hover paths pass through InitializeTooltip. This
-- post-hook changes position only; it never changes tooltip content, item use,
-- keybinds, menus, or protected inventory behavior.
if type(ZO_PostHook) == "function" and type(InitializeTooltip) == "function" then
    ZO_PostHook("InitializeTooltip", function(tooltip, owner)
        if tooltip == ItemTooltip or tooltip == InformationTooltip then
            dockTooltip(tooltip, owner)
        end
    end)
end
