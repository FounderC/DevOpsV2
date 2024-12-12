#include "load_server.h"
#include <vector>
#include <algorithm>
#include <random>
#include <chrono>

int simulateServerLoad() {
    auto t1 = std::chrono::high_resolution_clock::now();

    std::vector<int> aValues;
    std::mt19937 mtre {123}; // Mersenne Twister random engine
    std::uniform_int_distribution<int> distr {0, 2000000};

    for (int i = 0; i < 2000000; i++) {
        aValues.push_back(distr(mtre));
    }

    for (int i = 0; i < 500; i++) {
        std::sort(aValues.begin(), aValues.end());
        std::reverse(aValues.begin(), aValues.end());
    }

    auto t2 = std::chrono::high_resolution_clock::now();
    auto int_ms = std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1);

    return int_ms.count(); // Повертає час у мілісекундах
}
