local Lib = {
  name = "LibFLEncode",
  LibVersion = 2,
  author = "ForgottenLight",
  EncDec = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!?",
  EncArr = {},
  DecArr = {},
}
local function nvl(a, b) if a ~= nil then return a elseif b ~= nil then return b else return "nil" end end
local function ZXOR(a, b)
  local r,x,y,z = 0,0,0,0
  for i = 1, 6 do
    x = a % 2
    y = b % 2
    a = (a - x) / 2
    b = (b - y) / 2
    if x==0 and y==0 or x==1 and y==1 then z=0 else z=1 end
    r = r * 2 + z
  end
  return r
end

function Lib:CalcCRC(nmax)
  local n = self.n
  local a,b = n[1],n[1]
  for i = 2, nmax do
    a = a + n[i]
    b = ZXOR(b, n[i])
  end
  a = a % 64
  return a,b
end

function Lib:DecBool(k)
 local a = k%2
 return (a>0), (k-a)/2
end

function Lib:DecNumb(k,m)
 local a = k%m
 return a, (k-a)/m
end

function Lib:EncBool(val, shift) if val == true then return shift end return 0 end

function Lib:EncNumb(val, shift, lim)
  if val == nil or type(val) ~= "number" or val <= 0 then return 0 end
  if val > lim then return lim * shift end
  return val * shift
end

function Lib:EncN1V(val)
  if val == nil or type(val) ~= "number" or val <= 0 then
    return 0
  elseif val > 63 then
    val = 63
  end
  return val
end

function Lib:EncN2V(val)
  if val == nil or type(val) ~= "number" or val <= 0 then
    return 0,0
  elseif val > 4095 then
    val = 4095
  end
  local n1 = val % 64
  local n0 = (val - n1) / 64
  return n0, n1
end

function Lib:EncN3V(val)
  if val == nil or type(val) ~= "number" or val <= 0 then
    return 0,0,0
  elseif val > 262143 then
    val = 262143
  end
  local n2 = val % 64
  local n0 = (val - n2) / 64
  local n1 = n0 % 64
  n0 = (n0 - n1) / 64
  return n0, n1, n2
end

function Lib:EncDDMM(d,m)
  if d < 1 or m < 1 then
    return 0,0
  end
  return self:EncNumb(d,1,31), self:EncNumb(m,1,12)
end

function Lib:SetVersions(vers)
  local VR = self.Vers
  if type(vers) == "table" then
    for i = 0, 63 do
      VR[i] = nil
      if type(vers[i]) == "table" then
        local v = vers[i]
        if type(v.CodeStrLen) == "number" and type(v.CRCLen) == "number" and
           type(v.Decode) == "function" then
           self.CurVers = i
           self.nMaxClearStrLen = self.nMaxLen - v.CodeStrLen
           VR[i] = {
             CodeStrLen = v.CodeStrLen,
             CRCLen = v.CRCLen,
             Decode = v.Decode,
           }
        end
      end
    end
  end
end

function Lib:GetCntVertLineS(sval)
  local k,a = 0,""
  if type(sval) == "string" and sval ~= "" then
    for i = 1, string.len(sval) do
      if string.sub(sval, i, i) == "|" then k = k + 1 end
    end
  end
  return k
end

function Lib:GetCntVertLine()
  return self:GetCntVertLineS(self.Str)
end

function Lib:GetStrClear()
  local s = ""
  if type(self.Str) == "string" and self.Str ~= "" then
    local n = string.len(self.Str)
    local mcl = self.nMaxClearStrLen - self:GetCntVertLine()
    if self.CodeStrPresent ~= true then
      if n > mcl then
        return string.sub(self.Str, 1, mcl)
      end
      return self.Str
    else
      if self.nBeg > 1 then s =      string.sub(self.Str, 1, self.nBeg - 1) end
      if self.nEnd < n then s = s .. string.sub(self.Str, self.nEnd + 1, n) end
    end
  end
  return s
end

function Lib:GetStrBeg()
  local s = ""
  if type(self.Str) == "string" and self.Str ~= "" then
    local n = string.len(self.Str)
    local mcl = self.nMaxClearStrLen - self:GetCntVertLine()
    if self.CodeStrPresent ~= true then
      if n > mcl then
        return string.sub(self.Str, 1, mcl)
      end
      return self.Str
    else
      if self.nBeg > 1 then
        if self.nBeg - 1 < mcl then
          s = string.sub(self.Str, 1, self.nBeg - 1)
        else
          s = string.sub(self.Str, 1, mcl)
        end
      end
    end
  end
  return s
