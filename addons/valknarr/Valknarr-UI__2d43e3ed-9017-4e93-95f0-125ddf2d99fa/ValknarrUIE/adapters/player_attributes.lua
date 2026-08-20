ValknarrUIEPlayerAttributes = ValknarrUIEPlayerAttributes or {}

local Adapter = ValknarrUIEPlayerAttributes
local Log = ValknarrUIELog
local Platform = ValknarrUIEPlatform
local Safe = ValknarrUIESafe
local names = { health = "Health", magicka = "Magicka", stamina = "Stamina" }
local order = { "health", "magicka", "stamina" }

local function FindControl(element)
    local suffix = names[element]
    local candidates = {
        { label = "ZO_PlayerAttribute" .. suffix, control = _G["ZO_PlayerAttribute" .. suffix] },
        { label = "ZO_PlayerAttribute" .. suffix .. "Bar", control = _G["ZO_PlayerAttribute" .. suffix .. "Bar"] },
    }

    for _, candidate in ipairs(candidates) do
        if candidate.control and type(candidate.control.SetAnchor) == "function" then
            if Log then
                Log:Debug("Locate " .. element .. " via global " .. candidate.label)
            end
            return candidate.control, candidate.label
        end
    end

    local root = _G.ZO_PlayerAttribute
    if root and type(root.GetNamedChild) == "function" then
        local ok, child = pcall(root.GetNamedChild, root, suffix)
        if ok and child and type(child.SetAnchor) == "function" then
            if Log then
                Log:Debug("Locate " .. element .. " via ZO_PlayerAttribute:" .. suffix)
            end
            return child, "ZO_PlayerAttribute/" .. suffix
        end
    end

    if Log then
        Log:Warn("Locate failed for " .. element)
    end
    return nil, nil
end

function Adapter:Find(element)
    return FindControl(element)
end

function Adapter:Locate()
    local controls = {}
    local sources = {}
    for index = 1, #order do
        local element = order[index]
        local control, source = FindControl(element)
        controls[element] = control
        sources[element] = source or "missing"
    end
    if Log then
        Log:Dump("Located controls", sources)
    end
    return controls, sources
end

