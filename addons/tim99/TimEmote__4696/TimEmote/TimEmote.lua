------------------------------------------
--           TimEmote Extended           --
--       by Rosie & Khrill & tim99       --
--                                      --
--                 v 3                 --
------------------------------------------

TimEmote = TimEmote or {}
local TE = TimEmote
TE.ADDON_NAME   = "TimEmote"
TE.DISPLAY_NAME = "Tim|cB70E99Emote|r"
TE.VERSION      = "3"
TE.default		= {
	anchor 		= {TOPLEFT, TOPLEFT, 100, 100},
	nbEmote 	= 0,
	nbRow		= 20,
	fav			= {[1]= {}},
	group		= {[1]= "favorite"},
	movable		= true,
	fontSize	= 15,
	contrast	= 0.40,
	color		= {},
}
TE.locale = nil
TE.nbEmote = 0
TE.nbRow = 20
TE.fav = nil
TE.orderFav = {}
TE.group = nil
TE.selGroup = 1
TE.MAX_GROUPS = 9
TE.showList = false
TE.movable = true
TE.color = {}
TE.fontColor = {
			{0.77,0.76,0.62,1},	-- default 
			{0.39,0.75,0.29,1},	-- green
			{0.59,0.47,0.86,1}, -- purple
			{0.83,0.62,0.37,1},	-- orange
			{0.86,0.47,0.70,1}, -- pink
			{0.86,0.47,0.47,1}, -- red
			{0.47,0.68,0.86,1}	-- blue
}
TE.maxColor = #TE.fontColor
TE.sliderOffset = 0
TE.alphaList = {}
TE.emoteIndexById = {}
TE.alphaIndexById = {}
TE.tex = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
TE.SIZE_PRESETS = {
	[14] = {
		buttonWidth = 160,
		buttonHeight = 25,
		fontSize = 14,
	},
	[15] = {
		buttonWidth = 168,
		buttonHeight = 26,
		fontSize = 15,
	},
	[16] = {
		buttonWidth = 180,
		buttonHeight = 28,
		fontSize = 16,
	},
}

TE.GROUP_SPACING = 0
TE.FONT_SIZE = 15
TE.BUTTON_WIDTH = 168
TE.BUTTON_HEIGHT = 26
TE.xOffset = {
	up = 0,
	down = 0,
	Fav = 0,
	Panel = 10 + TE.BUTTON_WIDTH + TE.GROUP_SPACING,
}
TE.yOffset = {up = 0, down = 0, Fav = -5, Panel = 0 }

local COLOR_KHRILLSELECT = "FF6A00" -- orange ^^

local function GetEmoteFont()
	if TE.FONT_SIZE == 14 then
		return "ZoFontGameSmall"
	elseif TE.FONT_SIZE == 15 then
		return "$(BOLD_FONT)|15|soft-shadow-thick"
	end

	return "$(BOLD_FONT)|16|soft-shadow-thick"
end
-----------------------------------------------------------------------------------------------------------------

local function SetButtonContrast(button, alpha)
	if not button then
		return
	end

	local contrastTexture = button:GetNamedChild("Contrast")
	if contrastTexture then
		contrastTexture:SetAlpha(tonumber(alpha) or TE.default.contrast)
	end
end
-----------------------------------------------------------------------------------------------------------------
function TE.UpdateContrast(alpha)
	alpha = tonumber(alpha) or TE.default.contrast
	TE.vars.contrast = alpha

	SetButtonContrast(GetControl("TE_ShowListButton"), alpha)

	for rowIndex = 0, TE.nbRow - 1 do
		SetButtonContrast(
			GetControl("TE_EmoteButton" .. tostring(rowIndex)),
			alpha
		)
	end

	for groupIndex = 1, #TE.group do
		SetButtonContrast(
			GetControl("TE_FavPanel" .. groupIndex .. "GroupButton"),
			alpha
		)

		local groupFavs = TE.fav[groupIndex]
		for favIndex = 1, groupFavs and #groupFavs or 0 do
			SetButtonContrast(
				GetControl(
					"TE_FavPanel"
						.. groupIndex
						.. "FavList"
						.. favIndex
				),
				alpha
			)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------

local function ApplySizePreset(fontSize)
	local preset = TE.SIZE_PRESETS[tonumber(fontSize)] or TE.SIZE_PRESETS[15]

	TE.FONT_SIZE = preset.fontSize
	TE.BUTTON_WIDTH = preset.buttonWidth
	TE.BUTTON_HEIGHT = preset.buttonHeight

	-- The main list begins 10 px to the right of TimEmoteWindowLabel.
	-- Include that offset so the first group never overlaps the list.
	TE.xOffset.Panel = 10 + TE.BUTTON_WIDTH + TE.GROUP_SPACING
end

local function ShowControlTooltip(control, text)
	ZO_Tooltips_ShowTextTooltip(control, TOP, text)
end

local function HideControlTooltip()
	ZO_Tooltips_HideTextTooltip()
end

local function SetupRandomButtonTooltip(button)
	button:SetHandler("OnMouseEnter", function(control)
		ShowControlTooltip(control, TE.locale.Tooltip_playRandom)
	end)
	button:SetHandler("OnMouseExit", HideControlTooltip)
