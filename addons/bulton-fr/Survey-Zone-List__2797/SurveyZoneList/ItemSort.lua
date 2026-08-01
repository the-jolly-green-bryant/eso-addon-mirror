SurveyZoneList.ItemSort = {}

-- @var table All saved variables dedicated to the sort system.
SurveyZoneList.ItemSort.savedVars = nil

-- @var string The current zone name
SurveyZoneList.ItemSort.currentZoneName = ""

-- @const ORDER_TYPE_SURVEY_NB_UNIQUE The value for an order by number of unique survey point
SurveyZoneList.ItemSort.ORDER_TYPE_SURVEY_NB_UNIQUE = "surveyNbUnique"

-- @const ORDER_TYPE_SURVEY_NB_TOTAL The value for an order by the total number of survey in a zone
SurveyZoneList.ItemSort.ORDER_TYPE_SURVEY_NB_TOTAL = "surveyNbTotal"


SurveyZoneList.ItemSort.ORDER_TYPE_TREASURE_NB_UNIQUE = "treasureNbUnique"


-- SurveyZoneList.ItemSort.ORDER_TYPE_TREASURE_NB_TOTAL = "treasureNbTotal"

-- @const ORDER_TYPE_ZONE_NAME The value for an order by zone name
SurveyZoneList.ItemSort.ORDER_TYPE_ZONE_NAME = "zoneName"

--[[
-- Initialise data used by the sort system
--]]
function SurveyZoneList.ItemSort:init()
    self.savedVars = SurveyZoneList.savedVariables.sort

    self:initSavedVarsValues()
end

--[[
-- Initialise with a default value all saved variables dedicated to the sort system
--]]
function SurveyZoneList.ItemSort:initSavedVarsValues()
    if self.savedVars.order == nil then
        self.savedVars.order = {
            self.ORDER_TYPE_SURVEY_NB_UNIQUE,
            self.ORDER_TYPE_SURVEY_NB_TOTAL,
            self.ORDER_TYPE_TREASURE_NB_UNIQUE,
            self.ORDER_TYPE_TREASURE_NB_TOTAL,
            self.ORDER_TYPE_ZONE_NAME
        }
    end

    if self.savedVars.keepCurrentZoneFirst == nil then
        self.savedVars.keepCurrentZoneFirst = true
    end
end

--[[
-- Obtain the current order to use
--
-- @return table
--]]
function SurveyZoneList.ItemSort:obtainOrder()
    return self.savedVars.order
end

--[[
-- Define a new order to use
--
-- @param integer pos The order priority index (1 to 3)
-- @param string value The order type to use
--]]
function SurveyZoneList.ItemSort:defineOrder(pos, value)
    self.savedVars.order[pos] = value
    SurveyZoneList.GUI:refreshAll()
end

--[[
-- Obtain info about if the current zone must always be the first item or not
--
-- @return bool
--]]
function SurveyZoneList.ItemSort:isKeepCurrentZoneFirst()
    return self.savedVars.keepCurrentZoneFirst
end

--[[
-- Define if the current zone must always be the first item or not
--
-- @param bool value
--]]
function SurveyZoneList.ItemSort:defineKeepCurrentZoneFirst(value)
    self.savedVars.keepCurrentZoneFirst = value
    SurveyZoneList.GUI:refreshAll()
end

--[[
-- Update the current zone name
--]]
function SurveyZoneList.ItemSort:updateCurrentZone()
    self.currentZoneName = zo_strformat(
        "<<1>>",
        GetZoneNameByIndex(GetCurrentMapZoneIndex())
    )

    if self.currentZoneName == nil then
        self.currentZoneName = ""
    else
        -- The current zone name is not espaced by espaceLuaStr because it's
        -- the string in which we search a zone name, it's not used as pattern.
        self.currentZoneName = self.currentZoneName:lower()
    end
end

--[[
-- Escape string to use it in pattern
-- Find at https://stackoverflow.com/a/6707799
--
-- @param String str The string to escape
--
-- @return String
--]]
function SurveyZoneList.ItemSort:espaceLuaStr(str)
    local matches = {
        ["^"] = "%^";
        ["$"] = "%$";
        ["("] = "%(";
        [")"] = "%)";
        ["%"] = "%%";
        ["."] = "%.";
        ["["] = "%[";
        ["]"] = "%]";
        ["*"] = "%*";
        ["+"] = "%+";
        ["-"] = "%-";
        ["?"] = "%?";
    }

    return str:gsub(".", matches)
