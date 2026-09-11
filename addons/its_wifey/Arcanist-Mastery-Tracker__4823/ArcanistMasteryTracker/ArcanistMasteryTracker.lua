local ADDON_NAME = "ArcanistMasteryTracker"
local DISPLAY_NAME = "Arcanist Mastery Tracker"

-- =========================================================
-- IDs
-- =========================================================

local MAJOR_FORCE_ID = 61747
local INK_THRESHOLD = 100000

local ABYSSAL_EMERGENCE_ID = 263369
local CRUX_ID = 184220

local FATE_REALIGNED_BUFF_ID = 268372
local UNBOUND_POTENTIAL_COMBAT_ID = 263411
local FATED_FORTUNE_EFFECT_ID = 194875
local MAJOR_VITALITY_ID = 61713
local FATEWOVEN_ARMOR_ID = 183648
local CRUXWEAVER_ARMOR_ID = 185908
local UNBREAKABLE_FATE_ID = 186477

-- Arcanist utility trackers
local GIBBERING_SHIELD_ID = 183676
local GIBBERING_SHELTER_ID = 192380
local SANCTUM_ABYSSAL_SEA_ID = 192372
local BLOCK_MITIGATION_ADVANCED_STAT_ID = 7
local BLOCK_MITIGATION_CAP = 90

-- Class Mastery passive skill IDs
local ABYSSAL_MASTERY_SKILL_ID = 263316
local FATE_MASTERY_SKILL_ID = 263398
local UNBOUND_MASTERY_SKILL_ID = 263410
local ERUDITE_MASTERY_SKILL_ID = 263412
local INK_MASTERY_SKILL_ID = 263416

-- =========================================================
-- VARIABLES
-- =========================================================

local savedVars
local panel

local inCombat = false

-- Actual purchased Class Mastery selections
local inkMasterySelected = false
local abyssalMasterySelected = false
local fateMasterySelected = false
local unboundMasterySelected = false
local eruditeMasterySelected = false

local nextMasteryScanTime = 0

-- Ink-Scribe
local inkFrame
local inkTitleLabel
local inkProgressLabel
local inkForceLabel

local runningTotal = 0
local majorForceActive = false
local majorForceEndTime = 0

-- Abyssal
local abyssalFrame
local abyssalTitleLabel
local abyssalTimerLabel

local abyssalActive = false
local abyssalEndTime = 0

-- Standalone Crux Counter
local cruxFrame
local cruxTexture
local cruxNumberLabel

local currentCrux = 0

-- Fate Realigned
local fateFrame
local fateTitleLabel
local fateTimerLabel

local fateActive = false
local fateEndTime = 0

-- Unbound Potential
local unboundFrame
local unboundTitleLabel
local unboundTimerLabel

local unboundActive = false
local unboundEndTime = 0

-- Erudite's Rigor
local eruditeFrame
local eruditeTitleLabel
local eruditeArmorLabel
local eruditeTimerLabel

local armorActive = false
local armorEndTime = 0

local eruditeActive = false
local eruditeEndTime = 0

-- Gibbering Shield / morphs
local gibberFrame
local gibberTitleLabel
local gibberBar
local gibberTimerLabel
local gibberActive = false
local gibberEndTime = 0

-- Block Mitigation
local blockFrame
local blockTitleLabel
local blockValueLabel


-- =========================================================
-- DEFAULTS
-- =========================================================

local defaults = {

    -- Ink-Scribe
    inkEnabled = true,

    inkX = 0,
    inkY = -120,

    inkFontSize = 32,
    forceFontSize = 28,

    inkProgressColor = {
        r = 1,
        g = 0.85,
        b = 0,
        a = 1,
    },

    forceColor = {
        r = 0.3,
        g = 1,
        b = 0.3,
        a = 1,
    },

    inkUnlocked = false,
    showInkTitle = true,

    -- Abyssal
    abyssalEnabled = true,

    abyssalX = 0,
    abyssalY = 80,

    abyssalFontSize = 32,

    abyssalColor = {
        r = 0.6,
        g = 1,
        b = 0.4,
        a = 1,
    },

    abyssalUnlocked = false,
    showAbyssalTitle = true,

    -- Crux Counter
    cruxEnabled = true,

    cruxX = 220,
    cruxY = 0,

    cruxSize = 110,
    cruxTextSize = 38,

    cruxTextColor = {
        r = 1,
        g = 1,
        b = 1,
        a = 1,
    },

    cruxUnlocked = false,
    cruxHideOutOfCombat = true,

    -- Fate Realigned
    fateEnabled = true,

    fateX = -220,
    fateY = 80,

    fateFontSize = 32,

    fateColor = {
        r = 0.8,
        g = 0.5,
        b = 1,
        a = 1,
    },

    fateUnlocked = false,
    showFateTitle = true,

    -- Unbound Potential
    unboundEnabled = true,

    unboundX = -220,
    unboundY = -40,

    unboundFontSize = 32,

    unboundColor = {
        r = 0.4,
        g = 0.9,
        b = 1,
        a = 1,
    },

    unboundUnlocked = false,
    showUnboundTitle = true,

    -- Erudite's Rigor
    eruditeEnabled = true,

    eruditeX = 220,
    eruditeY = -120,

    eruditeFontSize = 32,

    eruditeColor = {
        r = 1,
        g = 0.65,
        b = 0.25,
        a = 1,
    },

    eruditeUnlocked = false,
    showEruditeTitle = true,

    -- Gibbering Shield
    gibberEnabled = true,
    gibberX = 0,
    gibberY = 200,
    gibberFontSize = 32,
    gibberColor = { r = 0.25, g = 0.85, b = 1, a = 1 },
    gibberUnlocked = false,
    showGibberTitle = true,

    -- Block Mitigation
    blockEnabled = true,
    blockX = 220,
    blockY = 120,
    blockFontSize = 30,
    blockColor = { r = 1, g = 0.85, b = 0.2, a = 1 },
    blockCapColor = { r = 0.3, g = 1, b = 0.3, a = 1 },
    blockUnlocked = false,
    blockHideOutOfCombat = true,

}

-- =========================================================
-- HELPERS
-- =========================================================

local function ClampProgress(value)

    if value < 0 then
        return 0
    end

    if value > INK_THRESHOLD then
        return INK_THRESHOLD
    end

    return value
end

-- =========================================================
-- INK POSITION
-- =========================================================

local function UpdateInkPosition()

    inkFrame:ClearAnchors()

    inkFrame:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        savedVars.inkX,
        savedVars.inkY
    )
end

local function SaveInkPosition()

    local left = inkFrame:GetLeft()
    local top = inkFrame:GetTop()

    if not left or not top then
        return
    end

    local rootLeft = GuiRoot:GetLeft()
    local rootTop = GuiRoot:GetTop()

    local frameCenterX =
        left + (inkFrame:GetWidth() / 2)

    local frameCenterY =
        top + (inkFrame:GetHeight() / 2)

    local rootCenterX =
        rootLeft + (GuiRoot:GetWidth() / 2)

    local rootCenterY =
        rootTop + (GuiRoot:GetHeight() / 2)

    savedVars.inkX =
        frameCenterX - rootCenterX

    savedVars.inkY =
        frameCenterY - rootCenterY
end

local function SetInkUnlocked(unlocked)

    savedVars.inkUnlocked = unlocked

    inkFrame:SetMouseEnabled(unlocked)
    inkFrame:SetMovable(unlocked)
end

-- =========================================================
-- ABYSSAL POSITION
-- =========================================================

local function UpdateAbyssalPosition()

    abyssalFrame:ClearAnchors()

    abyssalFrame:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        savedVars.abyssalX,
        savedVars.abyssalY
    )
end

local function SaveAbyssalPosition()

    local left = abyssalFrame:GetLeft()
    local top = abyssalFrame:GetTop()

    if not left or not top then
        return
    end

    local rootLeft = GuiRoot:GetLeft()
    local rootTop = GuiRoot:GetTop()

    local frameCenterX =
        left + (abyssalFrame:GetWidth() / 2)

    local frameCenterY =
        top + (abyssalFrame:GetHeight() / 2)

    local rootCenterX =
        rootLeft + (GuiRoot:GetWidth() / 2)

    local rootCenterY =
        rootTop + (GuiRoot:GetHeight() / 2)

    savedVars.abyssalX =
        frameCenterX - rootCenterX

    savedVars.abyssalY =
        frameCenterY - rootCenterY
end

local function SetAbyssalUnlocked(unlocked)

    savedVars.abyssalUnlocked = unlocked

    abyssalFrame:SetMouseEnabled(unlocked)
    abyssalFrame:SetMovable(unlocked)
end

-- =========================================================
-- CRUX POSITION
-- =========================================================

local function UpdateCruxPosition()

    cruxFrame:ClearAnchors()

    cruxFrame:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        savedVars.cruxX,
        savedVars.cruxY
    )
end

local function SaveCruxPosition()

    local left = cruxFrame:GetLeft()
    local top = cruxFrame:GetTop()

    if not left or not top then
        return
    end

    local rootLeft = GuiRoot:GetLeft()
    local rootTop = GuiRoot:GetTop()

    local frameCenterX =
        left + (cruxFrame:GetWidth() / 2)

    local frameCenterY =
        top + (cruxFrame:GetHeight() / 2)

    local rootCenterX =
        rootLeft + (GuiRoot:GetWidth() / 2)

    local rootCenterY =
        rootTop + (GuiRoot:GetHeight() / 2)

    savedVars.cruxX =
        frameCenterX - rootCenterX

    savedVars.cruxY =
        frameCenterY - rootCenterY
