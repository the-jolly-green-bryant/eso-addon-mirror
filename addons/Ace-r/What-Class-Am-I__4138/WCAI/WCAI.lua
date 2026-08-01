WCAI = WCAI or {}
WCAI.name = "WCAI"
WCAI.version = "1.0"

WCAI.classes = {}

WCAI.race = ""

WCAI.names = {
	["1,1,1,"] = "Dragonknight",
	["1,1,2,"] = "Dragonerer",
	["1,1,3,"] = "Dragonblade",
	["1,1,4,"] = "Dragonden",
	["1,1,5,"] = "Dragonmancer",
	["1,1,6,"] = "Dragonplar",
	["1,1,117,"] = "Dragoncanist",
	["1,2,2,"] = "Sorcknight",
	["1,2,3,"] = "Nightknighterer",
	["1,2,4,"] = "Dragonsorcden",
	["1,2,5,"] = "Dragonmancererer",
	["1,2,6,"] = "Dragonplarerer",
	["1,2,117,"] = "Dragonsorcanist",
	["1,3,3,"] = "Nightknight",
	["1,3,4,"] = "Dragonbladeden",
	["1,3,5,"] = "Necrobladeknight",
	["1,3,6,"] = "Nightknightplar",
	["1,3,117,"] = "Dragonbladecanist",
	["1,4,4,"] = "Wardknight",
	["1,4,5,"] = "Necroknightden",
	["1,4,6,"] = "Dragonplarden",
	["1,4,117,"] = "Arcaknightden",
	["1,5,5,"] = "Necroknight",
	["1,5,6,"] = "Necroknightplar",
	["1,5,117,"] = "Dragonmancercanist",
	["1,6,6,"] = "Tempknight",
	["1,6,117,"] = "Arcaknightplar",
	["1,117,117,"] = "Arcaknight",
	["2,2,2,"] = "Sorcerer",
	["2,2,3,"] = "Sorcblade",
	["2,2,4,"] = "Sorcden",
	["2,2,5,"] = "Sorcmancer",
	["2,2,6,"] = "Sorcplar",
	["2,2,117,"] = "Sorcanist",
	["2,3,3,"] = "Nighterer",
	["2,3,4,"] = "Sorcbladeden",
	["2,3,5,"] = "Necrobladerer",
	["2,3,6,"] = "Nightplarerer",
	["2,3,117,"] = "Arcabladerer",
	["2,4,4,"] = "Warderer",
	["2,4,5,"] = "Sorcdenmancer",
	["2,4,6,"] = "Sorcdenplar",
	["2,4,117,"] = "Arcdenerer",
	["2,5,5,"] = "Necrerer",
	["2,5,6,"] = "Tempmancerer",
	["2,5,117,"] = "Necronisterer",
	["2,6,6,"] = "Templerer",
	["2,6,117,"] = "Templarcanisterer",
	["2,117,117,"] = "Arcanisterer",
	["3,3,3,"] = "Nightblade",
	["3,3,4,"] = "Nightden",
	["3,3,5,"] = "Nightmancer",
	["3,3,6,"] = "Nightplarerer",
	["3,3,117,"] = "Nightcanist",
	["3,4,4,"] = "Wardenblade",
	["3,4,5,"] = "Wardenblademancer",
	["3,4,6,"] = "Nightplarden",
	["3,4,117,"] = "Nightcanistden",
	["3,5,5,"] = "Necroblade",
	["3,5,6,"] = "Nightplarmancer",
	["3,5,117,"] = "Arcblademancer",
	["3,6,6,"] = "Tempblade",
	["3,6,117,"] = "Templarcanblade",
	["3,117,117,"] = "Arcblade",
	["4,4,4,"] = "Warden",
	["4,4,5,"] = "Wardmancer",
	["4,4,6,"] = "Wardplar",
	["4,4,117,"] = "Wardcanist",
	["4,5,5,"] = "Necroden",
	["4,5,6,"] = "Necrodenplar",
	["4,5,117,"] = "Wardcanistmancer",
	["4,6,6,"] = "Tempden",
	["4,6,117,"] = "Arcplarden",
	["4,117,117,"] = "Arcden",
	["5,5,5,"] = "Necromancer",
	["5,5,6,"] = "Necroplar",
	["5,5,117,"] = "Necrarcanist",
	["5,6,6,"] = "Templomancer",
	["5,6,117,"] = "Templomancercanist",
	["5,117,117,"] = "Arcamancer",
	["6,6,6,"] = "Templar",
	["6,6,117,"] = "Templarcanist",
	["6,117,117,"] = "Arcplar",
	["117,117,117,"] = "Arcanist"
}


function WCAI.OnLoaded(_, addonName)
    if addonName ~= WCAI.name then return end
    WCAI:Init()
end

function WCAI.OnPlayerLoaded()
end

function WCAI.OnStatsSceneShow(oldState, newState)
	if (newState == SCENE_SHOWN) then
		WCAI:SetClassNameInUI()
	end
end

function WCAI:Init()
	for i=1,3 do
		self.classes[i] = SKILLS_DATA_MANAGER:GetActiveClassSkillLine(i):GetClassId()
	end
	
	table.sort(self.classes)	
	
	self.race = GetUnitRace("player")
	
    SLASH_COMMANDS["/wcai"] = function (args)
		local className = self:GetClassName()
		local word = "a"
		if (string.sub(className, 1, 1) == "A") then word = "an" end
		local result = string.format("You are playing %s %s%s|r!", word, self:GetClassColour(), className)
		d(result)
    end
	
	SLASH_COMMANDS["/rl"] = function(a) ReloadUI() end

	local statsScene = SCENE_MANAGER:GetScene("stats")
	statsScene:RegisterCallback("StateChange", WCAI.OnStatsSceneShow)

    EVENT_MANAGER:UnregisterForEvent(WCAI.name, EVENT_ADD_ON_LOADED)
end

function WCAI:GetClassName()	
	local index = ""
	for i=1,3 do
		index = index .. self.classes[i] .. ","
	end
	
	return self.names[index]
end

function WCAI:GetClassColour()
	local x = 0
	for i=1,3 do
		x = x + self.classes[i]
	end
	
	local colours = { "d090b0", "a2eeed", "e6d944", "ac79f1", "79ee76" }
	x = math.fmod(x, table.getn(colours)) + 1
	return string.format("|c%s", colours[x])
end

function WCAI:SetClassNameInUI()
	local text = string.format("%s %s%s|r", self.race, self:GetClassColour(), self:GetClassName())
	ZO_StatsPanelTitleSectionRaceClass:SetText(text)
end

function WCAI:test(x,y,z)
	if (x == 7) then x = 117 end
	if (y == 7) then y = 117 end
	if (z == 7) then z = 117 end
	self.classes = {x,y,z}
	self:SetClassNameInUI()
end

EVENT_MANAGER:RegisterForEvent(WCAI.name, EVENT_ADD_ON_LOADED, WCAI.OnLoaded)
EVENT_MANAGER:RegisterForEvent(WCAI.name, EVENT_PLAYER_ACTIVATED, WCAI.OnPlayerLoaded)