----------------------------------------------------------------------
-- SmartGear -- Upgrade Alert System
-- Shows a notification when a better item is in your inventory
-- with a one-click EQUIP button.
----------------------------------------------------------------------
SmartGear = SmartGear or {}

local ALERT_DURATION = 12         -- seconds before auto-hide
local SCAN_DELAY = 1.5            -- seconds after inventory change
local MIN_SCORE_DIFF = 5          -- minimum score improvement to alert
local COMBAT_LOCKOUT = true       -- don't alert during combat

-- State
local alertQueue = {}             -- pending alerts
local isShowing = false
local currentAlert = nil          -- {bagId, slotIndex, wornSlot, itemLink, ...}
local scanPending = false
local hideTimerId = nil

----------------------------------------------------------------------
-- UI References (populated after XML loads)
----------------------------------------------------------------------
local frame, itemNameLabel, descLabel, scoreLabel, iconTexture
local equipBtn, dismissBtn

local function InitUI()
    frame         = SmartGearAlertFrame
    if not frame then return false end

    itemNameLabel = frame:GetNamedChild("ItemName")
    descLabel     = frame:GetNamedChild("Description")
    scoreLabel    = frame:GetNamedChild("Score")
    iconTexture   = frame:GetNamedChild("Icon")
    equipBtn      = frame:GetNamedChild("EquipBtn")
    dismissBtn    = frame:GetNamedChild("DismissBtn")

    if not equipBtn or not dismissBtn then return false end

    equipBtn:SetHandler("OnClicked", function()
        SmartGear.OnEquipClicked()
    end)

    dismissBtn:SetHandler("OnClicked", function()
        SmartGear.HideAlert()
    end)

    -- Tooltip on icon hover
    if iconTexture then
        iconTexture:SetHandler("OnMouseEnter", function()
            if currentAlert and currentAlert.itemLink then
                InitializeTooltip(ItemTooltip, iconTexture, RIGHT, -5)
                ItemTooltip:SetLink(currentAlert.itemLink)
            end
        end)
        iconTexture:SetHandler("OnMouseExit", function()
            ClearTooltip(ItemTooltip)
        end)
    end

    return true
end

----------------------------------------------------------------------
-- Show / Hide alert
----------------------------------------------------------------------
function SmartGear.ShowAlert(alertData)
    if not frame and not InitUI() then return end
    if not frame then return end

    currentAlert = alertData
    isShowing = true

    -- Set item info
    local lang = SmartGear.currentLang or "en"
    local itemName = GetItemLinkName(alertData.itemLink)
    itemName = zo_strformat("<<1>>", itemName)

    local quality = GetItemLinkQuality(alertData.itemLink)
    local qualityColor = GetItemQualityColor(quality)

    itemNameLabel:SetText(qualityColor:Colorize(itemName))

    -- Description: what it replaces
    local replaceText = ""
    if alertData.equippedName and alertData.equippedName ~= "" then
        replaceText = (lang == "ru" and "Замена: " or "Replaces: ") .. alertData.equippedName
    else
        replaceText = (lang == "ru" and "Пустой слот" or "Empty slot")
    end
    descLabel:SetText(replaceText)

    -- Score
    local diff = alertData.scoreDiff or 0
    local scoreText = ""
    if diff > 0 then
        scoreText = "|c00FF00^ +" .. diff .. " |r"
    end

    -- Add change details
    if alertData.changes then
        local details = {}
        for _, ch in ipairs(alertData.changes) do
            local txt = ""
            if ch.detail == "meta_vs_nonmeta" then
                txt = lang == "ru" and "Мета-сет!" or "Meta set!"
            elseif ch.detail == "higher_tier" then
                txt = lang == "ru" and "Выше тир" or "Higher tier"
            elseif ch.detail == "completes_set" then
                txt = lang == "ru" and "Замыкает сет!" or "Completes set!"
            elseif ch.detail == "better_trait" then
                txt = lang == "ru" and "Лучший трейт" or "Better trait"
            elseif ch.detail == "higher_level" then
                txt = lang == "ru" and "Выше уровень" or "Higher level"
            elseif ch.detail == "higher_quality" then
                txt = lang == "ru" and "Выше качество" or "Higher quality"
            end
            if txt ~= "" then
                table.insert(details, txt)
            end
        end
        if #details > 0 then
            scoreText = scoreText .. table.concat(details, ", ")
        end
    end
    scoreLabel:SetText(scoreText)

    -- Icon
    local icon = GetItemLinkIcon(alertData.itemLink)
    if icon and icon ~= "" then
        iconTexture:SetTexture(icon)
        iconTexture:SetHidden(false)
    else
        iconTexture:SetHidden(true)
    end

    -- Equip button text
    local btnLabel = equipBtn:GetNamedChild("Label")
    if btnLabel then
        btnLabel:SetText(lang == "ru" and "НАДЕТЬ" or "EQUIP")
    end

    -- Show
    frame:SetHidden(false)

    -- Auto-hide timer
    if hideTimerId then
        EVENT_MANAGER:UnregisterForUpdate(hideTimerId)
    end
    hideTimerId = SmartGear.name .. "AlertHide"
    EVENT_MANAGER:RegisterForUpdate(hideTimerId, ALERT_DURATION * 1000, function()
        SmartGear.HideAlert()
        EVENT_MANAGER:UnregisterForUpdate(hideTimerId)
    end)
