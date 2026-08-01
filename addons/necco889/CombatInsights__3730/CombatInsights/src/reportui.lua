CombatInsightsReportUI = CombatInsightsReportUI or {}
local UI = CombatInsightsReportUI
local Utils = CombatInsightsUtils

local logger = Utils.CreateSubLogger("ReportUI")
local MAX_ROWS = 200
local UI_UPDATE_PERIOD=500

local function debugPrint(message, ...)
    df("[WiReportUI]: %s", message:format(...))
end

local function debugPrintLog(message, ...)
    logger:Debug(string.format("[CPChP]: %s", message:format(...)))
end

local Row = { num = 0 }

function Row:New()
    local o = {}
    Row.num = Row.num + 1
    o.id = Row.num
    o.hidden = true
    o.name = "CombatInsightsReportRow" .. tostring(Row.num)
    o.control = CreateControlFromVirtual(o.name, UI.scrollPanelScrollChild, "CombatInsightsReportRowTemplate")
    o.lblText = o.control:GetNamedChild("Text")
    o.lblTextOrigWidth = o.lblText:GetWidth()
    o.lblUptime = o.control:GetNamedChild("Uptime")
    o.lblIgnored = o.control:GetNamedChild("Ignored")
    o.lblActualGain = o.control:GetNamedChild("ActualGain")
    o.lblPotentialGain = o.control:GetNamedChild("PotentialGain")
    o.iconControl = o.control:GetNamedChild("Icon")
    o.control:ClearAnchors()
    o.control:SetHidden(true)
    o.used = false
    o.lblText:SetFont("ZoFontGameLarge")
    o.lblUptime:SetFont("ZoFontGameLarge")
    o.lblIgnored:SetFont("ZoFontGameLarge")
    o.lblActualGain:SetFont("ZoFontGameLarge")
    o.lblPotentialGain:SetFont("ZoFontGameLarge")
    o.iconControl:SetHidden(false)
    o.lblUptime:SetHidden(false)
    o.lblIgnored:SetHidden(false)
    o.lblActualGain:SetHidden(false)
    o.lblPotentialGain:SetHidden(false)

    setmetatable(o, self)
    self.__index = self
    return o
end

local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function percentToString(val)
    if not val or val ~= val then
        return "N/A"
    end
    return string.format("%3.2f%%", round(val, 2))
end

function Row:SetData(icon, description, uptime, ignored, actualGain, potentialGain)
    self.lblUptime:SetHidden(false)
    self.lblIgnored:SetHidden(false)
    self.lblActualGain:SetHidden(false)
    self.lblPotentialGain:SetHidden(false)

    if icon then
        self.iconControl:SetHidden(false)
        self.iconControl:SetTexture(icon)
    else
        self.iconControl:SetHidden(true)
    end
    self.lblText:SetText(description)
    self.lblText:SetWidth(self.lblTextOrigWidth)
    self.lblUptime:SetText(percentToString(uptime))
    self.lblIgnored:SetText(percentToString(ignored))
    self.lblActualGain:SetText(percentToString(actualGain))
    self.lblPotentialGain:SetText(percentToString(potentialGain))
end

function Row:SetErrorString(icon, errorString)
    self.lblUptime:SetHidden(true)
    self.lblIgnored:SetHidden(true)
    self.lblActualGain:SetHidden(true)
    self.lblPotentialGain:SetHidden(true)
    if icon then
        self.iconControl:SetHidden(false)
        self.iconControl:SetTexture(icon)
    else
        self.iconControl:SetHidden(true)
    end
    self.lblText:SetText(errorString)
    self.lblText:SetWidth(self.control:GetWidth() - 20)
    self.lblText:SetWidth(errorString)
end


