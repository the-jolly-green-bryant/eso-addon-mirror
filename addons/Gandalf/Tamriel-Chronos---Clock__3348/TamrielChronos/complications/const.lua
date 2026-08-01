-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------
 
TaChronos.const = TaChronos.const or {}
local c         = TaChronos.const  	

-- Conversion constants
c.TAMRIEL_YEAROFFSET               = 582
c.TAMRIEL_WEEKDAY_OFFSET           = 3	-- Weekday offset to make launch day Fredas
c.SECONDS_PER_TAMRIEL_DAY          = 20955
c.SECONDS_SINCE_START              = 1394659893
c.SECONDS_PER_TAMRIEL_NIGHT        = c.SECONDS_PER_TAMRIEL_DAY/24*5   
c.TAMRIEL_MOONPHASE_LENGTH         = 30
c.SECONDS_SINCE_START_MOON         = 1435838770 + c.SECONDS_PER_TAMRIEL_DAY*c.TAMRIEL_MOONPHASE_LENGTH/2 -- % of of half cycle
c.SECONDS_SINCE_START_MOON         = c.SECONDS_SINCE_START_MOON +9300 -- adjustment of +9300sec ~3% based on check of 04.03.2020
