local DEG_ADDON = _G["DEG_CURRENT_ADDON"]

local function d(msg)
  _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:d(msg)
end

local function ts(...)
  return tostring(...)
end

local Addon = {}
Addon.initialized = false
Addon.debug = false--release:false
Addon.name = DEG_ADDON.ADDON_NAME
Addon.versionString = '1.046'
Addon.saveVariablesName = DEG_ADDON.SAVED_VARS_NAME
Addon.savedVariablesAccount = nil
Addon.saveVariablesVersion = 1
Addon.vars = {framesByUnitTag = {}, debugFrames = nil, lastUpdateTime = 0}
Addon.debugPointer = nil
Addon.FrameClass = DryzlersBetterRezzFrame
Addon.Settings = _G[DEG_ADDON.ADDON_NAME.."Settings"]

function Addon:Initialize()
  if (self.initialized) then return end
    
--  SLASH_COMMANDS["/tdegad"] = self.showAd
  
--  local LINK_COLOR = ZO_ColorDef:New("5959D5")
--  local LINK_MOUSE_OVER_COLOR = ZO_ColorDef:New("B8B8D3")

--  local OnClicked = function() RequestOpenUnsafeURL("https://gardon.me") end
  --local button = DEGAdLink1
  --button:SetClickSound("Click")
  --button:SetMouseOverFontColor(LINK_MOUSE_OVER_COLOR:UnpackRGBA())  
  --button:SetHandler("OnClicked", OnClicked)
  --button:SetDimensions(button:GetLabelControl():GetTextDimensions())  
  
  --local OnClicked = function() RequestOpenUnsafeURL("https://wikivotes.org") end
  --local button = DEGAdLink2
  --button:SetClickSound("Click")
  --button:SetMouseOverFontColor(LINK_MOUSE_OVER_COLOR:UnpackRGBA())  
  --button:SetHandler("OnClicked", OnClicked)
  --button:SetDimensions(button:GetLabelControl():GetTextDimensions())  
  
  
  --SCENE_MANAGER:RegisterTopLevel(DEGAd, true)   -- enables close on Esc
    
  local defaultsAccount = {settings={activeHealer=true,activeTank=true,activeDD=true,icon="arrowChatOverflow",frameScale=150,colorHealer={51/255,204/255,51/255},colorTank={255/255,153/255,51/255}}}
  self.savedVariablesAccount = ZO_SavedVars:NewAccountWide(self.saveVariablesName, self.saveVariablesVersion, nil, defaultsAccount)
  
  for k,v in pairs(defaultsAccount) do
    if k == settings then
      for k2,v2 in pairs(v) do
        if self.savedVariablesAccount[k][k2] == nil then
          self.savedVariablesAccount[k][k2] = v2
        end
      end
    end    
  end
  
  DryzlersBetterRezzFrameStatics.texture = self.savedVariablesAccount.settings.icon
    
  self.Settings:initialize()
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(...) self:onEVENT_PLAYER_ACTIVATED(...) end)  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_UPDATE, function(...) self:onEVENT_GROUP_UPDATE(...) end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_UNIT_DEATH_STATE_CHANGED, function(...) self:onEVENT_UNIT_DEATH_STATE_CHANGED(...) end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_CONNECTED_STATUS, function(...) self:onEVENT_GROUP_MEMBER_CONNECTED_STATUS(...) end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_LEFT, function(...) self:onEVENT_GROUP_MEMBER_LEFT(...) end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_JOINED, function(...) self:onEVENT_GROUP_MEMBER_JOINED(...) end)
  
  --EVENT_UNIT_FRAME_UPDATE (integer eventCode,string unitTag)
  --EVENT_GROUP_SUPPORT_RANGE_UPDATE (integer eventCode,string unitTag,boolean status) 
  --EVENT_GROUP_MEMBER_LEFT (integer eventCode,string memberCharacterName,number reason,boolean isLocalPlayer,boolean isLeader,string memberDisplayName,boolean actionRequiredVote) 
  --EVENT_GROUP_MEMBER_JOINED (integer eventCode,string memberName)    
  
  local moreMotd = ""
  if self.debug then moreMotd =" ,"..ts(GetGameTimeMilliseconds()) end  
  LibMOTD:setMessage(self.savedVariablesAccount, "|c3f95ffDryzler's|r |cEFEBBEBetter Rezzing|r: "..GetString(SI_DEG_REZZ_MOTD)..moreMotd, 1) 
  
  degLib("ad1")
  
  self.initialized = true
end


