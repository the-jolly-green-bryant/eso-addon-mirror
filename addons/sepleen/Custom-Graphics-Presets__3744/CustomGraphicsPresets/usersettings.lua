function GP.RegisterAddonPanel(parent, addonID, panelData)
    local panel = LAMCreateControl.panel(parent, panelData, addonID)
    panel:SetHidden(true)
    panel:SetAnchorFill(parent)

    return panel
end

function GP.CreateOptions(panel, options)
    local optionsTable = options

    if optionsTable then
        local function CreateAndAnchorWidget(parent, widgetData, offsetX, offsetY, anchorTarget, wasHalf)
            local widget
            local status, err = pcall(function() widget = LAMCreateControl[widgetData.type](parent, widgetData) end)
            if not status then
                return err or true, offsetY, anchorTarget, wasHalf
            else
                if widgetData.type == "dropdown" then
                    if widgetData.name:match("Screenshot") then
                        widget.dropdown.m_dropdown:ClearAnchors()
                        widget.dropdown.m_dropdown:SetAnchor(BOTTOMRIGHT, widget.combobox, TOPRIGHT)
                    end
                end
                if widgetData.type == "submenu" then
                    widget.bg:SetBlendMode(TEX_BLEND_MODE_ADD)
                    widget.bg:SetCenterColor(0,0,0,0)
                end
                local isHalf = (widgetData.width == "half")
                if not anchorTarget then
                    widget:SetAnchor(TOPLEFT)
                    anchorTarget = widget
                else
                    widget:SetAnchor(TOPLEFT, anchorTarget, BOTTOMLEFT, 0, 15)
                    offsetY = 0
                    anchorTarget = widget
                end
                return false, offsetY, anchorTarget, isHalf
            end
        end

        local THROTTLE_COUNT = 20
        local fifo = {}
        local anchorOffset, lastAddedControl, wasHalf
        local CreateWidgetsInPanel, err

        local function PrepareForNextPanel()
            anchorOffset, lastAddedControl, wasHalf = 0, nil, false
        end

        local function SetupCreationCalls(parent, widgetDataTable)
            fifo[#fifo + 1] = PrepareForNextPanel
            local count = #widgetDataTable
            for i = 1, count, THROTTLE_COUNT do
                fifo[#fifo + 1] = function()
                    CreateWidgetsInPanel(parent, widgetDataTable, i, zo_min(i + THROTTLE_COUNT - 1, count))
                end
            end
            return count ~= NonContiguousCount(widgetDataTable)
        end

        CreateWidgetsInPanel = function(parent, widgetDataTable, startIndex, endIndex)
            for i=startIndex,endIndex do
                local widgetData = widgetDataTable[i]
                if widgetData then
                    local widgetType = widgetData.type
                    local offsetX = 0
                    local isSubmenu = (widgetType == "submenu")
                    if isSubmenu then
                        wasHalf = false
                        offsetX = 5
                    end

                    err, anchorOffset, lastAddedControl, wasHalf = CreateAndAnchorWidget(parent, widgetData, offsetX, anchorOffset, lastAddedControl, wasHalf)
                    if err then end

                    if isSubmenu then
                        if SetupCreationCalls(lastAddedControl, widgetData.controls) then end
                    end
                end
            end
        end

        local function DoCreateSettings()
            if #fifo > 0 then
                local nextCall = table.remove(fifo, 1)
                nextCall()
                DoCreateSettings()
            end
        end

        if SetupCreationCalls(panel, optionsTable) then end
        DoCreateSettings()
    end
end

GP.usersettings = {
    [1] = {
        type = "submenu",
        name = "UserSettings",
        tooltip = "Edit CVars. Not affected by restoring defaults",
        controls = {
            [1] = {type = 'header', name = "Display"},
            [2] = {
                type = "dropdown",
                name = "Particle Density",
                tooltip = "Particle Density",
                choices = {"Low", "Medium", "High", "Maximum"},
                choicesValues = {0, 1, 2, 3},
                getFunc = function() return end,
                setFunc = function(value) SetCVar("PARTICLE_DENSITY", tostring(value)) end,
                width = "full",
                default = tonumber(GetCVar("PARTICLE_DENSITY")),
            },
            [3] = {
                type = "checkbox",
                name = "Enabled Player Stand-Ins",
                tooltip = "Enabled Player Stand-Ins",
                getFunc = function() return end,
                setFunc = function(value) SetCVar("PlayerStandInsEnabled.2", tostring(value)) end,
                width = "full",
                default = (tonumber(GetCVar("PlayerStandInsEnabled.2")) == 1 and true or false),
            },
            [4] = {
                type = "slider",
                name = "Maximum Stand-Ins Per Frame",
                tooltip = "Maximum Stand-Ins Per Frame",
                min = 0,
                max = 150,
                step = 1,
                getFunc = function() return end,
                setFunc = function(value) SetCVar("PlayerStandInsMaxPerFrame", tostring(value)) end,
                width = "full",
                default = tonumber(GetCVar("PlayerStandInsMaxPerFrame")),
            },
            [5] = {
                type = "slider",
                name = "Maximum Frames Per Second",
                tooltip = "Max FPS",
                min = 24,
                max = 560,
                step = 1,
                getFunc = function() return end,
                setFunc = function(value) SetCVar("MinFrameTime.2", tostring(1/value)) end,
                width = "full",
                default = 100,
            },
            [6] = {
                type = "slider",
                name = "GPU Smoothing Frames",
                tooltip = "Maximum Stand-Ins Per Frame",
                min = 0,
                max = 10,
                step = 1,
                getFunc = function() return end,
                setFunc = function(value) SetCVar("GPUSmoothingFrames", tostring(value)) end,
                width = "full",
                default = tonumber(GetCVar("GPUSmoothingFrames")),
            },
            [7] = {type = 'header', name = "Graphics"},
            [8] = {
                type = "checkbox",
                name = "Simple Shaders",
                tooltip = "Simple Shaders",
                getFunc = function() return end,
                setFunc = function(value) SetCVar("SIMPLE_SHADERS", tostring(value)) end,
                width = "full",
                default = (tonumber(GetCVar("SIMPLE_SHADERS")) == 1 and true or false),
            },
            [9] = {
                type = "checkbox",
                name = "Character Lighting",
                tooltip = "Character Lighting",
                getFunc = function() return end,
                setFunc = function(value) SetCVar("CHARACTER_LIGHTING", tostring(value)) end,
                width = "full",
                default = (tonumber(GetCVar("CHARACTER_LIGHTING")) == 1 and true or false),
            },
            [10] = {
                type = "checkbox",
                name = "High Resolution Shadows",
                tooltip = "High Resolution Shadows",
                getFunc = function() return end,
                setFunc = function(value) SetCVar("HIGH_RESOLUTION_SHADOWS", tostring(value)) end,
                width = "full",
                warning = "Seems to affect only certain shadows, requires shadow quality setting to be on",
                default = (tonumber(GetCVar("HIGH_RESOLUTION_SHADOWS")) == 1 and true or false),
            },
            [11] = {
                type = "checkbox",
                name = "Terrain Shadows",
                tooltip = "Render foliage shadows",
                getFunc = function() return end,
                setFunc = function(value) SetCVar("TerrainShadowsEnabled", tostring(value)) end,
                width = "full",
                warning = "Requires shadow quality setting to be on",
                default = (tonumber(GetCVar("TerrainShadowsEnabled")) == 1 and true or false),
            },
            [12] = {
                type = "checkbox",
                name = "Body Shadows",
                tooltip = "Body Shadows",
                getFunc = function() return end,
                setFunc = function(value) SetCVar("BlobShadowsEnabled", tostring(value)) end,
                width = "full",
                default = (tonumber(GetCVar("BlobShadowsEnabled")) == 1 and true or false),
            },
            [13] = {
                type = "checkbox",
                name = "Lens Flare",
                tooltip = "Lens Flare",
                getFunc = function() return end,
                setFunc = function(value) SetCVar("LENS_FLARE", tostring(value)) end,
                width = "full",
                default = (tonumber(GetCVar("LENS_FLARE")) == 1 and true or false),
            },
            [14] = {
                type = "checkbox",
                name = "Rain Wetness",
                tooltip = "Rain Wetness",
                getFunc = function() return end,
                setFunc = function(value) SetCVar("RAIN_WETNESS", tostring(value)) end,
                width = "full",
                default = (tonumber(GetCVar("RAIN_WETNESS") == 1 and true or false)),
            },
            [15] = {
                type = "checkbox",
                name = "Screen Border Munge",
                tooltip = "Screen Border Munge",
                getFunc = function() return end,
                setFunc = function(value) SetCVar("PPFXOverlaysEnabled", tostring(value)) end,
                width = "full",
                default = (tonumber(GetCVar("PPFXOverlaysEnabled")) == 1 and true or false),
            },
            [16] = { type = 'header', name = "Miscellaneous" },
            [17] = {
                type = "checkbox",
                name = "Skip Pregame Videos",
                tooltip = "Skip Pregame Videos",
                getFunc = function() return end,
                setFunc = function(value) SetCVar("SkipPregameVideos", tostring(value)) end,
                width = "full",
                default = (tonumber(GetCVar("SkipPregameVideos")) == 1 and true or false),
            },
            [18] = {
                type = "dropdown",
                name = "Screenshot Format",
                tooltip = "Screenshot Format",
                choices = {"BMP", "PNG", "JPG"},
                getFunc = function() return end,
                setFunc = function(value) SetCVar("ScreenshotFormat.2", value) end,
                width = "full",
                warning = "JPG format is compressed",
                default = GetCVar("ScreenshotFormat.2"),
            },
        },
    },
}