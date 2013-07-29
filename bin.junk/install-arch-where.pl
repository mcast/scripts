#! /usr/bin/env perl
use strict;
use warnings;

use Module::Build;
use ExtUtils::MakeMaker;
use File::Temp 'tempdir';
use YAML 'Dump';


# written with doc from 0.4003
sub for_MB {
    local @ARGV = ('--quiet', @_);

    my $mb = Module::Build->new(module_name => 'Acme::Junk', dist_version => 0);

    my %info =
      (ARGV => \@ARGV,
       install_destination => {
                               map {( $_ => $mb->install_destination($_) )}
                               $mb->install_types
                              },
      );
    return \%info;
}


# probably version-generic
sub for_EU_MM {
    local @ARGV = @_;
    my $dir = tempdir('EUMM-where.XXXXXX', TMPDIR => 1, CLEANUP => 1);
    chdir $dir or die "Cannot chdir($dir): $!";
    nulfile('Makefile.PL');
    nulfile('foo.xs');

    my $frag = join '', "showvars: \n",
      map {qq{\techo "$_: '\$($_)'"\n}}
        qw( INSTALLARCHLIB INSTALLBIN );

    no warnings qw( once redefine );
    *MY::postamble = sub { return $frag }; # postamble is eaten after use?
    WriteMakefile(NAME => 'EUMM::Where', VERSION => 0);

    chdir '/' or warn "Failed to chdir out: $!";
    my %info = (ARGV => \@ARGV,
                output => scalar `cd $dir && make -s showvars`);

    return \%info;
}

sub nulfile {
    my ($fn) = @_;
    open my $fh, '>', $fn or die "Create bogus $fn: $!";
    close $fh;
    return;
}


my $dir = '/tmp/acme-junk';
my %out =
  (Perl => $^X,
   Version => $],
   install_base__MB => for_MB("--install_base=$dir"),
   prefix__MB => for_MB("--prefix=$dir"),
   install_base__EU_MM => for_EU_MM("INSTALL_BASE=$dir"),
   prefix__EU_MM => for_EU_MM("PREFIX=$dir"),
  );
print Dump(\%out);
