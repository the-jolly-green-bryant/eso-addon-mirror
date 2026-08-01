
-- ------------------------------------------------------------------------------
-- AddOn : AT_Finisher                                                         --
-- Description : This Addon displays a message when the target can be          --
--               effectively hit using a finisher spell.                       --
-- Author : Carter_DC                                                          --
-- V 1.1.8                                                                     --
--                                                                             --
-- ------------------------------------------------------------------------------


-- ------------------------------------------------------------------------------
-- dependencies                                                              ----
-- ------------------------------------------------------------------------------
local LAM = LibAddonMenu2


-- ------------------------------------------------------------------------------
-- Globals                                                                   ----
-- ------------------------------------------------------------------------------

AT_Finisher               = {}
AT_Finisher.addonName     = "AT_Finisher"
AT_Finisher.version       = "1.1.8"
AT_Finisher.currentTarget = ""
AT_Finisher.uiLocked  = true

AT_Finisher.defaults      = {  -- default settings for saved variables

     uiTop                = GuiRoot:GetHeight()/2-38, 
     uiLef                = GuiRoot:GetWidth()/2-164,
     
     difficultyThreshold  = MONSTER_DIFFICULTY_NORMAL, -- =2
     enableDiffThreshold     = true,
     
     hpThreshold          = 1000,
     enableHPThreshold    = true,
     
     enableHostilePlayer  = false,
     
     triggerValue  = 25,
     triggerMessage = "Finish Him !!!",
	 
     fontColorR    = 1,
     fontColorG    = 0.11,
     fontColorB    = 0,
     
}
AT_Finisher.savedVariables={}

-- ------------------------------------------------------------------------------
-- Event Handlers                                                            ----
-- ------------------------------------------------------------------------------

-- called when any addon is loaded
-- initiate stuffs and sh!ts
function AT_Finisher.OnAddOnLoaded(eventCode, name)
   if name ~= AT_Finisher.addonName then return end
   
   AT_Finisher.savedVariables = ZO_SavedVars:New("ATFinisherSavedVariables", 1, nil, AT_Finisher.defaults)
   
   -- UI   
   AT_Finisher.InitUI()
   --anim
   AT_Finisher.finisherTimeline = ANIMATION_MANAGER:CreateTimeline()
   AT_Finisher.settingsTimeline = ANIMATION_MANAGER:CreateTimeline()
   AT_Finisher.CreateAnim()
   -- Settings menu
   AT_Finisher.CreateSettingsMenu()
   
   
   --events
   EVENT_MANAGER:RegisterForEvent( AT_Finisher.addonName, EVENT_POWER_UPDATE, AT_Finisher.OnPowerUpdate)
   EVENT_MANAGER:UnregisterForEvent(AT_Finisher.addonName, EVENT_ADD_ON_LOADED)
end


function AT_Finisher.OnPowerUpdate( eventCode , unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax )
   
  if (AT_Finisher.IsValidTarget(unitTag, powerType, powerValue, powerMax)==false) then return end 
  
    if (AT_Finisher.currentTarget ~= GetRawUnitName('reticleover')) then
       --d("current : "..AT_Finisher.currentTarget)
       --d("reticle : "..GetRawUnitName('reticleover'))
      AT_Finisher.currentTarget = GetRawUnitName('reticleover')
      AT_Finisher.finisherTimeline:PlayFromStart() 
      
    end
   
end

-- ------------------------------------------------------------------------------
-- core                                                                      ----
-- ------------------------------------------------------------------------------

function AT_Finisher.Debug(debugString)
  CHAT_SYSTEM["containers"][1]["currentBuffer"]:AddMessage("|c00FFFF"..debugString.."|r") 
end