end
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
local function HexToRGBA( hex )
	if string.len(hex) == 6 then hex = hex.."FF" end
    local rhex, ghex, bhex, ahex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
    return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end
-----------------------------------------------------------------------------------------------------------------
local function sceneChange(oldState, newState)
    if newState == SCENE_SHOWN then
		TE.ShowUI(true)
		TimEmoteWindow:SetHidden(false)
	else
		TimEmoteWindow:SetHidden(true)
    end
end
-----------------------------------------------------------------------------------------------------------------
function TE.Random(group)
	-- play a random emote from choosen list
	local n = 0
	if group == 0 then --main list
		n = TE.nbEmote
	else --specific group
		if TE.fav[group] then
			n = #TE.fav[group]
		end
	end
	if n > 0 then
		local alea = math.random(1,n)
		if group ==0 then
			TE.PlayEmote(alea, 0) --emote from main list
		else
			TE.PlayEmote(TE.fav[group][alea].id, 1) -- emote from fav group
		end
	else
		-- no emote :s
		TE.Msg(TE.locale.Message_noEmote)
	end
end
-----------------------------------------------------------------------------------------------------------------
function TE.OnSliderMove(value)
	TE.sliderOffset = value
	TE.UpdateButton()
	TE.UpdateColor()
end
-----------------------------------------------------------------------------------------------------------------
function TE.OnMouseWheel(delta)
	local offset = TESlider:GetValue()
	offset = offset - delta
	if (offset < 0) then offset = 0 end
	if (offset > TE.nbEmote-TE.nbRow) then offset = TE.nbEmote-TE.nbRow end
	
	TE.sliderOffset = offset
	TESlider:SetValue(offset)
end
-----------------------------------------------------------------------------------------------------------------
 
--###  INIT/SAVE  ###--
-----------------------
function TE.SaveAnchor()
	local isValidAnchor, point, _, relativePoint, offsetX, offsetY = TimEmoteWindow:GetAnchor()

	if isValidAnchor then
		TE.vars.anchor = { point, relativePoint, offsetX, offsetY }
	else
		d("TimEmote - anchor not valid")
	end
end
-----------------------------------------------------------------------------------------------------------------
function TE.InitAlphaList()
	TE.alphaList = {}
	TE.emoteIndexById = {}
	TE.alphaIndexById = {}

	for emoteIndex = 1, GetNumEmotes() do
		local emoteId = select(3, GetEmoteInfo(emoteIndex))
		local slashName = GetEmoteSlashNameByIndex(emoteIndex)
		local collectibleId = GetEmoteCollectibleId(emoteIndex)
		local isUnlocked = not collectibleId or IsCollectibleUnlocked(collectibleId)

		if emoteId and isUnlocked then
			TE.emoteIndexById[emoteId] = emoteIndex
			table.insert(TE.alphaList, {
				id = emoteId,
				slashName = slashName or "",
			})
		end
	end

	table.sort(TE.alphaList, function(a, b)
		return a.slashName < b.slashName
	end)

	for alphaIndex, emoteData in ipairs(TE.alphaList) do
		TE.alphaIndexById[emoteData.id] = alphaIndex
	end
end
-----------------------------------------------------------------------------------------------------------------

function TE.UpdateEmote()
	TE.nbEmote = #TE.alphaList
	TE.vars.nbEmote = TE.nbEmote
end
-----------------------------------------------------------------------------------------------------------------
function TE.ToggleMovable(state)
	TE.movable = state
	TE.vars.movable = state
	TimEmoteWindow:SetMovable(state)
	return state
end
-----------------------------------------------------------------------------------------------------------------

--###  EMOTES  ###--
--------------------
function TE.ShowList()
	TE.showList = true
	TE_EmotePanel:SetHidden(false)
	GetControl("TE_ShowListButton"):SetText("|cB70E99" .. TE.locale.UI_list .. "|r")
end
-----------------------------------------------------------------------------------------------------------------
function TE.UpdateButton()
	-- init emote button of list
	for i= 1, TE.nbRow do
		local button = GetControl("TE_EmoteButton"..tostring(i-1))
				
		button:SetText(TE.GetEmoteSlashName(i,0))
	end	
end
-----------------------------------------------------------------------------------------------------------------
function TE.GetEmIndexFromEmListIndex(emListId)
	local emIndex = TE.sliderOffset + emListId
	
	return TE.alphaList[emIndex].id
	
end
-----------------------------------------------------------------------------------------------------------------
function TE.PlayEmote(emListId, list)
	local emoteId

	if list == 0 then
		emoteId = TE.GetEmIndexFromEmListIndex(emListId)
	else
		emoteId = emListId
	end

	local emoteIndex = TE.emoteIndexById[emoteId]
	if emoteIndex then
		PlayEmoteByIndex(emoteIndex)
	end
end
-----------------------------------------------------------------------------------------------------------------
function TE.GetEmoteSlashName(emListId, list)
	local emoteId

	if list == 0 then
		emoteId = TE.GetEmIndexFromEmListIndex(emListId)
	else
		emoteId = emListId
	end

	local emoteIndex = TE.emoteIndexById[emoteId]
	if not emoteIndex then
		return "|cFF0000* missing emote|r"
	end

	local slashName = GetEmoteSlashNameByIndex(emoteIndex)
	local collectibleId = GetEmoteCollectibleId(emoteIndex)

	if collectibleId and not IsCollectibleUnlocked(collectibleId) then
		return "|cFF0000##|r" .. tostring(slashName)
	end

	return tostring(slashName)
