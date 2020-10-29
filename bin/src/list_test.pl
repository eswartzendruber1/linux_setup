#!/usr/bin/perl -w


my $tlist_sanity_failing = [ "f_foo", "f_bar" ];
my $tlist_sanity_passing = [ "p_foo", "p_bar" ];

print "Failing\n";
for my $elem (@$tlist_sanity_failing) {
    print $elem."\n";
}

print "Passing\n";
for my $elem (@$tlist_sanity_passing) {
    print $elem."\n";
}


my $tlist_sanity = [ @$tlist_sanity_failing, @$tlist_sanity_passing];

print "Combined\n";
for my $elem (@$tlist_sanity) {
    print $elem."\n";
}
