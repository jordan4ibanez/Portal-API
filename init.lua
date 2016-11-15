--an api to create portals in the world
portal = {}

local max_portal_height = 30
local max_portal_radius = 15

portal.register_portal = function(activator,desired_node,filler_node)
	minetest.register_abm({
		nodenames = {desired_node},
		neighbors = {activator},
		interval = 1,
		chance = 1,
		action = function(pos, node)
			pos.y = pos.y + 1
			if minetest.get_node(pos).name == activator then
				minetest.remove_node(pos)
				pos.y = pos.y - 1
				portal.check_portal(pos,desired_node,"z",filler_node)
			end
		end,
	})
end


portal.check_portal = function(pos,desired_node,axis,filler_node)
	local xfail = false
	local yfail = false
	local zfail = false
	--go through the height of the portal
	for y = 1,max_portal_height do
		--check the cap of the portal
		local node = minetest.get_node({x=pos.x,y=pos.y+y,z=pos.z}).name
		if node == desired_node then
			print("got the height cap!")
			break
		elseif y == max_portal_height and node ~= desired_node then
			print("portal is too tall!")
			yfail = true
			break
		else
			if node ~= "air" then
				fail = true
				print("failure in the height check")
				yfail = true
				break
			end
		end
		
		
		if xfail == false then
			--go through -x to check if portals are able to be created
			for x = -1,-max_portal_radius,-1 do
				local node = minetest.get_node({x=pos.x+x,y=pos.y+y,z=pos.z}).name
				--if there are any nodes not desired in the portal, don't create
				if node == desired_node then
					print("got - x cap!")
					break
				elseif x == -max_portal_radius and node ~= desired_node then
					print("portal is too wide -x!")
					xfail = true
					break
				else
					if node ~= "air" then
						print("failure in the - x axis check")
						xfail = true
						break
					end
				end
			end
			--go through +x to check if portals are able to be created
			for x = 1,max_portal_radius do
				local node = minetest.get_node({x=pos.x+x,y=pos.y+y,z=pos.z}).name
				--if there are any nodes not desired in the portal, don't create
				if node == desired_node then
					print("got + x cap!")
					break
				elseif x == max_portal_radius and node ~= desired_node then
					print("portal is too wide +x!")
					xfail = true
					break
				else
					if node ~= "air" then
						print("failure in the + x axis check")
						xfail = true
						break
					end
				end
			end
		end
		if zfail == false then
			--go through -z to check if portals are able to be created
			for z = -1,-max_portal_radius,-1 do
				local node = minetest.get_node({x=pos.x,y=pos.y+y,z=pos.z+z}).name
				--if there are any nodes not desired in the portal, don't create
				if node == desired_node then
					print("got - z cap!")
					break
				elseif z == -max_portal_radius and node ~= desired_node then
					print("portal is too wide -z!")
					zfail = true
					break
				else
					if node ~= "air" then
						print("failure in the - z axis check")
						zfail = true
						break
					end
				end
			end
			--go through +z to check if portals are able to be created
			for z = 1,max_portal_radius do
				local node = minetest.get_node({x=pos.x,y=pos.y+y,z=pos.z+z}).name
				--if there are any nodes not desired in the portal, don't create
				if node == desired_node then
					print("got + z cap!")
					break
				elseif z == max_portal_radius and node ~= desired_node then
					print("portal is too wide +z!")
					zfail = true
					break
				else
					if node ~= "air" then
						print("failure in the + z axis check")
						zfail = true
						break
					end
				end
			end
		end
	end
	--if it found a portal that works, create the filler
	if yfail == false then
		if xfail == false then
			portal.create_portal(pos,desired_node,"x",filler_node)
		end
		if zfail == false then
			portal.create_portal(pos,desired_node,"z",filler_node)
		end
	end
end


portal.create_portal = function(pos,desired_node,axis,filler_node)
	--this function assumes portal check is correct and the game didn't add any nodes into space
	--in half step somehow, it'll remove them anyways
	for y = 1,max_portal_height do
		--if the cap node is found, end function loop
		local node = minetest.get_node({x=pos.x,y=pos.y+y,z=pos.z}).name
		if node ~= desired_node then
			minetest.set_node({x=pos.x,y=pos.y+y,z=pos.z}, {name=filler_node})
		elseif node == desired_node then
			print("portal completed!")
			break
		end
		if axis == "x" then
			--go through -x to check if portals are able to be created
			for x = -1,-max_portal_radius,-1 do
				local node = minetest.get_node({x=pos.x+x,y=pos.y+y,z=pos.z}).name
				--add node if not at portal wall
				if node ~= desired_node then
					minetest.set_node({x=pos.x+x,y=pos.y+y,z=pos.z}, {name=filler_node})
				elseif node == desired_node then
					break
				end
			end
			--go through +x to check if portals are able to be created
			for x = 1,max_portal_radius do
				local node = minetest.get_node({x=pos.x+x,y=pos.y+y,z=pos.z}).name
				--add node if not at portal wall
				if node ~= desired_node then
					minetest.set_node({x=pos.x+x,y=pos.y+y,z=pos.z}, {name=filler_node})
				elseif node == desired_node then
					break
				end
			end
		end
		if axis == "z" then
			--go through -z to check if portals are able to be created
			for z = -1,-max_portal_radius,-1 do
				local node = minetest.get_node({x=pos.x,y=pos.y+y,z=pos.z+z}).name
				--add node if not at portal wall
				if node ~= desired_node then
					minetest.set_node({x=pos.x,y=pos.y+y,z=pos.z+z}, {name=filler_node})
				elseif node == desired_node then
					break
				end
			end
			--go through +z to check if portals are able to be created
			for z = 1,max_portal_radius do
				local node = minetest.get_node({x=pos.x,y=pos.y+y,z=pos.z+z}).name
				--add node if not at portal wall
				if node ~= desired_node then
					minetest.set_node({x=pos.x,y=pos.y+y,z=pos.z+z}, {name=filler_node})
				elseif node == desired_node then
					break
				end
			end
		end
	end
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
		--diggable = false,
		--pointable = false,
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

