local CC = CombatCoordinates

---------------------------------------------------------------------------
-- CREATE SETTINGS MENU
---------------------------------------------------------------------------
function CC.CreateSettings()
    local LAM2 = LibAddonMenu2
    if not LAM2 then return end

    local panelData = {
        type = "panel",
        name = "Combat Coordinates",
        displayName = "|cFF7F00Combat|r |cFFFFFFCoordinates|r",
        author = "|cFF7F00" .. CC.author .. "|r",
        version = CC.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local function GetColorDefault(colorArray)
        return { r = colorArray[1], g = colorArray[2], b = colorArray[3], a = colorArray[4] }
    end

    ---------------------------------------------------------------------------
    -- HELPER: DRAW PREVIEW
    ---------------------------------------------------------------------------
    local function DrawPreview()
        local zone, x, y, z = GetUnitRawWorldPosition("player")
        if x and y and z then
            local radius, numSides, lineWidth, heightOffset = CC.GetVisualSettings()
            local fwdX, fwdY, fwdZ = CC.GetForwardPosition("player", x, y, z, CC.SV.standardOffset)
            local duration = CC.supportedSkills[32947].duration

            CC.DrawEffectCircle(fwdX, fwdY, fwdZ, radius, CC.SV.standardColorSelf, duration, numSides, lineWidth, heightOffset)
        end
    end

    local optionsData = {
        {
            type = "checkbox",
            name = "|cFF7F00MASTERSWITCH|r (Turns the entire addon ON/OFF)",
            tooltip = "Enables or disables the drawing of 3D effects.",
            getFunc = function() return CC.SV.enableAddon end,
            setFunc = function(value) 
                CC.SV.enableAddon = value 
                if value then CC.Enable() else CC.Disable() end
            end,
            default = CC.default.enableAddon,
        },
        {
            type = "checkbox",
            name = "Enable Debug Messages",
            tooltip = "Shows detailed send and receive messages in the chat.",
            getFunc = function() return CC.SV.debugMode end,
            setFunc = function(value) CC.SV.debugMode = value end,
            default = CC.default.debugMode,
        },
        {
            type = "submenu",
            name = "|cFF7F00SKILL: STANDARD OF MIGHT|r",
            controls = {
                {
                    type = "button",
                    name = "Draw Preview",
                    tooltip = "Draws a test circle for 15 seconds based on current settings.",
                    func = function() DrawPreview() end,
                    disabled = function() return not CC.SV.enableAddon end,
                },
                {
                    type = "slider",
                    name = "Circle Resolution (Number of Sides)",
                    tooltip = "Determines how 'round' the circle appears. Default: 16.",
                    min = 8, max = 24, step = 2,
                    getFunc = function() return CC.SV.standardNumSides end,
                    setFunc = function(val) CC.SV.standardNumSides = val end,
                    default = CC.default.standardNumSides,
                },
                {
                    type = "slider",
                    name = "Line Thickness",
                    tooltip = "Determines the height/thickness of the 3D line. Default: 0.25",
                    min = 0.1, max = 1.0, step = 0.05, decimals = 2,
                    getFunc = function() return CC.SV.standardLineWidth end,
                    setFunc = function(val) CC.SV.standardLineWidth = val end,
                    default = CC.default.standardLineWidth,
                },
                {
                    type = "slider",
                    name = "Radius",
                    tooltip = "The base radius of the circle (100 = 1 meter). Default: 800.",
                    min = 400, max = 1200, step = 10,
                    getFunc = function() return CC.SV.standardRadius end,
                    setFunc = function(val) CC.SV.standardRadius = val end,
                    default = CC.default.standardRadius,
                },
                {
                    type = "slider",
                    name = "Forward Offset (Self Cast)",
                    tooltip = "Shifts the circle forward in your facing direction. Default: 150 (1.5m).",
                    min = 0, max = 300, step = 10,
                    getFunc = function() return CC.SV.standardOffset end,
                    setFunc = function(val) CC.SV.standardOffset = val end,
                    default = CC.default.standardOffset,
                },
                {
                    type = "slider",
                    name = "Height Offset (Visual Z-Axis)",
                    tooltip = "Adjusts the vertical position of the circle to compensate for uneven terrain. Default: 5.",
                    min = -50, max = 50, step = 1,
                    getFunc = function() return CC.SV.standardHeightOffset end,
                    setFunc = function(val) CC.SV.standardHeightOffset = val end,
                    default = CC.default.standardHeightOffset,
                },
                {
                    type = "colorpicker",
                    name = "Line Color (Self Cast)",
                    getFunc = function() return unpack(CC.SV.standardColorSelf) end,
                    setFunc = function(r, g, b, a) CC.SV.standardColorSelf = {r, g, b, a} end,
                    default = GetColorDefault(CC.default.standardColorSelf),
                },
                {
                    type = "colorpicker",
                    name = "Line Color (Group Members)",
                    getFunc = function() return unpack(CC.SV.standardColorGroup) end,
                    setFunc = function(r, g, b, a) CC.SV.standardColorGroup = {r, g, b, a} end,
                    default = GetColorDefault(CC.default.standardColorGroup),
                },
            },
        },
        {
            type = "description",
            text = "If you enjoy |cFF7F00Combat Coordinates|r, consider sharing your feedback or supporting its development. Your input and contributions are greatly appreciated!",
            width = "full"
        },
        {
            type = "button",
            name = "Feedback / Donate",
            tooltip = "Opens a mail to send feedback or donate to the author. <3",
            func = function()
                if CC.isConsole then
                    d(string.format("%s |cFFFFFFFeedback via Mail is currently only supported on PC.|r", CC.chat))
                    return
                end
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(function()
                    ZO_MailSendToField:SetText(CC.author)
                    ZO_MailSendSubjectField:SetText("Combat Coordinates")
                    ZO_MailSendBodyField:TakeFocus()
                end, 250)
            end,
            width = "half"
        }
    }

    LAM2:RegisterAddonPanel(CC.name .. "Menu", panelData)
    LAM2:RegisterOptionControls(CC.name .. "Menu", optionsData)
end