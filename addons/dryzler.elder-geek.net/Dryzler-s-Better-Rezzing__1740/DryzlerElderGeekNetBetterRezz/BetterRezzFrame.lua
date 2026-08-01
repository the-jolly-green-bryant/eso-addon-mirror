local DEG_ADDON = _G["DEG_CURRENT_ADDON"]

local function d(msg)
  _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:d(msg)
end

local pi2half = math.pi / 2

DryzlersBetterRezzFrameStatics = {
  texture = "soulgem",
  textures = {
    soulgem = {
      texture = [[esoui/art/icons/soulgem_002_filled.dds]],
      normalizedAngle = -2.4
    },  
    arrowSmithing = {
      texture = [[esoui/art/tutorial/smithing_leftarrow_up.dds]],
      normalizedAngle = pi2half * -1
    },
    arrowCharacterCreate = {
      texture = [[esoui/art/charactercreate/charactercreate_leftarrow_up.dds]],
      normalizedAngle = pi2half * -1
    },    
    arrowChatOverflow = {
      texture = [[esoui/art/chatwindow/chat_overflowarrow_up.dds]],
      normalizedAngle = pi2half
    }    
  },
  frames = {},
  framesEnabled = false,
  hide = function()
    DEGBetterRezzRootFrame:SetHidden(true)
  end,
  show = function()
    DEGBetterRezzRootFrame:SetHidden(false)
    DryzlersBetterRezzFrameStatics.repaintAllFrames()
  end,
  clear = function(self)
    for k,v in pairs(self.frames) do
      v:disable()
    end
  end,
  fromTop = 0,
  repaintAllFrames = function(bIsUpdate)
    DryzlersBetterRezzFrameStatics.fromTop = 0
    
    DryzlersBetterRezzFrameStatics.sortFramesByRole()
    
    for k,v in pairs(DryzlersBetterRezzFrameStatics.frames) do
      DryzlersBetterRezzFrameStatics.repaintFrame(v, bIsUpdate)
    end
  end,
  repaintFrame = function(frame, bIsUpdate)
    local Addon = _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]
          
    local scale = Addon.savedVariablesAccount.settings.frameScale / 100
  
    local dim = frame.dim * scale
    local dimReticle = ZO_ReticleContainerReticle:GetHeight()
  
    if (DryzlersBetterRezzFrameStatics.fromTop == 0) then
      DryzlersBetterRezzFrameStatics.fromTop = dimReticle / 2
    end
  
    local fromTop = DryzlersBetterRezzFrameStatics.fromTop + dim / 2
      
    DryzlersBetterRezzFrameStatics.fromTop = DryzlersBetterRezzFrameStatics.fromTop + dim
  
    frame.control:SetAnchor(CENTER, DEGBetterRezzRootFrame, CENTER, 0, fromTop)
    frame.control:SetWidth(dim)
    frame.control:SetHeight(dim)
  
    local texture = DryzlersBetterRezzFrameStatics.textures[DryzlersBetterRezzFrameStatics.texture]
  
    frame.control:SetTexture(texture.texture)
    
    if (bIsUpdate) then
    
    else
      frame.normalizedAngle = texture.normalizedAngle
      frame:update(0, frame.control:GetAlpha())  
    end
  end,
  settingsFrameHelper = nil,
  showSettingsFrameHelper = function(self)
    local Addon = _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]
    local rgb = nil
    --148,0,137
    --local rgb = Addon.savedVariablesAccount.settings.colorTank
    --local rgb = self.savedVariablesAccount.settings.colorHealer    
    if self.settingsFrameHelper == nil then
      self.settingsFrameHelper = DryzlersBetterRezzFrame.new(rgb, true, false, false)
    end
    self.settingsFrameHelper:enable(rgb)
  end,
  hideSettingsFrameHelper = function(self)
    if self.settingsFrameHelper == nil then return end
    self.settingsFrameHelper:disable()
  end,
  sortFramesByRole = function(self)

    local healers = {}
    local tanks = {}
    local dds = {}
    local disabled = {}
  
    local numFrames = 0
    for numFrame,theFrame in pairs(DryzlersBetterRezzFrameStatics.frames) do
      if theFrame.isEnabled then 
        if theFrame.isHealer then
          table.insert(healers, theFrame)
        end
        if theFrame.isTank then
          table.insert(tanks, theFrame)
        end
        if theFrame.isDps then
          table.insert(dds, theFrame)     
        end
      else
        table.insert(disabled, theFrame)
      end
      
      numFrames = numFrames + 1
    end  
    
    DryzlersBetterRezzFrameStatics.frames = {}
    for numFrame,theFrame in pairs(healers) do
      table.insert(DryzlersBetterRezzFrameStatics.frames, theFrame)
    end
    for numFrame,theFrame in pairs(tanks) do
      table.insert(DryzlersBetterRezzFrameStatics.frames, theFrame)
    end
    for numFrame,theFrame in pairs(dds) do
      table.insert(DryzlersBetterRezzFrameStatics.frames, theFrame)
    end
    for numFrame,theFrame in pairs(disabled) do
      table.insert(DryzlersBetterRezzFrameStatics.frames, theFrame)
    end            
    
    
  end
}

