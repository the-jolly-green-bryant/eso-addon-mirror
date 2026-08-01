Mephisto = Mephisto or {}
local MP = Mephisto

MP.gui = MP.gui or {}
local MPG = MP.gui

local PANEL_WIDTH = 245
local PANEL_HEIGHT = 70
local PANEL_WIDTH_MINI = PANEL_WIDTH - 70
local PANEL_HEIGHT_MINI = PANEL_HEIGHT - 30

local PANEL_DEFAULT_TOP = ActionButton8:GetTop() - 10
local PANEL_DEFAULT_LEFT = ActionButton8:GetLeft() + ActionButton8:GetWidth() + 2

local WINDOW_WIDTH = 360
local WINDOW_HEIGHT = 665

local TITLE_HEIGHT = 50
local TOP_MENU_HEIGHT = 50
local PAGE_MENU_HEIGHT = 40
local BOTTOM_MENU_HEIGHT = 36
local DIVIDER_HEIGHT = 2

local SETUP_BOX_WIDTH = 350
local SETUP_BOX_HEIGHT = 128

function MPG.Init()
	MPG.name = MP.name .. "Gui"
	MPG.setupTable = {}

	MPG.HandleFirstStart()
	MPG.SetSceneManagement()
	MPG.SetDialogManagement()

	MPG.SetupPanel()
	MPG.SetupWindow()
	MPG.SetupPageMenu()
	MPG.SetupSetupList()
	MPG.SetupBottomMenu()
	MPG.CreateSetupPool()
	MPG.SetupTopMenu()

	MPG.SetupModifyDialog()
	MPG.SetupArrangeDialog()

	MPG.RegisterEvents()

	zo_callLater( function() MPG.OnWindowResize( "stop" ) end, 250 )
end

function MPG.RegisterEvents()
	EVENT_MANAGER:RegisterForEvent( MPG.name, EVENT_PLAYER_DEAD, function() MephistoPanel.fragment:Refresh() end )
	EVENT_MANAGER:RegisterForEvent( MPG.name, EVENT_PLAYER_ALIVE, function() MephistoPanel.fragment:Refresh() end )
end

function MPG.HandleFirstStart()
	if not MP.settings.changelogs then MP.settings.changelogs = {} end

	if not MP.settings.initialized then
		local function HandleClickEvent( rawLink, mouseButton, linkText, linkStyle, linkType, dataString )
			if linkType ~= MP.LINK_TYPES.URL then return end
			if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
				if dataString == "esoui" then
					RequestOpenUnsafeURL( "https://MPw.esoui.com/downloads/info3170-Mephisto.html" )
				end
			end
			return true
		end
		LibChatMessage:RegisterCustomChatLink( MP.LINK_TYPES.URL, function( linkStyle, linkType, data, displayText )
			return ZO_LinkHandler_CreateLinkWithoutBrackets( displayText, nil, MP.LINK_TYPES.URL, data )
		end )
		LINK_HANDLER:RegisterCallback( LINK_HANDLER.LINK_MOUSE_UP_EVENT, HandleClickEvent )
		LINK_HANDLER:RegisterCallback( LINK_HANDLER.LINK_CLICKED_EVENT, HandleClickEvent )
		zo_callLater( function()
						  local urlLink = ZO_LinkHandler_CreateLink( "esoui.com", nil, MP.LINK_TYPES.URL, "esoui" )
						  local pattern = string.format( "|ca5cd84[|caca665M|ca91922P|ce4d09d]|r |cFFFFFF%s|r",
							  GetString( MP_MSG_FIRSTSTART ) )
						  local output = string.format( pattern, "|r" .. urlLink .. "|cFFFFFF" )
						  CHAT_ROUTER:AddSystemMessage( output )
						  MP.settings.initialized = true
					  end, 500 )

		-- dont show changelogs if first time
		MP.settings.changelogs[ "v1.8.0" ] = true
		return
	end

	if not MP.settings.changelogs[ "v1.8.0" ] then
		EVENT_MANAGER:RegisterForUpdate( MPG.name .. "UpdateWarning", 1000, function()
			if not MP.settings.changelogs[ "v1.8.0" ]
				and not ZO_Dialogs_IsShowingDialog() then
				MPG.ShowConfirmationDialog( MPG.name .. "UpdateWarning", GetString( MP_CHANGELOG ), function()
					EVENT_MANAGER:UnregisterForUpdate( MPG.name .. "UpdateWarning" )
					MP.settings.changelogs[ "v1.8.0" ] = true
					RequestOpenUnsafeURL( "https://MPw.esoui.com/downloads/info3170-Mephisto.html" )
				end )
			end
		end )
	end
end

function MPG.SetSceneManagement()
	local onSceneChange = function( scene, oldState, newState )
		local sceneName = scene:GetName()

		if sceneName == "gameMenuInGame" then return end

		if newState == SCENE_SHOWING then
			local savedScene = MP.settings.window[ sceneName ]
			if savedScene then
				if not savedScene.hidden then
					MephistoWindow:ClearAnchors()
					MephistoWindow:SetAnchor( TOPLEFT, GUI_ROOT, TOPLEFT, savedScene.left, savedScene.top )
					MephistoWindow:SetHidden( false )
				end
			end
		end

		-- looks better when window hides faster
		if newState == SCENE_HIDING then
			local savedScene = MP.settings.window[ sceneName ]
			if savedScene then
				MephistoWindow:SetHidden( true )
			end
			if sceneName == "hud" or sceneName == "hudui" then
				if not MP.settings.window[ sceneName ] then
					MP.settings.window[ sceneName ] = {
						top = MephistoWindow:GetTop(),
						left = MephistoWindow:GetLeft(),
						hidden = true,
					}
				end
				MP.settings.window[ sceneName ].hidden = true
			end
		end
	end
	SCENE_MANAGER:RegisterCallback( "SceneStateChanged", onSceneChange )

	-- quickslot tab will internally act like a independent scene
	KEYBOARD_QUICKSLOT_FRAGMENT:RegisterCallback( "StateChange", function( oldState, newState )
		local quickslot = {
			GetName = function( GetName )
				return "inventoryQuickslot"
			end
		}
		local inventoryScene = SCENE_MANAGER:GetScene( "inventory" )
		if newState == SCENE_SHOWING then
			onSceneChange( inventoryScene, SCENE_SHOWN, SCENE_HIDING )
			onSceneChange( quickslot, SCENE_HIDDEN, SCENE_SHOWING )
		elseif newState == SCENE_HIDING then
			if inventoryScene:IsShowing() then
				onSceneChange( quickslot, SCENE_SHOWN, SCENE_HIDING )
				onSceneChange( inventoryScene, SCENE_HIDDEN, SCENE_SHOWING )
			else
				onSceneChange( quickslot, SCENE_SHOWN, SCENE_HIDING )
			end
		end
	end )

	CALLBACK_MANAGER:RegisterCallback( "LAM-PanelControlsCreated", function( panel )
		if panel:GetName() ~= "MephistoMenu" then return end
		local icon = WINDOW_MANAGER:CreateControl( "MephistoMenuIcon", panel, CT_TEXTURE )
		icon:SetTexture( "/Mephisto/assets/icon64.dds" )
		icon:SetDimensions( 64, 64 )
		icon:SetAnchor( TOPRIGHT, panel, TOPRIGHT, -45, -25 )
	end )
	CALLBACK_MANAGER:RegisterCallback( "LAM-PanelOpened", function( panel )
		if panel:GetName() ~= "MephistoMenu" then return end
		MephistoWindow:ClearAnchors()
		MephistoWindow:SetAnchor( CENTER, GUI_ROOT, RIGHT, -(MephistoWindow:GetWidth() / 2 + 50), 0 )
		MephistoWindow:SetHidden( false )
		PlaySound( SOUNDS.DEFAULT_WINDOW_OPEN )
	end )
	CALLBACK_MANAGER:RegisterCallback( "LAM-PanelClosed", function( panel )
		if panel:GetName() ~= "MephistoMenu" then return end
		MephistoWindow:SetHidden( true )
	end )

	SLASH_COMMANDS[ "/mephisto" ] = function()
		local scene = SCENE_MANAGER:GetCurrentScene()
		local sceneName = scene:GetName()
		if sceneName == "gameMenuInGame" then
			MephistoWindow:SetHidden( not MephistoWindow:IsHidden() )
			return
		end
		if sceneName == "inventory" and KEYBOARD_QUICKSLOT_FRAGMENT:IsShowing() then
			sceneName = "inventoryQuickslot"
		end
		local savedScene = MP.settings.window[ sceneName ]
		if savedScene then
			if savedScene.hidden then
				-- open
				MephistoWindow:ClearAnchors()
				MephistoWindow:SetAnchor( TOPLEFT, GUI_ROOT, TOPLEFT, savedScene.left, savedScene.top )
				MephistoWindow:SetHidden( false )
				PlaySound( SOUNDS.DEFAULT_WINDOW_OPEN )
				SCENE_MANAGER:SetInUIMode( true, false )
				MP.settings.window[ sceneName ].hidden = false
			else
				-- close
				MephistoWindow:SetHidden( true )
				PlaySound( SOUNDS.DEFAULT_WINDOW_CLOSE )
				MP.settings.window[ sceneName ].hidden = true
			end
		else
			-- open but new
			MephistoWindow:ClearAnchors()
			MephistoWindow:SetAnchor( CENTER, GUI_ROOT, CENTER, 0, 0 )
			MephistoWindow:SetHidden( false )
			PlaySound( SOUNDS.DEFAULT_WINDOW_OPEN )
			SCENE_MANAGER:SetInUIMode( true, false )
			MP.settings.window[ sceneName ] = {
				top = MephistoWindow:GetTop(),
				left = MephistoWindow:GetLeft(),
				hidden = false,
			}
		end
	end
