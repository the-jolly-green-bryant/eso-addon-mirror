LibRadialMenu:RegisterAddon("mara", "Mara")

LibRadialMenu:RegisterEntry("mara", GetString(SI_GROUP_MENU_LEAVE_INSTANCE_KEYBIND), "pte", "/esoui/art/guild/gamepad/gp_guild_menuicon_leaveguild.dds", function() ExitInstanceImmediately() end, "This action will eject you from the current instance.\n\nIf you're in a group, you can travel back to the instance by traveling to a group member that is still inside it. Otherwise you can travel back using the map.") -- leave instance

LibRadialMenu:RegisterEntry("mara", string.format("%s %s",GetString(SI_DUNGEON_DIFFICULTY_HEADER), GetString(SI_DUNGEONDIFFICULTY1)), "setToNormal", "/esoui/art/lfg/gamepad/lfg_activityicon_normaldungeon.dds", function() SetVeteranDifficulty(false) end, "Sets the dungeon difficulty to normal.")

LibRadialMenu:RegisterEntry("mara", string.format("%s %s",GetString(SI_DUNGEON_DIFFICULTY_HEADER), GetString(SI_DUNGEONDIFFICULTY2)), "setToVet", "/esoui/art/lfg/gamepad/lfg_activityicon_veterandungeon.dds", function() SetVeteranDifficulty(true) end, "Sets the dungeon difficulty to veteran.")


LibRadialMenu:RegisterEntry("mara", "Reset Instance", "resetInstance", "/esoui/art/icons/mapkey/mapkey_dungeon.dds", function()
		local currentDiff = IsGroupUsingVeteranDifficulty()
		SetVeteranDifficulty(not currentDiff)
		zo_callLater(function() SetVeteranDifficulty(currentDiff) end, 250)
	end, "Resets the current dungeon instance by toggling veteran off and on.\n\nThis requires you to be outside of the instance to reset it.")



LibRadialMenu:RegisterEntry("mara", "Toggle Add-on Memory Display", "toggleram", "/esoui/art/addons/gamepad/gp_addons_manage.dds", function() ADD_ON_MEMORY_DISPLAY:Toggle() end, "Toggles the addon memory display in the bottom left corner of your screen.")

LibRadialMenu:RegisterEntry("mara", "Toggle GCD Display", "togglegcd", "/esoui/art/addons/gamepad/gp_mod_listing_category_castbarsandcooldowns.dds", function() ZO_ActionButtons_ToggleShowGlobalCooldown() end, "Toggles the base game Global Cooldown (GCD) tracker.")
--ZO_ActionButtons_ToggleShowGlobalCooldown()

LibRadialMenu:RegisterEntry("mara", "Identify Ghost Emperor", "showghostemp", "/esoui/art/tutorial/gamepad/gp_overview_menuicon_emperor.dds", function() local alliance,_,name = GetCampaignAbdicationStatus(GetCurrentCampaignId()); local alli = zo_strformat(SI_ALLIANCE_NAME, GetAllianceName(alliance)); if alliance == 0 then d("There is no Ghost Emp") else d(name.." of the ".. alli.. " is the Ghost Emp") end end, "Identifies if there is a ghost emperor in your current cyrodiil campaign, and who it is.")
--

LibRadialMenu:RegisterEntry("mara", "Leave Group", "leavegroup", "/esoui/art/menubar/gamepad/gp_playermenu_icon_quit.dds", function() GroupLeave() end, "Exits your current group.")



LibRadialMenu:RegisterEntry("mara", "Primary Residence", "porthome", "/esoui/art/icons/poi/poi_group_house_owned.dds", function() 
	local primary = GetHousingPrimaryHouse()
	RequestJumpToHouse(primary,false)
end, "Travels to your Primary Residence.")

LibRadialMenu:RegisterEntry("mara", "Outside Primary Residence", "porthomebutnot", "/esoui/art/icons/poi/poi_group_house_unowned.dds", function() 
	local primary = GetHousingPrimaryHouse()
	RequestJumpToHouse(primary,true)
end, "Travels to your Primary Residence.")




-- Code adapted from PetDismiss on PC
local pets = {
	[23304] = true, [30631] = true, [30636] = true, [30641] = true, [23319] = true, [30647] = true, [30652] = true, [30657] = true, [23316] = true, [30664] = true, [30669] = true, [30674] = true, -- scamp
	[24613] = true, [30581] = true, [30584] = true, [30587] = true, [24636] = true, [30592] = true, [30595] = true, [30598] = true, [24639] = true, [30618] = true, [30622] = true, [30626] = true, -- birb
	[85982] = true, [85983] = true, [85984] = true, [85985] = true, [85986] = true, [85987] = true, [85988] = true, [85989] = true, [85990] = true, [85991] = true, [85992] = true, [85993] = true -- bear
} 
local function dismissAllPets()
	for i = 1, GetNumBuffs("player") do
		local _, _, _, buffSlot, _, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("player", i)
		if pets[abilityId] then
			CancelBuff(buffSlot)
		end
	end
