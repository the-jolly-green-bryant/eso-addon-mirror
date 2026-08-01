-- Load up emote and comunication code constants
SPC = {
	soulgemEmoteIndex = 230,
	parchmentEmoteIndex = 231,
	clippersEmoteIndex = 232,

	soulgemCode = 474,
	parchmentCode = 239,
	clipperCode = 782,
	readyCode = 123,
	spcIdentityCode = 394,
	countDownCode = 843,

	-- approve, cheer, cuckoo, laugh, goaway, wagfinger, pointu, thumbsup, bucketsplash
	winnerEmotes = {14, 25, 28, 41, 74, 93, 124, 129, 157, 161, },
	-- boo, disapprove, exasperated, facepalm, headscratch, shakefist, thumbsdown, crying, wagfinger, playdead, spit
	loserEmotes = {23, 29, 32, 33, 40, 62, 69, 71, 93, 115, 179, },

	-- whistle, horn, come, point, pointd, sitchair, wand
	startEmotes = {[3] = true, [4] = true, [18] = true, [45] = true, [47] = true, [100] = true, [164] = true}, 
}

function SPC.CalcMapPoint(value)
	return (value / 1000)
end 

function SPC.CalcCode(value)
	return math.floor((value * 1000) + 0.5)
end

SPC.Original_PlayEmoteByIndex = PlayEmoteByIndex
PlayEmoteByIndex = function(emoteIndex) 
	
	if (SPC.code[emoteIndex] ~= nil and IsUnitGrouped("player")) then
		-- queue up the emote
		SPC.myQueuedEmote = emoteIndex
		-- broadcast ready
		PingMap(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, SPC.CalcMapPoint(SPC.readyCode), SPC.CalcMapPoint(SPC.spcIdentityCode))
		--d('Queued Index: '..emoteIndex)
	else
		SPC.Original_PlayEmoteByIndex(emoteIndex)
		if (SPC.startEmotes[emoteIndex]) then
			-- Ping the starter emote to the group
			PingMap(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, SPC.CalcMapPoint(SPC.countDownCode), SPC.CalcMapPoint(SPC.spcIdentityCode))	
		else
			-- Clear out any queued info if they throw any other emote.
			SPC.Clear()
		end
		--d('You emoted: '..emoteIndex)
	end
end

--SPC.Original_PingMap = PingMap
--PingMap = function(pinType, mapType, x, y) 
--	d('pinType: '..pinType)
--	d('mapType: '..mapType)
--	d('x: '..x)
--	d('y: '..y)	
--	SPC.Original_PingMap(pinType, mapType, x, y)
--end

function SPC.Countdown(count)
   if count == 3 and SPC.inCountdown then return end

   SPC.inCountdown = true
	if count == 3 then
		d('Epic SPC Throwdown in 3...')
	elseif count == 2 then
		d('2..')	
	elseif count == 1 then 
		d('1.')
	else	
		d('THROW!!')
		SPC.inCountdown = false
		SPC.CheckForThrow()
		SPC.CheckForResults()
	end
	if count <= 3 and count > 0 then
		zo_callLater(function() SPC.Countdown(count - 1) end, 1750)	
	end
end

function SPC.Clear()
	-- Clear everything
	SPC.myQueuedEmote = nil
	SPC.ReadyPlayer1 = nil
	SPC.Player1Emote = nil
	SPC.ReadyPlayer2 = nil
	SPC.Player2Emote = nil
	SPC.inCountdown = false
end

function SPC.CheckForThrow()
	-- If Both Players are ready and not in countdown then Throw
	if (SPC.ReadyPlayer1 ~= nil) and (SPC.ReadyPlayer2 ~= nil) and (not SPC.inCountdown) then
		-- Both Players ready so throw out my emote if I'm one of the players
		if SPC.ReadyPlayer1 == 'You' or SPC.ReadyPlayer2 == 'You' then
			SPC.Original_PlayEmoteByIndex(SPC.myQueuedEmote)
			--d('You emoted: '..SPC.myQueuedEmote)
			-- broadcast the actual emote							
			PingMap(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, SPC.CalcMapPoint(SPC.code[SPC.myQueuedEmote]), SPC.CalcMapPoint(SPC.spcIdentityCode))			
		end
	end
end

function SPC.CheckForResults()
	-- If both players have thrown and not in the countdown then we have results
	if (SPC.Player1Emote ~= nil) and (SPC.Player2Emote ~= nil) and (not SPC.inCountdown) then
		zo_callLater(function() 				
			-- Wait 3 seconds for the emotes to go off and then declare winner
			d(SPC.GetName(SPC.ReadyPlayer1).." threw ".. SPC.emoteText[SPC.Player1Emote].. ".")
			d(SPC.GetName(SPC.ReadyPlayer2).." threw ".. SPC.emoteText[SPC.Player2Emote].. ".")
			if SPC.Player1Emote == SPC.Player2Emote then
				-- tie
				d("Everyone threw ".. SPC.emoteText[SPC.Player1Emote]..".  It's a tie.")
			elseif ((SPC.Player1Emote == SPC.soulgemEmoteIndex) and (SPC.Player2Emote == SPC.clippersEmoteIndex)) 
				or ((SPC.Player1Emote == SPC.clippersEmoteIndex) and (SPC.Player2Emote == SPC.parchmentEmoteIndex))
				or ((SPC.Player1Emote == SPC.parchmentEmoteIndex) and (SPC.Player2Emote == SPC.soulgemEmoteIndex)) then
				-- Player 1 wins
				d(SPC.GetWinMessage(SPC.ReadyPlayer1, SPC.ReadyPlayer2))
			else
				-- Player 2 Wins
				d(SPC.GetWinMessage(SPC.ReadyPlayer2, SPC.ReadyPlayer1))
			end
			-- Clear everything
			SPC.Clear()
		end, 3000)
	end	
