local HideSomeThings = ZO_Object:Subclass()

HideSomeThings.defaults = {
   ["hideTopBar"] = false,
   ["hideBottomBar"] = false,
   ["hideMeterBackground"] = false,
   ["hideChatBackground"] = false,
   ["hideChatDivider"] = false,
   ["hideMinChatBackground"] = false,
   ["hideNotificationIcon"] = false,  
   ["hideWeaponSwapIcon"] = false,
   ["hideKeybindBackground"] = false,
--   ["hideKeybindText"] = false,
   ["hideEmptyBackground"] = false,
   ["hideButtonOne"] = false,
   ["hideButtonTwo"] = false,
   ["hideButtonThree"] = false,
   ["hideButtonFour"] = false,   
   ["hideButtonFive"] = false,   
   ["hideUltimate"] = false,
   ["hideQuickbar"] = false,
   ["hideActionBorders"] = false,  
}

	-- Hide Top Bar
function HideSomeThings:hidetop()
	if self.config.hideTopBar then
		ZO_TopBarBackground:SetAlpha(0)
	end
end	

	-- Hide Bottom Bar
function HideSomeThings:hidebot()
    if self.config.hideBottomBar then
		RedirectTexture("esoui/art/miscellaneous/bottom_bar.dds", "HideThings\media\hide_blank.dds")
    else
		RedirectTexture("esoui/art/miscellaneous/bottom_bar.dds", "esoui/art/miscellaneous/bottom_bar.dds")
    end
end

	-- Hide Performance Meter Background
function HideSomeThings:hidemet()
	if self.config.hideMeterBackground then
		ZO_PerformanceMetersBg:SetAlpha(0)
	end
end

    -- Hide Chat Background
function HideSomeThings:hidecht()	
	if self.config.hideChatBackground then
		ZO_ChatWindowBg:SetAlpha(0)
	end
end

	
    -- Hide Chat Divider Bar
function HideSomeThings:hidechtdiv()
	if self.config.hideChatDivider then
		ZO_ChatWindowDivider:SetAlpha(0)
	end
end

	
    -- Hide Minimized Chat Bar Background
function HideSomeThings:hidechtmin()
	if self.config.hideMinChatBackground then
		ZO_ChatWindowMinBar:SetAlpha(0)
	end
end

	-- Hide Chat Notification Icon
function HideSomeThings:hidechtnot()
	if self.config.hideNotificationIcon then
		ZO_ChatWindowNotifications:SetAlpha(0)
	end
end

    -- Hide Weapon Swap Icon
function HideSomeThings:hideswp()
	if self.config.hideWeaponSwapIcon then
		ZO_ActionBar1WeaponSwap:SetAlpha(0)
		ZO_ActionBar1WeaponSwapLock:SetAlpha(0)
	end	
 end
 
 
    -- Hide Keybind Background
function HideSomeThings:hidekybd()
	if self.config.hideKeybindBackground then
		ZO_ActionBar1KeybindBG:SetAlpha(0)
	end	 
end

-- DISABLED FOR NOW. Doesn't play well with hide chat notification icon.
--    -- Toggle Keybind Text
--function HideSomeThings:hidetxt()
--	if self.config.hideKeybindText then	
--		ActionButton3ButtonText:SetHidden(true)
--		ActionButton4ButtonText:SetHidden(true)
--		ActionButton5ButtonText:SetHidden(true)
--		ActionButton6ButtonText:SetHidden(true)
--		ActionButton7ButtonText:SetHidden(true)
--		ActionButton8ButtonText:SetHidden(true)
--		ActionButton9ButtonText:SetHidden(true)
--		if (IsInGamepadPreferredMode()) then
--			ActionButton8RBkey:SetHidden(true)
--			ActionButton8LBkey:SetHidden(true)
--		else
--			ActionButton8ButtonText:SetHidden(true)
--		end
--	end
--end
	
    -- Hide Empty Button Backgrounds
function HideSomeThings:hidempt()
	if self.config.hideEmptyBackground then
		ActionButton3BG:SetAlpha(0)
		ActionButton4BG:SetAlpha(0)
		ActionButton5BG:SetAlpha(0)
		ActionButton6BG:SetAlpha(0)
		ActionButton7BG:SetAlpha(0)
		ActionButton8BG:SetAlpha(0)
		ActionButton9BG:SetAlpha(0)
	end	
