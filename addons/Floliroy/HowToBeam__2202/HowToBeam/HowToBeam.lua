-----------------
---- Globals ----
-----------------
HowToBeam = HowToBeam or {}
local HowToBeam = HowToBeam

HowToBeam.name = "HowToBeam"
HowToBeam.version = "2.5.1"

local cpt = 0
local lastHP = {}
local currentDPS
local targetName

local sV

HowToBeam.DotsUsed = {}
HowToBeam.fireStaff = 0
HowToBeam.shockStaff = 0
HowToBeam.spammableOffset = -0.035

---------------------------
---- Variables Default ----
---------------------------
HowToBeam.Default = {
	OffsetX = 800,
	OffsetY = 300,
	Enable = true,
	Glyph = 1,
	showWhatToDrop = false,
	maxTargetHPchoose = 3,
	SpammableAlert = "Start Use Beam",
	DoTAlert = "Only Spear + Blockade",
	FinishAlert = "Beam Them to Death",
	ColorRGB = {1, 0.12, 0.02, 1},
}
local infusedGlyph, usingMA

---------------
-- FUNCTIONS --
---------------
local damageBonus, fireBonus, spellDamage, currentMagicka, maxMagicka, effMaxMagicka
local lightAttackTotal
function HowToBeam.UnpackDatas(skillName)
	if HowToBeam.Datas[skillName] then
		local skill = HowToBeam.Datas[skillName]
		local totalDmg = lightAttackTotal

		for i = 1, #skill.bonus do
			local bonus = damageBonus
			local bonusSpellDmg = 0
			if skill.bonus[i].empower then
				bonus = 0
			else
				if skill.bonus[i].fireBonus then
					bonus = bonus + fireBonus
				end
				if skill.bonus[i].singleTarget then
					bonus = bonus + (0.08 * HowToBeam.fireStaff)
					bonus = bonus + HowToBeam.DeadlyAim
				elseif skill.bonus[i].singleTarget ~= nil and skill.bonus[i].singleTarget == false then
					bonus = bonus + (0.08 * HowToBeam.shockStaff)
					bonus = bonus + HowToBeam.BitingAura
				end
				if skill.bonus[i].directDmg then
					bonus = bonus + HowToBeam.MasterArms
				elseif skill.bonus[i].directDmg ~= nil and skill.bonus[i].directDmg == false then
					bonus = bonus + HowToBeam.Thaumaturge
				end
				if skill.bonus[i].magicDmg then
					bonusSpellDmg = HowToBeam.WarMage
				end
			end

			local dmg = (skill.factor[i].magicka * maxMagicka + skill.factor[i].spellDamage * (spellDamage + bonusSpellDmg) + skill.factor[i].additional) * skill.factor[i].multiplier * (1 + bonus)
			totalDmg = totalDmg + dmg
		end

		return totalDmg / skill.castTime
	else
		d("HowToBeam Missing Datas for: |cFF0000" .. skillName .. "|r" )
	end
end

function HowToBeam.GetThresholdPercentage(dmgToCompare, radiantDmg, skillName)
	local offset = 0
	if skillName == HowToBeam.SkillNames.STRING_PULSE_UNMORPHED or skillName == HowToBeam.SkillNames.STRING_CRUSHING_SHOCK or skillName == HowToBeam.SkillNames.STRING_FORCE_PULSE or	skillName == HowToBeam.SkillNames.STRING_ELEMENTAL_WEAPON or
	skillName == HowToBeam.SkillNames.STRING_SWEEP_UNMORPHED or skillName == HowToBeam.SkillNames.STRING_PUNCTURING_SWEEP or skillName == HowToBeam.SkillNames.STRING_FLARE_UNMORPHED or skillName == HowToBeam.SkillNames.STRING_DARK_FLARE then
		offset = HowToBeam.spammableOffset
	end
	return (1 - ((dmgToCompare * 1.8 - lightAttackTotal) / radiantDmg - 1) / 4.8) * 0.5 + offset
end

