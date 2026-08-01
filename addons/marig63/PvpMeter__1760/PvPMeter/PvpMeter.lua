
PvpMeter = {}
 
PvpMeter.name = "PvpMeter"
 
function PvpMeter:Initialize(PvpMeterLabelKill)

  PvpMeter.savedVariables = ZO_SavedVars:New("PvpMeterSavedVariables", 1, nil,{})
  PvpMeter.savedVariablesAw = ZO_SavedVars:NewAccountWide("PvpMeterSavedVariables", 1, nil,{})
  --
  --IHateYou()
  PvpMeter.initSettings()

  if(self.savedVariables.rotation == nil)then
	self.savedVariables.rotation = 1
  end
  
  if(self.savedVariables.quickButton == nil)then
	self.savedVariables.quickButton = true
  end

  if(self.savedVariables.autoqueue == nil)then
	self.savedVariables.autoqueue = false
  end
  
  if(self.savedVariables.playSound == nil)then
	self.savedVariables.playSound = true
  end

  if(self.savedVariables.alertBorder == nil)then
	self.savedVariables.alertBorder = true
  end
 
  if(self.savedVariables.nbrSound == nil)then
	self.savedVariables.nbrSound = 0
  end
 
  if(self.savedVariables.nbrCyro == nil)then
	self.savedVariables.nbrCyro = 0
  end

  if(self.savedVariables.showBeautifulMeter == nil)then
	self.savedVariables.showBeautifulMeter = true
  end
 
  if(self.savedVariables.BGAssist == nil)then
	self.savedVariables.BGAssist = false
  end
  
  if(self.savedVariables.top == nil)then
	self.savedVariables.top = 952
  end
  
  if(self.savedVariables.left == nil)then
	self.savedVariables.left = 1664
  end
  
  if(self.savedVariables.cyroKill == nil)then
	self.savedVariables.cyroKill = 0
  end
  
  if(self.savedVariables.cyroDeath == nil)then
	self.savedVariables.cyroDeath = 0
  end
  
  if(self.savedVariables.bgKill == nil)then
	self.savedVariables.bgKill = 0
  end
  
  if(self.savedVariables.bgDeath == nil)then
	self.savedVariables.bgDeath = 0
  end
  
  if(self.savedVariables.currAP == nil)then
	self.savedVariables.currAP = true
  end
  
  if(self.savedVariables.chat == nil)then
	self.savedVariables.chat = 20
  end

  self.inCombat = IsUnitInCombat("player")
  self.inAvA = IsPlayerInAvAWorld()
  self.inIC = IsInImperialCity()
  self.AP = GetAlliancePoints()
  self.currAP = 0
  self.kills = 0
  self.assistBG = 0
  self.killsCoef = 0
  self.death = 0
  self.inBG = IsActiveWorldBattleground()
  self.alliance = 0
  self.isHide = false
  self.lastAP = 0
  self.lastPercentKeep = 0
  self.allianceKill = 0
  self.allianceDeath = 0
  self.allianceMedal = 0
  self.allianceLastScore = 0
  self.allianceScore = 0
  
  self.switch = 0
  self.dye =  false
  self.armory = false
  
  self.PvpMeterLabelKill = PvpMeterLabelKill

  CreateControl("ControlName",LabelKill,CT_LABEL)
  
  EVENT_MANAGER:UnregisterForEvent(PvpMeter.name, EVENT_ADD_ON_LOADED)
  --EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GAME_FOCUS_CHANGED, self.focus)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_ALLIANCE_POINT_UPDATE, self.OnAPUpdate)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_COMBAT_EVENT, self.OnKill)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_PLAYER_DEAD, self.OnDeath)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED   , self.UIswitch)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_PLAYER_ACTIVATED ,self.zoneChange)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED   , self.gamepad)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_OPEN_BANK, self.openBank)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_OPEN_STORE, self.openBank)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_OPEN_TRADING_HOUSE, self.openBank)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_OPEN_GUILD_BANK, self.openBank)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_CHATTER_BEGIN, self.openBank)
  
  
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_MEDAL_AWARDED, self.onPointUpdate)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_BATTLEGROUND_SCOREBOARD_UPDATED , self.onScoreUpdate)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_DYEING_STATION_INTERACT_START, self.onDyeStart)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_DYEING_STATION_INTERACT_END, self.onDyeEnd)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name,EVENT_GAME_CAMERA_CHARACTER_FRAMING_STARTED ,self.UIchange)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name,EVENT_KEEP_ALLIANCE_OWNER_CHANGED,self.updateMeter)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name,EVENT_BATTLEGROUND_KILL ,self.bgkill)
  
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name,EVENT_CAMPAIGN_QUEUE_JOINED ,self.queue_joined)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name,EVENT_CAMPAIGN_QUEUE_LEFT  ,self.queue_left)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name,EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED  ,self.queue_position)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name,EVENT_CAMPAIGN_QUEUE_STATE_CHANGED ,self.queue_state)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, self.onActivityFinderStatusUpdate)
  
  --EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_OPEN_ARMORY_MENU, self.openArmory)
  EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_OPEN_ARMORY_MENU, self.openArmory)
  
