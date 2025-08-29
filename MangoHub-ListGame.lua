--// Load WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

--// List game hỗ trợ
local supportedGames = {
    ["Grow a Garden"] = 126884695634066,
    ["Steal a brainrot"] = 109983668079237,
    ["DOORS"] = 7326934954,
}

local currentPlaceId = game.PlaceId
local isSupported = false

for name, id in pairs(supportedGames) do
    if currentPlaceId == id then
        WindUI:Notify({
            Title = "✅ Supported Game",
            Content = "Detected: " .. name,
            Duration = 3,
            Icon = "check"
        })

        isSupported = true

        --// Load Key System của Red
        loadstring(game:HttpGet("https://raw.githubusercontent.com/RoyRedRedVN/Script/refs/heads/main/Mango-GAG"))()
        break
    end
end

if not isSupported then
    WindUI:Notify({
        Title = "Notification Warning",
        Content = "🚫 Your current game is not supported.",
        Duration = 3,
        Icon = "warning",
    })
end