------------------------------------------------
-- XAM's Toolbox -- Advanced ESO Settings
------------------------------------------------

-- Register Module
XAM:registerModule("AdvancedSettings")

-- Module: Default Settings
XAM.d.AdvancedSettings = {
    -- DISPLAY
    GPUSmoothingFrames                  = 10,       -- 0-10
    MinFrameTime                        = 1/100,    -- 30-300
    -- GRAPHICS
    HIGH_RESOLUTION_SHADOWS             = 1,        -- 0-1
    HORIZON_BASED_AMBIENT_OCCLUSION     = 0,        -- 0-1
    LENS_FLARE                          = 1,        -- 0-1
    PARTICLE_DENSITY                    = 3,        -- 0-3
    RAIN_WETNESS                        = 1,        -- 0-1
    SIMPLE_SHADERS                      = 1,        -- 0-1
    -- MISCELLANEOUS
    ScreenshotFormat                    = "PNG",    -- BMP,JPG,PNG
    ShowPetsAtCharacterSelect           = 1,        -- 0-1
    SkipPregameVideos                   = 0,        -- 0-1
}

-- Functions
local function setDefaults()
    -- DISPLAY
    SetCVar("GPUSmoothingFrames",               XAM.d.AdvancedSettings.GPUSmoothingFrames)
    SetCVar("MinFrameTime.2",                   XAM.d.AdvancedSettings.MinFrameTime)
    -- GRAPHICS
    SetCVar("HIGH_RESOLUTION_SHADOWS",          XAM.d.AdvancedSettings.HIGH_RESOLUTION_SHADOWS)
    SetCVar("HORIZON_BASED_AMBIENT_OCCLUSION",  XAM.d.AdvancedSettings.HORIZON_BASED_AMBIENT_OCCLUSION)
    SetCVar("LENS_FLARE",                       XAM.d.AdvancedSettings.LENS_FLARE)
    SetCVar("PARTICLE_DENSITY",                 XAM.d.AdvancedSettings.PARTICLE_DENSITY)
    SetCVar("RAIN_WETNESS",                     XAM.d.AdvancedSettings.RAIN_WETNESS)
    SetCVar("SIMPLE_SHADERS",                   XAM.d.AdvancedSettings.SIMPLE_SHADERS)
    -- MISCELLANEOUS
    SetCVar("ScreenshotFormat.2",               XAM.d.AdvancedSettings.ScreenshotFormat)
    SetCVar("ShowPetsAtCharacterSelect.2",      XAM.d.AdvancedSettings.ShowPetsAtCharacterSelect)
    SetCVar("SkipPregameVideos",                XAM.d.AdvancedSettings.SkipPregameVideos)
end

