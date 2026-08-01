Killz = Killz or {}

local initialized = false
local fragment = nil

local OPPONENT_DATA_TYPE = 1
local ABILITY_DATA_TYPE = 2
local OVERVIEW_DATA_TYPE = 3
local TOP_OPPONENT_DATA_TYPE = 4

local CHAR_CLASS_DRAGONKNIGHT = 1
local CHAR_CLASS_SORCERER = 2
local CHAR_CLASS_NIGHTBLADE = 3
local CHAR_CLASS_WARDEN = 4
local CHAR_CLASS_NECROMANCER = 5
local CHAR_CLASS_TEMPLAR = 6
local CHAR_CLASS_ARCANIST = 117

function Killz.StatsWindow_ToggleHidden()

    local shouldHide = not KillzStatsWindow:IsHidden()

    if initialized == false then Killz.StatsWindow_Init() end

    if shouldHide and fragment then
        HUD_SCENE:RemoveFragment(fragment)
        HUD_UI_SCENE:RemoveFragment(fragment)
    else
        if fragment == nil then fragment = ZO_SimpleSceneFragment:New(KillzStatsWindow) end
        HUD_SCENE:AddFragment(fragment)
        HUD_UI_SCENE:AddFragment(fragment)
    end

    local src = nil
    local sessionData = nil

    if shouldHide == true and Killz.StatsWindowList.useSessionData == false then 
        -- Don't want to leave it on lifetime data when closing the window
        src = OPPONENT_DATA_TYPE
        sessionData = true
    end

    Killz.StatsWindowList:SetMasterListSource(src, sessionData)

    KillzStatsWindow:SetHidden(shouldHide)

end

function Killz.StatsWindow_OnInitialized()
end

function Killz.StatsWindow_OnMoveStop()

	local 	isValidAnchor, 
			currAnchorPoint, 
			relativeTo, 
			relativePoint, 
			currXOff, 
			currYOff, 
			anchorConstrains = KillzStatsWindow:GetAnchor()

	Killz.settings.opponentsWindow = { anchorPoint = currAnchorPoint, xOff = currXOff, yOff = currYOff }
end

function Killz.StatsWindow_RestorePosition()
	
    if not Killz.settings then return end

	if not Killz.settings.opponentsWindow then -- Save original window position
		local isValidAnchor, currAnchorPoint, relativeTo, 
			relativePoint, currXOff, currYOff, anchorConstrains = KillzStatsWindow:GetAnchor()
		
        Killz.settings.opponentsWindow = { anchorPoint = currAnchorPoint, xOff = currXOff, yOff = currYOff}
	end

	-- FYI: If you fuck up the XML file you'll get a nil error here when loading the addon
	KillzStatsWindow:ClearAnchors()
	KillzStatsWindow:SetAnchor(Killz.settings.opponentsWindow.anchorPoint, GuiRoot, nil, Killz.settings.opponentsWindow.xOff, Killz.settings.opponentsWindow.yOff)
end

function Killz.StatsWindow_Init()
    if initialized == true then return end
    Killz.StatsWindow_RestorePosition()
    Killz.StatsWindowList = KillzStatzList:New(KillzStatsWindow)
    initialized = true
end

function Killz.StatsWindow_ButtonClicked(inWhichButton)

    local useSessionData = Killz.StatsWindowList.useSessionData
    local dataType = Killz.StatsWindowList.dataType

    if inWhichButton == "Session" then useSessionData = true
    elseif inWhichButton == "Lifetime" then useSessionData = false
    elseif inWhichButton == "Opponents" then dataType = OPPONENT_DATA_TYPE
    elseif inWhichButton == "Abilities" then dataType = ABILITY_DATA_TYPE
    elseif inWhichButton == "Overview" then dataType = OVERVIEW_DATA_TYPE end

    Killz.StatsWindowList:SetMasterListSource(dataType, useSessionData)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
--
-- The Stats Window's Scrollable, Sortable, Filterable List Of Stats
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

KillzStatzList = ZO_SortFilterList:Subclass()

function KillzStatzList:New(...)
    return ZO_SortFilterList.New(self, ...)
end

