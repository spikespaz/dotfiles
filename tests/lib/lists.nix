{ lib }: {
  indicesOf = lib.mkTests {
    found = {
      expr = lib.indicesOf 1 [ 0 1 0 0 0 1 0 1 0 111 ];
      result = [ 1 5 7 9 10 11 ];
    };
  };
}
