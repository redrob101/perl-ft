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
my $trCommand = "";
my $here_doc= "";
my $FH;

sub scpTransfer_file {
    system("$trCommand $key $file $user\@$host:$file");
}
sub sftpTransfer_file {
    system("$trCommand $key $user\@$host $here_doc");
}
while(1)
{
    if($#ARGV < 2) # too few params
    {
        say "\nusage: perl $0 <file (or -l <listfile>)> <user> <host> [optional key (path of the key file)]\n";
        last;
    }
    else # right # of params
    {
        if ($ARGV[0] ne "-l" and $ARGV[3] eq "") # no "-l" and no key
        {
            $key = "";
            say "Please choose transfer method:\n1) scp\n2) sftp";
            my $answer = <STDIN>;
            chomp $answer;
            if ($answer eq "1")
            {
                say "Transfer method: SCP";
                $trCommand = "scp";
                &scpTransfer_file;
                last;
            }
            elsif($answer eq "2")
            {
                say "Transfer method: SFTP";
                $trCommand = "sftp";
                $here_doc = "<<EOT
                            put ".$file."
                            quit
                            EOT";
                &sftpTransfer_file;
                last;
            }
            else 
            {
                say "you MUST specify a file transfer method";
            }
        }
        
        elsif ($ARGV[0] ne "-l" and $ARGV[3] ne "") #no -l and key specified
        {
            say "Please choose transfer method:\n1) scp\n2) sftp";
            my $answer = <STDIN>;
            chomp $answer;
            if ($answer eq "1")
            {
                say "Transfer method: SCP";
                $trCommand = "scp -i";
                &scpTransfer_file;
                last;
            }
            elsif($answer eq "2")
            {
                say "Transfer method: SFTP";
                $trCommand = "sftp -i";
                $here_doc = "<<EOT
                            put ".$file."
                            quit
                            EOT";
                &sftpTransfer_file;
                last;
            }
            else 
            {
                say "you MUST specify a file transfer method";
            }
        }
        
        elsif($ARGV[0] eq "-l" and $#ARGV == 3) # '-l' and no key specified
        {
            say "Please choose transfer method:\n1) scp\n2) sftp";
            my $answer = <STDIN>;
            $host = $ARGV[3];
            $user = $ARGV[2];
            chomp $answer;
            $filelist = $ARGV[1];
            open ($FH, '<', $filelist) or die "Cannot open ".$filelist;
            if ($answer eq "1") # you choose scp
            {
                say "Transfer method: SCP";
                $trCommand = "scp";
                $key = "";
                while (my $line = <$FH>) 
                {
                    chomp($line);
                    $file=$line;
                    &scpTransfer_file;
                }
                last;
            }
            elsif ($answer == 2) # you choose SFTP
            {
                say "transfer method: SFTP";
                $trCommand = "sftp";
                $key = "";
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
                last;
                close $FH;
            }
            else 
            {
                say "you MUST specify a file transfer method";
            }
            
        } 
        elsif($ARGV[0] eq "-l" and $#ARGV == 4) # '-l and key specified
        {
            say @ARGV;
            $key = $ARGV[4];
            $host = $ARGV[3];
            $user = $ARGV[2];
            say "Please choose transfer method:\n1) scp\n2) sftp";
            my $answer = <STDIN>;
            chomp $answer;
            $filelist = $ARGV[1];
            open ($FH, '<', $filelist) or die "Cannot open ".$filelist;
            if ($answer eq "1") # you choose scp
            {
                say "Transfer method: SCP";
                $trCommand = "scp";
                $key = "";
                while (my $line = <$FH>) 
                {
                    chomp($line);
                    $file=$line;
                    &scpTransfer_file;
                }
                last;
            }
            elsif ($answer == 2) # you choose SFTP
            {
                say "transfer method: SFTP";
                $trCommand = "sftp";
                $key = "";
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
                last;
                close $FH;
            }
        }
        else
        {
            say "\nPlease check your parameters, maybe there's something wrong\n";
            say "$ARGV[0]";
            say "$#ARGV";
            last;
        }
    }
}