function KillzStatzList:Initialize(control, owner)

    ZO_SortFilterList.Initialize(self, control, owner)

    self:SetEmptyText("No opponents yet.")
    self:SetAlternateRowBackgrounds(true)
    self:SetAutomaticallyColorRows(true)

    self.owner = owner
    self.useSessionData = true
    self.stats = Killz.settings.sessionStats
    self.dataType = OPPONENT_DATA_TYPE
    self.sourceData = Killz.settings.sessionOpponents
    self.opponents = self.sourceData

    self.currSortKey = "kills"
    self.currSortIsAscending = false
    self.currSortIsTargetInfo = false

    -- Stats rows (used for both opponents and abilities) have a class icon, name, then stats cells for up to 5 stats.
    -- Opponents rows use all of them.
    -- Abilities rows only use the name cell and then the first two stats cells

    local function SetupStatsRow(rowControl, data, scrollList)

        local theColor = Colorz.textDefault
        local classLabel = rowControl:GetNamedChild("Icon")
        local theIcon = ""
        if self.dataType == OPPONENT_DATA_TYPE then theIcon = "?" end
        local theName = "--"

        if data then
    
            theName = data.name

            if self.dataType == OPPONENT_DATA_TYPE and data.targetInfo then
                -- Get alliance color
                theColor = Colorz.GetAllianceColor(data.targetInfo.alliance)
        
                -- Add class & rank icons
                local icon = GetClassIcon(data.targetInfo.classID)
                if icon then theIcon = zo_iconFormatInheritColor(icon, 26, 26) end
            
                local rank = data.targetInfo.rank
                if rank == "?" then rank = nil end

                if rank then 
                    local rankIcon = GetAvARankIcon(rank)
                    if rankIcon then
                        theName = theName.." "..zo_iconFormatInheritColor(rankIcon, 26, 26)
                    end
                end
            end
        end

        classLabel:SetColor(theColor:UnpackRGBA())
        classLabel:SetText(theIcon)

        local nameButton = rowControl:GetNamedChild("Name")
        nameButton:SetNormalFontColor(theColor:UnpackRGBA()) 
        nameButton:SetMouseOverFontColor(Colorz.offWhite:UnpackRGBA()) 
        nameButton:SetText(theName)

        local hiddenName = rowControl:GetNamedChild("HiddenName") -- because GetText() doesn't work on Button controls, fuckin ZOS
        hiddenName:SetText(data.name)

        local killsLabel = rowControl:GetNamedChild("Kills")
        killsLabel:SetText(data.kills)

        local deathsLabel = rowControl:GetNamedChild("Deaths")
        deathsLabel:SetText(data.deaths)

        local kbsLabel = rowControl:GetNamedChild("KBs")
        kbsLabel:SetText(data.killingBlows or "")

        local avengeLabel = rowControl:GetNamedChild("Avenge")
        avengeLabel:SetText(data.avengeKills or "")

        local revengeLabel = rowControl:GetNamedChild("Revenge")
        revengeLabel:SetText(data.revengeKills or "")
    end

    -- Overview lines use this setup, unless its a top opponent line
    local function SetupOverviewRow(rowControl, data, scrollList)
        
        local theLabel = rowControl:GetNamedChild("Name")
        theLabel:SetVerticalAlignment(data.txtAlign)

        local theText = data.title
        theLabel:SetText(theText)

        local function setCtrlText(ctrlName, data, key)
            local theCtrl = rowControl:GetNamedChild(ctrlName)
            theCtrl:SetVerticalAlignment(data.txtAlign)
            local theText = tostring(data[key])
            if data.top and data.top[key] then 
                if data.dataType and data.dataType == TOP_OPPONENT_DATA_TYPE then 
                    theText = data.top[key]
                else
                    theText = Colorz.green:Colorize(theText) 
                end
            end
            theCtrl:SetText(theText)
        end 

        setCtrlText("Kills", data, "kills")
        setCtrlText("Deaths", data, "deaths")
        setCtrlText("KBs", data, "killingBlows")

    end

    ZO_ScrollList_AddDataType(self.list, OPPONENT_DATA_TYPE, "OpponentStatsListRow", 30, SetupStatsRow)  
    ZO_ScrollList_AddDataType(self.list, ABILITY_DATA_TYPE, "OpponentStatsListRow", 30, SetupStatsRow)  
    ZO_ScrollList_AddDataType(self.list, OVERVIEW_DATA_TYPE, "OverviewRow", 30, SetupOverviewRow)  
    ZO_ScrollList_AddDataType(self.list, TOP_OPPONENT_DATA_TYPE, "TopOpponentRow", 30, SetupOverviewRow)  

    self:UpdateCurrentList()
end

