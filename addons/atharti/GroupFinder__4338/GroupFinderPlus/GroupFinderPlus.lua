GroupFinderPlus = {}

local GF = GroupFinderPlus
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER

GF.name = "GroupFinderPlus"

-- =========================================================

local defaultSV = {
    windowOffsetX      = 20,
    windowOffsetY      = 20,
    isHidden           = false,
    windowAnchor       = "LEFT",
    AllowAllRoles      = true,
    HideInsufficientCP = false,
    HideWTSListings    = true,
	ShowInstanceTooltip = true,
	PrimaryOptionIndex = 2,
	ShowPrimaryOptionButton = true,
	SaveLastCategory = false,
	LastCategory = GROUP_FINDER_CATEGORY_TRIAL,
	FullAchievements = true,
	LastBossRainbow = false,
	HideInInstance = false,
    TrialsEnabled      = {
        AA  = true,
        AS  = true,
        CR  = true,
        HoF = true,
        HRC = true,
        SO  = true,
        MoL = true,
        SS  = true,
        KA  = true,
        RG  = true,
        DSR = true,
        SE  = true,
        LC  = true,
        OC  = true,
    },
	
	 CategoriesEnabled = {
        [GROUP_FINDER_CATEGORY_TRIAL]          = true,
        [GROUP_FINDER_CATEGORY_DUNGEON]        = true,
        [GROUP_FINDER_CATEGORY_ARENA]          = true,
        [GROUP_FINDER_CATEGORY_ENDLESS_DUNGEON]= true,
        [GROUP_FINDER_CATEGORY_ZONE]           = true,
		[GROUP_FINDER_CATEGORY_ADVENTURE_ZONE] = true,
        [GROUP_FINDER_CATEGORY_CUSTOM]         = true,
    },
	BlacklistedLeaders = {},
}

-- =========================================================

ZO_CreateStringId("SI_BINDING_NAME_GROUPFINDERPLUS_TOGGLE_WINDOW", "Toggle GroupFinder+")
ZO_CreateStringId("SI_BINDING_NAME_GROUPFINDERPLUS_CYCLE_CATEGORY", "Next GroupFinder Category")
ZO_CreateStringId("SI_BINDING_NAME_GROUPFINDERPLUS_SWITCH_MODE", "Switch Difficulty Normal-Veteran")
ZO_CreateStringId("SI_BINDING_NAME_GROUPFINDERPLUS_RECREATE_LISTING", "Recreate Last Listing")

-- =========================================================

local ICON_NORMAL  = "esoui/art/tutorial/gamepad/gp_lfg_normaldungeon.dds"
local ICON_VETERAN = "esoui/art/tutorial/gamepad/gp_lfg_veteranldungeon.dds"

GF.ROW_HEIGHT = 26
GF.BASE_WIDTH = 360
GF.PADDING = 4
GF.TOP_BUTTON_SIZE = 25
GF.TOP_BUTTON_PADDING = 6
GF.TOP_CONTENT_OFFSET = GF.TOP_BUTTON_SIZE + GF.TOP_BUTTON_PADDING * 2

GF.firstSearchAfterCategoryChange = false
GF.lastSearchCategory = nil
GF.playerLevel = nil
GF.eventZone = false
GF.championPoints = 0

GF.hiddenListings = {}
GF.rows = {}
GF.listings = {}
GF.tempListings = {}
GF.filteredListings = {}
GF.tooltipLines = {}
GF.achievementLinks = {}
GF.seenLinks = {}
GF.extractedLinks = {}

GF.ROLE_ICONS = {
    [LFG_ROLE_TANK] = "esoui/art/lfg/lfg_icon_tank.dds",
    [LFG_ROLE_HEAL] = "esoui/art/lfg/lfg_icon_healer.dds",
    [LFG_ROLE_DPS]  = "esoui/art/lfg/lfg_icon_dps.dds",
}


function GF.BuildCategories()
    local categories = {
        {
            id   = GROUP_FINDER_CATEGORY_TRIAL,
            icon = "esoui/art/icons/mapkey/mapkey_raiddungeon.dds",
            size = GF.TOP_BUTTON_SIZE,
            name = "Trials",
        },
        {
            id   = GROUP_FINDER_CATEGORY_DUNGEON,
            icon = "esoui/art/icons/mapkey/mapkey_groupinstance.dds",
            size = GF.TOP_BUTTON_SIZE,
            name = "Dungeons",
        },
        {
            id   = GROUP_FINDER_CATEGORY_ARENA,
            icon = "esoui/art/icons/mapkey/mapkey_groupdelve.dds",
            size = GF.TOP_BUTTON_SIZE,
            name = "Arenas",
        },
        {
            id   = GROUP_FINDER_CATEGORY_ENDLESS_DUNGEON,
            icon = "esoui/art/leaderboards/gamepad/gp_leaderboards_menuicon_endlessdungeon_duo.dds",
            size = GF.TOP_BUTTON_SIZE,
            name = "Infinite Archive",
        },
        {
            id   = GROUP_FINDER_CATEGORY_ZONE,
            icon = "esoui/art/armory/buildicons/buildicon_47.dds",
            size = GF.TOP_BUTTON_SIZE,
            name = "Zone",
        },
        {
            id   = GROUP_FINDER_CATEGORY_CUSTOM,
            icon = "esoui/art/guildfinder/gamepad/gp_guildrecruitment_menuicon_applications.dds",
            size = GF.TOP_BUTTON_SIZE,
            name = "Custom",
        },
    }
    

    if GF.eventZone then
        table.insert(categories, 6, {
            id   = GROUP_FINDER_CATEGORY_ADVENTURE_ZONE,
            icon = "esoui/art/treeicons/gamepad/gp_nightmarket.dds",
            size = GF.TOP_BUTTON_SIZE,
            name = "Event Zone",
        })
    end
    
    return categories
end

GF.Categories = GF.BuildCategories()

GF.currentCategoryIndex = 1
GF.currentCategory = GF.Categories[GF.currentCategoryIndex].id

-- =========================================================
-- Trial Definitions (Shortcode → ZoneID)
-- =========================================================

GF.Trials = {
    AA  = 638,
    AS  = 1000,
    CR  = 1051,
    HoF = 975,
    HRC = 636,
    SO  = 639,
    MoL = 725,
    SS  = 1121,
    KA  = 1196,
    RG  = 1263,
    DSR = 1344,
    SE  = 1427,
    LC  = 1478,
    OC  = 1548,
}

GF.Dungeons = {
    ["VoM"]  = 11,
    ["VF"]   = 22,
    ["SW"]   = 31,
    ["BHH"]   = 38,
    ["DC-I"]  = 63,
    ["BC"]   = 64,
    ["EH-I"]  = 126,
    ["CoH-I"] = 130,
    ["TI"]   = 131,
    ["SC-I"]  = 144,
    ["WS-I"]  = 146,
    ["AC"]   = 148,
    ["CoA-I"] = 176,
    ["FG-I"]  = 283,
    ["BC-I"]  = 380,
    ["DK"]   = 449,
    ["ICP"]  = 678,
    ["CoA-II"] = 681,
    ["WGT"]  = 688,
    ["RoM"]  = 843,
    ["COS"]  = 848,
    ["DC-II"] = 930,
    ["EH-II"] = 931,
    ["CoH-II"] = 932,
    ["WS-II"] = 933,
    ["FG-II"] = 934,
    ["BC-II"] = 935,
    ["SC-II"] = 936,
    ["BF"]   = 973,
    ["FH"]   = 974,
    ["FL"]   = 1009,
    ["SCP"]  = 1010,
    ["MHK"]  = 1052,
    ["MoS"]  = 1055,
    ["FV"]   = 1080,
    ["DoM"]  = 1081,
    ["MGF"]  = 1122,
    ["LoM"]  = 1123,
    ["IR"]   = 1152,
    ["UG"]   = 1153,
    ["SG"]   = 1197,
    ["CT"]   = 1201,
    ["BDV"]  = 1228,
    ["CD"]   = 1229,
    ["RPB"]  = 1267,
    ["DC"]   = 1268,
    ["CA"]   = 1301,
    ["SR"]   = 1302,
    ["ERE"]  = 1360,
    ["GD"]   = 1361,
    ["BS"]   = 1389,
    ["SH"]   = 1390,
    ["OSP"]   = 1470,
    ["BV"]   = 1471,
    ["ExR"]  = 1496,
    ["LS"]   = 1497,
    ["NC"]   = 1551,
    ["BGF"]  = 1552,
}


