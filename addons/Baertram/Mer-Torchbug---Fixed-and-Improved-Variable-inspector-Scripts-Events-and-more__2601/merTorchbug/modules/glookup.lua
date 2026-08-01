local tbug = TBUG or SYSTEMS:GetSystem("merTorchbug")

local types = tbug.types
local stringType = types.string
local numberType = types.number
local functionType = types.func
local tableType = types.table
local userDataType = types.userdata
local structType = types.struct
local isObjectType = {
    [tableType]    = true,
    [userDataType] = true,
    [functionType] = true,
}

local libAS = LibAsync

local autovivify = tbug.autovivify

local tos = tostring
local strbyte = string.byte
local strfind = string.find
local strmatch = string.match
local strsub = string.sub
local strup = string.upper
local strlower = string.lower

local strsplit = tbug.strSplit
local zo_strsplit = zo_strsplit
local tconcat = table.concat
local zo_insecureNext = zo_insecureNext

local EsoStrings = EsoStrings

local DEBUG = 1
local SI_LAST = SI_NONSTR_PUBLICALLINGAMESGAMEPADSTRINGS_LAST_ENTRY --10944, old one was: SI_NONSTR_INGAMESHAREDSTRINGS_LAST_ENTRY  10468

local g_objects = tbug.LookupTabs["_G"] -- = {}

local g_nonEnumPrefixes = tbug.nonEnumPrefixes
local mtEnum = { __index = function (_, v) return v end }
local g_enums = setmetatable({}, autovivify(mtEnum))
tbug.enums = g_enums
tbug.enumsContextMenuCache = {}
local g_needRefresh = true
local g_refreshRunning = false

local g_tmpGroups = setmetatable({}, autovivify(nil))
tbug.enumTmpGroups = g_tmpGroups
local g_tmpKeys = {}
--tbug._g_tmpKeys = g_tmpKeys
local g_tmpStringIds = {}
--tbug._tmpStringIds = g_tmpStringIds

local getTBUGGlobalInspectorPanelIdByName = tbug.getTBUGGlobalInspectorPanelIdByName
local hideLoadingSpinner = tbug.hideLoadingSpinner

local libraryPrefixComparisonVar = tbug.libraryPrefixComparisonVar
--local isSpecialInspectorKey = tbug.isSpecialInspectorKey
local keyToSpecialEnum = tbug.keyToSpecialEnum
local keyToSpecialEnumNoSubtablesInEnum = tbug.keyToSpecialEnumNoSubtablesInEnum
local keyToSpecialEnumExclude = tbug.keyToSpecialEnumExclude
local keyToSpecialEnumTmpGroupKey = tbug.keyToSpecialEnumTmpGroupKey
local keyToEnums = tbug.keyToEnums
local checkIfItemLinkFunc = tbug.checkIfItemLinkFunc
local sortItemLinkFunctions = tbug.sortItemLinkFunctions

local specialEnumNoSubtables_subTables = {}


local function isIterationOrMinMaxConstant(stringToSearch)
    local stringsToFind = {
        ["_MIN_VALUE"] = -11,
        ["_MAX_VALUE"] = -11,
        ["_ITERATION_BEGIN"] = -17,
        ["_ITERATION_END"] = -15,
    }
    for searchStr, offsetFromEnd in pairs(stringsToFind) do
        if strfind(stringToSearch, searchStr, offsetFromEnd, true) ~= nil then
            return true
        end
    end
    return false
end

local function longestCommonPrefix(tab, pat)
    local key, val = zo_insecureNext(tab)
    local lcp = val and strmatch(val, pat)

    if not lcp then
        return nil
    end

    if DEBUG >= 2 then
        df("... lcp start %q => %q", val, lcp)
    end

    for key, val in zo_insecureNext, tab, key do
        while strfind(val, lcp, 1, true) ~= 1 do
            lcp = strmatch(lcp, pat)
            if not lcp then
                return nil
            end
            if DEBUG >= 2 then
                df("... lcp cut %q", lcp)
            end
        end
    end
    return lcp
end

local function getPrefix(str, sepparator, prefixDepth)
    sepparator = sepparator or "_"
    prefixDepth = prefixDepth or 1 --find the 1st sepparator, or which "depth"?
    --local retVar

    --if prefixDepth == 1 then
    --    retVar = strmatch(str, "^([A-Z][A-Z0-9]*%"..sepparator..")[%"..sepparator.."A-Z0-9]*$") --2023--12-04 Does not find PCHAT_lowerCasHere
    --    if retVar == nil then
    --        retVar = strmatch(str, "^([A-Z][A-Z0-9]*%"..sepparator..")[%"..sepparator.."%w]*$")
    --    end
    --else
    --Split the string at the sepparator into a table
    --    local splitAtSepparatorTab = strsplit(str, sepparator)
    --    if not ZO_IsTableEmpty(splitAtSepparatorTab) then
    --        retVar = ""
    --        for i=1, prefixDepth, 1 do
    --            retVar = retVar .. splitAtSepparatorTab[i] .. sepparator
    --        end
    --    end
    --end
    local parts = { zo_strsplit(sepparator, str) }
    local retVar = tconcat(parts, sepparator, 1, prefixDepth) .. sepparator
    return retVar
