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
  scalingFactor = love.graphics.getWidth()/width
  love.graphics.setDefaultFilter("nearest")

  directions = {right = {up = math.pi/4*-1, forward = math.pi/4*0, down = math.pi/4*1}, left = {up = math.pi/4*1, forward = math.pi/4*0, down = math.pi/4*-1}, flip = {right = 1, left = -1}}

  playerSprites = {}
  playerSprites.normal = love.graphics.newImage("sprites/player/normal.png")
  playerSprites.run1 = love.graphics.newImage("sprites/player/run1.png")
  playerSprites.run2 = love.graphics.newImage("sprites/player/run2.png")
  playerSprites.run3 = love.graphics.newImage("sprites/player/run3.png")
  playerSprites.run4 = love.graphics.newImage("sprites/player/run4.png")

  epee = love.graphics.newImage("sprites/epee.png")
  sound = love.audio.newSource("music/music.mp3")
  soundm = love.audio.newSource("music/step.wav")
  love.audio.setVolume(1)
  isPlaying = false
  player = {direction = "right", cd = 0, isSprinting = 0, x = 0, y = 0, momentum = {x = 0, y = 0}, swordRotation = "forward", onGround = true, spriteIndex = "normal"}
  sizeplayer = playerSprites.normal:getWidth()
  playerScale = 6
  playerSpeed = 300
  playerSprintingSpeed = 500
  cdt = 3
  updateRate = 0.001
  gravity = 1000
  groundHeight = 800
  timeUntilUpdate = 0
  animations = {none = {'normal'}, run = {'run1', 'run2', 'run3', 'run4'}}
  animation = {type = "none", time = 0, speed = 0}
  enemy = {direction = "right", x = 2565, y = 55656, swordRotation = "forward", spriteIndex = "normal"}
end

function love.update(dt)
  animation.time = animation.time + animation.speed*dt
  player.spriteIndex = animations[animation.type][(math.floor(animation.time) - math.floor(animation.time/#animations[animation.type])*#animations[animation.type])+1]
  TEsound.cleanup()
  networking.receive()
  physics.update(dt)
  movements(dt)
  if player.isSprinting > 0 then player.isSprinting = player.isSprinting - dt end

  if timeUntilUpdate < 0 then
    timeUntilUpdate = updateRate
    udp:send(id.." position ".. player.x.." "..player.y)
    udp:send(id.." direction ".. player.direction)
    udp:send(id.." swordRotation ".. player.swordRotation)
  else
    timeUntilUpdate = timeUntilUpdate - dt
  end
end

function love.draw()
  love.graphics.scale(scalingFactor, scalingFactor)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 1533, 05)

  -- DESSINER LE SOL
  love.graphics.setColor(64, 54, 38)
  love.graphics.rectangle("fill", 0, groundHeight, width, height-groundHeight)

  -- DESSINER LE JOUEUR
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(playerSprites[player.spriteIndex], player.x, player.y, 0, playerScale*directions.flip[player.direction], playerScale, playerSprites[player.spriteIndex]:getWidth()/2, playerSprites[player.spriteIndex]:getHeight())

  -- DESSINER L'ÉPÉE
  love.graphics.draw(epee,
    player.x + playerScale*2.5*directions.flip[player.direction] + math.cos(directions[player.direction][player.swordRotation]*0.5)*playerScale*directions.flip[player.direction],
    player.y - 6.5*playerScale + math.sin(directions[player.direction][player.swordRotation]*0.5)*playerScale*directions.flip[player.direction],
    0.4*directions[player.direction][player.swordRotation], 0.4*playerScale*directions.flip[player.direction], playerScale, 0, epee:getHeight()/2)

  love.graphics.points(player.x, player.y)

  -- DESSINER LE JOUEUR ENNEMI
  love.graphics.setColor(252, 45, 201)
  love.graphics.draw(playerSprites[enemy.spriteIndex], enemy.x, enemy.y, 0, playerScale*directions.flip[enemy.direction], playerScale, playerSprites[enemy.spriteIndex]:getWidth()/2, playerSprites[enemy.spriteIndex]:getHeight())

  -- DESSINER L'ÉPÉE ENNEMIE
  love.graphics.draw(epee,
    enemy.x + playerScale*2.5*directions.flip[enemy.direction] + math.cos(directions[enemy.direction][enemy.swordRotation]*0.5)*playerScale*directions.flip[enemy.direction],
    enemy.y - 6.5*playerScale + math.sin(directions[enemy.direction][enemy.swordRotation]*0.5)*playerScale*directions.flip[enemy.direction],
    0.4*directions[enemy.direction][enemy.swordRotation], 0.4*playerScale*directions.flip[enemy.direction], playerScale, 0, epee:getHeight()/2)

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
  elseif key == 'd' or key == 'q' then
    animation.type = 'run'
    animation.time = 0
    animation.speed = 14
  end
end

function love.keyreleased(key)
  if key == "z" and player.swordRotation == "up" then
    player.swordRotation = "forward"
  elseif key == "s" and player.swordRotation == "down" then
    player.swordRotation = "forward"
  elseif key == 'd' or key == 'q' then
    animation.type = 'none'
    animation.time = 0
    animation.speed = 0
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
