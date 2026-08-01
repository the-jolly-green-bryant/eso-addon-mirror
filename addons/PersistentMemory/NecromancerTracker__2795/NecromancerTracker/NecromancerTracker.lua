NecromancerTracker = {}

NecromancerTracker.name="NecromancerTracker"

local blastBones = { 114863, 117750, 117691,  } -- blastbones, stalking blastbones, blighted blastbones
--local blastBonesAbility = { 114860, 117690, 117749 } -- for some reason it looks like the ability is different from the effect but only for blastBones
local skeletalMage = { 114317, 118726 } --mage, arcanist
local skeletalArcher =  118680
local spiritMender = { 115710, 118840, 118912 } -- spirit mender, intensive mender, spirit guardian

local blastBonesLines = {
"Blastbones go BOOM",
"BONSAI!!",
"There's viscera everywhere",
"That's gonna need drycleaning", 
"Tell my wife I love her!",
"I just rolled a nat 1",
"I just rolled a nat 20 to die!",
"Bring me baaaaaaack",
"Take me hoooooome",
"Cleanup, aisle 3",
"YEET",
"Country roooooooads",
"So that's where my arms went",
"BOOM",
"Shaka-laka",
"This blows. Get it?",
"DETH SURROUNDS MI",
"Ayiyiyiyiyi",
"Yipee-kai-yi-yay?",
"Wheeeee",
"Cowabunga. Cowabunga it is",
"ssssssssssssssss",
"*screeching*",
"I have an Int of 6, I know what I'm doing!",
"It's not a phase, ma",
"Imagine if I had a real weapon",
"Play Nexus of Fate!",
"Blastbones was not the impostor",
"*insert meme here*",
"You should donate gold to PersistentMemory",
"Yee-haw!",
"I'm one bad mamma-jamma!",
"eeeeeeeeeeeeeeeeee",
"Legends never die, but I do!",
"Have you finished the story quests yet?",
"Get a load of this!",
"More!!",
"10/10 A++ would blow up again",
"Are ya proud??",
"Let me iiiiiiin",
"Give it to me!",
"Badaboom!",
"Feel better yet?"
}

local skeletalMageSummonLines = {
"Once more into the breach I suppose",
"Ugh, again?",
"Vast arcane power and this is what you do with it?",
"If I must",
"I don't know why I bother with you",
"Who works for whom now?",
"So be it",
"But I was having tea",
"Found new ways to disappoint me?",
"This is the worst part of my day",
"You again?",
"Less, please",
"I'm filing a complaint",
"This is endless",
"This is what you do with your time?"
}

local skeletalMageUnsummonLines = {
"You're really not paying me enough for this",
"This has been a complete waste of my time",
"I know you'll drag me back",
"Until next time, sadly",
"It is done",
"It is a business doing business with you",
"Tolerating you took all my energy",
"Well that's that",
"Please don't call again",
"Heavens, that was an ordeal",
"0/10 would not do again",
"A temporary respite",
"Don't call on me again"
}

local spiritMenderSummonLines = {
"Ahhhhh whyyyyyyyyy",
"I really don't want to be here",
"I was so happy for a time",
"Why can't you heal yourself?",
"A Templar would be way better at this",
"I hate all this",
"Why do you torture me so?",
"You're the real monster, you know",
"I don't suppose we can talk about this?",
"You don't need me, the power is in you",
"You do know I hate this right?",
"Existence is pain",
"You put me through this",
"I have a bad feeling about this",
"Does it ever end?"
}

local spiritMenderUnsummonLines = {
"Finally",
"Thank goodness",
"The sweet embrace of oblivion awaits",
"The pleasant silence",
"Lovely",
"Peace at last",
"To my respite",
"My reward!",
"I'm taking my healing and going home",
"And now to rest",
"Much better",
"Is it over? Please?",
"Sweet nonexistence!",
"How death teases",
"Thank whoever and whatever"
}

local skeletalArcherSummonLines = {
"You got it boss!",
"Let's shoot something!",
"Pew pew pew",
"I forgot my arrows!",
"I love all this!",
"Can do!",
"This is totally metal",
"Let's get 'em!",
"I wanna shoot something!",
"Point me at 'em!",
"You get shot! You get shot! Everyone gets shot!",
"A skeleton walks into a dungeon",
"More!",
"Let's go!",
"Welcome to the rice fields!",
"Gonna shoot 'em good",
"Again, again!",
"I have a good feeling about this!"
}

local skeletalArcherUnsummonLines = {
"I'm outta here",
"See you soon!",
"Why you gotta let me go?",
"Nooooooooo",
"See ya later!",
"Let's do that again!",
"I miss Cries-Over-Bunnies",
"Did I do good?",
"Wait, what happened?",
"I'll say hi to Blastbones!",
"Gotta reload!",
"But he had no body to go with! Zing!",
"Less!",
"That was dangerous!",
"Arrows out!",
"I can't wait for more!"
}

