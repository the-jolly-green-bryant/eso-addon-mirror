local Decay         = { health = 0, magicka = 0, stamina = 0 }
local DecayStep

local ReactionColor = {
  [UNIT_REACTION_DEFAULT]     = { .6, .1, .2, 1 },
  [UNIT_REACTION_FRIENDLY]    = { .1, .5, .1, 1 },
  [UNIT_REACTION_HOSTILE]     = { .6, .1, .2, 1 },
  [UNIT_REACTION_NEUTRAL]     = { .9, .9, .3, 1 },
  [UNIT_REACTION_NPC_ALLY]    = { .1, .5, .1, 1 },
  [UNIT_REACTION_PLAYER_ALLY] = { 0, .3, .8, 1 },
  ["INVULNERABLE"]            = { .5, .5, .2, 1 },
}

local function TargetReactionUpdate()
  if BUI_TargetFrame then
    local color

    if BUI.Target.Invul then
      color = ReactionColor["INVULNERABLE"]
    else
      local reaction = GetUnitReaction('reticleover')
      color          = (reaction == 1 or reaction == 3) and BUI.Vars.FrameHealthColor or ReactionColor[reaction]
    end
    BUI.Target.color = color
    BUI_TargetFrame.health.bar:SetColor(unpack(color))
  end
end

local function AttributeDecay()
  local frame = _G["BUI_PlayerFrame"]
  local count = 0
  for attribute, value in pairs(Decay) do
    if value > 0 then
      local w = value - DecayStep
      if w < DecayStep then w = 0 end
      Decay[attribute] = w
      count            = count + w
      local control    = frame[attribute]
      if attribute == "health" and BUI.Vars.FrameHorisontal then
        control.bar1:SetWidth(w / 2)
        control.bar2:SetWidth(w / 2)
      else
        control.bar1:SetWidth(w)
      end
    end
  end
  if count <= 0 then EVENT_MANAGER:UnregisterForUpdate("BUI_AttributeDecay") end
end

