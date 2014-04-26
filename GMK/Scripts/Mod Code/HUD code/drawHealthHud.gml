// Draw the new health HUD

{
    if (global.myself.object == -1) {
        instance_destroy();
        exit; 
    }
    
    // abort draw if the user is zoomed in -- the HUD isn't drawn if we're scoped
    if (global.myself.object.zoomed) exit;
    
    var hpPer, fullBarLength, barLength, cOffset, tAlpha;
    
    hpPer = global.myself.object.shieldHp / global.myself.object.maxShieldHp;

    // calculate the color for the underlay
    fullBarLength = 200;
    barLength = fullBarLength * hpPer;
    
    if (hpPer > 0.20) {
        cOffset = 0;
        tAlpha = 1;
    } else if (hpPer != 0) {
        cOffset = 2;
        tAlpha = 1;
    } else {
        // shields down, flash full bar using the visor hud's synchronized timer
        cOffset = 2;
        tAlpha = 1 - (global.myself.object.timeUnscathed mod VisorHud.hudFlashSpeed) / VisorHud.hudFlashSpeed;
        barLength = fullBarLength;
    }
    
    // then draw the underlay
    draw_sprite_part_ext(ShieldBarS, cOffset + 1, 0, 0, barLength, 23, view_xview[0] + view_wview[0] / 2 - 100, view_yview[0] + 38, 1, 1, c_white, tAlpha);
    // and then draw the overlay
    draw_sprite_ext(ShieldBarS, cOffset, view_xview[0] + view_wview[0] / 2, view_yview[0] + 49, 1, 1, 0, c_white, 1);
}
