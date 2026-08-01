local DEG_ADDON = _G["DEG_CURRENT_ADDON"]

local function d(msg)
  _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:d(msg)
end

local function d2(msg)
  _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:d2(msg)
end

local function ts(...)
  return tostring(...)
end

local Addon = {}
Addon.initialized = false
Addon.debug = false
Addon.debug2 = false
Addon.name = DEG_ADDON.ADDON_NAME
Addon.versionString = '1.022'
Addon.saveVariablesName = DEG_ADDON.SAVED_VARS_NAME
Addon.savedVariablesAccount = nil
Addon.savedVariablesChars = nil
Addon.saveVariablesVersion = 2
Addon.vars = {}
Addon.Settings = _G[DEG_ADDON.ADDON_NAME.."Settings"]
Addon.libSafe = nil

Addon.reticleSquareContainer = nil
Addon.reticleSquareOuter = nil
Addon.reticleSquareInner = nil

Addon.reticleCircleContainer = nil
Addon.reticleCirclePixels = {}

Addon.reticleCircleContainer = nil
Addon.reticleCircleOuterPixels = {}
Addon.reticleCircleInnerPixels = {}
Addon.reticleCircleHRule = nil
Addon.reticleCircleVRule = nil

Addon.reticleDotContainer = nil
Addon.reticleDotOuterPixels = {}
Addon.reticleDotInnerPixels = {}

Addon.reticleRuleContainer = nil
Addon.reticleRuleOuterPixels = {}
Addon.reticleRuleInnerPixels = {}

Addon.MODE_CIRCLE = 'circle'
Addon.MODE_SQUARE = 'square'
Addon.MODE_DOT = 'dot'
Addon.MODE_RULE = 'rule'


Addon.defaults = {
  alphaOuter = 0.60,
  alphaInner = 0.85,
  colorNoReaction = {0.8,0.8,0.8},
  colorOuter = {0,0,0},
  modes = {circle=false,square=false,dot=false,rule=true},
  circle = {
    scale = 100,
    hrule = false,
    hruleAlpha = 50,
    vrule = false,
    vruleAlpha = 50,    
  },
  square = {
    scale = 100,
    rotate = false,
  },
  dot = {
    scale = 100,
  },
  rule = {    
    hrule = true,
    hruleAlpha = 75,
    hruleScale = 100,
    vrule = true,
    vruleAlpha = 75,
    vruleScale = 100,
    rotate = false,
  },
}

function Addon:Initialize()
  if (self.initialized) then return end

  self.debug = false

  local defaultsAccount = {settings={modes=self.defaults.modes, circle=self.defaults.circle, square=self.defaults.square, dot=self.defaults.dot, rule=self.defaults.rule}}
  self.savedVariablesAccount = ZO_SavedVars:NewAccountWide(self.saveVariablesName, self.saveVariablesVersion, nil, defaultsAccount)
  
  for k,v in pairs(self.defaults.modes) do
    if self.savedVariablesAccount.settings.modes[k] == nil then
      self.savedVariablesAccount.settings.modes[k] = v
    end
  end
  for k,v in pairs(self.defaults.circle) do
    if self.savedVariablesAccount.settings.circle[k] == nil then
      self.savedVariablesAccount.settings.circle[k] = v
    end
  end  
  for k,v in pairs(self.defaults.square) do
    if self.savedVariablesAccount.settings.square[k] == nil then
      self.savedVariablesAccount.settings.square[k] = v
    end
  end
  for k,v in pairs(self.defaults.dot) do
    if self.savedVariablesAccount.settings.dot[k] == nil then
      self.savedVariablesAccount.settings.dot[k] = v
    end
  end
  for k,v in pairs(self.defaults.rule) do
    if self.savedVariablesAccount.settings.rule[k] == nil then
      self.savedVariablesAccount.settings.rule[k] = v
    end
  end

  if self.debug then
    self.savedVariablesAccount.settings.modes = self.defaults.modes
  end
  
  self.Settings:initialize()
  
  local moreMotd = ""
  if self.debug then moreMotd =" ,"..ts(GetGameTimeMilliseconds()) end 
  LibMOTD:setMessage(self.savedVariablesAccount, "|c3f95ffDryzler's|r |cEFEBBEReticle|r: "..GetString(SI_DEG_RETICLE_MOTD)..moreMotd, 1)
   
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(...) self:onEVENT_PLAYER_ACTIVATED(...) end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_TARGET_CHANGED, function(...) self:onEVENT_RETICLE_TARGET_CHANGED(...) end)
   
  if not self.debug then
    self:initializeReticles()
  end
  
  degLib("ad1")

  self.initialized = true
