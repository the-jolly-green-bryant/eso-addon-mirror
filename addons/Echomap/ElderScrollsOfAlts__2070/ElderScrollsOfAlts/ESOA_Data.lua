----------------------------------------
--[[ ESOA ]]-- 
----------------------------------------
-- INTERNAL Implementation API
----------------------------------------


------------------------------
--NEW BETA/ALPHA
function ElderScrollsOfAlts.DataSaveLivePlayerNew()
	ElderScrollsOfAlts.outputMsg("DataSaveLivePlayerNew: Called")
	local playerKey = ElderScrollsOfAlts.GeneratePlayerKeyForCurrentCharacter()
	ElderScrollsOfAlts.view.whoiamplayerKey = tostring(playerKey)	
	ElderScrollsOfAlts.debugMsg("Set WhoamI: playerKey=",playerKey)
	if (EchoESOADatastore ~= nil) then
		EchoESOADatastore.saveCurrentPlayerData()
	else 
		ElderScrollsOfAlts:DataSaveLivePlayer()
	end
end

------------------------------
-- 
function ElderScrollsOfAlts:LoadPlayerDataForGui()
	-- what these for, todo
	ElderScrollsOfAlts.view.accountData = {}
	ElderScrollsOfAlts.view.accountData.secondsplayed = 0
	--
	if( ESOADatastore~=nil ) then
		ElderScrollsOfAlts.debugMsg("LoadPlayerDataForGui: Called DS: allconverted?",tostring(ElderScrollsOfAlts.altData.convertedToDataStor) )
		if(ElderScrollsOfAlts.altData.convertedToDataStore==nil) then
			-- Use Datastore and Legacy
			-- Check if chardata is in the Datastore
			ElderScrollsOfAlts.view.playerLines = ElderScrollsOfAlts:SetupGuiPlayerLinesDS()
			local dsNum = ElderScrollsOfAlts:tablelength(ElderScrollsOfAlts.view.playerLines)
			--load Legacy Stored Data
			ElderScrollsOfAlts:SetupGuiPlayerLinesDSpre()			
			local legNum = ElderScrollsOfAlts:tablelength(ElderScrollsOfAlts.view.playerLines)
			if( (legNum-dsNum)>0 ) then
				ElderScrollsOfAlts.outputMsg("Loaded: DS#:",dsNum, " Legacy#:",(legNum-dsNum), " Total#:", legNum )
			else
				ElderScrollsOfAlts.debugMsg("Loaded from Datastore, cnt#=", dsNum )
			end
		else
			-- Only Use Datastore
			ElderScrollsOfAlts.view.playerLines = ElderScrollsOfAlts:SetupGuiPlayerLinesDS()
		end
	else
		-- Only legacy
		ElderScrollsOfAlts.debugMsg("LoadPlayerDataForGui: Called Legacy")
		ElderScrollsOfAlts.view.playerLines = ElderScrollsOfAlts:SetupGuiPlayerLines()
		ElderScrollsOfAlts.view.needToLoadGuiData = false
		ElderScrollsOfAlts.debugMsg("LoadPlayerDataForGui:", " called") 
	end
	table.sort(ElderScrollsOfAlts.view.playerLines)  
	ElderScrollsOfAlts.view.maxPlayerLineCount = #ElderScrollsOfAlts.view.playerLines		
end

------------------------------
-- 
function ElderScrollsOfAlts.GeneratePlayerKeyForCurrentCharacter()
	local pName     = GetUnitName("player")
	local rName     = GetRawUnitName("player")   
	local pID       = GetCurrentCharacterId()
	local pServer   = GetWorldName()
	local playerKey = pID.."_".. pServer:gsub(" ","_")
	ElderScrollsOfAlts.view.currentplayerkey = playerKey
	return playerKey
end

------------------------------
-- 
function ElderScrollsOfAlts.SavePlayerDataForGui(loadtype)
	ElderScrollsOfAlts.debugMsg("SavePlayerDataForGui: loadtype='"..tostring(loadtype).."'")
	ElderScrollsOfAlts.GeneratePlayerKeyForCurrentCharacter()
	--
	if(ESOADatastore~=nil and ElderScrollsOfAlts.altData.players==nil ) then
		ElderScrollsOfAlts.altData.convertedToDataStore = true
	end
	--
	ElderScrollsOfAlts.DataSaveLivePlayer(loadtype)
	--ALPHA ElderScrollsOfAlts.DataSaveLivePlayerNew()
	ElderScrollsOfAlts.view.needToLoadGuiData = true
	ElderScrollsOfAlts.debugMsg("SavePlayerDataForGui:", " called") 
	ElderScrollsOfAlts:ResetPlayerOrder()
end