function Addon:onRootFrameUpdate()
  if not self.initialized then return end
   
  if not DryzlersBetterRezzFrameStatics.framesEnabled then return end
  
  local ms = GetGameTimeMilliseconds()
  if ms < self.vars.lastUpdateTime then return end  
  self.vars.lastUpdateTime = ms + 100
  
  --debug frame
  if self.vars.debugFrames then    
    for k,v in pairs(self.vars.debugFrames) do
      if v.isEnabled then
        --d("self.vars.debugTargetX="..self.vars.debugTargetX..";self.vars.debugTargetY="..self.vars.debugTargetY)
        --[13:12] DryzlerElderGeekNetBetterRezz> self.vars.debugTargetX=0.25745356965065;self.vars.debugTargetY=0.63210330295563
        self:updateFrame(v, self.vars.debugTargetX, self.vars.debugTargetY, 1.00)
      end
    end    
  end

  --active group frames
  for k,v in pairs(self.vars.framesByUnitTag) do
    self:updateRezzFrame(k,v)
  end
end

function Addon:updateRezzFrame(sUnitTag, frame)
  if not frame.isEnabled then return end
      
  if not IsUnitDead(sUnitTag) then
    frame:disable()
    return
  end
      
  local Bx, By = GetMapPlayerPosition(sUnitTag)
  local alpha = 0.75
  if IsUnitBeingResurrected(sUnitTag) then
    alpha = 0.30      
  elseif DoesUnitHaveResurrectPending(sUnitTag) then
    --muss e drücken
    alpha = 0.20      
  elseif IsUnitReincarnating(sUnitTag) then
    --weißer geist
    alpha = 0.20      
  elseif IsUnitResurrectableByPlayer(sUnitTag) then
    alpha = 1.00      
  end        
  if not IsUnitInGroupSupportRange(sUnitTag) then
    alpha = 0.00
  end
  
  self:updateFrame(frame, Bx, By, alpha)
end

function Addon:updateFrame(frame, Bx, By, controlAlpha)  
    local x, y, posDir = GetMapPlayerPosition("player")        
    local camDir = GetPlayerCameraHeading()
        
    if x==nil or y==nil or posDir==nil or camDir == nil then return end
        
    local pi2half = math.pi / 2
    
    --spieler
    local Ax = x
    local Ay = y
    
    --ziel
--    local Bx = self.vars.debugTargetX
--    local By = self.vars.debugTargetY    
    
    --rechter winkel
    local Cx = Ax
    local Cy = By
    
    --steht der spielernördlich vom ziel?    
    local Dy = By - Ay
    local Dx = Bx - Ax
    
    local dist = math.sqrt((Dx * Dx) + (Dy * Dy))

    local a = math.sqrt((Cx-Bx)*(Cx-Bx)+(Cy-By)*(Cy-By))
    local b = math.sqrt((Ax-Cx)*(Ax-Cx)+(Ay-Cy)*(Ay-Cy))
    local c = math.sqrt((Bx-Ax)*(Bx-Ax)+(By-Ay)*(By-Ay))
    local alpha = math.atan2(a, b)

    local dirDiff = posDir - camDir
    -- dirDiff = wieviel muss man nach links drehen damit es 0 ist
        
    local angle = alpha
    
    if Dy > 0 then 
      if Dx > 0 then
        --d("playerDir="..posDir.." spieler steht nördlich, spieler steht westlich")
        local camAbstandZuSuden = math.pi - camDir
        angle = alpha + camAbstandZuSuden        
      else
        --d("playerDir="..posDir.." spieler steht nördlich, spieler steht östlich")
        local camAbstandZuSuden = math.pi - camDir
        angle = alpha * -1 + camAbstandZuSuden
      end
    else
      if Dx > 0 then
        --d("playerDir="..posDir.." spieler steht südlich, spieler steht westlich")
        local camAbstandZuNorden = math.pi * 2 - camDir
        angle = alpha * -1 + camAbstandZuNorden
      else
        --d("playerDir="..posDir.." spieler steht südlich, spieler steht östlich")
        local camAbstandZuNorden = math.pi * 2 - camDir
        angle = alpha + camAbstandZuNorden
      end    
    end
      
    -- - heißt nach rechts drehen
--    if angle < 0 then
--      angle = angle - 0.314
--    elseif angle > 0 then
--      angle = angle + 0.314
--    end
    frame:update(angle, controlAlpha)
end


