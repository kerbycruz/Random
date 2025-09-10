local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local placeId = game.PlaceId
local player = Players.LocalPlayer

local function GetServers(cursor)
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    if cursor then
        url = url .. "&cursor=" .. cursor
    end

    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if success then
        return response
    else
        warn("Failed to get servers: ", response)
        return nil
    end
end

local function RejoinDifferentServer()
    local servers = GetServers()
    if not servers then return end

    for _, server in ipairs(servers.data) do
        if server.id ~= game.JobId and server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
            return
        end
    end

    while servers.nextPageCursor do
        servers = GetServers(servers.nextPageCursor)
        if not servers then break end

        for _, server in ipairs(servers.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
                return
            end
        end
    end

    TeleportService:Teleport(placeId, player)
end

RejoinDifferentServer()
