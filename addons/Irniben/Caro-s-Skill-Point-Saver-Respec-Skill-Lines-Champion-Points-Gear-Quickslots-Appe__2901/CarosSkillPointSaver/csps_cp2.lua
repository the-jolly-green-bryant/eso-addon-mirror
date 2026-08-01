local GS = GetString
local cpSlT = {
		"esoui/art/champion/actionbar/champion_bar_world_selection.dds",
		"esoui/art/champion/actionbar/champion_bar_combat_selection.dds",
		"esoui/art/champion/actionbar/champion_bar_conditioning_selection.dds",
}
--local cpColHex = {"A6D852", "5CBDE7", "DE6531" }
local cpColors = CSPS.cpColors

local customCPBarCtr = {}
local cpForHB = false

local cp = CSPS.cp -- table is created in main lua
local cpBar = cp.bar
local cpTable = cp.table

local waitingForCpPurchase = false

local cspsPost = CSPS.post
local cspsD = CSPS.cspsD
local hf = CSPS.helperFunctions

local basestats = {}
local rootNodes = {}
local cpInHb = {}

local vanillaCluster = {}

CSPS.cpColTex = {
		"esoui/art/champion/champion_points_stamina_icon-hud-32.dds",
		"esoui/art/champion/champion_points_magicka_icon-hud-32.dds",
		"esoui/art/champion/champion_points_health_icon-hud-32.dds",
		"esoui/art/menubar/gamepad/gp_playermenu_icon_collections.dds",
		"esoui/art/menubar/gamepad/gp_playermenu_icon_skills.dds",	
		"esoui/art/armory/builditem_icon.dds",	
		"ESOUI/art/restyle/gamepad/gp_dyes_tabicon_outfitstyledye.dds",
}

CSPS.changedCP = false

local resizingNow = false

local customCpIcons = {
	[76] = "esoui/art/icons/ability_thievesguild_passive_004.dds",			-- Friends in Low Places
	[77] = "esoui/art/icons/ability_legerdemain_sly.dds",					-- Infamous
	[80] = "esoui/art/icons/ability_darkbrotherhood_passive_001.dds", 		-- Shadowstrike
	[90] = "esoui/art/icons/ability_legerdemain_lightfingers.dds", 			-- Cutpurse's Art
	[84] = "esoui/art/icons/ability_thievesguild_passive_002.dds",				-- Fade Away 
	[78] = "esoui/art/notifications/gamepad/gp_notification_craftbag.dds", 	-- Master Gatherer 
	[79] = "esoui/art/icons/ability_thievesguild_passive_001.dds", 			-- Treasure Hunter
	[85] = "esoui/art/icons/ability_provisioner_002.dds", 					-- Rationer
	[86] = "esoui/art/icons/ability_alchemy_006.dds", 						-- Liquid Efficiency
	[89] = "esoui/art/icons/crafting_fishing_salmon.dds", 					-- Angler's Instincts
	[88] = "esoui/art/icons/achievements_indexicon_fishing_down.dds", 		-- Reel Technique
	[91] = "esoui/art/crafting/provisioner_indexicon_furnishings_down.dds", -- Homemaker
	[81] = "esoui/art/icons/crafting_flower_corn_flower_r1.dds", 			-- Plentiful Harvest 
	[82] = "esoui/art/mounts/ridingskill_stamina.dds", 						-- War Mount 
	[92] = "esoui/art/mounts/tabicon_mounts_down.dds", 						-- Gifted Rider 
	[83] = "esoui/art/tutorial/inventory_trait_intricate_icon.dds", 		-- Meticulous Disassembly
	[66] = "esoui/art/icons/ability_darkbrotherhood_passive_004.dds", 		-- Steed's Blessing 
	[65] = "esoui/art/icons/ability_armor_007.dds", 						-- Sustaining Shadows 
	[1] = "esoui/art/repair/inventory_tabicon_repair_up.dds", 				-- Professional Upkeep 

	[259] = "esoui/art/icons/ability_templar_005.dds",						-- Weapons Expoert
	[264] = "esoui/art/icons/ability_sorcerer_024.dds",						-- Master at arms
	[260] = "esoui/art/icons/ability_templar_017.dds",						-- Salve of Renewal
	[261] = "esoui/art/icons/ability_templar_021.dds",						-- Hope Infusion
	[262] = "esoui/art/icons/ability_templar_032.dds",						-- From the brink
	[263] = "esoui/art/icons/ability_templar_028.dds",						-- Enlivening Overflow
	[12] = "esoui/art/icons/ability_sorcerer_045.dds", 						-- Fighting Finesse 
	[24] = "esoui/art/icons/ability_templar_016.dds", 						-- Soothing tide
	[9] = "esoui/art/icons/ability_templar_011.dds", 						-- Rejuvenator
	[163] = "esoui/art/icons/ability_alchemy_004.dds",	 					-- Foresight
	[29] = "esoui/art/icons/ability_templar_006.dds", 						-- Cleansing Revival 
	[26] = "esoui/art/icons/ability_templar_004.dds", 						-- Focused Mending
	[28] = "esoui/art/icons/ability_templar_008.dds", 						-- Swift Renewal
	[25] = "esoui/art/icons/ability_vampire_007.dds", 						-- Deadly Aim
	[23] = "esoui/art/icons/ability_sorcerer_006.dds",	 					-- Biting Aura 
	[27] = "esoui/art/icons/ability_sorcerer_004.dds", 						-- Thaumaturge
	[30] = "esoui/art/icons/ability_templar_002.dds",						-- Reaving Blows 
	[8] = "esoui/art/icons/ability_weapon_019.dds", 						-- Wrathful Strikes
	[32] = "esoui/art/icons/ability_sorcerer_010.dds",	 					-- Occult Overload 
	[31] = "esoui/art/icons/ability_weapon_023.dds", 						-- Backstabber
	[13] = "esoui/art/icons/ability_weapon_028.dds", 						-- Resilience
	[136] = "esoui/art/icons/ability_weapon_024.dds", 						-- Enduring Resolve 
	[160] = "esoui/art/icons/ability_psijic_010.dds",						-- Reinforced
	[162] = "esoui/art/icons/ability_armor_013.dds", 						-- Riposte
	[159] = "esoui/art/icons/ability_dragonknight_020.dds", 				-- Bulwark
	[161] = "esoui/art/icons/ability_werewolf_008.dds", 					-- Last Stand
	[33] = "esoui/art/icons/ability_dragonknight_031.dds", 					-- Cutting Defense
	[134] = "esoui/art/icons/ability_armor_014.dds", 						-- Duelist's Rebuff 
	[133] = "esoui/art/icons/ability_dragonknight_029.dds", 				-- Unassailable
	[5] = "esoui/art/icons/ability_scrying_05a.dds", 						-- Endless Endurance
	[4] = "esoui/art/icons/ability_scrying_05d.dds",	 					-- Untamed Aggression
	[3] = "esoui/art/icons/ability_scrying_05b.dds", 						-- Arcane Supremacy
	[265] = "esoui/art/icons/ability_templar_022.dds",						-- Ironclad
	[276] = "esoui/art/icons/ability_sorcerer_008.dds",						-- Force of Nature 
	[277] = "esoui/art/icons/ability_sorcerer_028.dds",						-- Exploiter  

	[62] = "esoui/art/icons/ability_armor_009.dds", 						-- Rousing Speed
	[57] = "esoui/art/icons/ability_thievesguild_passive_005.dds",			-- Survival Instincts 
	[46] = "esoui/art/icons/ability_armor_005.dds", 						-- Bastion
	[61] = "esoui/art/icons/ability_armor_008.dds", 						-- Arcane Alacrity
	[56] = "esoui/art/icons/ability_templar_026.dds", 						-- Spirit Mastery
	[49] = "esoui/art/icons/ability_templar_029.dds", 						-- Strategic Reserve
	[63] = "esoui/art/icons/ability_templar_027.dds", 						-- Shield Master 
	[48] = "esoui/art/icons/ability_weapon_021.dds", 						-- Bloody Renewal 
	[47] = "esoui/art/icons/ability_weapon_006.dds", 						-- Siphoning Spells
	[60] = "esoui/art/icons/ability_armor_012.dds", 						-- On Guard 
	[51] = "esoui/art/icons/ability_armor_010.dds", 						-- Expert Evasion 
	[52] = "esoui/art/icons/ability_armor_006.dds", 						--  Slippery
	[64] = "esoui/art/icons/ability_darkbrotherhood_passive_002.dds",		-- Unchained
	[59] = "esoui/art/icons/ability_dragonknight_021.dds", 					-- Juggernaut
	[54] = "esoui/art/icons/ability_armor_015.dds", 						-- Peace of Mind 
	[55] = "esoui/art/icons/ability_darkbrotherhood_passive_003.dds", 		-- Hardened
	[35] = "esoui/art/icons/ability_dragonknight_024.dds", 					-- Rejuvenation
	[34] = "esoui/art/icons/ability_dragonknight_034.dds", 					-- Ironclad
	[2] = "esoui/art/icons/ability_scrying_05c.dds", 						-- Boundless Vitality
	[266] = "esoui/art/icons/ability_weapon_030.dds",	 					-- Ward Master
	[267] = "esoui/art/icons/ability_weapon_001.dds",						-- Bracing Anchor
	[268] = "esoui/art/icons/ability_vampire_006.dds",						-- Soothing Shield
	[270] = "esoui/art/icons/ability_weapon_017.dds",						-- Celerity
	[271] = "esoui/art/icons/ability_templar_009.dds",						-- Refreshing Stride
	[272] = "esoui/art/icons/ability_weapon_018.dds",						-- Thrill of the Hunt
	[273] = "esoui/art/icons/ability_sorcerer_023.dds",						-- Sustained by Suffering
	[274] = "esoui/art/icons/ability_templar_019.dds",						-- Relentlessness
	[275] = "esoui/art/icons/ability_weapon_009.dds",						-- Pain's Refuge
}


