ifeq ($(origin FC),default)
FC = ifort
endif
# if FFLAGS is not set, use default
ifeq ($(origin FFLAGS),undefined)
ifeq ($(FC),ifort)
FFLAGS=-i8
else
FFLAGS=-fdefault-integer-8
endif
endif
EXE = readmdcint
SRC = readmdcint.f90

$(EXE): $(SRC)
	$(FC) $(FFLAGS) -o $(EXE) $(SRC)

all: $(EXE)

clean:
	rm -f $(EXE)
