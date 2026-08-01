local FDB = LIB_FOOD_DRINK_BUFF

-- Addon Info {{{
Auto = {}
local Auto = Auto

Auto.name = "Auto"
Auto.version = 1.1
Auto.displayName = "|c00ffffAuto|r"
Auto.settingsPanel = nil
Auto.ready = false
-- }}}

-- Saved Vars {{{
Auto.Defaults = {}
Auto.Defaults.log = false

-- Food/Drink
Auto.Defaults.consumeFoodIndex = nil
Auto.Defaults.consumeFoodAvaIndex = nil
Auto.Defaults.foodID = nil
Auto.Defaults.foodAvaID = nil
Auto.Defaults.autoConsumeFood = true
Auto.Defaults.eatAmount = 10
Auto.Defaults.onlyConsumeFoodInDungeon = true

-- Charge
Auto.Defaults.autoChargeWeapon = true
Auto.Defaults.chargeAmount = 10

-- Repair
Auto.Defaults.autoRepairArmor = true
Auto.Defaults.repairAmount = 10

Auto.Defaults.ui = {
    ["iconSize"]    = 25,
    ["barWidth"] = 400,
    ["barFit"]   = true,
    ["offsetY"]  = 0,
    ["offsetX"]  = 0,
    ["point"]    = CENTER,
    ["relPoint"] = CENTER,
    ["scale"]    = 100,
    ["show"]     = true,
    ["group"]    = true,
    ["alpha"]    = 0.3,
}
Auto.Defaults.uiequip = {
    ["offsetY"]  = 0,
    ["offsetX"]  = 0,
    ["point"]    = CENTER,
    ["relPoint"] = CENTER,
    ["scale"]    = 100,
    ["show"]     = true,
}
Auto.Defaults.uienchant = {
    ["offsetY"]  = 0,
    ["offsetX"]  = 0,
    ["point"]    = CENTER,
    ["relPoint"] = CENTER,
    ["scale"]    = 100,
    ["show"]     = true,
}

Auto.Defaults.uihouse = {
    ["offsetY"]  = 0,
    ["offsetX"]  = 0,
    ["point"]    = CENTER,
    ["relPoint"] = CENTER,
    ["scale"]    = 100,
}

--}}}

-- Structures {{{

Auto.hide = false

-- Food
Auto.foodChoiceCount = 0
Auto.foodChoiceLinks = {}
Auto.foodChoiceIndex = {}
Auto.foodChoiceChoices = {}
Auto.foodChoiceIDs = {}
Auto.foodChoiceNameToLink = {}
Auto.foodChoiceSlots = nil
Auto.foodChoiceSlotCount = 0

Auto.soulGemSlots = nil
Auto.soulGemSlotCount = 0
Auto.crownSoulGemSlots = nil
Auto.crownSoulGemSlotCount = 0
Auto.grandRepairKitSlots = nil
Auto.grandRepairKitSlotCount = 0

Auto.conditionsCount = 0

Auto.Enchants = {
    { AutoEnchantMainText,     AutoEnchantMainIcon,     AutoEnchantMain,       },
    { AutoEnchantOffText,      AutoEnchantOffIcon,      AutoEnchantOff,        },
    { AutoEnchantBackMainText, AutoEnchantBackMainIcon, AutoEnchantBackMain,   },
    { AutoEnchantBackOffText,  AutoEnchantBackOffIcon,  AutoEnchantBackOff,    },
}

-- Equip
Auto.Equips = {
    { AutoEquipHeadText    , AutoEquipHeadIcon     , AutoEquipHead     , },
    { AutoEquipShoulderText, AutoEquipShoulderIcon , AutoEquipShoulder , },
    { AutoEquipArmText     , AutoEquipArmIcon      , AutoEquipArm      , },
    { AutoEquipLegText     , AutoEquipLegIcon      , AutoEquipLeg      , },
    { AutoEquipChestText   , AutoEquipChestIcon    , AutoEquipChest    , },
    { AutoEquipBeltText    , AutoEquipBeltIcon     , AutoEquipBelt     , },
    { AutoEquipShoeText    , AutoEquipShoeIcon     , AutoEquipShoe     , },
}

Auto.TooltipCount = 0
Auto.lastRepairTime = 0
--}}}

-- Constants{{{
Auto.REPAIR_WORN_ID = { EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_HAND, EQUIP_SLOT_LEGS, EQUIP_SLOT_CHEST, EQUIP_SLOT_WAIST, EQUIP_SLOT_FEET, }
Auto.EQUIP_WORN_ID = { EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND, EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF }

Auto.ID_TO_EQUIP = { [EQUIP_SLOT_MAIN_HAND] = 1, [EQUIP_SLOT_OFF_HAND] = 2, [EQUIP_SLOT_BACKUP_MAIN] = 3, [EQUIP_SLOT_BACKUP_OFF] = 4 }

Auto.SOUL_GEM_ID = 33271
Auto.CROWN_SOUL_GEM_ID = 61080
Auto.GRAND_REPAIR_KIT_ID = 44879
Auto.UNIT_TAG_PLAYER = "player"
Auto.EATEN_REFIRE = Auto.name .. "EATEN_Refire"
Auto.REPAIR_REFIRE = Auto.name .. "REPAIR_Refire"
Auto.REPAIR_INTERVAL_ALLOWANCE = 1250

--}}}

