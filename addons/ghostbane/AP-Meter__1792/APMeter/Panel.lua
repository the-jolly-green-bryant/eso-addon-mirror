local APM = APMeter
local Panel = {
    display = false
}

local buffItems = {
    cake = {    
        headerText = 'Cake',
        defaultDescription = 'Consume a |H0:item:171323:124:10:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h |c888888(50%)|cffffff, |H0:item:171329:124:10:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h |c888888(100%)|cffffff or |H0:item:171432:124:10:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h |c888888(150%)|cffffff to gain a boost to your Alliance War skill line and rank.',
    },
    delve = {
        headerText = 'Delve Buff',
        defaultDescription = 'Kill a boss in a Cyrodiil delve to gain a |c88888820%|cffffff AP boost for 1 hour.',
    },
    event = {
        headerText = 'Event Buff',
        defaultDescription = 'Activate your |H0:item:121550:124:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h to gain a |c888888100%|cffffff AP boost for 2 hours. You gain this scroll from completing the Whitestrake\'s Mayhem Event Quest from the Crown Store.'
    }
}


local cyroManifest = {
    keeps = {10,13,15,19,20,18,16,17,9,14,12,7,6,8,5,4,3,11},
    resources = {46,47,48,75,74,73,81,80,79,36,35,34,22,23,24,85,86,87,43,44,45,82,83,84,70,71,72,76,77,78,38,37,39,64,65,66,61,62,63,67,68,69,49,50,51,55,56,57,40,41,42,52,53,54},
    outposts = {134,164,165,132,133,163},
    towns = {151,152,149},

    farm = {46,75,81,36,22,87,43,84,72,78,39,66,61,25,69,49,55,40,52},
    lumbermill = {47,74,80,34,24,86,44,83,71,77,37,65,62,26,68,50,56,41,53},
    mine = {48,73,79,35,23,85,45,82,70,76,38,64,63,27,67,51,57,42,54}
}

local ticklist = {}
local goalUI = {}
local sessionUI = {}

local function BuildBuffsArea()

    local container = APMeterPanelBuffsArea
    for i,category in ipairs({ 'Cake', 'Delve', 'Event' }) do
        local cakeContainer = GetControl(container, category)
        local key = category:lower()

        buffItems[key].active = false
        buffItems[key].ctx_header = GetControl(cakeContainer, 'Label')
        buffItems[key].ctx_boost = GetControl(cakeContainer, 'LabelPerc')
        buffItems[key].ctx_icon = GetControl(cakeContainer, 'FrameIconFile')
        buffItems[key].ctx_iconWarning = GetControl(cakeContainer, 'FrameIconWarning')
        buffItems[key].ctx_name = GetControl(cakeContainer, 'Name')
        buffItems[key].ctx_description = GetControl(cakeContainer, 'NameDesc')
        buffItems[key].ctx_defaultDescription = GetControl(cakeContainer, 'DefaultDesc')
        buffItems[key].ctx_timer = GetControl(cakeContainer, 'Timer')
        buffItems[key].ctx_duration = GetControl(cakeContainer, 'TimerDisplay')

        buffItems[key].ctx_header:SetText(buffItems[key].headerText)
        buffItems[key].ctx_defaultDescription:SetText(buffItems[key].defaultDescription)
    end
end

