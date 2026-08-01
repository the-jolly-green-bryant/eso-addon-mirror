local class = ZO_InitializingObject:Subclass()
servantSettings = class

local function OrderedIterator(t)
    local indexes = {}
    for k, v in pairs(t) do
        table.insert(indexes, k)
    end

    table.sort(indexes)

    local i = 0
    local count = #indexes

    return function()
        if i < count then
            i = i + 1
            return indexes[i], t[indexes[i]]
        end
    end
end

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sSettings", self.owner.name)
    self.data = LibSimpleSavedVars:NewInstallationWide(string.format("%sData", self.name), 1, {
        charge = true,
        eat = true,
        repair = true,
        scroll = true,
        collectible = true,

        minCharge = 10,
        minCondition = 10,
        minEat = 10,
        instanceOnly = true,
        crownRepairKits = false,
        minAvgCondition = 30,

        foodPve = {},
        foodPvp = {},
        foodAp = {},
        foodExp = {},

        scrollAp = {},
        scrollExp = {},
        scrollPelinal = false,

        collectibles = {},

        log = true
    })

    self.currentCharacterId = GetCurrentCharacterId()

    self.panel = self:createSettingsPanel()
end

local hintColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HINT)

local function createItemControl(itemId)
    return function(customControl)
        local control = WINDOW_MANAGER:CreateControl("$(parent)Left", customControl, CT_LABEL)

        customControl.label = control
        customControl.amount = 0

        control:SetAnchor(LEFT, customControl, LEFT, 0, 0)
        control:SetHeight(16)
        control:SetFont("$(BOLD_FONT)|16|soft-shadow-thick")
        control:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        control:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        customControl.label:SetText(string.format("%s - %d [|c%sitemId: %d|r]", string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId), customControl.amount, hintColor:ToHex(), itemId))
    end
end

local function refreshItemControl(itemId)
    return function(customControl)
        customControl.label:SetText(string.format("%s - %d [|c%sitemId: %d|r]", string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId), customControl.amount, hintColor:ToHex(), itemId))
    end
end

