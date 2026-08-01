-- Functionality
LE_EVENT_EmotesOverriddenUpdated = "EmotesOverriddenUpdated"										-- params: none
LE_EVENT_AvailableEmotesUpdated = "AvailableEmotesUpdated"											-- params: none

-- Settings
LE_EVENT_EmoteSaved = "EmoteSaved"																	-- params: int:tabIndex, int:slotIndex
LE_EVENT_MinimizedStateChanged = "MinimizedStateChanged"											-- params: bool:isMinimized
LE_EVENT_ActiveFavoriteEmotesTabIndexChanged = "ActiveFavoriteEmotesTabIndexChanged"				-- params: int:newTabIndex
LE_EVENT_NumberOfVisibleFavoriteEmotesTabsChanged = "NumberOfVisibleFavoriteEmotesTabsChanged"		-- params: int:tabCount
LE_EVENT_FavoriteButtonCountChanged = "FavoriteButtonCountChanged"									-- params: int:tabIndex, int:buttonCount
LE_EVENT_AccountWideFavoritesActiveChanged = "AccountWideFavoritesActiveChanged"					-- params: bool:isActive
LE_EVENT_ShowSlashNamesChanged = "ShowSlashNames"													-- params: bool:value
LE_EVENT_ShowEndlessLoopIconsChanged = "ShowEndlessLoopIconsChanged"								-- params: bool:isShown
LE_EVENT_EmoteSyncChatChannelChanged = "EmoteSyncChatChannelChanged"								-- params: int:chatChannel, bool:isEnabled

LovelyEmotes_EventSystem = {}
local _listeners = {}

function LovelyEmotes_EventSystem.AddListener(name, callbackFunction)
	local callbackList = _listeners[name]

	if callbackList == nil then
		callbackList = {}
		_listeners[name] = callbackList
	end

	table.insert(callbackList, callbackFunction)
end

function LovelyEmotes_EventSystem.RemoveListener(name, callbackFunction)
	local callbackList = _listeners[name]

	if callbackList == nil then return end

	for i, callback in ipairs(callbackList) do
		if callback == callbackFunction then
			table.remove(callbackList, i)
		end
	end

	if #callbackList < 1 then
		_listeners[name] = nil
	end
end

function LovelyEmotes_EventSystem.Invoke(name, ...)
	local callbackList = _listeners[name]

	if callbackList == nil then return end

	for _, callback in ipairs(callbackList) do
		callback(...)
	end
end

function LovelyEmotes_EventSystem.Clear(name)
	if name ~= nil then
		_listeners[name] = nil
	else
		_listeners = {}
	end
end