end
-----------------------------------------------------------------------------------------------------------------

--###  FAV  ###--
-----------------
function TE.ToggleOrderFav(button)
	-- Click on setting button
	local group = tonumber(string.sub(button:GetName(), 12, 12))
	if TE.orderFav[group] == nil then TE.orderFav[group] = false end
	
	TE.orderFav[group] = not TE.orderFav[group]
	TE.UpdateOrderFav(group)
end
-----------------------------------------------------------------------------------------------------------------
function TE.UpdateOrderFav(group)
	local groupFavs = TE.fav[group]
	local numFavs = groupFavs and #groupFavs or 0

	if numFavs == 0 then
		return
	end

	if TE.orderFav[group] then
		local favListControl = GetControl("TE_FavPanel" .. tostring(group) .. "FavList")

		for i = 1, numFavs do
			local currentGroup = group
			local currentIndex = i
			local favButton = GetControl("TE_FavPanel" .. currentGroup .. "FavList" .. currentIndex)

			local downButton = GetControl("TE_FavPanel" .. currentGroup .. "FavList" .. currentIndex .. "down")
			if not downButton then
				downButton = CreateControlFromVirtual(
					"TE_FavPanel" .. currentGroup .. "FavList",
					favListControl,
					"TE_DownButton",
					tostring(currentIndex) .. "down"
				)
				downButton:SetDrawLayer(DL_OVERLAY)
				downButton:SetDrawTier(DT_HIGH)
				downButton:SetDrawLevel(1)

				if currentIndex == 1 then
					_, _, _, _, TE.xOffset.down, TE.yOffset.down = downButton:GetAnchor()
				end
			end

			downButton:SetHandler("OnClicked", function()
				TE.FavDown(currentIndex, currentGroup)
			end)
			downButton:SetHandler("OnMouseEnter", function(control)
				ShowControlTooltip(control, TE.locale.Tooltip_moveDown)
			end)
			downButton:SetHandler("OnMouseExit", HideControlTooltip)

			downButton:ClearAnchors()
			downButton:SetNormalTexture("TimEmote/img/down_d.dds")
			downButton:SetPressedTexture("TimEmote/img/down.dds")
			downButton:SetAnchor(LEFT, favButton, RIGHT, -10, 1)
			downButton:SetHidden(currentIndex == numFavs)

			local upButton = GetControl("TE_FavPanel" .. currentGroup .. "FavList" .. currentIndex .. "up")
			if not upButton then
				upButton = CreateControlFromVirtual(
					"TE_FavPanel" .. currentGroup .. "FavList",
					favListControl,
					"TE_UpButton",
					tostring(currentIndex) .. "up"
				)
				upButton:SetDrawLayer(DL_OVERLAY)
				upButton:SetDrawTier(DT_HIGH)
				upButton:SetDrawLevel(1)

				if currentIndex == 1 then
					_, _, _, _, TE.xOffset.up, TE.yOffset.up = upButton:GetAnchor()
				end
			end

			upButton:SetHandler("OnClicked", function()
				TE.FavUp(currentIndex, currentGroup)
			end)
			upButton:SetHandler("OnMouseEnter", function(control)
				ShowControlTooltip(control, TE.locale.Tooltip_moveUp)
			end)
			upButton:SetHandler("OnMouseExit", HideControlTooltip)

			upButton:ClearAnchors()
			upButton:SetNormalTexture("TimEmote/img/up_d.dds")
			upButton:SetPressedTexture("TimEmote/img/up.dds")
			upButton:SetAnchor(LEFT, favButton, RIGHT, 7, 0)
			upButton:SetHidden(currentIndex == 1)
		end
	else
		for i = 1, numFavs do
			local prefix = "TE_FavPanel" .. tostring(group) .. "FavList" .. tostring(i)
			local upButton = GetControl(prefix .. "up")
			local downButton = GetControl(prefix .. "down")

			if upButton then upButton:SetHidden(true) end
			if downButton then downButton:SetHidden(true) end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------
function TE.FavUp(index, group)
	if index <= 1 then return end

	local groupFavs = TE.fav[group]
	groupFavs[index], groupFavs[index - 1] = groupFavs[index - 1], groupFavs[index]

	TE.vars.fav = TE.fav
	TE.UpdateFav(group)
	TE.UpdateOrderFav(group)
end
-----------------------------------------------------------------------------------------------------------------
function TE.FavDown(index, group)
	local groupFavs = TE.fav[group]
	if index >= #groupFavs then return end

	groupFavs[index], groupFavs[index + 1] = groupFavs[index + 1], groupFavs[index]

	TE.vars.fav = TE.fav
	TE.UpdateFav(group)
	TE.UpdateOrderFav(group)