end

function SmartGear.HideAlert()
    if frame then
        frame:SetHidden(true)
    end
    isShowing = false
    currentAlert = nil

    if hideTimerId then
        EVENT_MANAGER:UnregisterForUpdate(hideTimerId)
        hideTimerId = nil
    end

    -- Show next in queue
    if #alertQueue > 0 then
        local next = table.remove(alertQueue, 1)
        zo_callLater(function() SmartGear.ShowAlert(next) end, 500)
    end
end

----------------------------------------------------------------------
-- Equip button handler
----------------------------------------------------------------------
function SmartGear.OnEquipClicked()
    if not currentAlert then return end

    local bagId = currentAlert.bagId
    local slotIndex = currentAlert.slotIndex
    local wornSlot = currentAlert.wornSlot

    -- Verify item is still there
    local currentLink = GetItemLink(bagId, slotIndex)
    if currentLink ~= currentAlert.itemLink then
        local lang = SmartGear.currentLang or "en"
        d("|c00FF00[SmartGear]|r " .. (lang == "ru" and "Предмет перемещён или изменён." or "Item moved or changed, cannot equip."))
        SmartGear.HideAlert()
        return
    end

    -- Cannot equip in combat
    if IsUnitInCombat("player") then
        local lang = SmartGear.currentLang or "en"
        d("|c00FF00[SmartGear]|r " .. (lang == "ru" and "Нельзя надеть в бою!" or "Cannot equip during combat!"))
        return
    end

    -- Equip the item
    if wornSlot then
        EquipItem(bagId, slotIndex, wornSlot)
    else
        -- Let the game pick the slot
        EquipItem(bagId, slotIndex)
    end

    local lang = SmartGear.currentLang or "en"
    d("|c00FF00[SmartGear]|r " .. (lang == "ru" and "Надето: " or "Equipped: ") .. currentAlert.itemLink)
    SmartGear.HideAlert()
end

