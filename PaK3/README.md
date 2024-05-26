# PaK3
paks yer pk3
## Usage
```
node main.js path/to/data/ output.pk3
#Run a program after packing
node main.js path/to/data/ output.pk3 -p path/to/doomgame
node main.js path/to/data/ output.pk3 --program path/to/doomgame
#Pass arguments to that program
node main.js path/to/data/ output.pk3 -p doomgame -e -warp MAP01 ...
node main.js path/to/data/ output.pk3 -p doomgame --extra ...
```
## Data folder structure
- Folders always go first, and cannot be ordered.
- S_SKIN lumps will always go before other lumps.
- There is not yet a way to specify a custom order.
- PNGs will be converted.
  The offset for the PNG wll come from its comment (it will take the first two numbers in the comment), or, lacking that, default to the center of the sprite.
  You can add this comment in GIMP with Alt+Enter -> Comment

## Exceptions
- XTRAA0 and XTRAB0 will have the default offset at 0, 0

## todo
- Compress images by identical columns and cropping
- add a way to have the order your way