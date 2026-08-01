local wtb = WTBConduits

function wtb.IndexBosses()
     wtb.bosses = {}
     for i = 1, MAX_BOSSES do
          local bossName = GetUnitName("boss" .. i)
          if GetUnitName("boss1") ~= "" and GetUnitName("boss2") ~= "" then
               if bossName ~= "" then
                    wtb.bosses[bossName] = false
               end
          else
               if bossName ~= "" then
                    wtb.bosses[bossName] = true
               end
          end

     end
     for key, value in pairs(wtb.bosses) do
          wtb.dbg("Boss: " .. key .. " = " .. tostring(value))
     end
end

function wtb.IndexTanks()
     wtb.tanks = {}
     if GetGroupSize() == 0 then
          wtb.dbg("Not in a group. Indexing failed")
     else
          for i = 1, GetGroupSize() do -- For each member in your group
               local memberDisplayName = string.lower(GetUnitDisplayName("group" .. i)) -- The member's @DisplayName
               local role = GetGroupMemberAssignedRole("group" .. i)
               if role == LFG_ROLE_TANK then
                    wtb.tanks[memberDisplayName] = true
               end
          end
     end
     local tanks = "Tanks: "
     for key, value in pairs(wtb.tanks) do
          tanks = tanks .. key .. ", "
     end
     wtb.dbg(tanks)
end

function wtb.IndexGroupMembers()
     local groupSize = GetGroupSize()
     if groupSize == 0 then
          wtb.groupMembers[GetUnitName("player")] = GetUnitDisplayName("player")
     else
          for i = 1, groupSize do -- For each member in your group
               local memberCharacterName = GetUnitName("group" .. i) -- The member's character name
               local memberDisplayName = GetUnitDisplayName("group" .. i) -- The member's @DisplayName
               wtb.groupMembers[memberCharacterName] = memberDisplayName -- Store them in the groupMembers table
          end
     end

     for key, value in pairs(wtb.groupMembers) do
          value = string.lower(value)
          if value == wtb.sv.tankName then
               wtb.monitorTank = true
               break
          else
               wtb.monitorTank = false
          end
     end
     if wtb.sv.enableTank2 then
          wtb.dbg("Tank 2 is enabled")
          wtb.dbg("Tank 2 Display Name: " .. wtb.sv.tankName2)
          for key, value in pairs(wtb.groupMembers) do
               value = string.lower(value)
               if value == wtb.sv.tankName2 then
                    wtb.monitorTank2 = true
                    break
               else
                    wtb.monitorTank2 = false
               end
          end
     else
          wtb.dbg("Tank 2 is disabled")
     end
     if wtb.sv.enableTank3 then
          wtb.dbg("Tank 3 is enabled")
          wtb.dbg("Tank 3 Display Name: " .. wtb.sv.tankName3)
          for key, value in pairs(wtb.groupMembers) do
               value = string.lower(value)
               if value == wtb.sv.tankName3 then
                    wtb.monitorTank3 = true
                    break
               else
                    wtb.monitorTank3 = false
               end
          end
     else
          wtb.dbg("Tank 3 is disabled")
     end
end
