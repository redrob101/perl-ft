use strict;
use warnings;
use v5.10;
use Getopt::Long;
use Net::Ping;
use Net::SCP;
use Net::SFTP::Foreign;
use IO::Socket::PortState qw(check_ports);

my $transfer_type="scp";
my $listfile = "";
my $user = "";
my $host = "";
my $file = "";
my $command = "";
my $key="";
my $hd = "";
my $hostlist;
my $proto   = 'tcp';
my $port    = '22';
my($section, %porthash);
my $timeout = '5';

sub TransferMultipleFilesScp {
    if ($key eq ""){
        say "\ntransferring multiple files using \'scp\'\n";
    }
    elsif ($key ne ""){
        say "\ntransferring multiple files using \'scp\' and the provided key \'$key\'\n";
    }
    open my $FH, '<', $listfile or die "Can't open file '$listfile' $!";
    while ($file = <$FH>)
    {
        chomp $file;
        $command = "$transfer_type $key $file $user\@$host:$file";
        system ($command);
    }
    close $FH;
}

sub TransferMultipleFilesSftp {
    if ($key eq ""){
        say "\ntransferring multiple files using \'sftp\'\n";
    }
    elsif ($key ne ""){
        say "\ntransferring multiple files using \'sftp\' and the provided key \'$key\'\n";
    }
    open my $FH, '<', $listfile or die "Cant open file '$listfile' $!";
    while (my $file = <$FH>)
    {
        chomp $file;
        my $here_doc = "<<EOT
                    put ".$file."
                    quit
                    EOT";
        $command = "$transfer_type $key $user\@$host $here_doc";
        system ($command);
    }
    close $FH;
}

sub check_avail { 
    $porthash{$proto}{$port}{'name'} = $section;
    check_ports($host, $timeout, \%porthash);

    my $open = $porthash{$proto}{$port}{'open'};
    if ($open) {
        print "\nhost reachable, connected!\n";
    }
    else {
        die "Host is unreachable, check connection...";
    }
}

GetOptions('t=s' => \ $transfer_type,
           'l=s' => \ $listfile,
           'k=s' => \ $key,
           'u=s' => \ $user,
           'h=s' => \ $host,
           'f=s' => \ $file,
           'host-list:s' => \ $hostlist) or die "\nPlease check if your arguments are correct";

   $hd = "<<EOT
         put ".$file."
         quit
         EOT";

    die "This script requires at least three arguments: -f <filename> (or -l <listfile>) -u <username> -h <host> " unless (($file || $listfile)  && $user && $host);

    if ($key eq "" and $listfile eq "" and $transfer_type ne "sftp" and $user ne "" and $host ne "") { #no key and no list
        $command = "$transfer_type $file $user\@$host:$file";
        say "\ntransferring a single file using 'scp'";
        &check_avail;
        system($command);
    } elsif ($key ne "" and $listfile eq "" and $transfer_type ne "sftp") { #key and no list
        $command = "$transfer_type -i $key $file $user\@$host:$file";
        say "\ntransferring a single file using 'scp' and the provided key \'$key\'";
        &check_avail;
        system($command);
    } elsif ($listfile ne "" and $key eq "" and $transfer_type ne "sftp"){ #no key and list
        &check_avail;
        &TransferMultipleFilesScp;
    } elsif ($listfile ne "" and $key ne "" and $transfer_type ne "sftp"){ #key and list
        $transfer_type = "scp -i";
        &check_avail;
        &TransferMultipleFilesScp;
    } elsif($transfer_type eq "sftp" and $listfile eq "" and $key eq ""){ #sftp, no key and no list
        say "\ntransferring a single file using 'sftp'";
        $command = "$transfer_type $user\@$host $hd";
        &check_avail;
        system ($command);
    } elsif($transfer_type eq "sftp" and $listfile eq "" and $key ne ""){ #sftp, key and no list
        say "\ntransferring a single file using 'sftp' and the provided key \'$key\'";
        $transfer_type = "sftp -i";
        $command = "$transfer_type $key $user\@$host $hd";
        &check_avail;
        system ($command);
    } elsif ($transfer_type eq "sftp" and $listfile ne "" and $key eq ""){ #sftp, list and no key
        &check_avail;
        &TransferMultipleFilesSftp;
    } elsif ($transfer_type eq "sftp" and $listfile ne "" and $key ne "") { #sftp, list and key
        $transfer_type = "sftp -i";
        &check_avail;
        &TransferMultipleFilesSftp;
    } elsif ($file eq "" and $user eq "" and $host eq ""){
        say "you need to specify at least three parameters: -f -u -h\n Example: perl $0 -f <filename> -u <user> -h <host>";
    }