GF.Arenas = {
   DSA = 635,
   BRP = 1082,
}


GF.TrialDefinitions = {
    SS = { "SS", "SUNSPIRE", "SUN SPIRE" },
    KA = { "KA", "KYNE'S AEGIS", "KYNES AEGIS" },
    SO = { "SO", "SANCTUM OPHIDIA" },
    HRC = { "HRC", "HEL RA CITADEL", "HELRA", "HEL RA" },
    AA = { "AA", "AETHERIAN ARCHIVE" },
    AS = { "AS", "AS", "ASYLUM SANCTORIUM" },
    CR = { "CR", "CR+1", "CR+2", "CR+3", "CLOUDREST" },
    MoL = { "MOL", "MAW OF LORKHAJ" },
    RG = { "RG", "ROCKGROVE" },
    DSR = { "DSR", "DREADSAIL REEF", "DREAD SAIL", "REEF", "DREAD SAIL REEF" },
    SE = { "SE", "SANITYS EDGE", "SANITY'S EDGE" },
    LC = { "LC", "LUCENT CITADEL", "LUCENT" },
    OC = { "OC", "OSSEIN CAGE", "OSSEIN", "CAGE" },
    HoF = { "HOF", "HALLS", "HALLS OF FABRICATION", "FABRICATION" },
}

GF.CategoriesWithPrefix = {
    [GROUP_FINDER_CATEGORY_TRIAL]   = true,
    [GROUP_FINDER_CATEGORY_DUNGEON] = true,
    [GROUP_FINDER_CATEGORY_ARENA]   = true,
}


-- =========================================================

local function normalizeZoneName(name)
    if not name then return "" end
    name = name:gsub("%^.*$", "")
    name = name:match("^%s*(.-)%s*$") or ""
    return name:upper()
end

function GF.StripZonePostfix(name)
    if not name then return "" end
    return name:gsub("%^.*$", "")
end

local function buildZoneLookup(shortToZone, nameToZoneTable, zoneToShortTable)
    for short, zoneId in pairs(shortToZone) do
        local zoneName = normalizeZoneName(GetZoneNameById(zoneId) or "")
        nameToZoneTable[zoneName] = zoneId
        zoneToShortTable[zoneId] = short
    end
end

-- Trials
GF.ZoneNameToShort = {}
GF.TrialNameToZoneID = {}
buildZoneLookup(GF.Trials, GF.TrialNameToZoneID, GF.ZoneNameToShort)

-- Dungeons
GF.DungeonNameToZoneID = {}
GF.ZoneToDungeonShort = {}
buildZoneLookup(GF.Dungeons, GF.DungeonNameToZoneID, GF.ZoneToDungeonShort)

-- Arenas
GF.ArenaNameToZoneID = {}
GF.ZoneToArenaShort = {}
buildZoneLookup(GF.Arenas, GF.ArenaNameToZoneID, GF.ZoneToArenaShort)

-- Blacklist functions
function GF.BlacklistLeader(displayName)
    GF.Settings.BlacklistedLeaders[displayName] = true
    GF.RefreshUI()

    if GF_BLACKLIST_DROPDOWN then
        GF_BLACKLIST_DROPDOWN:UpdateChoices(GF.GetBlacklistChoices())
        GF_BLACKLIST_DROPDOWN:UpdateValue()
    end
end

function GF.IsLeaderBlacklisted(displayName)
    return GF.Settings.BlacklistedLeaders[displayName] == true
end

-- =========================================================
-- Keybinds
-- =========================================================
function GroupFinderPlus_ToggleWindow()
    if GF.isMasterHidden then return end
	
    if not GF.win then
        GF.CreateWindow()
    end

    local hidden = not GF.Settings.isHidden
    GF.Settings.isHidden = hidden

    if GF.fragment then
        if hidden then
            GF.fragment:Hide()
        else
            GF.fragment:Show(true)
        end
    end
end

function GroupFinderPlus_CycleCategory()
    if not GF.win or GF.Settings.isHidden or GF.isMasterHidden then return end

    local nextIndex = GF.GetNextEnabledCategoryIndex()
    if not nextIndex then return end

    GF.currentCategoryIndex = nextIndex
    local cat = GF.Categories[nextIndex]
    GF.currentCategory = cat.id
	
    GF.Settings.LastCategory = GF.Settings.SaveLastCategory and GF.currentCategory or nil

    if GF.topButton then
        GF.topButton:ClearAnchors()
        GF.topButton:SetTexture(cat.icon)
        GF.topButton:SetDimensions(cat.size or GF.TOP_BUTTON_SIZE, cat.size or GF.TOP_BUTTON_SIZE)
    end

    GF.UpdateTopButtonAnchors()
    GF.UpdatePrimaryButtonVisibility()

    GF.ClearListingsUI()
    GF.ApplyCategory()
	
    GF.firstSearchAfterCategoryChange = true
    GF.SetEmptyIconSearching(true)
    
    if not IsGroupFinderSearchOnCooldown() then
        GF.RequestCurrentCategorySearch()
    end

    PlaySound(SOUNDS.GUILD_RANK_LOGO_SELECTED)
end

function GroupFinderPlus_SwitchMode()
    if not GF.win or GF.Settings.isHidden or GF.isMasterHidden then return end

    if not GF.CategoriesWithPrefix[GF.currentCategory] then return end

    GF.primaryOptionIndex = (GF.primaryOptionIndex == 1) and 2 or 1
    GF.Settings.PrimaryOptionIndex = GF.primaryOptionIndex

    if GF.leftTopButton then
        GF.leftTopButton:ClearAnchors()
        local icon = (GF.primaryOptionIndex == 1) and ICON_NORMAL or ICON_VETERAN
        GF.leftTopButton:SetTexture(icon)
        GF.leftTopButton:SetDimensions(24, 24)
    end

    GF.UpdateTopButtonAnchors()
    GF.UpdatePrimaryButtonVisibility()

    SetGroupFinderFilterPrimaryOptionByIndex(GF.primaryOptionIndex, true)

    GF.ClearListingsUI()
    GF.firstSearchAfterCategoryChange = true
    GF.SetEmptyIconSearching(true)

    if not IsGroupFinderSearchOnCooldown() then
        GF.RequestCurrentCategorySearch()
    end

    PlaySound(SOUNDS.GUILD_RANK_LOGO_SELECTED)
end

function GF.SetupBackgroundColors()
    GF.bg:SetCenterColor(0, 0, 0, 0.5)
    GF.bg:SetEdgeColor(0, 0, 0, 0.5)
    GF.bg:SetEdgeTexture("GroupFinderPlus/Textures/centerscreen_floating_edge.dds", 256, 256, 8)
    GF.bg:SetCenterTexture("GroupFinderPlus/Textures/centerscreen_floating_center.dds")
