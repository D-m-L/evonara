enemyNames = {
  "bogey",
  "tree",
  "dog,"
}

deademies = {}

function initEnemies(t)
  
  bogeySz = 64
  treeSz = 192
  dogSz = 192
  frDr = .15
  
  sheets = {
    tree = love.graphics.newImage("gfx/enem/tree.png"),
    bogey = love.graphics.newImage("gfx/enem/bogey.png"),
    dogidle = love.graphics.newImage("gfx/enem/dog/idle.png"), 
  }
  anims = {
    bogeyidle = newAnimation(sheets.bogey, bogeySz, bogeySz, frDr, 0),
    treeidle = newAnimation(sheets.tree, treeSz, treeSz, frDr, 0),
    dogidle = newAnimation(sheets.dogidle, dogSz, dogSz, frDr, 8),
    dogidleL = newAnimation(sheets.dogidle, dogSz, dogSz, frDr, 8),
  }
   
  anims.dogidleL:flipH()
end

function addEnemy(t, name, health, x, y, facing)

  if name == nil then
    local bit = math.random(1,#enemyNames)
    if bit == 1 then name = "tree" end
    if bit == 2 then name = "bogey" end
    if bit == 3 then name = "dog" end
  --else name = "dog"
  end
  if health == nil then health = math.random(0,200) end
  if x == nil then x = math.random(400, 1000) end
  if y == nil then y = math.random(500, 800) end
  if facing == nil then facing = "front" end
  
  local size = bogeySz / 2
  local img = sheets.bogey
  local anim = anims.bogeyidle
  if name == "tree" then size = treeSz / 2 img = sheets.tree  anim = anims.treeidle end
  if name == "dog" then size = dogSz / 2 img = sheets.dogidle  anim = anims.dogidle end
    
  table.insert(t, {
      name = name,
      health = health,
      x = x,
      y = y,
      img = img,
      size = size,
      r = 0,
      anim = anim,
      facing = facing,
      state = "idle",
    })
  
  --You can get the "length" of an array using the # operator: #enemies
    t[#t].body = love.physics.newBody(world, t[#t].x, t[#t].y, "dynamic")
    if t[#t].name == "tree" then anim = anims.treeidle
      t[#t].originSh = love.physics.newCircleShape(t[#t].size * .8)
      t[#t].originFi = love.physics.newFixture(t[#t].body, t[#t].originSh)
      t[#t].originFi:setRestitution(1)
      t[#t].body:setMass(t[#t].size)
      t[#t].body:setAngularDamping(4)
      t[#t].body:setLinearDamping(5)
    end
    if t[#t].name == "bogey" then anim = anims.bogeyidle
      t[#t].originSh = love.physics.newCircleShape(t[#t].size * .8)
      t[#t].originFi = love.physics.newFixture(t[#t].body, t[#t].originSh)
      t[#t].originFi:setRestitution(1)
      t[#t].body:setMass(t[#t].size)
      t[#t].body:setAngularDamping(2)
      t[#t].body:setLinearDamping(.5)
--      t[#t].facing = "front"
    end
    if t[#t].name == "dog" then anim = anims.dogidle
      t[#t].originSh = love.physics.newRectangleShape(t[#t].size - 20, t[#t].size / 2)
      t[#t].originFi = love.physics.newFixture(t[#t].body, t[#t].originSh)
      t[#t].originFi:setRestitution(.1)
      t[#t].body:setMass(t[#t].size)
      t[#t].body:setFixedRotation(true)
      t[#t].body:setLinearDamping(.5)
      t[#t].facing = "right"
    end
    t[#t].originFi:setUserData(t[#t])
    
end

function listEnemies(layer)
  local list =  "The Living: \n"
  for i=1, #layer.enemies do
    if (layer.enemies[i].state ~= "dead") then
      local x, y = math.floor(layer.enemies[i].x), math.floor(layer.enemies[i].y)
      list = list .. i .. ": " .. layer.enemies[i]["name"] .. ", " .. layer.enemies[i].health .. "hp - (" .. x .. ", " .. y .. ") \n"
    end
  end
  list = list .. "\n The Dead: \n" 
  for i=1, #deademies do
    list = list .. i .. ": " .. deademies[i]["name"] .. "\n"
  end
  love.graphics.printf(list, love.window.getWidth()-200, 20, love.window.getWidth()-100)
end

function drawEnemies(spriteLayer)
  local s = spriteLayer
  
  for i=1, #s.enemies, 1 do
    local x, y = s.enemies[i].body:getLinearVelocity()
    --if map:setDrawRange(tx, ty, scrn.w / cam.zoom, (scrn.h / cam.zoom))
    --love.graphics.draw(s.enemies[i].img, s.enemies[i].x, s.enemies[i].y, s.enemies[i].r, 1, .85 + math.abs(y/1000), s.enemies[i].size, s.enemies[i].size)
    if s.enemies[i].name == "bat" then
      local bat = s.enemies[i]
      if bat.state ~= "dying" then
        if s.enemies[i].state == "seeking" then
          s.enemies[i].anim:draw(s.enemies[i].x, s.enemies[i].y, s.enemies[i].r, 1, 1,
           s.enemies[i].size, s.enemies[i].size)
        end
      else
        if bat.flippedV ~= true then bat.anim:flipV() bat.flippedV = true end
        local x,y = s.enemies[i].body:getPosition()
        s.enemies[i].anim:stop()
        s.enemies[i].anim:draw(x, y, s.enemies[i].r, 1, 1,
           s.enemies[i].size, s.enemies[i].size / 2)
      end
    elseif s.enemies[i].name == "dog" then
    s.enemies[i].anim:draw(s.enemies[i].x, s.enemies[i].y, s.enemies[i].r, 1, 1,
      s.enemies[i].size, 140 )
    else
    s.enemies[i].anim:draw(s.enemies[i].x, s.enemies[i].y, s.enemies[i].r, 1, .85 + math.abs(y/1000),
      s.enemies[i].size, s.enemies[i].size)
    end
  end
end

function updateEnemies(s, target, dt)
  if #s.enemies >= 1 then
    for i=1, #s.enemies, 1 do
    local distance = getDistancetoTarget(s.enemies[i], target)
      if s.enemies[i].name == "bat" then
        --Do bat stuff
        local bat = s.enemies[i]
        if bat.state ~= "dying" and bat.state ~= "dead" then
          if math.abs(distance) <= 400 then bat.state = "seeking" end
          if bat.state == "seeking" then
            batgo = flux.to(s.enemies[i], 5, { x = target.x + batSz * maths.sign(distance), y = target.y - target.h + batSz}):delay(1)
          end
          s.enemies[i].body:setPosition(s.enemies[i].x, s.enemies[i].y)
          local _, ehy = math.compG(0, 0, 0, -forces.gravity, dt)
          s.enemies[i].body:setLinearVelocity(0, ehy)
          s.enemies[i].x, s.enemies[i].y = s.enemies[i].body:getPosition()
        else
          --killEnemy(bat)  
          if batgo then batgo:stop() end
        end
        --s.enemies[i].body:setPosition(s.enemies[i].x, s.enemies[i].y)
        --s.enemies[i].body:setLinearVelocity(0, -gravity)
        
      elseif s.enemies[i].name == "bogey" or s.enemies[i].name == "tree" then
        s.enemies[i].x, s.enemies[i].y = s.enemies[i].body:getWorldCenter()
        s.enemies[i].r = s.enemies[i].body:getAngle()
      elseif s.enemies[i].name == "dog" then
        s.enemies[i].x, s.enemies[i].y = s.enemies[i].body:getWorldCenter()
        --s.enemies[i].r = s.enemies[i].body:getAngle()
      end
      
      s.enemies[i].anim:update(dt)
    end
    bringOutYourDead(s.enemies)
  end  
  return distance
end

function getDistancetoTarget(s, target)
  local x1, y1, x2, y2 = 0
  if s.body then
    x1, y1 = s.body:getPosition()
  else x1, y1 = 0, 0 end
  if target.body then
    x2, y2 = target.body:getPosition()
  else x2, y2 = 0, 0 end
  local b = maths.distance(x1, y1, x2, y2)
  return b
end

function deleteAllEnemies(t)
  for i=1, #t, 1 do
   t[i].originFi:destroy()
   t[i].body:destroy()
   t[i] = nil
  end
end

function deleteEnemy(t)
  t.originFi:destroy()
  t.body:destroy()
  t = nil
end

function killEnemy(t)
  deademies[#deademies + 1] = t
  t.state = "dead"
end

function bringOutYourDead(t)
  for i=1, #t, 1 do
    if t[i].state == "delete" then
      deleteEnemy(t[i])
    end
  end
end
