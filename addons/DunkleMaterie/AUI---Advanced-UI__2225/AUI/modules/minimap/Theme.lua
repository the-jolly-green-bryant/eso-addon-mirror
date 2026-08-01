AUI.Minimap.Theme = {}

local iconThemes = {}													
local miniMapThemes = {}		
local isLoaded = false

function AUI.Minimap.Theme.AddMinimapTheme(internName, displayName, themeData)
	if not AUI.Minimap.IsLoaded() or not internName or not displayName or not themeData then
		return
	end
	
	themeData.displayName = displayName
	
	table.insert(miniMapThemes, {[internName] = themeData})
end

function AUI.Minimap.Theme.AddMinimapIconTheme(internName, displayName, iconThemeData)
	if not AUI.Minimap.IsLoaded() or not internName or not displayName or not iconThemeData then
		return
	end

	iconThemeData.displayName = displayName	
	
	table.insert(iconThemes, {[internName] = iconThemeData})
end

function AUI.Minimap.Theme.GetThemeNames()
	local names = {}

	for _index, tableData in pairs(miniMapThemes) do	
		for _internName, data in pairs(tableData) do	
			if data.displayName then
				table.insert(names, {[_internName] = data.displayName})
			end
		end
	end
	
	return names
end

function AUI.Minimap.Theme.GetIconThemeNames()
	local names = {}

	for _index, tableData in pairs(iconThemes) do	
		for _internName, data in pairs(tableData) do
			if data.displayName then
				table.insert(names, {[_internName] = data.displayName})
			end
		end
	end

	return names
end

function AUI.Minimap.Theme.GetMiniMapThemes()
	if not AUI.Minimap.IsLoaded() then
		return nil
	end

	return miniMapThemes
end

function AUI.Minimap.Theme.GetMiniMapIconTheme()
	if not AUI.Minimap.IsLoaded() then
		return nil
	end

	return iconThemes
end

function AUI.Minimap.Theme.GetCurrentMiniMapTheme()
	if not AUI.Minimap.IsLoaded() then
		return nil
	end

	local currentTheme = AUI.Table.GetValue(miniMapThemes, AUI.Settings.Minimap.theme)

	if currentTheme == nil then
		currentTheme = AUI.Table.GetValue(miniMapThemes, "default")	
	end
		
	return currentTheme
end

function AUI.Minimap.Theme.GetCurrentMiniMapIconTheme()
	if not AUI.Minimap.IsLoaded() then
		return nil
	end

	local currentIconTheme = AUI.Table.GetValue(iconThemes,  AUI.Settings.Minimap.icon_theme)

	if currentIconTheme == nil then
		currentIconTheme = AUI.Table.GetValue(iconThemes, "default")	
	end
	
	return currentIconTheme
end

function AUI.Minimap.Theme.Load()
	if isLoaded then
		return
	end

	AUI.Minimap.CreateOptionTable()	
	AUI.Minimap.UI.Update()	
	AUI.Minimap.Pin.SetPinData()
	
	isLoaded = true
end