end

LibRadialMenu:RegisterEntry("mara", "Despawn Pets", "goawayplzpets", "/esoui/art/treeicons/gamepad/gp_store_indexicon_vanitypets.dds", dismissAllPets, "Unsummons your Sorc or Warden pets.")

-- /esoui/art/dye/dyes_tabicon_player_over.dds -- to hide
-- /esoui/art/dye/dyes_tabicon_player_down.dds -- to show

local hideGroup
local ReshowGroup

function hideGroup()
	SetCrownCrateNPCVisible(true)
	LibRadialMenu:RegisterEntry("mara", "Show Group", "hidegroup", "/esoui/art/dye/dyes_tabicon_player_down.dds", ReshowGroup, "Toggles hiding players around you by summoning the crown crate assistant.")
end

-- yoinked from speedrun/hidegroupnecro
function ReshowGroup()
	if not IsPlayerActivated() then return end
	local scene = SCENE_MANAGER.currentScene:GetName()
	if scene == "stats" then return end
	SCENE_MANAGER:Show("stats")
	zo_callLater(
		function()
			SetCrownCrateNPCVisible(false)
			if scene == "hudui" then
				SCENE_MANAGER:Show("hud")
			else
				if scene ~= "" then
					SCENE_MANAGER:Show(scene)
				end
			end
			LibRadialMenu:RegisterEntry("mara", "Hide Group", "hidegroup", "/esoui/art/dye/dyes_tabicon_player_over.dds", hideGroup, "Toggles hiding players around you by summoning the crown crate assistant.")
		end,20)
end



LibRadialMenu:RegisterEntry("mara", "Hide Group", "hidegroup", "/esoui/art/dye/dyes_tabicon_player_over.dds",
	hideGroup,
	"Toggles hiding players around you by summoning the crown crate assistant.")






--local alliance,_,name = GetCampaignAbdicationStatus(GetCurrentCampaignId()); local alli = zo_strformat(SI_ALLIANCE_NAME, GetAllianceName(alliance)); if alliance == 0 then d("There is no Ghost Emp") else d(name.." of the ".. alli.. " is the Ghost Emp") end


