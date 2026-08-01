OJ_TxtOutput = {}
local OJTOP = OJ_TxtOutput
OJTOP.ename = 'OJTOP'
OJTOP.name = 'oJ_TxtOutput' -- sugar daddy
OJTOP.author = 'oJelly, fixed by Baertram'
OJTOP.version = '1.4.5'
OJTOP.init = false
OJTOP.savedata = {}

--Original Quest variables
local questsPanel = ZO_QuestJournalQuestsPanel
local questsChildContainer = questsPanel:GetNamedChild("QuestInfoContainerScrollChild")
local questTitle = questsChildContainer:GetNamedChild("TitleText")
local questRepeatable = questsChildContainer:GetNamedChild("RepeatableText")
local questBG = questsChildContainer:GetNamedChild("BGText")
local questStep = questsChildContainer:GetNamedChild("StepText")

local questStepContainer = questsPanel:GetNamedChild("QuestStepContainerScrollChild")
local questStepBulletLabels = {}
local questStepOptionalBulletLabels = {}


--XML controls of the addon
local OJ_TxtOutputPanelTLC = OJ_TxtOutputPanelTLC
--local OJ_TxtOutputStatusTLC = OJ_TxtOutputStatusTLC
local OJ_TxtOutputPanelTLCOutputBoxTxtBox = OJ_TxtOutputPanelTLCOutputBoxTxtBox

--local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER
--local CM = CALLBACK_MANAGER
--local strformat = zo_strformat
local init_savedef = {
    -- aleryuistatus = true, --icon show status
    autoshowstatus = true, --auto show status
    autoshowsubtitle = false, --auto show subtitles
    autoselectalltxt = true, --auto select all
    subtitlechat = true, --show to chat
    mainbox_pos = {70,120},
    statusicon_pos = {20,20},
}
local debug_mode = false
OJTOP.talkstatus = false
OJTOP.queststatus = false
OJTOP.talkoptcount = 0
OJTOP.showingtype = 0 -- 0非subtitle , 5 subtitle
OJTOP.withoutCombat  = true --就算有開自動顯示 戰鬥中也不秀

local LAM2 = LibAddonMenu2


local findAllTxt4InteractWindow, findAllTxt4QuestJournal

local function parseQuestTextDelayed(delay)
    delay = delay or 100
    zo_callLater(function() findAllTxt4QuestJournal() end, delay)
end


--npc講話 原本期待用事件判斷抓資料時間
function OJTOP.oj_chatter_begin(eventCode, optionCount)
    -- local maxOpt = optionCount + 1
    -- findAllTxt4InteractWindow(maxOpt)
    OJTOP.talkstatus = true
    findAllTxt4InteractWindow(0)
end
function OJTOP.oj_conversation_updated(eventCode, conversationBodyText, conversationOptionCount)
    -- local maxOpt = conversationOptionCount + 1
    -- findAllTxt4InteractWindow(maxOpt)
    findAllTxt4InteractWindow(0)
end
function OJTOP.oj_quest_offered()
    findAllTxt4InteractWindow(0)
end
function OJTOP.oj_quest_complete_dialog()
    findAllTxt4InteractWindow(0)
end
function OJTOP.oj_chatter_end()
    if OJTOP.talkstatus then
        OJTOP.talkstatus = false
        OJTOP.toggleOJTOPPanelView(0);
    end
end
function OJTOP.oj_subtitle_show(eventCode,MsgType,speakerName,text)
    local lastmsg = ''
    if OJTOP.showingtype == 5 then
        lastmsg = OJ_TxtOutputPanelTLCOutputBoxTxtBox:GetText()
        if lastmsg ~= '' then
            lastmsg = lastmsg.."\n\n"
        end
    end
    OJTOP.showingtype = 5
    
    local npc = zo_strformat("<<1>>", speakerName);
    local msg = zo_strformat("<<1>>", text);
    local main = lastmsg .. npc .. " : \n" .. msg
    OJTOP:showTxt2Box(main)
    

    if OJTOP.savedata.subtitlechat then
        -- format
        npc = zo_strformat("|c00C000<<1>>|r", speakerName);
        msg = zo_strformat("|cf0f0f0<<1>>|r", text);
        -- output
        CHAT_SYSTEM:AddMessage(npc .. ' : ' .. msg)
    end