end

function MPG.SetDialogManagement()
	MPG.dialogList = {}
	SCENE_MANAGER:RegisterCallback( "SceneStateChanged", function( scene, oldState, newState )
		if newState ~= SCENE_HIDING then return end
		for _, dialog in ipairs( MPG.dialogList ) do
			dialog:SetHidden( true )
		end
	end )
end

function MPG.ResetUI()
	MP.settings.panel = {
		top = PANEL_DEFAULT_TOP,
		left = PANEL_DEFAULT_LEFT,
		locked = true,
		hidden = false,
		setup = true,
	}
	MephistoPanel:ClearAnchors()
	MephistoPanel:SetAnchor( TOPLEFT, GUI_ROOT, TOPLEFT, PANEL_DEFAULT_LEFT, PANEL_DEFAULT_TOP )
	MP.settings.window = {
		wizard = {
			width = WINDOW_WIDTH,
			height = WINDOW_HEIGHT,
			scale = 1,
			locked = false,
		},
	}
	MephistoWindow:SetWidth( WINDOW_WIDTH )
	MephistoWindow:SetHeight( WINDOW_HEIGHT )
	MPG.OnWindowResize( "stop" )
end

function MPG.SetupPanel()
	MephistoPanel.fragment = ZO_SimpleSceneFragment:New( MephistoPanel )
	MephistoPanel.fragment:SetConditional( function()
		return not MP.settings.panel.hidden and not IsUnitDead( "player" )
	end )
	HUD_SCENE:AddFragment( MephistoPanel.fragment )
	HUD_UI_SCENE:AddFragment( MephistoPanel.fragment )
	zo_callLater( function() MephistoPanel.fragment:Refresh() end, 1 )

	MephistoPanelIcon:SetHandler( "OnMouseEnter", function( self )
		self:SetDesaturation( 0.4 )
	end )
	MephistoPanelIcon:SetHandler( "OnMouseExit", function( self )
		self:SetDesaturation( 0 )
	end )
	MephistoPanelIcon:SetHandler( "OnMouseDown", function( self )
		self:SetDesaturation( 0.8 )
	end )
	MephistoPanelIcon:SetHandler( "OnMouseUp", function( self, mouseButton )
		if MouseIsOver( self, 0, 0, 0, 0 )
			and mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			SLASH_COMMANDS[ "/mephisto" ]()
			self:SetDesaturation( 0.4 )
		else
			self:SetDesaturation( 0 )
		end
	end )

	MephistoPanelTopLabel:SetText( MP.displayName:upper() )
	MephistoPanelMiddleLabel:SetText( "Version " .. MP.version )
	--MephistoPanelBottomLabel:SetText( "" )

	if MP.settings.panel and MP.settings.panel.mini then
		MephistoPanel:SetDimensions( PANEL_WIDTH_MINI, PANEL_HEIGHT_MINI )
		MephistoPanelBG:SetHidden( true )
		MephistoPanelIcon:SetHidden( true )
		MephistoPanelTopLabel:SetHidden( true )
		MephistoPanelMiddleLabel:SetAnchor( TOPLEFT, MephistoPanel, TOPLEFT )
		MephistoPanelBottomLabel:SetAnchor( BOTTOMLEFT, MephistoPanel, BOTTOMLEFT )
	end

	if MP.settings.panel and MP.settings.panel.top and MP.settings.panel.setup then
		MephistoPanel:SetAnchor( TOPLEFT, GUI_ROOT, TOPLEFT, MP.settings.panel.left, MP.settings.panel.top )
		MephistoPanel:SetMovable( not MP.settings.panel.locked )
	else
		MP.settings.panel = {
			top = PANEL_DEFAULT_TOP,
			left = PANEL_DEFAULT_LEFT,
			locked = true,
			hidden = false,
			setup = true,
		}
		MephistoPanel:SetAnchor( TOPLEFT, GUI_ROOT, TOPLEFT, PANEL_DEFAULT_LEFT, PANEL_DEFAULT_TOP )
	end
end

function MPG.OnPanelMove()
	MP.settings.panel.top = MephistoPanel:GetTop()
	MP.settings.panel.left = MephistoPanel:GetLeft()
end

function MPG.SetPanelText( zoneTag, pageName, setupName )
	local middleText = string.format( "%s / %s", zoneTag, pageName )
	MephistoPanelMiddleLabel:SetText( middleText )

	local logColor = IsUnitInCombat( "player" ) and MP.LOGTYPES.INFO or MP.LOGTYPES.NORMAL
	local middleText = string.format( "|c%s%s|r", logColor, setupName )
	MephistoPanelBottomLabel:SetText( middleText )

	if IsUnitInCombat( "player" ) then
		MP.queue.Push( function()
			middleText = string.format( "|c%s%s|r", MP.LOGTYPES.NORMAL, setupName )
			MephistoPanelBottomLabel:SetText( middleText )
		end )
	end
end

function MPG.SetupWindow()
	MephistoWindow.fragment = ZO_SimpleSceneFragment:New( MephistoWindow )
	MephistoWindow:SetDimensions( MP.settings.window.wizard.width, MP.settings.window.wizard.height )
	MephistoWindow:SetResizeHandleSize( 8 )

	MephistoWindowTitleLabel:SetText( MP.displayName:upper() )
end

function MPG.OnWindowMove()
	local scene = SCENE_MANAGER:GetCurrentScene()
	local sceneName = scene:GetName()
	if sceneName == "inventory" and KEYBOARD_QUICKSLOT_FRAGMENT:IsShowing() then
		sceneName = "inventoryQuickslot"
	end
	MP.settings.window[ sceneName ] = {
		top = MephistoWindow:GetTop(),
		left = MephistoWindow:GetLeft(),
		hidden = false,
	}
end

function MPG.OnWindowResize( action )
	local function OnResize()
		local count = #MPG.setupTable
		local height = MephistoWindow:GetHeight() - TITLE_HEIGHT - TOP_MENU_HEIGHT - DIVIDER_HEIGHT - PAGE_MENU_HEIGHT -
		DIVIDER_HEIGHT - BOTTOM_MENU_HEIGHT
		local width = MephistoWindow:GetWidth() - 6

		local rows = zo_floor( width / SETUP_BOX_WIDTH )
		local itemsPerCol = zo_ceil( count / rows )

		local scrollBox = MephistoWindowSetupList:GetNamedChild( "ScrollChild" )

		for i = 1, #MPG.setupTable do
			local key = MPG.setupTable[ i ]
			local setupControl = MPG.setupPool:AcquireObject( key )
			local x = zo_floor( (i - 1) / itemsPerCol ) * SETUP_BOX_WIDTH + 3
			local y = (((i - 1) % itemsPerCol) * SETUP_BOX_HEIGHT)
			setupControl:ClearAnchors()
			setupControl:SetAnchor( TOPLEFT, scrollBox, TOPLEFT, x, y )
		end

		MPG.substituteExplain:ClearAnchors()
		MPG.substituteExplain:SetAnchor( TOP, scrollBox, TOP, 0, itemsPerCol * SETUP_BOX_HEIGHT + 10 )

		MPG.addSetupButton:ClearAnchors()
		MPG.addSetupButton:SetAnchor( TOP, scrollBox, TOP, 0, itemsPerCol * SETUP_BOX_HEIGHT - 10 )
		MPG.addSetupButtonSpacer:ClearAnchors()
		MPG.addSetupButtonSpacer:SetAnchor( TOP, scrollBox, TOP, 0, itemsPerCol * SETUP_BOX_HEIGHT + 10 )

		MephistoWindowTitle:SetWidth( width )
		MephistoWindowPageMenu:SetWidth( width )
		MephistoWindowSetupList:SetDimensions( width, height )
		scrollBox:SetDimensionConstraints( width, height, AUTO_SIZE, AUTO_SIZE )
		MephistoWindowBottomMenu:SetWidth( width )

		MephistoWindowTopDivider:SetWidth( width )
		MephistoWindowBottomDivider:SetWidth( width )
	end

	local function OnResizeEnd()
		local rows = zo_floor( ((MephistoWindow:GetWidth() + 2) / SETUP_BOX_WIDTH) + 0.5 )
		local width = rows * SETUP_BOX_WIDTH + 10
		MephistoWindow:SetWidth( width )
		OnResize()

		MP.settings.window.wizard.width = MephistoWindow:GetWidth()
		MP.settings.window.wizard.height = MephistoWindow:GetHeight()
	end

	local identifier = MP.name .. "WindowResize"
	if action == "start" then
		EVENT_MANAGER:RegisterForUpdate( identifier, 50, OnResize )
	elseif action == "stop" then
		EVENT_MANAGER:UnregisterForUpdate( identifier )
		OnResizeEnd()
	end
end

