 --PROJECT GOALS
 --[[

rain when in warm biome

snow when in cold biome

only do weather particles when inside


do snow when temperature is implimented

 ]]--

--global to enable other mods/packs to utilize the ai
open_weather = {}
--this will depend on the heat of the chunk the player stands in
--the state of global weather
--0 = clear
--1 = light precipitation
--2 = heavy precipitation
--3 = storm
open_weather.state = 0
--the table to house player spawner IDs
open_weather.spawners = {}
--this is the global timer to update particle spawners
open_weather.spawner_timer = 0

--this sets the local particle spawner to the player
open_weather.set_spawner = function(player)
	local name = player:get_player_name()
	--delete old particle spawner
	if open_weather.spawners[name] ~= nil then
		--print("deleting id "..open_weather.spawners[name])
		minetest.delete_particlespawner(open_weather.spawners[name])
		open_weather.spawners[name] = nil
	end
	
	--return if clear to not waste resources
	if open_weather.state == 0 then
		return
	end
	
	local pos = player:getpos()
	local timeofday = minetest.get_timeofday()
	local light = minetest.get_node_light(pos, timeofday)

	local id = nil
	if light and light == 15 then
		local particle_amount
		if open_weather.state == 1 then
			particle_amount = 200
		elseif open_weather.state == 2 then
			particle_amount = 700
		elseif open_weather.state == 3 then
			particle_amount = 1200
		end
		
		id = minetest.add_particlespawner({
			amount = particle_amount,
			time = 0,
			minpos = {x=pos.x-20, y=pos.y-20, z=pos.z-20},
			maxpos = {x=pos.x+20, y=pos.y+20, z=pos.z+20},
			minvel = {x=0, y=-20, z=0},
			maxvel = {x=0, y=-20, z=0},
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 1,
			maxexptime = 1,
			minsize = 1,
			maxsize = 1,
			collisiondetection = true,
			vertical = true,
			texture = "open_weather_rain_drop.png",
			playername = name,
		})
	end
	if id ~= nil then
		--print("adding id "..id)
		open_weather.spawners[name] = id
	end
end

minetest.register_globalstep(function(dtime)
	open_weather.spawner_timer = open_weather.spawner_timer + dtime
	
	if open_weather.spawner_timer > 1 then
		print("update spawners")
		for _,player in ipairs(minetest.get_connected_players()) do
			open_weather.set_spawner(player)
		end
		open_weather.spawner_timer = 0
	end

end)



--run weather commands
dofile(minetest.get_modpath("open_weather").."/commands.lua")
