/* Draws an Ammo HUD, called by the VisorHud
**
** argument0 = Instance ID of the weapon to draw a HUD for
** argument1 = The side of the HUD to draw on and use the alert flashes of (left = true, right = false)
*/

{
    var xoffset, yoffset, xsize, ysize;
    var tColor, sColor;
    var i, aDist, ax, ay, curWeap;
    var emptyColor, emptyAlpha;
    var xMult, xBase, ammoVal;
    
    xoffset = view_xview[0];
    yoffset = view_yview[0];
    xsize = view_wview[0];
    ysize = view_hview[0];
    
    draw_set_alpha(1);
    // set the text alignment based on what side we're drawing on
    if (argument1) {
        draw_set_halign(fa_left);
    } else {
        draw_set_halign(fa_right);
    }
    draw_set_valign(fa_middle);
    
    // define text and shadow colors
    tColor = make_color_rgb(148, 191, 242);
    sColor = make_color_rgb(73, 146, 233);
    
    if (instance_exists(argument0)) {
        // get the current weapon
        curWeap = argument0;
        
        // determine what alpha and color to use for the empty bullets
        if (argument1) {
            if (ammoFlashLeft) {
                // use the normal red color of the 2nd frame
                emptyColor = c_white;
                emptyAlpha = 1 - (ammoFlashLeftFrame / hudFlashSpeed) * 0.8;
            } else {
                // blacken it for non-flashing empty pips
                emptyColor = c_black;
                emptyAlpha = 0.2;
            }
            // draw from the left side
            xBase = xoffset;
            xMult = -1;
        } else {
            if (ammoFlashRight) {
                // use the normal red color of the 2nd frame
                emptyColor = c_white;
                emptyAlpha = 1 - (ammoFlashRightFrame / hudFlashSpeed) * 0.8;
            } else {
                // blacken it for non-flashing empty pips
                emptyColor = c_black;
                emptyAlpha = 0.2;
            }
            // draw from the right side
            xBase = xoffset + xsize;
            xMult = 1;
        }
        
        // figure out what value to use for the numerical ammo counter
        switch (curWeap.object_index) {
            case EnergySword:
            case PlasmaPistol:
            case PlasmaRifle:
            case SpartanLaser:
                // energy weapons
                ammoVal = ceil(curWeap.ammoCount / curWeap.maxAmmo * 100);
                break;
                
            default:
                // default behaviour
                ammoVal = curWeap.reserveAmmo;
                
                // if the owner is dual-wielding and the current weapon and dw weapon are the same
                // type, show their reserve ammo as pooled
                if (curWeap.owner.dualWielding) {
                    if (curWeap.owner.weapons[curWeap.owner.currentWeapon].weaponType == curWeap.owner.weapons[2].weaponType) {
                        ammoVal = curWeap.owner.weapons[curWeap.owner.currentWeapon].reserveAmmo + curWeap.owner.weapons[2].reserveAmmo;
                    }
                }
                break;
        }
       
        // draw common items last, weapon specific calculations first      
        // weapon-specific stuff
        switch (curWeap.object_index) {
            case AssaultRifle:
                //aDist = 97 / 17;
                aDist = 6;
                for (i = curWeap.maxAmmo; i > 0; i -= 1) {
                    ax = ((i - 1) mod 16) * aDist;
                    ay = 14 * floor((i - 1) / 16);
                    if (i <= curWeap.ammoCount) {
                        draw_sprite_ext(BattleRifleAmmoS, 0, floor(xBase - (28 + ax) * xMult), yoffset + 79 - ay, xMult, 1, 0, c_white, 1);
                    } else {
                        draw_sprite_ext(BattleRifleAmmoS, 1, floor(xBase - (28 + ax) * xMult), yoffset + 79 - ay, xMult, 1, 0, emptyColor, emptyAlpha);
                    }
                }
                break;
            
            case BattleRifle:
                aDist = 6;
                for (i = curWeap.maxAmmo; i > 0; i -= 1) {
                    ax = ((i - 1) mod 18) * aDist;
                    ay = 14 * floor((i - 1) / 18);
                    if (i <= curWeap.ammoCount) {
                        draw_sprite_ext(BattleRifleAmmoS, 0, floor(xBase - (28 + ax) * xMult), yoffset + 79 - ay, xMult, 1, 0, c_white, 1);
                    } else {
                        draw_sprite_ext(BattleRifleAmmoS, 1, floor(xBase - (28 + ax) * xMult), yoffset + 79 - ay, xMult, 1, 0, emptyColor, emptyAlpha);
                    }
                }
                break;
            
            case Carbine:
                aDist = 7;
                for (i = curWeap.maxAmmo; i > 0; i -= 1) {
                    if (i <= curWeap.ammoCount) {
                        draw_sprite_ext(CarbineAmmoS, 0, floor(xBase - (20 + aDist * (i - 1)) * xMult), yoffset + 65, xMult, 1, 0, c_white, 1);
                    } else {
                        draw_sprite_ext(CarbineAmmoS, 1, floor(xBase - (20 + aDist * (i - 1)) * xMult), yoffset + 65, xMult, 1, 0, emptyColor, emptyAlpha);
                    }
                }
                break;
            
            case EnergySword:
                // draw the bar background
                draw_sprite_ext(WeaponChargeBarS, 0, xBase - 136 * xMult, yoffset + 65, xMult, 1, 0, c_white, 1);
                // draw the remaining charge
                draw_sprite_part_ext(WeaponChargeBarS, 1, 0, 0, curWeap.ammoCount / curWeap.maxAmmo * 111, 15, xoffset + 664, yoffset + 65, 1, 1, c_white, 1);
                break;
            
            case FuelRodCannon:
                //aDist = 97 / (curWeap.maxAmmo - 1);
                aDist = 28;
                for (i = curWeap.maxAmmo; i > 0; i -= 1) {
                    if (i <= curWeap.ammoCount) {
                        draw_sprite_ext(FuelRodAmmoS, 0, floor(xBase - (20 + aDist * (i - 1)) * xMult), yoffset + 65, 1, 1, 0, c_white, 1);
                    } else {
                        draw_sprite_ext(FuelRodAmmoS, 1, floor(xBase - (20 + aDist * (i - 1)) * xMult), yoffset + 65, 1, 1, 0, emptyColor, emptyAlpha);
                    }
                }
                break;
            
            case Magnum:
                aDist = 97 / (curWeap.maxAmmo - 1);
                for (i = curWeap.maxAmmo; i > 0; i -= 1) {
                    if (i <= curWeap.ammoCount) {
                        draw_sprite_ext(MagnumAmmoS, 0, floor(xBase - (20 + aDist * (i - 1)) * xMult), yoffset + 65, 1, 1, 0, c_white, 1);
                    } else {
                        draw_sprite_ext(MagnumAmmoS, 1, floor(xBase - (20 + aDist * (i - 1)) * xMult), yoffset + 65, 1, 1, 0, emptyColor, emptyAlpha);
                    }
                }
                break;
            
            case Mauler:
                aDist = 97 / (curWeap.maxAmmo - 1);
                for (i = curWeap.maxAmmo; i > 0; i -= 1) {
                    if (i <= curWeap.ammoCount) {
                        draw_sprite_ext(MaulerAmmoS, 0, floor(xBase - (20 + aDist * (i - 1)) * xMult), yoffset + 65, 1, 1, 0, c_white, 1);
                    } else {
                        draw_sprite_ext(MaulerAmmoS, 1, floor(xBase - (20 + aDist * (i - 1)) * xMult), yoffset + 65, 1, 1, 0, emptyColor, emptyAlpha);
                    }
                }
                break;
            
            case PlasmaPistol:
            case PlasmaRifle:
            case SpartanLaser:
                // draw the bar background
                draw_sprite_ext(WeaponChargeBarS, 0, xBase - 136 * xMult, yoffset + 65, xMult, 1, 0, c_white, 1);
                //draw_sprite_ext(WeaponChargeBarS, 1, xBase - 136 * xMult, yoffset + 65, xMult, 1, 0, c_white, 1);
                // draw the heat bar
                draw_sprite_part_ext(WeaponChargeBarS, 2, 0, 0, curWeap.heat / curWeap.maxHeat * 111, 15, xBase - 136 * xMult, yoffset + 65, xMult, 1, c_white, 1);
                break;
            
            case Shotgun:
                aDist = 97 / (curWeap.maxAmmo - 1);
                for (i = curWeap.maxAmmo; i > 0; i -= 1) {
                    if (i <= curWeap.ammoCount) {
                        draw_sprite_ext(ShotgunAmmoS, 0, floor(xBase - (20 + aDist * (i - 1)) * xMult), yoffset + 65, 1, 1, 0, c_white, 1);
                    } else {
                        draw_sprite_ext(ShotgunAmmoS, 1, floor(xBase - (20 + aDist * (i - 1)) * xMult), yoffset + 65, 1, 1, 0, emptyColor, emptyAlpha);
                    }
                }
                break;
            
            case SMG:
                //aDist = 97 / 17;
                aDist = 6;
                for (i = curWeap.maxAmmo; i > 0; i -= 1) {
                    ax = ((i - 1) mod 20) * aDist;
                    ay = 14 * floor((i - 1) / 20);
                    if (i <= curWeap.ammoCount) {
                        draw_sprite_ext(BattleRifleAmmoS, 0, floor(xBase - (28 + ax) * xMult), yoffset + 84 - ay, xMult, 1, 0, c_white, 1);
                    } else {
                        draw_sprite_ext(BattleRifleAmmoS, 1, floor(xBase - (28 + ax) * xMult), yoffset + 84 - ay, xMult, 1, 0, emptyColor, emptyAlpha);
                    }
                }
                break;
            
            case SniperRifle:
                // Sniper Rifle has a special case for being zoomed in
                // Snipers can't be dual-wielded, so don't worry about a dual-wield case
                if (global.myself.object.zoomed) {
                    // zoomed-in case
                    
                    // draw the repositioned ammo icons w/o flash
                    for (i = curWeap.maxAmmo; i > 0; i -= 1) {
                        if (i <= curWeap.ammoCount) {
                            draw_sprite_ext(SniperRifleAmmoS, 0, xoffset + 292, yoffset + 359 - i * 11, 1, 1, 0, c_white, 1);
                        }
                    }
                    // draw "DIST" and "ELEV" flavor text
                    var dist, elev;
                    dist = point_distance(0, 0, global.myself.object.scopeRelX, global.myself.object.scopeRelY);
                    elev = point_direction(0, 0, global.myself.object.scopeRelX, global.myself.object.scopeRelY);
                    // adjust the elevation values to look more presentable
                    if (elev > 90) && (elev < 270) {
                        elev = 180 - elev;
                    } else if (elev >= 270) {
                        elev = elev - 360;
                    }
                    draw_set_halign(fa_left);
                    draw_text_shadow(xoffset + 275, yoffset + 380, "DIST " + string_format(dist, 3, 2) + "#ELEV " + string_format(elev, 3, 2), 1, 1, 0, tColor, sColor, 1);
                } else {
                    // normal drawing case
                    aDist = 37;
                    for (i = curWeap.maxAmmo; i > 0; i -= 1) {
                        if (i <= curWeap.ammoCount) {
                            draw_sprite_ext(SniperRifleAmmoS, 0, floor(xoffset + 775 - aDist * (i - 1)), yoffset + 65, 1, 1, 0, c_white, 1);
                        } else {
                            draw_sprite_ext(SniperRifleAmmoS, 1, floor(xoffset + 775 - aDist * (i - 1)), yoffset + 65, 1, 1, 0, emptyColor, emptyAlpha);
                        }
                    }
                }
                break;
            
            case Spiker:
                aDist = 6;
                for (i = curWeap.maxAmmo; i > 0; i -= 1) {
                    ax = ((i - 1) mod 20) * aDist;
                    ay = 14 * floor((i - 1) / 20);
                    if (i <= curWeap.ammoCount) {
                        draw_sprite_ext(SpikerAmmoS, 0, floor(xBase - (28 + ax) * xMult), yoffset + 79 - ay, xMult, 1, 0, c_white, 1);
                    } else {
                        draw_sprite_ext(SpikerAmmoS, 1, floor(xBase - (28 + ax) * xMult), yoffset + 79 - ay, xMult, 1, 0, emptyColor, emptyAlpha);
                    }
                }
                break;
                
            default:
                // unhandled weapon
                ammoVal = -1;
                break;
        }
        
        // draw the divider bar
        draw_sprite_ext(AmmoDividerS, 0, xBase - 108 * xMult, yoffset + 36, 1, 1, 0, c_white, 1);
        // draw the weapon text
        draw_text_shadow(xBase - 116 * xMult, yoffset + 36, string(ammoVal), 2, 2, 0, tColor, sColor, 1);
        // draw the weapon icon
        draw_sprite_ext(global.weaponHudIcon[curWeap.weaponType], 0, xBase - 98 * xMult, yoffset + 36, xMult, 1, 0, c_white, 1);        

        // draw the ammo pickup number animation, if appropriate
        draw_set_halign(fa_center);
        var ptScale, ptColor, ptAlpha, ptShadow;
        if (argument1) && (ammoPickupLeftTimer > -1) {
            // left side
            ptScale = 1 + (30 - ammoPickupLeftTimer) * 0.1;
            ptColor = merge_color(c_white, tColor, min(ammoPickupLeftTimer / 20, 1));
            ptShadow = merge_color(ptColor, c_black, 0.35);
            ptAlpha = min(ammoPickupLeftTimer / 10, 1);
            draw_text_shadow(xBase - 140 * xMult, yoffset + 36, "+" + string(ammoPickupLeftValue), ptScale, ptScale, 0, ptColor, ptShadow, ptAlpha);
        } else if (!argument1) && (ammoPickupRightTimer > -1) {
            // right side
            ptScale = 1 + (30 - ammoPickupRightTimer) * 0.1;
            ptColor = merge_color(c_white, tColor, min(ammoPickupRightTimer / 20, 1));
            ptShadow = merge_color(ptColor, c_black, 0.35);
            ptAlpha = min(ammoPickupRightTimer / 10, 1);
            draw_text_shadow(xBase - 140 * xMult, yoffset + 36, "+" + string(ammoPickupRightValue), ptScale, ptScale, 0, ptColor, ptShadow, ptAlpha);
        }
    } // end IF WEAPON EXISTS block
}
