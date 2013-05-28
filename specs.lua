-- Editable platform specific parameters and instructions goes here
specs = {
  -- Linux
  {
    system =
    {
      name = 'Linux',
      path = '/home',
      sep = '/'
    },
    archivers =
    {
      {
        name = 'zip',
        paths =
        {
          '',
          -- You can add more paths here ...
        },
        build =
          'cd "<project.path>" && ' ..
          '"<archiver.path><archiver.name>" -r "bin/Love/<project.name>.love" * -x bin\\*'
      },
      -- You can add more archivers here ...
    },
    love2d =
    {
      name = 'love',
      paths =
      {
        '/usr/bin/',
        -- You can add more paths here ...
      },
      build = 
        'cd "<project.path>bin" && ' ..
        'cat "<love2d.path><love2d.name>" "Love/<project.name>.love" > "<system.name><system.arch>/<project.name>" && ' ..
        'chmod a+x "<system.name><system.arch>/<project.name>"'
    },
    run =
    {
      loved = 'love "<project.path>bin/Love/<project.name>.love"',
      native = '"<project.path>bin/<system.name><system.arch>/<project.name>"'
    }
  },

  -- MacOSX
  {
    system =
    {
      name = 'MacOSX',
      path = '/Applications',
      sep = '/'
    },
    archivers = {
      {
        name = 'zip',
        paths =
        {
          '',
          -- You can add more paths here ...
        },
        build = 
          'cd "<project.path>" && ' .. 
          '"<archiver.path><archiver.name>" -r "bin/Love/<project.name>.love" * -x bin\\*'
      },
      -- You can add more archivers here ...
    },
    love2d =
    {
      name = 'love',
      paths =
      {
        '/Applications/love.app/Contents/MacOS/',
        -- You can add more paths here ...
      },
      build = 
        'cd "<project.path>bin" && ' ..
        'cat "<love2d.path><love2d.name>" "Love/<project.name>.love" > "<system.name><system.arch>/<project.name>" && ' ..
        'chmod a+x "<system.name><system.arch>/<project.name>"'
    },
    run =
    {
      loved = '"<love2d.path><love2d.name>" "<project.path>bin/Love/<project.name>.love"',
      native = 'open -a -n "<project.path>bin/<system.name><system.arch>/<project.name>"'
    }
  },

  -- Windows
  {
    system =
    {
      name = 'Windows',
      path = 'C:\\Windows',
      sep = '\\'
    },
    archivers =
    {
      {
        name = '7z.exe',
        paths =
        {
          'C:\\Program Files (x86)\\7-Zip\\',
          'C:\\Program Files\\7-Zip\\',
          -- You can add more paths here ...
        },
        build = 
          'cd /d "<project.path>" && ' ..
          '"<archiver.path><archiver.name>" a -r -tzip "bin\\Love\\<project.name>.love" * -xr!bin'
      },
      -- You can add more archivers here ...
    },
    love2d =
    {
      name = 'love.exe',
      paths =
      {
        'C:\\Program Files (x86)\\LOVE\\',
        'C:\\Program Files\\LOVE\\',
        -- You can add more paths here ...
      },
      build = 
        'cd /d "<project.path>bin" && ' ..
        'copy /b /y "<love2d.path><love2d.name>"+"Love\\<project.name>.love" "<system.name><system.arch>\\<project.name>.exe" && ' ..
        'copy /y "<love2d.path>SDL.dll" "<system.name><system.arch>\\SDL.dll" && ' ..
        'copy /y "<love2d.path>DevIL.dll" "<system.name><system.arch>\\DevIL.dll" && ' ..
        'copy /y "<love2d.path>OpenAL32.dll" "<system.name><system.arch>\\OpenAL32.dll"'
    },
    run =
    {
      loved = 'cd /d "<love2d.path>" && <love2d.name> "<project.path>bin\\Love\\<project.name>.love"',
      native = '"<project.path>bin\\<system.name><system.arch>\\<project.name>.exe"'
    }
  },

  -- You can add more platforms here ...
}

-- I've put this here so that you can see the available keywords and extend it
function replaceKeywords(str)
  local s = str

  s = system.name and s:gsub("<system.name>", system.name) or s
  s = system.arch and s:gsub("<system.arch>", system.arch) or s

  s = project.name and s:gsub("<project.name>", project.name) or s
  s = project.path and s:gsub("<project.path>", project.path) or s

  s = archiver.name and s:gsub("<archiver.name>", archiver.name) or s
  s = archiver.path and s:gsub("<archiver.path>", archiver.path) or s

  s = love2d.name and s:gsub("<love2d.name>", love2d.name) or s
  s = love2d.path and s:gsub("<love2d.path>", love2d.path) or s

  -- You can add more keywords here ...
  return s
end
