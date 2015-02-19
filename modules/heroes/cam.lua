cam = {}

function cam:init(target1, target2)
  self.tx,self.ty = 0,0
  self.alt = 100
  self.mode = "one"
  self.lastmode = "one"
  self.target1 = target1
  self.target2 = target2
	self.zoom = 1
	self.zit = 6
	self.zsteps = {.042, .12, .2, .4, .6, 1, 1.4, 2, 3.4, 4, 8}
	self.ox = 0
	self.oy = 0
  self.r = 0
  self.fps = 60
  self.frDesired = 1/self.fps
  self.attached = 1
  self.fade = 255
end

function cam:update(dt)
  local hdist = math.abs(self.target1.x - self.target2.x) or 0
  local vdist = math.abs(self.target1.y - self.target2.y) or 0
  local lastmode = self.mode
  
--  if self.target1.state.ymov ~= "climbing" and self.mode == "unattached" then
--    self.attached = 1
--  if self.target1.state.ymov == "climbing" and self.mode ~= "unattached" then
--    --    lastmode = self.mode
--    self.mode = "unattached"
--    flux.to(self, 1, { ox = 0 })
--    flux.to(self, 1, { oy = 0 })
--    flux.to(self, 1, { ty = self.ty - 24 })
--    flux.to(self, 1, { tx = self.target1.x })
    
--  end
  
  local down = love.keyboard.isDown
--  local mdown = love.mouse.isDown
  if self.mode == "one" then
    if down("a") or down("left") then
      if self.ox > -75*self.zoom then flux.to(cam, 2, { ox = cam.ox - 25/cam.zoom }) end
    elseif down("d") or down("right") then
      if self.ox < 75*self.zoom then flux.to(cam, 2, { ox = cam.ox + 25/cam.zoom }) end
    end
    if down("w") or down("up") then
      if self.oy < 25*self.zoom then flux.to(cam, 1, { oy = cam.oy + 50/cam.zoom }):delay(1) end
    end
--  elseif self.mode == "unattached" then
--    flux.to(self, 1, { ty = -self.target1.y })
--    flux.to(self, 1, { tx = self.target1.x })
--    self.tx = self.tx + 24
--    self.ox = self.ox - 24
--    self.mode = lastmode
  elseif self.mode == "free" then
    if down("a") or down("left") then self.tx = self.tx + 100 * cam.zoom * dt end
    if down("s") or down("down") then self.ty = self.ty - 100 * cam.zoom * dt end
    if down("d") or down("right") then self.tx = self.tx - 100 * cam.zoom * dt end
    if down("w") or down("up") then self.ty = self.ty + 100 * cam.zoom * dt end
  elseif self.mode == "two" then
    --Moving Out
    if self.zoom == self.zsteps[4] and ((hdist > 1600) or (vdist > 800)) then
      self.zit = 3
      flux.to(self, 1, { zoom = self.zsteps[self.zit] })
    end
    if self.zoom == self.zsteps[5] and ((hdist > 900 and hdist < 1600) or (vdist > 450 and hdist < 800)) then
      self.zit = 4
      flux.to(self, 1, { zoom = self.zsteps[self.zit] })
    end
    if self.zoom == self.zsteps[6] and ((hdist > 400 and hdist < 900) or (vdist > 200 and hdist < 450)) then
      self.zit = 5
      flux.to(self, 1, { zoom = self.zsteps[self.zit] })
    end
    if self.zoom == self.zsteps[8] and ((hdist > 200 and hdist < 400) or (vdist > 100 and hdist < 200)) then
      self.zit = 6
      flux.to(self, 1, { zoom = self.zsteps[self.zit] })
    end
    --Coming In
    if self.zoom == self.zsteps[3] and (hdist > 900 and hdist < 1600) then
      self.zit = 4
      flux.to(self, 1, { zoom = self.zsteps[self.zit] })
    end
    if self.zoom == self.zsteps[4] and (hdist > 400 and hdist < 900) then
      self.zit = 5
      flux.to(self, 1, { zoom = self.zsteps[self.zit] })
    end
    if self.zoom == self.zsteps[5] and (hdist > 200 and hdist < 400) then
      self.zit = 6
      flux.to(self, 1, { zoom = self.zsteps[self.zit] })
    end
    if self.zoom == self.zsteps[6] and (hdist < 200) then
      self.zit = 8
      flux.to(self, 1, { zoom = self.zsteps[self.zit] })
    end
  end
