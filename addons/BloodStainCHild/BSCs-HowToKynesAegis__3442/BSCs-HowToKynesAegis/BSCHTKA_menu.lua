BSCHTKAHelper = BSCHTKAHelper or {}
local BSCHTKA = BSCHTKAHelper

local optionsTable = {}

local function AddSendFeedBack()
    table.insert(optionsTable, {
        type = "button",
        name = "Donate",
        tooltip = "Main - EU Server",
        func = function()
              local function PrefillMail()
                ZO_MailSendToField:SetText(BSCHTKA.Author)
                ZO_MailSendSubjectField:SetText(BSCHTKA.Name)
                ZO_MailSendBodyField:TakeFocus()
              end
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(PrefillMail, 250)
        end,
        width = "half",
        warning = "",	
    })
end

local function AddTexture(control, strIcon, strDesciption)
	table.insert(control, {
        type = "texture",
        image =  GetAbilityIcon(strIcon),
		tooltip = strDesciption,
        imageWidth = 32,
        imageHeight = 32,
        width = "half",
	})
end

local function AddDivider(control)
	table.insert(control, {
		type = "divider",
	})
end

local TEST_COLOR = { 0, 0.8, 0, 0.4 }
local function AddTestAlert()
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Use Select Color Alert", 
		getFunc = function() return BSCHTKA.SV_ACC.USE_COLOR end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.USE_COLOR = value
		end,
        --width = "half",
	})	
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Test Alert Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(TEST_COLOR) end,
		setFunc = function(r,g,b,a) 
			TEST_COLOR={r,g,b,a} 
			CombatAlerts.AlertCast( 133515, "Test Alert", 4000, { -3, 0, false, { r , g, b, a }, { r , g, b, 1 } } )
			CombatAlerts.Alert(nil, "Test Alert!", BSCHTKA:BuildHexColor(TEST_COLOR), SOUNDS.NONE, 4000)
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})
	table.insert(optionsTable, {
        type = "button",
        name = "Test Alert",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
        func = function()
			CombatAlerts.AlertCast( 133515, "Test Alert", 4000, { -3, 0, false, { unpack(TEST_COLOR) }, { TEST_COLOR[1] , TEST_COLOR[2], TEST_COLOR[3], 1 }})
			CombatAlerts.Alert(nil, "Test Alert!", BSCHTKA:BuildHexColor(TEST_COLOR), SOUNDS.NONE, 4000)
        end,
        width = "full",
    })	
end

local function AddUISettings()
	table.insert(optionsTable, {
        type = "header",
        name = "UI Settings",
    })
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Show Boss UI", 
		getFunc = function() return BSCHTKA.SV_ACC.SHOW_UI_BOSS end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.SHOW_UI_BOSS = value
		end,
        --width = "half",
	})	
	table.insert(optionsTable, {
		type = "checkbox",
		name = "LOCK Boss UI", 
		getFunc = function() return BSCHTKA.SV_ACC.LOCK_UI_I end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.LOCK_UI_I = value
			BSCHTKAHelperInfoUI:SetMovable(not BSCHTKA.SV_ACC.LOCK_UI_I)
		end,
        --width = "half",
	})	
	table.insert(optionsTable, {
        type = "button",
        name = "Reset UI Position Boss",
        func = function()
			BSCHTKAHelperInfoUI:ClearAnchors()
			BSCHTKAHelperInfoUI:SetAnchor(BOTTOM, GuiRoot, CENTER, 500, -150)	
			BSCHTKA.SV_ACC.UI_LEFT_I = 500
			BSCHTKA.SV_ACC.UI_TOP_I = -150
        end,
        width = "full",
    })	
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Show UI Lord Falgravn Percent", 
		getFunc = function() return BSCHTKA.SV_ACC.SHOW_UI_PERCENT end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.SHOW_UI_PERCENT = value
		end,
        --width = "half",
	})	
	table.insert(optionsTable, {
		type = "checkbox",
		name = "LOCK UI Lord Falgravn Percent", 
		getFunc = function() return BSCHTKA.SV_ACC.LOCK_UI_B end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.LOCK_UI_B = value
			BSCHTKAUIBossP:SetMovable(not BSCHTKA.SV_ACC.LOCK_UI_B)
		end,
        --width = "half",
	})
	table.insert(optionsTable, {
        type = "button",
        name = "Reset UI Position Lord Falgravn Percent",
        func = function()
			BSCHTKAUIBossP:ClearAnchors()
			BSCHTKAUIBossP:SetAnchor(BOTTOM, GuiRoot, CENTER, 0, -165)
			BSCHTKA.SV_ACC.UI_LEFT_B = 0 
			BSCHTKA.SV_ACC.UI_TOP_B = -165
        end,
        width = "full",
    })	
