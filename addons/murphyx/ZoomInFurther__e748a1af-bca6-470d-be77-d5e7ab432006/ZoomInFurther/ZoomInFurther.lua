local e="ZoomInFurther"
local a=1.5
local i=2
ZO_WorldMap_GetPanAndZoom().SetMapZoomMinMax=function(t,o,e)
if(GetMapType()==2 and GetMapContentType()==0)and GetCurrentMapIndex()~=1 then
if e>1.1 and e<4.9 then e=e*a end
end
t.mapMin=o
t.mapMax=e
t:RefreshZoom()
end
ZO_WorldMap_GetPanAndZoom().AddZoomDeltaGamepad=function(e,o,s)
local n=2
local a=2
if(GetMapType()==2 and GetMapContentType()==0)then a=a*i end
local i=e.targetNormalizedZoom or e.currentNormalizedZoom
local t=e.maxZoom-e.minZoom
local a=o*zo_max(a,t/n)
local t=t>0 and(a/t)or 0
local t=zo_clamp(i+s*t,0,1)
e:SetLockedNormalizedZoom(t,ZO_WorldMapScroll:GetCenter())
if o>0 and e.canZoomInFurther then
PlaySound(SOUNDS.MAP_ZOOM_IN)
elseif o<0 and e.canZoomOutFurther then
PlaySound(SOUNDS.MAP_ZOOM_OUT)
end
end