end

function cam:getCenter()
  local view = scrn.scl * self.zoom
  local scale = scrn.scl / scrn.fullfactor
  if not self.target1 or not self.target2 then return 0,0
  elseif self.mode == "one" then
    self.tx = scrn.w / scale / view - (self.target1.x + self.ox)
    self.ty = scrn.h / scale / view - (self.target1.y - self.target1.h / scrn.scl + self.oy)
  elseif self.mode == "two" then
    self.tx = scrn.w / scale / view - (self.target1.x + self.target2.x ) / 2 --+ self.ox
    self.ty = scrn.h / scale / view - (self.target1.y + self.target2.y ) / 2 --+ self.oy
  elseif self.mode == "free" then
--    self.tx = self.tx + scrn.w / scale / view
--    self.ty = self.ty + scrn.h / scale / view
  elseif self.mode == "unattached" then
--    self.tx = self.tx + scrn.w / scale / view
--    self.ty = self.ty + scrn.h / scale / view
  end
  return self.tx or 0, self.ty or 0
end

function cam:switchMode()
  if self.mode == "one" then self.mode = "two"
  elseif self.mode == "two" then self.mode = "free"
  elseif self.mode == "free" or self.mode == "unattached" then self.mode = "one"  end --flux.to(self, .5, { ox = 0, oy = 0 } ) end
end

function cam:switchTarget()
  local t2, t1 = self.target1, self.target2
  self.target1, self.target2 = t1, t2
end

function cam:getMouse(button)
  if self.mode == "one" or "free" then
    if button == "wu" then  
      if self.zit < #self.zsteps then
        flux.to(self, 1, { zoom = self.zsteps[self.zit + 1], oy = self.oy + self.oy / self.zoom })
        self.zit = self.zit + 1 end
    end
    if button == "wd" then  
      if self.zit > 1 then
        flux.to(self, 2, { zoom = self.zsteps[self.zit - 1] })
        self.zit = self.zit - 1 end
    end
  end
  maths.wrap(self.zit, 1, #self.zsteps)
end

function cam:getZoom(offx, offy, w, h, sh, sv)
  -- zoom with parallaxity

  local targetx = self.target1.x -- what are these??
  local targety = self.target1.y
  local parx = sh / 100 -- turns sh into a percent
  local pary = sv / 100
  local par = parx -- and pary?
  local objx, objy = 0, 0

  -- Step 1: project to landscape coordinates
  local resultzoom = 1.0 / (1.0 - (par - par/self.zoom)) -- it would be par / (1.0 - (par - par/zoom)) if objects would get smaller farther away
  
--  if (resultzoom <= 0 or resultzoom > 100) then -- FIXME: optimize treshhold??
--    return resultx, resulty, resultzoom = 0, 0, 1 end

  local rx = ((1 - parx) * targetx) * resultzoom + objx / (parx + self.zoom - parx * self.zoom)
  local ry = ((1 - pary) * targety) * resultzoom + objy / (pary + self.zoom - pary * self.zoom)

  -- Step 2: convert to screen coordinates
  if parx == 0 then resultx = offx + (objx + w) * self.zoom / resultzoom
               else resultx = offx + (rx - targetx) * self.zoom / resultzoom end

  if pary == 0 then resulty = offy + (objy + h) * self.zoom / resultzoom
               else resulty = offy + (ry - targety) * self.zoom / resultzoom end

  return resultx, resulty, resultzoom
end

return cam