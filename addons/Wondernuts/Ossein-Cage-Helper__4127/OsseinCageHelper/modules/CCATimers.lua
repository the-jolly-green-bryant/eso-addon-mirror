local LCA = LibCombatAlerts
local CA1 = CombatAlerts
local CA2 = CombatAlerts2
local Module = CA_Module:Subclass()

Module.ID = "OCH_U46"
Module.NAME = "Ossein Cage Helper CCA dodge alerts module"
Module.AUTHOR = "Wondernuts"
Module.ZONES = {
	1548, -- Ossein Cage
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
		[236466] = { -2, 2 }, -- Harvester Ethereal Burst
		[236458] = { -2, 2 }, -- Harvester Potent Ethereal Burst
		[236273] = { -3, 2 }, -- Harvester Ethereal Fire
		[232601] = { -2, 2 }, -- Abomination of Flesh Hemorrhaging Strike
		[232600] = { -2, 2 }, -- Abomination of Flesh Sweep
		[232599] = { -2, 2 }, -- Abomination of Flesh Rancid Hammer
		[232598] = { -2, 2 }, -- Abomination of Flesh Tremor
		[236510] = { -2, 2 }, -- Realm Shaper Smite
		[236357] = { -2, 2 }, -- Daedroth Jagged Claw
		[236381] = { -3, 2, true }, -- Coldharbour Sinewshot True Shot
		[239158] = { -3, 2, true }, -- Osteon Skeletal Archer True Shot
		[245485] = { -2, 2 }, -- Osteon Bloodknight Cross Swipe
		[240984] = { -2, 2 }, -- Channeler Heavy Strike
		[236871] = { -2, 2 }, -- Enlightened Channeler Heavy Strike
		[236957] = { -2, 2 }, -- Tormented Carrion Reaper Murder
		[236477] = { -2, 0 }, -- Tormented Skullmancer Spike Cage
		[245402] = { -2, 0 }, -- Osteon Skeletal Werewolf Rending Leap
		[236569] = { -2, 1, vet = true }, -- Spectral Revenant Spectral Revenge

		[238800] = { -3, 2, true }, -- Red Witch Gedna Relvel Phantasmal Barrage
		[239884] = { -2, 2 }, -- Tortured Kathutet Branding Strike
		[239983] = { -2, 2 }, -- Tortured Ranyu Sunburst
		[239662] = { -2, 2 }, -- Tortured Amkaos Cataclysmic Thrust
		[239637] = { -2, 2 }, -- Blood Drinker Thisa Cross Swipe

		[233596] = { -2, 2, offset = -400 }, -- Jynorah Incinerating Smash
		[233720] = { -3, 2, offset = -1100 }, -- Jynorah Spark Surge Bolt
		[233606] = { -2, 2, offset = -400 }, -- Skorkhif Incinerating Smash
		[233751] = { -3, 2, offset = -1100 }, -- Skorkhif Spark Surge Bolt

		[245157] = { -2, 2, offset = -400 }, -- Blazing Brimstone Aspect Incinerating Smash
		[245161] = { -2, 2, offset = -400 }, -- Blazing Brimstone Aspect Blazing Smash
		[245140] = { -3, 2, offset = -1100 }, -- Blazing Brimstone Aspect Incinerating Bolt
		[245131] = { -3, 2, offset = -1100 }, -- Sparking Cold-Flame Aspect Spark Surge Bolt
		[245135] = { -3, 2, offset = -1100 }, -- Sparking Cold-Flame Aspect Spark Surge Bolt
		[245149] = { -2, 2, offset = -400 }, -- Sparking Cold-Flame Aspect Incinerating Smash
		[245154] = { -2, 2, offset = -400 }, -- Sparking Cold-Flame Aspect Spark Smash
		[239378] = { -3, 2, offset = -1100 }, -- Sparking Cold-Flame Aspect Incinerating Bolt

		[236372] = { -2, 2 }, -- Sparking Shackled Titan Bat
		[234621] = { -3, 2 }, -- Blazing Daedroth Burst of Embers

		[232722] = { -2, 2 }, -- Overfiend Kazpian Frenzy
		[245273] = { -2, 2 }, -- Ossein Colossus Bone Saw
		[245247] = { -2, 2 }, -- King Khrogo Firebomb
		[245318] = { -3, 0, true }, -- Fear Mage Aspect of Terror
	}
end

CA2.RegisterModule(Module)
