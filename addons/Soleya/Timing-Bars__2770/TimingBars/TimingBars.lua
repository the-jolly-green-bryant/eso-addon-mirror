-- Addon namespace
TimingBars = {}

TimingBars.name = "TimingBars"

TimingBars.mHealthBarX = 0
TimingBars.mHealthBarY = 0

TimingBars.mBuffBarX = 0
TimingBars.mBuffBarY = 0

TimingBars.mSwapButtonX = 0
TimingBars.mSwapButtonY = 0
TimingBars.mActionBarX = 0
TimingBars.mActionBarY = 0

TimingBars.mAction3ButtonX = 0
TimingBars.mAction3ButtonY = 0
TimingBars.mAction4ButtonX = 0
TimingBars.mAction4ButtonY = 0
TimingBars.mAction5ButtonX = 0
TimingBars.mAction5ButtonY = 0
TimingBars.mAction6ButtonX = 0
TimingBars.mAction6ButtonY = 0
TimingBars.mAction7ButtonX = 0
TimingBars.mAction7ButtonY = 0
TimingBars.mAction8ButtonX = 0
TimingBars.mAction8ButtonY = 0
TimingBars.mAction9ButtonX = 0
TimingBars.mAction9ButtonY = 0

TimingBars.mAction3TextX = 0
TimingBars.mAction3TextY = 0
TimingBars.mAction4TextX = 0
TimingBars.mAction4TextY = 0
TimingBars.mAction5TextX = 0
TimingBars.mAction5TextY = 0
TimingBars.mAction6TextX = 0
TimingBars.mAction6TextY = 0
TimingBars.mAction7TextX = 0
TimingBars.mAction7TextY = 0
TimingBars.mAction8TextX = 0
TimingBars.mAction8TextY = 0
TimingBars.mAction9TextX = 0
TimingBars.mAction9TextY = 0

TimingBars.mIcon1 = {
	[1] = "",
	[2] = "",
	[3] = "",
	[4] = "",
	[5] = "",
	[6] = "",
}

TimingBars.mIcon2 = {
	[1] = "",
	[2] = "",
	[3] = "",
	[4] = "",
	[5] = "",
	[6] = "",
}

TimingBars.mBarButtons = {
	[1] = nil,
	[2] = nil,
	[3] = nil,
	[4] = nil,
	[5] = nil,
	[6] = nil,
}

TimingBars.mBarCooldowns = {
	[1] = nil,
	[2] = nil,
	[3] = nil,
	[4] = nil,
	[5] = nil,
	[6] = nil,
	[7] = nil,
	[8] = nil,
	[9] = nil,
	[10] = nil,
	[11] = nil,
	[12] = nil,
}


TimingBars.mTimeText = 
{
	[1] = nil,
	[2] = nil,
	[3] = nil,
	[4] = nil,
	[5] = nil,
	[6] = nil,
	[7] = nil,
	[8] = nil,
	[9] = nil,
	[10] = nil,
	[11] = nil,
	[12] = nil,
}

TimingBars.mTimers = 
{
	[1] =  0,
	[2] =  0,
	[3] =  0,
	[4] =  0,
	[5] =  0,
	[6] =  0,
	[7] =  0,
	[8] =  0,
	[9] =  0,
	[10] = 0,
	[11] = 0,
	[12] = 0,
}


TimingBars.mSlotData			= {}

