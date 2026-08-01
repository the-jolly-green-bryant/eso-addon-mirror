SEH = SEH or {}
local SEH = SEH
SEH.Chimera = {}

function SEH.Chimera.AddChimeraPortalIcons()
  if SEH.savedVariables.showChimeraPortalIcons and SEH.hasOSI() then

    if table.getn(SEH.status.ChimeraWamasuIcon) == 0 then
      table.insert(SEH.status.ChimeraWamasuIcon, 
        OSI.CreatePositionIcon(
          182466,
          40391,
          222635,
          "SanitysEdgeHelper/icons/Wamasu.dds",
          2 * OSI.GetIconSize()))
    end

    if table.getn(SEH.status.ChimeraLionIcon) == 0 then
      table.insert(SEH.status.ChimeraLionIcon, 
        OSI.CreatePositionIcon(
          187456,
          40387,
          222644,
          "SanitysEdgeHelper/icons/Lion.dds",
          2 * OSI.GetIconSize()))
    end

    if table.getn(SEH.status.ChimeraGryphonIcon) == 0 then
      table.insert(SEH.status.ChimeraGryphonIcon, 
        OSI.CreatePositionIcon(
          185015,
          40390,
          228119,
          "SanitysEdgeHelper/icons/Gryphon.dds",
          2 * OSI.GetIconSize()))
    end
  end
end

function SEH.Chimera.RemoveChimeraPortalIcons()
  SEH.DiscardPositionIconList(SEH.status.ChimeraWamasuIcon)
  SEH.status.ChimeraWamasuIcon = {}

  SEH.DiscardPositionIconList(SEH.status.ChimeraLionIcon)
  SEH.status.ChimeraLionIcon = {}

  SEH.DiscardPositionIconList(SEH.status.ChimeraGryphonIcon)
  SEH.status.ChimeraGryphonIcon = {}
end

function SEH.Chimera.AddNonHM_CrystalNumberIcons()
  if SEH.savedVariables.showNonHM_CrystalNumberIcons and SEH.hasOSI() then

    if table.getn(SEH.status.ChimeraNonHM_Number1Icon) == 0 then
      for i=1,3 do
        table.insert(SEH.status.ChimeraNonHM_Number1Icon, 
          OSI.CreatePositionIcon(
            SEH.data.chimera_nonhm_number1_pos_list[i][1],
            SEH.data.chimera_nonhm_number1_pos_list[i][2],
            SEH.data.chimera_nonhm_number1_pos_list[i][3],
            "SanitysEdgeHelper/icons/1.dds",
            1 * OSI.GetIconSize()))
      end
    end

    if table.getn(SEH.status.ChimeraNonHM_Number2Icon) == 0 then
      for i=1,3 do
        table.insert(SEH.status.ChimeraNonHM_Number2Icon, 
          OSI.CreatePositionIcon(
            SEH.data.chimera_nonhm_number2_pos_list[i][1],
            SEH.data.chimera_nonhm_number2_pos_list[i][2],
            SEH.data.chimera_nonhm_number2_pos_list[i][3],
            "SanitysEdgeHelper/icons/2.dds",
            1 * OSI.GetIconSize()))
      end
    end

    if table.getn(SEH.status.ChimeraNonHM_Number3Icon) == 0 then
      for i=1,3 do
        table.insert(SEH.status.ChimeraNonHM_Number3Icon, 
          OSI.CreatePositionIcon(
            SEH.data.chimera_nonhm_number3_pos_list[i][1],
            SEH.data.chimera_nonhm_number3_pos_list[i][2],
            SEH.data.chimera_nonhm_number3_pos_list[i][3],
            "SanitysEdgeHelper/icons/3.dds",
            1 * OSI.GetIconSize()))
      end
    end

    if table.getn(SEH.status.ChimeraNonHM_Number4Icon) == 0 then
      for i=1,3 do
        table.insert(SEH.status.ChimeraNonHM_Number4Icon, 
          OSI.CreatePositionIcon(
            SEH.data.chimera_nonhm_number4_pos_list[i][1],
            SEH.data.chimera_nonhm_number4_pos_list[i][2],
            SEH.data.chimera_nonhm_number4_pos_list[i][3],
            "SanitysEdgeHelper/icons/4.dds",
            1 * OSI.GetIconSize()))
      end
    end
  end