function Row:SetHidden(isHidden)
    if isHidden == self.hidden then return end

    local previous = nil
    local next = nil
    for i=self.id-1,1,-1 do
        local r = UI.rows[i]
        if r and r.hidden == false then
            previous = r
            break
        end
    end

    for i=self.id+1,MAX_ROWS do
        local r = UI.rows[i]
        if r and r.hidden == false then
            next = r
            break
        end
    end

    self.control:ClearAnchors()
    self.hidden = isHidden
    -- debugPrint("isHidden %s", tostring(isHidden))
    if isHidden then
        if next then
            -- debugPrint("next is %d", next.id)
            if previous then
                -- debugPrint("prev is %d", previous.id)
                next.control:SetAnchor(TOPLEFT, previous.control, BOTTOMLEFT, 0, 5)
            else
                -- debugPrint("no prev")
                next.control:SetAnchor(TOPLEFT, UI.scrollPanelScrollChild, TOPLEFT, 5, 5)
            end
        else
            -- debugPrint("no next")
        end
    else
        if not previous then
            -- debugPrint("no prev")
            self.control:SetAnchor(TOPLEFT, UI.scrollPanelScrollChild, TOPLEFT, 5, 5)
        else
            -- debugPrint("prev is %d", previous.id)
            self.control:SetAnchor(TOPLEFT, previous.control, BOTTOMLEFT, 0, 5)
        end

        if next then
            -- debugPrint("next is %d", next.id)
            next.control:SetAnchor(TOPLEFT, self.control, BOTTOMLEFT, 0, 5)
        else
            -- debugPrint("no next")
        end
    end
    self.control:SetHidden(isHidden)
end

local function getFreeRow()
    for i=1,MAX_ROWS do
        local r = UI.rows[i]
        if r.hidden == true then
            return r
        end
    end
    return nil
end

local function count(base, pattern)
    return select(2, string.gsub(base, pattern, ""))
end

function UI.AddToReport(calculation)
    -- debugPrint("AddToReport")
    local r = getFreeRow()
    if r then
        local ignoredOrig = nil
        local ignoredNew = nil
        local gainedOnOrig = nil
        local gainOnNew = nil
        if calculation.cmpForCurrentGain then
            local i, go, gn = calculation.cmpForCurrentGain:Summarize(UI.cmxSelectedUnits, UI.cmxSelectedAbilities)
            ignoredOrig = i
            gainedOnOrig = go
        end
        if calculation.cmpForPossibleGain then
            local i, go, gn = calculation.cmpForPossibleGain:Summarize(UI.cmxSelectedUnits, UI.cmxSelectedAbilities)
            ignoredNew = i
            gainOnNew = gn
        end
        r:SetData(
            calculation.config.icon,
            calculation.config.description,
            calculation.uptimeCounter and calculation.uptimeCounter:Get(UI.cmxSelectedUnits, UI.cmxSelectedAbilities) or (0/0),
            math.max(ignoredOrig or 0, ignoredNew or 0),
            gainedOnOrig or (0/0),
            gainOnNew or (0/0))

        local numlines = count(calculation.config.description, "\n") + 1
        -- r.control:SetHeight(r:GetFontHeight())
        r.lblText:SetHeight(r.lblText:GetFontHeight() * numlines)
        r:SetHidden(false)
    end
end

function UI.AddWarningToReport(err)
    local r = getFreeRow()
    if r then
        r:SetErrorString("/esoui/art/miscellaneous/eso_icon_warning.dds", err)
        local numlines = count(err, "\n") + 1
        r.lblText:SetHeight(r.lblText:GetFontHeight() * numlines)
        r:SetHidden(false)
    end
end


