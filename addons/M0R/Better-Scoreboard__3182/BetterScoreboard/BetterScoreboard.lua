BetterScoreboard = {}
local bs = BetterScoreboard
-- Written by M0R_Gaming

bs.name = "BetterScoreboard"
bs.scores = {}
bs.queues = {}
bs.vars = {}

local classIcons = {
	"esoui/art/icons/class/gamepad/gp_class_dragonknight.dds",
	"esoui/art/icons/class/gamepad/gp_class_sorcerer.dds",
	"esoui/art/icons/class/gamepad/gp_class_nightblade.dds",
	"esoui/art/icons/class/gamepad/gp_class_warden.dds",
	"esoui/art/icons/class/gamepad/gp_class_necromancer.dds",
	"esoui/art/icons/class/gamepad/gp_class_templar.dds"
}

classIcons[117] = "esoui/art/icons/class/gamepad/gp_class_arcanist.dds"

local defaultSettings = {
	queueSelections = {},
	kda = {
		kills = 0,
		deaths = 0,
		assists = 0
	},
	wlt = {
		wins = 0,
		losses = 0,
		ties = 0
	},
	points = 0,
	damage = 0,
	heals = 0
}



local function updateScore(i, roundIndex, showAggregate)
	local damage = 0
	local heal = 0
	if not showAggregate then -- to show aggrigate its a seperate function, instead of a paramater for some reason
		damage = GetScoreboardEntryScoreByType(i, SCORE_TRACKER_TYPE_DAMAGE_DONE, roundIndex)
		heal = GetScoreboardEntryScoreByType(i, SCORE_TRACKER_TYPE_HEALING_DONE, roundIndex)
	else
		damage = GetBattlegroundCumulativeScoreForScoreboardEntryByType(i, SCORE_TRACKER_TYPE_DAMAGE_DONE, roundIndex)
		heal = GetBattlegroundCumulativeScoreForScoreboardEntryByType(i, SCORE_TRACKER_TYPE_HEALING_DONE, roundIndex)
	end
	

	damage = string.format("%sk",math.floor(damage/1000))
	heal = string.format("%sk",math.floor(heal/1000))

	if damage and bs.scores[i] then
		bs.scores[i].damage:SetText(damage)
	end
	if heal and bs.scores[i] then
		bs.scores[i].heal:SetText(heal)
	end
end


local function updateRow(row)
	local charName = zo_strformat(SI_PLAYER_NAME, row.data.characterName)
	local displayName = zo_strformat(SI_PLAYER_NAME, row.data.displayName)
	local formattedName = ""
	
	if ZO_ShouldPreferUserId() then
		formattedName = string.format("%s (%s)", displayName, charName)
	else
		formattedName = string.format("%s (%s)", charName, displayName)
	end
	row.nameLabel:SetText(formattedName)


	local classId = GetScoreboardEntryClassId(row.data.entryIndex)
	row.classIcon:SetTexture(classIcons[classId])



	if row.data.isPlaceholderEntry then -- new bgs have placeholders
		row.nameLabel:SetText("")
		row.classIcon:SetTexture("/esoui/art/icons/heraldrycrests_misc_blank_01.dds") -- blank texture
		row.heal:SetText("")
		row.damage:SetText("")
	end
end



SecurePostHook(Battleground_Scoreboard_Player_Row, "UpdateRow", updateRow)

SecurePostHook(Battleground_Scoreboard_Player_Row, "Initialize", function(self, row)
	local rowName = row:GetName()
	local metalScore = row:GetNamedChild("MedalScore")
	local nameLabel = row:GetNamedChild("NameLabel")

	local damage = CreateControl(rowName.."DamageScore",row,CT_LABEL)
	local heal = CreateControl(rowName.."HealScore",row,CT_LABEL)
	heal:SetAnchor(LEFT,metalScore,RIGHT,15,0,0)
	damage:SetAnchor(LEFT,metalScore,RIGHT,15,0,0)
	heal:SetTransformOffsetY(15)
	damage:SetTransformOffsetY(-5)
	heal:SetColor(1,0.85,0)
	damage:SetFont("ZoFontGame")
	heal:SetFont("ZoFontGame")

	local classIcon = CreateControl(rowName.."ClassIcon",row,CT_TEXTURE)
	classIcon:SetAnchor(RIGHT,nameLabel,LEFT,-15,0,0)
	classIcon:SetDimensions(32,32)
	classIcon:SetDrawLevel(6)


	self.damage = damage
	self.heal = heal
	self.classIcon = classIcon
end)