end

function Addon:updateReticleCircle()
  if (DoesUnitExist('reticleover')) then
    local r, g, b = GetUnitReactionColor('reticleover')    
    for k,v in pairs(self.reticleCircleInnerPixels) do
      v:SetColor(r,g,b,self.defaults.alphaInner)
      v:SetAlpha(self.defaults.alphaInner)
    end         
  else
    local r,g,b = unpack(self.defaults.colorNoReaction) 
    for k,v in pairs(self.reticleCircleInnerPixels) do
      v:SetColor(r,g,b,self.defaults.alphaInner)
      v:SetAlpha(self.defaults.alphaInner)    
    end
  end
end

function Addon:updateReticleSquare()
  if (DoesUnitExist('reticleover')) then
    local r, g, b = GetUnitReactionColor('reticleover')    
    self.reticleSquareInner:SetColor(r,g,b,self.defaults.alphaInner)
    self.reticleSquareInner:SetAlpha(self.defaults.alphaInner)
    
    local r, g, b = unpack(self.defaults.colorOuter)
    self.reticleSquareOuter:SetColor(r,g,b,self.defaults.alphaOuter)
    self.reticleSquareOuter:SetAlpha(self.defaults.alphaOuter)    
         
  else
    local r,g,b = unpack(self.defaults.colorNoReaction)
    self.reticleSquareInner:SetColor(r,g,b,self.defaults.alphaInner)
    self.reticleSquareInner:SetAlpha(self.defaults.alphaInner)    
    
    local r, g, b = unpack(self.defaults.colorOuter)
    self.reticleSquareOuter:SetColor(r,g,b,self.defaults.alphaOuter)
    self.reticleSquareOuter:SetAlpha(self.defaults.alphaOuter)    
  end
end

function Addon:updateReticleDot()
  if (DoesUnitExist('reticleover')) then
    local r, g, b = GetUnitReactionColor('reticleover')    
    for k,v in pairs(self.reticleDotInnerPixels) do
      v:SetColor(r,g,b,self.defaults.alphaInner)
      v:SetAlpha(self.defaults.alphaInner)
    end         
  else
    local r,g,b = unpack(self.defaults.colorNoReaction) 
    for k,v in pairs(self.reticleDotInnerPixels) do
      v:SetColor(r,g,b,self.defaults.alphaInner)
      v:SetAlpha(self.defaults.alphaInner)    
    end
  end
end

function Addon:updateReticleRule()
  local hruleAlpha  = self.savedVariablesAccount.settings.rule.hruleAlpha / 100
  local vruleAlpha  = self.savedVariablesAccount.settings.rule.vruleAlpha / 100
  if (DoesUnitExist('reticleover')) then
    local r, g, b = GetUnitReactionColor('reticleover')
             
    self.reticleRuleHRule:SetColor(r,g,b,hruleAlpha)
    self.reticleRuleVRule:SetColor(r,g,b,vruleAlpha)         
  else
    local r,g,b = unpack(self.defaults.colorNoReaction)
    self.reticleRuleHRule:SetColor(r,g,b,hruleAlpha)
    self.reticleRuleVRule:SetColor(r,g,b,vruleAlpha)
  end
end

function Addon:updateReticles()
  for k,v in pairs(self.savedVariablesAccount.settings.modes) do
    if v then
      if k == self.MODE_CIRCLE then
        self:updateReticleCircle()
      elseif k == self.MODE_SQUARE then
        self:updateReticleSquare()
      elseif k == self.MODE_DOT then
        self:updateReticleDot()                
      elseif k == self.MODE_RULE then
        self:updateReticleRule()        
      end
    end
  end
end

