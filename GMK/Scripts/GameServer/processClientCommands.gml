var player, playerId, commandLimitRemaining;

player = argument0;
playerId = argument1;

// To prevent players from flooding the server, limit the number of commands to process per step and player.
commandLimitRemaining = 10;

with(player) {
    if(!variable_local_exists("commandReceiveState")) {
        // 0: waiting for command byte.
        // 1: waiting for command data length (1 byte)
        // 2: waiting for command data.
        commandReceiveState = 0;
        commandReceiveExpectedBytes = 1;
        commandReceiveCommand = 0;
    }
}

while(commandLimitRemaining > 0) {
    var socket;
    socket = player.socket;
    if(!tcp_receive(socket, player.commandReceiveExpectedBytes)) {
        return 0;
    }
    
    switch(player.commandReceiveState)
    {
    case 0:
        player.commandReceiveCommand = read_ubyte(socket);
        switch(commandBytes[player.commandReceiveCommand]) {
        case commandBytesInvalidCommand:
            // Invalid byte received. Wait for another command byte.
            break;
            
        case commandBytesPrefixLength1:
            player.commandReceiveState = 1;
            player.commandReceiveExpectedBytes = 1;
            break;

        case commandBytesPrefixLength2:
            player.commandReceiveState = 3;
            player.commandReceiveExpectedBytes = 2;
            break;

        default:
            player.commandReceiveState = 2;
            player.commandReceiveExpectedBytes = commandBytes[player.commandReceiveCommand];
            break;
        }
        break;
        
    case 1:
        player.commandReceiveState = 2;
        player.commandReceiveExpectedBytes = read_ubyte(socket);
        break;

    case 3:
        player.commandReceiveState = 2;
        player.commandReceiveExpectedBytes = read_ushort(socket);
        break;
        
    case 2:
        player.commandReceiveState = 0;
        player.commandReceiveExpectedBytes = 1;
        commandLimitRemaining -= 1;
        
        switch(player.commandReceiveCommand)
        {
        case PLAYER_LEAVE:
            socket_destroy(player.socket);
            player.socket = -1;
            break;
            
        case PLAYER_CHANGECLASS:
            var class;
            class = read_ubyte(socket);
            if(getCharacterObject(player.team, class) != -1)
            {
                if(player.object != -1)
                {
                    with(player.object)
                    {
                        if (collision_point(x,y,SpawnRoom,0,0) < 0)
                        {
                            if (lastDamageDealer == -1 || lastDamageDealer == player)
                            {
                                sendEventPlayerDeath(player, player, noone, BID_FAREWELL);
                                doEventPlayerDeath(player, player, noone, BID_FAREWELL);
                            }
                            else
                            {
                                var assistant;
                                assistant = secondToLastDamageDealer;
                                if (lastDamageDealer.object != -1)
                                    if (lastDamageDealer.object.healer != -1)
                                        assistant = lastDamageDealer.object.healer;
                                sendEventPlayerDeath(player, lastDamageDealer, assistant, FINISHED_OFF);
                                doEventPlayerDeath(player, lastDamageDealer, assistant, FINISHED_OFF);
                            }
                        }
                        else 
                        instance_destroy(); 
                        
                    }
                }
                else if(player.alarm[5]<=0)
                    player.alarm[5] = 1;
                player.class = class;
                ServerPlayerChangeclass(playerId, player.class, global.sendBuffer);
            }
            break;
            
        case PLAYER_CHANGETEAM:
            var newTeam, balance, redSuperiority;
            newTeam = read_ubyte(socket);
            
            redSuperiority = 0   //calculate which team is bigger
            with(Player)
            {
                if(team == TEAM_RED)
                    redSuperiority += 1;
                else if(team == TEAM_BLUE)
                    redSuperiority -= 1;
            }
            if(redSuperiority > 0)
                balance = TEAM_RED;
            else if(redSuperiority < 0)
                balance = TEAM_BLUE;
            else
                balance = -1;
            
            if(balance != newTeam)
            {
                if(getCharacterObject(newTeam, player.class) != -1 or newTeam==TEAM_SPECTATOR)
                {  
                    if(player.object != -1)
                    {
                        with(player.object)
                        {
                            if (lastDamageDealer == -1 || lastDamageDealer == player)
                            {
                                sendEventPlayerDeath(player, player, noone, BID_FAREWELL);
                                doEventPlayerDeath(player, player, noone, BID_FAREWELL);
                            }
                            else
                            {
                                var assistant;
                                assistant = secondToLastDamageDealer;
                                if (lastDamageDealer.object != -1)
                                    if (lastDamageDealer.object.healer != -1)
                                        assistant = lastDamageDealer.object.healer;
                                sendEventPlayerDeath(player, lastDamageDealer, assistant, FINISHED_OFF);
                                doEventPlayerDeath(player, lastDamageDealer, assistant, FINISHED_OFF);
                            }
                        }
                        player.alarm[5] = global.Server_Respawntime;
                    }
                    else if(player.alarm[5]<=0)
                        player.alarm[5] = 1;                    

                    ServerPlayerChangeclass(playerId, player.class, global.sendBuffer);
                    player.team = newTeam;
                    ServerPlayerChangeteam(playerId, player.team, global.sendBuffer);
                    ServerBalanceTeams();
                }
            }
            break;                   
            
        case CHAT_BUBBLE:
            var bubbleImage;
            bubbleImage = read_ubyte(socket);
            if(global.aFirst) {
                bubbleImage = 0;
            }
            write_ubyte(global.sendBuffer, CHAT_BUBBLE);
            write_ubyte(global.sendBuffer, playerId);
            write_ubyte(global.sendBuffer, bubbleImage);
            
            setChatBubble(player, bubbleImage);
            break;
            
        case BUILD_SENTRY:
            if(player.object != -1)
            {
                if(player.class == CLASS_ENGINEER
                        and collision_circle(player.object.x, player.object.y, 50, Sentry, false, true) < 0
                        and player.object.nutsNBolts == 100
                        and (collision_point(player.object.x,player.object.y,SpawnRoom,0,0) < 0)
                        and !player.sentry
                        and !player.object.onCabinet)
                {
                    write_ubyte(global.sendBuffer, BUILD_SENTRY);
                    write_ubyte(global.sendBuffer, playerId);
                    write_ushort(global.serializeBuffer, round(player.object.x*5));
                    write_ushort(global.serializeBuffer, round(player.object.y*5));
                    write_byte(global.serializeBuffer, player.object.image_xscale);
                    buildSentry(player, player.object.x, player.object.y, player.object.image_xscale);
                }
            }
            break;                                       

        case DESTROY_SENTRY:
            with(player.sentry)
                instance_destroy();
            break;                     
        
        case DROP_INTEL:                                                                  
            if(player.object != -1) {
                write_ubyte(global.sendBuffer, DROP_INTEL);
                write_ubyte(global.sendBuffer, playerId);
                with player.object event_user(5);  
            }
            break;     
              
        case OMNOMNOMNOM:
            if(player.object != -1) {
                if(!player.humiliated
                    and !player.object.taunting
                    and !player.object.omnomnomnom
                    and player.object.canEat
                    and player.class==CLASS_HEAVY)
                {                            
                    write_ubyte(global.sendBuffer, OMNOMNOMNOM);
                    write_ubyte(global.sendBuffer, playerId);
                    if (player == global.myself) playsound(player.object.x, player.object.y, global.HeavyHealSnd);
                    with(player.object)
                    {
                        omnomnomnom = true;
                        if(hp < maxHp)
                        {
                            canEat = false;
                            alarm[6] = eatCooldown; //10 second cooldown
                        }
                        if player.team == TEAM_RED {
                            omnomnomnomindex=0;
                            omnomnomnomend=31;
                        } else if player.team==TEAM_BLUE {
                            omnomnomnomindex=32;
                            omnomnomnomend=63;
                        } 
                        xscale=image_xscale;
                    }             
                }
            }
            break;
             
        case TOGGLE_ZOOM:
            if player.object != -1 {
                if player.class == CLASS_SNIPER {
                    write_ubyte(global.sendBuffer, TOGGLE_ZOOM);
                    write_ubyte(global.sendBuffer, playerId);
                    toggleZoom(player.object);
                }
            }
            break;
            
        case PLAYER_CHANGENAME:
            var nameLength;
            nameLength = socket_receivebuffer_size(socket);
            if(nameLength > MAX_PLAYERNAME_LENGTH)
            {
                write_ubyte(player.socket, KICK);
                write_ubyte(player.socket, KICK_NAME);
                socket_destroy(player.socket);
                player.socket = -1;
            }
            else
            {
                with(player)
                {
                    if(variable_local_exists("lastNamechange")) 
                        if(current_time - lastNamechange < 1000)
                            break;
                    lastNamechange = current_time;
                    name = read_string(socket, nameLength);
                    if(string_count("#",name) > 0)
                    {
                        name = "I <3 Bacon";
                    }
                    write_ubyte(global.sendBuffer, PLAYER_CHANGENAME);
                    write_ubyte(global.sendBuffer, playerId);
                    write_ubyte(global.sendBuffer, string_length(name));
                    write_string(global.sendBuffer, name);
                }
            }
            break;
            
        case INPUTSTATE:
            if(player.object != -1)
            {
                with(player.object)
                {
                    keyState = read_ushort(socket);
                    netAimDirection = read_ushort(socket);
                    netAimDistance = read_ushort(socket);
                    aimDirection = netAimDirection*360/65536;
                    aimDistance = netAimDistance / 10;
                    event_user(1);
                }
            }
            break;
        
        case REWARD_REQUEST:
            player.rewardId = read_string(socket, socket_receivebuffer_size(socket));
            player.challenge = rewardCreateChallenge();
            
            write_ubyte(socket, REWARD_CHALLENGE_CODE);
            write_binstring(socket, player.challenge);
            break;
            
        case REWARD_CHALLENGE_RESPONSE:
            var answer, i, authbuffer;
            answer = read_binstring(socket, 16);
            
            with(player)
                if(variable_local_exists("challenge") and variable_local_exists("rewardId"))
                    rewardAuthStart(player, answer, challenge, true, rewardId);
           
            break;
        
        case CHAT_MESSAGE:
            var msgLength, msgScope, chatMsg;
            msgLength = socket_receivebuffer_size(socket) - 1;
            if (msgLength > MAX_CHAT_SIZE) {
                // kick the player if the message length exceeds the max
                write_ubyte(player.socket, KICK);
                write_ubyte(player.socket, KICK_NAME);
                socket_destroy(player.socket);
                player.socket = -1;
            } else {
                // read the scope byte
                msgScope = read_ubyte(socket);
                // read the message
                chatMsg = read_string(socket, msgLength);
                // if there's unwanted characters in it, change it and let everyone know you're a butt
                if (string_count("#", chatMsg) > 0) {
                    msgScope = CHAT_SCOPE_GLOBAL;
                    chatMsg = "Who wants to touch my nubbin?";
                }
                
                // Add the message to our chat log, depending on scope/team the player is on
                addChatMessage(playerId, msgScope, chatMsg);
                
                // pass on the message to everyone else
                write_ubyte(global.sendBuffer, CHAT_MESSAGE);
                write_ubyte(global.sendBuffer, playerId);
                write_ubyte(global.sendBuffer, msgScope);
                write_ubyte(global.sendBuffer, string_length(chatMsg));
                write_string(global.sendBuffer, chatMsg);
            }
        }
        break;
    } 
}
