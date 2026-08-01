HowToSunspire = HowToSunspire or {}
local HowToSunspire = HowToSunspire

HowToSunspire.IceTombEffects = {
  [1] = 124687, -- inc
  [2] = 119638, -- set
}
-- summonFrost = 124046,

HowToSunspire.AbilitiesToTrack = {
    [120542] = HowToSunspire.PowerfulSlam, 		-- Ground slam from statue on nahvii HM

		-- [117976] = HowToSunspire.LivingStone,			-- Statue activates
		-- [120774] = HowToSunspire.HailofStones,		-- Invulnerability shield on statues when not channeling
		-- [120783] = HowToSunspire.HailofStones,		-- Channeled ability from statues on nahvii HM
		-- [120842] = HowToSunspire.HailofStones,		-- Individual charge of stones being launched
		-- [120853] = HowToSunspire.HailofStones,		-- Stacks of increased dmg

		[120838] = HowToSunspire.GlacialFist,			-- Glacial Fist from ice atronarchs on lokke

    -- 124046
    -- elseif (result == ACTION_RESULT_EFFECT_GAINED and abilityId == CombatAlertsData.sunspire.summonFrost) then
    -- CombatAlerts.sunspire.atroNext = GetGameTimeMilliseconds() + 90000

		[120567] = HowToSunspire.Stonefist,		 		-- Rock throw from statue on last boss

		[115723] = HowToSunspire.HeavyAttack, 		-- HA from lokke
		[123026] = HowToSunspire.HeavyAttack,			-- Wing Thrash from lokke
    [122124] = HowToSunspire.HeavyAttack, 		-- HA from yolna
		[121833] = HowToSunspire.HeavyAttack,			-- Wing Thrash from yolna
		[121849] = HowToSunspire.HeavyAttack,			-- Wing Thrash from yolna
    [115443] = HowToSunspire.HeavyAttack, 		-- HA from nahvii
		[119796] = HowToSunspire.HeavyAttack,			-- Wing Thrash from nahvii
    [121422] = HowToSunspire.HeavyAttack, 		-- HA from cone in portal
    [117071] = HowToSunspire.HeavyAttack, 		-- HA from 1H & Shield
		[119817] = HowToSunspire.HeavyAttack, 		-- Anvil Cracker from Iron Servant

    [117075] = HowToSunspire.ShieldCharge, 		-- shield charge from 1H & Shield

		[116836] = HowToSunspire.Leap, 						-- 2H adds leap -- [116915] = HowToSunspire.Leap,[116916] = HowToSunspire.Leap, [116918] = HowToSunspire.Leap,

		[120890] = HowToSunspire.Block, 					-- jump from the red cats
		[122012] = HowToSunspire.Block, 					-- jump from white cats

		[121075] = HowToSunspire.Comet, 					-- comet from portal (not on someone) 121074
		[120359] = HowToSunspire.Comet, 					-- comet from lokkestiiz that bump
		[116636] = HowToSunspire.Comet, 					-- comet from mage trash 116619
		[117251] = HowToSunspire.Comet, 					-- molten meteor veteran
		[123067] = HowToSunspire.Comet, 					-- molten meteor veteran

		[119283] = HowToSunspire.Breath, 					-- Frost Breath
		[121723] = HowToSunspire.Breath, 					-- Fire Breath
		[121980] = HowToSunspire.Breath, 					-- Searing Breath

    [119632] = HowToSunspire.IceTomb, 				-- ice tomb cast
    [116044] = HowToSunspire.InIce,           -- ice tomb taken

		[122820] = HowToSunspire.LokkeLaser, 			-- first jump of lokke
    [122821] = HowToSunspire.LokkeLaser, 			-- second jump of lokke
    [122822] = HowToSunspire.LokkeLaser, 			-- third jump of lokke

		-- [125924] = HowToSunspire.Flare, 					-- fire attro light attack on yolna
		-- [125926] = HowToSunspire.Flare, 					-- fire attro light attack on yolna
		-- [125927] = HowToSunspire.Flare, 					-- fire attro light attack on yolna

    [119549] = HowToSunspire.AtroSpawn, 			-- Fire Atro

		[124546] = HowToSunspire.LavaGeyser, 			-- lava geyser from fire atro
    [121722] = HowToSunspire.NextFlare, 			-- Focus fire casted
    [121459] = HowToSunspire.NextFlare, 			-- boss go fly

    -- yolna fly
    [124910] = HowToSunspire.TakeFlight,
    [124915] = HowToSunspire.TakeFlight,
    [124916] = HowToSunspire.TakeFlight,

    --[[
    -- nahvii fly
    [120921] = HowToSunspire.TakeFlight,
    [120991] = HowToSunspire.TakeFlight,
    [120992] = HowToSunspire.TakeFlight,
    ]]

    [122598] = HowToSunspire.Cata, 						-- Cataclysm

    [120188] = HowToSunspire.SweepingBreath, 	-- fire sweeping breath >>>>
    [118743] = HowToSunspire.SweepingBreath, 	-- fire sweeping breath <<<<

		[118860] = HowToSunspire.FireSpit, 				-- nahvii's spit that spawns an atronach during lokke and yolna fights
    [115592] = HowToSunspire.FireSpit, 				-- same but during nahvii fight

		[118562] = HowToSunspire.Thrash, 					-- thrash of nahvii

		[117526] = HowToSunspire.SoulTear, 				-- Soul tear

		[118884] = HowToSunspire.FireStorm, 			-- room explosion of nahvii

		[117308] = HowToSunspire.NextMeteor, 			-- entering phase 4

		[117938] = HowToSunspire.MarkForDeath, 		-- cast debuff on tank

    [121676] = HowToSunspire.Portal, 					-- Portal spawn

		[121213] = HowToSunspire.PortalEnter, 		-- Portal used

	  [121254] = HowToSunspire.PortalExit, 			-- return to reality

		[121436] = HowToSunspire.PortalInterrupt,	-- eternal servants channeled wipe mechanic

	  [121411] = HowToSunspire.NegateField, 		-- negate in portal

		-- [123103] = HowToSunspire.BossHealth,			-- AoE under lokke when grounded
		-- [121459] = HowToSunspire.BossHealth,			-- AoE under yolna when grounded
		-- [120031] = HowToSunspire.BossHealth,			-- AoE under nahvii when grounded
}

--Add a notification :
    --add the ID here with a function
    --main file :
        --create the corresping function
        --create the UI function
        --add default values
        --add new events / variables to the reset function
    --settings file :
        --add to unlock all
        --add an enable / unlock option
        --add to the text size
    --UI file :
        --add to the init function
        --add the saveLoc function
    --XML file :
        --add th new part of UI
