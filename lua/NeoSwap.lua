--[[

 /$$   /$$                      /$$$$$$
| $$$ | $$                     /$$__  $$
| $$$$| $$  /$$$$$$   /$$$$$$ | $$  \__/ /$$  /$$  /$$  /$$$$$$   /$$$$$$
| $$ $$ $$ /$$__  $$ /$$__  $$|  $$$$$$ | $$ | $$ | $$ |____  $$ /$$__  $$
| $$  $$$$| $$$$$$$$| $$  \ $$ \____  $$| $$ | $$ | $$  /$$$$$$$| $$  \ $$
| $$\  $$$| $$_____/| $$  | $$ /$$  \ $$| $$ | $$ | $$ /$$__  $$| $$  | $$
| $$ \  $$|  $$$$$$$|  $$$$$$/|  $$$$$$/|  $$$$$/$$$$/|  $$$$$$$| $$$$$$$/
|__/  \__/ \_______/ \______/  \______/  \_____/\___/  \_______/| $$____/
                                                                | $$
                                                                | $$
                                                                |__/
--]]
local NeoSwap = {}

local fn = vim.fn
local api = vim.api
local user_cmd = vim.api.nvim_create_user_command

NeoSwap.setup = function()
  if vim.g.neoswap_setup then
    return
  end

  vim.g.neoswap_setup = true

  user_cmd("NeoSwapNext", "lua require('NeoSwap').swap_next()", {})

  user_cmd("NeoSwapPrev", "lua require('NeoSwap').swap_prev()", {})
  
  user_cmd("NeoSwapVisualNext", "lua require('NeoSwap').swap_visual_next()", { range = true })
  
  user_cmd("NeoSwapVisualPrev", "lua require('NeoSwap').swap_visual_prev()", { range = true })
end

NeoSwap.entity_pattern = {}
NeoSwap.entity_pattern.w = {}
NeoSwap.entity_pattern.w._in = "\\w"
NeoSwap.entity_pattern.w.out = "\\W"
NeoSwap.entity_pattern.w.prev_end = "\\zs\\w\\W\\+$"
NeoSwap.entity_pattern.k = {}
NeoSwap.entity_pattern.k._in = "\\k"
NeoSwap.entity_pattern.k.out = "\\k\\@!"
NeoSwap.entity_pattern.k.prev_end = "\\k\\(\\k\\@!.\\)\\+$"


function NeoSwap.swap_prev(cursor_pos, type)
  type = type or "w"
  cursor_pos = cursor_pos or "follow"

  local line = api.nvim_get_current_line()
  local cursor = api.nvim_win_get_cursor(0)
  local c = cursor[2]
  local line_before_cursor = line:sub(1, c + 1)

  local _in = NeoSwap.entity_pattern[type]._in
  local out = NeoSwap.entity_pattern[type].out
  local prev_end = NeoSwap.entity_pattern[type].prev_end

  local current_word_start = fn.match(line_before_cursor, _in .. "\\+$")
  if current_word_start == -1 then
    NeoSwap.swap_next()
    return
  end
  local current_word_end = fn.match(line, _in .. out, current_word_start)
  current_word_end = current_word_end == -1 and #line - 1 or current_word_end

  local prev_word_end = fn.match(line:sub(1, current_word_start), prev_end)
  if prev_word_end == -1 then
    NeoSwap.swap_next()
    return
  end
  local prev_word_start = fn.match(line:sub(1, prev_word_end + 1), _in .. "\\+$")

  local current_word = line:sub(current_word_start + 1, current_word_end + 1)
  local prev_word = line:sub(prev_word_start + 1, prev_word_end + 1)

  local new_line = (prev_word_start > 0 and line:sub(1, prev_word_start) or "")
      .. current_word
      .. line:sub(prev_word_end + 2, current_word_start)
      .. prev_word
      .. line:sub(current_word_end + 2)

  local new_c = c
  if cursor_pos == "keep" then
    new_c = c + 1
  elseif cursor_pos == "follow" then
    new_c = c + prev_word_start - current_word_start + 1
  elseif cursor_pos == "left" then
    new_c = prev_word_start + 1
  elseif cursor_pos == "follow" then
    new_c = current_word:len() + current_word_start - prev_word_end + prev_word_start
  end

  api.nvim_set_current_line(new_line)
  api.nvim_win_set_cursor(0, { cursor[1], new_c - 1 })
end

