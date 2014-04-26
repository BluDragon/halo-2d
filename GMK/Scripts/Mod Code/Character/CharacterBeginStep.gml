// Character - Begin Step event
{    
    var i;
    
    // apply immolation effects
    if (firebombBurning) {
        var fireDamage;
        fireDamage = 1.5    // 45 DPS
        
        // finishing-off credit and whatnot copied from GG2's Afterburn
        if (hp > 0) {
            if ((lastDamageDealer != firebombedBy) && (lastDamageDealer != player)) {
                secondToLastDamageDealer = lastDamageDealer;
                alarm[4] = alarm[3];
            }
            alarm[3] = ASSIST_TIME;
            lastDamageDealer = firebombedBy;
            lastDamageSource = WEAPON_FIREBOMB;
        }
        
        // deal the damage, mostly copied from weaponDealDamage
        var damageBleed;
        
        // if shields take damage, do the flash
        if (shieldHp > 0) shieldFlash = 8;
        
        // calculate the damage bleed-through for shields and HP
        damageBleed = max(0, fireDamage - shieldHp);
        // damage the shields and HP
        shieldHp = max(0, shieldHp - fireDamage);
        hp -= damageBleed;
        timeUnscathed = 0;
        
        // force uncrouch if crouched
        if (crouched) {
            toggleCrouch(false);
        }
    }
    
    // decrement the crouching counter if it's above -1
    if (crouchFrame > -1) {
        crouchFrame -= 1;
    
        // if the animation expired, switch to the proper collision sprite and reset the animation image indexes
        if (crouchFrame == -1) {
            if (crouched) {
                // fully crouched
                sprite_index = ArmorCrouchColorS;
            } else {
                // fully not-crouched
                sprite_index = ArmorWalkColorS;
            }
            // reset the index
            animationImage = 0;
        }
    }
    
    // ***********************
    // **   Handle Input
    // ***********************
    
    // Weapon zoom key
    // Only matters if this is myself
    if (player == global.myself) {
        // check if the Zoom key was pressed
        if ((global.keyScope == MOUSE_LEFT) && mouse_check_button_pressed(mb_left)) ||
            ((global.keyScope == MOUSE_RIGHT) && mouse_check_button_pressed(mb_right)) ||
            ((global.keyScope == MOUSE_MIDDLE) && mouse_check_button_pressed(mb_middle)) ||
            keyboard_check_pressed(global.keyScope) {
            
            // the key was pressed, check if we can zoom
            // we can only zoom when ready to shoot and not tossing a grenade
            // and we can only zoom when the cursor is not a pointer
            if (weapons[currentWeapon].readyToShoot && weapons[currentWeapon].canZoom) && (Cursor.sprite_index != CrosshairS) &&
                (grenadeTossFrame == -1) {
                // we can toggle the zoom
                zoomed = !zoomed;
                // if we are now zoomed, we should center the view on where the cursor was
                if (zoomed) {
                    justZoomed = true;
                    // recored where the scoped area is relative to the player
                    scopeRelX = mouse_x - x;
                    scopeRelY = mouse_y - y;
                    // set the view to the cursor
                    view_xview[0] = mouse_x - view_wview[0] / 2;
                    view_yview[0] = mouse_y - view_hview[0] / 2;
                    // set the cursor to the center of the view
                    window_mouse_set(window_get_width() / 2, window_get_height() / 2);
                    // play the appropriate zoom-in sound for the weapon type
                    switch (weapons[currentWeapon].weaponType) {
                        case WEAPON_BATTLERIFLE:
                        case WEAPON_SNIPERRIFLE:
                            FMODSoundPlay(global.SniperZoomInSnd, false);
                            break;
                        case WEAPON_CARBINE:
                            FMODSoundPlay(global.CarbineZoomInSnd, false);
                            break;
                    }
                    
                } else {
                    // we unzoomed, so move the cursor to an appropriate position
                    undoZoomCursor();
                    // play the appropriate zoom-out sound for the weapon type
                    switch (weapons[currentWeapon].weaponType) {
                        case WEAPON_BATTLERIFLE:
                        case WEAPON_SNIPERRIFLE:
                            FMODSoundPlay(global.SniperZoomOutSnd, false);
                            break;
                        case WEAPON_CARBINE:
                            FMODSoundPlay(global.CarbineZoomOutSnd, false);
                            break;
                    }
                }
            }
        }
    }
    
    // Weapon switching key
    // switch to the other weapon if the weapon's ready to fire (or the reload, melee, etc effects are not active)
    // and not while throwing a grenade
    if ((pressedKeys & $0800) && weapons[currentWeapon].readyToShoot) && (grenadeTossFrame == -1) {
        if (dualWielding) {
            dualWielding = false;
            // and if we're the host, we send the command to drop the weapon
            if (global.isHost) {
                sendEventWeaponDualDrop(player);
                doEventWeaponDualDrop(player);
            }
        } else if (!dualJustDropped) {
            // otherwise we just switch weapons (if we also didn't drop this frame)
            // if the current weapon is a charging type, reset its charge status and silence any playing charge sound
            if (weapons[currentWeapon].chargesUp) {
                weapons[currentWeapon].chargeLevel = 0;
                if (FMODInstanceIsPlaying(weapons[currentWeapon].chargeSoundID)) FMODInstanceStop(weapons[currentWeapon].chargeSoundID);
            }
            
            // clear the zoomed status
            if (zoomed) {
                zoomed = false;
                undoZoomCursor();
            }
            
            // switch to the other weapon
            currentWeapon = (currentWeapon + 1) mod 2;
            // play the sound if this is the player's character and change the reticle
            // also perform the ammo warning check
            if (player == global.myself) {
                // play the sound, but only if it's not an out-of-ammo Energy Sword
                if !(weapons[currentWeapon].weaponType == WEAPON_ENERGYSWORD && weapons[currentWeapon].ammoCount <= 0) {
                    FMODSoundPlay(weapons[currentWeapon].equipSound);
                }
                Cursor.sprite_index = weapons[currentWeapon].reticleSprite;
                ammoWarningCheck(weapons[currentWeapon], false, true);     // reset the warning if the check is true
                // clear the ammo pickup number timer
                VisorHud.ammoPickupRightTimer = -1;
            }
            // set the equipment timer and don't allow use
            with (weapons[currentWeapon]) {
                alarm[2] = 15;
                readyToShoot = false;
            }
        }
    }
    
    // weapon reload key
    if (pressedKeys & $0400) && weapons[currentWeapon].readyToShoot && (grenadeTossFrame == -1) &&
        (weapons[currentWeapon].ammoCount < weapons[currentWeapon].maxAmmo) {
        // check to see if there's any reserve ammo left
        var reserveOk;
        
        reserveOk = false;
        // if the user is dual-wielding and the weapon types are the same, pool the reserve ammo
        // for the purposes of this check
        if (dualWielding) {
            if (weapons[currentWeapon].weaponType == weapons[2].weaponType) {
                if ((weapons[currentWeapon].reserveAmmo + weapons[2].reserveAmmo) > 0) reserveOk = true;
            } else {
                if (weapons[currentWeapon].reserveAmmo > 0) reserveOk = true;
            }
        } else {
            if (weapons[currentWeapon].reserveAmmo > 0) reserveOk = true;
        }

        // proceed with the reload if reserve supplies are ok
        if (reserveOk) {        
            // clear the zoomed status
            if (zoomed) {
                zoomed = false;
                undoZoomCursor();
            }
            
            // reload the weapon
            with (weapons[currentWeapon]) {
                // if we're dual-wielding, reload time is slightly longer
                alarm[4] = floor(reloadTime * Iif(other.dualWielding, global.dualWieldReloadFactor, 1));
                readyToShoot = false;
            }
            if (player == global.myself) weapons[currentWeapon].reloadSoundID = FMODSoundPlay(weapons[currentWeapon].reloadSound);
        }
    }
    
    // Weapon firing
    // This is handled by a for loop with an IF statement within it to determine
    // what weapon we are currently processing and the keycode we're doing comparisons to.
    // If we're not dual-wielding, we only do the first part of the 'loop'
    var loopMax;
    loopMax = 1;
    if (dualWielding) loopMax = 2;
    // enter the for loop
    for (i = 0; i < loopMax; i += 1) {
        var fWeap, keyCode, wCheckSide;
        // determine what weapon we're checking, and what key value
        if (i == 0) {
            // current weapon
            fWeap = weapons[currentWeapon];
            keyCode = $0010;    // Primary fire key (M1)
            wCheckSide = false;
        } else {
            // dual-wielded weapon
            fWeap = weapons[2];
            keyCode = $0008;    // Grenade Throw key (M2)
            wCheckSide = true;
        }
        
        // different logic for charging and non-charging weapons
        // weapons can only charge up if they are ready-to-fire and not overheated (if they can overheat)
        if (fWeap.chargesUp && fWeap.readyToShoot) && !(fWeap.overheats && fWeap.overheated) {
            // charging logic
            // if a grenade toss operation is not occuring...
            if (grenadeTossFrame == -1) {
                if (fWeap.chargeLevel == 0) {
                    // weapon's charge is currently 0
                    
                    // check to see if we should begin charging
                    if (((keyState & fWeap.fullAuto) | pressedKeys) & keyCode) && (fWeap.ammoCount > 0) {
                        // begin charging
                        fWeap.chargeLevel += 1;
                        fWeap.chargeSoundID = playsound(x, y, fWeap.chargingSound);
                    } else if (pressedKeys & keyCode) && (fWeap.ammoCount == 0) && (fWeap.reserveAmmo == 0) {
                        // the key to fire was pressed, BUT there's no ammo at all
                        if (player == global.myself) {
                            // play the no-ammo sound and display the no-ammo warning
                            FMODSoundPlay(global.NoAmmoClickSnd);
                            ammoWarningCheck(fWeap, wCheckSide, true);     // flash the ammo warning
                        }
                    }
                    
                } else if (fWeap.chargeLevel >= fWeap.maxCharge) {
                    // weapon's charge is >= max
                    
                    // if the weapon auto-fires on a full charge
                    if (fWeap.autoFireOnFullCharge) {
                        // Fire! (Spartan Laser does this)
                        with (fWeap) event_user(1);
                    } else {
                        // overcharge or fire (Plasma Pistol does this)
                        if (releasedKeys & keyCode) {
                            // fire button's released, so fire
                            // the weapon fires and any charging sound is killed
                            if (FMODInstanceIsPlaying(fWeap.chargeSoundID)) FMODInstanceStop(fWeap.chargeSoundID);
                            with (fWeap) event_user(1);
                        } else {
                            // overcharging, burn through ammo and maintain loop
                            fWeap.ammoCount = max(0, fWeap.ammoCount - 1);
                            
                            // check if there's still ammo left
                            if (fWeap.ammoCount > 0) {
                                loopsoundmaintain(x, y, fWeap.chargeSoundID);
                            } else {
                                // if you lose your last ammo, you lose all your charge
                                fWeap.chargeLevel = 0;
                                if (FMODInstanceIsPlaying(fWeap.chargeSoundID)) FMODInstanceStop(fWeap.chargeSoundID);
                            }
                        }
                    }
                } else {
                    // charge is between 0 and max
                    
                    // check if the fire button has been released
                    if (releasedKeys & keyCode) {
                        // fire button's released, check what to do for this weapon
                        if (fWeap.onlyFireOnFullCharge) {
                            // the weapon only fires on a full charge, reset the charge and kill the charge sound
                            fWeap.chargeLevel = 0;
                            if (FMODInstanceIsPlaying(fWeap.chargeSoundID)) FMODInstanceStop(fWeap.chargeSoundID);
                        } else {
                            // the weapon fires and any charging sound is killed
                            if (FMODInstanceIsPlaying(fWeap.chargeSoundID)) FMODInstanceStop(fWeap.chargeSoundID);
                            with (fWeap) event_user(1);
                        }
                    } else {
                        // keep charging the weapon
                        fWeap.chargeLevel = min(fWeap.chargeLevel + 1, fWeap.maxCharge);
                        // maintain the charging sound
                        loopsoundmaintain(x, y, fWeap.chargeSoundID);
                        // if the weapon reached full charge and doesn't auto-fire on full, switch to the
                        // charged sound and loop it
                        if (fWeap.chargeLevel == fWeap.maxCharge) && (!fWeap.autoFireOnFullCharge) {
                            // kill the old sound first
                            FMODInstanceStop(fWeap.chargeSoundID);
                            // then start the new one
                            fWeap.chargeSoundID = loopsoundstart(x, y, fWeap.chargedSound);
                        }
                    }
                }
            } else {
                // grenade tossing, set charge level to 0
                fWeap.chargeLevel = 0;
                if (FMODInstanceIsPlaying(fWeap.chargeSoundID)) FMODInstanceStop(fWeap.chargeSoundID);
            }
        // non-chargering weapons that are not overheated (if they can overheat)
        } else if (!fWeap.chargesUp) && !(fWeap.overheats && fWeap.overheated) {
            // non-charging logic
            if (((keyState & fWeap.fullAuto) | pressedKeys) & keyCode) && (fWeap.ammoCount > 0) {
                with (fWeap) event_user(1);
            } else if (pressedKeys & keyCode) && (fWeap.ammoCount == 0) && (fWeap.reserveAmmo == 0) {
                // the key to fire was pressed, BUT there's no ammo at all
                if (player == global.myself) {
                    // play the no-ammo sound and display the no-ammo warning
                    // except if it's an Energy Sword
                    if (fWeap.weaponType != WEAPON_ENERGYSWORD) FMODSoundPlay(global.NoAmmoClickSnd);
                    ammoWarningCheck(fWeap, wCheckSide, true);     // flash the ammo warning
                }
            }
        }
        // muzzle spread reset (fire key released or weapon reloading)
        if ((releasedKeys & keyCode) || (fWeap.alarm[4] > -1)) && (fWeap.muzzleSpreadInc) {
            fWeap.muzzleSpread = fWeap.muzzleSpreadMin;
        }
    }   // END WEAPON FIRE FOR LOOP
    
    // Melee key
    // check if the current weapon is okay with a melee action right now
    // melee CAN occur during refire cooldown and reload, but NOT during equip delay, 
    // while a weapon is charging, or during melee cooldown
    // NOTE: Melee is currently NOT a synced event sent from the server to the client;
    // this is because the primary effects of melee (speed and position modification) is synced each step
    // on a quick update -- so in theory this can be left safely alone, for now.
    if (pressedKeys & $2000) && (weapons[currentWeapon].canMelee) && (weapons[currentWeapon].alarm[2] == -1) &&
        (weapons[currentWeapon].chargeLevel == 0) && (weapons[currentWeapon].alarm[8] == -1) &&
        (weapons[currentWeapon].alarm[9] == -1) && (grenadeTossFrame == -1) &&
        // use 'implies' function for special behaviour of the Energy Sword not being able to melee if out of ammo
        implies(weapons[currentWeapon].weaponType == WEAPON_ENERGYSWORD, weapons[currentWeapon].ammoCount > 0)
        {
        
        // if we're dual-wielding, we cancel dual-wield
        if (dualWielding) {
            dualWielding = false;
            // if we're the host, we send and do the DW weapon drop
            if (global.isHost) {
                sendEventWeaponDualDrop(player);
                doEventWeaponDualDrop(player);
            }
        } else if (!dualJustDropped) {
            // otherwise we behave normally (if we didn't drop a dual weapon this frame)
            // clear the zoomed status
            if (zoomed) {
                zoomed = false;
                undoZoomCursor();
            }
            
            // if a reload operation was in progress, cancel it
            if (weapons[currentWeapon].alarm[4] > -1) {
                weapons[currentWeapon].alarm[4] = -1;
                if (player == global.myself) FMODInstanceStop(weapons[currentWeapon].reloadSoundID);
            }
            
            // play the proper melee sound depending on weapon type
            switch (weapons[currentWeapon].weaponType) {
                case WEAPON_ENERGYSWORD:
                    playsound(x, y, global.EnergySwordMeleeSnd);
                    break;
                
                default:
                    playsound(x, y, global.MeleeSwingSnd);
                    break;
            }
            
            // weapon is no longer ready to shoot if it was before
            weapons[currentWeapon].readyToShoot = false;
            // start the melee animation
            weapons[currentWeapon].alarm[8] = 20;
            // start the melee search timer
            meleeSearchTimer = 3;
            // create the melee strike mask and set its initial timer for a 'passive' strike
            global.paramOwner = id;
            meleeStrikeMask = instance_create(0, 0, MeleeStrikeMask);
            global.paramOwner = noone;
            meleeStrikeMask.x = x;
            meleeStrikeMask.y = y;
            meleeStrikeMask.image_xscale = image_xscale;
            meleeStrikeMask.alarm[0] = 10;
        }
    }
    
    // Melee Search Timer check -- continue a melee search as long is the timer is > -1
    if (meleeSearchTimer > -1) {
        var hitID;
        
        // tell the weapon we haven't hit anyone yet
        weapons[currentWeapon].meleeHasHit = false;
        
        // continue to search for a valid target
        // perform the melee collision search 60 pixels out
        var meleeDir, meleeDist;
        
        if (weapons[currentWeapon].meleeRangeOverride) {
            // proceed only if the lunge victim still exists (hasn't been killed)
            if (instance_exists(weapons[currentWeapon].lungeVictimID)) {
                // Energy Sword lunge search behaviour
                // lunge directly at the victim, rather than where we're aiming (as we could miss the victim that way)
                meleeDir = point_direction(x, y, weapons[currentWeapon].lungeVictimID.x, weapons[currentWeapon].lungeVictimID.y);
                // fix the melee direction if we're facing left
                meleeDir += 180 * (image_xscale == -1);
                // set the distance to the weapon's max range
                meleeDist = weapons[currentWeapon].maxRange;
            } else {
                // "abort" the melee by setting the search distance to 1
                meleeDir = 0;
                meleeDist = 1;
            }
        } else {
            // default search behaviour
            meleeDir = aimDirection + (180 * (image_xscale == -1));
            meleeDist = 60;
        }
        
        // perform the search
        hitID = meleeCollisionSearch(meleeDist, meleeDir);
        
        // only actually lunge at someone if there's someone there
        if (hitID != -1) {
            // there's a victim ahead, let's lunge at him!
            var dist, dir;
            dist = point_distance(x, y, hitID.x, hitID.y);
            dir = point_direction(x, y, hitID.x, hitID.y);
            
            // we're now lunging
            meleeSearchTimer = -1;     // reset the search timer
            meleeLungeTimer = 5;       // set the timer for lunge expiration
            lungeXspeed = lengthdir_x(dist, dir) / 4.5;   // set the speed for the lunge lock, 
            lungeYspeed = lengthdir_y(dist, dir) / 4.5;   // just below the timer length to ensure we hit
            
            // change the melee strike mask's timer to account for the lunge
            meleeStrikeMask.alarm[0] = meleeLungeTimer + 1;
        }
    }
    
    // Grenade cycling / Dual Wield weapon pickup key
    // This key is context-sensitive, based on how long its been held down
    if ((keyState | pressedKeys) & $1000) {
        // the key is being held down, increment the timer
        weaponDualKeyTimer = min(weaponDualKeyTimer + 1, 100);
        var w2ReadyToShoot;
        
        // whether weapon 2 is ready-to-shoot
        w2ReadyToShoot = true;
        if (instance_exists(weapons[2])) {
            w2ReadyToShoot = weapons[2].readyToShoot;
        }
        
        // if the button's been held down for long enough and a dual-wield weapon is nearby,
        // and pickup is okay to happen right now, dual-wield
        if (weaponDualKeyTimer >= 21) && (nearestDualWeapon != noone) && w2ReadyToShoot {
            if (global.isHost) {
                sendEventWeaponPickup(player, 2, nearestDualWeapon);
                doEventWeaponPickup(player, 2, nearestDualWeapon);
            }
            
            // reset the timer
            weaponDualKeyTimer = 0;
            weaponDualKeyPickedUp = true;
        }
    } else if (releasedKeys & $1000) {
        // the key was released
        // if the key wasn't held down for too long...
        if (weaponDualKeyTimer < 10) && !weaponDualKeyPickedUp {
            // if we're not dual-wielding, we cycle grenades
            if (!dualWielding) {
                // grenade cycling behaviour
                var newType;
                
                newType = currentGrenade;
                // cycle to the next available grenade type, or return to the original if nothing is available
                do {
                    newType = (newType + 1) mod 4;
                    // if the new selected grenade type is in stock, set the currentGrenade to match
                    if (grenadeAmmo[newType] > 0) currentGrenade = newType;
                } until (newType == currentGrenade);
            } else {
                // otherwise, we'd try to reload the dual-wielded weapon
                if (weapons[2].readyToShoot && (weapons[2].ammoCount < weapons[2].maxAmmo)) {
                    var reserveOk;
                    reserveOk = false;
                    
                    // pool the weapon ammo if they're the same type for the purpose of the check
                    if (weapons[currentWeapon].weaponType == weapons[2].weaponType) {
                        if ((weapons[currentWeapon].reserveAmmo + weapons[2].reserveAmmo) > 0) reserveOk = true;
                    } else {
                        if (weapons[2].reserveAmmo > 0) reserveOk = true;
                    }
                    
                    if (reserveOk) {
                        // reload the dual-wielded weapon
                        with (weapons[2]) {
                            // reload time is extended slightly
                            alarm[4] = reloadTime * global.dualWieldReloadFactor;
                            readyToShoot = false;
                        }
                        if (player == global.myself) weapons[2].reloadSoundID = FMODSoundPlay(weapons[2].reloadSound);
                    }
                }
            }
        }
        
        // reset the timer
        weaponDualKeyTimer = 0;
        weaponDualKeyPickedUp = false;
    }
    
    // Grenade throwing key
    // grenades can only be tossed when the weapon is readyToShoot (not firing, not meleeing, not reloading, etc)
    // also not when a grenade is already being tossed or during grenade-toss cooldown
    // also not while dual-wielding
    if (pressedKeys & $0008) && (grenadeCooldownTimer == -1) && (weapons[currentWeapon].canGrenade) &&
        (weapons[currentWeapon].readyToShoot) && (!dualWielding) {
        // the grenade is not spawned immediately -- rather it's spawned on the last frame of the animation
        // so start the animation and cooldown countdowns if we have a grenade in stock
        if (grenadeAmmo[currentGrenade] > 0) {
            grenadeCooldownTimer = 30;
            // set the frame toss timer so its sycned to the sound
            grenadeTossFrame = 12;
            // set the type to be tossed
            grenadeTossType = currentGrenade;
            // clear the zoomed status
            if (zoomed) {
                zoomed = false;
                undoZoomCursor();
            }
            
            // play the sound effect for the grenade we're tossing
            switch (grenadeTossType) {
                case 0:
                    playsound(x, y, global.FragGrenadeThrowSnd);
                    break;
                case 1:
                    playsound(x, y, global.PlasmaGrenadeThrowSnd);
                    break;
                case 2:
                    break;
                case 3:
                    playsound(x, y, global.FirebombThrowSnd);
                    break;
            }
        }
    }
    
    // Grenade spawning check
    // if the frame is 1 NOW, that means its about to roll over to 0 this frame, so spawn the grenade now
    if (grenadeTossFrame == 1) {
        if (global.isHost && (grenadeAmmo[currentGrenade] > 0)) {
            var seed;
            seed = irandom(65535);
            sendEventThrowGrenade(player, grenadeTossType, seed);
            doEventThrowGrenade(player, grenadeTossType, seed);
        }
    }
    
    // Weapon Pickup Key
    // NOTE: The functions for the actual pickup ONLY work for the host,
    // as the host is responsible for sending the commands to the clients
    // Clients, however, will know which weapon is close enough to be picked up
    // so they can display it on the HUD
    if (global.isHost) {
        if ((keyState | pressedKeys) & $0200) {
            // increment the timer so long as it's held down
            weaponPickupKeyTimer = min(weaponPickupKeyTimer + 1, 100);
            
            // if the button's been held down for long enough and a weapon is nearby,
            // and pickup is okay to happen right now, pick up the weapon
            // weapon pickup can occur when the gun is ready to shoot, or during reload/refire time, but never any other time
            if (weaponPickupKeyTimer >= 21) && (nearestPickupWeapon != noone) &&
            ((weapons[currentWeapon].readyToShoot) || (weapons[currentWeapon].alarm[0] > -1) || (weapons[currentWeapon].alarm[4] > -1)) {
                sendEventWeaponPickup(player, currentWeapon, nearestPickupWeapon);
                doEventWeaponPickup(player, currentWeapon, nearestPickupWeapon);
                
                // reset the timer
                weaponPickupKeyTimer = 0;
            }
        } else {
            // the key is not being held down, reset the timer
            weaponPickupKeyTimer = 0;
        }
    }
    
    // if this is the player's character, set the nearest weapon as shown on the HUD
    if (player == global.myself) {
        VisorHud.nearestPickupWeapon = nearestPickupWeapon;
        VisorHud.nearestDualWeapon = nearestDualWeapon;
    }
    // and after that, we need to reset the nearest weapon variables, in case there are no
    // future collision events
    nearestPickupWeapon = noone;
    nearestPickupWeaponDist = 0;
    nearestDualWeapon = noone;
    nearestDualWeaponDist = 0;
    
    // Jump key
    if (pressedKeys & $0080) {
        if (!crouched) {
            // jump if not crouched
            if (!place_free(x, y + 1) && place_free(x, y)) {
                //playsound(x,y,global.JumpSnd);
                vspeed = min(vspeed - jumpStrength, -jumpStrength);
            } else if (canDoublejump and !doublejumpUsed and vspeed > -jumpStrength) {
                vspeed = -jumpStrength;
                //playsound(x,y,global.JumpSnd);
                doublejumpUsed = 1;
                moveStatus = 0;
            }
        } else if (crouched && (vspeed == 0) && (crouchFrame == -1)) {
            // uncrouch if fully crouched
            toggleCrouch(true);
        }
    }
    
    // Crouch key
    if (pressedKeys & $0004) {
        // cannot toggle crouching if the player is moving vertically (falling or jumping)
        // also cannot toggle if they're mid-transition between standing/crouching
        if ((vspeed == 0) && (crouchFrame == -1)) {
            // toggle crouching and animate the transition
            toggleCrouch(true);
        }
    }
        
    // Cloak
    /* We don't do spy cloaking shit anymore, it works differently now
    if (!player.humiliated && (pressedKeys & $08)
        && canCloak && ((cloakAlpha == 1 and !cloak) or cloak)
        && !intel  && !taunting)
    {
        if(currentWeapon.readyToStab) {
            if (cloak) { // stop spies immediately picking up intel after uncloaking
                canGrabIntel=false;
                alarm[1]=30;
            }
            cloak = !cloak;
        }
    }
    */
    
    switch(moveStatus) // moveStatus is reset in collision with ceilings (including doors if they reject you)
    {
    case 1: //If I am rocketing/mining myself
            controlFactor = 0.65;
        frictionFactor = 1;
        break;
    case 2: //If I am rocketing/mining an enemy
        controlFactor = 0.45;
        frictionFactor = 1.05;
        break;
    case 3: //Airblast
        controlFactor = 0.35;
        frictionFactor = 1.05;
        break;
    case 4: //If I am rocketing/mining a teamate
        controlFactor = baseControl;
        frictionFactor = 1;
        break;
    default:
        if (player.humiliated)
            controlFactor = baseControl-0.2;
        else if (intel)
            controlFactor = baseControl-0.1;
        else
            controlFactor = baseControl;
        frictionFactor = baseFriction;
    }
    
    if(moveStatus == 1 or moveStatus == 2 or moveStatus == 4)
    {
        if !variable_local_exists("jumpFlameParticleType")
        {
            jumpFlameParticleType = part_type_create();
            part_type_sprite(jumpFlameParticleType,FlameS,true,false,true);
            part_type_alpha2(jumpFlameParticleType,1,0.3);
            part_type_life(jumpFlameParticleType,2,5);
            part_type_scale(jumpFlameParticleType,0.7,-0.65);
        }
        vspeed -= 0.06;
        
        if !variable_global_exists("jumpFlameParticleSystem")
        {
            global.jumpFlameParticleSystem = part_system_create();
            part_system_depth(global.jumpFlameParticleSystem, 10);
        }
        
        if(global.particles == PARTICLES_NORMAL)
        {
            if(random(1) > (controlFactor+frictionFactor)/2)
            {
                effect_create_below(ef_smoke,x-hspeed*1.2,y-vspeed*1.2+20,0,c_gray);
            }
        }
        if(global.particles == PARTICLES_NORMAL or global.particles == PARTICLES_ALTERNATIVE)
        {
            if(random(7) < 5)
            {
                part_particles_create(global.jumpFlameParticleSystem,x,y+19,jumpFlameParticleType,1);
            }
        }
    }
    
    _basemaxspeed = abs(runPower * baseControl / (baseFriction-1));
    
    // Left/Right movement keys
    if((keyState|pressedKeys) & $40 and hspeed > -_basemaxspeed)
        hspeed -= runPower*controlFactor;
            
    if((keyState|pressedKeys) & $20 and hspeed < _basemaxspeed)
        hspeed += runPower*controlFactor;
    
    //divide friction as normal if going way too fast
    if(abs(hspeed) > _basemaxspeed * 2 or
       ((keyState|pressedKeys) & $60 and abs(hspeed) < _basemaxspeed))
        hspeed /= baseFriction;
    else //otherwise divide by the moveStatus's friction
        hspeed /= frictionFactor;
       
    pressedKeys = 0;
    releasedKeys = 0;
    
    if(abs(hspeed)<0.195 /*and not moveStatus = 3*/) { // Overweight carrying intel and shooting will get stuck with this number much higher
        hspeed=0;
        animationImage=0;
    }    
    
    // if the place below the character is free of solids AND hostile characters
    if (place_free(x, y + 1)) {
        vspeed += 0.6;
        if (vspeed > 10) {
            vspeed = 10;
        }
    }
    
    // Melee speed lock -- modified version of Dusty's implementation:
    // "Needs to go after friction/gravity so the lunge plays nice."
    if (meleeLungeTimer > -1) {
        hspeed = lungeXspeed;
        vspeed = lungeYspeed;
    }
    
    if (intel)
    { 
        if (cloak)
        {
            cloak=false;
            cloakAplha=1;
        }
        intelRecharge = min(INTEL_MAX_TIMER, intelRecharge + INTEL_MAX_TIMER/(3*30));// 3*30 == it'll take 3 seconds for this to charge
    }
    
    /*
    // we don't draw humiliation in Halo Mod
    if (player.humiliated)  
    {
        if (!place_free(x,y+1) && hspeed == 0)
            animationImage = 0;
        else if place_free(x,y+1)
            animationImage = 2;
        if (!place_free(x,y+1) && hspeed != 0)
            animationImage = 1+((animationImage-1+abs(hspeed)/20) mod CHARACTER_ANIMATION_LEN);
    }
    else
    */
    
    // Chose the proper animation frame based on running/crouching states
    // NOTE: Problems may arise from this stuff being only in the Begin Step event
    // (with regards to being shot while crouched), so be ready to copy some functions to the End Step event or something
    var prevAnimImage;
    // Keep track of what the previous frame's image was so we can play sounds only on frame boundaries
    prevAnimImage = animationImage;
    
    if (!crouched && (crouchFrame == -1)) {
        // the user is not crouched or transitioning
        colorSprite = ArmorWalkColorS;
        overSprite = ArmorWalkOutlineS;
        // set the animation base
        animationBase = bodyType * 10;

        // perform the various state checks
        if (place_free(x, y + 1)) {
            // user is in mid-air
            animationImage = CHAR_RUN_ANIM_LEN + 1;
        } else if (hspeed == 0) {
            // user is standing still
            animationImage = CHAR_RUN_ANIM_LEN;
        } else {
            // user is running
            animationImage = ((animationImage + hspeed * image_xscale / 13) mod CHAR_RUN_ANIM_LEN);
            if (animationImage < 0) animationImage += CHAR_RUN_ANIM_LEN;
        }
        
        // play a random stepping sound on specific frame boundaries
        if (abs(floor(prevAnimImage) - floor(animationImage)) > 0) && (abs(hspeed) > 0.2) {
            // the frames are different depending on the direction of movement
            // for walking forwards it's 0 and 4, for backwards it's 2 and 6
            if (sign(hspeed * image_xscale) == 1) {
                if (floor(animationImage) == 0) || (floor(animationImage) == 4) {
                    playsound(x, y, choose(global.FootstepSnd1, global.FootstepSnd2, global.FootstepSnd3, global.FootstepSnd4, global.FootstepSnd5));
                }
            } else if (sign(hspeed * image_xscale) == -1) {
                if (floor(animationImage) == 2) || (floor(animationImage) == 6) {
                    playsound(x, y, choose(global.FootstepSnd1, global.FootstepSnd2, global.FootstepSnd3, global.FootstepSnd4, global.FootstepSnd5));
                }
            }
        }
        
        // calculate the bob offset
        var bobFrame;
        bobFrame = floor(abs(animationImage mod (CHAR_RUN_ANIM_LEN + 2)));
        bobAmt = global.walkBob[bobFrame];
        
    } else if (crouched && (crouchFrame == -1)) {
        // crouched, not transitioning
        colorSprite = ArmorCrouchColorS;
        overSprite = ArmorCrouchOutlineS;
        // set the animation base
        animationBase = bodyType * 9;
        
        // perform the various state checks
        if (place_free(x, y + 1)) {
            // user is in mid-air
            animationImage = CHAR_CROUCH_ANIM_LEN;
        } else if (hspeed == 0) {
            // user is standing still
            animationImage = CHAR_CROUCH_ANIM_LEN;
        } else {
            // user is crouch-running
            animationImage = ((animationImage + hspeed * image_xscale / 18) mod CHAR_CROUCH_ANIM_LEN);
            if (animationImage < 0) animationImage += CHAR_CROUCH_ANIM_LEN;
        }
        
        // play a random stepping sound on specific frame boundaries
        if (abs(floor(prevAnimImage) - floor(animationImage)) > 0) && (abs(hspeed) > 0.2) {
            // for crouch-walking it's 0, 2, 4, and 6
            if ((floor(animationImage) mod 2) == 0) {
                playsound(x, y, choose(global.FootstepSnd1, global.FootstepSnd2, global.FootstepSnd3, global.FootstepSnd4, global.FootstepSnd5));
            }
        }
        
        // calculate the bob offset
        var bobFrame;
        bobFrame = floor(abs(animationImage mod (CHAR_RUN_ANIM_LEN + 2)));
        bobAmt = global.crouchBob[bobFrame];
        
    } else {
        // transitioning between crouch and standing
        colorSprite = ArmorLoweringColorS;
        overSprite = ArmorLoweringOutlineS;
        // set the animation base
        animationBase = bodyType * 3;
        
        if (crouched) {
            // crouching down
            animationImage = 2 - crouchFrame;
        } else {
            // standing up
            animationImage = crouchFrame;
        }
        
        // calculate the bob offset
        var bobFrame;
        bobFrame = floor(abs(animationImage mod (CHAR_RUN_ANIM_LEN + 2)));
        bobAmt = global.loweringBob[bobFrame];
        
    }
        
    // drop intel if round is over
    // TODO: Ask KZ if we still do this in Halo 2D
    if (intel && global.mapchanging) {
        event_user(5);
    }
    
    //ubered max out ammo and extinguish flames
    /* Ubering is no longer a thing
    if ubered {
        if (burnIntensity > 0 || burnDuration > 0)
        {
            burnIntensity = 0;
            burnDuration = 0;
            burnedBy = -1;
        }
        if instance_exists(currentWeapon) {
            with(currentWeapon) {
                if(variable_local_exists("maxAmmo")) {
                    ammoCount = maxAmmo;
                }
                alarm[5] = -1;
            }
        }
    }
    */
    
    //give max ammo for players on the winning team
    var arenaRoundEnd;
    arenaRoundEnd = true;
    if instance_exists(ArenaHUD) { 
        if(ArenaHUD.endCount!=0) 
            arenaRoundEnd=true;
        else arenaRoundEnd=false;
    }
    
    /* No end-match humiliation logic for weapons
    if (arenaRoundEnd and global.mapchanging and !player.humiliated) {
        if instance_exists(currentWeapon) {
            with(currentWeapon){
                if(variable_local_exists("maxAmmo")) {
                    ammoCount = maxAmmo;
                }
                alarm[5] = -1;
            }
        }
    }
    */
    
    //drop cloak and unscope if on losing team or stalemate
    /* Humiliation is not a thing
    if (player.humiliated)
    {
        if (zoomed)
            toggleZoom(id);
        if (!stabbing)
            cloak = false;
    }
    */
    
    // Determine if the character is capturing a CP, and which
    /*
    var zone;
    zone = collision_point(x,y,CaptureZone,0,0);
    
    if(zone >= 0 and !cloak)
        cappingPoint = zone.cp;
    else
        cappingPoint = noone;
    */
    
    // if the char's HP < 50 (and is the user's char, enable eligibilty for Stop Drop Go) [Disabled for now]
    /*
    if (global.myself == player) && (hp < 50) && ((player.class == CLASS_HEAVY) || (player.class == CLASS_MEDIC)) {
        AchievementController.stopDropGoOkay = true;
    }
    */
}
