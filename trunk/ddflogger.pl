#!/usr/bin/perl -w
# 
# Script to do burn-in testing of a hard drive. Repeatedly seeks,
# to random locations, and reads a block of data. 
#
# Reads from the device file, so the disk need not be partitioned
# or formatted beforehand.
#
# Command line arguments:
# -d device name
# -n read count
# eg
# ddflogger.pl -d /dev/sdd -n 65536
#
# pfh 4/10/01
# phubbard@computer.org

use Fcntl;
use IO::Seekable;
use Time::Local;
use Getopt::Std;

#########################
# Parameters
# Device to exercise - command line -d
$FNAME = "/dev/sdd";

# Read forever by default - command line -n
$READ_MAX = -1;

# Number of bytes to read at each seek location
$read_size = 1024 * 512;

# Screen update rate - the stats will update every N seeks.
$update_rate = 25;

# Variables, counters
$cur_seek = 0;
$bytes_read = 0;
$seeks_done = 0;
$done = 0;

##########################
# Start of code

# Install break handler
$SIG{"INT"} = \&ctrl_c_handler;

# Parse the command line options
%option = ();
getopts("d:n:", \%option);

if ($option{d}) {
    print "Setting device to $option{d}\n";
    $FNAME = $option{d};
}

if ($option{n}) {
    print "Setting read count to $option{n}";
    $READ_MAX = $option{n};
}

open FNAME or die "can't open device $FNAME: $!\n";

# Determine device size by seeking to EOF
seek(FNAME, 0, SEEK_END) or die "Seeking: $!";
$max_size = tell(FNAME);

# Quick sanity check
if ($max_size <= $read_size) {
    print("\nDevice $FNAME too small: size $max_size, read size $read_size");
    exit(1);
}

# Read and save start time
$start_time = time();

# Output run parameters
print("\nDevice: $FNAME device size: ", $max_size, " bytes\n");
print("\nRead block size: $read_size started at ", scalar localtime($start_time));

if($READ_MAX > 0) {
    print("\nFinite read mode: will read $READ_MAX times\n");
} else {
    print("\nInfinite read mode: will read until interrupted\n");
}

print "-------------------------------------------------------------------------\n";
print "Starting run...";

# Exercise the disk
while($done == 0)
{
    # Generate a destination address
    $cur_seek = int(rand($max_size - $read_size));

    # Try to go there
    seek(FNAME, $cur_seek, SEEK_SET) or die "Error in seek: $!";

    # Read what's there into scratch buffer
    read FNAME, $my_buf, $read_size;

    # Increment counters
    $num_reads++;
    $seeks_done++;
    $bytes_read += $read_size;

    # Check ending condition
    if(($num_reads >= $READ_MAX) &&
       ($READ_MAX > 0)) {
	$done = 1;
    }

    # Periodic screen updates as to progress
    if(($num_reads % $update_rate) == 0) {
	print("\n$num_reads reads, $bytes_read bytes read");
    }
}

# Ending stats
$end_time = time();
print "\n-------------------------------------------------------------------------";
print "\n\nDone at ", scalar localtime($end_time), " elapsed time ",
      $end_time - $start_time, " seconds.";
print "\n$num_reads reads, $bytes_read bytes read, $seeks_done seeks completed\n";
print "No errors found.\n";

close FNAME;

# Subroutine, control-c handler
sub ctrl_c_handler {
    print "\nControl C pressed or SIGINT received, exiting\n";
    # All we have to do is set the done flag and the main loop will terminate
    $done = 1;
}