end

function GF.GetNextEnabledCategoryIndex()
    local total = #GF.Categories
    if total == 0 then return nil end

    local startIndex = GF.currentCategoryIndex
    local nextIndex = startIndex

    repeat
        nextIndex = nextIndex + 1
        if nextIndex > total then
            nextIndex = 1
        end

        local cat = GF.Categories[nextIndex]
        if GF.Settings.CategoriesEnabled[cat.id] ~= false then
            return nextIndex
        end
    until nextIndex == startIndex

    return startIndex
end

function GF.GetCurrentIndexBySessionId(sessionId)
    if not sessionId then return nil end
    for i = 1, #GF.listings do
        if GF.listings[i] and GF.listings[i].sessionId == sessionId then
            return i
        end
    end
    return nil
end

local function GetActualGroupSize(sizeIndex)
    local sizeMap = {
        [1] = 2,   -- Duo
        [2] = 4,   -- Dungeon
        [4] = 12,  -- Trial
    }
    return sizeMap[sizeIndex]
end

-- =========================================================
-- GetShortCode
-- =========================================================

function GF.GetShortCode(listingIndex)
    local _, listingName = GetGroupFinderSearchListingOptionsSelectionTextByIndex(listingIndex)

    if not listingName or listingName == "" then
        return "∞", nil, nil
    end

    listingName = normalizeZoneName(listingName)

    local zoneId, short

    if GF.currentCategory == GROUP_FINDER_CATEGORY_TRIAL then
        zoneId = GF.TrialNameToZoneID[listingName]
        short  = zoneId and GF.ZoneNameToShort[zoneId]
    elseif GF.currentCategory == GROUP_FINDER_CATEGORY_DUNGEON then
        zoneId = GF.DungeonNameToZoneID[listingName]
        short  = zoneId and GF.ZoneToDungeonShort[zoneId]
    elseif GF.currentCategory == GROUP_FINDER_CATEGORY_ARENA then
        zoneId = GF.ArenaNameToZoneID[listingName]
        short  = zoneId and GF.ZoneToArenaShort[zoneId]
    end

    local zoneName = zoneId and GetZoneNameById(zoneId) or nil

    return short or "∞", zoneId, zoneName
end

-- =========================================================
-- Window Creation
-- =========================================================
function GF.CreateWindow()
    GF.win = WINDOW_MANAGER:CreateTopLevelWindow("GroupFinderPlusWindow")
    GF.win:SetDimensions(GF.BASE_WIDTH, 200)
    GF.win:SetMovable(true)
    GF.win:SetMouseEnabled(true)
    GF.win:SetClampedToScreen(false)
    GF.win:SetDrawLayer(DL_OVERLAY)
	GF.win:SetDrawTier(DT_MEDIUM)
	GF.win:SetDrawLevel(0)         
    GF.win:ClearAnchors()
    GF.ApplyWindowAnchor()
    GF.win:SetHidden(true)

    GF.win:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StartMoving()
        end
    end)
    GF.win:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StopMovingOrResizing()
        end
    end)

	GF.win:SetHandler("OnMoveStop", function(self)
		local screenW = GuiRoot:GetWidth()
		local left    = self:GetLeft()
		local right   = self:GetRight()
		local top     = self:GetTop()
		local width   = self:GetWidth()

		local EPS     = 2
		local anchor  = GF.Settings.windowAnchor 
		local x       = GF.Settings.windowOffsetX

		-- Only change anchor if actually touching an edge
		if left <= EPS then
			anchor = "LEFT"
			x = 5
		elseif right >= screenW - EPS then
			-- Snap to right
			anchor = "RIGHT"
			x = -5 
		else
			-- Not touching either edge, preserve current anchor but update position
			anchor = GF.Settings.windowAnchor
			if anchor == "LEFT" then
				x = left
			else
				x = screenW - right
			end
		end

		GF.Settings.windowAnchor  = anchor
		GF.Settings.windowOffsetX = x
		GF.Settings.windowOffsetY = top

		GF.ApplyWindowAnchor()
	end)

    local background = WINDOW_MANAGER:CreateControl(nil, GF.win, CT_BACKDROP)
    GF.bg = background

	background:SetAnchor(TOPLEFT, GF.win, TOPLEFT, -5, GF.TOP_CONTENT_OFFSET)

    background:SetWidth(GF.BASE_WIDTH)
    background:SetHeight(200)
    background:SetInsets(8, 8, -8, -8)
    background:SetIntegralWrapping(true)
    background:SetDrawLayer(DL_BACKGROUND)

    GF.SetupBackgroundColors()


    -- =====================================================
    -- Drag area for empty state
    -- =====================================================
    local dragArea = WINDOW_MANAGER:CreateControl(nil, GF.win, CT_CONTROL)
    dragArea:SetAnchorFill(GF.win)
    dragArea:SetMouseEnabled(true)
    dragArea:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:GetParent():StartMoving()
        end
    end)
    dragArea:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:GetParent():StopMovingOrResizing()
        end
    end)
    GF.dragArea = dragArea
    GF.dragArea:SetHidden(true)

    -- Empty state label
    local emptyLabel = WINDOW_MANAGER:CreateControl(nil, GF.win, CT_LABEL)
    emptyLabel:SetAnchor(CENTER, GF.bg, CENTER, 0, 0)
    emptyLabel:SetFont("ZoFontWinH1")
    emptyLabel:SetText("∞")
    emptyLabel:SetColor(0.5, 0.5, 0.5, 1)
    emptyLabel:SetHidden(true)
    emptyLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    emptyLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    emptyLabel:SetMouseEnabled(false) 
    GF.emptyIcon = emptyLabel
	
	local searchIcon = WINDOW_MANAGER:CreateControl(nil, GF.win, CT_TEXTURE)
	searchIcon:SetAnchor(CENTER, GF.bg, CENTER, 0, -1)
	searchIcon:SetDimensions(24, 24)
	searchIcon:SetTexture("esoui/art/miscellaneous/timer_32.dds")
	searchIcon:SetColor(1, 0.85, 0, 1) 
	searchIcon:SetHidden(true)
	searchIcon:SetMouseEnabled(false)

	GF.searchIcon = searchIcon

    -- Fragment
    GF.fragment = ZO_HUDFadeSceneFragment:New(GF.win)
    HUD_SCENE:AddFragment(GF.fragment)
    HUD_UI_SCENE:AddFragment(GF.fragment)

    local originalShow = GF.fragment.Show
    function GF.fragment:Show(force)
        if not force and GF.Settings.isHidden then return end
        originalShow(self)
    end

    if not GF.Settings.isHidden then
        GF.fragment:Show()
    else
        GF.fragment:Hide()
    end
	
	-- =====================================================
	-- Top-right overlay button
	-- =====================================================
	local button = WINDOW_MANAGER:CreateControl(nil, GF.win, CT_TEXTURE)
	GF.topButton = button

	button:SetDimensions(GF.TOP_BUTTON_SIZE, GF.TOP_BUTTON_SIZE)
	button:SetTexture(GF.Categories[GF.currentCategoryIndex].icon)
	button:SetMouseEnabled(true)

	button:SetAnchor(
		TOPRIGHT,
		GF.win,
		TOPRIGHT,
		-GF.TOP_BUTTON_PADDING - 2,
		GF.TOP_BUTTON_PADDING + 10
	)

	button:SetDrawLayer(DL_OVERLAY)
	button:SetDrawTier(DT_HIGH)
	button:SetDrawLevel(5)

	button:SetHandler("OnMouseUp", function(self, buttonId)
    if buttonId == MOUSE_BUTTON_INDEX_LEFT then
        GroupFinderPlus_CycleCategory()
    end
    end)

	-- =====================================================
	-- Primary option toggle button (Normal / Veteran)
	-- =====================================================
	if GF.Settings.ShowPrimaryOptionButton then
		local leftButton = WINDOW_MANAGER:CreateControl(nil, GF.win, CT_TEXTURE)
		GF.leftTopButton = leftButton

		-- Set initial texture and size based on PRIMARY_ICON_SIZE
		local icon = (GF.primaryOptionIndex == 1) and ICON_NORMAL or ICON_VETERAN
		leftButton:SetTexture(icon)

		leftButton:SetDimensions(24, 24)

		leftButton:SetMouseEnabled(true)

		-- Anchor LEFT of category button
		leftButton:SetAnchor(
			RIGHT,
			GF.topButton,
			LEFT,
			0,
			0
		)

		leftButton:SetDrawLayer(DL_OVERLAY)
		leftButton:SetDrawTier(DT_HIGH)
		leftButton:SetDrawLevel(5)

		leftButton:SetHandler("OnMouseUp", function(_, buttonId)
			if buttonId == MOUSE_BUTTON_INDEX_LEFT then
				GroupFinderPlus_SwitchMode()
			end
		end)
	end

    GF.UpdateTopButtonAnchors()
	