end

local function SetCruxUnlocked(unlocked)

    savedVars.cruxUnlocked = unlocked

    cruxFrame:SetMouseEnabled(unlocked)
    cruxFrame:SetMovable(unlocked)
end

-- =========================================================
-- FATE POSITION
-- =========================================================

local function UpdateFatePosition()

    fateFrame:ClearAnchors()

    fateFrame:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        savedVars.fateX,
        savedVars.fateY
    )
end

local function SaveFatePosition()

    local left = fateFrame:GetLeft()
    local top = fateFrame:GetTop()

    if not left or not top then
        return
    end

    local rootLeft = GuiRoot:GetLeft()
    local rootTop = GuiRoot:GetTop()

    local frameCenterX =
        left + (fateFrame:GetWidth() / 2)

    local frameCenterY =
        top + (fateFrame:GetHeight() / 2)

    local rootCenterX =
        rootLeft + (GuiRoot:GetWidth() / 2)

    local rootCenterY =
        rootTop + (GuiRoot:GetHeight() / 2)

    savedVars.fateX =
        frameCenterX - rootCenterX

    savedVars.fateY =
        frameCenterY - rootCenterY
end

local function SetFateUnlocked(unlocked)

    savedVars.fateUnlocked = unlocked

    fateFrame:SetMouseEnabled(unlocked)
    fateFrame:SetMovable(unlocked)
end

-- =========================================================
-- UNBOUND POSITION
-- =========================================================

local function UpdateUnboundPosition()

    unboundFrame:ClearAnchors()

    unboundFrame:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        savedVars.unboundX,
        savedVars.unboundY
    )
end

local function SaveUnboundPosition()

    local left = unboundFrame:GetLeft()
    local top = unboundFrame:GetTop()

    if not left or not top then
        return
    end

    local rootLeft = GuiRoot:GetLeft()
    local rootTop = GuiRoot:GetTop()

    local frameCenterX =
        left + (unboundFrame:GetWidth() / 2)

    local frameCenterY =
        top + (unboundFrame:GetHeight() / 2)

    local rootCenterX =
        rootLeft + (GuiRoot:GetWidth() / 2)

    local rootCenterY =
        rootTop + (GuiRoot:GetHeight() / 2)

    savedVars.unboundX =
        frameCenterX - rootCenterX

    savedVars.unboundY =
        frameCenterY - rootCenterY
end

local function SetUnboundUnlocked(unlocked)

    savedVars.unboundUnlocked = unlocked

    unboundFrame:SetMouseEnabled(unlocked)
    unboundFrame:SetMovable(unlocked)
end

-- =========================================================
-- ERUDITE POSITION
-- =========================================================

local function UpdateEruditePosition()

    eruditeFrame:ClearAnchors()

    eruditeFrame:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        savedVars.eruditeX,
        savedVars.eruditeY
    )
end

local function SaveEruditePosition()

    local left = eruditeFrame:GetLeft()
    local top = eruditeFrame:GetTop()

    if not left or not top then
        return
    end

    local rootLeft = GuiRoot:GetLeft()
    local rootTop = GuiRoot:GetTop()

    local frameCenterX =
        left + (eruditeFrame:GetWidth() / 2)

    local frameCenterY =
        top + (eruditeFrame:GetHeight() / 2)

    local rootCenterX =
        rootLeft + (GuiRoot:GetWidth() / 2)

    local rootCenterY =
        rootTop + (GuiRoot:GetHeight() / 2)

    savedVars.eruditeX =
        frameCenterX - rootCenterX

    savedVars.eruditeY =
        frameCenterY - rootCenterY
end

local function SetEruditeUnlocked(unlocked)

    savedVars.eruditeUnlocked = unlocked

    eruditeFrame:SetMouseEnabled(unlocked)
    eruditeFrame:SetMovable(unlocked)
end

-- =========================================================
-- UTILITY TRACKER POSITION / LOCKING
-- =========================================================

local function SaveCenteredPosition(frame, xKey, yKey)
    local centerX, centerY = frame:GetCenter()
    local rootCenterX, rootCenterY = GuiRoot:GetCenter()
    if centerX and centerY and rootCenterX and rootCenterY then
        savedVars[xKey] = centerX - rootCenterX
        savedVars[yKey] = centerY - rootCenterY
    end
end

local function PositionUtilityFrame(frame, x, y)
    frame:ClearAnchors()
    frame:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
end

local function SetUtilityUnlocked(frame, unlocked)
    frame:SetMouseEnabled(unlocked)
    frame:SetMovable(unlocked)
end

-- =========================================================
-- FONTS
-- =========================================================

local function UpdateFonts()

    inkTitleLabel:SetFont(
        string.format(
            "$(BOLD_FONT)|%d|soft-shadow-thick",
            savedVars.inkFontSize
        )
    )

    inkProgressLabel:SetFont(
        string.format(
            "$(BOLD_FONT)|%d|soft-shadow-thick",
            savedVars.inkFontSize
        )
    )

    inkForceLabel:SetFont(
        string.format(
            "$(BOLD_FONT)|%d|soft-shadow-thick",
            savedVars.forceFontSize
        )
    )

    abyssalTitleLabel:SetFont(
        string.format(
            "$(BOLD_FONT)|%d|soft-shadow-thick",
            savedVars.abyssalFontSize
        )
    )

    abyssalTimerLabel:SetFont(
        string.format(
            "$(BOLD_FONT)|%d|soft-shadow-thick",
            savedVars.abyssalFontSize
        )
    )

    cruxNumberLabel:SetFont(
        string.format(
            "$(BOLD_FONT)|%d|soft-shadow-thick",
            savedVars.cruxTextSize
        )
    )

    fateTitleLabel:SetFont(
        string.format(
            "$(BOLD_FONT)|%d|soft-shadow-thick",
            savedVars.fateFontSize
        )
    )

    fateTimerLabel:SetFont(
        string.format(
            "$(BOLD_FONT)|%d|soft-shadow-thick",
            savedVars.fateFontSize
        )
    )

    unboundTitleLabel:SetFont(
        string.format(
            "$(BOLD_FONT)|%d|soft-shadow-thick",
            savedVars.unboundFontSize
        )
    )

    unboundTimerLabel:SetFont(
        string.format(
            "$(BOLD_FONT)|%d|soft-shadow-thick",
            savedVars.unboundFontSize
        )
    )

    eruditeTitleLabel:SetFont(
        string.format(
            "$(BOLD_FONT)|%d|soft-shadow-thick",
            savedVars.eruditeFontSize
        )
    )

    eruditeArmorLabel:SetFont(
        string.format(
            "$(BOLD_FONT)|%d|soft-shadow-thick",
            savedVars.eruditeFontSize
        )
    )

    eruditeTimerLabel:SetFont(
        string.format(
            "$(BOLD_FONT)|%d|soft-shadow-thick",
            savedVars.eruditeFontSize
        )
    )


    gibberTitleLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", savedVars.gibberFontSize))
    gibberTimerLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", savedVars.gibberFontSize))
    blockTitleLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", savedVars.blockFontSize))
    blockValueLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", savedVars.blockFontSize))
end

-- =========================================================
-- COLORS
-- =========================================================

local function UpdateColors()

    local c =
        savedVars.inkProgressColor

    inkProgressLabel:SetColor(
        c.r,
        c.g,
        c.b,
        c.a
    )

    local f =
        savedVars.forceColor

    inkForceLabel:SetColor(
        f.r,
        f.g,
        f.b,
        f.a
    )

    local a =
        savedVars.abyssalColor

    abyssalTimerLabel:SetColor(
        a.r,
        a.g,
        a.b,
        a.a
    )

    local crux =
        savedVars.cruxTextColor

    cruxNumberLabel:SetColor(
        crux.r,
        crux.g,
        crux.b,
        crux.a
    )

    local fate =
        savedVars.fateColor

    fateTimerLabel:SetColor(
        fate.r,
        fate.g,
        fate.b,
        fate.a
    )

    local unbound =
        savedVars.unboundColor

    unboundTimerLabel:SetColor(
        unbound.r,
        unbound.g,
        unbound.b,
        unbound.a
    )

    local erudite =
        savedVars.eruditeColor

    eruditeArmorLabel:SetColor(
        erudite.r,
        erudite.g,
        erudite.b,
        erudite.a
    )

    eruditeTimerLabel:SetColor(
        erudite.r,
        erudite.g,
        erudite.b,
        erudite.a
    )


    local g = savedVars.gibberColor
    gibberTimerLabel:SetColor(g.r, g.g, g.b, g.a)
    gibberBar:SetColor(g.r, g.g, g.b, g.a)

    local b = savedVars.blockColor
    blockValueLabel:SetColor(b.r, b.g, b.b, b.a)
end

-- =========================================================
-- CRUX SIZE
-- =========================================================

local function UpdateCruxSize()

    cruxFrame:SetDimensions(
        savedVars.cruxSize,
        savedVars.cruxSize
    )

    cruxTexture:SetDimensions(
        savedVars.cruxSize,
        savedVars.cruxSize
    )

    cruxNumberLabel:SetDimensions(
        savedVars.cruxSize,
        savedVars.cruxSize
    )
end

-- =========================================================
-- VISIBILITY
-- =========================================================

local function UpdateInkVisibility()

    if not savedVars.inkEnabled then
        inkFrame:SetHidden(true)
        return
    end

    if savedVars.inkUnlocked then
        inkFrame:SetHidden(false)
        return
    end

    inkFrame:SetHidden(not inCombat)
