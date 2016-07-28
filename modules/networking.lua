networking = {}
function networking.load (ip, port)
  udp = socket.udp()
  udp:settimeout(0)
  udp:setpeername(ip, port)
  id = tostring(math.random(0, 100000))
  udp:send(id.." connected")

end

function networking.receive()
  repeat
    data = udp:receive()
    if data ~= nil then
      data = tools.split(data, " ")
      if data [1] ~= id then
        print(data [2])
        if data [2] == "position" then
          enemy.x = data [3]
          enemy.y = data [4]
        elseif data [2] == "direction" then
          
        end
      end
    end
  until not data
end
