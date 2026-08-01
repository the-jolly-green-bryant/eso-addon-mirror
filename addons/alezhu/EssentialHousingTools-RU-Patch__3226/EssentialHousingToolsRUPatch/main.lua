EHTRU = EHTRU or {
	name = "EssentialHousingToolsRUPatch",
	tag = "ETHRU",
	version = "1.0.0",
	debug = false,
	viaHook = false,
	initialized = false,
	playerActivated = false,
	logData = {}
}

do
	if EHTRU.debug then
		local function _log(msg)
			d(msg)
		end	
		local function _logf(...)
			df(...)
		end	
	
		function log(str, ...)
			if EHTRU.playerActivated then
				if ... == nil  then
					_log(str)
				else
					_logf(str,...)
				end
			else
				table.insert(EHTRU.logData, {str,{...}})
			end
		end
	else
		function log() end
	end
	

	local function Initialize( )
		if not EHTRU.initialized then
			EHTRU.initialized = true
			local lang = GetCVar("language.2")
			log("EHTRU.Lang: %s", lang)
			if lang == "ru" then
				local stationSkillType = {
					[CRAFTING_TYPE_BLACKSMITHING] = "кузница",
					[CRAFTING_TYPE_CLOTHIER] = "портняжный станок",
					[CRAFTING_TYPE_JEWELRYCRAFTING] = "стол ювелира",
					[CRAFTING_TYPE_WOODWORKING] = "столярный верстак"
				}
				for key, effectType in pairs( EHT.Effect.POITradeskillEffectTypes ) do
					local keyword = stationSkillType[effectType.TradeskillType]
					if keyword then
						log(effectType.Keywords)
						log("EHTRU.Add keyword: %s", keyword)
						table.insert(effectType.Keywords, keyword)
						log(effectType.Keywords)
						EHT.Effect.POITradeskillEffectTypes[key] = effectType
					end
				end
			end
		end
	end

	if EHTRU.viaHook then
		local origFunc = EHT.Effect.GetPOIEffectTypeNameByItemOrSet
		local patched = false
		function EHT.Effect:GetPOIEffectTypeNameByItemOrSet(link, setFilters)
			if not patched then
				log("Hook")
				patched = true
				Initialize( )
			end
			return origFunc(self,link,setFilters)
		end
	end
	
	local unpack = _G.unpack or table.unpack 
	
	local function OnPlayerActivated(...)
		EHTRU.playerActivated = true
		for	_,value in ipairs( EHTRU.logData ) do
			if value and #value ~= 0 then
				local str = value[1]
				local data = value[2]
				if not data or #data == 0 then
					d(str)
				else
					df(str,unpack(data))
				end
			end
		end
		EHTRU.logData = {}
	end

	local function OnPlayerDeactivated(...)
		EHTRU.playerActivated = false
	end

	
	-- On load
	local function OnAddOnLoaded(_, addonName)
		if (addonName == EHTRU.name) then
			log("[%s] loaded" , addonName)
			EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
			if not EHTRU.viaHook then
				Initialize()
				--- Register for events ---
				EVENT_MANAGER:RegisterForEvent(EHTRU.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
				EVENT_MANAGER:RegisterForEvent(EHTRU.name, EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)
			end
		end
	end

	EVENT_MANAGER:RegisterForEvent(EHTRU.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end