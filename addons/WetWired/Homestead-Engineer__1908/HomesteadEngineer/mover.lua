--[[
The mover module manages a coordinate cache for all objects placed by the 
addon.  The game stores all furniture at integer coordinate locations, but 
since we are performing rotational transforms, the desired coordinates are 
rarely integers.  While we have to live with the game's precision with regards 
to final placed location, we can cache the fractional part to smooth over 
successive movements and prevent "display glitches" due to quantization 
issues.

There are two issue with caching the fractional part of the coordinates.  The
first is that we have to deal with the game's movement controls, which are
essentially done outside of lua and thus untouchable as well as other addons
which may move furniture.  Truely, the fractional part is only valid if this
addon was the last to move the furniture.  The second issue is that the game
will continue to report the old location until our movement request hits the
server and a response is received. The solution to these issues used by this
addon is to keep a history of expected locations for each object, with 
timestamps.  As the item location moves to each expected location, or if the
validity period expires, the old history entries are removed.  When the item
position finally reaches the end of the history, the entire history is removed
to signal that the starting location should be placed in the history for the
next movement.  In this way, when the item follows the movements that we 
expect, we can report the last location that we set, with fractional part, in
the expectation that the item will eventually reach that location.  If 
something else moves the object, with high probability we will detect this
immediately.
]]--

HomesteadEngMover={};
local HE=HomesteadEng;
local Mover=HomesteadEngMover;
local TR=HomesteadEngTransform;

local HISTORY_VALID=1.0;

--Especially since the game stores angles internally with lower precsision, a 
-- simple equality check will not work. In the case of angles, we know that 
-- the values should always be in the range -pi<=angle<=pi, so we can use a 
-- fixed accuracy cutoff to do the comparison. This assumption is not valid 
-- for most floating point numbers. The limit used is based on observed 
-- retention of precision in game.
local ANGLE_ACCURACY=1/(2^11);
local function EqAng(a,b)
  return math.abs(a-b)<ANGLE_ACCURACY;
end

local function ComparePos(x1,y1,z1,x2,y2,z2)
  return x1==x2 and y1==y2 and z1==z2;
end

local function CompareAng(p1,w1,r1,p2,w2,r2)
  return EqAng(p1,p2) and EqAng(w1,w2) and EqAng(r1,r2);
end

local function CheckHistory(myCache,frameIdx,a,b,c,CompareFunc)
  local curLoc;
  if Mover.locked then
    return false;
  end
  if myCache.history then
    --Process the history to determine our progress and ultimately determine if we should use the cached value
    for i=1,#myCache.history-1 do
      --History entries older than HISTORY_VALID should be discarded
      if (frameIdx-myCache.history[i][1])<=HISTORY_VALID then
        if CompareFunc(myCache.history[i][2],myCache.history[i][3],myCache.history[i][4],a,b,c) then
          --We found the first history item matching the reported position.
          curLoc=i;
          break;
        end
      end
    end
    --Remove all entries before our current location
    if curLoc then
      for i=1,curLoc-1 do
        table.remove(myCache.history,1);
      end
    else
      myCache.history=nil;
    end
  end
  return curLoc~=nil;
end

function Mover.GetItemPos(furnId)
  local furnKey=zo_getSafeId64Key(furnId);
  local x,y,z=HousingEditorGetFurnitureWorldPosition(furnId);
  if Mover.itemCache[furnKey] then
    local myCache=Mover.itemCache[furnKey];
    local frameIdx=GetFrameTimeSeconds();
    if CheckHistory(myCache,frameIdx,x,y,z,ComparePos) or (myCache.last[2]==x and myCache.last[3]==y and myCache.last[4]==z) then
      x=myCache.use.x;
      y=myCache.use.y;
      z=myCache.use.z;
    elseif not Mover.locked then
      --d("no match "..string.format("%.3f",myCache.last[1])..","..tostring(myCache.last[2])..","..tostring(myCache.last[3])..","..tostring(myCache.last[4]).." "..string.format("%.3f",frameIdx)..","..tostring(x)..","..tostring(y)..","..tostring(z));
      Mover.itemCache[furnKey]=nil;
    end
  end
  return x,y,z,HousingEditorGetFurnitureOrientation(furnId);
end

