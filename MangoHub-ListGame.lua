local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local games = {
    -- Grow a Garden
    [126884695634066] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-GAG.lua",
    -- Steal a brainrot
    [109983668079237] = "https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-SAB.lua",
    -- 99 days in the forest
    [79546208627805] =
"https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-99DITF.lua",
    -- Doors
    [2440500124] =
"https://raw.githubusercontent.com/Vinreach/MangoHub-Script/refs/heads/main/MangoHub-DOORS.lua",
}

local function notify(title, content, icon)
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = 3,
        Icon = icon
    })
end

local scriptLink = games[game.PlaceId]

if scriptLink then
    notify("✅ Supported Game", "Detected game!", "check")
    pcall(function()
        loadstring(game:HttpGet(scriptLink))()
    end)
else
    notify("🚫 Not Supported", "Your current game is not supported.", "warning")
end