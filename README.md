# twoPointFiveD

An OpenSCAD library for creating 2.5D models from a 2D pixel grid and a color-to-height mapping.

Each color string in the image array gets extruded to its corresponding Z height, producing a 3D
model for printing.

## Usage

```openscad
include <two_point_five_d.scad>

height_map = ["red": 5, "blue": 10, "green": 3];

image_array = [
    ["red",   "blue",  "red"],
    ["blue",  "green", "blue"],
    ["red",   "blue",  "red"]
];

two_point_five_d(image_array, height_map, pixel_size = 1);
```

- `image_array` - 2D list of color strings (rows × columns).
- `height_map` - object mapping color strings to Z-axis extrusion heights.
- `pixel_size` - size of each cube in X/Y (default `1`).

Pixels set to `undef` are skipped, allowing for gaps or irregular shapes.

## Additional Notes

This project is meant to be used as a supporting library to other projects. it can be imported
easily using the [buildscad](https://github.com/dduxx/buildscad) dependency manager and build tool.
