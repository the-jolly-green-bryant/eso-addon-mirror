--	============================================================================================================================
--
--	The Elder Scrolls Online
--	------------------------
--
--	Game-Informations AddON für The Elder Scrolls Online
--
--
--	Dieses AddON zeigt die freien und belegten Bank- und/oder Taschenplätze (in einem frei bewegbaren Fenster), sowie auf Wunsch
--	Informationen über die mit diesem Character gespielte Zeit im Chatfenster an
--
--	Nachdem TESO leider verschweigt was gelootet wurde wenn "automatisch einsammeln" aktiviert ist, kann der
--	Name der gelooteten Gegenstände (und/oder Gold) auf Wunsch ebenso im Chatfenster ausgegeben werden
--
--	Ich hoffe, Euch macht das Spiel genauso viel Spass wie mir und wer weiss...	vielleicht trifft man sich irgendwann...
--	irgendwo in den Weiten Tamriels (*flüstert der Wind als die Schemen verwehen - Stille kehrt wieder ein*)
--
--
--	(c) im Mai 2014		@Sternentau
--
--	============================================================================================================================


GI = {}
GI.name="GameInfo"
GI.version="3.3"
GI.loaded=false


function GI.Ready4Action()
	if GI.PlayerReady==false then
		GI.HourBreak=GetSecondsPlayed()+2
		GI.DisplayAttrib(GI.vars.DisplayAttrib)
		GI.DisplayStufe(GI.vars.DisplayStufe)
		GI.PlayerReady=true
	end
end


function GI.ColorStart(colorHTML)
	return "|c"..string.sub(colorHTML,1,6)
end


function GI.sendMessage(message)
	if(CHAT_SYSTEM)	then
		CHAT_SYSTEM:AddMessage(message)
	end
end


function GI.strStrip(message)
	local pos
	pos=string.find(message,"^",1,true)
	if pos==nil then
		return(message)
	else
		return string.sub(message,1,pos-1)
	end
end


function GI.ItemStrip(message)
	local temp=""
	local blocker=0
	for looper=1,string.len(message),1 do
		local checker=string.sub(message,looper,looper)
		if blocker==0 then
			if checker=="^" then
				blocker=20
			else
				temp=temp..checker
			end
		else
			if string.find("^ABCDEFGHIJKLMNOPQRSTUVWXYZÖÄÜßabcdefghijklmnopqrstuvwxyzöäü.,:[",checker,1,true)~=nil then
				-- nichts, maximal 20 werden ausgeschnitten
				blocker=blocker-1
			else
				--ist schon kein Buchstabe mehr - wieder anfügen
				blocker=0
				temp=temp..checker
			end
		end
	end
	return temp
end


function GI.strNum2(nZahl)
	local xret
	if nZahl<1 then
		xret="00"
	else
		xret=tostring(nZahl)
		if nZahl<10 then
			xret="0"..xret
		end
	end
	return xret
end


function GI.strPlayTime(tPlayed, bClockType)
	local seconds
	local minutes
	local hours
	local days
	local strplayed
	hours=0
	seconds=tPlayed
	days=math.floor(seconds / 86400)
	seconds=seconds-days*86400
	hours=math.floor(seconds / 3600)
	seconds=seconds-hours*3600
	minutes=math.floor(seconds/60)
	seconds=seconds-minutes*60
	strplayed=""
	if bClockType==true then
		if days>0 then
			strplayed=strplayed .. tostring(days) .. " " .. GI.locPlayTimeDays
			strplayed=strplayed .. ", "
		end
		if hours>0 then
			strplayed=strplayed .. tostring(hours) .. " " .. GI.locPlayTimeHours
			strplayed=strplayed .. ", "
		end
		if minutes>0 then
			strplayed=strplayed .. tostring(minutes) .. " " .. GI.locPlayTimeMinutes
			strplayed=strplayed .. ", "
		end
		if seconds>0 then
			strplayed=strplayed .. tostring(seconds) .. " " .. GI.locPlayTimeSeconds
		end
	else
		if days>0 then
			strplayed=strplayed+strNum2(days) .. ":"
			strplayed=strplayed .. ":"
		end
		if ((hours>0) or (days>0)) then
			strplayed=strplayed .. GI.strNum2(hours)
			strplayed=strplayed .. ":"
		end
		strplayed=strplayed .. GI.strNum2(minutes) .. ":" .. GI.strNum2(seconds)
	end
	return strplayed
end


function GI.DisplayStufe(displayMe)
	if displayMe==true then
		HUD_SCENE:AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
		HUD_SCENE:AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
		HUD_UI_SCENE:AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
		HUD_UI_SCENE:AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
	else
		HUD_SCENE:RemoveFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
		HUD_SCENE:RemoveFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
		HUD_UI_SCENE:RemoveFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
	end
end


function GI.DisplayAttrib(displayMe)
	local minAlpha=0
	if displayMe==true then minAlpha=1 end
	ZO_PlayerAttributeHealth.playerAttributeBarObject.timeline:GetAnimation():SetAlphaValues(minAlpha,1)
	ZO_PlayerAttributeStamina.playerAttributeBarObject.timeline:GetAnimation():SetAlphaValues(minAlpha,1)
	ZO_PlayerAttributeMagicka.playerAttributeBarObject.timeline:GetAnimation():SetAlphaValues(minAlpha,1)
	ZO_PlayerAttributeHealth:SetAlpha(minAlpha)
	ZO_PlayerAttributeMagicka:SetAlpha(minAlpha)
	ZO_PlayerAttributeStamina:SetAlpha(minAlpha)
end


