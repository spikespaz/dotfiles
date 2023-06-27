{ lib }:
let
  # Prefix functions are implemented by the terms described on Wikipedia:
  # <https://en.wikipedia.org/wiki/Byte#Multiple-byte_units>

  # Both multiples of 1024 (for example, kibibytes)
  # and 1000 (kilobytes) are provided.

  # IEC 80000-13 Suffixes
  # <https://en.wikipedia.org/wiki/ISO/IEC_80000>

  # Metric Suffixes
  # <https://en.wikipedia.org/wiki/Metric_prefix>

  # Functions to take units as input and output number of bytes.
  bytes = {
    KiB = x: 1024 * x;
    MiB = x: (lib.pow 1024 2) * x;
    GiB = x: (lib.pow 1024 3) * x;
    TiB = x: (lib.pow 1024 4) * x;
    PiB = x: (lib.pow 1024 5);

    kB = x: 1000 * x;
    MB = x: (lib.pow 1000 2) * x;
    GB = x: (lib.pow 1000 3) * x;
    TB = x: (lib.pow 1000 4) * x;
    PB = x: (lib.pow 1000 5) * x;
  };

  # Functions to take units as input and output number of K-prefixed units.
  kbytes = {
    MiB = x: 1024 * x;
    GiB = x: (lib.pow 1024 2) * x;
    TiB = x: (lib.pow 1024 3) * x;
    PiB = x: (lib.pow 1024 4);

    MB = x: 1024 * x;
    GB = x: (lib.pow 1000 2) * x;
    TB = x: (lib.pow 1000 3) * x;
    PB = x: (lib.pow 1000 4) * x;
  };
in {
  #
  inherit bytes kbytes;
}
