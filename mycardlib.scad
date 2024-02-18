module bezel() {
cylinder(0.1, 0.8, 0.8);
}

friction_fit = 0.32;
//friction_fit = 2;

EXTERIOR_X = 0;
EXTERIOR_Y = 1;
EXTERIOR_Z = 2;
THICKNESS = 3;
LIP_HEIGHT = 4;
LID_HEIGHT = 5;
YDIVS = 6;
YDIV_HEIGHT_OFFSET = 7;
YDIV_CUTOUT = 8;  // Radius, edge_offset
EDGE_CUTOUT = 9;
$fn = 40;

lid_margin=8;


// The final bottom half of the box box will be EXTERIOR_Z+LIP_HEIGHT tall
// The lid will be LIP_HEIGHt+LID_HEIGHT tall and the final sealed box will be
// EXTERIOR_Z+LIP_HEIGHT+LID_HEIGHT

// spec = [x,y,z,thickness, liph, lidh, ydivs[], ydivoff,ydivcut[], edgecut[]]

module boxinterior(s, lipheight,lidheight,t) {
    translate([t, t, t])
    cube(s-[2*t,2*t,-lipheight-lidheight+t+t]);
}

module make_cut(spec) {
    difference() {
        children();
        union() {
            curvecut(spec, spec[EDGE_CUTOUT][0], spec[EDGE_CUTOUT][0]+spec[EDGE_CUTOUT][1]);
            translate([spec[EXTERIOR_X], 0, 0])
              curvecut(spec, spec[EDGE_CUTOUT][0], spec[EDGE_CUTOUT][0]+spec[EDGE_CUTOUT][1]);
        }        
    }
}

module cardbox(spec, add_friction_fit=false) {
    make_cut(spec) uncut_cardbox(spec, add_friction_fit);
    ydividers(spec);
}

module boxexterior(spec) {
    size= [spec[EXTERIOR_X], spec[EXTERIOR_Y], spec[EXTERIOR_Z]];
    cube(size);

}
module boxwlidspacer(spec, add_friction_fit) {
    t = spec[THICKNESS];
    size= [spec[EXTERIOR_X], spec[EXTERIOR_Y], spec[EXTERIOR_Z]];

    lipheight = spec[LIP_HEIGHT];
    lidheight = spec[LID_HEIGHT];    
    union() {
            if (add_friction_fit) {
            translate([(t-friction_fit)/2, (t-friction_fit)/2, 0]) cube(size+[friction_fit-1*t,
                                                                              friction_fit-1*t,
                                                                              lipheight]);
            }else {
            translate([(t)/2, (t)/2, 0]) cube(size+[-1*t,-1*t,lipheight]);
            }

            boxexterior(spec);
        }
}


module uncut_cardbox(spec, add_friction_fit) {
    //size, lipheight, lidheight, t) {
    epsilon=0.000;
    t = spec[THICKNESS];
    size= [spec[EXTERIOR_X], spec[EXTERIOR_Y], spec[EXTERIOR_Z]];
    lipheight = spec[LIP_HEIGHT];
    lidheight = spec[LID_HEIGHT];
    difference() {
        boxwlidspacer(spec, add_friction_fit);
        boxinterior(size,lipheight,lidheight,t);
    }

}

module oldcardlid(s, lipheight, lidheight, t, label) {
      difference() {
        difference() {
            //minkowski() {
              cube(s+[0,0,lipheight+lidheight]);
            //                bezel();
            //}
            minkowski() {
                cardbox(s,lipheight, lidheight, t);
                cube(friction_fit); // Was 0.1, didn't fit, adjusted to 0.5
            }

        }
        boxinterior(s,lipheight,lidheight,t);
}
            //translate([s[0]/2, s[2], 0]) linear_extrude(height=2) text(label);
 
}
module cardlid(spec) {
      s = [spec[EXTERIOR_X], spec[EXTERIOR_Y], spec[EXTERIOR_Z] ];
      lipheight = spec[LIP_HEIGHT];
      lidheight = spec[LID_HEIGHT];
      t = spec[THICKNESS];
      difference() {
        difference() {
            //minkowski() {
              cube(s+[0,0,lipheight+lidheight]);
            //                bezel();
            //}
            //minkowski() {
                cardbox(spec, add_friction_fit=true);  // This box needs to be slightly bigger for friction fit
            //    cube(friction_fit); // Was 0.1, didn't fit, adjusted to 0.5
            //}

        }
        boxinterior(s,lipheight,lidheight,t);
}
            //translate([s[0]/2, s[2], 0]) linear_extrude(height=2) text(label);
 
}

