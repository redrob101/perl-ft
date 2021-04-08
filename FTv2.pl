use strict;
use warnings;
use v5.10;
use Getopt::Long;

my $transfer_type="scp";
my $listfile = "";
my $user = "";
my $host = "";
my $file = "";
my $command = "";
my $key="";
my $hd = "";

sub TransferMultipleFilesScp {
    if ($key eq ""){
        say "\ntransferring multiple files using \'scp\'\n";
    }
    elsif ($key ne ""){
        say "\ntransferring multiple files using \'scp\' and the provided key \'$key\'\n";
    }
    open my $FH, '<', $listfile or die "Cant open file '$listfile' $!";
    while (my $line = <$FH>)
    {
        chomp $line;
        $file = $line;
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
    while (my $line = <$FH>)
    {
        chomp $line;
        $file = $line;
        my $here_doc = "<<EOT
                    put ".$file."
                    quit
                    EOT";
        $command = "$transfer_type $key $user\@$host $here_doc";
        system ($command);
    }
    close $FH;
}

GetOptions('t=s' => \ $transfer_type,
           'l=s' => \ $listfile,
           'k=s' => \ $key,
           'u=s' => \ $user,
           'h=s' => \ $host,
           'f=s' => \ $file) or die "\nplease check your arguments are correct";

   $hd = "<<EOT
         put ".$file."
         quit
         EOT";

    if ($key eq "" and $listfile eq "" and $transfer_type ne "sftp") { #no key and no list
        $command = "$transfer_type $file $user\@$host:$file";
        say "\ntransferring a single file using 'scp'\n";
        system($command);
    } elsif ($key ne "" and $listfile eq "" and $transfer_type ne "sftp") { #key and no list
        $command = "$transfer_type -i $key $file $user\@$host:$file";
        say "\ntransferring a single file using 'scp' and the provided key \'$key\'\n";
        system($command);
    } elsif ($listfile ne "" and $key eq "" and $transfer_type ne "sftp"){ #no key and list
        &TransferMultipleFilesScp;
    } elsif ($listfile ne "" and $key ne "" and $transfer_type ne "sftp"){ #key and list
        $transfer_type = "scp -i";
        &TransferMultipleFilesScp;
    }
    elsif($transfer_type eq "sftp" and $listfile eq "" and $key eq ""){ #sftp, no key and no list
        say "\ntransferring a single file using 'sftp'\n";
        $command = "$transfer_type $user\@$host $hd";
        system ($command);
    }elsif($transfer_type eq "sftp" and $listfile eq "" and $key ne ""){ #sftp, key and no list
        say "\ntransferring a single file using 'sftp' and the provided key \'$key\'\n";
        $transfer_type = "sftp -i";
        $command = "$transfer_type $key $user\@$host $hd"; 
        system ($command);
    }
    elsif ($transfer_type eq "sftp" and $listfile ne "" and $key eq ""){ #sftp, list and no key
        TransferMultipleFilesSftp;
    }
    elsif ($transfer_type eq "sftp" and $listfile ne "" and $key ne "") { #sftp, list and key
        $transfer_type = "sftp -i";
        TransferMultipleFilesSftp;
    }
