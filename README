=== Notes

Config Files! -- DO THIS!

= config/database.yml
Make sure you set your db connection. There is a default file for an
example

= config/activemerchant.yml
Make sure to create a config file from the default one for development.
This will use a central sandbox account.

= config/twilio.yml
Get a free trail account at http://www.twilio.com/.
Verify your number for testing.
Enter the sandbox account: Account SID and AuthToken. The sms_number
needs to be the Sandbox number during testing.

= config/interfax.yml
No credentials yet.


== ActiveMerchant

- Use these cards to get predicted results.
http://wiki.usaepay.com/developer/testcards

== Heroku ENV vars to set
USA_EPAY_LOGIN -- source key
USA_EPAY_PASSWORD -- pin
USA_EPAY_SOFTWARE_ID -- id in wsdl

S3_BUCKET
S3_KEY
S3_SECRET

TWILIO_SID
TWILIO_AUTH_TOKEN
TWILIO_SMS_NUMBER - Number messages come from. Purchased from twilio.

INTERFAX_USERNAME
INTERFAX_PASSWORD

== Testing

If you would like to run the tests you can either use rake. Default
task runs all tests. Or (preferred method):

gem install ZenTest autotest-rails
autotest

To continually run tests and only run modified code. This way you can
notice when you break something... intentionally or not.

There are many gems to allow notification through growl etc.

I have also included simplecov. On OSX `open coverage/index.html` and
see how bad we suck (or are not sucking).

= Growl Notifications (OSX)
Install growl from App store. ($1.99 now...)

Then gem install autotest-growl and add:
require 'autotest/growl'
to ~/.autotest

This will give you notifications when tests fails instead of having
to look at the terminal to see if they pass/fail.

= File System Event Add On (OSX)
gem install autotest-fsevent
Then add:
require 'autotest/fsevent'
to ~/.autotest

This will use native file notifications rather than filesystem
polling.

= Alternatives for Linux:
- autotest-notification (alerts)
- autotest-ionotify (filesytem)
