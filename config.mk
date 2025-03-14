# fetchme's config.
###########################################################
##### ** Everything works with linux.              ** #####
##### ** Other OS support is explicitly mentioned. ** #####
##### ** "Hurd" refers to "Debian GNU/Hurd."       ** #####
##### ** "BSD" refers to "FreeBSD."                ** #####
###########################################################
#
# options can be turned on with either
# `Y' or `y'. to deselect an option,
# comment it out.

# to set a custom color,
# uncomment both CUSTOM_COLOR
# and CUSTOM_COLOR_VALUE
# M_CUSTOM_COLOR=y
# options are: RED,GREEN,YELLOW,BLUE,PURPLE,CYAN,WHITE
# M_CUSTOM_COLOR_VALUE=CYAN

# Works with BSD,Hurd
M_USERNAME_HOSTNAME=y

# Works with BSD,Hurd
M_DISTRO=y

# Works with BSD,Hurd
M_KERNEL=y

# Works with BSD
M_UPTIME=y

# Off by default.
# Currently only works
# with pacman-based,
# portage-based,
# and apk-based
# linux distros.
#
# Works with BSD
M_PACKAGE=y

# Works with BSD,Hurd
# M_SHELL=y

# Works with BSD
# XCB might be faster than Xlib
# both modules must be uncommented
# and set to 'y' to use xcb. otherwise,
# Xlib is used.
M_RESOLUTION=y
M_RESOLUTION_XCB=y

# Works with BSD (outside of VMs)
# XCB might be faster than Xlib
# both modules must be uncommented
# and set to 'y' to use xcb. otherwise,
# Xlib is used.
M_REFRESH_RATE=y
# M_REFRESH_RATE_XCB=y

# Works with BSD (X11 tested)
# M_WM only works with XWayland and X11.
# M_WM_WAYLAND only works with Wayland (but is slower)
M_WM=y
# M_WM_WAYLAND=y

# Works with BSD,Hurd
M_TERMINAL=y

# any option associated with CPU
# needs to have CPU=y
# - Works with BSD
# - Does NOT work with PinePhone; the information is
# not exposed in /proc/cpuinfo
M_CPU=y
M_CPU_THREADS=y
# commented out by default since
# it's **experimental**
# M_CPU_TEMP=y
M_CPU_FREQUENCY=y

# v2 is the newer, faster method.
# v1 is older and slower, but tested more.
# If M_GPU_VERSION is not set, it is defaulted to v1.
# - Works with BSD
# - Does NOT work with PinePhone; pcilib throws an error,
# "Cannot open /proc/bus/pci"
M_GPU=y
M_GPU_VERSION=2

# any option associated with MEMORY
# needs to have MEMORY=y
# Does NOT work with BSD
M_MEMORY=y
M_MEMORY_PERCENT=y

# any option associated with DISK
# needs to have DISK=y
# Works with BSD,Hurd
M_DISK=y
M_DISK_PERCENT=y