function GetLightAttackTotal(dmg, ma)
	local total = dmg
	if (usingMA == true) then
		total = total + ma
	end
	if (sV.Glyph == 1) then
		local fireGlyphBonus = damageBonus + fireBonus + 0.08 + HowToBeam.MasterArms
		local burningBonus = damageBonus + fireBonus + 0.08 + HowToBeam.Thaumaturge
		local fireGlyphDamage1
		if infusedGlyph then
			fireGlyphDamage1 = 3294 * 0.5 * (1 + fireGlyphBonus)
		else
			fireGlyphDamage1 = 2534 * 0.5 * (1 + fireGlyphBonus)
		end
		local fireGlyphDamage2 = (maxMagicka/10.5 + spellDamage) * 0.167947210695167 * 0.5 * 0.4 * 2.5 * (1 + burningBonus)
		total = total + fireGlyphDamage1 + fireGlyphDamage2
	elseif (sV.Glyph == 2) then
		local shockGlyphBonus = damageBonus + 0 + 0.08 + HowToBeam.MasterArms
		local concussionBonus = damageBonus + 0 + 0.08 + HowToBeam.Thaumaturge
		local shockGlyphDamage1
		if infusedGlyph then
			shockGlyphDamage1 = 3294 * 0.5 * (1 + shockGlyphBonus)
		else
			shockGlyphDamage1 = 2534 * 0.5 * (1 + shockGlyphBonus)
		end
		local shockGlyphDamage2 = (maxMagicka/10.5 + spellDamage) * 0.08743955967 * 0.5 * 0.4 * (1 + concussionBonus)
		total = total + shockGlyphDamage1 + shockGlyphDamage2
	elseif (sV.Glyph == 3) then
		local absorbGlyphBonus = damageBonus + 0.08 + HowToBeam.MasterArms
		local absorbGlyphDamage
		if infusedGlyph then
			absorbGlyphDamage = 2470 * 0.5 * (1 + absorbGlyphBonus)
		else
			absorbGlyphDamage = 1900 * 0.5 * (1 + absorbGlyphBonus)
		end
		total = total + absorbGlyphDamage
	end
	return total
end

function HowToBeam.GetDamageBonus()
	local MinBerserk = 0
	local MajBerserk = 0
	local MinSlayer = 0
	local MajSlayer	= 0
	for i=1,GetNumBuffs("player") do
		local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("player",i)			
		if(zo_strformat(SI_ABILITY_NAME,GetAbilityName(abilityId)) == zo_strformat(SI_ABILITY_NAME, GetAbilityName(62636))) then
			MinBerserk = 0.05
		end
		if(zo_strformat(SI_ABILITY_NAME,GetAbilityName(abilityId)) == zo_strformat(SI_ABILITY_NAME, GetAbilityName(62195))) then
			MajBerserk = 0.10
		end
		if(zo_strformat(SI_ABILITY_NAME,GetAbilityName(abilityId)) == zo_strformat(SI_ABILITY_NAME, GetAbilityName(98103))) then
			MinSlayer = 0.05
		end
		if(zo_strformat(SI_ABILITY_NAME,GetAbilityName(abilityId)) == zo_strformat(SI_ABILITY_NAME, GetAbilityName(93120))) then
			MajSlayer = 0.10
		end
	end

	local EngFlames	= 0	
	local Behemoth = 0		
	for i=1,GetNumBuffs("reticleover") do
		local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("reticleover",i)		
		if(zo_strformat(SI_ABILITY_NAME,GetAbilityName(abilityId)) == zo_strformat(SI_ABILITY_NAME, GetAbilityName(31104))) then
			EngFlames = 0.10
		end
		if(zo_strformat(SI_ABILITY_NAME,GetAbilityName(abilityId)) == zo_strformat(SI_ABILITY_NAME, GetAbilityName(151034))) then
			Behemoth = 0.05
		end		
	end

	return (MinBerserk + MajBerserk + MinSlayer + MajSlayer), (EngFlames + Behemoth)
end

