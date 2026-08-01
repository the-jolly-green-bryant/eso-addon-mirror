local ADDON_NAME			= "QuickEmotes"
local ADDON_AUTHOR			= "@KL1SK"
local ADDON_WEBSITE			= "https://www.esoui.com/downloads/info2348-QuickEmotes.html"
--===============================================================================================--
QuickEmotes = {}

local QE = QuickEmotes
local SM = SCENE_MANAGER
local EM = EVENT_MANAGER
local MIO = MouseIsOver
local PEM = PLAYER_EMOTE_MANAGER

local width = 214
local height = 24
local sharp = 0.8
local alphaOn, alphaOff = 1, .3

ZO_CreateStringId("SI_BINDING_NAME_QUICK_EMOTES", "Quick Emotes");

local function Settings()
	panelData = {
		type							= "panel",
		name							= ADDON_NAME,
		author							= ADDON_AUTHOR,
		website							= ADDON_WEBSITE,
		slashCommand					= "/qemotes",
		registerForRefresh				= true,
		registerForDefaults				= true,
	}
	local SV_VER						= 0.1
	local DEF = {
		button_position_x				= 0,
		showing_submenu_delay			= 200,
		disable_cur_mod_select			= true,
	}
	local SV = ZO_SavedVars:NewAccountWide(ADDON_NAME .. "_SV", SV_VER, "Options", DEF, GetWorldName())
	QE.SV = SV
	--LibAddonMenu2-------------------------------------------
	if not LibAddonMenu2 then return end
	optionsData = {
		{	type				= "slider",
			name				= "Quick Emotes Button - Position X",
			max					= 0,
			min					= -250,
			getFunc				= function() return SV.button_position_x end,
			setFunc				= function(value) SV.button_position_x = value QE.button:SetAnchor(RIGHT, ZO_ChatWindowOptions, LEFT, SV.button_position_x, 0) end,
			-- width				= "half",
			default				= DEF.button_position_x,
		},
		{	type				= "slider",
			name				= "Delay emergence submenu(ms). 0 = off",
			tooltip				= "Delay the appearance of a submenu when you hover the mouse.",
			max					= 1000,
			min					= 0,
			getFunc				= function() return SV.showing_submenu_delay end,
			setFunc				= function(value) SV.showing_submenu_delay = value end,
			-- width				= "half",
			default				= DEF.showing_submenu_delay,
		},
		{	type				= "checkbox",
			name				= "Disable cursor mode when selecting emotions.",
			getFunc				= function() return SV.disable_cur_mod_select end,
			setFunc				= function(value) SV.disable_cur_mod_select = value end,
			default				= DEF.disable_cur_mod_select,
		},
	}

	LibAddonMenu2:RegisterAddonPanel(ADDON_NAME .. "Options", panelData)
	LibAddonMenu2:RegisterOptionControls(ADDON_NAME .. "Options", optionsData)
end

