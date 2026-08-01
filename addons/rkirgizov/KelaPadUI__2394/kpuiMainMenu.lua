


-- главное меню

--обнуляем
ZO_MENU_ENTRIES = {}

--Main Menu Categories
--zo_mainmenu_manager.lua
MENU_CATEGORY_MARKET = 1
MENU_CATEGORY_CROWN_CRATES = 2
MENU_CATEGORY_INVENTORY = 3
MENU_CATEGORY_CHARACTER = 4
MENU_CATEGORY_SKILLS = 5
MENU_CATEGORY_CHAMPION = 6
MENU_CATEGORY_JOURNAL = 7
MENU_CATEGORY_COLLECTIONS = 8
MENU_CATEGORY_MAP = 9
MENU_CATEGORY_GROUP = 10
MENU_CATEGORY_CONTACTS = 11
MENU_CATEGORY_GUILDS = 12
MENU_CATEGORY_ALLIANCE_WAR = 13
MENU_CATEGORY_MAIL = 14
MENU_CATEGORY_NOTIFICATIONS = 15
MENU_CATEGORY_HELP = 16
MENU_CATEGORY_ACTIVITY_FINDER = 17
MENU_CATEGORY_GIFT_INVENTORY = 18
--Kela Main Menu Categories
KELAPADUI_CATEGORY_RESEARCHING = 19
KELAPADUI_CATEGORY_SETS = 20
KELAPADUI_CATEGORY_UNDAUNTED = 21


local MENU_MAIN_ENTRIES =
{
    CROWN_STORE     = 1,
	KELAPADUI		= 2,
    ANNOUNCEMENTS   = 3,
    NOTIFICATIONS   = 4,
    COLLECTIONS     = 5,
    INVENTORY       = 6,
    CHARACTER       = 7,
    SKILLS          = 8,
    CHAMPION        = 9,
    CAMPAIGN        = 10,
    JOURNAL         = 11,
    SOCIAL          = 12,
    ACTIVITY_FINDER = 13,
    HELP            = 14,
    OPTIONS         = 15,
    LOG_OUT         = 16,
}
local MENU_CROWN_STORE_ENTRIES =
{
    CROWN_STORE         = 1,
    DAILY_LOGIN_REWARDS = 2,
    CROWN_CRATES        = 3,
    CHAPTERS            = 4,
    GIFT_INVENTORY      = 5,
    REDEEM_CODE         = 6,
}
local MENU_JOURNAL_ENTRIES =
{
    QUESTS              = 1,
    CADWELLS_JOURNAL    = 2,
    ANTIQUITIES         = 3,
    LORE_LIBRARY        = 4,
    ACHIEVEMENTS        = 5,
    LEADERBOARDS        = 6,
}
local MENU_SOCIAL_ENTRIES =
{
    VOICE_CHAT  = 1,
    TEXT_CHAT   = 2,
    EMOTES      = 3,
    GROUP       = 4,
    GUILDS      = 5,
    FRIENDS     = 6,
    IGNORED     = 7,
    MAIL        = 8,
}
local KELAPADUI_ENTRIES =
{
    RESEARCHING = 1,
    SETS  		= 2,
    UNDAUNTED 	= 3,
}