end

local function UpdateAbyssalVisibility()

    if not savedVars.abyssalEnabled then
        abyssalFrame:SetHidden(true)
        return
    end

    if savedVars.abyssalUnlocked then
        abyssalFrame:SetHidden(false)
        return
    end

    if not inCombat then
        abyssalFrame:SetHidden(true)
        return
    end

    abyssalFrame:SetHidden(not abyssalActive)
end

local function UpdateCruxVisibility()

    if not savedVars.cruxEnabled then
        cruxFrame:SetHidden(true)
        return
    end

    if savedVars.cruxUnlocked then
        cruxFrame:SetHidden(false)
        return
    end

    if savedVars.cruxHideOutOfCombat
        and not inCombat then

        cruxFrame:SetHidden(true)
        return
    end

    cruxFrame:SetHidden(false)
end

local function UpdateFateVisibility()

    if not savedVars.fateEnabled then
        fateFrame:SetHidden(true)
        return
    end

    if savedVars.fateUnlocked then
        fateFrame:SetHidden(false)
        return
    end

    if not inCombat then
        fateFrame:SetHidden(true)
        return
    end

    fateFrame:SetHidden(not fateActive)
end

local function UpdateUnboundVisibility()

    if not savedVars.unboundEnabled then
        unboundFrame:SetHidden(true)
        return
    end

    if savedVars.unboundUnlocked then
        unboundFrame:SetHidden(false)
        return
    end

    if not inCombat then
        unboundFrame:SetHidden(true)
        return
    end

    unboundFrame:SetHidden(not unboundActive)
end

local function UpdateEruditeVisibility()

    if not savedVars.eruditeEnabled then
        eruditeFrame:SetHidden(true)
        return
    end

    if savedVars.eruditeUnlocked then
        eruditeFrame:SetHidden(false)
        return
    end

    if not inCombat then
        eruditeFrame:SetHidden(true)
        return
    end

    eruditeFrame:SetHidden(not eruditeActive)
end

-- =========================================================
-- ARCANIST UTILITY DISPLAYS
-- =========================================================

local function UpdateGibberDisplay()
    if not savedVars.gibberEnabled then gibberFrame:SetHidden(true) return end
    if savedVars.gibberUnlocked then gibberFrame:SetHidden(false) else gibberFrame:SetHidden(not gibberActive) end
    if gibberFrame:IsHidden() then return end
    gibberTitleLabel:SetHidden(not savedVars.showGibberTitle)
    if not gibberActive then
        gibberBar:SetMinMax(0, 10)
        gibberBar:SetValue(10)
        gibberTimerLabel:SetText("10.0s")
        return
    end
    local remaining = gibberEndTime - GetFrameTimeSeconds()
    if remaining <= 0 then
        gibberActive = false
        gibberEndTime = 0
        if not savedVars.gibberUnlocked then gibberFrame:SetHidden(true) end
        return
    end
    gibberBar:SetMinMax(0, 10)
    gibberBar:SetValue(math.min(10, remaining))
    if remaining <= 5 then
        gibberTimerLabel:SetText(tostring(math.ceil(remaining)))
    else
        gibberTimerLabel:SetText(string.format("%.1fs", remaining))
    end
end

local function GetBlockMitigationPercent()
    local _, _, pct = GetAdvancedStatValue(BLOCK_MITIGATION_ADVANCED_STAT_ID)
    return tonumber(pct) or 0
end

local function UpdateBlockDisplay()
    if not savedVars.blockEnabled then blockFrame:SetHidden(true) return end
    if savedVars.blockUnlocked then
        blockFrame:SetHidden(false)
    elseif savedVars.blockHideOutOfCombat and not inCombat then
        blockFrame:SetHidden(true)
        return
    else
        blockFrame:SetHidden(false)
    end
    local pct = math.floor(GetBlockMitigationPercent() + 0.5)
    if pct >= BLOCK_MITIGATION_CAP then
        blockValueLabel:SetText(string.format("%d%% - CAPPED", pct))
        local c = savedVars.blockCapColor
        blockValueLabel:SetColor(c.r, c.g, c.b, c.a)
    else
        blockValueLabel:SetText(string.format("%d%% / %d%%", pct, BLOCK_MITIGATION_CAP))
        local c = savedVars.blockColor
        blockValueLabel:SetColor(c.r, c.g, c.b, c.a)
    end
end

-- =========================================================
-- INK DISPLAY
-- =========================================================

local function UpdateInkDisplay()

    if not inkMasterySelected then
        inkFrame:SetHidden(true)
        return
    end

    UpdateInkVisibility()

    if inkFrame:IsHidden() then
        return
    end

    inkTitleLabel:SetHidden(
        not savedVars.showInkTitle
    )

    local displayTotal =
        ClampProgress(runningTotal)

    if runningTotal >= INK_THRESHOLD
        and not majorForceActive then

        inkProgressLabel:SetText(
            "100,000 / 100,000  PROC IMMINENT"
        )

    else

        inkProgressLabel:SetText(
            string.format(
                "%d / %d",
                displayTotal,
                INK_THRESHOLD
            )
        )
    end

    if majorForceActive then

        local remaining =
            majorForceEndTime -
            GetFrameTimeSeconds()

        if remaining <= 0 then

            majorForceActive = false
            inkForceLabel:SetHidden(true)

        else

            inkForceLabel:SetHidden(false)

            inkForceLabel:SetText(
                string.format(
                    "MAJOR FORCE %.1fs",
                    remaining
                )
            )
        end

    else

        inkForceLabel:SetHidden(true)

    end
end

-- =========================================================
-- ABYSSAL DISPLAY
-- =========================================================

local function UpdateAbyssalDisplay()

    if not abyssalMasterySelected then
        abyssalFrame:SetHidden(true)
        return
    end

    UpdateAbyssalVisibility()

    if abyssalFrame:IsHidden() then
        return
    end

    abyssalTitleLabel:SetHidden(
        not savedVars.showAbyssalTitle
    )

    if abyssalActive then

        local remaining =
            abyssalEndTime -
            GetFrameTimeSeconds()

        if remaining <= 0 then

            abyssalActive = false

            UpdateAbyssalVisibility()

            return
        end

        abyssalTimerLabel:SetText(
            string.format(
                "%.1fs",
                remaining
            )
        )

    else

        abyssalTimerLabel:SetText(
            "READY"
        )

    end
end

-- =========================================================
-- CRUX DISPLAY
-- =========================================================

local function UpdateCruxDisplay()

    UpdateCruxVisibility()

    if cruxFrame:IsHidden() then
        return
    end

    cruxNumberLabel:SetText(
        tostring(currentCrux)
    )
end

-- =========================================================
-- FATE DISPLAY
-- =========================================================

local function UpdateFateDisplay()

    if not fateMasterySelected then
        fateFrame:SetHidden(true)
        return
    end

    UpdateFateVisibility()

    if fateFrame:IsHidden() then
        return
    end

    fateTitleLabel:SetHidden(
        not savedVars.showFateTitle
    )

    if fateActive then

        local remaining =
            fateEndTime -
            GetFrameTimeSeconds()

        if remaining <= 0 then

            fateActive = false
            fateEndTime = 0

            UpdateFateVisibility()

            return
        end

        fateTimerLabel:SetText(
            string.format(
                "%.1fs",
                remaining
            )
        )

    else

        fateTimerLabel:SetText(
            "READY"
        )
    end
end

-- =========================================================
-- UNBOUND DISPLAY
-- =========================================================

local function UpdateUnboundDisplay()

    if not unboundMasterySelected then
        unboundFrame:SetHidden(true)
        return
    end

    UpdateUnboundVisibility()

    if unboundFrame:IsHidden() then
        return
    end

    unboundTitleLabel:SetHidden(
        not savedVars.showUnboundTitle
    )

    if unboundActive then

        local remaining =
            unboundEndTime -
            GetFrameTimeSeconds()

        if remaining <= 0 then

            unboundActive = false
            unboundEndTime = 0

            UpdateUnboundVisibility()

            return
        end

        unboundTimerLabel:SetText(
            string.format(
                "%.1fs",
                remaining
            )
        )

    else

        unboundTimerLabel:SetText(
            "READY"
        )
    end
end

-- =========================================================
-- ERUDITE DISPLAY
-- =========================================================

local function UpdateEruditeDisplay()

    if not eruditeMasterySelected then
        eruditeFrame:SetHidden(true)
        return
    end

    if not savedVars.eruditeEnabled then
        eruditeFrame:SetHidden(true)
        return
    end

    if savedVars.eruditeUnlocked then
        eruditeFrame:SetHidden(false)
    elseif not inCombat then
        eruditeFrame:SetHidden(true)
        return
    else
        eruditeFrame:SetHidden(false)
    end

    eruditeTitleLabel:SetHidden(
        not savedVars.showEruditeTitle
    )

    if armorActive then

        local armorRemaining =
            armorEndTime -
            GetFrameTimeSeconds()

        if armorRemaining <= 0 then

            armorActive = false
            armorEndTime = 0

            eruditeArmorLabel:SetText(
                "ARMOR DOWN"
            )

        else

            eruditeArmorLabel:SetText(
                string.format(
                    "ARMOR: %.1fs",
                    armorRemaining
                )
            )
        end

    else

        eruditeArmorLabel:SetText(
            "ARMOR DOWN"
        )
    end

    if eruditeActive then

        local remaining =
            eruditeEndTime -
            GetFrameTimeSeconds()

        if remaining <= 0 then

            eruditeActive = false
            eruditeEndTime = 0

            eruditeTimerLabel:SetText(
                "VITALITY: --"
            )

        else

            eruditeTimerLabel:SetText(
                string.format(
                    "VITALITY: %.1fs",
                    remaining
                )
            )
        end

    else

        eruditeTimerLabel:SetText(
            "VITALITY: --"
        )
    end
