--[[ --  Stateswitcher Portions by Author: Daniel Duris, (CC-BY) 2014, dusoft[at]staznosti.sk ]]--
lf = love.filesystem
ls = love.sound
la = love.audio
lp = love.physics
lt = love.thread
li = love.image
lg = love.graphics
lw = love.window

lw.setTitle( "DmL Presents: Evo & Ara" )
iconimg = li.newImageData("gfx/icon.gif")
lw.setIcon(iconimg)

-- Libs which need a reference -- anything we want to reset with stateswitcher needs to be local
local lume	= require 'modules/libs/lume'
local state	= require 'modules/libs/stateswitcher'
Spriter = require("modules/libs/Spriter")
flux = require "modules/libs/flux"
--sti = require 'modules/libs/STI'
vector = require "modules/libs/hump.vector"
Peep  = require "modules/libs/Peep"

--gl = require("modules/libs/3d2/gl")

arc_path = 'modules/libs/arc/'
require(arc_path .. 'arc')
_navi = require(arc_path .. 'navi')

-- "Libraries"
require 'modules/libs/anAL'
require 'modules/libs/maths'
-- require 'libs/TLfres'
require ('modules/libs/lovedebug')

--Working Files
require 'modules/cfg/callbacks'
require 'modules/cfg/transitions'
require 'modules/cfg/colors'
require 'modules/entities'
require 'modules/enemies'
require 'gfx/shaders'

--blur = love.graphics.newShader('gfx/shaders/blur.c')
--mine = love.graphics.newShader('gfx/shaders/mine.c')
outline = love.graphics.newShader( "gfx/shaders/outline.c" )
CRT = love.graphics.newShader('gfx/shaders/CRT.c')
inx, iny, outx, outy, texx, texy = 512, 1024, 1280, 720, 1024, 1024

-- When we enter the state, we store any variables/attributes that were passed along
-- In this case, we just get the first one
step=tonumber(passvar[1])
-- Then we clear the passing variables. 
state.clear()
state.name = "menus"
state.event = 1
state.started = false

dt_buffer = 0
forces = {
  gravity = 800,
  wind = 25,
  meter = 48,
}

debug = 1

lg.setDefaultFilter('nearest','nearest')
scrn = {
  w = lg.getWidth(),
  h = lg.getHeight(),
  scl = 2,
  vscl = 1,
  fullfactor = 1,
  x = 0,
  y = 0,
  r = 0,
  xsk = 0,
  ysk = 0,
  full = false,
  shader = false,
  scanlines = true,
  scanpic = lg.newImage('gfx/shaders/scanlines.png')
}
canvas = lg.newCanvas(scrn.w/ scrn.scl, scrn.h/ scrn.scl, normal, 0)

controls = {
  gas = {'up', 'w', },--','},
  brake = {'down', 's', },--'o'},
  left = {'left', 'a',},
  right = {'right', 'd',} --'e'}
  --QWERTY and Dvorak friendly (Dvorak's A is the same as QWERTY's)
}

pAct, sAct = "l", "<"
pInt, sInt = "r", ">"
pJ, sJ = " ", "m"
pU, sU = "w", "up"
pD, sD = "s", "down"
pL, sL = "a", "left"
pR, sR = "d", "right"

cbtxt       = ""   -- we'll use this to put info text on the screen later
cbpersists = 0    -- we'll use this to store the state of repeated callback calls

menuhint = _navi:new('|c{mblue}Press -Space- to Begin!',
	{x=sw, y = sh, alx='m', alxb='m', alyb='m', wbox=sw, box=false, skip=false, wait=2})
menuhint.x, menuhint.y, menuhint.a = scrn.w/8, scrn.h/8, 0

local sky = require "modules/heroes/BGs"
local cam = require "modules/heroes/cam"
local title = {
  img = lg.newImage('gfx/title1.png'),
  a = 0,
  scl = .01,
  x = scrn.w/4,
  y = scrn.h/4,
}

function love.load()
  ents.Startup()
  cam:init()
  sky:init()