end


function OJTOP.findAllTxt4InteractWindow(maxOpt)
    if maxOpt == 0 then
        maxOpt = OJTOP.talkoptcount
    end
    -- title 
    local main = ":::  "..ZO_InteractWindowTargetAreaTitle:GetText().."  :::\n\n"
    -- body
    main = main..ZO_InteractWindowTargetAreaBodyText:GetText().."\n\n"
    -- option
    if ZO_ChatterOption1:IsHidden() == false then main = main.."\n >> "..ZO_ChatterOption1:GetText() end
    if ZO_ChatterOption2:IsHidden() == false then main = main.."\n >> "..ZO_ChatterOption2:GetText() end
    if ZO_ChatterOption3:IsHidden() == false then main = main.."\n >> "..ZO_ChatterOption3:GetText() end
    if ZO_ChatterOption4:IsHidden() == false then main = main.."\n >> "..ZO_ChatterOption4:GetText() end
    if ZO_ChatterOption5:IsHidden() == false then main = main.."\n >> "..ZO_ChatterOption5:GetText() end
    if ZO_ChatterOption6:IsHidden() == false then main = main.."\n >> "..ZO_ChatterOption6:GetText() end
    if ZO_ChatterOption7:IsHidden() == false then main = main.."\n >> "..ZO_ChatterOption7:GetText() end
    if ZO_ChatterOption8:IsHidden() == false then main = main.."\n >> "..ZO_ChatterOption8:GetText() end
    if ZO_ChatterOption9:IsHidden() == false then main = main.."\n >> "..ZO_ChatterOption9:GetText() end
    if ZO_ChatterOption10:IsHidden() == false then main = main.."\n >> "..ZO_ChatterOption10:GetText() end
    main = main.."\n\n\n"

    OJTOP.showingtype = 0
    OJTOP:showTxt2Box(main)
end
findAllTxt4InteractWindow = OJTOP.findAllTxt4InteractWindow


-- 任務
--local OriginQJTitleSet = ZO_QuestJournalTitleText.SetText
--local OriginQJTitleSet = questTitle.SetText
-- questTitle.SetText = function (self, bodyText)
--end
-- local OriginQJStepSet = ZO_QuestJournalStepText.SetText
-- ZO_QuestJournalStepText.SetText = function (self, bodyText)
--     OriginQJStepSet(self, bodyText)
-- end
-- local OriginQJBGSet = ZO_QuestJournalBGText.SetText
-- ZO_QuestJournalBGText.SetText = function (self, bodyText)
--     OriginQJBGSet(self, bodyText)
-- end

--Remove color codes
local function cancelc666(str)
    str = string.gsub(str, "|c666666", "")
    str = string.gsub(str, "|r", "")
    return str
end

