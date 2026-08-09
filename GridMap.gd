extends Node2D

const GRID_SIZE := 10
const TILE_SIZE := Vector2(64, 32)
const HALF_TILE := TILE_SIZE * 0.5
const TILE_EMPTY := 0
const TILE_ROAD := 1
const TILE_RESIDENTIAL := 2
const TILE_COMMERCIAL := 3
const TILE_INDUSTRIAL := 4

var tile_map: Array = []
var selected_cell: Vector2 = Vector2(-1, -1)
var build_mode: int = TILE_ROAD

func _ready() -> void:
    _reset_tile_map()
    queue_redraw()

func _process(delta: float) -> void:
    queue_redraw()

func _reset_tile_map() -> void:
    tile_map.resize(GRID_SIZE)
    for x in range(GRID_SIZE):
        tile_map[x] = []
        tile_map[x].resize(GRID_SIZE)
        for y in range(GRID_SIZE):
            tile_map[x][y] = TILE_EMPTY

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        _select_cell(event.position)
    elif event is InputEventScreenTouch and event.pressed:
        _select_cell(event.position)

func _draw() -> void:
    draw_tiles()
    draw_grid()
    draw_selection()

func draw_grid() -> void:
    var line_color = Color(1, 1, 1, 0.8)
    var thickness = 2.0

    for y in range(GRID_SIZE + 1):
        var start = map_to_iso(Vector2(0, y))
        var end = map_to_iso(Vector2(GRID_SIZE, y))
        draw_line(start, end, line_color, thickness)

    for x in range(GRID_SIZE + 1):
        var start = map_to_iso(Vector2(x, 0))
        var end = map_to_iso(Vector2(x, GRID_SIZE))
        draw_line(start, end, line_color, thickness)

func draw_tiles() -> void:
    for x in range(GRID_SIZE):
        for y in range(GRID_SIZE):
            var tile_type = tile_map[x][y]
            if tile_type != TILE_EMPTY:
                var colors = _get_tile_colors(tile_type)
                if colors.size() > 0:
                    _draw_tile_cell(Vector2(x, y), colors.fill, colors.outline)

func _get_tile_colors(tile_type: int) -> Dictionary:
    match tile_type:
        TILE_ROAD:
            return {"fill": Color(0.2, 0.2, 0.2, 0.75), "outline": Color(0.8, 0.7, 0.4, 0.9)}
        TILE_RESIDENTIAL:
            return {"fill": Color(0.2, 0.8, 0.2, 0.35), "outline": Color(0.1, 0.6, 0.1, 0.9)}
        TILE_COMMERCIAL:
            return {"fill": Color(0.2, 0.5, 1.0, 0.35), "outline": Color(0.1, 0.3, 0.8, 0.9)}
        TILE_INDUSTRIAL:
            return {"fill": Color(0.95, 0.8, 0.2, 0.35), "outline": Color(0.8, 0.65, 0.1, 0.9)}
        _:
            return {}

func _draw_tile_cell(cell: Vector2, fill_color: Color, outline_color: Color) -> void:
    var top = map_to_iso(cell)
    var right = map_to_iso(cell + Vector2(1, 0))
    var bottom = map_to_iso(cell + Vector2(1, 1))
    var left = map_to_iso(cell + Vector2(0, 1))
    var polygon = [top, right, bottom, left]
    draw_colored_polygon(polygon, fill_color)
    draw_polyline(polygon + [top], outline_color, 2.0)

func draw_selection() -> void:
    if selected_cell.x < 0 or selected_cell.y < 0:
        return
    if selected_cell.x >= GRID_SIZE or selected_cell.y >= GRID_SIZE:
        return

    var top = map_to_iso(selected_cell)
    var right = map_to_iso(selected_cell + Vector2(1, 0))
    var bottom = map_to_iso(selected_cell + Vector2(1, 1))
    var left = map_to_iso(selected_cell + Vector2(0, 1))
    var polygon = [top, right, bottom, left]

    draw_colored_polygon(polygon, Color(0.0, 0.7, 1.0, 0.25))
    draw_polyline(polygon + [top], Color(0.0, 0.7, 1.0, 0.8), 2.0)

func _select_cell(screen_pos: Vector2) -> void:
    var local_pos = to_local(screen_pos)
    var iso_pos = screen_to_iso(local_pos)
    var cell = Vector2(floor(iso_pos.x), floor(iso_pos.y))

    if cell.x >= 0 and cell.y >= 0 and cell.x < GRID_SIZE and cell.y < GRID_SIZE:
        selected_cell = cell
        tile_map[cell.x][cell.y] = build_mode
    else:
        selected_cell = Vector2(-1, -1)

    queue_redraw()

func _on_RoadButton_pressed() -> void:
    build_mode = TILE_ROAD

func _on_ResidentialButton_pressed() -> void:
    build_mode = TILE_RESIDENTIAL

func _on_CommercialButton_pressed() -> void:
    build_mode = TILE_COMMERCIAL

func _on_IndustrialButton_pressed() -> void:
    build_mode = TILE_INDUSTRIAL

func map_to_iso(map_pos: Vector2) -> Vector2:
    return Vector2(
        (map_pos.x - map_pos.y) * HALF_TILE.x,
        (map_pos.x + map_pos.y) * HALF_TILE.y
    )

func screen_to_iso(screen_pos: Vector2) -> Vector2:
    var local_pos = screen_pos - map_to_iso(Vector2(0, 0))
    var x = (local_pos.x / HALF_TILE.x + local_pos.y / HALF_TILE.y) * 0.5
    var y = (local_pos.y / HALF_TILE.y - local_pos.x / HALF_TILE.x) * 0.5
    return Vector2(x, y)
