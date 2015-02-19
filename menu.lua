--[[ This example is a part of the State switcher class: stateswitcher.lua
Author: Daniel Duris, (CC-BY) 2014, dusoft[at]staznosti.sk ]]--

--arc_path = 'libs/arc/'
--require(arc_path .. 'arc')
--_navi = require(arc_path .. 'navi')
local state = require 'modules/libs/stateswitcher'

sw,sh = scrn.w/2,scrn.h/2

menuhint = _navi:new('|c{mblue}Main menu (e.g. mainmenu.lua).',
	{x=sw, y = sh, alx='m', alxb='m', alyb='m', wbox=sw, box=false, skip=false, wait=2})
	
function love.update(dt)
	arc.check_keys(dt)
end

function love.draw()
	local lH = font:getHeight() + 2
	love.graphics.setBackgroundColor(200,200,200)
	love.graphics.setColor(255,30,30)
	--love.graphics.printf("Main menu (e.g. mainmenu.lua)",50,50,love.window.getWidth()-100)
	love.graphics.setColor(0,0,0)
	love.graphics.printf(
    "Press '1' for '2D Level - Scrolling." .. "\n" ..
    "Press '2' for '2D Level - Caves'." .. "\n" ..
    "Press '3' for '3D Level - Jumper'." .. "\n" ..
    "Press '4' for '3D Level - Atmospheric Re-entry'." .. "\n" ..
    "Press '5' for 'Mode7 Floor Test'." .. "\n" ..
    "Press '6' for 'Messaging Test'." .. "\n" ..
    "Press '7' for 'Polygon Test 1'." .. "\n" ..
    "Press '8' for 'Iso Test'." .. "\n" ..
    "Press '9' for 'Polygon Test 3'." .. "\n" ..
    "Press '0' for 'Effects'." ,100,
	80 + lH * 1,love.window.getWidth()-200)
	
	if menuhint:is_over() then
		menuhint.pos = 'made'
	else menuhint:play(10,10) end
end

function love.keypressed( key )
	--arc.set_key(key)
   if ( key == "escape" ) then state.switch("modules/credits") end
   if ( key == "1" ) then state.switch("modules/sidetilescroller") end
   if ( key == "2" ) then state.switch("modules/sidecavescroller") end
   if ( key == "3" ) then state.switch("modules/vehicle3d;jumper") end
   if ( key == "4" ) then state.switch("modules/vehicle3d;atmos") end
   if ( key == "5" ) then state.switch("modules/vehicle3d;floor") end
   if ( key == "6" ) then state.switch("modules/messaging") end
   if ( key == "7" ) then state.switch("modules/3d") end
   if ( key == "8" ) then state.switch("modules/iso") end
   if ( key == "9" ) then state.switch("modules/3d3") end
   if ( key == "0" ) then state.switch("modules/effects") end
end

function love.keyreleased ( key )
	--gKeyPressed[key] = nil
end