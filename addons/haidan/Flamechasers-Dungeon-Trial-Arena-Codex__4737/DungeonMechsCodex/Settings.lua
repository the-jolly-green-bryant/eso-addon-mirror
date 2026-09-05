-- Flamechasers Dungeon, Trial & Arena Codex
-- Appearance settings, validation, presets, and LibAddonMenu integration.

local DMC = DungeonMechsCodex

local function clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

local function deepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do copy[key] = deepCopy(child) end
    return copy
end

local function replaceTable(target, source)
    for key in pairs(target) do target[key] = nil end
    for key, value in pairs(source) do target[key] = deepCopy(value) end
end

local function rgba(r, g, b, a)
    return {r, g, b, a == nil and 1 or a}
end

-- These values are the exact v0.7.2 presentation. New users and upgraded users
-- therefore see no visual change until they choose to customize the Codex.
DMC.appearanceDefaults = {
    schema = 4,
    preset = "flamechasers",
    typography = {
        bodyFace = "$(MEDIUM_FONT)",
        headingFace = "$(BOLD_FONT)",
        navigationFace = "$(MEDIUM_FONT)",
        bodyStyle = "soft-shadow-thin",
        headingStyle = "soft-shadow-thick",
        bodySize = 15,
        navigationSize = 18,
        bossRowSize = 14,
        sectionSize = 16,
        activityTitleSize = 24,
        bossTitleSize = 20,
        compactSize = 13,
        hintSize = 11,
    },
    layout = {
        windowScale = 100,
        lockWindowPosition = false,
        activityRowHeight = 30,
        mechanicSpacing = 14,
        artworkIntensity = 100,
        showArtwork = true,
        showMechanicNumbers = true,
        showHoverHints = true,
        showDlcTags = true,
        showHeaderTagline = true,
        showSectionIcons = true,
        showCounters = true,
    },
    colors = {
        bg = rgba(0.005, 0.009, 0.014, 1),
        mainSurface = rgba(0.003, 0.007, 0.011, 0.94),
        header = rgba(0.014, 0.062, 0.094, 1),
        panel = rgba(0.010, 0.018, 0.026, 1),
        panel2 = rgba(0.014, 0.024, 0.034, 1),
        section = rgba(0.022, 0.052, 0.070, 1),
        sectionAlt = rgba(0.019, 0.042, 0.057, 1),

        row = rgba(0.024, 0.039, 0.052, 1),
        rowHover = rgba(0.038, 0.073, 0.096, 1),
        rowSelected = rgba(0.032, 0.104, 0.143, 1),
        rowText = rgba(0.76, 0.82, 0.86, 1),
        rowSelectedText = rgba(0.52, 0.93, 1.00, 1),
        currentRow = rgba(0.028, 0.068, 0.060, 0.97),
        currentText = rgba(0.48, 0.95, 0.65, 1),
        bossRow = rgba(0.018, 0.032, 0.042, 0.72),
        bossRowHover = rgba(0.043, 0.079, 0.104, 0.96),
        bossText = rgba(0.78, 0.82, 0.85, 1),
        bossHoverText = rgba(0.93, 0.95, 0.96, 1),
        bossFlagText = rgba(0x46 / 255, 0x54 / 255, 0x5D / 255, 1),
        bossChevron = rgba(0x5B / 255, 0x6D / 255, 0x78 / 255, 1),
        bossChevronActive = rgba(0x75 / 255, 0xE6 / 255, 1.00, 1),
        stubText = rgba(0x68 / 255, 0x72 / 255, 0x7A / 255, 1),

        pill = rgba(0.034, 0.078, 0.100, 1),
        pillHover = rgba(0.052, 0.122, 0.154, 1),
        pillPressed = rgba(0.030, 0.106, 0.142, 1),
        pillSelected = rgba(0.044, 0.158, 0.206, 1),
        pillPrimaryHover = rgba(0.060, 0.196, 0.248, 1),
        pillDisabled = rgba(0.018, 0.034, 0.044, 1),
        segment = rgba(0.017, 0.037, 0.049, 1),
        segmentHover = rgba(0.030, 0.075, 0.096, 1),
        segmentPressed = rgba(0.027, 0.094, 0.122, 1),
        segmentSelected = rgba(0.030, 0.112, 0.146, 1),
        pillEdge = rgba(0.18, 0.50, 0.61, 0.94),
        pillHoverEdge = rgba(0.31, 0.73, 0.87, 1),
        pillSelectedEdge = rgba(0.39, 0.87, 1.00, 1),
        pillDisabledEdge = rgba(0.11, 0.28, 0.34, 0.74),
        buttonText = rgba(0.84, 0.88, 0.91, 1),
        buttonHoverText = rgba(1.00, 1.00, 1.00, 1),
        buttonPressedText = rgba(0.48, 0.91, 1.00, 1),
        buttonDisabledText = rgba(0.43, 0.48, 0.52, 1),
        iconPill = rgba(0.018, 0.043, 0.056, 0.82),
        iconPillHover = rgba(0.035, 0.092, 0.116, 0.94),
        iconPillEdge = rgba(0.14, 0.39, 0.48, 0.82),

        bodyText = rgba(0.82, 0.85, 0.88, 1),
        bodyTextSoft = rgba(0.76, 0.80, 0.83, 1),
        title = rgba(0.48, 0.90, 1.00, 1),
        sectionTitle = rgba(0.48, 0.90, 1.00, 1),
        text = rgba(0.92, 0.93, 0.94, 1),
        muted = rgba(0.52, 0.62, 0.70, 1),
        quiet = rgba(0.38, 0.46, 0.54, 1),
        gold = rgba(0.96, 0.75, 0.30, 1),
        ok = rgba(0.45, 0.94, 0.62, 1),
        warning = rgba(0.95, 0.72, 0.32, 1),

        mechanic = rgba(0.024, 0.048, 0.063, 1),
        mechanicAlt = rgba(0.014, 0.029, 0.041, 1),
        mechanicHeader = rgba(0.030, 0.064, 0.082, 1),
        mechanicAction = rgba(0.010, 0.023, 0.032, 0.96),
        mechanicHeaderRule = rgba(0.72, 0.51, 0.16, 0.48),
        mechanicBottomRule = rgba(0.08, 0.22, 0.28, 0.24),
        mechanicAccent = rgba(1.00, 0.72, 0.24, 0.82),

        structuralRule = rgba(0.12, 0.36, 0.45, 0.56),
        passiveRule = rgba(0.10, 0.29, 0.36, 0.42),
        fieldEdge = rgba(0.16, 0.45, 0.55, 0.88),
        fieldFocus = rgba(0.32, 0.76, 0.90, 1),
        edge = rgba(0.25, 0.72, 1.00, 0.92),
        edgeDim = rgba(0.13, 0.38, 0.48, 0.96),

        search = rgba(0.008, 0.017, 0.024, 1),
        searchHover = rgba(0.012, 0.026, 0.036, 1),
        searchFocus = rgba(0.014, 0.032, 0.044, 1),
        searchText = rgba(0.88, 0.92, 0.95, 1),
        noteSurface = rgba(0.012, 0.024, 0.032, 1),
        groupSurface = rgba(0.007, 0.016, 0.022, 1),
        hintSurface = rgba(0.008, 0.019, 0.026, 0.98),
        hintEdge = rgba(0.14, 0.38, 0.46, 0.88),
        close = rgba(0.90, 0.94, 1.00, 1),
        closeHover = rgba(0.48, 0.91, 1.00, 1),
        artworkLeft = rgba(0.15, 0.27, 0.31, 0.07),
        artworkRight = rgba(0.34, 0.54, 0.61, 0.17),
    },
}

