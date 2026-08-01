LibBase64 = LibBase64 or {}
local B64CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local b64charmap = {};

for index = 1, 64 do b64charmap[string.byte(B64CHARS, index)] = index - 1 end

function LibBase64.encode(s)
	local b64chars = B64CHARS
	local rn = #s % 3
	local st = {}
	local c1, c2, c3
	local t4 = {}
	local lln, maxlln = 1, 72
	for i = 1, #s, 3 do
		c1 = string.byte(s,i)
		c2 = string.byte(s,i+1) or 0
		c3 = string.byte(s,i+2) or 0
		t4[1] = string.char(string.byte(b64chars, BitRShift(c1, 2) + 1))
		t4[2] = string.char(string.byte(b64chars, BitAnd(BitOr(BitLShift(c1, 4), BitRShift(c2, 4)), 0x3f) + 1))
		t4[3] = string.char(string.byte(b64chars, BitAnd(BitOr(BitLShift(c2, 2), BitRShift(c3, 6)), 0x3f) + 1))
		t4[4] = string.char(string.byte(b64chars, BitAnd(c3, 0x3f) + 1))
		st[#st+1] = table.concat(t4)
		lln = lln + 4
		if lln > maxlln then st[#st+1] = "\n"; lln = 1 end
	end
	local llx = #st
	if st[llx] == "\n" then llx = llx - 1 end 
	if rn == 2 then
		st[llx] = string.gsub(st[llx], ".$", "=")
	elseif rn == 1 then
		st[llx] = string.gsub(st[llx], "..$", "==")
	end
	return table.concat(st)
end

function LibBase64.decode(b)
	local cmap = b64charmap
	local e1, e2, e3, e4
	local st = {}
	local t3 = {}
	b = string.gsub(b, "[=%s]", "")
	if b:find("[^0-9A-Za-z/+=]") then return nil, "invalid char" end
	for i = 1, #b, 4 do
		e1 = cmap[string.byte(b, i)]
		e2 = cmap[string.byte(b, i+1)]
		if not e1 or not e2 then return nil, "invalid length" end
		e3 = cmap[string.byte(b, i+2)]
		e4 = cmap[string.byte(b, i+3)]
		t3[1] = string.char(BitOr(BitLShift(e1, 2), BitRShift(e2, 4)))
		if not e3 then
			t3[2] = nil
			t3[3] = nil
			st[#st + 1] = table.concat(t3)
			break
		end
		t3[2] = string.char(BitAnd(BitOr(BitLShift(e2, 4), BitRShift(e3, 2)), 0xff))
		if not e4 then
			t3[3] = nil
			st[#st + 1] = table.concat(t3)
			break
		end
		t3[3] = string.char(BitAnd(BitOr(BitLShift(e3, 6), e4), 0xff))
		st[#st + 1] = table.concat(t3)
	end
	return table.concat(st)
end