-- 'HELP' -- {{{
function Auto:GetItemText(bagId, slotId)
    local itemLink   = GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS)
    local icon, _, _, _, _, _, _, _ = GetItemInfo(bagId, slotId)

    return "|t20:20:" .. icon .. "|t " .. itemLink
end

function Auto:LogThis(message, error)
    if not Auto.sv.log then return end

    function getMessage(str)
        local color = "99ff99"

        if error then
            color = "ff9999"
        end

        return "|t20:20:esoui/art/buttons/info_over.dds|t|c" .. tostring(color) .. tostring(str) .. "|r"
    end

    d ( getMessage(message ) )
end

function Auto:ShowThis(control, link)
    control:SetHidden(false)
    -- control:SetDimensions(Auto.sv.ui.iconSize * 2, Auto.sv.ui.iconSize * 2)
    if link then
        control:SetHandler("OnMouseEnter", function (self)
            -- d ( "MouseEnter " .. control:GetName() )
            self.itemtool = ItemTooltip
            if self.itemtool then
                InitializeTooltip(self.itemtool, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
                itemtool:SetLink(link)
            end
        end)

        control:SetHandler("OnMouseExit", function (self)
            -- d ( "MouseExit " .. control:GetName() )
            if self.itemtool then
                ClearTooltip(self.itemtool)
            end
        end)
    end
end

function Auto:HideThis(control)
    control:SetHidden(true)
    -- control:SetDimensions(0,0)
end

function Auto:GetTextColor(curC, maxC, dee)
    local g = 0
    local r = 0

    local scale = 500 / maxC

    if curC >= (maxC / 2) then
        g = 255
        r = ( maxC - curC ) * scale
    else
        g = ( curC +    5 ) * scale
        r = 255
    end

    if r < 0 then r = 0 end
    if g < 0 then g = 0 end

    r = math.min(255, r)
    g = math.min(255, g)

    r = string.format("%x", r )

    if string.len(r) < 2 then
        r = "0" .. r
    end

    g = string.format("%x", g )

    if string.len(g) < 2 then
        g = "0" .. g
    end

    local color =  r .. g  .. "00"
    if dee then
        d ( scale .. " :: |c" .. color .. " " .. color  .. "|r")
    end
    return color
end

function Auto:UpdateRepair(from)
    zo_callLater(function()
        if GetGameTimeMilliseconds() < Auto.lastRepairTime + Auto.REPAIR_INTERVAL_ALLOWANCE then
            return
        end

        -- EVENT_MANAGER:UnregisterForUpdate(Auto.REPAIR_REFIRE)
        -- EVENT_MANAGER:RegisterForUpdate(Auto.REPAIR_REFIRE, Auto.REPAIR_INTERVAL_ALLOWANCE, Auto.UpdateRepair)

        Auto.lastRepairTime = GetGameTimeMilliseconds()
        Auto:RepairParse()
        Auto:RepairAll()
        Auto:UpdateUI()
    end, 500)
end

function Auto:UpdateEaten()
    -- TODO
    EVENT_MANAGER:UnregisterForUpdate(Auto.EATEN_REFIRE)
    EVENT_MANAGER:RegisterForUpdate(Auto.EATEN_REFIRE, 10000, Auto.UpdateEaten)

    local active, time, abilityId = FDB:IsFoodBuffActiveAndGetTimeLeft(Auto.UNIT_TAG_PLAYER)
    if active then

        local icon = GetAbilityIcon(abilityId)
        local dur = GetAbilityDuration(abilityId) / 1000
        local name = GetAbilityName(abilityId)
        local link = Auto.foodChoiceNameToLink[name]
        local timeStr, timeUntil = FormatTimeSeconds(time, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL_HIDE_ZEROES, TIME_FORMAT_PRECISION_SECONDS)

        if link then
            -- Auto:ShowThis(AutoWindowEaten, link)
        end

        -- d(name)

        -- AutoWindowEatenIcon:SetTexture(icon)
        -- AutoWindowEatenText:SetText("|c" .. Auto:GetTextColor(time, dur) .. timeStr .. "|r")
    else
        -- Auto:HideThis(AutoWindowEaten)
    end

    if not active or time / 60 < Auto.sv.eatAmount then
        Auto:EatFood()
    end

    return active, time
end

function Auto:Stackify(arr, count, index)
    if not index then index = 1 end
    local icon, stack, _, _, _, _, _, _ = GetItemInfo(BAG_BACKPACK, arr[index])

    for i=2, count do
        local i, s, _, _, _, _, _, _ = GetItemInfo(BAG_BACKPACK, arr[i])
        stack = s + stack
    end

    return icon, stack
end

function Auto:handleNewItemsForCombo()
    if Auto.settingsPanel and Auto_LAM.controlsToRefresh and #Auto_LAM.controlsToRefresh > 4 then
        local control = Auto_LAM.controlsToRefresh[5]
        control.data.choices = Auto.foodChoiceChoices
        control.data.choicesValues = Auto.foodChoiceIndex
        control.data.choicesTooltips = Auto.foodChoiceLinks
        control:UpdateChoices()
        control:UpdateValue()
    end
end

function Auto:ParseBag(mark) -- {{{
    if not ( mark or Auto.isDirty ) then return end

    -- d ( "Parse Bag " )
    Auto.foodChoiceCount = 0
    Auto.foodChoiceSlotCount = 0

    Auto.foodChoiceIDs = {}
    Auto.foodChoiceSlots = {}
    Auto.foodChoiceLinks = {}
    Auto.foodChoiceIndex = {}
    Auto.foodChoiceChoices = {}
    Auto.foodChoiceNameToLink = {}

    Auto.soulGemSlots = {}
    Auto.soulGemSlotCount = 0

    Auto.crownSoulGemSlots = {}
    Auto.crownSoulGemSlotCount = 0

    Auto.grandRepairKitSlots = {}
    Auto.grandRepairKitSlotCount = 0

    -- Auto.combobox:ClearItems()

    local foodIcon = nil

    for slotId = 0, GetBagSize(BAG_BACKPACK) do
        local id = GetItemId(BAG_BACKPACK, slotId)
        local name = GetItemName(BAG_BACKPACK, slotId)

        -- d ( id .. " : : " .. name )

        if id == Auto.SOUL_GEM_ID then
            Auto.soulGemSlotCount = Auto.soulGemSlotCount + 1
            Auto.soulGemSlots[Auto.soulGemSlotCount] = slotId
        end

        if id == Auto.CROWN_SOUL_GEM_ID then
            Auto.crownSoulGemSlotCount = Auto.crownSoulGemSlotCount + 1
            Auto.crownSoulGemSlots[Auto.crownSoulGemSlotCount] = slotId
        end

        if id == Auto.GRAND_REPAIR_KIT_ID then
            Auto.grandRepairKitSlotCount = Auto.grandRepairKitSlotCount + 1
            Auto.grandRepairKitSlots[Auto.grandRepairKitSlotCount] = slotId
        end

        local type = GetItemType(BAG_BACKPACK, slotId)

        if type == ITEMTYPE_DRINK or type == ITEMTYPE_FOOD then
            Auto.foodChoiceCount = Auto.foodChoiceCount + 1

            local link = GetItemLink(BAG_BACKPACK, slotId, LINK_STYLE_DEFAULT)
            local icon, _, _, _, _, _, _, _ = GetItemInfo(BAG_BACKPACK, slotId)

            Auto.foodChoiceLinks[Auto.foodChoiceCount]   = link
            Auto.foodChoiceNameToLink[name]              = link
            Auto.foodChoiceIndex[Auto.foodChoiceCount]   = Auto.foodChoiceCount
            Auto.foodChoiceChoices[Auto.foodChoiceCount] = "|t20:20:" .. icon .. "|t " .. link
            Auto.foodChoiceIDs[Auto.foodChoiceCount]     = id

            if Auto.sv.foodID and Auto.sv.foodID == id then
                Auto.sv.consumeFoodIndex = Auto.foodChoiceCount
                Auto.foodChoiceSlotCount = Auto.foodChoiceSlotCount + 1
                Auto.foodChoiceSlots[Auto.sv.consumeFoodIndex] = slotId
                if not IsInAvAZone() then foodIcon = icon end
            end

            if Auto.sv.foodAvaID and Auto.sv.foodAvaID == id then
                Auto.sv.consumeFoodAvaIndex = Auto.foodChoiceCount
                Auto.foodAvaChoiceSlotCount = Auto.foodChoiceSlotCount + 1
                Auto.foodChoiceSlots[Auto.sv.consumeFoodAvaIndex] = slotId
                if IsInAvAZone() then foodIcon = icon end
            end

            -- local itemEntry = comboBox:CreateItemEntry(link, SelectConfigTypeCallback)
            -- comboBox:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
        end
    end

    -- Auto:handleNewItemsForCombo()

    if Auto.foodChoiceSlotCount == 0 then
        Auto:HideThis(AutoWindowFood)
    else
        local foodIndex = Auto.sv.consumeFoodIndex
        if IsInAvAZone() then
            foodIndex = Auto.sv.consumeFoodAvaIndex
        end
        local _, stack = Auto:Stackify(Auto.foodChoiceSlots, Auto.foodChoiceSlotCount, foodIndex)
        Auto:ShowThis(AutoWindowFood, Auto.foodChoiceLinks[foodIndex])
        if foodIcon then
            AutoWindowFoodIcon:SetTexture(foodIcon)
        end
        AutoWindowFoodText:SetText("|c"..Auto:GetTextColor(stack, 30) .. stack .."|r")

        if not Auto.sv.foodID then
            Auto.sv.foodID = Auto.foodChoiceIDs[Auto.sv.consumeFoodIndex]
        end
        if not Auto.sv.foodAvaID then
            Auto.sv.foodAvaID = Auto.foodChoiceIDs[Auto.sv.consumeFoodAvaIndex]
        end
    end

    if Auto.grandRepairKitSlotCount == 0 then
        AutoWindowRepairKitsText:SetText("|cff00000|r")
        AutoWindowRepairKitsIcon:SetTexture("/esoui/art/icons/quest_crate_001.dds")
    else
        local icon, stack = Auto:Stackify(Auto.grandRepairKitSlots, Auto.grandRepairKitSlotCount)
        -- d ( icon )
        AutoWindowRepairKitsIcon:SetTexture(icon)
        AutoWindowRepairKitsText:SetText("|c"..Auto:GetTextColor(stack, 30) .. stack .."|r")
        Auto:ShowThis(AutoWindowRepairKits, GetItemLink(BAG_BACKPACK, Auto.grandRepairKitSlots[1], LINK_STYLE_DEFAULT))
    end


    if Auto.soulGemSlotCount == 0 and Auto.crownSoulGemSlotCount == 0 then
        AutoWindowSoulGemText:SetText("|cff00000|r")
        AutoWindowSoulGemIcon:SetTexture("esoui/art/icons/soulgem_006_filled.dds")
    else
        local _, stack2 = Auto:Stackify(Auto.crownSoulGemSlots, Auto.crownSoulGemSlotCount)
        local icon, stack = Auto:Stackify(Auto.soulGemSlots, Auto.soulGemSlotCount)
        stack = stack + stack2

        AutoWindowSoulGemIcon:SetTexture(icon)
        AutoWindowSoulGemText:SetText("|c"..Auto:GetTextColor(stack, 30) .. stack .."|r")
        Auto:ShowThis(AutoWindowSoulGem, GetItemLink(BAG_BACKPACK, Auto.soulGemSlots[1], LINK_STYLE_DEFAULT))
    end

    Auto.isDirty = false
end -- }}}
-- }}}

