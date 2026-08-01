local ADDON_NAME			= "MarkPledges"
local ADDON_AUTHOR			= "@KL1SK"
local ADDON_WEBSITE			= "https://www.esoui.com/downloads/info2261-MarkPledges.html"
--===============================================================================================--
MarkPledges = {}
local MP = MarkPledges

local checkNormal
local function Settings()

	local SV_VER						= 0.1
	local DEF = {
		marks_col						= {220/255, 216/255, 34/255, 1},
		marks_normal					= true,
		autoSelect_normal				= false,
		marks_veteran					= true,
		autoSelect_veteran				= false,
		debug_toggle					= false,
		buttons_posX					= -18,
		buttons_posY					= 0,
	}
	MP.SV = ZO_SavedVars:NewAccountWide(ADDON_NAME, SV_VER, "Options", DEF, GetWorldName())
	local SV = MP.SV

	--LibAddonMenu2------------------------------

	if not LibAddonMenu2 then return end

	panelData = {
		type							= "panel",
		name							= ADDON_NAME,
		author							= ADDON_AUTHOR,
		website							= ADDON_WEBSITE,
		slashCommand					= "/markp",
		registerForRefresh				= true,
		registerForDefaults				= true,
	}

	optionsData = {
		{	type				= "colorpicker",
			name				= GetString(MARKPLEDGES_COLOR),
			getFunc				= function() return unpack(SV.marks_col) end,
			setFunc				= function(r, g, b, a) SV.marks_col = { r, g, b, a } end,
			width				= "full",
			default				= {r = DEF.marks_col[1], g = DEF.marks_col[2], b = DEF.marks_col[3], a = DEF.marks_col[4]},
		},
		{	type				= "checkbox",
			name				= GetString(MARKPLEDGES_MARK_NORMAL_DUNGEONS),
		 	tooltip				= GetString(MARKPLEDGES_MARK_NORMAL_DUNGEONS_TT),
			getFunc				= function() return SV.marks_normal end,
			setFunc				= function(value) SV.marks_normal = value end,
			default				= DEF.marks_normal,
		},
		{	type				= "checkbox",
			name				= GetString(MARKPLEDGES_MARK_VET_DUNGEONS),
			tooltip				= GetString(MARKPLEDGES_MARK_VET_DUNGEONS_TT),
			getFunc				= function() return SV.marks_veteran end,
			setFunc				= function(value) SV.marks_veteran = value end,
			default				= DEF.marks_veteran,
		},
		{	type				= "slider",
			name				= GetString(MARKPLEDGES_CHECK_BUTTONS_POSITION_X),
			max					= 250,
			min					= -250,
			getFunc				= function() return SV.buttons_posX end,
			setFunc				= function(value) SV.buttons_posX = value checkNormal:SetAnchor(BOTTOM, ZO_SearchingForGroupStatus, TOP, SV.buttons_posX, SV.buttons_posY) end,
			width				= "half",
			default				= DEF.buttons_posX,
		},
		{	type				= "slider",
			name				= GetString(MARKPLEDGES_CHECK_BUTTONS_POSITION_Y),
			max					= 250,
			min					= -250,
			getFunc				= function() return SV.buttons_posY end,
			setFunc				= function(value) SV.buttons_posY = value checkNormal:SetAnchor(BOTTOM, ZO_SearchingForGroupStatus, TOP, SV.buttons_posX, SV.buttons_posY) end,
			width				= "half",
			default				= DEF.buttons_posY,
		},
		-- {	type				= "checkbox",
			-- name				= GetString(MARKPLEDGES_DEBUG),
			-- getFunc				= function() return SV.debug_toggle end,
			-- setFunc				= function(value) SV.debug_toggle = value end,
			-- default				= DEF.debug_toggle,
		-- },
	}
	LibAddonMenu2:RegisterAddonPanel(ADDON_NAME .. "Options", panelData)
	LibAddonMenu2:RegisterOptionControls(ADDON_NAME .. "Options", optionsData)
