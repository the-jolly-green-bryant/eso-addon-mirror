MCAT_Interface = {}

--#region[purple] Modules and locals
local WM = WINDOW_MANAGER

-- shared base radius (screen px); every mechanic's band is a fraction of this
local R = 100

-- fraction of R controlling a mechanic's own pip size vs. its distance from center. BoundArmaments
-- sits on GrimFocus's diagonal axis, just past its spikes' own tips (see Abilities.lua) -- these
-- two values are tuned to that relationship, not derived from GrimFocus's constants at runtime.
local BAND_SIZE = { Crux = 1.71, SeethingFury = 1.632, BoundArmaments = 1.3, GrimFocus = 0.54 }
local BAND_POS  = { Crux = 1.71, SeethingFury = 2.206, BoundArmaments = 0.82, GrimFocus = 0.54 }

-- fraction of placeR where a pip's center sits, and fraction of sizeR it measures across
local PIP_CENTER_RATIO = { Crux = 0.55, SeethingFury = 0.55, BoundArmaments = 0.62, GrimFocus = 0.55 }
local PIP_SIZE_RATIO   = { Crux = 0.5, SeethingFury = 0.45, BoundArmaments = 0.26, GrimFocus = 0.18 }

local DRAW_LEVEL = { GrimFocus = 0, BoundArmaments = 1, Crux = 0, SeethingFury = 0 }

local GHOST_R, GHOST_G, GHOST_B, GHOST_A = 1, 1, 1, 0.08
-- Debug Mode is for previewing the full layout out of combat, where most pips would
-- otherwise sit at this barely-visible 8% ghost opacity; swap in a bright magenta instead.
local DEBUG_GHOST_R, DEBUG_GHOST_G, DEBUG_GHOST_B, DEBUG_GHOST_A = 1, 0, 1, 0.65

-- mechanicKey -> container control; mechanicKey -> { pip controls, 1 per MCAT_Definitions[key].pips entry }
local Containers = {}
local Pips = {}

-- Containers must be parented to a real top-level window to be rendered at all;
-- a control merely descended from GuiRoot gets valid coordinates but is never
-- composited into the frame (confirmed via GetLeft/Top/Right/Bottom returning
-- a correct on-screen rect that still never painted). Anchor target stays
-- GuiRoot,CENTER for reticle-centered positioning; only the parent is TopLevel.
local TopLevel
--#endregion

--#region[teal] Color
local HexToRGB = MCAT_Utils.HexToRGB
--#endregion

--#region[orange] Lighting rules
-- i is 0-based pip index within the mechanic's own pips array.
-- Returns lit, hasOverflow -- hasOverflow swaps the pip to pipDef.overflowTexturePath when
-- true (a shape-only signal for banked extra stacks, no color change; see Update()).
local function PipState(mechanicKey, i, stacks)
    if mechanicKey == "GrimFocus" then
        local primary = math.min(stacks, 5)
        if i < 4 then
            -- diagonal group: builds one per stack, 1-4; all 4 gain their hilt together at
            -- the max stack (10), the very last thing to happen in the whole progression.
            return i < math.min(primary, 4), stacks >= 10
        else
            -- cardinal group: all four snap on together at the 5th stack, then each gains
            -- its own hilt one at a time as stacks bank further (6, 7, 8, 9).
            return primary >= 5, stacks >= i + 2
        end
    elseif mechanicKey == "BoundArmaments" then
        -- each chevron doubles up individually as stacks bank past the primary 4 (5, 6, 7, 8).
        return i < math.min(4, stacks), stacks >= 5 + i
    else
        -- Crux, SeethingFury: simple fill, no overflow state
        return i < stacks, false
    end
end
--#endregion

