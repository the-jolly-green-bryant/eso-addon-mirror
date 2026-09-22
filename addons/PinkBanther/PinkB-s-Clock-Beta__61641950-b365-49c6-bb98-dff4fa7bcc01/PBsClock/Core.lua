PBS_CLOCK = {
    name = "PBsClock", baseTitle = "PB’s Clock", author = "PinkBanther", version = "1.3.1",
    defaults = {enabled=true, display="both", style="digital", seconds=false,
        hour24=true, opacity=100, source="global", preview=true, layouts={}, layoutVersion=0},
}
local A = PBS_CLOCK
-- Match the other PB addons: the settings library strips the ASCII "PB's "
-- prefix. Use U+2019 here; the manifest retains the ASCII apostrophe.
local manager = GetAddOnManager and GetAddOnManager()
if manager then
    for index = 1, manager:GetNumAddOns() do
        local name, title = manager:GetAddOnInfo(index)
        if name == A.name and title then
            local plain = title:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
            A.version = plain:match("(%d+[%d%.]*)%s*$") or A.version
            break
        end
    end
end
A.title = A.baseTitle .. " " .. A.version
local enums = {display={real=true,game=true,both=true}, style={digital=true,analog=true},
    source={global=true,zone=true}, layer={back=true,normal=true,front=true}, align={left=true,center=true,right=true}}
local ranges = { fontSize={8,64}, opacity={20,100}}
local function number(value, low, high, default)
    local n = tonumber(value)
    if not n or n ~= n then return default end
    return math.max(low, math.min(high, n))
end
function A:ScreenSize()
    return math.max(1,GuiRoot:GetWidth()),math.max(1,GuiRoot:GetHeight())
end
function A:LayoutMetrics(style,layout,legacySize)
    local sw,sh=self:ScreenSize()
    local analog=style=="analog"
    local dialSize=legacySize or 180*layout.dialScale/100
    local showText=not analog or layout.showText
    local width=analog and math.max(dialSize,showText and layout.fontSize*10 or 0) or layout.fontSize*18
    local textHeight=showText and layout.fontSize*(analog and 2.8 or 1.65) or 0
    local height=(analog and dialSize or 0)+textHeight
    return width,height,dialSize,textHeight,math.min(1,sw/width,sh/height)
end
function A:LayoutDefaults(style, kind)
    local layout={dialScale=100,fontSize=24,align="center",showText=true,
        color={0.91,0.85,0.70},layer="normal"}
    local sw,sh=self:ScreenSize()
    local width,height,_,_,scale=self:LayoutMetrics(style,layout)
    local x=style=="analog" and (kind=="real" and 75 or 95) or 95
    local y=kind=="real" and 12 or (style=="digital" and 17 or 12)
    layout.x=math.floor(math.max(0,sw-width*scale)*x/100+0.5)
    layout.y=math.floor(math.max(0,sh-height*scale)*y/100+0.5)
    return layout
end
function A:Layout(style, kind)
    return self.sv.layouts[style .. "_" .. kind]
end
function A:Validate(key, value, default)
    if key=="x" or key=="y" then
        local sw,sh=self:ScreenSize()
        return math.floor(number(value,0,key=="x" and sw or sh,default)+0.5)
    end
    if key=="dialScale" then return number(value,5,200,default) end
    if enums[key] then return enums[key][value] and value or default end
    if key == "color" then
        local c = type(value)=="table" and value or {}
        return {number(c[1],0,1,default[1]),number(c[2],0,1,default[2]),number(c[3],0,1,default[3])}
    end
    if ranges[key] then return math.floor(number(value,ranges[key][1],ranges[key][2],default)+0.5) end
    if type(value) ~= type(default) then return default end
    return value
