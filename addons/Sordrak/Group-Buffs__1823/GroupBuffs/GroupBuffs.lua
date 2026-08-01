-- GroupBuffs - Main
-- By @s0rdrak, @Graham82 (PC / EU)

GroupBuffs = {}
GroupBuffs.addonName = "GroupBuffs"
GroupBuffs.version = 1
GroupBuffs.versionString = "1.5.22"
GroupBuffs.updateInterval = 100 -- in ms
GroupBuffs.author = "@s0rdrak, @Graham82 (PC / EU)"
GroupBuffs.credits = "@Neltje, @Marcohf"
GroupBuffs.slashCmd = "/gb"

GroupBuffs.menu = {}
GroupBuffs.menu.name = "GroupBuffsMenu"

GroupBuffs.data = {}
GroupBuffs.sound = {}

GroupBuffs.config = {}
GroupBuffs.config.constants = {}
GroupBuffs.config.constants.TLW_TEMP = "GroupBuffsTemp_TLW"
GroupBuffs.config.constants.TLW_PREFIX = "GroupBuffs_TLW_%d_%d_%d"
GroupBuffs.config.constants.HEADER_LABEL_PREFIX = "GroupBuffs_HeaderLabel_%d_%d_%d_%d"
GroupBuffs.config.constants.COMPONENT_BASELINE = "GroupBuffs_%d_%d_%d_%s_%d_%d"
GroupBuffs.config.constants.COMPONENT_BD = "BD"
GroupBuffs.config.constants.COMPONENT_SB = "SB"
GroupBuffs.config.constants.COMPONENT_LABEL = "Label"
GroupBuffs.config.constants.COMPONENT_STACK_COUNT = "StackCount"
GroupBuffs.config.constants.COMPONENT_STRING_PLACEHOLDER = "%s"
GroupBuffs.config.constants.SORT_BY_NONE = 0
GroupBuffs.config.constants.SORT_BY_TIMER_DESC = 1
GroupBuffs.config.constants.SORT_BY_TIMER_ASC = 2
GroupBuffs.config.constants.SORT_BY_NAME_DESC = 3
GroupBuffs.config.constants.SORT_BY_NAME_ASC = 4
GroupBuffs.config.constants.SORT_BY_NAME_IN_POSITION_DESC = 5
GroupBuffs.config.constants.SORT_BY_NAME_IN_POSITION_ASC = 6
GroupBuffs.config.constants.nameMode = {}
GroupBuffs.config.constants.nameMode.CHAR = 1
GroupBuffs.config.constants.nameMode.DISPLAY = 2
GroupBuffs.config.constants.roleMode = {}
GroupBuffs.config.constants.roleMode.ALL = 1
GroupBuffs.config.constants.roleMode.TANK = 2
GroupBuffs.config.constants.roleMode.HEALER = 3
GroupBuffs.config.constants.roleMode.DD = 4

GroupBuffs.config.fonts = {}
GroupBuffs.config.fonts.headerFont = "ZoFontGameLarge"
GroupBuffs.config.fonts.buffFont = "ZoFontGameSmall"

GroupBuffs.config.centerColorUp = {}
GroupBuffs.config.centerColorUp.R = 0
GroupBuffs.config.centerColorUp.G = 0
GroupBuffs.config.centerColorUp.B = 0
GroupBuffs.config.centerColorUp.alpha = 0.5

GroupBuffs.config.centerColorDown = {}
GroupBuffs.config.centerColorDown.R = 0
GroupBuffs.config.centerColorDown.G = 0
GroupBuffs.config.centerColorDown.B = 0
GroupBuffs.config.centerColorDown.alpha = 0.0

GroupBuffs.config.defaultValues = {}
GroupBuffs.config.defaultValues.buffSpaceWidth = 15
GroupBuffs.config.defaultValues.buffSpaceHeight = 15
GroupBuffs.config.defaultValues.headerWidth = 100
GroupBuffs.config.defaultValues.headerHeight = 42
GroupBuffs.config.defaultValues.headerSpacingTop = -3
GroupBuffs.config.defaultValues.headerSpacingLeft = 3
GroupBuffs.config.defaultValues.firstLabelOffset = 10
GroupBuffs.config.defaultValues.labelOffsetX = 5
GroupBuffs.config.defaultValues.labelOffsetY = -3
GroupBuffs.config.defaultValues.boxDimensionWidth = 100
GroupBuffs.config.defaultValues.boxDimensionHeight = 10
GroupBuffs.config.defaultValues.showStack = false
GroupBuffs.config.defaultValues.headerColor = {}
GroupBuffs.config.defaultValues.headerColor.R = 1
GroupBuffs.config.defaultValues.headerColor.G = 0.87
GroupBuffs.config.defaultValues.headerColor.B = 0.68
GroupBuffs.config.defaultValues.defaultColorLabel = {}
GroupBuffs.config.defaultValues.defaultColorLabel.R = 1
GroupBuffs.config.defaultValues.defaultColorLabel.G = 1
GroupBuffs.config.defaultValues.defaultColorLabel.B = 1
GroupBuffs.config.defaultValues.differentOffDeadColor = true
GroupBuffs.config.defaultValues.defaultDifferentOffDeadLabel = {}
GroupBuffs.config.defaultValues.defaultDifferentOffDeadLabel.R = 0
GroupBuffs.config.defaultValues.defaultDifferentOffDeadLabel.G = 0
GroupBuffs.config.defaultValues.defaultDifferentOffDeadLabel.B = 0


GroupBuffs.controls = {}
GroupBuffs.controls.frame = {}

GroupBuffs.addonState = {}
GroupBuffs.addonState.frame = {}
GroupBuffs.addonState.foreground = true


GroupBuffs.savedVars = nil
GroupBuffs.default = {}
GroupBuffs.default.frame = {}




--local tmp = ""

local wm = GetWindowManager()

function GroupBuffs.SaveFrameLocation()
	local frame = GroupBuffs.controls.frame
	if frame ~= null then
		for i = 1, #frame do
			if frame[i].TLW ~= nil then
				GroupBuffs.savedVars.frame[i].offset.x = frame[i].TLW:GetLeft()
				GroupBuffs.savedVars.frame[i].offset.y = frame[i].TLW:GetTop()
			end
		end
	end

	--d(savedVars.offsetX)
end

function GroupBuffs.VerifySavedVars()
	if GroupBuffs.savedVars ~= nil then
		if GroupBuffs.savedVars.active == nil then
			GroupBuffs.savedVars.active = true
		end
		GroupBuffs.ChangeAddonState(GroupBuffs.savedVars.active)
	end
end

function GroupBuffs.GetTLWWidth(frame) 
	local width = 100;
	
	if frame ~= nil then
		local buffs = frame.buffs
		if buffs ~= nil then
			width = 0
			for i = 1, #buffs do
				if i >= 2 then
					if frame.buffSpaceWidth ~= nil then
						width = width + frame.buffSpaceWidth
					else
						width = width + GroupBuffs.config.defaultValues.buffSpaceWidth
					end
				end
				if buffs[i].boxDimension.width ~= nil then
					width = width + buffs[i].boxDimension.width
				else
					width = width + GroupBuffs.config.defaultValues.boxDimensionWidth
				end
			end
		end
	end
	return width
end

function GroupBuffs.GetHeaderDistance(buffs, space, index)
	local width = 0
	if space == nil then
		space = GroupBuffs.config.defaultValues.buffSpaceWidth
	end
	width = GroupBuffs.config.defaultValues.headerSpacingLeft
	if buffs ~= nil and index ~= nil and #buffs >= index then
		for i = 1, (index - 1) do
			width = width + space + buffs[i].boxDimension.width
		end
	else
		for i = 1, (index - 1) do
			width = width + space + GroupBuffs.config.defaultValues.boxDimensionWidth
		end
	end
	return width
end

function GroupBuffs.CreateFrames(vars)
	if vars ~= nil and vars and vars.frame ~= nil then
		local frames = vars.frame
		if frames ~= nil then
			local tlwWidth = GroupBuffs.config.defaultValues.headerWidth
			
			for i = 1, #frames do
				GroupBuffs.AddNewFrameControl(i)

				if vars.frame[i].buffs ~= nil then
					
					local buffs = vars.frame[i].buffs
					
					for j = 1, #buffs do
						GroupBuffs.AddNewBuffControl(i, j)

					end
				end

			end
		end
	end
	
end

function GroupBuffs.FixSavedVars()
	if GroupBuffs.savedVars ~= nil and GroupBuffs.savedVars.frame ~= nil then
		local frames = GroupBuffs.savedVars.frame
		for i = 1, #frames do
			for j = 1, #frames[i].buffs do
				if frames[i].nameMode == nil then
					frames[i].nameMode =GroupBuffs.config.constants.nameMode.CHAR
				end
				if frames[i].roleMode == nil then
					frames[i].roleMode = GroupBuffs.config.constants.roleMode.ALL
				end
				local buff = frames[i].buffs[j]
				if buff ~= nil then
				
					if buff.showName == nil then
						buff.showName = true
					end
					if buff.showStack == nil then
						buff.showStack = GroupBuffs.config.defaultValues.showStack
					end
					
					if buff.differentOffDeadColor == nil then
						buff.differentOffDeadColor = GroupBuffs.config.defaultValues.differentOffDeadColor
					end
					
					if buff.differentOffDeadColorLabel == nil then
						buff.differentOffDeadColorLabel = {}
						buff.differentOffDeadColorLabel.R = GroupBuffs.config.defaultValues.defaultDifferentOffDeadLabel.R
						buff.differentOffDeadColorLabel.G = GroupBuffs.config.defaultValues.defaultDifferentOffDeadLabel.G
						buff.differentOffDeadColorLabel.B = GroupBuffs.config.defaultValues.defaultDifferentOffDeadLabel.B
					end
					
					if buff.id == nil then
						buff.id = {}
						buff.id[1] = -1
					end
					
					if buff.buffColors == nil then
						buff.buffColors = {}
						buff.buffColors[1] = {}
						buff.buffColors[1].R = 1
						buff.buffColors[1].G = 0
						buff.buffColors[1].B = 0
					end
					
					if buff.fontColors == nil then
						buff.fontColors = {}
						buff.fontColors[1] = {}
						buff.fontColors[1].R = GroupBuffs.config.defaultValues.defaultColorLabel.R
						buff.fontColors[1].G = GroupBuffs.config.defaultValues.defaultColorLabel.G
						buff.fontColors[1].B = GroupBuffs.config.defaultValues.defaultColorLabel.B
					end
					
					if buff.effects == nil or buff.effects.fadeIn == nil then
						buff.effects = {}
						buff.effects.fadeIn = {}
						buff.effects.fadeIn.timeSpan = 0
						buff.effects.fadeIn.color = {}
						buff.effects.fadeIn.color.R = 1
						buff.effects.fadeIn.color.G = 0
						buff.effects.fadeIn.color.B = 0
					end
					
					if buff.effects.fadeOut == nil or buff.effects.fadeOut == nil then
						buff.effects.fadeOut = {}
						buff.effects.fadeOut.timeSpan = 0
						buff.effects.fadeOut.color = {}
						buff.effects.fadeOut.color.R = 1
						buff.effects.fadeOut.color.G = 0
						buff.effects.fadeOut.color.B = 0
					end
					
					if buff.effects.audio == nil then
						buff.effects.audio = {}
						buff.effects.audio.enabled = false
						buff.effects.audio.interval = 5
						buff.effects.audio.selectedSound = nil
					end
					
					if buff.sortMethod == nil then
						buff.sortMethod = GroupBuffs.config.constants.SORT_BY_NONE
					end
					
					if buff.edgeColor == nil then
						buff.edgeColor = {}
						buff.edgeColor.R = 0
						buff.edgeColor.G = 0
						buff.edgeColor.B = 0
						buff.edgeColor.alpha = 0.0
					end
					
					if buff.labelColor == nil then				
						buff.labelColor = {}
						buff.labelColor.R = 1
						buff.labelColor.G = 1
						buff.labelColor.B = 1
						buff.labelColor.alpha = 0.5
					end
					
					if buff.boxDimension == nil then
						buff.boxDimension = {}
						buff.boxDimension.width = GroupBuffs.config.defaultValues.boxDimensionWidth
						buff.boxDimension.height = GroupBuffs.config.defaultValues.boxDimensionHeight
						buff.boxDimension.min = 0
						buff.boxDimension.max = 100
					end
					
					if buff.alwaysShowNames == nil then
						buff.alwaysShowNames = false
					end
				end
			end
		end
	end
end

function GroupBuffs.FixBugs()
	GroupBuffs.FixSavedVars()
end

function GroupBuffs.SetForegroundState(eventCode, layerIndex, activeLayerIndex)
	if activeLayerIndex > 2 then
		GroupBuffs.addonState.foreground = false
	else
		GroupBuffs.addonState.foreground = true
	end
	--d(activeLayerIndex)
	if GroupBuffs.savedVars ~= nil and GroupBuffs.savedVars.frame ~= nil then
		local frames = GroupBuffs.savedVars.frame
		local size = GetGroupSize()
		for i = 1, #frames do
			if frames[i].isEnabled == true and size > 1 then
				GroupBuffs.controls.frame[i].TLW:SetHidden(not GroupBuffs.addonState.foreground)
			end
		end	
	end
end

function GroupBuffs.GroupBuffsOnInitialize(event, addonName)

	if addonName == GroupBuffs.addonName then
		GroupBuffs.savedVars = ZO_SavedVars:New("GroupBuffsVars", GroupBuffs.version, nil, GroupBuffs.default)
		
		GroupBuffs.FixBugs()
		
		GroupBuffs.CreateFrames(GroupBuffs.savedVars)
		GroupBuffs.VerifySavedVars()
		
		GroupBuffs.data.Initialize()
		GroupBuffs.sound.Initialize()
		GroupBuffs.menu.Initialize(GroupBuffs.menu.name, GroupBuffs.savedVars)
		
		EVENT_MANAGER:UnregisterForEvent(GroupBuffs.addonName, EVENT_ADD_ON_LOADED)
		if GroupBuffs.savedVars.active == nil or GroupBuffs.savedVars.active == true then
			EVENT_MANAGER:RegisterForUpdate(GroupBuffs.addonName, GroupBuffs.updateInterval, GroupBuffs.GroupBuffsOnUpdate)
			EVENT_MANAGER:RegisterForEvent(GroupBuffs.addonName, EVENT_ACTION_LAYER_POPPED, GroupBuffs.SetForegroundState)
			EVENT_MANAGER:RegisterForEvent(GroupBuffs.addonName, EVENT_ACTION_LAYER_PUSHED, GroupBuffs.SetForegroundState)
		end
		
	end

end



function GroupBuffs.ClearAllLabels(frameIndex, buffIndex, startIndex, endIndex)
	for emptySlots = startIndex, endIndex do
		GroupBuffs.SetBuffBoxValues(frameIndex, buffIndex, emptySlots, 0, GroupBuffs.config.centerColorDown, "  ", nil, nil)
		--GroupBuffs.SetBuffBoxValues(string.format(GroupBuffs.config.constants.COMPONENT_BASELINE, frameIndex, buffIndex, emptySlots, GroupBuffs.config.constants.COMPONENT_STRING_PLACEHOLDER), 0, GroupBuffs.config.centerColorDown, "  ")
	end
end

function GroupBuffs.SetBuffBoxValues(frameId, buffId, slotId, buffTime, bgColor, boxText, color, fontColor, stackCount, showStackCount)
	if frameId ~= nil and buffId ~= nil then
		local bd = GroupBuffs.controls.frame[frameId].buffs[buffId].BD[slotId]
		local sb = GroupBuffs.controls.frame[frameId].buffs[buffId].SB[slotId]
		local label = GroupBuffs.controls.frame[frameId].buffs[buffId].label[slotId]
		local stackLabel = GroupBuffs.controls.frame[frameId].buffs[buffId].stackLabel[slotId]
		--d(color)
		if color ~= nil then
			sb:SetColor(color.R, color.G, color.B)
		end
		sb:SetValue(buffTime)
		bd:SetCenterColor(bgColor.R, bgColor.G, bgColor.B, bgColor.alpha)
		label:SetText(boxText)
		if fontColor == nil then
			label:SetColor(GroupBuffs.config.defaultValues.defaultColorLabel.R, GroupBuffs.config.defaultValues.defaultColorLabel.G, GroupBuffs.config.defaultValues.defaultColorLabel.B)
		else
			label:SetColor(fontColor.R, fontColor.G, fontColor.B)
		end
		if stackCount == nil or stackCount == 0 or showStackCount == nil or showStackCount == false then
			--d("nil / 0")
			stackLabel:SetText("")
		else
			--d(stackCount)
			stackLabel:SetText(stackCount)
			--stackLabel:SetText("")
		end
		if fontColor == nil then
			stackLabel:SetColor(GroupBuffs.config.defaultValues.defaultColorLabel.R, GroupBuffs.config.defaultValues.defaultColorLabel.G, GroupBuffs.config.defaultValues.defaultColorLabel.B)
		else
			stackLabel:SetColor(fontColor.R, fontColor.G, fontColor.B)
		end
	end
end

function GroupBuffs.GetGroupByBuff(buff, nameMode, roleMode)
	local groupSize = GetGroupSize()
	local currentTimeStamp = GetGameTimeMilliseconds() / 1000
	local ids = buff.id
	
	if groupSize > 0 then
		local players = {}
		local currentIndex = 1
		for playerID = 1, groupSize do
			local validRole = false
			local isDps, isHealer, isTank = GetGroupMemberRoles(GetGroupUnitTagByIndex(playerID))
			if roleMode == GroupBuffs.config.constants.roleMode.ALL then
				validRole = true
			elseif roleMode == GroupBuffs.config.constants.roleMode.TANK and isTank == true then
				validRole = true
			elseif roleMode == GroupBuffs.config.constants.roleMode.HEALER and isHealer == true then
				validRole = true
			elseif roleMode == GroupBuffs.config.constants.roleMode.DD and isDps == true then
				validRole = true
			end			
			if validRole == true then
				players[currentIndex] = {}
				local numBuffs = GetNumBuffs(GetGroupUnitTagByIndex(playerID))
				--d(GetUnitName(GetGroupUnitTagByIndex(playerID)))
				if nameMode == GroupBuffs.config.constants.nameMode.CHAR then
					players[currentIndex].name = GetUnitName(GetGroupUnitTagByIndex(playerID))
				else
					players[currentIndex].name = GetUnitDisplayName(GetGroupUnitTagByIndex(playerID))
				end
				players[currentIndex].buffTime = -1
				players[currentIndex].unitTag = GetGroupUnitTagByIndex(playerID)
				if ids ~= nil then
					--d("ids valid")
					local count = 0
					for id = 1, #ids do
						
						if id ~= nil and DoesAbilityExist(ids[id]) == true then
							--d(string.format("Ability exists: %d",id))
							local currentBuffName = GetAbilityName(ids[id])
							
							
							for playerBuff = 1, numBuffs do
								local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo(GetGroupUnitTagByIndex(playerID), playerBuff)
								local buffDuration = timeEnding - timeStarted
								local timeLeft = timeEnding - currentTimeStamp
								local buffTime = timeLeft / buffDuration * 100
								if timeStarted == timeEnding then
									buffTime = 100
									timeLeft = 9999999
								end
								--[[
								if buffName == "xxx" then
									d("-------")
									d(GetGroupUnitTagByIndex(playerID))
									d(timeStarted)
									d(timeEnding)
									d(currentTimeStamp)
									d(buffTime)
									d(timeLeft)
									
								end
								]]
								--d(abilityId)
								if currentBuffName~= nil and buffName ~= nil and currentBuffName == buffName then
									--d("found")
									--d("buff identified")
									count = count + 1
									players[currentIndex].stackCount = count
									--d({GetUnitBuffInfo(GetGroupUnitTagByIndex(playerID), playerBuff)})
									if players[currentIndex].duration == nil or players[currentIndex].duration <= timeLeft then

										players[currentIndex].buffTime = buffTime
										players[currentIndex].duration = timeLeft
										players[currentIndex].useColor = buff.buffColors[id]
										--d(players[playerID].useColor)
										if buff.fontColors ~= nil then
											players[currentIndex].fontColor = buff.fontColors[id]
											--d(players[playerID].fontColor)
										end
										if buff.effects ~= nil and (buff.effects.fadeIn ~= nil or buff.effects.fadeOut ~= nil) then
											--d(string.format("fade detected: %d - %d - %d - %d - %d", timeStarted, timeEnding, currentTimeStamp, buff.effects.fadeIn.timeSpan, buff.effects.fadeOut.timeSpan))
											--players[playerID].useColor = {}
											if buff.effects.fadeIn ~= nil and timeStarted + buff.effects.fadeIn.timeSpan >= currentTimeStamp and buff.effects.fadeIn.timeSpan ~= 0 then
												players[currentIndex].useColor = buff.effects.fadeIn.color
												fadingIdentified = true
											end
											if buff.effects.fadeOut ~= nil and timeEnding - buff.effects.fadeOut.timeSpan <= currentTimeStamp and buff.effects.fadeOut.timeSpan ~= 0 and timeStarted ~= timeEnding then
												players[currentIndex].useColor = buff.effects.fadeOut.color
												fadingIdentified = true
											end
											--d(players[playerID].useColor)
										end
									end
								end
							end
						end
					end
				end
				currentIndex = currentIndex + 1
			end
		end
		return players
	end
	
	return nil
