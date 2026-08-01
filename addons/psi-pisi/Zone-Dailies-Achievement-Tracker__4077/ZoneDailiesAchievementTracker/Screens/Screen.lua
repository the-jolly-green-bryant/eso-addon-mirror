-- Initialize File
ZDAT                 = ZDAT or {}
ZDAT.Screens         = ZDAT.Screens or {}
ZDAT.Screens.Screen  = {}

function ZDAT.Screens.Screen.initialize()
    local _v  = function() return true end
    local _is = ZDAT.UI.Constants.iconSize

    -- COLUMN 1
    -- headers
    local t = {{
      ZDAT.UI.Labels.basic{ v=_v,      f="ZoFontGameSmall", w=140,  t="ZONE",         tt="Zone"},
      ZDAT.UI.Misc.spacer{  v=_v, w=10},
      ZDAT.UI.Labels.basic{ v=_v,      f="ZoFontGameSmall", w=200,  t="ACHIEVEMENT",  tt="Achievement"},
      ZDAT.UI.Misc.spacer{  v=_v, w=10},
      ZDAT.UI.Labels.basic{ v=_v,      f="ZoFontGameSmall", w=_is,  t="T1",           tt="Tier I",              align=TEXT_ALIGN_CENTER},
      ZDAT.UI.Labels.basic{ v=_v,      f="ZoFontGameSmall", w=_is,  t="T2",           tt="Tier II",             align=TEXT_ALIGN_CENTER},
      ZDAT.UI.Labels.basic{ v=_v,      f="ZoFontGameSmall", w=_is,  t="T3",           tt="Tier III",            align=TEXT_ALIGN_CENTER},
      ZDAT.UI.Misc.spacer{  v=_v, w=10},
      ZDAT.UI.Labels.basic{ v=_v,      f="ZoFontGameSmall", w=_is,  t="DS",           tt="Daily Status",        align=TEXT_ALIGN_CENTER},
    }}

  -- create grid rows
    local rows = ZDAT.Data.Achievements.GetStatus()
    for _, row in pairs(rows) do
      if row.column == 1 then
        local current;
        if row.tierIII.completed then
          current = row.tierIII.id
        elseif row.tierII.completed then
          current = row.tierIII.id
        elseif row.tierI.completed then
          current = row.tierII.id
        else
          current = row.tierI.id
        end

        t[#t+1] =  {
          ZDAT.UI.Labels.teleport{    v=_v,     t=row.zone,         w=140, c=ZDAT.UI.Constants.rgbBlue, wayshrineId=row.wayshrineId},
          ZDAT.UI.Misc.spacer{        v=_v, w=10},
          ZDAT.UI.Labels.achievement{ v=_v,     t=row.tierIII.name, w=200, a=row.tierIII.id, c=ZDAT.UI.Constants.rgbBlue},
          ZDAT.UI.Misc.spacer{        v=_v, w=10},
          ZDAT.UI.Icons.achievement{  v=_v,     a=row.tierI.id,     l=current},
          ZDAT.UI.Icons.achievement{  v=_v,     a=row.tierII.id,    l=current},
          ZDAT.UI.Icons.achievement{  v=_v,     a=row.tierIII.id,   l=current},
          ZDAT.UI.Misc.spacer{  v=_v, w=10},
          ZDAT.UI.Icons.progress{     v=_v,     a=row.tierIII.id,   l=current, tt="Is completed today?"},
        }
      end
    end
    -- anchor grid
    ZDAT.UI.Layout.anchorGrid(t, ZDAT.UI.Layout.anchor(40, 60))

    -- COLUMN 2
    -- headers
    local t = {{
      ZDAT.UI.Labels.basic{ v=_v,      f="ZoFontGameSmall", w=140,  t="ZONE",         tt="Zone"},
      ZDAT.UI.Misc.spacer{  v=_v, w=10},
      ZDAT.UI.Labels.basic{ v=_v,      f="ZoFontGameSmall", w=200,  t="ACHIEVEMENT",  tt="Achievement"},
      ZDAT.UI.Misc.spacer{  v=_v, w=10},
      ZDAT.UI.Labels.basic{ v=_v,      f="ZoFontGameSmall", w=_is,  t="T1",           tt="Tier I",              align=TEXT_ALIGN_CENTER},
      ZDAT.UI.Labels.basic{ v=_v,      f="ZoFontGameSmall", w=_is,  t="T2",           tt="Tier II",             align=TEXT_ALIGN_CENTER},
      ZDAT.UI.Labels.basic{ v=_v,      f="ZoFontGameSmall", w=_is,  t="T3",           tt="Tier III",            align=TEXT_ALIGN_CENTER},
      ZDAT.UI.Misc.spacer{  v=_v, w=10},
      ZDAT.UI.Labels.basic{ v=_v,      f="ZoFontGameSmall", w=_is,  t="DS",           tt="Daily Status",        align=TEXT_ALIGN_CENTER},
      }}

  -- create grid rows
    local rows = ZDAT.Data.Achievements.GetStatus()
    for _, row in pairs(rows) do
      if row.column == 2 then
        local current;
        if row.tierIII.completed then
          current = row.tierIII.id
        elseif row.tierII.completed then
          current = row.tierIII.id
        elseif row.tierI.completed then
          current = row.tierII.id
        else
          current = row.tierI.id
        end

        t[#t+1] =  {
          ZDAT.UI.Labels.teleport{    v=_v,     t=row.zone,         w=140, c=ZDAT.UI.Constants.rgbBlue, wayshrineId=row.wayshrineId},
          ZDAT.UI.Misc.spacer{        v=_v, w=10},
          ZDAT.UI.Labels.achievement{ v=_v,     t=row.tierIII.name, w=200, a=row.tierIII.id, c=ZDAT.UI.Constants.rgbBlue},
          ZDAT.UI.Misc.spacer{        v=_v, w=10},
          ZDAT.UI.Icons.achievement{  v=_v,     a=row.tierI.id,     l=current},
          ZDAT.UI.Icons.achievement{  v=_v,     a=row.tierII.id,    l=current},
          ZDAT.UI.Icons.achievement{  v=_v,     a=row.tierIII.id,   l=current},
          ZDAT.UI.Misc.spacer{  v=_v, w=10},
          ZDAT.UI.Icons.progress{     v=_v,     a=row.tierIII.id,   l=current, tt="Is completed today?"},
        }
      end
    end
    -- anchor grid
    ZDAT.UI.Layout.anchorGrid(t, ZDAT.UI.Layout.anchor(570, 60))
end