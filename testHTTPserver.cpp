#include <iostream>
#include <cmath>
#include <chrono>
#include <vector>
#include <random>
#include <cassert>
#include <algorithm>
#include "FuncA.h"
#include "calculateTime.h"

void test_cos_zero() {
    FuncA calc;
    assert(fabs(calc.calculate(0.0, 5) - 1.0) < 0.001);
}

void test_cos_pi() {
    FuncA calc;
    assert(fabs(calc.calculate(M_PI, 10) + 1.0) < 0.001);
}

void test_cos_pi_half() {
    FuncA calc;
    assert(fabs(calc.calculate(M_PI/2, 10)) < 0.001);
}

void test_calculation_time() {
    int iMS = calculateTime();
    std::cout << "Calculation and sorting time: " << iMS << " milliseconds" << std::endl;
    assert(iMS >= 5000 && iMS <= 20000);
}

int main() {
    test_cos_zero();
    test_cos_pi();
    test_cos_pi_half();
    test_calculation_time();
    std::cout << "All tests passed!" << std::endl;
    return 0;
}