function KillzStatzList:CalcOverviewListRows()

    local statSource = Killz.settings.lifetimeStats
    if self.useSessionData == true then statSource = Killz.settings.sessionStats end

    local kdrDeaths = statSource.deaths
    if kdrDeaths == 0 then kdrDeaths = 1 end -- No division by zero please

    self.ovT = {

        { index = 998, title="",  txtAlign = TEXT_ALIGN_CENTER, kills="", deaths="", killingBlows="" },

        unique = { index = 999, title="Unique Opponents", txtAlign = TEXT_ALIGN_CENTER, kills=0,deaths=0,killingBlows=0},
        overall = { index = 1, title="Total Overall", txtAlign = TEXT_ALIGN_CENTER,
            kills=statSource.kills, 
            deaths=statSource.deaths, 
            killingBlows=statSource.killingBlows }, 
    
        kdr = {index = 2, title="Kills/Death (KDR)", txtAlign = TEXT_ALIGN_CENTER,
            kills=string.format("%.2f Kills/Death", statSource.kills/kdrDeaths), 
            deaths="--", 
            killingBlows=string.format("%.2f KBs/Death", statSource.killingBlows/kdrDeaths), 
        },
        streaks = { index = 3, title="Longest Streaks", txtAlign = TEXT_ALIGN_CENTER,
            kills=tostring(statSource.killStreak),
            deaths=tostring(statSource.deathStreak), 
            killingBlows=tostring(statSource.kbStreak) 
        },
        topOpponent = {index = 4, title="Top Opponent",  txtAlign = TEXT_ALIGN_BOTTOM, kills=0,deaths=0,killingBlows=0},

        { index = 6, title="",  txtAlign = TEXT_ALIGN_CENTER, kills="", deaths="", killingBlows="" },

        alliance = {
            [ALLIANCE_ALDMERI_DOMINION] = { index = 7, title=Colorz.alliance_AD:Colorize(GetAllianceName(ALLIANCE_ALDMERI_DOMINION)),
                                            txtAlign = TEXT_ALIGN_CENTER, allianceID=ALLIANCE_ALDMERI_DOMINION,kills=0,deaths=0,killingBlows=0},
            [ALLIANCE_DAGGERFALL_COVENANT] = { index = 8, title=Colorz.alliance_DC:Colorize(GetAllianceName(ALLIANCE_DAGGERFALL_COVENANT)),
                                            txtAlign = TEXT_ALIGN_CENTER, allianceID=ALLIANCE_DAGGERFALL_COVENANT,kills=0,deaths=0,killingBlows=0},
            [ALLIANCE_EBONHEART_PACT] = { index = 9, title=Colorz.alliance_EP:Colorize(GetAllianceName(ALLIANCE_EBONHEART_PACT)),
                                            txtAlign = TEXT_ALIGN_CENTER, allianceID=ALLIANCE_EBONHEART_PACT,kills=0,deaths=0,killingBlows=0},
        },

        { index = 10, title="",  txtAlign = TEXT_ALIGN_CENTER, kills="", deaths="", killingBlows="" },

        class = {
            [CHAR_CLASS_DRAGONKNIGHT] = { index = 11, title=GetClassName(2, CHAR_CLASS_DRAGONKNIGHT), txtAlign = TEXT_ALIGN_CENTER, classID=CHAR_CLASS_DRAGONKNIGHT,kills=0,deaths=0,killingBlows=0},
            [CHAR_CLASS_SORCERER] = { index = 12, title=GetClassName(2, CHAR_CLASS_SORCERER), txtAlign = TEXT_ALIGN_CENTER, classID=CHAR_CLASS_SORCERER,kills=0,deaths=0,killingBlows=0},
            [CHAR_CLASS_NIGHTBLADE] = { index = 13, title=GetClassName(2, CHAR_CLASS_NIGHTBLADE), txtAlign = TEXT_ALIGN_CENTER, classID=CHAR_CLASS_NIGHTBLADE,kills=0,deaths=0,killingBlows=0},
            [CHAR_CLASS_TEMPLAR] = { index = 14, title=GetClassName(2, CHAR_CLASS_TEMPLAR), txtAlign = TEXT_ALIGN_CENTER, classID=CHAR_CLASS_TEMPLAR,kills=0,deaths=0,killingBlows=0},
            [CHAR_CLASS_WARDEN] = { index = 15, title=GetClassName(2, CHAR_CLASS_WARDEN), txtAlign = TEXT_ALIGN_CENTER, classID=CHAR_CLASS_WARDEN,kills=0,deaths=0,killingBlows=0},
            [CHAR_CLASS_NECROMANCER] = { index = 16, title=GetClassName(2, CHAR_CLASS_NECROMANCER), txtAlign = TEXT_ALIGN_CENTER, classID=CHAR_CLASS_NECROMANCER,kills=0,deaths=0,killingBlows=0},
            [CHAR_CLASS_ARCANIST] = { index = 17, title=GetClassName(2, CHAR_CLASS_ARCANIST), txtAlign = TEXT_ALIGN_CENTER, classID=CHAR_CLASS_ARCANIST,kills=0,deaths=0,killingBlows=0},
        },
    }

    local function updateStatsFromOpponent(opponent, key)
        if opponent[key] > 0 then 
            self.ovT.unique[key] =  self.ovT.unique[key] + 1 
            if opponent[key] >  self.ovT.topOpponent[key] then
                self.ovT.topOpponent[key] = opponent[key]
                self.ovT.topOpponent.top = self.ovT.topOpponent.top or {}
                self.ovT.topOpponent.top[key] = opponent.name
            end
            if opponent.targetInfo then
                local info = opponent.targetInfo
                local classID = info.classID
                if classID and self.ovT.class[classID] then self.ovT.class[classID][key] = self.ovT.class[classID][key] + 1 end
                local alliance = info.alliance
                if alliance and self.ovT.alliance[alliance] then self.ovT.alliance[alliance][key] = self.ovT.alliance[alliance][key] + 1 end
            end
        end
    end

    for name, opponent in pairs(self.opponents) do
        updateStatsFromOpponent(opponent, "kills")
        updateStatsFromOpponent(opponent, "deaths")
        updateStatsFromOpponent(opponent, "killingBlows")
    end

    -- If we have a top opponent, tell list to use that row type
    if self.ovT.topOpponent.top then self.ovT.topOpponent.dataType = TOP_OPPONENT_DATA_TYPE end

    local function addTopAllianceFor(key)
        local top = 0
        
        local AD = self.ovT.alliance[ALLIANCE_ALDMERI_DOMINION]
        local DC = self.ovT.alliance[ALLIANCE_DAGGERFALL_COVENANT]
        local EP = self.ovT.alliance[ALLIANCE_EBONHEART_PACT]

        if AD[key] > 0 then top = ALLIANCE_ALDMERI_DOMINION end
        if DC[key] > AD[key] then top = ALLIANCE_DAGGERFALL_COVENANT end
        if (EP[key] > AD[key] and EP[key] > DC[key]) then top = ALLIANCE_EBONHEART_PACT end
        if top == 0 then return end

        if not self.ovT.alliance[top].top then self.ovT.alliance[top].top = {} end
        self.ovT.alliance[top].top[key]=true
    end

    local function addTopClassFor(key)
        local top = 0
        local topCount = 0
        if self.ovT.class[CHAR_CLASS_DRAGONKNIGHT][key] > topCount then 
            top = CHAR_CLASS_DRAGONKNIGHT 
            topCount = self.ovT.class[CHAR_CLASS_DRAGONKNIGHT][key]
        end
        if self.ovT.class[CHAR_CLASS_SORCERER][key] > topCount then 
            top = CHAR_CLASS_SORCERER 
            topCount = self.ovT.class[CHAR_CLASS_SORCERER][key]
        end
        if self.ovT.class[CHAR_CLASS_NIGHTBLADE][key] > topCount then 
            top = CHAR_CLASS_NIGHTBLADE 
            topCount = self.ovT.class[CHAR_CLASS_NIGHTBLADE][key]
        end
        if self.ovT.class[CHAR_CLASS_WARDEN][key] > topCount then 
            top = CHAR_CLASS_WARDEN 
            topCount = self.ovT.class[CHAR_CLASS_WARDEN][key]
        end
        if self.ovT.class[CHAR_CLASS_NECROMANCER][key] > topCount then 
            top = CHAR_CLASS_NECROMANCER 
            topCount = self.ovT.class[CHAR_CLASS_NECROMANCER][key]
        end
        if self.ovT.class[CHAR_CLASS_TEMPLAR][key] > topCount then 
            top = CHAR_CLASS_TEMPLAR 
            topCount = self.ovT.class[CHAR_CLASS_TEMPLAR][key]
        end
        if self.ovT.class[CHAR_CLASS_ARCANIST][key] > topCount then 
            top = CHAR_CLASS_ARCANIST 
            topCount = self.ovT.class[CHAR_CLASS_ARCANIST][key]
        end

        if top == 0 then return end
        if not self.ovT.class[top].top then self.ovT.class[top].top = {} end
        self.ovT.class[top].top[key]=true
    end

    addTopAllianceFor("kills")
    addTopAllianceFor("deaths")
    addTopAllianceFor("killingBlows")

    addTopClassFor("kills")
    addTopClassFor("deaths")
    addTopClassFor("killingBlows")

    if self.ovT.topOpponent.top then -- There is at least one top opponent, so need 2nd top opponent line
        local theRow = { title="", index = 5, kills="", deaths="", killingBlows="" }
        local top = self.ovT.topOpponent.top

        if top.kills then theRow.kills = string.format("(%d Kills)",  self.ovT.topOpponent.kills) end
        if top.deaths then theRow.deaths = string.format("(%d Deaths)",  self.ovT.topOpponent.deaths) end
        if top.killingBlows then theRow.killingBlows = string.format("(%d Killing Blows)",  self.ovT.topOpponent.killingBlows) end
    
        table.insert(self.ovT, theRow)
    end

    -- Need to strip the table down to the actual row definitions

    local rows = {}

    local function assembleRows(srcT, destT)
        for k, v in pairs (srcT) do
            if v.index then table.insert(destT, v)
            else assembleRows(v, destT) end -- recurse
        end
    end

    assembleRows(self.ovT, rows)

    self.ovT = ZO_DeepTableCopy(rows)

