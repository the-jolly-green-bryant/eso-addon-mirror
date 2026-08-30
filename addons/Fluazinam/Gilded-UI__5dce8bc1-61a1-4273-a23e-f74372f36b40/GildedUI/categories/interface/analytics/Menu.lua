if not GildedUI then return end

local Addon = GildedUI

Addon:RegisterMenuSection(function(menu, H)
    local sv = Addon.state.sv
    local controls = {
        { type = "header", name = "General" },
        H.Toggle(
            "Show Analytics in this menu",
            function() return sv.showInMenu end,
            function(v)
                sv.showInMenu = v
                Addon:UpdateVisibility()
            end,
            Addon.defaults.showInMenu
        ),
        { type = "header", name = "Monitoring" },
    }

    local function MetricSubmenu(name, options)
        local page = {
            H.Toggle(
                options.enableName,
                function() return sv[options.showKey] end,
                function(v) options.setEnabled(v) end,
                Addon.defaults[options.showKey]
            ),
            H.FontSizeDropdown(options.fontKey),
        }
        H.Append(page, H.BackgroundControls(options.backgroundKey, options.paddingKey, options.opacityKey))
        H.Append(page, H.PositionSliders(
            options.xName,
            options.yName,
            options.posXKey,
            options.posYKey,
            options.applyPosition
        ))
        H.Append(page, H.ColorTier(
            options.useColorsKey,
            options.goodName,
            options.midName,
            options.lowName,
            options.goodKey,
            options.midKey,
            options.lowKey
        ))
        return {
            type = "submenu",
            name = name,
            options = page,
        }
    end

    controls[#controls + 1] = MetricSubmenu("FPS", {
        enableName = "Enable FPS",
        showKey = "showFPS",
        setEnabled = function(v) Addon:SetFPSEnabled(v) end,
        fontKey = "fpsFontSize",
        backgroundKey = "fpsShowBackground",
        paddingKey = "fpsShowPadding",
        opacityKey = "fpsBackgroundOpacity",
        posXKey = "fpsPosX",
        posYKey = "fpsPosY",
        xName = "FPS X Position",
        yName = "FPS Y Position",
        applyPosition = function() Addon:ApplyFPSPosition() end,
        useColorsKey = "fpsUseColors",
        goodName = "Good (45+ FPS)",
        midName = "Acceptable (30-44 FPS)",
        lowName = "Bad (0-29 FPS)",
        goodKey = "fpsColorGood",
        midKey = "fpsColorMid",
        lowKey = "fpsColorLow",
    })
    controls[#controls + 1] = MetricSubmenu("Ping", {
        enableName = "Enable Ping",
        showKey = "showPing",
        setEnabled = function(v) Addon:SetPingEnabled(v) end,
        fontKey = "pingFontSize",
        backgroundKey = "pingShowBackground",
        paddingKey = "pingShowPadding",
        opacityKey = "pingBackgroundOpacity",
        posXKey = "pingPosX",
        posYKey = "pingPosY",
        xName = "Ping X Position",
        yName = "Ping Y Position",
        applyPosition = function() Addon:ApplyPingPosition() end,
        useColorsKey = "pingUseColors",
        goodName = "Good (0-149 ms)",
        midName = "Acceptable (150-249 ms)",
        lowName = "Bad (250+ ms)",
        goodKey = "pingColorGood",
        midKey = "pingColorMid",
        lowKey = "pingColorLow",
    })
    controls[#controls + 1] = MetricSubmenu("Memory", {
        enableName = "Enable Memory",
        showKey = "showMemory",
        setEnabled = function(v) Addon:SetMemoryEnabled(v) end,
        fontKey = "memFontSize",
        backgroundKey = "memShowBackground",
        paddingKey = "memShowPadding",
        opacityKey = "memBackgroundOpacity",
        posXKey = "memPosX",
        posYKey = "memPosY",
        xName = "Memory X Position",
        yName = "Memory Y Position",
        applyPosition = function() Addon:ApplyMemoryPosition() end,
        useColorsKey = "memUseColors",
        goodName = "Good (under 50 MB)",
        midName = "Acceptable (50-69 MB)",
        lowName = "Bad (70+ MB)",
        goodKey = "memColorGood",
        midKey = "memColorMid",
        lowKey = "memColorLow",
    })

    menu:AddOptions({
        {
            type = "submenu",
            name = "Analytics",
            align = "leftIndent",
            icon = "/esoui/art/menubar/gamepad/gp_playermenu_icon_terms.dds",
            options = controls,
        },
    })
end)