function class:createSettingsPanel()
    local panelData = {
        type = "panel",
        name = self.owner.addonData.title,
        displayName = self.owner.addonData.title,
        author = self.owner.addonData.author,
        version = tostring(self.owner.addonData.version),
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local panel  = LibAddonMenu2:RegisterAddonPanel(panelData.name, panelData)

    local optionsTable = {}


    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize("AutoCharge"),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Turn on",
        getFunc = function()
            return self.data.charge == true
        end,
        setFunc = function(value)
            self.data.charge = value
            self.owner.charge:Start(self.data.charge)
        end,
        width = "half",
    })

    table.insert(optionsTable, {
        type = "slider",
        name = "Minimal charge (in percent)",
        getFunc = function()
            return self.data.minCharge
        end,
        setFunc = function(value)
            self.data.minCharge = value
            if self.data.charge then
                self.owner.charge.ChargeAllHandler:Trigger()
            end
        end,
        min = 10,
        max = 95,
        step = 5,
        width = "half",
    })

    table.insert(optionsTable, {
        type = "divider",
        width = "full",
        alpha = 0.4,
    })

    table.insert(optionsTable, {
        type = "custom",
        createFunc = createItemControl(servantCharge.soulGemId),
        refreshFunc = refreshItemControl(servantCharge.soulGemId),
        width = "full",
       reference = string.format("%sItemWidget-%d", self.name, servantCharge.soulGemId)
    })

    table.insert(optionsTable, {
        type = "custom",
        createFunc = createItemControl(servantCharge.crownSoulGemId),
        refreshFunc = refreshItemControl(servantCharge.crownSoulGemId),
        width = "full",
        reference = string.format("%sItemWidget-%d", self.name, servantCharge.crownSoulGemId)
    })


    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize("AutoRepair"),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Turn on",
        getFunc = function()
            return self.data.repair == true
        end,
        setFunc = function(value)
            self.data.repair = value
            self.owner.repair:Start(self.data.repair)
        end,
        width = "half",
    })

    table.insert(optionsTable, {
        type = "slider",
        name = "Minimal condition (in percent)",
        getFunc = function()
            return self.data.minCondition
        end,
        setFunc = function(value)
            self.data.minCondition = value
            if self.data.repair then
                self.owner.repair.RepairAllHandler:Trigger()
            end
        end,
        min = 10,
        max = 95,
        step = 5,
        width = "half",
    })

    if self.data.crownRepairKits == nil then
        self.data.crownRepairKits = false
    end
    table.insert(optionsTable, {
        type = "checkbox",
        name = "Use Crown Repair Kits",
        getFunc = function()
            return self.data.crownRepairKits == true
        end,
        setFunc = function(value)
            self.data.crownRepairKits = value
            self.owner.repair:Start(self.data.repair)
        end,
        width = "half",
    })

    if self.data.minAvgCondition == nil then
        self.data.minAvgCondition = 30
    end
    table.insert(optionsTable, {
        type = "slider",
        name = "Minimal average condition for Crown Repair Kits (in percent)",
        getFunc = function()
            return self.data.minAvgCondition
        end,
        setFunc = function(value)
            self.data.minAvgCondition = value
            if self.data.repair then
                self.owner.repair.RepairAllHandler:Trigger()
            end
        end,
        min = 10,
        max = 50,
        step = 5,
        width = "half",
    })

    table.insert(optionsTable, {
        type = "divider",
        width = "full",
        alpha = 0.4,
    })

    table.insert(optionsTable, {
        type = "custom",
        createFunc = createItemControl(servantRepair.repairKitId),
        refreshFunc = refreshItemControl(servantRepair.repairKitId),
        width = "full",
        reference = string.format("%sItemWidget-%d", self.name, servantRepair.repairKitId)
    })

    for _, itemId in ipairs(servantRepair.crownRepairKitIds) do
        table.insert(optionsTable, {
            type = "custom",
            createFunc = createItemControl(itemId),
            refreshFunc = refreshItemControl(itemId),
            width = "full",
            reference = string.format("%sItemWidget-%d", self.name, itemId)
        })
    end

    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize("AutoEat"),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "divider",
        width = "full",
        alpha = 0.8,
    })

    table.insert(optionsTable, {
        type = "description",
        text = "Works with crafted food/drink only",
        width = "full",
    })

    table.insert(optionsTable, {
        type = "divider",
        width = "full",
        alpha = 0.8,
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Turn on",
        getFunc = function()
            return self.data.eat == true
        end,
        setFunc = function(value)
            self.data.eat = value
            self.owner.eat:Start(self.data.eat)
        end,
        width = "half",
    })

    table.insert(optionsTable, {
        type = "slider",
        name = "Remaining time (in minutes)",
        getFunc = function()
            return self.data.minEat
        end,
        setFunc = function(value)
            self.data.minEat = value
            if self.data.eat then
                self.owner.eat.EatHandler:Trigger()
            end
        end,
        min = 5,
        max = 30,
        step = 1,
        width = "half",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Instance only (delves, dungeons, trials)",
        getFunc = function()
            return self.data.instanceOnly == true
        end,
        setFunc = function(value)
            self.data.instanceOnly = value
            if self.data.eat then
                self.owner.eat.EatHandler:Trigger()
            end
        end,
        width = "half",
    })

    table.insert(optionsTable, {
        type = "divider",
        width = "full",
        alpha = 0.8,
    })

    if self.data.foodPve == nil then
        self.data.foodPve = {}
    end
    if self.data.foodPve[self.currentCharacterId] == nil then
        self.data.foodPve[self.currentCharacterId] = ""
    end
    table.insert(optionsTable, {
        type = "dropdown",
        name = "PVE food",
        choices = {"---"},
        choicesValues = {""},
        getFunc = function()
            return self.data.foodPve[self.currentCharacterId]
        end,
        setFunc = function(value)
            self.data.foodPve[self.currentCharacterId] = value
            if self.data.eat then
                self.owner.eat.EatHandler:Trigger()
            end
        end,
        width = "half",
        reference = string.format("%sFoodWidget-%s", self.name, "pve")
    })

    if self.data.foodPvp == nil then
        self.data.foodPvp = {}
    end
    if self.data.foodPvp[self.currentCharacterId] == nil then
        self.data.foodPvp[self.currentCharacterId] = ""
    end
    table.insert(optionsTable, {
        type = "dropdown",
        name = "PVP food",
        choices = {"---"},
        choicesValues = {""},
        getFunc = function()
            return self.data.foodPvp[self.currentCharacterId]
        end,
        setFunc = function(value)
            self.data.foodPvp[self.currentCharacterId] = value
            if self.data.eat then
                self.owner.eat.EatHandler:Trigger()
            end
        end,
        width = "half",
        reference = string.format("%sFoodWidget-%s", self.name, "pvp")
    })

    table.insert(optionsTable, {
        type = "divider",
        width = "full",
        alpha = 0.8,
    })

    if self.data.foodExp == nil then
        self.data.foodExp = {}
    end
    if self.data.foodExp[self.currentCharacterId] == nil then
        self.data.foodExp[self.currentCharacterId] = ""
    end
    table.insert(optionsTable, {
        type = "dropdown",
        name = "EXP booster",
        choices = {"---"},
        choicesValues = {""},
        getFunc = function()
            return self.data.foodExp[self.currentCharacterId]
        end,
        setFunc = function(value)
            self.data.foodExp[self.currentCharacterId] = value
            if self.data.eat then
                self.owner.eat.EatHandler:Trigger()
            end
        end,
        width = "half",
        reference = string.format("%sFoodWidget-%s", self.name, "exp")
    })

    if self.data.foodAp == nil then
        self.data.foodAp = {}
    end
    if self.data.foodAp[self.currentCharacterId] == nil then
        self.data.foodAp[self.currentCharacterId] = ""
    end
    table.insert(optionsTable, {
        type = "dropdown",
        name = "AP booster",
        choices = {"---"},
        choicesValues = {""},
        getFunc = function()
            return self.data.foodAp[self.currentCharacterId]
        end,
        setFunc = function(value)
            self.data.foodAp[self.currentCharacterId] = value
            if self.data.eat then
                self.owner.eat.EatHandler:Trigger()
            end
        end,
        width = "half",
        reference = string.format("%sFoodWidget-%s", self.name, "ap")
    })


    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize("AutoScroll"),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Turn on",
        getFunc = function()
            return self.data.scroll == true
        end,
        setFunc = function(value)
            self.data.scroll = value
            self.owner.scroll:Start(self.data.scroll)
        end,
        width = "full",
    })

    if self.data.scrollAp == nil then
        self.data.scrollAp = {}
    end
    if self.data.scrollAp[self.currentCharacterId] == nil then
        self.data.scrollAp[self.currentCharacterId] = ""
    end
    table.insert(optionsTable, {
        type = "dropdown",
        name = "AP scrolls",
        choices = {"---"},
        choicesValues = {""},
        getFunc = function()
            return self.data.scrollAp[self.currentCharacterId]
        end,
        setFunc = function(value)
            self.data.scrollAp[self.currentCharacterId] = value
            if self.data.scroll then
                self.owner.scroll.ScrollHandler:Trigger()
            end
        end,
        width = "half",
        reference = string.format("%sScrollWidget-%s", self.name, "ap")
    })

    if self.data.scrollExp == nil then
        self.data.scrollExp = {}
    end
    if self.data.scrollExp[self.currentCharacterId] == nil then
        self.data.scrollExp[self.currentCharacterId] = ""
    end
    table.insert(optionsTable, {
        type = "dropdown",
        name = "EXP scrolls",
        choices = {"---"},
        choicesValues = {""},
        getFunc = function()
            return self.data.scrollExp[self.currentCharacterId]
        end,
        setFunc = function(value)
            self.data.scrollExp[self.currentCharacterId] = value
            if self.data.scroll then
                self.owner.scroll.ScrollHandler:Trigger()
            end
        end,
        width = "half",
        reference = string.format("%sScrollWidget-%s", self.name, "exp")
    })

    if self.data.scrollPelinal == nil then
        self.data.scrollPelinal = false
    end
    self.data.scrollPelinal = false

    --table.insert(optionsTable, {
    --    type = "checkbox",
    --    name = servantScrollLibrary.pelinalScroll.itemLink,
    --    getFunc = function()
    --        return self.data.scrollPelinal == true
    --    end,
    --    setFunc = function(value)
    --        self.data.scrollPelinal = value
    --        if self.data.scroll then
    --            self.owner.scroll.ScrollHandler:Trigger()
    --        end
    --    end,
    --    width = "half",
    --})


    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize("AutoCollectible"),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Turn on",
        getFunc = function()
            return self.data.collectible == true
        end,
        setFunc = function(value)
            self.data.collectible = value
            self.owner.collectible:Start(self.data.collectible)
        end,
        width = "full",
    })

    if self.data.collectibles == nil then
        self.data.collectibles = {}
    end

    for collectibleId, _ in OrderedIterator(servantScrollCollectible.items) do
        table.insert(optionsTable, {
            type = "checkbox",
            name = GetCollectibleName(collectibleId),
            getFunc = function()
                return self.data.collectibles[collectibleId] == true
            end,
            setFunc = function(value)
                self.data.collectibles[collectibleId] = value
                if self.data.collectible then
                    self.owner.collectible.CollectibleHandler:Trigger()
                end
            end,
            width = "full",
        })
    end


    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize("Other settings"),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Log to chat",
        getFunc = function()
            return self.data.log == true
        end,
        setFunc = function(value)
            self.data.log = value
        end,
        width = "half",
    })


    LibAddonMenu2:RegisterOptionControls(panelData.name, optionsTable)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel ~= self.panel then
            return
        end

        local items = {
            [servantCharge.soulGemId] = 0,
            [servantCharge.crownSoulGemId] = 0,
            [servantRepair.repairKitId] = 0,
            [servantRepair.crownRepairKitIds[1]] = 0,
            [servantRepair.crownRepairKitIds[2]] = 0,
        }

        local foodDrinks = {}
        local apBoosters = {}
        local expBoosters = {}
        local apScrolls = {}
        local expScrolls = {}
        for slotIndex in ZO_IterateBagSlots(BAG_BACKPACK) do
            local itemId = GetItemId(BAG_BACKPACK, slotIndex)
            local link = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_BRACKETS)

            if self.owner.eat.foodDrink:IsFoodDrinkItem(itemId) then
                foodDrinks[link] = true
            end
            if self.owner.eat.foodDrink:IsApBoosterItem(itemId) then
                apBoosters[link] = true
            end
            if self.owner.eat.foodDrink:IsExpBoosterItem(itemId) then
                expBoosters[link] = true
            end
            if self.owner.scroll.scroll:IsApScroll(itemId) then
                apScrolls[link] = true
            end
            if self.owner.scroll.scroll:IsExpScroll(itemId) then
                expScrolls[link] = true
            end

            if items[itemId] ~= nil then
                local stack, maxStack = GetSlotStackSize(BAG_BACKPACK, slotIndex)
                items[itemId] = items[itemId] + stack
            end
        end

        local function generateChoices(itemLinks, currentItemLink)
            if currentItemLink ~= nil and currentItemLink ~= "" then
                itemLinks[currentItemLink] = true
            end
            local choices = {"---"}
            local choiceValues = {""}
            local choiceTooltips = {""}
            for itemLink, _ in pairs(itemLinks) do
                table.insert(choices, itemLink)
                table.insert(choiceValues, itemLink)
                table.insert(choiceTooltips, itemLink)
            end

            return choices, choiceValues, choiceTooltips
        end

        local function SetupTooltips(comboBox, choicesTooltips)
            -- allow for tooltips on the drop down entries
            local originalShow = comboBox.ShowDropdownInternal
            comboBox.ShowDropdownInternal = function(comboBox)
                originalShow(comboBox)
                local entries = ZO_Menu.items
                for i = 1, #entries do
                    local control = entries[i].item
                    control.itemLink = choicesTooltips[i]

                    if control.itemLink ~= "" then
                        control:SetHandler("OnMouseEnter", function(control)
                            InitializeTooltip(PopupTooltip, control,  TOPLEFT, 0, 0, TOPRIGHT)
                            PopupTooltip:SetLink(control.itemLink)
                        end, "LAM2_Dropdown_Tooltip")
                        control:SetHandler("OnMouseExit", function()
                            ClearTooltip(PopupTooltip)
                        end, "LAM2_Dropdown_Tooltip")
                        control:SetHandler("OnMouseDown", function()
                            ClearTooltip(PopupTooltip)
                        end, "LAM2_Dropdown_Tooltip")
                    end
                end
            end

            local originalHide = comboBox.HideDropdownInternal
            comboBox.HideDropdownInternal = function(self)
                local entries = ZO_Menu.items
                for i = 1, #entries do
                    local control = entries[i].item
                    if control.itemLink then
                        control:SetHandler("OnMouseEnter", nil, "LAM2_Dropdown_Tooltip")
                        control:SetHandler("OnMouseExit", nil, "LAM2_Dropdown_Tooltip")
                        control.itemLink = nil
                    end
                end
                originalHide(self)
            end
        end

        local controls = {
            {
                control = _G[string.format("%sFoodWidget-%s", self.name, "pve")],
                itemLinks = foodDrinks
            },
            {
                control = _G[string.format("%sFoodWidget-%s", self.name, "pvp")],
                itemLinks = foodDrinks
            },
            {
                control = _G[string.format("%sFoodWidget-%s", self.name, "ap")],
                itemLinks = apBoosters
            },
            {
                control = _G[string.format("%sFoodWidget-%s", self.name, "exp")],
                itemLinks = expBoosters
            },
            {
                control = _G[string.format("%sScrollWidget-%s", self.name, "ap")],
                itemLinks = apScrolls
            },
            {
                control = _G[string.format("%sScrollWidget-%s", self.name, "exp")],
                itemLinks = expScrolls
            },
        }

        for _, controlData in ipairs(controls) do
            local  choices, choiceValues, choiceTooltips = generateChoices(controlData.itemLinks, controlData.control.data.getFunc())

            controlData.control:UpdateChoices(choices, choiceValues)
            controlData.control:UpdateValue()

            if choiceTooltips then
                assert(#choices == #choiceTooltips, "choices and choiceTooltips need to have the same size")
                if not controlData.control.scrollHelper then
                    SetupTooltips(controlData.control.dropdown, choiceTooltips)
                end
            end
        end

        for itemId, amount in pairs(items) do
            _G[string.format("%sItemWidget-%d", self.name, itemId)].amount = amount
            _G[string.format("%sItemWidget-%d", self.name, itemId)]:UpdateValue()
        end
    end)

    return panel
end

function class:Open()
    LibAddonMenu2:OpenToPanel(self.panel)
end