end

function SEH.Chimera.RemoveNonHM_CrystalNumberIcons()
  SEH.DiscardPositionIconList(SEH.status.ChimeraNonHM_Number1Icon)
  SEH.status.ChimeraNonHM_Number1Icon = {}

  SEH.DiscardPositionIconList(SEH.status.ChimeraNonHM_Number2Icon)
  SEH.status.ChimeraNonHM_Number2Icon = {}

  SEH.DiscardPositionIconList(SEH.status.ChimeraNonHM_Number3Icon)
  SEH.status.ChimeraNonHM_Number3Icon = {}

  SEH.DiscardPositionIconList(SEH.status.ChimeraNonHM_Number4Icon)
  SEH.status.ChimeraNonHM_Number4Icon = {}
end

function SEH.Chimera.AddHM_CrystalNumberIcons()
  if SEH.savedVariables.showHM_CrystalNumberIcons and SEH.hasOSI() then

    if table.getn(SEH.status.ChimeraHM_Number1Icon) == 0 then
      for i=1,3 do
        table.insert(SEH.status.ChimeraHM_Number1Icon, 
          OSI.CreatePositionIcon(
            SEH.data.chimera_hm_number1_pos_list[i][1],
            SEH.data.chimera_hm_number1_pos_list[i][2],
            SEH.data.chimera_hm_number1_pos_list[i][3],
            "SanitysEdgeHelper/icons/1.dds",
            1 * OSI.GetIconSize()))
      end
    end

    if table.getn(SEH.status.ChimeraHM_Number2Icon) == 0 then
      for i=1,3 do
        table.insert(SEH.status.ChimeraHM_Number2Icon, 
          OSI.CreatePositionIcon(
            SEH.data.chimera_hm_number2_pos_list[i][1],
            SEH.data.chimera_hm_number2_pos_list[i][2],
            SEH.data.chimera_hm_number2_pos_list[i][3],
            "SanitysEdgeHelper/icons/2.dds",
            1 * OSI.GetIconSize()))
      end
    end

    if table.getn(SEH.status.ChimeraHM_Number3Icon) == 0 then
      for i=1,3 do
        table.insert(SEH.status.ChimeraHM_Number3Icon, 
          OSI.CreatePositionIcon(
            SEH.data.chimera_hm_number3_pos_list[i][1],
            SEH.data.chimera_hm_number3_pos_list[i][2],
            SEH.data.chimera_hm_number3_pos_list[i][3],
            "SanitysEdgeHelper/icons/3.dds",
            1 * OSI.GetIconSize()))
      end
    end

    if table.getn(SEH.status.ChimeraHM_Number4Icon) == 0 then
      for i=1,3 do
        table.insert(SEH.status.ChimeraHM_Number4Icon, 
          OSI.CreatePositionIcon(
            SEH.data.chimera_hm_number4_pos_list[i][1],
            SEH.data.chimera_hm_number4_pos_list[i][2],
            SEH.data.chimera_hm_number4_pos_list[i][3],
            "SanitysEdgeHelper/icons/4.dds",
            1 * OSI.GetIconSize()))
      end
    end

    if table.getn(SEH.status.ChimeraHM_Number5Icon) == 0 then
      for i=1,3 do
        table.insert(SEH.status.ChimeraHM_Number5Icon, 
          OSI.CreatePositionIcon(
            SEH.data.chimera_hm_number5_pos_list[i][1],
            SEH.data.chimera_hm_number5_pos_list[i][2],
            SEH.data.chimera_hm_number5_pos_list[i][3],
            "SanitysEdgeHelper/icons/5.dds",
            1 * OSI.GetIconSize()))
      end
    end
  end
