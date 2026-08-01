local _addon = WYK_Macros

_addon.Macros = {}
_addon.Macros.Buttons = {}
_addon.Macros.Containers = {}

_addon.Macros.MaxMacros = 48

_addon.Macros.getPopupAnchor = function( idx, forceTop )
	local anchor = { CENTER, GuiRoot, CENTER, 0, 0 }
	if wykkydsMacroFrame == nil then return anchor end
	if wykkydsMacroFrame.Backdrop == nil then return anchor end
	if _addon.Macros.Buttons[ idx.."" ] == nil then return anchor end
	if _addon.Macros.Buttons[ idx.."" ].Backdrop == nil then return anchor end
	local addOnX, addOnY = wykkydsMacroFrame.Backdrop:GetCenter()
	local guiRootX, guiRootY = GuiRoot:GetCenter()
	local offsetY = _addon.Macros.Buttons[ idx.."" ].Backdrop:GetTop() - wykkydsMacroFrame.Backdrop:GetTop()
	if forceTop then offsetY = 0 end
	if addOnX <= guiRootX then anchor = { TOPLEFT, wykkydsMacroFrame.Backdrop, TOPRIGHT, 2, offsetY }
	else anchor = { TOPRIGHT, wykkydsMacroFrame.Backdrop, TOPLEFT, -2, offsetY } end
	return anchor
end

_addon.Macros.macroName = function(text)
	local key = _addon:string_trim(text)
	local alt = string.sub(text,1,10)
	local goodMacroNum = false
	for m = 1, _addon.Macros.MaxMacros, 1 do
		if key == (m.."") then goodMacroNum = true end
	end
	if not goodMacroNum then return alt end
	if _addon.Settings["Macros"] == nil then return alt end
	if _addon.Settings["Macros"][key] == nil then return alt end
	if _addon.Settings["Macros"][key].Name == nil then return alt end
	return string.sub(_addon.Settings["Macros"][key].Name,1,10)
end

_addon.Macros.Load = function( idx )
	local settings = {}
	local key = idx..""
	local goodMacroNum = false
	for m = 1, _addon.Macros.MaxMacros, 1 do
		if key == (m.."") then goodMacroNum = true end
	end
	if _addon.Settings["Macros"] == nil then _addon.Settings["Macros"] = {}; return; end
	if goodMacroNum then
		local cmd = _addon.Settings["Macros"][key]
		if cmd ~= nil then
			if cmd.Name ~= nil then settings.Name = cmd.Name end
			if cmd.Commands ~= nil then settings.Commands = cmd.Commands end
		end
	end
	return settings
end

_addon.Macros.Save = function( idx, settings )
	local key = idx..""
	local goodMacroNum = false
	for m = 1, _addon.Macros.MaxMacros, 1 do
		if key == (m.."") then goodMacroNum = true end
	end
	if _addon.Settings["Macros"] == nil then _addon.Settings["Macros"] = {}; return; end
	if goodMacroNum then
		_addon.Settings["Macros"][key] = {}
		_addon.Settings["Macros"][key].Name = settings.Name
		_addon.Settings["Macros"][key].Commands = {}
		if settings.Commands ~= nil then
			for cc = 1, 3, 1 do
				if settings.Commands[cc] ~= nil then
					if settings.Commands[cc].Type ~= 0 and settings.Commands[cc].Type ~= nil then
						if settings.Commands[cc].Param1 == 0 or settings.Commands[cc].Param1 == -1 then settings.Commands[cc].Param1 = nil end
						if settings.Commands[cc].Param2 == 0 or settings.Commands[cc].Param2 == -1 then settings.Commands[cc].Param2 = nil end
						table.insert( _addon.Settings["Macros"][key].Commands, settings.Commands[cc] )
					end
				end
			end
		end
		if _addon.Macros.Buttons[ idx.."" ] ~= nil then
			_addon.Macros.Buttons[ idx.."" ].Label:SetText( _addon.Macros.macroName(idx.."") )
		end
		_addon:Print("|c610B0B[Macros]"..LWF4_DEFAULT_CHAT_COLOR.."  Macro Saved. Reloading UI in 3 seconds to enforce changes. Hang on!")
		_addon:ReloadUI()
	end
end

_addon.MacroButton = function(num)
	local key = num..""
	local goodMacroNum = false
	for m = 1, _addon.Macros.MaxMacros, 1 do
		if key == (m.."") then goodMacroNum = true end
	end
	if _addon.Settings["Macros"] == nil then _addon.Settings["Macros"] = {}; return; end
	if goodMacroNum then
		local cmd = _addon.Settings["Macros"][key]
		if cmd ~= nil then
			if cmd.Name ~= nil and cmd.Name ~= nil and cmd.Commands ~= nil then
				for _,c in ipairs(cmd.Commands) do
					if c.Type == _addon.G.MACRO_TYPE_GEAR and c.Param1 ~= nil and c.Param1 ~= -1 and c.Param1 ~= 0 then if WYK_Outfitter then WYK_Outfitter.GC.LoadCommands(c.Param1) end
					elseif c.Type == _addon.G.MACRO_TYPE_SKILL and c.Param1 ~= nil and c.Param1 ~= -1 and c.Param1 ~= 0 then if WYK_Outfitter then WYK_Outfitter.ABT.loadSet(c.Param1) end
					elseif c.Type == _addon.G.MACRO_TYPE_EMOTE and c.Param1 ~= nil and c.Param1 ~= -1 and c.Param1 ~= 0 then 
						if _addon.GLOBAL.emotes == nil then _addon:LoadEmotes() end
						if _addon.GLOBAL.emotes[ c.Param1 ] ~= nil then PlayEmoteByIndex( _addon.GLOBAL.emotes[ c.Param1 ] ) else _addon:Print("|c610B0B[Macros]"..LWF4_DEFAULT_CHAT_COLOR.."  Could not find Emote: "..tostring(c.Param1) ) end
					end
				end
			end
		end
	end
end
