--Library name and version
local MAJOR, MINOR = "LibVampire", 1.2
--An output prefix
local prefix = "[".. MAJOR .. "]"
--Library already loaded check with version comparison
if LibVampire ~= nil and (LibVampire.version and LibVampire.version >= MINOR) then return end

--Library table
local lib = {}
lib.name = MAJOR
lib.version = tostring(MINOR)
lib.debug = false

--GLOBAL constants
--VAMPIRE_STAGE_0 = 0
VAMPIRE_STAGE_1 = 1
VAMPIRE_STAGE_2 = 2
VAMPIRE_STAGE_3 = 3
VAMPIRE_STAGE_4 = 4

--Internal constants:
local PLAYER_CONST = "player"
--Identifiers for the player buff checks
local Buff_Identifier_VampireBuffInfo       = "VampireBuffInfo"
local Buff_Identifier_VampireFeedCooldown   = "VampireFeedCooldown"
local timeToWaitBeforeNextBuffCheck = 1000 --Only check each 1 second, or use the lib.isVampire boolean as result for checks

--Pattern for string find
--vampire stage1 texture: /esoui/art/icons/ability_u26_vampire_infection_stage1.dds
lib.vampireBuffTexturePattern = "ability_.+_vampire_" --for e.g. ability_u26_vampire_infection_stage1.dds -> ability_u26_vampire_infection_stage4.dds
local allowedVampireStages = {
    [VAMPIRE_STAGE_1] = true,
    [VAMPIRE_STAGE_2] = true,
    [VAMPIRE_STAGE_3] = true,
    [VAMPIRE_STAGE_4] = true,
}
--The textures of the vampire stages
local vampireStageTextures = {
    --[VAMPIRE_STAGE_0] = "/esoui/art/icons/ability_u26_vampire_infection_stage0.dds",
    [VAMPIRE_STAGE_1] = "/esoui/art/icons/ability_u26_vampire_infection_stage1.dds",
    [VAMPIRE_STAGE_2] = "/esoui/art/icons/ability_u26_vampire_infection_stage2.dds",
    [VAMPIRE_STAGE_3] = "/esoui/art/icons/ability_u26_vampire_infection_stage3.dds",
    [VAMPIRE_STAGE_4] = "/esoui/art/icons/ability_u26_vampire_infection_stage4.dds",
}

--Registered callback functions of other addons for the vampire stage change
local callbacksToVampireStageChangedRegistered = {}

--[[ LIB VARIABLES ]]
--Variables for optimized IsVampire buff check
lib.lastVampireBuffCheckDone    = nil
lib.isVampire                   = nil
lib.vampireStage                = nil
lib.vampireBuff                 = nil
lib.vampireBuffTexture          = nil
lib.buffInfo                    = nil
--Feed cooldown variables
lib.lastVampireCooldownBuffCheckDone = nil
lib.isFeedOnCooldown        = nil
lib.isFeedPassiveSkillGiven = nil
lib.feedCooldownSecondsLeft = nil
lib.feedCooldownBuffInfo    = nil

--2020-05-29, maybe changing due to ZOs one day!
lib.vampireSkillsID                     = 51                    --The skillLine ID of the vampire skills in skill type SKILL_TYPE_WORLD
lib.vampireSkillsType                   = SKILL_TYPE_WORLD      --The skillType of the vampire skills (World skills)
lib.vampireSkillLineIndexInWorldSkills  = nil                   --The skill types' SKILL_TYPE_WORLD skill line "Vampire"'s skillIndex. Will be updated at EVENT_ADD_ON_LOADED

--AbilityIds of the vampire skillline
lib.vampireSkills = {
    numSkills = 0, -- will be updated at EVENT_ADD_ON_LOADED
    --Active Vampire skillline skills
    active = {

    },
    --Passive Vampire skillline skills
    passive = {
        feed = {
            skillIndex      = 10, --10th skill from the top of the Vampire skill line (starting at the ultimate)
            baseAbilityId   = 33091,
        },
    },
}

--Buffs on the vampire player
lib.vampireBuffIds = {
    --The vampire stages, as player buff
    stages = {
        -------------------------------------------------------------------------------------
        --85990,  -- TODO: Remove after test: Wild watcher ultimate -> Warden Bear -> For testing only!
        -------------------------------------------------------------------------------------
        135397, -- Vampire Stage 1
        135399, -- Vampire Stage 2
        135400, -- Vampire Stage 3
        135402, -- Vampire Stage 4
        135412, -- Vampire Stage 5
    },
    --The feed cooldown, as player buff
    feedCooldown = {
        40359, --Feed cooldown timer buff
    },
}


