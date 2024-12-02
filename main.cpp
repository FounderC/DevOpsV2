#include <iostream>
#include "FuncA.h"

int CreateHTTPserver();

int main() {
    FuncA func;
    double x;
    int n;
    
    std::cout << "Enter x and n: ";
    std::cin >> x >> n;
    
    std::cout << "FuncA result: " << func.calculate(x, n) << std::endl;

    std::cout << "Starting HTTP server..." << std::endl;
    CreateHTTPserver();

    return 0;
}

