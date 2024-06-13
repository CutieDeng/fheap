const std = @import("std");

const fheap = @import("fheap"); 

const Order = std.math.Order; 

pub fn i32cmp(_: void, a: i32, b: i32) Order {
    return std.math.order(a, b); 
}

pub fn main() !void {

    const allocator = std.heap.c_allocator; 
    const buffer: []i32 = try allocator.alloc(i32, 32); 
    for (0..32) |v| {
        const vi32 : i32 = @intCast(v); 
        buffer[v] = vi32 * vi32 - 2 * vi32 + vi32 ^ 0x11; 
    }
    const PQueue = fheap.HeapDefine(i32, void, i32cmp);
    const p = PQueue.init({});
    std.debug.print("before: {any}\n", .{ buffer }); 
    p.fillArray(buffer); 
    std.debug.print("after : {any}\n", .{ buffer }); 

}
