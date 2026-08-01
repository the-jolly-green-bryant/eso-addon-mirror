AOCH = AOCH or {}
local AOCH = AOCH

-------------------------------------------- Trash
function AOCH.SetTrashNumberIcons() ----------------------- show pack numbers
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.trash_numbers_enabled then
    AOCH.status.trash_numbers_enabled = true
  else
    return
  end

  for i=1, AOCH.icons_data.num_pack_coords do
    table.insert(AOCH.status.trash_number_icons, OSI.CreatePositionIcon(
      AOCH.icons_data.pack_number_coords[i][1],
      AOCH.icons_data.pack_number_coords[i][2] + 400,
      AOCH.icons_data.pack_number_coords[i][3],
      AOCH.icons_data.pack_number_textures[i],
      OSI.GetIconSize() * 2))
  end
end

function AOCH.HideTrashNumberIcons()
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.trash_numbers_enabled then
    for _, icon in ipairs(AOCH.status.trash_number_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.trash_number_icons = {}
    AOCH.status.trash_numbers_enabled = false
  end
end

function AOCH.SetTrashStackIcons() ------------------------ show stack positions
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.trash_stacks_enabled then
    AOCH.status.trash_stacks_enabled = true
  else
    return
  end

  for _, coord in ipairs(AOCH.icons_data.trash_pack_stack_positions) do
    table.insert(AOCH.status.trash_stacks_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.stack_texture,
        OSI.GetIconSize()))
  end

  for _, coord in ipairs(AOCH.icons_data.trash_pack_ot_stack_positions) do
    table.insert(AOCH.status.trash_stacks_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.ot_stack_texture,
        OSI.GetIconSize()))
  end

end

function AOCH.HideTrashStackIcons()
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.trash_stacks_enabled then
    for _, icon in ipairs(AOCH.status.trash_stacks_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.trash_stacks_icons = {}
    AOCH.status.trash_stacks_enabled = false;
  end
end

function AOCH.SetTrashSlayerIcons() --------------------- show trash slayer positions
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.trash_slayers_enabled then
    AOCH.status.trash_slayers_enabled = true
  else
    return
  end

  for _, coord in ipairs(AOCH.icons_data.trash_pack_left_slayer_positions) do
    table.insert(AOCH.status.trash_slayer_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.left_slayer_texture,
        OSI.GetIconSize()))
  end

  for _, coord in ipairs(AOCH.icons_data.trash_pack_right_slayer_positions) do
    table.insert(AOCH.status.trash_slayer_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.right_slayer_texture,
        OSI.GetIconSize()))
  end
end

function AOCH.HideTrashSlayerIcons()
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.trash_slayers_enabled then
    for _, icon in ipairs(AOCH.status.trash_slayer_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.trash_slayer_icons = {}
    AOCH.status.trash_slayers_enabled = false
  end
end

--------------------------------------- Mini bosses
function AOCH.SetMiniBossIcons()
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.mini_bosses_markers_enabled then
    AOCH.status.mini_bosses_markers_enabled = true
  else
    return
  end

  for _, coord in ipairs(AOCH.icons_data.mini_boss_stack_positions) do
    table.insert(AOCH.status.mini_boss_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.stack_texture,
        OSI.GetIconSize()))
  end

  for _, coord in ipairs(AOCH.icons_data.mini_boss_left_slayer_positions) do
    table.insert(AOCH.status.mini_boss_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.left_slayer_texture,
        OSI.GetIconSize()))
  end

  for _, coord in ipairs(AOCH.icons_data.mini_boss_right_slayer_positions) do
    table.insert(AOCH.status.mini_boss_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.right_slayer_texture,
        OSI.GetIconSize()))
  end

  table.insert(AOCH.status.mini_boss_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.witch_phantom_left_back[1],
    AOCH.icons_data.witch_phantom_left_back[2],
    AOCH.icons_data.witch_phantom_left_back[3],
    AOCH.icons_data.phantom_left_back_texture,
    OSI.GetIconSize()))
  table.insert(AOCH.status.mini_boss_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.witch_phantom_left_front[1],
    AOCH.icons_data.witch_phantom_left_front[2],
    AOCH.icons_data.witch_phantom_left_front[3],
    AOCH.icons_data.phantom_left_front_texture,
    OSI.GetIconSize()))
  table.insert(AOCH.status.mini_boss_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.witch_phantom_right_back[1],
    AOCH.icons_data.witch_phantom_right_back[2],
    AOCH.icons_data.witch_phantom_right_back[3],
    AOCH.icons_data.phantom_right_back_texture,
    OSI.GetIconSize()))
  table.insert(AOCH.status.mini_boss_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.witch_phantom_right_front[1],
    AOCH.icons_data.witch_phantom_right_front[2],
    AOCH.icons_data.witch_phantom_right_front[3],
    AOCH.icons_data.phantom_right_front_texture,
    OSI.GetIconSize()))
