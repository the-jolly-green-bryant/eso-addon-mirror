Main = Main or {}
Main.Name = "SeducerTracker"
Main.Version = "1.0"

Main.Panel = ZO_SimpleSceneFragment:New(MainTrackerPanel)
Main.Countdown = 9
Main.Alpha = 1
Main.SeducerInd = false
Main.SeducerStartInd = false
Main.SeducerStartTime = 0
Main.SpellsList = {61745, 61694, 61747, 61716, 109966}
Main.Spells = {
	--arcanist Skill
	[61745] = {
		["Color"] = {0.33, 0.89, 0.95, 0.7}  --"54e4f1",
	},
	--arcanist Skill
	[61694] = {
		["Color"] = {0.52, 0.03, 0.59, 0.7}  --"860896",
	},
	--arcanist Skill
	[61747] = {
		["Color"] = {1, 1, 1, 0.7}  --"ffffff",
	},
	--arcanist Skill
	[61716] = {
		["Color"] = {0.79, 0.29, 0.77, 0.7} --"cb4bc4",
	},
	--arcanist Skill
	[109966] = {
		["Color"] = {1, 0.8, 0.09, 0.7} --"ffcc18",
	},
}

function Main.UpdatePanel()
	MainTrackerPanelLabel:SetColor(1,1,1,Main.Alpha)
	MainTrackerPanelLabel:SetText(tostring(Main.Countdown))

	Main.Countdown = Main.Countdown - 1
	if Main.Countdown < 0 then
		EVENT_MANAGER:UnregisterForUpdate("MainTrackerLoop")
	end
end

function Main.OnEffectChanged(a1, changeType, a2, effectName, unitTag, beginTime, endTime, a3, icon, a4, a5, a6, a7, charName, unitId, abilityId, sourceType)
	if abilityId == 221535 then
		if changeType == 1 then
			Main.SeducerInd = true
			MainTrackerPanel:SetHidden(false)
			HUD_SCENE:AddFragment(Main.Panel)
			HUD_UI_SCENE:AddFragment(Main.Panel)
			Main.SeducerStartInd = true
			Main.SeducerStartTime = beginTime
			
			Main.Countdown = 9
			Main.UpdatePanel()
			EVENT_MANAGER:RegisterForUpdate("MainTrackerLoop", 1000, Main.UpdatePanel)
		end
		if changeType == 2 then
			Main.SeducerInd = false
			MainTrackerPanel:SetHidden(true)
			HUD_SCENE:RemoveFragment(Main.Panel)
			HUD_UI_SCENE:RemoveFragment(Main.Panel)
			
			Main.SeducerStartInd = false
			Main.SeducerStartTime = 0
			MainTrackerPanelIcon:SetTexture("/esoui/art/icons/ability_buff_major_evasion.dds") --/esoui/art/icons/ability_mage_025.dds
			MainTrackerPanelBox:SetColor(0.79, 0.29, 0.77, 0.7)
		end
	end
	
	local deltaTime = beginTime - Main.SeducerStartTime
	if (Main.SeducerInd and changeType == 1 and beginTime == endTime and  deltaTime < 0.15) or (Main.SeducerInd and changeType == 1 and deltaTime < 0)then
		local SpellsListInd = false
		for i = 1, 5 do
			if Main.SpellsList[i] == abilityId then
				SpellsListInd = true
			end
		end
		
		if SpellsListInd then
			MainTrackerPanelIcon:SetTexture(icon)
			cr = Main.Spells[abilityId].Color
			MainTrackerPanelBox:SetColor(cr[1], cr[2], cr[3], cr[4])
		end
	end
end

function Main.ResetPanelPosition()
	local panelLeft = Main.SavedVariables.Panel.Left
	local panelTop = Main.SavedVariables.Panel.Top
	if panelTop > -1 and panelLeft > -1 then
		MainTrackerPanel:ClearAnchors()
		MainTrackerPanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, panelLeft, panelTop)
	end	
end

function Main.InitSavedVariables()
	local defaults = {
		Panel = {
			["Top"] = -1,
			["Left"] = -1,
		},
	}
	local visible = {
		["Ind"] = true,
	}

	Main.SavedVariables = ZO_SavedVars:NewAccountWide("SeducerTrackerSV", 1, nil, defaults)
	Main.Visible = ZO_SavedVars:NewCharacterNameSettings("SeducerTrackerSV", 1, nil, visible)
end

local function slashCommandFunction(extra)
	Main.Visible.Ind = not Main.Visible.Ind
	
	if Main.Visible.Ind then
		Main.Alpha = 1
	else
		Main.Alpha = 0
	end
	
	MainTrackerPanelLabel:SetColor(1,1,1,Main.Alpha)
end

SLASH_COMMANDS["/seducer"] = slashCommandFunction

function Main.OnAddOnLoaded(_, addonName)
	if addonName ~= Main.Name then return end
	
	Main.InitSavedVariables()
	Main.ResetPanelPosition()
	
	if Main.Visible.Ind then
		Main.Alpha = 1
	else
		Main.Alpha = 0
	end
	
	EVENT_MANAGER:RegisterForEvent(Main.Name, EVENT_EFFECT_CHANGED, Main.OnEffectChanged)
	EVENT_MANAGER:AddFilterForEvent(Main.Name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
end

EVENT_MANAGER:RegisterForEvent(Main.Name, EVENT_ADD_ON_LOADED, Main.OnAddOnLoaded)