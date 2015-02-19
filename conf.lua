--require("libs/cupid")
function love.conf(t)
    t.identity = DmLEvoAra                   -- The name of the save directory (string)
	t.author = "DmL Presents"
    t.version = "0.9.1"                -- The LVE version this game was made for (string)
    t.console = false                  -- Attach a console (boolean, Windows only)

    t.window.title = "DmL Presents: Evo & Ara"       -- The window title (string)
    t.window.icon = nil                -- Filepath to an image to use as the window's icon (string)
    t.window.width = 1280              -- The window width (number)
    t.window.height = 720             -- The window height (number)
    t.window.borderless = false        -- Remove all border visuals from the window (boolean)
    t.window.resizable = false         -- Let the window be user-resizable (boolean)
    t.window.minwidth = 1024           -- Minimum window width if window resizable (number)
    t.window.minheight = 720           -- Minimum window height if window resizable (number)
    t.window.fullscreen = false        -- Enable fullscreen (boolean)
    t.window.fullscreentype = "normal" -- Standard fullscreen or desktop fullscreen mode (string)
    t.window.vsync = true              -- Enable vertical sync (boolean)
    t.window.fsaa = 4                  -- The number of samples to use with multi-sampled antialiasing (number)
    t.window.display = 1               -- Index of the monitor to show the window in (number)
    t.window.highdpi = false           -- Enable high-dpi mode for the window on a Retina display (boolean). Added in 0.9.1
    t.window.srgb = false              -- Enable sRGB gamma correction when drawing to the screen (boolean). Added in 0.9.1

    t.modules.audio = true             -- Enable the audio module (boolean)
    t.modules.event = true             -- Enable the event module (boolean)
    t.modules.graphics = true          -- Enable the graphics module (boolean)
    t.modules.image = true             -- Enable the image module (boolean)
    t.modules.joystick = true          -- Enable the joystick module (boolean)
    t.modules.keyboard = true          -- Enable the keyboard module (boolean)
    t.modules.math = true              -- Enable the math module (boolean)
    t.modules.mouse = true             -- Enable the mouse module (boolean)
    t.modules.physics = true           -- Enable the physics module (boolean)
    t.modules.sound = true             -- Enable the sound module (boolean)
    t.modules.system = true            -- Enable the system module (boolean)
    t.modules.timer = true             -- Enable the timer module (boolean)
    t.modules.window = true            -- Enable the window module (boolean)
    t.modules.thread = true            -- Enable the thread module (boolean)

  local laptop = {
    width = 1152,
    height = 648,
    fullscreen = false,
    vsync = false,
    fsaa = 0,
    borderless = false,
    resizable = false,
    centered = true,
  }

  local desktopfull = {
    width = 1920,
    height = 1080,
    fullscreen = false,
    vsync = false,
    fsaa = 16,
    borderless = false,
    resizable = false,
    centered = true,
  }

  local desktop = {
    width = 1536,
    height = 864,
    fullscreen = false,
    vsync = false,
    fsaa = 16,
    borderless = false,
    resizable = false,
    centered = true,
  }

  local desktop720 = {
    width = 1280,
    height = 720,
    fullscreen = false,
    vsync = false,
    fsaa = 0,
    borderless = false,
    resizable = false,
    centered = true,
  }

  local tiny = {
    width = 640,
    height = 480,
    fullscreen = false,
    vsync = false,
    fsaa = 0,
    borderless = false,
    resizable = true,
    centered = true,
  }

  local square = {
    width = 640,
    height = 640,
    fullscreen = false,
    vsync = false,
    fsaa = 0,
    borderless = false,
    resizable = false,
    centered = true,
  }

  local square512 = {
    width = 512,
    height = 512,
    fullscreen = false,
    vsync = false,
    fsaa = 0,
    borderless = false,
    resizable = false,
    centered = true,
  }

  -- local windowSettings = tiny
  --  local windowSettings = square
   local windowSettings = desktop720
  -- local windowSettings = square512

  t.window.width = windowSettings.width
  t.window.height = windowSettings.height
  t.window.fullscreen = windowSettings.fullscreen
  t.window.vsync = windowSettings.vsync
  t.window.fsaa = windowSettings.fsaa
  t.window.borderless = windowSettings.borderless
  t.window.resizable = windowSettings.resizable
  t.window.centered = windowSettings.centered

  gWindow = windowSettings
end