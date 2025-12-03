const std = @import("std");
const input = @embedFile("input");

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var part1: usize = 0;
    var part2: usize = 0;

    while (lines.next()) |line| {
        part1 += try maxJoltage(line, 2);
        part2 += try maxJoltage(line, 12);
    }

    std.debug.print("part1: {d}\n", .{part1});
    std.debug.print("part2: {d}\n", .{part2});
}

fn maxJoltage(batteries: []const u8, remaining: usize) !usize {
    if (remaining == 0) return 0;

    const slice = batteries[0 .. batteries.len - (remaining - 1)];
    const index = std.mem.indexOfMax(u8, slice);
    const jolts = try std.fmt.charToDigit(batteries[index], 10);
    const power = std.math.pow(usize, 10, remaining - 1);

    return jolts * power + try maxJoltage(batteries[index + 1 ..], remaining - 1);
}

test "jolts" {
    try std.testing.expectEqual(987654321111, try maxJoltage("987654321111111", 12));
    try std.testing.expectEqual(98, try maxJoltage("987654321111111", 2));
}
