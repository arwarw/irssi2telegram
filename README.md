# irssi2telegram

This is an irssi script that sends all highlights and queries to your
[telegram](https://telegram.org/) account via the [telegram bot API](https://core.telegram.org/bots)

This means that you need to register a telegram bot to use this plugin.

## Setup

I'll assume you have [telegram](https://telegram.org) installed on your mobile
device and registered a personal account (called e.g. `you_in_telegram`). I'll
also assume that you have installed irssi somewhere and that irssi is currently
running, connected to one or more IRC networks, etc.

1. First, copy `irssi2telegram.pl` into your irssi scripts directory, usually `~/.irssi/scripts/`. Install
   `libfile-slurp-perl` and `libwww-telegram-botapi-perl` or whatever your
   Distro packages the perl modules `File::Slurp` or `WWW::Telegram::BotAPI` as.
   Your irssi should include the irssi perl API, the Debian packages do at least.
   If you can't find `libwww-telegram-botapi-perl` (no surprise, since its not in the
   official debian repos) create it yourself:

   ```console
   $ dh-make-perl --cpan WWW::Telegram::BotAPI
   <if in doubt: press enter a few times>
   $ cd libwww-telegram-botapi-perl
   $ fakeroot debian/rules binary
   $ cd ..
   # dpkg -i libwww-telegram-botapi-perl_0.03-1_all.deb
   ```

   Maybe the version number in the last command will be higher by now. As always, `#` means:
   execute as root.

2. In telegram, talk to `@botfather`. This is the special telegram bot that creates all other
   bots. Type `/newbot` to create your bot, pick a display name and username (which must end in
   `bot`, so e.g. `you_in_telegram_bot`) and remember those along with the token displayed there.
   The token will look similar to `110201543:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw`. Treat this
   token like a password, so keep it secret, but remember it, you'll need it later on.

3. Execute the following: 
   ```console
   # mkdir -p ~/.irssi2telegram
   # chmod -R go-rwx ~/.irssi2telegram
   # echo "110201543:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw" > ~/.irssi2telegram/token
   # echo "you_in_telegram" > ~/.irssi2telegram/destination_user
   ```
   Replace your telegram user (your personal one, not the bot!) and your bot token in the code above.

4. Now you can test your bot by running test.pl:
   ```console
   # ./test.pl
   I am $VAR1 = {
   	'result' => {
   		'username' => 'you_in_telegram_bot',
   		'first_name' => 'you_in_telegram's bot',
   		'id' => 23984295
   	},
   	'ok' => bless( do{\(my $o = 1)}, 'JSON::XS::Boolean' )
   }; 
   ```
   Talk to `@you_in_telegram_bot` in telegram and send a message to your bot (content does not matter).
   You should see something like this:
   ```console
   Message from you_in_telegram
   $VAR1 = {
	   'update_id' => 47110815,
	   'message' => {
		   'text' => 'Test text you sent',
		   'chat' => {
			   'username' => 'you_in_telegram',
			   'id' => 123456789,
			   'type' => 'private',
			   'first_name' => 'you'
		   },
		   'date' => 1469634270,
		   'message_id' => 1,
		   'from' => {
			   'id' => 123456789,
			   'first_name' => 'you',
			   'username' => 'you_in_telegram'
		   }
	   }
   };
   ```
   
   Note that `{message}->{chat}->{type}` should be `private` and the value of `{message}->{chat}->{id}` should equal
   the value of `{message}->{from}->{id}`, here e.g. `123456789`.
   
   Abort test.pl via Ctrl-C.

5. Execute the following:
   ```console
   echo "123456789" > ~/.irssi2telegram/destination_channel
   ```
   You need to replace the id by your value of `{message}->{from}->{id}`.

6. Now you just need to load the script in irssi. For this, type `/script load ~/.irssi/scripts/irssi2telegram.pl` in irssi.
   You should not see any error messages. After typing `/script list` in irssi, a line like the following should appear:
   ```
   17:59 Loaded scripts:
   17:59 irssi2telegram  /home/arw/.irssi/scripts/irssi2telegram.pl
   ```
   
7. Done. Test your setup by having someone highlight you in IRC. Your bot should forward all hightlight messages to your mobile device.

## Sources
The telegram bot API is very useful and one of the nicest things abour telegram:
https://core.telegram.org/bots#botfather
https://core.telegram.org/bots/api
I think this API is something where the competition is sorely lacking.

Half of the code is taken from and ananlogous to the `WWW::Telegram::BotAPI` usage examples:
https://metacpan.org/pod/WWW::Telegram::BotAPI

The other half is inspired by the hilightcmd.pl irssi script:
https://github.com/irssi/scripts/blob/gh-pages/scripts/hilightcmd.pl
