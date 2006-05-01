package FS::part_pkg::prorate;

use strict;
use vars qw(@ISA %info);
use Time::Local qw(timelocal);
#use FS::Record qw(qsearch qsearchs);
use FS::part_pkg::flat;

@ISA = qw(FS::part_pkg::flat);

%info = (
  'name' => 'First partial month pro-rated, then flat-rate (selectable billing day)',
  'fields' =>  {
    'setup_fee' => { 'name' => 'Setup fee for this package',
                     'default' => 0,
                   },
    'recur_fee' => { 'name' => 'Recurring fee for this package',
                     'default' => 0,
                    },
    'unused_credit' => { 'name' => 'Credit the customer for the unused portion'.
                                   ' of service at cancellation',
                         'type' => 'checkbox',
                       },
    'cutoff_day' => { 'name' => 'billing day',
			 'default' => 1,
					    },
    #it would be better if this had to be turned on, its confusing
    'externalid' => { 'name'   => 'Optional External ID',
                      'default' => '',
                    },
 },
  'fieldorder' => [ 'setup_fee', 'recur_fee', 'unused_credit', 'cutoff_day',
                    'externalid', ],
  'freq' => 'm',
  'weight' => 20,
);

sub calc_recur {
  my($self, $cust_pkg, $sdate ) = @_;
  my $cutoff_day = $self->option('cutoff_day', 1) || 1;
  my $mnow = $$sdate;
  my ($sec,$min,$hour,$mday,$mon,$year) = (localtime($mnow) )[0,1,2,3,4,5];
  my $mend;
  my $mstart;
  
  if ( $mday > $cutoff_day ) {
    $mend =
      timelocal(0,0,0,$cutoff_day, $mon == 11 ? 0 : $mon+1, $year+($mon==11));
    $mstart =
      timelocal(0,0,0,$cutoff_day,$mon,$year);  

  } else {
    $mend = timelocal(0,0,0,$cutoff_day, $mon, $year);
    if ($mon==0) {$mon=11;$year--;} else {$mon--;}
    $mstart=  timelocal(0,0,0,$cutoff_day,$mon,$year);  
  }

  $$sdate = $mstart;
  my $permonth = $self->option('recur_fee') / $self->freq;

  $permonth * ( ( $self->freq - 1 ) + ($mend-$mnow) / ($mend-$mstart) );
}

1;