function cp.reSortList()

	cp.createList()
	
	cp.updateUnlock()
	cp.updateClusterSum()
	
	if not CSPS.treeIsReady then 
		CSPS.createTree()
	else
		CSPS.createCPTree()
	end
end

local function createListAlphabetical()
	
	local cpsDone = {}
	local skillByName = {{},{},{}}
	local activeNames = {{},{},{}}
	local passiveNames = {{},{},{}}
	local allNames = {{},{},{}}
	
	for skillId, skillData in pairs(cpTable) do
		local name = zo_strformat("<<C:1>>", GetChampionSkillName(skillId))
		table.insert(skillData.type == 1 and passiveNames[skillData.discipline] or activeNames[skillData.discipline], name)
		table.insert(allNames[skillData.discipline], name)
		skillByName[skillData.discipline][name] = skillData
	end
	for i=1,3 do
		table.sort(activeNames[i])
		table.sort(passiveNames[i])
		table.sort(allNames[i])
	end
	
	if CSPS.savedVariables.settings.sortCPs == 2 then
		for discipline=1,3 do
			for _, skillName in pairs(allNames[discipline]) do
				local skillData = skillByName[discipline][skillName]
				table.insert(cp.sortedLists[discipline], skillData)
			end
		end
		return
	end
	
	for discipline=1, 3 do
		local clusterData = {cluster = {}, discipline = discipline, sum = 0, name = GS(SI_SKILLS_PASSIVE_ABILITIES)}
		local firstInCluster = false
		for _, skillName in pairs(passiveNames[discipline]) do
			local skillData = skillByName[discipline][skillName]
			--table.insert(cp.sortedLists[discipline], skillData)
			table.insert(clusterData.cluster, skillData)
			firstInCluster = firstInCluster or skillData
			cp.clusterParents[skillData.id] = clusterData
		end
		
		clusterData.id = firstInCluster.id
		table.insert(cp.sortedLists[discipline], clusterData)
		
		
		for _, skillName in pairs(activeNames[discipline]) do
			local skillData = skillByName[discipline][skillName]
			table.insert(cp.sortedLists[discipline], skillData)
		end
	end
end

function cp.createList()
	cp.sortedLists = {{}, {}, {}}
	cp.clusterParents = {}
	if CSPS.savedVariables.settings.sortCPs and CSPS.savedVariables.settings.sortCPs > 1 then createListAlphabetical() return end
	local cpsDone = {}
	for discipline = 1,3 do
		local myList = cp.sortedLists[discipline]
		
		for _, skData in pairs(basestats[discipline]) do
			table.insert(myList, skData)
		end		
		
		local function addLinkedNodesByDistance(lastLayer)
			local nextLayer = {}
			for _, skillId in pairs(lastLayer) do
				if not cpsDone[skillId] and not vanillaCluster[skillId] then
					local skData = cpTable[skillId]
					for _, linkedId in pairs(skData.linked or {}) do
						table.insert(nextLayer, linkedId)
					end
					if IsChampionSkillClusterRoot(skillId) then
						skData = {cluster = {skData}, id = skillId, discipline = discipline, sum = 0, name = zo_strformat("<<C:1>>", GetChampionClusterName(skillId))}
						cp.clusterParents[skillId] = skData
						for _, clusterCpId in pairs({GetChampionClusterSkillIds(skillId)}) do
							table.insert(skData.cluster, cpTable[clusterCpId])
							cpsDone[clusterCpId] = true
							cp.clusterParents[clusterCpId] = skData
						end
						
					end
					table.insert(myList, skData)
					cpsDone[skillId] = true
				end
			end
			if #nextLayer > 0 then addLinkedNodesByDistance(nextLayer) end
		end
		
		local baseLayer = {}
		for _, skData in pairs(rootNodes[discipline]) do
			table.insert(baseLayer, skData.id)
		end
		addLinkedNodesByDistance(baseLayer)
	end
end

function cp.CreateTable()
	for discipline = 1, 3 do
		basestats[discipline] = {}
		rootNodes[discipline] = {}
		for skillIndex=1, GetNumChampionDisciplineSkills(discipline) do	
			local skillId = GetChampionSkillId(discipline, skillIndex)
			local skType = GetChampionSkillType(skillId) + 1-- normal,slottable,statpool(also slottable)
			cpTable[skillId] = cpTable[skillId] or {value = 0, unlocked = false, active = false, linked = {GetChampionSkillLinkIds(skillId)}, id = skillId, type = skType, discipline = discipline, jumpPoints = DoesChampionSkillHaveJumpPoints(skillId) and {GetChampionSkillJumpPoints(skillId)}, maxValue=GetChampionSkillMaxPoints(skillId), icon=customCpIcons[skillId] or nil}
			local skData = cpTable[skillId]
			if skType == 3 then
				-- root nodes and basestats are always unlocked
				table.insert(basestats[discipline], skData)
				skData.unlocked = true
			elseif IsChampionSkillRootNode(skillId) then 
				table.insert(rootNodes[discipline], skData)				
				skData.unlocked = true
			end
			if IsChampionSkillClusterRoot(skillId) then
				for _, v in pairs({GetChampionClusterSkillIds(skillId)}) do
					if v ~= skillId then vanillaCluster[v] = skillId end
				end
			end	
		end	
		
	end
