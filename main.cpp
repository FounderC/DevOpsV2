#include <iostream>
#include "FuncA.h"

int main() {
    FuncA func;
    double x;
    int n;
    std::cout << "Enter x and n: ";
    std::cin >> x >> n;
    std::cout << "Result: " << func.calculate(x, n) << std::endl;
    return 0;
}

