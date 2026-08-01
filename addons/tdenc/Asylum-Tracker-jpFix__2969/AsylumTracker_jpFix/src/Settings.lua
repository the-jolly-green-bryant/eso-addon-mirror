local AST = AsylumTracker
local locales = {
     ["English"] = "en",
     ["Français"] = "fr",
     ["Deutsche"] = "de",
     ["日本語"] = "jp",
}

function AST.CreateSettingsWindow()
     local LAM2 = LibAddonMenu2
     local sv = AsylumTrackerVars["Default"][GetDisplayName()][GetCurrentCharacterId()]

     local panelData = {
          type = "panel",
          name = "Asylum Tracker",
          displayName = "|cAD601C" .. GetString(AST_SETT_HEADER) .. "|r",
          author = "|cAD601C" .. AST.author .. "|r",
          version = "|cAD601C" .. AST.version .. "|r",
          website = "https://www.esoui.com/downloads/info2111-AST.html",
          feedback = "https://www.esoui.com/downloads/info2111-AST.html#comments",
          translation = "https://github.com/3tini/AsylumTracker/tree/dev/locales",
          registerForRefresh = true,
     }
     local panel = LAM2:RegisterAddonPanel(AST.name .. "Settings", panelData)

     local Settings = {
          {
               type = "header",
               name = "|cAD601C" .. GetString(AST_SETT_INFO) .. "|r",
               width = "full"
          },
          {
               type = "description",
               text = "|c513DEB" .. GetString(AST_SETT_DESCRIPTION) .. "|r",
               width = "full"
          },
          {
               type = "button",
               name = AST_SETT_UNLOCK,
               tooltip = AST_SETT_UNLOCK_TOOL,
               func = function(value)
                    AST.ToggleMovable()
                    if not AST.isMovable then
                         value:SetText(GetString(AST_SETT_UNLOCK))
                    else
                         value:SetText(GetString(AST_SETT_LOCK))
                    end
               end,
               width = "half",
          },
          {
               type = "button",
               name = AST_SETT_CENTER_NOTIF,
               tooltip = AST_SETT_CENTER_NOTIF_TOOL,
               func = function() AST.ResetToDefaults() end,
               width = "half",
          },
          {
               type = "checkbox",
               name = AST_SETT_SOUND_EFFECT,
               tooltip = AST_SETT_SOUND_EFFECT_TOOL,
               getFunc = function() return sv.sound_enabled end,
               setFunc = function(value) sv.sound_enabled = value end,
               default = true,
               width = "full",
          },
          {
               type = "checkbox",
               name = AST_SETT_LLOTHIS_NOTIF,
               tooltip = AST_SETT_LLOTHIS_NOTIF_TOOL,
               getFunc = function()
                    return sv.llothis_notifications
               end,
               setFunc = function(value) sv.llothis_notifications = value end,
               default = true,
               width = "full",
          },
          {
               type = "checkbox",
               name = AST_SETT_FELMS_NOTIF,
               tooltip = AST_SETT_FELMS_NOTIF_TOOL,
               getFunc = function()
                    return sv.felms_notifications
               end,
               setFunc = function(value) sv.felms_notifications = value end,
               default = true,
               width = "full",
          },
          {
               type = "colorpicker",
               name = AST_SETT_TIMER_COLOR,
               tooltip = AST_SETT_TIMER_COLOR_TOOL,
               getFunc = function() return unpack(sv.color_timer) end,
               setFunc = function(r, g, b, a) sv.color_timer = {r, g, b, a} end,
               width = "full",
          },
          {
               type = "submenu",
               name = "|cAD601C" .. GetString(AST_SETT_NOTIFICATIONS) .. "|r",
               controls = {
                    {
                         type = "slider",
                         name = AST_SETT_OLMS_HP_SIZE,
                         tooltip = AST_SETT_OLMS_HP_SIZE_TOOL,
                         getFunc = function() return sv.font_size_olms_hp end,
                         setFunc = function(value) sv.font_size_olms_hp = value AST.SetFontSize(AsylumTrackerOlmsHP, AsylumTrackerOlmsHPLabel, value) end,
                         min = 38,
                         max = 72,
                         step = 2,
                         default = 48,
                         width = "full",
                    },
                    {
                         type = "slider",
                         name = AST_SETT_OLMS_HP_SCALE,
                         tooltip = AST_SETT_OLMS_HP_SCALE_TOOL,
                         warning = AST_SETT_SCALE_WARN,
                         getFunc = function() return sv.olms_hp_scale end,
                         setFunc = function(value) sv.olms_hp_scale = value AST.SetScale(AsylumTrackerOlmsHPLabel, value) end,
                         min = 0.5,
                         max = 2,
                         step = 0.1,
                         default = 1,
                         width = "full",
                    },
                    {
                         type = "colorpicker",
                         name = AST_SETT_COLOR_1,
                         tooltip = AST_SETT_OLMS_HP_COLOR_1_TOOL,
                         getFunc = function() return unpack(sv.color_olms_hp) end,
                         setFunc = function(r, g, b, a)
                              sv.color_olms_hp = {r, g, b, a}
                              AST.ToggleMovable() AST.ToggleMovable()
                         end,
                         width = "full",
                    },
                    {
                         type = "colorpicker",
                         name = AST_SETT_COLOR_2,
                         tooltip = AST_SETT_OLMS_HP_COLOR_2_TOOL,
                         getFunc = function() return unpack(sv.color_olms_hp2) end,
                         setFunc = function(r, g, b, a)
                              sv.color_olms_hp2 = {r, g, b, a}
                              AsylumTrackerOlmsHPLabel:SetColor(unpack(sv.color_olms_hp2))
                              AST.ToggleMovable() AST.ToggleMovable()
                         end,
                         width = "full",
                    },
                    {
                         type = "header",
                         width = "full",
                    },
                    {
                         type = "checkbox",
                         name = AST_SETT_STORM,
                         tooltip = AST_SETT_STORM_TOOL,
                         getFunc = function() return sv.storm_the_heavens end,
                         setFunc =
                         function(value)
                              sv.storm_the_heavens = value
                              AST.ToggleMovable()
                              AST.ToggleMovable()
                         end,
                         default = true,
                         width = "full",
                    },
                    {
                         type = "slider",
                         name = AST_SETT_FONT_SIZE,
                         tooltip = AST_SETT_STORM_SIZE_TOOL,
                         getFunc = function() return sv.font_size_storm end,
                         setFunc = function(value) sv.font_size_storm = value AST.SetFontSize(AsylumTrackerStorm, AsylumTrackerStormLabel, value) end,
                         min = 38,
                         max = 72,
                         step = 2,
                         default = 48,
                         width = "full",
                         disabled = function() return not sv.storm_the_heavens end,
                    },
                    {
                         type = "slider",
                         name = AST_SETT_SCALE,
                         tooltip = AST_SETT_STORM_SCALE_TOOL,
                         warning = AST_SETT_SCALE_WARN,
                         getFunc = function() return sv.storm_scale end,
                         setFunc = function(value) sv.storm_scale = value AST.SetScale(AsylumTrackerStormLabel, value) end,
                         min = 0.5,
                         max = 2,
                         step = 0.1,
                         default = 1,
                         width = "full",
                         disabled = function() return not sv.storm_the_heavens end,
                    },
                    {
                         type = "colorpicker",
                         name = AST_SETT_COLOR_1,
                         tooltip = AST_SETT_STORM_COLOR_1_TOOL,
                         getFunc = function() return unpack(sv.color_storm) end,
                         setFunc = function(r, g, b, a)
                              sv.color_storm = {r, g, b, a}
                              AsylumTrackerStormLabel:SetColor(unpack(sv.color_storm))
                              AST.ToggleMovable() AST.ToggleMovable()
                         end,
                         width = "full",
                         disabled = function() return not sv.storm_the_heavens end,
                    },
                    {
                         type = "colorpicker",
                         name = AST_SETT_COLOR_2,
                         tooltip = AST_SETT_STORM_COLOR_2_TOOL,
                         getFunc = function() return unpack(sv.color_storm2) end,
                         setFunc = function(r, g, b, a)
                              sv.color_storm2 = {r, g, b, a}
                              AST.ToggleMovable() AST.ToggleMovable()
                         end,
                         width = "full",
                         disabled = function() return not sv.storm_the_heavens end,
                    },
                    {
                         type = "dropdown",
                         name = AST_SETT_STORM_SOUND_EFFECT,
                         tooltip = AST_SETT_STORM_SOUND_EFFECT_TOOL,
                         scrollable = true,
                         choices = AST.GetSounds(),
                         getFunc = function() return sv.storm_the_heavens_sound end,
                         setFunc = function(value) sv.storm_the_heavens_sound = value end,
                         width = "full",
                         disabled = function() return not sv.storm_the_heavens or not sv.sound_enabled end
                    },
                    {
                         type = "slider",
                         name = AST_SETT_STORM_SOUND_EFFECT_VOLUME,
                         tooltip = AST_SETT_STORM_SOUND_EFFECT_VOLUME_TOOL,
                         getFunc = function() return sv.storm_the_heavens_volume end,
                         setFunc = function(value) sv.storm_the_heavens_volume = value end,
                         min = 1,
                         max = 15,
                         step = 1,
                         default = 1,
                         width = "full",
                         disabled = function() return not sv.storm_the_heavens or not sv.sound_enabled end
                    },
                    {
                         type = "button",
                         name = "Test",
                         tooltip = "Test Sound Effect",
                         func = function(value)
                              AST.LoopSound(sv.storm_the_heavens_volume, sv.storm_the_heavens_sound)
                         end,
                         width = "full",
                         disabled = function() return not sv.storm_the_heavens or not sv.sound_enabled end
                    },
                    {
                         type = "header",
                         width = "full",
                    },
                    {
                         type = "checkbox",
                         name = AST_SETT_BLAST,
                         tooltip = AST_SETT_BLAST_TOOL,
                         getFunc = function() return sv.defiling_blast end,
                         setFunc = function(value)
                              sv.defiling_blast = value
                              AST.ToggleMovable()
                              AST.ToggleMovable()
                         end,
                         default = true,
                         width = "full",
                    },
                    {
                         type = "slider",
                         name = AST_SETT_FONT_SIZE,
                         tooltip = AST_SETT_BLAST_SIZE_TOOL,
                         getFunc = function() return sv.font_size_blast end,
                         setFunc = function(value) sv.font_size_blast = value AST.SetFontSize(AsylumTrackerBlast, AsylumTrackerBlastLabel, value) end,
                         min = 38,
                         max = 72,
                         step = 2,
                         default = 48,
                         width = "full",
                         disabled = function() return not sv.defiling_blast end,
                    },
                    {
                         type = "slider",
                         name = AST_SETT_SCALE,
                         tooltip = AST_SETT_BLAST_SCALE_TOOL,
                         warning = AST_SETT_SCALE_WARN,
                         getFunc = function() return sv.blast_scale end,
                         setFunc = function(value) sv.blast_scale = value AST.SetScale(AsylumTrackerBlastLabel, value) end,
                         min = 0.5,
                         max = 2,
                         step = 0.1,
                         default = 1,
                         width = "full",
                         disabled = function() return not sv.defiling_blast end,
                    },
                    {
                         type = "colorpicker",
                         name = AST_SETT_COLOR,
                         tooltip = AST_SETT_BLAST_COLOR_TOOL,
                         getFunc = function() return unpack(sv.color_blast) end,
                         setFunc = function(r, g, b, a)
                              sv.color_blast = {r, g, b, a}
                              AsylumTrackerBlastLabel:SetColor(unpack(sv.color_blast))
                              AST.ToggleMovable() AST.ToggleMovable()
                         end,
                         width = "full",
                         disabled = function() return not sv.defiling_blast end,
                    },
                    {
                         type = "dropdown",
                         name = AST_SETT_BLAST_SOUND_EFFECT,
                         tooltip = AST_SETT_BLAST_SOUND_EFFECT_TOOL,
                         scrollable = true,
                         choices = AST.GetSounds(),
                         getFunc = function() return sv.defiling_blast_sound end,
                         setFunc = function(value) sv.defiling_blast_sound = value end,
                         width = "full",
                         disabled = function() return not sv.defiling_blast or not sv.sound_enabled end
                    },
                    {
                         type = "slider",
                         name = AST_SETT_BLAST_SOUND_EFFECT_VOLUME,
                         tooltip = AST_SETT_BLAST_SOUND_EFFECT_VOLUME_TOOL,
                         getFunc = function() return sv.defiling_blast_volume end,
                         setFunc = function(value) sv.defiling_blast_volume = value end,
                         min = 1,
                         max = 15,
                         step = 1,
                         default = 1,
                         width = "full",
                         disabled = function() return not sv.defiling_blast or not sv.sound_enabled end
                    },
                    {
                         type = "button",
                         name = "Test",
                         tooltip = "Test Sound Effect",
                         func = function(value)
                              AST.LoopSound(sv.defiling_blast_volume, sv.defiling_blast_sound)
                         end,
                         width = "full",
                         disabled = function() return not sv.defiling_blast or not sv.sound_enabled end
                    },
                    {
                         type = "header",
                         width = "full",
                    },
                    {
                         type = "checkbox",
                         name = AST_SETT_PROTECT,
                         tooltip = AST_SETT_PROTECT_TOOL,
                         getFunc = function() return sv.static_shield end,
                         setFunc = function(value)
                              sv.static_shield = value
                              AST.ToggleMovable()
                              AST.ToggleMovable()
                         end,
                         default = true,
                         width = "full",
                    },
                    {
                         type = "slider",
                         name = AST_SETT_FONT_SIZE,
                         tooltip = AST_SETT_PROTECT_SIZE_TOOL,
                         getFunc = function() return sv.font_size_sphere end,
                         setFunc = function(value) sv.font_size_sphere = value AST.SetFontSize(AsylumTrackerSphere, AsylumTrackerSphereLabel, value) end,
                         min = 38,
                         max = 72,
                         step = 2,
                         default = 48,
                         width = "full",
                         disabled = function() return not sv.static_shield end,
                    },
                    {
                         type = "slider",
                         name = AST_SETT_SCALE,
                         tooltip = AST_SETT_PROTECT_SCALE_TOOL,
                         warning = AST_SETT_SCALE_WARN,
                         getFunc = function() return sv.sphere_scale end,
                         setFunc = function(value) sv.sphere_scale = value AST.SetScale(AsylumTrackerSphereLabel, value) end,
                         min = 0.5,
                         max = 2,
                         step = 0.1,
                         default = 1,
                         width = "full",
                         disabled = function() return not sv.static_shield end,
                    },
                    {
                         type = "colorpicker",
                         name = AST_SETT_COLOR_1,
                         tooltip = AST_SETT_PROTECT_COLOR_1_TOOL,
                         getFunc = function() return unpack(sv.color_sphere) end,
                         setFunc = function(r, g, b, a)
                              sv.color_sphere = {r, g, b, a}
                              AsylumTrackerSphereLabel:SetColor(unpack(sv.color_sphere))
                              AST.ToggleMovable() AST.ToggleMovable()
                         end,
                         width = "full",
                         disabled = function() return not sv.static_shield end,
                    },
                    {
                         type = "colorpicker",
                         name = AST_SETT_COLOR_2,
                         tooltip = AST_SETT_PROTECT_COLOR_2_TOOL,
                         getFunc = function() return unpack(sv.color_sphere2) end,
                         setFunc = function(r, g, b, a)
                              sv.color_sphere2 = {r, g, b, a}
                              AST.ToggleMovable() AST.ToggleMovable()
                         end,
                         width = "full",
                         disabled = function() return not sv.static_shield end,
                    },
                    {
                         type = "checkbox",
                         name = AST_SETT_PROTECT_MESSAGE,
                         tooltip = AST_SETT_PROTECT_MESSAGE_TOOL,
                         getFunc = function() return sv.sphere_message_toggle end,
                         setFunc = function(value)
                              sv.sphere_message_toggle = value
                              AST.ToggleMovable()
                              AST.ToggleMovable()
                         end,
                         default = true,
                         width = "full",
                    },
                    {
                         type = "editbox",
                         name = "",
                         getFunc = function() return sv.sphere_message end,
                         setFunc = function(value)
                              sv.sphere_message = value
                              ZO_CreateStringId("AST_NOTIF_PROTECTOR", value)
                         end,
                         width = "full",
                         disabled = function() return not sv.sphere_message_toggle end,
                    },
                    {
                         type = "header",
                         width = "full",
                    },
                    {
                         type = "checkbox",
                         name = AST_SETT_JUMP,
                         tooltip = AST_SETT_JUMP_TOOL,
                         getFunc = function() return sv.teleport_strike end,
                         setFunc = function(value)
                              sv.teleport_strike = value
                              AST.ToggleMovable()
                              AST.ToggleMovable()
                         end,
                         default = false,
                         width = "full",
                    },
                    {
                         type = "slider",
                         name = AST_SETT_FONT_SIZE,
                         tooltip = AST_SETT_JUMP_SIZE_TOOL,
                         getFunc = function() return sv.font_size_teleport_strike end,
                         setFunc = function(value) sv.font_size_teleport_strike = value AST.SetFontSize(AsylumTrackerTeleportStrike, AsylumTrackerTeleportStrikeLabel, value) end,
                         min = 38,
                         max = 72,
                         step = 2,
                         default = 48,
                         width = "full",
                         disabled = function() return not sv.teleport_strike end,
                    },
                    {
                         type = "slider",
                         name = AST_SETT_SCALE,
                         tooltip = AST_SETT_JUMP_SCALE_TOOL,
                         warning = AST_SETT_SCALE_WARN,
                         getFunc = function() return sv.teleport_strike_scale end,
                         setFunc = function(value) sv.teleport_strike_scale = value AST.SetScale(AsylumTrackerTeleportStrikeLabel, value) end,
                         min = 0.5,
                         max = 2,
                         step = 0.1,
                         default = 1,
                         width = "full",
                         disabled = function() return not sv.teleport_strike end,
                    },
                    {
                         type = "colorpicker",
                         name = AST_SETT_COLOR,
                         tooltip = AST_SETT_JUMP_COLOR_TOOL,
                         getFunc = function() return unpack(sv.color_teleport_strike) end,
                         setFunc = function(r, g, b, a)
                              sv.color_teleport_strike = {r, g, b, a}
                              AsylumTrackerTeleportStrikeLabel:SetColor(unpack(sv.color_teleport_strike))
                              AST.ToggleMovable() AST.ToggleMovable()
                         end,
                         width = "full",
                         disabled = function() return not sv.teleport_strike end,
                    },
                    {
                         type = "header",
                         width = "full",
                    },
                    {
                         type = "checkbox",
                         name = AST_SETT_BOLTS,
                         tooltip = AST_SETT_BOLTS_TOOL,
                         getFunc = function() return sv.oppressive_bolts end,
                         setFunc = function(value)
                              sv.oppressive_bolts = value
                              AST.ToggleMovable()
                              AST.ToggleMovable()
                         end,
                         default = false,
                         width = "full",
                    },
                    {
                         type = "slider",
                         name = AST_SETT_FONT_SIZE,
                         tooltip = AST_SETT_BOLTS_SIZE_TOOL,
                         getFunc = function() return sv.font_size_oppressive_bolts end,
                         setFunc = function(value) sv.font_size_oppressive_bolts = value AST.SetFontSize(AsylumTrackerOppressiveBolts, AsylumTrackerOppressiveBoltsLabel, value) end,
                         min = 38,
                         max = 72,
                         step = 2,
                         default = 48,
                         width = "full",
                         disabled = function() return not sv.oppressive_bolts end,
                    },
                    {
                         type = "slider",
                         name = AST_SETT_SCALE,
                         tooltip = AST_SETT_BOLTS_SCALE_TOOL,
                         warning = AST_SETT_SCALE_WARN,
                         getFunc = function() return sv.oppressive_bolts_scale end,
                         setFunc = function(value) sv.oppressive_bolts_scale = value AST.SetScale(AsylumTrackerOppressiveBoltsLabel, value) end,
                         min = 0.5,
                         max = 2,
                         step = 0.1,
                         default = 1,
                         width = "full",
                         disabled = function() return not sv.oppressive_bolts end,
                    },
                    {
                         type = "colorpicker",
                         name = AST_SETT_COLOR,
                         tooltip = AST_SETT_BOLTS_COLOR_TOOL,
                         getFunc = function() return unpack(sv.color_oppressive_bolts) end,
                         setFunc = function(r, g, b, a)
                              sv.color_oppressive_bolts = {r, g, b, a}
                              AsylumTrackerOppressiveBoltsLabel:SetColor(unpack(sv.color_oppressive_bolts))
                              AST.ToggleMovable() AST.ToggleMovable()
                         end,
                         width = "full",
                         disabled = function() return not sv.oppressive_bolts end,
                    },
                    {
                         type = "editbox",
                         name = AST_SETT_INTTERUPT,
                         tooltip = AST_SETT_INTTERUPT_TOOL,
                         getFunc = function() return sv.interrupt_message end,
                         setFunc = function(value) sv.interrupt_message = value end,
                         width = "full",
                         disabled = function() return not sv.oppressive_bolts end,
                    },
                    {
                         type = "header",
                         width = "full",
                    },
                    {
                         type = "checkbox",
                         name = AST_SETT_STEAM,
                         tooltip = AST_SETT_STEAM_TOOL,
                         getFunc = function() return sv.scalding_roar end,
                         setFunc = function(value)
                              sv.scalding_roar = value
                              AST.ToggleMovable()
                              AST.ToggleMovable()
                         end,
                         default = false,
                         width = "full",
                    },
                    {
                         type = "slider",
                         name = AST_SETT_FONT_SIZE,
                         tooltip = AST_SETT_STEAM_SIZE_TOOL,
                         getFunc = function() return sv.font_size_scalding_roar end,
                         setFunc = function(value) sv.font_size_scalding_roar = value AST.SetFontSize(AsylumTrackerSteam, AsylumTrackerSteamLabel, value) end,
                         min = 38,
                         max = 72,
                         step = 2,
                         default = 48,
                         width = "full",
                         disabled = function() return not sv.scalding_roar end,
                    },
                    {
                         type = "slider",
                         name = AST_SETT_SCALE,
                         tooltip = AST_SETT_STEAM_SCALE_TOOL,
                         warning = AST_SETT_SCALE_WARN,
                         getFunc = function() return sv.scalding_roar_scale end,
                         setFunc = function(value) sv.scalding_roar_scale = value AST.SetScale(AsylumTrackerSteamLabel, value) end,
                         min = 0.5,
                         max = 2,
                         step = 0.1,
                         default = 1,
                         width = "full",
                         disabled = function() return not sv.scalding_roar end,
                    },
                    {
                         type = "colorpicker",
                         name = AST_SETT_COLOR,
                         tooltip = AST_SETT_STEAM_COLOR_TOOL,
                         getFunc = function() return unpack(sv.color_scalding_roar) end,
                         setFunc = function(r, g, b, a)
                              sv.color_scalding_roar = {r, g, b, a}
                              AsylumTrackerSteamLabel:SetColor(unpack(sv.color_scalding_roar))
                              AST.ToggleMovable() AST.ToggleMovable()
                         end,
                         width = "full",
                         disabled = function() return not sv.scalding_roar end,
                    },
                    {
                         type = "header",
                         width = "full",
                    },
                    {
                         type = "checkbox",
                         name = AST_SETT_CHARGES,
                         tooltip = AST_SETT_CHARGES_TOOL,
                         getFunc = function() return sv.exhaustive_charges end,
                         setFunc = function(value)
                              sv.exhaustive_charges = value
                              AST.ToggleMovable()
                              AST.ToggleMovable()
                         end,
                         default = false,
                         width = "full",
                    },
                    {
                         type = "slider",
                         name = AST_SETT_FONT_SIZE,
                         tooltip = AST_SETT_CHARGES_SIZE_TOOL,
                         getFunc = function() return sv.font_size_exhaustive_charges end,
                         setFunc = function(value) sv.font_size_exhaustive_charges = value AST.SetFontSize(AsylumTrackerCharges, AsylumTrackerChargesLabel, value) end,
                         min = 38,
                         max = 72,
                         step = 2,
                         default = 48,
                         width = "full",
                         disabled = function() return not sv.exhaustive_charges end,
                    },
                    {
                         type = "slider",
                         name = AST_SETT_SCALE,
                         tooltip = AST_SETT_CHARGES_SCALE_TOOL,
                         warning = AST_SETT_SCALE_WARN,
                         getFunc = function() return sv.exhaustive_charges_scale end,
                         setFunc = function(value) sv.exhaustive_charges_scale = value AST.SetScale(AsylumTrackerChargesLabel, value) end,
                         min = 0.5,
                         max = 2,
                         step = 0.1,
                         default = 1,
                         width = "full",
                         disabled = function() return not sv.exhaustive_charges end,
                    },
                    {
                         type = "colorpicker",
                         name = AST_SETT_COLOR,
                         tooltip = AST_SETT_CHARGES_COLOR_TOOL,
                         getFunc = function() return unpack(sv.color_exhaustive_charges) end,
                         setFunc = function(r, g, b, a)
                              sv.color_exhaustive_charges = {r, g, b, a}
                              AsylumTrackerChargesLabel:SetColor(unpack(sv.color_exhaustive_charges))
                              AST.ToggleMovable() AST.ToggleMovable()
                         end,
                         width = "full",
                         disabled = function() return not sv.exhaustive_charges end,
                    },
                    {
                         type = "header",
                         width = "full",
                    },
                    {
                         type = "checkbox",
                         name = AST_SETT_FIRE,
                         tooltip = AST_SETT_FIRE_TOOL,
                         getFunc = function() return sv.trial_by_fire end,
                         setFunc = function(value)
                              sv.trial_by_fire = value
                              AST.ToggleMovable()
                              AST.ToggleMovable()
                         end,
                         default = false,
                         width = "full",
                    },
                    {
                         type = "slider",
                         name = AST_SETT_FONT_SIZE,
                         tooltip = AST_SETT_FIRE_SIZE_TOOL,
                         getFunc = function() return sv.font_size_fire end,
                         setFunc = function(value) sv.font_size_fire = value AST.SetFontSize(AsylumTrackerFire, AsylumTrackerFireLabel, value) end,
                         min = 38,
                         max = 72,
                         step = 2,
                         default = 48,
                         width = "full",
                         disabled = function() return not sv.trial_by_fire end,
                    },
                    {
                         type = "slider",
                         name = AST_SETT_SCALE,
                         tooltip = AST_SETT_FIRE_SCALE_TOOL,
                         warning = AST_SETT_SCALE_WARN,
                         getFunc = function() return sv.fire_scale end,
                         setFunc = function(value) sv.fire_scale = value AST.SetScale(AsylumTrackerFireLabel, value) end,
                         min = 0.5,
                         max = 2,
                         step = 0.1,
                         default = 1,
                         width = "full",
                         disabled = function() return not sv.trial_by_fire end,
                    },
                    {
                         type = "colorpicker",
                         name = AST_SETT_COLOR,
                         tooltip = AST_SETT_FIRE_COLOR_TOOL,
                         getFunc = function() return unpack(sv.color_fire) end,
                         setFunc = function(r, g, b, a)
                              sv.color_fire = {r, g, b, a}
                              AsylumTrackerFireLabel:SetColor(unpack(sv.color_fire))
                              AST.ToggleMovable() AST.ToggleMovable()
                         end,
                         width = "full",
                         disabled = function() return not sv.trial_by_fire end,
                    },
                    {
                         type = "header",
                         width = "full",
                    },
                    {
                         type = "checkbox",
                         name = AST_SETT_MAIM,
                         tooltip = AST_SETT_MAIM_TOOL,
                         getFunc = function() return sv.maim end,
                         setFunc =
                         function(value)
                              sv.maim = value
                              AST.ToggleMovable()
                              AST.ToggleMovable()
                         end,
                         default = false,
                         width = "full",
                    },
                    {
                         type = "slider",
                         name = AST_SETT_FONT_SIZE,
                         tooltip = AST_SETT_MAIM_SIZE_TOOL,
                         getFunc = function() return sv.font_size_maim end,
                         setFunc = function(value) sv.font_size_maim = value AST.SetFontSize(AsylumTrackerMaim, AsylumTrackerMaimLabel, value) end,
                         min = 38,
                         max = 72,
                         step = 2,
                         default = 48,
                         width = "full",
                         disabled = function() return not sv.maim end,
                    },
                    {
                         type = "slider",
                         name = AST_SETT_SCALE,
                         tooltip = AST_SETT_MAIM_SCALE_TOOL,
                         warning = AST_SETT_SCALE_WARN,
                         getFunc = function() return sv.maim_scale end,
                         setFunc = function(value) sv.maim_scale = value AST.SetScale(AsylumTrackerMaimLabel, value) end,
                         min = 0.5,
                         max = 2,
                         step = 0.1,
                         default = 1,
                         width = "full",
                         disabled = function() return not sv.maim end,
                    },
                    {
                         type = "colorpicker",
                         name = AST_SETT_COLOR,
                         tooltip = AST_SETT_MAIM_COLOR_TOOL,
                         getFunc = function() return unpack(sv.color_maim) end,
                         setFunc = function(r, g, b, a)
                              sv.color_maim = {r, g, b, a}
                              AsylumTrackerMaimLabel:SetColor(unpack(sv.color_maim))
                              AST.ToggleMovable() AST.ToggleMovable()
                         end,
                         width = "full",
                         disabled = function() return not sv.maim end,
                    },
               }
          },
          {
               type = "submenu",
               name = "|cAD601C" .. GetString(AST_SETT_TIMERS) .. "|r",
               controls = {
                    {
                         type = "checkbox",
                         name = GetString(AST_SETT_OLMS_ADJUST),
                         tooltip = GetString(AST_SETT_OLMS_ADJUST_DESC),
                         getFunc = function() return sv.adjust_timers_olms end,
                         setFunc = function(value) sv.adjust_timers_olms = value end,
                         default = false,
                         width = "full",
                    },
                    {
                         type = "checkbox",
                         name = GetString(AST_SETT_LLOTHIS_ADJUST),
                         tooltip = GetString(AST_SETT_LLOTHIS_ADJUST_DESC),
                         getFunc = function() return sv.adjust_timers_llothis end,
                         setFunc = function(value) sv.adjust_timers_llothis = value end,
                         default = false,
                         width = "full",
                    },
               }
          },
          {
               type = "submenu",
               name = "|cAD601C" .. GetString(AST_SETT_LANGUAGE) .. "|r",
               controls = {
                    {
                         type = "checkbox",
                         name = GetString(AST_SETT_LANGUAGE_OVERRIDE),
                         tooltip = GetString(AST_SETT_LANGUAGE_OVERRIDE_DESC),
                         getFunc = function() return sv.languageOverride end,
                         setFunc = function(value) sv.languageOverride = value end,
                         default = false,
                         width = "full",
                         requiresReload = true,
                    },
                    {
                         type = "dropdown",
                         name = GetString(AST_SETT_LANGUAGE),
                         tooltip = GetString(AST_SETT_LANGUAGE_DROPDOWN_TOOL),
                         choices = {"English", "Français", "Deutsche", "日本語"},
                         getFunc = function()
                              local locale = sv.chosenLocale
                              for k, v in pairs(locales) do
                                   if v == locale then return k end
                              end
                         end,
                         setFunc = function(value)
                              sv.chosenLocale = locales[value]
                              ReloadUI()
                         end,
                         default = "English",
                         width = "full",
                         disabled = function() return not sv.languageOverride end,
                         requiresReload = true,
                    },
               }
          }
     }
     LAM2:RegisterOptionControls(AST.name .. "Settings", Settings)

     AST.OpenSettingsPanel = function()
          LAM2:OpenToPanel(panel)
     end
end
