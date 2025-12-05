const std = @import("std");
const input = @embedFile("input");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var grid: std.ArrayList([]u8) = .empty;
    while (lines.next()) |line| {
        try grid.append(allocator, try allocator.dupe(u8, line));
    }

    var part1: usize = 0;
    var part2: usize = 0;

    var run: usize = 0;
    var removed: usize = 1;
    while (removed > 0) : (run += 1) {
        removed = 0;

        for (0..grid.items.len) |y| {
            for (0..grid.items[0].len) |x| {
                if (grid.items[y][x] != '@') continue;

                const x_start = x -| 1;
                const x_end = @min(x + 1, grid.items[0].len - 1);
                const y_start = y -| 1;
                const y_end = @min(y + 1, grid.items.len - 1);

                var rolls: usize = 0;
                for (y_start..y_end + 1) |k| {
                    for (x_start..x_end + 1) |j| {
                        if (k == y and j == x) continue;
                        rolls += @intFromBool(grid.items[k][j] == '@');
                    }
                }

                if (rolls < 4) {
                    if (run == 0) part1 += 1;

                    grid.items[y][x] = '.';
                    removed += 1;
                }
            }
        }

        part2 += removed;
    }

    std.debug.print("part1: {d}\n", .{part1});
    std.debug.print("part2: {d}\n", .{part2});
}
