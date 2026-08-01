-- Create namespace
DsRGuildPvPKeepInfo = {}
local DsRGuildPvPKeepInfo = DsRGuildPvPKeepInfo  or {}

DsRGuildPvPKeepInfo.name = "DsRGuildPvPKeepInfo"

local Animation = LibAnimation
local wm        = WINDOW_MANAGER

DsRGuildPvPKeepInfo.hiddenShortly = false

-------------------------------------------------------------------------------------------------------------------------------------------------
local Textures = {
    ["Alliance"] = {
        [1] = {
            ["SiegeWeapon"]         = "DsRGuildHall/misc/siege_aldmeri.dds",
            ["Keep"]                = "esoui/art/mappins/ava_largekeep_aldmeri.dds",
            ["KeepNeutral"]         = "esoui/art/mappins/ava_largekeep_neutral.dds",
            ["Outpost"]             = "esoui/art/mappins/ava_outpost_aldmeri.dds",
            ["Town"]                = "esoui/art/mappins/ava_town_aldmeri.dds",
            ["UnderAttack"]         = "esoui/art/mappins/ava_attackburst_64.dds",
            ["Mine"]                = "esoui/art/compass/ava_mine_aldmeri.dds",
            ["MineNeutral"]         = "esoui/art/compass/ava_mine_neutral.dds",
            ["Farm"]                = "esoui/art/compass/ava_farm_aldmeri.dds",
            ["FarmNeutral"]         = "esoui/art/compass/ava_farm_neutral.dds",
            ["Lumber"]              = "esoui/art/compass/ava_lumbermill_aldmeri.dds",
            ["LumberNeutral"]       = "esoui/art/compass/ava_lumbermill_neutral.dds",
        },

        [2] = {
            ["SiegeWeapon"]         = "DsRGuildHall/misc/siege_ebonheart.dds",
            ["Keep"]                = "esoui/art/mappins/ava_largekeep_ebonheart.dds",
            ["KeepNeutral"]         = "esoui/art/mappins/ava_largekeep_neutral.dds",
            ["Outpost"]             = "esoui/art/mappins/ava_outpost_ebonheart.dds",
            ["Town"]                = "esoui/art/mappins/ava_town_ebonheart.dds",
            ["UnderAttack"]         = "esoui/art/mappins/ava_attackburst_64.dds",
            ["Mine"]                = "esoui/art/compass/ava_mine_ebonheart.dds",
            ["MineNeutral"]         = "esoui/art/compass/ava_mine_neutral.dds",
            ["Farm"]                = "esoui/art/compass/ava_farm_ebonheart.dds",
            ["FarmNeutral"]         = "esoui/art/compass/ava_farm_neutral.dds",
            ["Lumber"]              = "esoui/art/compass/ava_lumbermill_ebonheart.dds",
            ["LumberNeutral"]       = "esoui/art/compass/ava_lumbermill_neutral.dds",
        },

        [3] = {
            ["SiegeWeapon"]         = "DsRGuildHall/misc/siege_daggerfall.dds",
            ["Keep"]                = "esoui/art/mappins/ava_largekeep_daggerfall.dds",
            ["KeepNeutral"]         = "esoui/art/mappins/ava_largekeep_neutral.dds",
            ["Outpost"]             = "esoui/art/mappins/ava_outpost_daggerfall.dds",
            ["Town"]                = "esoui/art/mappins/ava_town_daggerfall.dds",
            ["UnderAttack"]         = "esoui/art/mappins/ava_attackburst_64.dds",
            ["Mine"]                = "esoui/art/compass/ava_mine_daggerfall.dds",
            ["MineNeutral"]         = "esoui/art/compass/ava_mine_neutral.dds",
            ["Farm"]                = "esoui/art/compass/ava_farm_daggerfall.dds",
            ["FarmNeutral"]         = "esoui/art/compass/ava_farm_neutral.dds",
            ["Lumber"]              = "esoui/art/compass/ava_lumbermill_daggerfall.dds",
            ["LumberNeutral"]       = "esoui/art/compass/ava_lumbermill_neutral.dds",
        },
    }
}

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPKeepInfo:Initialize_UI()
    local width_mini = 250

    DsRGuildPvPKeepInfo.UI = wm:CreateTopLevelWindow("DsRGuildPvPKeepInfoWindow")
    DsRGuildPvPKeepInfo.UI:SetDimensions(width_mini, 100)
    DsRGuildPvPKeepInfo.UI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, DsRGuildPvP.pvp.PvPKeepInfoUI.X,DsRGuildPvP.pvp.PvPKeepInfoUI.Y)
    DsRGuildPvPKeepInfo.UI:SetMouseEnabled(true)
    DsRGuildPvPKeepInfo.UI:SetMovable(true)
    DsRGuildPvPKeepInfo.UI:SetAlpha(0)
    DsRGuildPvPKeepInfo.UI:SetClampedToScreen(true)
    DsRGuildPvPKeepInfo.UI:SetHandler('OnMoveStop', function()
        DsRGuildPvP.pvp.PvPKeepInfoUI.X = DsRGuildPvPKeepInfo.UI:GetLeft()
        DsRGuildPvP.pvp.PvPKeepInfoUI.Y = DsRGuildPvPKeepInfo.UI:GetTop()
    end)
 
    DsRGuildPvPKeepInfo.UI_BG = wm:CreateControl("DsRGuildPvPKeepInfoUI_BG", DsRGuildPvPKeepInfo.UI, CT_TEXTURE) 
    DsRGuildPvPKeepInfo.UI_BG:SetParent(DsRGuildPvPKeepInfo.UI)
    DsRGuildPvPKeepInfo.UI_BG:SetTexture('DsRGuildHall/misc/loothistory_highlight.dds')
    DsRGuildPvPKeepInfo.UI_BG:SetDimensions(width_mini, 100)
    DsRGuildPvPKeepInfo.UI_BG:SetAnchor(LEFT, DsRGuildPvPKeepInfo.UI, LEFT, 0, 0)

    local keepID       = DsRGuildPvPPlayerPos:getNearestKeep(AREATYPE_SQUARE, 0.040,{CKEEPTYPE_KEEP,CKEEPTYPE_KEEP_OUTPOST,CKEEPTYPE_KEEP_TOWN})
    local keepAlliance = GetKeepAlliance(keepID, DsRGuildPvPPlayerPos:getBattlegroundContext())
    local keeptype     = DsRGuildPvPPlayerPos:getKeepType(keepID)

    local keepRessourceID       = DsRGuildPvPPlayerPos:getNearestKeep(AREATYPE_SQUARE, 0.040,{CKEEPTYPE_KEEP_RESSOURCE})
    local keepRessourceAlliance = GetKeepAlliance(keepRessourceID, DsRGuildPvPPlayerPos:getBattlegroundContext())
    
    local Farm   = GetResourceKeepForKeep(keepID, RESOURCETYPE_FOOD) -- Farm
    local Lumber = GetResourceKeepForKeep(keepID, RESOURCETYPE_WOOD) -- Lumber
    local Mine   = GetResourceKeepForKeep(keepID, RESOURCETYPE_ORE)  -- Mine

    local FarmAlliance   = GetKeepAlliance(Farm, DsRGuildPvPPlayerPos:getBattlegroundContext())
    local LumberAlliance = GetKeepAlliance(Lumber, DsRGuildPvPPlayerPos:getBattlegroundContext())
    local MineAlliance   = GetKeepAlliance(Mine, DsRGuildPvPPlayerPos:getBattlegroundContext())

    DsRGuildPvPKeepInfo.KeepIconAttack = wm:CreateControl("KeepPosInfosUI_KeepIconAttack", DsRGuildPvPKeepInfo.UI, CT_TEXTURE) 
    DsRGuildPvPKeepInfo.KeepIconAttack:SetParent(DsRGuildPvPKeepInfo.UI)
    if keepAlliance == 0 then
        DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[2].KeepNeutral)
    elseif keeptype == 1 then
        DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[keepAlliance].Keep)
    elseif keeptype == 2 then
        DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[keepAlliance].Outpost)
    elseif keeptype == 4 then
        DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[keepAlliance].Town)
    end
    DsRGuildPvPKeepInfo.KeepIconAttack:SetDimensions(64,64);
    DsRGuildPvPKeepInfo.KeepIconAttack:SetAnchor(TOPLEFT, DsRGuildPvPKeepInfo.UI, TOPLEFT, -10, -10)

    DsRGuildPvPKeepInfo.KeepIcon = wm:CreateControl("KeepPosInfosUI_KeepIcon", DsRGuildPvPKeepInfo.UI, CT_TEXTURE) 
    DsRGuildPvPKeepInfo.KeepIcon:SetParent(DsRGuildPvPKeepInfo.UI)
    if keepAlliance == 0 then
        DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[2].KeepNeutral)
    elseif keeptype == 1 then
        DsRGuildPvPKeepInfo.KeepIcon:SetTexture(Textures.Alliance[keepAlliance].Keep)
    elseif keeptype == 2 then
        DsRGuildPvPKeepInfo.KeepIcon:SetTexture(Textures.Alliance[keepAlliance].Outpost)
    elseif keeptype == 4 then
        DsRGuildPvPKeepInfo.KeepIcon:SetTexture(Textures.Alliance[keepAlliance].Town)
    end
    DsRGuildPvPKeepInfo.KeepIcon:SetDimensions(64,64);
    DsRGuildPvPKeepInfo.KeepIcon:SetAnchor(TOPLEFT, DsRGuildPvPKeepInfo.UI, TOPLEFT, -10, -10)

    DsRGuildPvPKeepInfo.KeepLabel = wm:CreateControl("KeepPosInfosUI_KeepLabel", DsRGuildPvPKeepInfo.UI, CT_LABEL) 
    DsRGuildPvPKeepInfo.KeepLabel:SetParent(DsRGuildPvPKeepInfo.UI)
    DsRGuildPvPKeepInfo.KeepLabel:SetFont('EsoUi/Common/Fonts/Univers67.otf|22|soft-shadow-thick')
    DsRGuildPvPKeepInfo.KeepLabel:SetText('Unknown Keep')
    DsRGuildPvPKeepInfo.KeepLabel:SetAnchor(LEFT, DsRGuildPvPKeepInfo.KeepIcon, LEFT, 55, 0)

    DsRGuildPvPKeepInfo.KeepMineIcon = wm:CreateControl("KeepPosInfosUI_KeepMineIcon", DsRGuildPvPKeepInfo.UI, CT_TEXTURE) 
    DsRGuildPvPKeepInfo.KeepMineIcon:SetParent(DsRGuildPvPKeepInfo.UI)
    if keepRessourceAlliance == 0 then
        DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[2].MineNeutral)
    elseif MineAlliance == nil or MineAlliance == 0 then
        DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[2].MineNeutral)
    else
        DsRGuildPvPKeepInfo.KeepMineIcon:SetTexture(Textures.Alliance[MineAlliance].Mine)
    end
    DsRGuildPvPKeepInfo.KeepMineIcon:SetDimensions(20,20)
    DsRGuildPvPKeepInfo.KeepMineIcon:SetAnchor(BOTTOMLEFT, DsRGuildPvPKeepInfo.KeepIcon, BOTTOMLEFT, 23, 5)

    DsRGuildPvPKeepInfo.KeepFarmIcon = wm:CreateControl("KeepPosInfosUI_KeepFarmIcon", DsRGuildPvPKeepInfo.UI, CT_TEXTURE) 
    DsRGuildPvPKeepInfo.KeepFarmIcon:SetParent(DsRGuildPvPKeepInfo.UI)
    if keepRessourceAlliance == 0 then
        DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[2].FarmNeutral)
    elseif FarmAlliance == nil or FarmAlliance == 0 then
        DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[2].FarmNeutral)
    else
        DsRGuildPvPKeepInfo.KeepFarmIcon:SetTexture(Textures.Alliance[FarmAlliance].Farm)
    end
    DsRGuildPvPKeepInfo.KeepFarmIcon:SetDimensions(20,20)
    DsRGuildPvPKeepInfo.KeepFarmIcon:SetAnchor(LEFT, DsRGuildPvPKeepInfo.KeepMineIcon, LEFT, -12, 15)

    DsRGuildPvPKeepInfo.KeepLumberIcon = wm:CreateControl("KeepPosInfosUI_KeepLumberIcon", DsRGuildPvPKeepInfo.UI, CT_TEXTURE) 
    DsRGuildPvPKeepInfo.KeepLumberIcon:SetParent(DsRGuildPvPKeepInfo.UI)
    if keepRessourceAlliance == 0 then
        DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[2].LumberNeutral)
    elseif LumberAlliance == nil or LumberAlliance == 0 then
        DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[2].LumberNeutral)
    else
        DsRGuildPvPKeepInfo.KeepLumberIcon:SetTexture(Textures.Alliance[LumberAlliance].Lumber)
    end
    DsRGuildPvPKeepInfo.KeepLumberIcon:SetDimensions(20,20)
    DsRGuildPvPKeepInfo.KeepLumberIcon:SetAnchor(LEFT, DsRGuildPvPKeepInfo.KeepFarmIcon, LEFT, 24, 0)
    
    DsRGuildPvPKeepInfo.KeepSiegeAD = wm:CreateControl("KeepPosInfosUI_KeepSiegeAD", DsRGuildPvPKeepInfo.KeepIcon, CT_TEXTURE) 
    DsRGuildPvPKeepInfo.KeepSiegeAD:SetParent(DsRGuildPvPKeepInfo.UI)
    DsRGuildPvPKeepInfo.KeepSiegeAD:SetTexture(Textures.Alliance[1].SiegeWeapon)
    DsRGuildPvPKeepInfo.KeepSiegeAD:SetDimensions(32,32);
    DsRGuildPvPKeepInfo.KeepSiegeAD:SetAnchor(LEFT, DsRGuildPvPKeepInfo.KeepLabel, LEFT, 15, 33)

    DsRGuildPvPKeepInfo.KeepSiegeADLabel = wm:CreateControl("KeepPosInfosUI_KeepSiegeADLabel", DsRGuildPvPKeepInfo.KeepSiegeAD, CT_LABEL) 
    DsRGuildPvPKeepInfo.KeepSiegeADLabel:SetParent(DsRGuildPvPKeepInfo.UI)
    DsRGuildPvPKeepInfo.KeepSiegeADLabel:SetFont('EsoUi/Common/Fonts/Univers67.otf|16|soft-shadow-thick')
    DsRGuildPvPKeepInfo.KeepSiegeADLabel:SetText('0')
    DsRGuildPvPKeepInfo.KeepSiegeADLabel:SetAnchor(LEFT, DsRGuildPvPKeepInfo.KeepSiegeAD, LEFT, 30, 0)

    DsRGuildPvPKeepInfo.KeepSiegeEP = wm:CreateControl("KeepPosInfosUI_KeepSiegeEP", DsRGuildPvPKeepInfo.KeepIcon, CT_TEXTURE) 
    DsRGuildPvPKeepInfo.KeepSiegeEP:SetParent(DsRGuildPvPKeepInfo.UI)
    DsRGuildPvPKeepInfo.KeepSiegeEP:SetTexture(Textures.Alliance[2].SiegeWeapon)
    DsRGuildPvPKeepInfo.KeepSiegeEP:SetDimensions(32,32);
    DsRGuildPvPKeepInfo.KeepSiegeEP:SetAnchor(LEFT, DsRGuildPvPKeepInfo.KeepSiegeAD, LEFT, 50, 0)

    DsRGuildPvPKeepInfo.KeepSiegeEPLabel = wm:CreateControl("KeepPosInfosUI_KeepSiegeEPLabel", DsRGuildPvPKeepInfo.KeepSiegeEP, CT_LABEL) 
    DsRGuildPvPKeepInfo.KeepSiegeEPLabel:SetParent(DsRGuildPvPKeepInfo.UI)
    DsRGuildPvPKeepInfo.KeepSiegeEPLabel:SetFont('EsoUi/Common/Fonts/Univers67.otf|16|soft-shadow-thick')
    DsRGuildPvPKeepInfo.KeepSiegeEPLabel:SetText('0')
    DsRGuildPvPKeepInfo.KeepSiegeEPLabel:SetAnchor(LEFT, DsRGuildPvPKeepInfo.KeepSiegeEP, LEFT, 30, 0)

    DsRGuildPvPKeepInfo.KeepSiegeDC = wm:CreateControl("KeepPosInfosUI_KeepSiegeDC", DsRGuildPvPKeepInfo.KeepIcon, CT_TEXTURE) 
    DsRGuildPvPKeepInfo.KeepSiegeDC:SetParent(DsRGuildPvPKeepInfo.UI)
    DsRGuildPvPKeepInfo.KeepSiegeDC:SetTexture(Textures.Alliance[3].SiegeWeapon)
    DsRGuildPvPKeepInfo.KeepSiegeDC:SetDimensions(32,32);
    DsRGuildPvPKeepInfo.KeepSiegeDC:SetAnchor(LEFT, DsRGuildPvPKeepInfo.KeepSiegeEP, LEFT, 50, 0)

    DsRGuildPvPKeepInfo.KeepSiegeDCLabel = wm:CreateControl("KeepPosInfosUI_KeepSiegeDCLabel", DsRGuildPvPKeepInfo.KeepSiegeDC, CT_LABEL) 
    DsRGuildPvPKeepInfo.KeepSiegeDCLabel:SetParent(DsRGuildPvPKeepInfo.UI)
    DsRGuildPvPKeepInfo.KeepSiegeDCLabel:SetFont('EsoUi/Common/Fonts/Univers67.otf|16|soft-shadow-thick')
    DsRGuildPvPKeepInfo.KeepSiegeDCLabel:SetText('0')
    DsRGuildPvPKeepInfo.KeepSiegeDCLabel:SetAnchor(LEFT, DsRGuildPvPKeepInfo.KeepSiegeDC, LEFT, 30, 0)

    DsRGuildPvPKeepInfo:checkKeep()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPKeepInfo:checkKeep()
    local UpdateTimer = tonumber(DsRGuildPvP.pvp.PvPKeepInfoUpdate) * 1000

    zo_callLater(function() DsRGuildPvPKeepInfo:checkKeep() end, UpdateTimer) 
    
    local keepID       = DsRGuildPvPPlayerPos:getNearestKeep(AREATYPE_SQUARE, 0.040,{CKEEPTYPE_KEEP,CKEEPTYPE_KEEP_OUTPOST,CKEEPTYPE_KEEP_TOWN})
    local keepAlliance = GetKeepAlliance(keepID, DsRGuildPvPPlayerPos:getBattlegroundContext())
    local keeptype     = DsRGuildPvPPlayerPos:getKeepType(keepID)

    local Farm   = GetResourceKeepForKeep(keepID, RESOURCETYPE_FOOD) -- Farm
    local Lumber = GetResourceKeepForKeep(keepID, RESOURCETYPE_WOOD) -- Lumber
    local Mine   = GetResourceKeepForKeep(keepID, RESOURCETYPE_ORE) -- Mine

    local FarmAlliance   = GetKeepAlliance(Farm, DsRGuildPvPPlayerPos:getBattlegroundContext())
    local LumberAlliance = GetKeepAlliance(Lumber, DsRGuildPvPPlayerPos:getBattlegroundContext())
    local MineAlliance   = GetKeepAlliance(Mine, DsRGuildPvPPlayerPos:getBattlegroundContext())

    if IsInCyrodiil() == false then
        local anim = Animation:New(DsRGuildPvPKeepInfoWindow)
        anim:AlphaTo( 0, 2000 )
        anim:Play()
        zo_callLater(function()
            if keepAlliance == 0 then
                DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[2].KeepNeutral)
            elseif keeptype == 1 then
                DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[keepAlliance].Keep)
            elseif keeptype == 2 then
                DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[keepAlliance].Outpost)
            elseif keeptype == 4 then
                DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[keepAlliance].Town)
            end
            if keepAlliance == 0 then
                DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[2].KeepNeutral)
            elseif keeptype == 1 then
                DsRGuildPvPKeepInfo.KeepIcon:SetTexture(Textures.Alliance[keepAlliance].Keep)
            elseif keeptype == 2 then
                DsRGuildPvPKeepInfo.KeepIcon:SetTexture(Textures.Alliance[keepAlliance].Outpost)
            elseif keeptype == 4 then
                DsRGuildPvPKeepInfo.KeepIcon:SetTexture(Textures.Alliance[keepAlliance].Town)
            end
            if MineAlliance == 0 then
                DsRGuildPvPKeepInfo.KeepMineIcon:SetTexture(Textures.Alliance[2].MineNeutral)
            else
                DsRGuildPvPKeepInfo.KeepMineIcon:SetTexture(Textures.Alliance[MineAlliance].Mine)
            end                
            if FarmAlliance == 0 then
                DsRGuildPvPKeepInfo.KeepFarmIcon:SetTexture(Textures.Alliance[2].FarmNeutral)
            else
                DsRGuildPvPKeepInfo.KeepFarmIcon:SetTexture(Textures.Alliance[FarmAlliance].Farm)
            end            
            if LumberAlliance == 0 then
                DsRGuildPvPKeepInfo.KeepLumberIcon:SetTexture(Textures.Alliance[2].LumberNeutral)
            else
                DsRGuildPvPKeepInfo.KeepLumberIcon:SetTexture(Textures.Alliance[LumberAlliance].Lumber)
            end
            DsRGuildPvPKeepInfo.KeepLabel:SetText('Unknown Keep')
            DsRGuildPvPKeepInfo.KeepSiegeADLabel:SetText('0')
            DsRGuildPvPKeepInfo.KeepSiegeEPLabel:SetText('0')
            DsRGuildPvPKeepInfo.KeepSiegeDCLabel:SetText('0')
        end, 2000)		
        return
    end
    if IsInCyrodiil() == true then
        if keepID > 0 then
            local width_mini = 250
            local final_width = 0
            local anim = Animation:New(DsRGuildPvPKeepInfoWindow)
            anim:AlphaTo( 1, 2000 )
            anim:Play()
            local keepName = zo_strformat("<<1>>", GetKeepName(keepID))
            local keepName = zo_strgsub(keepName , "die " , "" )        
            local keepName = zo_strgsub(keepName , "der " , "" )        
            local keepName = zo_strgsub(keepName , "das " , "" )        
            local keepName = zo_strgsub(keepName , "the " , "" )

            local Width = string.len(keepName) + 25
            if Width < width_mini then
                Width = width_mini
            end

            DsRGuildPvPKeepInfo.UI:SetDimensions(Width, 100)

            DsRGuildPvPKeepInfo.UI_BG:SetDimensions(Width, 100)
            
            local color = {}
            if keepAlliance == 1 then
                color = DsRGuildPvP.Acol.DsRColorad
            elseif keepAlliance == 2 then
                color = DsRGuildPvP.Acol.DsRColorep
            elseif keepAlliance == 3 then
                color = DsRGuildPvP.Acol.DsRColordc
            else
                color = DsRGuildPvP.Acol.DsRColornoAlliance
            end
            DsRGuildPvPKeepInfo.UI_BG:SetColor(color.r, color.g, color.b, 1.3)

            if DsRGuildPvP.pvp.PvPKeepInfoBGtrans then
                DsRGuildPvPKeepInfo.UI_BG:SetHidden(true)
            else
                DsRGuildPvPKeepInfo.UI_BG:SetHidden(false)
            end

            local CountSiege = {}
            CountSiege["Aldmeri"]    = GetNumSieges(keepID, DsRGuildPvPPlayerPos:getBattlegroundContext(), 1)
            CountSiege["Ebonheart"]  = GetNumSieges(keepID, DsRGuildPvPPlayerPos:getBattlegroundContext(), 2)
            CountSiege["Daggerfall"] = GetNumSieges(keepID, DsRGuildPvPPlayerPos:getBattlegroundContext(), 3)

            DsRGuildPvPKeepInfo.KeepLabel:SetText(keepName)
            if GetKeepUnderAttack(keepID, DsRGuildPvPPlayerPos:getBattlegroundContext()) then
                DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[keepAlliance].UnderAttack)
                if keeptype == 1 then
                    DsRGuildPvPKeepInfo.KeepIcon:SetTexture(Textures.Alliance[keepAlliance].Keep)
                elseif keeptype == 2 then
                    DsRGuildPvPKeepInfo.KeepIcon:SetTexture(Textures.Alliance[keepAlliance].Outpost)
                elseif keeptype == 4 then
                    DsRGuildPvPKeepInfo.KeepIcon:SetTexture(Textures.Alliance[keepAlliance].Town)
                end
            else
                if keeptype == 1 then
                    DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[keepAlliance].Keep)
                    DsRGuildPvPKeepInfo.KeepIcon:SetTexture(Textures.Alliance[keepAlliance].Keep)
                elseif keeptype == 2 then
                    DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[keepAlliance].Outpost)
                    DsRGuildPvPKeepInfo.KeepIcon:SetTexture(Textures.Alliance[keepAlliance].Outpost)
                elseif keeptype == 4 then
                    DsRGuildPvPKeepInfo.KeepIconAttack:SetTexture(Textures.Alliance[keepAlliance].Town)
                    DsRGuildPvPKeepInfo.KeepIcon:SetTexture(Textures.Alliance[keepAlliance].Town)
                end
            end
            if keeptype ~= 1 then
                DsRGuildPvPKeepInfo.KeepMineIcon:SetHidden(true)
            else
                DsRGuildPvPKeepInfo.KeepMineIcon:SetHidden(false)
                if MineAlliance == 0 then
                    DsRGuildPvPKeepInfo.KeepMineIcon:SetTexture(Textures.Alliance[2].MineNeutral)
                else
                    DsRGuildPvPKeepInfo.KeepMineIcon:SetTexture(Textures.Alliance[MineAlliance].Mine)
                end
            end                
            if keeptype ~= 1 then
                DsRGuildPvPKeepInfo.KeepFarmIcon:SetHidden(true)
            else
                DsRGuildPvPKeepInfo.KeepFarmIcon:SetHidden(false)
                if FarmAlliance == 0 then
                    DsRGuildPvPKeepInfo.KeepFarmIcon:SetTexture(Textures.Alliance[2].FarmNeutral)
                else
                    DsRGuildPvPKeepInfo.KeepFarmIcon:SetTexture(Textures.Alliance[FarmAlliance].Farm)
                end
            end            
            if keeptype ~= 1 then
                DsRGuildPvPKeepInfo.KeepLumberIcon:SetHidden(true)
            else
                DsRGuildPvPKeepInfo.KeepLumberIcon:SetHidden(false)
                if LumberAlliance == 0 then
                    DsRGuildPvPKeepInfo.KeepLumberIcon:SetTexture(Textures.Alliance[2].LumberNeutral)
                else
                    DsRGuildPvPKeepInfo.KeepLumberIcon:SetTexture(Textures.Alliance[LumberAlliance].Lumber)
                end
            end
            DsRGuildPvPKeepInfo.KeepSiegeADLabel:SetText(CountSiege["Aldmeri"])
            DsRGuildPvPKeepInfo.KeepSiegeEPLabel:SetText(CountSiege["Ebonheart"])
            DsRGuildPvPKeepInfo.KeepSiegeDCLabel:SetText(CountSiege["Daggerfall"])
        else
            local anim = Animation:New(DsRGuildPvPKeepInfoWindow)
            anim:AlphaTo( 0, 2000 )
            anim:Play()
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPKeepInfo:SetHiddenShortly(hidden)
    DsRGuildPvPKeepInfo.hiddenShortly = hidden

    if GetInteractionType() == INTERACTION_SIEGE then return end

    if DsRGuildPvPKeepInfo.hiddenShortly then
        DsRGuildPvPKeepInfo.UI:SetHidden(true)
    else
        DsRGuildPvPKeepInfo.UI:SetHidden(false)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- On addon loaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPKeepInfo.OnAddonLoaded(event, name)
    EVENT_MANAGER:UnregisterForEvent (DsRGuildPvPKeepInfo.name , EVENT_ADD_ON_LOADED )

    if DsRGuildPvP.pvp.PvPKeepInfoOnOff then return end

    -- -- hide listeners
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function()
        DsRGuildPvPKeepInfo:SetHiddenShortly(true)
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function()
        DsRGuildPvPKeepInfo:SetHiddenShortly(true)
    end)
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function()
        DsRGuildPvPKeepInfo:SetHiddenShortly(true)
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function()
        DsRGuildPvPKeepInfo:SetHiddenShortly(true)
    end)

    -- -- show listeners
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function()
        DsRGuildPvPKeepInfo:SetHiddenShortly(false)
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnHide", function()
        DsRGuildPvPKeepInfo:SetHiddenShortly(false)
    end)
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnHide", function()
        DsRGuildPvPKeepInfo:SetHiddenShortly(false)
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function()
        DsRGuildPvPKeepInfo:SetHiddenShortly(false)
    end)

    DsRGuildPvPKeepInfo:Initialize_UI()
end