function MPG.SetupTopMenu()
	MephistoWindowTitleHide:SetHandler( "OnClicked", function( self )
		SLASH_COMMANDS[ "/mephisto" ]()
	end )

	local selection = GridComboBox:New( "$(parent)Selection", MephistoWindow )
	selection:SetAnchor( LEFT, MephistoWindowTopMenu, LEFT, 16 )
	selection:SetDimensions( 208, 16 )
	selection:SetItemsPerRow( 4 )
	selection:SetItemSize( 49 )
	selection:SetItemSpacing( 4 )
	selection:ClearItems()
	for _, zone in ipairs( MPG.GetSortedZoneList() ) do
		selection:AddItem( {
			label = zone.name,
			tag = zone.tag,
			icon = zone.icon,
			callback = function()
				MPG.OnZoneSelect( zone )
			end,
		} )
	end
	MPG.zoneSelection = selection

	MephistoWindowTopMenuTeleportTrial:SetHandler( "OnClicked", function( self )
		local nodeId = MP.selection.zone.node
		if nodeId < 0 then return end

		if IsUnitGrouped( "player" ) then
			for i = 1, GetGroupSize() do
				local groupTag = GetGroupUnitTagByIndex( i )
				if IsUnitOnline( groupTag ) then
					local zoneId = GetUnitWorldPosition( groupTag )
					if zoneId == MP.selection.zone.id and CanJumpToGroupMember( groupTag ) then
						local displayName = GetUnitDisplayName( groupTag )
						MP.Log( GetString( MP_MSG_TELEPORT_PLAYER ), MP.LOGTYPES.NORMAL, nil, displayName )
						JumpToGroupMember( displayName )
						return
					end
				end
			end
		end

		if not HasCompletedFastTravelNodePOI( nodeId ) then
			MP.Log( GetString( MP_MSG_TELEPORT_WAYSHRINE_ERROR ), MP.LOGTYPES.ERROR )
			return
		end

		MP.Log( GetString( MP_MSG_TELEPORT_WAYSHRINE ), MP.LOGTYPES.NORMAL )
		FastTravelToNode( nodeId )
	end )
	MPG.SetTooltip( MephistoWindowTopMenuTeleportTrial, TOP, GetString( MP_BUTTON_TELEPORT ) )

	MephistoWindowTopMenuTeleportHouse:SetHandler( "OnClicked", function( self )
		MP.Log( GetString( MP_MSG_TELEPORT_HOUSE ), MP.LOGTYPES.NORMAL )
		RequestJumpToHouse( GetHousingPrimaryHouse() )
	end )
	MPG.SetTooltip( MephistoWindowTopMenuTeleportHouse, TOP, GetString( MP_BUTTON_TELEPORT ) )

	MephistoWindowTopMenuAddPage:SetHandler( "OnClicked", function( self )
		MPG.CreatePage( MP.selection.zone )
	end )
	MPG.SetTooltip( MephistoWindowTopMenuAddPage, TOP, GetString( MP_BUTTON_ADDPAGE ) )

	local autoEquipTextures = {
		[ true ] = "/esoui/art/crafting/smithing_tabicon_armorset_down.dds",
		[ false ] = "/esoui/art/crafting/smithing_tabicon_armorset_up.dds"
	}
	local autoEquipMessages = {
		[ true ] = GetString( MP_MSG_TOGGLEAUTOEQUIP_ON ),
		[ false ] = GetString( MP_MSG_TOGGLEAUTOEQUIP_OFF )
	}
	MephistoWindowTopMenuAutoEquip:SetHandler( "OnClicked", function( self )
		MP.settings.autoEquipSetups = not MP.settings.autoEquipSetups
		MP.storage.autoEquipSetups = MP.settings.autoEquipSetups
		self:SetNormalTexture( autoEquipTextures[ MP.settings.autoEquipSetups ] )
		MP.Log( GetString( MP_MSG_TOGGLEAUTOEQUIP ), MP.LOGTYPES.NORMAL, nil, autoEquipMessages[ MP.settings.autoEquipSetups ] )
	end )
	MephistoWindowTopMenuAutoEquip:SetNormalTexture( autoEquipTextures[ MP.settings.autoEquipSetups ] )
	MPG.SetTooltip( MephistoWindowTopMenuAutoEquip, TOP, GetString( MP_BUTTON_TOGGLEAUTOEQUIP ) )
end

function MPG.OnZoneSelect( zone )
	PlaySound( SOUNDS.TABLET_PAGE_TURN )

	if not MP.pages[ zone.tag ] then
		MPG.CreatePage( zone, true )
	end

	MP.selection.zone = zone
	MP.selection.pageId = MP.pages[ zone.tag ][ 0 ].selected

	MPG.BuildPage( MP.selection.zone, MP.selection.pageId )

	MPG.zoneSelection:SetLabel( zone.name )

	local isSubstitute = zone.tag == "SUB"
	MPG.substituteExplain:SetHidden( not isSubstitute )
	MPG.addSetupButton:SetHidden( isSubstitute )

	if zone.tag == "GEN"
		or zone.tag == "SUB"
		or zone.tag == "PVP" then
		MephistoWindowTopMenuTeleportTrial:SetHidden( true )
		MephistoWindowTopMenuTeleportHouse:SetHidden( false )
	else
		MephistoWindowTopMenuTeleportTrial:SetHidden( false )
		MephistoWindowTopMenuTeleportHouse:SetHidden( true )
	end

	MephistoWindowTopMenuTeleportTrial:SetEnabled( not IsInAvAZone() )
	MephistoWindowTopMenuTeleportTrial:SetDesaturation( IsInAvAZone() and 1 or 0 )
	MephistoWindowTopMenuTeleportHouse:SetEnabled( not IsInAvAZone() )
end

function MPG.SetupPageMenu()
	MephistoWindowPageMenuWarning:SetHandler( "OnMouseUp", function( self, mouseButton )
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			local missingGear = MP.CheckGear( MP.selection.zone, MP.selection.pageId )
			if #missingGear > 0 then
				local missingGearText = string.format( GetString( MP_MISSING_GEAR_TT ), MPG.GearLinkTableToString( missingGear ) )
				MPG.SetTooltip( self, TOP, missingGearText )
			else
				self:SetHidden( true )
				MPG.SetTooltip( self, TOP, nil )
			end
		end
	end )
	MephistoWindowPageMenuDropdown:SetHandler( "OnClicked", function( self, mouseButton )
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if IsMenuVisible() then
				ClearMenu()
			else
				MPG.ShowPageContextMenu( MephistoWindowPageMenuLabel )
			end
		end
	end )
	MPG.SetTooltip( MephistoWindowPageMenuBank, TOP, GetString( MP_BUTTON_BANKING ) )
	MephistoWindowPageMenuBank:SetHandler( "OnClicked", function( self )
		if IsShiftKeyDown() then
			MP.banking.DepositPage( MP.selection.zone, MP.selection.pageId )
		else
			MP.banking.WithdrawPage( MP.selection.zone, MP.selection.pageId )
		end
	end )
	MephistoWindowPageMenuLeft:SetHandler( "OnClicked", function( self )
		MPG.PageLeft()
	end )
	MephistoWindowPageMenuRight:SetHandler( "OnClicked", function( self )
		MPG.PageRight()
	end )
end

function MPG.SetupSetupList()
	-- always show scrollbar (set hidden to false only would show some errors)
	local oldScrollFunction = ZO_Scroll_UpdateScrollBar
	ZO_Scroll_UpdateScrollBar = function( self, forceUpdateBarValue )
		local _, verticalExtents = self.scroll:GetScrollExtents()
		if verticalExtents > 0 or self:GetName() ~= "MephistoWindowSetupList" then
			oldScrollFunction( self, forceUpdateBarValue )
		else
			ZO_Scroll_ResetToTop( self )
			self.scroll:SetFadeGradient( 1, 0, 0, 0 )
			local scrollBarHeight = self.scrollbar:GetHeight() / self.scroll:GetScale()
			self.scrollbar:SetThumbTextureHeight( scrollBarHeight )
			self.scrollbar:SetHidden( false )
		end
	end

	local scrollBox = MephistoWindowSetupList:GetNamedChild( "ScrollChild" )
	MPG.addSetupButton = MPG.CreateButton( {
		parent = scrollBox,
		size = 42,
		anchor = { TOPLEFT, scrollBox, TOPLEFT },
		texture = "/esoui/art/buttons/plus",
		tooltip = GetString( MP_BUTTON_ADDSETUP ),
		clicked = function() MPG.CreateSetup() end,
	} )
	MPG.addSetupButtonSpacer = MPG.CreateLabel( {
		parent = scrollBox,
		font = "ZoFontGame",
		text = " ",
		anchor = { TOPLEFT, scrollBox, TOPLEFT },
	} )
	MPG.substituteExplain = MPG.CreateLabel( {
		parent = scrollBox,
		font = "ZoFontGame",
		text = GetString( MP_SUBSTITUTE_EXPLAIN ),
		constraint = 310,
		anchor = { TOPLEFT, scrollBox, TOPLEFT },
		hidden = true,
	} )
end

