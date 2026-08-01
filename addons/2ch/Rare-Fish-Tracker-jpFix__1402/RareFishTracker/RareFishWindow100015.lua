local wm = GetWindowManager()
if RFT == nil then RFT = { } end

local RFT = RFT

RFT.KatKat42Colors = {
	ZO_ColorDef:New(.3,.5,.3,1),
	ZO_ColorDef:New(.6,1,.6,1),
	ZO_ColorDef:New(.25,.25,0.5,1),
	ZO_ColorDef:New(.5,.5,1,1),
	ZO_ColorDef:New(.5,.25,0.5,1),
	ZO_ColorDef:New(1,.5,1,1),
}
RFT.KatKat42Default = ZO_ColorDef:New(.9, .9, .7, 1)
RFT.KatKat42Highlight = ZO_ColorDef:New(.8, .8, 1, 1)
RFT.ESODefault = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
RFT.ESOHighlight = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_GENERAL, INTERFACE_GENERAL_COLOR_ENABLED))

function RFT:RestorePosition()
	local x, y = self.window:GetLeft(), self.window:GetTop()

	if WORLD_MAP_SCENE:IsShowing() then
		x, y = self.settings.x_world - x, self.settings.y_world - y
	else
		x, y = self.settings.x - x, self.settings.y - y
	end
	local slide = self.window.slide
	slide:SetDeltaOffsetX(x)
	slide:SetDeltaOffsetY(y)
	self.window.slideAmin:PlayFromStart()
end

function RFT:SetIsFishing(isFishing)
	self.isFishing = isFishing
	RARE_FISH_TRACKER_FRAGMENT:Refresh(500, 500)
end

local function IsScreenRightHalf(sender)
	local x = GuiRoot:GetCenter()
	return sender:GetLeft() > x
end

local function IsScreenLowerHalf(sender)
	local _, y = GuiRoot:GetCenter()
	return sender:GetTop() > y
end

function RFT.ShowTooltip(resultButton, state)
	if state and resultButton.itemId then
		local itemLink = resultButton.itemLink
		if not itemLink then
			itemLink = string.format("|H1:item:%i:27:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0|h|h", resultButton.itemId)
			resultButton.itemLink = itemLink
		end

		if IsScreenRightHalf(resultButton) then
			if IsScreenLowerHalf(resultButton) then
				InitializeTooltip(ItemTooltip, resultButton, TOPRIGHT, 0, 0, BOTTOMLEFT)
			else
				InitializeTooltip(ItemTooltip, resultButton, TOPRIGHT, 0, 0, TOPLEFT)
			end
		else
			if IsScreenLowerHalf(resultButton) then
				InitializeTooltip(ItemTooltip, resultButton, BOTTOMLEFT, 0, 0, TOPRIGHT)
			else
				InitializeTooltip(ItemTooltip, resultButton, TOPLEFT, 0, 0, TOPRIGHT)
			end
		end
		ItemTooltip:SetLink(itemLink)
	else
		ClearTooltip(ItemTooltip)
	end
end

