------------------------------------------------------------------
--FCOCursor.lua
--Author: Baertram
------------------------------------------------------------------
--Global variable
FCOCursor                 = {
    name    =           "FCOCursor", -- Matches folder and Manifest file names.
    settingsName =      "FCO Cursor", -- Matches folder and Manifest file names.
    version =           "2.0", -- A nuisance to match to the Manifest.
    author  =           "Baertram",
    website =           "https://www.esoui.com/downloads/fileinfo.php?id=3773",
    feedback =          "https://www.esoui.com/portal.php?id=136&a=faq",
    donation =          "https://www.esoui.com/portal.php?id=136&a=faq&faqid=131",
}
local FCOC                = FCOCursor

--Libraries
FCOC.LAM = LibAddonMenu2

local lamStringCursorTypePrefix = "FCOCURSOR_LAM_CURSOR_TYPE_"

--ZOs controls
FCOC.ctrlVars = {
    guiMouse = GuiMouse,
}

--Saved original cursor data
local origZOsCursors = {
    default =                   { name="MOUSE_CURSOR_DEFAULT_CURSOR", value=MOUSE_CURSOR_DEFAULT_CURSOR },--MOUSE_CURSOR_DEFAULT_CURSOR = 0
    resizeEW =                  { name="MOUSE_CURSOR_RESIZE_EW", value=MOUSE_CURSOR_RESIZE_EW },--MOUSE_CURSOR_RESIZE_EW,-- = 1
    resizeNS =                  { name="MOUSE_CURSOR_RESIZE_NS", value=MOUSE_CURSOR_RESIZE_NS },--MOUSE_CURSOR_RESIZE_NS,-- = 2
    resizeNESW =                { name="MOUSE_CURSOR_RESIZE_NESW", value=MOUSE_CURSOR_RESIZE_NESW },--MOUSE_CURSOR_RESIZE_NESW,-- = 3
    resizeNWSE =                { name="MOUSE_CURSOR_RESIZE_NWSE", value=MOUSE_CURSOR_RESIZE_NWSE },--MOUSE_CURSOR_RESIZE_NWSE,-- = 4
    icon =                      { name="MOUSE_CURSOR_ICON", value=MOUSE_CURSOR_ICON },--MOUSE_CURSOR_ICON,-- = 5
    uiHand =                    { name="MOUSE_CURSOR_UI_HAND", value=MOUSE_CURSOR_UI_HAND },--MOUSE_CURSOR_UI_HAND,-- = 6
    erase =                     { name="MOUSE_CURSOR_ERASE", value=MOUSE_CURSOR_ERASE },--MOUSE_CURSOR_ERASE,-- = 7
    fill =                      { name="MOUSE_CURSOR_FILL", value=MOUSE_CURSOR_FILL },--MOUSE_CURSOR_FILL,-- = 8
    fillMultiple =              { name="MOUSE_CURSOR_FILL_MULTIPLE", value=MOUSE_CURSOR_FILL_MULTIPLE },--MOUSE_CURSOR_FILL_MULTIPLE,-- = 9
    paint =                     { name="MOUSE_CURSOR_PAINT", value=MOUSE_CURSOR_PAINT },--MOUSE_CURSOR_PAINT,-- = 10
    sample =                    { name="MOUSE_CURSOR_SAMPLE", value=MOUSE_CURSOR_SAMPLE },--MOUSE_CURSOR_SAMPLE,-- = 11
    pan =                       { name="MOUSE_CURSOR_PAN", value=MOUSE_CURSOR_PAN },--MOUSE_CURSOR_PAN,-- = 12
    rotate =                    { name="MOUSE_CURSOR_ROTATE", value=MOUSE_CURSOR_ROTATE },--MOUSE_CURSOR_ROTATE,-- = 13
    nextLeft =                  { name="MOUSE_CURSOR_NEXT_LEFT", value=MOUSE_CURSOR_NEXT_LEFT },--MOUSE_CURSOR_NEXT_LEFT,-- = 14
    nextRight =                 { name="MOUSE_CURSOR_NEXT_RIGHT", value=MOUSE_CURSOR_NEXT_RIGHT },--MOUSE_CURSOR_NEXT_RIGHT,-- = 15
    preview =                   { name="MOUSE_CURSOR_PREVIEW", value=MOUSE_CURSOR_PREVIEW },--MOUSE_CURSOR_PREVIEW,-- = 16
    championWorldStar =         { name="MOUSE_CURSOR_CHAMPION_WORLD_STAR", value=MOUSE_CURSOR_CHAMPION_WORLD_STAR },--MOUSE_CURSOR_CHAMPION_WORLD_STAR,-- = 17
    championCombatStar =        { name="MOUSE_CURSOR_CHAMPION_COMBAT_STAR", value=MOUSE_CURSOR_CHAMPION_COMBAT_STAR },--MOUSE_CURSOR_CHAMPION_COMBAT_STAR,-- = 18
    championConditioningStar =  { name="MOUSE_CURSOR_CHAMPION_CONDITIONING_STAR", value=MOUSE_CURSOR_CHAMPION_CONDITIONING_STAR },--MOUSE_CURSOR_CHAMPION_CONDITIONING_STAR,-- = 19
    doNotCare =                 { name="MOUSE_CURSOR_DO_NOT_CARE", value=MOUSE_CURSOR_DO_NOT_CARE },--MOUSE_CURSOR_DO_NOT_CARE,-- = 666
}

