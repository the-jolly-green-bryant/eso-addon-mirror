--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: strings.lua

  Copyright (c) 2017-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local strings = {
	--module-bagspace
	SI_AWEMOD_BALANCING="Balancing",
	SI_AWEMOD_BALANCING_HINT="Get a notification of your income bilance after visiting a vendor.",
	SI_AWEMOD_BALANCING_TOTAL="Show total",
	SI_AWEMOD_BALANCING_TOTAL_HINT="Show the currents session total bilance instead of the last bilance.",
	SI_AWEMOD_BALANCING_TIMER="Fade out (seconds)",
	SI_AWEMOD_BALANCING_TIMER_HINT="Set the time in seconds until this notification will be removed.",
	SI_AWEMOD_BALANCING_LABEL="Balance",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
