#! /usr/bin/perl -w

# $Id: md5dups.pl,v 1.8 2009-11-12 22:26:58 mca1001 Exp $

=head1 README

Reads md5sum sum entries (piped, or from some files) and outputs a
list of all the duplicates and then all the other files, eg.

 md5sum oldcopy/* newcopy/* | md5dups.pl | less

=cut

use strict;
use vars qw(%sums);

# read inputs on command line, take MD5SUM from each
# output list of identical items

my $fn;
%sums = (); # key = sum, value = array of "filename\tsourcefile"

@ARGV = ("-") unless @ARGV; # hacketty hack  8-)

foreach $fn (@ARGV) {
    open INP, "<$fn" or die "Couldn't read '$fn': $!";
    while (<INP>) {
	chomp;
	unless ( /^([\da-f]{32,40})[: ][ *](.+)$/i ) {
	    warn "Ignored bad input line '$_' in $fn";
	    next;
	}
	$sums{$1} = [] unless defined $sums{$1};
	push @{$sums{$1}}, "$2\t$fn";
    }
    close INP;
}

my $sum;
my @sums = sort {$sums{$a}->[0] cmp $sums{$b}->[0]} keys %sums;

foreach $sum (@sums) {
    if (@{$sums{$sum}} != 1) {
	print "$sum: ";
	print join "\n".(' 'x34), @{$sums{$sum}};
	print "\n";
    }
}

foreach $sum (@sums) {
    if (@{$sums{$sum}} == 1) {
	print "$sum. $sums{$sum}[0]\n";
    }
}

exit 0;

__DATA__
	if (@{$sums{$sum}} == 2) {
	    my ($src, $dest) = @{$sums{$sum}};
	    foreach ($src, $dest) { s/\tmd5-[.\w]+$// or die }
	    my ($src_bit, $dest_bit) = ();
	    $src_bit = $1 if
		$src =~ m@^/mnt/eeny/collections/mr-bolt/(.+)$@i;
	    $dest_bit = $1 if
		$dest =~ m@^/data/Music/Craig/(.+)$@i;
	    if (defined $src_bit && defined $dest_bit) {
		rename($src, "/mnt/eeny/collections/mr-bolt/$dest_bit")
		    or die "rename failed $src, $dest";
		print "rm \"$dest\"\n";
#		print "Add: ".substr($dest_bit, 0, length($dest_bit)-length($src_bit))."\n";
	    }
	} else {
	    print "--> not 2!\n";
	}
