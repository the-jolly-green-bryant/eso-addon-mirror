----------------------------------------
--[[ ESOA Datastore ]]-- 
----------------------------------------
-- INTERNAL Implementation API
-- ONLY use SET methods for CURRENT server/account!
----------------------------------------


------------------------------
-- Implementation
function EchoESOADatastore.saveCurrentCharcterDataAll(loadtype)
	EchoESOADatastore.debugMsg("saveCurrentCharcterDataAll: loadtype=" , loadtype)
	--check if want to save player
	EchoESOADatastore.debugMsg("saveCurrentCharcterDataAll: savePlayer=", EchoESOADatastore.svESOADataAW.savePlayerData)
	if(EchoESOADatastore.svESOADataAW.savePlayerData) then
		EchoESOADatastore.saveCurrentPlayerDataInt()
	end
	--check if want to save equip
	EchoESOADatastore.debugMsg("saveCurrentCharcterDataAll: saveEquip=", EchoESOADatastore.svESOADataAW.saveEquipData)
	if(EchoESOADatastore.svESOADataAW.saveEquipData) then
		--TODO EchoESOADatastore.saveEquipData()
	end
	-- etc...?
end

------------------------------
-- Implementation
function EchoESOADatastore.getAccountList()
	local retval = {}
	if(EchoESOADatastore.svListDataAW.servers==nil) then
		local bar = {}
		bar.account = GetDisplayName()
		bar.server  = GetDisplayName()
		--local pServer   = GetWorldName()
		retval[bar.server] = bar
		return retval
	end
	for dServer, dName in pairs(EchoESOADatastore.svListDataAW.servers) do
		EchoESOADatastore.debugMsg("getAccountList: Account=".. dServer .. " dName=".. dName )
		local bar = {}
		bar.account = dServer
		bar.server  = dName
		retval[dServer] = bar
	end
	return retval
end

