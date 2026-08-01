synergy = synergy or {}
local syn = synergy
local EM = GetEventManager()
local libDialog = LibDialog

syn.name = "Synergy"
syn.version = "1.19.3"

local isMagDD

local defaults = {
	["ExtremeBlocking"] = false,
	["portalDisable"] = false,
	["maSynDisable"] = false,
	["brpSynDisable"] = false,
	["trialsOnly"] = true,
	["frontBarOnly"] = false,
	["lokkeMode"] = false,
	["alkoshMode"] = false,
	["disableGraveRobber"] = false,
	["showSynergyAlert"] = true,
	["advancedLokkeMode"] = false,
}

syn.CustomAbilityName = {
	[75753] = GetAbilityName(75753),	-- Line-Breaker
}

local trialZones = {
	[635] = true, -- DSA
	[636] = true, -- HRC
	[638] = true, -- AA
	[639] = true, -- SO
	[975] = true, -- HOF
	[1000] = true, -- AS
	[1051] = true, -- CR
	[677] = true, -- MA
	[1082] = true, -- BRP
	[1121] = true, -- SS
}

local LOKKE = {
	[1] = "|H1:item:151137:363:50:0:0:0:0:0:0:0:0:0:0:0:1:86:0:1:0:10000:0|h|h",
	[2] = "|H1:item:149934:363:50:0:0:0:0:0:0:0:0:0:0:0:1:86:0:1:0:10000:0|h|h",
}

local ALKOSH = "|H1:item:73058:364:50:0:0:0:0:0:0:0:0:0:0:0:257:45:0:1:0:0:0|h|h"

local function GetFormattedAbilityName(id)
	local name = syn.CustomAbilityName[id] or zo_strformat(SI_ABILITY_NAME, GetAbilityName(id))
	return name
end

syn.alkosh = true
syn.allowOutbreak = false
syn.displayAlert = true

local function yesHandle()
	syn.allowOutbreak = true
end

local function noHandle()
	syn.displayAlert = true
end

local function buildDialog()
	libDialog:RegisterDialog(syn.name.."OutbreakDialog", "OutbreakConfirmation", GetString(SI_SYNERGY_ABILITY_DESTRUCTIVE_OUTBREAK), "Press Confirm to enable the synergy", yesHandle, noHandle)
end

local function showDialog()
	syn.displayAlert = false
	libDialog:ShowDialog(syn.name.."OutbreakDialog", "OutbreakConfirmation")
end

local function lokkeCheck()
	local np, p = 0
	_,_,_,p = GetItemLinkSetInfo(LOKKE[1], true)
	_,_,_,np = GetItemLinkSetInfo(LOKKE[2], true)
	if (np < 3) and (p < 3) then return false end
	if (np >= 3 and np < 5) or (p >= 3 and p < 5) then return true end
	if (np == 5) or (p == 5) then return false end
	return true
end

local function alkoshCheck()
	local a = 0
	_,_,_,a = GetItemLinkSetInfo(ALKOSH, true)
	if a < 3 then return false end
	if (a >= 3) and (a < 5) then return true end
	if (a == 5) then return false end
	return true
end

local function lokkeCheckEquipped() -- redundant but I'm lazy
	local npActive, pActive = 0
	_,_,_,pActive = GetItemLinkSetInfo(LOKKE[1], true)
	_,_,_,npActive = GetItemLinkSetInfo(LOKKE[2], true)
	if (npActive >= 3) or (pActive >= 3) then return true end
	return false
end

local function checkSlayerTime()
	local t = 0
	local numBuffs = GetNumBuffs("player")
	for i = 1, numBuffs do
		local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("player", i)
		if buffName == GetFormattedAbilityName(121871) then
			t = timeEnding - GetGameTimeSeconds()
			break
		end
	end
	return t < 5
end

function syn.alkoshActive()
	if DoesUnitExist("boss1") and not DoesUnitExist("boss2") and not syn.excludeBoss[GetUnitName("boss1")] then
		local numBuffs = GetNumBuffs("boss1")
		for i = 1, numBuffs do
			local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("boss1", i)
			if buffName == GetFormattedAbilityName(75753) then
				syn.alkosh = true
				return
			end
		end
		syn.alkosh = false
	else
		syn.alkosh = true
	end
end

local function checkLowStamina()
	local current, max, eMax = GetUnitPower("player", POWERTYPE_STAMINA)
	if current < (max/2) then return true end
	return false
end

local function blockForSlayer()
	if not lokkeCheckEquipped() then return false end
	if checkLowStamina() then return false end
	return not checkSlayerTime()
