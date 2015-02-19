local ara = {}

function ara:draw()
  self.anim:draw(math.floor(self.x), math.floor(self.y), self.r, .5, .5, self.frSz / 2, self.frSz - self.h / 2 - 4) -- we set the origin from the draw func
end

function ara:init(map, layer, x, y)
  -- Standard frame size and duration
  self.frSz = 192
  self.frDr = 1/10 -- 1 / fps = frame duration
  self.map = map
  self.layer = layer
  
  -- Build out Ara's Custom Data
	self.img = { -- First we set up sprite sheets
    scrd = { -- Scared
      W = love.graphics.newImage('gfx/ara/scared/walk.png'),
      I = love.graphics.newImage('gfx/ara/scared/idle.png'),
      ItK = love.graphics.newImage('gfx/ara/scared/idle2kneel.png'),
      K = love.graphics.newImage('gfx/ara/scared/kneel.png'),
      --APSsheet = love.graphics.newImage('gfx/ara/scared/pivot.png');
      C1 = love.graphics.newImage('gfx/ara/scared/climb1.png'),
      ItW = love.graphics.newImage('gfx/ara/scared/idle2walk.png'),
      JG = lg.newImage('gfx/ara/scared/jumpGrab.png'),
    }
  }
  local ais = self.img.scrd
	self.anims = {
		walkScared = newAnimation(ais.W, self.frSz, self.frSz, self.frDr, 0),
		idleScared = newAnimation(ais.I, self.frSz, self.frSz, self.frDr * 1.5, 44),
		idle2walkScared = newAnimation(ais.ItW, self.frSz, self.frSz, self.frDr, 0),
		i2kScared = newAnimation(ais.ItK, self.frSz, self.frSz, self.frDr , 0),
		kneelScared = newAnimation(ais.K, self.frSz, self.frSz, self.frDr, 0),
		climb2Scared = newAnimation(ais.C1, self.frSz, self.frSz, self.frDr, 0),
		jumpGrabScared = newAnimation(ais.JG, self.frSz, self.frSz, self.frDr, 0),
		--pivotScared = newAnimation(APSsheet, arSz, arSz, arFrDr / 2, 0),
		--pivotScaredL = newAnimation(APSsheet, arSz, arSz, arFrDr / 2, 0),
  }
  self.anims.left = {
		walkScared = newAnimation(ais.W, self.frSz, self.frSz, self.frDr, 0),
		idleScared = newAnimation(ais.I, self.frSz, self.frSz, self.frDr * 1.5, 44),
		idle2walkScared = newAnimation(ais.ItW, self.frSz, self.frSz, self.frDr, 0),
		i2kScared = newAnimation(ais.ItK, self.frSz, self.frSz, self.frDr , 0),
		kneelScared = newAnimation(ais.K, self.frSz, self.frSz, self.frDr, 0),
		climb2Scared = newAnimation(ais.C1, self.frSz, self.frSz, self.frDr, 0),
		jumpGrabScared = newAnimation(ais.JG, self.frSz, self.frSz, self.frDr, 0),
  }
	self.x = x or 0 --226
	self.y = y or 0 --448
  self.xac = 0
  self.yac = 0
	self.r = 0
	self.xvel = 0
	self.yvel = 0
  self.h = 88
  self.bouyancy = 8.50
  self.name = "Ara"
  self.tile = { x = math.ceil(self.x / 24), y = math.ceil(self.y / 24), kind = "none" }
  self.fronttile = { x = self.tile.x + 1, self.tile.y - 1, kind = "empty" }

  self.anim = ara.anims.walkScared -- player starts looking Right, Scared, Idle
	self.state = {
		xmov = "idle",
		ymov = "falling",
		facing = "right",
		flipped = false,
		input = false,
		changing = false,
		phys = true,
    rotates = false,
	}
  
  	-- Do our flips