end


local function updateUnlock(discipline, oldPoints, ignoreBar)
	oldPoints = oldPoints or {}
	if not discipline then 
		for i=1, 3 do 
			updateUnlock(i, oldPoints) 
		end 
		return oldPoints 
	end
	for skillId, skillData in pairs(cpTable) do
		if skillData.discipline == discipline then
			skillData.active = false
			if not IsChampionSkillRootNode(skillId) then
				skillData.unlocked = false
				oldPoints[skillId] = oldPoints[skillId] or (skillData.value > 0 and skillData.value) or nil
				skillData.value = 0
			end
		end
	end
	for _, clusterData in pairs(cp.clusterParents) do
		if clusterData.discipline == discipline then
			clusterData.unlocked = false
		end
	end
	
	local function unlockLinked(linked)
		if not linked then return end
		for _, skillId in pairs(linked) do
			local skillData = cpTable[skillId]
			if not skillData.unlocked then
				skillData.unlocked = true
				skillData.value = oldPoints[skillId] or 0
				oldPoints[skillId] = nil
				skillData.active = WouldChampionSkillNodeBeUnlocked(skillId, skillData.value)
				if cp.clusterParents[skillId] then cp.clusterParents[skillId].unlocked = true end
				if skillData.active then
					unlockLinked(skillData.linked)
				end
			end
		end
	end
	
	for _, skillData in pairs(basestats[discipline]) do
		skillData.active = WouldChampionSkillNodeBeUnlocked(skillData.id, skillData.value)
	end
	for _, skillData in pairs(rootNodes[discipline]) do
		skillData.active = WouldChampionSkillNodeBeUnlocked(skillData.id, skillData.value)
		if skillData.active then
			unlockLinked(skillData.linked)
		end
	end
	return oldPoints
end

cp.updateUnlock = updateUnlock


function cp.recheckHotbar(discipline)
	if not discipline then for i=1, 3 do cp.recheckHotbar(i)  end return end
	for i=1, 4 do
		if cpBar[discipline][i] and not cpBar[discipline][i].active then
			cpBar[discipline][i] = nil
		end
	end
	cp.updateSidebarIcons(discipline)
end

function cp.isInHb(skillId)
	return cpInHb[skillId] or false
end

function cp.updateSlottedMarks()
	cpInHb = {}
	for _, barTable in pairs(cpBar) do
		for _, skillData in pairs(barTable) do
			cpInHb[skillData.id] = true
		end
	end
end
	

local function applyChampionSkillToHotbarProfile(discipline, hbIndex, skillData, iconCtr)
	if not skillData.active then return end
	if not hbIndex then
		for i=1,4 do
			if not cpBar[discipline][i] then hbIndex = i break end
		end
		if not hbIndex then return end
	else
		for i=1, 4 do
			if cpBar[discipline][i] == skillData then cpBar[discipline][i] = nil end
		end
	end
	cpBar[discipline][hbIndex] = skillData
	
	cp.updateSidebarIcons(discipline)
	cp.updateSlottedMarks()
	CSPS.refreshTree()
	CSPS.unsavedChanges = true
	changedCP = true
	if iconCtr and WINDOW_MANAGER:GetMouseOverControl() == iconCtr.circle then
		CSPS.showCpTT(iconCtr.circle,  skillData, nil, true, true)
	end
	CSPS.showElement("save", true)
end