-- Presets intentionally affect color only. Typography and density are personal
-- choices and should never be overwritten merely because the palette changes.
local COLOR_PRESETS = {
    flamechasers = { name = "Flamechasers (Default)", colors = {} },
    midnight = {
        name = "Midnight Violet",
        colors = {
            bg = rgba(0.006, 0.004, 0.015, 1),
            mainSurface = rgba(0.005, 0.003, 0.013, 0.95),
            header = rgba(0.035, 0.025, 0.090, 1),
            panel = rgba(0.012, 0.009, 0.024, 1),
            panel2 = rgba(0.016, 0.012, 0.031, 1),
            section = rgba(0.045, 0.038, 0.088, 1),
            sectionAlt = rgba(0.034, 0.031, 0.070, 1),
            row = rgba(0.026, 0.019, 0.043, 1),
            rowHover = rgba(0.047, 0.035, 0.075, 1),
            rowSelected = rgba(0.090, 0.058, 0.170, 1),
            rowText = rgba(0.80, 0.78, 0.86, 1),
            rowSelectedText = rgba(0.84, 0.76, 1.00, 1),
            currentRow = rgba(0.030, 0.058, 0.052, 0.97),
            currentText = rgba(0.59, 0.91, 0.72, 1),
            bossRow = rgba(0.018, 0.014, 0.032, 0.72),
            bossRowHover = rgba(0.052, 0.039, 0.082, 0.96),
            bossText = rgba(0.80, 0.78, 0.86, 1),
            bossHoverText = rgba(0.95, 0.93, 0.98, 1),
            bossFlagText = rgba(0.36, 0.33, 0.43, 1),
            bossChevron = rgba(0.42, 0.36, 0.54, 1),
            bossChevronActive = rgba(0.82, 0.72, 1.00, 1),
            stubText = rgba(0.44, 0.41, 0.49, 1),
            pill = rgba(0.050, 0.036, 0.084, 1),
            pillHover = rgba(0.083, 0.058, 0.135, 1),
            pillPressed = rgba(0.095, 0.058, 0.170, 1),
            pillSelected = rgba(0.125, 0.075, 0.215, 1),
            pillPrimaryHover = rgba(0.168, 0.100, 0.280, 1),
            pillDisabled = rgba(0.027, 0.022, 0.041, 1),
            segment = rgba(0.028, 0.022, 0.049, 1),
            segmentHover = rgba(0.060, 0.043, 0.103, 1),
            segmentPressed = rgba(0.080, 0.050, 0.140, 1),
            segmentSelected = rgba(0.100, 0.064, 0.180, 1),
            pillEdge = rgba(0.39, 0.30, 0.72, 0.94),
            pillHoverEdge = rgba(0.62, 0.49, 0.96, 1),
            pillSelectedEdge = rgba(0.76, 0.65, 1.00, 1),
            pillDisabledEdge = rgba(0.22, 0.17, 0.37, 0.74),
            buttonText = rgba(0.86, 0.83, 0.91, 1),
            buttonHoverText = rgba(0.97, 0.95, 1.00, 1),
            buttonPressedText = rgba(0.82, 0.72, 1.00, 1),
            buttonDisabledText = rgba(0.43, 0.40, 0.49, 1),
            iconPill = rgba(0.026, 0.020, 0.048, 0.86),
            iconPillHover = rgba(0.068, 0.048, 0.112, 0.96),
            iconPillEdge = rgba(0.32, 0.25, 0.57, 0.86),
            bodyText = rgba(0.84, 0.82, 0.89, 1),
            bodyTextSoft = rgba(0.76, 0.74, 0.82, 1),
            title = rgba(0.76, 0.65, 1.00, 1),
            sectionTitle = rgba(0.81, 0.74, 0.96, 1),
            text = rgba(0.94, 0.93, 0.97, 1),
            muted = rgba(0.58, 0.55, 0.68, 1),
            quiet = rgba(0.43, 0.40, 0.52, 1),
            gold = rgba(0.95, 0.64, 0.84, 1),
            ok = rgba(0.59, 0.91, 0.72, 1),
            warning = rgba(0.95, 0.64, 0.45, 1),
            mechanic = rgba(0.028, 0.020, 0.048, 1),
            mechanicAlt = rgba(0.016, 0.012, 0.030, 1),
            mechanicHeader = rgba(0.052, 0.034, 0.076, 1),
            mechanicAction = rgba(0.014, 0.010, 0.026, 0.96),
            mechanicHeaderRule = rgba(0.65, 0.34, 0.62, 0.50),
            mechanicBottomRule = rgba(0.23, 0.17, 0.42, 0.28),
            mechanicAccent = rgba(0.88, 0.47, 0.75, 0.86),
            edge = rgba(0.56, 0.42, 1.00, 0.94),
            edgeDim = rgba(0.30, 0.23, 0.58, 0.96),
            passiveRule = rgba(0.25, 0.20, 0.47, 0.44),
            fieldFocus = rgba(0.67, 0.56, 1.00, 1),
            fieldEdge = rgba(0.40, 0.31, 0.70, 0.88),
            structuralRule = rgba(0.34, 0.27, 0.65, 0.60),
            search = rgba(0.011, 0.008, 0.023, 1),
            searchHover = rgba(0.024, 0.017, 0.044, 1),
            searchFocus = rgba(0.034, 0.023, 0.060, 1),
            searchText = rgba(0.91, 0.89, 0.95, 1),
            noteSurface = rgba(0.014, 0.010, 0.027, 1),
            groupSurface = rgba(0.010, 0.007, 0.021, 1),
            hintSurface = rgba(0.015, 0.010, 0.030, 0.98),
            hintEdge = rgba(0.38, 0.29, 0.66, 0.90),
            close = rgba(0.94, 0.92, 0.98, 1),
            closeHover = rgba(0.82, 0.72, 1.00, 1),
            artworkLeft = rgba(0.25, 0.17, 0.35, 0.07),
            artworkRight = rgba(0.50, 0.36, 0.68, 0.17),
        },
    },
    ember = {
        name = "Ember",
        colors = {
            bg = rgba(0.012, 0.007, 0.005, 1),
            mainSurface = rgba(0.011, 0.006, 0.004, 0.95),
            header = rgba(0.095, 0.034, 0.014, 1),
            panel = rgba(0.025, 0.014, 0.010, 1),
            panel2 = rgba(0.034, 0.019, 0.013, 1),
            section = rgba(0.078, 0.034, 0.018, 1),
            sectionAlt = rgba(0.058, 0.027, 0.017, 1),
            row = rgba(0.049, 0.027, 0.018, 1),
            rowHover = rgba(0.092, 0.047, 0.025, 1),
            rowSelected = rgba(0.145, 0.061, 0.025, 1),
            rowText = rgba(0.84, 0.79, 0.72, 1),
            rowSelectedText = rgba(1.00, 0.75, 0.43, 1),
            currentRow = rgba(0.055, 0.059, 0.027, 0.97),
            currentText = rgba(0.78, 0.91, 0.50, 1),
            bossRow = rgba(0.035, 0.020, 0.014, 0.72),
            bossRowHover = rgba(0.092, 0.047, 0.025, 0.96),
            bossText = rgba(0.84, 0.79, 0.72, 1),
            bossHoverText = rgba(0.97, 0.94, 0.89, 1),
            bossFlagText = rgba(0.47, 0.39, 0.33, 1),
            bossChevron = rgba(0.58, 0.44, 0.34, 1),
            bossChevronActive = rgba(1.00, 0.69, 0.34, 1),
            stubText = rgba(0.49, 0.43, 0.38, 1),
            segment = rgba(0.049, 0.025, 0.016, 1),
            segmentHover = rgba(0.092, 0.044, 0.023, 1),
            segmentPressed = rgba(0.123, 0.052, 0.023, 1),
            segmentSelected = rgba(0.151, 0.062, 0.022, 1),
            pill = rgba(0.090, 0.040, 0.020, 1),
            pillHover = rgba(0.145, 0.061, 0.027, 1),
            pillPressed = rgba(0.165, 0.064, 0.022, 1),
            pillSelected = rgba(0.188, 0.073, 0.023, 1),
            pillPrimaryHover = rgba(0.235, 0.094, 0.029, 1),
            pillDisabled = rgba(0.038, 0.024, 0.018, 1),
            title = rgba(1.00, 0.69, 0.34, 1),
            sectionTitle = rgba(0.94, 0.68, 0.45, 1),
            gold = rgba(1.00, 0.70, 0.30, 1),
            edge = rgba(1.00, 0.42, 0.16, 0.94),
            edgeDim = rgba(0.61, 0.25, 0.11, 0.96),
            pillEdge = rgba(0.68, 0.29, 0.13, 0.94),
            pillHoverEdge = rgba(0.96, 0.47, 0.21, 1),
            pillSelectedEdge = rgba(1.00, 0.69, 0.34, 1),
            pillDisabledEdge = rgba(0.35, 0.17, 0.09, 0.74),
            buttonText = rgba(0.88, 0.82, 0.74, 1),
            buttonHoverText = rgba(0.99, 0.96, 0.91, 1),
            buttonPressedText = rgba(1.00, 0.72, 0.39, 1),
            buttonDisabledText = rgba(0.47, 0.41, 0.36, 1),
            iconPill = rgba(0.050, 0.027, 0.017, 0.84),
            iconPillHover = rgba(0.119, 0.052, 0.024, 0.96),
            iconPillEdge = rgba(0.56, 0.24, 0.11, 0.84),
            bodyText = rgba(0.88, 0.84, 0.78, 1),
            bodyTextSoft = rgba(0.79, 0.75, 0.69, 1),
            mechanic = rgba(0.054, 0.029, 0.018, 1),
            mechanicAlt = rgba(0.029, 0.017, 0.012, 1),
            mechanicHeader = rgba(0.080, 0.038, 0.019, 1),
            mechanicAction = rgba(0.022, 0.012, 0.008, 0.96),
            mechanicHeaderRule = rgba(0.83, 0.38, 0.13, 0.50),
            mechanicBottomRule = rgba(0.43, 0.18, 0.08, 0.27),
            mechanicAccent = rgba(1.00, 0.45, 0.13, 0.86),
            text = rgba(0.96, 0.93, 0.88, 1),
            muted = rgba(0.66, 0.58, 0.50, 1),
            quiet = rgba(0.49, 0.42, 0.36, 1),
            ok = rgba(0.78, 0.91, 0.50, 1),
            warning = rgba(0.94, 0.63, 0.34, 1),
            passiveRule = rgba(0.47, 0.20, 0.10, 0.43),
            fieldEdge = rgba(0.66, 0.28, 0.12, 0.88),
            fieldFocus = rgba(1.00, 0.55, 0.24, 1),
            structuralRule = rgba(0.61, 0.28, 0.14, 0.58),
            search = rgba(0.019, 0.010, 0.007, 1),
            searchHover = rgba(0.035, 0.018, 0.011, 1),
            searchFocus = rgba(0.051, 0.024, 0.013, 1),
            searchText = rgba(0.92, 0.88, 0.82, 1),
            noteSurface = rgba(0.023, 0.012, 0.008, 1),
            groupSurface = rgba(0.015, 0.008, 0.006, 1),
            hintSurface = rgba(0.027, 0.014, 0.009, 0.98),
            hintEdge = rgba(0.59, 0.25, 0.11, 0.88),
            close = rgba(0.96, 0.93, 0.88, 1),
            closeHover = rgba(1.00, 0.69, 0.34, 1),
            artworkLeft = rgba(0.31, 0.17, 0.10, 0.07),
            artworkRight = rgba(0.64, 0.31, 0.14, 0.17),
        },
    },
    verdant = {
        name = "Verdant",
        colors = {
            bg = rgba(0.003, 0.011, 0.009, 1),
            mainSurface = rgba(0.003, 0.010, 0.008, 0.95),
            header = rgba(0.010, 0.075, 0.060, 1),
            panel = rgba(0.007, 0.022, 0.018, 1),
            panel2 = rgba(0.009, 0.029, 0.023, 1),
            section = rgba(0.018, 0.066, 0.054, 1),
            sectionAlt = rgba(0.015, 0.050, 0.043, 1),
            row = rgba(0.014, 0.041, 0.033, 1),
            rowHover = rgba(0.023, 0.075, 0.057, 1),
            rowSelected = rgba(0.025, 0.125, 0.092, 1),
            rowText = rgba(0.80, 0.85, 0.81, 1),
            rowSelectedText = rgba(0.57, 1.00, 0.79, 1),
            currentRow = rgba(0.037, 0.075, 0.041, 0.97),
            currentText = rgba(0.72, 0.96, 0.61, 1),
            bossRow = rgba(0.010, 0.032, 0.026, 0.72),
            bossRowHover = rgba(0.025, 0.082, 0.061, 0.96),
            bossText = rgba(0.80, 0.85, 0.81, 1),
            bossHoverText = rgba(0.94, 0.98, 0.95, 1),
            bossFlagText = rgba(0.37, 0.46, 0.40, 1),
            bossChevron = rgba(0.42, 0.55, 0.47, 1),
            bossChevronActive = rgba(0.47, 1.00, 0.76, 1),
            stubText = rgba(0.43, 0.49, 0.45, 1),
            pill = rgba(0.021, 0.078, 0.057, 1),
            pillHover = rgba(0.026, 0.125, 0.087, 1),
            pillPressed = rgba(0.022, 0.145, 0.101, 1),
            pillSelected = rgba(0.027, 0.170, 0.117, 1),
            pillPrimaryHover = rgba(0.035, 0.215, 0.147, 1),
            pillDisabled = rgba(0.013, 0.041, 0.032, 1),
            segment = rgba(0.013, 0.050, 0.039, 1),
            segmentHover = rgba(0.019, 0.089, 0.066, 1),
            segmentPressed = rgba(0.020, 0.113, 0.082, 1),
            segmentSelected = rgba(0.022, 0.134, 0.096, 1),
            title = rgba(0.47, 1.00, 0.76, 1),
            sectionTitle = rgba(0.58, 0.91, 0.73, 1),
            gold = rgba(0.72, 0.94, 0.58, 1),
            edge = rgba(0.20, 0.91, 0.61, 0.94),
            edgeDim = rgba(0.11, 0.48, 0.35, 0.96),
            pillEdge = rgba(0.13, 0.56, 0.39, 0.94),
            pillHoverEdge = rgba(0.25, 0.84, 0.59, 1),
            pillSelectedEdge = rgba(0.47, 1.00, 0.76, 1),
            pillDisabledEdge = rgba(0.09, 0.31, 0.23, 0.74),
            buttonText = rgba(0.84, 0.89, 0.85, 1),
            buttonHoverText = rgba(0.97, 1.00, 0.98, 1),
            buttonPressedText = rgba(0.53, 1.00, 0.79, 1),
            buttonDisabledText = rgba(0.42, 0.49, 0.44, 1),
            iconPill = rgba(0.012, 0.052, 0.040, 0.84),
            iconPillHover = rgba(0.021, 0.105, 0.076, 0.96),
            iconPillEdge = rgba(0.11, 0.46, 0.33, 0.84),
            bodyText = rgba(0.84, 0.88, 0.85, 1),
            bodyTextSoft = rgba(0.76, 0.81, 0.78, 1),
            mechanic = rgba(0.016, 0.051, 0.039, 1),
            mechanicAlt = rgba(0.009, 0.030, 0.024, 1),
            mechanicHeader = rgba(0.021, 0.071, 0.053, 1),
            mechanicAction = rgba(0.007, 0.024, 0.019, 0.96),
            mechanicHeaderRule = rgba(0.38, 0.70, 0.28, 0.48),
            mechanicBottomRule = rgba(0.08, 0.34, 0.24, 0.25),
            mechanicAccent = rgba(0.48, 0.88, 0.37, 0.84),
            text = rgba(0.94, 0.97, 0.95, 1),
            muted = rgba(0.56, 0.67, 0.60, 1),
            quiet = rgba(0.40, 0.50, 0.44, 1),
            ok = rgba(0.72, 0.96, 0.61, 1),
            warning = rgba(0.94, 0.69, 0.34, 1),
            passiveRule = rgba(0.10, 0.41, 0.30, 0.42),
            fieldEdge = rgba(0.14, 0.55, 0.39, 0.88),
            fieldFocus = rgba(0.32, 0.92, 0.67, 1),
            structuralRule = rgba(0.12, 0.52, 0.38, 0.58),
            search = rgba(0.006, 0.020, 0.015, 1),
            searchHover = rgba(0.010, 0.036, 0.027, 1),
            searchFocus = rgba(0.013, 0.049, 0.036, 1),
            searchText = rgba(0.89, 0.93, 0.90, 1),
            noteSurface = rgba(0.008, 0.025, 0.019, 1),
            groupSurface = rgba(0.005, 0.017, 0.013, 1),
            hintSurface = rgba(0.007, 0.027, 0.020, 0.98),
            hintEdge = rgba(0.12, 0.47, 0.34, 0.88),
            close = rgba(0.94, 0.97, 0.95, 1),
            closeHover = rgba(0.47, 1.00, 0.76, 1),
            artworkLeft = rgba(0.11, 0.30, 0.22, 0.07),
            artworkRight = rgba(0.21, 0.57, 0.41, 0.17),
        },
    },
    roseVelvet = {
        name = "Rose Velvet",
        colors = {
            bg = rgba(0.012, 0.010, 0.015, 1),
            mainSurface = rgba(0.010, 0.009, 0.013, 0.95),
            header = rgba(0.060, 0.035, 0.060, 1),
            panel = rgba(0.022, 0.020, 0.027, 1),
            panel2 = rgba(0.026, 0.022, 0.030, 1),
            section = rgba(0.065, 0.041, 0.067, 1),
            sectionAlt = rgba(0.056, 0.037, 0.052, 1),
            row = rgba(0.032, 0.029, 0.037, 1),
            rowHover = rgba(0.054, 0.044, 0.060, 1),
            rowSelected = rgba(0.112, 0.058, 0.091, 1),
            rowText = rgba(0.82, 0.79, 0.82, 1),
            rowSelectedText = rgba(0.96, 0.73, 0.84, 1),
            currentRow = rgba(0.047, 0.056, 0.041, 0.97),
            currentText = rgba(0.75, 0.86, 0.66, 1),
            bossRow = rgba(0.024, 0.022, 0.029, 0.72),
            bossRowHover = rgba(0.060, 0.047, 0.064, 0.96),
            bossText = rgba(0.82, 0.80, 0.82, 1),
            bossHoverText = rgba(0.95, 0.92, 0.94, 1),
            bossFlagText = rgba(0.40, 0.36, 0.39, 1),
            bossChevron = rgba(0.48, 0.43, 0.47, 1),
            bossChevronActive = rgba(0.90, 0.62, 0.77, 1),
            stubText = rgba(0.43, 0.40, 0.42, 1),
            pill = rgba(0.058, 0.040, 0.059, 1),
            pillHover = rgba(0.101, 0.059, 0.090, 1),
            pillPressed = rgba(0.129, 0.061, 0.100, 1),
            pillSelected = rgba(0.150, 0.070, 0.116, 1),
            pillPrimaryHover = rgba(0.190, 0.087, 0.145, 1),
            pillDisabled = rgba(0.032, 0.028, 0.035, 1),
            segment = rgba(0.035, 0.031, 0.040, 1),
            segmentHover = rgba(0.073, 0.048, 0.071, 1),
            segmentPressed = rgba(0.102, 0.052, 0.085, 1),
            segmentSelected = rgba(0.126, 0.060, 0.099, 1),
            pillEdge = rgba(0.46, 0.31, 0.40, 0.94),
            pillHoverEdge = rgba(0.68, 0.43, 0.56, 1),
            pillSelectedEdge = rgba(0.88, 0.62, 0.75, 1),
            pillDisabledEdge = rgba(0.27, 0.20, 0.24, 0.74),
            buttonText = rgba(0.86, 0.82, 0.84, 1),
            buttonHoverText = rgba(0.96, 0.93, 0.94, 1),
            buttonPressedText = rgba(0.96, 0.75, 0.85, 1),
            buttonDisabledText = rgba(0.44, 0.41, 0.43, 1),
            iconPill = rgba(0.040, 0.031, 0.040, 0.84),
            iconPillHover = rgba(0.085, 0.052, 0.078, 0.96),
            iconPillEdge = rgba(0.39, 0.27, 0.34, 0.84),
            bodyText = rgba(0.86, 0.84, 0.85, 1),
            bodyTextSoft = rgba(0.76, 0.73, 0.75, 1),
            title = rgba(0.92, 0.63, 0.76, 1),
            sectionTitle = rgba(0.78, 0.67, 0.78, 1),
            text = rgba(0.95, 0.92, 0.93, 1),
            muted = rgba(0.60, 0.55, 0.58, 1),
            quiet = rgba(0.43, 0.39, 0.41, 1),
            gold = rgba(0.88, 0.76, 0.60, 1),
            ok = rgba(0.66, 0.84, 0.69, 1),
            warning = rgba(0.90, 0.65, 0.53, 1),
            mechanic = rgba(0.035, 0.029, 0.037, 1),
            mechanicAlt = rgba(0.022, 0.020, 0.026, 1),
            mechanicHeader = rgba(0.054, 0.039, 0.051, 1),
            mechanicAction = rgba(0.018, 0.016, 0.021, 0.96),
            mechanicHeaderRule = rgba(0.55, 0.42, 0.31, 0.46),
            mechanicBottomRule = rgba(0.26, 0.18, 0.23, 0.27),
            mechanicAccent = rgba(0.78, 0.43, 0.57, 0.84),
            structuralRule = rgba(0.38, 0.25, 0.34, 0.58),
            passiveRule = rgba(0.27, 0.19, 0.24, 0.42),
            fieldEdge = rgba(0.46, 0.31, 0.40, 0.88),
            fieldFocus = rgba(0.82, 0.55, 0.69, 1),
            edge = rgba(0.67, 0.39, 0.53, 0.94),
            edgeDim = rgba(0.40, 0.25, 0.34, 0.96),
            search = rgba(0.018, 0.016, 0.021, 1),
            searchHover = rgba(0.029, 0.025, 0.033, 1),
            searchFocus = rgba(0.043, 0.031, 0.042, 1),
            searchText = rgba(0.91, 0.88, 0.89, 1),
            noteSurface = rgba(0.020, 0.018, 0.023, 1),
            groupSurface = rgba(0.015, 0.014, 0.018, 1),
            hintSurface = rgba(0.021, 0.018, 0.024, 0.98),
            hintEdge = rgba(0.40, 0.27, 0.35, 0.88),
            close = rgba(0.95, 0.92, 0.93, 1),
            closeHover = rgba(0.96, 0.72, 0.83, 1),
            artworkLeft = rgba(0.20, 0.16, 0.21, 0.07),
            artworkRight = rgba(0.38, 0.28, 0.34, 0.17),
        },
    },
    classicEso = {
        name = "Classic ESO",
        colors = {
            bg = rgba(0.013, 0.011, 0.008, 1),
            mainSurface = rgba(0.011, 0.009, 0.007, 0.95),
            header = rgba(0.105, 0.078, 0.043, 1),
            panel = rgba(0.031, 0.026, 0.019, 1),
            panel2 = rgba(0.040, 0.033, 0.023, 1),
            section = rgba(0.105, 0.080, 0.046, 1),
            sectionAlt = rgba(0.079, 0.061, 0.038, 1),
            row = rgba(0.048, 0.040, 0.029, 1),
            rowHover = rgba(0.083, 0.067, 0.043, 1),
            rowSelected = rgba(0.121, 0.092, 0.050, 1),
            rowText = rgba(0.82, 0.78, 0.68, 1),
            rowSelectedText = rgba(0.94, 0.84, 0.58, 1),
            currentRow = rgba(0.058, 0.066, 0.039, 0.97),
            currentText = rgba(0.75, 0.86, 0.55, 1),
            bossRow = rgba(0.037, 0.030, 0.021, 0.72),
            bossRowHover = rgba(0.086, 0.068, 0.043, 0.96),
            bossText = rgba(0.83, 0.79, 0.70, 1),
            bossHoverText = rgba(0.96, 0.91, 0.80, 1),
            bossFlagText = rgba(0.46, 0.43, 0.36, 1),
            bossChevron = rgba(0.55, 0.50, 0.39, 1),
            bossChevronActive = rgba(0.91, 0.78, 0.44, 1),
            stubText = rgba(0.44, 0.42, 0.35, 1),
            pill = rgba(0.077, 0.059, 0.034, 1),
            pillHover = rgba(0.126, 0.094, 0.048, 1),
            pillPressed = rgba(0.145, 0.106, 0.050, 1),
            pillSelected = rgba(0.167, 0.122, 0.055, 1),
            pillPrimaryHover = rgba(0.205, 0.150, 0.066, 1),
            pillDisabled = rgba(0.042, 0.035, 0.026, 1),
            segment = rgba(0.052, 0.043, 0.029, 1),
            segmentHover = rgba(0.096, 0.075, 0.041, 1),
            segmentPressed = rgba(0.125, 0.092, 0.044, 1),
            segmentSelected = rgba(0.145, 0.106, 0.049, 1),
            pillEdge = rgba(0.55, 0.42, 0.22, 0.94),
            pillHoverEdge = rgba(0.78, 0.60, 0.30, 1),
            pillSelectedEdge = rgba(0.91, 0.78, 0.44, 1),
            pillDisabledEdge = rgba(0.31, 0.25, 0.16, 0.74),
            buttonText = rgba(0.87, 0.82, 0.72, 1),
            buttonHoverText = rgba(0.98, 0.94, 0.84, 1),
            buttonPressedText = rgba(0.94, 0.84, 0.58, 1),
            buttonDisabledText = rgba(0.47, 0.43, 0.35, 1),
            iconPill = rgba(0.054, 0.043, 0.027, 0.84),
            iconPillHover = rgba(0.111, 0.082, 0.042, 0.96),
            iconPillEdge = rgba(0.47, 0.36, 0.19, 0.84),
            bodyText = rgba(0.88, 0.84, 0.76, 1),
            bodyTextSoft = rgba(0.81, 0.77, 0.68, 1),
            title = rgba(0.88, 0.76, 0.45, 1),
            sectionTitle = rgba(0.83, 0.75, 0.58, 1),
            text = rgba(0.95, 0.91, 0.83, 1),
            muted = rgba(0.65, 0.60, 0.49, 1),
            quiet = rgba(0.49, 0.46, 0.38, 1),
            gold = rgba(0.91, 0.75, 0.36, 1),
            ok = rgba(0.70, 0.84, 0.49, 1),
            warning = rgba(0.91, 0.62, 0.29, 1),
            mechanic = rgba(0.055, 0.044, 0.027, 1),
            mechanicAlt = rgba(0.032, 0.026, 0.018, 1),
            mechanicHeader = rgba(0.083, 0.062, 0.031, 1),
            mechanicAction = rgba(0.024, 0.019, 0.013, 0.96),
            mechanicHeaderRule = rgba(0.67, 0.48, 0.19, 0.50),
            mechanicBottomRule = rgba(0.34, 0.26, 0.13, 0.27),
            mechanicAccent = rgba(0.88, 0.67, 0.27, 0.86),
            structuralRule = rgba(0.49, 0.37, 0.19, 0.58),
            passiveRule = rgba(0.38, 0.30, 0.17, 0.42),
            fieldEdge = rgba(0.54, 0.42, 0.22, 0.88),
            fieldFocus = rgba(0.86, 0.70, 0.36, 1),
            edge = rgba(0.78, 0.61, 0.30, 0.94),
            edgeDim = rgba(0.46, 0.36, 0.20, 0.96),
            search = rgba(0.024, 0.019, 0.013, 1),
            searchHover = rgba(0.039, 0.031, 0.020, 1),
            searchFocus = rgba(0.055, 0.042, 0.023, 1),
            searchText = rgba(0.91, 0.87, 0.78, 1),
            noteSurface = rgba(0.027, 0.022, 0.015, 1),
            groupSurface = rgba(0.019, 0.015, 0.010, 1),
            hintSurface = rgba(0.027, 0.021, 0.014, 0.98),
            hintEdge = rgba(0.46, 0.35, 0.18, 0.88),
            close = rgba(0.95, 0.91, 0.83, 1),
            closeHover = rgba(0.94, 0.82, 0.54, 1),
            artworkLeft = rgba(0.27, 0.22, 0.15, 0.07),
            artworkRight = rgba(0.53, 0.42, 0.23, 0.17),
        },
    },
    moonlitSapphire = {
        name = "Moonlit Sapphire",
        colors = {
            bg = rgba(0.004, 0.008, 0.016, 1),
            mainSurface = rgba(0.003, 0.007, 0.014, 0.95),
            header = rgba(0.025, 0.052, 0.099, 1),
            panel = rgba(0.010, 0.021, 0.038, 1),
            panel2 = rgba(0.013, 0.027, 0.048, 1),
            section = rgba(0.031, 0.061, 0.108, 1),
            sectionAlt = rgba(0.025, 0.049, 0.087, 1),
            row = rgba(0.020, 0.036, 0.059, 1),
            rowHover = rgba(0.033, 0.063, 0.102, 1),
            rowSelected = rgba(0.041, 0.090, 0.152, 1),
            rowText = rgba(0.78, 0.83, 0.90, 1),
            rowSelectedText = rgba(0.66, 0.80, 0.98, 1),
            currentRow = rgba(0.029, 0.066, 0.063, 0.97),
            currentText = rgba(0.58, 0.89, 0.75, 1),
            bossRow = rgba(0.015, 0.028, 0.047, 0.72),
            bossRowHover = rgba(0.035, 0.069, 0.112, 0.96),
            bossText = rgba(0.78, 0.83, 0.90, 1),
            bossHoverText = rgba(0.94, 0.97, 1.00, 1),
            bossFlagText = rgba(0.37, 0.43, 0.52, 1),
            bossChevron = rgba(0.43, 0.52, 0.64, 1),
            bossChevronActive = rgba(0.62, 0.77, 0.98, 1),
            stubText = rgba(0.43, 0.48, 0.55, 1),
            pill = rgba(0.029, 0.061, 0.102, 1),
            pillHover = rgba(0.044, 0.095, 0.157, 1),
            pillPressed = rgba(0.043, 0.112, 0.187, 1),
            pillSelected = rgba(0.049, 0.132, 0.220, 1),
            pillPrimaryHover = rgba(0.061, 0.162, 0.266, 1),
            pillDisabled = rgba(0.017, 0.035, 0.055, 1),
            segment = rgba(0.018, 0.040, 0.068, 1),
            segmentHover = rgba(0.031, 0.076, 0.126, 1),
            segmentPressed = rgba(0.036, 0.096, 0.159, 1),
            segmentSelected = rgba(0.041, 0.111, 0.185, 1),
            pillEdge = rgba(0.25, 0.49, 0.74, 0.94),
            pillHoverEdge = rgba(0.43, 0.68, 0.91, 1),
            pillSelectedEdge = rgba(0.61, 0.76, 0.96, 1),
            pillDisabledEdge = rgba(0.15, 0.30, 0.45, 0.74),
            buttonText = rgba(0.84, 0.88, 0.94, 1),
            buttonHoverText = rgba(0.97, 0.99, 1.00, 1),
            buttonPressedText = rgba(0.66, 0.80, 0.98, 1),
            buttonDisabledText = rgba(0.42, 0.48, 0.56, 1),
            iconPill = rgba(0.018, 0.043, 0.073, 0.84),
            iconPillHover = rgba(0.035, 0.087, 0.143, 0.96),
            iconPillEdge = rgba(0.21, 0.42, 0.64, 0.84),
            bodyText = rgba(0.83, 0.86, 0.91, 1),
            bodyTextSoft = rgba(0.75, 0.79, 0.85, 1),
            title = rgba(0.58, 0.72, 0.94, 1),
            sectionTitle = rgba(0.67, 0.76, 0.90, 1),
            text = rgba(0.94, 0.96, 0.99, 1),
            muted = rgba(0.55, 0.63, 0.74, 1),
            quiet = rgba(0.41, 0.48, 0.59, 1),
            gold = rgba(0.72, 0.70, 0.92, 1),
            ok = rgba(0.58, 0.89, 0.75, 1),
            warning = rgba(0.94, 0.69, 0.42, 1),
            mechanic = rgba(0.020, 0.044, 0.074, 1),
            mechanicAlt = rgba(0.012, 0.026, 0.044, 1),
            mechanicHeader = rgba(0.027, 0.057, 0.096, 1),
            mechanicAction = rgba(0.009, 0.021, 0.036, 0.96),
            mechanicHeaderRule = rgba(0.43, 0.42, 0.69, 0.48),
            mechanicBottomRule = rgba(0.12, 0.28, 0.46, 0.26),
            mechanicAccent = rgba(0.57, 0.55, 0.85, 0.84),
            structuralRule = rgba(0.21, 0.42, 0.66, 0.58),
            passiveRule = rgba(0.16, 0.33, 0.53, 0.42),
            fieldEdge = rgba(0.24, 0.49, 0.74, 0.88),
            fieldFocus = rgba(0.51, 0.71, 0.94, 1),
            edge = rgba(0.42, 0.66, 0.94, 0.94),
            edgeDim = rgba(0.24, 0.44, 0.67, 0.96),
            search = rgba(0.007, 0.017, 0.030, 1),
            searchHover = rgba(0.012, 0.030, 0.051, 1),
            searchFocus = rgba(0.017, 0.041, 0.069, 1),
            searchText = rgba(0.89, 0.92, 0.97, 1),
            noteSurface = rgba(0.009, 0.021, 0.036, 1),
            groupSurface = rgba(0.006, 0.014, 0.025, 1),
            hintSurface = rgba(0.008, 0.021, 0.036, 0.98),
            hintEdge = rgba(0.22, 0.43, 0.65, 0.88),
            close = rgba(0.94, 0.96, 0.99, 1),
            closeHover = rgba(0.62, 0.77, 0.98, 1),
            artworkLeft = rgba(0.14, 0.24, 0.38, 0.07),
            artworkRight = rgba(0.28, 0.47, 0.70, 0.17),
        },
    },
    highContrast = {
        name = "High Contrast",
        colors = {
            bg = rgba(0.000, 0.000, 0.000, 1),
            mainSurface = rgba(0.000, 0.000, 0.000, 1),
            header = rgba(0.010, 0.035, 0.052, 1),
            panel = rgba(0.004, 0.008, 0.012, 1),
            panel2 = rgba(0.007, 0.013, 0.019, 1),
            section = rgba(0.020, 0.057, 0.077, 1),
            sectionAlt = rgba(0.015, 0.043, 0.060, 1),

            row = rgba(0.016, 0.024, 0.032, 1),
            rowHover = rgba(0.045, 0.090, 0.118, 1),
            rowSelected = rgba(0.020, 0.145, 0.200, 1),
            rowText = rgba(0.95, 0.97, 0.98, 1),
            rowSelectedText = rgba(1.00, 1.00, 1.00, 1),
            currentRow = rgba(0.012, 0.100, 0.055, 0.98),
            currentText = rgba(0.68, 1.00, 0.78, 1),
            bossRow = rgba(0.010, 0.020, 0.028, 0.88),
            bossRowHover = rgba(0.035, 0.100, 0.140, 0.98),
            bossText = rgba(0.95, 0.97, 0.98, 1),
            bossHoverText = rgba(1.00, 1.00, 1.00, 1),
            bossFlagText = rgba(0.68, 0.74, 0.80, 1),
            bossChevron = rgba(0.60, 0.70, 0.76, 1),
            bossChevronActive = rgba(0.52, 0.93, 1.00, 1),
            stubText = rgba(0.70, 0.72, 0.75, 1),

            pill = rgba(0.018, 0.050, 0.068, 1),
            pillHover = rgba(0.030, 0.100, 0.135, 1),
            pillPressed = rgba(0.025, 0.130, 0.180, 1),
            pillSelected = rgba(0.020, 0.145, 0.200, 1),
            pillPrimaryHover = rgba(0.030, 0.200, 0.265, 1),
            pillDisabled = rgba(0.012, 0.020, 0.027, 1),
            segment = rgba(0.012, 0.038, 0.052, 1),
            segmentHover = rgba(0.025, 0.088, 0.120, 1),
            segmentPressed = rgba(0.022, 0.120, 0.165, 1),
            segmentSelected = rgba(0.020, 0.145, 0.200, 1),
            pillEdge = rgba(0.26, 0.67, 0.80, 1),
            pillHoverEdge = rgba(0.42, 0.94, 1.00, 1),
            pillSelectedEdge = rgba(0.52, 0.93, 1.00, 1),
            pillDisabledEdge = rgba(0.18, 0.35, 0.42, 0.90),
            buttonText = rgba(0.96, 0.98, 1.00, 1),
            buttonHoverText = rgba(1.00, 1.00, 1.00, 1),
            buttonPressedText = rgba(0.52, 0.93, 1.00, 1),
            buttonDisabledText = rgba(0.55, 0.60, 0.65, 1),
            iconPill = rgba(0.010, 0.035, 0.048, 0.96),
            iconPillHover = rgba(0.025, 0.105, 0.140, 1),
            iconPillEdge = rgba(0.24, 0.62, 0.75, 1),

            bodyText = rgba(0.96, 0.97, 0.98, 1),
            bodyTextSoft = rgba(0.91, 0.93, 0.95, 1),
            title = rgba(0.35, 0.90, 1.00, 1),
            sectionTitle = rgba(0.52, 0.93, 1.00, 1),
            text = rgba(1.00, 1.00, 1.00, 1),
            muted = rgba(0.72, 0.78, 0.84, 1),
            quiet = rgba(0.61, 0.68, 0.75, 1),
            gold = rgba(1.00, 0.82, 0.35, 1),
            ok = rgba(0.68, 1.00, 0.78, 1),
            warning = rgba(1.00, 0.75, 0.30, 1),

            mechanic = rgba(0.014, 0.038, 0.050, 1),
            mechanicAlt = rgba(0.006, 0.018, 0.025, 1),
            mechanicHeader = rgba(0.020, 0.065, 0.085, 1),
            mechanicAction = rgba(0.003, 0.012, 0.017, 0.98),
            mechanicHeaderRule = rgba(0.85, 0.61, 0.18, 0.75),
            mechanicBottomRule = rgba(0.20, 0.58, 0.70, 0.50),
            mechanicAccent = rgba(1.00, 0.74, 0.24, 1),

            structuralRule = rgba(0.20, 0.68, 0.82, 0.72),
            passiveRule = rgba(0.23, 0.52, 0.63, 0.65),
            fieldEdge = rgba(0.26, 0.67, 0.80, 1),
            fieldFocus = rgba(0.42, 0.94, 1.00, 1),
            edge = rgba(0.18, 0.82, 1.00, 1),
            edgeDim = rgba(0.13, 0.55, 0.70, 1),

            search = rgba(0.002, 0.010, 0.015, 1),
            searchHover = rgba(0.008, 0.028, 0.038, 1),
            searchFocus = rgba(0.012, 0.045, 0.060, 1),
            searchText = rgba(0.96, 0.98, 1.00, 1),
            noteSurface = rgba(0.003, 0.012, 0.017, 1),
            groupSurface = rgba(0.001, 0.007, 0.010, 1),
            hintSurface = rgba(0.002, 0.012, 0.018, 1),
            hintEdge = rgba(0.28, 0.72, 0.84, 1),
            close = rgba(1.00, 1.00, 1.00, 1),
            closeHover = rgba(0.52, 0.93, 1.00, 1),
            artworkLeft = rgba(0.10, 0.24, 0.29, 0.07),
            artworkRight = rgba(0.26, 0.54, 0.62, 0.17),
        },
    },
}

