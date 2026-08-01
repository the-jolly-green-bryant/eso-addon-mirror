-- Prepare all Global Tables
SwissKnife = {
	name = "SwissKnife",
	version = "1.06.7",
	author = "Nesferatum",
	homeServer = "EU",
	displayName = "|cE81B00S|cFFFFFFwiss |cE81B00K|cFFFFFFnife|r",
	versionAPI = "101050"
}

SwissKnife.Variables = {}
SwissKnife.Data = {}
SwissKnife.OptionsMenu = {}
SwissKnife.HelperFunctions = {}
SwissKnife.Equipment = {}
SwissKnife.Mailer = {}
SwissKnife.Automation = {}
SwissKnife.Scenes = {}
SwissKnife.Collectables = {}
SwissKnife.ContextMenu = {}
SwissKnife.CustomDialogs = {}
SwissKnife.Interface = {}
SwissKnife.Interaction = {}
SwissKnife.Bindings = {}

SwissKnife.savedVarsTable = "SwissKnifeSavedVariables"
SwissKnife.accountsWideSV = {}
SwissKnife.accountsWideName = "AccountsWide"
SwissKnife.accountWideSV = {}
SwissKnife.accountWideName = "$AccountWide"
SwissKnife.characterSV = {}
SwissKnife.storageName = "$Storage"
SwissKnife.globalSV = {}
SwissKnife.savedVars = {}

SwissKnife.MAIN_DIALOGUE_DATA = {
	DEFAULT = {
		HEIGHT = 438,
		WIDTH = 810,
		PADDING = 100,
		FILTER_MAX_WIDTH = 416
	},
	SIZES = {
		CONDENSED = 1,
		MEDIUM = 2,
		EXPAND = 3
	},
	LOCK_STATE = {
		LOCKED = 1,
		UNLOCKED = 2
	},
	NAVBAR_MODE_SIZE = {
		WIDTH = 41,
		HEIGHT = 240,
		EXTRA_PADDING = 80
	}
}

SwissKnife.ATTACHMENT_TYPES = {
	--MONEY = 1,
	RESOURCES = 2,
	INTRICATE = 3,
	NONE_SET_JEWELRY = 4,
	FCOIS_JEWELRY = 5,
	GLYPHS = 6
}

SwissKnife.STABLE_AFTER_THRESHOLD_TRAIN_RULES = {
	MAXIMIZE = 1,
	IN_ROTATION = 2
}

SwissKnife.TRANSFER_DIRECTIONS = {
	TO_GUILD_BANK = 0,
	FROM_GUILD_BANK = 1
}

SwissKnife.COMPANION_PREVENT_MODE = {
	NOTHING = 1,
	WARNING = 2,
	DISMISS = 3
}