end
 
 function PvpMeter.gamepad(event, opt)
	
	PvpMeter.zoneChange(event,"qdq","qdq","qdq",0,0)
		
	--PvpMeter:Initialize()
	PvpMeter.updateAP()
	PvpMeter.updateKills()
	PvpMeter.updateDeath()
	--PvpMeter.hideCyro()
	PvpMeter.updateKillsBG()
	PvpMeter.updateDeathBG()
	PvpMeter.updateMedal()
	PvpMeter.updateMeter()
	--PvpMeter:initSettings() 
	
end

function PvpMeter.OnAddOnLoaded(event, addonName)

  if addonName == PvpMeter.name then
    PvpMeter:Initialize()
 
	PvpMeter.updateAP()
	PvpMeter.updateKills()
	PvpMeter.updateDeath()
	PvpMeter.hideCyro()
	PvpMeter.updateKillsBG()
	PvpMeter.updateDeathBG()
	PvpMeter.updateMedal()
	PvpMeter.updateMeter()
	PvpMeter.prepareQuickButton()
	PvpMeter.updateButtonQuick()
  end
  
end
 
EVENT_MANAGER:RegisterForEvent(PvpMeter.name, EVENT_ADD_ON_LOADED, PvpMeter.OnAddOnLoaded)

function PvpMeter.hideCyro()

		HUDTelvarMeter_hide()
		PvpMeterIndicator:SetHidden(true)
		PvpMeterIndicr:SetHidden(true)
		myAtor:SetHidden(true)
		PvpMeterInd:SetHidden(true)	
		
		Glow:SetHidden(true)
		LabelAP:SetHidden(true)	
		APicon:SetHidden(true)	
		LabelKill:SetHidden(true)	
		LabelDeath:SetHidden(true)		
		
		--HUDTelvarMeter_alpha(0.0)
		
end

function PvpMeter.showCyro()

	if(PvpMeter.savedVariables.showBeautifulMeter)then
		if(PvpMeter.inAvA) then
			HUDTelvarMeter_color(0,0.78,0.09)--HUDTelvarMeter_color(0.2,0.31,0.12)
			HUDTelvarMeter_colorAlert(0.15,0.93,0.12)
			PvpMeterIndicator:SetHidden(false)
			PvpMeterIndicr:SetHidden(false)
			myAtor:SetHidden(false)
			PvpMeterInd:SetHidden(false)
		
			Glow:SetHidden(false)
			LabelAP:SetHidden(false)	
			APicon:SetHidden(false)	
			LabelKill:SetHidden(false)	
			LabelDeath:SetHidden(false)	
			--HUDTelvarMeter_alpha(1.0)
		end
	else
		HUDTelvarMeter_hide()
	end
	
end

function PvpMeter.hideBG()

	frameBG:SetHidden(true)
	medailBG:SetHidden(true)
	iconBG:SetHidden(true)
	killBG:SetHidden(true)
	--PvpMeterInd:SetHidden(true)
	
	Gl:SetHidden(true)	
	LabelMedal:SetHidden(true)	
	scoreIcon:SetHidden(true)	
	LabelKillBG:SetHidden(true)	

	LabelAssist:SetHidden(true)	
	LabelDeathBG:SetHidden(true)
	
end

