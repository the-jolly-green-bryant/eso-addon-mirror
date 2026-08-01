-- RdK Group Tool Equipment
-- By @s0rdrak (PC / EU)

RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.equipment = RdKGToolUtil.equipment or {}
local RdKGToolEquip = RdKGToolUtil.equipment


RdKGToolEquip.constants = RdKGToolEquip.constants or {}
RdKGToolEquip.constants.EQUIPMENT_STRING = "|H%d:item:%d:%d:%d:%d:%d:%d:%d:0:0:0:0:0:0:0:%d:%d:0:%d:%d:%d:0|h|h"
RdKGToolEquip.constants.networking = {}
RdKGToolEquip.constants.networking.messagePrefix = {}
RdKGToolEquip.constants.networking.messagePrefix.HEAD = 0
RdKGToolEquip.constants.networking.messagePrefix.SHOULDERS = 1
RdKGToolEquip.constants.networking.messagePrefix.CHEST = 2
RdKGToolEquip.constants.networking.messagePrefix.HANDS = 3
RdKGToolEquip.constants.networking.messagePrefix.WAIST = 4
RdKGToolEquip.constants.networking.messagePrefix.LEGS = 5
RdKGToolEquip.constants.networking.messagePrefix.FEET = 6
RdKGToolEquip.constants.networking.messagePrefix.NECKLACE = 7
RdKGToolEquip.constants.networking.messagePrefix.RING_1 = 8
RdKGToolEquip.constants.networking.messagePrefix.RING_2 = 9
RdKGToolEquip.constants.networking.messagePrefix.WEAPON_1_1 = 10
RdKGToolEquip.constants.networking.messagePrefix.WEAPON_1_2 = 11
RdKGToolEquip.constants.networking.messagePrefix.WEAPON_2_1 = 12
RdKGToolEquip.constants.networking.messagePrefix.WEAPON_2_2 = 13



--[[
quickslot stuff
|H0:collectible:5242|h|h
|H0:item:44772:2:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
|H0:item:71779:4:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
|H0:item:27038:307:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h
|H0:collectible:1108|h|h
|H0:collectible:1383|h|h
|H0:item:71779:4:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
|H0:item:27037:307:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h
|H1:item:68235:309:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h
|H1:item:33646:164:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
|H1:item:27039:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:1249027|h|h
|H1:item:27039:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:2149990|h|h
]]

