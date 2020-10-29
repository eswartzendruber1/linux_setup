#!/usr/bin/perl -w

my $ext = "";
my $new_string = "";
my $old_string = "";
my $ext_next = 0;
my $new_string_done = 0;
my $old_string_done = 0;
my @files = ();
my $force = 0;


foreach $argnum (0 .. $#ARGV) {

   if ($ext_next == 1) {
       $ext = $ARGV[$argnum];
       print "ext = $ext\n";
   } elsif ($ARGV[$argnum] =~ /-e/) {
       $ext_next = 1;
   } elsif ($ARGV[$argnum] =~ /-f/) {
       $force = 1;
   } elsif ($old_string_done == 0) {
       $old_string_done = 1;
       $old_string = $ARGV[$argnum];
       print "old_string = $old_string\n";
   } elsif ($new_string_done == 0) {
       $new_string_done = 1;
       $new_string = $ARGV[$argnum];
       print "new_string = $new_string\n";
   } else {
       @files = (@files, $ARGV[$argnum]);
   }

}

foreach my $file (@files) {
    my $new_file = "$file$ext";
    my $hit = 0;
    my @file_output = ();

    open (INPUT, "$file");

    while (<INPUT>) {
        chomp;
        my $line = $_;
        if ($line =~ /$old_string/) {
            print "Hit\n";
            $hit = 1;
        }
        $line =~ s/$old_string/$new_string/g;
        @file_output = (@file_output, "$line\n");
    }

    close (INPUT);

    if (($hit == 1)) {
       if ((-e $new_file) && ($force == 0)) {
           print "$new_file exists.  Replace? (y/n)";
           my $replace = <STDIN>;
           if ($replace =~ /^n/) {
               next;
           }
       }

       open (OUTPUT, "> $new_file");


       foreach my $line (@file_output) {
           print OUTPUT "$line";
       }

       close (OUTPUT);

    }

}

