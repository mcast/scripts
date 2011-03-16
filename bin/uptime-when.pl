#! /usr/bin/perl

use strict;
use warnings;

=head1 NAME

uptime-when.pl - convert dmesg timestamp to localtime

=head1 SYNTAX

 $ dmesg | tail -n2
 [5887848.292020] nfs: server netapp1a not responding, still trying
 [5887956.603171] nfs: server netapp1a OK
 $ uptime-when.pl 5887848 5887956
 Booted at 1281972786 = 2010-08-16t16:33:06 localtime
 boot+5887848 = 1287860634 = 2010-10-23t20:03:54
 boot+5887956 = 1287860742 = 2010-10-23t20:05:42

 $ dmesg | tail -n2 | uptime-when.pl
 Booted at 1294587756.03 = 2011-01-09t15:42:36 localtime
 2011-02-27t22:12:32.991459: [4256996.991459] LustreError: 11-0: an error occurred while communicating with 172.31.32.5@tcp. The mds_close operation failed with -116
 2011-02-27t22:12:33.134882: [4256997.134882] LustreError: 20386:0:(file.c:113:ll_close_inode_openhandle()) inode 95099399 mdc close failed: rc = -116

=head1 DESCRIPTION

It's a quick'n'dirty script.

=head1 SEE ALSO

F<scripts/show_delta> in the Linux kernel-2.6 tree.

=cut


sub main {
    open my $upfh, "<", "/proc/uptime"
      or die "Need /proc/uptime (Linux) but $!";
    my ($up, undef) = split /\s+/, <$upfh>;
    my $now = time();
    close $upfh;

    my $booted = $now - $up;
    print "Booted at $booted = ".ts($booted)." localtime\n";
    if (@ARGV) {
	while (my $t = shift @ARGV) {
	    my $tb = $booted + $t;
	    print "boot+$t = $tb = ".ts($tb)."\n";
	}
    } else {
	while (my $ln = <>) {
	    if ($ln =~ m{^\[ {0,4}(\d+)\.(\d+)\] }) {
		my ($t, $frac) = ($1, $2);
		$ln = ts($booted + $t, $frac).": $ln";
	    }
	    print $ln;
	}
    }
}

sub ts {
    my ($utime, $frac) = @_;
    my @t = localtime($utime);
    return sprintf("%04d-%02d-%02dt%02d:%02d:%02d%s",
		   1900+$t[5], 1+$t[4], $t[3],
		   @t[2,1,0],
		   (defined $frac ? ".$frac" : ''));
}

main();
