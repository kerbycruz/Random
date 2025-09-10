local function RejoinDifferentServer()
    local servers = GetServers()
    for _, server in ipairs(servers.data) do
        if server.id ~= game.JobId and server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
            return
        end
    end

    if servers.nextPageCursor then
        local nextServers = GetServers(servers.nextPageCursor)
        for _, server in ipairs(nextServers.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
                return
            end
        end
    end

    TeleportService:Teleport(placeId, player)
end

RejoinDifferentServer()