function AT_Finisher.IsValidTarget(unitTag, powerType, powerValue, powerMax)
  --basic checks
  if (unitTag ~= 'reticleover') then return false end
  if (GetUnitReaction(unitTag) ~= UNIT_REACTION_HOSTILE) then return false end  
  if (powerType ~= POWERTYPE_HEALTH) then return false end
  if (powerValue/powerMax)>(AT_Finisher.savedVariables.triggerValue/100) then 
     if (AT_Finisher.currentTarget == GetRawUnitName('reticleover')) then
      --target was once valid but isn't anymore, must have regen health in some way
      AT_Finisher.currentTarget=""
     end  
     return false
  end
  --options checks
  --PVP
  if (AT_Finisher.savedVariables.enableHostilePlayer == true) and (GetUnitType(unitTag) == COMBAT_UNIT_TYPE_PLAYER ) then return true end
  --Diff Threshold
  if (AT_Finisher.savedVariables.enableDiffThreshold == true) and (GetUnitDifficulty(unitTag) >= AT_Finisher.savedVariables.difficultyThreshold) then return true end
  --Hp Threshold
  if (AT_Finisher.savedVariables.enableHPThreshold == true) and (powerMax >= (AT_Finisher.savedVariables.hpThreshold * 1000)) then return true end

  return false
end


-- ------------------------------------------------------------------------------
-- UI                                                                        ----
-- ------------------------------------------------------------------------------

function AT_Finisher.InitUI()

  ATFinisherUi:SetHidden(false)
  AT_Finisher.RestoreUIPosition()
    
  local label = WINDOW_MANAGER:CreateControl("ATFinisherUiLabel", ATFinisherUi, CT_LABEL)
    label:SetVerticalAlignment(1)
    label:SetHorizontalAlignment(1)
    label:SetScale(1)
    label:SetAnchor(TOP, ATFinisherUi, TOP, 0, 0)    
    label:SetFont("ZoFontWinH1")
    label:SetColor(AT_Finisher.savedVariables.fontColorR,AT_Finisher.savedVariables.fontColorG,AT_Finisher.savedVariables.fontColorB,1)
    label:SetDrawLayer(1) 
    label:SetText(AT_Finisher.savedVariables.triggerMessage)
    label:SetDimensions(label:GetTextDimensions()) 
    label:SetAlpha(0)
     
 end
 
function AT_Finisher.CreateAnim()

--finisher anim
  local control = WINDOW_MANAGER:GetControlByName("ATFinisherUiLabel")
  local alphaAnimIn = AT_Finisher.finisherTimeline:InsertAnimation(ANIMATION_ALPHA,control)
    alphaAnimIn:SetAlphaValues(0, 1)
    alphaAnimIn:SetDuration(100)
  local scaleAnimIn = AT_Finisher.finisherTimeline:InsertAnimation(ANIMATION_SCALE,control)
    scaleAnimIn:SetScaleValues(0.5, 2.5)
    scaleAnimIn:SetDuration(250)
    scaleAnimIn:SetEasingFunction(ZO_BounceEase)
  local alphaAnimOut = AT_Finisher.finisherTimeline:InsertAnimation(ANIMATION_ALPHA,control,1500)
    alphaAnimOut:SetAlphaValues(1, 0)
    alphaAnimOut:SetDuration(750)
    alphaAnimOut:SetEasingFunction(ZO_EaseInOutQuartic)
  local scaleAnimOut = AT_Finisher.finisherTimeline:InsertAnimation(ANIMATION_SCALE,control,250)
    scaleAnimOut:SetScaleValues(2.5, 1)
    scaleAnimOut:SetDuration(750)
    scaleAnimOut:SetEasingFunction(ZO_BounceEase)  

--settings anim  
  local texture = WINDOW_MANAGER:CreateControl("ATFinisherDragIcon", ATFinisherUi, CT_TEXTURE)
    texture:SetDimensions(50,50)
    texture:SetAnchor(CENTER, ATTimerUi, TOPLEFT, 13, 3)
    texture:SetTexture("AT_Timer/textures/arrows.dds")
    texture:SetDrawLayer(2)
    texture:SetHidden(true)
       
  local dragScaleAnimIn = AT_Finisher.settingsTimeline:InsertAnimation(ANIMATION_SCALE,texture)
    dragScaleAnimIn:SetScaleValues(0.75, 1.25)
    dragScaleAnimIn:SetDuration(250)
  local dragScaleAnimOut = AT_Finisher.settingsTimeline:InsertAnimation(ANIMATION_SCALE,texture,250)
    dragScaleAnimOut:SetScaleValues(1.25, 0.75)
    dragScaleAnimOut:SetDuration(250)
  
  AT_Finisher.settingsTimeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, -1)   

  
end

