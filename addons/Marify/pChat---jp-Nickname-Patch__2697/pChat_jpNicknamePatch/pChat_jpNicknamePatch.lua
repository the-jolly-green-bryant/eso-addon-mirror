pChat_jpNicknamePatch = {
    displayName = "|c3CB371" .. "pChat - jp Nickname Patch" .. "|r",
    shortName = "PJP",
    name = "pChat_jpNicknamePatch",
    version = "1.3.12",
    nicknames = {},
    filters = {},
    guildRoster = nil,
    groupList = nil,
    friendsList = nil,
    ignoreList = nil,
    fontControlNames = {"pChatOptions"},

    excludeFonts = {
        -- [LibMediaProvider] ---------------------------------------------------
        --"ProseAntique",             -- "$(PROSE_ANTIQUE_FONT)     -- "EsoUI/Common/Fonts/ProseAntiquePSMT.otf"
        --"Consolas",                 -- "$(CONSOLAS_FONT)          -- "EsoUI/Common/Fonts/consola.ttf"
        --"Futura Condensed Light",   -- "$(FTN47_FONT)             -- "EsoUI/Common/Fonts/FTN47.otf"
        --"Futura Condensed",         -- "$(FTN57_FONT)             -- "EsoUI/Common/Fonts/FTN57.otf"
        --"Futura Condensed Bold",    -- "$(FTN87_FONT)             -- "EsoUI/Common/Fonts/FTN87.otf"
        --"Skyrim Handwritten",       -- "$(HANDWRITTEN_BOLD_FONT)  -- "EsoUI/Common/Fonts/Handwritten_Bold.otf"
        --"Trajan Pro",               -- "$(TRAJAN_PRO_R_FONT)      -- "EsoUI/Common/Fonts/trajanpro-regular.otf"
        --"Univers 55",               -- "$(UNIVERS55_FONT)         -- "EsoUI/Common/Fonts/univers55.otf"
        --"Univers 57",               -- "$(UNIVERS57_FONT)         -- "EsoUI/Common/Fonts/univers57.otf"
        --"Univers 67",               -- "$(UNIVERS67_FONT)         -- "EsoUI/Common/Fonts/univers67.otf"

        -- [pChat] ---------------------------------------------------
        "ESO Standard Font",        -- EsoUI/Common/Fonts/univers57.otf
        "ESO Book Font",            -- EsoUI/Common/Fonts/ProseAntiquePSMT.otf
        "ESO Tablet Font",          -- EsoUI/Common/Fonts/TrajanPro-Regular.otf
        "Arvo",                     -- pChat/fonts/Arvo/Arvo-Regular.ttf
        "DejaVuSans",               -- pChat/fonts/DejaVu/DejaVuSans.ttf
        "DejaVuSansCondensed",      -- pChat/fonts/DejaVu/DejaVuSansCondensed.ttf
        "DejaVuSansMono",           -- pChat/fonts/DejaVu/DejaVuSansMono.ttf
        "DejaVuSerif",              -- pChat/fonts/DejaVu/DejaVuSerif.ttf
        "DroidSans",                -- pChat/fonts/Droid_Sans/DroidSans.ttf
        "OpenSans",                 -- pChat/fonts/OpenSans/OpenSans-Regular.ttf
        "OpenSans Semibold",        -- pChat/fonts/OpenSans/OpenSans-Semibold.ttf
        "Prociono",                 -- pChat/fonts/Prociono/Prociono-Regular.otf
        "PT_Sans",                  -- pChat/fonts/PT_Sans/PT_Sans-Web-Regular.ttf
        "Ubuntu",                   -- pChat/fonts/Ubuntu/Ubuntu-Regular.ttf
        "Ubuntu Medium",            -- pChat/fonts/Ubuntu/Ubuntu-Medium.ttf
        "Vollkorn",                 -- pChat/fonts/Vollkorn/Vollkorn-Regular.ttf
        "RuEsoChat",                -- pChat/fonts/RuEsoChat/RuEsoChat.ttf
        "OpenDyslexic",             -- pChat/fonts/OpenDyslexic/OpenDyslexicAlta-Regular.otf

        -- [LuiExtended] ---------------------------------------------------
        --"ProseAntique",             -- ZoFontBookPaper:GetFontInfo(),
        --"Skyrim Handwritten",       -- ZoFontBookLetter:GetFontInfo(),
        --"Trajan Pro",               -- ZoFontBookTablet:GetFontInfo(),
        --"Univers 57",               -- ZoFontGame:GetFontInfo(),
        --"Univers 67",               -- ZoFontWinH1:GetFontInfo(),
        --"Consolas",                 -- /EsoUI/Common/Fonts/consola.ttf
        --"Futura Condensed Light",   -- /EsoUI/Common/Fonts/FTN47.otf
        --"Futura Condensed",         -- /EsoUI/Common/Fonts/FTN57.otf
        --"Futura Condensed Bold",    -- /EsoUI/Common/Fonts/FTN87.otf
        --"Univers 55",               -- /EsoUI/Common/Fonts/univers55.otf
        "Fontin Bold",              -- /LuiExtended/media/fonts/fontin_sans_b.otf
        "Fontin Italic",            -- /LuiExtended/media/fonts/fontin_sans_i.otf
        "Fontin Regular",           -- /LuiExtended/media/fonts/fontin_sans_r.otf
        "Fontin SmallCaps",         -- /LuiExtended/media/fonts/fontin_sans_sc.otf
        "Trajan Pro Bold",          -- /LuiExtended/media/fonts/TrajanProBold.otf
        "EnigmaReg",                -- /LuiExtended/media/fonts/EnigmaReg.ttf
        "EnigmaBold",               -- /LuiExtended/media/fonts/EnigmaBold.ttf
        "Adventure",                -- /LuiExtended/media/fonts/adventure.ttf
        "Bazooka",                  -- /LuiExtended/media/fonts/bazooka.ttf
        "Cooline",                  -- /LuiExtended/media/fonts/cooline.ttf
        "Diogenes",                 -- /LuiExtended/media/fonts/diogenes.ttf
        "Ginko",                    -- /LuiExtended/media/fonts/ginko.ttf
        "Heroic",                   -- /LuiExtended/media/fonts/heroic.ttf
        "Metamorphous",             -- /LuiExtended/media/fonts/metamorphous.otf
        "Porky",                    -- /LuiExtended/media/fonts/porky.ttf
        "Roboto Bold",              -- /LuiExtended/media/fonts/Roboto-Bold.ttf
        "Roboto Bold Italic",       -- /LuiExtended/media/fonts/Roboto-BoldItalic.ttf
        "Talisman",                 -- /LuiExtended/media/fonts/talisman.ttf
        "Transformers",             -- /LuiExtended/media/fonts/transformers.ttf
        "Yellowjacket",             -- /LuiExtended/media/fonts/yellowjacket.ttf
        "ProFontWindows",           -- /LuiExtended/media/fonts/ProFontWindows.ttf
        "FORCED SQUARE",            -- /LuiExtended/media/fonts/FORCED_SQUARE.ttf
    },
    newFonts = {
        --["Univers 57"]                    = "$(CHAT_FONT)",
        --["Univers 67"]                    = "$(BOLD_FONT)",
        ["ESO スタンダード"]                = "$(ESO_STD_JP_FONT)",
        ["ESO チャット"]                    = "$(ESO_CHAT_JP_FONT)",
        ["ESO アンティーク"]                = "$(ANTIQUE_FONT)",
        ["[JP]JapanSans70"]                 = "pChat_jpNicknamePatch/fonts/JapanSans/JapanSans70.otf",
        ["[JP]JapanSans80"]                 = "pChat_jpNicknamePatch/fonts/JapanSans/JapanSans80.otf",
        ["[JP]JapanSans90"]                 = "pChat_jpNicknamePatch/fonts/JapanSans/JapanSans90.otf",
        ["[JP]Rounded M+"]                  = "$(JP_ROUND_MPLUS_FONT)",
        ["[JP]Rounded M+ ミディアム"]       = "$(JP_ROUND_MPLUS_MID_FONT)",
        ["[JP]Rounded M+ 太字"]             = "$(JP_ROUND_MPLUS_BOLD_FONT)",
        ["[JP]Rounded M++"]                 = "$(JP_ROUND_MPLUSPLUS_FONT)",
        ["[JP]マキナス 4 Flat"]             = "pChat_jpNicknamePatch/fonts/Makinas4/Makinas-4-Flat.otf",
    },
    defFont  = "ESO スタンダード",
    halfFont = "ESO チャット",

}
LibMediaProvider.MediaTable.font["Univers 57"] = "$(ESO_STD_JP_FONT)"  -- 指定がミスってるので上書き
LibMediaProvider.MediaTable.font["Univers 67"] = "$(ESO_CHAT_JP_FONT)" -- 指定がミスってるので上書き
for name, path in pairs(pChat_jpNicknamePatch.newFonts) do
    LibMediaProvider:Register("font", name, path)
