SynergyToggle = SynergyToggle or {}
local ST = SynergyToggle

ST.name = "SynergyToggle"
ST.version = "1.12.0"

ST.synergies = {}

ST.SYNERGYBLACKLIST = {
	["/esoui/art/icons/ability_nightblade_015.dds"] = true,
	["/esoui/art/icons/ability_dragonknight_006.dds"] = true,
	["/esoui/art/icons/ability_dragonknight_010.dds"] = true,
	["/esoui/art/icons/ability_necromancer_010_b.dds"] = true,
	["/esoui/art/icons/ability_necromancer_004.dds"] = true,
	["/esoui/art/icons/ability_sorcerer_lightning_splash.dds"] = true,
	["/esoui/art/icons/ability_sorcerer_storm_atronach.dds"] = true,
	["/esoui/art/icons/ability_warden_005_b.dds"] = true,
	["/esoui/art/icons/ability_warden_007.dds"] = true,
	["/esoui/art/icons/ability_templar_cleansing_ritual.dds"] = true,
	["/esoui/art/icons/ability_templar_solar_prison.dds"] = true,
	["/esoui/art/icons/ability_templar_nova.dds"] = true,
	["/esoui/art/icons/ability_templar_light_strike.dds"] = true,
	["/esoui/art/icons/ability_templar_sun_strike.dds"] = true,
	["/esoui/art/icons/ability_undaunted_005a.dds"] = true,
	["/esoui/art/icons/ability_undaunted_005.dds"] = true,
	["/esoui/art/icons/ability_undaunted_004b.dds"] = true,
	["/esoui/art/icons/ability_undaunted_004.dds"] = true,
	["/esoui/art/icons/crafting_light_armor_standard_f_005.dds"] = true,
	["/esoui/art/icons/ability_undaunted_003.dds"] = true,
	["/esoui/art/icons/ability_undaunted_002.dds"] = true,
	["/esoui/art/icons/ability_undaunted_001_a.dds"] = true,
	["/esoui/art/icons/ability_undaunted_001.dds"] = true,
	["/esoui/art/icons/ability_u23_bloodball_chokeonit.dds"] = true,
	["/esoui/art/icons/ability_arcanist_016_b.dds"] = true,
	["/esoui/art/icons/ability_arcanist_004.dds"] = true
}

ST.RESOURCESYNERGIES = {
	["/esoui/art/icons/ability_templar_sun_strike.dds"] = true,
	["/esoui/art/icons/ability_templar_light_strike.dds"] = true,
	["/esoui/art/icons/ability_undaunted_004.dds"] = true,
	["/esoui/art/icons/ability_undaunted_004b.dds"] = true,
}

ST.EFFECTS = {
	["ALKOSH"] = 75753,
	["PORTALDEBUFF"] = 104542,
	["MAJORSLAYER"] = 93109,
	["MAJORBERSERK"] = 61745,
	["BLOBDEBUFF"] = 152993,
	["SHADOWBLESSING"] = 75804,
}

ST.SETS = {
	["ALKOSH"] = "|H1:item:73058:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	["LOKKE"] = "|H1:item:149795:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	["BAHSEI"] = "|H1:item:173591:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	["PEARLS"] = "|H1:item:171437:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	["MOONDANCER"] = "|H1:item:73009:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	["CORALRIPTIDE"] = "|H1:item:186547:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	["MK"] = "|H1:item:95452:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
}

-- alkosh mode
ST.alkoshUnits = {}
ST.lastUnit = nil
ST.alkoshAvailable = 0

-- lokke mode
ST.hasMajorSlayer = false
ST.lokkeAvailable = 0

-- moondancer mode
ST.hasShadowBlessing = false
ST.moondancerAvailable = 0

-- kinra mode
ST.SORCATRO = "/esoui/art/icons/ability_sorcerer_storm_atronach.dds"
ST.hasMajorBerserk = false

-- bahseis and pearls mode
ST.bahseiAvailable = 0
ST.pearlsAvailable = 0

-- coral riptide and mk mode
ST.coralriptideAvailable = 0
ST.mkavailable = 0

-- hrc hm
ST.DESTRUCTIVEOUTBREAK = "/esoui/art/icons/ability_sorcerer_065.dds"
ST.outbreakCooldown = false

-- rg blobs
ST.PURGESOUL = "/esoui/art/icons/achievement_murkmire_kill_voriplasm.dds"
ST.blobBlock = false

-- dsr
ST.SURGINGWATERS = "/esoui/art/icons/death_recap_cold_aoe2.dds"
ST.surgingWatersCooldown = false


