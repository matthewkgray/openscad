include <mycardlib.scad>

// Suitable for a regular deck of ~50 cards with some slack
// Lid slides on the long way for first version, short way second version

box = [27,95,65, 2, 0, 3, [], 2, [0, 0], [0,0]]; // Long slide
//box = [95,27,65, 2, 0, 3, [], 2, [0, 0], [0,0]];  // Short slide

// It is often going to be worth printing these seperately.
// The texture of the lid can change at the point where it gets taller
// than the box.
groovebox(box);
groovelid(box);
