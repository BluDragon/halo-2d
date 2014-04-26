{
    var xoffset, yoffset, tColor, sColor;
    
    if global.myself.object = -1 || global.myself.class!=CLASS_MEDIC exit;
    
    xoffset = view_xview[0];
    yoffset = view_yview[0];
    
    draw_set_valign(fa_center);
    draw_set_halign(fa_left);
    draw_set_alpha(1);
    
    // define text and shadow colors
    tColor = make_color_rgb(148, 191, 242);
    sColor = make_color_rgb(73, 146, 233);

    var myMedigun;
    myMedigun = -1;
    with(Medigun) {
        if (ownerPlayer == global.myself) myMedigun = id;
    }
    if (myMedigun != -1) {
        // draw the HUD BG
        draw_sprite_ext(UberHudS, 0, xoffset + 41, yoffset + 28, 1, 1, 0, c_white, 1);
        // draw the HUD FG
        draw_sprite_part(UberBarS, 0, 0, 0, 111 * myMedigun.uberCharge / 2000, 15, xoffset + 41, yoffset + 28);
        // draw the text
        draw_text_shadow(xoffset + 41, yoffset + 20, "Invincibility", 1, 1, 0, tColor, sColor, 1);
    }
}
