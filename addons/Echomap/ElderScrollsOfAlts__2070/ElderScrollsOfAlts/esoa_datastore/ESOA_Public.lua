----------------------------------------
--[[ ESOA Datastore ]]-- 
----------------------------------------
-- External API
-- ONLY use SET methods for CURRENT server/account!
----------------------------------------


------------------------------
-- 
ESOADatastore = {
}

------------------------------
-- API
function ESOADatastore.saveCurrentCharcterDataAll(loadtype)
	EchoESOADatastore.saveCurrentCharcterDataAll(loadtype)
end

------------------------------
-- API
function ESOADatastore.saveCurrentCharcterDataSkills()
	--TODO EchoESOADatastore.saveCurrentCharcterData()
end

------------------------------
-- API
function ESOADatastore.saveCurrentCharcterDataCP()
	EchoESOADatastore.saveCurrentPlayerDataCPInt()
end

------------------------------
-- API
function ESOADatastore.saveCurrentCharcterDataCPActive()
	--TODO EchoESOADatastore.saveCurrentCharcterData()
end

------------------------------
-- API
function ESOADatastore.saveCurrentCharcterDataCategory()
	--TODO EchoESOADatastore.saveCurrentCharcterData()
end

------------------------------
-- API
function ESOADatastore.saveCharcterCustomData(characterLineKey, keyName, elementData)
	EchoESOADatastore.saveCharcterCustomData(characterLineKey, keyName, elementData)
end

------------------------------
-- API
function ESOADatastore.getCharcterCustomData(characterLineKey, keyName)
	return EchoESOADatastore.getCharcterCustomData(characterLineKey, keyName)
end

------------------------------
-- API
function ESOADatastore.saveCharcterTrackingData(characterLineKey, trackingType,trackingName,isCompleted,completedTimeStamp,timeToReset )
	EchoESOADatastore.saveCharcterTrackingData(characterLineKey,  trackingType,trackingName,isCompleted,completedTimeStamp,timeToReset )
end

------------------------------
-- API
function ESOADatastore.getCharcterTrackingData(characterLineKey, trackingType,trackingName)
	return EchoESOADatastore.getCharcterTrackingData(characterLineKey, trackingType,trackingName) --TODO
end

------------------------------
-- API
function ESOADatastore.saveCompanionDataLevel(playerKey, companionId, cname, level, currentExperience, experienceForLevel)
	EchoESOADatastore.saveCompanionDataLevel(playerKey, companionId, cname, level, currentExperience, experienceForLevel)
end

------------------------------
-- API
function ESOADatastore.saveCompanionDataSkillRank(playerKey, companionId, cname,  skillLineId, slName, rank )
	EchoESOADatastore.saveCompanionDataSkillRank(playerKey, companionId, cname,  skillLineId, slName, rank )
end

------------------------------
-- API
function ESOADatastore.saveCompanionDataSkillLine(playerKey, companionId, cname, skillLineId, slName )
	EchoESOADatastore.saveCompanionDataSkillLine(playerKey, companionId, cname, skillLineId, slName )
end

------------------------------
-- API
function ESOADatastore.saveCompanionDataRapport(playerKey, companionId, cname, currentRapport)
	EchoESOADatastore.saveCompanionDataRapport(playerKey, companionId, cname, currentRapport)
end


------------------------------
-- API
function ESOADatastore.saveCurrentCharcterDataScreenorder()
	--TODO EchoESOADatastore.saveCurrentCharcterData()
end

------------------------------
-- API
function ESOADatastore.saveCurrentCharcterDataTracking()
	--TODO EchoESOADatastore.saveCurrentCharcterData()
end

------------------------------
-- API (accountname is optional)
function ESOADatastore.getCharacterList(accountname)
	EchoESOADatastore.CheckDataIntegrity()
	return EchoESOADatastore.getCharacterList(accountname)
end

------------------------------
-- API (accountname is optional)
function ESOADatastore.getCharactersBasicData(accountname)
	return EchoESOADatastore.getCharactersBasicData(accountname)
end

------------------------------
-- API
function ESOADatastore.getDataForCharacters(account)
	return EchoESOADatastore.getDataForCharacters(account)
end

------------------------------
-- API
function ESOADatastore.getCharacterByID(characterID)
	return EchoESOADatastore.getDataForCharacterById(characterID)
end

------------------------------
-- API
function ESOADatastore.deleteCharacterByID(characterID,accountname)
	return EchoESOADatastore.deleteCharacterByID(characterID,accountname)
end

------------------------------
-- API
function ESOADatastore.deleteAllCharacterByAccount(accountname)
	return EchoESOADatastore.deleteAllCharacterByAccount(accountname)
end

------------------------------
-- API
function ESOADatastore.deleteAllCharacterByAccount(accountname)
	return EchoESOADatastore.deleteAllCharacterByAccount(accountname)
end

------------------------------
-- API
function ESOADatastore.getAccountList()
	EchoESOADatastore.CheckDataIntegrity()
	return EchoESOADatastore.getAccountList()
end

--TODO get all categories as list

----------------------------------------
----------------------------------------