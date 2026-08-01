-- Kindler Beggar Liar Thief, and Elder Scrolls Online add-on by katkat42
-- This add-on is for compulsive achievement hunters. It detects your current
-- zone, and tells you whether you have completed the activities in that zone
-- towards the following achievements:
-- Lightbringer
-- Give to the Poor
-- I Like M'aiq
-- Crime Pays

if not KBLT then KBLT = {} end
KBLT.name = "Kindler Beggar Liar Thief"
KBLT.author = "katkat42 |c2046e5sshogrin|r"
KBLT.version = "1.2"
KBLT.variableVersion = 2

KBLT.data = {}
KBLT.data.kindler = {}
KBLT.data.beggar = {}
KBLT.data.liar = {}
KBLT.data.thief = {}

KBLT.defaults = {
	alpha = 50,
	x = 20,
	y = 20,
	highlight = "Completed",
	shown = true,
	apiVersion = GetAPIVersion(),
}
local strings

local function StripArticles(instring)
	local name = zo_strformat(SI_TOOLTIP_ITEM_NAME, instring)
	name = string.gsub(name,"^Les ","")
	name = string.gsub(name,"^Le ","")
	name = string.gsub(name,"^La ","")
	return name
end

function KBLT.FindAchievements()
	KBLT.data = {
	kindler = {ID = 873,},
	beggar = {ID = 871,},
	liar = {ID = 872,},
	thief = {ID = 869,},
}
for achiev, moredata in pairs(KBLT.data) do	
	KBLT.data[achiev].name = GetAchievementInfo(moredata.ID)
end

	for k, v in pairs(KBLT.data) do
		v.numZones = GetAchievementNumCriteria(v.ID)
		v.zones = {}
		for i = 1, v.numZones do
			local desc, done = GetAchievementCriterion(v.ID, i)
			if done == 1 then
				v.zones[desc] = true
			else
				v.zones[desc] = false
			end
		end
	end
end

function KBLT.UpdateZone()
	KBLT.zone = GetUnitZone('player')
	local myZone = StripArticles(KBLT.zone)

	KBLT.UpdateWindow(myZone)
end

local function AchievementProgress(event, achId)
	if achId ~= KBLT.data.kindler.ID and achId ~= KBLT.data.beggar.ID and achId ~= KBLT.data.liar.ID 
		and achId ~= KBLT.data.thief.ID then return end

	KBLT.FindAchievements()
	KBLT.UpdateZone()
end

local function OnLoad(event, name)
	if name ~= "KindlerBeggarLiarThief" then return end
	EVENT_MANAGER:UnregisterForEvent("KBLTInit", EVENT_ADD_ON_LOADED)
	
	KBLT.settings = ZO_SavedVars:NewAccountWide("KindlerBeggarLiarThief", KBLT.variableVersion, nil, KBLT.defaults)

	KBLT.lang = GetCVar("Language.2")
	if KBLT.lang ~= "en" then KBLT.lang = "en" end
	strings = KBLT.strings[KBLT.lang]

	KBLT.MakeMenu()
	
	ZO_CreateStringId("SI_BINDING_NAME_KBLT_TOGGLE", strings.KEYBIND_LABEL)

	KBLT.FindAchievements()
	KBLT.UpdateZone()

	EVENT_MANAGER:RegisterForEvent("KBLTZoneChange", EVENT_ZONE_CHANGED, KBLT.UpdateZone)
	EVENT_MANAGER:RegisterForEvent("KBLTAchUdpate", EVENT_ACHIEVEMENT_UPDATED, AchievementProgress)
end

EVENT_MANAGER:RegisterForEvent("KBLTInit", EVENT_ADD_ON_LOADED, OnLoad)