end

function Lib:GetStrEnd()
  local s = ""
  if type(self.Str) == "string" and self.Str ~= "" then
    if self.CodeStrPresent ~= true then
      return ""
    else
      local n = string.len(self.Str)
      if self.nEnd < n then s = string.sub(self.Str, self.nEnd + 1, n) end
    end
  end
  return s
end

function Lib:CheckCodeStrInTxt(txt)
  if type(txt) == "string" and txt ~= "" then
    local n = string.find(txt, self.Pref)
    if n ~= nil then return true end
  end
  return false
end

function Lib:FindCodeStr()
  self.CodeStrPresent = false
  self.CodeStr = ""
  if type(self.Str) == "string" and self.Str ~= "" then
    self.nBeg = string.find(self.Str, self.Pref)
    if self.nBeg ~= nil then
      self.CodeStrPresent = true
      local k = string.len(self.Pref)
      self.nEnd = string.find(self.Str, self.Suff, self.nBeg + k)
      if self.nEnd ~= nil then
        self.CodeStr = string.sub(self.Str, self.nBeg, self.nEnd)
      else
        self.nEnd = string.len(self.Str)
        self.CodeStr = string.sub(self.Str, self.nBeg, self.nEnd) .. self.Suff
    end
    end
  end
end

local function fDecode(e)
  local r,lp,ls=e.r,string.len(e.Pref),string.len(e.Suff)
  local iv=lp+1
--
  if string.len(e.CodeStr) < e.nMinCodeStrLen then
    e.Error = 1 -- Wrong length
    return true
  end
  if string.sub(e.CodeStr,1,lp) ~= e.Pref then
    e.Error = 2 -- Wrong prefix/suffix
    return true
  end
  local v = e.DecArr[string.sub(e.CodeStr,iv,iv)]
  if v == nil or v > e.CurVers or e.Vers[v] == nil then
    e.Error = 3 -- Wrong version
    return true
  end
--
  local vv = e.Vers[v]
  local l = vv.CodeStrLen
  if string.len(e.CodeStr) ~= l then
    e.Error = 1 -- Wrong length
    return true
  end
  if string.sub(e.CodeStr,l-ls+1,l) ~= e.Suff then
    e.Error = 2 -- Wrong prefix/suffix
    return true
  end
  e.Error = 0 -- Ok
  local n,m,a,b=e.n,l-iv-ls,0,0
  for i = 1, m do
    a = e.DecArr[string.sub(e.CodeStr,i+iv,i+iv)]
    if a == nil then
      e.Error = 4 -- Wrong simbol
      break
    end
    n[i] = a
  end
  if e.Error ~= 0 then
    return true
  end
  a,b = e:CalcCRC(vv.CRCLen)
  if a ~= n[m-1] or b ~= n[m] then
    e.Error = 5 -- Wrong CRC
    return true
  end
-- String is Ok !
  vv.Decode(e)
  return false
end

--
-- Section : Library interface
--
function LibFLEncode(sPref, sSuff, fInitRec, fEncode, nMaxLen)
  local e = {
    r = {},
    n = {},
    Pref = "{",
    Suff = "}",
    Str = "",
    CodeStr = "",
    CodeStrPresent = false,
    nMaxLen = 254,
    nMaxClearStrLen = 251,
    nMinCodeStrLen = 5,
    nBeg = 0,
    nEnd = 0,
    Error = 0,
    InitRec = function(self) end,
    Encode = function(self) end,
    Decode = fDecode,
    ClearN = function(self) self.n = {} end,
    CurVers = 0,
    Vers = {},
  }
  if type(sPref) == "string" and sPref ~= "" then e.Pref = sPref end
  if type(sSuff) == "string" and sSuff ~= "" then e.Suff = sSuff end
  e.nMinCodeStrLen = 3 + string.len(e.Pref) + string.len(e.Suff)
  if type(nMaxLen)  == "number" and nMaxLen > e.nMinCodeStrLen then e.nMaxLen = nMaxLen end
  if type(fInitRec) == "function" then e.InitRec = fInitRec end
  if type(fEncode)  == "function" then e.Encode  = fEncode end
  return setmetatable(e, {__index = Lib})
end

--
-- Section : Library initialization
--
local function InitEncDec()
  local l = Lib
  for i = 0, 63 do
    l.EncArr[i] = string.sub(l.EncDec,i+1,i+1)
    l.DecArr[string.sub(l.EncDec,i+1,i+1)] = i
  end
end

InitEncDec()