--toggle the animation for UI positionning
function AT_Finisher.UILockedToggle()
  if (AT_Finisher.uiLocked) then
    AT_Finisher.uiLocked = false
    --unlock ui and play animation
    ATFinisherUi:SetMouseEnabled(true)
    ATFinisherUi:SetMovable(true)  
    --ATFinisherUi:SetHidden(false)
    local dragIcon = WINDOW_MANAGER:GetControlByName("ATFinisherDragIcon")
    dragIcon:SetHidden(false)
    local label = WINDOW_MANAGER:GetControlByName("ATFinisherUiLabel")
    label:SetAlpha(1)
    AT_Finisher.settingsTimeline:PlayFromStart()        
  else
    AT_Finisher.uiLocked = true
    --stop animation and lock ui
    ATFinisherUi:SetMouseEnabled(false)
    ATFinisherUi:SetMovable(false)
    AT_Finisher.settingsTimeline:Stop() 
    local dragIcon = WINDOW_MANAGER:GetControlByName("ATFinisherDragIcon")
    dragIcon:SetHidden(true)
    local label = WINDOW_MANAGER:GetControlByName("ATFinisherUiLabel")
    label:SetAlpha(0)
    --ATFinisherUi:SetHidden(true)    
  end
end

--called by the UI (see xml file)
--save new UI position
function AT_Finisher.OnUIMoveStop()
  AT_Finisher.savedVariables.uiTop = ATFinisherUi:GetTop()
  AT_Finisher.savedVariables.uiLeft = ATFinisherUi:GetLeft()
end

--reset the Ui anchor to the saved position
function AT_Finisher.RestoreUIPosition()
  local left = AT_Finisher.savedVariables.uiLeft
  local top = AT_Finisher.savedVariables.uiTop
 
  ATFinisherUi:ClearAnchors()
  ATFinisherUi:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end


-- ------------------------------------------------------------------------------
-- Settings Menu                                                             ----
-- ------------------------------------------------------------------------------

