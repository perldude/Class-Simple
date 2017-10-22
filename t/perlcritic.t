use Test::More;

SKIP: {
	eval { require Test::Perl::Critic };
	plan(skip_all => 'Test::Perl::Critic is not installed', 1) if $@;

	Test::Perl::Critic->import(-profile => 't/perlcriticrc');
	all_critic_ok();
}