end
	
local function AddYandirSetting()
	table.insert(optionsTable, {
        type = "header",
        name = "1. Boss (Yandir The Butcher)",
    })
	AddTexture(optionsTable, 133559, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Poision Totem dodge Alert", 
		getFunc = function() return BSCHTKA.SV_ACC.POISION_TOTEM end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.POISION_TOTEM = value
		end,
        width = "half",
	})		
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Poision Totem dodge Alert Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_POISION_TOTEM) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_POISION_TOTEM={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})
	AddDivider(optionsTable)	
	AddTexture(optionsTable, 133549, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Gargoyle's Totem Block Alert", 
		getFunc = function() return BSCHTKA.SV_ACC.GARGYL_TOTEM end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.GARGYL_TOTEM = value
		end,
        width = "half",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Gargoyle's Totem Block Alert Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_GARGYL_TOTEM) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_GARGYL_TOTEM={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})
	AddDivider(optionsTable)	
	AddTexture(optionsTable, 70010, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Healing Alert", 
		getFunc = function() return BSCHTKA.SV_ACC.HEALING_YANDIR end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.HEALING_YANDIR = value
		end,
        width = "half",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Healing Alert Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_HEALING_YANDIR) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_HEALING_YANDIR={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})
	AddDivider(optionsTable)	
	AddTexture(optionsTable, 132588, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Jump Alert", 
		getFunc = function() return BSCHTKA.SV_ACC.JUMP_YANDIR end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.JUMP_YANDIR = value
		end,
        width = "half",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Jump Alert Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_JUMP_YANDIR) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_JUMP_YANDIR={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})
	AddDivider(optionsTable)	
	AddTexture(optionsTable, 136678, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Sea Adder Bile Spray", 
		getFunc = function() return BSCHTKA.SV_ACC.SEA_ADDER_BILE_SPRAY end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.SEA_ADDER_BILE_SPRAY = value
		end,
        width = "half",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Sea Adder Bile Spray Alert Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_SEA_ADDER_BILE) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_SEA_ADDER_BILE={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})
end

local function AddVrolSetting()
	table.insert(optionsTable, {
        type = "header",
        name = "2. Boss (Captain Vrol)",
    })
	AddTexture(optionsTable, 134016, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Cast Portal Alert", 
		getFunc = function() return BSCHTKA.SV_ACC.PORTAL_CAST_VROL end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.PORTAL_CAST_VROL = value
		end,
        width = "half",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Cast Portal Alert Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_PORTAL_CAST_VROL) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_PORTAL_CAST_VROL={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})
	AddDivider(optionsTable)
	AddTexture(optionsTable, 134016, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Countdown Portal (Only Portal Player)", 
		getFunc = function() return BSCHTKA.SV_ACC.PORTAL_KTIME_VROL end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.PORTAL_KTIME_VROL = value
		end,
        width = "half",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Countdown Portal Alert Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_PORTAL_KTIME_VROL) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_PORTAL_KTIME_VROL={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})
	AddDivider(optionsTable)
	AddTexture(optionsTable, 134016, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Portal Position Icon", 
		getFunc = function() return BSCHTKA.SV_ACC.PORTAL_ICON_VROL end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.PORTAL_ICON_VROL = value
			if value then 
				if BSCHTKA.bVrol then BSCHTKA.AddPortalIcon() end
			else 
				BSCHTKA.RemovePortalIcon() 
			end 
		end,
        width = "half",
	})	
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Cast Portal Alert Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_PORTAL_CAST_VROL) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_PORTAL_CAST_VROL={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})
	AddDivider(optionsTable)
	AddTexture(optionsTable, 140375, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Cast Fog Alert", 
		getFunc = function() return BSCHTKA.SV_ACC.FOG_CAST_VROL end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.FOG_CAST_VROL = value
		end,
        width = "half",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Cast Fog Alert Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_FOG_CAST_VROL) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_FOG_CAST_VROL={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})
	AddDivider(optionsTable)
	AddTexture(optionsTable, 124468, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Countdown to Kill Harpoon", 
		getFunc = function() return BSCHTKA.SV_ACC.HARPOON_VROL end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.HARPOON_VROL = value
		end,
        width = "half",
	})	
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Countdown to Kill Harpoon Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_HARPOON_VROL) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_HARPOON_VROL={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})
	AddDivider(optionsTable)
	AddTexture(optionsTable, 140261, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Interrupt Apothecary Alert", 
		getFunc = function() return BSCHTKA.SV_ACC.APOTHECARY_VROL end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.APOTHECARY_VROL = value
		end,
        width = "half",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Interrupt Apothecary Alert Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_APOTHECARY_VROL) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_APOTHECARY_VROL={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})
