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
        self.sides[side]={target=0,emitted=0,landed=0,displayed=0,falling={},batches={},camera=0,
            frame={coins={}},pool={}}
    end
    return self
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
    local volleyEnd=firstFlight+C.volleyWindow
    local batch={events={},amount=amount,ends=self.time+C.duration,landed=0}
    for i=1,n do
        local q=n>1 and (i-1)/(n-1) or 1
        local arrival
        if q<=share then arrival=firstFlight+C.volleyWindow*(q/share)
        else arrival=volleyEnd+(C.duration-volleyEnd)*((q-share)/(1-share))^C.tailPower end
        if i==n then arrival=C.duration end
        local progress=(arrival-firstFlight)/(C.duration-firstFlight)
        local flight=firstFlight+(C.finalFlight-firstFlight)*progress
        batch.events[i]={index=s.target+amount*i/n,starts=self.time+arrival-flight,
            arrives=self.time+arrival,duration=flight,amount=amount/n}
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
                elseif coin.emitted and not coin.landed and #s.falling<C.maxFalling then
                    s.falling[#s.falling+1]=coin
                end
            end
            if self.time+1e-9>=batch.ends then table.remove(s.batches,b) end
        end
        if #s.batches==0 then s.landed=s.target; s.emitted=s.target end
        -- No trailing interpolation after the last arrival: complete exactly at the deadline.
        s.displayed=s.landed
        s.camera=math.max(0,C.tipY-topAt(math.floor(s.displayed)))
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
            local index=(math.max(1,math.ceil(coin.index))-1)%#pillars+1
            local p=pillars[index]
            if p.depth==depth then
                local t=math.min(1,math.max(0,(self.time-coin.starts)/coin.duration))
                local height=heightAt(count,index)
                local endY=frame.floorY+p.y-height*C.stackStep
                n=place(s,n+1,p.x,-C.height+(endY+C.height)*t*t,p,depth,index,true)
            end
        end
    end
    local coins=frame.coins; for i=#coins,n+1,-1 do coins[i]=nil end
    assert(n<=C.limit,"Coin viewport pool is too small")
    return frame
end
return V
