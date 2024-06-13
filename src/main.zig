const std = @import("std");

const fheap = @import("fheap"); 

const Order = std.math.Order; 

pub fn i32cmp(_: void, a: i32, b: i32) Order {
    return std.math.order(a, b); 
}

pub fn main() !void {

    const allocator = std.heap.c_allocator; 
    const buffer: []i32 = try allocator.alloc(i32, 32); 
    defer allocator.free(buffer); 
    for (0..32) |v| {
        const vi32 : i32 = @intCast(v); 
        buffer[v] = vi32 * vi32 - 15 * vi32 + vi32 ^ 0x11 + @divTrunc(vi32 * vi32 * vi32, 24); 
    }
    const PQueue = fheap.HeapDefine(i32, void, i32cmp);
    const p = PQueue.init({});
    std.debug.print("before: {any}\n", .{ buffer }); 
    p.fillArray(buffer); 
    std.debug.print("after : {any}\n", .{ buffer }); 
    var orderPop = buffer; 
    while (orderPop.len != 1) {
        std.mem.swap(i32, &orderPop[0], &orderPop[orderPop.len - 1]); 
        orderPop.len -= 1; 
        p.siftDown(orderPop, 0); 
    }
    std.mem.reverse(i32, buffer); 
    std.debug.print("sorted: {any}\n", .{ buffer }); 

}
