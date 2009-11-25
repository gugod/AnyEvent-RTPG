package AnyEvent::RTPG;
our $VERSION = "0.01";

use 5.008;

use common::sense 2.02;
use parents       0.223 "Object::Event";
use AnyEvent      5.202;
use RTPG          0.3;

sub new {
   my $this  = shift;
   my $class = ref($this) || $this;
   my $self  = $class->SUPER::new(@_);
   $self->{_rtpg} = RTPG->new(url=>$self->{url});
   return $self
}

sub _tick {
    my $self = shift;
    my $list=$self->{_rtpg}->torrents_list;
    $self->event("refresh_status"=>\@$list);
}

sub start {
    my $self = shift;
    $self->{_tick_timer} = AE::timer(0, 10, sub { $self->_tick });
}

sub rpc_command {
    my $self = shift;
    my ($result, $error)=$self->{_rtpg}->rpc_command(@_);
    my $cmd=shift;
    if ($cmd =~ /^d.erase$/) {
        my $hash=shift;
        print $cmd,$hash;
        $self->event("rtorrent_remove_torrent"=>$hash);
    }else{
        $self->_tick;
    }
}

1;

