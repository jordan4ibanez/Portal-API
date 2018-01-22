--create specific nodebox for portals

--better sounds

--better physics (ie lock the player in place so they don't fly while being transported)

--if player breaks portal border then recursively delete portal blocks (check x or z)

--make global table that tells if player is already in portal
--side node, just get pos and math.floor it, and if different check again until player is no longer in portal


--an api to create portals in the world
portal = {}

local max_portal_height = 30
local max_portal_width = 15

portal.register_portal = function(activator,desired_node,filler_node)
	--log the player name
	minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
		if newnode.name == activator and desired_node == minetest.get_node(pointed_thing.under).name then
			--minetest.set_node(pos, {name="default:glass"})
			local meta = minetest.get_meta(pos)
			meta:set_string("creator", placer:get_player_name())
		end
	end)
	
	minetest.register_abm({
		nodenames = {desired_node},
		neighbors = {activator},
		interval = 1,
		chance = 1,
		action = function(pos, node)
			pos.y = pos.y + 1
			if minetest.get_node(pos).name == activator then
				local meta = minetest.get_meta({x=pos.x,y=pos.y,z=pos.z})
				local creator = meta:get_string("creator")				
				minetest.remove_node(pos)
				pos.y = pos.y - 1
				portal.check_portal(pos,desired_node,"z",filler_node,creator)
			end
		end,
	})
end


portal.check_portal = function(pos,desired_node,axis,filler_node,creator)
	local xfail = false
	local yfail = false
	local zfail = false
	--go through the height of the portal
	for y = 1,max_portal_height do
		--check the cap of the portal
		local node = minetest.get_node({x=pos.x,y=pos.y+y,z=pos.z}).name
		if node == desired_node then
			--print("got the height cap!")
			break
		elseif y == max_portal_height and node ~= desired_node then
			--print("portal is too tall!")
			yfail = true
			break
		else
			if node ~= "air" then
				fail = true
				--print("failure in the height check")
				yfail = true
				break
			end
		end
		
		
		if xfail == false then
			--go through -x to check if portals are able to be created
			for x = -1,-max_portal_width,-1 do
				local node = minetest.get_node({x=pos.x+x,y=pos.y+y,z=pos.z}).name
				--if there are any nodes not desired in the portal, don't create
				if node == desired_node then
					--print("got - x cap!")
					break
				elseif x == -max_portal_width and node ~= desired_node then
					--print("portal is too wide -x!")
					xfail = true
					break
				else
					if node ~= "air" then
						--print("failure in the - x axis check")
						xfail = true
						break
					end
				end
			end
			--go through +x to check if portals are able to be created
			for x = 1,max_portal_width do
				local node = minetest.get_node({x=pos.x+x,y=pos.y+y,z=pos.z}).name
				--if there are any nodes not desired in the portal, don't create
				if node == desired_node then
					--print("got + x cap!")
					break
				elseif x == max_portal_width and node ~= desired_node then
					--print("portal is too wide +x!")
					xfail = true
					break
				else
					if node ~= "air" then
						--print("failure in the + x axis check")
						xfail = true
						break
					end
				end
			end
		end
		if zfail == false then
			--go through -z to check if portals are able to be created
			for z = -1,-max_portal_width,-1 do
				local node = minetest.get_node({x=pos.x,y=pos.y+y,z=pos.z+z}).name
				--if there are any nodes not desired in the portal, don't create
				if node == desired_node then
					--print("got - z cap!")
					break
				elseif z == -max_portal_width and node ~= desired_node then
					--print("portal is too wide -z!")
					zfail = true
					break
				else
					if node ~= "air" then
						--print("failure in the - z axis check")
						zfail = true
						break
					end
				end
			end
			--go through +z to check if portals are able to be created
			for z = 1,max_portal_width do
				local node = minetest.get_node({x=pos.x,y=pos.y+y,z=pos.z+z}).name
				--if there are any nodes not desired in the portal, don't create
				if node == desired_node then
					--print("got + z cap!")
					break
				elseif z == max_portal_width and node ~= desired_node then
					--print("portal is too wide +z!")
					zfail = true
					break
				else
					if node ~= "air" then
						--print("failure in the + z axis check")
						zfail = true
						break
					end
				end
			end
		end
	end
	--if it found a portal that works, create the filler
	if yfail == false then
		--prefer x axis to z axis
		if xfail == false then
			portal.create_portal(pos,desired_node,"x",filler_node,creator)
			minetest.sound_play("portal_creation", {
				pos = pos,
				max_hear_distance = 10,
				gain = 0.1,
			})
		elseif zfail == false then
			portal.create_portal(pos,desired_node,"z",filler_node,creator)
			minetest.sound_play("portal_creation", {
				pos = pos,
				max_hear_distance = 10,
				gain = 0.1,
			})
		end
	end
