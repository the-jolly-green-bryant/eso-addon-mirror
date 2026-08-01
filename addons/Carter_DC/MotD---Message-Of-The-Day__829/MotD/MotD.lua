-- AddOn : MotD
-- Description : This Addon displays the Message of the Day for a choosen guild.
-- Author : Carter_DC
-- V 0.1.3
-- Color management functions courtesy of IngeniousClown
--
-- 
--Libraries--------------------------------------------------------------------
local LAM = LibStub("LibAddonMenu-2.0")


MotD           = {}
MotD.addonName = "MotD"
MotD.version   = "0.1.3"
MotD.defaults  = {  -- default settings for saved variables
     mainGuildID = 1,
     motdColor   = "", 
     guildColor  = "",
}
MotD.savedVariables={}





-- Event handlers -------------------------------------------------------------

function MotD.OnAddOnLoaded(eventCode, name)
   if name ~= MotD.addonName then return end

   MotD.defaults.motdColor  = MotD.RGBAToHex(1, .25, 0, 1)
   MotD.defaults.guildColor = MotD.RGBAToHex(0, 1, 1, 1)
   MotD.savedVariables      = ZO_SavedVars:NewAccountWide("MotDSavedVariables", 1 , nil , MotD.defaults , nil )
   --MotD.savedVariables      = ZO_SavedVars:New("MotDSavedVariables", 1, nil, MotD.defaults)
   
   
   
   -- Settings menu
   MotD.CreateSettingsMenu()
     
   --events
   EVENT_MANAGER:RegisterForEvent(MotD.addonName, EVENT_PLAYER_ACTIVATED , MotD.OnPlayerActivated )
   EVENT_MANAGER:RegisterForEvent(MotD.addonName, EVENT_GUILD_MOTD_CHANGED , MotD.OnGuildMotdChanged )
   
   EVENT_MANAGER:UnregisterForEvent(MotD.addonName, EVENT_ADD_ON_LOADED)
   
   
end


function MotD.OnPlayerActivated()

  d(MotD.CreateMotDString(MotD.savedVariables.mainGuildID))
  
  local function MyHook()
    return true
  end
  
  ZO_PreHook(ZO_GuildMotDProvider, "BuildNotificationList", MyHook)
  
  EVENT_MANAGER:UnregisterForEvent(MotD.addonName, EVENT_PLAYER_ACTIVATED)
end

function MotD.OnGuildMotdChanged(eventCode, guildID)
  if guildID ~= MotD.savedVariables.mainGuildID then return end
  local motdChangedString = MotD.CreateMotDChangedString(MotD.savedVariables.mainGuildID)
  CHAT_SYSTEM["containers"][1]["currentBuffer"]:AddMessage(motdChangedString) 
end

-- Settings menu --------------------------------------------------------------
function MotD.CreateSettingsMenu()
    
    local bIsOfficer = DoesPlayerHaveGuildPermission(MotD.savedVariables.mainGuildID,GUILD_PERMISSION_OFFICER_CHAT_READ)
    local guildList={}
    for index=1, 5, 1 do
      if GetGuildName(index) == "" then break end   
      guildList[index] = GetGuildName(index)
            
    end  
    

   local panelData = {
      type = "panel",
      name = MotD.addonName,
      displayName = "|cFFAA33"..MotD.addonName.."|r",
      author = "Carter_DC",
      version = MotD.version,
      registerForRefresh = true,
      registerForDefaults = true,
   }
   LAM:RegisterAddonPanel(MotD.addonName.."_LAM", panelData)

   local optionsTable = 
   {
      [1] = {
        type = "description",
        text = GetString(MOTD_DESCRIPTION),
      },
      [2] = {
        type = "header",
        --name = "OPTIONS",
        width = "full",
      },
      [3] ={
        type = "dropdown",
        name = GetString(MOTD_GUILD_PICKER),
        tooltip = GetString(MOTD_TOOLTIP_GUILD),
        choices = guildList,
        getFunc = function() return guildList[MotD.savedVariables.mainGuildID] end,
        setFunc = function(selected)
          for index, name in ipairs(guildList) do
            if name == selected then
              MotD.savedVariables.mainGuildID = index
            break
            end
          end   
        end,
        default = guildList[MotD.defaults.mainGuildID],
      },
      [4] = {
        type = "colorpicker",
        name = GetString(MOTD_MOTD_COLOR),
        tooltip = GetString(MOTD_TOOLTIP_COLOR),
        getFunc = function()
              local r, g, b, a = MotD.HexToRGBA(MotD.savedVariables.motdColor)
              return r, g, b
              
        end,
        setFunc = function(r, g, b)
              --d(r..", "..g..", "..b..", "..MotD.RGBAToHex(r, g, b, 1))
              MotD.savedVariables.motdColor = MotD.RGBAToHex(r, g, b, 1)
              
        end
      },
      [5] = {
        type = "colorpicker",
        name = GetString(MOTD_GUILD_COLOR),
        tooltip = GetString(MOTD_TOOLTIP_COLOR),
        getFunc = function()
              local r, g, b, a = MotD.HexToRGBA(MotD.savedVariables.guildColor)
              return r, g, b
        end,
        setFunc = function(r, g, b)
              MotD.savedVariables.guildColor = MotD.RGBAToHex(r, g, b, 1)
              
        end
      },
    }
   
   
   
   LAM:RegisterOptionControls(MotD.addonName.."_LAM", optionsTable)
   
end


function MotD.CreateMotDString(guildID)
  local guildColor = string.sub(MotD.savedVariables.guildColor, 1, 6)
  local motdColor = string.sub(MotD.savedVariables.motdColor, 1, 6)
--  
  return GetString(MOTD_WELCOME).." |c"..guildColor..GetGuildName(MotD.savedVariables.mainGuildID).."|r"..string.char(13,10)..GetString(MOTD_MOTD).." : |c"..motdColor..GetGuildMotD(MotD.savedVariables.mainGuildID).."|r"
end

function MotD.CreateMotDChangedString(guildID)
  local guildColor = string.sub(MotD.savedVariables.guildColor, 1, 6)
  local motdColor = string.sub(MotD.savedVariables.motdColor, 1, 6)
--  
  return GetString(MOTD_CHANGED)..string.char(13,10).." |c"..guildColor..GetGuildName(MotD.savedVariables.mainGuildID).." : |r"..string.char(13,10).."|c"..motdColor..GetGuildMotD(MotD.savedVariables.mainGuildID).."|r"
end


-- Usefull functions shamelessly stolen (and fixed) from Research Assistant Addon By IngeniousClown--

function MotD.RGBAToHex( r, g, b, a )
  if r>1 then r=1 end
  if g>1 then g=1 end
  if b>1 then b=1 end
  
  r = r <= 1 and r >= 0 and r or 0
  g = g <= 1 and g >= 0 and g or 0
  b = b <= 1 and b >= 0 and b or 0
  return string.format("%02x%02x%02x%02x", r * 255, g * 255, b * 255, a * 255)
end

function MotD.HexToRGBA( hex )
    local rhex, ghex, bhex, ahex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
    return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end


EVENT_MANAGER:RegisterForEvent(MotD.addonName, EVENT_ADD_ON_LOADED, MotD.OnAddOnLoaded)
