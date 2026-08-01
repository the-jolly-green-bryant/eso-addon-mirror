EnhancedBounties = {
    Addon = {
        _displayName = "Enhanced Bounties",
        _name = "EnhancedBounties",

        updateChatterOptionData = function(self, chatterData)
            if chatterData.optionText == zo_strformat(
                EsoStrings[SI_INTERACT_OPTION_PAY_BOUNTY_FORFEIT_ITEMS],
                chatterData.gold
            ) then
                local gold = chatterData.gold
                if select(6, GetSkillAbilityInfo(SKILL_TYPE_WORLD, 2, 5)) then
                    gold = ZO_SUCCEEDED_TEXT:Colorize(gold)
                end
                if (self.bagBounty.value > 0) then
                    chatterData.optionText = zo_strformat(
                        SI_INTERACT_OPTION_PAY_BOUNTY_FORFEIT_ITEMS_ENHANCED,
                        gold,
                        self.bagBounty.count,
                        self.bagBounty.value
                    )
                end
            end
            return chatterData
        end,

        getName = function(self)
            return self._name
        end,

        onLoad = function(self, addonName)
            if (addonName == self._name) then
                self.bagBounty = EnhancedBounties.BagBounty()
                self.infamyControl = EnhancedBounties.InfamyControl(addonName)
                self.infamyControl:update(self.bagBounty:update())
                EVENT_MANAGER:RegisterForEvent(self._name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE
                 ,function(event, bag, _, _, _, reason)
                    if reason == INVENTORY_UPDATE_REASON_DEFAULT and self.bagBounty:includesInventory(bag) then
                        self.infamyControl:update(self.bagBounty:update())
                    end
                end)
                EVENT_MANAGER:RegisterForEvent(addonName, EVENT_JUSTICE_STOLEN_ITEMS_REMOVED, function()
                    self.infamyControl:update(self.bagBounty:clear())
                end)
                EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
            end
        end
    },

    BagBounty = {
        Inventories = {
            BAG_BACKPACK,
            BAG_WORN
        },

        clear = function(self)
            self.count = 0
            self.value = 0
            return self
        end,

        includesInventory = function(self, inventory)
            for _, included in pairs(self.Inventories) do
                if (included == inventory) then
                    return true
                end
            end
            return false
        end,

        update = function(self)
            local count = 0
            local value = 0
            for _, bag in pairs(self.Inventories) do
                for index, item in ZO_IterateBagSlots(bag) do
                    if IsItemStolen(bag, index) then
                        local itemCount = GetSlotStackSize(bag, index)
                        count = count + itemCount
                        value = value + GetItemSellValueWithBonuses(bag, index) * itemCount
                    end
                end
            end
            self.count = count
            self.value = value
            return self
        end
    },

    Icon = {
        _height = 24,
        _width = 24,

        Paths = {
            Bag = "esoui/art/mainmenu/menubar_inventory_up.dds",
            Coin = "esoui/art/loot/icon_goldcoin_pressed.dds",
            StolenItem = "esoui/art/inventory/inventory_stolenitem_icon.dds"
        },

        getIconText = function(self)
            return string.format("|t%d:%d:%s|t", self._width, self._height, self._path)
        end,

        choose = function(self, path)
            self._path = path
            return self
        end,

        setScale = function(self, width, height)
            self._width = width
            if height == nil then
                self._height = width
            else
                self._height = height
            end
            return self
        end
    },

    InfamyControl = {
        createControl = function(self)
            self._control = WINDOW_MANAGER:CreateControl(self._name, ZO_HUDInfamyMeterBountyDisplay, CT_LABEL)
            self._control:SetAnchor(RIGHT, ZO_HUDInfamyMeterBountyDisplay, LEFT, 0, 0)
            self._control:SetFont("ZoFontGameLargeBold")
            self._control:SetColor(ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
            self._countIcon = EnhancedBounties.Icon(EnhancedBounties.Icon.Paths.Bag)
            self._valueIcon = EnhancedBounties.Icon(EnhancedBounties.Icon.Paths.Coin)
        end,

        setAddonName = function(self, addonName)
            self._name = string.format("%s-InfamyControl", addonName)
        end,

        update = function(self, bagBounty)
            if bagBounty.value > 0 then
                self._control:SetText(zo_strformat("(<<1>>) <<2>>"
                 ,ZO_ERROR_COLOR:Colorize(bagBounty.value) .. self._valueIcon:getIconText()
                 ,bagBounty.count .. self._countIcon:getIconText()))
                self._control:SetHidden(false)
            else
                self._control:SetHidden(true)
            end
        end
    }
}

for _, class in pairs(EnhancedBounties) do
    if class == EnhancedBounties.BagBounty then
        class.__init = function()
            local self = setmetatable({}, class)
            self:clear()
            return self
        end
    elseif class == EnhancedBounties.Icon then
        class.__init = function(path)
            local self = setmetatable({}, class)
            self:choose(path)
            return self
        end
    elseif class == EnhancedBounties.InfamyControl then
        class.__init = function(addonName)
            local self = setmetatable({}, class)
            self:setAddonName(addonName)
            self:createControl()
            return self
        end
    else
        class.__init = function()
            return setmetatable({}, class)
        end
    end

    setmetatable(class, {
        __call = function(cls, ...)
            cls.__index = cls
            return cls.__init(...)
        end
    })
end

local enhancedBounties = EnhancedBounties.Addon()

local originalChatterOptionData = ZO_SharedInteraction.GetChatterOptionData
ZO_SharedInteraction.GetChatterOptionData = function(...)
    return enhancedBounties:updateChatterOptionData(originalChatterOptionData(...))
end

EVENT_MANAGER:RegisterForEvent(enhancedBounties:getName(), EVENT_ADD_ON_LOADED
 ,function(_, addonName) enhancedBounties:onLoad(addonName) end)
