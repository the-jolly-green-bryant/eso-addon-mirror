InventoryAssistantMenu = {}
local InventoryAssistantMenu = InventoryAssistantMenu  or {}

InventoryAssistantMenu.name = "InventoryAssistantMenu"

local MenuOptions,MenuPanel,MenuHandlers={},{},{}
local Settings={}

Settings = {
    [1]  = {name="DsRGuildMenue_accsettings",description=true},
    [2]  = {name="DsRGuildInventory_InvOnOff",default=false,warning="ReloadUiWarn2",checkbox=true,
            getfnc=function() return IA_InventoryAssistant.settings.InvOnOff end,
            setfnc=function(value) IA_InventoryAssistant.settings.InvOnOff = value DsR.Menu.HandleReloadUIPressed() end,
            },
    [3]  = {name="DsRGuildInventory_GeneralSettings",subheader=true},
    [4]  = {name="DsRGuildInventory_DefaultSettings",description=true},
    [5]  = {name="DsRGuildInventory_ShowOnlyLoots",default=false,warning=false,checkbox=true,
            getfnc=function() return IA_InventoryAssistant.settings.onlyLoots end,
            setfnc=function(value) IA_InventoryAssistant.settings.onlyLoots, IA_InventoryAssistant.onlyLoots = value, value if not IA_InventoryAssistant.window:IsControlHidden ( ) then self:Refresh ( false ) end end,
            disable=function() return IA_InventoryAssistant.settings.InvOnOff end,
            },
    [6]  = {name="DsRGuildInventory_ShowCraftedSets",default=true,warning=false,checkbox=true,
            getfnc=function() return IA_InventoryAssistant.settings.showCrafted end,
            setfnc=function(value) IA_InventoryAssistant.settings.showCrafted, IA_InventoryAssistant.showCrafted = value, value if not IA_InventoryAssistant.window:IsControlHidden ( ) then self:Refresh ( false ) end end,
            disable=function() return IA_InventoryAssistant.settings.InvOnOff end,    
            },
    [7]  = {name="DsRGuildInventory_ShowTradeableSets",default=true,warning=false,checkbox=true,
            getfnc=function() return IA_InventoryAssistant.settings.showBuyable end,
            setfnc=function(value) IA_InventoryAssistant.settings.showBuyable, IA_InventoryAssistant.showBuyable = value, value if not IA_InventoryAssistant.window:IsControlHidden ( ) then self:Refresh ( false ) end end,
            disable=function() return IA_InventoryAssistant.settings.InvOnOff end,
            },
    [8]  = {name="DsRGuildInventory_ShowBoundSets",default=true,warning=false,checkbox=true,
            getfnc=function() return IA_InventoryAssistant.settings.showBound end,
            setfnc=function(value) IA_InventoryAssistant.settings.showBound, IA_InventoryAssistant.showBound = value, value if not IA_InventoryAssistant.window:IsControlHidden ( ) then self:Refresh ( false ) end end,
            disable=function() return IA_InventoryAssistant.settings.InvOnOff end,
            },
    [9]  = {name="DsRGuildInventory_ShowMonsterSets",default=true,warning=false,checkbox=true,
            getfnc=function() return IA_InventoryAssistant.settings.showMonsterSets end,
            setfnc=function(value) IA_InventoryAssistant.settings.showMonsterSets, IA_InventoryAssistant.showMonsterSets = value, value if not IA_InventoryAssistant.window:IsControlHidden ( ) then self:Refresh ( false ) end end,
            disable=function() return IA_InventoryAssistant.settings.InvOnOff end,
            },
    [10] = {name="DsRGuildInventory_ShowOtherItems",default=true,warning=false,checkbox=true,
            getfnc=function() return IA_InventoryAssistant.settings.showNonSetItems end,
            setfnc=function(value) IA_InventoryAssistant.settings.showNonSetItems, IA_InventoryAssistant.showNonSetItems = value, value if not IA_InventoryAssistant.window:IsControlHidden ( ) then self:Refresh ( false ) end end,
            disable=function() return IA_InventoryAssistant.settings.InvOnOff end,
            },
    [11] = {name="DsRGuildInventory_WindowSettings",subheader=true},
    [12] = {name="DsRGuildInventory_ShowWinInventar",default=true,warning=false,checkbox=true,
            getfnc=function() return IA_InventoryAssistant.settings.showWinInv end,
            setfnc=function(value) IA_InventoryAssistant.settings.showWinInv = value end,
            disable=function() return IA_InventoryAssistant.settings.InvOnOff end,
            },
    [13] = {name="DsRGuildInventory_BagNameWidth",slider=true,maxvalue=450,minvalue=50,step=10,default=250,warning=false,
            getfnc=function() return IA_InventoryAssistant.settings.bagNameWidth end,
            setfnc=function(value) IA_InventoryAssistant.settings.bagNameWidth = value if not IA_InventoryAssistant.window:IsControlHidden ( ) then IA_InventoryAssistant.list:RefreshVisible ( ) end end,
            disable=function() return IA_InventoryAssistant.settings.InvOnOff end,
            },
    [14] = {name="DsRGuildInventory_ShowItemPrice",default=true,warning=false,checkbox=true,
            getfnc=function() return IA_InventoryAssistant.settings.showTradPrice end,
            setfnc=function(value) IA_InventoryAssistant.settings.showTradPrice, IA_InventoryAssistant.showTradPrice = value, value if not IA_InventoryAssistant.window:IsControlHidden ( ) then self:Refresh ( false ) end end,
            disable=function() return IA_InventoryAssistant.settings.InvOnOff end,
            },
    [15] = {name="DsRGuildInventory_ShowItemEnchantments",default=true,warning=false,checkbox=true,
            getfnc=function() return IA_InventoryAssistant.settings.showEnchants end,
            setfnc=function(value) IA_InventoryAssistant.settings.showEnchants, IA_InventoryAssistant.showEnchants = value, value if not IA_InventoryAssistant.window:IsControlHidden ( ) then self:Refresh ( false ) end end,
            disable=function() return IA_InventoryAssistant.settings.InvOnOff end,
            },
    [16] = {name="DsRGuildInventory_ShowNonCP160",default=true,warning=false,checkbox=true,
            getfnc=function() return IA_InventoryAssistant.settings.showItemLevels end,
            setfnc=function(value) IA_InventoryAssistant.settings.showItemLevels, IA_InventoryAssistant.showItemLevels = value, value if not IA_InventoryAssistant.window:IsControlHidden ( ) then self:Refresh ( false ) end end,
            disable=function() return IA_InventoryAssistant.settings.InvOnOff end,
            },
    [17]  = {name="",description=true},
}