end


portal.link_portal = function(pos,teleport_pos)

	local meta = minetest.get_meta(pos)
	meta:set_string("teleport_pos", minetest.pos_to_string(teleport_pos))
	
	--minetest.string_to_pos(string)
	--print(dump(meta:get_string("teleport_pos")))
	print(dump(minetest.string_to_pos(meta:get_string("teleport_pos"))))
	
end

--meta:set_string("infotext", "Chest");

portal.create_portal = function(pos,desired_node,axis,filler_node,creator)
	
	local pos2 = {x=pos.x,y=pos.y,z=pos.z} --memory leak if (pos2 = pos)
	
	--hack to allow hell portals
	pos2.x = pos2.x + math.random(-100,100)
	pos2.z = pos2.z + math.random(-100,100)
	pos2.y = math.random(-25000,-22000)
	
	
	--minetest.set_node(pos, {name="default:glass"})
	
	
	
	local sizey = 0
	local sizexmin = 0
	local sizexmax = 0
	local sizezmin = 0
	local sizezmax = 0
	
	
	--generate portal 1-----------------------------------------------------
	
	--this function assumes portal check is correct and the game didn't add any nodes into space
	--in half step somehow, it'll remove them anyways
	for y = 1,max_portal_height do
		--if the cap node is found, end function loop
		local node = minetest.get_node({x=pos.x,y=pos.y+y,z=pos.z}).name
		if node ~= desired_node then
			minetest.set_node({x=pos.x,y=pos.y+y,z=pos.z}, {name=filler_node})
			portal.link_portal({x=pos.x,y=pos.y+y,z=pos.z},pos2)
		elseif node == desired_node then
			--print("portal completed!")
			break
		end
		if y > sizey then
			sizey = y
		end
		if axis == "x" then
			--go through -x to check if portals are able to be created
			for x = -1,-max_portal_width,-1 do
				local node = minetest.get_node({x=pos.x+x,y=pos.y+y,z=pos.z}).name
				--add node if not at portal wall
				if node ~= desired_node then
					minetest.set_node({x=pos.x+x,y=pos.y+y,z=pos.z}, {name=filler_node})
					portal.link_portal({x=pos.x+x,y=pos.y+y,z=pos.z},pos2)
				elseif node == desired_node then
					break
				end
				if x < sizexmin then
					sizexmin = x
				end
			end
			--go through +x to check if portals are able to be created
			for x = 1,max_portal_width do
				local node = minetest.get_node({x=pos.x+x,y=pos.y+y,z=pos.z}).name
				--add node if not at portal wall
				if node ~= desired_node then
					minetest.set_node({x=pos.x+x,y=pos.y+y,z=pos.z}, {name=filler_node})
					portal.link_portal({x=pos.x+x,y=pos.y+y,z=pos.z},pos2)
				elseif node == desired_node then
					break
				end
				if x > sizexmax then
					sizexmax = x
				end
			end
		end
		if axis == "z" then
			--go through -z to check if portals are able to be created
			for z = -1,-max_portal_width,-1 do
				local node = minetest.get_node({x=pos.x,y=pos.y+y,z=pos.z+z}).name
				--add node if not at portal wall
				if node ~= desired_node then
					minetest.set_node({x=pos.x,y=pos.y+y,z=pos.z+z}, {name=filler_node})
					portal.link_portal({x=pos.x,y=pos.y+y,z=pos.z+z},pos2)
				elseif node == desired_node then
					break
				end
				if z < sizezmin then
					sizezmin = z
				end
			end
			--go through +z to check if portals are able to be created
			for z = 1,max_portal_width do
				local node = minetest.get_node({x=pos.x,y=pos.y+y,z=pos.z+z}).name
				--add node if not at portal wall
				if node ~= desired_node then
					minetest.set_node({x=pos.x,y=pos.y+y,z=pos.z+z}, {name=filler_node})
					portal.link_portal({x=pos.x,y=pos.y+y,z=pos.z+z},pos2)
				elseif node == desired_node then
					break
				end
				if z > sizezmax then
					sizezmax = z
				end
			end
		end
	end
		
	portal.generate_second_portal(pos2,pos,desired_node,axis,filler_node,sizey,sizexmin,sizexmax,sizezmin,sizezmax,creator)
	
