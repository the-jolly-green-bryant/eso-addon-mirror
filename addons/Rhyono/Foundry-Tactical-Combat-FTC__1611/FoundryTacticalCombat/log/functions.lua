--[[----------------------------------------------------------
    COMBAT LOG COMPONENT
  ]]----------------------------------------------------------
local FTC = FTC
FTC.Log = {}
FTC.Log.Defaults = {
  ["FTC_CombatLog"] = { BOTTOMLEFT, FTC_UI, BOTTOMLEFT, 24, -6 },
  ["LogWidth"] = 450,
  ["LogHeight"] = 300,
  ["AlternateChat"] = true,
  ["LogFont"] = "standard",
  ["LogFontSize"] = 16,
  ["LogOpacity"] = 100,
}
FTC:JoinTables(FTC.Defaults, FTC.Log.Defaults)

--[[----------------------------------------------------------
    COMBAT LOG FUNCTIONS
  ]]----------------------------------------------------------

--[[
 * Initialize Combat Log Component
 * --------------------------------
 * Called by FTC:Initialize()
 * --------------------------------
 ]]--
function FTC.Log:Initialize()

  -- Maybe create the log
  local FCL = _G["FTC_CombatLog"]
  if FCL == nil then
    FCL = FTC.LMW:CreateMsgWindow("FTC_CombatLog", GetString(FTC_CL_Label), nil, nil)
    FCL:SetDimensions(FTC.Vars.LogWidth, FTC.Vars.LogHeight)
    -- fix for High Isle GuiRoot startup error
    --FCL:SetParent(FTC_UI)
    FCL:SetParent(GuiRoot)
    FCL:ClearAnchors()
    FCL:SetAnchor(unpack(FTC.Vars.FTC_CombatLog))
    FCL:SetClampedToScreen(false)
    FCL:SetHandler("OnMouseUp", function() FTC.Menu:MoveLog() end)
  end

  -- Change the styling
  FCL.buffer = _G["FTC_CombatLogBuffer"]
  FCL.buffer:SetFont(FTC.UI:Font(FTC.Vars.LogFont, FTC.Vars.LogFontSize, true))
  FCL.buffer:SetMaxHistoryLines(1000)
  FTC_CombatLogLabel:SetFont(FTC.UI:Font(FTC.Vars.LogFont, FTC.Vars.LogFontSize + 2, true))
  FTC_CombatLogBg:SetAlpha(FTC.Vars.LogOpacity / 100)

  --[[
   * Prehook Chat window
   ]]--
  local chatSystem = SYSTEMS:GetObject("ChatSystem")
  local isPreHooked = false
  ZO_PostHook(chatSystem, "LoadChatFromSettings", function()
    if isPreHooked then return end

    zo_callLater(function()
      if FTC.Vars.AlternateChat and not chatSystem:IsMinimized() then
        chatSystem:Minimize()
      end
    end, 200)

    -- Mod High Isle non-alternating combat log 29-08-22
    -- Only hook to chat if alternating with chat
    if FTC.Vars.AlternateChat then
      ZO_PreHook(chatSystem, "Minimize", function() FTC.Log:SetupChat(false) end)
      ZO_PreHook(chatSystem, "Maximize", function() FTC.Log:SetupChat(true) end)
    end
    --End mod

    isPreHooked = true
  end)

  -- Mod High Isle non-alternating combat log 29-08-22
  -- If not alternating with chat then enable
  if (not FTC.Vars.AlternateChat) then FTC_CombatLog:SetHidden(false) end

  -- Indicate toggle to display (irrelevant when alternating with chat)
  FTC.init.toggleHide = false
  -- End mod

  -- Save initialization status
  if not FTC.init.Log then
    FTC.init.Log = true
  end
end

--[[
 * Setup Combat Log Interaction with Chat
 * --------------------------------
 * Called by FTC.Log:Initialize()
 * --------------------------------
 ]]--