-- New palettes are based on a complete shipped preset, then fully materialized.
-- This keeps every color role defined while allowing closely related families
-- to share sensible neutral and status colors.
local function derivedPreset(baseKey, name, overrides)
    local colors = deepCopy(DMC.appearanceDefaults.colors)
    for key, color in pairs((COLOR_PRESETS[baseKey] and COLOR_PRESETS[baseKey].colors) or {}) do
        colors[key] = deepCopy(color)
    end
    for key, color in pairs(overrides or {}) do
        colors[key] = deepCopy(color)
    end
    return {name = name, colors = colors}
end

COLOR_PRESETS.duskLilac = derivedPreset("roseVelvet", "Dusk Lilac", {
    bg = rgba(0.010, 0.009, 0.014, 1),
    mainSurface = rgba(0.009, 0.008, 0.013, 0.95),
    header = rgba(0.057, 0.043, 0.074, 1),
    panel = rgba(0.021, 0.019, 0.027, 1),
    panel2 = rgba(0.026, 0.023, 0.033, 1),
    section = rgba(0.064, 0.051, 0.082, 1),
    sectionAlt = rgba(0.052, 0.043, 0.068, 1),
    row = rgba(0.032, 0.029, 0.039, 1),
    rowHover = rgba(0.057, 0.049, 0.071, 1),
    rowSelected = rgba(0.098, 0.074, 0.132, 1),
    rowSelectedText = rgba(0.89, 0.78, 0.96, 1),
    bossRow = rgba(0.024, 0.022, 0.030, 0.72),
    bossRowHover = rgba(0.061, 0.052, 0.076, 0.96),
    bossChevronActive = rgba(0.84, 0.72, 0.94, 1),
    pill = rgba(0.057, 0.046, 0.073, 1),
    pillHover = rgba(0.092, 0.070, 0.122, 1),
    pillPressed = rgba(0.112, 0.079, 0.151, 1),
    pillSelected = rgba(0.130, 0.089, 0.177, 1),
    pillPrimaryHover = rgba(0.166, 0.111, 0.224, 1),
    pillDisabled = rgba(0.032, 0.029, 0.039, 1),
    segment = rgba(0.036, 0.032, 0.045, 1),
    segmentHover = rgba(0.071, 0.057, 0.092, 1),
    segmentPressed = rgba(0.094, 0.068, 0.125, 1),
    segmentSelected = rgba(0.113, 0.078, 0.153, 1),
    pillEdge = rgba(0.46, 0.37, 0.58, 0.94),
    pillHoverEdge = rgba(0.65, 0.52, 0.78, 1),
    pillSelectedEdge = rgba(0.82, 0.69, 0.94, 1),
    pillDisabledEdge = rgba(0.27, 0.23, 0.34, 0.74),
    iconPill = rgba(0.041, 0.035, 0.052, 0.84),
    iconPillHover = rgba(0.082, 0.063, 0.108, 0.96),
    iconPillEdge = rgba(0.39, 0.31, 0.50, 0.84),
    title = rgba(0.84, 0.71, 0.94, 1),
    sectionTitle = rgba(0.76, 0.70, 0.84, 1),
    gold = rgba(0.91, 0.77, 0.68, 1),
    mechanic = rgba(0.035, 0.031, 0.044, 1),
    mechanicAlt = rgba(0.022, 0.020, 0.027, 1),
    mechanicHeader = rgba(0.058, 0.045, 0.071, 1),
    mechanicAction = rgba(0.018, 0.016, 0.022, 0.96),
    mechanicHeaderRule = rgba(0.63, 0.49, 0.70, 0.46),
    mechanicBottomRule = rgba(0.29, 0.23, 0.36, 0.27),
    mechanicAccent = rgba(0.68, 0.52, 0.77, 0.84),
    structuralRule = rgba(0.42, 0.34, 0.53, 0.58),
    passiveRule = rgba(0.29, 0.24, 0.37, 0.42),
    fieldEdge = rgba(0.48, 0.39, 0.59, 0.88),
    fieldFocus = rgba(0.75, 0.62, 0.87, 1),
    edge = rgba(0.65, 0.52, 0.77, 0.94),
    edgeDim = rgba(0.39, 0.32, 0.49, 0.96),
    search = rgba(0.017, 0.015, 0.021, 1),
    searchHover = rgba(0.030, 0.026, 0.038, 1),
    searchFocus = rgba(0.044, 0.036, 0.055, 1),
    noteSurface = rgba(0.019, 0.017, 0.024, 1),
    groupSurface = rgba(0.015, 0.014, 0.019, 1),
    hintSurface = rgba(0.021, 0.018, 0.027, 0.98),
    hintEdge = rgba(0.42, 0.34, 0.53, 0.88),
    closeHover = rgba(0.86, 0.74, 0.95, 1),
    artworkLeft = rgba(0.20, 0.17, 0.25, 0.07),
    artworkRight = rgba(0.40, 0.33, 0.48, 0.17),
})

