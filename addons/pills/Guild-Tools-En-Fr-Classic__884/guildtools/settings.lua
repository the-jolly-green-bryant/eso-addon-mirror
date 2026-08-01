
guildtools.config={}

--guildtools.config.panid=0;

local class_stub="guildtools_config"

guildtools.config.lam = LibStub("LibAddonMenu-2.0")
--guildtools.config.panid =guildtools.config.lam:CreateControlPanel(class_stub, "|c00ff00Guild Tools|r")

guildtools.config.alertLabels={"None","In Chat","In HUD", "In HUD and Chat"}
guildtools.config.alertValues={["None"]=0,["In Chat"]=1,["In HUD"]=2, ["In HUD and Chat"]=3}

function guildtools.config.create()
	---- Create Sub Menus
	
	
	--guildtools.config.panid=guildtools.config.lam:AddSubMenu(guildtools.config.panid, class_stub.."_mnu_guilds", "Guilds", "Configure guild specific settings")
	--guildtools.config.mnuAdverts=guildtools.config.lam:AddSubMenu(guildtools.config.panid, class_stub.."_mnu_adverts", "Adverts", "Configure guild adverts")
	--guildtools.config.mnuMail=guildtools.config.lam:AddSubMenu(guildtools.config.panid, class_stub.."_mnu_mail", "Adverts", "Configure guild mail")
	--guildtools.config.mnuNotif=guildtools.config.lam:AddSubMenu(guildtools.config.panid, class_stub.."_mnu_notif", "HUD", "Configure HUD")
	
	----Reset Values for lang
	guildtools.config.alertLabels=guildtools.lang.config.alertLabels
	guildtools.config.alertValues=guildtools.lang.config.alertValues
	local adv_instr=guildtools.lang.config.advert_instr
	
	----General Config
	--guildtools.config.mnuGeneral=guildtools.config.lam:AddSubMenu(guildtools.config.panid, class_stub.."_mnu_general", guildtools.lang.config.gen_hdr, guildtools.lang.config.gen_hdr)

	local panelData = {
         type = "panel",
         name = "guildtools",
    }
	guildtools.config.lam:RegisterAddonPanel("guildtools_Panel", panelData)
	local optionsData = {
		--guildtools.config.lam:AddHeader(guildtools.config.panid, class_stub.."_general", guildtools.lang.config.gen_hdr)
        [1] = {
        	type = "header",
        	name = guildtools.lang.config.gen_hdr,
        	reference = class_stub.."_general",
    	},
    	--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_general_debug",guildtools.lang.config.gen_dbg_lbl, guildtools.lang.config.gen_dbg_tip, guildtools.config.getDebug, guildtools.config.setDebug, true, guildtools.lang.config.gen_dbg_warn)
    	[2] = {
    		type = "checkbox",
    		name = guildtools.lang.config.gen_dbg_lbl,
    		tooltip = guildtools.lang.config.gen_dbg_tip,
    		getFunc = guildtools.config.getDebug,
    		setFunc = guildtools.config.setDebug,
    		warn = guildtools.lang.config.gen_dbg_warn,
    		disabled = true,
    		reference = class_stub.."_general_debug",
    	},
    	--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_general_statusshow", guildtools.lang.config.gen_widget_lbl, guildtools.lang.config.gen_widget_tip, guildtools.config.getStatusShow, guildtools.config.setStatusShow, false, "")
    	[3] = {
    		type = "checkbox",
    		name = guildtools.lang.config.gen_widget_lbl,
    		tooltip = guildtools.lang.config.gen_widget_tip,
    		getFunc = guildtools.config.getStatusShow,
    		setFunc = guildtools.config.setStatusShow,
    		warn = "",
    		default = false,
    		reference = class_stub.."_general_statusshow",
    	},
    	--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_general_statuslock", guildtools.lang.config.gen_widgetlock_lbl, guildtools.lang.config.gen_widgetlock_tip, guildtools.config.getStatusLock, guildtools.config.setStatusLock, false, "")
    	[4] = {
    		type = "checkbox",
    		name = guildtools.lang.config.gen_widgetlock_lbl,
    		tooltip = guildtools.lang.config.gen_widgetlock_tip,
    		getFunc = guildtools.config.getStatusLock,
    		setFunc = guildtools.config.setStatusLock,
    		warn = "",
    		default = false,
    		reference = class_stub.."_general_statuslock",
    	},
    	--Alerts
	    --guildtools.config.lam:AddHeader(guildtools.config.panid, class_stub.."_alerts", guildtools.lang.config.msgs_hdr)
    	[5] = {
        	type = "header",
        	name = guildtools.lang.config.msgs_hdr,
        	reference = class_stub.."_alerts",
    	},
    	--guildtools.config.lam:AddDescription(guildtools.config.panid,  class_stub.."_alert_level_desc1", "Guild 1")
		--guildtools.config.lam:AddDropdown(guildtools.config.panid, class_stub.."_alert_level1", guildtools.lang.config.gen_galert_lbl, "", guildtools.config.alertLabels ,function() return guildtools.config.getAlertLevel(1) end,function(value) guildtools.config.setAlertLevel(1, value) end, false,"" )
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_motd1", guildtools.lang.config.gen_gmotd_lbl, guildtools.lang.config.gen_gmotd_tip, function() return guildtools.config.getmotd(1) end, function(value) guildtools.config.setmotd(1, value) end, false, "")
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_levela1", guildtools.lang.config.gen_glevel_lbl, guildtools.lang.config.gen_glevel_tip, function() return guildtools.config.getlevelalert(1) end, function(value) guildtools.config.setlevelalert(1, value) end, false, "")
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_status1", guildtools.lang.config.gen_gstatus_lbl, guildtools.lang.config.gen_gstatus_tip, function() return guildtools.config.getstatus(1) end, function(value) guildtools.config.setstatus(1, value) end, false, "")
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_state1", guildtools.lang.config.gen_gstate_lbl, guildtools.lang.config.gen_gstate_tip, function() return guildtools.config.getstate(1) end, function(value) guildtools.config.setstate(1, value) end, false, "")
		[6] = {
			type = "description",
			text = "Guild 1",
			reference = class_stub.."_alert_level_desc1",
		},
		[7] = {
			type = "dropdown",
			name = guildtools.lang.config.gen_galert_lbl,
			tooltip = "",
			choices = guildtools.config.alertLabels,
			getFunc = function() return guildtools.config.getAlertLevel(1) end,
			setFunc = function(value) guildtools.config.setAlertLevel(1, value) end,
			disabled = false,
			warning = "",
			reference = class_stub.."_alert_level1",
		},
		[8] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_gmotd_lbl,
    		tooltip = guildtools.lang.config.gen_gmotd_tip,
    		getFunc = function() return guildtools.config.getmotd(1) end,
    		setFunc = function(value) guildtools.config.setmotd(1, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_motd1",
		},
		[9] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_glevel_lbl,
    		tooltip = guildtools.lang.config.gen_glevel_tip,
    		getFunc = function() return guildtools.config.getlevelalert(1) end,
    		setFunc = function(value) guildtools.config.setlevelalert(1, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_levela1",
		},
		[10] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_gstatus_lbl,
    		tooltip = guildtools.lang.config.gen_gstatus_tip,
    		getFunc = function() return guildtools.config.getstatus(1) end,
    		setFunc = function(value) guildtools.config.setstatus(1, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_status1",
		},
		[11] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_gstate_lbl,
    		tooltip = guildtools.lang.config.gen_gstate_tip,
    		getFunc = function() return guildtools.config.getstate(1) end,
    		setFunc = function(value) guildtools.config.setstate(1, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_state1",
		},
		--guildtools.config.lam:AddDescription(guildtools.config.panid,  class_stub.."_alert_level_desc2", "Guild 2")
		--guildtools.config.lam:AddDropdown(guildtools.config.panid, class_stub.."_alert_level2", guildtools.lang.config.gen_galert_lbl, "", guildtools.config.alertLabels ,function() return guildtools.config.getAlertLevel(2) end,function(value) guildtools.config.setAlertLevel(2, value) end, false,"" )
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_motd2", guildtools.lang.config.gen_gmotd_lbl, guildtools.lang.config.gen_gmotd_tip, function() return guildtools.config.getmotd(2) end, function(value) guildtools.config.setmotd(2, value) end, false, "")
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_levela2", guildtools.lang.config.gen_glevel_lbl, guildtools.lang.config.gen_glevel_tip, function() return guildtools.config.getlevelalert(2) end, function(value) guildtools.config.setlevelalert(2, value) end, false, "")
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_status2", guildtools.lang.config.gen_gstatus_lbl, guildtools.lang.config.gen_gstatus_tip, function() return guildtools.config.getstatus(2) end, function(value) guildtools.config.setstatus(2, value) end, false, "")
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_state2", guildtools.lang.config.gen_gstate_lbl, guildtools.lang.config.gen_gstate_tip, function() return guildtools.config.getstate(2) end, function(value) guildtools.config.setstate(2, value) end, false, "")
		[12] = {
			type = "description",
			text = "Guild 2",
			reference = class_stub.."_alert_level_desc2",
		},
		[13] = {
			type = "dropdown",
			name = guildtools.lang.config.gen_galert_lbl,
			tooltip = "",
			choices = guildtools.config.alertLabels,
			getFunc = function() return guildtools.config.getAlertLevel(2) end,
			setFunc = function(value) guildtools.config.setAlertLevel(2, value) end,
			disabled = false,
			warning = "",
			reference = class_stub.."_alert_level2",
		},
		[14] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_gmotd_lbl,
    		tooltip = guildtools.lang.config.gen_gmotd_tip,
    		getFunc = function() return guildtools.config.getmotd(2) end,
    		setFunc = function(value) guildtools.config.setmotd(2, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_motd2",
		},
		[15] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_glevel_lbl,
    		tooltip = guildtools.lang.config.gen_glevel_tip,
    		getFunc = function() return guildtools.config.getlevelalert(2) end,
    		setFunc = function(value) guildtools.config.setlevelalert(2, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_levela2",
		},
		[16] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_gstatus_lbl,
    		tooltip = guildtools.lang.config.gen_gstatus_tip,
    		getFunc = function() return guildtools.config.getstatus(2) end,
    		setFunc = function(value) guildtools.config.setstatus(2, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_status2",
		},
		[17] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_gstate_lbl,
    		tooltip = guildtools.lang.config.gen_gstate_tip,
    		getFunc = function() return guildtools.config.getstate(2) end,
    		setFunc = function(value) guildtools.config.setstate(2, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_state2",
		},
		--guildtools.config.lam:AddDescription(guildtools.config.panid,  class_stub.."_alert_level_desc3", "Guild 3")
		--guildtools.config.lam:AddDropdown(guildtools.config.panid, class_stub.."_alert_level3", guildtools.lang.config.gen_galert_lbl, "", guildtools.config.alertLabels ,function() return guildtools.config.getAlertLevel(3) end,function(value) guildtools.config.setAlertLevel(3, value) end, false,"" )
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_motd3", guildtools.lang.config.gen_gmotd_lbl, guildtools.lang.config.gen_gmotd_tip, function() return guildtools.config.getmotd(3) end, function(value) guildtools.config.setmotd(3, value) end, false, "")
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_levela3", guildtools.lang.config.gen_glevel_lbl, guildtools.lang.config.gen_glevel_tip, function() return guildtools.config.getlevelalert(3) end, function(value) guildtools.config.setlevelalert(3, value) end, false, "")
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_status3", guildtools.lang.config.gen_gstatus_lbl, guildtools.lang.config.gen_gstatus_tip, function() return guildtools.config.getstatus(3) end, function(value) guildtools.config.setstatus(3, value) end, false, "")
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_state3", guildtools.lang.config.gen_gstate_lbl, guildtools.lang.config.gen_gstate_tip, function() return guildtools.config.getstate(3) end, function(value) guildtools.config.setstate(3, value) end, false, "")
		[18] = {
			type = "description",
			text = "Guild 3",
			reference = class_stub.."_alert_level_desc3",
		},
		[19] = {
			type = "dropdown",
			name = guildtools.lang.config.gen_galert_lbl,
			tooltip = "",
			choices = guildtools.config.alertLabels,
			getFunc = function() return guildtools.config.getAlertLevel(3) end,
			setFunc = function(value) guildtools.config.setAlertLevel(3, value) end,
			disabled = false,
			warning = "",
			reference = class_stub.."_alert_level3",
		},
		[20] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_gmotd_lbl,
    		tooltip = guildtools.lang.config.gen_gmotd_tip,
    		getFunc = function() return guildtools.config.getmotd(3) end,
    		setFunc = function(value) guildtools.config.setmotd(3, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_motd3",
		},
		[21] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_glevel_lbl,
    		tooltip = guildtools.lang.config.gen_glevel_tip,
    		getFunc = function() return guildtools.config.getlevelalert(3) end,
    		setFunc = function(value) guildtools.config.setlevelalert(3, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_levela3",
		},
		[22] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_gstatus_lbl,
    		tooltip = guildtools.lang.config.gen_gstatus_tip,
    		getFunc = function() return guildtools.config.getstatus(3) end,
    		setFunc = function(value) guildtools.config.setstatus(3, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_status3",
		},
		[23] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_gstate_lbl,
    		tooltip = guildtools.lang.config.gen_gstate_tip,
    		getFunc = function() return guildtools.config.getstate(3) end,
    		setFunc = function(value) guildtools.config.setstate(3, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_state3",
		},
	    --guildtools.config.lam:AddDescription(guildtools.config.panid,  class_stub.."_alert_level_desc4", "Guild 4")	
		--guildtools.config.lam:AddDropdown(guildtools.config.panid, class_stub.."_alert_level4", guildtools.lang.config.gen_galert_lbl, "", guildtools.config.alertLabels ,function() return guildtools.config.getAlertLevel(4) end,function(value) guildtools.config.setAlertLevel(4, value) end, false,"" )
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_motd4", guildtools.lang.config.gen_gmotd_lbl, guildtools.lang.config.gen_gmotd_tip, function() return guildtools.config.getmotd(4) end, function(value) guildtools.config.setmotd(4, value) end, false, "")
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_levela4", guildtools.lang.config.gen_glevel_lbl, guildtools.lang.config.gen_glevel_tip, function() return guildtools.config.getlevelalert(4) end, function(value) guildtools.config.setlevelalert(4, value) end, false, "")
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_status4", guildtools.lang.config.gen_gstatus_lbl, guildtools.lang.config.gen_gstatus_tip, function() return guildtools.config.getstatus(4) end, function(value) guildtools.config.setstatus(4, value) end, false, "")
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_state4", guildtools.lang.config.gen_gstate_lbl, guildtools.lang.config.gen_gstate_tip, function() return guildtools.config.getstate(4) end, function(value) guildtools.config.setstate(4, value) end, false, "")
		[24] = {
			type = "description",
			text = "Guild 4",
			reference = class_stub.."_alert_level_desc4",
		},
		[25] = {
			type = "dropdown",
			name = guildtools.lang.config.gen_galert_lbl,
			tooltip = "",
			choices = guildtools.config.alertLabels,
			getFunc = function() return guildtools.config.getAlertLevel(4) end,
			setFunc = function(value) guildtools.config.setAlertLevel(4, value) end,
			disabled = false,
			warning = "",
			reference = class_stub.."_alert_level4",
		},
		[26] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_gmotd_lbl,
    		tooltip = guildtools.lang.config.gen_gmotd_tip,
    		getFunc = function() return guildtools.config.getmotd(4) end,
    		setFunc = function(value) guildtools.config.setmotd(4, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_motd4",
		},
		[27] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_glevel_lbl,
    		tooltip = guildtools.lang.config.gen_glevel_tip,
    		getFunc = function() return guildtools.config.getlevelalert(4) end,
    		setFunc = function(value) guildtools.config.setlevelalert(4, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_levela4",
		},
		[28] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_gstatus_lbl,
    		tooltip = guildtools.lang.config.gen_gstatus_tip,
    		getFunc = function() return guildtools.config.getstatus(4) end,
    		setFunc = function(value) guildtools.config.setstatus(4, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_status4",
		},
		[29] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_gstate_lbl,
    		tooltip = guildtools.lang.config.gen_gstate_tip,
    		getFunc = function() return guildtools.config.getstate(4) end,
    		setFunc = function(value) guildtools.config.setstate(4, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_state4",
		},
		--guildtools.config.lam:AddDescription(guildtools.config.panid,  class_stub.."_alert_level_desc5", "Guild 5")
		--guildtools.config.lam:AddDropdown(guildtools.config.panid, class_stub.."_alert_level5", guildtools.lang.config.gen_galert_lbl, "", guildtools.config.alertLabels ,function() return guildtools.config.getAlertLevel(5) end,function(value) guildtools.config.setAlertLevel(5, value) end, false,"" )
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_motd5", guildtools.lang.config.gen_gmotd_lbl, guildtools.lang.config.gen_gmotd_tip, function() return guildtools.config.getmotd(5) end, function(value) guildtools.config.setmotd(5, value) end, false, "")
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_levela5", guildtools.lang.config.gen_glevel_lbl, guildtools.lang.config.gen_glevel_tip, function() return guildtools.config.getlevelalert(5) end, function(value) guildtools.config.setlevelalert(5, value) end, false, "")
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_status5", guildtools.lang.config.gen_gstatus_lbl, guildtools.lang.config.gen_gstatus_tip, function() return guildtools.config.getstatus(5) end, function(value) guildtools.config.setstatus(5, value) end, false, "")
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_alert_state5", guildtools.lang.config.gen_gstate_lbl, guildtools.lang.config.gen_gstate_tip, function() return guildtools.config.getstate(5) end, function(value) guildtools.config.setstate(5, value) end, false, "")
		[30] = {
			type = "description",
			text = "Guild 5",
			reference = class_stub.."_alert_level_desc5",
		},
		[31] = {
			type = "dropdown",
			name = guildtools.lang.config.gen_galert_lbl,
			tooltip = "",
			choices = guildtools.config.alertLabels,
			getFunc = function() return guildtools.config.getAlertLevel(5) end,
			setFunc = function(value) guildtools.config.setAlertLevel(5, value) end,
			disabled = false,
			warning = "",
			reference = class_stub.."_alert_level5",
		},
		[32] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_gmotd_lbl,
    		tooltip = guildtools.lang.config.gen_gmotd_tip,
    		getFunc = function() return guildtools.config.getmotd(5) end,
    		setFunc = function(value) guildtools.config.setmotd(5, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_motd5",
		},
		[33] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_glevel_lbl,
    		tooltip = guildtools.lang.config.gen_glevel_tip,
    		getFunc = function() return guildtools.config.getlevelalert(5) end,
    		setFunc = function(value) guildtools.config.setlevelalert(5, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_levela5",
		},
		[34] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_gstatus_lbl,
    		tooltip = guildtools.lang.config.gen_gstatus_tip,
    		getFunc = function() return guildtools.config.getstatus(5) end,
    		setFunc = function(value) guildtools.config.setstatus(5, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_status5",
		},
		[35] = {
			type = "checkbox",
    		name = guildtools.lang.config.gen_gstate_lbl,
    		tooltip = guildtools.lang.config.gen_gstate_tip,
    		getFunc = function() return guildtools.config.getstate(5) end,
    		setFunc = function(value) guildtools.config.setstate(5, value) end,
    		warn = "",
    		default = false,
    		reference = class_stub.."_alert_state5",
		},
		--guildtools.config.lam:AddSlider(guildtools.config.panid, class_stub.."_hudSpeed", guildtools.lang.config_hudspeeed_lbl, guildtools.lang.config_hudspeeed_tip, 1, 5, 1, guildtools.config.getHUDSpeed, guildtools.config.setHUDSpeed, true, guildtools.lang.config_hudspeeed_warn)
		[36] = {
			type = "slider",
			name = guildtools.lang.config_hudspeeed_lbl,
			tooltip = guildtools.lang.config_hudspeeed_tip,
			min = 1,
			max = 5,
			step = 1,
			getFunc = guildtools.config.getHUDSpeed,
			setFunc = guildtools.config.setHUDSpeed,
			disabled = true,
			warn = guildtools.lang.config_hudspeeed_warn,
			reference = class_stub.."_hudSpeed",
		},
		--guildtools.config.lam:AddHeader(guildtools.config.panid, class_stub.."_guild", guildtools.lang.config.advert_hdr)
    	[37] = {
        	type = "header",
        	name = guildtools.lang.config.advert_hdr,
        	reference = class_stub.."_guild",
    	},
    	--guildtools.config.lam:AddDescription(guildtools.config.panid,  class_stub.."_guild_intro", string.format(guildtools.lang.config.advert_desc,"none"))
    	[38] = {
    		type = "description",
    		text = string.format(guildtools.lang.config.advert_desc,"none"),
    		reference = class_stub.."_guild_intro",
    	},
    	--Guild Adverts
    	--guildtools.config.lam:AddEditBox(guildtools.config.panid, class_stub.."_advert1", string.format(guildtools.lang.config.advert_lbl,1), adv_instr, true, guildtools.config.getAdvert1,guildtools.config.setAdvert1,false,"")
		--guildtools.config.lam:AddEditBox(guildtools.config.panid, class_stub.."_advert2", string.format(guildtools.lang.config.advert_lbl,2),  adv_instr, true, guildtools.config.getAdvert2,guildtools.config.setAdvert2,false,"")
		--guildtools.config.lam:AddEditBox(guildtools.config.panid, class_stub.."_advert3", string.format(guildtools.lang.config.advert_lbl,3),  adv_instr, true, guildtools.config.getAdvert3,guildtools.config.setAdvert3,false,"")
		--guildtools.config.lam:AddEditBox(guildtools.config.panid, class_stub.."_advert4", string.format(guildtools.lang.config.advert_lbl,4),  adv_instr, true, guildtools.config.getAdvert4,guildtools.config.setAdvert4,false,"")
		--guildtools.config.lam:AddEditBox(guildtools.config.panid, class_stub.."_advert5", string.format(guildtools.lang.config.advert_lbl,5), adv_instr, true, guildtools.config.getAdvert5,guildtools.config.setAdvert5,false,"")
		[39] = {
			type = "editbox",
			name = string.format(guildtools.lang.config.advert_lbl,1),
			tooltip = adv_instr,
			isMultiline = true,
			getFunc = guildtools.config.getAdvert1,
			setFunc = guildtools.config.setAdvert1,
			disabled = false,
			warn = "",
			reference = class_stub.."_advert1",
		},
		[40] = {
			type = "editbox",
			name = string.format(guildtools.lang.config.advert_lbl,2),
			tooltip = adv_instr,
			isMultiline = true,
			getFunc = guildtools.config.getAdvert2,
			setFunc = guildtools.config.setAdvert2,
			disabled = false,
			warn = "",
			reference = class_stub.."_advert2",
		},
		[41] = {
			type = "editbox",
			name = string.format(guildtools.lang.config.advert_lbl,3),
			tooltip = adv_instr,
			isMultiline = true,
			getFunc = guildtools.config.getAdvert3,
			setFunc = guildtools.config.setAdvert3,
			disabled = false,
			warn = "",
			reference = class_stub.."_advert3",
		},
		[42] = {
			type = "editbox",
			name = string.format(guildtools.lang.config.advert_lbl,4),
			tooltip = adv_instr,
			isMultiline = true,
			getFunc = guildtools.config.getAdvert4,
			setFunc = guildtools.config.setAdvert4,
			disabled = false,
			warn = "",
			reference = class_stub.."_advert4",
		},
		[43] = {
			type = "editbox",
			name = string.format(guildtools.lang.config.advert_lbl,5),
			tooltip = adv_instr,
			isMultiline = true,
			getFunc = guildtools.config.getAdvert5,
			setFunc = guildtools.config.setAdvert5,
			disabled = false,
			warn = "",
			reference = class_stub.."_advert5",
		},
		--guildtools.config.lam:AddDescription(guildtools.config.panid,  class_stub.."_guild_intro1", guildtools.lang.config.advert_desc_autoinv)
		[44] = {
			type = "description",
			name = guildtools.lang.config.advert_desc_autoinv,
			reference = class_stub.."_guild_intro1",
		},
		--guildtools.config.lam:AddEditBox(guildtools.config.panid, class_stub.."_autoinv", guildtools.lang.config.advert_autoinv_lbl, guildtools.lang.config.advert_autoinv_instr, false, guildtools.config.getAutoInv,guildtools.config.setAutoInv,false,"")
		[45] = {
			type = "editbox",
			name = guildtools.lang.config.advert_autoinv_lbl,
			tooltip = guildtools.lang.config.advert_autoinv_instr,
			isMultiline = false,
			getFunc = guildtools.config.getAutoInv,
			setFunc = guildtools.config.setAutoInv,
			disabled = false,
			warn = "",
			reference = class_stub.."_autoinv",
		},
		---- Mail Config
		--guildtools.config.lam:AddHeader(guildtools.config.panid, class_stub.."_mail", guildtools.lang.config.mail_hdr)
		--guildtools.config.lam:AddDescription(guildtools.config.panid,  class_stub.."_mail_intro", guildtools.lang.config.mail_desc)
		--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_mail_send",guildtools.lang.config.mail_autosend_lbl, guildtools.lang.config.mail_autosend_tip, guildtools.config.getMailSend, guildtools.config.setMailSend, true, guildtools.lang.config.mail_autosend_warn)
		[46] = {
			type = "header",
			name = guildtools.lang.config.mail_hdr,
			reference = class_stub.."_mail",
		},
		[47] = {
			type = "description",
			name = guildtools.lang.config.mail_desc,
			reference = class_stub.."_mail_intro",
		},
		[48] = {
			type = "checkbox",
			name = guildtools.lang.config.mail_autosend_lbl,
			tooltip = guildtools.lang.config.mail_autosend_tip,
			getFunc = guildtools.config.getMailSend,
			setFunc = guildtools.config.setMailSend,
			disabled = true,
			warn = guildtools.lang.config.mail_autosend_warn,
			reference = class_stub.."_mail_send",
		},
		--olam:AddHeader(panId, class_stub.."_qmess", "Alert Window")
		--olam:AddDescription(panId, class_stub.."_qmess_desc", "Adjust the location where alerts from this and other add-ons will appear.")
		--olam:AddCheckbox(panId, class_stub.."_qmess_lock", "Lock Message Window.", "Lock the message window for configuration.", ldrude_qmess.ui.getlock,ldrude_qmess.ui.setlock, false, "")
		--olam:AddSlider(panId, class_stub.."_qmess_xpos", "Message Window X Position", "Zero (0) is the centre of the screen", -2000, 2000,10, ldrude_qmess.ui.getx, ldrude_qmess.ui.setx,true, "If you cannot see the message panel, set this value to 0")
		--olam:AddSlider(panId, class_stub.."_qmess_ypos", "Message Window Y Position", "Zero (0) is the centre of the screen", -2000, 2000,10, ldrude_qmess.ui.gety, ldrude_qmess.ui.sety,true, "If you cannot see the message panel, set this value to 0")
		--olam:AddDropdown(panId, class_stub.."_qmess_scale", "Alert Message Size", "", {"Large","Normal", "Small", "Tiny"},ldrude_qmess.ui.getscale, ldrude_qmess.ui.setscale, false,"" )
		[49] = {
			type = "header",
			name = "Alert Window",
			reference = class_stub.."_qmess",
		},
		[50] = {
			type = "description",
			name = "Adjust the location where alerts from this and other add-ons will appear.",
			reference = class_stub.."_qmess_desc",
		},
		[51] = {
			type = "checkbox",
			name = "Lock Message Window",
			tooltip = "Lock the message window for configuration.",
			getFunc = ldrude_qmess.ui.getlock,
			setFunc = ldrude_qmess.ui.setlock,
			disabled = false,
			warn = "",
			reference = class_stub.."_qmess_lock",
		},
		[52] = {
			type = "slider",
			name = "Message Window X Position",
			tooltip = "Zero (0) is the centre of the screen",
			min = -2000,
			max = 2000,
			step = 10,
			getFunc = ldrude_qmess.ui.getx,
			setFunc = ldrude_qmess.ui.setx,
			disabled = true,
			warn = "If you cannot see the message panel, set this value to 0",
			reference = class_stub.."_qmess_xpos",
		},
		[53] = {
			type = "slider",
			name = "Message Window Y Position",
			tooltip = "Zero (0) is the centre of the screen",
			min = -2000,
			max = 2000,
			step = 10,
			getFunc = ldrude_qmess.ui.gety,
			setFunc = ldrude_qmess.ui.sety,
			disabled = true,
			warn = "If you cannot see the message panel, set this value to 0",
			reference = class_stub.."_qmess_ypos",
		},
		[54] = {
			type = "dropdown",
			name = "Alert Message Size",
			tooltip = "",
			choices = {"Large","Normal", "Small", "Tiny"},
			getFunc = ldrude_qmess.ui.getscale,
			setFunc = ldrude_qmess.ui.setscale,
			disabled = false,
			warning = "",
			reference = class_stub.."_qmess_scale",
		},
    }
	
	guildtools.config.lam:RegisterOptionControls("guildtools_Panel", optionsData)
	
	
	--guildtools.config.lam:AddCheckbox(guildtools.config.panid, class_stub.."_general_motd", guildtools.lang.config.gen_gmotd_lbl, guildtools.lang.config.gen_gmotd_tip, guildtools.config.getmotd, guildtools.config.setmotd, false, "")
	