end

-- =========================================================
-- RESET
-- =========================================================

local function ResetInkProgress()

    runningTotal = 0

    UpdateInkDisplay()
end

-- =========================================================
-- CLASS MASTERY SELECTIONS
-- =========================================================

local function RefreshMasterySelections()

    local oldInk = inkMasterySelected
    local oldAbyssal = abyssalMasterySelected
    local oldFate = fateMasterySelected
    local oldUnbound = unboundMasterySelected
    local oldErudite = eruditeMasterySelected

    inkMasterySelected = false
    abyssalMasterySelected = false
    fateMasterySelected = false
    unboundMasterySelected = false
    eruditeMasterySelected = false

    local numLines =
        GetNumSkillLines(SKILL_TYPE_CLASS)

    for skillLineIndex = 1, numLines do

        local numAbilities =
            GetNumSkillAbilities(
                SKILL_TYPE_CLASS,
                skillLineIndex
            )

        for abilityIndex = 1, numAbilities do

            local abilityId =
                GetSkillAbilityId(
                    SKILL_TYPE_CLASS,
                    skillLineIndex,
                    abilityIndex,
                    false
                )

            if abilityId == ABYSSAL_MASTERY_SKILL_ID
                or abilityId == FATE_MASTERY_SKILL_ID
                or abilityId == UNBOUND_MASTERY_SKILL_ID
                or abilityId == ERUDITE_MASTERY_SKILL_ID
                or abilityId == INK_MASTERY_SKILL_ID then

                local
                    abilityName,
                    texture,
                    earnedRank,
                    passive,
                    ultimate,
                    purchased =
                        GetSkillAbilityInfo(
                            SKILL_TYPE_CLASS,
                            skillLineIndex,
                            abilityIndex
                        )

                if purchased then

                    if abilityId == INK_MASTERY_SKILL_ID then
                        inkMasterySelected = true

                    elseif abilityId == ABYSSAL_MASTERY_SKILL_ID then
                        abyssalMasterySelected = true

                    elseif abilityId == FATE_MASTERY_SKILL_ID then
                        fateMasterySelected = true

                    elseif abilityId == UNBOUND_MASTERY_SKILL_ID then
                        unboundMasterySelected = true

                    elseif abilityId == ERUDITE_MASTERY_SKILL_ID then
                        eruditeMasterySelected = true
                    end
                end
            end
        end
    end

    -- If a mastery was removed/respecced, immediately clear its old state.
    if oldInk and not inkMasterySelected then
        runningTotal = 0
        majorForceActive = false
        majorForceEndTime = 0
    end

    if oldAbyssal and not abyssalMasterySelected then
        abyssalActive = false
        abyssalEndTime = 0
    end

    if oldFate and not fateMasterySelected then
        fateActive = false
        fateEndTime = 0
    end

    if oldUnbound and not unboundMasterySelected then
        unboundActive = false
        unboundEndTime = 0
    end

    if oldErudite and not eruditeMasterySelected then
        eruditeActive = false
        eruditeEndTime = 0
        armorActive = false
        armorEndTime = 0
    end

    UpdateInkDisplay()
    UpdateAbyssalDisplay()
    UpdateFateDisplay()
    UpdateUnboundDisplay()
    UpdateEruditeDisplay()
end

-- =========================================================
-- COMBAT EVENTS
-- =========================================================

local function OnCombatEvent(
    eventCode,
    result,
    isError,
    abilityName,
    abilityGraphic,
    abilityActionSlotType,
    sourceName,
    sourceType,
    targetName,
    targetType,
    hitValue,
    powerType,
    damageType,
    log,
    sourceUnitId,
    targetUnitId,
    abilityId,
    overflow
)

    if not inCombat then
        return
    end

    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    -- Ink-Scribe healing + overhealing
    if not inkMasterySelected then
        return
    end

    if result == ACTION_RESULT_HEAL
        or result == ACTION_RESULT_CRITICAL_HEAL
        or result == ACTION_RESULT_HOT_TICK
        or result == ACTION_RESULT_HOT_TICK_CRITICAL then

        local heal =
            tonumber(hitValue) or 0

        local over =
            tonumber(overflow) or 0

        local raw =
            heal + over

        if raw > 0 then

            runningTotal =
                runningTotal + raw

            UpdateInkDisplay()
        end
    end
end

-- =========================================================
-- EFFECT EVENTS
-- =========================================================

local function OnEffectChanged(
    eventCode,
    changeType,
    effectSlot,
    effectName,
    unitTag,
    beginTime,
    endTime,
    stackCount,
    iconName,
    buffType,
    effectType,
    abilityType,
    statusEffectType,
    unitName,
    unitId,
    abilityId,
    sourceType
)

    if unitTag ~= "player" then
        return
    end

    -- =====================================================
    -- GIBBERING SHIELD / MORPHS
    -- =====================================================

    if abilityId == GIBBERING_SHIELD_ID
        or abilityId == GIBBERING_SHELTER_ID
        or abilityId == SANCTUM_ABYSSAL_SEA_ID then

        if changeType == EFFECT_RESULT_GAINED
            or changeType == EFFECT_RESULT_UPDATED then
            gibberActive = true
            gibberEndTime = endTime
        elseif changeType == EFFECT_RESULT_FADED then
            gibberActive = false
            gibberEndTime = 0
        end
        UpdateGibberDisplay()
        return
    end

    -- =====================================================
    -- INK-SCRIBE / MAJOR FORCE
    -- =====================================================

    if abilityId == MAJOR_FORCE_ID then

        if not inkMasterySelected then
            return
        end

        if changeType == EFFECT_RESULT_GAINED then

            majorForceActive = true
            majorForceEndTime = endTime

            ResetInkProgress()

        elseif changeType == EFFECT_RESULT_UPDATED then

            majorForceActive = true
            majorForceEndTime = endTime

        elseif changeType == EFFECT_RESULT_FADED then

            majorForceActive = false
            inkForceLabel:SetHidden(true)

        end

        UpdateInkDisplay()

        return
    end

    -- =====================================================
    -- ABYSSAL EMERGENCE
    -- =====================================================

    if abilityId == ABYSSAL_EMERGENCE_ID then

        if not abyssalMasterySelected then
            return
        end

        if changeType == EFFECT_RESULT_GAINED
            or changeType == EFFECT_RESULT_UPDATED then

            abyssalActive = true
            abyssalEndTime = endTime

        elseif changeType == EFFECT_RESULT_FADED then

            abyssalActive = false
            abyssalEndTime = 0

        end

        UpdateAbyssalDisplay()

        return
    end

    -- =====================================================
    -- CRUX
    -- =====================================================

    if abilityId == CRUX_ID then

        if changeType == EFFECT_RESULT_GAINED
            or changeType == EFFECT_RESULT_UPDATED then

            currentCrux =
                stackCount or 0

        elseif changeType == EFFECT_RESULT_FADED then

            currentCrux = 0

        end

        UpdateCruxDisplay()

        return
    end

    -- =====================================================
    -- FATE REALIGNED
    -- =====================================================

    if abilityId == FATE_REALIGNED_BUFF_ID then

        if not fateMasterySelected then
            return
        end

        if changeType == EFFECT_RESULT_GAINED
            or changeType == EFFECT_RESULT_UPDATED then

            fateActive = true
            fateEndTime = endTime

        elseif changeType == EFFECT_RESULT_FADED then

            fateActive = false
            fateEndTime = 0

        end

        UpdateFateDisplay()

        return
    end

    -- =====================================================
    -- UNBOUND POTENTIAL / FATED FORTUNE
    -- =====================================================

    if abilityId == FATED_FORTUNE_EFFECT_ID then

        if not unboundMasterySelected then
            return
        end

        if changeType == EFFECT_RESULT_GAINED
            or changeType == EFFECT_RESULT_UPDATED then

            unboundActive = true
            unboundEndTime = endTime

        elseif changeType == EFFECT_RESULT_FADED then

            unboundActive = false
            unboundEndTime = 0

        end

        UpdateUnboundDisplay()

        return
    end

    -- =====================================================
    -- ERUDITE'S RIGOR / FATEWOVEN ARMOR + MORPHS
    -- =====================================================

    if abilityId == FATEWOVEN_ARMOR_ID
        or abilityId == CRUXWEAVER_ARMOR_ID
        or abilityId == UNBREAKABLE_FATE_ID then

        if not eruditeMasterySelected then
            return
        end

        if changeType == EFFECT_RESULT_GAINED
            or changeType == EFFECT_RESULT_UPDATED then

            armorActive = true
            armorEndTime = endTime

        elseif changeType == EFFECT_RESULT_FADED then

            armorActive = false
            armorEndTime = 0

        end

        UpdateEruditeDisplay()

        return
    end

    -- =====================================================
    -- ERUDITE'S RIGOR / MAJOR VITALITY
    -- =====================================================

    if abilityId == MAJOR_VITALITY_ID then

        if not eruditeMasterySelected then
            return
        end

        if changeType == EFFECT_RESULT_GAINED
            or changeType == EFFECT_RESULT_UPDATED then

            eruditeActive = true
            eruditeEndTime = endTime

        elseif changeType == EFFECT_RESULT_FADED then

            eruditeActive = false
            eruditeEndTime = 0

        end

        UpdateEruditeDisplay()

        return
    end
