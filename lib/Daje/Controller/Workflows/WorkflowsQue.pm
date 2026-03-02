package Daje::Controller::Workflows::WorkflowsQue;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use v5.42;

# NAME
# ====
#
# Daje::Controller::Workflow::WorkflowsQue - Mojolicious controller for
# Daje::Workflow using Minion Job que
#
# SYNOPSIS
# ========
#
#     use Daje::Controller::Workflow::WorkflowsQue;
#
#     Expected indata format
#
#     'workflow' => {
#                      'workflow' => 'Workflow name',
#                      'activity' => 'name of activity',
#                      'workflow_pkey' => ,
#                      'connector' => 'Name of the connector to the workflow Optional if the workflow_pkey > 0'

#                    },
#      'payload' => {
#                        Something the activity understands
#                    }
#        }
#
#
# DESCRIPTION
# ===========
#
# Daje::Controller::Workflow::WorkflowsQue is the controller for accessing Daje::Workflow minion que
#
# LICENSE
# =======
#
# Copyright (C) janeskil1525.
#
# This library is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# AUTHOR
# ======
#
# janeskil1525 E<lt>janeskil1525@gmail.comE<gt>
#
#

sub execute($self) {

    # $self->render_later;
    $self->app->log->debug('Daje::Controller::Workflow::Workflow::execute');
    try {
        my ($companies_pkey, $users_pkey) = $self->jwt->companies_users_pkey(
            $self->req->headers->header('X-Token-Check')
        );

        $self->app->log->debug('Daje::Controller::Workflows::Workflows::execute '  . Dumper($self->req->body));

        my $data->{context} = decode_json ($self->req->body);
        $data->{context}->{users_fkey} = $users_pkey;
        $data->{context}->{companies_fkey} = $companies_pkey;
        #
        # push @{$data->{actions}}, "$self->stash('wf_action')";
        # $data->{workflow}->{workflow} = $self->stash('workflow');
        # $data->{workflow}->{workflow_relation} = $self->stash('workflow_relation');
        # $data->{workflow}->{workflow_relation_key} = $self->stash('workflow_relation_key');
        # $data->{workflow}->{workflow_origin_key} = $self->stash('workflow_origin_key');
        #
        # say Dumper ($data);

        if(exists $data->{context}->{payload}->{workflow_fkey}) {
            $self->workflow_engine->workflow_pkey($data->{context}->{payload}->{workflow_fkey});
        } else {
            $self->workflow_engine->workflow_pkey($data->{context}->{workflow}->{workflow_fkey});
        }
        $self->workflow_engine->workflow_name($data->{context}->{workflow}->{workflow});
        $self->workflow_engine->context($data);
        $self->workflow_engine->process($data->{context}->{workflow}->{activity});
        if($self->workflow_engine->error->has_error() == 0) {
            $self->render(json => {result => 1, data => 'OK'});
        } else {
            $self->app->log->error('Daje::Controller::Workflows::Workflows::execute ' . $self->workflow_engine->error->error());
            $self->render(json =>
                {result => 0, data => $self->workflow_engine->error->error()}
            );
        }
    } catch ($e) {
        $self->app->log->error('Daje::Controller::Workflows::Workflows::execute ' . $e);
        $self->render(json => {result => 0, data => $e});
    };
    $self->app->log->debug('Daje::Controller::Workflows::Workflows::execute ends');
}
1;