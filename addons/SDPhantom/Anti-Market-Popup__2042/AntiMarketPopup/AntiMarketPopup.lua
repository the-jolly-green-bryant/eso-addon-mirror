--[[	Anti Market Popup
	by SDPhantom
	http://www.esoui.com/forums/member.php?u=483	]]
----------------------------------------------------------

--	Note: SCENE_SHOWING procs when SCENE_MANAGER:Show() is called, SCENE_SHOWN procs after animations are done
--SCENE_MANAGER:CallWhen("marketAnnouncement",SCENE_SHOWING,function() if SCENE_MANAGER.previousScene~=SCENE_MANAGER.scenes.gameMenuInGame then SCENE_MANAGER:Hide("marketAnnouncement"); end end);
SCENE_MANAGER:RegisterCallback("SceneStateChanged",function(scene,_,newstate)
	if scene==SCENE_MANAGER.scenes.marketAnnouncement and newstate==SCENE_SHOWING and SCENE_MANAGER.previousScene~=SCENE_MANAGER.scenes.gameMenuInGame then SCENE_MANAGER:Hide("marketAnnouncement"); end
end);
