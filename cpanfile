requires 'perl', '5.040000';
requires 'Daje::Workflow::Database', '0';
requires 'Daje::Workflow::Loader', '0';
requires 'Mojo::Base', '0';
requires 'Mojolicious::Plugin', '0';
requires 'Daje::Workflow', '0';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