--[[
|H1:item:132172:364:50:26588:370:50:18:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h
|H3:item:82171:364:50:26588:370:50:18:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h
|H3:item:82171:364:50:26588:370:50:18:0:0:0:0:0:0:0:1:67:0:0:0:10000:0|h|h
|H1:item:82155:364:50:26588:370:50:18:0:0:0:0:0:0:0:1:67:0:1:0:9603:0|h|h
|H1:item:82171:364:50:26588:370:0:0:1:1:1:1:1:1:1:2:67:0:555:0:5555555:0|h|h

|H1:item:<id>:<quality>:<level>:<enchantment>:<enchantment quality>:<enchantmentLevel>:<transmutationstrait [0=none]>:
<nothing>:<nothing>:<nothing>:<nothing>:<nothing>:<nothing>:<style [0=none]>:<nothing>:<crafted [0=no,1=yes]>:<redborder [0=no,1yes]>:
<item_health>:<idk>

|H1:item:51589:293:50:26580:275:50:0:0:0:0:0:0:0:0:1:20:1:1:0:10000:0|h|h
|H1:item:51543:370:50:26588:370:50:0:0:0:0:0:0:0:0:1:52:1:1:0:10000:0|h|h
|H1:item:76099:133:50:0:0:0:0:0:0:0:0:0:0:0:257:257:0:0:0:10000:0|h|h
|H1:item:76099:131:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:51601:370:50:26587:370:50:0:0:0:0:0:0:0:0:1:49:1:1:0:347:0|h|h
|H1:item:51543:370:75:26588:370:50:0:0:0:0:0:0:0:0:1:52:1:1:0:10000:0|h|h

|H1:item:100269:363:50:26588:370:50:0:0:0:0:0:0:0:0:1:5:0:1:0:3040:0|h|h

|H1:item:100212:363:50:26589:370:50:2:0:0:0:0:0:0:0:257:5:0:1:0:0:0|h|h
|H1:item:100212:363:50:26589:370:50:6:0:0:0:0:0:0:0:256:5:0:1:0:0:0|h|h
|H1:item:100212:363:50:26589:370:50:6:0:0:0:0:0:0:0:212:5:0:1:0:0:0|h|h
|H1:item:100212:363:50:26589:370:50:28:0:0:0:0:0:0:0:257:5:0:1:0:0:0|h|h
|H1:item:100212:363:50:26589:370:50:28:0:0:0:0:0:0:0:256:5:0:1:0:0:0|h|h
|H1:item:100212:363:50:26589:370:50:28:0:0:0:0:0:0:0:0:5:0:1:0:0:0|h|h

|H1:item:72798:370:50:54484:370:50:0:0:0:0:0:0:0:0:1:65:1:1:0:292:0|h|h
|H1:item:72798:370:50:54484:370:50:0:0:0:0:0:0:0:0:1:65:0:1:0:292:0|h|h

glyph:
|H1:item:26841:310:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h

poison:
|H1:item:76829:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:10000:0|h|h
|H1:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:133650|h|h
|H1:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:33:1:0:0:0:133650|h|h
|H1:item:76826:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:66309|h|h

tests:
|H1:item:76826:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:66309|h|h
|H1:item:26841:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:66309|h|h
|H1:item:76826:306:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:0|h|h

brackets:
|H0:item:129550:363:50:26582:370:50:0:0:0:0:0:0:0:0:1:67:0:1:0:9850:0|h|h
|H1:item:129550:363:50:26582:370:50:0:0:0:0:0:0:0:0:1:67:0:1:0:9850:0|h|h

issues:
|H1:item:136384:370:50:54484:370:50:0:0:0:0:0:0:0:0:1:75:1:1:0:71:0|h|h
|H1:item:136113:370:50:54484:370:50:0:0:0:0:0:0:0:0:1:75:0:0:0:10000:0|h|h
|H1:item:136113:370:50:54484:370:50:0:0:0:0:0:0:0:0:1:75:1:1:0:457:0|h|h


|H1:item:136262:369:50:0:0:50:0:0:0:0:0:0:0:0:1:75:0:0:0:10000:0|h|h
|H1:item:136262:369:50:26582:370:50:0:0:0:0:0:0:0:0:1:75:0:0:0:10000:0|h|h

/script d(RdKGTool.util.equipment.CreateItemLink(82155, 364, 50, 26588, 370, 50, 18, 0, 67, 0, 0, 10000))

--Networking
--Armor
idemId: 524288 --20bit
quality (inc cp): 512 --10bit
level: 64 --7bit
enchantment: 524288 --20bit
quality (inc cp): 512 --10bit
level: 64 --7bit
transmutation: 64 --7bit
--irrelevant stats
boud: 2
style: 128
crafted: 2
redBorder: 2
itemHealth: 16384

	1			00000000 00000000 00000001
	2			00000000 00000000 00000010
	4			00000000 00000000 00000100
	8			00000000 00000000 00001000
	16			00000000 00000000 00010000
	32			00000000 00000000 00100000
	64			00000000 00000000 01000000
	128			00000000 00000000 10000000
	256			00000000 00000001 00000000
	512			00000000 00000010 00000000
	1024		00000000 00000100 00000000
	2048		00000000 00001000 00000000
	4096		00000000 00010000 00000000
	8192		00000000 00100000 00000000
	16384		00000000 01000000 00000000
	32768		00000000 10000000 00000000
	65536		00000001 00000000 00000000
	131072		00000010 00000000 00000000
	262144		00000100 00000000 00000000
	524288		00001000 00000000 00000000
	1048576		00010000 00000000 00000000
	2097152		00100000 00000000 00000000
	4194304		01000000 00000000 00000000
	8388608		10000000 00000000 00000000

	4 messages
	00000000 00000000 00000000 00000000
	[MESSAGE_TYPE:8bit] [PACKET_ID:3bit] [MESSAGE:21bit]
	MESSAGE_1: itemId
	MESSAGE_2: enchantmentId
	MESSAGE_3: quality | quality
	MESSAGE_4: level | level | transmutation

]]
         
