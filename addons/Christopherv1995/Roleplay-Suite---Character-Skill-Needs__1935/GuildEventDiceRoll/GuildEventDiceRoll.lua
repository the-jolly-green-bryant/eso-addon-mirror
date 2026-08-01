----------------------------------------------------------------------------------------------------------------------------
--Global Variables--
----------------------------------------------------------------------------------------------------------------------------

local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
local LMP = LibStub:GetLibrary("LibMediaProvider-1.0")
local savedVars
local lastTime = 0
local needUpdate = 0
local combatStart = 0
local combatEnd = 0
local stage1Hunger = false
local stage2Hunger = false
local stage3Hunger = false
local stage1Thirst = false
local stage2Thirst = false
local stage3Thirst = false
local stage1Hygine = false
local stage2Hygine = false
local stage3Hygine = false
local stage1Fatigue = false
local stage2Fatigue = false
local stage3Fatigue = false
local stage1Arousal = false
local stage2Arousal = false
local stage3Arousal = false
local characterWet = false
local inWater = false

----------------------------------------------------------------------------------------------------------------------------
--General Purpose Functions--
----------------------------------------------------------------------------------------------------------------------------

function Basic_Instructions()
	CHAT_SYSTEM:AddMessage('Skill System:')
	CHAT_SYSTEM:AddMessage("You can use the '/skills' command to display the commands to use that will show all your skills under that category and their current rank to use and of these skills simply type /'skill_name' (all lower case) and the addon will take care of the rest.")
	if savedVars.Need_System == true then 
		CHAT_SYSTEM:AddMessage('Needs System:')
		CHAT_SYSTEM:AddMessage("Needs will degrade over time and as they do they will effect your ability to make effective roles in order to restore needs you can use the following commands:")
		CHAT_SYSTEM:AddMessage('/ate_food')
		CHAT_SYSTEM:AddMessage('/drank_something')
		CHAT_SYSTEM:AddMessage('/rested')
		CHAT_SYSTEM:AddMessage('/bathed')
		CHAT_SYSTEM:AddMessage('/pleasured')
		CHAT_SYSTEM:AddMessage("This is done generally after or during role-play that would satisfy the related need")
		CHAT_SYSTEM:AddMessage("Long combat will also cause some of your needs to degrade as well as using some skills")
		
		CHAT_SYSTEM:AddMessage("after exiting from swimming you can use the '/dry_yourself' command to allow messages to play again")
		if savedVars.NSFW == true then
			CHAT_SYSTEM:AddMessage("Use can use also the '/tease_yourself' command to raise your arousal")
		end
	end
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

----------------------------------------------------------------------------------------------------------------------------
--Skill List Rank Rank Display Functions--
----------------------------------------------------------------------------------------------------------------------------

function available_skills()
	CHAT_SYSTEM:AddMessage('Use any of the following to list the related skills and their rank:')
	CHAT_SYSTEM:AddMessage('/attributes:')
	CHAT_SYSTEM:AddMessage('/weapons:')
	CHAT_SYSTEM:AddMessage('/magic:')
	CHAT_SYSTEM:AddMessage('/crafting:')
	CHAT_SYSTEM:AddMessage('/roleplay:')
	CHAT_SYSTEM:AddMessage('/languages:')
end

function available_attributes()
	CHAT_SYSTEM:AddMessage(tostring(GetUnitName("player")) .. ' attributes:' )
	CHAT_SYSTEM:AddMessage('Strength: ' .. statRank(savedVars.Strength))
	CHAT_SYSTEM:AddMessage('Constitution: ' .. statRank(savedVars.Constitution))
	CHAT_SYSTEM:AddMessage('Intelligence: ' .. statRank(savedVars.Intelligence))
	CHAT_SYSTEM:AddMessage('Wisdom: ' .. statRank(savedVars.Wisdom))
	CHAT_SYSTEM:AddMessage('Charisma: ' .. statRank(savedVars.Charisma))
end

function available_weapon_skills()
	CHAT_SYSTEM:AddMessage(tostring(GetUnitName("player")) .. ' weapon skills:' )
	CHAT_SYSTEM:AddMessage('Dual_wield: ' .. statRank(savedVars.Dual_wield))
	CHAT_SYSTEM:AddMessage('Sword and_shield: ' .. statRank(savedVars.Sword_and_shield))
	CHAT_SYSTEM:AddMessage('Bow: ' .. statRank(savedVars.Bow))
	CHAT_SYSTEM:AddMessage('Two-Handed Weapons: ' .. statRank(savedVars.Two_handeders))
	CHAT_SYSTEM:AddMessage('Destruction Staff: ' .. statRank(savedVars.Destro_staff))
	CHAT_SYSTEM:AddMessage('Healing Staff: ' .. statRank(savedVars.Healing_staff))
	CHAT_SYSTEM:AddMessage('Unarmed: ' .. statRank(savedVars.Unarmed))
	CHAT_SYSTEM:AddMessage('One Handed Weapons: ' .. statRank(savedVars.One_handeders))
end

function available_magic_skills()
	CHAT_SYSTEM:AddMessage(tostring(GetUnitName("player")) .. ' magic skills:' )
	CHAT_SYSTEM:AddMessage('Alteration: ' .. statRank(savedVars.Alteration))
	CHAT_SYSTEM:AddMessage('Conjuration: ' .. statRank(savedVars.Conjuration))
	CHAT_SYSTEM:AddMessage('Destruction: ' .. statRank(savedVars.Destruction))
	CHAT_SYSTEM:AddMessage('Illusion: ' .. statRank(savedVars.Illusion))
	CHAT_SYSTEM:AddMessage('Mysticism: ' .. statRank(savedVars.Mysticism))
	CHAT_SYSTEM:AddMessage('Restoration: ' .. statRank(savedVars.Restoration))
	CHAT_SYSTEM:AddMessage('Thaumaturgy: ' .. statRank(savedVars.Thaumaturgy))
	CHAT_SYSTEM:AddMessage('Blood: ' .. statRank(savedVars.Blood))
	CHAT_SYSTEM:AddMessage('Daedric: ' .. statRank(savedVars.Daedric_magic))
	CHAT_SYSTEM:AddMessage('Necromancy: ' .. statRank(savedVars.Necromancy))
end

function available_crafting_skills()
	CHAT_SYSTEM:AddMessage(tostring(GetUnitName("player")) .. ' crafting skills:' )
	CHAT_SYSTEM:AddMessage('Alchemy: ' .. statRank(savedVars.Alchemy))
	CHAT_SYSTEM:AddMessage('Blacksmithing: ' .. statRank(savedVars.Blacksmithing))
	CHAT_SYSTEM:AddMessage('Tailoring: ' .. statRank(savedVars.Tailoring))
	CHAT_SYSTEM:AddMessage('Enchanting: ' .. statRank(savedVars.Enchanting))
	CHAT_SYSTEM:AddMessage('Provisioning: ' .. statRank(savedVars.Provisioning))
	CHAT_SYSTEM:AddMessage('Woodworking: ' .. statRank(savedVars.Woodworking))
end

function available_roleplay_skills()
	CHAT_SYSTEM:AddMessage(tostring(GetUnitName("player")) .. ' roleplay skills:' )
	CHAT_SYSTEM:AddMessage('Appraise: ' .. statRank(savedVars.Appraise))
	CHAT_SYSTEM:AddMessage('Balance: ' .. statRank(savedVars.Balance))
	CHAT_SYSTEM:AddMessage('Bluff: ' .. statRank(savedVars.Bluff))
	CHAT_SYSTEM:AddMessage('Concentration: ' .. statRank(savedVars.Concentration))
	CHAT_SYSTEM:AddMessage('Diplomacy: ' .. statRank(savedVars.Diplomancy))
	CHAT_SYSTEM:AddMessage('Disable Traps: ' .. statRank(savedVars.Disable_traps))
	CHAT_SYSTEM:AddMessage('Disguise: ' .. statRank(savedVars.Disguise))
	CHAT_SYSTEM:AddMessage('Escape Artist: ' .. statRank(savedVars.Escape_artist))
	CHAT_SYSTEM:AddMessage('Forgery: ' .. statRank(savedVars.Forgery))
	CHAT_SYSTEM:AddMessage('Gather Information: ' .. statRank(savedVars.Gather_info))
	CHAT_SYSTEM:AddMessage('Handle Animals: ' .. statRank(savedVars.Handle_animals))
	CHAT_SYSTEM:AddMessage('First Aid: ' .. statRank(savedVars.First_aid))
	CHAT_SYSTEM:AddMessage('Stealth: ' .. statRank(savedVars.Stealth))
	CHAT_SYSTEM:AddMessage('Intimidate: ' .. statRank(savedVars.Intimidate))
	CHAT_SYSTEM:AddMessage('Perception: ' .. statRank(savedVars.Perception))
	CHAT_SYSTEM:AddMessage('Perform: ' .. statRank(savedVars.Perform))
	CHAT_SYSTEM:AddMessage('Profession: ' .. statRank(savedVars.Profession))
	CHAT_SYSTEM:AddMessage('Ride: ' .. statRank(savedVars.Ride))
	CHAT_SYSTEM:AddMessage('Search: ' .. statRank(savedVars.Search))
	CHAT_SYSTEM:AddMessage('Sense Motive: ' .. statRank(savedVars.Sense_motive))
	CHAT_SYSTEM:AddMessage('Sleight Of Hand: ' .. statRank(savedVars.Sleight_of_hand))
	CHAT_SYSTEM:AddMessage('Spell Research: ' .. statRank(savedVars.Spell_research))
	CHAT_SYSTEM:AddMessage('Survival: ' .. statRank(savedVars.Survival))
	CHAT_SYSTEM:AddMessage('Swim: ' .. statRank(savedVars.Swim))
	CHAT_SYSTEM:AddMessage('Athletics: ' .. statRank(savedVars.Athletics))
	CHAT_SYSTEM:AddMessage('Acrobatics: ' .. statRank(savedVars.Acrobatics))
	CHAT_SYSTEM:AddMessage('Use Device: ' .. statRank(savedVars.Use_devise))
	CHAT_SYSTEM:AddMessage('Use Rope: ' .. statRank(savedVars.Use_rope))