module holedlid(spec) {
    // Lid margin is how much of the lid to keep around the edges for the snapfit pins
    mainhole_x = spec[EXTERIOR_X]-2*spec[THICKNESS]-2*lid_margin;
    mainhole_y = spec[EXTERIOR_Y]-2*spec[THICKNESS]-2*lid_margin;
    holenudge = spec[THICKNESS]+lid_margin/2;
    echo("Hole =", mainhole_x, ",", mainhole_y);
    difference() {
        cardlid(spec);
        union() {
            translate([spec[THICKNESS]+lid_margin, spec[THICKNESS]+lid_margin, 0]) cube([mainhole_x, mainhole_y, spec[EXTERIOR_Z]+50]);
            translate([holenudge, holenudge, 0 ]) cylinder(h=spec[EXTERIOR_Z]+100, r=1.75, center=true);
            translate([spec[EXTERIOR_X]-holenudge, holenudge, 0 ]) cylinder(h=spec[EXTERIOR_Z]+100, r=1.75, center=true);
            translate([spec[EXTERIOR_X]-holenudge, spec[EXTERIOR_Y]-holenudge, 0 ]) cylinder(h=spec[EXTERIOR_Z]+100, r=1.75, center=true);
            translate([holenudge, spec[EXTERIOR_Y]-holenudge, 0 ]) cylinder(h=spec[EXTERIOR_Z]+100, r=1.75, center=true);
        }
    }
}

module arrow(offset_height=0, column_height=3, r1=2, r2=0.5, height=5, column_r=2, cone_height=2){
    t = 0.5;
    s=2;
    difference(){
        union(){
            translate([0,0,offset_height+(cone_height/2+column_height)])cylinder (r1=r1, r2=r2, h=cone_height, center=true); //arrow head
            translate([0,0,offset_height+column_height/2])cylinder(r=column_r-t, h=column_height, center=true); //mini column
		}
        translate([0,0,offset_height+column_height+t]) 
        cube([s/3,column_r*2,cone_height+t+(column_height/2)], center=true); //cut in snap fit
    }
}

module lidartwithpins(spec) {
    lid_inset_tolerance = 1.5;
    mainhole_x = spec[EXTERIOR_X]-2*spec[THICKNESS]-2*lid_margin;
    mainhole_y = spec[EXTERIOR_Y]-2*spec[THICKNESS]-2*lid_margin;
    holenudge = spec[THICKNESS]+lid_margin/2;

    translate([lid_inset_tolerance/2, lid_inset_tolerance/2])
    cube([spec[EXTERIOR_X]-lid_inset_tolerance,
          spec[EXTERIOR_Y]-lid_inset_tolerance, spec[THICKNESS]] );
    translate([holenudge, holenudge, spec[THICKNESS]]) arrow();
    translate([spec[EXTERIOR_X]-holenudge, spec[EXTERIOR_Y]-holenudge, spec[THICKNESS]]) arrow();
    translate([holenudge, spec[EXTERIOR_Y]-holenudge, spec[THICKNESS]]) arrow();
    translate([spec[EXTERIOR_X]-holenudge, holenudge, spec[THICKNESS]]) arrow();
    translate([spec[THICKNESS] + lid_margin+1,
    spec[THICKNESS]+lid_margin+1, 0]) resize([mainhole_x-2, mainhole_y-2, 3]) children();
    
}

//spec = [80, 60, 10, 1, 3, 6, [], 18, [9, 9], [0,0]];

//translate([0,0,18]) holedlid(spec);
//lidartwithpins(spec);
//cardbox(spec);

module boxwithlid(size, lipheight, lidheight, thickness, label) {
    exterior_size = size+[2*thickness, 2*thickness,2*thickness];
    cardbox(exterior_size, lipheight,lidheight, thickness);
    
    translate([size[0]+thickness+1,exterior_size[1]+5,lipheight+lidheight]) 
    rotate([0,180,0])
    translate([0,0,-1*exterior_size[2]])
    cardlid(exterior_size, lipheight,lidheight, thickness, label);    
}




module ydivider(spec, xdiv, offset) {
    translate([xdiv, 0, 0]) 
    difference() {
//    union() {
        cube([spec[THICKNESS]/2, spec[EXTERIOR_Y], spec[EXTERIOR_Z]-offset]);
        curvecut(spec, spec[YDIV_CUTOUT][0], spec[YDIV_CUTOUT][1], 
        spec[YDIV_HEIGHT_OFFSET]);
    }
}

module ydividers(spec) {
    if(len(spec[YDIVS]) > 0) 
    for(i = [0:len(spec[YDIVS])-1])
        ydivider(spec, spec[YDIVS][i], spec[YDIV_HEIGHT_OFFSET]);
}



module curvecut(spec, r, offset, height_offset=0) {
    translate([spec[THICKNESS], 0, spec[LIP_HEIGHT]+spec[EXTERIOR_Z]-r-height_offset])
    rotate([0,-90,0])
    linear_extrude(spec[3]*2)
        hull() {
            translate([r, offset+spec[THICKNESS], 0]) circle(r);
            translate([r, spec[EXTERIOR_Y]-offset-spec[THICKNESS], 0]) circle(r);
        }
}