function Addon:activateReticles()
  d("activateReticles")
  for k,v in pairs(self.savedVariablesAccount.settings.modes) do    
    if k == self.MODE_CIRCLE then
      d2("activateReticles k="..ts(k).." v="..ts(v))
      
      if v then
        --local width = 7 * (self.savedVariablesAccount.settings.circle.scale/100)
        local width = math.floor(10 * (self.savedVariablesAccount.settings.circle.scale/100))
        local widthComplete = (width - 1) * 2
        local r,g,b = unpack(self.defaults.colorOuter)
        local a = self.defaults.alphaOuter                                      
        self:paintCircle(self.reticleCircleContainer, width -1, r, g, b, a, self.reticleCircleOuterPixels)
        self:paintCircle(self.reticleCircleContainer, width -2, r, g, b, a, self.reticleCircleOuterPixels, true)
                             
        width = width - 3
        r,g,b = unpack(self.defaults.colorNoReaction)
        a = self.defaults.alphaInner
        self:paintCircle(self.reticleCircleContainer, width, r, g, b, a, self.reticleCircleInnerPixels)
        self:paintCircle(self.reticleCircleContainer, width - 1, r, g, b, a, self.reticleCircleInnerPixels, true)
                
        if self.savedVariablesAccount.settings.circle.hrule then
          local alpha  = self.savedVariablesAccount.settings.circle.hruleAlpha / 100
          self.reticleCircleHRule:SetWidth(widthComplete)
          self.reticleCircleHRule:SetHeight(2)
          self.reticleCircleHRule:SetColor(0.8,0.8,0.8,alpha)
          self.reticleCircleHRule:SetAlpha(alpha)
          self.reticleCircleHRule:SetHidden(false)
        end
        
        if self.savedVariablesAccount.settings.circle.vrule then
          local alpha  = self.savedVariablesAccount.settings.circle.vruleAlpha / 100
          self.reticleCircleVRule:SetWidth(2)
          self.reticleCircleVRule:SetHeight(widthComplete)
          self.reticleCircleVRule:SetColor(0.8,0.8,0.8,alpha)
          self.reticleCircleVRule:SetAlpha(alpha)
          self.reticleCircleVRule:SetHidden(false)
        end
      end
      self.reticleCircleHRule:SetHidden(not self.savedVariablesAccount.settings.circle.hrule)
      self.reticleCircleVRule:SetHidden(not self.savedVariablesAccount.settings.circle.vrule)
      self.reticleCircleContainer:SetHidden(not v)
    elseif k == self.MODE_SQUARE then
      if v then
        local width = math.floor(12 * (self.savedVariablesAccount.settings.square.scale/100))
        --6
        local space = math.floor(4 * (self.savedVariablesAccount.settings.square.scale/100))
        --2
        if space < 4 then space = 4 end
        --4
        if width < space then width = space + 1 end
        if width - space <= 1 then space = space - 1 end
        --9
        --3        
        self.reticleSquareOuter:SetWidth(width)
        self.reticleSquareOuter:SetHeight(width)
        self.reticleSquareOuter:SetAlpha(self.defaults.alphaOuter)
        
        width = width - space
        self.reticleSquareInner:SetWidth(width)        
        self.reticleSquareInner:SetHeight(width)
        self.reticleSquareInner:SetAlpha(self.defaults.alphaInner)
        
        if self.savedVariablesAccount.settings.square.rotate then
          self.reticleSquareOuter:SetTextureRotation(math.pi / 4)
          self.reticleSquareInner:SetTextureRotation(math.pi / 4)
        else
          self.reticleSquareOuter:SetTextureRotation(0)
          self.reticleSquareInner:SetTextureRotation(0)        
        end                
      end
      self.reticleSquareContainer:SetHidden(not v)
    elseif k == self.MODE_DOT then
      if v then
        local width = math.floor(6 * (self.savedVariablesAccount.settings.dot.scale/100))
        local r,g,b = unpack(self.defaults.colorOuter)
        local a = self.defaults.alphaOuter
        self:paintCircle(self.reticleDotContainer, width - 1, r, g, b, a, self.reticleDotOuterPixels)
        self:paintCircle(self.reticleDotContainer, width - 2, r, g, b, a, self.reticleDotOuterPixels, true)

        r,g,b = unpack(self.defaults.colorNoReaction)
        a = self.defaults.alphaInner
        
        self:paintCircle(self.reticleDotContainer, width - 3, r, g, b, a, self.reticleDotInnerPixels)
        local startWidth = width - 4
        for innerWidth=startWidth,0,-1 do
          self:paintCircle(self.reticleDotContainer, innerWidth, r, g, b, a, self.reticleDotInnerPixels, true)        
        end
      end
      self.reticleDotContainer:SetHidden(not v)
    elseif k == self.MODE_RULE then      
      if v then
      
        local rotate = 0
        if self.savedVariablesAccount.settings.rule.rotate then
          rotate = math.pi / 4        
        end      
      
        if self.savedVariablesAccount.settings.rule.hrule then
          local width = math.floor(19 * (self.savedVariablesAccount.settings.rule.hruleScale/100))
          local alpha  = self.savedVariablesAccount.settings.rule.hruleAlpha / 100
          local r,g,b = unpack(self.defaults.colorNoReaction)
          self.reticleRuleHRule:SetWidth(width)
          self.reticleRuleHRule:SetHeight(2)
          self.reticleRuleHRule:SetColor(r,g,b,alpha)
          self.reticleRuleHRule:SetAlpha(alpha)
          self.reticleRuleHRule:SetTextureRotation(rotate)
          self.reticleRuleHRule:SetHidden(false)
        end
        
        if self.savedVariablesAccount.settings.rule.vrule then
          local width = math.floor(19 * (self.savedVariablesAccount.settings.rule.vruleScale/100))
          local alpha  = self.savedVariablesAccount.settings.rule.vruleAlpha / 100
          local r,g,b = unpack(self.defaults.colorNoReaction)
          self.reticleRuleVRule:SetWidth(2)
          self.reticleRuleVRule:SetHeight(width)
          self.reticleRuleVRule:SetColor(r,g,b,alpha)
          self.reticleRuleVRule:SetAlpha(alpha)
          self.reticleRuleVRule:SetTextureRotation(rotate)
          self.reticleRuleVRule:SetHidden(false)
        end            
        
        
      end
      self.reticleRuleHRule:SetHidden(not self.savedVariablesAccount.settings.rule.hrule)
      self.reticleRuleVRule:SetHidden(not self.savedVariablesAccount.settings.rule.vrule)
      self.reticleRuleContainer:SetHidden(not v)
    end    
  end