end

function AOCH.HideMiniBossIcons()
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.mini_bosses_markers_enabled then
    for _, icon in ipairs(AOCH.status.mini_boss_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.mini_boss_icons = {}
    AOCH.status.mini_bosses_markers_enabled = false
  end
end

------------------------------------------- Fleshcraft
function AOCH.SetFleshcraftStackIcons()
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.fleshcraft_stacks_enabled then
    AOCH.status.fleshcraft_stacks_enabled = true
  else
    return
  end

  local coords_table = {}
  if AOCH.savedVariables.show_hall_of_flesh_arcanist_positions then
    coords_table = AOCH.icons_data.hall_of_flesh_stack_positions_arc
  else
    coords_table = AOCH.icons_data.hall_of_flesh_stack_positions
  end

  for _, coord in ipairs(coords_table) do
    table.insert(AOCH.status.fleshcraft_stack_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.stack_texture,
        OSI.GetIconSize()))
  end
end

function AOCH.HideFleshcraftStackIcons()
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.fleshcraft_stacks_enabled then
    for _, icon in ipairs(AOCH.status.fleshcraft_stack_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.fleshcraft_stack_icons = {}
    AOCH.status.fleshcraft_stacks_enabled = false
  end
end

function AOCH.SetFleshcraftSlayerIcons()
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.fleshcraft_slayers_enabled then
    AOCH.status.fleshcraft_slayers_enabled = true
  else
    return
  end

  local coords_table = {}
  if AOCH.savedVariables.show_hall_of_flesh_arcanist_positions then
    coords_table = AOCH.icons_data.hall_of_flesh_left_slayer_positions_arc
  else
    coords_table = AOCH.icons_data.hall_of_flesh_left_slayer_positions
  end

  for _, coord in ipairs(coords_table) do
    table.insert(AOCH.status.fleshcraft_slayer_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.left_slayer_texture,
        OSI.GetIconSize()))
  end

  if AOCH.savedVariables.show_hall_of_flesh_arcanist_positions then
    coords_table = AOCH.icons_data.hall_of_flesh_right_slayer_positions_arc
  else
    coords_table = AOCH.icons_data.hall_of_flesh_right_slayer_positions
  end

  for _, coord in ipairs(coords_table) do
    table.insert(AOCH.status.fleshcraft_slayer_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.right_slayer_texture,
        OSI.GetIconSize()))
  end
end