end

--[[
-- Execute the table's sort on SurveyZoneList.Collect.orderedList
--]]
function SurveyZoneList.ItemSort:exec()
    table.sort(SurveyZoneList.Collect.orderedList, self.sortZoneList)
end

--[[
-- Callback function used by table.sort.
-- It's called each time an item in the sorted table is compared to another.
--
-- @param table left The left item to compare
-- @param table right The right item to compare
--
-- @return bool true if left item as the priority on right item, else return false
--]]
function SurveyZoneList.ItemSort.sortZoneList(left, right)
    local sortOrder = SurveyZoneList.ItemSort.savedVars.order

    -- Current zone always first item
    if SurveyZoneList.ItemSort:isKeepCurrentZoneFirst() == true then
        local currentName = SurveyZoneList.ItemSort.currentZoneName

        if string.find(currentName, left.nameEscaped) then
            return true
        elseif string.find(currentName, right.nameEscaped) then
            return false
        end
    end

    -- Sort type to use
    local orderType = sortOrder[1]

    -- We never compare to identical zone name, so not need a elseif for it.
    -- It's because there is not duplicate of zone name in the sorted table.

    if orderType == SurveyZoneList.ItemSort.ORDER_TYPE_SURVEY_NB_UNIQUE and left.survey.nbUnique == right.survey.nbUnique then
        orderType = sortOrder[2]
    elseif orderType == SurveyZoneList.ItemSort.ORDER_TYPE_SURVEY_NB_TOTAL and left.survey.nbTotal == right.survey.nbTotal then
        orderType = sortOrder[2]
    elseif orderType == SurveyZoneList.ItemSort.ORDER_TYPE_TREASURE_NB_UNIQUE and left.treasure.nbUnique == right.treasure.nbUnique then
        orderType = sortOrder[2]
    end
    if orderType == SurveyZoneList.ItemSort.ORDER_TYPE_SURVEY_NB_UNIQUE and left.survey.nbUnique == right.survey.nbUnique then
        orderType = sortOrder[3]
    elseif orderType == SurveyZoneList.ItemSort.ORDER_TYPE_SURVEY_NB_TOTAL and left.survey.nbTotal == right.survey.nbTotal then
        orderType = sortOrder[3]
    elseif orderType == SurveyZoneList.ItemSort.ORDER_TYPE_TREASURE_NB_UNIQUE and left.treasure.nbUnique == right.treasure.nbUnique then
        orderType = sortOrder[3]
    end
    if orderType == SurveyZoneList.ItemSort.ORDER_TYPE_SURVEY_NB_UNIQUE and left.survey.nbUnique == right.survey.nbUnique then
        orderType = sortOrder[4]
    elseif orderType == SurveyZoneList.ItemSort.ORDER_TYPE_SURVEY_NB_TOTAL and left.survey.nbTotal == right.survey.nbTotal then
        orderType = sortOrder[4]
    elseif orderType == SurveyZoneList.ItemSort.ORDER_TYPE_TREASURE_NB_UNIQUE and left.treasure.nbUnique == right.treasure.nbUnique then
        orderType = sortOrder[4]
    end
    
    -- Do the comparison
    if orderType == SurveyZoneList.ItemSort.ORDER_TYPE_ZONE_NAME then
        return left.name < right.name
    elseif orderType == SurveyZoneList.ItemSort.ORDER_TYPE_SURVEY_NB_UNIQUE then
        return left.survey.nbUnique > right.survey.nbUnique
    elseif orderType == SurveyZoneList.ItemSort.ORDER_TYPE_SURVEY_NB_TOTAL then
        return left.survey.nbTotal > right.survey.nbTotal
    elseif orderType == SurveyZoneList.ItemSort.ORDER_TYPE_TREASURE_NB_UNIQUE then
        return left.treasure.nbUnique > right.treasure.nbUnique
    end

    -- security, sort function must always return an boolean value
    return false
end