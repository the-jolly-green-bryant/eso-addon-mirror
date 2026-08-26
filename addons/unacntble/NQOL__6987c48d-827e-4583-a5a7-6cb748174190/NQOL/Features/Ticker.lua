NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Ticker = {}

local EVENT_NAMESPACE = "NQOL_Ticker"
local UPDATE_INTERVAL_MS = 1000
local TICKER_INITIAL_WIDTH = 760
local TICKER_MIN_WIDTH = 120
local TICKER_HORIZONTAL_PADDING = 24
local ROW_MIN_HEIGHT = 30
local ROW_GAP = 2
local DRAW_LEVEL = 20
local INSET_X = 0
local INSET_Y = 0
local ICON_SIZE = 22
local ENTRY_GAP = 18
local TEXT_GAP = 5
local TEXTURE_WHITE = "EsoUI/Art/Miscellaneous/white.dds"
local MAIL_ICON = "EsoUI/Art/MenuBar/Gamepad/gp_playermenu_icon_mail.dds"
local CLOCK_ICON_FILE = "nqol_clock.dds"
local SOUL_GEM_FALLBACK_ICON = "EsoUI/Art/Inventory/inventory_tabIcon_Craftbag_enchanting_up.dds"
local GAMEPLAY_SCENES = {
    hud = true,
    siegeBar = true,
}

local ROW_OFF = "off"
local ROW_1 = "row1"
local ROW_2 = "row2"
local ROW_3 = "row3"
local ROW_CHOICES = { ROW_OFF, ROW_1, ROW_2, ROW_3 }
local ROW_CHOICE_NAMES = NQOL.Lexicon.LocalizedList({
    "features.ticker.row_hidden", "features.ticker.row_one", "features.ticker.row_two", "features.ticker.row_three",
})
local ALIGNMENT_LEFT = "left"
local ALIGNMENT_RIGHT = "right"
local ALIGNMENT_CENTER = "center"
local ALIGNMENT_CHOICES = { ALIGNMENT_LEFT, ALIGNMENT_RIGHT, ALIGNMENT_CENTER }
local ALIGNMENT_CHOICE_NAMES = NQOL.Lexicon.LocalizedList({
    "features.ticker.alignment_left", "features.ticker.alignment_right", "features.ticker.alignment_center",
})
local VALID_ALIGNMENTS = {
    [ALIGNMENT_LEFT] = true,
    [ALIGNMENT_RIGHT] = true,
    [ALIGNMENT_CENTER] = true,
}
local DEFAULT_FONT_SIZE = 34
local FONT_SIZE_MIN = 16
local FONT_SIZE_MAX = 48
local DEFAULT_BACKGROUND_OPACITY = 0
local BACKGROUND_OPACITY_MIN = 0
local BACKGROUND_OPACITY_MAX = 100
local VALID_ROWS = {
    [ROW_OFF] = true,
    [ROW_1] = true,
    [ROW_2] = true,
    [ROW_3] = true,
}

local armourSlots = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_HAND,
}

local weaponSlots = {
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}

local defaults = {
    ticker = {
        enabled = false,
        horizontalPosition = 100,
        verticalPosition = 0,
        showInSettings = true,
        coloredIcons = true,
        alignment = ALIGNMENT_CENTER,
        font = NQOL.Util.GetDefaultFont(),
        fontSize = DEFAULT_FONT_SIZE,
        backgroundOpacity = DEFAULT_BACKGROUND_OPACITY,
        entries = {},
    },
}

local savedVariables
local initialized = false
local sceneCallbackInstalled = false
local settingsPanelVisible = false
local updateLoopRunning = false
local sceneUpdateQueued = false
local tickerControl
local tickerBackground
local refreshRetryQueued = false
local measuringLabel
local rowControls = {}
local dividerControls = {}
local entryControls = {}
local tickerScratch = {
    definitions = { {}, {}, {} },
    values = { {}, {}, {} },
    controls = { {}, {}, {} },
    widths = { 0, 0, 0 },
}
local fontStringCache = {}
local soulGemCacheDirty = true
local soulGemCountCache = 0
local soulGemIconCache = SOUL_GEM_FALLBACK_ICON
local inventoryEventRegistered = false
local vampireTimerCached = false
local vampireTimerValue
local vampireTimerIcon

local ICON_COLORS = {
    alliancePoints = { 0.85, 0.39, 1.00, 1 },
    armourDurability = { 0.92, 0.82, 0.58, 1 },
    autoInviteMode = { 0.50, 0.84, 1.00, 1 },
    bagSpace = { 0.62, 0.78, 1.00, 1 },
    challengeDifficulty = { 0.88, 0.52, 1.00, 1 },
    clock = { 0.42, 0.88, 1.00, 1 },
    clock12 = { 0.42, 0.88, 1.00, 1 },
    cp = { 0.94, 0.78, 0.22, 1 },
    cpXp = { 1.00, 0.55, 0.18, 1 },
    crownGems = { 0.50, 0.95, 0.95, 1 },
    endeavorSeals = { 0.55, 0.72, 1.00, 1 },
    fps = { 0.30, 0.95, 0.44, 1 },
    gold = { 1.00, 0.80, 0.22, 1 },
    latency = { 0.45, 0.82, 1.00, 1 },
    mailCount = { 0.96, 0.70, 0.26, 1 },
    memoryUsage = { 1.00, 0.42, 0.30, 1 },
    mountFeedTimer = { 0.72, 0.52, 0.32, 1 },
    soulGems = { 0.82, 0.48, 1.00, 1 },
    tamrielTime = { 0.78, 0.58, 0.26, 1 },
    telVarStones = { 0.64, 1.00, 0.42, 1 },
    tradeBars = { 1.00, 0.64, 0.28, 1 },
    transmuteCrystals = { 0.38, 0.98, 0.88, 1 },
    undauntedKeys = { 0.82, 0.66, 1.00, 1 },
    vampireLevel = { 0.95, 0.22, 0.26, 1 },
    vampireTimer = { 0.95, 0.22, 0.26, 1 },
    weaponCharges = { 0.78, 0.90, 1.00, 1 },
    writVouchers = { 0.98, 0.88, 0.48, 1 },
}

local OVERLAND_DIFFICULTY_TEXTURE_NAMES = {}

local function AddOverlandDifficultyTextureName(difficultyType, textureName)
    if difficultyType ~= nil then
        OVERLAND_DIFFICULTY_TEXTURE_NAMES[difficultyType] = textureName
    end
end

AddOverlandDifficultyTextureName(OVERLAND_DIFFICULTY_TYPE_BASEGAME, "basegame")
AddOverlandDifficultyTextureName(OVERLAND_DIFFICULTY_TYPE_JOURNEYMAN, "journeyman")
AddOverlandDifficultyTextureName(OVERLAND_DIFFICULTY_TYPE_ADVENTURER, "adventurer")
AddOverlandDifficultyTextureName(OVERLAND_DIFFICULTY_TYPE_VETERAN, "veteran")

local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round
local FormatNumber = NQOL.Util.FormatNumber

local function MoveControlAbove(control, drawLevel)
    if not control then
        return
    end

    if control.SetDrawLayer and DL_OVERLAY then
        control:SetDrawLayer(DL_OVERLAY)
    end

    if control.SetDrawTier and DT_HIGH then
        control:SetDrawTier(DT_HIGH)
    end

    if control.SetDrawLevel then
        control:SetDrawLevel(drawLevel or DRAW_LEVEL)
    end
