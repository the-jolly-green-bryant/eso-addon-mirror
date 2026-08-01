------------------------------------------------
-- XAM's Toolbox -- Auto Charge
------------------------------------------------

-- Register Module
XAM:registerModule("AutoCharge")

-- Module: Default Settings
XAM.d.AutoCharge = {
    Load = false,
    Threshold = 8,
    Recheck = 60,
    Output = false,
}

local function setDefaults()
    XAM.s.AutoCharge.Load       = XAM.d.AutoCharge.Load
    XAM.s.AutoCharge.Threshold  = XAM.d.AutoCharge.Threshold
    XAM.s.AutoCharge.Recheck    = XAM.d.AutoCharge.Recheck
    XAM.s.AutoCharge.Output     = XAM.d.AutoCharge.Output
end

-- Module: Settings Menu
XAM.o[#XAM.o + 1] = {
    type = "submenu",
    name = "|cFF9900Auto Charge Items|r",
    tooltip = "Settings for auto charging items",
    controls = {
        {
            type = "checkbox",
            name = "Enabled",
            tooltip = "Auto charge equipped items when below a threshold",
            getFunc = function() return XAM.s.AutoCharge.Load end,
            setFunc = function(value) XAM.s.AutoCharge.Load = value XAM:AutoChargeReload() end,
            default = XAM.d.AutoCharge.Load,
            width = "full",
        },{
            type = "checkbox",
            name = "Show message when charging item",
            tooltip = "Will print a local message in chat when charging items",
            getFunc = function() return XAM.s.AutoCharge.Output end,
            setFunc = function(value) XAM.s.AutoCharge.Output = value XAM:AutoChargeReload() end,
            default = XAM.d.AutoCharge.Output,
            width = "full",
        },{
            type = "slider",
            name = "Charge Threshold",
            tooltip = "At what threshold items get recharged at",
            getFunc = function() return XAM.s.AutoCharge.Threshold end,
            setFunc = function(value) XAM.s.AutoCharge.Threshold = value XAM:AutoChargeReload() end,
            default = XAM.d.AutoCharge.Threshold,
            disabled = function() return not XAM.s.AutoCharge.Load end,
            min = 0,
            max = 99,
            width = "full",
            clampInput = false,
        },{
            type = "slider",
            name = "Recheck timer",
            tooltip = "How often items are checked in seconds",
            getFunc = function() return XAM.s.AutoCharge.Recheck end,
            setFunc = function(value) XAM.s.AutoCharge.Recheck = value XAM:AutoChargeReload() end,
            default = XAM.d.AutoCharge.Recheck,
            disabled = function() return not XAM.s.AutoCharge.Load end,
            min = 10,
            max = 120,
            width = "full",
            clampInput = false,
        },{
            type = "description",
            text = [[|cCCCCCCNote: Will only use Soul Gems of|r |c00FF00Fine|r |cCCCCCCquality|r]],
            width = "full",
        },{
            type = "header",
            name = "",
            width = "full",
        },{
            type = "button",
            name = "Set Defaults",
            tooltip = "Reset this section only to default values",
            func = function() setDefaults() end,
            width = "full",
        },
    },
}

-- Module: Auto Charge
function XAM:AutoCharge()
    if XAM.s.AutoCharge.Load == true then
        if XAM.s.debug then
            CHAT_SYSTEM:AddMessage(string.format("%s|cFFFFFFAuto Charge|r: |c00FF00Loaded|r",XAM.prefix))
            CHAT_SYSTEM:AddMessage(string.format("%s|cFFFFFFAuto Charge|r: Checking for charge =< %s%% every %ss",XAM.prefix,XAM.s.AutoCharge.Threshold,XAM.s.AutoCharge.Recheck))
        end
        EVENT_MANAGER:RegisterForUpdate("AutoChargeChecker", (XAM.s.AutoCharge.Recheck * 1000), XAM.CheckCharge)
    elseif XAM.s.debug then
        CHAT_SYSTEM:AddMessage("%s|cFFFFFFAuto Charge|r: |cFF0000Not loaded|r",XAM.prefix)
    end
