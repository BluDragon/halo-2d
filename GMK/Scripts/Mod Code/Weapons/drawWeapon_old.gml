{
    var xviewoffset, yviewoffset, xviewsize, yviewsize;
    
    xviewoffset = view_xview[0];
    yviewoffset = view_yview[0];
    xviewsize = view_wview[0];
    yviewsize = view_hview[0];

    var drawSprite, colorFrame, outlineFrame;
    var tick;
    var xr, yr;
    var weaponAngle;
    
    // abort drawing if the weapon is not on-screen
    if distance_to_point(xviewoffset + xviewsize / 2, yviewoffset + yviewsize / 2) > 800 exit;
       
    // TODO: Dual wield support
    // if the weapon IS the current weapon
    if (owner.weapons[owner.currentWeapon] == id) {
        // weapon IS the current weapon
        // get the position of the weapon
        xr = round(x + xoffset * image_xscale);
        yr = round(y + yoffset);
    
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
            drawSprite = reloadSprite;
            colorFrame = armorFrame * reloadAnimLength + floor(reloadAnimLength * ((reloadTime - alarm[4]) / reloadTime));
            outlineFrame = colorFrame + reloadAnimLength * 8;
            image_angle = 0;
        } else if (alarm[2] > 0) {
            /********************************
            **    EQUIP DELAY
            ********************************/
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
        } else if (alarm[6] > 0) {
            /********************************
            **    RECOIL
            ********************************/
            // recoil MUST have lower priority than Melee, because the two timers run concurrently
            tick = refireTime - alarm[6];
            // some weapons animate differently, so handle those
            switch (weaponType) {
                case WEAPON_SHOTGUN:
                    // the shotgun animates at different speeds based on the elapsed time, for the recoil and the cocking
                    drawSprite = recoilSprite;
                    if (tick < 26) {
                        // normal recoil
                        colorFrame = armorFrame * recoilAnimLength + min(3, tick / 2);
                    } else {
                        // cocking the gun
                        colorFrame = armorFrame * recoilAnimLength + min(tick - 26 + 3, recoilAnimLength - 1);
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
                        outlineFrame = armorFrame + 8;
                    }
                    break;
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
            outlineFrame = armorFrame + 8;
        } else {
            /********************************
            **    IDLE
            ********************************/
            drawSprite = normalSprite;
            colorFrame = armorFrame;
            outlineFrame = armorFrame + 8;
        }
        
        // calculate weapon angle
        weaponAngle = image_angle + muzzleJitter;
    
        // draw the sprites
        draw_sprite_ext(drawSprite, colorFrame, xr, yr, image_xscale, image_yscale, weaponAngle, global.customColor[armorColor], owner.cloakAlpha);
        draw_sprite_ext(drawSprite, outlineFrame, xr, yr, image_xscale, image_yscale, weaponAngle, c_white, owner.cloakAlpha);
        
        // draw the shield effects
        // NOTE: this is done here due to weapons being the last part drawn of a character
        drawShieldEffects(owner);
        
    } else {
        // weapon is NOT the current, draw it on the back or hip
        xr = round(x);
        yr = round(y);
        
        // draw the sprite
        draw_sprite_ext(bodySprite, 0, xr, yr, image_xscale, image_yscale, 0, c_white, owner.cloakAlpha);
    }
}
