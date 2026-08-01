-- Vampire Buff Display for Elder Scrolls Online
-- Author: notrix aka xirton, fixed by Baertram 2020-04-16

VampireInfo = {}

local vi = VampireInfo

vi.name = "VampireInfo" -- AddonName
vi.version = "4.00"
vi.author = "notrix aka xirton, fixed by Baertram"
vi.website = "https://www.esoui.com/downloads/info377-VampireInfo.html#info"

vi.svVersion = 2.00 --Changing this will reset the SavedVariables!

vi.initialized = false  -- Init state

vi.notAVampire = false

local vampireAbility007Texture = "/esoui/art/icons/ability_vampire_007.dds"

--Libs
local LMP = LibMediaProvider
local LAM = LibAddonMenu2
local LVAMP = LibVampire

--The skillLine ID of the vampire skills in skills SKILL_TYPE_WORLD
local vampireSkillsID = 51 --2020-04-16, maybe changing!

-- defaults and vars for VI_StoredOptions
vi.defaults = {
    updateUISeconds = 1000,
    location = {
        x = 830,
        y= 140,
    },

    alpha			 = 0.8,
    showIcon         = true,
    useStageIcon     = false,
    iconAlpha        = 0.3,
    showDuration     = true,
    showCooldownIcon = true,
    showSkillLineInfo = true,
    showBuffInfo     = true,
    fontsize         = 15,
    fontface         = "Trajan Pro",
    fontstyle        = "soft-shadow-thin",

    colors = {
        textLabel = {
            --Fallback phase 0 = No vampire color = White
            [0] = {
                r		= 1,
                g		= 1,
                b		= 1,
                a		= 1
            },
            --The key are the vampire phases 1 to 4
            [1] = {
                r		= 0.152941,
                g		= 0.529412,
                b		= 0.039216,
                a		= 1
            },
            [2] = {
                r   = 0.980392,
                g   = 0.913725,
                b   = 0,
                a   = 1
            },
            [3] = {
                r   = 0.988235,
                g   = 0.384314,
                b   = 0.121569,
                a   = 1
            },
            [4] = {
                r   = 1,
                g   = 0.031373,
                b   = 0.011765,
                a   = 1
            },
        },
        skillLineColor = {
            r   = 0.937255,
            g   = 1,
            b   = 0.713726,
            a   = 1
        }
    },
}

local function GetTimeLeftUntilInSeconds(timeEndingInMilliseconds)
-- Returns 1: number seconds
	return math.max(zo_roundToNearest(timeEndingInMilliseconds - GetGameTimeMilliseconds() / 1000, 1), 0)
end

-- DragDrop stop -> save location
function vi.DragEnd()
    vi.vars.location.x, vi.vars.location.y = vi.TLC:GetScreenRect()
end

local function getVampTexture(textureName)
    local vampTexture = vampireAbility007Texture
    local settings = vi.vars
    if settings.useStageIcon == true then
        if not textureName or textureName == "" then
            if not vi.lastPhase then
                vi.lastPhase = LVAMP.GetVampireStage()
            end
            if vi.lastPhase then
                vampTexture = LVAMP.GetVampireStageTexture(tonumber(vi.lastPhase))
            end
        else
            vampTexture = textureName
        end
        if not vampTexture or vampTexture == "" then
            vampTexture = vampireAbility007Texture
        end
    end
    return vampTexture
end

-- update event
function vi.OnUpdateSelf(self, time)
    if vi.initialized then
        vi.UpdateBuff()
        vi.UpdateSkill()
    end
end

local function updateNotAVampirePreview()
    local settings = vi.vars
    if settings.showIcon then
        local vampTexture = getVampTexture()
        VampireInfoTLCIcon:SetTexture(vampTexture)
    end
    if not vi.notAVampire then return end
    --For the settings menu add some standard texts and textrues to the labels and texture controls
    if settings.showBuffInfo then
        VampireInfoTLCLabelValue:SetText("Vampire - Stage 2")
    else
        VampireInfoTLCLabelValue:SetText("2")
    end
    if settings.showSkillLineInfo then
        VampireInfoTLCLabelXP:SetText("Level: 5 - XP: 50000/100000 (50%)")
    else
        VampireInfoTLCLabelXP:SetText("")
    end
    local colorsForPhase = settings.colors.textLabel
    local phase = 2
    local colorForPhase = colorsForPhase[phase]
    if colorForPhase then
        VampireInfoTLCLabelValue:SetColor(colorForPhase.r,colorForPhase.g,colorForPhase.b,colorForPhase.a)
        VampireInfoTLCLabelDuration:SetColor(colorForPhase.r,colorForPhase.g,colorForPhase.b,colorForPhase.a)
    end
    if settings.showDuration then
        local durationText = " - 05:12"
        if settings.updateUISeconds <= 1000 then
            durationText = durationText .. ":05"
        end
        VampireInfoTLCLabelDuration:SetText(durationText)
    end
    if settings.showIcon and settings.showCooldownIcon then
        vi.buffRemainingTime = -1
        vi.buffDurationTime  = -2
        VampireInfoTLCStatusBar:SetHidden(false)
        VampireInfoTLCStatusBar:StartCooldown(200000, 500000, CD_TYPE_RADIAL , CD_TIME_TYPE_TIME_UNTIL, false) --CD_TIME_TYPE_TIME_REMAINING
    end
