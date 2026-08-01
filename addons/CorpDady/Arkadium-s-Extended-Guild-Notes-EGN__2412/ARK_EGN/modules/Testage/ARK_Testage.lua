---------------------------------------------------------
--	ARKadium's Extended Guild Notes test file  		    -
--	Written by @Carter_DC (EU) / coirier.rom1@gmail.com -
--------------------------------------------------------- 




ARK_EGN              	= ARK_EGN or {}
local EGN 			 	= ARK_EGN
EGN.Testage		 		= ARK_EGN.Testage or{}
local Testage			= ARK_EGN.Testage
Testage.sVars			= {}
Testage.savedVarsVersion= 1
Testage.default			= {

}



do

	function Testage.Initialize()
		--loads saved variables from file or default
		Testage.sVars = ZO_SavedVars:NewAccountWide( "ARK_EGN_SavedVariables", Testage.savedVarsVersion, "Testage", Testage.default )
		
		Testage.Disciplines = {
			[1] = { index = 4, name =  "", skills = {},}, --Destrier
			[2] = { index = 3, name =  "", skills = {},}, --Dame
			[3] = { index = 2, name =  "", skills = {},}, --Seigneur
			[4] = { index = 1, name =  "", skills = {},}, --Tour
			[5] = { index = 9, name =  "", skills = {},}, --Amant
			[6] = { index = 8, name =  "", skills = {},}, --Ombre
			[7] = { index = 7, name =  "", skills = {},}, --apprentis
			[8] = { index = 6, name =  "", skills = {},}, --atronach
			[9] = { index = 5, name =  "", skills = {},}, --rituel
		}
		--initialize settings
		
		--intialize ui
		local testageTLC = WINDOW_MANAGER:GetControlByName("ARK_EGN_TESTAGE")
		local fragment = ZO_HUDFadeSceneFragment:New(testageTLC)
		CHAMPION_PERKS_SCENE:AddFragment(fragment)
		
		zo_callLater(function() EGN.Debug( "Testage","Module Loaded" ) end, 2600)
	end

	
	function Testage.Test()
		EGN.Debug( "Testage.Test", "Function" )	
	end

	function Testage.Export()
		EGN.Debug( "Testage.Export", "Function" )	
		
		if (SCENE_MANAGER.currentScene.name ~= "championPerks") then
			EGN.Msg2Chat( EGN.Colorize("Vous devez ouvrir l'interface des Points Champion") )
			return
		end
		
		local totalCPs = 0
		
		if not IsChampionSystemUnlocked() then
			EGN.Msg2Chat(EGN.Colorize("No CPs."))
			return
		end

		for i, discipline in pairs (Testage.Disciplines) do
			
			discipline.name = zo_strformat("<<A:1>>.", GetChampionDisciplineName(discipline.index))
			--EGN.Debug(discipline.name,"Discipline")
			local skills = {}
			for skillIndex = 1, GetNumChampionDisciplineSkills() do
									
				local pointsSpent = GetNumPointsSpentOnChampionSkill(discipline.index, skillIndex)
				local skillUnlockLevel = GetChampionSkillUnlockLevel(discipline.index, skillIndex)
				
				if skillUnlockLevel then
					--skill is a passive
					--EGN.Debug("passive", GetChampionSkillName(skillIndex))
				else
					table.insert(skills, {name = zo_strformat("<<1>>", GetChampionSkillName(discipline.index, skillIndex)), cps = pointsSpent})
					totalCPs = totalCPs + pointsSpent
				end
				
				Testage.Disciplines[i].skills = skills
				
			end
		end	
			
		Testage.CreateDumpString()
			
	end

	
	function Testage.CreateDumpString()
		
		local crlf = string.char(13,10) -- chariot return + line feed
		local skillsString = ""
		
		local dumpString = string.format("%s [b]%s (%s)[/b]%s", "Points Champion de", GetUnitName('player'), GetDisplayName(),crlf )
		dumpString = string.format("%s [b]%s - %s %s - %s[/b]%s%s", dumpString, zo_strformat("<<1>>", GetRaceName(0, GetUnitRaceId('player'))), zo_strformat("<<1>>", GetUnitClass('player')), Testage.GetSpe(), Testage.GetRole(), crlf,crlf) 
		
		--guerrier
		dumpString = string.format("%s%s ", dumpString,"[img size=18x18]http://s3.amazonaws.com/s3.mmoguildsites.com/s3/gallery_images/998813/original.png?1520422968[/img]")
		dumpString = string.format("%s%s%s", dumpString, "[size=16][color=#d94e2a][u][b]LE GUERRIER[/b][/u][/color][/size]", crlf)
		dumpString = string.format("%s%s%s", dumpString, "[spoiler][color=#d94e2a] ➤ Le Destrier[/color]", crlf)
		skillsString = Testage.GetSkillsString(Testage.Disciplines[1].skills)
		dumpString = string.format("%s%s", dumpString, skillsString)
		
		dumpString = string.format("%s%s%s", dumpString, "[color=#d94e2a] ➤ La Dame[/color]", crlf)
		skillsString = Testage.GetSkillsString(Testage.Disciplines[2].skills)
		dumpString = string.format("%s%s", dumpString, skillsString)		
		
		dumpString = string.format("%s%s%s", dumpString, "[color=#d94e2a] ➤ Le Seigneur[/color]", crlf)
		skillsString = Testage.GetSkillsString(Testage.Disciplines[3].skills)
		dumpString = string.format("%s%s%s", dumpString, skillsString, "[/spoiler]")

		--voleur
		dumpString = string.format("%s%s ", dumpString,"[img size=18x18]http://s3.amazonaws.com/s3.mmoguildsites.com/s3/gallery_images/998814/original.png?1520422969[/img]")
		dumpString = string.format("%s%s%s", dumpString, "[size=16][color=#87b93c][u][b]LE VOLEUR[/b][/u][/color][/size]", crlf)
		dumpString = string.format("%s%s%s", dumpString, "[spoiler][color=#87b93c] ➤ La Tour[/color]", crlf)
		skillsString = Testage.GetSkillsString(Testage.Disciplines[4].skills)
		dumpString = string.format("%s%s", dumpString, skillsString)
		
		dumpString = string.format("%s%s%s", dumpString, "[color=#87b93c] ➤ L'Amant[/color]", crlf)
		skillsString = Testage.GetSkillsString(Testage.Disciplines[5].skills)
		dumpString = string.format("%s%s", dumpString, skillsString)		
		
		dumpString = string.format("%s%s%s", dumpString, "[color=#87b93c] ➤ L'Ombre[/color]", crlf)
		skillsString = Testage.GetSkillsString(Testage.Disciplines[6].skills)
		dumpString = string.format("%s%s%s", dumpString, skillsString, "[/spoiler]")

		--mage
		dumpString = string.format("%s%s ", dumpString,"[img size=18x18]http://s3.amazonaws.com/s3.mmoguildsites.com/s3/gallery_images/998815/original.png?1520422970[/img]")
		dumpString = string.format("%s%s%s", dumpString, "[size=16][color=#3dabea][u][b]LE MAGE[/b][/u][/color][/size]", crlf)
		dumpString = string.format("%s%s%s", dumpString, "[spoiler][color=#3dabea] ➤ L'Apprenti[/color]", crlf)
		skillsString = Testage.GetSkillsString(Testage.Disciplines[7].skills)
		dumpString = string.format("%s%s", dumpString, skillsString)
		
		dumpString = string.format("%s%s%s", dumpString, "[color=#3dabea] ➤ L'Atronach[/color]", crlf)
		skillsString = Testage.GetSkillsString(Testage.Disciplines[8].skills)
		dumpString = string.format("%s%s", dumpString, skillsString)		
		
		dumpString = string.format("%s%s%s", dumpString, "[color=#3dabea] ➤ Le Rituel[/color]", crlf)
		skillsString = Testage.GetSkillsString(Testage.Disciplines[9].skills)
		dumpString = string.format("%s%s%s", dumpString, skillsString, "[/spoiler]")		
		
		
		local editWindow = WINDOW_MANAGER:GetControlByName("ARK_EGN_EDIT")
		local title = WINDOW_MANAGER:GetControlByName("ARK_EGN_EDITTitle")
		title:SetText("CTRL+C POUR COPIER")
		local editControl = WINDOW_MANAGER:GetControlByName("ARK_EGN_EDIT_Edit")
		editControl:SetText(dumpString)
		
		editControl:SetEditEnabled(false)
		editControl:SelectAll()
		
		editWindow:SetHidden(false)
		editControl:TakeFocus()
		
	end
	
	function Testage.GetSpe()
		local spe = ""
		
		local health = GetPlayerStat(STAT_HEALTH_MAX)
		local stam = GetPlayerStat(STAT_STAMINA_MAX)
		local mana = GetPlayerStat(STAT_MAGICKA_MAX)
		
		if (stam > mana) and (stam > health) then
			spe = "Stam"		
		elseif (mana > stam) and (mana > health) then
			spe = "Magie"
		else
			spe = "Santé"
		end
		
		return spe
	end
	
	function Testage.GetRole()
		local role = ""
		local isDps, isHealer, isTank = GetPlayerRoles()

		if isTank then
			role = "Tank"
		elseif isHealer then
			role = "Healer"
		else
			role = "DD"
		end
	
		return role
	end

	function Testage.GetSkillsString(skills)
		local crlf = string.char(13,10) -- chariot return + line feed
		local skillsString = "[list]"
		table.sort(skills, Testage.SortByName)
		for i, skill in pairs (skills) do
			if skill.cps == 0 then
				skillsString = string.format("%s%s %s : %d%s", skillsString, "[*]", skill.name, 0, crlf)
			else
				skillsString = string.format("%s%s [b]%s : %d[/b]%s", skillsString, "[*]", skill.name, skill.cps, crlf)
			end
		end
		
		skillsString = string.format("%s%s%s", skillsString, "[/list]", crlf)
		--EGN.Debug(skillsString,"skillsString")
		return skillsString
	end
	
	function Testage.SortByName(entry1, entry2)
		return entry1.name < entry2.name
	end
	
	
	function Testage.OnEffectivelyShown(control)
		--EGN.Debug("OnEffectivelyShown", "Function")
		myButtonGroup = {
			{
				name = "Exporter",
				keybind = "SI_BINDING_NAME_ARK_EGN_CPS_EXPORT",
				callback = function() Testage.Export() end,
				visible = function() return (SCENE_MANAGER.currentScene.name == "championPerks") end,
			},
			alignment = KEYBIND_STRIP_ALIGN_CENTER,
		}
		KEYBIND_STRIP:AddKeybindButtonGroup(myButtonGroup)		
	end
	
