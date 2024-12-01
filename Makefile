CXX = g++
CXXFLAGS = -Wall -std=c++11
TARGET = main

all: $(TARGET)

$(TARGET): main.o FuncA.o
	$(CXX) $(CXXFLAGS) -o $(TARGET) main.o FuncA.o

main.o: main.cpp FuncA.h
	$(CXX) $(CXXFLAGS) -c main.cpp

FuncA.o: FuncA.cpp FuncA.h
	$(CXX) $(CXXFLAGS) -c FuncA.cpp

clean:
	rm -f *.o $(TARGET)