end

local function GetCurrencyIcon(currencyType)
    if not currencyType then
        return TEXTURE_WHITE
    end

    if ZO_Currency_GetPlatformCurrencyIcon then
        return ZO_Currency_GetPlatformCurrencyIcon(currencyType)
    end

    if GetCurrencyGamepadIcon then
        return GetCurrencyGamepadIcon(currencyType)
    end

    if GetCurrencyKeyboardIcon then
        return GetCurrencyKeyboardIcon(currencyType)
    end

    return TEXTURE_WHITE
end

local function GetCurrencyValue(currencyType, currencyLocation)
    if not GetCurrencyAmount or not currencyType or not currencyLocation then
        return nil
    end

    return FormatNumber(GetCurrencyAmount(currencyType, currencyLocation) or 0)
end

local function GetCurrencyDisplayName(currencyType, fallbackKey)
    if GetCurrencyName then
        local name = GetCurrencyName(currencyType, false, false)
        if name and name ~= "" then return name end
    end
    return NQOL.L(fallbackKey)
end

local function CreateCurrencyEntry(key, labelKey, tooltipKey, currencyType, currencyLocation)
    return {
        key = key,
        label = GetCurrencyDisplayName(currencyType, labelKey),
        tooltip = NQOL.L(tooltipKey),
        labelKey = labelKey,
        tooltipKey = tooltipKey,
        currencyType = currencyType,
        icon = function()
            return GetCurrencyIcon(currencyType)
        end,
        getValue = function()
            return GetCurrencyValue(currencyType, currencyLocation)
        end,
    }
end

local function FormatMilliseconds(milliseconds)
    milliseconds = tonumber(milliseconds) or 0
    if milliseconds <= 0 then
        return NQOL.L("features.ticker.ready")
    end

    if ZO_FormatTimeMilliseconds and TIME_FORMAT_STYLE_COLONS and TIME_FORMAT_PRECISION_TWELVE_HOUR then
        return ZO_FormatTimeMilliseconds(milliseconds, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
    end

    local totalSeconds = math.floor(milliseconds / 1000)
    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60

    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function FormatLocalTime()
    if os and os.date then
        return os.date("%H:%M:%S")
    end

    if GetTimeString then
        return GetTimeString()
    end

    return ""
end

local function FormatLocalTime12()
    if GetSecondsSinceMidnight and ZO_FormatTime and TIME_FORMAT_STYLE_CLOCK_TIME and TIME_FORMAT_PRECISION_TWELVE_HOUR then
        return ZO_FormatTime(GetSecondsSinceMidnight(), TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWELVE_HOUR)
    end

    if os and os.date then
        return os.date("%I:%M %p")
    end

    return ""
end

local function FormatTimeParts(hours, minutes, seconds)
    return string.format(
        "%02d:%02d:%02d",
        tonumber(hours) or 0,
        tonumber(minutes) or 0,
        tonumber(seconds) or 0
    )
end

local function FormatTamrielTime()
    if not GetLocalTimeOfDay then
        return nil
    end

    return FormatTimeParts(GetLocalTimeOfDay())
end

local function HasWornItem(slotId)
    return HasItemInSlot and HasItemInSlot(BAG_WORN, slotId)
end

local function HasTrainableRidingStat()
    if STABLE_MANAGER and STABLE_MANAGER.IsRidingSkillMaxedOut then
        return not STABLE_MANAGER:IsRidingSkillMaxedOut()
    end

    if not GetRidingStats then
        return false
    end

    local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()
    return (inventoryBonus or 0) < (maxInventoryBonus or 0)
        or (staminaBonus or 0) < (maxStaminaBonus or 0)
        or (speedBonus or 0) < (maxSpeedBonus or 0)
end

local function GetLowestArmourDurability()
    if not GetItemCondition then
        return nil
    end

    local lowest
    for _, slotId in ipairs(armourSlots) do
        if HasWornItem(slotId) then
            local condition = tonumber(GetItemCondition(BAG_WORN, slotId))
            if condition and condition < 100 and (not lowest or condition < lowest) then
                lowest = condition
            end
        end
    end

    return lowest
end

local function GetLowestWeaponCharge()
    if not GetChargeInfoForItem then
        return nil
    end

    local lowest
    for _, slotId in ipairs(weaponSlots) do
        if HasWornItem(slotId) then
            local charge, maxCharge = GetChargeInfoForItem(BAG_WORN, slotId)
            charge = tonumber(charge)
            maxCharge = tonumber(maxCharge)
            if charge and maxCharge and maxCharge > 0 then
                local percent = math.floor((charge / maxCharge) * 100)
                if percent < 100 and (not lowest or percent < lowest) then
                    lowest = percent
                end
            end
        end
    end

    return lowest
end

local function RefreshSoulGemCache()
    if not soulGemCacheDirty then
        return
    end

    soulGemCacheDirty = false
    soulGemCountCache = 0
    soulGemIconCache = SOUL_GEM_FALLBACK_ICON

    if not GetBagSize or not IsItemSoulGem or not GetItemInfo then
        return
    end

    local bagSize = GetBagSize(BAG_BACKPACK) or 0
    for slotId = 0, bagSize do
        if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, slotId) then
            local icon, stackCount = GetItemInfo(BAG_BACKPACK, slotId)
            soulGemCountCache = soulGemCountCache + (tonumber(stackCount) or 1)
            if icon and icon ~= "" and soulGemIconCache == SOUL_GEM_FALLBACK_ICON then
                soulGemIconCache = icon
            end
        end
    end
end

local function GetFilledSoulGemCount()
    RefreshSoulGemCache()
    return soulGemCountCache
end

local function GetSoulGemIcon()
    RefreshSoulGemCache()
    return soulGemIconCache
end

local function GetCurrentChampionPoints()
    if GetPlayerChampionPointsEarned then
        return GetPlayerChampionPointsEarned()
    end

    if GetUnitChampionPoints then
        return GetUnitChampionPoints("player")
    end

    return 0
end

local function IsChampionProgression()
    return CanUnitGainChampionPoints and CanUnitGainChampionPoints("player") == true
end

local function GetCurrentLevel()
    if GetUnitLevel then
        return tonumber(GetUnitLevel("player")) or 0
    end

    return 0
end

local function GetCpOrLevelValue()
    if IsChampionProgression() then
        return FormatNumber(GetCurrentChampionPoints())
    end

    return "L" .. tostring(GetCurrentLevel())
end

local function GetCpOrLevelIcon()
    if IsChampionProgression() then
        return "EsoUI/Art/Champion/champion_icon.dds"
    end

    return nil
end

local function GetCpOrLevelXpValue()
    if IsChampionProgression() then
        if not GetPlayerChampionXP or not GetNumChampionXPInChampionPoint then
            return nil
        end

        local currentCp = tonumber(GetCurrentChampionPoints()) or 0
        return FormatNumber(GetPlayerChampionXP() or 0) .. "/" .. FormatNumber(GetNumChampionXPInChampionPoint(currentCp) or 0)
    end

    if not GetUnitXP or not GetUnitXPMax then
        return nil
    end

    return FormatNumber(GetUnitXP("player") or 0) .. "/" .. FormatNumber(GetUnitXPMax("player") or 0)
