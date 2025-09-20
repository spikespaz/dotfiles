const force_proc_name: slice_z_t = "@procName@";

const c = @cImport({
    @cInclude("dlfcn.h");
    @cInclude("pthread.h");
    @cInclude("sys/prctl.h");
});

const std_c = @import("std").c;
const linux = @import("std").os.linux;

const slice_z_t = [:0]const u8;
const str_z_t = [*:0]const u8;

const pthread_t = @import("std").c.pthread_t;

fn isMainThread() bool {
    return linux.getpid() == linux.gettid();
}

fn pthreadEqual(t1: pthread_t, t2: pthread_t) bool {
    return 0 != c.pthread_equal(@intFromPtr(t1), @intFromPtr(t2));
}

var prctl_fn: ?*const fn (c_int, c_ulong, c_ulong, c_ulong, c_ulong) callconv(.c) c_int = null;
fn callPrctl(op: c_int, arg2: c_ulong, arg3: c_ulong, arg4: c_ulong, arg5: c_ulong) c_int {
    const f = prctl_fn orelse init: {
        prctl_fn = @ptrCast(std_c.dlsym(c.RTLD_NEXT, "prctl"));
        break :init prctl_fn orelse @panic("missing symbol: prctl");
    };
    return f(op, arg2, arg3, arg4, arg5);
}

var pthread_setname_np_fn: ?*const fn (pthread_t, str_z_t) callconv(.c) c_int = null;
fn callPthreadSetnameNp(thread: pthread_t, name: str_z_t) c_int {
    const f = pthread_setname_np_fn orelse init: {
        pthread_setname_np_fn = @ptrCast(std_c.dlsym(c.RTLD_NEXT, "pthread_setname_np"));
        break :init pthread_setname_np_fn orelse @panic("missing symbol: pthread_setname_np");
    };
    return f(thread, name);
}

pub export fn prctl(op: c_int, arg2: c_ulong, arg3: c_ulong, arg4: c_ulong, arg5: c_ulong) callconv(.c) c_int {
    return if (op == c.PR_SET_NAME and isMainThread())
        callPrctl(op, @intFromPtr(force_proc_name.ptr), arg3, arg4, arg5)
    else
        callPrctl(op, arg2, arg3, arg4, arg5);
}

pub export fn pthread_setname_np(thread: pthread_t, name: str_z_t) callconv(.c) c_int {
    var new_name = name;
    if (isMainThread() and pthreadEqual(thread, std_c.pthread_self()))
        new_name = force_proc_name;
    return callPthreadSetnameNp(thread, new_name);
}

fn ctor() callconv(.c) void {
    if (!isMainThread()) return;
    _ = linux.prctl(@intCast(c.PR_SET_NAME), @intFromPtr(force_proc_name.ptr), 0, 0, 0);
}

pub export const _procname_shim_ctor: [1]@TypeOf(&ctor) linksection(".init_array") = .{&ctor};
