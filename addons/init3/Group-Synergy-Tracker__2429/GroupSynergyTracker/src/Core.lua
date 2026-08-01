GroupSynergyTracker = GroupSynergyTracker or {}
local GST = GroupSynergyTracker
local EM = EVENT_MANAGER

--[[
ChangeLog 1.4.2:
     Blacklist is no longer case sensitive
     The timers will no longer reset when a player in the group disconnects
]]

GST.author = "@init3 [NA]"
GST.name = "GroupSynergyTracker"
GST.version = "1.4.5"
GST.variableVersion = 2
GST.trackedUsers = {}
GST.groupMembers = {}
GST.refreshRate = 200
GST.width = 230
GST.isMovable = false
GST.max_rows = 4
GST.max_synergies = GST.max_rows * 2
GST.testingTimers = false
GST.selectedBlacklistUser = nil
GST.frames = {}
GST.ids = {}

GST.endTimes = { frames = {} }

local function round(number, decimalPlaces)
     local mult = 10^(decimalPlaces or 0)
     return math.floor(number * mult + 0.5) / mult
end

local function RemoveSpaces(str)
     return str:gsub("%s+", "")
end

function GST.IsStringInTable(str, tbl, caseSensitive)
     for key, value in pairs(tbl) do
          if caseSensitive then
               if value == str then
                    return true
               end
          else
               if string.lower(value) == string.lower(str) then
                    return true
               end
          end
     end
     return false
end