function GI.SlashGI()
	GI.sendMessage(GI.ColorStart(GI.vars.ColorWelcome)..GI.locWorldPosition..GI.strStrip(GetUnitZone("player")) .. ", " .. GetUnitName("player")..GI.ColorEnd)
	GI.DisplayGuildInfo()
	GI.DisplayPlayTime(true)
end


function GI.clearQueue()
	GI.QueuedGold=0
	GI.QueuedXP=0
	GI.QueuedVP=0
	GI.QueuedLoot={}
	GI.QueuedLootindex=0
end


function GI.sendQueuedLoot()
	if (GI.loaded == true) then
		local temp=""
		-- den Loot ausgeben, wenn vorhanden und gewünscht
		if (GI.vars.LootMsg==true) then
			if GI.QueuedLootindex>0 then
				temp=temp..GI.ColorStart(GI.vars.ColorLoot)
				local looper=0
				while looper<GI.QueuedLootindex do
					looper=looper+1
					temp=temp..GI.QueuedLoot[looper].." "
				end
				temp=temp..GI.locLootGained..GI.ColorEnd.." "
			end
		end
		-- XP ausgeben, wenn vorhanden und gewünscht
		if GI.vars.LootXPMsg==true then
			if GI.QueuedXP>0 then
				temp=temp..GI.ColorStart(GI.vars.ColorAmount)..tostring(GI.QueuedXP)..GI.ColorEnd.." "..GI.ColorStart(GI.vars.ColorXPVP)..GI.locXPGained.." "..GI.ColorEnd
			end
			if GI.QueuedVP>0 then
				temp=temp..GI.ColorStart(GI.vars.ColorAmount)..tostring(GI.QueuedVP)..GI.ColorEnd.." "..GI.ColorStart(GI.vars.ColorXPVP)..GI.locVPGained.." "..GI.ColorEnd
			end
		end
		-- Gold ausgeben, wenn vorhanden und gewünscht
		if(GI.vars.LootGoldMsg==true) then
			if GI.QueuedGold~=0 then
				if GI.QueuedGold>0 then
					temp=temp..GI.ColorStart(GI.vars.ColorAmount)..tostring(GI.QueuedGold)..GI.ColorEnd.." "..GI.ColorStart(GI.vars.ColorLoot)..GI.locMoneyGained.." "..GI.ColorEnd
				else
					temp=temp..GI.ColorStart(GI.vars.ColorAmount)..tostring(0-GI.QueuedGold)..GI.ColorEnd.." "..GI.ColorStart(GI.vars.ColorLoot)..GI.locMoneyPayed.." "..GI.ColorEnd
				end
			end
		end
		GI.sendMessage(temp)
		-- alles ausgegeben, die Queue löschen
		GI.clearQueue()
	end
end


