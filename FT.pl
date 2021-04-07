#!/usr/bin/perl
# A simple file transfer application which uses scp
# you can use sftp by specifying the '-s' parameter
# you can also specify a list of files in a txt format with '-l'
# usage: perl FT.pl [-s (optional - use sftp)] <file (or -l <listfile>)> <user> <host> [optional key (path of the key file)]

use strict;
use warnings;
use 5.028;

my $file = $ARGV[1];
my $user;
my $host;
my $key;
my $trCommand = "scp";
my $here_doc = "<<EOT
                put ".$file."
                quit
                EOT";
my $FH;
my $command;
my $filelist;

sub TransferMultipleFilesScp {
    $filelist = $ARGV[1];
    say "transferring multiple files using scp";
    open $FH, '<', $filelist or die "Cant open file '$filelist' $!";
    while (my $line = <$FH>)
    {
        chomp $line;
        $file = $line;
        $command = "$trCommand $key $file $user\@$host:$file";
        system ($command);
    }
    close $FH;
}

sub TransferMultipleFilesSftp {
    $filelist = $ARGV[2];
    say "transferring multiple files using sftp";
    open $FH, '<', $filelist or die "Cant open file '$filelist' $!";
    while (my $line = <$FH>)
    {
        chomp $line;
        $file = $line;
        $here_doc = "<<EOT
                    put ".$file."
                    quit
                    EOT";
        $command = "$trCommand $key $user\@$host $here_doc";
        system ($command);
    }
    close $FH;
}
### end of subs

    if($#ARGV < 2) # too few params
    {
        say "\nusage: perl $0 [-s (optional - use sftp)] <file (or -l <listfile>)> <user> <host> [optional key (path of the key file)]\n";
    }
    else # right # of params
    {
        if ($ARGV[0] ne "-l" and $ARGV[0] ne "-s" and $#ARGV == 2) # no '-l' or '-s' and no key specified
        {
            say "no '-l' and no key specified";
            $file = $ARGV[0];
            $user = $ARGV[1];
            $host = $ARGV[2];
            $command = "$trCommand $file $user\@$host:$file";
            system ("$command");
        }
        elsif ($ARGV[0] ne "-l" and $ARGV[0] ne "-s" and $ARGV[3] ne "") #no '-l' or '-s' and key specified
        {
            say "no '-l' and key specified";
            $file = $ARGV[0];
            $user = $ARGV[1];
            $host = $ARGV[2];
            $key = $ARGV[3];
            $trCommand= "scp -i";
            $command = "$trCommand $key $file $user\@$host:$file";
            system ("$command");
        }
        elsif($ARGV[0] eq "-l" and $#ARGV == 3) # '-l' and no key specified
        {
            say "'-l' and no key specified";
            $key = "";
            my $filelist = $ARGV[1];
            $user = $ARGV[2];
            $host = $ARGV[3];
            $trCommand = "scp";
            &TransferMultipleFilesScp;
        } 
        elsif($ARGV[0] eq "-l" and $#ARGV == 4) # '-l' and key specified
        {
            say "'-l' and key specified";
            $trCommand = "scp -i";
            $user = $ARGV[2];
            $host = $ARGV[3];
            $key = $ARGV[4];
            &TransferMultipleFilesScp;
        }
        elsif ($ARGV[0] eq "-s" and $#ARGV == 3) # '-s', no '-l' and no key 
        {
            say "'-s' and no key specified";
            $trCommand = "sftp";
            $file = $ARGV[1];
            $user = $ARGV[2];
            $host = $ARGV[3];
            $command = "$trCommand $user\@$host $here_doc";
            system($command);
        }
        elsif ($ARGV[0] eq "-s" and $ARGV[1] ne "-l" and $ARGV[4] ne "") # '-s', no '-l' and key specified
        {
            say ("'-s' and key specified");
            $trCommand = "sftp -i";
            $file = $ARGV[1];
            $user = $ARGV[2];
            $host = $ARGV[3];
            $key = $ARGV[4];
            $command = "$trCommand $key $user\@$host $here_doc";
            system($command);
        }
        elsif($ARGV[0] eq "-s" and $ARGV[1] eq "-l" and $#ARGV == 4) # '-s','-l' and no key
        {
            say "'-s', '-l' and no key specified";
            $trCommand = "sftp";
            $key = "";
            $filelist = $ARGV[2];
            $user = $ARGV[3];
            $host = $ARGV[4];
            &TransferMultipleFilesSftp;
        }
        elsif ($ARGV[0] eq "-s" and $ARGV[1] eq "-l" and $#ARGV == 5) # -s','-l' and key specified
        {
            say "'-s', '-l' and key specified";
            $trCommand = "sftp -i";
            $key = $ARGV[5];
            $filelist = $ARGV[2];
            $user = $ARGV[3];
            $host = $ARGV[4];
            &TransferMultipleFilesSftp;
        }
        else
        {
            say "\nPlease check your parameters, maybe there's something wrong\n";
        }
    }