--	guildtools.config.lam:AddDescription(guildtools.config.panid,  class_stub.."_guild_intro2", "The box below can be used to import/export a set of guild message. To |c30C0FFexport|r, copy the text in the box. To |c30C0FFimport|r, paste the import text into the box and click Import.")
--	guildtools.config.lam:AddEditBox(guildtools.config.panid, class_stub.."_imptext", "Import/Export adverts", "", true, guildtools.config.getDummy,guildtools.config.setDummy,false,"")
	
--	guildtools.config.lam:AddButton(guildtools.config.panid,  class_stub.."_import", "Import Adverts", "Import the adverts into this guild", guildtools.config.doImport(), false, "")
	
	
	
	
	
	---- Add in message screen config
	
	--ldrude_qmess.ui.addconfig( guildtools.config.lam, guildtools.config.panid, class_stub )
	
	--guildtools.debug("Created config window ["..guildtools.config.panid.."]");
	
	---- Configure advert edit boxes
	--[[
	local maxChar=1022
	local scale=0.75
	
	guildtools_config_advert1.edit:SetMaxInputChars(maxChar)
	guildtools_config_advert1.edit:SetScale(scale)
	guildtools_config_advert2.edit:SetMaxInputChars(maxChar)
	guildtools_config_advert2.edit:SetScale(scale)
	guildtools_config_advert3.edit:SetMaxInputChars(maxChar)
	guildtools_config_advert3.edit:SetScale(scale)
	guildtools_config_advert4.edit:SetMaxInputChars(maxChar)
	guildtools_config_advert4.edit:SetScale(scale)
	guildtools_config_advert5.edit:SetMaxInputChars(maxChar)
	guildtools_config_advert5.edit:SetScale(scale)
	]]--
