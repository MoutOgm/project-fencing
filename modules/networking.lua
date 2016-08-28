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
          enemy.direction = data [3]
        elseif data [2]  == "swordRotation" then
          enemy.swordRotation = data[3]
          if data [2] == "up" then
            enemy.spriteIndex = "epeeUp"
          elseif data [2] == "down" then
            enemy.spriteIndex = "epeeDown"
          else
            enemy.spriteIndex = "normal"
          end
        end
      end
    end
  until not data
end
