-- Research Timer 
-- Original AddOn by hisdad; Based on CRT by Ato
-- Updated by Fennek
-- v2

RT = {
	name = "ResearchTimer",
	font = "ZoFontGame",
	cmdsetup = "/rt",
	version = "v2.1.8",
	playername = "",
	Init_done = false,
	UI = {},
	options = {},
	SV={},
	debug = false
}

RT.UI.GRID_TLW = {}
RT.UI.GRID_BD = {}
RT.UI.GRID_WD = {}
RT.UI.GRID_BTN = {}
RT.SV.data = {}

function RT.Collect_Data()
	RT.Info_Research(CRAFTING_TYPE_BLACKSMITHING, 0)
	RT.Info_Research(CRAFTING_TYPE_CLOTHIER, 1)
	RT.Info_Research(CRAFTING_TYPE_WOODWORKING, 2)
	RT.Info_Research(CRAFTING_TYPE_JEWELRYCRAFTING, 3)
	if RT.debug then d("RT: Collected Data") end
end


function RT.Info_Research(craft_type,craft_id)
	local Simu_craft = 0
	local ResearchLines, ResearchTrait
	local MaxResearch = GetMaxSimultaneousSmithingResearch(craft_type)
	local nbtype = GetNumSmithingResearchLines(craft_type)

	RT.SV.data.Craft[RT.playername][craft_id] = {}
	RT.SV.data.Craft[RT.playername][craft_id].doing = {}
	for ResearchLines = 1, nbtype, 1 do
		local item_name, item_icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craft_type, ResearchLines)
		for ResearchTrait = 1, numTraits, 1 do
			local duration, timeRemaining = GetSmithingResearchLineTraitTimes(craft_type, ResearchLines, ResearchTrait)

			if (duration ~= nil and timeRemaining ~= nil) then
				Simu_craft = Simu_craft + 1


			local traitType, trait_description, _ = GetSmithingResearchLineTraitInfo(craft_type,ResearchLines,ResearchTrait)
			local _, trait_name, trait_icon, _, _, _, _ = GetSmithingTraitItemInfo(traitType+1)

			RT.SV.data.Craft[RT.playername][craft_id].doing[Simu_craft] = {}
			RT.SV.data.Craft[RT.playername][craft_id].doing[Simu_craft]["EndTimeStamp"] = GetTimeStamp() + timeRemaining
			RT.SV.data.Craft[RT.playername][craft_id].doing[Simu_craft]["Item_name"] = string.sub(zo_strformat("<<C:1>>",item_name), 1, 18)
			RT.SV.data.Craft[RT.playername][craft_id].doing[Simu_craft]["Item_icon"] = item_icon
			RT.SV.data.Craft[RT.playername][craft_id].doing[Simu_craft]["Trait_stone"] = zo_strformat("<<C:1>>",trait_name)
			RT.SV.data.Craft[RT.playername][craft_id].doing[Simu_craft]["Trait_icon"] = trait_icon
			RT.SV.data.Craft[RT.playername][craft_id].doing[Simu_craft]["Trait_description"] = zo_strformat("<<C:1>>",trait_description)
			RT.SV.data.Craft[RT.playername][craft_id].doing[Simu_craft]["Trait_name"]= zo_strformat("<<C:1>>",GetString("SI_ITEMTRAITTYPE",traitType))
			end
		end
	end
	RT.SV.data.Craft[RT.playername][craft_id].MaxResearch = MaxResearch
	RT.SV.data.Craft[RT.playername][craft_id].Simu_craft = Simu_craft
end



-- for each character, find the research completing soonest and set RT.SV.data.Craft[Char].shortest
function RT.Set_Shortest()
	local shortest, remaining
	for char,_ in pairs (RT.SV.data.Craft) do

		shortest = 9999999999
		for craft =0,2, 1 do
			for _,v in pairs (RT.SV.data.Craft[char][craft].doing) do
				remaining = v["EndTimeStamp"] - GetTimeStamp()
				if shortest > remaining
				then shortest = remaining
				end
			end
		end
		RT.SV.data.Craft[char].shortest = shortest
	end