end

function KillzStatzList:SetMasterListSource(inDataType, inUseSessionData)
    
    if inDataType == nil then inDataType = self.dataType end
    if inUseSessionData == nil then inUseSessionData = self.useSessionData end
    
    self.dataType = inDataType
    self.useSessionData = inUseSessionData

    if self.useSessionData == true then 
        self.opponents = Killz.settings.sessionOpponents
        self.stats = Killz.settings.sessionStats
    else 
        self.opponents = Killz.settings.opponents
        self.stats = Killz.settings.lifetimeStats
    end

    if self.dataType == OVERVIEW_DATA_TYPE or self.dataType == TOP_OPPONENT_DATA_TYPE then self.currSortIsIndex = true else self.currSortIsIndex = false end
    self:UpdateCurrentList()
end

function KillzStatzList:BuildMasterList()

    if self.dataType == OPPONENT_DATA_TYPE then
        self.sourceData = Killz.settings.opponents
        if self.useSessionData == true then self.sourceData = Killz.settings.sessionOpponents end
        self.opponents = self.sourceData
    elseif self.dataType == ABILITY_DATA_TYPE then
        self.sourceData = Killz.settings.kbAbilities
        if self.useSessionData == true then self.sourceData = Killz.settings.sessionKBAbilities end
    elseif self.dataType == OVERVIEW_DATA_TYPE then
        self:CalcOverviewListRows()
        self.sourceData = self.ovT
    end

    return self.sourceData
