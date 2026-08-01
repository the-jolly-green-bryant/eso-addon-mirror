local LCA = LibCombatAlerts
local CA1 = CombatAlerts
local CA2 = CombatAlerts2
local Module = CA_Module:Subclass()

Module.ID = "LCH_U42"
Module.NAME = "Lucent Citadel Helper CCA dodge alerts module"
Module.AUTHOR = "Wondernuts"
Module.ZONES = {
	1478, -- Lucent Citadel
}

function Module:Initialize( )
	self.TIMER_ALERTS_LEGACY = {
		--[[ Options ---------------------------------------
		1: Size of alert window
			0: None
			>0: Time, in milliseconds
			-1: Default (auto-detect)
			-2: Default (melee)
			-3: Default (projectile)
		2: Alert text/ping (ignored if alert window is 0)
			0: Never
			1: Always
			2: Suppressed for tanks
		3: Interruptible (optional, default false)
		4: Color, regular (optional)
		5: Color, alerted (optional)
		vet: Vet-only?
		offset: Offset to reported hitValue, in milliseconds
		--------------------------------------------------]]
    [218710] = { -2, 2 }, -- Darkcaster Slasher Butcher
    --[222271] = { -2, 2 }, -- Zilyesset Heavy Strike
    --[218274] = { -2, 2 }, -- Count Ryelaz Shear
    --[219420] = { -2, 2 }, -- Cavot Agnan Smite
    --[217971] = { -2, 2 }, -- Orphic Shattered Shard Heavy Strike
    [213685] = { -2, 2 }, -- Orphic Shattered Shard Shockwave
    --[221863] = { -2, 2 }, -- Crystal Hollow Sentinel Heavy Attack
    [221877] = { -2, 2 }, -- Ruinach Frenzy
    [221886] = { -3, 2, false, { 1, 0.4, 0, 0.5 }}, -- Ruinach Bouncing Flames
    [219791] = { -2, 2 }, -- Crystal Atronach Crystal Spear
    [219792] = { -2, 2 }, -- Crystal Atronach Crunch
    --[219793] = { -2, 2,  }, -- Crystal Atronach Crushing Shards
    --[222605] = { -2, 2 }, -- Baron Rize Shear
    [223546] = { -3, 2 }, -- Mantikora Javelin
    [219030] = { -2, 1 }, -- Jresazzel Power Bash
}
end

CA2.RegisterModule(Module)