end

function GF.ApplyWindowAnchor()
    if not GF.win then return end

    local x = GF.Settings.windowOffsetX or 0
    local y = GF.Settings.windowOffsetY or 0

    GF.win:ClearAnchors()

    if GF.Settings.windowAnchor == "RIGHT" then
        GF.win:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -x, y)
    else
        GF.win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    end
	
	GF.UpdateTopButtonAnchors()
end

function GF.UpdatePrimaryButtonVisibility()
    if not GF.Settings.ShowPrimaryOptionButton then
        if GF.leftTopButton then
            GF.leftTopButton:SetHidden(true)
        end
        return
    end

    local show =
        GF.currentCategory == GROUP_FINDER_CATEGORY_TRIAL
     or GF.currentCategory == GROUP_FINDER_CATEGORY_DUNGEON
     or GF.currentCategory == GROUP_FINDER_CATEGORY_ARENA

    if GF.leftTopButton then
        GF.leftTopButton:SetHidden(not show or GF.isMasterHidden or GF.Settings.isHidden)

        if show and not GF.isMasterHidden and not GF.Settings.isHidden then
            local icon = (GF.primaryOptionIndex == 1) and ICON_NORMAL or ICON_VETERAN
            GF.leftTopButton:SetTexture(icon)

            GF.leftTopButton:SetDimensions(24, 24)
        end
    end
end

function GF.SetEmptyIconSearching(isSearching)
    if isSearching then
        if GF.emptyIcon then GF.emptyIcon:SetHidden(true) end
        if GF.searchIcon then GF.searchIcon:SetHidden(false) end
    else
        if GF.searchIcon then GF.searchIcon:SetHidden(true) end

        local rowCount = #GF.listings or 0
        if rowCount == 0 and GF.emptyIcon then
            GF.emptyIcon:SetHidden(false)
            GF.emptyIcon:SetColor(0.5, 0.5, 0.5, 1)
        end
    end
end

-- =========================================================
-- Row Creation
-- =========================================================
function GF.CreateRow()
    local row = WM:CreateControl(nil, GF.win, CT_CONTROL)
	row.isHovered = false
    row:SetHeight(GF.ROW_HEIGHT)
    row:SetMouseEnabled(true)

    -- Background
    row.bg = WM:CreateControl(nil, row, CT_BACKDROP)
    row.bg:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
    row.bg:SetWidth(GF.BASE_WIDTH)
    row.bg:SetHeight(GF.ROW_HEIGHT)
    row.bg:SetCenterColor(0.15, 0.15, 0.15, 0.25)
    row.bg:SetEdgeTexture("", 1, 1, 0)
    row.bg:SetEdgeColor(0, 0, 0, 0)

    -- Label
    row.label = WM:CreateControl(nil, row, CT_LABEL)
    row.label:SetAnchor(LEFT, row, LEFT, GF.PADDING, 0)
    row.label:SetFont("ZoFontGame")
    row.label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

    -- CP requirement warning icon (hidden by default)
    row.cpIcon = WM:CreateControl(nil, row, CT_TEXTURE)
    row.cpIcon:SetDimensions(20, 20)
    row.cpIcon:SetTexture("esoui/art/treeicons/achievements_indexicon_champion_up.dds")
    row.cpIcon:SetColor(1, 0, 0, 1) -- RED
    row.cpIcon:SetHidden(true)

    -- Roles container
    row.roles = WM:CreateControl(nil, row, CT_CONTROL)
    row.roles:SetHeight(GF.ROW_HEIGHT)
    row.roles:SetMouseEnabled(false)

    -- Role icons + numbers
    row.roleControls = {}
    local prev
    for _, role in ipairs({ LFG_ROLE_TANK, LFG_ROLE_HEAL, LFG_ROLE_DPS }) do
        local icon = WM:CreateControl(nil, row.roles, CT_TEXTURE)
        icon:SetDimensions(18, 18)
        icon:SetTexture(GF.ROLE_ICONS[role])

        local text = WM:CreateControl(nil, row.roles, CT_LABEL)
        text:SetFont("ZoFontGameSmall")

        if prev then
            icon:SetAnchor(LEFT, prev.text, RIGHT, 10, 0)
        else
            icon:SetAnchor(LEFT, row.roles, LEFT, 0, 0)
        end
        text:SetAnchor(LEFT, icon, RIGHT, 2, 0)

        row.roleControls[role] = { icon = icon, text = text }
        prev = row.roleControls[role]
    end

    -- Tooltip and hover behavior
		row:SetHandler("OnMouseEnter", function(self)
			PlaySound(SOUNDS.GAMEPAD_MENU_UP)
			self.isHovered = true

			local side, offset
			if GF.Settings.windowAnchor == "LEFT" then
				side   = LEFT   
				offset = 5
			else
				side   = RIGHT 
				offset = -5
			end

			InitializeTooltip(InformationTooltip, self, side, offset, 0)

			ZO_ClearNumericallyIndexedTable(GF.tooltipLines)
            local lines = GF.tooltipLines

			-- Instance tooltip
			if GF.Settings.ShowInstanceTooltip and self.tooltipData and self.tooltipData.instance and self.tooltipData.instance ~= "" then
				local displayInstance = GF.StripZonePostfix(self.tooltipData.instance)
				table.insert(lines, string.format("|cFFFFFF%s|r", displayInstance))
			end

			-- Host info
			if self.tooltipData then
				local displayName = self.tooltipData.displayName or "Unknown"
				local charName    = self.tooltipData.charName    or "Unknown"
				table.insert(lines, string.format("|cFFC500%s%s|r", charName, displayName))
			end

			-- Description 
			local tooltipDesc = (self.tooltipData and self.tooltipData.desc) or self.desc
			table.insert(lines, tooltipDesc)

			SetTooltipText(InformationTooltip, table.concat(lines, "\n"))

			-- Hover background tweak
			if self.desiredBgColor then
				local r, g, b, a = unpack(self.desiredBgColor)
				if r == 0.15 and g == 0.15 and b == 0.15 then
					self.bg:SetCenterColor(0.45, 0.45, 0.45, a)
				end
			end
		end)

		row:SetHandler("OnMouseExit", function(self)
			self.isHovered = false
			ClearTooltip(InformationTooltip)
			if self.desiredBgColor then
				self.bg:SetCenterColor(unpack(self.desiredBgColor))
			end
		end)

    -- Drag window
    row:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:GetParent():StartMoving()
        end
    end)
    row:SetHandler("OnMouseUp", function(self, button)
		if button == MOUSE_BUTTON_INDEX_LEFT then
			self:GetParent():StopMovingOrResizing()

		elseif button == MOUSE_BUTTON_INDEX_RIGHT then
			GF.ShowContextMenu(self)
		end
	end)

	-- Double-click to apply directly to the listing
	row:SetHandler("OnMouseDoubleClick", function(self, button)
		if button ~= MOUSE_BUTTON_INDEX_LEFT or not self.sessionId then return end
		
		if self.autoAccept then
			local joinResult = GetGroupFinderSearchListingJoinabilityResult(self.listingIndex)
			if joinResult == 13 then
				GF.Popup("Wrong role!", nil, "FFA500")
				return
			end
			RequestApplyToGroupListing(self.listingIndex, nil, nil)
		else
			local joinResult = GetGroupFinderSearchListingJoinabilityResult(self.listingIndex)
			if joinResult == 13 then
				GF.Popup("Wrong role!", nil, "FFA500")
				return
			end
			local dialogData = {
				GetListingIndex = function() return GF.GetCurrentIndexBySessionId(self.sessionId) end,
				GetTitle = function() return self.title end,
				DoesGroupAutoAcceptRequests = function() return self.autoAccept end,
				DoesGroupRequireInviteCode = function() return self.requireCode end,
			}
			ZO_Dialogs_ShowDialog("GROUP_FINDER_APPLICATION_KEYBOARD", dialogData)
		end
	end)


    return row