end

local VAMPIRE_STAGE_BY_ICON = {
    ["/esoui/art/icons/ability_u26_vampire_infection_stage1.dds"] = 1,
    ["/esoui/art/icons/ability_u26_vampire_infection_stage2.dds"] = 2,
    ["/esoui/art/icons/ability_u26_vampire_infection_stage3.dds"] = 3,
    ["/esoui/art/icons/ability_u26_vampire_infection_stage4.dds"] = 4,
}
local VAMPIRE_STAGE_ICON = "/esoui/art/icons/crownstore_skillline_vampire.dds"

local function GetVampireStageFromIcon(iconFile)
    if type(iconFile) ~= "string" or iconFile == "" then
        return nil
    end

    return VAMPIRE_STAGE_BY_ICON[string.lower(iconFile)]
end

local function ComputeVampireTimer()
    if not GetNumBuffs or not GetUnitBuffInfo then
        return nil
    end

    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or nil
    if not now and GetFrameTimeMilliseconds then
        now = GetFrameTimeMilliseconds() / 1000
    end
    if not now then
        now = 0
    end

    local bestRemaining
    local bestIcon
    for index = 1, GetNumBuffs("player") do
        local _, _, timeEnding, _, _, iconFile = GetUnitBuffInfo("player", index)
        local ending = tonumber(timeEnding)
        if GetVampireStageFromIcon(iconFile) and ending and ending > now then
            local remaining = math.floor((ending - now) * 1000)
            if not bestRemaining or remaining < bestRemaining then
                bestRemaining = remaining
                bestIcon = iconFile
            end
        end
    end

    if bestRemaining then
        return FormatMilliseconds(bestRemaining), bestIcon
    end

    return nil
end

local function GetVampireTimer()
    if not vampireTimerCached then
        vampireTimerValue, vampireTimerIcon = ComputeVampireTimer()
        vampireTimerCached = true
    end

    return vampireTimerValue, vampireTimerIcon
end

local function GetVampireLevel()
    if GetPlayerCurseType and CURSE_TYPE_VAMPIRE and GetPlayerCurseType() ~= CURSE_TYPE_VAMPIRE then
        return nil
    end

    if not GetNumBuffs or not GetUnitBuffInfo then
        return nil
    end

    local highestStage
    for index = 1, GetNumBuffs("player") do
        local _, _, _, _, _, iconFile = GetUnitBuffInfo("player", index)
        local stage = GetVampireStageFromIcon(iconFile)
        if stage and (not highestStage or stage > highestStage) then
            highestStage = stage
        end
    end

    if highestStage then
        return NQOL.L("features.ticker.stage", tostring(highestStage))
    end

    return nil
end

local function GetUnreadMailCount()
    if not GetNumUnreadMail then
        return nil
    end

    local count = tonumber(GetNumUnreadMail()) or 0
    if count <= 0 then
        return nil
    end

    return tostring(count)
end

local function GetChallengeDifficulty()
    if not GetOverlandDifficulty then
        return nil
    end

    return GetOverlandDifficulty()
end

local function GetChallengeDifficultyText()
    local difficulty = GetChallengeDifficulty()
    if not difficulty then
        return nil
    end

    if GetString then
        local text = GetString("SI_OVERLANDDIFFICULTYTYPE", difficulty)
        if text and text ~= "" then
            return text
        end
    end

    return tostring(difficulty)
end

local function GetChallengeDifficultyIcon()
    local difficulty = GetChallengeDifficulty()
    local textureName = difficulty and OVERLAND_DIFFICULTY_TEXTURE_NAMES[difficulty] or "basegame"

    return string.format("EsoUI/Art/ChallengeDifficulty/challengeDifficulty_%s_up.dds", textureName)
end

local function GetAutoInviteModeText()
    if not NQOL.Features or not NQOL.Features.Grouping or not NQOL.Features.Grouping.GetAutoInviteModeName then
        return nil
    end

    return NQOL.Features.Grouping.GetAutoInviteModeName()
end

local function GetClockIcon()
    return "/" .. tostring(NQOL.name or "NQOL") .. "/Art/Ticker/" .. CLOCK_ICON_FILE
end

