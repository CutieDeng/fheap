const std = @import("std");
const testing = std.testing;

pub const Index = struct {
    row: u64, 
    column: u64, 
}; 

pub fn newIndex(index: u64) Index {
    const indexX3 = index * 3; 
    const plus1 = indexX3 + 1; 
    const p2 = @clz(plus1); 
    const bitCnt : u64 = @bitSizeOf(u64); 
    const inv2 = bitCnt - p2; 
    const inv2p1 = inv2 + 1; 
    const inv2p1d2 = inv2p1 / 2; 
    const m1 = inv2p1d2 - 1; 
    const r2rm = rowIntegral(m1); 
    const column = index - r2rm; 
    return .{ .row = m1, .column = column }; 
}

pub fn rowIntegral(rows: u64) u64 {
    const ru6 : u6 = @intCast(rows); 
    const exp4i = (@as(u64, 1) << (2 * ru6)) - 1; 
    const div = @divExact(exp4i, 3); 
    return div; 
}

pub fn rowLength(row: u64) u64 {
    const r : u6 = @intCast(row); 
    return @as(u64, 1) << (2 * r); 
}

pub fn fromIndex(index: Index) u64 {
    return rowIntegral(index.row) + index.column; 
}

pub fn subLeftmostSon(index: Index) Index {
    const row = index.row + 1; 
    const column = index.column << 2; 
    return .{ .row = row, .column = column }; 
}

pub fn parent(index: Index) Index {
    std.debug.assert(index.row != 0); 
    const row = index.row - 1; 
    const column = index.column / 4; 
    return .{ .row = row, .column = column }; 
}

pub fn directParent(index: u64) u64 {
    std.debug.assert(index != 0); 
    const indexm1 = index - 1; 
    const indexm1d4 = indexm1 / 4; 
    return indexm1d4; 
}

test "row length test" {
    const assert = std.debug.assert; 
    assert(rowLength(0) == 1); 
    assert(rowLength(1) == 4); 
    assert(rowLength(2) == 16); 
    assert(rowLength(3) == 64); 
}

pub fn eq(index1: Index, index2: Index) bool {
    return index1.row == index2.row and 
        index1.column == index2.column; 
}

test "sub leftmost son" {
    const indexes = [_] Index { 
        .{ .row = 0, .column = 0 }, 
        .{ .row = 1, .column = 0 }, 
        .{ .row = 1, .column = 3 }, 
        .{ .row = 2, .column = 12 }, 
        .{ .row = 1, .column = 0 }, 
        .{ .row = 2, .column = 0 }, 
    };
    const len = indexes.len; 
    const lend2 = len / 2; 
    for (0..lend2) |i| {
        const f = indexes[2 * i]; 
        const s = indexes[2 * i + 1]; 
        const s2 = subLeftmostSon(f); 
        std.debug.assert(eq(s, s2)); 
    }
}

const Order = std.math.Order; 

pub fn HeapDefine(comptime T: type, comptime Context: type, comptime compareFn: fn(context: Context, a: T, b: T) Order) type {
    return struct {
        const Self = @This(); 
        ctx: Context, 
        pub fn init(context: Context) Self {
            return .{ .ctx = context }; 
        }
        pub fn fillArray(self: Self, array: []T) void {
            if (array.len == 0) {
                return ; 
            }
            var idx: u64 = array.len - 1; 
            const last = newIndex(idx); 
            const last2 = rowIntegral(last.row); 
            idx = last2; 
            // std.debug.print("idx = {}\n", .{ idx }); 
            while (true) { 
                self.siftDown(array, idx); 
                if (idx == 0) {
                    break ; 
                } 
                idx -= 1; 
            }
        }
        pub fn siftDown(self: Self, array: []T, idx: usize) void {
            std.debug.assert(idx < array.len); 
            const current = newIndex(idx); 
            const son = subLeftmostSon(current); 
            const sonIdx = fromIndex(son); 
            var nowMinimumIdx = idx;
            for (0..4) |i| {
                const currentSonIdx : usize = i + sonIdx; 
                if (currentSonIdx >= array.len) break; 
                const compare = compareFn(self.ctx, array[nowMinimumIdx], array[currentSonIdx]); 
                // std.debug.print("cmp({}, {}) [{}] [{}] = {}\n", .{ array[nowMinimumIdx], array[currentSonIdx], nowMinimumIdx, currentSonIdx, compare }); 
                if (compare == .gt) {
                    nowMinimumIdx = currentSonIdx; 
                }
            }
            if (nowMinimumIdx == idx) {
                return ; 
            }
            // std.debug.print("swap [{}]={}, [{}]={}\n", .{ idx, array[idx], nowMinimumIdx, array[nowMinimumIdx] }); 
            std.mem.swap(T, &array[idx], &array[nowMinimumIdx]); 
            return siftDown(self, array, nowMinimumIdx); 
        }
        pub fn siftUp(self: Self, array: []T, idx: usize) void {
            if (idx == 0) {
                return ; 
            }
            const parentIdx = directParent(idx); 
            const compare = compareFn(self.ctx, array[parentIdx], array[idx]); 
            if (compare == .gt) {
                std.mem.swap(T, &array[parentIdx], &array[idx]); 
                return siftUp(self, array, parentIdx); 
            }
        } 
    }; 
}