function MPG.SetupBottomMenu()
	MPG.SetTooltip( MephistoWindowBottomMenuSettings, TOP, GetString( MP_BUTTON_SETTINGS ) )
	MephistoWindowBottomMenuSettings:SetHandler( "OnClicked", function( self )
		LibAddonMenu2:OpenToPanel( MP.menu.panel )
	end )
	MPG.SetTooltip( MephistoWindowBottomMenuQueue, TOP, GetString( MP_BUTTON_CLEARQUEUE ) )
	MephistoWindowBottomMenuQueue:SetHandler( "OnClicked", function( self )
		local entries = MP.queue.Size()
		MP.queue.Reset()
		MP.Log( GetString( MP_MSG_CLEARQUEUE ), MP.LOGTYPES.NORMAL, nil, entries )
	end )
	MPG.SetTooltip( MephistoWindowBottomMenuUndress, TOP, GetString( MP_BUTTON_UNDRESS ) )
	MephistoWindowBottomMenuUndress:SetHandler( "OnClicked", function( self )
		MP.Undress()
	end )
	MPG.SetTooltip( MephistoWindowBottomMenuPrebuff, TOP, GetString( MP_BUTTON_PREBUFF ) )
	MephistoWindowBottomMenuPrebuff:SetHandler( "OnClicked", function( self )
		MP.prebuff.dialog:SetHidden( false )
	end )
	MPG.SetTooltip( MephistoWindowBottomMenuHelp, TOP, GetString( MP_BUTTON_HELP ) )
	MephistoWindowBottomMenuHelp:SetHandler( "OnClicked", function( self )
		RequestOpenUnsafeURL( "https://discord.gg/rqNgRkvZsq" )
	end )
end

function MPG.CreateButton( data )
	local button = WINDOW_MANAGER:CreateControl( data.name, data.parent, CT_BUTTON )
	button:SetDimensions( data.size, data.size )
	button:SetAnchor( unpack( data.anchor ) )
	button:SetHidden( data.hidden or false )
	button:SetClickSound( SOUNDS.DEFAULT_CLICK )
	button:SetNormalTexture( data.texture .. "_up.dds" )
	button:SetMouseOverTexture( data.texture .. "_over.dds" )
	button:SetPressedTexture( data.texture .. "_down.dds" )
	button:SetDisabledTexture( data.texture .. "_disabled.dds" )
	if data.clicked then button:SetHandler( "OnClicked", data.clicked ) end
	if data.tooltip then MPG.SetTooltip( button, TOP, data.tooltip ) end
	return button
end

function MPG.CreateLabel( data )
	local label = WINDOW_MANAGER:CreateControl( data.name, data.parent, CT_LABEL )
	label:SetFont( data.font )
	label:SetText( data.text or "" )
	label:SetAnchor( unpack( data.anchor ) )
	label:SetDimensionConstraints( AUTO_SIZE, AUTO_SIZE, data.constraint or AUTO_SIZE,
		data.oneline and label:GetFontHeight() or AUTO_SIZE )
	label:SetHidden( data.hidden or false )
	label:SetMouseEnabled( data.mouse or false )
	if data.tooltip then MPG.SetTooltip( label, TOP, data.tooltip ) end
	return label
end

function MPG.CreateSetupPool()
	local scrollBox = MephistoWindowSetupList:GetNamedChild( "ScrollChild" )

	local function FactoryItem()
		local setup = WINDOW_MANAGER:CreateControl( nil, scrollBox, CT_CONTROL )
		setup:SetDimensions( SETUP_BOX_WIDTH, SETUP_BOX_HEIGHT )

		setup.name = MPG.CreateLabel( {
			parent = setup,
			font = "ZoFontWinH4",
			anchor = { TOPLEFT, setup, TOPLEFT },
			constraint = 252,
			oneline = true,
			mouse = true,
		} )
		setup.dropdown = MPG.CreateButton( {
			parent = setup,
			size = 16,
			anchor = { LEFT, setup.name, RIGHT, 2, 0 },
			texture = "/esoui/art/buttons/scrollbox_downarrow",
		} )
		setup.modify = MPG.CreateButton( {
			parent = setup,
			size = 32,
			anchor = { TOPRIGHT, setup, TOPRIGHT, -8, -8 },
			texture = "/esoui/art/buttons/edit",
			tooltip = GetString( MP_BUTTON_MODIFY ),
		} )
		setup.save = MPG.CreateButton( {
			parent = setup,
			size = 32,
			anchor = { RIGHT, setup.modify, LEFT, 8 },
			texture = "/esoui/art/buttons/edit_save",
			tooltip = GetString( MP_BUTTON_SAVE ),
		} )
		setup.preview = MPG.CreateButton( {
			parent = setup,
			size = 32,
			anchor = { RIGHT, setup.save, LEFT, 6, 2 },
			texture = "/esoui/art/guild/tabicon_roster",
			tooltip = GetString( MP_BUTTON_PREVIEW ),
		} )
		setup.banking = MPG.CreateButton( {
			parent = setup,
			hidden = true,
			size = 34,
			anchor = { RIGHT, setup.preview, LEFT, 6 },
			texture = "/esoui/art/icons/guildranks/guild_indexicon_misc09",
			tooltip = GetString( MP_BUTTON_BANKING ),
		} )

		local skills = { [ 0 ] = {}, [ 1 ] = {} }
		for hotbarCategory = 0, 1 do
			for slotIndex = 3, 8 do
				local x = (slotIndex - 3) * 42
				local y = hotbarCategory * 42 + 25

				local skill = WINDOW_MANAGER:CreateControl( nil, setup, CT_TEXTURE )
				skill:SetDrawLayer( DL_CONTROLS )
				skill:SetDimensions( 40, 40 )
				skill:SetAnchor( TOPLEFT, setup, TOPLEFT, x, y )
				skill:SetDrawLevel( 2 )
				skill:SetMouseEnabled( true )
				skill:SetTexture( "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds" )
				skills[ hotbarCategory ][ slotIndex ] = skill

				local frame = WINDOW_MANAGER:CreateControl( nil, skill, CT_TEXTURE )
				frame:SetDrawLayer( DL_CONTROLS )
				frame:SetDimensions( 40, 40 )
				frame:SetAnchor( CENTER, skill, CENTER, 0, 0 )
				frame:SetDrawLevel( 3 )
				frame:SetTexture( "/esoui/art/actionbar/abilityframe64_up.dds" )
			end
		end
		setup.skills = skills

		local x = 6 * 42
		local y = 25

		setup.food = MPG.CreateButton( {
			parent = setup,
			size = 42,
			anchor = { TOPLEFT, setup, TOPLEFT, x + 1, y - 1 },
			texture = "/esoui/art/crafting/provisioner_indexicon_meat",
		} )
		local foodFrame = WINDOW_MANAGER:CreateControl( nil, setup.food, CT_TEXTURE )
		foodFrame:SetDimensions( 40, 40 )
		foodFrame:SetAnchor( CENTER, setup.food, CENTER, 0, 0 )
		foodFrame:SetTexture( "/esoui/art/actionbar/abilityframe64_up.dds" )

		setup.gear = MPG.CreateButton( {
			parent = setup,
			size = 42,
			anchor = { TOPLEFT, setup, TOPLEFT, x + 42, y - 1 },
			texture = "/esoui/art/guild/tabicon_heraldry",
		} )
		local gearFrame = WINDOW_MANAGER:CreateControl( nil, setup.gear, CT_TEXTURE )
		gearFrame:SetDimensions( 40, 40 )
		gearFrame:SetAnchor( CENTER, setup.gear, CENTER, 0, 0 )
		gearFrame:SetTexture( "/esoui/art/actionbar/abilityframe64_up.dds" )

		setup.skill = MPG.CreateButton( {
			parent = setup,
			size = 44,
			anchor = { TOPLEFT, setup, TOPLEFT, x, y + 42 - 2 },
			texture = "/esoui/art/mainmenu/menubar_skills",
		} )
		local skillFrame = WINDOW_MANAGER:CreateControl( nil, setup.skill, CT_TEXTURE )
		skillFrame:SetDimensions( 40, 40 )
		skillFrame:SetAnchor( CENTER, setup.skill, CENTER, 0, 0 )
		skillFrame:SetTexture( "/esoui/art/actionbar/abilityframe64_up.dds" )

		setup.cp = MPG.CreateButton( {
			parent = setup,
			size = 40,
			anchor = { TOPLEFT, setup, TOPLEFT, x + 42 + 1, y + 42 },
			texture = "/esoui/art/mainmenu/menubar_champion",
		} )
		local cpFrame = WINDOW_MANAGER:CreateControl( nil, setup.cp, CT_TEXTURE )
		cpFrame:SetDimensions( 40, 40 )
		cpFrame:SetAnchor( CENTER, setup.cp, CENTER, 0, 0 )
		cpFrame:SetTexture( "/esoui/art/actionbar/abilityframe64_up.dds" )

		return setup
	end
	local function ResetItem( setup )
		setup:SetHidden( true )
	end

	MPG.setupPool = ZO_ObjectPool:New( FactoryItem, ResetItem )
end