-- Static texture paths below are intentionally limited to paths verified in ESOUI source or extracted addon sources.
local entryDefinitions = {
    CreateCurrencyEntry(
        "alliancePoints",
        "features.ticker.currency.alliance_points",
        "features.ticker.currency.alliance_points_tooltip",
        CURT_ALLIANCE_POINTS,
        CURRENCY_LOCATION_CHARACTER
    ),
    {
        key = "armourDurability",
        label = NQOL.L("features.ticker.armour_durability_46cb791"),
        tooltip = NQOL.L("features.ticker.shows_the_lowest_equipped_armor_durability_hides_whe_e1703b5"),
        icon = "EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds",
        getValue = function()
            local lowest = GetLowestArmourDurability()
            if not lowest then
                return nil
            end
            return tostring(Round(lowest)) .. "%"
        end,
    },
    {
        key = "autoInviteMode",
        label = NQOL.L("features.ticker.auto_invite_mode_0b70d75"),
        tooltip = NQOL.L("features.ticker.shows_the_current_grouping_auto_invite_mode_ab7d773"),
        iconText = "INV",
        getValue = GetAutoInviteModeText,
    },
    {
        key = "bagSpace",
        label = NQOL.L("features.ticker.bag_space_91d1a8c"),
        tooltip = NQOL.L("features.ticker.shows_used_and_total_backpack_slots_973d506"),
        icon = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_all.dds",
        getValue = function()
            if not GetNumBagUsedSlots or not GetBagSize then
                return nil
            end
            return tostring(GetNumBagUsedSlots(BAG_BACKPACK) or 0) .. "/" .. tostring(GetBagSize(BAG_BACKPACK) or 0)
        end,
    },
    {
        key = "challengeDifficulty",
        label = NQOL.L("features.ticker.challenge_difficulty_dc6ccb7"),
        tooltip = NQOL.L("features.ticker.shows_this_character_s_selected_challenge_difficulty_ea76d12"),
        icon = GetChallengeDifficultyIcon,
        getValue = GetChallengeDifficultyText,
    },
    {
        key = "clock",
        label = NQOL.L("features.ticker.clock_04f6b3e"),
        tooltip = NQOL.L("features.ticker.shows_your_local_time_in_24_hour_format_2ca26ed"),
        icon = GetClockIcon,
        getValue = FormatLocalTime,
    },
    {
        key = "clock12",
        label = NQOL.L("features.ticker.clock12"),
        tooltip = NQOL.L("features.ticker.clock12_tooltip"),
        icon = GetClockIcon,
        getValue = FormatLocalTime12,
    },
    {
        key = "cp",
        label = NQOL.L("features.ticker.cp_f19057b"),
        tooltip = NQOL.L("features.ticker.shows_the_account_s_current_champion_points_or_this__d485fb9"),
        icon = GetCpOrLevelIcon,
        hideIconWhenMissing = true,
        getValue = GetCpOrLevelValue,
    },
    {
        key = "cpXp",
        label = NQOL.L("features.ticker.cp_xp_85779db"),
        tooltip = NQOL.L("features.ticker.shows_champion_xp_progress_or_level_xp_before_champi_bf38c0c"),
        icon = GetCpOrLevelIcon,
        hideIconWhenMissing = true,
        getValue = GetCpOrLevelXpValue,
    },
    CreateCurrencyEntry(
        "crownGems",
        "features.ticker.currency.crown_gems",
        "features.ticker.currency.crown_gems_tooltip",
        CURT_CROWN_GEMS,
        CURRENCY_LOCATION_ACCOUNT
    ),
    CreateCurrencyEntry(
        "endeavorSeals",
        "features.ticker.currency.endeavor_seals",
        "features.ticker.currency.endeavor_seals_tooltip",
        CURT_ENDEAVOR_SEALS,
        CURRENCY_LOCATION_ACCOUNT
    ),
    CreateCurrencyEntry(
        "tradeBars",
        "features.ticker.currency.trade_bars",
        "features.ticker.currency.trade_bars_tooltip",
        CURT_TRADE_BARS,
        CURRENCY_LOCATION_ACCOUNT
    ),
    {
        key = "fps",
        label = NQOL.L("features.ticker.fps_fce204a"),
        tooltip = NQOL.L("features.ticker.shows_current_frames_per_second_ff66e76"),
        iconText = "FPS",
        getValue = function()
            if not GetFramerate then
                return nil
            end
            return tostring(Round(GetFramerate()))
        end,
    },
    {
        key = "gold",
        label = NQOL.L("features.ticker.gold_amount_7afd1ac"),
        tooltip = NQOL.L("features.ticker.shows_this_character_s_carried_gold_52d8a95"),
        icon = "EsoUI/Art/currency/gamepad/gp_gold.dds",
        getValue = function()
            if not GetCurrencyAmount then
                return nil
            end
            return FormatNumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER))
        end,
    },
    {
        key = "latency",
        label = NQOL.L("features.ticker.latency_3e39972"),
        tooltip = NQOL.L("features.ticker.shows_current_connection_latency_af9f590"),
        icon = "EsoUI/Art/Campaign/campaignBrowser_medPop.dds",
        getValue = function()
            if not GetLatency then
                return nil
            end
            return tostring(Round(GetLatency())) .. " ms"
        end,
    },
    {
        key = "memoryUsage",
        label = NQOL.L("features.ticker.memory_usage_530f6dd"),
        tooltip = NQOL.L("features.ticker.shows_used_and_available_add_on_memory_498e68d"),
        icon = "EsoUI/Art/Miscellaneous/eso_icon_warning.dds",
        getValue = function()
            if not GetTotalUserAddOnMemoryPoolUsageMB or not GetTotalUserAddOnMemoryPoolCapacityMB then
                return nil
            end
            return string.format("%.1f/%d MB", GetTotalUserAddOnMemoryPoolUsageMB() or 0, GetTotalUserAddOnMemoryPoolCapacityMB() or 0)
        end,
    },
    {
        key = "mailCount",
        label = NQOL.L("features.ticker.mail_count_64acf2a"),
        tooltip = NQOL.L("features.ticker.shows_unread_mail_when_new_mail_is_waiting_a3239b6"),
        icon = MAIL_ICON,
        getValue = GetUnreadMailCount,
    },
    {
        key = "mountFeedTimer",
        label = NQOL.L("features.ticker.mount_feed_timer_f8b529a"),
        tooltip = NQOL.L("features.ticker.shows_time_until_this_character_can_train_riding_aga_8a9b569"),
        icon = "EsoUI/Art/Collections/Default/collections_default_mount.dds",
        getValue = function()
            if not GetTimeUntilCanBeTrained or not HasTrainableRidingStat() then
                return nil
            end
            return FormatMilliseconds(GetTimeUntilCanBeTrained() or 0)
        end,
    },
    {
        key = "soulGems",
        label = NQOL.L("features.ticker.soul_gems_93a52f5"),
        tooltip = NQOL.L("features.ticker.shows_filled_soul_gems_in_the_backpack_6321f4d"),
        icon = GetSoulGemIcon,
        getValue = function()
            return tostring(GetFilledSoulGemCount())
        end,
    },
    {
        key = "tamrielTime",
        label = NQOL.L("features.ticker.tamriel_time_eb46349"),
        tooltip = NQOL.L("features.ticker.shows_the_current_tamriel_time_in_24_hour_format_77f9d47"),
        icon = "EsoUI/Art/HUD/Gamepad/Ouroboros_Saving-128.dds",
        getValue = FormatTamrielTime,
    },
    CreateCurrencyEntry(
        "telVarStones",
        "features.ticker.currency.tel_var_stones",
        "features.ticker.currency.tel_var_stones_tooltip",
        CURT_TELVAR_STONES,
        CURRENCY_LOCATION_CHARACTER
    ),
    CreateCurrencyEntry(
        "transmuteCrystals",
        "features.ticker.currency.transmute_crystals",
        "features.ticker.currency.transmute_crystals_tooltip",
        CURT_CHAOTIC_CREATIA,
        CURRENCY_LOCATION_ACCOUNT
    ),
    CreateCurrencyEntry(
        "undauntedKeys",
        "features.ticker.currency.undaunted_keys",
        "features.ticker.currency.undaunted_keys_tooltip",
        CURT_UNDAUNTED_KEYS,
        CURRENCY_LOCATION_ACCOUNT
    ),
    {
        key = "vampireLevel",
        label = NQOL.L("features.ticker.vampire_level_47fd8ae"),
        tooltip = NQOL.L("features.ticker.shows_this_character_s_current_vampire_stage_9c7d8b8"),
        icon = VAMPIRE_STAGE_ICON,
        getValue = GetVampireLevel,
    },
    {
        key = "vampireTimer",
        label = NQOL.L("features.ticker.vampire_timer_6c22eac"),
        tooltip = NQOL.L("features.ticker.shows_time_until_your_vampire_stage_drops_9f5a4f3"),
        icon = function()
            local _, icon = GetVampireTimer()
            return icon or "/esoui/art/icons/ability_u26_vampire_infection_stage1.dds"
        end,
        getValue = function()
            return GetVampireTimer()
        end,
    },
    {
        key = "weaponCharges",
        label = NQOL.L("features.ticker.weapon_charges_d0391be"),
        tooltip = NQOL.L("features.ticker.shows_the_lowest_equipped_weapon_charge_hides_when_a_0cda3de"),
        icon = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds",
        getValue = function()
            local lowest = GetLowestWeaponCharge()
            if not lowest then
                return nil
            end
            return tostring(Round(lowest)) .. "%"
        end,
    },
    CreateCurrencyEntry(
        "writVouchers",
        "features.ticker.currency.writ_vouchers",
        "features.ticker.currency.writ_vouchers_tooltip",
        CURT_WRIT_VOUCHERS,
        CURRENCY_LOCATION_CHARACTER
    ),
}

local entryByKey = {}
for _, definition in ipairs(entryDefinitions) do
    entryByKey[definition.key] = definition
    defaults.ticker.entries[definition.key] = ROW_OFF
end

