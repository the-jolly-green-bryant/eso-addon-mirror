AUI.Time = {}

AUI_TIME_FORMAT_NORMAL = 0
AUI_TIME_FORMAT_SHORT = 1
AUI_TIME_FORMAT_EXACT = 2

function AUI.Time.MS_To_S(_ms)
	return _ms / 1000
end

function AUI.Time.GetFormatedString(_s, _m)
	local s = _s
	local m = 0
	local h = 0
	local d = 0

	if not _m then
		_m = AUI_TIME_FORMAT_NORMAL
	end
	
	if s >= 60 then
		m = s / 60
		s = math.fmod(s, 60)
	end
	
	if m >= 60 then
		h = m / 60
		m = math.fmod(m, 60)
	end	
	
	if h >= 24 then
		d = h / 24
	
		h = math.fmod(h, 24)
	end	

	if d > 0 then
		s = math.floor(s)
		m = math.floor(m)
		h = math.floor(h)
		d = math.floor(d)	
	
		if h > 0 and m > 0 and _m == AUI_TIME_FORMAT_NORMAL then
			return d .. "d " .. h .. "h " .. m .. "m"
		elseif h > 0 and _m == AUI_TIME_FORMAT_NORMAL then
			return d .. "d " .. h .. "h"
		else
			if d > 30 then
				return d + 1 .. "d"
			end			
		
			return d .. "d"
		end		
	elseif h > 0 then
		s = math.floor(s)
		m = math.floor(m)
		h = math.floor(h)
	
		if m > 0 and _m == AUI_TIME_FORMAT_NORMAL then
			return  h .. " h " .. m .. "m"
		else
			if m > 30 then
				return h + 1 .. "h"
			end		
		
			return h .. " h"
		end	
	elseif m > 0 then
		s = math.floor(s)
		m = math.floor(m)
	
		if s > 0 and _m == AUI_TIME_FORMAT_NORMAL then
			return m .. "m " .. s .. "s"
		else
			if s > 30 then
				return m + 1 .. "m"
			end
			
			return m .. "m "
		end
	else
		if s > 0 then
			if s <= 1 then
				return AUI.Math.Round(s, 1) .. "s"
			elseif s <= 60 then
				if _m == AUI_TIME_FORMAT_SHORT then
					return AUI.Math.Round(s, 0) .. "s"					
				elseif _m == AUI_TIME_FORMAT_NORMAL then
					return AUI.Math.Round(s, 1) .. "s"
				else
					return AUI.Math.Round(s, 2) .. "s"
				end
			end
		end
	end

	return 0 .. "s"
end

function AUI.Time.GetFormatedTime(_precision)
	local seconds   = GetSecondsSinceMidnight()
	local formattedTime = FormatTimeSeconds(seconds, TIME_FORMAT_STYLE_CLOCK_TIME, _precision, TIME_FORMAT_DIRECTION_NONE)

	if _precision == TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR then
		local str = AUI.L10n["clock_suffix"]
		if str and not AUI.String.IsEmpty(str) then
			formattedTime = formattedTime .." " .. str
		end
	end
	
	return formattedTime
end