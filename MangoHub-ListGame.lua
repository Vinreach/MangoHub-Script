local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local games = {
    -- Grow a Garden
    ["126884695634066"] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-GAG.lua",
    -- Steal a brainrot
    ["109983668079237"] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-SAB.lua",
    -- 99 days in the forest
    ["79546208627805"] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-99DITF.lua",
    -- Doors
    ["2440500124"] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-DOORS.lua",
    -- Arena Of Blox
    ["7832036655"] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-AOB.lua",
    -- POOP
    ["7932671830"] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-POOP.lua",
    -- Slap Battle (AC thật)
    ["2380077519"] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-SlapBattle.lua",
    -- Slap Battle (AC nhẹ)
    ["13741394801"] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-SlapBattle.lua"
}

-- Universal fallback
local universalLink = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-Universal.lua"

local placeId = tostring(game.PlaceId)
local gameId = tostring(game.GameId)
local scriptLink = games[placeId] or games[gameId] or universalLink

-- Notify detect game
WindUI:Notify({
    Title = scriptLink == universalLink and "Universal Mode" or "Supported Game",
    Content = scriptLink == universalLink and "Loaded universal script." or "Detected game!",
    Duration = 5,
    Icon = scriptLink == universalLink and "globe" or "check"
})

local success, result = pcall(function()
    loadstring(game:HttpGet(scriptLink))()
end)

if not success then
    WindUI:Notify({
        Title = "Error Loading Script",
        Content = tostring(result),
        Duration = 8,
        Icon = "x"
    })
end