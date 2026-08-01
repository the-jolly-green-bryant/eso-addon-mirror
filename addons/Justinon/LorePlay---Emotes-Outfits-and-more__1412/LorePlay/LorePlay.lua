LorePlay = LorePlay or {}
LorePlay.majorVersion = 1
LorePlay.minorVersion = 5
LorePlay.bugVersion = 1
LorePlay.version = LorePlay.majorVersion.."."..LorePlay.minorVersion.."."..LorePlay.bugVersion
LorePlay.name = "LorePlay"
LorePlay.player = "player"

function LorePlay.OnAddOnLoaded(event, addonName)
	if addonName ~= LorePlay.name then return end
	LPEventHandler = LibStub:GetLibrary("LibEventHandler-1.2")
	LPEmotesTable.CreateAllEmotesTable()
	LPEmoteHandler.InitializeEmoteHandler()
	LorePlay.InitializeSettings()
    LorePlay.InitializeEmotes()
    LorePlay.InitializeIdle()
    LorePlay.InitializeLoreWear()
    EVENT_MANAGER:UnregisterForEvent(LorePlay.name, event)
    LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_PLAYER_ACTIVATED, LorePlay.OnPlayerActivated)
end


function LorePlay.OnPlayerActivated(event)
	zo_callLater(function() CHAT_SYSTEM:AddMessage("Welcome to LorePlay, Soulless One!") end, 50)
	LPEventHandler:UnregisterForEvent(LorePlay.name, event, LorePlay.OnPlayerActivated)
end


EVENT_MANAGER:RegisterForEvent(LorePlay.name, EVENT_ADD_ON_LOADED, LorePlay.OnAddOnLoaded)