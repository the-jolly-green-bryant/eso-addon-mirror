local L = {}

L.SI_BINDING_NAME_BHAO = "Post house and exit instance"

L.BatmansHAO_LocationDropdown = "House to post"
L.BatmansHAO_CustomText = "Text before house name"
L.BatmansHAO_CustomTextStandard = "P-T-E and port to:"
L.BatmansHAO_WaitingTime = "Wait for user to send text (in seconds)"
L.BatmansHAO_WaitingTimeTT = "If you ever use the function and decide not to post the house for any reason, the addon will wait the specified number of seconds until it resets, so it won't kick you out of an instance the next time you post your house to chat."
L.BatmansHAO_ExitOnChat = "Port or exit instance if group leader posts a home"
L.BatmansHAO_AutoReset  = "Reset the instance automatically after leaving"
L.BatmansHAO_PortToHouse = "Port to house if not already there after leaving the instance (if ultimate isn't at 100%)."
L.BatmansHAO_PortBack = "Port back to the resetted instance after ressource refill or after reset if no refill is needed."
L.BatmansHAO_PortBackWait = "Waiting time between ports"
L.BatmansHAO_PortBackWaitTT = "If your ressources are already full the addon will try to port back at once. This process could be interrupted by other addons that are triggered upon arrival at a home. Try a higher value if porting back doesn't work for you."
L.BatmansHAO_PortBackRetry = "Retrying to port"
L.BatmansHAO_PortBackRetryTT = "If you set a number higher than 0 the addon will keep on trying to port back for this number of seconds in case anything interrupts the porting process."
L.BatmansHAO_VeteranOnly = "Only activate in veteran mode."

L.BatmansHAO_AutoResetSuccess = "Instance resetted"
L.BatmansHAO_UseStrangersHouse = "Use someone else's house"

L.BatmansHAO_PortToLeader = "Port to group leader once they are back in the instance"
L.BatmansHAO_WaitForUlti = "Only port once all ressources are back at 100%"

L.BatmansHAO_DiagPortNow = "Leave instance and port to %s?"

for stringId, stringValue in pairs(L) do
	ZO_CreateStringId(stringId, stringValue)
end