end




function pChat_jpNicknamePatch:CreateFilter(guildId)

    local filter = {
        {"\n.*",  ""},
        {" ", " "},   -- NO-BREAK SPACE(U+00A0) to SPACE (U+0020)
        {"　", " "},
        {"([ ]+)", " "},
    }

    local addFilter = self.savedVariables.setting[guildId].filter
    if addFilter and addFilter ~= "" then
        addFilter = addFilter:gsub("\n", "")
        local values = {zo_strsplit(",", addFilter)}
        for _, value in ipairs(values) do
            filter[#filter + 1] = {value, ""}
        end
    end

    filter[#filter + 1] = {"[(].*", ""}
    filter[#filter + 1] = {"([^ ]+) ([^ ]+).*", "%1"}
    filter[#filter + 1] = {" ", ""}
    return filter
end




function pChat_jpNicknamePatch:CreateMenu()

    self.savedVariables = ZO_SavedVars:NewAccountWide("pChat_jpNicknamePatchVariables", 2, nil, {})
    if self.savedVariables.setting == nil then
        self.savedVariables.setting = {}
    end
    if self.savedVariables.nameFormat == nil then
        self.savedVariables.nameFormat = 1
    end
    self.savedVariables.debugLog = nil

    local panelData = {
        type = "panel",
        name = self.displayName,
        displayName = self.displayName,
        author = "Marify",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LibAddonMenu2:RegisterAddonPanel(self.displayName, panelData)


    local optionsTable = {
        {
            type = "header",
            name = GetString(PJP_NICKNAMES_HEADER),
            width = "full",
        },
        {
            type = "dropdown",
            name = GetString(PCHAT_NAMEFORMAT),
            choices = {
                GetString(PCHAT_FORMATCHOICE1),
                GetString(PCHAT_FORMATCHOICE2),
                GetString(PCHAT_FORMATCHOICE3),
                GetString(PCHAT_FORMATCHOICE4)
            },
            choicesValues = {1, 2, 3, 4},
            getFunc = function()
                return self.savedVariables.nameFormat
            end,
            setFunc = function(value)
                self.savedVariables.nameFormat = value
                self:CreateNicknames()
            end,
            width = "full",
            default = 1,
        },
    }


    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        local guildName = GetGuildName(guildId)
        if guildName then

            if self.savedVariables.setting[guildId] == nil then
                self.savedVariables.setting[guildId] = {}
            end
            if self.savedVariables.setting[guildId].guildName == nil then
                self.savedVariables.setting[guildId].guildName = guildName
            end
            if self.savedVariables.setting[guildId].useNicknames == nil then
                self.savedVariables.setting[guildId].useNicknames = (guildId == 544633)
            end
            if self.savedVariables.setting[guildId].filter == nil then
                self.savedVariables.setting[guildId].filter = ""
            end
            if self.savedVariables.setting[guildId].useNicknames
                and self.savedVariables.setting[guildId].filter == "" then
                if guildId == 544633 then
                    self.savedVariables.setting[guildId].filter = GetString(PJP_FILTER_BB)
                else
                    self.savedVariables.setting[guildId].filter = GetString(PJP_FILTER_DEF)
                end
            end

            local controlList = {
                {
                    type = "checkbox",
                    name = GetString(PJP_NICKNAMES_USE),
                    getFunc = function()
                        return self.savedVariables.setting[guildId].useNicknames
                    end,
                    setFunc = function(value)
                        self.savedVariables.setting[guildId].useNicknames = value

                        if value and self.savedVariables.setting[guildId].filter == "" then
                            if guildId == 544633 then
                                self.savedVariables.setting[guildId].filter = GetString(PJP_FILTER_BB)
                            else
                                self.savedVariables.setting[guildId].filter = GetString(PJP_FILTER_DEF)
                            end
                        end
                        self:CreateNicknames()
                    end,
                    width = "full",
                    default = false,
                    requiresReload = true,
                },
                {
                    type = "editbox",
                    name = GetString(PJP_FILTER),
                    getFunc = function()
                        return self.savedVariables.setting[guildId].filter
                    end,
                    setFunc = function(value)
                        if value and value ~= "" and (string.match(value, ".$") ~= ",") then
                            value = value .. ","
                        end
                        self.savedVariables.setting[guildId].filter = value
                        self:CreateNicknames()
                    end,
                    disabled = function()
                        return (self.savedVariables.setting[guildId].useNicknames ~= true)
                    end,
                    isMultiline = true,
                    isExtraWide = true,
                    textType = TEXT_TYPE_ALL,
                    width = "full",
                    default = "",
                },
                {
                    type = "button",
                    name = GetString(PJP_FILTER_RESET),
                    func = function()
                        if guildId == 544633 then
                            self.savedVariables.setting[guildId].filter = GetString(PJP_FILTER_BB)
                        else
                            self.savedVariables.setting[guildId].filter = GetString(PJP_FILTER_DEF)
                        end
                        self:CreateNicknames()
                    end,
                    disabled = function()
                        return (self.savedVariables.setting[guildId].useNicknames ~= true)
                    end,
                   width = "full",
                },
            }

            optionsTable[#optionsTable + 1] = {
                type = "submenu",
                name = guildName,
                controls = controlList,
            }
        end
    end


    optionsTable[#optionsTable + 1] = {
        type = "header",
        name = GetString(PJP_OTHER_HEADER),
        width = "full",
    }

    optionsTable[#optionsTable + 1] = {
        type = "checkbox",
        name = GetString(PJP_DEBUG_LOG),
        getFunc = function()
            return self.savedVariables.isDebug
        end,
        setFunc = function(value)
            self.savedVariables.isDebug = value
        end,
        width = "full",
        default = false,
    },


    LibAddonMenu2:RegisterOptionControls(self.displayName, optionsTable)
end




function pChat_jpNicknamePatch:CreateNickname(guildId, memberIndex)

    local limit = 86400 * 60 -- (60 * 60 * 24) * 60 = 60day
    local userId, note, rankIndex, playerStatus, sinceLogoff  = GetGuildMemberInfo(guildId, memberIndex)
    if note == nil or note =="" then
        return userId, nil, nil
    end
    if self:IsDebug() == false and sinceLogoff > (86400 * 30) then    -- 1day(60 * 60 * 24) * 30 = 30day
        return userId, nil, nil
    end

    local filter = self.filters[guildId]
    if filter == nil then
        filter = self:CreateFilter(guildId)
        self.filters[guildId] = filter
    end

    local nickname = note
    for _, value in ipairs(filter) do
        nickname = string.gsub(nickname, value[1], value[2])
    end
    if nickname == nil or nickname =="" then
        return userId, nil, nil
    end
    note = note:gsub("\n.*", ""):sub(1, 100)

    if self.savedVariables.nameFormat == 1 then -- @UserID
        if self:IsDebug() then
            self:Debug(zo_strformat("|cFFFFFF<<1>>(|r|c7CFC00<<2>>|r)　|c808080<<3>>|r", userId,
                                                                                         nickname,
                                                                                         note))
        end
        return userId, userId .. "(" .. nickname .. ")", nickname
    end


    local hasCharacter, characterName = GetGuildMemberCharacterInfo(guildId, memberIndex)
    if hasCharacter and characterName then
        characterName = string.gsub(characterName, "(\^)%a*", "")
    end

    if self.savedVariables.nameFormat == 2 then -- Char
        if self:IsDebug() then
            self:Debug(zo_strformat("|cFFFFFF<<1>>(|r|c7CFC00<<2>>|r)　|c808080<<3>>|r", characterName,
                                                                                         nickname,
                                                                                         note))
        end
        return userId, characterName .. "(" .. nickname .. ")", nickname

    elseif self.savedVariables.nameFormat == 3 then -- Char@UserID
        if self:IsDebug() then
            self:Debug(zo_strformat("|cFFFFFF<<1>>(|r|c7CFC00<<2>>|r)　|c808080<<3>>|r", characterName .. userId,
                                                                                         nickname,
                                                                                         note))
        end
        return userId, characterName .. userId .. "(" .. nickname .. ")", nickname

    elseif self.savedVariables.nameFormat == 4 then -- @UserID/Char
        if self:IsDebug() then
            self:Debug(zo_strformat("|cFFFFFF<<1>>(|r|c7CFC00<<2>>|r)/|cFFFFFF<<3>>|r　|c808080<<4>>|r", userId,
                                                                                                         nickname,
                                                                                                         characterName,
                                                                                                         note))
        end
        return userId, userId .. "(" .. nickname .. ")/" .. characterName, nickname
    end
    return userId, nil, nil

end




function pChat_jpNicknamePatch:CreateNicknames()

    self.nicknames = {}
    self.filters = {}
    local guildId
    local numMembers
    local userId, nickname
    for guildIndex = 1, GetNumGuilds() do
        guildId = GetGuildId(guildIndex)
        if self.savedVariables.setting[guildId].useNicknames then
            numMembers = GetGuildInfo(guildId)
            for i = 1, numMembers do
                userId, nickname, nicknameOrigin = self:CreateNickname(guildId, i)
                pChat.pChatData.nicknames[userId] = nickname
                self.nicknames[userId] = nicknameOrigin
            end
        end
    end

end




function pChat_jpNicknamePatch:Hook_ThurisazGuildInfo()

    local existingFunction = TI["createNameToDisplay"]
    if existingFunction == nil then
        return
    end

    TI["createNameToDisplay"] = function(ThurisazGuildInfo, guildId, AccName, charName)
        local result = existingFunction(ThurisazGuildInfo, guildId, AccName, charName)
        pChat_jpNicknamePatch:Debug("ThurisazGuildInfo:createNameToDisplay = " .. tostring(result))

        if result then
            local nicknames = self.nicknames[AccName]
            if nicknames then
                result = zo_strformat("<<1>>(<<2>>)", result, nicknames)
                pChat_jpNicknamePatch:Debug("　　>" .. tostring(result))
            end
        end
        return result
    end

end




function pChat_jpNicknamePatch:LuiExtended_SetNickname(maxIndex)
    self:Debug("[LuiExtended_SetNickname] maxIndex=" .. tostring(maxIndex))

    local customFrames = LUIE.UnitFrames.CustomFrames
    local saveValue = LUIE.UnitFrames.SV
    local baseNames
    if maxIndex == 24 then
        baseNames = {"SmallGroup", "RaidGroup"}
    else
        baseNames = {"RaidGroup"}
    end


    local sizeCaption = (saveValue.CustomFontOther and saveValue.CustomFontOther > 0 ) and saveValue.CustomFontOther or 16
    local position = -5
    if sizeCaption <= 12 then
        position = -2
    elseif sizeCaption <= 15 then
        position = -3
    elseif sizeCaption <= 18 then
        position = -4
    end


    local unitFrame
    local unitTag
    local displayName
    local nickname
    local name
    local minusWidth
    local start
    for _, baseName in pairs(baseNames) do
        for i = 1, maxIndex do

            unitTag = GetGroupUnitTagByIndex(i)
            unitFrame = customFrames[baseName .. i]
            if unitTag and unitFrame then
                if i == 1 then
                    self:Debug("　　[" .. baseName .. "]--------------")
                    if baseName == "SmallGroup" then
                        self:Debug("　　fontSize=" .. sizeCaption)
                        self:Debug("　　textPosition=" .. position)
                    end
                end

                self:Debug("　　unitTag:" .. tostring(unitTag))
                name = unitFrame.name:GetText():gsub(" @", "@")
                if not string.find(name, "[)]$") then
                    displayName = GetUnitDisplayName(unitTag)
                    nickname = self.nicknames[displayName]
                    if nickname then
                        name = zo_strformat("<<1>>(<<2>>)", name, nickname)
                        unitFrame.name:SetText(name)
                    end
                end

                start = 0               -- def:22
                minusWidth = 115        -- def:115
                if IsUnitGroupLeader(unitTag) then
                    start = 20                      -- def:22
                    minusWidth = minusWidth + start -- def:137
                end
                if baseName == "RaidGroup" then
                    minusWidth = minusWidth - 10
                end

                unitFrame.name:SetWidth(saveValue.GroupBarWidth - minusWidth)
                if baseName == "SmallGroup" then
                    unitFrame.name:ClearAnchors()
                    unitFrame.name:SetAnchor(LEFT, unitFrame.topInfo, LEFT, start, position)

                    if unitFrame.levelIcon then
                        unitFrame.levelIcon:ClearAnchors()
                        unitFrame.levelIcon:SetAnchor(LEFT, unitFrame.topInfo, LEFT, unitFrame.name:GetTextWidth() + start + 1, 0)
                    end
                end

            end
        end
    end

end




function pChat_jpNicknamePatch:LuiExtended_SetSaveValues()
    self:Debug("[LuiExtended_SetSaveValues]")

    LUIE.UnitFrames.Defaults.DefaultFontFace = self.defFont

    local choices = {}
    LUIE.Fonts = {}
    for name, path in pairs(LibMediaProvider:HashTable("font")) do
        LUIE.Fonts[name] = path
        table.insert(choices, name)
    end
    for name, path in pairs(self.newFonts) do
        LUIE.Fonts[name] = path
        table.insert(choices, name)
    end


    local saveName
    local saveObjectList = {
        {"UnitFrames",      LUIE.UnitFrames.SV,                 "CustomFontFace",           self.halfFont},
        {"UnitFrames",      LUIE.UnitFrames.SV,                 "DefaultFontFace",          self.halfFont},
        {"BuffsAndDebuffs", LUIE.SpellCastBuffs.SV,             "BuffFontFace",             self.defFont},
        {"BuffsAndDebuffs", LUIE.SpellCastBuffs.SV,             "ProminentLabelFontFace",   self.defFont},
        {"CombatInfo",      LUIE.CombatInfo.SV,                 "UltimateFontFace",         self.defFont},
        {"CombatInfo",      LUIE.CombatInfo.SV,                 "BarFontFace",              self.defFont},
        {"CombatInfo",      LUIE.CombatInfo.SV,                 "PotionTimerFontFace",      self.defFont},
        {"CombatInfo",      LUIE.CombatInfo.SV,                 "CastBarFontFace",          self.defFont},
        {"CombatInfo",      LUIE.CombatInfo.SV.alerts.toggles,  "alertFontFace",            self.defFont},
    }
    local keyName
    local fontame
    local value
    for i = 1, #saveObjectList do
        saveName   = saveObjectList[i][1]
        saveObject = saveObjectList[i][2]
        keyName    = saveObjectList[i][3]
        fontame    = saveObjectList[i][4]
        value = saveObject[keyName]
        self:Debug(zo_strformat("　　　　<<1>>.<<2>>=<<3>>", saveName, keyName, tostring(value)))
        if not(value and self:Equal(value, choices)) then
            saveObject[keyName] = fontame
            self:Debug("　　　　>" .. tostring(saveObject[keyName]))
        end
    end

end




function pChat_jpNicknamePatch:OnAddOnLoaded(event, addonName)

    if addonName ~= self.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    setmetatable(pChat_jpNicknamePatch, {__index = LibMarify})


    self:CreateMenu()
    self:CreateNicknames()

    if IsInGamepadPreferredMode() then
        self.guildRoster  = GUILD_ROSTER_GAMEPAD     -- ZO_GamepadGuildRosterRow
        self.friendsList  = ZO_FRIENDS_LIST_GAMEPAD  -- ZO_GamepadFriendsListRow/ZO_GamepadFriendsListRow_Heron ... switch to IsHeronUI()
        self.ignoreList   = ZO_IGNORE_LIST_GAMEPAD   -- ZO_GamepadIgnoreListRow
        self.groupList    = GROUP_LIST_GAMEPAD       -- ZO_GroupListRow_Gamepad
        self:PostHook(self.groupList,   "SetupRow",  function(rowControl, data) self:Rewrite(rowControl, data) end)
    else
        self.guildRoster  = GUILD_ROSTER_KEYBOARD    -- ZO_KeyboardGuildRosterRow
        self.friendsList  = FRIENDS_LIST             -- ZO_FriendsListRow/ZO_FriendsListRow_Heron ... switch to IsHeronUI()
        self.ignoreList   = IGNORE_LIST              -- ZO_IgnoreListRow
        self.groupList    = GROUP_LIST               -- ZO_GroupListRow
        self:PostHook(self.groupList,   "SetupGroupEntry",  function(rowControl, data) self:Rewrite(rowControl, data) end)
    end
    self:PostHook(self.guildRoster, "SetupRow",         function(rowControl, data) self:Rewrite(rowControl, data) end)
    self:PostHook(self.friendsList, "SetupRow",         function(rowControl, data) self:Rewrite(rowControl, data) end)
    self:PostHook(self.ignoreList,  "SetupIgnoreEntry", function(rowControl, data) self:Rewrite(rowControl, data) end)


    pChat.ChangeChatFont = function(change)
        self:Debug("[pChat_ChangeChatFont]", self.checkColor)

        self:Debug("　　pChat.db.fonts=" .. tostring(pChat.db.fonts), self.checkColor)
        local fontSize = GetChatFontSize()
        local fontPath = self.newFonts[pChat.db.fonts] or LibMediaProvider:Fetch("font", pChat.db.fonts)
        self:Debug("　　fontSize=" .. tostring(fontSize))
        self:Debug("　　fontPath=" .. tostring(fontPath))
        if fontPath == nil then
            return
        end


        -- Entry Box
        ZoFontEditChat:SetFont(fontPath .. "|".. fontSize .. "|shadow")

        -- Chat window
        ZoFontChat:SetFont(fontPath .. "|" .. fontSize .. "|soft-shadow-thin")
    end


    if LUIE then -- LUIE:LuiExtended
        self:PostHook(LUIE.UnitFrames, "CustomFramesApplyLayoutGroup", function() self:Debug("Group") self:LuiExtended_SetNickname(4) end)
        self:PostHook(LUIE.UnitFrames, "CustomFramesApplyLayoutRaid",  function() self:Debug("Raid")  self:LuiExtended_SetNickname(24) end)
        self:PostHook(LUIE.UnitFrames, "CustomFramesApplyFont",        function() self:Debug("Font")  self:LuiExtended_SetNickname(24) end)

        self:LuiExtended_SetSaveValues()
        table.insert(self.fontControlNames, LUIE.name .. "UnitFramesOptions")
        table.insert(self.fontControlNames, LUIE.name .. "CombatInfoOptions")
        table.insert(self.fontControlNames, LUIE.name .. "BuffsAndDebuffsOptions")

        ZO_PreHook(LUIE.UnitFrames,    "CustomFramesApplyFont",        function()
            self:Debug("[LuiExtended_CustomFramesApplyFont]", self.checkColor)
            local fontName = LUIE.UnitFrames.SV.CustomFontFace
            local fontPath = LUIE.Fonts[fontName]
            self:Debug("　　" .. tostring(fontName) .. "=" .. tostring(fontPath), self.checkColor)
        end)
    end


    if TI then -- TI:ThurisazGuildInfo
        self:Hook_ThurisazGuildInfo()
    end


    ZO_PreHook(LAMCreateControl, "dropdown", function(parent, dropdownData) self:SetFonts(parent, dropdownData) end)


    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, function(...) self:UpdateNickname(...) end)




end




function pChat_jpNicknamePatch:pChat_SetSaveValues(choices)
    self:Debug("　　[pChat_SetSaveValues]")

    local saveName
    local saveObjectList = {
        {"pChat.db", pChat.db, "fonts", self.halfFont},
    }
    local keyName
    local fontame
    local value
    for i = 1, #saveObjectList do
        saveName   = saveObjectList[i][1]
        saveObject = saveObjectList[i][2]
        keyName    = saveObjectList[i][3]
        fontame    = saveObjectList[i][4]
        value = saveObject[keyName]
        self:Debug(zo_strformat("　　　　　　<<1>>.<<2>>=<<3>>", saveName, keyName, tostring(value)))
        if not(value and self:Equal(value, choices)) then
            saveObject[keyName] = fontame
            self:Debug("　　　　>" .. tostring(saveObject[keyName]))
        end
    end

end




function pChat_jpNicknamePatch:Rewrite(rowControl, data)

    if GUILD_ROSTER_MANAGER == nil  then
        return
    end

    local control
    local controlTxt
    local userId
    local nickname
    if data and data.dataEntry then
        control = data.dataEntry.control:GetNamedChild("DisplayName")
        if control then
            userId = control:GetText():gsub(".*@", "@")
        elseif rowControl == self.groupList then
            if GROUP_LIST_MANAGER.masterList and data.index then
                control = data.dataEntry.control:GetNamedChild("CharacterName")
                userId = GROUP_LIST_MANAGER.masterList[data.index].displayName
            else
                return
            end
        end

        controlTxt = control:GetText()
        if control and userId and controlTxt and (not controlTxt:match("[(]"))  then
            nickname = self.nicknames[userId]
            if nickname then
                controlTxt = controlTxt .. "(" .. nickname .. ")"
                control:SetText(controlTxt)
                --d("　　" .. tostring(control:GetName()) .. " " .. tostring(userId) .. " > " .. tostring(userIdTxt))
            end
        end
    end

end




function pChat_jpNicknamePatch:SetFonts(parent, dropdownData)

    local control = parent
    while control and control:GetParent() do
        if control:GetParent():GetName() == "LAMAddonSettingsWindowPanelContainer" then
            break
        end
        control = control:GetParent()
    end

    local controlName = control:GetName()
    if not self:Contains(controlName, self.fontControlNames) then
        --self:Debug("> return SetFonts() :" .. tostring(controlName))
        return
    end


    local choices = dropdownData.choices
    if not self:Equal(self.defFont, choices) then
        return
    end
    self:RemoveWithValue(self.fontControlNames, controlName)
    self:Debug("[SetFonts] " .. tostring(controlName))


    local start = 1
    local font
    local isContains = true
    while isContains do
        isContains = false
        for i = start, #choices do
            font = choices[i]
            if self:Equal(font, self.excludeFonts) then
                table.remove(choices, i)
                start = i
                isContains = true
                break
            end
        end
    end
    table.sort(choices)
    for i = 1, #dropdownData.choices do
        self:Debug("　　　　choices[" .. i .. "]="  .. tostring(choices[i]))
    end

    if controlName == "pChatOptions" then
        self:pChat_SetSaveValues(choices)
    end

end




function pChat_jpNicknamePatch:UpdateNickname(eventCode, guildId, userId, oldStatus, newStatus)

    if newStatus == PLAYER_STATUS_OFFLINE then
        return
    end
    if guildId == nil then
        return
    end
    if self.savedVariables.setting == nil then
        return
    end
    if self.savedVariables.setting[guildId] == nil then
        return
    end
    if not (self.savedVariables.setting[guildId].useNicknames) then
        return
    end
    if self.savedVariables.nameFormat == 1 and (not self:IsDebug()) and self.nicknames[userId] then -- @UserID
        return
    end

    local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, userId)
    local userId, nickname, nicknameOrigin = self:CreateNickname(guildId, memberIndex)
    pChat.pChatData.nicknames[userId] = nickname
    self.nicknames[userId] = nicknameOrigin
end




EVENT_MANAGER:RegisterForEvent(pChat_jpNicknamePatch.name, EVENT_ADD_ON_LOADED, function(...) pChat_jpNicknamePatch:OnAddOnLoaded(...) end)

