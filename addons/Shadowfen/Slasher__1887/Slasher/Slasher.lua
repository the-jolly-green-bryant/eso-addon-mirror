local SF = LibSFUtils

local SL=Slasher
local ASST=Slasher.assts
local HOLS=Slasher.holiday_items
local OTHR=Slasher.other

--local ZOS_addSystemMsg = function(text) CHAT_SYSTEM:AddMessage(text) end
local ZOS_addSystemMsg = function(text) CHAT_ROUTER:AddSystemMessage(text) end
--local ZOS_addSystemMsg = d

local cakes ={
	-- add new cakes to the top, so the newest unlocked one is used
	{ id = HOLS.JUBALEE_CAKE2026, year = 2026, },
	{ id = HOLS.JUBALEE_CAKE2025, year = 2025, },
	{ id = HOLS.JUBALEE_CAKE2024, year = 2024, },
	{ id = HOLS.JUBALEE_CAKE2023, year = 2023, },
	{ id = HOLS.JUBALEE_CAKE2022, year = 2022, },
	{ id = HOLS.JUBALEE_CAKE2021, year = 2021, },
	{ id = HOLS.JUBALEE_CAKE2020, year = 2020, },
	{ id = HOLS.JUBALEE_CAKE2019, year = 2019, },
	{ id = HOLS.JUBALEE_CAKE3,    year = 2018, },
	{ id = HOLS.JUBALEE_CAKE2,    year = 2017, },
	{ id = HOLS.JUBALEE_CAKE,     year = 2016, },
}

local defaults = {
	fence = ASST.PIR_FENCE[1],
	banker = ASST.CROW_BANKER[1],
	merchant = ASST.MERCHANT,
	decon = ASST.DECON[1],
	resummon = true,
}

local pets = {
	23304, 30631, 30636, 30641, 23319, 30647, 30652, 30657, 23316, 30664, 30669, 30674, -- familiars
	24613, 30581, 30584, 30587, 24636, 30592, 30595, 30598, 24639, 30618, 30622, 30626, -- twilights
	85982, 85983, 85984, 85985, 85986, 85987, 85988, 85989, 85990, 85991, 85992, 85993 -- grizzly bears
}

-- Create names for keybindings
ZO_CreateStringId('SI_BINDING_NAME_SLASHER_RELOADUI', GetString(SL_BINDING_RELOADUI))
ZO_CreateStringId('SI_BINDING_NAME_SLASHER_LEAVE', GetString(SL_BINDING_LEAVE))
--ZO_CreateStringId('SI_BINDING_NAME_SLASHER_DISBAND', GetString(SL_BINDING_DISBAND))
--ZO_CreateStringId('SI_BINDING_NAME_SLASHER_READY', GetString(SL_BINDING_READY))
ZO_CreateStringId('SI_BINDING_NAME_SLASHER_GOHOME', 'Go Home')
ZO_CreateStringId('SI_BINDING_NAME_SLASHER_GRASS', GetString(SL_BINDING_GRASS))
ZO_CreateStringId('SI_BINDING_NAME_ANTIQUARIAN_EYE', GetString(SL_BINDING_EYE))
ZO_CreateStringId('SI_BINDING_NAME_SLASHER_DISMISS_PET', GetString(SL_BINDING_PETS))


ZO_CreateStringId('SI_BINDING_NAME_SLASHER_FAV_BANKER_TOGGLE', GetString(SL_FAV_BANKER))
ZO_CreateStringId('SI_BINDING_NAME_SLASHER_FAV_MERCHANT_TOGGLE', GetString(SL_FAV_MERCHANT))
ZO_CreateStringId('SI_BINDING_NAME_SLASHER_FAV_FENCE_TOGGLE', GetString(SL_FAV_FENCE))
ZO_CreateStringId('SI_BINDING_NAME_SLASHER_FAV_DECON_TOGGLE', GetString(SL_FAV_DECON))
ZO_CreateStringId('SI_BINDING_NAME_SLASHER_FAV_ARMORER_TOGGLE', GetString(SL_FAV_ARMORER))

local n
for k, v in pairs(SL.assts) do
	name = GetCollectibleInfo(v[1])
	ZO_CreateStringId(v[3], name)
end

n = GetCollectibleInfo(HOLS.BREDAS_MEAD_CUP)
ZO_CreateStringId('SI_BINDING_NAME_SLASHER_MEAD', n)

n = GetCollectibleInfo(HOLS.JUBALEE_CAKE2026)
ZO_CreateStringId('SI_BINDING_NAME_SLASHER_CAKE', n)

