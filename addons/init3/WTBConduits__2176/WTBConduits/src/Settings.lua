local wtb = WTBConduits

function wtb.CreateSettingsWindow()
     local LAM2 = LibAddonMenu2
     local sv = WTBConduitsVars["Default"][GetDisplayName()][GetCurrentCharacterId()]

     local panelData = {
          type = "panel",
          name = "WTBConduits",
          displayName = "|cAD601CWTBConduits Settings|r",
          author = "|c513DEB" .. wtb.author .. "|r",
          version = "|c513DEB" .. wtb.version .. "|r",
          slashCommand = "/wtbconduits",
          registerForRefresh = true,
     }
     LAM2:RegisterAddonPanel(wtb.name .. "Settings", panelData)

     local Settings = {
          {
               type = "header",
               name = "|cAD601CWTBConduits Information|r",
               width = "full"
          },
          {
               type = "description",
               text = "Let's you know when the tank needs a synergy for Alkosh",
               width = "full"
          },
          {
               type = "button",
               name = "Unlock",
               tooltip = "Unhides frame and makes it movable",
               func = function(value)
                    wtb.ToggleMovable()
                    if not wtb.isMovable then
                         value:SetText("Unlock")
                    else
                         value:SetText("Lock")
                    end
               end,
               width = "half",
          },
          {
               type = "checkbox",
               name = "Warn of Stolen Conduits",
               tooltip = "Display in system chat box when a conduit is taken by a non-tank player",
               getFunc = function() return sv.warnStolenConduits end,
               setFunc = function(value) sv.warnStolenConduits = value end,
               width = "full",
               requiresReload = true,
          },
          {
               type = "checkbox",
               name = "Inform of Taken Conduits",
               tooltip = "Display in system chat box when a conduit is taken by a tank",
               getFunc = function() return sv.informTakenConduits end,
               setFunc = function(value) sv.informTakenConduits = value end,
               width = "full",
               requiresReload = true,
          },
          {
               type = "checkbox",
               name = "Track synergies when fighting trash",
               tooltip = "If enabled the synergies needed notification will show up when not in a boss fight",
               getFunc = function() return sv.trackDuringTrash end,
               setFunc = function(value) sv.trackDuringTrash = value end,
               width = "full",
               requiresReload = true,
          },
          {
               type = "checkbox",
               name = "Track if Alkosh is applied to boss",
               tooltip = "If enabled, the synergy prompt will not be displayed while Alkosh (linebreaker) is applied to the boss",
               getFunc = function() return sv.trackLinebreaker end,
               setFunc = function(value) sv.trackLinebreaker = value end,
               width = "full",
               requiresReload = true,
          },
          {
               type = "slider",
               name = "Font Size",
               tooltip = "Change the Font Size for the window",
               getFunc = function() return sv.fontSize end,
               setFunc = function(value)
                    sv.fontSize = value wtb.SetFontSize(WTBConduitsFrameLabel, value)
                    sv.fontSize = value wtb.SetFontSize(WTBConduitsFrame2Label, value)
                    sv.fontSize = value wtb.SetFontSize(WTBConduitsFrame3Label, value)
                    wtb.ToggleMovable() wtb.ToggleMovable()
               end,
               min = 4,
               max = 72,
               step = 2,
               default = 36,
               width = "full",
          },
          {
               type = "slider",
               name = "Orbs Preemptive Notification",
               tooltip = "How many seconds before the synergy can actually be activated to display the 'tank needs synergy notification'",
               getFunc = function() return 20 - sv.orbs_duration end,
               setFunc = function(value)
                    sv.orbs_duration = 20 - value
                    wtb.SetSynergyDuration("orbs", sv.orbs_duration)
               end,
               min = 0,
               max = 5,
               step = 1,
               default = 2,
               width = "full",
          },
          {
               type = "slider",
               name = "Conduit Preemptive Notification",
               tooltip = "How many seconds before the synergy can actually be activated to display the 'tank needs synergy notification'",
               getFunc = function() return 20 - sv.conduit_duration end,
               setFunc = function(value)
                    sv.conduit_duration = 20 - value
                    wtb.SetSynergyDuration("conduit", sv.conduit_duration)
               end,
               min = 0,
               max = 5,
               step = 1,
               default = 2,
               width = "full",
          },
          {
               type = "slider",
               name = "Harvest Preemptive Notification",
               tooltip = "How many seconds before the synergy can actually be activated to display the 'tank needs synergy notification'",
               getFunc = function() return 20 - sv.harvest_duration end,
               setFunc = function(value)
                    sv.harvest_duration = 20 - value
                    wtb.SetSynergyDuration("harvest", sv.harvest_duration)
               end,
               min = 0,
               max = 5,
               step = 1,
               default = 2,
               width = "full",
          },
          {
               type = "slider",
               name = "Boneyard Preemptive Notification",
               tooltip = "How many seconds before the synergy can actually be activated to display the 'tank needs synergy notification'",
               getFunc = function() return 20 - sv.boneyard_duration end,
               setFunc = function(value)
                    sv.boneyard_duration = 20 - value
                    wtb.SetSynergyDuration("boneyard", sv.boneyard_duration)
               end,
               min = 0,
               max = 5,
               step = 1,
               default = 2,
               width = "full",
          },
          {
               type = "slider",
               name = "Pure Agony Preemptive Notification",
               tooltip = "How many seconds before the synergy can actually be activated to display the 'tank needs synergy notification'",
               getFunc = function() return 20 - sv.agony_duration end,
               setFunc = function(value)
                    sv.agony_duration = 20 - value
                    wtb.SetSynergyDuration("agony", sv.agony_duration)
               end,
               min = 0,
               max = 5,
               step = 1,
               default = 2,
               width = "full",
          },
          {
               type = "submenu",
               name = "|cAD601CTanks|r",
               controls = {
                    {
                         type = "editbox",
                         name = "Tank Display Name",
                         tooltip = "The @name of the tank whose synergies you want to track",
                         getFunc = function() return sv.tankName end,
                         setFunc = function(value)
                              value = DecorateDisplayName(value)
                              value = string.lower(value)
                              sv.tankName = value
                              wtb.ToggleMovable() wtb.ToggleMovable()
                         end,
                         width = "full",
                    },
                    {
                         type = "checkbox",
                         name = "Enable Second Tank",
                         tooltip = "Enabling this will allow the tracking of a second tank",
                         getFunc = function() return sv.enableTank2 end,
                         setFunc = function(value)
                              sv.enableTank2 = value
                              wtb.ToggleMovable() wtb.ToggleMovable()
                         end,
                         width = "half",
                    },
                    {
                         type = "editbox",
                         name = "Tank 2 Display Name",
                         tooltip = "The @name of the tank whose synergies you want to track",
                         getFunc = function() return sv.tankName2 end,
                         setFunc = function(value)
                              value = DecorateDisplayName(value)
                              value = string.lower(value)
                              sv.tankName2 = value
                              wtb.ToggleMovable() wtb.ToggleMovable()
                         end,
                         width = "half",
                         disabled = function() return not sv.enableTank2 end,
                    },
                    {
                         type = "checkbox",
                         name = "Enable Third Tank",
                         tooltip = "Enabling this will allow the tracking of a Third tank",
                         getFunc = function() return sv.enableTank3 end,
                         setFunc = function(value)
                              sv.enableTank3 = value
                              wtb.ToggleMovable() wtb.ToggleMovable()
                         end,
                         width = "half",
                    },
                    {
                         type = "editbox",
                         name = "Tank 3 Display Name",
                         tooltip = "The @name of the tank whose synergies you want to track",
                         getFunc = function() return sv.tankName3 end,
                         setFunc = function(value)
                              value = DecorateDisplayName(value)
                              value = string.lower(value)
                              sv.tankName3 = value
                              wtb.ToggleMovable() wtb.ToggleMovable()
                         end,
                         width = "half",
                         disabled = function() return not sv.enableTank3 end,
                    },
               },
          },
          {
               type = "submenu",
               name = "|cAD601CArrow|r",
               controls = {
                    {
                         type = "checkbox",
                         name = "Track First Tank with Arrow",
                         tooltip = "Displays an arrow on the screen around your reticle which follows the player marked as the First Tank",
                         getFunc = function() return sv.showArrow end,
                         setFunc = function(value) sv.showArrow = value end,
                         width = "full",
                         requiresReload = false,
                    },
                    {
                         type = "colorpicker",
                         name = "Arrow Color",
                         tooltip = "Color for the arrow tracking the tank",
                         getFunc = function() return unpack(sv.arrowColor) end,
                         setFunc = function(r, g, b, a)
                              sv.arrowColor = {r, g, b, a}
                              wtb:HideArrow()
                              wtb:ShowArrow("player")
                         end,
                         width = "half",
                         disabled = function() return not sv.showArrow end,
                    },
                    {
                         type = "slider",
                         name = "Arrow Scale",
                         tooltip = "Change the size of the arrow",
                         getFunc = function() return sv.arrowScale end,
                         setFunc = function(value)
                              sv.arrowScale = value
                              wtb:HideArrow()
                              wtb:ShowArrow("player")
                         end,
                         min = .25,
                         max = 4,
                         step = .25,
                         default = 1,
                         width = "half",
                         disabled = function() return not sv.showArrow end,
                    },
               },
          },
          {
               type = "submenu",
               name = "|cAD601CSynergies|r",
               controls = {
                    {
                         type = "checkbox",
                         name = "Auto Determine Synergies",
                         tooltip = "Automatically determine which synergies to track based on group role/class",
                         warning = "This only checks based on role and class, so the harvest synergy will appear if you are a warden dps even if you don't have the ability slotted",
                         getFunc = function() return sv.autodetermination end,
                         setFunc = function(value)
                              sv.autodetermination = value
                              wtb.UnregisterEvents()
                              wtb.RegisterEvents()
                         end,
                         width = "full",
                    },
                    {
                         type = "divider",
                         alpha = 1,
                         width = "full"
                    },
                    {
                         type = "checkbox",
                         name = "Track Orbs",
                         tooltip = "Track the tank's orbs synergy cooldown",
                         getFunc = function() return sv.trackOrbs end,
                         setFunc = function(value)
                              sv.trackOrbs = value
                              wtb.UnregisterEvents()
                              wtb.RegisterEvents()
                         end,
                         width = "half",
                         disabled = function() return sv.autodetermination end,
                         requiresReload = false,
                    },
                    {
                         type = "colorpicker",
                         name = "Orbs Color",
                         tooltip = "Color for Orbs Notification",
                         getFunc = function() return unpack(sv.orbsColor) end,
                         setFunc = function(r, g, b, a)
                              sv.orbsColor = {r, g, b, a}
                              wtb.UpdateSynergyColor("orbs")
                         end,
                         width = "half",
                         disabled = function() return not sv.trackOrbs or sv.autodetermination end,
                    },
                    {
                         type = "checkbox",
                         name = "Track Conduit",
                         tooltip = "Track the tank's conduit synergy cooldown",
                         getFunc = function() return sv.trackConduit end,
                         setFunc = function(value)
                              sv.trackConduit = value
                              wtb.UnregisterEvents()
                              wtb.RegisterEvents()
                         end,
                         width = "half",
                         disabled = function() return sv.autodetermination end,
                         requiresReload = false,
                    },
                    {
                         type = "colorpicker",
                         name = "Conduit Color",
                         tooltip = "Color for Conduit Notification",
                         getFunc = function() return unpack(sv.conduitColor) end,
                         setFunc = function(r, g, b, a)
                              sv.conduitColor = {r, g, b, a}
                              wtb.UpdateSynergyColor("conduit")
                         end,
                         width = "half",
                         disabled = function() return not sv.trackConduit or sv.autodetermination end,
                    },
                    {
                         type = "checkbox",
                         name = "Track Harvest",
                         tooltip = "Track the tank's harvest synergy cooldown",
                         getFunc = function() return sv.trackHarvest end,
                         setFunc = function(value)
                              sv.trackHarvest = value
                              wtb.UnregisterEvents()
                              wtb.RegisterEvents()
                         end,
                         width = "half",
                         disabled = function() return sv.autodetermination end,
                         requiresReload = false,
                    },
                    {
                         type = "colorpicker",
                         name = "Harvest Color",
                         tooltip = "Color for Harvest Notification",
                         getFunc = function() return unpack(sv.harvestColor) end,
                         setFunc = function(r, g, b, a)
                              sv.harvestColor = {r, g, b, a}
                              wtb.UpdateSynergyColor("harvest")
                         end,
                         width = "half",
                         disabled = function() return not sv.trackHarvest or sv.autodetermination end,
                    },
                    {
                         type = "checkbox",
                         name = "Track Boneyard",
                         tooltip = "Track the tank's boneyard synergy cooldown",
                         getFunc = function() return sv.trackBoneyard end,
                         setFunc = function(value)
                              sv.trackBoneyard = value
                              wtb.UnregisterEvents()
                              wtb.RegisterEvents()
                         end,
                         width = "half",
                         disabled = function() return sv.autodetermination end,
                         requiresReload = false,
                    },
                    {
                         type = "colorpicker",
                         name = "Boneyard Color",
                         tooltip = "Color for Boneyard Notification",
                         getFunc = function() return unpack(sv.boneyardColor) end,
                         setFunc = function(r, g, b, a)
                              sv.boneyardColor = {r, g, b, a}
                              wtb.UpdateSynergyColor("boneyard")
                         end,
                         width = "half",
                         disabled = function() return not sv.trackBoneyard or sv.autodetermination end,
                    },
                    {
                         type = "checkbox",
                         name = "Track Pure Agony",
                         tooltip = "Track the tank's Pure Agony synergy cooldown",
                         getFunc = function() return sv.trackAgony end,
                         setFunc = function(value)
                              sv.trackAgony = value
                              wtb.UnregisterEvents()
                              wtb.RegisterEvents()
                         end,
                         width = "half",
                         disabled = function() return sv.autodetermination end,
                         requiresReload = false,
                    },
                    {
                         type = "colorpicker",
                         name = "Pure Agony Color",
                         tooltip = "Color for Pure Agony Notification",
                         getFunc = function() return unpack(sv.agonyColor) end,
                         setFunc = function(r, g, b, a)
                              sv.agonyColor = {r, g, b, a}
                              wtb.UpdateSynergyColor("agony")
                         end,
                         width = "half",
                         disabled = function() return not sv.trackAgony or sv.autodetermination end,
                    },
               },
          },
          {
               type = "submenu",
               name = "|cAD601CDebugging|r",
               controls = {
                    {
                         type = "checkbox",
                         name = "Enable Debugging",
                         tooltip = "Enable debugging messages in chat",
                         getFunc = function() return sv.dbg end,
                         setFunc = function(value) sv.dbg = value end,
                         width = "full",
                    },
               },
          },
     }
     LAM2:RegisterOptionControls(wtb.name .. "Settings", Settings)
end
