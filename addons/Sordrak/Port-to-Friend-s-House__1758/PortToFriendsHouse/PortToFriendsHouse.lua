-- PortToFriendsHouse
-- By @s0rdrak (PC / EU)

PortToFriend = {}
PortToFriend.addonName = "PortToFriendsHouse"
PortToFriend.version = 1 -- saved vars
PortToFriend.versionString = "2.5.46"
PortToFriend.updateInterval = 20 -- in ms, not used in this addon [default construct]
PortToFriend.author = "@s0rdrak (PC / EU)"
PortToFriend.credits = "@Neltje, @Graham82, @Nita65"
PortToFriend.slashCmd = "/ptf"
PortToFriend.callbackName = "PtfOnPlayerDeactivated"


PortToFriend.libData = PortToFriend.libData or {}
local PortToFriendData = PortToFriend.libData

PortToFriend.config = {}
PortToFriend.config.size = {}
PortToFriend.config.size.width = 800
PortToFriend.config.size.height = 600
PortToFriend.config.size.headerHeight = 25
PortToFriend.config.size.headerHeightOffset = 8
PortToFriend.config.size.gap = -4
PortToFriend.config.isMovable = true
PortToFriend.config.isMouseEnabled = true
PortToFriend.config.isClampedToScreen = true
PortToFriend.config.fonts = {}
PortToFriend.config.fonts.header = "$(BOLD_FONT)|$(KB_20)soft-shadow-thick"
PortToFriend.config.search = {}
PortToFriend.config.search.max = 5
PortToFriend.config.search.height = 25
PortToFriend.config.search.width = 250
PortToFriend.config.search.minChars = 2
PortToFriend.config.color = {}
PortToFriend.config.color.default = {R = 0.85, G = 0.83, B = 0.7}
PortToFriend.config.color.backdrop = {R = 0.0, G = 0.0, B = 0.0, A = 0.7}
PortToFriend.config.color.backdropEdge = {R = 1.0, G = 1.0, B = 1.0, A = 0.7}
PortToFriend.config.color.searchBackdrop = {R = 0.0, G = 0.0, B = 0.0, A = 0.9}
PortToFriend.config.color.searchBackdropEdge = {R = 1.0, G = 1.0, B = 1.0, A = 0.8}
PortToFriend.config.color.backDropLine = {R = 0.4, G = 0.6, B = 1.0, A = 0.3}
PortToFriend.config.color.visitCardFontColor = { R = 0.77254903316498, G = 0.76078432798386, B = 0.61960786581039, A = 1}
PortToFriend.config.color.selectedVisitCardColor = {R = 0.8, G = 0.6, B = 0.4, A = 0.3}
PortToFriend.config.color.selectedVisitCardColorOnMouseOver = {R = 0.4, G = 0.6, B = 1.0, A = 0.7}
PortToFriend.config.color.tabSelected = {}
PortToFriend.config.color.tabSelected.r = 0.5
PortToFriend.config.color.tabSelected.g = 0.5
PortToFriend.config.color.tabSelected.b = 0.5
PortToFriend.config.color.tabSelected.a = 0.7
PortToFriend.config.color.tabNotSelected = {}
PortToFriend.config.color.tabNotSelected.r = 0.3
PortToFriend.config.color.tabNotSelected.g = 0.3
PortToFriend.config.color.tabNotSelected.b = 0.3
PortToFriend.config.color.tabNotSelected.a = 0.7
PortToFriend.config.color.tabMouseOver = {}
PortToFriend.config.color.tabMouseOver.r = 0.2
PortToFriend.config.color.tabMouseOver.g = 0.6
PortToFriend.config.color.tabMouseOver.b = 0.8
PortToFriend.config.color.tabMouseOver.a = 0.7
PortToFriend.config.color.edgeColor = {}
PortToFriend.config.color.edgeColor.r = 0.8
PortToFriend.config.color.edgeColor.g = 0.8
PortToFriend.config.color.edgeColor.b = 0.8
PortToFriend.config.color.edgeColor.a = 0.7
PortToFriend.config.color.tabFontColor = {}
PortToFriend.config.color.tabFontColor.r = 0.85
PortToFriend.config.color.tabFontColor.g = 0.83
PortToFriend.config.color.tabFontColor.b = 0.7
PortToFriend.config.vc = {}
PortToFriend.config.vc.size = {}
PortToFriend.config.vc.size.width = 558
PortToFriend.config.vc.size.height = 400
PortToFriend.config.vc.size.headerHeight = 25
PortToFriend.config.vc.size.headerHeightOffset = 8
PortToFriend.config.vc.size.gap = -4
--PortToFriend.config.vc.isMovable = true
--PortToFriend.config.vc.isMouseEnabled = true
--PortToFriend.config.vc.isClampedToScreen = true
PortToFriend.config.tabHeight = 40
PortToFriend.config.tabWidth = 158
PortToFriend.config.tabOffset = 4
PortToFriend.config.tabFont = "$(BOLD_FONT)|$(KB_20)soft-shadow-thick"
PortToFriend.config.houseDebug = false


PortToFriend.constants = {}
PortToFriend.constants.sendBasicString = "%s%s %d (%s)"
PortToFriend.constants.sendKeyWord = "PTF_VisitCard: "
PortToFriend.constants.sendBasicComment = "Port to Friend's House Visit Card"
PortToFriend.constants.controls = {}
PortToFriend.constants.controls.TLW_NAME = "PortToFriend_TLW"
PortToFriend.constants.controls.TLW_VC_NAME = "PortToFriend_VC_TLW"
PortToFriend.constants.controls.HEADER_NAME = "PortToFriend_Header"
PortToFriend.constants.controls.HEADER_CONTROL = "PortToFriend_Header_Control"
PortToFriend.constants.controls.HEADER_BACKDROP = "PortToFriend_Header_Backdrop"
PortToFriend.constants.controls.HEADER_BUTTON = "PortToFriend_Header_Button"
PortToFriend.constants.controls.BODY_CONTROL = "PortToFriend_Body_Control"
PortToFriend.constants.controls.BODY_BACKDROP = "PortToFriend_Body_Backdrop"
PortToFriend.constants.controls.BODY_EDITBOX = "PortToFriend_Body_Editbox"
PortToFriend.constants.controls.BODY_DROPDOWN = "PortToFriend_Body_Dropdown"
PortToFriend.constants.controls.SEARCH_BODY_BACKDROP = "PortToFriend_Search_Body_Dropdown"
PortToFriend.constants.controls.SCROLL_CONTROL = "PortToFriend_Scroll_Control"
PortToFriend.constants.controls.COMBOBOX_FAVORITES = "PortToFriend_Combobox_Favorites_%d_%d"
PortToFriend.constants.controls.COMBOBOX_LIBRARY = "PortToFriend_Combobox_Library"
PortToFriend.constants.controls.COMBOBOX_SORT_LIBRARY = "PortToFriend_Combobox_Sort_Library"
PortToFriend.constants.controls.COMBOBOX_MYHOUSES = "PortToFriend_Combobox_MyHouses"
PortToFriend.constants.controls.COMBOBOX_MYHOUSES_FAVORITES = "PortToFriend_Combobox_Favorites_%d_%d_%d_%d"
PortToFriend.constants.controls.VC_HEADER_NAME = "PortToFriend_VC_Header"
PortToFriend.constants.controls.VC_HEADER_CONTROL = "PortToFriend_VC_Header_Control"
PortToFriend.constants.controls.VC_HEADER_BACKDROP = "PortToFriend_VC_Header_Backdrop"
PortToFriend.constants.controls.VC_HEADER_BUTTON = "PortToFriend_VC_Header_Button"
PortToFriend.constants.controls.VC_BODY_CONTROL = "PortToFriend_VC_Body_Control"
PortToFriend.constants.controls.VC_BODY_BACKDROP = "PortToFriend_VC_Body_Backdrop"
PortToFriend.constants.controls.VC_SCROLL_CONTROL = "PortToFriend_VC_Scroll_Control"
PortToFriend.constants.TAB_HOUSE = 1
PortToFriend.constants.TAB_VC = 2
PortToFriend.constants.TAB_MYHOUSES = 3
PortToFriend.constants.TAB_LIBRARY = 4
PortToFriend.constants.TAB_DONATE = 5
PortToFriend.constants.SORT_ID_HOUSE = 1
PortToFriend.constants.SORT_ID_LOCATION = 2
PortToFriend.constants.FILTER_ID_NONE = 1
PortToFriend.constants.FILTER_ID_HIGHLIGHT = 2
PortToFriend.constants.FILTER_ID_LABYRINTH = 3
PortToFriend.constants.FILTER_ID_JUMPNRUN = 4
PortToFriend.constants.FILTER_ID_CRAFTING = 5
PortToFriend.constants.FILTER_ID_GUILD = 6
PortToFriend.constants.FILTER_ID_ROLEPLAY = 7
PortToFriend.constants.FILTER_ID_RAID = 8
PortToFriend.constants.FILTER_ID_HIDE_SEEK = 9
PortToFriend.constants.FILTER_ID_ERP = 10
PortToFriend.constants.LIBRARY_SORT_ID_NONE = 1
PortToFriend.constants.LIBRARY_SORT_ID_NAME = 2
PortToFriend.constants.LIBRARY_SORT_ID_HOUSE = 3
PortToFriend.constants.PORT_MODE_NONE = 1
PortToFriend.constants.PORT_MODE_ON_CLICK = 2
PortToFriend.constants.PORT_MODE_ON_DEACTIVATE = 3
PortToFriend.constants.PORT_TYPE_INSIDE = 1
PortToFriend.constants.PORT_TYPE_OUTSIDE = 2

PortToFriend.controls = {}
PortToFriend.controls.favorites = {}
PortToFriend.controls.searchResults = {}
PortToFriend.controls.searchResultsBackdrop = {}
PortToFriend.controls.libraryEntries = {}
PortToFriend.controls.purchasedHouses = {}

PortToFriend.addonState = {}
PortToFriend.addonState.houseId = 0
PortToFriend.addonState.isScrollable = false
PortToFriend.addonState.isVCScrollable = false
PortToFriend.addonState.isMyHousesScrollable = false
PortToFriend.addonState.names = {}
PortToFriend.addonState.searchResultClicked = false
PortToFriend.addonState.taintedVisitCards = true
PortToFriend.addonState.selectedVisitCard = -1
PortToFriend.addonState.highlightedVisitCard = nil
PortToFriend.addonState.windowCallback = nil
PortToFriend.addonState.selectedTab = PortToFriend.constants.TAB_HOUSE
PortToFriend.addonState.selectedLibraryFilter = PortToFriend.constants.FILTER_ID_NONE
PortToFriend.addonState.selectedLibrarySort = PortToFriend.constants.LIBRARY_SORT_ID_NONE
PortToFriend.addonState.categoryFilterInitialized = false
PortToFriend.addonState.LibrarySortInitialized = false
PortToFriend.addonState.selectedMyHousesSort = PortToFriend.constants.SORT_ID_HOUSE
PortToFriend.addonState.sortInitialized = false
PortToFriend.savedVars = nil

PortToFriend.defaults = {}
PortToFriend.defaults.vc_chatAllowed = {}
PortToFriend.defaults.vc_chatAllowed.g1 = true
PortToFriend.defaults.vc_chatAllowed.o1 = true
PortToFriend.defaults.vc_chatAllowed.g2 = true
PortToFriend.defaults.vc_chatAllowed.o2 = true
PortToFriend.defaults.vc_chatAllowed.g3 = true
PortToFriend.defaults.vc_chatAllowed.o3 = true
PortToFriend.defaults.vc_chatAllowed.g4 = true
PortToFriend.defaults.vc_chatAllowed.o4 = true
PortToFriend.defaults.vc_chatAllowed.g5 = true
PortToFriend.defaults.vc_chatAllowed.o5 = true
PortToFriend.defaults.vc_chatAllowed.emote = false
PortToFriend.defaults.vc_chatAllowed.say = false
PortToFriend.defaults.vc_chatAllowed.yell = false
PortToFriend.defaults.vc_chatAllowed.group = true
PortToFriend.defaults.vc_chatAllowed.tell = true
PortToFriend.defaults.vc_chatAllowed.zone = false
PortToFriend.defaults.vc_chatAllowed.enzone = false
PortToFriend.defaults.vc_chatAllowed.frzone = false
PortToFriend.defaults.vc_chatAllowed.dezone = false
PortToFriend.defaults.vc_chatAllowed.jpzone = false
PortToFriend.defaults.vc = {}
PortToFriend.defaults.vc.allowSelf = false
PortToFriend.defaults.port_mode = PortToFriend.constants.PORT_MODE_ON_DEACTIVATE
PortToFriend.defaults.defaultTab = PortToFriend.constants.TAB_HOUSE

PortToFriend.menu = {}
PortToFriend.menu.name = "PortToFriendMenu"


PortToFriend.hacks = {}
PortToFriend.hacks.callbackName = "PortToFriend.ContextMenuHack"
PortToFriend.hacks.callbackInterval = 500


local wm = GetWindowManager()