--  for i = 1, #self.anims.left do
--    self.anims.left[i]:flipH()
--  end
  
	self.anims.left.walkScared:flipH()
	self.anims.left.idleScared:flipH()
	self.anims.left.i2kScared:flipH()
	self.anims.left.kneelScared:flipH()
	--ara.anims.left.pivotScared:flipH()
	self.anims.left.climb2Scared:flipH()
	self.anims.left.idle2walkScared:flipH()
	self.anims.left.jumpGrabScared:flipH()
  
  -- Now we shall set up her actual physics
	-- The 'body' is the part with velocity & position.
	ara.body = love.physics.newBody(world, self.x, self.y, "dynamic")
	self.feet = love.physics.newBody(world, self.x, self.y, "dynamic")
	self.head = love.physics.newBody(world, self.x, self.y - self.h, "dynamic")
  self.head:setFixedRotation(true)
  self.head:setMass(1)
		
	-- The 'shape' is the part which has mass and collides.
	-- The physics will rarely get hung up on the corners of the tiles...  may have to draw walking surfaces by hand.
	self.originSh = love.physics.newRectangleShape(3, 3)
	self.originFi = love.physics.newFixture(self.body, self.originSh)
  self.originFi:setUserData(self)
	self.feet	= love.physics.newCircleShape( 8 )
	self.feetFix	= love.physics.newFixture(self.body, self.feet)
  self.feetFix:setUserData({name = "Ara's feet"})
--  ct.Sh	= love.physics.newRectangleShape(0, 0, 16, 16)
--	ct.Fix	= love.physics.newFixture(ct.body, ct.Sh)
--  ct.Fix:setUserData(ct)
	
	self.headSh	= love.physics.newRectangleShape(0, 0, 18, 18)
	self.headFix	= love.physics.newFixture(self.head, self.headSh)
  self.headFix:setUserData({name = "Ara's head"})
  
  --arajoint = love.physics.newDistanceJoint( ara.body, ara.head, ara.x, ara.y, ara.x, ara.y - ara.h, false )
  --arajoint = love.physics.newWeldJoint( ara.body, ara.head, ara.x, ara.y, false )
	--spriteLayer.ara.feetFix:setGroupIndex( 1 )
	--spriteLayer.ara.feetFix:setRestitution( 1 )
	--spriteLayer.ara.body:setMass( 41/2 ) -- Mass in kg -- about 90lbs -- makes her fall through world??
	self.body:setMassData( 0, 0, 40, 1 )
	self.body:setLinearDamping(2)
  self.originFi:setRestitution(2)
end