end

function available_language_skills()
	CHAT_SYSTEM:AddMessage(tostring(GetUnitName("player")) .. ' language skills:' )
	CHAT_SYSTEM:AddMessage('Akaviri: ' .. statRank(savedVars.Akaviri))
	CHAT_SYSTEM:AddMessage('Aldmeris: ' .. statRank(savedVars.Aldmeris))
	CHAT_SYSTEM:AddMessage('Ayleidoon: ' .. statRank(savedVars.Ayleidoon))
	CHAT_SYSTEM:AddMessage('Bosmeris: ' .. statRank(savedVars.Bosmeris))
	CHAT_SYSTEM:AddMessage('Daedric: ' .. statRank(savedVars.Daedric))
	CHAT_SYSTEM:AddMessage('Draconic: ' .. statRank(savedVars.Draconic))
	CHAT_SYSTEM:AddMessage('Dummeris: ' .. statRank(savedVars.Dummeris))
	CHAT_SYSTEM:AddMessage('Dwemeris: ' .. statRank(savedVars.Dwemeris))
	CHAT_SYSTEM:AddMessage('Ehlnofex: ' .. statRank(savedVars.Ehlnofex))
	CHAT_SYSTEM:AddMessage('Falmer: ' .. statRank(savedVars.Falmer))
	CHAT_SYSTEM:AddMessage('Giantish: ' .. statRank(savedVars.Giantish))
	CHAT_SYSTEM:AddMessage('Goblin: ' .. statRank(savedVars.Goblin))
	CHAT_SYSTEM:AddMessage('Harpy: ' .. statRank(savedVars.Harpy))
	CHAT_SYSTEM:AddMessage('Imperial: ' .. statRank(savedVars.Imperial))
	CHAT_SYSTEM:AddMessage('Impish: ' .. statRank(savedVars.Impish))
	CHAT_SYSTEM:AddMessage('Jel: ' .. statRank(savedVars.Jel))
	CHAT_SYSTEM:AddMessage('Kothringi: ' .. statRank(savedVars.Kothringi))
	CHAT_SYSTEM:AddMessage('Lamia: ' .. statRank(savedVars.Lamia))
	CHAT_SYSTEM:AddMessage('Nedic: ' .. statRank(savedVars.Nedic))
	CHAT_SYSTEM:AddMessage('Nordish: ' .. statRank(savedVars.Nordish))
	CHAT_SYSTEM:AddMessage('Old_bretic: ' .. statRank(savedVars.Old_bretic))
	CHAT_SYSTEM:AddMessage('Orchish: ' .. statRank(savedVars.Orchish))
	CHAT_SYSTEM:AddMessage('Sload: ' .. statRank(savedVars.Sload))
	CHAT_SYSTEM:AddMessage('Taagra: ' .. statRank(savedVars.Taagra))
	CHAT_SYSTEM:AddMessage('Tamrielic: ' .. statRank(savedVars.Tamrielic))
	CHAT_SYSTEM:AddMessage('Tsaesci: ' .. statRank(savedVars.Tsaesci))
	CHAT_SYSTEM:AddMessage('Umbrielic: ' .. statRank(savedVars.Umbrielic))
	CHAT_SYSTEM:AddMessage('Yokudan: ' .. statRank(savedVars.Yokudan))
end

----------------------------------------------------------------------------------------------------------------------------
--Needs Functions--
----------------------------------------------------------------------------------------------------------------------------

function Needs()
	if savedVars.Hunger < 40 then
		CHAT_SYSTEM:AddMessage("I feel full and don't need to eat")
	elseif savedVars.Hunger >= 40 and savedVars.Hunger < 60 then
		CHAT_SYSTEM:AddMessage("I'm starting to feel hungry I should eat soon")
	elseif savedVars.Hunger >= 60 and savedVars.Hunger < 90 then
		CHAT_SYSTEM:AddMessage("I'm getting really hungry, I better find food before I get into trouble")
	elseif savedVars.Hunger >= 90 then
		CHAT_SYSTEM:AddMessage("I'm starving and my body feels so heavy, if I don't eat soon I'll pass out")
	end	
	
	if savedVars.Thirst < 25 then
		CHAT_SYSTEM:AddMessage("I feel fine and don't need to drink right now")
	elseif savedVars.Thirst >= 25 and savedVars.Thirst < 50 then
		CHAT_SYSTEM:AddMessage("I'm starting to feel thirsty I should drink something soon")
	elseif savedVars.Thirst >= 50 and savedVars.Thirst < 75 then
		CHAT_SYSTEM:AddMessage("I'm getting very thirsty, I better find something to drink before I get into trouble")
	elseif savedVars.Thirst >= 75 then
		CHAT_SYSTEM:AddMessage("I can barely feel my throat and my body awful, if I don't drink something soon I'll pass out")
	end

	if savedVars.Hygine < 35 then
		CHAT_SYSTEM:AddMessage("I've bathed recently and feel great")
	elseif savedVars.Hygine >= 35 and savedVars.Hygine < 60 then
		CHAT_SYSTEM:AddMessage("I'm starting to get dirty I should clean myself off soon")
	elseif savedVars.Hygine >= 60 and savedVars.Hygine < 85 then
		CHAT_SYSTEM:AddMessage("I've got blood and mud all over me, I better wash this off before I catch something bad")
	elseif savedVars.Hygine >= 85 then
		CHAT_SYSTEM:AddMessage("I have muck in place I didn't think it could get.. and it feels disgusting, I need to bath")
	end		
	
	if savedVars.Fatigue < 30 then
		CHAT_SYSTEM:AddMessage("I feel well rested and don't need to sleep")
	elseif savedVars.Fatigue >= 30 and savedVars.Fatigue < 50 then
		CHAT_SYSTEM:AddMessage("I'm starting to feel tired I should rest soon")
	elseif savedVars.Fatigue >= 50 and savedVars.Fatigue < 60 then
		CHAT_SYSTEM:AddMessage("I'm getting really tired now, I better find somewhere to rest before I get into trouble")
	elseif savedVars.Fatigue >= 60 then
		CHAT_SYSTEM:AddMessage("I'm so tired I can barely keep my eyes open, if I don't rest soon I'll pass out")
	end	
	
	if savedVars.NSFW == true then
		if savedVars.Arousal < 10 then
			CHAT_SYSTEM:AddMessage("I've had fun so I'm not feeling very aroused right now")
		elseif savedVars.Arousal >= 10 and savedVars.Arousal < 25 then
			CHAT_SYSTEM:AddMessage("I'm starting to feel aroused I wonder if there's someone around to help with that")
		elseif savedVars.Arousal >= 25 and savedVars.Arousal < 50 then
			CHAT_SYSTEM:AddMessage("I'm getting really aroused right now, I think I need to do something about that before I get into more trouble")
		elseif savedVars.Arousal >= 50 then
			CHAT_SYSTEM:AddMessage("I can barely control my urges everything is looking fun right now, if I don't do something to satisfy them, I'm going to make some very bad decisions")
		end	
	end
end

function Restore_hunger()
	savedVars.Hunger = 0
	stage1Hunger = false
	stage2Hunger = false
	stage3Hunger = false
	CHAT_SYSTEM:AddMessage("That's much better, I'm feeling well fed again")
end

function Restore_thirst()
	if inWater == true then
		CHAT_SYSTEM:AddMessage("so you WANT dysentery?")
	end
	savedVars.Thirst = 0
	stage1Thirst = false
	stage2Thirst = false
	stage3Thirst = false
	CHAT_SYSTEM:AddMessage("That hit the spot")