function PortToFriend.PortToFriendOnInitialize(event, addonName)
	
	if addonName == PortToFriend.addonName then
		EVENT_MANAGER:UnregisterForEvent(PortToFriend.addonName, EVENT_ADD_ON_LOADED)
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_OPEN", PortToFriend.constants.TOGGLE_PORT_WINDOW)
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_1", string.format(PortToFriend.constants.PORT_TO_FAVORITE,1))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_2", string.format(PortToFriend.constants.PORT_TO_FAVORITE,2))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_3", string.format(PortToFriend.constants.PORT_TO_FAVORITE,3))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_4", string.format(PortToFriend.constants.PORT_TO_FAVORITE,4))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_5", string.format(PortToFriend.constants.PORT_TO_FAVORITE,5))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_6", string.format(PortToFriend.constants.PORT_TO_FAVORITE,6))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_7", string.format(PortToFriend.constants.PORT_TO_FAVORITE,7))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_8", string.format(PortToFriend.constants.PORT_TO_FAVORITE,8))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_9", string.format(PortToFriend.constants.PORT_TO_FAVORITE,9))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_10", string.format(PortToFriend.constants.PORT_TO_FAVORITE,10))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_INSIDE_1", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_INSIDE,1))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_INSIDE_2", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_INSIDE,2))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_INSIDE_3", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_INSIDE,3))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_INSIDE_4", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_INSIDE,4))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_INSIDE_5", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_INSIDE,5))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_INSIDE_6", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_INSIDE,6))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_INSIDE_7", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_INSIDE,7))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_INSIDE_8", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_INSIDE,8))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_INSIDE_9", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_INSIDE,9))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_INSIDE_10", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_INSIDE,10))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_OUTSIDE_1", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_OUTSIDE,1))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_OUTSIDE_2", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_OUTSIDE,2))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_OUTSIDE_3", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_OUTSIDE,3))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_OUTSIDE_4", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_OUTSIDE,4))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_OUTSIDE_5", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_OUTSIDE,5))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_OUTSIDE_6", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_OUTSIDE,6))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_OUTSIDE_7", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_OUTSIDE,7))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_OUTSIDE_8", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_OUTSIDE,8))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_OUTSIDE_9", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_OUTSIDE,9))
		ZO_CreateStringId("SI_BINDING_NAME_PORTTOFRIENDSHOUSE_FAV_MYHOUSE_OUTSIDE_10", string.format(PortToFriend.constants.PORT_TO_FAVORITE_MY_HOUSE_OUTSIDE,10))
		
		PortToFriend.savedVars = ZO_SavedVars:NewAccountWide("PortToFriendsHouseVars", PortToFriend.version, nil, PortToFriend.defaults)
		if PortToFriend.savedVars.favorites == nil then
			PortToFriend.savedVars.favorites = {}
		end
		if PortToFriend.savedVars.vc == nil then
			PortToFriend.savedVars.vc = {}
		end
		if PortToFriend.savedVars.vc.receivedCards == nil then
			PortToFriend.savedVars.vc.receivedCards = {}
		end
		--version 1.2 name / account fix
		for i = 1, #PortToFriend.savedVars.favorites do
			PortToFriend.Version12NameFix(i)
		end
		
		if GetDisplayName() == "@s0rdrak" then
			PortToFriend.config.houseDebug = true
		end
		
		--Init filters
		if PortToFriend.savedVars.selectedMyHousesSort ~= nil then
			PortToFriend.addonState.selectedMyHousesSort = PortToFriend.savedVars.selectedMyHousesSort
		end
		if PortToFriend.savedVars.selectedLibraryFilter ~= nil then
			PortToFriend.addonState.selectedLibraryFilter = PortToFriend.savedVars.selectedLibraryFilter
		end
		if PortToFriend.savedVars.selectedLibrarySort ~= nil then
			PortToFriend.addonState.selectedLibrarySort = PortToFriend.savedVars.selectedLibrarySort
		end
		
		--myHouses Favorites
		if PortToFriend.savedVars.myHousesFavorites == nil then
			PortToFriend.savedVars.myHousesFavorites = {}
		end
		if PortToFriend.savedVars.myHousesFavorites[PortToFriend.constants.PORT_TYPE_INSIDE] == nil then
			PortToFriend.savedVars.myHousesFavorites[PortToFriend.constants.PORT_TYPE_INSIDE] = {}
		end
		if PortToFriend.savedVars.myHousesFavorites[PortToFriend.constants.PORT_TYPE_OUTSIDE] == nil then
			PortToFriend.savedVars.myHousesFavorites[PortToFriend.constants.PORT_TYPE_OUTSIDE] = {}
		end
		
		PortToFriend.HOUSES = PortToFriend.CreateHouseList()
		
		PortToFriend.controls.TLW = wm:CreateTopLevelWindow(PortToFriend.constants.controls.TLW_NAME)
		
		PortToFriend.controls.TLW:SetDimensions(PortToFriend.config.size.width, PortToFriend.config.size.headerHeight)
		if PortToFriend.savedVars == nil or PortToFriend.savedVars.position == nil then
			PortToFriend.controls.TLW:SetAnchor(CENTER, GuiRoot, CENTER, --[[PortToFriend.config.size.width / 2]]0, -PortToFriend.config.size.height / 2)
		else
			PortToFriend.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PortToFriend.savedVars.position.x , PortToFriend.savedVars.position.y)
		end
		
		PortToFriend.controls.TLW:SetMovable(PortToFriend.config.isMovable)
		PortToFriend.controls.TLW:SetMouseEnabled(PortToFriend.config.isMouseEnabled)
		
		PortToFriend.controls.TLW:SetClampedToScreen(PortToFriend.config.isClampedToScreen)
		PortToFriend.controls.TLW:SetDrawLayer(3)
		PortToFriend.controls.TLW:SetDrawLevel(0)
		PortToFriend.controls.TLW:SetHandler("OnMoveStop", PortToFriend.SaveWindowLocation)
		PortToFriend.controls.TLW:SetHidden(true)
		
		PortToFriend.controls.header = {}
		PortToFriend.controls.header.label = wm:CreateControl(PortToFriend.constants.controls.HEADER_NAME, PortToFriend.controls.TLW, CT_LABEL)
		PortToFriend.controls.header.label:SetAnchor(TOP, PortToFriend.controls.TLW, TOP ,0 , 3)
		PortToFriend.controls.header.label:SetFont(PortToFriend.config.fonts.header)
		PortToFriend.controls.header.label:SetWrapMode(ELLIPSIS)
		PortToFriend.controls.header.label:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
		PortToFriend.controls.header.label:SetText(PortToFriend.constants.HEADER_TITLE)
		
		
		PortToFriend.controls.header.control = wm:CreateControl(PortToFriend.constants.controls.HEADER_CONTROL, PortToFriend.controls.TLW, CT_CONTROL)
		PortToFriend.controls.header.control:SetDimensions(PortToFriend.config.size.width, PortToFriend.config.size.headerHeight + PortToFriend.config.size.headerHeightOffset)
		PortToFriend.controls.header.control:SetAnchor(TOPLEFT, PortToFriend.controls.TLW, TOPLEFT, 0, 0)
		PortToFriend.controls.header.control:SetDrawLayer(0)
		
		PortToFriend.controls.header.backdrop = CreateControlFromVirtual(PortToFriend.constants.controls.HEADER_BACKDROP, PortToFriend.controls.header.control, "ZO_SliderBackdrop")
		PortToFriend.controls.header.backdrop:SetCenterColor(PortToFriend.config.color.backdrop.R, PortToFriend.config.color.backdrop.G, PortToFriend.config.color.backdrop.B, PortToFriend.config.color.backdrop.A)
		PortToFriend.controls.header.backdrop:SetEdgeColor(PortToFriend.config.color.backdropEdge.R, PortToFriend.config.color.backdropEdge.G, PortToFriend.config.color.backdropEdge.B, PortToFriend.config.color.backdropEdge.A)
		
		
		
		PortToFriend.controls.header.button = wm:CreateControl(PortToFriend.constants.controls.HEADER_BUTTON, PortToFriend.controls.TLW, CT_BUTTON)
		PortToFriend.controls.header.button:SetAnchor(TOPRIGHT, PortToFriend.controls.header.control, TOPRIGHT, -3, 7)
		PortToFriend.controls.header.button:SetDimensions(20, 20)
		PortToFriend.controls.header.button:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
		PortToFriend.controls.header.button:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
		PortToFriend.controls.header.button:SetHandler("OnClicked", PortToFriend.CloseWindow)
		
		PortToFriend.controls.body = {}
		PortToFriend.controls.body.control = wm:CreateControl(PortToFriend.constants.controls.BODY_CONTROL, PortToFriend.controls.TLW, CT_CONTROL)
		PortToFriend.controls.body.control:SetDimensions(PortToFriend.config.size.width, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap + PortToFriend.config.tabHeight)
		PortToFriend.controls.body.control:SetAnchor(TOPLEFT, PortToFriend.controls.TLW, TOPLEFT, 0, PortToFriend.config.size.headerHeightOffset + PortToFriend.config.size.headerHeight + PortToFriend.config.size.gap)
		PortToFriend.controls.body.control:SetDrawLayer(0)
		
		PortToFriend.controls.body.backdrop = CreateControlFromVirtual(PortToFriend.constants.controls.BODY_BACKDROP, PortToFriend.controls.body.control, "ZO_SliderBackdrop")
		PortToFriend.controls.body.backdrop:SetCenterColor(PortToFriend.config.color.backdrop.R, PortToFriend.config.color.backdrop.G, PortToFriend.config.color.backdrop.B, PortToFriend.config.color.backdrop.A)
		PortToFriend.controls.body.backdrop:SetEdgeColor(PortToFriend.config.color.backdropEdge.R, PortToFriend.config.color.backdropEdge.G, PortToFriend.config.color.backdropEdge.B, PortToFriend.config.color.backdropEdge.A)
		
		PortToFriend.controls.body.tabControl = wm:CreateControl(nil, PortToFriend.controls.body.control, CT_CONTROL)
		PortToFriend.controls.body.tabControl:SetDimensions(PortToFriend.config.width, PortToFriend.config.tabHeight - PortToFriend.config.tabOffset)
		PortToFriend.controls.body.tabControl:SetAnchor(TOPLEFT, PortToFriend.controls.body.control, TOPLEFT, 0, PortToFriend.config.tabOffset)
		
		PortToFriend.controls.body.tabControl.houseTab = PortToFriend.CreateTabControl(PortToFriend.controls.body.tabControl, PortToFriend.config.tabOffset, PortToFriend.constants.TAB_HOUSE, PortToFriend.constants.TAB_HOUSE_TITLE)
		PortToFriend.controls.body.tabControl.vcTab = PortToFriend.CreateTabControl(PortToFriend.controls.body.tabControl, PortToFriend.config.tabOffset + PortToFriend.config.tabWidth, PortToFriend.constants.TAB_VC, PortToFriend.constants.TAB_VC_TITLE)
		PortToFriend.controls.body.tabControl.myHousesTab = PortToFriend.CreateTabControl(PortToFriend.controls.body.tabControl, PortToFriend.config.tabOffset + PortToFriend.config.tabWidth * 2, PortToFriend.constants.TAB_MYHOUSES, PortToFriend.constants.TAB_MYHOUSES_TITLE)
		PortToFriend.controls.body.tabControl.libraryTab = PortToFriend.CreateTabControl(PortToFriend.controls.body.tabControl, PortToFriend.config.tabOffset + PortToFriend.config.tabWidth * 3, PortToFriend.constants.TAB_LIBRARY, PortToFriend.constants.TAB_LIBRARY_TITLE)
		PortToFriend.controls.body.tabControl.donationTab = PortToFriend.CreateTabControl(PortToFriend.controls.body.tabControl, PortToFriend.config.tabOffset + PortToFriend.config.tabWidth * 4, PortToFriend.constants.TAB_DONATE, PortToFriend.constants.TAB_DONATE_TITLE)
		
		
		PortToFriend.controls.body.edge = wm:CreateControl(nil, PortToFriend.controls.body.control, CT_BACKDROP)
		PortToFriend.controls.body.edge:SetAnchor(TOPLEFT, PortToFriend.controls.body.control, TOPLEFT, 0, PortToFriend.config.tabHeight + PortToFriend.config.tabOffset)
		PortToFriend.controls.body.edge:SetDimensions(PortToFriend.config.size.width, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - PortToFriend.config.tabOffset - 4)
		PortToFriend.controls.body.edge:SetEdgeTexture(nil, 1, 1, 2, 0)
		PortToFriend.controls.body.edge:SetCenterColor(0, 0, 0, 0)
		PortToFriend.controls.body.edge:SetEdgeColor(PortToFriend.config.color.edgeColor.r, PortToFriend.config.color.edgeColor.g, PortToFriend.config.color.edgeColor.b, PortToFriend.config.color.edgeColor.a)
	
		
		PortToFriend.controls.house = {}
		PortToFriend.controls.house.control = wm:CreateControl(nil, PortToFriend.controls.body.control, CT_CONTROL)
		PortToFriend.controls.house.control:SetDimensions(PortToFriend.config.size.width, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap)
		PortToFriend.controls.house.control:SetAnchor(TOPLEFT, PortToFriend.controls.body.control, TOPLEFT, 0, PortToFriend.config.tabHeight)
		PortToFriend.controls.house.control:SetDrawLayer(0)
		
		
		PortToFriend.controls.house.labelPlayer = wm:CreateControl(PortToFriend.constants.controls.BODY_EDITBOX, PortToFriend.controls.house.control, CT_LABEL)
		PortToFriend.controls.house.labelPlayer:SetDimensions(80, 25)
		PortToFriend.controls.house.labelPlayer:SetAnchor(TOPLEFT, PortToFriend.controls.house.control, TOPLEFT, 5, 15)
		PortToFriend.controls.house.labelPlayer:SetText(PortToFriend.constants.LABEL_PLAYER)
		PortToFriend.controls.house.labelPlayer:SetFont(PortToFriend.config.fonts.header)
		PortToFriend.controls.house.labelPlayer:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
		
		
		
		PortToFriend.controls.house.editboxbg, PortToFriend.controls.house.editbox = PortToFriend.CreateEditbox(PortToFriend.controls.house.control)
		PortToFriend.controls.house.editboxbg:SetAnchor(TOPLEFT, PortToFriend.controls.house.control, TOPLEFT, 85, 15)
		PortToFriend.controls.house.editboxbg:SetDimensions(PortToFriend.config.search.width,25)
		
		PortToFriend.controls.house.editbox:SetText("")
		PortToFriend.controls.house.editbox:SetMaxInputChars(128)
		PortToFriend.controls.house.editbox:SetHandler("OnTextChanged", PortToFriend.SearchTextChanged)
		PortToFriend.controls.house.editbox:SetAnchor(TOPLEFT, PortToFriend.controls.house.control, TOPLEFT, 85, 15)
		PortToFriend.controls.house.editbox:SetDimensions(PortToFriend.config.search.width,25)
		
		
		
		PortToFriend.controls.house.combobox = wm:CreateControlFromVirtual(PortToFriend.constants.controls.BODY_DROPDOWN, PortToFriend.controls.house.control, "ZO_ScrollableComboBox")
		PortToFriend.controls.house.combobox:SetAnchor(TOPLEFT, PortToFriend.controls.house.control, TOPLEFT, 345, 15)
		PortToFriend.controls.house.combobox:SetDimensions(325,25)
		PortToFriend.controls.house.dropdown = ZO_ComboBox_ObjectFromContainer(PortToFriend.controls.house.combobox)
		
		PortToFriend.CreateDropdownEntries(PortToFriend.controls.house.dropdown)
		
		PortToFriend.controls.house.buttonPort = wm:CreateControlFromVirtual(nil, PortToFriend.controls.house.control, "ZO_DefaultButton")
		PortToFriend.controls.house.buttonPort:SetAnchor(TOPLEFT, PortToFriend.controls.house.control, TOPLEFT, 670, 15)
		PortToFriend.controls.house.buttonPort:SetDimensions(125,25)
		PortToFriend.controls.house.buttonPort:SetText(PortToFriend.constants.BUTTON_PORT)
		PortToFriend.controls.house.buttonPort:SetClickSound("Click")
		PortToFriend.controls.house.buttonPort:SetHandler("OnClicked", PortToFriend.PortToFriend)
		
		PortToFriend.controls.house.buttonAddFavorite = wm:CreateControlFromVirtual(nil, PortToFriend.controls.house.control, "ZO_DefaultButton")
		PortToFriend.controls.house.buttonAddFavorite:SetAnchor(TOPLEFT, PortToFriend.controls.house.control, TOPLEFT, 670, 50)
		PortToFriend.controls.house.buttonAddFavorite:SetDimensions(125,25)
		PortToFriend.controls.house.buttonAddFavorite:SetText(PortToFriend.constants.BUTTON_ADD_FAVORITE)
		PortToFriend.controls.house.buttonAddFavorite:SetClickSound("Click")
		PortToFriend.controls.house.buttonAddFavorite:SetHandler("OnClicked", PortToFriend.AddToFavorite)
		
		
		PortToFriend.controls.house.buttonPortMain = wm:CreateControlFromVirtual(nil, PortToFriend.controls.house.control, "ZO_DefaultButton")
		PortToFriend.controls.house.buttonPortMain:SetAnchor(TOPLEFT, PortToFriend.controls.house.control, TOPLEFT, 280, 50)
		PortToFriend.controls.house.buttonPortMain:SetDimensions(175,25)
		PortToFriend.controls.house.buttonPortMain:SetText(PortToFriend.constants.BUTTON_MAIN_RESIDENCE)
		PortToFriend.controls.house.buttonPortMain:SetClickSound("Click")
		PortToFriend.controls.house.buttonPortMain:SetHandler("OnClicked", PortToFriend.PortToMainResidence)
		
		
		PortToFriend.controls.house.buttonSendVisitCard = wm:CreateControlFromVirtual(nil, PortToFriend.controls.house.control, "ZO_DefaultButton")
		PortToFriend.controls.house.buttonSendVisitCard:SetAnchor(TOPLEFT, PortToFriend.controls.house.control, TOPLEFT, 475, 50)
		PortToFriend.controls.house.buttonSendVisitCard:SetDimensions(175,25)
		PortToFriend.controls.house.buttonSendVisitCard:SetText(PortToFriend.constants.BUTTON_SEND_VISITCARD)
		PortToFriend.controls.house.buttonSendVisitCard:SetClickSound("Click")
		PortToFriend.controls.house.buttonSendVisitCard:SetHandler("OnClicked", PortToFriend.SendVisitCard)
		
		PortToFriend.controls.house.scrollControl = wm:CreateControl(PortToFriend.constants.controls.SCROLL_CONTROL, PortToFriend.controls.house.control, CT_SCROLL)
		PortToFriend.controls.house.scrollControl:SetDimensions(PortToFriend.config.size.width - 10, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 80 - 5)
		PortToFriend.controls.house.scrollControl:SetAnchor(TOPLEFT, PortToFriend.controls.house.control, TOPLEFT, 5, 80)
		PortToFriend.controls.house.scrollControl:SetScrollBounding(SCROLL_BOUNDING_CONTAINED)
		
		PortToFriend.controls.house.scrollPanel = wm:CreateControl(nil, PortToFriend.controls.house.scrollControl, CT_CONTROL)
		PortToFriend.controls.house.scrollPanel:SetDimensions(PortToFriend.config.size.width - 10, 40)
		PortToFriend.controls.house.scrollPanel:SetAnchor(TOPLEFT, PortToFriend.controls.house.scrollControl, TOPLEFT, 0, 0)
		PortToFriend.controls.house.scrollPanel:SetMouseEnabled(true)
		PortToFriend.controls.house.scrollPanel:SetHandler("OnMouseWheel", PortToFriend.FavoritePanelOnMouseWheel);
		
		PortToFriend.controls.house.slider = wm:CreateControl(nil, PortToFriend.controls.house.control, CT_SLIDER)
		PortToFriend.controls.house.slider:SetDimensions(25, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 80)
		PortToFriend.controls.house.slider:SetAnchor(TOPRIGHT, PortToFriend.controls.house.control, TOPRIGHT, 0, 80)
		PortToFriend.controls.house.slider:SetOrientation(ORIENTATION_VERTICAL)
		PortToFriend.controls.house.slider:SetMouseEnabled(true)
		PortToFriend.controls.house.slider:SetMinMax(0, 100)
		PortToFriend.controls.house.slider:SetThumbTexture("esoui/art/buttons/smoothsliderbutton_up.dds", nil, nil, 25, 50)
		PortToFriend.controls.house.slider:SetValueStep(1)
		PortToFriend.controls.house.slider:SetHandler("OnValueChanged", PortToFriend.AdjustSlider)
	
		
		
		PortToFriend.CreateFavorites()
		PortToFriend.controls.house.searchBox = PortToFriend.CreateSearchBox(PortToFriend.controls.house.control, 85, 38, PortToFriend.config.search.width)
		
		--PortToFriend.CreateVisitCardWindow()
		
		
		PortToFriend.controls.vc = {}
		PortToFriend.controls.vc.control = wm:CreateControl(nil, PortToFriend.controls.body.control, CT_CONTROL)
		PortToFriend.controls.vc.control:SetDimensions(PortToFriend.config.size.width, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap)
		PortToFriend.controls.vc.control:SetAnchor(TOPLEFT, PortToFriend.controls.body.control, TOPLEFT, 0, PortToFriend.config.tabHeight)
		PortToFriend.controls.vc.control:SetDrawLayer(0)
		
		
		PortToFriend.controls.vc.nameLabel = CreateControl(nil, PortToFriend.controls.vc.control, CT_LABEL)
		PortToFriend.controls.vc.nameLabel:SetAnchor(TOPLEFT, PortToFriend.controls.vc.control, TOPLEFT ,8 , 8)
		PortToFriend.controls.vc.nameLabel:SetFont(PortToFriend.config.fonts.header)
		PortToFriend.controls.vc.nameLabel:SetWrapMode(ELLIPSIS)
		PortToFriend.controls.vc.nameLabel:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
		PortToFriend.controls.vc.nameLabel:SetText(PortToFriend.constants.VC_PLAYER)
		PortToFriend.controls.vc.nameLabel:SetDimensions(PortToFriend.config.vc.size.width - 6, 25)
		
		PortToFriend.controls.vc.houseLabel = CreateControl(nil, PortToFriend.controls.vc.control, CT_LABEL)
		PortToFriend.controls.vc.houseLabel:SetAnchor(TOPLEFT, PortToFriend.controls.vc.control, TOPLEFT ,8 , 34)
		PortToFriend.controls.vc.houseLabel:SetFont(PortToFriend.config.fonts.header)
		PortToFriend.controls.vc.houseLabel:SetWrapMode(ELLIPSIS)
		PortToFriend.controls.vc.houseLabel:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
		PortToFriend.controls.vc.houseLabel:SetText(PortToFriend.constants.VC_HOUSE)
		PortToFriend.controls.vc.houseLabel:SetDimensions(PortToFriend.config.vc.size.width - 6, 25)
		
		PortToFriend.controls.vc.addFavoriteButton = CreateControlFromVirtual(nil, PortToFriend.controls.vc.control, "ZO_DefaultButton")
		PortToFriend.controls.vc.addFavoriteButton:SetAnchor(TOPLEFT, PortToFriend.controls.vc.control, TOPLEFT, 0, 65)
		PortToFriend.controls.vc.addFavoriteButton:SetDimensions(125,25)
		PortToFriend.controls.vc.addFavoriteButton:SetText(PortToFriend.constants.BUTTON_ADD_FAVORITE)
		PortToFriend.controls.vc.addFavoriteButton:SetClickSound("Click")
		PortToFriend.controls.vc.addFavoriteButton:SetHandler("OnClicked", PortToFriend.VCAddFavorite)
		
		
		PortToFriend.controls.vc.vcButton = CreateControlFromVirtual(nil, PortToFriend.controls.vc.control, "ZO_DefaultButton")
		PortToFriend.controls.vc.vcButton:SetAnchor(TOPLEFT, PortToFriend.controls.vc.control, TOPLEFT, 130, 65)
		PortToFriend.controls.vc.vcButton:SetDimensions(175,25)
		PortToFriend.controls.vc.vcButton:SetText(PortToFriend.constants.BUTTON_SEND_VISITCARD)
		PortToFriend.controls.vc.vcButton:SetClickSound("Click")
		PortToFriend.controls.vc.vcButton:SetHandler("OnClicked", PortToFriend.VCSendVC)
		
		
		PortToFriend.controls.vc.portButton = CreateControlFromVirtual(nil, PortToFriend.controls.vc.control, "ZO_DefaultButton")
		PortToFriend.controls.vc.portButton:SetAnchor(TOPLEFT, PortToFriend.controls.vc.control, TOPLEFT, 310, 65)
		PortToFriend.controls.vc.portButton:SetDimensions(125,25)
		PortToFriend.controls.vc.portButton:SetText(PortToFriend.constants.BUTTON_PORT)
		PortToFriend.controls.vc.portButton:SetClickSound("Click")
		PortToFriend.controls.vc.portButton:SetHandler("OnClicked", PortToFriend.VCPort)
		
		
		PortToFriend.controls.vc.removeButton = CreateControlFromVirtual(nil, PortToFriend.controls.vc.control, "ZO_DefaultButton")
		PortToFriend.controls.vc.removeButton:SetAnchor(TOPLEFT, PortToFriend.controls.vc.control, TOPLEFT, 430, 65)
		PortToFriend.controls.vc.removeButton:SetDimensions(125,25)
		PortToFriend.controls.vc.removeButton:SetText(PortToFriend.constants.BUTTON_REMOVE)
		PortToFriend.controls.vc.removeButton:SetClickSound("Click")
		PortToFriend.controls.vc.removeButton:SetHandler("OnClicked", PortToFriend.VCRemoveVC)
		
		PortToFriend.controls.vc.addFavoriteButton:SetEnabled(false)
		PortToFriend.controls.vc.vcButton:SetEnabled(false)
		PortToFriend.controls.vc.portButton:SetEnabled(false)
		PortToFriend.controls.vc.removeButton:SetEnabled(false)
		
		PortToFriend.controls.vc.scrollControl = wm:CreateControl(PortToFriend.constants.controls.VC_SCROLL_CONTROL, PortToFriend.controls.vc.control, CT_SCROLL)
		PortToFriend.controls.vc.scrollControl:SetDimensions(PortToFriend.config.size.width - 10, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 95 - 5)
		PortToFriend.controls.vc.scrollControl:SetAnchor(TOPLEFT, PortToFriend.controls.vc.control, TOPLEFT, 5, 95)
		PortToFriend.controls.vc.scrollControl:SetScrollBounding(SCROLL_BOUNDING_CONTAINED)
		
		PortToFriend.controls.vc.scrollPanel = wm:CreateControl(nil, PortToFriend.controls.vc.scrollControl, CT_CONTROL)
		PortToFriend.controls.vc.scrollPanel:SetDimensions(PortToFriend.config.size.width - 10, 40)
		PortToFriend.controls.vc.scrollPanel:SetAnchor(TOPLEFT, PortToFriend.controls.vc.scrollControl, TOPLEFT, 0, 0)
		PortToFriend.controls.vc.scrollPanel:SetMouseEnabled(true)
		PortToFriend.controls.vc.scrollPanel:SetHandler("OnMouseWheel", PortToFriend.VCPanelOnMouseWheel);
		
		PortToFriend.controls.vc.slider = wm:CreateControl(nil, PortToFriend.controls.vc.control, CT_SLIDER)
		PortToFriend.controls.vc.slider:SetDimensions(25, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 90)
		PortToFriend.controls.vc.slider:SetAnchor(TOPRIGHT, PortToFriend.controls.vc.control, TOPRIGHT, 0, 90)
		PortToFriend.controls.vc.slider:SetOrientation(ORIENTATION_VERTICAL)
		PortToFriend.controls.vc.slider:SetMouseEnabled(true)
		PortToFriend.controls.vc.slider:SetMinMax(0, 100)
		PortToFriend.controls.vc.slider:SetThumbTexture("esoui/art/buttons/smoothsliderbutton_up.dds", nil, nil, 25, 50)
		PortToFriend.controls.vc.slider:SetValueStep(1)
		PortToFriend.controls.vc.slider:SetHandler("OnValueChanged", PortToFriend.VCAdjustSlider)
		PortToFriend.UpdateVisitCardList()
		
		
		
		
		PortToFriend.controls.myHouses = {}
		PortToFriend.controls.myHouses.control = wm:CreateControl(nil, PortToFriend.controls.body.control, CT_CONTROL)
		PortToFriend.controls.myHouses.control:SetDimensions(PortToFriend.config.size.width, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap)
		PortToFriend.controls.myHouses.control:SetAnchor(TOPLEFT, PortToFriend.controls.body.control, TOPLEFT, 0, PortToFriend.config.tabHeight)
		PortToFriend.controls.myHouses.control:SetDrawLayer(0)
		
		PortToFriend.controls.myHouses.filterLabel = CreateControl(nil, PortToFriend.controls.myHouses.control, CT_LABEL)
		PortToFriend.controls.myHouses.filterLabel:SetAnchor(TOPLEFT, PortToFriend.controls.myHouses.control, TOPLEFT ,8 , 15)
		PortToFriend.controls.myHouses.filterLabel:SetFont(PortToFriend.config.fonts.header)
		PortToFriend.controls.myHouses.filterLabel:SetWrapMode(ELLIPSIS)
		PortToFriend.controls.myHouses.filterLabel:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
		PortToFriend.controls.myHouses.filterLabel:SetText(PortToFriend.constants.SORT_LABEL)
		PortToFriend.controls.myHouses.filterLabel:SetDimensions(105, 25)
		
		PortToFriend.controls.myHouses.combobox = wm:CreateControlFromVirtual(PortToFriend.constants.controls.COMBOBOX_MYHOUSES, PortToFriend.controls.myHouses.control, "ZO_ScrollableComboBox")
		PortToFriend.controls.myHouses.combobox:SetAnchor(TOPLEFT, PortToFriend.controls.myHouses.control, TOPLEFT, 120, 15)
		PortToFriend.controls.myHouses.combobox:SetDimensions(145,25)
		PortToFriend.controls.myHouses.dropdown = ZO_ComboBox_ObjectFromContainer(PortToFriend.controls.myHouses.combobox)
		
		PortToFriend.CreateSortDropdownEntries(PortToFriend.controls.myHouses.dropdown)
		PortToFriend.controls.myHouses.dropdown:SetSelected(PortToFriend.addonState.selectedMyHousesSort)
		
		PortToFriend.controls.myHouses.scrollControl = wm:CreateControl(nil, PortToFriend.controls.myHouses.control, CT_SCROLL)
		PortToFriend.controls.myHouses.scrollControl:SetDimensions(PortToFriend.config.size.width - 10, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 40 - 5)
		PortToFriend.controls.myHouses.scrollControl:SetAnchor(TOPLEFT, PortToFriend.controls.myHouses.control, TOPLEFT, 5, 40)
		PortToFriend.controls.myHouses.scrollControl:SetScrollBounding(SCROLL_BOUNDING_CONTAINED)
		
		PortToFriend.controls.myHouses.scrollPanel = wm:CreateControl(nil, PortToFriend.controls.myHouses.scrollControl, CT_CONTROL)
		PortToFriend.controls.myHouses.scrollPanel:SetDimensions(PortToFriend.config.size.width - 10, 0)
		PortToFriend.controls.myHouses.scrollPanel:SetAnchor(TOPLEFT, PortToFriend.controls.myHouses.scrollControl, TOPLEFT, 0, 40)
		PortToFriend.controls.myHouses.scrollPanel:SetMouseEnabled(true)
		PortToFriend.controls.myHouses.scrollPanel:SetHandler("OnMouseWheel", PortToFriend.MyHousesPanelOnMouseWheel);
		
		PortToFriend.controls.myHouses.slider = wm:CreateControl(nil, PortToFriend.controls.myHouses.control, CT_SLIDER)
		PortToFriend.controls.myHouses.slider:SetDimensions(25, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 40)
		PortToFriend.controls.myHouses.slider:SetAnchor(TOPRIGHT, PortToFriend.controls.myHouses.control, TOPRIGHT, 0, 40)
		PortToFriend.controls.myHouses.slider:SetOrientation(ORIENTATION_VERTICAL)
		PortToFriend.controls.myHouses.slider:SetMouseEnabled(true)
		PortToFriend.controls.myHouses.slider:SetMinMax(0, 100)
		PortToFriend.controls.myHouses.slider:SetThumbTexture("esoui/art/buttons/smoothsliderbutton_up.dds", nil, nil, 25, 50)
		PortToFriend.controls.myHouses.slider:SetValueStep(1)
		PortToFriend.controls.myHouses.slider:SetHandler("OnValueChanged", PortToFriend.MyHousesAdjustSlider)
		PortToFriend.controls.myHouses.slider:SetValue(1)
		PortToFriend.UpdateMyHouses()
		PortToFriend.addonState.sortInitialized = true
		
		
		
		PortToFriend.controls.library = {}
		PortToFriend.controls.library.control = wm:CreateControl(nil, PortToFriend.controls.body.control, CT_CONTROL)
		PortToFriend.controls.library.control:SetDimensions(PortToFriend.config.size.width, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap)
		PortToFriend.controls.library.control:SetAnchor(TOPLEFT, PortToFriend.controls.body.control, TOPLEFT, 0, PortToFriend.config.tabHeight)
		PortToFriend.controls.library.control:SetDrawLayer(0)
		
		
		PortToFriend.controls.library.information = CreateControl(nil, PortToFriend.controls.library.control, CT_LABEL)
		PortToFriend.controls.library.information:SetAnchor(TOPLEFT, PortToFriend.controls.library.control, TOPLEFT ,8 , 8)
		PortToFriend.controls.library.information:SetFont(PortToFriend.config.fonts.header)
		PortToFriend.controls.library.information:SetWrapMode(ELLIPSIS)
		PortToFriend.controls.library.information:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
		PortToFriend.controls.library.information:SetText(PortToFriend.constants.LIBRARY_MESSAGE)
		PortToFriend.controls.library.information:SetDimensions(PortToFriend.config.size.width - 8, 100)
		
		
		PortToFriend.controls.library.edge = wm:CreateControl(nil, PortToFriend.controls.library.control, CT_BACKDROP)
		PortToFriend.controls.library.edge:SetAnchor(TOPLEFT, PortToFriend.controls.library.control, TOPLEFT, 0, 75)
		PortToFriend.controls.library.edge:SetDimensions(PortToFriend.config.size.width, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - PortToFriend.config.tabOffset - 75)
		PortToFriend.controls.library.edge:SetEdgeTexture(nil, 1, 1, 2, 0)
		PortToFriend.controls.library.edge:SetCenterColor(0, 0, 0, 0)
		PortToFriend.controls.library.edge:SetEdgeColor(PortToFriend.config.color.edgeColor.r, PortToFriend.config.color.edgeColor.g, PortToFriend.config.color.edgeColor.b, PortToFriend.config.color.edgeColor.a)
	
		
		PortToFriend.controls.library.filterLabel = CreateControl(nil, PortToFriend.controls.library.control, CT_LABEL)
		PortToFriend.controls.library.filterLabel:SetAnchor(TOPLEFT, PortToFriend.controls.library.control, TOPLEFT ,8 , 85)
		PortToFriend.controls.library.filterLabel:SetFont(PortToFriend.config.fonts.header)
		PortToFriend.controls.library.filterLabel:SetWrapMode(ELLIPSIS)
		PortToFriend.controls.library.filterLabel:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
		PortToFriend.controls.library.filterLabel:SetText(PortToFriend.constants.FILTER_LABEL)
		PortToFriend.controls.library.filterLabel:SetDimensions(170, 25)
		
		PortToFriend.controls.library.combobox = wm:CreateControlFromVirtual(PortToFriend.constants.controls.COMBOBOX_LIBRARY, PortToFriend.controls.library.control, "ZO_ScrollableComboBox")
		PortToFriend.controls.library.combobox:SetAnchor(TOPLEFT, PortToFriend.controls.library.control, TOPLEFT, 178, 85)
		PortToFriend.controls.library.combobox:SetDimensions(200,25)
		PortToFriend.controls.library.dropdown = ZO_ComboBox_ObjectFromContainer(PortToFriend.controls.library.combobox)
		
		PortToFriendData.currentData = PortToFriendData.GetLibraryData()
		PortToFriend.CreateCategoryDropdownEntries(PortToFriend.controls.library.dropdown)
		PortToFriend.controls.library.dropdown:SetSelected(PortToFriend.addonState.selectedLibraryFilter)
		
		
		PortToFriend.controls.library.sortLabel = CreateControl(nil, PortToFriend.controls.library.control, CT_LABEL)
		PortToFriend.controls.library.sortLabel:SetAnchor(TOPLEFT, PortToFriend.controls.library.control, TOPLEFT ,400 , 85)
		PortToFriend.controls.library.sortLabel:SetFont(PortToFriend.config.fonts.header)
		PortToFriend.controls.library.sortLabel:SetWrapMode(ELLIPSIS)
		PortToFriend.controls.library.sortLabel:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
		PortToFriend.controls.library.sortLabel:SetText(PortToFriend.constants.LIBRARY_SORT_LABEL)
		PortToFriend.controls.library.sortLabel:SetDimensions(170, 25)
		
		PortToFriend.controls.library.sortCombobox = wm:CreateControlFromVirtual(PortToFriend.constants.controls.COMBOBOX_SORT_LIBRARY, PortToFriend.controls.library.control, "ZO_ScrollableComboBox")
		PortToFriend.controls.library.sortCombobox:SetAnchor(TOPLEFT, PortToFriend.controls.library.control, TOPLEFT, 578, 85)
		PortToFriend.controls.library.sortCombobox:SetDimensions(200,25)
		PortToFriend.controls.library.sortDropdown = ZO_ComboBox_ObjectFromContainer(PortToFriend.controls.library.sortCombobox)
		
		PortToFriend.CreateLibrarySortDropdownEntries(PortToFriend.controls.library.sortDropdown)
		PortToFriend.controls.library.sortDropdown:SetSelected(PortToFriend.addonState.selectedLibrarySort)
		
		PortToFriend.controls.library.scrollControl = wm:CreateControl(nil, PortToFriend.controls.library.control, CT_SCROLL)
		PortToFriend.controls.library.scrollControl:SetDimensions(PortToFriend.config.size.width - 10, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 100 - 5)
		PortToFriend.controls.library.scrollControl:SetAnchor(TOPLEFT, PortToFriend.controls.library.control, TOPLEFT, 5, 100)
		PortToFriend.controls.library.scrollControl:SetScrollBounding(SCROLL_BOUNDING_CONTAINED)
		
		PortToFriend.controls.library.scrollPanel = wm:CreateControl(nil, PortToFriend.controls.library.scrollControl, CT_CONTROL)
		PortToFriend.controls.library.scrollPanel:SetDimensions(PortToFriend.config.size.width - 10, 40)
		PortToFriend.controls.library.scrollPanel:SetAnchor(TOPLEFT, PortToFriend.controls.library.scrollControl, TOPLEFT, 0, 0)
		PortToFriend.controls.library.scrollPanel:SetMouseEnabled(true)
		PortToFriend.controls.library.scrollPanel:SetHandler("OnMouseWheel", PortToFriend.LibraryPanelOnMouseWheel);
		
		PortToFriend.controls.library.slider = wm:CreateControl(nil, PortToFriend.controls.library.control, CT_SLIDER)
		PortToFriend.controls.library.slider:SetDimensions(25, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 100)
		PortToFriend.controls.library.slider:SetAnchor(TOPRIGHT, PortToFriend.controls.library.control, TOPRIGHT, 0, 100)
		PortToFriend.controls.library.slider:SetOrientation(ORIENTATION_VERTICAL)
		PortToFriend.controls.library.slider:SetMouseEnabled(true)
		PortToFriend.controls.library.slider:SetMinMax(0, 100)
		PortToFriend.controls.library.slider:SetThumbTexture("esoui/art/buttons/smoothsliderbutton_up.dds", nil, nil, 25, 50)
		PortToFriend.controls.library.slider:SetValueStep(1)
		PortToFriend.controls.library.slider:SetHandler("OnValueChanged", PortToFriend.AdjustLibrarySlider)
	
		PortToFriend.CreateLibraryEntries()
		PortToFriend.addonState.categoryFilterInitialized = true
		PortToFriend.addonState.LibrarySortInitialized = true
		
		PortToFriend.controls.donation = {}
		PortToFriend.controls.donation.control = wm:CreateControl(nil, PortToFriend.controls.body.control, CT_CONTROL)
		PortToFriend.controls.donation.control:SetDimensions(PortToFriend.config.size.width, PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap)
		PortToFriend.controls.donation.control:SetAnchor(TOPLEFT, PortToFriend.controls.body.control, TOPLEFT, 0, PortToFriend.config.tabHeight)
		PortToFriend.controls.donation.control:SetDrawLayer(0)
		
		if GetWorldName() == "EU Megaserver" then
			PortToFriend.controls.donation.donationMessage = CreateControl(nil, PortToFriend.controls.donation.control, CT_LABEL)
			PortToFriend.controls.donation.donationMessage:SetAnchor(TOPLEFT, PortToFriend.controls.donation.control, TOPLEFT ,8 , 8)
			PortToFriend.controls.donation.donationMessage:SetFont(PortToFriend.config.fonts.header)
			PortToFriend.controls.donation.donationMessage:SetWrapMode(ELLIPSIS)
			PortToFriend.controls.donation.donationMessage:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
			PortToFriend.controls.donation.donationMessage:SetText(PortToFriend.constants.DONATION_MESSAGE)
			PortToFriend.controls.donation.donationMessage:SetDimensions(PortToFriend.config.size.width - 8, 100)
			
			PortToFriend.controls.donation.donateButton = CreateControlFromVirtual(nil, PortToFriend.controls.donation.control, "ZO_DefaultButton")
			PortToFriend.controls.donation.donateButton:SetAnchor(TOPLEFT, PortToFriend.controls.donation.control, TOPLEFT, 10, 50)
			PortToFriend.controls.donation.donateButton:SetDimensions(200,25)
			PortToFriend.controls.donation.donateButton:SetText(PortToFriend.constants.BUTTON_DONATION_PERSONAL)
			PortToFriend.controls.donation.donateButton:SetClickSound("Click")
			PortToFriend.controls.donation.donateButton:SetHandler("OnClicked", PortToFriend.DonatePersonalAmount)
			
			PortToFriend.controls.donation.donate5Button = CreateControlFromVirtual(nil, PortToFriend.controls.donation.control, "ZO_DefaultButton")
			PortToFriend.controls.donation.donate5Button:SetAnchor(TOPLEFT, PortToFriend.controls.donation.control, TOPLEFT, 210, 50)
			PortToFriend.controls.donation.donate5Button:SetDimensions(200,25)
			PortToFriend.controls.donation.donate5Button:SetText(PortToFriend.constants.BUTTON_DONATION_5)
			PortToFriend.controls.donation.donate5Button:SetClickSound("Click")
			PortToFriend.controls.donation.donate5Button:SetHandler("OnClicked", PortToFriend.Donate5k)
			
			PortToFriend.controls.donation.donate50Button = CreateControlFromVirtual(nil, PortToFriend.controls.donation.control, "ZO_DefaultButton")
			PortToFriend.controls.donation.donate50Button:SetAnchor(TOPLEFT, PortToFriend.controls.donation.control, TOPLEFT, 410, 50)
			PortToFriend.controls.donation.donate50Button:SetDimensions(200,25)
			PortToFriend.controls.donation.donate50Button:SetText(PortToFriend.constants.BUTTON_DONATION_50)
			PortToFriend.controls.donation.donate50Button:SetClickSound("Click")
			PortToFriend.controls.donation.donate50Button:SetHandler("OnClicked", PortToFriend.Donate50k)
			
		else
			PortToFriend.controls.donation.errorMessage = CreateControl(nil, PortToFriend.controls.donation.control, CT_LABEL)
			PortToFriend.controls.donation.errorMessage:SetAnchor(TOPLEFT, PortToFriend.controls.donation.control, TOPLEFT ,8 , 8)
			PortToFriend.controls.donation.errorMessage:SetFont(PortToFriend.config.fonts.header)
			PortToFriend.controls.donation.errorMessage:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
			PortToFriend.controls.donation.errorMessage:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
			PortToFriend.controls.donation.errorMessage:SetText(PortToFriend.constants.DONATION_WRONG_SERVER)
			PortToFriend.controls.donation.errorMessage:SetDimensions(PortToFriend.config.size.width - 8, 100)
		
			
		end
		
		PortToFriend.addonState.selectedTab = PortToFriend.savedVars.defaultTab
		PortToFriend.TabOnMouseExit(PortToFriend.addonState.selectedTab)
		PortToFriend.TabSelected(PortToFriend.addonState.selectedTab)
		EVENT_MANAGER:RegisterForEvent(PortToFriend.addonName, EVENT_CHAT_MESSAGE_CHANNEL, PortToFriend.ChatMessageReceived)
		--EVENT_MANAGER:RegisterForEvent(PortToFriend.addonName, EVENT_COLLECTIBLE_UPDATED, PortToFriend.CollectibleUpdated)
		--EVENT_MANAGER:RegisterForEvent(PortToFriend.addonName, EVENT_COLLECTION_UPDATED, PortToFriend.CollectionUpdated)
		--EVENT_MANAGER:RegisterForEvent(PortToFriend.addonName, EVENT_COLLECTIBLES_UPDATED, PortToFriend.CollectiblesUpdated)
		EVENT_MANAGER:RegisterForEvent(PortToFriend.addonName, EVENT_COLLECTIBLE_NOTIFICATION_NEW, PortToFriend.CollectibleNotification)
		
		PortToFriend.menu.Initialize(PortToFriend.menu.name, PortToFriend.savedVars)
		
		
		
		--Shissus ContextMenu Hack as he failed to implement this properly
		EVENT_MANAGER:RegisterForUpdate(PortToFriend.hacks.callbackName, PortToFriend.hacks.callbackInterval, PortToFriend.ContextMenuHackOnUpdate)
		EVENT_MANAGER:RegisterForEvent(PortToFriend.callbackName, EVENT_PLAYER_DEACTIVATED, PortToFriend.OnPlayerDeactivated)
	end
