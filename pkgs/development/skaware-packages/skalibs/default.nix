{
  lib,
  stdenv,
  skawarePackages,
  pkgs,
}:

skawarePackages.buildPackage {
  pname = "skalibs";
  version = "2.14.4.0";
  sha256 = "sha256-DmJiYYSMySBzj5L9UKJMFLIeMDBt/tl7hDU2n0uuAKU=";

  description = "Set of general-purpose C programming libraries";

  outputs = [
    "lib"
    "dev"
    "doc"
    "out"
  ];

  configureFlags = [
    # assume /dev/random works
    "--enable-force-devr"
    "--libdir=\${lib}/lib"
    "--dynlibdir=\${lib}/lib"
    "--includedir=\${dev}/include"
    "--sysdepdir=\${lib}/lib/skalibs/sysdeps"
    # Empty the default path, which would be "/usr/bin:bin".
    # It would be set when PATH is empty. This hurts hermeticity.
    "--with-default-path="

  ]
  ++ lib.optionals (stdenv.buildPlatform.config != stdenv.hostPlatform.config) [
    # There's a fallback path for BSDs.
    "--with-sysdep-procselfexe=${
      if stdenv.hostPlatform.isLinux then
        "/proc/self/exe"
      else if stdenv.hostPlatform.isSunOS then
        "/proc/self/path/a.out"
      else
        "none"
    }"
    # ./configure: sysdep posixspawnearlyreturn cannot be autodetected
    # when cross-compiling. Please manually provide a value with the
    # --with-sysdep-posixspawnearlyreturn=yes|no|... option.
    #
    # posixspawnearlyreturn: `yes` if the target has a broken
    # `posix_spawn()` implementation that can return before the
    # child has successfully exec'ed. That happens with old glibcs
    # and some virtual platforms.
    "--with-sysdep-posixspawnearlyreturn=no"
  ];

  postInstall = ''
    rm -rf sysdeps.cfg
    rm libskarnet.*

    mv doc $doc/share/doc/skalibs/html
  '';

  passthru.tests = {
    # fdtools is one of the few non-skalib packages that depends on skalibs
    # and might break if skalibs gets an breaking update.
    fdtools = pkgs.fdtools;
  };

}