end

function GroupBuffs.SortByBuffTimeDesc(players) 
	--d("function called")
	local itemCount = #players
	repeat
		local hasChanged = false
		itemCount=itemCount - 1
		for i = 1, itemCount do
			--d("sort loop")
			if players[i].name ~= nil and players[i + 1].name ~= nil then
				if players[i].buffTime < players[i + 1].buffTime then
					players[i].buffTime, players[i + 1].buffTime = players[i + 1].buffTime, players[i].buffTime
					players[i].name, players[i + 1].name = players[i + 1].name, players[i].name
					players[i].useColor, players[i + 1].useColor = players[i + 1].useColor, players[i].useColor
					players[i].fontColor, players[i + 1].fontColor = players[i + 1].fontColor, players[i].fontColor
					players[i].stackCount, players[i + 1].stackCount = players[i + 1].stackCount, players[i].stackCount
					players[i].unitTag, players[i + 1].unitTag = players[i + 1].unitTag, players[i].unitTag
					players[i].duration, players[i + 1].duration = players[i + 1].duration, players[i].duration
					hasChanged = true
				end
			end
		end
	until hasChanged == false
	return players
end

function GroupBuffs.SortByBuffTimeAsc(players) 
	--d("function called")
	local itemCount = #players
	repeat
		local hasChanged = false
		itemCount=itemCount - 1
		for i = 1, itemCount do
			--d("sort loop")
			if players[i].name ~= nil and players[i + 1].name ~= nil then
				if (players[i].buffTime > players[i + 1].buffTime or players[i].buffTime == -1) and players[i + 1].buffTime ~= -1 then
					--d(string.format("change detected - i:%d, i+1: %d", players[i].buffTime, players[i+1].buffTime))
					players[i].buffTime, players[i + 1].buffTime = players[i + 1].buffTime, players[i].buffTime
					players[i].name, players[i + 1].name = players[i + 1].name, players[i].name
					players[i].useColor, players[i + 1].useColor = players[i + 1].useColor, players[i].useColor
					players[i].fontColor, players[i + 1].fontColor = players[i + 1].fontColor, players[i].fontColor
					players[i].stackCount, players[i + 1].stackCount = players[i + 1].stackCount, players[i].stackCount
					players[i].unitTag, players[i + 1].unitTag = players[i + 1].unitTag, players[i].unitTag
					players[i].duration, players[i + 1].duration = players[i + 1].duration, players[i].duration
					hasChanged = true
				end
			end
		end
	until hasChanged == false
	return players
end

function GroupBuffs.SortByNameDesc(players) 
	--d("function called")
	local itemCount = #players
	repeat
		local hasChanged = false
		itemCount=itemCount - 1
		for i = 1, itemCount do
			--d("sort loop")
			if players[i].name ~= nil and players[i + 1].name ~= nil then
				if (players[i].name < players[i + 1].name or players[i].buffTime == -1) and players[i + 1].buffTime ~= -1 then
					players[i].buffTime, players[i + 1].buffTime = players[i + 1].buffTime, players[i].buffTime
					players[i].name, players[i + 1].name = players[i + 1].name, players[i].name
					players[i].useColor, players[i + 1].useColor = players[i + 1].useColor, players[i].useColor
					players[i].fontColor, players[i + 1].fontColor = players[i + 1].fontColor, players[i].fontColor
					players[i].stackCount, players[i + 1].stackCount = players[i + 1].stackCount, players[i].stackCount
					players[i].unitTag, players[i + 1].unitTag = players[i + 1].unitTag, players[i].unitTag
					players[i].duration, players[i + 1].duration = players[i + 1].duration, players[i].duration
					hasChanged = true
				end
			end
		end
	until hasChanged == false
	return players
end

function GroupBuffs.SortByNameAsc(players) 
	--d("function called")
	local itemCount = #players
	repeat
		local hasChanged = false
		itemCount=itemCount - 1
		for i = 1, itemCount do
			--d("sort loop")
			if players[i].name ~= nil and players[i + 1].name ~= nil then
				if (players[i].name > players[i + 1].name or players[i].buffTime == -1) and players[i + 1].buffTime ~= -1 then
					--d(string.format("change detected - i:%d, i+1: %d", players[i].buffTime, players[i+1].buffTime))
					players[i].buffTime, players[i + 1].buffTime = players[i + 1].buffTime, players[i].buffTime
					players[i].name, players[i + 1].name = players[i + 1].name, players[i].name
					players[i].useColor, players[i + 1].useColor = players[i + 1].useColor, players[i].useColor
					players[i].fontColor, players[i + 1].fontColor = players[i + 1].fontColor, players[i].fontColor
					players[i].stackCount, players[i + 1].stackCount = players[i + 1].stackCount, players[i].stackCount
					players[i].unitTag, players[i + 1].unitTag = players[i + 1].unitTag, players[i].unitTag
					players[i].duration, players[i + 1].duration = players[i + 1].duration, players[i].duration
					hasChanged = true
				end
			end
		end
	until hasChanged == false
	return players
end

function GroupBuffs.SortByNameInPositionDesc(players) 
	--d("function called")
	local itemCount = #players
	repeat
		local hasChanged = false
		itemCount=itemCount - 1
		for i = 1, itemCount do
			--d("sort loop")
			if players[i].name ~= nil and players[i + 1].name ~= nil and players[i].name < players[i + 1].name then
				players[i].buffTime, players[i + 1].buffTime = players[i + 1].buffTime, players[i].buffTime
				players[i].name, players[i + 1].name = players[i + 1].name, players[i].name
				players[i].useColor, players[i + 1].useColor = players[i + 1].useColor, players[i].useColor
				players[i].fontColor, players[i + 1].fontColor = players[i + 1].fontColor, players[i].fontColor
				players[i].stackCount, players[i + 1].stackCount = players[i + 1].stackCount, players[i].stackCount
				players[i].unitTag, players[i + 1].unitTag = players[i + 1].unitTag, players[i].unitTag
				players[i].duration, players[i + 1].duration = players[i + 1].duration, players[i].duration
				hasChanged = true
			end
		end
	until hasChanged == false
	return players
end

function GroupBuffs.SortByNameInPositionAsc(players) 
	--d("function called")
	local itemCount = #players
	repeat
		local hasChanged = false
		itemCount=itemCount - 1
		for i = 1, itemCount do
			--d("sort loop")
			if players[i].name ~= nil and players[i + 1].name ~= nil and players[i].name > players[i + 1].name then
				--d(string.format("change detected - i:%d, i+1: %d", players[i].buffTime, players[i+1].buffTime))
				players[i].buffTime, players[i + 1].buffTime = players[i + 1].buffTime, players[i].buffTime
				players[i].name, players[i + 1].name = players[i + 1].name, players[i].name
				players[i].useColor, players[i + 1].useColor = players[i + 1].useColor, players[i].useColor
				players[i].fontColor, players[i + 1].fontColor = players[i + 1].fontColor, players[i].fontColor
				players[i].stackCount, players[i + 1].stackCount = players[i + 1].stackCount, players[i].stackCount
				players[i].unitTag, players[i + 1].unitTag = players[i + 1].unitTag, players[i].unitTag
				players[i].duration, players[i + 1].duration = players[i + 1].duration, players[i].duration
				hasChanged = true
			end
		end
	until hasChanged == false
	return players
end


function GroupBuffs.GetGroupSortedByBuff(buff, sortMethod, nameMode, roleMode)
	--d("getgroupsortedbybuff called")
	local groupSize = GetGroupSize()
	if groupSize > 0 then
		local players = GroupBuffs.GetGroupByBuff(buff, nameMode, roleMode)
		--d(Players)
		if players ~= nil then
			--d("calling fn")
			if sortMethod == GroupBuffs.config.constants.SORT_BY_TIMER_DESC then
				players = GroupBuffs.SortByBuffTimeDesc(players)
			elseif sortMethod == GroupBuffs.config.constants.SORT_BY_TIMER_ASC then
				players = GroupBuffs.SortByBuffTimeAsc(players)
			elseif sortMethod == GroupBuffs.config.constants.SORT_BY_NAME_DESC then
				players = GroupBuffs.SortByNameDesc(players)
			elseif sortMethod == GroupBuffs.config.constants.SORT_BY_NAME_ASC then
				players = GroupBuffs.SortByNameAsc(players)
			elseif sortMethod == GroupBuffs.config.constants.SORT_BY_NAME_IN_POSITION_DESC then
				players = GroupBuffs.SortByNameInPositionDesc(players)
			elseif sortMethod == GroupBuffs.config.constants.SORT_BY_NAME_IN_POSITION_ASC then
				players = GroupBuffs.SortByNameInPositionAsc(players)
			end
		end 
		return players
	end
	return nil
end

function GroupBuffs.SetHidden(index, state)
	if GroupBuffs.controls.frame[index] ~= nil then
		local tlw = GroupBuffs.controls.frame[index].TLW
		if tlw ~= nil then
			tlw:SetHidden(state)
		end
	end
end

function GroupBuffs.CheckAndPlaySound(frameId, buffId)
	if GroupBuffs.savedVars.frame[frameId] ~= nil and GroupBuffs.savedVars.frame[frameId].buffs ~= nil and GroupBuffs.savedVars.frame[frameId].buffs[buffId] ~= nil and GroupBuffs.savedVars.frame[frameId].buffs[buffId].effects ~= nil and GroupBuffs.savedVars.frame[frameId].buffs[buffId].effects.audio ~= nil then
		local interval = GroupBuffs.savedVars.frame[frameId].buffs[buffId].effects.audio.interval
		local soundKey = GroupBuffs.savedVars.frame[frameId].buffs[buffId].effects.audio.selectedSound
		if interval ~= nil and soundKey ~= nil then
			local currentGameTime = GetGameTimeMilliseconds()
			interval = interval * 1000
			if GroupBuffs.addonState.frame[frameId].buffs[buffId].audioLastPlayed == nil or currentGameTime > GroupBuffs.addonState.frame[frameId].buffs[buffId].audioLastPlayed + interval then
				--d("--------------------------")
				--d(interval)
				--d(currentGameTime)
				--d(GroupBuffs.addonState.frame[frameId].buffs[buffId].audioLastPlayed)
				GroupBuffs.addonState.frame[frameId].buffs[buffId].audioLastPlayed = currentGameTime
				GroupBuffs.PlaySound(soundKey)
			end
		end
	end
end

function GroupBuffs.GroupBuffsOnUpdate()
	if GroupBuffs.savedVars.frame ~= nil then
		if GroupBuffs.savedVars.active == true then
			if GroupBuffs.addonState.foreground == true then
				local groupSize = GetGroupSize()
				local frame = GroupBuffs.savedVars.frame
				for i = 1, #frame do
					if groupSize ~= 0 then
						local isInPvp = IsPlayerInAvAWorld()
						if ((frame[i].visibleInPvp == true and isInPvp == true) or (frame[i].visibleInPve == true and isInPvp == false)) and frame[i].isEnabled == true then
							GroupBuffs.SetHidden(i, false)
							if frame[i].buffs ~= nil then
								local buffs = frame[i].buffs
								for j = 1, #buffs do
									local soundPlayed = false
									local players = GroupBuffs.GetGroupSortedByBuff(buffs[j], buffs[j].sortMethod, frame[i].nameMode, frame[i].roleMode)
									--d(players)
									if players ~= nil then
										GroupBuffs.addonState.frame[i].buffs[j].showControl = true
										for playerID = 1, #players do
											local color = nil
											local fontColor = nil
											if players[playerID].useColor ~= nil then
												color = players[playerID].useColor
											end
											if buffs[j].differentOffDeadColor == true and (IsUnitOnline(players[playerID].unitTag) == false or IsUnitDead(players[playerID].unitTag)) then
												fontColor = buffs[j].differentOffDeadColorLabel
											else
												if players[playerID].fontColor ~= nil then
													fontColor = players[playerID].fontColor
													--d(fontColor)
												end
											end
											if players[playerID].buffTime >= 0 then
												

												
												--d(fontColor)
												--if players[playerID].buffTime > 0 then
												--d(players[playerID].buffTime)
												--end
												--d(color)
												GroupBuffs.SetBuffBoxValues(i, j, playerID, players[playerID].buffTime, GroupBuffs.config.centerColorUp, players[playerID].name, color, fontColor, players[playerID].stackCount, buffs[j].showStack)
												if soundPlayed == false and buffs[j].effects ~= nil and buffs[j].effects.audio ~= nil and buffs[j].effects.audio.enabled == true then
													soundPlayed = true
													GroupBuffs.CheckAndPlaySound(i, j)
												end
												--GroupBuffs.SetBuffBoxValues(string.format(GroupBuffs.config.constants.COMPONENT_BASELINE, i, j, playerID, GroupBuffs.config.constants.COMPONENT_STRING_PLACEHOLDER), players[playerID].buffTime, GroupBuffs.config.centerColorUp, players[playerID].name, color)
											else
												
												
												if buffs[j].sortMethod ~= GroupBuffs.config.constants.SORT_BY_TIMER_ASC and buffs[j].sortMethod ~= GroupBuffs.config.constants.SORT_BY_TIMER_DESC and buffs[j].alwaysShowNames == true then
													GroupBuffs.SetBuffBoxValues(i, j, playerID, 0, GroupBuffs.config.centerColorDown, players[playerID].name, color, fontColor, players[playerID].stackCount, buffs[j].showStack)
												else
													GroupBuffs.SetBuffBoxValues(i, j, playerID, 0, GroupBuffs.config.centerColorDown, "  ", color, fontColor, players[playerID].stackCount, buffs[j].showStack)
												end
												--GroupBuffs.SetBuffBoxValues(string.format(GroupBuffs.config.constants.COMPONENT_BASELINE, i, j, playerID, GroupBuffs.config.constants.COMPONENT_STRING_PLACEHOLDER), 0, GroupBuffs.config.centerColorDown, "  ")
											end
										end
										GroupBuffs.ClearAllLabels(i, j, #players + 1,24)
									else
										if GroupBuffs.addonState.frame[i].buffs[j].showControl == true then
											GroupBuffs.ClearAllLabels(i, j, 1, 24)
											GroupBuffs.addonState.frame[i].buffs[j].showControl = false
										end
									end
								end
							end
						else
							--d("wrong area")
							GroupBuffs.SetHidden(i, true)
						end
					else
						GroupBuffs.SetHidden(i, true)
					end
				end
			else
				--Not in Foreground
			end
		else
			--d("inactive")
		end
	end
end

EVENT_MANAGER:RegisterForEvent(GroupBuffs.addonName, EVENT_ADD_ON_LOADED, GroupBuffs.GroupBuffsOnInitialize)

--[[HELPER FUNCTIONS BUFFS / MENU / DATA]]
function GroupBuffs.TableContainsValue(tableData, entryName)
	if tableData ~= nil and entryName ~= nil then
		for i = 1, #tableData do
			if tableData[i] == entryName then
				return true
			end
		end
	end
	return false
end

function GroupBuffs.InitializeNewFrame(id, frameName)
	if GroupBuffs.savedVars ~= nil and GroupBuffs.savedVars.frame ~= nil then
		--d("Adding frame")
		GroupBuffs.savedVars.frame[id] = {}
		local frame = GroupBuffs.savedVars.frame[id]
		frame.name = frameName
		frame.isActive = true
		frame.visibleInPve = true;
		frame.visibleInPvp = true;
		frame.isEnabled = true;
		frame.isMovable = true;
		frame.offset = {}
		frame.offset.x = 1700
		frame.offset.y = 200
		frame.buffSpaceWidth = GroupBuffs.config.defaultValues.buffSpaceWidth
		frame.headerColor = {}
		frame.headerColor.R = 1
		frame.headerColor.G = 0.87
		frame.headerColor.B = 0.68
		frame.nameMode = GroupBuffs.config.constants.nameMode.CHAR
		frame.roleMode = GroupBuffs.config.constants.roleMode.ALL
		frame.buffs = {}
		GroupBuffs.AddNewFrameControl(id)
	end
end

function GroupBuffs.InitializeNewBuff(frameId, buffId, buffName)
	if GroupBuffs.savedVars ~= nil and GroupBuffs.savedVars.frame ~= nil and GroupBuffs.savedVars.frame[frameId] ~= nil then
		local frame = GroupBuffs.savedVars.frame[frameId]
		frame.buffs[buffId] = {}
		local buff = frame.buffs[buffId]
		
		buff.name = buffName
		buff.showName = true
		buff.showStack = GroupBuffs.config.defaultValues.showStack
		
		buff.differentOffDeadColor = GroupBuffs.config.defaultValues.differentOffDeadColor
		buff.differentOffDeadColorLabel = {}
		buff.differentOffDeadColorLabel.R = GroupBuffs.config.defaultValues.defaultDifferentOffDeadLabel.R
		buff.differentOffDeadColorLabel.G = GroupBuffs.config.defaultValues.defaultDifferentOffDeadLabel.G
		buff.differentOffDeadColorLabel.B = GroupBuffs.config.defaultValues.defaultDifferentOffDeadLabel.B
		
		buff.id = {}
		buff.id[1] = -1

		buff.buffColors = {}
		buff.buffColors[1] = {}
		buff.buffColors[1].R = 1
		buff.buffColors[1].G = 0
		buff.buffColors[1].B = 0
		
		buff.fontColors = {}
		buff.fontColors[1] = {}
		buff.fontColors[1].R = GroupBuffs.config.defaultValues.defaultColorLabel.R
		buff.fontColors[1].G = GroupBuffs.config.defaultValues.defaultColorLabel.G
		buff.fontColors[1].B = GroupBuffs.config.defaultValues.defaultColorLabel.B
		
		buff.effects = {}
		buff.effects.fadeIn = {}
		buff.effects.fadeIn.timeSpan = 0
		buff.effects.fadeIn.color = {}
		buff.effects.fadeIn.color.R = 1
		buff.effects.fadeIn.color.G = 0
		buff.effects.fadeIn.color.B = 0
		
		buff.effects.fadeOut = {}
		buff.effects.fadeOut.timeSpan = 0
		buff.effects.fadeOut.color = {}
		buff.effects.fadeOut.color.R = 1
		buff.effects.fadeOut.color.G = 0
		buff.effects.fadeOut.color.B = 0
		
		buff.effects.audio = {}
		buff.effects.audio.enabled = false
		buff.effects.audio.interval = 5
		buff.effects.audio.selectedSound = nil

		buff.sortMethod = GroupBuffs.config.constants.SORT_BY_NONE
		buff.edgeColor = {}
		buff.edgeColor.R = 0
		buff.edgeColor.G = 0
		buff.edgeColor.B = 0
		buff.edgeColor.alpha = 0.0
		buff.labelColor = {}
		buff.labelColor.R = 1
		buff.labelColor.G = 1
		buff.labelColor.B = 1
		buff.labelColor.alpha = 0.5
		buff.boxDimension = {}
		buff.boxDimension.width = GroupBuffs.config.defaultValues.boxDimensionWidth
		buff.boxDimension.height = GroupBuffs.config.defaultValues.boxDimensionHeight
		buff.boxDimension.min = 0
		buff.boxDimension.max = 100
		buff.alwaysShowNames = false
		
		GroupBuffs.AddNewBuffControl(frameId, buffId)
		GroupBuffs.UpdateBuffLayoutById(frameId) -- update frame movable area
		
		return true
	end
	return false
end


function GroupBuffs.GetFrameIdFromName(frameName)
	if frameName ~= nil and GroupBuffs.savedVars ~= nil and GroupBuffs.savedVars.frame ~= nil then
		local frames = GroupBuffs.savedVars.frame
		for i = 1, #frames do
			if frames[i] ~= nil and frames[i].name == frameName then
				return i
			end
		end
	end
	return -1
end

function GroupBuffs.GetAttributeFromFrameByFrameName(frameName, attribute)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id > 0 then
		return GroupBuffs.savedVars.frame[id][attribute]
	end
	return nil
end

function GroupBuffs.SetAttributeOfFrameByFrameName(frameName, attribute, value)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id > 0 then
		GroupBuffs.savedVars.frame[id][attribute] = value
	end
end

function GroupBuffs.UpdateControlIsMovable(frameName, value)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id > 0 then
		if GroupBuffs.controls.frame[id] ~= nil and GroupBuffs.controls.frame[id].TLW then
			GroupBuffs.controls.frame[id].TLW:SetMovable(value)
			GroupBuffs.controls.frame[id].TLW:SetMouseEnabled(value)
		end
	end
end

function GroupBuffs.UpdateControlHeaderColor(frameName, value)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id > 0 then
		if GroupBuffs.controls.frame[id] ~= nil and GroupBuffs.controls.frame[id].headerLabel ~= nil then
			local headerLabels = GroupBuffs.controls.frame[id].headerLabel
			for i = 1, #headerLabels do
				GroupBuffs.controls.frame[id].headerLabel[i]:SetColor(value.R, value.G, value.B)
			end
		end
	end
end

function GroupBuffs.AddNewFrameControl(id)
	local frames = GroupBuffs.savedVars.frame
	if frames ~= nil then
		local gameTime = GetGameTimeMilliseconds()
		math.randomseed(gameTime)
		local rand = math.random(1,1000000)
		GroupBuffs.addonState.frame[id] = {}
		GroupBuffs.addonState.frame[id].buffs = {}
		
		local tlwWidth = GroupBuffs.GetTLWWidth(frames[id])
		GroupBuffs.controls.frame[id] = {}
		GroupBuffs.controls.frame[id].TLW = wm:CreateTopLevelWindow(string.format(GroupBuffs.config.constants.TLW_PREFIX, id, rand, gameTime))
		GroupBuffs.controls.frame[id].TLW:SetDimensions(tlwWidth, GroupBuffs.config.defaultValues.headerHeight) --Greifbare Fläche
		GroupBuffs.controls.frame[id].TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, frames[id].offset.x, frames[id].offset.y)
		GroupBuffs.controls.frame[id].TLW:SetMovable(frames[id].isMovable)
		GroupBuffs.controls.frame[id].TLW:SetMouseEnabled(frames[id].isMovable)
		GroupBuffs.controls.frame[id].TLW:SetHandler("OnMoveStop", GroupBuffs.SaveFrameLocation)
		
		GroupBuffs.controls.frame[id].TLW:SetClampedToScreen(true)
		GroupBuffs.controls.frame[id].TLW:SetDrawLayer(0)
		GroupBuffs.controls.frame[id].TLW:SetDrawLevel(id)
		
		
		GroupBuffs.controls.frame[id].headerLabel = {}
		
		
		local isInPvp = IsPlayerInAvAWorld()
		if (frames[id].visibleInPvp == true and isInPvp == true) or (frames[id].visibleInPve == true and isInPvp == false) then
			GroupBuffs.SetHidden(id, false)
		else
			GroupBuffs.SetHidden(id, true)
		end
		if GetGroupSize() == nil then
			GroupBuffs.SetHidden(id, true)
		end
	end