end

function PortToFriend.CreateTabControl(rootControl, offset, index, title)
	local control = wm:CreateControl(nil, rootControl, CT_CONTROL)
	control:SetDimensions(PortToFriend.config.tabWidth, PortToFriend.config.tabHeight - PortToFriend.config.tabOffset)
	control:SetAnchor(TOPLEFT, rootControl, TOPLEFT, offset, PortToFriend.config.tabOffset)
	
	control.backdrop = wm:CreateControl(nil, control, CT_BACKDROP)
	control.backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.backdrop:SetDimensions(PortToFriend.config.tabWidth, PortToFriend.config.tabHeight - PortToFriend.config.tabOffset)
	control.backdrop:SetCenterColor(PortToFriend.config.color.tabNotSelected.r, PortToFriend.config.color.tabNotSelected.g, PortToFriend.config.color.tabNotSelected.b, PortToFriend.config.color.tabNotSelected.a)
	control.backdrop:SetEdgeColor(0,0,0,0)
	
	control.edge = wm:CreateControl(nil, control, CT_BACKDROP)
	control.edge:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.edge:SetDimensions(PortToFriend.config.tabWidth, PortToFriend.config.tabHeight - PortToFriend.config.tabOffset)
	control.edge:SetEdgeTexture(nil, 1, 1, 2, 0)
	control.edge:SetCenterColor(0, 0, 0, 0)
	control.edge:SetEdgeColor(PortToFriend.config.color.edgeColor.r, PortToFriend.config.color.edgeColor.g, PortToFriend.config.color.edgeColor.b, PortToFriend.config.color.edgeColor.a)
	
	control.label = wm:CreateControl(nil, control, CT_LABEL)
	control.label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.label:SetFont(PortToFriend.config.tabFont)
	control.label:SetWrapMode(ELLIPSIS)
	control.label:SetColor(PortToFriend.config.color.tabFontColor.r, PortToFriend.config.color.tabFontColor.g, PortToFriend.config.color.tabFontColor.b)
	control.label:SetText(title)
	control.label:SetDimensions(PortToFriend.config.tabWidth, PortToFriend.config.tabHeight - PortToFriend.config.tabOffset)
	control.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	control.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	
	control.button = wm:CreateControl(nil, control, CT_BUTTON)
	local button = control.button
	button:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	button:SetDimensions(PortToFriend.config.tabWidth, PortToFriend.config.tabHeight - PortToFriend.config.tabOffset)
	button:SetHandler("OnClicked", function () PortToFriend.TabSelected(index) end)
	button:SetHandler("OnMouseEnter", function() PortToFriend.TabOnMouseEnter(index) end)
	button:SetHandler("OnMouseExit", function() PortToFriend.TabOnMouseExit(index) end)
	
	
	return control
end

function PortToFriend.TabSelected(index)
	local color = PortToFriend.config.color.tabNotSelected
	if index ~= PortToFriend.constants.TAB_HOUSE then
		PortToFriend.controls.body.tabControl.houseTab.backdrop:SetCenterColor(color.r, color.g, color.b, color.a)
	end
	if index ~= PortToFriend.constants.TAB_VC then
		PortToFriend.controls.body.tabControl.vcTab.backdrop:SetCenterColor(color.r, color.g, color.b, color.a)
	end
	if index ~= PortToFriend.constants.TAB_MYHOUSES then
		PortToFriend.controls.body.tabControl.myHousesTab.backdrop:SetCenterColor(color.r, color.g, color.b, color.a)
	end
	if index ~= PortToFriend.constants.TAB_LIBRARY then
		PortToFriend.controls.body.tabControl.libraryTab.backdrop:SetCenterColor(color.r, color.g, color.b, color.a)
	end
	if index ~= PortToFriend.constants.TAB_DONATE then
		PortToFriend.controls.body.tabControl.donationTab.backdrop:SetCenterColor(color.r, color.g, color.b, color.a)
	end
	PortToFriend.addonState.selectedTab = index
	--d(index)
	if index == PortToFriend.constants.TAB_HOUSE then
		PortToFriend.controls.house.control:SetHidden(false)
		PortToFriend.controls.vc.control:SetHidden(true)
		PortToFriend.controls.myHouses.control:SetHidden(true)
		PortToFriend.controls.library.control:SetHidden(true)
		PortToFriend.controls.donation.control:SetHidden(true)
	end
	if index == PortToFriend.constants.TAB_VC then
		PortToFriend.controls.house.control:SetHidden(true)
		PortToFriend.controls.vc.control:SetHidden(false)
		PortToFriend.controls.myHouses.control:SetHidden(true)
		PortToFriend.controls.library.control:SetHidden(true)
		PortToFriend.controls.donation.control:SetHidden(true)
	end
	if index == PortToFriend.constants.TAB_MYHOUSES then
		PortToFriend.controls.house.control:SetHidden(true)
		PortToFriend.controls.vc.control:SetHidden(true)
		PortToFriend.controls.myHouses.control:SetHidden(false)
		PortToFriend.controls.library.control:SetHidden(true)
		PortToFriend.controls.donation.control:SetHidden(true)
	end
	if index == PortToFriend.constants.TAB_LIBRARY then
		PortToFriend.controls.house.control:SetHidden(true)
		PortToFriend.controls.vc.control:SetHidden(true)
		PortToFriend.controls.myHouses.control:SetHidden(true)
		PortToFriend.controls.library.control:SetHidden(false)
		PortToFriend.controls.donation.control:SetHidden(true)
	end
	if index == PortToFriend.constants.TAB_DONATE then
		PortToFriend.controls.house.control:SetHidden(true)
		PortToFriend.controls.vc.control:SetHidden(true)
		PortToFriend.controls.myHouses.control:SetHidden(true)
		PortToFriend.controls.library.control:SetHidden(true)
		PortToFriend.controls.donation.control:SetHidden(false)
	end
end

function PortToFriend.TabOnMouseEnter(index)
	local control = nil
	if index == PortToFriend.constants.TAB_HOUSE then
		control = PortToFriend.controls.body.tabControl.houseTab.backdrop
	elseif index == PortToFriend.constants.TAB_VC then
		control = PortToFriend.controls.body.tabControl.vcTab.backdrop
	elseif index == PortToFriend.constants.TAB_MYHOUSES then
		control = PortToFriend.controls.body.tabControl.myHousesTab.backdrop
	elseif index == PortToFriend.constants.TAB_LIBRARY then
		control = PortToFriend.controls.body.tabControl.libraryTab.backdrop
	elseif index == PortToFriend.constants.TAB_DONATE then
		control = PortToFriend.controls.body.tabControl.donationTab.backdrop
	end
	control:SetCenterColor(PortToFriend.config.color.tabMouseOver.r, PortToFriend.config.color.tabMouseOver.g, PortToFriend.config.color.tabMouseOver.b, PortToFriend.config.color.tabMouseOver.a)
end

function PortToFriend.TabOnMouseExit(index)
	local control = nil
	if index == PortToFriend.constants.TAB_HOUSE then
		control = PortToFriend.controls.body.tabControl.houseTab.backdrop
	elseif index == PortToFriend.constants.TAB_VC then
		control = PortToFriend.controls.body.tabControl.vcTab.backdrop
	elseif index == PortToFriend.constants.TAB_MYHOUSES then
		control = PortToFriend.controls.body.tabControl.myHousesTab.backdrop
	elseif index == PortToFriend.constants.TAB_LIBRARY then
		control = PortToFriend.controls.body.tabControl.libraryTab.backdrop
	elseif index == PortToFriend.constants.TAB_DONATE then
		control = PortToFriend.controls.body.tabControl.donationTab.backdrop
	end
	
	local color = PortToFriend.config.color.tabSelected
	if index ~= PortToFriend.addonState.selectedTab then
		color = PortToFriend.config.color.tabNotSelected
	end
	control:SetCenterColor(color.r, color.g, color.b, color.a)
end

--Shissus ContextMenu Hack as he failed to implement this properly
function PortToFriend.ContextMenuHackOnUpdate()
	if PortToFriend.hacks.contextMenuHackUpdated == nil then
		PortToFriend.hacks.contextMenuHackUpdated = true
		--d("first")
	else
		--d("second")
		PortToFriend.AdjustContextMenus()
		EVENT_MANAGER:UnregisterForUpdate(PortToFriend.hacks.callbackName)
	end
end

function PortToFriend.Donate(amount)
	SCENE_MANAGER:Show('mailSend')
	zo_callLater(
		function()
			ZO_MailSendToField:SetText("@s0rdrak")
			ZO_MailSendSubjectField:SetText(PortToFriend.constants.DONATE_MAIL_SUBJECT)
			QueueMoneyAttachment(amount)
			ZO_MailSendBodyField:TakeFocus() 
		end, 
	200)
end

function PortToFriend.DonatePersonalAmount()
	PortToFriend.Donate(0)
end

function PortToFriend.Donate5k()
	PortToFriend.Donate(5000)
end

function PortToFriend.Donate50k()
	PortToFriend.Donate(50000)
end

function PortToFriend.CreateHouseList()
--[[
	WORLD_MAP_HOUSES_DATA:RefreshHouseList()
	local retHouses = {}
	local zos_list = WORLD_MAP_HOUSES_DATA:GetHouseList()
	for i = 1, #zos_list do
		retHouses[zos_list[i].houseId] = zos_list[i].houseName
	end
	return retHouses
	--]]
	local data = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects() 
	local retHouses = {}
	PortToFriend.purchasedHouses = {}
	for i = 1, #data do 
		if data[i]:IsHouse() == true then 
			retHouses[data[i]:GetReferenceId()] = data[i]:GetFormattedName()
			if data[i]:IsLocked() == false then
				PortToFriend.purchasedHouses[data[i]:GetReferenceId()] = {}
				PortToFriend.purchasedHouses[data[i]:GetReferenceId()].name = data[i]:GetFormattedName()
				PortToFriend.purchasedHouses[data[i]:GetReferenceId()].location = zo_strformat("<<C:1>>", data[i]:GetHouseLocation())
			end
		end
	end
	return retHouses
end

EVENT_MANAGER:RegisterForEvent(PortToFriend.addonName, EVENT_ADD_ON_LOADED, PortToFriend.PortToFriendOnInitialize)

function PortToFriend.LibraryPanelOnMouseWheel(control, delta)
	if PortToFriend.controls.library.slider:IsHidden() == false then
		local size = 100 / #PortToFriendData.currentData
		local position = -delta * size * 2 + PortToFriend.controls.library.slider:GetValue()
		
		if position < 0 then
			position = 0
		end
		if position > 100 then
			position = 100
		end
		PortToFriend.controls.library.slider:SetValue(position)
	end
end



function PortToFriend.FavoritePanelOnMouseWheel(control, delta)
	if PortToFriend.controls.house.slider:IsHidden() == false then
		local size = 100 / #PortToFriend.savedVars.favorites
		if size < 1 then
			size = 1
		end
		local position = -delta * size * 2 + PortToFriend.controls.house.slider:GetValue()
		
		if position < 0 then
			position = 0
		end
		if position > 100 then
			position = 100
		end
		PortToFriend.controls.house.slider:SetValue(position)
	end
end

function PortToFriend.SendNameToPTF(name)
	PortToFriend.controls.house.editbox:SetText(name)
	PortToFriend.OpenWindow()