function HowToBeam.Calcul()
	local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("reticleover", POWERTYPE_HEALTH)
	local bossPercentage = currentTargetHP / maxTargetHP
	local alertText

	if bossPercentage < 0.5 and maxTargetHP > sV.maxTargetHPchoose * 1000000 and currentTargetHP > 0 then
		damageBonus, fireBonus = HowToBeam.GetDamageBonus()
		----------------------
		---- Player Stats ----
		----------------------
		spellDamage = GetPlayerStat(STAT_SPELL_POWER)
		currentMagicka, maxMagicka, effMaxMagicka = GetUnitPower("player", POWERTYPE_MAGICKA)
		local actualMagicka = currentMagicka / maxMagicka

		----------------------------
		---- Skills Calculation ----
		----------------------------
		--bonuses
		local lightAttackBonus = damageBonus + ((0.08 + fireBonus) * HowToBeam.fireStaff) + HowToBeam.MasterArms + HowToBeam.DeadlyAim + HowToBeam.ArmsExpert
		local lightAttackMABonus = damageBonus + ((0.08 + fireBonus) * HowToBeam.fireStaff) + HowToBeam.MasterArms + HowToBeam.DeadlyAim

		local spearBonus1 = damageBonus + (0.08 * HowToBeam.shockStaff) + HowToBeam.MasterArms + HowToBeam.BitingAura --Inital Hit
		local spearBonus2 =	damageBonus + (0.08 * HowToBeam.shockStaff) + HowToBeam.Thaumaturge + HowToBeam.BitingAura --DoT
		local burningLightBonus = damageBonus + (0.08 * HowToBeam.fireStaff) + HowToBeam.MasterArms + HowToBeam.DeadlyAim --Passiv

		local radiantBonus = damageBonus + (0.08 * HowToBeam.fireStaff) + HowToBeam.Thaumaturge + HowToBeam.DeadlyAim

		--damages
		--Skills factor are found on uesp : http://esoitem.uesp.net/viewSkills.php
		local lightAttackDamage = (0.0450994 * maxMagicka + 0.47178 * (spellDamage + HowToBeam.WarMage) - 1.08238) * 1 * (1 + lightAttackBonus)
		local lightAttackMADamage = 1341 * (1 + lightAttackMABonus)

		local burningLightSpear = (0.0599264 * maxMagicka + 0.630855 * (spellDamage + HowToBeam.WarMage) - 1.93596) * 11 * (1 + burningLightBonus) / 4
		local spearDamage1 = (0.0961859 * maxMagicka + 1.00786 * (spellDamage + HowToBeam.WarMage) - 2.25832) * 1 * (1 + spearBonus1)
		local spearDamage2 = (0.0095795 * maxMagicka + 0.101259 * (spellDamage + HowToBeam.WarMage) - 2.29412) * 10 * (1 + spearBonus2)

		local radiantDamage = (0.116426 * maxMagicka + 1.22416 * (spellDamage + HowToBeam.WarMage) - 2.47368) * 1 * (1 + radiantBonus) * (1 + 0.2 * actualMagicka)

		--add the lightattack buff and glyphs
		lightAttackTotal = GetLightAttackTotal(lightAttackDamage, lightAttackMADamage)
		local spearTotal = (lightAttackTotal + spearDamage1 + spearDamage2 + burningLightSpear) / 1
		local spearPercentage = HowToBeam.GetThresholdPercentage(spearTotal, radiantDamage, "")
		--d("Lance Ardente: " .. tostring(string.format("%.3f", spearPercentage))*100 .. "%")

		-------------------------
		---- Boss Percentage ----
		-------------------------
		if targetName ~= GetUnitNameHighlightedByReticle("reticleover") then
			cpt = 0
			targetName = GetUnitNameHighlightedByReticle("reticleover")
		else
			lastHP[cpt] = currentTargetHP
			if cpt > 3*5 then
				currentDPS = lastHP[cpt - 3*5] - currentTargetHP
			end
		end
		cpt = cpt + 1

		local baseBossPercentage = bossPercentage
		if bossPercentage < 0.4 and currentDPS ~= nil then
			bossPercentage = (currentTargetHP - currentDPS) / maxTargetHP
		end

		---------------------------
		---- Skills Comparison ----
		---------------------------
		if bossPercentage > spearPercentage then
			local spammablePercentage		
			if HowToBeam.SpammableUsed ~= "null" then
				local spammableTotal = HowToBeam.UnpackDatas(HowToBeam.SpammableUsed)
				spammablePercentage = HowToBeam.GetThresholdPercentage(spammableTotal, radiantDamage, HowToBeam.SpammableUsed)
				--d(HowToBeam.SpammableUsed .. ": " .. tostring(string.format("%.3f", spammablePercentage))*100 .. "%")
			end

			local dotNumber = #HowToBeam.DotsUsed
			local skillsToDrop = {}
			if HowToBeam.SpammableUsed == "null" or baseBossPercentage < spammablePercentage then

				for i = 1, #HowToBeam.DotsUsed do
					local dotTotal = HowToBeam.UnpackDatas(HowToBeam.DotsUsed[i])
					local dotPercentage = HowToBeam.GetThresholdPercentage(dotTotal, radiantDamage, HowToBeam.DotsUsed[i])
					--d(HowToBeam.DotsUsed[i] .. ": " .. tostring(string.format("%.3f", dotPercentage))*100 .. "%")
					if bossPercentage < dotPercentage then
						dotNumber = dotNumber - 1
						table.insert(skillsToDrop, HowToBeam.DotsUsed[i])
					end
				end
			end

			if (spammablePercentage and baseBossPercentage < spammablePercentage) or dotNumber < #HowToBeam.DotsUsed then
				alertText = sV.SpammableAlert
				if sV.showWhatToDrop and HowToBeam.SpammableUsed ~= "null" then
					alertText = alertText .. "\nDrop: " .. HowToBeam.Datas[HowToBeam.SpammableUsed].icon
				end
				if sV.showWhatToDrop and HowToBeam.SpammableUsed ~= "null" and dotNumber >= #HowToBeam.DotsUsed - 2 and dotNumber ~= #HowToBeam.DotsUsed then
					alertText = alertText .. " & "
					for i = 1, #skillsToDrop do
						if i ~= #skillsToDrop then
							alertText = alertText .. HowToBeam.Datas[skillsToDrop[i]].icon .. " & "
						else
							alertText = alertText .. HowToBeam.Datas[skillsToDrop[i]].icon
						end
					end
				end
				if sV.showWhatToDrop and HowToBeam.SpammableUsed == "null" and dotNumber >= #HowToBeam.DotsUsed - 3 then
					alertText = alertText .. "\nDrop: "
					for i = 1, #skillsToDrop do
						if i ~= #skillsToDrop then
							alertText = alertText .. HowToBeam.Datas[skillsToDrop[i]].icon .. " & "
						else
							alertText = alertText .. HowToBeam.Datas[skillsToDrop[i]].icon
						end
					end
				end
				if bossPercentage < 0.20 or dotNumber <= 0 then
					alertText = sV.DoTAlert
				end
			end
		else
			alertText = sV.FinishAlert
		end
		HTBAlert_Label:SetText(alertText)
		HTBAlert:SetHidden(false)
	else
		HTBAlert:SetHidden(true)
	end