-- Initialize addon
function TimingBars:Initialize()

	TimingBars.mHealthBarX = math.floor(ZO_PlayerAttributeHealth:GetLeft())
	TimingBars.mHealthBarY = math.floor(ZO_PlayerAttributeHealth:GetTop())

	--TimingBars.mBuffBarX = math.floor(ZO_BuffDebuffTopLevel:GetLeft())
	--TimingBars.mBuffBarY = math.floor(ZO_BuffDebuffTopLevel:GetTop())
	--d(string.format("|cFFFFFF%d %d|cFFFF00Buff Bar Pos", TimingBars.mBuffBarX, TimingBars.mBuffBarY))

	TimingBars.mSwapButtonX = math.floor(ZO_ActionBar1WeaponSwap:GetLeft())
	TimingBars.mSwapButtonY = math.floor(ZO_ActionBar1WeaponSwap:GetTop())

	TimingBars.mActionBarX = math.floor(ZO_ActionBar1KeybindBG:GetLeft())
	TimingBars.mActionBarY = math.floor(ZO_ActionBar1KeybindBG:GetTop())

	TimingBars.mAction3ButtonX = math.floor (ActionButton3:GetLeft ())
	TimingBars.mAction3ButtonY = math.floor (ActionButton3:GetTop ())
	TimingBars.mAction4ButtonX = math.floor (ActionButton4:GetLeft ())
	TimingBars.mAction4ButtonY = math.floor (ActionButton4:GetTop ())
	TimingBars.mAction5ButtonX = math.floor (ActionButton5:GetLeft ())
	TimingBars.mAction5ButtonY = math.floor (ActionButton5:GetTop ())
	TimingBars.mAction6ButtonX = math.floor (ActionButton6:GetLeft ())
	TimingBars.mAction6ButtonY = math.floor (ActionButton6:GetTop ())
	TimingBars.mAction7ButtonX = math.floor (ActionButton7:GetLeft ())
	TimingBars.mAction7ButtonY = math.floor (ActionButton7:GetTop ())
	TimingBars.mAction8ButtonX = math.floor (ActionButton8:GetLeft ())
	TimingBars.mAction8ButtonY = math.floor (ActionButton8:GetTop ())
	TimingBars.mAction9ButtonX = math.floor (ActionButton9:GetLeft ())
	TimingBars.mAction9ButtonY = math.floor (ActionButton9:GetTop ())

	TimingBars.mAction3TextX = math.floor (ActionButton3ButtonText:GetLeft ())
	TimingBars.mAction3TextY = math.floor (ActionButton3ButtonText:GetTop ())
	TimingBars.mAction4TextX = math.floor (ActionButton4ButtonText:GetLeft ())
	TimingBars.mAction4TextY = math.floor (ActionButton4ButtonText:GetTop ())
	TimingBars.mAction5TextX = math.floor (ActionButton5ButtonText:GetLeft ())
	TimingBars.mAction5TextY = math.floor (ActionButton5ButtonText:GetTop ())
	TimingBars.mAction6TextX = math.floor (ActionButton6ButtonText:GetLeft ())
	TimingBars.mAction6TextY = math.floor (ActionButton6ButtonText:GetTop ())
	TimingBars.mAction7TextX = math.floor (ActionButton7ButtonText:GetLeft ())
	TimingBars.mAction7TextY = math.floor (ActionButton7ButtonText:GetTop ())
	TimingBars.mAction8TextX = math.floor (ActionButton8ButtonText:GetLeft ())
	TimingBars.mAction8TextY = math.floor (ActionButton8ButtonText:GetTop ())
	TimingBars.mAction9TextX = math.floor (ActionButton9ButtonText:GetLeft ())
	TimingBars.mAction9TextY = math.floor (ActionButton9ButtonText:GetTop ())

	for i = 1, 6 do
		b = WINDOW_MANAGER:CreateControl (nil, ZO_ActionBar1WeaponSwap, CT_BUTTON)
		b:SetMouseEnabled (true)
		b:SetHandler ("OnMouseEnter", function (self)
			if self.text ~= nil then ZO_Tooltips_ShowTextTooltip (self, TOP, self.text) end
		end)
		b:SetHandler ("OnMouseExit", function (self) ZO_Tooltips_HideTextTooltip () end)
		b:SetDimensions(50, 50)
		b:SetAlpha(0.3)

		b:ClearAnchors()
	
		TimingBars.mBarButtons[i] = b

	end

	for i = 1, 12 do

		l = WINDOW_MANAGER:CreateControl (nil, ZO_ActionBar1WeaponSwap, CT_LABEL)
		l:SetFont("ZoFontGame")
		l:SetDimensions(40,40)
		l:SetText("")
		l:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		l:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		TimingBars.mTimeText[i] = l
	end

	TimingBars.mTimeText[1]:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,TimingBars.mAction3ButtonX+7, TimingBars.mAction3ButtonY-46)
	TimingBars.mTimeText[2]:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,TimingBars.mAction4ButtonX+7, TimingBars.mAction4ButtonY-46)
	TimingBars.mTimeText[3]:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,TimingBars.mAction5ButtonX+7, TimingBars.mAction5ButtonY-46)
	TimingBars.mTimeText[4]:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,TimingBars.mAction6ButtonX+7, TimingBars.mAction6ButtonY-46)
	TimingBars.mTimeText[5]:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,TimingBars.mAction7ButtonX+7, TimingBars.mAction7ButtonY-46)
	TimingBars.mTimeText[6]:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,TimingBars.mAction8ButtonX+7, TimingBars.mAction8ButtonY-46)

	TimingBars.mTimeText[7]:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,TimingBars.mAction3ButtonX+7, TimingBars.mAction3ButtonY+10)
	TimingBars.mTimeText[8]:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,TimingBars.mAction4ButtonX+7, TimingBars.mAction4ButtonY+10)
	TimingBars.mTimeText[9]:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,TimingBars.mAction5ButtonX+7, TimingBars.mAction5ButtonY+10)
	TimingBars.mTimeText[10]:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,TimingBars.mAction6ButtonX+7, TimingBars.mAction6ButtonY+10)
	TimingBars.mTimeText[11]:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,TimingBars.mAction7ButtonX+7, TimingBars.mAction7ButtonY+10)
	TimingBars.mTimeText[12]:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,TimingBars.mAction8ButtonX+7, TimingBars.mAction8ButtonY+10)


	TimingBars.mBarButtons[1]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction3ButtonX, TimingBars.mAction3ButtonY)
	TimingBars.mBarButtons[2]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction4ButtonX, TimingBars.mAction4ButtonY)
	TimingBars.mBarButtons[3]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction5ButtonX, TimingBars.mAction5ButtonY)
	TimingBars.mBarButtons[4]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction6ButtonX, TimingBars.mAction6ButtonY)
	TimingBars.mBarButtons[5]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction7ButtonX, TimingBars.mAction7ButtonY)
	TimingBars.mBarButtons[6]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction8ButtonX, TimingBars.mAction8ButtonY)
	
	for slot = 3, 8 do
		TimingBars.mSlotData[slot] = {}
		TimingBars.OnActionSlotUpdated(0, slot) -- populate initial data (before events registered so no triggers before setup is done)
	end

	for i = 1, 12 do
		local gameTime      = GetGameTimeMilliseconds() / 1000
		cooldown = WINDOW_MANAGER:CreateControl( nil , ZO_ActionBar1WeaponSwap , CT_COOLDOWN )
		cooldown:SetDimensions( 52, 52 )
		cooldown:ClearAnchors()
		cooldown:SetFillColor( 1, 1, 1, 1 )
		cooldown:SetAlpha(0.5)
	
		TimingBars.mBarCooldowns[i] = cooldown
	end

	TimingBars.mBarCooldowns[1]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction3ButtonX, TimingBars.mAction3ButtonY-52)
	TimingBars.mBarCooldowns[2]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction4ButtonX, TimingBars.mAction4ButtonY-52)
	TimingBars.mBarCooldowns[3]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction5ButtonX, TimingBars.mAction5ButtonY-52)
	TimingBars.mBarCooldowns[4]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction6ButtonX, TimingBars.mAction6ButtonY-52)
	TimingBars.mBarCooldowns[5]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction7ButtonX, TimingBars.mAction7ButtonY-52)
	TimingBars.mBarCooldowns[6]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction8ButtonX, TimingBars.mAction8ButtonY-52)

	TimingBars.mBarCooldowns[7]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction3ButtonX, TimingBars.mAction3ButtonY)
	TimingBars.mBarCooldowns[8]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction4ButtonX, TimingBars.mAction4ButtonY)
	TimingBars.mBarCooldowns[9]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction5ButtonX, TimingBars.mAction5ButtonY)
	TimingBars.mBarCooldowns[10]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction6ButtonX, TimingBars.mAction6ButtonY)
	TimingBars.mBarCooldowns[11]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction7ButtonX, TimingBars.mAction7ButtonY)
	TimingBars.mBarCooldowns[12]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction8ButtonX, TimingBars.mAction8ButtonY)



	EVENT_MANAGER:RegisterForEvent(TimingBars.name, EVENT_ACTION_SLOTS_FULL_UPDATE,	TimingBars.OnActionSlotsFullUpdate)
	EVENT_MANAGER:RegisterForEvent(TimingBars.name, EVENT_ACTION_SLOT_UPDATED,		TimingBars.OnActionSlotUpdated)

	EVENT_MANAGER:RegisterForEvent(TimingBars.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, TimingBars.WeaponSwapped)
	EVENT_MANAGER:RegisterForEvent(TimingBars.name, EVENT_ACTION_SLOT_ABILITY_USED,	TimingBars.AbilityUsed)

	EVENT_MANAGER:RegisterForUpdate(TimingBars.name, 100, TimingBars.UpdateTimingTexts)