end


function PortToFriend.AdjustContextMenus()
	local ShowPlayerContextMenu = CHAT_SYSTEM.ShowPlayerContextMenu
	CHAT_SYSTEM.ShowPlayerContextMenu = function(self, displayName, rawName)
		ShowPlayerContextMenu(self, displayName, rawName)
		AddCustomMenuItem(PortToFriend.constants.CONTEXT_MENU_SEND, function() PortToFriend.SendNameToPTF(displayName) end )
		--d("DisplayName: " .. displayName)
		if ZO_Menu_GetNumMenuItems() > 0 then 
			ShowMenu() 
		end
	end
	
	local GuildRosterRow_OnMouseUp = GUILD_ROSTER_KEYBOARD.GuildRosterRow_OnMouseUp
	GUILD_ROSTER_KEYBOARD.GuildRosterRow_OnMouseUp = function(self, control, button, upInside)

		local data = ZO_ScrollList_GetData(control)
		GuildRosterRow_OnMouseUp(self, control, button, upInside)

		if (button ~= MOUSE_BUTTON_INDEX_RIGHT --[[and not upInside]]) then 
			return 
		end
		
		if data ~= nil then
			--In case someone messed around with the guild roster... >_<
			--data.characterName = string.gsub(data.characterName, "|ceeeeee", "")
			--d(data.displayName)
			AddCustomMenuItem(PortToFriend.constants.CONTEXT_MENU_SEND, function() PortToFriend.SendNameToPTF(data.displayName) end )
			self:ShowMenu(control)
		end
	end
	
end

function PortToFriend.IsChatAllowed(channelType)
	--channelType (12 - 16 g1-5, 17-21 o1-5)
	--6: emote
	--0: say
	--1: yell
	--3: group
	--4: whisper (tell)
	--31: zone
	--32: enzone
	--33: frzone
	--34: dezone
	--35: jpzone
	local retVal = false
	if channelType ~= nil and (
	(channelType == 12 and PortToFriend.savedVars.vc_chatAllowed.g1 == true) or
	(channelType == 13 and PortToFriend.savedVars.vc_chatAllowed.g2 == true) or
	(channelType == 14 and PortToFriend.savedVars.vc_chatAllowed.g3 == true) or
	(channelType == 15 and PortToFriend.savedVars.vc_chatAllowed.g4 == true) or
	(channelType == 16 and PortToFriend.savedVars.vc_chatAllowed.g1 == true) or
	(channelType == 17 and PortToFriend.savedVars.vc_chatAllowed.o1 == true) or
	(channelType == 18 and PortToFriend.savedVars.vc_chatAllowed.o2 == true) or
	(channelType == 19 and PortToFriend.savedVars.vc_chatAllowed.o3 == true) or
	(channelType == 20 and PortToFriend.savedVars.vc_chatAllowed.o4 == true) or
	(channelType == 21 and PortToFriend.savedVars.vc_chatAllowed.o5 == true) or
	(channelType == 0 and PortToFriend.savedVars.vc_chatAllowed.say == true) or
	(channelType == 1 and PortToFriend.savedVars.vc_chatAllowed.yell == true) or
	(channelType == 3 and PortToFriend.savedVars.vc_chatAllowed.group == true) or
	(channelType == 2 and PortToFriend.savedVars.vc_chatAllowed.tell == true) or
	(channelType == 6 and PortToFriend.savedVars.vc_chatAllowed.emote == true) or
	(channelType == 31 and PortToFriend.savedVars.vc_chatAllowed.zone == true) or
	(channelType == 32 and PortToFriend.savedVars.vc_chatAllowed.enzone == true) or
	(channelType == 33 and PortToFriend.savedVars.vc_chatAllowed.frzone == true) or
	(channelType == 34 and PortToFriend.savedVars.vc_chatAllowed.dezone == true) or
	(channelType == 35 and PortToFriend.savedVars.vc_chatAllowed.jpzone == true)
	) then
		retVal = true
	end
	return retVal
end

function PortToFriend.IsValidPTFString(text)
	local retVal = false
	if text ~= nil and PortToFriend.StringStartsWith(text,PortToFriend.constants.sendKeyWord) then
		retVal = true
	end
	return retVal
end

function PortToFriend.AddVisitCardFromString(rawVisitCard)
	local name = ""
	local houseId = 0
	local comment = ""
	if rawVisitCard ~= nil and PortToFriend.StringStartsWith(rawVisitCard, PortToFriend.constants.sendKeyWord) then
		rawVisitCard = string.sub(rawVisitCard, string.len(PortToFriend.constants.sendKeyWord))
		--d(rawVisitCard)
		if tonumber(zo_strtrim(string.find(rawVisitCard, "%("))) ~= nil then
			comment = string.sub(rawVisitCard, string.find(rawVisitCard, "%(") + 1, string.len(rawVisitCard) - 1)
			--d(comment)
			rawVisitCard = zo_strtrim(string.sub(rawVisitCard, 0, string.find(rawVisitCard, "%(") - 1))
			
			--d(rawVisitCard)
			local houseIndex = rawVisitCard:match(".* ()")
			--d(houseIndex)
			if houseIndex ~= nil and tonumber(houseIndex) ~= nil and houseIndex > 0 then
				houseId = string.sub(rawVisitCard, houseIndex)
				--d(houseId)
				if tonumber(houseId) ~= nil then
					name = zo_strtrim(string.sub(rawVisitCard, 0, houseIndex - 1))
					--d(name)
					PortToFriend.AddVisitCard(name, houseId, comment)
				end
			end
		end
	end
end

function PortToFriend.DoesVisitCardExist(entry)
	local retVal = false
	if entry ~= nil then
		for i = 1, #PortToFriend.savedVars.vc.receivedCards do
			if PortToFriend.savedVars.vc.receivedCards[i].name == entry.name and PortToFriend.savedVars.vc.receivedCards[i].houseId == entry.houseId then
			   retVal = true
			   break
			end
		end
	end
	return retVal
end

function PortToFriend.AddVisitCard(name, houseId, comment)
	--d(comment)
	--d(houseId)
	--d(name)
	houseId = tonumber(houseId)
	if houseId ~= nil and houseId > 0 and name ~= nil then
		if PortToFriend.savedVars.vc == nil then
			PortToFriend.savedVars.vc = {}
		end
		if PortToFriend.savedVars.vc.receivedCards == nil then
			PortToFriend.savedVars.vc.receivedCards = {}
		end
		local entry = {}
		entry.name = name
		entry.houseId = houseId
		--entry.comment = comment --might be implemented later
		if not PortToFriend.DoesVisitCardExist(entry) then
			table.insert(PortToFriend.savedVars.vc.receivedCards, entry)
			PortToFriend.addonState.taintedVisitCards = true
		end
		PortToFriend.UpdateVisitCardList()
	end
end

function PortToFriend.ChatMessageReceived(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
	--d(channelType)
	--d(fromName)
	--d(text)
	--d(isCustomerService)
	--d(fromDisplayName)
	--d(PortToFriend.savedVars.vc.allowSelf)
	if eventCode == EVENT_CHAT_MESSAGE_CHANNEL and PortToFriend.IsChatAllowed(channelType) and PortToFriend.IsValidPTFString(text) then
		if fromDisplayName ~= GetDisplayName() or PortToFriend.savedVars.vc.allowSelf == true then
			--d("allowed Channel: " .. fromDisplayName .. ": " .. fromName)
			PortToFriend.AddVisitCardFromString(text)
		end
	end
end
--[[
function PortToFriend.CollectibleUpdated(eventCode, id, justUnlocked)
	--d(eventCode)
	--d(id)
	--d(justUnlocked)
	d("Collectible")
end

function PortToFriend.CollectionUpdated(eventCode)
	d("Collection Updated")
end

function PortToFriend.CollectiblesUpdated(eventCode, numJustUnlocked)
	d("Collectibles")
	d(eventCode)
	d(numJustUnlocked)
end
]]

function PortToFriend.CollectibleNotification(eventCode, collectibleId, notificationId)
	--d("Collectible Notification")
	--d(eventCode)
	--d(collectibleId)
	--d(notificationId)
	local data = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects() 
	for i = 1, #data do 
		if data[i]:IsHouse() == true and data[i].collectibleId == collectibleId then 
			PortToFriend.purchasedHouses[data[i]:GetReferenceId()] = {}
			PortToFriend.purchasedHouses[data[i]:GetReferenceId()].name = data[i]:GetFormattedName()
			PortToFriend.purchasedHouses[data[i]:GetReferenceId()].location = zo_strformat("<<C:1>>", data[i].houseLocation)
			PortToFriend.UpdateMyHouses()
			break
		end
	end
end


function PortToFriend.SortVisitCards()
	if PortToFriend.savedVars.vc.receivedCards ~= nil then
		local cards = PortToFriend.savedVars.vc.receivedCards
		local itemCount = #cards
		repeat
			local hasChanged = false
			itemCount = itemCount - 1
			for i = 1, itemCount do
				if cards[i].name > cards[i + 1].name then					
					cards[i], cards[i + 1] = cards[i + 1], cards[i]
					hasChanged = true
				elseif cards[i].name == cards[i + 1].name then
					if PortToFriend.HOUSES[cards[i].houseId] > PortToFriend.HOUSES[cards[i + 1].houseId] then
						cards[i], cards[i + 1] = cards[i + 1], cards[i]
						hasChanged = true
					end
				end
			end
		until hasChanged == false
		return players
	end
end


function PortToFriend.VCBdOnMouseEnter(index)
	if index ~= nil and index > 0 and PortToFriend.controls.vc ~= nil and PortToFriend.controls.vc.cardEntry ~= nil and PortToFriend.controls.vc.cardEntry[index] ~= nil and PortToFriend.controls.vc.cardEntry[index].backdrop ~= nil then
		if index ~= PortToFriend.addonState.selectedVisitCard then
			PortToFriend.controls.vc.cardEntry[index].backdrop:SetCenterColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, PortToFriend.config.color.backDropLine.A)
			PortToFriend.controls.vc.cardEntry[index].backdrop:SetEdgeColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
		else
			PortToFriend.controls.vc.cardEntry[index].backdrop:SetCenterColor(PortToFriend.config.color.selectedVisitCardColorOnMouseOver.R, PortToFriend.config.color.selectedVisitCardColorOnMouseOver.G, PortToFriend.config.color.selectedVisitCardColorOnMouseOver.B, PortToFriend.config.color.selectedVisitCardColorOnMouseOver.A)
			PortToFriend.controls.vc.cardEntry[index].backdrop:SetEdgeColor(PortToFriend.config.color.selectedVisitCardColorOnMouseOver.R, PortToFriend.config.color.selectedVisitCardColorOnMouseOver.G, PortToFriend.config.color.selectedVisitCardColorOnMouseOver.B, 0.0)
		end
		PortToFriend.addonState.highlightedVisitCard = index
	end
end

function PortToFriend.VCBdOnMouseExit(index)
	if index ~= nil and index > 0 and PortToFriend.controls.vc ~= nil and PortToFriend.controls.vc.cardEntry ~= nil and PortToFriend.controls.vc.cardEntry[index] ~= nil and PortToFriend.controls.vc.cardEntry[index].backdrop ~= nil then
		if index ~= PortToFriend.addonState.selectedVisitCard then
			PortToFriend.controls.vc.cardEntry[index].backdrop:SetCenterColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
			PortToFriend.controls.vc.cardEntry[index].backdrop:SetEdgeColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
		else
			PortToFriend.controls.vc.cardEntry[index].backdrop:SetCenterColor(PortToFriend.config.color.selectedVisitCardColor.R, PortToFriend.config.color.selectedVisitCardColor.G, PortToFriend.config.color.selectedVisitCardColor.B, PortToFriend.config.color.selectedVisitCardColor.A)
			PortToFriend.controls.vc.cardEntry[index].backdrop:SetEdgeColor(PortToFriend.config.color.selectedVisitCardColor.R, PortToFriend.config.color.selectedVisitCardColor.G, PortToFriend.config.color.selectedVisitCardColor.B, 0.0)		
		end
		PortToFriend.addonState.highlightedVisitCard = nil
	end
end

function PortToFriend.VCBdOnClick(index)
	if index ~= nil and tonumber(index) ~= nil then
		PortToFriend.controls.vc.nameLabel:SetText(PortToFriend.constants.VC_PLAYER .. PortToFriend.savedVars.vc.receivedCards[index].name)
		PortToFriend.controls.vc.houseLabel:SetText(PortToFriend.constants.VC_HOUSE .. PortToFriend.HOUSES[PortToFriend.savedVars.vc.receivedCards[index].houseId])
		PortToFriend.addonState.selectedVisitCard = index
		if PortToFriend.controls.vc ~= nil and PortToFriend.controls.vc.cardEntry ~= nil then
			for i = 1, #PortToFriend.controls.vc.cardEntry do
				PortToFriend.VCBdOnMouseExit(i)
			end
		end
		PortToFriend.VCBdOnMouseEnter(index)
		PortToFriend.controls.vc.addFavoriteButton:SetEnabled(true)
		PortToFriend.controls.vc.vcButton:SetEnabled(true)
		PortToFriend.controls.vc.portButton:SetEnabled(true)
		PortToFriend.controls.vc.removeButton:SetEnabled(true)
	end
end

