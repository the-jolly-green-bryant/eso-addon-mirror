-- Author      : LintyDruid
-- Tool tip manager - Based off code by Vicster0

local ldTip_lddebug=false

local function lddebug(msg)
    if ldTip_lddebug then
        d("|cff0000LD Tooltip :: |r"..msg)
    end
end

--- functions
local function register()
    --Use dumb functions to ensure that they reference latest version of object and not direct function ref
    --PopupTooltips
    ZO_PreHookHandler(PopupTooltip, 'OnShow',function (control, ...) ld_tooltip.hooks.ToolTipShowHandler(control) end)
    ZO_PreHookHandler(PopupTooltip, 'OnUpdate', function (control, ...) ld_tooltip.hooks.TooltipUpdateHandler(control) end )
    ZO_PreHookHandler(PopupTooltip, 'OnHide', function (control, ...) ld_tooltip.hooks.ToolTipHideHandler(control) end )
    ZO_PreHookHandler(PopupTooltip, 'OnAddGameData', function (control, ...) ld_tooltip.hooks.ToolTipAddGameDataHandler(control) end )
    --ItemTooltips
    ZO_PreHookHandler(ItemTooltip, 'OnShow',function (control, ...) ld_tooltip.hooks.ToolTipShowHandler(control) end)
    ZO_PreHookHandler(ItemTooltip, 'OnUpdate', function (control, ...) ld_tooltip.hooks.TooltipUpdateHandler(control) end )
    ZO_PreHookHandler(ItemTooltip, 'OnHide', function (control, ...) ld_tooltip.hooks.ToolTipHideHandler(control) end )
    ZO_PreHookHandler(ItemTooltip, 'OnAddGameData', function (control, ...) ld_tooltip.hooks.ToolTipAddGameDataHandler(control) end )

    lddebug("Handlers Registered")
end

local function deregister()
    lddebug("Handlers Deregistered")
end

local function additemtooltip(name, sectionLabel, callback)
    lddebug("Request to add tooltip handler-> "..name)
    if ld_tooltips == nil then
        ld_tooltips={}
    end

    if ld_tooltips.items==nil then
        ld_tooltips.items={}
    end

    if (ld_tooltips.items[name]== nil) then ld_tooltips.items[name]={} end
    ld_tooltips.items[name].version=ldTip_ver
    ld_tooltips.items[name].sectionLabel=sectionLabel
    ld_tooltips.items[name].callback=callback
end

---- internal functions
function inferQualityFromLinkColor(color)
    for n=0,6,1 do
        cr,cg,cb,ca=GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS,n)
        sCol=string.format("%x%x%x",cr*255,cg*255,cb*255)
        --	lddebug("Colour-Quality --> "..color.." == "..sCol)
        if (color:lower()==sCol:lower()) then 
            return n 
        end
    end

    return -1
end

local function DissectItemLink( itemLink )
    if(itemLink) then
        local itemColor, data, itemText = itemLink:match("|H(.-):(.-)|h(.-)|h")

        if itemColor==nil then itemColor="ffffff" end

        if itemText==nil then itemText="#unknown#" end

        --			lddebug("Link data --> "..data)

        local itemType, 
        itemID, 
        itemQuality, 
        itemLevel,
        itemEnchantmentType, 
        itemEnchantmentStrength1, 
        itemEnchantmentStrength2,
        _, _, _, _, _, _, _, _, _, 
        itemStyle, 
        _, 
        itemIsBound, 
        itemChargeStatus = zo_strsplit(':', data);

        if (itemQuality==nil) then itemQuality=inferQualityFromLinkColor(itemColor) end
        if itemID==nil then itemID=-1 end

        if itemText:sub(1,1)=="[" then itemText=itemText:sub(2) end
        if itemText:sub(itemText:len())=="]" then itemText=itemText:sub(1,itemText:len()-1) end

        local itemIcon, 
        itemSellPrice, 
        itemMeetsUsageRequirement, 
        itemEquipType = GetItemLinkInfo(itemLink)

        local result = {
            source=nil,
            name=itemText,
            quality=itemQuality,
            icon=itemIcon,
            link=itemLink,
            vendorUnitPrice=itemSellPrice,
            meetsUsageReq=itemMeetsUsageRequirement,
            stackCount=nil,
            bagId= nil,
            slotId=nil,
            index=nil,
            timeLeft=nil,
            itemId=itemID,
            purchasePrice=nil,
        }			

        return result
    else
        return nil
    end
end