--[[ ZOs VARIABLES ]]
local eventBuffChangedAtStageChangeNameBase = MAJOR.."_EVENT_EFFECT_CHANGED_VAMPIRE_STAGE_CHANGE_CALLBACK_%s"
local em = EVENT_MANAGER


--[[ HELPER FUNCTIONS ]]
--Split string into table, with pattern
local function splitStringIntoTable(strValue, splitPattern)
    if not strValue or not splitPattern or splitPattern == "" then return end
    local retTab = {}
    for i in string.gmatch(strValue, splitPattern) do
        table.insert(retTab, i)
    end
    return retTab
end

--Time formatting function
local function getTimeLeft(endTimeMS, formatting)
    --if not startTimeMs or not endTimeMS or startTimeMs <= 0 or endTimeMS <= 0 or startTimeMs <= endTimeMS then return 0 end
    formatting = formatting or "%s"
    local timeLeft
    local now = GetGameTimeMilliseconds()
    local timeLeftSeconds = math.max(zo_roundToNearest(endTimeMS - now / 1000, 1), 0)
--d(">getTimeLeft-start/endTimeMs: " ..tostring(startTimeMs) .. "/" .. tostring(endTimeMS) .. "->" ..tostring(endTimeMS-startTimeMs).."/"..tostring(timeLeftSeconds))
    --Seconds
    if formatting == "%s" then
        timeLeft = timeLeftSeconds
    --Minutes
    elseif formatting == "%m" then
        local timeLeftBase = math.max(zo_roundToNearest(timeLeftSeconds / 60, 1), 0)
        timeLeft = zo_strformat("<<1[mins/min/$d mins]>>", timeLeftBase)
    --Hours
    elseif formatting == "%h" then
        local timeLeftBase = (timeLeftSeconds / 60) / 60
        timeLeft = zo_strformat("<<1[hours/hour/$d hours]>>", timeLeftBase)
    --Days
    elseif formatting == "%d" then
        local timeLeftBase = ((timeLeftSeconds / 60) / 60) / 24
        timeLeft = zo_strformat("<<1[days/day/$d days]>>", timeLeftBase)
    --Countdown timer
    elseif formatting == "%c" then
        local timeLeftBase = ZO_FormatTime(timeLeftSeconds, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_NONE)
        --Split at :
        local splitTimeData = splitStringIntoTable(timeLeftBase, "[^:]+") -- split at not a :
        if splitTimeData and #splitTimeData > 0 then
            timeLeft = zo_strformat("<<1[days/day/$d days]>>, <<2[mins/min/$d mins]>>, <<3[secs/sec/$d secs]>>", splitTimeData[1], splitTimeData[2], splitTimeData[3])
        end
    end
    return timeLeft
end

--Check if an entry exists in a table and return the key
local function isInTableAndReturnKey(tabName, valueToSearch)
    if not tabName or not valueToSearch then return end
    for k,v in pairs(tabName) do
        if v==valueToSearch then return k end
    end
    return
end

local function showOutput(outputStr)
    if outputStr ~= "" then
        d(prefix .. outputStr)
        local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.CHAMPION_POINTS_COMMITTED)
        params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
        params:SetText(outputStr)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
    end
end

-- Should a buff check done again or did we query too often (more than once a second)
local function isBuffCheckReady(identifier)
    if not identifier then return true end
    local identifiersToLastCheckValue = {
        [Buff_Identifier_VampireBuffInfo]       = lib.lastVampireBuffCheckDone,
        [Buff_Identifier_VampireFeedCooldown]   = lib.lastVampireCooldownBuffCheckDone,
    }
    local lastCheck = identifiersToLastCheckValue[identifier]
    if (not lastCheck or (lastCheck and ((GetGameTimeMilliseconds()-lastCheck) > timeToWaitBeforeNextBuffCheck))) then
        return true
    end
    if      identifier == Buff_Identifier_VampireBuffInfo then
        if (lib.isVampire == nil or lib.vampireStage == nil or lib.vampireBuffTexture == nil or lib.vampireBuff == nil or lib.buffInfo == nil) then
            return true
        end
    elseif  identifier == Buff_Identifier_VampireFeedCooldown then
        if (lib.isVampire == nil or lib.isFeedOnCooldown == nil or lib.feedCooldownSecondsLeft == nil or lib.feedCooldownBuffInfo == nil or lib.isFeedPassiveSkillGiven == nil) then
            return true
        end
    end
    return false
