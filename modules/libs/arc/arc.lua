-- shortcuts
local la = love.audio
local lg = love.graphics

arc = {}

local _key,_,_ = unpack(require(arc_path .. 'input'))

-- config
arc.cfg = {
	msg_spd = 50, 		        -- chars/sec. message speed
	msg_tanim = 0.2,		    -- sec. duration of message box open/close animation
	msg_tscroll = 0.2,	        -- sec. duration of message scroll animation
	msg_tblink = 0.5,	        -- sec. period of blinker
	msg_txt_shdw = true,	    -- boolean. true: use text shadow, false: don't use
    msg_nc_short_pause = 10,    -- number. number of characters wait for short pause
    msg_nc_long_pause = 50,    -- number. number of characters wait for short pause
	key_wait0 = .4,		        -- sec. initial wait for directional buttons
	key_wait = .1,		        -- sebsequent wait for directional buttons
	cur_dx = 3,		            -- delta x,y of text wrt cursor right edge
	cur_dy = -2
}

-- colors
arc.col = {
	white = {255,255,255},
	black = {0,0,0},
	gray = {128,128,128},
	name = {255,255,0},
	shadow = {0,0,0,192},
	window = {0,80,160,192},
	mred = {255,128,128},
	mgreen = {128,255,128},
	mblue = {128,192,255},
    mpurple = {192,128,255}
}

-- font
arc.fn = {}
-- arc.fn.f = lg.newImageFont('fnt/font.png'," abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\"")
arc.fn.f = lg.newFont("gfx/fnt/gnon.ttf", 16)
arc.fn.h = arc.fn.f:getHeight()+2
arc.fn.w = function(s) return arc.fn.f:getWidth(s) end
lg.setFont(arc.fn.f)

-- keys
arc.btn = {
	ent = 'z',
	esc = 'x',
	kp = ''
}
arc.key = {
	u = _key:new('up'),
	r = _key:new('right'),
	d = _key:new('down'),
	l = _key:new('left')
}

-- images
arc.img = {
	cursor = lg.newImage('gfx/navi/cursor.png'),
	blinker = lg.newImage('gfx/navi/press.png')
}

-- sound effects
arc.sfx = {
	cursor = la.newSource('sfx/navi/cursor.wav','static'),
	confirm = la.newSource('sfx/navi/confirm.wav','static')
}

-- process directional keys
function arc.check_keys(dt)
    for k,_ in pairs(arc.key) do
        arc.key[k]:check(dt)
    end
end

-- update last key pressed
function arc.set_key(k)
	arc.btn.kp = k
end

-- clears last key pressed
function arc.clear_key()
	arc.btn.kp = ''
end