end
 
-- Loaded event
function TimingBars.OnAddOnLoaded(event, addonName)
	-- Check to see if this event is for TimingBars addon.
	if (TimingBars.name ~= addOnName) then return end

end

-- Load screen, output data to chat window
function TimingBars.LoadScreen()
	TimingBars.Initialize()
	
	TimingBars.UpdateUI()
	d(string.format("|cFFFFFF%s |cFFFF00by |c8000FFSoleya", TimingBars.name))
	EVENT_MANAGER:UnregisterForEvent(TimingBars.name, EVENT_PLAYER_ACTIVATED)
end

-- Note: Skill Boxes are 52x52

function TimingBars:UpdateUI ()

	local pair, _ = GetActiveWeaponPairInfo ()
	local buttonOffsetY = 52
	local textOffsetY = 124

	if TimingBars.mBarButtons[1] == nil then return end

	if pair == 2 then
		buttonOffsetY = 0
		textOffsetY = 0

		TimingBars.mIcon2[1] = GetSlotTexture(3)
		TimingBars.mIcon2[2] = GetSlotTexture(4)
		TimingBars.mIcon2[3] = GetSlotTexture(5)
		TimingBars.mIcon2[4] = GetSlotTexture(6)
		TimingBars.mIcon2[5] = GetSlotTexture(7)
		TimingBars.mIcon2[6] = GetSlotTexture(8)
	else
		TimingBars.mIcon1[1] = GetSlotTexture(3)
		TimingBars.mIcon1[2] = GetSlotTexture(4)
		TimingBars.mIcon1[3] = GetSlotTexture(5)
		TimingBars.mIcon1[4] = GetSlotTexture(6)
		TimingBars.mIcon1[5] = GetSlotTexture(7)
		TimingBars.mIcon1[6] = GetSlotTexture(8)
	end

	ZO_ActionBar1WeaponSwap:ClearAnchors()
	ZO_ActionBar1WeaponSwap:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mSwapButtonX, TimingBars.mSwapButtonY-26)

	ZO_PlayerAttributeHealth:ClearAnchors()
	ZO_PlayerAttributeHealth:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mHealthBarX, TimingBars.mHealthBarY-44)

	--ZO_BuffDebuffTopLevel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mBuffBarX, TimingBars.mHealthBarY-88);
	--ZO_BuffDebuffExpiresInStyle:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mBuffBarX, TimingBars.mBuffBarY-104);
	--ZO_BuffDebuff:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mBuffBarX, TimingBars.mBuffBarY-104);

	ActionButton3:ClearAnchors()
	ActionButton3:SetAnchor (TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction3ButtonX, TimingBars.mAction3ButtonY - buttonOffsetY)

	ActionButton4:ClearAnchors()
	ActionButton4:SetAnchor (TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction4ButtonX, TimingBars.mAction4ButtonY - buttonOffsetY)

	ActionButton5:ClearAnchors()
	ActionButton5:SetAnchor (TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction5ButtonX, TimingBars.mAction5ButtonY - buttonOffsetY)

	ActionButton6:ClearAnchors()
	ActionButton6:SetAnchor (TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction6ButtonX, TimingBars.mAction6ButtonY - buttonOffsetY)

	ActionButton7:ClearAnchors()
	ActionButton7:SetAnchor (TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction7ButtonX, TimingBars.mAction7ButtonY - buttonOffsetY)

	ActionButton8:ClearAnchors()
	ActionButton8:SetAnchor (TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction8ButtonX, TimingBars.mAction8ButtonY - buttonOffsetY)


	ActionButton3ButtonText:ClearAnchors ()
	ActionButton3ButtonText:SetAnchor (TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction3TextX, TimingBars.mAction3TextY - textOffsetY)

	ActionButton4ButtonText:ClearAnchors ()
	ActionButton4ButtonText:SetAnchor (TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction4TextX, TimingBars.mAction4TextY - textOffsetY)

	ActionButton5ButtonText:ClearAnchors ()
	ActionButton5ButtonText:SetAnchor (TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction5TextX, TimingBars.mAction5TextY - textOffsetY)

	ActionButton6ButtonText:ClearAnchors ()
	ActionButton6ButtonText:SetAnchor (TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction6TextX, TimingBars.mAction6TextY - textOffsetY)

	ActionButton7ButtonText:ClearAnchors ()
	ActionButton7ButtonText:SetAnchor (TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction7TextX, TimingBars.mAction7TextY - textOffsetY)

	ActionButton8ButtonText:ClearAnchors ()
	ActionButton8ButtonText:SetAnchor (TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction8TextX, TimingBars.mAction8TextY - textOffsetY)
	
	ActionButton9:ClearAnchors()
	ActionButton9:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction9ButtonX, TimingBars.mAction9ButtonY)


	if pair == 1 then

		for i = 1, 6 do
			local b = TimingBars.mBarButtons[i]
			if (b) then
				b:ClearAnchors()
				if TimingBars.mIcon2[i] == "" then
					b:SetNormalTexture("ESOUI/art/actionbar/quickslotbg.dds")
					b.text = nil
				else
					b:SetNormalTexture (TimingBars.mIcon2[i])
					b.text = nil
				--b.text = zo_strformat(SI_ABILITY_NAME, name)
				end
			end
		end

		TimingBars.mBarButtons[1]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction3ButtonX+1, TimingBars.mAction3ButtonY+1)
		TimingBars.mBarButtons[2]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction4ButtonX+1, TimingBars.mAction4ButtonY+1)
		TimingBars.mBarButtons[3]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction5ButtonX+1, TimingBars.mAction5ButtonY+1)
		TimingBars.mBarButtons[4]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction6ButtonX+1, TimingBars.mAction6ButtonY+1)
		TimingBars.mBarButtons[5]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction7ButtonX+1, TimingBars.mAction7ButtonY+1)
		TimingBars.mBarButtons[6]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction8ButtonX+1, TimingBars.mAction8ButtonY+1)
	else

		for i = 1, 6 do
			local b = TimingBars.mBarButtons[i]
			if (b) then
				b:ClearAnchors()
				if TimingBars.mIcon1[i] == "" then
					b:SetNormalTexture("ESOUI/art/actionbar/quickslotbg.dds")
					b.text = nil
				else
					b:SetNormalTexture (TimingBars.mIcon1[i])
					b.text = nil
				--b.text = zo_strformat(SI_ABILITY_NAME, name)
				end
			end
		end
		
		TimingBars.mBarButtons[1]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction3ButtonX+1, TimingBars.mAction3ButtonY-51)
		TimingBars.mBarButtons[2]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction4ButtonX+1, TimingBars.mAction4ButtonY-51)
		TimingBars.mBarButtons[3]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction5ButtonX+1, TimingBars.mAction5ButtonY-51)
		TimingBars.mBarButtons[4]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction6ButtonX+1, TimingBars.mAction6ButtonY-51)
		TimingBars.mBarButtons[5]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction7ButtonX+1, TimingBars.mAction7ButtonY-51)
		TimingBars.mBarButtons[6]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TimingBars.mAction8ButtonX+1, TimingBars.mAction8ButtonY-51)
	end


