const std = @import("std");
const input = @embedFile("input");

const Machine = struct {
    lights: u16,
    lights_count: u16,
    buttons: []const u16,
    joltages: []const u16,
};

pub fn main() !void {
    var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var machines: std.ArrayList(Machine) = .empty;
    while (lines.next()) |line| {
        var lights: u16 = 0;
        var light_count: u4 = 0;
        const lights_slice = std.mem.sliceTo(line, ' ');
        {
            const trim = std.mem.trim(u8, lights_slice, "[]");
            for (trim) |char| {
                lights <<= 1;
                lights |= if (char == '#') 1 else 0;
                light_count += 1;
            }
        }

        var buttons: std.ArrayList(u16) = .empty;
        const buttons_slice = line[lights_slice.len..std.mem.sliceTo(line, '{').len];
        {
            var it = std.mem.tokenizeScalar(u8, buttons_slice, ' ');
            while (it.next()) |str| {
                const trim = std.mem.trim(u8, str, "()");
                var nums = std.mem.tokenizeScalar(u8, trim, ',');
                var button: u16 = 0;
                while (nums.next()) |num| {
                    const bit = try std.fmt.parseInt(u4, num, 10);
                    button |= @as(u16, 1) << (light_count - bit - 1);
                }

                try buttons.append(allocator, button);
            }
        }

        var joltages: std.ArrayList(u16) = .empty;
        const joltages_slice = line[std.mem.sliceTo(line, '{').len..];
        {
            const trim = std.mem.trim(u8, joltages_slice, "{}");
            var it = std.mem.tokenizeScalar(u8, trim, ',');
            while (it.next()) |joltage| {
                try joltages.append(allocator, try std.fmt.parseInt(u16, joltage, 10));
            }
        }

        try machines.append(allocator, .{
            .lights = lights,
            .lights_count = light_count,
            .buttons = buttons.items,
            .joltages = joltages.items,
        });
    }

    var part1: usize = 0;
    loop: for (machines.items) |machine| {
        var states: std.AutoArrayHashMap(u16, void) = .init(allocator);
        var new_states: std.AutoArrayHashMap(u16, void) = .init(allocator);

        try states.put(0, {});

        var count: usize = 0;
        while (true) {
            count += 1;

            for (states.keys()) |key| {
                for (machine.buttons) |button| {
                    const state = key ^ button;
                    try new_states.put(state, {});
                }
            }

            for (new_states.keys()) |key| {
                try states.put(key, {});
            }
            new_states.clearRetainingCapacity();

            if (states.contains(machine.lights)) {
                part1 += count;
                continue :loop;
            }
        }
    }

    std.debug.print("part1: {d}\n", .{part1});
}