end 

local function AddFalgravnSetting()
	table.insert(optionsTable, {
        type = "header",
        name = 'Trash & Boss',
    })
	AddTexture(optionsTable, 132570, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Blood Fountains Block Alert", 
		getFunc = function() return BSCHTKA.SV_ACC.BLOOD_FOUNTAIN end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.BLOOD_FOUNTAIN = value
		end,
        width = "half",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Blood Fountains Block Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_BLOOD_FOUNTAIN) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_BLOOD_FOUNTAIN={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})	
	AddDivider(optionsTable)
	AddTexture(optionsTable, 137292, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Infuser Cast Alert", 
		getFunc = function() return BSCHTKA.SV_ACC.INFUSER_INFUSE end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.INFUSER_INFUSE = value
		end,
        width = "half",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Infuser Cast Alert Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_INFUSER_INFUSE) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_INFUSER_INFUSE={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})	
	table.insert(optionsTable, {
        type = "header",
        name = '3. Boss "Mini" (Lieutenant Njordal)',
    })
	AddTexture(optionsTable, 136988, "Lieutenant Njordal")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Ground Effect Countdown (Move)", 
		getFunc = function() return BSCHTKA.SV_ACC.M_MOVE_FALGRAVN end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.M_MOVE_FALGRAVN = value
		end,
        width = "half",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Ground Effect Countdown Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_M_MOVE_FALGRAVN) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_M_MOVE_FALGRAVN={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})	
	AddDivider(optionsTable)
	AddTexture(optionsTable, 137499, "Lieutenant Njordal")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Charge Alert (Block)", 
		getFunc = function() return BSCHTKA.SV_ACC.M_BLOCK_FALGRAVN end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.M_BLOCK_FALGRAVN = value
		end,
        width = "half",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Charge Alert Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_M_BLOCK_FALGRAVN) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_M_BLOCK_FALGRAVN={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})	
	AddDivider(optionsTable)	
	AddTexture(optionsTable, 136976, "Lieutenant Njordal")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Blood Cleave Alert (DODGE)", 
		getFunc = function() return BSCHTKA.SV_ACC.M_DODGE_FALGRAVN end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.M_DODGE_FALGRAVN = value
		end,
        width = "half",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Blood Cleave Alert Color",		
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_M_DODGE_FALGRAVN) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_M_DODGE_FALGRAVN={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})	
	--	
	table.insert(optionsTable, {
        type = "header",
        name = "3. Boss (Lord Falgravn)",
    })
	--AddTexture(optionsTable, 121272, "")
	--table.insert(optionsTable, {
	--	type = "checkbox",
	--	name = "90% 80% Countdown", 
	--	getFunc = function() return BSCHTKA.SV_ACC.CONNECT_TIME_FALGRAVN end,
	--	setFunc = function(value) 
	--		BSCHTKA.SV_ACC.CONNECT_TIME_FALGRAVN = value
	--	end,
    --    width = "half",
	--})
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Position Icon (Connect 90% 80%)", 
		getFunc = function() return BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE = value
		end,
        --width = "half",
	})
	table.insert(optionsTable, {
		type = "slider",
		disabled = function() return not BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE end,
		name = "Position Ody's Icon Size",
		min = 0,
		max = 300,
		step = 1,
		default = 100,	
		getFunc = function() return BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_SIZE end,
		setFunc = function(value)
			BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_SIZE = value
			BSCHTKA.UpdateAllPosIconConn()
			BSCHTKA.UpdateAllTorturerIcons()
			BSCHTKA.UpdateAllPosIconBlood()
		end,
	})
	table.insert(optionsTable, {
		type = "dropdown",
		disabled = function() return not BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE end,
		name = "My Position", 
		tooltip = "Position 1 Starts at the wall, 5 end's into the middle.",
        choices = {"NONE", "Positon 1", "Positon 2", "Positon 3", "Positon 4", "Positon 5"},		
		getFunc = function()		
			if BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_POS == -1 then
				return "NONE" 
			elseif BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_POS == 1 then
				return "Positon 1"
			elseif BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_POS == 2 then
				return "Positon 2"
			elseif BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_POS == 3 then
				return "Positon 3"
			elseif BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_POS == 4 then
				return "Positon 4"
			elseif BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_POS == 5 then
				return "Positon 5"
			else			
				return "NONE" 
			end
		end,
		setFunc = function(v) 
			if v == "NONE" then
				BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_POS = -1 
			elseif v == "Positon 1" then
				BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_POS = 1 
			elseif v == "Positon 2" then
				BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_POS = 2 
			elseif v == "Positon 3" then
				BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_POS = 3 
			elseif v == "Positon 4" then
				BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_POS = 4
			elseif v == "Positon 5" then
				BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_POS = 5 
			else
				BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_POS = -1 
			end	
			BSCHTKA.UpdatePosIcon()
		end,
        width = "full",
	})
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Display all Red Position Icon", 
		disabled = function() return not BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE end,
		tooltip = "The choosen one will be Green else all are Red.",
		getFunc = function() return BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL = value
			BSCHTKA.UpdatePosIcon()
		end,
        --width = "half",
	})	
	AddDivider(optionsTable)	
	AddTexture(optionsTable, 135092, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Prison Kill Countdown", 
		getFunc = function() return BSCHTKA.SV_ACC.PRISON_FALGRAVN end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.PRISON_FALGRAVN = value
		end,
        width = "half",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Prison Kill Countdown Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_M_DODGE_FALGRAVN) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_M_DODGE_FALGRAVN={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})
	AddDivider(optionsTable)
	AddTexture(optionsTable, 135092, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Prison Icon on Player", 
		getFunc = function() return BSCHTKA.SV_ACC.PRISON_ICON end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.PRISON_ICON = value
		end,
        width = "half",
	})
	AddDivider(optionsTable)
	AddTexture(optionsTable, 137963, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Alert Openign Door", 
		getFunc = function() return BSCHTKA.SV_ACC.OPEN_DOOR_FALGRAVN end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.OPEN_DOOR_FALGRAVN = value
		end,
        width = "half",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Alert Openign Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_OPEN_DOOR_FALGRAVN) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_OPEN_DOOR_FALGRAVN={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})	
	AddDivider(optionsTable)
	AddTexture(optionsTable, 144159, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Torturer Feed", 
		getFunc = function() return BSCHTKA.SV_ACC.TUT_FEED_FALGRAVN end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.TUT_FEED_FALGRAVN = value
		end,
        width = "half",
	})	
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Torturer Feed Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_TUT_FEED_FALGRAVN) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_TUT_FEED_FALGRAVN={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})		
	AddDivider(optionsTable)
	AddTexture(optionsTable, 140944, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Instability Icon's On Players", 
		getFunc = function() return BSCHTKA.SV_ACC.INSTABILITY_ICON end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.INSTABILITY_ICON = value
		end,
        width = "half",
	})	
	AddDivider(optionsTable)
	AddTexture(optionsTable, 129936, "")
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Execration Icon On Player", 
		tooltip = "The player who did take the Blop Synergie..",
		getFunc = function() return BSCHTKA.SV_ACC.EXECRATION_ICON end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.EXECRATION_ICON = value
		end,
        width = "half",
	})	
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Position Icon (Blood Ball)", 
		getFunc = function() return BSCHTKA.SV_ACC.BB_ODYICON_POS_FALGRAVN_ENABLE end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.BB_ODYICON_POS_FALGRAVN_ENABLE = value
		end,
        --width = "half",
	})
	table.insert(optionsTable, {
		type = "slider",
		disabled = function() return not BSCHTKA.SV_ACC.BB_ODYICON_POS_FALGRAVN_ENABLE end,
		name = "Position Icon Size (Blood Ball)",
		min = 0,
		max = 300,
		step = 1,
		default = 200,	
		getFunc = function() return BSCHTKA.SV_ACC.BB_ODYICON_FALGRAVN_SIZE end,
		setFunc = function(value)
			BSCHTKA.SV_ACC.BB_ODYICON_FALGRAVN_SIZE = value
			BSCHTKA.UpdateAllPosIconBlood()
		end,
	})
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Torturer Icon's", 
		getFunc = function() return BSCHTKA.SV_ACC.TUT_ODYICON_FALGRAVN end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.TUT_ODYICON_FALGRAVN = value
		end,
        width = "full",
	})
	table.insert(optionsTable, {
		type = "slider",
		disabled = function() return not BSCHTKA.SV_ACC.TUT_ODYICON_FALGRAVN end,
		name = "Torturer Icon Size",
		min = 0,
		max = 300,
		step = 1,
		default = 200,	
		getFunc = function() return BSCHTKA.SV_ACC.TUT_ODYICON_FALGRAVN_SIZE end,
		setFunc = function(value)
			BSCHTKA.SV_ACC.TUT_ODYICON_FALGRAVN_SIZE = value
			BSCHTKA.UpdateAllTorturerIcons()
		end,
	})	
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Torturer Port Alert", 
		getFunc = function() return BSCHTKA.SV_ACC.FALGRAVN_TORTURER_ESC end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.FALGRAVN_TORTURER_ESC = value
		end,
        width = "full",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Torturer Port Alert Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_FALGRAVN_TORTURER_ESC) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_FALGRAVN_TORTURER_ESC={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})		
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Torturer Light Attack You Alert (DD&HEAL)", 
		getFunc = function() return BSCHTKA.SV_ACC.FALGRAVN_TORTURER_LA end,
		setFunc = function(value) 
			BSCHTKA.SV_ACC.FALGRAVN_TORTURER_LA = value
		end,
        width = "full",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Torturer Attacks You Alert Color",
		disabled = function() return not BSCHTKA.SV_ACC.USE_COLOR end,
		getFunc = function() return unpack(BSCHTKA.SV_ACC.C_FALGRAVN_TORTURER_LA) end,
		setFunc = function(r,g,b,a) 
			BSCHTKA.SV_ACC.C_FALGRAVN_TORTURER_LA={r,g,b,a} 
		end,
		width = "full",
		default = function() return {r=248/255,g=248/255,b=255/255} end, 
	})