end

local function forceRefresh(e, didChange, shouldUpdate, category)
	if didChange then SYNERGY:OnSynergyAbilityChanged() end
end

function syn.SynergyOverride()

	local onSynAbChng = SYNERGY.OnSynergyAbilityChanged
	local gRobber = GetString(SI_SYNERGY_ABILITY_BONEYARD)
	local gate = GetString(SI_SYNERGY_ABILITY_GATEWAY)
	
	function SYNERGY:OnSynergyAbilityChanged()
		local n, texture = GetSynergyInfo()
		local bar = GetActiveHotbarCategory()
		local dd, h, t = GetGroupMemberRoles('player')
		if n then n = zo_strformat("<<1>>", n) end
		if n and syn.savedVariables.frontBarOnly and (lokkeCheck() or alkoshCheck()) and not syn.excludeSyn[n] and not syn.lokkeWL[n] then
			if syn.savedVariables.showSynergyAlert and not (syn.savedVariables.advancedLokkeMode and blockForSlayer()) and ((dd and not syn.dpsSynergyBL[n]) or (t and not syn.tankSynergyBL[n])) then
				syn.alertFrame:SetHidden(false)
				syn.alertIcon:SetTexture(texture)
				syn.alertText:SetText(zo_strformat("<<1>> Available", n))
			end
			SHARED_INFORMATION_AREA:SetHidden(self, true)
			return
		end
		if n and syn.savedVariables.advancedLokkeMode and blockForSlayer() and not syn.lokkeWL[n] and not syn.excludeSyn[n] then return end
		if n and syn.savedVariables.disableGraveRobber and n == gRobber then return end
		if n and syn.savedVariables.brpSynDisable and syn.blackrose[n] then return end
		if n and syn.savedVariables.maSynDisable and syn.maelstrom[n] then return end
		if n and syn.savedVariables.portalDisable and n == gate then return end
		if dd then
			--if n and isMagDD and syn.magDpsSynergyBL[n] then return end
			if n and syn.dpsSynergyBL[n] then return end
			if n and not syn.alkosh and not syn.excludeSyn[n] then return end
		elseif h then
			if n and syn.healSynergyBL[n] then return end
		elseif t then
			if n and syn.tankSynergyBL[n] then return end
		end

		if n and syn.alertSyn[n] and syn.displayAlert and not syn.allowOutbreak then
			showDialog()
		end
	
		if not n or (n and not syn.alertSyn[n]) then
			syn.allowOutbreak = false
			syn.displayAlert = true
		end
		if not n or bar == HOTBAR_CATEGORY_PRIMARY then syn.alertFrame:SetHidden(true) end
		onSynAbChng(self)
	end

end

function syn.combat(e, inCombat)
	if inCombat and syn.savedVariables.ExtremeBlocking then
		if syn.savedVariables.trialsOnly and not trialZones[GetZoneId(GetUnitZoneIndex("player"))] then return end
		EM:RegisterForUpdate(syn.name.."alkoshCheck", 50, syn.alkoshActive)
	else
		EM:UnregisterForUpdate(syn.name.."alkoshCheck")
	end
end