end
-----------------------------------------------------------------------------------------------------------------
function TE.ToggleFav(fav, list)
	-- click on emote btn to add/remove fav
	local bFav = false
	local idFav = 0
	local emIndex = 0
	local group
	
	if list == 0 then -- from emote list
		emIndex = TE.GetEmIndexFromEmListIndex(fav)
		if TE.selGroup == nil then
			-- no selected group = cannot add item
			TE.Msg(TE.locale.Message_notSelGroup)
			return
		end
		group = TE.selGroup
	else -- from fav group
		emIndex = fav
		group = list
	end
	
	local n = 0
	if TE.fav[group] then n = #TE.fav[group] end
	for i=1, n do
		if (TE.fav[group][i].id == emIndex) then
			bFav = true
			idFav = i
			break
		end
	end

	if bFav then
		--d("already fav -> remove")
--		TE.ShowGroup(group, false)
		table.remove(TE.fav[group],idFav)
		TE.UpdateFav(group)
		TE.RemoveFavButton(n, group)
	else
		--d("not in fav -> add")
		if TE.fav[group] == nil then TE.fav[group] = {} end
		local color = TE.color[emIndex] or 0
		table.insert(TE.fav[group], { id = emIndex, color = color })
		--table.sort(TE.fav[group], function(a,b) return a[1] < b[1] end)
--		d(TE.fav[group])
		TE.UpdateFav(group)
	end
	
	TE.vars.fav = TE.fav
	if TE.orderFav[group] then
		TE.UpdateOrderFav(group)
	end
end
-----------------------------------------------------------------------------------------------------------------
function TE.UpdateFav(group)
	if group == nil then
		group = TE.selGroup
	end

	local groupFavs = TE.fav[group]
	local numFavs = groupFavs and #groupFavs or 0
	if numFavs == 0 then
		return
	end

	local favListControl = GetControl("TE_FavPanel" .. tostring(group) .. "FavList")
	-- The list container itself must not swallow mouse input intended for its buttons.
	favListControl:SetMouseEnabled(false)

	for i = 1, numFavs do
		local currentGroup = group
		local currentIndex = i
		local favData = groupFavs[currentIndex]
		local buttonName = "TE_FavPanel" .. currentGroup .. "FavList" .. currentIndex
		local buttonControl = GetControl(buttonName)

		if not buttonControl then
			buttonControl = CreateControlFromVirtual(
				"TE_FavPanel" .. currentGroup .. "FavList",
				favListControl,
				"TE_FavButton",
				tostring(currentIndex)
			)
			buttonControl:SetDrawLayer(DL_CONTROLS)
			buttonControl:SetDrawTier(DT_HIGH)
			buttonControl:SetDrawLevel(1)
		else
			buttonControl:SetHidden(false)
		end

		buttonControl:SetMouseEnabled(true)
		buttonControl:SetEnabled(true)
		buttonControl:SetDimensions(TE.BUTTON_WIDTH, TE.BUTTON_HEIGHT)
		buttonControl:SetDrawLayer(DL_CONTROLS)
		buttonControl:SetDrawTier(DT_HIGH)
		buttonControl:SetDrawLevel(1)

		-- OnMouseUp is used instead of OnClicked because these dynamically
		-- created buttons can otherwise lose their click behind the list panel.
		buttonControl:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
			if upInside == false then
				return
			end

			local currentFav = TE.fav[currentGroup] and TE.fav[currentGroup][currentIndex]
			if not currentFav then
				return
			end

			local emoteId = currentFav.id
			if mouseButton == MOUSE_BUTTON_INDEX_LEFT or mouseButton == 1 then
				if IsShiftKeyDown() then
					TE.ToggleFav(emoteId, currentGroup)
				else
					TE.PlayEmote(emoteId, 1)
				end
			end
		end)

		buttonControl:SetHandler("OnMouseDoubleClick", function(_, mouseButton)
			if mouseButton == 1 and TE.fav[currentGroup] and TE.fav[currentGroup][currentIndex] then
				TE.NextFavColor(currentIndex, currentGroup)
			end
		end)


		buttonControl:SetFont(GetEmoteFont())
		SetButtonContrast(buttonControl, TE.vars.contrast)
		buttonControl:SetText(TE.GetEmoteSlashName(favData.id, 1))

		favData.color = tonumber(favData.color) or 0
		local color = TE.GetColor(favData.color)
		buttonControl:SetNormalFontColor(color[1], color[2], color[3], color[4])
		buttonControl:SetMouseOverFontColor(color[1], color[2], color[3], color[4])
		buttonControl:SetPressedFontColor(color[1], color[2], color[3], color[4])

		local _, point, relativeTo, relativePoint = buttonControl:GetAnchor()
		buttonControl:ClearAnchors()

		buttonControl:SetAnchor(
			point,
			relativeTo,
			relativePoint,
			TE.xOffset.Fav,
			TE.yOffset.Fav + (currentIndex - 1) * TE.BUTTON_HEIGHT
		)
	end
end
-----------------------------------------------------------------------------------------------------------------
function TE.RemoveFavButton(fav, group)
	local buttonControl = GetControl("TE_FavPanel"..tostring(group).."FavList"..tostring(fav))
	if buttonControl ~= nil then buttonControl:SetHidden(true) end
end
-----------------------------------------------------------------------------------------------------------------

