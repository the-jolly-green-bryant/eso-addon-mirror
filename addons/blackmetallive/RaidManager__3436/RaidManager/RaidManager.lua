
RaidManager = {}

RaidManager.name = "RaidManager"

function RaidManager.Initialize()

end

function RaidManager.OnAddOnLoaded(event, addonName)
  if addonName == RaidManager.name then
    RaidManager.Initialize()
  end
end

function RaidManager.HideUI() 
	RaidManagerWindow:SetHidden(true)
end

function RaidManager.Generate() 

	ids = {1474, 1136, 1503, 1137, 1462, 1138, 1368, 1344, 1810, 1829, 1838, 2077, 2085, 2086, 2079, 2087, 2133, 2134, 2135, 2136, 2139, 2435, 2469, 2470, 2466, 2467, 2734, 2736, 2737, 2739, 2740, 2987, 3005, 3006, 3007, 3003, 3244, 3250, 3251, 3252, 3248}
	
	account = GetDisplayName();
	account = string.lower(account)
	
	cp = GetUnitChampionPoints("player")
	cp = cp + 1337

	text = "159753";
	
	text = text .. string.byte(string.sub(account, 2, 2))
	text = text .. string.byte(string.sub(account, 3, 3))
	text = text .. string.byte(string.sub(account, 4, 4))

	text = text .. "0123210"
	
	text = text .. cp
	
	text = text .. "0123210";
	
	for idCount = 1, #ids do
		
		local name, _, _, _, completed, _, _ = GetAchievementInfo(ids[idCount])
		
		if completed then
			text = text .. (ids[idCount] + 1337) .. "0123210"
		end
		
	end
	
	text = text .. "357951";
		
	RaidManagerWindowText:SetText(text)
	
end

SLASH_COMMANDS["/rm"] = function (extra)
  RaidManagerWindow:SetHidden(false)
end

SLASH_COMMANDS["/raidmanager"] = function (extra)
  RaidManagerWindow:SetHidden(false)
end

-- Init AddOn
EVENT_MANAGER:RegisterForEvent(RaidManager.name, EVENT_ADD_ON_LOADED, RaidManager.OnAddOnLoaded)