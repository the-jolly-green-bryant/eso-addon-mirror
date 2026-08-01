SLASH_COMMANDS["/fandom"] = function ()
	RequestOpenUnsafeURL("https://elderscrolls.fandom.com/wiki/" .. string.gsub(GetUnitZone("player"), " ", "_"))
end

SLASH_COMMANDS["/fextralife"] = function ()
	RequestOpenUnsafeURL("https://elderscrollsonline.wiki.fextralife.com/" .. string.gsub(GetUnitZone("player"), " ", "+"))
end

SLASH_COMMANDS["/uesp"] = function ()
	RequestOpenUnsafeURL("https://en.uesp.net/wiki/Online:" .. string.gsub(GetUnitZone("player"), " ", "_"))
end