end

function GroupBuffs.AddNewBuffControl(frameId, buffId)
	if frameId ~= nil and buffId ~= nil then
		local buffs = GroupBuffs.savedVars.frame[frameId].buffs
		local gameTime = GetGameTimeMilliseconds()
		math.randomseed(gameTime)
		local rand = math.random(1,1000000)
		GroupBuffs.addonState.frame[frameId].buffs[buffId] = {}
		GroupBuffs.addonState.frame[frameId].buffs[buffId].showControl = true;
				
		local spacingLeft = GroupBuffs.config.defaultValues.headerSpacingLeft + GroupBuffs.GetHeaderDistance(buffs, GroupBuffs.savedVars.frame[frameId].buffSpaceWidth, buffId)
		
		GroupBuffs.controls.frame[frameId].headerLabel[buffId] = wm:CreateControl(string.format(GroupBuffs.config.constants.HEADER_LABEL_PREFIX, frameId, buffId, rand, gameTime), GroupBuffs.controls.frame[frameId].TLW, CT_LABEL )
		GroupBuffs.controls.frame[frameId].headerLabel[buffId]:SetAnchor(TOPLEFT, GroupBuffs.controls.frame[frameId].TLW, TOPLEFT, spacingLeft, GroupBuffs.config.defaultValues.headerSpacingTop)
		GroupBuffs.controls.frame[frameId].headerLabel[buffId]:SetFont(GroupBuffs.config.fonts.headerFont)
		GroupBuffs.controls.frame[frameId].headerLabel[buffId]:SetWrapMode(ELLIPSIS)
		GroupBuffs.controls.frame[frameId].headerLabel[buffId]:SetColor(GroupBuffs.savedVars.frame[frameId].headerColor.R, GroupBuffs.savedVars.frame[frameId].headerColor.G, GroupBuffs.savedVars.frame[frameId].headerColor.B)
		GroupBuffs.controls.frame[frameId].headerLabel[buffId]:SetDimensions(buffs[buffId].boxDimension.width, GroupBuffs.config.defaultValues.headerHeight)
		
		GroupBuffs.controls.frame[frameId].headerLabel[buffId]:SetText(buffs[buffId].name)
		GroupBuffs.controls.frame[frameId].headerLabel[buffId]:SetHidden(not buffs[buffId].showName)
		
		if GroupBuffs.controls.frame[frameId].buffs == nil then
			GroupBuffs.controls.frame[frameId].buffs = {}
		end
		for i = 1, 24 do
			if GroupBuffs.controls.frame[frameId].buffs[buffId] == nil then
				GroupBuffs.controls.frame[frameId].buffs[buffId] = {}
				GroupBuffs.controls.frame[frameId].buffs[buffId].BD = {}
				GroupBuffs.controls.frame[frameId].buffs[buffId].SB = {}
				GroupBuffs.controls.frame[frameId].buffs[buffId].label = {}
				GroupBuffs.controls.frame[frameId].buffs[buffId].stackLabel = {}
			end
			local top = GroupBuffs.config.defaultValues.firstLabelOffset + (i * GroupBuffs.config.defaultValues.buffSpaceHeight)
			local buffBD = wm:CreateControl(string.format(GroupBuffs.config.constants.COMPONENT_BASELINE, frameId, buffId, i, GroupBuffs.config.constants.COMPONENT_BD, rand, gameTime), GroupBuffs.controls.frame[frameId].TLW, CT_BACKDROP)
			buffBD:SetAnchor(TOPLEFT, GroupBuffs.controls.frame[frameId].TLW, TOPLEFT, spacingLeft, top)
			buffBD:SetDimensions(buffs[buffId].boxDimension.width, buffs[buffId].boxDimension.height)
			buffBD:SetCenterColor(GroupBuffs.config.centerColorDown.R, GroupBuffs.config.centerColorDown.G, GroupBuffs.config.centerColorDown.B, GroupBuffs.config.centerColorDown.alpha)
			buffBD:SetEdgeColor(buffs[buffId].edgeColor.R, buffs[buffId].edgeColor.G, buffs[buffId].edgeColor.B, buffs[buffId].edgeColor.alpha)
			buffBD:SetAlpha(1) --Allenfalls boolean, damit Alpha verwendet wird
			
			GroupBuffs.controls.frame[frameId].buffs[buffId].BD[i] = buffBD
			
			local buffSB = wm:CreateControl(string.format(GroupBuffs.config.constants.COMPONENT_BASELINE, frameId, buffId, i, GroupBuffs.config.constants.COMPONENT_SB, rand, gameTime), GroupBuffs.controls.frame[frameId].TLW, CT_STATUSBAR )
			buffSB:SetAnchor(TOPLEFT, GroupBuffs.controls.frame[frameId].TLW, TOPLEFT, spacingLeft, top)
			buffSB:SetDimensions(buffs[buffId].boxDimension.width, buffs[buffId].boxDimension.height)
			buffSB:SetMinMax(buffs[buffId].boxDimension.min, buffs[buffId].boxDimension.max)
			if buffs[buffId].buffColors[1] ~= nil then
				buffSB:SetColor(buffs[buffId].buffColors[1].R, buffs[buffId].buffColors[1].G, buffs[buffId].buffColors[1].B)
			end
			buffSB:SetValue(0)
			
			GroupBuffs.controls.frame[frameId].buffs[buffId].SB[i] = buffSB
			
			local buffLabel = wm:CreateControl(string.format(GroupBuffs.config.constants.COMPONENT_BASELINE, frameId, buffId, i, GroupBuffs.config.constants.COMPONENT_LABEL, rand, gameTime), GroupBuffs.controls.frame[frameId].TLW, CT_LABEL )
			buffLabel:SetAnchor(TOPLEFT, GroupBuffs.controls.frame[frameId].TLW, TOPLEFT, spacingLeft + GroupBuffs.config.defaultValues.labelOffsetX, top + GroupBuffs.config.defaultValues.labelOffsetY)
			buffLabel:SetFont(GroupBuffs.config.fonts.buffFont)
			buffLabel:SetWrapMode(ELLIPSIS)
			buffLabel:SetDimensions(buffs[buffId].boxDimension.width - 20, buffs[buffId].boxDimension.height)
			buffLabel:SetColor(buffs[buffId].labelColor.R, buffs[buffId].labelColor.G, buffs[buffId].labelColor.B, buffs[buffId].labelColor.alpha)
			buffLabel:SetText("  ")
			
			GroupBuffs.controls.frame[frameId].buffs[buffId].label[i] = buffLabel
			
			local stackLabel = wm:CreateControl(string.format(GroupBuffs.config.constants.COMPONENT_BASELINE, frameId, buffId, i, GroupBuffs.config.constants.COMPONENT_STACK_COUNT, rand, gameTime), GroupBuffs.controls.frame[frameId].TLW, CT_LABEL )
			stackLabel:SetAnchor(TOPLEFT, GroupBuffs.controls.frame[frameId].TLW, TOPLEFT, spacingLeft + GroupBuffs.config.defaultValues.labelOffsetX + buffs[buffId].boxDimension.width - 20, top + GroupBuffs.config.defaultValues.labelOffsetY)
			stackLabel:SetFont(GroupBuffs.config.fonts.buffFont)
			stackLabel:SetWrapMode(ELLIPSIS)
			stackLabel:SetDimensions(20, buffs[buffId].boxDimension.height)
			stackLabel:SetColor(buffs[buffId].labelColor.R, buffs[buffId].labelColor.G, buffs[buffId].labelColor.B, buffs[buffId].labelColor.alpha)
			stackLabel:SetText("  ")
			
			GroupBuffs.controls.frame[frameId].buffs[buffId].stackLabel[i] = stackLabel
		end
	end
end


function GroupBuffs.UpdateBuffLayoutById(id)
	if id ~= nil and id > 0 then
		local frame = GroupBuffs.savedVars.frame[id]
		local frameControl = GroupBuffs.controls.frame[id]
		if frame ~= nil and frameControl ~= nil then
			local tlwWidth = GroupBuffs.GetTLWWidth(frame)
			frameControl.TLW:SetDimensions(tlwWidth, GroupBuffs.config.defaultValues.headerHeight) --Greifbare Fläche
			
			local buffs = frame.buffs
			if buffs ~= nil then
				for i = 1, #buffs do
					--d(i)
					--d(buffs[i].name)
					local spacingLeft = GroupBuffs.config.defaultValues.headerSpacingLeft + GroupBuffs.GetHeaderDistance(buffs, frame.buffSpaceWidth, i)
					--d(spacingLeft)
					frameControl.headerLabel[i]:SetAnchor(TOPLEFT, frameControl.TLW, TOPLEFT, spacingLeft, GroupBuffs.config.defaultValues.headerSpacingTop)
					frameControl.headerLabel[i]:SetDimensions(buffs[i].boxDimension.width, GroupBuffs.config.defaultValues.headerHeight)
					local buffControl = frameControl.buffs[i]
					for j = 1, 24 do
						local top = GroupBuffs.config.defaultValues.firstLabelOffset + (j * GroupBuffs.config.defaultValues.buffSpaceHeight)
						
						
						if buffControl ~= nil then
							--d(buffControl.SB)
							buffControl.SB[j]:ClearAnchors()
							buffControl.SB[j]:SetAnchor(TOPLEFT, frameControl.TLW, TOPLEFT, spacingLeft, top)
							buffControl.SB[j]:SetDimensions(buffs[i].boxDimension.width, buffs[i].boxDimension.height)
							if buffs[i].buffColors[1] ~= nil then
								buffControl.SB[j]:SetColor(buffs[i].buffColors[1].R, buffs[i].buffColors[1].G, buffs[i].buffColors[1].B)
							end
							
							buffControl.BD[j]:ClearAnchors()
							buffControl.BD[j]:SetAnchor(TOPLEFT, frameControl.TLW, TOPLEFT, spacingLeft, top)
							buffControl.BD[j]:SetDimensions(buffs[i].boxDimension.width, buffs[i].boxDimension.height)
							
							buffControl.label[j]:ClearAnchors()
							buffControl.label[j]:SetAnchor(TOPLEFT, frameControl.TLW, TOPLEFT, spacingLeft + GroupBuffs.config.defaultValues.labelOffsetX, top + GroupBuffs.config.defaultValues.labelOffsetY)
							buffControl.label[j]:SetDimensions(buffs[i].boxDimension.width - 20, buffs[i].boxDimension.height)
							buffControl.label[j]:SetColor(buffs[i].labelColor.R, buffs[i].labelColor.G, buffs[i].labelColor.B, buffs[i].labelColor.alpha)
							
							buffControl.stackLabel[j]:ClearAnchors()
							buffControl.stackLabel[j]:SetAnchor(TOPLEFT, frameControl.TLW, TOPLEFT, spacingLeft + GroupBuffs.config.defaultValues.labelOffsetX + buffs[i].boxDimension.width - 20, top + GroupBuffs.config.defaultValues.labelOffsetY)
							buffControl.stackLabel[j]:SetDimensions(20, buffs[i].boxDimension.height)
							buffControl.stackLabel[j]:SetColor(buffs[i].labelColor.R, buffs[i].labelColor.G, buffs[i].labelColor.B, buffs[i].labelColor.alpha)
						else
							--d("nil detected")
							--d(frameName)
							--d(id)
							--d(i)
							--d(j)
						end
					end
				end
			end
		end
	end
end

function GroupBuffs.UpdateBuffLayoutByFrameName(frameName)
	GroupBuffs.UpdateBuffLayoutById(GroupBuffs.GetFrameIdFromName(frameName))
end

function GroupBuffs.HideBuffControls(id, buffId)
	--d(string.format("HideBuffControls: %d, %d",id, buffId))
	if id ~= nil and id > 0 and buffId ~= nil and buffId > 0 then
		local frame = GroupBuffs.controls.frame[id]
		if frame.headerLabel ~= nil and frame.headerLabel[buffId] ~= nil then
			frame.headerLabel[buffId]:SetHidden(true)
		end
		
		if frame.buffs ~= nil and frame.buffs[buffId] ~= nil then
			local buffs = frame.buffs[buffId]
			for i = 1, 24 do
				buffs.SB[i]:SetHidden(true)
				buffs.BD[i]:SetHidden(true)
				buffs.label[i]:SetHidden(true)
				buffs.stackLabel[i]:SetHidden(true)
			end
		end
	end
end

function GroupBuffs.HideFrameControls(id)
	if id ~= nil and id > 0 then
		local buffs = GroupBuffs.controls.frame[id].TLW:SetHidden(true)
	end
end

function GroupBuffs.GetBuffEffectNames()
	local buffNames = {}
	local effects = GroupBuffs.data.effects
	if effects ~= nil and #effects > 0 then
		for i = 1, #effects do
			buffNames[i] = effects[i].name
		end
	end
	return buffNames
end

function GroupBuffs.GetBuffEffectName(frameName, buffId, buffEffectId)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	local retVal = nil
	if id ~= nil and frameName ~= nil and buffId ~= nil and buffEffectId ~= nil and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].id ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].id[buffEffectId] ~= nil then
		local currentBuffId = GroupBuffs.savedVars.frame[id].buffs[buffId].id[buffEffectId]
		local effects = GroupBuffs.data.effects
		
		if effects ~= nil and #effects > 0 then
			for i = 1, #effects do
				local ids = effects[i].ids
				if ids ~= nil then
					local entryFound = false
					for j = 1, #ids do
						if ids[j] == currentBuffId then
							retVal = effects[i].name
							entryFound = true
							break
						end
					end
					if entryFound == true then
						break
					end
				end
			end
		end
	end
	--d(retVal)
	return retVal
end

function GroupBuffs.SetBuffEffectName(frameName, buffId, buffEffectId, value)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and frameName ~= nil and buffId ~= nil and buffEffectId ~= nil and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].id ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].id[buffEffectId] ~= nil then
		local newEffectId = 0
		local effects = GroupBuffs.data.effects
		if effects ~= nil and #effects > 0 then
			for i = 1, #effects do
				if effects[i].name == value then
					local ids = effects[i].ids
					if ids ~= nil then
						local entryFound = false
						for j = 1, #ids do
							if DoesAbilityExist(ids[j]) then
								newEffectId = ids[j]
								entryFound = true
								break
							end
						end
						if entryFound == true then
							break
						end
					end
				end
			
			end
		end
		GroupBuffs.savedVars.frame[id].buffs[buffId].id[buffEffectId] = newEffectId
	end
end

function GroupBuffs.GetAbilityIdFromName(value)

end

function GroupBuffs.AddNewBuffEffect(frameName, buffId)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and buffId ~= nil and buffId > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil then
		local buffs = GroupBuffs.savedVars.frame[id].buffs[buffId]
		local ids = buffs.id
		local colors = buffs.buffColors
		local colorIndex = #colors
		ids[#ids + 1] = -1
		colors[colorIndex + 1] = {}
		colors[colorIndex + 1].R = 1
		colors[colorIndex + 1].G = 0
		colors[colorIndex + 1].B = 0
	end
end

function GroupBuffs.GetBuffEffectValue(frameName, buffId, effectName, valueName)
	local retVal = nil
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and buffId ~= nil and buffId > 0 then
		if GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil then
			if GroupBuffs.savedVars.frame[id].buffs[buffId].effects ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].effects[effectName] ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].effects[effectName][valueName] ~= nil then
				retVal = GroupBuffs.savedVars.frame[id].buffs[buffId].effects[effectName][valueName]
			end
		end
	end
	return retVal
end

function GroupBuffs.SetBuffEffectValue(frameName, buffId, effectName, valueName, value)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and buffId ~= nil and buffId > 0 then
		if GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil then
			if GroupBuffs.savedVars.frame[id].buffs[buffId].effects == nil then
				GroupBuffs.savedVars.frame[id].buffs[buffId].effects = {}
			end
			if GroupBuffs.savedVars.frame[id].buffs[buffId].effects[effectName] == nil then
				GroupBuffs.savedVars.frame[id].buffs[buffId].effects[effectName] = {}
			end
			GroupBuffs.savedVars.frame[id].buffs[buffId].effects[effectName][valueName] = value
		end
	end
end

function GroupBuffs.GetAudioEffectNames()
	local soundNames = GroupBuffs.sound.soundNames
	return soundNames
end

function GroupBuffs.GetAudioEffectValues()
	local soundKeys = GroupBuffs.sound.soundKeys
	return soundKeys
end

function GroupBuffs.PlaySound(key)
	GroupBuffs.sound.PlaySound(key)
end

--[[MENU FUNCTIONS]]
function GroupBuffs.ChangeAddonState(value)
	GroupBuffs.savedVars.active = value
	local frame = GroupBuffs.savedVars.frame
	if frame ~= nil then
		for i = 1, #frame do
			if value == true then
				local isInPvp = IsPlayerInAvAWorld()
				if (frame[i].visibleInPvp == true and isInPvp == true) or (frame[i].visibleInPve == true and isInPvp == false) then
					GroupBuffs.SetHidden(i, false)
				end
			else
				GroupBuffs.SetHidden(i, true)
			end
		end
	end
	if value == true then
		EVENT_MANAGER:RegisterForUpdate(GroupBuffs.addonName, GroupBuffs.updateInterval, GroupBuffs.GroupBuffsOnUpdate)
		EVENT_MANAGER:RegisterForEvent(GroupBuffs.addonName, EVENT_ACTION_LAYER_POPPED, GroupBuffs.SetForegroundState)
		EVENT_MANAGER:RegisterForEvent(GroupBuffs.addonName, EVENT_ACTION_LAYER_PUSHED, GroupBuffs.SetForegroundState)
	else
		EVENT_MANAGER:UnregisterForUpdate(GroupBuffs.addonName)
		EVENT_MANAGER:UnregisterForEvent(GroupBuffs.addonName, EVENT_ACTION_LAYER_POPPED)
		EVENT_MANAGER:UnregisterForEvent(GroupBuffs.addonName, EVENT_ACTION_LAYER_PUSHED)
	end
end

function GroupBuffs.GetAddonState()
	return GroupBuffs.savedVars.active
end

function GroupBuffs.GetFrameNames()
	local retVal = {}
	if GroupBuffs.savedVars ~= nil and GroupBuffs.savedVars.frame ~= nil then
		local frames = GroupBuffs.savedVars.frame
		for i = 1, #frames do
			--d(retVal[i])
			retVal[i] = frames[i].name
			
		end
	end
	return retVal