if WizardsWardrobe then
	local shouldReplaceNextQuestKeybind = false
	local wizardsMara = {}
	function wizardsMara.EnableWizardsNextSetup()
		LibRadialMenu:RegisterEntry("mara", "Disable Next Wizards Keybind", "toggleNextSetup", "/esoui/art/buttons/large_rightarrow_disabled.dds", function() wizardsMara.DisableWizardsNextSetup() end, "Toggles the ability to press d-pad right to move to the next wizards wardrobe setup.")
		shouldReplaceNextQuestKeybind = true
	end

	function wizardsMara.DisableWizardsNextSetup()
		LibRadialMenu:RegisterEntry("mara", "Enable Next Wizards Keybind", "toggleNextSetup", "/esoui/art/buttons/large_rightarrow_up.dds", function() wizardsMara.EnableWizardsNextSetup() end, "Toggles the ability to press d-pad right to move to the next wizards wardrobe setup.")
		shouldReplaceNextQuestKeybind = false
	end


	ZO_PreHook(FOCUSED_QUEST_TRACKER, "AssistNext", function()
		if shouldReplaceNextQuestKeybind then
			if HUD_SCENE.state == "shown" then
				WizardsWardrobe.LoadSetupAdjacent(1)
				return true
			end
		end
	end)

	wizardsMara.DisableWizardsNextSetup()



	LibRadialMenu:RegisterEntry("mara", "Wizards Setup #1", "wizards1", "/esoui/art/icons/internal/ability_internal_1.dds", function() WizardsWardrobe.LoadSetupCurrent(1, false) end, "Loads the first wizards setup.")
	LibRadialMenu:RegisterEntry("mara", "Wizards Setup #2", "wizards2", "/esoui/art/icons/internal/ability_internal_2.dds", function() WizardsWardrobe.LoadSetupCurrent(2, false) end, "Loads the second wizards setup.")
	LibRadialMenu:RegisterEntry("mara", "Wizards Setup #3", "wizards3", "/esoui/art/icons/internal/ability_internal_3.dds", function() WizardsWardrobe.LoadSetupCurrent(3, false) end, "Loads the third wizards setup.")
	LibRadialMenu:RegisterEntry("mara", "Wizards Setup #4", "wizards4", "/esoui/art/icons/internal/ability_internal_4.dds", function() WizardsWardrobe.LoadSetupCurrent(4, false) end, "Loads the fourth wizards setup.")
	LibRadialMenu:RegisterEntry("mara", "Wizards Setup #5", "wizards5", "/esoui/art/icons/internal/ability_internal_5.dds", function() WizardsWardrobe.LoadSetupCurrent(5, false) end, "Loads the fifth wizards setup.")
	LibRadialMenu:RegisterEntry("mara", "Wizards Setup #6", "wizards6", "/esoui/art/icons/internal/ability_internal_6.dds", function() WizardsWardrobe.LoadSetupCurrent(6, false) end, "Loads the sixth wizards setup.")
	LibRadialMenu:RegisterEntry("mara", "Wizards Setup #7", "wizards7", "/esoui/art/icons/internal/ability_internal_7.dds", function() WizardsWardrobe.LoadSetupCurrent(7, false) end, "Loads the seventh wizards setup.")
	LibRadialMenu:RegisterEntry("mara", "Wizards Setup #8", "wizards8", "/esoui/art/icons/internal/ability_internal_8.dds", function() WizardsWardrobe.LoadSetupCurrent(8, false) end, "Loads the eighth wizards setup.")
	LibRadialMenu:RegisterEntry("mara", "Wizards Setup #9", "wizards9", "/esoui/art/icons/internal/ability_internal_9.dds", function() WizardsWardrobe.LoadSetupCurrent(9, false) end, "Loads the ninth wizards setup.")
	

	-- prev: /esoui/art/buttons/leftarrow_up.dds
	-- next: /esoui/art/buttons/rightarrow_up.dds

	LibRadialMenu:RegisterEntry("mara", "Wizards Previous Setup", "wizardsprev", "/esoui/art/buttons/leftarrow_up.dds", function() WizardsWardrobe.LoadSetupAdjacent(-1) end, "Loads the previous setup in Wizards Wardrobe.")
	LibRadialMenu:RegisterEntry("mara", "Wizards Next Setup", "wizardsnext", "/esoui/art/buttons/rightarrow_up.dds", function() WizardsWardrobe.LoadSetupAdjacent(1) end, "Loads the next setup in Wizards Wardrobe.")

end


--[[

if COLOR_PICKER_GAMEPAD then -- adds the ability to change the alpha slider in colour pickers
	
	local enableColourPickerAlpha = true

	LibRadialMenu:RegisterEntry("mara", "Toggle Alpha Slider", "toggleAlpha", "/esoui/art/miscellaneous/gamepad/gp_colorpicker_slider_vertical.dds", function()
		enableColourPickerAlpha = not enableColourPickerAlpha
	end, "Toggles the alpha slider in colour pickers. By default this is enabled.")

	SecurePostHook(COLOR_PICKER_GAMEPAD,
	    "UpdateDirectionalInput",
	    function(self, deltaS)
	    	if enableColourPickerAlpha then
		        local left = GetGamepadLeftTriggerMagnitude()
		        local right = GetGamepadRightTriggerMagnitude()
		        local currentAlpha = self.alphaSlider:GetValue()
		        local net = right - left
		        self.alphaSlider:SetValue(currentAlpha+net/50)
		    end
	    end)

	COLOR_PICKER_GAMEPAD.alphaLabel:SetFont("ZoFontGamepad22")
end
--LibRadialMenu:RegisterEntry("mara", entryName, entryId, entryIcon, entryCallback, entryDescription)


--]]









EVENT_MANAGER:RegisterForEvent("MARA", EVENT_ADD_ON_LOADED, function(event, addonName)
	if addonName ~= "MARA" then return end
	EVENT_MANAGER:UnregisterForEvent("MARA", EVENT_ADD_ON_LOADED)
	DungeonTrialReset_Standalone:Initialize()

	LibRadialMenu:RegisterEntry("mara", "Reform Group", "reformgroup", "/esoui/art/icons/mapkey/mapkey_solotrial.dds", function() DungeonTrialReset_Standalone:ReformGroupConfirm() end, "Resets the current trial/dungeon instance by disbanding and reforming the group.\n\nYou do NOT need to be outside of an instance to do this.")

end)



EVENT_MANAGER:RegisterForEvent("MARA", EVENT_PLAYER_ACTIVATED, function()
	EVENT_MANAGER:UnregisterForEvent("MARA", EVENT_PLAYER_ACTIVATED)
	if LibRadialMenu.vars.wheelIndex == 0 then
		d("[MARA] LibRadialMenu is currently not showing its wheel! To change this, set the Wheel Location in LibRadialMenu to anything other than 0! The recommended value is 6.")
	end

end)