end

function Restore_fatigue()
	savedVars.Fatigue = 0
	stage1Fatigue = false
	stage2Fatigue = false
	stage3Fatigue = false
	CHAT_SYSTEM:AddMessage("A little rest goes a long way, I feel much better now")
end

function Restore_hygine()
	savedVars.Hygine = 0
	stage1Hygine = false
	stage2Hygine = false
	stage3Hygine = false
	CHAT_SYSTEM:AddMessage("Clean once more, that feels much better")
end

function Restore_arousal()
	savedVars.Arousal = 0
	stage1Arousal = false
	stage2Arousal = false
	stage3Arousal = false
	CHAT_SYSTEM:AddMessage("That felt amazing, I can't wait to do that again")
end

function Hunger_state(update_need_by)
	savedVars.Hunger = savedVars.Hunger + round((update_need_by/180))
	
	if savedVars.Hunger >= 40 and savedVars.Hunger < 60 then
		if stage1Hunger == false then
			CHAT_SYSTEM:AddMessage("You start to feel hungry and should probably eat soon")
			stage1Hunger = true
		end
	elseif savedVars.Hunger >= 60 and savedVars.Hunger < 90 then
		if stage2Hunger == false then
			CHAT_SYSTEM:AddMessage("You start to feel very hungry and should really eat soon your body is feeling sluggish")
			stage2Hunger = true
		end
	elseif savedVars.Hunger >= 90 then
		if stage3Hunger == false then
			CHAT_SYSTEM:AddMessage("You're extremely hungry and need to eat soon your body is feeling incredibly slow")
			stage3Hunger = true
		end		
	end
end

function Thirst_state(update_need_by)
	savedVars.Thirst = savedVars.Thirst + round((update_need_by/180))
	
	if savedVars.Thirst >= 20 and savedVars.Thirst < 30 then
		if stage1Thirst == false then
			CHAT_SYSTEM:AddMessage("You start to feel thirsty and should probably drink something soon")
			stage1Thirst = true
		end
	elseif savedVars.Thirst >= 30 and savedVars.Thirst < 55 then
		if stage2Thirst == false then
			CHAT_SYSTEM:AddMessage("You start to feel very thirsty and should really drink something soon your body is feeling sluggish")
			stage2Thirst = true
		end
	elseif savedVars.Thirst >= 55 then
		if stage3Thirst == false then
			CHAT_SYSTEM:AddMessage("You're extremely thirsty and need to drink something soon your body is feeling incredibly slow")
			stage3Thirst = true
		end		
	end
end

function Fatigue_state(update_need_by)
	savedVars.Fatigue = savedVars.Fatigue + round((update_need_by/180))
	
	if savedVars.Fatigue >= 45 and savedVars.Fatigue < 75 then
		if stage1Fatigue == false then
			CHAT_SYSTEM:AddMessage("You start to feel tired and should probably rest soon")
			stage1Fatigue = true
		end
	elseif savedVars.Fatigue >= 75 and savedVars.Fatigue < 80 then
		if stage2Fatigue == false then
			CHAT_SYSTEM:AddMessage("You start to feel very tired and should really rest soon your body is feeling sluggish")
			stage2Fatigue = true
		end
	elseif savedVars.Fatigue >= 80 then
		if stage3Fatigue == false then
			CHAT_SYSTEM:AddMessage("You're extremely tired and need to rest soon your body is feeling incredibly slow")
			stage3Fatigue = true
		end		
	end
end

function Hygine_state(update_need_by)
	savedVars.Hygine = savedVars.Hygine + round((update_need_by/180))
	
	if savedVars.Hygine >= 40 and savedVars.Hygine < 65 then
		if stage1Hygine == false then
			if savedVars.Player_Race == 'Nord' and savedVars.playerGender == 2 then
				CHAT_SYSTEM:AddMessage("I'm getting dirty... meh who cares")
			else
				CHAT_SYSTEM:AddMessage("You start to feel dirty and should probably bathe soon")
			end
			stage1Hygine = true
		end
	elseif savedVars.Hygine >= 65 and savedVars.Hygine < 85 then
		if stage2Hygine == false then
			CHAT_SYSTEM:AddMessage("You've started to get very dirty and should really bathe soon your body is feeling sluggish")
			stage2Hygine = true
		end
	elseif savedVars.Hygine >= 85 then
		if stage3Hygine == false then
			CHAT_SYSTEM:AddMessage("You're extremely dirty and need to bathe soon your body is feeling incredibly slow")
			stage3Hygine = true
		end		
	end
end

function Arousal_state(update_need_by)
	savedVars.Arousal = savedVars.Arousal + round((update_need_by/180))
	
	if savedVars.Arousal >= 10 and savedVars.Arousal < 25 then
		if stage1Arousal == false then
			CHAT_SYSTEM:AddMessage("You start to feel aroused and should probably 'handle' that soon")
			stage1Arousal = true
		end
	elseif savedVars.Arousal >= 25 and savedVars.Arousal < 50 then
		if stage2Arousal == false then
			CHAT_SYSTEM:AddMessage("You start to feel very aroused and should really deal with it soon your body is feeling hot")
			stage2Arousal = true
		end
	elseif savedVars.Arousal >= 50 then
		if stage3Arousal == false then
			CHAT_SYSTEM:AddMessage("You're extremely aroused and need to take care of it soon your body is feeling incredibly hot and sensitive")
			stage3Arousal = true
		end		
	end
end

function Tease_self()
	if savedVars.NSFW == true then
		tease = math.random(5)

		if tease == 1 then
			CHAT_SYSTEM:AddMessage("I reach up with both hands to my chest finding my nipples my fingers curl around them tweaking them, giving them a tug I feel myself biting down on my lower lip to suppress a moan... that felt a lot better than you thought it would")
			savedVars.Arousal = savedVars.Arousal + 10
		elseif tease == 2 then
			CHAT_SYSTEM:AddMessage("I slide my hands down between my legs, just for a moment, quickly glancing around hoping no one has seen")
			savedVars.Arousal = savedVars.Arousal + 10
		elseif tease == 3 then
			CHAT_SYSTEM:AddMessage("I slide both hands down between my legs, I feel my toes wiggle a little with excitement... ")
			savedVars.Arousal = savedVars.Arousal + 10
		elseif tease == 4 then
			CHAT_SYSTEM:AddMessage("Oh my! that Bosmer with the chain is so....")
			savedVars.Arousal = savedVars.Arousal + 20
		elseif tease == 5 then
			CHAT_SYSTEM:AddMessage("Mmmm I'll just close my eyes for a minute and.. Oh Gods! was that a naked orc in a pool of sweetrolls I was picturing")
			savedVars.Arousal = savedVars.Arousal + 20
		end
	end
end

function Dry_yourself()
	characterWet = false
	CHAT_SYSTEM:AddMessage('You quickly dry yourself off')
end

----------------------------------------------------------------------------------------------------------------------------
--For My Testing Purposes--
----------------------------------------------------------------------------------------------------------------------------
function Test_function()
	--Gender: 1 = Female | Gender: 2 = Male--
	playerGender = GetUnitGender("player")
	CHAT_SYSTEM:AddMessage(tostring(playerGender))
	
	playerRace = GetUnitRace("player")
	CHAT_SYSTEM:AddMessage(tostring(playerRace))
	
	--only true when in werewolf form--
	werewolf = IsWerewolf("player")
	CHAT_SYSTEM:AddMessage(tostring(werewolf))
end

----------------------------------------------------------------------------------------------------------------------------
--Skill System Functions--
----------------------------------------------------------------------------------------------------------------------------

function available_defensive_skills()
	CHAT_SYSTEM:AddMessage('Dodge: ' .. statRank(savedVars.Dodge))
end  

function rollStrength()
	statRoll = rollCalculator(savedVars.Strength)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Strength) .. ' You made a strength roll of: ' .. tostring(statRoll))
	if savedVars.Need_System == true then 
		savedVars.Fatigue = (savedVars.Fatigue + math.random(10))
	end
end

function rollDexterity()
	statRoll = rollCalculator(savedVars.Dexterity)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Dexterity) .. ' You made a Dexterity roll of: ' .. tostring(statRoll))
	if savedVars.Need_System == true then 
		savedVars.Fatigue = (savedVars.Fatigue + math.random(10))
	end
end

function Constitution()
	statRoll = rollCalculator(savedVars.Constitution)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Constitution) .. ' You made a Constitution roll of: ' .. tostring(statRoll))
end

function Intelligence()
	statRoll = rollCalculator(savedVars.Intelligence)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Intelligence) .. ' You made a Intelligence roll of: ' .. tostring(statRoll))
end

function Wisdom()
	statRoll = rollCalculator(savedVars.Wisdom)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Wisdom) .. ' You made a Wisdom roll of: ' .. tostring(statRoll))
end