--	guildtools_config_imptext.edit:SetMaxInputChars((maxChar+5)*3)
--	guildtools_config_imptext.edit:SetScale(0.5)
		
end

----Dummy
function guildtools.config.getDummy()
end
function guildtools.config.setDummy(value)
end

 -- Manage HUD Speed

function guildtools.config.getHUDSpeed()

	return guildtools.data.messageDuration/1000

end

function guildtools.config.setHUDSpeed(value)

	guildtools.data.messageDuration = value*1000

end
---- Manage Status Widget

function guildtools.config.getStatusShow()

	return guildtools.data.status.show

end

function guildtools.config.getStatusLock()

	return guildtools.ui.status.locked

end

function guildtools.config.setStatusShow(value)

	guildtools.data.status.show = value
	guildtools.ui.status.setVisibility()

end

function guildtools.config.setStatusLock(value)

	guildtools.ui.status.locked = value
	
	if value then
		guildtools.ui.status.lock()
	else
		guildtools.ui.status.unlock()
	end

end



---- Manage alerts


function guildtools.config.getAlertLevel(guildIndex)
	
	if GetGuildId(guildIndex) == 0 then -- no guild
		return guildtools.config.alertLabels[1]
	end
	
	gname = GetGuildName(GetGuildId(guildIndex))
	

	return guildtools.config.alertLabels[guildtools.data.guilds[gname].config.alert+1]
