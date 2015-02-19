arc_path = 'libs/arc/'
require(arc_path .. 'arc')
_navi = require(arc_path .. 'navi')
require('txt/intro')

local state = require 'libs/stateswitcher'


-- shortcuts for love stuff
le = love.event
lg = love.graphics
lg.setDefaultFilter("nearest", "nearest", 0)

-- load variables
-- colors
col = {
  white = {255,255,255},
}
-- images
img = {
  logo = lg.newImage('gfx/navi/logo.png'),
  face = lg.newImage('gfx/avatar/face.png'),
  avatar = lg.newImage('gfx/avatar/avatar.png'),
  bg = lg.newImage('gfx/navi/bg-highup.png')
}
litearc = {face=img.avatar}

iw,ih = img.logo:getWidth(),img.logo:getHeight()
sw,sh = scrn.w/2,scrn.h/2
lg.setBackgroundColor(unpack(white))
canvas = lg.newCanvas(sw,sh)


-- game text goes here
initMsgs()

-- key press
function love.keypressed(k)
  arc.set_key(k)
  if k == 'escape' then
    state.switch("mainmenu")
  end
end

-- update game
function love.update(dt)
  arc.check_keys(dt)
end

-- draw stuff
function love.draw()
  lg.setCanvas(canvas)
  lg.clear(canvas)

  lg.setColor(col.white)
  lg.draw(img.bg,0,0,0,scrn.scl,scrn.scl)

  if (m_correct:is_over() or m_wrong:is_over()) then
    m2:play(10,10)
  else
    if m[#m]:is_over() then
      local pick = m[5]:get_pick()
      if pick == 2 then
        m_correct:play(10,10)
      else
        m_wrong:play(10,10)
      end
    else _navi.play_list(m,10,10) end
  end
  arc.clear_key()
  lg.setCanvas()
  lg.setColor(col.white)
  lg.draw(canvas, 0, 0, 0, scrn.scl, scrn.scl)
  doScanlines()
end
