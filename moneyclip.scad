// Simple Christmas tree themed moneyclip.  Print in green.

bump = 0.7;

n = 130;

points = [
	for (a = [0 : n]) [ 0.1*(a/10)*(a/10), a/10 ],
	for (a = [0 : n]) [ 0.01*((n-a)/10)*((n-a)/10), (n-a)/10 ],
];


module branch() {
    translate([10,41,0])
    rotate([0,0,180])
    linear_extrude(1) polygon(points);
}

module dshape(x, extend=0, bar=5) {
    linear_extrude(1)
    hull() {
        circle(x);;
        translate([x+extend, -1*x]) square([bar, x*2]);
    }
}

module clip() {
    difference() {
        dshape(28);
        dshape(21);
    }

    translate([1,0,0])
    difference() {
        dshape(15, extend=10);
        dshape(8, extend=10);
    }
}

clip();
module treeside() {
    for(i = [1:7])
    translate([-9*i, -4*i, 0]) branch();
}
treeside();
mirror([0,1,0]) treeside();
linear_extrude(1) polygon([[0, 28], [-65, 0], [0, -28], [-26,-9], [-26, 9]]);