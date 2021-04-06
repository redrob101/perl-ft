#!/usr/bin/perl

use strict;
use warnings;
use 5.028;

my $file = $ARGV[0];
my $user = $ARGV[1];
my $host = $ARGV[2];
my $key = $ARGV[3];
my $filelist;
my $Ttype;
my $trCommand;
my $here_doc;
my $FH;
my $answer;

sub scpTransfer_file {
    system("$trCommand $key $file $user\@$host:$file");
}

sub sftpTransfer_file {
    system("$trCommand $key $user\@$host $here_doc");
}

sub askTransferMethod {
    while(1) 
    {
        say "Please choose transfer method:\n1) scp\n2) sftp";
        $answer = <STDIN>;
        chomp $answer;
        if ($answer eq "1" and $#ARGV == 2) # no '-l' and  no key specified and TM = scp
        {
            $key = "";
            #say "\nstep #1\n";
            $trCommand = "scp";
            &scpTransfer_file;
            last;
        }
        elsif ($answer eq "2" and $#ARGV == 2) # no '-l' and no key specified and TM = sftp
        {
            $key = "";
            #say "\nstep #2\n";
            $trCommand = "sftp";
            $here_doc = "<<EOT
                        put ".$file."
                        quit
                        EOT";
            &sftpTransfer_file;
            last;
        }
        elsif ($answer eq "1" and $ARGV[3] ne "" and $ARGV[0] ne "-l") # no '-l' and key specified and TM = scp
        {
            #say "\nstep #3\n";
            $trCommand = "scp -i";
            &scpTransfer_file;
            last;
        }
        elsif ($answer eq "2" and $ARGV[0] ne "-l" and $#ARGV == 3) # no '-l' and key specified and TM = sftp
        {
            #say "\nstep #4\n";
            $trCommand = "sftp -i";
            $here_doc = "<<EOT
                        put ".$file."
                        quit
                        EOT";
            &sftpTransfer_file;
            last;
        }
        elsif ($answer eq "1" and $ARGV[0] eq "-l" and $#ARGV == 3) # '-l' specified, no key and TM = scp
        {
            #say "\nstep #5\n";
            $trCommand = "scp";
            $key = "";
            $filelist = $ARGV[1];
            $user = $ARGV[2];
            $host = $ARGV[3];
            open ($FH, '<', $filelist) or die "Cannot open ".$filelist;
            while (my $line = <$FH>) 
            {
                chomp($line);
                $file=$line;
                &scpTransfer_file;
            }
            close $FH;
            last;
        }
        elsif ($answer eq "2" and $ARGV[0] eq "-l" and $#ARGV == 3) # '-l' specified, no key and TM = sftp
        {
            #say "\nstep #6\n";
            $trCommand = "sftp";
            $key = "";
            $filelist = $ARGV[1];
            $user = $ARGV[2];
            $host = $ARGV[3];
            open ($FH, '<', $filelist) or die "Cannot open ".$filelist;
            while (my $line = <$FH>)
            {
                chomp($line);
                $file=$line;
                $here_doc = "<<EOT
                        put ".$file."
                        quit
                        EOT";
                &sftpTransfer_file;
            }
            close $FH;
            last;
        }
        elsif ($answer eq "1" and $ARGV[0] eq "-l" and $#ARGV == 4) # '-l' specified, key and TM = scp
        {
            #say "\nstep #7\n";
            $trCommand = "scp -i";
            $key = $ARGV[4];
            $filelist = $ARGV[1];
            $user = $ARGV[2];
            $host = $ARGV[3];
            open ($FH, '<', $filelist) or die "Cannot open ".$filelist;
            while (my $line = <$FH>)
            {
                chomp($line);
                $file=$line;
                &scpTransfer_file;
            }
            close $FH;
            last;
        }
        elsif ($answer eq "2" and $ARGV[0] eq "-l" and $#ARGV == 4) # '-l' specified, key and TM = sftp
        {
            #say "\nstep #8\n";
            $trCommand = "sftp -i";
            $key = $ARGV[4];
            $filelist = $ARGV[1];
            $user = $ARGV[2];
            $host = $ARGV[3];
            open ($FH, '<', $filelist) or die "Cannot open ".$filelist;
            while (my $line = <$FH>)
            {
                chomp($line);
                $file=$line;
                $here_doc = "<<EOT
                        put ".$file."
                        quit
                        EOT";
                &sftpTransfer_file;
            }
            close $FH;
            last;
        }
        else
        {
            say "you MUST choose a transfer method"
        }
    }
}
### end of subs

    if($#ARGV < 2) # too few params
    {
        say "\nusage: perl $0 <file (or -l <listfile>)> <user> <host> [optional key (path of the key file)]\n";
    }
    else # right # of params
    {
        if ($ARGV[0] ne "-l" and $#ARGV == 2) # no "-l" and no key
        {
            say "no '-l' and no key specified";
            &askTransferMethod;
        }

        elsif ($ARGV[0] ne "-l" and $ARGV[3] ne "") #no -l and key specified
        {
            say "no '-l' and key specified";
            &askTransferMethod;
        }
        elsif($ARGV[0] eq "-l" and $#ARGV == 3) # '-l' and no key specified
        {
            &askTransferMethod;
        } 
        elsif($ARGV[0] eq "-l" and $#ARGV == 4) # '-l and key specified
        {
            &askTransferMethod;
        }
        else
        {
            say "\nPlease check your parameters, maybe there's something wrong\n";
        }
    }