function FTC.Log:SetupChat(chatShown)
  -- Toggle visibility with chat
  if FTC.Vars.AlternateChat then
    FTC_CombatLog:SetHidden(chatShown)
  end

  -- Always show in move mode
  if FTC.move then
    FTC_CombatLog:SetHidden(false)
  end
end

--[[
 * Setup Combat Log Interaction with Chat
 * --------------------------------
 * Called by FTC.Log:Initialize()
 * --------------------------------
 ]]--
function FTC.Log:Toggle()

  -- Bail if the log is disabled
  if (not FTC.Vars.EnableLog) then return end

  -- Mod High Isle non-alternating combat log 29-08-22
  -- Manage the toggle for chat alternating and non-chat alternating
  if FTC.Vars.AlternateChat then
    -- Toggle alternating with chat
    if FTC_CombatLog:IsHidden() then
      FTC.Log:SetupChat(false)
    else
      FTC.Log:SetupChat(true)
    end
  else
    if FTC_CombatLog:IsHidden() then
      -- Was hidden, so reveal
      FTC_CombatLog:SetHidden(false)
      FTC.init.toggleHide = false
    else
      -- Was visible, so hide
      FTC_CombatLog:SetHidden(true)
      FTC.init.toggleHide = true
    end
  end
  --End mod
end

-- Mod High Isle non-alternating combat log 29-08-22
--[[
 * Switch Combat Log visibility on layer change.
 * --------------------------------
 * Called by FTC.OnLayerChange()
 * --------------------------------
 ]]--
function FTC.Log:ToggleLayer(hide)

  -- Consider change based on request and current toggle state
  if hide then
    -- Request to hide - do nothing if already hidden
    if (FTC_CombatLog:IsHidden()) then return end
    -- Otherwise hide
    FTC_CombatLog:SetHidden(true)
  else
    -- Request to make visible - do nothing if already visible
    if (not FTC_CombatLog:IsHidden()) then return end
    -- Otherwise only allow if previously toggled to visible
    if (not FTC.init.toggleHide) then
      FTC_CombatLog:SetHidden(false)
    end
  end

end
--End mod


--[[
 * Print Message to Log
 * --------------------------------
 * Called by FTC.Log:Damage()
 * --------------------------------
 ]]--
function FTC.Log:Print(message, color)

  -- Get the log
  local log = _G["FTC_CombatLog"]

  -- Validate args
  if (message == nil) then return end
  local color = color or { 0.6, 0.6, 0.6 }

  -- Get the timestamp
  local time = "|c666666[" .. GetTimeString() .. "]|r "

  -- Write to the log
  log:AddText(time .. message, unpack(color))
end

--[[
 * Write Combat Log Damage Events
 * --------------------------------
 * Called by FTC:OnCombatEvent()
 * --------------------------------
 ]]--