local MENU_ENTRY_DATA =
{
    [MENU_MAIN_ENTRIES.CROWN_STORE] =
    {
        customTemplate = "ZO_GamepadMenuCrownStoreEntryTemplate",
        name = GetString(SI_GAMEPAD_MAIN_MENU_CROWN_STORE_CATEGORY),
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_PlayerMenu_icon_store.dds",
        header = zo_iconTextFormatNoSpace("EsoUI/Art/Market/Gamepad/gp_ESOPlus_Chalice_GOLD_64.dds", 32, 32, ZO_MARKET_PRODUCT_ESO_PLUS_COLOR:Colorize(GetString(SI_ESO_PLUS_TITLE))),
        postPadding = 70,
        showHeader = function() return IsESOPlusSubscriber() end,
        isNewCallback = function(entryData)
            for entryIndex, entry in ipairs(entryData.subMenu) do
                if entry:IsNew() then
                    return true
                end
            end
            return false
        end,
        subMenu =
        {
            [MENU_CROWN_STORE_ENTRIES.CROWN_STORE] =
            {
                scene = "gamepad_market_pre_scene",
                sceneGroup = "gamepad_market_scenegroup",
                name = GetString(SI_GAMEPAD_MAIN_MENU_CROWN_STORE_ENTRY),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_PlayerMenu_icon_store.dds",
            },
            [MENU_CROWN_STORE_ENTRIES.DAILY_LOGIN_REWARDS] =
            {
                name = GetString(SI_GAMEPAD_MAIN_MENU_DAILY_LOGIN_REWARDS_ENTRY),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_dailyLoginRewards.dds",
                shouldDisableFunction = function()
                    return ZO_DAILYLOGINREWARDS_MANAGER:IsDailyRewardsLocked() or not ZO_DAILYLOGINREWARDS_MANAGER:HasClaimableRewardInMonth()
                end,
                fragmentGroupCallback = function()
                    return {ZO_DAILY_LOGIN_REWARDS_GAMEPAD:GetFragment(), GAMEPAD_NAV_QUADRANT_2_3_BACKGROUND_FRAGMENT}
                end,
                activatedCallback = function(self)
                    self:ActivateHelperPanel(ZO_DAILY_LOGIN_REWARDS_GAMEPAD)
                end,
                isNewCallback = function()
                    return GetDailyLoginClaimableRewardIndex() ~= nil
                end,
            },
            [MENU_CROWN_STORE_ENTRIES.CROWN_CRATES] =
            {
                scene = "crownCrateGamepad",
                name = GetString(SI_MAIN_MENU_CROWN_CRATES),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_crownCrates.dds",
                disableWhenDead = true,
                disableWhenReviving = true,
                disableWhenSwimming = true,
                disableWhenWerewolf = true,
                isNewCallback = function()
                    return GetNumOwnedCrownCrateTypes() > 0
                end,
                isVisibleCallback = function()
                    --An unusual case, we don't want to blow away this option if you're already in the scene when it's disabled
                    --Crown crates will properly refresh again when it closes its scene
                    return CanInteractWithCrownCratesSystem() or SYSTEMS:IsShowing("crownCrate")
                end,
            },
            [MENU_CROWN_STORE_ENTRIES.CHAPTERS] =
            {
                scene = "chapterUpgradeGamepad",
                sceneGroup = "gamepad_chapterUpgrade_scenegroup",
                name = GetString(SI_MAIN_MENU_CHAPTERS),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_chapters.dds",
                isVisibleCallback = function()
                    return ZO_CHAPTER_UPGRADE_MANAGER:GetNumChapterUpgrades() > 0
                end,
            },
            [MENU_CROWN_STORE_ENTRIES.GIFT_INVENTORY] =
            {
                scene = "giftInventoryGamepad",
                name = GetString(SI_MAIN_MENU_GIFT_INVENTORY),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_giftInventory.dds",
                isNewCallback = function()
                    return GIFT_INVENTORY_MANAGER and GIFT_INVENTORY_MANAGER:HasAnyUnseenGifts()
                end,
            },
            [MENU_CROWN_STORE_ENTRIES.REDEEM_CODE] =
            {
                scene = "codeRedemptionGamepad",
                name = GetString(SI_MAIN_MENU_REDEEM_CODE),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_redeemCode.dds",
                isVisibleCallback = function()
                    local serviceType = GetPlatformServiceType()
                    return serviceType ~= PLATFORM_SERVICE_TYPE_DMM
                end,
            },
        },
    },
	[MENU_MAIN_ENTRIES.KELAPADUI] =
	{
        customTemplate = "ZO_GamepadMenuEntryTemplateWithArrow",
        name = GetString(KELA_MAINMENU_TITLE),
        --icon = "EsoUI/Art/MenuBar/Gamepad/gp_PlayerMenu_icon_store.dds",
		-- activatedCallback = function()
			-- local list = KELA_ROOT_GAMEPAD:GetMainList()
			-- local entry = list:GetTargetData()
			-- KelaMainMenuRefreshSubList(entry)
			-- --kelaAddInfoTooltipResearchMain() 
		-- end,
		subMenu = 
		{
			[KELAPADUI_ENTRIES.RESEARCHING] =
            {
				scene = "kelaResearch",
                --sceneGroup = "gamepad_market_scenegroup",
                header = GetString(KELA_MAINMENU_TITLE),
				name = GetString(KELA_MAINMENU_RESEARCHING),
                icon = "esoui/art/crafting/gamepad/gp_crafting_menuicon_research.dds",
            },
			[KELAPADUI_ENTRIES.SETS] =
            {
                scene = "kelaSets",
                name = GetString(KELA_MAINMENU_SETS),
                icon = "esoui/art/treeicons/gamepad/gp_collectionicon_weapona+armor.dds",
            },
			[KELAPADUI_ENTRIES.UNDAUNTED] =
            {
                scene = "kelaUndaunted",
                name = GetString(KELA_MAINMENU_UNDAUNTED),
                icon = "EsoUI/art/icons/servicemappins/servicepin_undaunted.dds",
            },
		}
	},
    [MENU_MAIN_ENTRIES.ANNOUNCEMENTS] =
    {
        name = GetString(SI_MAIN_MENU_ANNOUNCEMENTS),
        icon = "EsoUI/Art/AnnounceWindow/gamepad/gp_announcement_Icon.dds",
        activatedCallback = function()
            SCENE_MANAGER:Show("marketAnnouncement")
            RequestMarketAnnouncement()
        end,
    },
    [MENU_MAIN_ENTRIES.NOTIFICATIONS] =
    {
        scene = "gamepad_notifications_root",
        name = function()
            local numNotifications = GAMEPAD_NOTIFICATIONS and GAMEPAD_NOTIFICATIONS:GetNumNotifications() or 0
            return zo_strformat(SI_GAMEPAD_MAIN_MENU_NOTIFICATIONS, numNotifications)
        end,
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_notifications.dds",
        isNewCallback = function()
            return true --new icon indicator should always display
        end,
        isVisibleCallback = function()
            if GAMEPAD_NOTIFICATIONS then
                return GAMEPAD_NOTIFICATIONS:GetNumNotifications() > 0
            else
                return false
            end
        end,
    },
    [MENU_MAIN_ENTRIES.COLLECTIONS] =
    {
        scene = "gamepadCollectionsBook",
        name = GetString(SI_MAIN_MENU_COLLECTIONS),
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_collections.dds",
        isNewCallback = function()
            return ZO_COLLECTIBLE_DATA_MANAGER:HasAnyNewCollectibles()
        end,
    },
    [MENU_MAIN_ENTRIES.INVENTORY] =
    {
        scene = "gamepad_inventory_root",
        name = GetString(SI_MAIN_MENU_INVENTORY),
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_inventory.dds",
        isNewCallback = function()
            return SHARED_INVENTORY:AreAnyItemsNew(nil, nil, BAG_BACKPACK, BAG_VIRTUAL)
        end,
    },
    [MENU_MAIN_ENTRIES.CHARACTER] =
    {
        scene = "gamepad_stats_root",
        name = GetString(SI_MAIN_MENU_CHARACTER),
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_character.dds",
        canLevel = function()
            return HasPendingLevelUpReward() or GetAttributeUnspentPoints() > 0
        end
    },
    [MENU_MAIN_ENTRIES.SKILLS] =
    {
        scene = "gamepad_skills_root",
        customTemplate = "ZO_GamepadNewAnimatingMenuEntryTemplate",
        name = GetString(SI_MAIN_MENU_SKILLS),
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_skills.dds",
        canLevel = function()
            return GetAvailableSkillPoints() > 0
        end,
        isNewCallback =  function()
            return SKILLS_DATA_MANAGER and SKILLS_DATA_MANAGER:AreAnySkillLinesOrAbilitiesNew()
        end,
    },
    [MENU_MAIN_ENTRIES.CHAMPION] =
    {
        scene = "gamepad_championPerks_root",
        name = GetString(SI_MAIN_MENU_CHAMPION),
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_champion.dds",
        isNewCallback = function()
            if CHAMPION_PERKS then
                return CHAMPION_PERKS:IsChampionSystemNew()
            end
        end,
        isVisibleCallback = function()
            return IsChampionSystemUnlocked()
        end,
        canLevel = function()
            if CHAMPION_PERKS then
                return CHAMPION_PERKS:HasAnySpendableUnspentPoints()
            end
        end,
    },
    [MENU_MAIN_ENTRIES.CAMPAIGN] =
    {
        scene = "gamepad_campaign_root",
        name = GetString(SI_PLAYER_MENU_CAMPAIGNS),
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_allianceWar.dds",
        isNewCallback = function()
            local tutorialId = GetTutorialId(TUTORIAL_TRIGGER_CAMPAIGN_BROWSER_OPENED)
            if CanTutorialBeSeen(tutorialId) then
                return not HasSeenTutorial(tutorialId)
            end
            return false
        end,
        isVisibleCallback = function()
            local currentLevel = GetUnitLevel("player")
            return currentLevel >= GetMinLevelForCampaignTutorial()
        end,
    },
    [MENU_MAIN_ENTRIES.JOURNAL] =
    {
        customTemplate = "ZO_GamepadMenuEntryTemplateWithArrow",
        name = GetString(SI_MAIN_MENU_JOURNAL),
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_journal.dds",
        isNewCallback = function()
            return ANTIQUITY_DATA_MANAGER and ANTIQUITY_DATA_MANAGER:HasNewLead()
        end,
        subMenu =
        {
            [MENU_JOURNAL_ENTRIES.QUESTS] =
            {
                scene = "gamepad_quest_journal",
                name = GetString(SI_GAMEPAD_MAIN_MENU_JOURNAL_QUESTS),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_quests.dds",
                header = GetString(SI_MAIN_MENU_JOURNAL),
            },
            [MENU_JOURNAL_ENTRIES.CADWELLS_JOURNAL] =
            {
                scene = "cadwellGamepad",
                name = GetString(SI_GAMEPAD_MAIN_MENU_JOURNAL_CADWELL),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_cadwell.dds",
                isVisibleCallback = function()
                    return GetCadwellProgressionLevel() > CADWELL_PROGRESSION_LEVEL_BRONZE
                end,
            },
            [MENU_JOURNAL_ENTRIES.ANTIQUITIES] =
            {
                scene = "gamepad_antiquity_journal",
                name = GetString(SI_JOURNAL_MENU_ANTIQUITIES),
                icon = "EsoUI/Art/Journal/Gamepad/GP_journal_tabIcon_antiquities.dds",
                isNewCallback = function()
                    return ANTIQUITY_DATA_MANAGER and ANTIQUITY_DATA_MANAGER:HasNewLead()
                end,
            },
            [MENU_JOURNAL_ENTRIES.LORE_LIBRARY] =
            {
                scene = "loreLibraryGamepad",
                name = GetString(SI_GAMEPAD_MAIN_MENU_JOURNAL_LORE_LIBRARY),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_loreLibrary.dds",
            },
            [MENU_JOURNAL_ENTRIES.ACHIEVEMENTS] =
            {
                scene = "achievementsGamepad",
                name = GetString(SI_GAMEPAD_MAIN_MENU_JOURNAL_ACHIEVEMENTS),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_achievements.dds",
            },
            [MENU_JOURNAL_ENTRIES.LEADERBOARDS] =
            {
                scene = "gamepad_leaderboards",
                name = GetString(SI_JOURNAL_MENU_LEADERBOARDS),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_leaderBoards.dds",
            },
        }
    },
    [MENU_MAIN_ENTRIES.SOCIAL] =
    {
        customTemplate = "ZO_GamepadMenuEntryTemplateWithArrow",
        name = GetString(SI_MAIN_MENU_SOCIAL),
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_multiplayer.dds",
        isNewCallback = function()
            return HasUnreadMail()
        end,
        subMenu =
        {
            [MENU_SOCIAL_ENTRIES.VOICE_CHAT] =
            {
                scene = "gamepad_voice_chat",
                name = GetString(SI_MAIN_MENU_GAMEPAD_VOICECHAT),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_communications.dds",
                header = GetString(SI_MAIN_MENU_SOCIAL),
                isVisibleCallback = IsConsoleUI
            },
            [MENU_SOCIAL_ENTRIES.TEXT_CHAT] =
            {
                scene = "gamepadChatMenu",
                name = GetString(SI_GAMEPAD_TEXT_CHAT),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_textChat.dds",
                header = not IsConsoleUI() and GetString(SI_MAIN_MENU_SOCIAL) or nil,
                isVisibleCallback = IsChatSystemAvailableForCurrentPlatform
            },
            [MENU_SOCIAL_ENTRIES.EMOTES] =
            {
                scene = "gamepad_player_emote",
                name = GetString(SI_GAMEPAD_MAIN_MENU_EMOTES),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_emotes.dds",
                header = (not IsConsoleUI() and not IsChatSystemAvailableForCurrentPlatform()) and GetString(SI_MAIN_MENU_SOCIAL) or nil,
            },
            [MENU_SOCIAL_ENTRIES.GROUP] =
            {
                scene = "gamepad_groupList",
                name = GetString(SI_PLAYER_MENU_GROUP),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_groups.dds",
            },
            [MENU_SOCIAL_ENTRIES.GUILDS] =
            {
                scene = "gamepad_guild_hub",
                name = GetString(SI_MAIN_MENU_GUILDS),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_guilds.dds",
            },
            [MENU_SOCIAL_ENTRIES.FRIENDS] =
            {
                scene = "gamepad_friends",
                name = GetString(SI_GAMEPAD_CONTACTS_FRIENDS_LIST_TITLE),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_contacts.dds",
            },
            [MENU_SOCIAL_ENTRIES.IGNORED] =
            {
                scene = "gamepad_ignored",
                name = GetString(SI_GAMEPAD_CONTACTS_IGNORED_LIST_TITLE),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_contacts.dds",
                isVisibleCallback = function()
                    return not IsConsoleUI()
                end,
            },
            [MENU_SOCIAL_ENTRIES.MAIL] =
            {
                scene = "mailManagerGamepad",
                name = GetString(SI_MAIN_MENU_MAIL),
                icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_mail.dds",
                isNewCallback = function()
                    return HasUnreadMail()
                end,
                disableWhenDead = true,
                disableWhenInCombat = true,
                disableWhenReviving = true,
            },
        }
    },
    [MENU_MAIN_ENTRIES.ACTIVITY_FINDER] =
    {
        scene = ZO_GAMEPAD_ACTIVITY_FINDER_ROOT_SCENE_NAME,
        name = GetString(SI_MAIN_MENU_ACTIVITY_FINDER),
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_activityFinder.dds",
    },
    [MENU_MAIN_ENTRIES.HELP] =
    {
        scene = "helpRootGamepad",
        name = GetString(SI_MAIN_MENU_HELP),
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_help.dds",
    },
    [MENU_MAIN_ENTRIES.OPTIONS] =
    {
        scene = "gamepad_options_root",
        name = GetString(SI_GAMEPAD_OPTIONS_MENU),
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_settings.dds",
    },
    [MENU_MAIN_ENTRIES.LOG_OUT] =
    {
        name = GetString(SI_GAME_MENU_LOGOUT),
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_logout.dds",
        activatedCallback = function()
            ZO_Dialogs_ShowGamepadDialog("GAMEPAD_LOG_OUT")
        end,
    },
}

