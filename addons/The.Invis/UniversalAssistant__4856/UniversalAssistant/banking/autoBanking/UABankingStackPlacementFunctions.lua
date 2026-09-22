local ua = UAssistant
local banking = ua.Banking
local autoBanking = banking.AutoBanking
local craftingItems = autoBanking.CraftingItems

autoBanking.StackPlacement = autoBanking.StackPlacement or {}
local stackPlacement = autoBanking.StackPlacement

local MODE_NONE = "none"
local MODE_BANK = "bank"
local MODE_GUILD = "guild"
local MODE_HOUSE = "house"
local FULL_STACK_SIZE = 200
local MIN_BANK_STACKS = 1
local MAX_BANK_STACKS = 10
local RULE_ID = "crafting:fullStackPlacement"

local MODE_REFERENCE = "UABankingCraftingStackPlacementMode"
local COUNT_SLIDER_REFERENCE = "UABankingCraftingBankStackCountSlider"
local GUILD_REFERENCE = "UABankingCraftingStackPlacementGuild"
local HOUSE_REFERENCE = "UABankingCraftingStackPlacementHouse"

local function L(key)
    return ua.GetString("BANKING_" .. key)
end

local function RefreshControl(reference, updateValue)
    local control = _G[reference]

    if not control then
        return
    end

    if control.UpdateDisabled then
        control:UpdateDisabled()
    end

    if updateValue and control.UpdateValue then
        control:UpdateValue()
    end
end

local function RefreshDependentControls()
    RefreshControl(COUNT_SLIDER_REFERENCE, true)
    RefreshControl(GUILD_REFERENCE, true)
    RefreshControl(HOUSE_REFERENCE, true)
end

function stackPlacement.RefreshControls()
    RefreshControl(MODE_REFERENCE, true)
    RefreshDependentControls()
end

local function IsValidPlacementMode(mode)
    return mode == MODE_NONE or mode == MODE_BANK or mode == MODE_GUILD or mode == MODE_HOUSE
end

function stackPlacement.GetSettings()
    local settings = craftingItems.GetSettings()

    if type(settings.stackPlacement) ~= "table" then
        settings.stackPlacement = {}
    end

    local profile = settings.stackPlacement

    if not IsValidPlacementMode(profile.mode) then
        profile.mode = MODE_NONE
    end

    profile.bankStackCount =
        zo_clamp(zo_floor(tonumber(profile.bankStackCount) or 1), MIN_BANK_STACKS, MAX_BANK_STACKS)
    profile.guildId = zo_floor(tonumber(profile.guildId) or 0)
    profile.houseBankBagId = zo_floor(tonumber(profile.houseBankBagId) or 0)

    return profile
end

local function HasConfiguredDestination(profile)
    if profile.mode == MODE_GUILD then
        return profile.guildId > 0
    end

    if profile.mode == MODE_HOUSE then
        return profile.houseBankBagId > 0
    end

    return profile.mode == MODE_BANK
end

function stackPlacement.IsActive()
    local profile = stackPlacement.GetSettings()

    return craftingItems.IsEnabled()
        and profile.mode ~= MODE_NONE
        and HasConfiguredDestination(profile)
end

function stackPlacement.ShouldForcePersonalBankDeposit()
    return autoBanking.interactionKind == "personal" and stackPlacement.IsActive()
end

function stackPlacement.CanDepositToGuild(guildId)
    local profile = stackPlacement.GetSettings()

    if
        not craftingItems.IsEnabled()
        or profile.mode ~= MODE_GUILD
        or profile.guildId ~= guildId
    then
        return false
    end

    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_DEPOSIT) then
        return false
    end

    return not DoesGuildHavePrivilege
        or DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_BANK_DEPOSIT)
end

function stackPlacement.IsSelectedHouseBank(bagId)
    local profile = stackPlacement.GetSettings()

    return craftingItems.IsEnabled()
        and profile.mode == MODE_HOUSE
        and profile.houseBankBagId == bagId
end

local function IsFullCraftingStack(itemLink, bagId, slotIndex)
    if not craftingItems.MatchesItemLink(itemLink) then
        return false
    end

    local count, maximum = GetSlotStackSize(bagId, slotIndex)

    return maximum == FULL_STACK_SIZE and count == FULL_STACK_SIZE