function UI.Init()
    UI.cmxSelectedUnits = nil
    UI.cmxSelectedAbilities = nil
    UI.control = CombatInsightsReportWindow
    UI.fragment = ZO_HUDFadeSceneFragment:New(UI.control);
    if CMX then SCENE_MANAGER:GetScene("CMX_REPORT_SCENE"):AddFragment(UI.fragment) end
    -- CombatInsightsReportWindow:SetHidden(false)
    UI.control:ClearAnchors()
    UI.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CombatInsights.SV.ui.left, CombatInsights.SV.ui.top)
    UI.control:SetWidth(CombatInsights.SV.ui.width)
    UI.control:SetHeight(CombatInsights.SV.ui.height)

    UI.bg = UI.control:GetNamedChild("Bg")
    UI.topRow = UI.bg:GetNamedChild("TopRow")
    UI.tableHeadRow = UI.bg:GetNamedChild("TableHeadRow")
    UI.scrollPanel = UI.bg:GetNamedChild("Panel")
    UI.scrollPanelScrollChild = UI.scrollPanel:GetNamedChild("Scroll"):GetNamedChild("Child")
    UI.scrollPanelScrollBar = UI.scrollPanel:GetNamedChild("ScrollBar")

    UI.scrollPanelText = UI.bg:GetNamedChild("PanelText")
    UI.scrollPanelTextScrollChild = UI.scrollPanelText:GetNamedChild("Scroll"):GetNamedChild("Child")
    UI.scrollPanelTextScrollBar = UI.scrollPanelText:GetNamedChild("ScrollBar")
    UI.scrollableTextBoxControl = CreateControlFromVirtual("CombatInsightsTextBoxTemplateInstance2", UI.scrollPanelTextScrollChild, "CombatInsightsScrollableTextBoxTemplate")
    UI.txtBox = UI.scrollableTextBoxControl:GetNamedChild("Box")
    UI.txtBox:SetMaxInputChars(100000)
    local width = UI.scrollPanelText:GetWidth() - UI.scrollPanelTextScrollBar:GetWidth() - 10
    UI.txtBox:SetWidth(width)

    UI.btnAnalyze    = UI.bg:GetNamedChild("BtnAnalyze")
    UI.progressBar   = UI.bg:GetNamedChild("ProgressBar")
    UI.progressBarFrame = UI.progressBar:GetNamedChild("Frame")
    UI.progressBarLabel = UI.progressBar:GetNamedChild("Text")
    UI.progressFill     = UI.progressBar:GetNamedChild("Fill")
    UI.btnTabAll     = UI.topRow:GetNamedChild("TabButton0")
    UI.btnTabPen     = UI.topRow:GetNamedChild("TabButton1")
    UI.btnTabBuffs   = UI.topRow:GetNamedChild("TabButton2")
    UI.btnTabDebuffs = UI.topRow:GetNamedChild("TabButton3")
    UI.btnTabCP      = UI.topRow:GetNamedChild("TabButton4")
    UI.btnTabGear    = UI.topRow:GetNamedChild("TabButton5")
    UI.btnTabWarning = UI.topRow:GetNamedChild("TabButton6")
    UI.btnClose      = UI.topRow:GetNamedChild("CloseButton")
    UI.btnDelete     = UI.topRow:GetNamedChild("DeleteButton")


    UI.tabBtnMap = {
        ["all"] = UI.btnTabAll,
        ["pen"] = UI.btnTabPen,
        ["buffs"] = UI.btnTabBuffs,
        ["debuffs"] = UI.btnTabDebuffs,
        ["cp"] = UI.btnTabCP,
        ["gear"] = UI.btnTabGear,
        ["warnings"] = UI.btnTabWarning,
    }

    UI.lblAddonName = UI.bg:GetNamedChild("AddonName")
    UI.lblAddonName:SetText(CombatInsights.name .. " " .. CombatInsights.version)

    UI.rows = {}
    for i=1,MAX_ROWS do
        UI.rows[i] = Row:New()
    end

    -- UI.SetState("error")
    -- UI.SetMode("text")
    -- for i=1,100 do
    --     UI.txtBox:SetText(UI.txtBox:GetText() ..  tostring(i) .. "\n")
    -- end
    
    UI.SetState("base")

    EVENT_MANAGER:RegisterForUpdate(CombatInsights.name .. "UiUpd", UI_UPDATE_PERIOD, UI.UpdateLoop)

end

function UI.UpdateLoop()
    if UI.analysis and UI.state == "loading" then
        UI.UpdateProgressBar(UI.analysis.progressTxt, UI.analysis.progressPercent)
    end
end


function UI.HandleTxtBoxScrollExtent(scrollableTxtBox)
    local max = 10
    while scrollableTxtBox:GetScrollExtents() == 0 and scrollableTxtBox:GetHeight() > scrollableTxtBox:GetFontHeight() and max > 0 do
        scrollableTxtBox:SetHeight( math.floor(scrollableTxtBox:GetHeight() / 2) )
        max = max - 1
    end

    if max <= 0 then
        d("TOO MANY SHRINK TRIES")
    end

    if scrollableTxtBox:GetScrollExtents() > 0 then
        scrollableTxtBox:SetHeight( scrollableTxtBox:GetHeight() + scrollableTxtBox:GetScrollExtents() * scrollableTxtBox:GetFontHeight() )
    end
    scrollableTxtBox:GetParent():SetHeight(scrollableTxtBox:GetHeight())
end



function UI.Reset()
    UI.txtBox:SetText("")
    for i=1,MAX_ROWS do
        UI.rows[i]:SetHidden(true)
    end