function NeoSwap.swap_next(cursor_pos, type)
  type = type or "w"
  cursor_pos = cursor_pos or "follow"

  local line = api.nvim_get_current_line()
  local cursor = api.nvim_win_get_cursor(0)
  local c = cursor[2]
  local line_before_cursor = line:sub(1, c + 1)

  local _in = NeoSwap.entity_pattern[type]._in
  local out = NeoSwap.entity_pattern[type].out

  local current_word_start = fn.match(line_before_cursor, _in .. "\\+$")
  local current_word_end = fn.match(line, _in .. out, current_word_start)
  if current_word_end == -1 then
    NeoSwap.swap_prev()
    return
  end

  local next_word_start = fn.match(line, _in, current_word_end + 1)
  if next_word_start == -1 then
    NeoSwap.swap_prev()
    return
  end
  local next_word_end = fn.match(line, _in .. out, next_word_start)
  next_word_end = next_word_end == -1 and #line - 1 or next_word_end

  local current_word = line:sub(current_word_start + 1, current_word_end + 1)
  local next_word = line:sub(next_word_start + 1, next_word_end + 1)

  local new_line = (current_word_start > 0 and line:sub(1, current_word_start) or "")
      .. next_word
      .. line:sub(current_word_end + 2, next_word_start)
      .. current_word
      .. line:sub(next_word_end + 2)

  local new_c = c
  if cursor_pos == "keep" then
    new_c = c + 1
  elseif cursor_pos == "follow" then
    new_c = c + next_word:len() + next_word_start - current_word_end
  elseif cursor_pos == "left" then
    new_c = current_word_start + 1
  elseif cursor_pos == "follow" then
    new_c = c + next_word:len() + next_word_start - current_word_end + current_word_start
  end

  api.nvim_set_current_line(new_line)
  api.nvim_win_set_cursor(0, { cursor[1], new_c - 1 })
end

function NeoSwap.swap_visual_next(type)
  type = type or "w"
  
  -- Get visual selection bounds
  local start_pos = fn.getpos("'<")
  local end_pos = fn.getpos("'>")
  
  -- Only handle single-line selections for now
  if start_pos[2] ~= end_pos[2] then
    vim.notify("Multi-line visual swapping not supported", vim.log.levels.WARN)
    return
  end
  
  local line = api.nvim_get_current_line()
  local start_col = start_pos[3] - 1
  local end_col = end_pos[3] - 1
  
  -- Get the selected text
  local selected_text = line:sub(start_col + 1, end_col + 1)
  
  local _in = NeoSwap.entity_pattern[type]._in
  local out = NeoSwap.entity_pattern[type].out
  
  -- Find the next word after the selection
  local next_word_start = fn.match(line, _in, end_col + 1)
  if next_word_start == -1 then
    vim.notify("No word found after selection", vim.log.levels.INFO)
    return
  end
  
  local next_word_end = fn.match(line, _in .. out, next_word_start)
  next_word_end = next_word_end == -1 and #line - 1 or next_word_end
  
  local next_word = line:sub(next_word_start + 1, next_word_end + 1)
  
  -- Build the new line
  local new_line = (start_col > 0 and line:sub(1, start_col) or "")
      .. next_word
      .. line:sub(end_col + 2, next_word_start)
      .. selected_text
      .. line:sub(next_word_end + 2)
  
  api.nvim_set_current_line(new_line)
  
  -- Exit visual mode
  vim.cmd('normal! v')
end

function NeoSwap.swap_visual_prev(type)
  type = type or "w"
  
  -- Get visual selection bounds
  local start_pos = fn.getpos("'<")
  local end_pos = fn.getpos("'>")
  
  -- Only handle single-line selections for now
  if start_pos[2] ~= end_pos[2] then
    vim.notify("Multi-line visual swapping not supported", vim.log.levels.WARN)
    return
  end
  
  local line = api.nvim_get_current_line()
  local start_col = start_pos[3] - 1
  local end_col = end_pos[3] - 1
  
  -- Get the selected text
  local selected_text = line:sub(start_col + 1, end_col + 1)
  
  local _in = NeoSwap.entity_pattern[type]._in
  local out = NeoSwap.entity_pattern[type].out
  local prev_end = NeoSwap.entity_pattern[type].prev_end
  
  -- Find the previous word before the selection
  local line_before_selection = line:sub(1, start_col)
  local prev_word_end = fn.match(line_before_selection, prev_end)
  if prev_word_end == -1 then
    vim.notify("No word found before selection", vim.log.levels.INFO)
    return
  end
  
  local prev_word_start = fn.match(line:sub(1, prev_word_end + 1), _in .. "\\+$")
  local prev_word = line:sub(prev_word_start + 1, prev_word_end + 1)
  
  -- Build the new line
  local new_line = (prev_word_start > 0 and line:sub(1, prev_word_start) or "")
      .. selected_text
      .. line:sub(prev_word_end + 2, start_col)
      .. prev_word
      .. line:sub(end_col + 2)
  
  api.nvim_set_current_line(new_line)
  
  -- Exit visual mode
  vim.cmd('normal! v')
end

return NeoSwap
