--[[
Author: Ayantir
Filename: de.lua
Version: 7
]]--

local strings = {
    ROOMBA_GBANK            = "Roomba in der Gildenbank aktivieren",
    ROOMBA_GBANK_TOOLTIP    = "Wenn diese Option aktiviert ist, wird Roomba in der Gildenbank aktiv.",
	
    ROOMBA_LITEMODE         = "Lite-Modus aktivieren",
    ROOMBA_LITEMODE_TOOLTIP    = "Wenn diese Option aktiviert ist, stapelt Roomba Gegenstände, die in die Gildenbank gelegt werden, automatisch neu.",

    ROOMBA_POSITION         = "Schaltflächenposition",
    ROOMBA_POSITION_TOOLTIP = "Legt die horizontale Position der Schaltfläche zum Neustapeln fest.",

    ROOMBA_POSITION_CHOICE1 = "Links",
    ROOMBA_POSITION_CHOICE2 = "Mitte",
    ROOMBA_POSITION_CHOICE3 = "Rechts"
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(stringId, stringValue, 1)
end