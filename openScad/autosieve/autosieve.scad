// Unit: cm
mode = "preview";

larger_diameter = 17;
smaller_diameter = 13;
// ring locations refer to rings outletward border
// in other words, the thing is built from the outlet
ring_distance = 35;
// How thick the ring is along the axis
ring_length = 2;
linear_ratio = (larger_diameter-smaller_diameter) / ring_distance;
// how far after the smaller ring does the solid portion extend to
// spit out unfiltered material
outlet_distance = 10;
// How far should the bigger ring extend after the axis to allow easy loading, this includes rings length
inlet_distance = 10;
// how much brim should there be at the end of main cone to prevent dirt from falling out
inlet_brim = 2;

ring_thickness = 0.3;

total_length = ring_distance + inlet_distance;
// distance at which the cone collapses into a single point
singularity_point = (-smaller_diameter)/linear_ratio;
// angle of the cone in respect to central axis
cone_angle = asin((smaller_diameter/2) / singularity_point);

// dimensions of the X shapes that hold the central axis


// diameter of the axis
axis_diameter = 0.82;
axis_radius = axis_diameter / 2.0;
// Width along rotation (seen from the inlet/outlet)
axis_frame_width = max(1.5, axis_diameter + 0.3);
// width along axis
axis_frame_thickness = 0.5;

// outside, there will be 3 rods holding it together, each at 60 deg angle
// diameter of the screw connecting the cones
reinforcement_diameter = 0.43;
reinforcement_radius = reinforcement_diameter / 2;
reinforcement_hole_thickness =  0.3;
reinforcement_hole_diameter = reinforcement_diameter + reinforcement_hole_thickness;
reinforcement_hole_radius = reinforcement_hole_diameter/2;
reinforcement_hole_length = 4;

// Stand and achor
// How much should the bottom part of the sieve be tilted relative to ground
sieve_tilt = 5; //+15;
// Since the cone is tilted towards inlet, we need to add that to the required tilt
stand_tilt = sieve_tilt + cone_angle;
// Thickness of the wooden planks holding the stand
outlet_plank_thickness = 1.8;
// Distance between the insides of the planks
outlet_planks_distance = 18;
// distance from the outlet
outlet_plank_start = 10;
// width of the planks
outlet_plank_width = 20;
// height of the planks
outlet_plank_height = 40;
// Thickness of the nodes that attach to the planks and hold the axis
axis_holder_thickness = 1;
axis_holder_width = 4;
axis_holder_height = 6;
// screw size of the holders (metric screw)
axis_holder_screw_M_size = 5;
axis_holder_screw_diameter = axis_holder_screw_M_size / 10.0;
// how far to extend the axis support
axis_holder_support_length = 1;
// Entry height of the axis in the first plank
axis_plank_height = 35;

assert(axis_plank_height + axis_diameter + 5 > outlet_plank_height);

// calculated from the outlet - at outlet this is 0
// produces outer radius of the cone at that position
function pos2diameter(position)  = (smaller_diameter + position*linear_ratio);
function pos2radius(position)  = pos2diameter(position)/2;
// Creates cylinder representing the axis to be used for making holes
module axis_for_removal(radius) {
    cylinder(ring_distance * 2, radius, radius);
}

// use radius offset to make it slightly larger, if you want to remove anything that would protrude out of the cone
// Always use the smaller diameter for the cone, the larger one is generated from lenth
module make_cone(height, diameter, thickness, radius_offset=0) {
    outer_radius_offset = radius_offset * 20;
    // diameter on the side towards the inlet
    inpside_diameter = diameter + (height * linear_ratio);
    
    radius = diameter / 2.0;
    inpside_radius = inpside_diameter / 2.0;

    // definitions for the inner cone that cuts the outer one
    cut_cylinder_overlap = 0.5;
    cut_cylinder_radius_overlap = (cut_cylinder_overlap * linear_ratio)/2.0;

    cut_cylinder_r1 =  radius - thickness/2 - cut_cylinder_radius_overlap;
    cut_cylinder_r2 =  inpside_radius - thickness/2 + cut_cylinder_radius_overlap;

