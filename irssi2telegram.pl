#!/usr/bin/perl
#
use strict;
use Irssi;
use File::Slurp;
use WWW::Telegram::BotAPI;
use Data::Dumper qw(Dumper);
use v5.18;

my $token = read_file("./token");
my $user = read_file("./destination_user");
chomp ($user);
chomp($token);
my $log;
open $log, ">", $ENV{HOME}."/irssi2telegram.log" || die "could not open log: $!";

my $api = WWW::Telegram::BotAPI->new(token => $token);
my $me = $api->getMe or die "could not getMe";
say $log "I am ". Dumper($me);

my $updates;
my $offset;
my $last_update_time = time;

%IRSSI = (authors => "Alexander Wuerstlein", contact => 'arw@arw.name', name => 'irssi2telegram', 
	description => 'send irssi highlights to a telegram destination', license => 'GNU GPLv3', );

Irssi::signal_add('print text' => sub {
	my ($dest, $text, $stripped) = @_;
	my $opt = MSGLEVEL_HILIGHT | MSGLEVEL_MSGS;

	if (($dest->{level} & $opt) &&
		(($dest->level & MSGLEVEL_NOHIGHLIGHT) == 0) {
		send_text($text);
	}
	if (time - $last_update_time > 60) {
		$last_update_time = time;
		get_updates();
	}
});

sub get_updates {
	$updates = $api->getUpdates({timeout => 30, $offset?(offset => $offset):()});
	unless ($updates and ref $updates eq "HASH" and $updates->{ok}) {
		say $log "updates weird";
		next;
	}
	for my $u (@{$updates->{result}}) {
		 $offset = $u->{update_id} + 1 if $u->{update_id} >= $offset;
		 say $log "Message from " . $u->{message}{from}{username};
		 say $log Dumper($u);
	}
}

sub send_text {
	my $text = shift;
	$api->sendMessage({ chat_id => "$user", text => "$text", });
}
