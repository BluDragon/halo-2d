/* Performs a weapon pickup ammo event
**
** argument0 = The player who's picking up a powerup (by instance ID)
** argument1 = The array index of the weapon that's receiving the ammo (0 - 1 for normals, 2 for dual-wielded)
** argument2 = The weapon powerup that ammo's being picked up from (by instance ID)
** argument3 = The amount of ammo that's being picked up
**
*/

{
    // grenade special-case check
    if ((argument2.weaponType >= WEAPON_FRAGGRENADE) && (argument2.weaponType <= WEAPON_FIREBOMB)) {
        var gType;
        
        // it's a grenade powerup
        // increase the player's appropriate grenade stock
        gType = argument2.weaponType - WEAPON_FRAGGRENADE;
        argument0.object.grenadeAmmo[gType] += argument3;
        
        // play the appropriate pickup sound if it's the player's character
        if (myCharExists()) {
            if (argument0 == global.myself) {
                switch (argument2.weaponType) {
                    case WEAPON_FRAGGRENADE:
                    case WEAPON_SPIKEGRENADE:
                        FMODSoundPlay(global.FragGrenadeAmmoSnd);
                        break;
                    
                    case WEAPON_PLASMAGRENADE:
                    case WEAPON_FIREBOMB:
                        FMODSoundPlay(global.PlasmaGrenadeAmmoSnd);
                        break;
                }
            }
        }
        
    } else {
        // it's a regular weapon powerup
        var weap, reloadAmt;
        
        // get the weapon instance
        weap = argument0.object.weapons[argument1];
        
        // add the ammo
        weap.reserveAmmo += argument3;
        
        // if the character belongs to the player, perform the necessary UI effects
        if (myCharExists()) {
            if (argument0 == global.myself) {
                // play the pickup sound
                FMODSoundPlay(weap.ammoPickupSound);
                // set the appropriate values and timers for the ammo pickup animation
                if (argument1 == 2) {
                    VisorHud.ammoPickupLeftTimer = 30;
                    VisorHud.ammoPickupLeftValue = argument3;
                } else if (argument1 == argument0.object.currentWeapon) {
                    VisorHud.ammoPickupRightTimer = 30;
                    VisorHud.ammoPickupRightValue = argument3;
                }
            }
        }
    }
    
    // decrement the ammo from the drop
    argument2.ammo -= argument3;
    
    // despawn the weapon drop if all ammo has been depleted from the drop, AND we're the host
    if (argument2.ammo <= 0) && (global.isHost) {
        sendEventWeaponDespawn(argument2);
        doEventWeaponDespawn(argument2);
    }
}
