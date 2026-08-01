local WW = WizardsWardrobe
WW.zones["AC"] = {}
local AC = WW.zones["AC"]

AC.name = GetString(WWE_AC_NAME)
AC.tag = "AC"
AC.icon = "esoui/art/icons/achievement_025"
AC.priority = 113
AC.id = 148
AC.node = 192
AC.category = WW.ACTIVITIES.DUNGEONS

AC.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_AC_BOSS1),
	}, [3] = {
		name = GetString(WWE_AC_BOSS2),
	}, [4] = {
		name = GetString(WWE_AC_BOSS3),
	}, [5] = {
		name = GetString(WWE_AC_BOSS4),
	}, [6] = {
		name = GetString(WWE_AC_BOSS5),
	}, [7] = {
		name = GetString(WWE_AC_BOSS6),
	},
}

function AC.Init()

end

function AC.Reset()

end

function AC.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
