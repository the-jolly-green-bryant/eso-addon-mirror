--[[
Author: Jarth
Filename: General.lua
]] --
-------------------------------------------------------------------------------------------------
-- VARIABLES --
-------------------------------------------------------------------------------------------------
CollectionBars = {
	WM = GetWindowManager(),
	Addon = {Name = "CollectionBars", DisplayName = "Collection Bars", Abbreviation = "CBs", Version = 1.1, MinorVersion = 14, SettingsSlash = "/cb", Author = "Jarth"},
	AllButtons = {},
	Default = {
		UseAccountSettings = true,
		Bar = {Depth = 5, Width = 0, SnapSize = 5},
		Button = {Size = ZO_GAMEPAD_ACTION_BUTTON_SIZE, IsAudioEnabled = true, IsActiveActivationEnabled = true},
		Scene = {OnHud = true, OnHudUI = true, InMenu = true, InInventory = false, InInteract = false, InBank = false, InFence = false, InStore = false},
		Bindings = {Show = true, Number = 20},
		Combine = {Bar = {Depth = 0, Width = 0, Offset = {X = CENTER, Y = CENTER}}, Label = {Show = true, Display = "CombineBar", Offset = {X = 0, Y = 0}, Position = BOTTOMLEFT, PositionTarget = TOPLEFT}},
		Categories = {},
		Logging = {Info = false, Debug = false, Verbose = false}
	},
	Global = {
		EnableSettings = false,
		IsMoveEnabled = false,
		ReverseBindings = {},
		Settings = {Frame = nil, List = nil, Filters = {["Categories"] = "Categories", ["Collectibles"] = "Collectibles", ["Category"] = "Category", ["General"] = "General", ["Combined"] = "Combined bar"}},
		Combine = {Name = "Combine", EventTS = nil, Frames = {Frame = nil, Move = nil}, category = nil, HideAll = nil, Fragment = nil, IsEmpty = false},
		ChoiceLocations = {"top", "topright", "right", "bottomright", "bottom", "bottomleft", "left", "topleft", "center"},
		ChoiceNumberOfBindings = {5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100},
		AvailableFonts = {"ZoFontGameSmall", "ZoFontGameLarge", "ZoFontGameLargeBold", "ZoFontGameLargeBoldShadow", "ZoFontHeader", "ZoFontHeader2", "ZoFontHeader3", "ZoFontHeader4"},
		Scenes = {
			[1] = {Name = "OnHud", Instance = HUD_SCENE, Description = "%s on main view/hud"},
			[2] = {Name = "OnHudUI", Instance = HUD_UI_SCENE, Description = "%s on the main view when an overlay is activated/hudui"},
			[3] = {Name = "InMenu", Instance = SCENE_MANAGER:GetScene("gameMenuInGame"), Description = "%s in menu"},
			[4] = {Name = "InInventory", Instance = SCENE_MANAGER:GetScene("inventory"), Description = "%s in the inventory"},
			[5] = {Name = "InInteract", Instance = SCENE_MANAGER:GetScene("interact"), Description = "%s in interactions"},
			[6] = {Name = "InBank", Instance = SCENE_MANAGER:GetScene("bank"), Description = "%s at a bank"},
			[7] = {Name = "InFence", Instance = SCENE_MANAGER:GetScene("fence_keyboard"), Description = "%s at a fence"},
			[8] = {Name = "InStore", Instance = SCENE_MANAGER:GetScene("store"), Description = "%s at a store"},
			[9] = {Name = "InArmoryKeyboard", Instance = SCENE_MANAGER:GetScene("armoryKeyboard"), Description = "%s at the armory (Keyboard)"},
			[10] = {Name = "InArmoryGamepad", Instance = SCENE_MANAGER:GetScene("armoryRootGamepad"), Description = "%s at the armory (Gamepad)"},
			[11] = {Name = "InDeconstructionKeyboard", Instance = SCENE_MANAGER:GetScene("universalDeconstructionSceneKeyboard"), Description = "%s in deconstruction screen (Keyboard)"},
			[12] = {Name = "InDeconstructionGamepad", Instance = SCENE_MANAGER:GetScene("universalDeconstructionSceneGamepad"), Description = "%s in deconstruction screen (Gamepad)"}
		},
		HighestUnlocked = 0,
		ShowChildren = {}
	},
	Categories = {},
	CategoriesOrdered = {},
	Texts = {
		Font = {ZoFontWinT1 = "ZoFontWinT1", ZoFontWinH4 = "ZoFontWinH4"},
		Format = {Number = "%.2f", Decimal = "%d", Comma = "%s,%s"},
		Location = {Bottom = "bottom", BottomLeft = "bottomleft", BottomRight = "bottomright", Center = "center", Left = "left", Right = "right", Top = "top", TopLeft = "topleft", TopRight = "topright"},
		Settings = {ToggleMoveFrameText = "Toggle move frame", ReloadText = "Reload list of 'Collectibles'\nHint: Usefull after gaining a new collectible)"}
	},
	Loggers = {}
}
local base = CollectionBars

base.Texts.FormatAbbreviation = string.format("%s%%s", base.Addon.Abbreviation)
base.Texts.FormatAbbreviationLowDash = string.format("%s_%%s", base.Addon.Abbreviation)
base.Texts.FormatCategoryName = string.format("%s_C%%s", base.Addon.Abbreviation)
base.Texts.FormatBindingName = string.format("SI_BINDING_NAME_%s", base.Texts.FormatAbbreviationLowDash)
base.Texts.CombineFrameName = string.format(base.Texts.FormatAbbreviationLowDash, "CombineFrame")
base.Texts.CombineFrameNameHideAll = string.format("%s%s", base.Texts.CombineFrameName, "HideAll")
base.Texts.AccountKey = string.format("%s_Account", base.Addon.Name)
base.Texts.CharacterKey = string.format("%s_Character", base.Addon.Name)