--#region[yellow] Update
function MCAT_Interface.Update()
    local ghostR, ghostG, ghostB, ghostA = GHOST_R, GHOST_G, GHOST_B, GHOST_A
    if MCAT_Settings.IsDebugEnabled() then
        ghostR, ghostG, ghostB, ghostA = DEBUG_GHOST_R, DEBUG_GHOST_G, DEBUG_GHOST_B, DEBUG_GHOST_A
    end
    for mechanicKey, def in pairs(MCAT_Definitions) do
        local state = MCAT.State[mechanicKey]
        local container = Containers[mechanicKey]
        container:SetHidden(not state.visible)
        if state.visible then
            local scale, spacingPx = MCAT_Settings.GetScale(mechanicKey), MCAT_Settings.GetSpacing(mechanicKey)
            local sizeR = R * BAND_SIZE[mechanicKey] * scale
            local placeR = R * BAND_POS[mechanicKey] * scale + spacingPx

            local centerDist, pipSize, offset
            if mechanicKey == "GrimFocus" then
                offset = placeR - sizeR
            else
                centerDist = placeR * PIP_CENTER_RATIO[mechanicKey]
                pipSize = sizeR * PIP_SIZE_RATIO[mechanicKey]
            end

            local baseR, baseG, baseB = HexToRGB(MCAT_Settings.GetColor(mechanicKey))

            for i, pipDef in ipairs(def.pips) do
                local pip = Pips[mechanicKey][i]
                local dx, dy, w, h

                if mechanicKey == "GrimFocus" then
                    local len = sizeR * pipDef.lenRatio
                    local innerGap = 0
                    local innerDist, tipDist = offset + innerGap, offset + len
                    local midDist = (innerDist + tipDist) / 2
                    local spanLength = tipDist - innerDist
                    dx, dy = midDist * math.cos(pipDef.angle), midDist * math.sin(pipDef.angle)
                    -- square control: the texture's own art supplies the elongation and is
                    -- already centered/oriented for it, so rotation stays clean at any angle.
                    -- A non-square box (spanLength x spanWidth) would need non-uniform stretch
                    -- to re-orient after SetTextureRotation, which is what caused the blur.
                    w, h = spanLength, spanLength
                else
                    dx, dy = centerDist * math.cos(pipDef.angle), centerDist * math.sin(pipDef.angle)
                    w, h = pipSize, pipSize
                end

                pip:ClearAnchors()
                pip:SetAnchor(CENTER, container, CENTER, dx, dy)
                pip:SetDimensions(w, h)

                local lit, hasOverflow = PipState(mechanicKey, i - 1, state.stacks)

                if pipDef.overflowTexturePath then
                    pip:SetTexture(hasOverflow and pipDef.overflowTexturePath or pipDef.texturePath)
                end

                local setColor = def.pipTexturePath and pip.SetColor or pip.SetCenterColor
                if lit then
                    setColor(pip, baseR, baseG, baseB, 1)
                else
                    setColor(pip, ghostR, ghostG, ghostB, ghostA)
                end
            end
        end
    end
end
--#endregion

--#region[green] Init
-- Must run before MCAT_Tracker.Initialize(): Tracker's initial Resync() call already
-- calls MCAT_Interface.Update(), which needs these controls to exist. Doesn't touch
-- MCAT.State itself, so it has no dependency on Tracker having run first.
function MCAT_Interface.Initialize()
    TopLevel = WM:CreateTopLevelWindow("MCAT_Interface_TopLevel")
    TopLevel:SetHidden(false)

    for mechanicKey, def in pairs(MCAT_Definitions) do
        local container = WM:CreateControl("MCAT_Interface_Container_" .. mechanicKey, TopLevel, CT_CONTROL)
        container:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        container:SetDrawLevel(DRAW_LEVEL[mechanicKey])
        Containers[mechanicKey] = container

        Pips[mechanicKey] = {}
        for i, pipDef in ipairs(def.pips) do
            local pip
            local texturePath = pipDef.texturePath or def.pipTexturePath
            if texturePath then
                pip = WM:CreateControl("MCAT_Interface_Pip_" .. mechanicKey .. "_" .. i, container, CT_TEXTURE)
                pip:SetTexture(texturePath)
                pip:SetColor(GHOST_R, GHOST_G, GHOST_B, GHOST_A)
            else
                pip = WM:CreateControl("MCAT_Interface_Pip_" .. mechanicKey .. "_" .. i, container, CT_BACKDROP)
                pip:SetCenterColor(GHOST_R, GHOST_G, GHOST_B, GHOST_A)
            end
            Pips[mechanicKey][i] = pip
        end
    end
end
--#endregion