end

function Addon:initializeReticles()  
  ZO_ReticleContainerReticle:SetHidden(true)
  ZO_ReticleContainerReticle.SetHidden = function() end 
        
  --circle
  if not self.reticleCircleContainer then
    local DEG_ReticleCircle = WINDOW_MANAGER:CreateControl("DEG_ReticleCircle", ZO_ReticleContainer, CT_CONTROL)
    DEG_ReticleCircle:SetAnchor(CENTER, GuiRoot, CENTER)
    
    local DEG_ReticleCircleHRule = WINDOW_MANAGER:CreateControl("DEG_ReticleCircleHRule", DEG_ReticleCircle, CT_TEXTURE)
    DEG_ReticleCircleHRule:SetAnchor(CENTER, DEG_ReticleCircle, CENTER)    
    
    local DEG_ReticleCircleVRule = WINDOW_MANAGER:CreateControl("DEG_ReticleSquareVRule", DEG_ReticleCircle, CT_TEXTURE)
    DEG_ReticleCircleVRule:SetAnchor(CENTER, DEG_ReticleCircle, CENTER)
  
    self.reticleCircleContainer = DEG_ReticleCircle
    self.reticleCircleHRule = DEG_ReticleCircleHRule
    self.reticleCircleVRule = DEG_ReticleCircleVRule
  end  
  self.reticleCircleContainer:SetHidden(true)
    
  --square
  if not self.reticleSquareContainer then
    local DEG_ReticleSquare = WINDOW_MANAGER:CreateControl("DEG_ReticleSquare", ZO_ReticleContainer, CT_CONTROL)
    DEG_ReticleSquare:SetAnchor(CENTER, GuiRoot, CENTER)
    
    local DEG_ReticleSquareOuter = WINDOW_MANAGER:CreateControl("DEG_ReticleSquareOuter", DEG_ReticleSquare, CT_TEXTURE)
    DEG_ReticleSquareOuter:SetAnchor(CENTER, DEG_ReticleSquare, CENTER)
        
    local DEG_ReticleSquareInner = WINDOW_MANAGER:CreateControl("DEG_ReticleSquareInner", DEG_ReticleSquare, CT_TEXTURE)
    DEG_ReticleSquareInner:SetAnchor(CENTER, DEG_ReticleSquare, CENTER)

    self.reticleSquareContainer = DEG_ReticleSquare
    self.reticleSquareOuter = DEG_ReticleSquareOuter
    self.reticleSquareInner = DEG_ReticleSquareInner
  end  
  self.reticleSquareContainer:SetHidden(true)
  
  --dot
  if not self.reticleDotContainer then
    local DEG_ReticleDot = WINDOW_MANAGER:CreateControl("DEG_ReticleDot", ZO_ReticleContainer, CT_CONTROL)
    DEG_ReticleDot:SetAnchor(CENTER, GuiRoot, CENTER)
    
    self.reticleDotContainer = DEG_ReticleDot
  end  
  self.reticleDotContainer:SetHidden(true)  
  
  --rule
  if not self.reticleRuleContainer then
    local DEG_ReticleRule = WINDOW_MANAGER:CreateControl("DEG_ReticleRule", ZO_ReticleContainer, CT_CONTROL)
    DEG_ReticleRule:SetAnchor(CENTER, GuiRoot, CENTER)
    
    local DEG_ReticleRuleHRule = WINDOW_MANAGER:CreateControl("DEG_ReticleRuleHRule", DEG_ReticleRule, CT_TEXTURE)
    DEG_ReticleRuleHRule:SetAnchor(CENTER, DEG_ReticleRule, CENTER)    
    
    local DEG_ReticleRuleVRule = WINDOW_MANAGER:CreateControl("DEG_ReticleRuleVRule", DEG_ReticleRule, CT_TEXTURE)
    DEG_ReticleRuleVRule:SetAnchor(CENTER, DEG_ReticleRule, CENTER)    
    
    self.reticleRuleContainer = DEG_ReticleRule
    self.reticleRuleHRule = DEG_ReticleRuleHRule
    self.reticleRuleVRule = DEG_ReticleRuleVRule    
  end  
  self.reticleDotContainer:SetHidden(true)  
