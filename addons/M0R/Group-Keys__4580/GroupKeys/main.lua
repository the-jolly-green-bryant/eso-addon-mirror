local protocol
local syncrequest
local bossLabelControls = {} -- ADVENTURE_ZONE_BOSS_TREE_KEYBOARD

local bosses = {
	ADVENTURE_ZONE_BOSS_SKITTERING_WORLD_BOSS_1,
	ADVENTURE_ZONE_BOSS_SKITTERING_WORLD_BOSS_2,
	ADVENTURE_ZONE_BOSS_SORROWS_FRIEND_WORLD_BOSS_1,
	ADVENTURE_ZONE_BOSS_SORROWS_FRIEND_WORLD_BOSS_2,
	ADVENTURE_ZONE_BOSS_PARCH_WORLD_BOSS_1,
	ADVENTURE_ZONE_BOSS_PARCH_WORLD_BOSS_2,
	ADVENTURE_ZONE_BOSS_SKITTERING_INSTANCE_BOSS,
	ADVENTURE_ZONE_BOSS_SORROWS_FRIEND_INSTANCE_BOSS,
	ADVENTURE_ZONE_BOSS_PARCH_INSTANCE_BOSS,
} -- excluding trial boss cause he no drop key

local function makeControls()
	for i,v in pairs(bosses) do
		local name = "GroupKeyCountBoss"..i
		local keyCount = CreateControl(name,GuiRoot,CT_LABEL) -- set parent in anchor
		--keyCount:SetAnchor(CENTER,v:GetNamedChild("Frame"),TOP,0,0)
		keyCount:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_18)|thick-outline")
		--keyCount:SetText("1/12")
		keyCount.keysState = {}
		bossLabelControls[v] = keyCount
	end
end


local function refreshText()
	local currentGroup = {}
	local groupCount = 0
	for i=1,12 do
		local name = GetUnitDisplayName("group"..i)
		if name then
			currentGroup[name] = true
			groupCount = groupCount + 1
		end
	end
	for i,v in pairs(bossLabelControls) do
		if groupCount == 0 then
			v:SetText("")
		else
			local currentKeyCount = 0
			for j,k in pairs(v.keysState) do
				if currentGroup[j] and k then
					currentKeyCount = currentKeyCount + 1
				else
					v.keysState[j] = nil
				end
			end
			local colour
			if currentKeyCount == groupCount then
				colour = "00ff00" -- everyone has key
			elseif currentKeyCount == 0 then
				colour = "ff0000" -- nobody has key
			else
				colour = "ffff00" -- someone has key
			end
			v:SetText(string.format("|c%s%d/%d|r", colour, currentKeyCount, groupCount))
		end
	end
end


local function anchorControls(self)
	for i,v in pairs(self.bossControls) do
		if v.boss ~= ADVENTURE_ZONE_BOSS_TRIAL_BOSS then
			local current = bossLabelControls[v.boss]
			current:ClearAnchors()
			current:SetParent(v)
			current:SetAnchor(CENTER,v:GetNamedChild("Frame"),TOP,0,0)
		end
	end
end


local oldKeyCount = 0


local function updateCurrentKeys()
	local currentKeys = 0
	local playerName = GetUnitDisplayName('player')
	for i,v in pairs(bossLabelControls) do
		local currentState = GetAdventureZoneBossState(i) == ADVENTURE_ZONE_BOSS_STATE_DEFEATED and 1 or 0
		currentKeys = currentKeys + currentState * zo_pow(2,i)
		v.keysState[playerName] = currentState == 1 and true or false
	end
	--a = currentKeys
	return currentKeys
end

local function playerActivated(_, _, keys)
	--b = {...}
	--keys = nil
	if not keys then keys = updateCurrentKeys() end
	--send keys here
	protocol:Send({
		data = keys
	})
	oldKeyCount = keys
end



local isWindowCurrentlyShowing = false
SecurePostHook(ZO_AdventureZoneBossTree_Shared, "OnShowing", function(self)
	anchorControls(self)
	refreshText()
	local keyCount = updateCurrentKeys()
	if oldKeyCount ~= keyCount then
		playerActivated(nil, nil, keyCount)
		oldKeyCount = keyCount
	end
	isWindowCurrentlyShowing = true

	syncrequest:Send({
		sync = true
	})
end)

