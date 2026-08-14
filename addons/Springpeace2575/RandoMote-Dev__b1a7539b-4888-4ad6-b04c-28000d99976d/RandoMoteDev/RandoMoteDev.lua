RandoMoteInner = RandoMoteInner or {}
local RM = RandoMoteInner
local RMPlayer = RandoMotePlayerInner

RM.name             = "RandoMoteDev"
RM.displayName      = "RandoMote (Dev)"
RM.savedVarsName    = "RandoMoteDevSavedVars"
RM.settingsPanelId  = "RandoMoteDevPanel"
RM.version          = "1.8.0"

RM.defaults.gsw = {
    maxResults = 5000,
    captureSearchResponses = true,
    capturePageResponses = true,
    keepUncollectedItemsOnly = false,
    showCheapestItemsOnly = true,
    showUncollectedItemsOnly = false,
    enablePageRotation = true,
    deleteOnConfirmationOnly = true,
    deleteWholeItem = false,
    clearOnConfirmationOnly = true,
    trimResults = false,
    orderedByName = false,
    debug = false,
    enable = false,

    -- collections, values by ix
    results = {},
    items = {},
    contexts = {},
    sellers = {},
    locations = {},
    traders = {},
    guilds = {},
    searches = {},

    resultsCount = 0,
    resultsLength = 0,
}

RM.defaults.cta = {
    showUncollectedItemsOnly = false,
    enablePageRotation = true,
    showIcons = true,
    orderedBy = 3,
    debug = false,
    enable = false,

    selectedCategory = "All",
    selectedSubcategory = "All",
    selectedSource = "All",
    selectedGroup = "All",

    -- collections, values by ix
    results = {},
    categories = {},
    subcategories = {},
    sources = {},
    groups = {},
    types = {},

    collectedCount = 0,
    totalCount = 0,
}

RM.playTestEnabled = false

RM.slashCommand.enablePlayTest	= "/rmplaytest"
RM.slashCommand.checkMementos	= "/rmchmems"
RM.slashCommand.enableGSW		= "/rmgsw"
RM.slashCommand.enableCTA		= "/rmcta"

function RM.ExtensionInitialize()
    if GuildStoreWatch and GuildStoreWatch.Initialize then
		GuildStoreWatch.Initialize(RM.sv)
	end

    if CollectThemAll and CollectThemAll.Initialize then
		CollectThemAll.Initialize(RM.sv)
	end
end

function RM.TestEmoteLoop(index, slash)
	if RM.playTestEnabled == false then
		return
	end

	local POLL_INTERVAL = 100          -- ms
	local MAX_DURATION  = 30000        -- ms (30 s)

    local running = true
    local startTime = GetGameTimeMilliseconds()

    local function Poll()
        if not running then return end

        local elapsed = GetGameTimeMilliseconds() - startTime

        -- End test when it is not possible already
		local canPlay, _ = RMPlayer.CanPlayEmoteNow()
        if not canPlay then
            running = false
            d(string.format("%s -> STOPPED (after %.2f s)", slash, elapsed / 1000))
            return
        end

        -- Timeout = emote is probably LOOP
        if elapsed >= MAX_DURATION then
            running = false
            d(string.format("%s -> LOOP (ran %.2f s)", slash, elapsed / 1000))
            return
        end

        zo_callLater(Poll, POLL_INTERVAL)
    end

    -- start polling
    zo_callLater(Poll, POLL_INTERVAL)
end

function RMPlayer.PlayEmoteNow(emote)
	SCENE_MANAGER:ShowBaseScene()
	zo_callLater(function()
		local canPlay, reason = RMPlayer.CanPlayEmoteNow()
		if not canPlay then
			d(reason)
			-- RM.SafeStartChatInput(emote.slash)
			return
		end
		PlayEmoteByIndex(emote.index)
		RM.TestEmoteLoop(emote.index, emote.slash)
	end, 200)
end

function RM.VarToString(name, value)
	return " ; "..name..": "..tostring(value)
end

function RM.MementoCategoryType()
    ---@type CollectibleCategoryType
    return COLLECTIBLE_CATEGORY_TYPE_MEMENTO
end

function RM.CheckMementos()
	local categoryType = RM.MementoCategoryType()
	d("Mementos: "
		..RM.VarToString("COLLECTIBLE_CATEGORY_TYPE_MEMENTO", COLLECTIBLE_CATEGORY_TYPE_MEMENTO)
		..RM.VarToString("GetTotalCollectiblesByCategoryType", GetTotalCollectiblesByCategoryType(categoryType))
	)
	-- local available = {}
	for i = 1, GetTotalCollectiblesByCategoryType(categoryType) do
		local collectibleId = GetCollectibleIdFromType(categoryType, i)
		-- local isUnlocked = IsCollectibleUnlocked(collectibleId)
		-- if GetCollectibleCategoryType(collectibleId) ~= COLLECTIBLE_CATEGORY_TYPE_MEMENTO then return end
		-- if id and IsCollectibleUnlocked(collectibleId) then table.insert(available, collectibleId) end
		local name, _, _, _, unlocked = GetCollectibleInfo(collectibleId)

        if i > 300 then -- output switched off now
            -- not possile to output all at once
            d(""
                ..RM.VarToString("ix", i)
                ..RM.VarToString("id", collectibleId)
                ..RM.VarToString("name", name)
                ..RM.VarToString("unlocked", unlocked)
            )
        end
    end
end

function RM.ExtensionOnLoaded()
    SLASH_COMMANDS[RM.slashCommand.enablePlayTest] = function() RM.playTestEnabled = true end
	SLASH_COMMANDS[RM.slashCommand.checkMementos] = function() RM.CheckMementos() end
	SLASH_COMMANDS[RM.slashCommand.enableGSW] = function()
		RM.sv.gsw.enable = true
		d("GSW Enable: "..tostring(RM.sv.gsw.enable))
		zo_callLater(function() ReloadUI() end, 1000)
	end

    SLASH_COMMANDS[RM.slashCommand.enableCTA] = function()
        RM.sv.cta.enable = true
        d("CTA Enable: "..tostring(RM.sv.cta.enable))
		zo_callLater(function() ReloadUI() end, 1000)
    end
end