-- 'FOOD/DRINK' -- {{{
function Auto:EatFood(force)
    local amISecure = CallSecureProtected("UseItem")

    if amISecure ~= true then
        return
    end

    if not force then
        if not IsInAvAZone() and not IsUnitInDungeon(Auto.UNIT_TAG_PLAYER) and Auto.sv.onlyConsumeFoodInDungeon then return end
        if not ( Auto.sv.autoConsumeFood ) then return end
    end

    if IsUnitInCombat(Auto.UNIT_TAG_PLAYER) then return end
    if IsUnitDeadOrReincarnating(Auto.UNIT_TAG_PLAYER) then return end
    if IsUnitSwimming(Auto.UNIT_TAG_PLAYER) then return end
    if not IsInAvAZone() and not Auto.sv.consumeFoodIndex then return end
    if IsInAvAZone() and not Auto.sv.consumeFoodAvaIndex then return end

    if IsInAvAZone() and ( Auto.sv.foodAvaID and Auto.foodChoiceSlotCount > 0 and CanInteractWithItem(BAG_BACKPACK, Auto.foodChoiceSlots[Auto.sv.consumeFoodAvaIndex])) then
        Auto:LogThis ( " Going to eat food now!! : " .. tostring(Auto.foodChoiceChoices[Auto.sv.consumeFoodAvaIndex]))
        CallSecureProtected("UseItem", BAG_BACKPACK, Auto.foodChoiceSlots[Auto.sv.consumeFoodAvaIndex])
    elseif ( Auto.sv.foodID and Auto.foodChoiceSlotCount > 0 and CanInteractWithItem(BAG_BACKPACK, Auto.foodChoiceSlots[Auto.sv.consumeFoodIndex])) then
        Auto:LogThis ( " Going to eat food now!! : " .. tostring(Auto.foodChoiceChoices[Auto.sv.consumeFoodIndex]))
        CallSecureProtected("UseItem", BAG_BACKPACK, Auto.foodChoiceSlots[Auto.sv.consumeFoodIndex])
    else
        Auto:LogThis( " Warning!! : The food you have selected or haven't selected you are out of.", true )
        EVENT_MANAGER:UnregisterForUpdate(Auto.EATEN_REFIRE)
        EVENT_MANAGER:RegisterForUpdate(Auto.EATEN_REFIRE, 10000, Auto.UpdateEaten)
    end
end -- }}}