module mydovetail(dovetail_bottom, dovetail_top, dovetail_length, rail) {
    translate([-dovetail_bottom/2,rail,0]) rotate([90,0,0]) linear_extrude (rail) polygon([[0, 0], [
    (dovetail_bottom-dovetail_top)/2, dovetail_length], [dovetail_top+(dovetail_bottom-dovetail_top)/2, dovetail_length], [dovetail_bottom, 0] ]);
}
module grooves (dovetail_max, dovetail_height, rail_length, rail_spacing, height_adjust=0) {
    union() {
        translate ([(groove_side_thickness/2),0,0.01-dovetail_height])
        mydovetail(dovetail_max, dovetail_max-dovetail_delta, groovedepth, rail_length-thickness-height_adjust);
        translate( [rail_spacing-(groove_side_thickness)/2,0,0.01-dovetail_height])
        mydovetail(dovetail_max, dovetail_max-dovetail_delta, groovedepth, rail_length-thickness-height_adjust);
    }
}

module lidslab(spec) {
translate([-1.5,0,spec[2]])
cube([spec[0]+3, spec[1], 3.5]);
}
module lidramp(spec) {
    //translate([4,89, 64.65])
    //[67,95,65, 2, 0, 7, [], 11, [9, 9], [0,0]]
    translate([4,spec[1]-6, spec[2]-0.35])
        hull() {
            ridgelen = spec[0]-8;
            cube([ridgelen,0.1,0.01]);
            translate([0, 6, 0]) cube([ridgelen,0.1,0.4]);
        }
}

module thelidon(spec) {
    difference() {
        union() {
            lidslab(spec);
            lidramp(spec);
        }
        // Groove slots in the lid
    // Original slots
    translate([-0.4,0,spec[2]]) mirror([0,0,1]) grooves(groovewidth,groovedepth,spec[1]-10, spec[0]+0.75);
    // Slightly tighter
    translate([-0.4,0,spec[2]]) mirror([0,0,1]) grooves(groovewidth-tolerance/2,groovedepth,spec[1]-2, spec[0]+0.75);
    }
}
module groovelid(spec) {
    // Position the lid
    translate([spec[2]+3+spec[0]+10,2.5+spec[0]-(spec[0]-spec[2])/2,0])
    rotate([90,0,-90])
    thelidon(spec);

    // Add the card frames
    //twoslotoffset = (pairedspec[1]/2)-5;
    //translate([pairedspec[0]+9.5,2.5+twoslotoffset,0]) vcardframe(pairedspec);
    //translate([pairedspec[0]+9.5,2.5-twoslotoffset,0]) vcardframe(pairedspec);
    
    // Add the tiny lip    
    //translate([89.7,11.5,pairedspec[1]-1]) rotate([-90,0,0]) linear_extrude(pairedspec[0]-20) circle(0.6);    
}

//---------------------------
//  ----- The box itself ----
//---------------------------
module groovebox(spec) {
    cardbox(spec);

    // Groove tongues on top of the box
    translate([-0.4,0,spec[2]]) mirror([0,0,1]) 
    grooves(groovewidth-tolerance, groovedepth-tolerance/2, spec[1]-2, spec[0]+0.75,height_adjust=tolerance);

}


// For the grooves
thickness = 1;
grooved_extra_thickness = 1.2;
// Width of the groove, slider is less by tolerance
groovewidth = 2.4;
groovedepth = 2;
tolerance = 0.3;
dovetail_delta = 0.7;
groove_side_thickness = thickness+grooved_extra_thickness;

example = [67,95,65, 2, 0, 7, [], 11, [9, 9], [0,0]]; // No lip
//example = [50, 50, 48, 1, 21, 11, [12, 30], 6, [3,3], [5,5]]; // Lip
//boxwlidspacer(example, false);
//cardbox(example);
//cardlid(example);

//groovebox(example);
//groovelid(example);

//boxinterior([10,7,14], 1, 2, 1);
//boxwithlid([10,7,15], 3.0,2, 0.5);
//boxwithlid([78,52,26], 2,5, 1.5);
//boxwithlid([110,78,16], 2,5, 1.5);
//boxwithlid([98,52,26], 6,7, 3,"M");

// Light Speed
//boxwithlid([52,78.5,28], 5,2, 1,"M");
//translate([-60,0,0])
//cardlid([54,80.5,30], 5,2, 1,"M");


// Pico
//OLD cardbox([57.7+2,89.2+2,4+2], 4,6, 1);
// THIS ONE WORKS cardbox([61, 91, 6], 4, 7, 1);
//rotate([0,180,0]) 
//cardlid([61,91,6], 4,7, 1);