n = GetCollectibleInfo(HOLS.WITCHMOTHERS_WHISTLE)
ZO_CreateStringId('SI_BINDING_NAME_SLASHER_WITCH_WHISTLE', n)

n = GetCollectibleInfo(HOLS.PIE_OF_MISRULE)
ZO_CreateStringId('SI_BINDING_NAME_SLASHER_PIE', n)

n = GetCollectibleInfo(OTHR.ANTIQUARIAN_EYE)
ZO_CreateStringId('SI_BINDING_NAME_ANTIQUARIAN_EYE', n)

---------------------
local function internalMsg(text, textcolor)
	local prefix = SF.colors.bronze:Colorize("["..SL.name.."] ")
	if type(text) == "number" then
		text = GetString(text)
	end
	local msg = textcolor:Colorize(text)
	ZOS_addSystemMsg(prefix..msg);
end

local function SystemMessage(text)
	if type(text) == "number" then
		return internalMsg(GetString(text, SF.colors.mocassin))
	end
    return internalMsg(text, SF.colors.mocassin)
end

local function DebugMessage(text)
	if not SL.saved.debug then return end
    internalMsg(text, SF.colors.ltskyblue)
end

----------
-- INIT --
----------
local function onPlayerActivated()
	-- only runs once
	SL.evtmgr:unregEvt(EVENT_PLAYER_ACTIVATED)
end

local function onAddonLoaded(_, addonName)
	if addonName == SL.name then
		SL.evtmgr:unregEvt(EVENT_ADD_ON_LOADED)

        aw, toon = SF.getAllSavedVars("SlasherVar", 1, defaults)
        SL.saved = SF.currentSavedVars(aw, toon)

		SL.RegisterSettings()
		SL.evtmgr:registerEvt(EVENT_PLAYER_ACTIVATED, onPlayerActivated)
	end

end

function Slasher.dismissPets()
	-- Walk through active buffs looking for the cancelables (likely pets)
	local i
	for i = 1, GetNumBuffs("player") do
		local buffName, _, _, buffSlot, _, _, _, _, _, _, abilityId, canClickOff = GetUnitBuffInfo("player", i)
		if canClickOff == true then
			--d("found possible pet: "..buffName)
			-- Compare each buff's abilityID to the list of IDs we were given
			for k, v in pairs(pets) do
				if abilityId == v then
					-- It is a pet so cancel it
					CancelBuff(buffSlot)
				end
			end
		end
	end
end

-- accepts either a table entry from SL.assts or an itemId and an error message to display
local function useCollectibleItem(item, errmsg)
	local itemid
	local emsg = errmsg
	if type(item) == "table" then
		itemid = item[1]
		emsg = GetString(item[2])

	else
		itemid = item
		emsg = GetString(errmsg)
	end
	local name,description,icon,lockedIcon,unlocked,purchasable,isActive = GetCollectibleInfo(itemid)
	if( unlocked == true ) then
		UseCollectible(itemid)
	elseif emsg then
		SystemMessage(emsg)
	end
end

local function useCake(errmsg, year)
	local function getNewestCake()
		for _, cake in ipairs(cakes) do
			if IsCollectibleUnlocked(cake.id) then
				return cake.id
			end
		end
	end

	local function getYearCake(year)
		local yr = tonumber(year)
		for _, cake in ipairs(cakes) do
			if cake.year == yr and IsCollectibleUnlocked(cake.id) then
				return cake.id
			end
		end
	end
	id = nil
	if not year then
		id = getNewestCake()
	else
		id = getYearCake(year)
	end
	if id then
		UseCollectible(id)
		return
	end

	-- does not possess any of the cakes or not the specified year cake
	SystemMessage(errmsg)
end

--unused
local function isLeader()
    if GetGroupSize() > 1 and IsUnitGroupLeader(UNITTAG_PLAYER) then
		return true
	end
	return false
end

local function isInGroup()
    local groupSize = GetGroupSize()
	if groupSize > 1 then
		return true
	end
	return false
end

function SL.leaveGroup()
    if isInGroup() then
		GroupLeave()
	end
end

function SL.disbandGroup()
    if isInGroup() and IsUnitPlayer(GetGroupLeaderUnitTag()) then
		if not (IsActiveWorldBattleground() or IsInLFGGroup()) then
			GroupDisband()
		else
			SystemMessage(GetString(SLASHER_GROUP_ERROR))
		end
	end
end

