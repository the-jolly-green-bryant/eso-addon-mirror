-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--  Libraries --
-------------------------------------------------------------------------------------------------
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
     --returns a reference to the library table
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--  Variables --
-------------------------------------------------------------------------------------------------
	
local start_count = 0

RadiantTime = {}

--Saved Variables
RadiantTime.Default = {
	OffsetX = 800,
	OffsetY = 300,
	OffsetXtable = 900,
	OffsetYtable = 300,
	ShowTable = true,
	AlwaysShowTable = false,
	AlwaysShowExecutionAlert = false,
	maxTargetHPindicate = 6000000,
	blockadeAlert = "Burn it!",
	spamAlert = "FINISH HIM!",
	DualsEnable = true,
	preexdps = 35000,
	Penetration = 18200,
	InfernoEnable = false}
	
-------------------------------------------------------------------------------------------------
--  Initialize Variables --
-------------------------------------------------------------------------------------------------
RadiantTime.name = "RadiantTime" 
RadiantTime.version = 1.2
-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------

function RadiantTime.OnAddOnLoaded(event, addonName)
   if addonName ~= RadiantTime.name then return end
	
	RadiantTime:Initialize()
end
 
-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------


function RadiantTime:Initialize()
	RadiantTime.CreateSettingsWindow()
 	
	RadiantTime.savedVariables = ZO_SavedVars:New("RadiantTimeVariables", RadiantTime.version, nil, RadiantTime.Default)
	EVENT_MANAGER:UnregisterForEvent(RadiantTime.name, EVENT_ADD_ON_LOADED)
	
	RadiantTimeWindow:ClearAnchors()
	RadiantTimeWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RadiantTime.savedVariables.OffsetXtable, RadiantTime.savedVariables.OffsetYtable)
	RadiantTimeExecutionAlert:ClearAnchors()
	RadiantTimeExecutionAlert:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RadiantTime.savedVariables.OffsetX, RadiantTime.savedVariables.OffsetY)
	
	RadiantTime.ShowTable = RadiantTime.savedVariables.ShowTable
	RadiantTime.AlwaysShowTable = RadiantTime.savedVariables.AlwaysShowTable
	
	RadiantTime.AlwaysShowExecutionAlert = RadiantTime.savedVariables.AlwaysShowExecutionAlert
	
	EVENT_MANAGER:UnregisterForEvent(RadiantTime.name, EVENT_ADD_ON_LOADED)
	
	RadiantTime.maxTargetHPindicate = RadiantTime.savedVariables.maxTargetHPindicate
	RadiantTime.blockadeAlert = RadiantTime.savedVariables.blockadeAlert
	RadiantTime.spamAlert = RadiantTime.savedVariables.spamAlert
		
	if(RadiantTime.savedVariables.DualsEnable == true)then
		RadiantTime.DualsValue = 0.05
	else
		RadiantTime.DualsValue = 0
	end
	
	if(RadiantTime.savedVariables.InfernoEnable == true)then
		RadiantTime.InfernoValue = 0.08
	else
		RadiantTime.InfernoValue = 0
	end
	RadiantTime.Penetration = RadiantTime.savedVariables.Penetration
	RadiantTime.preexdps = RadiantTime.savedVariables.preexdps
	start_count = 1
end

-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(RadiantTime.name, EVENT_ADD_ON_LOADED, RadiantTime.OnAddOnLoaded)

-------------------------------------------------------------------------------------------------
--  Save Location --
-------------------------------------------------------------------------------------------------

function RadiantTime.SaveLoc()
	RadiantTime.savedVariables.OffsetX = RadiantTimeExecutionAlert:GetLeft()
	RadiantTime.savedVariables.OffsetY = RadiantTimeExecutionAlert:GetTop()
	RadiantTime.savedVariables.OffsetXtable = RadiantTimeWindow:GetLeft()
	RadiantTime.savedVariables.OffsetYtable = RadiantTimeWindow:GetTop()
end

