UNITTEST:=$(BIN)/uinttest

TESTDCFLAGS+=$(LIBS)
TESTDCFLAGS+=$(TAGION_DFILES)
TESTDCFLAGS+=-main

vpath %.d tests/