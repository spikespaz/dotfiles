{ lib }:
lib.birdos.mkTestSuite {
  indicesOf = [{
    name = "finds multiple indices";
    expr = lib.indicesOf 1 [ 0 1 0 0 0 1 0 1 0 111 ];
    expect = [ 1 5 7 9 10 11 ];
  }];
}
