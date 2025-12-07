const std = @import("std");
const input = @embedFile("input");

const Pos = struct { x: usize, y: usize };

pub fn main() !void {
    var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var grid: std.ArrayList([]const u8) = .empty;

    const start = std.mem.indexOfScalar(u8, lines.next().?, 'S').?;
    while (lines.next()) |line| {
        try grid.append(allocator, line);
    }

    var prev_beams: std.AutoHashMap(usize, void) = .init(allocator);
    var next_beams: std.AutoHashMap(usize, void) = .init(allocator);

    try prev_beams.put(start, {});

    var part1: usize = 0;
    for (grid.items) |line| {
        var it = prev_beams.keyIterator();
        while (it.next()) |beam| {
            if (line[beam.*] == '^') {
                try next_beams.put(beam.* - 1, {});
                try next_beams.put(beam.* + 1, {});
                part1 += 1;
            } else {
                try next_beams.put(beam.*, {});
            }
        }

        std.mem.swap(std.AutoHashMap(usize, void), &prev_beams, &next_beams);
        next_beams.clearRetainingCapacity();
    }

    var cache: std.AutoHashMap(Pos, usize) = .init(allocator);
    const part2 = try countTimelines(&cache, grid.items, start, 0);

    std.debug.print("part1: {d}\n", .{part1});
    std.debug.print("part2: {d}\n", .{part2});
}

fn countTimelines(
    cache: *std.AutoHashMap(Pos, usize),
    grid: []const []const u8,
    x: usize,
    y: usize,
) !usize {
    const pos: Pos = .{ .x = x, .y = y };

    if (y == grid.len) return 1;
    if (cache.get(pos)) |result| return result;

    if (grid[y][x] == '^') {
        const left = try countTimelines(cache, grid, x - 1, y + 1);
        const right = try countTimelines(cache, grid, x + 1, y + 1);

        const result = left + right;
        try cache.put(pos, result);

        return result;
    }

    const result = try countTimelines(cache, grid, x, y + 1);
    try cache.put(pos, result);

    return result;
}