--  if arg[#arg] == "-debug" then require("mobdebug").start() end
--  require("mobdebug").off() 

  font = lg.newFont("gfx/fnt/gnon_dedit.ttf", 32)
  font:setFilter("nearest", "nearest", 0)

--  TLfres.setScreen({w=1280, h=720, full=false, vsync=true, aa=0}, 1920, false, false)

  workPath = lf.getWorkingDirectory( )
  savePath = lf.getSaveDirectory( )

  --if (love.filesystem.exists( savePath .. 'conf.lua' ) == false ) then
  configFileMain = lf.read('conf.lua')
  configFileSave = love.filesystem.newFile("conf.lua")
  configFileSave:open("r")
  --if configFileMain then
  configFileSave = love.filesystem.write('conf.lua', configFileMain )
  --end
  --end
--  TLfres.transform()
  

  
end

function love.draw()
  lg.setCanvas(canvas)
  sky:draw()
  lg.push() -- Save the camera stack
  lg.scale(cam.zoom, cam.zoom * scrn.vscl) 	--Set up our zoom
  lg.setColor(200, 100, 255, title.a)
  lg.draw(title.img, title.x, title.y, 0, title.scl, title.scl, title.img:getWidth()/2, title.img:getHeight()/2, 0, 0)
  
  -- Now the start prompt
  lg.setColor(255,255,255, menuhint.a)
  if menuhint.a == 255 then
    if menuhint:is_over() then
      menuhint.pos = 'made'
    else menuhint:play(menuhint.x, menuhint.y) end
  end
  
  -- Draw Screen Fade Rect
  local r, g, b = unpack(blueblack)
  lg.setColor(r, g, b, cam.fade)
  lg.rectangle("fill",0,0,scrn.w,scrn.h)
  
  lg.pop()
  
--  lg.setColor(200, 100, 255, 255)
  drawCanvas(200, 100, 255, 255)
  drawPostFX()
  drawDummyGUI()


end

function love.keypressed( key ) 
  --gKeyPressed[key] = true 
  if (key == "escape") then love.event.quit() end	
  if (key == " " ) then state.switch("menu") end
  if (key == "f1" ) then switchScreen() end
  shaderkey(key)
end

function shaderkey(key)
  if (key == "l" ) then
    if scrn.shader == true then
      scrn.shader = false
      scrn.vscl = 1
      canvas:setFilter( "nearest", "nearest")
    else
      scrn.shader = true
      scrn.vscl = 2
      canvas:setFilter( "linear", "linear")
    end
  end
end

function love.update(dt)
  -- Fade in Logo (but only the first time through the loop)
  if state.started ~= true then
    flux.to(title, 2, {a = 255}):delay(5):ease("quadout")
    flux.to(title, 3, {scl = 1}):delay(5):ease("elasticout")
    flux.to(title, 2, {y = title.y - 40}):delay(8):ease("elasticout")
    flux.to(menuhint, 1, {a = 255}):delay(8):ease("quadout")
    flux.to(menuhint, 1, {y = menuhint.y + title.img:getHeight()/4}):delay(9):ease("elasticout")
    state.started = true
  end
  -- Screen Fade Rect
  flux.to(cam, 3, {fade = 0}):delay(1):ease("quadout") --:oncomplete(function() math.increment(state.event, 2) end)
  
  updateShader()
  arc.check_keys(dt)
  flux.update(dt)
  ents:update(dt)
  
--  if state.event == 3 then
--    screenFadeOut(blueblack, 3, .5)
--  end
end

function drawDummyGUI()
  --lg.setBackgroundColor(0,0,0)
  lg.setColor(255,30,30)
  lg.printf("state.event: " .. state.event, 25, scrn.h - 25, scrn.w - 100)
  if (step~=2) then
    lg.printf("First state (e.g. main.lua) " .. state.name,25,25,love.window.getWidth()-100)
  else
    lg.printf("First state (e.g. main.lua) reloaded!",25,25,love.window.getWidth()-100)
  end
  lg.setColor(255,255,255)
--  lg.printf("Press 'space' to switch to new state.",100,80,love.window.getWidth()-200)
  if (step==2) then
    lg.printf("Info: easily pass values to state switcher, and retrieve them after switches.",100,150,love.window.getWidth()-200)
    lg.setColor(255,255,255)
    lg.rectangle("fill",50,200,love.window.getWidth()-100,230)
    lg.setColor(0,0,50)
    lg.rectangle("fill",50,450,love.window.getWidth()-100,120)
    lg.setColor(255,255,255)
    lg.printf("We have recieved the return state passvars!",100,470,love.window.getWidth()-200)
  end

end

function drawCanvas(r,g,b,a)
	love.graphics.setCanvas()
  if scrn.shader == true then love.graphics.setShader( CRT ) end
--  lg.setColor(r,g,b,a)
  love.graphics.draw(canvas, scrn.x, scrn.y, scrn.r, scrn.scl, scrn.scl / scrn.vscl, 0, 0, scrn.xsk, scrn.ysk)
--	love.graphics.draw(canvas, 0, scrn.h, 0, scrn.scl, -scrn.scl)  -- flip vertically
	love.graphics.setShader( )
end



function switchScreen()
  if (scrn.full ~= true) then		
    love.window.setMode(1920, 1080, {fullscreen=true, vsync=true,})
    scrn.fullfactor = 1.5
    scrn.w = lg.getWidth()
    scrn.h = lg.getHeight()
    scrn.scl = 2 * scrn.fullfactor
    scrn.full = true
  else love.window.setMode(1280, 720, {resizable=false, fullscreen=false, vsync=true})
    scrn.fullfactor = 1
    scrn.w = lg.getWidth()
    scrn.h = lg.getHeight()
    scrn.scl = 2
    scrn.full = false
  end
  if state.name ~= "menus" then
    --if (map) then map:resize(scrn.w, scrn.h) end
    --lg.setCanvas(canvas)
  end
end

function initPhys(size, gravity)
  love.physics.setMeter(size)
  -- Prepare physics world
  world = love.physics.newWorld(0, gravity, true)
  world:setCallbacks(beginContact, endContact, preSolve, postSolve)
--  return world
end

function updateShader()
  if scrn.shader == true then
    CRT:send("inputSize", {inx, iny} )
    CRT:send("outputSize", {outx, outy} )
    CRT:send("textureSize", {texx, texy} )
  end
end

function drawPostFX()
  local r,g,b,a = lg.getColor()
  lg.setColor(white)
  if scrn.scanlines == true then
    love.graphics.setBlendMode( "multiplicative" )
    lg.draw(scrn.scanpic, 0, 0, 0, scrn.w, 1)
    lg.draw(scrn.scanpic, 0, 1024, 0, scrn.w, 1)
  end
  lg.setColor(r,g,b,a)
  love.graphics.setBlendMode( "alpha" )
end

function doScanlines()
  lg.draw(scrn.scanpic, 0, 0, 0, scrn.w, 1)
  lg.draw(scrn.scanpic, 0, 1024, 0, scrn.w, 1)
end

function printKeyPresses()
  local kdown = love.keyboard.isDown
  local mdown = love.mouse.isDown
  local prin = lg.printf
	if mdown(pAct) or mdown(sAct) then 
		prin("Action",50,scrn.h-20,love.window.getWidth()-100)
	end
	if mdown(pInt) or mdown(sInt) then 
		prin("Interaction",100,scrn.h-20,love.window.getWidth()-100)
	end
  if kdown(pAct) or kdown(sAct) then 
		prin("Action",50,scrn.h-20,love.window.getWidth()-100)
	end
	if kdown(pInt) or kdown(sInt) then 
		prin("Interaction",100,scrn.h-20,love.window.getWidth()-100)
	end
	if kdown(pU) or kdown(sU) then 
		prin("W or Up",150,scrn.h-20,love.window.getWidth()-100)
	end
	if kdown(pD) or kdown(sD) then 
		prin("S or Down",200,scrn.h-20,love.window.getWidth()-100)
	end
	if kdown(pL) or kdown(sL) then 
		prin("A or Left",250,scrn.h-20,love.window.getWidth()-100)
	end
	if kdown(pR) or kdown(sR) then 
		prin("D or Right",300,scrn.h-20,love.window.getWidth()-100)
	end
  if kdown(pJ) or kdown(sJ) then 
		prin("Space or M",0,scrn.h-20,love.window.getWidth()-100)
	end
  if kdown("lctrl") then prin("Cheat!", scrn.w / 2 - 100, scrn.h - 20, scrn.w / 2 + 100) end 
end

function love.run()
	if (love.math) then
		love.math.setRandomSeed(os.time())
	end

	love.event.pump()

	if (love.load) then
		love.load()
	end

	love.timer.step()

	local fastest_frame = 1/120 -- max framerate for graphics
	local dt = 1/60 -- rate that updates should run at
	local slowest_frame = 1/15 -- minimum framerate to prevent spiral of death for
	local frame_time = 0
	local accumulator = 0

	while (true) do
		love.event.pump()

		for e, a, b, c, d in love.event.poll() do
			if (e == "quit") then
				if (not love.quit or not love.quit()) then
					if (love.audio) then
						love.audio.stop()
					end
					return
				end
			end

			love.handlers[e](a, b, c, d)
		end

		love.timer.step()
		frame_time = love.timer.getDelta()

		if (frame_time > slowest_frame) then
			frame_time = slowest_frame
		end

		accumulator = accumulator + frame_time

		if (love.update) then
			while (accumulator >= dt) do
				love.update(dt)
				accumulator = accumulator - dt
			end
		else
			--this is actually untested, beware!
			accumulator = accumulator % dt
		end

		if (love.window and love.window.isCreated()) then
			love.graphics.clear()
			love.graphics.origin()

			local alpha = accumulator / dt

			if (love.draw) then
				love.draw(alpha)
			end

			love.graphics.present()
		end

		love.timer.sleep(fastest_frame)
	end
end