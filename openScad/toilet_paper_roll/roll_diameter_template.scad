spool_diameter = 46;
spool_radius = spool_diameter/2;
template_height = 2;
handle_radius = 10;
handle_height = 15;

cylinder(template_height, spool_radius, spool_radius);
cylinder(template_height + handle_height, handle_radius, handle_radius);   