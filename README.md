# BlipMods

## Achievements Module:

### Setup:

```lua
Modules = { achievements = "github.com/NickB-30/BlipMods/achievements" }
local achievements = require(Modules.achievements)
```

### Initialize the module with your achievement definitions and badge identifiers:

```lua
achievements({
  ["games-played"] = {
    {
      goal = 5,
      badge = "noob",
    },
    {
      goal = 20,
      badge = "rookie",
    },
  },
  ["score"] = {
    {
      goal = 500,
      badge = "good",
    },
    {
      goal = 1000,
      badge = "great",
    },
  },
})
```

### In your game code, you can either **SET** or **INCREMENT** achievement counters with:

```lua
achievements:Set("score", value)
```

or

```lua
achievements:Increment("games-played", value) -- value is optional, defaults to 1
```