end

-- =========================================================
-- SCAN CURRENT CRUX
-- =========================================================

local function ScanCurrentCrux()

    currentCrux = 0

    for i = 1, GetNumBuffs("player") do

        local
            buffName,
            startTime,
            endTime,
            buffSlot,
            stackCount,
            iconFilename,
            buffType,
            effectType,
            abilityType,
            statusEffectType,
            abilityId =
                GetUnitBuffInfo(
                    "player",
                    i
                )

        if abilityId == CRUX_ID then

            currentCrux =
                stackCount or 0

            break
        end
    end

    UpdateCruxDisplay()
end

local function ScanCurrentArmor()

    armorActive = false
    armorEndTime = 0

    if not eruditeMasterySelected then
        UpdateEruditeDisplay()
        return
    end

    for i = 1, GetNumBuffs("player") do

        local
            buffName,
            startTime,
            endTime,
            buffSlot,
            stackCount,
            iconFilename,
            buffType,
            effectType,
            abilityType,
            statusEffectType,
            abilityId =
                GetUnitBuffInfo(
                    "player",
                    i
                )

        if abilityId == FATEWOVEN_ARMOR_ID
            or abilityId == CRUXWEAVER_ARMOR_ID
            or abilityId == UNBREAKABLE_FATE_ID then

            armorActive = true
            armorEndTime = endTime
            break
        end
    end

    UpdateEruditeDisplay()
end

-- =========================================================
-- COMBAT STATE
-- =========================================================

local function OnCombatState(
    eventCode,
    state
)

    inCombat = state

    if inCombat then

        runningTotal = 0

        majorForceActive = false
        majorForceEndTime = 0

        abyssalActive = false
        abyssalEndTime = 0

        fateActive = false
        fateEndTime = 0

        unboundActive = false
        unboundEndTime = 0

        eruditeActive = false
        eruditeEndTime = 0

        armorActive = false
        armorEndTime = 0

        ScanCurrentCrux()
        ScanCurrentArmor()

    else

        runningTotal = 0

        majorForceActive = false
        majorForceEndTime = 0

        abyssalActive = false
        abyssalEndTime = 0

        fateActive = false
        fateEndTime = 0

        unboundActive = false
        unboundEndTime = 0

        eruditeActive = false
        eruditeEndTime = 0

        armorActive = false
        armorEndTime = 0

        ScanCurrentCrux()
    end

    UpdateInkDisplay()
    UpdateAbyssalDisplay()
    UpdateCruxDisplay()
    UpdateFateDisplay()
    UpdateUnboundDisplay()
    UpdateEruditeDisplay()
    UpdateGibberDisplay()
    UpdateBlockDisplay()
end

-- =========================================================
-- PLAYER ACTIVATED
-- =========================================================

local function OnPlayerActivated()

    inCombat =
        IsUnitInCombat("player")

    RefreshMasterySelections()
    ScanCurrentCrux()
    ScanCurrentArmor()

    UpdateInkDisplay()
    UpdateAbyssalDisplay()
    UpdateCruxDisplay()
    UpdateFateDisplay()
    UpdateUnboundDisplay()
    UpdateEruditeDisplay()
    UpdateGibberDisplay()
    UpdateBlockDisplay()
end

-- =========================================================
-- CREATE INK UI
-- =========================================================

local function CreateInkUI()

    inkFrame =
        WINDOW_MANAGER:CreateTopLevelWindow(
            ADDON_NAME .. "InkFrame"
        )

    inkFrame:SetDimensions(
        420,
        150
    )

    inkFrame:SetClampedToScreen(true)

    inkFrame:SetHandler(
        "OnMoveStop",
        function()
            SaveInkPosition()
        end
    )

    inkTitleLabel =
        WINDOW_MANAGER:CreateControl(
            ADDON_NAME .. "InkTitle",
            inkFrame,
            CT_LABEL
        )

    inkTitleLabel:SetAnchor(
        TOP,
        inkFrame,
        TOP,
        0,
        0
    )

    inkTitleLabel:SetText(
        "INK-SCRIBE'S VERVE"
    )

    inkTitleLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    inkProgressLabel =
        WINDOW_MANAGER:CreateControl(
            ADDON_NAME .. "InkProgress",
            inkFrame,
            CT_LABEL
        )

    inkProgressLabel:SetAnchor(
        TOP,
        inkTitleLabel,
        BOTTOM,
        0,
        6
    )

    inkProgressLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    inkForceLabel =
        WINDOW_MANAGER:CreateControl(
            ADDON_NAME .. "InkForce",
            inkFrame,
            CT_LABEL
        )

    inkForceLabel:SetAnchor(
        TOP,
        inkProgressLabel,
        BOTTOM,
        0,
        6
    )

    inkForceLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    inkForceLabel:SetHidden(true)

    UpdateInkPosition()

    SetInkUnlocked(
        savedVars.inkUnlocked
    )
end

-- =========================================================
-- CREATE ABYSSAL UI
-- =========================================================

local function CreateAbyssalUI()

    abyssalFrame =
        WINDOW_MANAGER:CreateTopLevelWindow(
            ADDON_NAME .. "AbyssalFrame"
        )

    abyssalFrame:SetDimensions(
        420,
        110
    )

    abyssalFrame:SetClampedToScreen(true)

    abyssalFrame:SetHandler(
        "OnMoveStop",
        function()
            SaveAbyssalPosition()
        end
    )

    abyssalTitleLabel =
        WINDOW_MANAGER:CreateControl(
            ADDON_NAME .. "AbyssalTitle",
            abyssalFrame,
            CT_LABEL
        )

    abyssalTitleLabel:SetAnchor(
        TOP,
        abyssalFrame,
        TOP,
        0,
        0
    )

    abyssalTitleLabel:SetText(
        "ABYSSAL EMERGENCE"
    )

    abyssalTitleLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    abyssalTimerLabel =
        WINDOW_MANAGER:CreateControl(
            ADDON_NAME .. "AbyssalTimer",
            abyssalFrame,
            CT_LABEL
        )

    abyssalTimerLabel:SetAnchor(
        TOP,
        abyssalTitleLabel,
        BOTTOM,
        0,
        6
    )

    abyssalTimerLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    UpdateAbyssalPosition()

    SetAbyssalUnlocked(
        savedVars.abyssalUnlocked
    )
end

-- =========================================================
-- CREATE CRUX UI
-- =========================================================

local function CreateCruxUI()

    cruxFrame =
        WINDOW_MANAGER:CreateTopLevelWindow(
            ADDON_NAME .. "CruxFrame"
        )

    cruxFrame:SetClampedToScreen(true)

    cruxFrame:SetHandler(
        "OnMoveStop",
        function()
            SaveCruxPosition()
        end
    )

    cruxTexture =
        WINDOW_MANAGER:CreateControl(
            ADDON_NAME .. "CruxTexture",
            cruxFrame,
            CT_TEXTURE
        )

    cruxTexture:SetAnchor(
        CENTER,
        cruxFrame,
        CENTER,
        0,
        0
    )

    cruxTexture:SetTexture(
        "/art/fx/texture/arcanist_tank4_runicglowlines.dds"
    )

    cruxTexture:SetTextureCoords(
        0,
        1,
        0,
        1
    )

    cruxTexture:SetAlpha(0.95)

    cruxNumberLabel =
        WINDOW_MANAGER:CreateControl(
            ADDON_NAME .. "CruxNumber",
            cruxFrame,
            CT_LABEL
        )

    cruxNumberLabel:SetAnchor(
        CENTER,
        cruxFrame,
        CENTER,
        0,
        0
    )

    cruxNumberLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    cruxNumberLabel:SetVerticalAlignment(
        TEXT_ALIGN_CENTER
    )

    cruxNumberLabel:SetText(
        "0"
    )

    UpdateCruxSize()
    UpdateCruxPosition()

    SetCruxUnlocked(
        savedVars.cruxUnlocked
    )
end

-- =========================================================
-- CREATE FATE UI
-- =========================================================

local function CreateFateUI()

    fateFrame =
        WINDOW_MANAGER:CreateTopLevelWindow(
            ADDON_NAME .. "FateFrame"
        )

    fateFrame:SetDimensions(
        420,
        110
    )

    fateFrame:SetClampedToScreen(true)

    fateFrame:SetHandler(
        "OnMoveStop",
        function()
            SaveFatePosition()
        end
    )

    fateTitleLabel =
        WINDOW_MANAGER:CreateControl(
            ADDON_NAME .. "FateTitle",
            fateFrame,
            CT_LABEL
        )

    fateTitleLabel:SetAnchor(
        TOP,
        fateFrame,
        TOP,
        0,
        0
    )

    fateTitleLabel:SetText(
        "FATE REALIGNED"
    )

    fateTitleLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    fateTimerLabel =
        WINDOW_MANAGER:CreateControl(
            ADDON_NAME .. "FateTimer",
            fateFrame,
            CT_LABEL
        )

    fateTimerLabel:SetAnchor(
        TOP,
        fateTitleLabel,
        BOTTOM,
        0,
        6
    )

    fateTimerLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    UpdateFatePosition()

    SetFateUnlocked(
        savedVars.fateUnlocked
    )
end

-- =========================================================
-- CREATE UNBOUND UI
-- =========================================================