end


function BSCHTKA:InitMenu()
	-- the panel for the addons menu
	local panelData = {
		type = "panel",
		name = BSCHTKA.NameMenu,
		displayName = BSCHTKA.NameSpaced,
		author = BSCHTKA.Author,
		version = BSCHTKA.VersionDisplay,
		registerForRefresh = true,
	}
	
	AddSendFeedBack()
	AddTestAlert()	
	AddYandirSetting()
	AddVrolSetting()
	AddFalgravnSetting()
	AddUISettings()
	
    local addonpanel = LibAddonMenu2:RegisterAddonPanel(BSCHTKA.NameSpaced, panelData)
    LibAddonMenu2:RegisterOptionControls(BSCHTKA.NameSpaced, optionsTable)
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(currentpanel) 
		if addonpanel == currentpanel then 
			BSCHTKAUIBossP:SetHidden(false) 
			BSCHTKAUIBossP:GetNamedChild("BossPercent"):SetText("BossInfo")
			BSCHTKAHelperInfoUI:SetHidden(false) 
			BSCHTKAHelperInfoUI:GetNamedChild("InfoTOP"):SetText("Boss Name")
			BSCHTKAHelperInfoUI:GetNamedChild("Info1"):SetText("Info 1")
			BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText("Info 2")
			BSCHTKAHelperInfoUI:GetNamedChild("Info3"):SetText("Info 3")
			BSCHTKAHelperInfoUI:GetNamedChild("Info4"):SetText("Info 4")	
		end 
	end)
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(currentpanel) 
		if addonpanel == currentpanel then  
			BSCHTKAUIBossP:SetHidden(true) 		
			BSCHTKAUIBossP:GetNamedChild("BossPercent"):SetText("")
			BSCHTKAHelperInfoUI:SetHidden(true)	
			BSCHTKAHelperInfoUI:GetNamedChild("InfoTOP"):SetText("")
			BSCHTKAHelperInfoUI:GetNamedChild("Info1"):SetText("")
			BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText("")
			BSCHTKAHelperInfoUI:GetNamedChild("Info3"):SetText("")
			BSCHTKAHelperInfoUI:GetNamedChild("Info4"):SetText("")	
		end 
	end)
end