----------------------------------------------------------------------
-- Inventory scanner: find upgrades in bag
----------------------------------------------------------------------
local function ScanBagForUpgrades()
    if not SmartGear.savedVars or not SmartGear.savedVars.showAlerts then return end
    if COMBAT_LOCKOUT and IsUnitInCombat("player") then return end

    local bagId = BAG_BACKPACK
    local bagSlots = GetBagSize(bagId)
    local bestUpgrade = nil

    for slotIndex = 0, bagSlots - 1 do
        local itemLink = GetItemLink(bagId, slotIndex)
        if itemLink and itemLink ~= "" then
            local itemType = GetItemLinkItemType(itemLink)
            if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
                local comp = SmartGear.CompareWithEquipped(bagId, slotIndex)
                if comp and comp.isUpgrade and comp.scoreDiff >= MIN_SCORE_DIFF then
                    -- Only keep upgrades, not for items on cooldown
                    if not bestUpgrade or comp.scoreDiff > bestUpgrade.scoreDiff then
                        bestUpgrade = {
                            bagId = bagId,
                            slotIndex = slotIndex,
                            wornSlot = comp.wornSlot,
                            itemLink = itemLink,
                            equippedName = comp.equippedName,
                            equippedLink = comp.equippedLink,
                            scoreDiff = comp.scoreDiff,
                            slotLabel = comp.slotLabel,
                            changes = comp.changes,
                            verdict = comp.verdict,
                        }
                    end
                end
            end
        end
    end

    if bestUpgrade then
        if isShowing then
            -- Queue it if already showing an alert
            table.insert(alertQueue, bestUpgrade)
        else
            SmartGear.ShowAlert(bestUpgrade)
        end
    end
end

----------------------------------------------------------------------
-- Trigger scan on inventory changes
----------------------------------------------------------------------
local function OnInventoryUpdate(_, bagId, slotIndex, isNewItem)
    if bagId ~= BAG_BACKPACK then return end
    if not SmartGear.savedVars or not SmartGear.savedVars.showAlerts then return end

    -- Debounce: don't scan every single slot update
    if not scanPending then
        scanPending = true
        zo_callLater(function()
            scanPending = false
            ScanBagForUpgrades()
        end, SCAN_DELAY * 1000)
    end
end

----------------------------------------------------------------------
-- Initialize
----------------------------------------------------------------------
function SmartGear.InitUpgradeAlerts()
    -- Register for new items in backpack
    EVENT_MANAGER:RegisterForEvent(
        SmartGear.name .. "UpgradeAlert",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        OnInventoryUpdate
    )
    EVENT_MANAGER:AddFilterForEvent(
        SmartGear.name .. "UpgradeAlert",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID, BAG_BACKPACK
    )

    -- Register for weapon equip changes -> check swap
    EVENT_MANAGER:RegisterForEvent(
        SmartGear.name .. "WeaponSwapCheck",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function(_, bagId, slotIndex)
            if bagId ~= BAG_WORN then return end
            -- Only care about weapon slots
            if slotIndex == EQUIP_SLOT_MAIN_HAND
                or slotIndex == EQUIP_SLOT_OFF_HAND
                or slotIndex == EQUIP_SLOT_BACKUP_MAIN
                or slotIndex == EQUIP_SLOT_BACKUP_OFF
            then
                zo_callLater(function()
                    SmartGear.CheckWeaponSwaps()
                end, 1500)
            end
        end
    )
    EVENT_MANAGER:AddFilterForEvent(
        SmartGear.name .. "WeaponSwapCheck",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID, BAG_WORN
    )

    -- Also scan on loot received
    EVENT_MANAGER:RegisterForEvent(
        SmartGear.name .. "LootAlert",
        EVENT_LOOT_RECEIVED,
        function()
            if SmartGear.savedVars and SmartGear.savedVars.showAlerts then
                zo_callLater(ScanBagForUpgrades, 2000)
            end
        end
    )

    -- Scan once on load (after a short delay)
    zo_callLater(function()
        if SmartGear.savedVars and SmartGear.savedVars.showAlerts then
            ScanBagForUpgrades()
            -- Also check weapon placement on load
            zo_callLater(SmartGear.CheckWeaponSwaps, 1000)
        end
    end, 5000)
end

----------------------------------------------------------------------
-- Manual scan command
----------------------------------------------------------------------
function SmartGear.ScanUpgrades()
    ScanBagForUpgrades()
    if not isShowing then
        local lang = SmartGear.currentLang or "en"
        d("|c00FF00[SmartGear]|r " .. (lang == "ru" and "Улучшений не найдено." or "No upgrades found."))
    end
