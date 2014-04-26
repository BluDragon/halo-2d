if winners == TEAM_RED {
    redWins += 1;
}
else {
    blueWins += 1;
}
redteam = ds_priority_create();
blueteam = ds_priority_create();  

for(i=0; i<ds_list_size(global.players); i+=1) {
    player = ds_list_find_value(global.players, i);
    if(player.team == TEAM_RED) {
        ds_priority_add(redteam, player, player.roundStats[POINTS]);
    } else if (player.team == TEAM_BLUE) {
        ds_priority_add(blueteam, player, player.roundStats[POINTS]);
    }
}

while ds_priority_size(redteam) > 3{
    ds_priority_delete_min(redteam);
}

while ds_priority_size(blueteam) > 3{
    ds_priority_delete_min(blueteam);
}

redMVPs = ds_priority_size(redteam);
blueMVPs = ds_priority_size(blueteam);

write_ubyte(global.sendBuffer, ARENA_ENDROUND);

write_ubyte(global.sendBuffer, winners);
write_ubyte(global.sendBuffer, redMVPs);
write_ubyte(global.sendBuffer, blueMVPs);
write_ubyte(global.sendBuffer, redWins);
write_ubyte(global.sendBuffer, blueWins);

for(i=0; i < redMVPs; i+=1) {
    redMVP[i] = ds_priority_delete_max(redteam);
    redMVPIndex[i] = ds_list_find_index(global.players,redMVP[i]);
    redMVP[i].roundStats[HEALING] = round(redMVP[i].roundStats[HEALING]);
    write_ubyte(global.sendBuffer, redMVPIndex[i]);
    write_ubyte(global.sendBuffer, redMVP[i].roundStats[KILLS]);
    write_ushort(global.sendBuffer, redMVP[i].roundStats[HEALING]);
    write_ubyte(global.sendBuffer, redMVP[i].roundStats[POINTS]);
}

for(i=0; i < blueMVPs; i+=1) {
    blueMVP[i] = ds_priority_delete_max(blueteam);
    blueMVPIndex[i] = ds_list_find_index(global.players,blueMVP[i]);
    blueMVP[i].roundStats[HEALING] = round(blueMVP[i].roundStats[HEALING]);
    write_ubyte(global.sendBuffer, blueMVPIndex[i]);
    write_ubyte(global.sendBuffer, blueMVP[i].roundStats[KILLS]);
    write_ushort(global.sendBuffer, blueMVP[i].roundStats[HEALING]);
    write_ubyte(global.sendBuffer, blueMVP[i].roundStats[POINTS]);
}

with Sentry if team != ArenaHUD.winners event_user(1);

ds_priority_destroy(redteam);
ds_priority_destroy(blueteam);

doEventArenaEndRound();
