local missingParameter = {}

local AddStatRowOrg = ZO_Stats.AddStatRow
ZO_Stats.AddStatRow = function(...)
	missingParameter = (select(1,...))
	local ret = AddStatRowOrg(...)
	ZO_Stats.AddStatRow = AddStatRowOrg
	return ret
end

local CreateAttributesSectionOrg = ZO_Stats.CreateAttributesSection
ZO_Stats.CreateAttributesSection = function(...)
	local ret = CreateAttributesSectionOrg(...)
	ZO_Stats.SetNextControlPadding(missingParameter,20)
	ZO_Stats.AddStatRow(missingParameter, STAT_ATTACK_POWER, STAT_HEALTH_REGEN_IDLE)
	ZO_Stats.SetNextControlPadding(missingParameter,0)
	ZO_Stats.AddStatRow(missingParameter, STAT_SPELL_PENETRATION, STAT_MAGICKA_REGEN_IDLE)
	ZO_Stats.SetNextControlPadding(missingParameter,0)
	ZO_Stats.AddStatRow(missingParameter, STAT_PHYSICAL_PENETRATION, STAT_STAMINA_REGEN_IDLE)
	ZO_Stats.SetNextControlPadding(missingParameter,0)
	ZO_Stats.AddStatRow(missingParameter,STAT_SPELL_MITIGATION,STAT_MITIGATION)
	ZO_Stats.SetNextControlPadding(missingParameter,0)
	ZO_Stats.AddStatRow(missingParameter,STAT_HEALING_TAKEN, STAT_CRITICAL_RESISTANCE)
	
	ZO_Stats.SetNextControlPadding(missingParameter,20)
	ZO_Stats.AddStatRow(missingParameter,STAT_DAMAGE_RESIST_COLD,STAT_DAMAGE_RESIST_DISEASE)
	ZO_Stats.SetNextControlPadding(missingParameter,0)
	ZO_Stats.AddStatRow(missingParameter,STAT_DAMAGE_RESIST_DROWN,STAT_DAMAGE_RESIST_EARTH)
	ZO_Stats.SetNextControlPadding(missingParameter,0)
	ZO_Stats.AddStatRow(missingParameter,STAT_DAMAGE_RESIST_FIRE,STAT_DAMAGE_RESIST_GENERIC)
	ZO_Stats.SetNextControlPadding(missingParameter,0)
	ZO_Stats.AddStatRow(missingParameter,STAT_DAMAGE_RESIST_MAGIC,STAT_DAMAGE_RESIST_OBLIVION)
	ZO_Stats.SetNextControlPadding(missingParameter,0)
	ZO_Stats.AddStatRow(missingParameter,STAT_DAMAGE_RESIST_PHYSICAL,STAT_DAMAGE_RESIST_POISON)
	ZO_Stats.SetNextControlPadding(missingParameter,0)
	ZO_Stats.AddStatRow(missingParameter,STAT_DAMAGE_RESIST_SHOCK,STAT_NONE)
	
	ZO_Stats.SetNextControlPadding(missingParameter,20)
	ZO_Stats.AddStatRow(missingParameter,STAT_DODGE,STAT_BLOCK)
	ZO_Stats.SetNextControlPadding(missingParameter,0)
	ZO_Stats.AddStatRow(missingParameter,STAT_PARRY,STAT_MISS)
	return ret
end