end

function GroupBuffs.isUniqueFrameName(frameName)
	if GroupBuffs.savedVars ~= nil and GroupBuffs.savedVars.frame ~= nil then
		local frames = GroupBuffs.savedVars.frame
		for i = 1, #frames do
			if frames[i].name ~= nil and frames[i].name == frameName then
				return false
			end
		end
	end
	return true
end

function GroupBuffs.AddNewFrame(frameName)
	if GroupBuffs.savedVars ~= nil then
		if GroupBuffs.savedVars.frame == nil then
			GroupBuffs.savedVars.frame = {}
		end
		local frames = GroupBuffs.savedVars.frame
		GroupBuffs.InitializeNewFrame(#frames + 1,frameName)
	end
end

function GroupBuffs.RemoveFrame(frameName)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 then
		local frames = GroupBuffs.savedVars.frame
		local controls = GroupBuffs.controls.frame
		local addonState = GroupBuffs.addonState.frame
		GroupBuffs.HideFrameControls(id)
		table.remove(frames, id)
		table.remove(controls, id)
		table.remove(addonState, id)
	end
end


function GroupBuffs.GetIsFrameEnabled(frameName)
	return GroupBuffs.GetAttributeFromFrameByFrameName(frameName, "isEnabled")
end

function GroupBuffs.GetIsFrameFixedLocation(frameName)
	return GroupBuffs.GetAttributeFromFrameByFrameName(frameName, "isMovable")
end

function GroupBuffs.GetIsFramePvpEnabled(frameName)
	return GroupBuffs.GetAttributeFromFrameByFrameName(frameName, "visibleInPvp")
end

function GroupBuffs.GetIsFramePveEnabled(frameName)
	return GroupBuffs.GetAttributeFromFrameByFrameName(frameName, "visibleInPve")
end

function GroupBuffs.GetFrameBuffSpacing(frameName)
	return GroupBuffs.GetAttributeFromFrameByFrameName(frameName, "buffSpaceWidth")
end

function GroupBuffs.GetFrameHeaderColor(frameName)
	return GroupBuffs.GetAttributeFromFrameByFrameName(frameName, "headerColor")
end

function GroupBuffs.SetIsFrameEnabled(frameName, value)
	GroupBuffs.SetAttributeOfFrameByFrameName(frameName, "isEnabled", value)
end

function GroupBuffs.SetIsFrameFixedLocation(frameName, value)
	GroupBuffs.SetAttributeOfFrameByFrameName(frameName, "isMovable", value)
	GroupBuffs.UpdateControlIsMovable(frameName, value)
end

function GroupBuffs.SetIsFramePvpEnabled(frameName, value)
	GroupBuffs.SetAttributeOfFrameByFrameName(frameName, "visibleInPvp", value)
end

function GroupBuffs.SetIsFramePveEnabled(frameName, value)
	GroupBuffs.SetAttributeOfFrameByFrameName(frameName, "visibleInPve", value)
end

function GroupBuffs.SetFrameBuffSpacing(frameName, value)
	GroupBuffs.SetAttributeOfFrameByFrameName(frameName, "buffSpaceWidth", value)
	GroupBuffs.UpdateBuffLayoutByFrameName(frameName)
end

function GroupBuffs.SetFrameHeaderColor(frameName, value)
	GroupBuffs.SetAttributeOfFrameByFrameName(frameName, "headerColor", value)
	GroupBuffs.UpdateControlHeaderColor(frameName, value)
end

function GroupBuffs.GetDisplayModes()
	local values = {}
	values[GroupBuffs.config.constants.nameMode.CHAR] = GroupBuffs.config.constants.DISPLAY_MODE_NAME
	values[GroupBuffs.config.constants.nameMode.DISPLAY] = GroupBuffs.config.constants.DISPLAY_MODE_DISPLAY
	return values
end

function GroupBuffs.GetDisplayModesValues()
	local values = {
		GroupBuffs.config.constants.nameMode.CHAR,
		GroupBuffs.config.constants.nameMode.DISPLAY
	}
	return values
end

function GroupBuffs.GetDisplayMode(frameName)
	--local modes = GroupBuffs.GetDisplayModes()
	--local id = GroupBuffs.GetAttributeFromFrameByFrameName(frameName, "nameMode")
	return GroupBuffs.GetAttributeFromFrameByFrameName(frameName, "nameMode")
end

function GroupBuffs.SetSelectedDisplayMode(frameName, value)
	GroupBuffs.SetAttributeOfFrameByFrameName(frameName, "nameMode", value)
	GroupBuffs.UpdateBuffLayoutByFrameName(frameName)
end

function GroupBuffs.GetRoleModes()
	local values = {}
	values[GroupBuffs.config.constants.roleMode.ALL] = GroupBuffs.config.constants.ROLE_MODE_ALL
	values[GroupBuffs.config.constants.roleMode.TANK] = GroupBuffs.config.constants.ROLE_MODE_TANK
	values[GroupBuffs.config.constants.roleMode.HEALER] = GroupBuffs.config.constants.ROLE_MODE_HEALER
	values[GroupBuffs.config.constants.roleMode.DD] = GroupBuffs.config.constants.ROLE_MODE_DD
	return values
end

function GroupBuffs.GetRoleModesValues()
	local values = {
		GroupBuffs.config.constants.roleMode.ALL, 
	    GroupBuffs.config.constants.roleMode.TANK, 
		GroupBuffs.config.constants.roleMode.HEALER,
		GroupBuffs.config.constants.roleMode.DD
	}
	return values
end

function GroupBuffs.GetRoleMode(frameName)
	--local roles = GroupBuffs.GetRoleModes()
	--local id = GroupBuffs.GetAttributeFromFrameByFrameName(frameName, "roleMode")
	return GroupBuffs.GetAttributeFromFrameByFrameName(frameName, "roleMode")
end

function GroupBuffs.SetSelectedRoleMode(frameName, value)
	GroupBuffs.SetAttributeOfFrameByFrameName(frameName, "roleMode", value)
	GroupBuffs.UpdateBuffLayoutByFrameName(frameName)
end

function GroupBuffs.GetDefaultHeaderColor()
	return GroupBuffs.config.defaultValues.headerColor
end

function GroupBuffs.GetBuffNames(selectedFrameName)
	local retVal = {}
	local indexTable = {}
	--d(selectedFrameName)
	if GroupBuffs.savedVars ~= nil and GroupBuffs.savedVars.frame ~= nil then
		local id = GroupBuffs.GetFrameIdFromName(selectedFrameName)
		if id ~= nil and id > 0 then
			local buffs = GroupBuffs.savedVars.frame[id].buffs
			for i = 1, #buffs do
				retVal[i] = buffs[i].name
				indexTable[i] = i
				--d(retVal[i])
			end
		end
	end
	return retVal, indexTable
end

function GroupBuffs.AddNewBuff(frameName, newBuffName)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 then
		local frame = GroupBuffs.savedVars.frame[id]
		if frame ~= nil then
			if frame.buffs == nil then
				frame.buffs = {}
			end
			local buffs = frame.buffs
			return GroupBuffs.InitializeNewBuff(id, #buffs + 1, newBuffName)
		end
	end
	return false
end

function GroupBuffs.RemoveBuff(frameName, buffId)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 then
		local buffs = GroupBuffs.savedVars.frame[id].buffs
		local buffControl = GroupBuffs.controls.frame[id].buffs
		local headerControl = GroupBuffs.controls.frame[id].headerLabel
		local addonState = GroupBuffs.addonState.frame[id].buffs
		GroupBuffs.HideBuffControls(id, buffId)
		table.remove(buffs, buffId)
		table.remove(buffControl, buffId)
		table.remove(headerControl, buffId)
		table.remove(addonState, buffId)
		GroupBuffs.UpdateBuffLayoutById(id)
	end
end

function GroupBuffs.GetShowBuffName(frameName, buffId)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil then
		return GroupBuffs.savedVars.frame[id].buffs[buffId].showName
	end
	return false
end

function GroupBuffs.SetShowBuffName(frameName, buffId, value)
	local id = GroupBuffs.GetFrameIdFromName(frameName) 
	if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil then
		GroupBuffs.savedVars.frame[id].buffs[buffId].showName = value
		if GroupBuffs.controls.frame[id] ~= nil and GroupBuffs.controls.frame[id].headerLabel ~= nil and GroupBuffs.controls.frame[id].headerLabel[buffId] ~= nil then
			GroupBuffs.controls.frame[id].headerLabel[buffId]:SetHidden(not value)
		end
	end
	
end

function GroupBuffs.GetShowBuffStack(frameName, buffId)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil then
		return GroupBuffs.savedVars.frame[id].buffs[buffId].showStack
	end
	return false
end

function GroupBuffs.SetShowBuffStack(frameName, buffId, value)
	local id = GroupBuffs.GetFrameIdFromName(frameName) 
	if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil then
		GroupBuffs.savedVars.frame[id].buffs[buffId].showStack = value
	end
end

function GroupBuffs.GetShowBuffSDifferentOffDeadColor(frameName, buffId)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil then
		return GroupBuffs.savedVars.frame[id].buffs[buffId].differentOffDeadColor
	end
	return false
end

function GroupBuffs.SetShowBuffSDifferentOffDeadColor(frameName, buffId, value)
	local id = GroupBuffs.GetFrameIdFromName(frameName) 
	if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil then
		GroupBuffs.savedVars.frame[id].buffs[buffId].differentOffDeadColor = value
	end
end

function GroupBuffs.GetBuffDifferentOffDeadColor(frameName, buffId)
	local retVal = nil
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil then
		retVal = GroupBuffs.savedVars.frame[id].buffs[buffId].differentOffDeadColorLabel
	end
	if retVal == nil then
		retVal = {R = 0, G = 0, B = 0}
	end
	return retVal
end

function GroupBuffs.SetBuffDifferentOffDeadColor(frameName, buffId, value)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil then
		GroupBuffs.savedVars.frame[id].buffs[buffId].differentOffDeadColorLabel = value
	end
end

function GroupBuffs.GetAlwaysShowName(frameName, buffId)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil then
		return GroupBuffs.savedVars.frame[id].buffs[buffId].alwaysShowNames
	end
	return false
end

function GroupBuffs.SetAlwaysShowName(frameName, buffId, value)
	local id = GroupBuffs.GetFrameIdFromName(frameName) 
	if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil then
		GroupBuffs.savedVars.frame[id].buffs[buffId].alwaysShowNames = value
	end
	
end

function GroupBuffs.GetBuffColumnSize(frameName, buffId)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].boxDimension ~= nil then
		return GroupBuffs.savedVars.frame[id].buffs[buffId].boxDimension.width
	end
	return GroupBuffs.config.defaultValues.boxDimensionWidth
end

function GroupBuffs.SetBuffColumnSize(frameName, buffId, value)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].boxDimension ~= nil then
		GroupBuffs.savedVars.frame[id].buffs[buffId].boxDimension.width = value
		GroupBuffs.UpdateBuffLayoutByFrameName(frameName)
	end
end

function GroupBuffs.GetOrderChoices()
	return { GroupBuffs.config.constants.NAME_SORT_BY_NONE,
			 GroupBuffs.config.constants.NAME_SORT_BY_TIMER_DESC,
			 GroupBuffs.config.constants.NAME_SORT_BY_TIMER_ASC,
			 GroupBuffs.config.constants.NAME_SORT_BY_NAME_DESC,
			 GroupBuffs.config.constants.NAME_SORT_BY_NAME_ASC,
			 GroupBuffs.config.constants.NAME_SORT_BY_NAME_IN_POSITION_DESC,
			 GroupBuffs.config.constants.NAME_SORT_BY_NAME_IN_POSITION_ASC
	}
end

function GroupBuffs.GetOrderChoicesValues()
	return { GroupBuffs.config.constants.SORT_BY_NONE,
			 GroupBuffs.config.constants.SORT_BY_TIMER_DESC,
			 GroupBuffs.config.constants.SORT_BY_TIMER_ASC,
			 GroupBuffs.config.constants.SORT_BY_NAME_DESC,
			 GroupBuffs.config.constants.SORT_BY_NAME_ASC,
			 GroupBuffs.config.constants.SORT_BY_NAME_IN_POSITION_DESC,
			 GroupBuffs.config.constants.SORT_BY_NAME_IN_POSITION_ASC
	}
end

function GroupBuffs.GetOrder(frameName, buffId)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil then
		return GroupBuffs.savedVars.frame[id].buffs[buffId].sortMethod
	end
	return GroupBuffs.config.constants.SORT_BY_NONE
end

function GroupBuffs.SetOrder(frameName, buffId, value)
	local id = GroupBuffs.GetFrameIdFromName(frameName) 
	if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil then
		GroupBuffs.savedVars.frame[id].buffs[buffId].sortMethod = value
	end
end

function GroupBuffs.GetBuffEffectIdChoices(frameName, buffId)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	local retVal = {}
	if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].id ~= nil then
		local ids = GroupBuffs.savedVars.frame[id].buffs[buffId].id
		for i = 1, #ids do
			retVal[i] = i
		end
	end
	return retVal
end

function GroupBuffs.AddBuffEffect(frameName, buffId)
	GroupBuffs.AddNewBuffEffect(frameName, buffId)
end

function GroupBuffs.RemoveBuffEffect(frameName, buffId, effectId)
	if frameName ~= nil and buffId ~= nil and effectId ~= nil then
		local id = GroupBuffs.GetFrameIdFromName(frameName)
		if id ~= nil and id > 0 and GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].id ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].id[effectId] ~= nil then
			local buffEffectIds = GroupBuffs.savedVars.frame[id].buffs[buffId].id
			if #buffEffectIds > 1 then
				local buffColors = GroupBuffs.savedVars.frame[id].buffs[buffId].buffColors
				table.remove(buffEffectIds, effectId)
				table.remove(buffColors, effectId)
				return true
			end
		end
	end
	return false
end

function GroupBuffs.GetBuffEffectColor(frameName, buffId, effectId)
	local retVal = nil
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and buffId ~= nil and buffId > 0 and effectId ~= nil and effectId > 0 then
		if GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].id ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].id[effectId] ~= nil then
			retVal = GroupBuffs.savedVars.frame[id].buffs[buffId].buffColors[effectId]
		end
	end
	if retVal == nil then
		retVal = {R = 1, G = 0, B = 0}
	end
	return retVal
end

function GroupBuffs.SetBuffEffectColor(frameName, buffId, effectId, color)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and buffId ~= nil and buffId > 0 and effectId ~= nil and effectId > 0 then
		if GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].id ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].id[effectId] ~= nil then
			GroupBuffs.savedVars.frame[id].buffs[buffId].buffColors[effectId] = color
		end
	end
end

function GroupBuffs.GetBuffEffectFontColor(frameName, buffId, effectId)
	local retVal = nil
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and buffId ~= nil and buffId > 0 and effectId ~= nil and effectId > 0 then
		if GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].id ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].id[effectId] ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].fontColors ~= nil then
			retVal = GroupBuffs.savedVars.frame[id].buffs[buffId].fontColors[effectId]
		end
	end
	if retVal == nil then
		retVal = {R = GroupBuffs.config.defaultValues.defaultColorLabel.R, G = GroupBuffs.config.defaultValues.defaultColorLabel.G, B = GroupBuffs.config.defaultValues.defaultColorLabel.B}
	end
	return retVal
end

function GroupBuffs.SetBuffEffectFontColor(frameName, buffId, effectId, color)
	local id = GroupBuffs.GetFrameIdFromName(frameName)
	if id ~= nil and id > 0 and buffId ~= nil and buffId > 0 and effectId ~= nil and effectId > 0 then
		if GroupBuffs.savedVars.frame[id] ~= nil and GroupBuffs.savedVars.frame[id].buffs ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId] ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].id ~= nil and GroupBuffs.savedVars.frame[id].buffs[buffId].id[effectId] ~= nil then
			if GroupBuffs.savedVars.frame[id].buffs[buffId].fontColors == nil then
				GroupBuffs.savedVars.frame[id].buffs[buffId].fontColors = {}
			end
			GroupBuffs.savedVars.frame[id].buffs[buffId].fontColors[effectId] = color
		end
	end
end

function GroupBuffs.GetEffectFadeInDuration(frameName, buffId)
	local retVal = GroupBuffs.GetBuffEffectValue(frameName, buffId, "fadeIn", "timeSpan")
	if retVal == nil then
		retVal = 0
	end
	return retVal
end

function GroupBuffs.SetEffectFadeInDuration(frameName, buffId, duration)
	GroupBuffs.SetBuffEffectValue(frameName, buffId, "fadeIn", "timeSpan", duration)
end

function GroupBuffs.GetEffectFadeInColor(frameName, buffId)
	local retVal = GroupBuffs.GetBuffEffectValue(frameName, buffId, "fadeIn", "color")
	if retVal == nil then
		retVal = {R = 1, G = 0, B = 0}
	end
	return retVal
end

function GroupBuffs.SetEffectFadeInColor(frameName, buffId, color)
	GroupBuffs.SetBuffEffectValue(frameName, buffId, "fadeIn", "color", color)
end

function GroupBuffs.GetEffectFadeOutDuration(frameName, buffId)
	local retVal = GroupBuffs.GetBuffEffectValue(frameName, buffId, "fadeOut", "timeSpan")
	if retVal == nil then
		retVal = 0
	end
	return retVal
end

function GroupBuffs.SetEffectFadeOutDuration(frameName, buffId, duration)
	GroupBuffs.SetBuffEffectValue(frameName, buffId, "fadeOut", "timeSpan", duration)
end

function GroupBuffs.GetEffectFadeOutColor(frameName, buffId)
	local retVal = GroupBuffs.GetBuffEffectValue(frameName, buffId, "fadeOut", "color")
	if retVal == nil then
		retVal = {R = 1, G = 0, B = 0}
	end
	return retVal
end

function GroupBuffs.SetEffectFadeOutColor(frameName, buffId, color)
	GroupBuffs.SetBuffEffectValue(frameName, buffId, "fadeOut", "color", color)
end

function GroupBuffs.GetActiveSoundEffect(frameName, buffId)
	local retVal = GroupBuffs.GetBuffEffectValue(frameName, buffId, "audio", "enabled")
	if retVal == nil then
		retVal = false
	end
	return retVal
end

function GroupBuffs.SetActiveSoundEffect(frameName, buffId, value)
	GroupBuffs.SetBuffEffectValue(frameName, buffId, "audio", "enabled", value)
end

function GroupBuffs.GetEffectAudioInterval(frameName, buffId)
	local retVal = GroupBuffs.GetBuffEffectValue(frameName, buffId, "audio", "interval")
	if retVal == nil then
		retVal = 5
	end
	return retVal
end

function GroupBuffs.SetEffectAudioInterval(frameName, buffId, value)
	GroupBuffs.SetBuffEffectValue(frameName, buffId, "audio", "interval", value)
end

function GroupBuffs.GetAudioEffectName(frameName, buffId)
	return GroupBuffs.GetBuffEffectValue(frameName, buffId, "audio", "selectedSound")
end

function GroupBuffs.SetAudioEffectName(frameName, buffId, value)
	GroupBuffs.SetBuffEffectValue(frameName, buffId, "audio", "selectedSound", value)
end

--[[DEBUG FUNCTIONS]]
GroupBuffs.debug = {}
GroupBuffs.debug.informationGathering = {}
GroupBuffs.debug.informationGathering.effectName = {}
GroupBuffs.debug.informationGathering.id = {}
--ByName
--Sorc
GroupBuffs.debug.informationGathering.effectName[1] = "Crystal Shard"
GroupBuffs.debug.informationGathering.effectName[2] = "Crystal Blast"
GroupBuffs.debug.informationGathering.effectName[3] = "Crystal Fragements"
GroupBuffs.debug.informationGathering.effectName[4] = "Encase"
GroupBuffs.debug.informationGathering.effectName[5] = "Shattering Prison"
GroupBuffs.debug.informationGathering.effectName[6] = "Restraining Prison"
GroupBuffs.debug.informationGathering.effectName[7] = "Rune Prison"
GroupBuffs.debug.informationGathering.effectName[8] = ""
GroupBuffs.debug.informationGathering.effectName[9] = ""
GroupBuffs.debug.informationGathering.effectName[10] = "Daedric Mines"
GroupBuffs.debug.informationGathering.effectName[11] = "Daedric Tomb"
GroupBuffs.debug.informationGathering.effectName[12] = "Daedric Minefield"
GroupBuffs.debug.informationGathering.effectName[13] = "Negate Magic"
GroupBuffs.debug.informationGathering.effectName[14] = "" --Empty by Design

