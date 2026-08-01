LckSmth = LckSmth or {}
local LckSmth = LckSmth

LckSmth.name = "Locksmith"
LckSmth.version = "1.0"

local BAR_WIDTH = 10

-- From esoui/ingame/lockpick/lockpick.xml 
local PIN_MIN,		PIN_MAX 	 = 110, 97
local SPRING_MIN, 	SPRING_MAX 	 = 99,  90
local X_OFFSET_MIN, X_OFFSET_MAX = 175, 357
local Y_OFFSET_MIN, Y_OFFSET_MAX = -83, -86

-- Linear sampling between min and max points.
-- Gets close-ish to the hardcoded values from the lockpick.xml and still looks ok
local function GetPerspectiveShiftValue(base, max, chamber)
	return math.ceil(base + (chamber - 1) * (max - base) / (NUM_LOCKPICK_CHAMBERS - 1))
end

-- Make the bars respect the alpha changes.
-- TODO: Maybe also do the perfect-window-markers here?
local function UpdateAlpha(self, alpha, ignoreIndex, allowHighlights)
	for i = 1, NUM_LOCKPICK_CHAMBERS do
		if i ~= ignoreIndex then
			LckSmth.bars[i]:SetAlpha(alpha)
		end
	end
end

-- Reset variables and visuals for a fresh lock
local function Reset(self)
	for i = 1, NUM_LOCKPICK_CHAMBERS do
		local pinheight    = GetPerspectiveShiftValue(PIN_MIN, PIN_MAX, i)
		local springheight = GetPerspectiveShiftValue(SPRING_MIN, SPRING_MAX, i)
		local height 	   = pinheight + springheight - 10
	
		LckSmth.bars[i]:SetColor(1, 1, 0)
		LckSmth.bars[i]:SetDimensions(BAR_WIDTH, height)
		LckSmth.maxDepression[i] = 0
		LckSmth.solutions[i]:SetHidden(true)
	end
end

local function OnUpdate()
	local chamber = LOCK_PICK.settingChamberIndex
	if chamber then
		local state, progress = GetChamberState(chamber)
		local totalprogress = state + progress
		
		local pinheight    = GetPerspectiveShiftValue(PIN_MIN, PIN_MAX, chamber)
		local springheight = GetPerspectiveShiftValue(SPRING_MIN, SPRING_MAX, chamber)
		local height 	   = pinheight + springheight * (1 - totalprogress / 5) - 10
	
		-- Update max depression value and visually update progress
		if LckSmth.maxDepression[chamber] < totalprogress then
			LckSmth.maxDepression[chamber] = totalprogress			
			LckSmth.bars[chamber]:SetHeight(height)
		end
		
		-- If there is stress, that is the point of solution, so show that!
		if GetSettingChamberStress() ~= 0 then
			local offset = pinheight + springheight * (1 - (state + 1) / 5)	
			LckSmth.solutions[chamber]:SetAnchor(BOTTOMLEFT, LckSmth.bars[chamber], BOTTOMLEFT, 0, -offset)
			LckSmth.solutions[chamber]:SetHidden(false)
		end	
	end
	
	-- Change color of solved chamber's bars to green
	for i = 1, NUM_LOCKPICK_CHAMBERS do
		if IsChamberSolved(i) then
			LckSmth.bars[i]:SetColor(0, 1, 0)
		end
	end
	
end

local function InitializeUI()
	local body = LOCK_PICK.body
	
	-- Create the maximum depression bar and the solution window for all chambers.
	for i = 1, NUM_LOCKPICK_CHAMBERS do
		local x 		   = GetPerspectiveShiftValue(X_OFFSET_MIN - BAR_WIDTH, X_OFFSET_MAX - BAR_WIDTH, i)
		local y 		   = GetPerspectiveShiftValue(Y_OFFSET_MIN, Y_OFFSET_MAX, i)
		local pinheight    = GetPerspectiveShiftValue(PIN_MIN, PIN_MAX, i)
		local springheight = GetPerspectiveShiftValue(SPRING_MIN, SPRING_MAX, i)
	
		local bar = WINDOW_MANAGER:CreateControl("LockpickBar"..i, body, CT_TEXTURE)
		bar:SetDimensions(BAR_WIDTH, pinheight + springheight - 10)
		bar:SetColor(1, 1, 0)
		bar:SetAnchor(BOTTOMLEFT, body, BOTTOMLEFT, x, y)
		LckSmth.bars[i] = bar
		
		local solution = WINDOW_MANAGER:CreateControl("LockpickBarSolution"..i, body, CT_TEXTURE)
		solution:SetDimensions(BAR_WIDTH + 30, springheight / 10)
		solution:SetAnchor(BOTTOMLEFT, body:GetNamedChild("LockpickBar"..i), BOTTOMLEFT)
		solution:SetColor(1, 0, 0)
		solution:SetAlpha(0.75)
		solution:SetHidden(true)
		LckSmth.solutions[i] = solution
		LckSmth.maxDepression[i] = 0
	end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= LckSmth.name then return end
    EVENT_MANAGER:UnregisterForEvent(LckSmth.name, EVENT_ADD_ON_LOADED)

    LckSmth.bars = {}
	LckSmth.solutions = {}
	LckSmth.maxDepression = {}
	
	InitializeUI()

	ZO_PostHook(LOCK_PICK, "UpdatePinAlpha", UpdateAlpha)
	ZO_PostHook(LOCK_PICK, "ResetChambers", Reset)
	ZO_PostHook(LOCK_PICK, "OnUpdate", OnUpdate)
end
EVENT_MANAGER:RegisterForEvent(LckSmth.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)