function GI.LootMessage(eventId, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
	-- Nur ausführen, wenn Das AddON schon geladen ist
	if (GI.loaded == true) then
		if(GI.vars.LootMsg==true) then
			if (isNewItem==true) then
				GI.QueuedLootindex=GI.QueuedLootindex+1
				GI.QueuedLoot[GI.QueuedLootindex]=GI.ItemStrip(GetItemLink(bagId, slotId,LINK_STYLE_BRACKETS))
			end
		end
	end
end

	
function GI.MoneyMessage(eventID, newMoney, oldMoney, updateReason)
	-- Nur ausführen, wenn Das AddON schon geladen ist
	if (GI.loaded == true) then
		if(GI.vars.LootGoldMsg==true) then
			GI.QueuedGold=GI.QueuedGold+(newMoney-oldMoney)
		end
	end
end

	
function GI.GainedXP(eventCode, unitTag, currentXP, maxXP, reasonCode)
	if GI.loaded==true then
		if ((unitTag=="player") and (IsUnitVeteran(unitTag)==false)) then
			local XPEarned=currentXP-GI.PlayerXP
			if (XPEarned>=1) then
				if GI.vars.LootXPMsg==true then
					GI.QueuedXP=GI.QueuedXP+XPEarned
				end
			end
			GI.PlayerXP=currentXP	
		end
	end
end


function GI.GainedVP(eventCode, unitTag, currentVP, maxVP, reasonCode)
	if GI.loaded==true then
		if ((unitTag=="player") and (IsUnitVeteran(unitTag)==true)) then
			local VPEarned = currentVP-GI.PlayerVP
			if (VPEarned>=1) then
				if GI.vars.LootXPMsg==true then
					GI.QueuedVP=GI.QueuedVP+VPEarned
				end
			end
			GI.PlayerVP=currentVP
		end
	end
end


function GI.UpdateThrottle(key, frequency)
	if key == nil then return end
	if GI.throttle[key] == nil then GI.throttle[key] = {} end
	GI.throttle[key].frequency = frequency or 10
	GI.throttle[key].now = GetFrameTimeMilliseconds()
	if GI.throttle[key].last == nil then GI.throttle[key].last = GI.throttle[key].now end
	GI.throttle[key].diff = GI.throttle[key].now - GI.throttle[key].last
	GI.throttle[key].eval = GI.throttle[key].diff >= GI.throttle[key].frequency
	if GI.throttle[key].eval then GI.throttle[key].last = GI.throttle[key].now end
	return GI.throttle[key].eval
end


function GI.DisplayPlayTime(bDisplayThisSession)
	local strplayed=GI.locPlayedSession .. GI.strPlayTime(GetSecondsPlayed()-GI.StartTime,false)
	if (bDisplayThisSession==true) then
		GI.sendMessage(GI.ColorStart(GI.vars.ColorPlayTime)..strplayed..GI.ColorEnd)
	end
	strplayed=GI.locPlayedEver .. GI.strPlayTime(GetSecondsPlayed(),true)
	GI.sendMessage(GI.ColorStart(GI.vars.ColorPlayTime)..strplayed..GI.ColorEnd)
end


function GI.ProcessTimer()
	-- Nur ausführen, wenn das AddON schon geladen ist
	if (GI.loaded==true) then
		-- Nur ausführen, wenn die Verzögerungszeit abgelaufen ist (oder zum Start)
		if (GetSecondsPlayed()>=GI.HourBreak) then
			-- Nur ausführen, wenn der Spieler schon bereit ist
			if (GI.PlayerReady==true) then
				-- Beim Start die Begrüssungsformel sprechen
				if (GI.Welcome==false) then
					if (GI.vars.InfoOnEnter==true) then
						GI.sendMessage(GI.ColorStart(GI.vars.ColorWelcome)..GI.locWelcome .. GI.strStrip(GetUnitZone("player")) .. ", " .. GetUnitName("player")..GI.ColorEnd)
					end
					if (GI.vars.FpsOnEnter==true) then
						GI.sendMessage(GI.ColorStart(GI.vars.ColorPlayTime)..GI.locFrameRate .. tostring(math.floor(GetFramerate()*10)/10) .. " fps"..GI.ColorEnd)
					end
					if (GI.vars.InfoOnEnter==true) then
						GI.DisplayPlayTime(false)
					end
					if (GI.vars.GmiOnEnter==true) then
						GI.DisplayGuildInfo()
					end
					GI.Welcome=true
				else
					-- ansonsten zyklisch berichten, wenn dies gewünscht
					if (GI.vars.InfoCyclic==true) then
						GI.DisplayPlayTime(true)
					end
				end
				GI.HourBreak=GetSecondsPlayed()+GI.vars.ReportingMinutes*60
			end
		end
	end
end


function GI.BankOpen()
	GI.BankIsOpen=true
	-- Die Bankplätze anzeigen, sobald die Bank geoeffnet wird
	GI.BankInfoFade(GI.vars.BankInfo)
end


function GI.BankClose()
	GI.BankIsOpen=false
	-- Die Bankplaetze wieder normal anzeigen (wie in den Einstellungen festgelegt)
	GI.BankInfoFade(GI.vars.BankInfo)
end


function GI.hasToHide()
	local keybindIsHidden=not ZO_KeybindStripControl:IsHidden()
	if GI.BankIsOpen==true then
		-- nicht schliessen, wenn die Bank geoeffnet ist
		keybindIsHidden=false
	end
	return keybindIsHidden
end


function GI.ManageSpaceDisplay()
	local usedSlots, maxSlots=PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
	local BankSlots=GetBagSize(BAG_BANK)
	local usedBankSlots=GetNumBagUsedSlots(BAG_BANK)
	-- Farbroutine für die Anzeige, herzlichen Dank an PaulDenton
	local usedBagPercent=tonumber(usedSlots) * 100 / tonumber(maxSlots)
	local cs=GI.ColorStart(GI.vars.ColorSpaceOK)
	if usedBagPercent>99 then
		cs=GI.ColorStart(GI.vars.ColorSpaceFULL)
	else
		if usedBagPercent>=GI.vars.BagsSpaceAlertThreshold then
			cs=GI.ColorStart(GI.vars.ColorSpaceALERT)
		else
			if usedBagPercent>=GI.vars.BagsSpaceWarnThreshold then
				cs=GI.ColorStart(GI.vars.ColorSpaceWARN)
			end
		end
	end
	local cb=GI.ColorStart(GI.vars.ColorSpaceOK)
	local usedBankPercent=tonumber(usedBankSlots) * 100 / tonumber(BankSlots)
	if usedBankPercent>99 then
		cb=GI.ColorStart(GI.vars.ColorSpaceFULL)
	else
		if usedBankPercent>=GI.vars.BankSpaceAlertThreshold then
			cb=GI.ColorStart(GI.vars.ColorSpaceALERT)
		else
			if usedBankPercent>=GI.vars.BankSpaceWarnThreshold then
				cb=GI.ColorStart(GI.vars.ColorSpaceWARN)
			end
		end
	end
	usedSlots=cs..tostring(usedSlots)..GI.ColorEnd
	usedBankSlots=cb..tostring(usedBankSlots)..GI.ColorEnd
	-- Texte einblenden
	local isInCombat=IsUnitInCombat("player")
	if isInCombat==false then
		if GI.vars.SpaceInfo==true then
			GameInfoPanelCount:SetText(usedSlots.." / "..maxSlots)
		end
		if GI.vars.BankInfo==true then
			GameInfoPanelCountB:SetText(usedBankSlots.." / "..BankSlots)
		end
	end
	-- Kampficons einblenden, wenn im Kampf und das auch gewünscht war
	if (GI.vars.ReportInCombat==true) then
		if (isInCombat==true) then
			-- im Kampf, Symbole einblenden, wenn nicht aktiv
			if GI.combatSymbols==false then
				GI.combatSymbols=true
				GameInfoPanelBag:SetTexture("/esoui/art/mappins/ava_3way.dds")
				GameInfoPanelBank:SetTexture("/esoui/art/mappins/ava_3way.dds")
				-- Texte ueberschreiben, wenn im Kampf - ansonsten die Normaltexte stehenlassen
				if GI.vars.SpaceInfo==true then
					GameInfoPanelCount:SetText(GI.locCombat)
				end
				if GI.vars.BankInfo==true then
					GameInfoPanelCountB:SetText(GI.locCombat)
				end
			end
		else
			-- kein Kampf mehr, Symbole ausblenden, wenn noch aktiv
			if GI.combatSymbols==true then
				GI.combatSymbols=false
				GameInfoPanelBag:SetTexture("/esoui/art/menubar/menubar_inventory_over.dds")
				GameInfoPanelBank:SetTexture("ESOUI/art/icons/servicemappins/servicepin_bank.dds")
			end
		end
	else
		if GI.vars.SpaceInfo==true then
			GameInfoPanelCount:SetText(usedSlots.." / "..maxSlots)
		end
		if GI.vars.BankInfo==true then
			GameInfoPanelCountB:SetText(usedBankSlots.." / "..BankSlots)
		end
	end
end


-- Callback für das AddON-Fenster
function GI.PanelUpdate()
	-- Nur ausführen, wenn Das AddON schon geladen ist
	if (GI.loaded == true) then
		-- Die Frequenz ein wenig herunterbremsen, sonst behindern wir das gesamte Spiel
		if (GI.UpdateThrottle("Update", 800) == true) then
			-- Das Fenster ausblenden, wenn die Oberfläche wegfaded
			if GI.hasToHide()==true then
				GameInfoPanel:SetAlpha(0)
			else
				GameInfoPanel:SetAlpha(1)
				GI.ManageSpaceDisplay()
			end
			-- Nachsehen, ob zeitgesteuerte Nachrichten in den Chat geschrieben werden sollen...
			GI.ProcessTimer()
			-- Loot ausgeben, wenn etwas aufgenommen wurde
			GI.sendQueuedLoot()
		end
	end
end


function GI.MoveStop()
	-- der Anwender hat das Fenster verschoben - das merken wir uns
	GI.vars.offsetX = GameInfoPanel:GetLeft()
	GI.vars.offsetY = GameInfoPanel:GetTop()
end

function GI.SpaceInfoFade(fade)
	if fade==false then
		GameInfoPanelBag:SetAlpha(0)
		GameInfoPanelCount:SetAlpha(0)
	else
		GameInfoPanelBag:SetAlpha(1)
		GameInfoPanelCount:SetAlpha(1)
	end
end

function GI.BankInfoFade(fade)
	if fade==false then
		GameInfoPanelBank:SetAlpha(0)
		GameInfoPanelCountB:SetAlpha(0)
	else
		GameInfoPanelBank:SetAlpha(1)
		GameInfoPanelCountB:SetAlpha(1)
	end
end

function GI.UpdateLockStatus(newValue)
	GI.vars.lockWindowPosition = newValue
	GameInfoPanel:SetMovable(not GI.vars.lockWindowPosition)
	GameBuffDisplay:SetMovable(not GI.vars.lockWindowPosition)
end


-- Callback für das AddON-Fenster (Buffs)
function GI.BuffUpdate()
	-- Nur ausführen, wenn Das AddON schon geladen ist
	if (GI.loaded == true) then
		-- Die Frequenz ein wenig herunterbremsen, sonst behindern wir das gesamte Spiel
		if (GI.UpdateThrottle("BuffUpdate", 500) == true) then
			local keybindIsHidden=ZO_KeybindStripControl:IsHidden()
			-- Das Fenster ausblenden, wenn die Oberfläche wegfaded
			if (keybindIsHidden == false) then
				GameBuffDisplay:SetAlpha(0)
			else
				GameBuffDisplay:SetAlpha(1)
			end
			if (GI.vars.DisplayBuffs == false) then
				GameBuffDisplay:SetAlpha(0)
			end
			local Buffs=GetNumBuffs("player")
			local Looper=1
			while Looper<=9 do
				if Looper<=Buffs then
					local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType = GetUnitBuffInfo("player", Looper)
					_G["GameBuffDisplayBuff"..Looper]:SetTexture(iconFilename)
					_G["GameBuffDisplayBuff"..Looper]:SetAlpha(1.0)
				else
					_G["GameBuffDisplayBuff"..Looper]:SetTexture(nil)
					_G["GameBuffDisplayBuff"..Looper]:SetAlpha(0.1)
				end
				Looper=Looper+1
			end
		end
	end
end

function GI.BuffMoveStop()
	-- der Anwender hat das Fenster verschoben - das merken wir uns
	GI.vars.BuffoffsetX = GameBuffDisplay:GetLeft()
	GI.vars.BuffoffsetY = GameBuffDisplay:GetTop()
end


function GI.HexToN(sHexVal)
	local Nibble1=0
	local Nibble2=0
	Nibble1, Nibble2=string.byte(sHexVal,1,2)
	if Nibble1>=65 then
		Nibble1=Nibble1-55
	else
		Nibble1=Nibble1-48
	end
	if Nibble2>=65 then
		Nibble2=Nibble2-55
	else
		Nibble2=Nibble2-48
	end
	local Byte=Nibble1*16+Nibble2
	return Byte/255
end


function GI.nToHex(nWert)
	local Byte=nWert*255
	local Nibble1=math.floor(Byte/16)
	local Nibble2=Byte-(Nibble1*16)
	local Part1=string.char(Nibble1+48)
	local Part2=string.char(Nibble2+48)
	if Nibble1>9 then
		Part1=string.char(Nibble1+55)
	end
	if Nibble2>9 then
		Part2=string.char(Nibble2+55)
	end
	return Part1 .. Part2
end


function GI.ColorToHTML(r,g,b,a)
	local temo=GI.nToHex(r)..GI.nToHex(g)..GI.nToHex(b)
	return temo
end


function GI.ColorToRGB()
	GI.ColorPlayTime_r=GI.HexToN(string.sub(GI.vars.ColorPlayTime,1,2))
	GI.ColorPlayTime_g=GI.HexToN(string.sub(GI.vars.ColorPlayTime,3,4))
	GI.ColorPlayTime_b=GI.HexToN(string.sub(GI.vars.ColorPlayTime,5,6))
	GI.ColorPlayTime_a=GI.HexToN(string.sub(GI.vars.ColorPlayTime,7,8))
	GI.ColorLoot_r=GI.HexToN(string.sub(GI.vars.ColorLoot,1,2))
	GI.ColorLoot_g=GI.HexToN(string.sub(GI.vars.ColorLoot,3,4))
	GI.ColorLoot_b=GI.HexToN(string.sub(GI.vars.ColorLoot,5,6))
	GI.ColorLoot_a=GI.HexToN(string.sub(GI.vars.ColorLoot,7,8))
	GI.ColorXPVP_r=GI.HexToN(string.sub(GI.vars.ColorXPVP,1,2))
	GI.ColorXPVP_g=GI.HexToN(string.sub(GI.vars.ColorXPVP,3,4))
	GI.ColorXPVP_b=GI.HexToN(string.sub(GI.vars.ColorXPVP,5,6))
	GI.ColorXPVP_a=GI.HexToN(string.sub(GI.vars.ColorXPVP,7,8))
end


function GI.Stufenanzeige()
	local expAnim
	expAnim = ZO_ExperienceBar.owner.fadeTimeline:GetFirstAnimation()
	expAnim:SetStartAlpha(1)
	expAnim:SetEndAlpha(1)
	expAnim = ZO_ExperienceBar.owner.fadeTimeline:GetLastAnimation()
	expAnim:SetStartAlpha(1)
	expAnim:SetEndAlpha(1)
	ZO_ExperienceBar:SetHidden(false)
end


function GI.DisplayGuildInfo()
	for gLooper=1,5,1 do
		local guildID=GetGuildId(gLooper)
		if guildID>0 then
			local guildName=GetGuildName(guildID)
			local guildMembers=GetNumGuildMembers(guildID) 
			local nOnline=0
			for looper=1,guildMembers,1 do
				local xname, xnote, xrankIndex, xplayerStatus, xsecsSinceLogoff=GetGuildMemberInfo(guildID, looper)
				-- grundsaetzlich anzeigen
				if xplayerStatus<4 then
					-- Spieler ist online
					nOnline=nOnline+1
				end
			end
			local temp=guildName..": "..nOnline.."/"..guildMembers..GI.locGMonline
			GI.sendMessage(GI.ColorStart(GI.vars.ColorPlayTime)..temp..GI.ColorEnd)
		end
	end
end


function GI.setAlignment(alignment)
	if alignment==true then
		_G["GameBuffDisplay"]:SetDimensions(315,20)
		for looper=1,9,1 do
			_G["GameBuffDisplayBuff"..looper]:ClearAnchors()
			if looper>1 then
				_G["GameBuffDisplayBuff"..looper]:SetAnchor(TOPLEFT, _G["GameBuffDisplayBuff"..looper-1], TOPRIGHT, 5, 0)
			else
				_G["GameBuffDisplayBuff"..looper]:SetAnchor(TOPLEFT, _G["GameBuffDisplay"], TOPLEFT, 0, 0)
			end
		end
	else
		_G["GameBuffDisplay"]:SetDimensions(20,315)
		for looper=1,9,1 do
			_G["GameBuffDisplayBuff"..looper]:ClearAnchors()
			if looper>1 then
				_G["GameBuffDisplayBuff"..looper]:SetAnchor(TOPLEFT, _G["GameBuffDisplayBuff"..looper-1], BOTTOMLEFT, 0, 5)
			else
				_G["GameBuffDisplayBuff"..looper]:SetAnchor(TOPLEFT, _G["GameBuffDisplay"], TOPLEFT, 0, 0)
			end
		end
	end
end


function GI.Initialize(eventCode, addOnName)
	if (GI.name == addOnName) then
		GI.defaults = {
			InfoOnEnter=true,
			FpsOnEnter=false,
			InfoCyclic=true,
			LootMsg=true,
			LootGoldMsg=true,
			LootXPMsg=true,
			ReportingMinutes=30,
			ReportInCombat=true,
			GmiOnEnter=true,
			SpaceInfo=true,
			BankInfo=true,
			DisplayBuffs=true,
			lockWindowPosition=false,
			DisplayStufe=true,
			DisplayAttrib=true,
			offsetX=0,
			offsetY=0,
			BuffoffsetX=0,
			BuffoffsetY=0,
			ColorWelcome="FCFCFCFF",
			ColorAmount="FCFCFCFF",
			ColorPlayTime="E6E6AAFF",
			ColorLoot="C5C29EFF",
			ColorXPVP="C5C29EFF",
			ColorSpaceOK="FCFCFC",
			ColorSpaceWARN="FCFC00",
			ColorSpaceALERT="E68200",
			ColorSpaceFULL="FC0000",
			BagsSpaceWarnThreshold=85,
			BagsSpaceAlertThreshold=95,
			BankSpaceWarnThreshold=85,
			BankSpaceAlertThreshold=95,
			horizontAlignmentBuff=true,
		}
		GI.ColorEnd="|r"
		GI.throttle = {}
		-- Die Variablen laden
		GI.vars = ZO_SavedVars:NewAccountWide("GIVars", 2, nil, GI.defaults)
		-- Nachrichtenfarben generieren
		GI.ColorToRGB()
		-- Spracheinstellung laden, wenn Sprachdatei vorhanden
		if GI.LoadLocalization then
			GI.LoadLocalization()
		else
			GI.LoadDefaultLocalization()
		end
		-- Das Einstellungsfenster aufbauen
		local ReportOpts = {
			[1] = "5",
			[2] = "10",
			[3] = "15",
			[4] = "20",
			[5] = "30",
			[6] = "45",
			[7] = "60",
			[8] = "90",
			[9] = "120",
		}
        local panelData = {
            type = "panel",
            name = "Gameinfo 3",
            displayName = "|c00B5FF" .. "Game Information" .. "|r",
            author = "@Sternentau",
            version = GI.version,
            registerForRefresh = true,
            registerForDefaults = true,
        }
		local optionsData = {
			[1] = {
				type = "header",
				name = GI.locTimeEinstellungen,
				reference = "GI.TimeConfig",
				},
			[2] = {
				type = "checkbox",
				name = GI.locInfoOnEnterConfig,
				tooltip = GI.locInfoOnEnterConfigDsc,
				getFunc = function() return GI.vars.InfoOnEnter end,
				setFunc = function() GI.vars.InfoOnEnter = not GI.vars.InfoOnEnter end,
				width = "full",
				default = GI.defaults.InfoOnEnter,
				reference = "GI.InfoOnEnterConfig",
				},
			[3] = {
				type = "checkbox",
				name = GI.locInfoCyclicConfig,
				tooltip = GI.locInfoCyclicConfigDsc,
				getFunc = function() return GI.vars.InfoCyclic end,
				setFunc = function() GI.vars.InfoCyclic = not GI.vars.InfoCyclic end,
				width = "full",
				default = GI.defaults.InfoCyclic,
				reference = "GI.InfoCyclicConfig",
				},
			[4] = {
				type = "dropdown",
				name = GI.locReportingConfig,
				tooltip = GI.locReportingConfigDsc,
				choices = ReportOpts,
				getFunc = function() return GI.vars.ReportingMinutes end,
				setFunc = function(val)	GI.vars.ReportingMinutes=val GI.HourBreak=GetSecondsPlayed() end,
				width = "full",
				default = GI.defaults.ReportingMinutes,
				disabled = function() return not GI.vars.InfoCyclic end,
				reference = "GI.ReportingConfig",
				},
			[5] = {
				type = "colorpicker",
				name = GI.locReportingColorConfig,
				tooltip = GI.locReportingColorConfigDsc,
				getFunc = function() return GI.ColorPlayTime_r,GI.ColorPlayTime_g,GI.ColorPlayTime_b,GI.ColorPlayTime_a	end,
				setFunc = function(r,g,b,a)	GI.ColorPlayTime_r=r GI.ColorPlayTime_g=g GI.ColorPlayTime_b=b GI.ColorPlayTime_a=a GI.vars.ColorPlayTime=GI.ColorToHTML(r,g,b,a) end,
				width = "full",
				disabled = false,
				reference = "GI.ReportingColorConfig"
				},
			[6] = {
				type = "header",
				name = GI.locInfoEinstellungen,
				reference = "GI.InfoConfig",
				},
			[7] = {
				type = "checkbox",
				name = GI.locSpaceInfoConfig,
				tooltip = GI.locSpaceInfoConfigDsc,
				getFunc = function() return GI.vars.SpaceInfo end,
				setFunc = function() GI.vars.SpaceInfo = not GI.vars.SpaceInfo GI.SpaceInfoFade(GI.vars.SpaceInfo) end,
				width = "full",
				default = GI.defaults.SpaceInfo,
				reference = "GI.SpaceInfoConfig",
				},
			[8] = {
				type = "slider",
				name = GI.locSpaceInfoWarnConfig,
				tooltip = GI.locSpaceInfoWarnConfigDsc,
				min = 1,
				max = 100,
				getFunc = function() return GI.vars.BagsSpaceWarnThreshold end,
				setFunc = function(value) GI.vars.BagsSpaceWarnThreshold = value end,
				default = GI.defaults.BagsSpaceWarnThreshold,
				disabled = function() return not GI.vars.SpaceInfo end,
				reference = "GI.SpaceInfoWarnConfig",
				},
			[9] = {
				type = "slider",
				name = GI.locSpaceInfoAlertConfig,
				tooltip = GI.locSpaceInfoAlertConfigDsc,
				min = 1,
				max = 100,
				getFunc = function() return GI.vars.BagsSpaceAlertThreshold end,
				setFunc = function(value) GI.vars.BagsSpaceAlertThreshold = value end,
				default = GI.defaults.BagsSpaceAlertThreshold,
				disabled = function() return not GI.vars.SpaceInfo end,
				reference = "GI.SpaceInfoAlertConfig",
				},
			[10] = {
				type = "checkbox",
				name = GI.locBankInfoConfig,
				tooltip = GI.locBankInfoConfigDsc,
				getFunc = function() return GI.vars.BankInfo end,
				setFunc = function() GI.vars.BankInfo = not GI.vars.BankInfo GI.BankInfoFade(GI.vars.BankInfo) end,
				width = "full",
				default = GI.defaults.BankInfo,
				reference = "GI.BankInfoConfig",
				},
			[11] = {
				type = "slider",
				name = GI.locBankInfoWarnConfig,
				tooltip = GI.locBankInfoWarnConfigDsc,
				min = 1,
				max = 100,
				getFunc = function() return GI.vars.BankSpaceWarnThreshold end,
				setFunc = function(value) GI.vars.BankSpaceWarnThreshold = value end,
				default = GI.defaults.BankSpaceWarnThreshold,
				disabled = function() return not GI.vars.BankInfo end,
				reference = "GI.BankInfoWarnConfig",
				},
			[12] = {
				type = "slider",
				name = GI.locBankInfoAlertConfig,
				tooltip = GI.locBankInfoAlertConfigDsc,
				min = 1,
				max = 100,
				getFunc = function() return GI.vars.BankSpaceAlertThreshold end,
				setFunc = function(value) GI.vars.BankSpaceAlertThreshold = value end,
				default = GI.defaults.BankSpaceAlertThreshold,
				disabled = function() return not GI.vars.BankInfo end,
				reference = "GI.BankInfoAlertConfig",
				},
			[13] = {
				type = "checkbox",
				name = GI.locLootMsgConfig,
				tooltip = GI.locLootMsgConfigDsc,
				getFunc = function() return GI.vars.LootMsg end,
				setFunc = function() GI.vars.LootMsg = not GI.vars.LootMsg end,
				width = "full",
				default = GI.defaults.LootMsg,
				reference = "GI.LootMsgConfig",
				},
			[14] = {
				type = "colorpicker",
				name = GI.locLootColorConfig,
				tooltip = GI.locLootColorConfigDsc,
				getFunc = function() return GI.ColorLoot_r,GI.ColorLoot_g,GI.ColorLoot_b,GI.ColorLoot_a	end,
				setFunc = function(r,g,b,a)	GI.ColorLoot_r=r GI.ColorLoot_g=g GI.ColorLoot_b=b GI.ColorLoot_a=a GI.vars.ColorLoot=GI.ColorToHTML(r,g,b,a) end,
				width = "full",
				disabled = function() return not GI.vars.LootMsg end,
				reference = "GI.LootColorConfig"
				},
			[15] = {
				type = "checkbox",
				name = GI.locLootGoldMsgConfig,
				tooltip = GI.locLootGoldMsgConfigDsc,
				getFunc = function() return GI.vars.LootGoldMsg end,
				setFunc = function() GI.vars.LootGoldMsg = not GI.vars.LootGoldMsg end,
				width = "full",
				default = GI.defaults.LootGoldMsg,
				reference = "GI.LootGoldMsgConfig",
				},
			[16] = {
				type = "checkbox",
				name = GI.locLootXPMsgConfig,
				tooltip = GI.locLootXPMsgConfigDsc,
				getFunc = function() return GI.vars.LootXPMsg end,
				setFunc = function() GI.vars.LootXPMsg = not GI.vars.LootXPMsg end,
				width = "full",
				default = GI.defaults.LootXPMsg,
				reference = "GI.LootXPMsgConfig",
				},
			[17] = {
				type = "colorpicker",
				name = GI.locXPVPColorConfig,
				tooltip = GI.locXPVPColorConfigDsc,
				getFunc = function() return GI.ColorXPVP_r,GI.ColorXPVP_g,GI.ColorXPVP_b,GI.ColorXPVP_a	end,
				setFunc = function(r,g,b,a)	GI.ColorXPVP_r=r GI.ColorXPVP_g=g GI.ColorXPVP_b=b GI.ColorXPVP_a=a GI.vars.ColorXPVP=GI.ColorToHTML(r,g,b,a) end,
				width = "full",
				disabled = function() return not GI.vars.LootXPMsg end,
				reference = "GI.XPVPColorConfig"
				},
			[18] = {
				type = "header",
				name = GI.locCombatEinstellungen,
				reference = "GI.CombatConfig",
				},
			[19] = {
				type = "checkbox",
				name = GI.locDisplayBuffsConfig,
				tooltip = GI.locDisplayBuffsConfigDsc,
				getFunc = function() return GI.vars.DisplayBuffs end,
				setFunc = function() GI.vars.DisplayBuffs = not GI.vars.DisplayBuffs end,
				width = "full",
				default = GI.defaults.DisplayBuffs,
				reference = "GI.DisplayBuffsConfig",
				},
			[20] = {
				type = "checkbox",
				name = GI.locDisplayBuffsAlignConfig,
				tooltip = GI.locDisplayBuffsAlignConfigDsc,
				getFunc = function() return GI.vars.horizontAlignmentBuff end,
				setFunc = function(value) GI.vars.horizontAlignmentBuff=value GI.setAlignment(value) end,
				width = "full",
				default = GI.defaults.horizontAlignmentBuff,
				disabled = function() return not GI.vars.DisplayBuffs end,
				reference = "GI.DisplayBuffsAlignConfig",
				},
			[21] = {
				type = "checkbox",
				name = GI.locReportInCombatConfig,
				tooltip = GI.locReportInCombatConfigDsc,
				getFunc = function() return GI.vars.ReportInCombat end,
				setFunc = function() GI.vars.ReportInCombat = not GI.vars.ReportInCombat end,
				width = "full",
				default = GI.defaults.horizontAlignmentBuff,
				reference = "GI.ReportInCombatConfig",
				},
			[22] = {
				type = "header",
				name = GI.locEinstellungen,
				reference = "GI.ConfigConfig",
				},
			[23] = {
				type = "checkbox",
				name = GI.locFpsOnEnterConfig,
				tooltip = GI.locFpsOnEnterConfigDsc,
				getFunc = function() return GI.vars.FpsOnEnter end,
				setFunc = function() GI.vars.FpsOnEnter = not GI.vars.FpsOnEnter end,
				width = "full",
				default = GI.defaults.FpsOnEnter,
				reference = "GI.FpsOnEnterConfig",
				},
			[24] = {
				type = "checkbox",
				name = GI.locReportGMOnEnterConfig,
				tooltip = GI.locReportGMOnEnterConfigDsc,
				getFunc = function() return GI.vars.GmiOnEnter end,
				setFunc = function() GI.vars.GmiOnEnter = not GI.vars.GmiOnEnter end,
				width = "full",
				default = GI.defaults.GmiOnEnter,
				reference = "GI.ReportGMOnEnterConfig",
				},
			[25] = {
				type = "checkbox",
				name = GI.locLockWindowConfig,
				tooltip = GI.locLockWindowConfigDsc,
				getFunc = function() return GI.vars.lockWindowPosition end,
				setFunc = function(newValue) GI.UpdateLockStatus(newValue) end,
				width = "full",
				default = GI.defaults.lockWindowPosition,
				reference = "GI.LockWindowConfig",
				},
			[26] = {
				type = "checkbox",
				name = GI.locDisplayStufeConfig,
				tooltip = GI.locDisplayStufeConfigDsc,
				getFunc = function() return GI.vars.DisplayStufe end,
				setFunc = function(newValue) GI.vars.DisplayStufe=newValue GI.DisplayStufe(newValue) end,
				width = "full",
				default = GI.defaults.DisplayStufe,
				reference = "GI.DisplayStufeConfig",
				},
			[27] = {
				type = "checkbox",
				name = GI.locDisplayAttribConfig,
				tooltip = GI.locDisplayAttribConfigDsc,
				getFunc = function() return GI.vars.DisplayAttrib end,
				setFunc = function(newValue) GI.vars.DisplayAttrib=newValue GI.DisplayAttrib(newValue) end,
				width = "full",
				default = GI.defaults.DisplayAttrib,
				reference = "GI.DisplayAttribConfig",
				},
			[28] = {
				type = "header",
				name = GI.locAddonEinstellungen,
				reference = "GI.AddonConfig",
				},
			[29] = {
				type = "description",
				title = "Version " .. GI.version,
				text = GI.locDescriptionConfig,
				width = "full",
				reference = "GI.DescriptionConfig",
				},
		}
        local LAM2 = LibStub("LibAddonMenu-2.0")
        LAM2:RegisterAddonPanel("GIConfig", panelData)
        LAM2:RegisterOptionControls("GIConfig", optionsData)
		-- Die AddON-Fensterposition korrigieren, wenn das der erste Aufruf ist oder das Fenster ausserhalb des gültigen Bereichs
		local screenWidth, screenHeight = GuiRoot:GetDimensions()
		if (GI.vars.offsetX == 0 and GI.vars.offsetY == 0) then
			GI.vars.offsetX = screenWidth / 2
			GI.vars.offsetY = (screenHeight / 2) + 50
		end
		if (GI.vars.offsetX >= screenWidth) then GI.vars.offsetX=screenWidth / 2 end
		if (GI.vars.offsetY >= screenHeight) then GI.vars.offsetY=screenHeight / 2 end
		-- Das AddON-Fenster einstellen und anzeigen
		GameInfoPanel:ClearAnchors()
		GameInfoPanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GI.vars.offsetX, GI.vars.offsetY)
		GameInfoPanel:SetMovable(not GI.vars.lockWindowPosition)
		GameInfoPanelBag:SetTexture("/esoui/art/menubar/menubar_inventory_over.dds")
		GameInfoPanelBank:SetTexture("ESOUI/art/icons/servicemappins/servicepin_bank.dds")
		GI.combatSymbols=false
		if (GI.vars.BuffoffsetX == 0 and GI.vars.BuffoffsetY == 0) then
			GI.vars.BuffoffsetX = screenWidth / 2 + 50
			GI.vars.BuffoffsetY = (screenHeight / 2) + 50
		end
		if (GI.vars.BuffoffsetX >= screenWidth) then GI.vars.BuffoffsetX=screenWidth / 2 end
		if (GI.vars.BuffoffsetY >= screenHeight) then GI.vars.BuffoffsetY=screenHeight / 2 end
		GameBuffDisplay:ClearAnchors()
		GameBuffDisplay:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GI.vars.BuffoffsetX, GI.vars.BuffoffsetY)
		GameBuffDisplay:SetMovable(not GI.vars.lockWindowPosition)
		GI.setAlignment(GI.vars.horizontAlignmentBuff)
		GI.StartTime=GetSecondsPlayed()
		GI.HourBreak=GI.StartTime+1
		GI.Welcome=false
		GI.PlayerReady=false
		GI.BankIsOpen=false
		GI.SpaceInfoFade(GI.vars.SpaceInfo)
		GI.BankInfoFade(GI.vars.BankInfo)
		GI.PlayerXP=GetUnitXP("player")
		GI.PlayerVP=GetUnitVeteranPoints("player")
		GI.clearQueue()
		GI.loaded=true
	end
end

EVENT_MANAGER:RegisterForEvent("GI", EVENT_ADD_ON_LOADED, GI.Initialize)
EVENT_MANAGER:RegisterForEvent("GI", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, GI.LootMessage)
EVENT_MANAGER:RegisterForEvent("GI", EVENT_MONEY_UPDATE, GI.MoneyMessage)
EVENT_MANAGER:RegisterForEvent("GI", EVENT_PLAYER_ACTIVATED, GI.Ready4Action)
EVENT_MANAGER:RegisterForEvent("GI", EVENT_EXPERIENCE_UPDATE, GI.GainedXP)
EVENT_MANAGER:RegisterForEvent("GI", EVENT_VETERAN_POINTS_UPDATE, GI.GainedVP)
EVENT_MANAGER:RegisterForEvent("GI", EVENT_OPEN_BANK, GI.BankOpen)
EVENT_MANAGER:RegisterForEvent("GI", EVENT_CLOSE_BANK, GI.BankClose)
SLASH_COMMANDS["/gi"] = GI.SlashGI