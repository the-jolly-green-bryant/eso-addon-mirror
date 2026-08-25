-- Texture paths and one-shot binds. Re-binding every power tick would spam
-- chat and fight console SetTexture. Log every first bind so /vtheme diag
-- and SavedVariables debugLog show whether .dds actually loaded.
-- SetTexture ok=true is not proof: ESO does not error on a missing file.
-- Fancy Action Bar+ loads custom DXT5 from /AddonName/texture/file.dds
-- (leading slash, mipCount=1). Never bind /esoui/art/actionbar/* — FAB+
-- RedirectTexture maps those to blank.dds.

ValknarrThemeSkins = ValknarrThemeSkins or {}

local Skins = ValknarrThemeSkins
local Safe = ValknarrThemeSafe
local Log = ValknarrThemeLog
local Format = ValknarrThemeFormat

local TEX_ROOT = "/ValknarrTheme/texture/"

Skins.VANILLA_WOLF_ICON = "/esoui/art/icons/ability_werewolf_001.dds"
Skins.TEMPLATE = {
    icon = "ValknarrTheme_WwIcon",
    ring = "ValknarrTheme_WwRing",
    seg = "ValknarrTheme_WwSeg",
    well = "ValknarrTheme_WwWell",
    headfill = "ValknarrTheme_WwWell",
}
Skins.WELL = TEX_ROOT .. "well.dds"
Skins.WOLF = {
    nordic = { icon = TEX_ROOT .. "w1i.dds", ring = TEX_ROOT .. "w1r.dds", wedge = TEX_ROOT .. "wseg.dds" },
    steel = { icon = TEX_ROOT .. "w3i.dds", ring = TEX_ROOT .. "w3r.dds", wedge = TEX_ROOT .. "wseg.dds" },
    bronze = { icon = TEX_ROOT .. "w2i.dds", ring = TEX_ROOT .. "w2r.dds", wedge = TEX_ROOT .. "wseg.dds" },
}

function Skins.BarFrame(themeId)
    local frames = _G.ValknarrThemeFrames
    if type(frames) ~= "table" then
        return nil
    end
    local id = Format.NormalizeThemeId(themeId)
    local pack = frames[id]
    if type(pack) ~= "table" or type(pack.tiles) ~= "table" or type(pack.hole) ~= "table" then
        return nil
    end
    return pack
end

function Skins.WolfPlate(wolfId)
    local frames = _G.ValknarrThemeFrames
    if type(frames) ~= "table" or type(frames.wolf) ~= "table" then
        return nil
    end
    local id = Format.NormalizeWolfId(wolfId)
    local pack = frames.wolf[id]
    if type(pack) ~= "table" or type(pack.tiles) ~= "table" or type(pack.hole) ~= "table" then
        return nil
    end
    return {
        tiles = pack.tiles,
        hole = pack.hole,
        circle = frames.wolf.circle or { 0.75, 0.50, 0.24 },
        well = frames.wolf.well or 0.20,
        cols = frames.wolf.cols or 4,
        rows = frames.wolf.rows or 2,
    }
end

function Skins.BindBarTiles(controls, pack, tagPrefix)
    if type(controls) ~= "table" or type(pack) ~= "table" or type(pack.tiles) ~= "table" then
        return false
    end
    local ok = true
    for index = 1, #pack.tiles do
        local control = controls[index]
        local path = pack.tiles[index]
        if not (control and path and Skins.Bind(control, path, tagPrefix .. index) and Skins.IsCustomBound(control)) then
            ok = false
        end
    end
    return ok
end

function Skins.HudPack(_themeId)
    return nil
end

function Skins.WolfPack(wolfId)
    return Skins.WOLF[Format.NormalizeWolfId(wolfId)]
end

local function IsCustomPath(path)
    return type(path) == "string" and string.find(path, "ValknarrTheme/", 1, true) ~= nil
end

function Skins.CreateTexture(name, parent, template)
    if template and WINDOW_MANAGER and type(WINDOW_MANAGER.CreateControlFromVirtual) == "function" then
        local ok, control = pcall(WINDOW_MANAGER.CreateControlFromVirtual, WINDOW_MANAGER, name, parent, template)
        if ok and control then
            return control
        end
    end
    if WINDOW_MANAGER and CT_TEXTURE then
        return WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
    end
    return nil
end

local function TextureFileSize(control)
    if type(control.GetTextureFileDimensions) == "function" then
        local ok, width, height = pcall(control.GetTextureFileDimensions, control)
        if ok and type(width) == "number" then
            return width, type(height) == "number" and height or 0
        end
    end
    local width
    local height
    if type(control.GetTextureFileWidth) == "function" then
        local ok, value = pcall(control.GetTextureFileWidth, control)
        if ok and type(value) == "number" then
            width = value
        end
    end
    if type(control.GetTextureFileHeight) == "function" then
        local ok, value = pcall(control.GetTextureFileHeight, control)
        if ok and type(value) == "number" then
            height = value
        end
    end
    return width, height
end

local EXPECT = {
    [TEX_ROOT .. "u1.dds"] = { 256, 64 },
    [TEX_ROOT .. "xl.dds"] = { 256, 256 },
    [TEX_ROOT .. "xm.dds"] = { 256, 256 },
    [TEX_ROOT .. "xr.dds"] = { 256, 256 },
    [TEX_ROOT .. "a2l.dds"] = { 256, 256 },
    [TEX_ROOT .. "a2m.dds"] = { 256, 256 },
    [TEX_ROOT .. "a2r.dds"] = { 256, 256 },
    [TEX_ROOT .. "a3l.dds"] = { 256, 256 },
    [TEX_ROOT .. "a3m.dds"] = { 256, 256 },
    [TEX_ROOT .. "a3r.dds"] = { 256, 256 },
    [TEX_ROOT .. "w1i.dds"] = { 256, 256 },
    [TEX_ROOT .. "w1r.dds"] = { 256, 256 },
    [TEX_ROOT .. "w2i.dds"] = { 256, 256 },
    [TEX_ROOT .. "w2r.dds"] = { 256, 256 },
    [TEX_ROOT .. "w3i.dds"] = { 256, 256 },
    [TEX_ROOT .. "w3r.dds"] = { 256, 256 },
    [TEX_ROOT .. "wseg.dds"] = { 256, 256 },
    [TEX_ROOT .. "well.dds"] = { 256, 256 },
    [TEX_ROOT .. "n1.dds"] = { 256, 256 },
    [TEX_ROOT .. "n2.dds"] = { 256, 256 },
    [TEX_ROOT .. "n3.dds"] = { 256, 256 },
    [TEX_ROOT .. "n4.dds"] = { 256, 256 },
    [TEX_ROOT .. "n5.dds"] = { 256, 256 },
    [TEX_ROOT .. "n6.dds"] = { 256, 256 },
    [TEX_ROOT .. "n7.dds"] = { 256, 256 },
    [TEX_ROOT .. "n8.dds"] = { 256, 256 },
    [TEX_ROOT .. "s1.dds"] = { 256, 256 },
    [TEX_ROOT .. "s2.dds"] = { 256, 256 },
    [TEX_ROOT .. "s3.dds"] = { 256, 256 },
    [TEX_ROOT .. "s4.dds"] = { 256, 256 },
    [TEX_ROOT .. "s5.dds"] = { 256, 256 },
    [TEX_ROOT .. "s6.dds"] = { 256, 256 },
    [TEX_ROOT .. "s7.dds"] = { 256, 256 },
    [TEX_ROOT .. "s8.dds"] = { 256, 256 },
    [TEX_ROOT .. "b1.dds"] = { 256, 256 },
    [TEX_ROOT .. "b2.dds"] = { 256, 256 },
    [TEX_ROOT .. "b3.dds"] = { 256, 256 },
    [TEX_ROOT .. "b4.dds"] = { 256, 256 },
    [TEX_ROOT .. "b5.dds"] = { 256, 256 },
    [TEX_ROOT .. "b6.dds"] = { 256, 256 },
    [TEX_ROOT .. "b7.dds"] = { 256, 256 },
    [TEX_ROOT .. "b8.dds"] = { 256, 256 },
}

local function BarePath(path)
    if type(path) ~= "string" then
        return path
    end
    if string.sub(path, 1, 1) == "/" then
        return path
    end
    return "/" .. path
end

local function TextureFileName(control)
    if type(control.GetTextureFileName) == "function" then
        local ok, value = pcall(control.GetTextureFileName, control)
        if ok and type(value) == "string" then
            return value
        end
    end
    return nil
end

local function Stolen(fileName)
    if type(fileName) ~= "string" then
        return false
    end
    local lower = string.lower(fileName)
    return string.find(lower, "blank.dds", 1, true) ~= nil
        or string.find(lower, "fancyactionbar", 1, true) ~= nil
end

function Skins.IsCustomBound(control)
    return control and IsCustomPath(control.ValknarrBoundTex) and true or false
end

local function Accepts(path, width, height, fileName)
    if Stolen(fileName) then
        return false
    end
    if width == nil then
        return true
    end
    if width == 0 then
        return false
    end
    local expect = EXPECT[BarePath(path)]
    if expect then
        return width == expect[1] and height == expect[2]
    end
    if IsCustomPath(path) and width == 64 and height == 64 then
        return false
    end
    return width > 0
end

local function Candidates(path)
    if string.sub(path, 1, 1) == "/" then
        return { path, string.sub(path, 2) }
    end
    return { "/" .. path, path }
end

local function Prepare(control)
    Safe.Try(control, "SetColor", 1, 1, 1, 1)
    Safe.Try(control, "SetAlpha", 1)
    local blend = _G.TEX_BLEND_MODE_ALPHA
    if blend ~= nil then
        Safe.Try(control, "SetBlendMode", blend)
    end
end

local MAX_MISS_TRIES = 8

function Skins.Bind(control, path, tag)
    if not control then
        if Log then
            Log:Always("tex FAIL tag=" .. tostring(tag) .. " control=nil path=" .. tostring(path))
        end
        return false
    end
    if type(path) ~= "string" or path == "" then
        if Log then
            Log:Always("tex FAIL tag=" .. tostring(tag) .. " empty path")
        end
        return false
    end
    if control.ValknarrBoundTex == path then
        return true
    end
    if control.ValknarrTriedTex == path and control.ValknarrGiveUp then
        return false
    end

    Prepare(control)

    local used = nil
    local fileW, fileH
    local lastOk, lastErr
    local list = Candidates(path)
    for index = 1, #list do
        local candidate = list[index]
        lastOk, lastErr = Safe.Try(control, "SetTexture", candidate)
        fileW, fileH = TextureFileSize(control)
        local fileName = TextureFileName(control)
        if lastOk and Accepts(candidate, fileW, fileH, fileName) then
            used = candidate
            break
        end
    end

    local fallback = false
    if IsCustomPath(path) and used == nil and tag and string.find(tostring(tag), "icon", 1, true) then
        lastOk, lastErr = Safe.Try(control, "SetTexture", Skins.VANILLA_WOLF_ICON)
        fileW, fileH = TextureFileSize(control)
        if lastOk and not Stolen(TextureFileName(control)) then
            used = Skins.VANILLA_WOLF_ICON
            fallback = true
        end
    end

    local tries
    if used then
        tries = (control.ValknarrTries or 0) + 1
        control.ValknarrTriedTex = path
        control.ValknarrBoundTex = used
        control.ValknarrGiveUp = nil
        control.ValknarrTries = nil
    else
        control.ValknarrTries = (control.ValknarrTries or 0) + 1
        tries = control.ValknarrTries
        if control.ValknarrTries >= MAX_MISS_TRIES then
            control.ValknarrTriedTex = path
            control.ValknarrGiveUp = true
        end
    end
    if Log and (used or tries <= 2 or tries == MAX_MISS_TRIES) then
        local bits = Log.ControlBits and Log:ControlBits(control) or {}
        local fileName = TextureFileName(control) or ""
        local line = "tex tag=" .. tostring(tag)
            .. " path=" .. path
            .. " used=" .. tostring(used or "")
            .. " ok=" .. tostring(lastOk and true or false)
            .. " fileW=" .. tostring(fileW)
            .. " fileH=" .. tostring(fileH)
            .. " fallback=" .. tostring(fallback)
            .. " try=" .. tostring(tries)
            .. " file=" .. fileName
            .. " err=" .. tostring(lastErr or "")
            .. " name=" .. tostring(bits.name or control.GetName and control:GetName() or "?")
        if type(tag) == "string" and string.find(tag, "probe/", 1, true) then
            Log:Always(line)
        else
            Log:Debug(line)
        end
    end
    return used ~= nil
end

function Skins.BindBackdrop(control, tag, pack)
    if not control then
        return false
    end
    pack = pack or {}
    local edge = pack.edge
    local well = pack.well
    if type(edge) == "string" then
        Safe.Try(control, "SetEdgeTexture", edge, pack.edgeW or 128, pack.edgeH or 16, pack.edgeThick or 6)
    end
    if type(well) == "string" then
        Safe.Try(control, "SetCenterTexture", well)
    end
    if Log and control.ValknarrBackdropLogged ~= edge then
        control.ValknarrBackdropLogged = edge
        Log:Always("tex tag=" .. tostring(tag) .. " path=" .. tostring(edge or "") .. " backdrop=edge")
    end
    return edge ~= nil
end

function Skins.ClearBind(control)
    if control then
        control.ValknarrBoundTex = nil
        control.ValknarrTriedTex = nil
        control.ValknarrGiveUp = nil
        control.ValknarrTries = nil
    end
end

function Skins.Probe(pass)
    if not WINDOW_MANAGER or not GuiRoot or not CT_TEXTURE then
        if Log then
            Log:Always("probe FAIL no WINDOW_MANAGER")
        end
        return
    end
    pass = tonumber(pass) or 1
    local specs = {
        { tag = "probe/wolf", path = TEX_ROOT .. "w1i.dds", want = "256x256" },
        { tag = "probe/tile", path = TEX_ROOT .. "xl.dds", want = "256x256" },
        { tag = "probe/strip", path = TEX_ROOT .. "u1.dds", want = "256x64" },
        { tag = "probe/plate", path = TEX_ROOT .. "n1.dds", want = "256x256" },
        { tag = "probe/well", path = TEX_ROOT .. "well.dds", want = "256x256" },
    }
    if Log then
        Log:Always("probe pass=" .. tostring(pass))
    end
    for index = 1, #specs do
        local spec = specs[index]
        local name = "ValknarrThemeProbe" .. index
        local control = _G[name]
        if not control then
            control = WINDOW_MANAGER:CreateControl(name, GuiRoot, CT_TEXTURE)
        end
        Safe.Try(control, "SetHidden", true)
        Safe.Try(control, "SetDimensions", 8, 8)
        Skins.ClearBind(control)
        Skins.Bind(control, spec.path, spec.tag)
        if Log then
            Log:Always("probe want=" .. spec.want .. " path=" .. spec.path)
        end
    end
    if pass == 1 and EVENT_MANAGER and type(EVENT_MANAGER.RegisterForUpdate) == "function" then
        pcall(EVENT_MANAGER.UnregisterForUpdate, EVENT_MANAGER, "ValknarrThemeProbeRetry")
        EVENT_MANAGER:RegisterForUpdate("ValknarrThemeProbeRetry", 2000, function()
            pcall(EVENT_MANAGER.UnregisterForUpdate, EVENT_MANAGER, "ValknarrThemeProbeRetry")
            Skins.Probe(2)
        end)
    end
end

function Skins.Rebind(control, path, tag)
    if control and control.ValknarrTriedTex ~= path then
        Skins.ClearBind(control)
    end
    return Skins.Bind(control, path, tag)
end

return Skins
