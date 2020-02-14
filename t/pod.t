# $Id$

use Test::More;
eval 'use Test::Pod';
plan skip_all => "Test::Pod is not installed" if $@;
all_pod_files_ok();

1;
