LE_EmoteSelectionWindow = {}

local _baseControl
local _alphaAnimation
local _isActive = false
local _temp = {}
local _hideCallbackFunction

function LE_EmoteSelectionWindow.UpdateMaxAlpha()
	local maxAlpha = LovelyEmotes_Settings.SavedAccountVariables.Alpha / 100

	_alphaAnimation:SetMinMaxAlpha(0, maxAlpha)

	if _isActive == true then
		_baseControl:SetAlpha(maxAlpha)
	end
end

function LE_EmoteSelectionWindow.SetHideCallback(func)
	if _hideCallbackFunction ~= nil then _hideCallbackFunction() end
	_hideCallbackFunction = func
end

local function SelectEmote(emote, playEmote)
	if not emote then
		_temp.EmoteID = emote
		playEmote = false
	else
		_temp.EmoteID = emote.ID
	end

	local displayName = ""
	local slashName = LE_Const_EmoteUnknownDisplayName

	if emote then
		slashName = emote.SlashName
		if emote.DisplayName ~= emote.SlashName then displayName = emote.DisplayName end
	elseif emote == false then
		slashName = LE_Const_EmoteEmptyDisplayName
	end

	LE_EmoteSelectionWindowControlTopBoxSelectedEmoteTextDisplayName:SetText(displayName)
	LE_EmoteSelectionWindowControlTopBoxSelectedEmoteTextSlashName:SetText(slashName)

	if not playEmote then return end
	emote.Play()
end

local function SetupEmoteList()
	if LovelyEmotes.EmoteList:CompareParent(_baseControl) == true then
		LovelyEmotes.EmoteList:ResetList()
	else
		LovelyEmotes.EmoteList:SetParent(_baseControl, LE_Const_MainWindowBaseHeight + 16, function(button, data)
			SelectEmote(data, button == 1)
		end)
	end
end

function LE_EmoteSelectionWindow.ShowWindow(favoriteIndex)
	if _isActive == false then
		_isActive = true

		LovelyEmotes.PlayWindowOpenSound()
		SetupEmoteList()

		_alphaAnimation:FadeIn(0,
			DEFAULT_SCENE_TRANSITION_TIME,
			ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA,
			nil,
			ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA)

		_baseControl:SetHidden(false)
	end

	_temp.FavoriteIndex = favoriteIndex
	SelectEmote(LovelyEmotes.GetSavedEmote(favoriteIndex), false)
end

local function HideWindow(instant)
	if _isActive == false then return end
	_isActive = false

	LovelyEmotes.PlayWindowCloseSound()
	_hideCallbackFunction()

	ZO_ClearTable(_temp)

	if instant then
		_baseControl:SetAlpha(0)
		_baseControl:SetHidden(true)
	else
		_alphaAnimation:FadeOut(0,
			DEFAULT_SCENE_TRANSITION_TIME,
			ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA,
			function() _baseControl:SetHidden(true) end,
			ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA)
	end
end
LE_EmoteSelectionWindow.HideWindow = HideWindow

function LE_EmoteSelectionWindow.SaveEmote()
	if _isActive == false then return end

	if _temp.EmoteID ~= nil then
		LovelyEmotes_Settings.SaveEmote(_temp.FavoriteIndex, _temp.EmoteID)
	end

	HideWindow()
end

function LE_EmoteSelectionWindow.EmptySlot()
	if _isActive == false then return end

	SelectEmote(false, false)
end

local function SavePosition()
	local savedAccountVariables = LovelyEmotes_Settings.SavedAccountVariables
	savedAccountVariables.EmoteListPositionX = _baseControl:GetLeft()
	savedAccountVariables.EmoteListPositionY = _baseControl:GetTop()
end

function LE_EmoteSelectionWindow.Initialize()
	_baseControl = LE_EmoteSelectionWindowControl
	local savedAccountVariables = LovelyEmotes_Settings.SavedAccountVariables

	_baseControl:ClearAnchors()
	_baseControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedAccountVariables.EmoteListPositionX, savedAccountVariables.EmoteListPositionY)

	_baseControl:SetAlpha(0)
	_alphaAnimation = ZO_AlphaAnimation:New(_baseControl)
	_alphaAnimation:SetMinMaxAlpha(0, savedAccountVariables.Alpha / 100)

	_baseControl:SetHandler("OnMoveStop", SavePosition)
end
