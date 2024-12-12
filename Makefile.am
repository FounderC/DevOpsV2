# Використання Automake
AUTOMAKE_OPTIONS = foreign

# Основна програма
bin_PROGRAMS = FuncA
FuncA_SOURCES = main.cpp http_server.cpp FuncA.cpp FuncA.h load_server.cpp load_server.h

# Тестова програма
check_PROGRAMS = funca_tests
funca_tests_SOURCES = funca_tests.cpp FuncA.cpp FuncA.h load_server.cpp load_server.h

# Додаткові файли для дистрибуції
EXTRA_DIST = Makefile.am configure.ac

# Тести
TESTS = funca_tests
TESTS_ENVIRONMENT = GTEST_COLOR=1

