local RegisterForEvent = sidWarTools.RegisterForEvent
local UnregisterForEvent = sidWarTools.UnregisterForEvent
local Objectives = sidWarTools.Objectives

local function InitializeObjectivesTab()
	Objectives:BuildLocationList()
	WORLD_MAP_INFO.modeBar:Add(SI_MAPFILTER1, { Objectives.fragment },  {
		normal = "EsoUI/Art/MainMenu/menuBar_ava_up.dds",
		pressed = "EsoUI/Art/MainMenu/menuBar_ava_down.dds",
		highlight = "EsoUI/Art/MainMenu/menuBar_ava_over.dds",
	})
end

local function IsCampaignStateInitialized()
	return GetNumKeeps() > 0
end

local function Initialize(saveData)
	Objectives.saveData = saveData
	if(saveData.mapObjectivesTab) then
		if(IsCampaignStateInitialized()) then
			InitializeObjectivesTab()
		else
			local eventHandle = ""
			eventHandle = RegisterForEvent(EVENT_CAMPAIGN_STATE_INITIALIZED, function()
				UnregisterForEvent(EVENT_CAMPAIGN_STATE_INITIALIZED, eventHandle)
				InitializeObjectivesTab()
			end)
		end
	end
end

sidWarTools.InitializeMapObjectivesTab = Initialize