    if(radius_offset >= 0)
    {
        difference()
        {
            cylinder(height, radius+outer_radius_offset, inpside_radius+outer_radius_offset);
            translate([0,0,-cut_cylinder_overlap])
            cylinder(height+2*cut_cylinder_overlap, cut_cylinder_r1 + radius_offset, cut_cylinder_r2 + radius_offset);
        }
    }
    // special case for generating inner cutoff
    else
    {
        radius_offset = -radius_offset;
        outer_radius_offset = - outer_radius_offset;
        translate([0,0,-cut_cylinder_overlap])
        cylinder(height+2*cut_cylinder_overlap, cut_cylinder_r1 + radius_offset, cut_cylinder_r2 + radius_offset);
    }
}

// This is for holes around that will be used to enhance structural integrity
// @param position this is the position in respect to the outlet end
// @param direction from which side to grow the hole, the overlap will be created in that direction
module outer_screw_hole(position, direction = 1) {
    start_radius = (smaller_diameter + ((position) * linear_ratio))/2;

    // How much does the square part of the hole extend into the cone
    square_part_extension = 0.1;
    // how much to offset from the base to allow space for nut
    offset_from_base = 0.15;
    // length is more than the base, and is sheared of later
    reinforcement_overlap = 0.5;
    overlap_translate = direction == 1 ? 0 : -1*reinforcement_overlap;
    length_with_overlap = reinforcement_hole_length + reinforcement_overlap;

    translate([0, start_radius+reinforcement_radius, position])
    {
        rotate([cone_angle, 0, 0])
        {
            difference() 
            {
                union()
                {
                    translate([0, offset_from_base, overlap_translate])
                    cylinder(length_with_overlap, reinforcement_hole_radius, reinforcement_hole_radius);
                    translate([-reinforcement_hole_radius, -reinforcement_hole_radius-square_part_extension,overlap_translate]) 
                    cube([reinforcement_hole_radius*2, reinforcement_hole_radius+square_part_extension+offset_from_base, length_with_overlap]);
                }
                
                translate([0, offset_from_base,-0.25])
                cylinder(length_with_overlap + 0.5, reinforcement_radius, reinforcement_radius);
            }
            
        }
        
    }
}

module inlet_ring() {
    inlet_dia = larger_diameter + (inlet_distance*linear_ratio);
    assert(inlet_dia < 20);

    // offset is used to use this module for cropping stuff that protrudes out
    module main_cone(radius_offset=0) {
        // outer_radius_offset = radius_offset * 20;
        // difference()
        // {
        //     cylinder(inlet_distance, larger_diameter/2+outer_radius_offset, inlet_dia/2+outer_radius_offset, $fn = 60);
        //     translate([0,0,-0.1])
        //     cylinder(inlet_distance+0.2, (larger_diameter-ring_thickness)/2+radius_offset, (inlet_dia-ring_thickness)/2+radius_offset, $fn = 60);
        // }
        make_cone(height = inlet_distance, diameter = larger_diameter, thickness = ring_thickness, radius_offset = radius_offset);
    }

    module axis_frame_line() {
        // the connection bars
        translate([0,0,-0.01])
        difference()
        {
            // z translation done to make the difference work better
            translate([-larger_diameter/2,-axis_frame_width/2,0.01])
            {
                cube([larger_diameter, axis_frame_width, axis_frame_thickness]);
            }
            // remove the corners protruding out of the cone
            main_cone(0.05);
        }
    }

    module axis_cross() {
        difference()
        {
            union()
            {
                axis_frame_line();
                rotate(90)
                axis_frame_line();
            }
            axis_for_removal(axis_radius, $fn=20);
        }
    }

    // This will be gluet to main cone probably?
    module main_cone_inlet_brim() {
        removal_cylinder_radius = inlet_dia/2-inlet_brim;
        start_position = ring_distance + inlet_distance - inlet_brim;
        translate([0,0, start_position])
        {
            difference()
            {
                cylinder(inlet_brim, inlet_dia/2, inlet_dia/2);
                union()
                {
                    translate([0,0,-0.2])
                    {
                        make_cone(5, pos2diameter(start_position-0.2), 0.3, 0.1);
                        cylinder(inlet_brim+0.7, pos2radius(start_position-0.2), removal_cylinder_radius);
                    }

                }
            }
        }

    }
    difference() 
    {
        union()
        {
            translate([0,0,ring_distance])
            {
                main_cone();
                axis_cross();
            }
            main_cone_inlet_brim();
            for(i = [0:2])
            {
                rotate([0,0,i*120])
                outer_screw_hole(ring_distance, direction = -1);
            }
        }
        // Shear the bottom off to make sure it all sticks to the print plane
        color("red")
        translate([-50,-50,ring_distance-1+0.01]) 
        cube([100, 100, 1]);
    }


}