DryzlersBetterRezzFrame = {}
DryzlersBetterRezzFrame.__index = DryzlersBetterRezzFrame

DryzlersBetterRezzFrame.new = function(rgb, isDps, isHealer, isTank)
  local theFrame = nil
  
  local numFrames = 0
  local control = nil
  while true do
    numFrames = numFrames + 1
    local ctrName = "DEGBetterRezzRootFrame"..numFrames
    if _G[ctrName] then
    
    else
      break
    end      
  end
  
  --for numFrame,theFrame in pairs(DryzlersBetterRezzFrameStatics.frames) do
    --if not theFrame.isEnabled then 
      --theFrame.isDps = isDps
      --theFrame.isHealer = isHealer
      --theFrame.isTank = isTank                 
      --theFrame:enable(rgb)
      --return theFrame
    --end
    --numFrames = numFrames + 1
  --end
  
  local self = setmetatable({}, DryzlersBetterRezzFrame)
  self.isEnabled = false
  self.control = WINDOW_MANAGER:CreateControl("DEGBetterRezzRootFrame"..numFrames, DEGBetterRezzRootFrame, CT_TEXTURE)
  self.control.origColor = {self.control:GetColor()}
  
  self.dim = 36
    
  self.isDps = isDps
  self.isHealer = isHealer
  self.isTank = isTank
    
  self.control:SetHidden(true)    
  
  table.insert(DryzlersBetterRezzFrameStatics.frames, self)
  
  self:enable(rgb)
  
  return self
end

function DryzlersBetterRezzFrame:update(angle, controlAlpha)
  self.control:SetTextureRotation(self.normalizedAngle + angle)
  self.control:SetAlpha(controlAlpha)  
end

function DryzlersBetterRezzFrame:enable(rgb)
  if self.isEnabled then return end
  
  DryzlersBetterRezzFrameStatics.repaintFrame(self)

  self.control:SetTextureRotation(self.normalizedAngle)
  
  if rgb == 'donottouch' then
  
  elseif rgb then
    local r,g,b = unpack(rgb)
    self.control:SetColor(r, g, b, 1)
  else 
    self.control:SetColor(unpack(self.control.origColor))  
  end
    
  self.control:SetHidden(false)
  
  self.isEnabled = true
  
  DryzlersBetterRezzFrameStatics.framesEnabled = true
  
  DryzlersBetterRezzFrameStatics.repaintAllFrames(true)
end

function DryzlersBetterRezzFrame:disable(bIsBulk)
  if not self.isEnabled then return end
  
  self.control:SetHidden(true)
  self.isEnabled = false
    
  local framesEnabled = false
  for numFrame,theFrame in pairs(DryzlersBetterRezzFrameStatics.frames) do
    if theFrame.isEnabled then
      framesEnabled = true
      do break end
    end
  end
  DryzlersBetterRezzFrameStatics.framesEnabled = framesEnabled
  
  if (bIsBulk) then
  
  else
    DryzlersBetterRezzFrameStatics.repaintAllFrames(true)
  end
  
end