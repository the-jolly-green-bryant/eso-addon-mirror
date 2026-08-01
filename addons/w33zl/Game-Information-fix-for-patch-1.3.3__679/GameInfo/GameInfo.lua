--	=====================================================================================================================
--
--	The Elder Scrolls Online
--	------------------------
--
--	Game-Informations AddON für The Elder Scrolls Online
--
--
--	Dieses AddON zeigt die freien und belegten Taschenplätze (in einem frei bewegbaren Fenster), sowie auf Wunsch
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
--	=====================================================================================================================


GI = {}
GI.name="GameInfo"
GI.version="2.6a"
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
				-- changed by PaulDenton
				temp=temp..GI.ColorStart(GI.vars.ColorAmount)..tostring(GI.QueuedXP)..GI.ColorEnd.." "..GI.ColorStart(GI.vars.ColorXPVP)..GI.locXPGained.." "..GI.ColorEnd
			end
			if GI.QueuedVP>0 then
				-- changed by PaulDenton
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
--				GI.QueuedLoot[GI.QueuedLootindex]=GI.strStrip(GetItemLink(bagId, slotId,LINK_STYLE_BRACKETS))
				GI.QueuedLoot[GI.QueuedLootindex]=GetItemLink(bagId, slotId,LINK_STYLE_BRACKETS)
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


-- Callback für das AddON-Fenster
function GI.Update()
	-- Nur ausführen, wenn Das AddON schon geladen ist
	if (GI.loaded == true) then
		-- Die Frequenz ein wenig herunterbremsen, sonst behindern wir das gesamte Spiel
		if (GI.UpdateThrottle("Update", 800) == true) then
			local keybindIsHidden=ZO_KeybindStripControl:IsHidden()
			-- Das Fenster ausblenden, wenn die Oberfläche wegfaded
			if (keybindIsHidden == false) then
				GameInfoDisplay:SetAlpha(0.0)
			else
				GameInfoDisplay:SetAlpha(GI.vars.BuffTransparency)
			end
			local usedSlots, maxSlots=PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
			GameInfoDisplayCount:SetText(usedSlots.." / "..maxSlots)
			-- Kampfnachricht einblenden, wenn im Kampf und das auch gewünscht war
			if (IsUnitInCombat("player")==true) then
				if (GI.vars.ReportInCombat==true) then
					GameInfoDisplayCombat:SetAlpha(1)
				end
			else
				GameInfoDisplayCombat:SetAlpha(0)
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
	GI.vars.offsetX = GameInfoDisplay:GetLeft()
	GI.vars.offsetY = GameInfoDisplay:GetTop()
end

function GI.SpaceInfoFade()
	if (GI.vars.SpaceInfo==false) then
		GameInfoDisplayBag:SetAlpha(0)
		GameInfoDisplayCount:SetAlpha(0)
	else
		GameInfoDisplayBag:SetAlpha(1)
		GameInfoDisplayCount:SetAlpha(1)
	end
end

