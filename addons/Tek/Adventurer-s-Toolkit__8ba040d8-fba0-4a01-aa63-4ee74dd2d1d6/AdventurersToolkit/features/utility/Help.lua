-- ============================================
-- HELP & INSTRUCTIONS MODULE
-- ============================================
NWT.HelpDashboard = { isOpen = false, currentPage = 1, selectedTopic = 1, focusPanel = "topics", contentScrollOffset = 0, topicScrollOffset = 0 }
local MAX_VISIBLE_TOPICS = 13

local helpPages = {
    { title = "Overview", text = "ADVENTURER'S TOOLKIT\nThe Ultimate ESO Companion for Xbox\n\n14 powerful features in one addon. No keyboard required.\n\n\nFEATURES INCLUDED:\n\nWEALTH TRACKING:\n- Net Worth: Total wealth calculator\n- Gold Ledger: Income/expense tracking\n\nGUILD MANAGEMENT:\n- Guild Sales Tracker: Trading analytics\n- Guild Bookkeeper: Dues management\n- Guild Raffle: Run member raffles\n\nHOUSING:\n- Housing Dashboard: Manage all houses\n- Furniture Finder: Search your items\n- Plan Browser: All furnishing plans\n- Planner: Decoration wishlists\n\nCOMBAT & FARMING:\n- PVP Tracker: AP, kills, deaths\n- Item Finder: Cross-character search\n- Loot Log: Farming session stats\n\nUTILITY:\n- Fishing Tracker: Master Angler progress\n- Loot Radar: 3D container markers\n\n\nGETTING STARTED:\n\n1. Open the main menu (Menu button)\n2. Scroll to 'Adventurer's Toolkit'\n3. Press [A] to see all features\n4. Select any feature to open it\n\n\nFIRST TIME SETUP:\n\nFor accurate data, visit these locations:\n- BANK: Scan bank items\n- CRAFT BAG: Scan materials\n- FURNITURE VAULT: Scan stored furniture\n- HOUSES: Cache placed furniture\n- GUILD BANKS: Scan contributions" },

    { title = "Net Worth", text = "NET WORTH TRACKER\n\nSee your TRUE total wealth in Tamriel.\n\n\nWHAT IT TRACKS:\n\n- Character Gold: Gold in your pocket\n- Bank Gold: Gold in personal bank\n- Inventory Value: Items you're carrying\n- Bank Value: Items in bank\n- Craft Bag Value: All crafting materials\n- Furniture Vault: Stored furniture\n- Housing Value: Placed furniture\n- Crown Items: Crown store purchases\n- Writ Vouchers: Voucher item values\n- Guild Bank: Your contributions\n\n\nGETTING ACCURATE VALUES:\n\nThe addon only sees what you've visited:\n\n1. Open your BANK (auto-scans)\n2. Open CRAFT BAG tab\n3. Open FURNITURE VAULT (Housing Editor > Retrieve)\n4. Visit each HOUSE you own\n5. Visit each GUILD BANK\n\n\nCONTROLS:\n\n[LB/RB] - Switch to Gold Ledger\n[Y] - Refresh all values\n[B] - Back to menu\n\n\nPRICE DATA:\n\nPrices come from Tamriel Trade Centre (TTC).\nCrown items show crown store values.\nWrit voucher items show voucher costs." },

    { title = "Gold Ledger", text = "GOLD LEDGER\n\nAutomatically tracks ALL gold transactions.\n\n\nINCOME TRACKED:\n\n- Guild Store Sales\n- Vendor Sales\n- Loot Gold\n- Mail Received\n- Quest Rewards\n- Pickpocket/Stolen\n- Kill Rewards\n- Other Income\n\n\nEXPENSES TRACKED:\n\n- Guild Purchases\n- Listing Fees\n- Vendor Purchases\n- Repairs\n- Fast Travel (Wayshrine)\n- Mail Sent\n- Bag/Bank Upgrades\n- Stable Training\n- Respec Costs\n- COD Payments\n- Other Expenses\n\n\nDAILY RESET:\n\n'Today' totals reset at 5:00 AM EST.\nThis matches ESO's daily reset time.\nAll-time totals are preserved forever.\n\n\nTRANSACTION HISTORY:\n\nThe last 50 transactions are saved with:\n- Timestamp\n- Type of transaction\n- Amount\n- Balance after\n- Item name (for purchases)\n\n\nCONTROLS:\n\n[LB/RB] - Switch to Net Worth\n[B] - Back to menu" },

    { title = "Guild Sales", text = "GUILD SALES TRACKER\n\nPowerful trading analytics for all your guilds.\n\n\nWHAT IT TRACKS:\n\n- Your total sales and gold earned\n- Tax paid to guild\n- Items sold count\n- Top selling items\n- Seller leaderboards\n- Buyer tracking\n- Bank gold deposits/withdrawals\n- Kiosk/trader information\n\n\nTIME PERIODS:\n\n- 24 Hours\n- 7 Days (This Week)\n- Last Week\n- 30 Days (Month)\n\n\nSCANNING SALES:\n\n1. Travel to a GUILD BANK or TRADER\n2. Open the guild interface\n3. Addon scans automatically\n4. View data in Guild Sales Tracker\n\nScan each guild for complete data.\n\n\nLEADERBOARDS:\n\nSee top sellers in each guild.\nCompare your performance.\nTrack who's buying your items.\n\n\nCONTROLS:\n\n[D-pad] - Navigate\n[A] - View details\n[LB/RB] - Switch guilds\n[Y] - Refresh\n[B] - Back to menu\n\n\nTIPS:\n\n- Scan weekly for accurate data\n- Compare guilds to find best trader\n- Track your top items" },

    { title = "Bookkeeper", text = "GUILD BOOKKEEPER\n\nComplete guild dues and member management.\n\n\nWHAT IT TRACKS:\n\n- Member deposit history\n- Dues payment status\n- Total contributions\n- Prepaid periods\n- Lifetime members\n- Exempt ranks\n- Trading activity\n\n\nMEMBER STATUS COLORS:\n\nGREEN 'PAID' - Current on dues\nYELLOW 'PRE' - Has prepaid time\nRED 'OWED' - Needs to pay\nCYAN 'LIFE' - Lifetime member\nPURPLE 'EXMT' - Exempt rank\n\n\nSETTING UP DUES:\n\n1. Open Bookkeeper\n2. Press [X] for Settings\n3. Set dues amount (e.g., 5000g)\n4. Set dues period (weekly/monthly)\n5. Set exempt ranks\n6. Configure deposit suffixes\n\n\nQUICK ACTIONS:\n\n- View member details\n- Update member note\n- Set member rank\n- Mark as lifetime\n- Kick member\n\n\nFILTER MODES:\n\n[Y] cycles through:\n- All Members\n- Unpaid Only\n- Paid Only\n- Name A-Z / Z-A\n- Last Paid\n\n\nCONTROLS:\n\n[D-pad] - Navigate members\n[A] - View details\n[X] - Settings\n[Y] - Cycle filter\n[RS] - Update note\n[LB/RB] - Switch guilds\n[B] - Back" },

    { title = "Guild Raffle", text = "GUILD RAFFLE\n\nRun professional guild raffles with ease.\n\n\nHOW IT WORKS:\n\n1. Set ticket price (e.g., 1000g)\n2. Members deposit gold to guild bank\n3. Addon assigns tickets automatically\n4. You pick a random winner!\n\n\nTICKET MODES:\n\nSIMPLE MODE:\nSet one price per ticket.\n5000g at 1000g/ticket = 5 tickets\n\nTICKET PACKS:\nCreate custom price/ticket combos.\nE.g., 1001g = 1 ticket, 5005g = 5 tickets\n\n\nBONUS TICKETS:\n\nRANK BONUSES:\nGive free tickets or multipliers\nto specific guild ranks.\n\nACTIVITY BONUSES:\n- Recruitment bonus\n- New member bonus\n- Trader sales bonus\n- Longevity bonus (per month)\n\n\nPICKING A WINNER:\n\n1. Open Guild Raffle\n2. Review all entries\n3. Press [Y] to draw winner\n4. Winner is announced!\n5. Press [Y] again to reroll\n\n\nCONTROLS:\n\n[D-pad] - Navigate entries\n[A] - View member tickets\n[X] - Raffle settings\n[Y] - Pick winner / Reroll\n[LB/RB] - Switch guilds\n[B] - Back" },

    { title = "Housing", text = "HOUSING DASHBOARD\n\nManage all your houses from one screen.\n\n\nWHAT YOU CAN SEE:\n\n- All houses you own\n- Furniture count per house\n- Traditional item limit/usage\n- Special item limit/usage\n- Collectible count\n- Capacity warnings (color coded)\n\n\nCAPACITY COLORS:\n\nGREEN - Under 70% full\nYELLOW - 70-90% full\nRED - Over 90% full\n\n\nFAVORITES:\n\nPress [Y] to favorite/unfavorite.\nUse filter to show favorites only.\n\n\nCACHING HOUSES:\n\nThe addon must CACHE each house:\n\n1. Select house, press [A] to travel\n2. Walk inside (auto-caches)\n3. Repeat for every house\n\nRe-cache after decorating!\n\n\nCACHING STORED FURNITURE:\n\n1. Enter any house\n2. Open Housing Editor\n3. Go to Place > Retrieve\n4. Stored items are now cached\n\n\nCONTROLS:\n\n[D-pad] - Select house\n[A] - Travel to house\n[Y] - Toggle favorite\n[X] - Cycle filter\n[LB] - Furniture Finder\n[RB] - Planner\n[B] - Back" },

    { title = "Furniture Finder", text = "FURNITURE FINDER\n\nSearch for ANY furniture across ALL houses.\n\n'Where did I put that table?'\nThis solves that problem.\n\n\nIMPORTANT:\n\nYou MUST cache each house first!\nThe addon can't see un-visited houses.\n\n\nHOW TO SEARCH:\n\n1. Open Furniture Finder\n2. Press [A] to open keyboard\n3. Type part of item name\n   (e.g., 'chair' or 'redguard')\n4. Press Enter to search\n5. Results show all matches\n\n\nRESULTS SHOW:\n\n- Item name\n- Which house it's in\n- How many you have\n- Placed or stored status\n\n\nSEARCH TIPS:\n\n- Partial names work: 'rug' finds all rugs\n- Style names work: 'nord' finds Nord items\n- Re-cache after decorating!\n\n\nCONTROLS:\n\n[A] - Open search keyboard\n[X] - Clear search\n[Y] - Add to Planner\n[D-pad] - Navigate results\n[LB] - Go to Planner\n[RB] - Housing Dashboard\n[B] - Back" },

    { title = "Plan Browser", text = "PLAN BROWSER\n\nBrowse EVERY furnishing plan in ESO.\n\n\nWHAT IT SHOWS:\n\n- All craftable furniture\n- Which plans YOU know (green)\n- Which plans ALTS know (yellow)\n- Which NO ONE knows (red)\n- Crafting station required\n- Materials needed\n\n\nCATEGORIES:\n\n- Blacksmithing\n- Clothing\n- Woodworking\n- Jewelry\n- Alchemy\n- Enchanting\n- Provisioning\n\n\nFILTERING:\n\n[Y] cycles through:\n- ALL items\n- UNKNOWN only\n- KNOWN only\n\n\nSEARCHING:\n\nPress [A] to search by name.\nGreat for finding specific items!\n\n\nADDING TO WISHLIST:\n\nPress [X] to add item to Planner.\nTrack what you want to craft!\n\n\nCONTROLS:\n\n[D-pad] - Navigate items\n[LB/RB] - Change category\n[LT/RT] - Page up/down\n[A] - Search\n[Y] - Cycle filter\n[X] - Add to Planner\n[B] - Back" },

    { title = "Planner", text = "PLANNER (Wishlist)\n\nOrganize furniture into project folders.\n\n\nWHAT IT DOES:\n\n- Create folders for projects\n- Add furniture items to folders\n- Track quantities needed\n- Check off items as acquired\n- Organize multiple builds\n\n\nCREATING A PROJECT:\n\n1. Open Planner\n2. Press [X] for 'New Folder'\n3. Type project name\n4. Press Enter to create\n\n\nADDING ITEMS:\n\n1. Open Plan Browser\n2. Find item you want\n3. Press [X] to add to Planner\n4. Item goes to active project\n\nTo change active project:\nSelect the folder in Planner.\n\n\nREMOVING ITEMS:\n\nNavigate to item, press [Y].\n\n\nUSE CASES:\n\n- Plan a new house build\n- Track guild hall items\n- Organize crafting goals\n- Shopping lists for traders\n\n\nCONTROLS:\n\n[D-pad] - Navigate\n[A] - Select folder\n[X] - New folder\n[Y] - Remove item\n[LB] - Housing Dashboard\n[RB] - Furniture Finder\n[B] - Back" },

    { title = "PVP Tracker", text = "PVP TRACKER\n\nTrack your Cyrodiil and Battlegrounds stats.\n\n\nCYRODIIL TRACKING:\n\nAlways-on tracking for:\n- Alliance Points earned\n- Kills\n- Deaths\n- K/D ratio\n- AP per hour\n\n\nTIME PERIODS:\n\n- Today's stats (resets daily)\n- All-time totals\n- Session stats (since login)\n\n\nBATTLEGROUNDS:\n\n- Matches played\n- Wins / Losses\n- Win rate\n- Kills / Deaths\n- Medals earned\n- Match history\n\n\nKILL TRACKING:\n\n- Kill feed (recent kills)\n- Nemesis tracking (who kills you)\n- Victim tracking (who you kill)\n\n\nHOW IT WORKS:\n\nStats track automatically!\nJust play PVP normally.\nOpen tracker to view stats.\n\n\nCONTROLS:\n\n[LB/RB] - Switch tabs\n[Y] - Refresh\n[B] - Back to menu" },

    { title = "Item Finder", text = "ITEM FINDER\n\nSearch inventory across ALL characters.\n\n\nWHAT IT SEARCHES:\n\n- All character inventories\n- Equipped items\n- Bank contents\n\n\nWHAT IT SHOWS:\n\n- Item name and icon\n- Quality (color coded)\n- Item type (Armor/Weapon/etc)\n- Level/CP requirement\n- Set name (if part of set)\n- Trait\n- Which character has it\n- Quantity\n\n\nHOW TO USE:\n\n1. Open Item Finder\n2. Press [A] to search\n3. Type item or set name\n4. View results across all chars\n\n\nSEARCH TIPS:\n\n- Search by set name: 'Mother's Sorrow'\n- Search by type: 'Staff'\n- Search by trait: 'Divines'\n- Partial names work\n\n\nCACHING:\n\nItems cache when you:\n- Log into a character\n- Open your inventory\n- Open your bank\n\n\nCONTROLS:\n\n[A] - Search\n[X] - Clear search\n[D-pad] - Navigate results\n[B] - Back" },

    { title = "Loot Log", text = "LOOT LOG\n\nTrack farming sessions and gold per hour.\n\n\nWHAT IT TRACKS:\n\n- All items looted\n- Item values (TTC prices)\n- Raw gold picked up\n- Session duration\n- Total value earned\n- Gold per hour rate\n- Items per hour\n- Best item dropped\n\n\nSTARTING A SESSION:\n\n1. Open Loot Log\n2. Press [A] to START\n3. Go farm!\n4. Press [A] to STOP\n5. View your results\n\n\nSESSION STATS:\n\n- Duration: Time farmed\n- Gold Looted: Raw gold\n- Items Value: TTC value\n- Total: Gold + Items\n- Gold/Hour: Efficiency rate\n- Items/Hour: Loot speed\n\n\nRESETTING:\n\nPress [X] to reset session.\nClears current data only.\n\n\nUSE CASES:\n\n- Compare farming spots\n- Track dungeon profit\n- Find best routes\n- Measure efficiency\n\n\nCONTROLS:\n\n[A] - Start/Stop session\n[X] - Reset session\n[Y] - Refresh display\n[D-pad] - Navigate loot\n[B] - Back" },

    { title = "Fishing", text = "FISHING TRACKER\n\nTrack Master Angler achievement progress.\n\n\nWHAT IT TRACKS:\n\n- Zone-by-zone progress\n- Fish caught per zone\n- Rare fish found\n- Achievement completion %\n- Total fish caught\n\n\nZONE ACHIEVEMENTS:\n\nTracks all base game zones:\n- Daggerfall Covenant (5 zones)\n- Ebonheart Pact (5 zones)\n- Aldmeri Dominion (5 zones)\n- Starter zones (3 zones)\n- Cyrodiil\n- Coldharbour\n\n207 unique fish total!\n\n\nFISH STATUS:\n\nGreen check = Caught\nRed X = Still needed\n\nSee exactly which fish you\nneed in each zone.\n\n\nWATER TYPES:\n\n- Foul (green/murky)\n- Lake/River (freshwater)\n- Ocean (saltwater)\n- Slaughterfish (red/bloody)\n\n\nCONTROLS:\n\n[D-pad] - Navigate zones\n[A] - View zone fish\n[Y] - Refresh\n[B] - Back" },

    { title = "Loot Radar", text = "LOOT RADAR\n\nFloating 3D pins show nearby containers.\n\nNever miss hidden treasure again!\n\n\nWHAT IT DETECTS:\n\n- Treasure chests\n- Heavy sacks\n- Thieves troves\n- Urns and vases\n- Barrels and crates\n- Wardrobes/dressers\n- Desks/nightstands\n- Cabinets/drawers\n- Backpacks\n- Trunks\n\n\nHOW IT WORKS:\n\nWhen enabled, floating pins appear\nabove nearby containers:\n\n- GOLD pins = Chests, heavy sacks\n- GREEN pins = Normal containers\n- RED pins = Owned (stealing)\n\nPins show distance to container.\nPins hide after you loot.\n\n\nENABLING:\n\n1. Open Settings\n2. Turn ON Loot Radar\n3. Type /reloadui\n\n\nBEST USES:\n\n- Finding hidden delve chests\n- Dungeon container sweeps\n- Never missing lootables\n- Achievement chest hunting\n\n\nTIPS:\n\n- Great for delve clears\n- Disable if distracting\n- Combines with Loot Log" },

    { title = "Settings", text = "SETTINGS\n\nToggle addon features on or off.\n\n\nWHY TOGGLE?\n\n- Disable unused features\n- Reduce memory usage\n- Simplify the menu\n- Fix any conflicts\n\n\nFEATURES YOU CAN TOGGLE:\n\n- Net Worth Tracker\n- Gold Ledger\n- Guild Sales Tracker\n- Guild Bookkeeper\n- Guild Raffle\n- Housing Dashboard\n- Plan Browser\n- Planner\n- PVP Tracker\n- Item Finder\n- Loot Log\n- Fishing Tracker\n- Loot Radar\n\n\nAPPLYING CHANGES:\n\nChanges require UI reload!\n\nPress [X] to reload UI\nOR type /reloadui in chat\n\n\nSTATUS INDICATORS:\n\nGREEN 'ON' = Feature enabled\nRED 'OFF' = Feature disabled\n\n\nCONTROLS:\n\n[D-pad] - Navigate options\n[A] - Toggle on/off\n[X] - Reload UI\n[B] - Back" },

    { title = "Tips & Commands", text = "TIPS AND SLASH COMMANDS\n\n\nSLASH COMMANDS:\n\n/atk - Open Settings\n/nw - Toggle Net Worth HUD\n/nwf scan - Cache house furniture\n/nwf [name] - Search furniture\n/pb or /plans - Plan Browser\n/gst - Guild Sales commands\n/bk - Guild Bookkeeper\n/house - Housing Dashboard\n/planner - Open Planner\n/fishing - Fishing Tracker\n/pvp - PVP Tracker\n\n\nPRO TIPS:\n\n1. CACHE EVERYTHING FIRST\n   Visit bank, craft bag, furniture\n   vault, and all houses before\n   checking Net Worth.\n\n2. RE-CACHE AFTER CHANGES\n   Moved furniture? Visit that house.\n   Deposited items? Open your bank.\n\n3. SCAN GUILDS WEEKLY\n   Visit guild banks to keep sales\n   and dues data current.\n\n4. USE THE PLANNER\n   Press [X] in Plan Browser to\n   save items you want to craft.\n\n5. CHECK GOLD LEDGER\n   Find where your gold goes.\n   Track spending leaks!\n\n6. ENABLE LOOT RADAR\n   Never miss delve chests again.\n\n\nCONTROLLER BUTTONS:\n\n[A] - Primary action\n[B] - Back / Close\n[X] - Secondary action\n[Y] - Tertiary / Refresh\n[LB/RB] - Switch views\n[LT/RT] - Page up/down\n[D-pad] - Navigate\n\n\nThank you for using\nAdventurer's Toolkit!" },
}

