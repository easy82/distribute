function love.conf(t)
  t.title = "Love Distribution Tool v0.3"
  t.author = "Peter Szöllősi (easy82)"
  t.url = "https://github.com/easy82/distribute"
  t.identity = "distribute"
  t.version = "0.8.0"
  t.console = true
  t.release = false
  t.screen.width = 800
  t.screen.height = 600
  t.screen.fullscreen = false
  t.screen.vsync = true
  t.screen.fsaa = 0
  t.modules.joystick = false
  t.modules.audio = false
  t.modules.keyboard = true
  t.modules.event = true
  t.modules.image = true
  t.modules.graphics = true
  t.modules.timer = true
  t.modules.mouse = true
  t.modules.sound = false
  t.modules.physics = false
end
