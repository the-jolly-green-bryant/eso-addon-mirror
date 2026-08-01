UniversalTracker = UniversalTracker or {}

-- Clears and updates all anchors in the list.
-- Assumes controls have been acquired from pools and initialized.
function UniversalTracker.UpdateListAnchors(settingsTable)
	-- Only works on lists
	if not (UniversalTracker.Controls[settingsTable.id] and UniversalTracker.Controls[settingsTable.id][1]) then return end

	local columns = {
		[0] = {},
		[1] = {},
		[2] = {}
	}

	--populate columns with lists of controls.
	local nextColumnIndex = 0
	for i = 1, #UniversalTracker.Controls[settingsTable.id] do
		local control = UniversalTracker.Controls[settingsTable.id][i].object
		if control and not (settingsTable.hideInactive and control:IsHidden()) then
			columns[nextColumnIndex][#columns[nextColumnIndex] + 1] = control
			nextColumnIndex = (nextColumnIndex + 1)%settingsTable.listSettings.columns
		end
	end

	local horizontalOffset = settingsTable.listSettings.horizontalOffsetScale * settingsTable.scale
	local verticalOffset = settingsTable.listSettings.verticalOffsetScale * settingsTable.scale
	if settingsTable.type == "Bar" then
		horizontalOffset = horizontalOffset * 15
		verticalOffset = verticalOffset * 25
	elseif settingsTable.type == "Compact" then
		horizontalOffset = horizontalOffset * 10
		verticalOffset = verticalOffset * 15
	end

	if columns[0][1] then
		columns[0][1]:ClearAnchors()
		columns[0][1]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settingsTable.x, settingsTable.y)
	end

	if settingsTable.type == "Bar" and settingsTable.barSettings.alignment == "Bottom" or settingsTable.barSettings.alignment == "Top" then

		
		-- Anchor column heads
		if columns[1][1] then
			columns[1][1]:ClearAnchors()
			columns[1][1]:SetAnchor(LEFT, columns[0][1], LEFT, horizontalOffset + columns[0][1]:GetHeight(), 0)
		end
		if columns[2][1] then
			columns[2][1]:ClearAnchors()
			columns[2][1]:SetAnchor(LEFT, columns[1][1], LEFT, horizontalOffset + columns[1][1]:GetHeight(), 0)
		end
		
		-- Anchor column children
		for i = 2, #columns[0] do
			columns[0][i]:ClearAnchors()
			columns[0][i]:SetAnchor(TOPLEFT, columns[0][i-1], TOPLEFT, 0, verticalOffset + columns[0][i-1]:GetWidth())
		end
		for i = 2, #columns[1] do
			columns[1][i]:ClearAnchors()
			columns[1][i]:SetAnchor(TOPLEFT, columns[1][i-1], TOPLEFT, 0, verticalOffset + columns[1][i-1]:GetWidth())
		end
		for i = 2, #columns[2] do
			columns[2][i]:ClearAnchors()
			columns[2][i]:SetAnchor(TOPLEFT, columns[2][i-1], TOPLEFT, 0, verticalOffset + columns[2][i-1]:GetWidth())
		end
	else
		
		-- Anchor column heads
		if columns[1][1] then
			columns[1][1]:ClearAnchors()
			columns[1][1]:SetAnchor(LEFT, columns[0][1], LEFT, horizontalOffset + columns[0][1]:GetWidth(), 0)
		end
		if columns[2][1] then
			columns[2][1]:ClearAnchors()
			columns[2][1]:SetAnchor(LEFT, columns[1][1], LEFT, horizontalOffset + columns[1][1]:GetWidth(), 0)
		end
		
		-- Anchor column children
		for i = 2, #columns[0] do
			columns[0][i]:ClearAnchors()
			columns[0][i]:SetAnchor(TOPLEFT, columns[0][i-1], TOPLEFT, 0, verticalOffset + columns[0][i-1]:GetHeight())
		end
		for i = 2, #columns[1] do
			columns[1][i]:ClearAnchors()
			columns[1][i]:SetAnchor(TOPLEFT, columns[1][i-1], TOPLEFT, 0, verticalOffset + columns[1][i-1]:GetHeight())
		end
		for i = 2, #columns[2] do
			columns[2][i]:ClearAnchors()
			columns[2][i]:SetAnchor(TOPLEFT, columns[2][i-1], TOPLEFT, 0, verticalOffset + columns[2][i-1]:GetHeight())
		end
	end