GroupBuffs.debug.informationGathering.effectName[15] = "Summon Unstable Familiar"
GroupBuffs.debug.informationGathering.effectName[16] = "Summon Unstable Clannfear"
GroupBuffs.debug.informationGathering.effectName[17] = "Summon Volatile Familiar"
GroupBuffs.debug.informationGathering.effectName[18] = "Daedric Curse"
GroupBuffs.debug.informationGathering.effectName[19] = "Daedric Prey"
GroupBuffs.debug.informationGathering.effectName[20] = "Haunting Curse"
GroupBuffs.debug.informationGathering.effectName[21] = "Summon Winged Twilight"
GroupBuffs.debug.informationGathering.effectName[22] = "Summon Twilight Tormentor"
GroupBuffs.debug.informationGathering.effectName[23] = "Summon Twilight Matriarch"
GroupBuffs.debug.informationGathering.effectName[24] = "Conjured Ward"
GroupBuffs.debug.informationGathering.effectName[25] = "Hardened Ward"
GroupBuffs.debug.informationGathering.effectName[26] = "Empowered Ward"
GroupBuffs.debug.informationGathering.effectName[27] = "Bound Armor"
GroupBuffs.debug.informationGathering.effectName[28] = "Bound Armaments"
GroupBuffs.debug.informationGathering.effectName[29] = "Bound Aegis"
GroupBuffs.debug.informationGathering.effectName[30] = "Summon Storm Atronach"
GroupBuffs.debug.informationGathering.effectName[31] = "Zap Snare"

GroupBuffs.debug.informationGathering.effectName[32] = "Mages' Fury"
GroupBuffs.debug.informationGathering.effectName[33] = "Mages' Wrath"
GroupBuffs.debug.informationGathering.effectName[34] = "Endless Fury"
GroupBuffs.debug.informationGathering.effectName[35] = "Lightning Form"
GroupBuffs.debug.informationGathering.effectName[36] = "Hurricane"
GroupBuffs.debug.informationGathering.effectName[37] = "Boundless Storm"
GroupBuffs.debug.informationGathering.effectName[38] = "Surge"
GroupBuffs.debug.informationGathering.effectName[39] = "Power Surge"
GroupBuffs.debug.informationGathering.effectName[40] = "Critical Surge"
GroupBuffs.debug.informationGathering.effectName[41] = "Bolt Escape"
GroupBuffs.debug.informationGathering.effectName[42] = "Streak"
GroupBuffs.debug.informationGathering.effectName[43] = "Bolt Escape"
GroupBuffs.debug.informationGathering.effectName[44] = "Overload"
GroupBuffs.debug.informationGathering.effectName[45] = "Power Overload"
GroupBuffs.debug.informationGathering.effectName[46] = "Energy Overload"
--Destro
GroupBuffs.debug.informationGathering.effectName[47] = "Wall of Storms"
GroupBuffs.debug.informationGathering.effectName[48] = "Wall of Frost" --verify effect
GroupBuffs.debug.informationGathering.effectName[49] = "" --Empty by Design
GroupBuffs.debug.informationGathering.effectName[50] = "Unstable Wall of Storms"
GroupBuffs.debug.informationGathering.effectName[51] = "Unstable Wall of Frost"
GroupBuffs.debug.informationGathering.effectName[52] = "" --Empty by Design
GroupBuffs.debug.informationGathering.effectName[53] = "Frost Reach"
GroupBuffs.debug.informationGathering.effectName[54] = "Frost Grip"
GroupBuffs.debug.informationGathering.effectName[55] = "Flame Reach"
GroupBuffs.debug.informationGathering.effectName[56] = "Shock Touch"
GroupBuffs.debug.informationGathering.effectName[57] = "Frost Touch"
GroupBuffs.debug.informationGathering.effectName[58] = "Fire Touch"
GroupBuffs.debug.informationGathering.effectName[59] = "Shock Clench"
GroupBuffs.debug.informationGathering.effectName[60] = "Frost Clench"
GroupBuffs.debug.informationGathering.effectName[61] = "Shock Reach"
GroupBuffs.debug.informationGathering.effectName[62] = "Deep Freeze"
GroupBuffs.debug.informationGathering.effectName[63] = "Icy Rage Immobilize"
GroupBuffs.debug.informationGathering.effectName[64] = "Eye of Flame"
GroupBuffs.debug.informationGathering.effectName[65] = "Eye of Frost"
GroupBuffs.debug.informationGathering.effectName[66] = "Eye of Lightning"
GroupBuffs.debug.informationGathering.effectName[67] = "Blockade of Storms"
--Resto

--DK
GroupBuffs.debug.informationGathering.effectName[68] = "Warmth"
GroupBuffs.debug.informationGathering.effectName[69] = "Searing Strike"
GroupBuffs.debug.informationGathering.effectName[70] = "Venomous Claw"
GroupBuffs.debug.informationGathering.effectName[71] = "Burning Embers"
GroupBuffs.debug.informationGathering.effectName[72] = "Fiery Breath"
GroupBuffs.debug.informationGathering.effectName[73] = "Noxious Breath"
GroupBuffs.debug.informationGathering.effectName[74] = "Engulfing Flames"
GroupBuffs.debug.informationGathering.effectName[75] = "Inferno"
GroupBuffs.debug.informationGathering.effectName[76] = "Flames of Oblivion"
GroupBuffs.debug.informationGathering.effectName[77] = "Cauterize"

GroupBuffs.debug.informationGathering.effectName[78] = "Spiked Armor"
GroupBuffs.debug.informationGathering.effectName[79] = "Hardened Armor"
GroupBuffs.debug.informationGathering.effectName[80] = "Volatile Armor"
GroupBuffs.debug.informationGathering.effectName[81] = "Dark Talons"
GroupBuffs.debug.informationGathering.effectName[82] = "Burning Talons"
GroupBuffs.debug.informationGathering.effectName[83] = "Choking Talons"
GroupBuffs.debug.informationGathering.effectName[84] = "Reflective Scales"
GroupBuffs.debug.informationGathering.effectName[85] = "Reflective Plate"
GroupBuffs.debug.informationGathering.effectName[86] = "Dragonfire Scale"
GroupBuffs.debug.informationGathering.effectName[87] = "Sacred Ground"
GroupBuffs.debug.informationGathering.effectName[88] = "Dragon Leap"
GroupBuffs.debug.informationGathering.effectName[89] = "Ferocious Leap"

GroupBuffs.debug.informationGathering.effectName[90] = "Stonefist"
GroupBuffs.debug.informationGathering.effectName[91] = "Obsidian Shard"
GroupBuffs.debug.informationGathering.effectName[92] = "Stone Giant"
GroupBuffs.debug.informationGathering.effectName[93] = "Molten Armaments"
GroupBuffs.debug.informationGathering.effectName[94] = "Obsidian Shield"
GroupBuffs.debug.informationGathering.effectName[95] = "Ingenous Shield"
GroupBuffs.debug.informationGathering.effectName[96] = "Fragmented Shield"
GroupBuffs.debug.informationGathering.effectName[97] = "Petrify"
GroupBuffs.debug.informationGathering.effectName[98] = "Fossilize"
GroupBuffs.debug.informationGathering.effectName[99] = "Shattering Rocks"
GroupBuffs.debug.informationGathering.effectName[100] = "Ash Cloud"
GroupBuffs.debug.informationGathering.effectName[101] = "Cinder Storm"
GroupBuffs.debug.informationGathering.effectName[102] = "Eruption"
GroupBuffs.debug.informationGathering.effectName[103] = "Magma Armor"
GroupBuffs.debug.informationGathering.effectName[104] = "Magma Shell"
GroupBuffs.debug.informationGathering.effectName[105] = "Corrosive Armor"

--templar
GroupBuffs.debug.informationGathering.effectName[106] = "Puncturing Strikes"
GroupBuffs.debug.informationGathering.effectName[107] = "Piercing Javelin"
GroupBuffs.debug.informationGathering.effectName[108] = "Sun Shield"
GroupBuffs.debug.informationGathering.effectName[109] = "Radial Sweep"
GroupBuffs.debug.informationGathering.effectName[110] = "Biting Jabs"
GroupBuffs.debug.informationGathering.effectName[111] = "Aurora Javelin"
GroupBuffs.debug.informationGathering.effectName[112] = "Radiant Ward"
GroupBuffs.debug.informationGathering.effectName[113] = "Empowering Sweep"
GroupBuffs.debug.informationGathering.effectName[114] = "Puncturing Strikes"
GroupBuffs.debug.informationGathering.effectName[115] = "Binding Javelin"
GroupBuffs.debug.informationGathering.effectName[116] = "Toppling Charge"
GroupBuffs.debug.informationGathering.effectName[117] = "Blazing Shield"
GroupBuffs.debug.informationGathering.effectName[118] = "Radial Sweep"

GroupBuffs.debug.informationGathering.effectName[119] = "Sun Fire"
GroupBuffs.debug.informationGathering.effectName[120] = "Backlash"
GroupBuffs.debug.informationGathering.effectName[121] = "Eclipse"
GroupBuffs.debug.informationGathering.effectName[122] = "Eclipse Reflect"
GroupBuffs.debug.informationGathering.effectName[123] = "Radiant Destruction"
GroupBuffs.debug.informationGathering.effectName[124] = "Nova"
GroupBuffs.debug.informationGathering.effectName[125] = "Vampire's Bane"
GroupBuffs.debug.informationGathering.effectName[126] = "Purifying Light"
GroupBuffs.debug.informationGathering.effectName[127] = "Total Dark"
GroupBuffs.debug.informationGathering.effectName[128] = "Total Dark Reflect"
GroupBuffs.debug.informationGathering.effectName[129] = "Radiant Glory"
GroupBuffs.debug.informationGathering.effectName[130] = "Solar Prison"
GroupBuffs.debug.informationGathering.effectName[131] = "Reflective Light"
GroupBuffs.debug.informationGathering.effectName[132] = "Power of the Light"
GroupBuffs.debug.informationGathering.effectName[133] = "Unstable Core"
GroupBuffs.debug.informationGathering.effectName[134] = "Radiant Oppression"
GroupBuffs.debug.informationGathering.effectName[135] = "Solar Disturbance"

--warden
GroupBuffs.debug.informationGathering.effectName[136] = "Healing Seed Synergy"
GroupBuffs.debug.informationGathering.effectName[137] = "Living Vines"
GroupBuffs.debug.informationGathering.effectName[138] = "Lotus Flower"
GroupBuffs.debug.informationGathering.effectName[139] = "Nature's Grasp"
GroupBuffs.debug.informationGathering.effectName[140] = "Scorch"
GroupBuffs.debug.informationGathering.effectName[141] = "Swarm"
GroupBuffs.debug.informationGathering.effectName[142] = "Betty Netch"
GroupBuffs.debug.informationGathering.effectName[143] = "Feral Guardian"
GroupBuffs.debug.informationGathering.effectName[144] = "Budding Seeds Synergy"
GroupBuffs.debug.informationGathering.effectName[145] = "Leeching Vines"
GroupBuffs.debug.informationGathering.effectName[146] = "Green Lotus"
GroupBuffs.debug.informationGathering.effectName[147] = "Subterranean Assault"
GroupBuffs.debug.informationGathering.effectName[148] = "Fetcher Infection"
GroupBuffs.debug.informationGathering.effectName[149] = "Blue Betty"
GroupBuffs.debug.informationGathering.effectName[150] = "Eternal Guardian"
GroupBuffs.debug.informationGathering.effectName[151] = "Crushing Swipe"
GroupBuffs.debug.informationGathering.effectName[152] = "Corrupting Pollen Synergy"
GroupBuffs.debug.informationGathering.effectName[153] = "Living Trellis"
GroupBuffs.debug.informationGathering.effectName[154] = "Lotus Blossom"
GroupBuffs.debug.informationGathering.effectName[155] = "Nature's Embrace"
GroupBuffs.debug.informationGathering.effectName[156] = "Healing Thicket"
GroupBuffs.debug.informationGathering.effectName[157] = "Deep Fissure"
GroupBuffs.debug.informationGathering.effectName[158] = "Growing Swarm"
GroupBuffs.debug.informationGathering.effectName[159] = "Bull Netch"
GroupBuffs.debug.informationGathering.effectName[160] = "Wild Guardian"
GroupBuffs.debug.informationGathering.effectName[161] = "Guardian's Savagery"

GroupBuffs.debug.informationGathering.effectName[162] = "Impaling Shards"
GroupBuffs.debug.informationGathering.effectName[163] = "Arctic Wind"
GroupBuffs.debug.informationGathering.effectName[164] = "Crystallized Shield"
GroupBuffs.debug.informationGathering.effectName[165] = "Frozen Gate Root"
GroupBuffs.debug.informationGathering.effectName[166] = "Sleet Storm"
GroupBuffs.debug.informationGathering.effectName[167] = "Gripping Shards"
GroupBuffs.debug.informationGathering.effectName[168] = "Polar Wind"
GroupBuffs.debug.informationGathering.effectName[169] = "Crystallized Slab"
GroupBuffs.debug.informationGathering.effectName[170] = "Frozen Gate Root"
GroupBuffs.debug.informationGathering.effectName[171] = "Northern Storm"
GroupBuffs.debug.informationGathering.effectName[172] = "Winters Revenge"
GroupBuffs.debug.informationGathering.effectName[173] = "Arctic Blast"
GroupBuffs.debug.informationGathering.effectName[174] = "Shimmering Shield"
GroupBuffs.debug.informationGathering.effectName[175] = "Frozen Retreat Root"
GroupBuffs.debug.informationGathering.effectName[176] = "Permafrost"

--nightblade
GroupBuffs.debug.informationGathering.effectName[177] = "Mark Target"
GroupBuffs.debug.informationGathering.effectName[178] = "Grim Focus"
GroupBuffs.debug.informationGathering.effectName[179] = "Damage Taken Increased"
GroupBuffs.debug.informationGathering.effectName[180] = "Shadow Cloak"
GroupBuffs.debug.informationGathering.effectName[181] = "Aspect of Terror"
GroupBuffs.debug.informationGathering.effectName[182] = "Consuming Darkness"
GroupBuffs.debug.informationGathering.effectName[183] = "Twin Blade and Blunt Bleed"
GroupBuffs.debug.informationGathering.effectName[184] = "Lotus Fan"
GroupBuffs.debug.informationGathering.effectName[185] = "Piercing Mark"
GroupBuffs.debug.informationGathering.effectName[186] = "Relentless Focus"
GroupBuffs.debug.informationGathering.effectName[187] = "Incapacitating Strike"
GroupBuffs.debug.informationGathering.effectName[188] = "Precision"
GroupBuffs.debug.informationGathering.effectName[189] = "Shadowy Disguise"
GroupBuffs.debug.informationGathering.effectName[190] = "Mass Hysteria"
GroupBuffs.debug.informationGathering.effectName[191] = "Bolstering Darkness"
GroupBuffs.debug.informationGathering.effectName[192] = "Strife"
GroupBuffs.debug.informationGathering.effectName[193] = "Agony"
GroupBuffs.debug.informationGathering.effectName[194] = "Cripple"
GroupBuffs.debug.informationGathering.effectName[195] = "Siphoning Strikes"
GroupBuffs.debug.informationGathering.effectName[196] = "Soul Shred"
GroupBuffs.debug.informationGathering.effectName[197] = "Funnel Health"
GroupBuffs.debug.informationGathering.effectName[198] = "Prolonged Suffering"
GroupBuffs.debug.informationGathering.effectName[199] = "Debilitate"
GroupBuffs.debug.informationGathering.effectName[200] = "Leeching Strikes"
GroupBuffs.debug.informationGathering.effectName[201] = "Reaper's Mark"
GroupBuffs.debug.informationGathering.effectName[202] = "Merciless Resolve"
GroupBuffs.debug.informationGathering.effectName[203] = "Damage Taken Increased"
GroupBuffs.debug.informationGathering.effectName[204] = "Dark Cloak"
GroupBuffs.debug.informationGathering.effectName[205] = "Refreshing Path"
GroupBuffs.debug.informationGathering.effectName[206] = "Manifestation of Terror"
GroupBuffs.debug.informationGathering.effectName[207] = "Shade Corrode"
GroupBuffs.debug.informationGathering.effectName[208] = "Veil of Blades"
GroupBuffs.debug.informationGathering.effectName[209] = "Swallow Soul"
GroupBuffs.debug.informationGathering.effectName[210] = "Malefic Wreath"
GroupBuffs.debug.informationGathering.effectName[211] = "Crippling Grasp"
GroupBuffs.debug.informationGathering.effectName[212] = "Siphoning Attacks"
GroupBuffs.debug.informationGathering.effectName[213] = "Soul Tether"


--fighters guild
GroupBuffs.debug.informationGathering.effectName[214] = "Silver Bolts"
GroupBuffs.debug.informationGathering.effectName[215] = "Expert Hunter"
GroupBuffs.debug.informationGathering.effectName[216] = "Trap Beast"
GroupBuffs.debug.informationGathering.effectName[217] = "Dawnbreaker"
GroupBuffs.debug.informationGathering.effectName[218] = "Silver Shards"
GroupBuffs.debug.informationGathering.effectName[219] = "Evil Hunter"
GroupBuffs.debug.informationGathering.effectName[220] = "Rearming Trap"
GroupBuffs.debug.informationGathering.effectName[221] = "Flawless Dawnbreaker"
GroupBuffs.debug.informationGathering.effectName[222] = "Silver Bolts"
GroupBuffs.debug.informationGathering.effectName[223] = "Camouflaged Hunter"
GroupBuffs.debug.informationGathering.effectName[224] = "Lightweight Beast Trap"
GroupBuffs.debug.informationGathering.effectName[225] = "Living Vines"
GroupBuffs.debug.informationGathering.effectName[226] = "Dawnbreaker of Smiting"

--mage guild
GroupBuffs.debug.informationGathering.effectName[227] = "Magelight"
GroupBuffs.debug.informationGathering.effectName[228] = "Entropy"
GroupBuffs.debug.informationGathering.effectName[229] = "Equilibrium"
GroupBuffs.debug.informationGathering.effectName[230] = "Stun"
GroupBuffs.debug.informationGathering.effectName[231] = "Inner Light"
GroupBuffs.debug.informationGathering.effectName[232] = "Invisibility"
GroupBuffs.debug.informationGathering.effectName[233] = "Degeneration"
GroupBuffs.debug.informationGathering.effectName[234] = "Volcanic Rune"
GroupBuffs.debug.informationGathering.effectName[235] = "Spell Symmetry"
GroupBuffs.debug.informationGathering.effectName[236] = "Ice Comet"
GroupBuffs.debug.informationGathering.effectName[237] = "Radiant Magelight"
GroupBuffs.debug.informationGathering.effectName[238] = "Structured Entropy"
GroupBuffs.debug.informationGathering.effectName[239] = "Scalding Rune"
GroupBuffs.debug.informationGathering.effectName[240] = "Balance"


--undaunted
GroupBuffs.debug.informationGathering.effectName[241] = "Trapping Webs"
GroupBuffs.debug.informationGathering.effectName[242] = "Bone Shield"
GroupBuffs.debug.informationGathering.effectName[243] = "Inner Fire"
GroupBuffs.debug.informationGathering.effectName[244] = "Shadow Silk"
GroupBuffs.debug.informationGathering.effectName[245] = "Inner Rage"
GroupBuffs.debug.informationGathering.effectName[246] = "Spiked Bone Shield"
GroupBuffs.debug.informationGathering.effectName[247] = "Tangling Webs"
GroupBuffs.debug.informationGathering.effectName[248] = "Inner Beast"
GroupBuffs.debug.informationGathering.effectName[249] = "Bone Surge"

--vampire
GroupBuffs.debug.informationGathering.effectName[250] = "Stage 1 Vampirism"
GroupBuffs.debug.informationGathering.effectName[251] = "Stage 2 Vampirism"
GroupBuffs.debug.informationGathering.effectName[252] = "Stage 3 Vampirism"
GroupBuffs.debug.informationGathering.effectName[253] = "Stage 4 Vampirism"
GroupBuffs.debug.informationGathering.effectName[254] = "Drain Essence"
GroupBuffs.debug.informationGathering.effectName[255] = "Mist Form"
GroupBuffs.debug.informationGathering.effectName[256] = "Bat Swarm"

--ww
GroupBuffs.debug.informationGathering.effectName[257] = "Lycanthropy"
GroupBuffs.debug.informationGathering.effectName[258] = "Pursuit"
GroupBuffs.debug.informationGathering.effectName[259] = "Roar"
GroupBuffs.debug.informationGathering.effectName[260] = "Off Balance"
GroupBuffs.debug.informationGathering.effectName[261] = "Piercing Howl Stun"
GroupBuffs.debug.informationGathering.effectName[262] = "Infection"
GroupBuffs.debug.informationGathering.effectName[263] = "Werewolf Bleed"


