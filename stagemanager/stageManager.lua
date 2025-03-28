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
        print(playerCount .. " players in the game!")
        local e = Event()
        e.number = playerCount + 1
        e:SendTo(Players)
    end)
    LocalEvent:Listen(LocalEvent.Name.OnPlayerLeave, function(Player)
        print(Player.Username .." has left the game!")
        print(playerCount .. " players in the game!")
        local e = Event()
        e.number = playerCount - 1
        e:SendTo(Players)
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
        local readyEvent = Event()
        readyEvent.ready = readyCount - 1
        readyEvent:SendTo(Players)
        print(Player.Username .. " unreadied!")
    else
        ready[Player] = "ready"
        local readyEvent = Event()
        readyEvent.ready = readyCount + 1
        readyEvent:SendTo(Players)
        print(Player.Username .. " is now ready!")
    end
    print(readyCount .. " players ready")
end

-- Network event to sync player count (Client-side)
if not IsServer then
    Client.DidReceiveEvent = function(event)
        -- do something with the event
        if event.number then
            playerCount = event.number
        end
        if event.ready then
            readyCount = event.ready
        end
    end
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