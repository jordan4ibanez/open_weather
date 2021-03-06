--the set weather commands
--[[
weather commands:
0 clear
1 light
2 heavy
3 storm

can either type the word or number to get the state if you have server privelage

]]--
minetest.register_chatcommand("weather", {
	params = "<precipitation force>",
	description = "Set the weather",
	privs = {server = true},
	func = function( name, weather)
		if weather == "clear" or weather == "0" then
			open_weather.state = 0
			minetest.chat_send_player(name, "Setting weather to clear!")
		elseif weather == "light" or weather == "1" then
			open_weather.state = 1
			minetest.chat_send_player(name, "Setting weather to light precipitation!")
		elseif weather == "heavy" or weather == "2" then
			open_weather.state = 2
			minetest.chat_send_player(name, "Setting weather to heavy precipitation!")
		elseif weather == "storm" or weather == "3" then
			open_weather.state = 3
			minetest.chat_send_player(name, "Setting weather to storm!")
		else
			minetest.chat_send_player(name, weather.." is not a state!")
		end
		
	end,
})

--[[
sets rain or snow

0 = rain
1 = snow

]]--
minetest.register_chatcommand("cold", {
	params = "<weather type>",
	description = "Set the weather",
	privs = {server = true},
	func = function( name, weather)
		if weather == "rain" or weather == "0" then
			open_weather.type = 0
			minetest.chat_send_player(name, "Setting weather to rain!")
		elseif weather == "snow" or weather == "1" then
			open_weather.type = 1
			minetest.chat_send_player(name, "Setting weather to snow!")
		else
			minetest.chat_send_player(name, weather.." is not a weather type!")
		end
	end,
})