end

function GF.GetFullRoleData(listingIndex)
    local roleData = {}
    local roles = { LFG_ROLE_TANK, LFG_ROLE_HEAL, LFG_ROLE_DPS }
    
    for _, role in ipairs(roles) do
        local requested, current = GetGroupFinderSearchListingRoleStatusCount(listingIndex, role)
        roleData[role] = {
            requested = requested or 0,
            current = current or 0
        }
    end
    
    return roleData
end

-- =========================================================
-- Set Category
-- =========================================================

function GF.ApplyCategory()
    SetGroupFinderFilterCategory(GF.currentCategory, true)
end

local function findStandalone(text, pattern)
    local s, e = text:find(pattern)
    if not s then return nil end

    local before = s > 1 and text:sub(s - 1, s - 1) or ""
    local after  = e < #text and text:sub(e + 1, e + 1) or ""

    -- allow V/N prefix
    if before:match("%a") and before:upper() ~= "V" and before:upper() ~= "N" then
        return nil
    end

    if after:match("%a") then
        return nil
    end

    return s
end

-- =========================================================
-- Build Listings
-- =========================================================
function GF.BuildListings()
    ZO_ClearNumericallyIndexedTable(GF.listings)
    ZO_ClearNumericallyIndexedTable(GF.tempListings)

    local count = GetGroupFinderSearchNumListings()
    local tempListings = GF.tempListings

    for i = 1, count do
        local title = GetGroupFinderSearchListingTitleByIndex(i)
        local desc  = GetGroupFinderSearchListingDescriptionByIndex(i)

        local hideWTS = GF.Settings.HideWTSListings
        if GF.currentCategory == GROUP_FINDER_CATEGORY_CUSTOM then
            hideWTS = false
        end

        if not (hideWTS and title:lower():find("wts")) then
            local short, zoneId, zoneName = GF.GetShortCode(i)

			if short == "∞" then
				local text = normalizeZoneName(title)
				local bestCode, bestScore

				for code, aliases in pairs(GF.TrialDefinitions) do
					aliases = aliases or { code }

					for _, alias in ipairs(aliases) do
						local pos = findStandalone(text, "[VN]%s*" .. alias)
						if pos then
							local score = 10000 - pos
							if not bestScore or score > bestScore then
								bestScore = score
								bestCode = code
							end
						end

						local plainPos = findStandalone(text, alias)
						if plainPos then
							local score = 1000 - plainPos
							if not bestScore or score > bestScore then
								bestScore = score
								bestCode = code
							end
						end
					end
				end

				if bestCode then
					short = bestCode

					if GF.currentCategory == GROUP_FINDER_CATEGORY_TRIAL then
						zoneId = GF.Trials[short]
						zoneName = zoneId and GetZoneNameById(zoneId)
					end
				end
			end

            if short == "∞" or GF.Settings.TrialsEnabled[short] ~= false then
				local prefix = ""

				if GF.CategoriesWithPrefix[GF.currentCategory] then
					prefix = "[" .. short .. "]"
				end

                local fallbackDesc = desc ~= "" and desc or "N/A"
				
				local leaderDisplayName = GetGroupFinderSearchListingLeaderDisplayNameByIndex(i)
				local leaderCharName = GetGroupFinderSearchListingLeaderCharacterNameByIndex(i)
				
				local sessionId = leaderDisplayName .. "|" .. title
				
				local autoAccept = DoesGroupFinderSearchListingAutoAcceptRequests(i)
				local requireCode = DoesGroupFinderSearchListingRequireInviteCode(i)
				local joinResult = GetGroupFinderSearchListingJoinabilityResult(i)
				local isPending = IsGroupFinderSearchListingActiveApplication(i)
				local requiresCP = DoesGroupFinderSearchListingRequireChampion(i)
				local requiredCP = GetGroupFinderSearchListingChampionPointsByIndex(i)
				local enforcesRoles = DoesGroupFinderSearchListingEnforceRoles(i)
				local groupSizeIndex = GetGroupFinderSearchListingGroupSizeByIndex(i)

				table.insert(tempListings, {
					index = i,
					sessionId = sessionId,
					title = title,
					desc = fallbackDesc,
					short = prefix,
					roleData = GF.GetFullRoleData(i),
					instance = zoneName,
					groupSizeIndex = groupSizeIndex,
					leaderDisplayName = leaderDisplayName,
					leaderCharName = leaderCharName,
					autoAccept = autoAccept,
					requireCode = requireCode,
					joinResult = joinResult,
					isPending = isPending,
					requiresCP = requiresCP,
					requiredCP = requiredCP,
					enforcesRoles = enforcesRoles,
					tooltip = {
						instance = zoneName,
						charName = leaderCharName,
						displayName = leaderDisplayName,
						desc = fallbackDesc,
					},
				})

            end
        end
    end

    for _, listing in ipairs(tempListings) do
        table.insert(GF.listings, listing)
    end
end