table.sort(entryDefinitions, function(left, right)
    return left.label < right.label
end)
NQOL.Lexicon.RegisterRefreshCallback(function()
    local keys = {
        armourDurability = { "features.ticker.armour_durability_46cb791", "features.ticker.shows_the_lowest_equipped_armor_durability_hides_whe_e1703b5" },
        autoInviteMode = { "features.ticker.auto_invite_mode_0b70d75", "features.ticker.shows_the_current_grouping_auto_invite_mode_ab7d773" },
        bagSpace = { "features.ticker.bag_space_91d1a8c", "features.ticker.shows_used_and_total_backpack_slots_973d506" },
        challengeDifficulty = { "features.ticker.challenge_difficulty_dc6ccb7", "features.ticker.shows_this_character_s_selected_challenge_difficulty_ea76d12" },
        clock = { "features.ticker.clock_04f6b3e", "features.ticker.shows_your_local_time_in_24_hour_format_2ca26ed" },
        clock12 = { "features.ticker.clock12", "features.ticker.clock12_tooltip" },
        cp = { "features.ticker.cp_f19057b", "features.ticker.shows_the_account_s_current_champion_points_or_this__d485fb9" },
        cpXp = { "features.ticker.cp_xp_85779db", "features.ticker.shows_champion_xp_progress_or_level_xp_before_champi_bf38c0c" },
        fps = { "features.ticker.fps_fce204a", "features.ticker.shows_current_frames_per_second_ff66e76" },
        gold = { "features.ticker.gold_amount_7afd1ac", "features.ticker.shows_this_character_s_carried_gold_52d8a95" },
        latency = { "features.ticker.latency_3e39972", "features.ticker.shows_current_connection_latency_af9f590" },
        memoryUsage = { "features.ticker.memory_usage_530f6dd", "features.ticker.shows_used_and_available_add_on_memory_498e68d" },
        mailCount = { "features.ticker.mail_count_64acf2a", "features.ticker.shows_unread_mail_when_new_mail_is_waiting_a3239b6" },
        mountFeedTimer = { "features.ticker.mount_feed_timer_f8b529a", "features.ticker.shows_time_until_this_character_can_train_riding_aga_8a9b569" },
        soulGems = { "features.ticker.soul_gems_93a52f5", "features.ticker.shows_filled_soul_gems_in_the_backpack_6321f4d" },
        tamrielTime = { "features.ticker.tamriel_time_eb46349", "features.ticker.shows_the_current_tamriel_time_in_24_hour_format_77f9d47" },
        vampireLevel = { "features.ticker.vampire_level_47fd8ae", "features.ticker.shows_this_character_s_current_vampire_stage_9c7d8b8" },
        vampireTimer = { "features.ticker.vampire_timer_6c22eac", "features.ticker.shows_time_until_your_vampire_stage_drops_9f5a4f3" },
        weaponCharges = { "features.ticker.weapon_charges_d0391be", "features.ticker.shows_the_lowest_equipped_weapon_charge_hides_when_a_0cda3de" },
    }
    for _, definition in ipairs(entryDefinitions) do
        local definitionKeys = keys[definition.key]
        if definitionKeys then
            definition.label, definition.tooltip = NQOL.L(definitionKeys[1]), NQOL.L(definitionKeys[2])
        elseif definition.labelKey then
            definition.label = GetCurrencyDisplayName(definition.currencyType, definition.labelKey)
            definition.tooltip = NQOL.L(definition.tooltipKey)
        end
    end
    table.sort(entryDefinitions, function(left, right) return left.label < right.label end)
end)

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "ticker")
    local defaultSettings = defaults.ticker

    NQOL.Settings.EnsureTable(settings, "entries")
    NQOL.Settings.Boolean(settings, defaultSettings, "enabled")
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "horizontalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "verticalPosition", 0, 100)
    NQOL.Settings.Boolean(settings, defaultSettings, "showInSettings")
    NQOL.Settings.Boolean(settings, defaultSettings, "coloredIcons")
    NQOL.Settings.Choice(settings, defaultSettings, "alignment", VALID_ALIGNMENTS)
    if not NQOL.Util.IsFontChoice(settings.font) then
        settings.font = defaultSettings.font
    end
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "fontSize", FONT_SIZE_MIN, FONT_SIZE_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "backgroundOpacity", BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX, true)

    for _, definition in ipairs(entryDefinitions) do
        local value = settings.entries[definition.key]
        if not VALID_ROWS[value] then
            settings.entries[definition.key] = ROW_OFF
        end
    end

    return settings
end

local function HasEnabledEntry()
    local settings = GetSettings()
    for _, definition in ipairs(entryDefinitions) do
        if settings.entries[definition.key] ~= ROW_OFF then
            return true
        end
    end

    return false
end

local function GetScreenWidth()
    return GuiRoot and GuiRoot.GetWidth and GuiRoot:GetWidth() or 1920
end

local function GetScreenHeight()
    return GuiRoot and GuiRoot.GetHeight and GuiRoot:GetHeight() or 1080
end

local function ClearTickerScratch()
    for rowIndex = 1, 3 do
        local definitions = tickerScratch.definitions[rowIndex]
        local values = tickerScratch.values[rowIndex]
        local controls = tickerScratch.controls[rowIndex]
        for index = #definitions, 1, -1 do definitions[index] = nil end
        for index = #values, 1, -1 do values[index] = nil end
        for index = #controls, 1, -1 do controls[index] = nil end
        tickerScratch.widths[rowIndex] = 0
    end
end

local function HideTicker()
    ClearTickerScratch()
    if tickerControl then
        tickerControl:SetHidden(true)
    end
end

local function GetCurrentSceneName()
    if not SCENE_MANAGER then
        return nil
    end

    if SCENE_MANAGER.GetCurrentSceneName then
        return SCENE_MANAGER:GetCurrentSceneName()
    end

    if SCENE_MANAGER.GetCurrentScene then
        local scene = SCENE_MANAGER:GetCurrentScene()
        if scene and scene.GetName then
            return scene:GetName()
        end
    end

    return nil
end

local function IsGameplaySceneShowing()
    if not SCENE_MANAGER then
        return true
    end

    return GAMEPLAY_SCENES[GetCurrentSceneName()] == true
end

local function ShouldShowForCurrentScene()
    if IsGameplaySceneShowing() then
        return true
    end

    return settingsPanelVisible and GetSettings().showInSettings == true
end

local function ResolveIcon(definition)
    if type(definition.icon) == "function" then
        return definition.icon()
    end
    return definition.icon
end

local function ResolveFont()
    local settings = GetSettings()
    local key = tostring(settings.font) .. ":" .. tostring(settings.fontSize)
    if not fontStringCache[key] then
        fontStringCache[key] = NQOL.Util.CreateFontString(settings.font, settings.fontSize, "ZoFontGamepad34")
    end

    return fontStringCache[key]
end

local function SetTextureDesaturation(texture, desaturation)
    if texture and texture.SetDesaturation then
        texture:SetDesaturation(desaturation)
    end
end

local function ApplyIconStyle(control, definition)
    local settings = GetSettings()
    local color = settings.coloredIcons and ICON_COLORS[definition.key] or nil

    if definition.iconText then
        SetTextureDesaturation(control.icon, 0)
        if color then
            control.icon:SetColor(color[1], color[2], color[3], 0.38)
            control.iconLabel:SetColor(1, 1, 1, 0.95)
        else
            control.icon:SetColor(1, 1, 1, 0.22)
            control.iconLabel:SetColor(1, 1, 1, 0.95)
        end
        return
    end

    if color then
        SetTextureDesaturation(control.icon, 0)
        control.icon:SetColor(color[1], color[2], color[3], color[4] or 1)
    else
        SetTextureDesaturation(control.icon, 1)
        control.icon:SetColor(1, 1, 1, 1)
    end
