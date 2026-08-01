CombatInsights = {
    name = 'CombatInsights',
    variableVersion = 2,
    version = "1.2.2",
    addonVersion = 10202,

    analyses = {},

    -- Settings
    defaults = {
        ui = {
            left = 400,
            top = 300,
            width = 600,
            height = 700,
        },
    },
}

local Fights = CombatInsightsFights
local Consts = CombatInsightsConsts
local ReportUI = CombatInsightsReportUI
local Utils = CombatInsightsUtils
local Async = LibAsync
local Analysis = CombatInsightsAnalysis
local CalculationCfg = CombatInsightsCalculationCfg

local logger=Utils.CreateSubLogger("main")
local self=CombatInsights

local function debugPrint(message, ...)
    df("[CI]: %s", message:format(...))
end


function CombatInsights.PrintMessage(message, ...)
    local msg = message:format(...)
    df("[|c66a7f5Combat|r|c0fcc0fInsights|r]: %s", msg)
end

local function PredicateCpYesNo(player, cp1, cp2)
    return player.cps[cp1] and not player.cps[cp2]
end

local function PredicateHasCpEquipped(player, cp)
    return player.cps[cp]
end

local function PredicateHasEmptyCpSlot(player)
    local n = 0
    for cp,_ in pairs(Consts.slottableCpIds) do
        if player.cps[cp] then n = n + 1 end
    end
    return n < 4
end

local function handleFightSelection()
    local cmxData = CMX.GetAbilityStats()
    if not cmxData then return end
    local cmxFight = CMX.GetAbilityStats()[1]
    if not cmxFight then return end
    local fightUID = Utils.CMXFightUID(cmxFight)

    if not self.lastFightUID or self.lastFightUID ~= fightUID then
        if self.analysis and self.analysis.taskRunning then
            -- if there is already an analysis in progress for a fight just ignore the change
            return
        end

        local stored = self.analyses[fightUID]
        if stored then
            ReportUI.SetData(stored)
        else
            ReportUI.SetData(nil)
        end
        self.lastFightUID = fightUID
    end
end

