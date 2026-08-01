-- Speed Farmer by @dOpiate
-- Version 1.3.0
-- Thanks to Balver for German translations.
-- Thanks to Baertram for universal translation code!
--
SpeedFarmer = {}

SpeedFarmer.name = "SpeedFarmer"
local ItemOpened = ""

function SpeedFarmer.OnPlayerFarmingState(EVENT_SHOW_BOOK, inBook)
			local action, item, _, _ , _, _ = GetGameCameraInteractableActionInfo()

			if ItemOpened == item then
				ItemOpened = ""
				action = "nada"
			end
 			if action == GetString(SI_GAMECAMERAACTIONTYPE1)  	  --search
         or action == GetString(SI_GAMECAMERAACTIONTYPE15)  --examine
         		or item == "Bookshelf"
           then 
           SCENE_MANAGER:ShowBaseScene()							  --interrupt book display
           ItemOpened = item
			end
end

EVENT_MANAGER:RegisterForEvent("SpeedFarmer", EVENT_SHOW_BOOK, SpeedFarmer.OnPlayerFarmingState)  --- register event
