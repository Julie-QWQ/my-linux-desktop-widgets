-- ~/.config/conky/fetch/widget.lua
require("cairo")

local FONT = "Ubuntu Sans Mono"
local SIZE = 28
local COLOR = {1.0, 1.0, 1.0, 0.98}

local X = 450
local Y = 1115
local LINE_GAP = 50

local SHADOW_OPTS = {
  dx = 4, dy = 4,
  blur_r = 5,
  core_alpha = 1.0,
  blur_alpha = 0.30,
  sigma = 3,
  blur_gain = 6,
  blur_max_a = 0.04,
}

local cached_lines = nil

local function read_first_match(path, pattern)
  local f = io.open(path, "r")
  if not f then return nil end
  for line in f:lines() do
    local v = line:match(pattern)
    if v then f:close(); return v end
  end
  f:close()
  return nil
end

local function read_file_all(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end

local function popen_first_line(cmd)
  local p = io.popen(cmd)
  if not p then return nil end
  local line = p:read("*l")
  p:close()
  return line
end

local function fmt_uptime()
  local up = read_file_all("/proc/uptime")
  if not up then return "Uptime: ?" end
  local seconds = tonumber(up:match("^(%d+%.?%d*)")) or 0
  seconds = math.floor(seconds)

  local days = math.floor(seconds / 86400); seconds = seconds % 86400
  local hrs = math.floor(seconds / 3600); seconds = seconds % 3600
  local mins = math.floor(seconds / 60)

  if days > 0 then
    return string.format("Uptime: %dd %dh %dm", days, hrs, mins)
  elseif hrs > 0 then
    return string.format("Uptime: %dh %dm", hrs, mins)
  else
    return string.format("Uptime: %dm", mins)
  end
end

local function fmt_mem()
  local meminfo = read_file_all("/proc/meminfo")
  if not meminfo then return "Memory: ?" end
  local total_kb = tonumber(meminfo:match("MemTotal:%s+(%d+)")) or 0
  local avail_kb = tonumber(meminfo:match("MemAvailable:%s+(%d+)")) or 0
  if total_kb <= 0 then return "Memory: ?" end
  local used_kb = total_kb - avail_kb

  local total_g = total_kb / 1024 / 1024
  local used_g = used_kb / 1024 / 1024
  return string.format("Memory: %.1f/%.1f GiB", used_g, total_g)
end

local function fmt_disk()
  local line = popen_first_line([[df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}']])
  if not line or line == "" then return "Disk: ?" end
  return "Disk: " .. line
end

local function get_os()
  local pretty = read_first_match("/etc/os-release", [[^PRETTY_NAME="?(.-)"?$]])
  return pretty or "Linux"
end

local function get_kernel()
  local k = popen_first_line("uname -r")
  return k or "?"
end

local function get_cpu()
  local model = read_first_match("/proc/cpuinfo", "^model name%s*:%s*(.+)$")
  if not model then return "CPU: ?" end
  model = model:gsub("%s+", " ")
  return "CPU: " .. model
end

local function get_host()
  local user = os.getenv("USER") or "user"
  local host = popen_first_line("hostname") or "host"
  return user .. "@" .. host
end

local function refresh_cache()
  local lines = {}
  lines[#lines + 1] = get_host()
  lines[#lines + 1] = "OS: " .. get_os()
  lines[#lines + 1] = "Kernel: " .. get_kernel()
  lines[#lines + 1] = fmt_uptime()
  lines[#lines + 1] = get_cpu()
  lines[#lines + 1] = fmt_mem()
  lines[#lines + 1] = fmt_disk()
  cached_lines = lines
end

function draw_fetch(cr, w, h)
  -- Text content refreshes with Conky update cycle.
  refresh_cache()

  for i, s in ipairs(cached_lines) do
    local y = Y + (i - 1) * LINE_GAP
    shadow_draw_text(cr, s, X, y, FONT, SIZE, COLOR, SHADOW_OPTS)
  end
end
