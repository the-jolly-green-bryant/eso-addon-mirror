DsRslashcmd    = DsRslashcmd or {}

local LSC      = LibSlashCommander

function DsRslashcmd.createSlashCommands()
    LSC:Register("/dsr"            , function() DsR.Menu.Open() end                                 , GetString(DsRGuildcmd_settings))
    LSC:Register("/dsrinventory"   , function() IA_InventoryAssistant:ToggleWindow ( true ) end     , GetString(DsRGuildcmd_inventory))
    LSC:Register("/dsrbind"        , function() DsRGuildBind.Binding.BindAllUnknown() end           , GetString(DsRGuildcmd_binding))
    LSC:Register("/dsrpost"        , function() DsRGuildBind.Post.PostAllUnbounted() end            , GetString(DsRGuildcmd_post))
    LSC:Register("/dsrport"        , function() DsRGuildPvP.StartChatTelVarPort() end               , GetString(DsRGuildcmd_port))
   
    LSC:Register("/dsrcraftclear"  , function() DsRGuildPrecrafterQueue:Clear() end                 , GetString(DsRGuildCrafting_PrecraftCMDrem))

    LSC:Register("/dsrcraft"  , function(args)
        local bagSpace   = GetNumBagFreeSlots(BAG_BACKPACK)
        local QUEUE_SIZE = 37 -- Mindestzahl an Platz im Inventar. Entspricht 1 Rotation!!
        if bagSpace < QUEUE_SIZE then
            d(GetString(DsRGuildCrafting_PrecraftNoInvSpace))
            return
        end
        DsRGuildPrecrafter:GetMultiplierAndQueue(args, bagSpace)
    end, GetString(DsRGuildCrafting_PrecraftCMDadd))

    LSC:Register("/dsrstart", function (districtId)
        if districtId == nil then 
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Error")
            return 
        end
        DsRGuildPvPBossTimer.markDistrict(tonumber(districtId))
    end, GetString(DsRPvPBossTimer_StartManu))

    LSC:Register("/dsrdeathwindow"   , function() DsRGuildDeathTable.ToggleWindow ( true ) end     , GetString(DsRGuildcmd_deathwindow))
    LSC:Register("/dsrdeathreset"    , function() DsRGuildDeathTable.resetTable() end              , GetString(DsRGuildcmd_deathreset))
    LSC:Register("/dsrdeathpost"     , function() DsRGuildDeathTable.postDeath() end               , GetString(DsRGuildcmd_deathpost))
    
    LSC:Register("/dsrrepair"         , function() DsRGuildPersonalRepair.RepairItemsWithKits("99") end    , GetString(DsRGuildcmd_repair))
    LSC:Register("/dsrrecharge"       , function() DsRGuildPersonalRepair.RechargeItemsWithGems("99") end  , GetString(DsRGuildcmd_recharge))
    LSC:Register("/dsrrepairrecharge" , function() DsRGuildPersonalRepair.RepairRecharge("99") end         , GetString(DsRGuildcmd_repairandrecharge))

    LSC:Register("/dsraddonupdate"   , function() DsRVersion_Updated:SetHidden(false) end , GetString(DsRGuildcmd_addonupdate))

    LSC:Register("/dsrbuff"   , function() DsRGuildBuffSetting:Show() end , GetString(DsRGuildcmd_buff))

    LSC:Register("/dsrattack"   , function() DsRGroupAttackProtocol:SendGroupAttackCountdown() end , GetString(DsRGuildcmd_GroupAttack))
end