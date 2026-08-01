local LAM = LibAddonMenu2

local entry
local entries


local function SetUnmuteNPCChoices() 

	local i, npc, first 
	i = 1
	first = nil
	SYT.UnmuteNPC_DropDown.choices = {}
	SYT.UnmuteNPC_DropDown.choicesValues = {}
	for npc,_ in pairs(SYT.SV.Muted) do 
		if i == 1 then first = npc end
		table.insert(SYT.UnmuteNPC_DropDown.choices, zo_strformat("<<1>> ", npc)) 
		table.insert(SYT.UnmuteNPC_DropDown.choicesValues, npc)
		i = i + 1
	end
	SYTUnmuteNPCDropdown:UpdateChoices() 
	if not SYT.UnmuteNPC_CurrentChoice then SYT.UnmuteNPC_CurrentChoice = first end
	return SYT.UnmuteNPC_CurrentChoice
end



local function SetUnmuteDialogueChoices() 

	local i, diag, first 
	i = 1
	first = nil
	SYT.UnmuteDialogue_DropDown.choices = {}
	SYT.UnmuteDialogue_DropDown.choicesValues = {}
	if SYT.UnmuteNPC_CurrentChoice ~= nil and SYT.SV.Muted[SYT.UnmuteNPC_CurrentChoice] ~= nil then 
		for diag,_ in pairs(SYT.SV.Muted[SYT.UnmuteNPC_CurrentChoice]) do 
			if i == 1 then first = diag end
			table.insert(SYT.UnmuteDialogue_DropDown.choices, zo_strformat("<<1>> ", diag)) 
			table.insert(SYT.UnmuteDialogue_DropDown.choicesValues, diag)
			i = i + 1
		end
	end
	SYTUnmuteDialogueDropdown:UpdateChoices() 
	if not SYT.UnmuteDialogue_CurrentChoice then SYT.UnmuteDialogue_CurrentChoice = first end
	if first == nil then SYT.SV.Muted[SYT.UnmuteNPC_CurrentChoice] = nil end
	return SYT.UnmuteDialogue_CurrentChoice
end