local function buildTables()
	-- Synergy blacklist for all DDs
	syn.dpsSynergyBL = {
		[GetString(SI_SYNERGY_ABILITY_CONDUIT)] = true,
		[GetString(SI_SYNERGY_ABILITY_HARVEST)] = true,
	}

	-- Synergy blacklist for mag DDs
	syn.magDpsSynergyBL = {
		[GetString(SI_SYNERGY_ABILITY_BLACK_WIDOWS)] = true,
	}

	-- Lokkestiiz Whitelist
	syn.lokkeWL = {
		[GetString(SI_SYNERGY_ABILITY_BLACK_WIDOWS)] = true,
		[GetString(SI_SYNERGY_ABILITY_CHARGED_LIGHTNING)] = true,
	}
	
	-- Synergy blacklist for tanks
	syn.tankSynergyBL = {
		[GetString(SI_SYNERGY_ABILITY_CHARGED_LIGHTNING)] = true,
		[GetString(SI_SYNERGY_ABILITY_IMPALE)] = true,
		[GetString(SI_SYNERGY_ABILITY_GRAVITY_CRUSH)] = true,
		[GetString(SI_SYNERGY_ABILITY_BLACK_WIDOWS)] = true,
	}
	
	-- Synergy blacklist for healers
	syn.healSynergyBL = {
		[GetString(SI_SYNERGY_ABILITY_CHARGED_LIGHTNING)] = true,
		[GetString(SI_SYNERGY_ABILITY_IMPALE)] = true,
		[GetString(SI_SYNERGY_ABILITY_GRAVITY_CRUSH)] = true,
		[GetString(SI_SYNERGY_ABILITY_CONDUIT)] = true,
		[GetString(SI_SYNERGY_ABILITY_BLACK_WIDOWS)] = true,
		[GetString(SI_SYNERGY_ABILITY_BONEYARD)] = true,
	}

	-- Blackrose sigils
	syn.blackrose = {
		[GetString(SI_SYNERGY_SIGIL_RESURRECTION)] = true,
		[GetString(SI_SYNERGY_SIGIL_DEFENSE)] = true,
		[GetString(SI_SYNERGY_SIGIL_HEALING)] = true,
		[GetString(SI_SYNERGY_SIGIL_SUSTAIN)] = true,
	}

	-- Maelstrom sigils
	syn.maelstrom = {
		[GetString(SI_SYNERGY_SIGIL_POWER)] = true,
		[GetString(SI_SYNERGY_SIGIL_DEFENSE)] = true,
		[GetString(SI_SYNERGY_SIGIL_HEALING)] = true,
		[GetString(SI_SYNERGY_SIGIL_HASTE)] = true,
	}
	
	-- Don't care about alkosh
	syn.excludeBoss = {
		[GetString(SI_SYNERGY_BOSS_THE_MAGE)] = true,
		[GetString(SI_SYNERGY_BOSS_YOKEDA_KAI)] = true,
		[GetString(SI_SYNERGY_BOSS_YOKEDA_ROKDUN)] = true,
		[GetString(SI_SYNERGY_BOSS_ASSEMBLY_GENERAL)] = true,
		[GetString(SI_SYNERGY_BOSS_YOLNAHKRIIN)] = true,
		[GetString(SI_SYNERGY_BOSS_LOKKESTIIZ)] = true,
		[GetString(SI_SYNERGY_BOSS_NAHVIINTAAS)] = true,
	}

	-- Can use regardless of alkosh
	syn.excludeSyn = {
		[GetString(SI_SYNERGY_ABILITY_SHED_HOARFROST)] = true,
		[GetString(SI_SYNERGY_ABILITY_CELESTIAL_PURGE)] = true,
		[GetString(SI_SYNERGY_ABILITY_POWER_SWITCH)] = true,
		[GetString(SI_SYNERGY_ABILITY_GATEWAY)] = true,
		[GetString(SI_SYNERGY_ABILITY_REMOVE_BOLT)] = true,
		[GetString(SI_SYNERGY_ABILITY_DESTRUCTIVE_OUTBREAK)] = true,
		[GetString(SI_SYNERGY_ABILITY_MALEVOLENT_CORE)] = true,
		[GetString(SI_SYNERGY_ABILITY_WIND_OF_THE_WELKYNAR)] = true,
		[GetString(SI_SYNERGY_ABILITY_WELKYNARS_LIGHT)] = true,
		[GetString(SI_SYNERGY_ABILITY_LEVITATE)] = true,
		[GetString(SI_SYNERGY_ABILITY_BLACK_WIDOWS)] = true,
		[GetString(SI_SYNERGY_ABILITY_TIME_BREACH)] = true,
	}

	-- Synergies to create alerts for
	syn.alertSyn = {
		[GetString(SI_SYNERGY_ABILITY_DESTRUCTIVE_OUTBREAK)] = true,
	}
end

function syn.init(event, addon)
	if addon ~= syn.name then return end
	EM:UnregisterForEvent(syn.name.."Load", EVENT_ADD_ON_LOADED)
	syn.savedVariables = ZO_SavedVars:New("SynergySavedVars", 1, nil, defaults, GetWorldName())
	local _, mag, _ = GetUnitPower('player', POWERTYPE_MAGICKA)
	local _, stam, _ = GetUnitPower('player', POWERTYPE_STAMINA)
	isMagDD = mag > stam
	buildTables()
	syn.buildMenu()
	buildDialog()
	syn.setupUI()
	syn.SynergyOverride()
	EM:RegisterForEvent(syn.name.."Combat", EVENT_PLAYER_COMBAT_STATE, syn.combat)
	EM:RegisterForEvent(syn.name.."SwapRefresh", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, forceRefresh)
end

EM:RegisterForEvent(syn.name.."Load", EVENT_ADD_ON_LOADED, syn.init)
