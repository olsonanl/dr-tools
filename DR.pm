package DR;

use strict;
use LWP::UserAgent;
use JSON::XS;
use HTTP::Request::Common;
use Data::Dumper;

our $token_path;
if ($^O eq 'MSWin32')
{
    my $dir = $ENV{HOME} || $ENV{HOMEPATH};
    $token_path = "$dir/.datarobot_token";
} else {
    $token_path = "$ENV{HOME}/.datarobot_token";
}

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw(json ua token url));

sub new
{
    my($class) = @_;

    my $self = {
	ua => LWP::UserAgent->new,
	json => JSON::XS->new->allow_nonref->pretty(1),
	url => 'http://140.221.10.250/api/v2',
    };

    bless $self, $class;

    if ($ENV{DR_TOKEN})
    {
	$self->token($ENV{DR_TOKEN});
    }
    elsif (open(my $fh, "<", $token_path))
    {
	my $t = <$fh>;
	chomp $t;
	if ($t)
	{
	    $self->token($t);
	}
    }

    if ($ENV{DR_PROXY})
    {
	$self->ua->proxy([qw(http https)] => $ENV{DR_PROXY});
    }
    return $self;
}

sub token_path
{
    return $token_path;
}

sub get_token
{
    my($self, $username, $password) = @_;

    my $url = $self->url . "/api_token/";

    my $req = { username => $username, password => $password };
    my $req_txt = $self->json->encode($req);
    my $res = $self->ua->post($url,
			      Content_Type => 'application/json',
			      Content => $req_txt);
    if (!$res->is_success)
    {
	die "Request to $url failed: " . $res->code . " " . $res->content;
    }
    my $txt = $res->content;
    print "Got $txt\n";
    my $obj = $self->json->decode($txt);
    my $token = $obj->{apiToken};
    return $token;
}

sub project_status
{
    my($self, $project_id) = @_;
    my $res = $self->request("/projects/$project_id/status");
    return $res;
}

sub list_projects
{
    my($self, $project_name) = @_;

    my $route = "/projects";
    $route .= "?projectName=$project_name" if $project_name;
    my $doc = $self->request($route);

    return $doc;
}

sub list_model_jobs
{
    my($self, $project_id) = @_;

    my $route = "/projects/$project_id/modelJobs/";
    my $doc = $self->request($route);

    return $doc;
}

sub list_models
{
    my($self, $project_id) = @_;

    my $route = "/projects/$project_id/models/";
    my $doc = $self->request($route);

    return $doc;
}

sub start_model_job
{
    my($self, $project_id, $target, $params, $await_completion) = @_;

    my $route = $self->url . "/projects/$project_id/aim/";
    my $req_data = {
	target => $target,
    };
    if (ref($params) eq 'HASH')
    {
	$req_data->{$_} = $params->{$_} foreach keys %$params;
    }
    my $req = HTTP::Request::Common::POST($route,
					  Authorization => "Token " . $self->token,
					  Content_Type => 'application/json',
					  Content => $self->json->encode($req_data));
    $req->method("PATCH");
    my $res = $self->ua->request($req);
    
    if (!$res->is_success)
    {
	die "Request failed to $route: " . $res->content;
    }

    my $status_url = $res->header("location");

    while (1)
    {
	print "Check status: $status_url\n";

	my $stat = $self->ua->get($status_url,
				  Authorization => "Token " . $self->token);

	if ($stat->is_redirect)
	{
	    my $new = $res->header("location");
	    print "Job complete new=$new\n";
	    return $new;
	}
	   
	if (!$stat->is_success)
	{
	    die "Status request failed for $status_url: " . $res->code . " " . $res->content;
	}

	my $txt = $stat->content;
	my $doc = $self->json->decode($txt);

	print "Status: $txt\n";

	if ($doc->{status} eq 'RUNNING')
	{
	    if (!$await_completion)
	    {
		print "Job running\n";
		return $status_url;
	    }
	}
	else
	{
	    return $status_url;
	}


	# if ($doc->{id})
	# {
	#     print "Project ID found: $doc->{id}\n";
	#     return $doc->{id};
	# }
	sleep 1;
    }
    return undef;

}

sub request
{
    my($self, $route) = @_;
    my $url = $self->url . $route;

    my $res = $self->ua->get($url,
			     Authorization => "Token " . $self->token);
    if (!$res->is_success)
    {
	die "Request failed to $url: " . $res->content;
    }
    my $txt = $res->content;
    my $doc = $self->json->decode($txt);
    return $doc;
}

sub create_project
{
    my($self, $file_name, $project_name) = @_;

    my $url = $self->url . "/projects/";

    my $res = $self->ua->post($url,
			      Authorization => "Token " . $self->token,
			      Content_Type => 'multipart/form-data',
			      Content => [file => [$file_name],
					  $project_name ? (projectName => $project_name) : (),
					  ],
			     );
    if (!$res->is_success)
    {
	die "Request failed to $url: " . $res->content;
    }

    my $status_url = $res->header("location");

    while (1)
    {
	print "Check status: $status_url\n";

	my $stat = $self->ua->get($status_url,
				  Authorization => "Token " . $self->token);
	if (!$stat->is_success)
	{
	    die "Status request failed for $status_url: " . $res->code . " " . $res->content;
	}

	my $txt = $stat->content;
	my $doc = $self->json->decode($txt);

	print "Status: $txt\n";

	if ($doc->{id})
	{
	    print "Project ID found: $doc->{id}\n";
	    return $doc->{id};
	}
	sleep 1;
    }
    return undef;
}

sub delete_project
{
    my ($self, $proj_id) = @_;
    my $route = $self->url . '/projects/' . $proj_id . '/';

	print $self->token, "\n";
    my $res = $self->ua->delete($route,
			Authorization => "Token " . $self->token);

    if (!$res->is_success)
    {
        die "Request failed to $route: " . $res->content;
    }

    return undef;
}
1;