function AT_Finisher.CreateSettingsMenu()
   local difficultyList ={
     [1] = "EASY",     
     [2] = "NORMAL____*",
     [3] = "HARD_______**",
     [4] = "DEADLY_____***",
   }
    
   local panelData = {
      type = "panel",
      name = AT_Finisher.addonName,
      displayName = "|cFFAA33"..AT_Finisher.addonName.."|r",
      author = "Carter_DC",
      version = AT_Finisher.version,
      registerForRefresh = true,
      registerForDefaults = true,
   }
   LAM:RegisterAddonPanel(AT_Finisher.addonName.."_LAM", panelData)

   local optionsTable = 
   {
      [1] = {
        type = "description",
        text = GetString(AT_FINISHER_DESCRIPTION),
      },
      [2] = {
        type = "header",
        --name = "OPTIONS",
        width = "full",
      },
      [3] = {
          type = "button",
          name = GetString(AT_FINISHER_UNLOCK),
          tooltip = GetString(AT_FINISHER_UNLOCK_TOOLTIP),
          func = function(lockBtn)
                  if (AT_Finisher.uiLocked) then
                      lockBtn:SetText(GetString(AT_FINISHER_LOCK))
                  else
                      lockBtn:SetText(GetString(AT_FINISHER_UNLOCK))
                  end
                  AT_Finisher.UILockedToggle()
                end,
       },
       [4] ={
         type = "slider",
         name = GetString(AT_FINISHER_TRIGGER),
         tooltip = GetString(AT_FINISHER_TRIGGER_TOOLTIP),
         min = 20,
         max = 50,
         step = 1,
         getFunc = function() return (AT_Finisher.savedVariables.triggerValue) end,
         setFunc = function(trigger)
            AT_Finisher.savedVariables.triggerValue = trigger    
         end,
         default = AT_Finisher.defaults.triggerValue,
      }, 
      [5] = {
        type = "checkbox",
        name = GetString(AT_FINISHER_PVP),
        tooltip = GetString(AT_FINISHER_PVP_TOOLTIP),
        getFunc = function() return AT_Finisher.savedVariables.enableHostilePlayer end,
        setFunc = function(value)
          AT_Finisher.savedVariables.enableHostilePlayer = value            
        end,
        --width = "half", --or "half" (optional)
        default = AT_Finisher.defaults.enableHostilePlayer
      },  
      [6] = {
        type = "header",
        --name = "OPTIONS",
        width = "half",
      },      
      [7] = {
        type = "checkbox",
        name = GetString(AT_FINISHER_DIFFTHR_BTN),
        tooltip = GetString(AT_FINISHER_DIFFTHR_BTN_TOOLTIP),
        getFunc = function() return AT_Finisher.savedVariables.enableDiffThreshold end,
        setFunc = function(value)
          AT_Finisher.savedVariables.enableDiffThreshold = value
          --TODO enable/disable dropbox    
        end,
        --width = "half", --or "half" (optional)
        default = AT_Finisher.defaults.enableDiffThreshold
      },
      [8] ={
        type = "dropdown",
        name = GetString(AT_FINISHER_DIFFTHR_SLIDER),
        tooltip = GetString(AT_FINISHER_DIFFTHR_SLIDER_TOOLTIP),
        choices = difficultyList,
        getFunc = function() return difficultyList[AT_Finisher.savedVariables.difficultyThreshold] end,
        setFunc = function(selected)
          for index, name in ipairs(difficultyList) do
            if name == selected then
              AT_Finisher.savedVariables.difficultyThreshold = index
            break
            end
          end   
        end,
        disabled = function() return not AT_Finisher.savedVariables.enableDiffThreshold end,
        default = difficultyList[AT_Finisher.defaults.difficultyThreshold],
      },
      [9] = {
        type = "header",
        --name = "OPTIONS",
        width = "half",
      },
      [10] = {
        type = "checkbox",
        name = GetString(AT_FINISHER_HPTHR_BTN),
        tooltip = GetString(AT_FINISHER_HPTHR_BTN_TOOLTIP),
        getFunc = function() return AT_Finisher.savedVariables.enableHPThreshold end,
        setFunc = function(value)
          AT_Finisher.savedVariables.enableHPThreshold = value
          --TODO enable/disable slider    
        end,
        --width = "half", --or "half" (optional)
        default = AT_Finisher.defaults.enableHPThreshold
      },  
      [11] ={
         type = "slider",
         name = GetString(AT_FINISHER_HPTHR_SLIDER),
         tooltip = GetString(AT_FINISHER_HPTHR_SLIDER_TOOLTIP),
         min = 100,
         max = 2000,
         step = 100,
         getFunc = function() return AT_Finisher.savedVariables.hpThreshold end,
         setFunc = function(minHP)
            AT_Finisher.savedVariables.hpThreshold = minHP    
         end,
         disabled = function() return not AT_Finisher.savedVariables.enableHPThreshold end,
         default = AT_Finisher.defaults.hpThreshold,
      },
      [12] = {
        type = "header",
        --name = "OPTIONS",
        width = "half",
      },  
      [13] = {
        type = "colorpicker",
        name = GetString(AT_FINISHER_FONTCOLOR),
        tooltip = GetString(AT_FINISHER_FONTCOLOR_TOOLTIP),
        getFunc = function()
           return AT_Finisher.savedVariables.fontColorR, AT_Finisher.savedVariables.fontColorG, AT_Finisher.savedVariables.fontColorB,1
              
        end,
        setFunc = function(r, g, b,a)
              --
              local label = WINDOW_MANAGER:GetControlByName("ATFinisherUiLabel")
              label:SetColor(r,g,b)
              label:SetAlpha(0)
              AT_Finisher.savedVariables.fontColorR = r
              AT_Finisher.savedVariables.fontColorG = g
              AT_Finisher.savedVariables.fontColorB = b              
        end    
        
      },
	  [14] = {
		type = "editbox",
		name = GetString(AT_FINISHER_FINISH),
		tooltip = GetString(AT_FINISHER_FINISH_TOOLTIP),
		getFunc = function() return AT_Finisher.savedVariables.triggerMessage end,
		setFunc = function(msg)
            AT_Finisher.savedVariables.triggerMessage = msg    
         end, 
		isMultiline = false,
		width = "full",
		warning = GetString(AT_FINISHER_RELOAD),
		default = AT_Finisher.defaults.triggerMessage,
	  },
   }
   
   LAM:RegisterOptionControls(AT_Finisher.addonName.."_LAM", optionsTable)
   
end

EVENT_MANAGER:RegisterForEvent(AT_Finisher.addonName, EVENT_ADD_ON_LOADED, AT_Finisher.OnAddOnLoaded)
