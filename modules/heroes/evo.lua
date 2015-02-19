local evo = {}

function evo:draw()
  self.canvas:clear()
  lg.push()
  lg.setCanvas(self.canvas)
  love.graphics.setShader( outline )
--  self.anim:draw(math.floor(self.x), math.floor(self.y), 0, .5, .5,  self.frSz / 2, self.frSz - 80)
  lg.origin()
  self.anim:draw(0, 0, 0, 1, 1)
  love.graphics.setShader()
  lg.setCanvas(canvas)
  lg.pop()
  love.graphics.setColor(wlight)
  
  lg.draw(self.canvas, math.floor(self.x), math.floor(self.y), 0, .5, .5,  self.frSz / 2, self.frSz - 80)
  self.anim:draw(math.floor(self.x), math.floor(self.y), 0, .5, .5,  self.frSz / 2, self.frSz - 80)
--  lg.draw(self.canvas, 0, 0)
end

function evo:update(dt, collision)
  self.outlinezoom = maths.clamp(.002/cam.zoom + .001, .001, .006)
  outline:send( "stepSize",{self.outlinezoom, self.outlinezoom} )
--  outline:send( "stepSize", self.outlinezoom )
  -- Update Evo's coordinates
	self.xvel, self.yvel = self.body:getLinearVelocity()
	self.xvel, self.yvel = math.floor(self.xvel), maths.round(self.yvel)
	local ex, ey, er = self:input(collision)
  -- Evo's physics
	self.x, self.y = self.body:getWorldCenter()
	self.body:setLinearVelocity(self.xvel + ex, self.yvel + ey)
  
  self:astateUpdate()
  self.anim:update(dt)
end

function evo:init()
  self.frSz = 192
  self.frDr = 1/10 -- 1 / fps = frame duration
  self.canvas = lg.newCanvas(256, 256)
--  outline:send( "stepSize",{.002*cam.zoom,.002*cam.zoom} )
  
  self.img = { -- First we set up sprite sheets
    I = love.graphics.newImage('gfx/evo/idle.png'),
    J = love.graphics.newImage('gfx/evo/jump.png'),
  }
--  for i=1, #self.img do
--    self.img[i]:setWrap("clamp", "clamp")
--  end
--  self.img.I:setWrap("clamp", "clamp")
--  self.img.J:setWrap("clamp", "clamp")
	self.anims = {
    idle = newAnimation(self.img.I, self.frSz, self.frSz, self.frDr, 18),
    idleL = newAnimation(self.img.I, self.frSz, self.frSz, self.frDr, 18),
    jump = newAnimation(self.img.J, self.frSz, self.frSz, self.frDr, 2),
  }
  self.h = 95
	self.x = 260
	self.y = 448
	self.r = 0
	self.xvel = 0
	self.yvel = 0
  self.name = "Evo"

	-- Get a smaller local handle
--	local ara = layer.ara
--	local evo = layer.evo
	--local ct = layer.checktile
	evo.anim = evo.anims.idle -- evo starts Idle
  evo.state = {
    facing = "left",
  }
  self.anims.idleL:flipH()
  
  self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
  self.originSh = love.physics.newCircleShape(24)
	self.originFi = love.physics.newFixture(self.body, self.originSh)
  self.originFi:setUserData(self)
  self.body:setMassData( 0, 0, 81, 1 )
	self.body:setLinearDamping(.5)
end

function evo:input()
  local x, y = 0, 0
	local down = love.keyboard.isDown
	local xvel, yvel = evo.body:getLinearVelocity()
  
  if down("lalt") then
    lalt = true
  end
  if down("lctrl") then
    lctrl = true
  elseif down("lshift") then
    if down("kp8") then  end
    if down("kp5") then  end
    if down("kp4") then  end
    if down("kp6") then  end
  else
    if down("kp8") then y = y - 50 end
    if down("kp5") then y = y + 10 end
    if down("kp4") then x = x - 10 end
    if down("kp6") then x = x + 10 end
  end
  
  return x, y, self.r
end

function evo:astateUpdate()
  if (math.abs(evo.xvel) > 0) then
    evo.state.facing = "left" evo.anim = evo.anims.idleL
  else
    evo.state.facing = "right" evo.anim = evo.anims.idle
  end
end

return evo