function RFT.MakeWindow()
	local function SetupWaterType(control)
		control:SetExcludeFromResizeToFitExtents(true)
		control:SetAnchorFill()
		control:SetCenterColor(0, 0, 0, RFT.settings.waterTypeAlpha / 100)
		control:SetEdgeColor(0, 0, 0, RFT.settings.waterTypeAlpha / 100)
		control:SetEdgeTexture("/esoui/art/chatwindow/textentry_edge.dds", 64, 8, 32)
		control:SetCenterTexture("/esoui/art/chatwindow/textentry_center.dds")
		control:SetInsets(32, 32, -32, -32)
	end

	local smallFont = "EsoUI/Common/Fonts/ESO_FWUDC_70-M.ttf|14|soft-shadow-thin"
	local mediumFont = "EsoUI/Common/Fonts/ESO_FWUDC_70-M.ttf|16|soft-shadow-thin"

	local function LabelFactory(pool)
		local id = pool:GetNextControlId()
		local lastControl = pool.parent:GetChild(pool.parent:GetNumChildren()) or pool.parent
		local label = wm:CreateControl("$(parent)Label" .. id, pool.parent, CT_LABEL)
		label:SetFont(smallFont)
		label:SetStyleColor(0, 0, 0, 1)
		label:SetAnchor(TOP, lastControl, BOTTOM, 0, 5)
		label:SetHandler("OnMouseEnter", function(sender) RFT.ShowTooltip(sender, true) end)
		label:SetHandler("OnMouseExit", function(sender) RFT.ShowTooltip(sender, false) end)

		return label
	end

	-- our primary window
	RFT.window = wm:CreateTopLevelWindow("RareFishTracker")
	local rft = RFT.window
	rft:SetHidden(true)
	rft:SetMovable(true)
	rft:SetMouseEnabled(true)
	rft:SetClampedToScreen(true)
	rft:SetClampedToScreenInsets(16, 0, -16, 0)
	rft:SetDimensions(0, 0)
	rft:SetResizeToFitDescendents(true)
	rft:SetHandler("OnMoveStop", function()
		if WORLD_MAP_SCENE:IsShowing() then
			RFT.settings.x_world = rft:GetLeft()
			RFT.settings.y_world = rft:GetTop()
		else
			RFT.settings.x = rft:GetLeft()
			RFT.settings.y = rft:GetTop()
		end
	end )
	rft:SetDrawLayer(DL_TEXT)
	local am = GetAnimationManager()
	rft.slideAmin = am:CreateTimelineFromVirtual("ZO_LootSlideInAnimation", rft)
	rft.slide = rft.slideAmin:GetFirstAnimation()
	rft:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RFT.settings.x, RFT.settings.y)
	RFT:RestorePosition()

	-- give it a backdrop
	rft.bg = wm:CreateControl("RFTBackground", rft, CT_BACKDROP)
	rft.bg:SetAnchorFill(rft)
	rft.bg:SetCenterColor(0, 0, 0, RFT.settings.alpha / 100)
	rft.bg:SetEdgeColor(0, 0, 0, RFT.settings.alpha / 100)
	-- rft.bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 128, 16)
	-- rft.bg:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
	rft.bg:SetInsets(16, 16, -16, -16)
	rft.bg:SetExcludeFromResizeToFitExtents(true)
	-- rft.bg:SetDrawLayer(DL_TEXT)

	rft.bgtex = wm:CreateControl("RFTBackgroundoverlay", rft.bg, CT_TEXTURE)
	rft.bgtex:SetTexture("/esoui/art/tooltips/munge_overlay.dds")
	rft.bgtex:SetAlpha(RFT.settings.alpha / 100)
	rft.bgtex:SetAnchor(TOPLEFT, rft.bg, TOPLEFT, 8, 8)
	rft.bgtex:SetAnchor(BOTTOMRIGHT, rft.bg, BOTTOMRIGHT, -8, -8)
	rft.bgtex:SetDrawLayer(DL_BACKGROUND)

	-- give it a header
	rft.title = wm:CreateControl("RFTTitle", rft, CT_LABEL)
	rft.title:SetAnchor(TOP, rft, TOP, 0, 5)
	rft.title:SetFont("EsoUI/Common/Fonts/ESO_FWUDC_70-M.ttf|18|soft-shadow-thin")
	rft.title:SetStyleColor(0, 0, 0, 1)
	rft.title:SetText("Rare Fish Tracker")
	rft.title:SetHidden(not RFT.settings.showtitle)

	-- Give it a zone label
	rft.zone = wm:CreateControl("RFTZone", rft, CT_LABEL)
	if (RFT.settings.showtitle) then
		rft.zone:SetAnchor(TOP, rft.title, BOTTOM, 0, 5)
	else
		rft.zone:SetAnchor(TOP, rft, TOP, 0, 5)
	end
	rft.zone:SetFont("EsoUI/Common/Fonts/ESO_FWUDC_70-M.ttf|17|soft-shadow-thin")
	rft.zone:SetStyleColor(0, 0, 0, 1)
	rft.zone:SetText("Zone Name")

	-- make a container for the list entries
	rft.entries = wm:CreateControl("RFTEntries", rft, CT_CONTROL)
	-- rft.entries = wm:CreateControl("RFTEntries", rft, CT_TEXTURE)
	rft.entries:SetAnchor(TOP, rft.zone, BOTTOM, 0, 0)
	-- rft.entries:SetTexture([[/esoui/art/buttons/swatchframe_up.dds]])
	rft.entries:SetHidden(false)
	rft.entries:SetResizeToFitDescendents(true)

	-- make sub-containers for each water type
	-- Ocean fish
	rft.entries.ocean = wm:CreateControl("RFTOcean", rft.entries, CT_CONTROL)
	rft.entries.ocean:SetAnchor(TOPLEFT, rft.entries, TOPLEFT, 0, 0)
	rft.entries.ocean:SetHidden(false)
	rft.entries.ocean:SetResizeToFitDescendents(true)
	rft.entries.ocean:SetResizeToFitPadding(2, 0)

	rft.entries.ocean.bd = wm:CreateControl("$(parent)BD", rft.entries.ocean, CT_BACKDROP)
	SetupWaterType(rft.entries.ocean.bd)

	rft.entries.ocean.label = wm:CreateControl("RFTOceanLabel", rft.entries.ocean, CT_LABEL)
	rft.entries.ocean.label:SetAnchor(TOP, rft.entries.ocean, TOP, 0, 0)
	rft.entries.ocean.label:SetFont(mediumFont)
	rft.entries.ocean.label:SetStyleColor(0, 0, 0, 1)
	rft.entries.ocean.label:SetText("Ocean")

	-- lake fish
	rft.entries.lake = wm:CreateControl("RFTLake", rft.entries, CT_CONTROL)
	rft.entries.lake:SetAnchor(TOPLEFT, rft.entries.ocean, TOPRIGHT, 5, 0)
	rft.entries.lake:SetHidden(false)
	rft.entries.lake:SetResizeToFitDescendents(true)
	rft.entries.lake:SetResizeToFitPadding(2, 0)

	rft.entries.lake.bd = wm:CreateControl("$(parent)BD", rft.entries.lake, CT_BACKDROP)
	SetupWaterType(rft.entries.lake.bd)

	rft.entries.lake.label = wm:CreateControl("RFTLakeLabel", rft.entries.lake, CT_LABEL)
	rft.entries.lake.label:SetAnchor(TOP, rft.entries.lake, TOP, 0, 0)
	rft.entries.lake.label:SetFont(mediumFont)
	rft.entries.lake.label:SetStyleColor(0, 0, 0, 1)
	rft.entries.lake.label:SetText("Lake")

	-- river fish
	rft.entries.river = wm:CreateControl("RFTRiver", rft.entries, CT_CONTROL)
	rft.entries.river:SetAnchor(TOPLEFT, rft.entries.lake, TOPRIGHT, 5, 0)
	rft.entries.river:SetHidden(false)
	rft.entries.river:SetResizeToFitDescendents(true)
	rft.entries.river:SetResizeToFitPadding(2, 0)

	rft.entries.river.bd = wm:CreateControl("$(parent)BD", rft.entries.river, CT_BACKDROP)
	SetupWaterType(rft.entries.river.bd)

	rft.entries.river.label = wm:CreateControl("RFTRiverLabel", rft.entries.river, CT_LABEL)
	rft.entries.river.label:SetAnchor(TOP, rft.entries.river, TOP, 0, 0)
	rft.entries.river.label:SetFont(mediumFont)
	rft.entries.river.label:SetStyleColor(0, 0, 0, 1)
	rft.entries.river.label:SetText("River")

	-- foul water fish
	rft.entries.foul = wm:CreateControl("RFTFoul", rft.entries, CT_CONTROL)
	rft.entries.foul:SetAnchor(TOPLEFT, rft.entries.river, TOPRIGHT, 5, 0)
	rft.entries.foul:SetHidden(false)
	rft.entries.foul:SetResizeToFitDescendents(true)

	rft.entries.foul.bd = wm:CreateControl("$(parent)BD", rft.entries.foul, CT_BACKDROP)
	SetupWaterType(rft.entries.foul.bd)

	rft.entries.foul.label = wm:CreateControl("RFTFoulLabel", rft.entries.foul, CT_LABEL)
	rft.entries.foul.label:SetAnchor(TOP, rft.entries.foul, TOP, 0, 0)
	rft.entries.foul.label:SetFont(mediumFont)
	rft.entries.foul.label:SetStyleColor(0, 0, 0, 1)
	rft.entries.foul.label:SetText("Foul")

	-- add a bit of padding
	rft:SetResizeToFitPadding(30, 30)

	rft.column1 = ZO_ObjectPool:New(LabelFactory)
	rft.column1.parent = rft.entries.ocean
	rft.column2 = ZO_ObjectPool:New(LabelFactory)
	rft.column2.parent = rft.entries.lake
	rft.column3 = ZO_ObjectPool:New(LabelFactory)
	rft.column3.parent = rft.entries.river
	rft.column4 = ZO_ObjectPool:New(LabelFactory)
	rft.column4.parent = rft.entries.foul

	RFT.columns = { rft.entries.ocean, rft.entries.lake, rft.entries.river, rft.entries.foul }

	RARE_FISH_TRACKER_FRAGMENT = ZO_HUDFadeSceneFragment:New(rft, 500, 0)
	RARE_FISH_TRACKER_FRAGMENT:SetConditional( function()
		if WORLD_MAP_SCENE:IsShowing() then
			if RFT.isAutoRefresh and RFT.numFishes == 0 then return false end
			return RFT.settings.shown_world
		else
			if IsUnitInCombat("player") then return false end
			if RFT.isFishing then return true end
			if RFT.isAutoRefresh and RFT.settings.autoShowHide then return(RFT.numFishes or 0) > 0 and not(RFT.numCaught == RFT.numFishes) end
			return RFT.settings.shown
		end
	end )
	WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		-- If window is visible in both scenes, the state does not change => RestorePosition only
		if newState == SCENE_FRAGMENT_SHOWING then
			if RFT.settings.shown_world and not RFT.window:IsHidden() then RFT:RestorePosition() end
			RARE_FISH_TRACKER_FRAGMENT:Refresh()
		elseif newState == SCENE_FRAGMENT_HIDING then
			if (RFT.settings.shown or RFT.isFishing) and not RFT.window:IsHidden() then RFT:RestorePosition() end
		elseif newState == SCENE_FRAGMENT_HIDDEN then
			if not RFT.window:IsHidden() then RFT:RestorePosition() end
			RFT.RefreshWindowForZone(GetZoneId(GetUnitZoneIndex('player')))
		end
	end )
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function(navigateIn)
		if WORLD_MAP_FRAGMENT:IsShowing() then
			if navigateIn then
				-- from Cyrodiil down to IC?
				if GetCurrentMapIndex() == nil then return end
			end
			RFT.RefreshWindowForZone(GetZoneId(GetCurrentMapZoneIndex()))
		else
			RFT.RefreshWindowForZone(GetZoneId(GetUnitZoneIndex('player')))
		end
	end )
	RARE_FISH_TRACKER_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWING then RFT:RestorePosition() end
	end )
	EVENT_MANAGER:RegisterForEvent("RareFishTracker", EVENT_PLAYER_COMBAT_STATE, function() RARE_FISH_TRACKER_FRAGMENT:Refresh() end)

	HUD_SCENE:AddFragment(RARE_FISH_TRACKER_FRAGMENT)
	HUD_UI_SCENE:AddFragment(RARE_FISH_TRACKER_FRAGMENT)
	LOOT_SCENE:AddFragment(RARE_FISH_TRACKER_FRAGMENT)
	WORLD_MAP_SCENE:AddFragment(RARE_FISH_TRACKER_FRAGMENT)

	RFT.MakeOrders()

	local colors = { }
	local function MakeColors(quality)
		local r, g, b = GetItemQualityColor(quality):UnpackRGB()
		colors[#colors + 1] = ZO_ColorDef:New(r * 0.5625, g * 0.5625, b * 0.5625)
		colors[#colors + 1] = ZO_ColorDef:New(r * 1.05, g * 1.05, b * 1.05)
	end
	MakeColors(ITEM_QUALITY_MAGIC)
	MakeColors(ITEM_QUALITY_ARCANE)
	MakeColors(ITEM_QUALITY_ARTIFACT)
	-- MakeColors(ITEM_QUALITY_LEGENDARY)
	colors[7] = RFT.KatKat42Colors[7]
	colors[8] = RFT.KatKat42Colors[8]
	RFT.ESOColors = colors
end

function RFT.PopulateWindowForAchievement(achievement)
	-- local lowAlpha = 0.4
	-- local highAlpha = 1

	local disp = RFT.settings.highlight == "Caught" or false
	local numFishes = NonContiguousCount(RFT.progress[achievement])

	local numCaught = 0
	if numFishes > 0 then
		-- 0 = default fish order/quality
		local fishorder = RFT.orders[achievement] or RFT.orders[0]
		local fishquality = RFT.quality[achievement] or RFT.quality[0]
		local function AddColumn(k, v)
			local label = fishorder[k]:AcquireObject()
			label:SetHidden(false)
			label:SetText(zo_strformat(SI_TOOLTIP_ITEM_NAME, v))
			label.itemId = RFT.achievementToItem[achievement][k]
			label.itemLink = nil
			label:SetMouseEnabled(label.itemId ~= nil)

			local colorType =(fishquality[k] - ITEM_QUALITY_MAGIC) * 2 + 1
			local caught = RFT.progress[achievement][v] == 1 or false
			if caught then numCaught = numCaught + 1 end
			-- WHY does lua not have an xor operator?!?!
			if (caught or disp) and not(caught and disp) then
				label:SetColor(RFT.Colors[colorType]:UnpackRGB())
			else
				label:SetColor(RFT.Colors[colorType + 1]:UnpackRGB())
			end
		end
		local fishes = RFT.fishnames[achievement]
		for k, v in ipairs(fishes) do
			if (fishquality[k] == ITEM_QUALITY_ARCANE) then AddColumn(k, v) end
		end
		for k, v in ipairs(fishes) do
			if (fishquality[k] == ITEM_QUALITY_MAGIC) then AddColumn(k, v) end
		end
		for k, v in ipairs(fishes) do
			if (fishquality[k] == ITEM_QUALITY_ARTIFACT) then AddColumn(k, v) end
		end
	else
		-- sub zones like dungeons
		numFishes = 0
	end
	return numCaught, numFishes
end

function RFT.PopulateWindow(zone, achievements)
	if RFT.window == nil then RFT.MakeWindow() end

	local rft = RFT.window

	zone = RFT.common.subzoneToZone[zone] or zone

	rft.zone:SetText(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetZoneNameByIndex(GetZoneIndex(zone))))

	rft.column1:ReleaseAllObjects()
	rft.column2:ReleaseAllObjects()
	rft.column3:ReleaseAllObjects()
	rft.column4:ReleaseAllObjects()

	local title, head
	if RFT.settings.useDefaultColors then
		RFT.Colors = RFT.ESOColors
		title = RFT.ESODefault
		head = RFT.ESOHighlight
	else
		RFT.Colors = RFT.KatKat42Colors
		title = RFT.KatKat42Default
		head = RFT.KatKat42Highlight
	end
	rft.title:SetColor(title:UnpackRGB())
	rft.zone:SetColor(title:UnpackRGB())
	rft.entries.ocean.label:SetColor(head:UnpackRGB())
	rft.entries.lake.label:SetColor(head:UnpackRGB())
	rft.entries.river.label:SetColor(head:UnpackRGB())
	rft.entries.foul.label:SetColor(head:UnpackRGB())

	local numCaught, numFishes = 0, 0
	if achievements ~= 0 then
		local caught, fishes
		for i = 1, #achievements do
			caught, fishes = RFT.PopulateWindowForAchievement(achievements[i])
			numCaught, numFishes = numCaught + caught, numFishes + fishes
		end

		local types = RFT.types[zone] or RFT.types[0]
		local column, waterType
		for i = 1, #RFT.columns do
			column, waterType = RFT.columns[i], types[i]
			column:SetHidden(waterType == nil)
			column:GetNamedChild("Label"):SetText(GetString(waterType))
		end
	else
		for i = 1, #RFT.columns do
			RFT.columns[i]:SetHidden(true)
		end
	end

	RFT.window.bgtex:SetHidden(not RFT.settings.showMunge)
	if RFT.settings.showMunge then
		rft.bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 128, 16)
		rft.bg:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
	else
		rft.bg:SetEdgeTexture(nil, 2, 2, 16)
		rft.bg:SetCenterTexture(nil)
	end
	return numCaught, numFishes
end

function RFT.ToggleWindow()
	if WINDOW_MANAGER:IsSecureRenderModeEnabled() then
		RARE_FISH_TRACKER_FRAGMENT:Refresh(500, 0)
		return
	end

	local ishidden = RFT.window:IsHidden()
	local shouldBeHidden = RFT.numFishes == RFT.numCaught
	RFT.isAutoRefresh = not(RFT.settings.autoShowHide and shouldBeHidden == ishidden)
	-- refresh the window if we're about to show it
	if ishidden then RFT.RefreshWindow() end
	if not RFT.settings.autoShowHide or not RFT.isAutoRefresh then
		if WORLD_MAP_SCENE:IsShowing() then
			RFT.settings.shown_world = ishidden
		else
			RFT.settings.shown = ishidden
		end
	end
	RARE_FISH_TRACKER_FRAGMENT:Refresh(500, 500)
end