function MPG.AquireSetupControl( setup )
	local setupControl, key = MPG.setupPool:AcquireObject()
	table.insert( MPG.setupTable, key )
	local index = #MPG.setupTable

	setupControl:SetHidden( false )
	setupControl.i = index

	setupControl.name:SetHandler( "OnMouseEnter", function( self )
		setup = Setup:FromStorage( MP.selection.zone.tag, MP.selection.pageId, index )
		ZO_Tooltips_ShowTextTooltip( self, TOP, GetString( MP_BUTTON_LABEL ) )
		if not setup:IsDisabled() then
			self:SetColor( 1, 0.5, 0.5, 1 )
		end
	end )
	setupControl.name:SetHandler( "OnMouseExit", function( self )
		setup = Setup:FromStorage( MP.selection.zone.tag, MP.selection.pageId, index )
		ZO_Tooltips_HideTextTooltip()
		local color = 1
		if setup:IsDisabled() then
			color = 0.3
		end
		self:SetColor( color, color, color, 1 )
	end )
	setupControl.name:SetHandler( "OnMouseDown", function( self )
		self:SetColor( 0.8, 0.4, 0.4, 1 )
	end )
	setupControl.name:SetHandler( "OnMouseUp", function( self, mouseButton )
		if not MouseIsOver( self, 0, 0, 0, 0 ) then return end
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			MP.LoadSetupCurrent( index, false )
		end
	end )

	setupControl.dropdown:SetHandler( "OnClicked", function( self, mouseButton )
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if IsMenuVisible() then
				ClearMenu()
			else
				MPG.ShowSetupContextMenu( setupControl.name, index )
			end
		end
	end )
	setupControl.modify:SetEnabled( not (MP.selection.zone.tag == "SUB") )
	setupControl.modify:SetHandler( "OnClicked", function( self )
		MPG.ShowModifyDialog( setupControl, index )
	end )
	setupControl.save:SetHandler( "OnClicked", function( self )
		MP.SaveSetup( MP.selection.zone, MP.selection.pageId, index )
		setup = Setup:FromStorage( MP.selection.zone.tag, MP.selection.pageId, index )
		MPG.RefreshSetup( setupControl, setup )
	end )
	setupControl.preview:SetHandler( "OnClicked", function( self )
		MP.preview.ShowPreviewFromSetup( setup, MP.selection.zone.name )
	end )
	setupControl.banking:SetHandler( "OnClicked", function( self )
		if IsShiftKeyDown() then
			MP.banking.DepositSetup( MP.selection.zone, MP.selection.pageId, index )
		else
			MP.banking.WithdrawSetup( MP.selection.zone, MP.selection.pageId, index )
		end
	end )

	for hotbarCategory = 0, 1 do
		for slotIndex = 3, 8 do
			local skillControl = setupControl.skills[ hotbarCategory ][ slotIndex ]
			local function OnSkillDragStart( self )
				if IsUnitInCombat( "player" ) then return end -- would fail at protected call anyway
				if GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then return end

				setup = Setup:FromStorage( MP.selection.zone.tag, MP.selection.pageId, index )

				local abilityId = setup:GetSkills()[ hotbarCategory ][ slotIndex ]
				if not abilityId then return end

				local baseAbilityId = MP.GetBaseAbilityId( abilityId )
				if not baseAbilityId then return end

				local skillType, skillLine, skillIndex = GetSpecificSkillAbilityKeysByAbilityId( baseAbilityId )
				if CallSecureProtected( "PickupAbilityBySkillLine", skillType, skillLine, skillIndex ) then
					setup:SetSkill( hotbarCategory, slotIndex, 0 )
					setup:ToStorage( MP.selection.zone.tag, MP.selection.pageId, index )
					self:GetHandler( "OnMouseExit" )()
					MPG.RefreshSetup( setupControl, setup )
				end
			end
			local function OnSkillDragReceive( self )
				if GetCursorContentType() ~= MOUSE_CONTENT_ACTION then return end
				local abilityId = GetCursorAbilityId()

				local progression = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId( abilityId )
				if not progression then return end

				if progression:IsUltimate() and slotIndex < 8 or
					not progression:IsUltimate() and slotIndex > 7 then
					-- Prevent ult on normal slot and vice versa
					return
				end

				if progression:IsChainingAbility() then
					abilityId = GetEffectiveAbilityIdForAbilityOnHotbar( abilityId, hotbarCategory )
				end

				ClearCursor()

				setup = Setup:FromStorage( MP.selection.zone.tag, MP.selection.pageId, index )

				local previousAbilityId = setup:GetSkills()[ hotbarCategory ][ slotIndex ]
				setup:SetSkill( hotbarCategory, slotIndex, abilityId )
				setup:ToStorage( MP.selection.zone.tag, MP.selection.pageId, index )

				self:GetHandler( "OnMouseExit" )()
				MPG.RefreshSetup( setupControl, setup )

				if previousAbilityId and previousAbilityId > 0 then
					local baseAbilityId = MP.GetBaseAbilityId( previousAbilityId )
					local skillType, skillLine, skillIndex = GetSpecificSkillAbilityKeysByAbilityId( baseAbilityId )
					CallSecureProtected( "PickupAbilityBySkillLine", skillType, skillLine, skillIndex )
				end
			end
			skillControl:SetHandler( "OnReceiveDrag", OnSkillDragReceive )
			skillControl:SetHandler( "OnMouseUp", function( self )
				if MouseIsOver( self, 0, 0, 0, 0 ) then
					OnSkillDragReceive( self )
				end
			end )
			skillControl:SetHandler( "OnDragStart", OnSkillDragStart )
		end
	end

	local function OnFoodDrag( self )
		local cursorContentType = GetCursorContentType()
		if cursorContentType ~= MOUSE_CONTENT_INVENTORY_ITEM then return false end

		local bagId = GetCursorBagId()
		local slotIndex = GetCursorSlotIndex()

		local foodLink = GetItemLink( bagId, slotIndex, LINK_STYLE_DEFAULT )
		local foodId = GetItemLinkItemId( foodLink )

		if not MP.BUFFFOOD[ foodId ] then
			MP.Log( GetString( MP_MSG_NOTFOOD ), MP.LOGTYPES.ERROR )
			return false
		end

		setup = Setup:FromStorage( MP.selection.zone.tag, MP.selection.pageId, index )

		MP.SaveFood( setup, slotIndex )
		setup:ToStorage( MP.selection.zone.tag, MP.selection.pageId, index )

		self:GetHandler( "OnMouseExit" )()
		MPG.RefreshSetup( setupControl, setup )
		self:GetHandler( "OnMouseEnter" )()

		ClearCursor()
		return true
	end
	setupControl.food:SetHandler( "OnReceiveDrag", OnFoodDrag )
	setupControl.food:SetHandler( "OnClicked", function( self, mouseButton )
		setup = Setup:FromStorage( MP.selection.zone.tag, MP.selection.pageId, index )
		if OnFoodDrag( self ) then return end
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if IsShiftKeyDown() then
				MP.SaveFood( setup )
				setup:ToStorage( MP.selection.zone.tag, MP.selection.pageId, index )
				self:GetHandler( "OnMouseExit" )()
				MPG.RefreshSetup( setupControl, setup )
				self:GetHandler( "OnMouseEnter" )()
			elseif IsControlKeyDown() or IsCommandKeyDown() then
				setup:SetFood( {} )
				setup:ToStorage( MP.selection.zone.tag, MP.selection.pageId, index )
				ZO_Tooltips_HideTextTooltip()
				self:GetHandler( "OnMouseExit" )()
				MPG.RefreshSetup( setupControl, setup )
				self:GetHandler( "OnMouseEnter" )()
			else
				MP.EatFood( setup )
			end
		end
	end )

	local function OnGearDrag( self )
		local cursorContentType = GetCursorContentType()
		if cursorContentType ~= MOUSE_CONTENT_INVENTORY_ITEM and
			cursorContentType ~= MOUSE_CONTENT_EQUIPPED_ITEM then
			return false
		end

		local bagId = GetCursorBagId()
		local slotIndex = GetCursorSlotIndex()

		local itemLink = GetItemLink( bagId, slotIndex, LINK_STYLE_DEFAULT )
		local equipType = GetItemLinkEquipType( itemLink )

		if not MP.GEARTYPE[ equipType ] then return false end
		local gearSlot = MP.GEARTYPE[ equipType ]

		if IsShiftKeyDown() then
			if gearSlot == EQUIP_SLOT_MAIN_HAND then
				gearSlot = EQUIP_SLOT_BACKUP_MAIN
			elseif gearSlot == EQUIP_SLOT_RING1 then
				gearSlot = EQUIP_SLOT_RING2
			elseif gearSlot == EQUIP_SLOT_POISON then
				gearSlot = EQUIP_SLOT_BACKUP_POISON
			end
		end

		setup = Setup:FromStorage( MP.selection.zone.tag, MP.selection.pageId, index )

		local gearTable = setup:GetGear()

		if gearTable.mythic then
			local isMythic = MP.IsMythic( bagId, slotIndex )
			if isMythic and gearSlot ~= gearTable.mythic then
				gearTable[ gearTable.mythic ] = {
					[ "link" ] = "",
					[ "id" ] = "0",
				}
				gearTable.mythic = gearSlot
			elseif not isMythic and gearSlot == gearTable.mythic then
				gearTable[ gearTable.mythic ] = {
					[ "link" ] = "",
					[ "id" ] = "0",
				}
				gearTable.mythic = nil
			end
		end

		if gearSlot == EQUIP_SLOT_MAIN_HAND then
			gearTable[ EQUIP_SLOT_OFF_HAND ] = {
				[ "link" ] = "",
				[ "id" ] = "0",
			}
		elseif gearSlot == EQUIP_SLOT_BACKUP_MAIN then
			gearTable[ EQUIP_SLOT_BACKUP_OFF ] = {
				[ "link" ] = "",
				[ "id" ] = "0",
			}
		end

		gearTable[ gearSlot ] = {
			id = Id64ToString( GetItemUniqueId( bagId, slotIndex ) ),
			link = GetItemLink( bagId, slotIndex, LINK_STYLE_DEFAULT ),
		}

		if GetItemLinkItemType( gearTable[ gearSlot ].link ) == ITEMTYPE_TABARD then
			gearTable[ gearSlot ].creator = GetItemCreatorName( bagId, slotIndex )
		end

		setup:SetGear( gearTable )
		setup:ToStorage( MP.selection.zone.tag, MP.selection.pageId, index )

		self:GetHandler( "OnMouseExit" )()
		MPG.RefreshSetup( setupControl, setup )
		self:GetHandler( "OnMouseEnter" )()

		ClearCursor()
		return true
	end
	setupControl.gear:SetHandler( "OnReceiveDrag", OnGearDrag )
	setupControl.gear:SetHandler( "OnClicked", function( self, mouseButton )
		setup = Setup:FromStorage( MP.selection.zone.tag, MP.selection.pageId, index )
		if OnGearDrag( self ) then return end
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if IsShiftKeyDown() then
				MP.SaveGear( setup )
				setup:ToStorage( MP.selection.zone.tag, MP.selection.pageId, index )
				local tooltip = setup:GetGearText()
				if tooltip and tooltip ~= "" then
					ZO_Tooltips_ShowTextTooltip( self, RIGHT, tostring( tooltip ) )
				end
				MPG.RefreshSetup( setupControl, setup )
			elseif IsControlKeyDown() or IsCommandKeyDown() then
				setup:SetGear( { mythic = nil } )
				setup:ToStorage( MP.selection.zone.tag, MP.selection.pageId, index )
				ZO_Tooltips_HideTextTooltip()
				MPG.RefreshSetup( setupControl, setup )
			else
				MP.LoadGear( setup )
			end
		end
	end )

	setupControl.skill:SetHandler( "OnClicked", function( self, mouseButton )
		setup = Setup:FromStorage( MP.selection.zone.tag, MP.selection.pageId, index )
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if IsShiftKeyDown() then
				MP.SaveSkills( setup )
				setup:ToStorage( MP.selection.zone.tag, MP.selection.pageId, index )
				local tooltip = setup:GetSkillsText()
				if tooltip and tooltip ~= "" then
					ZO_Tooltips_ShowTextTooltip( self, RIGHT, tostring( tooltip ) )
				end
				MPG.RefreshSetup( setupControl, setup )
			elseif IsControlKeyDown() or IsCommandKeyDown() then
				setup:SetSkills( { [ 0 ] = {}, [ 1 ] = {} } )
				setup:ToStorage( MP.selection.zone.tag, MP.selection.pageId, index )
				ZO_Tooltips_HideTextTooltip()
				MPG.RefreshSetup( setupControl, setup )
			else
				MP.LoadSkills( setup )
			end
		end
	end )

	setupControl.cp:SetHandler( "OnClicked", function( self, mouseButton )
		setup = Setup:FromStorage( MP.selection.zone.tag, MP.selection.pageId, index )
		if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
			if IsShiftKeyDown() then
				MP.SaveCP( setup )
				setup:ToStorage( MP.selection.zone.tag, MP.selection.pageId, index )
				local tooltip = setup:GetCPText()
				if tooltip and tooltip ~= "" then
					ZO_Tooltips_ShowTextTooltip( self, RIGHT, tostring( tooltip ) )
				end
				MPG.RefreshSetup( setupControl, setup )
			elseif IsControlKeyDown() or IsCommandKeyDown() then
				setup:SetCP( {} )
				setup:ToStorage( MP.selection.zone.tag, MP.selection.pageId, index )
				ZO_Tooltips_HideTextTooltip()
				MPG.RefreshSetup( setupControl, setup )
			else
				MP.LoadCP( setup )
			end
		end
	end )

	return setupControl