local function Core()
	local TEXT_COLOR_NORMAL				= {GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL)}
	local TEXT_COLOR_CONTEXT_HIGHLIGHT	= {GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_CONTEXT_HIGHLIGHT)}

	local function DisableMouseMode(key)
		if not key then return end
		if SM:GetScene("hud"):IsShowing() or SM:GetScene("hudui"):IsShowing() then
			SM:SetInUIMode(false)
		end
	end

	local function CreateMenu(name, parent)
		local menu = CreateControl(name, parent)
		menu:SetInheritAlpha(false)
		menu:SetMouseEnabled(true)
		menu:SetHidden(true)
		menu:SetResizeToFitDescendents(true)
		menu:SetClampedToScreen(true)

		local bg = CreateControl("$(parent)Bg", menu, CT_BACKDROP)
		bg:SetAnchor(TOPLEFT, menu, TOPLEFT, -4, -4)
		bg:SetAnchor(BOTTOMRIGHT, menu, BOTTOMRIGHT, 4, 4)
		bg:SetCenterColor(10/255, 10/255, 10/255, .96)
		bg:SetEdgeTexture(nil, 1, 1, 1, 0)
		bg:SetEdgeColor(60/255, 60/255, 60/255, 1)
		bg:SetInsets(-1, -1, 1, 1)
		bg:SetExcludeFromResizeToFitExtents(true)
		menu.bg = bg

		return menu
	end

	local function Row_OnMouseEnter(row)
		row.label:SetColor(unpack(TEXT_COLOR_CONTEXT_HIGHLIGHT))
		row:SetCenterColor(96/255*.4, 125/255*.4, 139/255*.4, 1)
	end
	local function Row_OnMouseExit(row)
		row.label:SetColor(unpack(TEXT_COLOR_NORMAL))
		row:SetCenterColor(96/255*.3, 125/255*.3, 139/255*.3, 0)
	end

	local function ShowSubMenu(menuRow, state)
		local menu		= QE.menu
		local subMenu	= QE.subMenu
		local pool		= subMenu.rowPool

		if menu.selectedRow then

			if menu.selectedRow == menuRow then return end

			menu.selectedRow.arrow:SetAlpha(alphaOff)
			menu.selectedRow = nil
		end

		if state then
			pool:ReleaseAllObjects()
			menuRow.arrow:SetAlpha(alphaOn)
			menu.selectedRow = menuRow

			subMenu.width = 0

			subMenu:ClearAnchors()
			subMenu:SetAnchor(LEFT, menuRow, RIGHT, 10, 0)
			
			for _, id in pairs(PEM.emoteCategories[menuRow.category]) do
				local row = pool:AcquireObject()
				row.data = PEM.emoteList[id]

				row.label:SetText(row.data.displayName)
				
				local textWidth = row.label:GetTextWidth()
				if subMenu.width < textWidth then
					subMenu.width = textWidth
				end
			end

			PlaySound(SOUNDS.TREE_HEADER_CLICK)
			subMenu:SetWidth(subMenu.width + 8)

		end

		subMenu:SetHidden(not state)
	end

	function QE:MenuToggle(key)
		local menu = self.menu
		if menu:IsHidden() then
			menu:SetHidden(false)
			SM:SetInUIMode(true)
		else
			menu:SetHidden(true)

			DisableMouseMode(key)
		end
	end

	local button = CreateControl(ADDON_NAME .. "_Button", ZO_ChatWindow, CT_BUTTON)
	button:SetNormalTexture("EsoUI/Art/Help/help_tabIcon_emotes_up.dds")
	button:SetPressedTexture("EsoUI/Art/Help/help_tabIcon_emotes_down.dds")
	button:SetMouseOverTexture("EsoUI/Art/Help/help_tabIcon_emotes_over.dds")
	button:SetAnchor(RIGHT, ZO_ChatWindowOptions, LEFT, QE.SV.button_position_x, 0)
	button:SetDimensions(32, 32)
	button:SetClickSound(SOUNDS.DEFAULT_CLICK)

	button:SetHandler("OnMouseUp", function(self, mouseButton, upInside)
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT and upInside then
			QE:MenuToggle()
		end
	end)

	QE.button = button
--Menu-------------------------------------------
	local menu = CreateMenu(ADDON_NAME .. "_Menu", button)
	QE.menu = menu
	
	menu:SetAnchor(BOTTOMLEFT, button, TOP, 0, 0)

	menu:SetHandler("OnShow", function(self)
		self:RegisterForEvent(EVENT_GLOBAL_MOUSE_UP, function()
			if MIO(self) or MIO(button) then return end
			if QE.subMenu.lock then
				QE.subMenu.lock = nil
				return
			end
			self:SetHidden(true)
		end)
		self:RegisterForEvent(EVENT_ACTION_LAYER_POPPED, function()
			if self:IsHidden() then return end
			self:SetHidden(true)
		end)
	end)

	menu:SetHandler("OnHide", function(self)
		self:UnregisterForEvent(EVENT_GLOBAL_MOUSE_UP)
		self:UnregisterForEvent(EVENT_ACTION_LAYER_POPPED)
		ShowSubMenu(nil, false)
	end)

	--MenuItems----------------------------------
	local lastRow
	for key, category in pairs(PEM.emoteCategoryTypes) do

		local row = CreateControl("$(parent)Row" .. key, menu, CT_BACKDROP)
		row:SetMouseEnabled(true)
		row:SetDimensions(width, height)
		row:SetCenterColor(96/255*.3, 125/255*.3, 139/255*.3, 0)
		row:SetEdgeTexture(nil, 1, 1, 1, 0)
		row:SetEdgeColor(0, 0, 0, 0)
		
		local arrow = CreateControl("$(parent)Arrow", row, CT_TEXTURE)
		arrow:SetTexture("EsoUI/Art/Buttons/tree_closed_up.dds")
		arrow:SetAnchor(RIGHT, row, RIGHT, 0, 0)
		arrow:SetDimensions(height * sharp, height)
		arrow:SetTextureCoords(0, sharp, 0, 1)
		arrow:SetAlpha(alphaOff)
		row.arrow = arrow

		local label = CreateControl("$(parent)Label", row, CT_LABEL)
		label:SetAnchor(LEFT, row, LEFT, 4, 0)
		label:SetAnchor(RIGHT, arrow, LEFT, 0, 0)
		label:SetMaxLineCount(1)
		label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
		label:SetFont("$(MEDIUM_FONT)|18|shadow")
		label:SetColor(unpack(TEXT_COLOR_NORMAL))
		label:SetText(GetString("SI_EMOTECATEGORY", category))
		row.label = label

		row.category = category

		local eventName = "qe_submenu"

		row:SetHandler("OnMouseUp", function(self, mouseButton, upInside)
			if mouseButton == MOUSE_BUTTON_INDEX_LEFT and upInside then
				ShowSubMenu(self, true)
				
				EM:UnregisterForUpdate(eventName)
			end
		end)

		row:SetHandler("OnMouseEnter", function(self)
			Row_OnMouseEnter(self)

			if QE.SV.showing_submenu_delay == 0 then return end
			EM:RegisterForUpdate(eventName, QE.SV.showing_submenu_delay, function()
				EM:UnregisterForUpdate(eventName)
				if MIO(self) and menu.selectedRow ~= self then
					ShowSubMenu(self, true)
				end
			end)
		end)

		row:SetHandler("OnMouseExit", function(self)
			Row_OnMouseExit(self)

			EM:UnregisterForUpdate(eventName)
		end)

		-----------------------------------------
		-- control:SetAnchor(TOPLEFT)
		-- control:SetAnchor(TOPRIGHT)
	-- else
		-- control:SetAnchor(TOPLEFT, pool.m_Active[controlId - 1], BOTTOMLEFT, 0, 0)
		-- control:SetAnchor(TOPRIGHT, pool.m_Active[controlId - 1], BOTTOMRIGHT, 0, 0)
		if not lastRow then
			row:SetAnchor(TOPLEFT)
			lastRow = row
		else
			row:SetAnchor(TOPLEFT, lastRow, BOTTOMLEFT, 0, 0)
			lastRow = row
		end
	end

