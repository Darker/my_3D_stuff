openscad -o inlet.stl -D "mode=\"inlet\"" -D "$fn=300" autosieve.scad
openscad -o outlet.stl -D "mode=\"outlet\"" -D "$fn=300" autosieve.scad
openscad -o autosieve.png -D "$fn=300" --autocenter --viewall --imgsize 1000,1000 autosieve.scad