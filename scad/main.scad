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

                        color(pixel_color) {
                            translate([row * pixel_size, col * pixel_size, 0]) {
                                cube([pixel_size, pixel_size, z]);
                            }
                        }
                    }
                }
            }
        }
    }
}

// Module: multi_layer_two_point_five_d()
// Description: merges multiple image layers and their height maps, then
//   renders the combined result as a 2.5D model using two_point_five_d().
//   optionally overrides the final height map.
// Arguments:
//   image_layers = list of objects, each with "image" (2D color array) and
//     "height_map" (color-to-height object) keys.
//   override_height_map = optional object to replace the merged height map.
//   pixel_size = size of each pixel cube in X/Y dimensions. default is `1`.
//   center = center the output model on the X/Y plane. default is true.
module multi_layer_two_point_five_d(
    image_layers,
    override_height_map = undef,
    pixel_size = 1,
    center = true,
) {
    assert(is_list(image_layers), "expected a list of input image layers to merge.");
    assert(
        is_undef(additional_layer_offsets) ||
            (is_list(additional_layer_offsets) &&
                len(image_layers) == len(additional_layer_offsets)),
        str("Expected additional layers to be undefined or the a list the same length as the ",
            "number of layers."
        )
    );
    assert(
        is_undef(override_height_map) || is_object(override_height_map),
        "Expected override_height_map to be undefined or an object of color value pairs",
    );
    assert(
        is_num(pixel_size), "Expected pixel size to be a number"
    );

    original_images = [
        for (i = [0 : len(image_layers) - 1])
            if (!is_undef(image_layers[i])) image_layers[i]["image"]
    ];

    original_height_maps = [
        for (i = [0 : len(image_layers) - 1])
            if (!is_undef(image_layers[i])) image_layers[i]["height_map"]
    ];

    final_image = _merge_image(original_images);
    final_height_map = is_undef(override_height_map) ? _merge_height_maps(original_height_maps) :
        override_height_map;

    two_point_five_d(
        final_image,
        final_height_map,
        pixel_size = pixel_size,
        center = center,
    );
}

function _merge_cells(remaining_cells, current_cell_val = undef) =
    len(remaining_cells) == 0 ? current_cell_val :
        !is_undef(current_cell_val) ? current_cell_val :
            _merge_cells(
                [ for (i = [0 : len(remaining_cells) - 2]) remaining_cells[i]],
                remaining_cells[len(remaining_cells) - 1]
            );



function _merge_rows(remaining_rows, current_row_value = undef) =
    len(remaining_rows) == 0 ? current_row_value :
    current_row_value == undef ? _merge_rows(
        [for (i = [1:len(remaining_rows)-1]) remaining_rows[i]],
        remaining_rows[0]
    ) :
    _merge_rows(
        [for (i = [1:len(remaining_rows)-1]) remaining_rows[i]],
        [
            for (i = [0:len(current_row_value)-1]) _merge_cells(
                [current_row_value[i],
                remaining_rows[0][i]]
            )
        ]
    );

function _merge_image(remaining_image, current_image_value = undef) =
    len(remaining_image) == 0
        ? current_image_value
        : is_undef(current_image_value)
            ? _merge_image(
                [for (i = [1 : len(remaining_image) - 1]) remaining_image[i]],
                remaining_image[0]
              )
            : _merge_image(
                [for (i = [1 : len(remaining_image) - 1]) remaining_image[i]],
                [for (i = [0 : len(current_image_value) - 1])
                    _merge_rows([current_image_value[i], remaining_image[0][i]])
                ]
              );

function _merge_height_maps(height_maps, current_map = undef) =
    len(height_maps) == 0
        ? current_map
        : is_undef(current_map)
            ? _merge_height_maps(
                [for (i = [1:len(height_maps)-1]) height_maps[i]],
                height_maps[0]
              )
            : _merge_height_maps(
                [for (i = [1:len(height_maps)-1]) height_maps[i]],
                _merge_objects(current_map, height_maps[0])
              );

function _merge_objects(map1, map2) =
    let (
        pairs2 = [for (k = map2) [k, map2[k]]],
        pairs1_unique = [for (k = map1)
            if (!has_key(map2, k))
                [k, map1[k]]],
        combined = concat(pairs1_unique, pairs2)
    )
    object(combined);
