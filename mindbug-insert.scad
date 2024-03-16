// Mindbug

// 119mm wide, 168mm long

cube([166, 117, 0.36]);

//166-92

// Card is 88, so 92 with slack
// 62 so 66 with slack

cardw = 67;
cardh = 93;
frac = 0.5;

translate([0, 117-cardh-1, 0]) cube([cardw*0.6,1, 34]);
translate([cardw,117-cardh*frac, 0]) cube([1,cardh*frac, 34]);

translate([166-cardh,117-cardw*frac, 0]) cube([1,cardw*frac, 34]);
translate([166-cardh*frac, 117-cardw-1, 0]) cube([cardh*frac,1, 34]);