local function MakeScrollerAreas()

    local scrollChildContainer = APMeterPanelSession:GetNamedChild('ScrollChild')
    APMeterPanelSessionArea:SetParent( scrollChildContainer )
    APMeterPanelSessionArea:SetAnchor(TOPLEFT, scrollChildContainer, TOPLEFT, 4, 4)

    local scrollChildContainer = APMeterPanelTicklist:GetNamedChild('ScrollChild')
    APMeterPanelTicklistArea:SetParent( scrollChildContainer )
    APMeterPanelTicklistArea:SetAnchor(TOPLEFT, scrollChildContainer, TOPLEFT, 4, 4)

    local scrollChildContainer = APMeterPanelBuffs:GetNamedChild('ScrollChild')
    APMeterPanelBuffsArea:SetParent( scrollChildContainer )
    APMeterPanelBuffsArea:SetAnchor(TOPLEFT, scrollChildContainer, TOPLEFT, 4, 4)

    BuildBuffsArea()

    ticklist = {
        keep = { active = false, container = GetControl(APMeterPanelTicklistArea,'Keep') },
        resource = { active = false, container = GetControl(APMeterPanelTicklistArea,'Resource') },
        outpost = { active = false, container = GetControl(APMeterPanelTicklistArea,'Outpost') },
        town = { active = false, container = GetControl(APMeterPanelTicklistArea,'Town') }
    }

    goalUI = {
        ctx_Add = GetControl(APMeterPanelSessionArea,'AddGoal'),
        ctx_Label = GetControl(APMeterPanelSessionArea,'GoalLabel'),
        ctx_Status = GetControl(APMeterPanelSessionArea,'GoalStatus'),
        ctx_Perc = GetControl(APMeterPanelSessionArea,'GoalStatusPerc'),
        ctx_AP = GetControl(APMeterPanelSessionArea,'GoalStatusAP'),
    }
    
    sessionUI = {
        ctx_RankName = GetControl(APMeterPanelSessionArea,'RankName'),
        ctx_APH = GetControl(APMeterPanelSessionArea,'APH'),
        ctx_Time = GetControl(APMeterPanelSessionArea,'APHTime'),
        ctx_NextRankValue = GetControl(APMeterPanelSessionArea,'NextRank'),
        ctx_NextRankStatus = GetControl(APMeterPanelSessionArea,'NextRankProgress'),
        ctx_NextRankPerc = GetControl(APMeterPanelSessionArea,'NextRankProgressPerc'),
        ctx_NextRankIcon = GetControl(APMeterPanelSessionArea,'NextRankProgressIcon'),
        ctx_NextRankLabel = GetControl(APMeterPanelSessionArea,'NextRankProgressLabel'),
        
        types = {}
    }

    for i, catgeory in ipairs({'Combat', 'Repairs', 'Defence', 'Capture', 'Quests', 'Resurrections'}) do
        sessionUI.types[catgeory] = {
            ctx_Label = GetControl(APMeterPanelSessionArea,'Stats'..catgeory..'Label'),
            ctx_Status = GetControl(APMeterPanelSessionArea,'Stats'..catgeory),
            ctx_StatusPerc = GetControl(APMeterPanelSessionArea,'Stats'..catgeory..'Perc'),
            ctx_StatusAP = GetControl(APMeterPanelSessionArea,'Stats'..catgeory..'AP'),
        }

        sessionUI.types[catgeory].ctx_Status:SetValue(0)
        sessionUI.types[catgeory].ctx_StatusPerc:SetText('0%')
        sessionUI.types[catgeory].ctx_StatusAP:SetText('')                                    
    end
    
                                    
    GetControl(APMeterPanelSessionArea, 'PlayerName'):SetText(GetUnitName('player'))

    Panel.UpdateSession()
end

local function OnUpdatePanel()

    for i,category in ipairs({ 'cake', 'delve', 'event' }) do
        local row = buffItems[category]

        if row.active then
            row.timeRemaining = zo_max(zo_roundToNearest(row.endTime - GetGameTimeMilliseconds() / 1000, 1), 0)
            row.ctx_timer:SetValue(math.floor(100/row.duration * row.timeRemaining))
            row.ctx_duration:SetText(ZO_FormatTime(row.timeRemaining, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS))
        end
    end
    
    for i,category in ipairs({ 'keep', 'resource', 'town', 'outpost' }) do
        local row = ticklist[category]

        if row.active then
            local waitTime = GetTimeStamp() - row.timeAgo
            row.container:GetNamedChild('TimeAgo'):SetText(ZO_FormatTime(waitTime, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS))
        end
    end

    if APM.session.timeElapsed > 0 then
        APM.session.timeElapsed = (APM.session.timeElapsed + GetGameTimeMilliseconds() - APM.session.startTime) / 1000
        local APH_value = math.floor(1 * (3600 / APM.session.timeElapsed * APM.session.total))
        local currencyDisplayOptions = {
            showTooltips = false,
            useShortFormat = false,
            font = "$(GAMEPAD_LIGHT_FONT)|32|soft-shadow-thick",
            iconSide = RIGHT,
            iconSize = 22,
        }

        ZO_CurrencyControl_SetSimpleCurrency(sessionUI.ctx_APH, CURT_ALLIANCE_POINTS, APH_value, currencyDisplayOptions, CURRENCY_SHOW_ALL)
        sessionUI.ctx_Time:SetText(ZO_FormatTime(APM.session.timeElapsed, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS))
    else
        sessionUI.ctx_Time:SetText('')
    end
