-- Auto Accept Duel - By @GhostGat (v0)
-- Good Artists borrow, great artists steal -Me


ThankYouNext = ThankYouNext or {}
local TYN = ThankYouNext
local EM = GetEventManager()
local enabled = true;

TYN.name = "AutoAcceptDuel"
TYN.version = "0.0"


function CheckIncomingDuel()
	d("Time to D-D-D--D-D-Duel!!!!")
	AcceptDuel()
end

local function sChadMode()
	d("ChadMode Enabled")
	EM:RegisterForEvent(TYN.name.."Request", EVENT_DUEL_INVITE_RECEIVED, CheckIncomingDuel)
end

local function sBitchMode()
	d("ur a faget")
	EM:UnregisterForEvent(TYN.name.."Request", EVENT_DUEL_INVITE_RECEIVED)
end

function TYN.init(e, addon)
	if addon ~= TYN.name then return end
	EM:UnregisterForEvent(TYN.name.."Load", EVENT_ADD_ON_LOADED)
	SLASH_COMMANDS["/chadmode"] = sChadMode
	SLASH_COMMANDS["/bitchmode"] = sBitchMode
	EM:RegisterForEvent(TYN.name.."Request", EVENT_DUEL_INVITE_RECEIVED, CheckIncomingDuel)
end

EM:RegisterForEvent(TYN.name.."Load", EVENT_ADD_ON_LOADED, TYN.init)
