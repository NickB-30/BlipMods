local stageManager = {}

-- current stage
local currentStage = "lobby"

-- default maps
local lobbyMap = {}
local gameMap = {}
local postGameMap = {}

local currentMap = {}
local players = {}

local stages = {
    lobby = function()
        -- lobby functionality
        -- if user sets a lobby map, change it
        if lobbyMap[0] then
            -- set map to lobbyMap and update currentMap
            currentMap = lobbyMap
            Config.Map = currentMap
        end
    end,

    game = function()
        -- game functionality
        -- if currentMap is not gameMap, change it
        if currentMap ~= gameMap then
            currentMap = gameMap
            Config.Map = currentMap
        end
    end,

    postGame = function()
        -- postGame functionality
        -- if user sets a postGameMap, change it
        if postGameMap[0] then
            -- set map to postGameMap and update currentMap
            currentMap = postGameMap
            Config.Map = currentMap
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

-- add players
function stageManager.addPlayer(Player)
    if currentStage == "game" then
        players[Player] = "spectating"
        print(Player .. " is spectating")
    else
        players[Player] = "lobby"
        print(Player.Username)
        print(Player.Username .. " joined the lobby")
    end
end

-- remove players
function stageManager.removePlayer(Player)
    if players[Player] then
        players[Player] = nil
        print(Player.Username .. " left the game")
    end
end

-- ready up
local ready = {}
function stageManager.readyUp(Player)
    if ready[Player] then
        print("Player already ready!")
    else
        ready[Player] = "ready"
        print(Player.Username .. "is now ready!")
    end
end

-- get ready players
function stageManager.getReadyPlayer()
    return ready
end

-- check if players are ready
function stageManager.checkPlayersReady()
    local readyCount = 0
    for _, status in pairs(ready) do
        if status == "ready" then
            readyCount = readyCount + 1
        end
    end

    -- if everyone is ready, start the gane
    if readyCount == #players then
        stageManager.setStage("game")
        print("Starting game!")
    else
        print(readyCount .. "/ " .. #players .. "are ready!")
    end
end

return stageManager