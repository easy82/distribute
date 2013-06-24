local output = ""

function writeOutput(line)
  output = output .. line .. "\n"
  print(line)
end

function drawOutput()
  love.graphics.setColor(0, 0, 0, 160)
  love.graphics.print(output, 20, 22)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print(output, 20, 20)
end

function try(condition, errorMessage, successMessage)
  if condition == true then
    writeOutput(errorMessage)
    return false
  end

  if successMessage then writeOutput(successMessage) end
  return true
end

function trimStr(str)
  return str:match("^%s*(.-)%s*$")
end

function splitStr(str, sep)
  local ret = {}
  local pattern = string.format("([^%s]+)", sep)
  str:gsub(pattern, function(c) ret[#ret + 1] = c end)
  return ret
end

function testCommand(command)
  return tonumber(os.execute(command)) == 0 and true or false
end

function testDir(path)
  return testCommand('cd "' .. path .. '"')
end

function testFile(file)
  local f = io.open(file, "r")
  if f ~= nil then
    f:close()
    return true
  else
    return false
  end
end

function writeFile(file, text)
  local f = io.open(file, "w")
  if f ~= nil then
    f:write(text)
    f:close()
    return true
  else
    return false
  end
end

function readOutput(command)
  -- Bugfix: Love 0.8.0 has no io.popen on Mac, 0.9.0 will have
  -- Create a temporary file and redirect command output to it
  if not io.popen then
    local temp = "tempoutp"
    if testCommand(command .. " > " .. temp) == true then
      local f = io.input(temp)
      if f ~= nil then
        local t = f:read("*all")
        f:close()
        os.execute("rm " .. temp)
        return t
      else
        return ""
      end
    else
      return ""
    end
  end

  -- This piece of code is originally from https://github.com/lualatex/lualibs/blob/master/lualibs-os.lua
  -- Use the regular way to get command output
  local h = io.popen(command, "r")
  return h and h:read("*all") or ""
end
