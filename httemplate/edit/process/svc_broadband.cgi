<& elements/svc_Common.html,
  table       => 'svc_broadband',
  fields      => [ fields('svc_broadband'), fields('nas'), 'usergroup' ],
  precheck_callback => \&precheck,
&>
<%init>
# for historical reasons, process_m2m for usergroup tables is done 
# in the svc_x::insert/replace/delete methods, not here
my $curuser = $FS::CurrentUser::CurrentUser;

die "access denied"
  unless $curuser->access_right('Provision customer service'); #something else more specific?

sub precheck {
  my $cgi = shift;
  if ( !defined($cgi->param('ip_addr')) ) {
    $cgi->param('ip_addr', $cgi->param('prev_ip_addr') || '');
  }
  $cgi->param("usergroup", [ $cgi->param('usergroup') ]);
  ''
}

</%init>
