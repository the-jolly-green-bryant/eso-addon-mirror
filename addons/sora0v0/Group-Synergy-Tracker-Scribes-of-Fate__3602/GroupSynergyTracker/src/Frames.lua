local GST = GroupSynergyTracker

local classIcons = {}
for i = 1, GetNumClasses() do
	local id, _, _, _, _, _, icon, _, _, _ = GetClassInfo(i)
	classIcons[id] = icon -- Creates a table of ClassIds with their icon paths
end

function GST.GroupMemberRoleChanged(_, unitTag, role)
	if role ~= LFG_ROLE_INVALID then
		for key, value in pairs(GST.groupMembers) do
			if value["groupID"] == unitTag then
				if role ~= value["role"] then
					GST.UpdateFrame()
				end
			end
		end
	end
end

function GST.CreateFrame(frameName, frameID)
     local direction = GST.sv.growth_direction
     local numRows = GST.GetNumRows()
     GST.frames[frameID] = WINDOW_MANAGER:CreateControlFromVirtual(frameName, GuiRoot, "PlayerFrameTemplate")

	GST.frames[frameID].BG = GST.frames[frameID]:GetNamedChild("BG")
     GST.frames[frameID].rows = {}
     GST.frames[frameID].icon = GST.frames[frameID]:GetNamedChild("Icon")
     GST.frames[frameID].playerName = GST.frames[frameID]:GetNamedChild("PlayerName")
     GST.frames[frameID].playerName:SetText("@TestUser")

     GST.endTimes.frames[frameID] = {}
     GST.endTimes.frames[frameID].rows = {}
     for i = 1, GST.max_rows do
          GST.frames[frameID].rows[i] = GST.frames[frameID]:GetNamedChild("Row" .. i)
          GST.frames[frameID].rows[i].BG1 = GST.frames[frameID].rows[i]:GetNamedChild("BG1")
          GST.frames[frameID].rows[i].synergyName1 = GST.frames[frameID].rows[i]:GetNamedChild("SynergyName1")
          GST.frames[frameID].rows[i].synergyTime1 = GST.frames[frameID].rows[i]:GetNamedChild("SynergyTime1")
          GST.frames[frameID].rows[i].BG2 = GST.frames[frameID].rows[i]:GetNamedChild("BG2")
          GST.frames[frameID].rows[i].synergyName2 = GST.frames[frameID].rows[i]:GetNamedChild("SynergyName2")
          GST.frames[frameID].rows[i].synergyTime2 = GST.frames[frameID].rows[i]:GetNamedChild("SynergyTime2")

          GST.endTimes.frames[frameID].rows[i] = {}
          GST.endTimes.frames[frameID].rows[i].column = {}
          GST.endTimes.frames[frameID].rows[i].column[1] = -1
          GST.endTimes.frames[frameID].rows[i].column[2] = -1
     end

     local row = 1
     local trackedSynergies = GST.GetTrackedSynergies()
     for j = 1, GST.GetNumTrackedSynergies() do -- For each synergy that is being tracked, display it on the frame with a default time remaining of 0.0
          if trackedSynergies[j] then
               if j % 2 ~= 0 then
                    GST.frames[frameID].rows[row].synergyName1:SetText(trackedSynergies[j] .. ":")
                    GST.frames[frameID].rows[row].synergyTime1:SetText("0.0")
               elseif j % 2 == 0 then
                    GST.frames[frameID].rows[row].synergyName2:SetText(trackedSynergies[j] .. ":")
                    GST.frames[frameID].rows[row].synergyTime2:SetText("0.0")
                    row = row + 1
               end
          end
     end

     GST.frames[frameID]:SetDimensions(GST.width, (numRows * 18 + 28))
     if frameID ~= 1 then -- Changes the way the frames anchor depending on the direction the frames were told to grow in settings
          GST.frames[frameID]:ClearAnchors()
          if direction == "Down" then
               GST.frames[frameID]:SetAnchor(TOPLEFT, GST.frames[frameID - 1], BOTTOMLEFT, 0, 3)
          elseif direction == "Up" then
               GST.frames[frameID]:SetAnchor(BOTTOMLEFT, GST.frames[frameID - 1], TOPLEFT, 0, -3)
          elseif direction == "Left" then
               GST.frames[frameID]:SetAnchor(TOPRIGHT, GST.frames[frameID - 1], TOPLEFT, -3, 0)
          elseif direction == "Right" then
               GST.frames[frameID]:SetAnchor(TOPLEFT, GST.frames[frameID - 1], TOPRIGHT, 3, 0)
          end
     end
     GST.frames[frameID]:SetScale(GST.sv.frame_scale)
end