end

function UniversalTracker.InitList(settingsTable, unitTag)
	UniversalTracker.Controls[settingsTable.id] = {}
	UniversalTracker.Animations[settingsTable.id] = {}

	-- Initialize linked list with current group members / living bosses.
	for i = 1, 12 do
		if DoesUnitExist(unitTag..i) and not (unitTag == "boss" and IsUnitDead(unitTag..i)) then
			local newControl, newControlKey
			local newAnimation, newAnimationKey
			if settingsTable.type == "Bar" then
				newControl, newControlKey = UniversalTracker.barPool:AcquireObject()
				newAnimation, newAnimationKey = UniversalTracker.barAnimationPool:AcquireObject()
				UniversalTracker.InitBar(settingsTable, unitTag..i, newControl, newAnimation)
				
				table.insert(UniversalTracker.Animations[settingsTable.id], {object = newAnimation, key = newAnimationKey})
			elseif settingsTable.type == "Compact" then
				newControl, newControlKey = UniversalTracker.compactPool:AcquireObject()
				UniversalTracker.InitCompact(settingsTable, unitTag..i, newControl)
			end

			table.insert(UniversalTracker.Controls[settingsTable.id], {object = newControl, key = newControlKey, unitTag = unitTag..i})
		end
	end

	UniversalTracker.UpdateListAnchors(settingsTable)
end