NecromancerTracker.defaults = {
    showBb = true,
	showMage = true,
	showMender = true,
	alwaysShow = false,
	bbSummons = 0,
	mageSummons = 0,
	archerSummons = 0,
	menderSummons = 0,
	bbFont = 24,
	indicatorFont = 14,
	humor = true,
	bbHide = false
}

local showBb = true
local showMage = true
local showMender = true
local alwaysShow = false
local bbLeft = false
local inCombat = false
local fontPath = "EsoUI/Common/Fonts/Univers67.otf"
local leftFontDefault = 14
local bbFontDefault = 24

-- some data for LAM

local panelData = {
         type = "panel",
         name = "NecromancerTracker",
    }
	
local optionsData = {
		 [1] = {
				type = "header",
				name = "General Options",
				width = "full",	--or "half" (optional)
		 },
         [2] = {
              type = "checkbox",
              name = "Always Show",
              tooltip = "When on, will show the indicators even when out of combat",
              getFunc = function() return NecromancerTracker.savedVariables.alwaysShow end,
              setFunc = function(value) 
				NecromancerTracker.alwaysShow = value
				NecromancerTracker.savedVariables.alwaysShow = value
			  end,
         },
         [3] = {
              type = "checkbox",
              name = "Show Blastbones",
              tooltip = "When on, will show the Blastbones indicator",
              getFunc = function() return NecromancerTracker.savedVariables.showBb end,
              setFunc = function(value) 
				NecromancerTracker.showBb = value
				NecromancerTracker.savedVariables.showBb = value
			  end,
         },
         [4] = {
              type = "checkbox",
              name = "Show Mage/Arcanist/Archer",
              tooltip = "When on, will show the Skeletal Mage, Arcanist, or Archer indicator",
              getFunc = function() return NecromancerTracker.savedVariables.showMage end,
              setFunc = function(value) 
				NecromancerTracker.showMage = value
				NecromancerTracker.savedVariables.showMage = value
			  end,
         },
		 [5] = {
              type = "checkbox",
              name = "Show Mender",
              tooltip = "When on, will show the Spirit Mender indicator",
              getFunc = function() return NecromancerTracker.savedVariables.showMender end,
              setFunc = function(value) 
				NecromancerTracker.showMender = value
				NecromancerTracker.savedVariables.showMender = value
			  end,
         },
		 [6] = {
              type = "checkbox",
              name = "Blastbones lefthand tracker",
              tooltip = "When on, will show the Blastbones indicator on the lefthand side like the rest",
              getFunc = function() return NecromancerTracker.savedVariables.bbLeft end,
              setFunc = function(value) 
				NecromancerTracker.bbLeft = value
				NecromancerTracker.savedVariables.bbLeft = value
			  end,
         },
		 [7] = {
              type = "checkbox",
              name = "Hide Blastbones after combat",
              tooltip = "When on, will hide the Blastbones text when combat ends whether or not Always Show is on",
              getFunc = function() return NecromancerTracker.savedVariables.bbHide end,
              setFunc = function(value) 
				NecromancerTracker.savedVariables.bbHide = value
			  end,
         },
		 [8] = {
              type = "checkbox",
              name = "Humor",
              tooltip = "When on, will show the text lines",
              getFunc = function() return NecromancerTracker.savedVariables.humor end,
              setFunc = function(value) 
				NecromancerTracker.savedVariables.humor = value
			  end,
         },
		 [9] = {
			 type = "header",
			 name = "Font Sizes",
			 width = "full",	--or "half" (optional)
		 },
		 [10] = {
			 type = "dropdown",
			 name = "Lefthand Tracker Font Size",
			 tooltip = "Font Size Selector for the lefthand side trackers",
			 choices = {8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,28,30,32,34,36,40,48,54},
			 getFunc = function() return NecromancerTracker.savedVariables.indicatorFont end,
			 setFunc = function(var) 
				NecromancerTracker.savedVariables.indicatorFont = var
				BlastbonesLeftIndicatorLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
				SkeletalMageIndicatorLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
				SpiritMenderIndicatorLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
				BlastbonesLeftIndicatorSezLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
				SkeletalMageIndicatorSezLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
				SpiritMenderIndicatorSezLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
			 end,
			 width = "half",	--or "half" (optional)
        
		 },
		 [11] = {
			 type = "dropdown",
			 name = "Blastbones Font Size",
			 tooltip = "Font Size Selector for the Blastbones center indicator",
			 choices = {16,17,18,19,20,21,22,23,24,25,26,28,30,32,34,36,40,48,54},
			 getFunc = function() return NecromancerTracker.savedVariables.bbFont end,
			 setFunc = function(var) 
				NecromancerTracker.savedVariables.bbFont = var
				BlastbonesIndicatorLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.bbFont .. "|soft-shadow-thick")
				BlastbonesIndicatorSezLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.bbFont-8 .. "|soft-shadow-thick")
			 end,
			 width = "half",	--or "half" (optional)
        
		 },
    }

