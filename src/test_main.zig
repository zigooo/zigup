const builtin = @import("builtin");
const std = @import("std");

fn exec(dd: *const fn () type) type {
    return dd();
}

fn apply(comptime T: type, f: fn (T) T, x: T) T {
    return f(x);
}

fn square(x: i32) i32 {
    return x * x;
}

fn main11() void {
    _ = exec(fn () i32{return 1});

    // const result1 = apply(i32, square, 10);
    // std.debug.print("Result1: {d}\n", .{result1}); // 输出 100

    // const result2 = apply(f64,  (x: f64) f64{return x}, 2.5);
    // std.debug.print("Result2: {d}\n", .{result2}); // 输出 6.25
}

fn Maybe(comptime T: type) type {
    return struct {
        val: ?T,
        pub fn apply(self: Maybe(T), fun: *const fn (T) ?T) Maybe(T) {
            if (self.val != null) {
                return Maybe(T){ .val = fun(self.val.?) };
            }
            return Maybe(T){ .val = null };
        }

        pub fn unwrapOr(self: anytype, default: T) T {
            if (self.val != null) {
                return self.val.?;
            }
            return default;
        }

        pub fn init(val: T) @This() {
            return Maybe(T){ .val = val };
        }
    };
}

pub fn increment(x: i32) ?i32 {
    return x + 1;
}

pub fn squareOver100(x: i32) ?i32 {
    if (x < 100) {
        return null;
    }
    return x * x;
}

fn main111() void {
    _ = exec(fn () i32{return 1});

    // squareOver100 will fail returning a null so our default value will be printed
    const a = Maybe(i32).init(0).apply(increment)
        .apply(squareOver100).apply(fn (x: i32) ?i32{return x});
    std.debug.print("Failed Operation:  {d}\n", .{a.unwrapOr(0)});
}