end

--the actual nether portal
portal.generate_second_portal = function(pos2,pos,desired_node,axis,filler_node,sizey,sizexmin,sizexmax,sizezmin,sizezmax,creator)
	
		local player = minetest.get_player_by_name(creator)
		
		local player_origin = player:getpos()
		
		if axis == "z" then
			player:setpos({x=pos2.x+1,y=pos2.y,z=pos2.z})
		elseif axis == "x" then
			player:setpos({x=pos2.x,y=pos2.y,z=pos2.z+1})
		end
		
		player:set_physics_override({
				gravity = 0,
				jump = 0,
				speed = 0,
			})
			
		minetest.after(5, function(pos2,pos,desired_node,axis,filler_node,sizey,sizexmin,sizexmax,sizezmin,sizezmax,creator)
			for y = -1,sizey do
			--generate top and bottom of portal
				if axis == "x" then
					
					--go through -x to check if portals are able to be created
					for x = sizexmin-1,sizexmax+1 do
					
						if y == -1 or y == sizey then
							minetest.set_node({x=pos2.x+x,y=pos2.y+y,z=pos2.z}, {name=desired_node})
						else
						
							if x == sizexmin-1 or x == sizexmax+1 then
								minetest.set_node({x=pos2.x+x,y=pos2.y+y,z=pos2.z}, {name=desired_node})
								print("side x")
							else				
								minetest.set_node({x=pos2.x+x,y=pos2.y+y,z=pos2.z}, {name=filler_node})
								portal.link_portal({x=pos2.x+x,y=pos2.y+y,z=pos2.z},pos)
							end
						end
					end
				end
				if axis == "z" then
					--go through -z to check if portals are able to be created
					for z = sizezmin-1,sizezmax+1 do
						if y == -1 or y == sizey+1 then
							minetest.set_node({x=pos2.x,y=pos2.y+y,z=pos2.z+z}, {name=desired_node})
						else
					
							if z == sizezmin-1 or z == sizezmax+1 then
								minetest.set_node({x=pos2.x,y=pos2.y+y,z=pos2.z+z}, {name=desired_node})
								print("side z")
							else
								minetest.set_node({x=pos2.x,y=pos2.y+y,z=pos2.z+z}, {name=filler_node})
								portal.link_portal({x=pos2.x,y=pos2.y+y,z=pos2.z+z},pos)
							end
						end
					end
				end
			end
		end,pos2,pos,desired_node,axis,filler_node,sizey,sizexmin,sizexmax,sizezmin,sizezmax,creator)
		
		minetest.after(7,function(player,player_origin)
			player:setpos(player_origin)
			player:set_physics_override({
					gravity = 1,
					jump = 1,
					speed = 1,
				})
		end,player,player_origin)