function Charisma()
	statRoll = rollCalculator(savedVars.Charisma)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Charisma) .. ' You made a Charisma roll of: ' .. tostring(statRoll))
end

function Dual_wield()
	statRoll = rollCalculator(savedVars.Dual_wield)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Dual_wield) .. ' You made a Dual Wield roll of: ' .. tostring(statRoll))
end

function Sword_and_shield()
	statRoll = rollCalculator(savedVars.Sword_and_shield)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Sword_and_shield) .. ' You made a Sword & Shield roll of: ' .. tostring(statRoll))
end

function Bow()
	statRoll = rollCalculator(savedVars.Bow)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Bow) .. ' You made a Bow roll of: ' .. tostring(statRoll))
end

function Two_handeders()
	statRoll = rollCalculator(savedVars.Two_handeders)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Two_handeders) .. ' You made a Two-Handed Weapon roll of: ' .. tostring(statRoll))
end

function Unarmed()
	statRoll = rollCalculator(savedVars.Unarmed)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Unarmed) .. ' You made a Unarmed roll of: ' .. tostring(statRoll))
end

function One_handeders()
	statRoll = rollCalculator(savedVars.One_handeders)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.One_handeders) .. ' You made a One-Handed Weapon roll of: ' .. tostring(statRoll))
end

function Destro_staff()
	statRoll = rollCalculator(savedVars.Destro_staff)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Destro_staff) .. ' You made a Destruction Staff roll of: ' .. tostring(statRoll))
end

function Healing_staff()
	statRoll = rollCalculator(savedVars.Healing_staff)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Healing_staff) .. ' You made a Healing Staff roll of: ' .. tostring(statRoll))
end

function Alchemy()
	statRoll = rollCalculator(savedVars.Alchemy)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Alchemy) .. ' You made a Alchemy roll of: ' .. tostring(statRoll))
end

function Blacksmithing()
	statRoll = rollCalculator(savedVars.Blacksmithing)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Blacksmithing) .. ' You made a Blacksmithing roll of: ' .. tostring(statRoll))
end

function Tailoring()
	statRoll = rollCalculator(savedVars.Tailoring)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Tailoring) .. ' You made a Tailoring roll of: ' .. tostring(statRoll))
end

function Enchanting()
	statRoll = rollCalculator(savedVars.Enchanting)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Enchanting) .. ' You made a Enchanting roll of: ' .. tostring(statRoll))
end

function Provisioning()
	statRoll = rollCalculator(savedVars.Provisioning)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Provisioning) .. ' You made a Provisioning roll of: ' .. tostring(statRoll))
end

function Woodworking()
	statRoll = rollCalculator(savedVars.Woodworking)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Woodworking) .. ' You made a Woodworking roll of: ' .. tostring(statRoll))
end

function Akaviri()
	statRoll = rollCalculator(savedVars.Akaviri)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Akaviri) .. ' You made a Akaviri understanding check of: ' .. tostring(statRoll))
end

function Aldmeris()
	statRoll = rollCalculator(savedVars.Aldmeris)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Aldmeris) .. ' You made a Aldmeris understanding check of: ' .. tostring(statRoll))
end

function Ayleidoon()
	statRoll = rollCalculator(savedVars.Ayleidoon)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Ayleidoon) .. ' You made a Ayleidoon understanding check of: ' .. tostring(statRoll))
end

function Bosmeris()
	statRoll = rollCalculator(savedVars.Bosmeris)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Bosmeris) .. ' You made a Bosmeris understanding check of: ' .. tostring(statRoll))
end

function Daedric()
	statRoll = rollCalculator(savedVars.Daedric)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Daedric) .. ' You made a Daedric understanding check of: ' .. tostring(statRoll))
end

function Draconic()
	statRoll = rollCalculator(savedVars.Draconic)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Draconic) .. ' You made a Draconic understanding check of: ' .. tostring(statRoll))
end

function Dummeris()
	statRoll = rollCalculator(savedVars.Dummeris)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Dummeris) .. ' You made a Dummeris understanding check of: ' .. tostring(statRoll))
end

function Dwemeris()
	statRoll = rollCalculator(savedVars.Dwemeris)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Dwemeris) .. ' You made a Dwemeris understanding check of: ' .. tostring(statRoll))
end

function Ehlnofex()
	statRoll = rollCalculator(savedVars.Ehlnofex)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Ehlnofex) .. ' You made a Ehlnofex understanding check of: ' .. tostring(statRoll))
end

function Falmer()
	statRoll = rollCalculator(savedVars.Falmer)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Falmer) .. ' You made a Falmer understanding check of: ' .. tostring(statRoll))
end

function Giantish()
	statRoll = rollCalculator(savedVars.Giantish)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Giantish) .. ' You made a Giantish understanding check of: ' .. tostring(statRoll))
end

function Goblin()
	statRoll = rollCalculator(savedVars.Goblin)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Goblin) .. ' You made a Goblin understanding check of: ' .. tostring(statRoll))
end

function Harpy()
	statRoll = rollCalculator(savedVars.Harpy)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Harpy) .. ' You made a Harpy understanding check of: ' .. tostring(statRoll))
end

function Imperial()
	statRoll = rollCalculator(savedVars.Imperial)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Imperial) .. ' You made a Imperial understanding check of: ' .. tostring(statRoll))
end

function Impish()
	statRoll = rollCalculator(savedVars.Impish)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Impish) .. ' You made a Impish understanding check of: ' .. tostring(statRoll))
end

function Jel()
	statRoll = rollCalculator(savedVars.Jel)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Jel) .. ' You made a Jel understanding check of: ' .. tostring(statRoll))
end

function Kothringi()
	statRoll = rollCalculator(savedVars.Kothringi)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Kothringi) .. ' You made a Kothringi understanding check of: ' .. tostring(statRoll))
end

function Lamia()
	statRoll = rollCalculator(savedVars.Lamia)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Lamia) .. ' You made a Lamia understanding check of: ' .. tostring(statRoll))
end

function Nedic()
	statRoll = rollCalculator(savedVars.Nedic)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Nedic) .. ' You made a Nedic understanding check of: ' .. tostring(statRoll))
end

function Nordish()
	statRoll = rollCalculator(savedVars.Nordish)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Nordish) .. ' You made a Nordish understanding check of: ' .. tostring(statRoll))
end

function Tsaesci()
	statRoll = rollCalculator(savedVars.Tsaesci)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Tsaesci) .. ' You made a Tsaesci understanding check of: ' .. tostring(statRoll))
end

function Umbrielic()
	statRoll = rollCalculator(savedVars.Umbrielic)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Umbrielic) .. ' You made a Umbrielic understanding check of: ' .. tostring(statRoll))
end

function Yokudan()
	statRoll = rollCalculator(savedVars.Yokudan)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Yokudan) .. ' You made a Yokudan understanding check of: ' .. tostring(statRoll))
end

function Old_bretic()
	statRoll = rollCalculator(savedVars.Old_bretic)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Old_bretic) .. ' You made a Old_bretic understanding check of: ' .. tostring(statRoll))
end

function Orchish()
	statRoll = rollCalculator(savedVars.Orchish)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Orchish) .. ' You made a Orchish understanding check of: ' .. tostring(statRoll))
end

function Sload()
	statRoll = rollCalculator(savedVars.Sload)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Sload) .. ' You made a Sload understanding check of: ' .. tostring(statRoll))
end

function Taagra()
	statRoll = rollCalculator(savedVars.Taagra)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Taagra) .. ' You made a Taagra understanding check of: ' .. tostring(statRoll))
end

function Tamrielic()
	statRoll = rollCalculator(savedVars.Tamrielic)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Tamrielic) .. ' You made a Tamrielic roll of: ' .. tostring(statRoll))
end

function Appraise()
	statRoll = rollCalculator(savedVars.Appraise)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Appraise) .. ' You made a Appraise roll of: ' .. tostring(statRoll))
end

function Balance()
	statRoll = rollCalculator(savedVars.Balance)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Balance) .. ' You made a Balance roll of: ' .. tostring(statRoll))
end

function Bluff()
	statRoll = rollCalculator(savedVars.Bluff)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Bluff) .. ' You made a Bluff roll of: ' .. tostring(statRoll))
end

function Concentration()
	statRoll = rollCalculator(savedVars.Concentration)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Concentration) .. ' You made a Concentration roll of: ' .. tostring(statRoll))
end

function Diplomancy()
	statRoll = rollCalculator(savedVars.Diplomancy)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Diplomancy) .. ' You made a Diplomacy roll of: ' .. tostring(statRoll))
end

function Disable_traps()
	statRoll = rollCalculator(savedVars.Disable_traps)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Disable_traps) .. ' You made a Disable_traps roll of: ' .. tostring(statRoll))
end

function Disguise()
	statRoll = rollCalculator(savedVars.Disguise)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Disguise) .. ' You made a Disguise roll of: ' .. tostring(statRoll))
end