end

function KillzStatzList:FilterScrollList()
    
    if not self.list or not self.sourceData then return end

    local listData = ZO_ScrollList_GetDataList(self.list)
    if not listData then return end
    
    ZO_ClearNumericallyIndexedTable(listData)

	-- We must make a deep copy of our master list using ZO_DeepTableCopy because our master lists are stored in saved variables.
	-- This is because ZO_ScrollList_CreateDataEntry creates a recursive reference to the data.
    local sourceDataCopy = ZO_DeepTableCopy(self.sourceData)
    if not sourceDataCopy then return end

    local dataType = self.dataType
    local hasTopOpponent = false

    for key, value in pairs(sourceDataCopy) do
        if self.dataType == OVERVIEW_DATA_TYPE then
            dataType = self.dataType
            if value.index and value.index == 789 and (value.kills ~= "" or value.deaths ~= "" or value.killingBlows ~= "") then 
                dataType = TOP_OPPONENT_DATA_TYPE -- we have a valid top opponet row, so make it clickable buttons
            end
        end 
        local entry = ZO_ScrollList_CreateDataEntry(dataType, value)
        table.insert(listData, entry)
    end
end

function KillzStatzList:SortScrollListBy(inSortKey, inSortAscending)

    -- If sort criteria are nil then use current sort paramaters, otherwise save new paramaters & re-sort.
    --
    -- Both opponents and abilities lists can be sorted by name, kill count or death count.
    -- Additionally, opponents can also be sorted by killnig blow count.
    -- But trying to sort by killing blows when viewing abilties will revert
    -- to kills because all ability kills are killing blows.

    if self.currSortKey == nil then self.currSortKey = "kills" end
    if self.currSortIsAscending == nil then self.currSortIsAscending = false end
    if self.currSortIsTargetInfo == nil then self.currSortIsTargetInfo = false end

    if inSortKey == nil then inSortKey = self.currSortKey end
    if inSortAscending == nil then inSortAscending = self.currSortIsAscending end
   
    self.currSortIsIndex = false 

    if self.dataType == ABILITY_DATA_TYPE and inSortKey == "killingBlows" then inSortKey = "kills" end -- all ability kills are killing blows
    if self.dataType == OVERVIEW_DATA_TYPE then 
        self.currSortIsIndex = true 
        self.currSortIsAscending = true
    end

    if inSortKey == self.currSortKey and inSortAscending == self.currSortIsAscending then return end -- alreadt sorted, nothing to do

    self.currSortKey = inSortKey
    self.currSortIsAscending = inSortAscending
    if inSortKey == "class" then self.currSortIsTargetInfo = true else self.currSortIsTargetInfo = false end

    self:RefreshSort()
