WTBConduits = WTBConduits or {}
local wtb = WTBConduits

wtb.name                      = "WTBConduits"
wtb.author                    = "init3"
wtb.version                   = "3.1"
wtb.variableVersion           = 1
wtb.isMovable                 = false
wtb.isInCombat                = false
wtb.isInDungeon               = false
wtb.isFightingBoss            = false
wtb.isRegistered              = false

wtb.monitorTank               = false
wtb.monitorTank2              = false
wtb.monitorTank3              = false

wtb.playerClassId             = GetUnitClassId("player")
wtb.playerRole                = GetGroupMemberAssignedRole("player")

wtb.groupMembers              = {}
wtb.registeredAbilities       = {}
wtb.synergies                 = {}
wtb.tanks                     = {}
wtb.bosses                    = {}
wtb.stolenConduits            = {}

wtb.orbsHex                   = "c9a817"
wtb.conduitHex                = "5555ff"
wtb.harvestHex                = "9756bc"
wtb.boneyardHex               = "f27f13"
wtb.agonyHex                  = "a61c6a"

wtb.synergies[108799]         = {true, "orbs", 18}          -- Necrotic Orbs
wtb.synergies[108802]         = {true, "orbs", 18}          -- Energy Orbs
wtb.synergies[108924]         = {true, "orbs", 18}          -- Blessed Shards
wtb.synergies[108821]         = {true, "orbs", 18}          -- Holy Shards
wtb.synergies[108607]         = {true, "conduit", 18}       -- Conduit
wtb.synergies[108826]         = {true, "harvest", 18}       -- Harvest
wtb.synergies[125219]         = {true, "boneyard", 18}      -- Boneyard
wtb.synergies[125220]         = {true, "agony", 18}         -- Pure Agony

wtb.synergies[108782]         = {false, "other", 18}        -- Blood Funnel
wtb.synergies[108787]         = {false, "other", 18}        -- Blood Feast
wtb.synergies[108788]         = {false, "other", 18}        -- Trapping Webs
wtb.synergies[108791]         = {false, "other", 18}        -- Shadow Silk
wtb.synergies[108792]         = {false, "other", 18}        -- Tangling Webs
wtb.synergies[108793]         = {false, "other", 18}        -- Inner Fire
wtb.synergies[108794]         = {false, "other", 18}        -- Bone Wall
wtb.synergies[108797]         = {false, "other", 18}        -- Spinal Surge
wtb.synergies[108824]         = {false, "other", 18}        -- Exended Ritual
wtb.synergies[108805]         = {false, "other", 18}        -- Shackle
wtb.synergies[108807]         = {false, "other", 18}        -- Talons
wtb.synergies[108822]         = {false, "other", 18}        -- Supernova
wtb.synergies[108823]         = {false, "other", 18}        -- Gravity Crush
wtb.synergies[108808]         = {false, "other", 18}        -- Consuming Darkness
wtb.synergies[108814]         = {false, "other", 18}        -- Soul Leech
wtb.synergies[102321]         = {false, "other", 18}        -- Charged Lightning