end


portal.register_filler = function(name,description,texture,particle_texture,post_effect_color)
	minetest.register_node(name, {
		description =  description,
		drawtype = "glasslike",
		tiles = {
			texture,
			texture,
			texture,
			texture,
			--{
			--	name = "nether_portal.png",
			--	animation = {
			--		type = "vertical_frames",
			--		aspect_w = 16,
			--		aspect_h = 16,
			--		length = 0.5,
			--	},
			--},
			--{
			--	name = "nether_portal.png",
			--	animation = {
			--		type = "vertical_frames",
			--		aspect_w = 16,
			--		aspect_h = 16,
			--		length = 0.5,
			--	},
			--},
		},
		paramtype = "light",
		sunlight_propagates = true,
		use_texture_alpha = true,
		walkable = false,
		diggable = false,
		pointable = false,
		buildable_to = false,
		is_ground_content = false,
		drop = "",
		light_source = 13,
		post_effect_color = post_effect_color,--{a = 180, r = 128, g = 0, b = 128},
		alpha = 192,
		
		--groups = {not_in_creative_inventory = 1}
		
		--do on remove remove portal around it
	})
	minetest.register_abm({
		nodenames = {name},
		interval = 1,
		chance = 1,
		action = function(pos, node)
			minetest.add_particlespawner({
				amount = 30,
				time = 1,
				minpos = {x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5},
				maxpos = {x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5},
				minvel = {x = -0.8, y = -0.8, z = -0.8},
				maxvel = {x = 0.8, y = 0.8, z = 0.8},
				minacc = {x=0, y=0, z=0},
				maxacc = {x=0, y=0, z=0},
				minexptime = 0.5,
				maxexptime = 1,
				minsize = 1,
				maxsize = 1,
				collisiondetection = false,
				vertical = false,
				texture = particle_texture,
			})
		end,
	})
end

minetest.register_chatcommand("portal", {
	params = "<text>",
	description = "Send text to chat",
	privs = {},
	func = function( name , _)
		local pos2 = minetest.get_player_by_name(name):getpos()
		local sizey = 2
		local axis = "x"
		local sizexmin = -1
		local sizexmax = 0
		
		local desired_node = "default:obsidian"
		
		local filler_node = "default:mese"
		
		
		for y = -1,sizey do
			--generate top and bottom of portal
			if axis == "x" then
				
				--go through -x to check if portals are able to be created
				for x = sizexmin-1,sizexmax+1 do
				
					if y == -1 or y == sizey then
						minetest.set_node({x=pos2.x+x,y=pos2.y+y,z=pos2.z}, {name=desired_node})
					else
					
						if x == sizexmin-1 or x == sizexmax+1 then
							minetest.set_node({x=pos2.x+x,y=pos2.y+y,z=pos2.z}, {name=desired_node})
							print("side x")
						else				
							minetest.set_node({x=pos2.x+x,y=pos2.y+y,z=pos2.z}, {name=filler_node})
							--portal.link_portal({x=pos2.x+x,y=pos2.y+y,z=pos2.z},pos)
						end
					end
				end
			end
			if axis == "z" then
				--go through -z to check if portals are able to be created
				for z = sizezmin-1,sizezmax+1 do
					if y == -1 or y == sizey+1 then
						minetest.set_node({x=pos2.x,y=pos2.y+y,z=pos2.z+z}, {name=desired_node})
					else
				
						if z == sizezmin-1 or z == sizezmax+1 then
							minetest.set_node({x=pos2.x,y=pos2.y+y,z=pos2.z+z}, {name=desired_node})
							print("side z")
						else
							minetest.set_node({x=pos2.x,y=pos2.y+y,z=pos2.z+z}, {name=filler_node})
							--portal.link_portal({x=pos2.x,y=pos2.y+y,z=pos2.z+z},pos)
						end
					end
				end
			end
		end
	end,
})