local function updateQuestStepBulletListControls()
    questStepBulletLabels = {}
    for i=1, 10 do
        local questStepBulletLabel = questStepContainer:GetNamedChild("ConditionTextBulletListLabel" .. tostring(i))
        if questStepBulletLabel ~= nil then
            questStepBulletLabels[#questStepBulletLabels+1] = questStepBulletLabel
        end
    end
end

local function updateQuestStepOptionalBulletListControls()
    questStepOptionalBulletLabels = {}
    for i=1, 10 do
        local questStepOptionalBulletLabel = questStepContainer:GetNamedChild("OptionalStepTextBulletList" .. tostring(i))
        if questStepOptionalBulletLabel ~= nil then
            questStepOptionalBulletLabels[#questStepOptionalBulletLabels+1] = questStepOptionalBulletLabel
        end
    end
end

function OJTOP.findAllTxt4QuestJournal()
--d("[OJTOP]findAllTxt4QuestJournal-questStatus: " ..tostring(OJTOP.queststatus))
    if OJTOP.queststatus == false then return end

    local maxOpt = OJTOP.talkoptcount
    -- title 
    local main = ":::  "..questTitle:GetText().."  :::"
--d(">title: " .. tostring(questTitle:GetText()))
    --repeatable
    if questRepeatable ~= nil and not questRepeatable:IsHidden() then
        main = main.."\n!" .. questRepeatable:GetText().."!\n\n"
    else
        main = main  .. "\n\n"
    end
    -- body
    main = main..questBG:GetText().."\n\n"
    main = main..questStep:GetText().."\n\n"
--d(">bodyBG: " .. tostring(questBG:GetText()))
--d(">step: " .. tostring(questStep:GetText()))
    -- tasks

    updateQuestStepBulletListControls()
    if not ZO_IsTableEmpty(questStepBulletLabels) then
        for _, bulletLabel in ipairs(questStepBulletLabels) do
            if bulletLabel:IsHidden() == false then
--d(">>Added quest condition: " ..tostring(bulletLabel:GetText()))
                main = main.."\n >> "..cancelc666(bulletLabel:GetText())
            end
        end
    end
    -- optional steps
    updateQuestStepOptionalBulletListControls()
    if not ZO_IsTableEmpty(questStepOptionalBulletLabels) then
        for _, optionalBulletLabel in ipairs(questStepOptionalBulletLabels) do
            if optionalBulletLabel:IsHidden() == false then
--d(">>Added optional quest condition: " ..tostring(optionalBulletLabel:GetText()))
                main = main.."\n\n\n >> ".. optionalBulletLabel:GetText()
            end
        end
    end

    main = main.."\n\n\n"

    OJTOP.showingtype = 0
    OJTOP:showTxt2Box(main)
end
findAllTxt4QuestJournal = OJTOP.findAllTxt4QuestJournal

-- 戰鬥判斷
function OJTOP.OnPlayerCombatState(event, inCombat)
    if inCombat then
        OJTOP.withoutCombat = false;
    else
        OJTOP.withoutCombat = true;
    end
end
-- 即時開書
function OJTOP.OnShowBook(eventCode, title, body, medium, showTitle)
    local main = ":::  "..title.."  :::\n\n\n"..body
    OJTOP.showingtype = 0
    OJTOP:showTxt2Box(main)
end
-- j 介面開書
local Origin_LoreLibrary_ReadBook = ZO_LoreLibrary_ReadBook
ZO_LoreLibrary_ReadBook = function (categoryIndex, collectionIndex, bookIndex)
    Origin_LoreLibrary_ReadBook(categoryIndex, collectionIndex, bookIndex)
    local title = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
    local body, medium, showTitle = ReadLoreBook(categoryIndex, collectionIndex, bookIndex)

    local main = ":::  "..title.."  :::"
    main = main.." -- ("..categoryIndex.." , "..collectionIndex.." , "..bookIndex..") \n\n"
    main = main..body

    OJTOP.showingtype = 0
    OJTOP:showTxt2Box(main)
end

function OJTOP:showTxt2Box(main)
--d("[OJTOP]showTxt2Box - main: " ..tostring(main) .. ", showingType: " ..tostring(OJTOP.showingtype))
    OJ_TxtOutputPanelTLCOutputBoxTxtBox:Clear()

    local length = ZoUTF8StringLength(main) + 1000
    OJ_TxtOutputPanelTLCOutputBoxTxtBox:SetMaxInputChars(length)
    OJ_TxtOutputPanelTLCOutputBoxTxtBox:SetText(main)
    
    if OJTOP.showingtype == 5 then
        if OJTOP.savedata.autoshowsubtitle == true then
            if OJTOP.withoutCombat == true then
                OJTOP.toggleOJTOPPanelView(1);
            end
        end
    else
        if OJTOP.savedata.autoshowstatus == true then
            OJTOP.toggleOJTOPPanelView(1);
        end
    end
    if OJTOP.savedata.autoselectalltxt == true then 
        OJ_TxtOutputPanelTLCOutputBoxTxtBox:SelectAll()
        OJ_TxtOutputPanelTLCOutputBoxTxtBox:TakeFocus()
        -- eso deny copy
        -- OJ_TxtOutputPanelTLCOutputBoxTxtBox:CopyAllTextToClipboard()
        -- d('=====')
    end
end
-- 硬讀書
function OJTOP.ShowFilterBook()
    local category_i = OJ_TxtOutputPanelTLCCategoryIndexVal:GetText()
    local collection_i = OJ_TxtOutputPanelTLCCollectionIndexVal:GetText()
    local book_i = OJ_TxtOutputPanelTLCBookIndexVal:GetText()

    if category_i ~= '' and collection_i ~= '' and book_i ~= '' then
        local title = GetLoreBookInfo(category_i, collection_i, book_i)
        local body, medium, showTitle = ReadLoreBook(category_i, collection_i, book_i)

        local main = ":::  "..title.."  :::\n\n\n"..body
        OJTOP.showingtype = 0
        OJTOP:showTxt2Box(main)
    else

        local main = "please input 3 input val"
        OJTOP.showingtype = 0
        OJTOP:showTxt2Box(main)
    end
end

----------------------------------------
-- UI CTRL Start
----------------------------------------
function OJTOP:OnUiPosLoad()
    OJ_TxtOutputPanelTLC:ClearAnchors()
    OJ_TxtOutputPanelTLC:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, OJTOP.savedata.mainbox_pos[0], OJTOP.savedata.mainbox_pos[1])

    -- if OJTOP.savedata.autoshowstatus == false then
    --     OJTOP.toggleOJTOPStatusView(1)
    -- else
    --     OJTOP.toggleOJTOPStatusView(0)
    -- end
    -- OJ_TxtOutputStatusTLC:ClearAnchors()
    -- OJ_TxtOutputStatusTLC:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, OJTOP.savedata.statusicon_pos[0], OJTOP.savedata.statusicon_pos[1])
