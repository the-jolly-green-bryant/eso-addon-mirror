gsse.config = {}

function gsse.config.create()
    local lam2 = LibStub:GetLibrary("LibAddonMenu-2.0")
    
    local panelIdentifier = "GSSE"
    
    local settingsPanel = {
        type = "panel",
        name = gsse.lang.core.addonName,
        displayName = gsse.lang.core.coloredAddonName,
        author = gsse.Author,
        version = gsse.Version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    local settingsMenu = {
        [1] = {
            type = "header",
            name = gsse.lang.config.gen_hdr,
            width = "full"
        },
        [2] = {
            type = "checkbox",
            name = gsse.lang.config.gen_dbg_lbl,
            tooltip = gsse.lang.config.gen_dbg_tip,
            getFunc = gsse.config.getDebug,
            setFunc = gsse.config.setDebug,
            width = "full",
            warning = gsse.lang.config.gen_dbg_warn,
            default = gsse.defaults.showdebug,
        },
        [3] = {
            type = "slider",
            name = gsse.lang.config_filt_markdown_lbl,
            tooltip = gsse.lang.config_filt_markdown_tip,
            min = 0,
            max = 99,
            step = 1,
            getFunc = gsse.config.getMarkdown,
            setFunc = gsse.config.setMarkdown,
            default = gsse.defaults.undercutPerc,
        },
        [4] = {
            type = "dropdown",
            name = gsse.lang.config.lang_lbl,
            tooltip = gsse.lang.config.lang_tip,
            choices = gsse.language_options,
            getFunc = gsse.config.getLang,
            setFunc = gsse.config.setLang,
            warning = gsse.lang.config.lang_warn,
            default = gsse.defaults.language
        },
        [5] = {
            type = "header",
            name = gsse.lang.config.tooltip_hdr,
            width = "full"
        },
        [6] = {
            type = "description",
            text = gsse.lang.config.tooltip_desc,
            width = "full"
        },
        [7] = {
            type = "checkbox",
            name = gsse.lang.config.tooltip_session_lbl,
            tooltip = gsse.lang.config.tooltip_session_tip,
            getFunc = gsse.config.getSess,
            setFunc = gsse.config.setSess,
            width = "full",
            default = gsse.defaults.tooltips.session,
        },
        [8] = {
            type = "checkbox",
            name = gsse.lang.config.tooltip_history_lbl,
            tooltip = gsse.lang.config.tooltip_history_tip,
            getFunc = gsse.config.getHist,
            setFunc = gsse.config.setHist,
            width = "full",
            default = gsse.defaults.tooltips.history,
        },
        [9] = {
            type = "checkbox",
            name = gsse.lang.config.tooltip_recom_lbl,
            tooltip = gsse.lang.config.tooltip_recom_tip,
            getFunc = gsse.config.getRecom,
            setFunc = gsse.config.setRecom,
            width = "full",
            default = gsse.defaults.tooltips.recommend,
        },
    }
    
    lam2:RegisterAddonPanel(panelIdentifier, settingsPanel)
    lam2:RegisterOptionControls(panelIdentifier, settingsMenu)
end

----Dummy
function gsse.config.getDummy()
end
function gsse.config.setDummy(value)
end

---- GS Update lang
function  gsse.config.getLang()
    return gsse.data.language
end

function gsse.config.setLang(value)
    gsse.data.language=value
end

---- Mark Down
function  gsse.config.getMarkdown()
    return gsse.data.undercutPerc
end

function gsse.config.setMarkdown(value)
    gsse.data.undercutPerc=value
end

---- Manage debug
function gsse.config.getDebug()
    return gsse.data.showdebug
end

function gsse.config.setDebug(value)
    gsse.data.showdebug=value
end

---- Manage Session Tooltip
function gsse.config.getSess()
    return gsse.data.tooltips.session
end

function gsse.config.setSess(value)
    gsse.data.tooltips.session=value
end

---- Manage History Tooltip
function gsse.config.getHist()
    return gsse.data.tooltips.history
end

function gsse.config.setHist(value)
    gsse.data.tooltips.history=value
end

---- Manage Recommendation Tooltip
function gsse.config.getRecom()
    return gsse.data.tooltips.recommend
end

function gsse.config.setRecom(value)
    gsse.data.tooltips.recommend=value
end
