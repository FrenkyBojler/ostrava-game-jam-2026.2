class_name FlagsGridUtils
extends RefCounted

## For a multi-select grid (FlagsGridProperty): returns every (x, y)
## whose bit is set in `mask`, given the grid's column count.
static func get_set_coords(mask: int, columns: int) -> Array[Vector2]:
	var coords: Array[Vector2] = []
	for i in 32:
		if mask & (1 << i):
			coords.append(Vector2(i % columns, i / columns))
	return coords

## For a multi-select grid: check a single cell.
static func is_cell_set(mask: int, x: int, y: int, columns: int) -> bool:
	var bit := 1 << (y * columns + x)
	return (mask & bit) != 0

## For a multi-select grid: set/clear a single cell, returns the new mask.
static func set_cell(mask: int, x: int, y: int, columns: int, value: bool) -> int:
	var bit := 1 << (y * columns + x)
	return (mask | bit) if value else (mask & ~bit)

## For a radio grid (FlagsGridRadioProperty): returns the single selected
## (x, y), or Vector2(-1, -1) if nothing is selected (value == 0).
static func get_selected_coord(value: int, columns: int) -> Vector2:
	if value == 0:
		return Vector2(-1, -1)
	for i in 32:
		if value == (1 << i):
			return Vector2(i % columns, i / columns)
	return Vector2(-1, -1)

## For a radio grid: returns the bit value to assign for a given (x, y),
## e.g. `my_selected_cell = FlagsGridUtils.coord_to_value(1, 2, 3)`.
static func coord_to_value(x: int, y: int, columns: int) -> int:
	return 1 << (y * columns + x)

## Rotates a square (n x n) grid mask 90 degrees clockwise ("to the right").
static func rotate_mask_cw(mask: int, n: int) -> int:
	var new_mask := 0
	for y in n:
		for x in n:
			if mask & (1 << (y * n + x)):
				var new_x := n - 1 - y
				var new_y := x
				new_mask |= 1 << (new_y * n + new_x)
	return new_mask

## Rotates a square (n x n) grid mask 90 degrees counter-clockwise ("to the left").
static func rotate_mask_ccw(mask: int, n: int) -> int:
	var new_mask := 0
	for y in n:
		for x in n:
			if mask & (1 << (y * n + x)):
				var new_x := y
				var new_y := n - 1 - x
				new_mask |= 1 << (new_y * n + new_x)
	return new_mask
