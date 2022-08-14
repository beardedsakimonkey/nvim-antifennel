local function create_file(filename, text)
  local handle = assert(io.open(filename, "w+"))
  handle:write(text)
  return handle:close()
end
local function antifennel_script()
  local _local_1_ = debug.getinfo(1)
  local source = _local_1_["source"]
  local dirname = string.sub(source, 2, (string.len("/lua/antifennel.lua") * -1))
  local sep = (package.config):sub(1, 1)
  local path = (dirname .. ("vendor" .. sep .. "antifennel"))
  return path
end
local function run_antifennel(filename, _start_line, _end_line)
  local cmd = (antifennel_script() .. " " .. filename)
  local fh = io.popen(cmd)
  local lines = {}
  for line in fh:lines() do
    table.insert(lines, line)
  end
  fh:close()
  if ("" == lines[#lines]) then
    table.remove(lines)
  else
  end
  return lines
end
local function replace_lines(start_line, end_line, lines)
  vim.api.nvim_buf_set_lines(0, start_line, end_line, true, {})
  return vim.api.nvim_buf_set_lines(0, start_line, start_line, true, lines)
end
local function run(start_line, end_line)
  local start_line0 = (start_line - 1)
  local input = vim.api.nvim_buf_get_lines(0, start_line0, end_line, true)
  local filename = vim.fn.tempname()
  create_file(filename, table.concat(input, "\n"))
  local lines = run_antifennel(filename, start_line0, end_line)
  replace_lines(start_line0, end_line, lines)
  return os.remove(filename)
end
return {run = run}