local function showHotbarSkillMenu(discipline, hbIndex, currentSkillId, showInactive, funcIsSlotted, funcIsActive, funcValue, funcApply, funcRemove)
	
	local skillsInProfile, skillsNotInProfile, skillsAlreadyInHb = {}, {}, {}
	local skillByName = {}
	
	for skillId, skillData in pairs(cpTable) do
		if (not currentSkillId or skillId ~= currentSkillId) and skillData.discipline == discipline and CanChampionSkillTypeBeSlotted(GetChampionSkillType(skillId)) then
			local skillName = zo_strformat("<<C:1>>", GetChampionSkillName(skillId))
			skillByName[skillName] = skillData
			if funcIsSlotted(skillId) then
				table.insert(skillsAlreadyInHb, skillName)
			elseif funcIsActive(skillData) then
				table.insert(skillsInProfile, skillName)
			else
				table.insert(skillsNotInProfile, skillName)
			end
		end
	end
	
	table.sort(skillsInProfile)
	table.sort(skillsNotInProfile)
	table.sort(skillsAlreadyInHb)
	
	ClearMenu()

	local menuIsEmpty = true
	
	local function addEntry(skName, nameColor)
		local skillData = skillByName[skName]
		skName = nameColor and nameColor:Colorize(skName) or skName
		skName = cp.useCustomIcons and skillData.icon and string.format("|t20:20:%s|t %s", skillData.icon, skName) or skName
		AddCustomMenuItem(skName, function() funcApply(discipline, hbIndex, skillData, nil) end)
		
		local menuItemControl = ZO_Menu.items[#ZO_Menu.items].item 
		menuItemControl.onEnter = function() CSPS.showCpTT(menuItemControl, skillData, funcValue and funcValue(skillData) or nil, false, false, 15) end
		menuItemControl.onExit = function() ZO_Tooltips_HideTextTooltip() end
	end
	--ZO_NORMAL_TEXT
	for i, v in pairs(skillsInProfile) do
		addEntry(v, cpColors[discipline])
		menuIsEmpty = false
	end
	
	AddCustomMenuItem("-", function() end)
	
	for i, v in pairs(skillsAlreadyInHb) do
		addEntry(v)
		menuIsEmpty = false
	end
	if showInactive then
		AddCustomMenuItem("-", function() end)
		for i, v in pairs(skillsNotInProfile) do
			addEntry(v, LOCKED_COLOR)
			menuIsEmpty = false
		end
	end
	
	if currentSkillId and currentSkillId ~= 0 then
		if not menuIsEmpty then AddCustomMenuItem("-", function() end) end
		AddCustomMenuItem(GS(SI_ABILITY_ACTION_CLEAR_SLOT), function() funcRemove(discipline, hbIndex) end)
		menuIsEmpty = false
	end
	
	if not menuIsEmpty then ShowMenu() end
end

function CSPS.onCpHbIconReceive(discipline, hbIndex, iconCtr)
	if not cpForHB then return end 
	if cpForHB.discipline ~= discipline then cpForHB = false return end 
	applyChampionSkillToHotbarProfile(discipline, hbIndex, cpForHB, iconCtr)
	cpForHB = false
end

function CSPS.CpHbSkillRemove(discipline, hbIndex)
	if cpBar[discipline][hbIndex] ~= nil then
		cpBar[discipline][hbIndex] = nil	
		cp.updateSidebarIcons(discipline)		
		cp.updateSlottedMarks()
		CSPS.unsavedChanges = true
		ZO_Tooltips_HideTextTooltip()
		changedCP = true
		CSPS.refreshTree()
	end
end	
	
function CSPS.clickCPIcon(skillData, mouseButton)
	if mouseButton == 2 then
		if not skillData or not skillData.discipline then return end
		if cpInHb[skillData.id] then
			local mySlot = 0
			for i=1, 4 do
				if cpBar[skillData.discipline][i] == skillData then mySlot = i break end
			end
			if mySlot > 0 then CSPS.CpHbSkillRemove(skillData.discipline, mySlot) end
		else
			applyChampionSkillToHotbarProfile(skillData.discipline, false, skillData, nil)
		end
	end
end


function cp.rearrangeCustomBar()
	local mySize = CSPS.savedVariables.settings.hbsize or 28
	local cpCustomBar = CSPS.savedVariables.settings.cpCustomBar
	
	local mySpace = mySize * 0.12
	
	-- 1x12 / 3x4 / 1x4 						
	CSPSCpHotbar:SetWidth(cpCustomBar == 1 and 12 * mySize + 17 * mySpace
		or 4 * mySize + 5 * mySpace) 
	CSPSCpHotbar:SetHeight(cpCustomBar == 2 and 3 * mySize + 4 * mySpace or mySize + 2 * mySpace)
	CSPSCpHotbar:SetDimensionConstraints(unpack(cpCustomBar == 1 and {346, 30, 1384, 120} 
		or cpCustomBar == 2 and {120, 30, 480, 120}
		or {120, 30, 480, 120})) -- minX minY maxX maxY	
	
	for i=1,3 do
		customCPBarCtr[i] = customCPBarCtr[i] or {}
		for j=1,4 do
			if (cpCustomBar ~= 3 or i == 1) then
				if not customCPBarCtr[i][j] then
					customCPBarCtr[i][j] = WINDOW_MANAGER:CreateControlFromVirtual("CSPSCpHotbarSlot"..i.."_"..j, CSPSCpHotbar, "CSPSHbPres" )
					customCPBarCtr[i][j]:GetNamedChild("Circle"):SetTexture(cpSlT[i])
					if i == 1 then customCPBarCtr[i][j]:GetNamedChild("Circle"):SetColor(0.8235, 0.8235, 0) end	-- re-color the not-so-green circle for the green cp...
				else
					customCPBarCtr[i][j]:ClearAnchors()
				end
				customCPBarCtr[i][j]:SetHidden(false)
				if cpCustomBar == 1 then
					customCPBarCtr[i][j]:SetAnchor(TOPLEFT, customCPBarCtr[i][j]:GetParent(), TOPLEFT, mySpace + ((i - 1) * 4  + j - 1) * (mySize + mySpace) + 2 * mySpace * (i - 1), mySpace)
				else
					customCPBarCtr[i][j]:SetAnchor(TOPLEFT, customCPBarCtr[i][j]:GetParent(), TOPLEFT, mySpace + (j - 1) * (mySize + mySpace), (i-1) * mySize + i * mySpace)
				end
				customCPBarCtr[i][j]:SetDimensions(mySize, mySize)
				customCPBarCtr[i][j]:GetNamedChild("Circle"):SetDimensions(mySize, mySize)
				customCPBarCtr[i][j]:GetNamedChild("Icon"):SetDimensions(mySize * 0.73, mySize * 0.73)
			else
				if customCPBarCtr[i][j] ~= nil then customCPBarCtr[i][j]:SetHidden(true) end
			end
		end
	end
	if cpCustomBar then cp.refreshCustomBar() end
end

function CSPS.HbSize(forceResize)
	if not resizingNow and not forceResize then return end
	local barWindow = WINDOW_MANAGER:GetControlByName("CSPSCpHotbar")
	if not CSPS or not CSPS.savedVariables then return end
	local cpCustomBar = CSPS.savedVariables.settings.cpCustomBar
	
	-- Fitting the icons to the new width
	local mySize  = barWindow:GetWidth() * 0.075
	local mySpace = (barWindow:GetWidth() - 12 * mySize) / 17
	if cpCustomBar ~= 1 then
		mySize = barWindow:GetWidth() * 0.23
		mySpace = (barWindow:GetWidth() - 4 * mySize) / 5
	end
	CSPS.savedVariables.settings.hbsize = mySize
	
	-- Adjusting the height of the hotbar
	if cpCustomBar == 1 then	-- 1x12
		barWindow:SetHeight(mySize + 2 * mySpace)
	elseif cpCustomBar == 2 then	-- 3x4
		barWindow:SetHeight(3*mySize + 4*mySpace)
	else	-- 1x4
		barWindow:SetHeight(mySize + 2 * mySpace)
	end
	
	-- Adjusting the anchors of the icons
	customCPBarCtr = customCPBarCtr or {}
	for i=1,3 do
		customCPBarCtr[i] = customCPBarCtr[i] or {}
		for j=1,4 do
			if (cpCustomBar ~= 3 or i == 1) then
				if cpCustomBar == 1 then 
					customCPBarCtr[i][j]:SetAnchor(TOPLEFT, customCPBarCtr[i][j]:GetParent(), TOPLEFT, mySpace + ((i - 1) * 4  + j - 1) * (mySize + mySpace) + 2 * mySpace * (i - 1), mySpace)
				else
					customCPBarCtr[i][j]:SetAnchor(TOPLEFT, customCPBarCtr[i][j]:GetParent(), TOPLEFT, mySpace + (j - 1) * (mySize + mySpace), (i-1) * mySize + i * mySpace)
				end
				customCPBarCtr[i][j]:SetDimensions(mySize, mySize)
				customCPBarCtr[i][j]:GetNamedChild("Circle"):SetDimensions(mySize, mySize)
				customCPBarCtr[i][j]:GetNamedChild("Icon"):SetDimensions(mySize * 0.73, mySize * 0.73)
			end
		end
	end
end

function CSPS.HbResizing(control, isResizingNow)
	resizingNow = isResizingNow 
	control:GetNamedChild("BG"):SetHidden(not isResizingNow)
end

function CSPS.OnHotbarMoveStop() 
	CSPS.savedVariables.settings.hbleft = CSPSCpHotbar:GetLeft()
	CSPS.savedVariables.settings.hbtop = CSPSCpHotbar:GetTop()
end

local function onCPChange(_, result)
	if result > 0 then return end
	if waitingForCpPurchase then cspsPost(GS(CSPS_CPApplied)) waitingForCpPurchase = false end
	if CSPS.savedVariables.settings.cpCustomBar then cp.refreshCustomBar() end
end

function cp.setupZoHooks()	
	EVENT_MANAGER:RegisterForEvent(CSPS.name.."OnCpPurchase", EVENT_CHAMPION_PURCHASE_RESULT, onCPChange)

	ZO_PreHook("ZO_ChampionAssignableActionSlot_OnMouseClicked", function(control, mouseButton) 
		if GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then return end
		if mouseButton == 1 then 
			-- discipline, hbIndex, showInactive, funcIsSlotted, funcIsActive, funcValue, funcApply)
			local slotIndex = control.owner:GetSlotIndices()
			barIndex = math.floor((slotIndex - 1)/4) + 1
			slotIndex = (slotIndex-1)%4 + 1
			showHotbarSkillMenu(barIndex, slotIndex, control.owner.championSkillData and control.owner.championSkillData:GetId(), false, 
				function(skillId) -- slotted
					for _, slotData in pairs(control.owner.bar.slots) do
						if slotData and slotData.championSkillData and slotData.championSkillData:GetId() == skillId then return true end
						-- if skillId == GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION) then return true end
					end
				end,
				function(theSkillData) -- active
					return WouldChampionSkillNodeBeUnlocked(theSkillData.id, GetNumPointsSpentOnChampionSkill(theSkillData.id))
				end,
				function(theSkillData) -- value
					return GetNumPointsSpentOnChampionSkill(theSkillData.id)
				end,
				function(discipline, hbIndex, theSkillData) --apply
					control.owner:AssignChampionSkillToSlot(CHAMPION_DATA_MANAGER:GetChampionSkillData(theSkillData.id))
				end,
				function(discipline, hbIndex) -- remove
					control.owner:ClearSlot()
				end)
			return true
		end 
	end)

	SecurePostHook(CHAMPION_DATA_MANAGER, "OnDeferredInitialize", function()
		for i=1,3 do
			for j=1,4 do
				local mySlot = (i-1) * 4 + j			
				local myZoSlotCtr = WINDOW_MANAGER:GetControlByName(string.format("ZO_ChampionPerksActionBarSlot%s", mySlot))
				local myBtnCtr = myZoSlotCtr:GetNamedChild("Button")
				local myZoIcon = myZoSlotCtr:GetNamedChild("Icon")
				local myZoSlot = myBtnCtr.owner
				if myZoSlot ~= nil then 
					
					SecurePostHook(myZoSlot, "Refresh", function()
						if myZoSlot.championSkillData and cp.useCustomIcons then
							
							local skillData = cpTable[myZoSlot.championSkillData:GetId()]
							if skillData then myZoIcon:SetTexture(skillData.icon) end
						end
					end)
				end
			end
		end
	end)