function SL.readyCheck()
    if isInGroup() then
		ZO_SendReadyCheck()
	end
end



function SL.gohome()
	local primary = GetHousingPrimaryHouse()
	if( primary == nil ) then 
		SystemMessage(GetString(SLASHER_HOME_NO_PRIMARY))
		return 
	end
	local collectible=GetCollectibleIdForHouse(primary)
	local name,description,icon,lockedIcon,unlocked,purchasable,isActive,Collectible,categoryType,hint,isPlaceholder=GetCollectibleInfo(collectible)
	if( unlocked == true ) then
		SystemMessage(GetString(SLASHER_HOME_GOING_TO)..name)
		RequestJumpToHouse(primary)
	else
		SystemMessage(GetString(SLASHER_HOME_NOT_OWN)..name)
	end
end

function Slasher.togglegrass()
	--valid = { CLUTTER_QUALITY_OFF, CLUTTER_QUALITY_LOW, CLUTTER_QUALITY_MEDIUM, CLUTTER_QUALITY_HIGH, CLUTTER_QUALITY_ULTRA, }	
	local current = tonumber(GetSetting( SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_CLUTTER_2D_QUALITY ))
	local new = CLUTTER_QUALITY_MEDIUM
	if current ~= CLUTTER_QUALITY_OFF then 
		new = CLUTTER_QUALITY_OFF 
	end
	SetSetting( SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_CLUTTER_2D_QUALITY, new )
end

function Slasher.shutoffZOSSkyshards()
	RedirectTexture("EsoUI/Art/MapPins/skyshard_seen.dds", "/esoui/art/icons/heraldrycrests_misc_blank_01.dds")
	RedirectTexture("EsoUI/Art/Compass/skyshard_seen.dds", "/esoui/art/icons/heraldrycrests_misc_blank_01.dds")
end

function SL.reloadui()
    ReloadUI("ingame")
end


local function isAsstActive(id)
	if id == nil or id == 0 then return false end
	local name,description,icon,lockedIcon,unlocked,purchasable,isActive=GetCollectibleInfo(id)
	return (unlocked and isActive)
end

-- returns the id of the companion that is currently active (out), or 0 if noone is out
local companion_active = 0
local function getActiveCompanion()
	if SL.saved.resummon == false then return 0 end

	local name,description,icon,lockedIcon,unlocked,purchasable,isActive
	for k,v in pairs(SL.companions) do
		name,description,icon,lockedIcon,unlocked,purchasable,isActive=GetCollectibleInfo(v[1])
		if isActive == true then
			return v[1]
		end
	end
	return companion_active
end

local function getAssistant(id)
	for k,v in pairs(SL.assts) do
		if v[1] == id then
			return v
		end
	end
	return nil
end

local function summon(asst, defaulted, basic)
	local id
	if asst == nil or type(asst) == "number" then
		asst = getAssistant(defaulted)
		if asst then
			id = asst[1]
		end

		if not id then
			asst = basic
		end
	elseif type(asst) == "table" then
		id = asst[1]
	end

	if not id then return end
	companion_active = getActiveCompanion()
	if isAsstActive(id) == true then
		-- dismissing
		if companion_active ~= 0 then
			useCollectibleItem(companion_active)
			companion_active = 0
		else
			useCollectibleItem(asst)
		end
	else
		useCollectibleItem(asst)
	end
end

function SL.summon_banker(asst)
	summon(asst, SL.saved.banker, SL.assts[BANKER])
end

function SL.summon_merchant(asst)
	summon(asst, SL.saved.merchant, SL.assts[MERCHANT])
end

function SL.summon_armorer(asst)
	summon(asst, SL.saved.armorer, SL.assts[ARMORER])
end

function SL.summon_decon(asst)
	summon(asst, SL.saved.decon, SL.assts[DECON])
end

function SL.summon_fence(asst)
	summon(asst, SL.saved.fence, SL.assts[FENCE])
end

local id2err = {
		[479] = SLASHER_ITEM_WHISTLE,
		[1167] = SLASHER_ITEM_PIE,
		[1168] = SLASHER_ITEM_MEADCUP,
		[356] =  SLASHER_ITEM_CAKE,		-- 2016
		[1109] = SLASHER_ITEM_CAKE,		-- 2017
		[4786] = SLASHER_ITEM_CAKE,		-- 2018
		[5886] = SLASHER_ITEM_CAKE,		-- 2019
		[7619] = SLASHER_ITEM_CAKE,		-- 2020
		[9012] = SLASHER_ITEM_CAKE,		-- 2021
		[10287] = SLASHER_ITEM_CAKE,	-- 2022
		[11089] = SLASHER_ITEM_CAKE,	-- 2023
		[12422] = SLASHER_ITEM_CAKE,	-- 2024
}

