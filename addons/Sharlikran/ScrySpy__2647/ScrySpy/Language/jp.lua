-- by Snorunt361
local strings = {
  mod_title = "ScrySpy",
  map_pin_texture_text = "マップピン",
  map_pin_texture_desc = "マップ上に表示されるアイコンを設定します",
  digsite_texture_text = "3Dピンアイコン",
  digsite_texture_desc = "フィールド上の3Dピンに表示されるアイコンを設定します",
  pin_size = "マップピンのサイズ",
  pin_size_desc = "マップ上に表示されるピンのサイズを変更します",
  pin_layer = "マップピンの表示優先度",
  pin_layer_desc = "マップ上のアイコンを優先的に表示することができます",
  show_digsites_on_compas = "コンパスに表示",
  show_digsites_on_compas_desc = "発掘現場のアイコンをコンパスに表示することができます",
  compass_max_dist = "ピンの表示距離",
  compass_max_dist_desc = "コンパス上にピンを表示するまでの距離を設定します",
  spike_pincolor = "3Dピンの色",
  spike_pincolor_desc = "3Dピンの色を変更します",
}

for stringId, stringValue in pairs(strings) do
  SafeAddString(_G[stringId], stringValue, 1)
end
