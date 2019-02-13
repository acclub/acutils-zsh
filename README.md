
## Batch generation of clean windscreens
1. Make sure Cygwin is installed
1. Remember that zsh and zip extensions need to be installed as well
1. Node.js must also be installed, and added to your path (https://medium.com/@WWWillems/how-to-install-cygwin-node-js-npm-and-webpack-for-windows-7-c061443653d3)
1. Place ac-fix-windscreen.zsh in your assetto corsa cards directory 
1. Run these commands in cygwin to recursively generate all windshield files for all cars: 
1. $ cd '/cygdrive/c/Program Files (x86)/Steam/steamapps/common/assettocorsa/content/cars'
1. $ find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && zsh ./../ac-fix-windscreen.zsh -t /tmp/clean_windscreen -o clean-windshields ." \;
1. Place the generated files in the appropriate car subfolders (or use a content manager)