function PvpMeter.showBG()

	if(PvpMeter.savedVariables.showBeautifulMeter)then
		frameBG:SetHidden(false)
		medailBG:SetHidden(false)
		iconBG:SetHidden(false)
		killBG:SetHidden(false)
		--PvpMeterInd:SetHidden(false)
	
		Gl:SetHidden(false)	
		LabelMedal:SetHidden(false)	
		scoreIcon:SetHidden(false)	
		LabelKillBG:SetHidden(false)
		if(PvpMeter.savedVariables.BGAssist == true)then
			LabelAssist:SetHidden(false)	
		end
		LabelDeathBG:SetHidden(false)	
	else
		HUDTelvarMeter_hide()
	end
	
end

function PvpMeter.UIchange(eventCode)

	PvpMeter.inAvA = IsPlayerInAvAWorld()
		
		if( PvpMeter.inAvA) then
			PvpMeter.hideCyro()
			
		end
		if(PvpMeter.inBG) then
			PvpMeter.hideBG()
		end
		HUDTelvarMeter_hide()
		
end

function PvpMeter.UIswitch(eventCode)

	PvpMeter.switch = PvpMeter.switch+1
	
	if(ZO_WorldMap_IsWorldMapShowing() or GetCraftingInteractionType()~=0  or  PvpMeter.dye or PvpMeter.armory ) then
		PvpMeter.dye = false
		PvpMeter.armory = false
		PvpMeter.inAvA = IsPlayerInAvAWorld()
  
		if( PvpMeter.inAvA) then
			PvpMeter.hideCyro()
		end
				
		if(PvpMeter.inBG) then
			PvpMeter.hideBG()
		end
		
		--HUDTelvarMeter_show()
		
	else	
		PvpMeter.inAvA = IsPlayerInAvAWorld()
  
		if( PvpMeter.inAvA) then
			PvpMeter.showCyro()
		end
				
		if(PvpMeter.inBG) then
			PvpMeter.showBG()
		end
		
		HUDTelvarMeter_show()
		
	end
	
end

function PvpMeter.zoneChange(eventCode,zoneName,subZoneName,newSubzone, zoneId,ubZoneId)

	PvpMeter.inAvA = IsPlayerInAvAWorld()
	PvpMeter.inIC = IsInImperialCity()
	PvpMeter.inBG = IsActiveWorldBattleground()
 
	if(PvpMeter.inAvA) then
		PvpMeter.showCyro()
	else
		PvpMeter.hideCyro()
	end
	
	--[[if(PvpMeter.inIC) then
		--PvpMeter.putSec()
	else
		if(PvpMeter.inAvA)then
			--PvpMeter.putFirst() --First
		end
	end]]
	
	--d(PvpMeter.inAvA)
	
	if(PvpMeter.inBG) then
		
		PvpMeter.alliance = GetUnitBattlegroundAlliance("player")
		--d(GetBattlegroundAllianceName(GetUnitBattlegroundAlliance("player")))
		PvpMeter.changeColor()
		PvpMeter.showBG()
		PvpMeter.hideCyro()
		PvpMeter.updateKillsBG()
		PvpMeter.updateDeathBG()
		PvpMeter.updateMedal()
	else
		PvpMeter.hideBG()
		PvpMeter.alliance = 0
		PvpMeter.allianceKill = 0
		PvpMeter.allianceDeath = 0
		PvpMeter.assistBG = 0
		PvpMeter.allianceMedal = 0
		PvpMeter.allianceScore = 0
			
	end
	
	if(PvpMeter.inAvA or PvpMeter.inBG) then
		--d("hide")
		HUDTelvarMeter_show()
	else
		--d("show")
		HUDTelvarMeter_hide()
	end
	
	--
	--PvpMeter.changeColor()
	--
	PvpMeter.restore()
 
	PvpMeter.updateMeter()
	PvpMeter.rotateMeter(PvpMeter.savedVariables.rotation)
 
end

function PvpMeter.OnAPUpdate(event, nbAP, playSound, difference)

	PvpMeter.AP = nbAP
	PvpMeter.currAP = PvpMeter.currAP + difference
	--PlaySound(SOUNDS.ALLIANCE_POINT_TRANSACT)
	
	--d(PvpMeter.AP)
	PvpMeter.updateAP()
	PvpMeter.updateMeter()
	
end

