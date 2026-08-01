-- NeltharionsHealer
NeltharionsHealer = ZO_InitializingObject:Subclass()

NeltharionsHealer.addOnName = "NeltharionsHealer"
NeltharionsHealer.addOnDisplayName = "Neltharions Healer"

NeltharionsHealer.website = "https://www.esoui.com/downloads/info2955-NeltharionsHealer.html"

NeltharionsHealer.DEFAULTS =
{
  enableAddon = true,
  ignoreCompanion=false,
  warnsoundenable = true,
  warnsound = "BG_Countdown_Finish",
  warnsoundoutR = "BG_One_Minute_Warning",
  soundVolumen = 100,
  userVISIBLE = false,
  userLOW_HEALTH = 45,
  warnTColor = ZO_ColorDef:New(255,0,0,255),
  warnTRColor = ZO_ColorDef:New(255,255,0,255),
  overlayColerW = ZO_ColorDef:New(255,0,0,255),
  overlayColerOR = ZO_ColorDef:New(255,255,0,255),


  overlayEnable = false,
  overlayOREnable = false,
  randomText = false,

  top = 0,
  left = 0,
  APIVersion = 0,
  APITimeStamp = 0,
  AddOnVersion = nil,
  data = { },
}


local function GetAddOnInfos()
	local addOnManager = GetAddOnManager()
	local name, author
	for i = 1, addOnManager:GetNumAddOns() do
		name, _, author = addOnManager:GetAddOnInfo(i)
		if name == NeltharionsHealer.addOnName then
			return author, tostring(addOnManager:GetAddOnVersion(i))
		end
	end
end

NeltharionsHealer.author, NeltharionsHealer.version = GetAddOnInfos()
NeltharionsHealer.version = "2.22"