-- =========================================================
-- UI Refresh 
-- =========================================================
function GF.RefreshUI()
    ZO_ClearNumericallyIndexedTable(GF.filteredListings)
    
    local bgPadding = 4
    local extraMargin = 3
    local rowExtraWidth = 5
    local rolesGap = 20
    local maxRowWidth = 0
    local maxLabelWidth = 0
    local prev

    local playerCP = GF.championPoints

    local CP_ICON_WIDTH = 22
    local showCpColumn = false

    -- =====================================================
    -- Filter listings if user wants to hide insufficient CP
    -- =====================================================
    local filteredListings = GF.filteredListings
    for _, listing in ipairs(GF.listings) do
        local requiredCP = listing.requiresCP and listing.requiredCP or 0
        
        local hideCPCheck = not GF.Settings.HideInsufficientCP or playerCP >= requiredCP
        local hideSessionCheck = not GF.hiddenListings[listing.sessionId]
        local hideBlacklistCheck = not GF.IsLeaderBlacklisted(listing.leaderDisplayName)
        
        if hideCPCheck and hideSessionCheck and hideBlacklistCheck then
            table.insert(filteredListings, listing)
        end
    end

    local rowCount = #filteredListings

    -- =====================================================
    -- Empty state
    -- =====================================================
    if rowCount == 0 then
        for i = 1, #GF.rows do
            GF.rows[i]:SetHidden(true)
        end
        if GF.emptyIcon then GF.emptyIcon:SetHidden(false) end
        if GF.dragArea then GF.dragArea:SetHidden(false) end

        local symbolSize  = 64
        local padding     = -15
        local totalWidth  = symbolSize + padding * 2
        local totalHeight = symbolSize + padding * 2 + GF.TOP_CONTENT_OFFSET

        GF.win:SetDimensions(totalWidth, totalHeight)
        GF.bg:SetWidth(totalWidth)
        GF.bg:SetHeight(totalHeight - GF.TOP_CONTENT_OFFSET)

        GF.ApplyWindowAnchor()

        GF.SetupBackgroundColors()

        if GF.emptyIcon then
            GF.emptyIcon:ClearAnchors()
            GF.emptyIcon:SetAnchor(CENTER, GF.bg, CENTER, 0, -1)
        end
        return
    end

    -- =====================================================
    -- Normal listings
    -- =====================================================
    if GF.emptyIcon then GF.emptyIcon:SetHidden(true) end
    if GF.dragArea then GF.dragArea:SetHidden(true) end

    GF.SetupBackgroundColors()

    -- =====================================================
    -- Calculate max label width (REUSE dummy label)
    -- =====================================================
    if not GF.dummyLabel then
        GF.dummyLabel = WM:CreateControl(nil, GuiRoot, CT_LABEL)
        GF.dummyLabel:SetFont("ZoFontGame")
        GF.dummyLabel:SetHidden(true)
    end

    local dummy = GF.dummyLabel

    for _, listing in ipairs(filteredListings) do
        dummy:SetText(listing.short .. " " .. listing.title)
        maxLabelWidth = math.max(maxLabelWidth, dummy:GetTextWidth())
    end

    -- =====================================================
    -- First pass: decide if CP column is needed
    -- =====================================================
    for _, listing in ipairs(filteredListings) do
        if listing.requiresCP and playerCP < listing.requiredCP then
            showCpColumn = true
            break
        end
    end

    -- =====================================================
    -- Layout rows
    -- =====================================================
    for i, listing in ipairs(filteredListings) do
        local row = GF.rows[i] or GF.CreateRow()
        GF.rows[i] = row
        row.listingIndex      = listing.index
        row.sessionId         = listing.sessionId 
        row.title             = listing.title
        row.leaderDisplayName = listing.leaderDisplayName
        row.leaderCharName    = listing.leaderCharName
        row.desc              = listing.desc
        row.instance          = listing.instance
        row.autoAccept        = listing.autoAccept
        row.requireCode       = listing.requireCode
        row.joinResult        = listing.joinResult
        row.isPending         = listing.isPending
        row.requiresCP        = listing.requiresCP
        row.requiredCP        = listing.requiredCP
        row.enforcesRoles     = listing.enforcesRoles
        row.roleData          = listing.roleData 
        row.tooltipData       = listing.tooltip
        row.groupSizeIndex    = listing.groupSizeIndex        

        -- Label
        row.label:SetText(
        listing.short ~= "" and (listing.short .. " " .. listing.title) or listing.title)

        row.label:SetWidth(maxLabelWidth)
        row.label:SetColor(1, 1, 1, 1)

        -- Role counts - use stored data
        row.roleControls[LFG_ROLE_TANK].text:SetText(row.roleData[LFG_ROLE_TANK].current)
        row.roleControls[LFG_ROLE_HEAL].text:SetText(row.roleData[LFG_ROLE_HEAL].current)
        row.roleControls[LFG_ROLE_DPS].text:SetText(row.roleData[LFG_ROLE_DPS].current)

        -- CP warning (per-row visibility) - use stored values
        local showCpWarning = row.requiresCP and playerCP < row.requiredCP
        row.cpIcon:SetHidden(not showCpWarning)

        row.cpIcon:ClearAnchors()
        if showCpWarning then
            row.cpIcon:SetAnchor(LEFT, row.label, RIGHT, 4, 0)
        end

        -- Visual highlights
        local isPending  = row.isPending
        local isJoined   = row.joinResult == 4    
        local isLastBoss = GF.IsLastBossListing(listing.title, listing.desc, listing.short)
                
        if isPending then
            row.desiredBgColor = {1.0, 1.0, 0.6, 0.5}
            GF.StopRainbow(row)

        elseif isJoined then
            row.desiredBgColor = {0.6, 1.0, 0.6, 0.4}
            GF.StopRainbow(row)

        elseif isLastBoss and GF.CategoriesWithPrefix[GF.currentCategory] then
            row.desiredBgColor = {0.15, 0.15, 0.15, 0.25}
            if GF.Settings.LastBossRainbow then
                GF.StartRainbow(row)
            else
                GF.StopRainbow(row)
            end

        else
            row.desiredBgColor = {0.15, 0.15, 0.15, 0.25}
            GF.StopRainbow(row)
        end
        
        if not row.isHovered then
            row.bg:SetCenterColor(unpack(row.desiredBgColor))
        end

        -- Roles width + coloring (using cached data)
        local rolesWidth = 0
        local roles = { LFG_ROLE_TANK, LFG_ROLE_HEAL, LFG_ROLE_DPS }

        if row.enforcesRoles then
            -- Get max group size (convert index to actual player count)
            local maxGroupSize = GetActualGroupSize(row.groupSizeIndex)
            
            -- Calculate total requested slots
            local totalRequested = 0
            for _, role in ipairs(roles) do
                totalRequested = totalRequested + (row.roleData[role].requested or 0)
            end
            
            -- Calculate total current players
            local totalCurrent = 0
            for _, role in ipairs(roles) do
                totalCurrent = totalCurrent + (row.roleData[role].current or 0)
            end
            
            -- Check if flex slots exist
            local hasFlexSlots = totalRequested < maxGroupSize
            
            if hasFlexSlots then
                -- Scenario: Flex slots exist
                -- Calculate unfilled requested slots per role
                local unfilledRequested = {}
                local totalUnfilledRequested = 0
                for _, role in ipairs(roles) do
                    local requested = row.roleData[role].requested or 0
                    local current = row.roleData[role].current or 0
                    unfilledRequested[role] = math.max(0, requested - current)
                    totalUnfilledRequested = totalUnfilledRequested + unfilledRequested[role]
                end
                
                -- Calculate remaining slots
                local remainingSlots = maxGroupSize - totalCurrent
                
                for _, role in ipairs(roles) do
                    local requested = row.roleData[role].requested or 0
                    local current = row.roleData[role].current or 0
                    
                    local shouldGrey = false
                    
                    -- Role not requested at all
                    if requested == 0 then
                        shouldGrey = true
                    -- Role has unfilled requested slots
                    elseif unfilledRequested[role] > 0 then
                        shouldGrey = false
                    -- Role is fully filled (unfilled == 0)
                    else
                        -- Check if remaining slots can only fill other roles' unfilled requests
                        local slotsNeededForOtherRoles = totalUnfilledRequested - unfilledRequested[role]
                        if remainingSlots <= slotsNeededForOtherRoles then
                            shouldGrey = true
                        end
                    end
                    
                    local alpha = shouldGrey and 0.3 or 1
                    
                    row.roleControls[role].icon:SetColor(1, 1, 1, alpha)
                    row.roleControls[role].text:SetColor(1, 1, 1, alpha)
                    
                    rolesWidth = rolesWidth + 18 + 2 + row.roleControls[role].text:GetTextWidth() + 5
                end
            else
                -- Scenario: No flex slots (fully distributed group)
                for _, role in ipairs(roles) do
                    local requested = row.roleData[role].requested or 0
                    local current = row.roleData[role].current or 0
                    
                    local shouldGrey = false
                    
                    -- Role not requested at all
                    if requested == 0 then
                        shouldGrey = true
                    -- Role has unfilled requested slots (still needed)
                    elseif current < requested then
                        shouldGrey = false
                    -- Role is fully filled (current >= requested)
                    else
                        shouldGrey = true
                    end
                    
                    local alpha = shouldGrey and 0.3 or 1
                    
                    row.roleControls[role].icon:SetColor(1, 1, 1, alpha)
                    row.roleControls[role].text:SetColor(1, 1, 1, alpha)
                    
                    rolesWidth = rolesWidth + 18 + 2 + row.roleControls[role].text:GetTextWidth() + 5
                end
            end
        else
            -- Listing allows all roles → keep full opacity
            for _, role in ipairs(roles) do
                row.roleControls[role].icon:SetColor(1, 1, 1, 1)
                row.roleControls[role].text:SetColor(1, 1, 1, 1)
                rolesWidth = rolesWidth + 18 + 2 + row.roleControls[role].text:GetTextWidth() + 5
            end
        end

        -- Anchor roles (aligned across all rows)
        row.roles:ClearAnchors()
        row.roles:SetAnchor(
            LEFT,
            row,
            LEFT,
            maxLabelWidth + rolesGap + (showCpColumn and CP_ICON_WIDTH or 0),
            0
        )
        row.roles:SetWidth(rolesWidth)

        -- Row width
        local rowWidth =
            maxLabelWidth +
            rolesGap +
            (showCpColumn and CP_ICON_WIDTH or 0) +
            rolesWidth +
            GF.PADDING +
            rowExtraWidth

        maxRowWidth = math.max(maxRowWidth, rowWidth)

        -- Anchor rows
        row:ClearAnchors()
        
        row:SetAnchor(
            TOPLEFT,
            prev or GF.win,
            prev and BOTTOMLEFT or TOPLEFT,
            0,
            prev and 0 or (bgPadding + GF.TOP_CONTENT_OFFSET)
        )

        row:SetWidth(rowWidth)
        row:SetHeight(GF.ROW_HEIGHT)
        row:SetHidden(false)
        row.bg:SetWidth(rowWidth)
        row.bg:SetHeight(GF.ROW_HEIGHT)

        prev = row
    end

    -- Hide unused rows
    for i = rowCount + 1, #GF.rows do
        GF.rows[i]:SetHidden(true)
    end

    -- Resize window
    local totalHeight =
        rowCount * GF.ROW_HEIGHT +
        bgPadding * 2 +
        GF.TOP_CONTENT_OFFSET

    local totalWidth = maxRowWidth + bgPadding * 2 + extraMargin
    GF.win:SetDimensions(totalWidth, totalHeight)
    GF.bg:SetWidth(totalWidth)
    GF.bg:SetHeight(totalHeight - GF.TOP_CONTENT_OFFSET)
