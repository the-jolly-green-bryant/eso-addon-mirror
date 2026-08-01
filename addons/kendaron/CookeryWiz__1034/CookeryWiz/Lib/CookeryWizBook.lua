local L = CookeryWizLanguage.language

local BOOK_TEMPLATE_NAME = "CookeryWizBookTemplate"

CookeryWizBook = {}
CookeryWizBook.ui = nil
CookeryWizBook.uiParent = nil
CookeryWizBook.templateName = BOOK_TEMPLATE_NAME

CookeryWizBook.chapterTemplates = {}
CookeryWizBook.chapters = {}

CookeryWizBook.traceEnabled = false

local function trace(msg)
  if CookeryWizBook.traceEnabled then
    CookeryWizUtils:Trace(msg)
  end
end

---------------------------------------------------------------------
-- Function: New
--
-- This function is called to create an instance of a book
-- If editing, savedVars can refer to the SavedVariables
-- If live, can refer to in memory table
-- template is a virtual template to instantiate
-- name is the name that is associated with the GUI control and requires
-- valid characters
---------------------------------------------------------------------
function CookeryWizBook:New(owner, name, savedVars)
  o = {}
  o.name = name
  o.owner = owner
  o.savedVars = savedVars
   
  if owner and owner.OnGetCookeryWizParentUI then
    o.uiParent = owner:OnGetCookeryWizParentUI()
  end      
  setmetatable(o, self)
  self.__index = self
  return o  
end

---------------------------------------------------------------------
-- Function: SetTemplate
--
-- This function is called to set the template used for this book
-- If not set then it defaults to the standard template
-- NOTE: template is an object already created via XML or in code
---------------------------------------------------------------------
function CookeryWizBook:SetTemplate(templateName)
  self.templateName = templateName
end

---------------------------------------------------------------------
-- Function: GetTemplate
--
-- This function is called to get the template used for this book
---------------------------------------------------------------------
function CookeryWizBook:GetTemplate()
  return self.templateName
end

---------------------------------------------------------------------
-- Function: AddChapter
--
-- This function is called to create a chapter in a book
-- It will return a new CookeryWizChapter object
-- title is an optional parameter
---------------------------------------------------------------------
function CookeryWizBook:AddChapter(title)
	local chapter = CookeryWizChapter:New(self, title)
  self.chapters[#self.chapters + 1] = chapter
  return chapter
end

---------------------------------------------------------------------
-- Function: GetOwner
--
-- This function is called to get the owner table/object of the book
---------------------------------------------------------------------
function CookeryWizBook:GetOwner()
  return self.owner
end

---------------------------------------------------------------------
-- Function: AddPageTemplate
--
-- This function is called to add a template used for a page
-- If the template already exists it will not be added again
---------------------------------------------------------------------
function CookeryWizBook:AddChapterTemplate(templateName)
  local found = false
  
  local chapterTemplates = self.chapterTemplates
  
  for i = 1, #chapterTemplates do    
    if chapterTemplates[i].name == templateName then
      found  = true
      break
    end
  end
  
  if not found then
    local chapterTemplate = {}
    chapterTemplate.name = templateName
    --pageTemplate.instance = CreateControlFromVirtual(name, parent, templateName) 
    chapterTemplates[#chapterTemplates + 1] = chapterTemplate
  end
end

---------------------------------------------------------------------
-- Function: Show
--
-- This function is called to display the book
-- It will create the controls if they have not been created
---------------------------------------------------------------------
function CookeryWizBook:Show(show)
  if not self.name then
    d("No name associated with book")
    return
  end
  
  if show then
    local parent = self.uiParent
    -- if we have not created the book, create it
    if not self.ui then
      self.ui = CreateControlFromVirtual(self.name, parent, self.templateName) 
    end
    -- center it
    CookeryWizUtils:CenterControl(parent, control)    
  end
end

  