end

local function GetRuleMode()
    if not stackPlacement.IsActive() then
        return autoBanking.MODE_NONE
    end

    local profile = stackPlacement.GetSettings()

    if autoBanking.interactionKind == "personal" and autoBanking.stackPlacementPhase then
        return autoBanking.MODE_WITHDRAW
    end

    if
        autoBanking.interactionKind == "guild"
        and stackPlacement.CanDepositToGuild(autoBanking.guildBankId)
    then
        return autoBanking.MODE_DEPOSIT
    end

    if
        autoBanking.interactionKind == "house"
        and stackPlacement.IsSelectedHouseBank(autoBanking.bankBagId)
    then
        return autoBanking.MODE_DEPOSIT
    end

    return autoBanking.MODE_NONE
end

function stackPlacement.Initialize()
    stackPlacement.GetSettings()

    autoBanking.RegisterRule(RULE_ID, GetRuleMode, IsFullCraftingStack)
end

local function GetStackKey(itemLink)
    return string.gsub(itemLink, "^|H%d+:", "|H1:")
end

function stackPlacement.CollectPersonalCandidates()
    if not stackPlacement.IsActive() then
        return {}
    end

    local profile = stackPlacement.GetSettings()
    local keepCount = profile.mode == MODE_BANK and profile.bankStackCount or 0
    local keptByItem = {}
    local candidates = {}
    local bags = { BAG_BANK }

    if IsESOPlusSubscriber() then
        table.insert(bags, BAG_SUBSCRIBER_BANK)
    end

    for _, bagId in ipairs(bags) do
        for slotIndex = 0, GetBagSize(bagId) - 1 do
            local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)

            if itemLink and itemLink ~= "" and IsFullCraftingStack(itemLink, bagId, slotIndex) then
                local key = GetStackKey(itemLink)
                local kept = keptByItem[key] or 0

                if kept < keepCount then
                    keptByItem[key] = kept + 1
                else
                    table.insert(candidates, {
                        bagId = bagId,
                        slotIndex = slotIndex,
                        mode = autoBanking.MODE_WITHDRAW,
                        ruleId = RULE_ID,
                        itemLink = itemLink,
                        targetBags = { BAG_BACKPACK },
                    })
                end
            end
        end
    end

    return candidates
end

local function GetHouseBankName(bagId)
    local collectibleId = GetCollectibleForBag and GetCollectibleForBag(bagId)
    local name

    if collectibleId and collectibleId > 0 then
        name = GetCollectibleNickname(collectibleId)

        if not name or name == "" then
            name = GetCollectibleName(collectibleId)
        end
    end

    if not name or name == "" then
        name = string.format(L("HOUSE_STORAGE_NUMBER"), bagId - BAG_HOUSE_BANK_ONE + 1)
    end

    return zo_strformat("<<C:1>>", name)
end

function stackPlacement.CollectDestinationCandidates(destinationKind, destinationBag)
    local profile = stackPlacement.GetSettings()

    if
        not stackPlacement.IsActive()
        or (destinationKind == "guild" and profile.mode ~= MODE_GUILD)
        or (destinationKind == "house" and profile.mode ~= MODE_HOUSE)
    then
        return {}
    end

    local candidates = {}
    local destinationId
    local destinationName

    if destinationKind == "guild" then
        destinationId = profile.guildId
        destinationName = GetGuildName(profile.guildId)

        if not destinationName or destinationName == "" then
            destinationName = L("TARGET_GUILD_BANK")
        end
    else
        destinationId = destinationBag
        destinationName = GetHouseBankName(destinationBag)
    end

    for slotIndex = 0, GetBagSize(BAG_BACKPACK) - 1 do
        local itemLink = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT)

        if
            itemLink
            and itemLink ~= ""
            and IsFullCraftingStack(itemLink, BAG_BACKPACK, slotIndex)
        then
            table.insert(candidates, {
                bagId = BAG_BACKPACK,
                slotIndex = slotIndex,
                mode = autoBanking.MODE_DEPOSIT,
                ruleId = RULE_ID,
                itemLink = itemLink,
                targetBags = { destinationBag },
                destinationKind = destinationKind,
                destinationId = destinationId,
                destinationName = destinationName,
            })
        end
    end

    return candidates
