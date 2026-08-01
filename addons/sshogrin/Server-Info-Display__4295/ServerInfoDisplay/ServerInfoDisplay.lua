SERVER_INFO_DISPLAY = {}

SERVER_INFO_DISPLAY = {
	name = "ServerInfoDisplay",
	author = "sshogrin",
	version = "1.2.1",
    variableVersion = 1,
}

SERVER_INFO_DISPLAY.defaults = {
    windowPosX = 0,
    windowPosY = 0,
    isLocked = false,
    fontColor = {
        R = 255,
        G = 255,
        B = 0,
        A = 255,
    },
    font = "BOLD_FONT",
    fontSize = 18
}

-- Function to display server info
function SERVER_INFO_DISPLAY:UpdateInfo()
    local serverName = GetWorldName() -- Gets the current megaserver name (e.g., "NA", "EU")
    local accountName = GetDisplayName()    --Gets the current Account and Character name
    local latency = GetLatency()     -- Gets the current latency/ping in milliseconds
    
    local coloredLatency

    if latency >= 500 then
    -- Red: |cFF0000
    coloredLatency = "|cFF0000" ..latency.. "ms|r"
    elseif latency >= 150 then
    -- Yellow: |cFFFF00
    coloredLatency = "|cFFFF00" ..latency.. "ms|r"
    else
    -- Green: |c00FF00
    coloredLatency = "|c00FF00" ..latency.. "ms|r"
    end
    
    -- Format the message
    local infoString = string.format("  Server: %s | Account: %s | Latency: %s", serverName, accountName, coloredLatency)
    ServerInfoDisplayWindowLabel:SetText(infoString)
    self.updateTimer = zo_callLater(function() self:UpdateInfo() end, 1000, true)

end

-- Display the message in the chat window (a simple way to show info)   
    --d(infoString) 

--Saves Display Window Location
function SERVER_INFO_DISPLAY:SaveLoc()
    local windowControl = GetControl("ServerInfoDisplayWindow")
        local currentX = windowControl:GetLeft()
        local currentY = windowControl:GetTop()
        SERVER_INFO_DISPLAY.savedVariables.windowPosX = currentX
        SERVER_INFO_DISPLAY.savedVariables.windowPosY = currentY
end

-- Restores Window Position
function SERVER_INFO_DISPLAY:RestoreWindowPosition()
        local left = SERVER_INFO_DISPLAY.savedVariables.windowPosX
        local top = SERVER_INFO_DISPLAY.savedVariables.windowPosY

        if left and top then
            ServerInfoDisplayWindow:ClearAnchors()
            ServerInfoDisplayWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
        end
    end

-- Sets lock state of window.
function SERVER_INFO_DISPLAY:SetLockState(locked)
    local mainWindow = GetControl("ServerInfoDisplayWindow")
    SERVER_INFO_DISPLAY.savedVariables.isLocked = locked      
    if locked then
        mainWindow:SetMovable(false)
        mainWindow:SetMouseEnabled(false)
        -- Optional: Add a visual indicator that it is locked
    else
        mainWindow:SetMovable(true)
        mainWindow:SetMouseEnabled(true)
        -- Optional: Add a visual indicator that it is unlocked and can be moved
    end
end

-- Gets Lock State.
function SERVER_INFO_DISPLAY:GetLockState()
    return SERVER_INFO_DISPLAY.savedVariables.isLocked
end

-- Gets Font Color
function SERVER_INFO_DISPLAY:GetFontColor()
   return SERVER_INFO_DISPLAY.savedVariables.fontColor.R, SERVER_INFO_DISPLAY.savedVariables.fontColor.G, SERVER_INFO_DISPLAY.savedVariables.fontColor.B, SERVER_INFO_DISPLAY.savedVariables.fontColor.A
end

-- Sets Font Color
function SERVER_INFO_DISPLAY:SetFontColor(r, g, b, a)
   ServerInfoDisplayWindowLabel:SetColor(r,g,b,a)
   SERVER_INFO_DISPLAY.savedVariables.fontColor.R = r
   SERVER_INFO_DISPLAY.savedVariables.fontColor.G = g
   SERVER_INFO_DISPLAY.savedVariables.fontColor.B = b
   SERVER_INFO_DISPLAY.savedVariables.fontColor.A = a
end

function SERVER_INFO_DISPLAY:GetFontSize()
   return SERVER_INFO_DISPLAY.savedVariables.fontSize
end

function SERVER_INFO_DISPLAY:SetFontSize(v)
   local value = v

   local case = {
     [27] = function ()
         value = 26
     end,
     [29] = function ()
         value = 28
      end,
      [31] = function ()
         value = 30
      end,
      [33] = function ()
         value = 32
      end,
      [35] = function ()
         value = 34
      end,
      [37] = function ()
         value = 36
      end,
      [38] = function ()
         value = 36
      end,
      [39] = function ()
         value = 40
      end,
   }

  if case[value] then
     case[value]()
  end

   ServerInfoDisplayWindowLabel:SetFont("$(".. SERVER_INFO_DISPLAY.savedVariables.font .. ")|$(KB_" .. value .. ")|soft-shadow-thick")
   SERVER_INFO_DISPLAY.savedVariables.fontSize = value
end

