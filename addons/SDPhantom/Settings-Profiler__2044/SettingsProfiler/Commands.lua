--[[	Settings Profiler - Command Module
	by SDPhantom
	http://www.esoui.com/forums/member.php?u=483	]]
----------------------------------------------------------

--------------------------
--[[	Namespace	]]
--------------------------
local AddOn=_G[debug.traceback():match("\nuser:/AddOns/([^/]+)")];
local print=AddOn.Print;

--------------------------
--[[	Slash Commands	]]
--------------------------
local function Trim(str) return str:match("^%s*(%S.-)%s*$"); end

SLASH_COMMANDS["/setprofile"]=function(arg)
	arg=Trim(arg); if not arg then print("Usage: /setprofile <name>"); return; end
	local exists=AddOn:GetProfile(arg);
	local isloaded=(exists==AddOn.ActiveProfile);
	arg=AddOn:SetProfile(arg); print(("%s profile |cffffff%s|r"):format(exists and (isloaded and "Reloaded" or "Set") or "Created",arg.Name));
end

SLASH_COMMANDS["/clearprofile"]=function()
	local profile=AddOn.ActiveProfile;
	if not profile then print("No profile set"); return; end
	AddOn:ClearProfile(); print("Cleared profile");
	if AddOn.AcctSave.Default then print("Linked default profile"); end
end

SLASH_COMMANDS["/delprofile"]=function(arg)
	arg=Trim(arg); if not arg then print("Usage: /delprofile <name>"); return; end
	arg=AddOn:GetProfile(arg); if not arg then print("Profile not found"); return; end
	if arg==AddOn.ActiveProfile then--	These are done internally by AddOn:DeleteProfile()
		print("Cleared profile");
		if AddOn.AcctSave.Default then print("Linked default profile"); end
	end
	AddOn:DeleteProfile(arg); print(("Deleted profile |cffffff%s|r"):format(arg.Name));
end

SLASH_COMMANDS["/savedefaultprofile"]=function(arg) AddOn:SaveDefault(); print("Default profile saved"); end
SLASH_COMMANDS["/cleardefaultprofile"]=function(arg) AddOn:ClearDefault(); print("Default profile cleared"); end

SLASH_COMMANDS["/resetprofiler"]=function() AddOn:Reset(); print("Profiler data reset"); end

local function CaseInsensitiveSort(s1,s2) return tostring(s1):lower()<tostring(s2):lower(); end
SLASH_COMMANDS["/listprofiles"]=function()--	Not going to make an API func for this
	local list={};
	for name in next,AddOn.AcctSave.Profiles do table.insert(list,name); end
	table.sort(list,CaseInsensitiveSort);

	print(("%d profile(s) found."):format(#list));
	for _,name in ipairs(list) do print(("|c%06x%s|r"):format(AddOn.AcctSave.Profiles[name]==AddOn.ActiveProfile and 0x00ff00 or 0xffff00,name)); end
end