-------------------------------------------------------------------------------------------------
--  Settings --
-------------------------------------------------------------------------------------------------
function RadiantTime.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Radiant Time",
		displayName = "Radiant Time",
		author = "Fortan",
		version = RadiantTime.version,
		slashCommand = "/rdt",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Radiant_Time", panelData)
	
	local optionsData = {
 		[1] = {
			type = "header",
			name = "Radiant Time Settings",
		},
		[2] = {
			type = "description",
			text = "Here you can configure the RadiantTime for your parameters.",
		},

		[3] = {
			type = "checkbox",
			name = "Show table?",
			tooltip = "Enable during combat a table with a reminder of the percentage for start execute?",
			default = true,
			getFunc = function() return RadiantTime.savedVariables.ShowTable end,
			setFunc = function(newValue) 
				RadiantTime.savedVariables.ShowTable = newValue 
				RadiantTime.ShowTable = newValue end,
		},	
		[4] = {
			type = "checkbox",
			name = "Always show table?",
			tooltip = "Need for reposition it.",
			default = false,
			getFunc = function() return RadiantTime.savedVariables.AlwaysShowTable end,
			setFunc = function(newValue) 
				RadiantTime.savedVariables.AlwaysShowTable = newValue 
				RadiantTime.AlwaysShowTable = newValue end,
		},

		[5] = {
			type = "checkbox",
			name = "Show Execution Bar now?",
			tooltip = "Need for reposition it",
			default = false,
			getFunc = function() return RadiantTime.savedVariables.AlwaysShowExecutionAlert end,
			setFunc = function(newValue) 
				RadiantTime.savedVariables.AlwaysShowExecutionAlert = newValue
				RadiantTimeExecutionAlert:SetHidden(not newValue)  end,
		},				
		[6] = {
			type = "checkbox",
			name = "Dual Swords",
			tooltip = "You are using a dual swords when execute?",
			default = true,
			getFunc = function() return RadiantTime.savedVariables.DualsEnable end,
			setFunc = function(newValue) 
				RadiantTime.savedVariables.DualsEnable = newValue
				if(newValue == true)then
					RadiantTime.DualsValue = 0.05
				else
					RadiantTime.DualsValue = 0
				end  end,
		},	
		[7] = {
			type = "checkbox",
			name = "Inferno Staff",
			tooltip = "You are using a inferno staff when execute?",
			default = false,
			getFunc = function() return RadiantTime.savedVariables.InfernoEnable end,
			setFunc = function(newValue) 
				RadiantTime.savedVariables.InfernoEnable = newValue
				if(newValue == true)then
					RadiantTime.InfernoValue = 0.08
				else
					RadiantTime.InfernoValue = 0
				end  end,
		},	
		[8] = {
			type = "slider",
			name = "Target HP",
			tooltip = "The minimum target's max Health which the addon works.",
			min = 100000,
			max = 10000000,
			step = 100000,
			default = 6000000,
			getFunc = function() return RadiantTime.savedVariables.maxTargetHPindicate end,
			setFunc = function(newValue) 
		                RadiantTime.savedVariables.maxTargetHPindicate = newValue
		                RadiantTime.maxTargetHPindicate = newValue
		                end,
		},
		[9] = {
			type = "editbox",
			name = "Blockade+Radiant start alert",
			tooltip = "What alert you want? ATTENTION: In the calculations used in the damage from the blockade to solo-target!",
			default = "Burn it!",
			getFunc = function() return RadiantTime.savedVariables.blockadeAlert end,
			setFunc = function(newValue) 
		                RadiantTime.savedVariables.blockadeAlert = newValue
		                RadiantTime.blockadeAlert = newValue
		                end,
		},
		[10] = {
			type = "editbox",
			name = "Radiant spam start alert",
			tooltip = "What alert you want?",
			default = "FINISH HIM!",
			getFunc = function() return RadiantTime.savedVariables.spamAlert end,
			setFunc = function(newValue) 
		                RadiantTime.savedVariables.spamAlert = newValue
		                RadiantTime.spamAlert = newValue
		                end,
		},
		[11] = {
			type = "slider",
			name = "Penetration",
			tooltip = "How many of your penetration? Boss have 18 200 resits, usually Penetration in raid between 15424 (Light Armor+Drain+Sharpened Weapon) and 18 200.",
			min = 5000,
			max = 18200,
			step = 1,
			default = 15424,
			getFunc = function() return RadiantTime.savedVariables.Penetration end,
			setFunc = function(newValue) 
		                RadiantTime.savedVariables.Penetration = newValue
		                RadiantTime.Penetration = tonumber(newValue)
		                end,
		},
		[12] = {
			type = "slider",
			name = "Pre-execution DPS",
			tooltip = "How many of you DPS the main rotation, before execute? Enter only solotarget DPS if you want the maximum damage to the boss, and the entire DPS if you want the maximum total number.",
			min = 1000,
			max = 100000,
			step = 100,
			default = 35000,
			getFunc = function() return RadiantTime.savedVariables.preexdps end,
			setFunc = function(newValue) 
		                RadiantTime.savedVariables.preexdps = newValue
		                RadiantTime.preexdps = tonumber(newValue)
		                end,
		},	
		
      }
	LAM2:RegisterOptionControls("Radiant_Time", optionsData)
	