------------------------------
-- Implementation
-- Go through account (or all), and return a simple list of characters
-- Also, check for bad character names, ie, blank, or '-'
function EchoESOADatastore.getCharacterList(accountname)
	local retval = {}
	local delVal = {}
	if( accountname==nil ) then
		EchoESOADatastore.debugMsg("-Returning CharList for all Accounts" )
		for dAccount, dName in pairs(EchoESOADatastore.svListDataAW.servers) do
			EchoESOADatastore.debugMsg("getCharList: Account=", dAccount , " dName=", dName )
			for id, tdata in pairs(EchoESOADatastore.svListDataAW[dAccount].players) do
				EchoESOADatastore.debugMsg("getCharList: character1=[" , id , "] tdata=", tdata )
				if(tdata~=nil) then
					if(id==nil or id=="_") then
						local bar = {}
						bar.id = id
						bar.account = dAccount
						table.insert(delVal, bar)
					else
						local bar = {}
						bar.id = id
						bar.name = tdata.name
						bar.account = dAccount
						bar.server  = tdata.server
						table.insert(retval, bar)
					end
				end
			end
		end
	else
		if(EchoESOADatastore.svListDataAW[accountname]==nil) then
			EchoESOADatastore.outputMsg("WARN: -No character data for Account[",tostring(accountname),"]")
		else
			EchoESOADatastore.debugMsg("getCharList: for Account["..accountname.."]")
			for id, tdata in pairs(EchoESOADatastore.svListDataAW[accountname].players) do	
				EchoESOADatastore.debugMsg("getCharList: character2=[" , id , "] tdata=", tdata )
				if(tdata~=nil) then
					if(id==nil or id=="_") then
						local bar = {}
						bar.id = id
						bar.account = accountname
						table.insert(delVal, bar)
					else
						local bar = {}
						bar.id = id
						bar.name = tdata.name
						bar.account = accountname
						bar.server  = dAccount
						table.insert(retval, bar)
					end
				end
			end
		end
	end
	--	
	if(delVal~=nil) then
		for index, tvalue in pairs(delVal) do
			EchoESOADatastore.outputMsg("Cleaned up bad-data, for char idx=[".. tostring(index).. "] tval=".. tostring(tvalue) .. " ID='".. tostring(tvalue.id) .. "' account='".. tostring(tvalue.account).."'")
			EchoESOADatastore.deleteCharacterByID(tvalue.id,tvalue.account)
		end
	end
	EchoESOADatastore.debugMsg("getCharList: retval#=" , #retval )
	return retval
end

------------------------------
-- Implementation
function EchoESOADatastore.getCharactersBasicData(accountname)
	local retval = {}
	if( accountname==nil ) then
		for dServer, dName in pairs(EchoESOADatastore.svListDataAW.servers) do
			EchoESOADatastore.debugMsg("getBasicCharList: Account=".. dServer .. " dName=".. dName )
			for id, bar in pairs(EchoESOADatastore.svListDataAW[dServer].players) do
				table.insert(retval, bar)
			end
		end
	else
		if(EchoESOADatastore.svListDataAW[accountname]==nil) then
			EchoESOADatastore.debugMsg("  No data for Account[",tostring(accountname),"]")
		else
			EchoESOADatastore.outputMsg("  for Account["..accountname.."]")
			for id, bar in pairs(EchoESOADatastore.svListDataAW[accountname].players) do	
				table.insert(retval, bar)
			end
		end
	end
	return retval
end

------------------------------
-- UI/Console
function EchoESOADatastore.PrintPlayerNote(accountname)
	EchoESOADatastore.outputMsg("Charlist->")
	local reval = EchoESOADatastore.getCharacterList(accountname)
	if(reval~=nil) then
		for index, tvalue in pairs(reval) do
			--EchoESOADatastore.debugMsg("index=".. tostring(index) .. " tvalue=".. tostring(tvalue) )
			EchoESOADatastore.outputMsg("name=".. tostring(tvalue.name) .. " id=".. tostring(tvalue.id) .. " account=".. tostring(tvalue.account ) )
		end
	else
		EchoESOADatastore.outputMsg("No players listed in datastsore")
	end
	EchoESOADatastore.outputMsg("<--Charlist")
end

------------------------------
-- Implementation
function EchoESOADatastore.getDataForCharacters(account)
	--EchoESOADatastore.outputMsg("dfc: account='", tostring(account) , "'" )
	local retval1 = {}
	local reval = EchoESOADatastore.getCharacterList(account)
	if(reval~=nil) then
		for index, tvalue in pairs(reval) do
			--EchoESOADatastore.outputMsg("index=".. tostring(index) .. " tvalue=".. tostring(tvalue) )
			EchoESOADatastore.debugMsg("getCharData2: name=" , tostring(tvalue.name) , " id=".. tostring(tvalue.id) , " account=" , tostring(tvalue.account), " index=", index )
			local val = EchoESOADatastore.getDataForCharacterById(tvalue.id, account)
			retval1[tvalue.id] = val
		end
	else
		EchoESOADatastore.outputMsg("No players listed in datastsore for account["..account.."]")
	end
	return retval1
end

------------------------------
-- Implementation
function EchoESOADatastore.getDataForCharacterById(characterID,account)
	EchoESOADatastore.debugMsg("GetCharDataByID: for id: ", characterID, " account=" , account )
	if(account==nil) then
		account = EchoESOADatastore.GetAccountForCharacterByID(characterID)
	end
	if(account==nil) then
		EchoESOADatastore.outputMsg("-Error with account for character")
	end
	if(EchoESOADatastore.svListDataAW[account]==nil) then
		EchoESOADatastore.outputMsg("-No data for Account[",account,"]")
		return
	end
	local retval = {}
	EchoESOADatastore.debugMsg("GetCharDataByID: characterID=["..characterID.. "] for account["..account.."]" )
	retval.charkey     = characterID
	retval.accountname = account
	-- (Sections)
	retval["bio"] 			= EchoESOADatastore.svCharDataAW.sections.bio[characterID]
	retval["stats"] 		= EchoESOADatastore.svCharDataAW.sections.stats[characterID]
	retval["skills"]		= EchoESOADatastore.svCharDataAW.sections.skills[characterID]
	retval["tradeskills"] 	= EchoESOADatastore.svCharDataAW.sections.tradeskills[characterID]
	retval["xp"] 	 		= EchoESOADatastore.svCharDataAW.sections.xp[characterID]
	retval["power"]  		= EchoESOADatastore.svCharDataAW.sections.power[characterID]
	retval["riding"] 		= EchoESOADatastore.svCharDataAW.sections.riding[characterID]
	retval["bags"] 	 		= EchoESOADatastore.svCharDataAW.sections.bags[characterID]
	retval["skillpoints"] 	= EchoESOADatastore.svCharDataAW.sections.skillpoints[characterID]
	retval["achieve"]  		= EchoESOADatastore.svCharDataAW.sections.achieve[characterID]
	retval["currency"] 		= EchoESOADatastore.svCharDataAW.sections.currency[characterID]
	retval["ava"] 			= EchoESOADatastore.svCharDataAW.sections.ava[characterID]
	retval["pvp"] 			= EchoESOADatastore.svCharDataAW.sections.pvp[characterID]
	retval["infamy"] 		= EchoESOADatastore.svCharDataAW.sections.infamy[characterID]
	retval["location"]		= EchoESOADatastore.svCharDataAW.sections.location[characterID]
	retval["research"] 		= EchoESOADatastore.svCharDataAW.sections.research[characterID]
	retval["buffs"] 		= EchoESOADatastore.svCharDataAW.sections.buffs[characterID]
	retval["researchtraits"]= EchoESOADatastore.svCharDataAW.sections.researchtraits[characterID]
	retval["companions"] 	= EchoESOADatastore.svCharDataAW.sections.companions[characterID]
	retval["special"]       = EchoESOADatastore.svCharDataAW.sections.special[characterID]
	-- (Tracking)
	retval["tracking"] 		= EchoESOADatastore.svCharDataAW.tracking[characterID]		
	-- OTHER
	if(EchoESOADatastore.svCharDataAW.sections.equipment~=nil and EchoESOADatastore.svCharDataAW.sections.equipment[characterID]~=nil ) then
		retval["equipment"] = EchoESOADatastore.svCharDataAW.sections.equipment[characterID]
	--else
	--	EchoESOADatastore.outputMsg("SetupGuiPlayerEquipLinesDS: no equipment section for : [",characterID,"]" )
	end
	if(EchoESOADatastore.svCharDataAW.sections.championpoints~=nil and EchoESOADatastore.svCharDataAW.sections.championpoints[characterID]~=nil ) then
		retval["championpoints"] = EchoESOADatastore.svCharDataAW.sections.championpoints[characterID]	
	end
	--
	-- (Custom)-->
	if( EchoESOADatastore.svCharDataAW.custom ~= nil ) then
		retval["custom"]	= EchoESOADatastore.svCharDataAW.custom[characterID]
	end
	if( retval["custom"] == nil ) then
		retval["custom"] 	= {}
	end
	if( retval["custom"].category == nil ) then
		retval["custom"].category = "A"
	end
	if( retval["custom"].playersorder == nil ) then
		retval["custom"].playersorder = -1		
	end
	-- needed? retval["custom"].note = nil
	EchoESOADatastore.debugMsg("GetCharDataByID: for id: ", characterID, " category=" , retval["custom"].category )	
	-- <--(Custom)
	--
	-- TODO: (CP, Equipment) section(s)
	--
	--
	return retval
end

------------------------------
-- Implementation
--function EchoESOADatastore.getCharacterByName(characterName,account)
	--TODO
--end

------------------------------
-- Implementation
--function EchoESOADatastore.getCharacterByID(characterID,account)
	--TODO
--end

------------------------------
-- Implementation
--function EchoESOADatastore.getBasicDataForCharacters()
	--TODO
--end

------------------------------
-- Implementation
--function EchoESOADatastore.getBasicDataForCharacter(characterName)
	--TODO
--end

---------------------
-- Implementation
function EchoESOADatastore.GetNote(characterLineKey)
	local keyName = "note"
	return EchoESOADatastore.svCharDataAW.custom[characterLineKey][keyName]
end

---------------------
-- Implementation
function EchoESOADatastore.GetCustomData(characterLineKey,keyName)
	if(keyname~=nil) then
		return EchoESOADatastore.svCharDataAW.custom[characterLineKey][keyName]
	else
		return EchoESOADatastore.svCharDataAW.custom[characterLineKey]
	end
end

------------------------------
-- Implementation
function EchoESOADatastore.deleteCharacterByID(characterID,account)
	if(EchoESOADatastore.svListDataAW[account]==nil) then
		EchoESOADatastore.outputMsg("No data for Account["..account.."]")
		return
	end
	if(account==nil) then
		--find account for character ??
	end
	EchoESOADatastore.debugMsg("deleteCharacterByID: characterID=[",characterID, "] for account[",account,"]" )
	EchoESOADatastore.svListDataAW[account].players[characterID] = nil
	--
	EchoESOADatastore.svCharDataAW.sections.bio[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.stats[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.skills[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.tradeskills[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.xp[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.power[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.riding[characterID] = nil	 
	EchoESOADatastore.svCharDataAW.sections.bags[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.skillpoints[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.achieve[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.currency[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.ava[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.pvp[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.infamy[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.location[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.research[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.buffs[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.researchtraits[characterID] = nil
	
	EchoESOADatastore.svCharDataAW.sections.xp[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.special[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.companions[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.equipment[characterID] = nil
	EchoESOADatastore.svCharDataAW.sections.championpoints[characterID] = nil
	--
	EchoESOADatastore.svCharDataAW.tracking[characterID] = nil
	EchoESOADatastore.svCharDataAW.custom[characterID] = nil
	--
end

------------------------------
-- API
function EchoESOADatastore.deleteAllCharacterByAccount(accountname)
	--
	if(EchoESOADatastore.svListDataAW[accountname]==nil) then
		EchoESOADatastore.outputMsg("No data for Account["..accountname.."]")
		return
	end
	EchoESOADatastore.debugMsg("deleteAllCharacterByAccount: for account[",accountname,"]" )
	--
	local charList = EchoESOADatastore.getCharacterList(accountname)
	if(charList~=nil) then
		for index, tvalue in pairs(reval) do
			--EchoESOADatastore.debugMsg("index=".. tostring(index) .. " tvalue=".. tostring(tvalue) )
			EchoESOADatastore.outputMsg("name=".. tostring(tvalue.name) .. " id=".. tostring(tvalue.id) .. " account=".. tostring(tvalue.account ) )
			EchoESOADatastore.deleteCharacterByID(tvalue.id,accountname)
		end
	else
		EchoESOADatastore.outputMsg("No players listed in datastsore for account[",accountname,"]" )
	end
end

------------------------------
-- Internal/
function EchoESOADatastore.CheckDataIntegrity()
--[[
	d("Checking for Deletable chars..")
	local delVal = {}
	local reval = EchoESOADatastore.getCharacterList(account)
	if(reval~=nil) then
		for index, tvalue in pairs(reval) do
			EchoESOADatastore.outputMsg("Check: name=".. tostring(tvalue.name) .. " id=".. tostring(tvalue.id) .. " account=".. tostring(tvalue.account) )
			if(tvalue.id==nil or tvalue.id=="_") then
				table.insert(delVal, tvalue.id)
			end
			--local val = EchoESOADatastore.getDataForCharacterById(tvalue.id, account)
			--retval1[tvalue.id] = val
		end
	end
	if(delVal~=nil) then
		for index, tvalue in pairs(reval) do
			d("Deletable chars:".. tostring(index).. " tval=".. tostring(tvalue) )
		end
	end
]]
end

------------------------------
------------------------------

------------------------------
-- UTIL/
function EchoESOADatastore.GetAccountForCharacterByID(characterID)
	EchoESOADatastore.debugMsg("getAccountForChar: characterID=",characterID )
	local retval1 = nil
	local reval = EchoESOADatastore.getCharacterList()
	if(reval~=nil) then
		for index, tvalue in pairs(reval) do
			EchoESOADatastore.debugMsg("GetCharAccount: name=".. tostring(tvalue.name) .. " id=".. tostring(tvalue.id) .. " account=".. tostring(tvalue.account) )
			if( tvalue.id == characterID) then
				retval1 = tvalue.account
			end
		end
	else
		EchoESOADatastore.outputMsg("No players listed in datastsore")
	end
	return retval1
end

------------------------------
-- UTIL
function EchoESOADatastore:matchStringList(str,itemlist)
  if(itemlist==nil) then
	return false
  end
  for _, v in ipairs(itemlist) do
      if v == str then
          return true
      end
  end
  return false;
end

------------------------------
-- UTIL/
function EchoESOADatastore:flatten( item, result )
    local result = result or {}  --  create empty table, if none given during initialization
    if type( item ) == 'table' then
        for k, v in pairs( item ) do
            flatten( v, result )
        end
    else
        result[ #result +1 ] = item
    end
    return result
end


----------------------------------------
----------------------------------------