--###  GROUPS  ###--
--------------------
function TE.InitGroup()
	local numGroups = #TE.group
	local header = GetControl("TimEmoteHeader")

	if header then
		header:SetWidth(TE.BUTTON_WIDTH + numGroups * (TE.BUTTON_WIDTH + TE.GROUP_SPACING))
	end

	for group = 1, numGroups do
		local panelControl = GetControl("TE_FavPanel" .. group)

		if not panelControl then
			panelControl = CreateControlFromVirtual("TE_FavPanel", TimEmoteWindow, "TE_FavPanel", tostring(group))
			panelControl:SetDrawLayer(DL_BACKGROUND)
			panelControl:SetDrawTier(DT_LOW)
			panelControl:SetDrawLevel(0)
		end

		panelControl:SetMovable(false)
		panelControl:ClearAnchors()
		panelControl:SetAnchor(
			TOPLEFT,
			TimEmoteWindowLabel,
			TOPLEFT,
			TE.xOffset.Panel + (group - 1) * (TE.BUTTON_WIDTH + TE.GROUP_SPACING),
			TE.yOffset.Panel
		)

		local settingsButton = GetControl("TE_FavPanel" .. group .. "SettingsButton")
		settingsButton:SetHandler("OnClicked", TE.ToggleOrderFav)

		local groupButton = GetControl("TE_FavPanel" .. group .. "GroupButton")
		groupButton:SetDimensions(TE.BUTTON_WIDTH, 20)
		groupButton:SetFont("$(BOLD_FONT)|$(KB_15)|soft-shadow-thick")
		groupButton:SetHandler("OnClicked", function(control, mouseButton)
			if mouseButton == 1 then
				TE.ToggleGroup(control, 2)
			end
		end)
		groupButton:SetHandler("OnMouseEnter", function(control)
			ShowControlTooltip(control, TE.locale.Tooltip_groupHeader)
		end)
		groupButton:SetHandler("OnMouseExit", HideControlTooltip)

		local randomButton = GetControl("TE_FavPanel" .. group .. "RandomButton")
		randomButton:SetHandler("OnClicked", function()
			TE.Random(group)
		end)
		SetupRandomButtonTooltip(randomButton)

		groupButton:SetText(TE.group[group])
		panelControl:SetHidden(false)

		TE.UpdateFav(group)
		TE.ShowGroup(group, true)
	end
end
-----------------------------------------------------------------------------------------------------------------
function TE.ToggleGroup(button, value)
	local group

	if button then
		group = tonumber(string.sub(button:GetName(), 12, 12))
	else
		group = TE.selGroup
	end

	if not group then
		return
	end

	if value == 2 then
		if group == TE.selGroup then
			GetControl(
				"TE_FavPanel" .. group .. "GroupButton"
			):SetText(TE.group[group])
			TE.selGroup = nil
		else
			if TE.selGroup then
				GetControl(
					"TE_FavPanel" .. TE.selGroup .. "GroupButton"
				):SetText(TE.group[TE.selGroup])
			end

			GetControl(
				"TE_FavPanel" .. group .. "GroupButton"
			):SetText("|c" .. COLOR_KHRILLSELECT .. TE.group[group] .. "|r")

			TE.selGroup = group
		end
	end

	TE.ShowGroup(group, true)
end
-----------------------------------------------------------------------------------------------------------------
function TE.ShowGroup(group)
	group = group or TE.selGroup
	if not group then return end

	local panelControl = GetControl("TE_FavPanel" .. group)
	if not panelControl then
		return
	end

	local numFavs = TE.fav[group] and #TE.fav[group] or 0
	panelControl:SetHeight((numFavs + 2) * TE.BUTTON_HEIGHT + TE.yOffset.Fav)
	panelControl:SetWidth(TE.BUTTON_WIDTH + TE.GROUP_SPACING + TE.xOffset.Fav)
	panelControl:SetHidden(false)

	local groupButton = GetControl("TE_FavPanel" .. group .. "GroupButton")
	local listControl = GetControl("TE_FavPanel" .. group .. "FavList")
	listControl:ClearAnchors()
	listControl:SetAnchor(TOP, groupButton, BOTTOM, 0, 5)
	listControl:SetHeight(numFavs * TE.BUTTON_HEIGHT + TE.yOffset.Fav)
	listControl:SetWidth(TE.BUTTON_WIDTH + TE.GROUP_SPACING + TE.xOffset.Fav)
	listControl:SetHidden(false)

	GetControl("TE_FavPanel" .. group .. "SettingsButton"):SetHidden(false)
end
-----------------------------------------------------------------------------------------------------------------
function TE.AddGroup(group)
	TE.group[group] = TE.locale.Settings_groupNoname
	TE.fav[group] = TE.fav[group] or {}
	TE.vars.group = TE.group
	TE.vars.fav = TE.fav
	ReloadUI()
end
-----------------------------------------------------------------------------------------------------------------
function TE.RemoveGroup(group)
	if #TE.group <= 1 then
		TE.Msg(TE.locale.Message_lastGroup)
		return
	end

	table.remove(TE.group, group)
	table.remove(TE.fav, group)
	table.remove(TE.orderFav, group)

	if TE.selGroup == group then
		TE.selGroup = 1
	elseif TE.selGroup and TE.selGroup > group then
		TE.selGroup = TE.selGroup - 1
	end

	TE.vars.group = TE.group
	TE.vars.fav = TE.fav
	ReloadUI()
