-- Each payment has its own three-second timeline; overlapping payments never restart it.
-- Monetary units are logical; representative sprites and visible stack rows remain bounded.
local V={}; V.__index=V; PBTrade.Coins=V
local C=PBTrade.Config.coins
local pillars={}
for depth,rank in ipairs(C.ranks) do
    for column=0,rank.count-1 do
        pillars[#pillars+1]={x=rank.x+column*C.pillarSpacing,y=rank.y,
            scale=rank.scale,shade=rank.shade,depth=depth}
    end
end
assert(#pillars==C.columns,"Coin rank count must match columns")
local function heightAt(count,index)
    return math.max(0,math.floor((count+#pillars-index)/#pillars))
end
local function topAt(count)
    local top=C.floorY
    for i,p in ipairs(pillars) do
        local height=heightAt(count,i)
        if height>0 then top=math.min(top,C.floorY+p.y-(height-1)*C.stackStep) end
    end
    return top
end
function V.New(value)
    local self=setmetatable({unit=math.max(C.minUnit,value/C.valueDivisor),time=0,sides={}},V)
    for side=1,2 do
        self.sides[side]={target=0,emitted=0,landed=0,displayed=0,landedVisual=0,falling={},resting={},batches={},camera=0,
            frame={coins={}},pool={}}
    end
    return self
end
-- Drawn stack size: true to the coin count until the view is full, then logarithmic, so a
-- colossal pile still scrolls a watchable distance. Exact totals are shown in the bid plaques.
function V.VisualCount(count)
    if count<=C.visualLinearUnits then return count end
    return math.min(C.visualMaxUnits,C.visualLinearUnits*(1+C.visualLogGain*math.log(count/C.visualLinearUnits)))
end
-- Small payments settle quickly; large ones take longer, on a log scale.
function V.DurationFor(amount)
    local share=math.log(1+math.max(0,amount))/math.log(1+C.durationFullUnits)
    return C.minDuration+(C.duration-C.minDuration)*math.min(1,share)
end
function V:SetBid(side,bid)
    if type(bid)~="number" or bid~=bid or bid==math.huge then return end
    local s=self.sides[side]
    local count=math.max(0,bid)/self.unit
    if count<=s.target then return end
    local amount=count-s.target
    local n=math.max(C.minimumSprites,math.min(C.burstSprites,math.ceil(amount)))
    local intensity=math.min(1,amount/C.burstSprites)
    -- Larger payments open with a bigger, faster volley; the rest thins out to the deadline.
    local share=C.volleyShareMin+(C.volleyShareMax-C.volleyShareMin)*intensity
    local firstFlight=C.slowFlight-(C.slowFlight-C.fastFlight)*intensity
    local duration=V.DurationFor(amount)
    -- Flights and the opening volley shrink with short showers so every coin still lands in time.
    local fit=math.min(1,duration/3)
    firstFlight=firstFlight*fit
    local window=C.volleyWindow*fit
    local finalFlight=math.max(firstFlight,C.finalFlight*fit)
    local volleyEnd=firstFlight+window
    local batch={events={},amount=amount,ends=self.time+duration,duration=duration,landed=0}
    -- Each sprite owns a slot on the drawn (compressed) stack: it falls onto exactly the coin
    -- position that the pile will show for it, so nothing lands on a column that never grows.
    local visualStart,visualEnd=V.VisualCount(s.target),V.VisualCount(count)
    for i=1,n do
        local q=n>1 and (i-1)/(n-1) or 1
        local arrival
        if q<=share then arrival=firstFlight+window*(q/share)
        else arrival=volleyEnd+(duration-volleyEnd)*((q-share)/(1-share))^C.tailPower end
        if i==n then arrival=duration end
        local progress=(arrival-firstFlight)/(duration-firstFlight)
        local flight=firstFlight+(finalFlight-firstFlight)*progress
        local slot=visualStart+(visualEnd-visualStart)*i/n
        local k=math.max(1,math.floor(slot+1e-9))
        batch.events[i]={index=s.target+amount*i/n,starts=self.time+arrival-flight,
            arrives=self.time+arrival,duration=flight,amount=amount/n,
            slot=slot,pillar=(k-1)%#pillars+1,level=math.floor((k-1)/#pillars),k=k}
    end
    s.target=count; s.batches[#s.batches+1]=batch
end
function V:Tick(dt)
    if type(dt)~="number" or dt~=dt or dt<=0 then return 0 end
    self.time=self.time+math.min(dt,.25)
    local impacts=0
    for _,s in ipairs(self.sides) do
        local falling=s.falling; for i=#falling,1,-1 do falling[i]=nil end
        for b=#s.batches,1,-1 do
            local batch=s.batches[b]
            for _,coin in ipairs(batch.events) do
                if not coin.emitted and self.time+1e-9>=coin.starts then
                    coin.emitted=true; s.emitted=s.emitted+coin.amount
                end
                if not coin.landed and self.time+1e-9>=coin.arrives then
                    coin.landed=true; s.landed=s.landed+coin.amount; impacts=impacts+1
                    if coin.slot>s.landedVisual then s.landedVisual=coin.slot end
                    -- Stays drawn where it landed until the growing pile covers its slot.
                    if coin.k>math.floor(s.displayed) then s.resting[#s.resting+1]=coin end
                elseif coin.emitted and not coin.landed and #s.falling<C.maxFalling then
                    s.falling[#s.falling+1]=coin
                end
            end
            if self.time+1e-9>=batch.ends then table.remove(s.batches,b) end
        end
        if #s.batches==0 then s.landed=s.target; s.emitted=s.target; s.landedVisual=V.VisualCount(s.target) end
        -- The drawn stack follows the landed total smoothly, so the plate slides down while the
        -- tip stays in view. Its scroll speed is capped; a pile far ahead of the view is skipped
        -- forward to keep at most scrollMaxLag pixels of catching up.
        local gap=s.landedVisual-s.displayed
        if gap>0 then
            local unitPx=C.stackStep/#pillars
            local maxLag=C.scrollMaxLag/unitPx
            if gap>maxLag then s.displayed=s.displayed+gap-maxLag; gap=maxLag end
            local dt=math.min(dt,.25)
            local step=math.max(gap*math.min(1,dt*C.scrollFollowRate),C.scrollMinSpeed/unitPx*dt)
            step=math.min(step,C.scrollMaxSpeed/unitPx*dt,gap)
            s.displayed=s.displayed+step
        elseif gap<0 then s.displayed=s.landedVisual end
        s.camera=math.max(0,C.tipY-topAt(math.floor(s.displayed)))
        -- Drop resting sprites the pile now draws itself (in place: no per-tick garbage).
        local resting,shown,kept=s.resting,math.floor(s.displayed),0
        for i=1,#resting do local coin=resting[i]; resting[i]=nil; if coin.k>shown then kept=kept+1; resting[kept]=coin end end
    end
    return impacts
end
-- Frames run at the UI rate with hundreds of visible coins. Reuse one frame
-- and one record pool per side: per-frame tables are garbage that pushed the
-- console add-on heap past its 100MB limit. The returned frame is only valid
-- until the next Frame call for the same side.
local function place(s,n,x,y,p,depth,index,falling)
    local coin=s.pool[n]
    if not coin then coin={}; s.pool[n]=coin end
    coin.x,coin.y,coin.scale,coin.shade=x,y,p.scale,p.shade
    coin.depth,coin.pillar,coin.falling=depth,index,falling
    s.frame.coins[n]=coin
    return n
end
function V:Frame(side)
    local s=self.sides[side]
    local count=math.floor(s.displayed)
    local frame=s.frame
    frame.floorY=C.floorY+s.camera; frame.camera=s.camera; frame.count=s.target; frame.landed=s.landed
    frame.tipY=topAt(count)+s.camera
    local n=0
    -- Painter order: finish every rear rank (including its falling coins) before the next rank.
    -- Only visible levels are constructed, independent of the total accumulated amount.
    for depth in ipairs(C.ranks) do
        for index,p in ipairs(pillars) do
            if p.depth==depth then
                local height=heightAt(count,index)
                local base=frame.floorY+p.y
                local first=math.max(0,math.ceil((base-C.viewportHeight)/C.stackStep))
                for level=first,height-1 do
                    local y=base-level*C.stackStep
                    if y>=-C.height and y<=C.viewportHeight then n=place(s,n+1,p.x,y,p,depth,index,nil) end
                end
            end
        end
        for _,coin in ipairs(s.falling) do
            local p=pillars[coin.pillar]
            if p.depth==depth and n<C.limit then
                local t=math.min(1,math.max(0,(self.time-coin.starts)/coin.duration))
                local endY=frame.floorY+p.y-coin.level*C.stackStep
                n=place(s,n+1,p.x,-C.height+(endY+C.height)*t*t,p,depth,coin.pillar,true)
            end
        end
        for _,coin in ipairs(s.resting) do
            local p=pillars[coin.pillar]
            if p.depth==depth and n<C.limit then
                local y=frame.floorY+p.y-coin.level*C.stackStep
                if y>=-C.height and y<=C.viewportHeight then n=place(s,n+1,p.x,y,p,depth,coin.pillar,nil) end
            end
        end
    end
    local coins=frame.coins; for i=#coins,n+1,-1 do coins[i]=nil end
    assert(n<=C.limit,"Coin viewport pool is too small")
    return frame
end
return V
