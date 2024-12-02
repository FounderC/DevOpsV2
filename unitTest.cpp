#include <iostream>
#include <cassert>
#include <cmath>
#include "FuncA.h"

void testFuncA() {
    FuncA trigFunc;

    // Тест 1: x = 0, n = 1
    double result1 = trigFunc.calculate(0, 1);
    double expected1 = 0.0;  // Очікуване значення для arctan(0)
    std::cout << "Test 1 - x = 0, n = 1: " << result1 << " (Expected: " << expected1 << ")" << std::endl;
    assert(std::abs(result1 - expected1) < 1e-9);

    // Тест 2: x = 1, n = 1
    double result2 = trigFunc.calculate(1, 1);
    double expected2 = 1.0;  // Очікуване значення для arctan(1)
    std::cout << "Test 2 - x = 1, n = 1: " << result2 << " (Expected: " << expected2 << ")" << std::endl;
    assert(std::abs(result2 - expected2) < 1e-9);

    // Тест 3: x = 1, n = 2
    double result3 = trigFunc.calculate(1, 2);
    double expected3 = 1.0 - 1.0 / 3.0;  // Очікуване значення: 1 - 1/3 = 0.666667
    std::cout << "Test 3 - x = 1, n = 2: " << result3 << " (Expected: " << expected3 << ")" << std::endl;
    assert(std::abs(result3 - expected3) < 1e-9);

    // Тест 4: x = M_PI/4, n = 3
    double result4 = trigFunc.calculate(M_PI / 4, 3);
    double expected4 = M_PI / 4 - std::pow(M_PI / 4, 3) / 3 + std::pow(M_PI / 4, 5) / 5;
    std::cout << "Test 4 - x = M_PI/4, n = 3: " << result4 << " (Expected: " << expected4 << ")" << std::endl;
    assert(std::abs(result4 - expected4) < 1e-9);

    // Тест 5: x = M_PI/2, n = 5
    double result5 = trigFunc.calculate(M_PI / 2, 5);
    double expected5 = M_PI / 2 - std::pow(M_PI / 2, 3) / 3 + std::pow(M_PI / 2, 5) / 5
                     - std::pow(M_PI / 2, 7) / 7 + std::pow(M_PI / 2, 9) / 9;
    std::cout << "Test 5 - x = M_PI/2, n = 5: " << result5 << " (Expected: " << expected5 << ")" << std::endl;
    assert(std::abs(result5 - expected5) < 1e-9);
}

int main() {
    testFuncA();
    return 0;
}