end

function UI.LoadReport()
    UI.ReloadReport()
    UI.SetState("report")
    if UI.lastSelectedPage then
        UI.TabButtonPressed(UI.lastSelectedPage)
    else
        UI.TabButtonPressed("all")
    end
end

function UI.RefreshCMXSelection()
    if UI.state ~= "report" then return end
    local fightDataImport, version, isSelection = CMX.GetAbilityStats()
    local numselected, abilities = Utils.GetCMXSelectedAbilities()
    local numselected2, units = Utils.GetCMXSelectedUnits(fightDataImport[1])
    UI.cmxSelectedUnitsNum = numselected
    UI.cmxSelectedAbilitiesNum = numselected2
    UI.cmxSelectedUnits = units
    UI.cmxSelectedAbilities = abilities
    UI.Reset()
    if UI.lastSelectedPage then
        UI.TabButtonPressed(UI.lastSelectedPage)
    end
    -- local astr = ""
    -- for k,v in pairs(abilities) do
    --     astr = astr .. " " .. tostring(k)
    -- end
    -- local ustr = ""
    -- for k,v in pairs(units) do
    --     ustr = ustr .. " " .. tostring(k)
    -- end
    -- debugPrint("CMX SELECTION CHANGE")
    -- debugPrint("%s", astr)
    -- debugPrint("%s", ustr)
end

function UI.ReloadReport()
    for _,calc in pairs(UI.analysis.calculations) do
        UI.AddToReport(calc)
    end
end

function UI.TabButtonPressed(key)
    -- debugPrint("TabButtonPressed %s", key)
    UI.Reset()
    UI.lastSelectedPage = key
    for k,btn in pairs(UI.tabBtnMap) do
        btn:SetState(BSTATE_NORMAL)
    end
    UI.tabBtnMap[key]:SetState(BSTATE_PRESSED)


    if key == "warnings" then
        local rowIdx = 0
        -- for e,_ in pairs(UI.calcWarnings) do
        for _,e in ipairs(UI.calcWarnings) do
            if rowIdx < MAX_ROWS then
                UI.AddWarningToReport(e)
            end
            rowIdx = rowIdx + 1
        end
    else
        local rowIdx = 0
        for _,c in ipairs(UI.analysis.calculations) do
            local cfg = c.config
            if (key == "all" or cfg.category == key) and rowIdx < MAX_ROWS then
                UI.AddToReport(c)
            end
            rowIdx = rowIdx + 1
        end
    end
    UI.HandleResize()
end

function UI.SetMode(mode)
    -- if UI.mode ~= mode then
        
        if mode == "text" then
            UI.Reset()
            UI.txtBox:SetText("")
            UI.scrollPanel:SetHidden(true)
            UI.scrollPanelText:SetHidden(false)
        elseif mode == "table" then
            UI.scrollPanel:SetHidden(false)
            UI.scrollPanelText:SetHidden(true)
        end
        
        UI.mode = mode
    -- end
end

function UI.SetState(state)
    if UI.state == state then return end

    if state == "base" then
        for _,btn in pairs(UI.tabBtnMap) do
            btn:SetState(BSTATE_DISABLED)
        end
        UI.btnDelete:SetState(BSTATE_DISABLED)

        UI.progressBar:SetHidden(true)
        UI.btnAnalyze:SetHidden(false)
        UI.btnAnalyze:SetText("Analyze selected fight")
        
    elseif state == "loading" then
        for _,btn in pairs(UI.tabBtnMap) do
            btn:SetState(BSTATE_DISABLED)
        end
        UI.btnDelete:SetState(BSTATE_DISABLED)
        UI.progressBar:SetHidden(false)
        UI.btnAnalyze:SetText("Cancel")
        
    elseif state == "report" then
        for _,btn in pairs(UI.tabBtnMap) do
            btn:SetState(BSTATE_NORMAL)
        end
        UI.btnDelete:SetState(BSTATE_NORMAL)
        UI.progressBar:SetHidden(true)
        UI.btnAnalyze:SetHidden(true)
        
    elseif state == "error" then
        for _,btn in pairs(UI.tabBtnMap) do
            btn:SetState(BSTATE_DISABLED)
        end
        UI.btnDelete:SetState(BSTATE_NORMAL)
        UI.progressBar:SetHidden(true)
        UI.btnAnalyze:SetHidden(true)
    end
    UI.state = state
    UI.HandleResize()