end

----------------------------------------------------------------------
-- Weapon Swap Suggestion
----------------------------------------------------------------------
local swapCooldown = false  -- prevent spam after swap

local function GetSwapReasonText(reasons, lang)
    local texts = {}
    for _, r in ipairs(reasons) do
        if r == "nirnhoned_to_main" then
            table.insert(texts, lang == "ru"
                and "Nirnhoned -> основная (100% скейлинг)"
                or  "Nirnhoned -> main hand (100% scaling)")
        elseif r == "high_dmg_to_offhand" then
            table.insert(texts, lang == "ru"
                and "Высокий урон -> левая (Эксперт ПО +3%)"
                or  "High dmg -> off-hand (DW Expert +3%)")
        elseif r == "dagger_to_main" then
            table.insert(texts, lang == "ru"
                and "Кинжал -> основная (низкий урон, трейт 100%)"
                or  "Dagger -> main hand (low base, trait 100%)")
        end
    end
    return table.concat(texts, ", ")
end

function SmartGear.ShowSwapAlert(swapData)
    if not frame and not InitUI() then return end
    if not frame then return end
    if swapCooldown then return end

    local lang = SmartGear.currentLang or "en"

    -- Store swap data in currentAlert with a swap flag
    currentAlert = {
        isSwap = true,
        bar = swapData.bar,
        mainSlot = swapData.mainSlot,
        offSlot = swapData.offSlot,
        mainLink = swapData.mainLink,
        offLink = swapData.offLink,
        scoreBenefit = swapData.scoreBenefit,
        reasons = swapData.reasons,
    }
    isShowing = true

    -- Item name: show both weapons
    local mainName = zo_strformat("<<1>>", GetItemLinkName(swapData.mainLink))
    local offName  = zo_strformat("<<1>>", GetItemLinkName(swapData.offLink))
    local mainQ = GetItemQualityColor(GetItemLinkQuality(swapData.mainLink))
    local offQ  = GetItemQualityColor(GetItemLinkQuality(swapData.offLink))

    itemNameLabel:SetText(mainQ:Colorize(mainName) .. " <-> " .. offQ:Colorize(offName))

    -- Description: reason
    local barText = swapData.bar == 2
        and (lang == "ru" and "Бар 2" or "Bar 2")
        or  (lang == "ru" and "Бар 1" or "Bar 1")
    local reasonText = GetSwapReasonText(swapData.reasons, lang)
    descLabel:SetText(barText .. ": " .. reasonText)

    -- Score
    local diff = swapData.scoreBenefit or 0
    scoreLabel:SetText("|c00FF00^ +" .. diff .. " |r"
        .. (lang == "ru" and "от перестановки" or "from swap"))

    -- Icon: show main-hand weapon icon
    local icon = GetItemLinkIcon(swapData.mainLink)
    if icon and icon ~= "" then
        iconTexture:SetTexture(icon)
        iconTexture:SetHidden(false)
    else
        iconTexture:SetHidden(true)
    end

    -- Button text: SWAP
    local btnLabel = equipBtn:GetNamedChild("Label")
    if btnLabel then
        btnLabel:SetText(lang == "ru" and "ПОМЕНЯТЬ" or "SWAP")
    end

    -- Override equip handler for swap mode
    equipBtn:SetHandler("OnClicked", function()
        SmartGear.OnSwapClicked()
    end)

    frame:SetHidden(false)

    -- Auto-hide
    if hideTimerId then
        EVENT_MANAGER:UnregisterForUpdate(hideTimerId)
    end
    hideTimerId = SmartGear.name .. "AlertHide"
    EVENT_MANAGER:RegisterForUpdate(hideTimerId, ALERT_DURATION * 1000, function()
        SmartGear.HideAlert()
        EVENT_MANAGER:UnregisterForUpdate(hideTimerId)
    end)