end
tbug.getPrefix = getPrefix

local function makeEnum(group, prefix, minKeys, calledFromTmpGroupsLoop)
    ZO_ClearTable(g_tmpKeys)

    local numKeys = 0
    for k2, v2 in zo_insecureNext, group do
        if strfind(k2, prefix, 1, true) == 1 then
            if g_tmpKeys[v2] == nil then
                g_tmpKeys[v2] = k2
                numKeys = numKeys + 1
            else
                -- duplicate value
                return nil
            end
        end
    end

    if minKeys then
        if numKeys < minKeys then
            return nil
        end
        prefix = longestCommonPrefix(g_tmpKeys, "^(.*[^_]_).")
        if not prefix then
            return nil
        end
    end

    local prefixWithoutLastUnderscore = strsub(prefix, 1, -2)
    local enum = g_enums[prefixWithoutLastUnderscore]
    for v2, k2 in zo_insecureNext, g_tmpKeys do
        enum[v2] = k2
        g_tmpKeys[v2] = nil
        --IMPORTANT: remove g_tmpGroups constant entry (set = nil) here -> to prevent endless loop in calling while . do
        group[k2] = nil
    end

    --Is the while not makeEnum(group, p, 2, true) do run on tmpGroups actually active?
    if calledFromTmpGroupsLoop then
        --Is the current prefix a specical one which could be split into multiple subTables at g_enums?
        --And should these split subTables be combined again to one in the end, afer the while ... do loop was finished?
        -->e.g. SPECIALIZED_ITEMTYPE_*, ITEMTYPE_*
        for prefixRecordAllSubtables, isActivated in pairs(keyToSpecialEnumNoSubtablesInEnum) do
            if isActivated and strfind(prefix, prefixRecordAllSubtables, 1) == 1 then
                --d(">anti-split into subtables found: " ..tos(prefix))
                local ref = specialEnumNoSubtables_subTables[prefixRecordAllSubtables]
                if ref == nil then
                    specialEnumNoSubtables_subTables[prefixRecordAllSubtables] = {}
                    ref = specialEnumNoSubtables_subTables[prefixRecordAllSubtables]
                end
                specialEnumNoSubtables_subTables[prefixRecordAllSubtables][#ref+1] = prefixWithoutLastUnderscore
                --table.insert(specialEnumNoSubtables_subTables[prefixRecordAllSubtables], prefixWithoutLastUnderscore)
            end
        end
    end

    return enum
end

local function makeEnumWithMinMaxAndIterationExclusion(group, prefix, key)
    local doDebug = false --true --todo change to false before release!
    --[[
    local firstEntryKey = next(group)
    if strfind(firstEntryKey, "ITEM_", 1, true) then
        doDebug = true
    end
    ]]

    if doDebug then
        d("==========================================")
        d("[TBUG]makeEnumWithMinMaxAndIterationExclusion - prefix: " ..tos(prefix) .. ", group: " ..tos(group) .. ", key: " ..tos(key))
    end
    ZO_ClearTable(g_tmpKeys)

    local keyToSpecialEnumExcludeEntries = keyToSpecialEnumExclude[key]

    local goOn = true
    for k2, v2 in zo_insecureNext, group do
        local strFoundPos = strfind(k2, prefix, 1, true)
        if strFoundPos ~= nil then
            --Exclude _MIN_VALUE and _MAX_VALUE
            if isIterationOrMinMaxConstant(k2) == false then
if doDebug then
d(">k: " ..tos(k2) .. ", v: " ..tos(v2) .. ", pos: " ..tos(strFoundPos))
end
                if keyToSpecialEnumExcludeEntries ~= nil then
                    for _, vExclude in ipairs(keyToSpecialEnumExcludeEntries) do
                        if strfind(k2, vExclude, 1, true) == 1 then
        if doDebug then
            d("<<excluded: " ..tos(k2))
        end
                            goOn = false
                            break
                        end
                    end
                end
                if goOn then
                    if g_tmpKeys[v2] == nil then
        if doDebug then
            d(">added g_tmpKeys - value: " ..tos(v2) .. ", key: " ..tos(k2))
        end
                        g_tmpKeys[v2] = k2
                    else
        if doDebug then
            d("<<<<<<<<<duplicate value: " ..tos(v2))
        end
                        -- duplicate value
                        return nil
                    end
                end
                --else
                --d("<<<<<--------------------------")
                --d("<<iterationOrMinMax")
            end
        end
    end

    if goOn then
        if doDebug then
            d("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        end

        local prefixWithoutLastUnderscore = strsub(prefix, 1, -2)
        local enum = g_enums[prefixWithoutLastUnderscore]
if doDebug then
    d(">prefixWOLastUnderscore: " ..tos(prefixWithoutLastUnderscore).. ", enum: " ..tos(enum))
end
        for v2, k2 in zo_insecureNext, g_tmpKeys do
            if doDebug then
                d(">added value to enum: " .. tos(v2) .. ", key: " ..tos(k2) .." !Deleted key from tmpGroup!")
            end
            enum[v2] = k2
            group[k2] = nil
            g_tmpKeys[v2] = nil
        end
        return enum
    end
end

local function mapEnum(k, v)
    local prefix = getPrefix(k, "_")
    local skip = g_nonEnumPrefixes[prefix]

    if skip ~= nil then
        if skip == true then
            --prefix = strmatch(k, "^([A-Z][A-Z0-9]*_[A-Z0-9]+_)")
            prefix = getPrefix(k, "_", 2)
        elseif type(skip) == stringType and strfind(k, skip) then
            return
        end
    end

    if prefix ~= nil then
--[[
        if strfind(prefix, "ITEM_", 1, true) == 1 then
d(">Adding tmpGroup: " ..tos(prefix .. ", k: " .. tos(k) .. " = " .. tos(v)))
        end
]]
        g_tmpGroups[prefix][k] = v
        --For ESOStrings comparison, start with number after last vanilla game's SI_ string constant
        -->Addon added ones
        if v > SI_LAST and EsoStrings[v] ~= nil then
            if g_tmpStringIds[v] ~= nil then
                g_tmpStringIds[v] = false
            else
                g_tmpStringIds[v] = k
            end
        end
    end
end


local function mapObject(k, v)
    if g_objects[v] == nil then
        g_objects[v] = k
    else
        g_objects[v] = false
    end
end


local typeMappings = {
    [numberType] = mapEnum;
    [tableType] = mapObject;
    [userDataType] = mapObject;
    [functionType] = mapObject;
}


local function doRefreshLib(lname, ltab)
    for k, v in zo_insecureNext, ltab do
        if type(k) == stringType then
            local mapFunc = typeMappings[type(v)]
            if mapFunc then
                mapFunc(lname .. "." .. k, v)
            end
        end
    end
end

local refreshStartTime
local function doRefresh()
    local doDebug = tbug.doDebug
    if not g_needRefresh then return end
    if g_refreshRunning then
        if tbug.doDebug then
            d("tbug: _G Lookup refresh already active! Started: " .. tos(refreshStartTime ~= nil and refreshStartTime > 0 and os.date("%c", refreshStartTime)))
        end
        return
    end
    if LibAsync ~= nil and doDebug then
        d("tbug: _G Lookup queued to LibAsync...")
    end
    refreshStartTime = GetTimeStamp()
    g_refreshRunning = true

    --Show the loading spinner
    local globalInspector = tbug.getGlobalInspector(false)
    if globalInspector ~= nil then
--d("[Tbug]Global Inspector was found - Start of _G refresh")
        globalInspector.g_refreshRunning = g_refreshRunning
        hideLoadingSpinner(globalInspector.control, false)
    end

    --d("[TBUG]doRefresh")
    ZO_ClearTable(g_objects)
    ZO_ClearTable(g_tmpStringIds)
    ZO_ClearTable(tbug.functionsItemLink)
    ZO_ClearTable(tbug.functionsItemLinkSorted)

    tbug.foreachValue(g_enums, ZO_ClearTable)
    tbug.foreachValue(g_tmpGroups, ZO_ClearTable)

	local function isLibraryGlobal(name, valueType)
        if valueType == tableType then
            -- Check if the name starts with "Lib", "LIB" or "lib"
            return type(name) == stringType and (strlower(strsub(name, 1, 3)) == libraryPrefixComparisonVar) --"lib"
        end
        return false
	end

	local function processLibraryGlobal(name, lib, valueType)
		doRefreshLib(name, lib)
	end

	for k, v in zo_insecureNext, _G do
		local valueType = type(v)
		if isObjectType[valueType] then
			if type(k) == stringType then
				mapObject(k, v)
				-- Check for library globals
				if isLibraryGlobal(k, valueType) then processLibraryGlobal(k, v) end
			end
			--Add *itemlink* functions to lookup table
			if valueType == functionType then checkIfItemLinkFunc(k, v) end
		elseif valueType == numberType and type(k) == stringType then
			local firstLetter = strbyte(k, 1)
			if not (firstLetter < 65 or firstLetter > 90) then mapEnum(k, v) end
		end
	end

    sortItemLinkFunctions()

    --Libraries: With deprecated LibStub
    if LibStub and LibStub.libs then
        doRefreshLib("LibStub", LibStub)
        for libName, lib in zo_insecureNext, LibStub.libs do
            doRefreshLib(libName, lib)
        end
    end

    --Enumerations for right click contextMenus to choose from
    local enumAnchorPosition = g_enums[keyToEnums["point"]]
    enumAnchorPosition[BOTTOM] = "BOTTOM"
    enumAnchorPosition[BOTTOMLEFT] = "BOTTOMLEFT"
    enumAnchorPosition[BOTTOMRIGHT] = "BOTTOMRIGHT"
    enumAnchorPosition[CENTER] = "CENTER"
    enumAnchorPosition[LEFT] = "LEFT"
    enumAnchorPosition[RIGHT] = "RIGHT"
    enumAnchorPosition[TOP] = "TOP"
    enumAnchorPosition[TOPLEFT] = "TOPLEFT"
    enumAnchorPosition[TOPRIGHT] = "TOPRIGHT"
    --enumAnchorPosition[NONE] = "NONE"

    local enumActorCategories = g_enums[keyToEnums["actorCategories"]] --GameplayActorCategories
    enumActorCategories[GAMEPLAY_ACTOR_CATEGORY_PLAYER]  = "GAMEPLAY_ACTOR_CATEGORY_PLAYER"
    enumActorCategories[GAMEPLAY_ACTOR_CATEGORY_COMPANION] = "GAMEPLAY_ACTOR_CATEGORY_COMPANION"

    local enumAnchorConstrains = g_enums[keyToEnums["anchorConstrains"]]
    enumAnchorConstrains[ANCHOR_CONSTRAINS_X] = "ANCHOR_CONSTRAINS_X"
    enumAnchorConstrains[ANCHOR_CONSTRAINS_XY] = "ANCHOR_CONSTRAINS_XY"
    enumAnchorConstrains[ANCHOR_CONSTRAINS_Y] = "ANCHOR_CONSTRAINS_Y"

    local enumControlTypes = g_enums[keyToEnums["type"]]
    enumControlTypes[CT_INVALID_TYPE] = "CT_INVALID_TYPE"
    enumControlTypes[CT_CONTROL] = "CT_CONTROL"
    enumControlTypes[CT_LABEL] = "CT_LABEL"
    enumControlTypes[CT_DEBUGTEXT] = "CT_DEBUGTEXT"
    enumControlTypes[CT_TEXTURE] = "CT_TEXTURE"
    enumControlTypes[CT_TOPLEVELCONTROL] = "CT_TOPLEVELCONTROL"
    enumControlTypes[CT_ROOT_WINDOW] = "CT_ROOT_WINDOW"
    enumControlTypes[CT_TEXTBUFFER] = "CT_TEXTBUFFER"
    enumControlTypes[CT_BUTTON] = "CT_BUTTON"
    enumControlTypes[CT_STATUSBAR] = "CT_STATUSBAR"
    enumControlTypes[CT_EDITBOX] = "CT_EDITBOX"
    enumControlTypes[CT_COOLDOWN] = "CT_COOLDOWN"
    enumControlTypes[CT_TOOLTIP] = "CT_TOOLTIP"
    enumControlTypes[CT_SCROLL] = "CT_SCROLL"
    enumControlTypes[CT_SLIDER] = "CT_SLIDER"
    enumControlTypes[CT_BACKDROP] = "CT_BACKDROP"
    enumControlTypes[CT_MAPDISPLAY] = "CT_MAPDISPLAY"
    enumControlTypes[CT_COLORSELECT] = "CT_COLORSELECT"
    enumControlTypes[CT_LINE] = "CT_LINE"
    enumControlTypes[CT_COMPASS] = "CT_COMPASS"
    enumControlTypes[CT_TEXTURECOMPOSITE] = "CT_TEXTURECOMPOSITE"
    enumControlTypes[CT_POLYGON] = "CT_POLYGON"
    enumControlTypes[CT_VECTOR] = "CT_VECTOR"
    enumControlTypes[CT_CANVAS] = "CT_CANVAS"

    local enumDrawLayer = g_enums[keyToEnums["layer"]]
    enumDrawLayer[DL_BACKGROUND]    = "DL_BACKGROUND"
    enumDrawLayer[DL_CONTROLS]      = "DL_CONTROLS"
    enumDrawLayer[DL_OVERLAY]       = "DL_OVERLAY"
    enumDrawLayer[DL_TEXT]          = "DL_TEXT"

    local enumDrawTier = g_enums[keyToEnums["tier"]]
    enumDrawTier[DT_LOW]    = "DT_LOW"
    enumDrawTier[DT_MEDIUM] = "DT_MEDIUM"
    enumDrawTier[DT_HIGH]   = "DT_HIGH"
    enumDrawTier[DT_PARENT] = "DT_PARENT"

    local enumTradeParticipant = g_enums["TradeParticipant"]
    enumTradeParticipant[TRADE_ME]      = "TRADE_ME"
    enumTradeParticipant[TRADE_THEM]    = "TRADE_THEM"

    local enumTextAlignHor = g_enums[keyToEnums["horizontalAlignment"]]
    enumTextAlignHor[TEXT_ALIGN_LEFT] =    "TEXT_ALIGN_LEFT"
    enumTextAlignHor[TEXT_ALIGN_CENTER] =  "TEXT_ALIGN_CENTER"
    enumTextAlignHor[TEXT_ALIGN_RIGHT] =   "TEXT_ALIGN_RIGHT"

    local enumTextAlignVer = g_enums[keyToEnums["verticalAlignment"]]
    enumTextAlignVer[TEXT_ALIGN_CENTER] =  "TEXT_ALIGN_CENTER"
    enumTextAlignVer[TEXT_ALIGN_TOP] =     "TEXT_ALIGN_TOP"
    enumTextAlignVer[TEXT_ALIGN_BOTTOM] =  "TEXT_ALIGN_BOTTOM"

    local enumTextType = g_enums[keyToEnums["modifyTextType"]]
    enumTextType[TEXT_TYPE_ALL] =                           "TEXT_TYPE_ALL"
    enumTextType[TEXT_TYPE_PASSWORD] =                      "TEXT_TYPE_PASSWORD"
    enumTextType[TEXT_TYPE_NUMERIC] =                       "TEXT_TYPE_NUMERIC"
    enumTextType[TEXT_TYPE_NUMERIC_UNSIGNED_INT] =          "TEXT_TYPE_NUMERIC_UNSIGNED_INT"
    enumTextType[TEXT_TYPE_ALPHABETIC] =                    "TEXT_TYPE_ALPHABETIC"
    enumTextType[TEXT_TYPE_ALPHABETIC_NO_FULLWIDTH_LATIN] = "TEXT_TYPE_ALPHABETIC_NO_FULLWIDTH_LATIN"

    --local enumTextWrapMode = g_enums[keyToEnums["wrapMode"]]
    --enumTextWrapMode[TEXT_WRAP_MODE_TRUNCATE] = "TEXT_WRAP_MODE_TRUNCATE"
    --enumTextWrapMode[TEXT_WRAP_MODE_ELLIPSIS] = "TEXT_WRAP_MODE_ELLIPSIS"

    local enumTexMode = g_enums[keyToEnums["addressMode"]]
    enumTexMode[TEX_MODE_CLAMP] = "TEX_MODE_CLAMP"
    enumTexMode[TEX_MODE_WRAP] = "TEX_MODE_WRAP"

    local enumTexBlendMode = g_enums[keyToEnums["blendMode"]]
    enumTexBlendMode[TEX_BLEND_MODE_ALPHA] = "TEX_BLEND_MODE_ALPHA"
    enumTexBlendMode[TEX_BLEND_MODE_ADD] = "TEX_BLEND_MODE_ADD"
    enumTexBlendMode[TEX_BLEND_MODE_COLOR_DODGE] = "TEX_BLEND_MODE_COLOR_DODGE"

    local enumButtonState = g_enums[keyToEnums["buttonState"]]
    enumButtonState[BSTATE_NORMAL] = "BSTATE_NORMAL"
    enumButtonState[BSTATE_PRESSED] = "BSTATE_PRESSED"
    enumButtonState[BSTATE_DISABLED] = "BSTATE_DISABLED"
    enumButtonState[BSTATE_DISABLED_PRESSED] = "BSTATE_DISABLED_PRESSED"

    local enumBags = g_enums[keyToEnums["bagId"]] --Bags
    enumBags[BAG_WORN]              = "BAG_WORN"
    enumBags[BAG_BACKPACK]          = "BAG_BACKPACK"
    enumBags[BAG_BANK]              = "BAG_BANK"
    enumBags[BAG_GUILDBANK]         = "BAG_GUILDBANK"
    enumBags[BAG_BUYBACK]           = "BAG_BUYBACK"
    enumBags[BAG_VIRTUAL]           = "BAG_VIRTUAL"
    enumBags[BAG_SUBSCRIBER_BANK]   = "BAG_SUBSCRIBER_BANK"
    enumBags[BAG_HOUSE_BANK_ONE]    = "BAG_HOUSE_BANK_ONE"
    enumBags[BAG_HOUSE_BANK_TWO]    = "BAG_HOUSE_BANK_TWO"
    enumBags[BAG_HOUSE_BANK_THREE]  = "BAG_HOUSE_BANK_THREE"
    enumBags[BAG_HOUSE_BANK_FOUR]   = "BAG_HOUSE_BANK_FOUR"
    enumBags[BAG_HOUSE_BANK_FIVE]   = "BAG_HOUSE_BANK_FIVE"
    enumBags[BAG_HOUSE_BANK_SIX]    = "BAG_HOUSE_BANK_SIX"
    enumBags[BAG_HOUSE_BANK_SEVEN]  = "BAG_HOUSE_BANK_SEVEN"
    enumBags[BAG_HOUSE_BANK_EIGHT]  = "BAG_HOUSE_BANK_EIGHT"
    enumBags[BAG_HOUSE_BANK_NINE]   = "BAG_HOUSE_BANK_NINE"
    enumBags[BAG_HOUSE_BANK_TEN]    = "BAG_HOUSE_BANK_TEN"
    enumBags[BAG_COMPANION_WORN]    = "BAG_COMPANION_WORN"
    enumBags[BAG_FURNITURE_VAULT]   = "BAG_FURNITURE_VAULT"
    enumBags[BAG_VENGEANCE]         = "BAG_VENGEANCE"


    -- some enumerations share prefix with other unrelated constants,
    -- making them difficult to isolate;
    -- extract these known trouble-makers explicitly
    makeEnum(g_tmpGroups["ANIMATION_"],     "ANIMATION_PLAYBACK_")
    makeEnum(g_tmpGroups["ATTRIBUTE_"],     "ATTRIBUTE_BAR_STATE_")
    makeEnum(g_tmpGroups["ATTRIBUTE_"],     "ATTRIBUTE_TOOLTIP_COLOR_")
    makeEnum(g_tmpGroups["ATTRIBUTE_"],     "ATTRIBUTE_VISUAL_")
    makeEnum(g_tmpGroups["BUFF_"],          "BUFF_TYPE_COLOR_")
    makeEnum(g_tmpGroups["CD_"],            "CD_TIME_TYPE_")
    makeEnum(g_tmpGroups["CHAT_"],          "CHAT_CATEGORY_HEADER_")
    makeEnum(g_tmpGroups["EVENT_"],         "EVENT_REASON_")
    makeEnum(g_tmpGroups["GAME_"],          "GAME_CREDITS_ENTRY_TYPE_")
    makeEnum(g_tmpGroups["GAME_"],          "GAME_NAVIGATION_TYPE_")
    makeEnum(g_tmpGroups["GUILD_"],         "GUILD_HISTORY_ALLIANCE_WAR_")
    makeEnum(g_tmpGroups["INVENTORY_"],     "INVENTORY_UPDATE_REASON_")
    makeEnum(g_tmpGroups["JUSTICE_"],       "JUSTICE_SKILL_")
    makeEnum(g_tmpGroups["MOVEMENT_"],      "MOVEMENT_CONTROLLER_DIRECTION_")
    makeEnum(g_tmpGroups["NOTIFICATIONS_"], "NOTIFICATIONS_MENU_OPENED_FROM_")
    makeEnum(g_tmpGroups["OBJECTIVE_"],     "OBJECTIVE_CONTROL_EVENT_")
    makeEnum(g_tmpGroups["OBJECTIVE_"],     "OBJECTIVE_CONTROL_STATE_")
    makeEnum(g_tmpGroups["OPTIONS_"],       "OPTIONS_CUSTOM_SETTING_")
    makeEnum(g_tmpGroups["PPB_"],           "PPB_CLASS_")
    makeEnum(g_tmpGroups["RIDING_"],        "RIDING_TRAIN_SOURCE_")
    makeEnum(g_tmpGroups["STAT_"],          "STAT_BONUS_OPTION_")
    makeEnum(g_tmpGroups["STAT_"],          "STAT_SOFT_CAP_OPTION_")
    makeEnum(g_tmpGroups["STAT_"],          "STAT_VALUE_COLOR_")
    makeEnum(g_tmpGroups["TRADING_"],       "TRADING_HOUSE_SORT_LISTING_")


    --LibAsync is not provided?
    if libAS == nil then
        --Transfer the tmpGroups of constants to the enumerations table, using the tmpGroups prefix e.g. SPECIALIZED_ and
        --checking for + creating subTables like SPECIALIZED_ITEMTYPE etc.
        --Enum entries at least need 2 constants entries in the g_tmpKeys or it will fail to create a new subTable
        for prefix, group in zo_insecureNext , g_tmpGroups do
            repeat
                local final = true
                for k, _ in zo_insecureNext , group do
                    -- find the shortest prefix that yields distinct values
                    local p, f = prefix, false
                    --Make the enum entry now and remove g_tmpGroups constant entry (set = nil) -> to prevent endless loop!
                    while not makeEnum(group, p, 2, true) do
                        --Creates subTables at "_", e.g. SPECIALIZED_ITEMTYPE, SPECIALIZED_ITEMTYP_ARMOR, ...
                        local _, me = strfind(k, "[^_]_", #p + 1)
                        if not me then
                            f = final
                            break
                        end
                        p = strsub(k, 1, me)
                    end
                    final = f
                end
            until final
        end

        --Create the 1table for the before split subtables -> like SPECIALIZED_ITEMTYPE_ again now
        -->Loop all the relevant subtables
        if specialEnumNoSubtables_subTables and not ZO_IsTableEmpty(specialEnumNoSubtables_subTables) then
            for prefixWhichGotSubtables, subtableNames in pairs(specialEnumNoSubtables_subTables) do
                local prefixWithoutLastUnderscore = strsub(prefixWhichGotSubtables, 1, -2)
        --d(">>combining subtables to 1 table: " ..tos(prefixWithoutLastUnderscore))
                g_enums[prefixWithoutLastUnderscore] = g_enums[prefixWithoutLastUnderscore] or {}
                for _, subTablePrefixWithoutUnderscore in ipairs(subtableNames) do
        --d(">>>subtable name: " ..tos(subTablePrefixWithoutUnderscore))
                    local subTableData = g_enums[subTablePrefixWithoutUnderscore]
                    if subTableData ~= nil then
                        for constantValue, constantName in pairs(subTableData) do
        --d(">>>>copied constant from subtable: " ..tos(constantName) .. " (" .. tos(constantValue) ..")")
                            if type(constantName) == stringType then
                                g_enums[prefixWithoutLastUnderscore][constantValue] = constantName
                            end
                        end
                    end
                end
            end
        end

        --For the Special cRightKey entries at tableInspector
        local alreadyCheckedValues = {}
        for k, v in pairs(keyToSpecialEnum) do
            if not alreadyCheckedValues[v] then
                alreadyCheckedValues[v] = true
                local tmpGroupEntry = keyToSpecialEnumTmpGroupKey[k]
                local selectedTmpGroupTable = tmpGroupEntry ~= nil and g_tmpGroups[tmpGroupEntry] or nil
                if selectedTmpGroupTable ~= nil then
                    --d("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
                    --d(">>group: " ..tos(selectedTmpGroupTable))
                    makeEnumWithMinMaxAndIterationExclusion(selectedTmpGroupTable, v, k)
                end
            end
        end

        --Strings in _G.EsoStrings
        local enumStringId = g_enums["SI"]
        for v, k in zo_insecureNext, g_tmpStringIds do
            if k then
                enumStringId[v] = k
            end
        end

        --Prepare the entries for the filterCombobox at the global inspector
        tbug.filterComboboxFilterTypesPerPanel = {}
        local filterComboboxFilterTypesPerPanel = tbug.filterComboboxFilterTypesPerPanel
        --"Controls" panel
        filterComboboxFilterTypesPerPanel[getTBUGGlobalInspectorPanelIdByName("controls")] = g_enums[keyToEnums["type"]] --ZO_ShallowTableCopy(g_enums[keyToEnums["type"]]) --CT_CONTROL, at "controls" tab

        g_needRefresh = false
        g_refreshRunning = false

        if globalInspector ~= nil then
            globalInspector.g_refreshRunning = g_refreshRunning
            hideLoadingSpinner(globalInspector.control, true)
        end

    else
        --LibAsync IS provided?
        --Examples

        local start = GetGameTimeMilliseconds()
        local task = libAS:Create("TBug_task-_G_ENUMs_Parse")
        local start2

        local enumError = false


        task:For(zo_insecureNext, g_tmpGroups):Do(function(prefix, group)
            --d("prefix: " .. tos(prefix).. "; group: " ..tos(group))
            --Transfer the tmpGroups of constants to the enumerations table, using the tmpGroups prefix e.g. SPECIALIZED_ and
            --checking for + creating subTables like SPECIALIZED_ITEMTYPE etc.
            --Enum entries at least need 2 constants entries in the g_tmpKeys or it will fail to create a new subTable
            --for prefix, group in zo_insecureNext , g_tmpGroups do

            local i = 0
            local final = true

            task:While(function() return final == true and i < 15000 end):Do(function() --repeat until final is changed to false -> max 15000 loops to prevent an endless loop
--d(">loop #" ..tostring(i) .. ", final: " .. tostring(final))
                --repeat
                i = i + 1 --security varibale to prevent an endless while loop
                --for k, _ in zo_insecureNext , group do
                task:For(zo_insecureNext, group):Do(function(k, v)
                    local doAbort = false
                    --final = true

                    -- find the shortest prefix that yields distinct values
                    local p, f = prefix, false
                    --Make the enum entry now and remove g_tmpGroups constant entry (set = nil) -> to prevent endless loop!
                    task:While(function()
                        if doAbort == true then
                            --d("<<ABORT while now!")
                            doAbort = false
                            return false
                        else
                            return not makeEnum(group, p, 2, true)
                        end
                    end):Do(function()
                        --while not makeEnum(group, p, 2, true) do
                        --Creates subTables at "_", e.g. SPECIALIZED_ITEMTYPE, SPECIALIZED_ITEMTYP_ARMOR, ...
                        local _, me = strfind(k, "[^_]_", #p + 1)
                        if not me then
                            f = final
                            --d("<Breaking the inner loop: " ..tostring(k) .. ", f: " .. tostring(f))
                            --break --break inner while loop
                            doAbort = true
                        end
                        if doAbort == false then
                            p = strsub(k, 1, me)
                        end
                    end)
                    final = f
                    --end
                end)
                --until final
                --end
            end)
        end):Then(function(p_task)
--d(">>next steps - final was false!")
            --start2 = GetGameTimeMilliseconds()
            --df("tbug: LibAsync global ENUM groups generation took %ims", start2 - start)

            --Transfer the special ENUM subtables back to 1
            --Create special enmus
            --Add the SI string value enums

            --Create the 1table for the before split subtables -> like SPECIALIZED_ITEMTYPE_ again now
            -->Loop all the relevant subtables
            if not ZO_IsTableEmpty(specialEnumNoSubtables_subTables) then
                for prefixWhichGotSubtables, subtableNames in pairs(specialEnumNoSubtables_subTables) do
                    local prefixWithoutLastUnderscore = strsub(prefixWhichGotSubtables, 1, -2)
        --d(">>combining subtables to 1 table: " ..tos(prefixWithoutLastUnderscore))
                    g_enums[prefixWithoutLastUnderscore] = g_enums[prefixWithoutLastUnderscore] or {}
                    for _, subTablePrefixWithoutUnderscore in ipairs(subtableNames) do
        --d(">>>subtable name: " ..tos(subTablePrefixWithoutUnderscore))
                        local subTableData = g_enums[subTablePrefixWithoutUnderscore]
                        if subTableData ~= nil then
                            for constantValue, constantName in pairs(subTableData) do
        --d(">>>>copied constant from subtable: " ..tos(constantName) .. " (" .. tos(constantValue) ..")")
                                if type(constantName) == stringType then
                                    g_enums[prefixWithoutLastUnderscore][constantValue] = constantName
                                end
                            end
                        end
                    end
                end
            end
        end):Then(function(p_task)
            --For the Special cRightKey entries at tableInspector
            local alreadyCheckedValues = {}
            for k, v in pairs(keyToSpecialEnum) do
                if not alreadyCheckedValues[v] then
                    alreadyCheckedValues[v] = true
                    local tmpGroupEntry = keyToSpecialEnumTmpGroupKey[k]
                    local selectedTmpGroupTable = tmpGroupEntry ~= nil and g_tmpGroups[tmpGroupEntry] or nil
                    if selectedTmpGroupTable ~= nil then
                        --d("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
                        --d(">>tmpGroupEntry: " ..tos(tmpGroupEntry))
                        makeEnumWithMinMaxAndIterationExclusion(selectedTmpGroupTable, v, k)
                    end
                end
            end

        end):Then(function(p_task)
            --Strings in _G.EsoStrings
            local enumStringId = g_enums["SI"]
            for v, k in zo_insecureNext, g_tmpStringIds do
                if k then
                    enumStringId[v] = k
                end
            end

        end):Then(function(p_task)
            --Prepare the entries for the filterCombobox at the global inspector
            tbug.filterComboboxFilterTypesPerPanel = {}
            local filterComboboxFilterTypesPerPanel = tbug.filterComboboxFilterTypesPerPanel
            --"Controls" panel
            filterComboboxFilterTypesPerPanel[getTBUGGlobalInspectorPanelIdByName("controls")] = g_enums[keyToEnums["type"]] --ZO_ShallowTableCopy(g_enums[keyToEnums["type"]]) --CT_CONTROL, at "controls" tab


        end)
        :OnError(function(p_task)
            df("tbug: [ERROR] at LibAsync global ENUM generation. Took %ims", GetGameTimeMilliseconds() - start)
            enumError = true
        end)
        :Finally(function(p_task)
            --df("[Tbug]ENUM special and StringId generation took %ims", GetGameTimeMilliseconds() - start2)
            if not enumError then
                if doDebug then
                    df("tbug: LibAsync global ENUM generation finished after %ims", GetGameTimeMilliseconds() - start)
                end
                g_needRefresh = false
            else
                g_needRefresh = true
            end

            g_refreshRunning = false

            if globalInspector ~= nil then
                --d("[Tbug]Global Inspector was found - End of _G refresh")
                globalInspector.g_refreshRunning = g_refreshRunning
                hideLoadingSpinner(globalInspector.control, true)
            end
        end)
    end
end
tbug.doRefresh = doRefresh


--Controls if the debug message after loading _G table should show in chat
if DEBUG >= 1 then
    --If LibAsync is enabled: Prepare the lookup tables etc for tbug already after addon load -> See file main.lua EVENT_ADD_ON_LOADED
    if LibAsync == nil then
        doRefresh = tbug.timed("tbug: _G Lookup refresh", doRefresh)
    end
end


function tbug.glookup(obj)
    if g_needRefresh and not g_refreshRunning then
        doRefresh()
    end
    return g_objects[obj]
end

function tbug.glookupEnum(prefix)
    if g_needRefresh and not g_refreshRunning then
        doRefresh()
    end
    return g_enums[prefix]
end

function tbug.glookupRefresh(now)
    if now then
        doRefresh()
    else
        g_needRefresh = true
    end
end
