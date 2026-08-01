local GST = GroupSynergyTracker
local LAM2 = LibAddonMenu2

function GST.RegisterSettingsWindow()
     local panelData = {
          type = "panel",
          name = "Group Synergy Tracker",
          displayName = "|cAD601CGroup Synergy Tracker Settings|r",
          author = "|c513DEB" .. GST.author .. "|r",
          version = "|c513DEB" .. GST.version .. "|r",
          slashCommand = "/gstracker",
          registerForRefresh = true,
     }
     LAM2:RegisterAddonPanel(GST.name .. "Settings", panelData)
     GST.BuildSettingsTable()
end

function GST.BuildSettingsTable()
     local Settings = {
          {
               type = "header",
               name = "|cAD601CGroup Synergy Tracker Information|r",
               width = "full"
          },
          {
               type = "description",
               text = "Provides tank synergy cooldowns",
               width = "full"
          },
          {
               type = "button",
               name = "Unlock Frames",
               tooltip = "Unhides frame and makes it movable",
               func = function(value)
                    GST.ToggleMovable()
                    if GST.isMovable then
                         value:SetText("Lock Frames")
                         GST.frames[1]:SetScale(GST.sv.frame_scale)
                         GST.frames[1]:SetHidden(false)
                         GST.frames[1]:SetMovable(true)
                         GST.frames[1]:SetMouseEnabled(true)
                    else
                         value:SetText("Unlock Frames")
                         GST.frames[1]:SetScale(0)
                         GST.frames[1]:SetHidden(true)
                         GST.frames[1]:SetMovable(false)
                         GST.frames[1]:SetMouseEnabled(false)
                         GST.UpdateFrame()
                    end
               end,
               width = "half",
          },
          {
               type = "slider",
               name = "Window Size",
               tooltip = "Change the Scale of the window frames",
               getFunc = function() return GST.sv.frame_scale end,
               setFunc = function(value)
                    GST.sv.frame_scale = value
                    GST.UpdateFrame()
               end,
               min = 0.5,
               max = 2,
               step = 0.1,
               default = 1,
               width = "full",
          },
          {
               type = "checkbox",
               name = "Use HodorReflexes Config",
               tooltip = "Uses icons and aliases from HodorReflexes if the addon is enabled",
               getFunc = function() return GST.sv.useHodorReflexes end,
               setFunc = function(value) GST.sv.useHodorReflexes = value end,
               default = false,
               width = "full",
          },
          {
               type = "dropdown",
               name = "Growth Direction",
               tooltip = "Direction in which new frames will be created",
               choices = {"Down", "Up", "Left", "Right"},
               getFunc = function() return GST.sv.growth_direction end,
               setFunc = function(value) GST.sv.growth_direction = value end,
               default = "Down",
               width = "full",
               requiresReload = true,
          },
          {
               type = "checkbox",
               name = "Use Cooldown Bars",
               tooltip = "Colors the backdrop behind the synergy to show the time remaining",
               getFunc = function() return GST.sv.cooldownBars end,
               setFunc = function(value) GST.sv.cooldownBars = value end,
               default = false,
               requiresReload = true,
               width = "full",
          },
          {
               type = "checkbox",
               name = "Show Tanks",
               tooltip = "If enabled, the addon will create frames for players marked as tank",
               getFunc = function() return GST.sv.showTanks end,
               setFunc = function(value)
                    GST.sv.showTanks = value
                    GST.UpdateFrame()
               end,
               default = false,
               width = "full",
          },
          {
               type = "checkbox",
               name = "Show Healers",
               tooltip = "If enabled, the addon will create frames for players marked as healer",
               getFunc = function() return GST.sv.showHealers end,
               setFunc = function(value)
                    GST.sv.showHealers = value
                    GST.UpdateFrame()
               end,
               default = false,
               width = "full",
          },
          {
               type = "checkbox",
               name = "Show DPS",
               tooltip = "If enabled, the addon will create frames for players marked as DPS",
               getFunc = function() return GST.sv.showDPS end,
               setFunc = function(value)
                    GST.sv.showDPS = value
                    GST.UpdateFrame()
               end,
               default = false,
               width = "full",
          },
          {
               type = "submenu",
               name = "|cAD601CRole Based Frame Colors|r",
               controls = {
                    {
                         type = "checkbox",
                         name = "Role Based Frame Colors",
                         tooltip = "If enabled, tanks, healers, and DPS will have different colored frames",
                         getFunc = function() return GST.sv.alternateFrameColors end,
                         setFunc = function(value)
                              GST.sv.alternateFrameColors = value
                              GST.UpdateFrame()
                         end,
                         default = false,
                         width = "full",
                    },
                    {
                         type = "colorpicker",
                         name = "Tank Color",
                         tooltip = "Color of the frames for Tanks",
                         getFunc = function() return unpack(GST.sv.tankColor) end,
                         setFunc = function(r, g, b)
                              GST.sv.tankColor = {r, g, b}
                              GST.UpdateFrame()
                         end,
                         width = "full",
                         disabled = function() return not GST.sv.alternateFrameColors end,
                    },
                    {
                         type = "colorpicker",
                         name = "Healer Color",
                         tooltip = "Color of the frames for Healer",
                         getFunc = function() return unpack(GST.sv.healerColor) end,
                         setFunc = function(r, g, b)
                              GST.sv.healerColor = {r, g, b}
                              GST.UpdateFrame()
                         end,
                         width = "full",
                         disabled = function() return not GST.sv.alternateFrameColors end,
                    },
                    {
                         type = "colorpicker",
                         name = "DPS Color",
                         tooltip = "Color of the frames for DPS",
                         getFunc = function() return unpack(GST.sv.dpsColor) end,
                         setFunc = function(r, g, b)
                              GST.sv.dpsColor = {r, g, b}
                              GST.UpdateFrame()
                         end,
                         width = "full",
                         disabled = function() return not GST.sv.alternateFrameColors end,
                    },
               }
          },
          {
               type = "submenu",
               name = "|cAD601CBlacklisted Players|r",
               controls = {
                    {
                         type = "dropdown",
                         name = "Blacklist from Tracked Users",
                         choices = GST.trackedUsers,
                         sort = "name-down",
                         getFunc = function() return '' end,
                         setFunc = function(value)
                              GST.sv.blacklist[1] = "|c513DEBClick to View Blacklist|r"
                              GST.sv.blacklist[#GST.sv.blacklist + 1] = value
                              GSTBlacklistDropdown:UpdateChoices(GST.sv.blacklist)
                              GST.UpdateFrame()
                         end,
                         width = "full",
                         scrollable = true,
                         reference = "GSTBlacklistGroupDropdown",
                    },
                    {
                         type = "editbox",
                         name = "Add to Blacklist",
                         description = "Enter the @displayName of the players you would like to not create frames for in this box",
                         getFunc = function() return '' end,
                         setFunc = function(value)
                              if value:gsub("%s+", "") ~= '' then
                                   value = DecorateDisplayName(value)
                                   value = value:gsub("%s+", "")
                                   GSTBlacklistEditBox.editbox:SetText("")

                                   for k, v in pairs(GST.groupMembers) do
                                        if string.lower(value) == string.lower(v["displayName"]) then
                                             value = v["displayName"]
                                        end
                                   end

                                   if not GST.IsStringInTable(value, GST.sv.blacklist, false) then
                                        GST.sv.blacklist[1] = "|c513DEBClick to View Blacklist|r"
                                        GST.sv.blacklist[#GST.sv.blacklist + 1] = value
                                        GSTBlacklistDropdown:UpdateChoices(GST.sv.blacklist)
                                        GST.UpdateFrame()
                                   end
                              end
                         end,
                         width = "full",
                         reference = "GSTBlacklistEditBox",
                    },
                    {
                         type = "dropdown",
                         name = "Blacklisted Players",
                         tooltip = "List of all players blacklisted from having frames",
                         choices = GST.sv.blacklist,
                         sort = "name-down",
                         getFunc = function() return GST.sv.blacklist[1] end,
                         setFunc = function(value) GST.selectedBlacklistUser = value end,
                         width = "full",
                         scrollable = true,
                         reference = "GSTBlacklistDropdown",
                    },
                    {
                         type = "button",
                         name = "Remove Selected",
                         tooltip = "Removes the selected member from the blacklist",
                         func = function(value)
                              for key, user in pairs(GST.sv.blacklist) do
                                   if user == GST.selectedBlacklistUser then
                                        table.remove(GST.sv.blacklist, key)
                                        GST.sv.blacklist[1] = "|c513DEBClick to View Blacklist|r"
                                        GSTBlacklistDropdown:UpdateChoices(GST.sv.blacklist)
                                        GST.UpdateFrame()
                                   end
                              end
                         end,
                         width = "full",
                    },
                    {
                         type = "button",
                         name = "Clear Blacklist",
                         tooltip = "Removes every entry from the blacklist",
                         func = function(value)
                              GST.sv.blacklist = {}
                              GST.sv.blacklist[1] = "|c513DEBClick to View Blacklist|r"
                              GSTBlacklistDropdown:UpdateChoices(GST.sv.blacklist)
                              GST.UpdateFrame()
                         end,
                         width = "full",
                    },
               }
          },
          {
               type = "submenu",
               name = "|cAD601CSynergies to Display|r",
               controls = {
                    {
                         type = "dropdown",
                         name = "Synergy 1",
                         choices = {" ", "Orb/Shard", "Conduit", "Harvest", "Purify", "Boneyard", "Pure Agony", "Bone Shield", "Blood Altar", "Spiders"},
                         getFunc = function() return GST.sv.trackedSynergies[1] end,
                         setFunc = function(value)
                              if value ~= " " then
                                   GST.sv.trackedSynergies[1] = value
                                   GST.UpdateFrame()
                              else
                                   GST.sv.trackedSynergies[1] = ""
                                   for i = 1, #GST.frames do
                                        GST.frames[i].rows[1].synergyName1:SetText("")
                                        GST.frames[i].rows[1].synergyTime1:SetText("")
                                   end
                                   GST.UpdateFrame()
                              end
                         end,
                         width = "half",
                    },
                    {
                         type = "dropdown",
                         name = "Synergy 2",
                         choices = {" ", "Orb/Shard", "Conduit", "Harvest", "Purify", "Boneyard", "Pure Agony", "Bone Shield", "Blood Altar", "Spiders"},
                         getFunc = function() return GST.sv.trackedSynergies[2] end,
                         setFunc = function(value)
                              if value ~= " " then
                                   GST.sv.trackedSynergies[2] = value
                                   GST.UpdateFrame()
                              else
                                   GST.sv.trackedSynergies[2] = ""
                                   for i = 1, #GST.frames do
                                        GST.frames[i].rows[1].synergyName2:SetText("")
                                        GST.frames[i].rows[1].synergyTime2:SetText("")
                                   end
                                   GST.UpdateFrame()
                              end
                         end,
                         width = "half",
                    },
                    {
                         type = "dropdown",
                         name = "Synergy 3",
                         choices = {" ", "Orb/Shard", "Conduit", "Harvest", "Purify", "Boneyard", "Pure Agony", "Bone Shield", "Blood Altar", "Spiders"},
                         getFunc = function() return GST.sv.trackedSynergies[3] end,
                         setFunc = function(value)
                              if value ~= " " then
                                   GST.sv.trackedSynergies[3] = value
                                   GST.UpdateFrame()
                              else
                                   GST.sv.trackedSynergies[3] = ""
                                   for i = 1, #GST.frames do
                                        GST.frames[i].rows[2].synergyName1:SetText("")
                                        GST.frames[i].rows[2].synergyTime1:SetText("")
                                   end
                                   GST.UpdateFrame()
                              end
                         end,
                         width = "half",
                    },
                    {
                         type = "dropdown",
                         name = "Synergy 4",
                         choices = {" ", "Orb/Shard", "Conduit", "Harvest", "Purify", "Boneyard", "Pure Agony", "Bone Shield", "Blood Altar", "Spiders"},
                         getFunc = function() return GST.sv.trackedSynergies[4] end,
                         setFunc = function(value)
                              if value ~= " " then
                                   GST.sv.trackedSynergies[4] = value
                                   GST.UpdateFrame()
                              else
                                   GST.sv.trackedSynergies[4] = ""
                                   for i = 1, #GST.frames do
                                        GST.frames[i].rows[2].synergyName2:SetText("")
                                        GST.frames[i].rows[2].synergyTime2:SetText("")
                                   end
                                   GST.UpdateFrame()
                              end
                         end,
                         width = "half",
                    },
                    {
                         type = "dropdown",
                         name = "Synergy 5",
                         choices = {" ", "Orb/Shard", "Conduit", "Harvest", "Purify", "Boneyard", "Pure Agony", "Bone Shield", "Blood Altar", "Spiders"},
                         getFunc = function() return GST.sv.trackedSynergies[5] end,
                         setFunc = function(value)
                              if value ~= " " then
                                   GST.sv.trackedSynergies[5] = value
                                   GST.UpdateFrame()
                              else
                                   GST.sv.trackedSynergies[5] = ""
                                   for i = 1, #GST.frames do
                                        GST.frames[i].rows[3].synergyName1:SetText("")
                                        GST.frames[i].rows[3].synergyTime1:SetText("")
                                   end
                                   GST.UpdateFrame()
                              end
                         end,
                         width = "half",
                    },
                    {
                         type = "dropdown",
                         name = "Synergy 6",
                         choices = {" ", "Orb/Shard", "Conduit", "Harvest", "Purify", "Boneyard", "Pure Agony", "Bone Shield", "Blood Altar", "Spiders"},
                         getFunc = function() return GST.sv.trackedSynergies[6] end,
                         setFunc = function(value)
                              if value ~= " " then
                                   GST.sv.trackedSynergies[6] = value
                                   GST.UpdateFrame()
                              else
                                   GST.sv.trackedSynergies[6] = ""
                                   for i = 1, #GST.frames do
                                        GST.frames[i].rows[3].synergyName2:SetText("")
                                        GST.frames[i].rows[3].synergyTime2:SetText("")
                                   end
                                   GST.UpdateFrame()
                              end
                         end,
                         width = "half",
                    },
                    {
                         type = "dropdown",
                         name = "Synergy 7",
                         choices = {" ", "Orb/Shard", "Conduit", "Harvest", "Purify", "Boneyard", "Pure Agony", "Bone Shield", "Blood Altar", "Spiders"},
                         getFunc = function() return GST.sv.trackedSynergies[7] end,
                         setFunc = function(value)
                              if value ~= " " then
                                   GST.sv.trackedSynergies[7] = value
                                   GST.UpdateFrame()
                              else
                                   GST.sv.trackedSynergies[7] = ""
                                   for i = 1, #GST.frames do
                                        GST.frames[i].rows[4].synergyName1:SetText("")
                                        GST.frames[i].rows[4].synergyTime1:SetText("")
                                   end
                                   GST.UpdateFrame()
                              end
                         end,
                         width = "half",
                    },
                    {
                         type = "dropdown",
                         name = "Synergy 8",
                         choices = {" ", "Orb/Shard", "Conduit", "Harvest", "Purify", "Boneyard", "Pure Agony", "Bone Shield", "Blood Altar", "Spiders"},
                         getFunc = function() return GST.sv.trackedSynergies[8] end,
                         setFunc = function(value)
                              if value ~= " " then
                                   GST.sv.trackedSynergies[8] = value
                                   GST.UpdateFrame()
                              else
                                   GST.sv.trackedSynergies[8] = ""
                                   for i = 1, #GST.frames do
                                        GST.frames[i].rows[4].synergyName2:SetText("")
                                        GST.frames[i].rows[4].synergyTime2:SetText("")
                                   end
                                   GST.UpdateFrame()
                              end
                         end,
                         width = "half",
                    },
               }
          },
          {
               type = "submenu",
               name = "|cAD601CDebugging|r",
               controls = {
                    {
                         type = "checkbox",
                         name = "Show Countdowns",
                         description = "Displays Countdown timers in system chat",
                         getFunc = function() return GST.sv.debug.showCountdowns end,
                         setFunc = function(value) GST.sv.debug.showCountdowns = value end,
                         default = false,
                         width = "full",
                    },
                    {
                         type = "checkbox",
                         name = "Show Unit Indexing",
                         getFunc = function() return GST.sv.debug.unitIndexing end,
                         setFunc = function(value) GST.sv.debug.unitIndexing = value end,
                         default = false,
                         width = "full",
                    },
                    {
                         type = "description",
                         text = "Show Taken Synergies",
                         width = "full"
                    },
                    {
                         type = "checkbox",
                         name = "Orbs",
                         description = "Displays in system chat when a player activates a synergy",
                         getFunc = function() return GST.sv.debug.showTakenSynergies.orbs.active end,
                         setFunc = function(value) GST.sv.debug.showTakenSynergies.orbs.active = value end,
                         default = false,
                         width = "half",
                    },
                    {
                         type = "checkbox",
                         name = "Conduit",
                         description = "Displays in system chat when a player activates a synergy",
                         getFunc = function() return GST.sv.debug.showTakenSynergies.conduit.active end,
                         setFunc = function(value) GST.sv.debug.showTakenSynergies.conduit.active = value end,
                         default = false,
                         width = "half",
                    },
                    {
                         type = "checkbox",
                         name = "Purify",
                         description = "Displays in system chat when a player activates a synergy",
                         getFunc = function() return GST.sv.debug.showTakenSynergies.purify.active end,
                         setFunc = function(value) GST.sv.debug.showTakenSynergies.purify.active = value end,
                         default = false,
                         width = "half",
                    },
                    {
                         type = "checkbox",
                         name = "Harvest",
                         description = "Displays in system chat when a player activates a synergy",
                         getFunc = function() return GST.sv.debug.showTakenSynergies.harvest.active end,
                         setFunc = function(value) GST.sv.debug.showTakenSynergies.harvest.active = value end,
                         default = false,
                         width = "half",
                    },
                    {
                         type = "checkbox",
                         name = "Boneyard",
                         description = "Displays in system chat when a player activates a synergy",
                         getFunc = function() return GST.sv.debug.showTakenSynergies.boneyard.active end,
                         setFunc = function(value) GST.sv.debug.showTakenSynergies.boneyard.active = value end,
                         default = false,
                         width = "half",
                    },
                    {
                         type = "checkbox",
                         name = "Pure Agony",
                         description = "Displays in system chat when a player activates a synergy",
                         getFunc = function() return GST.sv.debug.showTakenSynergies.pure_agony.active end,
                         setFunc = function(value) GST.sv.debug.showTakenSynergies.pure_agony.active = value end,
                         default = false,
                         width = "half",
                    },
                    {
                         type = "checkbox",
                         name = "Bone Shield",
                         description = "Displays in system chat when a player activates a synergy",
                         getFunc = function() return GST.sv.debug.showTakenSynergies.bone_shield.active end,
                         setFunc = function(value) GST.sv.debug.showTakenSynergies.bone_shield.active = value end,
                         default = false,
                         width = "half",
                    },
                    {
                         type = "checkbox",
                         name = "Blood Altar",
                         description = "Displays in system chat when a player activates a synergy",
                         getFunc = function() return GST.sv.debug.showTakenSynergies.altar.active end,
                         setFunc = function(value) GST.sv.debug.showTakenSynergies.altar.active = value end,
                         default = false,
                         width = "half",
                    },
                    {
                         type = "checkbox",
                         name = "Spiders",
                         description = "Displays in system chat when a player activates a synergy",
                         getFunc = function() return GST.sv.debug.showTakenSynergies.spiders.active end,
                         setFunc = function(value) GST.sv.debug.showTakenSynergies.spiders.active = value end,
                         default = false,
                         width = "half",
                    },
               }
          },
     }
     LAM2:RegisterOptionControls(GST.name .. "Settings", Settings)
end
