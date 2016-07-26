require "TEsound"
function love.load()
  width , height = 1600, 900
  love.window.setMode(width, height, {fullscreen = true})
  love.graphics.setDefaultFilter("nearest")
  test = love.graphics.newImage("sprites/test.png")
  sound = love.audio.newSource("music/music.mp3")
  love.audio.play(sound)
  love.audio.setVolume(0.115)
  love.audio.setVelocity( 1, 1, 1)
  x, y = 0, 0
  speed = 165
  cdt = 3
  cd = 0
  isSprinting = 0
end

function love.update(dt)
  cd = cd - dt
  if love.keyboard.isDown("s") then
    y = y + speed*dt
  end
  if love.keyboard.isDown("z") then
    y = y - speed*dt
  end
  if love.keyboard.isDown("d") then
    x = x + speed*dt
  end
  if love.keyboard.isDown("q") then
    x = x - speed*dt
  end
  if love.keyboard.isDown("lshift") and cd < 0 then
    cd = cdt
    speed = 250
    isSprinting = 3
    love.audio.setVelocity( 1, 1, 1)
  end
  if isSprinting > 0 then isSprinting = isSprinting - dt
    if isSprinting < 0 then speed = 165
    end
  end
end

function love.draw()
  love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 1540, 05)
  love.graphics.draw(test, x, y, 0, 2)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