function RdKGToolEquip.CreateItemLink(itemId, itemQuality, level, enchantment, enchantmentQuality, enchantmentLevel, transmutation, bound, style, crafted, redBorder, itemHealth, brackets)
	local link = nil
	brackets = brackets or 1
	itemId = itemId or 0
	itemQuality = itemQuality or 0
	level = level or 0
	enchantment = enchantment or 0
	enchantmentQuality = enchantmentQuality or 0
	enchantmentLevel = enchantmentLevel or 0
	transmutation = transmutation or 0
	bound = bound or 1
	style = style or 0
	crafted = crafted or 0
	redBorder = redBorder or 0
	itemHealth = itemHealth or 10000
	if itemId ~= 0 then
		link = string.format(RdKGToolEquip.constants.EQUIPMENT_STRING, brackets, itemId, itemQuality, level, enchantment, enchantmentQuality, enchantmentLevel, transmutation, bound, style, crafted, redBorder, itemHealth)
		--d(link)
	end
	
	return link
end

function RdKGToolEquip.ChangeBrackets(link)
	local brackets = link:sub(3,3)
	if brackets == "1" then
		brackets = "0"
	elseif brackets == "0" then
		brackets = "1"
	end
	return link:sub(1,2) .. brackets .. link:sub(4)
end

function RdKGToolEquip.GetItemLinkEntry(link, index)
	local entry = nil
	if link ~= nil then
		local values = {zo_strsplit(":", link)}
		entry = tonumber(values[index])
	end
	return entry
end

function RdKGToolEquip.GetItemLinkEnchantmentId(link)
	return RdKGToolEquip.GetItemLinkEntry(link, 6)
end

function RdKGToolEquip.GetItemLinkEnchantmentQuality(link)
	return RdKGToolEquip.GetItemLinkEntry(link, 7)
end

function RdKGToolEquip.GetItemLinkEnchantmentLevel(link)
	return RdKGToolEquip.GetItemLinkEntry(link, 8)
end

function RdKGToolEquip.GetItemLinkItemId(link)
	return RdKGToolEquip.GetItemLinkEntry(link, 3)
end

function RdKGToolEquip.GetItemLinkItemQuality(link)
	return RdKGToolEquip.GetItemLinkEntry(link, 4)
end

function RdKGToolEquip.GetItemLinkItemLevel(link)
	return RdKGToolEquip.GetItemLinkEntry(link, 5)
end

function RdKGToolEquip.GetItemLinkTransmutationId(link)
	return RdKGToolEquip.GetItemLinkEntry(link, 9)
end

function RdKGToolEquip.GetItemLinkStyleId(link)
	return RdKGToolEquip.GetItemLinkEntry(link, 18)
end

function RdKGToolEquip.GetEquipmentNameFromMessagePrefix(messagePrefix)
	local equipmentName = nil
	if messagePrefix == RdKGToolEquip.constants.networking.messagePrefix.HEAD then
		equipmentName = "head"
	elseif messagePrefix == RdKGToolEquip.constants.networking.messagePrefix.SHOULDERS then
		equipmentName = "shoulders"
	elseif messagePrefix == RdKGToolEquip.constants.networking.messagePrefix.CHEST then
		equipmentName = "chest"
	elseif messagePrefix == RdKGToolEquip.constants.networking.messagePrefix.HANDS then
		equipmentName = "hands"
	elseif messagePrefix == RdKGToolEquip.constants.networking.messagePrefix.WAIST then
		equipmentName = "waist"
	elseif messagePrefix == RdKGToolEquip.constants.networking.messagePrefix.LEGS then
		equipmentName = "legs"
	elseif messagePrefix == RdKGToolEquip.constants.networking.messagePrefix.FEET then
		equipmentName = "feet"
	elseif messagePrefix == RdKGToolEquip.constants.networking.messagePrefix.NECKLACE then
		equipmentName = "necklace"
	elseif messagePrefix == RdKGToolEquip.constants.networking.messagePrefix.RING_1 then
		equipmentName = "ring1"
	elseif messagePrefix == RdKGToolEquip.constants.networking.messagePrefix.RING_2 then
		equipmentName = "ring2"
	elseif messagePrefix == RdKGToolEquip.constants.networking.messagePrefix.WEAPON_1_1 then
		equipmentName = "weapon11"
	elseif messagePrefix == RdKGToolEquip.constants.networking.messagePrefix.WEAPON_1_2 then
		equipmentName = "weapon12"
	elseif messagePrefix == RdKGToolEquip.constants.networking.messagePrefix.WEAPON_2_1 then
		equipmentName = "weapon21"
	elseif messagePrefix == RdKGToolEquip.constants.networking.messagePrefix.WEAPON_2_2 then
		equipmentName = "weapon22"
	end
	return equipmentName
end