local function CreateUnboundUI()

    unboundFrame =
        WINDOW_MANAGER:CreateTopLevelWindow(
            ADDON_NAME .. "UnboundFrame"
        )

    unboundFrame:SetDimensions(
        420,
        110
    )

    unboundFrame:SetClampedToScreen(true)

    unboundFrame:SetHandler(
        "OnMoveStop",
        function()
            SaveUnboundPosition()
        end
    )

    unboundTitleLabel =
        WINDOW_MANAGER:CreateControl(
            ADDON_NAME .. "UnboundTitle",
            unboundFrame,
            CT_LABEL
        )

    unboundTitleLabel:SetAnchor(
        TOP,
        unboundFrame,
        TOP,
        0,
        0
    )

    unboundTitleLabel:SetText(
        "UNBOUND POTENTIAL"
    )

    unboundTitleLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    unboundTimerLabel =
        WINDOW_MANAGER:CreateControl(
            ADDON_NAME .. "UnboundTimer",
            unboundFrame,
            CT_LABEL
        )

    unboundTimerLabel:SetAnchor(
        TOP,
        unboundTitleLabel,
        BOTTOM,
        0,
        6
    )

    unboundTimerLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    UpdateUnboundPosition()

    SetUnboundUnlocked(
        savedVars.unboundUnlocked
    )
end

-- =========================================================
-- CREATE ERUDITE UI
-- =========================================================

local function CreateEruditeUI()

    eruditeFrame =
        WINDOW_MANAGER:CreateTopLevelWindow(
            ADDON_NAME .. "EruditeFrame"
        )

    eruditeFrame:SetDimensions(
        420,
        150
    )

    eruditeFrame:SetClampedToScreen(true)

    eruditeFrame:SetHandler(
        "OnMoveStop",
        function()
            SaveEruditePosition()
        end
    )

    eruditeTitleLabel =
        WINDOW_MANAGER:CreateControl(
            ADDON_NAME .. "EruditeTitle",
            eruditeFrame,
            CT_LABEL
        )

    eruditeTitleLabel:SetAnchor(
        TOP,
        eruditeFrame,
        TOP,
        0,
        0
    )

    eruditeTitleLabel:SetText(
        "ERUDITE'S RIGOR"
    )

    eruditeTitleLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    eruditeArmorLabel =
        WINDOW_MANAGER:CreateControl(
            ADDON_NAME .. "EruditeArmor",
            eruditeFrame,
            CT_LABEL
        )

    eruditeArmorLabel:SetAnchor(
        TOP,
        eruditeTitleLabel,
        BOTTOM,
        0,
        6
    )

    eruditeArmorLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    eruditeTimerLabel =
        WINDOW_MANAGER:CreateControl(
            ADDON_NAME .. "EruditeTimer",
            eruditeFrame,
            CT_LABEL
        )

    eruditeTimerLabel:SetAnchor(
        TOP,
        eruditeArmorLabel,
        BOTTOM,
        0,
        6
    )

    eruditeTimerLabel:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    UpdateEruditePosition()

    SetEruditeUnlocked(
        savedVars.eruditeUnlocked
    )
end

-- =========================================================
-- CREATE ARCANIST UTILITY UI
-- =========================================================

local function CreateGibberUI()
    gibberFrame = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "GibberFrame")
    gibberFrame:SetDimensions(420, 125)
    gibberFrame:SetClampedToScreen(true)
    gibberFrame:SetHandler("OnMoveStop", function() SaveCenteredPosition(gibberFrame, "gibberX", "gibberY") end)
    gibberTitleLabel = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "GibberTitle", gibberFrame, CT_LABEL)
    gibberTitleLabel:SetAnchor(TOP, gibberFrame, TOP, 0, 0)
    gibberTitleLabel:SetText("GIBBERING SHIELD")
    gibberTitleLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    gibberBar = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "GibberBar", gibberFrame, CT_STATUSBAR)
    gibberBar:SetDimensions(300, 18)
    gibberBar:SetAnchor(TOP, gibberTitleLabel, BOTTOM, 0, 8)
    gibberBar:SetMinMax(0, 10)
    gibberBar:SetValue(10)
    gibberTimerLabel = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "GibberTimer", gibberFrame, CT_LABEL)
    gibberTimerLabel:SetAnchor(TOP, gibberBar, BOTTOM, 0, 5)
    gibberTimerLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    PositionUtilityFrame(gibberFrame, savedVars.gibberX, savedVars.gibberY)
    SetUtilityUnlocked(gibberFrame, savedVars.gibberUnlocked)
end

local function CreateBlockUI()
    blockFrame = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "BlockFrame")
    blockFrame:SetDimensions(420, 105)
    blockFrame:SetClampedToScreen(true)
    blockFrame:SetHandler("OnMoveStop", function() SaveCenteredPosition(blockFrame, "blockX", "blockY") end)
    blockTitleLabel = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "BlockTitle", blockFrame, CT_LABEL)
    blockTitleLabel:SetAnchor(TOP, blockFrame, TOP, 0, 0)
    blockTitleLabel:SetText("BLOCK MITIGATION")
    blockTitleLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    blockValueLabel = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "BlockValue", blockFrame, CT_LABEL)
    blockValueLabel:SetAnchor(TOP, blockTitleLabel, BOTTOM, 0, 6)
    blockValueLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    PositionUtilityFrame(blockFrame, savedVars.blockX, savedVars.blockY)
    SetUtilityUnlocked(blockFrame, savedVars.blockUnlocked)
end

-- =========================================================
-- SETTINGS
-- =========================================================

