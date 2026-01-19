local M = {}

M.setup = function()
end

local test_lines = { "# GEV", "NVIM", "# ARI" }

local get_window_configurations = function()
  local width = vim.o.columns
  local height = vim.o.lines
  local title_height = 1 + 2
  local footer_height = 1
  local body_height = height - title_height - footer_height - 3
  return {
    background = {
      relative = "editor",
      width = width,
      height = height,
      style = "minimal",
      col = 0,
      row = 0,
      zindex = 1,
    },
    title = {
      relative = "editor",
      width = width,
      height = 1,
      style = "minimal",
      border = "rounded",
      col = 0,
      row = 1,
      zindex = 2,
    },
    body = {
      relative = "editor",
      width = width - 8,
      height = body_height,
      style = "minimal",
      -- border = { " ", " ", " ", " ", " ", " ", " ", " " },
      border = "solid",
      col = 8,
      row = 4,
      zindex = 2,
    },
    footer = {
      relative = "editor",
      width = width,
      height = 1,
      style = "minimal",
      border = "solid",
      col = 0,
      row = height - 1,
      zindex = 4,
    },
  }
end

---@class present.Slide
---@field title string
---@field body string[]
---@field block string

---@class present.Slides
---@field slides present.Slide[]

local function create_floating_window(config, enter)
  if enter == nil then
    enter = false
  end
  local buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer

  -- Create the floating window
  local win = vim.api.nvim_open_win(buf, enter, config)

  return { buf = buf, win = win }
end

---@param lines string[]
---@return present.Slides
local function parse_slides(lines)
  local slides = { slides = {} }
  local current_slide = {
    title = "",
    body = {}
  }
  local separator = "^#"

  for _, line in ipairs(lines) do
    if line:find(separator) then
      if current_slide.title ~= "" then
        table.insert(slides.slides, current_slide)
      end
      current_slide = { title = line, body = {} }
    else
      table.insert(current_slide.body, line)
    end
  end

  if current_slide.title ~= "" then
    table.insert(slides.slides, current_slide)
  end

  return slides
end

local state = {
  current_slide = 1,
  parsed = {},
  floats = {},
  filename = "",
}

local foreach_float = function(cb)
  for name, float in pairs(state.floats) do
    cb(name, float)
  end
end

M.start_presentation = function(opts)
  opts = opts or {}
  opts.bufnr = opts.bufnr or 0

  local lines
  if not vim.api.nvim_buf_is_valid(opts.bufnr) or vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false) == "" then
    print("using test")
    state.filename = vim.fn.expand("%:t")
    lines = test_lines
  else
    print("using bufnr")
    state.filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(opts.bufnr), ":t")
    lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
  end
  state.parsed = parse_slides(lines)

  ---@type vim.api.keyset.win_config

  local windowConfigs = get_window_configurations()
  state.floats.background = create_floating_window(windowConfigs.background)
  state.floats.title = create_floating_window(windowConfigs.title)
  state.floats.footer = create_floating_window(windowConfigs.footer)
  state.floats.body = create_floating_window(windowConfigs.body, true)


  foreach_float(function(_, float)
    vim.bo[float.buf].filetype = "markdown"
  end)

  local generate_footer = function(idx, total)
    local progress_section = string.rep("/", idx) .. string.rep(" ", total - idx)
    local footer = string.format("[%s] %d/%d | %s", progress_section, idx, total, state.filename)
    return footer
  end

  local set_slide_content = function(idx)
    local slide = state.parsed.slides[idx]
    local width = vim.o.columns
    local padding = string.rep(" ", math.max(0, (width - #slide.title) / 2))
    local title = padding .. slide.title
    local footer = generate_footer(idx, #state.parsed.slides)

    vim.api.nvim_buf_set_lines(state.floats.title.buf, 0, -1, false, { title })
    vim.api.nvim_buf_set_lines(state.floats.footer.buf, 0, -1, false, { footer })
    vim.api.nvim_buf_set_lines(state.floats.body.buf, 0, -1, false, slide.body)
  end
  if #state.parsed.slides == 0 then
    print("No slides found.")
    return
  end


  --NextSlide keymap
  vim.keymap.set("n", "n", function()
    state.current_slide = math.min(state.current_slide + 1, #state.parsed.slides)
    set_slide_content(state.current_slide)
  end, {
    buffer = state.floats.body.buf }
  )

  --PreviousSlide keymap
  vim.keymap.set("n", "p", function()
    state.current_slide = math.max(state.current_slide - 1, 1)
    set_slide_content(state.current_slide)
  end, {
    buffer = state.floats.body.buf }
  )

  --QuitPresentation keymap
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(state.floats.body.win, true)
  end, {
    buffer = state.floats.body.buf }
  )
  local restore = {
    cmdheight = {
      original = vim.o.cmdheight,
      present = 0,
    }
  }

  for option, config in pairs(restore) do
    vim.opt[option] = config.present
  end


  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = state.floats.body.buf,
    callback = function()
      for option, config in pairs(restore) do
        vim.opt[option] = config.original
      end
      foreach_float(function(_, float)
        pcall(vim.api.nvim_win_close, float.win, true)
      end)
    end
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("present-resized", {}),
    callback = function()
      if not vim.api.nvim_win_is_valid(state.floats.body.win) or state.floats.body.win == nil then
        return
      end

      local windows = get_window_configurations()
      foreach_float(function(name, _)
        vim.api.nvim_win_set_config(state.floats[name].win, windows[name])
      end)
      set_slide_content(state.current_slide)
    end
  })
  set_slide_content(1)
end

return M