--this function refreshes, respectively creates the controls. Use PortToFriend.UpdateVisitCardList()
function PortToFriend.RefreshVisitCards()
	if PortToFriend.controls.vc ~= nil and PortToFriend.savedVars.vc ~= nil and PortToFriend.savedVars.vc.receivedCards ~= nil then
		local receivedCards = PortToFriend.savedVars.vc.receivedCards
		if PortToFriend.controls.vc.cardEntry == nil then
			PortToFriend.controls.vc.cardEntry = {}
		end
		for i = 1, #receivedCards do
			if PortToFriend.controls.vc.cardEntry[i] == nil then
				PortToFriend.controls.vc.cardEntry[i] = {}
				PortToFriend.controls.vc.cardEntry[i].backdrop = wm:CreateControl(nil, PortToFriend.controls.vc.scrollPanel, CT_BACKDROP)
				PortToFriend.controls.vc.cardEntry[i].name = wm:CreateControl(nil, PortToFriend.controls.vc.cardEntry[i].backdrop, CT_BUTTON)
				PortToFriend.controls.vc.cardEntry[i].house = wm:CreateControl(nil, PortToFriend.controls.vc.cardEntry[i].backdrop, CT_BUTTON)
			end
			
			PortToFriend.controls.vc.cardEntry[i].backdrop:SetDimensions(PortToFriend.config.size.width - 30, 25)
			PortToFriend.controls.vc.cardEntry[i].backdrop:SetHidden(false)
			PortToFriend.controls.vc.cardEntry[i].backdrop:ClearAnchors()
			PortToFriend.controls.vc.cardEntry[i].backdrop:SetAnchor(TOPLEFT, PortToFriend.controls.vc.scrollPanel, TOPLEFT, 5, 25 * (i - 1))
			if i ~= PortToFriend.addonState.selectedVisitCard then
				PortToFriend.controls.vc.cardEntry[i].backdrop:SetCenterColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
				PortToFriend.controls.vc.cardEntry[i].backdrop:SetEdgeColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0, 0)
			else
				PortToFriend.controls.vc.cardEntry[i].backdrop:SetCenterColor(PortToFriend.config.color.selectedVisitCardColor.R, PortToFriend.config.color.selectedVisitCardColor.G, PortToFriend.config.color.selectedVisitCardColor.B, PortToFriend.config.color.selectedVisitCardColor.A)
				PortToFriend.controls.vc.cardEntry[i].backdrop:SetEdgeColor(PortToFriend.config.color.selectedVisitCardColor.R, PortToFriend.config.color.selectedVisitCardColor.G, PortToFriend.config.color.selectedVisitCardColor.B, 0.0)		
			end
			PortToFriend.controls.vc.cardEntry[i].backdrop:SetAlpha(1)
			
			PortToFriend.controls.vc.cardEntry[i].name:SetDimensions(240, 25)
			PortToFriend.controls.vc.cardEntry[i].name:SetHidden(false)
			PortToFriend.controls.vc.cardEntry[i].name:ClearAnchors()
			PortToFriend.controls.vc.cardEntry[i].name:SetAnchor(TOPLEFT, PortToFriend.controls.vc.cardEntry[i].backdrop, TOPLEFT, 0, 0)
			PortToFriend.controls.vc.cardEntry[i].name:SetText(receivedCards[i].name)
			PortToFriend.controls.vc.cardEntry[i].name:SetFont(PortToFriend.config.fonts.header)
			--PortToFriend.controls.vc.cardEntry[i].name:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
			PortToFriend.controls.vc.cardEntry[i].name:SetMouseEnabled(true)
			PortToFriend.controls.vc.cardEntry[i].name:SetHandler("OnMouseEnter", function() PortToFriend.VCBdOnMouseEnter(i) end)
			PortToFriend.controls.vc.cardEntry[i].name:SetHandler("OnMouseExit", function() PortToFriend.VCBdOnMouseExit(i) end)
			PortToFriend.controls.vc.cardEntry[i].name:SetHandler("OnClicked", function() PortToFriend.VCBdOnClick(i) end)
			PortToFriend.controls.vc.cardEntry[i].name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			PortToFriend.controls.vc.cardEntry[i].name:SetNormalFontColor(PortToFriend.config.color.visitCardFontColor.R, PortToFriend.config.color.visitCardFontColor.G, PortToFriend.config.color.visitCardFontColor.B, PortToFriend.config.color.visitCardFontColor.A)
			PortToFriend.controls.vc.cardEntry[i].name:SetPressedFontColor(PortToFriend.config.color.visitCardFontColor.R, PortToFriend.config.color.visitCardFontColor.G, PortToFriend.config.color.visitCardFontColor.B, PortToFriend.config.color.visitCardFontColor.A)
			PortToFriend.controls.vc.cardEntry[i].name:SetMouseOverFontColor(PortToFriend.config.color.visitCardFontColor.R, PortToFriend.config.color.visitCardFontColor.G, PortToFriend.config.color.visitCardFontColor.B, PortToFriend.config.color.visitCardFontColor.A)
		
			PortToFriend.controls.vc.cardEntry[i].house:SetDimensions(500, 25)
			PortToFriend.controls.vc.cardEntry[i].house:SetHidden(false)
			PortToFriend.controls.vc.cardEntry[i].house:ClearAnchors()
			PortToFriend.controls.vc.cardEntry[i].house:SetAnchor(TOPLEFT, PortToFriend.controls.vc.cardEntry[i].backdrop, TOPLEFT, 215, 0)
			PortToFriend.controls.vc.cardEntry[i].house:SetText(PortToFriend.HOUSES[receivedCards[i].houseId])
			PortToFriend.controls.vc.cardEntry[i].house:SetFont(PortToFriend.config.fonts.header)
			--PortToFriend.controls.vc.cardEntry[i].house:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
			PortToFriend.controls.vc.cardEntry[i].house:SetMouseEnabled(true)
			PortToFriend.controls.vc.cardEntry[i].house:SetHandler("OnMouseEnter", function() PortToFriend.VCBdOnMouseEnter(i) end)
			PortToFriend.controls.vc.cardEntry[i].house:SetHandler("OnMouseExit", function() PortToFriend.VCBdOnMouseExit(i) end)
			PortToFriend.controls.vc.cardEntry[i].house:SetHandler("OnClicked", function() PortToFriend.VCBdOnClick(i) end)
			PortToFriend.controls.vc.cardEntry[i].house:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			PortToFriend.controls.vc.cardEntry[i].house:SetNormalFontColor(PortToFriend.config.color.visitCardFontColor.R, PortToFriend.config.color.visitCardFontColor.G, PortToFriend.config.color.visitCardFontColor.B, PortToFriend.config.color.visitCardFontColor.A)
			PortToFriend.controls.vc.cardEntry[i].house:SetPressedFontColor(PortToFriend.config.color.visitCardFontColor.R, PortToFriend.config.color.visitCardFontColor.G, PortToFriend.config.color.visitCardFontColor.B, PortToFriend.config.color.visitCardFontColor.A)
			PortToFriend.controls.vc.cardEntry[i].house:SetMouseOverFontColor(PortToFriend.config.color.visitCardFontColor.R, PortToFriend.config.color.visitCardFontColor.G, PortToFriend.config.color.visitCardFontColor.B, PortToFriend.config.color.visitCardFontColor.A)
		
		end
		for i = #receivedCards + 1, #PortToFriend.controls.vc.cardEntry do
			if PortToFriend.controls.vc.cardEntry[i] ~= nil then
				PortToFriend.controls.vc.cardEntry[i].backdrop:SetHidden(true)
				PortToFriend.controls.vc.cardEntry[i].backdrop:SetDimensions(0,0)
				PortToFriend.controls.vc.cardEntry[i].backdrop:ClearAnchors()
				PortToFriend.controls.vc.cardEntry[i].backdrop:SetAnchor(TOPLEFT, PortToFriend.controls.vc.scrollPanel, TOPLEFT, 0, 0)
				
				PortToFriend.controls.vc.cardEntry[i].name:SetHidden(true)
				PortToFriend.controls.vc.cardEntry[i].name:SetDimensions(0,0)
				PortToFriend.controls.vc.cardEntry[i].name:ClearAnchors()
				PortToFriend.controls.vc.cardEntry[i].name:SetAnchor(TOPLEFT, PortToFriend.controls.vc.cardEntry[i].backdrop, TOPLEFT, 0, 0)
				
				PortToFriend.controls.vc.cardEntry[i].house:SetHidden(true)
				PortToFriend.controls.vc.cardEntry[i].house:SetDimensions(0,0)
				PortToFriend.controls.vc.cardEntry[i].house:ClearAnchors()
				PortToFriend.controls.vc.cardEntry[i].house:SetAnchor(TOPLEFT, PortToFriend.controls.vc.cardEntry[i].backdrop, TOPLEFT, 0, 0)
			end
		end
		PortToFriend.controls.vc.scrollPanel:SetDimensions(PortToFriend.config.size.width - 10, #receivedCards * 25)
		PortToFriend.VCBdOnMouseEnter(PortToFriend.addonState.highlightedVisitCard)
	else
	
	end
	PortToFriend.AdjustVCSliderSize()
end

function PortToFriend.AdjustVCSliderSize()
	local headSize = 25 * #PortToFriend.savedVars.vc.receivedCards + 40 - (PortToFriend.config.vc.size.height - PortToFriend.config.vc.size.headerHeightOffset - PortToFriend.config.vc.size.headerHeight - PortToFriend.config.vc.size.gap - 95)
	local totalSize = 25 * #PortToFriend.savedVars.vc.receivedCards + 40
	local screenSize = PortToFriend.config.vc.size.height - PortToFriend.config.vc.size.headerHeightOffset - PortToFriend.config.vc.size.headerHeight - PortToFriend.config.vc.size.gap - 95
	
	if totalSize <= screenSize then
		if PortToFriend.addonState.isVCScrollable == true then
			PortToFriend.controls.vc.slider:SetValue(0)
		end
		PortToFriend.controls.vc.slider:SetHidden(true)
		PortToFriend.addonState.isVCScrollable = false
	else
		PortToFriend.controls.vc.slider:SetHidden(false)
		PortToFriend.addonState.isVCScrollable = true
	end
	
end

function PortToFriend.UpdateVisitCardList()
	if PortToFriend.controls.vc ~= nil then
		if PortToFriend.addonState.taintedVisitCards == true then
			local selectedEntry = nil
			if PortToFriend.addonState.selectedVisitCard > 0 and PortToFriend.savedVars.vc ~= nil and PortToFriend.savedVars.vc.receivedCards ~= nil then
				selectedEntry = PortToFriend.savedVars.vc.receivedCards[PortToFriend.addonState.selectedVisitCard]
			end
			PortToFriend.SortVisitCards()
			if selectedEntry ~= nil then
				for i = 1, #PortToFriend.savedVars.vc.receivedCards do
					if PortToFriend.savedVars.vc.receivedCards[i] == selectedEntry then
						PortToFriend.addonState.selectedVisitCard = i
						break
					end
				end
			end
			PortToFriend.RefreshVisitCards()
			PortToFriend.addonState.taintedVisitCards = false
		end
	end
end

function PortToFriend.VCAddFavorite()
	if PortToFriend.addonState.selectedVisitCard ~= nil and PortToFriend.addonState.selectedVisitCard > 0 and PortToFriend.savedVars.vc ~= nil and PortToFriend.savedVars.vc.receivedCards ~= nil and PortToFriend.addonState.selectedVisitCard <= #PortToFriend.savedVars.vc.receivedCards	then
		local name = PortToFriend.savedVars.vc.receivedCards[PortToFriend.addonState.selectedVisitCard].name
		local houseId = PortToFriend.savedVars.vc.receivedCards[PortToFriend.addonState.selectedVisitCard].houseId
		PortToFriend.AddFavorite(name, houseId)
	end
end

function PortToFriend.VCSendVC()
	if PortToFriend.addonState.selectedVisitCard ~= nil and PortToFriend.addonState.selectedVisitCard > 0 and PortToFriend.savedVars.vc ~= nil and PortToFriend.savedVars.vc.receivedCards ~= nil and PortToFriend.addonState.selectedVisitCard <= #PortToFriend.savedVars.vc.receivedCards	then
		local name = PortToFriend.savedVars.vc.receivedCards[PortToFriend.addonState.selectedVisitCard].name
		local houseId = PortToFriend.savedVars.vc.receivedCards[PortToFriend.addonState.selectedVisitCard].houseId
		if name ~= nil and houseId ~= nil then
			PortToFriend.SendVisitCardOf(name, houseId, PortToFriend.constants.sendBasicComment)
		end
	end
end

function PortToFriend.VCPort()
	if PortToFriend.addonState.selectedVisitCard ~= nil and PortToFriend.addonState.selectedVisitCard > 0 and PortToFriend.savedVars.vc ~= nil and PortToFriend.savedVars.vc.receivedCards ~= nil and PortToFriend.addonState.selectedVisitCard <= #PortToFriend.savedVars.vc.receivedCards	then
		local name = PortToFriend.savedVars.vc.receivedCards[PortToFriend.addonState.selectedVisitCard].name
		local houseId = PortToFriend.savedVars.vc.receivedCards[PortToFriend.addonState.selectedVisitCard].houseId
		if name ~= nil and houseId ~= nil then
			--d(name)
			--d(houseId)
			
			PortToFriend.JumpToHouse(zo_strtrim(name), tonumber(houseId))
			if PortToFriend.savedVars.port_mode == PortToFriend.constants.PORT_MODE_ON_CLICK then
				PortToFriend.CloseWindow()
			end
		end
	end
end

function PortToFriend.VCRemoveVC()
	if PortToFriend.addonState.selectedVisitCard ~= nil and PortToFriend.addonState.selectedVisitCard > 0 and PortToFriend.savedVars.vc ~= nil and PortToFriend.savedVars.vc.receivedCards ~= nil and PortToFriend.addonState.selectedVisitCard <= #PortToFriend.savedVars.vc.receivedCards	then
		table.remove(PortToFriend.savedVars.vc.receivedCards, PortToFriend.addonState.selectedVisitCard)
		PortToFriend.addonState.taintedVisitCards = true
		PortToFriend.addonState.selectedVisitCard = -1
		PortToFriend.controls.vc.nameLabel:SetText(PortToFriend.constants.VC_PLAYER)
		PortToFriend.controls.vc.houseLabel:SetText(PortToFriend.constants.VC_HOUSE)
		PortToFriend.controls.vc.addFavoriteButton:SetEnabled(false)
		PortToFriend.controls.vc.vcButton:SetEnabled(false)
		PortToFriend.controls.vc.portButton:SetEnabled(false)
		PortToFriend.controls.vc.removeButton:SetEnabled(false)
		PortToFriend.UpdateVisitCardList()
	end
end

function PortToFriend.VCPanelOnMouseWheel(control, delta)
	if PortToFriend.controls.vc.slider:IsHidden() == false and PortToFriend.savedVars.vc ~= nil and PortToFriend.savedVars.vc.receivedCards ~= nil then
		local size = 100 / #PortToFriend.savedVars.vc.receivedCards
		if size < 1 then
			size = 1
		end
		local position = -delta * size * 2 + PortToFriend.controls.vc.slider:GetValue()
		
		if position < 0 then
			position = 0
		end
		if position > 100 then
			position = 100
		end
		PortToFriend.controls.vc.slider:SetValue(position)
	end
end

function PortToFriend.VCAdjustSlider()
	if PortToFriend.savedVars.vc.receivedCards ~= nil then
		local size = 25 * #PortToFriend.savedVars.vc.receivedCards + 10 - (PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 95)
		if size < 0 then
			size = 0
		end
		
		local slide = size / 100 * PortToFriend.controls.vc.slider:GetValue()
		
		PortToFriend.controls.vc.scrollPanel:SetSimpleAnchor(PortToFriend.controls.vc.scrollControl, 0, -slide)
	else
	
	end
end

function PortToFriend.OnPlayerDeactivated()
	if PortToFriend.savedVars.port_mode == PortToFriend.constants.PORT_MODE_ON_DEACTIVATE and PortToFriend.controls.TLW:IsHidden() == false then
		PortToFriend.CloseWindow()
	end
end

function PortToFriend.SortMyHousesByHouse(houseA, houseB)
	if houseA.houseName == nil and houseB.houseName == nil then
		return true
	elseif houseA.houseName ~= nil and houseB.houseName == nil then
		return true
	elseif houseA.houseName == nil and houseB.houseName ~= nil then
		return false
	end
	if houseA.houseName < houseB.houseName then
		return true
	else
		return false
	end
end

function PortToFriend.SortMyHousesByLocation(houseA, houseB)
	if houseA.location == nil and houseB.location == nil then
		return true
	elseif houseA.location ~= nil and houseB.location == nil then
		return true
	elseif houseA.location == nil and houseB.location ~= nil then
		return false
	end
	if houseA.location < houseB.location then
		return true
	elseif houseA.location > houseB.location then
		return false
	else
		return PortToFriend.SortMyHousesByHouse(houseA, houseB)
	end
end

function PortToFriend.GetSortedMyHousesList()
	local sortFunction = nil
	if PortToFriend.addonState.selectedMyHousesSort == PortToFriend.constants.SORT_ID_HOUSE then
		sortFunction = PortToFriend.SortMyHousesByHouse
	else
		sortFunction = PortToFriend.SortMyHousesByLocation
	end
	local purchasedHouses = {}
	if PortToFriend.purchasedHouses ~= nil then
		local currentIndex = 1
		for key, value in pairs(PortToFriend.purchasedHouses) do
			purchasedHouses[currentIndex] = {}
			purchasedHouses[currentIndex].houseId = key
			purchasedHouses[currentIndex].houseName = PortToFriend.purchasedHouses[key].name
			purchasedHouses[currentIndex].location = PortToFriend.purchasedHouses[key].location
			
			currentIndex = currentIndex + 1
		end
		--d(sortFunction)
		--d(purchasedHouses)
		table.sort(purchasedHouses, sortFunction)
	end
	return purchasedHouses
end

--/script for i = 1, 20 do PortToFriend.purchasedHouses[120+i] = {}PortToFriend.purchasedHouses[120+i].name = "test" PortToFriend.purchasedHouses[120+i].location = "test" end
function PortToFriend.UpdateMyHouses()
	local sortedMyHousesList = PortToFriend.GetSortedMyHousesList()
	--d(sortedMyHousesList)
	
	for i = 1, #sortedMyHousesList do
		if PortToFriend.controls.purchasedHouses[i] == nil then
			PortToFriend.controls.purchasedHouses[i] = {}
		end
			
		if PortToFriend.controls.purchasedHouses[i].backDrop == nil then
			PortToFriend.controls.purchasedHouses[i].backDrop = wm:CreateControl(nil, PortToFriend.controls.myHouses.scrollPanel, CT_BACKDROP)
		end
		PortToFriend.controls.purchasedHouses[i].backDrop:SetDimensions(PortToFriend.config.size.width - 30, 25)
		PortToFriend.controls.purchasedHouses[i].backDrop:SetHidden(false)
		PortToFriend.controls.purchasedHouses[i].backDrop:ClearAnchors()
		PortToFriend.controls.purchasedHouses[i].backDrop:SetAnchor(TOPLEFT, PortToFriend.controls.myHouses.scrollPanel, TOPLEFT, 5, 25 * (i - 1) + 15)
		PortToFriend.controls.purchasedHouses[i].backDrop:SetCenterColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
		PortToFriend.controls.purchasedHouses[i].backDrop:SetEdgeColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0, 0)
		PortToFriend.controls.purchasedHouses[i].backDrop:SetAlpha(1)
		--PortToFriend.controls.purchasedHouses[i].backDrop:SetHandler("OnMouseEnter", function() PortToFriend.BdMyHousesOnMouseEnter(i) end)
		--PortToFriend.controls.purchasedHouses[i].backDrop:SetHandler("OnMouseExit", function() PortToFriend.BdMyHousesOnMouseExit(i) end)

		if PortToFriend.controls.purchasedHouses[i].name == nil then
			PortToFriend.controls.purchasedHouses[i].name = wm:CreateControl(nil, PortToFriend.controls.purchasedHouses[i].backDrop, CT_LABEL)
		end			
		PortToFriend.controls.purchasedHouses[i].name:SetDimensions(235, 25)
		PortToFriend.controls.purchasedHouses[i].name:SetHidden(false)
		PortToFriend.controls.purchasedHouses[i].name:ClearAnchors()
		PortToFriend.controls.purchasedHouses[i].name:SetAnchor(TOPLEFT, PortToFriend.controls.purchasedHouses[i].backDrop, TOPLEFT, 0, 0)
		PortToFriend.controls.purchasedHouses[i].name:SetText(sortedMyHousesList[i].houseName)
		PortToFriend.controls.purchasedHouses[i].name:SetFont(PortToFriend.config.fonts.header)
		PortToFriend.controls.purchasedHouses[i].name:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
		PortToFriend.controls.purchasedHouses[i].name:SetMouseEnabled(true)
		PortToFriend.controls.purchasedHouses[i].name:SetHandler("OnMouseEnter", function() PortToFriend.BdMyHousesOnMouseEnter(i) end)
		PortToFriend.controls.purchasedHouses[i].name:SetHandler("OnMouseExit", function() PortToFriend.BdMyHousesOnMouseExit(i) end)
			
		if PortToFriend.controls.purchasedHouses[i].location == nil then
			PortToFriend.controls.purchasedHouses[i].location = wm:CreateControl(nil, PortToFriend.controls.purchasedHouses[i].backDrop, CT_LABEL)
		end			
		PortToFriend.controls.purchasedHouses[i].location:SetDimensions(155, 25)
		PortToFriend.controls.purchasedHouses[i].location:SetHidden(false)
		PortToFriend.controls.purchasedHouses[i].location:ClearAnchors()
		PortToFriend.controls.purchasedHouses[i].location:SetAnchor(TOPLEFT, PortToFriend.controls.purchasedHouses[i].backDrop, TOPLEFT, 235, 0)
		PortToFriend.controls.purchasedHouses[i].location:SetText(sortedMyHousesList[i].location)
		PortToFriend.controls.purchasedHouses[i].location:SetFont(PortToFriend.config.fonts.header)
		PortToFriend.controls.purchasedHouses[i].location:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
		PortToFriend.controls.purchasedHouses[i].location:SetMouseEnabled(true)
		PortToFriend.controls.purchasedHouses[i].location:SetHandler("OnMouseEnter", function() PortToFriend.BdMyHousesOnMouseEnter(i) end)
		PortToFriend.controls.purchasedHouses[i].location:SetHandler("OnMouseExit", function() PortToFriend.BdMyHousesOnMouseExit(i) end)
			
			
		if PortToFriend.controls.purchasedHouses[i].VCButton == nil then
			PortToFriend.controls.purchasedHouses[i].VCButton = wm:CreateControlFromVirtual(nil, PortToFriend.controls.purchasedHouses[i].backDrop, "ZO_DefaultButton")
		end
		PortToFriend.controls.purchasedHouses[i].VCButton:SetHidden(false)
		PortToFriend.controls.purchasedHouses[i].VCButton:ClearAnchors()
		PortToFriend.controls.purchasedHouses[i].VCButton:SetAnchor(TOPLEFT, PortToFriend.controls.purchasedHouses[i].backDrop, TOPLEFT, 390, 0)
		PortToFriend.controls.purchasedHouses[i].VCButton:SetDimensions(50,25)
		PortToFriend.controls.purchasedHouses[i].VCButton:SetText(PortToFriend.constants.BUTTON_VC)
		PortToFriend.controls.purchasedHouses[i].VCButton:SetClickSound("Click")
		PortToFriend.controls.purchasedHouses[i].VCButton:SetHandler("OnClicked", function () PortToFriend.MyHousesToVC(sortedMyHousesList[i].houseId) end)
		PortToFriend.controls.purchasedHouses[i].VCButton:SetHandler("OnMouseEnter", function() PortToFriend.BdMyHousesOnMouseEnter(i) end)
        PortToFriend.controls.purchasedHouses[i].VCButton:SetHandler("OnMouseExit", function() PortToFriend.BdMyHousesOnMouseExit(i) end)
			
		local value = PortToFriend.GetFavoriteIdFromMyHouseId(sortedMyHousesList[i].houseId,  PortToFriend.constants.PORT_TYPE_INSIDE)
		PortToFriend.CreatePortMyHouseFavorite(i, 60, 25, 440, PortToFriend.controls.purchasedHouses[i].backDrop, value, PortToFriend.constants.PORT_TYPE_INSIDE, sortedMyHousesList[i].houseId)
		if PortToFriend.controls.purchasedHouses[i].portInsideButton == nil then
			PortToFriend.controls.purchasedHouses[i].portInsideButton = wm:CreateControlFromVirtual(nil, PortToFriend.controls.purchasedHouses[i].backDrop, "ZO_DefaultButton")
		end
		PortToFriend.controls.purchasedHouses[i].portInsideButton:SetHidden(false)
		PortToFriend.controls.purchasedHouses[i].portInsideButton:ClearAnchors()
		PortToFriend.controls.purchasedHouses[i].portInsideButton:SetAnchor(TOPLEFT, PortToFriend.controls.purchasedHouses[i].backDrop, TOPLEFT, 500, 0)
		PortToFriend.controls.purchasedHouses[i].portInsideButton:SetDimensions(105,25)
		PortToFriend.controls.purchasedHouses[i].portInsideButton:SetText(PortToFriend.constants.MYHOUSES_PORT_INSIDE)
		PortToFriend.controls.purchasedHouses[i].portInsideButton:SetClickSound("Click")
		PortToFriend.controls.purchasedHouses[i].portInsideButton:SetHandler("OnClicked", function () PortToFriend.PortToMyHousesById(sortedMyHousesList[i].houseId, false) end)
		PortToFriend.controls.purchasedHouses[i].portInsideButton:SetHandler("OnMouseEnter", function() PortToFriend.BdMyHousesOnMouseEnter(i) end)
        PortToFriend.controls.purchasedHouses[i].portInsideButton:SetHandler("OnMouseExit", function() PortToFriend.BdMyHousesOnMouseExit(i) end)
		
		value = PortToFriend.GetFavoriteIdFromMyHouseId(sortedMyHousesList[i].houseId,  PortToFriend.constants.PORT_TYPE_OUTSIDE)
		PortToFriend.CreatePortMyHouseFavorite(i, 60, 25, 605, PortToFriend.controls.purchasedHouses[i].backDrop, value, PortToFriend.constants.PORT_TYPE_OUTSIDE, sortedMyHousesList[i].houseId)
		if PortToFriend.controls.purchasedHouses[i].portOutsideButton == nil then
			PortToFriend.controls.purchasedHouses[i].portOutsideButton = wm:CreateControlFromVirtual(nil, PortToFriend.controls.purchasedHouses[i].backDrop, "ZO_DefaultButton")
		end
		PortToFriend.controls.purchasedHouses[i].portOutsideButton:SetHidden(false)
		PortToFriend.controls.purchasedHouses[i].portOutsideButton:ClearAnchors()
		PortToFriend.controls.purchasedHouses[i].portOutsideButton:SetAnchor(TOPLEFT, PortToFriend.controls.purchasedHouses[i].backDrop, TOPLEFT, 665, 0)
		PortToFriend.controls.purchasedHouses[i].portOutsideButton:SetDimensions(105,25)
		PortToFriend.controls.purchasedHouses[i].portOutsideButton:SetText(PortToFriend.constants.MYHOUSES_FRONT_DOOR)
		PortToFriend.controls.purchasedHouses[i].portOutsideButton:SetClickSound("Click")
		PortToFriend.controls.purchasedHouses[i].portOutsideButton:SetHandler("OnClicked", function () PortToFriend.PortToMyHousesById(sortedMyHousesList[i].houseId, true) end)
		PortToFriend.controls.purchasedHouses[i].portOutsideButton:SetHandler("OnMouseEnter", function() PortToFriend.BdMyHousesOnMouseEnter(i) end)
        PortToFriend.controls.purchasedHouses[i].portOutsideButton:SetHandler("OnMouseExit", function() PortToFriend.BdMyHousesOnMouseExit(i) end)
	end
	PortToFriend.controls.myHouses.scrollPanel:SetDimensions(PortToFriend.config.size.width - 10, #sortedMyHousesList * 25 + 15)
	
	PortToFriend.AdjustMyHousesSliderSize()
	
end

function PortToFriend.GetNumPurchasedHouses()
	local ret = 0
	for key, value in pairs(PortToFriend.purchasedHouses) do
		ret = ret + 1
	end
	return ret
end

function PortToFriend.MyHousesPanelOnMouseWheel(control, delta)
	if PortToFriend.controls.myHouses.slider:IsHidden() == false then
		local size = 100 / PortToFriend.GetNumPurchasedHouses()
		if size < 1 then
			size = 1
		end
		local position = -delta * size * 2 + PortToFriend.controls.myHouses.slider:GetValue()
		
		if position < 0 then
			position = 0
		end
		if position > 100 then
			position = 100
		end
		PortToFriend.controls.myHouses.slider:SetValue(position)
	end
end

function PortToFriend.MyHousesAdjustSlider()
	local size = 25 * PortToFriend.GetNumPurchasedHouses() + 10 - (PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 40)
	if size < 0 then
		size = 0
	end
	
	local slide = size / 100 * PortToFriend.controls.myHouses.slider:GetValue()
		
	PortToFriend.controls.myHouses.scrollPanel:SetSimpleAnchor(PortToFriend.controls.myHouses.scrollControl, 0, -slide)
end

function PortToFriend.CalculateVCLocation()
	if PortToFriend.addonState.VCLocationCalculated == nil or PortToFriend.addonState.VCLocationCalculated == false then
		PortToFriend.CreateVisitCardWindow()
		PortToFriend.addonState.VCLocationCalculated = true
	end
end

function PortToFriend.FavoriteToVC(index)
	if index ~= nil and PortToFriend.savedVars.favorites ~= nil and PortToFriend.savedVars.favorites[index] ~= nil then
		PortToFriend.SendVisitCardOf(PortToFriend.savedVars.favorites[index].name, PortToFriend.savedVars.favorites[index].houseId, PortToFriend.constants.sendBasicComment)
	end
end

function PortToFriend.MyHousesToVC(id)
	PortToFriend.SendVisitCardOf(GetDisplayName(), id, PortToFriend.constants.sendBasicComment)
end

function PortToFriend.SendVisitCardOf(name, houseId, comment)
	if name ~= nil and houseId ~= nil and comment ~= nil then
		local message = string.format(PortToFriend.constants.sendBasicString,PortToFriend.constants.sendKeyWord, name, houseId, comment)
		local chat = CHAT_SYSTEM.textEntry.editControl
		if chat:HasFocus() == false then 
			StartChatInput() 
		end
		chat:SetText(message)
	end
end

function PortToFriend.SendVisitCard()
	local name = PortToFriend.controls.house.editbox:GetText()
	local houseId = PortToFriend.addonState.houseId
	if name == nil or zo_strtrim(name) == "" then
		name = GetDisplayName()
	end
	if houseId ~= nil then
		PortToFriend.SendVisitCardOf(name, houseId, PortToFriend.constants.sendBasicComment)
	end
end

function PortToFriend.AdjustLibrarySlider()
	local currentDataCount = #PortToFriend.GetFilteredLibraryData()
	local size = 25 * currentDataCount + 25 - (PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 100)
	if size < 0 then
		size = 0
	end
	
	local slide = size / 100 * PortToFriend.controls.library.slider:GetValue()
	
	PortToFriend.controls.library.scrollPanel:SetSimpleAnchor(PortToFriend.controls.library.scrollControl, 0, -slide)
end

function PortToFriend.AdjustSlider()
	if PortToFriend.savedVars.favorites ~= nil then
		local size = 25 * #PortToFriend.savedVars.favorites + 25 - (PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 80)
		if size < 0 then
			size = 0
		end
		
		local slide = size / 100 * PortToFriend.controls.house.slider:GetValue()
		
		PortToFriend.controls.house.scrollPanel:SetSimpleAnchor(PortToFriend.controls.house.scrollControl, 0, -slide)
	else
	
	end
end

function PortToFriend.SortFriends()
	if PortToFriend.savedVars.favorites ~= nil then
		local favorites = PortToFriend.savedVars.favorites
		local itemCount = #favorites
		repeat
			local hasChanged = false
			itemCount = itemCount - 1
			for i = 1, itemCount do
				if favorites[i].name > favorites[i + 1].name then					
					favorites[i], favorites[i + 1] = favorites[i + 1], favorites[i]
					hasChanged = true
				elseif favorites[i].name == favorites[i + 1].name then
					if PortToFriend.HOUSES[favorites[i].houseId] > PortToFriend.HOUSES[favorites[i + 1].houseId] then
						favorites[i], favorites[i + 1] = favorites[i + 1], favorites[i]
						hasChanged = true
					end
				end
			end
		until hasChanged == false
		return players
	end
end

function PortToFriend.AdjustLibrarySliderSize()
	local currentDataCount = #PortToFriend.GetFilteredLibraryData()
	local headSize = 25 * currentDataCount + 25 - (PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 100)
	local totalSize = 25 * currentDataCount + 25
	local screenSize = PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 100
	
	if totalSize <= screenSize then
		if PortToFriend.addonState.isScrollable == true then
			PortToFriend.controls.library.slider:SetValue(0)
		end
		PortToFriend.controls.library.slider:SetHidden(true)
		PortToFriend.addonState.isScrollable = false
	else
		PortToFriend.controls.library.slider:SetHidden(false)
		PortToFriend.addonState.isScrollable = true
	end
	
end

function PortToFriend.AdjustMyHousesSliderSize()
	local currentDataCount = PortToFriend.GetNumPurchasedHouses()
	local headSize = 25 * currentDataCount + 25 - (PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 40)
	local totalSize = 25 * currentDataCount + 25
	local screenSize = PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 40
	
	if totalSize <= screenSize then
		if PortToFriend.addonState.isMyHousesScrollable == true then
			PortToFriend.controls.myHouses.slider:SetValue(0)
		end
		PortToFriend.controls.myHouses.slider:SetHidden(true)
		PortToFriend.addonState.isMyHousesScrollable = false
	else
		PortToFriend.controls.myHouses.slider:SetHidden(false)
		PortToFriend.addonState.isMyHousesScrollable = true
	end
	
end

function PortToFriend.AdjustSliderSize()
	local headSize = 25 * #PortToFriend.savedVars.favorites + 25 - (PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 80)
	local totalSize = 25 * #PortToFriend.savedVars.favorites + 25
	local screenSize = PortToFriend.config.size.height - PortToFriend.config.size.headerHeightOffset - PortToFriend.config.size.headerHeight - PortToFriend.config.size.gap - 80
	
	if totalSize <= screenSize then
		if PortToFriend.addonState.isScrollable == true then
			PortToFriend.controls.house.slider:SetValue(0)
		end
		PortToFriend.controls.house.slider:SetHidden(true)
		PortToFriend.addonState.isScrollable = false
	else
		PortToFriend.controls.house.slider:SetHidden(false)
		PortToFriend.addonState.isScrollable = true
	end
	
end

--BMU Integration
function PortToFriend.GetFavorites()
	return PortToFriend.savedVars.favorites
end

function PortToFriend.ClearLibraryControls(index)
	--local entries = PortToFriend.GetFilteredLibraryData()
	if PortToFriend.controls.libraryEntries ~= nil and index ~= nil and index <= #PortToFriend.controls.libraryEntries then
		for i = index, #PortToFriend.controls.libraryEntries do
			PortToFriend.controls.libraryEntries[i].backDrop:SetHidden(true)
			PortToFriend.controls.libraryEntries[i].backDrop:ClearAnchors()
			PortToFriend.controls.libraryEntries[i].backDrop:SetAnchor(TOPLEFT, PortToFriend.controls.library.scrollPanel, TOPLEFT, 0, 0)
			PortToFriend.controls.libraryEntries[i].name:SetHidden(true)
			PortToFriend.controls.libraryEntries[i].name:ClearAnchors()
			PortToFriend.controls.libraryEntries[i].name:SetAnchor(TOPLEFT, PortToFriend.controls.libraryEntries[i].backDrop, TOPLEFT, 0, 0)
			PortToFriend.controls.libraryEntries[i].house:SetHidden(true)
			PortToFriend.controls.libraryEntries[i].house:ClearAnchors()
			PortToFriend.controls.libraryEntries[i].house:SetAnchor(TOPLEFT, PortToFriend.controls.libraryEntries[i].backDrop, TOPLEFT, 0, 0)
			PortToFriend.controls.libraryEntries[i].category:SetHidden(true)
			PortToFriend.controls.libraryEntries[i].category:ClearAnchors()
			PortToFriend.controls.libraryEntries[i].category:SetAnchor(TOPLEFT, PortToFriend.controls.libraryEntries[i].backDrop, TOPLEFT, 0, 0)
			PortToFriend.controls.libraryEntries[i].portButton:SetHidden(true)
			PortToFriend.controls.libraryEntries[i].portButton:ClearAnchors()
			PortToFriend.controls.libraryEntries[i].portButton:SetAnchor(TOPLEFT, PortToFriend.controls.libraryEntries[i].backDrop, TOPLEFT, 0, 0)
		end
	end
end

function PortToFriend.ClearFavoriteControls(index)
	if PortToFriend.controls.favorites ~= nil and index ~= nil and index <= #PortToFriend.controls.favorites then
		for i = index, #PortToFriend.controls.favorites do
			PortToFriend.controls.favorites[i].backDrop:SetHidden(true)
			PortToFriend.controls.favorites[i].backDrop:ClearAnchors()
			PortToFriend.controls.favorites[i].backDrop:SetAnchor(TOPLEFT, PortToFriend.controls.house.scrollPanel, TOPLEFT, 0,0)
			PortToFriend.controls.favorites[i].name:SetHidden(true)
			PortToFriend.controls.favorites[i].name:ClearAnchors()
			PortToFriend.controls.favorites[i].name:SetAnchor(TOPLEFT, PortToFriend.controls.favorites[i].backDrop, TOPLEFT, 0,0)
			PortToFriend.controls.favorites[i].house:SetHidden(true)
			PortToFriend.controls.favorites[i].house:ClearAnchors()
			PortToFriend.controls.favorites[i].house:SetAnchor(TOPLEFT, PortToFriend.controls.favorites[i].backDrop, TOPLEFT, 0,0)
			PortToFriend.controls.favorites[i].portButton:SetHidden(true)
			PortToFriend.controls.favorites[i].portButton:ClearAnchors()
			PortToFriend.controls.favorites[i].portButton:SetAnchor(TOPLEFT, PortToFriend.controls.favorites[i].backDrop, TOPLEFT, 0,0)
			PortToFriend.controls.favorites[i].removeButton:SetHidden(true)
			PortToFriend.controls.favorites[i].removeButton:ClearAnchors()
			PortToFriend.controls.favorites[i].removeButton:SetAnchor(TOPLEFT, PortToFriend.controls.favorites[i].backDrop, TOPLEFT, 0,0)
		end
	end
end

function PortToFriend.BdOnMouseEnter(index)
	if PortToFriend.controls.favorites ~= nil and index ~= nil and PortToFriend.controls.favorites[index] ~= nil then
		PortToFriend.controls.favorites[index].backDrop:SetCenterColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, PortToFriend.config.color.backDropLine.A)
		PortToFriend.controls.favorites[index].backDrop:SetEdgeColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
	end
