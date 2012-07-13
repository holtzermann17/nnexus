
package NNexusSAXHandler;

use strict;

use base qw(XML::SAX::Base);
use NNexus::Response;


my (%req_args, $current_element, $entry_count, $sent_count, @synonyms, @classes, @ssynonyms);

sub new {
	my $type = shift;
	return bless {}, $type;
}

sub start_document {
	my ($self, $doc) = @_;
# do nothing for now.
}

sub start_element {
	my ($self, $element) = @_;
# process element start event

#This is the new entry section
#
	if ($element->{Name} eq 'entry') {
		%req_args = ();
		$entry_count++;
		@synonyms = ();
		@classes = ();
	} elsif ( $element->{Name} eq 'defines' ) {
		@ssynonyms = ();
	}  else {
		$current_element = $element->{Name};
	}
}

sub characters {
	my ($self, $characters) = @_;
	my $text = $characters->{Data};
	if ($text){
		if ($current_element eq 'synonym') {
			push @ssynonyms, $text;
		} elsif ( $current_element eq 'class' ) {
			push @classes, $text;
		}
		else {
			$req_args{$current_element} .= $text;
		}
	}
}

sub end_document {
	my ($self, $prop) = @_;
# we do nothing for now.
}

sub end_element {
	my ($self, $element) = @_;

#
#adding new objects section
#	
	if ($element->{Name} eq 'entry')  {
#update the synonyms in the argument hash
		$req_args{'synonyms'} = \@synonyms;
		$req_args{'classes'} = \@classes;
#print "adding a new object to the server for domain $req_args{domain} \n";
#we have finished building an entry and we must now add it to
# the database.
		NNexus::add_entry( \%req_args );

	} elsif ( $element->{Name} eq 'deleteentry' ) {

		NNexus::delete_entry( \%req_args );

	} elsif ( $element->{Name} eq 'defines' ) {
		push @synonyms, \@ssynonyms;

	} elsif ( $element->{Name} eq 'getinvalidobjects' ) {
		print "sending all invalid objects to client\n";

# 	
#processing request section
#
	} elsif ( $element->{Name} eq 'linkentry' ) {
# we need to return the submitted article with links attached back through the socket.
#print "calling link_entry\n";
		$req_args{'classes'} = \@classes;
		NNexus::link_entry( \%req_args );

	} elsif ( $element->{Name} eq 'detailedreq' ) {
#print "processing detailed request\n";
	} elsif ( $element->{Name} eq 'getconcepts' ) {
#print "returning concepts for domains (fill me in)\n";
	}
	else {
# we do nothing for now -- we can use this section for error cheching if we decide to
# not use a dtd for validation.
	}
}

1;