end

function TimingBars:WeaponSwapped()
	TimingBars.UpdateUI()

end

function TimingBars:UpdateSlotTime(bar, slot, time)
	
	index = (slot-2)
	if (bar == 2) then 
		index = index + 6 
	end

	currentTime = GetGameTimeMilliseconds()
	TimingBars.mTimers[index] = currentTime+time

end

function TimingBars.UpdateTimingTexts()
	currentTime = GetGameTimeMilliseconds()
	for i = 1, 12 do
		timeLeft = TimingBars.mTimers[i] - currentTime
		sec = timeLeft / 1000
		ms = timeLeft % 1000

		local l = TimingBars.mTimeText[i]
		if (l ~= nil) then
			if(timeLeft > 0) then
				l:SetText(string.format("%d.%02d", sec, ms))
			else
				l:SetText("")
			end
		end
	end

end


function TimingBars.OnActionSlotUpdated(evt, slot)

	if (slot < 3 or slot > 8) then return end -- abort if not a main ability (or ultimate)

	abilityID	= GetSlotBoundId(slot)
	slotData	= TimingBars.mSlotData[slot]

	if (slotData.abilityID == abilityID) then return end -- nothing has changed, abort

	abilityName				= GetAbilityName(abilityID)

	slotData.abilityID		= abilityID
	slotData.abilityName	= abilityName
	slotData.abilityIcon	= GetAbilityIcon(abilityID)
	slotData.abilityDuration	= GetAbilityDuration(abilityID)

	--d("---------------------------")
	--d(slotData.abilityID)

	-- use this to see what skill names are
	--d(slotData.abilityName)
	--d(slotData.abilityIcon)


	isChannel, castTime, channelTime = GetAbilityCastInfo(abilityID)

	if (castTime > 0 or channelTime > 0) then
		slotData.isDelayed		= true			-- check for needing a cast bar
		slotData.isChannel		= isChannel
		slotData.castTime		= castTime
		slotData.channelTime	= channelTime
	else
		slotData.isDelayed		= false
	end