function Escape_artist()
	statRoll = rollCalculator(savedVars.Escape_artist)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Escape_artist) .. ' You made a Escape_artist roll of: ' .. tostring(statRoll))
	if savedVars.Need_System == true then 
		savedVars.Fatigue = (savedVars.Fatigue + math.random(10))
	end
end

function Forgery()
	statRoll = rollCalculator(savedVars.Forgery)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Forgery) .. ' You made a Forgery roll of: ' .. tostring(statRoll))
end

function Gather_info()
	statRoll = rollCalculator(savedVars.Gather_info)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Gather_info) .. ' You made a Gather Information roll of: ' .. tostring(statRoll))
end

function Handle_animals()
	statRoll = rollCalculator(savedVars.Handle_animals)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Handle_animals) .. ' You made a Handle Animals roll of: ' .. tostring(statRoll))
end

function First_aid()
	statRoll = rollCalculator(savedVars.First_aid)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.First_aid) .. ' You made a First Aid roll of: ' .. tostring(statRoll))
end

function Stealth()
	statRoll = rollCalculator(savedVars.Stealth)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Stealth) .. ' You made a Stealth roll of: ' .. tostring(statRoll))
end

function Intimidate()
	statRoll = rollCalculator(savedVars.Intimidate)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Intimidate) .. ' You made a Intimidate roll of: ' .. tostring(statRoll))
end

function Perception()
	statRoll = rollCalculator(savedVars.Perception)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Perception) .. ' You made a Perception roll of: ' .. tostring(statRoll))
end

function Perform()
	statRoll = rollCalculator(savedVars.Perform)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Perform) .. ' You made a Perform roll of: ' .. tostring(statRoll))
end

function Profession()
	statRoll = rollCalculator(savedVars.Profession)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Profession) .. ' You made a Profession roll of: ' .. tostring(statRoll))
end

function Ride()
	statRoll = rollCalculator(savedVars.Ride)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Ride) .. ' You made a Ride roll of: ' .. tostring(statRoll))
end

function Search()
	statRoll = rollCalculator(savedVars.Search)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Search) .. ' You made a Search roll of: ' .. tostring(statRoll))
	if savedVars.Need_System == true then 
		savedVars.Fatigue = (savedVars.Fatigue + math.random(10))
	end
end

function Sense_motive()
	statRoll = rollCalculator(savedVars.Sense_motive)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Sense_motive) .. ' You made a Sense Motive roll of: ' .. tostring(statRoll))
end

function Sleight_of_hand()
	statRoll = rollCalculator(savedVars.Sleight_of_hand)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Sleight_of_hand) .. ' You made a Sleight of Hand roll of: ' .. tostring(statRoll))
end

function Spell_research()
	statRoll = rollCalculator(savedVars.Spell_research)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Spell_research) .. ' You made a Spell Research roll of: ' .. tostring(statRoll))
end

function Survival()
	statRoll = rollCalculator(savedVars.Survival)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Survival) .. ' You made a Survival roll of: ' .. tostring(statRoll))
end

function Swim()
	statRoll = rollCalculator(savedVars.Swim)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Swim) .. ' You made a Swim roll of: ' .. tostring(statRoll))
	if savedVars.Need_System == true then 
		savedVars.Fatigue = (savedVars.Fatigue + math.random(10))
	end
end

function Athletics()
	statRoll = rollCalculator(savedVars.Athletics)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Athletics) .. ' You made a Athletics roll of: ' .. tostring(statRoll))
	if savedVars.Need_System == true then 
		savedVars.Fatigue = (savedVars.Fatigue + math.random(10))
	end
end

function Acrobatics()
	statRoll = rollCalculator(savedVars.Acrobatics)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Acrobatics) .. ' You made a Acrobatics roll of: ' .. tostring(statRoll))
	if savedVars.Need_System == true then 
		savedVars.Fatigue = (savedVars.Fatigue + math.random(10))
	end
end

function Use_devise()
	statRoll = rollCalculator(savedVars.Use_devise)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Use_devise) .. ' You made a Use Device roll of: ' .. tostring(statRoll))
end

function Use_rope()
	statRoll = rollCalculator(savedVars.Use_rope)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Use_rope) .. ' You made a Use Rope roll of: ' .. tostring(statRoll))
	if savedVars.Need_System == true then 
		savedVars.Fatigue = (savedVars.Fatigue + math.random(10))
	end
end

function Alteration()
	statRoll = rollCalculator(savedVars.Alteration)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Alteration) .. ' You made a Alteration roll of: ' .. tostring(statRoll))
end

function Conjuration()
	statRoll = rollCalculator(savedVars.Conjuration)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Conjuration) .. ' You made a Conjuration roll of: ' .. tostring(statRoll))
end

function Destruction()
	statRoll = rollCalculator(savedVars.Destruction)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Destruction) .. ' You made a Destruction roll of: ' .. tostring(statRoll))
end

function Illusion()
	statRoll = rollCalculator(savedVars.Illusion)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Illusion) .. ' You made a Illusion roll of: ' .. tostring(statRoll))
end

function Mysticism()
	statRoll = rollCalculator(savedVars.Mysticism)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Mysticism) .. ' You made a Mysticism roll of: ' .. tostring(statRoll))
end

function Restoration()
	statRoll = rollCalculator(savedVars.Restoration)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Restoration) .. ' You made a Restoration roll of: ' .. tostring(statRoll))
end

function Thaumaturgy()
	statRoll = rollCalculator(savedVars.Thaumaturgy)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Thaumaturgy) .. ' You made a Thaumaturgy roll of: ' .. tostring(statRoll))
end

function Blood()
	statRoll = rollCalculator(savedVars.Blood)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Blood) .. ' You made a Blood roll of: ' .. tostring(statRoll))
end

function Daedric_magic()
	statRoll = rollCalculator(savedVars.Daedric_magic)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Daedric_magic) .. ' You made a Daedric Magic roll of: ' .. tostring(statRoll))
end

function Necromancy()
	statRoll = rollCalculator(savedVars.Necromancy)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Necromancy) .. ' You made a Necromancy roll of: ' .. tostring(statRoll))
end

function Dodge()
	statRoll = rollCalculator(savedVars.Dodge)
	CHAT_SYSTEM:StartTextEntry('As a ' .. statRank(savedVars.Dodge) .. ' You made a Dodge roll of: ' .. tostring(statRoll))
end

----------------------------------------------------------------------------------------------------------------------------
--Role System Functions--
----------------------------------------------------------------------------------------------------------------------------
 
 function needStatePlenty(current_level)
	if stage1Arousal or stage1Fatigue or stage1Hunger or stage1Thirst or stage1Arousal then
		current_level = (current_level - 1) 
	end
	
	if stage2Arousal or stage2Fatigue or stage2Hunger or stage2Thirst or stage2Arousal then
		current_level = (current_level - 2) 
	end
	
	if stage3Arousal or stage3Fatigue or stage3Hunger or stage3Thirst or stage3Arousal then
		current_level = (current_level - 3) 
	end

	return current_level
 end
 
 function rollCalculator(level)
	skillRoll = diceRoll(level)
	return skillRoll
 end
 
 function diceRoll(rollCount)
	count = 0
	roll = 0
	rollCount = needStatePlenty(rollCount) 
	
	if rollCount >= 6 then
		rollCount = (rollCount + 1)
	elseif rollCount <= 0 then
		rollCount = 1
	end
	
	while( count < rollCount )		
	do
		roll = roll + math.random(6)
		count = count + 1
	end
	if roll < rollCount then
		return rollCount
	else
		return roll
	end
 end
 
 function statRank(skill_level)
	if skill_level == 1 then
		rank = 'Novice'
	elseif skill_level == 2 then
		rank = 'Apprentice'
	elseif skill_level == 3 then
		rank = 'Journeyman'
	elseif skill_level == 4 then
		rank = 'Adept'
	elseif skill_level == 5 then
		rank = 'Master'
	elseif skill_level == 6 then
		rank = 'Grand-Master'
	end
	return rank
 end
 
 ---------------------------------------------------------------------------------------------------------------------------
