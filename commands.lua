minetest.register_chatcommand("weather", {
	params = "<weather type>",
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