end

--------------
-- TRIGGERS --
--------------
local skills = {
	primaryBar = {},
	secondaryBar = {}
}
function HowToBeam.ChangeSkill(_, actionSlotIndex)
	if actionSlotIndex >= 3 and actionSlotIndex <= 7 then
		local activeHotbarCategory = GetActiveHotbarCategory()
		local skillName = zo_strformat(SI_ABILITY_NAME, GetSlotName(actionSlotIndex))

		if activeHotbarCategory == HOTBAR_CATEGORY_PRIMARY then
			if skills.primaryBar[actionSlotIndex - 2] ~= skillName then
				skills.primaryBar[actionSlotIndex - 2] = skillName
			end
		elseif activeHotbarCategory == HOTBAR_CATEGORY_BACKUP then
			if skills.secondaryBar[actionSlotIndex - 2] ~= skillName then
				skills.secondaryBar[actionSlotIndex - 2] = skillName
			end
		end

		HowToBeam.DotsUsed = {}
		for i = 1, 5 do
			if skills.primaryBar[i] == HowToBeam.SkillNames.STRING_SUN_FIRE or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_VAMPIRE_BANE or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_REFLECTIVE_LIGHT or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_SOLAR_BARRAGE or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_ENTROPY or
			skills.primaryBar[i] == HowToBeam.SkillNames.STRING_DEGENERATION or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_STRUCTURED_ENTROPY or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_SOUL_TRAP or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_SOUL_SPLIT_TRAP or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_CONSUMING_TRAP or
			skills.primaryBar[i] == HowToBeam.SkillNames.STRING_FLAME_REACH or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_FLAME_TOUCH or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_SHOCK_REACH or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_SHOCK_TOUCH or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_SCALDING_RUNE or
			skills.primaryBar[i] == HowToBeam.SkillNames.STRING_BACKLASH or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_PURIFYING_LIGHT or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_RITUAL_RETRIBUTION or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_NECROTIC_ORB or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_MYSTIC_ORB then
				table.insert(HowToBeam.DotsUsed, skills.primaryBar[i])
			end
			if skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_SUN_FIRE or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_VAMPIRE_BANE or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_REFLECTIVE_LIGHT or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_SOLAR_BARRAGE or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_ENTROPY or
			skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_DEGENERATION or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_STRUCTURED_ENTROPY or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_SOUL_TRAP or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_SOUL_SPLIT_TRAP or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_CONSUMING_TRAP or
			skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_FLAME_REACH or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_FLAME_TOUCH or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_SHOCK_REACH or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_SHOCK_TOUCH or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_SCALDING_RUNE or
			skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_BACKLASH or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_PURIFYING_LIGHT or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_RITUAL_RETRIBUTION or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_NECROTIC_ORB or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_MYSTIC_ORB then
				table.insert(HowToBeam.DotsUsed, skills.secondaryBar[i])
			end
		end

	end