local function CreateSettings()

    local LAM =
        LibAddonMenu2

    panel =
        LAM:RegisterAddonPanel(
            ADDON_NAME .. "Options",
            {
                type = "panel",
                name = DISPLAY_NAME,
                displayName = DISPLAY_NAME,
                author = "WifeyRytic",
                version = "1.3",
                registerForRefresh = true,
                registerForDefaults = true,
            }
        )

    local options = {

        -- =================================================
        -- INK-SCRIBE
        -- =================================================

        {
            type = "header",
            name = "Ink-Scribe's Verve",
        },

        {
            type = "checkbox",
            name = "Enable Ink-Scribe's Verve",

            getFunc = function()
                return savedVars.inkEnabled
            end,

            setFunc = function(value)

                savedVars.inkEnabled =
                    value

                UpdateInkVisibility()
            end,

            default =
                defaults.inkEnabled,
        },

        {
            type = "checkbox",
            name = "Show Ink-Scribe Title",

            getFunc = function()
                return savedVars.showInkTitle
            end,

            setFunc = function(value)

                savedVars.showInkTitle =
                    value

                UpdateInkDisplay()
            end,

            default =
                defaults.showInkTitle,
        },

        {
            type = "slider",
            name = "Ink-Scribe Text Size",
            min = 20,
            max = 80,
            step = 1,

            getFunc = function()
                return savedVars.inkFontSize
            end,

            setFunc = function(value)

                savedVars.inkFontSize =
                    value

                UpdateFonts()
            end,

            default =
                defaults.inkFontSize,
        },

        {
            type = "slider",
            name = "Major Force Text Size",
            min = 20,
            max = 80,
            step = 1,

            getFunc = function()
                return savedVars.forceFontSize
            end,

            setFunc = function(value)

                savedVars.forceFontSize =
                    value

                UpdateFonts()
            end,

            default =
                defaults.forceFontSize,
        },

        {
            type = "colorpicker",
            name = "Ink-Scribe Progress Color",

            getFunc = function()

                local c =
                    savedVars.inkProgressColor

                return
                    c.r,
                    c.g,
                    c.b,
                    c.a
            end,

            setFunc = function(r, g, b, a)

                savedVars.inkProgressColor = {
                    r = r,
                    g = g,
                    b = b,
                    a = a,
                }

                UpdateColors()
            end,

            default =
                defaults.inkProgressColor,
        },

        {
            type = "colorpicker",
            name = "Major Force Color",

            getFunc = function()

                local c =
                    savedVars.forceColor

                return
                    c.r,
                    c.g,
                    c.b,
                    c.a
            end,

            setFunc = function(r, g, b, a)

                savedVars.forceColor = {
                    r = r,
                    g = g,
                    b = b,
                    a = a,
                }

                UpdateColors()
            end,

            default =
                defaults.forceColor,
        },

        {
            type = "button",
            name = "Unlock Ink-Scribe",

            func = function()

                SetInkUnlocked(true)

                UpdateInkVisibility()
            end,
        },

        {
            type = "button",
            name = "Lock Ink-Scribe",

            func = function()

                SetInkUnlocked(false)

                UpdateInkVisibility()
            end,
        },

        {
            type = "button",
            name = "Reset Ink-Scribe Position",

            func = function()

                savedVars.inkX =
                    defaults.inkX

                savedVars.inkY =
                    defaults.inkY

                UpdateInkPosition()
            end,
        },

        {
            type = "button",
            name = "Test Ink Progress",

            func = function()

                runningTotal = 89000

                inkFrame:SetHidden(false)

                UpdateInkDisplay()
            end,
        },

        {
            type = "button",
            name = "Test Major Force",

            func = function()

                majorForceActive = true

                majorForceEndTime =
                    GetFrameTimeSeconds() + 10

                inkFrame:SetHidden(false)

                UpdateInkDisplay()
            end,
        },

        -- =================================================
        -- ABYSSAL
        -- =================================================

        {
            type = "header",
            name = "Abyssal Emergence",
        },

        {
            type = "checkbox",
            name = "Enable Abyssal Emergence",

            getFunc = function()
                return savedVars.abyssalEnabled
            end,

            setFunc = function(value)

                savedVars.abyssalEnabled =
                    value

                UpdateAbyssalVisibility()
            end,

            default =
                defaults.abyssalEnabled,
        },

        {
            type = "checkbox",
            name = "Show Abyssal Title",

            getFunc = function()
                return savedVars.showAbyssalTitle
            end,

            setFunc = function(value)

                savedVars.showAbyssalTitle =
                    value

                UpdateAbyssalDisplay()
            end,

            default =
                defaults.showAbyssalTitle,
        },

        {
            type = "slider",
            name = "Abyssal Text Size",
            min = 20,
            max = 80,
            step = 1,

            getFunc = function()
                return savedVars.abyssalFontSize
            end,

            setFunc = function(value)

                savedVars.abyssalFontSize =
                    value

                UpdateFonts()
            end,

            default =
                defaults.abyssalFontSize,
        },

        {
            type = "colorpicker",
            name = "Abyssal Timer Color",

            getFunc = function()

                local c =
                    savedVars.abyssalColor

                return
                    c.r,
                    c.g,
                    c.b,
                    c.a
            end,

            setFunc = function(r, g, b, a)

                savedVars.abyssalColor = {
                    r = r,
                    g = g,
                    b = b,
                    a = a,
                }

                UpdateColors()
            end,

            default =
                defaults.abyssalColor,
        },

        {
            type = "button",
            name = "Unlock Abyssal",

            func = function()

                SetAbyssalUnlocked(true)

                UpdateAbyssalVisibility()
            end,
        },

        {
            type = "button",
            name = "Lock Abyssal",

            func = function()

                SetAbyssalUnlocked(false)

                UpdateAbyssalVisibility()
            end,
        },

        {
            type = "button",
            name = "Reset Abyssal Position",

            func = function()

                savedVars.abyssalX =
                    defaults.abyssalX

                savedVars.abyssalY =
                    defaults.abyssalY

                UpdateAbyssalPosition()
            end,
        },

        {
            type = "button",
            name = "Test Abyssal Emergence",

            func = function()

                abyssalActive = true

                abyssalEndTime =
                    GetFrameTimeSeconds() + 15

                abyssalFrame:SetHidden(false)

                UpdateAbyssalDisplay()
            end,
        },

        -- =================================================
        -- FATE REALIGNED
        -- =================================================

        {
            type = "header",
            name = "Fate Realigned",
        },

        {
            type = "checkbox",
            name = "Enable Fate Realigned",

            getFunc = function()
                return savedVars.fateEnabled
            end,

            setFunc = function(value)

                savedVars.fateEnabled =
                    value

                UpdateFateVisibility()
            end,

            default =
                defaults.fateEnabled,
        },

        {
            type = "checkbox",
            name = "Show Fate Realigned Title",

            getFunc = function()
                return savedVars.showFateTitle
            end,

            setFunc = function(value)

                savedVars.showFateTitle =
                    value

                UpdateFateDisplay()
            end,

            default =
                defaults.showFateTitle,
        },

        {
            type = "slider",
            name = "Fate Realigned Text Size",
            min = 20,
            max = 80,
            step = 1,

            getFunc = function()
                return savedVars.fateFontSize
            end,

            setFunc = function(value)

                savedVars.fateFontSize =
                    value

                UpdateFonts()
            end,

            default =
                defaults.fateFontSize,
        },

        {
            type = "colorpicker",
            name = "Fate Realigned Timer Color",

            getFunc = function()

                local c =
                    savedVars.fateColor

                return
                    c.r,
                    c.g,
                    c.b,
                    c.a
            end,

            setFunc = function(r, g, b, a)

                savedVars.fateColor = {
                    r = r,
                    g = g,
                    b = b,
                    a = a,
                }

                UpdateColors()
            end,

            default =
                defaults.fateColor,
        },

        {
            type = "button",
            name = "Unlock Fate Realigned",

            func = function()

                SetFateUnlocked(true)

                UpdateFateVisibility()
            end,
        },

        {
            type = "button",
            name = "Lock Fate Realigned",

            func = function()

                SetFateUnlocked(false)

                UpdateFateVisibility()
            end,
        },

        {
            type = "button",
            name = "Reset Fate Realigned Position",

            func = function()

                savedVars.fateX =
                    defaults.fateX

                savedVars.fateY =
                    defaults.fateY

                UpdateFatePosition()
            end,
        },

        {
            type = "button",
            name = "Test Fate Realigned",

            func = function()

                fateActive = true

                fateEndTime =
                    GetFrameTimeSeconds() + 25

                fateFrame:SetHidden(false)

                UpdateFateDisplay()
            end,
        },

        -- =================================================
        -- UNBOUND POTENTIAL
        -- =================================================

        {
            type = "header",
            name = "Unbound Potential",
        },

        {
            type = "checkbox",
            name = "Enable Unbound Potential",

            getFunc = function()
                return savedVars.unboundEnabled
            end,

            setFunc = function(value)

                savedVars.unboundEnabled =
                    value

                UpdateUnboundVisibility()
            end,

            default =
                defaults.unboundEnabled,
        },

        {
            type = "checkbox",
            name = "Show Unbound Potential Title",

            getFunc = function()
                return savedVars.showUnboundTitle
            end,

            setFunc = function(value)

                savedVars.showUnboundTitle =
                    value

                UpdateUnboundDisplay()
            end,

            default =
                defaults.showUnboundTitle,
        },

        {
            type = "slider",
            name = "Unbound Potential Text Size",
            min = 20,
            max = 80,
            step = 1,

            getFunc = function()
                return savedVars.unboundFontSize
            end,

            setFunc = function(value)

                savedVars.unboundFontSize =
                    value

                UpdateFonts()
            end,

            default =
                defaults.unboundFontSize,
        },

        {
            type = "colorpicker",
            name = "Unbound Potential Timer Color",

            getFunc = function()

                local c =
                    savedVars.unboundColor

                return
                    c.r,
                    c.g,
                    c.b,
                    c.a
            end,

            setFunc = function(r, g, b, a)

                savedVars.unboundColor = {
                    r = r,
                    g = g,
                    b = b,
                    a = a,
                }

                UpdateColors()
            end,

            default =
                defaults.unboundColor,
        },

        {
            type = "button",
            name = "Unlock Unbound Potential",

            func = function()

                SetUnboundUnlocked(true)

                UpdateUnboundVisibility()
            end,
        },

        {
            type = "button",
            name = "Lock Unbound Potential",

            func = function()

                SetUnboundUnlocked(false)

                UpdateUnboundVisibility()
            end,
        },

        {
            type = "button",
            name = "Reset Unbound Potential Position",

            func = function()

                savedVars.unboundX =
                    defaults.unboundX

                savedVars.unboundY =
                    defaults.unboundY

                UpdateUnboundPosition()
            end,
        },

        {
            type = "button",
            name = "Test Unbound Potential",

            func = function()

                unboundActive = true

                unboundEndTime =
                    GetFrameTimeSeconds() + 7

                unboundFrame:SetHidden(false)

                UpdateUnboundDisplay()
            end,
        },

        -- =================================================
        -- ERUDITE'S RIGOR
        -- =================================================

        {
            type = "header",
            name = "Erudite's Rigor",
        },

        {
            type = "checkbox",
            name = "Enable Erudite's Rigor",

            getFunc = function()
                return savedVars.eruditeEnabled
            end,

            setFunc = function(value)

                savedVars.eruditeEnabled =
                    value

                UpdateEruditeVisibility()
            end,

            default =
                defaults.eruditeEnabled,
        },

        {
            type = "checkbox",
            name = "Show Erudite's Rigor Title",

            getFunc = function()
                return savedVars.showEruditeTitle
            end,

            setFunc = function(value)

                savedVars.showEruditeTitle =
                    value

                UpdateEruditeDisplay()
            end,

            default =
                defaults.showEruditeTitle,
        },

        {
            type = "slider",
            name = "Erudite's Rigor Text Size",
            min = 20,
            max = 80,
            step = 1,

            getFunc = function()
                return savedVars.eruditeFontSize
            end,

            setFunc = function(value)

                savedVars.eruditeFontSize =
                    value

                UpdateFonts()
            end,

            default =
                defaults.eruditeFontSize,
        },

        {
            type = "colorpicker",
            name = "Erudite's Rigor Timer Color",

            getFunc = function()

                local c =
                    savedVars.eruditeColor

                return
                    c.r,
                    c.g,
                    c.b,
                    c.a
            end,

            setFunc = function(r, g, b, a)

                savedVars.eruditeColor = {
                    r = r,
                    g = g,
                    b = b,
                    a = a,
                }

                UpdateColors()
            end,

            default =
                defaults.eruditeColor,
        },

        {
            type = "button",
            name = "Unlock Erudite's Rigor",

            func = function()

                SetEruditeUnlocked(true)

                UpdateEruditeVisibility()
            end,
        },

        {
            type = "button",
            name = "Lock Erudite's Rigor",

            func = function()

                SetEruditeUnlocked(false)

                UpdateEruditeVisibility()
            end,
        },

        {
            type = "button",
            name = "Reset Erudite's Rigor Position",

            func = function()

                savedVars.eruditeX =
                    defaults.eruditeX

                savedVars.eruditeY =
                    defaults.eruditeY

                UpdateEruditePosition()
            end,
        },

        {
            type = "button",
            name = "Test Erudite's Rigor",

            func = function()

                armorActive = true
                armorEndTime =
                    GetFrameTimeSeconds() + 20

                eruditeActive = true
                eruditeEndTime =
                    GetFrameTimeSeconds() + 4

                eruditeFrame:SetHidden(false)

                UpdateEruditeDisplay()
            end,
        },

        -- =================================================
        -- CRUX COUNTER
        -- =================================================

        {
            type = "header",
            name = "Crux Counter",
        },

        {
            type = "checkbox",
            name = "Enable Crux Counter",

            tooltip =
                "Shows your current Crux from 0 to 3. This works independently of any Class Mastery.",

            getFunc = function()
                return savedVars.cruxEnabled
            end,

            setFunc = function(value)

                savedVars.cruxEnabled =
                    value

                UpdateCruxVisibility()
            end,

            default =
                defaults.cruxEnabled,
        },

        {
            type = "checkbox",
            name = "Hide Crux Counter Out of Combat",

            getFunc = function()
                return savedVars.cruxHideOutOfCombat
            end,

            setFunc = function(value)

                savedVars.cruxHideOutOfCombat =
                    value

                UpdateCruxVisibility()
            end,

            default =
                defaults.cruxHideOutOfCombat,
        },

        {
            type = "slider",
            name = "Crux Counter Size",
            min = 60,
            max = 200,
            step = 5,

            getFunc = function()
                return savedVars.cruxSize
            end,

            setFunc = function(value)

                savedVars.cruxSize =
                    value

                UpdateCruxSize()
            end,

            default =
                defaults.cruxSize,
        },

        {
            type = "slider",
            name = "Crux Number Size",
            min = 20,
            max = 80,
            step = 1,

            getFunc = function()
                return savedVars.cruxTextSize
            end,

            setFunc = function(value)

                savedVars.cruxTextSize =
                    value

                UpdateFonts()
            end,

            default =
                defaults.cruxTextSize,
        },

        {
            type = "colorpicker",
            name = "Crux Number Color",

            getFunc = function()

                local c =
                    savedVars.cruxTextColor

                return
                    c.r,
                    c.g,
                    c.b,
                    c.a
            end,

            setFunc = function(r, g, b, a)

                savedVars.cruxTextColor = {
                    r = r,
                    g = g,
                    b = b,
                    a = a,
                }

                UpdateColors()
            end,

            default =
                defaults.cruxTextColor,
        },

        {
            type = "button",
            name = "Unlock Crux Counter",

            func = function()

                SetCruxUnlocked(true)

                UpdateCruxVisibility()
            end,
        },

        {
            type = "button",
            name = "Lock Crux Counter",

            func = function()

                SetCruxUnlocked(false)

                UpdateCruxVisibility()
            end,
        },

        {
            type = "button",
            name = "Reset Crux Position",

            func = function()

                savedVars.cruxX =
                    defaults.cruxX

                savedVars.cruxY =
                    defaults.cruxY

                UpdateCruxPosition()
            end,
        },

        {
            type = "button",
            name = "Test Crux 3",
            func = function()
                currentCrux = 3
                cruxFrame:SetHidden(false)
                UpdateCruxDisplay()
            end,
        },

        { type = "header", name = "Gibbering Shield" },
        { type = "checkbox", name = "Enable Gibbering Shield Tracker", getFunc = function() return savedVars.gibberEnabled end, setFunc = function(v) savedVars.gibberEnabled=v UpdateGibberDisplay() end, default = defaults.gibberEnabled },
        { type = "checkbox", name = "Show Gibbering Shield Title", getFunc = function() return savedVars.showGibberTitle end, setFunc = function(v) savedVars.showGibberTitle=v UpdateGibberDisplay() end, default = defaults.showGibberTitle },
        { type = "slider", name = "Gibbering Shield Text Size", min=20, max=80, step=1, getFunc=function() return savedVars.gibberFontSize end, setFunc=function(v) savedVars.gibberFontSize=v UpdateFonts() end, default=defaults.gibberFontSize },
        { type = "colorpicker", name = "Gibbering Shield Color", getFunc=function() local c=savedVars.gibberColor return c.r,c.g,c.b,c.a end, setFunc=function(r,g,b,a) savedVars.gibberColor={r=r,g=g,b=b,a=a} UpdateColors() end, default=function() local c=defaults.gibberColor return c.r,c.g,c.b,c.a end },
        { type = "checkbox", name = "Unlock Gibbering Shield Tracker", getFunc=function() return savedVars.gibberUnlocked end, setFunc=function(v) savedVars.gibberUnlocked=v SetUtilityUnlocked(gibberFrame,v) UpdateGibberDisplay() end, default=defaults.gibberUnlocked },
        { type = "button", name = "Reset Gibbering Shield Position", func=function() savedVars.gibberX=defaults.gibberX savedVars.gibberY=defaults.gibberY PositionUtilityFrame(gibberFrame,savedVars.gibberX,savedVars.gibberY) end },

        { type = "header", name = "Block Mitigation" },
        { type = "checkbox", name = "Enable Block Mitigation Tracker", getFunc=function() return savedVars.blockEnabled end, setFunc=function(v) savedVars.blockEnabled=v UpdateBlockDisplay() end, default=defaults.blockEnabled },
        { type = "checkbox", name = "Hide Block Mitigation Out of Combat", getFunc=function() return savedVars.blockHideOutOfCombat end, setFunc=function(v) savedVars.blockHideOutOfCombat=v UpdateBlockDisplay() end, default=defaults.blockHideOutOfCombat },
        { type = "slider", name = "Block Mitigation Text Size", min=20, max=80, step=1, getFunc=function() return savedVars.blockFontSize end, setFunc=function(v) savedVars.blockFontSize=v UpdateFonts() end, default=defaults.blockFontSize },
        { type = "colorpicker", name = "Block Mitigation Color", getFunc=function() local c=savedVars.blockColor return c.r,c.g,c.b,c.a end, setFunc=function(r,g,b,a) savedVars.blockColor={r=r,g=g,b=b,a=a} UpdateBlockDisplay() end, default=function() local c=defaults.blockColor return c.r,c.g,c.b,c.a end },
        { type = "colorpicker", name = "Block Cap Color", getFunc=function() local c=savedVars.blockCapColor return c.r,c.g,c.b,c.a end, setFunc=function(r,g,b,a) savedVars.blockCapColor={r=r,g=g,b=b,a=a} UpdateBlockDisplay() end, default=function() local c=defaults.blockCapColor return c.r,c.g,c.b,c.a end },
        { type = "checkbox", name = "Unlock Block Mitigation Tracker", getFunc=function() return savedVars.blockUnlocked end, setFunc=function(v) savedVars.blockUnlocked=v SetUtilityUnlocked(blockFrame,v) UpdateBlockDisplay() end, default=defaults.blockUnlocked },
        { type = "button", name = "Reset Block Mitigation Position", func=function() savedVars.blockX=defaults.blockX savedVars.blockY=defaults.blockY PositionUtilityFrame(blockFrame,savedVars.blockX,savedVars.blockY) end },

    }

    LAM:RegisterOptionControls(
        ADDON_NAME .. "Options",
        options
    )
