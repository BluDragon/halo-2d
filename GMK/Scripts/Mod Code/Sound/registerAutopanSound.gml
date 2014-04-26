/* Registers a playing sound instance to have its volume and pan automatically updated
** each step based on the camera's position.
** 
** argument0 = sound's instance ID
** argument1 = x position of the sound's source
** argument2 = y position of the sound's source
*/

{
    // add the relevant items to the DLL controller object
    with (DLLController) {
        ds_list_add(autopanSoundsID, argument0);
        ds_list_add(autopanSoundsX, argument1);
        ds_list_add(autopanSoundsY, argument2);
    }
}
