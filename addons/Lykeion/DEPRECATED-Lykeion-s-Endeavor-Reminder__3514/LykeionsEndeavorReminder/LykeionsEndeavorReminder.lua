LykeionER = {}

LykeionER.name = "LykeionsEndeavorReminder"
local SV_NAME = 'LER_VARS'
local SV_VER = 1
local db

local flag = true
local permission = true

local defaults = {
	enabled = true,
	oneTip = false,
	nextRefreshTime = 0
}

function LykeionER:GetWarningDialog()
    if(not ESO_Dialogs[LykeionER.name]) then
        ESO_Dialogs[LykeionER.name] = {
            canQueue = true,
            title = {
                text = "",
            },
            mainText = {
                text = "",
            },
            buttons = {
                [1] = {
                    text = "",
                    callback = function(dialog) end,
                },
				--[2] = {
                --    text = "",
                --    callback = function(dialog) end,
                --},
                [2] = {
                    text = "",
                }
            }
        }
    end
    return ESO_Dialogs[LykeionER.name]
end

function LykeionER:ShowQuitWarningDialog(buttonText, callback , incompleteCode)
    local dialog = self:GetWarningDialog()
    dialog.title.text = GetString(LER_TIPS)
	if incompleteCode == 1 then
		dialog.mainText.text = GetString(LER_TIPS_TEXT)
	elseif incompleteCode == 2 then
		dialog.mainText.text = GetString(LER_TIPS_TEXT_WEEKLY)
	end
	
	if db.oneTip then
		--d(LykeionER.getNextRefreshTime())
		db.nextRefreshTime = LykeionER.getNextRefreshTime()
	end

    local primaryButton = dialog.buttons[1]
    primaryButton.text = GetString(LER_BUTTON_1)
    primaryButton.callback = function(dialog)
        MAIN_MENU_KEYBOARD:ShowScene("groupMenuKeyboard")
    end
	
	--local secondaryButton = dialog.buttons[1]
    --secondaryButton.text = "Do not prompt until next Endeavor"
    --secondaryButton.callback = function(dialog)
    --    LykeionER:UpdateNextRefreshTime()
    --end

    local tertiaryButton = dialog.buttons[2]
    tertiaryButton.text = buttonText
    tertiaryButton.callback = callback

    ZO_Dialogs_ShowDialog(LykeionER.name)
end

function LykeionER:SetupDialogHook(name)
    local primaryButton = ESO_Dialogs[name].buttons[1]
    local originalCallback = primaryButton.callback
    primaryButton.callback = function(dialog)
        if db.enabled and LykeionER:HasIncompleteEndeavor() ~=0 and (not db.oneTip or (db.oneTip and os.time() >= db.nextRefreshTime)) then
            self:ShowQuitWarningDialog(primaryButton.text, originalCallback, LykeionER:HasIncompleteEndeavor())
        else
            originalCallback(dialog)
		end
    end
end

function LykeionER:HasIncompleteEndeavor()
	local t = os.time()
	local da = os.date("!*t", os.time())
	local hasIncompleteDailyEndeavor = GetNumTimedActivitiesCompleted(0)  < 3
	-- does Sunday endeavor activated?	
	local hasIncompleteWeeklyEndeavor = GetNumTimedActivitiesCompleted(1)  < 1 and ((da.wday == 0 and t > math.floor(t/60/60/24)*24*60*60+6*60*60) or (da.wday == 1 and t < math.floor(t/60/60/24)*24*60*60+6*60*60))
	if not hasIncompleteDailyEndeavor and not hasIncompleteWeeklyEndeavor then
		return 0
	elseif hasIncompleteDailyEndeavor then
		return 1
	elseif hasIncompleteWeeklyEndeavor then 
		return 2
	end
end

function LykeionER:UpdateNextRefreshTime()
    db.nextRefreshTime = LykeionER.getNextRefreshTime()
end

function LykeionER:Initialize()
	db = ZO_SavedVars : NewAccountWide ( SV_NAME , SV_VER , nil , defaults , GetWorldName())
	LykeionER:AddonMenu()
	--if LibSavedVars ~= nil then
	--	db = LibSavedVars:NewAccountWide(SV_NAME, "Account", defaults)
    --                 :AddCharacterSettingsToggle(SV_NAME, "Character")
	--else
	--	db = ZO_SavedVars:New( SV_NAME, 1, nil, defaults )
	--end
	
    self:SetupDialogHook("LOG_OUT")
    self:SetupDialogHook("QUIT")
end

function LykeionER.OnAddOnLoaded(event, addonName)
  if addonName == LykeionER.name then
	LykeionER:Initialize()
  end
end

local LAM2 = LibAddonMenu2

function LykeionER.AddonMenu()
	local menuOptions = {
		type				 = "panel",
		name				 = "Lykeion's Endeavor Reminder",
		displayName	 = "|c275a91L|r|c2e5d8dy|r|c355f89k|r|c3c6185e|r|c426481i|r|c49667do|r|c506878n|r|c576b74'|r|c5e6d70s|r |c656f6cE|r|c6c7268n|r|c737464d|r|c797660e|r|c80785ca|r|c877b58v|r|c8e7d54o|r|c957f50r|r |c9c824cR|r|ca38447e|r|caa8643m|r|cb0893fi|r|cb78b3bn|r|cbe8d37d|r|cc59033e|r|ccc922fr|r",
		author = "|c215895Lykeion|r",
		version = "|ccc922f1.0.7|r",
		slashCommand = "/LER",
		registerForRefresh	= true,
		registerForDefaults = true,
	}

	local dataTable = {
		{
			type = "description",
			text = GetString(LER_MENU_DESCRIPTION),
		},
		{
			type = "divider",
		},
		{
			type    = "checkbox",
			name    = GetString(LER_ENABLE),
			default = true,
			getFunc = function() return db.enabled end,
			setFunc = function( newValue ) db.enabled = newValue; end,
		},
		{
			type    = "checkbox",
			name    = GetString(LER_ONE_TIP),
			tooltip = GetString(LER_ONE_TIP_TOOLTIP),
			default = false,
			getFunc = function() return db.oneTip end,
			setFunc = function( newValue ) db.oneTip = newValue; end,
		},
	}

	LAM2:RegisterAddonPanel(LykeionER.name .. "Options", menuOptions )
	LAM2:RegisterOptionControls(LykeionER.name .. "Options", dataTable )
end


EVENT_MANAGER:RegisterForEvent(LykeionER.name, EVENT_ADD_ON_LOADED, LykeionER.OnAddOnLoaded)

function LykeionER.getNextRefreshTime()
    local t = os.time()
	local todayRefreshTime = math.floor(t/60/60/24)*24*60*60+10*60*60
	local tomorrowRefreshTime = math.floor(t/60/60/24)*24*60*60+34*60*60
	if t < todayRefreshTime then
		return todayRefreshTime
	else
		return tomorrowRefreshTime
	end
end