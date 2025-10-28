class OpenOcd < Formula
  desc "On-chip debugging, in-system programming and boundary-scan testing"
  homepage "https://openocd.org/"
  url "https://downloads.sourceforge.net/project/openocd/openocd/0.12.0/openocd-0.12.0.tar.bz2"
  sha256 "af254788be98861f2bd9103fe6e60a774ec96a8c374744eef9197f6043075afa"
  license "GPL-2.0-or-later"

  bottle do
    sha256 "b98629423454d99b9997ab464b6a61dcf55e04effe3c8355060b148ad2e081f6" => :tiger_altivec
  end

  # Switch from binary to hex constants to allow builds with GCC older than 4.3
  # MIN is already a macro defined in system's headers for networking
  # Help older compilers with enums inside a struct & linking as -rpath may not be supported
  # libproc showed up in Leopard, guard off functionality.
  patch :p0, :DATA

  head do
    url "https://github.com/openocd-org/openocd.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on "texinfo" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "capstone"
  # depends_on "hidapi"
  depends_on "libftdi"
  depends_on "libusb"

  def install
    ENV["CCACHE"] = "none"

    args = ["--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--enable-buspirate",
            "--enable-stlink",
            "--enable-dummy",
            "--enable-jlink",
            "--enable-jtag_vpi",
            "--enable-remote-bitbang"
           ]

    args << "ac_cv_func_realpath=no" if MacOS.version < :leopard # Need the modern implementation, lacking.

    system "./bootstrap", "nosubmodule" if build.head?
    system "./configure", *args
    system "make", "install"
  end
end
__END__
--- src/flash/nor/xcf.c.orig	2024-01-27 18:23:11.000000000 +0000
+++ src/flash/nor/xcf.c	2024-01-27 18:25:03.000000000 +0000
@@ -130,8 +130,8 @@
 	jtag_add_ir_scan(bank->target->tap, &scan, TAP_IDLE);
 	jtag_execute_queue();
 
-	ret.isc_error   = ((irdata[0] >> 7) & 3) == 0b01;
-	ret.prog_error  = ((irdata[0] >> 5) & 3) == 0b01;
+	ret.isc_error   = ((irdata[0] >> 7) & 3) == 1;
+	ret.prog_error  = ((irdata[0] >> 5) & 3) == 1;
 	ret.prog_busy   = ((irdata[0] >> 4) & 1) == 0;
 	ret.isc_mode    = ((irdata[0] >> 3) & 1) == 1;
 