function NecromancerTracker.OnAddOnLoaded(event, addOnName)
	if addOnName == NecromancerTracker.name then
		NecromancerTracker:Initialize()
	end

end

function NecromancerTracker:Initialize() 
  EVENT_MANAGER:UnregisterForEvent(NecromancerTracker.name, EVENT_ADD_ON_LOADED)
  EVENT_MANAGER:RegisterForEvent(NecromancerTracker.name, EVENT_EFFECT_CHANGED, NecromancerTracker.OnEffectChanged )
  EVENT_MANAGER:AddFilterForEvent(NecromancerTracker.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
  EVENT_MANAGER:RegisterForEvent(NecromancerTracker.name, EVENT_PLAYER_COMBAT_STATE, NecromancerTracker.OnPlayerCombatState)
  
  -- register some callbacks we can use to hide/show the controllers 
  HUD_SCENE:RegisterCallback("StateChange", NecromancerTracker.sceneChange)
  HUD_UI_SCENE:RegisterCallback("StateChange", NecromancerTracker.sceneChange)
  
  -- initialize some options
  NecromancerTracker.savedVariables = ZO_SavedVars:NewCharacterIdSettings("NecromancerTrackerSavedVariables", 1, nil, NecromancerTracker.defaults)
  
  NecromancerTracker.showBb = NecromancerTracker.savedVariables.showBb
  NecromancerTracker.showMage = NecromancerTracker.savedVariables.showMage
  NecromancerTracker.showMender = NecromancerTracker.savedVariables.showMender
  
  NecromancerTracker.alwaysShow = NecromancerTracker.savedVariables.alwaysShow
  
  NecromancerTracker.humor = NecromancerTracker.savedVariables.humor
  NecromancerTracker.bbHide = NecromancerTracker.savedVariables.bbHide
  
  -- initialize LAM if it exists
  if(LibAddonMenu2 ~= nil) then
	NecromancerTracker.setupLAM(panelData, optionsData)
  end
  
  -- get some local defaults and put them into the NecromancerTracker vars - this isn't really useful per se but I dunno, future-proofing?
  NecromancerTracker.inCombat = inCombat
  NecromancerTracker.fontPath = fontPath
  NecromancerTracker.leftFontDefault = leftFontDefault
  NecromancerTracker.bbFontDefault = bbFontDefault
  
  
  -- initialize some showing stuff if they have always show on
  if NecromancerTracker.alwaysShow then
	if NecromancerTracker.showBb then
		if NecromancerTracker.bbLeft then
			BlastbonesLeftIndicator:SetHidden(false)
		else
			BlastbonesIndicator:SetHidden(false)
		end
	end
			
	if NecromancerTracker.showMage then
		SkeletalMageIndicator:SetHidden(false)
	end
			
	if NecromancerTracker.showMender then
		SpiritMenderIndicator:SetHidden(false)
	end
  end
  
  -- initialize font sizes from saved vars
  BlastbonesLeftIndicatorLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
  SkeletalMageIndicatorLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
  SpiritMenderIndicatorLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
  
  BlastbonesLeftIndicatorSezLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
  SkeletalMageIndicatorSezLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
  SpiritMenderIndicatorSezLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
  
  BlastbonesIndicatorLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.bbFont .. "|soft-shadow-thick")
  BlastbonesIndicatorSezLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.bbFont-8 .. "|soft-shadow-thick")
  
  -- initialize ui position from saved vars
 
  if NecromancerTracker.savedVariables.bbleft == nil then
	NecromancerTracker.savedVariables.bbleft = BlastbonesIndicator:GetLeft()
  end
  
  if NecromancerTracker.savedVariables.bbtop == nil then
	NecromancerTracker.savedVariables.bbtop = BlastbonesIndicator:GetTop()
  end

  if NecromancerTracker.savedVariables.bbsezleft == nil then
	NecromancerTracker.savedVariables.bbsezleft = BlastbonesIndicatorSezLabel:GetLeft()
  end
  
  if NecromancerTracker.savedVariables.bbseztop == nil then
	NecromancerTracker.savedVariables.bbseztop = BlastbonesIndicatorSezLabel:GetTop()
  end  
  
  if NecromancerTracker.savedVariables.bbleftleft == nil then
	NecromancerTracker.savedVariables.bbleftleft = BlastbonesLeftIndicator:GetLeft()
  end
  
  if NecromancerTracker.savedVariables.bblefttop == nil then
	NecromancerTracker.savedVariables.bblefttop = BlastbonesLeftIndicator:GetTop()
  end
  
  if NecromancerTracker.savedVariables.mageleft == nil then
	NecromancerTracker.savedVariables.mageleft = SkeletalMageIndicator:GetLeft()
  end
  
  if NecromancerTracker.savedVariables.magetop == nil then
	NecromancerTracker.savedVariables.magetop = SkeletalMageIndicator:GetTop()
  end	
  
  if NecromancerTracker.savedVariables.menderleft == nil then
	NecromancerTracker.savedVariables.menderleft = SpiritMenderIndicator:GetLeft()
  end
  
  if NecromancerTracker.savedVariables.mendertop == nil then
	NecromancerTracker.savedVariables.mendertop = SpiritMenderIndicator:GetTop()
  end
  
  BlastbonesIndicatorLabel:ClearAnchors()
  BlastbonesIndicatorLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, NecromancerTracker.savedVariables.bbleft, NecromancerTracker.savedVariables.bbtop)

  BlastbonesIndicatorSezLabel:ClearAnchors()
  BlastbonesIndicatorSezLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, NecromancerTracker.savedVariables.bbsezleft, NecromancerTracker.savedVariables.bbseztop)	
  
  BlastbonesLeftIndicator:ClearAnchors()
  BlastbonesLeftIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, NecromancerTracker.savedVariables.bbleftleft, NecromancerTracker.savedVariables.bblefttop)
		
  SkeletalMageIndicator:ClearAnchors()
  SkeletalMageIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, NecromancerTracker.savedVariables.mageleft, NecromancerTracker.savedVariables.magetop)	
	
  SpiritMenderIndicator:ClearAnchors()
  SpiritMenderIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, NecromancerTracker.savedVariables.menderleft, NecromancerTracker.savedVariables.mendertop)
	  
  -- initialize humor level
  if NecromancerTracker.savedVariables.humor then
	BlastbonesIndicatorSezLabel:SetText("Blastbones sez:")
  else
	BlastbonesIndicatorLabel:SetText("Recast Blastbones")
	BlastbonesIndicatorSezLabel:SetText("")
	BlastbonesLeftIndicatorLabel:SetText("")
	SkeletalMageIndicatorLabel:SetText("")
	SpiritMenderIndicatorLabel:SetText("")
  end
  
  -- initialize slash commands
  SLASH_COMMANDS["/ntshowbb"] = NecromancerTracker.ntshowbb
  SLASH_COMMANDS["/ntshowmage"] = NecromancerTracker.ntshowmage
  SLASH_COMMANDS["/ntshowmender"] = NecromancerTracker.ntshowmender
  SLASH_COMMANDS["/ntalwaysshow"] = NecromancerTracker.ntalwaysshow
  SLASH_COMMANDS["/ntstats"] = NecromancerTracker.ntstats
  SLASH_COMMANDS["/ntall"] = NecromancerTracker.ntall
  SLASH_COMMANDS["/ntbbleft"] = NecromancerTracker.ntbbleft
  SLASH_COMMANDS["/ntleftfont"] = NecromancerTracker.ntleftfont
  SLASH_COMMANDS["/ntbbfont"] = NecromancerTracker.ntbbfont
  SLASH_COMMANDS["/nthumor"] = NecromancerTracker.nthumor
  SLASH_COMMANDS["/ntbbhide"] = NecromancerTracker.ntbbhide
  