function Adapter:Capture(control)
    if not control or type(control.GetAnchor) ~= "function" then
        return nil
    end
    local count = 1
    if type(control.GetNumAnchors) == "function" then
        local countOk, anchorCount = pcall(control.GetNumAnchors, control)
        if countOk and type(anchorCount) == "number" and anchorCount > 0 then
            count = anchorCount
        end
    end

    local anchors = {}
    for index = 0, count - 1 do
        -- GetAnchor returns isValid, point, relativeTo, relativePoint, offsetX, offsetY.
        -- pcall prepends success. Skipping isValid stored CENTER (128) as relativeTo
        -- and crashed DescribeAnchors on first /uiedit.
        local pcallOk, isValid, point, relativeTo, relativePoint, offsetX, offsetY =
            pcall(control.GetAnchor, control, index)
        if pcallOk and isValid then
            anchors[#anchors + 1] = { point, relativeTo, relativePoint, offsetX or 0, offsetY or 0 }
        end
    end

    if #anchors == 0 then
        if Log then
            Log:Warn("Capture found no anchors for " .. Log:FormatValue(control))
        end
        return nil
    end
    local sizeW, sizeH = self:GetControlSize(control)
    anchors.width = sizeW
    anchors.height = sizeH
    if Log then
        Log:Debug("Captured " .. #anchors .. " anchor(s) for " .. Log:FormatValue(control))
    end
    return anchors
end

function Adapter:GetScreenSize()
    if not GuiRoot or type(GuiRoot.GetWidth) ~= "function" then
        return nil, nil
    end
    local okW, width = pcall(GuiRoot.GetWidth, GuiRoot)
    local okH, height = pcall(GuiRoot.GetHeight, GuiRoot)
    if not okW or not okH or type(width) ~= "number" or type(height) ~= "number" or width <= 0 or height <= 0 then
        return nil, nil
    end
    return width, height
end

function Adapter:GetControlSize(control)
    if not control then
        return nil, nil
    end
    local okW, width = pcall(control.GetWidth, control)
    local okH, height = pcall(control.GetHeight, control)
    if not okW or not okH or type(width) ~= "number" or type(height) ~= "number" then
        return nil, nil
    end
    return width, height
end

function Adapter:GetNormalizedRect(control)
    local width, height = self:GetScreenSize()
    if not control or not width then
        return nil
    end
    local okL, left = pcall(control.GetLeft, control)
    local okT, top = pcall(control.GetTop, control)
    local okR, right = pcall(control.GetRight, control)
    local okB, bottom = pcall(control.GetBottom, control)
    if not okL or not okT or not okR or not okB then
        return nil
    end
    if type(left) ~= "number" or type(top) ~= "number" or type(right) ~= "number" or type(bottom) ~= "number" then
        return nil
    end
    local pixelW = right - left
    local pixelH = bottom - top
    local rect = {
        x = ((left + right) * 0.5) / width,
        y = ((top + bottom) * 0.5) / height,
    }
    if pixelW > 1 and pixelH > 1 then
        rect.w = pixelW / width
        rect.h = pixelH / height
    end
    return rect
end

function Adapter:GetNormalizedCenter(control)
    local rect = self:GetNormalizedRect(control)
    if not rect then
        return nil
    end
    return { x = rect.x, y = rect.y }
end

local function RelativeControlName(relativeTo)
    if relativeTo == nil then
        return "nil"
    end
    if relativeTo == GuiRoot then
        return "GuiRoot"
    end
    local relType = type(relativeTo)
    if relType ~= "userdata" and relType ~= "table" then
        return tostring(relativeTo)
    end
    if type(relativeTo.GetName) == "function" then
        local ok, name = pcall(relativeTo.GetName, relativeTo)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
    end
    return "rel"
end

function Adapter:DescribeAnchors(control)
    local anchors = self:Capture(control)
    if not anchors then
        return "none"
    end
    local parts = {}
    for index = 1, #anchors do
        local saved = anchors[index]
        parts[#parts + 1] = string.format(
            "%s->%s.%s (%.0f, %.0f)",
            Platform:PointName(saved[1]),
            RelativeControlName(saved[2]),
            Platform:PointName(saved[3]),
            saved[4] or 0,
            saved[5] or 0
        )
    end
    return table.concat(parts, "; ")
end

function Adapter:Apply(control, x, y, w, h)
    local width, height = self:GetScreenSize()
    if not control or not width then
        if Log then
            Log:Warn("Apply skipped: missing control or GuiRoot size")
        end
        return false
    end

    -- Snapshot native anchors/size so a failed SetAnchor can roll back
    -- after ClearAnchors (otherwise the control can float unanchored).
    local snapshot = self:Capture(control)

    -- Console HUD movers (FAB+) never unlock mouse-drag. Keep native bars
    -- non-movable even on Play Anywhere gamepad.
    if Platform and Platform.NeverMovable then
        Platform:NeverMovable(control)
    end

    -- Size first so TOPLEFT math uses the new box, not the pre-resize one.
    local controlWidth, controlHeight = self:GetControlSize(control)
    if type(w) == "number" and type(h) == "number" and w > 0 and h > 0 then
        controlWidth = w * width
        controlHeight = h * height
        Safe.Try(control, "SetDimensions", controlWidth, controlHeight)
    end

    local clearOk, clearErr = Safe.Try(control, "ClearAnchors")
    if not clearOk then
        if Log then
            Log:Warn("ClearAnchors failed: " .. Log:FormatValue(clearErr))
        end
        if snapshot then
            self:Restore(control, snapshot)
        end
        return false
    end

    -- Store normalized CENTER; apply as TOPLEFT pixels on GuiRoot (FAB+).
    -- CENTER+offset put 0.1.0 bars off-screen on console. If the control has
    -- no size yet (hidden), fall back to CENTER on the same TOPLEFT origin.
    local point = CENTER
    local offsetX = x * width
    local offsetY = y * height
    if controlWidth and controlHeight and controlWidth > 1 and controlHeight > 1 then
        point = TOPLEFT
        offsetX = offsetX - (controlWidth * 0.5)
        offsetY = offsetY - (controlHeight * 0.5)
    end

    local setOk, setErr = Safe.Try(control, "SetAnchor", point, GuiRoot, TOPLEFT, offsetX, offsetY)
    if not setOk then
        if Log then
            Log:Warn("SetAnchor failed for " .. Log:FormatValue(control) .. ": " .. Log:FormatValue(setErr))
        end
        if snapshot then
            self:Restore(control, snapshot)
        end
        return false
    end

    if Log then
        Log:Debug(string.format(
            "Apply %s %s -> (%.3f, %.3f) px=(%.0f, %.0f) size=%.0fx%.0f screen=%.0fx%.0f",
            Log:FormatValue(control),
            Platform:PointName(point),
            x,
            y,
            offsetX,
            offsetY,
            controlWidth or 0,
            controlHeight or 0,
            width,
            height
        ))
    end
    return true
end

-- Native target frame is TOP-anchored to GuiRoot TOP (offset 0, 88) so
-- name length, rank/level, difficulty brackets, and shrink/expand can
-- change width without the frame sliding sideways. Pinning TOPLEFT and
-- SetDimensions fights that and looks uncentered on alternate targets.
function Adapter:ApplyTopCentered(control, x, y)
    local width, height = self:GetScreenSize()
    if not control or not width or type(x) ~= "number" or type(y) ~= "number" then
        if Log then
            Log:Warn("ApplyTopCentered skipped: missing control, position, or GuiRoot size")
        end
        return false
    end

    local snapshot = self:Capture(control)
    if Platform and Platform.NeverMovable then
        Platform:NeverMovable(control)
    end

    local clearOk, clearErr = Safe.Try(control, "ClearAnchors")
    if not clearOk then
        if Log then
            Log:Warn("ClearAnchors failed: " .. Log:FormatValue(clearErr))
        end
        if snapshot then
            self:Restore(control, snapshot)
        end
        return false
    end

    local _, controlHeight = self:GetControlSize(control)
    local point = TOP
    local relPoint = TOP
    local offsetX = (x - 0.5) * width
    local offsetY = y * height
    if controlHeight and controlHeight > 1 then
        offsetY = offsetY - (controlHeight * 0.5)
    else
        point = CENTER
        relPoint = TOPLEFT
        offsetX = x * width
        offsetY = y * height
    end

    local setOk, setErr = Safe.Try(control, "SetAnchor", point, GuiRoot, relPoint, offsetX, offsetY)
    if not setOk then
        if Log then
            Log:Warn("SetAnchor failed for " .. Log:FormatValue(control) .. ": " .. Log:FormatValue(setErr))
        end
        if snapshot then
            self:Restore(control, snapshot)
        end
        return false
    end

    if Log then
        Log:Debug(string.format(
            "ApplyTopCentered %s %s -> (%.3f, %.3f) px=(%.0f, %.0f) screen=%.0fx%.0f",
            Log:FormatValue(control),
            Platform:PointName(point),
            x,
            y,
            offsetX,
            offsetY,
            width,
            height
        ))
    end
    return true
end

function Adapter:Restore(control, anchor)
    if not control or type(anchor) ~= "table" then
        return false
    end
    if type(anchor.width) == "number" and type(anchor.height) == "number"
        and anchor.width > 1 and anchor.height > 1 then
        Safe.Try(control, "SetDimensions", anchor.width, anchor.height)
    end
    if not Safe.Try(control, "ClearAnchors") then
        if Log then
            Log:Warn("Restore ClearAnchors failed for " .. Log:FormatValue(control))
        end
        return false
    end
    for _, savedAnchor in ipairs(anchor) do
        if not Safe.Try(control, "SetAnchor", unpack(savedAnchor)) then
            if Log then
                Log:Warn("Restore SetAnchor failed for " .. Log:FormatValue(control))
            end
            return false
        end
    end
    if Log then
        Log:Debug("Restored native anchors for " .. Log:FormatValue(control))
    end
    return true
end

function Adapter:ForceVisible(visible)
    local manager = PLAYER_ATTRIBUTE_BARS
    if not manager then
        if Log then
            Log:Warn("PLAYER_ATTRIBUTE_BARS missing; cannot ForceShow")
        end
        return false
    end
    if type(manager.ForceShow) ~= "function" then
        if Log then
            Log:Warn("PLAYER_ATTRIBUTE_BARS:ForceShow missing")
        end
        return false
    end
    local ok, err = pcall(manager.ForceShow, manager, visible)
    if Log then
        if ok then
            Log:Debug("ForceShow(" .. tostring(visible) .. ") ok")
        else
            Log:Warn("ForceShow failed: " .. Log:FormatValue(err))
        end
    end
    return ok
end

function Adapter:GetForceVisibility()
    local manager = PLAYER_ATTRIBUTE_BARS
    if not manager then
        return nil
    end
    for _, method in ipairs({ "IsForcedShown", "GetForceShow" }) do
        if type(manager[method]) == "function" then
            local ok, value = pcall(manager[method], manager)
            if ok and type(value) == "boolean" then
                return value
            end
        end
    end
    return nil
end

function Adapter:DescribeEnvironment()
    local width, height = self:GetScreenSize()
    local platform = Platform and Platform.Describe and Platform:Describe() or {}
    platform.guiRoot = GuiRoot ~= nil
    platform.playerAttributeBars = PLAYER_ATTRIBUTE_BARS ~= nil
    platform.forceShow = PLAYER_ATTRIBUTE_BARS and type(PLAYER_ATTRIBUTE_BARS.ForceShow) == "function"
    platform.zoPlayerAttribute = _G.ZO_PlayerAttribute ~= nil
    platform.zoHealth = _G.ZO_PlayerAttributeHealth ~= nil
    platform.zoMagicka = _G.ZO_PlayerAttributeMagicka ~= nil
    platform.zoStamina = _G.ZO_PlayerAttributeStamina ~= nil
    platform.gamepadChatSystem = _G.GAMEPAD_CHAT_SYSTEM ~= nil
    platform.zoGamepadTextChat = _G.ZO_GamepadTextChat ~= nil
    platform.screenWidth = width
    platform.screenHeight = height
    local Chat = ValknarrUIEGamepadChat
    if Chat and Chat.Describe then
        local chat = Chat:Describe()
        for key, value in pairs(chat) do
            platform["chat_" .. key] = value
        end
    end
    return platform
end

return Adapter
