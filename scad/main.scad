// Module: two_point_five_d()
// Description: iterates over a 2D grid of color strings, looks up each color in the height map,
//   and renders a colored cube at the corresponding (x, y, z) position. pixels with an
//   undefined color are skipped.
// Arguments:
//   image_array = 2D list of color strings representing the pixel grid.
//   height_map = object mapping color strings to Z-axis extrusion heights.
//   pixel_size = size of each pixel cube in X/Y dimensions. default is `1`.
//   center = center the output model on the X/Y plane. default is true
module two_point_five_d(image_array, height_map, pixel_size = 1, center = true) {
    assert(is_object(height_map), "Expected height map to be an object");
    assert(is_list(image_array), "Expected image array definition to be a list");
    assert(is_num(pixel_size), "pixel_size argument should be a number");

    x_trans = center ? -len(image_array[0]) / 2 * pixel_size: 0;
    y_trans = center ? -len(image_array) / 2 * pixel_size: 0;

    translate([x_trans, y_trans, 0]) {
        mirror([0, 1, 0]) {
            translate([0, -len(image_array) * pixel_size, 0])
            for (col = [0 : len(image_array) - 1]) {
                for (row = [0 : len(image_array[col]) - 1]) {
                    pixel_color = image_array[col][row];

                    if (pixel_color != undef) {
                        z = height_map[pixel_color];

                        _draw_pixel(
                            pixel_size = pixel_size,
                            pixel_color = pixel_color,
                            extrude_length = z,
                            x_trans_pixels = row,
                            y_trans_pixels = col
                        );
                    }
                }
            }
        }
    }
}

// Module: multi_layer_two_point_five_d()
// Description: takes a list of layers and merges them to a single image. for each layer the pixel
//   that is drawn is the "top" layer (last pixel in the list at that layer that is not undefined).
//   the height map from the layer the pixel is chosen is the one that is used to determine the
//   extrusion height of the pixel. an additional layer offset can be applied by providing a list
//   of offsets for each layer.
// Arguments:
//   image_layers = list of objects, each with "image" (2D color array) and
//     "height_map" (color-to-height object) keys.
//   layer_offsets = a list of heights to offset each layer. if no list is provided then no offsets
//     are applied. default is undefined.
//   pixel_size = size of each pixel cube in X/Y dimensions. default is `1`.
//   center = center the output model on the X/Y plane. default is true.
module multi_layer_two_point_five_d(
    image_layers,
    layer_offsets = undef,
    pixel_size = 1,
    center = true,
) {
    assert(is_list(image_layers), "expected a list of input image layers to merge.");
    assert(
        is_undef(layer_offsets) ||
            (is_list(layer_offsets) &&
                len(image_layers) == len(layer_offsets)),
        str("Expected layer offsets to be undefined or the a list the same length as the ",
            "number of layers."
        )
    );
    assert(
        is_num(pixel_size), "Expected pixel size to be a number"
    );

    height_maps = [
        for (i = [0 : len(image_layers) - 1])
            if (!is_undef(image_layers[i])) image_layers[i]["height_map"]
    ];

    layers = [
        for (i = [0 : len(image_layers) - 1])
            if (!is_undef(image_layers[i])) image_layers[i]["image"]
    ];

    columns = len(layers[0]) - 1;
    rows = len(layers[0][0]) - 1;


    x_trans = center ? -rows / 2 * pixel_size: 0;
    y_trans = center ? -columns / 2 * pixel_size: 0;

    translate([x_trans, y_trans, 0]) {
        mirror([0, 1, 0]) {
            translate([0, -columns * pixel_size, 0]) {
                for (col = [0 : columns]) {
                    for (row = [0 : rows]) {
                        cells_in_index = [ for (i = [0 : len(layers) - 1]) layers[i][col][row]];
                        layer_index = _get_layer_index(cells_in_index, len(cells_in_index) - 1);

                        pixel_color = cells_in_index[layer_index];

                        if (pixel_color != undef) {
                            z = height_maps[layer_index][pixel_color];
                            z_offset = is_undef(layer_offsets) ? 0 : layer_offsets[image_index];

                            _draw_pixel(
                                pixel_size = pixel_size,
                                pixel_color = pixel_color,
                                extrude_length = z + z_offset,
                                x_trans_pixels = row,
                                y_trans_pixels = col
                            );
                        }
                    }
                }
            }
        }
    }
}

function _get_layer_index(cells_at_index, layer_index) =
    layer_index == 0 ? layer_index :
        !is_undef(cells_at_index[layer_index]) ? layer_index :
            _get_layer_index(cells_at_index, layer_index - 1);

module _draw_pixel(pixel_size, pixel_color, extrude_length, x_trans_pixels, y_trans_pixels) {
    x_trans = pixel_size * x_trans_pixels;
    y_trans = pixel_size * y_trans_pixels;

    color(pixel_color) {
        translate([x_trans, y_trans, 0]) {
            cube([pixel_size, pixel_size, extrude_length]);
        }
    }
}
