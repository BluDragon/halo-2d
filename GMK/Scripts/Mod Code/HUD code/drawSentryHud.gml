{
    var xsize, ysize, xoffset, yoffset;
    var tColor, sColor;
    
    xsize = view_wview[0];
    ysize = view_hview[0];
    xoffset = view_xview[0];
    yoffset = view_yview[0];
    
    draw_set_valign(fa_center);
    draw_set_halign(fa_left);
    draw_set_alpha(1);
    
    // define text and shadow colors
    tColor = make_color_rgb(148, 191, 242);
    sColor = make_color_rgb(73, 146, 233);
    
    if ((global.myself.object == -1) || (global.myself.class!=CLASS_ENGINEER)) {
        instance_destroy();
        exit; 
    }
    
    if(global.myself.sentry) {
        // draw the HUD BG
        draw_sprite_ext(UberHudS, 0, xoffset + 41, yoffset + 58, 1, 1, 0, c_white, 1);
        // draw the HUD FG
        draw_sprite_part(UberBarS, 0, 0, 0, 111 * global.myself.sentry.hp / global.myself.sentry.maxHp, 15, xoffset + 41, yoffset + 58);
        // draw the text
        draw_text_shadow(xoffset + 41, yoffset + 50, "Autoturret Health", 1, 1, 0, tColor, sColor, 1);
    }
}
