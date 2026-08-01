local _addon = WYK_Outfitter

_addon.CommandLine = function(text)
	if not text or text == "" or text == "help" then
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.."  HELP:")
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.." /wo help action bars << shows Action Bar help")
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.." /wo help gear << shows Gear help")
		return
	end
	
	if text == "help gear" then
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.." Gear Controls : Commands:")
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.." /saveset <name>, /loadset <name>, /clearset <name>")
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.." saveset to save, loadset to load, etc")
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.." .. <name> in all above is an alphanumeric string, no spaces")
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.." EXAMPLE 1: /saveset 1")
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.." EXAMPLE 2: /saveset pvp")
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.." /stripnaked << saves your current gear and strips all")
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.." /getdressed << restores the last set of gear you /stripnaked'ed")
	end
	
	if text == "help skills" or text == "help action bars" or text == "help actionbars" then
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.." Action Bar Tools : Commands:")
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.." /savebar <name> // save current action bar")
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.." /loadbar <name> // load saved action bar")
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.." /delbar <name> // delete saved action bar")
		_addon:Print("|c610B0B[Outfitter]"..LWF4_DEFAULT_CHAT_COLOR.." .. <name> in all above is an alphanumeric string, no spaces")
	end
end