#include "FuncA.h"
#include <cmath>
#include <stdexcept>

double FuncA::calculate(double x, int n) {
    double result = 1.0;
    double term = 1.0;
    
    for (int i = 1; i <= n; i++) {
        term *= -x * x / ((2 * i) * (2 * i - 1));
        result += term;
    }
    return result;
}

