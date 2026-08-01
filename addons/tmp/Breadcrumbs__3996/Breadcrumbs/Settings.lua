Breadcrumbs = Breadcrumbs or {}

local LAM = LibAddonMenu2

local panelData = {
    type = "panel",
    name = Breadcrumbs.name, -- sidebar name
    author = Breadcrumbs.author,
    displayName = Breadcrumbs.title,
    version = Breadcrumbs.version,
    registerForRefresh = true,
    registerForDefaults = true,
}

local optionsTable = {
    {
        type = "header",
        name = "Settings",
    },
    {
        type = "checkbox",
        name = "Enabled",
        tooltip = "Toggles visibility of the lines",
        default = Breadcrumbs.defaults.enabled,
        getFunc = function() return Breadcrumbs.sV.enabled end,
        setFunc = function(value)
            Breadcrumbs.sV.enabled = value
            Breadcrumbs.RefreshLines()
        end,
    },
    {
        type = "button",
        name = "Clear Zone",
        warning = "This will delete all lines from your current zone",
        isDangerous = true,
        func = function(value) Breadcrumbs.ClearSavedZoneLinesFromThisZone() end,
    },
    {
        type = "header",
        name = "Import",
    },
    {
        type = "editbox",
        name = "Config",
        tooltip = "Insert a valid Breadcrumbs string to import new lines into the correct zone",
        default = Breadcrumbs.defaults.importString,
        isMultiline = true,
        isExtraWide = true,
        maxChars = 30000,
        getFunc = function() return Breadcrumbs.sV.importString end,
        setFunc = function(value) Breadcrumbs.sV.importString = value end,
    },
    {
        type = "button",
        name = "Import",
        func = function(value) Breadcrumbs.ImportStringToLines() end,
    },
    {
        type = "header",
        name = "Export String",
    },
    {
        type = "editbox",
        name = "Config",
        tooltip = "String that describes the lines for the current zone",
        default = Breadcrumbs.defaults.exportString,
        isMultiline = true,
        isExtraWide = true,
        maxChars = 10000,
        getFunc = function() return Breadcrumbs.sV.exportString end,
        setFunc = function(value) end,
    },
    {
        type = "submenu",
        name = "General Settings",
        controls = {
            {
                type = "slider",
                name = "Line width",
                min = 3,
                max = 24,
                default = Breadcrumbs.defaults.width,
                getFunc = function() return Breadcrumbs.sV.width end,
                setFunc = function(value) Breadcrumbs.sV.width = value Breadcrumbs.scaleFactor = 1. / Breadcrumbs.sV.width end,
            },
            {
                type = "slider",
                name = "Line opacity",
                min = 0.1,
                max = 1,
                step = 0.05,
                decimals = 2,
                default = Breadcrumbs.interval,
                getFunc = function() return Breadcrumbs.sV.alpha end,
                setFunc = function(value) Breadcrumbs.StopPolling() Breadcrumbs.sV.alpha = value Breadcrumbs.StartPolling() end,
            },
            {
                type = "slider",
                name = "Polling frquency (ms)",
                min = 1,
                max = 24,
                step = 1,
                default = Breadcrumbs.defaults.polling,
                getFunc = function() return Breadcrumbs.sV.polling end,
                setFunc = function(value) Breadcrumbs.sV.polling = value Breadcrumbs.StopPolling() Breadcrumbs.StartPolling() end,
            },
            {
                type = "slider",
                name = "Minimum line scale",
                min = 0.0,
                max = 0.4,
                step = 0.01,
                decimals = 2,
                default = Breadcrumbs.defaults.minimumScale,
                getFunc = function() return Breadcrumbs.sV.minimumScale end,
                setFunc = function(value) Breadcrumbs.sV.minimumScale = value end,
            },
            {
                type = "checkbox",
                name = "Use 3D Lines",
                tooltip = "Replaces 2d perspective lines with 3d controls",
                getFunc = function() return Breadcrumbs.sV.depthMarkers end,
                setFunc = function(value) 
                    Breadcrumbs.sV.depthMarkers = value
                    -- ReloadUI("ingame")
                end,
                requiresReload = true,
            },
            {
                type = "iconpicker",
                name = "Default line texture",
                choices = Breadcrumbs.lineTextures,
                getFunc = function() return Breadcrumbs.lineTextures[Breadcrumbs.sV.fallbackLineStyle] end,
                setFunc = function(var)
                    for i, texture in ipairs(Breadcrumbs.lineTextures) do
                        if texture == var then
                            Breadcrumbs.sV.fallbackLineStyle = i
                            break
                        end
                    end
                    Breadcrumbs.RefreshLines()
                end,
                maxColumns = 5,
                visibleRows = 2,
                iconSize = 32,
                defaultColor = ZO_ColorDef:New("FFFFFF"),
                default = Breadcrumbs.defaults.fallbackLineStyle,
            },
        },
    },
    {
        type = "header",
        name = "Draw lines",
    },
    {
        type = "button",
        name = "/breadcrumbs",
        func = function(value) Breadcrumbs.ToggleUIVisibility() end,
    },
    {
        type = "submenu",
        name = "Drawing Readme/Guide",
        controls = {
            {
                type = "description",
                text = "To draw lines using the draw menu simply save your current location into either location 1 (loc1) or location 2 (loc2) at two different positions, then click draw. This will create a line between these two positions.\nUsing the pin icon next to loc1 or loc2 will snap it to the nearest point to you. This is useful for modifying line connections. Also, it reduces the length of your export string.\nYou can select the colour of the line from a palette using the dropdown, or specify your own colour using the colour picker accessed through the custom button.\nTo remove a line, simply press remove. Finally, you can use the functions below to draw special shapes, such as polygons.",
            },
        },
    },
    {
        type = "header",
        name = "Shapes",
    },
    {
        type = "submenu",
        name = "Regular Polygon",
        controls = {
            {
                type = "description",
                text = "Select the appropriate parameters and then click draw to create a regular polygon around yourself. For shapes with an odd number of vertices, the first vertex is placed directly in front of you. For those with an even number, the first edge is placed in front of you instead.",
            },
            {
                type = "slider",
                name = "Number of sides",
                min = 3,
                max = 24,
                default = Breadcrumbs.defaults.polygon_sides,
                getFunc = function() return Breadcrumbs.sV.polygon_sides end,
                setFunc = function(value) Breadcrumbs.sV.polygon_sides = value end,
            },
            {
                type = "slider",
                name = "Radius of shape",
                min = 1,
                max = 100,
                step = 1,
                decimals = 1,
                default = Breadcrumbs.defaults.polygon_radius,
                getFunc = function() return Breadcrumbs.sV.polygon_radius end,
                setFunc = function(value) Breadcrumbs.sV.polygon_radius = value end,
            },
            {
                type = "colorpicker",
                name = "Colour",
                default = ZO_ColorDef:New(unpack(Breadcrumbs.defaults.colour)),
                getFunc = function() return unpack(Breadcrumbs.sV.colour) end,
                setFunc = function(r,g,b,a) Breadcrumbs.SetLineColour(r, g, b) end,
            },
            {
                type = "button",
                name = "Preview Polygon",
                tooltip = "Draw a temporary view of your polygon. This will disappear when changing any lines or reloading ui.",
                func = function(value) Breadcrumbs.PreviewPolygon(Breadcrumbs.sV.polygon_radius, Breadcrumbs.sV.polygon_sides, Breadcrumbs.sV.colour) end,
            },
            {
                type = "button",
                name = "Draw Polygon",
                tooltip = "Draws the defined polygon centered around your current location",
                func = function(value) Breadcrumbs.PlacePolygon(Breadcrumbs.sV.polygon_radius, Breadcrumbs.sV.polygon_sides, Breadcrumbs.sV.colour) end,
            },
        },
    },
    {
        type = "submenu",
        name = "3D Axis",
        controls = {
            {
                type = "description",
                text = "For debugging, draws a set of three lines. |cff0000+X|r, |c00ff00+Y|r, |c0000ff+Z|r.",
            },
            {
                type = "button",
                name = "Draw Axis",
                func = function(value) Breadcrumbs.Generate3DAxisLines() end,
            },
        },
    },
    {
        type = "header",
        name = "Recording",
    },
    {
        type = "submenu",
        name = "Recording",
        controls = {
            {
                type = "button",
                name = "Start/Stop Recording",
                func = function(value) Breadcrumbs.ToggleRecording() end,
            },
            {
                type = "slider",
                name = "Polling Frequency (ms)",
                min = 10,
                max = 1000,
                default = Breadcrumbs.defaults.recording,
                getFunc = function() return Breadcrumbs.sV.recording end,
                setFunc = function(value) Breadcrumbs.SetRecordingSpeed(value) end,
            },
            {
                type = "button",
                name = "Draw Recording",
                func = function(value) Breadcrumbs.DrawRecording() end,
            },
        },
    },
}

function Breadcrumbs.RegisterSettingsPanel()
    Breadcrumbs.addon_panel = LAM:RegisterAddonPanel(Breadcrumbs.name.."Options", panelData)
    LAM:RegisterOptionControls(Breadcrumbs.name.."Options", optionsTable)
end