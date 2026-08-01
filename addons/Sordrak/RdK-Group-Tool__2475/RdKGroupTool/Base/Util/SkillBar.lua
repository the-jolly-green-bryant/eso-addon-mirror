-- RdK Group Tool Skill Bar
-- By @s0rdrak (PC / EU)

RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.sb = RdKGToolUtil.sb or {}
local RdKGToolSB = RdKGToolUtil.sb


RdKGToolSB.callbackName = RdKGTool.addonName .. "SkillBar"

RdKGToolSB.config = {}
RdKGToolSB.config.interval = 1000

RdKGToolSB.state = {}
RdKGToolSB.state.bar = {}

RdKGToolSB.constants = {}
RdKGToolSB.constants.networking = {}
RdKGToolSB.constants.networking.messagePrefix = {}
RdKGToolSB.constants.networking.messagePrefix.BAR_1_SKILL_1 = 0
RdKGToolSB.constants.networking.messagePrefix.BAR_1_SKILL_2 = 1
RdKGToolSB.constants.networking.messagePrefix.BAR_1_SKILL_3 = 2
RdKGToolSB.constants.networking.messagePrefix.BAR_1_SKILL_4 = 3
RdKGToolSB.constants.networking.messagePrefix.BAR_1_SKILL_5 = 4
RdKGToolSB.constants.networking.messagePrefix.BAR_1_ULTIMATE = 5
RdKGToolSB.constants.networking.messagePrefix.BAR_2_SKILL_1 = 6
RdKGToolSB.constants.networking.messagePrefix.BAR_2_SKILL_2 = 7
RdKGToolSB.constants.networking.messagePrefix.BAR_2_SKILL_3 = 8
RdKGToolSB.constants.networking.messagePrefix.BAR_2_SKILL_4 = 9
RdKGToolSB.constants.networking.messagePrefix.BAR_2_SKILL_5 = 10
RdKGToolSB.constants.networking.messagePrefix.BAR_2_ULTIMATE = 11

--[[
/script for i = 1, 32 do d(GetAbilityName(GetSlotBoundId(i))) end
]]

function RdKGToolSB.Initialize()
	EVENT_MANAGER:RegisterForEvent(RdKGToolSB.callbackName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, RdKGToolSB.OnWeaponPairChanged)
	EVENT_MANAGER:RegisterForEvent(RdKGToolSB.callbackName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, RdKGToolSB.OnSlotsAllHotbarsUpdated)
	EVENT_MANAGER:RegisterForEvent(RdKGToolSB.callbackName, EVENT_ACTION_SLOT_UPDATED, RdKGToolSB.OnSlotUpdated)
	RdKGToolSB.UpdateSkillBarInformation()
end

function RdKGToolSB.GetSkillBars()
	return RdKGToolSB.state.bar
end

function RdKGToolSB.UpdateSkillBarInformation()
	local activeWeapon, locked = GetActiveWeaponPairInfo()
	local bar = RdKGToolSB.state.bar
	bar[activeWeapon] = bar[activeWeapon] or {}
	bar[activeWeapon][1] = GetSlotBoundId(3)
	bar[activeWeapon][2] = GetSlotBoundId(4)
	bar[activeWeapon][3] = GetSlotBoundId(5)
	bar[activeWeapon][4] = GetSlotBoundId(6)
	bar[activeWeapon][5] = GetSlotBoundId(7)
	bar[activeWeapon][6] = GetSlotBoundId(8)
end

--callbacks
function RdKGToolSB.OnWeaponPairChanged(eventCode, activeWeaponPair, locked)
	RdKGToolSB.UpdateSkillBarInformation()
end

function RdKGToolSB.OnSlotsAllHotbarsUpdated(eventCode)
	--d("debug")
	RdKGToolSB.UpdateSkillBarInformation()
end

function RdKGToolSB.OnSlotUpdated(eventCode)
	--d("debug")
	RdKGToolSB.UpdateSkillBarInformation()
end