end
function OJTOP.OnUiPosSave(tag)
    if tag == 'OJ_TxtOutputPanelTLC' then
        OJTOP.savedata.mainbox_pos[0] = OJ_TxtOutputPanelTLC:GetLeft()
        OJTOP.savedata.mainbox_pos[1] = OJ_TxtOutputPanelTLC:GetTop()
    end
    -- if tag == 'OJ_TxtOutputStatusTLC' then
    --     OJTOP.savedata.statusicon_pos[0] = OJ_TxtOutputStatusTLC:GetLeft()
    --     OJTOP.savedata.statusicon_pos[1] = OJ_TxtOutputStatusTLC:GetTop()
    -- end
end
function OJTOP.toggleOJTOPPanelView(open) 
    if open == nil then
        SM:ToggleTopLevel(OJ_TxtOutputPanelTLC)
    elseif open == 1 then
        SM:ShowTopLevel(OJ_TxtOutputPanelTLC)
    elseif open == 0 then
        SM:HideTopLevel(OJ_TxtOutputPanelTLC)
    end
end
function OJTOP.toggleOJTOPStatusView(open)
    -- if open == nil then
    --     if OJTOP.savedata.aleryuistatus == true then
    --         OJTOP.savedata.aleryuistatus = false
    --         OJ_TxtOutputStatusTLC:SetHidden(true)
    --     else
    --         OJTOP.savedata.aleryuistatus = true
    --         OJ_TxtOutputStatusTLC:SetHidden(false)
    --     end
    -- elseif open == 1 then
    --     OJ_TxtOutputStatusTLC:SetHidden(false)
    -- elseif open == 0 then
    --     OJ_TxtOutputStatusTLC:SetHidden(true)
    -- end