end

local function GetAVAResourceType( keepId )

    local resourceType = 'mine'

    if ZO_IsElementInNumericallyIndexedTable(cyroManifest.farm, keepId) then
        resourceType = 'farm'
    end

    if ZO_IsElementInNumericallyIndexedTable(cyroManifest.lumbermill, keepId) then
        resourceType = 'lumbermill'
    end

    return resourceType

end

local function GetKeepType( keepId )

    local keepType = 0

    if ZO_IsElementInNumericallyIndexedTable(cyroManifest.resources, keepId) then
        keepType = 'resource'
    end

    if ZO_IsElementInNumericallyIndexedTable(cyroManifest.keeps, keepId) then
        keepType = 'keep'
    end

    if ZO_IsElementInNumericallyIndexedTable(cyroManifest.towns, keepId) then
        keepType = 'town'
    end

    if ZO_IsElementInNumericallyIndexedTable(cyroManifest.outposts, keepId) then
        keepType = 'outpost'
    end

    return keepType

end

local function UpdateGoal()

    local db = APM.db

    if db.goal.active then
        local current = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(db.goal.total))
        local finish = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(db.goal.target))
        goalUI.ctx_AP:SetText(string.format('%s / %s', current, finish))

        local perc = math.floor(100 / db.goal.target * db.goal.total)
        goalUI.ctx_Status:SetValue(perc)
        goalUI.ctx_Perc:SetText(tostring(perc)..'%')
    end
end

Panel.UpdateGoal = UpdateGoal

local function SetGoalUI()

    if APM.db.goal.active then
        goalUI.ctx_Add:SetHidden(true)
        goalUI.ctx_Label:SetHidden(false)
        goalUI.ctx_Status:SetHidden(false)
    else
        goalUI.ctx_Add:SetHidden(false)
        goalUI.ctx_Label:SetHidden(true)
        goalUI.ctx_Status:SetHidden(true)
    end

    APM.Theme.Selected():ToggleGoalUI()

end

local function RemoveGoal()

    local db = APM.db

    db.goal.active = false
    db.goal.target = 0
    db.goal.total = 0
    SetGoalUI()
    APM.Theme.Selected():SetGoalProgress(0)
end

Panel.RemoveGoal = RemoveGoal

local function AddGoal( value )
    
    local db = APM.db

    if type(value) ~= 'number' then
        value = tonumber(value)
    end

    db.goal.active = true
    db.goal.target = value
    db.goal.total = 0
    UpdateGoal()
    SetGoalUI()
    
end

-- OnKeepChange()
----------------------
local function OnKeepChange(eventCode, keepId)
    Panel.UpdateTicklist(keepId, false, true)
end

local playerAlliance = GetUnitAlliance('player')

local ticklistIcons = {
    keep = '/esoui/art/compass/ava_largekeep_%s.dds',
    outpost = '/esoui/art/compass/ava_outpost_%s.dds',
    town = '/esoui/art/compass/ava_town_%s.dds',
    lumbermill = '/esoui/art/compass/ava_lumbermill_%s.dds',
    mine = '/esoui/art/compass/ava_mine_%s.dds',
    farm = '/esoui/art/compass/ava_farm_%s.dds'
}