end

SLASH_COMMANDS["/ark_testage"] = Testage.Test 

--[[

GetGroupMemberRoles(string unitTag)
Returns: boolean isDps, boolean isHealer, boolean isTank

GetClassName(number Gender gender, number classId)
Returns: string className

GetRaceName(number Gender gender, number raceId)
Returns: string raceName

]]--


--[[
[color=#dc6733][u][b]LE GUERRIER[/b][/u][/color]
[color=#dc6733] ➤ Le Destrier[/color]
[list]
[*] Bouclier anti-sorts 0
[*] [b]Cuirassé 56[/b]
[*] Spécialisation armure moyenne 0
[*] Résistant 0[/list]

[color=#dc6733] ➤ La Dame[/color]

[color=#dc6733] ➤ Le Seigneur[/color]



[color=#c9e360][u][b]LE VOLEUR[/b][/u][/color]


[color=#52c7ef][u][b]LE MAGE[/b][/u][/color]

]]--


--[[
EGN.GROUP_MEMBER_LIST = ZO_GroupListList

	--test
	--ZO_GroupList:SetHandler("OnEffectivelyShown", function() EGN.GroupPanelShown() end)
	EGN.PostHook("RefreshData", EGN.UpdateGroupList, "ZO_GroupList")

function EGN.GroupPanelShown()
	--EGN.Debug("shown","group panel")
	--EGN.UpdateGroupList()
end

function EGN.UpdateGroupList()
	EGN.Debug("UpdateGroupList","Function")
	
	local testControl = WINDOW_MANAGER:GetControlByName("ZO_GroupListList1Row1")
	if not testControl then
		zo_callLater(function() EGN.UpdateGroupList() end, 100)
	end
	
	--local groupMemberList = ZO_GroupListList
	
	for _,row in pairs(ZO_GroupListList.activeControls) do
		local charName = row.dataEntry.data.characterName
		local UserId = row.dataEntry.data.displayName
				
		local labelText = row.characterNameLabel:GetText()
		EGN.Debug(labelText)
		if labelText:sub(1, 1) ~= "@" then
			row.characterNameLabel:SetText(UserId)
		end
	end
end



--parses a string of characters
--separator used is "#"
--populates extendedNote[] with all the substrings found 
function EGN.ParseNote(note)
	--EGN.Debug( "ParseNote", "Function" )
	
	local extendedNote = {}
	local lastHashTagOffset = 1, nextHashTagOffset, index
	index = 0
	nextHashTagOffset = string.find(note, "#",lastHashTagOffset+1)
	
	while nextHashTagOffset do
		index = index + 1
		extendedNote[index] = string.sub(note, lastHashTagOffset+1, nextHashTagOffset-1)
		--EGN.Debug(ARK_EGN.note[index],"ARK_EGN.note[index]")
		lastHashTagOffset = nextHashTagOffset
		nextHashTagOffset = string.find(note, "#",lastHashTagOffset+1)		
	end
	
	return extendedNote
	
end

]]--
