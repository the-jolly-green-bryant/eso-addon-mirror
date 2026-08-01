MyAddon = {}

MyAddon.name = "LeaderboardHighlights"

local baseBackground = "EsoUI/Art/Contacts/social_list_bgStrip.dds"
local baseColour = {1,1,1,1}

local colours = 
{
	["PLAYER"] = {0,100,0,1},
	["FRIEND"] = {100,0,50,1},
	["GUILD"] = {40,70,100,1},
}

local function unpack(t)
	return t[1]/255, t[2]/255, t[3]/255
end

local function addHighlight(self, playerRelation, displayName)
	self:SetHidden(false)
	self:SetTexture("", true)
	self:SetColor(unpack(colours[playerRelation]))
end

local function removeHighlight(self)
	self:SetTexture(baseBackground, true)
	self:SetColor(unpack(baseColour))
end

local function isDisplayNameInGuild(displayName)
	for i = 1, 5 do
		if GetGuildMemberIndexFromDisplayName(GetGuildId(i), displayName)~= nil then
			return true
		end
	end
	return false
end
local i = 1

function MyAddon:Initialize()
	--SCENE_MANAGER:GetScene("leaderboards"):RegisterCallback("StateChange", setupHighlights)
	
end
 

function MyAddon.OnAddOnLoaded(event, addonName)

  if addonName == MyAddon.name then

    MyAddon:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(MyAddon.name, EVENT_ADD_ON_LOADED, MyAddon.OnAddOnLoaded)

--/script local UIElement = ZO_LeaderboardsListRow1Name local original = UIElement.SetText UIElement.SetText = function(...)d(...) original(...) d("A")end


-- This function is largely lifted from the ESOUI source code, with minor changes 
local original =  ZO_LeaderboardsManager_Shared.SetupLeaderboardPlayerEntry

ZO_LeaderboardsManager_Shared.SetupLeaderboardPlayerEntry = function(self, control, data)
    original(self, control, data)
        
    --Name
    local safeDisplayName = data.displayName ~= "" and data.displayName or GetString(SI_LEADERBOARDS_STAT_NOT_AVAILABLE)
    
    local isFriend = IsFriend(safeDisplayName)
    local isGuild = isDisplayNameInGuild(safeDisplayName)
    local isSelf = GetDisplayName() == safeDisplayName


    local bg = GetControl(control, "BG")
    if not bg then return end
    --Background
    if isSelf then
        addHighlight(bg, "PLAYER")
    elseif isFriend then
        addHighlight(bg, "FRIEND")
    elseif isGuild then
        addHighlight(bg, "GUILD")
    else
        removeHighlight(bg)

        local hidden = (data.index % 2) == 0
        bg:SetHidden(hidden)

    end
end