function AOCH.HideFleshcraftSlayerIcons()
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.fleshcraft_slayers_enabled then
    for _, icon in ipairs(AOCH.status.fleshcraft_slayer_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.fleshcraft_slayer_icons = {}
    AOCH.status.fleshcraft_slayers_enabled = false
  end
end

function AOCH.SetFleshcraftAddIcons()
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.fleshcraft_add_markers_enabled then
    AOCH.status.fleshcraft_add_markers_enabled = true
  else
    return
  end

  table.insert(AOCH.status.fleshcraft_add_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.hall_of_flesh_add_spawn_locations[1][1],
    AOCH.icons_data.hall_of_flesh_add_spawn_locations[1][2],
    AOCH.icons_data.hall_of_flesh_add_spawn_locations[1][3],
        AOCH.icons_data.harvester_spawn_texture_1,
        OSI.GetIconSize()))
  table.insert(AOCH.status.fleshcraft_add_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.hall_of_flesh_add_spawn_locations[2][1],
    AOCH.icons_data.hall_of_flesh_add_spawn_locations[2][2],
    AOCH.icons_data.hall_of_flesh_add_spawn_locations[2][3],
        AOCH.icons_data.harvester_spawn_texture_2,
        OSI.GetIconSize()))
end

function AOCH.HideFleshcraftAddIcons()
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.fleshcraft_add_markers_enabled then
    for _, icon in ipairs(AOCH.status.fleshcraft_add_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.fleshcraft_add_icons = {}
    AOCH.status.fleshcraft_add_markers_enabled = false
  end
end

--------------------------------------- jynorah and Skorknif

function AOCH.SetJynorahStackIcons() --------------------- boss stacks
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.jynorah_stacks_enabled then
    AOCH.status.jynorah_stacks_enabled = true
  else
    return
  end

  for _, coord in ipairs(AOCH.icons_data.jynorah_blue_boss_positions) do
    table.insert(AOCH.status.jynorah_stacks_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.jynorah_stack_texture,
        OSI.GetIconSize()))
  end
  for _, coord in ipairs(AOCH.icons_data.jynorah_red_boss_positions) do
    table.insert(AOCH.status.jynorah_stacks_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.skorknif_stack_texture,
        OSI.GetIconSize()))
  end
end

function AOCH.HideJynorahStackIcons()
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.jynorah_stacks_enabled then
    for _, icon in ipairs(AOCH.status.jynorah_stacks_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.jynorah_stacks_icons = {}
    AOCH.status.jynorah_stacks_enabled = false
  end
end

function AOCH.SetJynorahExitIcon() -------------------- Exit icon
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.jynorah_exit_icon_enabled then
    AOCH.status.jynorah_exit_icon_enabled = true
  else
    return
  end

  AOCH.status.jynorah_exit_icon = OSI.CreatePositionIcon(
        AOCH.icons_data.jynorah_exit_position[1],
        AOCH.icons_data.jynorah_exit_position[2],
        AOCH.icons_data.jynorah_exit_position[3],
        AOCH.icons_data.exit_texture,
        AOCH.savedVariables.jynorah_exit_icon_size)
end

function AOCH.HideJynorahExitIcon()
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.jynorah_exit_icon_enabled then

    if AOCH.status.jynorah_exit_icon ~= nil then
      OSI.DiscardPositionIcon(AOCH.status.jynorah_exit_icon)
    end

    AOCH.status.jynorah_exit_icon = nil
    AOCH.status.jynorah_exit_icon_enabled = false
  end
end

function AOCH.SetJynorahCurseIcons() ----------------------------- curse icons
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.is_hm_boss and not AOCH.status.jynorah_curse_markers_enabled then
    AOCH.status.jynorah_curse_markers_enabled = true
  else
    return
  end

  for _, coord in ipairs(AOCH.icons_data.jynorah_blue_healer_positions) do -- healer blue
    table.insert(AOCH.status.jynorah_curse_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.healer_blue_texture,
        OSI.GetIconSize()))
  end
  for _, coord in ipairs(AOCH.icons_data.jynorah_red_healer_positions) do -- healer red
    table.insert(AOCH.status.jynorah_curse_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.healer_red_texture,
        OSI.GetIconSize()))
  end
  for _, coord in ipairs(AOCH.icons_data.jynorah_blue_dd1_positions) do -- dd 1 blue
    table.insert(AOCH.status.jynorah_curse_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.dd_blue_1_texture,
        OSI.GetIconSize()))
  end
  for _, coord in ipairs(AOCH.icons_data.jynorah_blue_dd2_positions) do -- dd 2 blue
    table.insert(AOCH.status.jynorah_curse_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.dd_blue_2_texture,
        OSI.GetIconSize()))
  end
  for _, coord in ipairs(AOCH.icons_data.jynorah_blue_dd3_positions) do -- dd 3 blue
    table.insert(AOCH.status.jynorah_curse_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.dd_blue_3_texture,
        OSI.GetIconSize()))
  end
  for _, coord in ipairs(AOCH.icons_data.jynorah_blue_dd4_positions) do -- dd 4 blue
    table.insert(AOCH.status.jynorah_curse_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.dd_blue_4_texture,
        OSI.GetIconSize()))
  end
  for _, coord in ipairs(AOCH.icons_data.jynorah_red_dd1_positions) do -- dd 1 red
    table.insert(AOCH.status.jynorah_curse_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.dd_red_1_texture,
        OSI.GetIconSize()))
  end
  for _, coord in ipairs(AOCH.icons_data.jynorah_red_dd2_positions) do -- dd 2 red
    table.insert(AOCH.status.jynorah_curse_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.dd_red_2_texture,
        OSI.GetIconSize()))
  end
  for _, coord in ipairs(AOCH.icons_data.jynorah_red_dd3_positions) do -- dd 3 red
    table.insert(AOCH.status.jynorah_curse_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.dd_red_3_texture,
        OSI.GetIconSize()))
  end
  for _, coord in ipairs(AOCH.icons_data.jynorah_red_dd4_positions) do -- dd 4 red
    table.insert(AOCH.status.jynorah_curse_icons, OSI.CreatePositionIcon(
        coord[1],
        coord[2],
        coord[3],
        AOCH.icons_data.dd_red_4_texture,
        OSI.GetIconSize()))
  end