end
function RT.Update()
	RT.GRID_Update(GetTimeStamp())
	RT.GRID_Sort()
end

function RT.UpdateOnTimer()
	if (RT.UI.GRID_TLW:IsHidden()) then return; end		-- Don't waste effort while its hidden.
	RT.Update()
end

function RT.Research_Changed(eventCode)  -- Triggered by Event, action is event code
		if RT.debug then
			local eventstr = "UNKNOWN EVENT"
			if eventCode == EVENT_SMITHING_TRAIT_RESEARCH_STARTED
			then eventstr = "EVENT_SMITHING_TRAIT_RESEARCH_STARTED"
			elseif eventCode == EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED
			then eventstr = "EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED"
			end
			d("RT: Research Change Event   " .. eventstr)
		end
		-- erase all data for this character
		RT.SV.data.Craft[RT.playername] = {}
		-- Collect new data
		RT.Collect_Data()

		if (RT.UI.GRID_WD[RT.playername] == nil) then
			RT.GRID_Create_Character(RT.playername)
		end
		RT.Set_Shortest()
		RT.UI.GRID_WD[RT.playername].label:SetText(string.upper(RT.playername)) -- remove highlighting
		RT.Update()
end



function RT.Activated()
	if RT.debug then d("RT: Player Activated")
	end
	RT.Collect_Data()		-- Collection of data is just NOT RELIABLE at load phase. Do it again
end

function RT.toggleGRID()
	if RT.Init_done then	-- block until fully setup, other hit nil variables
		if (RT.UI.GRID_TLW:IsHidden()) then
		RT.GRID_Sort()
		end
		SCENE_MANAGER:ToggleTopLevel(RT.UI.GRID_TLW)
	end

end

function RT.CommandText_setup(option)
    option = string.lower(option)
    RT.options =  string.match(option,"^(%S*)%s*(.-)$")
    -- d("RT.options:  ".. RT.options)
	if option == "" then
		RT.toggleGRID()
	elseif RT.options == "read" then		-- cause a reread of the data without sorting
	    d("RT: Running Collect_Data()")
		RT.Collect_Data()
	elseif RT.options == "debug" then
			if RT.debug
			then	d("debug off")
			else	d("debug on")
			end
			RT.debug = not RT.debug
	end     -- #RT.options

end

function RT.Init(_, addOnName)

	if(addOnName == RT.name) then
	  RT.playername = GetUnitName("player")

	    -- SavedVariables
	  RT.SV.data = ZO_SavedVars:NewAccountWide(RT.name, 1, nil, nil )
	  if RT.SV.data.Craft == nil
		then RT.SV.data.Craft = {}
			 RT.SV.data.Craft[RT.playername]= {}
		else RT.GRID_Remove_Expired()
	  end
	  RT.InitialiseLanguage()

	    -- Slash commands
	  SLASH_COMMANDS[RT.cmdsetup] = RT.CommandText_setup


	    -- Create Keybinds
	  ZO_CreateStringId("SI_BINDING_NAME_RT_toggleGRID", "Toggle Display")


		RT.SV.data.Craft[RT.playername] = {}

		RT.Collect_Data()
		RT.GRID_Create()
		RT.Update()	--Manual Update



		-- Only after initialised do we hook any other events.
		EVENT_MANAGER:RegisterForEvent(RT.name, EVENT_SMITHING_TRAIT_RESEARCH_STARTED, RT.Research_Changed)
		EVENT_MANAGER:RegisterForEvent(RT.name, EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, RT.Research_Changed)
		EVENT_MANAGER:RegisterForEvent(RT.name, EVENT_PLAYER_ACTIVATED, RT.Activated)
		EVENT_MANAGER:RegisterForUpdate(RT.name, 1000, RT.UpdateOnTimer)
		SCENE_MANAGER:RegisterTopLevel(RT.UI.GRID_TLW,false)
		RT.Init_done = true
	end
end



