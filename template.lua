-- Template for RosaServer
local mode = ...
mode.name = "Mode name goes here"
mode.author = "Author Name"
-- THIS IS A ROSASERVER TEMPLATE BY DINGUS

-- You are free to modify and use this script in anyway you please
-- I know there is probably a much better way to do all of this, but if you know that then why are you using this script 
-- if you are using this script I assume you have knowlege of how LUA works and you are experienced with linux, you must setup rosaserver correctly for this to work.
-- feel free to ask me questions on discord: Dingus#1753


-- https://github.com/RosaServer/RosaServerCore/blob/master/.meta/template/types.lua


-- this script will spawn people in on 3 points in the map depending on what team they pick



-- the coords I will use to spawn people in on each team
local spawngold = Vector(1550, 30, 1214)
local spawnmons = Vector(1560, 30, 1214)
local spawnoxs = Vector(1570, 30, 1214)




function mode.onEnable(isReload) -- this code block is executed when the server goes up
	tick = 0 -- these are used later
	second = 0
	minute = 0
	server.type = TYPE_ROUND -- this is where you choose what logic to overwrite!
end




function mode.hooks.ResetGame(reason) -- this code block is called when /resetgame or /resetlua is called
	tick = 0
	second = 0
	minute = 0
	server.state = 2
	server.time = 14500 
	math.randomseed(os.time())
end 



function mode.hooks.Logic() -- This code block is called 60 times a second, most of your coding will be done here

    server.time = server.time - 1 -- this will cause the timer to tick down once a second, time is not calculated here in seconds but in TICKS PER SECOND. IE, ((Minutes * 60) * 60) WOO MATH!!!
	
    
    server.roundTeamDamage = 100 -- how much damage is recieved when commiting acts of RDM (team damage)

    tick = tick + 1 -- this causes the variable tick to go up by 1 every tick

    -- this is a simple thing to replace the code required to have a scoreboard, readying up, and round ending stuff etc etc. 
    
    
    
    if tick == 60 then -- overwriting the tick stuff in the game, basically dont touch this. 
        tick = 0
        second = second + 1
        if second == 60 then
            second = 0
            minute = minute + 1
        end
    end


    ---------------------------------------------
    
    if server.time == 0 then 
		if server.state == 1 then -- when the game begins, IE, when people spawn in. 
			server.state = 2
			server.time = 25155 -- refer to the comment above about time ((Minutes * 60) * 60)
			server.sunTime = (12 * 60 * 60 * 62.5)  -- integer Time of day in ticks, where noon is 2592000 (12*60*60*TPS)
		elseif server.state == 2 then
			if not gameEnding then -- When the round ends (when the timer is counting down to going back to the scoreboard)
				gameEnding = true
				events.createMessage(0, "Round over!", -1, 2)
				server.time = 600
			else
                gameEnding = false -- back to scoreboard
				server:reset()
				server.time = 3600
			end
		end
    end

---------------------------------------------
    local readyCount = 0 -- The code below this is for getting the ready count and starting the game if HALF the people are ready
    
    
    for _, ply in ipairs(players.getAll()) do -- for every player do THIS 
        ply.teamSwitchTimer = 0 -- allows people to switch teams
        
        if ply.isReady then -- if player is ready add one to player count 
			readyCount = readyCount + 1
		end
    end

    if readyCount >= players.getCount() * 0.5 and not gameStarting then -- if half the players are ready, start the game 
		gameStarting = true
		for _, ply in ipairs(players.getAll()) do -- for all players 
			ply:sendMessage("Game is now starting!") -- send a red message to all players
		end
		if server.time > 300 then
			server.time = 300
		end
	end



---------------------------------------------- -- this code spawns people in! 
    for _, ply in ipairs(players.getAll()) do -- for all players do 
        if ply.human == nil and server.state == 2 then -- if a PLAYER doesnt have a HUMAN and the server state is 2 (In play)
            if ply.team == 0 then -- if player is on gold then 
                local man = humans.create(spawngold, orientations.w, ply) -- make a human at spawngold, facing west, attach it to that player
                local wID = math.random(6) * 2 - 1 -- generate a random weapon 
                man.suitColor = 1 -- Clothes color
                man:arm(wID, 6) -- arm them with that weapon and 6 mags 
            elseif ply.team == 1 then -- if player is on mons
                local man = humans.create(spawnmons, orientations.w, ply)
                local wID = math.random(6) * 2 - 1
                man.suitColor = 2
                man:arm(wID, 6)
            elseif ply.team == 2 then  -- if player is on OXS
                local man = humans.create(spawnoxs, orientations.w, ply)
                local wID = math.random(6) * 2 - 1
                man.suitColor = 3
                man:arm(wID, 6)
            else end -- else end (spectator)
        end
    end
--------------------------------------------------





    for _, man in ipairs(humans.getAll()) do -- for all humans
        

        if man.player == nil then -- if a human doesnt have a player attached to it (IE, its a dead body)
            man:remove() -- remove it (removes dead bodies)
        end

    end 

    for _, itm in ipairs(items.getAll()) do -- for all items 
        if itm.physicsSettled then -- if an item is not moving and on the ground 
            itm:remove() -- remove it, (removes dropped items and stuff)
        end
    end 













end -- end of logic hook 







function mode.hooks.LogicRound() -- this actually overwrites the games gamemode code with the one you wrote is mode.hooks.logic
    return hook.override
end