--User Slash Commands--
----------------------------------------------------------------------------------------------------------------------------
 
	SLASH_COMMANDS['/skills'] = available_skills
	SLASH_COMMANDS['/attributes'] = available_attributes
	SLASH_COMMANDS['/languages'] = available_language_skills
	SLASH_COMMANDS['/roleplay'] = available_roleplay_skills
	SLASH_COMMANDS['/crafting'] = available_crafting_skills
	SLASH_COMMANDS['/magic'] = available_magic_skills
	SLASH_COMMANDS['/weapons'] = available_weapon_skills
	SLASH_COMMANDS['/defensive '] = available_defensive_skills
	SLASH_COMMANDS['/strength'] = rollStrength
	SLASH_COMMANDS['/dexterity'] = rollDexterity
	SLASH_COMMANDS['/constitution'] = Constitution
	SLASH_COMMANDS['/intelligence'] = Intelligence
	SLASH_COMMANDS['/wisdom'] = Wisdom
	SLASH_COMMANDS['/charisma'] = Charisma
	SLASH_COMMANDS['/dual_wield'] = Dual_wield
	SLASH_COMMANDS['/sword_and_shield'] = Sword_and_shield
	SLASH_COMMANDS['/use_bow'] = Bow
	SLASH_COMMANDS['/two_handeders'] = Two_handeders
	SLASH_COMMANDS['/destro_staff'] = Destro_staff
	SLASH_COMMANDS['/healing_staff'] = Healing_staff
	SLASH_COMMANDS['/unarmed'] = Unarmed
	SLASH_COMMANDS['/one_handeders'] = One_handeders
	SLASH_COMMANDS['/alchemy'] = Alchemy
	SLASH_COMMANDS['/blacksmithing'] = Blacksmithing 
	SLASH_COMMANDS['/tailoring'] = Tailoring 
	SLASH_COMMANDS['/enchanting'] = Enchanting 
	SLASH_COMMANDS['/provisioning'] = Provisioning 
	SLASH_COMMANDS['/woodworking'] = Woodworking 
	SLASH_COMMANDS['/akaviri'] = Akaviri 
	SLASH_COMMANDS['/aldmeris'] = Aldmeris 
	SLASH_COMMANDS['/ayleidoon'] = Ayleidoon 
	SLASH_COMMANDS['/bosmeris'] = Bosmeris 
	SLASH_COMMANDS['/daedric'] = Daedric 
	SLASH_COMMANDS['/draconic'] = Draconic 
	SLASH_COMMANDS['/dummeris'] = Dummeris 
	SLASH_COMMANDS['/dwemeris'] = Dwemeris 
	SLASH_COMMANDS['/ehlnofex'] =  Ehlnofex  
	SLASH_COMMANDS['/falmer'] =  Falmer  
	SLASH_COMMANDS['/giantish'] = Giantish 
	SLASH_COMMANDS['/goblin'] = Goblin 
	SLASH_COMMANDS['/harpy'] = Harpy 
	SLASH_COMMANDS['/imperial'] = Imperial 
	SLASH_COMMANDS['/impish'] = Impish 
	SLASH_COMMANDS['/jel'] = Jel 
	SLASH_COMMANDS['/kothringi'] = Kothringi 
	SLASH_COMMANDS['/lamia'] = Lamia 
	SLASH_COMMANDS['/nedic'] = Nedic 
	SLASH_COMMANDS['/nordish'] = Nordish 
	SLASH_COMMANDS['/old_bretic'] = Old_bretic 
	SLASH_COMMANDS['/orchish'] = Orchish 
	SLASH_COMMANDS['/sload'] = Sload 
	SLASH_COMMANDS['/taagra'] = Taagra 
	SLASH_COMMANDS['/tamrielic'] = Tamrielic 
	SLASH_COMMANDS['/tsaesci'] = Tsaesci
	SLASH_COMMANDS['/umbrielic'] = Umbrielic 
	SLASH_COMMANDS['/yokudan'] = Yokudan 
	SLASH_COMMANDS['/appraise'] = Appraise 
	SLASH_COMMANDS['/balance'] = Balance
	SLASH_COMMANDS['/bluff'] = Bluff 
	SLASH_COMMANDS['/concentration'] = Concentration 
	SLASH_COMMANDS['/diplomacy'] = Diplomancy 
	SLASH_COMMANDS['/disable_traps'] = Disable_traps 
	SLASH_COMMANDS['/disguise'] = Disguise 
	SLASH_COMMANDS['/escape_artist'] = Escape_artist 
	SLASH_COMMANDS['/forgery'] = Forgery 
	SLASH_COMMANDS['/gather_info'] = Gather_info 
	SLASH_COMMANDS['/handle_animals'] = Handle_animals 
	SLASH_COMMANDS['/first_aid'] = First_aid 
	SLASH_COMMANDS['/stealth'] = Stealth 
	SLASH_COMMANDS['/intimidate'] = Intimidate 
	SLASH_COMMANDS['/perception'] = Perception 
	SLASH_COMMANDS['/perform'] = Perform 
	SLASH_COMMANDS['/profession'] = Profession 
	SLASH_COMMANDS['/ride'] = Ride 
	SLASH_COMMANDS['/use_search'] = Search
	SLASH_COMMANDS['/sense_motive'] = Sense_motive 
	SLASH_COMMANDS['/sleight_of_hand'] = Sleight_of_hand 
	SLASH_COMMANDS['/spell_research'] = Spell_research 
	SLASH_COMMANDS['/survival'] = Survival 
	SLASH_COMMANDS['/swim'] = Swim 
	SLASH_COMMANDS['/athletics'] = Athletics 
	SLASH_COMMANDS['/acrobatics'] = Acrobatics 
	SLASH_COMMANDS['/use_device'] = Use_devise 
	SLASH_COMMANDS['/use_rope'] = Use_rope 
	SLASH_COMMANDS['/alteration'] = Alteration
	SLASH_COMMANDS['/conjuration'] = Conjuration 
	SLASH_COMMANDS['/destruction'] = Destruction 
	SLASH_COMMANDS['/illusion'] = Illusion 
	SLASH_COMMANDS['/mysticism'] = Mysticism 
	SLASH_COMMANDS['/restoration'] = Restoration
	SLASH_COMMANDS['/thaumaturgy'] = Thaumaturgy 
	SLASH_COMMANDS['/blood'] = Blood
	SLASH_COMMANDS['/daedric_magic'] = Daedric_magic 
	SLASH_COMMANDS['/necromancy'] = Necromancy
	SLASH_COMMANDS['/dodge'] = Dodge
	SLASH_COMMANDS['/ate_food'] = Restore_hunger
	SLASH_COMMANDS['/drank_something'] = Restore_thirst
	SLASH_COMMANDS['/rested'] = Restore_fatigue
	SLASH_COMMANDS['/pleasured'] = Restore_arousal
	SLASH_COMMANDS['/bathed'] = Restore_hygine
	SLASH_COMMANDS['/needs'] = Needs
	SLASH_COMMANDS['/tease_yourself'] = Tease_self
	SLASH_COMMANDS['/dry_yourself'] = Dry_yourself
	SLASH_COMMANDS['/testing'] = Test_function
	SLASH_COMMANDS['/helper'] = Basic_Instructions
	
------------------------------------------------------------------------------------------------------------------------------------
-- Set up the options panel in Add-on Settings.
------------------------------------------------------------------------------------------------------------------------------------

local stat_tooltip = 'Novice = 1, Apprentice = 2,  Journeyman = 3, Adept = 4, Master = 5, Grand-Master = 6'

