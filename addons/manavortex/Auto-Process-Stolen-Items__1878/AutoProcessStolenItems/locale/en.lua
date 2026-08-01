AutoProcessStolenItems 					= AutoProcessStolenItems or {}

AutoProcessStolenItems.crowStrings 		= AutoProcessStolenItems.crowStrings or {}

local strings = {
	[1] = "osmetic", 
	[2] = "tensil", 
	[3] = "ish", 
	[4] = "ookware", 
	[5] = "inkware", 
}

ZO_DeepTableCopy(strings, AutoProcessStolenItems.crowStrings)