end

local function GetRowHeight()
    local settings = GetSettings()
    return math.max(ROW_MIN_HEIGHT, (tonumber(settings.fontSize) or DEFAULT_FONT_SIZE) + 8, ICON_SIZE + 8)
end

local function GetTickerHeight()
    return (GetRowHeight() * 3) + (ROW_GAP * 2)
end

local function ApplyBackgroundOpacity()
    if tickerBackground then
        tickerBackground:SetCenterColor(0, 0, 0, GetSettings().backgroundOpacity / 100)
        tickerBackground:SetEdgeColor(0, 0, 0, 0)
    end
end

local function GetTextMeasureLabel()
    if measuringLabel or not WINDOW_MANAGER or not tickerControl then
        return measuringLabel
    end

    measuringLabel = WINDOW_MANAGER:CreateControl(nil, tickerControl, CT_LABEL)
    measuringLabel:SetAlpha(0)
    measuringLabel:SetAnchor(TOPLEFT, tickerControl, TOPLEFT, -4096, -4096)
    measuringLabel:SetDimensions(4096, ROW_MIN_HEIGHT)
    measuringLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    measuringLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    return measuringLabel
end

local function GetEntryTextWidth(value, font, rowHeight)
    local label = GetTextMeasureLabel()
    if label then
        label:SetFont(font)
        label:SetText(value)
        label:SetDimensions(4096, rowHeight)

        local width = label.GetTextDimensions and label:GetTextDimensions() or 0
        if width and width > 0 then
            return width
        end

        width = label.GetTextWidth and label:GetTextWidth() or 0
        if width and width > 0 then
            return width
        end
    end

    return 0
end

local function EnsureControls()
    if tickerControl or not WINDOW_MANAGER or not GuiRoot then
        return
    end

    tickerControl = NQOLTicker
    if not tickerControl and WINDOW_MANAGER.CreateTopLevelWindow then
        tickerControl = WINDOW_MANAGER:CreateTopLevelWindow("NQOLTicker")
    end
    if not tickerControl then
        return
    end

    tickerControl:SetDimensions(TICKER_INITIAL_WIDTH, GetTickerHeight())
    tickerControl:SetHidden(true)
    MoveControlAbove(tickerControl, DRAW_LEVEL)

    tickerBackground = WINDOW_MANAGER:CreateControl(nil, tickerControl, CT_BACKDROP)
    tickerBackground:SetCenterColor(0, 0, 0, GetSettings().backgroundOpacity / 100)
    tickerBackground:SetEdgeColor(0, 0, 0, 0)
    tickerBackground:SetAnchorFill(tickerControl)
    tickerBackground:SetDrawLevel(DRAW_LEVEL)

    for rowIndex = 1, 3 do
        local row = WINDOW_MANAGER:CreateControl(nil, tickerControl, CT_CONTROL)
        row:SetDimensions(TICKER_INITIAL_WIDTH, GetRowHeight())
        row:SetAnchor(TOP, tickerControl, TOP, 0, (rowIndex - 1) * (GetRowHeight() + ROW_GAP))
        MoveControlAbove(row, DRAW_LEVEL + 1)
        rowControls[rowIndex] = row

        if rowIndex < 3 then
            local divider = WINDOW_MANAGER:CreateControl(nil, tickerControl, CT_TEXTURE)
            divider:SetTexture(TEXTURE_WHITE)
            divider:SetColor(1, 1, 1, 0.22)
            divider:SetDimensions(TICKER_INITIAL_WIDTH - 40, 1)
            divider:SetAnchor(TOP, row, BOTTOM, 0, 0)
            MoveControlAbove(divider, DRAW_LEVEL + 2)
            dividerControls[rowIndex] = divider
        end
    end
end

local function ApplyTickerSize(width)
    if not tickerControl then
        return
    end

    width = math.max(tonumber(width) or TICKER_MIN_WIDTH, TICKER_MIN_WIDTH)
    local rowHeight = GetRowHeight()
    tickerControl:SetDimensions(width, GetTickerHeight())

    for rowIndex = 1, 3 do
        if rowControls[rowIndex] then
            rowControls[rowIndex]:ClearAnchors()
            rowControls[rowIndex]:SetDimensions(width, rowHeight)
            rowControls[rowIndex]:SetAnchor(TOP, tickerControl, TOP, 0, (rowIndex - 1) * (rowHeight + ROW_GAP))
        end
    end

    for dividerIndex = 1, 2 do
        if dividerControls[dividerIndex] then
            dividerControls[dividerIndex]:SetDimensions(math.max(width - 40, 1), 1)
        end
    end
end

local function ApplyPosition()
    if not tickerControl then
        return
    end

    local settings = GetSettings()
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local x = (screenWidth - tickerControl:GetWidth() - (INSET_X * 2)) * (settings.horizontalPosition / 100) + INSET_X
    local y = (screenHeight - tickerControl:GetHeight() - (INSET_Y * 2)) * (settings.verticalPosition / 100) + INSET_Y

    tickerControl:ClearAnchors()
    tickerControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

local function GetEntryControl(definition)
    local control = entryControls[definition.key]
    if control then
        return control
    end

    control = WINDOW_MANAGER:CreateControl(nil, tickerControl, CT_CONTROL)
    control:SetDimensions(120, GetRowHeight())

    control.icon = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    control.icon:SetDimensions(ICON_SIZE, ICON_SIZE)
    control.icon:SetAnchor(CENTER, control, LEFT, ICON_SIZE / 2, 0)
    MoveControlAbove(control.icon, DRAW_LEVEL + 4)

    control.iconLabel = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    control.iconLabel:SetDimensions(ICON_SIZE + 8, ICON_SIZE)
    control.iconLabel:SetAnchor(CENTER, control.icon, CENTER, 0, 0)
    control.iconLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    control.iconLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    control.iconLabel:SetFont("ZoFontGamepad18")
    control.iconLabel:SetColor(1, 1, 1, 0.95)
    MoveControlAbove(control.iconLabel, DRAW_LEVEL + 5)

    control.label = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    control.label:SetAnchor(LEFT, control.icon, RIGHT, TEXT_GAP, 0)
    control.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    control.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    if control.label.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then
        control.label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end
    control.label:SetFont(ResolveFont())
    control.label:SetColor(1, 1, 1, 0.95)
    MoveControlAbove(control.label, DRAW_LEVEL + 4)

    MoveControlAbove(control, DRAW_LEVEL + 3)

    entryControls[definition.key] = control
    return control
end

local function ClearRows()
    for _, control in pairs(entryControls) do
        control:SetHidden(true)
        control:ClearAnchors()
    end
end

local function AddEntryToRow(rowName, definition, value)
    local rowIndex = rowName == ROW_1 and 1 or rowName == ROW_2 and 2 or rowName == ROW_3 and 3 or nil
    if not rowIndex then
        return
    end

    local definitions = tickerScratch.definitions[rowIndex]
    local entryIndex = #definitions + 1
    definitions[entryIndex] = definition
    tickerScratch.values[rowIndex][entryIndex] = value
end

local Refresh, UpdateUpdateLoop

local function CompleteQueuedSceneUpdate()
    sceneUpdateQueued = false
    UpdateUpdateLoop()
end