end

function guildtools.config.setAlertLevel(guildIndex,value)
	
	if GetGuildId(guildIndex) == 0 then -- no guild
		return
	end

	gname = GetGuildName(GetGuildId(guildIndex))
	
	
	guildtools.data.guilds[gname].config.alert= guildtools.config.alertValues[value]
end

-------- MOTD

function guildtools.config.getmotd(guildIndex)
	if GetGuildId(guildIndex) == 0 then -- no guild
		return false
	end
	
	gname = GetGuildName(GetGuildId(guildIndex))
	

	return guildtools.data.guilds[gname].config.showMOTD
end

function guildtools.config.setmotd(guildIndex,value)
	if GetGuildId(guildIndex) == 0 then -- no guild
		return 
	end
	
	gname = GetGuildName(GetGuildId(guildIndex))
	

	guildtools.data.guilds[gname].config.showMOTD=value
end


-------- Level Alerts

function guildtools.config.getlevelalert(guildIndex)
	if GetGuildId(guildIndex) == 0 then -- no guild
		return false
	end
	
	gname = GetGuildName(GetGuildId(guildIndex))
	

	return guildtools.data.guilds[gname].config.showLevelChanges
end

function guildtools.config.setlevelalert(guildIndex,value)
	if GetGuildId(guildIndex) == 0 then -- no guild
		return 
	end
	
	gname = GetGuildName(GetGuildId(guildIndex))
	

	guildtools.data.guilds[gname].config.showLevelChanges=value
