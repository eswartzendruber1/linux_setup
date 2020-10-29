#!/usr/bin/perl -w

# USAGE:

my $file_in = $ARGV[0];
my $file_out = $ARGV[1];
open (INPUT, "$file_in");
open (OUTPUT, "> $file_out");
while (<INPUT>) {
    chomp;
    my $line_in = $_;
    if ($line_in =~ /^[01]* [01]*$/) {
        $line_in =~ s/^[01]* ([01]*)$/$1/;
        $hex = sprintf('%X', oct("0b$line_in"));
        print OUTPUT "$hex\n";
    }
}

close (INPUT);
close (OUTPUT);

