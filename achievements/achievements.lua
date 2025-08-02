local achievements_module = {}

-- user defined achievements configuration
local config = {}

-- badge module
local badge = require("badge")

-- function to check and unlock achievements
local function checkAndUnlockAchievements(playerStorage, new_value, achievement_def)
    if new_value >= achievement_def.goal then
        if achievement_def.badge == "noob" then
            print("noob achievement should be unlocked")
        end
        -- check if achievement is already unlocked
        playerStorage:Get(achievement_def.badge, function(success, results)
            if not success  or results == nil then
                -- achievement is not unlocked
                print("checkAndUnlockAchievements called, new_value: " .. new_value .. " goal_def.goal: " .. goal_def.goal)
                badge:unlockBadge(goal_def.badge, function(err) if not err then print("Achievement unlocked: " .. goal_def.badge) end end)
                playerStorage:Set(goal_def.badge, true, function(success) end)
            end
        end)
    end
end

-- GET function
function achievements_module:Get(key, callback)
    local playerStorage = KeyValueStore(Player.UserID)
    playerStorage:Get(key, function(success, results)
        if success and results and results[key] then
            callback(results[key])
        else
            callback(0)
        end
    end)
end

-- SET function
function achievements_module:Set(key, value)
    -- get achievement definition
    local achievement_def = config[key]
    if not achievement_def then
        error("Achievement " .. key .. " not found in config")
    end

    local playerStorage = KeyValueStore(Player.UserID)
    playerStorage:Set(key, value, function(success) if success and key == "games-played"then print("Set " .. key .. " to " .. value) end end)

    -- check for goal completion
    if type(achievement_def[1]) == "table" then
        for _, goal_def in ipairs(achievement_def) do
            checkAndUnlockAchievements(playerStorage, value, goal_def)
        end
    else
        print("achievement_def.goal: " .. achievement_def.goal .. ", achievement_def.badge: " .. achievement_def.badge)
        checkAndUnlockAchievements(playerStorage, value, achievement_def)
    end
end

-- INCREMENT function
function achievements_module:Increment(key, amount)
    amount = amount or 1 -- 1 is default
    self:Get(key, function(current_value)
        --print("increment called, current_value: " .. current_value .. " amount: " .. amount)
        local new_value = current_value + amount
        print("incrementing to new_value: " .. new_value)
        self:Set(key, new_value)
    end)
end

-- final setup
local mt = {
    __call = function(self, user_config)
        config = user_config
    end
}

setmetatable(achievements_module, mt)
return achievements_module