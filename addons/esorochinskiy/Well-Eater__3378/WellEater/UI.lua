WellEater = WellEater or {}

function WellEater:initSettingsMenu()

    local L = self:getLocale()
    local LAM = LibAddonMenu2
    local optionsTable = {}

    local function MakeControlEntry(optTable, data, category, key)

        if (category and key) then
            -- for the majority of the settings
            data.category = category
            data.key      = key

            -- build simple table with zero-based values for choices
            if data.choices and not data.choicesValues then
                data.choicesValues = {}
                for i=1, #data.choices do
                    table.insert(data.choicesValues, i-1)
                end
            end

            -- setup default value
            if not data.default then
                local default = self:getUserDefault(key, category)
                data.default = default
            end

            -- add get/set functions if they were not provided
            if not data.getFunc then
                data.getFunc = function()
                    return self:getUserPreference(data.key, data.category)
                end
            end
            if not data.setFunc then
                data.setFunc = function(value)
                    self:setUserPreference(data.key, value, data.category)
                end
            end
            data.reference = "WESET_".. category .. "_".. key
        end



        -- add to appropriate table
        table.insert(optTable, data)
        return optTable

    end

    local function MakeSubmenu(optTable, title, description)
        local subTable = {}
        MakeControlEntry(optTable,{
            type = "submenu",
            name = title,
            controls = subTable,
        })
        MakeControlEntry(subTable, {
            type = "description",
            text = description,
        })
        MakeControlEntry(subTable,{
            type = "divider",
            alpha = 1,
        })
        return subTable
    end


    self.panelData = {
        type = "panel",
        name = self:getDisplayName(),
        author = self:getAuthor(),
        version = self:getVersion(),
        registerForRefresh = true,
        registerForDefaults = true,
    }

    MakeControlEntry(optionsTable,{
        type = "description",
        text = L.generalSetupDescription,
    })

    MakeControlEntry(optionsTable,{
        type = "header",
        name = L.timerSetupHeader,
    })

    MakeControlEntry(optionsTable,{
        type = "slider",
        name = L.timerSetupLabel,
        tooltip = L.timerSetupLabel_TT,
        setFunc = function(value)

            self:setUserPreference("updateTime", value, "general")
            self.InterfaceHook_OnTimerSlider()
        end,
        min = 1000, max = 3000, step = 100,
        noAlert = true,
    }, "general", "updateTime")


    local sTable = MakeSubmenu(optionsTable,L.mealSetupHeader, L.mealSetupDescription)

    MakeControlEntry(sTable,{
        type = "checkbox",
        name = L.mealSetupFood,
        tooltip = L.mealSetupFood,
    }, "general", "useFood")

    MakeControlEntry(sTable,{
        type = "checkbox",
        name = L.mealSetupDrink,
        tooltip = L.mealSetupDrink,
    }, "general", "useDrink")

    sTable = MakeSubmenu(optionsTable,L.foodQualityHeader, L.foodQualityDescription)

    for i = ITEM_QUALITY_MAGIC, ITEM_QUALITY_LEGENDARY do
        MakeControlEntry(sTable,{
            type = "checkbox",
            name = L.foods[i],
            tooltip = L.foods[i],
        }, "general", i)
    end

    MakeControlEntry(sTable,{
        type = "checkbox",
        name = L.useCrownFoodTitle,
        tooltip = L.useCrownFoodTitle_TT,
    }, "general", "useCrownFood")

    sTable = MakeSubmenu(optionsTable,L.weaponSetupHeader, L.weaponSetupDescription)

    MakeControlEntry(sTable,{
        type = "checkbox",
        name = L.weaponSetupEnchantMainHand,
        tooltip = L.weaponSetupEnchantMainHand,
    }, "slots", EQUIP_SLOT_MAIN_HAND)

    MakeControlEntry(sTable,{
        type = "checkbox",
        name = L.weaponSetupEnchantOffHand,
        tooltip = L.weaponSetupEnchantOffHand,
    }, "slots", EQUIP_SLOT_OFF_HAND)

    MakeControlEntry(sTable,{
        type = "checkbox",
        name = L.weaponSetupEnchantMainHandBack,
        tooltip = L.weaponSetupEnchantMainHandBack,
    }, "slots", EQUIP_SLOT_BACKUP_MAIN)

    MakeControlEntry(sTable,{
        type = "checkbox",
        name = L.weaponSetupEnchantOffHandBack,
        tooltip = L.weaponSetupEnchantOffHandBack,
    }, "slots", EQUIP_SLOT_BACKUP_OFF)

    MakeControlEntry(sTable,{
        type = "checkbox",
        name = L.useCrownGemsTitle,
        tooltip = L.useCrownGemsTitle_TT,
    }, "general", "useCrownGems")

    MakeControlEntry(sTable,{
        type = "slider",
        name = L.minCharges,
        tooltip = L.minCharges,
        min = 50, max = 300, step = 10,
    }, "general", "minCharges")

    sTable = MakeSubmenu(optionsTable,L.repairSetupHeader, L.repairSetupDescription)

    MakeControlEntry(sTable,{
        type = "checkbox",
        name = L.repairSetupCheck,
        tooltip = L.repairSetupCheck_TT,
    }, "general", "useRepair")

    MakeControlEntry(sTable,{
        type = "checkbox",
        name = L.useCrownRepairTitle,
        tooltip = L.useCrownRepairTitle_TT,
    }, "general", "useCrownRepair")

    MakeControlEntry(sTable,{
        type = "slider",
        name = L.repairPercent,
        tooltip = L.repairPercent,
        min = 10, max = 50, step = 10,
    }, "general", "percent")

    MakeControlEntry(optionsTable,{
        type = "header",
        name = L.outputSetupHeader,
    })

    MakeControlEntry(optionsTable,{
        type = "checkbox",
        name = L.outputOnScreen,
        tooltip = L.outputSetupHeader_TT,
    }, "general", "notifyToScreen")

    self.optionsData = optionsTable
    -- local myLAMAddonPanel =
    LAM:RegisterAddonPanel(self:getAddonName() .. "_Settings_Panel", self.panelData)
    LAM:RegisterOptionControls(self:getAddonName() .. "_Settings_Panel", self.optionsData)
    -- return myLAMAddonPanel
end
