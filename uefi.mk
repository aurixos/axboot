###################################################################################
## Module Name:  uefi.mk                                                         ##
## Project:      AurixOS                                                         ##
##                                                                               ##
## Copyright (c) 2024 Jozef Nagy                                                 ##
##                                                                               ##
## This source is subject to the MIT License.                                    ##
## See License.txt in the root of this repository.                               ##
## All other rights reserved.                                                    ##
##                                                                               ##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    ##
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      ##
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   ##
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        ##
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, ##
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE ##
## SOFTWARE.                                                                     ##
###################################################################################

ifeq ($(ARCH),x86_64)
UEFISUF := X64
else ifeq ($(ARCH),i686)
UEFISUF := IA32
else ifeq ($(ARCH),arm)
UEFISUF := ARM
else ifeq ($(ARCH),aarch64)
UEFISUF := AA64
else ifeq ($(ARCH),riscv64)
UEFISUF := RISCV64
else
$(error Architecture not supported!)
endif

UEFI_BOOTFILE := $(BUILD_DIR)/boot/boot/BOOT$(UEFISUF).EFI

INCLUDE_DIRS += uefi/libefi include/arch/$(ARCH)/uefi

UEFI_AS := $(ARCH)-w64-mingw32-as
UEFI_CC := clang
UEFI_LD := clang

UEFI_ASFLAGS := $(ASFLAGS) \
				-DAXBOOT_UEFI=1 \
				$(foreach d, $(INCLUDE_DIRS), -I$d)

UEFI_CFLAGS := $(CFLAGS) \
				-DAXBOOT_UEFI=1 \
				$(foreach d, $(INCLUDE_DIRS), -I$d) \
				-target $(ARCH)-unknown-windows \
				-fshort-wchar \
				-fno-stack-protector \
				-fno-stack-check \
				-mgeneral-regs-only \
				-mno-80387 \
				-mno-mmx \
				-mno-sse \
				-mno-sse2

UEFI_LDFLAGS := $(LDFLAGS) \
				-target $(ARCH)-unknown-windows \
				-fuse-ld=lld-link \
				-Wl,-subsystem:efi_application \
				-Wl,-entry:uefi_entry

UEFI_CFILES := $(shell find uefi -name '*.c') $(shell find arch/$(ARCH)/uefi -name '*.c')
UEFI_ASFILES := $(shell find uefi -name '*.S') $(shell find arch/$(ARCH)/uefi -name '*.S')

UEFI_OBJ := $(UEFI_CFILES:uefi/%.c=$(BUILD_DIR)/boot/uefi/%.c.o) \
			$(UEFI_ASFILES:uefi/%.S=$(BUILD_DIR)/boot/uefi/%.S.o) \
			$(COMMON_CFILES:common/%.c=$(BUILD_DIR)/boot/uefi/common/%.c.o) \
			$(COMMON_ARCH_CFILES:arch/$(ARCH)/common/%.c=$(BUILD_DIR)/boot/uefi/arch/%.c.o) \
			$(COMMON_ARCH_ASFILES:arch/$(ARCH)/common/%.asm=$(BUILD_DIR)/boot/uefi/arch/%.asm.o)

.PHONY: install-uefi
install-uefi:
	@mkdir -p $(SYSROOT_DIR)/EFI/BOOT
	@printf "  INSTALL\t/EFI/BOOT/BOOT$(UEFISUF).EFI\n"
	@cp $(UEFI_BOOTFILE) $(SYSROOT_DIR)/EFI/BOOT/

$(UEFI_BOOTFILE): $(UEFI_OBJ)
	@mkdir -p $(@D)
	@printf "  LD\t$(notdir $@)\n"
	@$(UEFI_LD) $(UEFI_LDFLAGS) $^ -o $@

-include $(wildcard $(BUILD_DIR)/boot/*.d)

$(BUILD_DIR)/boot/uefi/%.c.o: uefi/%.c
	@mkdir -p $(@D)
	@printf "  CC\t$<\n"
	@$(UEFI_CC) $(UEFI_CFLAGS) -c $< -o $@

$(BUILD_DIR)/boot/uefi/common/%.c.o: common/%.c
	@mkdir -p $(@D)
	@printf "  CC\t$<\n"
	@$(UEFI_CC) $(UEFI_CFLAGS) -c $< -o $@

$(BUILD_DIR)/boot/uefi/arch/%.c.o: arch/$(ARCH)/common/%.c
	@mkdir -p $(@D)
	@printf "  CC\t$<\n"
	@$(UEFI_CC) $(UEFI_CFLAGS) -c $< -o $@

$(BUILD_DIR)/boot/uefi/arch/%.asm.o: arch/$(ARCH)/common/%.asm
	@mkdir -p $(@D)
	@printf "  AS\t$<\n"
	@$(UEFI_AS) $(UEFI_ASFLAGS) -c $< -o $@