-- number of controls, control unit tag targets, anchors, etc.
function UniversalTracker.updateList(settingsTable, unitTag)
	local shouldUpdateAnchors = false

	--Step 1: Removed list elements if the unittag's entity no longer exists.
	for i = #UniversalTracker.Controls[settingsTable.id], 1, -1 do
		if UniversalTracker.Controls[settingsTable.id][i] and (not DoesUnitExist(UniversalTracker.Controls[settingsTable.id][i].unitTag) or 
			(string.find(UniversalTracker.Controls[settingsTable.id][i].unitTag, "boss") and IsUnitDead(UniversalTracker.Controls[settingsTable.id][i].unitTag))) then

			shouldUpdateAnchors = true

			--free objects
			if UniversalTracker.Animations[settingsTable.id][i] and UniversalTracker.Animations[settingsTable.id][i].object then
				UniversalTracker.barPool:ReleaseObject(UniversalTracker.Controls[settingsTable.id][i].key)
				UniversalTracker.barAnimationPool:ReleaseObject(UniversalTracker.Animations[settingsTable.id][i].key)
				table.remove(UniversalTracker.Animations[settingsTable.id], i)
			else
				UniversalTracker.compactPool:ReleaseObject(UniversalTracker.Controls[settingsTable.id][i].key)
			end

			table.remove(UniversalTracker.Controls[settingsTable.id], i)
		end
	end

	--Step 2a: If the linked lists are empty, rebuild them.
	if #UniversalTracker.Controls[settingsTable.id] == 0 then
		UniversalTracker.InitList(settingsTable, unitTag)
		shouldUpdateAnchors = false
	else
		-- Step 2b: Else, Insert unaccounted for unit tags into sorted positions within the linked list
		local unusedTags = {}
		for i = 1, 12 do
			if DoesUnitExist(unitTag..i) and not (settingsTable.targetType == "Boss" and IsUnitDead(unitTag..i)) then unusedTags[i] = true end
		end

		-- remove used tags from unused list.
		-- note that an index is only in the unused list if the corresponding unit exists.
		for i = 1, #UniversalTracker.Controls[settingsTable.id] do
			local index = tonumber(string.gsub(UniversalTracker.Controls[settingsTable.id][i].unitTag, "%D", ""))
			if unusedTags[index] then
				unusedTags[index] = nil
			end
		end

		--insert unused tags into the tables in sorted order based off of unit tag
		for k, v in pairs(unusedTags) do
			shouldUpdateAnchors = true

			--object creation
			local newControl, newControlKey 
			local newAnimation, newAnimationKey
			if settingsTable.type == "Bar" then
				newControl, newControlKey = UniversalTracker.barPool:AcquireObject()
				newAnimation, newAnimationKey = UniversalTracker.barAnimationPool:AcquireObject()
				UniversalTracker.InitBar(settingsTable, unitTag..k, newControl, newAnimation)
				table.insert(UniversalTracker.Animations[settingsTable.id], {object = newAnimation, key = newAnimationKey})
			else
				newControl, newControlKey = UniversalTracker.compactPool:AcquireObject()
				InitCompact(settingsTable, unitTag..k, newControl)
			end

			local insertIndex = 1
			local currentTag = string.gsub(UniversalTracker.Controls[settingsTable.id][insertIndex].unitTag, "%D+", "") --gsub returns 2 arguments and tonumber takes 2 arguments. not a wanted interaction
			while UniversalTracker.Controls[settingsTable.id][insertIndex] and tonumber(currentTag) < k do
				insertIndex = insertIndex + 1
				if UniversalTracker.Controls[settingsTable.id][insertIndex] then
					currentTag = string.gsub(UniversalTracker.Controls[settingsTable.id][insertIndex].unitTag, "%D+", "")
				else
					break
				end
			end
			table.insert(UniversalTracker.Controls[settingsTable.id], insertIndex, {object = newControl, key = newControlKey, unitTag = unitTag..k})
			if settingsTable.type == "Bar" then
				table.insert(UniversalTracker.Animations[settingsTable.id], insertIndex, {object = newAnimation, key = newAnimationKey})
			end
		end
	end

	--Step 3: Sanity check to make sure there are no duplicate unit tags in list.
	local usedTags = {}
	
	for i = #UniversalTracker.Controls[settingsTable.id], 1, -1 do
		if UniversalTracker.Controls[settingsTable.id][i] and not usedTags[UniversalTracker.Controls[settingsTable.id][i].unitTag] then
			usedTags[UniversalTracker.Controls[settingsTable.id][i].unitTag] = true
		elseif UniversalTracker.Controls[settingsTable.id][i] then
			shouldUpdateAnchors = true

			--free objects
			if settingsTable.type == "Bar" and UniversalTracker.Animations[settingsTable.id][i] and UniversalTracker.Animations[settingsTable.id][i].object then
				UniversalTracker.barPool:ReleaseObject(UniversalTracker.Controls[settingsTable.id][i].key)
				UniversalTracker.barAnimationPool:ReleaseObject(UniversalTracker.Animations[settingsTable.id][i].key)
				table.remove(UniversalTracker.Animations[settingsTable.id], i)
			else
				UniversalTracker.compactPool:ReleaseObject(UniversalTracker.Controls[settingsTable.id][i].key)
			end

			table.remove(UniversalTracker.Controls[settingsTable.id], i)
		end 
	end

	if shouldUpdateAnchors then
		UniversalTracker.UpdateListAnchors(settingsTable)
	end
end