function SERVER_INFO_DISPLAY:SetFont(font)
   ServerInfoDisplayWindowLabel:SetFont("$(".. font .. ")|$(KB_" .. SERVER_INFO_DISPLAY:GetFontSize() .. ")|soft-shadow-thick")
   SERVER_INFO_DISPLAY.savedVariables.font = font
end

function SERVER_INFO_DISPLAY:GetFont()
   return SERVER_INFO_DISPLAY.savedVariables.font
end

-- Settings Panel
function initializeServerInfoDisplayOptions()

    local panelName = "ServerInfoDisplayOptions"

    local panelData = {
        type = "panel",
		name = "Server Info Display",
        displayName = "|c2046e5Server Info Display|r",
        author = "|c2046e5s|r|c403cccs|r|c6032b2h|r|c802898o|r|c9f1e7eg|r|cbf1465r|r|cdf0a4bi|r|cff0031n|r",
        version = SERVER_INFO_DISPLAY.version,
        registerForRefresh = true,
    }

    local optionsTable = {
    [1] = {
        type = "checkbox",
        name = "Lock Window Position",
        tooltip = "Check this to lock the window in place to prevent moving it with the mouse.",
        getFunc = function() return SERVER_INFO_DISPLAY:GetLockState() end,
        setFunc = function(value) SERVER_INFO_DISPLAY:SetLockState(value) end,
        },
    [2] = {
           type = "colorpicker",
           name = "Font color",
           tooltip = "The color of the font for the server info window.",
           getFunc = function() return SERVER_INFO_DISPLAY:GetFontColor() end,
           setFunc = function( r, g, b, a ) SERVER_INFO_DISPLAY:SetFontColor(r, g, b, a) end
      },
    [3] = {
            type = "dropdown",
            name = "Font",
            tooltip = "The font of the server info display window.",
            default = SERVER_INFO_DISPLAY.savedVariables.font,
            choices = {
            "MEDIUM_FONT",
            "BOLD_FONT",
            "CHAT_FONT",
            "GAMEPAD_LIGHT_FONT",
            "GAMEPAD_MEDIUM_FONT",
            "GAMEPAD_BOLD_FONT",
            "ANTIQUE_FONT",
            "HANDWRITTEN_FONT",
            "STONE_TABLET_FONT"
         },
            getFunc = function() return SERVER_INFO_DISPLAY:GetFont() end,
            setFunc = function(value) SERVER_INFO_DISPLAY:SetFont(value) end,
      },
    [4] = {
           type = "slider",
           name = "Font size",
           tooltip = "The font size of the server info display window.",
           getFunc = function() return SERVER_INFO_DISPLAY:GetFontSize() end,
           setFunc = function(value) SERVER_INFO_DISPLAY:SetFontSize(value) end,
           min = 8,
           max = 40
      },
    }
    
    local LAM = LibAddonMenu2
    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsTable)
end

-- Function called when the addon loads
function SERVER_INFO_DISPLAY:Initialize()
    -- Register an event listener for when the player enters the world
    EVENT_MANAGER:RegisterForEvent("ServerInfoDisplay", EVENT_PLAYER_ACTIVATED, function()
        -- Update info once the player is fully loaded in
        SERVER_INFO_DISPLAY:UpdateInfo()
    end)
    
    -- Register for latency updates
    EVENT_MANAGER:RegisterForEvent("ServerInfoDisplay", EVENT_LATENCY_UPDATED, function()
        -- Update info every time the latency is updated
        SERVER_INFO_DISPLAY:UpdateInfo()
    end)

    SERVER_INFO_DISPLAY:RestoreWindowPosition()
    SERVER_INFO_DISPLAY:SetLockState(SERVER_INFO_DISPLAY.savedVariables.isLocked)
    SERVER_INFO_DISPLAY:SetFontColor(
                        SERVER_INFO_DISPLAY.savedVariables.fontColor.R,
                        SERVER_INFO_DISPLAY.savedVariables.fontColor.G,
                        SERVER_INFO_DISPLAY.savedVariables.fontColor.B,
                        SERVER_INFO_DISPLAY.savedVariables.fontColor.A
                        )
    SERVER_INFO_DISPLAY:SetFont(SERVER_INFO_DISPLAY.savedVariables.font)
    SERVER_INFO_DISPLAY:SetFontSize(SERVER_INFO_DISPLAY.savedVariables.fontSize)
    -- You could also add a slash command for manual checks
    SLASH_COMMANDS["/serverinfo"] = function()
        SERVER_INFO_DISPLAY:PrintToChat()
    end
end

-- Initialize the addon
function SERVER_INFO_DISPLAY.OnAddOnLoaded(_, addonName)
    if addonName ~= SERVER_INFO_DISPLAY.name then return end
    
    EVENT_MANAGER:UnregisterForEvent(SERVER_INFO_DISPLAY.name, EVENT_ADD_ON_LOADED) 

    SERVER_INFO_DISPLAY.savedVariables = ZO_SavedVars:NewAccountWide("ServerInfoDisplaySavedVariables", SERVER_INFO_DISPLAY.variableVersion, nil, SERVER_INFO_DISPLAY.defaults)

    initializeServerInfoDisplayOptions()
    SERVER_INFO_DISPLAY:Initialize()

end

EVENT_MANAGER:RegisterForEvent(SERVER_INFO_DISPLAY.name, EVENT_ADD_ON_LOADED, SERVER_INFO_DISPLAY.OnAddOnLoaded)