end
function OJTOP.conmoveOJTOPStatusView(status)
    -- if status == 1 then
    --     OJ_TxtOutputStatusTLCBg:SetCenterColor(255,0,0,1)
    --     WM:SetMouseCursor(MOUSE_CURSOR_PAN)
    -- elseif status == 0 then
    --     OJ_TxtOutputStatusTLCBg:SetCenterColor(0,0,0,1)
    --     WM:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
    -- end
end
----------------------------------------
-- test
----------------------------------------
--[[
local function table2string()  end
function OJTOP.oJTxtOutputTest()
    
end
function OJTOP.oJTxtOutputCsStyle()
    OJTOP:showTxt2Box( table2string(CS.Styles.list) )
end
function OJTOP.oJTxtOutputCsTrait()
    OJTOP:showTxt2Box( table2string(CS.Data.researched) )
end
]]


----------------------------------------
-- LAM settings menu
----------------------------------------
local function createLAM2Panel()
    local panelData = {
        type = "panel",
        name = 'TxtOutput',
        displayName = ZO_HIGHLIGHT_TEXT:Colorize('TxtOutput'),
        author = "|cFFAA33"..OJTOP.author.."|r",
        version = OJTOP.version,
        registerForRefresh = true,
    }
    local optionsData = {
        -- [tpl] = {
        --     type = "checkbox",
        --     name = 'show TxtOutput status icon',
        --     tooltip = 'show the status ui when you trun off auto show',
        --     getFunc = function() 
        --         return OJTOP.savedata.aleryuistatus
        --     end,
        --     setFunc = function(val) 
        --         OJTOP.savedata.autoshowstatus = val
        --         OJTOP.toggleOJTOPStatusView(open)
        --     end,
        --     default = OJTOP.savedata.aleryuistatus,
        -- },
        [1] = {
            type = "checkbox",
            name = 'auto show book/quest/talk',
            tooltip = 'auto show TxtOutput with book/quest/talk UI open',
            getFunc = function() 
                return OJTOP.savedata.autoshowstatus
            end,
            setFunc = function(val) 
                OJTOP.savedata.autoshowstatus = val
            end,
            default = OJTOP.savedata.autoshowstatus,
        },
        [2] = {
            type = "checkbox",
            name = 'auto selec all text',
            tooltip = 'select all text when TxtOutput show',
            getFunc = function() 
                return OJTOP.savedata.autoselectalltxt
            end,
            setFunc = function(val) 
                OJTOP.savedata.autoselectalltxt = val
            end,
            default = OJTOP.savedata.autoselectalltxt,
        },
        [3] = {
            type = "checkbox",
            name = 'auto show Subtitle (NPC talk)',
            tooltip = 'auto show TxtOutput when subtitles update',
            getFunc = function() 
                return OJTOP.savedata.autoshowsubtitle
            end,
            setFunc = function(val) 
                OJTOP.savedata.autoshowsubtitle = val
            end,
            default = OJTOP.savedata.autoshowsubtitle,
        },
        [4] = {
            type = "checkbox",
            name = 'show Subtitle on CHAT (NPC talk)',
            tooltip = 'show Subtitle on CHAT, you can install addon : Chat2Clipboard to copy it',
            getFunc = function() 
                return OJTOP.savedata.subtitlechat
            end,
            setFunc = function(val) 
                OJTOP.savedata.subtitlechat = val
            end,
            default = OJTOP.savedata.subtitlechat,
        }
    }
    local LAM2optionsPanelName = OJTOP.name.."LAM2Options"
    LAM2:RegisterAddonPanel(LAM2optionsPanelName, panelData)
    LAM2:RegisterOptionControls(LAM2optionsPanelName, optionsData)
end

----------------------------------------
-- HOOKS
----------------------------------------
local function loadQuestPanelHooks()
    local origQuestTitleTextSetTextFunc = questTitle.SetText

    --Hook the quest container title's SetText function
    questTitle.SetText = function(selfVar, bodyText)
