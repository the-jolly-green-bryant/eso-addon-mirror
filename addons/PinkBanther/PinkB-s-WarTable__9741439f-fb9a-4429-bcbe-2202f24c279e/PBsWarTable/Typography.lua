-- Resolve the client's localized font rather than hard-coding a Latin font file.
-- ESO's native soft shadow blurs the shadow, keeping the glyph itself sharp.
local F={cache={}}; PBWT.Typography=F
function F.Apply(control,name,subtle)
    local style=subtle and 'soft-shadow-thin' or 'soft-shadow-thick'
    local key=name..':'..style
    local font=F.cache[key]
    if not font then
        local source=_G[name]
        if source and source.GetFontInfo then
            local face,size=source:GetFontInfo()
            if type(face)=='string' and face~='' and type(size)=='number' and size>0 then
                font=face..'|'..size..'|'..style
                F.cache[key]=font
            end
        end
        font=font or name -- Retain a working named font if resolution is unavailable.
    end
    if control.pbwtFont~=font then control:SetFont(font); control.pbwtFont=font end
end