end
function A:Normalize()
    local oldVersion = self.sv.layoutVersion
    if type(self.sv.layouts) ~= "table" then self.sv.layouts={} end
    for key, default in pairs(self.defaults) do
        if key ~= "layouts" then self.sv[key]=self:Validate(key,self.sv[key],default) end
    end
    for _,style in ipairs({"digital","analog"}) do
        for _,kind in ipairs({"real","game"}) do
            local id=style .. "_" .. kind
            local default=self:LayoutDefaults(style,kind)
            local layout=type(self.sv.layouts[id])=="table" and self.sv.layouts[id] or {}
            if oldVersion ~= 2 and oldVersion ~= 3 and self.sv.x ~= nil then
                local analog=style=="analog"
                local x=analog and oldVersion==1 and self.sv.analogX or self.sv.x
                local y=analog and oldVersion==1 and self.sv.analogY or self.sv.y
                -- Preserve the old origin, then separate the second clock to avoid overlap.
                layout.x=number(x,0,100,95)
                layout.y=number(y,0,100,12)
                if kind=="game" then
                    if analog then layout.x=layout.x>75 and layout.x-20 or layout.x+20
                    else layout.y=layout.y>90 and layout.y-5 or layout.y+5 end
                end
                layout.fontSize=analog and oldVersion==1 and self.sv.analogFontSize or self.sv.fontSize
                layout.size=self.sv.size
                layout.dialScale=100
            end
            local percentX,percentY=layout.x,layout.y
            local migrate=oldVersion~=3 and (oldVersion==2 or self.sv.x~=nil)
            local oldSize=number(layout.size,32,320,180)
            for key,value in pairs(default) do layout[key]=self:Validate(key,layout[key],value) end
            if migrate then
                local sw,sh=self:ScreenSize()
                local oldDial=oldSize*layout.dialScale/100
                local width,height,_,_,scale=self:LayoutMetrics(style,layout,oldDial)
                layout.x=math.floor(math.max(0,sw-width*scale)*number(percentX,0,100,95)/100+0.5)
                layout.y=math.floor(math.max(0,sh-height*scale)*number(percentY,0,100,12)/100+0.5)
                if style=="analog" then layout.dialScale=self:Validate("dialScale",oldDial/180*100,100) end
            end
            layout.size=nil
            self.sv.layouts[id]=layout
        end
    end
    self.sv.layoutVersion=3
end
function A:Set(key,value)
    if self.defaults[key]==nil or key=="layouts" then return end
    self.sv[key]=self:Validate(key,value,self.defaults[key])
    if key=="style" then self.previewStyle=nil; self.previewKind=nil end
    self:ApplyLayout(); self:RefreshVisibility()
end
function A:SetLayout(style,kind,key,value)
    local default=self:LayoutDefaults(style,kind)[key]
    if default==nil then return end
    self:Layout(style,kind)[key]=self:Validate(key,value,default)
    if self.panelOpen and self.sv.preview then self.previewStyle=style; self.previewKind=kind end
    self:ApplyLayout(); self:RefreshVisibility()
end
function A:Reset()
    for key,value in pairs(self.defaults) do self.sv[key]=key=="layouts" and {} or value end
    -- Legacy fields are intentionally discarded on an explicit reset.
    for _,key in ipairs({"x","y","size","fontSize","analogX","analogY","analogFontSize"}) do self.sv[key]=nil end
    self:Normalize()
    self.previewStyle=nil; self.previewKind=nil
    self:ApplyLayout(); self:RefreshVisibility()
end
function A:ReadTime(kind)
    if kind == "real" then return GetSecondsSinceMidnight() % 86400 end
    -- These are world time APIs, not elapsed play/session time. No guessed epoch.
    local read
    if self.sv.source == "zone" then read = GetLocalTimeOfDay else read = GetGlobalTimeOfDay end
    if type(read) ~= "function" then return nil end
    local h, m, s = read()
    if type(h) ~= "number" or type(m) ~= "number" or type(s) ~= "number"
        or h ~= h or m ~= m or s ~= s
        or h < 0 or h >= 24 or m < 0 or m >= 60 or s < 0 or s >= 60 then return nil end
    return h * 3600 + m * 60 + s
end

function A:FormatTime(seconds)
    if not seconds then return "--:--" end
    seconds = math.floor(seconds) % 86400
    local h, m, s = math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60
    local suffix = ""
    if not self.sv.hour24 then
        suffix = h < 12 and " AM" or " PM"
        h = h % 12
        if h == 0 then h = 12 end
    end
    return string.format("%02d:%02d", h, m) .. (self.sv.seconds and string.format(":%02d", s) or "") .. suffix
end

function A:Angles(seconds)
    local turn = math.pi * 2
    return (seconds % 43200) / 43200 * turn, (seconds % 3600) / 3600 * turn,
        (seconds % 60) / 60 * turn
end

function A:VisibleKinds()
    if self.sv.display == "both" then return {"real", "game"} end
    return {self.sv.display}
end