end

function MPG.GetSetupControl( index )
	local key = MPG.setupTable[ index ]
	local setupControl = MPG.setupPool:AcquireObject( key )
	return setupControl
end

function MPG.CreateSetup()
	local index = #MPG.setupTable + 1
	local tag = MP.selection.zone.tag
	local pageId = MP.selection.pageId

	local setup = Setup:FromStorage( tag, pageId, index )
	setup:ToStorage( tag, pageId, index )

	local control = MPG.AquireSetupControl( setup )
	MPG.RefreshSetup( control, setup )
	MPG.OnWindowResize( "stop" )
end

function MPG.RenameSetup()

end

function MPG.ClearPage()
	for i = 1, #MPG.setupTable do
		local key = MPG.setupTable[ i ]
		MPG.setupPool:ReleaseObject( key )
	end
	MPG.setupTable = {}
end

function MPG.BuildPage( zone, pageId, scroll )
	MPG.ClearPage()
	for entry in MP.PageIterator( zone, pageId ) do
		local setup = Setup:FromStorage( zone.tag, pageId, entry.index )
		local control = MPG.AquireSetupControl( setup )
	end
	if zone.tag == "SUB" and #MPG.setupTable == 0 then
		MPG.CreateDefaultSetups( zone, pageId )
		MPG.BuildPage( zone, pageId )
		return
	end
	MPG.RefreshPage()
	MPG.OnWindowResize( "stop" )
	MP.conditions.LoadConditions()
	if scroll then
		ZO_Scroll_ResetToTop( MephistoWindowSetupList )
	end
end

function MPG.CreatePage( zone, skipBuilding )
	if not MP.pages[ zone.tag ] then
		MP.pages[ zone.tag ] = {}
		MP.pages[ zone.tag ][ 0 ] = {}
		MP.pages[ zone.tag ][ 0 ].selected = 1
	end

	local nextPageId = #MP.pages[ zone.tag ] + 1
	MP.pages[ zone.tag ][ nextPageId ] = {
		name = string.format( GetString( MP_PAGE ), tostring( nextPageId ) ),
	}

	MP.pages[ zone.tag ][ 0 ].selected = nextPageId
	MP.selection.pageId = nextPageId

	MPG.CreateDefaultSetups( zone, nextPageId )

	if not skipBuilding then
		MPG.BuildPage( zone, nextPageId, true )
	end

	return nextPageId
end

function MPG.CreateDefaultSetups( zone, pageId )
	for i, boss in ipairs( zone.bosses ) do
		local setup = Setup:FromStorage( zone.tag, pageId, i )
		setup:SetName( boss.displayName or boss.name )
		setup:SetCondition( {
			boss = boss.name,
			trash = (boss.name == GetString( MP_TRASH )) and MP.CONDITIONS.EVERYWHERE or nil
		} )
		setup:ToStorage( zone.tag, pageId, i )
	end
end

function MPG.DuplicatePage()
	local zone = MP.selection.zone
	local pageId = MP.selection.pageId

	local cloneId = MPG.CreatePage( zone, true )

	local pageName = MP.pages[ zone.tag ][ pageId ].name
	MP.pages[ zone.tag ][ cloneId ].name = string.format( GetString( MP_DUPLICATE_NAME ), pageName )

	MP.setups[ zone.tag ][ cloneId ] = {}
	ZO_DeepTableCopy( MP.setups[ zone.tag ][ pageId ], MP.setups[ zone.tag ][ cloneId ] )

	MPG.BuildPage( MP.selection.zone, MP.selection.pageId, true )
end

function MPG.DeletePage()
	local zone = MP.selection.zone
	local pageId = MP.selection.pageId

	-- this is a workaround for empty pages
	-- dont ask me why
	if #MPG.setupTable == 0 then
		MPG.CreateSetup()
	end

	local nextPageId = pageId - 1
	if nextPageId < 1 then nextPageId = pageId end

	MP.pages[ zone.tag ][ 0 ].selected = nextPageId
	MP.selection.pageId = nextPageId

	table.remove( MP.setups[ zone.tag ], pageId )
	table.remove( MP.pages[ zone.tag ], pageId )

	MP.markers.BuildGearList()
	MPG.BuildPage( zone, nextPageId, true )

	return nextPageId
end

function MPG.RenamePage()
	local zone = MP.selection.zone
	local pageId = MP.selection.pageId

	local initialText = MP.pages[ zone.tag ][ pageId ].name
	MPG.ShowEditDialog( "PageNameEdit", GetString( MP_RENAME_PAGE ), initialText,
						function( input )
							if not input then
								return
							end
							if input == "" then
								MP.pages[ zone.tag ][ pageId ].name = GetString( MP_UNNAMED )
							else
								MP.pages[ zone.tag ][ pageId ].name = input
							end
							local pageName = MP.pages[ zone.tag ][ pageId ].name
							MephistoWindowPageMenuLabel:SetText( pageName:upper() )
						end )
end

function MPG.PageLeft()
	if MP.selection.pageId - 1 < 1 then
		return
	end
	local prevPage = MP.selection.pageId - 1
	MP.selection.pageId = prevPage
	MP.pages[ MP.selection.zone.tag ][ 0 ].selected = prevPage
	MPG.BuildPage( MP.selection.zone, MP.selection.pageId, true )
end

