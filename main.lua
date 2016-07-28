require "modules.TEsound"
require "socket"
require "math"
require "modules.tools"
require "modules.physics"
require "modules.networking"

function love.load()

  math.randomseed(os.time())
  options = tools.readOptions("options.ini")
  networking.load(options.ip, options.port)
  width , height = 1600, 900
  love.window.setMode(width, height, {fullscreen = true})
  love.graphics.setDefaultFilter("nearest")
  epee = love.graphics.newImage("sprites/epee.png")
  test = love.graphics.newImage("sprites/test.png")
  sound = love.audio.newSource("music/music.mp3")
  soundm = love.audio.newSource("music/step.wav")
  love.audio.setVolume(1)
  isPlaying = false
  player = {direction = "right", cd = 0, isSprinting = 0, x = 0, y = 0, momentum = {x = 0, y = 0}, swordRotation = "forward", onGround = true}
  sizeplayer = test:getWidth()
  playerScale = 4
  playerSpeed = 300
  playerSprintingSpeed = 500
  cdt = 3
  updateRate = 0.001
  timeUntilUpadate = 0
  gravity = 1000
  groundHeight = 800
  enemy = {direction = "right", x = 25056565, y = 55656}
end

function love.update(dt)
  TEsound.cleanup()
  networking.receive()
  physics.update(dt)
  movements(dt)
  if player.isSprinting > 0 then player.isSprinting = player.isSprinting - dt end

  if timeUntilUpadate < 0 then
    timeUntilUpadate = updateRate
    udp:send(id.." position ".. player.x.." "..player.y)
    udp:send(id.." direction ".. player.direction)
  else
    timeUntilUpadate = timeUntilUpadate - dt
  end
end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 1533, 05)
  if player.direction == "right" then
    love.graphics.draw(test, player.x, player.y, 0, playerScale, playerScale, test:getWidth()/2, test:getHeight()/2)
  else
    love.graphics.draw(test, player.x, player.y, 0,  - playerScale, playerScale, test:getWidth()/2, test:getHeight()/2)
  end

  if player.direction == "right" then
    if player.swordRotation == "forward" then
      love.graphics.draw(epee, player.x + playerScale * 6, player.y + 4, 0, playerScale, playerScale, 0, epee:getHeight()/2)
    elseif player.swordRotation == "up" then
      love.graphics.draw(epee, player.x + playerScale * 6, player.y + 4, - math.pi/4,  playerScale, playerScale, 0, epee:getHeight()/2)
    elseif player.swordRotation == "down" then
      love.graphics.draw(epee, player.x + playerScale * 6, player.y + 4, math.pi/4, playerScale, playerScale, 0, epee:getHeight()/2)
    end
  else
    if player.swordRotation == "forward" then
      love.graphics.draw(epee, player.x - playerScale * 6, player.y + 4, math.pi, playerScale, playerScale, 0, epee:getHeight()/2)
    elseif player.swordRotation == "up" then
      love.graphics.draw(epee, player.x - playerScale * 6, player.y + 4, math.pi/4*5, playerScale, playerScale, 0, epee:getHeight()/2)
    elseif player.swordRotation == "down" then
      love.graphics.draw(epee, player.x - playerScale * 6, player.y + 4, math.pi/4*3, playerScale, playerScale, 0, epee:getHeight()/2)
    end
  end

  love.graphics.setColor(252, 45, 201)
  if enemy.direction == "right" then
    love.graphics.draw(test, enemy.x, enemy.y, 0, playerScale, playerScale, test:getWidth()/2, test:getHeight()/2)
  else
    love.graphics.draw(test, enemy.x, enemy.y, 0,  - playerScale, playerScale, test:getWidth()/2, test:getHeight()/2)
  end

  love.graphics.setColor(255, 255, 255)
  if isPlaying then
    love.graphics.setColor(255,3,59)
  end
  love.graphics.rectangle("fill", 1580, 0, 20, 20)
end

function love.mousepressed (x, y)
  if x > 1580 and  x < 1600  and y > 0 and y < 20 then
    if not isPlaying then isPlaying = true
      love.audio.play(sound)
    else isPlaying = false
      love.audio.stop(sound)
    end
  end
end

function love.keypressed(key)
  if key == "lshift" and player.cd < 0 then
    player.cd = cdt
    player.isSprinting = 1
  elseif key == "escape" then
    udp:send(id.." disconnected")
    love.event.quit()
  elseif key == "space" and player.onGround then
    player.momentum.y = -700
  elseif key == "f" then
    player.X = 800
    player.y = 0
  elseif key == "z" and player.swordRotation == "forward" then
    player.swordRotation = "up"
  elseif key == "s" and player.swordRotation == "forward" then
    player.swordRotation = "down"
  end
end

function love.keyreleased(key)
  if key == "z" and player.swordRotation == "up" then
    player.swordRotation = "forward"
  elseif key == "s" and player.swordRotation == "down" then
    player.swordRotation = "forward"
  end
end

function movements(dt)
  local speed = playerSpeed
  if player.isSprinting > 0 then
    speed = playerSprintingSpeed
  else
    player.cd = player.cd - dt
  end

  if love.keyboard.isDown("d") and not physics.intersect(player.x + speed*dt - sizeplayer/2*playerScale, player.y - sizeplayer/2*playerScale, player.x + speed*dt + sizeplayer/2*playerScale, player.y + sizeplayer/2*playerScale, enemy.x - sizeplayer/2*playerScale, enemy.y - sizeplayer/2*playerScale, enemy.x + sizeplayer/2*playerScale, enemy.y + sizeplayer/2*playerScale) then
    player.x = player.x + speed*dt
    if player.onGround then
      love.audio.play(soundm)
    end
    player.direction = "right"
  end

  if love.keyboard.isDown("q") and not physics.intersect(player.x - speed*dt - sizeplayer/2*playerScale, player.y - sizeplayer/2*playerScale, player.x - speed*dt + sizeplayer/2*playerScale, player.y + sizeplayer/2*playerScale, enemy.x - sizeplayer/2*playerScale, enemy.y - sizeplayer/2*playerScale, enemy.x + sizeplayer/2*playerScale, enemy.y + sizeplayer/2*playerScale) then
    player.x = player.x - speed*dt
    if player.onGround then
      love.audio.play(soundm)
    end
    player.direction = "left"
  end
end