function FTC.Log:CombatEvent(damage)

  -- Death
  if (damage.result == ACTION_RESULT_DIED or damage.result == ACTION_RESULT_DIED_XP) then
    FTC.Log:Print("You killed " .. zo_strformat("<<!aC:1>>", damage.target), { 0.6, 0.6, 0.6 })

    -- Shielding
  elseif (damage.result == ACTION_RESULT_DAMAGE_SHIELDED) then
    local subject = damage.out and zo_strformat("<<!aCg:1>>", damage.target) or "Your"
    FTC.Log:Print(subject .. " shield absorbed  |cEEEEEE" .. FTC.DisplayNumber(damage.value) .. "|r damage.", { 0.6, 0.2, 0.6 })

    -- Blocks
  elseif (damage.result == ACTION_RESULT_BLOCKED_DAMAGE) then
    local subject = damage.out and zo_strformat("<<!aCg:1>>", damage.target) or "You"
    local ability = damage.out and zo_strformat("<<!aC:1>> ", damage.ability) or ""
    FTC.Log:Print(subject .. " blocked " .. ability .. "taking |cEEEEEE" .. FTC.DisplayNumber(damage.value) .. "|r damage.", { 0.6, 0.1, 0 })

    -- Dodges
  elseif (damage.result == ACTION_RESULT_DODGED or damage.result == ACTION_RESULT_MISS) then
    local subject = damage.out and zo_strformat("<<!aCg:1>>", damage.target) or "You"
    local ability = damage.out and zo_strformat("<<!aC:1>> ", damage.ability) or ""
    FTC.Log:Print(subject .. " dodged " .. ability .. "taking no damage.", { 0.4, 0.4, 1.0 })

    -- Damage
  elseif (damage.value ~= 0) then

    -- Determine the subject
    local subject = (damage.out) and "You" or (damage.ability == "Falling" and "Gravity" or zo_strformat("<<!aC:1>>", damage.source))
    if (zo_strformat("<<!aC:1>>", damage.source) == FTC.Player.name and not damage.out) then subject = "You" end

    -- Determine the action
    local verb = damage.heal and " healed " or " hit "
    verb = damage.crit and " critically" .. verb or verb

    -- Determine the target
    local target = (damage.out and damage.target ~= "") and zo_strformat("<<!aC:1>>", damage.target) or ""
    if (not damage.out) then target = "you" end
    if (zo_strformat("<<!aC:1>>", damage.source) == FTC.Player.name and not damage.out) then target = "yourself" end

    -- Determine the ability used
    local ability = ""
    if (damage.ability ~= "") then
      ability = zo_strformat(" with <<!aC:1>>", damage.ability)
    end

    -- Determine the damage done
    local dtype = damage.heal and " health" or " damage"
    local amount = " for |cEEEEEE" .. FTC.DisplayNumber(damage.value) .. "|r" .. dtype .. "."

    -- Ignore Sprinting and Crouching
    if (ability == GetAbilityName(FTC_ABILITYID_SPRINT_DRAIN) or ability == GetAbilityName(FTC_ABILITYID_CROUCH_DRAIN)) then return end

    -- Outgoing damage
    local color = { 1, 1, 1 }
    if (damage.out) then color = { 0.8, 0.6, 0.2 } end
    if (damage.out and damage.crit) then color = { 0.9, 0.7, 0.4 } end

    -- Incoming damage
    if (not damage.out) then color = { 0.8, 0, 0 } end
    if ((not damage.out) and damage.crit) then color = { 0.9, 0, 0 } end

    -- Healing
    if (damage.heal) then color = { 0.6, 0.8, 0.2 } end
    if (damage.heal and damage.crit) then color = { 0.7, 0.9, 0.4 } end

    -- Ignore healing/ignore healing out of combat
    if (FTC.Vars.LogCOH and not IsUnitInCombat("player") and damage.heal) or (FTC.Vars.LogHideHeal and damage.heal) then

    else
      -- Construct the message
      FTC.Log:Print(subject .. verb .. target .. ability .. amount, color)
    end
  end
end

--[[
 * Write Combat Log Experience
 * --------------------------------
 * Called by FTC.OnXPUpdate()
 * --------------------------------
 ]]--
function FTC.Log:Exp(currentExp, reason)

  -- Get the new experience amount
  local diff = math.max(currentExp - FTC.Player.exp, 0)
  if (diff <= 0) then return end

  -- Determine label
  local label = ""
  if (reason == PROGRESS_REASON_KILL) then label = " kill "
  elseif (reason == PROGRESS_REASON_QUEST) then label = " quest "
  else label = " bonus " end

  -- Print to log
  FTC.Log:Print("You earned " .. FTC.DisplayNumber(diff) .. label .. "experience.", { 0, 0.6, 0.6 })
end

--[[
 * Write Combat Log Alliance Points
 * --------------------------------
 * Called by FTC.OnXPUpdate()
 * --------------------------------
 ]]--
function FTC.Log:AP(eventCode, alliancePoints, playSound, difference, reason, reasonSupplementaryInfo)
  if (difference < 0) then return end

  -- Print to log
  FTC.Log:Print("You earned " .. FTC.DisplayNumber(difference) .. " alliance points.", { 0, 0.6, 0.6 })
end
