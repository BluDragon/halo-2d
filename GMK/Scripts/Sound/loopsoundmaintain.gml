// argument0 = new x position of sound
// argument1 = new y position of sound
// argument2 = the INSTANCE ID of the sound
{
    if (argument2 == 0) exit;
    FMODInstanceSetVolume(argument2, calculateVolume(argument0, argument1));
    FMODInstanceSetPan(argument2, calculatePan(argument0));
}
