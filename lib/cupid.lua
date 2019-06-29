-----------------------------------------------------
-- (C) Robert Blancakert 2012
-- Available under the same license as Love
-----------------------------------------------------


-----------------------------------------------------
-- Cupid Configuration
-----------------------------------------------------

local config = {

	always_use = true,

	enable_console = true,
	console_key = '`',
	console_override_print = true,
	console_height = 0.33,
	console_key_repeat = true,
	console_start_open = false,

	enable_remote = true,
	font = "graphics/fonts/whiterabit.ttf", -- Load your own font for console

	enable_watcher = false,
	watcher_interval = 1.0,
	watcher_onchanged = "reload()",
	watcher_patterns = {"lua$"},
	enable_physics = false,
	physics_show = false,
	enable_temporal = true, -- Enable '[' and ']' keys to slow and speed up game

  -- Below in cupid_commands.env is where console commands are set, add more there
}

-----------------------------------------------------
-- Cupid Hooking 
-----------------------------------------------------

local cupid_error = function(...) error(...) end
local main_args = {...}

local wraped_love = {}
local game_funcs = {}
local protected_funcs = {'update','draw','keyreleased','keypressed','textinput','load'}
local _love
local function protector(table, key, value)
	for k,v in pairs(protected_funcs) do
		if ( v == key ) then
			game_funcs[key] = value
			return
		end
	end
	rawset(_love, key, value)
end

local mods = {}
local modules = {}

local loaded = false

local g = nil

local function cupid_load_identity()
	local x,y,w,h = g.getScissor()
	g.setScissor(0,0,0,0)
	g.clear()
	if x ~= nil then
		g.setScissor(x,y,w,h)
	else
		g.setScissor()
	end
end

local function retaining(...)
	local values = {}
	g.push()
	for k,v in pairs({...}) do
		if type(v) == "function" then
			 v()
		elseif type(v) == "string" then
			values[v] = {g["get" .. v]()}
		end 
	end
	for k,v in pairs(values) do if #v > 0 then g["set" .. k](unpack(v)) end end
	g.pop()
end

local function cupid_load(args)
	local use = true

	if use then
		setmetatable(wraped_love, {__index = love, __newindex = protector})
		_love = love
		love = wraped_love
		for k,v in pairs(protected_funcs) do
			_love[v] = function(...)
				if g == nil then g = love.graphics end
				local result = {}
				local arg = {...}
				local paused = false
				for km,vm in pairs(modules) do
					if vm["paused"] and vm["paused"](vm,...) == true then paused = true end
				end
				for km,vm in pairs(modules) do
					if vm["pre-" .. v] and vm["pre-" .. v](vm,...) == false then return end
				end
				
				for km,vm in pairs(modules) do
						if vm["arg-" .. v] then arg = {vm["arg-" .. v](vm,unpack(arg))} end
				end

				if game_funcs[v] and not paused then
					result = {select(1,xpcall(
						function() return game_funcs[v](unpack(arg)) end, cupid_error
					))}
				end
				for km,vm in pairs(modules) do if vm["post-" .. v] then vm["post-" .. v](vm,...) end end
				return unpack(result)
			end
		end

		table.insert(modules, {
		--	["arg-update"] = function(self,dt) return dt / 8 end
		})


		local function load_modules(what)
			local mod = mods[what]()
			if ( mod.init ) then mod:init() end
			modules[what] = mod
		end

		if config.enable_console then
			load_modules("console")
		end

		if config.enable_watcher then
			load_modules("watcher")
		end

		if config.enable_remote then
			load_modules("remote")
		end

		if config.enable_physics then
			load_modules("physics")
		end

		if config.enable_temporal then
			load_modules("temporal")
		end

		load_modules("error")
	else
		love.load = nil
	end

end

-----------------------------------------------------
-- Commands
-----------------------------------------------------
local function cupid_print(str,color) print(str) end

