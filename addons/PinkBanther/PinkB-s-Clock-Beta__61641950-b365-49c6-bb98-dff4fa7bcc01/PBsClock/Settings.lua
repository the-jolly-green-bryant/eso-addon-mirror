local A,S=PBS_CLOCK,PBS_CLOCK_STRINGS

function A:InitSettings()
    local L=LibHarvensAddonSettings
    if not L then return end
    local panel=L:AddAddon(self.title)
    if not panel then return end
    self.panel=panel
    panel.author,panel.version,panel.allowDefaults=self.author,self.version,true
    CALLBACK_MANAGER:RegisterCallback("LibHarvensAddonSettings_AddonSelected",function(_,selected)
        self:OnAddonSelected(selected)
    end)
    panel:AddSetting({type=L.ST_LABEL,label=S.note})
    local function toggle(key)
        panel:AddSetting({type=L.ST_CHECKBOX,label=S[key],default=self.defaults[key],
            getFunction=function() return self.sv[key] end,
            setFunction=function(v) self:Set(key,v) end})
    end
    local function select(label,values,default,get,set)
        local items,byValue={},{}
        for _,value in ipairs(values) do
            local item={name=S[value],data=value}
            items[#items+1],byValue[value]=item,item
        end
        panel:AddSetting({type=L.ST_DROPDOWN,label=label,items=items,default=byValue[default].name,
            getFunction=function() return byValue[get()].name end,
            setFunction=function(_,_,item) if item then set(item.data) end end})
    end
    toggle("enabled"); toggle("preview")
    for _,spec in ipairs({{"display",{"real","game","both"}}, {"style",{"digital","analog"}},
        {"source",{"global","zone"}}}) do
        local key=spec[1]
        select(S[key],spec[2],self.defaults[key],function() return self.sv[key] end,
            function(v) self:Set(key,v) end)
    end
    toggle("seconds"); toggle("hour24")
    panel:AddSetting({type=L.ST_SLIDER,label=S.opacity,min=20,max=100,step=5,default=100,
        getFunction=function() return self.sv.opacity end,setFunction=function(v) self:Set("opacity",v) end})
    for _,style in ipairs({"digital","analog"}) do
        for _,kind in ipairs({"real","game"}) do
            local prefix=S[style] .. " / " .. S[kind]
            local defaults=self:LayoutDefaults(style,kind)
            local function get(key) return self:Layout(style,kind)[key] end
            local function set(key,v) self:SetLayout(style,kind,key,v) end
            panel:AddSetting({type=L.ST_SECTION or L.ST_LABEL,label=prefix})
            panel:AddSetting({type=L.ST_BUTTON,label=prefix .. " / " .. S.preview,
                buttonText=S.previewButton,clickHandler=function()
                    self:PreviewClock(style,kind)
                    if panel.UpdateControls then panel:UpdateControls() end
                end})
            local sw,sh=self:ScreenSize()
            local specs={{"x",0,math.floor(sw),1},{"y",0,math.floor(sh),1},{"fontSize",8,64,1}}
            if style=="analog" then
                panel:AddSetting({type=L.ST_CHECKBOX,label=prefix .. " / " .. S.showText,
                    default=defaults.showText,getFunction=function() return get("showText") end,
                    setFunction=function(v) set("showText",v) end})
                specs[#specs+1]={"dialScale",5,200,5}
            end
            for _,spec in ipairs(specs) do
                local key=spec[1]
                panel:AddSetting({type=L.ST_SLIDER,label=prefix .. " / " .. S[key],
                    min=spec[2],max=spec[3],step=spec[4],default=defaults[key],
                    getFunction=function() return get(key) end,setFunction=function(v) set(key,v) end})
            end
            select(prefix .. " / " .. S.align,{"left","center","right"},defaults.align,
                function() return get("align") end,function(v) set("align",v) end)
            select(prefix .. " / " .. S.layer,{"back","normal","front"},defaults.layer,
                function() return get("layer") end,function(v) set("layer",v) end)
            if L.ST_COLOR then
                panel:AddSetting({type=L.ST_COLOR,label=prefix .. " / " .. S.color,default=defaults.color,
                    getFunction=function() local c=get("color"); return c[1],c[2],c[3],1 end,
                    setFunction=function(r,g,b) set("color",{r,g,b}) end})
            else
                -- Color sliders remain available on library builds without a color picker.
                for i,key in ipairs({"red","green","blue"}) do
                    panel:AddSetting({type=L.ST_SLIDER,label=prefix .. " / " .. S[key],min=0,max=100,step=1,
                        default=defaults.color[i]*100,getFunction=function() return get("color")[i]*100 end,
                        setFunction=function(v)
                            local c=get("color"); local copy={c[1],c[2],c[3]}; copy[i]=v/100; set("color",copy)
                        end})
                end
            end
        end
    end
    panel:AddSetting({type=L.ST_BUTTON,label=S.reset,buttonText=S.resetButton,clickHandler=function()
        self:Reset(); if panel.UpdateControls then panel:UpdateControls() end
    end})
end
