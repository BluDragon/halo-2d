/* Draws character shield effects.  Made into a seperate script in case I need to move it around.
**
** argument0 = instance ID of the character
*/
{
    // draw some sparks if shields are down
    if (argument0.shieldHp <= 0) {
        var xOff, yOff, rot;
        repeat (8) {
            xOff = irandom_range(-8, 12) * argument0.image_xscale;
            yOff = irandom_range(-15, 30);
            rot = irandom_range(0, 15) * 22.5;
            draw_sprite_ext(ArmorShieldSparkS, 0, round(argument0.x) + xOff, round(argument0.y) + yOff, 1, 1, rot, c_white, argument0.cloakAlpha);
        }
    }
    
    // draw the shield recharge effects if shields are charging
    if ((argument0.timeUnscathed >= 127) && (argument0.timeUnscathed < 142) && (argument0.lastDamageSource != -1)) {
        var prog, yOff;
        
        prog = ((argument0.timeUnscathed - 127) / 15);
        yOff = 32 - prog * 80;
        
        //draw_sprite_ext(ArmorShieldRecharge, 0, round(argument0.x), round(argument0.y) + yOff, 1, 1, 0, c_white, 1);
        if (yOff > 0) {
            draw_sprite_part_ext(ArmorShieldRechargeS, 0, 0, 0, 30, max(0, 32 - yOff), round(argument0.x - 15), round(argument0.y) + (32 - max(0, 32 - yOff)), 1, 1, c_white, argument0.cloakAlpha);
        } else if (yOff < -15) {
            draw_sprite_part_ext(ArmorShieldRechargeS, 0, 0, min(40, abs(yOff + 15)), 30, 40 + (yOff + 15), round(argument0.x - 15), round(argument0.y) - 15, 1, 1, c_white, argument0.cloakAlpha);
        } else {
            draw_sprite_ext(ArmorShieldRechargeS, 0, round(argument0.x), round(argument0.y) + yOff, 1, 1, 0, c_white, argument0.cloakAlpha);
        }
    }
}
