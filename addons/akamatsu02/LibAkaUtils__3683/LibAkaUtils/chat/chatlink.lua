LibAkaUtils = LibAkaUtils or {}
LibAkaUtils.chatLinks = {}
LibAkaUtils.chatLinksSetup = false

local LINKTYPE = "LibAkaUtilsLink"

function LibAkaUtils.GetLink(text, name, onClick)
	if name == nil then return "|H1:" .. LINKTYPE .. "|h[Error Link]|h" end
	if text == nil then return "|H1:" .. LINKTYPE .. "|h[Error Link]|h" end
	if onClick == nil then return "|H1:" .. LINKTYPE .. "|h[Error Link]|h" end
	if LibAkaUtils.isAddonAvailable("LibChatMessage") == false then return "|H1:" .. LINKTYPE .. "|h[LibChatMessage Disabled]|h" end
	local id = LibAkaUtils.uuid()
	if LibAkaUtils.chatLinks[name] == nil then
		LibAkaUtils.chatLinks[name] = {}
	end
	LibAkaUtils.chatLinks[name][id] = onClick
	if LibAkaUtils.chatLinksSetup == false then
		LibAkaUtils.chatLinksSetup = true
		LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, LibAkaUtils.OnLinkClicked)
	end
	return "|H1:" .. LINKTYPE .. ":" .. name .. ":" .. id .. "|h[" .. text .. "]|h"
end

function LibAkaUtils.OnLinkClicked(_, _, _, _, linkType, data1, data2)
	if linkType == LINKTYPE then
		local name = tostring(data1)
		local id = tostring(data2)
		if LibAkaUtils.chatLinks[name] == nil then
			return false
		end
		if LibAkaUtils.chatLinks[name][id] == nil then
			return false
		end
		LibAkaUtils.chatLinks[name][id]()
		return true
	end
end