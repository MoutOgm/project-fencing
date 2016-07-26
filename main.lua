require "modules.TEsound"
require "socket"
require "math"
require "modules.tools"
function love.load()
  math.randomseed(os.time())


  udp = socket.udp()
  udp:settimeout(0)
  udp:setpeername("localhost", 53715)
  id = tostring(math.random(0, 100000))
  udp:send(id.." connected")

  width , height = 1600, 900
  love.window.setMode(width, height, {fullscreen = true})
  love.graphics.setDefaultFilter("nearest")
  test = love.graphics.newImage("sprites/test.png")
  sound = love.audio.newSource("music/music.mp3")
  love.audio.play(sound)
  love.audio.setVolume(0)
  player = {x = test:getWidth(), y = test:getHeight(), cd = 0, isSprinting = 0}
  playerSpeed = 230
  playerSprintingSpeed = 280
  cdt = 3
  updateRate = 0.1
  timeUntilUpadate = 0
  enemy = {x = 25056565, y = 55656}
end

function love.update(dt)
  TEsound.cleanup()
  udpmessage()
  move(dt)
  if player.x < 0 then player.x = width elseif player.x > width then player.x = 0 end
  if player.y < 0 then player.y = height elseif player.y > height then player.y = 0 end
  if player.isSprinting > 0 then player.isSprinting = player.isSprinting - dt end

  if timeUntilUpadate < 0 then
    timeUntilUpadate = updateRate
    udp:send(id.." position ".. player.x.." "..player.y)
  else
    timeUntilUpadate = timeUntilUpadate - dt
  end
end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 1540, 05)
  love.graphics.draw(test, player.x, player.y, 0, 2, 2, test:getWidth()/2, test:getHeight()/2) --  love.graphics.circle("fill", player.x, player.y, 9)
  love.graphics.setColor(252, 45, 201)
  love.graphics.draw(test, enemy.x, enemy.y, 0, 2, 2, test:getWidth()/2, test:getHeight()/2)
end

function love.keypressed(key)
  if key == "lshift" and player.cd < 0 then
    player.cd = cdt
    isSprinting = 3
  elseif key == "escape" then
    udp:send(id.." disconnected")
    love.event.quit()
  end
end
function udpmessage()
  repeat
    data = udp:receive()
    if data ~= nil then
      data = tools.split(data, " ")
      if data [1] ~= id then
        print(data [2])
        if data [2] == "position" then
          enemy.x = data [3]
          enemy.y = data [4]
        end
      end
    end

  until not data
end
function move(dt)
  local speed = playerSpeed
  if player.isSprinting > 0 then speed = playerSprintingSpeed end
  player.cd = player.cd - dt
  if love.keyboard.isDown("s") then
    player.y = player.y + speed*dt
  end
  if love.keyboard.isDown("z") then
    player.y = player.y - speed*dt
  end
  if love.keyboard.isDown("d") then
    player.x = player.x + speed*dt
  end
  if love.keyboard.isDown("q") then
    player.x = player.x - speed*dt
  end
end