SecurePostHook(ZO_AdventureZoneBossTree_Shared, "OnHiding", function(self)
	isWindowCurrentlyShowing = false
end)




local function onGroupKeyRecieved(unitTag, data)
	--d("Group Key recieved from "..GetUnitDisplayName(unitTag))
	if AreUnitsEqual('player', unitTag) then return end

	local bitData = data.data
	local playerName = GetUnitDisplayName(unitTag)
	for i,v in pairs(bossLabelControls) do
		local currentState = zo_floor(bitData/zo_pow(2,i))%2
		v.keysState[playerName] = currentState == 1 and true or false
	end

	if isWindowCurrentlyShowing then
		refreshText()
	end
end


local function onSyncRequestRecieved(unitTag, data)
	--d("Sync request recieved from "..GetUnitDisplayName(unitTag))
	if AreUnitsEqual('player', unitTag) then return end

	playerActivated()
end



local function createKeyTooltipText(boss)
	if not IsUnitGrouped('player') then return "" end
	if boss == ADVENTURE_ZONE_BOSS_TRIAL_BOSS then return "" end
	local hasKey = {}
	local doesntHaveKey = {}

	local currentGroup = {}
	for i=1,12 do
		local name = GetUnitDisplayName("group"..i)
		if name then
			currentGroup[name] = true
		end
	end
	for i,v in pairs(currentGroup) do
		if bossLabelControls[boss] and bossLabelControls[boss].keysState[i] then
			hasKey[#hasKey+1] = i
		else
			doesntHaveKey[#doesntHaveKey+1] = i
		end
	end

	local outText = ""
	if #hasKey == 0 then
		outText = "|cFF0000Nobody has this key!|r"
	elseif #doesntHaveKey == 0 then
		outText = "|c00FF00Everyone has this key!|r"
	else
		outText = string.format("|c00FF00Key Obtained: %s|r\n|cFF0000Key Missing: %s|r", table.concat(hasKey, ", "), table.concat(doesntHaveKey, ", "))
	end
	return outText

end


SecurePostHook(ADVENTURE_ZONE_BOSS_TREE_KEYBOARD, "ShowTooltipForBoss", function(self, boss, control)
	local keyText = createKeyTooltipText(boss)
	InformationTooltip:AddLine(keyText)
end)
-- TODO: Add it for gamepad too
SecurePostHook(ZO_Tooltip, "LayoutAdventureZoneBossTooltip", function(self, boss)
	local keyText = createKeyTooltipText(boss)
	local descriptionSection = self:AcquireSection(self:GetStyle("bodySection"))
	descriptionSection:AddLine(keyText, self:GetStyle("bodyDescription"))
	self:AddSection(descriptionSection)
end)





--SLASH_COMMANDS['/testkeys'] = playerActivated


local function OnAddOnLoaded(event, addonName)
	if addonName ~= "GroupKeys" then return end
	local LGB = LibGroupBroadcast

	makeControls()
	--updateCurrentKeys()

	local handler = LGB:RegisterHandler("GroupKeys")
	handler:SetDisplayName("Group Keys")
	handler:SetDescription("Shows your group members' Night Market Keys in the UI!")


	protocol = handler:DeclareProtocol(126, "GroupKeysData")
	protocol:AddField(LGB.CreateNumericField("data", {numBits=9, trimValues=true}))
	protocol:OnData(onGroupKeyRecieved)
	protocol:Finalize({replaceQueuedMessages = true})

	syncrequest = handler:DeclareProtocol(127, "GroupKeysSyncRequest")
	syncrequest:AddField(LGB.CreateFlagField("sync"))
	syncrequest:OnData(onSyncRequestRecieved)
	syncrequest:Finalize({replaceQueuedMessages = true})


	EVENT_MANAGER:UnregisterForEvent("GroupKeys", EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent("GroupKeys", EVENT_PLAYER_ACTIVATED, playerActivated)
end
EVENT_MANAGER:RegisterForEvent("GroupKeys", EVENT_ADD_ON_LOADED, OnAddOnLoaded)