COLOR_PRESETS.bloodMoon = derivedPreset("ember", "Blood Moon", {
    bg = rgba(0.014, 0.006, 0.008, 1),
    mainSurface = rgba(0.012, 0.005, 0.007, 0.95),
    header = rgba(0.092, 0.019, 0.029, 1),
    panel = rgba(0.030, 0.013, 0.017, 1),
    panel2 = rgba(0.039, 0.016, 0.021, 1),
    section = rgba(0.083, 0.024, 0.034, 1),
    sectionAlt = rgba(0.061, 0.020, 0.028, 1),
    row = rgba(0.047, 0.019, 0.025, 1),
    rowHover = rgba(0.084, 0.028, 0.040, 1),
    rowSelected = rgba(0.142, 0.036, 0.054, 1),
    rowText = rgba(0.86, 0.80, 0.80, 1),
    rowSelectedText = rgba(1.00, 0.72, 0.75, 1),
    bossRow = rgba(0.034, 0.014, 0.019, 0.72),
    bossRowHover = rgba(0.086, 0.029, 0.041, 0.96),
    bossText = rgba(0.86, 0.81, 0.81, 1),
    bossHoverText = rgba(0.98, 0.93, 0.92, 1),
    bossChevronActive = rgba(1.00, 0.56, 0.62, 1),
    pill = rgba(0.084, 0.026, 0.038, 1),
    pillHover = rgba(0.132, 0.034, 0.050, 1),
    pillPressed = rgba(0.157, 0.035, 0.055, 1),
    pillSelected = rgba(0.181, 0.039, 0.061, 1),
    pillPrimaryHover = rgba(0.225, 0.050, 0.073, 1),
    pillDisabled = rgba(0.038, 0.020, 0.023, 1),
    segment = rgba(0.047, 0.020, 0.027, 1),
    segmentHover = rgba(0.085, 0.027, 0.039, 1),
    segmentPressed = rgba(0.116, 0.030, 0.046, 1),
    segmentSelected = rgba(0.143, 0.033, 0.051, 1),
    pillEdge = rgba(0.65, 0.20, 0.28, 0.94),
    pillHoverEdge = rgba(0.88, 0.31, 0.40, 1),
    pillSelectedEdge = rgba(1.00, 0.54, 0.60, 1),
    pillDisabledEdge = rgba(0.34, 0.13, 0.18, 0.74),
    iconPill = rgba(0.049, 0.020, 0.027, 0.84),
    iconPillHover = rgba(0.108, 0.030, 0.045, 0.96),
    iconPillEdge = rgba(0.54, 0.17, 0.24, 0.84),
    buttonText = rgba(0.90, 0.84, 0.83, 1),
    buttonHoverText = rgba(1.00, 0.96, 0.95, 1),
    buttonPressedText = rgba(1.00, 0.70, 0.73, 1),
    title = rgba(1.00, 0.58, 0.63, 1),
    sectionTitle = rgba(0.91, 0.70, 0.70, 1),
    text = rgba(0.97, 0.93, 0.91, 1),
    bodyText = rgba(0.90, 0.85, 0.83, 1),
    bodyTextSoft = rgba(0.81, 0.75, 0.74, 1),
    muted = rgba(0.67, 0.57, 0.58, 1),
    quiet = rgba(0.49, 0.39, 0.41, 1),
    gold = rgba(0.92, 0.79, 0.61, 1),
    mechanic = rgba(0.052, 0.019, 0.026, 1),
    mechanicAlt = rgba(0.028, 0.011, 0.016, 1),
    mechanicHeader = rgba(0.077, 0.025, 0.034, 1),
    mechanicAction = rgba(0.022, 0.008, 0.012, 0.96),
    mechanicHeaderRule = rgba(0.76, 0.28, 0.35, 0.50),
    mechanicBottomRule = rgba(0.39, 0.12, 0.18, 0.27),
    mechanicAccent = rgba(0.93, 0.30, 0.39, 0.86),
    structuralRule = rgba(0.58, 0.17, 0.24, 0.58),
    passiveRule = rgba(0.42, 0.13, 0.18, 0.43),
    fieldEdge = rgba(0.62, 0.19, 0.27, 0.88),
    fieldFocus = rgba(0.96, 0.39, 0.47, 1),
    edge = rgba(0.87, 0.27, 0.36, 0.94),
    edgeDim = rgba(0.53, 0.16, 0.23, 0.96),
    search = rgba(0.019, 0.007, 0.011, 1),
    searchHover = rgba(0.035, 0.012, 0.017, 1),
    searchFocus = rgba(0.051, 0.015, 0.022, 1),
    searchText = rgba(0.94, 0.89, 0.88, 1),
    noteSurface = rgba(0.023, 0.008, 0.012, 1),
    groupSurface = rgba(0.015, 0.005, 0.008, 1),
    hintSurface = rgba(0.027, 0.009, 0.014, 0.98),
    hintEdge = rgba(0.56, 0.17, 0.24, 0.88),
    close = rgba(0.97, 0.93, 0.91, 1),
    closeHover = rgba(1.00, 0.58, 0.63, 1),
    artworkLeft = rgba(0.30, 0.10, 0.13, 0.07),
    artworkRight = rgba(0.61, 0.17, 0.23, 0.17),
})