end

--Update champion point damage coeff
function HowToBeam.ChangeChampionPoints(_, result)
	if result == CHAMPION_PURCHASE_SUCCESS then
		--Check which CP are slotted
		local slottableCps = {
			[25] = false,
			[27] = false,
			[264] = false,
			[23] = false
		}
		for i = 5, 8 do
			cpId = GetSlotBoundId(i, HOTBAR_CATEGORY_CHAMPION)
			if slottableCps[cpId] ~= nil and slottableCps[cpId] == false then
				slottableCps[cpId] = true
			end
		end

		--Check non slottable CPs
		local WarMage = GetNumPointsSpentOnChampionSkill(21)
		local ArmsExpert = GetNumPointsSpentOnChampionSkill(259)
		--Check slottable CPs
		local DeadlyAim = GetNumPointsSpentOnChampionSkill(25)
		if not slottableCps[25] then DeadlyAim = 0 end
		local Thaumaturge = GetNumPointsSpentOnChampionSkill(27)
		if not slottableCps[27] then Thaumaturge = 0 end
		local MasterArms = GetNumPointsSpentOnChampionSkill(264)
		if not slottableCps[264] then MasterArms = 0 end
		local BitingAura = GetNumPointsSpentOnChampionSkill(23)
		if not slottableCps[23] then BitingAura = 0 end

		--Save in global variables the coeff
		if WarMage >= 30 then
			HowToBeam.WarMage = 100
		end
		HowToBeam.ArmsExpert = math.floor(ArmsExpert / 10) * 0.03
		HowToBeam.DeadlyAim = math.floor(DeadlyAim / 10) * 0.02
		HowToBeam.Thaumaturge = math.floor(Thaumaturge / 10) * 0.02
		HowToBeam.MasterArms = math.floor(MasterArms / 10) * 0.02
		HowToBeam.BitingAura = math.floor(BitingAura / 10) * 0.02
	end
end

