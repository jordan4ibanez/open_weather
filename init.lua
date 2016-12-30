 --PROJECT GOALS
 --[[

set the skybox to weather type


rain when in warm biome

snow when in cold biome

no weather when in desert 
or sand storm?

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
--the table to house sound IDs
open_weather.sounds = {}
--this is the global timer to update particle spawners
open_weather.spawner_timer = 0
--remember if player is inside or outside
open_weather.sheltered = {}

--this sets the local particle spawner to the player
open_weather.set_spawner = function(player)
	
	local name = player:get_player_name()
	
	--delete old particle spawner
	if open_weather.spawners[name] ~= nil then
		--print("deleting id "..open_weather.spawners[name])
		minetest.delete_particlespawner(open_weather.spawners[name])
		open_weather.spawners[name] = nil
	end
	
	
	--stop sounds
	if open_weather.state == 0 and open_weather.sounds[name] ~= nil then
		--stop sound
		print("stopping sound")
		minetest.sound_stop(open_weather.sounds[name])
		open_weather.sounds[name] = nil
	end
		
	--return if clear to not waste resources
	if open_weather.state == 0 then
		return
	end
	
	--variables for particle spawners
	local pos = player:getpos()
	local id = nil
	local is_sheltered = not minetest.line_of_sight(pos, {x=pos.x,y=pos.y+40,z=pos.z}, 1) --will still rain if in huge house
		
	--update sounds
	if open_weather.sounds[name] ~= nil and is_sheltered ~= open_weather.sheltered[name] then
		--stop sound
		print("updating sound")
		minetest.sound_stop(open_weather.sounds[name])
		open_weather.sounds[name] = nil
	end
	
	--play weather sounds
	if open_weather.state ~= 0 and open_weather.sounds[name] == nil then
		local id 
		if is_sheltered == false then
			print("playing outside sound")
			id = minetest.sound_play("open_weather_rain_outside", {
				to_player = name,
				gain = 1.0,
				loop = true,
			})
		elseif is_sheltered == true then
			id = minetest.sound_play("open_weather_rain_inside", {
				to_player = name,
				gain = 1.0,
				loop = true,
			})
		end
		
		open_weather.sounds[name] = id
	end
	if is_sheltered == false then
		
		--set the particle amount
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
	
	--add particle spawner id to global table
	if id ~= nil then
		--print("adding id "..id)
		open_weather.spawners[name] = id
	end
	--remember if sheltered
	open_weather.sheltered[name] = is_sheltered

end

--the global step function for weather
minetest.register_globalstep(function(dtime)
	open_weather.spawner_timer = open_weather.spawner_timer + dtime
	
	--update the state
	if open_weather.spawner_timer > 1 then
		--print("update spawners")
		for _,player in ipairs(minetest.get_connected_players()) do
			open_weather.set_spawner(player)
		end
		open_weather.spawner_timer = 0
	end

end)



--run weather commands
dofile(minetest.get_modpath("open_weather").."/commands.lua")
