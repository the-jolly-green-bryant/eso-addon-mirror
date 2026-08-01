local MP = Mephisto
MP.zones[ "IA" ] = {}
local IA = MP.zones[ "IA" ]

IA.name = zo_strformat( "<<t:1>>", GetZoneNameById( 1436 ) )
IA.tag = "IA"
IA.icon = "/esoui/art/icons/achievement_u40_ed2_defeat_final_boss_50.dds"
IA.priority = 54
IA.id = 1436
IA.node = 550

IA.bosses = {
	[ 1 ] = {
		name = GetString( MP_TRASH ),
	},
	[ 2 ] = {
		name = GetString( MP_SUB_BOSS ),
	},
}

function IA.Init()

end

function IA.Reset()

end

function IA.OnBossChange( bossName )
	if #bossName > 0 then
		MP.conditions.OnBossChange( GetString( MP_SUB_BOSS ) )
	else
		MP.conditions.OnBossChange( bossName )
	end
end