local savedOrigCursors = ZO_ShallowTableCopy(origZOsCursors)
FCOC.origCursors = savedOrigCursors

--local variables
local isExchangeCursorsLooping = false

--SavedVariables data
local svVersion = 1
local svName = "FCOCursor_Settings"
FCOC.settingsVars = {
    defaults = {
        exchangeCursors = {
            default = savedOrigCursors.default.value,
        },
        cursorGlow = false,
        cursorGlowColor = { r=0, g=1, b=0.5, a=0.3 },
        cursorGlowColorEdge = { r=0, g=1, b=0.5, a=0.4 },
        cursorGlowSize = { x = 16, y = 16},
    },
    settings = {},
}

local function getCursorsList()
    local cursorsSorted = {}
    for cursorType, _ in pairs(savedOrigCursors) do
        cursorsSorted[#cursorsSorted + 1] = cursorType
    end
    table.sort(cursorsSorted)

    local choices = {}
    local choicesValues = {}
    for idx, cursorType in ipairs(cursorsSorted) do
        local cursorName = GetString(_G[lamStringCursorTypePrefix .. tostring(cursorType)])
        local cursorConstantData = savedOrigCursors[cursorType]
        if cursorName ~= nil and cursorConstantData ~= nil and cursorConstantData.value ~= nil then
            choices[idx] = cursorName
            choicesValues[idx] = cursorConstantData.value
        end
    end
--[[
FCOC._debug = {
    cursorsSorted = cursorsSorted,
    choices = choices,
    choicesValues = choicesValues,
}
]]

    return choices, choicesValues
end

function FCOC.UpdateCursorGlow()
    local settings = FCOC.settingsVars.settings

    --Show/Hide the cursor glow
    local doCursorGlow = settings.cursorGlow
    local cursorGlowTLC = FCOC.UITLC
    cursorGlowTLC:SetMouseEnabled(false)
    cursorGlowTLC:SetHidden(not doCursorGlow)
    if doCursorGlow == false then return end

    --Update the color of the glow
    local cursorGlowColor = settings.cursorGlowColor
    local cursorGlowColorEdge = settings.cursorGlowColorEdge
    local cursorGlowSize = settings.cursorGlowSize
    ---local glowLabel = cursorGlowTLC.GlowLabel
    --glowLabel:SetText(settings.cursorGlowText)
    --glowLabel:SetColor(cursorGlowColor.r, cursorGlowColor.g, cursorGlowColor.b, cursorGlowColor.a)

    local glowBackdrop = cursorGlowTLC.GlowBackdrop
    glowBackdrop:ClearAnchors()
    glowBackdrop:SetAnchor(CENTER, cursorGlowTLC, CENTER, 0, 0)
    glowBackdrop:SetDimensions(cursorGlowSize.x, cursorGlowSize.y)
    glowBackdrop:SetCenterColor(cursorGlowColor.r, cursorGlowColor.g, cursorGlowColor.b, cursorGlowColor.a)
    glowBackdrop:SetEdgeColor(cursorGlowColorEdge.r, cursorGlowColorEdge.g, cursorGlowColorEdge.b, cursorGlowColorEdge.a)
end
local updateCursorGlow = FCOC.UpdateCursorGlow

--functions
local function updateVisualCursorNow(cursorToReplace)
    if cursorToReplace == nil then return end
    --Mouse cursor is not updating if just pressing key to get into UI mode.
    --You need to open the inventory e.g. to update it?
    --So we try to force the change of the cursor now
    ClearCursor()
    WINDOW_MANAGER:SetMouseCursor(cursorToReplace)
    updateCursorGlow()
end

local function updateDefaultCursorVisualNow()
    updateVisualCursorNow(MOUSE_CURSOR_DEFAULT_CURSOR)
end

local function replaceCursor(cursorType, newCursor)
    if cursorType == nil then return end
    local cursorDataToReplace = savedOrigCursors[cursorType] --returns e.g. { name="MOUSE_CURSOR_DEFAULT_CURSOR", value=MOUSE_CURSOR_DEFAULT_CURSOR }
    if cursorDataToReplace ~= nil then
        local cursorName = cursorDataToReplace.name
        local currentCursor = _G[cursorName]
        if currentCursor ~= nil then
--d(">found _G[" ..tostring(cursorDataToReplace.name) .."] -> Assign new cursor: " .. tostring(newCursor or cursorDataToReplace.value))
            if newCursor == nil then
                --Reset to the original one
                --currentCursor = cursorDataToReplace.value
                _G[cursorName] = cursorDataToReplace.value
            else
                --Overwrite with new selected
                --currentCursor = newCursor
                _G[cursorName] = newCursor
            end
            --Update the doNotCare cursor too if we update the default cursor
            if cursorType == "default" then
                local doNotCareCursorName = savedOrigCursors.doNotCare.name
                _G[doNotCareCursorName] = _G[cursorName]
            end

            if isExchangeCursorsLooping then return end
            updateVisualCursorNow(_G[cursorName])
        end
    end
end

local exchangeCursors
function FCOC.ExchangeCursors(cursorType, newCursor)
    exchangeCursors = exchangeCursors or FCOC.ExchangeCursors
    if cursorType == nil and newCursor == nil  then
        --Loop over all exchanged cursors and set them to their exchanged value now
        local exchangeCursorsSettigs = FCOC.settingsVars.settings.exchangeCursors
        isExchangeCursorsLooping = true
        for l_cursorType, l_newCursor in pairs(exchangeCursorsSettigs) do
            exchangeCursors(l_cursorType, l_newCursor)
        end
        isExchangeCursorsLooping = false
        updateDefaultCursorVisualNow()
    else
        replaceCursor(cursorType, newCursor)
    end
end
exchangeCursors = FCOC.ExchangeCursors

--Settings menu
local function BuildAddonMenu()
        local defSettings = FCOC.settingsVars.defaults
        local settings = FCOC.settingsVars.settings

        local panelData = {
            type 				= 'panel',
            name 				= FCOC.settingsName,
            displayName 		= FCOC.settingsName,
            author 				= FCOC.author,
            version 			= FCOC.version,
            registerForRefresh 	= true,
            registerForDefaults = true,
            slashCommand 		= "/fcocursors",
            website             = FCOC.website,
            feedback            = FCOC.feedback,
            donation            = FCOC.donation,
        }
        --The LibAddonMenu2.0 settings panel reference variable
        FCOC.LAMsettingsPanel = FCOC.LAM:RegisterAddonPanel(FCOC.name .. "_LAM", panelData)

        --Callback as the FCOCursor LAm panel was created
        --[[
        local function FCOC_LAMPanelCreated()

        end
        ]]

        local cursorsDropdownChoices, cursorsDropdownChoicesValues = getCursorsList()


        --the LAM settings controls
        local optionsTable = {
            --==============================================================================
            {
                type = 'header',
                name = GetString(FCOCURSOR_LAM_HEADER_EXCHANGE_CURSOR),
            },
            --==============================================================================
            {
                type = "dropdown",
                name = GetString(FCOCURSOR_LAM_EXCHANGE_DEFAULT_CURSOR),
                tooltip = GetString(FCOCURSOR_LAM_EXCHANGE_DEFAULT_CURSOR_TT),
                choices = cursorsDropdownChoices,
                choicesValues = cursorsDropdownChoicesValues,
                getFunc = function () return settings.exchangeCursors["default"] end,
                setFunc = function (value)
                    settings.exchangeCursors["default"] = value
                    exchangeCursors("default", value)
                end,
                width = "full",
                default = defSettings.exchangeCursors["default"],
            },

            --==============================================================================
            {
                type = 'header',
                name = GetString(FCOCURSOR_LAM_HEADER_CURSOR_VISUALS),
            },
            --==============================================================================
            {
                type = "checkbox",
                name = GetString(FCOCURSOR_LAM_CURSOR_GLOW),
                tooltip = GetString(FCOCURSOR_LAM_CURSOR_GLOW_TT),
                getFunc = function() return settings.cursorGlow end,
                setFunc = function(value)
                    settings.cursorGlow = value

                    updateCursorGlow()
                end,
                default = defSettings.cursorGlow,
            },
            {
                type = "colorpicker",
                name = GetString(FCOCURSOR_LAM_CURSOR_GLOW_COLOR),
                tooltip = GetString(FCOCURSOR_LAM_CURSOR_GLOW_COLOR_TT),
                getFunc = function()
                    local cursorGlowColor = settings.cursorGlowColor
                    return cursorGlowColor["r"], cursorGlowColor["g"], cursorGlowColor["b"], cursorGlowColor["a"]
                end,
                setFunc = function(r,g,b,a)
                    settings.cursorGlowColor["r"] = r
                    settings.cursorGlowColor["g"] = g
                    settings.cursorGlowColor["b"] = b
                    settings.cursorGlowColor["a"] = a

                    updateCursorGlow()
                end,
                default = defSettings.cursorGlowColor,
                disabled = function() return not settings.cursorGlow end,
            },
            {
                type = "colorpicker",
                name = GetString(FCOCURSOR_LAM_CURSOR_GLOW_COLOR_EDGE),
                tooltip = GetString(FCOCURSOR_LAM_CURSOR_GLOW_COLOR_EDGE_TT),
                getFunc = function()
                    local cursorGlowColorEdge = settings.cursorGlowColorEdge
                    return cursorGlowColorEdge["r"], cursorGlowColorEdge["g"], cursorGlowColorEdge["b"], cursorGlowColorEdge["a"]
                end,
                setFunc = function(r,g,b,a)
                    settings.cursorGlowColorEdge["r"] = r
                    settings.cursorGlowColorEdge["g"] = g
                    settings.cursorGlowColorEdge["b"] = b
                    settings.cursorGlowColorEdge["a"] = a

                    updateCursorGlow()
                end,
                default = defSettings.cursorGlowColorEdge,
                disabled = function() return not settings.cursorGlow end,
            },
            {
                type = "slider",
                name = GetString(FCOCURSOR_LAM_CURSOR_GLOW_SIZE_X),
                tooltip = GetString(FCOCURSOR_LAM_CURSOR_GLOW_SIZE_X_TT),
                min = 0.1,
                max = 32,
                step = 0.1,
                decimals = 1,
                autoSelect = true,
                getFunc = function() return settings.cursorGlowSize.x end,
                setFunc = function(value)
                    settings.cursorGlowSize.x = value

                    updateCursorGlow()
                end,
                default = defSettings.cursorGlowSize.x,
                disabled = function() return not settings.cursorGlow end,
            },
            {
                type = "slider",
                name = GetString(FCOCURSOR_LAM_CURSOR_GLOW_SIZE_Y),
                tooltip = GetString(FCOCURSOR_LAM_CURSOR_GLOW_SIZE_Y_TT),
                min = 0.1,
                max = 32,
                step = 0.1,
                decimals = 1,
                autoSelect = true,
                getFunc = function() return settings.cursorGlowSize.y end,
                setFunc = function(value)
                    settings.cursorGlowSize.y = value

                    updateCursorGlow()
                end,
                default = defSettings.cursorGlowSize.y,
                disabled = function() return not settings.cursorGlow end,
            },

        }

        --CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", FCOC_LAMPanelCreated)
        FCOC.LAM:RegisterOptionControls(FCOC.name .. "_LAM", optionsTable)
end

local function LoadSavedVariables()
    FCOC.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings(svName, svVersion, GetWorldName(), FCOC.settingsVars.defaults, nil)

    if type(FCOC.settingsVars.settings.exchangeCursors.default) ~= "number" then
        FCOC.settingsVars.settings.exchangeCursors.default = FCOC.settingsVars.defaults.exchangeCursors.default
    end
end

--Events
function FCOC.OnPlayerActivated(event)
    --Check if any cursor should be exchanged
    FCOC.ExchangeCursors(nil, nil)
end

function FCOC.OnAddOnLoaded(event, addonName)
    if addonName ~= FCOC.name then return end
    EVENT_MANAGER:UnregisterForEvent(FCOC.name, EVENT_ADD_ON_LOADED)

    LoadSavedVariables()

    FCOC.InitCursorXML()

    BuildAddonMenu()

    EVENT_MANAGER:RegisterForEvent(FCOC.name, EVENT_PLAYER_ACTIVATED, FCOC.OnPlayerActivated)
end


--XML Initialization
function FCOC.InitCursorXML()
    local FCOC_UITLC = FCOCursorTLC
    FCOC_UITLC:SetHidden(true)

    --FCOC_UITLC.GlowLabel = GetControl(FCOC.UITLC, "GlowLabel")
    FCOC_UITLC.GlowBackdrop = GetControl(FCOC_UITLC, "GlowBackdrop")
    FCOC.UITLC = FCOC_UITLC

    --Switching between UI mdoe and non UI mode (pressing . to show cursor) should hide the TLC properly
    SecurePostHook(SCENE_MANAGER, 'SetInUIMode', function(selfVar, inUIMode, bypassHideSceneConfirmationReason)
--d("[FCOCursor]SCENE_MANAGER:SetInUIMode-inUIMode: " ..tostring(inUIMode))
        local settings = FCOC.settingsVars.settings
        --Show/Hide the cursor glow
        local doCursorGlow = settings.cursorGlow
        local doHide = not doCursorGlow
        if not doHide then
            doHide = not inUIMode
        end
        FCOC_UITLC:SetHidden(doHide)
	end)
end

--Load the addon
EVENT_MANAGER:RegisterForEvent(FCOC.name, EVENT_ADD_ON_LOADED, FCOC.OnAddOnLoaded)

