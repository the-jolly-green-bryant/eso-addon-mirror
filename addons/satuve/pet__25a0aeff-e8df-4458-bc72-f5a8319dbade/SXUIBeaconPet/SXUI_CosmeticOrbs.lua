-- Cosmetic-only extensions. The approved original four remain in their old controller.
-- Authored once with irregular spacing inside an upper half-disc; no gameplay RNG.
SXUI_CosmeticOrbs={Count=32,ExtraCenters={
    {-134,173}, -- extra orb 5
    {-133,95}, -- extra orb 6
    {-93,30}, -- extra orb 7
    {-48,-25}, -- extra orb 8
    {19,-75}, -- extra orb 9
    {93,-86}, -- extra orb 10
    {169,-85}, -- extra orb 11
    {240,-69}, -- extra orb 12
    {304,-29}, -- extra orb 13
    {352,31}, -- extra orb 14
    {389,102}, -- extra orb 15
    {391,176}, -- extra orb 16
    {-41,131}, -- extra orb 17
    {138,-25}, -- extra orb 18
    {-23,20}, -- extra orb 19
    {251,-7}, -- extra orb 20
    {-46,76}, -- extra orb 21
    {283,52}, -- extra orb 22
    {-86,163}, -- extra orb 23
    {291,116}, -- extra orb 24
    {76,-29}, -- extra orb 25
    {283,163}, -- extra orb 26
    {25,13}, -- extra orb 27
    {329,160}, -- extra orb 28
    {-84,107}, -- extra orb 29
    {327,72}, -- extra orb 30
    {-22,173}, -- extra orb 31
    {205,-37}, -- extra orb 32
}}
local O=SXUI_CosmeticOrbs
-- Gentle multiplicative shades over the original gold, blue, violet and green art.
O.Tints={{1,.96,.91},{.92,.98,1},{.98,.93,1},{.92,1,.96}}

function O:Initialize(controller)
    for j,_ in ipairs(self.ExtraCenters) do
        local i=j+4
        controller.pose.orbs[i]={rune=(j-1)%4+1,alpha=1}
    end
end

function O:Update(controller,t)
    for j,center in ipairs(self.ExtraCenters) do
        local orb=controller.pose.orbs[j+4]
        local phase=j*2.399963
        orb.x=center[1]+1.8*math.sin(t*.23+phase)
        orb.y=center[2]+2.4*math.sin(t*.31+phase*.83)
        orb.size=33+(j%3-1)+.7*math.sin(t*.41+phase)
        orb.opacity=.80+.06*math.sin(t*.37+phase)
        orb.front=false
        -- Staggered, slow cosmetic rune fades; no shared RNG or data state.
        local period=11+(j%5)*1.1
        local cycle=t+phase
        local c=cycle%period
        orb.rune=(math.floor(cycle/period)+j-1)%4+1
        local fade=math.min(1,c,(period-c))
        orb.alpha=fade*fade*(3-2*fade)
    end
end