function MPG.PageRight()
	if MP.selection.pageId + 1 > #MP.pages[ MP.selection.zone.tag ] then
		return
	end
	local nextPage = MP.selection.pageId + 1
	MP.selection.pageId = nextPage
	MP.pages[ MP.selection.zone.tag ][ 0 ].selected = nextPage
	MPG.BuildPage( MP.selection.zone, MP.selection.pageId, true )
end

function MPG.RefreshPage()
	local zone = MP.selection.zone
	local pageId = MP.selection.pageId

	for i = 1, #MPG.setupTable do
		local setupControl = MPG.GetSetupControl( i )
		local setup = Setup:FromStorage( zone.tag, pageId, i )
		MPG.RefreshSetup( setupControl, setup )
	end

	local pageName = MP.pages[ zone.tag ][ pageId ].name
	MephistoWindowPageMenuLabel:SetText( pageName:upper() )

	if pageId == 1 then MephistoWindowPageMenuLeft:SetEnabled( false ) else MephistoWindowPageMenuLeft
			:SetEnabled( true ) end
	if pageId == #MP.pages[ zone.tag ] then MephistoWindowPageMenuRight:SetEnabled( false ) else
		MephistoWindowPageMenuRight:SetEnabled( true ) end

	local missingGear = MP.CheckGear( zone, pageId )
	if #missingGear > 0 then
		MephistoWindowPageMenuWarning:SetHidden( false )
		local missingGearText = string.format( GetString( MP_MISSING_GEAR_TT ), MPG.GearLinkTableToString( missingGear ) )
		MPG.SetTooltip( MephistoWindowPageMenuWarning, TOP, missingGearText )
	else
		MephistoWindowPageMenuWarning:SetHidden( true )
		MPG.SetTooltip( MephistoWindowPageMenuWarning, TOP, nil )
	end

	MPG.OnWindowResize( "stop" )
end

function MPG.RefreshSetup( control, setup )
	local color = (setup:IsDisabled() and 0.3 or 1)
	local name = string.format( "|cC5C29E%s|r %s", control.i, setup:GetName():upper() )
	control.name:SetText( name )
	control.name:SetColor( color, color, color, 1 )

	for hotbarCategory = 0, 1 do
		for slotIndex = 3, 8 do
			local abilityId = setup:GetSkills()[ hotbarCategory ][ slotIndex ]
			local abilityIcon = "/esoui/art/itemtooltip/eso_itemtooltip_emptyslot.dds"
			if abilityId and abilityId > 0 then
				abilityIcon = GetAbilityIcon( abilityId )
			end
			local skillControl = control.skills[ hotbarCategory ][ slotIndex ]
			skillControl:SetTexture( abilityIcon )
			skillControl:SetColor( color, color, color, 1 )
			if abilityId and abilityId > 0 then
				skillControl:SetHandler( "OnMouseEnter", function()
					InitializeTooltip( AbilityTooltip, skillControl, TOPLEFT, 8, -8, TOPRIGHT )
					AbilityTooltip:SetAbilityId( abilityId )
				end )
				skillControl:SetHandler( "OnMouseExit", function()
					ClearTooltip( AbilityTooltip )
				end )
			else
				skillControl:SetHandler( "OnMouseEnter", function() end )
				skillControl:SetHandler( "OnMouseExit", function() end )
			end
		end
	end

	local food = setup:GetFood()
	if food.link then
		control.food:SetHandler( "OnMouseEnter", function()
			InitializeTooltip( ItemTooltip, control.food, LEFT, 4, 0, RIGHT )
			ItemTooltip:SetLink( food.link )
		end )
		control.food:SetHandler( "OnMouseExit", function()
			ClearTooltip( ItemTooltip )
		end )
	else
		MPG.SetTooltip( control.food, RIGHT, GetString( MP_BUTTON_BUFFFOOD ) )
	end

	local gearText = setup:GetGearText()
	MPG.SetTooltip( control.gear, RIGHT, gearText )

	local skillsText = setup:GetSkillsText()
	MPG.SetTooltip( control.skill, RIGHT, skillsText )

	local cpText = setup:GetCPText()
	MPG.SetTooltip( control.cp, RIGHT, cpText )

	if IsBankOpen() and not MP.DISABLEDBAGS[ GetBankingBag() ] then
		control.banking:SetHidden( false )
		MephistoWindowPageMenuBank:SetHidden( false )
	else
		control.banking:SetHidden( true )
		MephistoWindowPageMenuBank:SetHidden( true )
	end
end

function MPG.ShowPageContextMenu( control )
	local zone = MP.selection.zone
	local pageId = MP.selection.pageId

	ClearMenu()

	AddMenuItem( GetString( MP_BUTTON_RENAME ), function() MPG.RenamePage() end, MENU_ADD_OPTION_LABEL )

	if MP.selection.zone.tag ~= "SUB" then
		AddMenuItem( GetString( MP_BUTTON_REARRANGE ), function() MPG.ShowArrangeDialog( zone, pageId ) end,
			MENU_ADD_OPTION_LABEL )
	end

	AddMenuItem( GetString( MP_DUPLICATE ), function() MPG.DuplicatePage() end, MENU_ADD_OPTION_LABEL )

	local deleteColor = #MP.pages[ zone.tag ] > 1 and ZO_ColorDef:New( 1, 0, 0, 1 ) or ZO_ColorDef:New( 0.35, 0.35, 0.35, 1 )
	AddMenuItem( GetString( MP_DELETE ):upper(), function()
					 if #MP.pages[ zone.tag ] > 1 then
						 local pageName = MP.pages[ zone.tag ][ pageId ].name
						 MPG.ShowConfirmationDialog( "DeletePageConfirmation",
													 string.format( GetString( MP_DELETEPAGE_WARNING ), pageName ),
													 function()
														 MPG.DeletePage()
													 end )
					 end
				 end, MENU_ADD_OPTION_LABEL, "ZoFontGameBold", deleteColor, deleteColor )

	-- lets fix some ZOS bugs(?)
	if control:GetWidth() >= ZO_Menu.width then
		ZO_Menu.width = control:GetWidth() - 10
	end

	ShowMenu( control, 2, MENU_TYPE_COMBO_BOX )
	SetMenuPad( 100 )
	AnchorMenu( control, 0 )
end

function MPG.ShowSetupContextMenu( control, index )
	local zone = MP.selection.zone
	local pageId = MP.selection.pageId

	ClearMenu()

	-- LINK TO CHAT
	AddMenuItem( GetString( SI_ITEM_ACTION_LINK_TO_CHAT ), function()
					 MP.preview.PrintPreviewString( zone, pageId, index )
				 end, MENU_ADD_OPTION_LABEL )

	-- CUSTOM CODE
	AddMenuItem( GetString( MP_CUSTOMCODE ), function() MP.code.ShowCodeDialog( zone, pageId, index ) end,
		MENU_ADD_OPTION_LABEL )

	-- IMPORT / EXPORT
	AddMenuItem( GetString( MP_IMPORT ), function() MP.transfer.ShowImportDialog( zone, pageId, index ) end,
		MENU_ADD_OPTION_LABEL )
	AddMenuItem( GetString( MP_EXPORT ), function() MP.transfer.ShowExportDialog( zone, pageId, index ) end,
		MENU_ADD_OPTION_LABEL )

	-- ENABLE / DISABLE
	--if setup:IsDisabled() then
	--	AddMenuItem(GetString(MP_ENABLE), function() MPG.SetSetupDisabled(zone, pageId, index, false) end, MENU_ADD_OPTION_LABEL)
	--else
	--	AddMenuItem(GetString(MP_DISABLE), function() MPG.SetSetupDisabled(zone, pageId, index, true) end, MENU_ADD_OPTION_LABEL)
	--end

	-- DELETE
	AddMenuItem( GetString( MP_DELETE ):upper(), function()
					 PlaySound( SOUNDS.DEFER_NOTIFICATION )
					 if MP.selection.zone.tag == "SUB" then
						 MP.ClearSetup( zone, pageId, index )
					 else
						 MP.DeleteSetup( zone, pageId, index )
					 end
				 end, MENU_ADD_OPTION_LABEL, "ZoFontGameBold", ZO_ColorDef:New( 1, 0, 0, 1 ), ZO_ColorDef:New( 1, 0, 0, 1 ) )

	-- lets fix some ZOS bugs(?)
	if control:GetWidth() >= ZO_Menu.width then
		ZO_Menu.width = control:GetWidth() - 10
	end

	ShowMenu( control, 2, MENU_TYPE_COMBO_BOX )
	SetMenuPad( 100 )
	AnchorMenu( control, 0 )
end

function MPG.SetupModifyDialog()
	MephistoModify:SetDimensions( GuiRoot:GetWidth() + 8, GuiRoot:GetHeight() + 8 )
	MephistoModifyDialogTitle:SetText( GetString( MP_BUTTON_MODIFY ):upper() )
	MephistoModifyDialogHide:SetHandler( "OnClicked", function( self )
		MephistoModify:SetHidden( true )
	end )
	MephistoModifyDialogSave:SetText( GetString( MP_BUTTON_SAVE ) )
	MephistoModifyDialogNameLabel:SetText( GetString( MP_CONDITION_NAME ):upper() )
	MephistoModifyDialogConditionBossLabel:SetText( GetString( MP_CONDITION_BOSS ):upper() )
	MephistoModifyDialogConditionTrashLabel:SetText( GetString( MP_CONDITION_AFTER ):upper() )
	table.insert( MPG.dialogList, MephistoModify )
