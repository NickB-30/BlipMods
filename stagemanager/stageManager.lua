local stageManager = {}

-- current stage
local currentStage = "lobby"

-- default maps
local lobbyMap = {}
local gameMap = {}
local postGameMap = {}

local currentMap = {}
local players = {}
local playerCount = 0
local readyCount = 0

if IsServer then
    LocalEvent:Listen(LocalEvent.Name.OnPlayerJoin, function(Player)
        print(Player.Username .. " has joined the game!")
        playerCount = playerCount + 1
        print(playerCount .. " players in the game!")
        Network:Broadcast("UpdatePlayerCount", playerCount)
    end)
    LocalEvent:Listen(LocalEvent.Name.OnPlayerLeave, function(Player)
        print(Player.Username .." has left the game!")
        playerCount = playerCount - 1
        print(playerCount .. " players in the game!")
        Network:Broadcast("UpdatePlayerCount", playerCount)
    end)
end

-- Network event to sync player count (Client-side)
if not IsServer then
    Network:Listen("UpdatePlayerCount", function(count)
        playerCount = count
    end)
    Network:Listen("UpdateReadyCount", function(count)
        readyCount = count
    end)
end

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
    playerCount = playerCount + 1
    if currentStage == "game" then
        players[Player] = "spectating"
        print(Player .. " is spectating")
    else
        players[Player] = "lobby"
        print(Player.Username .. " joined the lobby")
    end
end

-- remove players
function stageManager.removePlayer(Player)
    playerCount = playerCount - 1
    if players[Player] then
        players[Player] = nil
        print(Player.Username .. " left the game")
    end
end

-- ready up
local ready = {}
function stageManager.readyUp(Player)
    if ready[Player] then
        ready[Player] = nil
        readyCount = readyCount - 1
        print(Player.Username .. " unreadied!")
    else
        ready[Player] = "ready"
        readyCount = readyCount + 1
        print(Player.Username .. " is now ready!")
    end
    print(readyCount .. " players ready")
end

-- get ready players
function stageManager.getReadyPlayer()
    return ready
end

-- check if players are ready
function stageManager.checkPlayersReady()
    -- if everyone is ready, start the gane
    if readyCount == playerCount then
        stageManager.setStage("game")
        print("Starting game!")
        ready = {}
        readyCount = 0
    else
        print("Cannot start game: " .. readyCount .. " / " .. playerCount .. " players are ready!")
    end
end

-- get readyCount / Players
function stageManager.getReadyCount()
    return (readyCount .. " / " .. playerCount .. " players are ready!")
end

return stageManager