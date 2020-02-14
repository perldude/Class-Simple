# $Id$

package Foo;
use base qw(Class::Simple);

Foo->privatize(qw(bar));

1;

package Bar;
use base qw(Class::Simple);

1;

use Test::More tests => 5;
BEGIN { use_ok('Class::Simple') };				##

my $bar = Bar->new();
eval { $bar->set_bar(1) };
diag($@) if $@;
ok(!$@, 'Privatization separates classes.');			##

Bar->privatize(qw(milk hamburger));

my $cow = Bar->new();
ok($cow, 'We have a cow, man.');				##
$cow->readonly_milk(1);
ok($cow->milk, "Cow's milk is okay, man.");			##
eval { $cow->set_milk(2); };
like($@, qr/readonly/, "Don't mess with a cow's milk, man.");	##