wtb.synergies.linebreaker     = 75753                       -- Linebreaker
-- wtb.synergies.linebreaker     = 31104                       -- Engulfing Flames (Was using instead of linebreaker for testing when I didn't have someone to give me synergies)

wtb.displayResolution = {
     width = GuiRoot:GetWidth(),
     height = GuiRoot:GetHeight()
}

wtb.timers = {
     --Tank 1
     linebreaker = 0,
     conduit = 0,
     orbs = 0,
     harvest = 0,
     boneyard = 0,
     agony = 0,
     --Tank 2
     linebreaker2 = 0,
     conduit2 = 0,
     orbs2 = 0,
     harvest2 = 0,
     boneyard2 = 0,
     agony2 = 0,
     -- Tank 3
     linebreaker3 = 0,
     conduit3 = 0,
     orbs3 = 0,
     harvest3 = 0,
     boneyard3 = 0,
     agony3 = 0,
}

wtb.defaults = {
     dbg                 = false,

     offsetX             = (wtb.displayResolution.width / 2) - (WTBConduitsFrame:GetWidth() / 2),
     offsetY             = wtb.displayResolution.height / 3,
     offsetX2            = (wtb.displayResolution.width / 2) - (WTBConduitsFrame2:GetWidth() / 2),
     offsetY2            = wtb.displayResolution.height / 3 + 100,
     offsetX3            = (wtb.displayResolution.width / 2) - (WTBConduitsFrame3:GetWidth() / 2),
     offsetY3            = wtb.displayResolution.height / 3 + 200,

     fontSize            = 36,

     showArrow           = false,
     arrowColor          = {.7412, 1, .8078, 1},
     arrowScale          = 1.0,

     tankName            = "@init3",
     tankName2           = "@everyone",
     tankName3           = "@here",
     enableTank2         = false,
     enableTank3         = false,

     autodetermination   = false,
     trackOrbs           = false,
     trackConduit        = false,
     trackHarvest        = false,
     trackBoneyard       = false,
     trackAgony          = false,
     trackLinebreaker    = true,

     orbsColor           = {.2235, .6588, .0902, 1},
     conduitColor        = {.3333, .3333,     1, 1},
     harvestColor        = {.5922, .3373, .7373, 1},
     boneyardColor       = {.9490, .4980, .0745, 1},
     agonyColor          = {.6510, .1098, .4157, 1},

     orbs_duration       = 18,
     conduit_duration    = 18,
     harvest_duration    = 18,
     boneyard_duration   = 18,
     agony_duration      = 18,

     warnStolenConduits  = true,
     informTakenConduits = true,
     trackDuringTrash    = false,
     stolenConduits      = {},
}

function wtb.dbg(text)
     if wtb.sv.dbg then
          d("|cff0096WTBConduits:|r " .. text)
     end
end

local function RGBToHex(r, g, b)
     r = string.format("%x", r*255)
     g = string.format("%x", g*255)
     b = string.format("%x", b*255)
     if #r < 2 then r = "0" .. r end
     if #g < 2 then g = "0" .. g end
     if #b < 2 then b = "0" .. b end
     return r .. g .. b
end

function wtb.UpdateSynergyColor(synergy)
     if synergy == "orbs" then
          wtb.orbsHex = RGBToHex(unpack(wtb.sv.orbsColor))
     elseif synergy == "conduit" then
          wtb.conduitHex = RGBToHex(unpack(wtb.sv.conduitColor))
     elseif synergy == "harvest" then
          wtb.harvestHex = RGBToHex(unpack(wtb.sv.harvestColor))
     elseif synergy == "boneyard" then
          wtb.boneyardHex = RGBToHex(unpack(wtb.sv.boneyardColor))
     elseif synergy == "agony" then
          wtb.agonyHex = RGBToHex(unpack(wtb.sv.agonyColor))
     end
end

local function GetTankUnitTag(tankDisplayName)
     if GetGroupSize() > 0 then
          for i = 1, GetGroupSize() do
               if string.lower(GetUnitDisplayName("group" .. i)) == tankDisplayName then
                    return "group" .. i
               end
          end
     else
          return "player"
     end
end

local function UnitIdToName(unitId)
     local name = wtb.GetNameForUnitId(unitId)
     if name == "" then
          return name
     else
          if wtb.groupMembers[name] ~= nil then
               name = wtb.groupMembers[name]
          else
               return name
          end
     end
     return name
end

local function OnZoneChanged()
     wtb.isInDungeon = IsUnitInDungeon("player")
     if not wtb.isInDungeon then
          wtb.sv.stolenConduits = {}
     end
     if wtb.isInDungeon and not wtb.isRegistered then
          wtb.RegisterEvents()
          wtb.isRegistered = true
     elseif not wtb.isInDungeon and wtb.isRegistered then
          wtb.UnregisterEvents()
          wtb.isRegistered = false
     end
end

local function SetTimer(synergy, duration, tank)
     if tank == 1 then
          wtb.timers[synergy] = duration
     elseif tank == 2 then
          synergy = synergy .. "2"
          wtb.timers[synergy] = duration
     elseif tank == 3 then
          synergy = synergy .. "3"
          wtb.timers[synergy] = duration
     end
end

function wtb.SetSynergyDuration(synergy, duration)
     if synergy == "orbs" then
          wtb.synergies[108799][3] = duration     -- Necrotic Orbs
          wtb.synergies[108802][3] = duration     -- Energy Orbs
          wtb.synergies[108924][3] = duration     -- Blessed Shards
          wtb.synergies[108821][3] = duration     -- Holy Shards
     elseif synergy == "conduit" then
          wtb.synergies[108607][3] = duration     -- Conduit
     elseif synergy == "harvest" then
          wtb.synergies[108826][3] = duration     -- Harvest
     elseif synergy == "boneyard" then
          wtb.synergies[125219][3] = duration     -- Boneyard
     elseif synergy == "agony" then
          wtb.synergies[125220][3] = duration     -- Pure Agony
     end
end

function wtb.UpdateTimers()
     for key, value in pairs(wtb.timers) do
          if wtb.timers[key] > 0 then
               wtb.timers[key] = wtb.timers[key] - .250
               local timeRemaining = wtb.timers[key]
               wtb.dbg("Synergy: " .. key .. " : " .. timeRemaining .. "s")
          elseif wtb.timers[key] < 0 then
               wtb.timers[key] = 0
          end
     end

     if wtb.sv.trackDuringTrash then wtb.isInBossFight = true end
     if wtb.isInCombat and wtb.isInBossFight then
          -- Tank 1
          if wtb.monitorTank then
               if wtb.timers.linebreaker <= 0 then
                    local tankName = wtb.sv.tankName
                    if wtb.sv.trackOrbs and wtb.timers.orbs == 0 then
                         WTBConduitsFrame:SetHidden(false)
                         WTBConduitsFrameLabel:SetText("|cccccff" .. tankName .. "|r needs |c" .. wtb.orbsHex .. "Orbs!|r")
                         if wtb.sv.showArrow then wtb:ShowArrow(GetTankUnitTag(wtb.sv.tankName)) end
                    elseif wtb.sv.trackConduit and wtb.timers.conduit == 0 then
                         WTBConduitsFrame:SetHidden(false)
                         WTBConduitsFrameLabel:SetText("|cccccff" .. tankName .. "|r needs a |c" .. wtb.conduitHex .. "Conduit!|r")
                         if wtb.sv.showArrow then wtb:ShowArrow(GetTankUnitTag(wtb.sv.tankName)) end
                    elseif wtb.sv.trackHarvest and wtb.timers.harvest == 0 then
                         WTBConduitsFrame:SetHidden(false)
                         WTBConduitsFrameLabel:SetText("|cccccff" .. tankName .. "|r needs |c" .. wtb.harvestHex .. "Harvest!|r")
                         if wtb.sv.showArrow then wtb:ShowArrow(GetTankUnitTag(wtb.sv.tankName)) end
                    elseif wtb.sv.trackBoneyard and wtb.timers.boneyard == 0 then
                         WTBConduitsFrame:SetHidden(false)
                         WTBConduitsFrameLabel:SetText("|cccccff" .. tankName .. "|r needs |c" .. wtb.boneyardHex .. "Boneyard!|r")
                         if wtb.sv.showArrow then wtb:ShowArrow(GetTankUnitTag(wtb.sv.tankName)) end
                    elseif wtb.sv.trackAgony and wtb.timers.agony == 0 then
                         WTBConduitsFrame:SetHidden(false)
                         WTBConduitsFrameLabel:SetText("|cccccff" .. tankName .. "|r needs |c" .. wtb.agonyHex .. "Pure Agony!|r")
                         if wtb.sv.showArrow then wtb:ShowArrow(GetTankUnitTag(wtb.sv.tankName)) end
                    else
                         WTBConduitsFrame:SetHidden(true)
                         if wtb.sv.showArrow then wtb:HideArrow() end
                    end
               else
                    WTBConduitsFrame:SetHidden(true)
                    if wtb.sv.showArrow then wtb:HideArrow() end
               end
          end

          -- Tank 2
          if wtb.monitorTank2 then
               if wtb.timers.linebreaker2 <= 0 then
                    local tankName2 = wtb.sv.tankName2
                    if wtb.sv.trackOrbs and wtb.timers.orbs2 == 0 then
                         WTBConduitsFrame2:SetHidden(false)
                         WTBConduitsFrame2Label:SetText("|cccccff" .. tankName2 .. "|r needs |c" .. wtb.orbsHex .. "Orbs!|r")
                    elseif wtb.sv.trackConduit and wtb.timers.conduit2 == 0 then
                         WTBConduitsFrame2:SetHidden(false)
                         WTBConduitsFrame2Label:SetText("|cccccff" .. tankName2 .. "|r needs a |c" .. wtb.conduitHex .. "Conduit!|r")
                    elseif wtb.sv.trackHarvest and wtb.timers.harvest2 == 0 then
                         WTBConduitsFrame2:SetHidden(false)
                         WTBConduitsFrame2Label:SetText("|cccccff" .. tankName2 .. "|r needs a |c" .. wtb.conduitHex .. "Conduit!|r")
                    elseif wtb.sv.trackBoneyard and wtb.timers.boneyard2 == 0 then
                         WTBConduitsFrame2:SetHidden(false)
                         WTBConduitsFrame2Label:SetText("|cccccff" .. tankName2 .. "|r needs |c" .. wtb.boneyardHex .. "Boneyard!|r")
                    elseif wtb.sv.trackAgony and wtb.timers.agony2 == 0 then
                         WTBConduitsFrame2:SetHidden(false)
                         WTBConduitsFrame2Label:SetText("|cccccff" .. tankName2 .. "|r needs |c" .. wtb.agonyHex .. "Pure Agony!|r")
                    else
                         WTBConduitsFrame2:SetHidden(true)
                    end
               else
                    WTBConduitsFrame2:SetHidden(true)
               end
          end

          --Tank 3
          if wtb.monitorTank3 then
               if wtb.timers.linebreaker3 <= 0 then
                    local tankName3 = wtb.sv.tankName3
                    if wtb.sv.trackOrbs and wtb.timers.orbs3 == 0 then
                         WTBConduitsFrame3:SetHidden(false)
                         WTBConduitsFrame3Label:SetText("|cccccff" .. tankName3 .. "|r needs |c" .. wtb.orbsHex .. "Orbs!|r")
                    elseif wtb.sv.trackConduit and wtb.timers.conduit3 == 0 then
                         WTBConduitsFrame3:SetHidden(false)
                         WTBConduitsFrame3Label:SetText("|cccccff" .. tankName3 .. "|r needs a |c" .. wtb.conduitHex .. "Conduit!|r")
                    elseif wtb.sv.trackHarvest and wtb.timers.harvest3 == 0 then
                         WTBConduitsFrame3:SetHidden(false)
                         WTBConduitsFrame3Label:SetText("|cccccff" .. tankName3 .. "|r needs a |c" .. wtb.conduitHex .. "Conduit!|r")
                    elseif wtb.sv.trackBoneyard and wtb.timers.boneyard3 == 0 then
                         WTBConduitsFrame3:SetHidden(false)
                         WTBConduitsFrame3Label:SetText("|cccccff" .. tankName3 .. "|r needs |c" .. wtb.boneyardHex .. "Boneyard!|r")
                    elseif wtb.sv.trackAgony and wtb.timers.agony3 == 0 then
                         WTBConduitsFrame3:SetHidden(false)
                         WTBConduitsFrame3Label:SetText("|cccccff" .. tankName3 .. "|r needs |c" .. wtb.agonyHex .. "Pure Agony!|r")
                    else
                         WTBConduitsFrame3:SetHidden(true)
                    end
               else
                    WTBConduitsFrame3:SetHidden(true)
               end
          end
     end
end

function wtb.CombatState(event, isInCombat)
     if isInCombat ~= wtb.isInCombat then
          wtb.isInCombat = isInCombat
          if wtb.isInCombat and wtb.isInDungeon then
               if GetUnitName("boss1") == "" and GetUnitName("boss2") == "" then
                    wtb.dbg("Not in a boss fight")
                    wtb.isInBossFight = false
               else
                    wtb.dbg("In a boss fight")
                    wtb.isInBossFight = true
               end

               wtb.playerRole = GetGroupMemberAssignedRole("player")
               wtb.IndexGroupMembers()
               wtb.IndexTanks()
               wtb.IndexBosses()
               local role = ""
               if wtb.playerRole == LFG_ROLE_TANK then role = "Tank"
               elseif wtb.playerRole == LFG_ROLE_HEAL then role = "Healer"
               elseif wtb.playerRole == LFG_ROLE_DPS then role = "DPS"
               else role = "Unknown" end
               wtb.dbg("Your role is: " .. role)
          else
               wtb.IndexGroupMembers()
               wtb.IndexTanks()
               wtb:HideArrow()
               WTBConduitsFrame:SetHidden(true)
               WTBConduitsFrame2:SetHidden(true)
               WTBConduitsFrame3:SetHidden(true)
          end
     end
end

function wtb.OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
     local sourceDisplayName = UnitIdToName(sourceUnitId)
     local targetDisplayName = UnitIdToName(targetUnitId)

     if result == ACTION_RESULT_EFFECT_GAINED and abilityId == wtb.synergies.linebreaker then
          wtb.dbg("-------------------------")
          wtb.dbg("result: " .. result .. " (Alkosh Proc)")
          wtb.dbg("-------------------------")
          wtb.dbg("abilityId: " .. abilityId)
          wtb.dbg("abilityName: " .. GetAbilityName(abilityId))
          wtb.dbg("sourceName: " .. sourceName)
          wtb.dbg("targetName: " .. targetName)
          wtb.dbg("sourceUnitId: " .. sourceUnitId)
          wtb.dbg("targetUnitId: " .. targetUnitId)
          wtb.dbg("Source Name: " .. sourceDisplayName)
          wtb.dbg("Target Name: " .. targetDisplayName)

          local targetName = zo_strformat("<<1>>", targetName)
          local tankName = wtb.sv.tankName
          local tankName2 = wtb.sv.tankName2
          local tankName3 = wtb.sv.tankName3
          sourceDisplayName = string.lower(sourceDisplayName)

          if wtb.bosses[targetDisplayName] then -- Was Alkosh line-breaker procced on one of the tracked bosses
               wtb.dbg("Setting Alkosh timer for all tanks")
               SetTimer("linebreaker", 8, 1)
               SetTimer("linebreaker", 8, 2)
               SetTimer("linebreaker", 8, 3)
          else
               wtb.dbg("Alkosh procced, but not on one of the tracked bosses")
               if sourceDisplayName == tankName then
                    SetTimer("linebreaker", 8, 1)
               elseif sourceDisplayName == tankName2 then
                    SetTimer("linebreaker", 8, 2)
               elseif sourceDisplayName == tankName3 then
                    SetTimer("linebreaker", 8, 3)
               end
          end
     elseif result == ACTION_RESULT_EFFECT_GAINED and abilityId ~= wtb.synergies.linebreaker then
          wtb.dbg("-------------------------")
          wtb.dbg("result: " .. result .. " (Synergy Proc)")
          wtb.dbg("-------------------------")
          wtb.dbg("abilityId: " .. abilityId)
          wtb.dbg("abilityName: " .. GetAbilityName(abilityId))
          wtb.dbg("sourceName: " .. sourceName)
          wtb.dbg("targetName: " .. targetName)
          wtb.dbg("sourceUnitId: " .. sourceUnitId)
          wtb.dbg("targetUnitId: " .. targetUnitId)
          wtb.dbg("Source Name: " .. sourceDisplayName)
          wtb.dbg("Target Name: " .. targetDisplayName)

          targetDisplayName = string.lower(targetDisplayName)
          local tankName = wtb.sv.tankName
          local tankName2 = wtb.sv.tankName2
          local tankName3 = wtb.sv.tankName3

          if wtb.synergies[abilityId][1] and targetDisplayName == tankName then -- If it is a tracked ability and the target is the first tracked tank
               local synergy = wtb.synergies[abilityId][2]
               local delay = wtb.synergies[abilityId][3]
               SetTimer(synergy, delay, 1)
               wtb.dbg("Setting Tank 1 " .. synergy .. " timer for " .. delay .. " seconds.")
          elseif wtb.synergies[abilityId][1] and targetDisplayName == tankName2 then -- If it is a tracked ability and the target is the second tracked tank
               local synergy = wtb.synergies[abilityId][2]
               local delay = wtb.synergies[abilityId][3]
               SetTimer(synergy, delay, 2)
               wtb.dbg("Setting Tank 2 " .. synergy .. " timer for " .. delay .. " seconds.")
          elseif wtb.synergies[abilityId][1] and targetDisplayName == tankName3 then -- If it is a tracked ability and the target is the third tracked tank
               local synergy = wtb.synergies[abilityId][2]
               local delay = wtb.synergies[abilityId][3]
               SetTimer(synergy, delay, 3)
               wtb.dbg("Setting Tank 3 " .. synergy .. " timer for " .. delay .. " seconds.")
          end
          if abilityId == 108607 then -- Conduit
               if wtb.isInCombat then
                    if wtb.sv.warnStolenConduits then
                         if not wtb.tanks[targetDisplayName] then
                              d("|cff0000" .. targetDisplayName .. " stole a conduit|r")
                         end
                    else
                         wtb.dbg("Not tracking Stolen Conduits")
                    end
                    if wtb.sv.informTakenConduits then
                         if wtb.tanks[targetDisplayName] then
                              d("|c0000ff" .. targetDisplayName .. " took a conduit|r")
                         end
                    else
                         wtb.dbg("Not tracking Taken Conduits")
                    end
                    if wtb.stolenConduits[targetDisplayName] ~= nil then
                         wtb.stolenConduits[targetDisplayName] = wtb.stolenConduits[targetDisplayName] + 1
                    else
                         wtb.stolenConduits[targetDisplayName] = 1
                    end

                    if wtb.sv.stolenConduits[targetDisplayName] ~= nil then
                         wtb.sv.stolenConduits[targetDisplayName] = wtb.sv.stolenConduits[targetDisplayName] + 1
                    else
                         wtb.sv.stolenConduits[targetDisplayName] = 1
                    end
               end
          end
     end
end

function wtb.OnBossesChanged(_)
     if GetUnitName("boss1") == "" and GetUnitName("boss2") == "" then
          wtb.dbg("Leaving Boss Fight")
          wtb.isInBossFight = false
     else
          wtb.dbg("Entering Boss Fight")
          wtb.isInBossFight = true
     end
end

local function PrintStolenConduits()
     d("|cff0000Conduits Taken:|r")
     for key, value in pairs(wtb.sv.stolenConduits) do
          if wtb.tanks[key] then
               d("|c1EB2E3" .. key .. ":|r |cff0000" .. value .. "|r")
          else
               d("|cff0096" .. key .. ":|r |cff0000" .. value .. "|r")
          end
     end
end

function wtb.Initialize()
     CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnZoneChanged)
     wtb.savedVars = ZO_SavedVars:NewCharacterIdSettings("WTBConduitsVars", wtb.variableVersion, nil, wtb.defaults)
     wtb.sv = WTBConduitsVars["Default"][GetDisplayName()][GetCurrentCharacterId()]
     wtb.CreateSettingsWindow()
     wtb.RegisterUnitIndexing()
     wtb.ResetAnchors()

     wtb.SetFontSize(WTBConduitsFrameLabel, wtb.sv.fontSize)
     wtb.SetFontSize(WTBConduitsFrame2Label, wtb.sv.fontSize)
     wtb.SetFontSize(WTBConduitsFrame3Label, wtb.sv.fontSize)

     wtb.SetSynergyDuration("orbs", wtb.sv.orbs_duration)
     wtb.SetSynergyDuration("conduit", wtb.sv.conduit_duration)
     wtb.SetSynergyDuration("harvest", wtb.sv.harvest_duration)
     wtb.SetSynergyDuration("boneyard", wtb.sv.boneyard_duration)
     wtb.SetSynergyDuration("agony", wtb.sv.agony_duration)

     wtb.UpdateSynergyColor("orbs")
     wtb.UpdateSynergyColor("conduit")
     wtb.UpdateSynergyColor("harvest")
     wtb.UpdateSynergyColor("boneyard")
     wtb.UpdateSynergyColor("agony")

     wtb.IndexGroupMembers()
     wtb.IndexTanks()
     wtb:InitializeArrow()

     wtb:StyleArrow(wtb.name .. "/texture/arrow.dds", wtb.sv.arrowColor, wtb.sv.arrowScale)
     wtb.stolenConduits = wtb.sv.stolenConduits
     SLASH_COMMANDS["/stolenconduits"] = function() PrintStolenConduits() end
end

function wtb.OnAddOnLoaded(event, addonName)
     if wtb.name ~= addonName then return end
     wtb.Initialize()

     EVENT_MANAGER:UnregisterForEvent(wtb.name, EVENT_ADD_ON_LOADED)
end
EVENT_MANAGER:RegisterForEvent(wtb.name, EVENT_ADD_ON_LOADED, wtb.OnAddOnLoaded)
