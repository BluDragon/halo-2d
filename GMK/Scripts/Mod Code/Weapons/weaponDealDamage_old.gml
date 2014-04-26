/* Common weapon damage function -- called by Weapon objects and their projectiles
**
** The following variables are expected to exist:
** hitType = Type of the object that was hit
** hitID = Instance ID of the character/object that was hit
** shieldDamage = Damage done to shields
** damage = Damage done to HP
** damageBleeds = Whether damage will bleed over from the shields to the HP
** headshotShield = Whether a headshot will instakill if shields are down
** headshotKill = Whether a headshot will instakill
*/
{
    var hDamage, sDamage, headshot, victim;
    
    // determine who we hit and what part
    if (hitType == Character) {
        headshot = false;
        victim = hitID;
    } else if (hitType == Helmet) {
        headshot = true;
        victim = hitID.owner;
    } else {
        // nothing that takes damage was hit -- exit the function
        exit;
    }
    
    // determine damage to shields and hp
    sDamage = min(shieldDamage, victim.shieldHp);
    // if shields are still up
    if (victim.shieldHp > 0) {
        if (damageBleeds) {
            // hp damage is bled from shields
            hDamage = shieldDamage - sDamage;
        } else {
            // no hp damage
            hDamage = 0;
        }
    } else {
        // hp damage is base damage
        hDamage = damage;
    }
    
    // if the shields took damage, flash them
    if (sDamage > 0) victim.shieldFlash = 8;
    
    // headshot cases
    if (headshot && headshotShield && hDamage > 0) {
        // instakill if target's shields are down or damage bleed would occur
        victim.hp = 0;
    } else if (headshot && headshotKill) {
        // instakill
        victim.hp = 0;
    } else {
        // normal damage
        victim.shieldHp -= sDamage;
        victim.hp -= hDamage;
    }

    // TODO: implement GG2's assist killing code
    victim.timeUnscathed = 0;
    victim.lastDamageDealer = ownerPlayer
    victim.lastDamageSource = weaponType;
    
    // force the victim to uncrouch if crouched
    if (victim.crouched) {
        with (victim) {
            toggleCrouch(false);
        }
    }
}