--d("[OJTOP]QuestTitle-SetText: " .. tostring(bodyText))
        OJTOP.talkoptcount = 0
        origQuestTitleTextSetTextFunc(selfVar, bodyText)
        parseQuestTextDelayed(100)
--d( '===============================' )
    end
end

local function loadChatterHooks()
    -- 因為無法有正確的事件 取得對話選項的更新狀態 只好繼承 副寫 每一個 setText
    local OriginTitleSet = ZO_InteractWindowTargetAreaTitle.SetText
    ZO_InteractWindowTargetAreaTitle.SetText = function (self, bodyText)
        OriginTitleSet(self, bodyText)
        OJTOP.talkoptcount = 0
    end
    -- local OriginTitleSet = ZO_InteractWindowTargetAreaBodyText.SetText
    -- ZO_InteractWindowTargetAreaBodyText.SetText = function (self, bodyText)
    --     OriginBodySet(self, bodyText)
    -- end
    -- local OriginOpt_1_Set = ZO_ChatterOption1.SetText; ZO_ChatterOption1.SetText = function (self, bodyText) OriginOpt_1_Set(self, bodyText); OJTOP.talkoptcount = OJTOP.talkoptcount + 1; end
    -- local OriginOpt_2_Set = ZO_ChatterOption2.SetText; ZO_ChatterOption2.SetText = function (self, bodyText) OriginOpt_2_Set(self, bodyText); OJTOP.talkoptcount = OJTOP.talkoptcount + 1; end
    -- local OriginOpt_3_Set = ZO_ChatterOption3.SetText; ZO_ChatterOption3.SetText = function (self, bodyText) OriginOpt_3_Set(self, bodyText); OJTOP.talkoptcount = OJTOP.talkoptcount + 1; end
    -- local OriginOpt_4_Set = ZO_ChatterOption4.SetText; ZO_ChatterOption4.SetText = function (self, bodyText) OriginOpt_4_Set(self, bodyText); OJTOP.talkoptcount = OJTOP.talkoptcount + 1; end
    -- local OriginOpt_5_Set = ZO_ChatterOption5.SetText; ZO_ChatterOption5.SetText = function (self, bodyText) OriginOpt_5_Set(self, bodyText); OJTOP.talkoptcount = OJTOP.talkoptcount + 1; end
    -- local OriginOpt_6_Set = ZO_ChatterOption6.SetText; ZO_ChatterOption6.SetText = function (self, bodyText) OriginOpt_6_Set(self, bodyText); OJTOP.talkoptcount = OJTOP.talkoptcount + 1; end
    -- local OriginOpt_7_Set = ZO_ChatterOption7.SetText; ZO_ChatterOption7.SetText = function (self, bodyText) OriginOpt_7_Set(self, bodyText); OJTOP.talkoptcount = OJTOP.talkoptcount + 1; end
    -- local OriginOpt_8_Set = ZO_ChatterOption8.SetText; ZO_ChatterOption8.SetText = function (self, bodyText) OriginOpt_8_Set(self, bodyText); OJTOP.talkoptcount = OJTOP.talkoptcount + 1; end
    -- local OriginOpt_9_Set = ZO_ChatterOption9.SetText; ZO_ChatterOption9.SetText = function (self, bodyText) OriginOpt_9_Set(self, bodyText); OJTOP.talkoptcount = OJTOP.talkoptcount + 1; end
    -- local OriginOpt_10_Set = ZO_ChatterOption10.SetText; ZO_ChatterOption10.SetText = function (self, bodyText) OriginOpt_10_Set(self, bodyText); OJTOP.talkoptcount = OJTOP.talkoptcount + 1; end
end

