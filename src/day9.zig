const std = @import("std");
const input = @embedFile("input");

const Vec2 = @Vector(2, i64);

const Segment = struct {
    start: Vec2,
    end: Vec2,
};

const Rect = struct {
    left: i64,
    right: i64,
    top: i64,
    bottom: i64,
    area: i64,

    fn greaterThan(_: void, a: Rect, b: Rect) bool {
        return a.area > b.area;
    }
};

pub fn main() !void {
    var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var tiles: std.ArrayList(Vec2) = .empty;
    while (lines.next()) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ',');
        const x = try std.fmt.parseInt(i32, it.next().?, 10);
        const y = try std.fmt.parseInt(i32, it.next().?, 10);
        try tiles.append(allocator, .{ x, y });
    }

    var segments: std.ArrayList(Segment) = .empty;
    for (tiles.items, 0..) |_, i| {
        const a = tiles.items[i];
        const b = tiles.items[(i + 1) % tiles.items.len];

        const x1 = @min(a[0], b[0]);
        const x2 = @max(a[0], b[0]);
        const y1 = @min(a[1], b[1]);
        const y2 = @max(a[1], b[1]);

        try segments.append(allocator, .{ .start = .{ x1, y1 }, .end = .{ x2, y2 } });
    }

    var rectangles: std.ArrayList(Rect) = .empty;
    for (tiles.items[0 .. tiles.items.len - 1], 0..) |a, i| {
        for (tiles.items[i + 1 ..]) |b| {
            const x1 = @min(a[0], b[0]);
            const x2 = @max(a[0], b[0]);
            const y1 = @min(a[1], b[1]);
            const y2 = @max(a[1], b[1]);

            const width = x2 - x1 + 1;
            const height = y2 - y1 + 1;
            const area = width * height;

            try rectangles.append(allocator, .{ .left = x1, .right = x2, .top = y1, .bottom = y2, .area = area });
        }
    }

    std.mem.sortUnstable(Rect, rectangles.items, {}, Rect.greaterThan);

    const part1 = rectangles.items[0].area;

    var part2: i64 = 0;
    loop: for (rectangles.items) |rect| {
        // check if any segments go through the rectangle
        for (segments.items) |segment| {
            const is_left = rect.right <= segment.start[0];
            const is_right = rect.left >= segment.end[0];
            const is_above = rect.bottom <= segment.start[1];
            const is_below = rect.top >= segment.end[1];
            if (!(is_left or is_right or is_above or is_below)) {
                continue :loop;
            }
        }

        part2 = rect.area;
        break;
    }

    std.debug.print("part1: {d}\n", .{part1});
    std.debug.print("part2: {d}\n", .{part2});
}
