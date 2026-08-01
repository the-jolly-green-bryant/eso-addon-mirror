--[[	Settings Profiler - Save Migration Module
	by SDPhantom
	http://www.esoui.com/forums/member.php?u=483	]]
----------------------------------------------------------

local AddOn=_G[debug.traceback():match("\nuser:/AddOns/([^/]+)")]

--	Current version is calculated based of MinSaveVersion and the number of migration functions registered
AddOn.MinSaveVersion=1;
AddOn.SaveMigration={
	function(acctsave,charsave)--	v1 -> v2
		for name,data in pairs(acctsave.Profiles) do acctsave.Profiles[name],data.Timestamp={Data={Settings=data},Timestamps={Settings=data.Timestamp}},nil; end
		if charsave.Timestamp then charsave.Timestamps,charsave.Timestamp=charsave.Timestamp,nil; end
	end;
};
