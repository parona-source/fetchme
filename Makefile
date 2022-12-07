NAME = fetchme
VERSION = 1.4.2

CFLAGS ?= -O2 -pipe -g
CPPFLAGS ?=
LDFLAGS = -Wl,-O1,--as-needed

include config_backend.mk

CFLAGS := -g -std=c99 $(CFLAGS)
CPPFLAGS := -D_PACKAGE_NAME=\"$(NAME)\" -D_PACKAGE_VERSION=\"$(VERSION)\" $(MODULES) $(CPPFLAGS)

TARGET = $(OUTDIR)/$(NAME)
OBJECTS = $(SOURCES:$(SRCDIR)/%.c=obj/%.o)
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

.PHONY: all install uninstall clean format

all: clean $(TARGET)

$(TARGET): $(OBJECTS) | $(OUTDIR)
	$(CC) -o $@ $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(INCLUDE) $^ $(M_LFLAGS)

obj/%.o : $(SRCDIR)/%.c | obj/modules
	$(CC) -o $@ $(CFLAGS) $(CPPFLAGS) $^ -c

$(OUTDIR) obj/modules:
	mkdir -p $@

install: | $(TARGET)
	$(INSTALL_DIR) $(DESTDIR)/$(BINDIR) $(DESTDIR)/$(MAN1DIR)
	$(INSTALL_PROGRAM) $(TARGET) $(DESTDIR)$(BINDIR)
	$(INSTALL_DATA) docs/fetchme.1.bz2 $(DESTDIR)$(MAN1DIR)

install-strip:
	make INSTALL_PROGRAM="install -s" install

uninstall:
	-rm $(DESTDIR)$(BINDIR)/$(NAME) $(DESTDIR)/$(MAN1DIR)/fetchme.1.bz2
	-rmdir -p $(DESTDIR)$(BINDIR)
	-rmdir -p $(DESTDIR)$(MAN1DIR)

clean:
	-rm -rf $(OUTDIR) obj

format:
	@find . -iname *.h -o -iname *.c | xargs clang-format -style=file:.clang-format -i


pgo:
	@# only clang is supported for this PGO
	if [[ -f fetchme.profdata ]]; then \
		make CC=clang PGO=use && $(rm) fetchme.prof*; \
	else \
		make CC=clang PGO=gen && \
	for x in {0..100}; do \
		LLVM_PROFILE_FILE=fetchme.profraw ./bin/fetchme > /dev/null; \
	done; \
	llvm-profdata merge -output=fetchme.profdata fetchme.profraw; \
	fi
