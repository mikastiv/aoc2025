const std = @import("std");
const input = @embedFile("input");

const Range = struct {
    start: u64,
    end: u64,

    fn lessThan(_: void, a: Range, b: Range) bool {
        return a.start < b.start;
    }

    fn contains(self: Range, value: u64) bool {
        return value >= self.start and value <= self.end;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var it = std.mem.tokenizeSequence(u8, input, "\n\n");
    var ranges_it = std.mem.tokenizeScalar(u8, it.next().?, '\n');
    var ingredients_it = std.mem.tokenizeScalar(u8, it.next().?, '\n');

    var ranges: std.ArrayList(Range) = .empty;
    while (ranges_it.next()) |range| {
        var split = std.mem.tokenizeScalar(u8, range, '-');
        const start = try std.fmt.parseInt(u64, split.next().?, 10);
        const end = try std.fmt.parseInt(u64, split.next().?, 10);
        try ranges.append(allocator, .{ .start = start, .end = end });
    }

    var ingredients: std.ArrayList(u64) = .empty;
    while (ingredients_it.next()) |ingredient| {
        const n = try std.fmt.parseInt(u64, ingredient, 10);
        try ingredients.append(allocator, n);
    }

    std.mem.sortUnstable(Range, ranges.items, {}, Range.lessThan);

    // merge overlapping ranges
    var i: usize = 0;
    while (i < ranges.items.len - 1) {
        const r0 = &ranges.items[i];
        const r1 = &ranges.items[i + 1];

        if (r0.end >= r1.start) {
            if (r0.end < r1.end) r0.end = r1.end;
            _ = ranges.orderedRemove(i + 1);
            continue;
        }

        i += 1;
    }

    var part1: u64 = 0;
    for (ingredients.items) |id| {
        for (ranges.items) |range| {
            if (range.contains(id)) part1 += 1;
        }
    }

    var part2: u64 = 0;
    for (ranges.items) |range| {
        part2 += range.end - range.start + 1;
    }

    std.debug.print("part1: {d}\n", .{part1});
    std.debug.print("part2: {d}\n", .{part2});
}