function SL.use_memento(mid)
	--SystemMessage("use_memento with "..mid.." type = "..type(mid))
	local id = mid
	if id == nil then return end
	local n, _, _, _, unlk, _, actv = GetCollectibleInfo(id)
	if n and n ~= "" then
		--SystemMessage("found collectible info for "..id)
		if GetCollectibleCategoryType(id) == COLLECTIBLE_CATEGORY_TYPE_MEMENTO then
			if unlk == false then
				SystemMessage("memento "..id.." ("..n..") ".." is locked")

			else
				useCollectibleItem(id, "error trying to use collectible "..id)
			end

		else
			SystemMessage(id.." ("..n..") ".." is NOT a MEMENTO ")
		end
	else
		SystemMessage("could not find collectible info for "..id)
	end
end

function SL.fence()
	useCollectibleItem(ASST.FENCE)
end

function SL.mead()
	useCollectibleItem(HOLS.BREDAS_MEAD_CUP,GetString(SLASHER_ITEM_MEADCUP))
end

function SL.cake(year)
		useCake(GetString(HOLS.SLASHER_ITEM_CAKE), year)
end

function SL.whistle()
	useCollectibleItem(HOLS.WITCHMOTHERS_WHISTLE,GetString(SLASHER_ITEM_WHISTLE))
end

function SL.pie()
	useCollectibleItem(HOLS.PIE_OF_MISRULE,GetString(SLASHER_ITEM_PIE))
end

function SL.mow()
	SetSetting( SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_CLUTTER_2D_QUALITY, CLUTTER_QUALITY_OFF )
end

function SL.grow()
	SetSetting( SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_CLUTTER_2D_QUALITY, CLUTTER_QUALITY_MEDIUM )
end

function SL.shutup( )
	SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED, "0")
	zo_callLater(function() SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED, "1") end, 300)
end

function SL.antiquarian_eye()
	useCollectibleItem(OTHR.ANTIQUARIAN_EYE,GetString(SLASHER_ITEM_EYE))
end


SL.evtmgr:registerEvt(EVENT_ADD_ON_LOADED, onAddonLoaded)



SLASH_COMMANDS["/rl"] = SL.reloadui
SLASH_COMMANDS["/home"] = SL.gohome

-- Group slash commands
SLASH_COMMANDS["/leave"] = SL.leaveGroup
SLASH_COMMANDS["/disband"] = SL.disbandGroup
SLASH_COMMANDS["/check"] = SL.readyCheck

-- Assistant slash commands
SLASH_COMMANDS["/b"] = function() SL.summon_banker(SL.saved.banker, SLASHER_SERVICE_BANKER) end
SLASH_COMMANDS["/f"] = function() SL.summon_fence(SL.saved.fence) end
SLASH_COMMANDS["/of"] = SLASH_COMMANDS["/f"]
SLASH_COMMANDS["/m"] = function() SL.summon_merchant(SL.saved.merchant, SLASHER_SERVICE_MERCHANT) end
SLASH_COMMANDS["/d"] = function() SL.summon_decon(SL.saved.decon, SLASHER_SERVICE_DECON) end

SLASH_COMMANDS["/pir"] = function() SL.summon_fence(ASST.PIR_FENCE) end
SLASH_COMMANDS["/cam"] = function() SL.summon_fence(ASST.CAM_FENCE) end

SLASH_COMMANDS["/om"] = function() SL.summon_merchant(ASST.MERCHANT) end
SLASH_COMMANDS["/km"] = function () SL.summon_merchant(ASST.ALFIQ_MERCHANT) end
SLASH_COMMANDS["/cm"] = function() SL.summon_merchant(ASST.CROW_MERCHANT) end
SLASH_COMMANDS["/ocm"] = function() SL.summon_merchant(ASST.CROW_MERCHANT) end
SLASH_COMMANDS["/clm"] = function() SL.summon_merchant(ASST.CLOCK_MERCHANT) end
SLASH_COMMANDS["/mm"] = function() SL.summon_merchant(ASST.MONST_MERCHANT) end
SLASH_COMMANDS["/hoa"] = function() SL.summon_merchant(ASST.MONST_MERCHANT) end
SLASH_COMMANDS["/ter"] = function() SL.summon_merchant(ASST.TERI_MERCHANT) end
SLASH_COMMANDS["/xyn"] = function() SL.summon_merchant(ASST.XYN_MERCHANT) end