function ara:update(dt, layer)
  -- Local impulse values
  local x, y = 0, 0

  
  local function stateUpdate()
    -- Here is where we decide which animation we're playing, which direction it is facing, and how fast it should play
    if (math.abs(self.xvel) > 80) then
      self.state.xmov = "idle"
      self.state.ymov = "falling"
      if self.xvel < 0 then flux.to(self, 1, { r = math.rad(-360) }):oncomplete(function() self.state.ymov = "fromkneel" end)
        else flux.to(self, 1, { r = math.rad(360) }):oncomplete(function() self.state.ymov = "fromkneel" end) end
      if self.state.facing == "left" then self.anim = self.anims.left.kneelScared
        else self.anim = self.anims.kneelScared end  
    end
    if (self.state.ymov == "grounded") then -- Grounded and non-zero x speed
      if (math.abs(self.xvel) > 2) then  -- Grounded and moving at a good speed = walking
        if self.state.facing == "left" then self.anim = self.anims.left.walkScared
          if self.xvel > 0 then self.anim:setMode("reverse") else self.anim:setMode("loop") end
        else self.anim = self.anims.walkScared 
          if self.xvel < 0 then self.anim:setMode("reverse") else self.anim:setMode("loop") end
        end
        self.anim:setSpeed(self.frDr * math.abs(self.xvel) / 2)
      elseif (math.abs(self.xvel) > .5) then -- turning around
        if self.state.facing == "left" then self.anim = self.anims.left.idle2walkScared
        else self.anim = self.anims.idle2walkScared end
        --self.anim:setSpeed(frDr * math.abs(self.xvel) / 2)
      elseif (math.abs(self.xvel) < 1)    -- Grounded and stopped
        and (self.state.input == false) then -- We're grounded and stopped, so idle!
        if self.state.facing == "left" then self.anim = self.anims.left.idleScared
        else self.anim = self.anims.idleScared end
        self.anim:setSpeed(1)
        self.state.xmov = "idle"
      end
      if (self.yvel > .1) then -- If we were grounded, but yvel is positive, fall!
        self.state.ymov = "falling" 
      end
    elseif (self.state.ymov == "falling") and (self.yvel <= 0) then
      self.state.ymov = "grounded" -- If we were falling, but yvel is zero, ground!
    elseif (self.state.ymov == "jumping") and (self.yvel >= .1) then
      self.state.ymov = "falling" -- If we were jumping, but yvel is zero, fall!
      self.state.xmov = "idle"
    elseif self.state.ymov == "floating" then
      if (math.abs(self.xvel) > 2) then  -- moving at a good speed = swimming
        if self.state.facing == "left" then self.anim = self.anims.left.walkScared
          else self.anim = self.anims.walkScared end
        self.anim:setSpeed(self.frDr * math.abs(self.xvel))
      elseif (math.abs(self.xvel) > .5) then -- turning around
        self.anim:setSpeed(1)
      elseif (math.abs(self.xvel) < 1)   -- Grounded and stopped
        and (self.state.input == false) then -- stopped, so idle!
  --      if self.state.facing == "left" then self.anim = self.anims.left.idleScared
  --      else self.anim = self.anims.idleScared end
        self.anim:setSpeed(1)
  --      self.state.xmov = "idle"
      end
    elseif (self.state.ymov == "floatkneel") then
      if self.facing == "left" then self.anim = self.anims.left.i2kScared else self.anim = self.anims.i2kScared end
      self.anim:seek(self.anim:getSize())
      self.anim:setMode("reverse")
      self.anim:play()
      local cFrame = self.anim:getCurrentFrame()
      if cFrame == 1 then
        self.state.changing = false
        self.anim:stop()
        self.state.ymov = "floating"
      end
    elseif (self.state.ymov == "tokneel") then
      if self.state.facing == "left" then self.anim = self.anims.left.i2kScared else self.anim = self.anims.i2kScared end
      self.anim:setMode("once")
      self.anim:play()
      local cFrame = self.anim:getCurrentFrame()
      if cFrame == self.anim:getSize() then
        self.state.changing = false
        self.anim:stop()
        self.state.ymov = "kneeling"
        if self.state.facing == "left" then self.anim = self.anims.left.kneelScared else self.anim = self.anims.kneelScared end
      end
    elseif (self.state.ymov == "fromkneel") then
      if self.facing == "left" then self.anim = self.anims.left.i2kScared else self.anim = self.anims.i2kScared end
      self.anim:setMode("reverse")
      self.anim:play()
      local cFrame = self.anim:getCurrentFrame()
      if cFrame == 1 then
        self.state.changing = false
        self.anim:stop()
        self.state.ymov = "grounded"
      end
    elseif (self.state.ymov == "climbing") then
      local cFrame = self.anim:getCurrentFrame()
      local amt, nextanim = -24, self.anims.left.idleScared
      if (self.state.facing == "left") then self.anim = self.anims.left.climb2Scared
      else self.anim = self.anims.climb2Scared; amt = 24; nextanim = self.anims.idleScared end
      if (cFrame == 21) and (self.state.changing == true) then
        local x, y = self.body:getPosition()
        x, y = x + amt, y - 24
        self.body:setX(x) self.body:setY(y)
        self.state.changing = false
      elseif (cFrame == self.anim:getSize()) then
        self.anim:reset()
        self.anim = nextanim
        self.state.ymov = "grounded"
      end
    elseif (self.state.ymov == "jumpgrab") then
      if (self.state.facing == "left") then
        self.anim = self.anims.left.jumpGrabScared
        local cFrame = self.anim:getCurrentFrame()
        if (cFrame > 9) and (cFrame < 11) and (self.state.changing == true) then
          self.state.phys = false
          --local x, y = self.body:getPosition()
          --x = x - 24 y = y - 24
          
          --self.body:setActive( false )
          --x = x - 2 y = y - 4
          --self.body:setX(x) self.body:setY(y)
          --self.state.changing = false
        elseif (cFrame == self.anim:getSize()) then
          -- self.anim:reset()
          self.anim:stop()
          --self.body:setActive( true )
          -- self.anim = self.anims.idleScaredL
          -- self.state.ymov = "grounded"
        end
      else
        self.anim = self.anims.jumpGrabScared
        local cFrame = self.anim:getCurrentFrame()
        if (cFrame > 9) and (cFrame < 11) and (self.state.changing == true) then
          self.state.phys = false
          --local x, y = self.body:getPosition()
          --x = x + 24 y = y - 24
          --self.body:setActive( false )
          --x = x + 2 y = y - 4
          --self.body:setX(x) self.body:setY(y)
          
          --self.state.changing = false
        elseif (cFrame == self.anim:getSize()) then
          -- self.anim:reset()
          self.anim:stop()
          --self.body:setActive( true )
          -- self.anim = self.anims.idleScared
          -- self.state.ymov = "grounded"					
        end
      end
    end
    
    if self.state.input == false then flux.to(cam, 4, { ox = 0, oy = 0 }):delay(.5)end --:ease("quadinout")
    if math.abs(self.r) ~= 0 then
      if self.state.facing == "left" then
        self.anim = self.anims.left.kneelScared
        else self.anim = self.anims.kneelScared end 
    end
  end
  
  local function getInput()
    local down = love.keyboard.isDown
    if down ~= "a" or "left" or "right" or "d" or "s" or "down" then
      ara.state.input = false
    end