end

function AOCH.HideJynorahCurseIcons()
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.jynorah_curse_markers_enabled then
    for _, icon in ipairs(AOCH.status.jynorah_curse_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.jynorah_curse_icons = {}
    AOCH.status.jynorah_curse_markers_enabled = false
  end
end

--------------------------------------- Overfiend Kazpian

function SetKazpianEntranceStackIcons() --------------------- entrance boss stacks
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.kazpian_entrance_stacks_enabled then
    AOCH.status.kazpian_entrance_stacks_enabled = true
  else
    return
  end

  table.insert(AOCH.status.kazpian_entrance_stack_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.kazpian_entrance_stack_pos[1],
    AOCH.icons_data.kazpian_entrance_stack_pos[2],
    AOCH.icons_data.kazpian_entrance_stack_pos[3],
    AOCH.icons_data.stack_texture,
    OSI.GetIconSize()))
end

function SetKazpianLowWardenStackIcons() --------------------- low warden boss stacks
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.kazpian_low_warden_stacks_enabled then
    AOCH.status.kazpian_low_warden_stacks_enabled = true
  else
    return
  end

  table.insert(AOCH.status.kazpian_low_warden_stack_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.kazpian_low_warden_boss_pos[1],
    AOCH.icons_data.kazpian_low_warden_boss_pos[2],
    AOCH.icons_data.kazpian_low_warden_boss_pos[3],
    AOCH.icons_data.kazpian_stack_texture,
    OSI.GetIconSize()))

  table.insert(AOCH.status.kazpian_low_warden_stack_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.kazpian_low_warden_add_pos[1],
    AOCH.icons_data.kazpian_low_warden_add_pos[2],
    AOCH.icons_data.kazpian_low_warden_add_pos[3],
    AOCH.icons_data.low_warden_stack_texture,
    OSI.GetIconSize()))
end

