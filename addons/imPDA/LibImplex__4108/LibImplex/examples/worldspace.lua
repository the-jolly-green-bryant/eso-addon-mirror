-- Go to Summerset, Alinor Wayshrine

local PI = math.pi

local Vector = LibImplex.Vector

local TEXTURES = LibImplex.Textures.Numbers
local ZONE_ID = 1011

local MARKER_POSITIONS = {
    --[[0]] {163311, 18355, 331544},
    --[[1]] {163555, 18355, 332016},
    --[[2]] {163799, 18355, 332488},
    --[[3]] {164043, 18355, 332960},
    --[[4]] {164287, 18355, 333432},
    --[[5]] {162877, 18355, 331769},
    --[[6]] {163121, 18355, 332241},
    --[[7]] {163365, 18355, 332713},
    --[[8]] {163609, 18355, 333185},
    --[[9]] {163853, 18355, 333657},
}

local TEXT_POSITION = Vector({164664, 18740, 336661})

local COLOR = {173 / 255, 216 / 255, 230 / 255}  -- #add8e6

local function placeMarkers()
    if GetZoneId(GetUnitZoneIndex('player')) ~= ZONE_ID then return end

    local wsTest = LibImplex.Marker('ws test')

    ----[[ Markers on the ground
    local ORIENTATION = {-PI * 0.5, -PI * 0.36, 0, true}
    for i = 1, #MARKER_POSITIONS do
        local m = wsTest._2DWS()
        m:SetPosition(unpack(MARKER_POSITIONS[i]))
        m:SetTexture(TEXTURES[i-1])
        m:SetDimensions(1.5, 1.5)
        m:SetRotation(unpack(ORIENTATION))

        local label1 = CreateControlFromVirtual('WS TEST LABEL', m.control, 'LibImplex_DefaultLabel', i*10+1)
        label1:SetAnchor(BOTTOM, m.control, TOP, 0, 0, 10)
        -- label:SetFont('$(MEDIUM_FONT)|$(KB_1)|soft-shadow-thin')
        label1:SetText('top')
        label1:SetScale(0.05)

        local label2 = CreateControlFromVirtual('WS TEST LABEL', m.control, 'LibImplex_DefaultLabel', i*10+2)
        label2:SetAnchor(TOP, m.control, BOTTOM, 0, 0)
        -- label:SetFont('$(MEDIUM_FONT)|$(KB_1)|soft-shadow-thin')
        label2:SetText('bottom')
        label2:SetScale(0.05)

        -- m.control:SetGradientColors(ORIENTATION_VERTICAL, 0, 1, 0, 1, 1, 0, 1, 1)
        -- m.control:SetPixelRoundingEnabled()
    end
    --]]

    --[[ Big text
    local LOREM_IPSUM = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut tempus laoreet efficitur. Sed nisl neque, pellentesque sit amet lectus sit amet, tempus pretium lorem. Aenean facilisis quam sed egestas dictum. Integer fringilla dui eu pharetra sodales. Maecenas auctor dictum est. Pellentesque urna quam, bibendum a finibus consequat, placerat vel neque. Sed consectetur quis leo in ullamcorper. Phasellus ultrices efficitur luctus. Sed id maximus purus. Morbi commodo velit vel velit cursus ultricies. In hac habitasse platea dictumst. Donec quis viverra odio, quis ornare lorem. Nunc eu ullamcorper est, at bibendum dui. Aenean lacinia orci ut efficitur consectetur. Vestibulum pretium arcu at mi pulvinar, vitae efficitur eros luctus. In sed eros at ex feugiat auctor. Cras vitae sodales quam. Morbi pharetra tincidunt pharetra. Donec dictum scelerisque nisi, in faucibus massa faucibus imperdiet. Phasellus pharetra nibh a ipsum tincidunt, ac sagittis mi efficitur. Integer a nulla fringilla, tincidunt ex quis, malesuada nisl. Nulla fermentum condimentum faucibus. Phasellus gravida massa id convallis consequat. Integer volutpat, ipsum et egestas ultricies, ligula diam ullamcorper est, sit amet rhoncus augue eros non velit. Nulla facilisi. Etiam lacinia odio in finibus bibendum. Duis maximus libero vel maximus condimentum. Sed id congue quam, ut eleifend lacus. Praesent fringilla ultrices venenatis. In elit lacus, euismod vitae ultrices nec, vulputate id libero. Integer efficitur tempus diam sed blandit. Vivamus id massa vel lectus eleifend viverra ac et sem. Mauris congue hendrerit lacus non facilisis. Nam volutpat erat sollicitudin pharetra sagittis. Aenean maximus eros sed risus fermentum blandit. Donec consequat libero in libero posuere condimentum. Integer sem est, blandit eu aliquet eu, volutpat non arcu. In dignissim nunc quis nisi tempus, ut dapibus quam pharetra. Cras sit amet velit eu elit sodales laoreet. Nulla accumsan nisl a enim facilisis, eu suscipit nunc rutrum. Sed vulputate mattis neque, non accumsan nulla condimentum sed. Morbi sollicitudin nisi lectus, vitae consectetur mi viverra a. Donec quis rutrum elit. Morbi at accumsan elit. Sed id elit aliquet, tempus nisi volutpat, pharetra leo. Duis a interdum enim.'

    local loremIpsum = LibImplex.Text(LOREM_IPSUM:sub(1), TOPLEFT, TEXT_POSITION + LibImplex.Vector({0.5, 6000, 0}), {PI / 3, 0.938 * PI, 0, true}, 1.3, COLOR, 4500)
    loremIpsum:Render()
    --]]

    --[[ Overlapping markers
    local USE_BUFFER = true

	local M1 = {162864, 18500, 333339}
	local M2 = {162550, 18500, 332985}
	local M3 = {162180, 18500, 332560}

    LibImplex.Marker.Marker3D(M1, {0, 0, 0, USE_BUFFER}, TEXTURES[1], {3, 3}, COLOR)
    LibImplex.Marker.Marker3D(M2, {0, 0, 0, USE_BUFFER}, TEXTURES[2], {3, 3}, COLOR)
    LibImplex.Marker.Marker3D(M3, {0, 0, 0, USE_BUFFER}, TEXTURES[3], {3, 3}, COLOR)
    --]]
end

do
    EVENT_MANAGER:RegisterForEvent('LIB_IMPLEX_EXAMPLES_WORLD_SPACE', EVENT_PLAYER_ACTIVATED, placeMarkers)
end