-- Module: Settings Menu
XAM.o[#XAM.o + 1] = {
    type = "submenu",
    name = "|cFF9900Advanced ESO Settings|r",
    tooltip = "Additional settings for ESO",
    controls = {
        {
            -- DISPLAY SETTINGS --
            type = "header",
            name = "Display",
            width = "full",
        },{
            type = "slider",
            name = " |u12:0::|uMaximum FPS",
            tooltip = "At what threshold your FPS caps at",
            getFunc = function() return zo_round(1 / tonumber(GetCVar("MinFrameTime.2"))) end,
            setFunc = function(value) SetCVar("MinFrameTime.2", 1 / value) end,
            default = XAM.d.AdvancedSettings.MinFrameTime,
            min = 30,
            max = 300,
            step = 1,
            width = "full",
            clampInput = false,
        },{
            type = "slider",
            name = " |u12:0::|uGPU Smoothed Frames",
            tooltip = "How many frames to pre-render. Usually best to set to 1 on single cards and a minimum of 3 when using SLI/Crossfire.",
            getFunc = function() return tonumber(GetCVar("GPUSmoothingFrames")) end,
            setFunc = function(value) SetCVar("GPUSmoothingFrames", value) end,
            default = XAM.d.AdvancedSettings.GPUSmoothingFrames,
            min = 0,
            max = 10,
            step = 1,
            width = "full",
            clampInput = false,
        },{
            -- GRAPHICS SETTINGS --
            type = "header",
            name = "Graphics",
            width = "full",
        },{
            type = "checkbox",
            name = " |u12:0::|uHigh Resolution Shadows",
            tooltip = "Toggle between high and low resolution shadows.",
            getFunc = function() return GetCVar("HIGH_RESOLUTION_SHADOWS") ~= "0" end,
            setFunc = function(value) SetCVar("HIGH_RESOLUTION_SHADOWS", value and "1" or "0") end,
            default = XAM.d.AdvancedSettings.HIGH_RESOLUTION_SHADOWS,
            width = "full",
        },{
            type = "checkbox",
            name = " |u12:0::|uHorizon Based Ambient Acclusion (HBAO)",
            tooltip = "Toggle between using SSAO or HBAO. Two different techniques to create realistic shadowing around objects.",
            getFunc = function() return GetCVar("HORIZON_BASED_AMBIENT_OCCLUSION") ~= "0" end,
            setFunc = function(value) SetCVar("HORIZON_BASED_AMBIENT_OCCLUSION", value and "1" or "0") end,
            default = XAM.d.AdvancedSettings.HORIZON_BASED_AMBIENT_OCCLUSION,
            width = "full",
        },{
            type = "checkbox",
            name = " |u12:0::|uLens Flares",
            tooltip = "A lens flare is the glare you see when looking at a light source.",
            getFunc = function() return GetCVar("LENS_FLARE") ~= "0" end,
            setFunc = function(value) SetCVar("LENS_FLARE", value and "1" or "0") end,
            default = XAM.d.AdvancedSettings.LENS_FLARE,
            width = "full",
        },{
            type = "dropdown",
            name = " |u12:0::|uParticle Density",
            tooltip = "Limits how many particles can be shown on your screen. Higher value means more particles.",
            choices = {"0","1","2","3"},
            getFunc = function() return GetCVar("PARTICLE_DENSITY") end,
            setFunc = function(value) SetCVar("PARTICLE_DENSITY", value) end,
            default = XAM.d.AdvancedSettings.PARTICLE_DENSITY,
            width = "full",
        },{
            type = "checkbox",
            name = " |u12:0::|uRain Wetness",
            tooltip = "Making surfaces appear wet by making them glance when being it by rain.",
            getFunc = function() return GetCVar("RAIN_WETNESS") ~= "0" end,
            setFunc = function(value) SetCVar("RAIN_WETNESS", value and "1" or "0") end,
            default = XAM.d.AdvancedSettings.RAIN_WETNESS,
            width = "full",
        },{
            type = "checkbox",
            name = " |u12:0::|uSimple Shaders",
            tooltip = "Toggle between Simple and Advanced shaders. Advanced makes the clouds and sky look a bit better.",
            getFunc = function() return GetCVar("SIMPLE_SHADERS") ~= "0" end,
            setFunc = function(value) SetCVar("SIMPLE_SHADERS", value and "1" or "0") end,
            default = XAM.d.AdvancedSettings.SIMPLE_SHADERS,
            width = "full",
        },{
            -- MISCELLANEOUS SETTINGS --
            type = "header",
            name = "Miscellaneous",
            width = "full",
        },{
            type = "dropdown",
            name = " |u12:0::|uScreenshot Format",
            tooltip = "Which format your screenshots gets saved as.",
            choices = {"BMP","JPG","PNG"},
            getFunc = function() return GetCVar("ScreenshotFormat.2") end,
            setFunc = function(value) SetCVar("ScreenshotFormat.2", value) end,
            default = XAM.d.AdvancedSettings.ScreenshotFormat,
            width = "full",
        },{
            type = "checkbox",
            name = " |u12:0::|uShow pet and mount on character select.",
            tooltip = "Either shows or hides your selected characters pet and mount on character screen.",
            getFunc = function() return GetCVar("ShowPetsAtCharacterSelect.2") ~= "0" end,
            setFunc = function(value) SetCVar("ShowPetsAtCharacterSelect.2", value and "1" or "0") end,
            default = XAM.d.AdvancedSettings.ShowPetsAtCharacterSelect,
            width = "full",
        },{
            type = "checkbox",
            name = " |u12:0::|uSkip Pre-game Intro",
            tooltip = "Disables the intro videos during game start-up. Makes it faster to launch the game.",
            getFunc = function() return GetCVar("SkipPregameVideos") ~= "0" end,
            setFunc = function(value) SetCVar("SkipPregameVideos", value and "1" or "0") end,
            default = XAM.d.AdvancedSettings.SkipPregameVideos,
            width = "full",
        },{
            type = "header",
            name = "",
            width = "full",
        },{
            type = "button",
            name = "Set Defaults",
            tooltip = "Reset this section only to default values",
            func = function() setDefaults() end,
            width = "full",
        },
    }
}

-- Module: Advanced Settings

function XAM:AdvancedSettings()
    if XAM.s.debug then
        CHAT_SYSTEM:AddMessage(string.format("%s|cFFFFFFAdvanced Settings|r: |c00FF00Loaded|r",XAM.prefix))
    end
end