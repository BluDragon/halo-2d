/*
{
    sound_volume(argument2, calculateVolume(argument0, argument1));
    sound_pan(argument2, calculatePan(argument0));
    
    sound_loop(argument2);
}
*/
// Modified for FMOD

// Now returns the instance ID of the playing sound,
// in case it needs to have its volume changed later, etc
{
    var sid, vol;
    
    sid = FMODSoundLoop(argument2, true);
    FMODInstanceSetVolume(sid, calculateVolume(argument0, argument1));
    FMODInstanceSetPan(sid, calculatePan(argument0));
    //FMODInstanceSetLoopCount(sid, -1);
    FMODInstanceSetPaused(sid, false);
    
    return sid;
}