--    if map.layers then
      self.tile.x, self.tile.y = self:getTile(self.x, self.y)
      if self.state.facing == "left" then self.fronttile.x, self.fronttile.y = self.tile.x - 1, self.tile.y - 1
      else self.fronttile.x, self.fronttile.y = self.tile.x + 1, self.tile.y - 1 end
      self.state.obstacleheight = self:getObstacleHeight(layer)
      self.stkind = self:getTileKind(self.tile.x, self.tile.y-2)
      self.tile.kind = self:getTileKind(self.tile.x, self.tile.y)
      self.tile.collides = self:tileCollides(self.tile.x, self.tile.y)
      self.fronttile.kind = self:getTileKind(self.fronttile.x, self.fronttile.y)
      self.fronttile.collides = self:tileCollides(self.fronttile.x, self.fronttile.y)
      if self.stkind == "water" then ara.state.ymov = "floating" end
      if self.stkind == "empty" and self.tile.kind == "water" then ara.state.ymov = "jumping" end
--    end
    
    if self.state.ymov == "grounded" then
      if down("w") or down("up") then
        if self.state.obstacleheight == 1 then self.state.ymov, self.state.changing = "climbing", true
        --elseif self.state.obstacleheight == 2 then self.state.ymov, self.state.changing = "jumpgrab", true
        end
      end
      if down(" ") or down("m") then
        -- boing, boing
        if (self.state.facing == "left") then x = -10 else x = 10 end
        y = -300
        self.state.ymov = "jumping"
      end
      -- KNEEL, MORTAL
      if down("s") or down("down") then
        if (math.abs(self.xvel) < 16) then
          self.state.ymov = "tokneel"
          self.state.changing = true
        end
        
      end
      -- go west, young man
      if down("a") or down("left") then
        if (self.xvel > 0) then self.state.changing = true else self.state.changing = false self.state.facing = "left" end
        x, y = -1.5, -4
        self.state.xmov = "walking"
        self.state.input = true

      end
      -- face the east
      if down("d") or down("right") then
        if (self.xvel < 0) then self.state.changing = true else self.state.changing = false self.state.facing = "right" end
        x, y = 1.5, -4
        self.state.xmov = "walking"
        self.state.input = true

      end
    elseif self.state.ymov == "jumping" then
      if down(" ") then if self.state.obstacleheight == 1 then self.state.ymov, self.state.changing = "climbing", true end end
      if down("a") or down("left") then x = -2 end
      if down("d") or down("right") then x = 2 end
    elseif self.state.ymov == "kneeling" then
      -- kneeljump/dodge or whaever
      if down(" ") then 
        if (self.state.facing == "left") then	x = -100 else x = 100 end
          --y = -10
        self.state.ymov = "jumping"
      end
      if down("up") or down("w") then  -- we're trying to go up
        self.state.changing = true
        self.state.ymov = "fromkneel"
        --if cam.oy > -25/cam.zoom then flux.to(cam, 2, { oy = cam.oy - 75/cam.zoom }):delay(2) end
      end
    elseif self.state.ymov == "falling" then
      if down(" ") then if self.state.obstacleheight == 1 then self.state.ymov, self.state.changing = "climbing", true end end
      if down("a") or down("left") then x = -2 end
      if down("d") or down("right") then x = 2 end
    elseif self.state.ymov == "floating" then
      if down("a") or down("left") then
        if (self.xvel > 0) then self.state.changing = true else self.state.changing = false self.state.facing = "left" end
        x = -1
        self.state.xmov = "walking"
        self.state.input = true
      end
      if down("d") or down("right") then
        if (self.xvel < 0) then self.state.changing = true else self.state.changing = false self.state.facing = "right" end
        x = 1
        self.state.xmov = "walking"
        self.state.input = true
      end
      if down("up") or down("w") then  -- we're trying to go up