function Mover.SetItemPos(furnId,x,y,z,p,w,r)
  --Don't do this if in placement mode
  if Mover.locked then
    return;
  end
  local furnKey=zo_getSafeId64Key(furnId);
  local frameIdx=GetFrameTimeSeconds();
  Mover.itemCache[furnKey]=Mover.itemCache[furnKey] or {};
  local myCache=Mover.itemCache[furnKey];
  --d("p"..string.format("%.3f",frameIdx).." "..string.format("%.3f",x)..","..string.format("%.3f",y)..","..string.format("%.3f",z));
  --We know that coordinates will be truncated to ints, so round to closest and store for later comparison
  local reqpos={frameIdx,math.floor(x+.5),math.floor(y+.5),math.floor(z+.5)};
  local curpos={frameIdx,HousingEditorGetFurnitureWorldPosition(furnId)};
  --If we're not currently tracking a history of movements, or our history is used up, start the history with the current position
  CheckHistory(myCache,curpos[1],curpos[2],curpos[3],curpos[4],ComparePos);
  if not myCache.history then
    myCache.history={};
    table.insert(myCache.history,curpos);
  end
  --Add the requested position to the history of movements
  table.insert(myCache.history,reqpos);
  --Then store the last requested position and the high resolution coordinates to use
  myCache.last=reqpos;
  myCache.use={x=x,y=y,z=z};
  HousingEditorRequestChangePositionAndOrientation(furnId,reqpos[2],reqpos[3],reqpos[4],p,w,r);
end

function Mover.GetItemPosLoc(furnId)
  local x,y,z,p,w,r=Mover.GetItemPos(furnId);
  local xl,yl,zl,pl,wl,rl=TR.TransformToCoord(TR.FwdTransform(TR.CoordToTransform(x,y,z,p,w,r),HE.locTr));
  local furnKey=zo_getSafeId64Key(furnId);
  if Mover.locRotCache[furnKey] then
    local myCache=Mover.locRotCache[furnKey];
    local frameIdx=GetFrameTimeSeconds();
    if CheckHistory(myCache,frameIdx,p,w,r,CompareAng) or CompareAng(myCache.last[2],myCache.last[3],myCache.last[4],p,w,r) then
      pl=myCache.use.p;
      wl=myCache.use.w;
      rl=myCache.use.r;
    else
      --d("no match "..string.format("%.3f",myCache.last[1])..","..tostring(myCache.last[2])..","..tostring(myCache.last[3])..","..tostring(myCache.last[4]).." "..string.format("%.3f",frameIdx)..","..tostring(p)..","..tostring(w)..","..tostring(r));
      Mover.itemCache[furnKey]=nil;
    end
  end
  return xl,yl,zl,pl,wl,rl;
end

function Mover.SetItemPosLoc(furnId,xl,yl,zl,pl,wl,rl)
  if Mover.locked then
    return;
  end
  --Constrain rotations to +/- 180 degrees
  pl=(pl+math.pi)%(2*math.pi)-math.pi;
  wl=(wl+math.pi)%(2*math.pi)-math.pi;
  rl=(rl+math.pi)%(2*math.pi)-math.pi;
  --Do the transformation
  local x,y,z,p,w,r=TR.TransformToCoord(TR.RevTransform(TR.CoordToTransform(xl,yl,zl,pl,wl,rl),HE.locTr));
  --Cache the (constrained) original angle and result
  local furnKey=zo_getSafeId64Key(furnId);
  local frameIdx=GetFrameTimeSeconds();
  Mover.locRotCache[furnKey]=Mover.locRotCache[furnKey] or {};
  local myCache=Mover.locRotCache[furnKey];
  local reqrot={frameIdx,p,w,r};
  local currot={frameIdx,HousingEditorGetFurnitureOrientation(furnId)};
  --If we're not currently tracking a history of rotations, or our history is used up, start the history with the current rotation
  CheckHistory(myCache,currot[1],currot[2],currot[3],currot[4],CompareAng);
  if not myCache.history then
    myCache.history={};
    table.insert(myCache.history,currot);
  end
  --Add the requested position to the history of rotations
  table.insert(myCache.history,reqrot);
  --Then store the last requested position and the high resolution coordinates to use
  myCache.last=reqrot;
  myCache.use={p=pl,w=wl,r=rl};
  Mover.SetItemPos(furnId,x,y,z,p,w,r);
end

function Mover.MoveItemRel(furnId,x,y,z)
  Mover.SetItemPos(furnId,TR.TransformToCoord(TR.RevTransform(TR.CoordToTransform(x,y,z,0,0,0),TR.CoordToTransform(Mover.GetItemPos(furnId)))));
end

function Mover.RotItemRel(furnId,p,w,r)
  Mover.SetItemPos(furnId,TR.TransformToCoord(TR.RevTransform(TR.CoordToTransform(0,0,0,p,w,r),TR.CoordToTransform(Mover.GetItemPos(furnId)))));
end

function Mover.Init()
  Mover.itemCache={};
  Mover.locRotCache={};
  Mover.locked=false;
end

function Mover.OnZone()
  Mover.itemCache={};
  Mover.locRotCache={};
end

function Mover.SetLock(locked)
  Mover.locked=locked;
end

function Mover.OnLocalChanged()
  Mover.locRotCache={};
end

function Mover.OnFurnRemoved(furnId)
  local furnKey=zo_getSafeId64Key(furnId);
  Mover.itemCache[furnKey]=nil;
  Mover.locRotCache[furnKey]=nil;
end
