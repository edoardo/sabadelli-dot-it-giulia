#!/usr/bin/env perl

use strict;
use warnings;

use CSS::Compressor ();

my @css = <>;
print CSS::Compressor::css_compress("@css");
