# GNU ARM Embedded Toolchain 10

> **DISCLAIMER**: This experimental toolchain is not meant to be used in production.

This project produces a **Platform.IO** toolchain
of [GNU ARM Embedded Toolchain 10-2020-q2-preview](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads)
, providing access to gcc-10.1, and applies fixed for current Cortex M Processors.

With a more recent compiler, the `--std=c++20` compiler flag is introduced and enables
all [C++20 Features](https://en.cppreference.com/w/cpp/compiler_support#cpp20) available in GCC 10.1, e.g:

- [Concepts and Constraints](https://en.cppreference.com/w/cpp/language/constraints)
- [Three-way comparison operator](https://en.cppreference.com/w/cpp/language/operator_comparison#Three-way_comparison)
- [Immediate Functions](https://en.cppreference.com/w/cpp/language/consteval)
- [Co-routines](https://en.cppreference.com/w/cpp/language/coroutines)
- [constinit](https://en.cppreference.com/w/cpp/language/constinit)
- [Descriptive [[nodiscard]]](https://en.cppreference.com/w/cpp/language/attributes/nodiscard)
- and more...

Keep in mind, that you will encounter various warnings during the compilation of framework libraries, since most
deprecations have not been taken into account, yet.

## Usage

### Installation

After cloning this repository, the makefile located at the project root will help conducting the installation:

```shell
make install
```

The `install` task moves the raw toolchain content to `~/.platformio/packages/toolchain-gccarmnoneeabi@10.1.1`
from where it is accessible for PlatformIO's CLI.

To further integrate the toolchain, a `package.json` is added.

Eventually, the Cortex-related fixes are applied to fully embrace the new (and older) capabilities of many bundled C++
Standard Library components.

> Note: Once the toolchain is used in any project, the postfix `@10.1.1` is redacted from the toolchain path.
> Therefore, to safely remove the toolchain, you need to use PIO's CLI!

### PlatformIO Project

After using `make install`ing the toolchain, it may be referenced in a project's `platform.ini`:

```ini
# Exemplary PlatformIO configuration

[env:teensy41]
platform = teensy
board = teensy41
framework = arduino
platform_packages = toolchain-gccarmnoneeabi@10.1.1

build_unflags =
    -std=gnu++14

build_flags =
    -std=gnu++20
    -Wno-unknown-pragmas

```

A re-run of `platformio init --ide clion` will update the CMake configuration to use the new toolchain.

## Fix for Cortex M Processors

The Code, which uses idioms from the C++ standard library, requires the linker to access one of the following archives:

| Library                    | Model                                              |
| -------------------------- | -------------------------------------------------- |
| `libarm_cortexM0l_math.a`    | M0/M0+, Little endian                              |
| `libarm_cortexM4l_math.a`    | M4, Little endian                                  |
| `libarm_cortexM4lf_math.a`   | M4, Little endian, Floating Point Unit             |
| `libarm_cortexM7lfsp_math.a` | M7, Little endian, Single Precision Floating Point |

For example, when using `std::vector`s on a Teensy 4.x, which runs a Cortex-M7, the linker scripts seems to be
missing `libarm_cortexM7lfsp_math.a`.

As a workaround for those cases, the listed archives were extracted
from [`toolchain-gccarmnoneeabi@1.50401.190816`](https://bintray.com/platformio/dl-packages/toolchain-gccarmnoneeabi/1.50401.190816)
and moved to the toolchain's `/lib` folder.
