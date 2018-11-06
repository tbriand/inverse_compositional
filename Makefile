CFLAGS=-Wall -Wextra -O3
LDFLAGS=-lm -lpng -ljpeg -ltiff -lstdc++

SRC1 := bicubic_interpolation.cpp inverse_compositional_algorithm.cpp mask.cpp transformation.cpp file.cpp matrix.cpp zoom.cpp
SRC2 := iio.c mt19937ar.c

INCLUDE = -I.

#Replace suffix .cpp and .c by .o
OBJ := $(addsuffix .o,$(basename $(SRC1))) $(addsuffix .o,$(basename $(SRC2)))

#Binary file
BIN  = inverse_compositional_algorithm add_noise generate_output equalization

#All is the target (you would run make all from the command line). 'all' is dependent
all: $(BIN)

#Generate executables
inverse_compositional_algorithm: main.o $(OBJ)
	$(CXX) -std=c++11 $^ -o $@ $(LDFLAGS)

add_noise: mt19937ar.o file.o iio.o noise.o
	$(CXX) -std=c++11 $^ -o $@ $(LDFLAGS)

generate_output: output.o $(OBJ)
	$(CXX) -std=c++11 $^ -o $@ $(LDFLAGS)
	
equalization: equalization.o iio.o
	$(CC) -std=c99 $^ -o $@ $(LDFLAGS)

#each object file is dependent on its source file, and whenever make needs to create
#an object file, to follow this rule:
%.o: %.c
	$(CC) -std=c99  -c $< -o $@ $(INCLUDE) $(CFLAGS)  -Wno-unused -pedantic -DNDEBUG -D_GNU_SOURCE

%.o: %.cpp
	$(CXX) -std=c++11 -c $< -o $@ $(INCLUDE) $(CFLAGS)

clean:
	rm -f $(OBJ) $(BIN) main.o output.o noise.o equalization.o
