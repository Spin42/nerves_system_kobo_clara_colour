#ifndef ERLINIT_COMPAT_SYS_RANDOM_H
#define ERLINIT_COMPAT_SYS_RANDOM_H

#include <errno.h>
#include <sys/types.h>
#include <stddef.h>
#include <sys/syscall.h>

#ifndef GRND_NONBLOCK
#define GRND_NONBLOCK 0x0001
#endif
#ifndef GRND_INSECURE
#define GRND_INSECURE 0x0004
#endif

/*
 * Minimal inline stub for getrandom() to trigger ENOSYS fallback paths
 * in erlinit's seedrng.c when the libc doesn't provide sys/random.h.
 */
static inline ssize_t getrandom(void *buf, size_t count, unsigned int flags)
{
    (void)buf; (void)count; (void)flags;
    errno = ENOSYS;
    return -1;
}

#endif /* ERLINIT_COMPAT_SYS_RANDOM_H */
