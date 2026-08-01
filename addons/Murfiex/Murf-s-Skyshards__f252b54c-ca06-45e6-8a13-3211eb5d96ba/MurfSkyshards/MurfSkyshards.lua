local o="MurfSkyshards"
local i={
[42]={.8464,.5951,226},
[65]={.3318,.512,194},
[71]={.6842,.4502,258},
[72]={.2455,.9519,22},
[76]={.4692,.5798,242},
[90]={.4384,.2723,16},
[97]={.6713,.6663,19},
[110]={.4197,.7056,20},
[111]={.2566,.2132,189},
[112]={.7284,.5867,17},
[113]={.5815,.2622,21},
[114]={.5608,.349,18},
[115]={.5962,.3032,32},
[119]={.5273,.7021,34},
[120]={.5081,.3638,36},
[121]={.5124,.1856,35},
[122]={.3886,.3671,37},
[123]={.5007,.6418,33},
[124]={.5762,.8085,38},
[140]={.505,.5248,70},
[142]={.6297,.3989,86},
[144]={.6438,.6057,54},
[146]={.3604,.7318,48},
[147]={.7382,.5207,52},
[148]={.8151,.7592,50},
[149]={.8597,.6897,53},
[150]={.7728,.3154,51},
[155]={.3518,.3464,49},
[163]={.3382,.8858,65},
[164]={.1301,.3751,67},
[165]={.3142,.7308,68},
[166]={.5405,.7193,66},
[167]={.5427,.1332,64},
[168]={.3226,.3171,69},
[169]={.1048,.6387,80},
[175]={.8244,.465,156},
[178]={.316,.2189,103},
[179]={.8345,.6232,106},
[180]={.87,.7008,102},
[181]={.2766,.5446,107},
[182]={.6939,.2555,105},
[186]={.8191,.7919,104},
[189]={.253,.7282,210},
[194]={.3512,.5351,207},
[199]={.3793,.8758,150},
[200]={.1785,.3476,224},
[202]={.3974,.1257,206},
[203]={.4063,.861,191},
[204]={.5263,.8785,221},
[206]={.312,.8986,154},
[210]={.3272,.4005,170},
[211]={.7722,.6104,84},
[212]={.6778,.3381,252},
[214]={.3942,.4177,82},
[215]={.4018,.116,192},
[216]={.6109,.3536,222},
[219]={.7522,.3176,208},
[220]={.3343,.7746,225},
[221]={.5402,.168,155},
[222]={.1913,.1347,151},
[223]={.1785,.4791,204},
[224]={.9026,.262,237},
[225]={.5227,.4444,220},
[226]={.4072,.5333,238},
[228]={.4518,.6799,190},
[229]={.183,.2348,254},
[230]={.8541,.3466,239},
[231]={.1463,.4368,236},
[232]={.5339,.8296,253},
[233]={.6942,.3297,241},
[235]={.7412,.2631,193},
[236]={.118,.3344,257},
[237]={.8403,.3123,188},
[238]={.7102,.4442,209},
[239]={.656,.333,256},
[244]={.5783,.5022,223},
[245]={.6543,.8592,255},
[246]={.9168,.709,240},
[249]={.7587,.0768,205},
[254]={.5327,.4508,83},
[261]={.2824,.267,271},
[262]={.4397,.1276,152},
[263]={.7675,.7018,274},
[265]={.7932,.7629,85},
[266]={.2696,.4307,269},
[267]={.571,.4029,153},
[268]={.6351,.6691,108},
[278]={.6806,.4154,140},
[283]={.2888,.6597,124},
[285]={.488,.241,316},
[286]={.5566,.1851,317},
[287]={.177,.6987,287},
[288]={.7688,.4406,305},
[289]={.7605,.2898,303},
[290]={.7332,.1969,302},
[291]={.6044,.4546,319},
[293]={.492,.5438,304},
[294]={.4033,.6413,304},
[299]={.1405,.7795,290},
[301]={.1136,.3918,169},
[304]={.1514,.2626,171},
[307]={.3757,.8311,168},
[317]={.1971,.4093,172},
[318]={.6388,.3314,172},
[322]={.3663,.4111,272},
[323]={.7771,.6637,167},
[339]={.327,.5004,275},
[343]={.7437,.4328,166},
[352]={.5264,.1488,270},
[380]={.5435,.5634,139},
[382]={.6141,.5714,134},
[383]={.7367,.7476,138},
[384]={.4655,.2385,137},
[386]={.5408,.4913,135},
[391]={.2673,.7327,136},
[393]={.738,.7472,121},
[394]={.6197,.463,119},
[395]={.3954,.4768,123},
[396]={.781,.4428,120},
[404]={.5751,.5764,118},
[414]={.1858,.7067,122},
[466]={.2573,.6352,320},
[467]={.1951,.7242,318},
[468]={.3793,.3242,288},
[469]={.1545,.4846,315},
[470]={.6935,.1332,300},
[471]={.3956,.5484,289},
[473]={.4199,.2262,301},
[474]={.3561,.3701,285},
[593]={.5614,.7433,273},
[703]={.8709,.6441,81},
[937]={.2647,.3886,363},
[941]={.9003,.708,368},
[945]={.1145,.1164,367},
[956]={.3292,.8275,365},
[957]={.2862,.4657,366},
[958]={.1852,.8434,364},
[968]={.7659,.6609,369},
[983]={.6223,.7182,362},
[990]={.8244,.465,156},
[1003]={.2566,.5258,374},
[1005]={.7769,.6646,381},
[1007]={.6773,.4567,380},
[1025]={.6617,.3862,375},
[1026]={.2566,.5258,374},
[1027]={.2566,.5258,374},
[1028]={.2566,.5258,374},
[1030]={.6617,.3862,375},
[1076]={.4624,.2896,331},
[1077]={.8883,.626,329},
[1078]={.711,.1723,332},
[1079]={.662,.0792,332},
[1080]={.8296,.4468,332},
[1081]={.3302,.6669,333},
[1089]={.4629,.381,325},
[1090]={.7233,.376,323},
[1093]={.6918,.1513,328},
[1094]={.6425,.5748,330},
[1096]={.1694,.7032,330},
[1099]={.7474,.3515,322},
[1100]={.6556,.2336,326},
[1101]={.8631,.2242,327},
[1102]={.6123,.455,324},
[1106]={.5288,.5355,337},
[1109]={.3753,.1598,335},
[1110]={.5708,.5097,338},
[1112]={.1243,.2342,335},
[1115]={.6386,.5055,334},
[1116]={.4026,.4251,336},
[1117]={.6262,.5575,339},
[1157]={.6086,.4615,394},
[1159]={.7783,.2555,396},
[1160]={.532,.7325,397},
[1161]={.4805,.3658,398},
[1274]={.336,.9315,395},
[1275]={.336,.9315,395},
[1276]={.3466,.8223,393},
[1277]={.3983,.4421,393},
[1283]={.6072,.582,399},
[1300]={.4805,.3658,398},
[1315]={.309,.5953,392},
[1316]={.04,.412,392},
[1324]={.8356,.5699,405},
[1332]={.369,.5644,404},
[1335]={.849,.7177,402},
[1348]={.3468,.5541,403},
[1362]={.849,.7177,402},
[1367]={.1985,.3829,418},
[1369]={.3028,.5224,422},
[1370]={.5428,.705,420},
[1371]={.369,.5644,404},
[1372]={.1481,.5968,419},
[1374]={.5514,.5017,423},
[1377]={.4689,.7125,421},
[1378]={.4689,.7125,421},
[1397]={.5994,.5957,416},
[1438]={.374,.3464,417},
[1469]={.3842,.4511,422},
[1471]={.582,.4803,423},
[1473]={.5834,.4777,423},
[1474]={.5817,.4792,423},
[1475]={.582,.4787,423},
[1506]={.2663,.8301,428},
[1507]={.6529,.5523,429},
[1590]={.1207,.3595,447},
[1595]={.7508,.7886,444},
[1608]={.5609,.4962,445},
[1616]={.6316,.274,443},
[1626]={.1023,.614,446},
[1636]={.3856,.5867,440},
[1637]={.3819,.5865,440},
[1638]={.5786,.5864,440},
[1639]={.8151,.4518,441},
[1662]={.3798,.8459,442},
[1673]={.3798,.8459,442},
[1676]={.7604,.2281,452},
[1694]={.3976,.385,453},
[1739]={.7564,.2265,452},
[1740]={.7564,.2265,452},
[1741]={.7409,.3166,452},
[1742]={.7604,.2281,452},
[1749]={.7043,.4025,469},
[1750]={.3565,.5838,468},
[1751]={.6829,.6029,465},
[1752]={.4525,.6161,470},
[1755]={.7261,.5049,471},
[1756]={.8644,.5517,466},
[1774]={.5639,.4736,464},
[1775]={.0282,.0149,464},
[1815]={.4522,.6155,470},
[1816]={.4522,.6155,470},
[1869]={.6463,.407,477},
[1870]={.3415,.622,476},
[1892]={.6463,.407,477},
[1893]={.6463,.407,477},
[1894]={.6463,.407,477},
[1895]={.6463,.407,477},
[1896]={.6463,.407,477},
[1897]={.6463,.407,477},
[1898]={.6463,.407,477},
[1930]={.538,.2967,494},
[1935]={.5245,.4037,491},
[1939]={.8576,.4461,493},
[1943]={.3056,.3513,488},
[1945]={.6832,.5147,490},
[1946]={.9128,.8341,490},
[1977]={.8567,.2126,495},
[1985]={.7399,.6228,489},
[1986]={.7845,.6238,489},
[1987]={.7799,.6229,489},
[1988]={.7822,.6242,489},
[1989]={.7774,.6222,489},
[2022]={.355,1.,489},
[2030]={.8576,.4461,493},
[2031]={.8576,.4461,493},
[2032]={.8576,.4461,493},
[2055]={.4527,.7349,488},
[2060]={.8785,.3493,492},
[2062]={.8567,.2126,495},
[2077]={.4527,.7349,488},
[2082]={.4894,.5019,499},
[2089]={.7566,.5511,501},
[2106]={.2633,.2483,500},
[2119]={.602,.3469,499},
[2130]={.5171,.1951,516},
[2131]={.348,.6626,519},
[2133]={.4859,.9266,517},
[2138]={.473,.5893,521},
[2154]={.3309,.3718,520},
[2156]={.3728,.6058,518},
[2171]={.7739,.5127,515},
[2199]={.5639,.5824,514},
[2225]={.3769,.1942,527},
[2265]={.4574,.752,526},
[2292]={.5407,.5127,544},
[2302]={.4046,.3327,539},
[2305]={.2862,.5336,540},
[2317]={.4518,.2968,541},
[2334]={.5643,.6558,542},
[2349]={.4811,.4713,545},
[2350]={.3528,.6204,538},
[2355]={.4244,.1213,543},
[2389]={.4244,.1213,543},
[2432]={.3337,.427,559},
[2433]={.4561,.2839,558},
[2439]={.4381,.3005,560},
[2441]={.559,.3148,556},
[2442]={.5084,.4036,563},
[2453]={.5111,.7589,562},
[2456]={.384,.2867,557},
[2459]={.4995,.6543,561},
[2632]={.7029,.7783,571},
[2633]={.3694,.792,579},
[2634]={.4651,.6036,570},
[2642]={.8662,.4647,572},
[2644]={.4015,.524,569},
[2684]={.7971,.4936,587},
[2699]={.2028,.4768,580},
[2728]={.3676,.5107,578},
[2784]={.2028,.4768,580},
[2785]={.2028,.4768,580},
[2799]={.2028,.4768,580},
[2800]={.2028,.4768,580},
[2801]={.2028,.4768,580},
[2802]={.2028,.4768,580},
[2806]={.2028,.4768,580},
[2807]={.2028,.4768,580},
}
local e={
[99]={.368,.786,194},
[317]={.4,.42,172},
[979]={.518,.465,362},
[982]={.805,.665,362},
[938]={.94,.49,363},
[993]={.577,.418,370},
[1003]={.677,.589,374},
[1030]={.593,.19,375},
[1314]={.816,.417,392},
[1310]={.77,.331,392},
[1312]={.9,.444,392},
[1317]={.245,.207,392},
[1276]={.625,.636,393},
[1278]={.34,.086,393},
[1279]={.224,.114,393},
[1162]={.179,.433,399},
[1159]={.619,.462,396},
[1158]={.321,.384,395},
[1348]={.151,.422,403},
[1313]={.411,.461,402},
[1366]={.46,.591,418},
[1507]={.569,.664,429},
[1508]={.392,.652,429},
[1636]={.309,.692,440},
[1637]={.453,.575,440},
[1775]={.537,.274,464},
[1770]={.542,.747,467},
[1752]={.521,.378,470},
[1750]={.522,.562,468},
[1756]={.878,.46,466},
[1755]={.735,.344,471},
[1850]={.427,.331,474},
[1870]={.245,.585,476},
[1872]={.465,.846,476},
[1892]={.617,.555,477},
[1896]={.617,.555,477},
[1959]={.883,.47,488},
[1990]={.174,.211,489},
[2057]={.248,.374,492},
[1945]={.496,.347,490},
[1946]={.768,.694,490},
[2089]={.655,.308,501},
[2106]={.147,.234,500},
[2131]={.301,.584,519},
[2138]={.446,.525,521},
[2153]={.527,.285,520},
[2171]={.81,.48,515},
[2200]={.906,.569,515},
[2211]={.638,.45,514},
[2199]={.478,.665,514},
[2265]={.49,.684,526},
[2266]={.409,.375,527},
[2225]={.563,.284,527},
[2267]={.279,.298,527},
[2302]={.225,.418,539},
[2292]={.259,.516,544},
[2334]={.709,.462,542},
[2317]={.649,.546,541},
[2349]={.482,.265,545},
[2355]={.497,.341,543},
[2389]={.497,.341,543},
[2350]={.864,.625,538},
[2351]={.241,.121,538},
[2459]={.571,.57,561},
[2433]={.309,.192,558},
[2441]={.422,.273,556},
[2456]={.413,.207,557},
[2453]={.291,.653,562},
[2432]={.263,.237,559},
[2439]={.331,.302,560},
[2442]={.334,.478,563},
[2595]={.699,.661,563},
[2632]={.562,.769,571},
[2642]={.583,.169,572},
[2634]={.454,.611,570},
[2722]={.632,.9,569},
[2644]={.34,.684,569},
[2728]={.514,.634,578},
[2633]={.254,.457,579},
}
local m={
[3]={[41]=380},
[19]={[21]=714},
[20]={[16]=713},
[104]={[28]=707},
[92]={[16]=708},
[381]={[40]=468},
[383]={[2]=470},
[108]={[1]=445},
[58]={[37]=460},
[382]={[23]=469},
[41]={[18]=379},
[57]={[20]=388},
[117]={[40]=372},
[103]={[31]=371},
[101]={[37]=381},
[347]={[40]=874},
[684]={[2]=1238,
[29]=1235},
[849]={[34]=1846,
[35]=1855},
[1011]={[25]=2095,
[26]=2096},
[1086]={[13]=2444,
[14]=2445},
[1160]={[12]=2714},
[1161]={[17]=2715},
[1261]={[19]=2995,
[32]=2994},
[1318]={[12]=3281,
[11]=3283},
[1413]={[11]=3657},
[1414]={[16]=3658},
[1443]={[13]=4000,
[14]=4002},
[1502]={[13]=4264,
[28]=4471},
}
local t={
[65]={.18,.4,380},
[189]={.366,.167,714},
[42]={.378,.117,713},
[76]={.337,.626,707},
[71]={.873,.519,708},
[268]={.477,.627,468},
[283]={.673,.171,470},
[278]={.83,.66,445},
[175]={.6,.76,460},
[990]={.6,.76,460},
[317]={.475,.9,469},
[72]={.69,.53,379},
[115]={.588,.883,388},
[144]={.2,.235,372},
[140]={.76,.5,381},
[142]={.11,.87,371},
[339]={.37,.24,874},
[984]={.17,.65,1238},
[939]={.52,.47,1235},
[1317]={.5,.59,1846},
[1276]={.22,.55,1855},
[1438]={.42,.157,2095},
[1397]={.905,.733,2096},
[1639]={.491,.662,2444},
[1636]={.785,.284,2445},
[1637]={.785,.284,2445},
[1775]={.14,.515,2714},
[1751]={.776,.512,2715},
[1990]={.613,.519,2995},
[1959]={.619,.281,2994},
[2200]={.524,.65,3283},
[2211]={.765,.505,3281},
[2302]={.58,.422,3658},
[2350]={.596,.348,3657},
[2441]={.807,.452,4002},
[2456]={.272,.626,4000},
[2644]={.594,.285,4264},
[2728]={.556,.576,4471},
}
local a={
[99]={.368,.786,380},
[979]={.518,.465,1238},
[980]={.315,.047,1238},
[982]={.19,.175,1238},
[938]={.94,.49,1235},
[937]={.577,.424,1235},
[1310]={.77,.331,1846},
[1312]={.9,.444,1846},
[1314]={.706,.676,1846},
[1315]={.07,.56,1846},
[1278]={.331,.669,1855},
[1277]={.19,.679,1855},
[1279]={.224,.114,1855},
[1638]={.773,.335,2445},
[1774]={.236,.652,2714},
[1943]={.329,.619,2994},
[1958]={.789,.293,2994},
[2055]={.375,.473,2994},
[1985]={.603,.715,2995},
[1988]={.603,.715,2995},
[1989]={.603,.715,2995},
[2171]={.367,.459,3283},
[2211]={.629,.248,3281},
[2353]={.514,.445,3657},
[2350]={.498,.352,3657},
[2352]={.628,.364,3657},
[2441]={.654,.452,4002},
[2722]={.744,.066,4264},
}
local function g()
local t="esoui/art/mappins/skyshard_seen.dds"
local a="esoui/art/mappins/skyshard_complete.dds"
local c=ZO_ColorDef:New(.55,.95,.95,1)
local u=ZO_ColorDef:New(.75,.9,.9,1)
local o="MURFSKYSHARDS_PIN_TYPE_SKYSHARD_UNDISCOVERED"
local l="MURFSKYSHARDS_PIN_TYPE_SKYSHARD_ACQUIRED"
local s="MURFSKYSHARDS_PIN_TYPE_SKYSHARDPOI_UNDISCOVERED"
local n="MURFSKYSHARDS_PIN_TYPE_SKYSHARDPOI_ACQUIRED"
local h="MURFSKYSHARDS_PIN_TYPE_SKYSHARDHINT_UNDISCOVERED"
local r="MURFSKYSHARDS_PIN_TYPE_SKYSHARDHINT_ACQUIRED"
local b={level=47,size=40,texture=t}
local p={level=47,size=40,texture=a}
local j={level=47,size=40,texture=t,tint=c}
local q={level=47,size=40,texture=a,tint=u}
local y={level=47,size=25,texture=t}
local w={level=47,size=25,texture=a}
local t=function()end
local c={creator=function(e)end}
local u={
creator=function(e)
local e,a=e:GetPinTypeAndTag()
local e=ZO_MapLocationTooltip_Gamepad
local t=GetString(SI_MURF_SKYSHARD)
if a[4]==ZONE_COMPLETION_TYPE_DELVES or a[4]==ZONE_COMPLETION_TYPE_GROUP_DELVES then
t=t.." ("..GetString(SI_ZONEDISPLAYTYPE7)..")"
elseif a[4]==ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS then
t=t.." ("..GetString(SI_ZONEDISPLAYTYPE6)..")"
end
e:LayoutIconStringLine(e.tooltip,nil,t,e.tooltip:GetStyle("mapTitle"))
e:LayoutIconStringLine(e.tooltip,nil,GetSkyshardHint(a[3])
,e.tooltip:GetStyle("skyshardHint"))
end,
tooltip=ZO_MAP_TOOLTIP_MODE.INFORMATION,
gamepadSpacing=true,
}
local function f(t)
local e=GetCurrentMapZoneIndex()
local a=GetZoneId(e)
local e=GetNumSkyshardsInZone(a)
for e=1,e do
local e=GetZoneSkyshardId(a,e)
local i,n,a=GetNormalizedPositionForSkyshardId(e)
local s=GetSkyshardDiscoveryStatus(e)
if e==403 and GetCurrentMapId()==1313 then a=true
elseif e==467 and GetCurrentMapId()==1770 then a=true end
if a and s~=SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
local e={i,n,e}
t:CreatePin(_G[o],e,i,n)
end
end
if a==1208 then
for a,e in pairs({474,475})do
local i,a,s=GetNormalizedPositionForSkyshardId(e)
local n=GetSkyshardDiscoveryStatus(e)
if s and n~=SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
local e={i,a,e}
t:CreatePin(_G[o],e,i,a)
end
end
end
local e=GetCurrentMapId()
if i[e]and GetSkyshardDiscoveryStatus(i[e][3])~=SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
t:CreatePin(_G[o],i[e],i[e][1],i[e][2])
end
end
local function m(t)
if not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_ACQUIRED_SKYSHARDS)then return end
local e={[1313]=403,
[1770]=467}
local e=e[GetCurrentMapId()]
if e then
local a,o,i=GetNormalizedPositionForSkyshardId(e)
local i=GetSkyshardDiscoveryStatus(e)
if i==SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
t:CreatePin(_G[l],"PinTagSkyshardAcquired"..e,a,o)
end
end
end
local function k(o)
local e=GetCurrentMapZoneIndex()
local h=GetZoneId(e)
for a=1,GetNumPOIs(e)do
local t=GetPOIZoneCompletionType(e,a)
if t==ZONE_COMPLETION_TYPE_DELVES or t==ZONE_COMPLETION_TYPE_GROUP_DELVES or t==ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS then
local i=GetPOISkyshardId(e,a)
local n=GetSkyshardDiscoveryStatus(i)
if n~=SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
local e,a,n,n,n,n,n,n=GetPOIMapInfo(e,a)
local t={e,a,i,t}
o:CreatePin(_G[s],t,e,a)
end
elseif h==1208 and a==6 then
local i=GetSkyshardDiscoveryStatus(477)
if i~=SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
local a,e,i,i,i,i,i,i=GetPOIMapInfo(e,a)
local t={a,e,477,t}
o:CreatePin(_G[s],t,a,e)
end
end
end
end
local function i(o)
if not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_ACQUIRED_SKYSHARDS)then return end
local e=GetCurrentMapZoneIndex()
local s=GetZoneId(e)
for t=1,GetNumPOIs(e)do
local a=GetPOIZoneCompletionType(e,t)
if a==ZONE_COMPLETION_TYPE_DELVES or a==ZONE_COMPLETION_TYPE_GROUP_DELVES or a==ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS then
local a=GetPOISkyshardId(e,t)
local i=GetSkyshardDiscoveryStatus(a)
if i==SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
local t,e,i,i,i,i,i,i=GetPOIMapInfo(e,t)
local a={t,e,a}
o:CreatePin(_G[n],a,t,e)
end
elseif s==1208 and t==6 then
local a=GetSkyshardDiscoveryStatus(477)
if a==SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
local e,t,a,a,a,a,a,a=GetPOIMapInfo(e,t)
local a={e,t,477}
o:CreatePin(_G[n],a,e,t)
end
end
end
end
local a={
creator=function(e)
local e,t=e:GetPinTypeAndTag()
local e=ZO_MapLocationTooltip_Gamepad
e:LayoutIconStringLine(e.tooltip,nil,GetString(SI_MURF_WAYPOINT),e.tooltip:GetStyle("mapTitle"))
e:LayoutIconStringLine(e.tooltip,nil,GetSkyshardHint(t[3])
,e.tooltip:GetStyle("skyshardHint"))
end,
tooltip=ZO_MAP_TOOLTIP_MODE.INFORMATION,
gamepadSpacing=true,
}
local function v(a)
local t=GetCurrentMapId()
if e[t]and GetSkyshardDiscoveryStatus(e[t][3])~=SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
a:CreatePin(_G[h],e[t],e[t][1],e[t][2])
end
end
local function g(a)
if not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_ACQUIRED_SKYSHARDS)then return end
local t=GetCurrentMapId()
if e[t]and GetSkyshardDiscoveryStatus(e[t][3])==SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
a:CreatePin(_G[r],e[t],e[t][1],e[t][2])
end
end
local e=ZO_WorldMap_GetPinManager()
e:AddCustomPin(o,f,t,b,u)
e:SetCustomPinEnabled(_G[o],true)
e:AddCustomPin(l,m,t,p,c)
e:SetCustomPinEnabled(_G[l],true)
e:AddCustomPin(s,k,t,j,u)
e:SetCustomPinEnabled(_G[s],true)
e:AddCustomPin(n,i,t,q,c)
e:SetCustomPinEnabled(_G[n],true)
e:AddCustomPin(h,v,t,y,a)
e:SetCustomPinEnabled(_G[h],true)
e:AddCustomPin(r,g,t,w,a)
e:SetCustomPinEnabled(_G[r],true)
end
local e=0
local function r()
local t=GetGameTimeMilliseconds()
if t-e<1000 then return end
e=t
local e=ZO_WorldMap_GetPinManager()
e:RefreshCustomPins(_G[pinTypeSkyshardUndiscovered])
e:RefreshCustomPins(_G[pinTypeSkyshardAcquired])
e:RefreshCustomPins(_G[pinTypeSkyshardHintUndiscovered])
e:RefreshCustomPins(_G[pinTypeSkyshardHintAcquired])
end
local function l()
local e=ZO_WorldMap_GetPinManager()
e:RefreshCustomPins(_G[pinTypeSkyshardPOIUndiscovered])
e:RefreshCustomPins(_G[pinTypeSkyshardPOIAcquired])
end
local function y()
local n="/esoui/art/icons/poi/poi_groupboss_incomplete.dds"
local r="/esoui/art/icons/poi/poi_groupboss_complete.dds"
local e=ZO_ColorDef:New(1,.4,.4,1)
local h="MURFSKYSHARDS_PIN_TYPE_GROUPEVENT_INCOMPLETE"
local s="MURFSKYSHARDS_PIN_TYPE_GROUPEVENT_COMPLETE"
local i="MURFSKYSHARDS_PIN_TYPE_GROUPEVENTHINT_INCOMPLETE"
local o="MURFSKYSHARDS_PIN_TYPE_GROUPEVENTHINT_COMPLETE"
local c={level=48,size=30,texture=n,tint=e}
local f={level=48,size=30,texture=r,tint=e}
local w={level=48,size=15,texture=n,tint=e}
local u={level=48,size=15,texture=r,tint=e}
local n=function()end
local e={creator=function(e)end}
local l={
creator=function(e)
local e,t=e:GetPinTypeAndTag()
local e=ZO_MapLocationTooltip_Gamepad
local a,t=GetAchievementInfo(t[3])
e:LayoutIconStringLine(e.tooltip,nil,a,e.tooltip:GetStyle("mapTitle"))
e:LayoutIconStringLine(e.tooltip,nil,t,e.tooltip:GetStyle("achievementName"))
end,
tooltip=ZO_MAP_TOOLTIP_MODE.INFORMATION,
gamepadSpacing=true,
}
local r={
creator=function(e)
local e,t=e:GetPinTypeAndTag()
local e=ZO_MapLocationTooltip_Gamepad
local t,a=GetAchievementInfo(t[3])
e:LayoutIconStringLine(e.tooltip,nil,GetString(SI_MURF_WAYPOINT),e.tooltip:GetStyle("mapTitle"))
e:LayoutIconStringLine(e.tooltip,nil,t,e.tooltip:GetStyle("achievementName"))
end,
tooltip=ZO_MAP_TOOLTIP_MODE.INFORMATION,
gamepadSpacing=true,
}
local function b(a)
local e=GetCurrentMapId()
if t[e]and select(2,GetAchievementCriterion(t[e][3],1))==0 then
a:CreatePin(_G[h],t[e],t[e][1],t[e][2])
return
end
end
local function p(a)
if not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_ACQUIRED_SKYSHARDS)then return end
local e=GetCurrentMapId()
if t[e]and select(2,GetAchievementCriterion(t[e][3],1))~=0 then
a:CreatePin(_G[s],t[e],t[e][1],t[e][2])
end
end
local function v(t)
local e=GetCurrentMapId()
if a[e]and select(2,GetAchievementCriterion(a[e][3],1))==0 then
t:CreatePin(_G[i],a[e],a[e][1],a[e][2])
return
end
local e=GetCurrentMapZoneIndex()
local a=GetZoneId(e)
local a=m[a]or{}
for o,a in pairs(a)do
if select(2,GetAchievementCriterion(a,1))==0 then
local e,o,n,n,n,n,n,n=GetPOIMapInfo(e,o)
local a={e,o,a}
t:CreatePin(_G[i],a,e,o)
end
end
end
local function y(i)
if not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_ACQUIRED_SKYSHARDS)then return end
local e=GetCurrentMapId()
if a[e]and select(2,GetAchievementCriterion(a[e][3],1))~=0 then
i:CreatePin(_G[o],a[e],a[e][1],a[e][2])
return
end
local e=GetCurrentMapZoneIndex()
local t=GetZoneId(e)
local t=m[t]or{}
for a,t in pairs(t)do
if select(2,GetAchievementCriterion(t,1))~=0 then
local a,e,n,n,n,n,n,n=GetPOIMapInfo(e,a)
local t={a,e,t}
i:CreatePin(_G[o],t,a,e)
end
end
end
local e=ZO_WorldMap_GetPinManager()
e:AddCustomPin(h,b,n,c,l)
e:SetCustomPinEnabled(_G[h],true)
e:AddCustomPin(s,p,n,f,l)
e:SetCustomPinEnabled(_G[s],true)
e:AddCustomPin(i,v,n,w,r)
e:SetCustomPinEnabled(_G[i],true)
e:AddCustomPin(o,y,n,u,r)
e:SetCustomPinEnabled(_G[o],true)
end
local function n()
local e=ZO_WorldMap_GetPinManager()
e:RefreshCustomPins(_G[pinTypeGroupEventIncomplete])
e:RefreshCustomPins(_G[pinTypeGroupEventComplete])
end
local function i(t,e)
if e~=o then return end
EVENT_MANAGER:UnregisterForEvent(o,EVENT_ADD_ON_LOADED)
local e=GetCVar("language.2")
local a={
en="Skyshard",
de="Himmelsscherbe",
fr="Éclat céleste",
es="Fragmento de cielo",
}
local t={
en="Waypoint",
de="Wegpunkt",
fr="Point de cheminement",
es="Punto de ruta",
}
ZO_CreateStringId("SI_MURF_SKYSHARD",a[e]or GetString(SI_GAMEPAD_SKILLS_SKY_SHARDS))
ZO_CreateStringId("SI_MURF_WAYPOINT",t[e]or GetString(SI_EMOTECATEGORY7))
g()
y()
EVENT_MANAGER:RegisterForEvent(o,EVENT_SKYSHARDS_UPDATED,r)
EVENT_MANAGER:RegisterForEvent(o,EVENT_POI_UPDATED,l)
EVENT_MANAGER:RegisterForEvent(o,EVENT_ACHIEVEMENT_AWARDED,n)
SecurePostHook(ZO_WorldMapFilterPanel_Shared,"SetPinFilter",function(t,e,t)
if e==MAP_FILTER_ACQUIRED_SKYSHARDS then
l()
end
end)
ZO_PreHook(ZO_WorldMap_GetTooltipForMode(ZO_MAP_TOOLTIP_MODE.INFORMATION),"AppendSkyshardHint",function()return true end)
zo_callLater(r,2000)
end
EVENT_MANAGER:RegisterForEvent(o,EVENT_ADD_ON_LOADED,i)
