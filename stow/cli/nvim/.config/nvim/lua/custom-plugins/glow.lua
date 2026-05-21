-- Glow markdown preview: float & split
-- Uses system `glow` CLI via terminal buffer (ANSI support)
-- No external plugin needed

local COL_WIDTH_RATIO = 0.66 -- 2/3 of window width for comfortable reading
local COL_WIDTH_MIN = 60 -- minimum column width

local glow_state = {
  chan = nil,
  buf = nil,
  win = nil,
  filepath = nil,
  line_numbers = nil,
  mode = nil,
  resize_timer = nil,
  gen = 0, -- generation counter: only on_exit for the latest gen closes the window
}

local function close_glow(win, buf)
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

local function cleanup_state()
  pcall(vim.api.nvim_del_augroup_by_name, 'glow_resize')
  if glow_state.resize_timer then
    glow_state.resize_timer:stop()
    glow_state.resize_timer:close()
    glow_state.resize_timer = nil
  end
  glow_state.chan = nil
  glow_state.buf = nil
  glow_state.win = nil
  glow_state.filepath = nil
  glow_state.line_numbers = nil
end

local function setup_glow_buf(buf, win)
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].buflisted = false
  vim.keymap.set('n', 'q', function()
    glow_state.gen = glow_state.gen + 1 -- invalidate on_exit so it won't close window
    cleanup_state()
    close_glow(win, buf)
  end, { buffer = buf, nowait = true, desc = 'Close glow preview' })
end

local function get_markdown_filepath()
  local filepath = vim.fn.expand '%:p'
  if filepath == '' then
    vim.notify('File must be saved first', vim.log.levels.WARN)
    return nil
  end
  vim.cmd 'write'
  return filepath
end

local function glow_col_width(win, mode)
  local w = vim.api.nvim_win_get_width(win)
  if mode == 'split' then
    return w
  end
  return math.max(COL_WIDTH_MIN, math.floor(w * COL_WIDTH_RATIO))
end

local function run_glow(buf, win, filepath, width, line_numbers, gen)
  local cmd = string.format('glow -p --width %d %s', width, vim.fn.shellescape(filepath))
  local env = { COLORTERM = 'truecolor' }
  if line_numbers then
    env.PAGER = 'less -RN'
  end

  vim.api.nvim_win_call(win, function()
    glow_state.chan = vim.fn.termopen(cmd, {
      env = env,
      on_exit = function()
        -- Only close if this is still the current generation (not a restart)
        if glow_state.gen ~= gen then
          return
        end
        cleanup_state()
        close_glow(win, buf)
      end,
    })
  end)
end

local function restart_glow()
  local win = glow_state.win
  if not win or not vim.api.nvim_win_is_valid(win) then
    return
  end

  -- Bump generation so old on_exit won't close the window
  glow_state.gen = glow_state.gen + 1
  local gen = glow_state.gen

  local old_chan = glow_state.chan
  local old_buf = glow_state.buf

  if old_chan then
    pcall(vim.fn.jobstop, old_chan)
  end

  local new_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, new_buf)

  if old_buf and vim.api.nvim_buf_is_valid(old_buf) then
    vim.api.nvim_buf_delete(old_buf, { force = true })
  end

  setup_glow_buf(new_buf, win)
  glow_state.buf = new_buf

  run_glow(new_buf, win, glow_state.filepath, glow_col_width(win, glow_state.mode), glow_state.line_numbers, gen)
end

local function schedule_restart()
  if glow_state.resize_timer then
    glow_state.resize_timer:stop()
  else
    glow_state.resize_timer = vim.uv.new_timer()
  end
  glow_state.resize_timer:start(150, 0, vim.schedule_wrap(function()
    restart_glow()
  end))
end

---@param mode 'float' | 'split'
---@param line_numbers boolean
local function glow_open(mode, line_numbers)
  local filepath = get_markdown_filepath()
  if not filepath then
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local win

  if mode == 'float' then
    win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      width = vim.o.columns,
      height = vim.o.lines - 1,
      row = 0,
      col = 0,
    })
  else
    vim.cmd.vsplit()
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
    vim.cmd 'wincmd p'
  end

  setup_glow_buf(buf, win)

  glow_state.gen = glow_state.gen + 1
  local gen = glow_state.gen
  glow_state.buf = buf
  glow_state.win = win
  glow_state.filepath = filepath
  glow_state.line_numbers = line_numbers
  glow_state.mode = mode

  run_glow(buf, win, filepath, glow_col_width(win, mode), line_numbers, gen)

  -- Restart glow on window/terminal resize (debounced)
  vim.api.nvim_create_augroup('glow_resize', { clear = true })
  vim.api.nvim_create_autocmd({ 'WinResized', 'VimResized' }, {
    group = 'glow_resize',
    callback = function()
      if not glow_state.win or not vim.api.nvim_win_is_valid(glow_state.win) then
        return
      end
      -- For float windows, also resize the window itself on VimResized
      local config = vim.api.nvim_win_get_config(glow_state.win)
      if config.relative == 'editor' then
        vim.api.nvim_win_set_width(glow_state.win, vim.o.columns)
        vim.api.nvim_win_set_height(glow_state.win, vim.o.lines - 1)
      end
      -- For WinResized, only restart if our window was affected
      if vim.v.event and vim.v.event.windows then
        if not vim.tbl_contains(vim.v.event.windows, glow_state.win) then
          return
        end
      end
      schedule_restart()
    end,
  })
end

return {
  dir = vim.fn.stdpath 'config',
  name = 'glow-preview',
  event = 'VeryLazy',
  config = function()
    vim.keymap.set('n', '<leader>mp', function()
      glow_open('float', false)
    end, { desc = '[m]arkdown glow [p]review (float)' })
    vim.keymap.set('n', '<leader>ms', function()
      glow_open('split', false)
    end, { desc = '[m]arkdown glow [s]plit preview' })
    vim.keymap.set('n', '<leader>mS', function()
      glow_open('split', true)
    end, { desc = '[m]arkdown glow [S]plit with line numbers' })
  end,
}
