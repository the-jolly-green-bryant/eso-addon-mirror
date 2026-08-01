local BR = BRHelper

BRHelperAbilities = {

	[5363] = BR.HeavyAttack,

	[114578] = BR.PortalSpawn,

	-- taking aims
	[110898] = BR.TakingAim, -- Tames-the-Beast
	[111209] = BR.TakingAim,
	[113146] = BR.TakingAim,

	-- 1st boss
	[110814] = BR.HeavyAttack,
	[111022] = BR.Meteor,

	-- 2nd arena
	[71787] = BR.ImpendingStorm, -- Wamasu aoe
	[113208] = BR.Shockwave, -- Haj mota aoe
	[110181] = BR.BugBomb, -- 2nd bosss stacking mechanic

	-- 3rd arena
	[99539] = BR.FocalQuake, -- Gargoyle aoe
	[99527] = BR.HeavyAttack, -- Gargoyle
	[111541] = BR.HeavyAttack, -- Lady Minara
	[92892] = BR.HeavyAttack, -- Colossus
	[110271] = BR.MinarasCurse,
	[111683] = BR.DrainEssence,
	[111659] = BR.BatSwarm,

	-- 5th arena
	[29378] = BR.HeavyAttack, -- Skeleton
	[113396] = BR.HeavyAttack, -- Skeleton
	[111871] = BR.HeavyAttack, -- Boss
	[114443] = BR.StoneTotem,
	[114803] = BR.DefilingEruption,
	[114453] = BR.ChillSpearCast,
	[114455] = BR.ChillSpear,
	[113385] = BR.Void,
	[114629] = BR.Void,
	[111881] = BR.BarrageOfStone,
	[110661] = BR.SpiritScream,
	[111887] = BR.RumblingSmash,

	-- Avoid death (when bosses despawn, the only interesting one is Lady Minara to stop swarm countdown)
	[112155] = BR.AvoidDeath,
	[112158] = BR.AvoidDeath,
	[112834] = BR.AvoidDeath,

}