#! /usr/bin/perl

die "You must pass in at least one parameter - the target directory" unless $ARGV[0];

my $target = $ARGV[0];
die "Target must be a directory!" unless -d $target;

my $output_name;
if ($ARGV[1]) {
    $output_name = $ARGV[1];
    die "output file must have the .epub extension" unless $output_name =~ m/\.epub$/i;
    } else {
    ($output_name) = $target =~ m|(?:^\|/)([^/]+)$|;
    $output_name .= ".epub";
    }

use File::Find;

my $mimetype;
find( sub{ $mimetype = $File::Find::name if m/mimetype/i && !m/(?:\.svn|\.DS_STORE)/ }, $target);
die "Couldn't find mimetype" unless $mimetype;

use Archive::Zip;

my $zip = Archive::Zip->new();
$mimetype =~ s|$target/||;
print "zipping $target/$mimetype\n";
my $mimetype_zipped = $zip->addFile("$target/$mimetype", $mimetype);
$mimetype_zipped->desiredCompressionLevel(0);

my @members;
find( sub{ push @members, $File::Find::name if -f && !m/(?:\.svn|\.DS_STORE)/i }, $target);
die "No members found!" unless scalar(@members);

foreach my $member (@members) {
    next if $member =~ m/mimetype/;
    $member =~ s|$target/||;
    print "zipping $target/$member\n";
    $zip->addFile("$target/$member", $member);
}

unless( $zip->writeToFileNamed($output_name) == AZ_OK ) { die "Couldn't write $output_name" }

print "all done! zipping successful!";