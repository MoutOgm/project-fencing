physics = {}

function physics.intersect(x0, y0, x1, y1, x2, y2, x3, y3)
  if x0 < x3 and y0 < y3 and x1 > x2 and y1 > y2 then
    return true
  end
  return false
end

function physics.update(dt)
  player.momentum.y = player.momentum.y + gravity*dt
  if player.y+player.momentum.y*dt < groundHeight then
    player.onGround = false
    player.y = player.y + player.momentum.y*dt
  else
    player.y = groundHeight
    player.onGround = true
  end
  player.x = player.x + player.momentum.x*dt
end
