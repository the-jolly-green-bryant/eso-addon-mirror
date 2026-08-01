
function PUIAddon.DungeonTracker()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local db = DungeonTracker[GetWorldName()][GetDisplayName()]["$AccountWide"]

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	vColorT = {
		[4] = 1,
		[1] = 0,
		[2] = 1,
		[3] = 0.9960784316,
	}
	cColorT = {
		[4] = 1,
		[1] = 0,
		[2] = 1,
		[3] = 0,
	}
	iColorT = {
		[4] = 1,
		[1] = 0.4800000000,
		[2] = 0.4800000000,
		[3] = 0.4800000000,
	}
	kSformat = 1
	iColorS = "7a7a7a"
	highlightCC = true
	sLFGdesc = true
	sDelveBC = true
	kQuestMap = 2
	cColorS = "00ff00"
	sDungeonVMap = true
	sortAlpha = true
	sDungeonFC = true
	customCColor = true
	sDungeonTT = true
	sDungeonNMap = true
	sDelveGC = true
	sLFGcomp = true
	vColorS = "00fffe"
	sDungeonHM = true
	sDungeonND = true
	sDelveFC = true
end