function Panel.UpdateSession()

    local _, gender = GetCharacterInfo()
    local rank = GetUnitAvARank('player')
    local nextRankPerc, nextRankValue = APM.GetLocalAP()

    local currencyDisplayOptions = {
        showTooltips = false,
        useShortFormat = false,
        font = "$(GAMEPAD_MEDIUM_FONT)|32|soft-shadow-thick",
        iconSide = RIGHT,
        iconSize = 22,
    }

    sessionUI.ctx_RankName:SetText(GetAvARankName(gender, rank))
    ZO_CurrencyControl_SetSimpleCurrency(sessionUI.ctx_APH , CURT_ALLIANCE_POINTS, 0, currencyDisplayOptions, CURRENCY_SHOW_ALL)
    
    currencyDisplayOptions['font'] = "$(GAMEPAD_LIGHT_FONT)|20|soft-shadow-thin"
    currencyDisplayOptions['iconSize'] = 18
    ZO_CurrencyControl_SetSimpleCurrency(sessionUI.ctx_NextRankValue, CURT_ALLIANCE_POINTS, nextRankValue, currencyDisplayOptions, CURRENCY_SHOW_ALL)
    
    
    if rank < 50 then
        sessionUI.ctx_NextRankIcon:SetTexture(GetAvARankIcon(rank+1):gsub('%rankicon', 'rankicon64'))
        sessionUI.ctx_NextRankLabel:SetText(GetAvARankName(gender, rank+1))
        sessionUI.ctx_NextRankPerc:SetText(tostring(nextRankPerc)..'%')
        sessionUI.ctx_NextRankStatus:SetValue(nextRankPerc)
    else
        sessionUI.ctx_NextRankIcon:SetHidden(true)
        sessionUI.ctx_NextRankStatus:SetValue(100)
        sessionUI.ctx_NextRankPerc:SetText('')
        sessionUI.ctx_NextRankLabel:SetText('')
    end

end

function Panel.UpdateSessionBreakdown()

    local session = APM.session
    local total = session.total
    local currencyDisplayOptions = {
        showTooltips = false,
        useShortFormat = false,
        font = "$(GAMEPAD_LIGHT_FONT)|20|soft-shadow-thin",
        iconSide = RIGHT,
        iconSize = 18,
    }

    local sessionOrder = {
        { type = 'Combat', value = session.combat },
        { type = 'Repairs', value = session.repairs },
        { type = 'Defence', value = session.defence },
        { type = 'Capture', value = session.capture },
        { type = 'Quests', value = session.quests },
        { type = 'Resurrections', value = session.resurrections }
    }

    table.sort(sessionOrder,function(a,b) return a.value > b.value end)

    for i, catgeory in ipairs(sessionOrder) do
        local label = sessionOrder[i].type
        local row = sessionUI.types[label]
        local rawValue = sessionOrder[i].value
        local perc = string.format("%.0f",tostring(100/total * rawValue))

        row.ctx_Status:SetValue(tonumber(perc))

        if perc == 0 and rawValue > 0 then
            perc = '< 1%'
        else
            perc = tostring(perc)..'%'
        end

        row.ctx_StatusPerc:SetText(perc)
        ZO_CurrencyControl_SetSimpleCurrency(row.ctx_StatusAP, CURT_ALLIANCE_POINTS, rawValue, currencyDisplayOptions, CURRENCY_SHOW_ALL)

        row.ctx_Label:ClearAnchors()

        if i == 1 then
            row.ctx_Label:SetAnchor(TOPLEFT, sessionUI.ctx_NextRankStatus, BOTTOMLEFT, 0, 160)
        else
            label = sessionOrder[i-1].type
            prevRow = sessionUI.types[label]
            row.ctx_Label:SetAnchor(TOPLEFT, prevRow.ctx_Status, BOTTOMLEFT, 0, 80)
        end

        if i == 6 then
            APMeterPanelSessionAreaFooterWeight:ClearAnchors()
            APMeterPanelSessionAreaFooterWeight:SetAnchor(TOPLEFT, row.ctx_Status, BOTTOMLEFT, 0, 80)
        end
    end

end

