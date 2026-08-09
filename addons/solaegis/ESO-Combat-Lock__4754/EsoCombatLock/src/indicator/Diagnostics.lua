-- EsoCombatLock - indicator diagnostics (/ecl testglow, /ecl halotex, debug)

local ECL = EsoCombatLock
ECL.Indicator = ECL.Indicator or {}
local Indicator = ECL.Indicator
Indicator.Diagnostics = Indicator.Diagnostics or {}
local Diagnostics = Indicator.Diagnostics
local State = Indicator.State

function Diagnostics.GetDebugState()
    local outer = Indicator.Halo.GetOuter()
    return {
        hidden = State.frame and State.frame:IsHidden(),
        show = Indicator.Visibility.ShouldShow(),
        playerInCombat = State.playerInCombat,
        apiInCombat = IsUnitInCombat and IsUnitInCombat("player"),
        armed = State.isGuardArmed(),
        hasActiveCompanion = State.hasActiveCompanion(),
        repositionMode = State.repositionMode,
        savedAlwaysVisible = State.savedIndicatorAlwaysVisible,
        combatHighlightVisible = outer and not outer:IsHidden(),
        combatHighlightPulsing = Indicator.Halo.IsPulsing(),
        forceCombatHighlight = State.forceCombatHighlight,
    }
end

local function callIfPresent(control, method)
    if control and control[method] then
        return control[method](control)
    end
    return nil
end

local function describeControl(label, control)
    if not control then
        return label .. "=nil"
    end
    return string.format(
        "%s{hidden=%s w=%s h=%s left=%s top=%s tier=%s layer=%s level=%s}",
        label,
        tostring(control:IsHidden()),
        tostring(zo_floor(control:GetWidth() or 0)),
        tostring(zo_floor(control:GetHeight() or 0)),
        tostring(zo_floor(control:GetLeft() or 0)),
        tostring(zo_floor(control:GetTop() or 0)),
        tostring(control:GetDrawTier()),
        tostring(control:GetDrawLayer()),
        tostring(callIfPresent(control, "GetDrawLevel"))
    )
end

function Diagnostics.DescribeHighlightControls()
    return {
        describeControl("frame", State.frame),
        describeControl("icon", State.iconTexture),
        describeControl("outer", Indicator.Halo.GetOuter()),
        describeControl("inner", Indicator.Halo.GetInner()),
        "texture=" .. tostring(Indicator.Halo.Texture()),
    }
end

--- Describes a texture path by what ESO actually loaded, not by the string that was
--- set. GetTextureFileName echoes any path back whether or not it resolved, so a
--- missing file looks healthy; measured dimensions are what distinguish the two.
local function describeTexturePath(label, path)
    if not path or path == "" then
        return label .. "=nil"
    end
    local ok, width, height = State.MeasureTexture(path)
    return string.format("%s=%s (%s)", label, path, ok and string.format("%dx%d", width, height) or "MISSING")
end

--- On-screen geometry for the combat Q park-preview icon (a child of the indicator
--- top-level window, anchored off the main icon). Real screen coordinates plus the
--- measured texture catch what unit tests cannot: wrong parent, off-screen anchoring,
--- zero size, or a texture path ESO failed to load. Each of those is a separate line,
--- so one /ecl tells them apart.
function Diagnostics.DescribeParkPreviewControl()
    local control = State.parkPreviewTexture
    local parent = callIfPresent(control, "GetParent")
    local r, g, b, a
    if control and control.GetColor then
        r, g, b, a = control:GetColor()
    end
    return {
        describeControl("icon", State.iconTexture),
        describeControl("parkPreview", control),
        describeTexturePath("parkPreviewTexturePath", callIfPresent(control, "GetTextureFileName")),
        "parkPreviewParent=" .. tostring(callIfPresent(parent, "GetName")),
        "parkPreviewParentIsIndicator=" .. tostring(parent ~= nil and parent == State.frame),
        describeTexturePath("emptyParkTexture", State.EMPTY_PARK_TEXTURE),
        string.format("parkPreviewColor=r=%s g=%s b=%s a=%s", tostring(r), tostring(g), tostring(b), tostring(a)),
    }
end

function Diagnostics.DescribeHaloTextures()
    local active = Indicator.Halo.Texture()
    local lines = {}
    for index, path in ipairs(Indicator.Halo.GetTextureList()) do
        local ok, width, height = Indicator.Halo.MeasureTexture(path)
        table.insert(
            lines,
            string.format(
                "%d%s %s (%s)",
                index,
                path == active and "*" or ".",
                path,
                ok and string.format("%dx%d", width, height) or "MISSING"
            )
        )
    end
    return lines
end
