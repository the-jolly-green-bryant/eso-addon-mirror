-- RdK Group Tool Player Link
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.playerLink = RdKGToolUtil.playerLink or {}
local RdKGToolPL = RdKGToolUtil.playerLink

function RdKGToolPL.CreateDisplayNameLink(nameToDisplay, displayName, hasBrackets)
	local link = ""
	if nameToDisplay ~= nil then
		link = ZO_LinkHandler_CreateLink(nameToDisplay, nil, DISPLAY_NAME_LINK_TYPE, displayName)
	end
	if hasBrackets == nil or hasBrackets == false then
		link = RdKGToolPL.RemoveBracketsFromLink(link)
	end
	return link
end

function RdKGToolPL.CreateCharNameLink(nameToDisplay, charName, hasBrackets)
	local link = ""
	if nameToDisplay ~= nil then
		link = ZO_LinkHandler_CreateLink(nameToDisplay, nil, CHARACTER_LINK_TYPE, charName)
	end
	if hasBrackets == nil or hasBrackets == false then
		link = RdKGToolPL.RemoveBracketsFromLink(link)
	end
	return link
end

function RdKGToolPL.RemoveBracketsFromLink(link)
	link = link:gsub("%[",""):gsub("%]","")
	return link
end