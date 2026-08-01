

LibTextureProxy = LibTextureProxy or {
    ['Name'] = "LibTextureProxy",
    ['Description'] = "Texture proxy for ESO",
    ['Author'] = "voidbiscuit",
    ['APIVersion'] = "101037",
    ['Version'] = "010000",
    ['VariableVersion'] = 1,
}
local LibTextureProxy = LibTextureProxy

-- Saved variables
LibTextureProxy.default_saved_variables = {
    settings = {
        -- General
        animation_enabled = false,
        chat_wiggle_enabled = true,
        cooldown = 1,
        speed = 1,
        -- Debug
        debug_enabled = false,
    }
}
LibTextureProxy.saved_variables = {}

LibTextureProxy.values = {
    colour = {
        addon = "|cFFA500",
        default = "|r",
        error = "|cFF0000",
    },
}


local ffots = false

-- Helper

local function filter(func, tbl)
    -- Out
    local list = {};
    -- Loop
    for i, v in ipairs(tbl) do
      if func(v) then
        table.insert(list, v)
      end
    end
    -- Return
    return list
end

local function dict_filter(func, tbl)
    -- Out
    local list = {};
    -- Loop
    for k, v in pairs(tbl) do
      if func(k, v) then
        list[k] = v
      end
    end
    -- Return
    return list
end

-- Debug
function LibTextureProxy.Message(message, ...)
    if type(message) == type("") then
        -- Format
        message = string.format(message, ...)
        -- Print
        d(string.format(
            -- Msg format
            "%s[%s]%s %s",
            -- Vals
            LibTextureProxy.values.colour.addon, 
            LibTextureProxy.Name, 
            LibTextureProxy.values.colour.default, 
            message
        ))
    else
      d(message)
    end
end

function LibTextureProxy.Debug(message, ...)
    -- Check enabled
    if LibTextureProxy.saved_variables.settings.debug_enabled ~= true then return end
    -- Call
    LibTextureProxy.Message(message, ...)
end

-- Override

-- Objects

-- - Texture
local Texture = ZO_Object:Subclass()
LibTextureProxy.Texture = Texture

function Texture:New(data)
    -- Create
    local texture = ZO_Object.New(self)
    -- Attr
    texture.name = data.name
    texture.animation_enabled = data.animation_enabled
    texture.frames = data.frames
    texture.fps = data.fps
    texture.current_frame_index = data.current_frame_index
    -- Return
    return texture
end


function Texture:Create(data)
    -- Attrs
    data.name = data.name or "<Anonymous Emote>"
    data.animation_enabled = data.animation_enabled or true
    data.frames = data.frames or {}
    -- FPS
    data.fps = data.fps or #data.frames < 24 and #data.frames or 24 -- Between 15 and 24, apparently
    data.current_frame_index = data.current_frame_index or nil
    -- Make texture
    local texture = Texture:New(data)
    -- Register virtual texture
    RedirectTexture(texture.name, texture.name)
    -- Register real textures
    for frame_index, frame in ipairs(texture.frames) do
        RedirectTexture(frame, frame)
    end
    -- Set emote first frame
    texture:SetTexture(1)
    -- Return
    return texture
end

