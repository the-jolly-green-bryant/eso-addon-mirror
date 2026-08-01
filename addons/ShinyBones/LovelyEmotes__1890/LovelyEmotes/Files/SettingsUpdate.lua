local function UpdateToV5_0()
	local savedAccountVariables = LovelyEmotes_Settings.SavedAccountVariables
	local savedLocalVariables = LovelyEmotes_Settings.SavedLocalVariables

	-- Update old favorite emote settings
	if savedAccountVariables.FavoriteEmotes ~= nil then
		ZO_ShallowTableCopy(savedAccountVariables.FavoriteEmotes, savedAccountVariables.FavoriteEmotesTabs[1].EmoteIDs)
		savedAccountVariables.FavoriteEmotes = nil
	end

	if savedAccountVariables.FavoriteButtonCount ~= nil then
		savedAccountVariables.FavoriteEmotesTabs[1].ButtonCount = savedAccountVariables.FavoriteButtonCount
		savedAccountVariables.FavoriteButtonCount = nil
	end

	if savedLocalVariables.FavoriteEmotes ~= nil then
		ZO_ShallowTableCopy(savedLocalVariables.FavoriteEmotes, savedLocalVariables.FavoriteEmotesTabs[1].EmoteIDs)
		savedLocalVariables.FavoriteEmotes = nil
	end

	if savedLocalVariables.FavoriteButtonCount ~= nil then
		savedLocalVariables.FavoriteEmotesTabs[1].ButtonCount = savedLocalVariables.FavoriteButtonCount
		savedLocalVariables.FavoriteButtonCount = nil
	end

	-- Update old alpha setting for the minimized window
	if savedAccountVariables.MinimizedAlpha < 10 then
		savedAccountVariables.MinimizedAlpha = LovelyEmotes_Settings.DefaultAccountVariables.MinimizedAlpha
		savedAccountVariables.EnableMinimizedState = false
	elseif savedAccountVariables.MinimizedAlpha < 20 then
		savedAccountVariables.MinimizedAlpha = 20
	end

	-- Delete obsolete variables
	if savedAccountVariables.RadialMenuVariant ~= nil then
		savedAccountVariables.RadialMenuVariant = nil
	end

	if savedAccountVariables.CustomButtonsForceDisplayName ~= nil then
		savedAccountVariables.FavoriteCommandsShowDisplayName = savedAccountVariables.CustomButtonsForceDisplayName
		savedAccountVariables.CustomButtonsForceDisplayName = nil
	end

	-- Update old favorite commands
	if savedAccountVariables.CustomButtonsData ~= nil then
		for i,v in ipairs(savedAccountVariables.CustomButtonsData) do
			if v.Command ~= nil then
				table.insert(savedAccountVariables.FavoriteCommandsData, v)
			end
		end

		savedAccountVariables.CustomButtonsData = nil
	end
end

local _updateFunctions = {
	[1] = UpdateToV5_0,
}

function LovelyEmotes.CheckForSettingsUpdate()
	local savedAccountVariables = LovelyEmotes_Settings.SavedAccountVariables

	if savedAccountVariables.SettingsVersion == nil then
		UpdateToV5_0() -- Update settings for LovelyEmotes versions prior to version 5.0

		if #savedAccountVariables.FavoriteEmotesTabs[1].EmoteIDs < 1 then
			savedAccountVariables.FavoriteEmotesTabs[1].EmoteIDs = { [1] = 74, [2] = 33, [3] = 120, [4] = 11, [5] = 5, }
		end
	else
		for i = savedAccountVariables.SettingsVersion, #_updateFunctions do
			_updateFunctions[i]()
		end
	end

	savedAccountVariables.SettingsVersion = #_updateFunctions + 1
end