end


local CpVariables = {[1]=0,
[2]=1,
[3]=1.6,
[4]=2.2,
[5]=2.6,
[6]=3.1,
[7]=3.5,
[8]=3.9,
[9]=4.3,
[10]=4.6,
[11]=5,
[12]=5.3,
[13]=5.7,
[14]=6,
[15]=6.3,
[16]=6.6,
[17]=6.9,
[18]=7.2,
[19]=7.5,
[20]=7.8,
[21]=8.1,
[22]=8.4,
[23]=8.7,
[24]=8.9,
[25]=9.2,
[26]=9.5,
[27]=9.7,
[28]=10,
[29]=10.3,
[30]=10.5,
[31]=10.8,
[32]=11,
[33]=11.3,
[34]=11.5,
[35]=11.8,
[36]=12,
[37]=12.2,
[38]=12.5,
[39]=12.7,
[40]=12.9,
[41]=13.2,
[42]=13.4,
[43]=13.6,
[44]=13.9,
[45]=14.1,
[46]=14.3,
[47]=14.5,
[48]=14.7,
[49]=15,
[50]=15.2,
[51]=15.4,
[52]=15.6,
[53]=15.8,
[54]=16,
[55]=16.2,
[56]=16.5,
[57]=16.7,
[58]=16.9,
[59]=17.1,
[60]=17.3,
[61]=17.5,
[62]=17.7,
[63]=17.9,
[64]=18.1,
[65]=18.3,
[66]=18.5,
[67]=18.7,
[68]=18.9,
[69]=19.1,
[70]=19.3,
[71]=19.5,
[72]=19.7,
[73]=19.9,
[74]=20.1,
[75]=20.2,
[76]=20.4,
[77]=20.6,
[78]=20.8,
[79]=21,
[80]=21.2,
[81]=21.4,
[82]=21.6,
[83]=21.8,
[84]=21.9,
[85]=22.1,
[86]=22.3,
[87]=22.5,
[88]=22.7,
[89]=22.9,
[90]=23,
[91]=23.2,
[92]=23.4,
[93]=23.6,
[94]=23.8,
[95]=23.9,
[96]=24.1,
[97]=24.3,
[98]=24.5,
[99]=24.6,
[100]=24.8,
[101]=25}