end
-----------------------------------------------------------------------------------------------------------------
function TE.UpdateGroup(group)
	if not group then
		for i = 1, #TE.group do
			TE.UpdateGroup(i)
		end
		return
	end

	local groupButton = GetControl("TE_FavPanel" .. group .. "GroupButton")
	if groupButton then
		groupButton:SetText(TE.group[group])
		groupButton:SetHidden(false)
	end
end
-----------------------------------------------------------------------------------------------------------------

--###  COLOR  ###--
--------------------

function TE.NormalizeColorData()
	local normalized = {}

	for key, value in pairs(TE.color or {}) do
		if type(value) == "table" then
			local emoteId = value[1]
			local colorId = value[2]
			if emoteId then
				normalized[emoteId] = colorId
			end
		elseif type(key) == "number" and type(value) == "number" then
			normalized[key] = value
		end
	end

	TE.color = normalized
	TE.vars.color = normalized
end
-----------------------------------------------------------------------------------------------------------------
function TE.GetColor(colorId)
	colorId = tonumber(colorId) or 0
	return TE.fontColor[colorId + 1] or TE.fontColor[1]
end
-----------------------------------------------------------------------------------------------------------------
function TE.NextColor(idbutton)
	local button = GetControl("TE_EmoteButton" .. tostring(idbutton))
	local emoteId = TE.GetEmIndexFromEmListIndex(idbutton + 1)
	local currentColor = TE.color[emoteId] or 0
	local nextColor

	if currentColor < TE.maxColor - 1 then
		nextColor = currentColor + 1
		TE.color[emoteId] = nextColor
	else
		nextColor = 0
		TE.color[emoteId] = nil
	end

	local color = TE.GetColor(nextColor)
	button:SetNormalFontColor(color[1], color[2], color[3], color[4])
	button:SetMouseOverFontColor(color[1], color[2], color[3], color[4])
	button:SetPressedFontColor(color[1], color[2], color[3], color[4])

	TE.vars.color = TE.color
end
-----------------------------------------------------------------------------------------------------------------
function TE.NextFavColor(index, group)
	group = group or TE.selGroup

	local favData = TE.fav[group][index]
	local colorId = favData.color

	if colorId == TE.maxColor - 1 then
		colorId = 0
	else
		colorId = colorId + 1
	end

	favData.color = colorId

	local color = TE.GetColor(colorId)
	local button = GetControl("TE_FavPanel" .. group .. "FavList" .. index)
	button:SetNormalFontColor(color[1], color[2], color[3], color[4])
	button:SetMouseOverFontColor(color[1], color[2], color[3], color[4])
	button:SetPressedFontColor(color[1], color[2], color[3], color[4])

	TE.vars.fav = TE.fav
end
-----------------------------------------------------------------------------------------------------------------
function TE.UpdateColor()
	for i = 1, TE.nbRow do
		local emoteId = TE.GetEmIndexFromEmListIndex(i)
		local button = GetControl("TE_EmoteButton" .. tostring(i - 1))

		if button then
			local color = TE.GetColor(TE.color[emoteId] or 0)
			button:SetNormalFontColor(color[1], color[2], color[3], color[4])
			button:SetMouseOverFontColor(color[1], color[2], color[3], color[4])
			button:SetPressedFontColor(color[1], color[2], color[3], color[4])
		end
	end
end
-----------------------------------------------------------------------------------------------------------------

local function DonationMail()
	SCENE_MANAGER:Show("mailSend")
	zo_callLater(function()
		ZO_MailSendToField:SetText("@tïm'99")
		ZO_MailSendSubjectField:SetText("Donation for TimEmote")
		ZO_MailSendBodyField:SetText("Hi, sending some stuff or gold :)")
		ZO_MailSendBodyField:TakeFocus()
	end, 500)
end
-----------------------------------------------------------------------------------------------------------------

--###  UI/SETTINGS  ###--
-------------------------
function TE.GetLanguage()
	local lang = GetCVar("language.2")
	
	--check for supported languages
	if (lang == "fr") then return lang end
	if (lang == "de") then return lang end
	if (lang == "es") then return lang end
	if (lang == "ru") then return lang end

	--return english if not supported
	return "en"
end
-----------------------------------------------------------------------------------------------------------------
function TE.ShowUI(state)
	-- show all groups buttons or only title
	for i=1,TimEmoteWindow:GetNumChildren() do
		local name = TimEmoteWindow:GetChild(i):GetName()
		if name ~= "TimEmoteWindowLabel" and name ~= "TE_ShowListButton" and name ~= "TE_EmoteRandomButton" then 
			TimEmoteWindow:GetChild(i):SetHidden(not state)
		end
	end
	TE.showList = state
	TE.ShowList()
