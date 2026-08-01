SyliranasNewLifeTravel = {
    name            = "SyliranasNewLifeTravel",
    author          = "Sylirana",
    color           = "3366FF",
    menuName        = "Sylirana's New Life Travel",
}
SyliranasNewLifeTravel.savedVars = {
    firstLoad = true,
    accountWide = false,
}

function SyliranasNewLifeTravel.Colorize(text, color)
    if not color then color = SyliranasNewLifeTravel.color end
    text = string.format('|c%s%s|r', color, text)
    return text
end

-- % is not a typo: Used to escape '-'.

local wayshrines = {
	["Talk to Breda"] = 89,
	["speak with Breda"] = 89,
	["return to Breda"] = 89,
	["Alcaire Keep"] = 15,
	["Fish Boon Feast"] = 51,
	["Gentle%-Heart"] = 52,
	["Watch House Inn"] = 65,
	["Fish Stink"] = 65,
	["Ebony Flask"] = 67,
	["Hlaalu House"] = 67,
	["throw mud balls"] = 121,
	["Aubatha"] = -2,
	["failed to light"] = -2,
	["Cub's Tumble"] = 87,
	["Cub'Horker's Drop"] = 87,
	["Dead man's Fall"] = 90,
	["Stonetooth Bash"] = 181,
	["Tumira"] = 162,
	["lockpicks"] = 162,
	["War Orphan's Sojourn"] = -1,
}

local wayshrinesOL = {
	["to Petronius Galenus"] = 89,
	["Auridon"] = 174,
	["Reaper's March"] = 157,
	["Glenumbra"] = 5,
	["Bangkorai"] = 34,
	["Stonefalls"] = 73,
	["The Rift"] = 120,
}

function SyliranasNewLifeTravel.FindQuestWayshrine(questText, ol)
    if questText == nil then return end
	if not ol then
		for key, value in pairs(wayshrines) do
			if string.match(questText, key) then
				if value == -1 then
					return SyliranasNewLifeTravel.savedVars.warOrphanWayshrine
				elseif value == -2 then
					return SyliranasNewLifeTravel.savedVars.signalFireWayshrine
				else
					return value
				end
			end
		end
	else
		for key, value in pairs(wayshrinesOL) do
			if string.match(questText, key) then
				return value
			end
		end
	end
    return nil
end

local questNames = {
	"Castle Charm Challenge",
	"Fish Boon Feast",
	"Lava Foot Stomp",
	"Mud Ball Merriment",
	"Signal Fire Sprint",
	"Snow Bear Plunge",
	"Stonetooth Bash",
	"The Trial of Five-Clawed Guile",
	"War Orphan's Sojourn",
	"Old Life Observance"
}

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end


function SyliranasNewLifeTravel.GetQuestInfo()
    local count = GetNumJournalQuests()
    for i = 1, count do
        local name = GetJournalQuestName(i)
        if has_value(questNames, name) then
            local count = GetJournalQuestNumSteps(i)
            for j = 1, count do
                local function isEmpty(s)
                    return s == nil or s == ''
                end
                local journalText, _, _, hudText, _ = GetJournalQuestStepInfo(i, j)
                if isEmpty(hudText) then
                    return journalText, string.match("Old Life Observance", name)
                else
                    return hudText, string.match("Old Life Observance", name)
                end
            end
        end
    end
    return nil
end

function SyliranasNewLifeTravel.TravelToWayshrine()
    local questText, ol = SyliranasNewLifeTravel.GetQuestInfo()
    local wayshrineId = SyliranasNewLifeTravel.FindQuestWayshrine(questText, ol)
    if wayshrineId then
        local discovered, name = GetFastTravelNodeInfo(wayshrineId)
        if not discovered then
            d(name .. ' not discovered.')
            return
        else
            if SyliranasNewLifeTravel.savedVars.chatOutput == true then
                d('Teleporting to ' .. name)
            end
            FastTravelToNode(wayshrineId)
        end
    end
end

function SyliranasNewLifeTravel.OnFastTravelInteraction()
    if SyliranasNewLifeTravel.savedVars.automaticTraveling == true then
        SyliranasNewLifeTravel.TravelToWayshrine()
    end
end
EVENT_MANAGER:RegisterForEvent(SyliranasNewLifeTravel.name, EVENT_START_FAST_TRAVEL_INTERACTION, function(eventId, ...) SyliranasNewLifeTravel.OnFastTravelInteraction(...) end)

function SyliranasNewLifeTravel.OnAddOnLoaded(event, addonName)
    if addonName ~= SyliranasNewLifeTravel.name then return end
    EVENT_MANAGER:UnregisterForEvent(SyliranasNewLifeTravel.name, EVENT_ADD_ON_LOADED)
    SyliranasNewLifeTravel.savedVars = ZO_SavedVars:New("SyliranasNewLifeTravelSavedVariables", 1, nil, SyliranasNewLifeTravel.savedVars)
    SyliranasNewLifeTravel.LoadSettings()
end
EVENT_MANAGER:RegisterForEvent(SyliranasNewLifeTravel.name, EVENT_ADD_ON_LOADED, SyliranasNewLifeTravel.OnAddOnLoaded)