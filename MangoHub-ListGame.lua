--// Load WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

--// Danh sách game Vinreach
local games = {
    -- Grow a Garden
    [126884695634066] = "https://raw.githubusercontent.com/RoyRedRedVN/Script/refs/heads/main/Mango-GAG.lua",
    -- Steal a brainrot
    [109983668079237] = "https://raw.githubusercontent.com/RoyRedRedVN/Script/refs/heads/main/Mango-SAB.lua",
    -- DOORS
    [7326934954] = "https://raw.githubusercontent.com/RoyRedRedVN/Script/refs/heads/main/Mango-DOORS.lua",
}

--// Hàm notify gọn
local function notify(title, content, icon)
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = 3,
        Icon = icon
    })
end

--// Check game
local scriptLink = games[game.PlaceId]

if scriptLink then
    notify("✅ Supported Game", "Detected game!", "check")
    pcall(function()
        loadstring(game:HttpGet(scriptLink))()
    end)
else
    notify("🚫 Not Supported", "Your current game is not supported.", "warning")
end