function Addon:refreshhRezzFrames()
  if IsUnitDead('player') then
    --self:deactivateAllFrames()
    --return
  end
  
  for k,v in pairs(self.vars.framesByUnitTag) do
    v:disable(true)
  end
  self.vars.framesByUnitTag = {}
    
  local playerGroupUnitTag = GetGroupUnitTagByIndex(GetGroupIndexByUnitTag("player"))
    
  for i=1,GetGroupSize() do
    --IsUnitResurrectableByPlayer
    --IsUnitBeingResurrected
    --DoesUnitHaveResurrectPending
    --IsUnitOnline
    --IsUnitDead
    --IsUnitReincarnating
    
    --GetUnitType
    --GetUnitClassId
    --GetUnitDisplayName
  
    local sUnitTag = GetGroupUnitTagByIndex(i)
    if sUnitTag == playerGroupUnitTag then
    
    else              
      if not IsUnitOnline(sUnitTag) then
        --spieler nicht online                      
      elseif DoesUnitHaveResurrectPending(sUnitTag) then
        --muss e drücken
        self:activateRezzFrame(sUnitTag)
      elseif IsUnitReincarnating(sUnitTag) then
        --weißer geist
        self:activateRezzFrame(sUnitTag)
      elseif IsUnitBeingResurrected(sUnitTag) then        
        --wird wiederbelebt
          --vom spieler?
        self:activateRezzFrame(sUnitTag)          
      elseif IsUnitDead(sUnitTag) then
        self:activateRezzFrame(sUnitTag)
        --if IsUnitResurrectableByPlayer(sUnitTag) then
          --todo icon stärker?
        --end
      else
        --??
      end
    end
  end
      
  self:enableAllFrames()
end



function Addon:activateRezzFrame(sUnitTag)
  
  local isDps, isHealer, isTank = GetGroupMemberRoles(sUnitTag)

  
  local rgb = nil
  if isTank then
    if not self.savedVariablesAccount.settings.activeTank then return end
    --rgb ={255/255,153/255,51/255}
    rgb = self.savedVariablesAccount.settings.colorTank
  elseif isHealer then
    if not self.savedVariablesAccount.settings.activeHealer then return end
    --rgb ={51/255,204/255,51/255}
    rgb = self.savedVariablesAccount.settings.colorHealer
  else
    if not self.savedVariablesAccount.settings.activeDD then return end
  end

  if not self.vars.framesByUnitTag[sUnitTag] then
    self.vars.framesByUnitTag[sUnitTag] = self.FrameClass.new(rgb, isDps, isHealer, isTank)
  end
  
  self:updateRezzFrame(sUnitTag, self.vars.framesByUnitTag[sUnitTag])
end

--function Addon:deactivateRezzFrame(sUnitTag)
--  if self.vars.framesByUnitTag[sUnitTag] then
--    self.vars.framesByUnitTag[sUnitTag]:disable()
--  end
--end

function Addon:deactivateAllFrames()
  DryzlersBetterRezzFrameStatics:hide()  
end

function Addon:enableAllFrames()
  DryzlersBetterRezzFrameStatics:show()
end

--#################################################################################################

Addon.groupPointers = {}

function Addon:onEVENT_GROUP_UPDATE()
  --This event fires after the group UnitTags have been updated.
  self:refreshhRezzFrames() 
end

function Addon:onEVENT_UNIT_DEATH_STATE_CHANGED(_, sUnitTag, isDead)
  self:refreshhRezzFrames()
end

function Addon:onEVENT_GROUP_MEMBER_CONNECTED_STATUS (eventCode, unitTag, isOnline)
  self:refreshhRezzFrames()
end

function Addon:onEVENT_GROUP_MEMBER_LEFT (integereventCode,stringmemberCharacterName,numberreason,booleanisLocalPlayer,booleanisLeader,stringmemberDisplayName,booleanactionRequiredVote)
  self:refreshhRezzFrames()
end

function Addon:onEVENT_GROUP_MEMBER_JOINED (integereventCode,stringmemberName)
  self:refreshhRezzFrames()
end

function DEGBetterRezzing_ToggleAdWindow()
  --SCENE_MANAGER:ToggleTopLevel(DEGAd)
end

function Addon:showAd()
  DEGBetterRezzing_ToggleAdWindow()
end

function Addon:onEVENT_PLAYER_ACTIVATED(intEventCode, bInitial)
  d("onEVENT_PLAYER_ACTIVATED: "..GetUnitName("player"))
  
  DryzlersBetterRezzFrameStatics:clear()  
  self:refreshhRezzFrames()

  if self.debug then
    local x, y, playerDir = GetMapPlayerPosition("player")    

    self.vars.debugTargetX = x + 0.003 -- 0.5426509976387
    self.vars.debugTargetY = y + 0.003 -- 0.4738946557045       
    
    self.vars.debugFrames = {}       
    table.insert(self.vars.debugFrames, self.FrameClass.new(self.savedVariablesAccount.settings.colorHealer, false, true, false))    
    table.insert(self.vars.debugFrames, self.FrameClass.new(self.savedVariablesAccount.settings.colorTank, false, false, true))
    table.insert(self.vars.debugFrames, self.FrameClass.new(nil, true, false, false))
    table.insert(self.vars.debugFrames, self.FrameClass.new(nil, true, false, false))   
  end
  
  self:showAd()
end

--#################################################################################################

function Addon:d(m)
  if self.debug then
    _G.d(self.name.."> "..tostring(m))
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