function SetKazpianMolagKenaStackIcons() --------------------- molag kena boss stacks
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.kazpian_molag_kena_stacks_enabled then
    AOCH.status.kazpian_molag_kena_stacks_enabled = true
  else
    return
  end

  table.insert(AOCH.status.kazpian_molag_kena_stack_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.kazpian_molag_kena_boss_pos[1],
    AOCH.icons_data.kazpian_molag_kena_boss_pos[2],
    AOCH.icons_data.kazpian_molag_kena_boss_pos[3],
    AOCH.icons_data.kazpian_stack_texture,
    OSI.GetIconSize()))

  table.insert(AOCH.status.kazpian_molag_kena_stack_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.kazpian_molag_kena_add_pos[1],
    AOCH.icons_data.kazpian_molag_kena_add_pos[2],
    AOCH.icons_data.kazpian_molag_kena_add_pos[3],
    AOCH.icons_data.molag_kena_stack_texture,
    OSI.GetIconSize()))
end

function SetKazpianKrogoStackIcons() --------------------- krogo boss stacks
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.kazpian_krogo_stacks_enabled then
    AOCH.status.kazpian_krogo_stacks_enabled = true
  else
    return
  end

  table.insert(AOCH.status.kazpian_krogo_stack_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.kazpian_krogo_boss_pos[1],
    AOCH.icons_data.kazpian_krogo_boss_pos[2],
    AOCH.icons_data.kazpian_krogo_boss_pos[3],
    AOCH.icons_data.kazpian_stack_texture,
    OSI.GetIconSize()))

  table.insert(AOCH.status.kazpian_krogo_stack_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.kazpian_krogo_add_pos[1],
    AOCH.icons_data.kazpian_krogo_add_pos[2],
    AOCH.icons_data.kazpian_krogo_add_pos[3],
    AOCH.icons_data.krogo_stack_texture,
    OSI.GetIconSize()))
end