end

function KillzStatzList:SortScrollList()
    
    local sortKeyLabels = {

        ["class"] = "Icon",
        ["name"] = "Name",
        ["kills"] = "Kills",
        ["deaths"] = "Deaths",
        ["killingBlows"] = "KBs",
    }

    -- Set the label for the sort column to bold & all others to normal game font
    for k, v in pairs(sortKeyLabels) do
        local ctrl = KillzStatsWindow:GetNamedChild(v)
        if ctrl then
            local font = "ZoFontGame"
            if k == "class" then font = "ZoFontWinH2" end
            local color = Colorz.textDefault
            if k == self.currSortKey then 
                font = "ZoFontGameBold"
                if k == "class" then font = "ZoFontWinH2Bold" end
                color = Colorz.offWhite
            end
            ctrl:SetFont(font)
            ctrl:SetNormalFontColor(color:UnpackRGBA()) 
        end
    end

    local function descendingComparator(objA, objB)

        if self.currSortIsIndex == true then 
            return (objB.data.index < objA.data.index) 
        elseif self.currSortIsTargetInfo == true and objA.data.targetInfo and objB.data.targetInfo then 
            return (objB.data.targetInfo[self.currSortKey] < objA.data.targetInfo[self.currSortKey]) 
        elseif not objB.data[self.currSortKey] then return true
        elseif not objA.data[self.currSortKey] then return false 
        end

        return (objB.data[self.currSortKey] < objA.data[self.currSortKey])
    end
        
    local function ascendingComparator(objA, objB)       

        if self.currSortIsIndex == true then 
            return (objA.data.index < objB.data.index) 
        elseif self.currSortIsTargetInfo == true and objA.data.targetInfo and objB.data.targetInfo then 
            return (objA.data.targetInfo[self.currSortKey] < objB.data.targetInfo[self.currSortKey]) 
        elseif not objA.data[self.currSortKey] then return true
        elseif not objB.data[self.currSortKey] then return false 
        end

        return (objA.data[self.currSortKey] < objB.data[self.currSortKey])
    end
    
    local whichComparator = descendingComparator
    if self.currSortIsAscending == true then whichComparator = ascendingComparator end

    if not self.list then return end
    local listData = ZO_ScrollList_GetDataList(self.list)
    if listData then table.sort(listData, whichComparator) end
end

function KillzStatzList:UpdateCurrentList()
    self:RefreshData()
    self:UpdateButtons()
end

function KillzStatzList:UpdateOpponentsList()
    if self.dataType ~= OPPONENT_DATA_TYPE then return end
    self:UpdateCurrentList()
end

function KillzStatzList:UpdateAbilitiesList()
    if self.dataType ~= ABILITY_DATA_TYPE then return end
    self:UpdateCurrentList()
end

function KillzStatzList:GetRowColors(data, mouseIsOver, control)
    local known = control.known
    if mouseIsOver then
        return ZO_SELECTED_TEXT, known and 0 or 1
    end
    if known then
        return ZO_NORMAL_TEXT, 0
    end
    return ZO_DISABLED_TEXT, 1
end

function KillzStatzList:OnRowMouseUp(control, button, data)
    d(string.format("KillzStatzList:OnRowMouseUp(control, button, data): control=%s, button=%s, data=%s", tostring(control) or "", tostring(button) or "", tostring(data) or ""))
end

function KillzStatzList:OnMouseDoubleClick(control, button, data)
    d(string.format("KillzStatzList:OnMouseDoubleClick(control, button, data): control=%s, button=%s, data=%s", tostring(control) or "", tostring(button) or "", tostring(data) or ""))
end

function KillzStatzList:GetMouseOverRow()
    return self.mouseOverRow
end

