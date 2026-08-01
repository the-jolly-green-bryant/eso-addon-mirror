-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
--               Based on https://esoclock.uesp.net/                       --
-- 					      									               --
-----------------------------------------------------------------------------
 
TaChronos.moon = TaChronos.moon or {}
local moon     = TaChronos.moon  	

-- Conversion constants
local SECONDS_PER_TAMRIEL_DAY  = TaChronos.const.SECONDS_PER_TAMRIEL_DAY 
local TAMRIEL_MOONPHASE_LENGTH = TaChronos.const.TAMRIEL_MOONPHASE_LENGTH
local SECONDS_SINCE_START_MOON = TaChronos.const.SECONDS_SINCE_START_MOON

-- Moon phase textures
local TEX_BASE = "TamrielChronos/complications/dds/"

local tex_masser_000  = TEX_BASE.."tex_masser_000.dds"
local tex_masser_010  = TEX_BASE.."tex_masser_010.dds"
local tex_masser_020  = TEX_BASE.."tex_masser_023.dds"
local tex_masser_030  = TEX_BASE.."tex_masser_030.dds"
local tex_masser_040  = TEX_BASE.."tex_masser_043.dds"
local tex_masser_050  = TEX_BASE.."tex_masser_050.dds"
local tex_masser_060  = TEX_BASE.."tex_masser_063.dds"
local tex_masser_070  = TEX_BASE.."tex_masser_070.dds"
local tex_masser_080  = TEX_BASE.."tex_masser_083.dds"
local tex_masser_090  = TEX_BASE.."tex_masser_090.dds"
local tex_masser_100  = TEX_BASE.."tex_masser_100.dds"
local tex_masser_110  = TEX_BASE.."tex_masser_110.dds"
local tex_masser_120  = TEX_BASE.."tex_masser_123.dds"
local tex_masser_130  = TEX_BASE.."tex_masser_130.dds"
local tex_masser_140  = TEX_BASE.."tex_masser_143.dds"
local tex_masser_150  = TEX_BASE.."tex_masser_150.dds"
local tex_masser_160  = TEX_BASE.."tex_masser_163.dds"
local tex_masser_170  = TEX_BASE.."tex_masser_170.dds"
local tex_masser_180  = TEX_BASE.."tex_masser_177.dds"
local tex_masser_190  = TEX_BASE.."tex_masser_190.dds"

local tex_secunda_000  = TEX_BASE.."tex_secunda_000.dds"
local tex_secunda_010  = TEX_BASE.."tex_secunda_010.dds"
local tex_secunda_020  = TEX_BASE.."tex_secunda_023.dds"
local tex_secunda_030  = TEX_BASE.."tex_secunda_030.dds"
local tex_secunda_040  = TEX_BASE.."tex_secunda_043.dds"
local tex_secunda_050  = TEX_BASE.."tex_secunda_050.dds"
local tex_secunda_060  = TEX_BASE.."tex_secunda_063.dds"
local tex_secunda_070  = TEX_BASE.."tex_secunda_070.dds"
local tex_secunda_080  = TEX_BASE.."tex_secunda_083.dds"
local tex_secunda_090  = TEX_BASE.."tex_secunda_090.dds"
local tex_secunda_100  = TEX_BASE.."tex_secunda_100.dds"
local tex_secunda_110  = TEX_BASE.."tex_secunda_110.dds"
local tex_secunda_120  = TEX_BASE.."tex_secunda_123.dds"
local tex_secunda_130  = TEX_BASE.."tex_secunda_130.dds"
local tex_secunda_140  = TEX_BASE.."tex_secunda_143.dds"
local tex_secunda_150  = TEX_BASE.."tex_secunda_150.dds"
local tex_secunda_160  = TEX_BASE.."tex_secunda_163.dds"
local tex_secunda_170  = TEX_BASE.."tex_secunda_170.dds"
local tex_secunda_180  = TEX_BASE.."tex_secunda_177.dds"
local tex_secunda_190  = TEX_BASE.."tex_secunda_190.dds"