COLOR_PRESETS.tidalTeal = derivedPreset("verdant", "Tidal Teal", {
    bg = rgba(0.003, 0.010, 0.012, 1),
    mainSurface = rgba(0.003, 0.009, 0.011, 0.95),
    header = rgba(0.008, 0.064, 0.071, 1),
    panel = rgba(0.006, 0.022, 0.025, 1),
    panel2 = rgba(0.008, 0.029, 0.032, 1),
    section = rgba(0.015, 0.063, 0.068, 1),
    sectionAlt = rgba(0.013, 0.048, 0.054, 1),
    row = rgba(0.012, 0.039, 0.043, 1),
    rowHover = rgba(0.019, 0.072, 0.078, 1),
    rowSelected = rgba(0.019, 0.117, 0.126, 1),
    rowText = rgba(0.80, 0.86, 0.87, 1),
    rowSelectedText = rgba(0.59, 0.98, 0.98, 1),
    bossRow = rgba(0.009, 0.030, 0.034, 0.72),
    bossRowHover = rgba(0.020, 0.078, 0.083, 0.96),
    bossText = rgba(0.80, 0.86, 0.87, 1),
    bossHoverText = rgba(0.94, 0.98, 0.98, 1),
    bossChevronActive = rgba(0.47, 0.94, 0.94, 1),
    pill = rgba(0.018, 0.074, 0.079, 1),
    pillHover = rgba(0.022, 0.116, 0.123, 1),
    pillPressed = rgba(0.018, 0.136, 0.144, 1),
    pillSelected = rgba(0.021, 0.158, 0.168, 1),
    pillPrimaryHover = rgba(0.027, 0.198, 0.210, 1),
    pillDisabled = rgba(0.012, 0.039, 0.042, 1),
    segment = rgba(0.011, 0.047, 0.051, 1),
    segmentHover = rgba(0.016, 0.084, 0.090, 1),
    segmentPressed = rgba(0.016, 0.105, 0.112, 1),
    segmentSelected = rgba(0.017, 0.126, 0.134, 1),
    pillEdge = rgba(0.11, 0.52, 0.55, 0.94),
    pillHoverEdge = rgba(0.22, 0.78, 0.80, 1),
    pillSelectedEdge = rgba(0.45, 0.93, 0.93, 1),
    pillDisabledEdge = rgba(0.08, 0.29, 0.31, 0.74),
    iconPill = rgba(0.010, 0.049, 0.053, 0.84),
    iconPillHover = rgba(0.017, 0.099, 0.105, 0.96),
    iconPillEdge = rgba(0.09, 0.43, 0.46, 0.84),
    title = rgba(0.45, 0.93, 0.93, 1),
    sectionTitle = rgba(0.61, 0.86, 0.85, 1),
    gold = rgba(0.88, 0.77, 0.55, 1),
    mechanic = rgba(0.014, 0.048, 0.052, 1),
    mechanicAlt = rgba(0.008, 0.028, 0.031, 1),
    mechanicHeader = rgba(0.018, 0.067, 0.071, 1),
    mechanicAction = rgba(0.006, 0.022, 0.025, 0.96),
    mechanicHeaderRule = rgba(0.38, 0.63, 0.65, 0.48),
    mechanicBottomRule = rgba(0.07, 0.31, 0.33, 0.25),
    mechanicAccent = rgba(0.31, 0.78, 0.78, 0.84),
    structuralRule = rgba(0.10, 0.49, 0.52, 0.58),
    passiveRule = rgba(0.08, 0.38, 0.41, 0.42),
    fieldEdge = rgba(0.12, 0.52, 0.55, 0.88),
    fieldFocus = rgba(0.28, 0.86, 0.87, 1),
    edge = rgba(0.17, 0.80, 0.81, 0.94),
    edgeDim = rgba(0.09, 0.45, 0.48, 0.96),
    search = rgba(0.005, 0.018, 0.020, 1),
    searchHover = rgba(0.008, 0.033, 0.036, 1),
    searchFocus = rgba(0.010, 0.045, 0.049, 1),
    searchText = rgba(0.89, 0.94, 0.94, 1),
    noteSurface = rgba(0.007, 0.023, 0.025, 1),
    groupSurface = rgba(0.004, 0.015, 0.017, 1),
    hintSurface = rgba(0.006, 0.025, 0.027, 0.98),
    hintEdge = rgba(0.10, 0.44, 0.47, 0.88),
    closeHover = rgba(0.45, 0.93, 0.93, 1),
    artworkLeft = rgba(0.09, 0.28, 0.29, 0.07),
    artworkRight = rgba(0.17, 0.53, 0.54, 0.17),
})

COLOR_PRESETS.silverMist = derivedPreset("moonlitSapphire", "Silver Mist", {
    bg = rgba(0.008, 0.009, 0.011, 1),
    mainSurface = rgba(0.007, 0.008, 0.010, 0.95),
    header = rgba(0.040, 0.045, 0.052, 1),
    panel = rgba(0.020, 0.023, 0.027, 1),
    panel2 = rgba(0.026, 0.029, 0.034, 1),
    section = rgba(0.054, 0.061, 0.070, 1),
    sectionAlt = rgba(0.044, 0.050, 0.058, 1),
    row = rgba(0.032, 0.036, 0.042, 1),
    rowHover = rgba(0.056, 0.063, 0.073, 1),
    rowSelected = rgba(0.092, 0.105, 0.121, 1),
    rowText = rgba(0.82, 0.85, 0.88, 1),
    rowSelectedText = rgba(0.90, 0.94, 0.97, 1),
    bossRow = rgba(0.024, 0.027, 0.032, 0.72),
    bossRowHover = rgba(0.060, 0.067, 0.078, 0.96),
    bossText = rgba(0.82, 0.85, 0.88, 1),
    bossHoverText = rgba(0.96, 0.97, 0.98, 1),
    bossChevronActive = rgba(0.79, 0.86, 0.91, 1),
    pill = rgba(0.058, 0.066, 0.076, 1),
    pillHover = rgba(0.093, 0.105, 0.120, 1),
    pillPressed = rgba(0.112, 0.126, 0.144, 1),
    pillSelected = rgba(0.130, 0.146, 0.167, 1),
    pillPrimaryHover = rgba(0.166, 0.184, 0.208, 1),
    pillDisabled = rgba(0.033, 0.037, 0.043, 1),
    segment = rgba(0.036, 0.041, 0.048, 1),
    segmentHover = rgba(0.070, 0.079, 0.091, 1),
    segmentPressed = rgba(0.092, 0.104, 0.119, 1),
    segmentSelected = rgba(0.111, 0.125, 0.143, 1),
    pillEdge = rgba(0.43, 0.50, 0.57, 0.94),
    pillHoverEdge = rgba(0.62, 0.69, 0.76, 1),
    pillSelectedEdge = rgba(0.78, 0.84, 0.89, 1),
    pillDisabledEdge = rgba(0.25, 0.29, 0.34, 0.74),
    iconPill = rgba(0.041, 0.047, 0.054, 0.84),
    iconPillHover = rgba(0.084, 0.095, 0.109, 0.96),
    iconPillEdge = rgba(0.36, 0.42, 0.48, 0.84),
    buttonText = rgba(0.86, 0.89, 0.92, 1),
    buttonHoverText = rgba(0.98, 0.99, 1.00, 1),
    buttonPressedText = rgba(0.88, 0.93, 0.96, 1),
    title = rgba(0.80, 0.86, 0.91, 1),
    sectionTitle = rgba(0.73, 0.78, 0.84, 1),
    text = rgba(0.96, 0.97, 0.98, 1),
    bodyText = rgba(0.88, 0.90, 0.92, 1),
    bodyTextSoft = rgba(0.79, 0.82, 0.85, 1),
    muted = rgba(0.61, 0.66, 0.71, 1),
    quiet = rgba(0.46, 0.51, 0.56, 1),
    gold = rgba(0.84, 0.76, 0.60, 1),
    mechanic = rgba(0.037, 0.042, 0.049, 1),
    mechanicAlt = rgba(0.021, 0.024, 0.029, 1),
    mechanicHeader = rgba(0.057, 0.064, 0.074, 1),
    mechanicAction = rgba(0.016, 0.018, 0.022, 0.96),
    mechanicHeaderRule = rgba(0.52, 0.58, 0.63, 0.48),
    mechanicBottomRule = rgba(0.26, 0.31, 0.36, 0.27),
    mechanicAccent = rgba(0.63, 0.69, 0.74, 0.84),
    structuralRule = rgba(0.39, 0.46, 0.52, 0.58),
    passiveRule = rgba(0.27, 0.33, 0.38, 0.42),
    fieldEdge = rgba(0.44, 0.51, 0.58, 0.88),
    fieldFocus = rgba(0.72, 0.80, 0.86, 1),
    edge = rgba(0.57, 0.66, 0.73, 0.94),
    edgeDim = rgba(0.35, 0.42, 0.48, 0.96),
    search = rgba(0.016, 0.018, 0.022, 1),
    searchHover = rgba(0.029, 0.033, 0.038, 1),
    searchFocus = rgba(0.042, 0.047, 0.054, 1),
    searchText = rgba(0.92, 0.94, 0.96, 1),
    noteSurface = rgba(0.019, 0.021, 0.025, 1),
    groupSurface = rgba(0.013, 0.015, 0.018, 1),
    hintSurface = rgba(0.020, 0.023, 0.027, 0.98),
    hintEdge = rgba(0.38, 0.45, 0.51, 0.88),
    close = rgba(0.96, 0.97, 0.98, 1),
    closeHover = rgba(0.82, 0.88, 0.92, 1),
    artworkLeft = rgba(0.18, 0.21, 0.24, 0.07),
    artworkRight = rgba(0.36, 0.42, 0.47, 0.17),
})

