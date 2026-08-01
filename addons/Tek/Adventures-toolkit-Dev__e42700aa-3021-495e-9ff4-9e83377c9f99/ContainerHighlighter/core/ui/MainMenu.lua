-- ============================================
-- MAIN MENU INTEGRATION
-- ============================================

function NWT.AddCustomMenuEntry()
    if not IsConsoleUI() and not IsInGamepadPreferredMode() then return end
    
    local function OnStateChange(oldState, newState)
        if newState == SCENE_SHOWING then
            MAIN_MENU_GAMEPAD_SCENE:UnregisterCallback("StateChange", OnStateChange)
            
            local function IsFeatureEnabled(f) return NWT.savedVars.features[f] ~= false end
            local subItems = {}
            
            -- Wealth Tracking
            if IsFeatureEnabled("netWorth") then table.insert(subItems, { name = "Net Worth", icon = "EsoUI/Art/Inventory/gamepad/gp_inventory_icon_currencies.dds", activatedCallback = function() NWT.OpenNetWorthDashboard() end }) end
            if IsFeatureEnabled("goldLedger") then table.insert(subItems, { name = "Gold Ledger", icon = "EsoUI/Art/Guild/gamepad/gp_guild_menuicon_deposits.dds", activatedCallback = function() NWT.OpenGoldLedgerDashboard() end }) end
            
            if NWT.isAuthorized then
                -- Guild Management
                if IsFeatureEnabled("guildSalesTracker") then table.insert(subItems, { name = "Guild Sales Tracker", icon = "EsoUI/Art/Guild/gamepad/gp_guild_menuicon_trader.dds", activatedCallback = function() NWT.OpenGuildSalesDashboard() end }) end
                if IsFeatureEnabled("bookkeeper") then table.insert(subItems, { name = "Guild Bookkeeper", icon = "EsoUI/Art/Guild/gamepad/gp_guild_menuicon_roster.dds", activatedCallback = function() NWT.OpenBookkeeper() end }) end
                if IsFeatureEnabled("guildRaffle") then table.insert(subItems, { name = "Guild Raffle", icon = "EsoUI/Art/MenuBar/gamepad/gp_playermenu_icon_crowncrates.dds", activatedCallback = function() NWT.OpenRaffle() end }) end
                
                -- Housing
                if IsFeatureEnabled("housingDashboard") then table.insert(subItems, { name = "Housing Dashboard", icon = "EsoUI/Art/TreeIcons/gamepad/gp_collectionicon_housing.dds", activatedCallback = function() NWT.OpenHousingDashboard() end }) end
                if IsFeatureEnabled("furnitureFinder") then table.insert(subItems, { name = "Furniture Finder", icon = "EsoUI/Art/TreeIcons/gamepad/gp_collectionicon_furnishings.dds", activatedCallback = function() NWT.OpenFurnitureSearch() end }) end
                if IsFeatureEnabled("planBrowser") then table.insert(subItems, { name = "Plan Browser", icon = "EsoUI/Art/Crafting/gamepad/gp_crafting_menuicon_blueprints.dds", activatedCallback = function() NWT.OpenPlanBrowser() end }) end
                if IsFeatureEnabled("planner") then table.insert(subItems, { name = "Housing Planner", icon = "EsoUI/Art/Crafting/gamepad/gp_crafting_menuicon_schematics.dds", activatedCallback = function() NWT.OpenPlanner() end }) end
                
                -- Combat & Farming
                if IsFeatureEnabled("pvpDashboard") then table.insert(subItems, { name = "PVP Tracker", icon = "EsoUI/Art/MenuBar/gamepad/gp_playermenu_icon_alliancewar.dds", activatedCallback = function() NWT.OpenPVPDashboard() end }) end
                table.insert(subItems, { name = "Infinite Archive", icon = "EsoUI/Art/MenuBar/gamepad/gp_playermenu_icon_journal.dds", activatedCallback = function() NWT.OpenEndlessArchiveDashboard() end })
                if IsFeatureEnabled("itemFinder") then table.insert(subItems, { name = "Item Finder", icon = "EsoUI/Art/MenuBar/gamepad/gp_playermenu_icon_inventory.dds", activatedCallback = function() NWT.OpenItemFinder() end }) end
                if IsFeatureEnabled("lootLog") then table.insert(subItems, { name = "Loot Log", icon = "EsoUI/Art/MenuBar/gamepad/gp_playermenu_icon_achievements.dds", activatedCallback = function() NWT.OpenLootLog() end }) end
                
                -- Gear Management
                table.insert(subItems, { name = "Wardrobe", icon = "EsoUI/Art/Inventory/gamepad/gp_inventory_icon_equipped.dds", activatedCallback = function() NWT.OpenWardrobeDashboard() end })
                
                -- Utility
                if IsFeatureEnabled("fishingTracker") then table.insert(subItems, { name = "Fishing Tracker", icon = "EsoUI/Art/Inventory/gamepad/gp_inventory_icon_craftbag_fishing.dds", activatedCallback = function() NWT.OpenFishingDashboard() end }) end
                
                -- Always show Help & Settings
                table.insert(subItems, { name = "|c88FFFF[Help & Instructions]|r", icon = "EsoUI/Art/MenuBar/gamepad/gp_playermenu_icon_help.dds", activatedCallback = function() NWT.OpenHelpDashboard() end })
                table.insert(subItems, { name = "|cAAAAAA[Settings]|r", icon = "EsoUI/Art/MenuBar/gamepad/gp_playermenu_icon_settings.dds", activatedCallback = function() NWT.OpenSettingsDashboard() end })
            end
            
            table.insert(subItems, { name = "|cFFD700Support the Developer|r", icon = "EsoUI/Art/MenuBar/gamepad/gp_playermenu_icon_giftinventory.dds", activatedCallback = function() NWT.OpenDonateDashboard() end })
            
            local function CreateEntry(id, data)
                local name = type(data.name) == "function" and "" or data.name
                local entry = ZO_GamepadEntryData:New(name, data.icon, nil, nil, data.isNewCallback)
                entry:SetIconTintOnSelection(true)
                entry:SetIconDisabledTintOnSelection(true)
                if data.header then entry:SetHeader(data.header) end
                entry.canLevel, entry.narrationText, entry.subLabelsNarrationText = data.canLevel, data.narrationText, data.subLabelsNarrationText
                if data.subMenu then
                    entry.subMenu = {}
                    for smId, smData in ipairs(data.subMenu) do entry.subMenu[#entry.subMenu + 1] = CreateEntry(smId, smData) end
                end
                entry.data, entry.id = data, id
                return entry
            end
            
            local insertPos = 0
            for i = 1, #ZO_MENU_ENTRIES do if ZO_MENU_ENTRIES[i].id == ZO_MENU_MAIN_ENTRIES.ACTIVITY_FINDER then insertPos = i break end end
            if insertPos == 0 then return end
            
            table.insert(ZO_MENU_ENTRIES, insertPos, CreateEntry("TraderManagerMainEntry", { customTemplate = "ZO_GamepadMenuEntryTemplateWithArrow", name = "|cFFAAAAAdventurer's Toolkit|r", icon = "EsoUI/Art/Inventory/gamepad/gp_inventory_icon_all.dds", subMenu = subItems }))
            MAIN_MENU_GAMEPAD:RefreshMainList()
        end
    end
    MAIN_MENU_GAMEPAD_SCENE:RegisterCallback("StateChange", OnStateChange)
end