end

function cp.refreshCustomBar()
	local cpCustomBar = CSPS.savedVariables.settings.cpCustomBar
	for i=1,3 do
		for j=1,4 do
			local mySlot = (i-1) * 4 + j
			local mySk = GetSlotBoundId(mySlot, HOTBAR_CATEGORY_CHAMPION)
			if (cpCustomBar ~= 3 or i == 1) then
				if mySk ~= nil and mySk ~= 0 then
					local skillData = cpTable[mySk]
					if cp.useCustomIcons and skillData.icon ~= nil then 
						if cpCustomBar then customCPBarCtr[i][j]:GetNamedChild("Icon"):SetTexture(skillData.icon) end
					else
						if cpCustomBar then customCPBarCtr[i][j]:GetNamedChild("Icon"):SetTexture("esoui/art/champion/champion_icon_32.dds") end
					end
					if cpCustomBar then 
						customCPBarCtr[i][j]:GetNamedChild("Icon"):SetHidden(false)
						customCPBarCtr[i][j]:GetNamedChild("Circle"):SetHandler("OnMouseEnter", function() CSPS.showCpTT(customCPBarCtr[i][j], skillData, GetNumPointsSpentOnChampionSkill(mySk), true, false) end)
					end
				else
					if cpCustomBar then 
						customCPBarCtr[i][j]:GetNamedChild("Icon"):SetHidden(true)
						customCPBarCtr[i][j]:GetNamedChild("Circle"):SetHandler("OnMouseEnter", function() end)
					end
				end
			end
		end
	end
end

