DsRAutoINVUI = DsRAutoINVUI or {}
DsRAutoINVUI.fragmentOptions = {}
local ui = DsRAutoINVUI.fragmentOptions
local wm = WINDOW_MANAGER

function DsRAutoINVUI:CreateOptionFragment()
    ui.main = wm:CreateControl("DsRAutoINVOptions", DsRAI_SmallGroupList, CT_CONTROL) --wm:CreateTopLevelWindow("DsRAutoINVOptionsFragment")
    ui.scroll = ui.main -- For using LAM controls
    ui.main:SetAnchor(TOPRIGHT, ZO_GroupList, TOPRIGHT, -40, 45)
    ui.main:SetWidth(340)
    ui.panel = ui.main
    ui.panel.data = {}

    ui.enabled = LAMCreateControl.checkbox(ui, {
        type = "checkbox",
        name = GetString(SI_DsRAI_OPT_ENABLED),
        tooltip = GetString(SI_DsRAI_TT_ENABLED),
        getFunc = function() return DsRAutoINV.listening end,
        setFunc = function(val)
            if val then DsRAutoINV.startListening() else DsRAutoINV.disable() end
        end,
    })
    ui.enabled.checkbox:SetAnchor(LEFT, ui.enabled.container, RIGHT, -25, 0)
    ui.enabled:SetAnchor(TOPLEFT, ZO_GroupList, TOPLEFT, 30, -35)

    ui.text = LAMCreateControl.editbox(ui, {
        type = "editbox",
        name = GetString(SI_DsRAI_OPT_STRING),
        tooltip = GetString(SI_DsRAI_TT_STRING),
        getFunc = function() return DsRAutoINV.cfg.watchStr end,
        setFunc = function(val) DsRAutoINV.cfg.watchStr = string.lower(val) end,
    })
    ui.text.container:SetWidth(140)
    ui.text:SetAnchor(TOPLEFT, ZO_GroupList, TOPLEFT, 30, 0)

    ui.max = LAMCreateControl.slider(ui, {
        type = "slider",
        name = GetString(SI_DsRAI_OPT_MAX_SIZE),
        tooltip = GetString(SI_DsRAI_TT_MAX_SIZE),
        min = 4,
        max = 12,
        getFunc = function() return DsRAutoINV.cfg.maxSize end,
        setFunc = function(val) DsRAutoINV.cfg.maxSize = val end,
        default = 12,
    })
    ui.max:SetAnchor(TOPLEFT,  ZO_GroupList, TOPLEFT, 30, 45)

    ui.restart = LAMCreateControl.checkbox(ui, {
        type = "checkbox",
        name = GetString(SI_DsRAI_OPT_RESTART),
        tooltip = GetString(SI_DsRAI_TT_RESTART),
        getFunc = function() return DsRAutoINV.cfg.restart end,
        setFunc = function(val) DsRAutoINV.cfg.restart = val end,
    })
    ui.restart.checkbox:SetAnchor(LEFT, ui.restart.container, RIGHT, -25, 0)
    ui.restart:SetAnchor(TOPRIGHT, ZO_GroupList, TOPRIGHT, -40, -35)

    ui.cyr = LAMCreateControl.checkbox(ui, {
        type = "checkbox",
        name = GetString(SI_DsRAI_OPT_CYRCHECK),
        tooltip = GetString(SI_DsRAI_TT_CYRCHECK),
        getFunc = function() return DsRAutoINV.cfg.cyrCheck end,
        setFunc = function(val) DsRAutoINV.cfg.cyrCheck = val end,
    })
    ui.cyr.checkbox:SetAnchor(LEFT, ui.cyr.container, RIGHT, -25, 0)
    ui.cyr:SetAnchor(TOPLEFT, ui.restart, BOTTOMLEFT, 0, 10)

    ui.kick = LAMCreateControl.checkbox(ui, {
        type = "checkbox",
        name = GetString(SI_DsRAI_OPT_KICK),
        tooltip = GetString(SI_DsRAI_TT_KICK),
        getFunc = function() return DsRAutoINV.cfg.autoKick end,
        setFunc = function(val) DsRAutoINV.cfg.autoKick = val end,
    })
    ui.kick.checkbox:SetAnchor(LEFT, ui.kick.container, RIGHT, -25, 0)
    ui.kick:SetAnchor(TOPLEFT, ui.cyr, BOTTOMLEFT, 0, 10)

    ui.kickTime = LAMCreateControl.slider(ui, {
        type = "slider",
        name = GetString(SI_DsRAI_OPT_KICK_TIME),
        tooltip = GetString(SI_DsRAI_TT_KICK_TIME),
        min = 5,
        max = 600,
        getFunc = function() return DsRAutoINV.cfg.kickDelay end,
        setFunc = function(val) DsRAutoINV.cfg.kickDelay = val end,
        default = 400,
    })
    ui.kickTime:SetAnchor(TOPLEFT, ui.kick, BOTTOMLEFT, 0, 10)

    ui.encounter = LAMCreateControl.checkbox(ui, {
        type    = "checkbox",
        name    = "|c35fc38" .. GetString(SI_DsRAI_ENCOUNTER_ON_OFF),
        tooltip = GetString(SI_DsRAI_ENCOUNTER_ON_OFF_TP),
        getFunc = function() return DsRAutoINV.cfg.EncounterOnOff end,
        setFunc = function(val) 
            DsRAutoINV.cfg.EncounterOnOff = val
            DsRAutoINV.EncounterAndTrialCheck(val)
        end,
    })
    ui.encounter.checkbox:SetAnchor(LEFT, ui.encounter.container, RIGHT, -220, 25)
    ui.encounter:SetAnchor(TOPLEFT,  ZO_GroupList, TOPLEFT, 370, -30)

    ui.encounterQuest = LAMCreateControl.checkbox(ui, {
        type    = "checkbox",
        name    = "|c35fc38" .. GetString(SI_DsRAI_ENCOUNTER_START),
        tooltip = GetString(SI_DsRAI_ENCOUNTER_START_TP),
        getFunc = function() return DsRAutoINV.cfg.EncounterQuest end,
        setFunc = function(val) DsRAutoINV.cfg.EncounterQuest = val end,
    })
    ui.encounterQuest.checkbox:SetAnchor(LEFT, ui.encounterQuest.container, RIGHT, -220, 25)
    ui.encounterQuest:SetAnchor(TOPLEFT,  ZO_GroupList, TOPLEFT, 370, 30)
end
