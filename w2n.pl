#!/usr/bin/env perl

#use strict;
#use warnings;
use Lingua::EN::Words2Nums;

my ( $num, $e, $f, $fromCli );

if (@ARGV) {
  $fromCli = words2nums($ARGV[0]);
  print("$fromCli\n");

} else {
  print "No args provided.  Bailing...\n";
  exit(1);
}