end

function XAM:AutoChargeReload()
    if EVENT_MANAGER:UnregisterForUpdate("AutoChargeChecker") then
        if XAM.s.debug then CHAT_SYSTEM:AddMessage(string.format("%s|cFFFFFFAuto Charge|r: |cFFa500Reloading|r",XAM.prefix)) end
    end
    XAM:AutoCharge()
end

function XAM.CheckCharge()

    local function needsCharge(slotId)
        local charge, maxCharge = GetChargeInfoForItem(BAG_WORN, slotId)
        return ((charge / maxCharge) * 100) <= XAM.s.AutoCharge.Threshold, ((charge / maxCharge) * 100)
    end

    local function findSoulGem()
        local gemStack,gemQuality,gemCount,gemIndex
        for _, data in pairs(SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)) do
            if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, data.slotIndex) then
                local _,gemStack,_,_,_,_,_,gemQuality = GetItemInfo(BAG_BACKPACK, data.slotIndex)
                if gemQuality == 2 then
                    if XAM.s.debug then
                        local gemItem = GetItemLink(BAG_BACKPACK, data.slotIndex, LINK_STYLE_BRACKETS)
                        CHAT_SYSTEM:AddMessage(string.format("%s|cFFFFFFAuto Charge|r: Found %s (ID: %s, Stack: %s) with Quality: %s",XAM.prefix,gemItem,data.slotIndex,gemStack,gemQuality))
                    end
                    if not gemCount or gemStack < gemCount then
                        gemCount = gemStack
                        gemIndex = data.slotIndex
                        if XAM.s.debug then
                            CHAT_SYSTEM:AddMessage(string.format("%s|cFFFFFFAuto Charge|r: Found better stack size",XAM.prefix))
                        end
                    end
                end
            end
        end
        if XAM.s.debug then
            if gemIndex then
                CHAT_SYSTEM:AddMessage(string.format("%s|cFFFFFFAuto Charge|r: Final Gem Index: %s - Stack Size: %s",XAM.prefix,gemIndex,gemCount))
            else
                CHAT_SYSTEM:AddMessage(string.format("%s|cFFFFFFAuto Charge|r: No Soul Gems found",XAM.prefix))
            end
        end
        return gemIndex or false
    end

    for whichSlot = 0, GetBagSize(BAG_WORN) do
        if XAM.s.debug and IsItemChargeable(BAG_WORN, whichSlot) then
            local chargedItem = GetItemLink(BAG_WORN, whichSlot, LINK_STYLE_BRACKETS)
            local _,curCharge = needsCharge(whichSlot)
            CHAT_SYSTEM:AddMessage(string.format("%s|cFFFFFFAuto Charge|r: %s is %s%% charged",XAM.prefix,chargedItem,curCharge))
        end
        if IsItemChargeable(BAG_WORN, whichSlot) and needsCharge(whichSlot) then
            local whichSoulGem = findSoulGem()
            if whichSoulGem then
                ChargeItemWithSoulGem(BAG_WORN, whichSlot, BAG_BACKPACK, whichSoulGem)
                if XAM.s.debug or XAM.s.AutoCharge.Output then
                    local chargedItem = GetItemLink(BAG_WORN, whichSlot, LINK_STYLE_BRACKETS)
                    local gemItem = GetItemLink(BAG_BACKPACK, whichSoulGem, LINK_STYLE_BRACKETS)
                    local _,curCharge = needsCharge(whichSlot)
                    CHAT_SYSTEM:AddMessage(string.format("%s|cFFFFFFAuto Charge|r: %s was charged with %s at %s%%",XAM.prefix,chargedItem,gemItem,curCharge))
                end
            end
        end
    end
    if XAM.s.debug then CHAT_SYSTEM:AddMessage(string.format("%s|cFFFFFFAuto Charge|r: Checking again in %ss",XAM.prefix,XAM.s.AutoCharge.Recheck)) end
end