-- Includes{{{
CPS = {}
local CPS = CPS
--}}}

-- Globals{{{
-- The names for config types
CPS.SIZE_X = nil
CPS.SIZE_Y = 1000
CPS.CURRENT = "Current"
CPS.currentSlotIsZero = false
CPS.ComboMap = {}

CPS.USER_PROF = "Users"
CPS.ACCOUNT_PROF = "UsersAccount"
--CPS.PREMADE_PROF = "UsersPremade"

CPS.LOG_ERROR_TYPE = "Error"

CPS.currentSlot = nil
CPS.currentItemIndex = 1
CPS.currentType = CPS.CURRENT
CPS.currentlyShowingSlot = false
CPS.currentSetName = "Current"
CPS.currentSpent = nil
CPS.currentUnspent = nil
CPS.currentlyMetic = nil
CPS.currentZoneId = -1

CPS.layerIndex = nil
CPS.categoryIndex = nil
CPS.actionIndex = nil
CPS.oldLiveSlot = {
    [1] = {
        [1]   = 0, [2]   = 0, [3]   = 0, [4]   = 0, [5]   = 0, [6]   = 0,
        [8]   = 0, [9]   = 0, [10]  = 0, [11]  = 0, [12]  = 0, [13]  = 0,
        [14]  = 0, [15]  = 0, [16]  = 0, [17]  = 0, [18]  = 0, [20]  = 0,
        [21]  = 0, [22]  = 0, [23]  = 0, [24]  = 0, [25]  = 0, [26]  = 0,
        [27]  = 0, [28]  = 0, [29]  = 0, [30]  = 0, [31]  = 0, [32]  = 0,
        [33]  = 0, [34]  = 0, [35]  = 0, [37]  = 0, [38]  = 0, [39]  = 0,
        [40]  = 0, [42]  = 0, [43]  = 0, [44]  = 0, [45]  = 0, [46]  = 0,
        [47]  = 0, [48]  = 0, [49]  = 0, [50]  = 0, [51]  = 0, [52]  = 0,
        [53]  = 0, [54]  = 0, [55]  = 0, [56]  = 0, [57]  = 0, [58]  = 0,
        [59]  = 0, [60]  = 0, [61]  = 0, [62]  = 0, [63]  = 0, [64]  = 0,
        [65]  = 0, [66]  = 0, [67]  = 0, [68]  = 0, [69]  = 0, [70]  = 0,
        [71]  = 0, [72]  = 0, [74]  = 0, [75]  = 0, [76]  = 0, [77]  = 0,
        [78]  = 0, [79]  = 0, [80]  = 0, [81]  = 0, [82]  = 0, [83]  = 0,
        [84]  = 0, [85]  = 0, [86]  = 0, [87]  = 0, [88]  = 0, [89]  = 0,
        [90]  = 0, [91]  = 0, [92]  = 0, [99]  = 0, [108] = 0, [113] = 0,
        [128] = 0, [133] = 0, [134] = 0, [136] = 0, [159] = 0, [160] = 0,
        [161] = 0, [162] = 0, [163] = 0
    },
    [2] = {
        [1]   = 0, [2]   = 0, [3]   = 0, [4]   = 0, [5]   = 0, [6]   = 0,
        [7]   = 0, [8]   = 0, [9]   = 0, [10]  = 0, [11]  = 0, [12]  = 0
    }
}
CPS.liveSlot = {
    [1] = {
        [1]   = 0, [2]   = 0, [3]   = 0, [4]   = 0, [5]   = 0, [6]   = 0,
        [8]   = 0, [9]   = 0, [10]  = 0, [11]  = 0, [12]  = 0, [13]  = 0,
        [14]  = 0, [15]  = 0, [16]  = 0, [17]  = 0, [18]  = 0, [20]  = 0,
        [21]  = 0, [22]  = 0, [23]  = 0, [24]  = 0, [25]  = 0, [26]  = 0,
        [27]  = 0, [28]  = 0, [29]  = 0, [30]  = 0, [31]  = 0, [32]  = 0,
        [33]  = 0, [34]  = 0, [35]  = 0, [37]  = 0, [38]  = 0, [39]  = 0,
        [40]  = 0, [42]  = 0, [43]  = 0, [44]  = 0, [45]  = 0, [46]  = 0,
        [47]  = 0, [48]  = 0, [49]  = 0, [50]  = 0, [51]  = 0, [52]  = 0,
        [53]  = 0, [54]  = 0, [55]  = 0, [56]  = 0, [57]  = 0, [58]  = 0,
        [59]  = 0, [60]  = 0, [61]  = 0, [62]  = 0, [63]  = 0, [64]  = 0,
        [65]  = 0, [66]  = 0, [67]  = 0, [68]  = 0, [69]  = 0, [70]  = 0,
        [71]  = 0, [72]  = 0, [74]  = 0, [75]  = 0, [76]  = 0, [77]  = 0,
        [78]  = 0, [79]  = 0, [80]  = 0, [81]  = 0, [82]  = 0, [83]  = 0,
        [84]  = 0, [85]  = 0, [86]  = 0, [87]  = 0, [88]  = 0, [89]  = 0,
        [90]  = 0, [91]  = 0, [92]  = 0, [99]  = 0, [108] = 0, [113] = 0,
        [128] = 0, [133] = 0, [134] = 0, [136] = 0, [159] = 0, [160] = 0,
        [161] = 0, [162] = 0, [163] = 0
    },
    [2] = {
        [1]   = 0, [2]   = 0, [3]   = 0, [4]   = 0, [5]   = 0, [6]   = 0,
        [7]   = 0, [8]   = 0, [9]   = 0, [10]  = 0, [11]  = 0, [12]  = 0
    }
}
CPS.changed = false
CPS.REFIRE = "CPS_Refire"
CPS.AUTOMETIC_RESLOT = "CPS_Autometic_Reslot"
CPS.TabFocusSlave = {}
CPS.TabReverseFocusSlave = {}
CPS.SpaceFocusSlave = {}
CPS.SpaceReverseFocusSlave = {}
-- Need to put somewhere else
-- CPS.EDIT_HELP = "Key: Up Arrow: Increase by Jump Point, Down Arrow: Decrease By Jump Point\nTab: Focus next text box, Shift-Tab: Focus Previous Text box\nSpace: Focus Column Right, Shift-Space: Focus Column Left\n\n"
CPS.EDIT_HELP = ""
CPS.ignoreTextChangeUpdates = true
CPS.ignoreLoseFocusUpdates = true
CPS.configTypeCombobox = nil
CPS.slotChoiceComboBox = nil
CPS.greencombo = nil
CPS.redcombo = nil
CPS.bluecombo = nil
CPS.dropdownGreen = nil
CPS.dropdownRed = nil
CPS.dropdownBlue = nil
CPS.ReorderMap = {
    [CPS.USER_PROF] = {},
    [CPS.ACCOUNT_PROF] = {}
}
CPS.METIC_STAR_ID = 83
CPS.currentFocus = nil
CPS.loaded = false

CPS.ELLIDE = { ["en"] = 30, ["de"] = 30, ["ru"] = 30, ["fr"] = 30, }
CPS.WIDTHS = { ["en"] = 1600, ["de"] = 1600, ["ru"] = 1600, ["fr"] = 1600, }

CPS.bindingStartingIndex = -1
CPS.BINDING_NAMES = {
    "SI_BINDING_NAME_CP_SLOT_BIND_USER1",
    "SI_BINDING_NAME_CP_SLOT_BIND_USER2",
    "SI_BINDING_NAME_CP_SLOT_BIND_USER3",
    "SI_BINDING_NAME_CP_SLOT_BIND_USER4",
    "SI_BINDING_NAME_CP_SLOT_BIND_USER5",
    "SI_BINDING_NAME_CP_SLOT_BIND_USER6",
    "SI_BINDING_NAME_CP_SLOT_BIND_USER7",
    "SI_BINDING_NAME_CP_SLOT_BIND_USER8",
    "SI_BINDING_NAME_CP_SLOT_BIND_USER_ACCOUNT1",
    "SI_BINDING_NAME_CP_SLOT_BIND_USER_ACCOUNT2",
    "SI_BINDING_NAME_CP_SLOT_BIND_USER_ACCOUNT3",
    "SI_BINDING_NAME_CP_SLOT_BIND_USER_ACCOUNT4",
    "SI_BINDING_NAME_CP_SLOT_BIND_USER_ACCOUNT5",
    "SI_BINDING_NAME_CP_SLOT_BIND_USER_ACCOUNT6",
    "SI_BINDING_NAME_CP_SLOT_BIND_USER_ACCOUNT7",
    "SI_BINDING_NAME_CP_SLOT_BIND_USER_ACCOUNT8",
    --"SI_BINDING_NAME_CP_SLOT_BIND_USER_PREMADE1",
    --"SI_BINDING_NAME_CP_SLOT_BIND_USER_PREMADE2",
    --"SI_BINDING_NAME_CP_SLOT_BIND_USER_PREMADE3",
    --"SI_BINDING_NAME_CP_SLOT_BIND_USER_PREMADE4",
    --"SI_BINDING_NAME_CP_SLOT_BIND_USER_PREMADE5",
    --"SI_BINDING_NAME_CP_SLOT_BIND_USER_PREMADE6",
    --"SI_BINDING_NAME_CP_SLOT_BIND_USER_PREMADE7",
    --"SI_BINDING_NAME_CP_SLOT_BIND_USER_PREMADE8",
}

-- h5. ChampionDisciplineType +1, zero-indexed but lua is one-indexed
CPS.WARFARE = CHAMPION_DISCIPLINE_TYPE_COMBAT + 1
CPS.FITNESS = CHAMPION_DISCIPLINE_TYPE_CONDITIONING + 1
CPS.CRAFT   = CHAMPION_DISCIPLINE_TYPE_WORLD + 1

-- Because why not have a different index!? (hotbar/position on screen I guess?)
CPS.WARFARE_INDEX = 2
CPS.FITNESS_INDEX = 3
CPS.CRAFT_INDEX   = 1

-- CPS.Colors
CPS.Colors = {}
CPS.ColorsDisabled = {}
CPS.ColorsText = {}

CPS.COLOR_BLUE = "53C8E9"
CPS.COLOR_GREEN = "D6EB63"
CPS.COLOR_RED = "EF8142"

CPS.COLOR_DISABLED_BLUE = "1C434F"
CPS.COLOR_DISABLED_GREEN = "5C652B"
CPS.COLOR_DISABLED_RED = "723E1F"

CPS.COLOR_TEXT_BLUE = "ADDCE9"
CPS.COLOR_TEXT_GREEN = "E2EBAF"
CPS.COLOR_TEXT_RED = "EFCAB5"

CPS.COLOR_DISABLED_WHITE = "696969"
CPS.COLOR_WHITE = "ffffff"

-- CPS Controls we will loop over later
CPS.DisControls = {}
CPS.StarControls = {}

-- We need these for special loop cases below
CPS.STAR_INDEX = 1
CPS.SLOT_INDEX = 2

CPS.NEW = "+  - New - +"

CPS.name = "ChampionPointsSlots"
CPS.displayName = "|c53C8E9Champion|r|cD6EB63 Points|r|cEF8142 Slots|r"
CPS.miniDisplayName = "|c53C8E9C|r|cD6EB63P |r|cEF8142Slots|r"
CPS.miniDisplayNameRaw = "CP Slots"
CPS.version = 3.5
CPS.cachedPaths = {}

CPS.Defaults = {}
CPS.AccountDefaults = {}
CPS.AccountDefaults.autoMetic = true
CPS.AccountDefaults.UsersAccount = {}
CPS.AccountDefaults.MapIndexToAccountName  = {}

--CPS.AccountDefaults.UsersPremade = {}
--CPS.AccountDefaults.MapIndexToPremadeName  = {}
--CPS.AccountDefaults.premadeCount = 0

CPS.Defaults.currentProfileId = nil
CPS.Defaults.currentSet = {
    ['type'] = '',
    ['index'] = -1,
    ['name'] = ''
}
CPS.Defaults.currentSetInfo = {}

-- Our ui stuff
CPS.AccountDefaults.ui = {
    ["offsetX"]  = 0,
    ["offsetY"]  = 0,
    ["point"]    = CENTER,
    ["relPoint"] = CENTER,
    ["scale"]    = 100,
    ["autoShow"] = true,
    ["buttonX"]  = 0,
    ["buttonY"]  = 0,
    ["buttonRel"]  = TOPLEFT,
    ["buttonPoint"]  = TOPLEFT,
    ["timerX"]  = 50,
    ["timerY"]  = 0,
    ["timerRel"]  = TOPLEFT,
    ["timerPoint"]  = TOPLEFT,
    ["showIcon"] = true,
    ["showTimer"] = true,
    ["showID"]   = false,
    ["log"]      = true,
}

CPS.Defaults.Users = {}
CPS.Defaults.userCount = 0
CPS.Defaults.MapIndexToName = { }

CPS.configTypes = {
    [1] = CPS.CURRENT,
    [2] = CPS.USER_PROF,
    -- [3] = CPS.PREMADE_PROF,
    [6] = CPS.ACCOUNT_PROF,
}

-- end global }}}

-- Trees{{{
-- What is our current CP lookin like
CPS.Defaults.Current = {}
CPS.Defaults.Current =  {
    [1] = {
        [1] = { },

        [2] = {
            [1]   = 0, [2]   = 0, [3]   = 0, [4]   = 0, [5]   = 0, [6]   = 0,
            [7]   = 0, [8]   = 0, [9]   = 0, [10]  = 0, [11]  = 0, [12]  = 0
        }
    }
}
CPS.laters = {}

CPS.Defaults.MeticTemp = nil

-- end trees }}}