-- 'SOUL GEMS''' -- {{{
function Auto:GetSoulGem(bagId, slotId, i)
    local curC, maxC = GetChargeInfoForItem(bagId, slotId)

    if maxC == 0 then
        Auto:HideThis(Auto.Enchants[i][3])
        return -1
    end

    local icon, _, _, _, _, _, _, _ = GetItemInfo(bagId, slotId)

    curC = tonumber(curC)
    maxC = tonumber(maxC)

    local text = math.floor((curC / maxC) * 100)
    if text > 99 then text = 100 else text = text .. "%" end

    Auto.Enchants[i][1]:SetText("|c" .. Auto:GetTextColor(curC, maxC) ..  text .. "|r")
    Auto.Enchants[i][2]:SetTexture(icon)
    Auto:ShowThis(Auto.Enchants[i][3], GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT))

    if curC > Auto.sv.chargeAmount then return -1 end

    Auto.ParseBag()

    local soulgem = nil

    -- Check this silly setting
    if GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_DEFAULT_SOUL_GEM) == 0 then
        soulgem = Auto.soulGemSlots[1] or Auto.crownSoulGemSlots[1]
    else
        soulgem = Auto.crownSoulGemSlots[1] or Auto.soulGemSlots[1]
    end

    if CanInteractWithItem(BAG_BACKPACK, soulgem) then
        return soulgem
    else
        return nil
    end
end

function Auto:ChargeAll()
    for i, wep in ipairs(Auto.EQUIP_WORN_ID) do
        -- if it's shield we handle it in repair, which we don't want to
        -- override so...
        if GetItemWeaponType(BAG_WORN, wep) ~= WEAPONTYPE_SHIELD then
            -- update ui always
            local gem = Auto:GetSoulGem(BAG_WORN, wep, i)

            if Auto.sv.autoChargeWeapon then
                Auto:Charge(BAG_WORN, wep, gem)
            else
                -- d()
            end
        end
    end

    Auto:UpdateUI()
end

function Auto:Charge(bagId, slotId, soulgem)
    if IsUnitDead(Auto.UNIT_TAG_PLAYER) then return end
    -- d ( "Charge" )

    if soulgem then
        if soulgem ~= -1 then
            -- d ( "Charge2" )
            Auto:LogThis ( "Charging " .. Auto:GetItemText(bagId, slotId) )
            ChargeItemWithSoulGem(bagId, slotId, BAG_BACKPACK, soulgem)
        end
    else
        -- d()
        Auto:LogThis ( "Attempted Charging " .. Auto:GetItemText(bagId, slotId) .. ", but failed.", true)
    end
end -- }}}

-- 'REPAIR' -- {{{

function Auto:GetRepairKit()
    if Auto.grandRepairKitSlots[1] then
        local icon, stack = Auto:Stackify(Auto.grandRepairKitSlots, Auto.grandRepairKitSlotCount)
        if  stack < 1 then
            return nil
        else
            if CanInteractWithItem(BAG_BACKPACK, Auto.grandRepairKitSlots[1]) then
                return Auto.grandRepairKitSlots[1]
            else
                return nil
            end
        end
    else
        return nil
    end
end

function Auto:RepairParse()
    -- d ( "RepairParse" )
    local totalRepairCost = 0
    local totalItemCount = 0

    Auto.conditions = {}
    Auto.conditionsCount = 0

    function evalItem(slotId, i, arr)
        local itemName      = GetItemName(BAG_WORN, slotId)
        local equip = arr[i]

        if itemName ~= '' then
            local itemCondition = GetItemCondition(BAG_WORN, slotId)
            local repairCost = GetItemRepairCost(BAG_WORN, slotId)

            totalItemCount  = totalItemCount  + 1
            totalRepairCost = totalRepairCost + repairCost

            local itemLink   = GetItemLink(BAG_WORN, slotId, LINK_STYLE_BRACKETS)
            Auto:ShowThis(equip[3], itemLink)

            local icon, _, _, _, _, _, _, _ = GetItemInfo(BAG_WORN, slotId)
            equip[2]:SetTexture(icon)
            local itemConditionText = itemCondition .. "%"

            if itemCondition > 99 then
                itemConditionText = "100"
            end

            equip[1]:SetText("|c" .. Auto:GetTextColor(itemCondition, 100) .. itemConditionText .."|r")

            Auto.conditions[slotId] = itemCondition
            Auto.conditionsCount = Auto.conditionsCount + 1
        else
            Auto:HideThis(equip[3])
        end
    end

    for i,slotId in ipairs(Auto.REPAIR_WORN_ID) do
        evalItem(slotId, i, Auto.Equips)
    end

    for i, slotId in ipairs(Auto.EQUIP_WORN_ID) do
        -- Currently only shields can be equipped in off-hand
        if i % 2 == 0 then
            if GetItemWeaponType(BAG_WORN, slotId) == WEAPONTYPE_SHIELD then
                evalItem(slotId, i, Auto.Enchants)
            end
        end
    end
end

function Auto:RepairAll()
    if IsUnitDead(Auto.UNIT_TAG_PLAYER) then return end
    if not ( Auto.sv.autoRepairArmor ) then return end
    if Auto.conditionsCount < 1 then return end
    if not Auto.sv.repairAmount then return end

    Auto:ParseBag()

    for i, armor in ipairs(Auto.REPAIR_WORN_ID) do
        if Auto.conditions[armor] then
            if Auto.conditions[armor] <= Auto.sv.repairAmount then
                Auto:Repair(BAG_WORN, armor, Auto:GetRepairKit(), Auto.Equips, i)
            end
        end
    end

    for i, armor in ipairs(Auto.EQUIP_WORN_ID) do
        if i % 2 == 0 then
            if Auto.conditions[armor] then
                if Auto.conditions[armor] <= Auto.sv.repairAmount then
                    Auto:Repair(BAG_WORN, armor, Auto:GetRepairKit(), Auto.Enchants, i)
                end
            end
        end
    end
end

function Auto:Repair(bagId, slotId, kit, arr, i)
    if kit then
        Auto:LogThis ( "Repairing " .. Auto:GetItemText(bagId, slotId))
        RepairItemWithRepairKit(bagId, slotId, BAG_BACKPACK, kit)

        zo_callLater(function()
            -- d ( "Call later " )
            local equip = arr[i]

            local itemLink   = GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS)
            Auto:ShowThis(equip[3], itemLink)

            local icon, _, _, _, _, _, _, _ = GetItemInfo(bagId, slotId)
            equip[2]:SetTexture(icon)
            local itemCondition = GetItemCondition(BAG_WORN, slotId)
            local itemConditionText = itemCondition .. "%"

            if itemCondition > 99 then
                itemConditionText = "100"
            end

            equip[1]:SetText("|c" .. Auto:GetTextColor(itemCondition, 100) .. itemConditionText .."|r")
        end, 200)
    else
        Auto:LogThis ( "Attempted Repair for " .. Auto:GetItemText(bagId, slotId) .. " but failed", true)
    end
end -- }}}