end

-------- Status Alerts

function guildtools.config.getstatus(guildIndex)
	if GetGuildId(guildIndex) == 0 then -- no guild
		return false
	end
	
	gname = GetGuildName(GetGuildId(guildIndex))
	

	return guildtools.data.guilds[gname].config.showStatusChanges
end

function guildtools.config.setstatus(guildIndex,value)
	if GetGuildId(guildIndex) == 0 then -- no guild
		return 
	end
	
	gname = GetGuildName(GetGuildId(guildIndex))
	

	guildtools.data.guilds[gname].config.showStatusChanges=value
end

-------- Status Alerts

function guildtools.config.getstate(guildIndex)
	if GetGuildId(guildIndex) == 0 then -- no guild
		return false
	end
	
	gname = GetGuildName(GetGuildId(guildIndex))
	

	return guildtools.data.guilds[gname].config.showGuildPlayerChanges
end

function guildtools.config.setstate(guildIndex,value)
	if GetGuildId(guildIndex) == 0 then -- no guild
		return 
	end
	
	gname = GetGuildName(GetGuildId(guildIndex))
	

	guildtools.data.guilds[gname].config.showGuildPlayerChanges=value
end

---- Manage debug
function guildtools.config.getDebug()
	return guildtools.data.showdebug
end

