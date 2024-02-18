// Blood spatter tokens for board games

$frn=40;

function cumsum(v) = [for (a = v[0]-v[0], i = 0; i < len(v); a = a+v[i], i = i+1) a+v[i]];

module unsmoothsplatter() {
angs = rands(20,90,4);
for (i=[1:4]) {
    r = rands(5,10,1)[0];
    ang = cumsum(angs)[i-1];
    //echo(ang);
    //echo (r);
    p = [r*cos(ang), r*sin(ang)];
    hull() {
        translate(p) circle(0.5);
        circle(2);
    }
    translate(p) circle(2);
}
circle(4);
}

module splatter() {
    // This is very thin, which means they're slightly translucent,
    // but a bit hard to pick up, so if translucent is not a goal, maybe make this 0.5 or more
    linear_extrude(0.2) 
    offset(-0.1) offset(0.1) unsmoothsplatter();
}

for (xi=[0:2]) {
    x = xi*25;
    for (yi=[0:2]) {
        y = yi*25;
        translate([x,y]) splatter();
    }
}
