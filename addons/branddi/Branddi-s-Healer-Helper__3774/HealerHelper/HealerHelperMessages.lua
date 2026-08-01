HealerHelper.MAX_NUMBER_OF_COMBAT_MESSAGES = 4
HealerHelper.MAX_NUMBER_OF_GEAR_MESSAGES = 6

HealerHelper.healerCombatMessages = {
    ["MinorSavagery"]              = {false,"Crit Damage", ""},
    ["MinorToughness"]             = {false,"Minor Toughness", ""},

    ["Zen_LA"]                     = {false,"Zen's LA", ""},
    ["MK_LA"]                      = {false,"MK LA", ""},
    ["Wrong_Bar_HA"]               = {false,"Wrong bar HA", ""},
    ["Unnecessary_HA"]             = {false,"Unnecessary HA", ""},
    ["Spaulder_Off"]               = {false,"Spaulder", ""},
    ["Trauma"]                     = {false,"Trauma", ""}


-- lower messages in this list appear first in the UI
}


HealerHelper.healerGearMessages = {



    ["RelentlessFocus_Morph"]       = {false,"Relentless Focus morph", ""},


    ["RuneColorlessPool_Morph"]     = {false,"Rune Colorless Pool morph", ""},
    ["Zena_Morph"]                  = {false,"Zena's morph", ""},
    ["LotusFan_Morph"]              = {false,"Lotus Fan morph", ""},
    ["EfficientPurge_Morph"]        = {false,"Efficient Purge morph", ""},
    ["CombatPrayer_Morph"]          = {false,"Combat Prayer morph", ""},
    ["EchoingVigor_Morph"]          = {false,"Echoing Vigor morph", ""},
    ["AggressiveWarhorn_Morph"]     = {false,"Aggressive Warhorn morph", ""},
    ["Barrier_Morph"]               = {false,"Barrier morph", ""},
    ["HealingSprings_Morph"]        = {false,"Healing Springs morph", ""},
    ["RadiatingRegeneration_Morph"] = {false,"Radiating Regeneration morph", ""},
    ["Guard_Morph"]                 = {false,"Guard morph", ""},
    ["SteadfastWard_Morph"]         = {false,"Steadfast Ward morph", ""},

    ["BRPResto_Skill"]              = {false,"No BRP resto skill", ""},
    ["MAResto_Skill"]               = {false,"No MA resto skill", ""},
    ["DSAResto_Skill"]              = {false,"No DSA resto skill", ""},
    ["MADestro_Skill"]              = {false,"No MA destro skill", ""},

    ["MissingOneFivePieceSet"]      = {false,"Miss 5 set bonus", ""},
    ["MissingTwoFivePieceSets"]     = {false,"No 5 set bonuses", ""},
    ["MissingTopSet"]               = {false,"No head/shoulder bonus", ""},

    ["ROJOProcShort"]               = {false,"ROJO low duration", ""},

    ["DungeonROJO"]                 = {false,"4man ROJO", ""},
    ["ROwoJO"]                      = {false,"Trial RO w/o JO", ""},
    ["Onebar_Jorvulds"]             = {false,"One bar Jorvulds", ""},

    ["PA_Skill"]                    = {false,"No PA skill", ""},
    ["Olo_Skill"]                   = {false,"No Olorime skill", ""},

    ["Backbar_SPC"]                 = {false,"Back bar SPC", ""},
    ["Onebar_SPC"]                  = {false,"One bar SPC", ""},
    ["Split_Ultisets"]              = {false,"Split Ulti sets", ""},


    ["MinorSorcery_Skill"]          = {false,"No Minor Sorcery skill", ""},
    ["MinorBrutality_Skill"]        = {false,"No Minor Brutality skill", ""},
    ["MinorProphecy_Skill"]         = {false,"No Minor Prophecy skill", ""},

    ["Oakensoul"]                   = {false,"Remove Oakensoul", ""},

    ["Hud_Edge"]                    = {false,"Action Bar too close to edge of screen", ""},

    ["FancyActionBar"]              = {false,"Missing Addon Fancy Action Bar", ""},

-- lower messages in this list appear first in the UI
}


function HealerHelper.setMessage(message, status, extra)
    if HealerHelper.healerCombatMessages[message]~= nil then
        HealerHelper.healerCombatMessages[message][1]= status
        if extra ~= nil and status then
            HealerHelper.healerCombatMessages[message][3]= extra
        else
            HealerHelper.healerCombatMessages[message][3]= ""
        end
    elseif HealerHelper.healerGearMessages[message]~= nil then
        HealerHelper.healerGearMessages[message][1]= status
        if extra ~= nil and status then
            HealerHelper.healerGearMessages[message][3]= extra
        else
            HealerHelper.healerGearMessages[message][3]= ""
        end
    else
        d("HH Error Message not found: ".. message)
    end
end

function HealerHelper.doMessageUI()


    if HealerHelper.manuallyShowUi then
         for i = 1, HealerHelper.MAX_NUMBER_OF_COMBAT_MESSAGES do
             local messageUi = _G["HealerHelperCombatMessageFrameMessage" .. i]
             messageUi:SetText("Combat Message "..i)
             messageUi:SetHidden(false)
        end
         for i = 1, HealerHelper.MAX_NUMBER_OF_GEAR_MESSAGES do
             local messageUi = _G["HealerHelperGearMessageFrameMessage" .. i]
             messageUi:SetText("Build Message "..i)
             messageUi:SetHidden(false)
        end
    else

        local messageNumber = 0
        for k, v in pairs(HealerHelper.healerCombatMessages ) do
            if v[1] == true then
                messageNumber = messageNumber + 1
                if  messageNumber <= HealerHelper.MAX_NUMBER_OF_COMBAT_MESSAGES then
                    --d("found "..v[2])
                    local messageUi = _G["HealerHelperCombatMessageFrameMessage" .. messageNumber]
                    messageUi:SetText(v[2]..v[3])
                    messageUi:SetHidden(false)
                end
            end
        end
        if messageNumber< HealerHelper.MAX_NUMBER_OF_COMBAT_MESSAGES then
            for i = messageNumber+1, HealerHelper.MAX_NUMBER_OF_COMBAT_MESSAGES do
                --d("i = "..i)
                local messageUi = _G["HealerHelperCombatMessageFrameMessage" .. i]
                messageUi:SetHidden(true)
            end
        end

        local gearMessageNumber = 0
        for k, v in pairs(HealerHelper.healerGearMessages ) do
            if v[1] == true then
                gearMessageNumber = gearMessageNumber + 1
                if  gearMessageNumber <= HealerHelper.MAX_NUMBER_OF_GEAR_MESSAGES then
                    --d("found "..v[2])
                    local messageUi = _G["HealerHelperGearMessageFrameMessage" .. gearMessageNumber]
                    messageUi:SetText(v[2]..v[3])
                    messageUi:SetHidden(false)
                end
            end
        end
        if gearMessageNumber< HealerHelper.MAX_NUMBER_OF_GEAR_MESSAGES then
            for i = gearMessageNumber+1, HealerHelper.MAX_NUMBER_OF_GEAR_MESSAGES do
                --d("i = "..i)
                local messageUi = _G["HealerHelperGearMessageFrameMessage" .. i]
                messageUi:SetHidden(true)
            end
        end
    end
    HealerHelperCombatMessageFrame:SetHidden(false)
    HealerHelperGearMessageFrame:SetHidden(false)
end