end

--Get info about a skillType's skillIndex (= a total skillLine)
--returns:
--string lineName
--number lineLevel
--boolean isAvailable
--number skillLineId
--boolean advised
--string unlockedText
--boolean active
--boolean discovered
local function getSkillLineInfo(skillType, skillIndex)
    if not skillType or not skillIndex then return end
    local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(skillType, skillIndex)
    if not skillLineData then return end
    local lineName, lineLevel, isAvailable, skillLineId, advised, unlockedText, active, discovered = skillLineData:GetName(), skillLineData:GetCurrentRank(), skillLineData:IsAvailable(), skillLineData:GetId(), skillLineData:IsAdvised(), skillLineData:GetUnlockText(), skillLineData:IsActive(), skillLineData:IsDiscovered()
    return lineName, lineLevel, isAvailable, skillLineId, advised, unlockedText, active, discovered
end

local function getVampireSkillLineIndexInWorldSkills()
    local vampireSkillsType = lib.vampireSkillsType
    local skillLinesCount = GetNumSkillLines(vampireSkillsType)
    if skillLinesCount == nil then return end
    --GetSkillLineId(*[SkillType|#SkillType]* _skillType_, *luaindex* _skillLineIndex_)
    --** _Returns:_ *integer* _skillLineId_
    local skillLineId
    local vampireSkillsID = lib.vampireSkillsID
    for i=1, skillLinesCount, 1 do
        skillLineId = GetSkillLineId(vampireSkillsType, i)
        if skillLineId == vampireSkillsID then
            lib.vampireSkillLineIndexInWorldSkills = i
            return i
        end
    end
    return
end

--Show the feed cooldown in chat
local function showVampireFeedCooldown()
    local output = ""
    local isVampire, vampireStage = lib.IsVampire()
    local isFeedOnCooldown, isFeedPassiveGiven, secondsLeft, buffInfo = lib.IsFeedOnCooldown(true)
    local timeLeftCooldown = getTimeLeft(buffInfo.timeEnding, "%c")
    if isVampire == true then
        if isFeedPassiveGiven == true then
            if isFeedOnCooldown == true then
                output = "Your feed cooldown will end in " ..tostring(timeLeftCooldown)
            else
                output = "|cFF0000Visit the shrine, bring us more children|r! Current stage: " ..tostring(vampireStage)
            end
        else
            output = "You're not able to turn others into a vampire yet. Learn the \'Blood ritual\' passive skill."
        end
    else
        output = "You're not one of Lamae Bal's children!"
    end
    showOutput(output)
end

local function testAndOutputIfAVampire()
    local isVampire, vampireStage, _, vampireBuffTexture = lib.IsVampire()
    local outputStr = ""
    local vampireBuffTextureAsString = ""
    if isVampire == true then
        if vampireBuffTexture and vampireBuffTexture ~= "" then
            vampireBuffTextureAsString = zo_iconFormat(vampireBuffTexture, 32, 32)
        end
        outputStr = string.format("%s You are a vampire of stage %s!", vampireBuffTextureAsString, tostring(vampireStage))
    else
        outputStr = "You are not a vampire!"
    end
    showOutput(outputStr)
end

--[[ LIB EVENT FUNCTIONS ]]

--Test if a vampire "feed" was done and if the
--EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
local function onEventEffectChanged(eventId,changeType,effectSlot,effectName,unitTag,beginTime,endTime,stackCount,iconName,buffType,effectType,abilityType,statusEffectType,unitName,unitId,abilityId,sourceType)
    --Standard states to fire the internal libraries vampire stage callback function are GAINED and FADED to update internal
    --library tables and variables like buffInfo and stageId
    local eventEffectChangedAllowedChangeTypes = {
        [EFFECT_RESULT_FADED] = true,
        [EFFECT_RESULT_GAINED] = true,
        --EFFECT_RESULT_UPDATED
        --EFFECT_RESULT_FULL_REFRESH
        --EFFECT_RESULT_TRANSFER
    }
    if not eventEffectChangedAllowedChangeTypes[changeType] then return end
    local oldStageId = lib.vampireStage
    local newStageId = lib.GetVampireStage(nil, true)
    if lib.debug then
        local debugChangeType = ""
        if      changeType == EFFECT_RESULT_GAINED then
            debugChangeType = "GAINED"
        elseif  changeType == EFFECT_RESULT_FADED then
            debugChangeType = "FADED"
        end
        d(string.format("[LibVampire]%s onEffectChanged: %s [%s] - oldState/newStage: %s/%s", debugChangeType, tostring(effectName), tostring(abilityId), tostring(oldStageId), tostring(newStageId)))
    end
    return oldStageId, newStageId
end

local function addCallbackToVampireStageChanged(addOnName, callbackFunc, onlyCallForTheFollowingEffectChangedTypes, oldStageNeeded, newStageNeeded)
    local retVar
    if not callbacksToVampireStageChangedRegistered[addOnName] then
        local stagesBuffData = lib.vampireBuffIds and lib.vampireBuffIds.stages
        if not stagesBuffData then return end
        for stageId=1, #stagesBuffData, 1 do
            local uniqueEventEffectChangedName = string.format(eventBuffChangedAtStageChangeNameBase, stageId)
            local buffIdOfStageBuff = stagesBuffData[stageId]
            if buffIdOfStageBuff then
                local callbackToVampireStageChanged_loop = em:RegisterForEvent(
                        uniqueEventEffectChangedName,
                        EVENT_EFFECT_CHANGED,
                        function(eventId,changeType,effectSlot,effectName,unitTag,beginTime,endTime,stackCount,iconName,buffType,effectType,abilityType,statusEffectType,unitName,unitId,abilityId,sourceType)
                            local oldStageId, newStageId = onEventEffectChanged(eventId,changeType,effectSlot,effectName,unitTag,beginTime,endTime,stackCount,iconName,buffType,effectType,abilityType,statusEffectType,unitName,unitId,abilityId,sourceType)
                            if changeType ~= nil and callbackFunc and type(callbackFunc) == "function" then
                                local doRunCallback = true
                                if      (oldStageNeeded ~= nil and allowedVampireStages[oldStageNeeded] and (oldStageId ~= nil and oldStageId ~= oldStageNeeded))
                                        or   (newStageNeeded ~= nil and allowedVampireStages[newStageNeeded] and (newStageId ~= nil and newStageId ~= newStageNeeded))
                                then
                                    if lib.debug then d("<stageChangedCallback not running because of newStage or oldStage!") end
                                    doRunCallback = false
                                end
                                if doRunCallback == true then
                                    if lib.debug then d(">stageChangedCallback runs now!") end
                                    if not onlyCallForTheFollowingEffectChangedTypes or onlyCallForTheFollowingEffectChangedTypes[changeType] == true then
                                        callbackFunc(oldStageId,newStageId,changeType,effectSlot,effectName,unitTag,beginTime,endTime,stackCount,iconName,buffType,effectType,abilityType,statusEffectType,unitName,unitId,abilityId,sourceType)
                                    end
                                end
                            end
                        end
                )
                --Only fire for the player
                em:AddFilterForEvent(uniqueEventEffectChangedName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, PLAYER_CONST)
                --Only fire for the vampire stage buffIds/abilityIds
                em:AddFilterForEvent(uniqueEventEffectChangedName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, buffIdOfStageBuff)

                if callbackToVampireStageChanged_loop == true then
                    callbacksToVampireStageChangedRegistered[addOnName] = callbackToVampireStageChanged_loop
                    retVar = true
                end
            end
        end
    elseif callbacksToVampireStageChangedRegistered[addOnName] == true then
        retVar = false
    end
    return retVar
end


--Check the active player buffs for table abilityIds, or a string texture pattern.
--If found: Return a table with filled data depending on the "identifier" parameter
local function checkPlayerBuffs(abilityIds, textureStringPattern, identifier)
    if lib.debug then d("[LibVampire]checkPlayerBuffs - identifier: " ..tostring(identifier)) end
    if identifier == nil or identifier == "" or (abilityIds == nil and (textureStringPattern == nil or textureStringPattern == "")) then return end
    local isVampBuffInfo = false
    local isVampFeedCD = false
    local now = GetGameTimeMilliseconds()
    if      identifier == Buff_Identifier_VampireBuffInfo then
        isVampBuffInfo = true
        lib.lastVampireBuffCheckDone = now
    elseif  identifier == Buff_Identifier_VampireFeedCooldown then
        isVampFeedCD = true
        lib.lastVampireCooldownBuffCheckDone = now
    end

    local buffInfo = {}
    local numBuffs = GetNumBuffs(PLAYER_CONST)
    if numBuffs ~= nil and numBuffs > 0 then
        --Check the normal vampire buff and stage
        if isVampBuffInfo then
            if lib.debug then d(">vampire Buff") end
            lib.buffInfo = nil
            lib.vampireBuff = nil
            --Check the feed cooldown timer
        elseif isVampFeedCD then
            if lib.debug then d(">feed cooldown Buff") end
            lib.isFeedOnCooldown     = nil
            lib.feedCooldownSecondsLeft = nil
            lib.feedCooldownBuffInfo = nil
        end
        --Check all player buffs
        for i = 0, numBuffs, 1 do
            local buffName,timeStarted,timeEnding,buffSlot,stackCount,textureName,buffType,effectType,abilityType,statusEffectType,abilityIdOfPlayerBuff,_ = GetUnitBuffInfo(PLAYER_CONST, i)
            if abilityIdOfPlayerBuff and abilityIdOfPlayerBuff > 0 then
                local buffNameClean
                if (       (isVampBuffInfo == true and (textureName and textureName ~= "" and textureStringPattern and textureStringPattern ~= "" and string.find(textureName, textureStringPattern)))
                        or (isVampFeedCD == true and (abilityIds and isInTableAndReturnKey(abilityIds, abilityIdOfPlayerBuff) ~= nil))
                ) then
                    if lib.debug then d(">>Buff was found!") end
                    buffNameClean = ZO_CachedStrFormat("<<C:1>>", buffName)
                    buffInfo["playerBuffIndex"] = i
                    buffInfo["abilityId"] = abilityIdOfPlayerBuff
                    buffInfo["buffName"] = buffName
                    buffInfo["buffNameClean"] = buffNameClean
                    buffInfo["timeStarted"] = timeStarted
                    buffInfo["timeEnding"] = timeEnding
                    buffInfo["textureName"]= textureName
                    if isVampBuffInfo == true then
                        lib.buffInfo = buffInfo
                        lib.vampireBuff = buffNameClean
                    end
                    if isVampFeedCD == true then
                        lib.isFeedOnCooldown     = true
                        lib.feedCooldownBuffInfo = buffInfo
                    end
                    return buffInfo
                end
            end
        end
    else
        if lib.debug then d("<<NO PLAYER BUFFS FOUND! -> RESET ALL VARIABLES") end
        --No buffs on player, so no vamp and no cooldown -> reset all variables
        lib.lastVampireBuffCheckDone    = nil
        lib.isVampire                   = nil
        lib.vampireStage                = nil
        lib.vampireBuff                 = nil
        lib.vampireBuffTexture          = nil
        lib.buffInfo                    = nil
        --Feed cooldown variables
        lib.lastVampireCooldownBuffCheckDone = nil
        lib.isFeedOnCooldown        = nil
        lib.isFeedPassiveSkillGiven = nil
        lib.feedCooldownSecondsLeft = nil
        lib.feedCooldownBuffInfo    = nil
    end
    return nil
end

--[[ SLASH COMMANDS ]]
local function slashCommandHandler(args)
    local noParams = true
    if args ~= nil then
        local options = {}
        --local searchResult = {} --old: searchResult = { string.match(args, "^(%S*)%s*(.-)$") }
        for param in string.gmatch(args, "([^%s]+)%s*") do
            if (param ~= nil and param ~= "") then
                options[#options+1] = string.lower(param)
            end
        end
        local firstArg = options[1]
        if firstArg and firstArg ~= "" then
            noParams = false
            if firstArg == "debug" then
                local debugState = {
                    [true] = "on",
                    [false] = "off",
                }
                lib.debug = not lib.debug
                d(prefix .. "Debug was changed to: " ..tostring(debugState[lib.debug]))
            elseif firstArg == "cd" then
                showVampireFeedCooldown()
            end
        end
    end
    if noParams == true then
        testAndOutputIfAVampire()
    end
end

local function registerSlashCommands()
    SLASH_COMMANDS["/vampire"] = slashCommandHandler
end


--[[ LIB API FUNCTIONS ]]
--Register a callback function "funcName" to the stage change of the vampire
--Params:
--> String addOnName: A unique addOn name for the callback registration
--> function callbackFunc: A callback function to be run as the stage changes
--   parameters of the function are all the parameters that the
--   EVENT_EFFECT_CHANGED provides (excluding the eventId as first parameter but instead adding the oldStageId and the newStageId number as first 2 parameters):
--    ( number oldStageId, number newStageId,
--        MsgEffectResult changeType, number effectSlot, string effectName, string unitTag,
--        number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType,
--        AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId,
--       CombatUnitType sourceType )
--> nilable table onlyCallForTheFollowingEffectChangedTypes: an optional table containing 1 or more MsgEffectResults as key
--   and the boolean true/false as value, e.g.
--     [EFFECT_RESULT_FADED] = true,
--     [EFFECT_RESULT_FULL_REFRESH] = false,
--     [EFFECT_RESULT_GAINED] = true,
--     [EFFECT_RESULT_TRANSFER] = false,
--     [EFFECT_RESULT_UPDATED] = false
--> nilable number oldStage: The old stage needs to be this stageId(1-4) to fire the callback
--> nilable number newStage: The new stage needs to be this stageId(1-4) to fire the callback
--Returns:
-->nilable boolean wasCallbackRegisteredNew: (true = yes; false = no it existed already for the addOnName; nil = Nothing was done or error occured)
function lib.AddStageChangeCallback(addOnName, callbackFunc, onlyCallForTheFollowingEffectChangedTypes, oldStage, newStage)
    if not addOnName or addOnName == "" or addOnName == MAJOR or
    not callbackFunc or type(callbackFunc) ~= "function" then return end
    if lib.debug then d("[AddStageChangeCallback]addOnName: " ..tostring(addOnName) ..", effectChangeTypesGiven: " ..tostring(onlyCallForTheFollowingEffectChangedTypes~=nil) .. ", oldStage: " ..tostring(oldStage)..", newStage: " ..tostring(newStage)) end
    return addCallbackToVampireStageChanged(addOnName, callbackFunc, onlyCallForTheFollowingEffectChangedTypes, oldStage, newStage)
end


--Read player buffs and return a table with the vampire buff info
--params:
--> nilable boolean doOverride: Force the update of the buff data instead of taking the last known value from the library internally
--returns:
--> table = {
--      ["playerBuffIndex"] = number indexOfVampireBuffInPlayerBuffs
--      ["abilityId"] = number vampireBuffAbilityId
--      ["buffName"] = string buffName
--      ["buffNameClean"] = string buffName without any gender stuff like ^m etc.
--      ["timeStarted"] = number timeStarted
--      ["timeEnding"] = number timeEnding
--      ["textureName"]= string textureName
--   }
function lib.GetBuffInfo(doOverride)
    if lib.debug then d("[LibVampire]GetBuffInfo - doOverride: " ..tostring(doOverride)) end
    if not doOverride == true then
        if not isBuffCheckReady(Buff_Identifier_VampireBuffInfo) then
            return lib.buffInfo
        end
    end
    local buffInfo = checkPlayerBuffs(nil, lib.vampireBuffTexturePattern, Buff_Identifier_VampireBuffInfo)
    if lib.debug then d(">>Vampire buffInfo was found") end
    return buffInfo
end


--Check if we are a vampire and return some values
--params:
--returns:
--> boolean isVampire
--> number vampireStage (1-4)
--> string vampireBuff
--> string vampireBuffTexture
--> table buffInfo (see function lib.GetBuffInfo() return table)
function lib.IsVampire()
    if lib.debug then d("[LibVampire]IsVampire") end
    local isVampire = false
    local vampireStage
    local vampireBuff
    local vampireBuffTexture
    local isBuffCheckNeeded = isBuffCheckReady(Buff_Identifier_VampireBuffInfo)
    if lib.debug then d(">isBuffCheckNeeded: " ..tostring(isBuffCheckNeeded)) end
    if not isBuffCheckNeeded then
        return lib.isVampire, lib.vampireStage, lib.vampireBuff, lib.vampireBuffTexture, lib.buffInfo
    end
    local buffInfo = lib.GetBuffInfo(isBuffCheckNeeded)
    vampireBuff = buffInfo and buffInfo['buffNameClean']
    if vampireBuff and vampireBuff ~= "" then
        isVampire = true
        --Strip the stage from the buff name text
        vampireStage = lib.GetVampireStage(buffInfo)
        if vampireStage then
            vampireBuffTexture = lib.GetVampireStageTexture(vampireStage)
            lib.vampireStage = vampireStage
            lib.vampireBuff = vampireBuff
            lib.vampireBuffTexture = vampireBuffTexture
        end
    end
    lib.isVampire = isVampire
    if lib.debug then d(">>isVampire: " ..tostring(isVampire) .. ", vampireStage: " ..tostring(vampireStage) .. ", vampireBuff: " ..tostring(vampireBuff) .. ", vampireBuffTexture: " ..tostring(vampireBuffTexture)) end
    if not isVampire then return false, nil, nil, nil end
    return isVampire, vampireStage, vampireBuff, vampireBuffTexture, buffInfo
end


--Get the current stage of a vampire
--params:
--> table           buffInfo: Table containing the buffInfo in the following format
--->                buffInfo = { ["buffNameClean"] = "Vampirism stage <number 1-4>" }
--> nilable boolean doOverride: Force the update of the buff data instead of taking the last known value from the library internally
--returns:
--> number (1-4) vampireStage
function lib.GetVampireStage(buffInfo, doOverride)
    doOverride = doOverride or false
    buffInfo = buffInfo or lib.GetBuffInfo(doOverride)
    if lib.debug then d("[LibVampire]GetVampireStage - buffInfo: " ..tostring(buffInfo["buffNameClean"])) end
    if not buffInfo or not buffInfo["buffNameClean"] then return end
    local vampireStage
    local buffNameClean = buffInfo["buffNameClean"]
    --First part of the buff is "Vampirism" but there does not seem to exist any constant for GetSTring for it
    --Extract the "stage #" at the end by splitting the text at spaces and returning the LAST found value (after last space)
    local chunks = {}
    for substring in buffNameClean:lower():gmatch("%S+") do
        table.insert(chunks, substring)
    end
    local numChunks = #chunks
    if chunks and numChunks >0 then
        vampireStage = tonumber(chunks[numChunks])
    end
    lib.vampireStage = vampireStage
    if lib.debug then d(">>vampireStage: " ..tostring(vampireStage)) end
    return vampireStage
end


--Get the texture .dds file of a vampire stage
--params:
--> number vampireStage: The stage of the vampire that the function should return the texture for
--returns:
--> string vampireStageTexturePath
function lib.GetVampireStageTexture(vampireStage)
    if lib.debug then d("[LibVampire]GetVampireStageTexture - vampireStage: " ..tostring(vampireStage)) end
    vampireStage = tonumber(vampireStage)
    if not vampireStage or not allowedVampireStages[vampireStage] then return end
    local vampBuffTexture = vampireStageTextures[vampireStage]
    lib.vampireBuffTexture = vampBuffTexture
    if lib.debug then d(">>vampBuffTexture: " ..tostring(vampBuffTexture)) end
    return vampBuffTexture
end


--Check if the passive Vampire feed skill (to turn others into a Vampire) is given
--params:
--returns:
--> boolean isFeedPassiveBloodRitualGiven
function lib.IsFeedSkillGiven()
    if lib.debug then d("[LibVampire]IsFeedSkillGiven") end
    local isFeedPassiveGiven = false
    local skillIndexVampire = lib.vampireSkillLineIndexInWorldSkills or getVampireSkillLineIndexInWorldSkills()
    if not skillIndexVampire or skillIndexVampire == 0 then return nil, nil, nil end
    --Read the vampire skill "Blood ritual"
    local bloodRitualPassiveSkillIndex = lib.vampireSkills.passive.feed.skillIndex
    if not bloodRitualPassiveSkillIndex then return end
    --* GetSkillAbilityInfo(*[SkillType|#SkillType]* _skillType_, *luaindex* _skillLineIndex_, *luaindex* _skillIndex_)
    --** _Returns:_ *string* _name_, *textureName* _texture_, *luaindex* _earnedRank_, *bool* _passive_, *bool* _ultimate_, *bool* _purchased_, *luaindex:nilable* _progressionIndex_, *integer* _rank_
    local name, texture, earnedRank, passive, ultimate, purchased, progressionIndex, rank = GetSkillAbilityInfo(lib.vampireSkillsType, skillIndexVampire, bloodRitualPassiveSkillIndex)
    purchased = purchased or false
    lib.isFeedPassiveSkillGiven = purchased
    if lib.debug then d(">>isFeedPassiveSkillGiven: " ..tostring(purchased)) end
    return purchased
end


--Check if the passive Vampire feed skill (to turn others into a Vampire) is given and if it's on cooldown
--params:
--> nilable boolean doOverride: Force the update of the buff data instead of taking the last known value from the library internally
--returns:
--> boolean isFeedOnCooldown
--> boolean isFeedPassiveGiven
--> number secondsLeft (time the cooldown will be active in seconds)
--> table buffInfo (see function lib.GetBuffInfo() return table)
function lib.IsFeedOnCooldown(doOverride)
    if lib.debug then d("[LibVampire]IsFeedOnCooldown") end
    if not doOverride == true then
        if not isBuffCheckReady(Buff_Identifier_VampireFeedCooldown) then
            return lib.isFeedOnCooldown, lib.isFeedPassiveSkillGiven, lib.feedCooldownSecondsLeft, lib.feedCooldownBuffInfo
        end
    end
    local isFeedOnCooldown = false
    local secondsLeft = 0
    local isFeedPassiveGiven = lib.IsFeedSkillGiven()
    if not isFeedPassiveGiven then return false, false end
    --Check the player buffs for the feed skill
    local feedCooldownBuffData = lib.vampireBuffIds and lib.vampireBuffIds.feedCooldown
    local buffInfo
    if feedCooldownBuffData then
        buffInfo = checkPlayerBuffs(feedCooldownBuffData, nil, Buff_Identifier_VampireFeedCooldown)
        if buffInfo and buffInfo.playerBuffIndex ~= nil then
            isFeedOnCooldown = true
            secondsLeft = getTimeLeft(buffInfo.timeEnding, "%s")
            lib.feedCooldownSecondsLeft = secondsLeft
        end
    end
    if lib.debug then d(">>isFeedOnCooldown: " ..tostring(isFeedOnCooldown) .. ", secondsLeft: " ..tostring(secondsLeft)) end
    return isFeedOnCooldown, isFeedPassiveGiven, secondsLeft, buffInfo
end


--Get the level and XP of the vampire skill line
--params:
--returns:
--> number vampireSkillLineLevel
--> number xpNowOfLevel
--> number xpMaxOfLevel
function lib.GetVampireLevelInfo()
    if lib.debug then d("[LibVampire]GetVampireSkillLineLevelInfo") end
    local skillIndexVampire = lib.vampireSkillLineIndexInWorldSkills or getVampireSkillLineIndexInWorldSkills()
    if not skillIndexVampire or skillIndexVampire == 0 then return nil, nil, nil end
    --Check if the vampire skills are discovered and active
    local vampireSkillsType = lib.vampireSkillsType
    local lineLevel
    local xpPre, xpMax, xpNow
    local rank,advised,active,discovered = GetSkillLineDynamicInfo(vampireSkillsType, skillIndexVampire)
    if discovered == true and active == true then
        xpPre, xpMax, xpNow = GetSkillLineXPInfo(vampireSkillsType, skillIndexVampire)
        if (xpMax == nil or xpNow == nil)  then
            xpMax = 0
            xpNow = 0
        end
        --lineName, lineLevel, isAvailable, skillLineId, advised, unlockedText, active, discovered = GetSkillLineInfo(SKILL_TYPE_WORLD, skillIndex)
        _, lineLevel = getSkillLineInfo(vampireSkillsType, skillIndexVampire)
        if lineLevel == nil then
            return nil, nil, nil
        end
    end
    if lib.debug then d(">>lineLevel: " ..tostring(lineLevel) .. ", xpNow: " ..tostring(xpNow) .. ", xpMax: " ..tostring(xpMax)) end
    return lineLevel, xpNow, xpMax
end


-- [[ LIBRARY INITIALIZATION]]
local function libraryInit(eventId, addonName)
    if addonName ~= MAJOR then return end
    em:UnregisterForEvent(MAJOR.."_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED)

    --Create global variable of the library
    LibVampire = lib

    --Register the slash commands of the lib
    registerSlashCommands()

    --Update the vampire skill line data
    getVampireSkillLineIndexInWorldSkills()
    lib.vampireSkills.numSkills = GetNumSkillAbilities(lib.vampireSkillsType, lib.vampireSkillLineIndexInWorldSkills)

    --Update the internal library vampire data
    lib.IsVampire()
    lib.IsFeedOnCooldown()

    --TODO - Remove after testing
    --[[
    --Only for testing!
    lib.AddStageChangeCallback(MAJOR.."_TEST", function(oldStageId, newStageId)
        d("CallbackFunc was called, oldStageId: " ..tostring(oldStageId) ..", newStageId: " ..tostring(newStageId))
    end, {[EFFECT_RESULT_GAINED]=true, [EFFECT_RESULT_FADED]=true}), VAMPIRE_STAGE_1, VAMPIRE_STAGE_2)
    ]]
end
em:RegisterForEvent(MAJOR.."_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, libraryInit)