end

function TimingBars.OnActionSlotsFullUpdate()
	for slot = 3, 8 do
		TimingBars.OnActionSlotUpdated(0, slot)
	end
end


function TimingBars.AbilityUsed(evt, slot)
	if (slot < 3 or slot > 8) then return end

	local pair, _ = GetActiveWeaponPairInfo ()

	data = TimingBars.mSlotData[slot]

	--d(string.format("channel = "))

	--d(data.abilityName)
	--d(data.abilityID)

	local index = slot-2;
	if pair == 2 then
		index = slot + 4;
	end

--(currentTime + (data.isChannel and data.channelTime or data.castTime) + GetLatency()) / 1000,

	if data.abilityDuration > 0 then
		TimingBars:UpdateSlotTime(pair, slot, data.abilityDuration)
		if TimingBars.mBarCooldowns[index] ~= nil then
			TimingBars.mBarCooldowns[index]:StartCooldown( (data.abilityDuration), (data.abilityDuration), CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false )
		end
	end

end

-- Register our event
EVENT_MANAGER:RegisterForEvent(TimingBars.name, EVENT_ADD_ON_LOADED, TimingBars.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(TimingBars.name, EVENT_PLAYER_ACTIVATED, TimingBars.LoadScreen)








-- local abilityIndex = 1
-- local skillType, skillIndex = GetCraftingSkillLineIndices (CRAFTING_TYPE_ALCHEMY)
-- local skillName, skillRank = GetSkillLineInfo (skillType, skillIndex)
-- local abilityName, abilityIcon = GetSkillAbilityInfo (skillType, skillIndex, abilityIndex)




