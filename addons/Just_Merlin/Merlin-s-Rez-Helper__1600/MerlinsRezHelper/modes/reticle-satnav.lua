local LIB = "Reticle Satnav"
local satnav = MERLINS_REZHELPER.Modes[LIB]
local arrow, right, ui;

if not satnav then

    satnav = MERLINS_REZHELPER.Modes:Register(LIB)

    function satnav:Init()

        ui = MERLINS_REZHELPER.UI
        arrow = ui:RequestTextureFrames({
            { Texture = "satnav/up.dds", Movable = true }
        })

    end

    function satnav:Unit()

        arrow = nil

    end

    function satnav:Update(state)

        if state.Hidden then
            arrow:SetAlpha(0)
            return
        end

        local d = state.Constants.GameReticleSize + state.Distance + (state.Size / 2)
        local x = math.sin(math.pi - state.Angle) * d
        local y = math.cos(math.pi - state.Angle) * d

        arrow:SetAnchor(CENTER, CENTER, x, y)
        arrow:SetTextureRotation((math.pi * 2) - state.Angle)
        arrow:SetDimensions(state.Size)
        arrow:SetColor(state.Color)
        arrow:SetAlpha(state.Alpha)

        if state.SetCloseIcon then
            arrow:SetTesoTexture("/esoui/art/icons/poi/poi_groupboss_incomplete.dds")
            arrow:SetTextureRotation(0)
        else
            arrow:SetTexture("satnav/up.dds")
        end

    end

end