end

function NecromancerTracker.setupLAM(_panelData, _optionsData)
	LibAddonMenu2:RegisterAddonPanel("NecromancerTrackerOptions", _panelData)
	LibAddonMenu2:RegisterOptionControls("NecromancerTrackerOptions", _optionsData)
end

function NecromancerTracker.sceneChange(sceneName, oldState, newState)
   --CHAT_SYSTEM:AddMessage("oldstate: " .. oldState)
   --CHAT_SYSTEM:AddMessage("sceneName: " .. sceneName)
   if oldState == "shown" then
        if (not NecromancerTracker.alwaysShow and not NecromancerTracker.inCombat) then
			BlastbonesIndicator:SetHidden(true)
			SkeletalMageIndicator:SetHidden(true)
			SpiritMenderIndicator:SetHidden(true)
		elseif NecromancerTracker.inCombat or NecromancerTracker.alwaysShow then
			if NecromancerTracker.showBb then
				if NecromancerTracker.bbLeft then
					BlastbonesLeftIndicator:SetHidden(false)
				elseif NecromancerTracker.bbDown then
					if not NecromancerTracker.inCombat and not NecromancerTracker.bbHide then
						BlastbonesIndicator:SetHidden(false)
					elseif not NecromancerTracker.inCombat and NecromancerTracker.bbHide then
						BlastbonesIndicator:SetHidden(true)
					end
				-- this should be refactored
				elseif not NecromancerTracker.bbDown then
					if NecromancerTracker.inCombat then
						BlastbonesIndicator:SetHidden(false)
					elseif NecromancerTracker.bbHide then 
						BlastbonesIndicator:SetHidden(true)
					else 
						BlastbonesIndicator:SetHidden(false)
					end
				end
			end
			
			if NecromancerTracker.showMage then
				SkeletalMageIndicator:SetHidden(false)
			end
			
			if NecromancerTracker.showMender then
				SpiritMenderIndicator:SetHidden(false)
			end
		end
	elseif oldState == "hidden" then
		-- hide these whenever the UI is hidden
		BlastbonesLeftIndicator:SetHidden(true)
		BlastbonesIndicator:SetHidden(true)
		SkeletalMageIndicator:SetHidden(true)
		SpiritMenderIndicator:SetHidden(true)
    end