end
-----------------------------------------------------------------------------------------------------------------
-- INIT --
function TE.InitUI()
	for i = 0, TE.nbRow - 1 do
		local buttonIndex = i
		local listRow = i + 1
		local buttonControl = CreateControlFromVirtual(
			"TE_EmoteButton",
			TE_EmotePanel,
			"TE_EmoteButton",
			buttonIndex
		)

		local _, point, relativeTo, relativePoint, offsetX = buttonControl:GetAnchor()
		buttonControl:SetAnchor(
			point,
			relativeTo,
			relativePoint,
			offsetX,
			TE.yOffset.Fav + buttonIndex * TE.BUTTON_HEIGHT
		)
		buttonControl:SetFont(GetEmoteFont())
		buttonControl:SetDimensions(TE.BUTTON_WIDTH, TE.BUTTON_HEIGHT)
		buttonControl:SetText(TE.GetEmoteSlashName(listRow, 0))

		buttonControl:SetHandler("OnClicked", function(_, mouseButton)
			if mouseButton == 1 then
				if IsShiftKeyDown() then
					TE.ToggleFav(listRow, 0)
				else
					TE.PlayEmote(listRow, 0)
				end
			end
		end)
		buttonControl:SetHandler("OnMouseWheel", function(_, delta)
			TE.OnMouseWheel(delta)
		end)
		buttonControl:SetHandler("OnMouseDoubleClick", function()
			TE.NextColor(buttonIndex)
		end)

		buttonControl:SetMouseOverFontColor(HexToRGBA("FF6A0000"))
		buttonControl:SetPressedFontColor(HexToRGBA("FF6A0000"))
	end

	TE.slider = CreateControl("TESlider", TE_EmotePanel, CT_SLIDER)
	TE.slider:SetDimensions(30, TE.nbRow * TE.BUTTON_HEIGHT)
	TE.slider:SetMouseEnabled(true)
	TE.slider:SetThumbTexture(TE.tex, TE.tex, TE.tex, 20, 50, 0, 0, 1, 1)
	TE.slider:SetMinMax(0, TE.nbEmote - TE.nbRow)
	TE.slider:SetValueStep(1)
	TE.slider:SetAnchor(TOPLEFT, TE_EmotePanel, TOPLEFT, TE.BUTTON_WIDTH - 20, TE.yOffset.Fav)
	TE.slider:SetHandler("OnValueChanged", function(_, value)
		TE.OnSliderMove(value)
	end)

	GetControl("TimEmoteWindowLabel"):SetText(TE.DISPLAY_NAME)

	TE_EmotePanel:SetDimensions(TE.BUTTON_WIDTH, TE.nbRow * TE.BUTTON_HEIGHT + 60)

	local listHeader = GetControl("TE_ShowListButton")
	listHeader:SetDimensions(TE.BUTTON_WIDTH, 20)
	listHeader:SetFont("$(BOLD_FONT)|$(KB_15)|soft-shadow-thick")
	listHeader:SetText(TE.locale.UI_list)
	listHeader:SetHandler("OnMouseEnter", function(control)
		ShowControlTooltip(control, TE.locale.Tooltip_listHeader)
	end)
	listHeader:SetHandler("OnMouseExit", HideControlTooltip)

	SetupRandomButtonTooltip(GetControl("TE_EmoteRandomButton"))

	for i = 1, #TE.fav do
		TE.orderFav[i] = false
	end

	TimEmoteWindow:SetHidden(true)
	TimEmoteWindow:SetDrawLayer(DL_BACKGROUND)
	TimEmoteWindow:SetAlpha(1)
end
-----------------------------------------------------------------------------------------------------------------
local function BuildPanelData()
	return {
		type = "panel",
		name = TE.DISPLAY_NAME .. " |c" .. COLOR_KHRILLSELECT .. "Extended|r",
		displayName = TE.DISPLAY_NAME .. " |c" .. COLOR_KHRILLSELECT .. "Extended|r (" .. TE.locale.LOCALE .. ")",
		author = "|cB70E99Rosie|r (Original) - |c" .. COLOR_KHRILLSELECT .. "Khrill|r (Extended) - |c9B30FFtim99|r (Renovate)",
		version = TE.VERSION,
		slashCommand = "/TimEmote",
		website = "https://www.esoui.com/downloads/info4696-TimEmote.html",
		feedback = "https://www.esoui.com/downloads/info4696-TimEmote.html#comments",
		donation = DonationMail,
		registerForRefresh = true,
		registerForDefaults = true,
		resetFunc = function()
			TE.vars.group = TE.default.group
			TE.vars.anchor = TE.default.anchor
			TE.vars.fontSize = TE.default.fontSize
			TE.vars.contrast = TE.default.contrast
			ReloadUI()
		end,
	}
end
-----------------------------------------------------------------------------------------------------------------
local function BuildGeneralOptions()
	return {
		{
			type = "header",
			name = "|c" .. COLOR_KHRILLSELECT .. TE.locale.Settings_control .. "|r",
			width = "full",
		},
		{
			type = "checkbox",
			name = TE.locale.Settings_title1,
			tooltip = TE.locale.Settings_description1,
			getFunc = function()
				return TE.vars.movable
			end,
			setFunc = function(newValue)
				TE.ToggleMovable(newValue)
			end,
			width = "full",
			default = TE.default.movable,
		},
		{
			type = "dropdown",
			name = TE.locale.Settings_displaySize,
			tooltip = TE.locale.Settings_displaySizeTip,
			choices = {
				TE.locale.DisplaySize_compact,
				TE.locale.DisplaySize_normal,
				TE.locale.DisplaySize_large,
			},
			choicesValues = {14, 15, 16},
			getFunc = function()
				return TE.vars.fontSize or TE.default.fontSize
			end,
			setFunc = function(newValue)
				TE.vars.fontSize = tonumber(newValue) or TE.default.fontSize
			end,
			width = "full",
			default = TE.default.fontSize,
			requiresReload = true,
		},
		{
			type = "slider",
			name = TE.locale.Settings_contrast,
			tooltip = TE.locale.Settings_contrastTip,
			min = 0,
			max = 1,
			step = 0.05,
			decimals = 2,
			getFunc = function()
				return TE.vars.contrast or TE.default.contrast
			end,
			setFunc = function(newValue)
				TE.UpdateContrast(newValue)
			end,
			width = "full",
			default = TE.default.contrast,
		},
	}
