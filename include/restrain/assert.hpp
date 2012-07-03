#ifndef RESTRAIN_ASSERT_HPP
#define RESTRAIN_ASSERT_HPP

#include <string>
#include <iostream>

#ifndef NDEBUG
    #define RESTRAIN_ASSERT_IMPL(condition, message) \
        do { if (condition) {} else { ::restrain::assert_impl(#condition, message); } } while(0)
#else
    #define RESTRAIN_ASSERT_IMPL(condition, message) do {} while(0)
#endif

#define RESTRAIN_ASSERT_PRECONDITION(condition, arg, type) \
    RESTRAIN_ASSERT_IMPL(condition, "Argument " arg " of invalid type " type " passed to " function ".")
#define RESTRAIN_ASSERT_POSTCONDITION(condition, type) \
    RESTRAIN_ASSERT_IMPL(condition, "Return value of " function " is not a " type ".")

namespace restrain {
    inline void assert_impl(std::string const& condition, std::string const& message) {
        std::cerr << "Failed: " << condition << std::endl;
        std::cerr << message << std::endl;
        // At the moment, assert continues without stopping program execution.
        // This will probably be changed; for now I'm keeping it this way to aid
        // debugging. 
    }
}

#endif