local function GetSpammableUsed(spammableList)
	for key, value in pairs(spammableList) do
		if value == HowToBeam.SkillNames.STRING_ELEMENTAL_WEAPON then
			return value
		end
	end
	for key, value in pairs(spammableList) do
		if value == HowToBeam.SkillNames.STRING_PULSE_UNMORPHED or value == HowToBeam.SkillNames.STRING_CRUSHING_SHOCK or value == HowToBeam.SkillNames.STRING_FORCE_PULSE then
			return value
		end
	end
	for key, value in pairs(spammableList) do
		if value == HowToBeam.SkillNames.STRING_PUNCTURING_SWEEP or value == HowToBeam.SkillNames.STRING_SWEEP_UNMORPHED then
			return value
		end
	end
	for key, value in pairs(spammableList) do
		if value == HowToBeam.SkillNames.STRING_DARK_FLARE or value == HowToBeam.SkillNames.STRING_FLARE_UNMORPHED then
			return value
		end
	end
end

function HowToBeam.CombatState(_, inCombat)
	if not sV.Enable then return end
	if inCombat then
		local containsBeam = false
		for i = 1, 5 do
			if skills.primaryBar[i] == zo_strformat(SI_ABILITY_NAME, GetAbilityName(63046)) or skills.secondaryBar[i] == zo_strformat(SI_ABILITY_NAME, GetAbilityName(63046)) then
				containsBeam = true
				break
			end
		end
		if not containsBeam then return end

		--trigger the functions
		--staff element
		HowToBeam.fireStaff = 0
		HowToBeam.shockStaff = 0

		--check weapon item
		if GetItemWeaponType(0,EQUIP_SLOT_MAIN_HAND) == WEAPONTYPE_FIRE_STAFF then
			HowToBeam.fireStaff = HowToBeam.fireStaff + 0.7 --60%
		elseif GetItemWeaponType(0,EQUIP_SLOT_MAIN_HAND) == WEAPONTYPE_LIGHTNING_STAFF then
			HowToBeam.shockStaff = HowToBeam.shockStaff + 0.7
		end
		if GetItemWeaponType(0,EQUIP_SLOT_BACKUP_MAIN) == WEAPONTYPE_FIRE_STAFF then
			HowToBeam.fireStaff = HowToBeam.fireStaff + 0.3 --40%
		elseif GetItemWeaponType(0,EQUIP_SLOT_BACKUP_MAIN) == WEAPONTYPE_LIGHTNING_STAFF then
			HowToBeam.shockStaff = HowToBeam.shockStaff + 0.3
		end

		--check maelstrom staff
		local _, _, _, _, _, setIdBack = GetItemLinkSetInfo(GetItemLink(0,EQUIP_SLOT_BACKUP_MAIN))
		local _, _, _, _, _, setIdFront = GetItemLinkSetInfo(GetItemLink(0,EQUIP_SLOT_MAIN_HAND))
		if setIdBack == 373 or setIdFront == 373 then
			usingMA = true
		else
			usingMA = false
		end

		--check weapon trait
		if GetItemTrait(0, EQUIP_SLOT_BACKUP_MAIN) == ITEM_TRAIT_TYPE_WEAPON_INFUSED then
			infusedGlyph = true
		else
			infusedGlyph = false
		end

		--skills relative
		local spammableList = {}
		local spammableCpt = 0
		for i = 1, 5 do
			if skills.primaryBar[i] == HowToBeam.SkillNames.STRING_PULSE_UNMORPHED or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_CRUSHING_SHOCK or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_FORCE_PULSE or	skills.primaryBar[i] == HowToBeam.SkillNames.STRING_ELEMENTAL_WEAPON or
			skills.primaryBar[i] == HowToBeam.SkillNames.STRING_SWEEP_UNMORPHED or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_PUNCTURING_SWEEP or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_FLARE_UNMORPHED or skills.primaryBar[i] == HowToBeam.SkillNames.STRING_DARK_FLARE then
				spammableCpt = spammableCpt + 1
				table.insert(spammableList, skills.primaryBar[i])
			end
			if skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_PULSE_UNMORPHED or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_CRUSHING_SHOCK or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_FORCE_PULSE or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_ELEMENTAL_WEAPON or
			skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_SWEEP_UNMORPHED or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_PUNCTURING_SWEEP or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_FLARE_UNMORPHED or skills.secondaryBar[i] == HowToBeam.SkillNames.STRING_DARK_FLARE then
				spammableCpt = spammableCpt + 1
				table.insert(spammableList, skills.secondaryBar[i])
			end
		end

		if spammableCpt > 1 then
			HowToBeam.SpammableUsed = GetSpammableUsed(spammableList)
		elseif spammableCpt > 0 then
			HowToBeam.SpammableUsed = spammableList[1]
		else
			HowToBeam.SpammableUsed = "null"
		end

		EVENT_MANAGER:RegisterForUpdate(HowToBeam.name, 333, HowToBeam.Calcul)
		EVENT_MANAGER:RegisterForEvent(HowToBeam.name, EVENT_RETICLE_TARGET_CHANGED, HowToBeam.Calcul)
	else
		--unregister all
		EVENT_MANAGER:UnregisterForUpdate(HowToBeam.name)
		EVENT_MANAGER:UnregisterForEvent(HowToBeam.name, EVENT_RETICLE_TARGET_CHANGED)
		HTBAlert:SetHidden(true)
	end
