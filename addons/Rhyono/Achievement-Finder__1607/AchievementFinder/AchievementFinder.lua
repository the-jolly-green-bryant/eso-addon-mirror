AchievementFinder = {
Name = "AchievementFinder",
Author = "Rhyono",
Version = "1.23"}

local AF = AchievementFinder

AchievementFinder.Table = {}

local built = false
local PTS = GetWorldName() == "PTS"

--splits string into array
local function split_str(inputstr, sep)
	sep = sep or "%s"
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[#t+1] = str
	end
	return t
end

function AF.BuildTable()  
	for a=11,3250,1 do --needs increased every update
		local achieveName = select(1,GetAchievementInfo(a))
		if achieveName ~= "" then
			AchievementFinder.Table[#AchievementFinder.Table+1] = {a,achieveName}
		end	
	end
	built = true
end

function AF.FindAchieve(text)
	if built == false then
		AF.BuildTable()
	end
	
	CHAT_SYSTEM:AddMessage("Searching for \"" .. text .. "\" in achievements:")

	local searchstring = text:lower()
	local searcharray = split_str(searchstring)
	local terms = #searcharray	
	local total_results = 0
	
	for index,data in pairs(AchievementFinder.Table) do
		matched = true
		--check for first term
		if terms == 1 and string.find(data[2]:lower(), tostring(searcharray[1])) == nil then
			matched = false
		--check if there are additional terms to compare it against
		elseif terms > 1 then
			for a = 1, terms, 1 do
				if string.find(data[2]:lower(), tostring(searcharray[a])) == nil then
					matched = false
				end
			end
		end
		if matched then
			CHAT_SYSTEM:AddMessage((PTS and data[1] .. ': ' or '') .. GetAchievementLink(data[1],1))
			total_results = total_results+1
		end
	end

	CHAT_SYSTEM:AddMessage("Finished search. Total results: " .. total_results)
end

function AF.ShowAchieve(link)
	--Check if the achievement is still active
	local aid = GetAchievementIdFromLink(link)
	if select(1,GetCategoryInfoFromAchievementId(aid)) ~= nil then
		SCENE_MANAGER:ShowBaseScene()
		ACHIEVEMENTS:ShowAchievement(aid)
	else
		CHAT_SYSTEM:AddMessage("|cA00000This achievement is not visible in the achievements tab of the quest journal.|r")
	end	
end

function AF.CopyAchieve(link)
	CHAT_SYSTEM.textEntry:Open(GetAchievementIdFromLink(link))
	CHAT_SYSTEM.textEntry:SetCursorPosition(0)
end

-- borrowed from LootAlert, as the MM method was doubling up again
function AF.OverWriteLinkMouseUpHandler()
    local base = ZO_LinkHandler_OnLinkMouseUp
    ZO_LinkHandler_OnLinkMouseUp = function(link, button, control)
        base(link, button, control)

        if button ~= MOUSE_BUTTON_INDEX_RIGHT or GetLinkType(link) ~= LINK_TYPE_ACHIEVEMENT then
            return
        end

        if PTS then
			AddMenuItem("ID in Chat", function() AF.CopyAchieve(link) end)
		end			
		AddMenuItem("Show in Achievements", function() AF.ShowAchieve(link) end)
        ShowMenu(control)
    end
end

--Shows command usage
function AF.Help()
	CHAT_SYSTEM:AddMessage("Achievement Finder Command Usage")
	--Find Achievement
	CHAT_SYSTEM:AddMessage("Command: |cFF7700/findachieve|r or |cFF7700/findachievement|r")
	CHAT_SYSTEM:AddMessage("Purpose: Searches for achievements by name.")
	CHAT_SYSTEM:AddMessage("Usage: /findachieve <name>")
	CHAT_SYSTEM:AddMessage("Example: /findachieve reaper")
	--Show Achievement
	CHAT_SYSTEM:AddMessage("Right click achievement links for the option to show them in the achievements menu.")
end	

function AF.OnAddOnLoaded(event, addonName)
    if addonName ~= AchievementFinder.Name then return end
	
	AF.OverWriteLinkMouseUpHandler()
end	

SLASH_COMMANDS["/findachieve"] = AF.FindAchieve
SLASH_COMMANDS["/findachievement"] = AF.FindAchieve
SLASH_COMMANDS["/afhelp"] = AF.Help

EVENT_MANAGER:RegisterForEvent(AchievementFinder.Name, EVENT_ADD_ON_LOADED, AchievementFinder.OnAddOnLoaded)