SwissKnife.defaultSavedVars = {
	versionSV = SwissKnife.version,
	firstLoad = true,
	accountsWide = true,
	accountWide = false,
	mainDialogueData = {
		size = SwissKnife.MAIN_DIALOGUE_DATA.SIZES.CONDENSED,
		lockState = SwissKnife.MAIN_DIALOGUE_DATA.LOCK_STATE.LOCKED,
		point = TOP,
		relativePoint = TOP,
		offsetX = 0,
		offsetY = 90,
		lastMode = 1
	},
	apparelShowQuality = false,
	companionApparelShowQuality = false,
	apparelQualitySlotIcon = "SwissKnife/textures/gui/hole.dds",
	apparelQualitySlotHighlightIcon = "SwissKnife/textures/gui/spot.dds",
	apparelShowDurability = false,
	panelBottomShowRepair = false,
	panelBottomShowCharge = false,
	showEnchantQualityColor = false,
	defaultGuildData = {},
	openGuildShopEnabled = false,
	permanentUnwantedItemIds = {},
	filterUnwantedItemAfterLoot = false,
	filterNewOnlyUnwantedItem = false,
	destroyUnwantedItemAfterLoot = false,
	destroyNewOnlyUnwantedItem = true,
	destroyProtectedUnwantedItem = false,
	destroyCraftedUnwantedItem = false,
	junkUnwantedSetsAfterLoot = false,
	deconstructUnwantedSetsByQuality = false,
	markDeconstructUnwantedWithFCOIS = true,
	junkDeconstructedToo = false,
	autoDeconstructFCOISMarked = false,
	autoRefineRawMaterial = false,
	autoRefineIfSkillMaxed = true,
	autoRefineIfESOPlus = true,
	autoFilletFish = true,
	isCloseCraftStationAfterDeconstruction = false,
	isDeconstructCraftedItems = false,
	junkKnownTraitOnly = false,
	junkTreasures = true,
	deconstructNonSetJewelry = false,
	deconstructNonSetArmorWeapon = true,
	junkNonSetEquipments = true,
	junkNonSetEquipmentQuality = 3,
	useGlyphsForCraftTraining = false,
	useGlyphsForCraftTrainingQuality = 3,
	markGlyphsForCraftTraining = false,
	junkGlyphsIfCraftMaximize = false,
	useIntricateForCraftTraining = false,
	markIntricateForCraftTraining = false,
	junkIntricateIfCraftMaximize = false,
	showEnSetNameToo = true,
	showEnTraitNameToo = true,
	trackSetsItems = false,
	filterCurrentAccountTrackSetsItems = false,
	filterCurrentServerTrackSetsItems = true,
	trackSetsItemsFont = "ZoFontWinT1",
	trackCraftedSetsItems = false,
	trackLowLevelSetsItems = false,
	trackCompanionItems = false,
	trackJunkSetsItems = false,
	trackItemsAccountsNames = {},
	playerServerCodes = {},
	trackAccountsCollectionsItems = false,
	trackedAccountsCollectionsItems = {},
	trackedAccountsHotbarAbilities = {},
	stableTrainEnabled = false,
	stableTrainOrder = {
		RIDING_TRAIN_SPEED,
		RIDING_TRAIN_CARRYING_CAPACITY,
		RIDING_TRAIN_STAMINA,
	},
	stableTrainThreshold = {
		[RIDING_TRAIN_SPEED] = 50,
		[RIDING_TRAIN_STAMINA] = 50,
		[RIDING_TRAIN_CARRYING_CAPACITY] = 50,
	},
	stableAfterThresholdTrainRule = SwissKnife.STABLE_AFTER_THRESHOLD_TRAIN_RULES.IN_ROTATION,
	isAutomaticModeReceiptMail = false,
	isAutomaticResourcesMailReceiptEnabled = false,
	useAutomaticReceiptWhenESOPlusOnly = true,
	repeatReceiptMailAfterFailure = true,
	maximumMailReceiptFailureCount = 7,
	failureReceiptMailTimeout = 300,
	sendMailToAnotherAccount = false,
	sendMailToAnotherAccountDelay = 300,
	isAutomaticModeSendMail = false,
	repeatSendMailAfterFailure = true,
	maximumMailSendFailureCount = 3,
	failureSendMailTimeout = 10000,
	sendFullMailOnly = true,
	sendMailByTypeOptions = {
		[SwissKnife.ATTACHMENT_TYPES.RESOURCES] = {
			recipient = "",
			quality = 4,
			isSmartSendEnabled = false,
			isAutomaticReceiptEnabled = false
		},
		[SwissKnife.ATTACHMENT_TYPES.INTRICATE] = {
			recipient = "",
			isJewelryExclude = true
		},
		[SwissKnife.ATTACHMENT_TYPES.GLYPHS] = {
			recipient = "",
			quality = 3
		},
	},
	stopCameraRotate = true,
	isDoNotInterruption = true,
	replaceBackpackSlotsInfo = true,
	showFreeBagSlots = true,
	usePercentageFreeBagSlots = false,
	showColorizedFreeBagSlots = true,
	replaceFenceSlotsInfo = true,
	showFreeFenceSlots = true,
	usePercentageFreeFenceSlots = false,
	showColorizedFreeFenceSlots = true,
	bindUnknownCollectablesSetItems = false,
	showCollectablesSetItemExtraTooltip = false,
	collectablesSetItemIconX = 10,
	collectablesSetItemIconY = 0,
	hideUnlockedCollectablesSetItemOnTooltip = false,
	enableMarkAsJunkNotification = true,
	enableMarkForDeconstructNotification = true,
	enableDestroyedNotification = true,
	enableHasBeenDeconstructedNotification = true,
	enableHasBeenRefinedNotification = true,
	enableHasBeenFilletNotification = true,
	whoMustReceiptMailWithoutESOPlus = {},
	isAutomationBlockAbilities = false,
	abilityEndCorrectionInterval = 200,
	preventUnsafeStealing = true,
	preventPickpocketWithoutBonus = false,
	isPickyThiefEnabled = false,
	lowQualityStealing = 1,
	lowCostStealing = 100,
	isSmartSaleEnabled = false,
	isAutoSaleEnabled = false,
	isAutoLaunderEnabled = false,
	enableHasBeenSellNotification = true,
	enableHasBeenLaunderNotification = true,
	preventUnsafeInsectTake = true,
	preventUnsafeFishing = true,
	preventCompanionUnsafeStealing = true,
	preventCompanionUnsafeBladeOfWoe = true,
	companionUnsafeEntryMode = SwissKnife.COMPANION_PREVENT_MODE.WARNING,
	preventAccidentalInteraction = false,
	preventAccidentalInteractionInterval = 2500,
	hideEmptyInteraction = true,
	hideStealthText = false,
	hideSwapWeapon = false,
	hideActionButtonsKeybind = false,
	hideCompanionsInteraction = false,
	enableCompanionsInteractionNotification = true,
	showGuildBankChooser = true,
	bankTransferOptions = {
		glyphs = false,
		intricate = false,
		resources = false,
		non_gold_resources = false,
		gold_resources = false,
		master_writs = false,
		style_motifs = false,
		style_pages = false,
		recipe = false,
		crafted_white = false,
		training_craft = false,
		raw_materials = false,
		worth_stylish = false,
		unknown_style_motifs = false,
		unknown_recipe = false,
		unknown_style_pages = false
	},
	dailyQuestAcceptOptions = {
		mage = false,
		fighters = false,
		undaunted = false,
		cyrodiil = false,
		imperial_city = false
	},
	dailyQuestData = {},
	enableDailyQuestHelper = true,
	minTransferLatency = 110,
	hideDangerInteraction = false,
	previousHideDangerInteraction = false,
	enableDangerInteractionIndicator = false,
	dangerInteractionIndicator = {
		point = 12,
		relativePoint = 12,
		offsetX = -691,
		offsetY = -50
	},
	showExecutionIndicator = false,
	executionIndicatorOffsetX = -20,
	executionIndicatorOffsetY = -15,
	executionIndicatorColor = { 255, 0, 0, 1 },
	disableExecutionIndicatorSound = false,
	minTargetHealthForExecutionWatch = 0,
	launderItems = {},
	notBindItems = {},
	pregameOptions = {},
	enableLogoutOrQuitConfirmation = true,
	autoFillDestroyItemConfirmation = false,
	debugMode = false
}

