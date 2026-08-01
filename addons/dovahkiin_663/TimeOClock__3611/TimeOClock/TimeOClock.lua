
TimeOClock = {}
TimeOClock.name = "TimeOClock"

local savedVariables

local function st()
    TimeOClockLabel:SetHidden(false)
   savedVariables.visible = true
end

local function ht()
    TimeOClockLabel:SetHidden(true)
   savedVariables.visible = false
end

local function clock()
   time = os.date("%a %b %d, %H:%M:%S")
   TimeOClockLabel:SetText(time)
   zo_callLater(function () clock() end, 1000)
end

local function getFontSize()
   return savedVariables.fontSize
end

local function setFontSize(v)
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

  TimeOClockLabel:SetFont("$(".. savedVariables.font .. ")|$(KB_" .. value .. ")|soft-shadow-thick")
   savedVariables.fontSize = value
end

local function setFont(font)
    TimeOClockLabel:SetFont("$(".. font .. ")|$(KB_" .. getFontSize() .. ")|soft-shadow-thick")
   savedVariables.font = font
end

local function getFont()
   return savedVariables.font
end

local function getFontColor()
   return savedVariables.fontColor.r, savedVariables.fontColor.g, savedVariables.fontColor.b, savedVariables.fontColor.a
end

local function setFontColor(r, g, b, a)
   TimeOClockLabel:SetColor(r,g,b,a)
   savedVariables.fontColor.r = r
   savedVariables.fontColor.g = g
   savedVariables.fontColor.b = b
   savedVariables.fontColor.a = a
end

local function setVisibility(v)
   if(v == true) then
      st()
   else
      ht()
   end
end

local function getVisibility()
   return savedVariables.visible
end

local function initializeTimeOClockAddon()
   setVisibility(savedVariables.visible)
   setFontSize(savedVariables.fontSize)
   setFont(savedVariables.font)
   setFontColor(
      savedVariables.fontColor.r,
      savedVariables.fontColor.g,
      savedVariables.fontColor.b,
      savedVariables.fontColor.a
   )

   local LAM = LibAddonMenu2
   local panelName = "TimeOClockSettings"
   
   local panelData = {
      type = "panel",
      name = "TimeOClock",
      author = "@dovahkiin_663",
   }
   
   local optionsData = {
         [1] = {
            type = "checkbox",
            name = "Visible",
            tooltip = "Shows or hides the clock.",
            getFunc = function() return getVisibility() end,
            setFunc = function(value) setVisibility(value) end

         },
         [2] = {
            type = "dropdown",
            name = "Font",
            tooltip = "The font of the clock.",
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
            getFunc = function() return getFont() end,
            setFunc = function(value) setFont(value) end,
      },
      [3] = {
           type = "slider",
           name = "Font size",
           tooltip = "The font size of the clock",
           getFunc = function() return getFontSize() end,
           setFunc = function(value) setFontSize(value) end,
           min = 8,
           max = 40
      },
      [4] = {
           type = "colorpicker",
           name = "Font color",
           tooltip = "The color of the font of the clock.",
           getFunc = function() return getFontColor() end,
           setFunc = function(r,g,b,a) setFontColor(r, g, b, a) end
      }
   }
   local panel = LAM:RegisterAddonPanel(panelName, panelData)
   LAM:RegisterOptionControls(panelName, optionsData)
   
end

function TimeOClock.OnAddOnLoaded(event, name)
   if name ~= "TimeOClock" then return end
   EVENT_MANAGER:UnregisterForEvent("TimeOClock", EVENT_ADD_ON_LOADED)

   local defaults = {
      fontSize = 24,
      font = "GAMEPAD_LIGHT_FONT",
      fontColor = {
         r = 255,
         g = 255,
         b = 255,
         a = 255,
      },
      visible = true
   }
   savedVariables = ZO_SavedVars:NewAccountWide("TimeOClockVars", 3, nil, defaults)

   initializeTimeOClockAddon()
   clock()
end
 
SLASH_COMMANDS["/st"] = st
SLASH_COMMANDS['/ht'] = ht

EVENT_MANAGER:RegisterForEvent(TimeOClock.name, EVENT_ADD_ON_LOADED, TimeOClock.OnAddOnLoaded)