local LKT = LibKeepTooltip
local underAttackBuffer = {}

local EVENT_NAMESPACE = 'IMP_KT_SIEGETIMER'

local function FormatSeconds(seconds)
	local minutes = math.floor(seconds / 60) % 60
	local hours = math.floor(seconds / 60 / 60)

	local remainingSeconds = seconds % 60

	if hours == 0 then
		return string.format('%d:%02d', minutes, remainingSeconds)
	else
		return string.format('%d:%02d:%02d', hours, minutes, remainingSeconds)
	end
end

local function AddKeepUnderAttackLine(self)
    local keepId = self.keepId
    local battlegroundContext = self.battlegroundContext

    local showUnderAttackLine = GetKeepUnderAttack(keepId, battlegroundContext)
    if not showUnderAttackLine then return end

    local text = GetString(SI_TOOLTIP_KEEP_IN_COMBAT)

    local siegeStartTimestamp = underAttackBuffer[keepId]
    if siegeStartTimestamp then
        local siegeDuration = GetDiffBetweenTimeStamps(GetTimeStamp(), siegeStartTimestamp)
        text = string.format('%s (%s)', text, FormatSeconds(siegeDuration))
    end

    LKT.AddLine(self, text, LKT.KEEP_TOOLTIP_ATTACK_LINE)
end

local function OnKeepUnderAttack(_, keepId, battlegroundContext, underAttack)
    if not IsLocalBattlegroundContext(battlegroundContext) then return end

    if underAttack then
        underAttackBuffer[keepId] = GetTimeStamp()
    else
        underAttackBuffer[keepId] = nil
    end
end

function IMP_KT_SiegeTimer_Initialize()
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_KEEP_UNDER_ATTACK_CHANGED, OnKeepUnderAttack)
    LKT:ReplaceIngridient(LKT.INGRIDIENTS.KEEP_UNDER_ATTACK, AddKeepUnderAttackLine)
end