SLASH_COMMANDS["/ob"] = function() SL.summon_banker(ASST.BANKER) end
SLASH_COMMANDS["/kb"] = function() SL.summon_banker(ASST.ALFIQ_BANKER) end
SLASH_COMMANDS["/cb"] = function () SL.summon_banker(ASST.CROW_BANKER) end
SLASH_COMMANDS["/clb"] = function() SL.summon_banker(ASST.CLOCK_BANKER) end
SLASH_COMMANDS["/mb"] = function() SL.summon_banker(ASST.MONST_BANKER) end
SLASH_COMMANDS["/eri"] = function() SL.summon_banker(ASST.ERI_BANKER) end
SLASH_COMMANDS["/cel"] = function() SL.summon_banker(ASST.CEL_BANKER) end


SLASH_COMMANDS["/arm"] = function() SL.summon_armorer(SL.saved.armorer, SLASHER_SERVICE_ARMORER) end

SLASH_COMMANDS["/ghrasharog"] = function() SL.summon_armorer(ASST.GHRASHROG) end
SLASH_COMMANDS["/ghr"] = SLASH_COMMANDS["/ghrasharog"]
--SLASH_COMMANDS["/arm"] = SLASH_COMMANDS["/ghrasharog"]
SLASH_COMMANDS["/dri"] = function() SL.summon_armorer(ASST.DRINWETH) end
SLASH_COMMANDS["/zuqoth"] = function() SL.summon_armorer(ASST.ZUQOTH) end
SLASH_COMMANDS["/aadv"] = SLASH_COMMANDS["/zuqoth"]
SLASH_COMMANDS["/zuq"] = SLASH_COMMANDS["/zuqoth"]
SLASH_COMMANDS["/voko"] = function() SL.summon_armorer(ASST.VOKO) end
SLASH_COMMANDS["/vok"] = SLASH_COMMANDS["/voko"]


SLASH_COMMANDS["/giladil"] = function() SL.summon_decon(ASST.DECON) end
SLASH_COMMANDS["/gil"] = SLASH_COMMANDS["/giladil"]
SLASH_COMMANDS["/rd"] = SLASH_COMMANDS["/giladil"]
SLASH_COMMANDS["/aderene"] = function() SL.summon_decon(ASST.FARG_DECON) end
SLASH_COMMANDS["/adr"] = SLASH_COMMANDS["/aderene"]
SLASH_COMMANDS["/fd"] = SLASH_COMMANDS["/aderene"]
SLASH_COMMANDS["/tzo"] = function() SL.summon_decon(ASST.TZOZ_DECON) end
SLASH_COMMANDS["/sil"] = function() SL.summon_decon(ASST.SIL_DECON) end
SLASH_COMMANDS["/por"] = function() SL.summon_decon(ASST.POR_DECON) end



-- Companion slash commands
SLASH_COMMANDS["/bastian"] = function() useCollectibleItem(ASST.BASTIAN) end
SLASH_COMMANDS["/bas"] = SLASH_COMMANDS["/bastian"]
SLASH_COMMANDS["/mirri"] = function() useCollectibleItem(ASST.MIRRI) end
SLASH_COMMANDS["/mir"] = SLASH_COMMANDS["/mirri"]
SLASH_COMMANDS["/ember"] = function() useCollectibleItem(ASST.EMBER) end
SLASH_COMMANDS["/emb"] = SLASH_COMMANDS["/ember"]
SLASH_COMMANDS["/isobel"] = function() useCollectibleItem(ASST.ISOBEL) end
SLASH_COMMANDS["/iso"] = SLASH_COMMANDS["/isobel"]
SLASH_COMMANDS["/sharp"] = function() useCollectibleItem(ASST.SHARP) end
SLASH_COMMANDS["/sha"] = SLASH_COMMANDS["/sharp"]
SLASH_COMMANDS["/azandar"] = function() useCollectibleItem(ASST.AZANDAR) end
SLASH_COMMANDS["/aza"] = SLASH_COMMANDS["/azandar"]
SLASH_COMMANDS["/tanlorin"] = function() useCollectibleItem(ASST.TANLORIN) end
SLASH_COMMANDS["/tan"] = SLASH_COMMANDS["/tanlorin"]
SLASH_COMMANDS["/zerith-var"] = function() useCollectibleItem(ASST.ZERITH) end
SLASH_COMMANDS["/zer"] = SLASH_COMMANDS["/zerith-var"]