local function BeginAnalysis(fightDataImport)
    if not fightDataImport then
        local f, version, isSelection = CMX.GetAbilityStats()
        fightDataImport = f
    end
    -- if not fightDataImport then
    --     UI.SetTextError("Please select a fight in CMX")
    --     return
    -- end
    
    self.analysis = Analysis:New(fightDataImport, self.calculationConfigs)
    if self.analysis.error then
        CombatInsightsReportUI.SetData(self.analysis)
        return
    end
    local analysis = self.analysis

    analysis.taskStartedAt = GetGameTimeMilliseconds()
    analysis.task = Async:Create("CombatInsightsReplayTask")
    analysis.taskRunning = true
    analysis.taskFinished = false
    CombatInsightsReportUI.SetData(self.analysis)


    local function customiter(a, i)
        local tbl1 = a[2]
        local tbl2 = a[3]
        i[2] = i[2] + 1
        local v1 = tbl1[i[1]]
        local v2 = tbl2[i[2]]
        if v1 and v2 then
            return i,{a[1], v1, v2}
        else
            i[1] = i[1] + 1
            i[2] = 1
            v1 = tbl1[i[1]]
            v2 = tbl2[i[2]]
            if v1 and v2 then
                return i,{a[1], v1, v2}
            end
        end
    end

    local function customIpairs(o, t1, t2)
        return customiter, {o, t1, t2}, {1,0}
    end

    local function dispatchCustomIterator(i,v) Analysis.ProcessHitDiff(v[1],i[1],i[2]) end

    analysis.task:For(1, #analysis.cmxFight.log)
    --first iteration we process the log line by line
    :Do(function(index) self.analysis:ProcessLogLine(index) end)
    --next we calculate the modifiers for all hits (we cant do this without the full log sooner because multiple enemy hit modifiers for pulsar, azure etc...)
    :Then(function()
        self.analysis:CalculateBaseHits()
        analysis.task
        --then this will call Analysis.ProcessHitDiff for reach hit/calculation with 1-1 iteration per call
        :For(customIpairs(self.analysis, self.analysis.hits, self.analysis.calculations))
        :Do(dispatchCustomIterator)
            :Then(function()
            analysis.taskFinished = true
         end)
     end)
     :Then(function()
        CombatInsights.PrintMessage("Your report is ready!")
        CombatInsightsReportUI.SetData(self.analysis)
        -- handling the edgecase where there was an analsysis running in background and the user selected another fight
        -- in this case the handler blocked the page change on the UI but now we can carry it out
        handleFightSelection()
        analysis.taskFinished = true
      end)
     :OnError(function(task)
        task:Cancel()
        -- this will show the error on the UI
        CombatInsightsReportUI.SetData(self.analysis)
        handleFightSelection()
     end)
     :Finally(function()
        analysis.taskRunning = false
        CombatInsightsReportUI.SetData(self.analysis)
        handleFightSelection()
        self.analyses[Utils.CMXFightUID(self.analysis.cmxFight)] = self.analysis
    end)
end

function CombatInsights.onStartButtonPressed()
    if self.analysis and self.analysis.taskRunning then
        self.analysis.taskCancelled = true
        self.analysis.task:Cancel()
        CombatInsightsReportUI.SetData(self.analysis)
        return
    else
        BeginAnalysis()
    end
end


function CombatInsights.AnalyzeFight()
    BeginAnalysis()
end


local function createCalcConfigDebuff(category, debuffKey)
    local abilityId = Consts.debuffs[debuffKey]
    return CalculationCfg:New(category, GetAbilityName(abilityId),
        LibCombat.GetFormattedAbilityIcon(abilityId), nil, function(hit) return hit.target[debuffKey] end,
        function(hit) return hit:ChangeTargetDebuff(debuffKey, false) end, function(hit) return hit:ChangeTargetDebuff(debuffKey, true) end )
end

local function createCalcConfigDebuffLossOnly(category, debuffKey)
    local abilityId = Consts.debuffs[debuffKey]
    return CalculationCfg:New(category, GetAbilityName(abilityId),
        LibCombat.GetFormattedAbilityIcon(abilityId), nil, function(hit) return hit.target[debuffKey] end,
        function(hit) return hit:ChangeTargetDebuff(debuffKey, false) end, nil )
end

local function createCalcConfigBuff(category, buffKey)
    local abilityId = Consts.buffs[buffKey]
    return CalculationCfg:New(category, GetAbilityName(abilityId),
        LibCombat.GetFormattedAbilityIcon(abilityId), nil, function(hit) return hit.player.buffs[buffKey] end,
        function(hit) return hit:ChangePlayerBuff(buffKey, false) end, function(hit) return hit:ChangePlayerBuff(buffKey, true) end )
end

local function createCalcConfigCPEquip(cpkey1)
    return CalculationCfg:New("cp", "Slotting " .. GetChampionSkillName(Consts.slottableCpIds[cpkey1]),
        "esoui/art/mainmenu/menubar_champion_up.dds",
        function(p) return PredicateHasEmptyCpSlot(p) and not PredicateHasCpEquipped(p, cpkey1) end,
        nil,
        nil,
        function(hit) return hit:ChangeCp(cpkey1, true) end )
end

local function createCalcConfigCPRemove(cpkey1)
    return CalculationCfg:New("cp", GetChampionSkillName(Consts.slottableCpIds[cpkey1]),
        "esoui/art/mainmenu/menubar_champion_up.dds",
        function(p) return PredicateHasCpEquipped(p, cpkey1) end,
        nil,
        function(hit) return hit:ChangeCp(cpkey1, false) end,
        nil )
end


local function createCalcConfigCPChange(cpkey1, cpkey2)

    return CalculationCfg:New("cp", GetChampionSkillName(Consts.slottableCpIds[cpkey1]) .. " -> " .. GetChampionSkillName(Consts.slottableCpIds[cpkey2]),
        "esoui/art/mainmenu/menubar_champion_up.dds",
        function(p) return PredicateCpYesNo(p, cpkey1, cpkey2) end,
        nil,
        nil,
        function(hit) return hit:ChangeCp(cpkey1, false):ChangeCp(cpkey2, true) end )
end

local function createCalcConfigSet(category, setname, bar)

    return CalculationCfg:New(category, Utils.GetSetName(Consts.sets[setname].iln) .. " on bar " .. tostring(bar),
        -- "/esoui/art/mainmenu/menubar_skills",
        Consts.sets[setname].icon,
        nil,
        function(hit) return hit.player.stats.activeBar == bar and hit.player.gear.sets[setname][bar] end,
        function(hit) return hit:ChangeSet(setname, bar, false) end,
        function(hit) return hit:ChangeSet(setname, bar, true) end)
end

local function initDiffTable()

    self.calculationConfigs =
    {
        createCalcConfigDebuff("pen", "majorBreach"),
        createCalcConfigDebuff("pen", "minorBreach"),
        createCalcConfigDebuff("pen", "crusher"),
        createCalcConfigDebuff("pen", "alkosh"),
        createCalcConfigDebuff("pen", "crimsonOath"),
        createCalcConfigDebuff("pen", "tremorscale"),
        createCalcConfigDebuff("pen", "crystalWeapon"),
        createCalcConfigDebuff("pen", "runicSunder"),
        createCalcConfigDebuff("debuffs", "minorBrittle"),
        createCalcConfigDebuff("debuffs", "majorBrittle"),
        createCalcConfigDebuff("debuffs", "flameWeakness"),
        createCalcConfigDebuff("debuffs", "frostWeakness"),
        createCalcConfigDebuff("debuffs", "shockWeakness"),
        createCalcConfigDebuff("debuffs", "minorVuln"),
        createCalcConfigDebuff("debuffs", "majorVuln"),
        createCalcConfigDebuffLossOnly("debuffs", "zen"),
        createCalcConfigDebuffLossOnly("debuffs", "mk"),
        createCalcConfigDebuff("debuffs", "engulfing"),
        createCalcConfigDebuffLossOnly("debuffs", "encratis"),
        createCalcConfigDebuff("debuffs", "abyssalInk"),
        CalculationCfg:New("debuffs", GetAbilityName(Consts.debuffs["stagger"]),
            LibCombat.GetFormattedAbilityIcon(Consts.debuffs["stagger"]), nil, function(hit) return hit.target["stagger"] end,
            function(hit) return hit:ChangeDebuffStagger(0) end, function(hit) return hit:ChangeDebuffStagger(3) end ),

        CalculationCfg:New("debuffs", GetAbilityName(Consts.debuffs["offBalance"]),
            LibCombat.GetFormattedAbilityIcon(Consts.debuffs["offBalance"]), nil, function(hit) return hit.target["offBalance"] end,
            nil, nil ),
        createCalcConfigDebuff("debuffs", "magicKnife"),

        createCalcConfigBuff("buffs", "minorBerserk"),
        createCalcConfigBuff("buffs", "majorBerserk"),
        createCalcConfigBuff("buffs", "minorSlayer"),
        createCalcConfigBuff("buffs", "majorSlayer"),
        createCalcConfigBuff("buffs", "minorForce"),
        createCalcConfigBuff("buffs", "majorForce"),
        createCalcConfigBuff("buffs", "sulxan"),
        
        createCalcConfigBuff("buffs", "minorCourage"),
        createCalcConfigBuff("buffs", "majorCourage"),
        createCalcConfigBuff("buffs", "powerfulAssault"),
        createCalcConfigBuff("buffs", "auraOfPride"),
        createCalcConfigBuff("buffs", "weaponDmgEnchant"),
        createCalcConfigBuff("buffs", "sunderer"),
        createCalcConfigBuff("buffs", "aggressiveHorn"),
        createCalcConfigBuff("buffs", "graveLordsSacrifice"),

        CalculationCfg:New("buffs", "Banner - Fire (dot)", LibCombat.GetFormattedAbilityIcon(Consts.buffs.fieryBanner), nil,
            function(hit) return hit.player.buffs.fieryBanner end,
            function(hit) return hit:ChangePlayerBuff("fieryBanner", false) end,
            function(hit) return hit:ChangePlayerBuff("fieryBanner", true) end),

        CalculationCfg:New("buffs", "Banner - Magic", LibCombat.GetFormattedAbilityIcon(Consts.buffs.magicalBanner), nil,
            function(hit) return hit.player.buffs.magicalBanner end,
            function(hit) return hit:ChangePlayerBuff("magicalBanner", false) end,
            function(hit) return hit:ChangePlayerBuff("magicalBanner", true) end),

        CalculationCfg:New("buffs", "Banner - Multi (aoe)", LibCombat.GetFormattedAbilityIcon(Consts.buffs.shatteringBanner), nil,
            function(hit) return hit.player.buffs.shatteringBanner end,
            function(hit) return hit:ChangePlayerBuff("shatteringBanner", false) end,
            function(hit) return hit:ChangePlayerBuff("shatteringBanner", true) end),

        CalculationCfg:New("buffs", "Banner - Physical (martial)", LibCombat.GetFormattedAbilityIcon(Consts.buffs.sunderingBanner), nil,
            function(hit) return hit.player.buffs.sunderingBanner end,
            function(hit) return hit:ChangePlayerBuff("sunderingBanner", false) end,
            function(hit) return hit:ChangePlayerBuff("sunderingBanner", true) end),

        CalculationCfg:New("buffs", "Banner - Shock (direct)", LibCombat.GetFormattedAbilityIcon(Consts.buffs.shockingBanner), nil,
            function(hit) return hit.player.buffs.shockingBanner end,
            function(hit) return hit:ChangePlayerBuff("shockingBanner", false) end,
            function(hit) return hit:ChangePlayerBuff("shockingBanner", true) end),

        CalculationCfg:New("buffs", "Sluthrug set",
            LibCombat.GetFormattedAbilityIcon(Consts.buffs.bloodhungry),
            nil,
            function(hit) return hit.player.buffs.bloodhungry and hit.target.bloodied end,
            function(hit) return hit:ChangePlayerBuff("bloodhungry", false):ChangeTargetDebuff("bloodied", false) end,
            function(hit) return hit:ChangePlayerBuff("bloodhungry", true):ChangeTargetDebuff("bloodied", true) end),


        CalculationCfg:New("gear", "Changing 1 light piece to medium",
            "/esoui/art/mainmenu/menubar_skills",
            function(player) return player.gear.numLightArmor > 0 end,
            nil,
            nil,
            function(hit) return hit:RemoveLightArmorPiece():AddMediumArmorPiece() end ),

        CalculationCfg:New("gear", "Changing 1 medium piece to light",
            "/esoui/art/mainmenu/menubar_skills",
            function(player) return player.gear.numMediumArmor > 0 end,
            nil,
            nil,
            function(hit) return hit:RemoveMediumArmorPiece():AddLightArmorPiece() end ),

        createCalcConfigSet("gear", "deadly", 1),
        createCalcConfigSet("gear", "deadly", 2),

        CalculationCfg:New("gear", Utils.GetSetName(Consts.sets.velothi.iln),
            Consts.sets.velothi.icon,
            nil,
            function(hit) return hit.player.gear.sets["velothi"][1] end,
            function(hit) return hit:ChangeSetVelothi(false) end,
            function(hit) return hit:ChangeSetVelothi(true) end),

        CalculationCfg:New("gear", Utils.GetSetName(Consts.sets.kilt.iln),
            Consts.sets.kilt.icon,
            nil,
            function(hit) return hit.player.gear.sets["kilt"][1] end,
            function(hit) return hit:ChangeSetKilt(false) end,
            function(hit) return hit:ChangeSetKilt(true) end),

        CalculationCfg:New("gear", Utils.GetSetName(Consts.sets.coral.iln) .. " on bar 1",
            Consts.sets.coral.icon, nil,
            function(hit) return hit.player.stats.activeBar == 1 and hit.player.gear.sets["coral"][1] end,
            function(hit) return hit:ChangeSet("coral", 1, false) end,
            function(hit) return hit:ChangeSet("coral", 1, true):ChangeStaminaPercentForCoral(0.33, 1) end),
        CalculationCfg:New("gear", Utils.GetSetName(Consts.sets.coral.iln) .. " on bar 2",
            Consts.sets.coral.icon, nil,
            function(hit) return hit.player.stats.activeBar == 2 and hit.player.gear.sets["coral"][2] end,
            function(hit) return hit:ChangeSet("coral", 2, false) end,
            function(hit) return hit:ChangeSet("coral", 2, true):ChangeStaminaPercentForCoral(0.33, 2) end),

        CalculationCfg:New("gear", "Maelstrom destro staff",
            Consts.sets.maCrushingWall.icon, nil,
            function(hit) return hit.player.gear.arenaSets.maCrushingWall end,
            function(hit) return hit:ChangeSetArenaWeapon("maCrushingWall", false) end,
            function(hit) return hit:ChangeSetArenaWeapon("maCrushingWall", true) end ),

        CalculationCfg:New("gear", "Master's bow with maximum uptime",
            Consts.sets.mastersBow.icon, nil,
            function(hit) return hit.player.gear.arenaSets.mastersBow and hit.target.poisonInjection end,
            function(hit) return hit:ChangeSetArenaWeapon("mastersBow", false):ChangeDebuffPoisonInjection(false) end,
            function(hit) return hit:ChangeSetArenaWeapon("mastersBow", true):ChangeDebuffPoisonInjection(true) end ),

        CalculationCfg:New("gear", "Maelstrom 2h",
            Consts.sets.ma2h.icon, nil,
            function(hit) return hit.player.gear.arenaSets.ma2h and hit.player.buffs.mercilessCharge end,
            function(hit) return hit:ChangeMercilessCharge(false) end,
            function(hit) return hit:ChangeMercilessCharge(true) end ),

            -- TODO spectral cloak

    }

    
    -- self.calculationConfigs = {}
    for cp1,_ in pairs(Consts.slottableCpIds) do
        table.insert(self.calculationConfigs, createCalcConfigCPRemove(cp1))
    end
    for cp1,_ in pairs(Consts.slottableCpIds) do
        table.insert(self.calculationConfigs, createCalcConfigCPEquip(cp1))
    end
    for cp1,_ in pairs(Consts.slottableCpIds) do
        for cp2,_ in pairs(Consts.slottableCpIds) do
            table.insert(self.calculationConfigs, createCalcConfigCPChange(cp1, cp2))
        end
    end




    -- self.calculationConfigs = {
    --     createCalcConfigBuff("buffs", "majorSlayer"),

        -- CalculationCfg:New("gear", "Harpooner's Wading Kilt",
        --     "/esoui/art/mainmenu/menubar_skills",
        --     nil,
        --     function(hit) return hit.player.gear.sets["kilt"][1] end,
        --     function(hit) return hit:ChangeSetKilt(false) end,
        --     function(hit) return hit:ChangeSetKilt(true) end),
    -- }
end

-- UI callbacks
function CombatInsights.onDeleteButtonPressed()
    -- if the currently selected cmx fight  has a stored analysis this will throw it away
    local cmxFight = CMX.GetAbilityStats()[1]
    if not cmxFight then return end
    local fightUID = Utils.CMXFightUID(cmxFight)
    self.analyses[fightUID] = nil
end

local function onCmxSavePressed(fightData, shiftkey)
    -- debugPrint("CMX SAVE %d", fightData.date)
    local additionalFightDatas = Fights.GetFightsBetweenDates(fightData.date, fightData.date + math.floor((fightData.combatend - fightData.combatstart) / 1000))
    if additionalFightDatas then
        for _,v in ipairs(additionalFightDatas) do
            v:SaveToSavedVariables()
        end
    end

end

local function onCmxNextPressed()

end

local function onCmxPreviousPressed()

end

local function onCmxDeletePressed()
    -- debugPrint("CMX DELETE")
end

local function onCmxSelectionChanged()
    CombatInsightsReportUI.RefreshCMXSelection()
    -- debugPrint("CMX SELECTION CHANGE")
end

local function onCmxNewFightLoaded()
    handleFightSelection()
end


local function installHook()
    ZO_PreHook(CombatMetricsFightData, "Save", function(fightData, shiftkey)
        onCmxSavePressed(fightData, shiftkey)
        return false
    end)


    ZO_PostHook(CMX, "AddSelection", function(object, button, upInside, ctrlkey, alt, shiftkey)
        onCmxSelectionChanged()
        -- return false
    end)

    ZO_PostHook(CombatMetrics_Report, "Update", function()
        onCmxNewFightLoaded()
        -- return false
    end)

end


function CombatInsights.Initialize()
    SLASH_COMMANDS["/cidbg"] = function ()
        CombatInsightsConsts.DEBUG_MODE = true
    end
    SLASH_COMMANDS["/ciclean"] = Fights.PurgeSavedFights
    if CombatInsightsSandbox then CombatInsightsSandbox.Init() end
    Fights.PurgeSavedFights()
    Fights.Init()
    CombatInsightsReportUI.Init()
    initDiffTable()
end

local function OnPlayerActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(CombatInsights.name, eventCode)
    CombatInsightsConsts.Init()
    CombatInsights.Initialize()
    Fights.LoadSavedFights()
    installHook()
end

function CombatInsights.OnAddOnLoaded(event, addOnName)
    if addOnName ~= CombatInsights.name then return end
    EVENT_MANAGER:UnregisterForEvent(CombatInsights.name, EVENT_ADD_ON_LOADED);
    EVENT_MANAGER:RegisterForEvent(CombatInsights.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    CombatInsights.SV = ZO_SavedVars:NewAccountWide("CombatInsightsSavedVariables", CombatInsights.variableVersion, nil, CombatInsights.defaults)
end

EVENT_MANAGER:RegisterForEvent(CombatInsights.name, EVENT_ADD_ON_LOADED, CombatInsights.OnAddOnLoaded)

