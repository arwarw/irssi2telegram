#!/usr/bin/perl

use strict;
use Irssi;
use File::Slurp;
use WWW::Telegram::BotAPI;
use Data::Dumper qw(Dumper);
use v5.18;
use vars qw(%IRSSI);

my $token = read_file($ENV{HOME}."/.irssi2telegram/token");
my $user = read_file($ENV{HOME}."/.irssi2telegram/destination_user");
my $channel_id = read_file($ENV{HOME}."/.irssi2telegram/destination_channel");
chomp($user);
chomp($token);
chomp($channel_id);


# touch ~/.irssi2telegram/log to enable debug logging
my $log;
if (-f $ENV{HOME}."/irssi2telegram/log") {
	open $log, ">", $ENV{HOME}."/irssi2telegram/log" || die "could not open log: $!";
}

my $api = WWW::Telegram::BotAPI->new(token => $token);
my $me = $api->getMe or say $log "could not getMe";
say $log "I am ". Dumper($me) if $log;

my $updates;
my $offset;
my $last_update_time = 0;

%IRSSI = (authors => "Alexander Wuerstlein", contact => 'arw@arw.name', name => 'irssi2telegram', 
	description => 'send irssi highlights to a telegram destination', license => 'GNU GPLv3', );

Irssi::signal_add('print text' => sub {
	my ($dest, $text, $stripped) = @_;
	my $opt = MSGLEVEL_HILIGHT | MSGLEVEL_MSGS;

	if (time - $last_update_time > 60) {
		$last_update_time = time;
		get_updates();
	}

	if (($dest->{level} & ($opt)) &&
		(($dest->{level} & MSGLEVEL_NOHILIGHT) == 0)) {
		send_text($stripped);
	}
});

sub get_updates {
	$updates = $api->getUpdates({timeout => 0, $offset?(offset => $offset):()});
	unless ($updates and ref $updates eq "HASH" and $updates->{ok}) {
		say $log "updates weird" if $log;
		next;
	}
	for my $u (@{$updates->{result}}) {
		 $offset = $u->{update_id} + 1 if $u->{update_id} >= $offset;
		 say $log "Message from " . $u->{message}{from}{username} if $log;
		 say $log Dumper($u) if $log;
	}
}

sub send_text {
	my $text = shift;
	my $chat = $api->getChat({chat_id => $channel_id});
	say $log Dumper($chat) if $log;
	die "username for destination channel does not match" unless $chat->{result}->{username} eq $user;
	$api->sendMessage({ chat_id => $channel_id, text => "$text", });
}