local function QueueSceneUpdate()
    if sceneUpdateQueued then return end
    if zo_callLater then
        sceneUpdateQueued = true
        zo_callLater(CompleteQueuedSceneUpdate, 0)
    else
        UpdateUpdateLoop()
    end
end

local function InstallSceneCallback()
    if sceneCallbackInstalled or not SCENE_MANAGER or not SCENE_MANAGER.RegisterCallback then
        return
    end

    sceneCallbackInstalled = true
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, _, newState)
        local isShowing = newState == SCENE_SHOWING or newState == SCENE_SHOWN
        local isHiding = newState == SCENE_HIDING or newState == SCENE_HIDDEN
        if isHiding then HideTicker() end
        if isShowing or isHiding then QueueSceneUpdate() end
    end)
end

local function QueueRefreshRetry()
    if refreshRetryQueued or not zo_callLater then
        return
    end

    refreshRetryQueued = true
    zo_callLater(function()
        refreshRetryQueued = false
        Refresh()
    end, 0)
end

local function RegisterInventoryEvents()
    if inventoryEventRegistered or not EVENT_MANAGER or not EVENT_INVENTORY_SINGLE_SLOT_UPDATE then
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_SoulGems", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId)
        if bagId == BAG_BACKPACK then
            soulGemCacheDirty = true
        end
    end)
    if EVENT_MANAGER.AddFilterForEvent and REGISTER_FILTER_BAG_ID then
        EVENT_MANAGER:AddFilterForEvent(
            EVENT_NAMESPACE .. "_SoulGems",
            EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
            REGISTER_FILTER_BAG_ID,
            BAG_BACKPACK
        )
    end

    inventoryEventRegistered = true
end

local function UnregisterInventoryEvents()
    if not inventoryEventRegistered or not EVENT_MANAGER or not EVENT_INVENTORY_SINGLE_SLOT_UPDATE then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_SoulGems", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    inventoryEventRegistered = false
end

