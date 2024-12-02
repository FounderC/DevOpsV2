AUTOMAKE_OPTIONS = foreign

bin_PROGRAMS = FuncA
check_PROGRAMS = test_func_a

FuncA_SOURCES = main.cpp FuncA.cpp FuncA.h http_server.cpp calculateTime.cpp calculateTime.h
test_func_a_SOURCES = unitTest.cpp FuncA.cpp FuncA.h calculateTime.cpp calculateTime.h

TESTS = test_func_a
EXTRA_DIST = Makefile.am