function ST.InitSavedVariables()
	local defaults = {
		general_purgeSoul = false,
		general_purgeSoul_cooldown = 2000,
		general_execration = true,
		general_conjurersPortal = false,
		general_cloudrestPortalDebuff = true,
		general_destructiveOutbreak = true,
		general_surgingWaters = false,
		general_arenaSigils = false,
		dd_conduit = false,
		dd_harvest = false,
		dd_grave = false,
		dd_agony = false,
		dd_shards = false,
		dd_ritual = false,
		dd_ladythorn = false,
		dd_runebreak = false,
		dd_bahseisMode = false,
		dd_bahseisMode_magicka = 20,
		dd_kinrasMode = false,
		dd_lokkestiizMode = false,
		dd_moondancerMode = false,
		dd_martialknowledgemode = false,
		dd_coralriptideMode = false,
		dd_coralriptideMode_stamina = 30,
		tank_atronarch = false,
		tank_alkoshMode = false,
		tank_nbshadowult = false,
		healer_cloudrestPortalEntirely = false,
		misc_wardenPortal = false,
		misc_passage = false,
		misc_vampirebite = false,
		misc_bladeofwoe = false,
		debug = false,
	}
	ST.savedVariables = ZO_SavedVars:NewCharacterIdSettings("STSV", 1, nil, defaults)
end

function ST.CreateAnnouncement()
	local announcement = WINDOW_MANAGER:CreateTopLevelWindow("SynergyToggleAnnouncement")
	announcement:SetDimensions(600, 200)
	announcement:SetAnchor(CENTER, GUI_ROOT, CENTER, 0, -200)
	announcement:SetHidden(true)
	announcement:SetClampedToScreen(true)
	announcement:SetMouseEnabled(false)
	announcement:SetMovable(false)
	
	local label = WINDOW_MANAGER:CreateControl(announcement:GetName() .. "Label", announcement, CT_LABEL)
	label:SetAnchor(CENTER, announcement, CENTER, 0, 0)
	label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	label:SetHorizontalAlignment(TEXT_ALIGN_CENTER) 
	label:SetFont("esoui/common/fonts/univers67.otf|60|soft-shadow-thick")
	label:SetText("|c00FF00BLOB SYNERGY|r")
end

function ST.UpdateAlkosh()
	for boss, uptime in pairs(ST.alkoshUnits) do
		if uptime > 0 then
			ST.alkoshUnits[boss] = uptime - 1
		else
			ST.alkoshUnits[boss] = nil
		end
	end
	ST.OnReticleTargetChanged(_)
end

function ST.OnReticleTargetChanged(_)
	local reticleTargetName = GetUnitNameHighlightedByReticle()
	if reticleTargetName and reticleTargetName ~= '' then
		local unitDifficulty = GetUnitDifficulty("reticleover")
		if not IsUnitPlayer("reticleover") and unitDifficulty == MONSTER_DIFFICULTY_DEADLY then
			local alkoshDuration = ST.GetAlkoshDuration("reticleover")
			ST.alkoshUnits[reticleTargetName] = alkoshDuration
			ST.lastUnit = reticleTargetName
		end
	end
end

function ST.GetAlkoshDuration(targetUnit)
	for i = 1, GetNumBuffs(targetUnit) do
		local _, _, timeEnding, _, _, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(targetUnit, i)
		if abilityId == ST.EFFECTS.ALKOSH then
			local duration = (timeEnding - GetGameTimeSeconds())
			return math.floor(duration)
		end
	end
	return 0
end

function ST.HasTargetAlkosh()
	if ST.alkoshUnits[ST.lastUnit] then
		local duration = ST.alkoshUnits[ST.lastUnit]
		return (duration > 2)
	end
	return false
end

function ST.HasLowStamina(percent)
	local currentStamina, maxStamina = GetUnitPower("player", POWERTYPE_STAMINA)
	local threshold = (maxStamina * percent / 100)
	if currentStamina < threshold then
		return true
	end
	return false
end

function ST.HasLowMagicka(percent)
	local currentMagicka, maxMagicka = GetUnitPower("player", POWERTYPE_MAGICKA)
	local threshold = (maxMagicka * percent / 100)
	if currentMagicka < threshold then
		return true
	end
	return false
end

function ST.CheckSet(setItem)
	local _, _, _, numNormalEquipped, _, _, numPerfectedEquipped = GetItemLinkSetInfo(setItem, true)
	return numNormalEquipped + numPerfectedEquipped
end