function PvpMeter.OnKill(eventCode , result , isError , abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log )

	if ( isError ) then
		return 
	end
 
	if result == ACTION_RESULT_KILLING_BLOW and sourceType == COMBAT_UNIT_TYPE_PLAYER and GetUnitName("player") == zo_strformat("<<1>>", sourceName) and abilityName ~= "" then
	
		if( PvpMeter.inAvA) then
		
			--d(sourceName)
			--d(targetName)
			if( sourceName == targetName)then return end
			
			PvpMeter.kills = PvpMeter.kills + 1
			PvpMeter.savedVariables.cyroKill = PvpMeter.savedVariables.cyroKill + 1
			-- PlaySound
			-- PlaySound(SOUNDS.EMPEROR_CORONATED_EBONHEART)
			if(PvpMeter.savedVariables.playSound == true)then 
   
   
				if(PvpMeter.savedVariables.nbrSound == 0)then
					PlaySound(SOUNDS.LOCKPICKING_SUCCESS_CELEBRATION)
				end
				if(PvpMeter.savedVariables.nbrSound == 1)then
					PlaySound(SOUNDS.EMPEROR_CORONATED_EBONHEART)
				end			
			end
			PvpMeter.updateKills()
		end
	end
	
end

function PvpMeter.OnDeath(eventCode)

	if( PvpMeter.inAvA) then
		PvpMeter.death = PvpMeter.death + 1
		PvpMeter.savedVariables.cyroDeath = PvpMeter.savedVariables.cyroDeath + 1
		PvpMeter.updateDeath()
	end
			
	if(PvpMeter.inBG) then
		PvpMeter.allianceDeath = PvpMeter.allianceDeath + 1
		PvpMeter.savedVariables.bgDeath = PvpMeter.savedVariables.bgDeath + 1
		PvpMeter.updateDeathBG()
	end
	
end

function PvpMeter.updateKills()

	if(tonumber(LabelKill:GetText()) < PvpMeter.kills)then
		HUDTelvarMeter_Anim()
	end

	LabelKill:SetText(PvpMeter.kills)
 
	PvpMeter.updateMeter()
	
end

function PvpMeter.updateDeath()

	LabelDeath:SetText(PvpMeter.death)
	
end

function PvpMeter.updateAP()

	--local lab = PvpMeterIndicator:GetNamedChild("LabelAP")
	--lab:SetText(PvpMeter.AP)
	if(PvpMeter.savedVariables.showBeautifulMeter)then
		--TELVAR_METER.meterOverlayControl.fadeAnimation:PlayFromStart()
	end
	if(PvpMeter.savedVariables.currAP == true)then
		LabelAP:SetText(PvpMeter.currAP)
	else
		LabelAP:SetText(PvpMeter.AP)
	end	
 
end

function PvpMeter.openBank(event)

	PvpMeter.hideCyro()
	
end

function PvpMeter.onDyeEnd(event)

	PvpMeter.dye = false
	
end

function PvpMeter.onDyeStart(event)

	PvpMeter.dye = true
	
end

--[[function PvpMeter.openArmory(event)

	PvpMeter.hideCyro()
	
end]]

function PvpMeter.openArmory(event)

	PvpMeter.armory = true
	
end

function PvpMeter.onPointUpdate(event,medalId,name,icon,value)

	PvpMeter.allianceMedal = PvpMeter.allianceMedal + value
	PvpMeter.updateMedal()
	
end

function PvpMeter.onScoreUpdate(event)

	--d(GetCurrentBattlegroundScore(PvpMeter.alliance))
	--d(PvpMeter.allianceMedal)
	
	if(PvpMeter.allianceScore ~= GetCurrentBattlegroundScore(PvpMeter.alliance)) then
		PvpMeter.updateMedal()
		PvpMeter.updateMeter()
	end
	local entryInde = GetScoreboardPlayerEntryIndex()
	if(PvpMeter.assistBG ~=  GetScoreboardEntryScoreByType(entryInde, SCORE_TRACKER_TYPE_ASSISTS))then
		PvpMeter.assistBG =  GetScoreboardEntryScoreByType(entryInde, SCORE_TRACKER_TYPE_ASSISTS)
		PvpMeter.updateKillsBG()
	end
 
	if(PvpMeter.inBG) then
		
			--PvpMeter.allianceKill = PvpMeter.allianceKill + 1
			--PvpMeter.updateKillsBG()
			local entryIndex = GetScoreboardPlayerEntryIndex()
            local characterName, displayName, battlegroundAlliance, isLocalPlayer = GetScoreboardEntryInfo(entryIndex)
   
			local kills = GetScoreboardEntryScoreByType(entryIndex, SCORE_TRACKER_TYPE_KILL)
			local death = GetScoreboardEntryScoreByType(entryIndex, SCORE_TRACKER_TYPE_DEATH)
			--local assist = GetScoreboardEntryScoreByType(entryIndex, SCORE_TRACKER_TYPE_ASSISTS)
			
			PvpMeter.allianceKill = kills
			PvpMeter.updateKillsBG()
			PvpMeter.allianceDeath = death
			PvpMeter.updateDeathBG()
		end
  
