-------------------------------
-- User-specific configuration
-------------------------------
ROOT_DIR = "D:\\Movies"
PATH_SEPARATOR = "\\"
-------------------------------


local lfs = require "lfs"

dofile "mime.lua"
local mimetypes = mime.mimetypes or {}
local VIDEO_MIMES = mime.VIDEO_MIMES or {}
local VIDEO_EXTS = mime.VIDEO_EXTS or {}


local function is_dir(path)
  return lfs.attributes(path, 'mode') == "directory"
end

local function is_file(path)
  return lfs.attributes(path, 'mode') == "file"
end

function startswith(s, start)
   return string.sub(s, 1, string.len(start)) == start
end

local function trim(s, pattern)
  pattern = pattern or '%s'
  return s:match("^" .. pattern .. "*(.*)"):match("(.-)" .. pattern .. "*$")
end

local function split(s, sep)
  local parts = {}
  local pattern = string.format("([^%s]+)", sep)
  s:gsub(pattern, function(part) table.insert(parts, part) end)
  return parts
end

local function join_paths(...)
  local paths = {}
  for _,part in ipairs(arg) do
	part = trim(part, '[/\\]')
	if part ~= "" then
	  table.insert(paths, part)
	end
  end
  return table.concat(paths, PATH_SEPARATOR)
end

local function fix_path_separators(path, sep)
  sep = sep or PATH_SEPARATOR
  return path:gsub('[\\/]', sep)
end

-- Returns a resolved path (i.e., relative to absolute)
local function realpath(path)
  local unipath = (# path) == 0 or path[0] ~= '/'
  if path:find(':') == nil and unipath then
    path = join_paths(lfs.currentdir(), path)
  end

  path = fix_path_separators(path)
  local parts = split(path, PATH_SEPARATOR)
  local absolutes = {}

  for k,part in ipairs(parts) do repeat
    if part == '.' then break end
    if part == '..' then
      table.remove(absolutes)
    else
      table.insert(absolutes, part)
    end
  until true end

  path = table.concat(absolutes, PATH_SEPARATOR)
  path = not unipath and ('/' .. path) or path
  return path
end

local function pluralize(num, singular, plural)
  if num == 1 then
	return singular
  else
	return plural
  end
end

local HTML_SPECIALS = {
  ['&'] = '&amp;',
  ['"'] = '&quot;',
  ['<'] = '&lt;',
  ['>'] = '&gt;'
}
local function htmlspecialchars(s)
  for find,replace in ipairs(HTML_SPECIALS) do
    s = s.gsub(find, replace)
  end
  return s
end

local function mimefromext(ext, default)
  default = default or 'application/unknown'
  if ext then
	return mimetypes[ext] or default
  else
	return default
  end
end

function read_dir_recursive(path, tab)
  tab = tab or 3

  if is_dir(path) then
	local entries = 0
	local videos = 0

	local out = { "<ul>" }

	for entry in lfs.dir(path) do
	  if entry ~= "." and entry ~= ".." then
		entries = entries + 1
		local entry_path = join_paths(path, entry)

		local sub_entries, sub_videos, sub_out = read_dir_recursive(
			entry_path, tab)

		local mime
		local title = entry
		local is_video = false
		if sub_entries > 0 then
		  local sub_entries_text = string.format("%d %s", sub_entries,
			  pluralize(sub_entries, "entry", "entries"))
		  if sub_videos > 0 then
			sub_entries_text = string.format(
				'%s, <span class="num_videos">%d %s</span>', sub_entries_text,
				sub_videos, pluralize(sub_videos, 'video', 'videos'))
		  end
		  title = string.format('%s <span class="num_entries">(%s)</span>',
			  title, sub_entries_text)

		elseif is_file(entry_path) then
		  local _,_,ext = string.find(entry_path, "%.([^.]*)$")
		  mime = mimefromext(ext)
		  if VIDEO_EXTS[ext] or VIDEO_MIMES[mime] then
			is_video = true
			videos = videos + 1
		  end

		  if mime then
			title = string.format('%s <span class="mimetype">(%s)</span>',
				title, mime)
		  end
		end -- elseif is_file(entry_path)

		table.insert(out, '  <li>')
		table.insert(out, string.format(
			'    <span title="%s" class="entry%s">%s</span>', entry_path,
			is_video and ' is_video ' .. mime:gsub('/', '__') or '', title))
		table.insert(out, sub_out)
		table.insert(out, '  </li>')
	  end -- if not . or ..
	end -- for files in path

	table.insert(out, "</ul>")

	local indent = string.rep('  ', tab)
	return entries, videos, indent .. table.concat(out, "\n" .. indent)
  end -- if is_dir(path)

  return 0, 0, ""
end

function is_valid_file(path)
  local _path = realpath(path)
  return startswith(_path, ROOT_DIR) and is_file(_path)
end

function get_media_info(path)
  local mediainfo = join_paths('MediaInfo', 'MediaInfo')
  local args = string.format('"%s"', string.gsub(path, '"', '\\"'))
  local cmd = mediainfo .. ' ' .. args

  local file = assert(io.popen(cmd, 'r'))
  local output = file:read('*all')
  file:close()

  -- Make MediaInfo's output pretty
  local html = trim(output)
  html = string.gsub(html, '^(.-)\n', '<span class="title">%1</span>\n', 1)
  html = string.gsub(html, '\n\n(.-)\n', '\n\n<span class="title">%1</span>\n')

  local attr_value = function(attr, value, ending)
    ending = ending or ''
    return string.format(
        '<span class="attr">%s</span>: ' ..
        '<span class="value">%s</span>%s',
        htmlspecialchars(trim(attr)), htmlspecialchars(trim(value)),
        ending
    )
  end
  html = string.gsub(html, '([^<\n]-)\s-:\s-([^<\n]-)(\n)', attr_value)
  html = string.gsub(html, '([^<\n]-)\s-:\s-([^<\n]-)$', attr_value)
  html = string.gsub(html, '\n', '<br>\n')

  return html
end