-- Hidden list screen for D-pad navigation
local ATK_HiddenHelpListScreen = ZO_Gamepad_ParametricList_Screen:Subclass()
function ATK_HiddenHelpListScreen:New(control) return ZO_Gamepad_ParametricList_Screen.New(self, control) end
function ATK_HiddenHelpListScreen:Initialize(control) ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, HELP_DASHBOARD_SCENE) end
function ATK_HiddenHelpListScreen:PerformUpdate() end
function ATK_HiddenHelpListScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Select", keybind = "UI_SHORTCUT_PRIMARY", callback = function() NWT.HelpSelectTopic() end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Topics", keybind = "UI_SHORTCUT_LEFT_SHOULDER", callback = function() NWT.HelpSwitchPanel("topics") end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Content", keybind = "UI_SHORTCUT_RIGHT_SHOULDER", callback = function() NWT.HelpSwitchPanel("content") end },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function() NWT.CloseHelpDashboard() end)
end

function NWT.HelpSwitchPanel(panel)
    local h = NWT.HelpDashboard
    h.focusPanel = panel
    if panel == "content" then
        h.contentScrollOffset = 0
    end
    PlaySound(SOUNDS.HORIZONTAL_LIST_TRACK_SELECTED)
    NWT.UpdateHelpDashboard()