-- 'UI'

function Auto:UpdateUI(updateIconSize) -- {{{
    function handleChildren(parent)
        for i=1, parent:GetNumChildren() do
            local child = parent:GetChild(i)
            local x,y = child:GetDimensions()
            if x ~= 0 and y ~= 0 then
                child:SetDimensions(Auto.sv.ui.iconSize * 2, Auto.sv.ui.iconSize )

                for v=1, child:GetNumChildren() do
                    local grandchild = child:GetChild(v)
                    if grandchild.SetFont then
                        grandchild:SetDimensions(Auto.sv.ui.iconSize * 2, Auto.sv.ui.iconSize)
                        if Auto.sv.ui.iconSize < 20 then
                            grandchild:SetFont("$(MEDIUM_FONT)|$(KB_12)|soft-shadow-thin")
                        elseif Auto.sv.ui.iconSize < 25 then
                            grandchild:SetFont("$(MEDIUM_FONT)|$(KB_14)|soft-shadow-thin")
                        elseif Auto.sv.ui.iconSize < 30 then
                            grandchild:SetFont("$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin")
                        elseif Auto.sv.ui.iconSize < 35 then
                            grandchild:SetFont("$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thin")
                        elseif Auto.sv.ui.iconSize < 40 then
                            grandchild:SetFont("$(MEDIUM_FONT)|$(KB_20)|soft-shadow-thin")
                        elseif Auto.sv.ui.iconSize < 50 then
                            grandchild:SetFont("$(MEDIUM_FONT)|$(KB_22)|soft-shadow-thin")
                        elseif Auto.sv.ui.iconSize == 50 then
                            grandchild:SetFont("$(MEDIUM_FONT)|$(KB_24)|soft-shadow-thin")
                        end
                    else
                        grandchild:SetDimensions(Auto.sv.ui.iconSize , Auto.sv.ui.iconSize)
                    end
                end
            end
        end
    end

    if updateIconSize ~= nil then
        handleChildren(AutoWindow)
        handleChildren(AutoEquip)
        handleChildren(AutoEnchant)
    end

    AutoWindow:SetHidden(Auto.hide or not Auto.sv.ui.show)
    AutoEquip:SetHidden(Auto.hide or not Auto.sv.uiequip.show)
    AutoEnchant:SetHidden(Auto.hide or not Auto.sv.uienchant.show)

    local totalSize = 0
    local Y = Auto.sv.ui.iconSize * 4

    if Auto.sv.ui.show then
        local size = Auto.sv.ui.iconSize * 2.2
        AutoWindow:SetDimensions(size, Y)
        totalSize = totalSize + size
    else
        AutoWindow:SetDimensions(0,0)
    end

    if Auto.sv.uiequip.show then
        local size = Auto.sv.ui.iconSize * 4
        AutoEquip:SetDimensions(size, Y)
        totalSize = totalSize + size
    else
        AutoEquip:SetDimensions(0,0)
    end

    if Auto.sv.uienchant.show then
        local x = 4
        if AutoEnchantBackOff:IsHidden() and AutoEnchantOff:IsHidden() then
            x = 2.2
        end

        local size = x * Auto.sv.ui.iconSize
        AutoEnchant:SetDimensions(size, Y)
        totalSize = totalSize + size
    else
        AutoEnchant:SetDimensions(0,0)
    end

    if Auto.sv.ui.group then
        if Auto.sv.ui.show or Auto.sv.uiequip.show or Auto.sv.uienchant.show then
            AutoHouse:SetHidden(Auto.hide)
            AutoHouse:SetAlpha(Auto.sv.ui.alpha)
            AutoHouse:SetAnchor(Auto.sv.uihouse.point, GuiRoot, Auto.sv.uihouse.relPoint, Auto.sv.uihouse.offsetX, Auto.sv.uihouse.offsetY)
            AutoHouse:SetDimensions(totalSize * 1.1, Y * 1.1)
            AutoHouse:SetCenterColor(0,0,0,1)
            AutoHouse:SetEdgeColor(0,0,0,1)
            AutoHouse:SetHandler("OnMoveStop", function (self)
                local valid, point, _, relPoint, offsetX, offsetY = self:GetAnchor(0)
                if valid then
                    Auto.sv.uihouse.point    = point
                    Auto.sv.uihouse.relPoint = relPoint
                    Auto.sv.uihouse.offsetX  = offsetX
                    Auto.sv.uihouse.offsetY  = offsetY
                end
                WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
            end)

            -- need to always set the anchor
            AutoEnchant:SetAnchor(RIGHT, AutoHouse, RIGHT, -5, 0)
            AutoEquip:SetAnchor(RIGHT, AutoEnchant, LEFT, -5, 0)
            AutoWindow:SetAnchor(RIGHT, AutoEquip, LEFT, -5, 0)

            if Auto.sv.ui.show then
                AutoWindow:SetCenterColor(0,0,0,0)
                AutoWindow:SetEdgeColor(0,0,0,0)
                AutoWindow:SetMovable(false)
                AutoWindow:SetHandler("OnMoveStop", function (self) end)
                AutoWindow:SetHandler("OnMouseEnter", function (self) end)
                AutoWindow:SetHandler("OnMouseExit", function (self) end)
            end

            if Auto.sv.uiequip.show then
                AutoEquip:SetCenterColor(0,0,0,0)
                AutoEquip:SetEdgeColor(0,0,0,0)
                AutoEquip:SetMovable(false)
                AutoEquip:SetHandler("OnMoveStop", function (self) end)
                AutoEquip:SetHandler("OnMouseEnter", function (self) end)
                AutoEquip:SetHandler("OnMouseExit", function (self) end)
            end

            if Auto.sv.uienchant.show then
                AutoEnchant:SetCenterColor(0,0,0,0)
                AutoEnchant:SetEdgeColor(0,0,0,0)
                AutoEnchant:SetMovable(false)
                AutoEnchant:SetHandler("OnMouseEnter", function (self) end)
                AutoEnchant:SetHandler("OnMouseExit", function (self) end)
                AutoEnchant:SetHandler("OnMoveStop", function (self) end)
            end
        else
            AutoHouse:SetHidden(true)
        end
    else
        AutoHouse:SetHidden(true)

        if Auto.sv.ui.show then
            AutoWindow:SetMovable(true)
            AutoWindow:SetAlpha(Auto.sv.ui.alpha)
            AutoWindow:SetAnchor(Auto.sv.ui.point, GuiRoot, Auto.sv.ui.relPoint, Auto.sv.ui.offsetX, Auto.sv.ui.offsetY)
            AutoWindow:SetCenterColor(0,0,0,1)
            AutoWindow:SetEdgeColor(0,0,0,1)

            AutoWindow:SetHandler("OnMoveStop", function (self)
                local valid, point, _, relPoint, offsetX, offsetY = self:GetAnchor(0)
                if valid then
                    Auto.sv.ui.point = point
                    Auto.sv.ui.relPoint = relPoint
                    Auto.sv.ui.offsetX = offsetX
                    Auto.sv.ui.offsetY = offsetY
                end
                WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
            end)

            AutoWindow:SetHandler("OnMouseEnter", function (self)
                self:SetCenterColor(0,1,1,0.3)
                self:SetEdgeColor(0,1,1,0.4)

                WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_PAN)
            end)

            AutoWindow:SetHandler("OnMouseExit", function (self)
                self:SetCenterColor(0,0,0,1)
                self:SetEdgeColor(0,0,0,1)

                WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
            end)
        end

        if Auto.sv.uiequip.show then
            AutoEquip:SetAnchor(Auto.sv.uiequip.point, GuiRoot, Auto.sv.uiequip.relPoint, Auto.sv.uiequip.offsetX, Auto.sv.uiequip.offsetY)
            AutoEquip:SetAlpha(Auto.sv.ui.alpha)
            AutoEquip:SetMovable(true)
            AutoEquip:SetCenterColor(0,0,0,1)
            AutoEquip:SetEdgeColor(0,0,0,1)

            AutoEquip:SetHandler("OnMoveStop", function (self)
                local valid, point, _, relPoint, offsetX, offsetY = self:GetAnchor(0)
                if valid then
                    Auto.sv.uiequip.point    = point
                    Auto.sv.uiequip.relPoint = relPoint
                    Auto.sv.uiequip.offsetX  = offsetX
                    Auto.sv.uiequip.offsetY  = offsetY
                end
                WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
            end)

            AutoEquip:SetHandler("OnMouseEnter", function (self)
                self:SetCenterColor(0,1,1,0.3)
                self:SetEdgeColor(0,1,1,0.4)

                WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_PAN)
            end)

            AutoEquip:SetHandler("OnMouseExit", function (self)
                self:SetCenterColor(0,0,0,1)
                self:SetEdgeColor(0,0,0,1)

                WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
            end)
        end

        if Auto.sv.uienchant.show then
            AutoEnchant:SetAnchor(Auto.sv.uienchant.point, GuiRoot, Auto.sv.uienchant.relPoint, Auto.sv.uienchant.offsetX, Auto.sv.uienchant.offsetY)
            AutoEnchant:SetAlpha(Auto.sv.ui.alpha)
            AutoEnchant:SetMovable(true)
            AutoEnchant:SetCenterColor(0,0,0,1)
            AutoEnchant:SetEdgeColor(0,0,0,1)

            AutoEnchant:SetHandler("OnMouseEnter", function (self)
                self:SetCenterColor(0,1,1,0.3)
                self:SetEdgeColor(0,1,1,0.4)

                WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_PAN)
            end)

            AutoEnchant:SetHandler("OnMouseExit", function (self)
                self:SetCenterColor(0,0,0,1)
                self:SetEdgeColor(0,0,0,1)

                WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
            end)

            AutoEnchant:SetHandler("OnMoveStop", function (self)
                local valid, point, _, relPoint, offsetX, offsetY = self:GetAnchor(0)
                if valid then
                    Auto.sv.uienchant.point    = point
                    Auto.sv.uienchant.relPoint = relPoint
                    Auto.sv.uienchant.offsetX  = offsetX
                    Auto.sv.uienchant.offsetY  = offsetY
                end
                WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
            end)
        end

    end

    -- d ( "Update UI" )
