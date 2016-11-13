--an api to create portals in the world
portal = {}

local max_portal_height = 30
local max_portal_radius = 15

portal.register_portal = function(activator,desired_node,filler)
	minetest.override_item(activator, {
		on_place = function(itemstack, placer, pointed_thing)
			local node = minetest.get_node(pointed_thing.under).name
			portal.check_area(pointed_thing.under, desired_node,filler)
		end,
	})
end

--a test
portal.register_portal("default:stick","default:mese","default:glass")

portal.check_area = function(pos,desired_node,filler_node)
	local x_check = false
	local z_check = false
	if minetest.get_node({x=pos.x-1,y=pos.y,z=pos.z}).name == desired_node and minetest.get_node({x=pos.x+1,y=pos.y,z=pos.z}).name == desired_node then
	   x_check = true
	end
	if minetest.get_node({x=pos.x,y=pos.y,z=pos.z-1}).name == desired_node and minetest.get_node({x=pos.x,y=pos.y,z=pos.z+1}).name == desired_node then
	   z_check = true
	end
	--allow both for x shaped portals
	if x_check == true then
		portal.check_portal(pos,desired_node,"x",filler_node)
	elseif z_check == true then
		portal.check_portal(pos,desired_node,"z",filler_node)
	end

end

portal.check_portal = function(pos,desired_node,axis,filler_node)
	local fail = false
	--go through the height of the portal
	for y = 1,max_portal_height do
		--check the cap of the portal
		local node = minetest.get_node({x=pos.x,y=pos.y+y,z=pos.z}).name
		if node == desired_node then
			print("got the height cap!")
			break
		elseif y == max_portal_height and node ~= desired_node then
			fail = true
			print("portal is too tall!")
			return
		else
			if node ~= "air" then
				fail = true
				print("failure in the height check")
				return
			end
		end
		
		
		if axis == "x" then
			--go through -x to check if portals are able to be created
			for x = -1,-max_portal_radius,-1 do
				local node = minetest.get_node({x=pos.x+x,y=pos.y+y,z=pos.z}).name
				--if there are any nodes not desired in the portal, don't create
				if node == desired_node then
					print("got - x cap!")
					break
				elseif x == -max_portal_radius and node ~= desired_node then
					fail = true
					print("portal is too wide -x!")
					return
				else
					if node ~= "air" then
						fail = true
						print("failure in the - x axis check")
						return
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
					fail = true
					print("portal is too wide +x!")
					return
				else
					if node ~= "air" then
						fail = true
						print("failure in the + x axis check")
						return
					end
				end
			end
		end
		if axis == "z" then
			--go through -z to check if portals are able to be created
			for z = -1,-max_portal_radius,-1 do
				local node = minetest.get_node({x=pos.x,y=pos.y+y,z=pos.z+z}).name
				--if there are any nodes not desired in the portal, don't create
				if node == desired_node then
					print("got - z cap!")
					break
				elseif z == -max_portal_radius and node ~= desired_node then
					fail = true
					print("portal is too wide -z!")
					return
				else
					if node ~= "air" then
						fail = true
						print("failure in the - z axis check")
						return
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
					fail = true
					print("portal is too wide +z!")
					return
				else
					if node ~= "air" then
						fail = true
						print("failure in the + z axis check")
						return
					end
				end
			end
		end
	end
	--if it found a portal that works, create the filler
	if fail == false then
		portal.create_portal(pos,desired_node,axis,filler_node)
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