end

function PvpMeter.bgkill (eventCode,killedPlayerCharacterName,killedPlayerDisplayName,killedPlayerBattlegroundAlliance,killingPlayerCharacterName,killingPlayerDisplayName,killingPlayerBattlegroundAlliance,battlegroundKillType)

	if(battlegroundKillType == BATTLEGROUND_KILL_TYPE_KILLING_BLOW)then
		PvpMeter.allianceKill = PvpMeter.allianceKill + 1
		PvpMeter.savedVariables.bgKill = PvpMeter.savedVariables.bgKill + 1
		HUDTelvarMeter_Anim()
		PvpMeter.updateKillsBG()
		if(PvpMeter.savedVariables.playSound == true)then
			if(PvpMeter.savedVariables.nbrSound == 0)then
				PlaySound(SOUNDS.LOCKPICKING_SUCCESS_CELEBRATION)
			end
			if(PvpMeter.savedVariables.nbrSound == 1)then
				PlaySound(SOUNDS.EMPEROR_CORONATED_EBONHEART)
			end
		end
	end
	if(battlegroundKillType == BATTLEGROUND_KILL_TYPE_ASSIST)then
		if(PvpMeter.savedVariables.playSound == true)then
			
		end
	end


end

function PvpMeter.updateKillsBG()

	LabelKillBG:SetText(PvpMeter.allianceKill)
	LabelAssist:SetText(PvpMeter.assistBG)
	
end

function PvpMeter.updateDeathBG()

	LabelDeathBG:SetText(PvpMeter.allianceDeath)
	
end

function PvpMeter.updateMedal()

	LabelMedal:SetText(PvpMeter.allianceMedal)
	
end

function PvpMeter.changeColor()

	if(PvpMeter.alliance == 1) then
		LabelKillBG:SetColor(0.85,0.4,00)
		LabelAssist:SetColor(0.85,0.4,00)
		LabelDeathBG:SetColor(0.85,0.4,00)
		LabelMedal:SetColor(0.85,0.4,00)
		--meterBarBG:SetColor(1,0.0,0.0)
		scoreIcon:SetTexture( GetBattlegroundTeamIcon(PvpMeter.alliance))
		--scoreIcon:SetColor(1,0.1,00)
		--Fill:SetFillColor(1,0.0,0.0)
		--Highlig:SetFillColor(1,0.0,0.0)
		HUDTelvarMeter_color(1,0.15,0.0)
		HUDTelvarMeter_colorAlert(0.5,0,0.0)
	end
	if(PvpMeter.alliance == 3) then
		LabelKillBG:SetColor(0.5,0.3,0.6)
		LabelAssist:SetColor(0.5,0.3,0.6)
		LabelDeathBG:SetColor(0.5,0.3,0.6)
		LabelMedal:SetColor(0.5,0.3,0.6)
		--meterBarBG:SetColor(1.0,0.1,0.7)
		scoreIcon:SetTexture(GetBattlegroundTeamIcon(PvpMeter.alliance))
		--scoreIcon:SetColor(0.6,0.1,0.7)
		HUDTelvarMeter_color(1.0,0.1,0.5)
		HUDTelvarMeter_colorAlert(1.0,0.1,0.7)
		--Fill:SetFillColor(1.0,0.1,0.7)
		--Highlig:SetFillColor(1.0,0.1,0.7)
	end
	if(PvpMeter.alliance == 2) then
		LabelKillBG:SetColor(0.36,0.6,0.0)
		LabelAssist:SetColor(0.36,0.6,0.0)
		LabelDeathBG:SetColor(0.36,0.6,0.0)
		LabelMedal:SetColor(0.36,0.6,0.0)
		--meterBarBG:SetColor(0.5,0.4,0.00)
		scoreIcon:SetTexture(GetBattlegroundTeamIcon(PvpMeter.alliance))
		--scoreIcon:SetColor(0.5,0.4,0.00)
		HUDTelvarMeter_color(0.5,0.4,0.00)
		HUDTelvarMeter_colorAlert(0.4,0.5,0.00)
		--Fill:SetFillColor(0.5,0.4,0.00)
		--Highlig:SetFillColor(0.5,0.4,0.00)
	end