function ST.OnWeaponSwap(_, didChange, _, _)
	if didChange then
		ST.alkoshAvailable = ST.CheckSet(ST.SETS.ALKOSH)
		ST.lokkeAvailable = ST.CheckSet(ST.SETS.LOKKE)
		ST.bahseiAvailable = ST.CheckSet(ST.SETS.BAHSEI)
		ST.pearlsAvailable = ST.CheckSet(ST.SETS.PEARLS)
		ST.moondancerAvailable = ST.CheckSet(ST.SETS.MOONDANCER)
		ST.coralriptideAvailable = ST.CheckSet(ST.SETS.CORALRIPTIDE)
		ST.mkavailable = ST.CheckSet(ST.SETS.MK)
		SYNERGY:OnSynergyAbilityChanged()
	end
end

function ST.OnEffectChanged(_, changeType, _, effectName, unitTag, beginTime, endTime, _, _, _, _, _, _, _, unitId, abilityId, sourceType)
	if ST.savedVariables.general_purgeSoul
		and abilityId == ST.EFFECTS.BLOBDEBUFF
		and changeType == EFFECT_RESULT_GAINED
		and ST.savedVariables.general_purgeSoul_cooldown > 0 then
		
		ST.blobBlock = true
		SynergyToggleAnnouncement:SetHidden(false)
		zo_callLater(function()
			ST.blobBlock = false
			SYNERGY:OnSynergyAbilityChanged()
			SynergyToggleAnnouncement:SetHidden(true)
		end, ST.savedVariables.general_purgeSoul_cooldown)
	end
	
	if ST.savedVariables.dd_lokkestiizMode and abilityId == ST.EFFECTS.MAJORSLAYER then
		local cooldown = endTime - beginTime
		if cooldown > 0 then
			ST.hasMajorSlayer = true
			zo_callLater(function()
				ST.hasMajorSlayer = false
			end, (cooldown * 1000) - 1000)
		end
	end
	
	if ST.savedVariables.dd_moondancerMode and abilityId == ST.EFFECTS.SHADOWBLESSING then
		local cooldown = endTime - beginTime
		if cooldown > 0 then
			ST.hasShadowBlessing = true
			zo_callLater(function()
				ST.hasShadowBlessing = false
			end, (cooldown * 1000) - 1000)
		end
	end
	
	-- no need to check set since it wont change anything
	if ST.savedVariables.dd_kinrasMode and abilityId == ST.EFFECTS.MAJORBERSERK then		
		if changeType == EFFECT_RESULT_GAINED then
			ST.hasMajorBerserk = true
			SYNERGY:OnSynergyAbilityChanged()
		elseif changeType == EFFECT_RESULT_FADED then
			ST.hasMajorBerserk = false
			SYNERGY:OnSynergyAbilityChanged()
		end
	end
	
	if not ST.savedVariables.healer_cloudrestPortalEntirely then	
		if ST.savedVariables.general_cloudrestPortalDebuff and abilityId == ST.EFFECTS.PORTALDEBUFF then
			local cooldown = endTime - beginTime
			if cooldown > 0 then
				ST.oldPortalState = ST.synergies["/esoui/art/icons/collectible_memento_pearlsummon.dds"]
				ST.synergies["/esoui/art/icons/collectible_memento_pearlsummon.dds"] = true
				zo_callLater(function()
					ST.synergies["/esoui/art/icons/collectible_memento_pearlsummon.dds"] = ST.oldPortalState
				end, cooldown * 1000)
			end
		end
	end
end

function ST.OnPlayerDeath(_)
	if not ST.savedVariables.healer_cloudrestPortalEntirely then
		if ST.savedVariables.general_cloudrestPortalDebuff then
			ST.synergies["/esoui/art/icons/collectible_memento_pearlsummon.dds"] = false
		end
	end
end

function ST.OnPlayerCombatChange(_, inCombat)
	if IsUnitDead("player") then return end
	
	if inCombat then
		if ST.savedVariables.general_conjurersPortal and ST.DoesBossExist("vrol", "boss1") then
			ST.synergies["/esoui/art/icons/malatar_agonizingbolts.dds"] = true
		else
			ST.synergies["/esoui/art/icons/malatar_agonizingbolts.dds"] = false
		end
	end
	
	if ST.savedVariables.tank_alkoshMode then
		if inCombat then
			EVENT_MANAGER:RegisterForUpdate(ST.name .. "AlkoshUpdateLoop", 1000, ST.UpdateAlkosh)
		else
			EVENT_MANAGER:UnregisterForUpdate(ST.name .. "AlkoshUpdateLoop")
		end
	end
end

function ST.DoesBossExist(name, unitTag)
	if DoesUnitExist(unitTag) then
		local lowerName = string.lower(GetUnitName(unitTag))
		if string.find(lowerName, name) then
			return true
		end
	end
	return false
