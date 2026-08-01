local nameChunks = {"aak","aal","aam","aan","aar","aav","aaz","ag","ah","ahrk","ahst","al","am","au","aus","bah","bein","bel","bex","beyn","bo","bok","brit","brod","brom","bron","daal","daan","daar","dah","dalk","dein","dey","dez","dir","do","dok","dov","draal","dreh","drem","drey","drog","drun","du","du'ul","dun","dur","ek","faad","faal","faas","faaz","fah","feim","fel","fen","fent","fey","feyn","fin","fo","fod","frin","frod","fron","frul","ful","fun","funt","fus","gaaf","gaan","gaar","geh","gein","gol","golt","golz","graag","graan","grah","gram","grik","grind","gro","gron","gruth","gut","haal","haas","hah","heim","het","heyv","hi","him","hin","hind","hon","hun","in","jer","jol","joor","jot","jud","jul","jun","kaal","kaan","kaaz","kah","kein","kel","kelle","kest","key","keyn","kip","klo","klov","ko","kod","kol","koor","kos","krah","kreh","krein","kren","krent","krif","kril","krin","kro","kron","kul","kun","laan","laar","laas","laat","lah","leh","lein","lir","lo","lok","lon","loost","los","lost","lot","luft","lun","luv","maar","mah","mal","med","mey","meyz","mid","mir","mon","mu","mul","mun","muz","naak","naal","naan","naar","naas","nah","nahl","nall","nau","nax","neh","ney","ni","nid","nil","nin","nir","nis","nok","nol","nos","nu","nus","nust","nuz","od","ok","ol","om","on","ond","ont","oth","ov","paak","paal","paar","paaz","pah","pel","peyt","pook","praal","praan","qah","qeth","qo","qoth","raal","raan","rah","rath","rein","rek","rel","reyth","ro","roh","rok","ron","ros","rot","roth","ru","rul","ruth","ruz","sah","se","shaan","shor","shul","sil","slen","so","sod","sos","sot","sov","spaan","stin","strun","su","su'um","sul","tah","tey","thaarn","thu'um","thur","til","tol","toor","tu","tum","tuz","ul","um","un","unt","us","uth","uv","vaal","vaat","vaaz","vah","ved","ven","vey","vith","vod","vol","vos","voth","vul","vun","vur","vus","wah","wahl","wen","win","wo","wol","wuld","wuth","yah","yol","zaam","zaan","zah","zeim","zin","zind","zok","zol","zoor","zu'u","zul","zun"}
local existingNames = {["Ahbiilok"]=true,["Alduin"]=true,["Bahlokdaan"]=true,["Boziikkodstrun"]=true,["Dovahkiin"]=true,["Dukaanfinsot"]=true,["Durnehviir"]=true,["Grahkrindrog"]=true,["Joorahmaar"]=true,["Kaalgrontiid"]=true,["Krahjotdaan"]=true,["Krosulhah"]=true,["Kruziikrel"]=true,["Laatvulon"]=true,["Lokkestiiz"]=true,["Maarselok"]=true,["Mirmulnir"]=true,["Mulaamnir"]=true,["Naaslaarum"]=true,["Nahagliiv"]=true,["Nahfahlaar"]=true,["Nahviintaas"]=true,["Odahviing"]=true,["Paarthurnax"]=true,["Relonikiv"]=true,["Sahloknir"]=true,["Sahrotaar"]=true,["Sahrotnax"]=true,["Shulkunaak"]=true,["Thurvokun"]=true,["Vahlokzin"]=true,["Viinturuth"]=true,["Vithrelnaak"]=true,["Voslaarum"]=true,["Vuljotnaak"]=true,["Vulthuryol"]=true,["Yolnahkriin"]=true,["Yahgrondu"]=true}
local lastZoneId
local dragonUnits = {}

local function FirstToUpper(str)
	return (str:gsub("^%l", string.upper))
end

local function GetDragonName()
	local name

	repeat
		local chunkIndexes = {}
		
		local function HaveChunkIndex(i)
			for _, chunkIndex in ipairs(chunkIndexes) do
				if i == chunkIndex then
					return true
				end
			end
		
			return false
		end

		-- get 3 unique chunks
		repeat
			local i = math.random(#nameChunks)

			if not HaveChunkIndex(i) then
				table.insert(chunkIndexes, i)
			end
		until #chunkIndexes == 3

		name = FirstToUpper(nameChunks[chunkIndexes[1]]) .. nameChunks[chunkIndexes[2]] .. nameChunks[chunkIndexes[3]]
	until existingNames[name] == nil -- don't use existing names

	existingNames[name] = true

	return name
end

local orgGetUnitName = GetUnitName
function GetUnitName(unitTag)
	if dragonUnits[unitTag] then
		return dragonUnits[unitTag]
	end

	for dragonUnitTag in pairs(dragonUnits) do
		if AreUnitsEqual(unitTag, dragonUnitTag) then
			return dragonUnits[dragonUnitTag]
		end
	end

	return orgGetUnitName(unitTag)
end

local function GetNextWorldEventInstanceIdIter(state, var1)
	return GetNextWorldEventInstanceId(var1)
end

EVENT_MANAGER:RegisterForEvent(
	"DragonNamer",
	EVENT_WORLD_EVENT_UNIT_CREATED,
	function (_, _, unitTag)
		dragonUnits[unitTag] = GetDragonName()
	end
)

EVENT_MANAGER:RegisterForEvent(
	"DragonNamer",
	EVENT_WORLD_EVENT_UNIT_DESTROYED,
	function (_, _, unitTag)
		dragonUnits[unitTag] = nil
	end
)

EVENT_MANAGER:RegisterForEvent(
	"DragonNamer",
	EVENT_PLAYER_ACTIVATED,
	function ()
		local zoneId = GetUnitWorldPosition("player")

		if lastZoneId == zoneId then
			return
		end

		lastZoneId = zoneId
		dragonUnits = {}

		if zoneId == 1086 or zoneId == 1133 then
			for worldEventInstanceId in GetNextWorldEventInstanceIdIter do
				local unitTag = GetWorldEventInstanceUnitTag(worldEventInstanceId, 1)

				dragonUnits[unitTag] = GetDragonName()
			end
		end
	end
)