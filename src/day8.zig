const std = @import("std");
const input = @embedFile("input");

const Vec3 = @Vector(3, i64);

const Circuit = std.ArrayList(Vec3);

const Connection = struct {
    a: Vec3,
    b: Vec3,
    distance_sq: i64,
};

pub fn main() !void {
    var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var junction_boxes: std.ArrayList(Vec3) = .empty;

    while (lines.next()) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ',');
        const x = try std.fmt.parseInt(i32, it.next().?, 10);
        const y = try std.fmt.parseInt(i32, it.next().?, 10);
        const z = try std.fmt.parseInt(i32, it.next().?, 10);
        try junction_boxes.append(allocator, .{ x, y, z });
    }

    var connections: std.ArrayList(Connection) = .empty;
    for (junction_boxes.items, 0..) |box_a, i| {
        if (i == junction_boxes.items.len - 1) break;

        for (junction_boxes.items[i + 1 ..]) |box_b| {
            const dist_sq = distanceSq(box_a, box_b);
            const connection: Connection = .{ .a = box_a, .b = box_b, .distance_sq = dist_sq };
            try connections.append(allocator, connection);
        }
    }

    std.mem.sortUnstable(Connection, connections.items, {}, lessThanConnection);

    var circuits: std.ArrayList(Circuit) = .empty;
    var part1: usize = 1;
    var last_connection: Connection = undefined;
    for (connections.items, 0..) |connection, count| {
        if (count == 1000) {
            std.mem.sortUnstable(Circuit, circuits.items, {}, greaterThanCircuits);
            for (circuits.items[0..3]) |circuit| {
                part1 *= circuit.items.len;
            }
        }

        const circuit_a = findCircuit(circuits.items, connection.a);
        const circuit_b = findCircuit(circuits.items, connection.b);

        last_connection = connection;

        if (circuit_a == null and circuit_b == null) {
            var new: Circuit = .empty;
            try new.append(allocator, connection.a);
            try new.append(allocator, connection.b);
            try circuits.append(allocator, new);
        } else if (circuit_a != null and circuit_b != null) {
            if (circuit_a.? == circuit_b.?) continue;
            const a = &circuits.items[circuit_a.?];
            const b = &circuits.items[circuit_b.?];
            try a.appendSlice(allocator, b.items);
            _ = circuits.orderedRemove(circuit_b.?);
        } else if (circuit_a) |a| {
            try circuits.items[a].append(allocator, connection.b);
        } else if (circuit_b) |b| {
            try circuits.items[b].append(allocator, connection.a);
        }

        if (circuits.items[0].items.len == junction_boxes.items.len) break;
    }

    std.debug.print("part1: {d}\n", .{part1});
    std.debug.print("part2: {d}\n", .{last_connection.a[0] * last_connection.b[0]});
}

fn distanceSq(a: Vec3, b: Vec3) i64 {
    const v = b - a;
    return @reduce(.Add, v * v);
}

fn findCircuit(circuits: []Circuit, pos: Vec3) ?usize {
    for (circuits, 0..) |circuit, index| {
        for (circuit.items) |junction| {
            if (@reduce(.And, junction == pos)) return index;
        }
    }

    return null;
}

fn containsConnection(connections: []Connection, connection: Connection) bool {
    for (connections) |c| {
        if (c.distance_sq != connection.distance_sq) continue;

        const a_eql = @reduce(.And, c.a == connection.a);
        const b_eql = @reduce(.And, c.b == connection.b);
        if ((a_eql and b_eql) or (!a_eql and !b_eql)) return true;
    }

    return false;
}

fn greaterThanCircuits(_: void, a: Circuit, b: Circuit) bool {
    return a.items.len > b.items.len;
}

fn lessThanConnection(_: void, a: Connection, b: Connection) bool {
    return a.distance_sq < b.distance_sq;
}