--alliance support
GroupBuffs.debug.informationGathering.effectName[264] = "Siege Shield"
GroupBuffs.debug.informationGathering.effectName[265] = "Purge"
GroupBuffs.debug.informationGathering.effectName[266] = "Guard"
GroupBuffs.debug.informationGathering.effectName[267] = "Revealing Flare"
GroupBuffs.debug.informationGathering.effectName[268] = "Barrier"
GroupBuffs.debug.informationGathering.effectName[269] = "Siege Weapon Shield"
GroupBuffs.debug.informationGathering.effectName[270] = "Lingering Flare"
GroupBuffs.debug.informationGathering.effectName[271] = "Reviving Barrier"
GroupBuffs.debug.informationGathering.effectName[272] = "Reviving Barrier Heal"
GroupBuffs.debug.informationGathering.effectName[273] = "Mystic Guard"
GroupBuffs.debug.informationGathering.effectName[274] = "Stalwart Guard"
GroupBuffs.debug.informationGathering.effectName[275] = "Propelling Shield"
GroupBuffs.debug.informationGathering.effectName[276] = "Cleanse"
GroupBuffs.debug.informationGathering.effectName[277] = "Scorching Flare Reveal"
GroupBuffs.debug.informationGathering.effectName[278] = "Scorching Flare"
GroupBuffs.debug.informationGathering.effectName[279] = "Replenishing Barrier"
GroupBuffs.debug.informationGathering.effectName[280] = "Charging Maneuver"
GroupBuffs.debug.informationGathering.effectName[281] = "Resolving Vigor"
GroupBuffs.debug.informationGathering.effectName[282] = "Proximity Detonation"

--aliance assault
GroupBuffs.debug.informationGathering.effectName[283] = "Rapid Maneuver"
GroupBuffs.debug.informationGathering.effectName[284] = "Vigor"
GroupBuffs.debug.informationGathering.effectName[285] = "Hindered"
GroupBuffs.debug.informationGathering.effectName[286] = "Magicka Detonation"
GroupBuffs.debug.informationGathering.effectName[287] = "War Horn"
GroupBuffs.debug.informationGathering.effectName[288] = "Retreating Maneuver"
GroupBuffs.debug.informationGathering.effectName[289] = "Echoing Vigor"
GroupBuffs.debug.informationGathering.effectName[290] = "Inevitable Detonation"
GroupBuffs.debug.informationGathering.effectName[291] = "Aggressive Horn"

--armor
GroupBuffs.debug.informationGathering.effectName[292] = "Annulment"
GroupBuffs.debug.informationGathering.effectName[293] = "Major Evasion"
GroupBuffs.debug.informationGathering.effectName[294] = "Immovable"
GroupBuffs.debug.informationGathering.effectName[295] = "Dampen Magic"
GroupBuffs.debug.informationGathering.effectName[296] = "Shuffle"
GroupBuffs.debug.informationGathering.effectName[297] = "Immovable Brute"
GroupBuffs.debug.informationGathering.effectName[298] = "Harness Magicka"
GroupBuffs.debug.informationGathering.effectName[299] = "Major Evasion"
GroupBuffs.debug.informationGathering.effectName[300] = "Unstoppable"

--soul magic
GroupBuffs.debug.informationGathering.effectName[301] = "Soul Trap"
GroupBuffs.debug.informationGathering.effectName[302] = "Soul Splitting Trap"
GroupBuffs.debug.informationGathering.effectName[303] = "Consuming Trap"

--bow
GroupBuffs.debug.informationGathering.effectName[304] = "Scatter Shot"
GroupBuffs.debug.informationGathering.effectName[305] = "Arrow Spray"
GroupBuffs.debug.informationGathering.effectName[306] = "Poison Arrow"
GroupBuffs.debug.informationGathering.effectName[307] = "Venom Arrow"
GroupBuffs.debug.informationGathering.effectName[308] = "Focused Aim"
GroupBuffs.debug.informationGathering.effectName[309] = "Draining Shot"
GroupBuffs.debug.informationGathering.effectName[310] = "Acid Spray"
GroupBuffs.debug.informationGathering.effectName[311] = "Poison Injection"

--2h
GroupBuffs.debug.informationGathering.effectName[312] = "Merciless Charge"
GroupBuffs.debug.informationGathering.effectName[313] = "Cleave Bleed"
GroupBuffs.debug.informationGathering.effectName[314] = "Momentum"
GroupBuffs.debug.informationGathering.effectName[315] = "Berserker Strike"
GroupBuffs.debug.informationGathering.effectName[316] = "Dizzying Swing"
GroupBuffs.debug.informationGathering.effectName[317] = "Stampede"
GroupBuffs.debug.informationGathering.effectName[318] = "Carve Bleed"
GroupBuffs.debug.informationGathering.effectName[319] = "Onslaught"
GroupBuffs.debug.informationGathering.effectName[320] = "Deep Slash"
GroupBuffs.debug.informationGathering.effectName[321] = "Defensive Stance"
GroupBuffs.debug.informationGathering.effectName[322] = "Shielded Assault"
GroupBuffs.debug.informationGathering.effectName[323] = "Reverberating Bash"
GroupBuffs.debug.informationGathering.effectName[324] = "Spell Wall"
GroupBuffs.debug.informationGathering.effectName[325] = "Brawler Bleed"
GroupBuffs.debug.informationGathering.effectName[326] = "Rally"
GroupBuffs.debug.informationGathering.effectName[327] = "Berserker Rage"
GroupBuffs.debug.informationGathering.effectName[328] = "Forward Momentum"

--sb
GroupBuffs.debug.informationGathering.effectName[329] = "Low Slash Snare"
GroupBuffs.debug.informationGathering.effectName[330] = "Defensive Posture"
GroupBuffs.debug.informationGathering.effectName[331] = "Power Bash"
GroupBuffs.debug.informationGathering.effectName[332] = "Shield Wall"
GroupBuffs.debug.informationGathering.effectName[333] = "Heroic Slash Snare"
GroupBuffs.debug.informationGathering.effectName[334] = "Rampaging Slash"
GroupBuffs.debug.informationGathering.effectName[335] = "Absorb Magic"
GroupBuffs.debug.informationGathering.effectName[336] = "Invasion Stun"
GroupBuffs.debug.informationGathering.effectName[337] = "Shield Discipline"
GroupBuffs.debug.informationGathering.effectName[338] = "Deep Slash"

--dw
GroupBuffs.debug.informationGathering.effectName[339] = "Cruel Flurry"
GroupBuffs.debug.informationGathering.effectName[340] = "Twin Slashes Bleed"
GroupBuffs.debug.informationGathering.effectName[341] = "Blade Cloak"
GroupBuffs.debug.informationGathering.effectName[342] = "Hidden Blade"
GroupBuffs.debug.informationGathering.effectName[343] = "Lacerate"
GroupBuffs.debug.informationGathering.effectName[344] = "Rending Slashes Bleed"
GroupBuffs.debug.informationGathering.effectName[345] = "Quick Cloak"
GroupBuffs.debug.informationGathering.effectName[346] = "Shrouded Daggers"
GroupBuffs.debug.informationGathering.effectName[347] = "Rend"
GroupBuffs.debug.informationGathering.effectName[348] = "Blood Craze Bleed"
GroupBuffs.debug.informationGathering.effectName[349] = "Deadly Cloak"
GroupBuffs.debug.informationGathering.effectName[350] = "Flying Blade"
GroupBuffs.debug.informationGathering.effectName[351] = "Thrive in Chaos"

--others
GroupBuffs.debug.informationGathering.effectName[352] = "Dodge Fatigue"
GroupBuffs.debug.informationGathering.effectName[353] = "Unstoppable"
GroupBuffs.debug.informationGathering.effectName[354] = "Defiler"
GroupBuffs.debug.informationGathering.effectName[355] = "Increased Experience"
GroupBuffs.debug.informationGathering.effectName[356] = "Fetcher Infection Bonus Damage"
GroupBuffs.debug.informationGathering.effectName[357] = "Melee Snare"
GroupBuffs.debug.informationGathering.effectName[358] = "Heavy Weapons Bleed"


--Other effects
GroupBuffs.debug.informationGathering.effectName[359] = "CC Immunity"
GroupBuffs.debug.informationGathering.effectName[360] = "Vengeance"
GroupBuffs.debug.informationGathering.effectName[361] = "Melee Snare"
GroupBuffs.debug.informationGathering.effectName[362] = "Wrath"
GroupBuffs.debug.informationGathering.effectName[363] = "Ensnare"
GroupBuffs.debug.informationGathering.effectName[364] = "Block"
GroupBuffs.debug.informationGathering.effectName[365] = "The Troll King"
GroupBuffs.debug.informationGathering.effectName[366] = "Burning Spellwaeve"
GroupBuffs.debug.informationGathering.effectName[367] = "Burning" --Something is missing here
GroupBuffs.debug.informationGathering.effectName[368] = "Tri Focus" --Something is missing here
GroupBuffs.debug.informationGathering.effectName[369] = "Intercept" --Something is missing here
GroupBuffs.debug.informationGathering.effectName[370] = "Stun After Knockback Movement"
GroupBuffs.debug.informationGathering.effectName[371] = "Weapon Damage Enchantment"
GroupBuffs.debug.informationGathering.effectName[372] = "Poisoned"
GroupBuffs.debug.informationGathering.effectName[373] = "Empower"
GroupBuffs.debug.informationGathering.effectName[374] = "Charge Snare"
GroupBuffs.debug.informationGathering.effectName[375] = "Red Diamond"
GroupBuffs.debug.informationGathering.effectName[376] = "Ebon Armory"

--ww [morhps]
GroupBuffs.debug.informationGathering.effectName[377] = "Sanies Lupinus"
GroupBuffs.debug.informationGathering.effectName[378] = "Hircine's Rage"
GroupBuffs.debug.informationGathering.effectName[379] = "Sacred Ground"
GroupBuffs.debug.informationGathering.effectName[380] = "Ferocious Roar"
GroupBuffs.debug.informationGathering.effectName[381] = "Howl of Despair Stun"
GroupBuffs.debug.informationGathering.effectName[382] = "Hircine's Fortitude"
GroupBuffs.debug.informationGathering.effectName[383] = "Rousing Roar"
GroupBuffs.debug.informationGathering.effectName[384] = "Howl of Agony Bonus"
GroupBuffs.debug.informationGathering.effectName[385] = "Piercing Howl Stun"

--vamp [morphs]
GroupBuffs.debug.informationGathering.effectName[386] = "Invigorating Drain"
GroupBuffs.debug.informationGathering.effectName[387] = "Elusive Mist"
GroupBuffs.debug.informationGathering.effectName[388] = "Clouding Swarm"
GroupBuffs.debug.informationGathering.effectName[389] = "Accelerating Drain"
GroupBuffs.debug.informationGathering.effectName[390] = "Baleful Mist"
GroupBuffs.debug.informationGathering.effectName[391] = "Devouring Swarm"

--templar [heal]
GroupBuffs.debug.informationGathering.effectName[392] = "Honor The Dead"


--heal
GroupBuffs.debug.informationGathering.effectName[393] = "Regeneration"
GroupBuffs.debug.informationGathering.effectName[394] = "Steadfast Ward"
GroupBuffs.debug.informationGathering.effectName[395] = "Panacea"
GroupBuffs.debug.informationGathering.effectName[396] = "Rapid Regeneration"
GroupBuffs.debug.informationGathering.effectName[397] = "Ward Ally"
GroupBuffs.debug.informationGathering.effectName[398] = "Life Giver"
GroupBuffs.debug.informationGathering.effectName[399] = "Mutagen"
GroupBuffs.debug.informationGathering.effectName[400] = "Healing Ward"
GroupBuffs.debug.informationGathering.effectName[401] = "Light's Champion"


--others
GroupBuffs.debug.informationGathering.effectName[402] = "Bonus vs off balance"
GroupBuffs.debug.informationGathering.effectName[403] = "Nip"
GroupBuffs.debug.informationGathering.effectName[404] = "Lunge"
GroupBuffs.debug.informationGathering.effectName[405] = "Harry"
GroupBuffs.debug.informationGathering.effectName[406] = "Taunt"
GroupBuffs.debug.informationGathering.effectName[407] = "Infection"
GroupBuffs.debug.informationGathering.effectName[408] = "Twice-Fanged Serpent"
GroupBuffs.debug.informationGathering.effectName[409] = "Off Balance"
GroupBuffs.debug.informationGathering.effectName[410] = "The Troll King"
GroupBuffs.debug.informationGathering.effectName[411] = "Robes of Transmutation"
GroupBuffs.debug.informationGathering.effectName[412] = "Obliterate"
GroupBuffs.debug.informationGathering.effectName[413] = "Shatter"

--Minor / Major
GroupBuffs.debug.informationGathering.effectName[414] = "Major Berserk"
GroupBuffs.debug.informationGathering.effectName[415] = "Major Breach"
GroupBuffs.debug.informationGathering.effectName[416] = "Major Brutality"
GroupBuffs.debug.informationGathering.effectName[417] = "Major Defile"
GroupBuffs.debug.informationGathering.effectName[418] = "Major Endurance"
GroupBuffs.debug.informationGathering.effectName[419] = "Major Evasion"
GroupBuffs.debug.informationGathering.effectName[420] = "Major Expedition"
GroupBuffs.debug.informationGathering.effectName[421] = "Major Force"
GroupBuffs.debug.informationGathering.effectName[422] = "Major Fortitude"
GroupBuffs.debug.informationGathering.effectName[423] = "Major Fracture"
GroupBuffs.debug.informationGathering.effectName[424] = "Major Heroism"
GroupBuffs.debug.informationGathering.effectName[425] = "Major Intellect"
GroupBuffs.debug.informationGathering.effectName[426] = "Major Mending"
GroupBuffs.debug.informationGathering.effectName[427] = "Major Prophecy"
GroupBuffs.debug.informationGathering.effectName[428] = "Major Protection"
GroupBuffs.debug.informationGathering.effectName[429] = "Major Resolve"
GroupBuffs.debug.informationGathering.effectName[430] = "Major Savagery"
GroupBuffs.debug.informationGathering.effectName[431] = "Major Sorcery"
GroupBuffs.debug.informationGathering.effectName[432] = "Major Spell Shatter"
GroupBuffs.debug.informationGathering.effectName[433] = "Major Vitality"
GroupBuffs.debug.informationGathering.effectName[434] = "Major Ward"
GroupBuffs.debug.informationGathering.effectName[435] = "Minor Berserk"
GroupBuffs.debug.informationGathering.effectName[436] = "Minor Breach"
GroupBuffs.debug.informationGathering.effectName[437] = "Minor Brutality"
GroupBuffs.debug.informationGathering.effectName[438] = "Minor Cowardice"
GroupBuffs.debug.informationGathering.effectName[439] = "Minor Defile"
GroupBuffs.debug.informationGathering.effectName[440] = "Minor Endurance"
GroupBuffs.debug.informationGathering.effectName[441] = "Minor Enervation"
GroupBuffs.debug.informationGathering.effectName[442] = "Minor Expedition"
GroupBuffs.debug.informationGathering.effectName[443] = "Minor Force"
GroupBuffs.debug.informationGathering.effectName[444] = "Minor Fracture"
GroupBuffs.debug.informationGathering.effectName[445] = "Minor Heroism"
GroupBuffs.debug.informationGathering.effectName[446] = "Minor Intellect"
GroupBuffs.debug.informationGathering.effectName[447] = "Minor Lifesteal"
GroupBuffs.debug.informationGathering.effectName[448] = "Minor Magickasteal"
GroupBuffs.debug.informationGathering.effectName[449] = "Minor Maim"
GroupBuffs.debug.informationGathering.effectName[450] = "Minor Mangle"
GroupBuffs.debug.informationGathering.effectName[451] = "Minor Prophecy"
GroupBuffs.debug.informationGathering.effectName[452] = "Minor Protection"
GroupBuffs.debug.informationGathering.effectName[453] = "Minor Resolve"
GroupBuffs.debug.informationGathering.effectName[454] = "Minor Savagery"
GroupBuffs.debug.informationGathering.effectName[455] = "Minor Sorcery"
GroupBuffs.debug.informationGathering.effectName[456] = "Minor Uncertainty"
GroupBuffs.debug.informationGathering.effectName[457] = "Minor Vitality"
GroupBuffs.debug.informationGathering.effectName[458] = "Minor Vulnerability"
GroupBuffs.debug.informationGathering.effectName[459] = "Minor Ward"
GroupBuffs.debug.informationGathering.effectName[460] = "Minor Wound"

--failed previously
GroupBuffs.debug.informationGathering.effectName[461] = "Suppression Field"
GroupBuffs.debug.informationGathering.effectName[462] = "Absorption Field"

--1.0.3
GroupBuffs.debug.informationGathering.effectName[463] = "Spell Power Cure"

--1.0.4
GroupBuffs.debug.informationGathering.effectName[464] = "Enervating Seal"

GroupBuffs.debug.informationGathering.effectName[465] = "Ruthless Salvo Bleed"
GroupBuffs.debug.informationGathering.effectName[466] = "Lunar Flare"

GroupBuffs.debug.informationGathering.effectName[467] = "Sickening Poison"
GroupBuffs.debug.informationGathering.effectName[468] = "Delirium Poison"
GroupBuffs.debug.informationGathering.effectName[469] = "Enfeebling Poison"

GroupBuffs.debug.informationGathering.effectName[470] = "Power Leech"
GroupBuffs.debug.informationGathering.effectName[471] = "Melting Point"
GroupBuffs.debug.informationGathering.effectName[472] = "Phlebotomize"
GroupBuffs.debug.informationGathering.effectName[473] = "Gaping Wound"
GroupBuffs.debug.informationGathering.effectName[474] = "Greater Defile"
GroupBuffs.debug.informationGathering.effectName[475] = "Venom Injection"

GroupBuffs.debug.informationGathering.effectName[476] = "Overheated"
GroupBuffs.debug.informationGathering.effectName[477] = "Defiled"
GroupBuffs.debug.informationGathering.effectName[478] = "Trial by Fire"

--1.0.5
GroupBuffs.debug.informationGathering.effectName[479] = "Witchmother's Brew"
GroupBuffs.debug.informationGathering.effectName[480] = "Witchmother's Boon"

--1.0.6
GroupBuffs.debug.informationGathering.effectName[481] = "Powerful Assault"

--1.0.7
GroupBuffs.debug.informationGathering.effectName[482] = "Shattering Strike"
GroupBuffs.debug.informationGathering.effectName[483] = "Armor Shattered"

--1.3.1
GroupBuffs.debug.informationGathering.effectName[484] = "Minor Courage"
GroupBuffs.debug.informationGathering.effectName[485] = "Major Courage"
GroupBuffs.debug.informationGathering.effectName[486] = "Efficient Purge"
GroupBuffs.debug.informationGathering.effectName[487] = "Sturdy Horn"
--1.3.3
GroupBuffs.debug.informationGathering.effectName[488] = "Hawk Eye"
GroupBuffs.debug.informationGathering.effectName[489] = "Meritorious Service"

--1.3.5
GroupBuffs.debug.informationGathering.effectName[490] = "Minor Toughness"

--1.3.8
GroupBuffs.debug.informationGathering.effectName[491] = "Meridia's Favor"

--1.3.9
GroupBuffs.debug.informationGathering.effectName[492] = "Dark Conversion"
GroupBuffs.debug.informationGathering.effectName[493] = "Dark Deal"
GroupBuffs.debug.informationGathering.effectName[494] = "Dark Exchange"

--1.3.14
GroupBuffs.debug.informationGathering.effectName[495] = "Grave Guardian"
GroupBuffs.debug.informationGathering.effectName[496] = "Warming Aura"

--1.4.1
GroupBuffs.debug.informationGathering.effectName[497] = "Radiating Regeneration"

--1.5.1
GroupBuffs.debug.informationGathering.effectName[498] = "Minor Slayer"
GroupBuffs.debug.informationGathering.effectName[499] = "Major Slayer"

--1.5.5
GroupBuffs.debug.informationGathering.effectName[500] = "Twilight Remedy"
GroupBuffs.debug.informationGathering.effectName[501] = "Brands of Imperium"
GroupBuffs.debug.informationGathering.effectName[502] = "Ursus's Blessing"

--1.5.6
GroupBuffs.debug.informationGathering.effectName[503] = "Spinal Surge"
GroupBuffs.debug.informationGathering.effectName[504] = "Bone Wall"

--1.5.10
GroupBuffs.debug.informationGathering.effectName[505] = "Aura of Pride"
GroupBuffs.debug.informationGathering.effectName[506] = "Unstable Frost Shield"
GroupBuffs.debug.informationGathering.effectName[507] = "Frost Shield"
GroupBuffs.debug.informationGathering.effectName[508] = "Frost Safeguard"

--1.5.11
GroupBuffs.debug.informationGathering.effectName[509] = "Plague Carrier"

--1.5.14
GroupBuffs.debug.informationGathering.effectName[510] = "Minor Evasion"