-- Helpers{{{
function CPS:isCurrentSet(t, name, index)
    return CPS.sv.currentSet['type'] == t and CPS.sv.currentSet['name'] == name and CPS.sv.currentSet['index'] == index
end
function CPS:getJumpPointsString(starId)
    local rtn = ''
    local hasJump = DoesChampionSkillHaveJumpPoints(starId)
    if hasJump then
        for i, x in ipairs({GetChampionSkillJumpPoints(starId)}) do
            rtn = rtn .. tostring(x) .. ', '
        end
    end
    rtn = rtn:sub(1, #rtn - 2)
    return rtn
end

function CPS:getStarName(starId)
    local name = GetChampionSkillName(starId)

        name = tostring(starId) .. ' ' .. name

    return name
end

-- TODO WouldChampionSkillNodeBeUnlocked(*integer* _championSkillId_, *integer*
function CPS:getMinimumNeeded(starId)
    local hasJump = DoesChampionSkillHaveJumpPoints(starId)

    if hasJump then
        local jumps = {GetChampionSkillJumpPoints(starId)}
        -- d ( self:getStarName(starId) .. ' ' .. #jumps )
        return jumps[2]
    else
        local max = GetChampionSkillMaxPoints(starId)
        return 1
    end
end

function CPS:isStarEnabledLoop(starId)
    if self.maxRecurse > 20 then -- safety first..
        return false
    end
    if IsChampionSkillRootNode(starId) then
        return true
    end

    self.maxRecurse = self.maxRecurse + 1
    self.checkedStars[starId] = self:getStarName(starId)

    local tbl = {GetChampionSkillLinkIds(starId)}

    for i,x in ipairs(tbl) do
        if #{GetChampionSkillLinkIds(x)} == 1 and not IsChampionSkillRootNode(x) then
        else
            if self.checkedStars[x] == nil then
                if tonumber(self.currentSlot[self.STAR_INDEX][x]) >= self:getMinimumNeeded(x) and self:isStarEnabledLoop(x) then
                    return true
                end
            end
        end
    end

    return false
end

function CPS:isStarEnabled(starId)
    self.checkedStars = {}
    self.maxRecurse = 1

    local b = CPS:isStarEnabledLoop(starId)

    return b
end

function CPS:getLinkPathLoop(dis, starId, links, c)
    if self.maxRecurse > 100 then -- safety first..
        return nil
    end

    if IsChampionSkillRootNode(starId) then
        return ''
    end

    self.maxRecurse = self.maxRecurse + 1
    self.checkedStars[starId] = self:getStarName(starId)

    local tbl = {GetChampionSkillLinkIds(starId)}

    for i,x in ipairs(tbl) do
        if #{GetChampionSkillLinkIds(x)} == 1 and not IsChampionSkillRootNode(x) then
        else
            if x ~= self.origStarId and self.checkedStars[x] == nil then
                local name = self:getColoredText(self.Colors[dis], self:getText(CPS:getStarName(x)))
                name = '|t16:16:esoui/art/champion/champion_icon.dds|t' .. name
                if IsChampionSkillRootNode(x) then
                    if self.paths[x] == nil or self.pathLength[x] > c then
                        self.pathLength[x] = c
                        self.paths[x] = links .. name
                    end
                else
                    self:getLinkPathLoop(dis, x, links .. name .. ">", c + 1)
                end
            end
        end
    end

    return nil
end

function CPS:getLinkPath(dis, starId)
    if self.cachedPaths[starId] then
        return self.cachedPaths[starId]
    else
        self.checkedStars = {}
        self.maxRecurse = 0
        self.origStarId = starId
        self.paths = {}
        self.pathLength = {}

        local stars = {}
        local hasRoot = false
        local tbl = {GetChampionSkillLinkIds(starId)}
        for i,x in ipairs(tbl) do
            if IsChampionSkillRootNode(x) then
                local name = self:getColoredText(self.Colors[dis], self:getText(CPS:getStarName(x)))
                name = '|t20:20:esoui/art/champion/champion_icon.dds|t' .. name
                self.paths[x] = name
                hasRoot = true
            elseif not hasRoot then
                stars[i] = x
            end
        end

        if hasRoot then
            return self.paths
        else
            for i, x in ipairs(stars) do
                local name = self:getColoredText(self.Colors[dis], self:getText(CPS:getStarName(x)))
                name = '|t16:16:esoui/art/champion/champion_icon.dds|t' .. name
                self:getLinkPathLoop(dis, x, name .. ">", 0)
                self.checkedStars= {}
                self.maxRecurse = 0
            end
        end

        self.cachedPaths[starId] = self.paths
        return self.paths
    end
end

function CPS:getEntryName(index, name)
    return string.format("%d : %s", index, name)
end

function CPS:getColoredText(color, text)
    return "|c" .. color .. text .. '|r'
end

-- This makes me sad..
function CPS:getDisIndexFromDis(dis)
    if dis == self.WARFARE then
        return self.WARFARE_INDEX
    elseif dis == self.FITNESS then
        return self.FITNESS_INDEX
    else
        return self.CRAFT_INDEX
    end
end

-- This makes me very sad
function CPS:getDisFromIndex(disId)
    if disId == self.WARFARE_INDEX then
        return self.WARFARE
    elseif dis == self.FITNESS_INDEX then
        return self.FITNESS
    else
        return self.CRAFT
    end
end

-- TODO make a UI element
function CPS:getFullDescription(name, dis, starId, pointsSpent)
    local tbl = {GetChampionSkillLinkIds(starId)}
    local desc = ''
    if #tbl > 0 then
        desc = desc .. '' .. self:getLinkDescription(dis, starId)
    end
    desc = desc .. '' .. self:getDescription(starId, pointsSpent)

    if DoesChampionSkillHaveJumpPoints(starId) then
        desc = 'Jump Points: '.. CPS:getJumpPointsString(starId) ..'\n'.. desc
    else
        desc = 'Max Points: '.. tostring(GetChampionSkillMaxPoints(starId)) ..'\n'.. desc
    end

    desc =  self:getColoredText(self.Colors[dis], self:getStarName(starId)) .. '     ' .. desc

    if #tbl == 1 then
        desc = 'Leaf Node\n' .. desc
    end

    if IsChampionSkillRootNode(starId) then
        if #tbl == 0 then
            desc = 'Linkless Root Node\n' .. desc
        else
            desc = 'Root Node\n' .. desc
        end
    end

    return desc
end

function CPS:getDescription(starId, pointsSpent)
    local bonus = GetChampionSkillCurrentBonusText(starId, pointsSpent)

    if bonus ~= "" then
        bonus = "Current Bonus: " .. bonus
        return GetChampionSkillDescription(starId, pointsSpent) .. "\n" .. self:getColoredText('33cc33', bonus)
    else
        return GetChampionSkillDescription(starId, pointsSpent)
    end
end

function CPS:getLinkDescription(dis, starId)
    local rtnString = ''
    local leafString = 'Leaves: '
    local hasLeaves = false
    local isNotRoot = true

    if IsChampionSkillRootNode(starId) then
        isNotRoot = false
    end

    local tbl = {GetChampionSkillLinkIds(starId)}
    -- if #tbl > 0 then
        -- rtnString = rtnString .. "Links: "
    -- end

    for i, x in ipairs(tbl) do
        if #{GetChampionSkillLinkIds(x)} == 1 then
            hasLeaves = true
            local name = self:getColoredText(self.Colors[dis], self:getText(CPS:getStarName(x)))
            leafString = leafString .. '|t20:20:esoui/art/champion/champion_icon.dds|t' .. name  .. ' '
        else
            -- local name = self:getColoredText(self.Colors[dis], self:getText(CPS:getStarName(x)))
            -- rtnString = rtnString .. '|t20:20:esoui/art/champion/champion_icon.dds|t' .. name  .. ' '
        end
    end

    if hasLeaves then
        rtnString = leafString
    end

    if isNotRoot then
        local paths = self:getLinkPath(dis, starId)
        local pathString = ''
        local c = 1

        for i, x in pairs(paths) do
            if i ~= nil and x ~= nil then
                pathString = pathString .. 'Path ' .. tostring(c) .. ': '.. x .. "\n"
                c = c + 1
            end
        end

        rtnString = pathString
    end

    return rtnString
end

function CPS:getDisabledDescription(dis, starId)
    local rtnString = 'You must unlock one of the following:\n'

    local tbl = {GetChampionSkillLinkIds(starId)}
    for i, x in ipairs(tbl) do
        local name = self:getColoredText(self.Colors[dis], self:getText(CPS:getStarName(x)))
        rtnString = rtnString .. name .. ' with at least ' .. self:getMinimumNeeded(starId)..  ' points\n'
    end

    return rtnString
end

function CPS:fixBindingText()
    local MAX = 8
    local c = 0
    for i, tbl in pairs(CPS.sv.Users) do
        if i > MAX then
            break
        end
        local entryName = CPS:getEntryName(i, CPS.sv.MapIndexToName[i])
        local comboName = "Users : " .. entryName
        EsoStrings[CPS.bindingStartingIndex + i - 1] = comboName
        c = i
    end

    for i=c + 1, 8 do
        EsoStrings[CPS.bindingStartingIndex + i - 1] = "NO USER SLOT : " .. tostring(i)
    end

    local offset = 8
    c = 1
    for i, tbl in pairs(CPS.svAccount.UsersAccount) do
        if i > MAX then
            break
        end
        local entryName = CPS:getEntryName(i, CPS.svAccount.MapIndexToAccountName[i])
        local comboName = "UsrAcc : " .. entryName
        EsoStrings[CPS.bindingStartingIndex + i - 1 + offset] = comboName
        c = i
    end

    for i=c + offset + 1, 16 do
        EsoStrings[CPS.bindingStartingIndex + i - 1] = "NO ACCOUNT SLOT : " .. tostring(i - offset)
    end

    -- offset = 16
    -- c = 1
    -- for i, tbl in pairs(CPS.svAccount.UsersPremade) do
        -- if i > MAX then
            -- break
        -- end
        -- local entryName = CPS:getEntryName(i, CPS.svAccount.MapIndexToPremadeName[i])
        -- local comboName = "UsersPremade : " .. entryName
        -- EsoStrings[CPS.bindingStartingIndex + i - 1 + offset] = comboName
        -- c = i
    -- end
    -- for i=c + offset, #CPS.BINDING_NAMES do
        -- EsoStrings[CPS.bindingStartingIndex + i - 1] = "NO PREMADE SLOT : " .. tostring(i - offset)
    -- end
end

function CPS:getFailedReason(avail)
    local st = GetString("SI_CHAMPIONPURCHASERESULT", avail)
    if st == nil then
        st = avail
    end
    return tostring(st)
end

function CPS:Log(message, messageType, force)
    if message == nil then return end
    if (force == nil) or (force ~= nil and not force) then
        if not CPS.svAccount.ui.log then return end
    end

    local messageStart = "|t20:20:esoui/art/buttons/info_over.dds|t : "
    local messageColor = "|caaffaa"
    local messageEnd = "|r."

    if messageType == nil then
    elseif messageType == CPS.LOG_ERROR_TYPE then
        messageColor = "|cffaaaa"
    end

    d ( messageStart .. messageColor .. message .. messageEnd )
end

-- certain languages such as german have ^fm
function CPS:getText(text)
    text = string.gsub( text , "%^.*", "")
    local prev = string.len(text)
    local l = GetCVar("language.2")
    text = string.sub(text, 0, CPS.ELLIDE[l])
    if prev > string.len(text) then
        text = text .. "."
    end
    return text
end

function CPS:fireMessage(text, messageControl, time)
    messageControl:GetParent():SetHidden(false)
    messageControl:SetHidden(false)
    messageControl:SetText(text)

    if time >= 0 then
        EVENT_MANAGER:RegisterForUpdate(CPS.REFIRE, time, function ()
            EVENT_MANAGER:UnregisterForUpdate(CPS.REFIRE)
            messageControl:GetParent():SetHidden(true)
            messageControl:SetHidden(true)
        end)
    end
end

function CPS:getDisName(dis)
    if dis == self.CRAFT then
        return "Craft"
    elseif dis == self.WARFARE then
        return "Warfare"
    elseif dis == self.FITNESS then
        return "Fitness"
    else
        return "Error"
    end
end

function CPS:getDisciplineSpent()
    if self.currentType == self.CURRENT then
        return GetNumSpentChampionPoints(dis)
    else

    end
end

function CPS:getDisciplineUnspent()
    if self.currentType == self.CURRENT then
        return GetNumUnspentChampionPoints(dis)
    else

    end
end

function CPS:padText(text, pad, color)
    local loops = pad - string.len(text)
    local padText = ""
    while loops > 0 do
        padText = "0" .. padText
        loops = loops - 1
    end
    text = "|c010101" ..  padText .. "|r|c" .. color .. text .. "|r"
    return text
end

function CPS:getAttribute(dis)
    if dis == CPS.THE_TOWER or dis == CPS.THE_LOVER or dis == CPS.THE_SHADOW then
        return CPS.THE_THIEF
    elseif dis == CPS.THE_RITUAL or dis == CPS.THE_APPRENTICE or dis == CPS.THE_ATRONACH then
        return CPS.THE_MAGE
    else
        return CPS.THE_WARRIOR
    end
end

-- put index before one
function CPS:transferIndex(movingIndex, index)
    d ( tostring(movingIndex) .. ' to index -> ' .. tostring(index) )

    if self.currentType ~= self.CURRENT then

        if self:isCurrentSet(self.currentType, self.currentName, movingIndex) then
            CPS.sv.currentSet['index'] = index
        end

        local arr = CPS.sv.Users
        local map = CPS.sv.MapIndexToName

        if CPS.currentType == CPS.ACCOUNT_PROF then
            arr = CPS.svAccount.UsersAccount
            map = CPS.svAccount.MapIndexToAccountName
        -- elseif CPS.currentType == CPS.PREMADE_PROF then
            -- arr = CPS.svAccount.UsersPremade
            -- map = CPS.svAccount.MapIndexToPremadeName
        end

        local moveSlot = table.remove(arr, movingIndex)
        local moveName = table.remove(map, movingIndex)

        table.insert(arr, index, moveSlot)
        table.insert(map, index, moveName)

        return map[index]
    end

    return nil
end

-- copy slot1 into slot2
function CPS:transferCP(slot2, slot1, green, red, blue)
    if slot2 == nil then return end
    if slot1 == nil then return end

    for dis = 1, GetNumChampionDisciplines() do
        if  (green == nil or dis ~= self.CRAFT) and (red   == nil or dis ~= self.FITNESS) and (blue  == nil or dis ~= self.WARFARE) then
            local disIndex = self:getDisIndexFromDis(dis)
            for star = 1, GetNumChampionDisciplineSkills(disIndex) do
                local starId = GetChampionSkillId(disIndex, star)
                slot2[self.STAR_INDEX][starId] = slot1[self.STAR_INDEX][starId]
            end
        end
    end

    -- slots
    local start, nd = GetAssignableChampionBarStartAndEndSlots()
    for i=start, nd do
        local starId = GetSlotBoundId (i, HOTBAR_CATEGORY_CHAMPION)
        local dis = GetRequiredChampionDisciplineIdForSlot (i, HOTBAR_CATEGORY_CHAMPION)
        if  (green == nil or dis ~= self.CRAFT) and (red   == nil or dis ~= self.FITNESS) and (blue  == nil or dis ~= self.WARFARE) then
            slot2[self.SLOT_INDEX][i] = slot1[self.SLOT_INDEX][i]
        end
    end
end

function CPS:getMaximumCP(num, curValue, dis, starId)
    local max = GetChampionSkillMaxPoints(starId)
    if num > max then
        num = max
    end

    if num > curValue then
        local unspent = self.currentUnspent[dis]
        local spent = self.currentSpent[dis]

        num = math.min(num, unspent + curValue)
    end

    return num
end

function CPS:setTooltip(control, text)
    control.data = { tooltipText = text}

    control:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
    control:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
end

function CPS:editCheckBoxToggle()
    local hidden = not ZO_CheckButton_IsChecked(CPS_WindowEditCheck)

    for dis = 1, GetNumChampionDisciplines() do
        local disIndex = self:getDisIndexFromDis(dis)
        for star = 1, GetNumChampionDisciplineSkills(disIndex) do
            local starId = GetChampionSkillId(disIndex, star)
            local enabled = self:isStarEnabled(starId)
            local skillType = GetChampionSkillType(starId)
            local slottable = CanChampionSkillTypeBeSlotted(skillType)
            if enabled then
                self.StarControls[starId].Edit:SetHidden(hidden)
                self.StarControls[starId].Amt:SetHidden(not hidden)
                if slottable then
                    self.StarControls[starId].Check:SetHidden(not hidden)
                end
            else
                self.StarControls[starId].Edit:SetHidden(true)
                self.StarControls[starId].Amt:SetHidden(false)
                if slottable then
                    self.StarControls[starId].Check:SetHidden(false)
                end
            end
        end
    end

    if self.currentType == self.CURRENT then
        -- d()
    else
        self.dropdownGreen:SetHidden(not hidden)
        self.dropdownRed:SetHidden(not hidden)
        self.dropdownBlue:SetHidden(not hidden)
    end
end

function CPS:isJumpPoint(dis, skill, num)
    local l = CPS.JUMPS_LENGTH[dis][skill]
    lower = -1
    higher = -1

    if l == 0 then
        return true
    else
        for i, x in ipairs(CPS.JUMPS[dis][skill]) do
            if num > x then
                lower = x
            end

            if num < x and higher == -1 then
                higher = x
            end

            if num == x then
                return true
            end
        end
    end
end

function CPS:createNewEntry()
    local arr = self.sv.Users
    local map = self.sv.MapIndexToName
    local count = 0
    local comboboxName = ""

    if CPS.currentType == CPS.ACCOUNT_PROF then
        arr = CPS.svAccount.UsersAccount
        map = CPS.svAccount.MapIndexToAccountName
        count = #CPS.svAccount.UsersAccount + 1
        comboboxName = "UsrAcc : "
    --elseif CPS.currentType == CPS.PREMADE_PROF then
        --arr = CPS.svAccount.UsersPremade
        --map = CPS.svAccount.MapIndexToPremadeName
        --CPS.svAccount.premadeCount = CPS.svAccount.premadeCount + 1
        --count = CPS.svAccount.premadeCount
        --comboboxName = "UsersPremade : "
    else
        count = #CPS.sv.Users + 1
        comboboxName = "Users : "
    end

    local itemName = "New"

    map[count] = itemName
    arr[count] = {
        [1] = {
            [1]   = 0, [2]   = 0, [3]   = 0, [4]   = 0, [5]   = 0, [6]   = 0,
            [8]   = 0, [9]   = 0, [10]  = 0, [11]  = 0, [12]  = 0, [13]  = 0,
            [14]  = 0, [15]  = 0, [16]  = 0, [17]  = 0, [18]  = 0, [20]  = 0,
            [21]  = 0, [22]  = 0, [23]  = 0, [24]  = 0, [25]  = 0, [26]  = 0,
            [27]  = 0, [28]  = 0, [29]  = 0, [30]  = 0, [31]  = 0, [32]  = 0,
            [33]  = 0, [34]  = 0, [35]  = 0, [37]  = 0, [38]  = 0, [39]  = 0,
            [40]  = 0, [42]  = 0, [43]  = 0, [44]  = 0, [45]  = 0, [46]  = 0,
            [47]  = 0, [48]  = 0, [49]  = 0, [50]  = 0, [51]  = 0, [52]  = 0,
            [53]  = 0, [54]  = 0, [55]  = 0, [56]  = 0, [57]  = 0, [58]  = 0,
            [59]  = 0, [60]  = 0, [61]  = 0, [62]  = 0, [63]  = 0, [64]  = 0,
            [65]  = 0, [66]  = 0, [67]  = 0, [68]  = 0, [69]  = 0, [70]  = 0,
            [71]  = 0, [72]  = 0, [74]  = 0, [75]  = 0, [76]  = 0, [77]  = 0,
            [78]  = 0, [79]  = 0, [80]  = 0, [81]  = 0, [82]  = 0, [83]  = 0,
            [84]  = 0, [85]  = 0, [86]  = 0, [87]  = 0, [88]  = 0, [89]  = 0,
            [90]  = 0, [91]  = 0, [92]  = 0, [99]  = 0, [108] = 0, [113] = 0,
            [128] = 0, [133] = 0, [134] = 0, [136] = 0, [159] = 0, [160] = 0,
            [161] = 0, [162] = 0, [163] = 0
        },
        [2] = {
            [1]   = 0, [2]   = 0, [3]   = 0, [4]   = 0, [5]   = 0, [6]   = 0,
            [7]   = 0, [8]   = 0, [9]   = 0, [10]  = 0, [11]  = 0, [12]  = 0
        }
    }

    local name = self:getEntryName(count, itemName)
    local itemEntry = self.slotChoiceComboBox:CreateItemEntry(name, self.SelectSlotCallback)

    self.slotChoiceComboBox:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
    self.slotChoiceComboBox:SetSelectedItem(name)

    self.currentItemIndex = count
    self.currentSlot = arr[count]

    CPS_WindowDeleteButton:SetText("|cff0033Delete " .. itemName)
    CPS_WindowCloneButton:SetText("|c3333ffClone " ..  itemName)
    self.currentSetName = itemName

    self.ComboMap[comboboxName .. name] = arr[count]
end

function CPS:getSpent(dis, skill)
    local num = GetNumPointsSpentOnChampionSkill(dis, skill)

    if num == nil then
        num = 0
    end

    return num
end

function CPS:needsRespec(slot)
    local respec = false

    for dis = 1, GetNumChampionDisciplines() do
        local disIndex = self:getDisIndexFromDis(dis)
        for star = 1, GetNumChampionDisciplineSkills(disIndex) do
            local starId = GetChampionSkillId(disIndex, star)
            local pointsSpent = slot[self.STAR_INDEX][starId]
            local currentSpent = GetNumPointsSpentOnChampionSkill(starId)
            if pointsSpent < currentSpent then
                respec = true
                break
            end
        end
    end

    return respec
end
-- End Helpers}}}

-- Insert new values that arent yet there
function CPS:pointsSpent(starId)
    local rtn = self.currentSlot[self.STAR_INDEX][starId]

    if rtn == nil then
        if not CPS.lol then
            CPS.lol = {}
        end
        CPS.lol[starId] = ( 'Points spent:' .. tostring(starId) .. ' : ' .. tostring(rtn))
        table.insert(self.currentSlot[self.STAR_INDEX], starId, 0)
        rtn = self.currentSlot[self.STAR_INDEX][starId]
    else
        -- If it's over the max make it the max ( because ZOS is more finnicky than Gwynevere)
        local max = GetChampionSkillMaxPoints(starId)

        if rtn > max then
            rtn = max
            self.currentSlot[self.STAR_INDEX][starId] = rtn
        end
    end

    return rtn
end

-- Main Functionals {{{
function CPS:reloadUIAndCache()
    local totals = {
        [self.CRAFT] = GetNumSpentChampionPoints(self.CRAFT) + GetNumUnspentChampionPoints(self.CRAFT),
        [self.WARFARE] = GetNumSpentChampionPoints(self.WARFARE) + GetNumUnspentChampionPoints(self.WARFARE),
        [self.FITNESS] = GetNumSpentChampionPoints(self.FITNESS) + GetNumUnspentChampionPoints(self.FITNESS)
    }

    self.currentSpent = {}
    self.currentUnspent = {}

    -- dis
    for dis = 1, GetNumChampionDisciplines() do
        local spent = 0
        local unspent = 0
        local name = self:getText(GetChampionDisciplineName(dis))
        local cptexture = "|t20:20:esoui/art/champion/champion_icon.dds|t"
        local checktexture = "|t20:20:esoui/art/miscellaneous/check.dds|t"
        local lefttexture = "|t20:20:esoui/art/miscellaneous/eso_icon_warning.dds|t"

        local disIndex = self:getDisIndexFromDis(dis)

        -- stars
        for star = 1, GetNumChampionDisciplineSkills(disIndex) do
            local starId = GetChampionSkillId(disIndex, star)
            local pointsSpent = CPS:pointsSpent(starId)
            local pointsSpentI = pointsSpent
            local starTable = self.StarControls[starId]

            spent = spent + pointsSpent
            pointsSpent = tostring(pointsSpent)
            self.ignoreTextChangeUpdates = true
            starTable.EditBox:SetText(pointsSpent)
            self.ignoreTextChangeUpdates = false
            if starTable.Check ~= nil then
                local min = self:getMinimumNeeded(starId)
                if min <= pointsSpentI then
                    starTable.Check:SetEnabled(true)
                else
                    starTable.Check:SetEnabled(false)
                end
            end

            local slottable = CanChampionSkillTypeBeSlotted(skillType)
            local name = CPS:getText(CPS:getStarName(starId))
            -- self:setTooltip(starTable.Star, self:getFullDescription(name, dis, starId, pointsSpent))
            if self:isStarEnabled(starId) then
                starTable.Star:SetText(self:getColoredText(self.ColorsText[dis], name))
                starTable.Amt:SetText(self:getColoredText(self.Colors[dis], pointsSpent))
            else
                starTable.Star:SetText(self:getColoredText(self.ColorsDisabled[dis], name))
                starTable.Amt:SetText(self:getColoredText(self.ColorsDisabled[dis], pointsSpent))
            end

        end

        local unspent = totals[dis] - spent
        self.DisControls[dis].Dis:SetText(self:getColoredText(self.Colors[dis], name .. ' ' .. cptexture .. ' ' .. (totals[dis])))
        self.DisControls[dis].Amt:SetText(self:getColoredText(self.Colors[dis], checktexture .. ' ' .. spent .. ' ' .. lefttexture .. ' ' .. unspent))
        self.currentSpent[dis] = spent
        self.currentUnspent[dis] = unspent
    end

    -- slots
    local start, nd = GetAssignableChampionBarStartAndEndSlots()
    for i=start, nd do
        local starId = self.currentSlot[self.SLOT_INDEX][i]
        local dis = GetRequiredChampionDisciplineIdForSlot (i, HOTBAR_CATEGORY_CHAMPION)
        local xmlSlotIndex = tostring(((i - 1) % 4) + 1)

        if starId ~= 0 then
            local pointsSpent = CPS:pointsSpent(starId)
            local name = CPS:getStarName(starId)
            local tool = self:getFullDescription(name, dis, starId, pointsSpent)
            self:setTooltip(self.DisControls[dis]['Slot'..xmlSlotIndex], tool)
            self.DisControls[dis]['Slot'..xmlSlotIndex]:SetEnabled(true)
	    if self.StarControls[starId].Check ~= nil then
		ZO_CheckButton_SetCheckState(self.StarControls[starId].Check, true)
            end
        else
            self.DisControls[dis]['Slot'..xmlSlotIndex]:SetEnabled(false)
        end
    end

    CPS:editCheckBoxToggle()

    if CPS.currentType ~= CPS.CURRENT then
        if CPS:needsRespec(CPS.currentSlot) then
            CPS:setTooltip(CPS_WindowLoadButton, "Load and confirm ( |cff5555you lose ".. tostring(GetChampionRespecCost()) .." gold if your CP values change|r ) to the current slot.")
            CPS_WindowLoadButton:SetText("|cff5555Load")
        else
            CPS_WindowLoadButton:SetText("|c00ff00Load")
            CPS:setTooltip(CPS_WindowLoadButton, "Load and confirm to the current slot, |c00ff00free of charge.|r")
        end
    end
end

function CPS:reloadSlotComboBox()
    self.slotChoiceComboBox:ClearItems()

    if self.currentType == self.USER_PROF or self.currentType == self.ACCOUNT_PROF then -- or self.currentType == self.PREMADE_PROF then
        local itemEntry = self.slotChoiceComboBox:CreateItemEntry(self.NEW, self.SelectSlotCallback)
        self.slotChoiceComboBox:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
    end

    self.ComboMap = nil
    self.ComboMap = {}

    for i, name in pairs(self.sv.Users) do
        local entryName = self:getEntryName(i, self.sv.MapIndexToName[i])
        local comboName = "Users : " .. entryName

        if self.currentType == self.USER_PROF then
            local itemEntry = self.slotChoiceComboBox:CreateItemEntry(entryName, self.SelectSlotCallback)
            self.slotChoiceComboBox:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
        end
    end

    for i, name in pairs(self.svAccount.UsersAccount) do
        local entryName = self:getEntryName(i, self.svAccount.MapIndexToAccountName[i])
        local comboName = "UsrAcc : " .. entryName
        if self.currentType == self.ACCOUNT_PROF then
            local itemEntry = self.slotChoiceComboBox:CreateItemEntry(entryName, self.SelectSlotCallback)
            self.slotChoiceComboBox:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
        end
    end

    -- for i, name in pairs(self.svAccount.UsersPremade) do
    --     local entryName = self:getEntryName(i, self.svAccount.MapIndexToPremadeName[i])
    --     local comboName = "UsrAcc : " .. entryName
    --     local itemEntry = self.slotChoiceComboBox:CreateItemEntry(comboName, SelectTransferGreen)
    --     self.greencombo:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
    --     itemEntry = self.slotChoiceComboBox:CreateItemEntry(comboName, SelectTransferRed)
    --     self.redcombo:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
    --     itemEntry = self.slotChoiceComboBox:CreateItemEntry(comboName, SelectTransferBlue)
    --     self.bluecombo:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
    --     self.ComboMap[comboName] = self.svAccount.UsersPremade[i]
    --     if self.currentType == self.PREMADE_PROF then
    --         local itemEntry = self.slotChoiceComboBox:CreateItemEntry(entryName, self.SelectSlotCallback)
    --         self.slotChoiceComboBox:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
    --     end
    -- end

    KEYBINDING_MANAGER:RefreshList()
end

function CPS:deleteCPBuild(index)
    local arr = self.sv.Users
    local map = self.sv.MapIndexToName
    if self.currentType == self.ACCOUNT_PROF then
        arr = self.svAccount.UsersAccount
        map = self.svAccount.MapIndexToAccountName
    -- elseif self.currentType == self.PREMADE_PROF then
        -- arr = self.svAccount.UsersPremade
        -- map = self.svAccount.MapIndexToPremadeName
        -- self.svAccount.premadeCount = self.svAccount.premadeCount - 1
    else
    end
    table.remove(arr, index)
    table.remove(map, index)
    self.configTypeCombobox:SelectFirstItem()
    self.configTypeCombobox:UpdateItems()
    self.currentItemIndex = 1
    self.currentType = self.CURRENT
    self.currentSlot = self.sv[self.currentType][self.currentItemIndex]
    self:fixBindingText()
end

function CPS:cloneCPBuild()
    local oldslot = self.currentSlot
    self:createNewEntry()
    self:renameEditBoxHelperText()
    self:transferCP(self.currentSlot, oldslot)
    self:fixBindingText()
end

function CPS:deny()
    CPS:Log("Can not set CP until server cooldown expires because ZOS says so.")
end

function CPS:setCPBuild(slot)
    if CPS.changed then
        CPS:deny()
        return
    end

    CPS.tryingToSlotThisSlot = slot
    local respec = CPS:needsRespec(slot)

    PrepareChampionPurchaseRequest(respec)

    -- stars
    for dis = 1, GetNumChampionDisciplines() do
        local disIndex = self:getDisIndexFromDis(dis)
        for star = 1, GetNumChampionDisciplineSkills(disIndex) do
            local starId = GetChampionSkillId(disIndex, star)
            local pointsSpent = slot[self.STAR_INDEX][starId]
            AddSkillToChampionPurchaseRequest(starId, pointsSpent)
        end
    end

    -- slots
    local start, nd = GetAssignableChampionBarStartAndEndSlots()
    for i=start, nd do
        local currentId = self.currentSlot[self.SLOT_INDEX][i]
        local starId = slot[self.SLOT_INDEX][i]
        -- TODO
        AddHotbarSlotToChampionPurchaseRequest(i, starId)
    end

    -- There is no way to cancel it other than trying it.. so.. force push
    -- local exAvail = GetExpectedResultForChampionPurchaseRequest()
    -- if exAvail ~= CHAMPION_PURCHASE_SUCCESS then
        -- self:Log("Unable to set CP for reason : " .. self:getFailedReason(exAvail), self.LOG_ERROR_TYPE, true)
        -- self:fireMessage("Unable to set CP for reason : " .. self:getFailedReason(exAvail), CPS_WindowWarningLabel, 2000)
    -- else
    self.pending = true
    SendChampionPurchaseRequest()
    -- end
end

-- lua lmao
local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function CPS:doesCPChange()
    local start, nd = GetAssignableChampionBarStartAndEndSlots()
    local t = CPS.liveSlot[self.SLOT_INDEX]
    for i=start, nd do
        local v = CPS.oldLiveSlot[self.SLOT_INDEX][i]
        if not has_value(t, v) then
            return true
        end
    end

    return false
end

function CPS:saveCurrentCP(slot, override)
    -- stars
    for dis = 1, GetNumChampionDisciplines() do
        local disIndex = self:getDisIndexFromDis(dis)
        for star = 1, GetNumChampionDisciplineSkills(disIndex) do
            local starId = GetChampionSkillId(disIndex, star)
            local pointsSpent = GetNumPointsSpentOnChampionSkill(starId)
            slot[self.STAR_INDEX][starId] = pointsSpent
        end
    end

    -- slots
    local start, nd = GetAssignableChampionBarStartAndEndSlots()
    for i=start, nd do
        local starId = GetSlotBoundId (i, HOTBAR_CATEGORY_CHAMPION)
        local dis = GetRequiredChampionDisciplineIdForSlot (i, HOTBAR_CATEGORY_CHAMPION)
        slot[self.SLOT_INDEX][i] = starId
    end

    if not override then
        CPS:fireMessage("Successfully Saved to this build!", CPS_WindowWarningLabel, 2000)
        CPS:Log("Successfully Saved to this build!")
    end
end

function CPS:renameCPConfig(text)
    if text == nil or text == '' then
        return
    end

    local arr = CPS.sv.Users
    local map = CPS.sv.MapIndexToName

    if CPS.currentType == CPS.ACCOUNT_PROF then
        arr = CPS.svAccount.UsersAccount
        map = CPS.svAccount.MapIndexToAccountName
    -- elseif CPS.currentType == CPS.PREMADE_PROF then
        -- arr = CPS.svAccount.UsersPremade
        -- map = CPS.svAccount.MapIndexToPremadeName
    end

    for i, table in ipairs(arr) do
        if CPS.currentItemIndex == i then
            if CPS.currentSetName == map[CPS.currentItemIndex] then
                if CPS:isCurrentSet(CPS.currentType, CPS.currentSetName, CPS.currentItemIndex) then
                    CPS.sv.currentSet['name'] = text
                end

                CPS.currentSetName = text
            end
            map[CPS.currentItemIndex] = text

            CPS:reloadSlotComboBox()
            self.slotChoiceComboBox:SetSelectedItem(CPS:getEntryName(i, text))

            CPS_WindowDeleteButton:SetText("|cff0033Delete " .. text)
            CPS_WindowCloneButton:SetText("|c3333ffClone " ..  text)

            CPS:fixBindingText()
            return
        end
    end

end

function CPS:starCheckboxClicked(checkButton, isChecked, starId, dis)
    -- i = | 1~4 -> Craft | 5~8 -> Warfare | 9~12 -> Fitness |
    if isChecked then
        local full = 0
        local start, nd = GetAssignableChampionBarStartAndEndSlots()
        for i=start, nd do
            if dis == GetRequiredChampionDisciplineIdForSlot (i, HOTBAR_CATEGORY_CHAMPION) then
                local sid = self.currentSlot[self.SLOT_INDEX][i]
                if sid == 0 then
                    self.currentSlot[self.SLOT_INDEX][i] = starId
                    break
                else
                    full = full + 1
                end
            end
        end

        if full > 3 then
            -- first slot will be the sacrifice
            local disIndex = self:getDisIndexFromDis(dis)
            local sacrficeStarIndex = (disIndex * 4) - 3
            local sacrficeStarId = self.currentSlot[self.SLOT_INDEX][sacrficeStarIndex]
            self.currentSlot[self.SLOT_INDEX][sacrficeStarIndex] = starId
            ZO_CheckButton_SetCheckState(self.StarControls[sacrficeStarId].Check, false)
        end
    else
        local start, nd = GetAssignableChampionBarStartAndEndSlots()
        for i=start, nd do
            if dis == GetRequiredChampionDisciplineIdForSlot (i, HOTBAR_CATEGORY_CHAMPION) then
                local sid = self.currentSlot[self.SLOT_INDEX][i]
                if sid == starId then
                    self.currentSlot[self.SLOT_INDEX][i] = 0
                    break
                end
            end
        end
    end

    if self.currentType == self.CURRENT then
        self:setCPBuild(self.sv.Current[1])
    end

    self:reloadUIAndCache()
end

function CPS:noSlots(slot)
    local rtn = {}
    local start, nd = GetAssignableChampionBarStartAndEndSlots()
    for i=start, nd do
        rtn[i] = slot[self.SLOT_INDEX][i]
        slot[self.SLOT_INDEX][i] = 0
    end
    return rtn
end

function CPS:refillSlots(rtn, slot)
    local start, nd = GetAssignableChampionBarStartAndEndSlots()

    for i=start, nd do
        slot[self.SLOT_INDEX][i] = rtn[i]
    end
end

-- function CPS:meticulousDeconstructor(showing)
    -- self.currentlyMetic = true
    -- if showing then
        -- if self.sv.MeticTemp == nil then
            -- self.sv.MeticTemp = self.sv.Current[1][self.SLOT_INDEX][1]
        -- end
        -- self.sv.Current[1][self.SLOT_INDEX][1] = self.METIC_STAR_ID
        -- self:setCPBuild(self.sv.Current[1])
    -- else
        -- self.sv.Current[1][self.SLOT_INDEX][1] = self.sv.MeticTemp
        -- self.sv.MeticTemp = nil
        -- self:setCPBuild(self.sv.Current[1])
    -- end
-- end

-- End Main Functionals}}}

-- Setup{{{
function CPS:setupConstants()
    -- colors by discipline
    self.Colors[self.WARFARE] = self.COLOR_BLUE
    self.Colors[self.FITNESS] = self.COLOR_RED
    self.Colors[self.CRAFT]   = self.COLOR_GREEN

    -- colors disabled by discipline
    self.ColorsDisabled[self.WARFARE] = self.COLOR_DISABLED_BLUE
    self.ColorsDisabled[self.FITNESS] = self.COLOR_DISABLED_RED
    self.ColorsDisabled[self.CRAFT]   = self.COLOR_DISABLED_GREEN

    -- colors text
    self.ColorsText[self.WARFARE] = self.COLOR_TEXT_BLUE
    self.ColorsText[self.FITNESS] = self.COLOR_TEXT_RED
    self.ColorsText[self.CRAFT]   = self.COLOR_TEXT_GREEN

    local firstStarIds = {}
    local firstStarIdsSlot = {}

    -- controls by discipline
    for dis = 1, GetNumChampionDisciplines() do
        local cName = self:getDisName(dis)
        local name = self:getText(GetChampionDisciplineName(dis))
        local spent = GetNumSpentChampionPoints(dis)
        local unspent = GetNumUnspentChampionPoints(dis)
        local cptexture = "|t20:20:esoui/art/champion/champion_icon.dds|t"
        local checktexture = "|t20:20:esoui/art/miscellaneous/check.dds|t"
        local lefttexture = "|t20:20:esoui/art/miscellaneous/eso_icon_warning.dds|t"

        self.DisControls[dis] = {}
        self.DisControls[dis].Dis = WINDOW_MANAGER:GetControlByName("CPS_Window", cName .. "Dis")
        self.DisControls[dis].Amt = WINDOW_MANAGER:GetControlByName(self.DisControls[dis].Dis:GetName(), "Amt")

        local prevControl = self.DisControls[dis].Dis
        local prevControlSlot = self.DisControls[dis].Dis
        local prevStarId = nil
        local prevStarIdSlot = nil
        local firstStarId = nil
        local firstStarIdSlot = nil
        local disIndex = self:getDisIndexFromDis(dis)
        local maxSkills = GetNumChampionDisciplineSkills(disIndex)
        local writeToControl = false
        local addToEnd = {}
        local index = 0

        -- Create Controls
        for star = 1, maxSkills do
            local starId = GetChampionSkillId(disIndex, star)
            local pointsSpent = GetNumPointsSpentOnChampionSkill(starId)
            local skillType = GetChampionSkillType(starId)
            local slottable = CanChampionSkillTypeBeSlotted(skillType)
            local virtualName = "CPS_Star_Not_Slottable"
            local name = CPS:getStarName(starId)

            if slottable then
                virtualName = "CPS_Star"
            end

            self.StarControls[starId] = {}

            -- base control
            local c = CreateControlFromVirtual(self.DisControls[dis].Dis:GetName() .. tostring(starId), self.DisControls[dis].Dis, virtualName)

            -- edits
            self.StarControls[starId].Edit = WINDOW_MANAGER:GetControlByName(c:GetName(), 'Edit')
            self.StarControls[starId].EditBox = WINDOW_MANAGER:GetControlByName(c:GetName(), 'EditBox')
            local edgeControl = WINDOW_MANAGER:GetControlByName(c:GetName(), 'Edge')
            local boxControl = self.StarControls[starId].EditBox
            local editControl = self.StarControls[starId].Edit
            if dis == CPS.CRAFT then
                boxControl:SetColor(0.75,1.00,0.50,1.00)
            elseif dis == CPS.FITNESS then
                boxControl:SetColor(1.00,0.75,0.50,1.00)
            else
                boxControl:SetColor(0.50,0.75,1.00,1.00)
            end

            if slottable then
                if firstStarIdSlot == nil then
                    firstStarIdSlot = starId
                else
                    CPS.TabReverseFocusSlave[starId] = prevStarIdSlot
                    CPS.TabFocusSlave[prevStarIdSlot] = starId
                end

                if prevStarIdSlot == 33 then
                    writeToControl = true
                end
                if writeToControl then
                    addToEnd[index] = c
                    index = index + 1
                else
                    c:SetAnchor(TOPLEFT, prevControlSlot, BOTTOMLEFT, 0, -10)
                end
                prevControlSlot = c
                prevStarIdSlot = starId
                self.StarControls[starId].Check = WINDOW_MANAGER:GetControlByName(c:GetName(), 'Check' )
                self.StarControls[starId].Check:SetEnabled(false)
                ZO_CheckButton_SetToggleFunction(self.StarControls[starId].Check, function(checkButton, isChecked)
                    if CPS.changed then
                        ZO_CheckButton_SetCheckState(checkButton, not isChecked)
                        CPS:deny()
                        return
                    end
                    CPS:starCheckboxClicked(checkButton, isChecked, starId, dis)
                end)
            else
                if firstStarId == nil then
                    firstStarId = starId
                else
                    CPS.TabReverseFocusSlave[starId] = prevStarId
                    CPS.TabFocusSlave[prevStarId] = starId
                end

                c:SetAnchor(TOPRIGHT, prevControl, BOTTOMRIGHT, 0, -10)
                prevControl = c
                prevStarId = starId
            end

            -- amt control
            local cAmt = WINDOW_MANAGER:GetControlByName(c:GetName(), 'Amt' )
            self.StarControls[starId].Star = c

            c:SetHandler("OnMouseExit", function()
                editControl:SetEdgeColor(0,0,0,0)
                edgeControl:SetEdgeColor(0,0,0,0)
                CPS_WindowHelpEdge:SetEdgeColor(0,0,0,0)
                CPS_WindowHelpLabel:SetHidden(true)
                CPS_WindowWarning_BG:SetHidden(true)
                if CPS.currentFocus then
                    CPS.currentFocus:TakeFocus()
                end
            end)

            c:SetHandler("OnMouseEnter", function()
                CPS.ignoreLoseFocusUpdates = true
                if CPS.currentFocus then
                    CPS.currentFocus:LoseFocus()
                end
                if dis == CPS.CRAFT then
                    editControl:SetEdgeColor(0.75,1.00,0.50,1.00)
                    edgeControl:SetEdgeColor(0.75,1.00,0.50,1.00)
                    CPS_WindowHelpEdge:SetEdgeColor(0.75,1.00,0.50,1.00)
                elseif dis == CPS.FITNESS then
                    editControl:SetEdgeColor(1.00,0.75,0.50,1.00)
                    edgeControl:SetEdgeColor(1.00,0.75,0.50,1.00)
                    CPS_WindowHelpEdge:SetEdgeColor(1.00,0.75,0.50,1.00)
                else
                    editControl:SetEdgeColor(0.50,0.75,1.00,1.00)
                    edgeControl:SetEdgeColor(0.50,0.75,1.00,1.00)
                    CPS_WindowHelpEdge:SetEdgeColor(0.50,0.75,1.00,1.00)
                end

                local desc = self:getFullDescription(self:getText(CPS:getStarName(starId)), dis, starId, tonumber(boxControl:GetText()))
                CPS:fireMessage(CPS.EDIT_HELP..desc, CPS_WindowHelpLabel, -1)
            end)
            self.StarControls[starId].Amt = cAmt
            self.sv.Current[1][self.STAR_INDEX][starId] = pointsSpent

            -- edit handlers
            boxControl:SetHandler("OnFocusLost", function()
                if not CPS.ignoreLoseFocusUpdates then
                    CPS.currentFocus = nil
                    boxControl:LoseFocus()
                    editControl:SetEdgeColor(0,0,0,0)
                    edgeControl:SetEdgeColor(0,0,0,0)
                    CPS_WindowHelpEdge:SetEdgeColor(0,0,0,0)
                    CPS_WindowHelpLabel:SetHidden(true)
                    CPS_WindowWarning_BG:SetHidden(true)
                end
            end)

            boxControl:SetHandler("OnFocusGained", function()
                CPS.currentFocus = boxControl
                CPS.ignoreLoseFocusUpdates = false

                if dis == CPS.CRAFT then
                    editControl:SetEdgeColor(0.75,1.00,0.50,1.00)
                    edgeControl:SetEdgeColor(0.75,1.00,0.50,1.00)
                    CPS_WindowHelpEdge:SetEdgeColor(0.75,1.00,0.50,1.00)
                elseif dis == CPS.FITNESS then
                    editControl:SetEdgeColor(1.00,0.75,0.50,1.00)
                    edgeControl:SetEdgeColor(1.00,0.75,0.50,1.00)
                    CPS_WindowHelpEdge:SetEdgeColor(1.00,0.75,0.50,1.00)
                else
                    editControl:SetEdgeColor(0.50,0.75,1.00,1.00)
                    edgeControl:SetEdgeColor(0.50,0.75,1.00,1.00)
                    CPS_WindowHelpEdge:SetEdgeColor(0.50,0.75,1.00,1.00)
                end


                local desc = self:getFullDescription(self:getText(CPS:getStarName(starId)), dis, starId, tonumber(boxControl:GetText()))
                CPS:fireMessage(CPS.EDIT_HELP..desc, CPS_WindowHelpLabel, -1)
            end)

            boxControl:SetHandler("OnEnter", function()
                boxControl:LoseFocus()
            end)

            boxControl:SetHandler("OnTextChanged", function()
                if CPS.ignoreTextChangeUpdates then
                    return
                end

                if string.len(boxControl:GetText()) < 1 then
                    return
                end

                local curValue = CPS.currentSlot[CPS.STAR_INDEX][starId]
                local num = tonumber(boxControl:GetText())

                num = CPS:getMaximumCP(num, curValue, dis, starId)

                CPS.currentSlot[CPS.STAR_INDEX][starId] = num
                CPS:reloadUIAndCache()

                local desc = self:getFullDescription(self:getText(CPS:getStarName(starId)), dis, starId, tonumber(boxControl:GetText()))
                CPS:fireMessage(CPS.EDIT_HELP..desc, CPS_WindowHelpLabel, -1)

                -- CPS:setTooltip(boxControl, desc)
                -- d( " Txt Changed : " .. tostring(num) .." from " .. tostring(curValue) .. ' for ' .. tostring(starId) .. ' ' .. CPS:getStarName(starId))
            return end)

            boxControl:SetHandler("OnUpArrow", function()
                local num = 0

                if string.len(boxControl:GetText()) > 0 then
                    num = tonumber(boxControl:GetText())
                else
                    num = CPS.currentSlot[CPS.STAR_INDEX][starId]
                end

                local hasJump = DoesChampionSkillHaveJumpPoints(starId)

                if hasJump then
                    for i, x in ipairs({GetChampionSkillJumpPoints(starId)}) do
                        if num < x then
                            num = x
                            break
                        end
                    end
                else
                    local max = GetChampionSkillMaxPoints(starId)
                    if num < max then
                        num = num + 1
                    else
                        return
                    end
                end

                local curValue = CPS.currentSlot[CPS.STAR_INDEX][starId]
                num = CPS:getMaximumCP(num, curValue, dis, starId)
                boxControl:SetText(num)

            return end)

            boxControl:SetHandler("OnDownArrow", function()
                local num = 0

                if string.len(boxControl:GetText()) > 0 then
                    num = tonumber(boxControl:GetText())
                else
                    num = CPS.currentSlot[CPS.STAR_INDEX][starId]
                end

                local hasJump = DoesChampionSkillHaveJumpPoints(starId)

                if hasJump then
                    -- reverse
                    local tbl = {GetChampionSkillJumpPoints(starId)}
                    for i = #tbl, 1, -1 do
                        x = tbl[i]
                        if num > x then
                            num = x
                            break
                        end
                    end
                else
                    if num > 1 then
                        num = num - 1
                    else
                        return
                    end
                end

                local curValue = CPS.currentSlot[CPS.STAR_INDEX][starId]
                num = CPS:getMaximumCP(num, curValue, dis, starId)
                boxControl:SetText(num)
            return end)

            boxControl:SetHandler("OnTab", function()
                local id = nil
                local sid = starId
                local c = 0

                if IsShiftKeyDown() then
                    while id == nil and c < 100 do
                        c = c + 1
                        local tid = CPS.TabReverseFocusSlave[sid]
                        if CPS:isStarEnabled(tid) then
                            id = tid
                        else
                            sid = tid
                        end
                    end
                else
                    while id == nil and c < 100 do
                        local tid = CPS.TabFocusSlave[sid]
                        if CPS:isStarEnabled(tid) then
                            id = tid
                        else
                            sid = tid
                        end
                    end
                end

                if id ~= nil then
                    boxControl:LoseFocus()
                    CPS.StarControls[id].EditBox:TakeFocus()
                end
            return end)

            boxControl:SetHandler("OnSpace", function()
                local id = nil
                local c = 0

                if IsShiftKeyDown() then
                    local sid = CPS.SpaceReverseFocusSlave[starId]
                    if CPS:isStarEnabled(sid) then
                        id = sid
                    end

                    while id == nil and c < 100 do
                        c = c + 1
                        local tid = CPS.TabReverseFocusSlave[sid]
                        if CPS:isStarEnabled(tid) then
                            id = tid
                        else
                            sid = tid
                        end
                    end
                else
                    local sid = CPS.SpaceFocusSlave[starId]
                    if CPS:isStarEnabled(sid) then
                        id = sid
                    end
                    while id == nil and c < 100 do
                        c = c + 1
                        local tid = CPS.TabFocusSlave[sid]
                        if CPS:isStarEnabled(tid) then
                            id = tid
                        else
                            sid = tid
                        end
                    end
                end

                if id ~= nil then
                    boxControl:LoseFocus()
                    CPS.StarControls[id].EditBox:TakeFocus()
                end
            return end)

        end

        if writeToControl then
            for i=0, index - 1 do
                local c = addToEnd[i]
                c:SetAnchor(TOPRIGHT, prevControl, BOTTOMRIGHT, 0, -10)
                prevControl = c
            end
        end

        CPS.TabReverseFocusSlave[firstStarId] = prevStarId
        CPS.TabFocusSlave[prevStarId] = firstStarId

        CPS.TabReverseFocusSlave[firstStarIdSlot] = prevStarIdSlot
        CPS.TabFocusSlave[prevStarIdSlot] = firstStarIdSlot

        firstStarIds[dis] = firstStarId
        firstStarIdsSlot[dis] = firstStarIdSlot
    end

    -- space focus
    for dis = 1, GetNumChampionDisciplines() do
        local disForward = dis + 1
        local disBackwards = dis - 1
        if disForward > GetNumChampionDisciplines() then
            disForward = 1
        end
        if disBackwards < 1 then
            disBackwards = GetNumChampionDisciplines()
        end
        local disIndex = self:getDisIndexFromDis(dis)
        local maxSkills = GetNumChampionDisciplineSkills(disIndex)
        for star = 1, maxSkills do
            local starId = GetChampionSkillId(disIndex, star)
            local fid = firstStarIds[dis]
            local fidSlotUs = firstStarIdsSlot[dis]

            local fidSlotForward = firstStarIdsSlot[disForward]
            local fidBack = firstStarIds[disBackwards]

            local skillType = GetChampionSkillType(starId)
            local slottable = CanChampionSkillTypeBeSlotted(skillType)
            if slottable then
                CPS.SpaceFocusSlave[starId] = fid
                CPS.SpaceReverseFocusSlave[starId] = fidBack
            else
                CPS.SpaceFocusSlave[starId] = fidSlotForward
                CPS.SpaceReverseFocusSlave[starId] = fidSlotUs
            end
        end
    end

    -- slots
    local start, nd = GetAssignableChampionBarStartAndEndSlots()

    for i=start, nd do
        local starId = GetSlotBoundId (i, HOTBAR_CATEGORY_CHAMPION)
        local dis = GetRequiredChampionDisciplineIdForSlot (i, HOTBAR_CATEGORY_CHAMPION)
        local xmlSlotIndex = tostring((i % 4) + 1)

        self.DisControls[dis]['Slot'..xmlSlotIndex] = WINDOW_MANAGER:GetControlByName(self.DisControls[dis].Dis:GetName(), "Slot"..xmlSlotIndex)

        if starId ~= 0 then
            local pointsSpent = GetNumPointsSpentOnChampionSkill(starId)
            local tool = self:getDescription(starId, pointsSpent)
            local name = self:getText(CPS:getStarName(starId))
            self.sv.Current[1][self.SLOT_INDEX][i] = starId
        end
    end
end

function CPS:setupEditCheckbox()
    ZO_CheckButton_SetToggleFunction(CPS_WindowEditCheck, function()
        CPS:editCheckBoxToggle()
    end)
end

function CPS:renameEditBoxHelperText()
    if CPS.currentType == CPS.USER_PROF then
        CPS_WindowRenameEditBoxBackdropEditBox:SetText("Rename : " ..  CPS.sv.MapIndexToName[CPS.currentItemIndex])
        CPS_WindowRenameEditBoxBackdropEditBox:SetColor(.7,.7,.5,.5)
    elseif CPS.currentType == CPS.ACCOUNT_PROF then
        CPS_WindowRenameEditBoxBackdropEditBox:SetText("Rename : " ..  CPS.svAccount.MapIndexToAccountName[CPS.currentItemIndex])
        CPS_WindowRenameEditBoxBackdropEditBox:SetColor(.7,.7,.5,.5)
    -- elseif CPS.currentType == CPS.PREMADE_PROF then
        -- CPS_WindowRenameEditBoxBackdropEditBox:SetText("Rename : " ..  CPS.svAccount.MapIndexToPremadeName[CPS.currentItemIndex])
        -- CPS_WindowRenameEditBoxBackdropEditBox:SetColor(.7,.7,.5,.5)
    end
end

function CPS:setupRenameEdit()
    CPS_WindowRenameEditBoxBackdropEditBox:SetHandler("OnEnter", function()
        CPS:renameCPConfig(CPS_WindowRenameEditBoxBackdropEditBox:GetText())
        CPS_WindowRenameEditBoxBackdropEditBox:Clear()
        CPS_WindowRenameEditBoxBackdropEditBox:LoseFocus()
    end)

    CPS_WindowRenameEditBoxBackdropEditBox:SetHandler("OnFocusGained", function()
        CPS_WindowRenameEditBoxBackdropEditBox:Clear()
        CPS_WindowRenameEditBoxBackdropEditBox:SetColor(1,1,1,1)
        CPS_WindowRenameEditBoxBackdrop:SetEdgeColor(1,1,1,1)
    end)

    CPS_WindowRenameEditBoxBackdropEditBox:SetHandler("OnFocusLost", function()
        CPS_WindowRenameEditBoxBackdrop:SetEdgeColor(0,0,0,0)
        CPS:renameEditBoxHelperText()
    end)

    CPS:setTooltip(CPS_WindowRenameEditBoxBackdropEditBox, "Press |c55ff55ENTER|r when done to save new name.")

end

function CPS:SelectSlotCallback(itemName, item, selectionChanged)
    CPS_WindowSaveButton:SetHidden(false)
    CPS_WindowLoadButton:SetHidden(false)
    -- CPS_WindowSlotButton:SetHidden(false)
    CPS_WindowDeleteButton:SetHidden(true)
    CPS_WindowResetButton:SetHidden(true)
    CPS_WindowCloneButton:SetHidden(true)
    CPS_WindowEditCheck:SetHidden(false)
    CPS_WindowEditLabel:SetHidden(false)
    ZO_CheckButton_SetCheckState(CPS_WindowEditCheck, false)
    CPS.currentlyShowingSlot = true
    CPS.currentSlotIsZero = false

    CPS.dropdownGreen:SetHidden(false)
    CPS.dropdownRed:SetHidden(false)
    CPS.dropdownBlue:SetHidden(false)

    -- get the index
    CPS.currentItemIndex = tonumber(string.match(itemName, "%d+"))

    if CPS.currentType == CPS.USER_PROF or CPS.currentType == CPS.ACCOUNT_PROF then -- or CPS.currentType == CPS.PREMADE_PROF then
        CPS_WindowRenameEditBoxBackdrop:SetHidden(false)

        if itemName == CPS.NEW then
            CPS:createNewEntry()
        else
            if CPS.currentType == CPS.USER_PROF then
                CPS_WindowDeleteButton:SetText("|cff0033Delete " .. CPS.sv.MapIndexToName[CPS.currentItemIndex])
                CPS_WindowCloneButton:SetText("|c3333ffClone " .. CPS.sv.MapIndexToName[CPS.currentItemIndex])
                CPS.currentSlot = CPS.sv[CPS.currentType][CPS.currentItemIndex]

                CPS.currentSetName = CPS.sv.MapIndexToName[CPS.currentItemIndex]
                if CPS.currentSetName == nil then
                    CPS.sv.MapIndexToName[CPS.currentItemIndex] = "Name Me"
                    CPS.currentSetName = CPS.sv.MapIndexToName[CPS.currentItemIndex]
                end
            elseif CPS.currentType == CPS.ACCOUNT_PROF then
                CPS_WindowDeleteButton:SetText("|cff0033Delete " .. CPS.svAccount.MapIndexToAccountName[CPS.currentItemIndex])
                CPS_WindowCloneButton:SetText("|c3333ffClone " .. CPS.svAccount.MapIndexToAccountName[CPS.currentItemIndex])

                CPS.currentSlot = CPS.svAccount[CPS.currentType][CPS.currentItemIndex]
                CPS.currentSetName = CPS.svAccount.MapIndexToAccountName[CPS.currentItemIndex]
                if CPS.currentSetName == nil then
                    CPS.svAccount.MapIndexToAccountName[CPS.currentItemIndex] = "Name Me"
                    CPS.currentSetName = CPS.svAccount.MapIndexToAccountName[CPS.currentItemIndex]
                end
            -- else
            --     CPS_WindowDeleteButton:SetText("|cff0033Delete " .. CPS.svAccount.MapIndexToPremadeName[CPS.currentItemIndex])
            --     CPS_WindowCloneButton:SetText("|c3333ffClone " .. CPS.svAccount.MapIndexToPremadeName[CPS.currentItemIndex])

            --     CPS.currentSlot = CPS.svAccount[CPS.currentType][CPS.currentItemIndex]
            --     CPS.currentSetName = CPS.svAccount.MapIndexToPremadeName[CPS.currentItemIndex]
            --     if CPS.currentSetName == nil then
            --         CPS.svAccount.MapIndexToPremadeName[CPS.currentItemIndex] = "Name Me"
            --         CPS.currentSetName = CPS.svAccount.MapIndexToPremadeName[CPS.currentItemIndex]
            --     end
            end

        end

        CPS_WindowDeleteButton:SetHidden(false)
        CPS_WindowCloneButton:SetHidden(false)

        local function SelectTransferIndex(combo, itemName, item, selectionChanged)
            local name = CPS:transferIndex(CPS.currentItemIndex, CPS.ReorderMap[CPS.currentType][itemName])
            CPS.currentItemIndex = CPS.ReorderMap[CPS.currentType][itemName]
            local entryName = CPS:getEntryName(CPS.currentItemIndex, name)
            d ( name )
            -- not done!!
            CPS:reloadSlotComboBox()
            CPS.slotChoiceComboBox:SetSelectedItem(entryName)
            CPS_WindowDeleteButton:SetText("|cff0033Delete " .. name)
            CPS_WindowCloneButton:SetText("|c3333ffClone " ..  name)
            CPS:reloadUIAndCache()
            CPS:SelectSlotCallback(entryName, nil, nil)
            CPS:fixBindingText()
        end
        local function SelectTransferGreen(combo, itemName, item, selectionChanged)
            CPS:transferCP(CPS.currentSlot, CPS.ComboMap[itemName], nil, false, false)
            CPS:reloadUIAndCache()
        end

        local function SelectTransferRed(combo, itemName, item, selectionChanged)
            CPS:transferCP(CPS.currentSlot, CPS.ComboMap[itemName], false, nil, false)
            CPS:reloadUIAndCache()
        end

        local function SelectTransferBlue(combo, itemName, item, selectionChanged)
            CPS:transferCP(CPS.currentSlot, CPS.ComboMap[itemName], false, false, nil)
            CPS:reloadUIAndCache()
        end

        CPS.ReorderMap[CPS.currentType] = nil
        CPS.ReorderMap[CPS.currentType] = {}

        CPS.greencombo:ClearItems()
        CPS.redcombo:ClearItems()
        CPS.bluecombo:ClearItems()
        CPS.ComboMap = nil
        CPS.ComboMap = {}

        for i, name in pairs(CPS.sv.Users) do
            if CPS.currentType ~= CPS.USER_PROF or (CPS.currentType == CPS.USER_PROF and CPS.currentItemIndex ~= i) then
                local entryName = CPS:getEntryName(i, CPS.sv.MapIndexToName[i])
                local comboName = "Users : " .. entryName
                local itemEntry = CPS.slotChoiceComboBox:CreateItemEntry(comboName, SelectTransferGreen)

                CPS.greencombo:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
                itemEntry = CPS.slotChoiceComboBox:CreateItemEntry(comboName, SelectTransferRed)
                CPS.redcombo:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
                itemEntry = CPS.slotChoiceComboBox:CreateItemEntry(comboName, SelectTransferBlue)
                CPS.bluecombo:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
                CPS.ComboMap[comboName] = CPS.sv.Users[i]
            end

            if CPS.currentType == CPS.USER_PROF and CPS.currentItemIndex ~= i then
                local comboName = "Put at index : " .. tostring(i)
                local itemEntry = CPS.slotChoiceComboBox:CreateItemEntry(comboName, SelectTransferIndex)
                CPS.ReorderMap[CPS.USER_PROF][comboName] = i
            end
        end

        for i, name in pairs(CPS.svAccount.UsersAccount) do
            if CPS.currentType ~= CPS.ACCOUNT_PROF or (CPS.currentType == CPS.ACCOUNT_PROF and CPS.currentItemIndex ~= i) then
                local entryName = CPS:getEntryName(i, CPS.svAccount.MapIndexToAccountName[i])
                local comboName = "UsrAcc : " .. entryName
                local itemEntry = CPS.slotChoiceComboBox:CreateItemEntry(comboName, SelectTransferGreen)
                CPS.greencombo:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
                itemEntry = CPS.slotChoiceComboBox:CreateItemEntry(comboName, SelectTransferRed)
                CPS.redcombo:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
                itemEntry = CPS.slotChoiceComboBox:CreateItemEntry(comboName, SelectTransferBlue)
                CPS.bluecombo:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
                CPS.ComboMap[comboName] = CPS.svAccount.UsersAccount[i]
            end

            if CPS.currentType == CPS.ACCOUNT_PROF and CPS.currentItemIndex ~= i then
                local entryName = CPS:getEntryName(i, CPS.svAccount.MapIndexToAccountName[i])
                local comboName = "Put at index " .. tostring(i)
                local itemEntry = CPS.slotChoiceComboBox:CreateItemEntry(comboName, SelectTransferIndex)
                CPS.ReorderMap[CPS.ACCOUNT_PROF][comboName] = i
            end
        end

    else
        d ( "Something is terribly wrong" )
    end

    CPS:renameEditBoxHelperText()
    CPS:reloadUIAndCache()
end


function CPS:setupButtons()
    -- Buttons
    CPS_WindowCloseButton:SetHandler("OnClicked", function()
        CPS_Window:SetHidden(true)
    end)
    CPS:setTooltip(CPS_WindowCloseButton, "|cff0000Close|r you can reopen by using the slash command |c00ffff/cpslottoggleui|r or defining a keybinding. Or just reopen CP.")

    CPS_WindowSaveButton:SetHandler("OnClicked", function()
        self:saveCurrentCP(self.currentSlot, false)
        self:reloadUIAndCache()
    end)
    CPS_WindowSaveButton:SetText("|c55ff55Save")
    CPS:setTooltip(CPS_WindowSaveButton, "|c55ff55Save|r your current cp to this slot.")

    CPS_WindowLoadButton:SetHandler("OnClicked", function() CPS:setCPBuild(CPS.currentSlot) end)
    CPS_WindowLoadButton:SetText("|cff5555Load")
    CPS:setTooltip(CPS_WindowLoadButton, "Load and confirm ( |cff5555you lose ".. tostring(GetChampionRespecCost()) .." gold if your CP values change|r ) to the current slot.")

    -- FIXME not working.. IDK why
    -- CPS_WindowSlotButton:SetHandler("OnClicked", function() CPS:setCPBuild(CPS.currentSlot) end)
    -- CPS_WindowSlotButton:SetText("|cffaa55Slot")
    -- CPS:setTooltip(CPS_WindowSlotButton, "Slot the abilities, but don't respec the CP values.\nNOTE: You must have enough points in said star before you slot it.")

    -- CPS_WindowResetButton:SetHandler("OnClicked", function() CPS:resetCPBuild(CPS.currentType, CPS.currentItemIndex) CPS:updateUI(CPS.currentSlot) end)
    CPS:setTooltip(CPS_WindowResetButton, "|cff3333Reset|r the current preset to what it was by default.")

    CPS_WindowDeleteButton:SetHandler("OnClicked", function() CPS:deleteCPBuild(CPS.currentItemIndex) end)
    CPS:setTooltip(CPS_WindowDeleteButton, "|cff0033Delete|r the current slot.")

    CPS_WindowCloneButton:SetHandler("OnClicked", function() CPS:cloneCPBuild() end)
    CPS:setTooltip(CPS_WindowCloneButton, "|c3333ffClone|r the current slot to a new slot.")

    CPS:setTooltip(CPS_WindowEditCheck, "Toggle editing mode")
end

function CPS:setupCombos()
    local configTypeDropdown = WINDOW_MANAGER:GetControlByName("CPS_Window", "ConfigDropdown")
    local slotDropdown = WINDOW_MANAGER:GetControlByName("CPS_Window", "SlotDropdown")
    self.dropdownGreen = WINDOW_MANAGER:GetControlByName("CPS_Window", "DropdownGreen")
    self.dropdownRed = WINDOW_MANAGER:GetControlByName("CPS_Window", "DropdownRed")
    self.dropdownBlue = WINDOW_MANAGER:GetControlByName("CPS_Window", "DropdownBlue")

    CPS:setTooltip(configTypeDropdown, "Select CP Configuration Type")
    CPS:setTooltip(slotDropdown, "Select CP Configuration")
    CPS:setTooltip(self.dropdownGreen, "|cff00ffTransfer|r Selected |c55ff55Green|r tree to this one.")
    CPS:setTooltip(self.dropdownRed, "|cff00ffTransfer|r Selected |cff5555Red|r tree to this one.")
    CPS:setTooltip(self.dropdownBlue, "|cff00ffTransfer|r Selected |c5555ffBlue|r tree to this one.")
    CPS:setTooltip(CPSlot_UI_Button, "Open/Close " .. CPS.displayName .. " UI.")
    CPS:setTooltip(CPSlot_UI_Timer, "Shows the timer until you can set CP again")

    self.configTypeCombobox = configTypeDropdown.m_comboBox
    self.slotChoiceComboBox = slotDropdown.m_comboBox
    self.greencombo = self.dropdownGreen.m_comboBox
    self.redcombo = self.dropdownRed.m_comboBox
    self.bluecombo = self.dropdownBlue.m_comboBox

    self.greencombo.m_dropdown:SetHandler("OnShow", function(self)
        CPS.dropdownGreen:SetDimensions(300, 40)
    end)

    self.redcombo.m_dropdown:SetHandler("OnShow", function(self)
        CPS.dropdownRed:SetDimensions(300, 40)
    end)

    self.bluecombo.m_dropdown:SetHandler("OnShow", function(self)
        CPS.dropdownBlue:SetDimensions(300, 40)
    end)

    self.greencombo.m_dropdown:SetHandler("OnHide", function(self)
        CPS.dropdownGreen:SetDimensions(50, 30)
    end)

    self.redcombo.m_dropdown:SetHandler("OnHide", function(self)
        CPS.dropdownRed:SetDimensions(50, 30)
    end)

    self.bluecombo.m_dropdown:SetHandler("OnHide", function(self)
        CPS.dropdownBlue:SetDimensions(50, 30)
    end)

    self.configTypeCombobox:SetSortsItems(true)
    self.slotChoiceComboBox:SetSortsItems(true)
    self.greencombo:SetSortsItems(false)
    self.redcombo:SetSortsItems(false)
    self.bluecombo:SetSortsItems(false)

    self.configTypeCombobox:ClearItems()
    self.slotChoiceComboBox:ClearItems()

    self.greencombo:ClearItems()
    self.redcombo:ClearItems()
    self.bluecombo:ClearItems()


    local function SelectConfigTypeCallback(configTypeDropdown, itemName, item, selectionChanged)
        CPS.currentType = itemName

        CPS.slotChoiceComboBox:ClearItems()
        CPS.currentlyShowingSlot = false

        CPS_WindowResetButton:SetHidden(true)
        CPS_WindowDeleteButton:SetHidden(true)
        CPS_WindowSaveButton:SetHidden(true)
        CPS_WindowCloneButton:SetHidden(true)
        CPS_WindowLoadButton:SetHidden(true)
        -- CPS_WindowSlotButton:SetHidden(true)
        CPS_WindowRenameEditBoxBackdrop:SetHidden(true)

        ZO_CheckButton_SetCheckState(CPS_WindowEditCheck, false)
        CPS_WindowEditCheck:SetHidden(true)
        CPS_WindowEditLabel:SetHidden(true)

        CPS.dropdownGreen:SetHidden(true)
        CPS.dropdownRed:SetHidden(true)
        CPS.dropdownBlue:SetHidden(true)

        ZO_CheckButton_SetCheckState(CPS_WindowEditCheck, false)
        if itemName == CPS.CURRENT then
            slotDropdown:SetHidden(true)

            if CPS.sv.currentSet['index'] ~= -1 then
                CPS_WindowCurrentSet:SetHidden(false)
                CPS_WindowCurrentSet:SetText(CPS.sv.currentSet['name'])
            else
                CPS_WindowCurrentSet:SetHidden(true)
            end

            CPS.currentItemIndex = nil
            CPS.currentSlot = CPS.sv.Current[1]
            CPS.currentSetName = CPS.sv.currentSet['name']

            CPS:reloadUIAndCache()
        else
            CPS_WindowCurrentSet:SetHidden(true)
            CPS.currentSlotIsZero = true
            slotDropdown:SetHidden(false)
            CPS:reloadSlotComboBox()
            CPS.currentSlot = CPS.ZERO
            CPS.currentSetName = "NONE"
        end
    end

    for i, name in pairs(self.configTypes) do
        local itemEntry = self.configTypeCombobox:CreateItemEntry(name, SelectConfigTypeCallback)
        self.configTypeCombobox:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
    end

    self.configTypeCombobox:UpdateItems()
    self.configTypeCombobox:SelectFirstItem()
end

function CPS:setupCraftingScene()
    local scenes = { "gamepad_smithing_root", "smithing", "enchanting", "gamepad_enchanting_extraction" }

    for _, scene in ipairs(scenes) do
        local sceneObj = SCENE_MANAGER:GetScene(scene)

        sceneObj:RegisterCallback("StateChange", function(oldState, newState)
	    -- disable unless zos brings it back :)
            if CPS.svAccount.autoMetic then
                local shouldWe = newState == 'showing' and CPS.svAccount.autoMetic
                local shouldWeTemp = newState == 'hiding' and CPS.svAccount.autoMetic
                local pointsSpent = GetNumPointsSpentOnChampionSkill(self.METIC_STAR_ID)
                local min = self:getMinimumNeeded(self.METIC_STAR_ID)

                -- reset if we need to
                if shouldWe then
                    EVENT_MANAGER:UnregisterForUpdate(CPS.AUTOMETIC_RESLOT)
                end

                if pointsSpent >= min then
                    if shouldWe then
                        -- CPS:meticulousDeconstructor(true)
                    end

                    if shouldWeTemp then
                        -- wait one minute after leaving crafting station
                        CPS:Log("Reslotting in 60 seconds")
                        CPS.reslotting = true
                        EVENT_MANAGER:RegisterForUpdate(CPS.AUTOMETIC_RESLOT, 60000, function ()
                            CPS:Log("Reslotting Now.")
                            EVENT_MANAGER:UnregisterForUpdate(CPS.AUTOMETIC_RESLOT)
                            -- CPS:meticulousDeconstructor(false)
                        end)
                    end
                else
                    CPS:Log("Not enough points. Min: " .. tostring(min) .. ' Current: ' .. tostring(pointsSpent))
                end
            end
        end)
    end
end

function CPS:createWindow()
    CPS_Window:SetHandler("OnMoveStop", function (self)
        local valid, point, _, relPoint, offsetX, offsetY = self:GetAnchor(0)
        if valid then
            CPS.svAccount.ui.point = point
            CPS.svAccount.ui.relPoint = relPoint
            CPS.svAccount.ui.offsetX = offsetX
            CPS.svAccount.ui.offsetY = offsetY
        end
    end)

    CPSlot_UI_ButtonBg:SetHandler("OnMoveStop", function (self)
        local valid, point, _, relPoint, offsetX, offsetY = self:GetAnchor(0)
        if valid then
            CPS.svAccount.ui.buttonPoint = point
            CPS.svAccount.ui.buttonRel = relPoint
            CPS.svAccount.ui.buttonX = offsetX
            CPS.svAccount.ui.buttonY = offsetY
        end
    end)

    CPSlot_UI_Timer_BG:SetHandler("OnMoveStop", function (self)
        local valid, point, _, relPoint, offsetX, offsetY = self:GetAnchor(0)
        if valid then
            CPS.svAccount.ui.timerPoint = point
            CPS.svAccount.ui.timerRel = relPoint
            CPS.svAccount.ui.timerX = offsetX
            CPS.svAccount.ui.timerY = offsetY
        end
    end)

    CPSlot_UI_Button:SetHandler("OnClicked", function (self)
        toggleCPUI()
    end)

    CPS:setupConstants()
    CPS:setupButtons()
    CPS:setupRenameEdit()
    CPS:setupEditCheckbox()
    CPS:setupCombos()
    -- Disable since metic is no longer slottable
    -- CPS:setupCraftingScene()
end

-- end setup}}}

-- Slash commands{{{
function CPS:resetCPBuild(t, index)
    CPS:transferCP(CPS.sv[t][index], CPS.Defaults[t][index])
end

function CPS:printCP(attrib, noD)
    local name = "Current"

    if CPS.currentSetName == nil then
        name = ""
    else
        name = CPS.currentSetName
    end

    local rtn = CPS.miniDisplayName .. " : |cffffff" .. name .. "|r : "
    local raw = CPS.miniDisplayNameRaw .. " : " .. name .. " : "
    local slot = CPS.currentSlot

    for dis,arr in pairs(CPS.DisControls) do
        if (CPS:getAttribute(dis) == attrib) then
            for skill, control in ipairs(arr) do
                if skill < CPS.SKIP_INDEX then
                    if slot[dis][skill] > 0 then
                        rtn = rtn .. "|c" .. CPS.Colors[dis] .. CPS:getText(CPS:getStarName(dis, skill)) .. "  |c" .. CPS.ColorsText[dis] .. slot[dis][skill] .. "|r  "
                        raw = raw .. CPS:getText(CPS:getStarName(dis, skill)) .. "  " .. slot[dis][skill] .. '  '
                    end
                end
            end
        end
    end

    if rtn ~= "" and noD == nil then
        CPS.Log(rtn)
    end

    return raw
end

function CPS:putInChat(str)
    CHAT_SYSTEM.textEntry:SetText(str)
    CHAT_SYSTEM:Maximize()
    CHAT_SYSTEM.textEntry:Open()
    CHAT_SYSTEM.textEntry:FadeIn()
end

function toggleCPUI()
    CPS_Window:ToggleHidden()
    -- set mouse and make it moveable if showing, give camera control otherwise
    ShowMouse()
    WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
    SetGameCameraUIMode(not CPS_Window:IsHidden())
end

function selectCPKeyBindingUser(bind)
    if #CPS.sv.Users < bind then
        CPS:Log("You don't have a slot for this yet.", CPS.LOG_ERROR_TYPE, true)
        return
    end

    CPS.currentSetName = CPS.sv.MapIndexToName[bind]
    CPS.currentItemIndex = bind
    CPS.currentType = CPS.USER_PROF
    CPS.currentSlot = CPS.sv.Users[bind]

    CPS:setCPBuild(CPS.currentSlot)
end

function selectCPKeyBindingAccount(bind)
    if #CPS.svAccount.UsersAccount < bind then
        CPS:Log("You don't have a slot for this yet.", CPS.LOG_ERROR_TYPE, true)
        return
    end

    CPS.currentSetName = CPS.svAccount.MapIndexToAccountName[bind]
    CPS.currentItemIndex = bind
    CPS.currentType = CPS.ACCOUNT_PROF
    CPS.currentSlot = CPS.svAccount.UsersAccount[bind]

    CPS:setCPBuild(CPS.currentSlot)
end

function selectCPKeyBindingPremade(bind)
    if CPS.svAccount.premadeCount < bind then
        CPS:Log("You don't have a slot for this yet.", CPS.LOG_ERROR_TYPE, true)
        return
    end

    CPS.currentSetName = CPS.svAccount.MapIndexToPremadeName[bind]
    CPS.currentItemIndex = bind
    CPS.currentType = CPS.PREMADE_PROF
    CPS.currentSlot = CPS.svAccount.UsersPremade[bind]

    CPS:setCPBuild(CPS.currentSlot)
end


-- End Slash Commands}}}

-- Settings{{{
function CPS:CreateSettingsWindow()
    local LAM = LibAddonMenu2

    local settingsWindowData = {
        type = "panel",
        name = CPS.displayName,
        author = "|cff00ffJodynn|r",
        version = CPS.version .. "",
        registerForRefresh = true,
        registerForDefaults = true,
        slashCommand = "/cpslotsettings"
    }

    local settingsOptionsData = {
        {
            type = "checkbox",
            name = "Open CPSlot's UI on Champion Perks scene load.",
            tooltip = "Toggles whether or not you want to show by default when you load the CP scene.",
            default = CPS.svAccount.ui.autoShow,
            getFunc = function() return CPS.svAccount.ui.autoShow end,
            setFunc = function(newValue) CPS.svAccount.ui.autoShow = newValue end,
        },

        {
            type = "checkbox",
            name = "Show image button to open CPSlot's UI.",
            tooltip = "Toggles whether or not you want to show the icon that tells you the keybinding and a button to open the UI and move around.",
            default = CPS.svAccount.ui.showIcon,
            getFunc = function() return CPS.svAccount.ui.showIcon end,
            setFunc = function(newValue)
                CPS.svAccount.ui.showIcon = newValue
                CPSlot_UI_ButtonBg:SetHidden(not newValue)
                CPSlot_UI_Button:SetHidden(not newValue)
            end,
        },

        {
            type = "checkbox",
            name = "Show timer for when you can set CP again.",
            tooltip = "",
            default = CPS.svAccount.ui.showTimer,
            getFunc = function() return CPS.svAccount.ui.showTimer end,
            setFunc = function(newValue)
                CPS.svAccount.ui.showTimer = newValue
                CPSlot_UI_Timer_BG:SetHidden(not newValue)
                CPSlot_UI_Timer:SetHidden(not newValue)
            end,
        },

	-- Disable since it's no longer slottable, will not delete in case they bring it back because ZOS is anything but consistent
        -- {
        --     type = "checkbox",
        --     name = "Auto Meticulous on crafting scene",
        --     tooltip = "Make sure you have points slotted into it.\nWhy isn't is just always available as a passive?\nAutometicoulously Deconstructing.",
        --     default = CPS.svAccount.autoMetic,
        --     getFunc = function()
        --         return CPS.svAccount.autoMetic
        --     end,
        --     setFunc = function(newValue)
        --         CPS.svAccount.autoMetic = newValue
        --     end,
        -- },

        {
            type = "checkbox",
            name = "Show star ID numbers by name",
            tooltip = "Toggles whether or not you want to show star id for a star.\nUseful for debugging",
            default = CPS.svAccount.ui.showID,
            getFunc = function() return CPS.svAccount.ui.showID end,
            setFunc = function(newValue)
                CPS.svAccount.ui.showID = newValue
                CPS:reloadUIAndCache()
            end,
        },

        {
            type = "checkbox",
            name = "Log",
            tooltip = "Log messages when things happens.",
            default = CPS.Defaults.log,
            getFunc = function() return CPS.svAccount.ui.log end,
            setFunc = function(newValue)
                CPS.svAccount.ui.log = newValue
            end,
        },
    }

    local settingsOptionPanel = LAM:RegisterAddonPanel(CPS.name.."_LAM", settingsWindowData)
    LAM:RegisterOptionControls(CPS.name.."_LAM", settingsOptionsData)
end
-- Settings}}}

-- {{{ fix ESO breaking us
function CPS:Fix(slot)
    for dis = 1, GetNumChampionDisciplines() do
        if  (green == nil or dis ~= self.CRAFT) and (red   == nil or dis ~= self.FITNESS) and (blue  == nil or dis ~= self.WARFARE) then
            local disIndex = self:getDisIndexFromDis(dis)
            for star = 1, GetNumChampionDisciplineSkills(disIndex) do
                local starId = GetChampionSkillId(disIndex, star)
		slot[self.STAR_INDEX][starId] = CPS:pointsSpent(starId)
            end
        end
    end

    -- slots
    local start, nd = GetAssignableChampionBarStartAndEndSlots()
    for i=start, nd do
        local starId = GetSlotBoundId (i, HOTBAR_CATEGORY_CHAMPION)
        local dis = GetRequiredChampionDisciplineIdForSlot (i, HOTBAR_CATEGORY_CHAMPION)
        if  (green == nil or dis ~= self.CRAFT) and (red   == nil or dis ~= self.FITNESS) and (blue  == nil or dis ~= self.WARFARE) then
	    local skillType = GetChampionSkillType(starId)
            local slottable = CanChampionSkillTypeBeSlotted(skillType)
	    if not slottable then
		slot[self.SLOT_INDEX][i] = 0
	    end
        end
    end
end

function CPS:FixAll()
    local last = CPS.sv.latestVersionFixed
    if last == nil then
	last = -1
    end
    if (last < CPS.version) then
	CPS:Log ('Last fixed version ' .. tostring(last) .. ' is lower than current version: ' .. tostring(CPS.version))
	CPS:Log ('going to fix all your Users slots.. please hold' )
    else
	return
    end

    for i, tbl in pairs(CPS.sv.Users) do
        local entryName = CPS:getEntryName(i, CPS.sv.MapIndexToName[i])
	CPS:Log ( 'fixing: ' .. entryName)
	local slot = tbl
	CPS:Fix(slot)
    end

    CPS:Log (' going to fix all your UsersAccount slots.. please hold' )
    for i, tbl in pairs(CPS.svAccount.UsersAccount) do
        local entryName = CPS:getEntryName(i, CPS.svAccount.MapIndexToAccountName[i])
	CPS:Log ( 'fixing: ' .. entryName)
	local slot = tbl
	CPS:Fix(slot)
    end

    CPS:Log("done, on reload or log out it will save. Make a backup if you so desird of your SavedVariables beforehand. Should be somewhere like: (C:\\Users\\username\\Documents\\Elder Scrolls Online\\live\\SavedVariables)")
    CPS:Log("Setting latest version fixed to " .. tostring(CPS.version))

    CPS.sv.latestVersionFixed = CPS.version
end
-- }}}

-- Eso Stuff {{{
function CPS:Initialize()
    CPS:saveCurrentCP(CPS.liveSlot, true)
    CPS:saveCurrentCP(CPS.oldLiveSlot, true)
    CPS.currentSetName = CPS.sv.currentSet['name']

    CPSlot_UI_ButtonBg:SetHidden(not CPS.svAccount.ui.showIcon)
    CPSlot_UI_Button:SetHidden(not CPS.svAccount.ui.showIcon)

    CPSlot_UI_Timer_BG:SetHidden(not CPS.svAccount.ui.showTimer)
    CPSlot_UI_Timer:SetHidden(not CPS.svAccount.ui.showTimer)

    CPS.layerIndex, CPS.categoryIndex, CPS.actionIndex = GetActionIndicesFromName("CP_TOGGLE_UI")

    if CPS.layerIndex == nil or CPS.categoryIndex == nil or CPS.actionIndex == nil then
        CPSlot_UI_ButtonLabel:SetText("")
    else
        keycode, _, _, _, _ = GetActionBindingInfo(CPS.layerIndex, CPS.categoryIndex, CPS.actionIndex)
        CPSlot_UI_ButtonLabel:SetText(GetKeyName(keycode))
    end
    CPSlot_UI_TimerLabel:SetText("|c55ff55CP Ready To Be Set|")
    local timer = WINDOW_MANAGER:GetControlByName("CPS_Window", "Timer")
    timer:SetText("|c55ff55CP Ready To Be Set|")

    CPS.SIZE_X = CPS.WIDTHS[GetCVar("language.2")]

    CPS:createWindow()
    CPS_Window:ClearAnchors()

    CPSlot_UI_ButtonBg:ClearAnchors()
    CPSlot_UI_ButtonBg:SetAnchor(CPS.svAccount.ui.buttonPoint, GuiRoot, CPS.svAccount.ui.buttonRel, CPS.svAccount.ui.buttonX, CPS.svAccount.ui.buttonY)

    CPSlot_UI_Timer_BG:ClearAnchors()
    CPSlot_UI_Timer_BG:SetAnchor(CPS.svAccount.ui.timerPoint, GuiRoot, CPS.svAccount.ui.timerRel, CPS.svAccount.ui.timerX, CPS.svAccount.ui.timerY)

    CPS_Window:SetAnchor(CPS.svAccount.ui.point, GuiRoot, CPS.svAccount.ui.relPoint, CPS.svAccount.ui.offsetX, CPS.svAccount.ui.offsetY)
    CPS_Window:SetDimensions(CPS.SIZE_X, CPS.SIZE_Y)
    CPS_WindowTopDivider:SetDimensions(CPS.SIZE_X * .9)

    if ( CPS.svAccount.ui.scale < 50 ) then
        CPS.svAccount.ui.scale = CPS.svAccount.ui.scale * 10
    end

    -- CPS:setScale(CPS.svAccount.ui.scale)

    CHAMPION_PERKS_SCENE:RegisterCallback("StateChange", function(oldstate, newState)
        if CPS.svAccount.ui.autoShow then
            if(CHAMPION_PERKS_SCENE:IsShowing()) then
                CPS_Window:SetHidden(false)
            else
                CPS_Window:SetHidden(true)
            end
        end
    end)

    GAMEPAD_CHAMPION_PERKS_SCENE:RegisterCallback("StateChange", function(oldstate, newState)
        if CPS.svAccount.ui.autoShow then
            if(GAMEPAD_CHAMPION_PERKS_SCENE:IsShowing()) then
                CPS_Window:SetHidden(false)
            else
                CPS_Window:SetHidden(true)
            end
        end
    end)

    SLASH_COMMANDS["/cpslottoggleui"] = toggleCPUI

    CPS:CreateSettingsWindow()
    CPS:FixAll()
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= CPS.name then return end
    local version = 2.0
    CPS.sv = ZO_SavedVars:New("ChampionPointsSlots_sv", version, nil, CPS.Defaults)
    CPS.svAccount = ZO_SavedVars:NewAccountWide("ChampionPointsSlots_sv_account", version, nil, CPS.AccountDefaults)

    for i, x in ipairs(CPS.BINDING_NAMES) do
        ZO_CreateStringId(x, "NO CP SLOT MADE YET : " .. tostring(i))
    end

    for i=8793, #EsoStrings do
        if EsoStrings[i] == "NO CP SLOT MADE YET : 1" then
            CPS.bindingStartingIndex = i
        end
    end

    CPS:fixBindingText()
end

local function successEvent()
    if CPS.currentlyMetic then
        CPS.pending = false
        CPS.currentlyMetic = false
        CPS:Log('AutoMetic: ' .. CPS:getText(tostring(GetChampionSkillName(GetSlotBoundId(1, HOTBAR_CATEGORY_CHAMPION))) .. ' slotted'))
        if CPS.currentType == CPS.CURRENT then
            CPS:reloadUIAndCache()
        end
        return
    end

    -- Update the Current cp.. if not current
    CPS:saveCurrentCP(CPS.sv.Current[1], true)

    if CPS.pending then
        CPS.sv.currentSet['type'] = CPS.currentType
        CPS.sv.currentSet['index'] = CPS.currentItemIndex
        CPS.sv.currentSet['name'] = CPS.currentSetName
        CPS.currentItemIndex = 1
        CPS.currentType = CPS.CURRENT
        CPS.currentSlot = CPS.sv.Current

        CPS.configTypeCombobox:SelectFirstItem()
        CPS.configTypeCombobox:UpdateItems()

        local msg = "CP Successfully Set : ".. tostring(CPS.sv.currentSet['type']) .. " " .. tostring(CPS.sv.currentSet['name'])
        CPS:fireMessage(msg, CPS_WindowWarningLabel, 2000)
        CPS:Log(msg)

        CPS.pending = false
    else
        CPS.sv.currentSet['type'] = ''
        CPS.sv.currentSet['index'] = -1
        CPS.sv.currentSet['name'] = ''
        CPS_WindowCurrentSet:SetHidden(true)
    end

    CPS:reloadUIAndCache()

    local x = CPS.laters['change']
    if x ~= nil then
        EVENT_MANAGER:UnregisterForUpdate("CallLaterFunction"..x)
    end
end

EVENT_MANAGER:RegisterForEvent(CPS.name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, function(x)
    successEvent()
end)

local function setupTimer()
    if CPS.changed then
        local txt = "|cff5555"..tostring(30).."|"
        CPSlot_UI_TimerLabel:SetText(txt)
        local timer = WINDOW_MANAGER:GetControlByName("CPS_Window", "Timer")
        timer:SetText(txt)

        for i=1,30 do
            local x = CPS.laters[i]
            if x ~= nil then
                EVENT_MANAGER:UnregisterForUpdate("CallLaterFunction"..x)
            end
        end
        for i=1,30 do
            CPS.laters[i] = zo_callLater(function()
                local t = 30 - i
                if t == 0 then
                    CPS.changed = false
                    local txt = "|c55ff55CP Ready To Be Set|"
                    CPSlot_UI_TimerLabel:SetText()
                    timer:SetText(txt)

                    if CPS.currentType == CPS.CURRENT then
                        CPS:reloadUIAndCache()
                    end
                else
                    local txt = "|cff5555"..tostring(t).."|"
                    CPSlot_UI_TimerLabel:SetText(txt)
                    timer:SetText(txt)
                end
                CPS.laters[i] = nil
            end, i * 1000)
        end
    end
end

local function resetTimer()
    local timer = WINDOW_MANAGER:GetControlByName("CPS_Window", "Timer")
    CPS.changed = false
    for i=1,30 do
        local x = CPS.laters[i]
        if x ~= nil then
            EVENT_MANAGER:UnregisterForUpdate("CallLaterFunction"..x)
        end
    end

    local txt = "|c55ff55CP Ready To Be Set|"
    CPSlot_UI_TimerLabel:SetText()
    timer:SetText(txt)
end

EVENT_MANAGER:RegisterForEvent(CPS.name, EVENT_CHAMPION_PURCHASE_RESULT, function(event, result)
    if result == CHAMPION_PURCHASE_SUCCESS then
        CPS:saveCurrentCP(CPS.liveSlot, true)
        CPS.changed = CPS:doesCPChange()
        CPS:saveCurrentCP(CPS.oldLiveSlot, true)
        successEvent()
        setupTimer()
    else
        local st = CPS:getFailedReason(result)
        CPS:fireMessage("Champion Purchase Failed : " .. tostring(st), CPS_WindowWarningLabel, 2000)
        CPS:Log("Champion Purchase Failed : " .. tostring(st), CPS.LOG_ERROR_TYPE)
    end
end)

EVENT_MANAGER:RegisterForEvent(CPS.name, EVENT_KEYBINDING_SET, function(eventCode, layerIndex, categoryIndex, actionIndex, bindingIndex, keyCode)
    if layerIndex == nil or categoryIndex == nil or actionIndex == nil then
        CPSlot_UI_ButtonLabel:SetText("")
    elseif layerIndex == CPS.layerIndex and categoryIndex == CPS.categoryIndex and actionIndex == CPS.actionIndex then
        CPSlot_UI_ButtonLabel:SetText(GetKeyName(keyCode))
    end
end)

EVENT_MANAGER:RegisterForEvent(CPS.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(CPS.name, ZO_CHAMPION, function(ec, init)

end)

EVENT_MANAGER:RegisterForEvent(CPS.name, ZO_REMOTE_SCENE_CHANGE_ORIGIN, function(ec, init)
    -- CPS:Log(ec)
    -- CPS:Log(init)
    resetTimer()
end)

EVENT_MANAGER:RegisterForEvent(CPS.name, EVENT_PLAYER_ACTIVATED , function(eventCode, initial) -- {{{
    -- You need to do this if you want to set cp without manually doing it with
    -- the original UI

    if not CPS.loaded then
        CPS.loaded = true
        CPS:Initialize()

        local title = WINDOW_MANAGER:GetControlByName("CPS_Window", "Title")
        local texture = "|t40:40:esoui/art/champion/champion_icon.dds|t"
        title:SetText(CPS.miniDisplayName .. " " .. texture .. GetPlayerChampionPointsEarned())

        CPS_WindowHelpLabel:SetHidden(true)
        CPS_WindowWarning_BG:SetHidden(true)

        if CPS.sv.MeticTemp ~= nil then
            CPS:Log("Re-Slotting from auto-metic (You probably zoned or d/c'ed before it reloaded your original cp from auto-metic. Note, you can't reslot anything for 30 seconds, just like everywhere else because ZoSsSsSsSsS.")
            CPS.currentlyMetic = true
            CPS.sv.Current[1][CPS.SLOT_INDEX][1] = CPS.sv.MeticTemp
            CPS.sv.MeticTemp = nil
            CPS:setCPBuild(CPS.sv.Current[1])
        end
    end

    if (CPS.currentZoneId ~= ZO_ExplorationUtils_GetPlayerCurrentZoneId()) then
        resetTimer()
    end
    CPS.currentZoneId = ZO_ExplorationUtils_GetPlayerCurrentZoneId()
end)
