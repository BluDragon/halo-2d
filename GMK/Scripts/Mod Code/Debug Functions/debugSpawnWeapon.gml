{
    // spawn an assault rifle with full ammo at the host's feet
    if (global.isHost && player == global.myself) {       
        var wt;
        wt = WEAPON_SPARTANLASER;
        sendEventWeaponSpawn(wt, global.weaponMaxAmmo[wt] + global.weaponMaxReserve[wt], 900, x, y, 0, 0);
        doEventWeaponSpawn(wt, global.weaponMaxAmmo[wt] + global.weaponMaxReserve[wt], 900, x, y, 0, 0);
    }
}
