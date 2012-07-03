#include <restrain/assert.hpp>

namespace restrain {
    int rst_fib_argsZ_zero_plus(int);

    inline int rst_fib_argsZ_zero_plus_impl(int n) {
        if ((n >= 2)) {
            return (rst_fib_argsZ_zero_plus((n-1)) + rst_fib_argsZ_zero_plus((n-2)));
        } else {
            return n;
        }
    }

    int rst_fib_argsZ_zero_plus(int n) {
        RESTRAIN_ASSERT_PRECONDITION((n >= 0), "n", "Z0+");
        int result = rst_fib_argsZ_zero_plus_impl(n);
        RESTRAIN_ASSERT_POSTCONDITION((result >= 0), "Z0+");
        return result;
    }
}