function moon:GetData(timeStamp)

	timeStamp = timeStamp or GetTimeStamp()
	
	local MONTH              = SECONDS_PER_TAMRIEL_DAY * TAMRIEL_MOONPHASE_LENGTH
	local MOONPHASESTARTTIME = SECONDS_SINCE_START_MOON + MONTH
	local moonOffsetTime     = timeStamp - MOONPHASESTARTTIME
	local moonPhase          = moonOffsetTime / MONTH
	local moonPhaseNorm      = moonPhase % 1
	local relMoonPhase       = 100 - math.abs(moonPhaseNorm - 0.5) * 200

	local phaseStr           = GetString(SI_TACHRONOS_MOON_00X)
    local moonTexture        = TEX_MOON_000
    local masserTex          = tex_masser_000
    local secundaTex         = tex_secunda_000
    local rotation           = 0
	local nextFullMoon       = 0
	local nextNewMoon	     = 0
	
	-- set description
	if (moonPhaseNorm <= 0.06) then
		phaseStr = GetString(SI_TACHRONOS_MOON_000)
	elseif (moonPhaseNorm <= 0.185) then 
		phaseStr = GetString(SI_TACHRONOS_MOON_025)
	elseif (moonPhaseNorm <= 0.310) then 
		phaseStr = GetString(SI_TACHRONOS_MOON_050)
	elseif (moonPhaseNorm <= 0.435) then 
		phaseStr = GetString(SI_TACHRONOS_MOON_075)
	elseif (moonPhaseNorm <= 0.560) then 
		phaseStr = GetString(SI_TACHRONOS_MOON_100)
	elseif (moonPhaseNorm <= 0.685) then 	
		phaseStr = GetString(SI_TACHRONOS_MOON_125)
	elseif (moonPhaseNorm <= 0.810) then 						
		phaseStr = GetString(SI_TACHRONOS_MOON_150)
	elseif (moonPhaseNorm <= 0.935) then 						
		phaseStr = GetString(SI_TACHRONOS_MOON_175)
	else 														
		phaseStr = GetString(SI_TACHRONOS_MOON_000)
	end

	-- set texture	
	if     (moonPhaseNorm < 0.025) then	-- < 5% of full moon cycle 200%
		masserTex  = tex_masser_000        
		secundaTex = tex_secunda_000        
	elseif (moonPhaseNorm < 0.075) then -- < 15%
		masserTex  = tex_masser_010    
		secundaTex = tex_secunda_010        
	elseif (moonPhaseNorm < 0.125) then -- < 25%
		masserTex  = tex_masser_020		
		secundaTex = tex_secunda_020        
	elseif (moonPhaseNorm < 0.175) then -- < 35% 
		masserTex  = tex_masser_030		
		secundaTex = tex_secunda_030        
	elseif (moonPhaseNorm < 0.225) then -- < 45%
		masserTex  = tex_masser_040				
		secundaTex = tex_secunda_040        
	elseif (moonPhaseNorm < 0.275) then -- < 55%
		masserTex  = tex_masser_050
		secundaTex = tex_secunda_050        
	elseif (moonPhaseNorm < 0.325) then -- < 65%					
		masserTex  = tex_masser_060
		secundaTex = tex_secunda_060        
	elseif (moonPhaseNorm < 0.375) then -- < 75%					
		masserTex  = tex_masser_070
		secundaTex = tex_secunda_070  
		rotation   = 50      
	elseif (moonPhaseNorm < 0.425) then -- < 85%					
		masserTex  = tex_masser_080
		secundaTex = tex_secunda_080        
	elseif (moonPhaseNorm < 0.475) then -- < 95%					
		masserTex  = tex_masser_090
		secundaTex = tex_secunda_090        
	elseif (moonPhaseNorm < 0.525) then -- < 105%					
		masserTex  = tex_masser_100
		secundaTex = tex_secunda_100        
	elseif (moonPhaseNorm < 0.575) then -- < 115%					
		masserTex  = tex_masser_110
		secundaTex = tex_secunda_110        
	elseif (moonPhaseNorm < 0.625) then -- < 125%					
		masserTex  = tex_masser_120
		secundaTex = tex_secunda_120        
	elseif (moonPhaseNorm < 0.675) then -- < 135%					
		masserTex  = tex_masser_130
		secundaTex = tex_secunda_130        
	elseif (moonPhaseNorm < 0.725) then -- < 145%					
		masserTex  = tex_masser_140
		secundaTex = tex_secunda_140        
	elseif (moonPhaseNorm < 0.775) then -- < 155%					
		masserTex  = tex_masser_150
		secundaTex = tex_secunda_150        
	elseif (moonPhaseNorm < 0.825) then -- < 165%					
		masserTex  = tex_masser_160
		secundaTex = tex_secunda_160        
	elseif (moonPhaseNorm < 0.875) then -- < 175%					
		masserTex  = tex_masser_170
		secundaTex = tex_secunda_170        
	elseif (moonPhaseNorm < 0.925) then -- < 185%					
		masserTex  = tex_masser_180
		secundaTex = tex_secunda_180        
	elseif (moonPhaseNorm < 0.975) then -- < 195%					
		masserTex  = tex_masser_190
		secundaTex = tex_secunda_190        
	else 														
		masserTex  = tex_masser_000
		secundaTex = tex_secunda_000        
	end
	
	-- calculate rotation
	local h,m,s = select(2,TaChronos.sun:GetTamrielTime(nil,timeStamp))
	
	if h >= 4 and h < 21 then
		rotation = -360/(h+1)/24
	elseif h == 21 then
		rotation = 30
	elseif h == 22 then
		rotation = 20
	elseif h == 23 then
		rotation = 10
	elseif h == 00 then
		rotation = 00
	elseif h == 01 then
		rotation = -10
	elseif h == 02 then
		rotation = -20
	elseif h == 03 then
		rotation = -30
	end
	rotation = (h+m/60+s/3600)*360/24
	
	-- calculate data
	if moonPhaseNorm >= 0.5 then 
		nextNewMoon  = MONTH/2      - MONTH/2*(100-relMoonPhase)/100          
		nextFullMoon = nextNewMoon  + MONTH/2
	else
		nextFullMoon = MONTH/2      - MONTH/2*relMoonPhase/100           
		nextNewMoon  = nextFullMoon + MONTH/2
	end

	local nextFullMoon = ZO_FormatTime(nextFullMoon, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR_NO_SECONDS)
	local nextNewMoon  = ZO_FormatTime(nextNewMoon,  TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR_NO_SECONDS)

    return masserTex, secundaTex, rotation, phaseStr, relMoonPhase, nextFullMoon, nextNewMoon, moonPhaseNorm
end

function moon:GetPhaseStr(phase,nPhase)
	local tPhase = ""
	if phase == GetString(SI_TACHRONOS_MOON_000) or phase == GetString(SI_TACHRONOS_MOON_100) then 
		if nPhase > 0.5 then 
			tPhase = GetString(SI_TACHRONOS_M_WAINING) 
		else 
			tPhase = GetString(SI_TACHRONOS_M_WAXING)
		end
	end
	return tPhase
end