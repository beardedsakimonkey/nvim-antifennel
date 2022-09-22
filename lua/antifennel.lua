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
  local path = (dirname .. "vendor" .. sep .. "antifennel")
  return path
end
local function replace_lines(start_line, end_line, lines)
  if ("" == lines[#lines]) then
    table.remove(lines)
  else
  end
  vim.api.nvim_buf_set_lines(0, start_line, end_line, true, {})
  return vim.api.nvim_buf_set_lines(0, start_line, start_line, true, lines)
end
local function run(start_line, end_line)
  local start_line0 = (start_line - 1)
  local tmpfile = vim.fn.tempname()
  local lua_chunk = table.concat(vim.api.nvim_buf_get_lines(0, start_line0, end_line, true), "\n")
  create_file(tmpfile, lua_chunk)
  local lines = vim.fn.systemlist((antifennel_script() .. " " .. vim.fn.shellescape(tmpfile)))
  if (0 == vim.v.shell_error) then
    replace_lines(start_line0, end_line, lines)
  else
    vim.api.nvim_err_writeln(("[nvim-antifennel] " .. table.concat(lines, "\n")))
  end
  return os.remove(tmpfile)
end
return {run = run}
