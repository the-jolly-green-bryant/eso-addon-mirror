local SK = SwissKnife

SK.Data.scenesData = {
	FRAME_PLAYER_FRAGMENT_SCENES = {
		"inventory", "stats", "skills", "questJournal", "mailInbox", "mailSend", "notifications",
		"achievements", "leaderboards", "loreLibrary", "housingBook", "dlcBook", "friendsList", "ignoreList",
		"groupMenuKeyboard", "guildHome", "guildRoster", "guildRanks", "guildHeraldry", "guildHistory",
		"guildCreate", "campaignOverview", "campaignBrowser", "guildBrowserKeyboard",
		--"gameMenuInGame",
		"helpCustomerSupport", "helpEmotes", "helpTutorials", "championPerks", "antiquityJournalKeyboard"
	},
	FRAGMENTS_TO_REMOVE = {
		FRAME_PLAYER_FRAGMENT, FRAME_EMOTE_FRAGMENT_INVENTORY, FRAME_EMOTE_FRAGMENT_SKILLS,
		FRAME_EMOTE_FRAGMENT_JOURNAL, FRAME_EMOTE_FRAGMENT_MAP, FRAME_EMOTE_FRAGMENT_SOCIAL,
		FRAME_EMOTE_FRAGMENT_AVA, FRAME_EMOTE_FRAGMENT_SYSTEM, FRAME_EMOTE_FRAGMENT_LOOT,
		FRAME_EMOTE_FRAGMENT_CHAMPION,
	},
	FREE_SLOTS_DIALOGUES = {
		inventory = {
			main = {
				parentBar = ZO_PlayerInventoryInfoBar,
				originTextControl = ZO_PlayerInventoryInfoBarFreeSlots,
				newTextControl = nil
			},
			wallet = {
				parentBar = ZO_InventoryWalletInfoBar,
				originTextControl = ZO_InventoryWalletInfoBarFreeSlots,
				newTextControl = nil
			},
			quick = {
				parentBar = ZO_QuickSlotInfoBar,
				originTextControl = ZO_QuickSlotInfoBarFreeSlots,
				newTextControl = nil
			},
			quick_keyboard = {
				parentBar = ZO_QuickSlot_Keyboard_TopLevelInfoBar,
				originTextControl = ZO_QuickSlot_Keyboard_TopLevelInfoBarFreeSlots,
				newTextControl = nil
			},
			bank = {
				parentBar = ZO_PlayerBankInfoBar,
				originTextControl = ZO_PlayerBankInfoBarFreeSlots,
				newTextControl = nil
			},
			guild_bank = {
				parentBar = ZO_GuildBankInfoBar,
				originTextControl = ZO_GuildBankInfoBarFreeSlots,
				newTextControl = nil
			},
			house_bank = {
				parentBar = ZO_HouseBankInfoBar,
				originTextControl = ZO_HouseBankInfoBarFreeSlots,
				newTextControl = nil
			},
			store = {
				parentBar = ZO_StoreWindowInfoBar,
				originTextControl = ZO_StoreWindowInfoBarFreeSlots,
				newTextControl = nil
			},
			buy_back = {
				parentBar = ZO_BuyBackInfoBar,
				originTextControl = ZO_BuyBackInfoBarFreeSlots,
				newTextControl = nil
			},
			repair = {
				parentBar = ZO_RepairWindowInfoBar,
				originTextControl = ZO_RepairWindowInfoBarFreeSlots,
				newTextControl = nil
			},
			smithing_refinement = {
				parentBar = ZO_SmithingTopLevelRefinementPanelInventoryInfoBar,
				originTextControl = ZO_SmithingTopLevelRefinementPanelInventoryInfoBarFreeSlots,
				newTextControl = nil
			},
			smithing_creation = {
				parentBar = ZO_SmithingTopLevelCreationPanelInfoBar,
				originTextControl = ZO_SmithingTopLevelCreationPanelInfoBarFreeSlots,
				newTextControl = nil
			},
			smithing_deconstruction = {
				parentBar = ZO_SmithingTopLevelDeconstructionPanelInventoryInfoBar,
				originTextControl = ZO_SmithingTopLevelDeconstructionPanelInventoryInfoBarFreeSlots,
				newTextControl = nil
			},
			smithing_improvement = {
				parentBar = ZO_SmithingTopLevelImprovementPanelInventoryInfoBar,
				originTextControl = ZO_SmithingTopLevelImprovementPanelInventoryInfoBarFreeSlots,
				newTextControl = nil
			},
			--smithing_research = {
			--	parentBar = ZO_SmithingTopLevelResearchPanelInfoBar,
			--	originTextControl = ZO_SmithingTopLevelResearchPanelInfoBarFreeSlots,
			--	newTextControl = nil
			--},
			provisioner = {
				parentBar = ZO_ProvisionerTopLevelInfoBar,
				originTextControl = ZO_ProvisionerTopLevelInfoBarFreeSlots,
				newTextControl = nil
			},
			enchanting = {
				parentBar = ZO_EnchantingTopLevelInventoryInfoBar,
				originTextControl = ZO_EnchantingTopLevelInventoryInfoBarFreeSlots,
				newTextControl = nil
			},
			alchemy = {
				parentBar = ZO_AlchemyTopLevelInventoryInfoBar,
				originTextControl = ZO_AlchemyTopLevelInventoryInfoBarFreeSlots,
				newTextControl = nil
			},
			retrait_station = {
				parentBar = ZO_RetraitStation_KeyboardTopLevelRetraitPanelInventoryInfoBar,
				originTextControl = ZO_RetraitStation_KeyboardTopLevelRetraitPanelInventoryInfoBarFreeSlots,
				newTextControl = nil
			},
		},
		bank = {
			main = {
				parentBar = ZO_PlayerBankInfoBar,
				originTextControl = ZO_PlayerBankInfoBarAltFreeSlots,
				newTextControl = nil
			},
			inventory = {
				parentBar = ZO_PlayerInventoryInfoBar,
				originTextControl = ZO_PlayerInventoryInfoBarAltFreeSlots,
				newTextControl = nil
			},
			guild_bank = {
				parentBar = ZO_GuildBankInfoBar,
				originTextControl = ZO_GuildBankInfoBarAltFreeSlots,
				newTextControl = nil
			},
			house_bank = {
				parentBar = ZO_HouseBankInfoBar,
				originTextControl = ZO_HouseBankInfoBarAltFreeSlots,
				newTextControl = nil
			},
		}
	}
}