function guildtools.config.setDebug(value)
	guildtools.data.showdebug=value
end

---- Manage  Mail
function guildtools.config.getMailSend()
	return guildtools.data.mail_auto_send
end

function guildtools.config.setMailSend(value)
	guildtools.data.mail_auto_send=value
end


--- Update Info text

function guildtools.config.setGuildInfoText()
	
	if guildtools_config_guild_intro==nil then --- not init
			return
	end
	
	if (guildtools.guildid<1) then
		guildtools_config_guild_intro.desc:SetText(guildtools.lang.config.advert_desc_none)
	else
		guildtools_config_guild_intro.desc:SetText(string.format(guildtools.lang.config.advert_desc,guildtools.guildname))
	end
	
	-- Update coinfig labels
	
	for n=1,5,1 do
		if GetGuildId(n)==0 then
		
			_G["guildtools_config_alert_level_desc"..n].desc:SetText(guildtools.lang.config.gen_galert_none)
			
		else
			_G["guildtools_config_alert_level_desc"..n].desc:SetText("|c00ff00".. GetGuildName(GetGuildId(n)) .."|r")
		end
		
		
	end
	
	
end

--------  Manage Adverts
function guildtools.config.doImport()
	
	local txtImport = guildtools_config_imptext.edit:GetText()

	local a1,a2,a3,a4,a5=string.gmatch(txtImport, "^1^(*.)^2^(*.)^3^(*.)^4^(*.)^5^(*.)")
	
	if (a1==nil or a2==nil or a3==nil or a4==nil or a5==nil) then
		guildtools.error("Could not import adverts. String invalid!")
		return
	end
	
	guildtools_config_advert5.edit:SetText(a1)
	guildtools_config_advert5.edit:SetText(a2)
	guildtools_config_advert5.edit:SetText(a3)
	guildtools_config_advert5.edit:SetText(a4)
	guildtools_config_advert5.edit:SetText(a5)
	
	
