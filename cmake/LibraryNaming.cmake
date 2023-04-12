include(CheckSymbolExists)

macro(check_build_target symbol)
	check_symbol_exists(${symbol} "build.h" ${symbol})
endmacro()

macro(check_group_build_target symbol group)
	if(NOT ${group})
		check_build_target(${symbol})
		if(${symbol})
			set(${group} TRUE)
		endif()
	else()
		set(${symbol} FALSE)
	endif()
endmacro()

# So there is a problem:
# 1. Number of these symbols only grows, as we support more and more ports
# 2. CMake was written by morons and can't check these symbols in parallel
# 3. MSVC is very slow at everything (startup, parsing, generating error)

# Solution: group these symbols and set variable if one of them was found
# this way we can reorder to reorder them by most common configurations
# but we can't generate this list anymore! ... OR IS IT ???

# Well, after reordering positions in engine's buildenums.h, we can partially autogenerate this list!
# echo "check_build_target(XASH_64BIT)"
# grep "#define PLATFORM" buildenums.h     | cut -d' ' -f 2 | cut -d_ -f 2- | awk '{ print "check_group_build_target(XASH_" $1 " XASH_PLATFORM)" }'
# grep "#define ARCHITECTURE" buildenums.h | cut -d' ' -f 2 | cut -d_ -f 2- | awk '{ print "check_group_build_target(XASH_" $1 " XASH_ARCHITECTURE)"
# grep "#define ENDIAN" buildenums.h  | cut -d' ' -f 2 | cut -d_ -f 2- | awk '{ print "check_group_build_target(XASH_" $1 "_ENDIAN XASH_ENDIANNESS)"}'
# echo "if(XASH_ARM)"
# grep '^#undef XASH' build.h | grep "XASH_ARM[v_]" |  awk '{ print "check_build_target(" $2 ")"}'
# echo "endif()"
# echo "if(XASH_RISCV)"
# grep '^#undef XASH' build.h | grep "XASH_RISCV_" |  awk '{ print "check_build_target(" $2 ")"}'
# echo "endif()"

set(CMAKE_REQUIRED_INCLUDES "${PROJECT_SOURCE_DIR}/public/")
check_build_target(XASH_64BIT)
check_group_build_target(XASH_ANDROID XASH_PLATFORM)
check_group_build_target(XASH_WIN32 XASH_PLATFORM)
check_group_build_target(XASH_LINUX XASH_PLATFORM)
check_group_build_target(XASH_FREEBSD XASH_PLATFORM)
check_group_build_target(XASH_APPLE XASH_PLATFORM)
check_group_build_target(XASH_NETBSD XASH_PLATFORM)
check_group_build_target(XASH_OPENBSD XASH_PLATFORM)
check_group_build_target(XASH_EMSCRIPTEN XASH_PLATFORM)
check_group_build_target(XASH_DOS4GW XASH_PLATFORM)
check_group_build_target(XASH_HAIKU XASH_PLATFORM)
check_group_build_target(XASH_SERENITY XASH_PLATFORM)
check_group_build_target(XASH_IRIX XASH_PLATFORM)
check_group_build_target(XASH_NSWITCH XASH_PLATFORM)
check_group_build_target(XASH_PSVITA XASH_PLATFORM)
check_group_build_target(XASH_LINUX_UNKNOWN XASH_PLATFORM)
check_group_build_target(XASH_X86 XASH_ARCHITECTURE)
check_group_build_target(XASH_AMD64 XASH_ARCHITECTURE)
check_group_build_target(XASH_ARM XASH_ARCHITECTURE)
check_group_build_target(XASH_MIPS XASH_ARCHITECTURE)
check_group_build_target(XASH_JS XASH_ARCHITECTURE)
check_group_build_target(XASH_E2K XASH_ARCHITECTURE)
check_group_build_target(XASH_RISCV XASH_ARCHITECTURE)
check_group_build_target(XASH_LITTLE_ENDIAN XASH_ENDIANNESS)
check_group_build_target(XASH_BIG_ENDIAN XASH_ENDIANNESS)
if(XASH_ARM)
check_build_target(XASH_ARM_HARDFP)
check_build_target(XASH_ARM_SOFTFP)
check_build_target(XASH_ARMv4)
check_build_target(XASH_ARMv5)
check_build_target(XASH_ARMv6)
check_build_target(XASH_ARMv7)
check_build_target(XASH_ARMv8)
endif()
if(XASH_RISCV)
check_build_target(XASH_RISCV_DOUBLEFP)
check_build_target(XASH_RISCV_SINGLEFP)
check_build_target(XASH_RISCV_SOFTFP)
endif()
unset(CMAKE_REQUIRED_INCLUDES)