SwissKnife.COLOR = {
	DARK_BLUE = ZO_ColorDef:New("0000A0"),
	CYAN = ZO_ColorDef:New("00FFFF"),
	BLUE = ZO_ColorDef:New("2F2FFF"),
	GREEN = ZO_ColorDef:New("12FF12"),
	DARK_SLATE_BLUE = ZO_ColorDef:New("483D8B"),
	DARK_OLIVE_GREEN = ZO_ColorDef:New("648036"),
	LIGHT_OLIVE_GREEN = ZO_ColorDef:New("9FB577"),
	MAROON = ZO_ColorDef:New("800000"),
	LIGHT_BLUE = ZO_ColorDef:New("ADD8E6"),
	SWISS_RED = ZO_ColorDef:New("E81B00"),
	RED = ZO_ColorDef:New("FF0000"),
	ORANGE_RED = ZO_ColorDef:New("FF7400"),
	ORANGE = ZO_ColorDef:New("FFA500"),
	YELLOW = ZO_ColorDef:New("FFD700"),
	LIGHT_YELLOW = ZO_ColorDef:New("F7E351"),
	GRAY = ZO_ColorDef:New("A6A6A6"),
	DISABLED = ZO_ColorDef:New(0.36, 0.36, 0.36),
	WHITE = ZO_ColorDef:New("FFFFFF"),
}