end

function NWT.InitHelpDashboardScene()
    if HELP_DASHBOARD_SCENE then return end
    local ui = ATK_Help_UI or ATK_Help_UI
    if not ui then return end
    
    -- Create hidden control for D-pad navigation
    local hc = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenHelpList", GuiRoot, "ATK_HouseList_Screen")
    hc:SetHidden(true) hc:SetAlpha(0)
    
    HELP_DASHBOARD_SCENE = ZO_Scene:New("helpDashboardScene", SCENE_MANAGER)
    HELP_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    HELP_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    HELP_DASHBOARD_SCENE:AddFragment(ZO_SimpleSceneFragment:New(ui))
    HELP_DASHBOARD_SCENE:AddFragment(ZO_SimpleSceneFragment:New(hc))
    
    NWT.HiddenHelpListScreen = ATK_HiddenHelpListScreen:New(hc)
    NWT.HiddenHelpList = NWT.HiddenHelpListScreen:GetMainList()
    NWT.HiddenHelpList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function(c, d) end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    
    -- Override D-pad movement
    NWT.HiddenHelpList.MovePrevious = function(self, ...) NWT.HelpNavigate("up") end
    NWT.HiddenHelpList.MoveNext = function(self, ...) NWT.HelpNavigate("down") end
    
    HELP_DASHBOARD_SCENE:RegisterCallback("StateChange", function(os, ns)
        if ns == SCENE_SHOWING then
            NWT.HelpDashboard.isOpen = true
            NWT.HelpDashboard.selectedTopic = 1
            NWT.SyncHiddenHelpList()
            NWT.UpdateHelpDashboard()
        elseif ns == SCENE_HIDDEN then
            NWT.HelpDashboard.isOpen = false
        end
    end)