module outlet_ring() {
    inner_diameter = smaller_diameter + (linear_ratio * outlet_distance);

    // offset is used to use this module for cropping stuff that protrudes out
    module main_cone(radius_offset=0) {
        make_cone(height = outlet_distance, diameter = smaller_diameter, thickness = ring_thickness, radius_offset = radius_offset);
    }

    module axis_frame_line() {
        // the connection bars
        difference()
        {
            // z translation done to make the difference work better
            translate([-inner_diameter/2,-axis_frame_width/2,outlet_distance - axis_frame_thickness])
            {
                cube([inner_diameter, axis_frame_width, axis_frame_thickness]);
            }
            // remove the corners protruding out of the cone
            main_cone(0.05);
        }
    }

    module axis_cross() {
        difference()
        {
            union()
            {
                axis_frame_line();
                rotate(90)
                axis_frame_line();
            }
            axis_for_removal(axis_radius, $fn=20);
        }
    }
    difference()
    {
        union() 
        {
            main_cone();
            axis_cross();

            for(i = [0:2])
            {
                rotate([0,0,i*120])
                outer_screw_hole(outlet_distance-reinforcement_hole_length);
            }
        }
        color("red")
        translate([-50,-50,outlet_distance-0.03]) 
        cube([100, 100, 1]);
    }

}
if(mode == "preview" || mode == "inlet")
{
    inlet_ring($fn=100);
}
if(mode == "preview" || mode == "outlet")
{
    outlet_ring($fn=100);
}
// central axis only visible in preview
if(mode == "preview")
{
    $fn = max(15, $fn);
    axis_length = 65;
    color("black")
    translate([0,0,ring_distance-axis_length])
    cylinder(axis_length, axis_diameter/2-0.1, axis_diameter/2-0.1);
}
if(mode == "preview" || search("stand_", mode) == [0])
{
    $fn = 100;
    // make the planks, rotated by tilt axis
    rotate([-stand_tilt,0,0])
    difference() 
    {
        union() {
            translate([-outlet_plank_width/2, -outlet_plank_height+axis_plank_height,0])
            {
                holder_element_centering_x = outlet_plank_width/2-axis_holder_width/2;
                // currently const
                holder_element_offset_top = 2;
                translate([0,0,-outlet_plank_start])
                {
                    // the anchor that holds the axis
                    translate([holder_element_centering_x,holder_element_offset_top,0])
                    color("red")
                    {
                        translate([0,0,-axis_holder_thickness])
                        cube([axis_holder_width, axis_holder_height, axis_holder_thickness]);
                        translate([0,0,outlet_plank_thickness])
                        cube([axis_holder_width, axis_holder_height, axis_holder_thickness]);
                    }

                    color("brown")
                    cube([outlet_plank_width, outlet_plank_height, outlet_plank_thickness]);
                }
                translate([0,0,-outlet_plank_start-outlet_planks_distance])
                {
                    color("brown")
                    cube([outlet_plank_width, outlet_plank_height, outlet_plank_thickness]);
                }
            }

        }
        rotate([stand_tilt,0,0])
        translate([0,0,-100]) 
        cylinder(200, axis_diameter/2, axis_diameter/2);
    }
}
// t = 35;
// color("red")
// translate([0,0,t])
// cylinder(0.3, pos2radius(t), pos2radius(t+0.3));
// for(i = [0:2])
// {
//     rotate([0,0,i*120])
//     outer_screw_hole(outlet_distance-reinforcement_hole_length);
// }

//color("pink")
//make_cone(total_length, smaller_diameter, thickness = ring_thickness, radius_offset = 0);
// color("pink")
// translate([0,0,singularity_point]) 
// sphere(5);