COLOR_PRESETS.sunsetCopper = derivedPreset("classicEso", "Sunset Copper", {
    bg = rgba(0.014, 0.009, 0.006, 1),
    mainSurface = rgba(0.012, 0.008, 0.005, 0.95),
    header = rgba(0.087, 0.045, 0.024, 1),
    panel = rgba(0.031, 0.020, 0.013, 1),
    panel2 = rgba(0.040, 0.026, 0.016, 1),
    section = rgba(0.078, 0.043, 0.025, 1),
    sectionAlt = rgba(0.060, 0.034, 0.022, 1),
    row = rgba(0.046, 0.029, 0.018, 1),
    rowHover = rgba(0.080, 0.047, 0.026, 1),
    rowSelected = rgba(0.128, 0.067, 0.031, 1),
    rowText = rgba(0.86, 0.81, 0.74, 1),
    rowSelectedText = rgba(0.98, 0.77, 0.55, 1),
    bossRow = rgba(0.034, 0.022, 0.014, 0.72),
    bossRowHover = rgba(0.083, 0.048, 0.027, 0.96),
    bossText = rgba(0.86, 0.81, 0.74, 1),
    bossHoverText = rgba(0.98, 0.94, 0.87, 1),
    bossChevronActive = rgba(0.95, 0.64, 0.39, 1),
    pill = rgba(0.076, 0.043, 0.024, 1),
    pillHover = rgba(0.124, 0.064, 0.031, 1),
    pillPressed = rgba(0.147, 0.070, 0.031, 1),
    pillSelected = rgba(0.169, 0.078, 0.032, 1),
    pillPrimaryHover = rgba(0.211, 0.097, 0.038, 1),
    pillDisabled = rgba(0.037, 0.025, 0.018, 1),
    segment = rgba(0.045, 0.028, 0.018, 1),
    segmentHover = rgba(0.082, 0.046, 0.025, 1),
    segmentPressed = rgba(0.109, 0.056, 0.027, 1),
    segmentSelected = rgba(0.133, 0.064, 0.029, 1),
    pillEdge = rgba(0.65, 0.34, 0.17, 0.94),
    pillHoverEdge = rgba(0.88, 0.47, 0.23, 1),
    pillSelectedEdge = rgba(0.96, 0.65, 0.39, 1),
    pillDisabledEdge = rgba(0.35, 0.19, 0.11, 0.74),
    iconPill = rgba(0.047, 0.029, 0.018, 0.84),
    iconPillHover = rgba(0.102, 0.054, 0.026, 0.96),
    iconPillEdge = rgba(0.55, 0.29, 0.15, 0.84),
    buttonText = rgba(0.89, 0.84, 0.77, 1),
    buttonHoverText = rgba(1.00, 0.97, 0.91, 1),
    buttonPressedText = rgba(0.98, 0.75, 0.51, 1),
    title = rgba(0.95, 0.67, 0.43, 1),
    sectionTitle = rgba(0.87, 0.72, 0.57, 1),
    text = rgba(0.97, 0.94, 0.89, 1),
    bodyText = rgba(0.89, 0.85, 0.79, 1),
    bodyTextSoft = rgba(0.80, 0.76, 0.69, 1),
    muted = rgba(0.66, 0.58, 0.50, 1),
    quiet = rgba(0.49, 0.41, 0.35, 1),
    gold = rgba(0.96, 0.74, 0.42, 1),
    mechanic = rgba(0.051, 0.030, 0.018, 1),
    mechanicAlt = rgba(0.028, 0.017, 0.011, 1),
    mechanicHeader = rgba(0.076, 0.039, 0.020, 1),
    mechanicAction = rgba(0.021, 0.012, 0.008, 0.96),
    mechanicHeaderRule = rgba(0.72, 0.39, 0.19, 0.50),
    mechanicBottomRule = rgba(0.39, 0.20, 0.09, 0.27),
    mechanicAccent = rgba(0.90, 0.48, 0.22, 0.86),
    structuralRule = rgba(0.57, 0.30, 0.15, 0.58),
    passiveRule = rgba(0.42, 0.22, 0.11, 0.43),
    fieldEdge = rgba(0.63, 0.33, 0.16, 0.88),
    fieldFocus = rgba(0.93, 0.52, 0.25, 1),
    edge = rgba(0.82, 0.43, 0.20, 0.94),
    edgeDim = rgba(0.50, 0.27, 0.14, 0.96),
    search = rgba(0.018, 0.010, 0.006, 1),
    searchHover = rgba(0.033, 0.018, 0.010, 1),
    searchFocus = rgba(0.048, 0.024, 0.012, 1),
    searchText = rgba(0.93, 0.89, 0.82, 1),
    noteSurface = rgba(0.022, 0.012, 0.008, 1),
    groupSurface = rgba(0.014, 0.008, 0.005, 1),
    hintSurface = rgba(0.026, 0.014, 0.008, 0.98),
    hintEdge = rgba(0.56, 0.29, 0.15, 0.88),
    close = rgba(0.97, 0.94, 0.89, 1),
    closeHover = rgba(0.95, 0.67, 0.43, 1),
    artworkLeft = rgba(0.29, 0.17, 0.09, 0.07),
    artworkRight = rgba(0.58, 0.31, 0.14, 0.17),
})

DMC.appearanceColorPresets = COLOR_PRESETS

local function replaceWithPresetColors(target, preset)
    replaceTable(target, DMC.appearanceDefaults.colors)
    for key, color in pairs((preset and preset.colors) or {}) do
        target[key] = deepCopy(color)
    end
end

local VALID_FACES = {
    ["$(MEDIUM_FONT)"] = true,
    ["$(BOLD_FONT)"] = true,
    ["$(CHAT_FONT)"] = true,
    ["$(GAMEPAD_LIGHT_FONT)"] = true,
    ["$(GAMEPAD_MEDIUM_FONT)"] = true,
    ["$(GAMEPAD_MEDIUM_FONT_LATIN)"] = true,
    ["$(GAMEPAD_BOLD_FONT)"] = true,
    ["$(ANTIQUE_FONT)"] = true,
    ["$(STONE_TABLET_FONT)"] = true,
    ["$(HANDWRITTEN_FONT)"] = true,
}

local VALID_STYLES = {
    [""] = true,
    ["soft-shadow-thin"] = true,
    ["soft-shadow-thick"] = true,
    ["thin-outline"] = true,
    ["outline"] = true,
    ["thick-outline"] = true,
}

local NUMBER_LIMITS = {
    bodySize = {13, 18},
    navigationSize = {16, 21},
    bossRowSize = {13, 17},
    sectionSize = {14, 19},
    activityTitleSize = {21, 28},
    bossTitleSize = {18, 24},
    compactSize = {11, 15},
    hintSize = {9, 13},
    windowScale = {85, 115},
    activityRowHeight = {27, 36},
    mechanicSpacing = {6, 22},
    artworkIntensity = {0, 180},
}

local function normalizeColor(value, fallback)
    value = type(value) == "table" and value or fallback
    local function component(candidate, defaultValue)
        return clamp(tonumber(candidate) or defaultValue, 0, 1)
    end
    return {
        component(value[1] ~= nil and value[1] or value.r, fallback[1]),
        component(value[2] ~= nil and value[2] or value.g, fallback[2]),
        component(value[3] ~= nil and value[3] or value.b, fallback[3]),
        component(value[4] ~= nil and value[4] or value.a, fallback[4] or 1),
    }
end