end

function NWT.SyncHiddenHelpList()
    if not NWT.HiddenHelpList then return end
    NWT.HiddenHelpList:Clear()
    for i, page in ipairs(helpPages) do
        local ed = ZO_GamepadEntryData:New(page.title)
        ed.index = i
        NWT.HiddenHelpList:AddEntry("ZO_GamepadItemEntryTemplate", ed)
    end
    NWT.HiddenHelpList:Commit()
    if NWT.HelpDashboard.selectedTopic then
        NWT.HiddenHelpList:SetSelectedIndexWithoutAnimation(NWT.HelpDashboard.selectedTopic)
    end
end

function NWT.HelpNavigate(dir)
    local h = NWT.HelpDashboard
    
    if h.focusPanel == "content" then
        -- Scroll content up/down
        local page = helpPages[h.currentPage] or helpPages[1]
        local lineCount = 0
        for _ in page.text:gmatch("[^\n]*") do lineCount = lineCount + 1 end
        local maxScroll = math.max(0, lineCount - 20)
        
        if dir == "up" then
            h.contentScrollOffset = math.max(0, h.contentScrollOffset - 3)
        elseif dir == "down" then
            h.contentScrollOffset = math.min(maxScroll, h.contentScrollOffset + 3)
        end
        PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
        NWT.UpdateHelpDashboard()
        return
    end
    
    -- Navigate topics
    if dir == "up" then
        h.selectedTopic = h.selectedTopic - 1
        if h.selectedTopic < 1 then h.selectedTopic = #helpPages end
        -- Adjust scroll to keep selection visible
        if h.selectedTopic < h.topicScrollOffset + 1 then
            h.topicScrollOffset = h.selectedTopic - 1
        elseif h.selectedTopic > h.topicScrollOffset + MAX_VISIBLE_TOPICS then
            h.topicScrollOffset = h.selectedTopic - MAX_VISIBLE_TOPICS
        end
        -- Handle wrap-around
        if h.selectedTopic == #helpPages then
            h.topicScrollOffset = math.max(0, #helpPages - MAX_VISIBLE_TOPICS)
        elseif h.selectedTopic == 1 then
            h.topicScrollOffset = 0
        end
    elseif dir == "down" then
        h.selectedTopic = h.selectedTopic + 1
        if h.selectedTopic > #helpPages then h.selectedTopic = 1 end
        -- Adjust scroll to keep selection visible
        if h.selectedTopic > h.topicScrollOffset + MAX_VISIBLE_TOPICS then
            h.topicScrollOffset = h.selectedTopic - MAX_VISIBLE_TOPICS
        elseif h.selectedTopic < h.topicScrollOffset + 1 then
            h.topicScrollOffset = h.selectedTopic - 1
        end
        -- Handle wrap-around
        if h.selectedTopic == 1 then
            h.topicScrollOffset = 0
        elseif h.selectedTopic == #helpPages then
            h.topicScrollOffset = math.max(0, #helpPages - MAX_VISIBLE_TOPICS)
        end
    end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateHelpDashboard()
end

function NWT.HelpSelectTopic()
    NWT.HelpDashboard.currentPage = NWT.HelpDashboard.selectedTopic
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateHelpDashboard()
end

function NWT.UpdateHelpDashboard()
    local ui = ATK_Help_UI or ATK_Help_UI
    if not ui then return end
    local h = NWT.HelpDashboard
    local page = helpPages[h.currentPage] or helpPages[1]
    local isTopicsFocus = (h.focusPanel == "topics")
    local isContentFocus = (h.focusPanel == "content")
    
    -- Try new UI structure first
    local leftCol = ui:GetNamedChild("LeftCol")
    local topicsCard = leftCol and leftCol:GetNamedChild("TopicsCard")
    local topicsList = topicsCard and topicsCard:GetNamedChild("List")
    
    -- Update topics card border color based on focus
    if topicsCard then
        local tBG = topicsCard:GetNamedChild("BG")
        local tFocus = topicsCard:GetNamedChild("FocusGlow")
        if tBG then tBG:SetEdgeColor(isTopicsFocus and 0 or 0.3, isTopicsFocus and 0.8 or 0.3, isTopicsFocus and 0.8 or 0.3, 1) end
        if tFocus then tFocus:SetHidden(not isTopicsFocus) end
    end
    
    -- Populate topics list on the left (with scrolling)
    if topicsList then
        local selFrame = topicsList:GetNamedChild("SelectionFrame")
        for i = 1, MAX_VISIBLE_TOPICS do
            local row = topicsList:GetNamedChild("Row" .. i)
            if row then
                local topicIndex = i + h.topicScrollOffset
                local topic = helpPages[topicIndex]
                if topic then
                    local isSel = (topicIndex == h.selectedTopic)
                    local isCurrent = (topicIndex == h.currentPage)
                    local prefix = isSel and "► " or "  "
                    local color = isCurrent and "|cFFD700" or (isSel and "|c00FFFF" or "|cFFFFFF")
                    row:SetText(prefix .. color .. topic.title .. "|r")
                    row:SetHidden(false)
                    
                    if isSel and selFrame and isTopicsFocus then
                        selFrame:ClearAnchors()
                        selFrame:SetAnchor(TOPLEFT, row, TOPLEFT, -5, -2)
                        selFrame:SetHidden(false)
                    end
                else
                    row:SetHidden(true)
                end
            end
        end
        -- Hide extra rows beyond MAX_VISIBLE_TOPICS
        for i = MAX_VISIBLE_TOPICS + 1, 16 do
            local row = topicsList:GetNamedChild("Row" .. i)
            if row then row:SetHidden(true) end
        end
        if selFrame and not isTopicsFocus then selFrame:SetHidden(true) end
    end
    
    -- Update content on the right
    local rightCol = ui:GetNamedChild("RightCol")
    local contentCard = rightCol and rightCol:GetNamedChild("ContentCard")
    
    if contentCard then
        local cBG = contentCard:GetNamedChild("BG")
        if cBG then cBG:SetEdgeColor(isContentFocus and 0 or 0.3, isContentFocus and 0.8 or 0.3, isContentFocus and 0.8 or 0.3, 1) end
        
        local topicTitle = contentCard:GetNamedChild("TopicTitle")
        local content = contentCard:GetNamedChild("Content")
        if topicTitle then topicTitle:SetText(page.title) end
        
        -- Apply scroll offset to content
        if content then
            local lines = {}
            for line in page.text:gmatch("[^\n]*") do
                table.insert(lines, line)
            end
            local startLine = h.contentScrollOffset + 1
            local visibleLines = {}
            for i = startLine, math.min(#lines, startLine + 25) do
                table.insert(visibleLines, lines[i] or "")
            end
            content:SetText(table.concat(visibleLines, "\n"))
        end
    else
        -- Fallback to old UI
        local title = ui:GetNamedChild("Title")
        local pageInd = ui:GetNamedChild("PageIndicator")
        local content = ui:GetNamedChild("Content")
        if title then title:SetText("|cFFD700HELP - " .. page.title .. "|r") end
        if pageInd then pageInd:SetText("|c888888Page " .. h.currentPage .. " of " .. #helpPages .. "|r") end
        if content then content:SetText(page.text) end
    end
    
    -- Update footer
    local footer = ui:GetNamedChild("Footer")
    if footer then
        if isTopicsFocus then
            footer:SetText("|c888888[D-Pad] Navigate  [A] Select  [RB] Read Content  [B] Back|r")
        else
            footer:SetText("|c888888[D-Pad] Scroll  [LB] Back to Topics  [B] Back|r")
        end
    end
end

function NWT.HelpNextPage()
    NWT.HelpDashboard.currentPage = NWT.HelpDashboard.currentPage + 1
    if NWT.HelpDashboard.currentPage > #helpPages then NWT.HelpDashboard.currentPage = 1 end
    PlaySound(SOUNDS.HORIZONTAL_LIST_TRACK_SELECTED)
    NWT.UpdateHelpDashboard()
end

function NWT.HelpPrevPage()
    NWT.HelpDashboard.currentPage = NWT.HelpDashboard.currentPage - 1
    if NWT.HelpDashboard.currentPage < 1 then NWT.HelpDashboard.currentPage = #helpPages end
    PlaySound(SOUNDS.HORIZONTAL_LIST_TRACK_SELECTED)
    NWT.UpdateHelpDashboard()
end

function NWT.OpenHelpDashboard()
    if NWT.HelpDashboard.isOpen then return end
    if not HELP_DASHBOARD_SCENE then NWT.InitHelpDashboardScene() end
    SCENE_MANAGER:Push("helpDashboardScene")
end

function NWT.CloseHelpDashboard() if HELP_DASHBOARD_SCENE then SCENE_MANAGER:Hide("helpDashboardScene") end end
