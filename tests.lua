system = {
  name = '',
  path = '',
  sep = '',
  arch = '',
  icon = nil
}
archivers = {}
archiver = {
  name = '',
  path = '',
  build = ''
}
love2d = {
  name = '',
  paths = {},
  path = '',
  build = ''
}
run = {
  loved = '',
  native = ''
}
project = {
  name = '',
  path = ''
}

local function testArgument()
  project.path = ""
  
  if arg[2] then
    -- Remove quotes and trim white spaces from project path
    project.path = arg[2]:gsub('"', '')
    project.path = trimStr(project.path)
  end

  -- Display help if no good argument was given
  local usage = "Love Distribution Tool (LDT) is a command line application for distributing\n" ..
    "games created with the awesome LOVE framework. It creates a .love file\n" ..
    "and a native executable depending on the host operating system.\n\n"

  if arg[1] then
    local a = trimStr(arg[1]:gsub('"', ''))

    if a:find(".love") then
      usage = usage .. "Usage: love distribute.love PathToYourProject"
    else
      usage = usage .. "Usage: love distribute PathToYourProject"
    end
  end

  return try(project.path == "", usage)
end

local function testOperatingSystem()
  system.name = ""
  system.path = ""
  system.sep = ""
  system.icon = nil
  archivers = {}
  love2d.name = ""
  love2d.paths = {}
  love2d.build = ""
  run.loved = ""
  run.excutable = ""

  -- Test directories to detect host os
  for _, v in pairs(specs) do
    if testDir(v.system.path) == true then
      system.name = v.system.name
      system.path = v.system.path
      system.sep = v.system.sep
      system.icon = love.graphics.newImage("data/" .. system.name .. ".png")
      archivers = v.archivers
      love2d.name = v.love2d.name
      love2d.paths = v.love2d.paths
      love2d.build = v.love2d.build
      run.loved = v.run.loved
      run.native = v.run.native
      break
    end
  end

  return try(system.name == "", "Error: Unknown operating system!", "Operating system: " .. system.name)
end

-- This piece of code is originally from https://github.com/lualatex/lualibs/blob/master/lualibs-os.lua
local function testArchitecture()
  system.arch = "32"

  if system.name == "Windows" then
    local a = os.getenv("PROCESSOR_ARCHITECTURE") or ""

    if a:find("AMD64") then
      system.arch = "64"
    end

  elseif system.name == "Linux" then
    local a = os.getenv("HOSTTYPE") or testOutput("uname -m") or ""

    if a:find("x86_64") then
      system.arch = "64"
    elseif a:find("ppc") then
      system.arch = "PPC"
    end

  elseif system.name == "MacOSX" then
    local a = testOutput("echo $HOSTTYPE") or ""

    if a:find("x86_64") then
      system.arch = "64"
    elseif a ~= "" then
      system.arch = "PPC"
    end
  end

  writeOutput("System architecture: " .. system.arch)
  return true
end