end

	--Hide Action Bar Ability Borders
function HideSomeThings:hidebor()
	if self.config.hideActionBorders then
		ActionButton3Button:SetAlpha(0)
		ActionButton4Button:SetAlpha(0)
		ActionButton5Button:SetAlpha(0)
		ActionButton6Button:SetAlpha(0)
		ActionButton7Button:SetAlpha(0)
		ActionButton8Button:SetAlpha(0)
		ActionButton9Button:SetAlpha(0)
	end	 
end	
	
	-- Hide Button One
function HideSomeThings:hideone()
	if self.config.hideButtonOne then
		ActionButton3:SetAlpha(0)
	end	 
 end
 
 	-- Hide Button Two
function HideSomeThings:hidetwo()
	if self.config.hideButtonTwo then
		ActionButton4:SetAlpha(0)
	end	   
 end
 
  	-- Hide Button Three
function HideSomeThings:hidetre()
	if self.config.hideButtonThree then
		ActionButton5:SetAlpha(0)
	end	     
 end
 
   	-- Hide Button Four
function HideSomeThings:hidefor()
	if self.config.hideButtonFour then
		ActionButton6:SetAlpha(0)
	end
end	  

   	-- Hide Button Five
function HideSomeThings:hidefiv()
	if self.config.hideButtonFive then
		ActionButton7:SetAlpha(0)
	end	  	
end
	
   	-- Hide Ultimate Button
function HideSomeThings:hideult()
	if self.config.hideUltimate then
			ActionButton8:SetAlpha(0)
	end	 
end
 
   	-- Hide Quickbar Button
function HideSomeThings:hideqck()
	if self.config.hideQuickbar then
		ActionButton9:SetAlpha(0)
	end
end

function HideSomeThings:Init(eventCode, addonName)
	if addonName == "HideSomeThings" then
		EVENT_MANAGER:UnregisterForEvent("HideSomeThings", EVENT_ADD_ON_LOADED)
		self.config = ZO_SavedVars:New("HideSomeThings_SavedVariables", 1, nil, self.defaults, nil)
		self:hidetop()
		self:hidebot()
		self:hidemet()
		self:hidecht()
		self:hidechtdiv()
		self:hidechtmin()
		self:hidechtnot()
		self:hideswp()
		self:hidekybd()
--		self:hidetxt()
		self:hidebor()
		self:hidempt()
		self:hideone()
		self:hidetwo()
		self:hidetre() 
		self:hidefor()
		self:hidefiv()
		self:hideult()
		self:hideqck()	
		self:CreateSettings()
	end
end