-- settings (e.g font, scale, offset, etc.)
function UniversalTracker.refreshList(settingsTable, unitTag)
	if settingsTable.type == "Bar" then
		for i = 1, #UniversalTracker.Controls[settingsTable.id] do
			UniversalTracker.InitBar(settingsTable, UniversalTracker.Controls[settingsTable.id][i].unitTag, UniversalTracker.Controls[settingsTable.id][i].object, UniversalTracker.Animations[settingsTable.id][i].object)
		end
	elseif settingsTable.type == "Compact" then
		for i = 1, #UniversalTracker.Controls[settingsTable.id] do
			InitCompact(settingsTable, UniversalTracker.Controls[settingsTable.id][i].unitTag, UniversalTracker.Controls[settingsTable.id][i].object)
		end
	end

	--register events.
	EVENT_MANAGER:UnregisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_UNIT_DEATH_STATE_CHANGED)
	EVENT_MANAGER:UnregisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_BOSSES_CHANGED)
	EVENT_MANAGER:UnregisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_UNIT_DESTROYED)
	EVENT_MANAGER:UnregisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_UNIT_CREATED)
	EVENT_MANAGER:UnregisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_GROUP_MEMBER_JOINED)
	EVENT_MANAGER:UnregisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_GROUP_MEMBER_LEFT)

	EVENT_MANAGER:RegisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_UNIT_DEATH_STATE_CHANGED, function() UniversalTracker.updateList(settingsTable, unitTag) end)
	EVENT_MANAGER:AddFilterForEvent(UniversalTracker.name..settingsTable.id, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, unitTag)
	if unitTag == "boss" then
		EVENT_MANAGER:RegisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_BOSSES_CHANGED, function() UniversalTracker.updateList(settingsTable, unitTag) end)
		EVENT_MANAGER:RegisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_UNIT_CREATED, function() UniversalTracker.updateList(settingsTable, unitTag) end)
		EVENT_MANAGER:RegisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_UNIT_DESTROYED, function() UniversalTracker.updateList(settingsTable, unitTag) end)
		EVENT_MANAGER:AddFilterForEvent(UniversalTracker.name..settingsTable.id, EVENT_UNIT_CREATED, REGISTER_FILTER_UNIT_TAG_PREFIX, unitTag)
		EVENT_MANAGER:AddFilterForEvent(UniversalTracker.name..settingsTable.id, EVENT_UNIT_DESTROYED, REGISTER_FILTER_UNIT_TAG_PREFIX, unitTag)
	elseif unitTag == "group" then
		EVENT_MANAGER:RegisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_GROUP_MEMBER_JOINED, function() UniversalTracker.updateList(settingsTable, unitTag) end)
		EVENT_MANAGER:RegisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_GROUP_MEMBER_LEFT, function() UniversalTracker.updateList(settingsTable, unitTag) end)
	end

	UniversalTracker.UpdateListAnchors(settingsTable)
end

function UniversalTracker.freeLists(settingsTable)
	EVENT_MANAGER:UnregisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_GROUP_MEMBER_JOINED)
	EVENT_MANAGER:UnregisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_GROUP_MEMBER_LEFT)
	EVENT_MANAGER:UnregisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_BOSSES_CHANGED)
	EVENT_MANAGER:UnregisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_UNIT_DEATH_STATE_CHANGED)
	EVENT_MANAGER:UnregisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_UNIT_DESTROYED)
	EVENT_MANAGER:UnregisterForEvent(UniversalTracker.name..settingsTable.id, EVENT_UNIT_CREATED)
	
	-- Don't do anything if not passed lists.
	if UniversalTracker.Controls[settingsTable.id].object or (UniversalTracker.Animations[settingsTable.id] and UniversalTracker.Animations[settingsTable.id].object) then
		return
	end

	--We might be freeing bar objects when passed a settingsTable that wants to initialize compact objects.
	if UniversalTracker.Animations[settingsTable.id] and UniversalTracker.Animations[settingsTable.id][1] then
		--Bar
		for i = 1, #UniversalTracker.Controls[settingsTable.id] do
			UniversalTracker.barPool:ReleaseObject(UniversalTracker.Controls[settingsTable.id][i].key)
			UniversalTracker.barAnimationPool:ReleaseObject(UniversalTracker.Animations[settingsTable.id][i].key)
		end
	else
		--Compact
		for i = 1, #UniversalTracker.Controls[settingsTable.id] do
			UniversalTracker.compactPool:ReleaseObject(UniversalTracker.Controls[settingsTable.id][i].key)
		end
	end

	UniversalTracker.Controls[settingsTable.id] = {}
	UniversalTracker.Animations[settingsTable.id] = {}

end