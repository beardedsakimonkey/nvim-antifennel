local DEBUG = false
local function log(...)
  if DEBUG then
    return print("[nvim-antifennel] ", ...)
  else
    return nil
  end
end
local function assert_exists(path)
  if DEBUG then
    return assert(vim.loop.fs_access(path, "R"))
  else
    return nil
  end
end
local function create_file(filename, text)
  local handle = assert(io.open(filename, "w+"))
  handle:write(text)
  return handle:close()
end
local function antifennel_script()
  local _local_3_ = debug.getinfo(1)
  local source = _local_3_["source"]
  local dirname = string.sub(source, 2, (string.len("/lua/antifennel.lua") * -1))
  local sep = (package.config):sub(1, 1)
  local path = (dirname .. ("vendor" .. sep .. "antifennel"))
  assert_exists(path)
  return path
end
local function strip_trailing_newlines(str)
  local ret = str
  while ("\n" == ret:sub(-1)) do
    ret = ret:sub(1, -2)
  end
  return ret
end
local function run_antifennel(filename, start_line, end_line)
  local stdout = vim.loop.new_pipe()
  local stderr = vim.loop.new_pipe()
  local function on_stdout(_3ferr, _3fdata)
    log(("on-stdout() with err %s, data %s"):format(_3ferr, _3fdata))
    if (nil ~= _3fdata) then
      local lines = vim.split(strip_trailing_newlines(_3fdata), "\n")
      local function _4_()
        vim.api.nvim_buf_set_lines(0, start_line, end_line, true, {})
        return vim.api.nvim_buf_set_lines(0, start_line, start_line, true, lines)
      end
      return vim.schedule(_4_)
    else
      return nil
    end
  end
  local function on_stderr(_3ferr, _3fdata)
    return log(("on-stderr() with err %s, data %s"):format(_3ferr, _3fdata))
  end
  local function on_exit(code, signal)
    log(("on-exit() with exit code %d, signal %d"):format(code, signal))
    if (0 ~= code) then
      log(("spawn failed (exit code %d, signal %d)"):format(code, signal))
    else
    end
    return assert(os.remove(filename))
  end
  vim.loop.spawn(antifennel_script(), {args = {filename}, stdio = {nil, stdout, stderr}}, on_exit)
  vim.loop.read_start(stdout, on_stdout)
  return vim.loop.read_start(stderr, on_stderr)
end
local function run(start_line, end_line)
  local start_line0 = (start_line - 1)
  local input = vim.api.nvim_buf_get_lines(0, start_line0, end_line, true)
  local filename = vim.fn.tempname()
  create_file(filename, table.concat(input, "\n"))
  return run_antifennel(filename, start_line0, end_line)
end
return {run = run}
