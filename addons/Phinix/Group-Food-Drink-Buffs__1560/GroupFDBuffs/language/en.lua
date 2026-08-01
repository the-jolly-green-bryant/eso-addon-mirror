local GroupFDB = _G['GroupFDB']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- English
------------------------------------------------------------------------------------------------------------------

-- Panel Strings
	L.GroupFDB_Title		= "Group Food & Drink Buffs"
	L.GroupFDB_GOpts		= "Global Options"
	L.GroupFDB_SGF			= "Monitor Group Frames"
	L.GroupFDB_SGFD			= "Show the food of drink icons on group unit frames."
	L.GroupFDB_SRF			= "Monitor Raid Frames"
	L.GroupFDB_SRFD			= "Show the food of drink icons on raid unit frames."
	L.GroupFDB_SAB			= "Show Active Buff Indicator"
	L.GroupFDB_SABD			= "Show the icon for the active food or drink on the group and raid frames."
	L.GroupFDB_SJB			= "Show Junk Buff Indicator"
	L.GroupFDB_SJBD			= "Show the icon for active junk food or drink on the group and raid frames."
	L.GroupFDB_SNB			= "Show Missing Buff Indicator"
	L.GroupFDB_SNBD			= "Show a red icon on the group and raid frames when a member has no food or drink active."
	L.GroupFDB_GMode		= "Group Buff Mode"
	L.GroupFDB_GModeD		= "Select the support module for the group unit frames you currently use. Default is the game's normal frames."
	L.GroupFDB_RMode		= "Raid Buff Mode"
	L.GroupFDB_RModeD		= "Select the support module for the raid unit frames you currently use. Default is the game's normal frames."
	L.GroupFDB_GIS			= "Group Icon Size"
	L.GroupFDB_GISD			= "Size of the food/drink icon when displayed on standard group frames, as a multiple of 8 pixels."
	L.GroupFDB_RIS			= "Raid Icon Size"
	L.GroupFDB_RISD			= "Size of the food/drink icon when displayed on standard raid frames, as a multiple of 8 pixels."
	L.GroupFDB_GXIO			= "Group Horizontal Icon Offset"
	L.GroupFDB_GXIOD		= "Adjusts the position of the group frame food/drink icon left to right."
	L.GroupFDB_GYIO			= "Group Vertical Icon Offset"
	L.GroupFDB_GYIOD		= "Adjusts the position of the group frame food/drink icon up and down."
	L.GroupFDB_RXIO			= "Raid Horizontal Icon Offset"
	L.GroupFDB_RXIOD		= "Adjusts the position of the raid frame food/drink icon left to right."
	L.GroupFDB_RYIO			= "Raid Vertical Icon Offset"
	L.GroupFDB_RYIOD		= "Adjusts the position of the raid frame food/drink icon up and down."

-- Group frame support options
	L.GroupFDB_Mode1		= "Default"
	L.GroupFDB_Mode2		= "Foundry Tactical Combat"
	L.GroupFDB_Mode3		= "Lui Extended"
	L.GroupFDB_Mode4		= "Bandits User Interface"
	L.GroupFDB_Mode5		= "AUI"


------------------------------------------------------------------------------------------------------------------

function GroupFDB:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