local function mergeDefaults(target, defaults)
    if type(target) ~= "table" then target = {} end
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            target[key] = mergeDefaults(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
    return target
end

function DMC.EnsureAppearanceSettings()
    if not DMC.sv then return DMC.appearanceDefaults end
    local storedAppearance = type(DMC.sv.appearance) == "table" and DMC.sv.appearance or nil
    local previousSchema = storedAppearance and tonumber(storedAppearance.schema) or 0
    local storedColors = storedAppearance and type(storedAppearance.colors) == "table" and storedAppearance.colors or nil
    local hadSectionTitle = storedColors and storedColors.sectionTitle ~= nil
    local previousTitle = storedColors and storedColors.title
    DMC.sv.appearance = mergeDefaults(DMC.sv.appearance, DMC.appearanceDefaults)
    local appearance = DMC.sv.appearance

    if not COLOR_PRESETS[appearance.preset] and appearance.preset ~= "custom" then
        appearance.preset = "custom"
    end

    -- Shipped palettes may gain new roles or be rebalanced when the appearance
    -- schema changes. Refresh a selected built-in preset on upgrade while
    -- leaving genuinely custom palettes untouched.
    if previousSchema < DMC.appearanceDefaults.schema
        and appearance.preset ~= "custom"
        and COLOR_PRESETS[appearance.preset] then
        replaceWithPresetColors(appearance.colors, COLOR_PRESETS[appearance.preset])
    elseif previousSchema < 3 and appearance.preset == "custom" and not hadSectionTitle then
        -- A pre-v0.8.13 custom palette had only one title role. Let the new
        -- section headings inherit that chosen accent instead of turning cyan.
        appearance.colors.sectionTitle = normalizeColor(previousTitle, DMC.appearanceDefaults.colors.sectionTitle)
    end
    appearance.schema = DMC.appearanceDefaults.schema

    local typography = appearance.typography
    local typographyDefaults = DMC.appearanceDefaults.typography
    for _, key in ipairs({"bodyFace", "headingFace", "navigationFace"}) do
        if not VALID_FACES[typography[key]] then typography[key] = typographyDefaults[key] end
    end
    for _, key in ipairs({"bodyStyle", "headingStyle"}) do
        if not VALID_STYLES[typography[key]] then typography[key] = typographyDefaults[key] end
    end
    for key, limits in pairs(NUMBER_LIMITS) do
        if typography[key] ~= nil then
            typography[key] = clamp(tonumber(typography[key]) or typographyDefaults[key], limits[1], limits[2])
        elseif appearance.layout[key] ~= nil then
            appearance.layout[key] = clamp(tonumber(appearance.layout[key]) or DMC.appearanceDefaults.layout[key], limits[1], limits[2])
        end
    end
    for key, fallback in pairs(DMC.appearanceDefaults.layout) do
        if type(fallback) == "boolean" and type(appearance.layout[key]) ~= "boolean" then
            appearance.layout[key] = fallback
        end
    end

    for key, fallback in pairs(DMC.appearanceDefaults.colors) do
        appearance.colors[key] = normalizeColor(appearance.colors[key], fallback)
    end
    return appearance
end

-- Settings are fully validated once during addon initialization and whenever an
-- explicit repair is requested. Ordinary UI reads stay intentionally cheap:
-- building hundreds of labels must not rescan and reallocate the whole palette.
local function getCurrentAppearance()
    if not DMC.sv then return DMC.appearanceDefaults end
    if type(DMC.sv.appearance) ~= "table" then
        return DMC.EnsureAppearanceSettings()
    end
    return DMC.sv.appearance
end

DMC.themeColors = DMC.themeColors or {}

function DMC.RefreshAppearanceCache()
    local appearance = getCurrentAppearance()
    for key, fallback in pairs(DMC.appearanceDefaults.colors) do
        local source = normalizeColor(appearance.colors and appearance.colors[key], fallback)
        local target = DMC.themeColors[key]
        if not target then
            target = {}
            DMC.themeColors[key] = target
        end
        target[1], target[2], target[3], target[4] = source[1], source[2], source[3], source[4]
    end
end

function DMC.GetAppearanceValue(section, key)
    local appearance = getCurrentAppearance()
    local values = appearance[section]
    if values and values[key] ~= nil then return values[key] end
    local defaults = DMC.appearanceDefaults[section]
    return defaults and defaults[key]
end

function DMC.GetAppearanceColor(key)
    return DMC.themeColors[key] or DMC.appearanceDefaults.colors[key] or {1, 1, 1, 1}
end

local FONT_ROLES = {
    body = {"bodyFace", "bodySize", "bodyStyle"},
    meta = {"bodyFace", "compactSize", "bodyStyle"},
    metaBold = {"headingFace", "compactSize", "bodyStyle"},
    bossRow = {"headingFace", "bossRowSize", "bodyStyle"},
    section = {"headingFace", "sectionSize", "bodyStyle"},
    sectionSmall = {"headingFace", "sectionSize", "bodyStyle", -1},
    ui = {"navigationFace", "navigationSize", "bodyStyle"},
    uiBold = {"headingFace", "navigationSize", "bodyStyle"},
    uiSmall = {"headingFace", "compactSize", "bodyStyle"},
    h2 = {"headingFace", "activityTitleSize", "headingStyle"},
    h3 = {"headingFace", "bossTitleSize", "headingStyle"},
    hint = {"bodyFace", "hintSize", "bodyStyle"},
}
DMC.appearanceFontRoles = FONT_ROLES

function DMC.GetAppearanceFont(role)
    local definition = FONT_ROLES[role]
    if not definition then return role end
    local appearance = getCurrentAppearance()
    local typography = type(appearance.typography) == "table"
        and appearance.typography or DMC.appearanceDefaults.typography
    local face = typography[definition[1]] or DMC.appearanceDefaults.typography[definition[1]]
    local size = (typography[definition[2]] or DMC.appearanceDefaults.typography[definition[2]]) + (definition[4] or 0)
    local style = typography[definition[3]] or ""
    local font = tostring(face) .. "|" .. tostring(math.floor(size + 0.5))
    if style ~= "" then font = font .. "|" .. style end
    return font
end

function DMC.GetActivityRowHeight()
    return math.floor(DMC.GetAppearanceValue("layout", "activityRowHeight") + 0.5)
end

function DMC.GetMechanicSpacing()
    return math.floor(DMC.GetAppearanceValue("layout", "mechanicSpacing") + 0.5)
end

function DMC.ShouldShowAppearanceElement(key)
    return DMC.GetAppearanceValue("layout", key) ~= false
end

function DMC.GetArtworkIntensity()
    return DMC.GetAppearanceValue("layout", "artworkIntensity") / 100
end

function DMC.ApplyAppearanceSettings(reflow)
    DMC.RefreshAppearanceCache()
    if DMC.ApplyAppearanceToUI then DMC.ApplyAppearanceToUI(reflow == true) end
end

function DMC.ScheduleAppearanceApply(reflow)
    DMC._appearanceNeedsReflow = DMC._appearanceNeedsReflow or reflow == true
    if DMC._appearanceApplyPending then return end
    DMC._appearanceApplyPending = true
    zo_callLater(function()
        local needsReflow = DMC._appearanceNeedsReflow
        DMC._appearanceNeedsReflow = false
        DMC._appearanceApplyPending = false
        DMC.ApplyAppearanceSettings(needsReflow)
    end, 0)
end

function DMC.ApplyColorPreset(presetKey)
    local preset = COLOR_PRESETS[presetKey]
    if not preset or not DMC.sv then return false end
    local appearance = DMC.EnsureAppearanceSettings()
    replaceWithPresetColors(appearance.colors, preset)
    appearance.preset = presetKey
    DMC.ScheduleAppearanceApply(false)
    return true
end

function DMC.ResetAppearanceSection(section)
    if not DMC.sv or not DMC.appearanceDefaults[section] then return end
    local appearance = DMC.EnsureAppearanceSettings()
    replaceTable(appearance[section], DMC.appearanceDefaults[section])
    if section == "colors" then appearance.preset = "flamechasers" end
    DMC.ScheduleAppearanceApply(section == "typography" or section == "layout")
end

function DMC.ResetAllAppearanceSettings()
    if not DMC.sv then return end
    DMC.sv.appearance = deepCopy(DMC.appearanceDefaults)
    DMC.ScheduleAppearanceApply(true)
end

function DMC.InitializeAppearance()
    DMC.EnsureAppearanceSettings()
    DMC.RefreshAppearanceCache()
end

-- Prime the palette while files are loading. It is refreshed from SavedVariables
-- before the UI is constructed during EVENT_ADD_ON_LOADED.
DMC.RefreshAppearanceCache()
DMC.defaultSavedVars.appearance = deepCopy(DMC.appearanceDefaults)

local function refreshSettingsPanel()
    if DMC.settingsPanel and DMC.settingsPanel.RefreshPanel then
        DMC.settingsPanel:RefreshPanel()
    end
end

local function markCustom()
    local appearance = getCurrentAppearance()
    if appearance.preset == "custom" then return end
    appearance.preset = "custom"
    -- Keep the preset dropdown truthful after an individual color change.
    -- Defer one frame so LibAddonMenu can finish the color-picker callback.
    zo_callLater(refreshSettingsPanel, 0)
end

local function setValue(section, key, value, reflow)
    local appearance = getCurrentAppearance()
    if type(appearance[section]) ~= "table" then
        appearance = DMC.EnsureAppearanceSettings()
    end
    appearance[section][key] = value
    DMC.ScheduleAppearanceApply(reflow)
end

local function makeDropdown(name, tooltip, key, choices, values, default, reflow)
    return {
        type = "dropdown",
        name = name,
        tooltip = tooltip,
        choices = choices,
        choicesValues = values,
        getFunc = function() return DMC.GetAppearanceValue("typography", key) end,
        setFunc = function(value) setValue("typography", key, value, reflow) end,
        default = default,
        width = "full",
        dmcSection = "typography",
        dmcKey = key,
    }
end

local function makeSlider(name, tooltip, section, key, minimum, maximum, step, default, reflow, disabled)
    return {
        type = "slider",
        name = name,
        tooltip = tooltip,
        min = minimum,
        max = maximum,
        step = step,
        getFunc = function() return DMC.GetAppearanceValue(section, key) end,
        setFunc = function(value) setValue(section, key, value, reflow) end,
        default = default,
        width = "full",
        disabled = disabled,
        dmcSection = section,
        dmcKey = key,
    }
end

local function makeCheckbox(name, tooltip, key, default, reflow)
    return {
        type = "checkbox",
        name = name,
        tooltip = tooltip,
        getFunc = function() return DMC.GetAppearanceValue("layout", key) end,
        setFunc = function(value) setValue("layout", key, value, reflow) end,
        default = default,
        width = "full",
        dmcSection = "layout",
        dmcKey = key,
    }
end

-- ESO's inline |cRRGGBB markup has no alpha channel. These four colors are
-- embedded into mixed-color list labels, so their picker must not promise an
-- opacity setting the client cannot render.
local RGB_ONLY_COLORS = {
    bossFlagText = true,
    bossChevron = true,
    bossChevronActive = true,
    stubText = true,
}

local function makeColorOption(name, tooltip, key)
    local default = DMC.appearanceDefaults.colors[key]
    local supportsAlpha = not RGB_ONLY_COLORS[key]
    return {
        type = "colorpicker",
        name = name,
        tooltip = tooltip,
        getFunc = function()
            local appearance = getCurrentAppearance()
            local color = appearance.colors and appearance.colors[key] or default
            if supportsAlpha then return color[1], color[2], color[3], color[4] end
            return color[1], color[2], color[3]
        end,
        setFunc = function(r, g, b, a)
            local appearance = getCurrentAppearance()
            if type(appearance.colors) ~= "table" then
                appearance = DMC.EnsureAppearanceSettings()
            end
            appearance.colors[key] = normalizeColor({r, g, b, supportsAlpha and a or default[4]}, default)
            markCustom()
            DMC.ScheduleAppearanceApply(false)
        end,
        default = supportsAlpha
            and {r = default[1], g = default[2], b = default[3], a = default[4]}
            or {r = default[1], g = default[2], b = default[3]},
        width = "full",
        dmcSection = "colors",
        dmcKey = key,
        dmcSupportsAlpha = supportsAlpha,
    }
end

local function makeColorSubmenu(name, tooltip, definitions)
    local controls = {}
    for _, definition in ipairs(definitions) do
        controls[#controls + 1] = makeColorOption(definition[1], definition[2], definition[3])
    end
    return {type = "submenu", name = name, tooltip = tooltip, controls = controls}
end

function DMC.RegisterSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        DMC.Print("LibAddonMenu-2.0 is required for appearance settings.")
        return
    end

    local panelId = "DungeonMechsCodexSettings"
    local panelData = {
        type = "panel",
        name = "Flamechasers Codex",
        displayName = "|c66D9EFFlamechasers Dungeon, Trial & Arena Codex|r",
        author = "Flamechasers",
        version = DMC.version,
        keywords = "dungeon trial arena codex appearance theme colors fonts UI",
        slashCommand = "/dmcsettings",
        registerForRefresh = true,
        registerForDefaults = true,
        resetFunc = function() DMC.ResetAllAppearanceSettings() end,
    }
    DMC.settingsPanel = LAM:RegisterAddonPanel(panelId, panelData)

    local defaults = DMC.appearanceDefaults
    local fontChoices = {
        "Univers Condensed", "Univers Bold", "Chat / Locale", "Futura Light",
        "Futura Medium", "Futura Medium (Latin)", "Futura Bold", "Antique",
        "Stone Tablet", "Handwritten",
    }
    local fontValues = {
        "$(MEDIUM_FONT)", "$(BOLD_FONT)", "$(CHAT_FONT)", "$(GAMEPAD_LIGHT_FONT)",
        "$(GAMEPAD_MEDIUM_FONT)", "$(GAMEPAD_MEDIUM_FONT_LATIN)", "$(GAMEPAD_BOLD_FONT)",
        "$(ANTIQUE_FONT)", "$(STONE_TABLET_FONT)", "$(HANDWRITTEN_FONT)",
    }
    local styleChoices = {"None", "Soft Shadow", "Strong Shadow", "Thin Outline", "Outline", "Thick Outline"}
    local styleValues = {"", "soft-shadow-thin", "soft-shadow-thick", "thin-outline", "outline", "thick-outline"}

    local presetChoices, presetValues = {"Custom (keep current colors)"}, {"custom"}
    for _, key in ipairs({
        "flamechasers", "midnight", "roseVelvet", "duskLilac", "classicEso",
        "moonlitSapphire", "tidalTeal", "bloodMoon", "sunsetCopper",
        "silverMist", "ember", "verdant", "highContrast",
    }) do
        presetChoices[#presetChoices + 1] = COLOR_PRESETS[key].name
        presetValues[#presetValues + 1] = key
    end

    local options = {
        {
            type = "description",
            title = "Live UI Workshop",
            text = "Every option updates the Codex live and is account-wide. The shipped v0.7.2 design is preserved as Flamechasers (Default). Font sizes and layout controls use tested limits so content remains usable. If a custom palette becomes difficult to read, return here and restore a preset.",
        },
        {
            type = "dropdown",
            name = "Color preset",
            tooltip = "Applies a complete, readability-tested palette across backgrounds, buttons, selectors, mechanic accents, fields, and borders. Typography and layout are left untouched. Custom keeps the colors currently shown.",
            choices = presetChoices,
            choicesValues = presetValues,
            getFunc = function() return getCurrentAppearance().preset or "custom" end,
            setFunc = function(value)
                if value == "custom" then
                    getCurrentAppearance().preset = "custom"
                else
                    DMC.ApplyColorPreset(value)
                end
            end,
            default = "flamechasers",
            width = "full",
        },
        {
            type = "button",
            name = "Restore all defaults",
            tooltip = "Resets colors, fonts, sizing, density, and decorative visibility. Boss notes and window position are never touched.",
            func = function()
                DMC.ResetAllAppearanceSettings()
                refreshSettingsPanel()
            end,
            width = "full",
        },
        {type = "header", name = "Typography"},
        {
            type = "submenu",
            name = "Font families and effects",
            tooltip = "Choose independent font faces for reading, navigation, and headings.",
            controls = {
                makeDropdown("Body font", "Boss summaries, mechanics, and personal notes.", "bodyFace", fontChoices, fontValues, defaults.typography.bodyFace, true),
                makeDropdown("Heading font", "Activity names, boss names, section labels, and emphasized controls.", "headingFace", fontChoices, fontValues, defaults.typography.headingFace, true),
                makeDropdown("Navigation font", "Activity-list rows and other browsing text.", "navigationFace", fontChoices, fontValues, defaults.typography.navigationFace, true),
                makeDropdown("Body text effect", "Shadow or outline applied to body, compact, and navigation text.", "bodyStyle", styleChoices, styleValues, defaults.typography.bodyStyle, true),
                makeDropdown("Large heading effect", "Shadow or outline applied to activity and selected-boss titles.", "headingStyle", styleChoices, styleValues, defaults.typography.headingStyle, true),
            },
        },
        {
            type = "submenu",
            name = "Font sizes",
            tooltip = "Fine-tune each text tier inside safe layout bounds.",
            controls = {
                makeSlider("Body text", "Mechanic, summary, and note text size.", "typography", "bodySize", 13, 18, 1, defaults.typography.bodySize, true),
                makeSlider("Activity list", "Dungeon, trial, and arena row text size.", "typography", "navigationSize", 16, 21, 1, defaults.typography.navigationSize, true),
                makeSlider("Boss list", "Boss-selection row text size.", "typography", "bossRowSize", 13, 17, 1, defaults.typography.bossRowSize, true),
                makeSlider("Section headings", "Activities, Bosses, Personal Notes, and Mechanics headings.", "typography", "sectionSize", 14, 19, 1, defaults.typography.sectionSize, true),
                makeSlider("Activity title", "Selected dungeon, trial, or arena name.", "typography", "activityTitleSize", 21, 28, 1, defaults.typography.activityTitleSize, true),
                makeSlider("Boss title", "Selected boss name.", "typography", "bossTitleSize", 18, 24, 1, defaults.typography.bossTitleSize, true),
                makeSlider("Compact labels", "Tabs, counters, metadata, and button labels.", "typography", "compactSize", 11, 15, 1, defaults.typography.compactSize, true),
                makeSlider("Hover hints", "Small Paste, Veteran, and Hard Mode hints.", "typography", "hintSize", 9, 13, 1, defaults.typography.hintSize, true),
            },
        },
        {
            type = "button",
            name = "Restore typography",
            func = function() DMC.ResetAppearanceSection("typography"); refreshSettingsPanel() end,
            width = "full",
        },
        {type = "header", name = "Layout and Decoration"},
        {
            type = "submenu",
            name = "Scale and density",
            controls = {
                makeSlider("Window scale", "Scales the complete Codex while preserving its internal proportions.", "layout", "windowScale", 85, 115, 1, defaults.layout.windowScale, false),
                makeCheckbox("Lock window position", "Prevents accidental dragging after the Codex has been placed. The Center Window recovery action remains available.", "lockWindowPosition", defaults.layout.lockWindowPosition, false),
                makeSlider("Activity row height", "Vertical spacing between activity-list entries.", "layout", "activityRowHeight", 27, 36, 1, defaults.layout.activityRowHeight, true),
                makeSlider("Mechanic card spacing", "Empty space separating adjacent mechanic cards.", "layout", "mechanicSpacing", 6, 22, 1, defaults.layout.mechanicSpacing, true),
                makeSlider("Splash-art intensity", "Controls the strength of the instance artwork behind the summary. The default keeps it clearly visible under a readability veil; zero hides it and higher values make it more vivid.", "layout", "artworkIntensity", 0, 180, 5, defaults.layout.artworkIntensity, false,
                    function() return not DMC.GetAppearanceValue("layout", "showArtwork") end),
            },
        },
        {
            type = "submenu",
            name = "Visible elements",
            tooltip = "Hide optional details without removing any mechanics or controls.",
            controls = {
                makeCheckbox("Instance splash art", "Show the selected activity artwork behind its summary.", "showArtwork", defaults.layout.showArtwork, false),
                makeCheckbox("Mechanic number badges", "Show 01, 02, 03… in mechanic-card headers.", "showMechanicNumbers", defaults.layout.showMechanicNumbers, false),
                makeCheckbox("Compact hover hints", "Show the small Paste, Veteran, and Hard Mode hints.", "showHoverHints", defaults.layout.showHoverHints, false),
                makeCheckbox("DLC and chapter labels", "Show the content release beside the activity title.", "showDlcTags", defaults.layout.showDlcTags, true),
                makeCheckbox("Header tagline", "Show Boss mechanics. Role-ready. Paste-ready. in the top header.", "showHeaderTagline", defaults.layout.showHeaderTagline, false),
                makeCheckbox("Section icons", "Show the restrained Activities, Bosses, Notes, and Mechanics glyphs.", "showSectionIcons", defaults.layout.showSectionIcons, true),
                makeCheckbox("Activity and mechanic counters", "Show collection totals, search-result totals, and mechanic entry totals.", "showCounters", defaults.layout.showCounters, true),
            },
        },
        {
            type = "button",
            name = "Restore layout",
            func = function() DMC.ResetAppearanceSection("layout"); refreshSettingsPanel() end,
            width = "full",
        },
        {
            type = "button",
            name = "Center Codex window",
            tooltip = "Returns the Codex to the center of the screen without changing its appearance or content.",
            func = function() if DMC.CenterWindow then DMC.CenterWindow() end end,
            width = "full",
        },
        {type = "header", name = "Colors"},
        {
            type = "description",
            text = "Opacity is available wherever ESO exposes an alpha channel. The four inline boss-list markup colors are RGB-only. Changing any individual color switches the preset label to Custom; it does not alter typography or layout.",
        },
        makeColorSubmenu("Brand and text", "Primary identity, readable text tiers, and status colors.", {
            {"Accent / major titles", "Brand name, activity and boss titles, and selected button text.", "title"},
            {"Section headings", "Activities, Bosses, Personal Notes, and Mechanics headings and glyphs.", "sectionTitle"},
            {"Primary text", "Main high-contrast UI text.", "text"},
            {"Body text", "Mechanic and summary text.", "bodyText"},
            {"Soft body text", "Personal-note editor and secondary reading text.", "bodyTextSoft"},
            {"Muted text", "Tagline and secondary metadata.", "muted"},
            {"Quiet text", "Counters, labels, and de-emphasized metadata.", "quiet"},
            {"Mechanic title accent", "Mechanic titles and their theme-specific content emphasis.", "gold"},
            {"Success / detected", "Saved state and automatically detected activity.", "ok"},
            {"Warning / unsaved", "Unsaved-note state and caution emphasis.", "warning"},
            {"Header action icons", "Settings and close buttons at rest.", "close"},
            {"Header action icon hover", "Settings or close button under the pointer.", "closeHover"},
        }),
        makeColorSubmenu("Window and section surfaces", "Large passive surfaces that establish the Codex hierarchy.", {
            {"Outer backdrop", "The outermost window backdrop.", "bg"},
            {"Body surface", "Continuous surface behind the main content.", "mainSurface"},
            {"Header", "Top Flamechasers header band.", "header"},
            {"Sidebar panel", "Activity-browser panel.", "panel"},
            {"Content panels", "Summary, bosses, notes, and mechanics panels.", "panel2"},
            {"Section header", "Primary section header bands.", "section"},
            {"Alternate section header", "Personal Notes header band.", "sectionAlt"},
            {"Segment-group surface", "Surface behind activity, difficulty, and role tabs.", "groupSurface"},
        }),
        makeColorSubmenu("Activity and boss lists", "Idle, hover, selected, and auto-detected list states.", {
            {"Activity row", "Idle activity-list row.", "row"},
            {"Activity row hover", "Activity row under the pointer.", "rowHover"},
            {"Selected row", "Selected activity and boss background.", "rowSelected"},
            {"Activity row text", "Idle activity name.", "rowText"},
            {"Selected row text", "Selected activity and boss name.", "rowSelectedText"},
            {"Detected activity surface", "Activity that matches the player's current instance.", "currentRow"},
            {"Detected activity text", "Automatically detected activity name.", "currentText"},
            {"Boss row", "Idle boss-selection surface.", "bossRow"},
            {"Boss row hover", "Boss-selection surface under the pointer.", "bossRowHover"},
            {"Boss row text", "Idle boss name.", "bossText"},
            {"Boss row hover text", "Boss name under the pointer.", "bossHoverText"},
            {"Boss flags", "Main, Final, and Secret metadata beside boss names.", "bossFlagText"},
            {"Boss chevron", "Idle arrow before each boss name.", "bossChevron"},
            {"Active boss chevron", "Selected or hovered arrow before a boss name.", "bossChevronActive"},
            {"Dataset-stub text", "Stub marker used by future incomplete activity entries.", "stubText"},
        }),
        makeColorSubmenu("Buttons and selectors", "Complete interactive-state palette for actions and segmented selectors.", {
            {"Button surface", "Idle Save, Revert, and Paste surface.", "pill"},
            {"Button hover", "Action button under the pointer.", "pillHover"},
            {"Button pressed", "Action button while pressed.", "pillPressed"},
            {"Button selected / primary", "Selected or primary action surface.", "pillSelected"},
            {"Primary hover", "Enabled Save button under the pointer.", "pillPrimaryHover"},
            {"Disabled button", "Unavailable action surface.", "pillDisabled"},
            {"Selector surface", "Idle activity, difficulty, and view segment.", "segment"},
            {"Selector hover", "Selector segment under the pointer.", "segmentHover"},
            {"Selector pressed", "Selector segment while pressed.", "segmentPressed"},
            {"Selector selected", "Active selector segment.", "segmentSelected"},
            {"Button border", "Idle action and selector group border.", "pillEdge"},
            {"Button hover border", "Hovered action border.", "pillHoverEdge"},
            {"Selected button border", "Selected and primary action border.", "pillSelectedEdge"},
            {"Disabled button border", "Unavailable action border.", "pillDisabledEdge"},
            {"Button text", "Idle action and selector label.", "buttonText"},
            {"Button hover text", "Raw list-button text under the pointer.", "buttonHoverText"},
            {"Button pressed text", "Raw list-button text while pressed.", "buttonPressedText"},
            {"Disabled button text", "Unavailable action label.", "buttonDisabledText"},
            {"Paste button surface", "Idle icon-only Paste button.", "iconPill"},
            {"Paste button hover", "Icon-only Paste button under the pointer.", "iconPillHover"},
            {"Paste button border", "Idle icon-only Paste button border.", "iconPillEdge"},
        }),
        makeColorSubmenu("Mechanic cards", "Card surfaces, headers, action rail, and theme-specific separation cues.", {
            {"Odd card surface", "First, third, fifth… mechanic cards.", "mechanic"},
            {"Even card surface", "Second, fourth, sixth… mechanic cards.", "mechanicAlt"},
            {"Card header", "Mechanic-title strip.", "mechanicHeader"},
            {"Paste-action rail", "Right-side Paste action column.", "mechanicAction"},
            {"Header rule", "Theme-colored divider beneath each mechanic title.", "mechanicHeaderRule"},
            {"Bottom rule", "Very quiet lower edge of each mechanic card.", "mechanicBottomRule"},
            {"Mechanic accent rail", "Vertical identity rail on each mechanic card.", "mechanicAccent"},
        }),
        makeColorSubmenu("Borders, fields, and hints", "Structural lines, edit fields, tooltip surfaces, and the outer signature frame.", {
            {"Outer signature frame", "Bright frame around the complete addon window.", "edge"},
            {"Dim frame", "Secondary passive frame color.", "edgeDim"},
            {"Structural dividers", "Major column and header separation.", "structuralRule"},
            {"Passive dividers", "Low-emphasis internal separation.", "passiveRule"},
            {"Field border", "Idle search and personal-note border.", "fieldEdge"},
            {"Focused field border", "Search or note field with keyboard focus.", "fieldFocus"},
            {"Search field", "Idle search surface.", "search"},
            {"Search field hover", "Search surface under the pointer.", "searchHover"},
            {"Search field focus", "Search surface while typing.", "searchFocus"},
            {"Search text", "Typed search text.", "searchText"},
            {"Personal-note field", "Note editor surface.", "noteSurface"},
            {"Hover-hint surface", "Small in-addon Paste and mode hint background.", "hintSurface"},
            {"Hover-hint border", "Small in-addon hint frame.", "hintEdge"},
        }),
        makeColorSubmenu("Splash artwork tint", "Two-color overlay used to keep instance artwork subtle and readable.", {
            {"Artwork left tint", "Tint and visibility weighting at the left side of the summary artwork.", "artworkLeft"},
            {"Artwork right tint", "Tint and visibility weighting at the right side of the summary artwork.", "artworkRight"},
        }),
        {
            type = "button",
            name = "Restore colors",
            func = function() DMC.ResetAppearanceSection("colors"); refreshSettingsPanel() end,
            width = "full",
        },
        {type = "divider"},
        {
            type = "description",
            text = "Tip: /dmc opens the Codex and /dmcsettings opens this workshop directly. Appearance resets never touch boss notes, selected difficulty, or window position.",
        },
    }

    DMC.settingsOptions = options
    LAM:RegisterOptionControls(panelId, options)
end

function DMC.OpenSettings()
    local LAM = LibAddonMenu2
    if LAM and DMC.settingsPanel then LAM:OpenToPanel(DMC.settingsPanel) end
end