end

function NecromancerTracker.onActionSlotAbilityUsed(eventCode,slotNum)
	local abilityId = GetSlotBoundId(slotNum)
end

function NecromancerTracker.OnEffectChanged(eventCode,changeType,effectSlot,effectName,unitTag,beginTimeSec,endTimeSec,stackCount,iconName,buffType,
  effectType,abilityType,statusEffectType,unitName,unitId,abilityId,sourceType)
  -- was just used to check abilityIds
  --if changeType == EFFECT_RESULT_GAINED then
	--CHAT_SYSTEM:AddMessage("effect gained: " .. abilityId .. " " .. effectName)	
  --end
  --if changeType == EFFECT_RESULT_FADED then
	--CHAT_SYSTEM:AddMessage("effect ended: " .. abilityId .. " " .. effectName)	
  --end
  
  --blastbones  
  for index, value in ipairs(blastBones) do
	if value == blastBones[index] and value == abilityId then
		if changeType == EFFECT_RESULT_FADED and NecromancerTracker.showBb then
			NecromancerTracker.bbDown = true	
			if NecromancerTracker.humor then
				local line = blastBonesLines[math.random(#blastBonesLines)]
				BlastbonesIndicatorLabel:SetText(line)
				BlastbonesLeftIndicatorLabel:SetText(line)
			end
			BlastbonesLeftIndicatorSezLabel:SetColor(1,0,0)
			BlastbonesLeftIndicatorSezLabel:SetText("Blastbones inactive")
			if (not NecromancerTracker.bbLeft and (NecromancerTracker.inCombat or NecromancerTracker.alwaysShow)) then
				BlastbonesIndicator:SetHidden(false)
			end
		elseif changeType == EFFECT_RESULT_GAINED then
			NecromancerTracker.bbDown = false
			NecromancerTracker.savedVariables.bbSummons = NecromancerTracker.savedVariables.bbSummons + 1
			BlastbonesLeftIndicatorSezLabel:SetColor(0,1,0)
			BlastbonesLeftIndicatorSezLabel:SetText("Blastbones active")
			BlastbonesLeftIndicatorLabel:SetText("")
			if (NecromancerTracker.bbLeft and NecromancerTracker.showBb and (NecromancerTracker.inCombat or NecromancerTracker.alwaysShow)) then
				BlastbonesLeftIndicator:SetHidden(false)
			else
				BlastbonesIndicator:SetHidden(true)
			end
		end
		return
	end
  end
  
  --skeletal mage/arcanist
  for index, value in ipairs(skeletalMage) do
	if value == skeletalMage[index] and value == abilityId then
		if changeType == EFFECT_RESULT_FADED then
			SkeletalMageIndicatorSezLabel:SetColor(1,0,0)
			SkeletalMageIndicatorSezLabel:SetText("Skeletal Mage inactive")
			if NecromancerTracker.humor then
				SkeletalMageIndicatorLabel:SetText(skeletalMageUnsummonLines[math.random(#skeletalMageUnsummonLines)])
			end
		elseif changeType == EFFECT_RESULT_GAINED then
			NecromancerTracker.savedVariables.mageSummons = NecromancerTracker.savedVariables.mageSummons + 1
			SkeletalMageIndicatorSezLabel:SetColor(0,1,0)
			SkeletalMageIndicatorSezLabel:SetText("Skeletal Mage active")
			if NecromancerTracker.humor then
				SkeletalMageIndicatorLabel:SetText(skeletalMageSummonLines[math.random(#skeletalMageSummonLines)])
			end
			if (NecromancerTracker.showMage and (NecromancerTracker.inCombat or NecromancerTracker.alwaysShow)) then
				SkeletalMageIndicator:SetHidden(false)
			end
		end
		return
	end
  end
  
  -- skeletal archer
  if skeletalArcher == abilityId then
	if changeType == EFFECT_RESULT_FADED then
		SkeletalMageIndicatorSezLabel:SetColor(1,0,0)
		SkeletalMageIndicatorSezLabel:SetText("Skeletal Archer inactive")
		if NecromancerTracker.humor then
			SkeletalMageIndicatorLabel:SetText(skeletalArcherUnsummonLines[math.random(#skeletalArcherUnsummonLines)])
		end
	elseif changeType == EFFECT_RESULT_GAINED then
		NecromancerTracker.savedVariables.archerSummons = NecromancerTracker.savedVariables.archerSummons + 1
		SkeletalMageIndicatorSezLabel:SetColor(0,1,0)
		SkeletalMageIndicatorSezLabel:SetText("Skeletal Archer active")
		if NecromancerTracker.humor then
			SkeletalMageIndicatorLabel:SetText(skeletalArcherSummonLines[math.random(#skeletalArcherSummonLines)])
		end
		if (NecromancerTracker.showMage and (NecromancerTracker.inCombat or NecromancerTracker.alwaysShow)) then
			SkeletalMageIndicator:SetHidden(false)
		end
	end
	return
  end

  --spirit mender/intensive mender/spirit guardian
  for index, value in ipairs(spiritMender) do
	if value == spiritMender[index] and value == abilityId then
		if changeType == EFFECT_RESULT_FADED then
			SpiritMenderIndicatorSezLabel:SetColor(1,0,0)
			SpiritMenderIndicatorSezLabel:SetText("Spirit Mender inactive")
			if NecromancerTracker.humor then
				SpiritMenderIndicatorLabel:SetText(spiritMenderUnsummonLines[math.random(#spiritMenderUnsummonLines)])
			end
		elseif changeType == EFFECT_RESULT_GAINED then
			NecromancerTracker.savedVariables.menderSummons = NecromancerTracker.savedVariables.menderSummons + 1
			SpiritMenderIndicatorSezLabel:SetColor(0,1,0)
				SpiritMenderIndicatorSezLabel:SetText("Spirit Mender active")
				if NecromancerTracker.humor then
					SpiritMenderIndicatorLabel:SetText(spiritMenderSummonLines[math.random(#spiritMenderSummonLines)])
				end
			if (NecromancerTracker.showMender and (NecromancerTracker.inCombat or NecromancerTracker.alwaysShow)) then
				SpiritMenderIndicator:SetHidden(false)
			end
		end
		return
	end
  end  
  
end

function NecromancerTracker.OnPlayerCombatState(event, combat)
	if combat then
		NecromancerTracker.inCombat = true
		-- if they get into combat after summoning something, show it
		if NecromancerTracker.showBb then
			if NecromancerTracker.bbLeft then
				BlastbonesLeftIndicator:SetHidden(false)
			elseif NecromancerTracker.bbDown then -- if blastbones is down, show this indicator
				BlastbonesIndicator:SetHidden(false)
			end
		end
		
		if NecromancerTracker.showMage then
			SkeletalMageIndicator:SetHidden(false)
		end 
		
		if NecromancerTracker.showMender then
			SpiritMenderIndicator:SetHidden(false)
		end
		
		return
	else
		NecromancerTracker.inCombat = false
		-- hide the indicator when combat ends unless alwaysshow is on
		if not NecromancerTracker.alwaysShow then
			if NecromancerTracker.bbLeft then
				BlastbonesLeftIndicator:SetHidden(true)
			else
				BlastbonesIndicator:SetHidden(true)
			end
			SkeletalMageIndicator:SetHidden(true)
			SpiritMenderIndicator:SetHidden(true)
		elseif NecromancerTracker.bbHide then
			-- if bbHide is true, then hide this after combat regardless of if Always Show is on
			BlastbonesIndicator:SetHidden(true)
		end
	end
end

function NecromancerTracker.OnIndicatorMoveStop(indicator)
	--CHAT_SYSTEM:AddMessage("indicator " .. indicator)
	if indicator == "bb" then
		NecromancerTracker.savedVariables.bbleft = BlastbonesIndicatorLabel:GetLeft()
		NecromancerTracker.savedVariables.bbtop = BlastbonesIndicatorLabel:GetTop()
	elseif indicator == "bbsez" then
		NecromancerTracker.savedVariables.bbsezleft = BlastbonesIndicatorSezLabel:GetLeft()
		NecromancerTracker.savedVariables.bbseztop = BlastbonesIndicatorSezLabel:GetTop()
	elseif indicator == "bbleft" then
		NecromancerTracker.savedVariables.bbleftleft = BlastbonesLeftIndicator:GetLeft()
		NecromancerTracker.savedVariables.bblefttop = BlastbonesLeftIndicator:GetTop()
	elseif indicator == "mage" then
		NecromancerTracker.savedVariables.mageleft = SkeletalMageIndicator:GetLeft()
		NecromancerTracker.savedVariables.magetop = SkeletalMageIndicator:GetTop()
	elseif indicator == "mender" then
		NecromancerTracker.savedVariables.menderleft = SpiritMenderIndicator:GetLeft()
		NecromancerTracker.savedVariables.mendertop = SpiritMenderIndicator:GetTop()
	end
end

function NecromancerTracker.nthumor(extra)
	local options = {}
    local searchResult = { string.match(extra,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	
	if #options == 0 then
		NecromancerTracker.humor = not NecromancerTracker.humor
	elseif options[1] == "on" then
		NecromancerTracker.humor = true
	elseif options[1] == "off" then
		NecromancerTracker.humor = false
	end
	
	
	
	if NecromancerTracker.humor then
		state = "on"
		BlastbonesIndicatorSezLabel:SetText("Blastbones sez:")
	else 
		state = "off"
		
		--remove all the humorous lines, *sniff*
		BlastbonesIndicatorLabel:SetText("Recast Blastbones")
		BlastbonesIndicatorSezLabel:SetText("")
		BlastbonesLeftIndicatorLabel:SetText("")
		SkeletalMageIndicatorLabel:SetText("")
		SpiritMenderIndicatorLabel:SetText("")
		
	end
	
	CHAT_SYSTEM:AddMessage("'Humor' is " .. state)
	
	NecromancerTracker.savedVariables.humor = NecromancerTracker.humor
	
end

function NecromancerTracker.ntleftfont(extra)
	local options = {}
    local searchResult = { string.match(extra,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	
	if #options == 0 then
		NecromancerTracker.savedVariables.indicatorFont = NecromancerTracker.leftFontDefault
	else
		local theFontSize = tonumber(options[1])
		if theFontSize == nil or theFontSize < 1 or theFontSize > 61 then
			CHAT_SYSTEM:AddMessage("invalid font size, please stick to the plan")
			return
		end
		NecromancerTracker.savedVariables.indicatorFont = options[1]
	end
	
	BlastbonesLeftIndicatorLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
	SkeletalMageIndicatorLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
	SpiritMenderIndicatorLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
	BlastbonesLeftIndicatorSezLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
	SkeletalMageIndicatorSezLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
	SpiritMenderIndicatorSezLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.indicatorFont .. "|soft-shadow-thick")
  
end

function NecromancerTracker.ntbbfont(extra)
	local options = {}
    local searchResult = { string.match(extra,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	
	if #options == 0 then
		NecromancerTracker.savedVariables.bbFont = NecromancerTracker.bbFontDefault
	else
		local theFontSize = tonumber(options[1])
		if theFontSize == nil or theFontSize < 9 or theFontSize > 61 then
			CHAT_SYSTEM:AddMessage("invalid font size, please stick to the plan")
			return
		end
		NecromancerTracker.savedVariables.bbFont = theFontSize
	end
	
	BlastbonesIndicatorLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.bbFont .. "|soft-shadow-thick")
	BlastbonesIndicatorSezLabel:SetFont(fontPath .. "|" .. NecromancerTracker.savedVariables.bbFont-8 .. "|soft-shadow-thick")
end

function NecromancerTracker.ntstats(extra)
	local options = {}
    local searchResult = { string.match(extra,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	CHAT_SYSTEM:AddMessage("options #" .. #options)
	if #options == 0 then
		CHAT_SYSTEM:AddMessage("Mages bothered: " .. NecromancerTracker.savedVariables.mageSummons)
		CHAT_SYSTEM:AddMessage("Archers unleashed: " .. NecromancerTracker.savedVariables.archerSummons)
		CHAT_SYSTEM:AddMessage("Menders tortured: " .. NecromancerTracker.savedVariables.menderSummons)
		CHAT_SYSTEM:AddMessage("Kamikaze missions: " .. NecromancerTracker.savedVariables.bbSummons)
	elseif options[1] == "reset" then
		NecromancerTracker.savedVariables.bbSummons = 0
		NecromancerTracker.savedVariables.mageSummons = 0
		NecromancerTracker.savedVariables.archerSummons = 0
		NecromancerTracker.savedVariables.menderSummons = 0
	end
end

function NecromancerTracker.ntshowbb(extra)
	local options = {}
    local searchResult = { string.match(extra,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	if #options == 0 then
		NecromancerTracker.showBb = not NecromancerTracker.showBb
	elseif options[1] == "on" then
		NecromancerTracker.showBb = true
	elseif options[1] == "off" then
		NecromancerTracker.showBb = false
	end
	
	if NecromancerTracker.showBb and NecromancerTracker.inCombat then
		if NecromancerTracker.bbLeft then
			BlastbonesLeftIndicator:SetHidden(false)
		else
			BlastbonesIndicator:SetHidden(false)
		end
	else 
		if NecromancerTracker.bbLeft then
			BlastbonesLeftIndicator:SetHidden(true)
		else
			BlastbonesIndicator:SetHidden(true)
		end
	end
	
	if NecromancerTracker.showBb then
		state = "on"
	else 
		state = "off"
	end
	
	CHAT_SYSTEM:AddMessage("Show Blastbones " .. state)
	
	NecromancerTracker.savedVariables.showBb = NecromancerTracker.showBb
end

function NecromancerTracker.ntshowmage(extra)
	local options = {}
    local searchResult = { string.match(extra,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	if #options == 0 then
		NecromancerTracker.showMage = not NecromancerTracker.showMage
	elseif options[1] == "on" then
		NecromancerTracker.showMage = true
	elseif options[1] == "off" then
		NecromancerTracker.showMage = false
	end
	
	if NecromancerTracker.showMage and NecromancerTracker.inCombat then
		SkeletalMageIndicator:SetHidden(false)
	else 
		SkeletalMageIndicator:SetHidden(true)
	end
	
	local state = ""
	
	if NecromancerTracker.showMage then
		state = "on"
	else 
		state = "off"
	end
	
	CHAT_SYSTEM:AddMessage("Show Mage " .. state)
	
	NecromancerTracker.savedVariables.showMage = NecromancerTracker.showMage
end

function NecromancerTracker.ntshowmender(extra)
	local options = {}
    local searchResult = { string.match(extra,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	if #options == 0 then
		NecromancerTracker.showMender = not NecromancerTracker.showMender
	elseif options[1] == "on" then
		NecromancerTracker.showMender = true
	elseif options[1] == "off" then
		NecromancerTracker.showMender = false
	end
	
	if NecromancerTracker.showMender and NecromancerTracker.inCombat then
		SpiritMenderIndicator:SetHidden(false)
	else
		SpiritMenderIndicator:SetHidden(true)
	end
	
	if NecromancerTracker.showMender then
		state = "on"
	else 
		state = "off"
	end
	
	CHAT_SYSTEM:AddMessage("Show Mender " .. state)
	
	NecromancerTracker.savedVariables.showMender = NecromancerTracker.showMender
end

function NecromancerTracker.ntbbleft(extra)
	local options = {}
    local searchResult = { string.match(extra,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	if #options == 0 then
		NecromancerTracker.bbLeft = not NecromancerTracker.bbLeft
	elseif options[1] == "on" then
		NecromancerTracker.bbLeft = true
	elseif options[1] == "off" then
		NecromancerTracker.bbLeft = false
	end
	
	if NecromancerTracker.showBb and NecromancerTracker.inCombat then
		if NecromancerTracker.bbLeft then
			BlastbonesLeftIndicator:SetHidden(false)
			BlastbonesIndicator:SetHidden(true)
		else
			BlastbonesIndicator:SetHidden(false)
			BlastbonesLeftIndicator:SetHidden(true)
		end
	end
	
	if NecromancerTracker.bbLeft then
		state = "on"
	else 
		state = "off"
	end
	
	CHAT_SYSTEM:AddMessage("Blastbones left side " .. state)
	
	NecromancerTracker.savedVariables.bbLeft = NecromancerTracker.bbLeft
end

function NecromancerTracker.ntall(extra)
	local options = {}
    local searchResult = { string.match(extra,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	local command = ""
	if #options == 0 then
		command = ""
	elseif options[1] == "on" then
		command = "on"
	elseif options[1] == "off" then
		command = "off"
	end
	
	-- now just call each of them with the command they gave
	NecromancerTracker.ntshowbb(command)
	NecromancerTracker.ntshowmage(command)
	NecromancerTracker.ntshowmender(command)
	
end

function NecromancerTracker.ntbbhide(extra)
	local options = {}
    local searchResult = { string.match(extra,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	if #options == 0 then
		NecromancerTracker.bbHide = not NecromancerTracker.bbHide
	elseif options[1] == "on" then
		NecromancerTracker.bbHide = true
	elseif options[1] == "off" then
		NecromancerTracker.bbHide = false
	end
	
	if NecromancerTracker.bbHide and not NecromancerTracker.inCombat then
			BlastbonesIndicator:SetHidden(true)
	end
	
	if NecromancerTracker.bbHide then
		state = "on"
	else 
		state = "off"
	end
	
	CHAT_SYSTEM:AddMessage("Hide Blastbones after combat " .. state)
	
	NecromancerTracker.savedVariables.showBb = NecromancerTracker.showBb
end

function NecromancerTracker.ntalwaysshow(extra)
	local options = {}
    local searchResult = { string.match(extra,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	if #options == 0 then
		NecromancerTracker.alwaysShow = not NecromancerTracker.alwaysShow
	elseif options[1] == "on" then
		NecromancerTracker.alwaysShow = true
	elseif options[1] == "off" then
		NecromancerTracker.alwaysShow = false
	end
	
	if NecromancerTracker.alwaysShow then
		if NecromancerTracker.bbLeft then
			BlastbonesLeftIndicator:SetHidden(false)
		else
			BlastbonesIndicator:SetHidden(false)
		end
		SkeletalMageIndicator:SetHidden(false)
		SpiritMenderIndicator:SetHidden(false)
	else 
		if not NecromancerTracker.inCombat then
			BlastbonesIndicator:SetHidden(true)
		end
		
		if not NecromancerTracker.inCombat then
			SkeletalMageIndicator:SetHidden(true)
		end
		
		if not NecromancerTracker.inCombat then
			SpiritMenderIndicator:SetHidden(true)
		end
	end
	
	if NecromancerTracker.alwaysShow then
		state = "on"
	else 
		state = "off"
	end
	
	CHAT_SYSTEM:AddMessage("Always Show " .. state)
	
	NecromancerTracker.savedVariables.alwaysShow = NecromancerTracker.alwaysShow
end

EVENT_MANAGER:RegisterForEvent(NecromancerTracker.name, EVENT_ADD_ON_LOADED, NecromancerTracker.OnAddOnLoaded)