NAME = fetchme
VERSION = 1.4.2

CFLAGS ?= -O2 -pipe -g
LDFLAGS ?= -Wl,-O1,--as-needed

include config_backend.mk
# Basic
BASE_FLAGS = -std=c99
# Warnings
BASE_FLAGS += -Wall -Wextra -Wpedantic -Wshadow -Warray-bounds -Wformat=2 \
	      -Wfloat-equal -Wlogical-op -Wundef -Wunreachable-code -Wvla -Wwrite-strings \
	      -Wcast-align=strict -Wcast-qual -Wbad-function-cast
# Suggest attribute warning(s)
BASE_FLAGS += $(foreach case, pure const noreturn malloc format cold, -Wsuggest-attribute=$(case))
# Error
BASE_FLAGS += -Werror=format-security -Werror=array-bounds
# Disable warnings
BASE_FLAGS += -Wno-unknown-pragmas -Wno-unused-result
#Preprocessor options
BASE_FLAGS += -D_PACKAGE_NAME=\"$(NAME)\" -D_PACKAGE_VERSION=\"$(VERSION)\" $(MODULES)

ifndef $(COMPILER)
ifeq ($(shell $(CC) -v 2>&1 | grep -c "clang version"), 1)
	COMPILER = clang
else ifeq ($(shell $(CC) -v 2>&1 | grep -c "gcc version"), 1)
	COMPILER = gcc
endif
endif

PROFDIR = prof

ifeq ($(PGO),instrument)
ifeq ($(COMPILER),clang)
	BASE_FLAGS += -fprofile-instr-generate=$(PROFDIR)/$(NAME).profraw
endif
ifeq ($(COMPILER),gcc)
	BASE_FLAGS += -fprofile-generate=$(PROFDIR)
endif
endif

ifeq ($(PGO),optimize)
ifeq ($(COMPILER),clang)
	BASE_FLAGS += -fprofile-instr-use=$(PROFDIR)/$(NAME).profdata
endif
ifeq ($(COMPILER),gcc)
	BASE_FLAGS += -fprofile-use=$(PROFDIR)
endif
endif

OBJDIR = obj
OUTDIR = bin

TARGET = $(OUTDIR)/$(NAME)
OBJECTS = $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

DESTDIR =
PREFIX = /usr/local
BINDIR = $(PREFIX)/bin
DATADIR = $(PREFIX)/share
MANDIR = $(DATADIR)/man
MAN1DIR = $(MANDIR)/man1

INSTALL = install
INSTALL_DIR = install -d
INSTALL_DATA = install -m644
INSTALL_PROGRAM = $(INSTALL)

.PHONY: all install uninstall clean clean-prof format pgo

all: clean $(TARGET)

$(TARGET): $(OBJECTS) | $(OUTDIR)
	$(CC) -o $@ $(BASE_FLAGS) $(CFLAGS) $(LDFLAGS) $(INCLUDE) $^ $(LDLIBS)

$(OBJDIR)/%.o : $(SRCDIR)/%.c | $(OBJDIR)/modules
	$(CC) -o $@ $(BASE_FLAGS) $(CFLAGS) $^ -c

$(PROFDIR) $(OUTDIR) $(OBJDIR)/modules:
	mkdir -p $@

install: | $(TARGET)
	$(INSTALL_DIR) $(DESTDIR)/$(BINDIR) $(DESTDIR)/$(MAN1DIR)
	$(INSTALL_PROGRAM) $(TARGET) $(DESTDIR)$(BINDIR)
	$(INSTALL_DATA) docs/fetchme.1 $(DESTDIR)$(MAN1DIR)

install-strip:
	$(MAKE) INSTALL_PROGRAM="install -s" install

uninstall:
	-rm $(DESTDIR)$(BINDIR)/$(NAME) $(DESTDIR)/$(MAN1DIR)/fetchme.1
	-rmdir -p $(DESTDIR)$(BINDIR)
	-rmdir -p $(DESTDIR)$(MAN1DIR)

clean:
	-rm -r $(OUTDIR) $(OBJDIR)

clean-prof:
	-rm $(PROFDIR)/*

format:
	@find . -iname *.h -o -iname *.c | xargs clang-format -style=file:.clang-format -i

pgo: | $(PROFDIR)
ifneq (, $(filter $(COMPILER), clang gcc))
	$(MAKE) clean-prof
	$(MAKE) PGO=instrument
	@echo "Running the program 100 times for profiling data"
	@$(foreach x, $(shell echo {1..100}), LLVM_PROFILE_FILE="$(PROFDIR)/$(NAME).profraw" ./$(TARGET) > /dev/null;)
ifeq ($(COMPILER), clang)
	llvm-profdata merge -output=${PROFDIR}/$(NAME).profdata ${PROFDIR}/$(NAME).profraw
endif
	$(MAKE) PGO=optimize
	$(MAKE) clean-prof
else
	@echo "Only clang or gcc are supported for pgo"
endif

