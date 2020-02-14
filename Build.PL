use Module::Build;
use Pod::Markdown;

my $build = Module::Build->new(
  module_name  => 'Class-Simple',
  license      => 'perl',
  requires     => {
    'Class::ISA'   => 0.32,
    'Scalar::Util' => 0,
    'List::Util'   => 0,
  },
  test_requires => {
    'Test::Perl::Critic' => 0,
    'Test::Exception'    => 0,
  },
  configure_requires => {
    'Module::Build' => 0,
    'Pod::Markdown' => 0,
  },
  abstract_from     => 'lib/Class/Simple.pm',
  author_from       => 'lib/Class/Simple.pm',
  dist_version_from => 'lib/Class/Simple.pm',
  meta_merge => {
    resources => {
      repository => 'https://github.com/perldude/Class-Simple',
    }
  },
);

$build->create_build_script;

$build->delete_filetree('README');
$build->log_info("Creating README using Pod::Markdown\n");
my $md = Pod::Markdown->new();
if (open(my $fh, '>', 'README.md')) {
  $md->output_fh($fh);
  $md->parse_file($build->dist_version_from);
  close($fh);
}
else {
  $build->log_warn("Cannot write to README.md: $!\n");
}

