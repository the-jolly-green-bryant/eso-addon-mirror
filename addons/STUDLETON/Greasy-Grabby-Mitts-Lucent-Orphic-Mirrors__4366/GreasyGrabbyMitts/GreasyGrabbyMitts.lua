local namespace = "GreasyGrabbyMitts"

local currentMirrors = {}
local currentMirrorCounts = {}
local currentMirrorCountsIndex = 0
local isUpdateTicking = false
local savedVariables, playerDead, exitCombatTime

STLOG = {}

local mirrorConstants = {
	S = {
		listOrigin = {149090,90740},
		center = {149290,90640},
		bounds = {
		  {148290,90940},
		  {150290,90940},
		  {148790,89440},
		  {149790,89440},
		},
		isLight = false,
	},
	SW = {
		listOrigin = {147168,89778},
		center = {147380,89849},
		bounds = {
		  {146461,89354},
		  {147875,90768},
		  {147875,88647},
		  {148582,89354},
		},
		isLight = true,
	},
	W = {
		listOrigin = {146490,87740},
		center = {146590,87940},
		bounds = {
		  {146290,86940},
		  {146290,88940},
		  {147790,87440},
		  {147790,88440},
		},
		isLight = true,
	},
	NW = {
		listOrigin = {147451,85818},
		center = {147380,86030},
		bounds = {
		  {147875,85111},
		  {146461,86525},
		  {148582,86525},
		  {147875,87232},
		},
		isLight = true,
	},
	N = {
		listOrigin = {149490,85140},
		center = {149290,85240},
		bounds = {
		  {150290,84940},
		  {148290,84940},
		  {149790,86440},
		  {148790,86440},
		},
		isLight = false,
	},
	NE = {
		listOrigin = {151411,86101},
		center = {151199,86030},
		bounds = {
		  {152118,86525},
		  {150704,85111},
		  {150704,87232},
		  {149997,86525},
		},
		isLight = true,
	},
	E = {
		listOrigin = {152090,88140},
		center = {151990,87940},
		bounds = {
		  {152290,88940},
		  {152290,86940},
		  {150790,88440},
		  {150790,87440},
		},
		isLight = true,
	},
	SE = {
		listOrigin = {151128,90061},
		center = {151199,89849},
		bounds = {
		  {150704,90768},
		  {152118,89354},
		  {149997,89354},
		  {150704,88647},
		},
		isLight = true,
	},
}

local function isPlayerInArea(x, z, vertices)
    local function sign(p1x, p1z, p2x, p2z, p3x, p3z)
        return (p1x - p3x) * (p2z - p3z) - (p2x - p3x) * (p1z - p3z)
    end
    local v1x, v1z = unpack(vertices[1])
    local v2x, v2z = unpack(vertices[2])
    local v3x, v3z = unpack(vertices[4])
    local v4x, v4z = unpack(vertices[3])
    
    local d1 = sign(x, z, v1x, v1z, v2x, v2z)
    local d2 = sign(x, z, v2x, v2z, v3x, v3z)
    local d3 = sign(x, z, v3x, v3z, v4x, v4z)
    local d4 = sign(x, z, v4x, v4z, v1x, v1z)
    
    return (d1 >= 0 and d2 >= 0 and d3 >= 0 and d4 >= 0) or
           (d1 <= 0 and d2 <= 0 and d3 <= 0 and d4 <= 0)
end

local function findMirror(x, z, mirrors)
    for mirrorTag, mirror in pairs(mirrors) do
        if isPlayerInArea(x, z, mirror.bounds) then
            return mirrorTag
        end
    end
    return nil
end

EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ADD_ON_LOADED, function(_, addonName)
	if(addonName ~= namespace) then return end
	
	savedVariables = ZO_SavedVars:NewAccountWide(namespace .. "Vars", 1, nil, {
		enabledDrain = true,
		drainSize = 2,
		enabledVisitorLog = true,
		visitorLogSize = 0.7,
		enabledAutoBrag = true,
		visitorOffset = 0,
		drainOffset = 0
	})
	
	local panelConfig = {
		type = "panel",
		name = "Greasy Grabby Mitts",
		author = "@STUDLETON",
		version = "0.2.0",
		registerForRefresh = true,
	}
	
	local optionsConfig = {
		{
			type = "checkbox",
			name = "Enable Mirror Drain Timers",
			tooltip = "Shows remaining duration and stacks above players heads",
			getFunc = function() return savedVariables.enabledDrain end,
			setFunc = function(value) savedVariables.enabledDrain = value end,
		},
		{
			type = "slider",
			name = "Drain Timer Size",
			getFunc = function() return savedVariables.drainSize end,
			setFunc = function(value)
				savedVariables.drainSize = value
				for i = 1, GROUP_SIZE_MAX do
					local displayName = GetUnitDisplayName("group" .. i)
					local icon = OSI.GetIconForPlayer(displayName)
					if icon and icon.drainLabel then
						icon.drainLabel:SetScale(savedVariables.drainSize)
					end
				end
			end,
			min = 1,
			max = 5,
			step = 0.1,
			decimals = 1,
			width = "half",
			disabled = function() return not savedVariables.enabledDrain end
		},
		{
			type = "slider",
			name = "Drain Timer Offset",
			getFunc = function() return savedVariables.drainOffset end,
			setFunc = function(value)
				savedVariables.drainOffset = value
				for i = 1, GROUP_SIZE_MAX do
					local displayName = GetUnitDisplayName("group" .. i)
					local icon = OSI.GetIconForPlayer(displayName)
					if icon and icon.drainLabel then
						icon.drainLabel:ClearAnchors()
						icon.drainLabel:SetAnchor(CENTER, icon.ctrl, CENTER, 0, savedVariables.drainOffset)
					end
				end
			end,
			min = -500,
			max = 500,
			step = 1,
			width = "half",
			disabled = function() return not savedVariables.enabledDrain end
		},
		{
			type = "checkbox",
			name = "Enable Mirror Visitor Log",
			tooltip = "Next to each mirror shows a list of visitors that placed their mark, for better or for worse",
			getFunc = function() return savedVariables.enabledVisitorLog end,
			setFunc = function(value) savedVariables.enabledVisitorLog = value end,
		},
		{
			type = "slider",
			name = "Visitor Log Size",
			getFunc = function() return savedVariables.visitorLogSize end,
			setFunc = function(value)
				savedVariables.visitorLogSize = value
				for tag, mirror in pairs(currentMirrors) do
					if mirror.icons then
						for iconIndex, icon in ipairs(mirror.icons) do
							local y = 23500 - (iconIndex * (50 * savedVariables.visitorLogSize)) + savedVariables.visitorOffset
							icon.y = y
							icon.data.size = 60*savedVariables.visitorLogSize
							icon.visitorLabel:SetScale(savedVariables.visitorLogSize)
						end	
					end
				end
			end,
			min = 0.1,
			max = 2,
			step = 0.01,
			decimals = 2,
			width = "half",
			disabled = function() return not savedVariables.enabledVisitorLog end
		},
		{
			type = "slider",
			name = "Visitor Log Vertical Offset",
			getFunc = function() return savedVariables.visitorOffset end,
			setFunc = function(value)
				savedVariables.visitorOffset = value
				for tag, mirror in pairs(currentMirrors) do
					if mirror.icons then
						for iconIndex, icon in ipairs(mirror.icons) do
							local y = 23500 - ((iconIndex * (50 * savedVariables.visitorLogSize)) + savedVariables.visitorOffset)
							icon.y = y
						end	
					end
				end
			end,
			min = -500,
			max = 500,
			step = 1,
			width = "half",
			disabled = function() return not savedVariables.enabledVisitorLog end
		},
		-- {
			-- type = "checkbox",
			-- name = "Auto Brag",
			-- tooltip = "When exiting combat after mirrors were hit, brag to chat. That only you can read. Lol.",
			-- getFunc = function() return savedVariables.enabledAutoBrag end,
			-- setFunc = function(value) savedVariables.enabledAutoBrag = value end,
			-- width = "half",
		-- },
	}
	
	LibAddonMenu2:RegisterAddonPanel(namespace .. "Settings", panelConfig)
	LibAddonMenu2:RegisterOptionControls(namespace .. "Settings", optionsConfig)

	local function AdjustLabelForIcon(icon)
		local order = icon.ctrl:GetDrawLevel() + 1
		icon.drainLabel:SetDrawLevel(order)
	end
	
	function updateTick()
		local timeSec = GetGameTimeSeconds()
		for i = 1, GROUP_SIZE_MAX do
			local displayName = GetUnitDisplayName("group" .. i)
			local icon = OSI.GetIconForPlayer(displayName)
			if icon and icon.drainTimer then
				if timeSec >= icon.drainTimer then
					OSI.RemoveMechanicIconForUnit(displayName)
					icon.drainLabel:SetHidden(true)
					icon.drainStacks = 0
				else
					local timeLeft = icon.drainTimer - timeSec
					local drainStacksString = ""
					if icon.drainStacks > 1 then drainStacksString = " (" .. tostring(icon.drainStacks) .. ")" end
					icon.drainLabel:SetText(tostring(zo_floor(timeLeft)) .. drainStacksString)
					AdjustLabelForIcon(icon)
				end
			end
		end
	end

	local function updateMirrorDrain(changeType, unitTag, beginTime, endTime)
		if IsUnitPlayer(unitTag) then
			local displayName = GetUnitDisplayName(unitTag)
			local icon = OSI.GetIconForPlayer(displayName)
			if icon then
				if not icon.drainLabel then
					icon.drainLabel = icon.ctrl:CreateControl(icon.ctrl:GetName() .. "MirrorDrainLabel", CT_LABEL)
					icon.drainLabel:SetAnchor(CENTER, icon.ctrl, CENTER, 0, savedVariables.drainOffset)
					icon.drainLabel:SetFont("$(BOLD_FONT)|$(KB_54)|outline")
					icon.drainLabel:SetDrawLayer(DL_BACKGROUND)
					icon.drainLabel:SetDrawTier(DT_LOW)
					icon.drainLabel:SetColor(0.9,0.9,0.9,0.85)
				end
				AdjustLabelForIcon(icon)
				if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
					icon.drainLabel:SetScale(savedVariables.drainSize)
					currentMirrorCounts[currentMirrorCountsIndex] = currentMirrorCounts[currentMirrorCountsIndex] or {}
					currentMirrorCounts[currentMirrorCountsIndex][displayName] = 
						(currentMirrorCounts[currentMirrorCountsIndex][displayName] or 0) + 1
					icon.drainStacks = (icon.drainStacks or 0) + 1
					local drainStacksString = ""
					if icon.drainStacks > 1 then drainStacksString = " (" .. tostring(icon.drainStacks) .. ")" end
					
					OSI.SetMechanicIconForUnit(displayName, "/esoui/art/icons/heraldrycrests_misc_blank_01.dds", OSI.GetIconSize())
					icon.drainLabel:SetText(tostring(zo_floor(endTime - beginTime)) .. drainStacksString)
					if savedVariables.enabledDrain then icon.drainLabel:SetHidden(false) else icon.drainLabel:SetHidden(true) end
					icon.drainTimer = endTime
					
					local zone, x, y, z = GetUnitWorldPosition(unitTag)
					local mirrorTag = findMirror(x, z, mirrorConstants)
					if not mirrorTag then
						--d("mirror not found")
						table.insert(STLOG, {changeType, unitTag, beginTime, endTime, x, y, z})
					end
					if mirrorTag and savedVariables.enabledVisitorLog then
						currentMirrors[mirrorTag] = currentMirrors[mirrorTag] or {
							isLight = mirrorConstants[mirrorTag].isLight,
							icons = {}
						}
						local mirror = currentMirrors[mirrorTag]
						local x, z = unpack(mirrorConstants[mirrorTag].listOrigin)
						local iconIndex = #mirror.icons + 1
						local y = 23500 - (iconIndex * (50 * savedVariables.visitorLogSize)) + savedVariables.visitorOffset
						--mirror.isLight = not mirror.isLight
						local icon = OSI.CreatePositionIcon(
							x, y, z,
							"/esoui/art/icons/heraldrycrests_misc_blank_01.dds", -- "/esoui/art/icons/achievement_u42_tri_trial_flavor_4.dds"
							60*savedVariables.visitorLogSize,
							{1, 1, 1} -- {1, mirror.isLight and 1 or 0, 0}
						)
						table.insert(mirror.icons, icon)
						if not icon.visitorLabel then
							icon.visitorLabel = icon.ctrl:CreateControl(icon.ctrl:GetName()..mirrorTag.."MirrorVisitorLabel"..tostring(iconIndex)..tostring(GetGameTimeSeconds()), CT_LABEL)
						end
						icon.visitorLabel:SetAnchor(LEFT, icon.ctrl, RIGHT, 10, 0)
						icon.visitorLabel:SetFont("$(BOLD_FONT)|$(KB_54)|outline")
						icon.visitorLabel:SetScale(savedVariables.visitorLogSize)
						icon.visitorLabel:SetDrawLayer(DL_BACKGROUND)
						icon.visitorLabel:SetDrawTier(DT_LOW)
						icon.visitorLabel:SetColor(0.9,0.9,0.9,0.85)
						icon.visitorLabel:SetText(displayName)
						icon.visitorLabel:SetHidden(false)
					end
				elseif changeType == EFFECT_RESULT_FADED then
					OSI.RemoveMechanicIconForUnit(displayName)
					icon.drainLabel:SetHidden(true)
					icon.drainStacks = 0
				end
			end
		end
	end
	
	EVENT_MANAGER:RegisterForEvent(namespace, EVENT_PLAYER_ACTIVATED, function()
		if GetZoneId(GetUnitZoneIndex("player")) ~= 1478 then return end
		SLASH_COMMANDS["/mirrorbragreset"]()
		
		EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_PLAYER_COMBAT_STATE)
		EVENT_MANAGER:RegisterForEvent(namespace, EVENT_PLAYER_COMBAT_STATE, function(eventCode, inCombat)
			--d("inCombat "..tostring(inCombat).." "..tostring(IsUnitDeadOrReincarnating("player")).." "..tostring(playerDead).." "..tostring(exitCombatTime))
			
			if inCombat then
				if playerDead then
					playerDead = false
				else
					if exitCombatTime then
						if GetGameTimeSeconds() - exitCombatTime > 5 then
							SLASH_COMMANDS["/mirrorbragreset"]()
						end
					else SLASH_COMMANDS["/mirrorbragreset"]() end
				end
			elseif not playerDead then
				exitCombatTime = GetGameTimeSeconds()
			end
		end)
		
		
		EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_UNIT_DEATH_STATE_CHANGED)
		EVENT_MANAGER:RegisterForEvent(namespace, EVENT_UNIT_DEATH_STATE_CHANGED, function(eventCode, unitTag, isDead)
			--d(unitTag.." dead "..tostring(isDead).." incombat "..tostring(IsUnitInCombat("player")))
			if isDead then
				playerDead = true
			else
				if not IsUnitInCombat("player") then
					playerDead = false
				end
			end
		end)
		EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

		EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_EFFECT_CHANGED)
		EVENT_MANAGER:RegisterForEvent(namespace, EVENT_EFFECT_CHANGED, function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
				if not isUpdateTicking then
					EVENT_MANAGER:RegisterForUpdate(namespace, 100, updateTick)
					isUpdateTicking = true
				end
				updateMirrorDrain(changeType, unitTag, beginTime, endTime)
				table.insert(STLOG, {eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType})
		end)
		EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
		EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 214784) -- drain: 214784, minor resolve: 61693
	end)
	
	SLASH_COMMANDS["/mirrorbrag"] = function(historyIndex)
		historyIndex = historyIndex:match("%d+")
		local countsIndex = #currentMirrorCounts
		local historyMessage = ""
		if historyIndex then
			historyIndex = tonumber(historyIndex)
			historyMessage = "Pull "..tostring(historyIndex).." of "..tostring(#currentMirrorCounts).." - " 
			if currentMirrorCounts[historyIndex] then
				countsIndex = historyIndex
			else d(historyMessage.."Not Found, bragging most recent") end
		end
		local orderedCounts = {}
		--d(historyIndex, #currentMirrorCounts, countsIndex)
		if not currentMirrorCounts[countsIndex] then d("No one hit any mirrors to brag about :(") return end
		for name, count in pairs(currentMirrorCounts[countsIndex]) do
			table.insert(orderedCounts, {name = name, count = count})
		end
		if #orderedCounts == 0 then d("No one hit any mirrors to brag about :(") return end
		table.sort(orderedCounts, function(a, b) return a.count > b.count end)
		
		d(historyMessage.."I hit all these mirrors look at me:")
		for name, data in pairs(orderedCounts) do
			d(tostring(data.count) .. " " .. data.name)
		end
	end
	
	SLASH_COMMANDS["/mirrorbragreset"] = function()
		--d("mirrorbragreset")
		for tag, mirror in pairs(currentMirrors) do
			if mirror.icons then
				for _, icon in ipairs(mirror.icons) do
					OSI.DiscardPositionIcon(icon)
					icon.visitorLabel:SetHidden(true)
				end
				mirror.isLight = mirrorConstants[tag].isLight
				mirror.icons = {}		
			end
		end
		currentMirrorCountsIndex = #currentMirrorCounts + 1
	end

	EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_ADD_ON_LOADED)
end)

