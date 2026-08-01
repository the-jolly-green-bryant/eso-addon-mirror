BetterGuardAddon = BetterGuardAddon or {}
local BG = BetterGuardAddon

local LAM = LibAddonMenu2


local panelData = {
    type = "panel",
    name = BG.nameSpaced, -- sidebar name
    displayName = BG.nameTitle,
    author = BG.author,
    version = BG.version,
    slashCommand = "/betterguard",
    website = "https://www.esoui.com/downloads/info3974-BetterGuard.html",
    feedback = "https://github.com/sheumais/BetterGuard/issues",
    registerForRefresh = true,
    registerForDefaults = true,
}

local optionsTable = {
    {
        type = "description",
        title = nil,
        text = "Create a line between yourself and another group member when guarded.",
    },
    {
        type = "header",
        name = "Behaviour",
    },
    { 
        type = "checkbox",
        name = "Show tether on you",
        tooltip = "Show a tether when someone else guards you.",
        getFunc = function() return BG.savedVariables.showGuardOnYou end,
        setFunc = function(value) BG.savedVariables.showGuardOnYou = value end,
        default = BG.defaults.showGuardOnYou,
    },
    {
        type = "slider",
        name = "Safe distance",
        tooltip = "Meters distance under which safe colour should be used",
        min = 0,
        max = 15,
        step = 0.5,
        getFunc = function() return BG.savedVariables.safeDistance end,
        setFunc = function(value) BG.savedVariables.safeDistance = value end,
        disabled = function() return BG.savedVariables.rainbowLine end,
        default = BG.defaults.safeDistance,
    },
    {
        type = "description",
        title = nil,
        text = "", -- Spacing
    },
    {
        type = "header",
        name = "Appearance",
    },
    {
        type = "slider",
        name = "Alpha",
        tooltip = "Alpha/Transparency/Opacity",
        min = 1,
        max = 100,
        step = 1,
        getFunc = function() return BG.savedVariables.alpha * 100 end,
        setFunc = function(value) BG.savedVariables.alpha = value / 100 end,
        default = BG.defaults.alpha * 100,
    },
    {
        type = "slider",
        name = "Width",
        tooltip = "Width of line",
        min = 1,
        max = 50,
        step = 1,
        getFunc = function() return BG.savedVariables.width end,
        setFunc = function(value) BG.savedVariables.width = value end,
        default = BG.defaults.width,
    },
    {
        type = "colorpicker",
        name = "Safe Colour",
        tooltip = "Colour to use when close/safe",
        getFunc = function() return unpack(BG.savedVariables.safeColour) end,
        setFunc = function(r, g, b, _) BG.savedVariables.safeColour = {r, g, b, BG.savedVariables.alpha} end,
        disabled = function() return BG.savedVariables.rainbowLine end,
        default = ZO_ColorDef:New(unpack(BG.defaults.safeColour)),
    },
    {
        type = "colorpicker",
        name = "Danger Colour",
        tooltip = "Colour to use when guard is close to breaking",
        getFunc = function() return unpack(BG.savedVariables.breakingColour) end,
        setFunc = function(r, g, b, _) BG.savedVariables.breakingColour = {r, g, b, BG.savedVariables.alpha} end,
        disabled = function() return BG.savedVariables.rainbowLine end,
        default = ZO_ColorDef:New(unpack(BG.defaults.breakingColour)),
    },
    { 
        type = "checkbox",
        name = "Use Depth Buffer",
        tooltip = "Hide the line behind objects and enemies",
        warning = "Requires SubSampling on High",
        getFunc = function() return BG.savedVariables.depthBuffer end,
        setFunc = function(value) BG.savedVariables.depthBuffer = value end,
        default = BG.defaults.depthBuffer,
    },
    { 
        type = "checkbox",
        name = "Rainbow tether",
        tooltip = "Make your tether glow with the power of RGB",
        getFunc = function() return BG.savedVariables.rainbowLine end,
        setFunc = function(value) BG.savedVariables.rainbowLine = value end,
        default = BG.defaults.rainbowLine,
    },
    {type = "divider"},
}

local function RegisterLAMPanel()
    LAM:RegisterAddonPanel(BG.name, panelData)
    LAM:RegisterOptionControls(BG.name, optionsTable)
end

BG.RegisterLAMPanel = RegisterLAMPanel