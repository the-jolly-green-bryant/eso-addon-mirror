local _addon = WYK_Macros

_addon.MacroHelp = function()
	_addon:Print("|c610B0B[Macros]"..LWF4_DEFAULT_CHAT_COLOR.."  Macro Help:")
	_addon:Print("|c610B0B[Macros]"..LWF4_DEFAULT_CHAT_COLOR.."  /macrowin << shows macro window")
	_addon:Print("|c610B0B[Macros]"..LWF4_DEFAULT_CHAT_COLOR.."  > Macros are now controlled by right clicking inside of the macro window. Set your KEYBIND for toggling the macro window and simply RIGHT CLICK on the macro button you wish to manage.")
end

_addon.ClearMacro = function(text)
	local str = _addon:string_trim(text)
	local key = nil
	for m = 1, _addon.Macros.MaxMacros, 1 do
		local ms = (m.."")
		local lm = string.len(ms)
		if string.sub(str,1,lm) == ms then key = ms end
	end
	if key == nil then
		return
	end
	if _addon.Settings["Macros"] == nil then _addon.Settings["Macros"] = {} end
	_addon.Settings["Macros"][key] = nil
	if _addon.Macros.Buttons[key] ~= nil then _addon.Macros.Buttons[key].Label:SetText(key) end
	_addon:Print("|c610B0B[Macros]"..LWF4_DEFAULT_CHAT_COLOR.."  MACRO "..key.." CLEARED")
end

local lastRename = nil
_addon.RenameMacro = function(text, newName)
	local str = _addon:string_trim(text.."")
	local key = nil
	for m = 1, _addon.Macros.MaxMacros, 1 do
		local ms = (m.."")
		local lm = string.len(ms)
		if string.sub(str,1,lm) == ms then key = ms end
	end
	if key == nil then
		return
	end
	local name = newName
	if string.len(name) <= 1 then
		_addon:Print("|c610B0B[Macros]"..LWF4_DEFAULT_CHAT_COLOR.."  RENAME MACRO: Macro name too short")
		return
	end
	if _addon.Settings["Macros"] == nil then _addon.Settings["Macros"] = {} end
	if _addon.Settings["Macros"][key] ~= nil and text ~= lastRename then
		lastRename = text
		_addon.Settings["Macros"][key].Name = name
		if _addon.Macros.Buttons[key] ~= nil then _addon.Macros.Buttons[key].Label:SetText(string.sub(name,1,6)) end
		_addon:Print("|c610B0B[Macros]"..LWF4_DEFAULT_CHAT_COLOR.."  RENAME MACRO: Macro "..key.." renamed to "..name)
	end
end
