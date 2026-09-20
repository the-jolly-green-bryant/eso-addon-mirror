darkui = darkui or {}
local LAM = LibAddonMenu2
local themes = { GetString(DARKUI_DARK), GetString(DARKUI_LIGHT), GetString(DARKUI_MIXED) }
local panelData = { type="panel", name="DarkUI HUD", displayName="|c7f7f7fDark|cada684UI|r HUD", author="|cada684Jhenox|r", registerForDefaults=true, registerForRefresh=true, version=darkui.version, slashCommand="/darkui" }
local optionsData = {
  { type="description", text="PS5 HUD Edition: only in-game HUD textures are changed. Menus and windows stay native." },
  { type="dropdown", name=GetString(DARKUI_COLOR_THEME_NAME), tooltip=GetString(DARKUI_COLOR_THEME_TOOLTIP), choices=themes, default=GetString(DARKUI_DARK), getFunc=function() return darkui.SV.Icon end, setFunc=function(v) darkui.SV.Icon=v end },
  { type="checkbox", name=GetString(DARKUI_DARKER_BARS_NAME), tooltip=GetString(DARKUI_DARKER_BARS_TOOLTIP), default=false, getFunc=function() return darkui.SV.Darker_Bars end, setFunc=function(v) darkui.SV.Darker_Bars=v end },
  { type="checkbox", name="Hide group frame background", default=false, getFunc=function() return darkui.SV.Hide_Group_Frame_Background end, setFunc=function(v) darkui.SV.Hide_Group_Frame_Background=v end },
  { type="checkbox", name=GetString(DARKUI_HIDE_STATUS_METER_BACKGROUND_NAME), tooltip=GetString(DARKUI_HIDE_STATUS_METER_BACKGROUND_TOOLTIP), default=false, getFunc=function() return darkui.SV.Hide_Status_Meter_Background end, setFunc=function(v) darkui.SV.Hide_Status_Meter_Background=v end },
  { type="button", name="Reload UI", tooltip=GetString(DARKUI_RELOAD), width="full", func=function() ReloadUI("ingame") end },
}
function darkui:initLAM() LAM:RegisterOptionControls("DarkUI", optionsData); LAM:RegisterAddonPanel("DarkUI", panelData) end