function HideSomeThings:CreateSettings()
   local panelData = {
      type = 'panel',
      name = "Hide Some Things",
      displayName = ZO_HIGHLIGHT_TEXT:Colorize("Hide Some Things"),
      author = "Zinival,@Ninette",
      version = '1.0',
      slashCommand = '/hidesomethings',
      registerForRefresh = true,
      registerForDefaults = true,
   }
   local optionsData = {
      {
	    type = "header",
		name = "Miscellaneous Options",
      },
      {
         type = 'checkbox',
         name = 'Hide Top Bar',
         tooltip = 'Hides the bar that appears at the top of the screen when you open a menu. \n\nTurning this option OFF requires reloading the UI.',
         getFunc = function() return self.config.hideTopBar end,
         setFunc = function(value) self.config.hideTopBar = value; self:hidetop() end,
         default = self.defaults.hideTopBar,
      },
      {
         type = 'checkbox',
         name = 'Hide Bottom Bar',
         tooltip = 'Hides the bar that appears at the bottom of the screen when you open a menu. \n\nTurning this option OFF requires reloading the UI.',
         getFunc = function() return self.config.hideBottomBar end,
         setFunc = function(value) self.config.hideBottomBar = value; self:hidebot() end,
         default = self.defaults.hideBottomBar,
      },
      {
         type = 'checkbox',
         name = 'Hide Performance Meter Background',
         tooltip = 'Hides the background behind the FPS and Latency meters. \n\nTurning this option OFF requires reloading the UI.',
         getFunc = function() return self.config.hideMeterBackground end,
         setFunc = function(value) self.config.hideMeterBackground = value; self:hidemet() end,
         default = self.defaults.hideMeterBackground,
      },
	  {
	 	type = "button",
		name = "Reload UI",
		tooltip = "",
		width = "full",
		func = function() 
	      ReloadUI("ingame")
		end,
	  },	  
	  {
	    type = "header",
		name = "Chat Options",
      },
      {
         type = 'checkbox',
         name = 'Hide Chat Background',
         tooltip = 'Hides the background of the chat box. \n\nTurning this option OFF requires reloading the UI.',
         getFunc = function() return self.config.hideChatBackground end,
         setFunc = function(value) self.config.hideChatBackground = value; self:hidecht() end,
         default = self.defaults.hideChatBackground,	  
      },
      {
         type = 'checkbox',
         name = 'Hide Chat Divider Bar',
         tooltip = 'Hides the thin divider bar at the top of chat. \n\nTurning this option OFF requires reloading the UI.',
         getFunc = function() return self.config.hideChatDivider end,
         setFunc = function(value) self.config.hideChatDivider = value; self:hidechtdiv() end,
         default = self.defaults.hideChatDivider,	  
      },
      {
         type = 'checkbox',
         name = 'Hide Minimized Chat Bar ',
         tooltip = 'This completely hides the minimized chat bar. If you select this option you will have to press enter or click on an invisible button to open chat! \n\nTurning this option OFF requires reloading the UI.',
         getFunc = function() return self.config.hideMinChatBackground end,
         setFunc = function(value) self.config.hideMinChatBackground = value; self:hidechtmin() end,
         default = self.defaults.hideMinChatBackground,	  
      },
      {
       type = 'checkbox',
       name = 'Hide Chat Notification Icon ',
       tooltip = 'This hides the chat notification ICON only.\n\nThe number text will still appear when you have an unread notification.\n\nTurning this option OFF requires reloading the UI.',
       getFunc = function() return self.config.hideNotificationIcon end,
       setFunc = function(value) self.config.hideNotificationIcon = value; self:hidechtnot(); end,
       default = self.defaults.hideNotificationIcon,	  
      },
	  {
	 	type = "button",
		name = "Reload UI",
		tooltip = "",
		width = "full",
		func = function() 
	      ReloadUI("ingame")
		end,
	  },	  
      {
	    type = "header",
		name = "Action Bar Options",
      },
      {
         type = 'checkbox',
         name = 'Hide Weapon Swap Icon ',
         tooltip = 'Hides the weapon swap icon between the quickbar button and action bar button 1. \n\nTurning this option OFF requires reloading the UI.',
         getFunc = function() return self.config.hideWeaponSwapIcon end,
         setFunc = function(value) self.config.hideWeaponSwapIcon = value; self:hideswp() end,
         default = self.defaults.hideWeaponSwapIcon,	  
      },
      {
         type = 'checkbox',
         name = 'Hide Keybind Background ',
         tooltip = 'Hides the black background underneath the keybind text below the action bar. \n\nTurning this option OFF requires reloading the UI.',
         getFunc = function() return self.config.hideKeybindBackground end,
         setFunc = function(value) self.config.hideKeybindBackground = value; self:hidekybd() end,
         default = self.defaults.hideKeybindBackground,	  
      },
 --     {
 --       type = 'checkbox',
 --       name = 'Hide Keybind Text ',
 --       tooltip = 'Hides the keybind text below the action bar. \n\nTurning this option OFF requires reloading the UI.',	
 --       getFunc = function() return self.config.hideKeybindText end,
 --       setFunc = function(value) self.config.hideKeybindText = value; self:hidetxt(); end,
 --       default = self.defaults.hideKeybindText,	  
  --    },
      {
         type = 'checkbox',
         name = 'Hide Action Bar Icon Borders ',
         tooltip = 'Hides the borders around ability icons. \n\nTurning this option OFF requires reloading the UI.',
         getFunc = function() return self.config.hideActionBorders end,
         setFunc = function(value) self.config.hideActionBorders = value; self:hidebor() end,
         default = self.defaults.hideActionBorders,	  
      },
      {
         type = 'checkbox',
         name = 'Hide Empty Button Background ',
         tooltip = 'Hides the transparent background that appears in empty action bar buttons. \n\nTurning this option OFF requires reloading the UI.',
         getFunc = function() return self.config.hideEmptyBackground end,
         setFunc = function(value) self.config.hideEmptyBackground = value; self:hidempt() end,
         default = self.defaults.hideEmptyBackground,	  
      },
	  {
	 	type = "button",
		name = "Reload UI",
		tooltip = "",
		width = "full",
		func = function() 
	      ReloadUI("ingame")
		end,
	  },	
      {
	    type = "header",
		name = "Individual Action Bar Button Options",
      },
      {
         type = 'checkbox',
         name = 'Hide Button 1 ',
         tooltip = 'Warning: This completely hides the button. Always. Even in combat! \n\nTurning this option ON or OFF requires reloading the UI.',
         getFunc = function() return self.config.hideButtonOne end,
         setFunc = function(value) self.config.hideButtonOne = value; self:hideone() end,
         default = self.defaults.hideButtonOne,	  
      },
      {
         type = 'checkbox',
         name = 'Hide Button 2 ',
         tooltip = 'Warning: This completely hides the button. Always. Even in combat! \n\nTurning this option ON or OFF requires reloading the UI.',
         getFunc = function() return self.config.hideButtonTwo end,
         setFunc = function(value) self.config.hideButtonTwo = value; self:hidetwo() end,
         default = self.defaults.hideButtonTwo,	  
      },
      {
         type = 'checkbox',
         name = 'Hide Button 3 ',
         tooltip = 'Warning: This completely hides the button. Always. Even in combat! \n\nTurning this option ON or OFF requires reloading the UI.',
         getFunc = function() return self.config.hideButtonThree end,
         setFunc = function(value) self.config.hideButtonThree = value; self:hidetre() end,
         default = self.defaults.hideButtonThree,	  
      },
      {
         type = 'checkbox',
         name = 'Hide Button 4 ',
         tooltip = 'Warning: This completely hides the button. Always. Even in combat! \n\nTurning this option ON or OFF requires reloading the UI.',
         getFunc = function() return self.config.hideButtonFour end,
         setFunc = function(value) self.config.hideButtonFour = value; self:hidefor() end,
         default = self.defaults.hideButtonFour,	  
      },
      {
         type = 'checkbox',
         name = 'Hide Button 5 ',
         tooltip = 'Warning: This completely hides the button. Always. Even in combat! \n\nTurning this option ON or OFF requires reloading the UI.',
         getFunc = function() return self.config.hideButtonFive end,
         setFunc = function(value) self.config.hideButtonFive = value; self:hidefiv() end,
         default = self.defaults.hideButtonFive,	  
      },
      {
         type = 'checkbox',
         name = 'Hide Ultimate Button ',
         tooltip = 'Warning: This completely hides the button. Always. Even in combat! \n\nTurning this option ON or OFF requires reloading the UI.',
         getFunc = function() return self.config.hideUltimate end,
         setFunc = function(value) self.config.hideUltimate = value; self:hideult() end,
         default = self.defaults.hideUltimate,	  
      },
      {
         type = 'checkbox',
         name = 'Hide Quickbar Button ',
         tooltip = 'Warning: This completely hides the button. Always. Even in combat! \n\nTurning this option ON or OFF requires reloading the UI.',
         getFunc = function() return self.config.hideQuickbar end,
         setFunc = function(value) self.config.hideQuickbar = value; self:hideqck() end,
         default = self.defaults.hideQuickbar,	  
      },
	  {
	 	type = "button",
		name = "Reload UI",
		tooltip = "",
		width = "full",
		func = function() 
	      ReloadUI("ingame")
		end,
	  },
   }

   local LAM2 = LibStub("LibAddonMenu-2.0")
   LAM2:RegisterAddonPanel("HideSomeThings", panelData)
   LAM2:RegisterOptionControls("HideSomeThings", optionsData)
end

EVENT_MANAGER:RegisterForEvent("HideSomeThings", EVENT_ADD_ON_LOADED, function(...) HideSomeThings:Init(...) end)
