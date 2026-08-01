Q_RGH_LP = Q_RGH_LP or {}

Q_RGH_LP.name = "Qcell_RGHelper_LangPatch"
Q_RGH_LP.act	=	false

Q_RGH_LP.data = {
	OaxName 	= string.lower(GetString(SI_QcellRGH_OAXILTSO)),
    BahName 	= string.lower(GetString(SI_QcellRGH_BAHSEI)),
    XalName 	= string.lower(GetString(SI_QcellRGH_XALVAKKA)),	
    Xal_ShName 	= string.lower(GetString(SI_QcellRGH_XALVAKKA_VOLATILE_SHELL)),
}

	local isFirstTimePlayerActivated = true

local function NameRepl()
	local QD = QRH.data
	local VD = Q_RGH_LP.data
		QD.oaxiltso_name 				= VD.OaxName 	
		QD.bahsei_name 					= VD.BahName 	
		QD.xalvakka_name 				= VD.XalName 	
		QD.xalvakka_volatile_shell_name	= VD.Xal_ShName
end
	
local function ZoneChk()
	local QD_ZId = QRH.data.rockgrove_id
	local Cur_ZId = GetZoneId(GetUnitZoneIndex("player"))
	if Cur_ZId ~= QD_ZId then
	    return
	else
		NameRepl()
	end
	
	if not Q_RGH_LP.act then
	d(GetString(SI_QcellRGH_InitMSG))
	end
	
	Q_RGH_LP.act	=	true
end	

local function InitQ_RGH_LP(eventCode, initial)
	if initial then
		if isFirstTimePlayerActivated == false then
			ZoneChk()
		else
			isFirstTimePlayerActivated = false
			ZoneChk()
		end
    else
        isFirstTimePlayerActivated = false
		ZoneChk()
    end	
end
	
local function LangP_Init(event, addonName)
	if addonName ~= Q_RGH_LP.name then
		return
	end
		EVENT_MANAGER:UnregisterForEvent("Qcell_RGHelper_LangPatch", EVENT_ADD_ON_LOADED)
		EVENT_MANAGER:RegisterForEvent("Qcell_RGHelper_LangPatch", EVENT_PLAYER_ACTIVATED, InitQ_RGH_LP)
end

	EVENT_MANAGER:RegisterForEvent("Qcell_RGHelper_LangPatch", EVENT_ADD_ON_LOADED, LangP_Init)