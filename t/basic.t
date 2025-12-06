use Mojo::Base -strict, -signatures;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use Mojo::Pg;
use Mojo::Log;
use File::Share;
use Mojo::File;
use Mojo::Home;



my $pg = Mojo::Pg->new->dsn(
    "dbi:Pg:dbname=Venditabant;host=database;port=15432;user=postgres;password=PV58nova64"
);

helper log => sub ($c) {
    return Mojo::Log->new(
        path => '/home/jan/Project/Daje-Plugin-Workflow/Log/workflow.log',
        level => 'debug'
    );
};

helper pg => sub ($c) {
    return Mojo::Pg->new->dsn(
        "dbi:Pg:dbname=daje;host=192.168.1.124;port=5432;user=daje;password=PV58nova64"
    );;
};

helper config => sub ($c) {
    return Mojo::Pg->new->dsn(
        "dbi:Pg:dbname=daje;host=192.168.1.124;port=5432;user=daje;password=PV58nova64"
    );;
};


helper dist_dir => sub($c) {
  return Mojo::File->new(
      '/home/jan/IdeaProjects/Venditabant/Backend/venditabant/share/'
  );
};


push @{app->plugins->namespaces}, 'Daje::Plugin';
push @{app->routes->namespaces}, 'Daje::Controller';

plugin 'Config' => { file => '../conf/config.conf' };
plugin 'Workflow';

put '/workflow/api/execute' => sub {
  my $c = shift;

  $c->render(text => 'Hello Mojo!');
};

my $t = Test::Mojo->new;
$t->put_ok('/workflow/api/execute' =>
    { 'X-Token-Check' => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW5pZXNfcGtleSI6MjQsImNvbXBhbnkiOiJEYWplIEFCIiwiaXNfYWRtaW4iOjAsInBhc3N3b3JkIjoiMGdZVzZqTXU3dFwvcWVORHVRS2hON2xOSmJtaTRHTkxpVE94ZFZWUnFtazI0TllBamlCVElnRThiNHBTWFdXNmV2R09QRlFXVTBLbXJ0cnZqaFk4ZHVBIiwic3VwcG9ydCI6MSwidXNlcmlkIjoiamFuQGRhamUud29yayIsInVzZXJuYW1lIjoiSmFuIEVza2lsc3NvbiIsInVzZXJzX3BrZXkiOjI0fQ.oUhzZDxjDVNLUhWt81BBtKPFzpFiTBYxTGjW5Pk92V0' }
                                   => json =>
    {
        'context' => {
            'payload' => {
                "tools_version_pkey" => 0,
                "tools_projects_fkey" => 1,
                "version" => 1,
                "locked" => 0,
                "name" => "",
                "workflow_fkey" => 0,
            },
            'workflow' => {
                'workflow' => 'tools_generate_sql',
                'connector_data' => {
                    'workflow_pkey' => 0,
                    'connector_pkey' => 0,
                    'connector' => 'tools_projects'
                },
                'activity' => 'generate_sql'
            }
        }
    }
)->status_is(200)->content_is('Hello Mojo!');

done_testing();

1;