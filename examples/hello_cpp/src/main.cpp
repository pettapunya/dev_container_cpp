//  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
//  SPDX-License-Identifier: BSD-3-Clause

#include <iostream>
#include <string_view>

auto main() -> int {
    constexpr std::string_view message{"Hello from C++ in dev_container_cpp!"};
    std::cout << message << '\n';
    std::cout << "Toolchain verification: PASSED\n";
    return 0;
}