@@ -528,7 +528,7 @@
 {
 	uint8_t buf[4];
 	uint32_t btc = 0xFFFFFFFF;
-	btc &= ~0b1111;
+	btc &= ~0xF;
 	btc |= ((bank->num_sectors - 1) << 2);
 	btc &= ~(1 << 4);
 	h_u32_to_le(buf, btc);
--- src/jtag/drivers/libjaylink/libjaylink/libjaylink-internal.h.orig	2024-01-27 18:12:05.000000000 +0000
+++ src/jtag/drivers/libjaylink/libjaylink/libjaylink-internal.h	2024-01-27 18:12:18.000000000 +0000
@@ -56,7 +56,7 @@
 #endif
 
 /** Calculate the minimum of two numeric values. */
-#define MIN(a, b) (((a) < (b)) ? (a) : (b))
+#define OUR_MIN(a, b) (((a) < (b)) ? (a) : (b))
 
 struct jaylink_context {
 #ifdef HAVE_LIBUSB
--- src/jtag/drivers/libjaylink/libjaylink/transport_tcp.c.orig	2024-01-27 18:13:18.000000000 +0000
+++ src/jtag/drivers/libjaylink/libjaylink/transport_tcp.c	2024-01-27 18:13:27.000000000 +0000
@@ -532,7 +532,7 @@
 	if (!devh->write_pos)
 		return _send(devh, buffer, length);
 
-	tmp = MIN(length, devh->buffer_size - devh->write_pos);
+	tmp = OUR_MIN(length, devh->buffer_size - devh->write_pos);
 
 	/*
 	 * Fill up the internal buffer in order to reduce the number of
--- src/jtag/drivers/libjaylink/libjaylink/transport_usb.c.orig	2024-01-27 18:12:38.000000000 +0000
+++ src/jtag/drivers/libjaylink/libjaylink/transport_usb.c	2024-01-27 18:12:55.000000000 +0000
@@ -409,7 +409,7 @@
 	while (tries > 0 && length > 0) {
 		/* Send data in chunks of CHUNK_SIZE bytes to the device. */
 		ret = libusb_bulk_transfer(devh->usb_devh, devh->endpoint_out,
-			(unsigned char *)buffer, MIN(CHUNK_SIZE, length),
+			(unsigned char *)buffer, OUR_MIN(CHUNK_SIZE, length),
 			&transferred, USB_TIMEOUT);
 
 		if (ret == LIBUSB_SUCCESS) {
@@ -498,7 +498,7 @@
 		num_chunks++;
 
 	fill_bytes = (num_chunks * CHUNK_SIZE) - devh->write_pos;
-	tmp = MIN(length, fill_bytes);
+	tmp = OUR_MIN(length, fill_bytes);
 
 	if (tmp > 0) {
 		memcpy(devh->buffer + devh->write_pos, buffer, tmp);
@@ -583,7 +583,7 @@
 			if (ret != JAYLINK_OK)
 				return ret;
 
-			tmp = MIN(bytes_received, length);
+			tmp = OUR_MIN(bytes_received, length);
 			memcpy(buffer, devh->buffer, tmp);
 
 			/*
--- src/target/riscv/riscv.c.orig	2024-01-27 19:09:18.000000000 +0000
+++ src/target/riscv/riscv.c	2024-01-27 19:09:38.000000000 +0000
@@ -3937,7 +3937,7 @@
 		.type = REG_TYPE_ARCH_DEFINED,
 		.id = "FPU_FD",
 		.type_class = REG_TYPE_CLASS_UNION,
-		.reg_type_union = &single_double_union
+		{ .reg_type_union = &single_double_union }
 	};
 	static struct reg_data_type type_uint8 = { .type = REG_TYPE_UINT8, .id = "uint8" };
 	static struct reg_data_type type_uint16 = { .type = REG_TYPE_UINT16, .id = "uint16" };
--- jimtcl/autosetup/cc-shared.tcl.orig	2024-01-27 21:08:29.000000000 +0000
+++ jimtcl/autosetup/cc-shared.tcl	2024-01-27 21:12:34.000000000 +0000
@@ -46,6 +46,7 @@
 		define SH_CFLAGS -dynamic
 		define SH_LDFLAGS -dynamiclib
 		define SH_LINKFLAGS ""
+		define SH_LINKRPATH "-L%s"
 		define SH_SOEXT .dylib
 		define SH_SOEXTVER .%s.dylib
 		define SH_SOPREFIX -Wl,-install_name,
--- src/target/armv8_dpm.c.orig	2024-01-28 21:01:24.000000000 +0000
+++ src/target/armv8_dpm.c	2024-01-28 21:05:05.000000000 +0000
@@ -46,7 +46,7 @@
 	dpm->last_el = el;
 
 	/* In Debug state, each bit gives the current Execution state of each EL */
-	if ((rw >> el) & 0b1)
+	if ((rw >> el) & 1)
 		return ARM_STATE_AARCH64;
 
 	return ARM_STATE_ARM;
--- src/target/armv8_opcodes.h.orig	2024-01-28 21:06:46.000000000 +0000
+++ src/target/armv8_opcodes.h	2024-01-29 00:09:48.000000000 +0000
@@ -30,13 +30,13 @@
 #define SYSTEM_DAIF_MASK		0x3C0
 #define SYSTEM_DAIF_SHIFT		6
 
-#define SYSTEM_ELR_EL1			0b1100001000000001
-#define SYSTEM_ELR_EL2			0b1110001000000001
-#define SYSTEM_ELR_EL3			0b1111001000000001
-
-#define SYSTEM_SCTLR_EL1	0b1100000010000000
-#define SYSTEM_SCTLR_EL2	0b1110000010000000
-#define SYSTEM_SCTLR_EL3	0b1111000010000000
+#define SYSTEM_ELR_EL1			0xC201
+#define SYSTEM_ELR_EL2			0xE201
+#define SYSTEM_ELR_EL3			0xF201
+
+#define SYSTEM_SCTLR_EL1	0xC080
+#define SYSTEM_SCTLR_EL2	0xE080
+#define SYSTEM_SCTLR_EL3	0xF080
 
 #define SYSTEM_FPCR			0b1101101000100000
 #define SYSTEM_FPSR			0b1101101000100001
@@ -51,55 +51,55 @@
 #define SYSTEM_SPSR_IRQ			0b1110001000011000
 #define SYSTEM_SPSR_UND			0b1110001000011010
 
-#define SYSTEM_SPSR_EL1			0b1100001000000000
-#define SYSTEM_SPSR_EL2			0b1110001000000000
-#define SYSTEM_SPSR_EL3			0b1111001000000000
+#define SYSTEM_SPSR_EL1			0xC200
+#define SYSTEM_SPSR_EL2			0xE200
+#define SYSTEM_SPSR_EL3			0xF200
 
 #define SYSTEM_ISR_EL1			0b1100011000001000
 
 #define SYSTEM_DBG_DSPSR_EL0    0b1101101000101000
 #define SYSTEM_DBG_DLR_EL0		0b1101101000101001
-#define SYSTEM_DBG_DTRRX_EL0	0b1001100000101000
-#define SYSTEM_DBG_DTRTX_EL0	0b1001100000101000
-#define SYSTEM_DBG_DBGDTR_EL0	0b1001100000100000
-
-#define SYSTEM_CCSIDR			0b1100100000000000
-#define SYSTEM_CLIDR			0b1100100000000001
-#define SYSTEM_CSSELR			0b1101000000000000
+#define SYSTEM_DBG_DTRRX_EL0	0x9828
+#define SYSTEM_DBG_DTRTX_EL0	0x9828
+#define SYSTEM_DBG_DBGDTR_EL0	0x9820
+
+#define SYSTEM_CCSIDR			0xC800
+#define SYSTEM_CLIDR			0xC801
+#define SYSTEM_CSSELR			0xD000
 #define SYSTEM_CTYPE			0b1101100000000001
-#define SYSTEM_CTR				0b1101100000000001
+#define SYSTEM_CTR			0xD801
 
-#define SYSTEM_DCCISW			0b0100001111110010
+#define SYSTEM_DCCISW			0x43F2
 #define SYSTEM_DCCSW			0b0100001111010010
-#define SYSTEM_ICIVAU			0b0101101110101001
+#define SYSTEM_ICIVAU			0x5BA9
 #define SYSTEM_DCCVAU			0b0101101111011001
-#define SYSTEM_DCCIVAC			0b0101101111110001
+#define SYSTEM_DCCIVAC			0x5BF1
 
-#define SYSTEM_MPIDR			0b1100000000000101
+#define SYSTEM_MPIDR			0xC005
 
-#define SYSTEM_TCR_EL1			0b1100000100000010
-#define SYSTEM_TCR_EL2			0b1110000100000010
-#define SYSTEM_TCR_EL3			0b1111000100000010
+#define SYSTEM_TCR_EL1			0xC102
+#define SYSTEM_TCR_EL2			0xE102
+#define SYSTEM_TCR_EL3			0xF102
 
-#define SYSTEM_TTBR0_EL1		0b1100000100000000
-#define SYSTEM_TTBR0_EL2		0b1110000100000000
-#define SYSTEM_TTBR0_EL3		0b1111000100000000
+#define SYSTEM_TTBR0_EL1		0xC100
+#define SYSTEM_TTBR0_EL2		0xE100
+#define SYSTEM_TTBR0_EL3		0xF100
 #define SYSTEM_TTBR1_EL1		0b1100000100000001
 
 /* ARMv8 address translation */
-#define SYSTEM_PAR_EL1			0b1100001110100000
-#define SYSTEM_ATS12E0R			0b0110001111000110
-#define SYSTEM_ATS12E1R			0b0110001111000100
-#define SYSTEM_ATS1E2R			0b0110001111000000
-#define SYSTEM_ATS1E3R			0b0111001111000000
+#define SYSTEM_PAR_EL1			0xC3A0
+#define SYSTEM_ATS12E0R			0x63C6
+#define SYSTEM_ATS12E1R			0x63C4
+#define SYSTEM_ATS1E2R			0x63C0
+#define SYSTEM_ATS1E3R			0x73C0
 
 /* fault status and fault address */
 #define SYSTEM_FAR_EL1			0b1100001100000000
 #define SYSTEM_FAR_EL2			0b1110001100000000
 #define SYSTEM_FAR_EL3			0b1111001100000000
-#define SYSTEM_ESR_EL1			0b1100001010010000
-#define SYSTEM_ESR_EL2			0b1110001010010000
-#define SYSTEM_ESR_EL3			0b1111001010010000
+#define SYSTEM_ESR_EL1			0xC290
+#define SYSTEM_ESR_EL2			0xE290
+#define SYSTEM_ESR_EL3			0xF290
 
 #define ARMV8_MRS_DSPSR(rt)	(0xd53b4500 | (rt))
 #define ARMV8_MSR_DSPSR(rt)	(0xd51b4500 | (rt))
--- src/helper/options.c.orig	2024-02-03 06:11:01.000000000 +0000
+++ src/helper/options.c	2024-02-03 06:18:07.000000000 +0000
@@ -22,8 +22,11 @@
 #include <stdlib.h>
 #include <string.h>
 #if IS_DARWIN
+#include <AvailabilityMacros.h>
+#if defined(MAC_OS_X_VERSION_MIN_REQUIRED) && MAC_OS_X_VERSION_MIN_REQUIRED >= 1050
 #include <libproc.h>
 #endif
+#endif
 /* sys/sysctl.h is deprecated on Linux from glibc 2.30 */
 #ifndef __linux__
 #ifdef HAVE_SYS_SYSCTL_H
@@ -74,7 +77,7 @@
 				*p = '/';
 		}
 
-#elif IS_DARWIN
+#elif IS_DARWIN && defined(MAC_OS_X_VERSION_MIN_REQUIRED) && MAC_OS_X_VERSION_MIN_REQUIRED >= 1050
 		exepath = malloc(PROC_PIDPATHINFO_MAXSIZE);
 		if (!exepath)
 			break;
@@ -190,7 +193,7 @@
 #endif
 
 	const char *home = getenv("HOME");
-#if IS_DARWIN
+#if IS_DARWIN && defined(MAC_OS_X_VERSION_MIN_REQUIRED) && MAC_OS_X_VERSION_MIN_REQUIRED >= 1050
 	if (home) {
 		path = alloc_printf("%s/Library/Preferences/org.openocd", home);
 		if (path) {
