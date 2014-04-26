{
    var xsize, ysize, xoffset, yoffset;
    var tColor, sColor, hudText;
    
    /* Commented out due to the removal of Firebomb grenades from 'pyro' classes
    // don't bother to draw if we're not a pyro or we don't exist (what an existential quandry!)
    if ((global.myself.object == -1) || (global.myself.class != CLASS_PYRO)) exit;
    
    xsize = view_wview[0];
    ysize = view_hview[0];
    xoffset = view_xview[0];
    yoffset = view_yview[0];
    
    draw_set_valign(fa_center);
    draw_set_halign(fa_center);
    draw_set_alpha(1);
    
    // define text and shadow colors
    tColor = make_color_rgb(148, 191, 242);
    sColor = make_color_rgb(73, 146, 233);
    
    // draw the HUD sprite
    draw_sprite_ext(sprite_index, 0, xoffset + 69, yoffset + 19, 1, 1, 0, c_white, 1);
    // draw the HUD text
    hudText = string(floor(global.myself.object.currentWeapon.ammoCount / 40));
    if (instance_exists(global.myself.object.currentWeapon)) draw_text_shadow(xoffset + 84, yoffset + 35, hudText, 2, 2, 0, tColor, sColor, 1);
    */
}