# engine/common/build.c
if(XASH_ANDROID)
	set(BUILDOS "android")
elseif(XASH_LINUX_UNKNOWN)
	set(BUILDOS "linuxunkabi")
elseif(XASH_WIN32 OR XASH_LINUX OR XASH_APPLE)
	set(BUILDOS "") # no prefix for default OS
elseif(XASH_FREEBSD)
	set(BUILDOS "freebsd")
elseif(XASH_NETBSD)
	set(BUILDOS "netbsd")
elseif(XASH_OPENBSD)
	set(BUILDOS "openbsd")
elseif(XASH_EMSCRIPTEN)
	set(BUILDOS "emscripten")
elseif(XASH_DOS4GW)
	set(BUILDOS "DOS4GW")
elseif(XASH_HAIKU)
	set(BUILDOS "haiku")
elseif(XASH_SERENITY)
	set(BUILDOS "serenityos")
elseif(XASH_NSWITCH)
	set(BUILDOS "nswitch")
elseif(XASH_PSVITA)
	set(BUILDOS "psvita")
elseif(XASH_IRIX)
	set(BUILDOS "irix")
else()
	message(SEND_ERROR "Place your operating system name here! If this is a mistake, try to fix conditions above and report a bug")
endif()

if(XASH_AMD64)
	set(BUILDARCH "amd64")
elseif(XASH_X86)
	if(XASH_WIN32 OR XASH_LINUX OR XASH_APPLE)
		set(BUILDARCH "") # no prefix for default OS
	else()
		set(BUILDARCH "i386")
	endif()
elseif(XASH_ARM AND XASH_64BIT)
	set(BUILDARCH "arm64")
elseif(XASH_ARM)
	set(BUILDARCH "armv")
	if(XASH_ARMv8)
		set(BUILDARCH "${BUILDARCH}8_32")
	elseif(XASH_ARMv7)
		set(BUILDARCH "${BUILDARCH}7")
	elseif(XASH_ARMv6)
		set(BUILDARCH "${BUILDARCH}6")
	elseif(XASH_ARMv5)
		set(BUILDARCH "${BUILDARCH}5")
	elseif(XASH_ARMv4)
		set(BUILDARCH "${BUILDARCH}4")
	else()
		message(SEND_ERROR "Unknown ARM")
	endif()

	if(XASH_ARM_HARDFP)
		set(BUILDARCH "${BUILDARCH}hf")
	else()
		set(BUILDARCH "${BUILDARCH}l")
	endif()
elseif(XASH_MIPS)
	set(BUILDARCH "mips")
	if(XASH_64BIT)
		set(BUILDARCH "${BUILDARCH}64")
	endif()

	if(XASH_LITTLE_ENDIAN)
		set(BUILDARCH "${BUILDARCH}el")
	endif()
elseif(XASH_RISCV)
	set(BUILDARCH "riscv")
	if(XASH_64BIT)
		set(BUILDARCH "${BUILDARCH}64")
	else()
		set(BUILDARCH "${BUILDARCH}32")
	endif()

	if(XASH_RISCV_DOUBLEFP)
		set(BUILDARCH "${BUILDARCH}d")
	elseif(XASH_RISCV_SINGLEFP)
		set(BUILDARCH "${BUILDARCH}f")
	endif()
elseif(XASH_JS)
	set(BUILDARCH "javascript")
elseif(XASH_E2K)
	set(BUILDARCH "e2k")
else()
	message(SEND_ERROR "Place your architecture name here! If this is a mistake, try to fix conditions above and report a bug")
endif()

if(BUILDOS STREQUAL "android")
	set(POSTFIX "") # force disable for Android, as Android ports aren't distributed in normal way and doesn't follow library naming
elseif(BUILDOS AND BUILDARCH)
	set(POSTFIX "_${BUILDOS}_${BUILDARCH}")
elseif(BUILDARCH)
	set(POSTFIX "_${BUILDARCH}")
else()
	set(POSTFIX "")
endif()

message(STATUS "Library postfix: " ${POSTFIX})

set(CMAKE_RELEASE_POSTFIX ${POSTFIX})
set(CMAKE_DEBUG_POSTFIX ${POSTFIX})
set(CMAKE_RELWITHDEBINFO_POSTFIX ${POSTFIX})
set(CMAKE_MINSIZEREL_POSTFIX ${POSTFIX})
set(CMAKE_POSTFIX ${POSTFIX})