local cupid_commands
cupid_commands = {
	env = {
		config = config,
		mode = function(...) g.setMode(...) end, -- g.setMode is nil ATM
		quit = function(...) love.event.quit() end,
		dir = function(what, deep)
			if deep == nil then deep = true end
			what = what or cupid_commands.env
			local lst = {}
			while what ~= nil and type(what) == "table" do
				for k,v in pairs(what) do table.insert(lst,k) end
				local mt = getmetatable(what)
				if mt and deep then what = mt["__index"] else what = nil end
			end
			return "[" .. table.concat(lst, ", ") .. "]"
		end,
    clear = function(...) print('\n\n\n\n\n\n\n\n\n\n') end
	},
	["command"] = function(self, cmd)
		local xcmd = cmd
		if not (
			xcmd:match("end") or xcmd:match("do") or 
			xcmd:match("do") or xcmd:match("function") 
			or xcmd:match("return") or xcmd:match("=") 
		) then
			xcmd = "return " .. xcmd
		end
		local func, why = loadstring(xcmd,"*")
		if not func then
			return false, why
		end
		local xselect = function(x, ...) return x, {...} end
		setfenv(func,self.env)
		local ok, result = xselect(pcall(func))
		if not ok then
			return false, result[1]
		end

		if type(result[1]) == "function" and not xcmd:match("[()=]") then
			ok, result = xselect(pcall(result[1]))
			if not ok then 
				return false, result[1]
			end
		end
		
		if ( #result > 0 ) then
			local strings = {}
			for k,v in pairs(result) do strings[k] = tostring(v) end
			return true, table.concat(strings, " , ")
		end

		return true, "nil"
	end,
	["add"] = function(self, name, cmd)
		rawset(self.env, name, cmd)
	end


}

setmetatable(cupid_commands.env, {__index = _G, __newindex = _G})


-----------------------------------------------------
-- Module Reloader
-----------------------------------------------------

local cupid_keep_package = {}
for k,v in pairs(package.loaded) do cupid_keep_package[k] = true end

local cupid_keep_global = {}
for k,v in pairs(_G) do cupid_keep_global[k] = true end

local function cupid_reload(keep_globals)

	-- Unload packages that got loaded
	for k,v in pairs(package.loaded) do 
		if not cupid_keep_package[k] then package.loaded[k] = nil end
	end

	if not keep_globals then
		setmetatable(_G, {})
		for k,v in pairs(_G) do 
			if not cupid_keep_global[k] then _G[k] = nil end
		end
	end

	if modules.error then modules.error.lasterror = nil end
	if love.graphics then love.graphics.reset() end
	local game, why
	if ( main_args[1] == "main" ) then
		ok, game = pcall(love.filesystem.load, 'game.lua')
	else
		ok, game = pcall(love.filesystem.load, 'main.lua')
	end
	
	if not ok then cupid_error(game) return false end

	xpcall(game, cupid_error)
	if love.load then love.load() end
	return true
end
cupid_commands:add("reload", function(...) return cupid_reload(...) end)

-----------------------------------------------------
-- Helpers
-----------------------------------------------------

local cupid_font_data;
local function cupid_font(size)
	local ok, font = pcall(g.newFont,config.font,size)
	if ok then 
		return font
	else
		return g.newFont(cupid_font_data, size)
	end
end

-- Returns offset of the last UTF-8 symbol of the string
-- or 0 if the string is blank
local last_offset_utf8
local has_utf8, utf8 = pcall( require, 'utf8' )
if has_utf8 then
	last_offset_utf8 = function( s )
		return utf8.offset( s, -1 ) or 0
	end
else
	last_offset_utf8 = function( s )
		local n, last_len = 0, 1
		for uchar in s:sub(-4):gmatch( "([%z\1-\127\194-\244][\128-\191]*)" ) do
			last_len = #uchar
		end
		return #s-last_len+1
	end
end

-----------------------------------------------------
-- Module Console
-----------------------------------------------------

mods.console = function() return {
	buffer = "",
	shown = config.console_start_open or false,
	lastkey = "",
	log = {},
	history = {},
	history_idx = 0,
	lines = 12,
	["init"] = function(self)
		if config.console_override_print then
			local _print = print
			print = function(...) 
				local strings = {}
				for k,v in pairs({...}) do strings[k] = tostring(v) end
				self:print(table.concat(strings, "\t"))
				_print(...)
			end
		end
		cupid_print = function(str, color) self:print(str, color) end
	end,
	["post-load"] = function(self)
	end,
	["post-draw"] = function(self)
		if not self.shown then return end
		if self.height ~= g.getHeight() * config.console_height then
			self.height = g.getHeight() * config.console_height
			self.lineheight = self.height / self.lines
			self.font = cupid_font(self.lineheight)
		end
		retaining("Color","Font", function()
			cupid_load_identity()
			g.setColor(0,0,0,120)
			g.rectangle("fill", 0, 0, g.getWidth(), self.height)
			g.setColor(0,0,0,120)
			g.rectangle("line", 0, 0, g.getWidth(), self.height)
			if self.font then g.setFont(self.font) end
			local es = self.lineheight
			local xo = 5
			local idx = 1
			for k,v in ipairs(self.log) do
				g.setColor(0,0,0)
				local width, lines = g.getFont():getWrap(v[1], g.getWidth())
				if type(lines) == 'table' then lines = #lines end
				idx = idx + lines

				g.printf(v[1], xo, self.height - idx*es, g.getWidth() - xo * 2, "left")
				g.setColor(unpack(v[2]))
				g.printf(v[1], xo-1, self.height - idx*es, g.getWidth() - xo * 2, "left")
			end
			g.setColor(0,0,0)
			g.print("> " .. self.buffer .. "_", xo, self.height - es)
			g.setColor(255,255,255)
			g.print("> " .. self.buffer .. "_", xo - 1, self.height - es - 1)
		end)
	end,
	["pre-keypressed"] = function(self, key, isrepeatOrUnicode)

		if not self.shown then return true end
		
		if key == "up" then
			if self.history_idx < #self.history then
				self.history_idx = self.history_idx + 1		
				self.buffer = self.history[self.history_idx]
			end
		elseif key == "down" then
			if self.history_idx > 0 then
				self.history_idx = self.history_idx - 1		
				self.buffer = self.history[self.history_idx] or ""
			end
		else

			-- Love 0.8 - Simulate text input
			if type(isrepeatOrUnicode) == "number" then
				self["pre-textinput"](self, string.char(isrepeatOrUnicode))
			end
		end

		return false
	end,
	["pre-keyreleased"] = function(self, key)
		if key == config.console_key then 
			self:toggle()
			return false
		elseif key == "return" then
			if ( #self.buffer > 0 ) then
				self:command(self.buffer)
				self.buffer = ""
			else
				self:toggle()
			end
		elseif key == "backspace" then
			self.buffer = self.buffer:sub(1, last_offset_utf8(self.buffer) - 1)
		elseif key == "escape" and self.shown then
			self:toggle()
			return false
		end
		if self.shown then return false end
	end,
	["pre-textinput"] = function(self, text)
		if not self.shown then return true end
		if text ~= config.console_key then
			self.buffer = self.buffer .. text
		end
		return false
	end,
	["command"] = function(self, cmd)
		self.history_idx = 0
		table.insert(self.history, 1, cmd)
		self:print("> " .. cmd, {200, 200, 200})
		local ok, result = cupid_commands:command(cmd)
		self:print(result, ok and {255, 255, 255} or {255, 0, 0})
	end,
	["toggle"] = function(self) 
		self.shown = not self.shown 
		if config.console_key_repeat and love.keyboard.hasKeyRepeat ~= nil then
			if self.shown then
				self.keyrepeat = love.keyboard.hasKeyRepeat()
				love.keyboard.setKeyRepeat(true)
			elseif self.keyrepeat then
				love.keyboard.setKeyRepeat(self.keyrepeat)
				self.keyrepeat = nil
			end
		end
	end,
	["print"] = function(self, what, color)
		table.insert(self.log, 1, {what, color or {255,255,255,255}})
		for i=self.lines+1,#self.log do self.log[i] = nil end
	end
} end


-----------------------------------------------------
-- Remote Commands over UDP
-----------------------------------------------------

-- This command is your friend!
-- watchmedo-2.7 shell-command --command='echo reload | nc -u localhost 10173' .

mods.remote = function()
	local socket = require("socket")
	if not socket then return nil end
	return {
	["init"] = function(self)
		self.socket = socket.udp() 
		self.socket:setsockname("127.0.0.1",10173)
		self.socket:settimeout(0)
	end,
	["post-update"] = function(self)
		local a, b = self.socket:receive(100)
		if a then
			print("Remote: " .. a)
			cupid_commands:command(a)
		end
	end
	}
end

-----------------------------------------------------
-- Module Error Handler
-----------------------------------------------------


mods.error = function() return {
	["init"] = function(self)
		cupid_error = function(...) self:error(...) end
	end,
	["error"] = function(self, msg) 
		
		local obj = {msg = msg, traceback = debug.traceback()}
		cupid_print(obj.msg, {255, 0, 0})
		if not self.always_ignore then self.lasterror = obj end
		return msg
	end,
	["paused"] = function(self) return self.lasterror ~= nil end,
	["post-draw"] = function(self)
		if not self.lasterror then return end
		retaining("Color", "Font", function()
			cupid_load_identity()
			local ox = g.getWidth() * 0.1;
			local oy = g.getWidth() * 0.1;
			if self.height ~= g.getHeight() * config.console_height then
				self.height = g.getHeight() * config.console_height
				self.font = cupid_font(self.lineheight)
			end
			local hh = g.getHeight() / 20
			g.setColor(0, 0, 0, 128)
			g.rectangle("fill", ox,oy, g.getWidth()-ox*2, g.getHeight()-ox*2)
			g.setColor(0, 0, 0, 255)
			g.rectangle("fill", ox,oy, g.getWidth()-ox*2, hh)
			g.setColor(0, 0, 0, 255)
			g.rectangle("line", ox,oy, g.getWidth()-ox*2, g.getHeight()-ox*2)
			g.setColor(255, 255, 255, 255)
			local msg = string.format("%s\n\n%s\n\n\n[C]ontinue, [A]lways, [R]eload, [E]xit",
				self.lasterror.msg, self.lasterror.traceback)
			if self.font then g.setFont(self.font) end
			g.setColor(255, 255, 255, 255)
			g.print("[Lua Error]", ox*1.1+1, oy*1.1+1)
			g.setColor(0, 0, 0, 255)
			g.printf(msg, ox*1.1+1, hh + oy*1.1+1, g.getWidth() - ox * 2.2, "left")
			g.setColor(255, 255, 255, 255)
			g.printf(msg, ox*1.1, hh + oy*1.1, g.getWidth() - ox * 2.2, "left")
		end)
	end,
	["post-keypressed"] = function(self, key, unicode) 
		if not self.lasterror then return end
		if key == "r" then 
			self.lasterror = nil
			cupid_reload() 
		elseif key == "c" then
			self.lasterror = nil 
		elseif key == "a" then
			self.lasterror = nil 
			self.always_ignore = true
		elseif key == "e" then
			love.event.push("quit")
		end
	end

} end

-----------------------------------------------------
-- Module Watcher
-----------------------------------------------------

mods.watcher = function() return {
	lastscan = nil,
	doupdate = nil,
	["init"] = function(self) 
	end,
	["post-update"] = function(self, dt)
		if self.doupdate then
			self.doupdate = self.doupdate - dt
			if self.doupdate < 0 then
				if config.watcher_onchanged then
					cupid_commands:command(config.watcher_onchanged)
				end
				self.doupdate = nil
			end
		end
		if self.lastscan ~= nil then
			local now = love.timer.getTime()
			if now - self.lastscan < config.watcher_interval then return end
			local changed = false
			local data = self:scan()
			if self.files == nil then
				self.files = data
			else
				local old = self.files
				for k,v in pairs(data) do
					if not old[k] or old[k] ~= v then
						print(k .. " changed!", old[k], v)
						changed = true
					end
				end
			end
			if changed then
				self.doupdate = 0.5
			end
			self.files = data
		else
			self.files = self:scan()
		end
		
		self.lastscan = love.timer.getTime()
	end,
	["scan"] = function(self)
		local out = {}
		local function scan(where)

			-- Support 0.8
			local getDirectoryItems = love.filesystem.getDirectoryItems or love.filesystem.enumerate
			local list = getDirectoryItems(where)
			for k,v in pairs(list) do
				local file = where .. v
				-- if not love.filesystem.isFile(file) then
        if not love.filesystem.getInfo(file) then
					scan(file .. "/")
				else
					local match = true
					if config.watcher_patterns then
						match = false
						for k,v in pairs(config.watcher_patterns) do
							if file:match(v) then
								match = true
								break
							end
						end
					end
					if match then
						-- local modtime, err = love.filesystem.getLastModified(file)
            local modtime, err = love.filesystem.getInfo(file)
						if modtime then out[v] = modtime else print(err, file) end
					end
				end
			end
		end
		scan("/")
		return out
	end


} end

-----------------------------------------------------
-- Module Physics
-----------------------------------------------------

mods.physics = function() return {
	colors = {},
	["init"] = function(self) 

	end,
	["pre-load"] = function(self)
		local physics = love.physics
		local wraped_physics = {}
		wraped_physics.newWorld = function(...)
			local out = {physics.newWorld(...)}
			self.world = out[1]
			return unpack(out)
		end
		setmetatable(wraped_physics, {__index=physics})
		rawset(wraped_love, "physics", wraped_physics)
	end,
	["post-draw"] = function(self)
		if not config.physics_show then return end
		retaining("Color", function()
			if self.world then
				local c = 0
				for bk,bv in pairs(self.world:getBodyList()) do
					g.push()
					g.translate(bv:getPosition())
					g.rotate(bv:getAngle())
					c = c + 1
					if not self.colors[c] then 						
						self.colors[c] = {math.random(50,255),math.random(50,255),math.random(50,255)}
					end
					g.setColor(unpack(self.colors[c]))
					local x, y = bv:getWorldCenter()
					g.rectangle("fill",-5,-5,10,10)
					for fk, fv in pairs(bv:getFixtureList()) do
						local s = fv:getShape()
						local st = s:getType()
						if ( st == "circle" ) then
							g.circle("line", 0, 0, s:getRadius())
							g.line(0,0, s:getRadius(), 0)
						elseif ( st == "polygon" ) then
							g.polygon("line", s:getPoints())
						end
					end
					g.pop()
				end
			end
		end)
	end

} end

-----------------------------------------------------
-- Module Physics
-----------------------------------------------------

mods.temporal  = function() return {
	["arg-update"] = function(self, dt, ...)
		local mul = 1
		if love.keyboard.isDown("]") then
			mul = 4
		elseif love.keyboard.isDown("[") then
			mul = 0.25
		end
		return dt * mul, unpack({...})
	end
} end

-----------------------------------------------------
-- All Done!  Have fun :)
-----------------------------------------------------
print('...')
if ( main_args[1] == "main" ) then
	local ok, game = pcall(love.filesystem.load,'game.lua')
	game(main_args)
	love.main = cupid_load
else
	cupid_load()
end
loaded = true
