MarcelovskiMarkers = MarcelovskiMarkers or {}
MarcelovskiMarkers.name = "MarcelovskiMarkers"
MarcelovskiMarkers.slashCommand = '/mama'
MarcelovskiMarkers.version = '1.4.4'

local LAM = LibAddonMenu2
local settingsPageCreated = false
local isBarHidden = true

local SettingAddSkill = ''
local SettingRemoveSkill = ''

function MarcelovskiMarkers.SlashCommands(str)
  local cmd = string.lower(str) 
  local options = {} --Splits input and puts each 'word' into a table.
    local searchResult = { string.match(cmd,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end  
  if options[1] == 'bars' then -- Print the IDs of all slotted abilities.
    MarcelovskiMarkers.PostSlottedSkills()
  elseif options[1] == "skills" then
  	d("Currently used abilities for markers:")
	d(MarcelovskiMarkers.PrintMarkerSkills())
  elseif options[1] == "add" then -- Add an ability ID to the table of saved abilities.
    MarcelovskiMarkers.Uninitialize()	
	local inputID = tonumber(options[2])
	MarcelovskiMarkers.AddSkill(inputID)
	MarcelovskiMarkers.Initialize()
  elseif options[1] == "remove" then -- Remove an ability ID from the table of saved abilities.
    MarcelovskiMarkers.Uninitialize()
	local MarkerSkills = MarcelovskiMarkers.savedVariables.Skills
	if options[2] == "all" then
	  local size = 0
	  for _ in pairs(MarkerSkills) do size = size + 1 end
	  for i = 1,size do table.remove(MarkerSkills, 1) end
	  d("Removed all abilities from Markers, defaulting to Poison Injection...")
	else
      local inputID = tonumber(options[2])
	  MarcelovskiMarkers.RemoveSkill(inputID)
	end
	MarcelovskiMarkers.Initialize()
  elseif options[1] == "marker" then -- Change which marker is used.
    MarcelovskiMarkers.Uninitialize()
	if tonumber(options[2]) ~= nil then
	  if tonumber(options[2]) >= 1 and tonumber(options[2]) <= 8 then
	    MarcelovskiMarkers.savedVariables.MarkerType = tonumber(options[2])
		local FeedbackString = 'Marker ' .. options[2] .. ' will now be used.'
		d(FeedbackString)
	  else
	    d('Marker ID not found. - Must be number between 1 and 8!')
	  end
	else
	  d('Marker ID not found. - Must be number between 1 and 8!')
	end
    MarcelovskiMarkers.Initialize()
  elseif options[1] == "help" or options[1] =='' or options[1] == nil then
    d('MarcelovskiMarkers Commands: "help", "bars", "add <ID>", "remove <ID>", "remove all", "marker <1-8>", "skills"')
  else
	d('MarcelovskiMarkers Commands: "help", "bars", "add <ID>", "remove <ID>", "remove all", "marker <1-8>", "skills"')
  end
end

function MaMa_table_contains(table, element) --Check if a table contains an element.
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function MaMa_getIndex(table, element) -- Check which index an element has in a table.
    local index = nil
    for i, value in pairs(table) do 
        if value == element then
          index = i 
        end
    end
    return index
end

function MarcelovskiMarkers.RemoveSkill(inputID)
	local MarkerSkills = MarcelovskiMarkers.savedVariables.Skills
	if MaMa_table_contains(MarkerSkills, inputID) then
		local ind = MaMa_getIndex(MarkerSkills, inputID)
	    table.remove(MarkerSkills, ind)
	    MarcelovskiMarkers.savedVariables.Skills = MarkerSkills
	    local SkillName = GetAbilityName(inputID)
	    local FeedbackString = string.gsub(SkillName,'%^%a','') .. ' has been removed from Markers.'
	    d(FeedbackString)
	    -- Check if the last element was removed to inform about default.
	    local size = 0
	    for _ in pairs(MarkerSkills) do size = size + 1 end
	    if size == 0 then d("Last ability was removed from Markers, defaulting to Poison Injection...") end
		MarcelovskiMarkers.UpdateMarkerSkillsDecriptions()
	else
        d("Failed to remove ability as it wasn't added before!")
	end
end

function MarcelovskiMarkers.AddSkill(inputID)
	local MarkerSkills = MarcelovskiMarkers.savedVariables.Skills
	if MaMa_table_contains(MarkerSkills, inputID) then
		d("This ability has already been added!")
	else	
		local SkillName = GetAbilityName(inputID)
		if SkillName == nil or SkillName == '' then
			d('Ability ID not found. - Check for typo!')
		else
			table.insert(MarkerSkills, inputID)
			MarcelovskiMarkers.savedVariables.Skills = MarkerSkills
			local FeedbackString = string.gsub(SkillName,'%^%a','') .. ' is now added for Markers.'
			d(FeedbackString)
			MarcelovskiMarkers.UpdateMarkerSkillsDecriptions()
		end
	end
end

function MarcelovskiMarkers.PrintMarkerSkills()
	local MarkerSkills = MarcelovskiMarkers.savedVariables.Skills
	local FeedbackString = ''
    for _, value in pairs(MarkerSkills) do
		local SkillName = GetAbilityName(value)
		FeedbackString = FeedbackString .. string.gsub(SkillName,'%^%a','') .. ' - ' .. tostring(value) .. '\n'
    end
	return FeedbackString
end

local function GetSlotInfoString(index, bar)
  local slot    = index == 8 and "Ult" or tostring(index - 2)
  local string  = '[' .. slot .. '] '
  local id      = GetSlotBoundId(index, bar)
  if id > 0 then
    local name = string.gsub(GetAbilityName(id),'%^%a','')
    string = string .. '<' .. name .. '> ' .. id
  end
  return string
end

function MarcelovskiMarkers.PostSlottedSkills()
	d('Current Abilities:')
	d('Front Bar')
	for i = 3, 8 do d(GetSlotInfoString(i, 0)) end
	d('Back Bar')
	for i = 3, 8 do d(GetSlotInfoString(i, 1)) end
end

local function AllSlotString(bar)
    local string = ''
	for i = 3,8 do string = string .. GetSlotInfoString(i,bar) .. '\n' end
	return string
end

function MarcelovskiMarkers.UpdateSlottedSkillsDecriptions()
	if settingsPageCreated then
		MarcelovskiMarkers_Front_Bar_List.desc:SetText(AllSlotString(0))
		MarcelovskiMarkers_Back_Bar_List.desc:SetText(AllSlotString(1))
	end
end

function MarcelovskiMarkers.UpdateMarkerSkillsDecriptions()
	if settingsPageCreated then
		MarcelovskiMarkers_Current_Skills_List.desc:SetText(MarcelovskiMarkers.PrintMarkerSkills())
	end	
end

MarcelovskiMarkers.defaults = {
		Skills = {38660}, --Poison Injection (Bowsorcs)
		MarkerType = 8, --Skull Icon
		PvEMode = false, --Prevents placing markers on NPCs unless changed in settings
}

function MarcelovskiMarkers.Initialize()
  
  MarcelovskiMarkers.savedVariables = ZO_SavedVars:NewCharacterIdSettings("MarcelovskiMarkersVariables", 1, nil, MarcelovskiMarkers.defaults)
  
  SLASH_COMMANDS[MarcelovskiMarkers.slashCommand] = MarcelovskiMarkers.SlashCommands 
  
  local MarkerSkills = MarcelovskiMarkers.savedVariables.Skills
  
  local TargetMarkerType = tonumber(MarcelovskiMarkers.savedVariables.MarkerType)
  local playeralliance = GetUnitAlliance("player")
  
    local function AssignMarker(_, result) 
      if not IsUnitAttackable("reticleover") then return end
	  if MarcelovskiMarkers.savedVariables.PvEMode then
		if IsUnitPlayer("reticleover") and targetalliance ~= 0 then return end
	  else 
		if not IsUnitPlayer("reticleover") then return end
	  end
	  if GetUnitTargetMarkerType("reticleover") == TargetMarkerType then return end
	  local targetalliance = GetUnitAlliance("reticleover")
--      if  targetalliance == 0 then return end --No targets without alliance (TEST: Battlegrounds) (still targets guard npcs) [Better: IsUnitPlayer]
      if playeralliance == targetalliance then return end
      AssignTargetMarkerToReticleTarget(TargetMarkerType)	  
-------------------------------DEBUG-------------------------------
--	  d(LocalizeString("Marker placed on <<1>>.", Target))
--    local name = GetAllianceName(alliance)  --Alliance debug	  
--    d(LocalizeString("Alliance is <<1>>.", alliance))
--	  local difficulty = GetUnitDifficulty("reticleover") --UnitDifficulty Debug
--    d(LocalizeString("Target has Difficulty <<1>>.", difficulty)) 
    end

	local function OnAbilityUsed(_, n)
      if (n >= 3 and n <= 8) then
	    currentHotbarCategory = GetActiveHotbarCategory()
        local id = GetSlotBoundId(n, currentHotbarCategory)
		if MaMa_table_contains(MarkerSkills, id) then
	      AssignMarker()
		end
	  end
	end	

	local function ReticleTargetChange()
	  if GetUnitTargetMarkerType("reticleover") ~= TargetMarkerType then return end -- Only look at Targets with the preferred Marker
	  local targetalliance = GetUnitAlliance("reticleover")
	  
	  if MarcelovskiMarkers.savedVariables.PvEMode then
		if IsUnitPlayer("reticleover") == true then
			AssignTargetMarkerToReticleTarget(TargetMarkerType)
		end
	  else
		if (playeralliance == targetalliance or IsUnitPlayer("reticleover") == false) then -- Remove Marker if the Target is from the same alliance or is an NPC
			AssignTargetMarkerToReticleTarget(TargetMarkerType)
		end
	  end
	end
  EVENT_MANAGER:RegisterForEvent(MarcelovskiMarkers.name.."skilltarget", EVENT_ACTION_SLOT_ABILITY_USED, OnAbilityUsed)
  EVENT_MANAGER:RegisterForEvent(MarcelovskiMarkers.name.."reticletarget", EVENT_RETICLE_TARGET_CHANGED, ReticleTargetChange)
end

function MarcelovskiMarkers.Uninitialize()
  EVENT_MANAGER:UnregisterForEvent(MarcelovskiMarkers.name.."reticletarget", EVENT_RETICLE_TARGET_CHANGED, ReticleTargetChange)
  EVENT_MANAGER:UnregisterForEvent(MarcelovskiMarkers.name.."skilltarget", EVENT_ACTION_SLOT_ABILITY_USED, OnAbilityUsed)
end

--############################ MENU
function MarcelovskiMarkers.CreateMenu()
	local panelData = {
		type				= "panel",
		name				= MarcelovskiMarkers.name,
		displayName			= MarcelovskiMarkers.name,
		author				= 'Marcelovski',
		version				= MarcelovskiMarkers.version,
		slashCommand		= "/mamaoptions",
		registerForRefresh	= true,
		registerForDefaults = true,
	}

	local MaMa_Panel = LAM:RegisterAddonPanel( MarcelovskiMarkers.name .. "Options", panelData )


	local function OptionsSkillbar(isHidden)
		local l
		if isHidden then
			ZO_ActionBar1:SetHidden(false)
			isBarHidden = false
			l = 'Hide Ability Bar'
		else
			ZO_ActionBar1:SetHidden(true)
			isBarHidden = true
			l = 'Show Ability Bar'
		end
		WINDOW_MANAGER:GetControlByName('MaMa_OptionsSkills').button:SetText(l)
	end

    local optionsTable = {
		{
			type = "description",
			text = "Automatic target markers for pvp group leads. Use |cffff00/mama|r to change settings via chat commands instead. Access this menu quickly with |cffff00/mamaoptions|r.",
		},
		{
			type = 'button',
			name = 'Show Ability Bar',
			tooltip = 'Only shows within this settings menu.',
			func = function() OptionsSkillbar(ZO_ActionBar1:IsHidden()) end,
			width = 'half',
			reference = 'MaMa_OptionsSkills'
		},
		{
			type = 'checkbox',
			name = '        PvE Mode',
			tooltip = 'PvE Mode places markers on NPCs and prevents placement on players',
			width = 'half',
			getFunc = function() return MarcelovskiMarkers.savedVariables.PvEMode end,
			setFunc = function(value) 
			MarcelovskiMarkers.Uninitialize()			
			MarcelovskiMarkers.savedVariables.PvEMode = value 
			MarcelovskiMarkers.Initialize()	
			end,
			default = MarcelovskiMarkers.defaults.PvEMode,
			reference = "MaMa_PvEMode_Checkbox"
		},
		{
			type = "divider",
		},
		{
			type     = "submenu",
			name     = "|c00ffffSLOTTED ABILITIES|r",
			controls = {
				{
				type = 'description',
				text = 'Shows your currently slotted abilities with their respective IDs.',
				width = 'full',
				},
				{	
				type = 'description',
				title = 'Front Bar',
				text = function() return AllSlotString(0) end,
				width = 'half',
				reference = 'MarcelovskiMarkers_Front_Bar_List'
				},
				{	
				type = 'description',
				title = 'Back Bar',
				text = function() return AllSlotString(1) end,
				width = 'half',
				reference = 'MarcelovskiMarkers_Back_Bar_List'
				}
			}
		},
		{
			type     = "submenu",
			name     = "|c00ffffMARKER ABILITIES|r",
--			tooltip = 'Edit abilities that place a marker upon use.',
			controls = {
				{	
				type = 'description',
				title = 'Current Marker Abilities',
				text = function() return MarcelovskiMarkers.PrintMarkerSkills() end,
				width = 'full',
				reference = 'MarcelovskiMarkers_Current_Skills_List',
				},
				{
				type = 'editbox',
				name = 'Remove Marker Ability',
				tooltip = 'Enter Ability ID.',
				width = 'full',
				getFunc = function() return SettingRemoveSkill end,
				setFunc = function(text) SettingRemoveSkill = text end,
				isMultiline = false,
				default = '',
				},
				{
				type = 'editbox',
				name = 'Add Marker Ability',
				tooltip = 'Enter Ability ID.',
				width = 'full',
				getFunc = function() return SettingAddSkill end,
				setFunc = function(text) SettingAddSkill = text end,
				isMultiline = false,
				default = '',
				},
				{
				type = 'button',
				name = 'Update!',
				width = 'full',
				func = function()
					if SettingAddSkill ~= '' or SettingRemoveSkill ~= '' then
						MarcelovskiMarkers.Uninitialize()
						if SettingAddSkill ~= '' then MarcelovskiMarkers.AddSkill(tonumber(SettingAddSkill)) end
						if SettingRemoveSkill ~= '' then MarcelovskiMarkers.RemoveSkill(tonumber(SettingRemoveSkill)) end
						MarcelovskiMarkers.Initialize()
						SettingAddSkill = ''
						SettingRemoveSkill = ''
					end
				end,
--				reference = 'MaMa_OptionsSkills'
				},
			}
		},
		{
			type     = "submenu",
			name     = "|c00ffffMARKER SYMBOL|r",
			controls = {
				{
				type = 'description',
				text = '',
				},
				{	
				type = 'iconpicker',
				name = 'Marker Symbol',
				tooltip = 'Select marker symbol.',
				choices = {'/esoui/art/targetmarkers/target_blue_square_64.dds','/esoui/art/targetmarkers/target_gold_star_64.dds','/esoui/art/targetmarkers/target_green_circle_64.dds','/esoui/art/targetmarkers/target_orange_triangle_64.dds','/esoui/art/targetmarkers/target_pink_moons_64.dds','/esoui/art/targetmarkers/target_purple_oblivion_64.dds','/esoui/art/targetmarkers/target_red_weapons_64.dds','/esoui/art/targetmarkers/target_white_skull_64.dds'},
				choicesTooltips =  {'Blue Square','Gold Star','Green Circle','Orange Triangle','Pink Moons','Purple Oblivion Gate','Red Weapons','White Skull'},
				width = 'full',
				maxColumns = 4,
				visibleRows = 2,
				iconSize = 64,
				scrollable = false,
--				reference = '',
				getFunc = function() 
					if MarcelovskiMarkers.savedVariables.MarkerType == 1 then return '/esoui/art/targetmarkers/target_blue_square_64.dds'
					elseif MarcelovskiMarkers.savedVariables.MarkerType == 2 then return '/esoui/art/targetmarkers/target_gold_star_64.dds'
					elseif MarcelovskiMarkers.savedVariables.MarkerType == 3 then return '/esoui/art/targetmarkers/target_green_circle_64.dds'
					elseif MarcelovskiMarkers.savedVariables.MarkerType == 4 then return '/esoui/art/targetmarkers/target_orange_triangle_64.dds'
					elseif MarcelovskiMarkers.savedVariables.MarkerType == 5 then return '/esoui/art/targetmarkers/target_pink_moons_64.dds'
					elseif MarcelovskiMarkers.savedVariables.MarkerType == 6 then return '/esoui/art/targetmarkers/target_purple_oblivion_64.dds'
					elseif MarcelovskiMarkers.savedVariables.MarkerType == 7 then return '/esoui/art/targetmarkers/target_red_weapons_64.dds'
					elseif MarcelovskiMarkers.savedVariables.MarkerType == 8 then return '/esoui/art/targetmarkers/target_white_skull_64.dds' 
					else return '' end					
				end,
				setFunc = function(value) 
					MarcelovskiMarkers.Uninitialize()	
					if value == '/esoui/art/targetmarkers/target_blue_square_64.dds' then
						MarcelovskiMarkers.savedVariables.MarkerType = 1
						d('Marker changed to Blue Square.')
					elseif value == '/esoui/art/targetmarkers/target_gold_star_64.dds' then
						MarcelovskiMarkers.savedVariables.MarkerType = 2
						d('Marker changed to Gold Star.')
					elseif value == '/esoui/art/targetmarkers/target_green_circle_64.dds' then
						MarcelovskiMarkers.savedVariables.MarkerType = 3
						d('Marker changed to Green Circle.')
					elseif value == '/esoui/art/targetmarkers/target_orange_triangle_64.dds' then
						MarcelovskiMarkers.savedVariables.MarkerType = 4
						d('Marker changed to Orange Triangle.')
					elseif value == '/esoui/art/targetmarkers/target_pink_moons_64.dds' then
						MarcelovskiMarkers.savedVariables.MarkerType = 5
						d('Marker changed to Pink Moons.')
					elseif value == '/esoui/art/targetmarkers/target_purple_oblivion_64.dds' then
						MarcelovskiMarkers.savedVariables.MarkerType = 6
						d('Marker changed to Purple Oblivion Gate.')
					elseif value == '/esoui/art/targetmarkers/target_red_weapons_64.dds' then
						MarcelovskiMarkers.savedVariables.MarkerType = 7
						d('Marker changed to Red Weapons.')
					elseif value == '/esoui/art/targetmarkers/target_white_skull_64.dds' then
						MarcelovskiMarkers.savedVariables.MarkerType = 8
						d('Marker changed to White Skull.') end		
					MarcelovskiMarkers.Initialize()						
				end,
				},
			}
		},
	}

	LAM:RegisterOptionControls( MarcelovskiMarkers.name .. "Options", optionsTable )
	
	CALLBACK_MANAGER:RegisterCallback('LAM-PanelOpened', function(panel)
		if panel == MaMa_Panel then
		    if isBarHidden then
				ZO_ActionBar1:SetHidden(true)
			else
				ZO_ActionBar1:SetHidden(false)
			end
			MarcelovskiMarkers.UpdateSlottedSkillsDecriptions()
			MarcelovskiMarkers.UpdateMarkerSkillsDecriptions()
--			d('panel opened')
		else
			ZO_ActionBar1:SetHidden(true)
		end
	end)
	
	CALLBACK_MANAGER:RegisterCallback('LAM-PanelClosed', function(panel)
		if panel ~= MaMa_Panel then return end
		ZO_ActionBar1:SetHidden(true)
--		d('panel closed')
	end)
  
	CALLBACK_MANAGER:RegisterCallback('LAM-PanelControlsCreated', function(panel)
		if panel == MaMa_Panel then
			if not settingsPageCreated then
				settingsPageCreated = true
			end
--		d('panel created')
		end
	end)
end

--############################ MENU END

function MarcelovskiMarkers.OnAddOnLoaded(event, addonName)
  if addonName == MarcelovskiMarkers.name then
    MarcelovskiMarkers.Initialize()
    EVENT_MANAGER:UnregisterForEvent(MarcelovskiMarkers.name, EVENT_ADD_ON_LOADED) 
	MarcelovskiMarkers.CreateMenu()
  end
end
EVENT_MANAGER:RegisterForEvent(MarcelovskiMarkers.name, EVENT_ADD_ON_LOADED, MarcelovskiMarkers.OnAddOnLoaded)