local function Attribute(unitTag, attribute, powerValue, powerMax, pct, shieldValue)
  local frame, group, enabled = nil, false, false
  local ShowMax               = BUI.Vars.FrameShowMax
  local pctLabel              = (pct * 100) .. "%"
  --Player Frame
  if unitTag == 'player' then
    frame   = BUI_PlayerFrame
    enabled = BUI.Vars.PlayerFrame
    if enabled and BUI.Vars.FramesFade and not PlayerFrameFadeDelay and not BUI.inMenu and BUI.Player.alt == nil then
      if BUI.inCombat or BUI.Player.health.pct < 1 or BUI.Player.magicka.pct < 1 or BUI.Player.stamina.pct < 1 then
        if BUI_PlayerFrame_Base:GetAlpha() < .01 then BUI.Frames.Fade(BUI_PlayerFrame_Base) end
      elseif BUI_PlayerFrame_Base:GetAlpha() > 0 then
        PlayerFrameFadeDelay = true
        BUI.CallLater("Player_FramesFade", 1500, function()
          PlayerFrameFadeDelay = false
          if not (BUI.inCombat or BUI.Player.health.pct < 1 or BUI.Player.magicka.pct < 1 or BUI.Player.stamina.pct < 1) then
            BUI.Frames.Fade(BUI_PlayerFrame_Base, true)
          end
        end)
      end
    end
    --Target Frame
  elseif unitTag == 'reticleover' then
    frame         = BUI_TargetFrame
    enabled       = BUI.Vars.TargetFrame
    local dead    = IsUnitDead(unitTag)
    local execute = not dead and pct <= BUIE.Vars.ExecutionThreshold / 100
    --Add %% to ZO_Target frame
    if not dead and BUI.Vars.DefaultTargetFrame and BUI.Vars.DefaultTargetFrameText and BUI_TargetResourceNumbers then
      local label = powerValue > 100000 and BUI.DisplayNumber(powerValue / 1000) .. "k" or BUI.DisplayNumber(powerValue)
      BUI_TargetResourceNumbers:SetText(label .. " (" .. pctLabel .. ")" .. (execute and ' |t36:36:/esoui/art/icons/mapkey/mapkey_groupboss.dds|t' or ""))
    end
    if execute then
      if BUI.Vars.CurvedFrame ~= 0 then
        BUI.UI.Expires(BUI_Curved_Execute)
      end
      if BUI.Vars.TargetFrame then
        BUI.UI.Expires(frame.execute)
        if BUIE.Vars.ExecutionChangeTargetColor then
          frame.health.bar:SetColor(unpack(BUIE.Vars.ExecutionTargetColor))
        end
      end
      if BUIE.Vars.ExecutionSound and BUI.Target.health.pct > BUIE.Vars.ExecutionThreshold / 100 then
        PlaySound(BUIE.Vars.ExecutionSoundType)
      end
    end
    --Execute icon
    if BUI.Vars.TargetFrame then
      frame.execute:SetHidden(not (BUIE.Vars.ExecutionIcon and execute))
    end
    if BUI.Vars.CurvedFrame ~= 0 then
      BUI_Curved_Execute:SetHidden(dead or not execute)
    end
    BUI.Target.health = { current = powerValue, max = powerMax, pct = pct }
    --Group Frames
  elseif BUI.init.Group and BUI.Group[unitTag] then
    frame = BUI.Group[unitTag].frame
    if not frame then return end
    enabled = true
    group   = true
    ShowMax = false
  else return end

  if enabled then
    local short = powerValue > 100000 or group
    local label = (short and BUI.DisplayNumber(powerValue / 1000, 1) or BUI.DisplayNumber(powerValue))
            .. (ShowMax and "/" .. (group and BUI.DisplayNumber(powerMax / 1000) or (short and BUI.DisplayNumber(powerMax / 1000, 1) or BUI.DisplayNumber(powerMax))) or "")
    local dead  = IsUnitDead(unitTag)

    if attribute == "health" then
      if not IsUnitOnline(unitTag) then
        label, pct, pctLabel, short = BUI.Loc("Offline"), 0, "", false
      elseif dead or powerValue < 0 then
        label, pct, pctLabel, short = BUI.Loc("Dead"), 0, "", false
        if group then
          if frame.dead:IsHidden() then PlaySound(BUI.Vars.GroupDeathSound) end
          frame.dead:SetHidden(false)
          BUI.UI.Expires(frame.dead)
        end
      else
        local add_pct = unitTag == 'reticleover' and not BUI.Vars.FramePercents
        label         = label .. (add_pct and " (" .. pctLabel .. ")" or "") .. (shieldValue > 0 and "[" .. BUI.DisplayNumber(shieldValue / (short and 1000 or 1)) .. "]" or "")
        if group then frame.dead:SetHidden(true) end
      end
    end

    local control = frame[attribute]
    local w       = (group and BUI.Vars.RaidWidth * BUI_RaidFrame.scale - 4 or control.bg:GetWidth())
    --Decay animation
    if unitTag == 'player' then
      local dw = control.bar:GetWidth() - pct * w
      dw       = dw > 0 and dw - Decay[attribute] or dw + Decay[attribute]
      if dw >= DecayStep then
        control.bar1:SetWidth(dw)
        Decay[attribute] = dw
        EVENT_MANAGER:RegisterForUpdate("BUI_AttributeDecay", 50, AttributeDecay)
      end
    end
    control.bar:SetWidth(pct * w)
    control.current:SetText(label .. (short and "k" or ""))
    control.pct:SetText(pctLabel)
  end
end

local function Initialize()
  if BUI and BUI.Frames then
    if BUI.Vars.PlayerFrame then
      DecayStep = BUI.Vars.FrameWidth / 60
    end
    if BUI.Frames.TargetReactionUpdate then
      BUI.Frames.TargetReactionUpdate = TargetReactionUpdate
      BUI.Frames.Attribute            = Attribute
    else
      BUIE.Log("TargetReactionUpdate not found")
    end
  else
    BUIE.Log("BUI and BUI.Frames not found")
  end
end

local step    = 10;
local current = 100;
local function TargetFrameAnimate()
  local powerMax   = 100000
  local percent    = current / 100
  local powerValue = powerMax * percent
  Attribute('reticleover', "health", powerValue, powerMax, percent, 0)
  if current - step >= 0 then
    current = current - step
  else
    current = 100;
    BUI.Frames.TargetReactionUpdate()
  end
end

function BUIE.TargetFrameShowPreview()
  EVENT_MANAGER:UnregisterForUpdate("TargetFramePreviewAnimate")
  EVENT_MANAGER:RegisterForUpdate("TargetFramePreviewAnimate", 200, TargetFrameAnimate)
  BUI_TargetFrame:SetHidden(false)
end

function BUIE.TargetFrameHidePreview()
  EVENT_MANAGER:UnregisterForUpdate("TargetFramePreviewAnimate")
  BUI_TargetFrame:SetHidden(true)
end

function BUIE.Execution.Initialize()
  Initialize()
  BUIE.Log("Execution Loaded")
end