function GST.GetTrackedSynergies()
     local trackedSynergies = {}
     local sortedSynergies = {}
     local numTrackedSynergies = 0
     for key, value in ipairs(GST.sv.trackedSynergies) do
          if value ~= "" then
               trackedSynergies[key] = value
          end
     end

     for i = 1, GST.max_synergies do
          if trackedSynergies[i] ~= nil and trackedSynergies[i] ~= "" then
               sortedSynergies[#sortedSynergies + 1] = trackedSynergies[i]
          end
     end
     return sortedSynergies
end

function GST.GetNumTrackedSynergies()
     local count = 0
     for key, pair in pairs(GST.GetTrackedSynergies()) do
          count = count + 1
     end
     return count
end

function GST.GetNumRows()
     return math.ceil(GST.GetNumTrackedSynergies() / 2)
end

function GST.ToggleMovable()
     GST.isMovable = not GST.isMovable
end

local function UnitIdToName(unitId)
     local name = GST.GetNameForUnitId(unitId)
     if name == "" then
          return "#" .. unitId
     else
          if GST.groupMembers[name] ~= nil then
               name = GST.groupMembers[name]["displayName"]
               return name
          else
               return "#" .. unitId
          end
     end
end

local function UpdateTimers()
     local endTime = 0
     local timeRemaining = 0
     for i = 1, #GST.frames do
          for j = 1, GST.GetNumRows() do
               if GST.frames[i].rows[j].synergyTime1:GetText() ~= "" and GST.frames[i].rows[j].synergyTime1:GetText() ~= "0.0" then
                    endTime = GST.endTimes.frames[i].rows[j].column[1]
                    timeRemaining = endTime - GetGameTimeSeconds()

                    if timeRemaining > 0 then
                         timeRemaining = round(timeRemaining - (GST.refreshRate / 1000), 1)
                         if timeRemaining < 0 then timeRemaining = 0 end
                         if timeRemaining == math.floor(timeRemaining) then timeRemaining = timeRemaining .. ".0" end
                         GST.frames[i].rows[j].synergyTime1:SetText(timeRemaining)
                         if GST.sv.debug.showCountdowns then
                              d(GST.frames[i].rows[j].synergyName1:GetText() .. " " .. timeRemaining)
                         end
                    end

                    timeRemaining = tonumber(timeRemaining)

                    local percentComplete = (timeRemaining / 20) * 100
                    local completeValue = (percentComplete * 2) / 100
                    local redBar = (percentComplete > 50 and 2 - completeValue) or 1
                    local greenBar = (percentComplete < 50 and completeValue) or 1
                    if GST.sv.cooldownBars then
                         GST.frames[i].rows[j].BG1:SetHidden(false)
                         GST.frames[i].rows[j].BG1:SetDimensions(percentComplete, 18)
                         GST.frames[i].rows[j].BG1:SetCenterColor(redBar, greenBar, 0, 0.5)
                         GST.frames[i].rows[j].BG1:SetEdgeColor(redBar, greenBar, 0, 0.5)
                    end

                    if timeRemaining == 0 then
                         GST.frames[i].rows[j].synergyTime1:SetColor(1, 1, 1)
                         GST.frames[i].rows[j].BG1:SetEdgeColor(redBar, greenBar, 0, 0)
                    else
                         GST.frames[i].rows[j].synergyTime1:SetColor(redBar, greenBar, 0)
                    end
               end

               if GST.frames[i].rows[j].synergyTime2:GetText() ~= "" and GST.frames[i].rows[j].synergyTime2:GetText() ~= "0.0" then
                    endTime = GST.endTimes.frames[i].rows[j].column[2]
                    timeRemaining = endTime - GetGameTimeSeconds()

                    if timeRemaining > 0 then
                         timeRemaining = round(timeRemaining - (GST.refreshRate / 1000), 1)
                         if timeRemaining < 0 then timeRemaining = 0 end
                         if timeRemaining == math.floor(timeRemaining) then timeRemaining = timeRemaining .. ".0" end
                         GST.frames[i].rows[j].synergyTime2:SetText(timeRemaining)
                         if GST.sv.debug.showCountdowns then
                              d(GST.frames[i].rows[j].synergyName2:GetText() .. " " .. timeRemaining)
                         end
                    end

                    local percentComplete = (timeRemaining / 20) * 100
                    local completeValue = (percentComplete * 2) / 100
                    local redBar = (percentComplete > 50 and 2 - completeValue) or 1
                    local greenBar = (percentComplete < 50 and completeValue) or 1
                    if GST.sv.cooldownBars then
                         GST.frames[i].rows[j].BG2:SetHidden(false)
                         GST.frames[i].rows[j].BG2:SetDimensions(percentComplete, 18)
                         GST.frames[i].rows[j].BG2:SetCenterColor(redBar, greenBar, 0, 0.5)
                         GST.frames[i].rows[j].BG2:SetEdgeColor(redBar, greenBar, 0, 0.5)
                    end

                    timeRemaining = tonumber(timeRemaining)
                    if timeRemaining == 0 then
                         GST.frames[i].rows[j].synergyTime2:SetColor(1, 1, 1)
                         GST.frames[i].rows[j].BG2:SetEdgeColor(redBar, greenBar, 0, 0)
                    else
                         GST.frames[i].rows[j].synergyTime2:SetColor(redBar, greenBar, 0)
                    end
               end
          end
     end
end

function GST.OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
     targetDisplayName = UnitIdToName(targetUnitId)
     if result == ACTION_RESULT_EFFECT_GAINED then
          for frame = 1, #GST.frames do
               if string.lower(targetDisplayName) == string.lower(GST.trackedUsers[frame]) then
                    for row = 1, GST.GetNumRows() do
                         if GST.frames[frame].rows[row].synergyName1:GetText():sub(1, -2) == GST.ids[abilityId] then
                              GST.endTimes.frames[frame].rows[row].column[1] = GetGameTimeSeconds() + 20
                              GST.frames[frame].rows[row].synergyTime1:SetText(20)
                              break
                         elseif GST.frames[frame].rows[row].synergyName2:GetText():sub(1, -2) == GST.ids[abilityId] then
                              GST.endTimes.frames[frame].rows[row].column[2] = GetGameTimeSeconds() + 20
                              GST.frames[frame].rows[row].synergyTime2:SetText(20)
                              break
                         end
                    end
               end
          end
          local color = "FFFFFF"
          if GST.ids[abilityId] == "Orb/Shard" and GST.sv.debug.showTakenSynergies.orbs.active then
               color = GST.sv.debug.showTakenSynergies.orbs.color
               if GetGroupSize() > 1 then
                    d("|cff0096" .. targetDisplayName .. "|r|c50C7C7 used |r|c" .. color .. "Orb/Shard.|r")
               else
                    d("|cff0096*Unknown*|r|c50C7C7 used |r|c" .. color .. "Orb/Shard.|r")
               end
          elseif GST.ids[abilityId] == "Conduit" and GST.sv.debug.showTakenSynergies.conduit.active then
               color = GST.sv.debug.showTakenSynergies.conduit.color
               if GetGroupSize() > 1 then
                    d("|cff0096" .. targetDisplayName .. "|r|c50C7C7 used |r|c" .. color .. "Conduit.|r")
               else
                    d("|cff0096*Unknown*|r|c50C7C7 used |r|c" .. color .. "Conduit.|r")
               end
          elseif GST.ids[abilityId] == "Purify" and GST.sv.debug.showTakenSynergies.purify.active then
               color = GST.sv.debug.showTakenSynergies.purify.color
               if GetGroupSize() > 1 then
                    d("|cff0096" .. targetDisplayName .. "|r|c50C7C7 used |r|c" .. color .. "Purify.|r")
               else
                    d("|cff0096*Unknown*|r|c50C7C7 used |r|c" .. color .. "Purify.|r")
               end
          elseif GST.ids[abilityId] == "Harvest" and GST.sv.debug.showTakenSynergies.harvest.active then
               color = GST.sv.debug.showTakenSynergies.harvest.color
               if GetGroupSize() > 1 then
                    d("|cff0096" .. targetDisplayName .. "|r|c50C7C7 used |r|c" .. color .. "Harvest.|r")
               else
                    d("|cff0096*Unknown*|r|c50C7C7 used |r|c" .. color .. "Harvest.|r")
               end
          elseif GST.ids[abilityId] == "Boneyard" and GST.sv.debug.showTakenSynergies.boneyard.active then
               color = GST.sv.debug.showTakenSynergies.boneyard.color
               if GetGroupSize() > 1 then
                    d("|cff0096" .. targetDisplayName .. "|r|c50C7C7 used |r|c" .. color .. "Boneyard.|r")
               else
                    d("|cff0096*Unknown*|r|c50C7C7 used |r|c" .. color .. "Boneyard.|r")
               end
          elseif GST.ids[abilityId] == "Agony" and GST.sv.debug.showTakenSynergies.pure_agony.active then
               color = GST.sv.debug.showTakenSynergies.pure_agony.color
               if GetGroupSize() > 1 then
                    d("|cff0096" .. targetDisplayName .. "|r|c50C7C7 used |r|c" .. color .. "Pure Agony.|r")
               else
                    d("|cff0096*Unknown*|r|c50C7C7 used |r|c" .. color .. "Pure Agony.|r")
               end
          elseif GST.ids[abilityId] == "Bone Shield" and GST.sv.debug.showTakenSynergies.bone_shield.active then
               color = GST.sv.debug.showTakenSynergies.bone_shield.color
               if GetGroupSize() > 1 then
                    d("|cff0096" .. targetDisplayName .. "|r|c50C7C7 used |r|c" .. color .. "Bone Shield.|r")
               else
                    d("|cff0096*Unknown*|r|c50C7C7 used |r|c" .. color .. "Bone Shield.|r")
               end
          elseif GST.ids[abilityId] == "Blood Altar" and GST.sv.debug.showTakenSynergies.altar.active then
               color = GST.sv.debug.showTakenSynergies.altar.color
               if GetGroupSize() > 1 then
                    d("|cff0096" .. targetDisplayName .. "|r|c50C7C7 used |r|c" .. color .. "Blood Altar.|r")
               else
                    d("|cff0096*Unknown*|r|c50C7C7 used |r|c" .. color .. "Blood Altar.|r")
               end
          elseif GST.ids[abilityId] == "Spiders" and GST.sv.debug.showTakenSynergies.spiders.active then
               color = GST.sv.debug.showTakenSynergies.spiders.color
               if GetGroupSize() > 1 then
                    d("|cff0096" .. targetDisplayName .. "|r|c50C7C7 used |r|c" .. color .. "Spiders.|r")
               else
                    d("|cff0096*Unknown*|r|c50C7C7 used |r|c" .. color .. "Spiders.|r")
               end
          end
     end
end

local function RegisterEvents()
     local abilities = {}
     local eventName = GST.name .. "_event_"
     local eventIndex = 0

     local function RegisterForAbility(abilityId)
          if not abilities[abilityId] then
               abilities[abilityId] = true
               eventIndex = eventIndex + 1
               EM:RegisterForEvent(eventName .. eventIndex, EVENT_COMBAT_EVENT, GST.OnCombatEvent)
               EM:AddFilterForEvent(eventName .. eventIndex, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
          end
     end

     for key, value in pairs(GST.ids) do
          RegisterForAbility(key)
     end

     EM:RegisterForUpdate(GST.name, GST.refreshRate, UpdateTimers)
     EM:RegisterForEvent(GST.name, EVENT_RETICLE_HIDDEN_UPDATE, GST.ReticleChanged)
     EM:RegisterForEvent(GST.name, EVENT_GROUP_MEMBER_ROLE_CHANGED, GST.GroupMemberRoleChanged)
     EM:RegisterForEvent(GST.name, EVENT_GROUP_MEMBER_LEFT, GST.UpdateFrame)
     EM:RegisterForEvent(GST.name, EVENT_GROUP_MEMBER_JOINED, GST.UpdateFrame)
end

function GST.TestTimers(number, timerLength)
     local rand = 0
     local row = 0
     local high = 0

     GST.IndexTrackedPlayers()

     GST.testingTimers = true
     if HodorReflexes then
          if HodorReflexes.users then
               if #GST.trackedUsers == 0 then
                    local count = 1
                    for key, value in pairs(HodorReflexes.users) do
                         GST.trackedUsers[count] = key
                         if not GST.IsStringInTable(key, GST.sv.blacklist, false) then
                              count = count + 1
                              if count == number + 1 then break end
                         end
                    end
               end
          end
     end

     for i = 1, #GST.trackedUsers do
          GST.UpdateFrame()
          GST.frames[i]:SetHidden(false)
          GST.frames[i]:SetScale(GST.sv.frame_scale)
     end

     for frame = 1, #GST.frames do
          for synergy = 1, GST.GetNumTrackedSynergies() do
               rand = math.random(5, 20)
               if timerLength then rand = timerLength end
               row = math.ceil(synergy / 2)
               if synergy % 2 ~= 0 then
                    if rand > high then high = rand end
                    GST.endTimes.frames[frame].rows[row].column[1] = GetGameTimeSeconds() + rand
                    GST.frames[frame].rows[row].synergyTime1:SetText(rand)
               else
                    if rand > high then high = rand end
                    GST.endTimes.frames[frame].rows[row].column[2] = GetGameTimeSeconds() + rand
                    GST.frames[frame].rows[row].synergyTime2:SetText(rand)
               end
          end
     end
     zo_callLater(function()
          if GetGroupSize() == 0 then
               for i = 1, #GST.frames do
                    GST.frames[i]:SetHidden(true)
                    GST.frames[i]:SetScale(0)
               end
          end
          GST.testingTimers = false
          GST.IndexTrackedPlayers()
     end, (high + 0.5) * 1000)
end

function GST.OnMoveStop()
	GST.sv.offsetX = GST.frames[1]:GetLeft()
	GST.sv.offsetY = GST.frames[1]:GetTop()
end

function GST.ReticleChanged(_, hidden)
     if not GST.isMovable then
          for i = 1, #GST.frames do
               if GST.frames[i] ~= nil then
                    GST.frames[i]:SetHidden(hidden)
                    GST.frames[i]:SetMovable(not hidden)
                    GST.frames[i]:SetMouseEnabled(not hidden)
               end
          end
     end
end

function GST.Initialize()
     GST.savedVars = ZO_SavedVars:NewCharacterIdSettings("GSTVars", GST.variableVersion, nil, GST.defaults)
     GST.sv = GSTVars["Default"][GetDisplayName()][GetCurrentCharacterId()]

     local trackedSynergies = GST.GetTrackedSynergies()

     GST.ids[108799] = "Orb/Shard"      -- Necrotic Orbs
     GST.ids[108802] = "Orb/Shard"      -- Energy Orbs
     GST.ids[108924] = "Orb/Shard"      -- Blessed Shards
     GST.ids[108821] = "Orb/Shard"      -- Holy Shards
     GST.ids[108607] = "Conduit"        -- Conduit
     GST.ids[108824] = "Purify"         -- Purify
     GST.ids[108826] = "Harvest"        -- Harvest
     GST.ids[125219] = "Boneyard"       -- Boneyard
     GST.ids[125220] = "Agony"          -- Pure Agony
     GST.ids[108794] = "Bone Shield"    -- Bone Wall
     GST.ids[108797] = "Bone Shield"    -- Spinal Surge
     GST.ids[108782] = "Blood Altar"    -- Blood Funnel
     GST.ids[108787] = "Blood Altar"    -- Blood Feast
     GST.ids[108788] = "Spiders"        -- Spawn Broodlings Synergy (Trapping Webs)
     GST.ids[108791] = "Spiders"        -- Black Widows Synergy     (Shadow Silk)
     GST.ids[108792] = "Spiders"        -- Arachnophobia Synergy    (Tangling Webs)

     GST.RegisterUnitIndexing()
     GST.IndexGroupMembers()
     GST.IndexTrackedPlayers()
     GST.RegisterSettingsWindow()

	GST.CreateFrame("GSTPlayerFrame1", 1)
	GST.frames[1]:ClearAnchors()
	GST.frames[1]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GST.sv.offsetX, GST.sv.offsetY)

     GST.UpdateFrame()
     RegisterEvents()
end

function GST.OnAddOnLoaded(event, addonName)
     if GST.name ~= addonName then return end
     GST.Initialize()

     EM:UnregisterForEvent(GST.name, EVENT_ADD_ON_LOADED)
end
EM:RegisterForEvent(GST.name, EVENT_ADD_ON_LOADED, GST.OnAddOnLoaded)