local function GetLinkItemId( itemLink )
    if(itemLink) then
        local itemColor, data, itemText = itemLink:match("|H(.-):(.-)|h(.-)|h")

        --	lddebug("Link data --> "..data)

        local itemType, 
        itemID, 
        itemQuality, 
        itemLevel, 
        itemEnchantmentType, 
        itemEnchantmentStrength1, 
        itemEnchantmentStrength2,
        _, _, _, _, _, _, _, _, _, 
        itemStyle, 
        _, 
        itemIsBound, 
        itemChargeStatus = zo_strsplit(':', data);

        return itemID
    else
        return nil
    end
end

local function ToolTipShowHandler( control )	
    lddebug("ToolTipShowHandler :: control == "..control:GetName())
    if(control == ItemTooltip) then
        local mouseOverControl = moc();
        if(mouseOverControl ~= nil) then
            --		lddebug("ToolTipShowHandler :: MOC parent == "..mouseOverControl:GetParent():GetName())
            --lddebug("ToolTipShowHandler :: MOC index == "..mouseOverControl.index)

            local mocParent = mouseOverControl:GetParent()

            if (mocParent) then
                if(mouseOverControl.dataEntry and mouseOverControl.dataEntry.data.bagId and mouseOverControl.dataEntry.data.slotIndex) then --is inventroy
                    local bag = mouseOverControl.dataEntry.data.bagId;
                    local index = mouseOverControl.dataEntry.data.slotIndex;
                    local curMouseOverLink = GetItemLink(bag, index);
                    --ld_tooltip.currLink=curMouseOverLink

                    ld_tooltip.currLink={source=ld_tooltips.sources.inventory,
                        name=mouseOverControl.dataEntry.data.name,
                        quality=mouseOverControl.dataEntry.data.quality,
                        icon=mouseOverControl.dataEntry.data.icon,
                        link=curMouseOverLink,
                        vendorUnitPrice=mouseOverControl.dataEntry.data.sellPrice,
                        meetsUsageReq=mouseOverControl.dataEntry.data.meetsUsageRequirement,
                        stackCount=mouseOverControl.dataEntry.data.stackCount,
                        bagId= mouseOverControl.dataEntry.data.bagId,
                        slotId=mouseOverControl.dataEntry.data.slotIndex,
                        index=mouseOverControl.dataEntry.data.purchasePrice,
                        timeLeft=nil,
                        itemId=GetLinkItemId(curMouseOverLink),
                        purchasePrice=nil,
                    }					
                    ld_tooltip.currSource=ld_tooltips.sources.inventory
                    ld_tooltip.isNew=true;
                elseif(mouseOverControl:GetParent():GetName() == "ZO_Character") then --is worn item
                    local bag = mouseOverControl.bagId;
                    local index = mouseOverControl.itemIndex;
                    local curMouseOverLink = GetItemLink(bag, index);

                    ld_tooltip.currLink=DissectItemLink(curMouseOverLink)
                    ld_tooltip.currLink.bagId= bag
                    ld_tooltip.currLink.slotId=index
                    ld_tooltip.currLink.index=mouseOverControl.itemIndex
                    ld_tooltip.currLink.stackCount=mouseOverControl.stackCount
                    ld_tooltip.currLink.source=ld_tooltips.sources.character

                    --ld_tooltip.currLink=curMouseOverLink
                    ld_tooltip.currSource=ld_tooltips.sources.character
                    ld_tooltip.isNew=true;
                elseif(mouseOverControl:GetParent():GetName() == "ZO_TradingHouseLeftPanePostItemFormInfo") then --is worn item
                    local bag = mouseOverControl.bagId;
                    local index = mouseOverControl.itemIndex;
                    local curMouseOverLink = GetItemLink(bag, index);

                    ld_tooltip.currLink=DissectItemLink(curMouseOverLink)
                    ld_tooltip.currLink.bagId= bag
                    ld_tooltip.currLink.slotId=index
                    ld_tooltip.currLink.index=mouseOverControl.itemIndex
                    ld_tooltip.currLink.stackCount=mouseOverControl.stackCount
                    ld_tooltip.currLink.source=ld_tooltips.sources.auctionPostItem

                    --ld_tooltip.currLink=curMouseOverLink
                    ld_tooltip.currSource=ld_tooltips.sources.auctionPostItem
                    ld_tooltip.isNew=true;
                elseif(mouseOverControl:GetParent():GetName() == "ZO_StoreWindowListContents") then --is store item
                    local curMouseOverLink = GetStoreItemLink(mouseOverControl.index, LINK_STYLE_BRACKETS)
                    --ld_tooltip.currLink=curMouseOverLink

                    ld_tooltip.currLink={source=ld_tooltips.sources.store,
                        name=mouseOverControl.dataEntry.data.name,
                        quality=mouseOverControl.dataEntry.data.quality,
                        icon=mouseOverControl.dataEntry.data.icon,
                        link=curMouseOverLink,
                        vendorUnitPrice=mouseOverControl.dataEntry.data.sellPrice,
                        meetsUsageReq=mouseOverControl.dataEntry.data.meetsRequirementToEquip,
                        stackCount=mouseOverControl.dataEntry.data.stack,
                        bagId=nil,
                        slotId=nil,
                        index=mouseOverControl.dataEntry.data.slotIndex,
                        timeLeft=nil,
                        itemId=GetLinkItemId(curMouseOverLink),
                        purchasePrice=stackBuyPrice,
                    }				

                    ld_tooltip.currSource=ld_tooltips.sources.store
                    ld_tooltip.isNew=true;
                elseif(mouseOverControl:GetParent():GetName() == "ZO_BuyBackListContents") then --is buyback item
                    local curMouseOverLink = GetBuybackItemLink(mouseOverControl.index, LINK_STYLE_BRACKETS)

                    --ld_tooltip.currLink=curMouseOverLink

                    ld_tooltip.currLink={source=ld_tooltips.sources.buyback,
                        name=mouseOverControl.dataEntry.data.name,
                        quality=mouseOverControl.dataEntry.data.quality,
                        icon=mouseOverControl.dataEntry.data.icon,
                        link=curMouseOverLink,
                        vendorUnitPrice=mouseOverControl.dataEntry.data.price,
                        meetsUsageReq=mouseOverControl.dataEntry.data.meetsRequirements,
                        stackCount=mouseOverControl.dataEntry.data.stack,
                        bagId=nil,
                        slotId=nil,
                        index=mouseOverControl.dataEntry.data.slotIndex,
                        timeLeft=nil,
                        itemId=GetLinkItemId(curMouseOverLink),
                        purchasePrice=stackBuyPrice,
                    }

                    ld_tooltip.currSource=ld_tooltips.sources.buyback
                    ld_tooltip.isNew=true;
                elseif(mouseOverControl:GetParent():GetName() == "ZO_InteractWindowRewardArea") then --is reward item
                    local curMouseOverLink = GetQuestRewardItemLink(mouseOverControl.index, LINK_STYLE_BRACKETS)

                    --ld_tooltip.currLink=curMouseOverLink

                    ld_tooltip.currLink=DissectItemLink(curMouseOverLink)
                    ld_tooltip.currLink.bagId= bag
                    ld_tooltip.currLink.slotId=index
                    ld_tooltip.currLink.index=mouseOverControl.itemIndex
                    ld_tooltip.currLink.stackCount=mouseOverControl.stackCount
                    ld_tooltip.currLink.source=ld_tooltips.sources.reward

                    ld_tooltip.currSource=ld_tooltips.sources.reward		
                    ld_tooltip.isNew=true;
                elseif (mouseOverControl.dataEntry and mouseOverControl.dataEntry.data.name and mouseOverControl.dataEntry.data.quality and mouseOverControl.dataEntry.data.icon) then -- is partial store data
                    ld_tooltip.currLink={source=ld_tooltips.sources.auctionItem,
                        name=mouseOverControl.dataEntry.data.name,
                        quality=mouseOverControl.dataEntry.data.quality,
                        icon=mouseOverControl.dataEntry.data.icon,
                        link=nil,
                        vendorUnitPrice=nil,
                        meetsUsageReq=nil,
                        stackCount=mouseOverControl.dataEntry.data.stackCount,
                        bagId=nil,
                        slotId=nil,
                        index=mouseOverControl.dataEntry.data.itemIndex,
                        timeLeft=mouseOverControl.dataEntry.data.timeRemaining,
                        itemId=-1,
                        purchasePrice=mouseOverControl.dataEntry.data.purchasePrice
                    }					

                    ld_tooltip.currSource=ld_tooltips.sources.auctionItem
                    ld_tooltip.isNew=true;
                end
            end
        end
    elseif (control==PopupTooltip) then
        ld_tooltip.isNew=true;
    end