end -- }}}

function Auto:CreateSettingsWindow() -- {{{
    local settingsWindowData = {
        type = "panel",
        name = Auto.displayName,
        author = "|cff00ffJodynn|r",
        version = Auto.version .. "",
        registerForRefresh = true,
        registerForDefaults = true,
        slashCommand = "/autosettings"
    }

    local settingsOptionsData = {
        -- submenu
        {
            type = "header",
            name = "Food",
        },

        {
            type = "checkbox",
            name = "Automatically consume food",
            tooltip = "Automatically eat your food if you have one selected below.",
            default = Auto.Defaults.autoConsumeFood,
            getFunc = function() return Auto.sv.autoConsumeFood end,
            setFunc = function(newValue) Auto.sv.autoConsumeFood = newValue Auto:UpdateEaten() end,
        },

        {
            type = "checkbox",
            name = "Dungeons Only",
            tooltip = "Only consume food if you are in a dungeon, delve, trial, etc.",
            default = Auto.Defaults.onlyConsumeFoodInDungeon,
            getFunc = function() return Auto.sv.onlyConsumeFoodInDungeon end,
            setFunc = function(newValue) Auto.sv.onlyConsumeFoodInDungeon = newValue Auto:UpdateEaten() end,
        },

        {
            type = "slider",
            name = "Minutes Left",
            tooltip = "How many minutes left before you consume food.",
            min = 0,
            max = 120,
            step = 1,
            default = Auto.Defaults.eatAmount,
            getFunc = function() return Auto.sv.eatAmount end,
            setFunc = function(newValue) Auto.sv.eatAmount = newValue Auto:UpdateEaten() end,
        },

        {
            type = "linkdropdown",
            name = "Food to consume",
            choices = Auto.foodChoiceChoices,
            choicesValues = Auto.foodChoiceIndex,
            choicesTooltips = Auto.foodChoiceLinks,
            default = Auto.Defaults.consumeFoodIndex,
            getFunc = function() return Auto.sv.consumeFoodIndex end,
            setFunc = function(newValue)
                Auto.sv.consumeFoodIndex = newValue
                Auto.sv.foodID = Auto.foodChoiceIDs[newValue]
                Auto:ParseBag(true)
                Auto:UpdateEaten()
                if Auto.settingsPanel and Auto_LAM.controlsToRefresh and #Auto_LAM.controlsToRefresh > 4 then
                    local control = Auto_LAM.controlsToRefresh[5]
                    control:UpdateValue()
                end
            end,
        },

        {
            type = "linkdropdown",
            name = "PVP Food to consume",
            choices = Auto.foodChoiceChoices,
            choicesValues = Auto.foodChoiceIndex,
            choicesTooltips = Auto.foodChoiceLinks,
            default = Auto.Defaults.consumeFoodAvaIndex,
            getFunc = function() return Auto.sv.consumeFoodAvaIndex end,
            setFunc = function(newValue)
                Auto.sv.consumeFoodAvaIndex = newValue
                Auto.sv.foodAvaID = Auto.foodChoiceIDs[newValue]
                Auto:ParseBag(true)
                Auto:UpdateEaten()
                if Auto.settingsPanel and Auto_LAM.controlsToRefresh and #Auto_LAM.controlsToRefresh > 5 then
                    local control = Auto_LAM.controlsToRefresh[6]
                    control:UpdateValue()
                end
            end,
        },

        {
            type = "header",
            name = "Enchants",
        },

        {
            type = "checkbox",
            name = "Automatically recharge weapons",
            tooltip = "Automatically recharge your weapons when they have x charges left.",
            default = Auto.Defaults.autoChargeWeapon,
            getFunc = function() return Auto.sv.autoChargeWeapon end,
            setFunc = function(newValue) Auto.sv.autoChargeWeapon = newValue Auto:ChargeAll() end,
        },

        {
            type = "slider",
            name = "Charges Left",
            tooltip = "How many charges left before you charge your weapon.",
            min = 0,
            max = 499,
            step = 1,
            default = Auto.Defaults.chargeAmount,
            getFunc = function() return Auto.sv.chargeAmount end,
            setFunc = function(newValue) Auto.sv.chargeAmount = newValue Auto:ChargeAll() end,
        },

        {
            type = "header",
            name = "Repair",
        },

        {
            type = "checkbox",
            name = "Automatically repair armor",
            tooltip = "Automatically repair your armor with repair kits when they have x condition or less.",
            default = Auto.Defaults.autoRepairArmor,
            getFunc = function() return Auto.sv.autoRepairArmor end,
            setFunc = function(newValue) Auto.sv.autoRepairArmor = newValue Auto:UpdateRepair("Settings Auto Repair Check") end,
        },

        {
            type = "slider",
            name = "Min Condition",
            tooltip = "How low can you go before you repair.",
            min = 0,
            max = 99,
            step = 1,
            default = Auto.Defaults.repairAmount,
            getFunc = function() return Auto.sv.repairAmount end,
            setFunc = function(newValue) Auto.sv.repairAmount = newValue Auto:UpdateRepair("Min Condition changed") end,
        },

        -- submenu

        {
            type = "header",
            name = "UI",
        },


        {
            type = "checkbox",
            name = "Show Resources HUD",
            default = Auto.Defaults.ui.show,
            getFunc = function() return Auto.sv.ui.show end,
            setFunc = function(newValue) Auto.sv.ui.show = newValue; Auto.hide = false; Auto:UpdateUI() end,
        },

        {
            type = "checkbox",
            name = "Show Equipment HUD",
            default = Auto.Defaults.uiequip.show,
            getFunc = function() return Auto.sv.uiequip.show end,
            setFunc = function(newValue) Auto.sv.uiequip.show = newValue; Auto.hide = false; Auto:UpdateUI() end,
        },

        {
            type = "checkbox",
            name = "Show Weapon Enchants HUD",
            default = Auto.Defaults.uienchant.show,
            getFunc = function() return Auto.sv.uienchant.show end,
            setFunc = function(newValue) Auto.sv.uienchant.show = newValue; Auto.hide = false; Auto:UpdateUI() end,
        },

        {
            type = "checkbox",
            name = "Group HUDs together",
            tooltip = "If off you can move the HUDs individually.",
            default = Auto.Defaults.ui.group,
            getFunc = function() return Auto.sv.ui.group end,
            setFunc = function(newValue) Auto.sv.ui.group = newValue ReloadUI() end,
            requiresReload = true,
        },

        {
            type = "slider",
            name = "HUD Alpha",
            min = 0,
            max = 100,
            step = 1,
            default = Auto.Defaults.ui.alpha,
            getFunc = function() return Auto.sv.ui.alpha * 100 end,
            setFunc = function(newValue) Auto.sv.ui.alpha = newValue / 100; Auto.hide = false ; Auto:UpdateUI() end,
        },

        {
            type = "slider",
            name = "Icon Size",
            min = 15,
            max = 50,
            step = 1,
            default = Auto.Defaults.ui.iconSize,
            getFunc = function() return Auto.sv.ui.iconSize end,
            setFunc = function(newValue) Auto.sv.ui.iconSize = newValue; Auto.hide = false; Auto:UpdateUI(1) end,
        },

        -- submenu
        {
            type = "header",
            name = "Log",
        },

        {
            type = "checkbox",
            name = "Log Messages",
            tooltip = "Log messages of what happens, in a pretty format.",
            default = Auto.Defaults.log,
            getFunc = function() return Auto.sv.log end,
            setFunc = function(newValue) Auto.sv.log = newValue end,
        },


    }

    local LAM = LibAddonMenu2
    Auto.settingsPanel = LAM:RegisterAddonPanel(Auto.name.."_LAM", settingsWindowData)
    LAM:RegisterOptionControls(Auto.name.."_LAM", settingsOptionsData)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function()
        Auto:handleNewItemsForCombo()
    end)
end -- }}}

