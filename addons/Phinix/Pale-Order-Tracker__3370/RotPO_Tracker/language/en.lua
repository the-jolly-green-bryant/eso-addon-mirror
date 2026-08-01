local RPOTracker = _G['RPOTracker']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- English
------------------------------------------------------------------------------------------------------------------

-- Panel Strings
	L.RPOTRACK_Title		= "|cFF9900Pale Order|r |cFEE854Tracker|r"
	L.RPOTRACK_SOpts		= "Self Tracker Options"
	L.RPOTRACK_GOpts		= "Group Tracker Options"

-- Self Tracker Options
	L.RPOTRACK_Show			= "Show Tracker"
	L.RPOTRACK_ShowD		= "Show the RotPO equipped status tracker for the player."
	L.RPOTRACK_Lock			= "Lock Tracker"
	L.RPOTRACK_LockD		= "When unlocked you can move the tracker around to save a new position."
	L.RPOTRACK_ShowG		= "Show Grouped"
	L.RPOTRACK_ShowGD		= "Show the RotPO equipped status tracker for the player when grouped."
	L.RPOTRACK_ShowBG		= "Show Background"
	L.RPOTRACK_ShowBGD		= "Show a black background behind the RotPO tracker icon."
	L.RPOTRACK_Label		= "Show Label"
	L.RPOTRACK_LabelD		= "Show a text label indicating the percent RotPO strength based on number of group members present."
	L.RPOTRACK_TScale		= "Tracker Scale"
	L.RPOTRACK_TScaleD		= "Scale the dimensions for the tracker icon."
	L.RPOTRACK_LScale		= "Label Scale"
	L.RPOTRACK_LScaleD		= "Scale the dimensions for the text label."
	L.RPOTRACK_LabelX		= "Label Horizontal Offset"
	L.RPOTRACK_LabelXD		= "Adjust the position of the RotPO text label left to right."
	L.RPOTRACK_LabelY		= "Label Vertical Offset"
	L.RPOTRACK_LabelYD		= "Adjust the position of the RotPO text label up and down."

-- Group Tracker Options
	L.RPOTRACK_SGF			= "Monitor Group Frames"
	L.RPOTRACK_SGFD			= "Show RotPO icon for group unit frames."
	L.RPOTRACK_SRF			= "Monitor Raid Frames"
	L.RPOTRACK_SRFD			= "Show RotPO icon on raid unit frames."
	L.RPOTRACK_GIS			= "Group Icon Size"
	L.RPOTRACK_GISD			= "Size of the RotPO icon when displayed on standard group frames."
	L.RPOTRACK_RIS			= "Raid Icon Size"
	L.RPOTRACK_RISD			= "Size of the RotPO icon when displayed on standard raid frames."
	L.RPOTRACK_GXIO			= "Group Horizontal Icon Offset"
	L.RPOTRACK_GXIOD		= "Adjusts the position of the group frame RotPO icon left to right."
	L.RPOTRACK_GYIO			= "Group Vertical Icon Offset"
	L.RPOTRACK_GYIOD		= "Adjusts the position of the group frame RotPO icon up and down."
	L.RPOTRACK_RXIO			= "Raid Horizontal Icon Offset"
	L.RPOTRACK_RXIOD		= "Adjusts the position of the raid frame RotPO icon left to right."
	L.RPOTRACK_RYIO			= "Raid Vertical Icon Offset"
	L.RPOTRACK_RYIOD		= "Adjusts the position of the raid frame RotPO icon up and down."

-- 3rd Party Frame Options
	L.RPOTRACK_Mode1		= "Default"
	L.RPOTRACK_Mode2		= "Foundry Tactical Combat"
	L.RPOTRACK_Mode3		= "Lui Extended"
	L.RPOTRACK_Mode4		= "Bandits User Interface"
	L.RPOTRACK_Mode5		= "AUI"

------------------------------------------------------------------------------------------------------------------

function RPOTracker:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
