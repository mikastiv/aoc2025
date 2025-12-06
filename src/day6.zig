const std = @import("std");
const input = @embedFile("input");

const Range = struct { lo: u64, hi: u64 };

const Problem = struct {
    const Op = enum { add, mul };

    numbers: std.ArrayList(u64),
    op: Op,

    fn solve(self: Problem) u64 {
        var result: u64 = 0;

        switch (self.op) {
            .add => for (self.numbers.items) |number| {
                result += number;
            },
            .mul => {
                result = 1;
                for (self.numbers.items) |number| {
                    result *= number;
                }
            },
        }

        return result;
    }
};

pub fn main() !void {
    var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var max_line_len: usize = 0;
    var grid: std.ArrayList([]const u8) = .empty;
    while (lines.next()) |line| {
        try grid.append(allocator, line);
        max_line_len = @max(max_line_len, line.len);
    }
    _ = grid.pop();
    lines.reset();

    const ranges = try buildRanges(allocator, grid.items, max_line_len);

    const problemCount = countTokensScalar(lines.peek().?, ' ');
    var problems1: std.ArrayList(Problem) = .empty;
    var problems2: std.ArrayList(Problem) = .empty;
    try problems1.appendNTimes(allocator, .{ .numbers = .empty, .op = .add }, problemCount);
    try problems2.appendNTimes(allocator, .{ .numbers = .empty, .op = .add }, problemCount);

    while (lines.next()) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        var index: usize = 0;
        while (it.next()) |value| : (index += 1) {
            if (std.ascii.isDigit(value[0])) {
                const number = try std.fmt.parseInt(u64, value, 10);
                try problems1.items[index].numbers.append(allocator, number);
            } else {
                const op: Problem.Op = if (value[0] == '+') .add else .mul;
                problems1.items[index].op = op;
                problems2.items[index].op = op;
            }
        }
    }

    for (ranges, 0..) |range, problem| {
        var number_index: usize = 0;
        for (range.lo..range.hi) |x| {
            const numbers = &problems2.items[problem].numbers;
            try numbers.append(allocator, 0);

            for (0..grid.items.len) |y| {
                if (x >= grid.items[y].len) break;

                const number = std.fmt.charToDigit(grid.items[y][x], 10) catch continue;
                numbers.items[number_index] *= 10;
                numbers.items[number_index] += number;
            }

            number_index += 1;
        }
    }

    var part1: u64 = 0;
    var part2: u64 = 0;
    for (0..problemCount) |index| {
        part1 += problems1.items[index].solve();
        part2 += problems2.items[index].solve();
    }

    std.debug.print("part1: {d}\n", .{part1});
    std.debug.print("part2: {d}\n", .{part2});
}

fn countTokensScalar(text: []const u8, comptime scalar: u8) usize {
    var count: usize = 0;

    var lines = std.mem.tokenizeScalar(u8, text, scalar);
    while (lines.next()) |_| {
        count += 1;
    }

    return count;
}

fn buildRanges(allocator: std.mem.Allocator, grid: []const []const u8, max_line_len: u64) ![]Range {
    var ranges: std.ArrayList(Range) = .empty;

    var lo: u64 = 0;
    for (0..grid[0].len) |x| {
        for (0..grid.len) |y| {
            if (grid[y][x] != ' ') break;
        } else {
            try ranges.append(allocator, .{ .lo = lo, .hi = x });
            lo = x + 1;
        }
    }
    try ranges.append(allocator, .{ .lo = lo, .hi = max_line_len });

    return ranges.items;
}