end

function Addon:paintCircle(parent, width, r, g, b, a, pointList, doNotRemovePoints)
  d("paintCircle r="..ts(r).."g="..ts(g).."b="..ts(b).."a="..ts(a))

  if not doNotRemovePoints then
    for k,v in pairs(pointList) do
      v:SetHidden(true)
      pointList[k] = nil
    end
  end

  local ra = width
  local xmittel = width / 2 + 0.5
  local ymittel = width / 2 + 0.5

-- REM Bresenham-Algorithmus für einen Achtelkreis in Pseudo-Basic
-- REM gegeben seien r, xmittel, ymittel
-- REM Initialisierungen für den ersten Oktanten
 local x = ra
 local y = 0
 local fehler = ra
 --REM "schnelle" Richtung ist hier y!

   
 self:setPixel(parent, width, xmittel + x, ymittel + y, r, g, b, a, pointList, doNotRemovePoints)

 --REM Pixelschleife: immer ein Schritt in schnelle Richtung, hin und wieder auch einer in langsame
 while y < x do
    --REM Schritt in schnelle Richtung
    local dy = y*2+1 --: REM bei Assembler-Implementierung *2 per Shift
    y = y+1
    fehler = fehler-dy
    if fehler<0 then
       --REM Schritt in langsame Richtung (hier negative x-Richtung)
       local dx = 1-x*2 --: REM bei Assembler-Implementierung *2 per Shift
       x = x-1
       fehler = fehler-dx
    end
    self:setPixel(parent, width, xmittel+x, ymittel+y, r, g, b, a, pointList, doNotRemovePoints)
    --REM Wenn es um einen Bildschirm und nicht mechanisches Plotten geht,
    --REM kann man die anderen Oktanten hier gleich mit abdecken:
    self:setPixel(parent, width, xmittel-x, ymittel+y, r, g, b, a, pointList, doNotRemovePoints)
    self:setPixel(parent, width, xmittel-x, ymittel-y, r, g, b, a, pointList, doNotRemovePoints)
    self:setPixel(parent, width, xmittel+x, ymittel-y, r, g, b, a, pointList, doNotRemovePoints)
    self:setPixel(parent, width, xmittel+y, ymittel+x, r, g, b, a, pointList, doNotRemovePoints)
    self:setPixel(parent, width, xmittel-y, ymittel+x, r, g, b, a, pointList, doNotRemovePoints)
    self:setPixel(parent, width, xmittel-y, ymittel-x, r, g, b, a, pointList, doNotRemovePoints)
    self:setPixel(parent, width, xmittel+y, ymittel-x, r, g, b, a, pointList, doNotRemovePoints)
 end