function SYT.CreateSettings()
	local panelName = "Shut Yer Trap"

	local panelData = {
	   type = "panel",
		name = panelName,
		displayName = "Shut Yer Trap",
		author = "remosito",
		registerForRefresh = true,
		registerForDefaults = false,
	}
	local panel = LAM:RegisterAddonPanel(panelName, panelData)
	entries = { 
		{ type = "header", name = SYT.S_SETTINGS_HEADER, },
		{ type = "description",	text = SYT.S_SETTINGS_DESC,},
		{ type = "divider",	},
		{
			type = "slider",
			name = SYT.S_SETTINGS_LEVEL_NAME,
			tooltip = SYT.S_SETTINGS_LEVEL_TOOLTIP,
			getFunc = function() return SYT.SV.backupLevel end,
			setFunc = function(value) SYT.SV.backupLevel = value end,
			min = 0,
			max = 100,
			step = 1,
			decimals = 0,
			width = "full"
		},
		{ type = "divider",	},
	}
	
	SYT.DropDown = { 
		type = "dropdown",  
		name = SYT.S_SETTINGS_DROPDOWN_NAME,  
		tooltip = SYT.S_SETTINGS_DROPDOWN_TOOLTIP,  
		choices = {},  
		choicesValues = {}, 
		getFunc = function() 
			if not SYT.CurrentChoice then SYT.CurrentChoice = 1 end
			SYTDropdown:UpdateChoices() 
			return SYT.CurrentChoice
		end,  
		setFunc = function(var) 
			SYT.CurrentChoice = var 
		end, 
		reference = "SYTDropdown",
	}	
	table.insert(entries, SYT.DropDown)

	entry = { 
		type = "button", 
		name = SYT.S_SETTINGS_MUTENPC_NAME, 
		tooltip = SYT.S_SETTINGS_MUTENPC_TOOLTIP, 
		func = function() 
			if not SYT.SV.Muted[SYT.Chatter[SYT.CurrentChoice][1]] then 
				SYT.SV.Muted[SYT.Chatter[SYT.CurrentChoice][1]] = {}
			end
			SYT.SV.Muted[SYT.Chatter[SYT.CurrentChoice][1]]["#@ALL@#"] = true
			table.remove(SYT.Chatter, SYT.CurrentChoice) 
			table.remove(SYT.DropDown.choices,SYT.CurrentChoice) 
			table.remove(SYT.DropDown.choicesValues,SYT.CurrentChoice) 
		end,  
		disabled = function() return #SYT.Chatter == 0 end,
		width = "half", 
	}
	table.insert(entries, entry)

	entry = { 
		type = "button", 
		name = SYT.S_SETTINGS_MUTEDIALOGUE_NAME, 
		tooltip = SYT.S_SETTINGS_MUTEDIALOGUE_TOOLTIP, 
		func = function() 
			if not SYT.SV.Muted[SYT.Chatter[SYT.CurrentChoice][1]] then 
				SYT.SV.Muted[SYT.Chatter[SYT.CurrentChoice][1]] = {}
			end
			SYT.SV.Muted[SYT.Chatter[SYT.CurrentChoice][1]][SYT.Chatter[SYT.CurrentChoice][2]] = true 
			table.remove(SYT.Chatter, SYT.CurrentChoice) 
			table.remove(SYT.DropDown.choices,SYT.CurrentChoice) 
			table.remove(SYT.DropDown.choicesValues) 
			SYT.CurrentChoice = 1
		end,  
		disabled = function() return #SYT.Chatter == 0 end,
		width = "half", 
	}
	table.insert(entries, entry)

	entry = { type = "header", name = SYT.S_SETTINGS_SAVEDVARS_HEADER, }
	table.insert(entries, entry)
	entry = { type = "description", text = SYT.S_SETTINGS_SAVEDVARS_DESCRIPTION, }
	table.insert(entries, entry)

	SYT.UnmuteNPC_DropDown = { 
		type = "dropdown",  
		name = SYT.S_SETTINGS_UNMUTENPC_DROPDOWN_NAME,  
		tooltip = SYT.S_SETTINGS_UNMUTENPC_DROPDOWN_TOOLTIP,  
		choices = {},  
		choicesValues = {}, 
		getFunc = function() return SetUnmuteNPCChoices() end,  
		setFunc = function(var) SYT.UnmuteNPC_CurrentChoice = var SYT.UnmuteDialogue_CurrentChoice = nil SetUnmuteDialogueChoices() end, 
		reference = "SYTUnmuteNPCDropdown",
		width = "half", 
	}	
	table.insert(entries, SYT.UnmuteNPC_DropDown)

	SYT.UnmuteDialogue_DropDown = { 
		type = "dropdown",  
		name = SYT.S_SETTINGS_UNMUTEDIALOGUE_DROPDOWN_NAME,  
		tooltip = SYT.S_SETTINGS_UNMUTEDIALOGUE_DROPDOWN_TOOLTIP,  
		choices = {},  
		choicesValues = {}, 
		getFunc = function() return SetUnmuteDialogueChoices() end,  
		setFunc = function(var) SYT.UnmuteDialogue_CurrentChoice = var end, 
		reference = "SYTUnmuteDialogueDropdown",
		width = "half", 
	}	
	table.insert(entries, SYT.UnmuteDialogue_DropDown)

	entry = { 
		type = "button", 
		name = SYT.S_SETTINGS_UNMUTENPC_NAME, 
		tooltip = SYT.S_SETTINGS_UNMUTENPC_TOOLTIP, 
		func = function() SYT.SV.Muted[SYT.UnmuteNPC_CurrentChoice] = nil SYT.UnmuteNPC_CurrentChoice = nil SYT.UnmuteDialogue_CurrentChoice = nil SetUnmuteNPCChoices()	end,  
		disabled = function() return SYT.UnmuteNPC_CurrentChoice == nil end,
		width = "half", 
	}
	table.insert(entries, entry)
	
	entry = { 
		type = "button", 
		name = SYT.S_SETTINGS_UNMUTEDIALOGUE_NAME, 
		tooltip = SYT.S_SETTINGS_UNMUTEDIALOGUE_TOOLTIP, 
		func = function() SYT.SV.Muted[SYT.UnmuteNPC_CurrentChoice][SYT.UnmuteDialogue_CurrentChoice] = nil	 SYT.UnmuteDialogue_CurrentChoice = nil SetUnmuteDialogueChoices() end,  
		disabled = function() return SYT.UnmuteDialogue_CurrentChoice == nil end,
		width = "half", 
	}
	table.insert(entries, entry)
	
	LAM:RegisterOptionControls(panelName, entries)
	for npc,_ in pairs(SYT.SV.Muted) do table.insert(SYT.UnmuteNPC_DropDown.choices, npc) end

	
end