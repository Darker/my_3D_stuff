total_side = 0.4;
// from ceiling to the light
total_depth = 0.06;
// Spacing from ceiling for ventilation
ventilation_spacing = 0.005;
// outside frame depth
outside_depth = total_depth - ventilation_spacing;

// width of the visible frame bars
frame_width = 0.02;


glass_side = total_side - frame_width * 2;
glass_thickness = 0.002;
glass_mount_padding = 0.01;
inner_frame_side = glass_side - 2*glass_mount_padding;

// How thick the frame is in total, including the indented part
frame_width_bottom = frame_width + glass_mount_padding;

bottom_frame_depth = total_depth - ventilation_spacing - glass_thickness;

light_center_point = [total_side/2, total_side/2, total_depth/2];

// https://www.ledshopik.cz/led-profil-wide-up-x11727
led_container_width = 0.0235;
led_container_inner_width = 0.02;
led_container_bottom_thickness = 0.002;
led_container_height = 0.01;
// How far does the led container overlap to the frame of the lamp
led_container_overlap = 0.01;
// The container for leds should be shorter than the side of lamp
// margin applies on both sides.
led_container_length_margin = frame_width_bottom - led_container_overlap;
// how long should it be cut
led_container_total_len = total_side - 2*led_container_length_margin;
// How long the LED strip inside will be
led_container_led_len = led_container_total_len - 2*led_container_overlap;
// Hole to put the wires through
led_wire_hole_diameter = min(led_container_inner_width - 2*0.0015, 0.0075);
led_wire_hole_radius = led_wire_hole_diameter / 2;

module light_frame() {
    // Length of one of the bars of the frame, these are all same length
    frame_bar_length = total_side - frame_width;

    translate([frame_width,0,0])
    cube([frame_bar_length, frame_width, outside_depth], false);


    color("#CC9900")
    translate([frame_width,0,0])
    rotate(90)
    cube([frame_bar_length, frame_width, outside_depth], false);

    color("#CC9900")
    translate([total_side,frame_width,0])
    rotate(90)
    cube([frame_bar_length, frame_width, outside_depth], false);

    translate([0,total_side-frame_width,0])
    cube([frame_bar_length, frame_width, outside_depth], false);

    color("#AA3300")
    translate([frame_width, frame_width, 0]) 
    cube([glass_side, glass_mount_padding, outside_depth - glass_thickness]);

    color("#AA3300")
    translate([frame_width, total_side-frame_width-glass_mount_padding, 0]) 
    cube([glass_side, glass_mount_padding, outside_depth - glass_thickness]);

    shorter_glass_padding = glass_side-2*glass_mount_padding;

    color("#BB3300")
    translate([frame_width, frame_width+glass_mount_padding, 0]) 
    cube([glass_mount_padding, shorter_glass_padding, outside_depth - glass_thickness]);

    color("#BB3300")
    translate([total_side-frame_width-glass_mount_padding, frame_width+glass_mount_padding, 0]) 
    cube([glass_mount_padding, shorter_glass_padding, outside_depth - glass_thickness]);
    // Option B - shorter and longer lines
    // One is offset to match the other
    // color("red")
    // translate([0,frame_width,0])
    //     cube([frame_width,total_side - 2 * frame_width,outside_depth], false);
}

module glass_cover() {
    color("gray", 0.2)
    translate([frame_width, frame_width, total_depth-ventilation_spacing-glass_thickness])
    cube([glass_side, glass_side, glass_thickness]);
}

module led_container_extrusion(pos) {
    translate([led_container_length_margin,pos,-led_container_bottom_thickness]) {
        color("gray")
        cube([led_container_total_len, led_container_width, led_container_bottom_thickness]);
        wall_thickness = (led_container_width - led_container_inner_width)/2.0;
        // height but not including the bottom part that was already extruded
        wall_height_subts = led_container_height-led_container_bottom_thickness;

        color("pink")
        translate([led_container_overlap, 0, led_container_bottom_thickness]) {
            wall_vect = [led_container_led_len, wall_thickness, wall_height_subts];

            cube(wall_vect);
            translate([0,led_container_width - wall_thickness,0])
            cube(wall_vect);
        }
    }
}

module screw_hole_cylinder(pos, diameter, length) {
    translate([frame_width+glass_mount_padding/2, pos+led_container_width/2 ,-led_container_bottom_thickness-0.00001]) {
        cylinder(length, diameter/2, diameter/2, $fn = 20);
    }
}

module led_container_holes(pos) {
    difference() {
        led_container_extrusion(pos);
        // wire hole
        translate([frame_width_bottom + led_wire_hole_radius, pos+led_container_width/2 ,-0.1]) {
            cylinder(0.2, led_wire_hole_diameter/2, led_wire_hole_diameter/2, $fn = 30);
        }
    }
}

// pos is relative to the edge of the lamp
module led_strip(pos) {
    assert(pos < total_side - frame_width);
    led_container_holes(pos = pos);

}

translate(light_center_point) {
    sphere(0.02);
}

light_frame();
glass_cover();
led_strip(0.2);
screw_hole_cylinder(0.2, 0.005, 0.01);
// translate([frame_width+led_wire_hole_diameter+0.004, 0.2+led_container_width/2 ,-0.1]) {
//     cylinder(0.2, led_wire_hole_diameter/2, led_wire_hole_diameter/2, $fn = 30);
// }
// cube([total_side, frame_width, outside_depth], false);

//translate([0, total_side - frame_width,0])
//cube([total_side, frame_width, outside_depth], false);

