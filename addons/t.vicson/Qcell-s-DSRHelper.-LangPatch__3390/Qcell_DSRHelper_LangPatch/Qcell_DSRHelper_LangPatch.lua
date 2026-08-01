Q_DSRH_LP = Q_DSRH_LP or {}

Q_DSRH_LP.name	=	"Qcell_DSRHelper_LangPatch"
Q_DSRH_LP.act	=	false

Q_DSRH_LP.data = {
	LylName = string.lower(GetString(SI_QcDSR_LYLANAR)),
    TurName = string.lower(GetString(SI_QcDSR_TURLASSIL)),
    GrdName = string.lower(GetString(SI_QcDSR_GUARDIAN)),	
    TalName = string.lower(GetString(SI_QcDSR_TALERIA)),
}

	local isFirstTimePlayerActivated = true

local function NameRepl()
	local QD = QDRH.data
	local VD = Q_DSRH_LP.data
		QD.lylanarName		= VD.LylName
		QD.turlassilName	= VD.TurName
		QD.reefGuardianName	= VD.GrdName
		QD.taleriaName		= VD.TalName
end
		
local function ZoneChk()
	local QD_ZId = QDRH.data.dreadsailReefId
	local Cur_ZId = GetZoneId(GetUnitZoneIndex("player"))
	if Cur_ZId ~= QD_ZId then
	    return
	else
		NameRepl()
	end
	
	if not Q_DSRH_LP.act then
	d(GetString(SI_QcDSR_InitMSG))
	end
	
	Q_DSRH_LP.act	=	true
end	

local function InitQ_DSRH_LP(eventCode, initial)
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
	if addonName ~= Q_DSRH_LP.name then
		return
	end
		EVENT_MANAGER:UnregisterForEvent("Qcell_DSRHelper_LangPatch", EVENT_ADD_ON_LOADED)
		EVENT_MANAGER:RegisterForEvent("Qcell_DSRHelper_LangPatch", EVENT_PLAYER_ACTIVATED, InitQ_DSRH_LP)
end

	EVENT_MANAGER:RegisterForEvent("Qcell_DSRHelper_LangPatch", EVENT_ADD_ON_LOADED, LangP_Init)