end


function guildtools.config.getAdvert(advIndex)
	if guildtools.guildid<1 then
		return ""
	end
	
	if  guildtools.data.guilds[guildtools.guildname] == nil then
		return ""
	end

	
	
	if guildtools.data.guilds[guildtools.guildname] == nil or guildtools.data.guilds[guildtools.guildname].adverts == nil then
		temp=guildtools.getGuildTemplate()
		return temp[1]
	end
	
	
	
	return guildtools.data.guilds[guildtools.guildname].adverts[advIndex]
end

function guildtools.config.setAdvert(advIndex, text)
	if guildtools.guildid<1 then
		return
	end
	

	guildtools.data.guilds[guildtools.guildname].adverts[advIndex]=text
end


--1

function guildtools.config.getAdvert1()
	return guildtools.config.getAdvert(1)
end

function guildtools.config.setAdvert1(text)
	guildtools.config.setAdvert(1, text)
	guildtools.config.UpdateExport()
end

--2

function guildtools.config.getAdvert2()
	return guildtools.config.getAdvert(2)
end

function guildtools.config.setAdvert2(text)
	guildtools.config.setAdvert(2, text)
	guildtools.config.UpdateExport()
end

--3

function guildtools.config.getAdvert3()
	return guildtools.config.getAdvert(3)
