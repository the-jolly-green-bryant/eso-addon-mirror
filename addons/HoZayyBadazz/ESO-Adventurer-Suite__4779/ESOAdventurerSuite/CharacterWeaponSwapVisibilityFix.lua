-- ESO Adventurer Suite
-- v0.29.549 - Character weapon-swap transparent-center visibility fix.
-- Keep a Suite border around the Primary/Backup switch, but remove the opaque
-- center fill so ESO's native toggle, number, arrow and description can never
-- be visually buried behind the decorative cell.

local EPC = ESOProgressionCoach
if not EPC or not EPC.CharacterGearScreen then return end

local G = EPC.CharacterGearScreen

local function RaiseControl029549(control, level)
    if not control then return end
    if control.SetDrawTier and rawget(_G, "DT_HIGH") then
        pcall(control.SetDrawTier, control, DT_HIGH)
    end
    if control.SetDrawLayer and rawget(_G, "DL_OVERLAY") then
        pcall(control.SetDrawLayer, control, DL_OVERLAY)
    elseif control.SetDrawLayer and rawget(_G, "DL_CONTROLS") then
        pcall(control.SetDrawLayer, control, DL_CONTROLS)
    end
    if control.SetDrawLevel then
        pcall(control.SetDrawLevel, control, tonumber(level) or 900)
    end
end

local function LowerBackdrop029549(control)
    if not control then return end
    if control.SetDrawTier and rawget(_G, "DT_HIGH") then
        pcall(control.SetDrawTier, control, DT_HIGH)
    end
    if control.SetDrawLayer then
        if rawget(_G, "DL_BACKGROUND") ~= nil then
            pcall(control.SetDrawLayer, control, DL_BACKGROUND)
        elseif rawget(_G, "DL_CONTROLS") ~= nil then
            pcall(control.SetDrawLayer, control, DL_CONTROLS)
        end
    end
    if control.SetDrawLevel then pcall(control.SetDrawLevel, control, 1) end
end

local function ForceWhite029549(control)
    if not control then return end
    if control.SetColor then pcall(control.SetColor, control, 1, 1, 1, 1) end
    if control.SetAlpha then pcall(control.SetAlpha, control, 1) end
end

local function StyleSwapChildren029549(control, swap, depth)
    if not control or not swap or (tonumber(depth) or 0) > 6 then return end
    depth = (tonumber(depth) or 0) + 1

    if control ~= swap then
        RaiseControl029549(control, 940 + depth)
        ForceWhite029549(control)

        local isLabel = control.SetHorizontalAlignment and control.SetVerticalAlignment and control.SetText
        if isLabel then
            if control.ClearAnchors and control.SetAnchor then
                pcall(control.ClearAnchors, control)
                pcall(control.SetAnchor, control, CENTER, swap, CENTER, 0, 0)
            end
            pcall(control.SetHorizontalAlignment, control, TEXT_ALIGN_CENTER)
            pcall(control.SetVerticalAlignment, control, TEXT_ALIGN_CENTER)
            if swap.GetWidth and swap.GetHeight and control.SetDimensions then
                local okW, w = pcall(swap.GetWidth, swap)
                local okH, h = pcall(swap.GetHeight, swap)
                if okW and okH and tonumber(w) and tonumber(h) then
                    pcall(control.SetDimensions, control, w, h)
                end
            end
        end
    end

    if control.GetNumChildren and control.GetChild then
        local okCount, count = pcall(control.GetNumChildren, control)
        count = okCount and tonumber(count) or 0
        for i = 1, count do
            local okChild, child = pcall(control.GetChild, control, i)
            if okChild and child and child ~= control and child ~= swap then
                StyleSwapChildren029549(child, swap, depth)
            end
        end
    end
end

local function RaiseUtilityText029549(cell)
    if not cell then return end
    local candidates = {
        cell.label, cell.text, cell.nameLabel, cell.description,
        cell.descriptionLabel, cell.title, cell.value,
    }
    for _, control in ipairs(candidates) do
        if control then
            RaiseControl029549(control, 970)
            ForceWhite029549(control)
        end
    end
end

local function FixWeaponSwap029549()
    local swap = rawget(_G, "ZO_CharacterWeaponSwap")
    if not swap then return false end

    if G.weaponUtilityCells and G.weaponUtilityCells.Swap then
        local cell = G.weaponUtilityCells.Swap
        RaiseControl029549(cell, 200)

        if cell.bg then
            if cell.bg.SetHidden then pcall(cell.bg.SetHidden, cell.bg, false) end
            if cell.bg.SetAlpha then pcall(cell.bg.SetAlpha, cell.bg, 1) end
            -- No opaque center: the native ESO control and any description text
            -- remain visible regardless of sibling/scene composition order.
            if cell.bg.SetCenterColor then pcall(cell.bg.SetCenterColor, cell.bg, 0, 0, 0, 0) end
            if cell.bg.SetEdgeColor then pcall(cell.bg.SetEdgeColor, cell.bg, 0.82, 0.76, 0.58, 0.96) end
            LowerBackdrop029549(cell.bg)
        end

        if cell.icon and cell.icon.SetHidden then pcall(cell.icon.SetHidden, cell.icon, true) end
        RaiseUtilityText029549(cell)
    end

    RaiseControl029549(swap, 930)
    ForceWhite029549(swap)
    StyleSwapChildren029549(swap, swap, 0)
    if swap.SetHidden then pcall(swap.SetHidden, swap, false) end
    return true
end

if type(G.LayoutWeaponUtilityCells) == "function" and not G._weaponSwapVisibility029549 then
    local base = G.LayoutWeaponUtilityCells
    function G:LayoutWeaponUtilityCells(...)
        local result = base(self, ...)
        FixWeaponSwap029549()
        return result
    end
    G._weaponSwapVisibility029549 = true
end

FixWeaponSwap029549()

if G.IsPlayerSceneShowing and G:IsPlayerSceneShowing() and G.RequestRefresh then
    G:RequestRefresh(0)
end