end

local function SetBankStackCount(value)
    local profile = stackPlacement.GetSettings()
    profile.bankStackCount = zo_clamp(
        zo_floor(tonumber(value) or profile.bankStackCount),
        MIN_BANK_STACKS,
        MAX_BANK_STACKS
    )
end

local function GetGuildChoices()
    local names = { L("SELECT_GUILD_BANK") }
    local values = { 0 }

    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        local name = GetGuildName(guildId)

        if name and name ~= "" then
            table.insert(names, zo_strformat("<<C:1>>", name))
            table.insert(values, guildId)
        end
    end

    return names, values
end

local function GetHouseBankChoices()
    local names = { L("SELECT_HOUSE_STORAGE") }
    local values = { 0 }

    for bagId = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
        local collectibleId = GetCollectibleForBag and GetCollectibleForBag(bagId)

        if collectibleId and collectibleId > 0 and IsCollectibleUnlocked(collectibleId) then
            table.insert(names, GetHouseBankName(bagId))
            table.insert(values, bagId)
        end
    end

    return names, values
end

function stackPlacement.CreateMenuControls()
    local profile = stackPlacement.GetSettings()
    local guildNames, guildValues = GetGuildChoices()
    local houseNames, houseValues = GetHouseBankChoices()

    return {
        { type = "divider" },
        {
            type = "dropdown",
            name = L("STACK_PLACEMENT_RULES"),
            tooltip = L("STACK_PLACEMENT_RULES_TOOLTIP"),
            choices = {
                L("STACK_PLACEMENT_NONE"),
                L("STACK_PLACEMENT_BANK"),
                L("STACK_PLACEMENT_GUILD"),
                L("STACK_PLACEMENT_HOUSE"),
            },
            choicesValues = {
                MODE_NONE,
                MODE_BANK,
                MODE_GUILD,
                MODE_HOUSE,
            },
            getFunc = function()
                return profile.mode
            end,
            setFunc = function(value)
                profile.mode = value
                RefreshDependentControls()
            end,
            disabled = function()
                return not craftingItems.IsEnabled()
            end,
            default = MODE_NONE,
            reference = MODE_REFERENCE,
        },
        {
            type = "slider",
            name = L("BANK_FULL_STACK_COUNT"),
            tooltip = L("BANK_FULL_STACK_COUNT_TOOLTIP"),
            min = MIN_BANK_STACKS,
            max = MAX_BANK_STACKS,
            step = 1,
            decimals = 0,
            getFunc = function()
                return profile.bankStackCount
            end,
            setFunc = function(value)
                SetBankStackCount(value)
            end,
            disabled = function()
                return not craftingItems.IsEnabled() or profile.mode ~= MODE_BANK
            end,
            default = 1,
            reference = COUNT_SLIDER_REFERENCE,
        },
        {
            type = "dropdown",
            name = L("TARGET_GUILD_BANK"),
            tooltip = L("TARGET_GUILD_BANK_TOOLTIP"),
            choices = guildNames,
            choicesValues = guildValues,
            getFunc = function()
                return profile.guildId
            end,
            setFunc = function(value)
                profile.guildId = tonumber(value) or 0
            end,
            disabled = function()
                return not craftingItems.IsEnabled() or profile.mode ~= MODE_GUILD
            end,
            default = 0,
            reference = GUILD_REFERENCE,
        },
        {
            type = "dropdown",
            name = L("TARGET_HOUSE_STORAGE"),
            tooltip = L("TARGET_HOUSE_STORAGE_TOOLTIP"),
            choices = houseNames,
            choicesValues = houseValues,
            getFunc = function()
                return profile.houseBankBagId
            end,
            setFunc = function(value)
                profile.houseBankBagId = tonumber(value) or 0
            end,
            disabled = function()
                return not craftingItems.IsEnabled() or profile.mode ~= MODE_HOUSE
            end,
            default = 0,
            reference = HOUSE_REFERENCE,
        },
    }
end
