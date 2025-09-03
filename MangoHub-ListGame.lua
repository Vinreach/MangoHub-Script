local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local games = {
    -- Grow a Garden
    [126884695634066] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-GAG.lua",
    -- Steal a brainrot
    [109983668079237] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-SAB.lua",
    -- 99 days in the forest
    [79546208627805] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-99DITF.lua",
    -- Doors
    [2440500124] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-DOORS.lua",
    -- Arena Of Blox
    [7832036655] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-AOB.lua",
    -- POOP
    [7932671830] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-POOP.lua",
    -- SLAP BATTLE ( ANTI CHEAT IS REAL )
    [2380077519] =
"https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-SlapBattle.lua",
    -- SLAP BATTLE ( BUT BAD ANTI CHEAT IS REAL )
    [13741394801] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-SlapBattle.lua"
}

local scriptLink = games[game.PlaceId]

WindUI:Notify({
    Title = scriptLink and "Supported Game" or "Not Supported",
    Content = scriptLink and "Detected game!" or "Your current game is not supported.",
    Duration = 3,
    Icon = scriptLink and "check" or "warning"
})

if scriptLink then pcall(loadstring, game:HttpGet(scriptLink)) end