end

local function TooltipUpdateHandler(control)
    --lddebug("TooltipUpdateHandler::"..control:GetName())
    if (ld_tooltip.popupUptoDate) then 
        return 
    end

    if (control==PopupTooltip and control.lastLink ~= nil) then
        lddebug("TooltipUpdateHandler:: Process Link")
        ---if ld_tooltip.currLink~=nil and control.lastLink==ld_tooltip.currLink.link then return end

        ld_tooltip.currLink=DissectItemLink(control.lastLink)

        if ld_tooltip.currLink~=nil then
            --	lddebug("PopupTooltip::"..control.lastLink)
            ld_tooltip.currLink.bagId= nil
            ld_tooltip.currLink.slotId=nil
            ld_tooltip.currLink.index=nil
            ld_tooltip.currLink.stackCount=1
            ld_tooltip.currLink.source=ld_tooltips.sources.popup

            ld_tooltip.popupUptoDate=true;
            --ld_tooltip.currLink=curMouseOverLink
            ld_tooltip.currSource=ld_tooltips.sources.popup

            ld_tooltip.isNew=true
        end
    end

    if (control==PopupTooltip and control.lastLink == nil) then 
        return 
    end

    if ld_tooltip.isNew==false or ld_tooltip.currLink==nil then 
        return 
    end --- Nothing to do

    if(control == PopupTooltip or control == ItemTooltip) then	--Handle item tooltips 
        --lddebug("Item:: "..ld_tooltip.currSource.." : "..ld_tooltip.currLink.itemId.."-"..ld_tooltip.currLink.name.." +"..ld_tooltip.currLink.quality)

        --- Process Item Queue
        for id, data in pairs(ld_tooltips.items) do
            tipdata=ld_tooltips.items[id].callback(ld_tooltip.currLink) -- return tooltip lines as array

            if type(tipdata)=="table" and tipdata[1]~=nil then 
                lddebug("TipData[1]:: ["..tipdata[1].."]")

                ZO_Tooltip_AddDivider(control); 
                control:AddLine(ld_tooltips.items[id].sectionLabel.."|r")

                for i=1,#tipdata,1 do
                    if tipdata[i]~=nil and  type(tipdata[i]=="string") then
                        if tipdata[i]=="" then
                            control:AddVerticalPadding(10)
                        elseif tipdata[i]=="-" then
                            ZO_Tooltip_AddDivider(control); 
                        else
                            control:AddLine(tipdata[i].."|r")
                        end
                    end
                end
            end
        end
    end

    ld_tooltip.isNew=false;