CATEGORY_TO_ENTRY_DATA =
{
    [MENU_CATEGORY_NOTIFICATIONS]   = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.NOTIFICATIONS],
    [MENU_CATEGORY_MARKET]          = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.CROWN_STORE].subMenu[MENU_CROWN_STORE_ENTRIES.CROWN_STORE],
    [MENU_CATEGORY_CROWN_CRATES]    = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.CROWN_STORE].subMenu[MENU_CROWN_STORE_ENTRIES.CROWN_CRATES],
    [MENU_CATEGORY_GIFT_INVENTORY]  = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.CROWN_STORE].subMenu[MENU_CROWN_STORE_ENTRIES.GIFT_INVENTORY],
    [MENU_CATEGORY_COLLECTIONS]     = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.COLLECTIONS],
    [MENU_CATEGORY_INVENTORY]       = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.INVENTORY],
    [MENU_CATEGORY_CHARACTER]       = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.CHARACTER],
    [MENU_CATEGORY_SKILLS]          = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.SKILLS],
    [MENU_CATEGORY_CHAMPION]        = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.CHAMPION],
    [MENU_CATEGORY_ALLIANCE_WAR]    = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.CAMPAIGN],
    [MENU_CATEGORY_JOURNAL]         = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.JOURNAL].subMenu[MENU_JOURNAL_ENTRIES.QUESTS],
    [MENU_CATEGORY_GROUP]           = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.SOCIAL].subMenu[MENU_SOCIAL_ENTRIES.GROUP],
    [MENU_CATEGORY_CONTACTS]        = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.SOCIAL].subMenu[MENU_SOCIAL_ENTRIES.FRIENDS],
    [MENU_CATEGORY_GUILDS]          = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.SOCIAL].subMenu[MENU_SOCIAL_ENTRIES.GUILDS],
    [MENU_CATEGORY_MAIL]            = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.SOCIAL].subMenu[MENU_SOCIAL_ENTRIES.MAIL],
    [MENU_CATEGORY_ACTIVITY_FINDER] = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.ACTIVITY_FINDER],
    [MENU_CATEGORY_HELP]            = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.HELP],
    [KELAPADUI_CATEGORY_RESEARCHING]      = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.KELAPADUI].subMenu[KELAPADUI_ENTRIES.RESEARCHING], 	--KELAPADUI
    [KELAPADUI_CATEGORY_SETS]  			= MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.KELAPADUI].subMenu[KELAPADUI_ENTRIES.SETS],
    [KELAPADUI_CATEGORY_UNDAUNTED]        = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.KELAPADUI].subMenu[KELAPADUI_ENTRIES.UNDAUNTED],
    [MENU_CATEGORY_MAP]             = { scene = "gamepad_worldMap" }, --no gamepad menu entry for world map
}

local function CreateEntry(data)
    local name = data.name
    if type(name) == "function" then
        name = "" --will be updated whenever the list is generated
    end

    local entry = ZO_GamepadEntryData:New(name, data.icon, nil, nil, data.isNewCallback)
    entry:SetIconTintOnSelection(true)
    entry:SetIconDisabledTintOnSelection(true)

    local header = data.header
    if header then
        entry:SetHeader(header)
    end

    entry.canLevel = data.canLevel

    entry.data = data
    return entry
end

for menuEntryId, data in ipairs(MENU_ENTRY_DATA) do
    local newEntry = CreateEntry(data)
	
	
    newEntry.id = menuEntryId
    if data.subMenu then
        newEntry.subMenu = {}
        for submenuEntryId, subMenuData in ipairs(data.subMenu) do
            local newSubMenuEntry = CreateEntry(subMenuData)
            newSubMenuEntry.id = submenuEntryId
            table.insert(newEntry.subMenu, newSubMenuEntry)
        end
    end

    table.insert(ZO_MENU_ENTRIES, newEntry)
end
