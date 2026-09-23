PBTrade = {}
PBTrade.Config = {
    addonId = "PBsTradeGame", title = "PinkB's Tamriel Trade Game",
    displayTitle = "タムリエル交易戦", version = "0.5.7", scene = "pbTradeGame",
    playerId = "player", neutralId = "neutral", schemaVersion = 6,
    savedVariables="PBsTradeGameSavedVariables",
    -- Seconds, not frames. A fixed simulation step keeps 30/60/120fps equivalent.
    battle = {
        step = 1 / 60, maxFrameDelta = 0.25, duration = 150,
        gaugeLimit = 100, initialGauge = 0, maxVelocity = 8,
        pressureAcceleration = 4.0, baseAcceleration = 0.20, drag = 0.65,
        -- Border speed multiplier: centreSpeed at the middle rising to edgeSpeed at either end.
        -- paceScale sets the overall tempo: holding a lead of 30% of the value decides in ~30s.
        centerSpeed = .75, edgeSpeed = 2.4, edgeCurve = 1.8, paceScale = 2.0,
        momentumPerFunding = 0.65, maxMomentum = 2.6, momentumDecay = 0.13,
        priceFloor = 500, playerWait = 2.6, enemyWait = 4.0, enemyOpeningWait = 4.0,
        fundingProfitFactor = 3, fundingValueFactor = 0.025,
        fatiguePerRequest = 0.32, reserveProfitFactor = 14,
        openingEnemyBidFactor = 0.035, enemyBudgetFactor = 0.30,
        enemyBidFactor = 0.025, enemyBidVariation = 0.5,
        -- Treasury menu: amount that closes the bid gap (rounded up to two significant
        -- digits) plus neighbouring round steps on the 1-2-2.5-5 ladder.
        treasuryStepsEachSide = 2, treasuryMinimum = 100, treasuryLeadShare = .05, riskMax = 128,
        logLimit = 6, bandAnimationSeconds = 1.8, bandGlowWidth = 96, bandTipWidth=72,
    },
    independence = {safeThreshold=24, chancePerPoint=.0075, maxChance=.78,
        reacquireRisk=38, passiveRecovery=4, stabilizeCost=500, stabilizeAmount=32},
    groups = {accelerationBonus=.35, maxDiscoveriesPerRequest=1},
    tactics = {aiUseChance=.22, effectLimit=12},
    -- Tactic banner: seconds for the move, the opponent's reaction and the verdict.
    -- Two lines over the battle title; the negotiation keeps running underneath.
    tacticScene = {intro=.9, react=1.3, result=2.6, typeSpeed=34},
    campaign = {startingCash = 6500, unlockOwnedStep = 2, chapterOneAssets=50000},
    economy = {profitShare=.45,reserveRecoveryPeriods=4,enemyProfitShare=.35,
        rebuildThreshold=1000,rebuildGrant=2500,rebuildReputationCost=8,debtPaymentShare=.25},
    counterattack = {baseChance = .20, aggressionWeight = .30, maxChance = .60,
        minimumCash = 500, riskWeight = .4, headquartersWeight = .3},
    input = {deadzone = 0.45, firstRepeat = 0.32, repeatDelay = 0.15},
    ui = {width = 1240, height = 780, updateMs = 33, fullRefreshSeconds = .25, pageSize = 8, mapPageSize = 8, keybindHeight = 48},
    theme = {
        background={.035,.047,.045,1}, panel={.075,.090,.084,1},
        parchment={.18,.185,.157,1}, text={.83,.81,.72,1},
        gold={.61,.53,.36,1}, edge={.26,.28,.235,1},
        row={.11,.13,.115,1}, selected={.28,.29,.22,1},
        own={.12,.25,.23,1}, enemy={.29,.16,.17,1},
        neutral={.23,.22,.16,1}, locked={.12,.135,.125,1},
    },
    coins = {limit = 512, createPerFrame = 64, columns = 16, minUnit = 25, valueDivisor = 240,
        -- Every payment lands within `duration`: a dense opening volley whose share grows
        -- with the amount, then a tail whose gaps widen until the final coin.
        duration = 3, fastFlight = .28, slowFlight = .55, finalFlight = .70,
        volleyWindow = .35, volleyShareMin = .40, volleyShareMax = .70, tailPower = 2.2,
        deceleration = 2, minimumSprites = 8, width = 44, height = 22, stackStep = 8,
        pileWidth = 270, floorY = 202, tipY = 58, viewportHeight = 248,
        -- Back, middle, front: staggered ranks form a rounded bundle of coin pillars.
        ranks = {{count=5,x=30,y=-44,scale=.90,shade=.82},
            {count=6,x=9,y=-22,scale=.96,shade=.92},
            {count=5,x=30,y=0,scale=1,shade=1}},
        pillarSpacing = 44, plinthWidth = 302, plinthHeight = 96, plinthOffsetY = -52,
        maxFalling = 72, burstSprites = 96,
        soundEnabled = true, soundKey = "ITEM_MONEY_CHANGED", soundInterval = .18},
    uiSounds={tactic="DUEL_START",tacticSuccess="TELVAR_GAINED",tacticFail="GENERAL_ALERT_ERROR",discovery="ACHIEVEMENT_AWARDED",defection="GENERAL_ALERT_ERROR",
        chapter="QUEST_OBJECTIVE_STARTED",ending="ACHIEVEMENT_AWARDED",settlement="TELVAR_GAINED"},
}
