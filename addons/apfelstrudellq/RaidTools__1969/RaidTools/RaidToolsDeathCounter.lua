RaidToolsModule_DeathCounter = {}
local ENABLED = true -- core feature

function RaidToolsModule_DeathCounter.OnDeathStateChange(eventCode, unitTag, isDead)
	if not string.match(unitTag, 'group') then return end
	if not isDead then return end
	local identifier = GetUnitName(unitTag)
	if GetUnitDisplayName(unitTag) == UID then RaidTools.AddMyDeaths() end
	if RaidTools.storage.config.userid_instead_of_name then identifier = GetUnitDisplayName(unitTag) end
	RaidTools.AddPlayerDeath(identifier)
end

function RaidToolsModule_DeathCounter.OnResurrectResult(eventCode, targetCharacterName, result, targetDisplayName)
	if result == RESURRECT_RESULT_SUCCESS and playerName ~= NAME then
		RaidTools.AddMyRez()
		RaidTools.BrandedMessage('You resurrected '.. targetCharacterName .. '('.. targetDisplayName ..')')
		local identifier = targetCharacterName
		if RaidTools.storage.config.userid_instead_of_name then identifier = targetDisplayName end
		RaidTools.AddPlayerResurrection(identifier)
	end
end

--
-- Commands
--

function RaidToolsModule_DeathCounter.PrintDeaths()
	if not next(RaidTools.deaths) then
		RaidTools.BrandedMessage('No deaths to report')
		return
	end

	local players = {}
	for name, deaths in pairs(RaidTools.deaths) do
		players[name] = deaths
	end

	local message = 'Deaths:'
	if not next(players) then
		message = message .. ' No deaths'
	else
		for name, deaths in spairs(players, function(t,a,b) return t[b] < t[a] end) do
			if deaths ~= 0 then
				message = message .. ' ' .. name .. ': ' .. deaths
			end
		end
	end

	if IsUnitGrouped('player') then
		CHAT_SYSTEM.textEntry:SetText( '/g <RaidTools> ' .. message )
		CHAT_SYSTEM:Maximize()
		CHAT_SYSTEM.textEntry:Open()
		CHAT_SYSTEM.textEntry:FadeIn()
	else
		RaidTools.BrandedMessage(message)
	end
end

function RaidToolsModule_DeathCounter.PrintResurrections()
	local resurrections = RaidTools.resurrections
	local players = {}
	
	if not next(resurrections) then
		RaidTools.BrandedMessage('No resurrections')
		return
	end

	for name, count in pairs(resurrections) do
		players[name] = count
	end
	
	local message = 'My resurrections:'
	for name, resurrects in spairs(players, function(t,a,b) return t[b] < t[a] end) do
		if resurrects ~= 0 then
			message = message .. ' ' .. name .. ': ' .. resurrects
		end
	end

	if IsUnitGrouped('player') then
		CHAT_SYSTEM.textEntry:SetText( '/g <RaidTools> ' .. message)
		CHAT_SYSTEM:Maximize()
		CHAT_SYSTEM.textEntry:Open()
		CHAT_SYSTEM.textEntry:FadeIn()
	else
		RaidTools.BrandedMessage(message)
	end
end