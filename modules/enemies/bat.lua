local ent = {}

function ent:load( name, x, y, size, facing, health, r )
  self.x, self.y = x or 0, y or 0
  self.size = 16
  self.frDr = 1/10
  self.sheets = {
    idle = love.graphics.newImage('gfx/enem/bat.png'),
  }
  self.anims = {
    idle = newAnimation(self.sheets.idle, self.size, self.size, self.frDr, 0),
  }
  self.health = health or math.random(0,200)
  self.facing = facing or "front"
  self.size = self.size or size
  self.img = self.sheets.idle
  self.anim = self.anims.idle
  self.r = r or 0
  self.name = name or "bat" .. math.random(1, 1000)
--  if t then
--    table.insert(t, #t)
--  end
  self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
--  self.originSh = love.physics.newCircleShape(self.size * .8)
  self.originSh = love.physics.newRectangleShape(self.size * .8, self.size * .8)
  self.originFi = love.physics.newFixture(self.body, self.originSh)
  self.originFi:setRestitution(.8)
  self.body:setMass(self.size)
  self.body:setAngularDamping(2)
  self.body:setLinearDamping(.5)

  self.originFi:setUserData(self)
end

function ent:update(dt, player)
  self.distance = self:getDistanceTo(player)
  local batgo
  if self.state ~= "dying" and self.state ~= "dead" then
    if math.abs(self.distance) <= 400 then self.state = "seeking" end
    if self.state == "seeking" then
      batgo = flux.to(s.enemies[i], 5, { x = player.x + self.size * maths.sign(self.distance), y = player.y - player.h + self.size}):delay(1)
    end
    self.body:setPosition(self.x, self.y)
    local _, ehy = math.compG(0, 0, 0, -forces.gravity, dt)
    self.body:setLinearVelocity(0, ehy)
    self.x, self.y = self.body:getPosition()
  else
    if batgo then batgo:stop() end
  end      
  self.anim:update(dt)
end

function ent:draw()
  if self.state ~= "dying" then
    if self.flippedV == true then self.anim:flipV() self.flippedV = false end
    self.anim:draw(self.x, self.y, self.r, 1, 1, self.size, self.size)
  else
    if self.flippedV ~= true then self.anim:flipV() self.flippedV = true end
    self.anim:stop()
    self.anim:draw(self.x, self.y, self.r, 1, 1, self.size, self.size / 2)
  end
end

return ent