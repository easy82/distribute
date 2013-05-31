require("utils")
require("specs")
require("tests")

function love.load()
  font = love.graphics.newFont("data/Ubuntu-Bold.ttf", 20)
  if font then love.graphics.setFont(font) end

  loveGameIcon = love.graphics.newImage("data/LoveGame.png")
  loveAppIcon = love.graphics.newImage("data/LoveApp.png")

  resetAll()
end

function love.keyreleased(k)
  if k == "escape" then
    love.event.quit()
  end
  -- Run .love file if available
  if k == "f5" and createdLoveFile and testCommand(run.loved) == false then
    writeOutput("Error: Could not run .love file!")
  end
  -- Run executable if available
  if k == "f6" and createdExecutable and testCommand(run.native) == false then
    writeOutput("Error: Could not run executable!")
  end
end

function love.update()
  -- Create binaries progressively
  createBinaries()
end

function love.draw()
  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()

  -- Set background
  local bg = { 0, 60, 120, 255 }
  if creationProgress == -1 then bg = { 160, 30, 0, 255 }
  elseif creationProgress == numCreationSteps then bg = { 30, 120, 0, 255 } end
  love.graphics.setBackgroundColor(bg)

  -- Draw progress bar
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.rectangle("fill", 0, sh - 30, sw, 30)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.rectangle("fill", 2, sh - 28, ((sw - 4) / numCreationSteps) * creationProgress, 26)

  -- Draw icons
  local iconSize = 128
  local iconX = sw - iconSize - 20
  local iconY = 20

  if system.icon then
    love.graphics.draw(system.icon, iconX, iconY)
    iconY = iconY + iconSize + 20
  end
  if loveGameIcon and createdLoveFile then
    love.graphics.draw(loveGameIcon, iconX, iconY)
    iconY = iconY + iconSize + 20
  end
  if loveAppIcon and createdExecutable then
    love.graphics.draw(loveAppIcon, iconX, iconY)
    iconY = iconY + iconSize + 20
  end

  -- Draw text
  love.graphics.setColor(0, 0, 0, 160)
  love.graphics.print(output, 20, 22)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print(output, 20, 20)
end
