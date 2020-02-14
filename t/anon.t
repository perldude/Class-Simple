# $Id$

use Test::More tests => 3;
BEGIN { use_ok('Class::Simple') };		##

use Class::Simple;

my $foo = Class::Simple->new();
isa_ok($foo, 'Class::Simple');			##
$foo->set_bar(1);
is($foo->bar, 1, 'Anonymous setting.');		##

1;