end

function PvpMeter.updateMeter()
																	   
																	   
															  
																
 
															 
																 
															  
														   

					   
   

									   
 
 
	 

							   

	local start = 0.0
	local endd = 0.0
	
	if(PvpMeter.inAvA) then 
 
		if(PvpMeter.savedVariables.nbrCyro==0)then
			local isAllianceHoldingAllNativeKeeps, numEnemyKeepsThisAllianceHolds, numNativeKeepsThisAllianceHolds, totalNativeKeepsInThisAlliancesArea = GetAvAKeepScore( GetCurrentCampaignId() , GetUnitAlliance("player") )
		
			local num = (numEnemyKeepsThisAllianceHolds + numNativeKeepsThisAllianceHolds)/18
			start = PvpMeter.lastPercentKeep
			endd = num
		
		PvpMeter.lastPercentKeep = num
		end
		if(PvpMeter.savedVariables.nbrCyro==1)then
			if(PvpMeter.kills == 0) then
				start = 0.0
				endd = 0.0
			else
			if(PvpMeter.kills%5 == 0) then
				start = 0.0
				endd = 1.0
			else
				endd = (PvpMeter.kills%5)/5
				start = endd - 0.2
			end
		end
		end
		if(PvpMeter.savedVariables.nbrCyro==2)then
			local Aaa ,Bbb ,rankStartsAt,nextRankAt = GetAvARankProgress(GetUnitAvARankPoints("player"))
			local need  = nextRankAt-rankStartsAt
			local did = GetUnitAvARankPoints("player")-rankStartsAt

			endd = did/need
			
			if(PvpMeter.lastAP == 0)then 
				start = 0.0
			else
				start = PvpMeter.lastAP
			end
			
			PvpMeter.lastAP = endd
		end
	
	end
 
 
	if(PvpMeter.inBG) then
		
		PvpMeter.allianceScore = GetCurrentBattlegroundScore(PvpMeter.alliance)
		endd = PvpMeter.allianceScore/500
	
		if(PvpMeter.allianceLastScore == 0) then 
			start = 0.0
		else
			start = PvpMeter.allianceLastScore/500
		end
	
		PvpMeter.allianceLastScore = PvpMeter.allianceScore
		
	end

	HUDTelvarMeter_update(start,endd)
 
end

function PvpMeter.restore()

	local left = PvpMeter.savedVariables.left
	local top = PvpMeter.savedVariables.top
	
 
	HUDTelvarMeter_restore(top,left)
 
end

function PvpMeter.OnMeterMoveStop()

	PvpMeter.savedVariables.left = HUDTelvarMeter_getLeft()
	PvpMeter.savedVariables.top = HUDTelvarMeter_getTop()
	
end

