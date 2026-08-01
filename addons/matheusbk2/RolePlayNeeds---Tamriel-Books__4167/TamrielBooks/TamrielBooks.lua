local ADDON_NAME = "TamrielBooks"
local SavedData = nil  

TamrielBooks = {} 
local isBookOpen = false
ZO_CreateStringId("SI_BINDING_NAME_TAMRIELBOOKS_TAP", "Grab/Open Book")

local tapCount = 0
local tapTimer = 0
local TAP_THRESHOLD = 400 -- milliseconds

function TamrielBooks_Tap()
    tapCount = tapCount + 1
        tapTimer = GetGameTimeMilliseconds()
        zo_callLater(function()
            if tapCount == 1 then
                -- Single tap: open last saved book   

                SLASH_COMMANDS["/readlastsaved"]()
		tapCount = 0	
            elseif tapCount >= 2 then
                -- Double tap: save last read book
                SLASH_COMMANDS["/save"]()
                tapCount = 0
            end

        end, TAP_THRESHOLD * 1.2)

end


local MAX_CHUNK_SIZE = 1999
local runtimeLastBook = nil

local function ChunkText(text)
    local chunks = {}
    for i = 1, #text, MAX_CHUNK_SIZE do
        table.insert(chunks, string.sub(text, i, i + MAX_CHUNK_SIZE - 1))
    end
    return chunks
end

local function JoinChunks(chunks)
    return table.concat(chunks or {})
end

local function SanitizeBook(book)
    if not book or not book.title or not book.body then return nil end
    return {
        title = book.title,
        bodyChunks = ChunkText(book.body),
        medium = book.medium or MEDIUM_BOOK,
        showTitle = book.showTitle ~= false,
    }
end

local function ReadBook(book)
    if not isBookOpen then
        if not book or not book.bodyChunks then return end
        local fullText = JoinChunks(book.bodyChunks)
        LORE_READER:SetupBook(book.title, fullText, book.medium, book.showTitle)
        SCENE_MANAGER:Push("loreReaderDefault")
        PlaySound(LORE_READER.OpenSound)
        isBookOpen = true
    else      
       SLASH_COMMANDS["/save"]()
    end
end

local function OnShowBook(_, title, body, medium, showTitle)
    runtimeLastBook = {
        title = title,
        body = body,
        medium = medium,
        showTitle = showTitle,
    }
    
end

SLASH_COMMANDS["/save"] = function()
    if not runtimeLastBook then return end
    local clean = SanitizeBook(runtimeLastBook)
    SavedData.lastSavedBook = clean
    d('Carrying New Book:' .. clean.title)
end

SLASH_COMMANDS["/readlastsaved"] = function()
    ReadBook(SavedData.lastSavedBook)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end

    SavedData = ZO_SavedVars:New("TamrielBooksSV", 1, "Shelf", {
        lastSavedBook = nil,
    })

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_SHOW", EVENT_SHOW_BOOK, OnShowBook)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_SHOW_BOOK, function(_, bookId, medium, showTitle, title, body)
    --d("Book open: " .. tostring(bookId))
    isBookOpen = true
end)

local function OnSceneChange(newScene)
   if isBookOpen then 
      --d("Book was closed.")
      isBookOpen = false
   end
end

ZO_PreHook(SCENE_MANAGER, "ShowScene", function(sceneName)
    OnSceneChange(SCENE_MANAGER:GetCurrentScene(), SCENE_MANAGER:GetScene(sceneName))
end)