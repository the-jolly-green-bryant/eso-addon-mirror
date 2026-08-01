local GST = GroupSynergyTracker

function GST.IndexGroupMembers()
     local groupMembers = {}
     local groupSize = GetGroupSize()
     if groupSize == 0 then -- If you're not in a group, but for whatever reason trying to solo Asylum, this will prevent the addon bugging out because it can't index the members in your non-existant group
          groupMembers[GetUnitName("player")] = {
               ["displayName"] = GetUnitDisplayName("player"),
               ["groupID"] = "player",
               ["role"] = GetGroupMemberAssignedRole("player"),
          }
     else
          for i = 1, groupSize do -- For each member in your group
               local memberDisplayName = GetUnitDisplayName("group" .. i) -- The member's @DisplayName
               local memberCharacterName = GetUnitName("group" .. i)
               if memberCharacterName ~= "" and memberCharacterName ~= nil then
                    groupMembers[memberCharacterName] = {
                         ["displayName"] = memberDisplayName,
                         ["groupID"] = "group" .. i,
                         ["role"] = GetGroupMemberAssignedRole("group" .. i),
                    }
               end
          end
     end
     GST.groupMembers = groupMembers
end

function GST.IndexTrackedPlayers()
     local trackedUsers = {}
     local unsortedUsers = {}
     local displayName = ""
     local groupID = ""

     for key, value in pairs(GST.groupMembers) do
          displayName = value["displayName"]
          groupID = value["groupID"]
          if not GST.IsStringInTable(displayName, GST.sv.blacklist, false) then
               if GetGroupMemberAssignedRole(groupID) == LFG_ROLE_DPS then
                    if GST.sv.showDPS then
                         unsortedUsers[#unsortedUsers + 1] = {
                              [1] = displayName,
                              [2] = groupID,
                         }
                    end
               elseif GetGroupMemberAssignedRole(groupID) == LFG_ROLE_HEAL then
                    if GST.sv.showHealers then
                         unsortedUsers[#unsortedUsers + 1] = {
                              [1] = displayName,
                              [2] = groupID,
                         }
                    end
               elseif GetGroupMemberAssignedRole(groupID) == LFG_ROLE_TANK then
                    if GST.sv.showTanks then
                         unsortedUsers[#unsortedUsers + 1] = {
                              [1] = displayName,
                              [2] = groupID,
                         }
                    end
               end
          end
     end

     for key, value in pairs(unsortedUsers) do
          if GetGroupMemberAssignedRole(value[2]) == LFG_ROLE_TANK then
               trackedUsers[#trackedUsers + 1] = value[1]
          end
     end
     for key, value in pairs(unsortedUsers) do
          if GetGroupMemberAssignedRole(value[2]) == LFG_ROLE_HEAL then
               trackedUsers[#trackedUsers + 1] = value[1]
          end
     end
     for key, value in pairs(unsortedUsers) do
          if GetGroupMemberAssignedRole(value[2]) == LFG_ROLE_DPS then
               trackedUsers[#trackedUsers + 1] = value[1]
          end
     end
     GST.trackedUsers = trackedUsers
     if GSTBlacklistGroupDropdown then GSTBlacklistGroupDropdown:UpdateChoices(GST.trackedUsers) end
end
