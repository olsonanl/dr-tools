use FindBin;
use lib "$FindBin::Bin";

use strict;
use warnings;
use lib qw(/Users/brettin/perl5/lib/perl5);

use LWP::UserAgent;
use CGI;
use JSON;
my $json_obj = JSON->new->allow_nonref;

my $url = 'http://140.221.10.250/api/v2/api_token/';
my $json = '{"username": "", "password": ""}';
my $req = HTTP::Request->new( 'POST', $url );

$req->header('Content-Type' => 'application/json' );
$req->content($json);

my $ua = LWP::UserAgent->new;
$ua->proxy([qw(http https)] => 'socks://localhost:32000');
my $response = $ua->request( $req );
my $content  = $response->decoded_content();

# print $content, "\n";

my $perl_scalar = $json_obj->decode( $content );
print "export DR_TOKEN=", $perl_scalar->{apiToken}, "\n";