function RadiantTimeUpdate()
	if(start_count == 1)then
		local spellcritical = GetPlayerStat(STAT_SPELL_CRITICAL)
		local spellcriticalpercent = spellcritical/219.1230769230769
		local magickadmg = GetPlayerStat(STAT_SPELL_POWER)
		local curmagicka, maxmagicka, effmaxmagicka = GetUnitPower("player", POWERTYPE_MAGICKA)
		
		
		local EE = GetNumPointsSpentOnChampionSkill(7, 1)
		local Elfborn = GetNumPointsSpentOnChampionSkill(7, 3)
		local Thaumaturge = GetNumPointsSpentOnChampionSkill(5, 1)
		
		local EENum = EE+1
		local ElfbornNum = Elfborn+1
		local ThaumaturgeNum = Thaumaturge+1
		
		local EERes = CpVariables[EENum]
		local ThaumaturgeRes = CpVariables[ThaumaturgeNum]
		local ElfbornRes = CpVariables[ElfbornNum]
		
		local ElfbornPoint = math.floor(ElfbornRes)
		
		if ((ElfbornRes-ElfbornPoint) >= 0.5) then
			ElfbornPoint = ElfbornPoint +1
		end
	
	
		local cpBonus = 1+EERes/100+ThaumaturgeRes/100
		
	
		local MinorSlayer = 0
		local MinorBerserk = 0
		local MinorForce = 0
		local MajorForce = 0
		
		--player buffs
		
		for i = 1, GetNumBuffs("player") do
		local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)
			if(buffName == "Minor Slayer") then
				MinorSlayer = 0.05
			end
			if(buffName == "Minor Force") then
				MinorForce = 10
			end
			if(buffName == "Major Force") then
				MinorBerserk = 15
			end
			if(buffName == "Minor Berserk") then
				MinorBerserk = 0.08
			end
		end
		
		local MinorVulnerabilityBoss = 0
		local MajorBreachBoss = 0
		local MinorBreachBoss = 0
		local AlkoshOnBoss = 0
		local CrusherOnBoss = 0
		local InfusedCrusherOnBoss = 0
		
		
	 --	local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityIdsp = GetUnitBuffInfo("player", 3)
	 --	local psps = buffName
		
		--Boss information
		local targetName = GetUnitName("reticleover")
		local currentTargetHP, maxTargetHP, effectiveMaxTargetHP = GetUnitPower("reticleover", POWERTYPE_HEALTH)
		
		--boss debuffs
		
		for i = 1, GetNumBuffs("reticleover") do
		local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("reticleover", i)
			if(buffName == "Minor Vulnerability") then
				MinorVulnerabilityBoss = 0.08
			end
			if(buffName == "Infallible Aether") then
				MinorVulnerabilityBoss = 0.08
			end
		end
				
		
		local damageBonus = 1+MinorSlayer+MinorBerserk+RadiantTime.DualsValue+MinorVulnerabilityBoss+RadiantTime.InfernoValue
		local spellcritratio = 50+10+ElfbornPoint+MinorForce+MajorForce
		local attackerbonus = cpBonus*damageBonus +0.2*(curmagicka/maxmagicka)
		local critbonus = 1+spellcriticalpercent/100*spellcritratio/100
		local mitigation = 1-(18200-RadiantTime.Penetration)/50000
		local radiantdps = (RadiantTime.preexdps/((maxmagicka*0.0450475+magickadmg*0.4725975-0.4511275)*attackerbonus*mitigation*critbonus*4/2.8)-4.3)/(-6.6)*100
		local fromBlockade = (0.02499*maxmagicka+0.26267*magickadmg-0.53519)*attackerbonus*mitigation*critbonus
		local blockadedps = ((RadiantTime.preexdps-fromBlockade)/((maxmagicka*0.0450475+magickadmg*0.4725975-0.4511275)*attackerbonus*mitigation*critbonus*4/2.8)-4.3)/(-6.6)*100
		local bossex = (RadiantTime.preexdps/radiantdps-4.3)/-6.6
		
		attackerbonus = attackerbonus*100
		critbonus = critbonus*100
		
		local inCombat = IsUnitInCombat("player")
		if(RadiantTime.AlwaysShowTable)then
			RadiantTimeWindow:SetHidden(false)
		elseif(inCombat)then
			RadiantTime.ShowTable = RadiantTime.savedVariables.ShowTable
			RadiantTimeWindow:SetHidden(not RadiantTime.ShowTable)
		else
			RadiantTimeWindow:SetHidden(true)
		end
		
		
		local executeTrigger = "EXECUTE ALERT HERE"
		local bossPercent = currentTargetHP/maxTargetHP*100
		if(maxTargetHP > RadiantTime.maxTargetHPindicate) then
			if(bossPercent < blockadedps) then
				RadiantTimeExecutionAlert:SetHidden(false)
				executeTrigger = ""
				if(bossPercent > radiantdps) then
					executeTrigger = RadiantTime.blockadeAlert
				elseif (bossPercent > 15) then
			  		executeTrigger = RadiantTime.spamAlert
			  	end
			 else
			 	RadiantTimeExecutionAlert:SetHidden(true)
			 	executeTrigger = ""
			 end
		else
			RadiantTimeExecutionAlert:SetHidden(not RadiantTime.savedVariables.AlwaysShowExecutionAlert)
			executeTrigger = "EXECUTE ALERT HERE"	
		end
			RadiantTimeWindowSpam:SetText(string.format("Spam: %d", radiantdps))
			RadiantTimeWindowBlockade:SetText(string.format("Block: %d", blockadedps))
		    RadiantTimeBoss:SetText(string.format("%s", executeTrigger))
	end
--	else
--		radiantdps = ""
--		blockadedps = ""
--		executeTrigger = ""
--		RadiantTimeSpam:SetText(string.format("%s", radiantdps))
--	    RadiantTimeBlockade:SetText(string.format("%s", blockadedps))
--	    RadiantTimeBoss:SetText(string.format("%s", executeTrigger))
--    end
	
	  --  RadiantTimeElfborn:SetText(string.format("TST: %f", critbonus))
   -- RadiantTimeThau:SetText(string.format("Thau: %d", sp))
   -- RadiantTimeThau2:SetText(string.format("Thau: %d", psps))
end