end

function Addon:_setPixel(parent, pixelWidth, pixelHeight, x, y, r, g, b, a, pointList, doNotRemovePoints)
  local controlName = "DEG_ReticleCirclex"..ts(x).."y"..ts(y)
  local theControl = WINDOW_MANAGER:GetControlByName(controlName)
  if not theControl then
    theControl = WINDOW_MANAGER:CreateControl(controlName, parent, CT_TEXTURE)
  end
  
  d2("_setPixel x="..ts(x).." y="..ts(y))
  
  local offset = 0.5
  
  theControl:SetAnchor(CENTER, parent, CENTER, x + offset, y + offset)
  theControl:SetWidth(pixelWidth)
  theControl:SetHeight(pixelHeight)
  theControl:SetColor(r,g,b,1)
  theControl:SetAlpha(a)    
  theControl:SetHidden(false)
  
  pointList[controlName] = theControl
end

function Addon:setPixel(parent, width, x, y, r, g, b, a, pointList, doNotRemovePoints)  
  local x2 = math.floor(x - width / 2)
  local y2 = math.floor(y - width / 2)
  
  local x3 = x2
  local y3 = y2
  
  local pixelWidth = 2
  local pixelHeight = 2
  
  local fillDirLeft = false
  local fillDirRight = false
  local fillDirTop = false
  local fillDirBottom = false  
  
  if x < 0 then
    fillDirLeft = true
    fillDirBottom= true
    fillDirTop= true  
    if y > 0 then
      --linksoben
      x3 = x3 - 1
      y3 = y3 + 1
    elseif y < 0 then
      --linksunten
      x3 = x3 - 1
      y3 = y3 + 1
    else
      --links
      --x != 0, y = 0
      x3 = x3 - 1
      --höhe = 1?      
    end
  elseif x > 0 then
    fillDirRight = true
    fillDirBottom= true
    fillDirTop= true
    if y > 0 then
      --rechtsoben
      x3 = x3 - 1
      y3 = y3 + 1      
    elseif y < 0 then
      --rechtsunten
      x3 = x3 - 1
      y3 = y3 + 1      
    else
      --x != 0, y = 0
      x3 = x3 - 1
      --höhe = 1?      
    end
  else
    --x = 0
    if y > 0 then
      --oben
      fillDirRight = true
      fillDirLeft = true
      fillDirTop = true      
      y3 = y3 + 1
      --breit = 1?
    elseif y < 0 then
      --unten
      fillDirRight = true
      fillDirLeft = true
      fillDirBottom = true      
      y3 = y3 + 1
      --breit = 1?      
    else
      --x == 0, y = 0
    end
  end
  
  local x3 = x2
  local y3 = y2
  
  --local pixelWidth = 1.7
  --local pixelHeight = 1.7
  
  --local offset = 0.25
  local offset = 1
  
  local pixelWidth = 1 + offset
  local pixelHeight = 1 + offset
  
  x3 = x3 - (offset/2)
  y3 = y3 - (offset/2)
  
  d2("setPixel x="..ts(x).." y="..ts(y).." x2="..ts(x2).." y2="..ts(y2).." x3="..ts(x3).." y3="..ts(y3))

  self:_setPixel(parent, pixelWidth, pixelHeight, x3, y3, r, g, b, a, pointList, doNotRemovePoints)   
  
  if doNotRemovePoints and false then
    --look if there is something to fill up
      if fillDirRight then
        local hasFill = false
        for tempxplus=5,2 do
          if not hasFill then
            local tempx = x3 + tempxplus
            local tempy = y3
            local tempControlName = "DEG_ReticleCirclex"..ts(tempx).."y"..ts(tempy)
            local tempControl = WINDOW_MANAGER:GetControlByName(tempControlName)
            if tempControl then
              if not tempControl:IsHidden() then
                --lücke dazwischen füllen
                for newxplus=1,tempxplus do
                  local newx = x3 + newxplus
                  local newy = tempy
                  self:_setPixel(parent, pixelWidth, pixelHeight, newx, newy, r, g, b, a, pointList, doNotRemovePoints)
                end
                hasFill = true
              end
            end
          end
        end
      end
      
      if fillDirLeft then
        local hasFill = false
        for tempxminus=5,2 do
          if not hasFill then
            local tempx = x3 - tempxminus
            local tempy = y3
            local tempControlName = "DEG_ReticleCirclex"..ts(tempx).."y"..ts(tempy)
            local tempControl = WINDOW_MANAGER:GetControlByName(tempControlName)
            if tempControl then
              if not tempControl:IsHidden() then
                --lücke dazwischen füllen
                for newxminus=tempxminus,1 do
                  local newx = x3 - newxminus
                  local newy = tempy
                  self:_setPixel(parent, pixelWidth, pixelHeight, newx, newy, r, g, b, a, pointList, doNotRemovePoints)
                end
                hasFill = true
              end
            end
          end
        end
      end      

      if fillDirTop then
        local hasFill = false
        for tempyminus=5,2 do
          if not hasFill then
            local tempx = x3
            local tempy = y3 - tempyminus 
            local tempControlName = "DEG_ReticleCirclex"..ts(tempx).."y"..ts(tempy)
            local tempControl = WINDOW_MANAGER:GetControlByName(tempControlName)
            if tempControl then
              if not tempControl:IsHidden() then
                --lücke dazwischen füllen
                for newyminus=tempyminus,1 do
                  local newy = y3 - newyminus
                  local newx = tempx
                  self:_setPixel(parent, pixelWidth, pixelHeight, newx, newy, r, g, b, a, pointList, doNotRemovePoints)
                end
                hasFill = true
              end
            end
          end
        end
      end      
      
      if fillDirBottom then
        local hasFill = false
        for tempyplus=5,2 do
          if not hasFill then
            local tempx = x3
            local tempy = y3 + tempyplus
            local tempControlName = "DEG_ReticleCirclex"..ts(tempx).."y"..ts(tempy)
            local tempControl = WINDOW_MANAGER:GetControlByName(tempControlName)
            if tempControl then
              if not tempControl:IsHidden() then
                --lücke dazwischen füllen
                for newyplus=tempyplus,1 do
                  local newy = y3 + newyplus
                  local newx = tempx
                  self:_setPixel(parent, pixelWidth, pixelHeight, newx, newy, r, g, b, a, pointList, doNotRemovePoints)
                end
                hasFill = true
              end
            end
          end
        end
      end          
  end  
end

--#################################################################################################

function Addon:onEVENT_RETICLE_TARGET_CHANGED()
  d2("onEVENT_RETICLE_TARGET_CHANGED")
  self:updateReticles()  
end

function Addon:onEVENT_PLAYER_ACTIVATED(intEventCode, bInitial)
  d("onEVENT_PLAYER_ACTIVATED: "..GetUnitName("player"))
  
  if self.debug then
    self:initializeReticles()
  end  
  
  self:activateReticles()
  self:updateReticles()
  
  _G.degsettings = Addon.savedVariablesAccount.settings
  
end

--#################################################################################################


function Addon:d(m)
  if self.debug then
    _G.d(self.name.."> "..tostring(m))
  end
end

function Addon:d2(m)
  if self.debug and self.debug2 then
    _G.d(self.name.."(2)> "..tostring(m))
  end
end

_G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT] = Addon;

EVENT_MANAGER:RegisterForEvent(DEG_ADDON.ADDON_NAME, EVENT_ADD_ON_LOADED, 
  function(event, AddonName)
    if AddonName == _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT].name then
      _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:Initialize()
      EVENT_MANAGER:UnregisterForEvent(_G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT].name, EVENT_ADD_ON_LOADED)
    end
  end
)