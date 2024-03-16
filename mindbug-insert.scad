// Mindbug minimalist insert for Evolution or Eternity box
// Holds all cards from original kickstarter, new expansions
// and stretch goals in a single Evolution/Eternity box

// I print on Bambu P1S with 0.16 Optimal settings


cube([166, 117, 0.36]);


cardw = 67;
cardh = 93;
frac = 0.5;

translate([0, 117-cardh-1, 0]) cube([cardw*0.6,1, 34]);
translate([cardw,117-cardh*frac, 0]) cube([1,cardh*frac, 34]);

translate([166-cardh,117-cardw*frac, 0]) cube([1,cardw*frac, 34]);
translate([166-cardh*frac, 117-cardw-1, 0]) cube([cardh*frac,1, 34]);