local function testProject()
  project.name = ""

  -- Extract project name from path
  local extract = splitStr(project.path, system.sep)
  project.name = extract[#extract]
  writeOutput("Project name: " .. project.name)

  -- Add possible missing separator to the end of path
  if project.path:find(system.sep, -1, true) ~= #project.path then
    project.path = project.path .. system.sep
  end

  return try(testDir(project.path) == false, "Error: Project path does not exists!", "Project path: " .. project.path)
end

local function testMainLua()
  return try(testFile(project.path .. "main.lua") == false, "Error: Cannot find main.lua at the project folder!", "Found main.lua")
end

local function testLove2D()
  love2d.path = ""

  -- Seek for LOVE at its possible directories
  for _, p in pairs(love2d.paths) do
    local path = replaceKeywords(p)

    if testFile(path .. love2d.name) == true then
      love2d.path = path
      writeOutput("Love2D path: " .. love2d.path)

      -- Seek for .DLLs on Windows
      if system.name == "Windows" then
        if testFile(love2d.path .. "SDL.dll") == false or
           testFile(love2d.path .. "DevIL.dll") == false or
           testFile(love2d.path .. "OpenAL32.dll") == false then

          writeOutput("Error: Couldn't find LOVE DLLs!")
          return false
        end          

        writeOutput("Found LOVE DLLs")
      end

      return true
    end
  end

  writeOutput("Error: Couldn't find LOVE framework!")
  return false
end

local function testArchiveManagers()
  archiver.name = ""
  archiver.path = ""
  archiver.build = ""

  -- Seek for archivers at their possible directories
  for _, a in pairs(archivers) do
    archiver.paths = a.paths

    for _, p in pairs(archiver.paths) do
      local path = replaceKeywords(p)

      if tonumber(os.execute('"' .. path .. a.name .. '"')) == 0 then
        archiver.name = a.name
        archiver.path = path
        archiver.build = a.build
        writeOutput("Archive manager: " .. archiver.name)
        return true
      end
    end
  end

  writeOutput("Error: Couldn't find any archive managers!")
  return false
end

local function createDirectories()
  local binDir = project.path .. "bin"
  if testDir(binDir) == false then
    if tonumber(os.execute('mkdir "' .. binDir .. '"')) ~= 0 then
      writeOutput("Error: Could not create folder: " .. binDir)
      return false
    end
    writeOutput("Created " .. binDir)
  end

  local loveDir = binDir .. system.sep .. "Love" 
  if testDir(loveDir) == false then
    if tonumber(os.execute('mkdir "' .. loveDir .. '"')) ~= 0 then
      writeOutput("Error: Could not create folder: " .. loveDir)
      return false
    end
    writeOutput("Created " .. loveDir)
  end

  local systemDir = binDir .. system.sep .. system.name .. system.arch
  if testDir(systemDir) == false then
    if tonumber(os.execute('mkdir "' .. systemDir .. '"')) ~= 0 then
      writeOutput("Error: Could not create folder: " .. systemDir)
      return false
    end
    writeOutput("Created " .. systemDir)
  end

  return true
end

local function createLove()
  run.loved = replaceKeywords(run.loved)
  archiver.build = replaceKeywords(archiver.build)
  createdLoveFile = try(tonumber(os.execute(archiver.build)) ~= 0, "Error: Could not create .love file!", "Created .love file! (Hit F5 to run)")
  return createdLoveFile
end

local function createExecuatble()
  run.native = replaceKeywords(run.native)
  love2d.build = replaceKeywords(love2d.build)
  createdExecutable = try(tonumber(os.execute(love2d.build)) ~= 0, "Error: Could not create executable!", "Created executable! (Hit F6 to run)")
  return createdExecutable
end

function createBinaries()
  if oldCreationProgress == creationProgress then return end
  oldCreationProgress = creationProgress

  if creationProgress == 1 then -- Is there any arguments?
    creationProgress = testArgument() == true and creationProgress + 1 or -1

  elseif creationProgress == 2 then -- Detect which operating system is this
    writeOutput("Detecting operating system ...")
    creationProgress = testOperatingSystem() == true and creationProgress + 1 or -1

  elseif creationProgress == 3 then -- Detect if architecture is 32 or 64 bits
    creationProgress = testArchitecture() == true and creationProgress + 1 or -1

  elseif creationProgress == 4 then -- Does the project exists?
    writeOutput("\nSetting up project details ...")
    creationProgress = testProject() == true and creationProgress + 1 or -1

  elseif creationProgress == 5 then -- Does it contain main.lua?
    creationProgress = testMainLua() == true and creationProgress + 1 or -1

  elseif creationProgress == 6 then -- Search for LOVE framework
    writeOutput("\nSearching for required applications ...")
    creationProgress = testLove2D() == true and creationProgress + 1 or -1

  elseif creationProgress == 7 then -- Find an archive manager
    creationProgress = testArchiveManagers() == true and creationProgress + 1 or -1

  elseif creationProgress == 8 then -- Create directory structure
    writeOutput("\nCreating binaries ...")
    creationProgress = createDirectories() == true and creationProgress + 1 or -1

  elseif creationProgress == 9 then -- Create .love file
    creationProgress = createLove() == true and creationProgress + 1 or -1

  elseif creationProgress == 10 then -- Create native executable
    creationProgress = createExecuatble() == true and creationProgress + 1 or -1

  elseif creationProgress == 11 then
    writeOutput("\nDone!\n")
  end
end