SecurePostHook(BATTLEGROUND_SCOREBOARD_FRAGMENT, "UpdateAll", function(self)
	local showAggregate = BATTLEGROUND_SCOREBOARD_FRAGMENT:ShouldShowAggregateScores()
	local roundIndex = showAggregate and GetCurrentBattlegroundRoundIndex() or BATTLEGROUND_SCOREBOARD_FRAGMENT.viewedRound



	-- when the stuff updates, reload the row list as things prob changed
	bs.scores = {}
	for i,v in pairs(self.playerEntryData) do
		bs.scores[v.entryIndex] = v.rowObject
		updateRow(v.rowObject)
		updateScore(v.entryIndex, roundIndex, showAggregate)
	end
end)




SecurePostHook(Battleground_Scoreboard_Player_Row, "SetupOnAcquire", function(self, panel, poolKey, data)
	local showAggregate = BATTLEGROUND_SCOREBOARD_FRAGMENT:ShouldShowAggregateScores()
	local roundIndex = showAggregate and GetCurrentBattlegroundRoundIndex() or BATTLEGROUND_SCOREBOARD_FRAGMENT.viewedRound

	for i=1,GetNumScoreboardEntries() do
		local _, name = GetScoreboardEntryInfo(i)
		if name == data.displayName then
			bs.scores[i] = self
			updateScore(i, roundIndex, showAggregate)
		end
	end
end)


function bs.somethingChanged(code)
	-- logic used in base game BATTLEGROUND_SCOREBOARD_FRAGMENT to identify round index. Hopefully it just works without any issues
	local showAggregate = BATTLEGROUND_SCOREBOARD_FRAGMENT:ShouldShowAggregateScores()
	local roundIndex = showAggregate and GetCurrentBattlegroundRoundIndex() or BATTLEGROUND_SCOREBOARD_FRAGMENT.viewedRound
	
	for i=1,GetNumScoreboardEntries() do
		updateScore(i, roundIndex, showAggregate)
	end
end