--1.5.15
GroupBuffs.debug.informationGathering.effectName[511] = "Behemoth's Aura"
GroupBuffs.debug.informationGathering.effectName[512] = "Behemoth Resilience"
GroupBuffs.debug.informationGathering.effectName[513] = "Rallying Cry"
GroupBuffs.debug.informationGathering.effectName[514] = "Pearlescent Ward"
GroupBuffs.debug.informationGathering.effectName[515] = "Sanctuary"
GroupBuffs.debug.informationGathering.effectName[516] = "Hircine's Veneer"
GroupBuffs.debug.informationGathering.effectName[517] = "Worm's Raiment"
GroupBuffs.debug.informationGathering.effectName[518] = "Gibbering Shield"
GroupBuffs.debug.informationGathering.effectName[519] = "Gibbering Shelter"
GroupBuffs.debug.informationGathering.effectName[520] = "Sanctum of the Abyssal Sea"

--1.5.16
GroupBuffs.debug.informationGathering.effectName[521] = "Aura of Pride"
GroupBuffs.debug.informationGathering.effectName[522] = "Combat Physician"
GroupBuffs.debug.informationGathering.effectName[523] = "From the Brink"

--1.5.17
GroupBuffs.debug.informationGathering.effectName[524] = "Nibenay Bay Battlereeve"

--1.5.18
GroupBuffs.debug.informationGathering.effectName[525] = "Vampire Stage 1"
GroupBuffs.debug.informationGathering.effectName[526] = "Vampire Stage 2"
GroupBuffs.debug.informationGathering.effectName[527] = "Vampire Stage 3"
GroupBuffs.debug.informationGathering.effectName[528] = "Vampire Stage 4"

--1.5.19
GroupBuffs.debug.informationGathering.effectName[529] = "Pillager's Profit"

--ByID
--Sorc
GroupBuffs.debug.informationGathering.id[1] = 47553
GroupBuffs.debug.informationGathering.id[2] = 46332
GroupBuffs.debug.informationGathering.id[3] = 47570
GroupBuffs.debug.informationGathering.id[4] = 30087
GroupBuffs.debug.informationGathering.id[5] = 28308
GroupBuffs.debug.informationGathering.id[6] = 28311
GroupBuffs.debug.informationGathering.id[7] = 24559
GroupBuffs.debug.informationGathering.id[8] = nil
GroupBuffs.debug.informationGathering.id[9] = nil
GroupBuffs.debug.informationGathering.id[10] = 29917
GroupBuffs.debug.informationGathering.id[11] = 28452
GroupBuffs.debug.informationGathering.id[12] = 29982
GroupBuffs.debug.informationGathering.id[13] = 47158
GroupBuffs.debug.informationGathering.id[14] = nil --Empty by Design

GroupBuffs.debug.informationGathering.id[15] = 30641
GroupBuffs.debug.informationGathering.id[16] = 30652
GroupBuffs.debug.informationGathering.id[17] = 23316
GroupBuffs.debug.informationGathering.id[18] = 30499
GroupBuffs.debug.informationGathering.id[19] = 24328
GroupBuffs.debug.informationGathering.id[20] = 30523
GroupBuffs.debug.informationGathering.id[21] = 30587
GroupBuffs.debug.informationGathering.id[22] = 30598
GroupBuffs.debug.informationGathering.id[23] = 24639
GroupBuffs.debug.informationGathering.id[24] = 30463
GroupBuffs.debug.informationGathering.id[25] = 30474
GroupBuffs.debug.informationGathering.id[26] = 29482
GroupBuffs.debug.informationGathering.id[27] = 30418
GroupBuffs.debug.informationGathering.id[28] = 24165
GroupBuffs.debug.informationGathering.id[29] = 30445
GroupBuffs.debug.informationGathering.id[30] = 80462
GroupBuffs.debug.informationGathering.id[31] = 26098

GroupBuffs.debug.informationGathering.id[32] = 80012
GroupBuffs.debug.informationGathering.id[33] = 30333
GroupBuffs.debug.informationGathering.id[34] = 19118
GroupBuffs.debug.informationGathering.id[35] = 30235
GroupBuffs.debug.informationGathering.id[36] = 23231
GroupBuffs.debug.informationGathering.id[37] = 30255
GroupBuffs.debug.informationGathering.id[38] = 30390
GroupBuffs.debug.informationGathering.id[39] = 30396
GroupBuffs.debug.informationGathering.id[40] = 23678
GroupBuffs.debug.informationGathering.id[41] = 30206
GroupBuffs.debug.informationGathering.id[42] = 80012
GroupBuffs.debug.informationGathering.id[43] = 30226
GroupBuffs.debug.informationGathering.id[44] = 30354
GroupBuffs.debug.informationGathering.id[45] = 24806
GroupBuffs.debug.informationGathering.id[46] = 30381
--Destro
GroupBuffs.debug.informationGathering.id[47] = 62983
GroupBuffs.debug.informationGathering.id[48] = nil --verify effect
GroupBuffs.debug.informationGathering.id[49] = nil --Empty by Design
GroupBuffs.debug.informationGathering.id[50] = 68359
GroupBuffs.debug.informationGathering.id[51] = 62859
GroupBuffs.debug.informationGathering.id[52] = nil --Empty by Design
GroupBuffs.debug.informationGathering.id[53] = 62712
GroupBuffs.debug.informationGathering.id[54] = 38971
GroupBuffs.debug.informationGathering.id[55] = 62682
GroupBuffs.debug.informationGathering.id[56] = 62731
GroupBuffs.debug.informationGathering.id[57] = 62701
GroupBuffs.debug.informationGathering.id[58] = 62665
GroupBuffs.debug.informationGathering.id[59] = 62733
GroupBuffs.debug.informationGathering.id[60] = 62702
GroupBuffs.debug.informationGathering.id[61] = 62745
GroupBuffs.debug.informationGathering.id[62] = 38990
GroupBuffs.debug.informationGathering.id[63] = 87309
GroupBuffs.debug.informationGathering.id[64] = 86540
GroupBuffs.debug.informationGathering.id[65] = 86546
GroupBuffs.debug.informationGathering.id[66] = 86552
GroupBuffs.debug.informationGathering.id[67] = 63003
--Resto

--DK
GroupBuffs.debug.informationGathering.id[68] = 45016
GroupBuffs.debug.informationGathering.id[69] = 44368
GroupBuffs.debug.informationGathering.id[70] = 44372
GroupBuffs.debug.informationGathering.id[71] = 44376
GroupBuffs.debug.informationGathering.id[72] = 34032
GroupBuffs.debug.informationGathering.id[73] = 34041
GroupBuffs.debug.informationGathering.id[74] = 34050
GroupBuffs.debug.informationGathering.id[75] = 34061
GroupBuffs.debug.informationGathering.id[76] = 34080
GroupBuffs.debug.informationGathering.id[77] = 32881

GroupBuffs.debug.informationGathering.id[78] = 23828
GroupBuffs.debug.informationGathering.id[79] = 23856
GroupBuffs.debug.informationGathering.id[80] = 23842
GroupBuffs.debug.informationGathering.id[81] = 32113
GroupBuffs.debug.informationGathering.id[82] = 32125
GroupBuffs.debug.informationGathering.id[83] = 20528
GroupBuffs.debug.informationGathering.id[84] = 33743
GroupBuffs.debug.informationGathering.id[85] = 33745
GroupBuffs.debug.informationGathering.id[86] = 33759
GroupBuffs.debug.informationGathering.id[87] = 80195
GroupBuffs.debug.informationGathering.id[88] = 18032
GroupBuffs.debug.informationGathering.id[89] = 33680

GroupBuffs.debug.informationGathering.id[90] = 32195
GroupBuffs.debug.informationGathering.id[91] = 32202
GroupBuffs.debug.informationGathering.id[92] = 32211
GroupBuffs.debug.informationGathering.id[93] = 76549
GroupBuffs.debug.informationGathering.id[94] = 33866
GroupBuffs.debug.informationGathering.id[95] = 33872
GroupBuffs.debug.informationGathering.id[96] = 33881
GroupBuffs.debug.informationGathering.id[97] = 33898
GroupBuffs.debug.informationGathering.id[98] = 33921
GroupBuffs.debug.informationGathering.id[99] = 32678
GroupBuffs.debug.informationGathering.id[100] = 33780
GroupBuffs.debug.informationGathering.id[101] = 33800
GroupBuffs.debug.informationGathering.id[102] = 32712
GroupBuffs.debug.informationGathering.id[103] = 19982
GroupBuffs.debug.informationGathering.id[104] = 33838
GroupBuffs.debug.informationGathering.id[105] = 33852


--templar
GroupBuffs.debug.informationGathering.id[106] = 76911
GroupBuffs.debug.informationGathering.id[107] = 26976
GroupBuffs.debug.informationGathering.id[108] = 27504
GroupBuffs.debug.informationGathering.id[109] = 62596
GroupBuffs.debug.informationGathering.id[110] = 76915
GroupBuffs.debug.informationGathering.id[111] = 26985
GroupBuffs.debug.informationGathering.id[112] = 27517
GroupBuffs.debug.informationGathering.id[113] = 23800
GroupBuffs.debug.informationGathering.id[114] = 76911
GroupBuffs.debug.informationGathering.id[115] = 26994
GroupBuffs.debug.informationGathering.id[116] = 23873
GroupBuffs.debug.informationGathering.id[117] = 49097
GroupBuffs.debug.informationGathering.id[118] = 62613

GroupBuffs.debug.informationGathering.id[119] = 24173
GroupBuffs.debug.informationGathering.id[120] = 27227
GroupBuffs.debug.informationGathering.id[121] = 27306
GroupBuffs.debug.informationGathering.id[122] = 68709
GroupBuffs.debug.informationGathering.id[123] = 63058
GroupBuffs.debug.informationGathering.id[124] = 24064
GroupBuffs.debug.informationGathering.id[125] = 24182
GroupBuffs.debug.informationGathering.id[126] = 27558
GroupBuffs.debug.informationGathering.id[127] = 27324
GroupBuffs.debug.informationGathering.id[128] = 68756
GroupBuffs.debug.informationGathering.id[129] = 63066
GroupBuffs.debug.informationGathering.id[130] = 24302
GroupBuffs.debug.informationGathering.id[131] = 24197
GroupBuffs.debug.informationGathering.id[132] = 27587
GroupBuffs.debug.informationGathering.id[133] = 27311
GroupBuffs.debug.informationGathering.id[134] = 63075
GroupBuffs.debug.informationGathering.id[135] = 24325

--warden
GroupBuffs.debug.informationGathering.id[136] = 85577
GroupBuffs.debug.informationGathering.id[137] = 93877
GroupBuffs.debug.informationGathering.id[138] = 93908
GroupBuffs.debug.informationGathering.id[139] = 93945
GroupBuffs.debug.informationGathering.id[140] = 93593
GroupBuffs.debug.informationGathering.id[141] = 86026
GroupBuffs.debug.informationGathering.id[142] = 86053
GroupBuffs.debug.informationGathering.id[143] = 85985
GroupBuffs.debug.informationGathering.id[144] = 92913
GroupBuffs.debug.informationGathering.id[145] = 93880
GroupBuffs.debug.informationGathering.id[146] = 93911
GroupBuffs.debug.informationGathering.id[147] = 93791
GroupBuffs.debug.informationGathering.id[148] = 86030
GroupBuffs.debug.informationGathering.id[149] = 86057
GroupBuffs.debug.informationGathering.id[150] = 85989
GroupBuffs.debug.informationGathering.id[151] = 89129
GroupBuffs.debug.informationGathering.id[152] = 92902
GroupBuffs.debug.informationGathering.id[153] = 93883
GroupBuffs.debug.informationGathering.id[154] = 93914
GroupBuffs.debug.informationGathering.id[155] = 93964
GroupBuffs.debug.informationGathering.id[156] = 94001
GroupBuffs.debug.informationGathering.id[157] = 93778
GroupBuffs.debug.informationGathering.id[158] = 86034
GroupBuffs.debug.informationGathering.id[159] = 86061
GroupBuffs.debug.informationGathering.id[160] = 85993
GroupBuffs.debug.informationGathering.id[161] = 94643

GroupBuffs.debug.informationGathering.id[162] = 94071
GroupBuffs.debug.informationGathering.id[163] = 94038
GroupBuffs.debug.informationGathering.id[164] = 86138
GroupBuffs.debug.informationGathering.id[165] = 94269
GroupBuffs.debug.informationGathering.id[166] = 94191
GroupBuffs.debug.informationGathering.id[167] = 94092
GroupBuffs.debug.informationGathering.id[168] = 94056
GroupBuffs.debug.informationGathering.id[169] = 86142
GroupBuffs.debug.informationGathering.id[170] = 94292
GroupBuffs.debug.informationGathering.id[171] = 94202
GroupBuffs.debug.informationGathering.id[172] = 94100
GroupBuffs.debug.informationGathering.id[173] = 94048
GroupBuffs.debug.informationGathering.id[174] = 86146
GroupBuffs.debug.informationGathering.id[175] = 94324
GroupBuffs.debug.informationGathering.id[176] = 86120

--nightblade
GroupBuffs.debug.informationGathering.id[177] = 37603
GroupBuffs.debug.informationGathering.id[178] = 62096
GroupBuffs.debug.informationGathering.id[179] = 61392
GroupBuffs.debug.informationGathering.id[180] = 36340
GroupBuffs.debug.informationGathering.id[181] = 38065
GroupBuffs.debug.informationGathering.id[182] = 37698
GroupBuffs.debug.informationGathering.id[183] = 45483
GroupBuffs.debug.informationGathering.id[184] = 35885
GroupBuffs.debug.informationGathering.id[185] = 37631
GroupBuffs.debug.informationGathering.id[186] = 62107
GroupBuffs.debug.informationGathering.id[187] = 37536
GroupBuffs.debug.informationGathering.id[188] = 62141
GroupBuffs.debug.informationGathering.id[189] = 36373
GroupBuffs.debug.informationGathering.id[190] = 38075
GroupBuffs.debug.informationGathering.id[191] = 37746
GroupBuffs.debug.informationGathering.id[192] = 35932
GroupBuffs.debug.informationGathering.id[193] = 76425
GroupBuffs.debug.informationGathering.id[194] = 37870
GroupBuffs.debug.informationGathering.id[195] = 37977
GroupBuffs.debug.informationGathering.id[196] = 36170
GroupBuffs.debug.informationGathering.id[197] = 35943
GroupBuffs.debug.informationGathering.id[198] = 76432
GroupBuffs.debug.informationGathering.id[199] = 37894
GroupBuffs.debug.informationGathering.id[200] = 38015
GroupBuffs.debug.informationGathering.id[201] = 37658
GroupBuffs.debug.informationGathering.id[202] = 62117
GroupBuffs.debug.informationGathering.id[203] = 61403
GroupBuffs.debug.informationGathering.id[204] = 36355
GroupBuffs.debug.informationGathering.id[205] = 64027
GroupBuffs.debug.informationGathering.id[206] = 76666
GroupBuffs.debug.informationGathering.id[207] = 51558
GroupBuffs.debug.informationGathering.id[208] = 37715
GroupBuffs.debug.informationGathering.id[209] = 35950
GroupBuffs.debug.informationGathering.id[210] = 76406
GroupBuffs.debug.informationGathering.id[211] = 37921
GroupBuffs.debug.informationGathering.id[212] = 38050
GroupBuffs.debug.informationGathering.id[213] = 36207


--fighters guild
GroupBuffs.debug.informationGathering.id[214] = 42657
GroupBuffs.debug.informationGathering.id[215] = 42610
GroupBuffs.debug.informationGathering.id[216] = 42724
GroupBuffs.debug.informationGathering.id[217] = 62309
GroupBuffs.debug.informationGathering.id[218] = 42675
GroupBuffs.debug.informationGathering.id[219] = 42624
GroupBuffs.debug.informationGathering.id[220] = 42752
GroupBuffs.debug.informationGathering.id[221] = 62313
GroupBuffs.debug.informationGathering.id[222] = 42699
GroupBuffs.debug.informationGathering.id[223] = 42641
GroupBuffs.debug.informationGathering.id[224] = 42773
GroupBuffs.debug.informationGathering.id[225] = 93877
GroupBuffs.debug.informationGathering.id[226] = 42600

--mage guild
GroupBuffs.debug.informationGathering.id[227] = 42418
GroupBuffs.debug.informationGathering.id[228] = 43029
GroupBuffs.debug.informationGathering.id[229] = 48135
GroupBuffs.debug.informationGathering.id[230] = 18032
GroupBuffs.debug.informationGathering.id[231] = 42430
GroupBuffs.debug.informationGathering.id[232] = 86699
GroupBuffs.debug.informationGathering.id[233] = 43036
GroupBuffs.debug.informationGathering.id[234] = 42334
GroupBuffs.debug.informationGathering.id[235] = 48140
GroupBuffs.debug.informationGathering.id[236] = 42480
GroupBuffs.debug.informationGathering.id[237] = 42455
GroupBuffs.debug.informationGathering.id[238] = 43041
GroupBuffs.debug.informationGathering.id[239] = 42351
GroupBuffs.debug.informationGathering.id[240] = 48144


--undaunted
GroupBuffs.debug.informationGathering.id[241] = 80100
GroupBuffs.debug.informationGathering.id[242] = 43310
GroupBuffs.debug.informationGathering.id[243] = 43367
GroupBuffs.debug.informationGathering.id[244] = 80122
GroupBuffs.debug.informationGathering.id[245] = 43382
GroupBuffs.debug.informationGathering.id[246] = 43323
GroupBuffs.debug.informationGathering.id[247] = 80144
GroupBuffs.debug.informationGathering.id[248] = 43397
GroupBuffs.debug.informationGathering.id[249] = 43334

--vampire
GroupBuffs.debug.informationGathering.id[250] = 35771
GroupBuffs.debug.informationGathering.id[251] = 35776
GroupBuffs.debug.informationGathering.id[252] = 35783
GroupBuffs.debug.informationGathering.id[253] = 35792
GroupBuffs.debug.informationGathering.id[254] = 32893
GroupBuffs.debug.informationGathering.id[255] = 32986
GroupBuffs.debug.informationGathering.id[256] = 32624

--ww
GroupBuffs.debug.informationGathering.id[257] = 35658
GroupBuffs.debug.informationGathering.id[258] = 46142
GroupBuffs.debug.informationGathering.id[259] = 45823
GroupBuffs.debug.informationGathering.id[260] = 45821
GroupBuffs.debug.informationGathering.id[261] = 58406
GroupBuffs.debug.informationGathering.id[262] = 58856
GroupBuffs.debug.informationGathering.id[263] = 89146


--alliance support
GroupBuffs.debug.informationGathering.id[264] = 46654
GroupBuffs.debug.informationGathering.id[265] = 46631
GroupBuffs.debug.informationGathering.id[266] = 63318
GroupBuffs.debug.informationGathering.id[267] = 63376
GroupBuffs.debug.informationGathering.id[268] = 46609
GroupBuffs.debug.informationGathering.id[269] = 46662
GroupBuffs.debug.informationGathering.id[270] = 63397
GroupBuffs.debug.informationGathering.id[271] = 46614
GroupBuffs.debug.informationGathering.id[272] = 46615
GroupBuffs.debug.informationGathering.id[273] = 63335
GroupBuffs.debug.informationGathering.id[274] = 63351
GroupBuffs.debug.informationGathering.id[275] = 46672
GroupBuffs.debug.informationGathering.id[276] = 46644
GroupBuffs.debug.informationGathering.id[277] = 63422
GroupBuffs.debug.informationGathering.id[278] = 63421
GroupBuffs.debug.informationGathering.id[279] = 46622
GroupBuffs.debug.informationGathering.id[280] = 46519
GroupBuffs.debug.informationGathering.id[281] = 63257
GroupBuffs.debug.informationGathering.id[282] = 63302

--aliance assault
GroupBuffs.debug.informationGathering.id[283] = 46492
GroupBuffs.debug.informationGathering.id[284] = 63241
GroupBuffs.debug.informationGathering.id[285] = 64118
GroupBuffs.debug.informationGathering.id[286] = 63284
GroupBuffs.debug.informationGathering.id[287] = 46530
GroupBuffs.debug.informationGathering.id[288] = 46505
GroupBuffs.debug.informationGathering.id[289] = 63248
GroupBuffs.debug.informationGathering.id[290] = 63293
GroupBuffs.debug.informationGathering.id[291] = 46538

--armor
GroupBuffs.debug.informationGathering.id[292] = 41108
GroupBuffs.debug.informationGathering.id[293] = 63018
GroupBuffs.debug.informationGathering.id[294] = 63115
GroupBuffs.debug.informationGathering.id[295] = 41113
GroupBuffs.debug.informationGathering.id[296] = 63027
GroupBuffs.debug.informationGathering.id[297] = 63142
GroupBuffs.debug.informationGathering.id[298] = 41121
GroupBuffs.debug.informationGathering.id[299] = 63042
GroupBuffs.debug.informationGathering.id[300] = 63130