local function CreateSettingsWindow(addonName)
	local panelData = {
		type					= 'panel',
		name					= 'Roleplay Suite - Character Skills & Needs',
		displayName				= 'Roleplay Suite - Character Skills & Needs',
		author					= '@Christopher1995',
		version					= '2.3',
		registerForRefresh		= true,
		registerForDefaults		= true,
	}

	local optionsData = {
	{
		type = 'header',
		name = 'Set your character skill levels',
	},
	
	{
		type = "description",
		text = "Here you can set the rank of your skills, skill rank will set how high you are able to roll for, for example: a Journeyman is level 3 and will roll a 3d6 while a master is level 5 and will roll a 5d6",
	},
	
	{
		type = "description",
		text = "Grand-Masters are the exception to this pattern as they roll a 7d6 making earning the rank all the more important to give you the edge over others. Also note that you cannot role a number lower than your level e.g. a master will never roll lower than a 5 making the chance of a novice ever winning against that roll extremely unlikely",
	},
	
	{
		type = "description",
		text = "you can use '/skills' to show the list of commands that will show all skills under a category and their rank, to roll with a skill simply use '/skillname'",
	},
	
	{
		type = "description",
		text = "The over time your needs will start to decay and have an effect on how will you can do actions, in order to restore needs the following commands: '/ate_food' '/drank_something' '/rested''/pleasured' '/bathed'",
	},
	
	{
		type = "description",
		text = "Don't forget to run '/reloadui' after changing your level or it won't take effect you can use '/helper for a quick guide on how to use the addon in-game'",
	},

	{
		type = 'header',
		name = 'Options',
	},
	
	{
		type			= 'checkbox',
		name			= 'Needs System',
		tooltip			= 'Turn on to use the needs system functionality to affect skill rolls',
		getFunc			= function() return savedVars.Need_System end,
		setFunc			= function(value)
							savedVars.Need_System = value
						end,
	},
	
	{
		type			= 'checkbox',
		name			= 'NSFW - Needs System Extention',
		tooltip			= 'Turn on to use the NSFW functionality of the needs system - 18+ Only',
		getFunc			= function() return savedVars.NSFW end,
		setFunc			= function(value)
							savedVars.NSFW = value
						end,
	},
	
	{
		type = "description",
		text = stat_tooltip,
	},
	
	{
		type = 'header',
		name = 'Attributes',
	},
	
	{
		type = "slider",
		name = "Strength",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Strength end,
		setFunc = function(newValue) 
					savedVars.Strength = newValue
					end,
	},
		
	{
		type = "slider",
		name = "Dexterity",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Dexterity end,
		setFunc = function(newValue) 
					savedVars.Dexterity = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Constitution",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Constitution end,
		setFunc = function(newValue) 
					savedVars.Constitution = newValue
					end,
	},	

	{
		type = "slider",
		name = "Intelligence",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Intelligence end,
		setFunc = function(newValue) 
					savedVars.Intelligence = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Wisdom",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Wisdom end,
		setFunc = function(newValue) 
					savedVars.Wisdom = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Charisma",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Charisma end,
		setFunc = function(newValue) 
					savedVars.Charisma = newValue
					end,
	},	
	
	{
		type = 'header',
		name = 'Fightning Styles',
	},
	
	{
		type = "slider",
		name = "Dual Wield",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Dual_wield end,
		setFunc = function(newValue) 
					savedVars.Dual_wield = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Sword & Shield",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Sword_and_shield end,
		setFunc = function(newValue) 
					savedVars.Sword_and_shield = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Bow",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Bow end,
		setFunc = function(newValue) 
					savedVars.Bow = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Two Handed Weapons",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Two_handeders end,
		setFunc = function(newValue) 
					savedVars.Two_handeders = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Destruction Staff",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Destro_staff end,
		setFunc = function(newValue) 
					savedVars.Destro_staff = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Healing Staff",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Healing_staff end,
		setFunc = function(newValue) 
					savedVars.Healing_staff = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Unarmed",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Unarmed end,
		setFunc = function(newValue) 
					savedVars.Unarmed = newValue
					end,
	},
	
	{
		type = "slider",
		name = "One Handed Weapons",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.One_handeders end,
		setFunc = function(newValue) 
					savedVars.One_handeders = newValue
					end,
	},
	
		{
		type = 'header',
		name = 'Defensive Skills',
	},
	
	{
		type = "slider",
		name = "Dodge",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Dodge end,
		setFunc = function(newValue) 
					savedVars.Dodge = newValue
					end,
	},
	
	{
		type = 'header',
		name = 'Magic Skills',
	},
	
	{
		type = "slider",
		name = "Alteration",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Alteration end,
		setFunc = function(newValue) 
					savedVars.Alteration = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Conjuration",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Conjuration end,
		setFunc = function(newValue) 
					savedVars.Conjuration = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Destruction",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Destruction end,
		setFunc = function(newValue) 
					savedVars.Destruction = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Illusion",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Illusion end,
		setFunc = function(newValue) 
					savedVars.Illusion = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Mysticism",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Mysticism end,
		setFunc = function(newValue) 
					savedVars.Mysticism = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Restoration",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Restoration end,
		setFunc = function(newValue) 
					savedVars.Restoration = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Thaumaturgy",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Thaumaturgy end,
		setFunc = function(newValue) 
					savedVars.Thaumaturgy = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Blood",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Blood end,
		setFunc = function(newValue) 
					savedVars.Blood = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Daedric",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Daedric_magic end,
		setFunc = function(newValue) 
					savedVars.Daedric_magic = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Necromancy",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Necromancy end,
		setFunc = function(newValue) 
					savedVars.Necromancy = newValue
					end,
	},
	
	{
		type = 'header',
		name = 'Crafting Skills',
	},
	
	{
		type = "slider",
		name = "Alchemy",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Alchemy end,
		setFunc = function(newValue) 
					savedVars.Alchemy = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Blacksmithing",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Blacksmithing end,
		setFunc = function(newValue) 
					savedVars.Blacksmithing = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Tailoring",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Tailoring end,
		setFunc = function(newValue) 
					savedVars.Tailoring = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Enchanting",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Enchanting end,
		setFunc = function(newValue) 
					savedVars.Enchanting = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Provisioning",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Provisioning end,
		setFunc = function(newValue) 
					savedVars.Provisioning = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Woodworking",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Woodworking end,
		setFunc = function(newValue) 
					savedVars.Woodworking = newValue
					end,
	},
	
	{
		type = 'header',
		name = 'Roleplay Skills',
	},
	
	{
		type = "slider",
		name = "Appraise",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Appraise end,
		setFunc = function(newValue) 
					savedVars.Appraise = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Balance",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Balance end,
		setFunc = function(newValue) 
					savedVars.Balance = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Bluff",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Bluff end,
		setFunc = function(newValue) 
					savedVars.Bluff = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Concentration",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Concentration end,
		setFunc = function(newValue) 
					savedVars.Concentration = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Diplomacy",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Diplomancy end,
		setFunc = function(newValue) 
					savedVars.Diplomancy = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Disable Traps",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Disable_traps end,
		setFunc = function(newValue) 
					savedVars.Disable_traps = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Disguise",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Disguise end,
		setFunc = function(newValue) 
					savedVars.Disguise = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Escape Artist",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Escape_artist end,
		setFunc = function(newValue) 
					savedVars.Escape_artist = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Forgery",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Forgery end,
		setFunc = function(newValue) 
					savedVars.Forgery = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Gather Information",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Gather_info end,
		setFunc = function(newValue) 
					savedVars.Gather_info = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Handle Animals",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Handle_animals end,
		setFunc = function(newValue) 
					savedVars.Handle_animals = newValue
					end,
	},
	
	{
		type = "slider",
		name = "First Aid",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.First_aid end,
		setFunc = function(newValue) 
					savedVars.First_aid = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Stealth",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Stealth end,
		setFunc = function(newValue) 
					savedVars.Stealth = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Intimidate",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Intimidate end,
		setFunc = function(newValue) 
					savedVars.Intimidate = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Perception",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Perception end,
		setFunc = function(newValue) 
					savedVars.Perception = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Perform",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Perform end,
		setFunc = function(newValue) 
					savedVars.Perform = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Profession",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Profession end,
		setFunc = function(newValue) 
					savedVars.Profession = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Ride",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Ride end,
		setFunc = function(newValue) 
					savedVars.Ride = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Search",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Search end,
		setFunc = function(newValue) 
					savedVars.Search = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Sense Motive",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Sense_motive end,
		setFunc = function(newValue) 
					savedVars.Sense_motive = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Sleight of hand",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Sleight_of_hand end,
		setFunc = function(newValue) 
					savedVars.Sleight_of_hand = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Spell Research",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Spell_research end,
		setFunc = function(newValue) 
					savedVars.Spell_research = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Swim",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Swim end,
		setFunc = function(newValue) 
					savedVars.Swim = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Athletics",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Athletics end,
		setFunc = function(newValue) 
					savedVars.Athletics = newValue
					end,
	},	
	
	{
		type = "slider",
		name = "Acrobatics",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Acrobatics end,
		setFunc = function(newValue) 
					savedVars.Acrobatics = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Use Device",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Use_devise end,
		setFunc = function(newValue) 
					savedVars.Use_devise = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Use Rope",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Use_rope end,
		setFunc = function(newValue) 
					savedVars.Use_rope = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Survival",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Survival end,
		setFunc = function(newValue) 
					savedVars.Survival = newValue
					end,
	},
	
	{
		type = 'header',
		name = 'Languages',
	},
	
	{
		type = "slider",
		name = "Akaviri",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Akaviri end,
		setFunc = function(newValue) 
					savedVars.Akaviri = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Aldmeris",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Aldmeris end,
		setFunc = function(newValue) 
					savedVars.Aldmeris = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Ayleidoon",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Ayleidoon end,
		setFunc = function(newValue) 
					savedVars.Ayleidoon = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Bosmeris",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Bosmeris end,
		setFunc = function(newValue) 
					savedVars.Bosmeris = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Daedric",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Daedric end,
		setFunc = function(newValue) 
					savedVars.Daedric = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Draconic",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Draconic end,
		setFunc = function(newValue) 
					savedVars.Draconic = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Dummeris",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Dummeris end,
		setFunc = function(newValue) 
					savedVars.Dummeris = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Dwemeris",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Dwemeris end,
		setFunc = function(newValue) 
					savedVars.Dwemeris = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Ehlnofex",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Ehlnofex end,
		setFunc = function(newValue) 
					savedVars.Ehlnofex = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Falmer",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Falmer end,
		setFunc = function(newValue) 
					savedVars.Falmer = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Giantish",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Giantish end,
		setFunc = function(newValue) 
					savedVars.Giantish = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Goblin",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Goblin end,
		setFunc = function(newValue) 
					savedVars.Goblin = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Harpy",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Harpy end,
		setFunc = function(newValue) 
					savedVars.Harpy = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Imperial",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Imperial end,
		setFunc = function(newValue) 
					savedVars.Imperial = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Impish",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Impish end,
		setFunc = function(newValue) 
					savedVars.Impish = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Jel",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Jel end,
		setFunc = function(newValue) 
					savedVars.Jel = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Kothringi",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Kothringi end,
		setFunc = function(newValue) 
					savedVars.Kothringi = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Lamia",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Lamia end,
		setFunc = function(newValue) 
					savedVars.Lamia = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Nedic",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Nedic end,
		setFunc = function(newValue) 
					savedVars.Nedic = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Nordish",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Nordish end,
		setFunc = function(newValue) 
					savedVars.Nordish = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Old_bretic",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Old_bretic end,
		setFunc = function(newValue) 
					savedVars.Old_bretic = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Orchish",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Orchish end,
		setFunc = function(newValue) 
					savedVars.Orchish = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Sload",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Sload end,
		setFunc = function(newValue) 
					savedVars.Sload = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Taagra",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Taagra end,
		setFunc = function(newValue) 
					savedVars.Taagra = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Tamrielic",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Tamrielic end,
		setFunc = function(newValue) 
					savedVars.Tamrielic = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Tsaesci",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Tsaesci end,
		setFunc = function(newValue) 
					savedVars.Tsaesci = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Umbrielic",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Umbrielic end,
		setFunc = function(newValue) 
					savedVars.Umbrielic = newValue
					end,
	},
	
	{
		type = "slider",
		name = "Yokudan",
		tooltip = stat_tooltip,
		min = 1,
		max = 6,
		step = 1,
		default = 1,
		getFunc = function() return savedVars.Yokudan end,
		setFunc = function(newValue) 
					savedVars.Yokudan = newValue
					end,
	},
	
	}

	local LAM = LibStub('LibAddonMenu-2.0')
    LAM:RegisterAddonPanel('GuildEventDiceRoll_Panel', panelData)
	LAM:RegisterOptionControls('GuildEventDiceRoll_Panel', optionsData)