end
--===============================================================================================--
local function Pledges()
	local treeEntry	= DUNGEON_FINDER_KEYBOARD.navigationTree.templateInfo.ZO_ActivityFinderTemplateNavigationEntry_Keyboard
	local pool		= treeEntry.objectPool

	local function DebugLog(arg)
		if SV.debug_toggle then
			d(string.format("%s", arg))
		end
	end
	
	local function CheckPledges(pledgeActivityType)
		local m_active = pool.m_Active
		for k,v in pairs(m_active) do
			if v.pledge and v.pledge == pledgeActivityType then
				ZO_CheckButton_OnClicked(v.check)
				ZO_ACTIVITY_FINDER_ROOT_MANAGER:ToggleLocationSelected(v.node.data)
			end
		end
	end

	local parent = DUNGEON_FINDER_KEYBOARD.listSection

	local autoCheckVeteran = CreateControlFromVirtual("$(parent)AutoCheckVeteran", parent, "ZO_CheckButton")	--ZO_CheckButton
	autoCheckVeteran:SetAnchor(BOTTOMLEFT, parent, TOPLEFT, 10, -15)
	ZO_CheckButton_SetLabelText(autoCheckVeteran, GetString(MARKPLEDGES_AUTO_CHECK_VET_DUNGEONS))
	
	local autoCheckNormal = CreateControlFromVirtual("$(parent)AutoCheckNormal", parent, "ZO_CheckButton")	--ZO_CheckButton
	ZO_CheckButton_SetLabelText(autoCheckNormal, GetString(MARKPLEDGES_AUTO_CHECK_NORMAL_DUNGEONS))
	autoCheckNormal:SetAnchor(BOTTOMLEFT, autoCheckVeteran, TOPLEFT, 0, -5)

	local function OnAutoCheckChanged()
		MP.SV.autoSelect_normal	= ZO_CheckButton_IsChecked(autoCheckNormal)
		MP.SV.autoSelect_veteran	= ZO_CheckButton_IsChecked(autoCheckVeteran)
	end

	ZO_CheckButton_SetToggleFunction(autoCheckNormal, OnAutoCheckChanged)
	ZO_CheckButton_SetToggleFunction(autoCheckVeteran, OnAutoCheckChanged)
	
	checkNormal = CreateControl("$(parent)CheckNormal", parent, CT_BUTTON)
	checkNormal:SetNormalTexture("EsoUI/Art/LFG/LFG_normalDungeon_up.dds")
	checkNormal:SetPressedTexture("EsoUI/Art/LFG/LFG_normalDungeon_down.dds")
	checkNormal:SetMouseOverTexture("EsoUI/Art/LFG/LFG_normalDungeon_over.dds")
	checkNormal:SetAnchor(BOTTOM, ZO_SearchingForGroupStatus, TOP, MP.SV.buttons_posX, MP.SV.buttons_posY)
	checkNormal:SetDimensions(36, 36)
	checkNormal:EnableMouseButton(MOUSE_BUTTON_INDEX_RIGHT, true)
	checkNormal:SetHandler("OnClicked", function(self, button)
		CheckPledges(LFG_ACTIVITY_DUNGEON)
	end)
	
	local checkVeteran = CreateControl("$(parent)CheckVeteran", parent, CT_BUTTON)
	checkVeteran:SetNormalTexture("EsoUI/Art/LFG/LFG_veteranDungeon_up.dds")
	checkVeteran:SetPressedTexture("EsoUI/Art/LFG/LFG_veteranDungeon_down.dds")
	checkVeteran:SetMouseOverTexture("EsoUI/Art/LFG/LFG_veteranDungeon_over.dds")
	checkVeteran:SetAnchor(TOPLEFT, checkNormal, TOPRIGHT, 0, 0)
	checkVeteran:SetDimensions(36, 36)
	checkVeteran:EnableMouseButton(MOUSE_BUTTON_INDEX_RIGHT, true)
	checkVeteran:SetHandler("OnClicked", function(self, button)
		CheckPledges(LFG_ACTIVITY_MASTER_DUNGEON)
	end)

	local QuestCache = {}
	local function GetPledges()
		for i=1, MAX_JOURNAL_QUESTS do
			local name, _, _, _, _, completed, _, _, _, questType, _ = GetJournalQuestInfo(i)
			if questType == QUEST_TYPE_UNDAUNTED_PLEDGE and completed == false then
				local instance = string.format("%s", name:lower():gsub(".*:%s*", ""):gsub("%si$", " 1"):gsub("%sii$", " 2"))	--	:gsub("%s+", " ")
				table.insert(QuestCache, instance)
				-- DebugLog("table.insert >> " .. instance)
			end
			if #QuestCache == 3 then break end
		end
	end

	local function AutoSelect(control, data)
		if not MP.SV.autoSelect_normal and not MP.SV.autoSelect_veteran then return end
		if control.enabled and control.check:GetState() == 0 then
			if MP.SV.marks_normal and MP.SV.autoSelect_normal and data:GetActivityType() == LFG_ACTIVITY_DUNGEON then
				ZO_CheckButton_OnClicked(control.check)
				ZO_ACTIVITY_FINDER_ROOT_MANAGER:ToggleLocationSelected(control.node.data)
			end
			if MP.SV.marks_veteran and MP.SV.autoSelect_veteran and data:GetActivityType() == LFG_ACTIVITY_MASTER_DUNGEON then
				ZO_CheckButton_OnClicked(control.check)
				ZO_ACTIVITY_FINDER_ROOT_MANAGER:ToggleLocationSelected(control.node.data)
			end
		end
	end

	local function Marks(control, data, pledgeActivityType)
		local rawName = string.format("%s", data.rawName:lower():gsub("%si$", " 1"):gsub("%sii$", " 2"))	--	:gsub("%s+", " ")
		for i=1, #QuestCache do
			local name = QuestCache[i]
			if rawName == name or rawName:match(string.format(".*%s.*", name:gsub("%s+", ".*"))) or name:match(string.format(".*%s", rawName:gsub("%s+", ".*"))) then
				control.pledge = pledgeActivityType
				AutoSelect(control, data)
				-- DebugLog("N" .. i .. name .. " == " .. rawName)
				break
			end
		end
	end

	local function GetTextColor(self)
		local r, g, b, a = MP.SV.marks_col[1], MP.SV.marks_col[2], MP.SV.marks_col[3], MP.SV.marks_col[4]
		local pledge = self.owner.pledge

		if not self.enabled then
			if pledge then
				return r*.2, g*.2, b*.2, a
			else
				return GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED)
			end
		elseif self.selected then
			return GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)
		elseif self.mouseover then
			return GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HIGHLIGHT)
		else
			if pledge then
				return r, g, b, a
			else
				return self.normalColor:UnpackRGBA()
			end
		end
	end

	pool:SetCustomFactoryBehavior(function(control)
		local label = control.text
		label.owner = control
		label.GetTextColor = GetTextColor
    end)

	--TreeEntrySetup(node, control, data, open)
	local existingSetupCallback = treeEntry.setupFunction
	treeEntry.setupFunction = function(node, control, data, open)
		existingSetupCallback(node, control, data, open)

		control.pledge = nil

		if #QuestCache ~= 0 then
			if MP.SV.marks_normal and data:GetActivityType() == LFG_ACTIVITY_DUNGEON then
				Marks(control, data, LFG_ACTIVITY_DUNGEON)
			end
			if MP.SV.marks_veteran and data:GetActivityType() == LFG_ACTIVITY_MASTER_DUNGEON then
				Marks(control, data, LFG_ACTIVITY_MASTER_DUNGEON)
			end
		end

		control.text:RefreshTextColor()
	end

	ZO_PreHookHandler(ZO_DungeonFinder_KeyboardListSection, 'OnEffectivelyShown', function()
		GetPledges()
		if MP.SV.marks_normal then
			checkNormal:SetHidden(false)
			autoCheckNormal:SetHidden(false)
			ZO_CheckButton_SetCheckState(autoCheckNormal, MP.SV.autoSelect_normal)
		else
			checkNormal:SetHidden(true)
			autoCheckNormal:SetHidden(true)
		end
		if MP.SV.marks_veteran then
			checkVeteran:SetHidden(false)
			autoCheckVeteran:SetHidden(false)
			ZO_CheckButton_SetCheckState(autoCheckVeteran, MP.SV.autoSelect_veteran)
		else
			checkVeteran:SetHidden(true)
			autoCheckVeteran:SetHidden(true)
		end
 	end)

	ZO_PreHookHandler(ZO_DungeonFinder_KeyboardListSection, 'OnEffectivelyHidden', function()
		QuestCache = {}
	end)
end

local function OnAddonLoaded(eventType, addonName)
	if addonName == ADDON_NAME then
		--
		Settings()
		Pledges()
		--
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	end
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)