function Texture:SetTexture(frame_index)
    -- Check valid frame
    if not ((0 < frame_index) and (frame_index <= #self.frames)) then
        return
    end
    -- Return if same frame
    if self.current_frame_index == frame_index then return end
    -- Update frame index
    self.current_frame_index = frame_index
    -- Get frame
    local frame_path = self.frames[frame_index]
    -- Redirect texture
    RedirectTexture(self.name, self.name)
    RedirectTexture(self.name, frame_path)
    LibTextureProxy.Debug(string.format(" -> %s", frame_path))
end

function Texture:UpdateFrame()
    -- Check animation enabled
    if self.animation_enabled ~= true then
        return
    end
    -- Get raw frame time (1000 fps)
    local frame_time = GetFrameTimeMilliseconds() * LibTextureProxy.saved_variables.settings.speed
    -- Frame time modifier per texture
    frame_time = (frame_time * self.fps) / 1000
    frame_time = math.floor(frame_time)
    -- Find which frame to be on (time mod texture count)
    local frame_index = (frame_time % #self.frames) + 1
    -- Update texture
    self:SetTexture(frame_index)
end

function Texture:IsStatic()
    return (#self.frames <= 1)
end

function Texture:IsAnimated()
    return not (#self.frames <= 1)
end

-- - Texture Pack

local TexturePack = ZO_Object:Subclass()
LibTextureProxy.TexturePack = TexturePack

function TexturePack:New(data)
    -- Create
    local texture_pack = ZO_Object.New(self)
    -- Attr
    texture_pack.name = data.name
    texture_pack.animation_enabled = data.animation_enabled
    texture_pack.textures = data.textures
    -- Return
    return texture_pack
end

function TexturePack:Create(data)
    -- Attr
    data.name = data.name or "<Anonymous Texture Pack>"
    data.animation_enabled = data.animation_enabled or true
    data.textures = data.textures or {}
    -- Make texture pack
    local texture_pack = TexturePack:New(data)
    -- Return
    return texture_pack
end

function TexturePack:RegisterTexture(texture)
    -- Check not exist
    if not self.textures[texture.name] == nil then
        return
    end
    -- Save
    self.textures[texture.name] = texture
end

function TexturePack:DeregisterTexture(texture)
    -- Check does exist
    if self.textures[texture.name] == nil then
        return
    end
    -- Unset texture
    ZO_ClearTable(self.textures[texture.name] or {})
    -- Set nil
    self.textures[texture.name] = nil
end

function TexturePack:FromTextures(name, textures)
    -- Create
    local texture_pack = self:Create({name = name})
    -- Fill
    for texture_index, texture in ipairs(textures) do
        texture_pack:RegisterTexture(texture)
    end
    -- Return
    return texture_pack
end

function TexturePack:StaticTextures()
    local static_textures = dict_filter(function (texture_name, texture) return texture:IsStatic() end, self.textures)
    return static_textures
end

function TexturePack:AnimatedTextures()
    local animated_textures = dict_filter(function (texture_name, texture) return texture:IsAnimated() end, self.textures)
    return animated_textures
end

function TexturePack:AllTextures()
    local all_textures = dict_filter(function (texture_name, texture) return true end, self.textures)
    return all_textures
end


function TexturePack:UpdateFrame()
    -- Check enabled
    if self.animation_enabled ~= true then
        return
    end
    -- Update
    for texture_name, texture in pairs(self:AnimatedTextures()) do
        if ffots then
            LibTextureProxy.Debug("Updating texture %s", texture_name)
        end
        texture:UpdateFrame()
    end
end

-- Values

local texture_packs = {}
LibTextureProxy.texture_packs = texture_packs
local loop = nil
local expand_window = true

-- Functions

function LibTextureProxy.UpdateChatWindow()
    -- Check if chat wiggle enabled
    if not LibTextureProxy.saved_variables.settings.chat_wiggle_enabled == true then
        return
    end
    -- Resize, it's bad but it works.
    local current_width = CHAT_SYSTEM.control:GetWidth()
    if expand_window == true then
        CHAT_SYSTEM.control:SetWidth(current_width+1)
        expand_window = false
    else
        CHAT_SYSTEM.control:SetWidth(current_width-1)
        expand_window = true
    end
end

function LibTextureProxy.RegisterTexturePack(texture_pack)
    -- Check not exist
    if texture_packs[texture_pack.name] ~= nil then return end
    -- Set texture
    texture_packs[texture_pack.name] = texture_pack
end

function LibTextureProxy.DeregisterTexturePack(texture_pack)
    -- Check does exist
    if texture_packs[texture_pack.name] == nil then return end
    -- Unset texture
    ZO_ClearTable(texture_packs[texture_pack.name])
    texture_packs[texture_pack.name] = nil
end

function LibTextureProxy.Animation()
    -- Loop texturepacks
    for texture_pack_name, texture_pack in pairs(texture_packs) do
        if ffots then
            LibTextureProxy.Debug("Updating texture pack %s", texture_pack_name)
        end
        texture_pack:UpdateFrame()
    end
    -- Update chat window
    LibTextureProxy.UpdateChatWindow()
end

local last_update = 0
function LibTextureProxy.AnimationLoop()
    -- Check enabled
    if LibTextureProxy.saved_variables.settings.animation_enabled ~= true then
        -- Kill loop
        loop = nil
        return
    end
    -- First frame of the second
    local frame_time = GetFrameTimeMilliseconds()
    ffots = 1000 < frame_time - last_update
    if ffots == true then
        last_update = frame_time - math.floor(frame_time % 1000)
    end
    -- Debug
    if ffots then
        LibTextureProxy.Debug("Updating textures")
    end
    -- Run
    LibTextureProxy.Animation()
    -- Loop
    zo_callLater(
        -- Recall
        function() LibTextureProxy.AnimationLoop() end,
        -- Cooldown
        LibTextureProxy.saved_variables.settings.cooldown
    )
end

function LibTextureProxy.StartAnimationLoop()
    -- Debug
    LibTextureProxy.Debug("Starting animation loop")
    -- Check loop not started
    if loop ~= nil then return end
    loop = true
    -- Start loop
    LibTextureProxy.AnimationLoop()
end


function LibTextureProxy.SetAnimationEnabled(value)
    -- Enable
    if value == true then
        -- Set animation enabled
        LibTextureProxy.saved_variables.settings.animation_enabled = true
        -- Start loop
        LibTextureProxy.StartAnimationLoop()
    end
    -- Disable
    if value == false then
        -- Set animation disabled
        LibTextureProxy.saved_variables.settings.animation_enabled = false
    end     
end

-- Addon Config

-- Saved vars
function LibTextureProxy.SavedVariables()
    -- Saved Variables
    LibTextureProxy.saved_variables = ZO_SavedVars:NewAccountWide(
        LibTextureProxy.Name .. "SavedVariables", 
        LibTextureProxy.VariableVersion, 
        nil, 
        LibTextureProxy.default_saved_variables, 
        GetWorldName()
    )
end

-- Menu
function LibTextureProxy.AddonMenu()
    -- Addon Menu
    local LAM = LibAddonMenu2
    local panel_name = LibTextureProxy.Name .. "SettingsPanel"
    local panel_data = {
        type = "panel",
        name = LibTextureProxy.Name,
        author = LibTextureProxy.Author
    }
    local panel = LAM:RegisterAddonPanel(panel_name, panel_data)
    local options_data = {
        -- # General
        {
            type = "header",
            name = "General",
        },
        {
            type = "checkbox",
            name = "Animation Enabled",
            getFunc = function() return LibTextureProxy.saved_variables.settings.animation_enabled end,
            setFunc = function(value) LibTextureProxy.SetAnimationEnabled(value) end,
            default = LibTextureProxy.default_saved_variables.settings.animation_enabled,
        },
        {
            type = "checkbox",
            name = "Chat Wiggle Enabled",
            getFunc = function() return LibTextureProxy.saved_variables.settings.chat_wiggle_enabled end,
            setFunc = function(value) LibTextureProxy.saved_variables.settings.chat_wiggle_enabled = value end,
            default = LibTextureProxy.default_saved_variables.settings.chat_wiggle_enabled,
        },
        {
            type = "slider",
            name = "Cooldown",
            getFunc = function() return LibTextureProxy.saved_variables.settings.cooldown end,
            setFunc = function(value) LibTextureProxy.saved_variables.settings.cooldown = value end,
            default = LibTextureProxy.default_saved_variables.settings.cooldown,
            min = 1,
            max = 1000,
            step = 1,
        },
        {
            type = "slider",
            name = "Speed",
            getFunc = function() return LibTextureProxy.saved_variables.settings.speed end,
            setFunc = function(value) LibTextureProxy.saved_variables.settings.speed = value end,
            default = LibTextureProxy.default_saved_variables.settings.speed,
            min = 0,
            max = 5,
            step = 0.01,
            decimals=2
        },
    }
    LAM:RegisterOptionControls(panel_name, options_data)
end

-- Addon Load
function LibTextureProxy.Initialize()
    -- Unregister
    EVENT_MANAGER:UnregisterForEvent(LibTextureProxy.Name, EVENT_ADD_ON_LOADED)
    -- Init
    LibTextureProxy.SavedVariables()
    LibTextureProxy.AddonMenu()
    -- Start loop
    LibTextureProxy.SetAnimationEnabled(LibTextureProxy.saved_variables.settings.animation_enabled)
end

LibTextureProxy.initialised = false
function LibTextureProxy.OnAddOnLoaded(event, addonName)
    if addonName == LibTextureProxy.Name then
        LibTextureProxy.Initialize()
        LibTextureProxy.initialised = true
    end
end

EVENT_MANAGER:RegisterForEvent(LibTextureProxy.Name, EVENT_ADD_ON_LOADED, LibTextureProxy.OnAddOnLoaded)