end

function HowToBeam.Debug()
	--check skills
	local cptSkills = 0
	for i = 1, 5 do
		if skills.primaryBar[i] == nil or skills.secondaryBar[i] == nil then
			cptSkills = cptSkills + 1
			if cptSkills >= 5 then
				d("|cffd708Do a bar switch to register for your other bar's abilities.|r")
				return
			end
		end
	end

	--bonus
	HowToBeam.fireStaff = 0
	HowToBeam.shockStaff = 0
	if GetItemWeaponType(0,EQUIP_SLOT_MAIN_HAND) == WEAPONTYPE_FIRE_STAFF then
		HowToBeam.fireStaff = HowToBeam.fireStaff + 0.7 --60%
	elseif GetItemWeaponType(0,EQUIP_SLOT_MAIN_HAND) == WEAPONTYPE_LIGHTNING_STAFF then
		HowToBeam.shockStaff = HowToBeam.shockStaff + 0.7
	end
	if GetItemWeaponType(0,EQUIP_SLOT_BACKUP_MAIN) == WEAPONTYPE_FIRE_STAFF then
		HowToBeam.fireStaff = HowToBeam.fireStaff + 0.3 --40%
	elseif GetItemWeaponType(0,EQUIP_SLOT_BACKUP_MAIN) == WEAPONTYPE_LIGHTNING_STAFF then
		HowToBeam.shockStaff = HowToBeam.shockStaff + 0.3
	end
	local _, _, _, _, _, setIdBack = GetItemLinkSetInfo(GetItemLink(0,EQUIP_SLOT_BACKUP_MAIN))
	local _, _, _, _, _, setIdFront = GetItemLinkSetInfo(GetItemLink(0,EQUIP_SLOT_MAIN_HAND))
	if setIdBack == 373 or setIdFront == 373 then
		usingMA = true
	else
		usingMA = false
	end
	if GetItemTrait(0, EQUIP_SLOT_BACKUP_MAIN) == ITEM_TRAIT_TYPE_WEAPON_INFUSED then
		infusedGlyph = true
	else
		infusedGlyph = false
	end
	damageBonus, fireBonus = HowToBeam.GetDamageBonus()
	spellDamage = GetPlayerStat(STAT_SPELL_POWER)
	currentMagicka, maxMagicka, effMaxMagicka = GetUnitPower("player", POWERTYPE_MAGICKA)

	--LA dmg
	local lightAttackBonus = damageBonus + ((0.08 + fireBonus) * HowToBeam.fireStaff) + HowToBeam.MasterArms + HowToBeam.ArmsExpert + HowToBeam.DeadlyAim
	local lightAttackMABonus = damageBonus + ((0.08 + fireBonus) * HowToBeam.fireStaff) + HowToBeam.MasterArms + HowToBeam.DeadlyAim
	local lightAttackDamage = (0.0450994 * maxMagicka + 0.47178 * (spellDamage + HowToBeam.WarMage) - 1.08238) * 1 * (1 + lightAttackBonus)
	local lightAttackMADamage = 1341 * (1 + lightAttackMABonus)
	lightAttackTotal = GetLightAttackTotal(lightAttackDamage, lightAttackMADamage)

	--radiant dmg
	local radiantBonus = damageBonus + (0.08 * HowToBeam.fireStaff) + HowToBeam.Thaumaturge + HowToBeam.DeadlyAim
	local actualMagicka = currentMagicka / maxMagicka
	local radiantDamage = (0.116426 * maxMagicka + 1.22416 * (spellDamage + HowToBeam.WarMage) - 2.47368) * 1 * (1 + radiantBonus) * (1 + 0.2 * actualMagicka)

	--all other skills
	for i = 1, 5 do
		if HowToBeam.Datas[skills.primaryBar[i]] then
			local total = HowToBeam.UnpackDatas(skills.primaryBar[i])
			local percent = HowToBeam.GetThresholdPercentage(total, radiantDamage, skills.primaryBar[i])
			percent = tostring(string.format("%.3f", percent)) * 100
			d("|cffd708" .. skills.primaryBar[i] .. "|r: " .. percent .. "%")
		end
		if HowToBeam.Datas[skills.secondaryBar[i]] then
			local total = HowToBeam.UnpackDatas(skills.secondaryBar[i])
			local percent = HowToBeam.GetThresholdPercentage(total, radiantDamage, skills.secondaryBar[i])
			percent = tostring(string.format("%.3f", percent)) * 100
			d("|cffd708" .. skills.secondaryBar[i] .. "|r: " .. percent .. "%")
		end
	end

