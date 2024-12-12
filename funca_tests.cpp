#include <iostream>
#include <cmath>
#include <cassert>
#include "FuncA.h"
#include "load_server.h" // Для тесту часу виконання

// Тест: перевірка для позитивного значення
void test_cos_positive() {
    FuncA calc;
    assert(fabs(calc.calculate(0.5, 5) - cos(0.5)) < 0.001);
    std::cout << "test_cos_positive passed!" << std::endl;
}

// Тест: перевірка для негативного значення
void test_cos_negative() {
    FuncA calc;
    assert(fabs(calc.calculate(-0.5, 10) - cos(-0.5)) < 0.001);
    std::cout << "test_cos_negative passed!" << std::endl;
}

// Тест: перевірка для великого значення
void test_cos_large_input() {
    FuncA calc;
    assert(fabs(calc.calculate(10.0, 20) - cos(10.0)) < 0.001);
    std::cout << "test_cos_large_input passed!" << std::endl;
}

// Тест: перевірка часу виконання
void test_calculation_time() {
    int elapsedTime = simulateServerLoad(); // Використовуємо функцію з load_server.cpp
    std::cout << "Calculation and sorting time: " << elapsedTime << " milliseconds" << std::endl;
    assert(elapsedTime >= 5000 && elapsedTime <= 20000); // Час має бути в межах 5-20 секунд
    std::cout << "test_calculation_time passed!" << std::endl;
}

int main() {
    // Виклик усіх тестів
    test_cos_positive();
    test_cos_negative();
    test_cos_large_input();
    test_calculation_time();

    std::cout << "All tests passed!" << std::endl;
    return 0;
}

