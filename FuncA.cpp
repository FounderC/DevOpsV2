#include "FuncA.h"
#include <cmath>

double FuncA::calculate(double x, int n) {
    double result = 0.0;
    for (int i = 0; i < n; ++i) {
        double term = std::pow(x, 2 * i + 1) / (2 * i + 1);
        if (i % 2 != 0) {
            term = -term;
        }
        result += term;
    }
    return result;
}