function InventoryAssistantMenu.Menu_Init()
    local DsRMenu=DsR and DsR.InternalMenu
    local Panel={
        type        ="panel",
        name        =(DsRMenu and "|c9fb6cd9.|r |t32:32:/esoui/art/companion/keyboard/companion_inventory_down.dds|t" or "")..DsR.Localization[DsR.language].IndexInventoryManager,
        displayName =(DsRMenu and "|c9fb6cd9.|r |t32:32:/esoui/art/companion/keyboard/companion_inventory_down.dds|t" or "")..DsR.Localization[DsR.language].IndexInventoryManager,
        author      ="|cD8F781Has|r|cF3F781enw|r|cF5DA81arr|r|cF7BE81ior|r",
    }
    local MenuOptions={}
    local index=0
    for i,data in pairs(Settings) do
        index=index+1
        local _name    = data.name
        local _tip     = DsR.Localization[DsR.language][data.name.."Desc"] or nil

        if data.header then
            MenuOptions[index]=
            {	type = "header",
                name = _name,
            }
        elseif data.subheader then
            MenuOptions[index]=
            {	type = "subheader",
                name = _name,
            }
        elseif data.description then
            MenuOptions[index]=
            {	type = "description",
                name = _name,
            }
        elseif data.attention then
            MenuOptions[index]=
            {	type = "attention",
                name = _name,
            }
        elseif data.slider then
            MenuOptions[index]=
            {	type		= "slider",
                name		= _name,
                tooltip	    = _tip,
                min		    = data.minvalue,
                max		    = data.maxvalue,
                step		= data.step,
				getFunc	    = data.getfnc,
				setFunc	    = data.setfnc,
                default	    = data.default,
                disabled    = data.disable,
                warning     = data.warning,
            }
        elseif data.dropdown then
            MenuOptions[index]=
            {	type	  = "dropdown",
                name	  = _name,
                tooltip	  = _tip,
                choices	  = data.choices,
				getFunc	  = data.getfnc,
				setFunc	  = data.setfnc,
                default	  = data.default,
                disabled  = data.disable,
                warning   = data.warning,
            }
        elseif data.button then
            MenuOptions[index]=
            {	type	= "button",
                name	= _name,
                tooltip	= _tip,
                func	= data.func,
                warning = data.warning,
              }
        elseif data.checkbox then
            MenuOptions[index]=
            {	type		= "checkbox",
                name		= _name,
                tooltip	    = _tip,
				getFunc	    = data.getfnc,
				setFunc	    = data.setfnc,
                default	    = data.default,
                disabled    = data.disable,
                warning     = data.warning,
            }
        elseif data.editbox then
            MenuOptions[index]=
            {	type		= "editbox",
                name		= _name,
                tooltip	    = _tip,
				getFunc	    = data.getfnc,
				setFunc	    = data.setfnc,
                default	    = data.default,
                disabled    = data.disable,
                warning     = data.warning,
            }
        elseif data.colorpicker then
            MenuOptions[index]=
            {	type		= "colorpicker",
                name		= _name,
                tooltip	    = _tip,
				getFunc	    = data.getfnc,
				setFunc	    = data.setfnc,
                default	    = data.default,
                disabled    = data.disable,
                warning     = data.warning,
            }
        end
    end
    DsR.Menu.RegisterPanel("DsRIAPanel_Menu_1",Panel)
    DsR.Menu.RegisterOptions("DsRIAPanel_Menu_1", MenuOptions)
end