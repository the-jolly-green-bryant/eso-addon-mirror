--[[
  This file is part of Awesome Events.

  Author: @Ze_Mi <zemi@unive.de>
  Filename: LibAwesomeModule-1.0.lua
  Last Modified: 28.05.18 17:40

  Copyright (c) 2018 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local MAJOR, MINOR = 'LibAwesomeModule-1.0', 8
local libAM, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not libAM then return end

EVENT_AWESOME_MODULE_TIMER = 1
ORDER_AWESOME_MODULE_PUSH_NOTIFICATION = 75

COLOR_AWEVS_AVAILABLE = 1
COLOR_AWEVS_HINT = 2
COLOR_AWEVS_WARNING = 3

local colorDefs = { [COLOR_AWEVS_AVAILABLE]=nil,[COLOR_AWEVS_HINT]=nil,[COLOR_AWEVS_WARNING]=nil}

libAM.version = MINOR
libAM.labelToMod = {}
libAM.timer = {}
libAM.debug = false
libAM.logCallback = nil
libAM.log = {}

local function __boolToStr(value)
    if(value)then
        return 'true'
    else
        return 'false'
    end
end

local function __tostring(object,level)
    local lvlPrefix = ''
    if(level~=nil)then
        lvlPrefix = string.rep('--',level)
    end
    local str=''
    if(type(object) == 'table')then
        if(level==nil)then
            for i in ipairs(object)do
                if(i==1)then
                    str = str .. __tostring(object[i],1)
                else
                    str = str .. '> ' .. __tostring(object[i],1)
                end
            end
        else
            str = 'Table\n'
            for key,value in pairs(object)do
                str = str .. lvlPrefix .. '> .' .. key .. ' = ' .. __tostring(value,level+1)
            end
        end
    elseif(type(object) == 'number')then
        str = tostring(object)
    elseif(type(object) == 'boolean')then
        str = __boolToStr(object)
    elseif(type(object) == 'string')then
        str = object
    else
        str = type(object)
    end
    return str..'\n'
end

function libAM.d(...)
    if(not libAM.debug)then return end
    local args = {... }

    local str = ''
    if(args[1] ~= nil and type(args[1])=="string")then
        args[1] = '|cD4CD82[|c82D482' .. args[1] .. '|cD4CD82]|cFFFFFF '
        if(type(args[2])=="string")then
            args[1] = args[1] .. ' ' .. args[2]
            table.remove(args,2)
        end
        if(#args==1)then
            str = args[1]
        end
    end
    if(str=='')then
        str=__tostring(args)
    end
    if(libAM.logCallback == nil)then
        table.insert(libAM.log,str)
    else
        libAM.logCallback(str)
    end
end


function libAM.SetColorDef(type,r,g,b)
    if(colorDefs[type]==nil)then
        colorDefs[type] = ZO_ColorDef:New(r,g,b)
    else
        colorDefs[type]:SetRGB(r,g,b)
    end
end

local __labelIndex = 3 -- synchronous to ui-child-index
local function __getNextLabelId()
    local id = __labelIndex
    __labelIndex = id + 1
    return id
end

function libAM:CreateLabel( templateName, parentControl, previousControl, mod_id )
    local labelId = __getNextLabelId()
    self.labelToMod[labelId] = mod_id
    local label = CreateControlFromVirtual('AwesomeModuleLabel' .. labelId , parentControl, templateName)
    if( previousControl == nil) then
        label:SetAnchor( TOP, parentControl, TOP, 0, 0)
    else
        label:SetAnchor( TOP, previousControl, BOTTOM, 0, 0)
    end
    return label
end

local function __genOrderedIndex( options )
    local orderToKeyMap,orderedNumbers,orderedIndex = {},{},{}
    for key,option in pairs(options) do
        local order = (option.order or 40) * 100
        while(orderToKeyMap[order]~=nil)do
            order = order + 1
        end
        orderToKeyMap[order] = key
        table.insert( orderedNumbers, order )
    end
    table.sort( orderedNumbers )
    for i,order in ipairs(orderedNumbers) do
        table.insert( orderedIndex, orderToKeyMap[order] )
    end
    return orderedIndex
end

local function __getNextElement(t, state)

    -- Equivalent of the next function, but returns the keys in the alphabetic order
    local key = nil
    --d("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

-- Mod Constructor

function libAM:New(uniqueId)
    self.modules = self.modules or {}
    if(uniqueId==nil or self.modules[uniqueId]~=nil)then
        return {}
    end

    -- MODULE CLASS

    local Module = {
        lib = self,
        id = uniqueId,
        debug = false,
        title = 'UNTITLED_MODULE',
        hint = GetString(SI_AWEMOD_SHOW_HINT),
        label = nil,
        options = {},
        data = {},

        spacing = 0,
        fontSize = 1,
        order = 40,

        initialized = false,
        dataUpdated = true,
    }

    function Module:d(...)
        if(self.debug)then
            self.lib.d(self.id,...)
        end
    end

    function Module.Colorize(color,text)
        if(colorDefs[color]~=nil)then
            return colorDefs[color]:Colorize(text)
        else
            return text
        end
    end

    function Module.GetColorStr(color)
        if(colorDefs[color]~=nil)then
            return '|c' .. colorDefs[color]:ToHex()
        else
            return '|r'
        end
    end

    function Module:Initialize( options, parentControl, previousControl )
        if(self.initialized)then return end
        self.initialized = true

        if(options.enabled) then
            self:Enable(options)
        end

        -- create labels
        if( self.label == nil) then
            self.label = self.lib:CreateLabel('AwesomeModuleLabel', parentControl, previousControl, self.id)
            return self.label
        else
            for i,label in ipairs(self.label) do
                self.label[i] = self.lib:CreateLabel('AwesomeModuleLabel', parentControl, previousControl, self.id)
                previousControl = self.label[i]
            end
            return previousControl
        end
    end

    function Module:HasUpdate()
        return self.dataUpdated
    end

    function Module:GetEventListeners()
        return {}
    end

    function Module:Enable(options)
        self:d('Enable (in debug-mode)')
        if(type(self.label)=='table')then
            for i,_data in pairs(self.label) do
                self.label[i]:SetText('')
            end
        else
            self.label:SetText('')
        end
        self.dataUpdated = true
    end

    function Module:Disable()
        self:d('Disable')
        if(type(self.label)=='table')then
            for i,_data in pairs(self.label) do
                self.label[i]:SetText('')
            end
        else
            self.label:SetText('')
        end
    end

    function Module:Set(key,value)
        self:d('Set['..key..']',value)
        self.dataUpdated = true
    end

    function Module:StartTimer(seconds,updateIfFaster)
        if(self.lib.timer[self.id]==nil)then
            self:d(GetString(SI_AWEVS_DEBUG_MODULE_NO_TIMER))
            return
        end
        if(seconds == nil or seconds < 1)then
            seconds = 1
        end
        local timestamp = GetTimeStamp() + seconds
        if(self.lib.timer[self.id] == 0)then
            self:d('StartTimer['..seconds..']')
            self.lib.timer[self.id] = timestamp
        elseif(updateIfFaster==true and self.lib.timer[self.id] > timestamp)then
            self:d('StartTimer['..seconds..'] (faster)')
            self.lib.timer[self.id] = timestamp
        else
            self:d('StartTimer[ignored]')
        end
    end

    function Module:SetTimer(seconds)
        if(self.lib.timer[self.id]==nil)then
            self:d(GetString(SI_AWEVS_DEBUG_MODULE_NO_TIMER))
            return
        end
        if(seconds == nil or seconds < 1)then
            seconds = 1
        end
        self:d('SetTimer['..seconds..']')
        self.lib.timer[self.id] = GetTimeStamp() + seconds
    end

    function Module:StopTimer()
        if(self.lib.timer[self.id]==nil)then
            self:d(GetString(SI_AWEVS_DEBUG_MODULE_NO_TIMER))
            return
        end
        self:d('StopTimer')
        self.lib.timer[self.id] = 0
    end

    local function __getNextOption(t, state)

        -- Equivalent of the next function, but returns the keys in the alphabetic order
        local key = nil
        --d("orderedNext: state = "..tostring(state) )
        if state == nil then
            -- the first time, generate the index
            key = t.__orderedIndex[1]
        else
            -- fetch the next value
            for i = 1,table.getn(t.__orderedIndex) do
                if t.__orderedIndex[i] == state then
                    key = t.__orderedIndex[i+1]
                end
            end
        end

        if key then
            return key, t[key]
        end

        -- no more value to return, cleanup
        t.__orderedIndex = nil
        return
    end

    function Module:option_pairs()
        if(self.options == nil)then
            d("SELF",self)
            return nil,nil,nil
        end

        if(self.options.__orderedIndex == nil)then
            self.options.__orderedIndex = __genOrderedIndex( self.options )
        end
        return __getNextElement, self.options, nil
    end

    self.modules[Module.id] = Module
    return self.modules[Module.id]
end

--[[ local function __genModulesIndex( modules )
    local titleToIdMap,orderedTitles,orderedIndex = {},{},{}
    for mod_id,mod in pairs(modules) do
        local i,title = 1,mod.title
        while(titleToIdMap[title]~=nil)do
            title = mod.title .. i
            i = i+1
        end
        titleToIdMap[title] = mod_id
        table.insert( orderedTitles, title )
    end
    table.sort( orderedTitles )
    for i,title in ipairs(orderedTitles) do
        table.insert( orderedIndex, titleToIdMap[title] )
    end
    return orderedIndex
end ]]--

function libAM:module_pairs()
    if(self.modules.__orderedIndex == nil)then
        self.modules.__orderedIndex = __genOrderedIndex( self.modules )
    end
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return __getNextElement, self.modules, nil
end