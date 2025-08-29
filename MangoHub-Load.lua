local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/Vinreach/MangoHub/main/GameList.lua"))()

local URL = Games[game.PlaceId]

if URL then
  loadstring(game:HttpGet(URL))()
end