end

function SPC.GetName(unitTag)
	if unitTag == 'You' then
		return 'You'
	else
		return GetUnitDisplayName(unitTag);
	end
end

function SPC.GetWinMessage(winner, loser)
	if winner == 'You' then
		SPC.Original_PlayEmoteByIndex(SPC.winnerEmotes[ math.random( #SPC.winnerEmotes ) ])
		return 'You Win!!'
	else
		if loser == 'You' then
			SPC.Original_PlayEmoteByIndex(SPC.loserEmotes[ math.random( #SPC.loserEmotes ) ])
		end
		return GetUnitDisplayName(winner) .. ' Wins!!';
	end
end	

local function HandleMapPing(eventCode, pingEventType, pingType, pingTag, x, y, isPingOwner)

	--d('pingType: '..pingType)
	--d('pingTag: '..pingTag)
	--d('x: '..x)
	--d('y: '..y)	
	--d('x code: '..SPC.CalcCode(x))
	--d('y code: '..SPC.CalcCode(y))	

	if (pingEventType == PING_EVENT_ADDED and pingType == MAP_PIN_TYPE_PING and SPC.CalcCode(y) == SPC.spcIdentityCode and IsUnitGrouped("player")) then 
	
		if isPingOwner then pingTag = 'You' end

		--d('SPC.CalcCode(x): '..SPC.CalcCode(x))
		if SPC.CalcCode(x) == SPC.countDownCode then
			SPC.Countdown(3)
		end		
		if SPC.CalcCode(x) == SPC.readyCode then
			if (SPC.ReadyPlayer1 == nil and SPC.ReadyPlayer2 ~= pingTag) or SPC.ReadyPlayer1 == pingTag then
				SPC.ReadyPlayer1 = pingTag
			else
				if (SPC.ReadyPlayer2 == nil and SPC.ReadyPlayer1 ~= pingTag) or SPC.ReadyPlayer2 == pingTag then
					SPC.ReadyPlayer2 = pingTag
	
					SPC.CheckForThrow()
				end
			end
		end
		if SPC.emote[SPC.CalcCode(x)] ~= nil then
			if SPC.ReadyPlayer1 == pingTag then
				SPC.Player1Emote = SPC.emote[SPC.CalcCode(x)]
			end
			if SPC.ReadyPlayer2 == pingTag then
				SPC.Player2Emote = SPC.emote[SPC.CalcCode(x)]
			end
			SPC.CheckForResults()
		end
	end
	-- TBD (timeout)
	if (false and pingEventType == PING_EVENT_REMOVED and pingType == MAP_PIN_TYPE_PING) then
		-- Timeout so just throw anything queued and clear round
		if SPC.myQueuedEmote then 
			SPC.Original_PlayEmoteByIndex(SPC.myQueuedEmote)
		end
		SPC.Clear()
	end
end

local function OnAddOnLoaded(eventCode, addOnName)
	if addOnName == 'SPC' then
		EVENT_MANAGER:RegisterForEvent('SPC', EVENT_MAP_PING, HandleMapPing)

		SPC.code = {}
		SPC.code[SPC.soulgemEmoteIndex] = SPC.soulgemCode
		SPC.code[SPC.parchmentEmoteIndex] = SPC.parchmentCode
		SPC.code[SPC.clippersEmoteIndex] = SPC.clipperCode

		SPC.emote = {}
		SPC.emote[SPC.soulgemCode] = SPC.soulgemEmoteIndex
		SPC.emote[SPC.parchmentCode] = SPC.parchmentEmoteIndex
		SPC.emote[SPC.clipperCode] = SPC.clippersEmoteIndex
		
		SPC.emoteText = {}	
		_, _, _, SPC.emoteText[SPC.soulgemEmoteIndex] = GetEmoteInfo(SPC.soulgemEmoteIndex)
		_, _, _, SPC.emoteText[SPC.parchmentEmoteIndex] = GetEmoteInfo(SPC.parchmentEmoteIndex)
		_, _, _, SPC.emoteText[SPC.clippersEmoteIndex] = GetEmoteInfo(SPC.clippersEmoteIndex)

		SPC.Clear()
	end
end

function SPC.ListEmotes()
	for emoteIndex = 1, GetNumEmotes() do
		local lockedByCollectibleId = GetEmoteCollectibleId(emoteIndex)	
		local special = ''
		if lockedByCollectibleId then
			special = '*'
			if IsCollectibleUnlocked(lockedByCollectibleId) then
				special = '**'
			end
		end
		local emoteSlashName, emoteCategory, emoteId, displayName, showInGamepadUI = GetEmoteInfo(emoteIndex)
		d(emoteIndex .. ') ' .. emoteSlashName .. '  ' .. displayName .. special)
	end
end


EVENT_MANAGER:RegisterForEvent('SPC', EVENT_ADD_ON_LOADED, OnAddOnLoaded)