end

function MPG.ShowModifyDialog( setupControl, index )
	local zone = MP.selection.zone
	local pageId = MP.selection.pageId

	local setup = Setup:FromStorage( zone.tag, pageId, index )

	local condition = setup:GetCondition()

	local newBoss, newTrash

	MephistoModifyDialogNameEdit:SetText( setup:GetName() )

	if zone.tag == "GEN" then
		MephistoModifyDialogCondition:SetHeight( 50 )
		MephistoModifyDialogConditionBossCombo:SetHidden( true )
		MephistoModifyDialogConditionBossEdit:SetHidden( false )
		MephistoModifyDialogConditionTrashLabel:SetHidden( true )
		MephistoModifyDialogConditionTrashCombo:SetHidden( true )

		MephistoModifyDialogConditionBossEdit:SetText( condition.boss or "" )
		MephistoModifyDialogConditionBossEdit:SetHandler( "OnTextChanged", function( self )
			newBoss = self:GetText()
		end )
	else
		local function OnBossCombo( selection )
			newBoss = selection
			if newBoss == GetString( MP_TRASH ) then
				MephistoModifyDialogCondition:SetHeight( 100 )
				MephistoModifyDialogConditionTrashLabel:SetHidden( false )
				MephistoModifyDialogConditionTrashCombo:SetHidden( false )
			else
				MephistoModifyDialogCondition:SetHeight( 50 )
				MephistoModifyDialogConditionTrashLabel:SetHidden( true )
				MephistoModifyDialogConditionTrashCombo:SetHidden( true )
			end
		end
		local function OnTrashCombo( selection )
			newTrash = selection
		end

		MephistoModifyDialogConditionBossCombo:SetHidden( false )
		MephistoModifyDialogConditionBossEdit:SetHidden( true )

		local bossCombo = MephistoModifyDialogConditionBossCombo.m_comboBox
		bossCombo:SetSortsItems( false )
		bossCombo:ClearItems()
		bossCombo:AddItem( ZO_ComboBox:CreateItemEntry( GetString( MP_CONDITION_NONE ),
			function() OnBossCombo( MP.CONDITIONS.NONE ) end ) )
		local bossId = zone.lookupBosses[ condition.boss ]
		local selectedBoss = bossId and (zone.bosses[ bossId ].displayName or zone.bosses[ bossId ].name) or
		GetString( MP_CONDITION_NONE )
		bossCombo:SetSelectedItemText( selectedBoss )
		OnBossCombo( condition.boss or MP.CONDITIONS.NONE )

		local trashCombo = MephistoModifyDialogConditionTrashCombo.m_comboBox
		trashCombo:SetSortsItems( false )
		trashCombo:ClearItems()
		trashCombo:AddItem( ZO_ComboBox:CreateItemEntry( GetString( MP_CONDITION_EVERYWHERE ),
			function() OnTrashCombo( MP.CONDITIONS.EVERYWHERE ) end ) )
		local trashId = zone.lookupBosses[ condition.trash ]
		local selectedTrash = trashId and (zone.bosses[ trashId ].displayName or zone.bosses[ trashId ].name) or
		GetString( MP_CONDITION_EVERYWHERE )
		trashCombo:SetSelectedItemText( selectedTrash )
		OnTrashCombo( condition.trash or MP.CONDITIONS.EVERYWHERE )

		for i, boss in ipairs( zone.bosses ) do
			bossCombo:AddItem( ZO_ComboBox:CreateItemEntry( boss.displayName or boss.name,
				function() OnBossCombo( boss.name ) end ) )
			if boss.name ~= GetString( MP_TRASH ) then
				trashCombo:AddItem( ZO_ComboBox:CreateItemEntry( boss.displayName or boss.name,
					function() OnTrashCombo( boss.name ) end ) )
			end
		end
	end

	MephistoModifyDialogSave:SetHandler( "OnClicked", function( self )
		local newName = MephistoModifyDialogNameEdit:GetText()
		if #newName == 0 then newName = GetString( MP_UNNAMED ) end
		local name = string.format( "|cC5C29E%s|r %s", index, newName:upper() )
		setupControl.name:SetText( name )
		setup:SetName( newName )
		setup:SetCondition( {
			boss = newBoss,
			trash = newTrash,
		} )
		setup:ToStorage( zone.tag, pageId, index )
		MP.conditions.LoadConditions()
		MephistoModify:SetHidden( true )
	end )

	MephistoModify:SetHidden( false )
	SCENE_MANAGER:SetInUIMode( true, false )
end

function MPG.SetupArrangeDialog()
	MephistoArrange:SetDimensions( GuiRoot:GetWidth() + 8, GuiRoot:GetHeight() + 8 )
	MephistoArrangeDialogTitle:SetText( GetString( MP_BUTTON_REARRANGE ):upper() )
	MephistoArrangeDialogSave:SetText( GetString( MP_BUTTON_SAVE ) )
	MephistoArrangeDialogSave:SetHandler( "OnClicked", function( self )
		local dataList = ZO_ScrollList_GetDataList( MephistoArrangeDialogList )
		MPG.RearrangeSetups( dataList, MP.selection.zone, MP.selection.pageId )
	end )
	MephistoArrangeDialogHide:SetHandler( "OnClicked", function( self )
		MephistoArrange:SetHidden( true )
	end )
	MephistoArrangeDialogUp:SetHandler( "OnClicked", function( self )
		local index = ZO_ScrollList_GetSelectedDataIndex( MephistoArrangeDialogList )

		if not index or index == 1 then return end

		local dataList = ZO_ScrollList_GetDataList( MephistoArrangeDialogList )

		local current = dataList[ index ]
		local above = dataList[ index - 1 ]

		dataList[ index ] = above
		dataList[ index - 1 ] = current

		ZO_ScrollList_Commit( MephistoArrangeDialogList )
		MephistoArrangeDialogList:GetNamedChild( "ScrollBar" ):SetHidden( false )
	end )
	MephistoArrangeDialogDown:SetHandler( "OnClicked", function( self )
		local index = ZO_ScrollList_GetSelectedDataIndex( MephistoArrangeDialogList )
		local dataList = ZO_ScrollList_GetDataList( MephistoArrangeDialogList )

		if not index or index == #dataList then return end

		local current = dataList[ index ]
		local below = dataList[ index + 1 ]

		dataList[ index ] = below
		dataList[ index + 1 ] = current

		ZO_ScrollList_Commit( MephistoArrangeDialogList )
		MephistoArrangeDialogList:GetNamedChild( "ScrollBar" ):SetHidden( false )
	end )

	local function OnRowSetup( rowControl, data, scrollList )
		rowControl:SetFont( "ZoFontGame" )
		rowControl:SetMaxLineCount( 1 )
		rowControl:SetText( data.name )
		rowControl:SetHandler( "OnMouseUp", function() ZO_ScrollList_MouseClick( scrollList, rowControl ) end )
	end

	local function OnSelection( previouslySelectedData, selectedData, reselectingDuringRebuild )
		if not selectedData then return end
	end

	ZO_ScrollList_AddDataType( MephistoArrangeDialogList, 1, "ZO_SelectableLabel", 30, OnRowSetup, nil, nil, nil )
	ZO_ScrollList_EnableSelection( MephistoArrangeDialogList, "ZO_ThinListHighlight", OnSelection )
	ZO_ScrollList_EnableHighlight( MephistoArrangeDialogList, "ZO_ThinListHighlight" )
	ZO_ScrollList_SetDeselectOnReselect( MephistoArrangeDialogList, false )
	table.insert( MPG.dialogList, MephistoArrange )
end

function MPG.ShowArrangeDialog( zone, pageId )
	local function GetSetupList()
		local setupList = {}
		for entry in MP.PageIterator( zone, pageId ) do
			table.insert( setupList, {
				name = entry.setup.name,
				index = entry.index
			} )
		end
		return setupList
	end

	local function UpdateScrollList( data )
		local dataCopy = ZO_DeepTableCopy( data )
		local dataList = ZO_ScrollList_GetDataList( MephistoArrangeDialogList )

		ZO_ClearNumericallyIndexedTable( dataList )

		for _, value in ipairs( dataCopy ) do
			local entry = ZO_ScrollList_CreateDataEntry( 1, value )
			table.insert( dataList, entry )
		end

		ZO_ScrollList_Commit( MephistoArrangeDialogList )
	end

	local data = GetSetupList()
	UpdateScrollList( data )

	MephistoArrange:SetHidden( false )

	MephistoArrangeDialogList:GetNamedChild( "ScrollBar" ):SetHidden( false )
end

function MPG.RearrangeSetups( sortTable, zone, pageId )
	local pageCopy = ZO_DeepTableCopy( MP.setups[ zone.tag ][ pageId ] )
	for newIndex, entry in ipairs( sortTable ) do
		local oldIndex = entry.data.index
		if newIndex ~= oldIndex then
			MP.setups[ zone.tag ][ pageId ][ newIndex ] = pageCopy[ oldIndex ]
		end
	end
	MPG.BuildPage( zone, pageId, true )
	MephistoArrange:SetHidden( true )
end
