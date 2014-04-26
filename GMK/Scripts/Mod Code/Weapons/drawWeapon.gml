{
    var xviewoffset, yviewoffset, xviewsize, yviewsize;
    
    xviewoffset = view_xview[0];
    yviewoffset = view_yview[0];
    xviewsize = view_wview[0];
    yviewsize = view_hview[0];

    var drawSprite, colorFrame, outlineFrame;
    var tick;
    var xr, yr, xOff, yOff, leftSide;
    var weaponAngle;
    
    // abort drawing if the weapon is not on-screen
    if distance_to_point(xviewoffset + xviewsize / 2, yviewoffset + yviewsize / 2) > 800 exit;
    
    // figure out which offset and (if dual-wielding) which 'side' we're on (affects frame bases)
    switch (getWeaponPosition()) {
        case 0:
            // unequipped, no effect
            break;
        
        case 1:
            // equipped, on top
            xOff = xoffset;
            yOff = yoffset;
            leftSide = false;
            break;
        
        case 2:
            // equipped, on bottom
            xOff = xoffset + xoffsetDW;
            yOff = yoffset + yoffsetDW;
            leftSide = true;
            break;
    }
    
    // check if it's one of the equipped weapons
    if ((owner.weapons[owner.currentWeapon] == id) || (owner.weapons[2] == id)) {
        // it's one of the equipped weapons
        // get the position of the weapon
        xr = round(x + xOff * image_xscale);
        yr = round(y + yOff);
        
        // determine which sprites to use: recoil, reload, idle, etc.
        if (alarm[8] > 0) && !meleeRangeOverride {
            /********************************
            **    MELEE
            ********************************/
            var frame;
            
            // animation is divided in half, with the 'middle' frame stretched out over the intervening time
            if (alarm[8] > 10) {
                // starting part of the animation
                frame = min(20 - alarm[8], 2);
            } else {
                // latter half of the animation
                //frame = max(meleeAnimLength / 2, meleeAnimLength - alarm[8]);
                frame = min((10 - alarm[8]) / 10 * (meleeAnimLength - 2) + 2, meleeAnimLength - 1);
            }
            
            drawSprite = meleeSprite;
            colorFrame = armorFrame * meleeAnimLength + frame;
            outlineFrame = colorFrame + meleeAnimLength * 8;
            image_angle = 0;
        } else if (alarm[8] > 0) && meleeRangeOverride && (weaponType == WEAPON_ENERGYSWORD) {
            /********************************
            **    ENERGY SWORD LUNGE
            ********************************/
            var frame;
            
            // the animation just ends with the sword aloft
            drawSprite = recoilSprite;
            colorFrame = armorFrame * recoilAnimLength + min(20 - alarm[8], 3);
            outlineFrame = colorFrame + recoilAnimLength * 8;
        } else if (alarm[4] > 0) {
            /********************************
            **    RELOAD
            ********************************/
            // check if we're dual-wielding
            if (!owner.dualWielding) {
                // default behaviour
                drawSprite = reloadSprite;
                colorFrame = armorFrame * reloadAnimLength + floor(reloadAnimLength * ((reloadTime - alarm[4]) / reloadTime));
                outlineFrame = colorFrame + reloadAnimLength * 8;
                image_angle = 0;
            } else {
                // dual-wielded
                drawSprite = dualSprite;
                if (leftSide) {
                    colorFrame = armorFrame;
                } else {
                    colorFrame = armorFrame + 16;
                }
                outlineFrame = colorFrame + 8;
                
                // set the image angle for the reload animation based on how far in it is
                var t;
                t = ((floor(reloadTime * global.dualWieldReloadFactor) - alarm[4]) / floor(reloadTime * global.dualWieldReloadFactor));
                if (t <= 0.33) {
                    image_angle = (t / 0.33 * -80) * image_xscale;;
                } else if (t <= 0.66) {
                    image_angle = -80 * image_xscale;;
                } else {
                    image_angle = ((t - 0.66) / 0.33 * 80 - 80) * image_xscale;
                }
            }
        } else if (alarm[10] > 0) && (weaponType == WEAPON_PLASMAPISTOL) {
            /********************************
            **    PLASMA PISTOL COOLDOWN
            ********************************/
            // NOTE: takes priority over equip delays
            // figure out which frame of the animation to use
            // 3 steps per frame
            if (maxHeat - alarm[10] < 9) {
                tick = floor((maxHeat - alarm[10]) / 3);
            } else if (maxHeat - alarm[10] < maxHeat - 9) {
                tick = 2;
            } else {
                tick = 3 + floor((9 - alarm[10]) / 3);
            }
            // weapon is held level
            image_angle = 0;
            // check if dual-wielded
            if (!owner.dualWielding) {
                // check if the owner is tossing a grenade
                if (owner.grenadeTossFrame > -1) {
                    // grenade
                    drawSprite = dualCooldownSprite;
                    colorFrame = armorFrame * dualCooldownAnimLength + tick + dualCooldownAnimLength * 16;
                    outlineFrame = colorFrame + dualCooldownAnimLength * 8;
                } else {
                    // no grenade
                    drawSprite = cooldownSprite;
                    colorFrame = armorFrame * cooldownAnimLength + tick;
                    outlineFrame = colorFrame + cooldownAnimLength * 8;
                }
            } else {
                // dual-wielded
                drawSprite = dualCooldownSprite;
                if (leftSide) {
                    colorFrame = armorFrame * dualCooldownAnimLength + tick;
                } else {
                    colorFrame = armorFrame * dualCooldownAnimLength + tick + dualCooldownAnimLength * 16;
                }
                outlineFrame = colorFrame + dualCooldownAnimLength * 8;
            }
        } else if (alarm[10] > 0) && (weaponType == WEAPON_PLASMARIFLE) {
            /********************************
            **    PLASMA RIFLE COOLDOWN
            ********************************/
            // NOTE: takes priority over equip delays
            // figure out which frame of the animation to use
            // 5 steps per frame
            if (maxHeat - alarm[10] < 15) {
                // 3 frame lead-in
                tick = floor((maxHeat - alarm[10]) / 5);
            } else if (maxHeat - alarm[10] < maxHeat - 25) {
                // cycle the hot hand
                tick = 2 + (floor((maxHeat - alarm[10] - 15) / 3) mod 4);
            } else {
                // lead-out
                tick = 5 + min(floor((25 - alarm[10]) / 5), 2);
            }
            // weapon is held level
            image_angle = 0;
            // check if dual-wielded
            if (!owner.dualWielding) {
                // check if the owner is tossing a grenade
                if (owner.grenadeTossFrame > -1) {
                    // grenade
                    drawSprite = dualCooldownSprite;
                    colorFrame = armorFrame * dualCooldownAnimLength + tick + dualCooldownAnimLength * 16;
                    outlineFrame = colorFrame + dualCooldownAnimLength * 8;
                } else {
                    // no grenade
                    drawSprite = cooldownSprite;
                    colorFrame = armorFrame * cooldownAnimLength + tick;
                    outlineFrame = colorFrame + cooldownAnimLength * 8;
                }
            } else {
                // dual-wielded
                drawSprite = dualCooldownSprite;
                if (leftSide) {
                    colorFrame = armorFrame * dualCooldownAnimLength + tick;
                } else {
                    colorFrame = armorFrame * dualCooldownAnimLength + tick + dualCooldownAnimLength * 16;
                }
                outlineFrame = colorFrame + dualCooldownAnimLength * 8;
            }
        } else if (alarm[2] > 0) {
            /********************************
            **    EQUIP DELAY
            ********************************/
            // check if dual wielded
            if (!owner.dualWielding) {
                // default behaviour
                drawSprite = normalSprite;
                colorFrame = armorFrame;
                outlineFrame = armorFrame + 8;
                
                // calculate the drawing angle based on the time left
                if (equipOnBack) {
                    // from up to center
                    image_angle = 10 * max(alarm[2] - 8, 0) * image_xscale;
                } else {
                    // from down to center
                    image_angle = -10 * max(alarm[2] - 8, 0) * image_xscale;
                }
            } else {
                // dual wielded
                drawSprite = dualSprite;
                if (leftSide) {
                    colorFrame = armorFrame;
                } else {
                    colorFrame = armorFrame + 16;
                }
                outlineFrame = colorFrame + 8;
                
                // calculate the drawing angle based on the time left, always up from the floor
                image_angle = -10 * max(alarm[2] - 8, 0) * image_xscale;
            }
        } else if (alarm[6] > 0) {
            /********************************
            **    RECOIL
            ********************************/
            // check if dual wielded
            if (!owner.dualWielding) {
                // recoil MUST have lower priority than Melee, because the two timers run concurrently
                tick = refireTime - alarm[6];
                // some weapons animate differently, so handle those
                switch (weaponType) {
                    case WEAPON_SHOTGUN:
                        // the shotgun animates at different speeds based on the elapsed time, for the recoil and the cocking
                        drawSprite = recoilSprite;
                        if (tick < 24) {
                            // normal recoil
                            colorFrame = armorFrame * recoilAnimLength + min(3, tick / 2);
                        } else {
                            // cocking the gun
                            colorFrame = armorFrame * recoilAnimLength + min(tick - 24 + 3, recoilAnimLength - 1);
                        }
                        outlineFrame = colorFrame + recoilAnimLength * 8;
                        break;
                    
                    default:
                        // default behaviour of 1:1 playback speed
                        if (tick < recoilAnimLength) {
                            // if the position is less than the length of the recoil animation
                            drawSprite = recoilSprite;
                            colorFrame = armorFrame * recoilAnimLength + tick;
                            outlineFrame = colorFrame + recoilAnimLength * 8;
                        } else {
                            // otherwise use the idle sprite
                            drawSprite = normalSprite;
                            colorFrame = armorFrame;
                            outlineFrame = colorFrame + 8;
                        }
                        break;
                }
            } else {
                // dual wielded
                tick = refireTime - alarm[6];
                if (tick < recoilAnimLength) {
                    drawSprite = dualRecoilSprite;
                    if (leftSide) {
                        colorFrame = armorFrame * dualRecoilAnimLength + tick;
                    } else {
                        colorFrame = armorFrame * dualRecoilAnimLength + tick + dualRecoilAnimLength * 16;
                    }
                    outlineFrame = colorFrame + dualRecoilAnimLength * 8;
                } else {
                    drawSprite = dualSprite;
                    if (leftSide) {
                        colorFrame = armorFrame;
                    } else {
                        colorFrame = armorFrame + 16;
                    }
                    outlineFrame = colorFrame + 8;
                }
            }
        } else if (weaponType == WEAPON_ENERGYSWORD) && (alarm[0] > -1) && meleeHasHit {
            /****************************************
            **    ENERGY SWORD LUNGE FOLLOWUP
            ****************************************/
            // hold the sword aloft, then slowly lower it
            drawSprite = recoilSprite;
            colorFrame = armorFrame * recoilAnimLength + 6 - floor(min(9, alarm[0]) / 3);
            outlineFrame = colorFrame + recoilAnimLength * 8;
        } else if (owner.grenadeTossFrame > -1) {
            /********************************
            **    GRENADE TOSS
            ********************************/
            drawSprite = grenadeSprite;
            colorFrame = armorFrame;
            outlineFrame = colorFrame + 8;
        } else {
            /********************************
            **    IDLE
            ********************************/
            // check if dual-wielded
            if (!owner.dualWielding) {
                drawSprite = normalSprite;
                colorFrame = armorFrame;
                outlineFrame = colorFrame + 8;
            } else {
                // dual-wielded
                drawSprite = dualSprite;
                if (leftSide) {
                    colorFrame = armorFrame;
                } else {
                    colorFrame = armorFrame + 16;
                }
                outlineFrame = colorFrame + 8;
            }
        }
        
        // calculate weapon angle
        weaponAngle = image_angle + muzzleJitter;
    
        // draw the sprites
        draw_sprite_ext(drawSprite, colorFrame, xr, yr, image_xscale, image_yscale, weaponAngle, global.customColor[armorColor], owner.cloakAlpha);
        draw_sprite_ext(drawSprite, outlineFrame, xr, yr, image_xscale, image_yscale, weaponAngle, c_white, owner.cloakAlpha);

    } else {
        // weapon is NOT the current, draw it on the back or hip
        xr = round(x);
        yr = round(y);
        
        // draw the sprite
        draw_sprite_ext(bodySprite, 0, xr, yr, image_xscale, image_yscale, 0, c_white, owner.cloakAlpha);
    }
    
    // draw shield effects only if the weapon is the last one being drawn
    if (depth == origDepth) {
        // draw the shield effects
        // NOTE: this is done here due to weapons being the last part drawn of a character
        drawShieldEffects(owner);
    }
}