------------------------------
-- 
--
function ElderScrollsOfAlts.SavePlayerData( playerLineKey, keyName, elementData )
	ElderScrollsOfAlts.debugMsg("SavePlayerData: playerKey=",playerLineKey," keyName=",keyName," as ", elementData) 
	if (ESOADatastore ~= nil) then
		ElderScrollsOfAlts.SavePlayerDataDS( playerLineKey, keyName, elementData )
		ElderScrollsOfAlts.SavePlayerDataLegacy( playerLineKey, keyName, elementData )
	else 
		ElderScrollsOfAlts.SavePlayerDataLegacy( playerLineKey, keyName, elementData )
	end
end

------------------------------
-- 
--20250518 trying to use datastore instead of this addon SV for alt data
-- Read all data from the game Player Object into this Addon
function ElderScrollsOfAlts.DataSaveLivePlayer(loadtype)
	ElderScrollsOfAlts.debugMsg("DataSaveLivePlayer: loadtype='"..tostring(loadtype).."'")
	--TODO pause 
	if(ElderScrollsOfAlts.view.pauseactivesave) then 
		ElderScrollsOfAlts.debugMsg( GetString(ESOA_MSG_PAUSED) )
		return
	end
	local isInDungeon = IsUnitInDungeon("player")
	if(isInDungeon and ElderScrollsOfAlts.savedVariables.dontLoadDataInDungeon ) then
		ElderScrollsOfAlts.debugMsg("DataSaveLivePlayer:", " stopping per in instance") 
		return
	end
	local isInCombat = IsUnitInCombat("player")
	if(isInCombat and ElderScrollsOfAlts.savedVariables.dontLoadDataInCombat ) then
		ElderScrollsOfAlts.debugMsg("DataSaveLivePlayer:", " stopping per in combat") 
		return
	end
	local isPvPFlagged = IsUnitPvPFlagged("player")
	if(isInCombat and ElderScrollsOfAlts.savedVariables.dontLoadDataWhilePvPFlagged ) then
		ElderScrollsOfAlts.debugMsg("DataSaveLivePlayer:", " stopping per is PvPFlagged") 
		return
	end
	--
	local playerKey = ElderScrollsOfAlts.GeneratePlayerKeyForCurrentCharacter()
	ElderScrollsOfAlts.view.whoiamplayerKey = tostring(playerKey)
	ElderScrollsOfAlts.debugMsg("Set WhoamI: playerKey=",playerKey)
	--
	if (ESOADatastore ~= nil) then
		ESOADatastore.saveCurrentCharcterDataAll(loadtype)
	else 
		ElderScrollsOfAlts.DataSaveLivePlayer2(loadtype)
	end
end

------------------------------
--Companions
function ElderScrollsOfAlts:CollectCompanionDataLevel(companionId, cname, level, currentExperience, experienceForLevel)
	ElderScrollsOfAlts.debugMsg("CollectCompanionDataLevel: Called")
	if (EchoESOADatastore ~= nil) then
		ElderScrollsOfAlts:CollectCompanionDataLevelDS(companionId, cname, level, currentExperience, experienceForLevel)
	else
		ElderScrollsOfAlts:CollectCompanionDataLevelLegacy(companionId, cname, level, currentExperience, experienceForLevel)
	end
end

------------------------------
--Companions
function ElderScrollsOfAlts:CollectCompanionDataSkillRank(companionId, cname, skillLineId, slName, rank )
	ElderScrollsOfAlts.debugMsg("CollectCompanionDataSkillRank: Called")
	if (EchoESOADatastore ~= nil) then
		ElderScrollsOfAlts:CollectCompanionDataSkillRankDS(companionId, cname, skillLineId, slName, rank )
	else
		ElderScrollsOfAlts:CollectCompanionDataSkillRankLegacy(companionId, cname, skillLineId, slName, rank )
	end
end

------------------------------
--Companions
function ElderScrollsOfAlts:CollectCompanionDataSkillLine(companionId, cname, skillLineId, slName )
	ElderScrollsOfAlts.debugMsg("CollectCompanionDataSkillLine: Called")
	if (EchoESOADatastore ~= nil) then
		ElderScrollsOfAlts:CollectCompanionDataSkillLineDS(companionId, cname, skillLineId, slName )
	else
		ElderScrollsOfAlts:CollectCompanionDataSkillLineLegacy(companionId, cname, skillLineId, slName )
	end
end

------------------------------
--Companions
function ElderScrollsOfAlts:CollectCompanionDataRapport(companionId, cname, currentRapport)
	ElderScrollsOfAlts.debugMsg("CollectCompanionDataRapport: Called for companionId=",companionId, " cname=",cname)
	if (EchoESOADatastore ~= nil) then
		ElderScrollsOfAlts:CollectCompanionDataRapportDS(companionId, cname, currentRapport )
	else
		ElderScrollsOfAlts:CollectCompanionDataRapportLegacy(companionId, cname, currentRapport )
	end