end

local function HardUpdate(control)
    ld_tooltip.popupUptoDate=false
    TooltipUpdateHandler(control)
end

local function ToolTipHideHandler( control )
    --lddebug("ToolTipHideHandler")

    if(control == ItemTooltip or control == PopupTooltip ) then
        ld_tooltip.currLink=nil
        ld_tooltip.currSource=nil
        ld_tooltip.isNew=false;
    end	

    if( control == PopupTooltip ) then
        ld_tooltip.popupUptoDate=false;
    end
    
    ld_tooltip.currLink=curMouseOverLink
end

local function ToolTipAddGameDataHandler( control )
    --lddebug("ToolTipAddGameDataHandler::"..control:GetName())
    local mouseOverControl = moc();

    if(mouseOverControl ~= nil) then
        ToolTipShowHandler(control)
    end
end

------ Create/update object
if ld_tooltips == nil then
    ld_tooltips={}
    ld_tooltips.sources={inventory=0,character=1,store=2, buyback=3, reward=4,data=5,auctionPostItem=6, popup=7, auctionItem=99 }
end

local ldTip_ver=0.1

-- Manage alternate versions
if ld_tooltip==nil or ld_tooltip.ver<ldTip_ver then -- new version overwrite but preserve any data save call backs
    --	ld_timer=nil

    --- De register events
    if ld_tooltip==nil then 
        ld_tooltip={} 
        ld_tooltip.registered=false
        ld_tooltip.hooks={}
    else
        ld_tooltip.deregister();
    end

    ld_tooltip.currLink=nil
    ld_tooltip.currSource=nil
    ld_tooltip.isNew=false;
    ld_tooltip.popupUptoDate=false;

    ld_tooltip.deregister=deregister;
    ld_tooltip.additemtooltip=additemtooltip;
    ld_tooltip.ver=ldTip_ver;
    ld_tooltip.forceupdate=HardUpdate;

    -- Reset Hook Handlers
    ld_tooltip.hooks.ToolTipShowHandler=ToolTipShowHandler
    ld_tooltip.hooks.TooltipUpdateHandler=TooltipUpdateHandler
    ld_tooltip.hooks.ToolTipHideHandler=ToolTipHideHandler
    ld_tooltip.hooks.ToolTipAddGameDataHandler=ToolTipAddGameDataHandler

    --Register Hook Handlers (if not done before)
    if not ld_tooltip.registered then
        register()
        ld_tooltip.registered=true;
    end
else
    return --- better version do not overwrite
end

--- Demo Test Function
local function ld_testfunction(itemID,itemText,itemQuality,itemIsBound,itemSellPrice,itemMeetsUsageRequirement,link) 
    return {"This is a test","Line 2 of test", "Line 3 item is : "..itemText} 
end

--ld_tooltip.additemtooltip("ldttooltip_test","LD Tooltip Test",ld_testfunction)