function GST.UpdateFrame()
	if not GST.isMovable then
		GST.IndexGroupMembers()
		if not GST.testingTimers then GST.IndexTrackedPlayers() end

	     if (GetGroupSize() > 0 and #GST.trackedUsers > 0) or GST.testingTimers then
	          if #GST.frames > #GST.trackedUsers then
	               for i = #GST.trackedUsers + 1, #GST.frames do
	                    GST.frames[i]:SetDimensions(0, 0)
	                    GST.frames[i]:SetScale(0)
	               end
	          end

	          local trackedSynergies = GST.GetTrackedSynergies()
	          local numRows = GST.GetNumRows()
	          for i = 1, #GST.trackedUsers do
	               if GST.frames[i] == nil then
	                    GST.CreateFrame("GSTPlayerFrame" .. i, i)
	               end

	               if GST.GetNumTrackedSynergies() == 1 then
	                    GST.frames[i]:SetDimensions(GST.width/2, (numRows * 18 + 28))
	                    GST.frames[i].playerName:SetDimensions((GST.width / 2) - 8, 20)
	               else
	                    GST.frames[i]:SetDimensions(GST.width, (numRows * 18 + 28))
	                    GST.frames[i].playerName:SetDimensions(GST.width - 8, 20)
	               end
	               local playerName = GST.trackedUsers[i]
	               GST.frames[i].playerName:SetText(playerName)

	               local defaultIcon = 'esoui/art/campaign/campaignbrowser_guestcampaign.dds'
	               for key, value in pairs(GST.groupMembers) do
	                    if string.lower(value.displayName) == string.lower(playerName) then
	                         local playerClass = GetUnitClassId(value.groupID)

						local role = GetGroupMemberAssignedRole(value.groupID)
						if GST.sv.alternateFrameColors then
							if role == LFG_ROLE_TANK then
								local r, g, b = unpack(GST.sv.tankColor)
								GST.frames[i].BG:SetCenterColor(r, g, b, 0.5)
								GST.frames[i].BG:SetEdgeColor(r, g, b, 0.67)
								defaultIcon = 'esoui/art/lfg/lfg_icon_tank.dds'
							elseif role == LFG_ROLE_HEAL then
								local r, g, b = unpack(GST.sv.healerColor)
								GST.frames[i].BG:SetCenterColor(r, g, b, 0.5)
								GST.frames[i].BG:SetEdgeColor(r, g, b, 0.67)
								defaultIcon = 'esoui/art/lfg/lfg_icon_healer.dds'
							elseif role == LFG_ROLE_DPS then
								local r, g, b = unpack(GST.sv.dpsColor)
								GST.frames[i].BG:SetCenterColor(r, g, b, 0.5)
								GST.frames[i].BG:SetEdgeColor(r, g, b, 0.67)
								defaultIcon = 'esoui/art/lfg/lfg_icon_dps.dds'
							else
								GST.frames[i].BG:SetCenterColor(0, 0, 0, 0.5)
								GST.frames[i].BG:SetEdgeColor(0, 0, 0, 0.67)
								defaultIcon = classIcons[playerClass]
							end
						else
							GST.frames[i].BG:SetCenterColor(0, 0, 0, 0.5)
							GST.frames[i].BG:SetEdgeColor(0, 0, 0, 0.67)
							defaultIcon = classIcons[playerClass]
						end
	                    end
	               end

	               if HodorReflexes and GST.sv.useHodorReflexes then
	                    local userIcon = HodorReflexes.player.GetIconForUserId(playerName)
					local playerAlias = "@default"
	                    GST.frames[i].icon:SetTexture(userIcon and userIcon or defaultIcon)
					if HodorReflexes.modules then
						if HodorReflexes.modules.share then
							if HodorReflexes.modules.share.sv then
								if HodorReflexes.modules.share.sv.enableColoredNames then
				                    	playerAlias = HodorReflexes.player.GetAliasForUserId(playerName, true)
								else
									playerAlias = HodorReflexes.player.GetAliasForUserId(playerName, false)
								end
				                    GST.frames[i].playerName:SetText(playerAlias)
							end
						end
					end
	               else
	                    GST.frames[i].icon:SetTexture(defaultIcon)
	               end

	               local row = 1
	               for j = 1, (GST.max_synergies) do
	                    if trackedSynergies[j] then
		               	if j % 2 ~= 0 then
		                    	GST.frames[i].rows[row].synergyName1:SetText(trackedSynergies[j] .. ":")
		                         GST.frames[i].rows[row].synergyTime1:SetText("0.0")
							GST.frames[i].rows[row].synergyTime1:SetColor(1, 1, 1)
							GST.frames[i].rows[row].BG1:SetHidden(true)
		                    elseif j % 2 == 0 then
		                         GST.frames[i].rows[row].synergyName2:SetText(trackedSynergies[j] .. ":")
		                         GST.frames[i].rows[row].synergyTime2:SetText("0.0")
							GST.frames[i].rows[row].synergyTime2:SetColor(1, 1, 1)
							GST.frames[i].rows[row].BG2:SetHidden(true)
		                         row = row + 1
						end
	                    else
						if j % 2 ~= 0 then
	                              GST.frames[i].rows[row].synergyName1:SetText("")
	                              GST.frames[i].rows[row].synergyTime1:SetText("")
	                         elseif j % 2 == 0 then
	                              GST.frames[i].rows[row].synergyName2:SetText("")
	                              GST.frames[i].rows[row].synergyTime2:SetText("")
	                              row = row + 1
	                         end
					end
	               end
	               GST.frames[i]:SetHidden(false)
	               GST.frames[i]:SetScale(GST.sv.frame_scale)
	          end
	     else
	          for i = 1, #GST.frames do
	               GST.frames[i]:SetHidden(true)
	               GST.frames[i]:SetScale(0)
	          end
	     end
	end
end
