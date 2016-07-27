#!/usr/bin/perl

use strict;
use File::Slurp;
use WWW::Telegram::BotAPI;
use Data::Dumper qw(Dumper);
use v5.18;

my $token = read_file($ENV{HOME}."/.irssi2telegram/token");
chomp($token);
my $api = WWW::Telegram::BotAPI->new(token => $token);
my $me = $api->getMe or die "could not getMe";
say "I am ". Dumper($me);

my $updates;
my $offset;
while (1) {
	$updates = $api->getUpdates({timeout => 30, $offset?(offset => $offset):()});
	unless ($updates and ref $updates eq "HASH" and $updates->{ok}) {
		warn "updates weird";
		next;
	}
	for my $u (@{$updates->{result}}) {
		 $offset = $u->{update_id} + 1 if $u->{update_id} >= $offset;
		 say "Message from " . $u->{message}{from}{username};
		 say Dumper($u);

		 $api->sendMessage({
			 	chat_id => $u->{message}{chat}{id},
				text => "Hallo arw",
			 });
	}
}