--        self.state.changing = true
        self.state.ymov = "floatkneel"
        --if cam.oy > -25/cam.zoom then flux.to(cam, 2, { oy = cam.oy - 75/cam.zoom }):delay(2) end
      end
      y = -self.bouyancy
    elseif self.state.ymov == "tokneel" then
    elseif self.state.ymov == "fromkneel" then
    end
    -- we're trying to fly
    if down("lctrl") then
      if down("w") or down("up") then y = -30 end
      if down("s") or down("down") then y = 10 end
      if down("a") or down("left") then x = -10 end
      if down("d") or down("right") then x = 10 end
    end
  end
  
  getInput()
  
  self.xac, self.yac = x, y
  if math.abs(self.xvel) < 1 and math.abs(self.yvel) < 1 then self.r = 0 end
	if (self.state.phys == true) then self.x, self.y = self.body:getWorldCenter() end
  -- These two lines work their magic on a physical/dynamic Ara motion
	self.xvel, self.yvel = self.body:getLinearVelocity()
	self.body:setLinearVelocity(self.xvel + self.xac * 100 * dt, self.yvel + self.yac * 100 * dt)
  self.body:setAngle(self.r)
  self.head:setPosition(self.x, self.y - self.h / 2)
  if forces then 
    local ahx, ahy =  math.compG(0, 0, 0, -forces.gravity, dt)
    self.head:setLinearVelocity(0, ahy)
  end
  
  self.x, self.y = math.ceil(self.x), math.ceil(self.y)
  stateUpdate()
  self.anim:update(dt)
end

function ara:getTile()
  return math.floor(self.x / 24) + 1, math.floor(self.y / 24) + 2
end

function ara:getTileKind(x, y)
  -- Somewhere in here I need a bounds check apparently
  if y < 1 or y > #self.layer.data then
    return "empty"
  end
  maths.clamp(y, 2, self.map.height - 1)
  local data = self.layer.data[y][x]
  if not data then
    return "empty"
  else
    return data.properties.kind
  end
end

function ara:tileCollides(x, y)
  -- Somewhere in here I need a bounds check apparently
  if y < 1 or y > #self.layer.data then
    return false
  end
  maths.clamp(y, 2, self.map.height - 1)
  local data = self.layer.data[y][x]
  if not data then
    return false
  elseif data.properties.collidable == "true" then
    return true
  end
end

function ara:getObstacleHeight()
  local height = 0
  for y = 0, 4 do
    if self.map then
      local fixedy = maths.clamp(self.fronttile.y - y, 1, self.map.height)
      local col = self:tileCollides(self.fronttile.x, fixedy)
      if col == true then height = height + 1 end
    end
  end
  return height
end

function ara:drawCollision()
  lg.setColor(red)
  lg.circle("line", ara.body:getX(), ara.body:getY(), ara.feet:getRadius(), 8)
	lg.polygon("line", ara.body:getWorldPoints(ara.originSh:getPoints()))
  local tx,ty = self.tile.x * 24 - 24, self.tile.y * 24 - 24
  local fx,fy = self.fronttile.x * 24 - 24, self.fronttile.y * 24 - 24
	lg.rectangle("line", fx, fy, 24, 24)
  lg.rectangle("line", tx, ty, 24, 24)
  lg.setColor(blueblack)
	lg.polygon("line", ara.head:getWorldPoints(ara.headSh:getPoints()))
end

return ara