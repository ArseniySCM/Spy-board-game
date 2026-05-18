local socket = require("socket")
local json = require("json")

local M = {}

M.port = 12345
M.udpPort = 12346

local server = nil
local client = nil
local udp = nil
local clients = {} 

function M.getHostIP()
    local s = socket.udp()
    s:setpeername("8.8.8.8", 80)
    local ip = s:getsockname()
    s:close()
    return ip
end

function M.startServer()
    server = socket.bind("*", M.port)
    if server then
        server:settimeout(0)
        print("Server started on port " .. M.port)
        
        udp = socket.udp()
        udp:settimeout(0)
        udp:setsockname("*", M.udpPort)
        return true
    end
    return false
end
function M.broadcastPresence(roomName, roomCode)
    if udp then
        local data = json.encode({
            type = "discovery", 
            name = roomName, 
            code = roomCode,
            ip = M.getHostIP(), 
            port = M.port
        })
        udp:setoption("broadcast", true)
        udp:sendto(data, "255.255.255.255", M.udpPort)
    end
end

-- --- CLIENT ---
function M.startClient(ip)
    client = socket.tcp()
    client:settimeout(2) -- Shorter timeout for code joining
    local success = client:connect(ip, M.port)
    if success then
        client:settimeout(0)
        return true
    end
    client = nil
    return false
end

function M.findServerByCode(code, callback)
    local dUdp = socket.udp()
    dUdp:settimeout(0)
    dUdp:setsockname("*", M.udpPort)

    local foundIp = nil
    local iterations = 0
    local maxIterations = 50 -- approx 5 seconds

    local function check()
        iterations = iterations + 1
        local data, ip, port = dUdp:receivefrom()
        if data then
            local decoded = json.decode(data)
            if decoded and decoded.type == "discovery" and tostring(decoded.code) == tostring(code) then
                foundIp = decoded.ip
            end
        end

        if foundIp or iterations >= maxIterations then
            dUdp:close()
            callback(foundIp)
        else
            timer.performWithDelay(100, check)
        end
    end

    check()
end

function M.send(data)
    local msg = json.encode(data) .. "\n"
    if client then
        client:send(msg)
    elseif server then
        for i=#clients, 1, -1 do
            local c = clients[i]
            local ok = c:send(msg)
            if not ok then table.remove(clients, i) end
        end
    end
end

function M.update(onData)
    if server then
        local newClient = server:accept()
        if newClient then
            newClient:settimeout(0)
            table.insert(clients, newClient)
            print("New client connected")
        end
        
        for i=#clients, 1, -1 do
            local c = clients[i]
            local data, err = c:receive("*l")
            if data then
                local decoded = json.decode(data)
                if decoded then onData(decoded, c) end
            elseif err == "closed" then
                table.remove(clients, i)
            end
        end
    end
   
    if client then
        local data, err = client:receive("*l")
        if data then
            local decoded = json.decode(data)
            if decoded then onData(decoded) end
        elseif err == "closed" then
            client = nil
            print("Connection lost")
        end
    end
end

function M.stop()
    if server then server:close() server = nil end
    if client then client:close() client = nil end
    if udp then udp:close() udp = nil end
    clients = {}
end

return M
