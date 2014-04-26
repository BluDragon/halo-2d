/* Returns the weapon's 'position', based on the owner's dual wielding status and facing
** direction.  This is used to determine where to draw the weapon and where to spawn
** projectiles/hitscans from.
**
** The following values are returned:
** 0 = Weapon is unequipped and stowed on the body
** 1 = Weapon is equipped and 'on top' of the character
** 2 = Weapon is equipped and 'beneath' the character
*/

{
    // if the owner is dual-wielding
    if (owner.dualWielding) {
        if (owner.weapons[2] == id) {
            if (sign(image_xscale) == 1) {
                return 2;
            } else {
                return 1;
            }
        } else if (owner.weapons[owner.currentWeapon] == id) {
            if (sign(image_xscale) == 1) {
                return 1;
            } else {
                return 2;
            }
        } else {
            // unequipped weapon
            return 0;
        }
    } else {
        // owner is not dual-wielding
        if (owner.weapons[owner.currentWeapon] == id) {
            // on top
            return 1;
        } else {
            // unequipped weapon
            return 0;
        }
    }
}