function PvpMeter.rotateMeter(param)

	if(param == 1)then
		Glow:SetTextureCoords(0,1,0,1)
		Gl:SetTextureCoords(0,1,0,1)
		
		LabelAP:ClearAnchors()
		LabelAP:SetAnchor(RIGHT,HUDTelvarMeter_KeyboardTemplate,RIGHT,-118,42)
		LabelMedal:ClearAnchors()
		LabelMedal:SetAnchor(RIGHT,HUDTelvarMeter_KeyboardTemplate,RIGHT,-118,42)
		
		-- texture
		teamiconAP:ClearAnchors()
		teamiconAP:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-103,-14)
		
		teamiconBG:ClearAnchors()
		teamiconBG:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-103,-4)
		
		LabelKill:ClearAnchors()
		LabelKill:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,58)
		LabelDeath:ClearAnchors()
		LabelDeath:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,92)
		
		LabelKillBG:ClearAnchors()
		LabelKillBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,58)
		LabelDeathBG:ClearAnchors()
		LabelDeathBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,92)
		LabelAssist:ClearAnchors()
		LabelAssist:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,89,50)
		
		--Anim
		HUDTelvarMeter_moveBar(0,0)
	end
	
	if(param == 2)then
		Glow:SetTextureCoords(1,0,0,1)
		Gl:SetTextureCoords(1,0,0,1)
		
		LabelAP:ClearAnchors()
		LabelAP:SetAnchor(LEFT,HUDTelvarMeter_KeyboardTemplate,LEFT,115,42)
		LabelMedal:ClearAnchors()
		LabelMedal:SetAnchor(LEFT,HUDTelvarMeter_KeyboardTemplate,LEFT,115,42)
		
		-- texture
		teamiconAP:ClearAnchors()
		teamiconAP:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-153,-14)

		
		teamiconBG:ClearAnchors()
		teamiconBG:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-153,-4)
		
		LabelKill:ClearAnchors()
		LabelKill:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,58)
		LabelDeath:ClearAnchors()
		LabelDeath:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,92)
		
		LabelKillBG:ClearAnchors()
		LabelKillBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,58)
		LabelDeathBG:ClearAnchors()
		LabelDeathBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,92)
		LabelAssist:ClearAnchors()
		LabelAssist:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-93,50)
		
		--Anim
		HUDTelvarMeter_moveBar(-164,0)
	end

	if(param == 3)then
		Glow:SetTextureCoords(1,0,1,0)
		Gl:SetTextureCoords(1,0,1,0)
		
		LabelAP:ClearAnchors()
		LabelAP:SetAnchor(LEFT,HUDTelvarMeter_KeyboardTemplate,LEFT,115,-42)
		LabelMedal:ClearAnchors()
		LabelMedal:SetAnchor(LEFT,HUDTelvarMeter_KeyboardTemplate,LEFT,115,-42)
		
		-- texture
		teamiconAP:ClearAnchors()
		teamiconAP:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-153,-98)
		
		teamiconBG:ClearAnchors()
		teamiconBG:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-153,-88)
		
		LabelKill:ClearAnchors()
		LabelKill:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,22)
		LabelDeath:ClearAnchors()
		LabelDeath:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,56)
		
		LabelKillBG:ClearAnchors()
		LabelKillBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,22)
		LabelDeathBG:ClearAnchors()
		LabelDeathBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-84,56)
		LabelAssist:ClearAnchors()
		LabelAssist:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,-93,14)
		
		--Anim
		HUDTelvarMeter_moveBar(-164,-36)
	end

	if(param == 4)then
		Glow:SetTextureCoords(0,1,1,0)
		Gl:SetTextureCoords(0,1,1,0)
		
		LabelAP:ClearAnchors()
		LabelAP:SetAnchor(RIGHT,HUDTelvarMeter_KeyboardTemplate,RIGHT,-118,-42)
		LabelMedal:ClearAnchors()
		LabelMedal:SetAnchor(RIGHT,HUDTelvarMeter_KeyboardTemplate,RIGHT,-118,-42)
		
		-- texture
		teamiconAP:ClearAnchors()
		teamiconAP:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-103,-98)
		
		teamiconBG:ClearAnchors()
		teamiconBG:SetAnchor(BOTTOM,HUDTelvarMeter_KeyboardTemplate,BOTTOMRIGHT,-103,-88)
		
		LabelKill:ClearAnchors()
		LabelKill:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,22)
		LabelDeath:ClearAnchors()
		LabelDeath:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,56)
		
		LabelKillBG:ClearAnchors()
		LabelKillBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,22)
		LabelDeathBG:ClearAnchors()
		LabelDeathBG:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,80,56)
		LabelAssist:ClearAnchors()
		LabelAssist:SetAnchor(TOP,HUDTelvarMeter_KeyboardTemplate,TOP,89,14)
		
		--Anim
		HUDTelvarMeter_moveBar(0,-36)
	end
								   
end