--soul magic
GroupBuffs.debug.informationGathering.id[301] = 43056
GroupBuffs.debug.informationGathering.id[302] = 43067
GroupBuffs.debug.informationGathering.id[303] = 43083

--bow
GroupBuffs.debug.informationGathering.id[304] = 40859
GroupBuffs.debug.informationGathering.id[305] = 40766
GroupBuffs.debug.informationGathering.id[306] = 44544
GroupBuffs.debug.informationGathering.id[307] = 44548
GroupBuffs.debug.informationGathering.id[308] = 62587
GroupBuffs.debug.informationGathering.id[309] = 40887
GroupBuffs.debug.informationGathering.id[310] = 40792
GroupBuffs.debug.informationGathering.id[311] = 44552

--2h
GroupBuffs.debug.informationGathering.id[312] = 72813
GroupBuffs.debug.informationGathering.id[313] = 39747
GroupBuffs.debug.informationGathering.id[314] = 39881
GroupBuffs.debug.informationGathering.id[315] = 86276
GroupBuffs.debug.informationGathering.id[316] = 39987
GroupBuffs.debug.informationGathering.id[317] = 39809
GroupBuffs.debug.informationGathering.id[318] = 39755
GroupBuffs.debug.informationGathering.id[319] = 86285
GroupBuffs.debug.informationGathering.id[320] = 41405
GroupBuffs.debug.informationGathering.id[321] = 41358
GroupBuffs.debug.informationGathering.id[322] = 41529
GroupBuffs.debug.informationGathering.id[323] = 83449
GroupBuffs.debug.informationGathering.id[324] = 86333
GroupBuffs.debug.informationGathering.id[325] = 39770
GroupBuffs.debug.informationGathering.id[326] = 39904
GroupBuffs.debug.informationGathering.id[327] = 86296
GroupBuffs.debug.informationGathering.id[328] = 39892

--sb
GroupBuffs.debug.informationGathering.id[329] = 41396
GroupBuffs.debug.informationGathering.id[330] = 41351
GroupBuffs.debug.informationGathering.id[331] = 83445
GroupBuffs.debug.informationGathering.id[332] = 86322
GroupBuffs.debug.informationGathering.id[333] = 41417
GroupBuffs.debug.informationGathering.id[334] = 72821
GroupBuffs.debug.informationGathering.id[335] = 41380
GroupBuffs.debug.informationGathering.id[336] = 41541
GroupBuffs.debug.informationGathering.id[337] = 86345
GroupBuffs.debug.informationGathering.id[338] = 41405

--dw
GroupBuffs.debug.informationGathering.id[339] = 73024
GroupBuffs.debug.informationGathering.id[340] = 40666
GroupBuffs.debug.informationGathering.id[341] = 40633
GroupBuffs.debug.informationGathering.id[342] = 40611
GroupBuffs.debug.informationGathering.id[343] = 86373
GroupBuffs.debug.informationGathering.id[344] = 40678
GroupBuffs.debug.informationGathering.id[345] = 40642
GroupBuffs.debug.informationGathering.id[346] = 40620
GroupBuffs.debug.informationGathering.id[347] = 86396
GroupBuffs.debug.informationGathering.id[348] = 40690
GroupBuffs.debug.informationGathering.id[349] = 40651
GroupBuffs.debug.informationGathering.id[350] = 40629
GroupBuffs.debug.informationGathering.id[351] = 86414

--others
GroupBuffs.debug.informationGathering.id[352] = 69143
GroupBuffs.debug.informationGathering.id[353] = 86698
GroupBuffs.debug.informationGathering.id[354] = 93305
GroupBuffs.debug.informationGathering.id[355] = 64210
GroupBuffs.debug.informationGathering.id[356] = 93648
GroupBuffs.debug.informationGathering.id[357] = 16593
GroupBuffs.debug.informationGathering.id[358] = 45431

--Other effects
GroupBuffs.debug.informationGathering.id[359] = 38117
GroupBuffs.debug.informationGathering.id[360] = 63152
GroupBuffs.debug.informationGathering.id[361] = 16593
GroupBuffs.debug.informationGathering.id[362] = 80012
GroupBuffs.debug.informationGathering.id[363] = 60402
GroupBuffs.debug.informationGathering.id[364] = 14890
GroupBuffs.debug.informationGathering.id[365] = 80504
GroupBuffs.debug.informationGathering.id[366] = 61459
GroupBuffs.debug.informationGathering.id[367] = 18084
GroupBuffs.debug.informationGathering.id[368] = 69773
GroupBuffs.debug.informationGathering.id[369] = 23284
GroupBuffs.debug.informationGathering.id[370] = 62667
GroupBuffs.debug.informationGathering.id[371] = 21230
GroupBuffs.debug.informationGathering.id[372] = 21929
GroupBuffs.debug.informationGathering.id[373] = 61737
GroupBuffs.debug.informationGathering.id[374] = 48532
GroupBuffs.debug.informationGathering.id[375] = 45294
GroupBuffs.debug.informationGathering.id[376] = 47362
--ww [morhps]
GroupBuffs.debug.informationGathering.id[377] = 40521
GroupBuffs.debug.informationGathering.id[378] = 58320
GroupBuffs.debug.informationGathering.id[379] = 80230
GroupBuffs.debug.informationGathering.id[380] = 45859
GroupBuffs.debug.informationGathering.id[381] = 58792
GroupBuffs.debug.informationGathering.id[382] = 58335
GroupBuffs.debug.informationGathering.id[383] = 45863
GroupBuffs.debug.informationGathering.id[384] = 58806
GroupBuffs.debug.informationGathering.id[385] = 58807

--vamp [morphs]
GroupBuffs.debug.informationGathering.id[386] = 41901
GroupBuffs.debug.informationGathering.id[387] = 41815
GroupBuffs.debug.informationGathering.id[388] = 38932
GroupBuffs.debug.informationGathering.id[389] = 41880
GroupBuffs.debug.informationGathering.id[390] = 38965
GroupBuffs.debug.informationGathering.id[391] = 41937

--templar [heal]
GroupBuffs.debug.informationGathering.id[392] = 35632


--heal
GroupBuffs.debug.informationGathering.id[393] = 41271
GroupBuffs.debug.informationGathering.id[394] = 41310
GroupBuffs.debug.informationGathering.id[395] = 86425
GroupBuffs.debug.informationGathering.id[396] = 41276
GroupBuffs.debug.informationGathering.id[397] = 40130
GroupBuffs.debug.informationGathering.id[398] = 86428
GroupBuffs.debug.informationGathering.id[399] = 41288
GroupBuffs.debug.informationGathering.id[400] = 41320
GroupBuffs.debug.informationGathering.id[401] = 85132


--others
GroupBuffs.debug.informationGathering.id[402] = 15594
GroupBuffs.debug.informationGathering.id[403] = 80188
GroupBuffs.debug.informationGathering.id[404] = 80186
GroupBuffs.debug.informationGathering.id[405] = 85656
GroupBuffs.debug.informationGathering.id[406] = 62201
GroupBuffs.debug.informationGathering.id[407] = 58875
GroupBuffs.debug.informationGathering.id[408] = 51176
GroupBuffs.debug.informationGathering.id[409] = 45861
GroupBuffs.debug.informationGathering.id[410] = 80504
GroupBuffs.debug.informationGathering.id[411] = 76936
GroupBuffs.debug.informationGathering.id[412] = 43742
GroupBuffs.debug.informationGathering.id[413] = 26129


--Minor / Major
GroupBuffs.debug.informationGathering.id[414] = 79200
GroupBuffs.debug.informationGathering.id[415] = 63925
GroupBuffs.debug.informationGathering.id[416] = 62400
GroupBuffs.debug.informationGathering.id[417] = 68163
GroupBuffs.debug.informationGathering.id[418] = 68800
GroupBuffs.debug.informationGathering.id[419] = 63040
GroupBuffs.debug.informationGathering.id[420] = 78081
GroupBuffs.debug.informationGathering.id[421] = 86472
GroupBuffs.debug.informationGathering.id[422] = 72928
GroupBuffs.debug.informationGathering.id[423] = 34734
GroupBuffs.debug.informationGathering.id[424] = 65133
GroupBuffs.debug.informationGathering.id[425] = 62577
GroupBuffs.debug.informationGathering.id[426] = 61760
GroupBuffs.debug.informationGathering.id[427] = 62752
GroupBuffs.debug.informationGathering.id[428] = 44864
GroupBuffs.debug.informationGathering.id[429] = 61825
GroupBuffs.debug.informationGathering.id[430] = 64568
GroupBuffs.debug.informationGathering.id[431] = 62240
GroupBuffs.debug.informationGathering.id[432] = 62786
GroupBuffs.debug.informationGathering.id[433] = 63536
GroupBuffs.debug.informationGathering.id[434] = 61824
GroupBuffs.debug.informationGathering.id[435] = 62636
GroupBuffs.debug.informationGathering.id[436] = 46206
GroupBuffs.debug.informationGathering.id[437] = 61798
GroupBuffs.debug.informationGathering.id[438] = 46202
GroupBuffs.debug.informationGathering.id[439] = 79851
GroupBuffs.debug.informationGathering.id[440] = 62056
GroupBuffs.debug.informationGathering.id[441] = 47203
GroupBuffs.debug.informationGathering.id[442] = 63558
GroupBuffs.debug.informationGathering.id[443] = 68595
GroupBuffs.debug.informationGathering.id[444] = 38688
GroupBuffs.debug.informationGathering.id[445] = 38746
GroupBuffs.debug.informationGathering.id[446] = 77418
GroupBuffs.debug.informationGathering.id[447] = 33541
GroupBuffs.debug.informationGathering.id[448] = 26220
GroupBuffs.debug.informationGathering.id[449] = 29308
GroupBuffs.debug.informationGathering.id[450] = 39168
GroupBuffs.debug.informationGathering.id[451] = 62319
GroupBuffs.debug.informationGathering.id[452] = 3929
GroupBuffs.debug.informationGathering.id[453] = 31818
GroupBuffs.debug.informationGathering.id[454] = 61882
GroupBuffs.debug.informationGathering.id[455] = 62799
GroupBuffs.debug.informationGathering.id[456] = 47204
GroupBuffs.debug.informationGathering.id[457] = 37027
GroupBuffs.debug.informationGathering.id[458] = 51434
GroupBuffs.debug.informationGathering.id[459] = 32761
GroupBuffs.debug.informationGathering.id[460] = 9611

--failed previously
GroupBuffs.debug.informationGathering.id[461] = 47166
GroupBuffs.debug.informationGathering.id[462] = 47168

--1.0.3
GroupBuffs.debug.informationGathering.id[463] = 66902

--1.0.4
GroupBuffs.debug.informationGathering.id[464] = 27748

GroupBuffs.debug.informationGathering.id[465] = 73244
GroupBuffs.debug.informationGathering.id[466] = 73807

GroupBuffs.debug.informationGathering.id[467] = 84221
GroupBuffs.debug.informationGathering.id[468] = 84224
GroupBuffs.debug.informationGathering.id[469] = 84227

GroupBuffs.debug.informationGathering.id[470] = 88041
GroupBuffs.debug.informationGathering.id[471] = 90409
GroupBuffs.debug.informationGathering.id[472] = 90698
GroupBuffs.debug.informationGathering.id[473] = 90854
GroupBuffs.debug.informationGathering.id[474] = 93669
GroupBuffs.debug.informationGathering.id[475] = 95230

GroupBuffs.debug.informationGathering.id[476] = 95430
GroupBuffs.debug.informationGathering.id[477] = 96315
GroupBuffs.debug.informationGathering.id[478] = 101101

--1.0.5

GroupBuffs.debug.informationGathering.id[479] = 96118
GroupBuffs.debug.informationGathering.id[480] = 84369

--1.0.6
GroupBuffs.debug.informationGathering.id[481] = 61771

--1.0.7
GroupBuffs.debug.informationGathering.id[482] = 73249
GroupBuffs.debug.informationGathering.id[483] = 73250



function GroupBuffs.DebugShowSlashCmdOptions() 
	d(GroupBuffs.config.constants.GB_SLASH_CMD_GB_1)
	d(GroupBuffs.config.constants.GB_SLASH_CMD_GB_2)
	d(GroupBuffs.config.constants.GB_SLASH_CMD_GB_3)
end

function GroupBuffs.DebugShowSlashDebugCmdOptions()
	d(GroupBuffs.config.constants.GB_SLASH_CMD_DEBUG_1)
	d(GroupBuffs.config.constants.GB_SLASH_CMD_DEBUG_2)
	d(GroupBuffs.config.constants.GB_SLASH_CMD_DEBUG_3)
	d(GroupBuffs.config.constants.GB_SLASH_CMD_DEBUG_4)
	d(GroupBuffs.config.constants.GB_SLASH_CMD_DEBUG_5)
	d(GroupBuffs.config.constants.GB_SLASH_CMD_DEBUG_6)
end

function GroupBuffs.DebugShowPlayers()
	local groupSize = GetGroupSize()
	if groupSize > 0 then
		for i = 1, groupSize do
			d(string.format("ID: %d, Name: %s", i, GetUnitName(GetGroupUnitTagByIndex(i))))
		end
	else
		d(GroupBuffs.config.constants.GB_SLASH_CMD_ERROR_GROUP)
	end
end

function GroupBuffs.DebugShowPlayerBuffs(index)
	local id = GetGroupUnitTagByIndex(index)
	if id ~= nil then
		local numBuffs = GetNumBuffs(id)
		for i = 1, numBuffs do
			local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo(id , i)    
			d(string.format("%s: %d", buffName, abilityId))
		end
	else
		d(GroupBuffs.config.constants.GB_SLASH_CMD_ERROR_PLAYER_ID)
	end
end

function GroupBuffs.DebugShowAbilityInformation(playerId, abilityId)
	local id = GetGroupUnitTagByIndex(playerId)
	if id ~= nil then
		local numBuffs = GetNumBuffs(id)
		local identifiedBuff = false
		for i = 1, numBuffs do
			local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, aId, canClickOff, castByPlayer = GetUnitBuffInfo(id , i)    
			if abilityId == aId then
				d("---------------------")
				d(string.format("PlayerId: %d", playerId))
				d(string.format("AbilityId: %d", abilityId))
				d(string.format("Name: %s", buffName))
				d(string.format("TimeStarted: %d", timeStarted))
				d(string.format("TimeEnding: %d", timeEnding))
				d(string.format("BuffSlot: %d", buffSlot))
				d(string.format("StackCount: %d", stackCount))
				d(string.format("IconFilename: %s", iconFilename))
				d(string.format("BuffType: %s", buffType))
				d(string.format("EffectType: %d", effectType))
				d(string.format("AbilityType: %d", abilityType))
				d(string.format("StatusEffectType: %d", statusEffectType))
				d(string.format("CanClickOff: %s", tostring(canClickOff)))
				d(string.format("CastByPlayer: %s", tostring(castByPlayer)))
				d("---------------------")
				identifiedBuff = true
			end
		end
		if identifiedBuff == false then
			d(GroupBuffs.config.constants.GB_SLASH_CMD_ERROR_ABILITY_IDENTIFICATION)
		end
	else
		d(GroupBuffs.config.constants.GB_SLASH_CMD_ERROR_ABILITY_DOESNT_EXIST)
	end
end

function GroupBuffs.DebugShowSelfBuffs()
	local numBuffs = GetNumBuffs("player")
	for i = 1, numBuffs do
		local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("player" , i)    
		d(string.format("%s: %d", buffName, abilityId))
	end
end

function GroupBuffs.DebugCreateBuffList()
	d(GroupBuffs.config.constants.GB_SLASH_CMD_CBL_CREATING)
	local startTime = GetGameTimeMilliseconds()
	d(string.format(GroupBuffs.config.constants.GB_SLASH_CMD_CBL_STARTING, startTime))
	GroupBuffs.savedVars.debug = {}
	GroupBuffs.savedVars.debug = {}
	local index = 1
	local savedDebug = GroupBuffs.savedVars.debug
	savedDebug.informationGathering = {}
	if GroupBuffs.debug ~= nil and GroupBuffs.debug.informationGathering ~= nil then
		local names = GroupBuffs.debug.informationGathering.effectName
		if names ~= nil then
			for i = 1, #names do
				--[[temp fix for zos typo]]
				if names[i] == "Major Deflie" then
					names[i] = "Major Defile"
				end
				local containsEntry = false
				for j = 1, #savedDebug.informationGathering do
					if savedDebug.informationGathering[j].e_name == names[i] then
						containsEntry = true
						--d(savedDebug.informationGathering[j].e_name)
						break
					end
				end
				if containsEntry == false and names[i] ~= nil and names[i] ~= "" then
					savedDebug.informationGathering[index] = {}
					savedDebug.informationGathering[index].e_name = names[i]
					savedDebug.informationGathering[index].ids = {}
					savedDebug.informationGathering[index].name = ""
					index = index + 1
				end

			end
		end
		for i = 1, 300000 do
			if DoesAbilityExist(i) then
				local buff = {}
				buff.name = GetAbilityName(i)
				buff.duration = GetAbilityDuration(i)
				buff.abilityPassive = IsAbilityPassive(i)
				buff.duration = GetAbilityDuration(i)
				for j = 1, #savedDebug.informationGathering do
					if savedDebug.informationGathering[j].e_name == buff.name then
						local array = savedDebug.informationGathering[j].ids
						array[#array + 1] = i
					end
				end
			end
		end
	end
	local endTime = GetGameTimeMilliseconds()
	d(string.format(GroupBuffs.config.constants.GB_SLASH_CMD_CBL_FINISHED, endTime))
	d(string.format(GroupBuffs.config.constants.GB_SLASH_CMD_CBL_TIME, endTime - startTime))
	d(GroupBuffs.config.constants.GB_SLASH_CMD_CBL_RELOADUI_CREATED)
end

function GroupBuffs.DebugClearDebugData()
	d(GroupBuffs.config.constants.GB_SLASH_CMD_CBL_CLEARING)
	GroupBuffs.savedVars.debug = {}
	d(GroupBuffs.config.constants.GB_SLASH_CMD_CBL_RELOADUI)
end

function GroupBuffs.DebugParseCmd(cmd, param)
	param = zo_strtrim(param)
	cmd = zo_strtrim(cmd)
	
	local cmdIndex = string.find(param, " ")
	if cmdIndex  ~= nil then
		cmd = zo_strtrim(string.sub(param, 1, cmdIndex))
		param = zo_strtrim(string.sub(param, cmdIndex + 1))
	else
		cmd = param
		param = ""
	end
	return cmd, param
end

SLASH_COMMANDS[GroupBuffs.slashCmd] = function(param)
	--GroupBuffs.debugCombobox()
	--GroupBuffs.menu.RefreshCustomDropDown()
	d(string.format("%s %s", GroupBuffs.slashCmd, param))
	param = zo_strtrim(param)
	--if param == nil or param == "" then
	--	GroupBuffs.DebugShowSlashCmdOptions()
	--end
	--d(param)
	local cmdIndex = string.find(param, " ")
	--d(cmdIndex)
	if cmdIndex ~= nil then
		local cmd = zo_strtrim(string.sub(param, 1, cmdIndex))
		param = zo_strtrim(string.sub(param, cmdIndex + 1))
		if cmd == "debug" then
			cmd, param = GroupBuffs.DebugParseCmd(cmd, param)
			--d(cmd)
			--d(param)
			
			if cmd == "show" then
				if param == "" then
					GroupBuffs.DebugShowSelfBuffs()
				else
					if param == "players" then
						GroupBuffs.DebugShowPlayers()
					else
						cmd, param = GroupBuffs.DebugParseCmd(cmd, param)
						local id = tonumber(param)
						if cmd == "player" and id ~= nil then
							GroupBuffs.DebugShowPlayerBuffs(id)
						elseif cmd == "ability" then
							local playerId, abilityId = GroupBuffs.DebugParseCmd(cmd, param)
							local playerId = tonumber(playerId)
							local abilityId = tonumber(abilityId)
							if playerId ~= nil and abilityId ~= nil then
								GroupBuffs.DebugShowAbilityInformation(playerId, abilityId)
							else
								GroupBuffs.DebugShowSlashDebugCmdOptions()
							end
						else
							GroupBuffs.DebugShowSlashDebugCmdOptions()
						end
					end
				end
			elseif cmd == "cbl" then
				GroupBuffs.DebugCreateBuffList()
			elseif cmd == "clear" then
				GroupBuffs.DebugClearDebugData()
			else
				GroupBuffs.DebugShowSlashDebugCmdOptions()
			end
		end
	else
		if param == "debug" then
			GroupBuffs.DebugShowSlashDebugCmdOptions()
		elseif param == "menu" then
			GroupBuffs.menu.OpenMenu()
		else
			GroupBuffs.DebugShowSlashCmdOptions()
		end
	end
end

