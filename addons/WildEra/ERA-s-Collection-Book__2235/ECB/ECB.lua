ECB = {}
ECB.name = "ECB"
ECB.author = "@WILDERA (PC / EU)"
ECB.version = "2.0.1"
ECB.savedVars = nil

ECB.active = {}
ECB.active.tracker = false
ECB.active.book = false

ECB.constants = {}
ECB.constants.categories = {}
ECB.constants.categories.HATS = "HATS"
ECB.constants.categories.MARKINGS = "MARKINGS"
ECB.constants.categories.COSTUMES = "COSTUMES"
ECB.constants.categories.SKINS = "SKINS"
ECB.constants.categories.PERSONALITIES = "PERSONALITIES"
ECB.constants.categories.POLYMORPHS = "POLYMORPHS"
ECB.constants.categories.FURNISHINGS = "FURNISHINGS"
ECB.constants.categories.STORAGE = "STORAGE"
ECB.constants.categories.BUSTS = "BUSTS"
ECB.constants.categories.TROPHIES = "TROPHIES"
ECB.constants.categories.MEMENTOS = "MEMENTOS"
ECB.constants.categories.MOUNTS = "MOUNTS"
ECB.constants.categories.PETS = "PETS"
ECB.constants.categories.EMOTES = "EMOTES"
ECB.constants.categories.OTHERS = "OTHERS"
ECB.constants.categories.HOUSES = "HOUSING"
ECB.constants.categories.MOTIFS = "MOTIFS"
ECB.constants.categories.STYLES = "STYLES"
ECB.constants.pages = {}
ECB.constants.pages.settings = "SETTINGS"
ECB.constants.pages.about = "ABOUT"
ECB.constants.settings = {}
ECB.constants.settings.BACKGROUND = "BACKGROUND"
ECB.constants.settings.COMPLETED = "COMPLETED"

ECB.dimensions = {}
ECB.dimensions.tracker = {}
ECB.dimensions.tracker.default = {}

ECB.dimensions.tracker.default.width = 300
ECB.dimensions.tracker.default.height = 300
ECB.dimensions.tracker.default.opacity = 70
ECB.dimensions.tracker.default.header = {}
ECB.dimensions.tracker.default.header.height = 32
ECB.dimensions.tracker.default.category = {}
ECB.dimensions.tracker.default.category.width = ECB.dimensions.tracker.default.width
ECB.dimensions.tracker.default.category.height = 20
ECB.dimensions.tracker.default.collectible = {}
ECB.dimensions.tracker.default.collectible.offsetX = 13
ECB.dimensions.tracker.default.collectible.width = ECB.dimensions.tracker.default.width - ECB.dimensions.tracker.default.collectible.offsetX
ECB.dimensions.tracker.default.collectible.height = 20

ECB.dimensions.tracker.width = ECB.dimensions.tracker.default.width
ECB.dimensions.tracker.height = ECB.dimensions.tracker.default.height
ECB.dimensions.tracker.opacity = ECB.dimensions.tracker.default.opacity
ECB.dimensions.tracker.category = {}
ECB.dimensions.tracker.category.width = ECB.dimensions.tracker.default.category.width
ECB.dimensions.tracker.category.height = ECB.dimensions.tracker.default.category.height
ECB.dimensions.tracker.collectible = {}
ECB.dimensions.tracker.collectible.width = ECB.dimensions.tracker.default.collectible.width
ECB.dimensions.tracker.collectible.height = ECB.dimensions.tracker.default.collectible.height

ECB.parameters = {}
ECB.parameters.default = {}
ECB.parameters.default.font = "ZoFontWinH5"
ECB.parameters.default.prefix = "> "

local WM = GetWindowManager()

function ECB_InitializeTracker()
	-- data
	for i, category in ipairs(ECB.database.categories) do
		-- collectibles
		for j, collectible in ipairs(category.collectibles.list) do
			if (collectible.active ~= nil and collectible.active) or (collectible.unlocked ~= nil and not collectible.unlocked) then
				collectible.label = WM:CreateControl(string.format("%s%d", category.collectibles.parameters.pattern, j), category.parameters.tracker.body, CT_LABEL)
				collectible.label:SetFont(ECB.parameters.default.font)
				collectible.label:SetWrapMode(ELLIPSIS)
				collectible.label:SetMouseEnabled(true)
				collectible.label:SetText("COLLECTIBLE")
			end
		
			-- if category on 2 levels and active
			if (collectible.active ~= nil and collectible.active) then
				collectible.label:SetHandler("OnMouseUp", function() ECB:OpenCloseSubCategory(category.id, collectible.id) end)
				collectible.body = WM:CreateControl(string.format("%s%d%s", category.collectibles.parameters.pattern, j, "_LIST"), category.parameters.tracker.body, CT_CONTROL)
				collectible.body:SetMouseEnabled(true)
				collectible.body:SetResizeToFitDescendents(true)
				for k, subCollectible in ipairs(collectible.list) do
					if not subCollectible.unlocked then
						subCollectible.label = WM:CreateControl(string.format("%s%d%s%d", category.collectibles.parameters.pattern, j, "_LIST_", k), collectible.body, CT_LABEL)
						subCollectible.label:SetFont(ECB.parameters.default.font)
						subCollectible.label:SetWrapMode(ELLIPSIS)
						subCollectible.label:SetMouseEnabled(true)
						subCollectible.label:SetText("COLLECTIBLE")
					end
				end						
			end
		end
	end
end

