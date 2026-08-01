--[[soundSliderData = {
    type = "soundslider",
    name = "My sound slider", -- or string id or function returning a string
    getFunc = function() return db.var end,
    setFunc = function(value) db.var = value doStuff() end,
    autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
    inputLocation = "below", -- or "right" or function returning the strings, determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
    saveSoundIndex = false, -- or function returning a boolean (optional) If set to false (default) the internal soundName will be saved. If set to true the selected sound's index will be saved to the SavedVariables (the index might change if sounds get inserted later!).
    showSoundName = true, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be shown at the label of the slider, and at the tooltip too
    playSound = true, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be played via function PlaySound. Will be ignored if table playSoundData is provided!
    playSoundData = {number playCount, number delayInMS, number increaseVolume}, -- table or function returning a table. If this table is provided the chosen sound will be played playCount (default is 1) times after each other, with a delayInMS (default is 0) in milliseconds in between, and each played sound will be played increaseVolume times (directly at the same time) to increase the volume (default is 1, max is 10) (optional)
    showPlaySoundButton = false, --Boolean or function returning a boolean. If true a button control will be shown next to the slider, which will preview the selected sound (based on playSoundData or playSound. If both are nil/false the button won't be shown) (optional)
    noAutomaticSoundPreview = false, --Boolean or function returning a boolean. Only works if showPlaySoundButton is true! If true the automatic sound preview (based on playSoundData or playSound) will be disabled and only the sound preview button is used to play the sound (optional)
    readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
    tooltip = "Sound slider's tooltip text.", -- or string id or function returning a string (optional)
    width = "full", -- or "half" (optional)
    disabled = function() return db.someBooleanSetting end, --or boolean (optional)
    warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
    requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
    default = defaults.var, -- default value or function that returns the default value (optional)
    helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
    reference = "MyAddonSoundSlider" -- unique global reference to control (optional)
} ]]

local widgetVersion = 6
local widgetName = "LibAddonMenuSoundSlider"

local LAM = LibAddonMenu2
local util = LAM.util
local getDefaultValue = util.GetDefaultValue

local em = EVENT_MANAGER
local wm = WINDOW_MANAGER
local cm = CALLBACK_MANAGER

local tins = table.insert
local tsort = table.sort

local LASoundSliderIndex = 0
local defaultTooltip

--The sounds table of the game
local soundsRef = SOUNDS
local conNone= "NONE"
local nonSoundInternalName = soundsRef[conNone]

--The sound names table, sorted by name. Only create once and cache at LibAddonMenu2 table!
local soundNames = {}
local soundLookup = {}
local soundIndexLookup = {}
for soundName, _ in pairs(soundsRef) do
    if soundName ~= conNone then
        tins(soundNames, soundName)
    end
end
tsort(soundNames)
if #soundNames <= 0 then
    d("[LibAddonMenuSoundSlider] ERROR No sounds could be found - Widget won't work properly!")
    return
end
--Insert "NONE" as first sound
tins(soundNames, 1, conNone)

for idx, soundName in ipairs(soundNames) do
    local soundInternalName = soundsRef[soundName]
    soundLookup[idx] = soundInternalName
    soundIndexLookup[soundInternalName] = idx
end
soundIndexLookup[nonSoundInternalName] = 1

--The number of possible sounds in the game
local numSounds = #soundNames

--[[
--For debugging only
LAM.soundData = {
    origSounds = soundsRef,
    soundNames = soundNames,
    soundLookup = soundLookup,
    soundIndexLookup = soundIndexLookup,
}
]]

local SLIDER_HANDLER_NAMESPACE = "LAM2_SoundSlider"
local translation = {
    ["de"] = {previewSound = "Ausgewählten Sound \'%s\' abspielen"},
    ["en"] = {previewSound = "Preview selected sound \'%s\'"},
    ["es"] = {previewSound = "Vista previa del sonido seleccionado \'%s\'"},
    ["fr"] = {previewSound = "Prévisualiser le son sélectionné \'%s\'"},
    ["ru"] = {previewSound = "Предварительный просмотр выбранного звука \'%s\'"},
    ["jp"] = {previewSound = "選択したサウンド \'%s\' をプレビュー"},
    ["zh"] = {previewSound = "预览选定的声音 \'%s\'"},
}
local clientLang = GetCVar("language.2")
local langStrings = translation[clientLang]
if langStrings == nil then langStrings = translation["en"] end --Fallback language: English


local function playSoundLoopNow(soundToPlay, soundRepeats)
--d("[LAM2SoundSlider]PlaySound: " ..tostring(soundToPlay) .. ", volumeIncrease: " ..tostring(soundRepeats))
	if not soundToPlay or not soundsRef[soundToPlay] then return false end
	soundRepeats = soundRepeats or 1
	local wasPlayed = false
    for i=1, soundRepeats, 1 do
		--Play the sound (multiple times will play it louder)
		PlaySound(soundsRef[soundToPlay])
        wasPlayed = true
	end
    return wasPlayed
end

local function playSoundDelayedInLoop(playNTimes, delayInBetween, soundToPlay, soundRepeats)
--d(string.format("[LAM2SoundSlider]Playing %s times: %q (%sx repeated), with a delay of %s seconds", tostring(playNTimes), tostring(soundToPlay), tostring(soundRepeats), tostring(delayInBetween)))
	if not soundToPlay or not soundsRef[soundToPlay] then return false end
	playNTimes = playNTimes or 1
	delayInBetween = delayInBetween or 0
	soundRepeats = soundRepeats or 1
    local delay = 0
	--Do N times: Play the sound (each time with soundRepeats loops to increase the volume)
	local loopWasPlayed = false
    for i=1, playNTimes, 1 do
		if i == 1 then
--d(">call " ..tostring(i))
			loopWasPlayed = playSoundLoopNow(soundToPlay, soundRepeats)
		else
            delay = delay + delayInBetween
			zo_callLater(function()
                playSoundLoopNow(soundToPlay, soundRepeats)
--d(">call " ..tostring(i))
            end, delay)
            loopWasPlayed = true
		end
	end
    return loopWasPlayed
end

--Global function to convert the soundSlider soundIndex to the internal SOUNDS name (SOUNDS = { [soundName] = sound_internal_name, ... }
--Parameters: soundIndex number
--Returns nilable:internal_sound_name String
function ConvertLAMSoundSliderSoundIndexToName(soundIndex)
    if soundIndex == nil or type(soundIndex) ~= "number" or soundIndex <= 0 or soundIndex > numSounds then return end
    return soundLookup[soundIndex]
end

--Global function to convert the soundSlider soundNameInternal of SOUNDS to the index used in this widget (SOUNDS = { [soundName] = sound_internal_name, ... }
--Parameters: soundNameInternal string
--Returns nilable:widgetsSoundIndex number
function ConvertLAMSoundSliderSoundNameToIndex(soundNameInternal)
    if soundNameInternal == nil or type(soundNameInternal) ~= "string" then return end
    return soundIndexLookup[soundNameInternal]
end

--Global function to play the sound of an internal_sound_name, or by using the soundIndex of the soundSlider widget.
--The sound will be optionally played "volume" times (1 to 10) to increase the volume.
--The sound will be optionally repeated "repeats" time, with a "repeatDelayMS" delay in milliseconds in between.
--Volume default is 1, repeats default is 1 and repeatsDelayMS default is 0 milliseconds
--Either the soundNameInternal or the soundIndex must be given!
--Parameters: soundNameInternal optional:string, soundIndex optional:number, volume optional:number(1 to 10), repeats optional:number, repeatDelayMS optional:number milliseconds
--Returns nilable:boolean wasPlayed
function PlayLAMSoundSliderSound(soundNameInternal, soundIndex, volume, repeats, repeatDelayMS)
    if soundNameInternal == nil and soundIndex == nil then return end
    if soundNameInternal ~= nil then if type(soundNameInternal) ~= "string" then return end end
    if soundIndex ~= nil then if type(soundIndex) ~= "number" or soundIndex <= 0 or soundIndex > numSounds then return end end

    volume = volume or 1
    repeats = repeats or 1
    repeatDelayMS = repeatDelayMS or 0

    local soundNameToPlay
    if soundIndex ~= nil then
        soundNameInternal = soundLookup[soundIndex]
    end
    if soundNameInternal ~= nil then
        soundNameToPlay = ZO_KeyOfFirstElementInNonContiguousTable(soundsRef, soundNameInternal)
    end
    if soundNameToPlay == nil then return end

    if repeats > 1 then
        return playSoundDelayedInLoop(repeats, repeatDelayMS, soundNameToPlay, volume)
    else
        return playSoundLoopNow(soundNameToPlay, 1)
    end
end

local function ClampValue(value)
    return math.max(math.min(value, numSounds), 1)
end

local function UpdateDisabled(control)
    local data = control.data
    local disable = getDefaultValue(data.disabled)
    if disable == nil then disable = false end
    local readOnly = getDefaultValue(data.readOnly)
    if readOnly == nil then readOnly = false end

    local isEnabled = not disable

    control.isDisabled = disable

    control.slider:SetEnabled(isEnabled)
    control.slidervalue:SetEditEnabled((not readOnly and isEnabled) or false)
    if control.playSoundButton ~= nil then
        control.playSoundButton:SetEnabled(isEnabled)
        control.playSoundButton:SetMouseEnabled(isEnabled)
    end

    if disable == true then
        control.label:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
        --control.minText:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
        --control.maxText:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
        control.slidervalue:SetColor(ZO_DEFAULT_DISABLED_MOUSEOVER_COLOR:UnpackRGBA())
    else
        control.label:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
        --control.minText:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
        --control.maxText:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
        control.slidervalue:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
    end
end

local function playSoundPreview(control, value, doForcePlay)
    doForcePlay = doForcePlay or false
    if value > 1 then
        local soundName = soundNames[value] or "n/a"
        local data = control.data
        local playSoundData =   data.playSoundData
        local playSound =       (playSoundData == nil and data.playSound) or false

        local doPlaySingleSound = (playSound ~= nil and getDefaultValue(playSound)) or false
        if doPlaySingleSound == true then
            playSoundLoopNow(soundName, 1)
        else
            if playSoundData ~= nil then
                playSoundData = getDefaultValue(playSoundData)
                --playSoundData = {number playCount, number delayInMS, number increaseVolume},
                local playCount = playSoundData.playCount
                playCount = playCount or 1 --repeat the sound n times (loop)
                local delayInMS = playSoundData.delayInMS
                delayInMS = delayInMS or 0 --milliseconds
                local increaseVolume = playSoundData.increaseVolume
                increaseVolume = increaseVolume or 1 --Increase volume by playing the sound miltiple times after another
                increaseVolume = zo_clamp(increaseVolume, 1, 10)

                if playCount ~= nil and delayInMS ~= nil and increaseVolume ~= nil then
                    playSoundDelayedInLoop(playCount, delayInMS, soundName, increaseVolume)
                end
            else
                if doForcePlay == true then
                   playSoundLoopNow(soundName, 1)
                end
            end
        end
    end
end

local function raiseSoundChangedCallback(panel, control, value)
    if control.playSoundButton == nil or not control.noAutomaticSoundPreview then
        playSoundPreview(control, value)
    end
    local soundName = soundNames[value] or "n/a"
    cm:FireCallbacks("LibAddonMenuSoundSlider_UpdateValue", panel or LAM.currentAddonPanel, control, value, soundName)
end

local function updateSoundSliderLabelAndTooltip(control, value)
    local data = control.data
    local showSoundName = getDefaultValue(data.showSoundName) or false
    if showSoundName == true then
        --Show the sound name at the slider's label and tooltip
        local soundName = soundNames[value]
        if soundName and soundName ~= "" then
            control.label:SetText(data.name .. " " .. soundName)
            data.tooltipText = defaultTooltip ..  "\n" .. soundName
        end
    else
        --No soundname at the slider's label and tooltip)
        control.label:SetText(data.name)
        data.tooltipText = defaultTooltip
    end

    if control.playSoundButton ~= nil then
        local isHidden = (value <= 1 and true) or false
        control.playSoundButton:SetHidden(isHidden)
    end
end

local isHandlingChange = false --Prevent endless loop between HandleValueChanged -> slidervalue:SetText -> HandleValueChanged ...
local function HandleValueChanged(control, value, doNotPlaySound, valueText)
    if doNotPlaySound == nil then doNotPlaySound = true end
--d("[LAMSoundSlider]HandleValueChanged-isHandlingChange: " .. tostring(isHandlingChange) .. ", doNotPlaySound: " .. tostring(doNotPlaySound))
    if control.isDisabled then isHandlingChange = false return end
    if isHandlingChange then return end
    isHandlingChange = true

    value = ClampValue(value)

    control.slider:SetValue(value)
    control.slidervalue:SetText(value)

    --Update the slider label and tooltip
    updateSoundSliderLabelAndTooltip(control, value)

    --Play the sound now and raise the callback function
    if not doNotPlaySound then
        raiseSoundChangedCallback(nil, control, valueText)
    end

    isHandlingChange = false
end


local function UpdateValue(control, forceDefault, value)
--d("[LAMSoundSlider]UpdateValue-forceDefault: " .. tostring(forceDefault) .." , value: " ..tostring(value))

    local doNotPlaySound = true
    local data = control.data
    local defaultVar = data.default ~= nil and getDefaultValue(data.default)

    local valueOfSlider --the number variable to use to update the slider's selected index, as the internal sound name string cannot be used to update the slider's position!
    local saveSoundIndex = (data.saveSoundIndex ~= nil and getDefaultValue(data.saveSoundIndex)) or false
    local soundNameInternal, soundIndex
    --Save the internal sound name string?
    if not saveSoundIndex then
        if value ~= nil then
            value = ClampValue(value)

            soundNameInternal = soundLookup[value]
            --soundIndex = soundIndexLookup[value]
            valueOfSlider = value
        else
            if type(defaultVar) ~= "string" then defaultVar = soundsRef[conNone] end
            soundNameInternal = soundLookup[defaultVar]
            soundIndex = soundIndexLookup[defaultVar]
            valueOfSlider = soundIndex
        end
    else
        --Save the sound index number
        if value ~= nil then
            value = ClampValue(value)
            valueOfSlider = value
        else
            if type(defaultVar) ~= "number" then defaultVar = 1 end
            valueOfSlider = defaultVar
        end
    end


    if forceDefault then --if we are forcing defaults
        --Save/Load the internal soundName of the index seleced at the slider?
        value = (saveSoundIndex == true and defaultVar) or soundNameInternal
        data.setFunc(value)
    elseif value ~= nil then
        doNotPlaySound = false
        data.setFunc((saveSoundIndex == true and valueOfSlider) or soundNameInternal)
        --after setting this value, let's refresh the others to see if any should be disabled or have their settings changed
        util.RequestRefreshIfNeeded(control)
    else
        value = data.getFunc()
        --> getfunc changes value to the "internal_sound_name" but the slider needs the value as number! Get index via mapping table for internal_sound_name to number
        if not saveSoundIndex then
            valueOfSlider = (value ~= nil and soundIndexLookup[value]) or 1
        else
            valueOfSlider = (value ~= nil and value) or 1
        end
    end

    HandleValueChanged(control, valueOfSlider, doNotPlaySound, value)
    --[[
    control.slider:SetValue(valueOfSlider)
    control.slidervalue:SetText(valueOfSlider)

    updateSoundSliderLabel(control, valueOfSlider)
    --Play the sound now and raise the callback function
    if not doNotPlaySound then
        raiseSoundChangedCallback(nil, control, value)
    end
    ]]
end

local function OnMouseEnter(control)
    if control.isDisabled then return end
    ZO_Options_OnMouseEnter(control)
end

local function OnMouseExit(control)
    if control.isDisabled then return end
    ZO_Options_OnMouseExit(control)
end

function LAMCreateControl.soundslider(parent, sliderData, controlName)
    LASoundSliderIndex = LASoundSliderIndex + 1
    local soundSliderName = controlName or (widgetName .. tostring(LASoundSliderIndex))

    local control = util.CreateLabelAndContainerControl(parent, sliderData, soundSliderName)
    control:SetHandler("OnMouseEnter", OnMouseEnter)
    control:SetHandler("OnMouseExit", OnMouseExit)

    --Cache the default tooltip
    defaultTooltip = sliderData.tooltip or sliderData.name

    --Full width or half?
    control.isHalfWidth = sliderData.width == "half"

    --Slider's editBox input location
    local isInputOnRight = getDefaultValue(sliderData.inputLocation) == "right"

    --Disable single PlaySound if the table with additional PlaySound params is provided
    local playSoundData = getDefaultValue(sliderData.playSoundData)
    if playSoundData ~= nil then
        sliderData.playSound = false
    end
    control.noAutomaticSoundPreview = getDefaultValue(sliderData.noAutomaticSoundPreview)
    local showPlaySoundButton = getDefaultValue(sliderData.showPlaySoundButton)
    control.showPlaySoundButton = showPlaySoundButton

   --Default values: Show sound name / Play sound
    sliderData.saveSoundIndex = sliderData.saveSoundIndex or false
    if sliderData.showSoundName == nil then sliderData.showSoundName = true end
    if sliderData.playSound == nil then sliderData.playSound = true end

    --Slider control
    control.slider = wm:CreateControl(nil, control.container, CT_SLIDER)
    local slider = control.slider
    slider:SetAnchor(TOPLEFT)
    slider:SetHeight(14)
    if(isInputOnRight) then
        slider:SetAnchor(TOPRIGHT, nil, nil, -60)
    else
        slider:SetAnchor(TOPRIGHT)
    end
    slider:SetMouseEnabled(true)
    slider:SetOrientation(ORIENTATION_HORIZONTAL)
    --put nil for highlighted texture file path, and what look to be texture coords
    slider:SetThumbTexture("EsoUI\\Art\\Miscellaneous\\scrollbox_elevator.dds", "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator_disabled.dds", nil, 8, 16)
    local minValue = 1
    local maxValue = numSounds
    slider:SetMinMax(minValue, maxValue)
    slider:SetHandler("OnMouseEnter", function() OnMouseEnter(control) end)
    slider:SetHandler("OnMouseExit", function() OnMouseExit(control) end)

    slider.bg = wm:CreateControl(nil, slider, CT_BACKDROP)
    local bg = slider.bg
    bg:SetCenterColor(0, 0, 0)
    bg:SetAnchor(TOPLEFT, slider, TOPLEFT, 0, 4)
    bg:SetAnchor(BOTTOMRIGHT, slider, BOTTOMRIGHT, 0, -4)
    bg:SetEdgeTexture("EsoUI\\Art\\Tooltips\\UI-SliderBackdrop.dds", 32, 4)

    --[[ Min and max controls aren't needed at this slider
    control.minText = wm:CreateControl(nil, slider, CT_LABEL)
    local minText = control.minText
    minText:SetFont("ZoFontGameSmall")
    minText:SetAnchor(TOPLEFT, slider, BOTTOMLEFT)
    minText:SetText("")

    control.maxText = wm:CreateControl(nil, slider, CT_LABEL)
    local maxText = control.maxText
    maxText:SetFont("ZoFontGameSmall")
    maxText:SetAnchor(TOPRIGHT, slider, BOTTOMRIGHT)
    maxText:SetText("")
    ]]

    --The editbox at the slider
    control.slidervalueBG = wm:CreateControlFromVirtual(nil, slider, "ZO_EditBackdrop")
    if(isInputOnRight) then
        control.slidervalueBG:SetDimensions(32, 26)
        control.slidervalueBG:SetAnchor(LEFT, slider, RIGHT, 5, 0)
    else
        control.slidervalueBG:SetDimensions(50, 16)
        control.slidervalueBG:SetAnchor(TOP, slider, BOTTOM, 0, 0)
    end
    control.slidervalue = wm:CreateControlFromVirtual(nil, control.slidervalueBG, "ZO_DefaultEditForBackdrop")
    local slidervalue = control.slidervalue
    slidervalue:ClearAnchors()
    slidervalue:SetAnchor(TOPLEFT, control.slidervalueBG, TOPLEFT, 3, 1)
    slidervalue:SetAnchor(BOTTOMRIGHT, control.slidervalueBG, BOTTOMRIGHT, -3, -1)
    slidervalue:SetTextType(TEXT_TYPE_NUMERIC)
    if(isInputOnRight) then
        slidervalue:SetFont("ZoFontGameLarge")
    else
        slidervalue:SetFont("ZoFontGameSmall")
    end

    slidervalue:SetHandler("OnEscape", function(self)
        HandleValueChanged(control, sliderData.getFunc())
        self:LoseFocus()
    end)
    slidervalue:SetHandler("OnEnter", function(self)
        if control.isDisabled then return end
        self:LoseFocus()
    end)
    slidervalue:SetHandler("OnFocusLost", function(self)
        if control.isDisabled then return end
        local value = tonumber(self:GetText())
        control:UpdateValue(false, value)
    end)
    slidervalue:SetHandler("OnTextChanged", function(self)
        if control.isDisabled then return end
        if isHandlingChange then return end

        local input = self:GetText()
        if(#input > 1 and not input:sub(-1):match("[0-9]")) then return end
        local value = tonumber(input)
        if(value) then
            HandleValueChanged(control, value)
        end
    end)
    if(sliderData.autoSelect) then
        ZO_PreHookHandler(slidervalue, "OnFocusGained", function(self)
            self:SelectAll()
        end)
    end

    --local range = maxValue - minValue
    slider:SetValueStep(sliderData.step or 1)
    slider:SetHandler("OnValueChanged", function(self, value, eventReason)
        if control.isDisabled then return end
        if isHandlingChange then return end
        if eventReason == EVENT_REASON_SOFTWARE then return end
        HandleValueChanged(control, value)
        OnMouseEnter(control)
    end)
    slider:SetHandler("OnSliderReleased", function(self, value)
        if control.isDisabled then return end
        if self:GetEnabled() then
            control:UpdateValue(false, value)
            OnMouseEnter(control)
        end
    end)

    local function OnMouseWheel(self, value)
        if control.isDisabled then return end
        if(not self:GetEnabled()) then return end
        local new_value = (tonumber(slidervalue:GetText()) or 0) + (1 * value)
        control:UpdateValue(false, new_value)
        OnMouseEnter(control) --Update the tooltip to show the currently selected sound name
    end

    local sliderHasFocus = false
    local scrollEventInstalled = false
    local function UpdateScrollEventHandler()
        local needsScrollEvent = sliderHasFocus or slidervalue:HasFocus()
        if needsScrollEvent ~= scrollEventInstalled then
            local callback = needsScrollEvent and OnMouseWheel or nil
            slider:SetHandler("OnMouseWheel", callback, SLIDER_HANDLER_NAMESPACE)
            scrollEventInstalled = needsScrollEvent
        end
    end

    em:RegisterForEvent(soundSliderName .. "_OnGlobalMouseUp", EVENT_GLOBAL_MOUSE_UP, function()
        sliderHasFocus = (wm:GetMouseOverControl() == slider)
        UpdateScrollEventHandler()
    end)
    slidervalue:SetHandler("OnFocusGained", UpdateScrollEventHandler, SLIDER_HANDLER_NAMESPACE)
    slidervalue:SetHandler("OnFocusLost",   UpdateScrollEventHandler, SLIDER_HANDLER_NAMESPACE)


    --Show a "Play Sound" button for the preview, or directly play as the setFunc is called?
    if showPlaySoundButton == true then
        --Create the sound preview button
        local playSoundButtonName = soundSliderName .. "_PlaySoundButton"
        local playSoundButton = wm:CreateControl(playSoundButtonName, control, CT_BUTTON)
        if playSoundButton ~= nil then

            control.playSoundButton = playSoundButton

            playSoundButton:SetNormalTexture("/esoui/art/icons/item_u26_soundofsuccess.dds") --/esoui/art/battlegrounds/battlegrounds_scoretracker_playerteamindicator.dds (Play icon)
            playSoundButton:SetPressedOffset(2, 2)
            playSoundButton:SetNormalFontColor(ZO_HINT_TEXT:UnpackRGBA()) --ZO_NORMAL_TEXT

            playSoundButton:SetMouseEnabled(true)
            playSoundButton:SetHandler("OnMouseEnter", function(playSoundButtonCtrl)
                if control.isDisabled then return end
                playSoundButtonCtrl.data = {tooltipText = string.format(langStrings.previewSound, tostring(soundNames[slider:GetValue()]))}
                ZO_Options_OnMouseEnter(playSoundButtonCtrl)
            end)
            playSoundButton:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

            --playSoundButton:SetClickSound("Click")
            playSoundButton:SetHandler("OnClicked", function()
                if control.isDisabled then return end
                playSoundPreview(control, tonumber(slider:GetValue()), true)
            end)

            playSoundButton:SetMouseEnabled(true)
            playSoundButton:SetHidden(true) --will be changed at UpdateValue call -> function updateSoundSliderLabel

            --Position / Anchor the button
            if isInputOnRight then
                playSoundButton:SetDimensions(24, 24)
                if control.isHalfWidth then
                    playSoundButton:SetAnchor(LEFT, control.slidervalue, RIGHT, 8, 0)
                else
                    playSoundButton:SetAnchor(LEFT, control.slidervalue, RIGHT, 8, 0)
                end
            else
                if control.isHalfWidth then
                    playSoundButton:SetDimensions(24, 24)
                    playSoundButton:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 8)
                else
                    playSoundButton:SetDimensions(28, 28)
                    playSoundButton:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 12)
                end
            end
        end
    end

    --Warning icon
    if sliderData.warning ~= nil or sliderData.requiresReload then
        control.warning = wm:CreateControlFromVirtual(nil, control, "ZO_Options_WarningIcon")
        control.warning:SetAnchor(RIGHT, slider, LEFT, -5, 0)
        control.UpdateWarning = util.UpdateWarning
        control:UpdateWarning()
    end

    control.UpdateValue = UpdateValue
    control:UpdateValue()

    control.UpdateDisabled = UpdateDisabled
    control:UpdateDisabled()

    util.RegisterForRefreshIfNeeded(control)
    util.RegisterForReloadIfNeeded(control)

    return control
end


--Load the widget into LAM
local eventAddOnLoadedForWidgetName = widgetName .. "_EVENT_ADD_ON_LOADED"
local function registerWidget(eventId, addonName)
    if addonName ~= widgetName then return end
    em:UnregisterForEvent(eventAddOnLoadedForWidgetName, EVENT_ADD_ON_LOADED)

    if not LAM:RegisterWidget("soundslider", widgetVersion) then return end
end
em:RegisterForEvent(eventAddOnLoadedForWidgetName, EVENT_ADD_ON_LOADED, registerWidget)
