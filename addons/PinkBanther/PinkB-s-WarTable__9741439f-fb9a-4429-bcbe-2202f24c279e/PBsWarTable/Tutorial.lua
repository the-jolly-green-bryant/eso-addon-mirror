-- Isolated practice boards use the production engine. Lesson gates never mutate it.
local T={};T.__index=T;PBWT.Tutorial=T
local E,C=PBWT.Engine,PBWT.Config
local L=C.VARIANTS.light -- the tutorial always teaches the light board
local function board(pieces)
 local s=E.New();s.factions={1,2}
 for _,p in ipairs(s.pieces) do p.alive=false end
 for _,v in ipairs(pieces or {}) do local p=s.pieces[v[1]];p.alive,p.x,p.y=true,v[2],v[3] end
 return s
end
-- Lesson wording lives in the locale; the board setups stay here.
function T.LessonTitle(lesson)
    local args=lesson.format and lesson.format()
    return args and PBWT.L(lesson.titleKey,args[1]) or PBWT.L(lesson.titleKey)
end
function T.LessonText(lesson)
    local args=lesson.format and lesson.format()
    if args then return PBWT.L(lesson.textKey,args[2],args[3],args[4],args[5]) end
    return PBWT.L(lesson.textKey)
end
T.lessons={
 {titleKey='tut_1_title',textKey='tut_1_text',opening=true,seed=function() return E.New(true) end},
 {titleKey='tut_2_title',textKey='tut_2_text',pieces={{2,1,3}},commands={{type='move',id=2,x=2,y=3}}},
 {titleKey='tut_3_title',textKey='tut_3_text',pieces={{2,2,3}},commands={{type='end_turn'}}},
 {titleKey='tut_4_title',textKey='tut_4_text',pieces={{4,2,2}},commands={{type='move',id=4,x=5,y=2}}},
 {titleKey='tut_5_title',textKey='tut_5_text',pieces={{1,2,2},{7,3,2}},commands={{type='attack',id=1,target=7}}},
 {titleKey='tut_6_title',textKey='tut_6_text',pieces={{1,3,2},{12,3,3}},commands={{type='attack',id=1,target=12}}},
 {titleKey='tut_7_title',textKey='tut_7_text',pieces={{2,1,3},{7,4,3}},commands={{type='card',card='charge',id=2,x=3,y=3},{type='attack',id=2,target=7}}},
 {titleKey='tut_8_title',textKey='tut_8_text',pieces={{4,2,3}},commands={{type='card',card='stealth',id=4}}},
 {titleKey='tut_9_title',textKey='tut_9_text',seed=function() local s=board({{1,3,2},{6,2,2},{12,3,3}});s.factions={3,2};return s end,commands={{type='card',card='siege',id=1,target=12}}},
 {titleKey='tut_10_title',textKey='tut_10_text',pieces={{6,2,2}},commands={{type='card',card='revive',id=1,x=1,y=1}}},
 {titleKey='tut_11_title',textKey='tut_11_text',pieces={{2,2,2},{4,3,2},{6,2,1}},commands={{type='card',card='horn',id=2},{type='horn_move',id=4,x=3,y=3}}},
 {titleKey='tut_12_title',textKey='tut_12_text',seed=function() local s=board({{6,3,3},{2,2,3},{10,5,2}});s.score={4,6};s.flags={1,1,0};return s end,commands={{type='invoke_scroll'},{type='end_turn'}},opponentPass=true},
 {titleKey='tut_13_title',textKey='tut_13_text',seed=function() local s=board({{2,1,3},{12,3,3},{8,4,3}});s.player,s.turn=2,2;s.score={0,4};s.flags={0,2,2};assert(E.Apply(s,2,{type='invoke_scroll'}));assert(E.Apply(s,2,{type='end_turn'}));return s end,commands={{type='move',id=2,x=2,y=3}}},
 {titleKey='tut_14_title',textKey='tut_14_text',format=function() return {L.WIN_SCORE,L.WIN_SCORE-1,L.WIN_SCORE,L.MAX_TURNS,L.WIN_SCORE} end,seed=function() local s=board({{2,2,3}});s.score[1]=L.WIN_SCORE-1;s.flags[1]=1;return s end,commands={{type='end_turn'}}},
}
function T.New() local self=setmetatable({index=1},T);self:Load();return self end
function T:Load()
 self.lesson=T.lessons[self.index];self.progress=1;self.complete=false
 self.state=self.lesson.seed and self.lesson.seed() or board(self.lesson.pieces)
end
function T:Next() if self.index<#T.lessons then self.index=self.index+1 else self.index=1 end;self:Load() end
function T:Apply(command)
 if self.complete then return false,'tutorial_next' end
 if self.lesson.opening then
  local c=command
  if c.type=='roll_dice' then c={type='roll_dice',roll=5} end
  local ok,why=E.Apply(self.state,1,c);if not ok then return ok,why end
  while self.state.status=='setup' and self.state.player==2 do
   assert(E.Apply(self.state,2,PBWT.Opening.ComputerCommand(self.state,function() return 2 end)))
  end
  self.complete=self.state.status=='playing';return true,why
 end
 local expected=self.lesson.commands[self.progress]
 for k,v in pairs(expected) do if command[k]~=v then return false,'tutorial_goal' end end
 local ok,why=E.Apply(self.state,self.state.player,command)
 if ok then
  self.progress=self.progress+1;self.complete=self.progress>#self.lesson.commands
  if self.complete and self.lesson.opponentPass then assert(E.Apply(self.state,self.state.player,{type='end_turn'})) end
 end
 return ok,why
end
function T:TargetAt(x,y)
 if self.complete or self.lesson.opening then return false end
 local c=self.lesson.commands[self.progress];local p=E.Piece(self.state,c.id);local enemy=E.Piece(self.state,c.target)
 return (p and p.alive and p.x==x and p.y==y) or (c.x==x and c.y==y) or (enemy and enemy.alive and enemy.x==x and enemy.y==y)
end
function T:Text()
    local text=PBWT.L('tut_header',self.index,#T.lessons,T.LessonTitle(self.lesson),T.LessonText(self.lesson))
    if not self.complete and not self.lesson.opening then
        local c=self.lesson.commands[self.progress]
        local action=c.card and PBWT.Cards.Name(c.card) or PBWT.L('tut_action_'..c.type)
        text=PBWT.L('tut_step',self.progress,#self.lesson.commands,action)..text
    end
 if self.complete then text=text..(self.index==#T.lessons and PBWT.L('tut_all_done') or PBWT.L('tut_chapter_done'))
 else
    local c=self.lesson.commands and self.lesson.commands[self.progress]
    local guide=c and (c.type=='end_turn' or c.type=='invoke_scroll') and PBWT.L('tut_guide') or PBWT.L('tut_guide_board')
    text=text..'\n\n'..guide..PBWT.L('tut_guide_hint')
 end
 return text
end
