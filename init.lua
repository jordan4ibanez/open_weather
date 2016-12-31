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
--the players skybox
open_weather.skybox = {}
--the weather type (for now, in the future will use humidity of the biome)
--0 = rain
--1 = snow
open_weather.type = 0
--the old type
open_weather.old_type = 0

--stop effects
open_weather.sound_effect_stop = function(player,name)
	--stop sounds
	if (open_weather.state == 0 or open_weather.type ~= open_weather.old_type) and open_weather.sounds[name] ~= nil then
		--stop sound
		print("stopping sound")
		minetest.sound_stop(open_weather.sounds[name])
		open_weather.sounds[name] = nil
	end
	--remove player's skybox
	if open_weather.state == 0 and open_weather.skybox[name] ~= nil then
		print("removing skybox")
		player:set_sky({r=0, g=0, b=0},"regular",{})
		open_weather.skybox[name] = nil
	end
end

--delete old particle spawner
open_weather.clear_old_spawners = function(player,name)
	if open_weather.spawners[name] ~= nil then
		--print("deleting id "..open_weather.spawners[name])
		minetest.delete_particlespawner(open_weather.spawners[name])
		open_weather.spawners[name] = nil
	end
end

--play weather sounds
open_weather.play_weather_sounds = function(player,name,is_sheltered)
	local id 
	--rain
	if open_weather.type == 0 then
		if open_weather.state ~= 0 and open_weather.sounds[name] == nil then
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
	--snow
	elseif open_weather.type == 1 then
		if open_weather.state ~= 0 and open_weather.sounds[name] == nil then 
			if is_sheltered == false then
				print("playing outside sound")
				id = minetest.sound_play("open_weather_snow_outside", {
					to_player = name,
					gain = 1.0,
					loop = true,
				})
			elseif is_sheltered == true then
				id = minetest.sound_play("open_weather_snow_inside", {
					to_player = name,
					gain = 1.0,
					loop = true,
				})
			end
			
			open_weather.sounds[name] = id
		end
	end
end

open_weather.set_particle_spawner = function(player,name,is_sheltered,pos)
	local id
	--set particle spawner
	if is_sheltered == false then
		
		--set the particle amount
		local particle_amount
		if open_weather.state == 1 then
			particle_amount = 200
		elseif open_weather.state == 2 then
			particle_amount = 700
		elseif open_weather.state == 3 then
			particle_amount = 1400
		end
		
		--set the y velocity
		local y_velocity
		local particle
		
		if open_weather.type == 0 then
			particle = "open_weather_rain_drop.png"
			if open_weather.state == 1 then
				y_velocity = -20
			elseif open_weather.state == 2 then
				y_velocity = -30
			elseif open_weather.state == 3 then
				y_velocity = -40
			end	
		elseif open_weather.type == 1 then
			particle = "open_weather_snow_flake.png"
			if open_weather.state == 1 then
				y_velocity = -3
			elseif open_weather.state == 2 then
				y_velocity = -5
			elseif open_weather.state == 3 then
				y_velocity = -7
			end
		end
		
		local h_acceleration = 0
		--set the horizontal acceleration
		if open_weather.type == 1 then
			if open_weather.state == 1 then
				h_acceleration = 3
			elseif open_weather.state == 2 then
				h_acceleration = 6
			elseif open_weather.state == 3 then
				h_acceleration = 9
			end
		end
			
		
		id = minetest.add_particlespawner({
			amount = particle_amount,
			time = 0,
			minpos = {x=pos.x-20, y=pos.y-20, z=pos.z-20},
			maxpos = {x=pos.x+20, y=pos.y+20, z=pos.z+20},
			minvel = {x=0, y=y_velocity, z=0},
			maxvel = {x=0, y=y_velocity, z=0},
			minacc = {x=-h_acceleration, y=0, z=-h_acceleration},
			maxacc = {x=h_acceleration, y=0, z=h_acceleration},
			minexptime = 1,
			maxexptime = 1,
			minsize = 1,
			maxsize = 1,
			collisiondetection = true,
			vertical = true,
			texture = particle,
			playername = name,
		})
	end
	--add particle spawner id to global table
	if id ~= nil then
		--print("adding id "..id)
		open_weather.spawners[name] = id
	end
