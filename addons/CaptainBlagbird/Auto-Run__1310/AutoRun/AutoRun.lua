--[[

Auto Run
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Addon info
local AddOnName = "AutoRun"
-- Saved variables table
local sv = {}
-- Settings
local panelData = {
    type = "panel",
    name = "Auto Run",
    displayName = "|c70C0DEAuto Run|r",
    author = "|c70C0DECaptainBlagbird|r",
    version = "1.0",
    slashCommand = "/autorun",
    registerForRefresh = true,
    registerForDefaults = true,
}
local optionsTable = {
    {
        type = "editbox",
        name = "Commands",
        tooltip = "Seperate by new line",
        getFunc = function()
                local str = sv.Commands[1]
                for i=2,#sv.Commands do
                    str = zo_strjoin("\n", str, sv.Commands[i])
                end
                return str
            end,
        setFunc = function(str) sv.Commands = { zo_strsplit("\n", str) } end,
        isMultiline = true,
        isExtraWide = true,
        width = "full",
        reference = "AutoRunCommandsEditBoxControl",
        default = "",
    },
}
local function LAMPanelLoaded(panel)
    if panel == AutoRun_Options then
        local control = AutoRunCommandsEditBoxControl
        local container = AutoRunCommandsEditBoxControl.container
        local editboxData = AutoRunCommandsEditBoxControl.data
        if not (control and container and editboxData) then return end
        if editboxData.type ~= "editbox" then return end
        
        -- Increase edit box height
        local MIN_HEIGHT = 100
        if editboxData.isMultiline then
            container:SetHeight(MIN_HEIGHT * 3)
        else
            container:SetHeight(MIN_HEIGHT)
        end

        if control.isHalfWidth ~= true and editboxData.isExtraWide ~= true then
            control:SetHeight(container:GetHeight())
        else
            control:SetHeight(container:GetHeight() + control.label:GetHeight())
        end
        
        CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", LAMPanelLoaded)
    end
end
CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", LAMPanelLoaded)


-- Trim start and end (Source: http://lua-users.org/wiki/StringTrim --> trim7)
local match = string.match
function trim(s)
    return match(s,'^()%s*$') and '' or match(s,'^%s*(.*%S)')
end

-- Event handler function for EVENT_PLAYER_ACTIVATED
local function OnPlayerActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(AddOnName, EVENT_PLAYER_ACTIVATED)
    
    -- Set up SavedVariables table
    sv = ZO_SavedVars:New("AutoRun_SavedVars", 1, nil, {Commands={}})
    
    -- Set up settings menu
    if LibStub then
        local LAM = LibStub("LibAddonMenu-2.0", false)
        LAM:RegisterAddonPanel(AddOnName.."_Options", panelData)
        LAM:RegisterOptionControls(AddOnName.."_Options", optionsTable)
    end
    
    -- Don't continue if table invalid or empty
    if type(sv.Commands) ~= "table" then return end
    if #sv.Commands <= 0 then return end
    
    for i,cmd in ipairs(sv.Commands) do
        -- Trim whitespaces and get base command without arguments
        cmd = trim(cmd)
        local base_cmd = string.match(cmd, "[^%s]+")
        -- Run command if it exists
        if cmd ~= "" and SLASH_COMMANDS[base_cmd] then
            DoCommand(cmd)
        end
    end
end
EVENT_MANAGER:RegisterForEvent(AddOnName, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)