end
-----------------------------------------------------------------------------------------------------------------
local function AddGroupOptions(optionsTable)
	optionsTable[#optionsTable + 1] = {
		type = "header",
		name = "|c" .. COLOR_KHRILLSELECT .. TE.locale.Settings_group .. "|r",
		width = "full",
	}

	for groupIndex = 1, #TE.group do
		local currentGroup = groupIndex

		optionsTable[#optionsTable + 1] = {
			type = "editbox",
			name = "|c" .. COLOR_KHRILLSELECT .. TE.locale.Settings_groupItem .. " " .. tostring(currentGroup) .. "|r",
			tooltip = TE.locale.Settings_groupItemTip .. " " .. tostring(currentGroup),
			getFunc = function()
				return TE.group[currentGroup]
			end,
			setFunc = function(newValue)
				TE.group[currentGroup] = newValue
				TE.UpdateGroup(currentGroup)
			end,
			warning = TE.locale.Settings_warning,
			width = "half",
		}

		optionsTable[#optionsTable + 1] = {
			type = "button",
			name = TE.locale.Settings_groupDeleteBtn,
			tooltip = TE.locale.Settings_groupDeleteBtnTip,
			func = function()
				TE.RemoveGroup(currentGroup)
			end,
			width = "half",
			disabled = function()
				return #TE.group <= 1
			end,
			warning = TE.locale.Settings_groupDeleteWarning,
		}

		optionsTable[#optionsTable + 1] = {
			type = "header",
			name = "",
			width = "full",
		}
	end

	if #TE.group < TE.MAX_GROUPS then
		optionsTable[#optionsTable + 1] = {
			type = "button",
			name = TE.locale.Settings_groupNewBtn,
			tooltip = TE.locale.Settings_groupNewBtnTip,
			func = function()
				TE.AddGroup(#TE.group + 1)
			end,
			width = "full",
			warning = TE.locale.Settings_warning,
		}
	end
end
-----------------------------------------------------------------------------------------------------------------
function TE.InitConfigPanel()
	local LAM2 = LibAddonMenu2
	local panelId = "TimEmoteConfigPanel"
	local optionsTable = BuildGeneralOptions()

	AddGroupOptions(optionsTable)

	LAM2:RegisterAddonPanel(panelId, BuildPanelData())
	LAM2:RegisterOptionControls(panelId, optionsTable)
end
-----------------------------------------------------------------------------------------------------------------
function TE.Msg(msg)
	CHAT_SYSTEM:AddMessage(TE.DISPLAY_NAME.." : "..msg)
end
-----------------------------------------------------------------------------------------------------------------
function TE.OnAddOnLoaded(eventCode, addOnName)
	if addOnName~=TE.ADDON_NAME then return end
	EVENT_MANAGER:UnregisterForEvent(TE.ADDON_NAME, EVENT_ADD_ON_LOADED)

	-- Localization strings in separate file
	TE.locale = TE.Lang[TE.GetLanguage()] or TE.Lang.en
	TE.default.group[1] = TE.locale.Settings_groupDefault

	TE.vars = ZO_SavedVars:NewAccountWide("TimEmote_Vars", 1, TE.ADDON_NAME, TE.default, GetWorldName())

	SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", sceneChange)
	
	-- Need to clear anchors, since SetAnchor() will just keep adding new ones.
	TimEmoteWindow:ClearAnchors()
	TimEmoteWindow:SetAnchor(TE.vars.anchor[1], TimEmoteWindow.parent, TE.vars.anchor[2], TE.vars.anchor[3], TE.vars.anchor[4])
	
	-- sort list
	TE.InitAlphaList()
	
	-- setup emote button
	TE.UpdateEmote()
		
	TE.nbRow = TE.vars.nbRow
	TE.fav = TE.vars.fav
	TE.group = TE.vars.group
	TE.nbRow = TE.vars.nbRow
	TE.movable = TE.vars.movable
	TE.color = TE.vars.color
	TE.NormalizeColorData()
	ApplySizePreset(TE.vars.fontSize)
	
	-- update UI
	TE.InitUI()
			
	-- mousewheel interaction
	TE_EmotePanel:SetHandler("OnMouseWheel", function(self, delta) TE.OnMouseWheel(delta) end)
			
	-- update button visibility
	TE.UpdateButton()
	
	-- list visibility
	TE.ShowList()
	
	-- init groups & fav
	TE.InitGroup()
	TE.ToggleGroup(nil)
	
	TimEmoteWindow:SetMovable(TE.movable)
	
	
	TE.UpdateColor()
	TE.UpdateContrast(TE.vars.contrast)
	
	-- init config panel
	TE.InitConfigPanel()

end
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(TE.ADDON_NAME, EVENT_ADD_ON_LOADED, function(event, name) TE.OnAddOnLoaded(event, name) end)