function Panel.UpdateTicklist(keepId, tickReward, status)

    local categoryType = GetKeepType(keepId)

    if categoryType == 0 then return end

    local category = ticklist[categoryType]
    local owningAlliance = GetKeepAlliance(keepId,BGQUERY_ASSIGNED_AND_LOCAL)

    local function resetCategoryToUnassigned()
        category.container:SetAlpha(0.6)
        category.container:GetNamedChild('BG'):SetHidden(false)
        category.container:GetNamedChild('BG_Active'):SetHidden(true)
        category.container:GetNamedChild('Name'):SetHidden(true)
        category.container:GetNamedChild('Inactive'):SetHidden(false)
        category.container:GetNamedChild('TimeAgo'):SetText('')

        if categoryType == 'resource' then
            category.container:GetNamedChild('Icon'):SetTexture( string.format(ticklistIcons['mine'],'neutral') )
            category.container:GetNamedChild('IconLumbermill'):SetHidden(false)
            category.container:GetNamedChild('IconFarm'):SetHidden(false)
        else
            category.container:GetNamedChild('Icon'):SetTexture( string.format(ticklistIcons[categoryType],'neutral') )
        end
    end

    local function setCategoryToActive()
        local name = category.container:GetNamedChild('Name')
        category.container:SetAlpha(1)
        category.container:GetNamedChild('BG'):SetHidden(true)
        category.container:GetNamedChild('BG_Active'):SetHidden(false)
        name:SetHidden(false)
        category.container:GetNamedChild('Inactive'):SetHidden(true)
        name:SetText(GetKeepName(keepId))

        if categoryType == 'resource' then
            local resourceType = GetAVAResourceType(keepId)
            category.container:GetNamedChild('Icon'):SetTexture( string.format(ticklistIcons[resourceType],({'aldmeri','ebonheart','daggerfall'})[playerAlliance]) )
            category.container:GetNamedChild('IconLumbermill'):SetHidden(true)
            category.container:GetNamedChild('IconFarm'):SetHidden(true)
        else
            category.container:GetNamedChild('Icon'):SetTexture( string.format(ticklistIcons[categoryType], ({'aldmeri','ebonheart','daggerfall'})[playerAlliance]) )
        end
    end

    if playerAlliance ~= owningAlliance then
        if category then
            category.active = false
            resetCategoryToUnassigned()
        end
        return
    end

    if not status then
        if not category.active and not tickReward then
            category.timeAgo = GetTimeStamp()
            category.id = keepId
            category.active = true
            setCategoryToActive()
        elseif category.active and category.id ~= keepId then
            category.timeAgo = GetTimeStamp()
            category.id = keepId
            setCategoryToActive()
        elseif category.active and tickReward then
            category.active = false
            resetCategoryToUnassigned()
        end
    end
   
end

function Panel.UpdateBufflist( data )

    local row = buffItems[data.category]

    if data.active then
        
        row.ctx_icon:SetTexture(data.icon)
        row.ctx_icon:SetHidden(false)
        row.ctx_iconWarning:SetHidden(true)
        row.ctx_name:SetText(data.name)
        row.ctx_boost:SetText('+'..data.boost..'%')
        row.ctx_description:SetText(data.description)
        row.ctx_defaultDescription:SetHidden(true)

        if data.itemLink then
            row.ctx_name:SetText(data.itemLink)
            row.ctx_description:SetText(data.name)
        end

        row.ctx_timer:SetValue(math.floor(100/data.duration * data.timeRemaining))
        row.ctx_duration:SetText(ZO_FormatTime(data.timeRemaining, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS))

        row.active = true
        row.endTime = data.endTime
        row.duration = data.duration
        row.timeRemaining = data.timeRemaining

    else
        row.active = false
        if row.duration then row.duration = nil end
        if row.timeRemaining then row.timeRemaining = nil end
        if row.endTime then row.endTime = nil end

        row.ctx_icon:SetHidden(true)
        row.ctx_iconWarning:SetHidden(false)
        row.ctx_name:SetText('')
        row.ctx_boost:SetText('')
        row.ctx_description:SetText('')
        row.ctx_defaultDescription:SetHidden(false)
        row.ctx_timer:SetValue(0)
        row.ctx_duration:SetText('')
    end

end

function Panel.Show()
    EVENT_MANAGER:RegisterForUpdate('APMeterUpdate', 500, OnUpdatePanel)
    Panel.display = true
    Panel.fragment:Show()
    Panel.fragment:Refresh()
end

function Panel.Hide()
    EVENT_MANAGER:UnregisterForUpdate('APMeterUpdate')
    Panel.display = false
    Panel.fragment:Hide()
    Panel.fragment:Refresh()

    for i,category in ipairs({ 'cake', 'delve', 'event' }) do
        buffItems[category].ctx_duration:SetText('')
    end
    
    for i,category in ipairs({ 'keep', 'resource', 'town', 'outpost' }) do
        ticklist[category].container:GetNamedChild('TimeAgo'):SetText('')
    end

    sessionUI.ctx_Time:SetText('')