end

function guildtools.config.setAdvert3(text)
	guildtools.config.setAdvert(3, text)
	guildtools.config.UpdateExport()
end

--4

function guildtools.config.getAdvert4()
	return guildtools.config.getAdvert(4)
end

function guildtools.config.setAdvert4(text)
	guildtools.config.setAdvert(4, text)
	guildtools.config.UpdateExport()
end

--5

function guildtools.config.getAdvert5()
	return guildtools.config.getAdvert(5)
end

function guildtools.config.setAdvert5(text)
	guildtools.config.setAdvert(5, text)
	guildtools.config.UpdateExport()
end

---Update

function guildtools.config.UpdateExport()

	--- disabled atm

	--local txtExport = "^1^"..guildtools_config_advert1.edit:GetText()
	--txtExport = txtExport .. "^2^"..guildtools_config_advert2.edit:GetText()
	--txtExport = txtExport .. "^3^"..guildtools_config_advert3.edit:GetText()
	--txtExport = txtExport .. "^4^"..guildtools_config_advert4.edit:GetText()
	--txtExport = txtExport .. "^5^"..guildtools_config_advert5.edit:GetText()
	
	--guildtools_config_imptext.edit:SetText(txtExport)
	
end

function guildtools.config.loadAdverts()

	--[[
	if guildtools_config_advert1==nil or guildtools.data.guilds[guildtools.guildname]==nil then --- not init
	
		
		return
	end
			

	guildtools_config_advert1.edit:SetText(guildtools.config.getAdvert(1))
	guildtools_config_advert2.edit:SetText(guildtools.config.getAdvert(2))
	guildtools_config_advert3.edit:SetText(guildtools.config.getAdvert(3))
	guildtools_config_advert4.edit:SetText(guildtools.config.getAdvert(4))
	guildtools_config_advert5.edit:SetText(guildtools.config.getAdvert(5))
	guildtools_config_autoinv.edit:SetText(guildtools.data.guilds[guildtools.guildname].autoInviteText)
	guildtools.config.UpdateExport()
	]]--

end

 --- Auto Invite
 
 function guildtools.config.getAutoInv()
	if guildtools.guildid<1 then
		return ""
	end
	
	if guildtools.data.guilds[guildtools.guildname] == nil or guildtools.data.guilds[guildtools.guildname].autoInviteText == nil then
		return ""
	end
	
	
	
	return guildtools.data.guilds[guildtools.guildname].autoInviteText
end

function guildtools.config.setAutoInv( text)
	if guildtools.guildid<1 then
		return
	end
	

	guildtools.data.guilds[guildtools.guildname].autoInviteText=text
end
