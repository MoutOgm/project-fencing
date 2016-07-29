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
          enemy.x = data [4]
          enemy.y = data [5]
        elseif data [2] == "direction" then
          enemy.direction = data [6]
        elseif data [2]  == "swordRotation" then
          enemy.swordRotation.forward = data [7]
          enemy.swordRotation.up = data [8]
          enemy.swordRotation.down = data [9]
        end
      end
    end
  until not data
end