function Auto:Init() -- {{{
    Auto.sv = ZO_SavedVars:New("Auto_sv", 1, nil, Auto.Defaults)

    local scenes= {"hud", "hudui" }

    for _, scene in ipairs(scenes) do
        local sceneObj = SCENE_MANAGER:GetScene(scene)

        sceneObj:RegisterCallback("StateChange", function(oldState, newState)
            -- d ( scene .. " :: " .. tostring(oldState) .. " -> " .. tostring(newState) )
            Auto.hide = not ( newState and ( newState == "showing" or newState == "shown" ) )
            Auto:UpdateUI()
        end)
    end
end -- }}}


-- ' EVENTS '
EVENT_MANAGER:RegisterForEvent(Auto.name, EVENT_PLAYER_REINCARNATED, function (event) -- {{{
    if not Auto.ready then return end
    Auto:UpdateEaten()
    Auto:UpdateRepair("Player Reincarnate")
    Auto:ChargeAll()
end) -- }}}

EVENT_MANAGER:RegisterForEvent(Auto.name, EVENT_PLAYER_ALIVE, function (event) -- {{{
    -- d ( "Alive!!" )
end) -- }}}

EVENT_MANAGER:RegisterForEvent(Auto.name, EVENT_ADD_ON_LOADED, function (event, addonName) -- {{{
    if addonName == Auto.name then
        Auto:Init()
        FDB:RegisterAbilityIdsFilterOnEventEffectChanged(Auto.name, Auto.UpdateEaten, REGISTER_FILTER_UNIT_TAG, Auto.UNIT_TAG_PLAYER)
    end
end) -- }}}