end

------------------------------
--
function ElderScrollsOfAlts:SaveTrackingDataComplete(trackingType,trackingName,isCompleted)
	ElderScrollsOfAlts.debugMsg("trackingType: "..tostring(trackingType) .. " trackingName: " ..tostring(trackingName) )
	local trackElem = nil
	if (EchoESOADatastore ~= nil) then
		local hour, minute = ElderScrollsOfAlts:dailyReset()
		local timeToReset = hour*3600 + minute*60
		trackElem = ElderScrollsOfAlts:SaveTrackingDataDS( trackingType,trackingName,isCompleted,GetTimeStamp(),timeToReset )
	else
		trackElem = ElderScrollsOfAlts:InitTrackingDataLegacy(trackingType,trackingName)
		--
		trackElem.name          = trackingName
		trackElem.cat           = trackingType
		trackElem.completed     = isCompleted
		trackElem.completedtime = GetTimeStamp()
		local hour, minute = ElderScrollsOfAlts:dailyReset()
		local timeToReset = hour*3600 + minute*60
		trackElem.resettime     = trackElem.completedtime + timeToReset
		--trackElem.resettime     = GetTimeStamp today at 10am UTC NA for 3am UTC EU ??
		-- TODO EU NA
		--timeToReset = 5*3600 + 0*60
		--trackElem.resettime     = timeToReset
	end
end

------------------------------
--
function ElderScrollsOfAlts:CheckIfCpTypeIsSlottable(championSkillType)
  if(ElderScrollsOfAlts.view.CpTypeIsSlottable==nil) then
    ElderScrollsOfAlts.view.CpTypeIsSlottable = {}
  end
  if(ElderScrollsOfAlts.view.CpTypeIsSlottable[championSkillType]==nil) then
    ElderScrollsOfAlts.view.CpTypeIsSlottable[championSkillType] = CanChampionSkillTypeBeSlotted(championSkillType)
  end
  return ElderScrollsOfAlts.view.CpTypeIsSlottable[championSkillType]
end

------------------------------
--
function ElderScrollsOfAlts:CollectCP()
	if (EchoESOADatastore ~= nil) then
		ESOADatastore.saveCurrentCharcterDataCP()
	else 
		ElderScrollsOfAlts:CollectCPLegacy()
	end
end


------------------------------
--
--("world","Vampire","Blood Ritual")
function ElderScrollsOfAlts:FindAbility(tplayer,skillType,skillClass,skillName)
	local retVal = nil
	if (EchoESOADatastore ~= nil) then
		if( tplayer.skills~=nil and 
			tplayer.skills[skillType]~=nil and 
			tplayer.skills[skillType][skillClass]~=nil and
			tplayer.skills[skillType][skillClass]["abilities"]~=nil and
			tplayer.skills[skillType][skillClass]["abilities"][skillName]~=nil) then
				retVal = tplayer.skills[skillType][skillClass]["abilities"][skillName]
		end
		--[[
		if( tplayer.skills~=nil ) then
			EchoESOADatastore.outputMsg("FindAbility: 1")
			if( tplayer.skills[skillType]~=nil ) then
				EchoESOADatastore.outputMsg("FindAbility: 2")
				if( tplayer.skills[skillType][skillClass]~=nil ) then
					EchoESOADatastore.outputMsg("FindAbility: 3")
					if( tplayer.skills[skillType][skillClass]["abilities"]~=nil ) then
						EchoESOADatastore.outputMsg("FindAbility: 4")
						if( tplayer.skills[skillType][skillClass]["abilities"][skillName]~=nil ) then
							EchoESOADatastore.outputMsg("FindAbility: 5")
						end
					end
				end
			end
		end
		EchoESOADatastore.outputMsg("FindAbility: retVal=",tostring(retVal))
		]]
	else	
	  if( tplayer.skills~=nil and 
		  tplayer.skills[skillType]~=nil and 
		  tplayer.skills[skillType]["typelist"]~=nil and
		  tplayer.skills[skillType]["typelist"][skillClass]~=nil and
		  tplayer.skills[skillType]["typelist"][skillClass]["abilities"]~=nil and
		  tplayer.skills[skillType]["typelist"][skillClass]["abilities"][skillName]~=nil) then
		retVal = tplayer.skills[skillType]["typelist"][skillClass]["abilities"][skillName]
	  end
	end
  return retVal
end

----------------------------------------
 --[[ ESOA Data ]]-- 
----------------------------------------