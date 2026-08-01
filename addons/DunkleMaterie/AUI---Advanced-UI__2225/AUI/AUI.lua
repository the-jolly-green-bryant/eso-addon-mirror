local LMP = LibStub("LibMediaProvider-1.0")
local isLoaded = false
local showStartMessage = true
local hasAzurah = false

local function GetCustomFontList()
	local fontArtList = 
	{	
		["Calligraphica"]					= "AUI/fonts/Kingthings_Calligraphica_2.ttf",
		["Almendra"]						= "AUI/fonts/Almendra-Bold.otf",
		["Sansita One"]						= "AUI/fonts/SansitaOne.ttf",
	    ["Bellota"]							= "AUI/fonts/Bellota-Bold.otf",
		["ESO-FWUDC_70 M"]					= "esoui/common/fonts/eso_fwudc_70-m.ttf",
		["ESO-FWNTLGUDC70 DB"]				= "esoui/common/fonts/eso_fwntlgudc70-db.ttf",
	}	
	
	return fontArtList
end

function AUI.RegisterMedia()
	for fontName, fontPath in pairs(GetCustomFontList()) do
		LMP:Register(LMP.MediaType.FONT, fontName, fontPath)
	end
end

local function AUI_OnFastUpdate()
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Map.Update()
	end	
	
	if AUI.Questtracker.IsEnabled() then
		AUI.Questtracker.UpdateTime()
	end		
end

local function AUI_OnSlowUpdate()
	if AUI.Minimap.IsEnabled() then
		if AUI.Settings.Minimap.preview_locationName then
			AUI.Minimap.UI.UpdateLocationName()
			AUI.Minimap.Pin.UpdateMovingPins()
		end	
		
		if AUI.Settings.Minimap.preview_coords then
			 AUI.Minimap.UI.UpdateCoords()
		end
	end	
end

local function AUI_SlashCommand(option)	
	local options = { 
		string.match(option,"^(%S*)%s*(.-)$") 
	}

	if not option or option == "" then
    	d("AUI slash commands: ")
	    d("|ce5e1b4Gold donation:|r |cffffff/aui donate <value>|r")	
		d("|ce5e1b4Refresh Minimap:|r |cffffff/aui minimap refresh|r")	
		d("|ce5e1b4Toggle Minimap:|r |cffffff/aui minimap toggle|r")
	elseif options[1] and options[2]then
		if options[1] == "donate" then
			local value = tonumber(options[2])
			if value and value >= 1000 then
				RequestOpenMailbox()
				QueueMoneyAttachment(tonumber(options[2]))	
				SendMail("@sensi2010", "AUI Donation")
			else			
				d(AUI.L10n.GetString("zero_donate_warning"))
			end
		elseif options[1] == "minimap" then
			if options[2] == "refresh" then
				AUI.Minimap.Map.Refresh()
			elseif options[2] == "toggle" then
				AUI.Minimap.Toggle()
			end
		elseif options[1] == "stresstest" then
			if options[2] == "start" then
				AUI.StressTest.Start()
			elseif options[2] == "stop" then
				AUI.StressTest.Stop()
			end
		end
	end
end

local function AUI_OnLoad(p_eventCode, p_addOnName)
  if p_addOnName == "Azurah" then
      hasAzurah = true
      if isLoaded then
          AUI.MainMenu.SetMenuData(hasAzurah)
      end
  end

	if p_addOnName ~= "AUI" or isLoaded then
        return
    end	
	
	showStartMessage = true
	
	AUI.RegisterMedia()
	AUI.MainMenu.SetMenuData(hasAzurah)	
	AUI.LoadTemplateSettings()

	if AUI.ReloadUIHelper.IsEnabled() then
		AUI.ReloadUIHelper.Load()
	end	
	
	if AUI.Attributes.IsEnabled() then
		AUI.Attributes.Load()
	end

	if AUI.Combat.IsEnabled() then
		AUI.Combat.Load()	
	end
	
	if AUI.Actionbar.IsEnabled() and not AUI.Actionbar.UseAzurah() then
		AUI.Actionbar.Load()
	end
	
	if AUI.Buffs.IsEnabled() then
		AUI.Buffs.Load()
	end	
	
	if AUI.Minimap.IsEnabled() then
		AUI.Minimap.Load()
	end	

	if AUI.Questtracker.IsEnabled() then
		AUI.Questtracker.Load()
		AUI.Questtracker.Show()
	end	

	AUI.Keybinding.Create()	

	AUI_OnFastUpdate()
	AUI_OnSlowUpdate()
	
	EVENT_MANAGER:RegisterForUpdate("AUI_OnFastUpdate", 10, AUI_OnFastUpdate)
	EVENT_MANAGER:RegisterForUpdate("AUI_OnSlowUpdate", 400, AUI_OnSlowUpdate)
	
	EVENT_MANAGER:UnregisterForEvent("AUI_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED)
	
	AUI.LoadEvents()
	
	SLASH_COMMANDS["/aui"] = AUI_SlashCommand
	SLASH_COMMANDS["/advancedui"] = AUI_SlashCommand
	
	AUI.CreateDebugWindow()
	
	if ZO_LootHistoryControl_Keyboard then
		ZO_LootHistoryControl_Keyboard:SetDrawLayer(DL_OVERLAY)
	end
	
	isLoaded = true
end

function AUI.IsLoaded()
	return isLoaded
end

function AUI.SendStartMessage()
	if isLoaded and showStartMessage and AUI.MainSettings.show_start_message then
		d("|c80c63dAUI|r addon loaded. Type |cffffff/aui|r for more info")
		if hasAzurah then
		    d("|c80c63dAUI|r Azurah detected")
		else
		    d("|c80c63dAUI|r Azurah not detected")
		end
		showStartMessage = false
	end
end

function AUI.Minimap.IsEnabled()
	return AUI.MainSettings.modul_minimap_enabled
end

function AUI.Attributes.IsEnabled()
	return AUI.MainSettings.modul_attribute_enabled
end

function AUI.Combat.IsEnabled()
	return AUI.MainSettings.modul_combat_stats_enabled
end

function AUI.Actionbar.IsEnabled()
	return AUI.MainSettings.modul_actionBar_enabled
end

function AUI.Actionbar.UseAzurah()
  if AUI.MainSettings.modul_actionBarUseAzurah ~= nil then 
    return AUI.MainSettings.modul_actionBarUseAzurah
  end
  return false
end

function AUI.Buffs.IsEnabled()
	return AUI.MainSettings.modul_buffs_enabled
end

function AUI.Questtracker.IsEnabled()
	return AUI.MainSettings.modul_questtracker_enabled
end

function AUI.FrameMover.IsEnabled()
	return AUI.MainSettings.modul_FrameMover_enabled
end

function AUI.ReloadUIHelper.IsEnabled()
	return true
end

function AUI.IsAzurahDetected()
  return hasAzurah
end

EVENT_MANAGER:RegisterForEvent("AUI_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, AUI_OnLoad)