SwissKnife.COLORED_PREFIXES = {
	SK = table.concat({ "|cE81B00", "SK", "|r", "|cFFFFFF", "  ", "|r" }),
	SKO = table.concat({ "|cE81B00", "SK", "|r", "|cFFFFFF", "Opt: ", "|r" }),
	SKA = table.concat({ "|cE81B00", "SK", "|r", "|cFFFFFF", "Auto: ", "|r" }),
	SKB = table.concat({ "|cE81B00", "SK", "|r", "|cFFFFFF", "Bank: ", "|r" }),
	SKW = table.concat({ "|cE81B00", "SK", "|r", "|cFFFFFF", "Watch: ", "|r" }),
	SKM = table.concat({ "|cE81B00", "SK", "|r", "|cFFFFFF", "Mail: ", "|r" }),
}

SwissKnife.COLORED_SUFFIXES = {
	SKO = table.concat({ "|cE81B00", "SK", "|r", "|cFFFFFF", "Opt", "|r" }),
	SKA = table.concat({ "|cE81B00", "SK", "|r", "|cFFFFFF", "Auto", "|r" }),
	SKB = table.concat({ "|cE81B00", "SK", "|r", "|cFFFFFF", "Bank", "|r" }),
	SKW = table.concat({ "|cE81B00", "SK", "|r", "|cFFFFFF", "Watch", "|r" }),
	SKM = table.concat({ "|cE81B00", "SK", "|r", "|cFFFFFF", "Mail", "|r" }),
}

SwissKnife.CHATTER_OPTION_TYPES = {
	VIEW_STABLE = CHATTER_START_STABLE,
	OPEN_SHOP = CHATTER_START_SHOP,
	OPEN_BANK = CHATTER_START_BANK,
	OPEN_GUILD_TRADINGHOUSE = CHATTER_START_TRADINGHOUSE,
	OPEN_GUILD_BANK = CHATTER_START_GUILDBANK,
	OPEN_GUILD_SHOP = CHATTER_START_TRADINGHOUSE,
	OPEN_GUILD_SHOP_BET = CHATTER_START_GUILDKIOSK_BID,
	OPEN_COMPANION_MENU = CHATTER_START_COMPANION_MENU
}

SwissKnife.COMPANIONS = {
	BASTIAN = 1,
	MIRRI = 2,
	EMBER = 5,
	ISOBEL = 6,
	SHARP = 8,
	AZANDAR = 9,
	TANLORIN = 12,
	ZERIT = 13
}

SwissKnife.TRUE, SwissKnife.FALSE = 1, 0

SwissKnife.LINK_TYPES = {
	ABILITIES_PRESET = "atp"
}

SwissKnife.UNWANTED_QUALITY = {
	JUNK = {
		EQUIPMENT = 3,
		JEWELRY = 0
	},
	DECONSTRUCT = {
		EQUIPMENT = 4,
		JEWELRY = 3
	}
}

QDS_START = 0
QDS_NEXT = 1
QDS_CLOSE = 2

SKILL_BAR_FIRST_SLOT_INDEX = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1
SKILL_BAR_LAST_SLOT_INDEX = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1