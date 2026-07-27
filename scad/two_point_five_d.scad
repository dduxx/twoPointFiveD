// Module: two_point_five_d()
// Description: iterates over a 2D grid of color strings, looks up each color in the height map,
//   and renders a colored cube at the corresponding (x, y, z) position. pixels with an
//   undefined color are skipped.
// Arguments:
//   image_array = 2D list of color strings representing the pixel grid.
//   height_map = object mapping color strings to Z-axis extrusion heights.
//   pixel_size = size of each pixel cube in X/Y dimensions. default is `1`.
module two_point_five_d(image_array, height_map, pixel_size = 1) {
    assert(is_object(height_map), "Expected height map to be an object");
    assert(is_list(image_array), "Expected image array definition to be a list");
    assert(is_num(pixel_size), "pixel_size argument should be a number");

    for (col = [0 : len(image_array) - 1]) {
        for (row = [0 : len(image_array[col]) - 1]) {
            pixel_color = image_array[col][row];

            if (pixel_color != undef) {
                z = height_map[pixel_color];

                color(pixel_color) {
                    translate([col * pixel_size, row * pixel_size, 0]) {
                        cube([pixel_size, pixel_size, z]);
                    }
                }
            }
        }
    }
}
