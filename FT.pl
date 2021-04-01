#!/usr/bin/perl

use strict;
use warnings;
use 5.028;

my $file = $ARGV[0];
my $user = $ARGV[1];
my $host = $ARGV[2];
my $key = $ARGV[3];
my $Ttype;
#my $c =  1;
my $trCommand;
# $trCommand can have the following values:
# 'scp '
# 'scp -i'
# 'sftp '
# 'sftp -i'
my $here_doc = "<<EOT
                put ".$file."
                quit
                EOT";

sub scpTransfer_file {
    $trCommand ='scp';
    system("$trCommand $key $file $user\@$host:$file");
    say "$trCommand $key $file $user\@$host:$file";
}

sub scpTansfer_single_file_key: {
    system('scp -i'.$key.' '.$file.' '.$user.'@'.$host.':'.$file);    
}
sub scpTansfer_single_file_nokey {
    system('scp '.$file.' '.$user.'@'.$host.':'.$file);    
}
sub sftpTransfer_single_file_key {
    system("sftp -i".$key." ".$user."@".$host." <<EOT
                                    put ".$file."
                                    quit
                                    EOT");
}
sub sftpTransfer_single_file_nokey {
    system("sftp ".$user."@".$host." <<EOT
                                    put ".$file."
                                    quit
                                    EOT");
}

while(1)
{
    if($#ARGV < 2) 
    {
        say "\nusage: perl $0 <file (or -l <listfile>)> <user> <host> [optional key (path of the key file)]\n";
        last;
    }
    elsif  ($ARGV[0] eq "-l")
    {
        $user = $ARGV[2];
        $host = $ARGV[3];
        say "Chose transfer method:\n1)SCP\n2)SFTP";
        my $answer = <STDIN>;
        my $filelist = $ARGV[1];
        open (my $FH, '<', $filelist) or die "Cannot open ".$filelist;
        if ($answer == 1) # you chose SCP
        {
            say "transfer method: SCP";
            $trCommand = "scp";
            while (my $line = <$FH>) 
            {
                chomp($line);
                $file=$line;
                &scpTansfer_single_file_nokey;
                &scpTransfer_file;
            }
        }
        elsif ($answer == 2)
        {
            say "transfer method: SFTP";
            $trCommand = "sftp";
            while (my $line = <$FH>) 
            {
                chomp($line);
                $file=$line;
                &sftpTransfer_single_file_nokey;
            }
        }
        last;
        close $FH;
    }
    else
    {
        if($ARGV[3] eq "")  #if you DON'T specify a key
        {
            say("Empty key!");
            say("Choose transfer method:\n1)SCP\n2)SFTP");
            my $answer=<STDIN>;
            if ($answer == 1 or $answer == 2)
            {
                if($answer == 1)
                {
                $Ttype = "SCP";
                say "transfer method = SCP";
                $trCommand = "scp";
                &scpTansfer_single_file_nokey;
                &scpTransfer_file;
                last;
                }
                elsif($answer == 2)
                {
                $Ttype= "SFTP";
                say "Transfer type = SFTP" ;
                &sftpTransfer_single_file_nokey;
                last;
                }
            }
            else
            {
                say ("\nYou MUST specify a file transfer method!!\n");
            }
        }
        elsif($ARGV[3] ne "") #if you specify a key
        {
            say("key exists!");
            say("Chose transfer method:\n1)SCP\n2)SFTP");
            my $answer=<STDIN>;
            if ($answer == 1 or $answer == 2)
            {
                if($answer == 1)
                {
                $Ttype = "SCP";
                say("transfer method = SCP");
                &scpTansfer_single_file_key;
                last;
                }
                elsif($answer == 2)
                {
                $Ttype= "SFTP";
                say("Transfer type = SFTP");
                &sftpTransfer_single_file_key;
                last;
                }
            }
            else
            { 
                say ("\nYou MUST specify a file transfer type!!\n");
            }
            last;
        }
    }
}
