{
    /*
    xoffset = view_xview[0];
    yoffset = view_yview[0];
    xsize = view_wview[0];
    ysize = view_hview[0];
    
    if distance_to_point(xoffset+xsize/2,yoffset+ysize/2) > 800 exit;

    var xr, yr, sprite, bobFrame, bobAmt;
    xr = round(x);
    yr = round(y);
    // bobbing frame for the body/head
    bobFrame = floor(animationImage) mod 10;
    // add 10 if the frame is negative (for whatever the fuck reason this occurs)
    if (bobFrame < 0) bobFrame += 10;
    bobAmt = global.bodyBob[bobFrame];
        
    if global.myself == -1 && cloakAlpha==1{
        image_alpha = 1;
    } else if((global.myself.object == id && cloakAlpha==1) || (global.myself.object == -1)) {
        image_alpha = 1;
    } else if (!invisible) {
        image_alpha = cloakAlpha;
    } else {
        exit;
    }
   
    if global.myself.team == team && cloakAlpha<0.5 {
        if currentWeapon.readyToStab==true{
            cloakAlpha=0.5;
            image_alpha=0.5;
        }
    }
    
    if team == global.myself.team && (id != global.myself.object.id || global.showHealthBar == 1){
        draw_set_alpha(1);
        draw_healthbar(xr-10, yr-30, xr+10, yr-25,hp*100/maxHp,c_black,c_red,c_green,0,true,true);
    }    
    if(distance_to_point(mouse_x, mouse_y)<25) {
        // if I'm cloaked and the I'm not on the same team as the player is, then stop drawing
        if cloak && team!=global.myself.team exit;
        draw_set_alpha(1);
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        if(team==TEAM_RED) {
            draw_set_color(c_red);
        } else {
            draw_set_color(c_blue);
        }
        draw_text(xr, yr-35, player.name);
    }

    draw_set_alpha(1);
    if team == TEAM_RED ubercolour = c_red;
    if team == TEAM_BLUE ubercolour = c_blue;
    
    if omnomnomnom == true {
        draw_sprite_ext(OmnomnomnomS,omnomnomnomindex,xr,yr,image_xscale,image_yscale,image_angle,c_white,1);
        if ubered == 1 draw_sprite_ext(OmnomnomnomS,omnomnomnomindex,xr,yr,image_xscale,image_yscale,image_angle,ubercolour,0.7);
    }
    else if taunting == true{
        draw_sprite_ext(tauntsprite,tauntindex,xr,yr,image_xscale,image_yscale,image_angle,c_white,1);
        if ubered == 1 draw_sprite_ext(tauntsprite,tauntindex,xr,yr,image_xscale,image_yscale,image_angle,ubercolour,0.7);
    }
    else if taunting == false {
        // The character is not taunting, so we draw the head here
        var headSprite, headX, headY, headXScale, headAngle;
        
        // get info about how to draw the head
        headSprite = global.headSpriteIndex[player.team, player.class];
        if (((aimDirection + 270) mod 360) > 180) {
            headX = xr + global.headOffsetX[player.team, player.class];
            headY = yr + global.headOffsetY[player.team, player.class];
            
            headXScale = 1;
            headAngle = aimDirection;
            if ((headAngle > 180) && ((headAngle - 360) < global.headMinAngle)) headAngle = global.headMinAngle;
            if ((headAngle < 180) && (headAngle > global.headMaxAngle)) headAngle = global.headMaxAngle;
        } else {
            headX = xr - global.headOffsetX[player.team, player.class];
            headY = yr + global.headOffsetY[player.team, player.class];
            
            headXScale = -1;
            headAngle = aimDirection;
            if (headAngle < (180 - global.headMaxAngle)) headAngle = 180 - global.headMaxAngle;
            if (headAngle > (180 - global.headMinAngle)) headAngle = 180 - global.headMinAngle;
            headAngle += 180;
        }
        
        // handle the special case for the crouching sniper
        // (because the sprite actually IS a different height in this mod, we can't just
        // change sprites and call it a day, we have to shift the head down and whatnot)
        if (zoomed) {
            // adjust the sprite
            if (team == TEAM_RED) {
                sprite = SniperCrouchRedS;
            } else {
                sprite = SniperCrouchBlueS;
            }
            // shift the head
            //headX -= 4 * image_xscale;
            headY += 8;
            // alter the body bob
            bobAmt = global.crouchBob[bobFrame];
        } else {
            sprite = sprite_index;
        }
        
        // perform the calculations for Arms here
        var shldrX, shldrY, handX, handY, elbowX, elbowY, justShot, theta, D, D1, D2, gX, gY;
        var armGunOriginX, armGunOriginY;
        
        if (global.armDraw[player.class] == true) {
            if (global.armDualWield[player.class] == false) {
                // do the calculations
                justShot = currentWeapon.justShot;
                
                // figure out the armGunOriginX and Y from the current weapon's xoffset and yoffset
                armGunOriginX = currentWeapon.xoffset;
                armGunOriginY = currentWeapon.yoffset;
                
                // calculate the absolute co-ordinates for the shoulder point
                // Note: use currentweapon.image_xscale instead of the character's
                // image_xscale, because at the end of omnomnom, the gun will not
                // always face the same direction as the character.
                shldrX = x + sign(currentWeapon.image_xscale) * global.armShldrJointX[player.class];
                shldrY = y + global.armShldrJointY[player.class];
            
                // calculate the absolute co-ordinates for the hand point
                if (justShot == false) {
                    gX = global.armGunJointX[player.class];
                    gY = global.armGunJointY[player.class];
                } else {
                    gX = global.armGunJointFireX[player.class];
                    gY = global.armGunJointFireY[player.class];
                }
                if (sign(currentWeapon.image_xscale) == 1) {
                    theta = degtorad(aimDirection);
                    handX = x + armGunOriginX + (gX * cos(theta) + gY * sin(theta));
                    handY = y + armGunOriginY + (-gX * sin(theta) + gY * cos(theta));
                } else {
                    theta = degtorad(180 - aimDirection);
                    handX = x - armGunOriginX - (gX * cos(theta) + gY * sin(theta));
                    handY = y + armGunOriginY + (-gX * sin(theta) + gY * cos(theta));
                }
            
                // calculate the distance between those two points
                D = point_distance(shldrX, shldrY, handX, handY);
                // calculate D1 and D2
                D1 = (global.armUpperLength[player.class] * global.armUpperLength[player.class] - global.armLowerLength[player.class] * global.armLowerLength[player.class] + D * D) / (D * 2);
                D2 = D - D1;
            
                // calculate the absolute co-ordinates for the elbow point
                theta = arccos(D1 / global.armUpperLength[player.class]);
                if (global.armCurvesUp[player.class] == true) {
                    theta = degtorad(point_direction(shldrX, shldrY, handX, handY)) + theta * sign(image_xscale);
                } else {
                    theta = degtorad(point_direction(shldrX, shldrY, handX, handY)) - theta * sign(image_xscale);
                }
                
                elbowX = shldrX + cos(theta) * global.armUpperLength[player.class];
                elbowY = shldrY - sin(theta) * global.armUpperLength[player.class];
                
                // adjust the arms for bobbing
                elbowY += bobAmt;
                handY += bobAmt;
            } else {    // dual wield = true
            
                // calculate the absolute co-ordinates for the shoulder point
                // Note: use currentweapon.image_xscale instead of the character's
                // image_xscale, because at the end of omnomnom, the gun will not
                // always face the same direction as the character.
                shldrX = x + sign(currentWeapon.image_xscale) * global.armShldrJointX[player.class];
                shldrY = y + global.armShldrJointY[player.class];
            }
            
            // adjust the arms for bobbing
            shldrY += bobAmt;
        }
        
        // adjust the head for bobbing, if not Quote
        if (player.class != CLASS_QUOTE) headY += bobAmt;
        
        // SPECIAL CASE FOR PYRO WHEN THROWING GRENADES
        var pyroCase, tossFrame;
        pyroCase = false;
        if (player.class == CLASS_PYRO) {
            if (currentWeapon.tossed) {
                pyroCase = true;
                tossFrame = floor((12 - currentWeapon.alarm[9]) / 3) + 4 * player.team;
                shldrX = x + sign(currentWeapon.image_xscale) * 18;
                shldrY = y - 7;
            }
        }
        
        if ubered == 0 {
            // draw the arms
            if ((global.armDraw[player.class] == true) && (cloakAlpha > 0.5) && !pyroCase) {
                if (global.armDualWield[player.class] == false) {
                    draw_sprite_ext( global.armUpperSpriteIndex[player.class], player.team,
                        round(shldrX), round(shldrY), 1, image_xscale,
                        radtodeg(theta), c_white, cloakAlpha);
                    draw_sprite_ext( global.armLowerSpriteIndex[player.class], player.team,
                        round(elbowX), round(elbowY), 1, image_xscale,
                        point_direction(elbowX, elbowY, handX, handY), c_white, cloakAlpha);
                } else {
                    draw_sprite_ext( global.armUpperSpriteIndex[player.class], player.team,
                        round(shldrX), round(shldrY), currentWeapon.image_xscale, currentWeapon.image_yscale,
                        currentWeapon.image_angle, c_white, cloakAlpha);
                }
            }
            // handle the pyro throwing special case
            if (pyroCase) {
                draw_sprite_ext(PyroTossS, tossFrame, round(shldrX), round(shldrY), currentWeapon.image_xscale, currentWeapon.image_yscale, 0, c_white, cloakAlpha);
            }
        
            // draw the body
            draw_sprite_ext(sprite,floor(animationImage+animationOffset),xr,yr,image_xscale,image_yscale,image_angle,c_white,cloakAlpha);
            // draw the fiery hat
            if (hasFieryHat) draw_sprite_ext(FieryHatS, hatFrame, headX, headY, headXScale, 1, headAngle, c_white, min(0.5, cloakAlpha));
            // draw the head
            draw_sprite_ext(headSprite, 0, headX, headY, headXScale, 1, headAngle, c_white, cloakAlpha);
            
            // if the character is cloaked (Wesker only, so dont bother to do a class check), draw his arm
            // we will need to do a team check, though, to make sure we draw the right one
            if (cloakAlpha <= 0.5) {
                draw_sprite_ext(SpyArmS, player.team, xr, yr + global.bodyBob[bobFrame], image_xscale, image_yscale, image_angle, c_white, cloakAlpha);
            }
            
        }
        else if ubered == 1 {
            // draw the arms
            if ((global.armDraw[player.class] == true) && (cloakAlpha > 0.5) && !pyroCase) {
            
                if (global.armDualWield[player.class] == false) {
                    draw_sprite_ext( global.armUpperSpriteIndex[player.class], player.team,
                        round(shldrX), round(shldrY), 1, image_xscale,
                        radtodeg(theta), c_white, 1);
                    draw_sprite_ext( global.armUpperSpriteIndex[player.class], player.team,
                        round(shldrX), round(shldrY), 1, image_xscale,
                        radtodeg(theta), ubercolour, 0.7);
                    draw_sprite_ext( global.armLowerSpriteIndex[player.class], player.team,
                        round(elbowX), round(elbowY), 1, image_xscale,
                        point_direction(elbowX, elbowY, handX, handY), c_white, 1);
                    draw_sprite_ext( global.armLowerSpriteIndex[player.class], player.team,
                        round(elbowX), round(elbowY), 1, image_xscale,
                        point_direction(elbowX, elbowY, handX, handY), ubercolour, 0.7);
                } else {
                    draw_sprite_ext( global.armUpperSpriteIndex[player.class], player.team,
                        round(shldrX), round(shldrY), currentWeapon.image_xscale, currentWeapon.image_yscale,
                        currentWeapon.image_angle, c_white, 1);
                    draw_sprite_ext( global.armUpperSpriteIndex[player.class], player.team,
                        round(shldrX), round(shldrY), currentWeapon.image_xscale, currentWeapon.image_yscale,
                        currentWeapon.image_angle, ubercolour, 0.7);
                }
            }
            // handle the pyro throwing special case
            if (pyroCase) {
                draw_sprite_ext(PyroTossS, tossFrame, round(shldrX), round(shldrY), currentWeapon.image_xscale, currentWeapon.image_yscale, 0, c_white, 1);
                draw_sprite_ext(PyroTossS, tossFrame, round(shldrX), round(shldrY), currentWeapon.image_xscale, currentWeapon.image_yscale, 0, ubercolour, 0.7);
            }
            
            // draw the body
            draw_sprite_ext(sprite,floor(animationImage+animationOffset),xr,yr,image_xscale,image_yscale,image_angle,c_white,1);
            draw_sprite_ext(sprite,floor(animationImage+animationOffset),xr,yr,image_xscale,image_yscale,image_angle,ubercolour,0.7);
            // draw the fiery hat
            if (hasFieryHat) draw_sprite_ext(FieryHatS, hatFrame, headX, headY, headXScale, 1, headAngle, c_white, min(0.5, cloakAlpha));
            // draw the head
            draw_sprite_ext(headSprite, 0, headX, headY, headXScale, 1, headAngle, c_white, 1);
            draw_sprite_ext(headSprite, 0, headX, headY, headXScale, 1, headAngle, ubercolour, 0.7);
            
            // if the character is cloaked (Wesker only, so dont bother to do a class check), draw his arm
            // we will need to do a team check, though, to make sure we draw the right one
            if (cloakAlpha <= 0.5) {
                draw_sprite_ext(SpyArmS, player.team, xr, yr + bobAmt, image_xscale, image_yscale, image_angle, c_white, 1);
                draw_sprite_ext(SpyArmS, player.team, xr, yr + bobAmt, image_xscale, image_yscale, image_angle, ubercolour, 0.7);
            }
        }
    }

    if (burnDuration > 0 or burnIntensity > 0) {
        for(i = 0; i < numFlames * burnIntensity / maxIntensity; i += 1)
        {
            draw_sprite_ext(FlameS, alarm[5] + i + random(2), x + flameArray_x[i], y + flameArray_y[i], 1, 1, 0, c_white, burnDuration / maxDuration * 0.71);
        }  
    }
    */
    
    var xr, yr, xoffset, yoffset, xsize, ysize;
    
    xoffset = view_xview[0];
    yoffset = view_yview[0];
    xsize = view_wview[0];
    ysize = view_hview[0];
    
    if distance_to_point(xoffset + xsize / 2, yoffset + ysize / 2) > 800 exit;
    
    xr = round(x);
    yr = round(y);
        
    // use the shield overlay if shields took damage recently
    if (shieldFlash > -1) overSprite = ArmorWalkShieldsS;
    
    // draw accessories first
    switch (accessoryType) {
        case 1:
            // Hayabusa Sword
            draw_sprite_ext(AccHayabusaS, 0, xr, yr + bobAmt, image_xscale, image_yscale, image_angle, c_white, cloakAlpha);
            break;
            
        case 2:
            // Security Com
            draw_sprite_ext(AccSecurityComS, 0, xr, yr + bobAmt, image_xscale, image_yscale, image_angle, c_white, cloakAlpha);
            break;
    }
    
    // draw grenade-tossing arms next, if applicable
    if (grenadeTossFrame != -1) {
        var frame, armAngle;

        // calculate the initial frame
        frame = floor((11 - grenadeTossFrame) * (sprite_get_number(GrenadeArmColorS) / 96));
        
        // calculate the angle of the arm, except for the first two frames
        if (frame >= 2) {
            // copied from helmet angle stuff
            armAngle = aimDirection;
            if ((aimDirection + 270) mod 360 > 180) {
                if ((armAngle > 180) && ((armAngle - 360) < global.grenadeArmMinAngle)) armAngle = global.grenadeArmMinAngle;
                if ((armAngle < 180) && (armAngle > global.grenadeArmMaxAngle)) armAngle = global.grenadeArmMaxAngle;
            } else {
                if (armAngle < (180 - global.grenadeArmMaxAngle)) armAngle = 180 - global.grenadeArmMaxAngle;
                if (armAngle > (180 - global.grenadeArmMinAngle)) armAngle = 180 - global.grenadeArmMinAngle;
                armAngle += 180;
            }
        } else {
            armAngle = image_angle;
        }
        
        // recalculate the frame w/ the proper shoulder type
        frame += shoulderType * sprite_get_number(GrenadeArmColorS) / 8;
        
        draw_sprite_ext(GrenadeArmColorS, frame, xr + 4 * image_xscale, yr + bobAmt, image_xscale, image_yscale, armAngle, global.customColor[bodyColor], cloakAlpha);
        draw_sprite_ext(GrenadeArmOutlineS, frame, xr + 4 * image_xscale, yr + bobAmt, image_xscale, image_yscale, armAngle, c_white, cloakAlpha);
    }
    
    // draw the body sprites
    draw_sprite_ext(colorSprite, floor(animationBase + animationImage), xr, yr, image_xscale, image_yscale, image_angle, global.customColor[bodyColor], cloakAlpha);
    draw_sprite_ext(overSprite, floor(animationBase + animationImage), xr, yr, image_xscale, image_yscale, image_angle, c_white, cloakAlpha);
    
    // NOTE: shield effects are drawn by the Weapon object, as it's the last part of a character drawn
}