----------------------------------------
-- INIT
----------------------------------------
function OJTOP:Initialize()
    SM:RegisterTopLevel(OJ_TxtOutputPanelTLC, false) -- 註冊最高層

    -- savedata
    OJTOP.savedata = ZO_SavedVars:NewAccountWide('OJTOP_savedata', 1, GetWorldName(), init_savedef)
    
    -- key bind controls
    ZO_CreateStringId("SI_BINDING_NAME_SHOW_OJTOPPanelView", "toggle ui")

    --Init XML controls
    OJ_TxtOutputPanelTLCHeaderTitle:SetText("|cFFAA33TxtOutput|r "..OJTOP.version)

    --Hooks
    loadQuestPanelHooks()
    loadChatterHooks()

    -- Events
    EM:RegisterForEvent(OJTOP.name, EVENT_PLAYER_COMBAT_STATE, OJTOP.OnPlayerCombatState)
    EM:RegisterForEvent(OJTOP.name, EVENT_SHOW_BOOK, OJTOP.OnShowBook) --即時打開書本
    -- 以下4個事件 都在 ui 文字貼好才觸發 , 無法判斷我想要的 選項數量 只能改用 繼承的方式處理
    EM:RegisterForEvent(OJTOP.name, EVENT_CHATTER_BEGIN, OJTOP.oj_chatter_begin) --npc講話
    EM:RegisterForEvent(OJTOP.name, EVENT_CONVERSATION_UPDATED, OJTOP.oj_conversation_updated) --npc繼續講話
    EM:RegisterForEvent(OJTOP.name, EVENT_QUEST_OFFERED , OJTOP.oj_quest_offered); --npc對話給予任務選項
    EM:RegisterForEvent(OJTOP.name, EVENT_QUEST_COMPLETE_DIALOG , OJTOP.oj_quest_complete_dialog) --npc對話給予任務獎勵
    EM:RegisterForEvent(OJTOP.name, EVENT_CHATTER_END, OJTOP.oj_chatter_end) --npc對話結束

    EM:RegisterForEvent(OJTOP.name, EVENT_SHOW_SUBTITLE, OJTOP.oj_subtitle_show) --字幕出現

    -- 一堆 TopLevel 視窗問題
    EM:RegisterForEvent(OJTOP.ename,EVENT_NEW_MOVEMENT_IN_UI_MODE, function() OJTOP.toggleOJTOPPanelView(0) end)
    -- ZO_PreHookHandler(OJ_TxtOutputStatusTLC,'OnMouseEnter', function() OJTOP.conmoveOJTOPStatusView(1) end)
    -- ZO_PreHookHandler(OJ_TxtOutputStatusTLC,'OnMouseExit', function() OJTOP.conmoveOJTOPStatusView(0) end)
    ZO_PreHookHandler(ZO_QuestJournal,'OnShow', function() OJTOP.queststatus = true; parseQuestTextDelayed(200) end)
    ZO_PreHookHandler(ZO_QuestJournal,'OnHide', function() OJTOP.queststatus = false; OJTOP.toggleOJTOPPanelView(0); end)

    -- default run func
    OJTOP:OnUiPosLoad()

    -- setting page
    createLAM2Panel()

    --[[
    SLASH_COMMANDS["/ojtoptest"] = function()
        OJTOP.oJTxtOutputTest()
    end
    SLASH_COMMANDS["/ojtop_cs_style"] = function()
        OJTOP.oJTxtOutputCsStyle()
    end
    SLASH_COMMANDS["/ojtop_cs_trait"] = function()
        OJTOP.oJTxtOutputCsTrait()
    end
    ]]
    SLASH_COMMANDS["/ojtop"] = function() OJTOP.toggleOJTOPPanelView() end
end
function OJTOP.OnAddOnLoaded(event, addonName)
    if addonName ~= OJTOP.name then return end
    EM:UnregisterForEvent(OJTOP.ename,EVENT_ADD_ON_LOADED)
    OJTOP:Initialize()
end
EM:RegisterForEvent(OJTOP.ename, EVENT_ADD_ON_LOADED, OJTOP.OnAddOnLoaded);
