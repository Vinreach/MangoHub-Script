-- Load WindUI with error handling
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not success then
    warn("Failed to load WindUI:", WindUI)
    return
end

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

-- Get game identifiers
local placeId = tostring(game.PlaceId)
local gameId = tostring(game.GameId)

-- Find script link (check PlaceId first, then GameId)
local scriptLink = games[placeId] or games[gameId]

-- Show notification
if WindUI and WindUI.Notify then
    WindUI:Notify({
        Title = scriptLink and "Supported Game" or "Not Supported",
        Content = scriptLink and "Detected game!" or "Your current game is not supported.",
        Duration = 5,
        Icon = scriptLink and "check" or "warning"
    })
end

-- Load the game script if found
if scriptLink then
    local scriptSuccess, scriptError = pcall(function()
        local scriptCode = game:HttpGet(scriptLink)
        if scriptCode and scriptCode ~= "" then
            loadstring(scriptCode)()
        else
            error("Empty or invalid script content")
        end
    end)
    
    if not scriptSuccess then
        warn("Failed to load game script:", scriptError)
        if WindUI and WindUI.Notify then
            WindUI:Notify({
                Title = "Script Error",
                Content = "Failed to load the game script",
                Duration = 5,
                Icon = "warning"
            })
        end
    end
end