end

function ST.InitSynergies()
	local settings = ST.savedVariables
	ST.synergies["/esoui/art/icons/ability_necromancer_016.dds"] = settings.general_execration
	ST.synergies["/esoui/art/icons/sigil_defense_001.dds"] = settings.general_arenaSigils
	ST.synergies["/esoui/art/icons/sigil_healing_001.dds"] = settings.general_arenaSigils
	ST.synergies["/esoui/art/icons/sigil_speed_001.dds"] = settings.general_arenaSigils
	ST.synergies["/esoui/art/icons/sigil_power_001.dds"] = settings.general_arenaSigils
	ST.synergies["/esoui/art/icons/ability_sorcerer_lightning_splash.dds"] = settings.dd_conduit
	ST.synergies["/esoui/art/icons/ability_warden_007.dds"] = settings.dd_harvest
	ST.synergies["/esoui/art/icons/ability_necromancer_004.dds"] = settings.dd_grave
	ST.synergies["/esoui/art/icons/ability_necromancer_010_b.dds"] = settings.dd_agony
	ST.synergies["/esoui/art/icons/ability_arcanist_016_b.dds"] = settings.misc_passage
	ST.synergies["/esoui/art/icons/ability_templar_sun_strike.dds"] = settings.dd_shards
	ST.synergies["/esoui/art/icons/ability_templar_cleansing_ritual.dds"] = settings.dd_ritual
	ST.synergies["/esoui/art/icons/ability_u23_bloodball_chokeonit.dds"] = settings.dd_ladythorn
	ST.synergies["/esoui/art/icons/ability_arcanist_004.dds"] = settings.dd_runebreak
	ST.synergies["/esoui/art/icons/ability_sorcerer_storm_atronach.dds"] = settings.tank_atronarch
	ST.synergies["/esoui/art/icons/ability_nightblade_015.dds"] = settings.tank_nbshadowult
	ST.synergies["/esoui/art/icons/collectible_memento_pearlsummon.dds"] = settings.healer_cloudrestPortalEntirely
	ST.synergies["/esoui/art/icons/ability_warden_005_b.dds"] = settings.misc_wardenPortal
	ST.synergies["/esoui/art/icons/ability_u26_vampire_synergy_feed.dds"] = settings.misc_vampirebite
	ST.synergies["/esoui/art/icons/achievement_darkbrotherhood_003.dds"] = settings.misc_bladeofwoe
	
	if settings.tank_alkoshMode then
		EVENT_MANAGER:RegisterForEvent(ST.name, EVENT_RETICLE_TARGET_CHANGED, ST.OnReticleTargetChanged)
	end
	
	ST.OnPlayerCombatChange(_, IsUnitInCombat("player"))
	
	ST.OnWeaponSwap(_, true, _, _)
	
	ST.CreateAnnouncement()
end

