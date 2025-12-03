const std = @import("std");
const input = @embedFile("input");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var ranges = std.mem.tokenizeScalar(u8, std.mem.trim(u8, input, "\n"), ',');
    var part1: usize = 0;
    var part2: usize = 0;

    var hashset = std.AutoHashMap(usize, void).init(allocator);

    while (ranges.next()) |range| {
        const first = std.mem.sliceTo(range, '-');
        const second = range[first.len + 1 ..];

        const id_0 = try std.fmt.parseInt(usize, first, 10);
        const id_n = try std.fmt.parseInt(usize, second, 10);

        id_loop: for (id_0..id_n + 1) |id| {
            const digits = std.math.log10_int(id) + 1;

            pattern_loop: for (2..digits + 1) |repeat_count| {
                const pattern_len = digits / repeat_count;
                if (digits % repeat_count != 0) continue;

                const power = std.math.pow(usize, 10, pattern_len);
                const a = id % power;

                if (a == 0) continue;

                for (0..repeat_count - 1) |n| {
                    const divisor = power * std.math.pow(usize, 10, n * pattern_len);
                    const id_part = id / divisor;
                    const b = id_part % power;
                    if (a != b) continue :pattern_loop;
                }

                if (hashset.contains(id)) continue :id_loop;

                if (repeat_count == 2) part1 += id;
                part2 += id;

                try hashset.put(id, {});
            }
        }
    }

    std.debug.print("part 1: {d}\n", .{part1});
    std.debug.print("part 2: {d}\n", .{part2});
}
