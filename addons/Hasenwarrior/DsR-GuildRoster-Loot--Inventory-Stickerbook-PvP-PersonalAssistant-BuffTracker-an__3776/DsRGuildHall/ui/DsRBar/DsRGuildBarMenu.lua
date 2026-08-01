DsRGuildBarMenu = {}
local DsRGuildBarMenu = DsRGuildBarMenu  or {}

DsRGuildBarMenu.name = "DsRGuildBarMenu"

local MenuOptionsBar,MenuPanelBar,MenuHandlersBar={},{},{}
local SettingsBar={}

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildBarMenu:SetupMenueSettings()
    local DsRMenu=DsR and DsR.InternalMenu
    local MenuPanelBar={
        type        ="panel",
        name        =(DsRMenu and "|c9fb6cd18.|r |t28:28:/DsRGuildHall/misc/DsR_Rabenbar.dds|t" or "")..DsR.Localization[DsR.language].IndexBarMenu,
        displayName =(DsRMenu and "|c9fb6cd18.|r |t28:28:/DsRGuildHall/misc/DsR_Rabenbar.dds|t" or "")..DsR.Localization[DsR.language].IndexBarMenu,
        author      ="|cD8F781Has|r|cF3F781enw|r|cF5DA81arr|r|cF7BE81ior|r",
    }
    local MenuOptionsBar={}

    table.insert(MenuOptionsBar, {type="description",name="DsRGuildBarMenu_accsettings",})
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildBarMenu_OnOff",warning="ReloadUiWarn2",
        getFunc=function() return DsRGuildBar.SV.BarOnOff end,
        setFunc=function(val) DsRGuildBar.SV.BarOnOff = val DsR.Menu.HandleReloadUIPressed() end,})
    table.insert(MenuOptionsBar, {type="description",name="",})
    table.insert(MenuOptionsBar, {type="slider",name="DsRGuildBarMenu_RefreshTimer",warning=false,
	    getFunc=function() return DsRGuildBar.SV.BarRefreshTimer end,
	    setFunc=function(val)
            EVENT_MANAGER:UnregisterForUpdate("DsRGuildBarToolbar_Update")
            DsRGuildBar.SV.BarRefreshTimer = val
            local refreshSeconds = DsRGuildBar.SV.BarRefreshTimer * 1000
            EVENT_MANAGER:RegisterForUpdate("DsRGuildBarToolbar_Update", refreshSeconds, DsRGuildBar.Toolbar_Update)
        end,
	    min=1,max=30,step=1,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})    
    table.insert(MenuOptionsBar, {type="slider",name="DsRGuildBarMenu_Scale",warning=false,
	    getFunc=function() return DsRGuildBar.SV.BarScale end,
	    setFunc=function(val) DsRGuildBar.SV.BarScale = val DsRGuildBar.Toolbar_Update() end,
	    min=0.1,max=4,step=0.1,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})   
    table.insert(MenuOptionsBar, {type="slider",name="DsRGuildBarMenu_SpaceOffSet",warning="ReloadUiWarn1",
	    getFunc=function() return DsRGuildBar.SV.BarOffSetX end,
	    setFunc=function(val) DsRGuildBar.SV.BarOffSetX = val DsR.UI.ReloadUIButton() end,
	    min=0,max=10,step=1,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    table.insert(MenuOptionsBar, {type="dropdown",name="DsRGuildBarMenu_PosUPBOT",warning=false,
        choices	 ={DsR_Bar_PosTOP,DsR_Bar_PosBOTTOM},
        getFunc	 =function() return DsRGuildBar.SV.BarPosition end,
        setFunc	 =function(val) DsRGuildBar.SV.BarPosition = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})    
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildBarMenu_MenueHide",warning=false,
        getFunc=function() return DsRGuildBar.SV.BarMenueHide end,
        setFunc=function(val) DsRGuildBar.SV.BarMenueHide = val end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildBarMenu_Background",warning=false,
        getFunc=function() return DsRGuildBar.SV.BarBG end,
        setFunc=function(val) DsRGuildBar.SV.BarBG = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    table.insert(MenuOptionsBar, {type="slider",name="DsRGuildBarMenu_BgTransparent",warning=false,
	    getFunc=function() return DsRGuildBar.SV.BarBGtrans end,
	    setFunc=function(val) DsRGuildBar.SV.BarBGtrans = val DsRGuildBar.Toolbar_Update() end,
	    min=0,max=100,step=1,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    table.insert(MenuOptionsBar, {type="description",name="",})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildBarMenu_OStime",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BarOStime end,
        setFunc	 =function(val) DsRGuildBar.SV.BarOStime = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildBarMenu_Campion",warning=false,
        getFunc=function() return DsRGuildBar.SV.BarCP end,
        setFunc=function(val) DsRGuildBar.SV.BarCP = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildBarMenu_Crowns",warning=false,
        getFunc=function() return DsRGuildBar.SV.BarCrowns end,
        setFunc=function(val) DsRGuildBar.SV.BarCrowns = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    table.insert(MenuOptionsBar, {type="dropdown",name="DsRGuildLoot_gold_gain",
        choices	 ={DsR_Bar_TurnOff,DsR_Bar_Inventory,DsR_Bar_InventoryBank},
        getFunc	 =function() return DsRGuildBar.SV.BarGold end,
        setFunc	 =function(val) DsRGuildBar.SV.BarGold = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildBarMenu_CurrencyXP",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BarshowXP end,
        setFunc	 =function(val) DsRGuildBar.SV.BarshowXP = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="dropdown",name="DsRGuildBarMenu_CurrencyAP",warning=false,
        choices	 ={DsR_Bar_TurnOff,DsR_Bar_Inventory,DsR_Bar_InventoryBank},
        getFunc	 =function() return DsRGuildBar.SV.BarAP end,
        setFunc	 =function(val) DsRGuildBar.SV.BarAP = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="dropdown",name="DsRGuildBarMenu_Bankspace",warning=false,
        choices	 ={DsR_Bar_TurnOff,DsR_Bar_BankUse,DsR_Bar_BankUseMax},
        getFunc	 =function() return DsRGuildBar.SV.BarBankspace end,
        setFunc	 =function(val) DsRGuildBar.SV.BarBankspace = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="dropdown",name="DsRGuildBarMenu_Inventoryspace",warning=false,
        choices	 ={DsR_Bar_TurnOff,DsR_Bar_BankUse,DsR_Bar_BankUseMax},
        getFunc	 =function() return DsRGuildBar.SV.BarInventoryspace end,
        setFunc	 =function(val) DsRGuildBar.SV.BarInventoryspace = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="dropdown",name="DsRGuildBarMenu_CurrencyTelVar",warning=false,
        choices	 ={DsR_Bar_TurnOff,DsR_Bar_Inventory,DsR_Bar_InventoryBank},
        getFunc	 =function() return DsRGuildBar.SV.BarTelVar end,
        setFunc	 =function(val) DsRGuildBar.SV.BarTelVar = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildLoot_undauntedkeys",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BarUndaunted end,
        setFunc	 =function(val) DsRGuildBar.SV.BarUndaunted = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildLoot_transmute_crystals",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BarTransmute end,
        setFunc	 =function(val) DsRGuildBar.SV.BarTransmute = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    -- table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildLoot_event_Tickets",warning=false,
    --     getFunc	 =function() return DsRGuildBar.SV.BarEticket end,
    --     setFunc	 =function(val) DsRGuildBar.SV.BarEticket = val DsRGuildBar.Toolbar_Update() end,
    --     disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildLoot_endeavor",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BarEndeavor end,
        setFunc	 =function(val) DsRGuildBar.SV.BarEndeavor = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildLoot_archival_fortunes",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BarEndless end,
        setFunc	 =function(val) DsRGuildBar.SV.BarEndless = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildBarMenu_TomeChallenge",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BaromeChallenge end,
        setFunc	 =function(val) DsRGuildBar.SV.BaromeChallenge = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildBarMenu_TomePoints",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BarTomePoints end,
        setFunc	 =function(val) DsRGuildBar.SV.BarTomePoints = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildBarMenu_TomePointCach",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BarTomePointCach end,
        setFunc	 =function(val) DsRGuildBar.SV.BarTomePointCach = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildBarMenu_TomeToken",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BarTomeToken end,
        setFunc	 =function(val) DsRGuildBar.SV.BarTomeToken = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildBarMenu_TradeBars",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BarTradeBars end,
        setFunc	 =function(val) DsRGuildBar.SV.BarTradeBars = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildLoot_imperial_fragments",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BarImperialFragements end,
        setFunc	 =function(val) DsRGuildBar.SV.BarImperialFragements = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="dropdown",name="DsRGuildBarMenu_writvoucher",warning=false,
        choices	 ={DsR_Bar_TurnOff,DsR_Bar_Inventory,DsR_Bar_InventoryBank},
        getFunc	 =function() return DsRGuildBar.SV.BarWritvoucher end,
        setFunc	 =function(val) DsRGuildBar.SV.BarWritvoucher = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildPersonal_Repairkit",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BarRepairKits end,
        setFunc	 =function(val) DsRGuildBar.SV.BarRepairKits = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildBarMenu_SoulGem",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BarSoulGems end,
        setFunc	 =function(val) DsRGuildBar.SV.BarSoulGems = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildBarMenu_LockPick",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BarLockpicks end,
        setFunc	 =function(val) DsRGuildBar.SV.BarLockpicks = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})
    ---------
    table.insert(MenuOptionsBar, {type="checkbox",name="DsRGuildBarMenu_Stolen",warning=false,
        getFunc	 =function() return DsRGuildBar.SV.BarStolen end,
        setFunc	 =function(val) DsRGuildBar.SV.BarStolen = val DsRGuildBar.Toolbar_Update() end,
        disabled=function() return not DsRGuildBar.SV.BarOnOff end,})

    DsR.Menu.RegisterPanel("DsRBarPanel_Menu",MenuPanelBar)
    DsR.Menu.RegisterOptions("DsRBarPanel_Menu", MenuOptionsBar) 
end