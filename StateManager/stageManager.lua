local stageManager = {}

-- current stage
local currentStage = "lobby"

-- default maps
local lobbyMap = {}
local gameMap = {}
local postGameMap = {}

local currentMap = {}

local stages = {
    lobby = function()
        -- lobby functionality
        -- if user sets a lobby map, change it
        if lobbyMap[0] then
            -- set map to lobbyMap and update currentMap
            currentMap = lobbyMap
        end
    end,

    game = function()
        -- game functionality
        -- if currentMap is not gameMap, change it
        if currentMap ~= gameMap then
            currentMap = gameMap
        end
    end,

    postGame = function()
        -- postGame functionality
        -- if user sets a postGameMap, change it
        if postGameMap[0] then
            -- set map to postGameMap and update currentMap
            currentMap = postGameMap
        end
    end
}

-- update stage
function stageManager.setStage(stage)
    -- if stage is valid, update and call its function
    if stages[stage] then
        currentStage = stage
        stages[currentStage]()
    else
        print("Invalid stage: ", stage)
    end
end

-- get stage
function stageManager.getStage()
    return currentStage
end

-- set lobbyMap
function stageManager.setLobbyMap(lobby_map)
    lobbyMap = lobby_map
end

-- set postGameMap
function stageManager.setPostGameMap(post_game_map)
    postGameMap = post_game_map
end

return stageManager