end

-- update routine for buff / duration
function vi.UpdateBuff()
    local settings = vi.vars
    --[[
    local buffName
    local buffValue
    local duration
    local timeStarted
    local timeEnding
    local buffSlot
    local stackCount
    local textureName
    local buffType
    local effectType
    local abilityType
    local statusEffectType
    local abilityId
    local canClickOff
    local phase
    local numBuffs


    -- did we find the buff the last time? let's check if the buffSlot has changed
    if vi.lastFoundVampireBuffIndexOnPlayer ~= 0 then
        --** _Returns:_ *string* _buffName_, *number* _timeStarted_, *number* _timeEnding_, *integer* _buffSlot_, *integer* _stackCount_, *textureName* _iconFilename_, *string* _buffType_, *[BuffEffectType|#BuffEffectType]* _effectType_, *[AbilityType|#AbilityType]* _abilityType_, *[StatusEffectType|#StatusEffectType]* _statusEffectType_, *integer* _abilityId_, *bool* _canClickOff_, *bool* _castByPlayer_
        buffName,timeStarted,timeEnding,buffSlot,stackCount,textureName, buffType, effectType, abilityType, statusEffectType,abilityId,canClickOff = GetUnitBuffInfo("player", vi.lastFoundVampireBuffIndexOnPlayer )
        --      if tonumber(abilityType) == 45 then -- abilityType 45 = ABILITY_TYPE_VAMPIRE -> that doesn't work, we always get abilityType = 5! So dirty workaround: check the texture!
        --if (textureName ~= "/esoui/art/icons/ability_vampire_007.dds") then
        if not textureName or (textureName and (textureName == "" or not PlainStringFind(textureName,"ability_vampire_"))) then
            buffName = nil
        end
    end

    -- we didn't find the buff at the last spot or we just run this the first time -> let's find the vamp buff!
    if buffName == nil then
        numBuffs = GetNumBuffs("player")
        if numBuffs ~=nil then
            for i = 0, numBuffs, 1 do
                buffName,timeStarted,timeEnding,buffSlot,stackCount,textureName, buffType, effectType, abilityType, statusEffectType,abilityId,canClickOff = GetUnitBuffInfo("player", i)
                --         if tonumber(abilityType) == 45 then -- abilityType 45 = ABILITY_TYPE_VAMPIRE -> that doesn't work, we always get abilityType = 5! So dirty workaround: check the texture!
                --if (textureName == "/esoui/art/icons/ability_vampire_007.dds") then
                if textureName and textureName ~= "" and PlainStringFind(textureName,"ability_vampire_") then
                    vi.lastFoundVampireBuffIndexOnPlayer = i
                    break
                end
                buffName = nil
            end
        end
    end

--d(">timeStarted: " ..tostring(timeStarted) .. ", timeEnding: " ..tostring(timeEnding) .. ", timeLeftToEndingInS: " ..tostring(GetTimeLeftInSeconds(timeEnding)))
    ]]
    local isVampire, phase, buffName, vampireBuffTexture, buffInfo = LVAMP.IsVampire()
    -- parse the buff information
    if not isVampire then
        vi.notAVampire = true
        updateNotAVampirePreview()
        vi.UpdateSize()
        return
    end
    vi.notAVampire = false

    local timeEnding, timeStarted, textureName = buffInfo["timeEnding"], buffInfo["timeStarted"], buffInfo["textureName"]
    local buffValue, duration
    if not phase then return end

    vi.lastPhase = phase

    local isFirstPhase = tonumber(phase) == 1 or false
    if not isFirstPhase == true then
        buffValue, duration = vi.ParseBuff(buffName,timeEnding,timeStarted,phase)
        if not buffValue then
            return
        end
    else
        vi.buffDurationTime = 0
        vi.buffRemainingTime = 0
        vi.lastBuffRemainingTime = 0
    end

    --Update the UI
    VampireInfoTLCLabelValue:SetText("")
    if settings.showBuffInfo and not isFirstPhase == true and buffValue then
        VampireInfoTLCLabelValue:SetText(buffValue)
    else
        VampireInfoTLCLabelValue:SetText(phase)
    end
    local vampTexture = getVampTexture(textureName)
    VampireInfoTLCIcon:SetTexture(vampTexture)

    -- set colors equal to phase
    local colorsForPhase = settings.colors.textLabel
    if phase == "" then phase = 0 end
    local colorForPhase = colorsForPhase[phase]
    if colorForPhase then
        VampireInfoTLCLabelValue:SetColor(colorForPhase.r,colorForPhase.g,colorForPhase.b,colorForPhase.a)
        VampireInfoTLCLabelDuration:SetColor(colorForPhase.r,colorForPhase.g,colorForPhase.b,colorForPhase.a)
    end

    if settings.showDuration and not isFirstPhase == true and duration then
        VampireInfoTLCLabelDuration:SetText(" - "..tostring(duration))
    end

    -- set size
    if vi.lastPhase ~= phase or vi.layoutChanged == true then
        vi.UpdateSize()
    else
        -- check if we feed during same phase -> update cooldown on icon!
        if settings.showIcon and settings.showCooldownIcon and not isFirstPhase == true
                and vi.buffRemainingTime and vi.buffRemainingTime > 0 and vi.lastBuffRemainingTime and vi.lastBuffRemainingTime > 0
                and vi.buffRemainingTime > vi.lastBuffRemainingTime then
            VampireInfoTLCStatusBar:SetHidden(false)
            VampireInfoTLCStatusBar:StartCooldown(vi.buffRemainingTime, vi.buffDurationTime, CD_TYPE_RADIAL , CD_TIME_TYPE_TIME_UNTIL, false) --CD_TIME_TYPE_TIME_REMAINING
        end
    end

    vi.layoutChanged = false
    if vi.buffRemainingTime > 0 then
        vi.lastBuffRemainingTime = vi.buffRemainingTime
    end
end

--Update Skillinfo
function vi.UpdateSkill()
    local found
    local xpMax
    local xpNow
    local lineLevel
    found, xpMax, xpNow, lineLevel = vi.GetSkillLineXP()
    if found == true then
        vi.notAVampire = false
        vi.TLC:SetHidden(false)

        if lineLevel > 0 then
            VampireInfoTLCLabelXP:SetText("Level: " .. lineLevel)
        else
            VampireInfoTLCLabelXP:SetText("")
        end
        vi.lastXP = vi.lastXP or 0

        if xpNow and xpMax and xpMax > 0 and xpNow <= xpMax then
            VampireInfoTLCLabelXP:SetText("Level: " .. tostring(lineLevel) .. " - XP: " .. tostring(xpNow) .. "/" .. tostring(xpMax) .. " (" .. vi.round(xpNow/xpMax * 100,1)  .."%)")
            if xpNow ~= vi.lastXP then
                --set Size
                vi.UpdateSize()
                vi.lastXP = xpNow
            end
        end

    else
        if vi.lamPanel:IsHidden() then
            vi.TLC:SetHidden(true)
        end
        vi.lastXP = 0
        vi.notAVampire = true
    end
end

-- formats seconds to good looking time format
function vi.SecondsToClock(sSeconds)
	local nSeconds = sSeconds
	if nSeconds == 0 then
		--return nil;
		return "00:00:00";
	else
		local nHours = string.format("%02.f", math.floor(nSeconds/3600));
		local nMins = string.format("%02.f", math.floor(nSeconds/60 - (nHours*60)));
		local nSecs = string.format("%02.f", math.floor(nSeconds - nHours*3600 - nMins *60));
        if vi.vars.updateUISeconds > 1000 then
            return nHours..":"..nMins
        end
		return nHours..":"..nMins..":"..nSecs
	end
end

-- sets font face and font size
function vi.UpdateFont()
    local fontToUse = vi.GetFont()
    VampireInfoTLCLabelValue:SetFont(fontToUse)
    VampireInfoTLCLabelDuration:SetFont(fontToUse)
    VampireInfoTLCLabelXP:SetFont(fontToUse)
    vi.UpdateSize()
end

-- update layout size and positions
function vi.UpdateSize()
    local offsetX = 11
    local width = 100
    local settings = vi.vars

    VampireInfoTLCIcon:SetHidden(not settings.showIcon);

    local isFirstPhase = vi.lastPhase == 1 or false

    local labelValueHeight = VampireInfoTLCLabelValue:IsHidden() and math.ceil(VampireInfoTLCLabelValue:GetHeight()) or math.ceil(VampireInfoTLCLabelValue:GetTextHeight())
    local labelXPHeight = VampireInfoTLCLabelXP:IsHidden() and math.ceil(VampireInfoTLCLabelXP:GetHeight()) or math.ceil(VampireInfoTLCLabelXP:GetTextHeight())

    if settings.showSkillLineInfo == false then
        VampireInfoTLCLabelXP:SetHidden(true)
        VampireInfoTLCLabelXP:SetHeight(1)
        VampireInfoTLCLabelValue:ClearAnchors();
        VampireInfoTLCLabelValue:SetAnchor(LEFT, VampireInfoTLCIcon, RIGHT, 8, 1)
    else
        VampireInfoTLCLabelXP:SetHidden(false)
        VampireInfoTLCLabelXP:SetHeight(22)
        VampireInfoTLCLabelValue:ClearAnchors();
        VampireInfoTLCLabelValue:SetAnchor(TOPLEFT, VampireInfoTLCIcon, TOPRIGHT, 8,0)
    end

    if settings.showIcon == false then
        labelValueHeight = VampireInfoTLCLabelValue:IsHidden() and math.ceil(VampireInfoTLCLabelValue:GetHeight()) or math.ceil(VampireInfoTLCLabelValue:GetTextHeight())
        VampireInfoTLCIcon:SetDimensions(1,labelValueHeight)
        VampireInfoTLCIcon:ClearAnchors();
        VampireInfoTLCIcon:SetAnchor(TOPLEFT, VampireInfoTLC, TOPLEFT, -8, -2)
        offsetX = offsetX - 8
        VampireInfoTLCStatusBar:SetHidden(true)
    else
        labelValueHeight = VampireInfoTLCLabelValue:IsHidden() and math.ceil(VampireInfoTLCLabelValue:GetHeight()) or math.ceil(VampireInfoTLCLabelValue:GetTextHeight())
        labelXPHeight = VampireInfoTLCLabelXP:IsHidden() and math.ceil(VampireInfoTLCLabelXP:GetHeight()) or math.ceil(VampireInfoTLCLabelXP:GetTextHeight())

        VampireInfoTLCIcon:SetDimensions(labelValueHeight + labelXPHeight, labelValueHeight+ labelXPHeight)
        VampireInfoTLCIcon:ClearAnchors();
        VampireInfoTLCIcon:SetAnchor(TOPLEFT, VampireInfoTLC, TOPLEFT, 0, -2)
        offsetX = offsetX - 2

        if settings.showCooldownIcon == false or isFirstPhase == true
                or (vi.buffRemainingTime and vi.buffRemainingTime > 0 and vi.buffDurationTime and vi.buffDurationTime > 0 and vi.buffRemainingTime>=vi.buffDurationTime) then
            VampireInfoTLCIcon:SetAlpha(1)
            VampireInfoTLCStatusBar:SetHidden(true)
        elseif settings.showCooldownIcon == true and not isFirstPhase then
            VampireInfoTLCIcon:SetAlpha(settings.iconAlpha)
            VampireInfoTLCStatusBar:SetHidden(false)

            VampireInfoTLCStatusBar:ClearAnchors();
            VampireInfoTLCStatusBar:SetAnchor(TOPLEFT, VampireInfoTLC, TOPLEFT, 0, -2)
            VampireInfoTLCStatusBar:SetDimensions(labelValueHeight + labelXPHeight, labelValueHeight+ labelXPHeight)
            VampireInfoTLCStatusBar:SetTexture(VampireInfoTLCIcon:GetTextureFileName())
            VampireInfoTLCStatusBar:SetDrawLayer(DL_OVERLAY)
            VampireInfoTLCStatusBar:SetDrawTier(DT_HIGH)
            if not vi.notAVampire and vi.buffRemainingTime and vi.buffDurationTime and vi.buffDurationTime>vi.buffRemainingTime then
                VampireInfoTLCStatusBar:StartCooldown(vi.buffRemainingTime, vi.buffDurationTime, CD_TYPE_RADIAL , CD_TIME_TYPE_TIME_UNTIL, false)
            end
        end
    end

    if settings.showDuration == false or isFirstPhase == true then
        VampireInfoTLCLabelDuration:SetWidth(1)
    else
        VampireInfoTLCLabelDuration:SetWidth(VampireInfoTLCLabelDuration:GetTextWidth())
    end
    width = VampireInfoTLCLabelValue:GetWidth() + math.ceil(VampireInfoTLCLabelDuration:GetWidth())

    if settings.showSkillLineInfo == true and math.ceil(VampireInfoTLCLabelXP:GetWidth()) > width then
        width = math.ceil(VampireInfoTLCLabelXP:GetWidth())
    end

    VampireInfoTLC:SetWidth(VampireInfoTLCIcon:GetWidth() + width  + offsetX)

    labelValueHeight = VampireInfoTLCLabelValue:IsHidden() and math.ceil(VampireInfoTLCLabelValue:GetHeight()) or math.ceil(VampireInfoTLCLabelValue:GetTextHeight())
    labelXPHeight = VampireInfoTLCLabelXP:IsHidden() and math.ceil(VampireInfoTLCLabelXP:GetHeight()) or math.ceil(VampireInfoTLCLabelXP:GetTextHeight())
    if settings.showSkillLineInfo == false then
        VampireInfoTLC:SetHeight(labelValueHeight - 1)
    else
        VampireInfoTLC:SetHeight((labelXPHeight + labelValueHeight) - 1)
    end
end

-- parse buff information
function vi.ParseBuff(buffName, timeEnding, timeStarted, phase)
    local value = "You are not a vampire!"
    local duration = ""
    local durationTime = 0
    local timeEnd
    local timeStart
    local isFirstPhase = phase == 1 or false

    if buffName ~= nil and timeEnding ~= nil and timeStarted ~= nil and not isFirstPhase == true then
        local settings = vi.vars
        local calculateDuration = ((settings.showIcon and settings.showCooldownIcon) or settings.showDuration) or false
        --d(">calculateDuration: " ..tostring(calculateDuration))
        --local buffNameClean = ZO_CachedStrFormat("<<C:1>>", buffName)
        value = tostring(buffName)
        --value = string.gsub(value,"%^N"," ")

        if calculateDuration then
            timeEnd = tonumber(timeEnding)
            timeStart = tonumber(timeStarted)
            if timeEnd > timeStart then
                local durationInMS = timeEnd-timeStart
                if durationInMS > 0 then
                    --Needed for the cooldown
                    local endTimeMS = timeEnd * 1000.0
                    local timeLeft = endTimeMS - GetFrameTimeMilliseconds()
                    vi.buffDurationTime = durationInMS * 1000.0
                    vi.buffRemainingTime = timeLeft
                    --Needed for the duration text label
                    local timeLeftInSeconds = GetTimeLeftUntilInSeconds(timeEnd)
                    duration = vi.SecondsToClock(timeLeftInSeconds)
                    --d(">timeStart: "..tostring(timeStart)..", timeEnd: "..tostring(timeEnd)..", timeLeftInMilliseconds: " ..tostring(timeLeft) .. ", timeLeftInSeconds: " ..tostring(timeLeftInSeconds) ..", duration: " ..tostring(duration))
                end
            end
        end

        --[[
        phase = string.match(value,"%d+")
        if phase ~= nil then
            phase = tonumber(phase)
        else
            phase = ""
        end
        ]]
    elseif isFirstPhase == true then
        vi.buffDurationTime = 0
        vi.buffRemainingTime = 0
        vi.lastBuffRemainingTime = 0
    end
    return value, duration--, phase
end
 
 -- return fontstring
function vi.GetFont()
    local font = "%s|%d"
    local settings = vi.vars
    return font:format(LMP:Fetch(LMP.MediaType.FONT, settings.fontface), settings.fontsize, settings.fontstyle)
end

-- get skill info for vampire skill-line
function vi.GetSkillLineXP()
    local skillIndex
    local SkillLinesCount
    --local SkillAbilityCount
    --local name
    --local texture

    local xpPre
    local xpMax
    local xpNow
    local lineName
    local lineLevel

    local found = false

    SkillLinesCount = GetNumSkillLines(SKILL_TYPE_WORLD)
    if SkillLinesCount == nil then return false, nil, nil, nil end
    --Todo: Remove after debugging
    --vi._skillDynamicInfo = vi._skillDynamicInfo or {}
    --[[
    for index=0, SkillLinesCount, 1 do
        skillIndex = index

        --TODO: remove after debugging
        --Get the skillLineId of vampire
        --GetSkillLineDynamicInfo(*[SkillType|#SkillType]* _skillType_, *luaindex* _skillLineIndex_)
        -- ** _Returns:_ *luaindex* _rank_, *bool* _advised_, *bool* _active_, *bool* _discovered_
        --local a,b,c,d = GetSkillLineDynamicInfo(SKILL_TYPE_WORLD, skillIndex)
        --vi._skillDynamicInfo = {
        --    [skillIndex] = {
        --        name = GetSkillLineName(SKILL_TYPE_WORLD, skillIndex),
        --        id = GetSkillLineId(SKILL_TYPE_WORLD, skillIndex),
        --        _rank_ = a,
        --        _advised_ = b,
        --        _active_ = c,
        --        _discovered_ = d,
        --    }
        -- }

        SkillAbilityCount = GetNumSkillAbilities(SKILL_TYPE_WORLD,skillIndex)
        if SkillAbilityCount ~= nil then
            for skillAbilityIndex=0, SkillAbilityCount, 1 do
                name, texture = GetSkillAbilityInfo(SKILL_TYPE_WORLD, skillIndex, skillAbilityIndex)
                if (string.find(texture,"ability_vampire_") ~= nil) then
                    found = true
                    break
                end
            end
        end
        if found == true then break end
    end
    ]]
    --Set found to true as we know the skillLineId of the vampire skills
    --and we got it in variable "vampireSkillsID"
    --GetSkillLineId(*[SkillType|#SkillType]* _skillType_, *luaindex* _skillLineIndex_)
    --** _Returns:_ *integer* _skillLineId_
    local skillLineId
    --local unlockedText
    --local isAvailable
    for i=1, SkillLinesCount, 1 do
        skillLineId = GetSkillLineId(SKILL_TYPE_WORLD, i)
        if skillLineId == vampireSkillsID then
            skillIndex = i
            found = true
            break
        end
    end
    if found == true and skillIndex and skillIndex > 0 then
        --Check if the vampire skills are discovered and active
        local rank,advised,active,discovered = GetSkillLineDynamicInfo(SKILL_TYPE_WORLD, skillIndex)
        if discovered == true and active == true then
            xpPre, xpMax, xpNow = GetSkillLineXPInfo(SKILL_TYPE_WORLD, skillIndex)
            if (xpMax == nil or xpNow == nil)  then
                xpMax = 0
                xpNow = 0
            end
            if GetSkillLineInfo then
                --lineName, lineLevel, isAvailable, skillLineId, advised, unlockedText, active, discovered = GetSkillLineInfo(SKILL_TYPE_WORLD, skillIndex)
                lineName, lineLevel = GetSkillLineInfo(SKILL_TYPE_WORLD, skillIndex)
            else
                local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(SKILL_TYPE_WORLD, skillIndex)
                if skillLineData then
                    --lineName, lineLevel, isAvailable, skillLineId, advised, unlockedText, active, discovered = skillLineData:GetName(), skillLineData:GetCurrentRank(), skillLineData:IsAvailable(), skillLineData:GetId(), skillLineData:IsAdvised(), skillLineData:GetUnlockText(), skillLineData:IsActive(), skillLineData:IsDiscovered()
                    lineName, lineLevel = skillLineData:GetName(), skillLineData:GetCurrentRank()
                end
            end
            if  lineLevel == nil then
                return false, nil, nil, nil
            end
            return found, xpMax, xpNow, lineLevel
        end
    end
    return false, nil, nil, nil
end

-- round
function vi.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function vi.ConfigMenu()
    --The LAM 2 panel data
    local addonPanelData    = {
        type                = "panel",
        name                = vi.name,
        displayName         = vi.name,
        author              = vi.author,
        version             = tostring(vi.version),
        registerForRefresh  = true,
        registerForDefaults = true,
        slashCommand 		= "/vis",
        website             = vi.website
    }
    --The LAM 2 panel options
    local optionsData = {
        --Main section
        {
            type = 'header',
            name = "Main",
        },
        {
            type = "checkbox",
            name = "Show buff info",
            tooltip = "Shows or hides buff information. When disabled only the stage is shown.",
            getFunc = function() return vi.vars.showBuffInfo end,
            setFunc = function(value)
                vi.vars.showBuffInfo = value
                vi.layoutChanged = true
                vi.StartUpdateUI(nil, true)
            end,
            default = vi.defaults.showBuffInfo,
        },
        {
            type = "checkbox",
            name = "Show skill line info",
            tooltip = "Shows or hides information of vampire skill line.",
            getFunc = function() return vi.vars.showSkillLineInfo end,
            setFunc = function(value)
                vi.vars.showSkillLineInfo = value
                updateNotAVampirePreview()
                vi.UpdateFont()
            end,
            default = vi.defaults.showSkillLineInfo,
        },
        {
            type = "checkbox",
            name = "Show icon",
            tooltip = "Shows or hides icon.",
            getFunc = function() return vi.vars.showIcon end,
            setFunc = function(value)
                vi.vars.showIcon = value
                updateNotAVampirePreview()
                vi.UpdateFont()
            end,
            default = vi.defaults.showIcon,
            width = "half"
        },
        {
            type = "checkbox",
            name = "Show stage texture",
            tooltip = "Show the texture of the vampire stage as icon, or a standard vampire icon",
            getFunc = function() return vi.vars.useStageIcon end,
            setFunc = function(value)
                vi.vars.useStageIcon = value
                updateNotAVampirePreview()
                vi.UpdateFont()
            end,
            default = vi.defaults.useStageIcon,
            disabled = function() return not vi.vars.showIcon end,
            width = "half"
        },
        {
            type = "checkbox",
            name = "Show duration text",
            tooltip = "Shows or hides duration of the buff as text, next to the buff info label.",
            getFunc = function() return vi.vars.showDuration end,
            setFunc = function(value)
                vi.vars.showDuration = value
                updateNotAVampirePreview()
                vi.UpdateFont()
            end,
            default = vi.defaults.showDuration,
        },
        {
            type = "checkbox",
            name = "Show duration at icon",
            tooltip = "Use icon as buff duration display in form of a radial cooldown at the icon.\nThis will only work if the icon is enabled!",
            getFunc = function() return vi.vars.showCooldownIcon end,
            setFunc = function(value)
                vi.vars.showCooldownIcon = value
                updateNotAVampirePreview()
                vi.UpdateFont()
            end,
            default = vi.defaults.showCooldownIcon,
            disabled = function() return not vi.vars.showIcon end,
        },
		{
			type = "slider",
			name = "Icon opacity during duration",
			tooltip = "Changes the icon's opacity as the icon is used for the duration radial cooldown.",
			min = 1,
			max = 100,
            step = 1,
			getFunc = function() return vi.vars.iconAlpha*100 end,
			setFunc = function(value)
                vi.vars.iconAlpha = value / 100
                if VampireInfoTLCIcon and not VampireInfoTLCIcon:IsHidden() then
                    VampireInfoTLCIcon:SetAlpha(vi.vars.iconAlpha)
                end
            end,
			default = vi.defaults.iconAlpha*100,
            disabled = function() return not vi.vars.showIcon or not vi.vars.showCooldownIcon end,
		},
		{
			type = "slider",
			name = "Update UI (in seconds)",
			tooltip = "Update the UI (reading your vampire player buff and the vampire skill line progress, and update the cooldown & duration) every n seconds, where n is the sldier value here.\nA higher value helps to reduce lag, where a lower value helps to update the UI more accurately!",
			min = 1,
			max = 60,
            step = 1,
			getFunc = function() return vi.vars.updateUISeconds/1000 end,
			setFunc = function(value)
					vi.vars.updateUISeconds = value*1000
                    vi.StartUpdateUI(value*1000)
 				end,
			default = vi.defaults.updateUISeconds/1000,
		},

        --Font section
        {
            type = 'header',
            name = "Font settings",
        },
		{
			type = 'dropdown',
			name = "Font face",
			tooltip = "Changes the font face.",
			choices = LMP:List(LMP.MediaType.FONT),
            getFunc = function() return vi.vars.fontface end,
            setFunc = function(fontValue)
                vi.vars.fontface = fontValue
                updateNotAVampirePreview()
                vi.UpdateFont()
            end,
            default = vi.defaults.fontface,
        },
		{
			type = "slider",
			name = "Font Size",
			tooltip = "Changes the font size.",
			min = 10,
			max = 50,
            step = 1,
			getFunc = function() return vi.vars.fontsize end,
			setFunc = function(value)
                vi.vars.fontsize = value
                updateNotAVampirePreview()
                vi.UpdateFont()
            end,
			default = vi.defaults.fontsize,
		},

        --Background section
        {
            type = 'header',
            name = "Background settings",
        },
		{
			type = "slider",
			name = "Background opacity",
			tooltip = "Changes the background opacity.",
			min = 1,
			max = 100,
            step = 1,
			getFunc = function() return vi.vars.alpha*100 end,
			setFunc = function(value)
					vi.vars.alpha = value / 100
                    VampireInfoTLCBG:SetAlpha(vi.vars.alpha)
 				end,
			default = vi.defaults.alpha*100,
		},

        --Color section
        {
            type = 'header',
            name = "Color settings",
        },
		{
			type = "colorpicker",
			name = "Skill Line Color",
			tooltip = "The color of the skill line.",
			getFunc = function()
                return vi.vars.colors.skillLineColor.r, vi.vars.colors.skillLineColor.g, vi.vars.colors.skillLineColor.b, vi.vars.colors.skillLineColor.a
            end,
            setFunc = function(r,g,b,a)
            	vi.vars.colors.skillLineColor = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
			end,
            width="full",
            default = vi.defaults.colors.skillLineColor,
		},
		{
			type = "colorpicker",
			name = "Text color stage 1",
			tooltip = "The color of the text if you are a vampire at stage 1",
			getFunc = function()
                return vi.vars.colors.textLabel[1].r,vi.vars.colors.textLabel[1].g,vi.vars.colors.textLabel[1].b,vi.vars.colors.textLabel[1].a
            end,
            setFunc = function(r,g,b,a)
            	vi.vars.colors.textLabel[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
			end,
            width="full",
            default = vi.defaults.colors.textLabel[1],
		},
		{
			type = "colorpicker",
			name = "Text color stage 2",
			tooltip = "The color of the text if you are a vampire at stage 2",
			getFunc = function()
                return vi.vars.colors.textLabel[2].r,vi.vars.colors.textLabel[2].g,vi.vars.colors.textLabel[2].b,vi.vars.colors.textLabel[2].a
            end,
            setFunc = function(r,g,b,a)
            	vi.vars.colors.textLabel[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
			end,
            width="full",
            default = vi.defaults.colors.textLabel[2],
		},
		{
			type = "colorpicker",
			name = "Text color stage 3",
			tooltip = "The color of the text if you are a vampire at stage 3",
			getFunc = function()
                return vi.vars.colors.textLabel[3].r,vi.vars.colors.textLabel[3].g,vi.vars.colors.textLabel[3].b,vi.vars.colors.textLabel[3].a
            end,
            setFunc = function(r,g,b,a)
            	vi.vars.colors.textLabel[3] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
			end,
            width="full",
            default = vi.defaults.colors.textLabel[3],
		},
		{
			type = "colorpicker",
			name = "Text color stage 4",
			tooltip = "The color of the text if you are a vampire at stage 4",
			getFunc = function()
                return vi.vars.colors.textLabel[4].r,vi.vars.colors.textLabel[4].g,vi.vars.colors.textLabel[4].b,vi.vars.colors.textLabel[4].a
            end,
            setFunc = function(r,g,b,a)
            	vi.vars.colors.textLabel[4] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
			end,
            width="full",
            default = vi.defaults.colors.textLabel[4],
		},



    }
    --Register the LAM 2 panel now
    vi.lamPanel = LAM:RegisterAddonPanel(vi.name .. "_SettingsMenu", addonPanelData)
    --Add the options table to the LAM 2 panel
    LAM:RegisterOptionControls(vi.name .. "_SettingsMenu", optionsData)

    local function addonMenuOnPanelOpenedCallback(panel)
        if panel ~= vi.lamPanel then return end
        vi.TLC:SetHidden(false)
    end
    --Register the callback for the LAM panel opened function
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", addonMenuOnPanelOpenedCallback)
    local function addonMenuOnPanelClosedCallback(panel)
        if panel ~= vi.lamPanel then return end
        vi.TLC:SetHidden(true)
    end
    --Register the callback for the LAM panel closed function
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", addonMenuOnPanelClosedCallback)
end

function vi.StartUpdateUI(value, forceUpdateNow)
    forceUpdateNow = forceUpdateNow or false
    --Register an update timer every 3 seconds to update the vampire statusbar
    local onUpdateIdentifier = vi.name .. "_RegisterForUpdate_OnUpdateSelf"
    --Unregister old updaters
    EVENT_MANAGER:UnregisterForUpdate(onUpdateIdentifier)

    local function callMe()
        vi.OnUpdateSelf()
    end

    if forceUpdateNow == true then
        callMe()
    end

    value = value or vi.vars.updateUISeconds
    if not value or value <= 1000 then
        value = 1000
    elseif value > 60000 then
        value = 60000
    end

    --register the new updater of the UI
    EVENT_MANAGER:RegisterForUpdate(onUpdateIdentifier, value, callMe)
end

-- initialize the addon
function vi.Init(eventCode, addOnName)
    -- init only us!
    if (vi.name == addOnName) then
        EVENT_MANAGER:UnregisterForEvent(vi.name .. "_AddOn_Loaded", EVENT_ADD_ON_LOADED)

        LMP = LibMediaProvider
        LAM = LibAddonMenu2
        LVAMP = LibVampire

        -- get saved variables, or set defaults. Using server dependent SV and for all accounts the same
        --ZO_SavedVars:NewAccountWide(SavedVariableTable, version, namespace, defaults, profile, displayName)
        vi.vars = ZO_SavedVars:NewAccountWide("VampireInfo_SV", vi.svVersion, nil, vi.defaults, GetWorldName(), "AllAccountsTheSame")
        local settings = vi.vars

        -- init some variables
        vi.lastFoundVampireBuffIndexOnPlayer = 0
        vi.lastPhase = 0
        vi.lastXP = 0
        vi.buffDurationTime = 0
        vi.buffRemainingTime = 0
        vi.lastRun = 0
        vi.lastBuffRemainingTime = 0
        vi.layoutChanged = false

        vi.TLC = VampireInfoTLC
        vi.TLC:SetHidden(false)

        -- init view
        VampireInfoTLC:ClearAnchors()
        local locVars = settings.location
        VampireInfoTLC:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, locVars.x, locVars.y)

        VampireInfoTLCBG:SetAlpha(settings.alpha)
        local skillLineColor = settings.colors.skillLineColor
        VampireInfoTLCLabelXP:SetColor(skillLineColor.r,skillLineColor.g,skillLineColor.b,skillLineColor.a)

        vi.UpdateFont()

        -- config menu
        vi.ConfigMenu()

        -- register Events for show / hide
        --EVENT_MANAGER:RegisterForEvent("VI",  EVENT_ACTION_LAYER_PUSHED , function(eventCode,layerIndex,activeLayerIndex) if (activeLayerIndex == 3) then VampireInfoTLC:SetHidden(true) end end)
        --EVENT_MANAGER:RegisterForEvent("VI",  EVENT_ACTION_LAYER_POPPED , function() VampireInfoTLC:SetHidden(false) end)

        --Add fragment to hide TLC at menus
        local fragmentVITLC = ZO_HUDFadeSceneFragment:New(vi.TLC, nil, 0)
        vi.fragment = fragmentVITLC
        HUD_SCENE:AddFragment(fragmentVITLC)
        HUD_UI_SCENE:AddFragment(fragmentVITLC)
        --Callback function for HUD scene
        fragmentVITLC:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_FRAGMENT_SHOWING or newState == SCENE_FRAGMENT_SHOWN then
                vi.TLC:SetHidden(vi.notAVampire)
            end
        end)
        -- we are initialized!
        vi.initialized = true

        --Once update the values on the UI manually now
        --Then register the event update timer to update each x seconds
        vi.StartUpdateUI(nil, true)
    end

end

 -- register for addon init
EVENT_MANAGER:RegisterForEvent(vi.name .. "_AddOn_Loaded", EVENT_ADD_ON_LOADED, vi.Init)
