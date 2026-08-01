--GuildChatColors = GuildChatColors or {}
local GCC = GuildChatColors
if LibAddonMenu2 then GCC.LAM = LibAddonMenu2 else GCC.LAM = nil end
-----------------------------------
function GCC:CreateOptionsPanel()
  local Lang = self.i18n
  local tinsert = table.insert
  local OptPanel = {
    type = "panel",
    name = "Guild Chat Colors",
    author = "|c779cff" .. GCC.Author .. "|r",
    version = GCC.Version,
    registerForRefresh = true,
    registerForDefaults = true,
  } -- OptPanel end
--===========================================--
--== Section with static elements of panel ==--
--===========================================--
  local OptionsMenu = {
    --=====================--
    --== General Options ==--
    --=====================--
    { type = "divider", width = "full", },
    { type = "submenu",
     name = ZO_HIGHLIGHT_TEXT:Colorize(Lang.OptGeneralMenu),
     tooltip = Lang.OptGeneralMenuTT or Lang.OptGeneralMenu,
     controls = {
       { type = "divider", width = "full", },
       { type = "checkbox",
        name = Lang.OptAlwaysSetColors,
        tooltip = Lang.OptAlwaysSetColorsTT or Lang.OptAlwaysSetColors,
        getFunc = function() return GCC.GetVarByName("AlwaysSetColors") end,
        setFunc = function(value) GCC.SetVarByName("AlwaysSetColors", value) end,
        disabled = false,
        default = false, },
       { type = "divider", width = "full", },
       --========================================--
       { type = "checkbox",
        name = Lang.OptUseGlobalColors,
        tooltip = Lang.OptUseGlobalColorsTT or Lang.OptUseGlobalColors,
        getFunc = function() return GCC.GetVarByName("UseGlobalColors") end,
        setFunc = function(value) GCC.SetVarByName("UseGlobalColors", value) end,
        disabled = false,
        default = true, },
       --========================================--
       { type = "checkbox",
        name = Lang.OptUseRealmColors,
        tooltip = Lang.OptUseRealmColorsTT or Lang.OptUseRealmColors,
        getFunc = function() return GCC.GetVarByName("UseRealmColors") end,
        setFunc = function(value) GCC.SetVarByName("UseRealmColors", value) end,
        disabled = function() return GCCGlobal["Global"].isUseGlobalColors end,
        default = true, },
       --========================================--
       { type = "checkbox",
        name = Lang.OptUseAccountColors,
        tooltip = Lang.OptUseAccountColorsTT or Lang.OptUseAccountColors,
        getFunc = function() return GCC.GetVarByName("UseAccountColors") end,
        setFunc = function(value) GCC.SetVarByName("UseAccountColors", value) end,
        disabled = function() return (GCCGlobal["Global"].isUseGlobalColors or GCCGlobal["Global"].isUseRealmColors) end,
        default = true, },
       --========================================--
     }, -- controls end
    }, -- General options submenu end
    --========================--
    --== Additional Options ==--
    --========================--
    { type = "divider", width = "full", },
    { type = "submenu",
     name = ZO_HIGHLIGHT_TEXT:Colorize(Lang.OptAdditionalMenu),
     tooltip = Lang.OptAdditionalMenuTT or Lang.OptAdditionalMenu,
     controls = {
       { type = "divider", width = "full", },
       { type = "checkbox",
        name = Lang.OptSetGroupColors,
        tooltip = Lang.OptSetGroupColorsTT or Lang.OptSetGroupColors,
        getFunc = function() return GCC.GetVarByName("SetGroupColor") end,
        setFunc = function(value) GCC.SetVarByName("SetGroupColor", value) end,
        disabled = false,
        default = false, },
       --========================================--
       { type = "colorpicker",
        name = Lang.OptGroupColors,
        tooltip = Lang.OptGroupColorsTT or Lang.OptGroupColors,
        getFunc = function()
                    local r, g, b, a = GCC.GetVarByName("GroupColor")
                    return r, g, b, a
                  end,
        setFunc = function(r, g, b, a)
                    local C = {R = r, G = g, B = b}
                    GCC.SetVarByName("GroupColor", C)
                  end,
        disabled = function() return (not GCCGlobal["Global"].isSetGroupColors) end,
        default = function()
                    local r, g, b, a = GCC.GetVarByName("DefaultGroup")
                    return {r = r, g = g, b = b, a = 1}
                  end,
        width = "full", },
       { type = "divider", width = "full", },
       --========================================--
       { type = "checkbox",
        name = Lang.OptSetSystemColors,
        tooltip = Lang.OptSetSystemColorsTT or Lang.OptSetSystemColors,
        getFunc = function() return GCC.GetVarByName("SetSystemColor") end,
        setFunc = function(value) GCC.SetVarByName("SetSystemColor", value) end,
        disabled = false,
        default = false, },
       --========================================--
       { type = "colorpicker",
        name = Lang.OptSystemColors,
        tooltip = Lang.OptSystemColorsTT or Lang.OptSystemColors,
        getFunc = function()
                    local r, g, b, a = GCC.GetVarByName("SystemColor")
                    return r, g, b, a
                  end,
        setFunc = function(r, g, b, a)
                    local C = {R = r, G = g, B = b}
                    GCC.SetVarByName("SystemColor", C)
                  end,
        disabled = function() return (not GCCGlobal["Global"].isSetSystemColors) end,
        default = function()
                    local r, g, b, a = GCC.GetVarByName("DefaultSystem")
                    return {r = r, g = g, b = b, a = 1}
                  end,
        width = "full", },
       { type = "divider", width = "full", },
       --========================================--
       { type = "checkbox",
        name = Lang.OptSetChatFontSize,
        tooltip = Lang.OptSetChatFontSizeTT or Lang.OptSetChatFontSize,
        getFunc = function() return GCC.GetVarByName("SetChatFontSize") end,
        setFunc = function(value) GCC.SetVarByName("SetChatFontSize", value) end,
        disabled = false,
        default = false, },
       --========================================--
       { type = "slider",
        name = Lang.OptChatFontSize,
        tooltip = Lang.OptChatFontSizeTT or Lang.OptChatFontSize,
        min = 8,
        max = 24,
        step = 1,
        decimals = 0,
        clampInput = true,
        clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
        autoSelect = false,
        readOnly = true,
        width = "full",
        getFunc = function() return GCC.GetVarByName("ChatFontSize") end,
        setFunc = function(value) GCC.SetVarByName("ChatFontSize", value) end,
        disabled = function() return (not GCCGlobal["Global"].isSetChatFontSize) end,
        requiresReload = false,
        default = 18, },
       { type = "divider", width = "full", },
       --========================================--
     }, -- controls end
    }, -- Additional options submenu end
  --============================================--
  --== Section with dynamic elements of panel ==--
  --============================================--
  } -- OptionsMenu end

  --=======================================--
  --== Default Guild Chat Colors options ==--
  --=======================================--
  tinsert( OptionsMenu, { type = "divider", width = "full",} )
  tinsert( OptionsMenu, { type = "submenu",
          name = ZO_HIGHLIGHT_TEXT:Colorize(Lang.OptDefaultColorsMenu),
          tooltip = Lang.OptDefaultColorsMenuTT or Lang.OptDefaultColorsMenu,
          controls = {},} )
  local SubmenuCtrl = OptionsMenu[#OptionsMenu].controls -- link to last submenu
  for i = 1, MAX_GUILDS do
    tinsert( SubmenuCtrl, { type = "divider", width = "full",} )
    tinsert( SubmenuCtrl, { type = "colorpicker",
            name = zo_strformat(GetString(SI_EMPTY_GUILD_CHANNEL_NAME), i),
            tooltip = GetString( (SI_SOCIAL_OPTIONS_GUILD1_COLOR_TOOLTIP - 2 + (i * 2) ) ),
            getFunc = function()
                        --- slot, channel (1 guild, 2 officer) ---
                        local r, g, b, a = GCC.GetVarByName("ColorChannel", i, 1)
                        return r, g, b, a
                      end,
            setFunc = function(r, g, b, a)
                        local C = {R = r, G = g, B = b}
                        --- color, slot, channel (1 guild, 2 officer), gis (or nil) ---
                        GCC.SetVarByName("ColorChannel", C, i, 1)
                      end,
            disabled = false,
            default = function()
                        local r, g, b, a = GCC.GetVarByName("DefaultGuild")
                        return {r = r, g = g, b = b, a = 1}
                      end,
            width = "full",} )
    tinsert( SubmenuCtrl, { type = "colorpicker",
            name = zo_strformat(GetString(SI_EMPTY_OFFICER_CHANNEL_NAME), i),
            tooltip = GetString( (SI_SOCIAL_OPTIONS_OFFICER1_COLOR_TOOLTIP - 2 + (i * 2) ) ),
            getFunc = function()
                        --- slot, channel (1 guild, 2 officer) ---
                        local r, g, b, a = GCC.GetVarByName("ColorChannel", i, 2)
                        return r, g, b, a
                      end,
            setFunc = function(r, g, b, a)
                        local C = {R = r, G = g, B = b}
                        --- color, slot, channel (1 guild, 2 officer), gis (or nil) ---
                        GCC.SetVarByName("ColorChannel", C, i, 2)
                      end,
            disabled = false,
            default = function()
                        local r, g, b, a = GCC.GetVarByName("DefaultOfficer")
                        return {r = r, g = g, b = b, a = 1}
                      end,
            width = "full",} )
  end
  --=====================================--
  --== Named Guild Chat Colors options ==--
  --=====================================--
  tinsert( OptionsMenu, { type = "divider", width = "full",} )
  tinsert( OptionsMenu, { type = "submenu",
          name = ZO_HIGHLIGHT_TEXT:Colorize(Lang.OptNamedColorsMenu),
          tooltip = Lang.OptNamedColorsMenuTT or Lang.OptNamedColorsMenu,
          controls = {},} )
  SubmenuCtrl = OptionsMenu[#OptionsMenu].controls -- link to last submenu
  for i = 1, GetNumGuilds() do
    local GID = GetGuildId(i) or 0
    if GID > 0 then
      local GIS = tostring(GID)
      tinsert( SubmenuCtrl, { type = "divider", width = "full",} )
      tinsert( SubmenuCtrl, { type = "description",
              title = nil,
              text = ZO_HIGHLIGHT_TEXT:Colorize( GetGuildName(GID) ),
              width = "full",} )
      tinsert( SubmenuCtrl, { type = "colorpicker",
              name = GetString(SI_EMPTY_GUILD_CHANNEL_NAME):gsub("% .+", ""),
              getFunc = function()
                          --- slot, channel (1 guild, 2 officer), GIS (or nil) ---
                          local r, g, b, a = GCC.GetVarByName("ColorChannel", i, 1, GIS)
                          return r, g, b, a
                        end,
              setFunc = function(r, g, b, a)
                          local C = {R = r, G = g, B = b}
                          --- color, slot, channel (1 guild, 2 officer), gis (or nil) ---
                          GCC.SetVarByName("ColorChannel", C, i, 1, GIS)
                        end,
              disabled = false,
              default = function()
                          local r, g, b, a = GCC.GetVarByName("DefaultGuild")
                          return {r = r, g = g, b = b, a = 1}
                        end,
              width = "full",} )
      tinsert( SubmenuCtrl, { type = "colorpicker",
              name = GetString(SI_EMPTY_OFFICER_CHANNEL_NAME):gsub("% .+", ""),
              getFunc = function()
                          --- slot, channel (1 guild, 2 officer), GIS (or nil) ---
                          local r, g, b, a = GCC.GetVarByName("ColorChannel", i, 2, GIS)
                          return r, g, b, a
                        end,
              setFunc = function(r, g, b, a)
                          local C = {R = r, G = g, B = b}
                          --- color, slot, channel (1 guild, 2 officer), gis (or nil) ---
                          GCC.SetVarByName("ColorChannel", C, i, 2, GIS)
                        end,
              disabled = false,
              default = function()
                          local r, g, b, a = GCC.GetVarByName("DefaultOfficer")
                          return {r = r, g = g, b = b, a = 1}
                        end,
              width = "full",} )
    end
  end

  --== Register Option Controls ==--
  if self.LAM then
    self.LAM:RegisterAddonPanel("GuildChatColorsOptionsPanel", OptPanel)
    self.LAM:RegisterOptionControls("GuildChatColorsOptionsPanel", OptionsMenu)
  end
end -- CreateOptionsPanel end
