local Sky = {}

function Sky:init()
  self.canvas = lg.newCanvas(scrn.w / scrn.scl, scrn.h / scrn.scl)
  self.tcanvas = lg.newCanvas(scrn.w / scrn.scl, scrn.h / scrn.scl)
  self.topcolor = {111,  60, 103, 255}
  self.botcolor = {250, 190, 120, 255}
  self.img = lg.newImage('gfx/skies/sky3.png')
  self.imgh = self.img:getHeight()
  self.imgw = self.img:getWidth()
  self.cloud = lg.newImage('gfx/skies/clound.png')
  self.cloudtrans = 150
  self.x = 000 
  self.y = 0
  self.r = 0
  self.clouds = {}
   
  for i = 1, 10 do
    self.clouds[i] = ents.Create( "bgcloud", math.random(1, scrn.w), math.random(1, scrn.h) )
  end
--  self.ct = math.randXYZtable( 50, 24 * 200 / 8, 24 * 200 / 8)
end

function Sky:update()

end

function Sky:draw(player)
  lg.setCanvas(self.canvas)
  --Draw the top color box
  lg.setColor(self.topcolor)
	lg.rectangle('fill', 0, 0, scrn.w, scrn.h * scrn.vscl)
  --Draw the bottom color box, taking into account if there is a player reference
	lg.setColor(self.botcolor)
  local px
  if player then px = math.floor(-player.x / 32) else px = 0 end
  lg.rectangle('fill', 0, scrn.h/16 + self.imgh * cam.zoom, scrn.w, scrn.h)
  --Draw the sky image
  lg.setColor(white)
  lg.draw(self.img, px - self.imgw / 2, self.imgh * cam.zoom, 0, 1 / cam.zoom * cam.zoom, 1 / cam.zoom * cam.zoom )
--  lg.draw(sky.img, 0, 100, 0, 1, 1)

  self:drawClouds(player)
  lg.setCanvas(canvas)
  lg.setColor(white)
  lg.draw(self.canvas, scrn.x, scrn.y, scrn.r, 1, 1 * scrn.vscl, 0, 0, scrn.xsk, scrn.ysk)
  lg.setColor(255,255,255, self.cloudtrans)
  lg.draw(self.tcanvas, scrn.x, scrn.y, scrn.r, 1, 1 * scrn.vscl, 0, 0, scrn.xsk, scrn.ysk)
  --lg.draw(self.canvas, 0, 0, 0, scrn.scl, scrn.vscl)
end

function Sky:drawClouds(player)
  lg.setCanvas(self.tcanvas)
  love.graphics.setBackgroundColor(0,0,0,0)
  lg.clear(self.canvas)
  for i = 1, 10 do
    self.clouds[i]:skydraw()
  end
end

return Sky