end


function UI.SetText(text)
    UI.txtBox:SetText(text)
end


function UI.UpdateProgressBar(txt, percent)
    local str = string.format("%s: %.0f%%", txt, (percent*100))
    UI.progressBarLabel:SetText(str)
    UI.progressFill:SetWidth( (UI.progressBarFrame:GetWidth()-4) * percent )
end

function UI.onStartButtonPressed()
    CombatInsights.onStartButtonPressed()
end

function UI.onCmxFightChanged(cmxFight)

    if cmxFight and UI.analysis then
        local loadedFight = UI.analysis.cmxFight
        --check if the startdate is equals then also check if the units table is the same
        --the latter can differ if the fight was saved and loaded
        if loadedFight.date == cmxFight.date then
            local same = true
            for k,v in pairs(loadedFight.units) do
                local other = cmxFight.units[k]
                if not other or other.unitId ~= v.unitId then
                    same = false
                    break
                end
            end
            if same then
                if UI.state == "report" or UI.state == "loading" then
                    --already showing the current report
                    return
                elseif UI.state == "base" then
                    --reload the already processed report
                    UI.Reset()
                    UI.SetData(UI.analysis)
                    return
                end
            end
        end
    end
    
    UI.Reset()
    UI.SetState("base")
end


function UI.onDeleteButtonPressed()
    UI.SetData(nil)
    UI.Reset()
    UI.SetState("base")
    CombatInsights.onDeleteButtonPressed()
end

-- set new data or just update the UI state
function UI.SetData(analysis)
    UI.Reset()
    UI.analysis = analysis

    if not analysis then
        UI.SetState("base")
        return
    end

    if UI.analysis.error then
        UI.SetState("error")
        UI.SetMode("text")
        UI.SetText(UI.analysis.error)
        return
    end

    if UI.analysis.taskRunning then
        UI.SetState("loading")
        return
    end
       
    if UI.analysis.taskCancelled then
        UI.SetState("error")
        UI.SetMode("text")
        UI.SetText("Analysis cancelled!")
        return
    end

    if UI.analysis.task.Error then
        UI.SetState("error")
        UI.SetMode("text")
        UI.SetText("Analysis failed with error:\n\n" .. UI.analysis.task.Error)
        return
    end

    UI.calcWarnings = {}
    for abilityId,_ in pairs(analysis.warnings.unknownAbilities) do
        table.insert(UI.calcWarnings, string.format("Ability unknown: %s (%d)", GetAbilityName(abilityId), abilityId))
    end
    for unitId,unitName in pairs(analysis.warnings.unknownEnemyHp) do
        table.insert(UI.calcWarnings, string.format("Enemy hp %% unknown: %s (%d)", unitName, unitId))
    end
    for text,_ in pairs(analysis.warnings.other) do
        table.insert(UI.calcWarnings, text)
    end

    UI.SetState("report")
    UI.SetMode("table")
    if UI.lastSelectedPage then
        UI.TabButtonPressed(UI.lastSelectedPage)
    else
        UI.TabButtonPressed("all")
    end
    UI.RefreshCMXSelection()
end


function UI.Resizing(control, resizing)

end

function UI.HandleResize()
    local w = UI.control:GetWidth()
    local h = UI.control:GetHeight()
    local usedWidth = 90*4+10+10
    CombatInsights.SV.ui.width = w
    CombatInsights.SV.ui.height = h
    
    UI.txtBox:SetWidth(w-40)
    for _,r in pairs(UI.rows) do
        r.control:SetWidth(w-10)
        r.lblText:SetWidth(w-usedWidth)
        local fh = r.lblText:GetFontHeight()
        r.lblText:SetHeight(fh)
        local max = 10
        while max > 0 and r.lblText:WasTruncated() do
            r.lblText:SetHeight(r.lblText:GetHeight() + fh)
            max = max - 1
        end
    end
end

function UI.NewSize(control, newLeft, newTop, newRight, newBottom, oldLeft, oldTop, oldRight, oldBottom)
    
    if control:IsHidden() then return end
    UI.HandleResize()
end


function UI.SaveLocation()
    CombatInsights.SV.ui.left = UI.control:GetLeft()
    CombatInsights.SV.ui.top = UI.control:GetTop()
end