end

----------------------------------------------------------------------
-- Swap button handler: move weapons between main/off slots
----------------------------------------------------------------------
function SmartGear.OnSwapClicked()
    if not currentAlert or not currentAlert.isSwap then return end

    if IsUnitInCombat("player") then
        local lang = SmartGear.currentLang or "en"
        d("|c00FF00[SmartGear]|r " .. (lang == "ru"
            and "Нельзя менять оружие в бою!"
            or  "Cannot swap weapons in combat!"))
        return
    end

    local mainSlot = currentAlert.mainSlot
    local offSlot  = currentAlert.offSlot
    local mainLink = currentAlert.mainLink
    local offLink  = currentAlert.offLink

    -- Verify weapons are still in place
    local curMain = GetItemLink(BAG_WORN, mainSlot)
    local curOff  = GetItemLink(BAG_WORN, offSlot)
    if curMain ~= mainLink or curOff ~= offLink then
        local lang = SmartGear.currentLang or "en"
        d("|c00FF00[SmartGear]|r " .. (lang == "ru"
            and "Оружие изменилось, отмена."
            or  "Weapons changed, cancelled."))
        SmartGear.HideAlert()
        return
    end

    -- Prevent re-triggering during swap
    swapCooldown = true

    -- Swap via EquipItem (no protected calls needed):
    -- Step 1: Equip off-hand weapon to main-hand slot.
    --         The displaced main-hand weapon goes to BAG_BACKPACK automatically.
    -- Step 2: Find the displaced weapon in backpack and equip it to off-hand.

    EquipItem(BAG_WORN, offSlot, mainSlot)

    zo_callLater(function()
        -- Find the displaced main-hand weapon in backpack by matching link
        local foundSlot = nil
        for i = 0, GetBagSize(BAG_BACKPACK) - 1 do
            local link = GetItemLink(BAG_BACKPACK, i)
            if link == mainLink then
                foundSlot = i
                break
            end
        end

        if foundSlot then
            EquipItem(BAG_BACKPACK, foundSlot, offSlot)

            local lang = SmartGear.currentLang or "en"
            d("|c00FF00[SmartGear]|r " .. (lang == "ru"
                and "Оружие переставлено!"
                or  "Weapons swapped!"))
        else
            local lang = SmartGear.currentLang or "en"
            d("|c00FF00[SmartGear]|r " .. (lang == "ru"
                and "Не удалось найти оружие в сумке."
                or  "Could not find weapon in bag."))
        end

        -- Cooldown reset after a delay
        zo_callLater(function()
            swapCooldown = false
        end, 3000)
    end, 400)

    SmartGear.HideAlert()
end

----------------------------------------------------------------------
-- Override HideAlert to restore equip handler
----------------------------------------------------------------------
local _origHideAlert = SmartGear.HideAlert
SmartGear.HideAlert = function()
    -- Restore equip button handler if it was in swap mode
    if currentAlert and currentAlert.isSwap and equipBtn then
        equipBtn:SetHandler("OnClicked", function()
            SmartGear.OnEquipClicked()
        end)
    end
    _origHideAlert()
end

----------------------------------------------------------------------
-- Scan equipped weapons for suboptimal placement
----------------------------------------------------------------------
function SmartGear.CheckWeaponSwaps()
    if not SmartGear.savedVars or not SmartGear.savedVars.showAlerts then return end
    if COMBAT_LOCKOUT and IsUnitInCombat("player") then return end
    if swapCooldown then return end

    local swaps = SmartGear.CheckAllBarsWeaponSwap()
    if swaps and #swaps > 0 then
        -- Show the best swap suggestion
        local best = swaps[1]
        for _, s in ipairs(swaps) do
            if s.scoreBenefit > best.scoreBenefit then
                best = s
            end
        end

        if isShowing then
            -- Don't interrupt an upgrade alert with a swap suggestion
        else
            SmartGear.ShowSwapAlert(best)
        end
    end
end