end

function PortToFriend.BdOnMouseExit(index)
	if PortToFriend.controls.favorites ~= nil and index ~= nil and PortToFriend.controls.favorites[index] ~= nil then
		PortToFriend.controls.favorites[index].backDrop:SetCenterColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
		PortToFriend.controls.favorites[index].backDrop:SetEdgeColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
	end
end

function PortToFriend.BdLibraryEntryOnMouseEnter(index)
	if PortToFriend.controls.libraryEntries ~= nil and index ~= nil and PortToFriend.controls.libraryEntries[index] ~= nil then
		PortToFriend.controls.libraryEntries[index].backDrop:SetCenterColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, PortToFriend.config.color.backDropLine.A)
		PortToFriend.controls.libraryEntries[index].backDrop:SetEdgeColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
	end
end

function PortToFriend.BdLibraryEntryOnMouseExit(index)
	if PortToFriend.controls.libraryEntries ~= nil and index ~= nil and PortToFriend.controls.libraryEntries[index] ~= nil then
		PortToFriend.controls.libraryEntries[index].backDrop:SetCenterColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
		PortToFriend.controls.libraryEntries[index].backDrop:SetEdgeColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
	end
end

function PortToFriend.BdMyHousesOnMouseEnter(index)
	if PortToFriend.controls.purchasedHouses ~= nil and index ~= nil and PortToFriend.controls.purchasedHouses[index] ~= nil then
		PortToFriend.controls.purchasedHouses[index].backDrop:SetCenterColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, PortToFriend.config.color.backDropLine.A)
		PortToFriend.controls.purchasedHouses[index].backDrop:SetEdgeColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
	end
end

function PortToFriend.BdMyHousesOnMouseExit(index)
	if PortToFriend.controls.purchasedHouses ~= nil and index ~= nil and PortToFriend.controls.purchasedHouses[index] ~= nil then
		PortToFriend.controls.purchasedHouses[index].backDrop:SetCenterColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
		PortToFriend.controls.purchasedHouses[index].backDrop:SetEdgeColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
	end
end

function PortToFriend.FavoriteCallback(control, text, choice, index)
	local favorites = PortToFriend.savedVars.favorites
	if favorites ~= nil and #favorites > 0 then
		local favId = tonumber(text)
		if favId ~= nil and favId > 0 and favId <= 10 then

			favorites[index].id = favId
			PortToFriend.controls.favorites[index].dropdown:SetSelectedItem(favId)
			for i = 1, #favorites do
				if favorites[i].id == favId and i ~= index then
					PortToFriend.FavoriteCallback(nil, favId + 1, nil, i)
					break
				end
			end
		else
			favorites[index].id = nil
			PortToFriend.controls.favorites[index].dropdown:SetSelectedItem("-")
		end

	end
end

function PortToFriend.MyHouseFavoriteCallback(control, text, choice, index, portType)
	--d("MyHouseFavoriteCallback")
	local favorites = PortToFriend.savedVars.myHousesFavorites[portType]
	if favorites ~= nil then
		local id = tonumber(text)
		local houseId = PortToFriend.controls.myHouses.portFavorites[portType][index].houseId
		if id ~= nil and id > 0 and id <= 10 then
			for key, value in pairs(favorites) do
				if value == houseId then
					favorites[key] = nil
				end
			end
			favorites[id] = houseId
		else
			for key, value in pairs(favorites) do
				if value == houseId then
					favorites[key] = nil
				end
			end
			--PortToFriend.controls.myHouses.portFavorites[portType][index].dropdown:SetSelectedItem("-")
		end
		PortToFriend.UpdateMyHouses()
	end
end

function PortToFriend.GetFavoriteIdFromMyHouseId(id, portType)
	local favorites = PortToFriend.savedVars.myHousesFavorites[portType]
	if favorites ~= nil then
		for key, value in pairs(favorites) do
			if value == id then
				return key
			end
		end
	end
	return nil
end

function PortToFriend.CreateFavoriteCombobox(index, width, height, offsetX, offsetY, container, value)
	if index ~= nil and index > 0 and width ~= nil and height ~= nil and offsetX ~= nil and offsetY ~= nil and container ~= nil then
		if PortToFriend.controls.favorites[index] == nil then
			PortToFriend.controls.favorites[index] = {}
		end
		if PortToFriend.controls.favorites[index].combobox == nil then
			local gameTime = GetGameTimeMilliseconds()
			math.randomseed(gameTime)
			local rand = math.random(1,1000000)
			local comboboxName = string.format(PortToFriend.constants.controls.COMBOBOX_FAVORITES, rand, gameTime)
			PortToFriend.controls.favorites[index].combobox = wm:CreateControlFromVirtual(comboboxName, container, "ZO_ComboBox")
			--PortToFriend.controls.favorites[index].combobox = wm:CreateControlFromVirtual(nil, container, "ZO_ComboBox")
			PortToFriend.controls.favorites[index].comboboxButton = wm:GetControlByName(comboboxName .. "OpenDropdown")
			PortToFriend.controls.favorites[index].comboboxButton:SetHandler("OnMouseEnter", function() PortToFriend.BdOnMouseEnter(index) end)
            PortToFriend.controls.favorites[index].comboboxButton:SetHandler("OnMouseExit", function() PortToFriend.BdOnMouseExit(index) end)
		end
		if PortToFriend.controls.favorites[index].combobox ~= nil then
			PortToFriend.controls.favorites[index].combobox:ClearAnchors()
			PortToFriend.controls.favorites[index].combobox:SetAnchor(TOPLEFT, container, TOPLEFT, offsetX, offsetY)
			PortToFriend.controls.favorites[index].combobox:SetDimensions(width, height)
			PortToFriend.controls.favorites[index].combobox:SetHandler("OnMouseEnter", function() PortToFriend.BdOnMouseEnter(index) end)
            PortToFriend.controls.favorites[index].combobox:SetHandler("OnMouseExit", function() PortToFriend.BdOnMouseExit(index) end)

			if PortToFriend.controls.favorites[index].dropdown == nil then
				PortToFriend.controls.favorites[index].dropdown = ZO_ComboBox_ObjectFromContainer(PortToFriend.controls.favorites[index].combobox)
			end
			
			PortToFriend.controls.favorites[index].dropdown:SetSortsItems(false)
			PortToFriend.controls.favorites[index].dropdown:ClearItems()
			
			local entry = PortToFriend.controls.favorites[index].dropdown:CreateItemEntry("-", function(control, text, choice) PortToFriend.FavoriteCallback(control, text, choice, index) end)
			PortToFriend.controls.favorites[index].dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
			for i = 1, 10 do
				entry = PortToFriend.controls.favorites[index].dropdown:CreateItemEntry(i, function(control, text, choice) PortToFriend.FavoriteCallback(control, text, choice, index) end)
				PortToFriend.controls.favorites[index].dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
			end
			if value == nil then
				PortToFriend.controls.favorites[index].dropdown:SetSelectedItem("-")
			else
				PortToFriend.controls.favorites[index].dropdown:SetSelectedItem(value)
			end
		end
	end
end

function PortToFriend.CreatePortMyHouseFavorite(index, width, height, offsetX, container, value, portType, id)
	if index ~= nil and index > 0 and width ~= nil and height ~= nil and offsetX ~= nil and container ~= nil and portType ~= nil then
		if PortToFriend.controls.myHouses.portFavorites == nil then
			PortToFriend.controls.myHouses.portFavorites = {}
		end
		if PortToFriend.controls.myHouses.portFavorites[portType] == nil then
			PortToFriend.controls.myHouses.portFavorites[portType] = {}
		end
		if PortToFriend.controls.myHouses.portFavorites[portType][index] == nil then
			PortToFriend.controls.myHouses.portFavorites[portType][index] = {}
		end
		if PortToFriend.controls.myHouses.portFavorites[portType][index].combobox == nil then
			local gameTime = GetGameTimeMilliseconds()
			math.randomseed(gameTime)
			local rand = math.random(1,1000000)
			local comboboxName = string.format(PortToFriend.constants.controls.COMBOBOX_MYHOUSES_FAVORITES, portType, index, rand, gameTime)
			PortToFriend.controls.myHouses.portFavorites[portType][index].combobox = wm:CreateControlFromVirtual(comboboxName, container, "ZO_ComboBox")
			PortToFriend.controls.myHouses.portFavorites[portType][index].comboboxButton = wm:GetControlByName(comboboxName .. "OpenDropdown")
			PortToFriend.controls.myHouses.portFavorites[portType][index].comboboxButton:SetHandler("OnMouseEnter", function() PortToFriend.BdMyHousesOnMouseEnter(index) end)
            PortToFriend.controls.myHouses.portFavorites[portType][index].comboboxButton:SetHandler("OnMouseExit", function() PortToFriend.BdMyHousesOnMouseExit(index) end)
		end
		PortToFriend.controls.myHouses.portFavorites[portType][index].backDrop = container
		PortToFriend.controls.myHouses.portFavorites[portType][index].houseId = id
		
		PortToFriend.controls.myHouses.portFavorites[portType][index].combobox:SetAnchor(TOPLEFT, container, TOPLEFT, offsetX, 0)
		PortToFriend.controls.myHouses.portFavorites[portType][index].combobox:SetDimensions(width, height)
		PortToFriend.controls.myHouses.portFavorites[portType][index].combobox:SetHandler("OnMouseEnter", function() PortToFriend.BdMyHousesOnMouseEnter(index) end)
		PortToFriend.controls.myHouses.portFavorites[portType][index].combobox:SetHandler("OnMouseExit", function() PortToFriend.BdMyHousesOnMouseExit(index) end)
		
		if PortToFriend.controls.myHouses.portFavorites[portType][index].dropdown == nil then
			PortToFriend.controls.myHouses.portFavorites[portType][index].dropdown = ZO_ComboBox_ObjectFromContainer(PortToFriend.controls.myHouses.portFavorites[portType][index].combobox)
		end
		
		PortToFriend.controls.myHouses.portFavorites[portType][index].dropdown:SetSortsItems(false)
		PortToFriend.controls.myHouses.portFavorites[portType][index].dropdown:ClearItems()
			
		local entry = PortToFriend.controls.myHouses.portFavorites[portType][index].dropdown:CreateItemEntry("-", function(control, text, choice) PortToFriend.MyHouseFavoriteCallback(control, text, choice, index, portType) end)
		PortToFriend.controls.myHouses.portFavorites[portType][index].dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
		for i = 1, 10 do
			entry = PortToFriend.controls.myHouses.portFavorites[portType][index].dropdown:CreateItemEntry(i, function(control, text, choice) PortToFriend.MyHouseFavoriteCallback(control, text, choice, index, portType) end)
			PortToFriend.controls.myHouses.portFavorites[portType][index].dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
		end
		if value == nil then
			PortToFriend.controls.myHouses.portFavorites[portType][index].dropdown:SetSelectedItem("-")
		else
			PortToFriend.controls.myHouses.portFavorites[portType][index].dropdown:SetSelectedItem(value)
		end
			
	end
end

function PortToFriend.GetFilteredLibraryData()
	local retVal = {}
	local entries = PortToFriendData.currentData
	if PortToFriend.addonState.selectedLibraryFilter == PortToFriend.constants.FILTER_ID_NONE then
		
		for i = 1, #entries do
			retVal[i] = entries[i]
		end
	else
		local currentIndex = 1
		for i = 1, #entries do
			for j = 1, #entries[i].category do
				if entries[i].category[j] == PortToFriend.addonState.selectedLibraryFilter then
					retVal[currentIndex] = entries[i]
					currentIndex = currentIndex + 1
					break
				end
			end
		end
	end
	retVal = PortToFriend.SortFilteredLibraryData(retVal)
	return retVal
end

--/script d(PortToFriend.SortFilteredLibraryData({{name="test",houseId=1},{name="karl",houseId=3}}))
function PortToFriend.SortFilteredLibraryData(data)
	local retVal = {}
	for i = 1, #data do
		retVal[i] = data[i]
	end
	if PortToFriend.addonState.selectedLibrarySort == PortToFriend.constants.LIBRARY_SORT_ID_NONE then
		-- Do nothing here
	elseif PortToFriend.addonState.selectedLibrarySort == PortToFriend.constants.LIBRARY_SORT_ID_NAME then
		--d("sort: name")
		if #data > 1 then
			local itemCount = #retVal
			repeat
				local hasChanged = false
				itemCount = itemCount - 1
				for i = 1, itemCount do
					if retVal[i].name > retVal[i + 1].name then					
						retVal[i], retVal[i + 1] = retVal[i + 1], retVal[i]
						hasChanged = true
						--d("sort: true")
					elseif retVal[i].name == retVal[i + 1].name then
						if PortToFriend.HOUSES[retVal[i].houseId] > PortToFriend.HOUSES[retVal[i + 1].houseId] then
							retVal[i], retVal[i + 1] = retVal[i + 1], retVal[i]
							hasChanged = true
							--d("sort: true")
						end
					end
				end
			until hasChanged == false
		end
	else
		--d("sort: house")
		if #data > 1 then
			local itemCount = #retVal
			repeat
				local hasChanged = false
				itemCount = itemCount - 1
				for i = 1, itemCount do
					if PortToFriend.HOUSES[retVal[i].houseId] > PortToFriend.HOUSES[retVal[i + 1].houseId] then					
						retVal[i], retVal[i + 1] = retVal[i + 1], retVal[i]
						hasChanged = true
					elseif PortToFriend.HOUSES[retVal[i].houseId] == PortToFriend.HOUSES[retVal[i + 1].houseId] then
						if retVal[i].name > retVal[i + 1].name then
							retVal[i], retVal[i + 1] = retVal[i + 1], retVal[i]
							hasChanged = true
						end
					end
				end
			until hasChanged == false
		end
	end
	return retVal
end

function PortToFriend.GetCategoryString(categories)
	local retVal = ""
	local categoryList = PortToFriend.CreateCategoryFilterList()
	if categories ~= nil then
		for i = 1, #categories do
			if i ~= #categories then
				if categoryList[categories[i]] ~= nil then
					retVal = retVal .. categoryList[categories[i]] .. ", "
				end
			else
				if categoryList[categories[i]] ~= nil then
					retVal = retVal .. categoryList[categories[i]]
				end
			end
		end
	end
	return retVal
end

function PortToFriend.LibraryEntryNoteOnMouseEnter(index, control)
	local entries = PortToFriend.GetFilteredLibraryData()
	local entry = entries[index]
	if entry ~= nil and entry.description ~= nil then
		local description = entry.description
		InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0)
        SetTooltipText(InformationTooltip, description)
		--d(description)
	end
end
			
function PortToFriend.LibraryEntryNoteOnMouseExit(index)
	ClearTooltip(InformationTooltip)
	--d("clear")
end

