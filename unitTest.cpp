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
    double result = calc.calculate(0.0, 5);
    std::cout << "cos(0) calculated value: " << result << std::endl;
    assert(fabs(result - 1.0) < 0.001); 
}

void test_cos_pi() {
    FuncA calc;
    double result = calc.calculate(M_PI, 10);
    std::cout << "cos(pi) calculated value: " << result << std::endl;
    assert(fabs(result + 1.0) < 0.001);  
}

void test_cos_pi_half() {
    FuncA calc;
    double result = calc.calculate(M_PI/2, 10);
    std::cout << "cos(pi/2) calculated value: " << result << std::endl;
    assert(fabs(result) < 0.001);  
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