end

function Panel.Toggle()
    if Panel.fragment:IsHidden() then
        Panel.Show()
    else
        Panel.Hide()
    end
end

function Panel.Initialize()

    local container = APMeterPanel

    Panel.fragment = ZO_HUDFadeSceneFragment:New(container, nil, 0)
    Panel.fragment:SetConditional(function()
        return Panel.display
    end)
	HUD_SCENE:AddFragment(Panel.fragment)
	HUD_UI_SCENE:AddFragment(Panel.fragment)

    local panelSettings = APM.db.panel
    local location = panelSettings.location

    container:SetHandler('OnMoveStop', function(control)
        location.x = control:GetLeft()
        location.y = control:GetTop()
    end)

    if location.x ~= 0 and location.y ~= 0 then
        container:ClearAnchors()
        container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, location.x, location.y)
    end

    local UI = {
        session = {
            button = GetControl(container, 'SessionButtonLabel'),
            container = GetControl(container, 'Session')
        },
        ticklist = {
            button = GetControl(container, 'TicklistButtonLabel'),
            container = GetControl(container, 'Ticklist')
        },
        buffs = {
            button = GetControl(container, 'BuffsButtonLabel'),
            container = GetControl(container, 'Buffs')
        }
    }

    UI.session.alphaAnimation = ZO_AlphaAnimation:New(UI.session.container)
    UI.session.alphaAnimation:SetMinMaxAlpha(0, 1)

    UI.ticklist.alphaAnimation = ZO_AlphaAnimation:New(UI.ticklist.container)
    UI.ticklist.alphaAnimation:SetMinMaxAlpha(0, 1)

    UI.buffs.alphaAnimation = ZO_AlphaAnimation:New(UI.buffs.container)
    UI.buffs.alphaAnimation:SetMinMaxAlpha(0, 1)

    UI.current = 'session'

    local function MenuStateOnChange( label )

        local next = UI[label]
        local previous = UI[UI.current]

        previous.alphaAnimation:FadeOut(0, 200, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA, function()
            previous.container:SetHidden(true)
        end)
        previous.button:SetAlpha(0.3)
        previous.button:GetNamedChild('Arrow'):SetTexture('/esoui/art/miscellaneous/gamepad/spinner_arrow_right_disabled.dds')

        next.container:SetHidden(false)
        next.alphaAnimation:FadeIn(0, 300)
        next.button:SetAlpha(1)
        next.button:GetNamedChild('Arrow'):SetTexture('/esoui/art/miscellaneous/gamepad/spinner_arrow_right_up.dds')

        UI.current = label

    end

    UI.session.button:SetHandler("OnMouseUp", function() MenuStateOnChange('session') end)
    UI.ticklist.button:SetHandler("OnMouseUp", function() MenuStateOnChange('ticklist') end)
    UI.buffs.button:SetHandler("OnMouseUp", function() MenuStateOnChange('buffs') end)

    MakeScrollerAreas()
    SetGoalUI()
end

-- --------------------
-- Attach Listeners
-- --------------------
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_KEEP_ALLIANCE_OWNER_CHANGED, OnKeepChange)

-- --------------------
-- Dialogs
-- --------------------
function Panel.AddGoalDialog_OnInitialized( self )

	ZO_Dialogs_RegisterCustomDialog( "ADD_APM_GOAL", {
        customControl = self,
        title = {
            text = "Add AP Goal",
        },
        setup = function()
            GetControl(self, 'EditBox'):SetText('0')
        end,
        buttons = {
            [ 1 ] = {
                control = GetControl( self, "Save" ),
                text = SI_SAVE,
                callback = function(dialog)
                    local value = GetControl(dialog, 'EditBox'):GetText()

                    if value ~= '' and tonumber(value) > 0 then
                        AddGoal( value )
                    end
                end,
            },

            [ 2 ] = {
                control = GetControl( self, "Cancel" ),
                text = SI_DIALOG_CANCEL
            }
        }
    })

end

APM.Panel = Panel