base.IconState = {NORMAL = 1, OVER = 2, PRESSED = 3, DISABLED = 4}
base.ToggleButtonState = {OPEN = true, CLOSED = false}
base.ToggleButtonIcon = {
	[base.ToggleButtonState.OPEN] = {
		[base.IconState.NORMAL] = "EsoUI/Art/Buttons/tree_open_up.dds",
		[base.IconState.OVER] = "EsoUI/Art/Buttons/tree_open_over.dds",
		[base.IconState.PRESSED] = "EsoUI/Art/Buttons/tree_open_down.dds",
		[base.IconState.DISABLED] = "EsoUI/Art/Buttons/tree_open_disabled.dds"
	},
	[base.ToggleButtonState.CLOSED] = {
		[base.IconState.NORMAL] = "EsoUI/Art/Buttons/tree_closed_up.dds",
		[base.IconState.OVER] = "EsoUI/Art/Buttons/tree_closed_over.dds",
		[base.IconState.PRESSED] = "EsoUI/Art/Buttons/tree_closed_down.dds",
		[base.IconState.DISABLED] = "EsoUI/Art/Buttons/tree_closed_disabled.dds"
	}
}

-------------------------------------------------------------------------------------------------
-- FUNCTIONS --
-------------------------------------------------------------------------------------------------

function base:GenerateCategories()
	base:Debug("GenerateCategories")

	base.Categories = {}

	for _, categoryData in ZO_COLLECTIBLE_DATA_MANAGER:CategoryIterator({ZO_CollectibleCategoryData.HasShownCollectiblesInCollection}) do
		if categoryData ~= nil and categoryData:IsStandardCategory() then
			local categoryType = base.GetCategoryTypeFromCollectible(categoryData)
			local keyboardIcons = {categoryData:GetKeyboardIcons()}
			local parentKey = categoryData:GetFormattedName()
			local hasSubCategories = categoryData:GetNumSubcategories() > 0

			base.AddCategory(categoryData, categoryType, keyboardIcons, hasSubCategories)

			if hasSubCategories then
				base:AddSubCategories(categoryData, keyboardIcons, parentKey)
			end
		end
	end
end

function base:AddSubCategories(categoryData, parentKeyboardIcons, parentKey)
	base:Debug("AddSubCategories", categoryData, parentKeyboardIcons, parentKey)

	for _, subcategoryData in categoryData:SubcategoryIterator({ZO_CollectibleCategoryData.HasShownCollectiblesInCollection}) do
		local categoryType = base.GetCategoryTypeFromCollectible(subcategoryData)
		local hasSubCategories = subcategoryData.subcategories ~= nil and subcategoryData:GetNumSubcategories() > 0
		base.AddCategory(subcategoryData, categoryType, parentKeyboardIcons, hasSubCategories, parentKey)

		if hasSubCategories then
			local subcategoryParentKey = subcategoryData:GetFormattedName()
			base:AddSubCategories(subcategoryData, parentKeyboardIcons, subcategoryParentKey)
		end
	end
end

function base.GetCategoryTypeFromCollectible(categoryData)
	base:Debug("GetCategoryType", categoryData)

	local categoryType = nil

	for _, collectible in ZO_CollectibleCategoryData.SortedCollectibleIterator(categoryData, {ZO_CollectibleData.IsShownInCollection}) do
		categoryType = collectible:GetCategoryType()
		break
	end

	return categoryType
end

function base.AddCategory(categoryData, categoryType, keyboardIcons, hasChildren, parentKey)
	base:Debug("AddCategory", categoryData, categoryType, keyboardIcons, hasChildren, parentKey)

	local categoryName = categoryData:GetFormattedName()
	local categoryId = categoryData:GetId()

	if keyboardIcons ~= nil and keyboardIcons[1] == ZO_NO_TEXTURE_FILE then
		keyboardIcons = nil
	end

	base.Categories[categoryId] = {
		Collection = {},
		CollectionOrdered = {},
		Buttons = {},
		CategoryType = categoryType,
		Id = categoryId,
		CategoryData = categoryData,
		Icon = keyboardIcons,
		HasChildren = hasChildren,
		ParentKey = parentKey,
		Unlocked = 0,
		Name = categoryName,
		Frames = {Frame = nil, Label = nil, LabelButton = nil, ToggleSettings = nil, Move = nil},
		Bar = {Depth = 0, Width = nil},
		Cooldown = {Event = string.format("Cooldown%s", categoryName), CollectibleId = nil, StartTime = nil, Tick = 100},
		Fragment = nil
	}
	table.insert(base.CategoriesOrdered, base.Categories[categoryId])
	base.Default.Categories[categoryId] = {
		AutoSelectAll = false,
		Selected = {},
		Enabled = false,
		Tooltip = {Show = true, Position = TOP},
		Bar = {IsCombined = true, HideAll = true, Depth = 0, Width = 0, Horizontal = true, Offset = {X = CENTER, Y = CENTER}},
		Menu = {ShowDisabled = false},
		Label = {Show = true, EnableHideAll = true, Display = categoryName, Offset = {X = 0, Y = 0}, Height = 19, Width = 75, Font = "ZoFontGameSmall", Position = BOTTOMLEFT, PositionTarget = TOPLEFT}
	}
end
