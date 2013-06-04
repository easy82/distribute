function resetAll()
  system = {
    id = '',
    paths = {},
    path = '',
    name = '',
    sep = '',
    arch = '',
    icon = nil
  }
  archivers = {}
  archiver = {
    name = '',
    paths = {},
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
  createdLoveFile = false
  createdExecutable = false
  numCreationSteps = 12
  oldCreationProgress = 0
  creationProgress = 1
end

local function testArgument()
  if arg[2] then
    -- Remove quotes and trim white spaces from project path
    project.path = arg[2]:gsub('"', '')
    project.path = trimStr(project.path)
  end

  -- Display help if no good argument was given
  return try(project.path == "",
    "Love Distribution Tool (LDT) is a command line application for distributing\n" ..
    "games created with the awesome LOVE framework. It creates a .love file\n" ..
    "and a native executable depending on the host operating system.\n\n" ..
    "Usage: love distribute.love PathToYourProject")
end

local function testOperatingSystem()
  -- Test directories to detect host os
  local found = false
  for _, s in pairs(specs) do
    system.paths = s.system.paths

    for _, p in pairs(system.paths) do
      if testDir(p) == true then
        system.path = p
        system.id = s.system.id
        system.sep = s.system.sep
        system.icon = love.graphics.newImage("data/" .. system.id .. ".png")
        archivers = s.archivers
        love2d.name = s.love2d.name
        love2d.paths = s.love2d.paths
        love2d.build = s.love2d.build
        run.loved = s.run.loved
        run.native = s.run.native
        found = true
        break
      end
    end

    if found == true then break end
  end

  return try(system.id == "", "Error: Unknown operating system!", "Operating system: " .. system.id)
end

local function testDistribution()
  if system.id == "Linux" then
    -- File patterns to test against
    local tests =
    {
      "/etc/<distro>-release",
      "/etc/<distro>_release",
      "/etc/<distro>-version",
      "/etc/<distro>_version"
    }

    for _, v in pairs(tests) do
      -- Try to guess distro name from matching filenames
      -- This is equal to 'dir /etc/*-release', etc.
      local replaced = v:gsub("<distro>", "*")
      local output = readOutput("dir " .. replaced)

      if output ~= "" then
        -- Extract distro name from filename
        local replaced = v:gsub("<distro>", "(%%a+)")
        local distro = output:match(replaced) or ""
        local release = ""

        if distro == "os" then
          -- This is probably '/etc/os-release'
          -- http://www.freedesktop.org/software/systemd/man/os-release.html
          local replaced = v:gsub("<distro>", distro)
          local output = readOutput("cat " .. replaced)

          if output ~= "" then
            -- Extract distro name and release if possible
            system.name = output:match("ID=(%a+)") or ""
            release = output:match("VERSION_ID=(%d+.%d+)") or output:match("VERSION_ID=(%d+)") or ""
          end

        elseif distro == "lsb" then
          -- This is probably '/etc/lsb-release'
          -- LSB distro: let's assume it's Ubuntu by default
          system.name = "ubuntu"
          local replaced = v:gsub("<distro>", distro)
          local output = readOutput("cat " .. replaced)

          if output ~= "" then
            -- Extract distro name and release if possible
            system.name = output:match("DISTRIB_ID=(%a+)") or ""
            release = output:match("DISTRIB_RELEASE=(%d+.%d+)") or output:match("DISTRIB_RELEASE=(%d+)") or ""
          end

        elseif distro ~= "" then
          system.name = distro
          local replaced = v:gsub("<distro>", distro)
          local output = readOutput("cat " .. replaced)

          if output ~= "" then
            -- Extract release by pattern matching
            release = output:match("%d+.%d+") or output:match("%d+") or ""
          end
        end

        if system.name ~= "" then
          -- Distro name starts with uppercase
          system.name = system.name:gsub("^%l", string.upper)
          -- Add release to distro name
          if release ~= "" then system.name = system.name .. "-" .. release end
        end

        break
      end
    end

    if system.name ~= "" then
      writeOutput("Distribution: " .. system.name)
    else
      writeOutput("Unknown distribution")
    end
  else
    -- Windows and MacOSX binaries will run fine no matter which OS version it is
    system.name = system.id
  end

  return true
end

-- This piece of code is originally from https://github.com/lualatex/lualibs/blob/master/lualibs-os.lua
local function testArchitecture()
  if system.id == "Windows" then
    system.arch = os.getenv("PROCESSOR_ARCHITECTURE") or ""

  elseif system.id == "Linux" then
    system.arch = os.getenv("HOSTTYPE") or readOutput("uname -m") or ""

  elseif system.id == "MacOSX" then
    system.arch = readOutput("echo $HOSTTYPE") or ""
  end

  system.arch = system.arch:gsub("[\n\r]", "")

  if system.arch ~= "" then
    writeOutput("Architecture: " .. system.arch)
    system.arch = "-" .. system.arch
  else
    writeOutput("Unknown architecture")
  end
  
  return true
end

local function testProject()
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
  -- Seek for LOVE at its possible directories
  for _, p in pairs(love2d.paths) do
    local path = replaceKeywords(p)

    if testFile(path .. love2d.name) == true then
      love2d.path = path
      writeOutput("Love2D path: " .. love2d.path)

      -- Seek for .DLLs on Windows
      if system.id == "Windows" then
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
  -- Seek for archivers at their possible directories
  for _, a in pairs(archivers) do
    archiver.paths = a.paths

    for _, p in pairs(archiver.paths) do
      local path = replaceKeywords(p)

      if testFile(path .. a.name) == true then
        archiver.name = a.name
        archiver.path = path
        archiver.build = a.build
        writeOutput("Archive manager: " .. archiver.path .. archiver.name)
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
    if testCommand('mkdir "' .. binDir .. '"') == false then
      writeOutput("Error: Could not create folder: " .. binDir)
      return false
    end
    writeOutput("Created folder: " .. binDir)
  end

  local loveDir = binDir .. system.sep .. "Love" 
  if testDir(loveDir) == false then
    if testCommand('mkdir "' .. loveDir .. '"') == false then
      writeOutput("Error: Could not create folder: " .. loveDir)
      return false
    end
    writeOutput("Created folder: " .. loveDir)
  end

  local systemDir = binDir .. system.sep .. system.name .. system.arch
  if testDir(systemDir) == false then
    if testCommand('mkdir "' .. systemDir .. '"') == false then
      writeOutput("Error: Could not create folder: " .. systemDir)
      return false
    end
    writeOutput("Created folder: " .. systemDir)
  end

  return true
end

local function createLove()
  run.loved = replaceKeywords(run.loved)
  archiver.build = replaceKeywords(archiver.build)
  createdLoveFile = try(testCommand(archiver.build) == false, "Error: Could not create .love file!", "Created .love file! (Hit F5 to run)")
  return createdLoveFile
end

local function createExecuatble()
  run.native = replaceKeywords(run.native)
  love2d.build = replaceKeywords(love2d.build)
  createdExecutable = try(testCommand(love2d.build) == false, "Error: Could not create executable!", "Created executable! (Hit F6 to run)")
  return createdExecutable
end

function createBinaries()
  if oldCreationProgress == creationProgress then return end
  oldCreationProgress = creationProgress

  if creationProgress == 1 then -- Is there any arguments?
    creationProgress = testArgument() == true and creationProgress + 1 or -1

  elseif creationProgress == 2 then -- Detect operating system
    writeOutput("Detecting operating system ...")
    creationProgress = testOperatingSystem() == true and creationProgress + 1 or -1

  elseif creationProgress == 3 then -- Detect distribution
    creationProgress = testDistribution() == true and creationProgress + 1 or -1

  elseif creationProgress == 4 then -- Detect architecture
    creationProgress = testArchitecture() == true and creationProgress + 1 or -1

  elseif creationProgress == 5 then -- Does the project exists?
    writeOutput("\nSetting up project details ...")
    creationProgress = testProject() == true and creationProgress + 1 or -1

  elseif creationProgress == 6 then -- Does it contain main.lua?
    creationProgress = testMainLua() == true and creationProgress + 1 or -1

  elseif creationProgress == 7 then -- Search for LOVE framework
    writeOutput("\nSearching for required applications ...")
    creationProgress = testLove2D() == true and creationProgress + 1 or -1

  elseif creationProgress == 8 then -- Find an archive manager
    creationProgress = testArchiveManagers() == true and creationProgress + 1 or -1

  elseif creationProgress == 9 then -- Create directory structure
    writeOutput("\nCreating binaries ...")
    creationProgress = createDirectories() == true and creationProgress + 1 or -1

  elseif creationProgress == 10 then -- Create .love file
    creationProgress = createLove() == true and creationProgress + 1 or -1

  elseif creationProgress == 11 then -- Create native executable
    creationProgress = createExecuatble() == true and creationProgress + 1 or -1

  elseif creationProgress == 12 then
    writeOutput("\nDone!\n")
  end
end
