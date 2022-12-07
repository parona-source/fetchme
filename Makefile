NAME = fetchme
VERSION = 1.4.2

CFLAGS ?= -O2 -pipe -g
CPPFLAGS ?=
LDFLAGS = -Wl,-O1,--as-needed

include config_backend.mk

EXTRA_CFLAGS += -std=c99
CPPFLAGS := -D_PACKAGE_NAME=\"$(NAME)\" -D_PACKAGE_VERSION=\"$(VERSION)\" $(MODULES) $(CPPFLAGS)

TARGET = $(OUTDIR)/$(NAME)
OBJECTS = $(SOURCES:$(SRCDIR)/%.c=obj/%.o)
PROFDIR = prof
OUTDIR = bin

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
RM = rm -f

ifndef $(COMPILER)
ifeq ($(shell $(CC) -v 2>&1 | grep -c "clang version"), 1)
	COMPILER = clang
else ifeq ($(shell $(CC) -v 2>&1 | grep -c "gcc version"), 1)
	COMPILER = gcc
endif
endif

ifeq ($(PGO),instrument)
ifeq ($(COMPILER),clang)
	EXTRA_CFLAGS += -fprofile-instr-generate=$(PROFDIR)/$(NAME).profraw
endif
ifeq ($(COMPILER),gcc)
	EXTRA_CFLAGS += -fprofile-generate=$(PROFDIR)
endif
endif

ifeq ($(PGO),optimize)
ifeq ($(COMPILER),clang)
	EXTRA_CFLAGS += -fprofile-instr-use=$(PROFDIR)/$(NAME).profdata
endif
ifeq ($(COMPILER),gcc)
	EXTRA_CFLAGS += -fprofile-use=$(PROFDIR)
endif
endif

.PHONY: all install uninstall clean format pgo

all: clean $(TARGET)

$(TARGET): $(OBJECTS) | $(OUTDIR)
	$(CC) -o $@ $(EXTRA_CFLAGS) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(INCLUDE) $^ $(LDLIBS)

obj/%.o : $(SRCDIR)/%.c | obj/modules
	$(CC) -o $@ $(EXTRA_CFLAGS) $(CFLAGS) $(CPPFLAGS) $^ -c

$(PROFDIR) $(OUTDIR) obj/modules:
	mkdir -p $@

install: | $(TARGET)
	$(INSTALL_DIR) $(DESTDIR)/$(BINDIR) $(DESTDIR)/$(MAN1DIR)
	$(INSTALL_PROGRAM) $(TARGET) $(DESTDIR)$(BINDIR)
	$(INSTALL_DATA) docs/fetchme.1.bz2 $(DESTDIR)$(MAN1DIR)

install-strip:
	$(MAKE) INSTALL_PROGRAM="install -s" install

uninstall:
	-rm $(DESTDIR)$(BINDIR)/$(NAME) $(DESTDIR)/$(MAN1DIR)/fetchme.1.bz2
	-rmdir -p $(DESTDIR)$(BINDIR)
	-rmdir -p $(DESTDIR)$(MAN1DIR)

clean:
	-rm -rf $(OUTDIR) obj

clean-prof:
	-rm -rf $(PROFDIR)

format:
	@find . -iname *.h -o -iname *.c | xargs clang-format -style=file:.clang-format -i

pgo: | $(PROFDIR)
ifneq (, $(filter $(COMPILER), clang gcc))
	$(MAKE) clean-prof
	$(MAKE) PGO=instrument
	for x in {0..100}; do \
		./$(TARGET) > /dev/null; \
	done
ifeq ($(COMPILER), clang)
	export LLVM_PROFILE_FILE="${PROFDIR}/$(NAME).profraw"
	llvm-profdata merge -output=${PROFDIR}/$(NAME).profdata ${PROFDIR}/$(NAME).profraw
endif
	$(MAKE) PGO=optimize
	$(MAKE) clean-prof
else
	@echo "Only clang or gcc are supported for pgo"
endif