function KillzStatzList:UpdateButtons()
    
    self:UpdateHeaders()
    self:UpdateStreaks()

    local sessionState = BSTATE_PRESSED
    local lifetimeState = BSTATE_NORMAL
    local windowPrefix = "Session "
    local opponentsState = BSTATE_NORMAL
    local abilitiesState = BSTATE_NORMAL
    local overviewState = BSTATE_NORMAL
    local windowTitle = "Opponents"
    local shouldHide = (self.dataType ~= OPPONENT_DATA_TYPE)

    if self.useSessionData == false then
        sessionState = lifetimeState
        lifetimeState = BSTATE_PRESSED
        windowPrefix = "Lifetime "
    end

    self.currSortIsIndex = false

    if self.dataType == OPPONENT_DATA_TYPE then
        opponentsState = BSTATE_PRESSED
    elseif self.dataType == ABILITY_DATA_TYPE then
        abilitiesState = BSTATE_PRESSED
        windowTitle = "Abilities"
    elseif self.dataType == OVERVIEW_DATA_TYPE then
        overviewState = BSTATE_PRESSED
        windowTitle = "Overview"
        self.currSortIsIndex = true
    end

    local theCtrl = KillzStatsWindow:GetNamedChild("SessionBtn")
    theCtrl:SetState(sessionState)

    theCtrl = KillzStatsWindow:GetNamedChild("LifetimeBtn")
    theCtrl:SetState(lifetimeState)


    theCtrl = KillzStatsWindow:GetNamedChild("OverviewBtn")
    theCtrl:SetState(overviewState)

    theCtrl = KillzStatsWindow:GetNamedChild("OpponentsBtn")
    theCtrl:SetState(opponentsState)

    theCtrl = KillzStatsWindow:GetNamedChild("AbilitiesBtn")
    theCtrl:SetState(abilitiesState)

    windowTitle = windowPrefix..windowTitle
    theCtrl = KillzStatsWindow:GetNamedChild("StatsLabel")
    theCtrl:SetText(windowTitle)

    theCtrl = KillzStatsWindow:GetNamedChild("Name")
    theCtrl:SetHidden((self.dataType == OVERVIEW_DATA_TYPE))

    theCtrl = KillzStatsWindow:GetNamedChild("KBs")
    theCtrl:SetHidden((self.dataType == ABILITY_DATA_TYPE))

    theCtrl = KillzStatsWindow:GetNamedChild("Icon")
    theCtrl:SetHidden(shouldHide)

    theCtrl = KillzStatsWindow:GetNamedChild("Avenge")
    theCtrl:SetHidden(shouldHide)

    theCtrl = KillzStatsWindow:GetNamedChild("Revenge")
    theCtrl:SetHidden(shouldHide)

end

function KillzStatzList:UpdateHeaders()

    local oppWidths = {
        ["Icon"] = 30,
        ["Name"] = 270,
        ["Kills"] = 80,
        ["Deaths"] = 80,
        ["KBs"] = 80,
        ["Avenge"] = 80,
        ["Revenge"] = 80,
    }

    local ovWidths = {
        ["Icon"] = 10,
        ["Name"] = 150,
        ["Kills"] = 180,
        ["Deaths"] = 180,
        ["KBs"] = 180,
        ["Avenge"] = 0,
        ["Revenge"] = 0,
    }

    -- Need to change the width of header fields when list is in Overview mode vs. other mostDeaths
    -- By default we set Kills, Deaths and Killing Blows to their default positions as defined in the XML
    -- to match the OpponentStatsListRow spacing as well as make sure that they are clickable.

    local whichWidths = oppWidths
    local clickable = true

    if self.dataType == OVERVIEW_DATA_TYPE then
        -- Here we move the Kills, Deaths and Killing Blows to the wider spacing to match the
        -- OverviewRow spacing as well as make them NOT clickable. 
        whichWidths = ovWidths
        clickable = false
    end
    
    local headerCtrl = KillzStatsWindow:GetNamedChild("Icon")
    headerCtrl:SetWidth(whichWidths["Icon"])
    headerCtrl:SetMouseEnabled(clickable)
    
    headerCtrl = KillzStatsWindow:GetNamedChild("Name")
    headerCtrl:SetWidth(whichWidths["Name"])
    headerCtrl:SetMouseEnabled(clickable)

    headerCtrl = KillzStatsWindow:GetNamedChild("Kills")
    headerCtrl:SetWidth(whichWidths["Kills"])
    headerCtrl:SetMouseEnabled(clickable)

    headerCtrl = KillzStatsWindow:GetNamedChild("Deaths")
    headerCtrl:SetWidth(whichWidths["Deaths"])
    headerCtrl:SetMouseEnabled(clickable)

    headerCtrl = KillzStatsWindow:GetNamedChild("KBs")
    headerCtrl:SetWidth(whichWidths["KBs"])
    headerCtrl:SetMouseEnabled(clickable)

