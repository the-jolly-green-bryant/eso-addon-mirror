-- RdK Group Tool Siege
-- By @s0rdrak (PC / EU)

RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolTB = RdKGTool.toolbox
RdKGToolTB.siege = RdKGToolTB.siege or {}
local RdKGToolSiege = RdKGToolTB.siege

RdKGToolSiege.constants = RdKGToolSiege.constants or {}

function RdKGToolSiege.Initialize()
	ZO_CreateStringId("SI_BINDING_NAME_RDKGTOOL_TOGGLE_SIEGE_CAMERA", RdKGToolSiege.constants.TOGGLE_SIEGE)
end

function RdKGToolSiege.GetDefaults()
	return nil
end

function RdKGToolSiege.ToggleCamera()
	local siegeWeaponCamera = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_SIEGE_WEAPONRY)
	if siegeWeaponCamera == "1" then
		siegeWeaponCamera = "0"
	else
		siegeWeaponCamera = "1"
	end
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_SIEGE_WEAPONRY, siegeWeaponCamera, 1)
	--d(siegeWeaponCamera)
end

--menu interactions
function RdKGToolSiege.GetMenu()
	return nil
end