function HideKazpianEntranceStackIcons() --------------------hide kazpian entrance boss stacks
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.kazpian_entrance_stacks_enabled  then
    for _, icon in ipairs(AOCH.status.kazpian_entrance_stack_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.kazpian_entrance_stack_icons = {}
    AOCH.status.kazpian_entrance_stacks_enabled = false
  end
end

function HideKazpianLowWardenStackIcons() --------------------hide kazpian low warden boss stacks
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.kazpian_low_warden_stacks_enabled  then
    for _, icon in ipairs(AOCH.status.kazpian_low_warden_stack_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.kazpian_low_warden_stack_icons = {}
    AOCH.status.kazpian_low_warden_stacks_enabled = false
  end
end

function HideKazpianMolagKenaStackIcons() --------------------hide kazpian molag kena boss stacks
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.kazpian_molag_kena_stacks_enabled  then
    for _, icon in ipairs(AOCH.status.kazpian_molag_kena_stack_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.kazpian_molag_kena_stack_icons = {}
    AOCH.status.kazpian_molag_kena_stacks_enabled = false
  end
end

function HideKazpianKrogoStackIcons() --------------------hide kazpian krogo boss stacks
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.kazpian_krogo_stacks_enabled  then
    for _, icon in ipairs(AOCH.status.kazpian_krogo_stack_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.kazpian_krogo_stacks_enabled = {}
    AOCH.status.kazpian_krogo_stacks_enabled = false
  end
end

function SetKazpianEntanceSlayerIcons() --------------------- entrance slayer stacks
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.kazpian_entrance_slayers_enabled then
    AOCH.status.kazpian_entrance_slayers_enabled = true
  else
    return
  end

  table.insert(AOCH.status.kazpian_entrance_slayer_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.kazpian_entrance_left_slayer_pos[1],
    AOCH.icons_data.kazpian_entrance_left_slayer_pos[2],
    AOCH.icons_data.kazpian_entrance_left_slayer_pos[3],
    AOCH.icons_data.left_slayer_texture,
    OSI.GetIconSize()))

    table.insert(AOCH.status.kazpian_entrance_slayer_icons, OSI.CreatePositionIcon(
      AOCH.icons_data.kazpian_entrance_right_slayer_pos[1],
      AOCH.icons_data.kazpian_entrance_right_slayer_pos[2],
      AOCH.icons_data.kazpian_entrance_right_slayer_pos[3],
      AOCH.icons_data.right_slayer_texture,
      OSI.GetIconSize()))
end

function SetKazpianLowWardenSlayerIcons() --------------------- low warden slayer stacks
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.kazpian_low_warden_slayers_enabled then
    AOCH.status.kazpian_low_warden_slayers_enabled = true
  else
    return
  end

  table.insert(AOCH.status.kazpian_low_warden_slayer_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.kazpian_low_warden_left_slayer_pos[1],
    AOCH.icons_data.kazpian_low_warden_left_slayer_pos[2],
    AOCH.icons_data.kazpian_low_warden_left_slayer_pos[3],
    AOCH.icons_data.left_slayer_texture,
    OSI.GetIconSize()))

    table.insert(AOCH.status.kazpian_low_warden_slayer_icons, OSI.CreatePositionIcon(
      AOCH.icons_data.kazpian_low_warden_right_slayer_pos[1],
      AOCH.icons_data.kazpian_low_warden_right_slayer_pos[2],
      AOCH.icons_data.kazpian_low_warden_right_slayer_pos[3],
      AOCH.icons_data.right_slayer_texture,
      OSI.GetIconSize()))
end

function SetKazpianMolagKenaSlayerIcons() --------------------- molag kena slayer stacks
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.kazpian_molag_kena_slayers_enabled then
    AOCH.status.kazpian_molag_kena_slayers_enabled = true
  else
    return
  end

  table.insert(AOCH.status.kazpian_molag_kena_slayer_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.kazpian_molag_kena_left_slayer_pos[1],
    AOCH.icons_data.kazpian_molag_kena_left_slayer_pos[2],
    AOCH.icons_data.kazpian_molag_kena_left_slayer_pos[3],
    AOCH.icons_data.left_slayer_texture,
    OSI.GetIconSize()))

    table.insert(AOCH.status.kazpian_molag_kena_slayer_icons, OSI.CreatePositionIcon(
      AOCH.icons_data.kazpian_molag_kena_right_slayer_pos[1],
      AOCH.icons_data.kazpian_molag_kena_right_slayer_pos[2],
      AOCH.icons_data.kazpian_molag_kena_right_slayer_pos[3],
      AOCH.icons_data.right_slayer_texture,
      OSI.GetIconSize()))
end

function SetKazpianKrogoSlayerIcons() --------------------- krogo slayer stacks
  if not AOCH.hasOSI() then
    return
  end
  if not AOCH.status.kazpian_krogo_slayers_enabled then
    AOCH.status.kazpian_krogo_slayers_enabled = true
  else
    return
  end

  table.insert(AOCH.status.kazpian_krogo_slayer_icons, OSI.CreatePositionIcon(
    AOCH.icons_data.kazpian_krogo_left_slayer_pos[1],
    AOCH.icons_data.kazpian_krogo_left_slayer_pos[2],
    AOCH.icons_data.kazpian_krogo_left_slayer_pos[3],
    AOCH.icons_data.left_slayer_texture,
    OSI.GetIconSize()))

    table.insert(AOCH.status.kazpian_krogo_slayer_icons, OSI.CreatePositionIcon(
      AOCH.icons_data.kazpian_krogo_right_slayer_pos[1],
      AOCH.icons_data.kazpian_krogo_right_slayer_pos[2],
      AOCH.icons_data.kazpian_krogo_right_slayer_pos[3],
      AOCH.icons_data.right_slayer_texture,
      OSI.GetIconSize()))
end

function HideKazpianEntranceSlayerStackIcons() --------------------hide kazpian entrance slayer stacks
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.kazpian_entrance_slayers_enabled then
    for _, icon in ipairs(AOCH.status.kazpian_entrance_slayer_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.kazpian_entrance_slayer_icons = {}
    AOCH.status.kazpian_entrance_slayers_enabled = false
  end
end

function HideKazpianLowWardenSlayerStackIcons() --------------------hide kazpian low warden slayer stacks
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.kazpian_low_warden_slayers_enabled then
    for _, icon in ipairs(AOCH.status.kazpian_low_warden_slayer_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.kazpian_low_warden_slayer_icons = {}
    AOCH.status.kazpian_low_warden_slayers_enabled = false
  end
end

function HideKazpianMolagKenaSlayerStackIcons() --------------------hide kazpian molag kena slayer stacks
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.kazpian_molag_kena_slayers_enabled then
    for _, icon in ipairs(AOCH.status.kazpian_molag_kena_slayer_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.kazpian_molag_kena_slayer_icons = {}
    AOCH.status.kazpian_molag_kena_slayers_enabled = false
  end
end

function HideKazpianKrogoSlayerStackIcons() --------------------hide kazpian krogo slayer stacks
  if not AOCH.hasOSI() then
    return
  end
  if AOCH.status.kazpian_krogo_slayers_enabled then
    for _, icon in ipairs(AOCH.status.kazpian_krogo_slayer_icons) do
      if icon ~= nil then
        OSI.DiscardPositionIcon(icon)
      end
    end
    AOCH.status.kazpian_krogo_slayer_icons = {}
    AOCH.status.kazpian_krogo_slayers_enabled = false
  end
end

function AOCH.HideKazpianIcons()
  HideKazpianEntranceStackIcons()
  HideKazpianLowWardenStackIcons()
  HideKazpianMolagKenaStackIcons()
  HideKazpianKrogoStackIcons()
  HideKazpianEntranceSlayerStackIcons()
  HideKazpianLowWardenSlayerStackIcons()
  HideKazpianMolagKenaSlayerStackIcons()
  HideKazpianKrogoSlayerStackIcons()
end

function AOCH.SetTrashIcons()
  if AOCH.savedVariables.show_trash_pack_icons then
    AOCH.SetTrashNumberIcons()
  end
  if AOCH.savedVariables.show_trash_stack_positions then
    AOCH.SetTrashStackIcons()
  end
  if AOCH.savedVariables.show_trash_slayer_positions then
    AOCH.SetTrashSlayerIcons()
  end
  
  AOCH.HideMiniBossIcons()

  AOCH.HideFleshcraftStackIcons()
  AOCH.HideFleshcraftAddIcons()
  AOCH.HideFleshcraftSlayerIcons()

  AOCH.HideJynorahStackIcons()
  AOCH.HideJynorahCurseIcons()
  AOCH.HideJynorahExitIcon()

  AOCH.HideKazpianIcons()
end

function AOCH.SetGlobalMiniBossIcons()
  if AOCH.savedVariables.show_mini_boss_markers then
    AOCH.SetMiniBossIcons()
  end
  
  AOCH.HideTrashNumberIcons()
  AOCH.HideTrashStackIcons()
  AOCH.HideTrashSlayerIcons()

  AOCH.HideFleshcraftStackIcons()
  AOCH.HideFleshcraftAddIcons()
  AOCH.HideFleshcraftSlayerIcons()

  AOCH.HideJynorahStackIcons()
  AOCH.HideJynorahCurseIcons()
  AOCH.HideJynorahExitIcon()

  AOCH.HideKazpianIcons()
end

function AOCH.SetHallOfFleshcraftIcons()
  if AOCH.savedVariables.show_hall_of_flesh_stack_positions then
    AOCH.SetFleshcraftStackIcons()
  end
  if AOCH.savedVariables.show_hall_of_flesh_add_positions then
    AOCH.SetFleshcraftAddIcons()
  end
  if AOCH.savedVariables.show_hall_of_flesh_slayer_positions then
    AOCH.SetFleshcraftSlayerIcons()
  end
  
  AOCH.HideTrashNumberIcons()
  AOCH.HideTrashStackIcons()
  AOCH.HideTrashSlayerIcons()

  AOCH.HideMiniBossIcons()

  AOCH.HideJynorahStackIcons()
  AOCH.HideJynorahCurseIcons()
  AOCH.HideJynorahExitIcon()

  AOCH.HideKazpianIcons()
end

function AOCH.SetJynorahIcons()
  if AOCH.savedVariables.show_jynorah_boss_positions then
    AOCH.SetJynorahStackIcons()
  end
  if AOCH.savedVariables.show_jynorah_curse_positions then
    AOCH.SetJynorahCurseIcons()
  end
  if AOCH.savedVariables.show_jynorah_exit_icon then
    AOCH.SetJynorahExitIcon()
  end
  
  AOCH.HideTrashNumberIcons()
  AOCH.HideTrashStackIcons()
  AOCH.HideTrashSlayerIcons()

  AOCH.HideMiniBossIcons()

  AOCH.HideFleshcraftStackIcons()
  AOCH.HideFleshcraftAddIcons()
  AOCH.HideFleshcraftSlayerIcons()

  AOCH.HideKazpianIcons()
end

function AOCH.SetKazpianIcons()
  if AOCH.savedVariables.show_kazpian_stack_positions then
    if AOCH.status.is_kazpian_start_arena then
      SetKazpianEntranceStackIcons()
      HideKazpianMolagKenaStackIcons()
      HideKazpianLowWardenStackIcons()
      HideKazpianKrogoStackIcons()
    elseif AOCH.status.is_low_warden_arena then
      HideKazpianEntranceStackIcons()
      SetKazpianLowWardenStackIcons()
      HideKazpianMolagKenaStackIcons()
      HideKazpianKrogoStackIcons()
    elseif AOCH.status.is_molag_kena_arena then
      HideKazpianEntranceStackIcons()
      HideKazpianLowWardenStackIcons()
      SetKazpianMolagKenaStackIcons()
      HideKazpianKrogoStackIcons()
    elseif AOCH.status.is_krogo_arena then
      HideKazpianEntranceStackIcons()
      HideKazpianMolagKenaStackIcons()
      HideKazpianLowWardenStackIcons()
      SetKazpianKrogoStackIcons()
    end
  end

  if AOCH.savedVariables.show_kazpian_slayer_positions then
    if AOCH.status.is_kazpian_start_arena then
      SetKazpianEntanceSlayerIcons()
      HideKazpianLowWardenSlayerStackIcons()
      HideKazpianMolagKenaSlayerStackIcons()
      HideKazpianKrogoSlayerStackIcons()
    elseif AOCH.status.is_low_warden_arena then
      HideKazpianEntranceSlayerStackIcons()
      SetKazpianLowWardenSlayerIcons()
      HideKazpianMolagKenaSlayerStackIcons()
      HideKazpianKrogoSlayerStackIcons()
    elseif AOCH.status.is_molag_kena_arena then
      HideKazpianEntranceSlayerStackIcons()
      HideKazpianLowWardenSlayerStackIcons()
      SetKazpianMolagKenaSlayerIcons()
      HideKazpianKrogoSlayerStackIcons()
    elseif AOCH.status.is_krogo_arena then
      HideKazpianEntranceSlayerStackIcons()
      HideKazpianLowWardenSlayerStackIcons()
      HideKazpianMolagKenaSlayerStackIcons()
      SetKazpianKrogoSlayerIcons()
    end
  end
  
  AOCH.HideTrashNumberIcons()
  AOCH.HideTrashStackIcons()
  AOCH.HideTrashSlayerIcons()

  AOCH.HideMiniBossIcons()

  AOCH.HideFleshcraftStackIcons()
  AOCH.HideFleshcraftAddIcons()
  AOCH.HideFleshcraftSlayerIcons()

  AOCH.HideJynorahStackIcons()
  AOCH.HideJynorahCurseIcons()
  AOCH.HideJynorahExitIcon()
end