function PvpMeter.prepareQuickButton()

	--esoui/art/campaign/campaignbrowser_homecampaign.dds
	--
	--local taba = 20
	local taba = PvpMeter.savedVariables.chat
	
	PvpMeter.button =  WINDOW_MANAGER:CreateControl("PvpMeter_home_button", ZO_ChatWindow, CT_BUTTON)
    PvpMeter.button:SetDimensions(30, 30)
    PvpMeter.button:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, taba, 0)
    PvpMeter.button:SetNormalTexture("esoui/art/guild/tabicon_home_up.dds")
    PvpMeter.button:SetPressedTexture("esoui/art/guild/tabicon_home_down.dds")
    PvpMeter.button:SetMouseOverTexture("esoui/art/guild/tabicon_home_over.dds")
	--
	local tabb = taba+30+3
	
	PvpMeter.label_home =  WINDOW_MANAGER:CreateControl("PvpMeter_home_label", ZO_ChatWindow, CT_LABEL)
    PvpMeter.label_home:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, tabb , 4)
	PvpMeter.label_home:SetFont("ZoFontWinH4")
	PvpMeter.label_home:SetText("0")
	--
	
	PvpMeter.button:SetHandler("OnMouseEnter", function(...)
		ZO_Tooltips_ShowTextTooltip(PvpMeter.button, BOTTOM, GetCampaignName(GetAssignedCampaignId()) )
	end)
    PvpMeter.button:SetHandler("OnMouseExit", function(...)
		ZO_Tooltips_HideTextTooltip()
	end)
	--
	PvpMeter.button:SetHandler("OnClicked", function(...)
		QueueForCampaign(GetAssignedCampaignId(),false)
		--label:SetText("...")
	end)
	
	
	local minMaxClicked = ZO_ChatSystem_OnMinMaxClicked
	ZO_ChatSystem_OnMinMaxClicked = function(control)
		
		if CHAT_SYSTEM:IsMinimized() then
			--d("je maximize")
			
			if(PvpMeter.savedVariables.quickButton)then
			
				PvpMeter.button:SetHidden(false)
				PvpMeter.label_home:SetHidden(false)
			end
			
		else
			--d("je minimize")
			--if(PvpMeter.savedVariables.quickButton)then
				PvpMeter.button:SetHidden(true)
				PvpMeter.label_home:SetHidden(true)
			--end
			
		end
		minMaxClicked()
	end
	
	ZO_PreHook(CHAT_SYSTEM, "Minimize",
	function(self) 
		--d("je minimize")
			--if(PvpMeter.savedVariables.quickButton)then
				PvpMeter.button:SetHidden(true)
				PvpMeter.label_home:SetHidden(true)
			--end

	end)
	
	ZO_PreHook(CHAT_SYSTEM, "Maximize",
	function(self) 

		if(PvpMeter.savedVariables.quickButton)then
			
				PvpMeter.button:SetHidden(false)
				PvpMeter.label_home:SetHidden(false)
			end


	end)
	
	ZO_PreHook(SharedChatSystem, "StartTextEntry",
	function(self) 
		if(PvpMeter.savedVariables.quickButton)then
			PvpMeter.button:SetHidden(false)
			PvpMeter.label_home:SetHidden(false)
		end
	end)

end

function PvpMeter.updateButtonQuick() 

	if(PvpMeter.savedVariables.quickButton == false)then
				PvpMeter.button:SetHidden(true)
				PvpMeter.label_home:SetHidden(true)
	end
	if(PvpMeter.savedVariables.quickButton)then
			PvpMeter.button:SetHidden(false)
			PvpMeter.label_home:SetHidden(false)
		end

end

function PvpMeter.queue_joined (eventCode, campaignId, isGroup)

	--d("queue")
	if(campaignId==GetAssignedCampaignId())then
		PvpMeter.label_home:SetText("...")
	end

end


function PvpMeter.queue_left (eventCode, campaignId, isGroup)

	--d("left")
	if(campaignId==GetAssignedCampaignId())then
		PvpMeter.label_home:SetText("0")
	end

end

function PvpMeter.queue_position (eventCode, campaignId, isGroup, position)

	--d(position)
	if(campaignId==GetAssignedCampaignId())then
		PvpMeter.label_home:SetText(position)
	end

end


function PvpMeter.queue_state(eventCode, campaignId, isGroup, state)

	--d(state)
	if(state == 2)then
		--
		if(PvpMeter.savedVariables.autoqueue)then
			ConfirmCampaignEntry(campaignId, isGroup, true)
		end
		--
		if(campaignId==GetAssignedCampaignId())then
			PvpMeter.label_home:SetText("...")
		end
	end
	
end

function PvpMeter.onActivityFinderStatusUpdate(eventCode, status)

	if status == ACTIVITY_FINDER_STATUS_READY_CHECK then
		if(PvpMeter.savedVariables.autoqueue)then
		
		
			AcceptLFGReadyCheckNotification()
		end
	end
		
end