function GI.UpdateLockStatus(newValue)
	GI.vars.lockWindowPosition = newValue
	GameInfoDisplay:SetMovable(not GI.vars.lockWindowPosition)
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
				GameBuffDisplay:SetAlpha(GI.vars.BuffTransparency)
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
	local temo=GI.nToHex(r)..GI.nToHex(g)..GI.nToHex(b)..GI.nToHex(a)
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
	-- added by PaulDenton
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
			SpaceInfo=true,
			DisplayBuffs=true,
			lockWindowPosition=false,
			DisplayStufe=true,
			DisplayAttrib=true,
			BuffTransparency=80,
			offsetX=0,
			offsetY=0,
			BuffoffsetX=0,
			BuffoffsetY=0,
			ColorWelcome="FCFCFCFF",
			ColorAmount="FCFCFCFF",
			ColorPlayTime="E6E6AAFF",
			ColorLoot="C5C29EFF",
			ColorXPVP="C5C29EFF",
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
		local LAM = LibStub:GetLibrary("LibAddonMenu-1.0")
		local gipanel = LAM:CreateControlPanel(GI.name.."Config", "Game Info")
		LAM:AddHeader(gipanel, "GI.TimeConfig", GI.locTimeEinstellungen)
		LAM:AddCheckbox(gipanel, "GI.InfoOnEnterConfig", GI.locInfoOnEnterConfig, GI.locInfoOnEnterConfigDsc,
			function()  return GI.vars.InfoOnEnter end,
			function()	GI.vars.InfoOnEnter = not GI.vars.InfoOnEnter end)
		LAM:AddCheckbox(gipanel, "GI.FpsOnEnterConfig", GI.locFpsOnEnterConfig, GI.locFpsOnEnterConfigDsc,
			function()  return GI.vars.FpsOnEnter end,
			function()	GI.vars.FpsOnEnter = not GI.vars.FpsOnEnter end)
		LAM:AddCheckbox(gipanel, "GI.InfoCyclicConfig", GI.locInfoCyclicConfig, GI.locInfoCyclicConfigDsc,
			function()  return GI.vars.InfoCyclic end,
			function()	GI.vars.InfoCyclic = not GI.vars.InfoCyclic end)
		LAM:AddDropdown(gipanel, "GI.ReportingConfig", GI.locReportingConfig, GI.locReportingConfigDsc, ReportOpts,
			function()  return GI.vars.ReportingMinutes end,
			function(val)	GI.vars.ReportingMinutes = val GI.HourBreak=GetSecondsPlayed() end)
		LAM:AddColorPicker(gipanel,	"GI.ReportingColorConfig", GI.locReportingColorConfig, GI.locReportingColorConfigDsc,
			function()	return GI.ColorPlayTime_r,GI.ColorPlayTime_g,GI.ColorPlayTime_b,GI.ColorPlayTime_a	end,
			function(r,g,b,a)	GI.ColorPlayTime_r=r GI.ColorPlayTime_g=g GI.ColorPlayTime_b=b GI.ColorPlayTime_a=a GI.vars.ColorPlayTime=GI.ColorToHTML(r,g,b,a)	end)
		LAM:AddHeader(gipanel, "GI.InfoConfig", GI.locInfoEinstellungen)
		LAM:AddCheckbox(gipanel, "GI.SpaceInfoConfig", GI.locSpaceInfoConfig, GI.locSpaceInfoConfigDsc,
			function()  return GI.vars.SpaceInfo end,
			function()	GI.vars.SpaceInfo = not GI.vars.SpaceInfo GI.SpaceInfoFade() end)
		LAM:AddCheckbox(gipanel, "GI.LootMsgConfig", GI.locLootMsgConfig, GI.locLootMsgConfigDsc,
			function()  return GI.vars.LootMsg end,
			function()	GI.vars.LootMsg = not GI.vars.LootMsg end)
		LAM:AddCheckbox(gipanel, "GI.LootGoldMsgConfig", GI.locLootGoldMsgConfig, GI.locLootGoldMsgConfigDsc,
			function()  return GI.vars.LootGoldMsg end,
			function()	GI.vars.LootGoldMsg = not GI.vars.LootGoldMsg end)
		LAM:AddCheckbox(gipanel, "GI.LootXPMsgConfig", GI.locLootXPMsgConfig, GI.locLootXPMsgConfigDsc,
			function()  return GI.vars.LootXPMsg end,
			function()	GI.vars.LootXPMsg = not GI.vars.LootXPMsg end)
		LAM:AddColorPicker(gipanel,	"GI.LootColorConfig", GI.locLootColorConfig, GI.locLootColorConfigDsc,
			function()	return GI.ColorLoot_r,GI.ColorLoot_g,GI.ColorLoot_b,GI.ColorLoot_a	end,
			function(r,g,b,a)	GI.ColorLoot_r=r GI.ColorLoot_g=g GI.ColorLoot_b=b GI.ColorLoot_a=a GI.vars.ColorLoot=GI.ColorToHTML(r,g,b,a)	end)
		-- added by PaulDenton
		LAM:AddColorPicker(gipanel,	"GI.XPVPColorConfig", GI.locXPVPColorConfig, GI.locXPVPColorConfigDsc,
			function()	return GI.ColorXPVP_r,GI.ColorXPVP_g,GI.ColorXPVP_b,GI.ColorXPVP_a	end,
			function(r,g,b,a)	GI.ColorXPVP_r=r GI.ColorXPVP_g=g GI.ColorXPVP_b=b GI.ColorXPVP_a=a GI.vars.ColorXPVP=GI.ColorToHTML(r,g,b,a)	end)
		LAM:AddHeader(gipanel, "GI.CombatConfig", GI.locCombatEinstellungen)
		LAM:AddCheckbox(gipanel, "GI.DisplayBuffsConfig", GI.locDisplayBuffsConfig, GI.locDisplayBuffsConfigDsc,
			function()  return GI.vars.DisplayBuffs end,
			function()	GI.vars.DisplayBuffs = not GI.vars.DisplayBuffs end)
		LAM:AddCheckbox(gipanel, "GI.ReportInCombatConfig", GI.locReportInCombatConfig, GI.locReportInCombatConfigDsc,
			function()  return GI.vars.ReportInCombat end,
			function()	GI.vars.ReportInCombat = not GI.vars.ReportInCombat end)
		LAM:AddHeader(gipanel, "GI.ConfigConfig", GI.locEinstellungen)
		LAM:AddCheckbox(gipanel, "GI.LockWindowConfig", GI.locLockWindowConfig, GI.locLockWindowConfigDsc,
				function() return GI.vars.lockWindowPosition end,
				function(newValue) GI.UpdateLockStatus(newValue) end)
		LAM:AddCheckbox(gipanel, "GI.DisplayStufeConfig", GI.locDisplayStufeConfig, GI.locDisplayStufeConfigDsc,
				function() return GI.vars.DisplayStufe end,
				function(newValue) GI.vars.DisplayStufe=newValue GI.DisplayStufe(newValue) end)
		LAM:AddCheckbox(gipanel, "GI.DisplayAttribConfig", GI.locDisplayAttribConfig, GI.locDisplayAttribConfigDsc,
				function() return GI.vars.DisplayAttrib end,
				function(newValue) GI.vars.DisplayAttrib=newValue GI.DisplayAttrib(newValue) end)
		LAM:AddHeader(gipanel, "GI.AddonConfig", GI.locAddonEinstellungen)
		LAM:AddDescription(gipanel, "GI.DescriptionConfig", GI.locDescriptionConfig .. "\nGame Information (c) by Bernd aka @Sternentau", "Version " .. GI.version)
		-- Die AddON-Fensterposition korrigieren, wenn das der erste Aufruf ist oder das Fenster ausserhalb des gültigen Bereichs
		local screenWidth, screenHeight = GuiRoot:GetDimensions()
		if (GI.vars.offsetX == 0 and GI.vars.offsetY == 0) then
			GI.vars.offsetX = screenWidth / 2
			GI.vars.offsetY = (screenHeight / 2) + 50
		end
		if (GI.vars.offsetX >= screenWidth) then GI.vars.offsetX=screenWidth / 2 end
		if (GI.vars.offsetY >= screenHeight) then GI.vars.offsetY=screenHeight / 2 end
		-- Das AddON-Fenster einstellen und anzeigen
		GameInfoDisplay:ClearAnchors()
		GameInfoDisplay:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GI.vars.offsetX, GI.vars.offsetY)
		GameInfoDisplayBag:SetTexture("/esoui/art/menubar/menubar_inventory_over.dds")
		GameInfoDisplay:SetMovable(not GI.vars.lockWindowPosition)
		GameInfoDisplayCombat:SetTexture("/esoui/art/mappins/ava_3way.dds")
		GameInfoDisplayCombat:SetAlpha(0.0)

		if (GI.vars.BuffoffsetX == 0 and GI.vars.BuffoffsetY == 0) then
			GI.vars.BuffoffsetX = screenWidth / 2 + 50
			GI.vars.BuffoffsetY = (screenHeight / 2) + 50
		end
		if (GI.vars.BuffoffsetX >= screenWidth) then GI.vars.BuffoffsetX=screenWidth / 2 end
		if (GI.vars.BuffoffsetY >= screenHeight) then GI.vars.BuffoffsetY=screenHeight / 2 end
		GameBuffDisplay:ClearAnchors()
		GameBuffDisplay:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GI.vars.BuffoffsetX, GI.vars.BuffoffsetY)
		GameBuffDisplay:SetMovable(not GI.vars.lockWindowPosition)
		GI.StartTime=GetSecondsPlayed()
		GI.HourBreak=GI.StartTime+1
		GI.Welcome=false
		GI.PlayerReady=false
		GI.SpaceInfoFade()
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
SLASH_COMMANDS["/gi"] = GI.SlashGI