end

function GF.ClearListingsUI()
    for i = 1, #GF.rows do
        GF.rows[i]:SetHidden(true)
    end

    -- Show empty icon and drag area
    if GF.emptyIcon then GF.emptyIcon:SetHidden(false) end
    if GF.dragArea then GF.dragArea:SetHidden(false) end

    -- Resize window to empty state
    local symbolSize  = 64
    local padding     = -15
    local totalWidth  = symbolSize + padding * 2
    local totalHeight = symbolSize + padding * 2 + GF.TOP_CONTENT_OFFSET

    GF.win:SetDimensions(totalWidth, totalHeight)
    GF.bg:SetWidth(totalWidth)
    GF.bg:SetHeight(totalHeight - GF.TOP_CONTENT_OFFSET)
    GF.ApplyWindowAnchor()

    if GF.emptyIcon then
        GF.emptyIcon:ClearAnchors()
        GF.emptyIcon:SetAnchor(CENTER, GF.bg, CENTER, 0, -1)
    end
end

function GF.UpdateTopButtonAnchors()
    if not GF.topButton then return end

    GF.topButton:ClearAnchors()
    if GF.leftTopButton then
        GF.leftTopButton:ClearAnchors()
    end

    if GF.Settings.windowAnchor == "RIGHT" then
        GF.topButton:SetAnchor(
            TOPRIGHT,
            GF.win,
            TOPRIGHT,
            -GF.TOP_BUTTON_PADDING - 2,
            GF.TOP_BUTTON_PADDING + 10
        )

        if GF.leftTopButton then
            GF.leftTopButton:SetAnchor(
                RIGHT,
                GF.topButton,
                LEFT,
                0,
                0
            )
        end

    else
        GF.topButton:SetAnchor(
            TOPLEFT,
            GF.win,
            TOPLEFT,
            GF.TOP_BUTTON_PADDING - 6,
            GF.TOP_BUTTON_PADDING + 10
        )

        if GF.leftTopButton then
            GF.leftTopButton:SetAnchor(
                LEFT,
                GF.topButton,
                RIGHT,
                0,
                0
            )
        end
    end
end

function GF.ExtractAchievementLinks(text)
    ZO_ClearNumericallyIndexedTable(GF.extractedLinks)
    if not text then return GF.extractedLinks end
    for link in text:gmatch("(|H1:achievement:%d+:%d+:%d+|h|h)") do
        table.insert(GF.extractedLinks, link)
    end
    return GF.extractedLinks
end

function GF.ShowContextMenu(row)
    ClearMenu()
    
    if not row.sessionId then return end
	
	local sessionId = row.sessionId
    local leaderDisplayName = row.leaderDisplayName

    AddCustomMenuItem("Apply to Group", function()
        local currentIndex = GF.GetCurrentIndexBySessionId(sessionId)
        if currentIndex then
            RequestApplyToGroupListing(currentIndex)
        else
            GF.Popup("That group listing is no longer available!", nil, "FFA500")
        end
    end)

    AddCustomMenuItem("Whisper Leader", function()
        local currentIndex = GF.GetCurrentIndexBySessionId(sessionId)
        if currentIndex and GF.listings[currentIndex] then
            StartChatInput("/w " .. GF.listings[currentIndex].leaderDisplayName .. " ")
        end
    end)

    -- Use cached title/desc from row
    ZO_ClearNumericallyIndexedTable(GF.achievementLinks)
    ZO_ClearTable(GF.seenLinks)
    local achievementLinks = GF.achievementLinks
    local seenLinks = GF.seenLinks

    for _, link in ipairs(GF.ExtractAchievementLinks(row.title)) do
        if not seenLinks[link] then
            table.insert(achievementLinks, link)
            seenLinks[link] = true
        end
    end
    for _, link in ipairs(GF.ExtractAchievementLinks(row.desc)) do
        if not seenLinks[link] then
            table.insert(achievementLinks, link)
            seenLinks[link] = true
        end
    end

    for _, link in ipairs(achievementLinks) do
        local achievementId = GetAchievementIdFromLink(link)
        if achievementId then
            local myLink = GetAchievementLink(achievementId)
            if myLink then
                AddCustomMenuItem(myLink, function()
                    ZO_LinkHandler_OnLinkClicked(myLink, 1, nil)
                end)
            end
        end
    end
	
    AddCustomMenuItem("Hide This Listing (Session)", function()
        GF.hiddenListings[sessionId] = true
        GF.RefreshUI()
    end)
    
	AddCustomMenuItem("Blacklist " .. leaderDisplayName, function()
		local dialogParams = {
			callback = function()
				GF.BlacklistLeader(leaderDisplayName)
				GF.Popup("Blacklisted " .. leaderDisplayName, nil, "FFA500")
			end,
			mainText = string.format("Are you sure you want to blacklist |cFFC500%s|r?\n\nAll listings from this player will be hidden from the group finder.", leaderDisplayName)
		}
		ZO_Dialogs_ShowDialog("GF_BLACKLIST_CONFIRMATION_DIALOG", dialogParams)
	end)

    ShowMenu(row)
