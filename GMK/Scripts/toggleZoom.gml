with(argument0) {
    zoomed = !zoomed;
    if(zoomed) {
        runPower = 0.6;
        jumpStrength = 6;
        // play zoomed in sound
        if (argument0 == global.myself.object) FMODSoundPlay(global.SniperZoomInSnd);
    } else {
        runPower = 0.9;
        jumpStrength = 8;
        // play zoomed out sound
        if (argument0 == global.myself.object) FMODSoundPlay(global.SniperZoomOutSnd);
    }
}
