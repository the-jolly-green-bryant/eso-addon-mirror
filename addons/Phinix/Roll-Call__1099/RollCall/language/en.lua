RollCallAddon = WINDOW_MANAGER:CreateControl(nil, GuiRoot)
local RC = _G['RollCallAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- English
------------------------------------------------------------------------------------------------------------------

--Strings for /toss.
L.RollCallToss1			= "Heads."
L.RollCallToss2			= "Tails."
L.RollCallToss3			= " tosses a Drake and it lands "
L.RollCallTossQ1		= "[Toss] Use: /toss option"
L.RollCallTossQ2		= "[Toss] Valid option is 2 (meaning 2 sided coin)."
L.RollCallTossQ3		= "[Toss] Default (when no/invalid value entered) is 2."

--Strings for /roll.
L.RollCallRoll1			= "[Roll] of "
L.RollCallRoll2			= " out of "
L.RollCallRoll3			= " by: "
L.RollCallRoll4			= " tosses "
L.RollCallRoll5			= " tosses a Wooden Die and rolls a "
L.RollCallRoll6			= " Wooden Dice and rolls "
L.RollCallRollQ1		= "[Roll] Use: /roll option"
L.RollCallRollQ2		= "[Roll] Valid options are 6, 10, 12, 18, 24, 50, 100, & 1000."
L.RollCallRollQ3		= "[Roll] Default (when no/invalid value entered) is 100. See options."
L.RollCallRollQ4		= "[Roll] 'Special' values are 6, 12, 18, and 24."

--Settings panel strings.
L.RollCallCharOpt		= "Character options"
L.RollCallRollO			= "Default Roll Option"
L.RollCallRollOD		= "Choose the default behavior when typing /roll by itself without a number option. Default is a standard roll out of 100. See options."
L.RollCallOpt1			= "Roll 1 die."
L.RollCallOpt2			= "Roll 2 dice."
L.RollCallOpt3			= "Roll 3 dice."
L.RollCallOpt4			= "Roll 4 dice."
L.RollCallOpt5			= "Roll / 10"
L.RollCallOpt6			= "Roll / 20"
L.RollCallOpt7			= "Roll / 50"
L.RollCallOpt8			= "Roll / 100"
L.RollCallOpt9			= "Roll / 1000"
L.RollCallDC			= "Disable In Combat"
L.RollCallDCD			= "Prevents RollCall from responding to pings if you are in combat. Avoids unwanted chat spam during group fights where map pinging is frequent due to DPS sharing addons."
L.RollCallCM			= "Enable Chat Mode"
L.RollCallCMD			= "Enable sending output (without graphics) to the active chat instead of group. NOTE: You will still need to manually hit enter to post due to API limitations preventing chat spam via addons."


------------------------------------------------------------------------------------------------------------------

function RC:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
