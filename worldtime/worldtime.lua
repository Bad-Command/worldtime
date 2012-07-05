---
--worldtime
--Copyright (C) 2012 Bad_Command
--
--This library is free software; you can redistribute it and/or
--modify it under the terms of the GNU Lesser General Public
--License as published by the Free Software Foundation; either
--version 2.1 of the License, or (at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU Lesser General Public
--License along with this library; if not, write to the Free Software
--Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
----

-- Call this function to get the world time
worldtime.get = function() 
	return worldtime.worldtime
end
-- Obsolete function to get world time.  Use worldtime.get().
function worldtime_get() 
	return worldtime.get()
end

worldtime.last_file_io = -1
worldtime.worldtime = 0.0

worldtime.get_filename = function() 
	return minetest.get_worldpath(modname) .. "/" .. worldtime.save_file_name
end

worldtime.read_time = function() 
	local file
	local err
	file,err = io.open( worldtime.get_filename(), "r" )
	if err then
		return false
	end
	local text = file:read("*all")
	local time = string.match(text, "^(%d+\.?%d*)$")
	if time == nil or string.match(time, "^%d+\.$") then	
		minetest.log("info", "worldtime: Could not parse text when reading worldtime: " .. text)
		return false
	end
	worldtime.worldtime = time + 0.0
	worldtime.last_file_io = worldtime.worldtime
	return true
end

worldtime.write_time = function()
	local file
	local err
	file,err = io.open( worldtime.get_filename(), "w" )
	if err then 
		return false 
	end
	file:write(worldtime.worldtime)
	file:close()
	worldtime.last_file_io = worldtime.worldtime
	return true
end

worldtime.intialize = function()
	if not worldtime.read_time() then
		minetest.log('error', 
			"WARNING: worldtime:  Could not read time from "..
				worldtime.get_filename() )
		
	else 
		minetest.log('trace', 
			"worldtime:  Read current time ("..worldtime.worldtime..") from "..
				worldtime.get_filename() )
	end
end

worldtime.persist = function()
	minetest.after(worldtime.persist_time_interval,worldtime.persist);
	if not worldtime.write_time() then
		minetest.log('error', 
			"WARNING: worldtime:  Could not save time to "..
				worldtime.get_filename() )	
	else
		minetest.log('trace', 
			"worldtime:  Saved current time ("..worldtime.worldtime..") to "..
				worldtime.get_filename() )
	end
end

worldtime.timechange = function(dtime)
	worldtime.worldtime = worldtime.worldtime + dtime
end

worldtime.intialize()
worldtime.persist()
minetest.register_globalstep(worldtime.timechange)

