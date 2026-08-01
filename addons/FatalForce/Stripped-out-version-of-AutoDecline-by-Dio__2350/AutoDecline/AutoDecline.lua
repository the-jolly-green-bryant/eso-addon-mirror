-- Auto Decline - By FatalForce (v0.0.1), adapted from original much more robust version of Auto Decline written by Dio, 
-- and structure taken from Wheels HideGroup addon

ThankYouNext = ThankYouNext or {}
local TYN = ThankYouNext
local EM = GetEventManager()
local enabled = true;

TYN.name = "AutoDecline"
TYN.version = "1.0"

function CheckAllInvitesFriends()
	for i = 1, GetNumIncomingFriendRequests() do
		CheckFriendInvite(GetIncomingFriendRequestInfo(i))
	end
end

function CheckFriendInvite(accountName)
	RejectFriendRequest(accountName)
	d("Dismissed a friend invite from: "..accountName)
end

local function sCommand(opt)
	if opt == "true" or opt == "1" then
		d("Enabled. Enjoy your privacy")
		EM:RegisterForEvent(TYN.name.."Request", EVENT_INCOMING_FRIEND_INVITE_ADDED, CheckAllInvitesFriends)
	else
		d("You can now accept friend requests.")
		EM:UnregisterForEvent(TYN.name.."Request", EVENT_INCOMING_FRIEND_INVITE_ADDED)
	end
end

function TYN.init(e, addon)
	if addon ~= TYN.name then return end
	EM:UnregisterForEvent(TYN.name.."Load", EVENT_ADD_ON_LOADED)
	SLASH_COMMANDS["/autodecline"] = sCommand
	EM:RegisterForEvent(TYN.name.."Request", EVENT_INCOMING_FRIEND_INVITE_ADDED, CheckAllInvitesFriends)
end

EM:RegisterForEvent(TYN.name.."Load", EVENT_ADD_ON_LOADED, TYN.init)