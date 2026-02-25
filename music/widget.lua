-- ~/.config/conky/music/widget.lua
require("cairo")

local CAVA_FILE = os.getenv("HOME") .. "/cava.txt"

-- Layout
local X = 1560
local BASELINE_Y = 1450

-- Bar geometry
local BAR_WIDTH = 50
local BAR_GAP = BAR_WIDTH * 0.5
local MAX_LEVEL = 96
local PX_PER_LEVEL = 6
local MAX_HEIGHT = MAX_LEVEL * PX_PER_LEVEL
local MIN_BAR_HEIGHT = 2

-- Style
local SHADOW_RGBA = {0.0, 0.0, 0.0, 0.1}
local SHADOW_DX = 3
local SHADOW_DY = 3
local BAR_COLORS = {
  {0.29, 0.72, 0.92, 0.5},
  {0.33, 0.70, 0.92, 0.5},
  {0.36, 0.68, 0.92, 0.5},
  {0.40, 0.66, 0.92, 0.5},
  {0.44, 0.64, 0.92, 0.5},
  {0.48, 0.62, 0.92, 0.5},
  {0.51, 0.59, 0.92, 0.5},
  {0.55, 0.57, 0.92, 0.5},
  {0.59, 0.55, 0.92, 0.5},
  {0.63, 0.53, 0.92, 0.5},
  {0.66, 0.51, 0.92, 0.5},
  {0.70, 0.49, 0.92, 0.5},

  -- {0.95, 0.36, 0.35, 0.66}, -- coral red
  -- {0.98, 0.52, 0.28, 0.66}, -- orange
  -- {0.99, 0.72, 0.30, 0.66}, -- amber
  -- {0.90, 0.86, 0.33, 0.66}, -- yellow
  -- {0.66, 0.86, 0.38, 0.66}, -- lime
  -- {0.42, 0.84, 0.55, 0.66}, -- mint
  -- {0.30, 0.80, 0.74, 0.66}, -- teal
  -- {0.29, 0.72, 0.92, 0.66}, -- sky blue
  -- {0.36, 0.60, 0.95, 0.66}, -- blue
  -- {0.52, 0.54, 0.96, 0.66}, -- indigo
  -- {0.70, 0.49, 0.92, 0.66}, -- violet
  -- {0.88, 0.43, 0.80, 0.66}, -- magenta
}
local DEBUG_TEXT_RGBA = {1.0, 1.0, 1.0, 0.65}
local last_valid_values = {}


local function read_last_line(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local last = nil
  for line in f:lines() do
    last = line
  end
  f:close()
  return last
end

local function parse_values(line)
  if not line or line == "" then return {} end
  line = line:gsub(";", " ")

  local values = {}
  for token in line:gmatch("%S+") do
    local v = tonumber(token) or 0
    if v < 0 then v = 0 end
    if v > 1000 then v = 1000 end
    values[#values + 1] = v
  end
  return values
end

local function set_rgba(cr, rgba)
  cairo_set_source_rgba(cr, rgba[1], rgba[2], rgba[3], rgba[4])
end

local function color_for_bar(index)
  local n = #BAR_COLORS
  if n == 0 then return {0.00, 0.00, 0.00, 0.50} end
  return BAR_COLORS[((index - 1) % n) + 1]
end

local function draw_bar(cr, x, baseline_y, bar_h, rgba)
  if bar_h <= 0 then
    bar_h = MIN_BAR_HEIGHT
  end

  local base_a = SHADOW_RGBA[4] or 0
  if base_a > 0 then
    cairo_set_source_rgba(cr, SHADOW_RGBA[1], SHADOW_RGBA[2], SHADOW_RGBA[3], base_a)
    cairo_rectangle(cr, x + SHADOW_DX, baseline_y - bar_h + SHADOW_DY, BAR_WIDTH, bar_h)
    cairo_fill(cr)
  end

  set_rgba(cr, rgba)
  cairo_rectangle(cr, x, baseline_y - bar_h, BAR_WIDTH, bar_h)
  cairo_fill(cr)
end

function draw_music(cr, w, h)
  local line = read_last_line(CAVA_FILE)
  local values = parse_values(line)
  if #values > 0 then
    last_valid_values = values
  else
    values = last_valid_values
  end
  if #values == 0 then
    shadow_draw_text(cr, "NO CAVA DATA", X, BASELINE_Y, "Ubuntu Sans Mono", 24, DEBUG_TEXT_RGBA, {
      dx = 1, dy = 1, blur_r = 1, core_alpha = 0.25, blur_alpha = 0.1, sigma = 1.5, blur_gain = 2, blur_max_a = 0.02
    })
    return
  end

  for i, v in ipairs(values) do
    local level = (v / 1000) * MAX_LEVEL
    local bar_h = math.floor(level * PX_PER_LEVEL + 0.5)
    if bar_h > MAX_HEIGHT then bar_h = MAX_HEIGHT end

    local bar_x = X + (i - 1) * (BAR_WIDTH + BAR_GAP)
    draw_bar(cr, bar_x, BASELINE_Y, bar_h, color_for_bar(i))
  end
end