function PortToFriend.CreateLibraryEntries()
	if PortToFriendData.currentData ~= nil then
		local entries = PortToFriend.GetFilteredLibraryData()
		
		--local categories = PortToFriend.CreateCategoryFilterList()
		for i = 1, #entries do
			if PortToFriend.controls.libraryEntries[i] == nil then
				PortToFriend.controls.libraryEntries[i] = {}
			end
			if PortToFriend.controls.libraryEntries[i].backDrop == nil then
				PortToFriend.controls.libraryEntries[i].backDrop = wm:CreateControl(nil, PortToFriend.controls.library.scrollPanel, CT_BACKDROP)
			end
			PortToFriend.controls.libraryEntries[i].backDrop:SetDimensions(PortToFriend.config.size.width - 30, 25)
			PortToFriend.controls.libraryEntries[i].backDrop:SetHidden(false)
			PortToFriend.controls.libraryEntries[i].backDrop:ClearAnchors()
			PortToFriend.controls.libraryEntries[i].backDrop:SetAnchor(TOPLEFT, PortToFriend.controls.library.scrollPanel, TOPLEFT, 5, 25 * (i - 1) + 15)
			PortToFriend.controls.libraryEntries[i].backDrop:SetCenterColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
			PortToFriend.controls.libraryEntries[i].backDrop:SetEdgeColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0, 0)
			PortToFriend.controls.libraryEntries[i].backDrop:SetAlpha(1)
			
			if PortToFriend.controls.libraryEntries[i].name == nil then
				PortToFriend.controls.libraryEntries[i].name = wm:CreateControl(nil, PortToFriend.controls.libraryEntries[i].backDrop, CT_LABEL)
			end			
			PortToFriend.controls.libraryEntries[i].name:SetDimensions(215, 25)
			PortToFriend.controls.libraryEntries[i].name:SetHidden(false)
			PortToFriend.controls.libraryEntries[i].name:ClearAnchors()
			PortToFriend.controls.libraryEntries[i].name:SetAnchor(TOPLEFT, PortToFriend.controls.libraryEntries[i].backDrop, TOPLEFT, 0, 0)
			PortToFriend.controls.libraryEntries[i].name:SetText(entries[i].name)
			PortToFriend.controls.libraryEntries[i].name:SetFont(PortToFriend.config.fonts.header)
			PortToFriend.controls.libraryEntries[i].name:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
			PortToFriend.controls.libraryEntries[i].name:SetMouseEnabled(true)
			PortToFriend.controls.libraryEntries[i].name:SetHandler("OnMouseEnter", function() PortToFriend.BdLibraryEntryOnMouseEnter(i) end)
			PortToFriend.controls.libraryEntries[i].name:SetHandler("OnMouseExit", function() PortToFriend.BdLibraryEntryOnMouseExit(i) end)
			
			if PortToFriend.controls.libraryEntries[i].house == nil then
				PortToFriend.controls.libraryEntries[i].house = wm:CreateControl(nil, PortToFriend.controls.libraryEntries[i].backDrop, CT_LABEL)
			end			
			PortToFriend.controls.libraryEntries[i].house:SetDimensions(270, 25)
			PortToFriend.controls.libraryEntries[i].house:SetHidden(false)
			PortToFriend.controls.libraryEntries[i].house:ClearAnchors()
			PortToFriend.controls.libraryEntries[i].house:SetAnchor(TOPLEFT, PortToFriend.controls.libraryEntries[i].backDrop, TOPLEFT, 215, 0)
			PortToFriend.controls.libraryEntries[i].house:SetText(PortToFriend.HOUSES[entries[i].houseId])
			PortToFriend.controls.libraryEntries[i].house:SetFont(PortToFriend.config.fonts.header)
			PortToFriend.controls.libraryEntries[i].house:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
			PortToFriend.controls.libraryEntries[i].house:SetMouseEnabled(true)
			PortToFriend.controls.libraryEntries[i].house:SetHandler("OnMouseEnter", function() PortToFriend.BdLibraryEntryOnMouseEnter(i) end)
			PortToFriend.controls.libraryEntries[i].house:SetHandler("OnMouseExit", function() PortToFriend.BdLibraryEntryOnMouseExit(i) end)
			
			if PortToFriend.controls.libraryEntries[i].category == nil then
				PortToFriend.controls.libraryEntries[i].category = wm:CreateControl(nil, PortToFriend.controls.libraryEntries[i].backDrop, CT_LABEL)
			end			
			PortToFriend.controls.libraryEntries[i].category:SetDimensions(175, 25)
			PortToFriend.controls.libraryEntries[i].category:SetHidden(false)
			PortToFriend.controls.libraryEntries[i].category:ClearAnchors()
			PortToFriend.controls.libraryEntries[i].category:SetAnchor(TOPLEFT, PortToFriend.controls.libraryEntries[i].backDrop, TOPLEFT, 490, 0)
			PortToFriend.controls.libraryEntries[i].category:SetText(PortToFriend.GetCategoryString(entries[i].category))
			PortToFriend.controls.libraryEntries[i].category:SetFont(PortToFriend.config.fonts.header)
			PortToFriend.controls.libraryEntries[i].category:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
			PortToFriend.controls.libraryEntries[i].category:SetMouseEnabled(true)
			PortToFriend.controls.libraryEntries[i].category:SetHandler("OnMouseEnter", function() PortToFriend.BdLibraryEntryOnMouseEnter(i) end)
			PortToFriend.controls.libraryEntries[i].category:SetHandler("OnMouseExit", function() PortToFriend.BdLibraryEntryOnMouseExit(i) end)
			

			--EsoUI/Art/Contacts/social_note_up.dds
			if PortToFriend.controls.libraryEntries[i].noteTexture == nil then
				PortToFriend.controls.libraryEntries[i].noteTexture = wm:CreateControl(nil, PortToFriend.controls.libraryEntries[i].backDrop, CT_TEXTURE)
			end
			PortToFriend.controls.libraryEntries[i].noteTexture:ClearAnchors()
			PortToFriend.controls.libraryEntries[i].noteTexture:SetAnchor(TOPLEFT, PortToFriend.controls.libraryEntries[i].backDrop, TOPLEFT, 660, 0) 
			PortToFriend.controls.libraryEntries[i].noteTexture:SetDimensions(25, 25)
			PortToFriend.controls.libraryEntries[i].noteTexture:SetTexture("EsoUI/Art/Contacts/social_note_up.dds")
			--PortToFriend.controls.libraryEntries[i].noteTexture:SetHandler("OnMouseEnter", function() PortToFriend.LibraryEntryNoteOnMouseEnter(i, PortToFriend.controls.libraryEntries[i].noteTexture) end)
			--PortToFriend.controls.libraryEntries[i].noteTexture:SetHandler("OnMouseExit", function() PortToFriend.LibraryEntryNoteOnMouseExit(i) end)

			
			if PortToFriend.controls.libraryEntries[i].noteButton == nil then
				PortToFriend.controls.libraryEntries[i].noteButton = wm:CreateControl(nil, PortToFriend.controls.libraryEntries[i].backDrop, CT_LABEL)
			end
			--PortToFriend.controls.libraryEntries[i].noteButton:EnableMouseButton(MOUSE_BUTTON_INDEX_RIGHT, true)
			PortToFriend.controls.libraryEntries[i].noteButton:SetMouseEnabled(true)
			PortToFriend.controls.libraryEntries[i].noteButton:ClearAnchors()
			PortToFriend.controls.libraryEntries[i].noteButton:SetAnchor(TOPLEFT, PortToFriend.controls.libraryEntries[i].backDrop, TOPLEFT, 660, 0)
			PortToFriend.controls.libraryEntries[i].noteButton:SetDimensions(25, 25)
			PortToFriend.controls.libraryEntries[i].noteButton:SetHandler("OnMouseEnter", function() PortToFriend.BdLibraryEntryOnMouseEnter(i) PortToFriend.LibraryEntryNoteOnMouseEnter(i, PortToFriend.controls.libraryEntries[i].noteButton) end)
			PortToFriend.controls.libraryEntries[i].noteButton:SetHandler("OnMouseExit", function() PortToFriend.BdLibraryEntryOnMouseExit(i) PortToFriend.LibraryEntryNoteOnMouseExit(i) end)
			--PortToFriend.controls.libraryEntries[i].noteButton:SetHandler("OnClicked", function() RdKGToolAdmin.EquipmentEntryOnClick(index) end)
			
			if entries[i].description ~= nil and zo_strtrim(entries[i].description) ~= "" then
				PortToFriend.controls.libraryEntries[i].category:SetDimensions(175, 25)
				PortToFriend.controls.libraryEntries[i].noteTexture:SetHidden(false)
				PortToFriend.controls.libraryEntries[i].noteButton:SetHidden(false)
			else
				PortToFriend.controls.libraryEntries[i].category:SetDimensions(195, 25)
				PortToFriend.controls.libraryEntries[i].noteTexture:SetHidden(true)
				PortToFriend.controls.libraryEntries[i].noteButton:SetHidden(true)
			end
			
			
			if PortToFriend.controls.libraryEntries[i].portButton == nil then
				PortToFriend.controls.libraryEntries[i].portButton = wm:CreateControlFromVirtual(nil, PortToFriend.controls.libraryEntries[i].backDrop, "ZO_DefaultButton")
			end
			PortToFriend.controls.libraryEntries[i].portButton:SetHidden(false)
			PortToFriend.controls.libraryEntries[i].portButton:ClearAnchors()
			PortToFriend.controls.libraryEntries[i].portButton:SetAnchor(TOPLEFT, PortToFriend.controls.libraryEntries[i].backDrop, TOPLEFT, 675, 0)
			PortToFriend.controls.libraryEntries[i].portButton:SetDimensions(90,25)
			PortToFriend.controls.libraryEntries[i].portButton:SetText(PortToFriend.constants.BUTTON_PORT)
			PortToFriend.controls.libraryEntries[i].portButton:SetClickSound("Click")
			PortToFriend.controls.libraryEntries[i].portButton:SetHandler("OnClicked", function () PortToFriend.PortToLibraryEntry(i) end)
			PortToFriend.controls.libraryEntries[i].portButton:SetHandler("OnMouseEnter", function() PortToFriend.BdLibraryEntryOnMouseEnter(i) end)
            PortToFriend.controls.libraryEntries[i].portButton:SetHandler("OnMouseExit", function() PortToFriend.BdLibraryEntryOnMouseExit(i) end)
			
			
			
		end
		
		PortToFriend.controls.library.scrollPanel:SetDimensions(PortToFriend.config.size.width - 10, #entries * 25 + 15)
	else
		
	end
	PortToFriend.AdjustLibrarySliderSize()
end

function PortToFriend.CreateFavorites()
	if PortToFriend.savedVars.favorites ~= nil then
		PortToFriend.SortFriends()
		local favorites = PortToFriend.savedVars.favorites
		for i = 1, #favorites do
			if PortToFriend.controls.favorites[i] == nil then
				PortToFriend.controls.favorites[i] = {}
			end
			
			if PortToFriend.controls.favorites[i].backDrop == nil then
				PortToFriend.controls.favorites[i].backDrop = wm:CreateControl(nil, PortToFriend.controls.house.scrollPanel, CT_BACKDROP)
			end
			PortToFriend.controls.favorites[i].backDrop:SetDimensions(PortToFriend.config.size.width - 30, 25)
			PortToFriend.controls.favorites[i].backDrop:SetHidden(false)
			PortToFriend.controls.favorites[i].backDrop:ClearAnchors()
			PortToFriend.controls.favorites[i].backDrop:SetAnchor(TOPLEFT, PortToFriend.controls.house.scrollPanel, TOPLEFT, 5, 25 * (i - 1) + 15)
			PortToFriend.controls.favorites[i].backDrop:SetCenterColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
			PortToFriend.controls.favorites[i].backDrop:SetEdgeColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0, 0)
			PortToFriend.controls.favorites[i].backDrop:SetAlpha(1)

			if PortToFriend.controls.favorites[i].name == nil then
				PortToFriend.controls.favorites[i].name = wm:CreateControl(nil, PortToFriend.controls.favorites[i].backDrop, CT_LABEL)
			end			
			PortToFriend.controls.favorites[i].name:SetDimensions(220, 25)
			PortToFriend.controls.favorites[i].name:SetHidden(false)
			PortToFriend.controls.favorites[i].name:ClearAnchors()
			PortToFriend.controls.favorites[i].name:SetAnchor(TOPLEFT, PortToFriend.controls.favorites[i].backDrop, TOPLEFT, 0, 0)
			PortToFriend.controls.favorites[i].name:SetText(favorites[i].name)
			PortToFriend.controls.favorites[i].name:SetFont(PortToFriend.config.fonts.header)
			PortToFriend.controls.favorites[i].name:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
			PortToFriend.controls.favorites[i].name:SetMouseEnabled(true)
			PortToFriend.controls.favorites[i].name:SetHandler("OnMouseEnter", function() PortToFriend.BdOnMouseEnter(i) end)
			PortToFriend.controls.favorites[i].name:SetHandler("OnMouseExit", function() PortToFriend.BdOnMouseExit(i) end)
			
			if PortToFriend.controls.favorites[i].house == nil then
				PortToFriend.controls.favorites[i].house = wm:CreateControl(nil, PortToFriend.controls.favorites[i].backDrop, CT_LABEL)
			end			
			PortToFriend.controls.favorites[i].house:SetDimensions(265, 25)
			PortToFriend.controls.favorites[i].house:SetHidden(false)
			PortToFriend.controls.favorites[i].house:ClearAnchors()
			PortToFriend.controls.favorites[i].house:SetAnchor(TOPLEFT, PortToFriend.controls.favorites[i].backDrop, TOPLEFT, 215, 0)
			PortToFriend.controls.favorites[i].house:SetText(PortToFriend.HOUSES[favorites[i].houseId])
			PortToFriend.controls.favorites[i].house:SetFont(PortToFriend.config.fonts.header)
			PortToFriend.controls.favorites[i].house:SetColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B)
			PortToFriend.controls.favorites[i].house:SetMouseEnabled(true)
			PortToFriend.controls.favorites[i].house:SetHandler("OnMouseEnter", function() PortToFriend.BdOnMouseEnter(i) end)
			PortToFriend.controls.favorites[i].house:SetHandler("OnMouseExit", function() PortToFriend.BdOnMouseExit(i) end)
			
			PortToFriend.CreateFavoriteCombobox(i, 60, 25, 480, 0, PortToFriend.controls.favorites[i].backDrop, favorites[i].id)
			
			if PortToFriend.controls.favorites[i].VCButton == nil then
				PortToFriend.controls.favorites[i].VCButton = wm:CreateControlFromVirtual(nil, PortToFriend.controls.favorites[i].backDrop, "ZO_DefaultButton")
			end
			PortToFriend.controls.favorites[i].VCButton:SetHidden(false)
			PortToFriend.controls.favorites[i].VCButton:ClearAnchors()
			PortToFriend.controls.favorites[i].VCButton:SetAnchor(TOPLEFT, PortToFriend.controls.favorites[i].backDrop, TOPLEFT, 540, 0)
			PortToFriend.controls.favorites[i].VCButton:SetDimensions(50,25)
			PortToFriend.controls.favorites[i].VCButton:SetText(PortToFriend.constants.BUTTON_VC)
			PortToFriend.controls.favorites[i].VCButton:SetClickSound("Click")
			PortToFriend.controls.favorites[i].VCButton:SetHandler("OnClicked", function () PortToFriend.FavoriteToVC(i) end)
			PortToFriend.controls.favorites[i].VCButton:SetHandler("OnMouseEnter", function() PortToFriend.BdOnMouseEnter(i) end)
            PortToFriend.controls.favorites[i].VCButton:SetHandler("OnMouseExit", function() PortToFriend.BdOnMouseExit(i) end)
			
			
			if PortToFriend.controls.favorites[i].portButton == nil then
				PortToFriend.controls.favorites[i].portButton = wm:CreateControlFromVirtual(nil, PortToFriend.controls.favorites[i].backDrop, "ZO_DefaultButton")
			end
			PortToFriend.controls.favorites[i].portButton:SetHidden(false)
			PortToFriend.controls.favorites[i].portButton:ClearAnchors()
			PortToFriend.controls.favorites[i].portButton:SetAnchor(TOPLEFT, PortToFriend.controls.favorites[i].backDrop, TOPLEFT, 580, 0)
			PortToFriend.controls.favorites[i].portButton:SetDimensions(90,25)
			PortToFriend.controls.favorites[i].portButton:SetText(PortToFriend.constants.BUTTON_PORT)
			PortToFriend.controls.favorites[i].portButton:SetClickSound("Click")
			PortToFriend.controls.favorites[i].portButton:SetHandler("OnClicked", function () PortToFriend.PortToFavorite(i) end)
			PortToFriend.controls.favorites[i].portButton:SetHandler("OnMouseEnter", function() PortToFriend.BdOnMouseEnter(i) end)
            PortToFriend.controls.favorites[i].portButton:SetHandler("OnMouseExit", function() PortToFriend.BdOnMouseExit(i) end)
			
			if PortToFriend.controls.favorites[i].removeButton == nil then
				PortToFriend.controls.favorites[i].removeButton = wm:CreateControlFromVirtual(nil, PortToFriend.controls.favorites[i].backDrop, "ZO_DefaultButton")
			end
			PortToFriend.controls.favorites[i].removeButton:SetHidden(false)
			PortToFriend.controls.favorites[i].removeButton:ClearAnchors()
			PortToFriend.controls.favorites[i].removeButton:SetAnchor(TOPLEFT, PortToFriend.controls.favorites[i].backDrop, TOPLEFT, 670, 0)
			PortToFriend.controls.favorites[i].removeButton:SetDimensions(90,25)
			PortToFriend.controls.favorites[i].removeButton:SetText(PortToFriend.constants.BUTTON_REMOVE)
			PortToFriend.controls.favorites[i].removeButton:SetClickSound("Click")
			PortToFriend.controls.favorites[i].removeButton:SetHandler("OnClicked", function () PortToFriend.RemoveFavorite(i) end)
			PortToFriend.controls.favorites[i].removeButton:SetHandler("OnMouseEnter", function() PortToFriend.BdOnMouseEnter(i) end)
            PortToFriend.controls.favorites[i].removeButton:SetHandler("OnMouseExit", function() PortToFriend.BdOnMouseExit(i) end)
		end
		PortToFriend.controls.house.scrollPanel:SetDimensions(PortToFriend.config.size.width - 10, #favorites * 25 + 15)
		PortToFriend.ClearFavoriteControls(#favorites + 1)
	else
		PortToFriend.ClearFavoriteControls(1)
	end
	PortToFriend.AdjustSliderSize()
end

function PortToFriend.PortToFavoriteBinding(favId)
	local favorites = PortToFriend.savedVars.favorites
	if favorites ~= nil and favId > 0 and favId <= 10 then
		for i = 1, #favorites do
			if favorites[i].id ~= nil and favorites[i].id == favId then
				PortToFriend.JumpToHouse(favorites[i].name, favorites[i].houseId)
				return true
			end
		end
	end
	d(PortToFriend.constants.INVALID_FAVORITE_ID)
	return false
end

function PortToFriend.PortToMyHouseBinding(id, portType)
	local favorites = PortToFriend.savedVars.myHousesFavorites[portType]
	if favorites ~= nil and id > 0 and id <= 10 then
		local portOutside = false
		if portType == PortToFriend.constants.PORT_TYPE_OUTSIDE then
			portOutside = true
		end
		if favorites[id] ~= nil then
			PortToFriend.PortToMyHousesById(favorites[id], portOutside)
		end
		return true
	end
	d(PortToFriend.constants.INVALID_FAVORITE_ID)
	return false
end

function PortToFriend.JumpToHouse(name, id)
	if name ~= nil and name ~= "" and id ~= nil and id > 0 then
		if name == GetDisplayName() or name == nil or zo_strtrim(name) == "" then
			RequestJumpToHouse(id)
		else
			JumpToSpecificHouse(name, id)
		end
	end
end

--version 1.2 @account fix
--including 1.6.1 fix
function PortToFriend.Version12NameFix(id)
	if string.lower(PortToFriend.savedVars.favorites[id].name) == string.lower(GetUnitName("player")) or string.lower(PortToFriend.savedVars.favorites[id].name) == string.lower(GetDisplayName()) then
		PortToFriend.savedVars.favorites[id].name = GetDisplayName()
	end
end

function PortToFriend.PortToLibraryEntry(id)
	local entries = PortToFriend.GetFilteredLibraryData()
	if id ~= nil and id > 0 then
		PortToFriend.JumpToHouse(entries[id].name, entries[id].houseId)
		if PortToFriend.savedVars.port_mode == PortToFriend.constants.PORT_MODE_ON_CLICK then
			PortToFriend.CloseWindow()
		end
	end
end

function PortToFriend.PortToFavorite(id)
	if id ~= nil and id > 0 then
		PortToFriend.JumpToHouse(PortToFriend.savedVars.favorites[id].name, PortToFriend.savedVars.favorites[id].houseId)
		if PortToFriend.savedVars.port_mode == PortToFriend.constants.PORT_MODE_ON_CLICK then
			PortToFriend.CloseWindow()
		end
	end
end

function PortToFriend.PortToMyHousesById(id, outside)
	RequestJumpToHouse(id, outside)
	if PortToFriend.savedVars.port_mode == PortToFriend.constants.PORT_MODE_ON_CLICK then
		PortToFriend.CloseWindow()
	end
end

function PortToFriend.RemoveFavorite(id)
	if id ~= nil and id > 0 then
		local favorites = PortToFriend.savedVars.favorites
		table.remove(favorites,id)
		PortToFriend.CreateFavorites()
		PortToFriend.BdOnMouseEnter(id)
	end
	
end

function PortToFriend.EntryExists(name, houseId)
	if PortToFriend.savedVars.favorites ~= nil then
		for i = 1, #PortToFriend.savedVars.favorites do
			local favorite = PortToFriend.savedVars.favorites[i]
			if favorite.name == name and favorite.houseId == houseId then
				return true
			end
		end
	end
	return false
end

function PortToFriend.AddFavorite(name, houseId)
	if houseId > 0 and name ~= nil then
		name = zo_strtrim(name)
		if string.lower(name) == string.lower(GetUnitName("player")) or string.lower(name) == string.lower(GetDisplayName()) or name == nil or name == "" then
			name = GetDisplayName()
		end
		if PortToFriend.EntryExists(name, houseId) == false then
			local favorites = PortToFriend.savedVars.favorites
			favorites[#favorites + 1] = {}
			favorites[#favorites].name = name
			favorites[#favorites].houseId = houseId
			PortToFriend.CreateFavorites()
		end
	end
end

function PortToFriend.AddToFavorite()
	local name = PortToFriend.controls.house.editbox:GetText()
	local houseId = PortToFriend.addonState.houseId
	PortToFriend.AddFavorite(name, houseId)
end

function PortToFriend.OpenWindowKeyBinding()
	PortToFriend.controls.TLW:SetHidden(not PortToFriend.controls.TLW:IsHidden())
	SetGameCameraUIMode(not PortToFriend.controls.TLW:IsHidden())
	if PortToFriend.controls.TLW:IsHidden() == false then
		PortToFriend.CreateGuildAndFriendList()
	end
	if PortToFriend.controls.TLW:IsHidden() == true then
		local callback = PortToFriend.addonState.windowCallback
		if callback ~= nil and type(callback) == "function" then
			PortToFriend.addonState.windowCallback = nil
			callback()
		end
	end
end

function PortToFriend.PortToFriend()
	if PortToFriend.addonState.houseId > 0 then
		local name = PortToFriend.controls.house.editbox:GetText()
		if string.lower(name) == string.lower(GetUnitName("player")) or string.lower(name) == string.lower(GetDisplayName()) or name == nil or zo_strtrim(name) == "" then
			name = GetDisplayName()
		end
		PortToFriend.JumpToHouse(name, PortToFriend.addonState.houseId)
	end
end

function PortToFriend.GetIdFromName(name)
	local id = 0
	for key, value in pairs(PortToFriend.HOUSES) do
	--for i = 1, #PortToFriend.HOUSES do
		if name == PortToFriend.HOUSES[key] then
			id = key
			break
		end
	end
	return id
end

function PortToFriend.DropdownCallback(control, text, choice)
	PortToFriend.addonState.houseId = PortToFriend.GetIdFromName(text)
	if PortToFriend.config.houseDebug == true then
		d(PortToFriend.addonState.houseId)
	end
end

function PortToFriend.CategoryDropdownCallback(control, text, choice)
	--d(choice.filterId)
	PortToFriend.addonState.selectedLibraryFilter = choice.filterId
	PortToFriend.savedVars.selectedLibraryFilter = choice.filterId
	if PortToFriend.addonState.categoryFilterInitialized == true then
		PortToFriend.UpdateLibraryEntries()
	end
end

function PortToFriend.LibrarySortDropdownCallback(control, text, choice)
	PortToFriend.addonState.selectedLibrarySort = choice.filterId
	PortToFriend.savedVars.selectedLibrarySort = choice.filterId
	--d(choice.filterId)
	if PortToFriend.addonState.LibrarySortInitialized == true then
		PortToFriend.UpdateLibraryEntries()
	end
end

function PortToFriend.UpdateLibraryEntries()
	PortToFriend.controls.library.slider:SetValue(0)
		local entries = PortToFriend.GetFilteredLibraryData()
		if entries ~= nil then
			for i = 1, #PortToFriend.controls.libraryEntries do
				PortToFriend.ClearLibraryControls(i)
			end
			
			PortToFriend.CreateLibraryEntries()
		end
end

function PortToFriend.CloneTable(origTable)
	local newTable = {}
	for key, value in pairs(origTable) do
	--for i = 1, #origTable do
		newTable[key] = value
	end
	return newTable	
end

function PortToFriend.SortHouseList(names)
	return PortToFriend.SortPairs(names)
	--return PortToFriend.SortSearchNames(names)
end

function PortToFriend.CreateSortedHouseList()
	local retVal = PortToFriend.CloneTable(PortToFriend.HOUSES)
	return PortToFriend.SortHouseList(retVal)
end

function PortToFriend.CreateCategoryFilterList()
	local retVal = {}
	retVal[PortToFriend.constants.FILTER_ID_NONE] = PortToFriend.constants.FILTER_NONE
	retVal[PortToFriend.constants.FILTER_ID_HIGHLIGHT] = PortToFriend.constants.FILTER_HIGHLIGHT
	retVal[PortToFriend.constants.FILTER_ID_LABYRINTH] = PortToFriend.constants.FILTER_LABYRINTH
	retVal[PortToFriend.constants.FILTER_ID_JUMPNRUN] = PortToFriend.constants.FILTER_JUMPNRUN
	retVal[PortToFriend.constants.FILTER_ID_CRAFTING] = PortToFriend.constants.FILTER_CRAFTING
	retVal[PortToFriend.constants.FILTER_ID_GUILD] = PortToFriend.constants.FILTER_GUILD
	retVal[PortToFriend.constants.FILTER_ID_ROLEPLAY] = PortToFriend.constants.FILTER_ROLEPLAY
	retVal[PortToFriend.constants.FILTER_ID_RAID] = PortToFriend.constants.FILTER_RAID
	retVal[PortToFriend.constants.FILTER_ID_HIDE_SEEK] = PortToFriend.constants.FILTER_HIDE_SEEK
	retVal[PortToFriend.constants.FILTER_ID_ERP] = PortToFriend.constants.FILTER_ERP
	return retVal
end

function PortToFriend.CreateLibrarySortFilterList()
	local retVal = {}
	retVal[PortToFriend.constants.LIBRARY_SORT_ID_NONE] = PortToFriend.constants.LIBRARY_SORT_NONE
	retVal[PortToFriend.constants.LIBRARY_SORT_ID_NAME] = PortToFriend.constants.LIBRARY_SORT_NAME
	retVal[PortToFriend.constants.LIBRARY_SORT_ID_HOUSE] = PortToFriend.constants.LIBRARY_SORT_HOUSE
	return retVal
end

function PortToFriend.CreateDropdownEntries(dropdown)
	dropdown:SetSortsItems(false)
	dropdown:ClearItems()
	local sortedHouses = PortToFriend.CreateSortedHouseList()
	for key, value in pairs(sortedHouses) do
	--for i = 1, #sortedHouses do
		if sortedHouses[key] ~= nil then
			local entry = dropdown:CreateItemEntry(sortedHouses[key], PortToFriend.DropdownCallback)
			dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
		end
    end
end

function PortToFriend.CreateCategoryDropdownEntries(dropdown)
	dropdown:SetSortsItems(false)
	dropdown:ClearItems()
	
	local entries = PortToFriend.CreateCategoryFilterList()
	
	for i = 1, #entries do
		local entry = dropdown:CreateItemEntry(entries[i], PortToFriend.CategoryDropdownCallback)
		entry.filterId = i
		dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
    end
end

function PortToFriend.CreateLibrarySortDropdownEntries(dropdown)
	dropdown:SetSortsItems(false)
	dropdown:ClearItems()
	
	local entries = PortToFriend.CreateLibrarySortFilterList()
	
	for i = 1, #entries do
		local entry = dropdown:CreateItemEntry(entries[i], PortToFriend.LibrarySortDropdownCallback)
		entry.filterId = i
		dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
    end
end

function PortToFriend.SortDropdownCallback(control, text, choice)
	PortToFriend.addonState.selectedMyHousesSort = choice.sortId
	PortToFriend.savedVars.selectedMyHousesSort = choice.sortId
	if PortToFriend.addonState.sortInitialized == true then
		PortToFriend.controls.myHouses.slider:SetValue(1)
		PortToFriend.UpdateMyHouses()
	end
end

function PortToFriend.CreateSortDropdownEntries(dropdown)
	dropdown:SetSortsItems(false)
	dropdown:ClearItems()
	
	local entries = {}
	entries[PortToFriend.constants.SORT_ID_HOUSE] = PortToFriend.constants.SORT_HOUSE
	entries[PortToFriend.constants.SORT_ID_LOCATION] = PortToFriend.constants.SORT_LOCATION
	
	for i = 1, #entries do
		local entry = dropdown:CreateItemEntry(entries[i], PortToFriend.SortDropdownCallback)
		entry.sortId = i
		dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
    end
end

function PortToFriend.CreateEditbox(container)
	local bd = wm:CreateControlFromVirtual(nil, container, "ZO_EditBackdrop")
	local editbox = wm:CreateControlFromVirtual(nil, bd, "ZO_DefaultEditForBackdrop")
	return bd, editbox
end

function PortToFriend.CreateSearchBox(container, offsetX, offsetY, width)
	local control = wm:CreateControl(nil, container, CT_CONTROL)
	control:SetAnchor(TOPLEFT, PortToFriend.controls.house.control, TOPLEFT, offsetX, offsetY)
	control:SetDimensions(width, 0)
	control:SetHidden(true)
	control:SetDrawLayer(1)
	control:SetMouseEnabled(true)
	control:SetHandler("OnMouseWheel", PortToFriend.SearchBoxOnMouseWheel);
	
	
	control.backdrop = CreateControlFromVirtual(PortToFriend.constants.controls.SEARCH_BODY_BACKDROP, control, "ZO_SliderBackdrop")
	control.backdrop:SetCenterColor(PortToFriend.config.color.searchBackdrop.R, PortToFriend.config.color.searchBackdrop.G, PortToFriend.config.color.searchBackdrop.B, PortToFriend.config.color.searchBackdrop.A)
	control.backdrop:SetEdgeColor(PortToFriend.config.color.searchBackdropEdge.R, PortToFriend.config.color.searchBackdropEdge.G, PortToFriend.config.color.searchBackdropEdge.B, PortToFriend.config.color.searchBackdropEdge.A)
	control.backdrop:SetDrawLayer(1)
	
	control.scrollControl = wm:CreateControl(nil, control, CT_SCROLL);
	control.scrollControl:SetDimensions(width - 18, 0)
	control.scrollControl:SetAnchor(TOPLEFT, control, TOPLEFT, 2, 4)
	control.scrollControl:SetScrollBounding(SCROLL_BOUNDING_CONTAINED)
	control.scrollControl:SetDrawLayer(2)
	
	
	control.bodyControl = wm:CreateControl(nil, control.scrollControl, CT_CONTROL)
	control.bodyControl:SetDimensions(width - 18, 0)
	control.bodyControl:SetAnchor(TOPLEFT, control.scrollControl, TOPLEFT, 0, 0)
	control.bodyControl:SetDrawLayer(2)
	control.bodyControl:SetHandler("OnMouseWheel", PortToFriend.SearchBoxOnMouseWheel);
	
	control.slider = wm:CreateControl(nil, control, CT_SLIDER)
	control.slider:SetDrawLayer(4)
	control.slider:SetDrawLevel(1)
	control.slider:SetDimensions(18, 100)
	control.slider:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
	control.slider:SetOrientation(ORIENTATION_VERTICAL)
	control.slider:SetMouseEnabled(true)
	control.slider:SetMinMax(0, 100)
	control.slider:SetThumbTexture("esoui/art/buttons/smoothsliderbutton_up.dds", nil, nil, 18, 50)
	control.slider:SetValueStep(1)
	control.slider:SetHandler("OnValueChanged", PortToFriend.AdjustSearchSlider)
		
	return control
end

function PortToFriend.SearchBoxOnMouseWheel(control, delta)
	if PortToFriend.controls.house.searchBox.slider:IsHidden() == false then
		local size = 100 / #PortToFriend.addonState.searchResult
		if size < 1 then
			size = 1
		end
		local position = -delta * size + PortToFriend.controls.house.searchBox.slider:GetValue()
		
		if position < 0 then
			position = 0
		end
		if position > 100 then
			position = 100
		end
		PortToFriend.controls.house.searchBox.slider:SetValue(position)
	end
end

function PortToFriend.AdjustSearchSlider()
	if PortToFriend.addonState.searchResult ~= nil then
		local size = PortToFriend.config.search.height * #PortToFriend.addonState.searchResult - PortToFriend.config.search.height * PortToFriend.config.search.max
		if size < 0 then
			size = 0
		end
		
		local slide = size / 100 * PortToFriend.controls.house.searchBox.slider:GetValue()
		
		PortToFriend.controls.house.searchBox.bodyControl:SetSimpleAnchor(PortToFriend.controls.house.searchBox.scrollControl, 0, -slide)
	else
	
	end
end

function PortToFriend.SaveWindowLocation()
	PortToFriend.savedVars.position = {}
	PortToFriend.savedVars.position.x = PortToFriend.controls.TLW:GetLeft()
	PortToFriend.savedVars.position.y = PortToFriend.controls.TLW:GetTop()
	if PortToFriend.controls.vc ~= nil and PortToFriend.controls.vc.TLW ~= nil then
		PortToFriend.savedVars.position.vc = {}
		PortToFriend.savedVars.position.vc.x = PortToFriend.controls.vc.TLW:GetLeft()
		PortToFriend.savedVars.position.vc.y = PortToFriend.controls.vc.TLW:GetTop()
	end
end

function PortToFriend.OpenWindow(callback)
	PortToFriend.controls.TLW:SetHidden(false)
	SetGameCameraUIMode(not PortToFriend.controls.TLW:IsHidden())
	PortToFriend.CreateGuildAndFriendList()
	if callback ~= nil and type(callback) == "function" then
		PortToFriend.addonState.windowCallback = callback
	end
end

function PortToFriend.CloseWindow()
	PortToFriend.controls.TLW:SetHidden(true)
	SetGameCameraUIMode(not PortToFriend.controls.TLW:IsHidden())
	--ClearCursor()
	local callback = PortToFriend.addonState.windowCallback
	if callback ~= nil and type(callback) == "function" then
		PortToFriend.addonState.windowCallback = nil
		callback()
	end
end

function PortToFriend.ShowHelp()
	d(PortToFriend.slashCmd .. PortToFriend.constants.CMD_HELP_1)
	d(PortToFriend.slashCmd .. PortToFriend.constants.CMD_HELP_2)
	d(PortToFriend.slashCmd .. PortToFriend.constants.CMD_HELP_3)
	d(PortToFriend.slashCmd .. PortToFriend.constants.CMD_HELP_4)
	d(PortToFriend.slashCmd .. PortToFriend.constants.CMD_HELP_5)
	d(PortToFriend.slashCmd .. PortToFriend.constants.CMD_HELP_6)
	d(PortToFriend.slashCmd .. PortToFriend.constants.CMD_HELP_7)
end

function PortToFriend.ClearNameList()
	PortToFriend.addonState.names = {}
end

function PortToFriend.StringStartsWith(theString, startsWith)
   return string.sub(theString,1,string.len(startsWith))==startsWith
end

function PortToFriend.SearchEntryOnClicked(id)
	if id ~= nil and id > 0 and id < #PortToFriend.controls.searchResults ~= nil and PortToFriend.controls.searchResults[id] ~= nil then
		PortToFriend.addonState.searchResultClicked = true
		PortToFriend.controls.house.editbox:SetText(PortToFriend.controls.searchResults[id].searchResult)
	end
end

function PortToFriend.SearchEntryOnMouseEnter(id)
	if id ~= nil and id > 0 and id <= #PortToFriend.controls.searchResultsBackdrop and PortToFriend.controls.searchResultsBackdrop[id] ~= nil then
		PortToFriend.controls.searchResultsBackdrop[id]:SetCenterColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, PortToFriend.config.color.backDropLine.A)
	end
end

function PortToFriend.SearchEntryOnMouseExit(id)
	if id ~= nil and id > 0 and id <= #PortToFriend.controls.searchResultsBackdrop and PortToFriend.controls.searchResultsBackdrop[id] ~= nil then
		PortToFriend.controls.searchResultsBackdrop[id]:SetCenterColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
	end
end


function PortToFriend.SetSearchResults(names)
	if names == nil or #names == 0 then
		PortToFriend.controls.house.searchBox:SetHidden(true)
	else
		if PortToFriend.addonState.searchResultClicked == true then
			PortToFriend.controls.house.searchBox:SetHidden(true)
			PortToFriend.addonState.searchResultClicked = false
		else
			PortToFriend.controls.house.searchBox:SetHidden(false)
			local height = 10
			for i = 1, #names do
				height = height + PortToFriend.config.search.height

			end
			local dimensionWidth = PortToFriend.config.search.width - 22
			if height > PortToFriend.config.search.max * PortToFriend.config.search.height + 10 then
				height = PortToFriend.config.search.max * PortToFriend.config.search.height + 10
				PortToFriend.controls.house.searchBox.slider:SetHidden(false)
			else
				PortToFriend.controls.house.searchBox.slider:SetHidden(true)
				dimensionWidth = PortToFriend.config.search.width - 4
			end
			for i = 1, #names do
				if PortToFriend.controls.searchResultsBackdrop[i] == nil then
					PortToFriend.controls.searchResultsBackdrop[i] = wm:CreateControl(nil, PortToFriend.controls.house.searchBox.bodyControl, CT_BACKDROP)
				end
				PortToFriend.controls.searchResultsBackdrop[i]:SetHidden(false)
				PortToFriend.controls.searchResultsBackdrop[i]:SetDimensions(dimensionWidth, PortToFriend.config.search.height)
				PortToFriend.controls.searchResultsBackdrop[i]:ClearAnchors()
				PortToFriend.controls.searchResultsBackdrop[i]:SetAnchor(TOPLEFT, PortToFriend.controls.house.searchBox.bodyControl, TOPLEFT, 0, PortToFriend.config.search.height * (i - 1))
				PortToFriend.controls.searchResultsBackdrop[i]:SetCenterColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0)
				PortToFriend.controls.searchResultsBackdrop[i]:SetEdgeColor(PortToFriend.config.color.backDropLine.R, PortToFriend.config.color.backDropLine.G, PortToFriend.config.color.backDropLine.B, 0.0, 0)
				PortToFriend.controls.searchResultsBackdrop[i]:SetDrawLayer(3)
				if PortToFriend.controls.searchResults[i] == nil then
					PortToFriend.controls.searchResults[i] = wm:CreateControl(nil, PortToFriend.controls.house.searchBox.bodyControl, CT_BUTTON)
				end
				PortToFriend.controls.searchResults[i]:SetHidden(false)
				PortToFriend.controls.searchResults[i]:SetMouseEnabled(true)
				PortToFriend.controls.searchResults[i]:SetDimensions(dimensionWidth, PortToFriend.config.search.height)
				PortToFriend.controls.searchResults[i]:ClearAnchors()
				PortToFriend.controls.searchResults[i]:SetAnchor(TOPLEFT, PortToFriend.controls.house.searchBox.bodyControl, TOPLEFT, 0, PortToFriend.config.search.height * (i - 1))
				PortToFriend.controls.searchResults[i]:SetHandler("OnClicked", function() PortToFriend.SearchEntryOnClicked(i) end)
				PortToFriend.controls.searchResults[i]:SetHandler("OnMouseEnter", function() PortToFriend.SearchEntryOnMouseEnter(i) end)
				PortToFriend.controls.searchResults[i]:SetHandler("OnMouseExit", function() PortToFriend.SearchEntryOnMouseExit(i) end)
				PortToFriend.controls.searchResults[i]:SetText(names[i])
				PortToFriend.controls.searchResults[i].searchResult = names[i]
				PortToFriend.controls.searchResults[i]:SetFont(PortToFriend.config.fonts.header)
				PortToFriend.controls.searchResults[i]:SetNormalFontColor(PortToFriend.config.color.default.R, PortToFriend.config.color.default.G, PortToFriend.config.color.default.B, 1.0)
				PortToFriend.controls.searchResults[i]:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
				PortToFriend.controls.searchResults[i]:SetDrawLayer(3)
			end
			if #PortToFriend.controls.searchResults > #names then
				for i = #names + 1, #PortToFriend.controls.searchResults do
					PortToFriend.controls.searchResultsBackdrop[i]:SetHidden(true)
					PortToFriend.controls.searchResultsBackdrop[i]:SetAnchor(TOPLEFT, PortToFriend.controls.house.searchBox.bodyControl, TOPLEFT, 0, 0)
					PortToFriend.controls.searchResultsBackdrop[i]:SetDimensions(0, 0)
				
					PortToFriend.controls.searchResults[i]:SetHidden(true)
					PortToFriend.controls.searchResults[i]:SetAnchor(TOPLEFT, PortToFriend.controls.house.searchBox.bodyControl, TOPLEFT, 0, 0)
					PortToFriend.controls.searchResults[i]:SetDimensions(0, 0)
					PortToFriend.controls.searchResults[i]:SetText("")
				end
			end

			PortToFriend.controls.house.searchBox:SetDimensions(PortToFriend.config.search.width, height)
			PortToFriend.controls.house.searchBox.scrollControl:SetDimensions(dimensionWidth, height - 8)
			PortToFriend.controls.house.searchBox.bodyControl:SetDimensions(dimensionWidth, height - 8)
			PortToFriend.controls.house.searchBox.slider:SetDimensions(25, height)
			PortToFriend.controls.house.searchBox.slider:SetValue(0)
			PortToFriend.controls.house.searchBox.backdrop:SetDimensions(dimensionWidth, height)
		end
	end
end

function PortToFriend.SearchTextChanged()
	local searchTerm = PortToFriend.controls.house.editbox:GetText()
	local names = nil
	if searchTerm ~= nil and string.len(searchTerm) >= PortToFriend.config.search.minChars then
		names = PortToFriend.SearchNames(searchTerm)
	end
	PortToFriend.addonState.searchResult = names
	PortToFriend.SetSearchResults(names)
end

function PortToFriend.SortPairs(names)
	if names ~= nil then
		local indexes = {}
		local values = {}
		local index = 1
		for key, value in pairs(names) do
			indexes[index] = key
			values[index] = value
			index = index + 1
		end
		
		local itemCount = #indexes
		repeat
			local hasChanged = false
			itemCount = itemCount - 1
			for i = 1, itemCount do
				if (values[i] ~= nil and values[i + 1] ~= nil and values[i] > values[i + 1]) or (values[i] == nil) then					
					values[i], values[i + 1] = values[i + 1], values[i]
					hasChanged = true
				
				end
			end
		until hasChanged == false
		return values
	end
	return names
end

function PortToFriend.SortSearchNames(names)
	if names ~= nil then
		local itemCount = #names
		repeat
			local hasChanged = false
			itemCount = itemCount - 1
			for i = 1, itemCount do
				if (names[i] ~= nil and names[i + 1] ~= nil and names[i] > names[i + 1]) or (names[i] == nil) then					
					names[i], names[i + 1] = names[i + 1], names[i]
					hasChanged = true
				
				end
			end
		until hasChanged == false
		return names
	end
end

function PortToFriend.SearchNames(name)
	local retNames = {}
	if PortToFriend.addonState.names ~= nil and name ~= nil then
		for i = 1, #PortToFriend.addonState.names do
			if PortToFriend.StringStartsWith(string.lower(PortToFriend.addonState.names[i]), string.lower(name)) then
				table.insert(retNames, PortToFriend.addonState.names[i])
			end
		end
	end
	return PortToFriend.SortSearchNames(retNames)
end

function PortToFriend.AddNameToNameList(name)
	if PortToFriend.addonState.names ~= nil and name ~= nil then
		local entryIdentified = false
		for i = 1, #PortToFriend.addonState.names do
			if PortToFriend.addonState.names[i] == name then
				entryIdentified = true
				break
			end
		end
		if entryIdentified == false then
			table.insert(PortToFriend.addonState.names, name)
		end
	end
end

function PortToFriend.CreateGuildAndFriendList()
	PortToFriend.ClearNameList()
	for guildId = 1, GetNumGuilds() do
		guildId = GetGuildId(guildId)
        for memberId = 1, GetNumGuildMembers(guildId) do
            local hasCharacter, charName, zoneName, classType, alliance, level, championRank, zoneId = GetGuildMemberCharacterInfo(guildId, memberId)
            local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, memberId)
			local charIndex = string.find(charName, "^", nil, true)
			if charIndex  ~= nil then
				charName = string.sub(charName, 1, charIndex - 1)
			end
			PortToFriend.AddNameToNameList(charName)
			PortToFriend.AddNameToNameList(name)
		end
	end
	for friendIndex = 1, GetNumFriends() do
        local mi = { }
        local displayName, note, playerStatus, secsSinceLogoff = GetFriendInfo(friendIndex)
		local hasCharacter, characterName, zoneName, classType, alliance, level, championRank, zoneId = GetFriendCharacterInfo(friendIndex)
		local charIndex = string.find(characterName, "^", nil, true)
		if charIndex  ~= nil then
			characterName = string.sub(characterName, 1, charIndex - 1)
		end
		PortToFriend.AddNameToNameList(characterName)
		PortToFriend.AddNameToNameList(name)
    end
end

function PortToFriend.ParseCmd(cmd, param)
	param = zo_strtrim(param)
	cmd = zo_strtrim(cmd)
	
	local cmdIndex = string.find(param, " ")
	if cmdIndex  ~= nil then
		cmd = zo_strtrim(string.sub(param, 1, cmdIndex))
		param = zo_strtrim(string.sub(param, cmdIndex + 1))
	else
		cmd = param
		param = ""
	end
	return cmd, param
end

function PortToFriend.PortToMainResidence()
	local name = PortToFriend.controls.house.editbox:GetText()
	if string.lower(name) == string.lower(GetUnitName("player")) or string.lower(name) == string.lower(GetDisplayName()) or name == nil or zo_strtrim(name) == "" then
		name = GetDisplayName()
	end
	PortToFriend.JumpToDefaultHouse(name)
end

function PortToFriend.JumpToDefaultHouse(player)
	--d(player)
	if player ~= nil and player ~= "" then
		if player == GetDisplayName() or player == nil or zo_strtrim(player) == "" then
			--Is there a way to part to your own primary house?
		else
			JumpToHouse(player)
		end
	end
end

SLASH_COMMANDS[PortToFriend.slashCmd] = function(param)
	d(string.format("%s %s", PortToFriend.slashCmd, param))
	param = zo_strtrim(param)
	local cmd = ""
	cmd, param = PortToFriend.ParseCmd(cmd, param)
	if cmd == "port" then
		local lastWordIndex = param:match(".* ()")
		if lastWordIndex ~= nil then
			local index = tonumber(string.sub(param, lastWordIndex))
			if index ~= nil then
				cmd = zo_strtrim(string.sub(param, 0, lastWordIndex - 1))
				if cmd == GetUnitName("player") then
					cmd = GetDisplayName()
				end
				PortToFriend.JumpToHouse(cmd, index)
			else
				PortToFriend.JumpToDefaultHouse(param)
			end
		else
			PortToFriend.JumpToDefaultHouse(param)
		end
	elseif cmd == "show" then
		for key, house in pairs(PortToFriend.HOUSES) do
			if house ~= nil then
				d(string.format("%d: %s", key, house))
			end
		end
	elseif cmd == "open" then
		PortToFriend.OpenWindow()
	elseif cmd == "fav" then
		param = tonumber(param)
		if param ~= nil and param > 0 then
			PortToFriend.PortToFavoriteBinding(param)
		else
			d(PortToFriend.constants.INVALID_FAVORITE_ID)
		end
	elseif cmd == "favi" then
		param = tonumber(param)
		if param ~= nil and param > 0 then
			PortToFriend.PortToMyHouseBinding(param, PortToFriend.constants.PORT_TYPE_INSIDE)
		else
			d(PortToFriend.constants.INVALID_FAVORITE_ID)
		end
	elseif cmd == "favo" then
		param = tonumber(param)
		if param ~= nil and param > 0 then
			PortToFriend.PortToMyHouseBinding(param, PortToFriend.constants.PORT_TYPE_OUTSIDE)
		else
			d(PortToFriend.constants.INVALID_FAVORITE_ID)
		end
	elseif cmd == "menu" then
		if LibAddonMenu2 ~= nil then
			LibAddonMenu2:OpenToPanel(PortToFriend.menu.lam.panel)
		end
	else
		PortToFriend.ShowHelp()
	end
end

--GetHouseZoneId() -> GetZoneNameById()