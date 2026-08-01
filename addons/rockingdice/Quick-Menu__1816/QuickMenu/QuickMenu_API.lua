---------------------------Helper----------------------------
local function insertMenuEntry(key, showName)
	for k, v in ipairs(QuickMenu.menuChoices) do
		if v == key then
			return
		end
	end
	
	table.insert(QuickMenu.menuChoices, key)
	table.insert(QuickMenu.menuChoicesShowNames, showName)
end


----------------------------API------------------------------

--for keyboard mode, gamepad mode will show 'Empty'
function QuickMenu.RegisterKeyboardMenuEntry(addonName, entryKey, showName, icon, callback)
	if not entryKey or type(entryKey) ~= "string" or entryKey == "" then
		error("Please check your entry key, should be string type and not empty.")
		return
	end
	if not addonName or type(addonName) ~= "string" or addonName == "" then
		error("Please check your addon name, should be string type and not empty.")
		return
	end
	entry = {
		name = showName,
		enabledNormal = icon,
		enabledSelected = icon,
		callback = callback,
	} 
	local key = addonName .. "(" .. entryKey .. ")"
	QuickMenu.KEYBOARD_MENU_ENTRIES[key] = entry
	insertMenuEntry(key, showName)
end

--for gamepad mode, keyboard mode will show 'Empty'
function QuickMenu.RegisterGamepadMenuEntry(addonName, entryKey, showName, icon, callback)
	if not entryKey or type(entryKey) ~= "string" or entryKey == "" then
		error("Please check your entry key, should be string type and not empty.")
		return
	end
	if not addonName or type(addonName) ~= "string" or addonName == "" then
		error("Please check your addon name, should be string type and not empty.")
		return
	end
	entry = {
		name = showName,
		enabledNormal = icon,
		enabledSelected = icon,
		callback = callback,
	} 
	local key = addonName .. "(" .. entryKey .. ")"
	QuickMenu.GAMEPAD_MENU_ENTRIES[key] = entry
	
	insertMenuEntry(key, showName)
end

--for both keyboard mode and gamepad mode
function QuickMenu.RegisterMenuEntry(addonName, entryKey, showName, iconKeyboard, iconGamepad, callback)
	QuickMenu.RegisterKeyboardMenuEntry(addonName, entryKey, showName, iconKeyboard, callback)
	QuickMenu.RegisterGamepadMenuEntry(addonName, entryKey, showName, iconGamepad, callback)
end