function ST.BlockSynergies()
	ZO_PreHook(SYNERGY, 'OnSynergyAbilityChanged', function(self)
		local name, icon = GetSynergyInfo()
		if name and icon then
			if ST.savedVariables.debug then
				local link = ZO_LinkHandler_CreateLink(zo_strformat("<<C:1>>", name), nil, "synergydisplay", name, icon);
				d("|cf05a4f" .. link .. "|r");
			end
			if ST.synergies[icon] then
				--d("Blocking '" .. name .. "'")
				SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
				return true
			end
			if ST.savedVariables.general_purgeSoul and icon == ST.PURGESOUL then
				if ST.blobBlock then
					SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
					return true
				end
			end
			if ST.savedVariables.dd_kinrasMode and icon == ST.SORCATRO and ST.hasMajorBerserk then
				SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
				return true
			end
			if ST.savedVariables.general_destructiveOutbreak and icon == ST.DESTRUCTIVEOUTBREAK then
				if not ST.outbreakCooldown then
					ST.outbreakCooldown = true
					zo_callLater(function()
						ST.outbreakCooldown = false
					end, 10000)
					ST.ShowDialog("DestructiveOutbreak",
						"|t35:35:/esoui/art/icons/ability_sorcerer_065.dds|t Destructive Outbreak",
						"Are you sure you want to break free?\nPlease look after your mates.",
						function()
							SYNERGY:OnSynergyAbilityChanged()
						end,
						function()
							SYNERGY:OnSynergyAbilityChanged()
						end)
					SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
					return true
				end
			end
			if ST.savedVariables.general_surgingWaters and icon == ST.SURGINGWATERS then
				if not ST.surgingWatersCooldown then
					ST.surgingWatersCooldown = true
					zo_callLater(function()
						ST.surgingWatersCooldown = false
					end, 10000)
					ST.ShowDialog("Surging Waters",
						"|t35:35:" .. ST.SURGINGWATERS .. "|t Surging Waters",
						"Are you sure you want to go up? You won't be able to come back.",
						function()
							SYNERGY:OnSynergyAbilityChanged()
						end,
						function()
							SYNERGY:OnSynergyAbilityChanged()
						end)
					SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
					return true
				end
			end
			if not ST.HasLowMagicka(ST.savedVariables.dd_bahseisMode_magicka)
				and ST.savedVariables.dd_bahseisMode
				and (ST.bahseiAvailable >= 5 or ST.pearlsAvailable == 1) then
				
				if ST.RESOURCESYNERGIES[icon] then
					SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
					return true
				end
			end
			if not ST.HasLowStamina(ST.savedVariables.dd_coralriptideMode_stamina)
				and ST.savedVariables.dd_coralriptideMode
				and ST.coralriptideAvailable >= 3 then
				
				if ST.RESOURCESYNERGIES[icon] then
					SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
					return true
				end
			end
			if not ST.HasLowStamina(30)
				and ST.savedVariables.dd_martialknowledgemode
				and ST.mkavailable >= 3 then
				
				if ST.RESOURCESYNERGIES[icon] then
					SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
					return true
				end
			end
			if not ST.HasLowStamina(20) then
				if ST.savedVariables.tank_alkoshMode and ST.alkoshAvailable >= 3 then
					if ST.HasTargetAlkosh() or ST.alkoshAvailable < 5 then
						if ST.SYNERGYBLACKLIST[icon] then
							SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
							return true
						end
					end
				end
				if ST.savedVariables.dd_lokkestiizMode and ST.lokkeAvailable > 0 then
					if ST.hasMajorSlayer or ST.lokkeAvailable < 5 then
						if ST.SYNERGYBLACKLIST[icon] then
							SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
							return true
						end
					end
				end
			end
			if ST.savedVariables.dd_moondancerMode and ST.moondancerAvailable > 0 then
				if ST.hasShadowBlessing or ST.moondancerAvailable < 5 then
					if ST.SYNERGYBLACKLIST[icon] then
						SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
						return true
					end
				end
			end
		end
	end)
end

function ST.OnAddOnLoaded(_, addonName)
	if addonName ~= ST.name then return end
	
	ST.InitSavedVariables()
	ST.InitAddonMenu()
	ST.InitSynergies()
	ST.BlockSynergies()
	
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, ST.HandleClickEvent)
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, ST.HandleClickEvent) 
	
	EVENT_MANAGER:RegisterForEvent(ST.name, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, ST.OnWeaponSwap)
	EVENT_MANAGER:RegisterForEvent(ST.name, EVENT_EFFECT_CHANGED, ST.OnEffectChanged)
	EVENT_MANAGER:AddFilterForEvent(ST.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
	EVENT_MANAGER:RegisterForEvent(ST.name, EVENT_PLAYER_COMBAT_STATE, ST.OnPlayerCombatChange)
	EVENT_MANAGER:RegisterForEvent(ST.name, EVENT_PLAYER_DEAD, ST.OnPlayerDeath)
end

function ST.HandleClickEvent(rawLink, mouseButton, linkText, linkStyle, linkType, name, icon)
	if linkType == "synergydisplay" then
		d("|cFFFFFF ===== Synergy ===== |r")
		d("|cFFFFFFName: " .. name .. "|r")
		d("|cFFFFFFIcon: " .. icon .. "|r")
		return true
	end
end

function ST.ShowDialog(name, dialogTitle, dialogText, confirmCallback, cancelCallback)
	local uniqueId = string.format("%s%s", "SynergyToggleDialog", name)
	ESO_Dialogs[uniqueId] = {
		canQueue = true,
		uniqueIdentifier = uniqueId,
		title = {text = dialogTitle},
		mainText = {text = dialogText},
		buttons = {
			[1] = {
				text = SI_DIALOG_CONFIRM,
				callback = function() if confirmCallback then confirmCallback() end end,
			},
			[2] = {
				text = SI_DIALOG_CANCEL,
				callback = function() if cancelCallback then cancelCallback() end end,
			},
		},
		setup = function() end,
	}
	ZO_Dialogs_ShowDialog(uniqueId, nil, {mainTextParams = {}})
end

EVENT_MANAGER:RegisterForEvent(ST.name, EVENT_ADD_ON_LOADED, ST.OnAddOnLoaded)