end

----------
-- INIT --
----------
function HowToBeam:Initialize()
	--Saved Variables
	HowToBeam.savedVariables = ZO_SavedVars:New("HowToBeamVariables", 1, nil, HowToBeam.Default)
	sV = HowToBeam.savedVariables

	--Settings
	HowToBeam.CreateSettingsWindow()

	--UI
	HTBAlert:SetHidden(true)
	HTBAlert:ClearAnchors()
	HTBAlert:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX, sV.OffsetY)
	HTBAlert_Label:SetColor(unpack(sV.ColorRGB))

	--Events
	if GetUnitClassId("player") == 6 then
		HowToBeam.ChangeChampionPoints(nil, CHAMPION_PURCHASE_SUCCESS)
		local activeHotbarCategory = GetActiveHotbarCategory()
		for i = 1, 5 do
			if activeHotbarCategory == HOTBAR_CATEGORY_PRIMARY then
				skills.primaryBar[i] = zo_strformat(SI_ABILITY_NAME, GetSlotName(i + 2))
			elseif activeHotbarCategory == HOTBAR_CATEGORY_BACKUP then
				skills.secondaryBar[i] = zo_strformat(SI_ABILITY_NAME, GetSlotName(i + 2))
			end
		end
		EVENT_MANAGER:RegisterForEvent(HowToBeam.name, EVENT_ACTION_SLOT_STATE_UPDATED, HowToBeam.ChangeSkill)
		EVENT_MANAGER:RegisterForEvent(HowToBeam.name, EVENT_CHAMPION_PURCHASE_RESULT, HowToBeam.ChangeChampionPoints)
		EVENT_MANAGER:RegisterForEvent(HowToBeam.name, EVENT_PLAYER_COMBAT_STATE, HowToBeam.CombatState)
	end

	EVENT_MANAGER:UnregisterForEvent(HowToBeam.name, EVENT_ADD_ON_LOADED)
end

function HowToBeam.SaveLoc()
	sV.OffsetX = HTBAlert:GetLeft()
	sV.OffsetY = HTBAlert:GetTop()
end

function HowToBeam.OnAddOnLoaded(event, addonName)
	if addonName ~= HowToBeam.name then return end
		HowToBeam:Initialize()
end

EVENT_MANAGER:RegisterForEvent(HowToBeam.name, EVENT_ADD_ON_LOADED, HowToBeam.OnAddOnLoaded)