function CSPS.showCpTT(control, skillData, overwriteValue, withTitle, hotbarExplain, offsetX)
	InitializeTooltip(InformationTooltip, control, LEFT, offsetX)
	local myId = skillData.id
	local myValue = overwriteValue or skillData.value
	
	local myTooltip = myId and GetChampionSkillDescription(myId)
	local myCurrentBonus = myValue and GetChampionSkillCurrentBonusText(myId, myValue) or ""
	local r,g,b =  ZO_NORMAL_TEXT:UnpackRGB()
	if withTitle then
		InformationTooltip:AddLine(zo_strformat("<<C:1>>", GetChampionSkillName(myId)), "ZoFontWinH2", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		if  cp.useCustomIcons and skillData.icon then InformationTooltip:AddLine(string.format("\n|t48:48:%s|t\n", skillData.icon), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) end
		ZO_Tooltip_AddDivider(InformationTooltip)
	end
	if myId then InformationTooltip:AddLine(myTooltip, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) end
	if myCurrentBonus ~= "" then InformationTooltip:AddLine(myCurrentBonus, "ZoFontGameBold", ZO_SUCCEEDED_TEXT.r, ZO_SUCCEEDED_TEXT.g, ZO_SUCCEEDED_TEXT.b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) end
	if hotbarExplain then 
		InformationTooltip:AddLine(string.format("%s\n\n|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t: %s\n|t26:26:esoui/art/miscellaneous/icon_rmb.dds|t: %s", GS(CSPS_Tooltip_CPBar), GS(SI_GAMEPAD_CHAMPION_QUICK_MENU), GS(SI_ABILITY_ACTION_CLEAR_SLOT)), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	else
		local myActualValue = GetNumPointsSpentOnChampionSkill(myId)
		if myValue and myValue ~= myActualValue then
			ZO_Tooltip_AddDivider(InformationTooltip)
			InformationTooltip:AddLine(zo_strformat(GS(CSPS_CPPCurrentlyApplied), myActualValue), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			if myActualValue ~= 0 then 
				local myActualBonus = GetChampionSkillCurrentBonusText(myId, myActualValue) or ""
				if myActualBonus ~= "" then InformationTooltip:AddLine(myActualBonus, "ZoFontGame", CSPS.colors.orange.r, CSPS.colors.orange.g, CSPS.colors.orange.b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) end
			end
		end
	end
end

function CSPS.initCPSideBar()
	local cpBarCtr = CSPSWindowCPSideBar
	cpBarCtr.initialized = true
	cpBarCtr.slots = {}
	local bars = cpBarCtr.slots
	local hbRearrange = {2, 3, 1}
	for i=1,3 do
		local discipline = hbRearrange[i]
		bars[discipline] = {}
		local slots = bars[hbRearrange[i]]
		
		for j=1,4 do
			local oneSlot = WINDOW_MANAGER:CreateControlFromVirtual(string.format("CSPSWindowCPSideBarSlot%s_%s", i, j), cpBarCtr, "CSPSCPSideBarPres")
			slots[j] = oneSlot
			if j == 1 and i == 1 then
				oneSlot:SetAnchor(TOP, cpBarCtr:GetNamedChild("ToggleLabels"), BOTTOM, 0, 10)
			elseif j == 1 then
				oneSlot:SetAnchor(TOP, bars[hbRearrange[i-1]][4], BOTTOM, 0, 45)
			else
				oneSlot:SetAnchor(TOP, slots[j-1], BOTTOM, 0, 10)
			end
						
			oneSlot.circle = oneSlot:GetNamedChild("Circle")
			oneSlot.icon = oneSlot:GetNamedChild("Icon")
			oneSlot.label = oneSlot:GetNamedChild("Label")
			oneSlot.circle:SetTexture(cpSlT[discipline])
			if discipline == 1 then oneSlot.circle:SetColor(0.8235, 0.8235, 0) end
			oneSlot.circle:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
			oneSlot.circle:SetHandler("OnReceiveDrag", function() CSPS.onCpHbIconReceive(discipline, j, oneSlot) end)
			oneSlot.circle:SetHandler("OnMouseUp", 
				function(_, button, upInside) WINDOW_MANAGER:SetMouseCursor(0)
					if not upInside then return end
					showHotbarSkillMenu(discipline, j, cpBar[discipline][j] and cpBar[discipline][j].id, false, cp.isInHb, function(skillData) return skillData.active end, nil, applyChampionSkillToHotbarProfile, CSPS.CpHbSkillRemove)					
				end)
			oneSlot.label:SetHandler("OnMouseUp", oneSlot.circle:GetHandler("OnMouseUp"))
			oneSlot.circle:SetHandler("OnDragStart", function(_, button) if button == 1 then WINDOW_MANAGER:SetMouseCursor(15)  CSPS.onCpHbIconDrag(discipline, j) end end)
		end
	end
	CSPS.showElement("cpsidebarlabels", CSPS.savedVariables.settings.cpSideBarLabels or false)
end

function cp.updateSidebarIcons(discipline)
	if not CSPSWindowCPSideBar.initialized then return end
	if not discipline then for i=1,3 do cp.updateSidebarIcons(i)  end return end
	
	local myBar = cpBar[discipline]
	for i=1, 4 do
		local myCtrl = CSPSWindowCPSideBar.slots[discipline][i]
		local skillData = myBar[i]
		if skillData then
			myCtrl.icon:SetHidden(false)
			if cp.useCustomIcons and skillData.icon then 
				myCtrl.icon:SetTexture(skillData.icon)
			else
				myCtrl.icon:SetTexture("esoui/art/champion/champion_icon_32.dds")
			end
			
			local myName = cpColors[discipline]:Colorize(zo_strformat("<<C:1>>", GetChampionSkillName(skillData.id)))
			myCtrl.label:SetText(myName)

			myCtrl.circle:SetHandler("OnMouseEnter", 
				function()  
					CSPS.showCpTT(myCtrl.circle, skillData, nil, true, true) 
				end) 
			myCtrl.circle:SetHandler("OnMouseExit", function () ZO_Tooltips_HideTextTooltip() end)
		else
			myCtrl.label:SetText("")
			myCtrl.icon:SetHidden(true)
			myCtrl.circle:SetHandler("OnMouseEnter", 
				function() 
					ZO_Tooltips_ShowTextTooltip(myCtrl.circle, RIGHT, 
					string.format("%s\n\n|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t: %s", GS(CSPS_Tooltip_CPBar), GS(SI_GAMEPAD_CHAMPION_QUICK_MENU))) 
				end)
			myCtrl.circle:SetHandler("OnMouseExit", function () ZO_Tooltips_HideTextTooltip() end)
		end
	end
end

function CSPS.onCpDrag(skillData)
	cpForHB = skillData
end

function CSPS.onCpHbIconDrag(discipline, icon)
	cpForHB = cpBar[discipline][icon] or false
end

function cp.updateSum(disciplineFilter)
	for discipline=1, 3 do
		if not disciplineFilter or disciplineFilter == discipline then cp.sums[discipline] = 0 end
	end
	for _, skillData in pairs(cpTable) do
		if not disciplineFilter or disciplineFilter == skillData.discipline then
			cp.sums[skillData.discipline] = cp.sums[skillData.discipline] + skillData.value
		end
	end
end

local function updateClusterSum(clusterData, disciplineFilter)
	if not clusterData then
		for discipline, listData in pairs(cp.sortedLists) do
			if not disciplineFilter or discipline == disciplineFilter then
				for _, skillData in pairs(listData) do
					updateClusterSum(skillData)
				end
			end
		end
		return
	end
	if not clusterData.cluster then return end
	clusterData.sum = 0
	for _, clusterSkill in pairs(clusterData.cluster) do
		clusterData.sum = clusterData.sum + clusterSkill.value
	end
end

cp.updateClusterSum = updateClusterSum

function CSPS.cpBtnPlusMinus(skillData, addMe, ctrl, alt, shift)
	local myShiftKey = CSPS.savedVariables.settings.jumpShiftKey or 7
	myShiftKey = myShiftKey == 7 and shift or myShiftKey == 4 and ctrl or myShiftKey == 5 and alt or false
	local oldValue = skillData.value
	if myShiftKey == true then addMe = addMe * 10 end
	local myValue = oldValue + addMe
	if myShiftKey == true and skillData.jumpPoints then
		for _, jumpPoint in pairs(skillData.jumpPoints) do
			if addMe > 0 then 
				if jumpPoint > oldValue then myValue = jumpPoint break end
			else 
				if jumpPoint < oldValue then myValue = jumpPoint else break end
			end
		end
		
	end	
	myValue = math.max(myValue, 0)
	myValue = math.min(myValue, skillData.maxValue)
	
	skillData.value = myValue
	
	if WouldChampionSkillNodeBeUnlocked(skillData.id, oldValue) ~= WouldChampionSkillNodeBeUnlocked(skillData.id, myValue) then 
		updateUnlock(skillData.discipline) 
		
	end
	
	cp.updateSum(skillData.discipline)
	cp.updateClusterSum(nil, skillData.discipline)
		
	cp.recheckHotbar(skillData.discipline)
	cp.updateSlottedMarks()
	
	CSPS.unsavedChanges = true
	changedCP = true
	CSPS.showElement("save", true)
	 CSPS.refreshTree()
end

function cp.resetTable(excludeDisciplines)
	excludeDisciplines = excludeDisciplines or {}
	if type(excludeDisciplines) ~= "table" then
		excludeDisciplines = {excludeDisciplines ~= 1, excludeDisciplines ~= 2, excludeDisciplines ~= 3}
	end
	-- Sets all entries to zero points and locked if not root
	for skillId, skillData in pairs(cpTable) do
		if not excludeDisciplines[skillData.discipline] then
			skillData.unlocked = IsChampionSkillRootNode(skillId) or skillData.type == 3 
			skillData.active = false
			skillData.value = 0	
		end
	end
end

function cp.readCurrent()
	cp.resetTable()
	for skillId, skillData in pairs(cpTable) do
		skillData.value = GetNumPointsSpentOnChampionSkill(skillId)
	end
	updateUnlock()
	cp.updateSum()
	updateClusterSum()
	
	for i=1, 3 do
		cpBar[i] = cpBar[i] or {}
		for j=1, 4 do
			local mySk = GetSlotBoundId((i-1) * 4 + j, HOTBAR_CATEGORY_CHAMPION)
			if mySk ~= 0 then 
				cpBar[i][j] = cpTable[mySk]
			else
				cpBar[i][j] = nil
			end
		end
	end
	
	cp.updateSidebarIcons()
	cp.updateSlottedMarks()
	changedCP = false
end

function cp.singleBarCompress(myBar)
	local cpBarComp = {}
	for j=1,4 do
		cpBarComp[j] = myBar[j] and myBar[j].id or "-"
	end
	cpBarComp = table.concat(cpBarComp, ",")
	return cpBarComp
end

function cp.hotBarCompress(myTable)
	local cpHbComp = {}
	for i=1, 3 do
		cpHbComp[i] = cp.singleBarCompress(myTable[i])
	end
	cpHbComp = table.concat(cpHbComp, ";")
	return cpHbComp
end

function cp.singleBarExtract(cpBarComp)

	local barTable = {}
	local auxHb1 = {SplitString(",", cpBarComp)}
	for j, v in pairs(auxHb1) do
		if v ~= "-" then 
			local cpEntry = cpTable[tonumber(v)] 
			barTable[j] = CanChampionSkillTypeBeSlotted(GetChampionSkillType(cpEntry.id)) and cpEntry or nil
		else 
			barTable[j] = nil 
		end		
	end	
	
	return barTable
end

function cp.hotBarExtract(cpHbComp, fillTable, excludeDisciplines)
	local cpHbTable = fillTable or {{},{},{}}
	cpHbComp = cpHbComp or ""
	if cpHbComp ~= "" and cpHbComp ~= "-" then
		local auxHb = {SplitString(";", cpHbComp)}
		for i=1, 3 do
			if not excludeDisciplines or not excludeDisciplines[i] then
				cpHbTable[i] = cp.singleBarExtract(auxHb[i])
			else
				cpHbTable[i] = {}
			end
		end
	end
	return cpHbTable
end

function cp.compress(myTable)
	local cpComp = {}
	for skillId, skillData in pairs(myTable) do
		if skillData.value > 0 then table.insert(cpComp, string.format("%s-%s", skillId, skillData.value)) end
	end
	cpComp = table.concat(cpComp, ";")
	cpComp = cpComp ~= "" and cpComp or "-"
	return cpComp
end

function cp.extract(cpComp, excludeDisciplines)
	cp.resetTable(excludeDisciplines)
	excludeDisciplines = type(excludeDisciplines) == "table" and excludeDisciplines or {}
	if cpComp ~= "" and cpComp ~= "-" then
		local myTable = {SplitString(";", cpComp)}
		for i, v in pairs(myTable) do
			local skillId, myValue = SplitString("-", v)
			skillId = tonumber(skillId)
			myValue = tonumber(myValue)
			local skillData = cpTable[skillId]
			if not excludeDisciplines[skillData.discipline] then skillData.value = math.min(myValue, skillData.maxValue) end
		end
		updateUnlock()	
	end
	cp.updateSum()
	updateClusterSum()
end

local function cpRespecNeeded(applyCPc)
	applyCPc = applyCPc or CSPS.applyCPc
	-- Check if a respec is needed for the current cp-build
	local respecNeeded = false
	local pointsNeeded = {0,0,0}
	local enoughPoints = {true, true, true}
	for skillId, skillData in pairs(cpTable) do
		if applyCPc[skillData.discipline] and GetNumPointsSpentOnChampionSkill(skillId) < skillData.value then pointsNeeded[skillData.discipline] = pointsNeeded[skillData.discipline] + skillData.value - GetNumPointsSpentOnChampionSkill(skillId) end
	end
	local changesNeeded = false
	for i=1,3 do
		if pointsNeeded[i] > 0 then changesNeeded = true end
		if pointsNeeded[i] > GetNumUnspentChampionPoints(GetChampionDisciplineId(i)) then respecNeeded = true end
		if pointsNeeded[i] > GetNumSpentChampionPoints(GetChampionDisciplineId(i)) + GetNumUnspentChampionPoints(GetChampionDisciplineId(i)) then enoughPoints[i] = false end
	end
	return respecNeeded, enoughPoints, pointsNeeded, changesNeeded
end

local function anyHbChanges(hotbarsOnly)
	for discipline = 1,3 do
		if not hotbarsOnly or #hotbarsOnly == 0 or hotbarsOnly[discipline] then
			local barTable = cpBar[discipline] or {}
			for slotIndex=1,4 do
				local mySlot = (discipline-1) * 4 + slotIndex
				local currentSkill = GetSlotBoundId(mySlot, HOTBAR_CATEGORY_CHAMPION)
				local addonSkill = barTable[slotIndex] and barTable[slotIndex].id or 0
				if addonSkill ~= currentSkill then return true	end
			end
		end
	end
	return false
end

function cp.applyGo(skipDiag, noHotbars, applyCPc)
	applyCPc = applyCPc or CSPS.applyCPc
	-- Do I have enough points, do I need to respec, do I need points at all?
	local respecNeeded, enoughPoints, pointsNeeded, changesNeeded = cpRespecNeeded()
	if hf.anyEntryFalse(enoughPoints) then 
		ZO_Dialogs_ShowDialog(CSPS.name.."_OkDiag", {},  {mainTextParams = {GS(CSPS_MSG_CpPointsMissing)}, titleParams = {GS(CSPS_MSG_CpPurchTitle)}})
		return 
	end
	if not changesNeeded and not anyHbChanges() then cspsPost(GS(CSPS_CPNoChanges)) return end
	if respecNeeded and GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) < GetChampionRespecCost() then
		ZO_Dialogs_ShowDialog(CSPS.name.."_OkDiag", {},  {mainTextParams = {GS(SI_TRADING_HOUSE_ERROR_NOT_ENOUGH_GOLD)}, titleParams = {GS(CSPS_MSG_CpPurchTitle)}})		
		return 
	end
	local myDisciplines = {GS(CSPS_MSG_CpPurchChosen)}
	for i=1,3 do
		if applyCPc[i] then table.insert(myDisciplines, zo_strformat(" |t24:24:<<1>>|t |c<<2>><<3>>: <<4>>|r", CSPS.cpColTex[i], cpColors[i]:ToHex(), GetChampionDisciplineName(GetChampionDisciplineId(i)), pointsNeeded[i])) end
	end
	table.insert(myDisciplines, " ")
	local myCost = respecNeeded and GetChampionRespecCost() or 0
	table.insert(myDisciplines, zo_strformat(GS(CSPS_MSG_CpPurchCost), myCost))
	table.insert(myDisciplines, " ")
	table.insert(myDisciplines, GS(CSPS_MSG_CpPurchNow)) 
	myDisciplines = table.concat(myDisciplines, "\n")

	if not skipDiag or myCost > 0 then
		ZO_Dialogs_ShowDialog(CSPS.name.."_OkCancelDiag", 
			{returnFunc = function() cp.applyConfirm(respecNeeded, nil, noHotbars) end},  
			{mainTextParams = {myDisciplines}, titleParams = {GS(CSPS_MSG_CpPurchTitle)}})
	else
		cp.applyConfirm(respecNeeded, nil, noHotbars) 
	end
end

function cp.applyConfirm(respecNeeded, hotbarsOnly, noHotbars, applyCPc)
	applyCPc = applyCPc or CSPS.applyCPc
	-- Did a general check for respeccing before the dialog - hotbarsOnly as an array containing booleans for each hotbar
	if hotbarsOnly and not anyHbChanges(hotbarsOnly) then return end
	PrepareChampionPurchaseRequest(respecNeeded)
	local changeValues = hotbarsOnly == nil
	if changeValues then
		for skillId,skillData in pairs(cpTable) do
			if respecNeeded or GetNumPointsSpentOnChampionSkill(skillId) < skillData.value then 
				if applyCPc[skillData.discipline] then AddSkillToChampionPurchaseRequest(skillId, skillData.value) end
			end
		end
	end
	hotbarsOnly = hotbarsOnly or {}	
	local unslottedSkills = {}
	if not noHotbars then
		for discipline, singleBar in pairs(cpBar) do
			if (applyCPc[discipline] and #hotbarsOnly == 0) or hotbarsOnly[discipline] == true then
				local skToSlot = {}
				for slotIndex=1, 4 do
					local hbSkill = singleBar[slotIndex]
					if hbSkill then skToSlot[hbSkill.id] = true end
				end
				for slotIndex=1, 4 do
					local hbSkill = singleBar[slotIndex]
					if hbSkill then
						if (not changeValues and not WouldChampionSkillNodeBeUnlocked(hbSkill.id, GetNumPointsSpentOnChampionSkill(hbSkill.id))) or (changeValues and not WouldChampionSkillNodeBeUnlocked(hbSkill.id, hbSkill.value)) then 
							table.insert(unslottedSkills, hbSkill)
							hbSkill = nil
						end
					else
						local previousSkillId = GetSlotBoundId((discipline-1) * 4 + slotIndex, HOTBAR_CATEGORY_CHAMPION)
						if previousSkillId ~= 0 and not skToSlot[previousSkillId] and 
							((not changeValues and WouldChampionSkillNodeBeUnlocked(previousSkillId, GetNumPointsSpentOnChampionSkill(previousSkillId))) or
							(changeValues and cpTable[previousSkillId].active)) then 
								hbSkill = cpTable[previousSkillId]
						end
					end	
					AddHotbarSlotToChampionPurchaseRequest((discipline-1) * 4 + slotIndex, hbSkill and hbSkill.id or nil)
				end
			end
		end
	end
	local result = GetExpectedResultForChampionPurchaseRequest()
    if result ~= CHAMPION_PURCHASE_SUCCESS then  -- Show error on fail - show dialog only if not in hotbar only mode
        if #hotbarsOnly == 0 then 
				ZO_Dialogs_ShowDialog(CSPS.name.."_OkDiag", {},  {mainTextParams = {GS("SI_CHAMPIONPURCHASERESULT", result)}, titleParams = {GS(CSPS_MSG_CpPurchTitle)}})
			else
				cspsPost(GS("SI_CHAMPIONPURCHASERESULT", result))
		end
        return
    end
	
	waitingForCpPurchase = true
	
	--if not noHotbars then --for troubleshooting the sendrequest might be left out at this point
		SendChampionPurchaseRequest()
		local confirmationSound
		if respecNeeded then
			confirmationSound = SOUNDS.CHAMPION_RESPEC_ACCEPT
		else
			confirmationSound = SOUNDS.CHAMPION_POINTS_COMMITTED
		end
		PlaySound(confirmationSound)
	--end
	changedCP = false
	zo_callLater(function()  CSPS.refreshTree() end, 1000)
	if #unslottedSkills > 0 then
		cspsPost(GS(CSPS_MSG_Unslotted))
		for  _, skillData in pairs(unslottedSkills) do
			cspsPost(cpColors[skillData.discipline]:Colorize(zo_strformat(" - <<C:1>>", GetChampionSkillName(skillData.id))), true)
		end
	end
end

local function cpFastestWays(myCpId)
	local passedCPs = {}
	local fastestWay = 42000
	local myPaths = {}
	local function checkPathPoint(pointCPID, myPath)
		if not DoesChampionSkillHaveJumpPoints(pointCPID) then return end
		local _, unlockPoints = GetChampionSkillJumpPoints(pointCPID)
		if cpTable[pointCPID].value >= unlockPoints then unlockPoints = 0 end
		myPath.points = myPath.points + unlockPoints
		myPath.checked[pointCPID] = true
		table.insert(myPath.steps, pointCPID)
		if IsChampionSkillRootNode(pointCPID) then -- stop at active
			fastestWay = math.min(fastestWay, myPath.points)
			table.insert(myPaths, myPath)
		else
			for _, linkedId in pairs({GetChampionSkillLinkIds(pointCPID)}) do
				if myPath.checked[linkedId] == nil then
					local newPath = {
						points = myPath.points,
						checked = {},
						steps = {},
					}
					for checkedCP, checkedBoolean in pairs(myPath.checked) do
						newPath.checked[checkedCP] = checkedBoolean
					end
					for stepIndex, stepCP in ipairs(myPath.steps) do
						newPath.steps[stepIndex] = stepCP
					end
					checkPathPoint(linkedId, newPath)
				end
			end
		end
	end
	local myPath = {
		points = 0,
		checked = {},
		steps = {},
	}
	checkPathPoint(myCpId, myPath)
	
	table.sort(myPaths, function(a,b) return a.points < b.points end)
	
	return myPaths
end

cp.cpFastestWays = cpFastestWays

local function showFastestCPWays(myCpId)
	local sortedPaths = cpFastestWays(myCpId)
	local allPaths = {}
	for i=1, 4 do
		if sortedPaths[i] == nil then break end
		local v = sortedPaths[i]
		table.insert(allPaths, zo_strformat(GS(CSPS_MSG_CPPathOpt), cpColors[cpTable[myCpId].discipline]:ToHex(), i, v.points)..":")
		local myPathNames = {}
		for j=#v.steps, 1, -1 do
			table.insert(myPathNames, zo_strformat("<<C:1>>", GetChampionSkillName(v.steps[j])))
		end
		table.insert(allPaths, table.concat(myPathNames, " → "))
	end
	return table.concat(allPaths, "\n")
end

function cp.showUnlockMenu(myCpId)
	
	local sortedPaths = cpFastestWays(myCpId)
	if #sortedPaths == 0 then return end
	ClearMenu()
	local myColor = cpColors[cpTable[myCpId].discipline]
	for i, v in pairs(sortedPaths) do
		if i > 5 then break end
		AddCustomMenuItem(zo_strformat(GS(CSPS_MSG_CPPathOpt), myColor:ToHex(), i, v.points), function()
			for _, stepCP in pairs(v.steps) do
				local _, unlockPoints = GetChampionSkillJumpPoints(stepCP)
				cpTable[stepCP].value = math.max(cpTable[stepCP].value or 0, unlockPoints)
			end
			cp.updateUnlock()
			
			cp.updateSum()
			cp.recheckHotbar()

			cp.updateSlottedMarks()
			cp.updateClusterSum()
			CSPS.refreshTree()
		end)
		local myPathNames = {}
		for j=#v.steps, 1, -1 do
			local skillName = zo_strformat("<<C:1>>", GetChampionSkillName(v.steps[j]))
			local _, unlockPoints = GetChampionSkillJumpPoints(v.steps[j])
			skillName = cpTable[v.steps[j]].value < unlockPoints and ZO_SELECTED_TEXT:Colorize(skillName) or skillName
			table.insert(myPathNames, skillName)
		end
		myPathNames = table.concat(myPathNames, " → ")
		AddCustomMenuTooltip(function(menuItem, inside)
			if not inside then ZO_Tooltips_HideTextTooltip() return end
			ZO_Tooltips_ShowTextTooltip(menuItem, LEFT, myPathNames)
		end)
	end
	ShowMenu()
end

function CSPS.cpClicked(control, skillData, mouseButton)
	if CSPS.inCpRemapMode and mouseButton == 1 then 
		CSPS.remapClicked(control, skillData, mouseButton)
		return
	end
	if mouseButton == 2 then
		if skillData.unlocked then return end
		local myPaths = showFastestCPWays(skillData.id)
		ZO_Tooltips_ShowTextTooltip(control, RIGHT, zo_strformat(GS(CSPS_MSG_CPPaths), GetChampionSkillName(skillData.id), myPaths))
	end
end

function CSPS.checkCpOnClose()
	if not changedCP or CSPS.savedVariables.settings.suppressCpNotSaved then return end
	cspsPost(GS(CSPS_MSG_ApplyClosing))
	
end