function bs.buildQueues()


	-- Code that I adapted from zos's activity finder
	local filterModeData = ZO_ActivityFinderFilterModeData:New(LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL, LFG_ACTIVITY_BATTLE_GROUND_CHAMPION, LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION)
    filterModeData:SetSubmenuFilterNames(GetString(SI_BATTLEGROUND_FINDER_SPECIFIC_FILTER_TEXT), GetString(SI_BATTLEGROUND_FINDER_RANDOM_FILTER_TEXT))
    filterModeData:SetVisibleEntryTypes(ZO_ACTIVITY_FINDER_LOCATION_ENTRY_TYPE.SET)

	for _, activityType in ipairs(filterModeData:GetActivityTypes()) do
		if ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetNumLocationsByActivity(activityType, filterModeData:GetVisibleEntryTypes()) > 0 then
			local isLocked = ZO_ActivityFinderTemplate_Shared:GetLevelLockInfoByActivity(activityType)
			if not isLocked then
				local locationsData = ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetLocationsData(activityType)
				for _, location in ipairs(locationsData) do
					if filterModeData:IsEntryTypeVisible(location:GetEntryType()) and location:IsActive() then
						bs.queues[#bs.queues+1] = location
					end
				end
			end
		end
	end
end

function bs.buildPanel()
	local fragment = ZO_FadeSceneFragment:New(BS_Panel)

	--[[
	self:InitKeybindStrip()
	fragment:RegisterCallback("StateChange",  function(oldState, newState)
					   if(newState == SCENE_SHOWING) then
					      KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
					   elseif(newState == SCENE_HIDDEN) then
					      KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
					   end
	end)
	--]]

	
	




	local checkValues = {
		[TRISTATE_CHECK_BUTTON_UNCHECKED] = false,
		[TRISTATE_CHECK_BUTTON_CHECKED] = true
	}


	local last = BS_PanelData
	local offset = 0


	local rows = {}

	for i,location in ipairs(bs.queues) do

		local row = CreateControlFromVirtual("BS_Row"..i,BS_PanelData,"BS_Row")
		local checkbox = row:GetNamedChild("Check")
		row:GetNamedChild("Name"):SetText(location.rawName)

		rows[i] = {row,location}

		ZO_TriStateCheckButton_SetState(checkbox, TRISTATE_CHECK_BUTTON_UNCHECKED)
		ZO_TriStateCheckButton_SetStateChangeFunction(checkbox, function(control, checkState)
			
			--d("Row ".. i.. " has become "..tostring(checkValues[checkState]))

			local setState = checkValues[checkState]
			local locationName = location.rawName

			location:SetSelected(setState)
			if setState then
				bs.vars.queueSelections[locationName] = true
			elseif (not setState) and (bs.vars.queueSelections[locationName]) then
				bs.vars.queueSelections[locationName] = nil
			end

		end)

		row:SetAnchor(TOPCENTER, last, BOTTOMCENTER, 0, offset)
		last = row
		offset = 20

	end

	local button = CreateControlFromVirtual("BS_QueueButton", BS_PanelData, "BS_QueueButtonTemplate")
	button:SetAnchor(TOPLEFT, last, BOTTOMLEFT, 0, 10)




	fragment:RegisterCallback("StateChange",  function(oldState, newState)
		if(newState == SCENE_SHOWING) then
			local groupSize = GetGroupSize()
			-- Make the solo boxes auto selected if solo, group if in a group
			ZO_ACTIVITY_FINDER_ROOT_MANAGER:ClearSelections()
			for i,data in ipairs(rows) do
				local checkbox = data[1]:GetNamedChild("Check")
				local location = data[2]
				local locationName = location.rawName


				ZO_CheckButton_Enable(checkbox)

				local state = TRISTATE_CHECK_BUTTON_UNCHECKED

				--[[ -- Old logic regarding queue selection
				if (location.minGroupSize <= groupSize and location.maxGroupSize >= groupSize) or
					(location.minGroupSize >= location.maxGroupSize and groupSize == 0) then
						state = TRISTATE_CHECK_BUTTON_CHECKED
				end
				--]]
				if bs.vars.queueSelections[locationName] then
					state = TRISTATE_CHECK_BUTTON_CHECKED
				end

				ZO_TriStateCheckButton_SetState(checkbox, state)
				if groupSize > location.maxGroupSize then
					ZO_CheckButton_Disable(checkbox)
					data[2]:SetSelected(false)
				else
					data[2]:SetSelected(checkValues[state])
				end



			end
		end
   end)





	GROUP_MENU_KEYBOARD:AddCategory({
		name = "Better Scoreboard",--"Lilith's Group Manager",
		categoryFragment = fragment,
		normalIcon = "esoui/art/journal/journal_tabicon_achievements_up.dds",
		--normalIcon = "EsoUI/Art/Icons/guildranks/guild_indexicon_leader_up.dds",
		pressedIcon = "esoui/art/journal/journal_tabicon_achievements_down.dds",
		mouseoverIcon = "esoui/art/journal/journal_tabicon_achievements_over.dds",
		priority = 400
	})
	--if LGM.SV.autoSelectLGM then
	--GROUP_MENU_KEYBOARD.navigationTree:SelectNode(GROUP_MENU_KEYBOARD.categoryFragmentToNodeLookup[fragment])


end



function bs.startSearch()
	if not IsCurrentlySearchingForGroup() then
		ZO_ACTIVITY_FINDER_ROOT_MANAGER:StartSearch()
	end
end




bs.currentName = ""

-- Save statistics after bg ends

function bs.bgEnded(eventCode, previousState, currentState)

	-- Change the bg name on the sidebar
	local name = GetString("SI_BATTLEGROUNDGAMETYPE", GetBattlegroundGameType(GetCurrentBattlegroundId()))
	if not (name == bs.currentName) then 
		bs.currentName = name
		if IsInGamepadPreferredMode() then
			BATTLEGROUND_MATCH_INFO_GAMEPAD.control:GetNamedChild("ContainerTitle"):SetText(name)
		else
			BATTLEGROUND_MATCH_INFO_KEYBOARD.control:GetNamedChild("ContainerTitle"):SetText(name)
		end
	end

	--d("BG State Changed: "..previousState.. " going to "..currentState)
	if (currentState == BATTLEGROUND_STATE_POSTGAME) then
		local player = GetScoreboardPlayerEntryIndex()
		bs.vars.damage = bs.vars.damage + GetScoreboardEntryScoreByType(player, SCORE_TRACKER_TYPE_DAMAGE_DONE)
		bs.vars.heals = bs.vars.heals + GetScoreboardEntryScoreByType(player, SCORE_TRACKER_TYPE_HEALING_DONE)
		--d("Damage: ".. GetScoreboardEntryScoreByType(player, SCORE_TRACKER_TYPE_DAMAGE_DONE))
		--d("Heals: ".. GetScoreboardEntryScoreByType(player, SCORE_TRACKER_TYPE_HEALING_DONE))
		--d("Kills: ".. GetScoreboardEntryScoreByType(player, SCORE_TRACKER_TYPE_KILL))
		--d("Deaths: ".. GetScoreboardEntryScoreByType(player, SCORE_TRACKER_TYPE_DEATH))
		--d("Assists: ".. GetScoreboardEntryScoreByType(player, SCORE_TRACKER_TYPE_ASSISTS))
		local kda = bs.vars.kda

		kda.kills = kda.kills + GetScoreboardEntryScoreByType(player, SCORE_TRACKER_TYPE_KILL)
		kda.deaths = kda.deaths + GetScoreboardEntryScoreByType(player, SCORE_TRACKER_TYPE_DEATH)
		kda.assists = kda.assists + GetScoreboardEntryScoreByType(player, SCORE_TRACKER_TYPE_ASSISTS)

		local fire = GetCurrentBattlegroundScore(BATTLEGROUND_ALLIANCE_FIRE_DRAKES)
		local pit = GetCurrentBattlegroundScore(BATTLEGROUND_ALLIANCE_PIT_DAEMONS)
		local storm = GetCurrentBattlegroundScore(BATTLEGROUND_ALLIANCE_STORM_LORDS)
		local playerAlliance = GetUnitBattlegroundAlliance('player')

		local places = {}

		if (fire > pit) and (fire > storm) then
			places[BATTLEGROUND_ALLIANCE_FIRE_DRAKES] = 1

			if (pit > storm) then
				places[BATTLEGROUND_ALLIANCE_PIT_DAEMONS] = 2
				places[BATTLEGROUND_ALLIANCE_STORM_LORDS] = 3
			else
				places[BATTLEGROUND_ALLIANCE_STORM_LORDS] = 2
				places[BATTLEGROUND_ALLIANCE_PIT_DAEMONS] = 3
			end

		elseif (pit > fire) and (pit > storm) then
			places[BATTLEGROUND_ALLIANCE_PIT_DAEMONS] = 1

			if (fire > storm) then
				places[BATTLEGROUND_ALLIANCE_FIRE_DRAKES] = 2
				places[BATTLEGROUND_ALLIANCE_STORM_LORDS] = 3
			else
				places[BATTLEGROUND_ALLIANCE_STORM_LORDS] = 2
				places[BATTLEGROUND_ALLIANCE_FIRE_DRAKES] = 3
			end

		else
			places[BATTLEGROUND_ALLIANCE_STORM_LORDS] = 1

			if (fire > pit) then
				places[BATTLEGROUND_ALLIANCE_FIRE_DRAKES] = 2
				places[BATTLEGROUND_ALLIANCE_PIT_DAEMONS] = 3
			else
				places[BATTLEGROUND_ALLIANCE_PIT_DAEMONS] = 2
				places[BATTLEGROUND_ALLIANCE_FIRE_DRAKES] = 3
			end

		end

		--[[
		wlt = {
			wins = 0,
			losses = 0,
			ties = 0
		},
		]]


		local wlt = bs.vars.wlt

		--d("Place: ".. places[playerAlliance])
		if (places[playerAlliance] == 1) then
			wlt.wins = wlt.wins + 1
		elseif (places[playerAlliance] == 2) then
			wlt.ties = wlt.ties + 1
		else
			wlt.losses = wlt.losses + 1
		end
	end
end




function bs.updateLocations()
	bs.buildQueues()
	bs.buildPanel()
	ZO_ACTIVITY_FINDER_ROOT_MANAGER:UnregisterCallback("OnUpdateLocationData", bs.updateLocations)
end




-- The following was adapted from https://wiki.esoui.com/Circonians_Stamina_Bar_Tutorial#lua_Structure

-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function bs.OnAddOnLoaded(event, addonName)
	if addonName ~= bs.name then return end

	bs:Initialize()
end
 
-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function bs:Initialize()
	EVENT_MANAGER:UnregisterForEvent(bs.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(bs.name, EVENT_BATTLEGROUND_SCOREBOARD_UPDATED, bs.somethingChanged)


	--commenting out statistic collection until further notice (when i feel like updating it); its not like it was even being shown previously
	--EVENT_MANAGER:RegisterForEvent(bs.name, EVENT_BATTLEGROUND_STATE_CHANGED, bs.bgEnded)
	
	bs.vars = ZO_SavedVars:NewCharacterIdSettings("BSVars", 2, nil, defaultSettings)
	ZO_ACTIVITY_FINDER_ROOT_MANAGER:RegisterCallback("OnUpdateLocationData", bs.updateLocations)
end
 
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(bs.name, EVENT_ADD_ON_LOADED, bs.OnAddOnLoaded)