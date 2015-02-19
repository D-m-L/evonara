--[[ This example is a part of the State switcher class: stateswitcher.lua
Author: Daniel Duris, (CC-BY) 2014, dusoft[at]staznosti.sk ]]--

state = require 'libs/stateswitcher'

function love.draw()
   love.graphics.setBackgroundColor(0,0,50)
   love.graphics.setColor(255,30,30)
   love.graphics.printf("Press 'Escape' to exit.",50,50,love.window.getWidth()-100)
   love.graphics.setColor(255,255,255)
   love.graphics.printf("Press any key to switch back to the first state.",100,80,love.window.getWidth()-200)
   love.graphics.printf("Info: You can cycle through the states (reload them) as many times as you wish. We will now pass value to the next state, so it will display code examples.",100,150,love.window.getWidth()-200)
end

function love.keypressed( key, unicode )
   state.switch("main;2")
end

function love.keyreleased ( key )
	-- gKeyPressed[key] = nil
end

wever = [[Special Thanks:
 
 My family for their patience and vision.
 The hardwork and dedication of the Love2d.org team for their amazing framework.
 Daniel Duris, (CC-BY) 2014, dusoft[at]staznosti.sk for the Stateswitcher Library. www.ambience.sk
 User XXXX for the XXXX library.
 markgo the "Wanker" on #love irc.oftc.net
 
 Special No Thanks:
 JesseH "his near-Infiniteness level 24 Wizardry" on #love irc.oftc.net
 ]]