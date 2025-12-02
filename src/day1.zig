const std = @import("std");
const input = @embedFile("input");

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var current: i32 = 50;
    var part1: u32 = 0;
    var part2: u32 = 0;

    while (lines.next()) |line| {
        const direction = line[0];
        const rotations = try std.fmt.parseInt(i32, line[1..], 10);

        var next = current;
        if (direction == 'L') {
            next -= rotations;
        } else {
            next += rotations;
        }

        part2 += @abs(next) / 100;
        if (next == 0 or (next < 0 and current != 0)) {
            part2 += 1;
        }

        current = @mod(next, 100);
        if (current == 0) {
            part1 += 1;
        }
    }

    std.debug.print("part 1: {d}\n", .{part1});
    std.debug.print("part 2: {d}\n", .{part2});
}