end

function KillzStatzList:UpdateStreaks()

    local streaks = KillzStatsWindow:GetNamedChild("Streaks")
    local killStreak = KillzStatsWindow:GetNamedChild("KillStreak")
    local deathStreak = KillzStatsWindow:GetNamedChild("DeathStreak")
    local kbStreak = KillzStatsWindow:GetNamedChild("KBStreak")
    local shouldHide = (self.dataType ~= OPPONENT_DATA_TYPE)

    streaks:SetHidden(shouldHide)
    killStreak:SetHidden(shouldHide)
    deathStreak:SetHidden(shouldHide)
    kbStreak:SetHidden(shouldHide)

    if self.dataType == OPPONENT_DATA_TYPE then
        killStreak:SetText(tostring(self.stats.longKillStreak or self.stats.killStreak))
        deathStreak:SetText(tostring(self.stats.longDeathStreak or self.stats.deathStreak))
        kbStreak:SetText(tostring(self.stats.longKBStreak or self.stats.kbStreak))
    end

end

function Killz.StatsWindowList_OnInitialized()
end

function Killz.StatsListRowHeaderClick(inCtrl, inSortKey)

    -- Double-clicking on a column header or on an element in a row will either
    -- set the sort to that column, in descending order or else toggle the sort
    -- order back & forth between ascending and descending order if that column
    -- is already the current sort column.

    local isAscending = false
    if inSortKey == Killz.StatsWindowList.currSortKey then isAscending = not Killz.StatsWindowList.currSortIsAscending end

    Killz.StatsWindowList:SortScrollListBy(inSortKey, isAscending)
end

function Killz.StatsListRow_OnNameClick(inCtrl, inHiddenCtrlName)
    
    local parent = inCtrl:GetParent()
    local hiddenName = parent:GetNamedChild(inHiddenCtrlName) -- because GetText() doesn't work on Button controls, fuckin ZOS
    local name = hiddenName:GetText()    
    local opponent = Killz.settings.opponents[name]
    if not opponent then return end

    local line1Str = nil
    local line2Str = nil
    local line3Str = nil
    if opponent.targetInfo then
        if opponent.targetInfo.account and opponent.targetInfo.account ~= "" then 
            line1Str = string.format("%s (%s)", opponent.name, opponent.targetInfo.account) 
        end
        local levelStr = nil
        if opponent.targetInfo.level ~= "?" then
            local level = tonumber(opponent.targetInfo.level)
            if level < 50 then levelStr = "Level "..tostring(opponent.targetInfo.level).." "
            else levelStr = "CP "..tostring(opponent.targetInfo.CP).." "
            end
        end
        if levelStr then line2Str = levelStr.." " else line2Str = "" end
        if opponent.targetInfo.race ~= "?" then line2Str = line2Str..opponent.targetInfo.race.." " end
        if opponent.targetInfo.class ~= "?" then line2Str = line2Str..opponent.targetInfo.class end
        if opponent.targetInfo.alliance ~= "?" then
            local allianceColor = Colorz.GetAllianceColor(opponent.targetInfo.alliance)
            line3Str = allianceColor:Colorize(GetAllianceName(opponent.targetInfo.alliance))

            if opponent.targetInfo.rank ~= "?" then 
                line3Str = line3Str.."  "..allianceColor:Colorize(string.format("[%d]", opponent.targetInfo.rank)).."\n"
                line3Str = line3Str..allianceColor:Colorize(GetAvARankName(opponent.targetInfo.gender or 2, opponent.targetInfo.rank))
            end
        end
    end

    local toolTipText = ""
    if line1Str then toolTipText = toolTipText..line1Str end
    if line2Str then 
        if line1Str then toolTipText = toolTipText.."\n" end
        toolTipText = toolTipText..line2Str
    end
    if line3Str then 
        if line1Str or line2Str then toolTipText = toolTipText.."\n" end
        toolTipText = toolTipText..line3Str
    end
    
    if toolTipText == "" then toolTipText = "No Other Information Known" end

    if toolTipText ~= "" then ZO_Tooltips_ShowTextTooltip(inCtrl, BOTTOM, toolTipText) end
end
