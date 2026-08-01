--[[

Helmet Toggle
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Variable for saved variables table
local savedVariables = {}

-- Constants
local colors = {
    "Default (red)",
    "Green",
    "Blue",
    "Cyan",
    "Magenta",
    "Yellow",
    "Black",
    "White",
}

-- Change rally point texture from string
local function SetRallyColor(str)
    if type(str) ~= "string" then return end
    local isInputOk = false
    for i, c in ipairs(colors) do
        if str == c then
            isInputOk = true
            break
        end
    end
    if not isInputOk then return end
    
    local texture_orig = "EsoUI/Art/MapPins/MapRallyPoint.dds"
    local texture_new = "BetterRally/textures/MapRallyPoint_<<1>>.dds"
    
    if str == colors[1] then
        -- Use default texture
        texture_new = texture_orig
    else
        -- Use str in file name
        str = str:lower()
        texture_new = zo_strformat(texture_new, str)
    end
    
    RedirectTexture(texture_orig, texture_orig)  -- Reset first to fix weird behaviour
    RedirectTexture(texture_orig, texture_new)
end

local panelData = {
    type = "panel",
    name = "Better Rally",
    displayName = "|c70C0DEBetter Rally|r",
    author = "|c70C0DECaptainBlagbird|r",
    version = "1.0",
    slashCommand = "/betterrally",
    registerForRefresh = true,
    registerForDefaults = true,
    -- resetFunc = function() end, -- Will run after settings are reset to defaults
}

local optionsTable = {
    {
        type = "dropdown",
        name = "Rally point color",
        choices = colors,
        getFunc = function() 
                local value = savedVariables.RallyColor
                if value == nil then value = colors[1] end
                return value
            end,
        setFunc = function(value)
                if value == colors[1] then
                    savedVariables.RallyColor = nil
                else
                    savedVariables.RallyColor = value
                end
                SetRallyColor(value)
                -- Force texture reset in the menu
                BetterRally_Options_RallyTexture:SetTexture("")
                BetterRally_Options_RallyTexture:SetTexture("EsoUI/Art/MapPins/MapRallyPoint.dds")
            end,
        default = colors[1],
        warning = "It might be necessary to open another zone map to force the new color to load for the real rally point.",
        width = "full",
    },
}

-- Create texture on first load of the Better Rally LAM panel
local function CreateTexture(panel)
    if panel == BetterRally_Options then
        -- Create texture control
        local rallyTexture = WINDOW_MANAGER:CreateControl("BetterRally_Options_RallyTexture", panel.controlsToRefresh[1], CT_TEXTURE)
        rallyTexture:SetAnchor(RIGHT, panel.controlsToRefresh[1].dropdown:GetControl(), LEFT, -30, 0)
        rallyTexture:SetTexture("EsoUI/Art/MapPins/MapRallyPoint.dds")
        rallyTexture:SetDimensions(35, 35)
        -- Create animation for texture
        local animation, timeline = CreateSimpleAnimation(ANIMATION_TEXTURE, rallyTexture)
        animation:SetImageData(32, 1)
        animation:SetFramerate(32)
        animation:SetHandler("OnStop", function() rallyTexture:SetTextureCoords(0, 1, 0, 1) end)
        timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
        timeline:PlayFromStart()
        
        CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", CreateTexture)
    end
end
CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", CreateTexture)

-- Wait until all addons are loaded
local function OnPlayerActivated(event)
    -- Set up SavedVariables table
    savedVariables = ZO_SavedVars:New("BetterRallySettings", 1, nil, {})
    
    SetRallyColor(savedVariables.RallyColor)
    
    -- Setup LibAddonMenu if available
    if LibStub ~= nil then
        local LAM = LibStub("LibAddonMenu-2.0", false)
        LAM:RegisterAddonPanel("BetterRally_Options", panelData)
        LAM:RegisterOptionControls("BetterRally_Options", optionsTable)
    end
    
    EVENT_MANAGER:UnregisterForEvent("BetterRally_Options", EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent("BetterRally_Options", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)