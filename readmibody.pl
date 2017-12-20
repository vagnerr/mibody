#!/usr/bin/perl -w

use strict;
use warnings;

use Data::Dumper;

my $fh;

open( $fh, "<", "BODYDATA.TXT");

binmode $fh;

my $line; 
my $data;
my $count =0;
my $result = [];
while ( $line = read ($fh, $data, 18)) {
  my $record = ( ( $count % 35) +1);
  my $user   =(int( $count / 35) +1);
  $count++;
  #print "&&&&&&&&&&& $line\n" ;
  #print "ppppppppppp $data\n" ;
  my( $hex ) = unpack( 'H*', $data );
  if ( $hex ne '000000000000000000000000000000000000' ) {
    #if ( $hex !~ /^00000000/ ) {
    my @array = ( $hex =~ m/../g );
    my $debug =  "HH:($count U:$user R:$record) ". join(' ',@array) . "\n";

    print $debug;
    @array = map { hex($_) } @array; 

    my $item = 
    {
      _debug    => $debug,
      year      => ( $array[0]*256 + $array[1] ),
      month     => ( $array[2] ),
      day       => ( $array[3] ),
      hours     => ( $array[4] ),
      mins      => ( $array[5] ),
      secs      => ( $array[6] ),
      gender    => ( int( $array[7] / 128 ) ? 'M':'F' ),
      age       => ( $array[7] % 128 ),
      height    => ( $array[8] ),
      fitness   => ( $array[9] ),
      weight    => ( $array[10]*256 + $array[11] ) / 10,
      fat       => ( $array[12]*256 + $array[13] ) / 10,
      paddddd   => ( $array[14] ),
      muscle    => ( $array[15]*256 + $array[16] ) / 10,
      viceral   => ( $array[17] ),

    };
    $item->{bmi} = ( $item->{weight} / (( $item->{height}/100 )^2)) ;
    $item->{bmr} = ( 
                      $item->{gender} eq 'M' ? 
                      (  66 + ( 13.7 * $item->{weight} ) + ( 5   * $item->{height} ) - ( 6.8 * $item->{age} ) ) :  #Male
                      ( 655 + (  9.6 * $item->{weight} ) + ( 1.8 * $item->{height} ) - ( 4.7 * $item->{age} ) )    #Female
                    );


    $result->[$user -1 ][$count -1] = $item;
  #  print $line;
  }
}

close $fh;

#print Data::Dumper->Dump( [$result] );

my $usercount = 0;
for my $user ( @$result ) {
  $usercount++; # get Human numbers
  next unless defined $user;
  print "User: $usercount\n";
  
  my $record_count = 0;
  for my $record (@$user){
    $record_count++;

    next unless defined $record;
    my $date = "$record->{day}/$record->{month}/$record->{year} $record->{hours}:$record->{mins}";
    print "$record_count: $date\t$record->{height}\t$record->{weight}\t$record->{muscle}\t$record->{fat}\n";
  }

}