end
--make sounds update
open_weather.update_sounds = function(player,name,is_sheltered)
	if open_weather.sounds[name] ~= nil and is_sheltered ~= open_weather.sheltered[name] then
		--stop sound
		print("updating sound")
		minetest.sound_stop(open_weather.sounds[name])
		open_weather.sounds[name] = nil
	end
end

--set skybox to state
open_weather.update_skyboxes = function(player,name)
	
	
	local realtime = minetest.get_timeofday() * 24000
	--if weather state or type changes or updated skybox or time updates
	--update skybox
	if (open_weather.skybox[name] == nil or open_weather.state ~= open_weather.skybox[name]) or (realtime >= 18250 or (realtime >= 4500 and realtime <= 7000) or (realtime >= 0 and realtime < 4500))then
	
		open_weather.skybox[name] = open_weather.state
		
		--darkness of clouds depends on weather
		local rgb
		if open_weather.state == 1 then
			rgb = 130
		elseif open_weather.state == 2 then
			rgb = 117
		elseif open_weather.state == 3 then
			rgb = 105
		end
		
		
		--this section of code is copied from https://github.com/paramat/snowdrift/blob/master/init.lua
		--thanks paramat
		local time_mod = minetest.get_timeofday() * 100

		--evening
		--first transition starts at 18250
		--morning
		-- first transition (24000 -) 4500, (1 -) 0.1875
		-- last transition (24000 -) 7000, (1 -) 0.2396
		
		--evening
		if realtime >= 18250 then		
			rgb = rgb - time_mod
		--morning
		elseif realtime >= 4500 and realtime <= 7000 then
			rgb = rgb - 99 + ((time_mod - 18.75)*9.5)
		--middle of night
		elseif realtime >= 0 and realtime < 4500 then
			rgb = rgb - 99
		end
		--else don't modify (day)

		
		player:set_sky({r=rgb,g=rgb,b=rgb+5},"plain",{})
	end
end


--this sets the local particle spawner to the player
open_weather.set_spawner = function(player)
	
	local name = player:get_player_name()
	

	--stop old sounds if cold changes or weather is clear
	--also update skybox if changes
	open_weather.sound_effect_stop(player,name)
	
	--remove old spawners on each step
	open_weather.clear_old_spawners(player,name)
	
	
	--return if clear to not waste resources
	if open_weather.state == 0 then
		return
	end
	
	
	--variables for particle spawners
	local pos = player:getpos()
	local id = nil
	local is_sheltered = not (minetest.get_node_light(pos, 0.5) == 15)
	
	
	--make the sounds update
	open_weather.update_sounds(player,name,is_sheltered)

	
	--play new sounds if updated or new
	open_weather.play_weather_sounds(player,name,is_sheltered)
	
	--set the particles to simulate weather
	open_weather.set_particle_spawner(player,name,is_sheltered,pos)
		
	--set the skybox if needs update
	open_weather.update_skyboxes(player,name)

	--remember if sheltered
	open_weather.sheltered[name] = is_sheltered

end

--the global step function for weather
minetest.register_globalstep(function(dtime)
	open_weather.spawner_timer = open_weather.spawner_timer + dtime
	
	--update the state
	if open_weather.spawner_timer > 0.2 then
		--print("update spawners")
		for _,player in ipairs(minetest.get_connected_players()) do
			open_weather.set_spawner(player)
		end
		open_weather.spawner_timer = 0
		--remember the old type
		open_weather.old_type = open_weather.type
	end
	
	

end)



--run weather commands
dofile(minetest.get_modpath("open_weather").."/commands.lua")