end

function GF.MasterSwitchHostingCheck()
    if not GF.fragment then return end

    local hosting = GetCurrentGroupFinderUserType() == 1
    local inBattleground = IsActiveWorldBattleground()
    local inInstance = GF.IsInstanced == true
    local lowLevel = GF.playerLevel and GF.playerLevel < 10
    
    local shouldHide = hosting or inBattleground or inInstance or lowLevel

    local sceneObj = SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene()
    if not sceneObj then return end

    local currentScene = sceneObj:GetName()

    local allowedScenes = {
        [HUD_SCENE.name] = true,
        [HUD_UI_SCENE.name] = true,
    }

    local sceneAllowsFragment = allowedScenes[currentScene] == true
    
    if not shouldHide and sceneAllowsFragment then
        local showFragment = not GF.Settings.isHidden
        local fragmentShowing = GF.fragment:IsShowing() and true or false
        
        if showFragment ~= fragmentShowing then
            if showFragment then
                HUD_SCENE:AddFragment(GF.fragment)
                HUD_UI_SCENE:AddFragment(GF.fragment)
                GF.fragment:Show(true)
            else
                HUD_SCENE:RemoveFragment(GF.fragment)
                HUD_UI_SCENE:RemoveFragment(GF.fragment)
            end
        end
    elseif shouldHide then
        if GF.fragment:IsShowing() then
            HUD_SCENE:RemoveFragment(GF.fragment)
            HUD_UI_SCENE:RemoveFragment(GF.fragment)
        end
    end
    
    GF.isMasterHidden = shouldHide
    
    if GF.topButton then
        GF.topButton:SetHidden(shouldHide or GF.Settings.isHidden)
    end
end

-- =========================================================
-- Events
-- =========================================================

function GF.OnSearchComplete(_, result)
    if result ~= GROUP_FINDER_ACTION_RESULT_SUCCESS then return end

    if GF.currentCategory ~= GF.lastSearchCategory then
        return
    end

    GF.BuildListings()
    GF.RefreshUI()

    if GF.firstSearchAfterCategoryChange then
        GF.SetEmptyIconSearching(false)
    end

    GF.firstSearchAfterCategoryChange = false
end


function GF.OnCooldownUpdate(_, cooldownRemaining)
    if cooldownRemaining == 0 then
        GF.RequestCurrentCategorySearch()
    end
end

function GF.RegisterEvents()
    EM:RegisterForEvent(GF.name, EVENT_GROUP_FINDER_SEARCH_COMPLETE,
        function(...) GF.OnSearchComplete(...) end)
    EM:RegisterForEvent(GF.name, EVENT_GROUP_FINDER_COOLDOWN_UPDATE,
        function(...) GF.OnCooldownUpdate(...) end)
end

function GF.RequestCurrentCategorySearch()
    if not IsGroupFinderSearchOnCooldown() then
        GF.lastSearchCategory = GF.currentCategory
        RequestGroupFinderSearch()
    end
end

function GF.InstanceCheck()
  if (not IsPlayerInRaid() and not IsUnitInDungeon("player")) or IsInAdventureZone() then 
      GF.IsInstanced = false  
  else	  
      GF.IsInstanced = true
  end
end

function GF.levelCheck()
      GF.playerLevel = GetUnitLevel("player")	  
end

function GF.EventZoneCheck()
    local wasEventZone = GF.eventZone
    if IsAdventureZoneActive() then
        GF.eventZone = true
    else
        GF.eventZone = false
    end
    
    if wasEventZone ~= GF.eventZone then
        GF.Categories = GF.BuildCategories()
        GF.RefreshUI()
    end
end

-- =========================================================
-- Initialization
-- =========================================================
function GF.Initialize()
    GF.Settings = ZO_SavedVars:NewAccountWide("GroupFinderPlus_SavedVariables", 1, nil, defaultSV)
	
	for i, cat in ipairs(GF.Categories) do
		if GF.Settings.SaveLastCategory and cat.id == GF.Settings.LastCategory then
			GF.currentCategoryIndex = i
			GF.currentCategory = cat.id
			break
		end
	end
	
    GF.primaryOptionIndex = GF.Settings.PrimaryOptionIndex
    GF.RegisterLAMPanel()
	GF.RegisterBlacklistDialog()
    GF.AllowAllRoles()
    GF.CreateWindow()
    GF.RefreshUI()
    GF.RegisterEvents()
	GF.EventZoneCheck()

    	
	GF.FixAchievements()
    
    GF.isMasterHidden = false
    GF.win:SetHidden(GF.Settings.isHidden)
	
	GF.firstSearchAfterCategoryChange = true
    GF.SetEmptyIconSearching(true)
	
	EM:RegisterForEvent(GF.name .. "_EventZone", EVENT_PLAYER_ACTIVATED, GF.EventZoneCheck)
	
	EM:RegisterForEvent(GF.name .. "_LevelCheck", EVENT_PLAYER_ACTIVATED, function()
	    EM:UnregisterForEvent(GF.name .. "_LevelCheck", EVENT_PLAYER_ACTIVATED)
	    GF.levelCheck()		
		EM:RegisterForEvent(GF.name, EVENT_LEVEL_UPDATE, GF.levelCheck)
	end)
	
	EM:RegisterForEvent(GF.name .. "_InstanceInitCheck", EVENT_PLAYER_ACTIVATED, function()
	    EM:UnregisterForEvent(GF.name .. "_InstanceInitCheck", EVENT_PLAYER_ACTIVATED)
		
        if GF.Settings.HideInInstance then
	          GF.InstanceCheck()		 
			  EM:RegisterForEvent(GF.name .. "_InstanceCheck", EVENT_PLAYER_ACTIVATED, GF.InstanceCheck)
	    end
	end)

    EM:RegisterForEvent(GF.name .. "_CP", EVENT_PLAYER_ACTIVATED, function()
	    GF.championPoints = GetUnitChampionPoints("player")
    end)	
	
	EM:RegisterForEvent(GF.name .. "_Init", EVENT_PLAYER_ACTIVATED, function()
	  EM:UnregisterForEvent(GF.name .. "_Init", EVENT_PLAYER_ACTIVATED)
		EM:RegisterForUpdate(GF.name .. "AutoRefresh", 1000, function()
			GF.MasterSwitchHostingCheck()
			
			if GF.win and not GF.win:IsHidden() and not IsGroupFinderSearchOnCooldown() then
				if GF.Settings.AllowAllRoles then
					SetGroupFinderFilterEnforceRoles(false)
				end
				
				GF.ApplyCategory()
				
				if GF.CategoriesWithPrefix[GF.currentCategory] then
					SetGroupFinderFilterPrimaryOptionByIndex(GF.Settings.PrimaryOptionIndex, true)
					GF.primaryOptionIndex = GF.Settings.PrimaryOptionIndex
				end
				
				GF.UpdatePrimaryButtonVisibility()
				GF.RequestCurrentCategorySearch()
			end
		end)
	end)
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= GF.name then return end
    EM:UnregisterForEvent(GF.name, EVENT_ADD_ON_LOADED)
    GF.Initialize()
end

EM:RegisterForEvent(GF.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