Refresh = function()
    vampireTimerCached = false
    vampireTimerValue = nil
    vampireTimerIcon = nil

    EnsureControls()
    if not tickerControl then
        return
    end

    if not ShouldShowForCurrentScene() then
        HideTicker()
        return
    end

    ClearRows()
    ClearTickerScratch()

    local settings = GetSettings()
    local rows = tickerScratch.definitions
    local rowValues = tickerScratch.values

    for _, definition in ipairs(entryDefinitions) do
        local rowName = settings.entries[definition.key]
        if rowName ~= ROW_OFF then
            local value = definition.getValue()
            if value and value ~= "" then
                AddEntryToRow(rowName, definition, value)
            end
        end
    end

    local visibleRows = 0
    for rowIndex = 1, 3 do
        visibleRows = #rows[rowIndex] > 0 and visibleRows + 1 or visibleRows
    end

    if visibleRows == 0 then
        HideTicker()
        return
    end

    local widestRow = 0
    local font = ResolveFont()
    local rowHeight = GetRowHeight()
    for rowIndex = 1, 3 do
        local row = rowControls[rowIndex]
        local entries = rows[rowIndex]
        row:SetHidden(#entries == 0)

        if #entries > 0 then
            local totalWidth = 0
            local controls = tickerScratch.controls[rowIndex]
            local values = rowValues[rowIndex]
            local needsRetry = false
            for entryIndex, definition in ipairs(entries) do
                local value = values[entryIndex]
                local control = GetEntryControl(definition)
                local icon = ResolveIcon(definition)
                local hideIcon = not definition.iconText and definition.hideIconWhenMissing == true and not icon
                if definition.iconText then
                    control.icon:SetTexture(TEXTURE_WHITE)
                    control.iconLabel:SetText(definition.iconText)
                    control.iconLabel:SetHidden(false)
                    control.icon:SetHidden(false)
                    control.label:ClearAnchors()
                    control.label:SetAnchor(LEFT, control.icon, RIGHT, TEXT_GAP, 0)
                elseif hideIcon then
                    control.icon:SetHidden(true)
                    control.iconLabel:SetHidden(true)
                    control.label:ClearAnchors()
                    control.label:SetAnchor(LEFT, control, LEFT, 0, 0)
                else
                    control.icon:SetTexture(icon or TEXTURE_WHITE)
                    control.icon:SetHidden(false)
                    control.iconLabel:SetHidden(true)
                    control.label:ClearAnchors()
                    control.label:SetAnchor(LEFT, control.icon, RIGHT, TEXT_GAP, 0)
                end
                if not hideIcon then
                    ApplyIconStyle(control, definition)
                end
                control.label:SetFont(font)
                control.label:SetText(value)

                local textWidth = GetEntryTextWidth(value, font, rowHeight)
                if textWidth <= 0 then
                    needsRetry = true
                    textWidth = control.label:GetWidth() or 0
                end
                local width = hideIcon and textWidth or ICON_SIZE + TEXT_GAP + textWidth
                control:SetDimensions(width, rowHeight)
                control.label:SetDimensions(textWidth, rowHeight)
                totalWidth = totalWidth + width
                controls[#controls + 1] = control
            end
            if needsRetry then
                QueueRefreshRetry()
            end
            totalWidth = totalWidth + (math.max(#controls - 1, 0) * ENTRY_GAP)
            widestRow = math.max(widestRow, totalWidth)
            tickerScratch.widths[rowIndex] = totalWidth
        end
    end

    ApplyTickerSize(widestRow + (TICKER_HORIZONTAL_PADDING * 2))
    ApplyBackgroundOpacity()
    ApplyPosition()
    tickerControl:SetHidden(false)

    for rowIndex = 1, 3 do
        local totalWidth = tickerScratch.widths[rowIndex]
        if #tickerScratch.definitions[rowIndex] > 0 then
            local row = rowControls[rowIndex]
            local controls = tickerScratch.controls[rowIndex]

            local left = TICKER_HORIZONTAL_PADDING
            if settings.alignment == ALIGNMENT_RIGHT then
                left = row:GetWidth() - totalWidth - TICKER_HORIZONTAL_PADDING
            elseif settings.alignment == ALIGNMENT_CENTER then
                left = (row:GetWidth() - totalWidth) / 2
            end
            for _, control in ipairs(controls) do
                control:ClearAnchors()
                control:SetAnchor(LEFT, row, LEFT, left, 0)
                control:SetHidden(false)
                left = left + control:GetWidth() + ENTRY_GAP
            end
        end
    end

    for dividerIndex = 1, 2 do
        local showDivider = false
        for before = 1, dividerIndex do
            if #rows[before] > 0 then
                for after = dividerIndex + 1, 3 do
                    if #rows[after] > 0 then
                        showDivider = true
                        break
                    end
                end
            end
            if showDivider then
                break
            end
        end
        dividerControls[dividerIndex]:SetHidden(not showDivider)
    end
end

UpdateUpdateLoop = function()
    if not EVENT_MANAGER then
        return
    end

    local settings = GetSettings()
    local hasEnabledEntry = HasEnabledEntry()
    local shouldRun = hasEnabledEntry and (
        (settings.enabled == true and IsGameplaySceneShowing())
        or (settingsPanelVisible and settings.showInSettings == true)
    )

    if shouldRun ~= updateLoopRunning then
        EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)
        updateLoopRunning = false
    end

    if shouldRun and not updateLoopRunning then
        EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE, UPDATE_INTERVAL_MS, Refresh)
        updateLoopRunning = true
    end

    if shouldRun then
        InstallSceneCallback()
        Refresh()
    else
        HideTicker()
    end
end

function Ticker.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function Ticker.Initialize()
    local settings = GetSettings()
    if initialized then
        if settings.enabled == true then
            RegisterInventoryEvents()
        end
        UpdateUpdateLoop()
        return
    end

    if settings.enabled ~= true and not (settingsPanelVisible and settings.showInSettings == true) then
        return
    end

    initialized = true
    EnsureControls()
    InstallSceneCallback()
    if settings.enabled == true then
        RegisterInventoryEvents()
    end
    UpdateUpdateLoop()
end

function Ticker.GetEntries()
    return entryDefinitions
end

function Ticker.GetRowChoices()
    return ROW_CHOICES
end

function Ticker.GetRowChoiceNames()
    return ROW_CHOICE_NAMES
end

function Ticker.GetAlignmentChoices()
    return ALIGNMENT_CHOICES
end

function Ticker.GetAlignmentChoiceNames()
    return ALIGNMENT_CHOICE_NAMES
end

function Ticker.GetFontChoices()
    return NQOL.Util.GetFontChoices()
end

function Ticker.GetFontChoiceNames()
    return NQOL.Util.GetFontChoiceNames()
end

function Ticker.GetEntryRow(entryKey)
    local definition = entryByKey[entryKey]
    if not definition then
        return ROW_OFF
    end

    return GetSettings().entries[entryKey] or ROW_OFF
end

function Ticker.GetEnabled()
    return GetSettings().enabled
end

function Ticker.GetEnabledDefault()
    return defaults.ticker.enabled
end

function Ticker.SetEnabled(value)
    GetSettings().enabled = value == true

    if GetSettings().enabled == true then
        Ticker.Initialize()
        RegisterInventoryEvents()
        UpdateUpdateLoop()
    else
        UnregisterInventoryEvents()
        if settingsPanelVisible and GetSettings().showInSettings == true then
            Ticker.Initialize()
        end
        if initialized then UpdateUpdateLoop() else HideTicker() end
    end
end

function Ticker.SetEntryRow(entryKey, value)
    local definition = entryByKey[entryKey]
    if not definition then
        return
    end

    if not VALID_ROWS[value] then
        value = ROW_OFF
    end

    GetSettings().entries[entryKey] = value
    UpdateUpdateLoop()
end

function Ticker.GetHorizontalPosition()
    return GetSettings().horizontalPosition
end

function Ticker.SetHorizontalPosition(value)
    GetSettings().horizontalPosition = Clamp(value, 0, 100)
    ApplyPosition()
end

function Ticker.GetVerticalPosition()
    return GetSettings().verticalPosition
end

function Ticker.SetVerticalPosition(value)
    GetSettings().verticalPosition = Clamp(value, 0, 100)
    ApplyPosition()
end

function Ticker.GetAlignment()
    return GetSettings().alignment
end

function Ticker.SetAlignment(value)
    GetSettings().alignment = VALID_ALIGNMENTS[value] and value or ALIGNMENT_CENTER
    Refresh()
end

function Ticker.GetFont()
    return GetSettings().font
end

function Ticker.SetFont(value)
    if not NQOL.Util.IsFontChoice(value) then
        value = NQOL.Util.GetDefaultFont()
    end

    GetSettings().font = value
    Refresh()
end

function Ticker.GetFontSize()
    return GetSettings().fontSize
end

function Ticker.SetFontSize(value)
    GetSettings().fontSize = Clamp(Round(value), FONT_SIZE_MIN, FONT_SIZE_MAX)
    Refresh()
end

function Ticker.GetBackgroundOpacity()
    return GetSettings().backgroundOpacity
end

function Ticker.SetBackgroundOpacity(value)
    GetSettings().backgroundOpacity = Clamp(Round(value), BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX)
    Refresh()
end

function Ticker.GetBackgroundOpacityMin()
    return BACKGROUND_OPACITY_MIN
end

function Ticker.GetBackgroundOpacityMax()
    return BACKGROUND_OPACITY_MAX
end

function Ticker.GetShowInSettings()
    return GetSettings().showInSettings
end

function Ticker.GetShowInSettingsDefault()
    return defaults.ticker.showInSettings
end

function Ticker.SetShowInSettings(value)
    GetSettings().showInSettings = value == true
    if settingsPanelVisible and GetSettings().showInSettings == true then
        Ticker.Initialize()
    end
    if initialized then UpdateUpdateLoop() else HideTicker() end
end

function Ticker.GetColoredIcons()
    return GetSettings().coloredIcons
end

function Ticker.GetColoredIconsDefault()
    return defaults.ticker.coloredIcons
end

function Ticker.SetColoredIcons(value)
    GetSettings().coloredIcons = value == true
    Refresh()
end

function Ticker.SetSettingsPanelVisible(value)
    settingsPanelVisible = value == true
    if settingsPanelVisible and GetSettings().showInSettings == true then
        Ticker.Initialize()
    end
    if initialized then UpdateUpdateLoop() else HideTicker() end
end

function Ticker.GetEnabledLabel()
    return NQOL.L("features.ticker.enabled_label")
end

function Ticker.GetEnabledTooltip()
    return NQOL.L("features.ticker.enabled_tooltip")
end

function Ticker.GetFontLabel()
    return NQOL.L("features.ticker.font_label")
end

function Ticker.GetFontTooltip()
    return NQOL.L("features.ticker.font_tooltip")
end

function Ticker.GetFontSizeLabel()
    return NQOL.L("features.ticker.font_size_label")
end

function Ticker.GetFontSizeTooltip()
    return NQOL.L("features.ticker.font_size_tooltip")
end

function Ticker.GetShowInSettingsLabel()
    return NQOL.L("features.ticker.show_in_settings_label")
end

function Ticker.GetShowInSettingsTooltip()
    return NQOL.L("features.ticker.show_in_settings_tooltip")
end

function Ticker.GetColoredIconsLabel()
    return NQOL.L("features.ticker.colored_icons_label")
end

function Ticker.GetColoredIconsTooltip()
    return NQOL.L("features.ticker.colored_icons_tooltip")
end

function Ticker.GetBackgroundOpacityLabel()
    return NQOL.L("features.ticker.background_opacity_label")
end

function Ticker.GetBackgroundOpacityTooltip()
    return NQOL.L("features.ticker.background_opacity_tooltip")
end

function Ticker.GetAlignmentLabel()
    return NQOL.L("features.ticker.alignment_label")
end

function Ticker.GetAlignmentTooltip()
    return NQOL.L("features.ticker.alignment_tooltip")
end

function Ticker.GetFontSizeMin()
    return FONT_SIZE_MIN
end

function Ticker.GetFontSizeMax()
    return FONT_SIZE_MAX
end

function Ticker.GetHorizontalPositionLabel()
    return NQOL.L("features.ticker.horizontal_position_label")
end

function Ticker.GetHorizontalPositionTooltip()
    return NQOL.L("features.ticker.horizontal_position_tooltip")
end

function Ticker.GetVerticalPositionLabel()
    return NQOL.L("features.ticker.vertical_position_label")
end

function Ticker.GetVerticalPositionTooltip()
    return NQOL.L("features.ticker.vertical_position_tooltip")
end

NQOL.Features.Ticker = Ticker