-- Holiday slash commands
SLASH_COMMANDS["/mead"] = SL.mead
SLASH_COMMANDS["/jcake"] = function(year)
	if year == "" then year = nil end
	SL.cake(year)
end
SLASH_COMMANDS["/cake"] = function(year)
	if year == "" then year = nil end
	SL.cake(year)
end
SLASH_COMMANDS["/witch"] = SL.whistle
SLASH_COMMANDS["/pie"] = SL.pie

-- Grass commands
SLASH_COMMANDS["/mow"] = SL.mow
SLASH_COMMANDS["/grow"] = SL.grow
SLASH_COMMANDS["/grass"] = SL.togglegrass

-- Other commands
SLASH_COMMANDS["/shutup"] = SL.shutup
SLASH_COMMANDS["/nosky"] = SL.shutoffZOSSkyshards
SLASH_COMMANDS["/eye"] = SL.antiquarian_eye
SLASH_COMMANDS["/mem"] = SL.use_memento

-- Familiars and combat pets
SLASH_COMMANDS["/dismisspet"] = SL.dismissPets
SLASH_COMMANDS["/pet"] = SL.dismissPets
SLASH_COMMANDS["/pets"] = SL.dismissPets

-- developer slash commands

SLASH_COMMANDS["/run"] = function(...)
    SLASH_COMMANDS["/script"](...)
end

SLASH_COMMANDS["/apiversion"] = function(...)
	SystemMessage("ESO API version #"..tostring(GetAPIVersion()))
end

SLASH_COMMANDS["/sho"] = function(objectToOutput)
    SystemMessage(objectToOutput)
end


SLASH_COMMANDS["/collectibles"] = function(...)
    local n
    local start = select(1,...)
	if not start then 
		SystemMessage("/collectibles requires a start number as parameter")
		return
	end

	for k = start, start+1000 do
        n = GetCollectibleInfo(k)
        if n then
            SystemMessage(k..". "..n)
        end
    end
end

SLASH_COMMANDS["/getassistant"] = function(...)
    local n
    local start = 1
    for k = start, start+25000 do
        n = GetCollectibleInfo(k)
        if n then
			if GetCollectibleCategoryType(k) == COLLECTIBLE_CATEGORY_TYPE_ASSISTANT then
				SystemMessage(k..". "..n)
			end
        end
    end
end

SLASH_COMMANDS["/getcompanion"] = function(...)
    local n
    local start = 1
    for k = start, start+20000 do
        n = GetCollectibleInfo(k)
        if n then
			if GetCollectibleCategoryType(k) == COLLECTIBLE_CATEGORY_TYPE_COMPANION then
				SystemMessage(k..". "..n)
			end
        end
    end
end

SLASH_COMMANDS["/getstyle"] = function(...)
    local n
    local start = 1
    for k = start, start+20000 do
        n = GetCollectibleInfo(k)
        if n then
			if GetCollectibleCategoryType(k) == COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE then
				SystemMessage(k..". "..n)
			end
        end
    end
end


SLASH_COMMANDS["/getmemento"] = function(...)
    local n
    local start = 1
    for k = start, start+20000 do
        n = GetCollectibleInfo(k)
        if n then
			if GetCollectibleCategoryType(k) == COLLECTIBLE_CATEGORY_TYPE_MEMENTO then
				SystemMessage(k..". "..n)
			end
        end
    end
end


SLASH_COMMANDS["/dev1"] = function(...)
	local totCatByType = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_COMPANION) 
    for index = 1, totCatByType do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_COMPANION, index)
        SystemMessage(collectibleId)
    end
end

SLASH_COMMANDS["/what"] = function(...)
	for k,v in pairs(SLASH_COMMANDS) do
		SystemMessage(tostring(k))
		SystemMessage(tostring(v))
	end
end

SLASH_COMMANDS["/buffs"] = function(...)
	local i, k, v

	-- Walk through the player's active buffs
	SystemMessage("Number of buffs: "..GetNumBuffs("player"))
	for i = 1, GetNumBuffs("player") do
		local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff = GetUnitBuffInfo("player", i)
		SystemMessage( buffName .."  id: ".. abilityId .. "  type: "..abilityType)
		if canClickOff == true then
			SystemMessage(buffSlot.."/stk ".. stackCount.."/ic ".. iconFilename.."/bt ".. buffType.."/et ".. effectType.."/set ".. statusEffectType.."/".. SF.bool2str(canClickOff))
		end
	end
end