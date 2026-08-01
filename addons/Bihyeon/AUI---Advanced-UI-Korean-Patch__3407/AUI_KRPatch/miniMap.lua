function AUI_KRPatch.setMinimapFont(fontPath)
  AUI.Settings.Minimap.location_fontArt = fontPath
  AUI.Settings.Minimap.coords_fontArt = fontPath
  AUI.Minimap.UI.Update()
end