end

-- =========================================================
-- UPDATE LOOP
-- =========================================================

local function OnUpdate()

    local now =
        GetFrameTimeSeconds()

    if now >= nextMasteryScanTime then

        nextMasteryScanTime =
            now + 1

        RefreshMasterySelections()
    end

    UpdateInkDisplay()
    UpdateAbyssalDisplay()
    UpdateFateDisplay()
    UpdateUnboundDisplay()
    UpdateEruditeDisplay()
    UpdateGibberDisplay()
    UpdateBlockDisplay()
end

-- =========================================================
-- LOAD
-- =========================================================

local function OnAddonLoaded(
    eventCode,
    addonName
)

    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        ADDON_NAME,
        EVENT_ADD_ON_LOADED
    )

    savedVars =
        ZO_SavedVars:NewAccountWide(
            "ArcanistMasteryTrackerSavedVariables",
            1,
            nil,
            defaults
        )

    inCombat =
        IsUnitInCombat("player")

    CreateInkUI()
    CreateAbyssalUI()
    CreateCruxUI()
    CreateFateUI()
    CreateUnboundUI()
    CreateEruditeUI()
    CreateGibberUI()
    CreateBlockUI()

    UpdateFonts()
    UpdateColors()
    UpdateCruxSize()

    RefreshMasterySelections()
    ScanCurrentCrux()
    ScanCurrentArmor()

    UpdateInkDisplay()
    UpdateAbyssalDisplay()
    UpdateCruxDisplay()
    UpdateFateDisplay()
    UpdateUnboundDisplay()
    UpdateEruditeDisplay()
    UpdateGibberDisplay()
    UpdateBlockDisplay()

    CreateSettings()

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_Combat",
        EVENT_COMBAT_EVENT,
        OnCombatEvent
    )

    EVENT_MANAGER:AddFilterForEvent(
        ADDON_NAME .. "_Combat",
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
        COMBAT_UNIT_TYPE_PLAYER
    )

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_Effects",
        EVENT_EFFECT_CHANGED,
        OnEffectChanged
    )

    EVENT_MANAGER:AddFilterForEvent(
        ADDON_NAME .. "_Effects",
        EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG,
        "player"
    )

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_CombatState",
        EVENT_PLAYER_COMBAT_STATE,
        OnCombatState
    )

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_PlayerActivated",
        EVENT_PLAYER_ACTIVATED,
        OnPlayerActivated
    )

    EVENT_MANAGER:RegisterForUpdate(
        ADDON_NAME .. "_Update",
        100,
        OnUpdate
    )
end

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)