end

function SEH.Chimera.RemoveHM_CrystalNumberIcons()
  SEH.DiscardPositionIconList(SEH.status.ChimeraHM_Number1Icon)
  SEH.status.ChimeraHM_Number1Icon = {}

  SEH.DiscardPositionIconList(SEH.status.ChimeraHM_Number2Icon)
  SEH.status.ChimeraHM_Number2Icon = {}

  SEH.DiscardPositionIconList(SEH.status.ChimeraHM_Number3Icon)
  SEH.status.ChimeraHM_Number3Icon = {}

  SEH.DiscardPositionIconList(SEH.status.ChimeraHM_Number4Icon)
  SEH.status.ChimeraHM_Number4Icon = {}

  SEH.DiscardPositionIconList(SEH.status.ChimeraHM_Number5Icon)
  SEH.status.ChimeraHM_Number5Icon = {}
end

function SEH.Chimera.ChainLightning(result, targetType, hitValue)
  if result == ACTION_RESULT_BEGIN and hitValue > 1000 then
    SEH.status.chimeraLastChainLightning = GetGameTimeSeconds()
    SEH.status.chimeraIsFirstChainLightning = false
    --SEH.Alert("Chimera", "Chain Lightning", 0xFFD666FF, abilityId, SOUNDS.OBJECTIVE_DISCOVERED, hitValue)
  end
end

function SEH.Chimera.Vivify(result, targetType, hitValue)
  SEH.status.chimeraSpawned = true
  SEH.status.chimeraIsFirstChainLightning = true
  SEH.status.chimeraSpawnTime = GetGameTimeSeconds()
  SEH.status.chimeraLastChainLightning = GetGameTimeSeconds()
end

function SEH.Chimera.Petrify(result, targetType, hitValue)
  SEH.status.chimeraSpawned = false
end

function SEH.Chimera.UpdateTick(timeSec)
  SEHStatus:SetHidden(not (SEH.savedVariables.showChimeraDespawnTimer or SEH.savedVariables.showChainLightning))
  SEH.Chimera.UpdateDespawnTick(timeSec)
  SEH.Chimera.UpdateChainLightningTick(timeSec)
end

function SEH.Chimera.UpdateDespawnTick(timeSec)
  SEHStatusLabelChimera1:SetHidden(not SEH.status.chimeraSpawned or not SEH.savedVariables.showChimeraDespawnTimer)
  SEHStatusLabelChimera1Value:SetHidden(not SEH.status.chimeraSpawned or not SEH.savedVariables.showChimeraDespawnTimer)

  if SEH.status.chimeraSpawned then
    local timeSinceSpawn = timeSec - SEH.status.chimeraSpawnTime
    local despawnTimeLeft = SEH.data.chimera_despawn_cd - timeSinceSpawn
    SEHStatusLabelChimera1Value:SetText(SEH.GetSecondsRemainingString(despawnTimeLeft))
  end
end

function SEH.Chimera.UpdateChainLightningTick(timeSec)
  SEHStatusLabelChimera2:SetHidden(not SEH.status.chimeraSpawned or not SEH.savedVariables.showChainLightning)
  SEHStatusLabelChimera2Value:SetHidden(not SEH.status.chimeraSpawned or not SEH.savedVariables.showChainLightning)
  
  if SEH.status.chimeraSpawned then
    local timeSinceLastChainLightning = timeSec - SEH.status.chimeraLastChainLightning

    local chainLightningTimeLeft = 0
    if SEH.status.chimeraIsFirstChainLightning then
      chainLightningTimeLeft = SEH.data.chimera_chain_lightning_first_cd - timeSinceLastChainLightning
    else
      chainLightningTimeLeft = SEH.data.chimera_chain_lightning_cd - timeSinceLastChainLightning
    end

    SEHStatusLabelChimera2Value:SetText(SEH.GetSecondsRemainingString(chainLightningTimeLeft))
  end
end
