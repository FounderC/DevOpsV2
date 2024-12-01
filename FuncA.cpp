#include "FuncA.h"
#include <cmath>

double FuncA::calculate(double x, int n) {
    double result = 0.0;
    for (int i = 0; i < n; ++i) {
        result += std::pow(x, 2 * i + 1) / (2 * i + 1);
    }
    return result;
}