function cleanEncodedText(text)
	-- because Zenimax can't format/encode correctly their values
	
	local cleanedText = text:gsub("^%l", string.upper)
	local encodedChars = { "<<player{", "}>>", "%^pmd", "%^fd", "%^pf", "%^md", "%^f", "%^m", "%^n" }
	for key, value in ipairs(encodedChars) do
	   cleanedText = string.gsub(cleanedText, value, "")
	end
	
	return cleanedText
end

function ECB_InitializeCollectibles()
	for i, category in ipairs(ECB.database.categories) do
		local unlockedCount = 0
		for j, collectible in ipairs(category.collectibles.list) do
			-- if category on 2 levels
			if collectible.list ~= nil then
				local unlockedCountSub = 0
				for k, subCollectible in ipairs(collectible.list) do
					-- get info and add them to the database
					local name, description, icon, dIcon, unlocked = GetCollectibleInfo(subCollectible.id)
					subCollectible.name = cleanEncodedText(name)
					subCollectible.unlocked = unlocked
					
					if unlocked then
						unlockedCountSub = unlockedCountSub + 1
					end
				end
				
				-- deactivate sub category if all collectibles unlocked
				if unlockedCountSub == #collectible.list then
					collectible.active = false
					unlockedCount = unlockedCount + 1
				end
				
				collectible.unlockedCount = unlockedCountSub
			else
				-- get info and add them to the database
				local name, description, icon, dIcon, unlocked = GetCollectibleInfo(collectible.id)
				collectible.name = cleanEncodedText(name)
				collectible.unlocked = unlocked
				
				if unlocked then
					unlockedCount = unlockedCount + 1
				end
			end
		end
		
		-- deactivate category if all collectibles unlocked
		if unlockedCount == #category.collectibles.list then
			category.parameters.tracker.active = false
		end
		
		category.parameters.unlockedCount = unlockedCount
	end
end

function ECB_LoadSavedVars()
	if ECB.savedVars.position ~= nil then
		ECB_TRACKER:ClearAnchors()
		ECB_TRACKER:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ECB.savedVars.position.x , ECB.savedVars.position.y)
	end
	if ECB.savedVars.active ~= nil and ECB.savedVars.active then
		ECB:ToggleWindow()
	end
	if ECB.savedVars.dimensions ~= nil then
		ECB.dimensions.tracker.width = ECB.savedVars.dimensions.width
		ECB.dimensions.tracker.height = ECB.savedVars.dimensions.height
		ECB.dimensions.tracker.opacity = ECB.savedVars.dimensions.opacity
	end
end

function ECB_DeactivateCollectible(collectibleId)
	for i, category in ipairs(ECB.database.categories) do
		for j, collectible in ipairs(category.collectibles.list) do
			if collectible.id == collectibleId then
				if not collectible.unlocked then	
					collectible.label:SetHidden(true)
					collectible.unlocked = true
					category.parameters.unlockedCount = category.parameters.unlockedCount + 1
					if category.parameters.unlockedCount == #category.collectibles.list then
						category.parameters.tracker.active = false
					end
				end

				return
			end

			if (collectible.active ~= nil and collectible.active) then
				for k, subCollectible in ipairs(collectible.list) do
					if subCollectible.id == collectibleId then
						if not subCollectible.unlocked then
							subCollectible.label:SetHidden(true)
							subCollectible.unlocked = true
							collectible.unlockedCount = collectible.unlockedCount + 1
							if collectible.unlockedCount == #collectible.list then
								collectible.label:SetHidden(true)
								collectible.active = false
								category.parameters.unlockedCount = category.parameters.unlockedCount + 1
								if category.parameters.unlockedCount == #category.collectibles.list then
									category.parameters.tracker.active = false
								end
							end
						end

						return
					end
				end
			end
		end
	end
end

function ECB.OnNewCollectibleNotification(eventCode, collectibleId, notificationId)
	ECB_DeactivateCollectible(collectibleId)
	ECB_LoadTracker()
end

function ECB.OnPlayerActivated(eventCode, addonName)
	EVENT_MANAGER:UnregisterForEvent(ECB.name, eventCode)

	ECB_LoadTracker()
	ECB_LoadBook()
end

function ECB.OnAddOnLoaded(eventCode, addonName)
	-- load ECB only when called
	if ECB.name ~= addonName then
		return
	end
	EVENT_MANAGER:UnregisterForEvent(ECB.name, eventCode)
	
	-- load saved parameters
	ECB.savedVars = ZO_SavedVars:NewAccountWide("ECBVars", ECB.version, nil, nil)
	ECB_LoadSavedVars()
	
	-- init database
	ECB_InitializeCategories()
	ECB_InitializeCollectibles()
	
	-- init UI
	ECB_InitializeTracker()
	ECB_InitializeBook()
	
	-- hide/show in menu
	ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function() ECB:HideIfActive() end)
	ZO_PreHookHandler(ZO_GameMenu_InGame, "OnHide", function() ECB:ShowIfActive() end)
	ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function() ECB:HideIfActive() end)
	ZO_PreHookHandler(ZO_InteractWindow, "OnHide", function() ECB:ShowIfActive() end)
	ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function() ECB:HideIfActive() end)
	ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function() ECB:ShowIfActive() end)
	ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function() ECB:HideIfActive() end)
	ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function() ECB:ShowIfActive() end)

	-- chat command
	SLASH_COMMANDS["/ecb"] = function(option) ECB:ToggleWindow() end

	-- register events
	EVENT_MANAGER:RegisterForEvent(ECB.name, EVENT_PLAYER_ACTIVATED, ECB.OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(ECB.name, EVENT_COLLECTIBLE_NOTIFICATION_NEW, ECB.OnNewCollectibleNotification)
end

EVENT_MANAGER:RegisterForEvent(ECB.name, EVENT_ADD_ON_LOADED, ECB.OnAddOnLoaded)