--SubMenu----------------------------------------
	local subMenu = CreateMenu(ADDON_NAME .. "_SubMenu", menu.bg)
	QE.subMenu = subMenu

	--SubMenuItems-------------------------------
	local function CreateEntry(pool)
		local id = pool:GetNextControlId()

		local row = CreateControl("$(parent)Row" .. id, subMenu, CT_BACKDROP)
		row:SetMouseEnabled(true)
		-- row:SetDimensions(width, height)
		row:SetResizeToFitDescendents(true)
		row:SetCenterColor(96/255*.3, 125/255*.3, 139/255*.3, 0)
		row:SetEdgeTexture(nil, 1, 1, 1, 0)
		row:SetEdgeColor(0, 0, 0, 0)

		local label = CreateControl("$(parent)Label", row, CT_LABEL)
		label:SetAnchor(LEFT, row, LEFT, 4, 0)
		label:SetMaxLineCount(1)
		label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
		label:SetFont("$(MEDIUM_FONT)|18|shadow")
		label:SetColor(unpack(TEXT_COLOR_NORMAL))
		row.label = label

		row:SetHandler("OnMouseEnter", function(self)
			Row_OnMouseEnter(self)
		end)

		row:SetHandler("OnMouseExit", function(self)
			Row_OnMouseExit(self)
		end)

		row:SetHandler("OnMouseUp", function(self, mouseButton, upInside)
			if mouseButton == MOUSE_BUTTON_INDEX_LEFT and upInside then
				if upInside then
					PlayEmoteByIndex(self.data.emoteIndex)
					DisableMouseMode(QE.SV.disable_cur_mod_select)
				end
			elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
				QE.subMenu.lock = true
				if upInside then
					PlayEmoteByIndex(self.data.emoteIndex)
				end
			end
		end)

		pool.customAcquireBehavior = function(control, controlId)
			if control then
				if controlId == 1 then
					control:SetAnchor(TOPLEFT)
					control:SetAnchor(TOPRIGHT)
				else
					control:SetAnchor(TOPLEFT, pool.m_Active[controlId - 1], BOTTOMLEFT, 0, 0)
					control:SetAnchor(TOPRIGHT, pool.m_Active[controlId - 1], BOTTOMRIGHT, 0, 0)
				end
				control:SetHidden(false)
			end
		end

		return row
	end

	local function ResetEntry(control, pool)
		control:SetHidden(true)
		control:ClearAnchors()
		control.data = nil
	end

	subMenu.rowPool = ZO_ObjectPool:New(CreateEntry, ResetEntry)
end

local function OnAddonLoaded(eventType, addonName)
	if addonName == ADDON_NAME then
		--
		Settings()
		Core()
		--
		EM:UnregisterForEvent(ADDON_NAME, eventType)
	end
end
EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)