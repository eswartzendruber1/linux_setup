#!/usr/bin/perl -w


my @a = qw( a b );
my @b = map { my $x = $_;
              map { $x . $_ } @a;
} @a;

print "@a\n";
print "@b\n";
print "FOO:\n";
my $rgx_num_dfa = 3;
my @foo = map(
    {
        NAME       => "rgx_rcp_dfa${_}_thread_dis",
    },
    (0..$rgx_num_dfa-1));

for $i ( @foo ) {
    print "{ ";
    for $role ( keys %$i ) {
        print "$role=$i->{$role} ";
    }
    print "}\n";
}

#print "BLAH:\n";
my @blah = map { my $crap = $_;
              map ({ NAME => "rgx_${crap}_rcp_dfa${_}_thread_dis",}, ("_shit_", "_fuck_"));
} (0..$rgx_num_dfa-1);

for $i ( @blah ) {
    print "{ ";
    for $role ( keys %$i ) {
        print "$role=$i->{$role} ";
    }
    print "}\n";
}

#my @y = qw( 0 1 2 );
#my @z = qw( shit fuck );
#my @blah = map { my $crap = $_;
#                 map ({ NAME       => "rgx_${crap}_rcp_dfa${_}_thread_dis",} @y);
#} @z;
#
#for $i ( @blah ) {
#    print "{ ";
#    for $role ( keys %$i ) {
#        print "$role=$i->{$role} ";
#    }2

#    print "}\n";
#}