end

----------------------------------------------------------------------------------------------------------------------------
--Register & Run Add-on--
----------------------------------------------------------------------------------------------------------------------------

local function PLayerCombatState(inCombat)
	inCombat = IsUnitInCombat("player")
	if savedVars.Need_System == true then
		if inCombat == true then
			combatStart = math.floor(GetTimeStamp()) 
		elseif inCombat == false then 
			combatEnd = (math.floor(GetTimeStamp()) - combatStart)
		end
		
		if combatEnd >= 60 and combatEnd < 120 then 
			CHAT_SYSTEM:AddMessage("That was a good fight, I'm starting starting to feel it wear me down")
			savedVars.Thirst = savedVars.Thirst + 15
			savedVars.Fatigue = savedVars.Fatigue + 15
		elseif combatEnd >= 120 and combatEnd < 180 then 
			CHAT_SYSTEM:AddMessage("*pants* *pants* that was a tough one, should really stop and catch my breath")
			savedVars.Thirst = savedVars.Thirst + 35
			savedVars.Fatigue = savedVars.Fatigue + 35
		end
	end
end

local function PlayerSwimming()
	if savedVars.Need_System == true then 
		inWater = true
		savedVars.Hygine = 0
		if characterWet == false then
			water = math.random(2)
			
			if water == 1 then
				CHAT_SYSTEM:AddMessage("this water feels good")
			elseif water == 2 then
				CHAT_SYSTEM:AddMessage("What was that! I think I just felt something run pass my leg")
			end
		end
	end
end

local function PlayerNotSwimming()
	if savedVars.Need_System == true then 
		inWater = false
		savedVars.Hygine = 0
		if characterWet == false then
			characterWet = true 
			CHAT_SYSTEM:AddMessage("I'm dripping wet now, but at least I'm also clean")
		end
	end
end

--doesn't seem to be required but leaving here till confirmed--
local function AddonInit()
	--Strength = savedVars.Strength--
	--Dexterity = savedVars.Dexterity--
end
 
----------------------------------------------------------------------------------------------------------------------------
--All saved variables defaults stored in this table--
----------------------------------------------------------------------------------------------------------------------------

local function OnAddOnLoaded(eventCode, addOnName)
    if(addOnName ~= "GuildEventDiceRoll") then return end
	
    EVENT_MANAGER:UnregisterForEvent("GuildEventDiceRoll", EVENT_ADD_ON_LOADED)
	
	local defaults =
	{
		Strength = 1,
		Dexterity = 1,
		Constitution = 1,
		Intelligence = 1,
		Wisdom = 1,
		Charisma = 1,
		Dual_wield = 1,
		Sword_and_shield = 1,
		Bow = 1,
		Two_handeders = 1,
		Destro_staff = 1,
		Healing_staff = 1,
		Alchemy = 1,
		Blacksmithing = 1,
		Tailoring = 1,
		Enchanting = 1,
		Provisioning = 1,
		Woodworking = 1,
		Akaviri = 1,
		Aldmeris = 1,
		Ayleidoon = 1,
		Bosmeris = 1,
		Daedric = 1,
		Draconic = 1,
		Dummeris = 1,
		Dwemeris = 1,
		Ehlnofex = 1, 
		Falmer = 1, 
		Giantish = 1,
		Goblin = 1,
		Harpy = 1,
		Imperial = 1,
		Impish = 1,
		Jel = 1,
		Kothringi = 1,
		Lamia = 1,
		Nedic = 1,
		Nordish = 1,
		Old_bretic = 1,
		Orchish = 1,
		Sload = 1,
		Taagra = 1,
		Tamrielic = 1,
		Tsaesci = 1,
		Umbrielic = 1,
		Yokudan = 1,
		Appraise = 1,
		Balance = 1,
		Bluff = 1,
		Concentration = 1,
		Diplomancy = 1,
		Disable_traps = 1,
		Disguise = 1,
		Escape_artist = 1,
		Forgery = 1,
		Gather_info = 1,
		Handle_animals = 1,
		First_aid = 1,
		Stealth = 1,
		Intimidate = 1,
		Perception = 1,
		Perform = 1,
		Profession = 1,
		Ride = 1,
		Search = 1,
		Sense_motive = 1,
		Sleight_of_hand = 1,
		Spell_research = 1,
		Survival = 1,
		Swim = 1,
		Use_devise = 1,
		Use_rope = 1,
		Alteration = 1,
		Conjuration = 1, 
		Destruction = 1, 
		Illusion = 1,
		Mysticism = 1,
		Restoration = 1,
		Thaumaturgy = 1,
		Blood = 1,
		Daedric_magic = 1,
		Necromancy = 1,
		Unarmed = 1,
		One_handeders = 1,
		Dodge = 1,
		Athletics = 1,
		Acrobatics = 1,
		Hunger   = 0,
		Thirst   = 0,
		Fatigue  = 0,
		Hygine   = 0,
		Arousal  = 0,
		NSFW = false,
		Need_System = true,
		Player_Gender = GetUnitGender("player"),
		Player_Race = GetUnitRace("player"),
	}	
	
	savedVars = ZO_SavedVars:New('GuildEventDiceRoll_SavedVariables', 1, defaults)
	lastTime = math.floor(GetTimeStamp())
	CreateSettingsWindow(addonName)
	AddonInit()
end

----------------------------------------------------------------------------------------------------------------------------
--Run Each Time Message is Sent/Received In Order To Update Need States--
----------------------------------------------------------------------------------------------------------------------------

local function ChatMessageChannel(messageType, fromName, text)
	if savedVars.Need_System == true then
		current_time = math.floor(GetTimeStamp()) 
		time_since = (current_time - lastTime) 
		needUpdate = (needUpdate + time_since)
		
		if needUpdate >= 180 then
			Hunger_state(needUpdate)
			Thirst_state(needUpdate)
			Hygine_state(needUpdate)
			Fatigue_state(needUpdate)
			if savedVars.NSFW == true then
				Arousal_state(needUpdate)
			end
			needUpdate = 0
		end
		
		if stage3Arousal and stage1Fatigue and stage3Hunger and stage3Hygine and stage3Thirst then
			CHAT_SYSTEM:AddMessage("You've reached your limits, your only chance now is to offer your body and soul to The OverLord and pray that he is merciful")
		end
		
		lastTime = current_time  
	end	
end
  
   
EVENT_MANAGER:RegisterForEvent("GuildEventDiceRoll", EVENT_PLAYER_COMBAT_STATE , PLayerCombatState)
EVENT_MANAGER:RegisterForEvent("GuildEventDiceRoll", EVENT_PLAYER_NOT_SWIMMING , PlayerNotSwimming)
EVENT_MANAGER:RegisterForEvent("GuildEventDiceRoll", EVENT_PLAYER_SWIMMING, PlayerSwimming)
EVENT_MANAGER:RegisterForEvent("GuildEventDiceRoll", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent("GuildEventDiceRoll", EVENT_CHAT_MESSAGE_CHANNEL, ChatMessageChannel)