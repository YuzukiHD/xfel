#
# Top makefile
#

PREFIX ?= /usr/local
CROSS		?=

AS			:= $(CROSS)gcc -x assembler-with-cpp
CC			:= $(CROSS)gcc
CXX			:= $(CROSS)g++
LD			:= $(CROSS)ld
AR			:= $(CROSS)ar
RM			:= rm -fr

ASFLAGS		:= -g -ggdb -Wall -O3
CFLAGS		:= -g -ggdb -Wall -O3
CXXFLAGS	:= -g -ggdb -Wall -O3
LDFLAGS		:= -Wl,-z,relro -Wl,-z,now -Wl,-z,shstk
ARFLAGS		:= -rcs
MCFLAGS		:=

LIBDIRS		:=
LIBS 		:= `pkg-config --libs libusb-1.0`

INCDIRS		:= -I . `pkg-config --cflags libusb-1.0`
SRCDIRS		:= . chips


SFILES		:= $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.S))
CFILES		:= $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.c))
CPPFILES	:= $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.cpp))

SDEPS		:= $(patsubst %, %, $(SFILES:.S=.o.d))
CDEPS		:= $(patsubst %, %, $(CFILES:.c=.o.d))
CPPDEPS		:= $(patsubst %, %, $(CPPFILES:.cpp=.o.d))
DEPS		:= $(SDEPS) $(CDEPS) $(CPPDEPS)

SOBJS		:= $(patsubst %, %, $(SFILES:.S=.o))
COBJS		:= $(patsubst %, %, $(CFILES:.c=.o))
CPPOBJS		:= $(patsubst %, %, $(CPPFILES:.cpp=.o))
OBJS		:= $(SOBJS) $(COBJS) $(CPPOBJS)

OBJDIRS		:= $(patsubst %, %, $(SRCDIRS))
NAME		:= xfel
VPATH		:= $(OBJDIRS)

.PHONY:		all install clean

all : $(NAME)

$(NAME) : $(OBJS)
	@echo [LD] Linking $@
	@$(CC) $(LDFLAGS) $(LIBDIRS) $^ -o $@ $(LIBS)

$(SOBJS) : %.o : %.S
	@echo [AS] $<
	@$(AS) $(ASFLAGS) -MD -MP -MF $@.d $(INCDIRS) -c $< -o $@

$(COBJS) : %.o : %.c
	@echo [CC] $<
	@$(CC) $(CFLAGS) -MD -MP -MF $@.d $(INCDIRS) -c $< -o $@

$(CPPOBJS) : %.o : %.cpp
	@echo [CXX] $<
	@$(CXX) $(CXXFLAGS) -MD -MP -MF $@.d $(INCDIRS) -c $< -o $@

install:
	install -Dm0755 xfel $(DESTDIR)$(PREFIX)/bin/xfel
	install -Dm0644 99-xfel.rules $(DESTDIR)/lib/udev/rules.d/99-xfel.rules
	install -Dm0644 LICENSE $(DESTDIR)$(PREFIX)/share/licenses/xfel/LICENSE

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/xfel
	rm -f $(DESTDIR)/lib/udev/rules.d/99-xfel.rules
	rm -f $(DESTDIR)$(PREFIX)/share/licenses/xfel/LICENSE

clean:
	@$(RM) $(DEPS) $(OBJS) $(NAME).exe $(NAME) *~