EVENT_MANAGER:RegisterForEvent(Auto.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange) -- {{{
    if not Auto.ready then return end
    Auto.isDirty = true

    -- INVENTORY_UPDATE_REASON_DEFAULT           == 0
    -- INVENTORY_UPDATE_REASON_DURABILITY_CHANGE == 1
    -- INVENTORY_UPDATE_REASON_DYE_CHANGE        == 2
    -- INVENTORY_UPDATE_REASON_ITEM_CHARGE       == 3

    -- local type = GetItemType(BAG_BACKPACK, slotId)
    local name = GetItemName(BAG_BACKPACK, slotId)

    -- d ( tostring( bagId ) .. " :: " .. tostring ( slotId ) .. " :: " .. inventoryUpdateReason .. " :: " .. tostring(type) .. " :: " .. tostring(name) )

    if inventoryUpdateReason == INVENTORY_UPDATE_REASON_ITEM_CHARGE then
        -- d( "Charge update" )
        Auto:Charge(bagId, slotId, Auto:GetSoulGem(bagId, slotId, Auto.ID_TO_EQUIP[slotId]))

    elseif inventoryUpdateReason == INVENTORY_UPDATE_REASON_DEFAULT then
        -- d( "Default update" )
        local id = GetItemId(bagId, slotId)
        local type = GetItemType(BAG_BACKPACK, slotId)

        -- d ( id  .. ' :: ' .. Auto.sv.foodID .. ' :: ' )
        if bagId == BAG_BACKPACK then
            if ( ( Auto.sv.foodID and Auto.sv.foodID == id ) or ( Auto.sv.foodAvaID and Auto.sv.foodAvaID == id ) or Auto.SOUL_GEM_ID == id or Auto.CROWN_SOUL_GEM_ID ) then
                Auto:ParseBag()
                zo_callLater( Auto.UpdateEaten, 2000 )
            elseif type == ITEMTYPE_DRINK or type == ITEMTYPE_FOOD then
                Auto:ParseBag()
                zo_callLater( Auto.UpdateEaten, 2000 )
            end
        end

        if bagId == BAG_WORN then
            Auto:ChargeAll()
            Auto:UpdateRepair("Bag Worn")
        end
    elseif inventoryUpdateReason == INVENTORY_UPDATE_REASON_DURABILITY_CHANGE then
        -- d( "Durability update" )
        Auto:UpdateRepair("Dur Changed")
    else
    end
end) -- }}}

EVENT_MANAGER:RegisterForEvent(Auto.name, EVENT_PLAYER_DEAD , function(eventCode) -- {{{
    if not Auto.ready then return end
    Auto:RepairParse()
end) -- }}}

EVENT_MANAGER:RegisterForEvent(Auto.name, EVENT_PLAYER_ACTIVATED , function(eventCode, initial) -- {{{
    Auto.isDirty = true

    Auto:ParseBag()

    if Auto.settingsPanel then
    else
        Auto:CreateSettingsWindow()
    end

    Auto:UpdateEaten()
    Auto:UpdateRepair("Player Active")
    Auto:ChargeAll()

    Auto:UpdateUI(1)

    Auto.ready = true
end) -- }}}

