-- Full-screen curtain, independent of the game scene (as in PBsTetris).
local Transition={}; Transition.__index=Transition; PBWT.Transition=Transition
local IN_MS,OUT_MS,HOLD_MIN_MS,HOLD_MAX_MS=280,340,100,1200
function Transition.New(owner)
    local self=setmetatable({owner=owner},Transition)
    local root=WINDOW_MANAGER:CreateTopLevelWindow("PBsWarTableCurtain")
    root:SetAnchorFill(GuiRoot); root:SetHidden(true)
    root:SetDrawTier(DT_HIGH); root:SetDrawLayer(DL_OVERLAY); root:SetDrawLevel(9)
    local black=WINDOW_MANAGER:CreateControl(nil,root,CT_BACKDROP)
    black:SetAnchorFill(root); black:SetCenterColor(0,0,0,1); black:SetEdgeColor(0,0,0,0); black:SetEdgeTexture("",1,1,1)
    self.root=root
    self.tick=function() self:Tick(GetFrameTimeMilliseconds()) end
    return self
end
function Transition:Start(after)
    if self.phase then return end
    self.phase,self.started,self.after="in",GetFrameTimeMilliseconds(),after
    self.root:SetAlpha(0); self.root:SetHidden(false)
    EVENT_MANAGER:RegisterForUpdate("PBsWarTableTransition",16,self.tick)
end
function Transition:Finish()
    self.phase,self.after=nil,nil
    self.root:SetAlpha(0); self.root:SetHidden(true)
    EVENT_MANAGER:UnregisterForUpdate("PBsWarTableTransition")
    self.owner:SyncComputer()
end
function Transition:Cancel()
    self:Finish()
end
function Transition:Tick(now)
    if not self.phase then return end
    local elapsed=math.max(0,now-self.started)
    if self.phase=="in" then
        local alpha=math.min(1,elapsed/IN_MS); self.root:SetAlpha(alpha)
        if alpha==1 then
            local after=self.after
            self.phase,self.started,self.after="hold",now,nil
            -- Clear the curtain and timer even if the scene callback raises.
            local ok,err=pcall(after)
            if not ok then self:Finish(); error(err) end
        end
    elseif self.phase=="hold" then
        if (self.owner.sceneShown and elapsed>=HOLD_MIN_MS) or elapsed>=HOLD_MAX_MS then
            self.phase,self.started="out",now
        end
    else
        local alpha=math.max(0,1-elapsed/OUT_MS); self.root:SetAlpha(alpha)
        if alpha==0 then self:Finish() end
    end
end
