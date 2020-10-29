#!/tools/local/bin/perl -w

my $bar = "zing";
my @foo = (
   $bar . "_DRU_MAX_NUM_PF",         "1", "d", #// Valid values are 1 or 17 (networking is only device using > 1 PF)
   "DRU_MAX_NUM_FUNC_MODES", "1", "d", #// Valid values are 1 or 18 (networking is only device using > 1 Function Modes)
   "DRU_MAX_NUM_FUNC",       "8", "d",
   "DRU_RX_NUM_DR_CFG",      "1", "d",
   "DRU_TX_NUM_DR_CFG",      "1", "d",
   );
create_defines(\@foo);



sub create_defines
{
    my $prefix_lc = "";
    my $prefix_uc = "";
    my @foo;
    my @foo1;
    my $listbref;

    my $param_cnt = scalar @_;
    print "param_cnt = $param_cnt\n";
    if ($param_cnt == 2) {
        ($listbref) = $_[0];
        @foo = @$listbref;
        ($listbref1) = $_[1];
        @foo1 = @$listbref1;
         $prefix_lc = $foo1[0];
        $prefix_lc =~ s/^\s+//;
        $prefix_lc =~ s/\s+$//;
        if($prefix_lc =~ m/^`/) {
           print "Here\n";
           #$prefix_lc = $Define_List{sprintf("%s", $prefix_lc)};
        }
        
        $prefix_uc = uc($prefix_lc);
        my $bar = "_";
        $prefix_uc = $prefix_uc . $bar;
    } else {
        ($listbref) = @_;
        @foo = @$listbref;
    }
        

   my $ref = \@foo;
   my $cnt = $#{$ref};
   my $lsb = 0;
   my $msb = 0;
   my $range = 0;
   my $intPart;
   my $remPart;
   for($i=0; $i<$cnt; $i=$i+3) {
       $coding = $foo[($i+2)];
       $width = $foo[($i+1)];
       #get rid of leading and trailing whitespace
       $width =~ s/^\s+//;
       $width =~ s/\s+$//;
       $define = $foo[$i];
       $define =~ s/^\s+//;
       $define =~ s/\s+$//;
       $define = $prefix_uc . $define;
print "define = $define; width = $width\n";

       if($width =~ m/^`/) {
           $width = $Define_List{sprintf("%s", $width)};
       }
       if($width > 0) {
          $lsb = 0;
          $msb = $lsb+$width-1;
          $range = "$msb:$lsb";
          $Define_List{sprintf("`%s", $define)} = $width;
          $Define_List{sprintf("`%s_MSB", $define)} = $msb;
          $Define_List{sprintf("`%s_LSB", $define)} = $lsb;
          $Define_List{sprintf("`%s_RANGE", $define)} = $range;

          if($coding =~ /d/) {
             $Define_List{sprintf("`%s_DW", $define)} = $width;
             $Define_List{sprintf("`%s_DMSB", $define)} = $msb;
             $Define_List{sprintf("`%s_DLSB", $define)} = $lsb;
             $Define_List{sprintf("`%s_DR", $define)} = $range;

             if ($width <= 1) {
                 $bits = 1;
             } else {
                 $bits = log($width)/log(2);
             }
             $intPart = sprintf("%.0f", $bits);
             $remPart = sprintf("%.5f", ($bits - $intPart));
             if ($remPart > 0)
             {
                $intPart++;
             }
             $bits = $intPart;

             $msb = $lsb+$bits-1;
             $range = "$msb:$lsb";
             $Define_List{sprintf("`%s_EW", $define)} = $bits;
             $Define_List{sprintf("`%s_EMSB", $define)} = $msb;
             $Define_List{sprintf("`%s_ELSB", $define)} = $lsb;
             $Define_List{sprintf("`%s_ER", $define)} = $range;
          }  else {
             $Define_List{sprintf("`%s_EW", $define)} = $width;
             $Define_List{sprintf("`%s_EMSB", $define)} = $msb;
             $Define_List{sprintf("`%s_ELSB", $define)} = $lsb;
             $Define_List{sprintf("`%s_ER", $define)} = $range;

             if ($msb <= 0) {
                 $bits = 1;
             } else {
                 $bits = 2**$width;
             }
             $msb = $lsb+$bits-1;
             $range = "$msb:$lsb";
             $Define_List{sprintf("`%s_DW", $define)} = $bits;
             $Define_List{sprintf("`%s_DMSB", $define)} = $msb;
             $Define_List{sprintf("`%s_DLSB", $define)} = $lsb;
             $Define_List{sprintf("`%s_DR", $define)} = $range;

          }
       } else {
          $Define_List{sprintf("`%s", $define)} = 0;
          $Define_List{sprintf("`%s_EW", $define)} = 0;
          $Define_List{sprintf("`%s_EMSB", $define)} = 0;
          $Define_List{sprintf("`%s_ELSB", $define)} = 0;
          $Define_List{sprintf("`%s_ER", $define)} = 0;
          $Define_List{sprintf("`%s_DW", $define)} = 0;
          $Define_List{sprintf("`%s_DMSB", $define)} = 0;
          $Define_List{sprintf("`%s_DLSB", $define)} = 0;
          $Define_List{sprintf("`%s_DR", $define)} = 0;
       }
   }
}
