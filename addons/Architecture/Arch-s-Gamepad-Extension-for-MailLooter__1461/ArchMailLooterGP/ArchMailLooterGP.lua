ArchMailLooterGP = {}

function ArchMailLooterGP:LootAll()
	if MailLooter ~= nil then
		--Show the keyboard-based interface (even though we are in gamepad mode)
		if not SCENE_MANAGER:IsShowing("mailLooter") then
			MAIN_MENU_KEYBOARD:ShowScene("mailLooter")
		end

		--Loot All Mail using MailLooter addon
		zo_callLater(MailLooter.Core.ProcessMailAll, 500)
	else
		d("MailLooter addon must be enabled!")
	end
end

function ArchMailLooterGP:DefineColors()
	self.color = {}
	self.color.yellow 			= "|cFFFF00"
	self.color.lightYellow	 	= "|cFFFFCC"
	self.color.green 			= "|c00FF00"
	self.color.magenta 			= "|cFF00FF"
	self.color.red 				= "|cFF0000"
	self.color.darkOrange 		= "|cFFA500"
	self.color.iconYellow 		= "|cFFFF33"
	self.color.iconOrange 		= "|cFF6600"
	self.color.grey 			= "|c626255"
	self.color.brightOrange 	= "|cE68A00"
end

function ArchMailLooterGP:Initialize(addonName)
	ArchMailLooterGP:DefineColors()

	ZO_CreateStringId("SI_BINDING_NAME_ARCHMAILLOOTER_GP_LOOTALL", self.color.darkOrange.."Open and Loot All|r "..self.color.magenta.."- Set a hotkey to open and loot all mail using MailLooter within gamepad mode")

	self.name = addonName
end

local function ArchMailLooterGP_Init(eventType, addonName)
	if addonName ~= "ArchMailLooterGP" then
		return
	end
	
	ArchMailLooterGP:Initialize(addonName)
end

EVENT_MANAGER:RegisterForEvent("ArchMailLooterGPInit", EVENT_ADD_ON_LOADED, ArchMailLooterGP_Init)
